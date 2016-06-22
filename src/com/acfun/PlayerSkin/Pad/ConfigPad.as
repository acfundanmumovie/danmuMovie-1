package com.acfun.PlayerSkin.Pad
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.PARAM;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.MoreConfig;
	import com.acfun.PlayerSkin.SkinConfig;
	import com.acfun.PlayerSkin.component.AcSlider;
	import com.acfun.Utils.Util;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	import com.greensock.TweenLite;
	
	import flash.display.Shape;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.filters.DropShadowFilter;
	import flash.filters.GlowFilter;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	
	public class ConfigPad extends configPad
	{
		public static const MORE_OPTIONS_URL:String = PARAM.host + "/member/#area=setting;section=player;";
		
		public var fold_state:Boolean = true;		
//		public var mymask:Shape;
//		public var radios:RadioManager;
		
		private var calpha:AcSlider;
		private var mc:MoreConfig;
		
		public function ConfigPad()
		{
			super();
			init();
		}
		private function init():void {			
//			mymask = new Shape();
//			mymask.graphics.lineStyle(1, 0x000000); 
//			mymask.graphics.beginFill(0x000000); 
//			mymask.graphics.drawRect(0, 0, body.width, body.height);
//			mymask.graphics.endFill();
//			mymask.y = body.y - body.height;
			
			arrow.mouseEnabled = arrow.mouseChildren = false;
			
			register(SIGNALCONST.SET_CONFIG,setConfig);
			register(SIGNALCONST.SKIN_SHOW_MORE_CONFIG,showMoreConfig);
			
			//设置弹幕透明度滑块
			calpha = new AcSlider();
			calpha.setWidth(SkinConfig.COMMENT_ALPHA_BAR_WIDTH);			
			calpha.addEventListener(Event.CHANGE,onAlphaChange);
			bar.addChild(calpha);
			
			//设置字体
//			var tformat:TextFormat = new TextFormat();
//			tformat.font = "微软雅黑";
//			tformat.size = 12;
////			tformat.color = 0xbbbbbb;
//			for (var i:int=0;i<numChildren;i++)
//			{
//				var control:UIComponent = getChildAt(i) as UIComponent;
//				if (control is CheckBox)
//				{
//					control.setStyle("textFormat",tformat);
//				}
////				else if (control is ComboBox)
////				{
////					(control as ComboBox).textField.setStyle("textFormat",tformat);
////				}
//			}
			
//			blockGuest.setStyle("textFormat",tformat);
//			full.setStyle("textFormat",tformat);
//			cont.setStyle("textFormat",tformat);
			//设置监听
			this.addEventListener(MouseEvent.CLICK,onCheck);
//			ratioSelect.addEventListener(Event.CHANGE,onRatioChange);
//			fontSelect.addEventListener(Event.CHANGE,onFontChange);
//			fontRender.addEventListener(Event.CHANGE,onRenderChange);
//			blockGuest.addEventListener(MouseEvent.CLICK,onCheck);
//			full.addEventListener(MouseEvent.CLICK,onCheck);
//			cont.addEventListener(MouseEvent.CLICK,onCheck);
			//设置选项
			setConfig(AcConfig.getInstance());
//			var config:AcConfig = AcConfig.getInstance();
//			calpha.position = config.comment_alpha;
//			hebing.selected = config.comment_repeat_filter;
//			full.selected = config.auto_zoom;
//			cont.selected = config.auto_switch_p;
//			protect.selected = config.subtitle_protect;			
//			autoPlay.selected = config.auto_play;			
			//绑定checkbox
			Util.bindComponent(hebing,hebing_t,SkinConfig.SELECTED_COLOR);
			Util.bindComponent(full,full_t,SkinConfig.SELECTED_COLOR);
			Util.bindComponent(cont,cont_t,SkinConfig.SELECTED_COLOR);
			Util.bindComponent(protect,protect_t,SkinConfig.SELECTED_COLOR);
			Util.bindComponent(autoPlay,autoPlay_t,SkinConfig.SELECTED_COLOR);
//			var fonts:Array = Font.enumerateFonts(true);
//			var dp:DataProvider = new DataProvider();			
//			var fontname:String = config.comment_font_name;
//			var fontnames:Array = [];
//			fontSelect.dataProvider = dp;
//			fontRender.selectedIndex = config.comment_font_miaobian;
//			for each (var font:Font in fonts)
//			{
//				if (fontnames.indexOf(font.fontName) == -1 && font.fontName.search(/[一-龥]|hei|kai/i) != -1)
//				{					
//					var obj:Object = {label:font.fontName};					
//					dp.addItem(obj);
//					if (obj.label == fontname)
//						fontSelect.selectedItem = obj;	
//					fontnames.push(font.fontName);
//				}
//			}			
//			dp.sortOn("label");
			
//			radios = new RadioManager;
//			radios.x = 15;
//			radios.y = blockGuest.y + 35;
//			addChild(radios);
			
//			register(SIGNALCONST.SET_LOOP_CHANGE,function(isLoop:Boolean):void{ blockGuest.selected = isLoop; });
			

			//更多选项
			more.buttonMode = true;
			more.mouseChildren = false;
			more.addEventListener(MouseEvent.CLICK,function():void{
				notify(SIGNALCONST.SKIN_SHOW_MORE_CONFIG);
			});
		}
		
		private function showMoreConfig(panelIndex:int=0):void
		{
			//navigateToURL(new URLRequest(MORE_OPTIONS_URL),"_blank");
			if (mc == null)
			{
				mc = new MoreConfig(false,panelIndex);
				Util.dragEnable(mc,mc,new Rectangle(-mc.width + 20,-mc.height + 20,stage.stageWidth+mc.width-50,stage.stageHeight+mc.height-50),stage);
			}
			
			if (!stage.contains(mc))
			{
				stage.addChild(mc);
			}
			mc.x = (stage.stageWidth - mc.width) / 2;
			mc.y = (stage.stageHeight - mc.height) / 2;			
		}
		
		protected function onAlphaChange(event:Event):void
		{
			notify(SIGNALCONST.SET_CONFIG,{
				comment_alpha:calpha.position				
			});
		}
		
//		protected function onRenderChange(event:Event):void
//		{
//			notify(SIGNALCONST.SET_CONFIG,{comment_font_miaobian:fontRender.selectedIndex});
//		}
//		
//		protected function onFontChange(event:Event):void
//		{
//			notify(SIGNALCONST.SET_CONFIG,{comment_font_name:fontSelect.selectedLabel});
//		}
//		
//		protected function onRatioChange(event:Event):void
//		{
//			notify(SIGNALCONST.SET_PLAYER_RATIO,ratioSelect.selectedItem.data);
//		}
		
		protected function onCheck(event:Event):void
		{			
			notify(SIGNALCONST.SET_CONFIG,{		
				comment_repeat_filter:hebing.selected,
				auto_zoom:full.selected,
				auto_switch_p:cont.selected,
				subtitle_protect:protect.selected,
				auto_play:autoPlay.selected
			});	
		}
		private function foldHandler(e:MouseEvent):void {
			if (fold_state) {
				unfold();
			} else {
				fold();
			}
			fold_state = !fold_state;
		}
		public function fold(... args):void {
			TweenLite.to(this, 0.5, {y: (y + body.height)});
			for(var i:Number=0; i<args.length; i++) {
				TweenLite.to(args[i].origin, 0.5, {y: (args[i].origin.y + body.height)});
			}
			arrow.gotoAndStop("up");
			notify(SIGNALCONST.SET_CONFIG,{rightpad_config_fold_state:true});
		}
		public function unfold(... args):void {
			TweenLite.to(this, 0.5, {y: (y - body.height)});
			for(var i:Number=0; i<args.length; i++) {
				TweenLite.to(args[i], 0.5, {y: (args[i].y - body.height)});
			}
			arrow.gotoAndStop("down");
			notify(SIGNALCONST.SET_CONFIG,{rightpad_config_fold_state:false});
		}
		
		private function setConfig(config:Object):void
		{
			if (config == null) return;
			
			if (config.comment_alpha != null)
			{
				calpha.position = config.comment_alpha; 
			}
			if (config.comment_repeat_filter != null)
			{
				hebing.selected = config.comment_repeat_filter; 
			}
			if (config.auto_zoom != null)
			{
				full.selected = config.auto_zoom; 
			}
			if (config.auto_switch_p != null)
			{
				cont.selected = config.auto_switch_p; 
			}
			if (config.subtitle_protect != null)
			{
				protect.selected = config.subtitle_protect; 
			}
			if (config.auto_play != null)
			{
				autoPlay.selected = config.auto_play; 
			}
		}
	}
}