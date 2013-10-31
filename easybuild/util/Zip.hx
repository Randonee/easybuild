package easybuild.util;

import haxe.zip.Entry;
import sys.FileSystem;
import sys.io.File;
import haxe.io.Bytes;

class Zip
{
	var entries:List<Entry>;

	public function new()
	{
		entries = new List();
	}

	public function entryFromFile(path:String, entryPath:String):Entry
	{
		if(FileSystem.exists(path))
		{
			if(FileSystem.isDirectory(path))
			{
				var entry:Entry = createDirectoryEntry(entryPath);
				entries.push(entry);
				return entry;
			}
			else
			{
				var inFile = File.read(path);
				var entry:Entry = {
					fileName : entryPath,
					fileSize : 0,
					fileTime : Date.now(),
					compressed : false,
					dataSize : 0,
					data : inFile.readAll(),
					crc32 : 0,
					extraFields : null
				};
				entries.add(entry);
				return entry;
			}
		}
		return null;
	}
	
	public function addDirectory(path:String, ?entryPath:String=""):Void
	{
		if(path.charAt(path.length-1) != "/")
			path += "/";
	
		var parts = path.split("/");
		entryPath = entryPath + parts[parts.length-2] + "/";
		
		var files = FileSystem.readDirectory(path);
		for(file in files)
		{
			if(FileSystem.isDirectory(path + file))
			{
				addDirectory(path + file, entryPath);
			}
			else
			{
				if(file != ".DS_Store")
					entryFromFile(path + file, entryPath + file);
			}
		}
	}
	
	public function createDirectoryEntry(entryPath:String):Entry
	{
		var entry:Entry = {
			fileName : entryPath + "/",
			fileSize : 0,
			fileTime : Date.now(),
			compressed : false,
			dataSize : 0,
			data : null,
			crc32 : 0,
			extraFields : null
		};
		
		entries.add(entry);
		return entry;
	}
	
	public function entryFromString(entryPath:String, data:String):Entry
	{
		var entry:Entry = {
			fileName : entryPath,
			fileSize : 0,
			fileTime : Date.now(),
			compressed : false,
			dataSize : 0,
			data : Bytes.ofString(data),
			crc32 : 0,
			extraFields : null
		};
		entries.add(entry);
		return entry;
	}
	
	public function save(directory:String, name:String):Void
	{
		if(!FileSystem.exists(directory))
			FileUtil.createDirectory(directory);
	
		var fout = File.write(directory + "/" + name);
		var writer = new haxe.zip.Writer(fout);
		writer.write(entries);
		fout.close();
	}
}