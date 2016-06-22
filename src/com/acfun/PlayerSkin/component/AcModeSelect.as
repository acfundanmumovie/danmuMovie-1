package com.acfun.PlayerSkin.component
{
	import com.acfun.External.LocalStorage;
	import com.acfun.External.PARAM;
	import com.acfun.PlayerSkin.SkinConfig;
	import com.acfun.Utils.Util;
	
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import fl.core.UIComponent;
	
	import flash.display.DisplayObjectContainer;
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	import flash.ui.Keyboard;
	import flash.utils.Dictionary;

	/**
	 * Acfun弹幕模式选择模块 
	 * @author sky
	 * 
	 */
	public class AcModeSelect extends ModeSelect
	{
		//public
		public var danmakuSize:int;
		public var danmakuMode:String;
		public var danmakuColor:uint;
		
		//数据
		private var relatedDict:Dictionary;		
		private var commonColors:Array   = [0x000000,0x333333,0x666666,0x999999,0xCCCCCC,0xFFFFFF,0xFF0000,0x00FF00,0x0000FF,0xFFFF00,0x00FFFF,0xFF00FF];
		private var lastUsedColors:Array = [0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000,0x000000];
		private var panelColorsX:Array   = [0x000000,0x003300,0x006600,0x009900,0x00CC00,0x00FF00,0x330000,0x333300,0x336600,0x339900,0x33CC00,0x33FF00,0x660000,0x663300,0x666600,0x669900,0x66CC00,0x66FF00];
		private var panelColorsY:Array   = [0x000000,0x000033,0x000066,0x000099,0x0000CC,0x0000FF,0x990000,0x990033,0x990066,0x990099,0x9900CC,0x9900FF];
		private var panelColors:Array;
		private const sizeArray:Array = [37,25,16];
		private const modeArray:Array = ["1","5","4"];
		
		//样式
		private var buttonSelectedColor:uint = SkinConfig.SELECTED_COLOR;
		private var selectedShape:Shape;
		
		private var container:DisplayObjectContainer;
				
		public function AcModeSelect()
		{
			super();
			
			this.opaqueBackground = 0xffffff;
			this.cacheAsBitmap = true;
			
			initComponent();
		}
		
		private function initComponent():void
		{
			this.addEventListener(MouseEvent.CLICK,function(event:MouseEvent):void{ event.stopPropagation(); });
			this.addEventListener(MouseEvent.MOUSE_DOWN,function(event:MouseEvent):void{ event.stopImmediatePropagation(); });
			this.addEventListener(MouseEvent.ROLL_OUT,function():void{ 
				visible = false;
			});
			
			//字号
			var sizeGroup:RadioButtonGroup = s0.group;			
			sizeGroup.addEventListener(Event.CHANGE,function():void{
				danmakuSize = sizeArray[sizeGroup.selectedData];				
			});
			
			//模式
			if (PARAM.acInfo.isLive)	//直播模式不允许发送底端和顶端弹幕
				m1.visible = m2.visible = mt1.visible = mt2.visible = false;
			var modeGroup:RadioButtonGroup = m0.group;
			modeGroup.addEventListener(Event.CHANGE,function():void{
				danmakuMode = modeArray[modeGroup.selectedData];				
			});
			
			var i:int;
			relatedDict = new Dictionary();			
			for (i=0;i<3;i++)
			{
				relatedDict[this["s"+i]] = this["st"+i];
				relatedDict[this["m"+i]] = this["mt"+i];
				relatedDict[this["st"+i]] = this["s"+i];
				relatedDict[this["mt"+i]] = this["m"+i];
				
				this["s"+i].addEventListener(Event.CHANGE,onSelectedColorChange);
				this["m"+i].addEventListener(Event.CHANGE,onSelectedColorChange);
				this["st"+i].addEventListener(MouseEvent.CLICK,onSelectedColorChange);
				this["mt"+i].addEventListener(MouseEvent.CLICK,onSelectedColorChange);
				this["st"+i].buttonMode = true;
				this["st"+i].mouseChildren = false;
				this["mt"+i].buttonMode = true;
				this["mt"+i].mouseChildren = false;
			}			
			this["s1"].selected = true;
			this["m0"].selected = true;
			
			//颜色代码显示框			
			colorCode.restrict = "0-9 A-F a-f";
			colorCode.maxChars = 6;
			colorCode.borderColor = 0x3A9BD9;
			colorCode.addEventListener(MouseEvent.CLICK,function():void{
				if (colorCode.type == TextFieldType.DYNAMIC)
				{
					colorCode.type = TextFieldType.INPUT;
					colorCode.selectable = true;
					colorCode.border = true;
					colorCode.setSelection(0,colorCode.text.length);	
				}				
			});
			colorCode.addEventListener(MouseEvent.ROLL_OUT,function():void{
				colorCode.type = TextFieldType.DYNAMIC;
				colorCode.setSelection(0,0);
				colorCode.selectable = false;
				colorCode.border = false;
				colorCode.background = false;
			});
			colorCode.addEventListener(KeyboardEvent.KEY_UP,function(event:KeyboardEvent):void{
				if (event.keyCode == Keyboard.ENTER)
				{
					colorCode.type = TextFieldType.DYNAMIC;
					colorCode.setSelection(0,0);
					colorCode.text = colorCode.text.toUpperCase();
					colorCode.selectable = false;
					colorCode.border = false;
					colorCode.background = false;
					
					setDanmakuColor(int("0x" + colorCode.text));
				}
			});			
			
			//COLORPICKER
			var cellWith:int = 11;
			var cellHeight:int = 10;
			var cell:AcColorCell;			
			//常用色
			for (i=0;i<commonColors.length;i++)
			{
				cell = new AcColorCell(commonColors[i],cellWith,cellHeight);
				cell.x = 0;
				cell.y = i*cellHeight;
				colorPicker.addChild(cell);
			}
			//最近使用色
			for (i=0;i<lastUsedColors.length;i++)
			{
				cell = new AcColorCell(lastUsedColors[i],cellWith,cellHeight);
				cell.x = cellWith;
				cell.y = i*cellHeight;
				colorPicker.addChild(cell);
			}
			//调色板
			for (i=0;i<panelColorsX.length;i++)
			{
				for (var j:int=0;j<panelColorsY.length;j++)
				{
					var color:uint = panelColorsX[i] + panelColorsY[j];
					cell = new AcColorCell(color,cellWith,cellHeight);
					cell.x = (i+2)*cellWith;
					cell.y = j*cellHeight;
					colorPicker.addChild(cell);
				}
			}
			
			selectedShape = new Shape();
			selectedShape.graphics.lineStyle(2,0xffffff);
			selectedShape.graphics.drawRect(0,0,cellWith,cellHeight);
			selectedShape.visible = false;
			addChild(selectedShape);
			
			var me:AcModeSelect = this;
			colorPicker.addEventListener(MouseEvent.MOUSE_OVER,function(event:MouseEvent):void{
				var targetCell:AcColorCell = event.target as AcColorCell;
				if (targetCell)
				{
					colorCode.text = Util.convertToColorString(targetCell.color);
					var ct:ColorTransform = new ColorTransform();
					ct.color = targetCell.color;
					colorShow.transform.colorTransform = ct;
					
					var rect:Rectangle = targetCell.getRect(me);
					selectedShape.x = rect.x;
					selectedShape.y = rect.y;
					selectedShape.visible = true;
				}
			});
			colorPicker.addEventListener(MouseEvent.CLICK,function(event:MouseEvent):void{
				var targetCell:AcColorCell = event.target as AcColorCell;
				if (targetCell)
				{
					var rect:Rectangle = targetCell.getRect(me);
					selectedShape.x = rect.x;
					selectedShape.y = rect.y;
					selectedShape.visible = true;
					
					danmakuColor = targetCell.color;
				}
			});
			colorPicker.addEventListener(MouseEvent.ROLL_OUT,function():void{
				setDanmakuColor(danmakuColor);
			});
			
			//取得存储的发送参数
			var lastSendParam:Object = LocalStorage.getValue(LocalStorage.COMMENT_SEND_PARAM,{ type:"1",color:0xFFFFFF,fontSize:25});
			danmakuColor = lastSendParam.color;
			setDanmakuColor(danmakuColor);
		}
		
		private function onSelectedColorChange(event:Event):void
		{
			var rb:RadioButton;
			var rbSelected:ColorTransform = new ColorTransform();
			rbSelected.color = buttonSelectedColor;
			if (event.currentTarget is RadioButton)
			{
				rb = event.currentTarget as RadioButton;
				if (rb.selected)
					relatedDict[rb].transform.colorTransform = rbSelected;
				else
					relatedDict[rb].transform.colorTransform = new ColorTransform();	
			}
			else
			{
				rb = relatedDict[event.currentTarget] as RadioButton;
				rb.selected = true;
			}
		}
		
		private function setDanmakuColor(color:uint):void
		{
			danmakuColor = color;
			
			colorCode.text = Util.convertToColorString(danmakuColor);			
			var ct:ColorTransform = new ColorTransform();
			ct.color = danmakuColor;
			colorShow.transform.colorTransform = ct;
			
			for (var i:int=0;i<colorPicker.numChildren;i++)
			{
				var cell:AcColorCell = colorPicker.getChildAt(i) as AcColorCell;
				if (cell && cell.color == color)
				{
					var rect:Rectangle = cell.getRect(this);
					selectedShape.x = rect.x;
					selectedShape.y = rect.y;
					selectedShape.visible = true;
					return;
				}
			}			
			selectedShape.visible = false;
		}
	}
}