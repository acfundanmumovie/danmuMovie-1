package com.acfun.color
{
	public class ColorManager
	{
		private var iColor:IColor;
		private static var _instance:ColorManager = null;
		public function ColorManager()
		{
		}
		
		public static function getInstance():ColorManager
		{
			if(_instance == null){
				_instance = new ColorManager();
			}
			return _instance;
		}
		
		public function init(type:int):void{
			switch(type){
				case 1:
					iColor = new BaseColor();
					break;
				case 2:
					iColor = new TudouColor();
			}
		}
		
		public function color(colorName:String):uint{
			return iColor.getColor(colorName);
		}
	}
}