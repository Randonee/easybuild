/*COMPILER

COMPILER*/


import easybuild.util.*;
import sys.FileSystem;
import sys.io.File;

class BuildScript
{
	static inline private var VERSION:String = "0.0.3-alpha";
	static inline private var VERSION_DIR:String = "0,0,3-alpha";
	static inline private var BUILD_DIR:String = "build/";
	
	public function new(){};
	
	public function install():Void
	{
		build();
		var zip:Zip = new Zip();
		zip.addDirectory(BUILD_DIR + "easybuild/");
		zip.save(BUILD_DIR, "easybuild.zip");
		ProcessUtil.runCommand(Sys.getCwd(), "haxelib", ["local", "build/easybuild.zip"]);
	}
	
	public function build():Void
	{
		if(FileSystem.exists(BUILD_DIR))
			FileUtil.deleteDirectoryRecursive(BUILD_DIR);
			
		var baseDir = BUILD_DIR + 'easybuild/$VERSION_DIR/';
		var templateDir = baseDir + "template";
		
		FileUtil.createDirectory(templateDir);
		
		ProcessUtil.runCommand(Sys.getCwd(), "haxe", ["build.hxml"]);
		
		FileUtil.copyInto("template", templateDir);
		FileUtil.copyInto("easybuild", baseDir + "easybuild");
		FileUtil.copyInto("script", baseDir + "script");
		FileUtil.copyFile("haxelib.json", baseDir + "haxelib.json");
		FileUtil.copyFile(BUILD_DIR + "run.n", baseDir + "run.n");
		FileUtil.copyFile(BUILD_DIR + "run.n",  "run.n");
		File.saveContent(BUILD_DIR + "easybuild/.version", VERSION);
	}
}