package com.acfun.comment.display
{
	import com.acfun.External.ConstValue;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.signal.notify;
	import com.gif.Gif;
	import com.gif.events.GIFPlayerEvent;
	import com.greensock.TweenLite;
	import com.greensock.easing.Linear;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	public class RGifComment extends RScrollComment
	{
		public static var LOCAL_GIF:Boolean = true;
		private var gifsArray:Array ;
		//private var gif:Gif;
		private var gif;
		public function RGifComment(data:SingleCommentData)
		{
			//trace("__LOCAL_GIF:"+LOCAL_GIF)
			if(LOCAL_GIF)//使用内置表情包
			{
				gifsArray = [new Gif1(),new Gif2(),new Gif3(),new Gif4(),new Gif5(),new Gif6(),new Gif7(),new Gif8()];
				var specialGifArray:Array = [new Lianmeng(),new Buluo()]
				if(ConstValue.PLAY_SCREEN)//游戏屏
				{
					//trace(data.text)
					if(data.text =="lianmeng")
					{
						
						gif = specialGifArray[0]
					}
					else if(data.text =="buluo")
					{
						gif = specialGifArray[1]
					}
					else
					{
						gif = new Sprite();
					}
					this.addChild(gif);
				}
				else//普通屏
				{
					if(data.text.indexOf(".") >=0)
					{
						//trace(data.text.slice(0,data.text.indexOf(".")))
						if(data.text.slice(0,data.text.indexOf(".")))
						{
							try{
								var arrayGifNum:uint = new uint(data.text.slice(0,data.text.indexOf(".")));
								if(arrayGifNum >=1)
								{
									var currentGifId:uint = arrayGifNum -1;
									gif = gifsArray[currentGifId]
								}
								//////////////////
								this.addChild(gif);
								
								//trace("doAddGif:"+currentGifId)
								//////////////////
							}
							catch(e:Error)
							{
								
							}
						}
						else
						{
							gif = new Sprite();
						}
					}
					else
					{
						gif = new Sprite();
					}
				}
				
			}
			else//使用外置表情包
			{
				///////////////////////
				gif = new Gif(true);
				gif.load(new URLRequest("http://dm.aixifan.com/expression/"+data.text));
				//gif.load(new URLRequest("gif/"+data.text));
				/*gif.addEventListener(GIFPlayerEvent.COMPLETE,function():void
				{
					
				});*/
				
				this.addChild(gif);
				
			
			}
			super(data);
			
			if(LOCAL_GIF)
			{
				if(ConstValue.PLAY_SCREEN)//游戏屏
				{
					for(var i:int = 0; i<this.numChildren;i++){
						var o:DisplayObject = this.getChildAt(i);
						if(o is Lianmeng || o is Buluo){
							continue;
						}else{
							o.visible = false;
							this.removeChild(o);
						}
					}
				}
				else
				{
					for(i = 0; i<this.numChildren;i++){
						o = this.getChildAt(i);
						if(o is Gif1 || o is Gif2 || o is Gif3 || o is Gif4 || o is Gif5 || o is Gif6 || o is Gif7 || o is Gif8){
							continue;
						}else{
							o.visible = false;
							this.removeChild(o);
						}
					}
				}
				//////////////////
				
			}
			else
			{
				for(i = 0; i<this.numChildren;i++){
					o = this.getChildAt(i);
					if(o is Gif){
						continue;
					}else{
						o.visible = false;
						this.removeChild(o);
					}
				}
			}
			//////////////////////////
			
		}
		
		/**
		 * 开始播放
		 * 从当前位置(已经在滚动空间管理类中设置)滚动到-this.width
		 */
		override public function start(from:Number=0):void
		{
			if(gif)
			{
				//this.x = -width;
				var startX:Number = ConstValue.RIGHT==ConstValue.DIRECT?(ConstValue.STAGE.stageWidth+30):(-width+10);
				var toX:int = ConstValue.RIGHT==ConstValue.DIRECT?(-width-10):(ConstValue.STAGE.stageWidth+30);
				//var len:Number = this.x;
				this.x = startX;
				gif.scaleX = gif.scaleY = ConstValue.EMTION_SCALE;
				_tw = new TweenLite(this,duration,{x:toX,onComplete:completeHandler,ease:Linear.easeNone});
				_tw.resume();
				setTimeout(sendComment,sendDuration * 1000);
			}
		}
		
		public override function  sendComment():void{
			notify(SIGNALCONST.SEND_GIF,item);
		}
		
		public override function get height():Number{
			return 150;
		}
	}
}