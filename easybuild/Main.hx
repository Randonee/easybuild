package easybuild;

import sys.io.File;
import sys.FileSystem;
import neko.Lib;
import easybuild.util.*;

class Main
{
	public static function main():Void
	{
		var easyBuildTemp:String = "";
		try
		{
			var script:String = "";
			var target:String = "";
			var buildDir:String = ""; //always last argument
			var args = Sys.args();
			
			if(args.length == 2 && (args[0] == "?" || args[0] == "help") )
			{
				Lib.println("Commands");
				Lib.println('ebinstall           installs shortcut "eb" (example: "haxelib run install ebinstall")');
				Lib.println('(no commands)       Defaults script to "Build.hx" and runs the target named "build" (example: "eb") ');
				Lib.println('[target]            Defaults script to "Build.hx" and runs the target named [target] (example: "eb targetName")');
				Lib.println('[script] [target]   Runs the target named [target] in the script [script] (example: "eb scriptName targetName")');
				return;
			}
			else if(args.length == 1)
			{
				script = "build";
				target = "build";
				buildDir = args[0];
			}
			else if(args[0] == "ebinstall")
			{
				if(FileSystem.exists("/usr/bin/eb"))
					ProcessUtil.runCommand("/usr/bin/", "sudo", ["rm", "/usr/bin/eb"]);
				
				ProcessUtil.runCommand("/usr/bin/", "sudo", ["ln", "-s", FileUtil.getHaxelib("easybuild") + "script/eb.sh", "eb"]);
				ProcessUtil.runCommand("/usr/bin/", "sudo", ["chmod", "755", FileUtil.getHaxelib("easybuild") + "script/eb.sh"]);
				return;
			}
			else if(args.length == 2)
			{
				script = "build";
				target = args[0];
				buildDir = args[1];
			}
			else if(args.length == 0)
			{
				throw("Incorrect arguments");
			}
			else
			{
				script = args[0];
				target = args[1];

				buildDir = args[args.length-1];
			}
			
			
			if(script.indexOf(".hx") >= 0)
				script = script.substring(0, script.indexOf(".hx"));
				
			if(script.charAt(0) == "/")
			{
				buildDir = script.substring(0, script.lastIndexOf("/"));
				script = script.split("/").pop();
			}

			if(buildDir.charAt(buildDir.length-1) != "/")
				buildDir += "/";
				
			if(!FileSystem.exists(buildDir + script + ".hx"))
				throw("Build Script not found: " + buildDir + script + ".hx");

			var scriptClass = script.charAt(0).toUpperCase() + script.substr(1);
			var scriptContents = File.getContent(buildDir + script + ".hx");
			
			var mainLocatoin = FileUtil.getHaxelib("easybuild") + "template/BuildMain.hx";
			var mainContents = File.getContent(mainLocatoin);


			var r:EReg = ~/package (.*);/;
			var scriptClassImport = r.match(scriptContents) ? "import " + r.matched(1) + ";" : "";

			
			//Get compiler settings
			r = ~/\/\*COMPILER(.*)COMPILER\*\//s;
			var compilerSettings = r.match(scriptContents) ? r.matched(1) : "";
			

			var settings = compilerSettings.split("\n");
			compilerSettings = "";
			for(setting in settings)
			{
				if(setting.indexOf("-cp") >= 0)
				{
					var path = setting.split("-cp").pop();
					while(path.charAt(0) == " " && path.length > 0)
						path = path.substr(1);
					
					if(path.charAt(0) != "/")
						path = buildDir + path;
					
					compilerSettings += "\n-cp " + path;
				}
				else
					compilerSettings += "\n " + setting;
			}
			
			compilerSettings += "\n-lib easybuild";
			compilerSettings += "\n-main BuildMain";
			compilerSettings += "\n-neko Build.n";
	
			var easyBuildTemp:String = buildDir + "_easybuild/";
			cleanUp(easyBuildTemp);
			
			FileSystem.createDirectory(easyBuildTemp);
			File.saveContent(easyBuildTemp + "build.hxml", compilerSettings);
			
			FileUtil.copyFile(mainLocatoin, easyBuildTemp + "BuildMain.hx", {scriptClassImport:scriptClassImport, scriptClass:scriptClass, target:target});
			FileUtil.copyFile(buildDir + script + ".hx", easyBuildTemp + scriptClass + ".hx");
			
			ProcessUtil.runCommand(easyBuildTemp, "haxe", [easyBuildTemp + "build.hxml"]);

			var callArgs = [easyBuildTemp + "Build.n", target];

			if(args.length > 3)
			{
				var index = 2;
				while(index < args.length-1)
				{
					callArgs.push(args[index]);
					++index;
				}
			}

			ProcessUtil.runCommand(buildDir, "neko", callArgs);
			
			cleanUp(easyBuildTemp);
		}
		catch(error:Dynamic)
		{
			cleanUp(easyBuildTemp);
			Sys.exit(1);
		}
	}
	
	private static function cleanUp(dir:String):Void
	{
		if(dir != "" && FileSystem.exists(dir))
			FileUtil.deleteDirectoryRecursive(dir);
	}
	
	private static function getContent(contents:String, start:String, end:String):String
	{
		var index = contents.indexOf(start);
		if(index < 0)
			return "";
			
		index += start.length;
			
		var endIndex = contents.indexOf(end);
		if(endIndex < 0)
			return "";
		
		return contents.substring(index, endIndex);
	}

}