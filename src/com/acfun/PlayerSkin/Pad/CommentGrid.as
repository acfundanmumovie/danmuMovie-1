package com.acfun.PlayerSkin.Pad
{
	import com.acfun.External.PARAM;
	
	import fl.controls.DataGrid;
	import fl.events.ListEvent;
	
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	public class CommentGrid extends DataGrid
	{
		public var tip:TextField;
		
		public function CommentGrid(tipEnable:Boolean=false)
		{
			super();
			
			setStyle("cellRenderer", DMCellRenderer);
			this._allowMultipleSelection = true;
			
			if (tipEnable)
			{
				tip = new TextField();
				tip.mouseEnabled = false;
				tip.background = true;
				tip.backgroundColor = 0xffffff;
				tip.border = true;
				tip.borderColor = 0xdddddd;
				tip.autoSize = TextFieldAutoSize.CENTER;
				tip.wordWrap = true;
				var tf:TextFormat = new TextFormat("微软雅黑", 13, 0x676979, true);
				tf.kerning = true;
				tf.leading = 5;
				tf.leftMargin = 3;
				tip.defaultTextFormat = tf;
				tip.x = 10;
				tip.width = 295;
				tip.visible = false;				
				tip.filters = [new DropShadowFilter(2,90,0,1,2,2,0.2,2)];
				tip.alpha = 0.9;
				this.addChild(tip);
				this.addEventListener(ListEvent.ITEM_ROLL_OVER,onRollOver);
				this.addEventListener(ListEvent.ITEM_ROLL_OUT,onRollOut);	
			}
		}
		
		protected function onRollOver(event:ListEvent):void
		{
			if (!tip.visible)
			{
				//自动选取
				if (!PARAM.userInfo.isAdmin && !PARAM.userInfo.isUp)
					this.selectedIndex = event.index;
				
				if (event.item.text.length > 20 || event.item.text.search(/\r|\n/) != -1)
				{
					tip.text = event.item.text;
					tip.visible = true;				
					tip.y = this.rowHeight * event.index - this.verticalScrollPosition;					
					if (tip.y <= 0) tip.y = this.rowHeight;
				}				
			}
		}
		
		protected function onRollOut(event:ListEvent):void
		{
			tip.visible = false;
		}
	}
}