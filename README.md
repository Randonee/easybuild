EasyBuild
=====

EasyBuild lets you use haxe for build scripts. Think of it as a replacement for ant.
The great thing about EasyBuild is that build scripts are haxe classes which are compiled for neko. 

EasyBuild has only been tested on os x

Installation
----------------

run command:

	haxelib git easybuild https://github.com/Randonee/easybuild


Usage
----------------

You can install the shortcut "eb" by running
	
	haxelib run easybuild ebinstall
	
After that you can use "eb" instead of "haxelib run easybuild"


Commands
----------------

	ebinstall			installs shortcut "eb" (example: "haxelib run install ebinstall")
	(no commands)		Defaults script to "Build.hx" and runs the target named "build" (example: "eb") 
	[target]			Defaults script to "Build.hx" and runs the target named [target] (example: "eb targetName")
	[script] [target]	Runs the target named [target] in the script [script] (example: "eb scriptName targetName")


Build script format
----------------

Build scripts are haxe just classes. Each method in the class is a target. You can also specify compiler arguments using the syntax shown in the example bellow.
For a more thorow example take a look at the build script for this lib: https://github.com/Randonee/easybuild/blob/master/Build.hx

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