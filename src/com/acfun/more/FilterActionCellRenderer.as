package com.acfun.more
{
	import com.acfun.comment.utils.CommentFilter;
	
	import fl.controls.Button;
	import fl.controls.CheckBox;
	import fl.controls.DataGrid;
	import fl.controls.listClasses.ICellRenderer;
	import fl.controls.listClasses.ListData;
	import fl.events.DataChangeEvent;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class FilterActionCellRenderer extends Sprite implements ICellRenderer
	{
		private var deleteButton:Button;
		private var enableCheckbox:CheckBox;
		
		private var _data:Object;
		private var _listData:ListData;
		private var _selected:Boolean;
		
		public function get owner():DataGrid
		{
			return _listData.owner as DataGrid;
		}
		
		public function FilterActionCellRenderer()
		{
			super();
			
			deleteButton = new Button();
			deleteButton.label = "删除";
			deleteButton.height = 20;
			deleteButton.width = 50;
			deleteButton.addEventListener(MouseEvent.CLICK,onDelete);
			
			enableCheckbox = new CheckBox();
			enableCheckbox.label = "启用";
			enableCheckbox.width = 60;
			enableCheckbox.addEventListener(Event.CHANGE,onCheck);
			
			enableCheckbox.x = 55;
			addChild(deleteButton);
			addChild(enableCheckbox);
			
			//立即重绘 否则会显示为文本...
			deleteButton.drawNow();
			enableCheckbox.drawNow();
		}
		
		protected function onCheck(event:Event):void
		{
			CommentFilter.getInstance().setEnable(_data.data.id,enableCheckbox.selected);
			CommentFilter.getInstance().savetoSharedObject();
			event.stopImmediatePropagation();
		}
		
		protected function onDelete(event:MouseEvent):void
		{
			owner.removeItem(_data);
			CommentFilter.getInstance().deleteItem(_data.data.id);
			CommentFilter.getInstance().savetoSharedObject();
			event.stopImmediatePropagation();
		}
		
		public function setStyle(arg0:String, arg1:Object):void
		{
			deleteButton.setStyle(arg0, arg1);
			enableCheckbox.setStyle(arg0, arg1);
		}
		
		public function get data():Object
		{
			return _data;
		}
		
		public function set data(arg0:Object):void
		{
			_data = arg0;
			
			enableCheckbox.selected = _data.data.enable;
			enableCheckbox.drawNow();
		}
		
		public function get listData():ListData
		{
			return _listData;
		}
		
		public function set listData(arg0:ListData):void
		{
			_listData = arg0;
		}
		
		public function get selected():Boolean
		{
			return _selected;
		}
		
		public function set selected(arg0:Boolean):void
		{
			_selected = arg0;
		}
		
		public function setMouseState(arg0:String):void
		{
			// TODO Auto Generated method stub
			
		}
		
		public function setSize(arg0:Number, arg1:Number):void
		{
			// TODO Auto Generated method stub
			
		}
		
	}
}