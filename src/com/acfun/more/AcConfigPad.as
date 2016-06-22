package com.acfun.more
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerSkin.component.AcSlider;
	import com.acfun.Utils.Log;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	
	import fl.controls.Button;
	import fl.controls.CheckBox;
	import fl.controls.ComboBox;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import fl.core.UIComponent;
	import fl.data.DataProvider;
	import fl.events.ComponentEvent;
	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.Font;
	import flash.text.FontType;
	import flash.text.TextField;
	import flash.text.TextFormat;

	public class AcConfigPad extends DetailConfig
	{
		private var scaleSlider:AcSlider;
		private var alphaSlider:AcSlider;
		private var speedSlider:AcSlider;
		
		private var preventChange:Boolean = false;
		
		public function AcConfigPad()
		{
			super();
			
			initComponent();
		}
		
		private function initComponent():void
		{
			//设置字体
			var tf1:TextFormat = new TextFormat(null,13,0x666666);
			var tf2:TextFormat = new TextFormat(null,13,0x3a9bd9);
			for (var i:int=0;i<numChildren;i++)
			{
				var obj:Object = getChildAt(i);
				if (obj is UIComponent)
				{
					obj.setStyle("textFormat",tf1);
					obj.buttonMode = true;					
				}
				if (obj is ComboBox)
				{
					obj.textField.setStyle('textFormat', tf1);
					obj.dropdown.setRendererStyle("textFormat", tf1); 
				}
				if (obj is Button)
				{
					obj.setStyle("textFormat",tf2);
				}
			}
			
			scaleSlider = new AcSlider();			
			alphaSlider = new AcSlider();
			speedSlider = new AcSlider();
			scaleSlider.name = "comment_font_scale";
			alphaSlider.name = "comment_alpha";
			speedSlider.name = "comment_speed";
			scaleSlider.setRange(0.1,5);
			alphaSlider.setRange(0,1);
			speedSlider.setRange(0.1,2);
			scaleSlider.setWidth(280);
			alphaSlider.setWidth(280);
			speedSlider.setWidth(280);
			scaleSlider.addEventListener(Event.CHANGE,onChange);
			alphaSlider.addEventListener(Event.CHANGE,onChange);
			speedSlider.addEventListener(Event.CHANGE,onChange);			
			comment_font_scale.addChild(scaleSlider);
			comment_alpha.addChild(alphaSlider);
			comment_speed.addChild(speedSlider);
			
			resetFont.addEventListener(MouseEvent.CLICK,function():void { notify(SIGNALCONST.SET_CONFIG,{comment_font_name:"黑体"}); });
			resetScale.addEventListener(MouseEvent.CLICK,function():void{ notify(SIGNALCONST.SET_CONFIG,{comment_font_scale:1}); });
			resetAlpha.addEventListener(MouseEvent.CLICK,function():void{ notify(SIGNALCONST.SET_CONFIG,{comment_alpha:1}); });
			resetSpeed.addEventListener(MouseEvent.CLICK,function():void{ notify(SIGNALCONST.SET_CONFIG,{comment_speed:0.7}); });
						
			var mbDp:DataProvider = new DataProvider();
			mbDp.addItem({label:"仅描边",data:0});
			mbDp.addItem({label:"45度投影",data:1});
			mbDp.addItem({label:"深度投影",data:2});
			comment_font_miaobian.dataProvider = mbDp;
			
			setFontArray(false);
			
			this.addEventListener(Event.CHANGE,onChange);
			comment_font_name.addEventListener(Event.CHANGE,onChange);
			comment_font_miaobian.addEventListener(Event.CHANGE,onChange);
			only_chinese.addEventListener(Event.CHANGE,onOnlyChineseChange);
			time_anchor.addEventListener(MouseEvent.CLICK,function():void{
				if (time_anchor.selected)
					notify(SIGNALCONST.SKIN_SHOW_MESSAGE,"<b>请注意</b>\n勾选此选项，代表您发送弹幕的时间，将以聚焦到弹幕输入框的时间为准\n此时间会显示在弹幕输入框右侧\n请记住这一点，以免您的弹幕无法出现在正确的时间轴位置\n要刷新时间，按ESC令弹幕框失去焦点，之后再点进来即可。","25");
			});
			
			register(SIGNALCONST.SET_CONFIG,setConfig);
			
			setConfig(AcConfig.getInstance());
		}
		
		protected function onOnlyChineseChange(event:Event):void
		{
			setFontArray(only_chinese.selected);
			event.stopImmediatePropagation();
		}
		
		protected function onChange(event:Event):void
		{
			if (preventChange) return;
			
			var target:Object = event.target;
			var key:String = target.name;
			var selected:*;
			
			if (target is CheckBox)
			{
				selected = target.selected;
			}
			else if (target is ComboBox)
			{
				selected = target.value;				
			}
			else if (target is AcSlider)
			{
				selected = target.position;
			}
			else if (target is RadioButton && target.selected)
			{
				var group:RadioButtonGroup = target.group;
				key = group.name;
				selected = group.selectedData;
			}
			
			if (selected != undefined)
			{
				var config:Object = {};
				
				//双击全屏和双击网页全屏互斥
				if (doubleclick_fullscreen.selected && doubleclick_webfullscreen.selected)
				{
					if (target == doubleclick_fullscreen)
					{
						config.doubleclick_webfullscreen = false;
					}
					
					if (target == doubleclick_webfullscreen)
					{
						config.doubleclick_fullscreen = false;
					}
				}
				
				config[key] = selected;
				notify(SIGNALCONST.SET_CONFIG,config);
				if (key == "video_quality")
					notify(SIGNALCONST.SET_PLAYER_RATE,config.video_quality);
			}
		}
		
		private function setFontArray(onlyChinese:Boolean):void
		{
			var fontArray:Array = Font.enumerateFonts(true);
			fontArray = fontArray.filter(function(item:Font, index:int, array:Array):Boolean{				
				return item.fontType == FontType.DEVICE && (!onlyChinese || item.fontName.search(/[一-龥]|hei|kai/i) != -1);
			}).map(function(item:Font, index:int, array:Array):Object{
				return {label:item.fontName,data:item.fontName};
			});			
			var dp:DataProvider = new DataProvider(fontArray);
			comment_font_name.dataProvider = dp;
		}
		
		private function setFontName(fontname:String):void
		{
			for (var i:int=0;i<comment_font_name.length;i++)
			{
				if (comment_font_name.getItemAt(i).data == fontname)
				{
					comment_font_name.selectedIndex = i;
					break;
				}
			}
		}
		
		private function setConfig(config:Object):void
		{
			if (config == null) return;
			
			preventChange = true;
			
			if (config.comment_font_name != null)
			{
				setFontName(config.comment_font_name); 
			}
			if (config.comment_font_miaobian != null)
			{
				comment_font_miaobian.selectedIndex = config.comment_font_miaobian; 
			}
			if (config.comment_font_bold != null)
			{
				comment_font_bold.selected = config.comment_font_bold;
			}
			if (config.comment_font_scale != null)
			{
				scaleSlider.position = config.comment_font_scale; 	
			}
			if (config.comment_alpha != null)
			{
				alphaSlider.position = config.comment_alpha; 
			}
			if (config.comment_speed != null)
			{
				speedSlider.position = config.comment_speed; 
			}
			if (config.subtitle_protect != null)
			{
				subtitle_protect.selected = config.subtitle_protect; 
			}
			if (config.auto_zoom != null)
			{
				auto_zoom.selected = config.auto_zoom; 
			}
			if (config.time_anchor != null)
			{
				time_anchor.selected = config.time_anchor; 
			}
			if (config.fullscreen_input != null)
			{
				fullscreen_input.selected = config.fullscreen_input; 
			}
			if (config.auto_switch_p != null)
			{
				auto_switch_p.selected = config.auto_switch_p;
			}
			if (config.doubleclick_fullscreen != null)
			{
				doubleclick_fullscreen.selected = config.doubleclick_fullscreen;
			}
			if (config.doubleclick_webfullscreen != null)
			{
				doubleclick_webfullscreen.selected = config.doubleclick_webfullscreen;
			}
			if (config.auto_widescreen != null)
			{
				auto_widescreen.selected = config.auto_widescreen;
			}
			if (config.video_quality != null)
			{
				RadioButtonGroup.getGroup("video_quality").selectedData = config.video_quality;
			}
			if (config.max_use_memory_level != null)
			{
				RadioButtonGroup.getGroup("max_use_memory_level").selectedData = config.max_use_memory_level;
			}
			if (config.comment_useTextField != null)
			{
				comment_useTextField.selected = config.comment_useTextField;
			}
			if (config.try_hardware_accelerate != null)
			{
				try_hardware_accelerate.selected = config.try_hardware_accelerate; 
			}
			
			preventChange = false;
		}
	}
}