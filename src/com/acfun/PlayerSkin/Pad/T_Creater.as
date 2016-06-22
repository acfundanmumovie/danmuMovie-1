package com.acfun.PlayerSkin.Pad
{
	//import fl.controls.DataGrid;
	
	import fl.controls.DataGrid;
	import fl.controls.dataGridClasses.DataGridColumn;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.GlowFilter;
	import flash.text.TextFormat;
	import flash.ui.Mouse;
	
	public class T_Creater
	{
		public function T_Creater()
		{
		}
		
		/**例如: gridCreate([['列1','列2','列3'],['名称1(宽13)','名称2(宽默认)','名称3(宽14)'],[13,,14]])**/
		public static function gridCreate(items:Array,pos:DisplayObject = null,isAdvance:Boolean = false,tipEnable:Boolean=false):CommentGrid
		{
			if(items == null)	return null;
			if(items.length<1)	return null;
			var i:int;	
			var r:CommentGrid = new CommentGrid(tipEnable);			
			r.editable = false;
			r.verticalScrollBar.width = 3;
			var tf:TextFormat = new TextFormat("微软雅黑", 12, 0xffffff, false);
			r.setStyle("headerTextFormat", tf);			
			r.headerHeight = 22;
			if(items[0] is Array) {
				r.columns = items[0];
				if(items.length > 1) {
					for(i=0;i<items[0].length;i++) {
						if(items[1][i] != null)	{
							r.getColumnAt(i).headerText = items[1][i];
						}
					}
				} 
				if(items.length > 2) {
					for(i=0;i<items[0].length;i++) {
						if(items[2][i] != null)	{
							r.columns[i].width = items[2][i];
						}
					}
				}
			} else {
				r.columns = items;
			}
			if (pos != null){
				r.x=pos.x;
				r.y=pos.y;
				r.width=pos.width;
				r.height=pos.height;
				pos.visible=false;
			}			
			return r;
		}
	}
}