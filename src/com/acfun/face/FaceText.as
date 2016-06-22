package com.acfun.face
{
	import com.acfun.External.SIGNALCONST;
	import com.acfun.signal.notify;
	
	import fl.controls.ScrollBar;
	import fl.events.ScrollEvent;
	
	import flash.display.Sprite;
	import flash.display3D.IndexBuffer3D;
	import flash.events.MouseEvent;
	import flash.utils.clearTimeout;
	import flash.utils.setTimeout;
	
	public class FaceText extends Sprite
	{
		private var faceBg:FaceTextBg;
		private var sprite:Sprite = new Sprite();
		public static var FACE_WIDTH:int = 92;
		public function FaceText()
		{
			super();
			
//			this.graphics.beginFill(0xFF0000,1);
//			this.graphics.drawRect(0,0,300,175);
//			this.graphics.endFill();
			
			this.addEventListener(MouseEvent.CLICK,stop);
			
			faceBg = new FaceTextBg();
			faceBg.x = 0;
			faceBg.y = 0;
			this.addChild(faceBg);
			
			sprite.x = 10;
			sprite.y = 7;
			
			var faceLine:FaceLine = new FaceLine();
			faceLine.x = FACE_WIDTH + sprite.x +2;
			faceLine.y = 7;
			faceLine.height = 160;
			this.addChild(faceLine);
			
			var faceLine1:FaceLine = new FaceLine();
			faceLine1.x = FACE_WIDTH *2 + sprite.x +2;
			faceLine1.y = 7;
			faceLine1.height = 160;
			this.addChild(faceLine1);
			
			
			var mask:Sprite = new Sprite();
			mask.graphics.beginFill(0xFF0000,1);
			mask.graphics.drawRect(0,6,FACE_WIDTH * 3,160);
			mask.graphics.endFill();
			sprite.mask = mask;
			
			this.addChild(mask);
			
			this.addChild(sprite);
			sprite.addEventListener(MouseEvent.CLICK,click);
			sprite.graphics.beginFill(0xFFFFFF,0);
			sprite.graphics.drawRect(0,0,FACE_WIDTH * 3,680);
			sprite.graphics.endFill();
			
			
			var array:Array = ["|∀ﾟ","(´ﾟДﾟ`)","(;´Д`)","(=ﾟωﾟ)=","| ω・´)","|∀` )","(つд⊂)","(ﾟДﾟ≡ﾟДﾟ)?!","(|||ﾟДﾟ)","( ﾟ∀ﾟ)"
				,"(*´∀`)","(*ﾟ∇ﾟ)","(　ﾟ 3ﾟ)","( ´_ゝ`)","(・∀・)","(ゝ∀･)","(〃∀〃)","(*ﾟ∀ﾟ*)","( ﾟ∀。)","σ`∀´)"," ﾟ∀ﾟ)σ","(＞д＜)",
				"(|||ﾟдﾟ)","( ;ﾟдﾟ)","(>д<)","･ﾟ( ﾉд`ﾟ)","( TдT)","(￣∇￣)","(￣3￣)","(￣ . ￣)","(￣艸￣)","(*´ω`*)","(´・ω・`)","(oﾟωﾟo)",
				"(ノﾟ∀ﾟ)ノ","|дﾟ )","┃電柱┃","⊂彡☆))д`)","(´∀((☆ミつ","_(:з」∠)_","(●′ω`●) ","(｡・`ω´･)","(￢ω￢)","(」・ω・)」",
				"Σ( ￣□￣||)","Σ( ° △ °|||)","(*/ω＼*)","(｡ゝω･｡)ゞ","(ノ＝Д＝)ノ┻━┻","┯━┯ノ('－'ノ)","（<ゝω·）~☆ "];
			
			for(var i:int = 0; i< array.length; i++){
				var row:int = i/3;
				var col:int = i%3;
				var text:TextItemRender = new TextItemRender(array[i]);
				text.y = row * 40;
				text.x = col * FACE_WIDTH;
				sprite.addChild(text);
				
				if(i % 3 == 0 && row != 0){
					var faceLine2:FaceLineHor = new FaceLineHor();
					faceLine2.width = 275;
					faceLine2.x = -2;
					faceLine2.y = row * 40;
					faceLine2.mouseEnabled = false;
					sprite.addChild(faceLine2);
				}
			}
			
			
			
			
			var bar:FaceScrollBar = new FaceScrollBar();
			
//			var aa:Sprite = new Sprite();
//			aa.graphics.beginFill(0xFF00FF,1);
//			aa.graphics.drawRect(0,0,20,20);
//			aa.graphics.endFill();
//			bar.setStyle("upArrowUpSkin",aa);
			
			bar.setSize(10,160);
			bar.setScrollProperties(10,0,sprite.height - 160);
//			bar.pageSize = 100;
			bar.pageScrollSize = 0;
			bar.lineScrollSize = 0;
			bar.x = 277;
			bar.y = 7;
			bar.addEventListener(ScrollEvent.SCROLL,scroll);
			this.addChild(bar);
			
			
			
			this.addEventListener(MouseEvent.ROLL_OUT,rollOut);
			this.addEventListener(MouseEvent.ROLL_OVER,rollOver);
		}
		
		private function stop(e:MouseEvent):void{
			e.stopPropagation();
		}
		
		private function rollOver(e:MouseEvent):void{
			this.visible = true;
			clearTimeout(timeId);
		}
		private var timeId:uint = 0;
		private function rollOut(e:MouseEvent):void{
			timeId = setTimeout(hide,500);
		}
	
		private function hide():void{
			this.visible = false;
		}
		
		private function scroll(e:ScrollEvent):void{
			sprite.y = -e.position + 7;
		}
		private function click(e:MouseEvent):void{
			e.stopPropagation();
			if(e.target is TextItemRender){
//				trace((e.target as TextItemRender).text.text);
				notify(SIGNALCONST.SET_FACE_TEXT,(e.target as TextItemRender).text.text);
			}
			this.visible = false;
		}
	}
}