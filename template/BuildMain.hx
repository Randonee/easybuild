import easybuild.util.FileUtil;
import easybuild.util.ProcessUtil;
import neko.Lib;
::scriptClassImport::

class BuildMain
{
	public static function main():Void
	{
		var args = Sys.args();
		
		if(args.length == 0)
		{
			Lib.println("No target specified");
			return;
		}
		
		var target:String = args[0];
		
		var instance = new ::scriptClass::();
				
		var fields = Type.getInstanceFields(::scriptClass::);
		for(field in fields)
		{
			if(field == target)
			{
				try{
					instance.::target::();
					return;
				}
				catch(error:Dynamic)
				{
					Lib.println("ERROR: " + error);
					Sys.exit(1);
					return;
				}
			}
		}
		Lib.println('Target "' + target + '" not found.');			
	}
}