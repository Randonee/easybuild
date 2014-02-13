EasyBuild
=====

EasyBuild lets you use haxe for build scripts. Think of it as a replacement for ant.
The great thing about EasyBuild is that build scripts are haxe classes which are compiled for neko. 

EasyBuild has only been tested on os x

Installation
----------------

run command:

	haxelib git easybuild https://github.com/Randonee/easybuild


Install the shortcut "eb" by running
	
	haxelib run easybuild ebinstall
	
After that you can use "eb" instead of "haxelib run easybuild"


Usage
----------------

Build scripts are haxe classes that look something like this:

	class Build
	{
		public function new(){};

		public function build():Void
		{
			trace("Do Some Build Stuff");
		}

		public function build2():Void
		{
			trace("this is build 2");
		}
	}

If you were to save the above class to a file called Build.hx you could then go to the directory where you saved it and run the command:

	eb

This will default to running the build method of the Build class. To run build2 you would run this command

	eb build2

Now lets say you want to have more than one class. EasyBuild's default is to look for a Build class. If the class were named SuperBuild, you would run it like this:

	eb SuperBuild build



Commands
----------------

	ebinstall			installs shortcut "eb" (example: "haxelib run install ebinstall")
	(no commands)		Defaults script to "Build.hx" and runs the target named "build" (example: "eb") 
	[target]			Defaults script to "Build.hx" and runs the target named [target] (example: "eb targetName")
	[script] [target]	Runs the target named [target] in the script [script] (example: "eb scriptName targetName")


Build script format
----------------

Build scripts are just plane haxe classes. Each method in the class is a target. You can also specify compiler arguments adding /\*COMPILER [args]  COMPILER\*/ as shown in the example bellow.
For a more thorough example take a look at the build script for this lib: https://github.com/Randonee/easybuild/blob/master/BuildScript.hx

	/*COMPILER
	-cp src
	-lib someHaxelib
	COMPILER*/ 
	
	class build
	{
		public function new(){} //new constructor is required
		
		public function build():Void
		{
			trace('this is the default target that can be called with the command "eb"');
		}
		
		public function anotherTarget():Void
		{
			trace('this is a target that can be called with the command "anotherTarget"');
		}
	}
	
Sublime Text 3 Build System
----------------

Sublime Text 3 users can add this as their build system to build from within Sublime Text

	{
		"shell_cmd": "eb",
		"file_regex": "^([^:]*):([0-9]+):.*$",
		"working_dir": "${project_path:${folder}}"
	}
