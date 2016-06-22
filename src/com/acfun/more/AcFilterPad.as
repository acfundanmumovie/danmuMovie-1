package com.acfun.more
{
	import com.acfun.External.SIGNALCONST;
	import com.acfun.Utils.Util;
	import com.acfun.comment.utils.CommentFilter;
	import com.acfun.signal.notify;
	import com.adobe.utils.DateUtil;
	import com.adobe.utils.StringUtil;
	
	import fl.controls.Button;
	import fl.controls.CheckBox;
	import fl.core.UIComponent;
	import fl.data.DataProvider;
	import fl.events.DataChangeEvent;
	
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.globalization.DateTimeFormatter;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.text.TextFormat;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.Keyboard;

	public class AcFilterPad extends FilterPad
	{
		//弹幕滚动模式等高级设置项，建议在参考wiki里写详细帮助
		public static const FILTER_TYPE:Array = ["弹幕滚动模式","颜色","关键字","用户id","字体大小"];
		
		private var items:Array;
		private var filter:CommentFilter;
		
		public function AcFilterPad()
		{
			super();
			
			initComponent();
		}
		
		private function initComponent():void
		{
			items = [bEnable,bRoll,bTop,bBottom,blRoll,bSpecial,bGuest,bChange,bRegEnable,bVSelected,bIgnoreCase,bRepfiliter];
			filter = CommentFilter.getInstance();
			filter.addEventListener(Event.CHANGE,onFilterChange);
			
			//设置字体
			var tf:TextFormat = new TextFormat(null,13,0x666666);
			for (var i:int=0;i<numChildren;i++)
			{
				var obj:Object = getChildAt(i);
				if (obj is UIComponent)
				{
					obj.setStyle("textFormat",tf);
				}		
			}
			
			//设置Datagrid
//			data	"test"	
//			enable	true	
//			exp	"test"	
//			id	0	
//			mode	2	
//			normalExp	"test"
			
			filterBox.rowHeight = 24;
			filterBox.columns = ["过滤类别","关键词","操作"];
			filterBox.getColumnAt(0).width = 80;
			filterBox.getColumnAt(1).width = 230;
			filterBox.getColumnAt(2).cellRenderer = FilterActionCellRenderer;
			var menu:ContextMenu = new ContextMenu();
			var fin:ContextMenuItem = new ContextMenuItem("导入屏蔽与过滤...");
			var fout:ContextMenuItem = new ContextMenuItem("导出屏蔽与过滤...");
			fin.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onFin);
			fout.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT,onFout);
			menu.hideBuiltInItems();
			menu.customItems.push(fin,fout);
			filterBox.contextMenu = menu;
			update();
			
			this.addEventListener(Event.CHANGE,onChange);			
			text.addEventListener(KeyboardEvent.KEY_UP,onEnter);
			addText.addEventListener(MouseEvent.CLICK,onAddText);
		}
		
		protected function onFin(event:ContextMenuEvent):void
		{
			var fr:FileReference = new FileReference();
			if (fr.browse())
			{	
				fr.addEventListener(Event.SELECT,function():void{					
					fr.addEventListener(Event.COMPLETE,function():void{
						filter.fromString(fr.data.readUTFBytes(fr.data.length));						
					});
					fr.load();
				});				
			}			
		}
		
		protected function onFout(event:ContextMenuEvent):void
		{
			var fr:FileReference = new FileReference();			
			fr.save(filter.toString(),"AcFun屏蔽与过滤设置"+Util.date2()+".json");
		}
		
		protected function onFilterChange(event:Event):void
		{
			update();
		}
		
		private function update():void
		{
			//选项
			var bs:Array = filter.bSettings;
			for (var i:int=0;i<bs.length;i++)
			{
				items[i].selected = bs[i];
			}
			
			//屏蔽列表
			var dp:DataProvider = new DataProvider();			
			var tarr:Array = filter.filterSource(0);
			if (tarr)
			{
				for each (var fo:Object in tarr)
				{
					dp.addItem({"过滤类别":FILTER_TYPE[fo.mode],"关键词":fo.exp,data:fo});
				}
			}			
			filterBox.dataProvider = dp;	
		}
		
		protected function onAddText(event:MouseEvent):void
		{
			var str:String = StringUtil.trim(text.text);			
			if (str.length > 0)
			{
				str = textType.value + "=" + str;
				filter.addItem(str);
				filter.savetoSharedObject();				
			}
			text.text = "";
		}
		
		protected function onEnter(event:KeyboardEvent):void
		{
			if (event.keyCode == Keyboard.ENTER)
			{
				onAddText(null);
			}
		}
		
		protected function onChange(event:Event):void
		{
			if (event.target is CheckBox)
			{
				if (filter[event.target.name] != null)
				{
					filter[event.target.name] = event.target.selected;
					filter.savetoSharedObject();
					
					if (event.target.name == "bRepfiliter")
						notify(SIGNALCONST.SET_CONFIG,{comment_repeat_filter:event.target.selected});
					else
						filter.dispatchEvent(new Event(Event.CHANGE));
				}
			}
		}
	}
}