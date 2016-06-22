package com.acfun.PlayerSkin.Pad
{
	import com.acfun.Utils.Util;
	
	import fl.controls.listClasses.CellRenderer;
	import fl.controls.listClasses.ICellRenderer;
	
	import flash.text.TextFormat;
	
	public class DMCellRenderer extends CellRenderer implements ICellRenderer
	{
		private static var _textFormat:TextFormat;
		private static var _filterTextFormat:TextFormat;
		
		public function DMCellRenderer()
		{
			super();
		}
		override protected function drawBackground():void {
			if (_listData.index % 2 == 0) {
				setStyle("upSkin", CellRenderer_upSkin);				
			} else {
				setStyle("upSkin", CellRenderer_upSkin2);
			}
			super.drawBackground();
		}
		
		override public function set label(arg0:String):void
		{
			if (_textFormat == null)
			{
				_textFormat = getStyle("textFormat") as TextFormat;
				_filterTextFormat = Util.copy(_textFormat) as TextFormat;
				_filterTextFormat.color = 0xbbbbbb;
			}
			
			if (_listData.column == 1 && data.filterType != 0)
			{
				//0：正常，1：系统过滤，2：用户过滤，3：重复弹幕过滤
				switch(data.filterType)
				{
					case 1:
					{
						super.label = "[系统过滤]" + arg0;			
						break;
					}
					case 2:
					{
						super.label = "[用户过滤]" + arg0;
						break;
					}
					case 3:
					{
						super.label = "[重复弹幕过滤]" + arg0;
						break;
					}					
				}
				setStyle("textFormat",_filterTextFormat);
				return;
			}
			setStyle("textFormat",_textFormat);
			super.label = arg0;
		}
	}
}