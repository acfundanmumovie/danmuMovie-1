package com.acfun.comment.display.base
{
	import com.acfun.External.ConstValue;
	import com.acfun.Utils.Log;
	import com.acfun.Utils.Util;
	import com.acfun.comment.entity.CommentConfig;
	import com.riaidea.text.RichTextField;
	
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Graphics;
	import flash.display.PixelSnapping;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.filters.DropShadowFilter;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.engine.ElementFormat;
	import flash.text.engine.FontDescription;
	import flash.text.engine.FontPosture;
	import flash.text.engine.FontWeight;
	import flash.text.engine.TextBlock;
	import flash.text.engine.TextElement;
	import flash.text.engine.TextLine;
	
	public class SimpleCommentEngine extends Sprite
	{
		private static var textBlock:TextBlock;
		private var _width:Number = 0;
		private var _height:Number = 0;
		public var _debText:TextField;
		//public var _rtf:RichTextField;
		//private var myArray:Array = [new Lianmeng(),new Buluo(),new Gif1()]
		
		public function SimpleCommentEngine(_font:String,_size:Number,_color:int,_bold:Boolean,broder:int,str:String,filter:Array,useBitmap:Boolean=false,sx:Number=1,sy:Number=1)
		{
			super();
			this.mouseEnabled = false;
			this.mouseChildren = false;
			if(str == null||str.length<=0){return;}
			
			if (_font == null) _font = CommentConfig.instance.font;
			
			_size = _size / CommentConfig.instance.cmtfontResize;
			if(ConstValue.STAGE.displayState != "normal")
			{
				_size = ConstValue.MAX_SIZE;
			}
			
			//CommentConfig.instance.useTextFeild = true
			if(CommentConfig.instance.useTextFeild)
			{
				//trace("---textA")
				//图文混排，Z坐标造成表情位置跑偏
				//trace("_font:"+_font+";_size:"+_size+";_color:"+_color+";_bold:"+_bold)
				/*var _rtf = new RichTextField();
				//设置rtf的类型
				_rtf.type = RichTextField.DYNAMIC;
				//设置rtf的默认文本格式
				_rtf.defaultTextFormat = new TextFormat(_font,_size,_color,_bold);
				
				var smileBox:Sprite = myArray[2]
				smileBox.scaleX = smileBox.scaleY =.3
				
				_rtf.append(str, [ { index:1, src:smileBox }])
				
				if(broder > -1)
				{
					_rtf._textRenderer.borderColor = broder;
					_rtf._textRenderer.border = true;
				}
				_width = _rtf._textRenderer.textWidth;
				_height = _rtf._textRenderer.textHeight;
				_rtf._textRenderer.filters = filter;
				
				_rtf.setSize(_rtf._textRenderer.textWidth+10, _rtf._textRenderer.textHeight);
				this.addChild(_rtf);
				return*/
				//////////////////////////////////////////old
			
				_debText = new TextField();
				_debText.selectable = false;
				_debText.mouseEnabled = false;
				_debText.type = TextFieldType.DYNAMIC;
				_debText.autoSize = TextFieldAutoSize.LEFT;
				var debTextFormat:TextFormat = new TextFormat(_font,_size,_color,_bold);
				_debText.defaultTextFormat = debTextFormat;
				_debText.text = str;
				if(broder > -1)
				{
					_debText.borderColor = broder;
					_debText.border = true;
				}
				_width = _debText.width;
				_height = _debText.height;
				_debText.filters = filter;
				this.addChild(_debText);
				
				//转化为位图，或许可以提升性能
				/*var bmpData_:BitmapData = new BitmapData(width,height,true,0);
				bmpData_.draw(this);
				var bmp_:Bitmap =new Bitmap(bmpData_,PixelSnapping.NEVER,true);
				//bmp_.scaleY = 3;//拉伸图像
				this.addChild(bmp_)
				this.removeChild(_debText);
				this.filters = null;				 
				this.addEventListener(Event.REMOVED_FROM_STAGE,function():void{
					
					bmpData_.dispose();//释放BitmapData内存
					removeEventListener(Event.REMOVED_FROM_STAGE,arguments.callee);
					//trace("listeren BitmapData remove")
				});*/
			}
			else
			{
				//trace("---textB")
				var fontDescription:FontDescription = new FontDescription(_font,(_bold ? FontWeight.BOLD : FontWeight.NORMAL), FontPosture.NORMAL);
				var format:ElementFormat = new ElementFormat(fontDescription);
				format.fontSize = _size;
				format.color = _color;
				var lines:Array = str.split("\r");
				var heightCount:Number = 2;
				var textLine:TextLine;
				var needAdd:Boolean = true;
				var container:Sprite = new Sprite();
				container.mouseEnabled = container.mouseChildren = false;
				while(lines.length > 0)
				{
					var singleLine:String = lines.shift();
					textBlock = new TextBlock();
					textBlock.content =  new TextElement(singleLine, format);
					textLine = textBlock.createTextLine();
					needAdd = true;
					if(!textLine)
					{
						needAdd = false;
						if(!singleLine)
						{
							singleLine = 'a';
							textBlock.content =  new TextElement(singleLine, format);
							textLine = textBlock.createTextLine();
						}
					}
					textLine.x = 2;
					var _tl:Number = 0;
					if(singleLine.indexOf(' ') > -1 || singleLine.indexOf('　') > -1)
					{
						var wtl:String = singleLine.replace(/( )/g, "a");
						wtl = wtl.replace(/(　)/g, "哈");
						textBlock.content =  new TextElement(wtl, format);
						_tl = textBlock.createTextLine().width;
					}
					else _tl = textLine.width;
					if(_width < _tl)_width = _tl;
					heightCount += (textLine.height);					
					textLine.y = heightCount - textLine.descent;
					if(needAdd) container.addChild(textLine);
				}
				_height = heightCount;				
				if(broder > -1)
				{
					var g:Graphics = this.graphics;
					var w:Number = this.width;
					var h:Number = this.height;
					g.moveTo(0,0);
					g.lineStyle(1,broder);
					g.lineTo(w,0);
					g.lineTo(w,h);
					g.lineTo(0,h);
					g.lineTo(0,0);
				}
				
				if (container.width == 0 || container.height == 0)
					return;
				
				container.filters = filter;
				

				if (useBitmap)
				{
					//转化为位图，或许可以提升性能
					try
					{
						var bmpData:BitmapData = new BitmapData(width,height,true,0);
						bmpData.draw(container);
						var bmp:Bitmap = new Bitmap(bmpData,PixelSnapping.AUTO,false);
						//bmp.scaleX = bmp.scaleY = .8
						addChild(bmp);						
						container = null;
					}
					catch (e:Error)
					{
						Log.error(toString()," convert to bitmap error:",str,"\n",e.getStackTrace());
						addChild(container);
					}
					
				}
				else
				{
					addChild(container);
				}
			}
		}
		public override function get width():Number
		{
			return _width+4 ;
		}
		
		public override function get height():Number
		{
			return _height+2 ;
		}
	}
}