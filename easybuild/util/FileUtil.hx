package easybuild.util;

import haxe.macro.Expr;
import haxe.macro.Context;
import Type;

#if !js
import sys.FileSystem;
import sys.io.Process;
import sys.io.File;
import sys.io.FileOutput;
import haxe.io.Path;
import haxe.Template;
#end

/**
* Much of this code was modified from NME helpers
**/
class FileUtil
{

#if !js

	static public function cleanPath(path:String):String
	{
		path = StringTools.replace(path, '\\', '/');
		path = StringTools.replace(path, '//', '/');
		while(path.charAt(path.length-1) == "/" && path.length > 0)
			path = path.substring(0, path.length-1);
		return path;
	}

	static public function deleteDirectoryRecursive(directoryName:String):Void 
	{
		directoryName = cleanPath(directoryName);
		if(!FileSystem.exists(directoryName))
			return;
			
 		for (item in FileSystem.readDirectory(directoryName)) 
        { 
                var path:String = directoryName + '/' + item; 
        
                if (FileSystem.isDirectory(path)) 
                { 
					deleteDirectoryRecursive(path); 
                } 
                else 
                { 
					FileSystem.deleteFile(path); 
                } 
        } 
        
        if (FileSystem.exists(directoryName) && FileSystem.isDirectory(directoryName)) 
        { 
                FileSystem.deleteDirectory(directoryName); 
        } 
	}
	
	static public function getFileExtention(path:String):String
	{
		return Path.extension(path);
	}
	
	public static function read(path : String) : Array<String>
	{
		return sys.FileSystem.readDirectory(path);
	}
	
	
	/**
	* Creates a directory.
	* If a directory in the path does not exist it will be created
	**/
	static public function createDirectory(path:String):Void
	{
		path = cleanPath(path);
		var parts:Array<String> = path.split("/");
		
		var currDir:String = "";
		for(a in 0...parts.length)
		{
			if(a != 0)
				currDir += "/";
			currDir += parts[a];
			if(!FileSystem.exists(currDir))
				FileSystem.createDirectory(currDir);
		}
	}
	
	/**
	* gets a path to a haxelib
	* 
	* @param library name of haxelib
	**/
	public static function getHaxelib(library:String):String
	{
		var proc = new Process ("haxelib", ["path", library ]);
		var result = "";
		
		try
		{
			while (true)
			{
				var line = proc.stdout.readLine ();
				if (line.substr (0,1) != "-")
				{
					result = line;
					break;
				}
			}
		}
		catch (e:Dynamic) { };
		
		proc.close();
		
		if (result == "")
		{
			throw ("Could not find haxelib path  " + library + " - perhaps you need to install it?");
		}
		return result;
	}
	
	/**
	* Copies contents of one directoy into another. If the destination directory does not exist it will be created
	* 
	* @param sourcePath source directory
	* @param destinationPath destination directory
	* @param settings If set each file will be treated as a haxe template and the settings will be applied.
	* @param ifNewer only copy if the source is newer than the destination.
	**/
	public static function copyInto(sourcePath : String, destinationPath : String, ?settings:Dynamic=null, ?ifNewer:Bool=false, ?include:Array<EReg>, ?exclude:Array<EReg>) : Void 
	{
		privateCopyInto(sourcePath, destinationPath, settings, ifNewer, include, exclude);
	}
	
	/**
	* Copies a file
	* 
	* @param source source file
	* @param destination destination file
	* @param settings If set the file will be treated as a haxe template and the settings will be applied.
	* @param ifNewer only copy if the source is newer than the destination.
	**/
	public static function copyFile (source:String, destination:String, ?settings:Dynamic=null, ?ifNewer:Bool=false)
	{
		var extension:String = Path.extension (source);
		if (settings != null &&
            (extension == "xml" ||
             extension == "java" ||
             extension == "hx" ||
             extension == "hxml" ||
			 extension == "html" || 
             extension == "ini" ||
             extension == "gpe" ||
             extension == "pch" ||
             extension == "pbxproj" ||
             extension == "plist" ||
             extension == "json" ||
             extension == "cpp" ||
             extension == "mm" ||
             extension == "xib" ||
             extension == "properties"))
       {
			var fileContents:String = File.getContent (source);
			var template:Template = new Template (fileContents);
			var result:String = template.execute (settings);
			var fileOutput:FileOutput = File.write (destination, true);
			fileOutput.writeString (result);
			fileOutput.close ();
		}
		else
		{
			if(!ifNewer || (ifNewer && isNewer(source, destination)) )
				File.copy(source, destination);
		}
	}
	
	/**
	* Checks if file is newer than another
	* 
	* @param source source file
	* @param destination destination file
	**/
	public static function isNewer (source:String, destination:String):Bool
	{
		if (source == null || !FileSystem.exists (source))
		{
			return false;
		}
		
		if (FileSystem.exists (destination))
		{
			if (FileSystem.stat (source).mtime.getTime () < FileSystem.stat (destination).mtime.getTime ())
			{
				return false;
			}
		}
		return true;
	}
	
	
	private static function privateCopyInto(source:String, destination:String, ?settings:Dynamic=null, ?ifNewer:Bool=false, ?include:Array<EReg>, ?exclude:Array<EReg>) : Void
	{
		source = cleanPath(source);
		if(!sys.FileSystem.exists(source))
			throw("Source does not exist: "+ source);
		
		destination = cleanPath(destination);
		if(!sys.FileSystem.exists(destination))
			createDirectory(destination);
	
		var items = read(source);
		for(itemName in items)
		{
			var itemPath = source + "/" + itemName;
			
			if(itemName.charAt(0) != ".")
			{
				if(FileSystem.isDirectory(itemPath))
				{
					privateCopyInto(itemPath, destination + "/" + itemName, settings, ifNewer, include, exclude);
				} 
				else 
				{	
					if(include == null || containsMatchItem(include, itemName))
					{
						if(!containsMatchItem(exclude, itemName))
							copyFile(itemPath, destination + "/" + itemName, settings, ifNewer);
					}
				}
			}
		}	
	}
	
	static private function containsMatchItem(patterns:Array<EReg>, itemName:String):Bool
	{
		if(patterns == null)
			return false;
			
		for(pattern in patterns)
		{
			if(pattern.match(itemName))
				return true;
		}
		return false;
	}
#end
	
	macro public static function includeFileContents(fileName:Expr, ?lookInCurrentDir:Bool=true )
	{
        var fileStr = null;
        switch( fileName.expr )
        {
			case EConst(c):
				switch( c )
				{
					case CString(s): fileStr = s;
					default:
				}
			default:
        }
        
        
        if( fileStr == null )
            Context.error("Constant string expected",fileName.pos);
		
		var path:String = "";
		if(lookInCurrentDir)
		{
			path = Std.string(fileName.pos);
			path = path.substring(path.indexOf("(") + 1, path.indexOf(":")-1);
			path = path.substring(0, path.lastIndexOf("/") + 1);
		}

		if(!sys.FileSystem.exists(path + fileStr))
			Context.error("File Does not exist: " + path + fileStr, fileName.pos);
            
        return Context.makeExpr(sys.io.File.getContent(path + fileStr), fileName.pos);
	}
	
}