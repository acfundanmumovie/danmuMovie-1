// ========================================================================
// Copyright 2011 Acfun
// ------------------------------------------------------------------------
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at 
// http://www.apache.org/licenses/LICENSE-2.0
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//========================================================================

package com.acfun.comment.display 
{
    import com.acfun.External.ConstValue;
    import com.acfun.comment.display.base.SimpleCommentEngine;
    import com.acfun.comment.entity.CommentConfig;
    import com.acfun.comment.entity.SingleCommentData;
    import com.acfun.comment.interfaces.IComment;
    import com.greensock.TimelineLite;
    import com.greensock.TweenLite;
    import com.greensock.easing.*;
    import com.greensock.plugins.TintPlugin;
    import com.greensock.plugins.TweenPlugin;
    import com.worlize.gif.GIFPlayer;
    
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.display.BlendMode;
    import flash.display.DisplayObject;
    import flash.display.Loader;
    import flash.events.Event;
    import flash.filters.*;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.ByteArray;
    
    import mx.utils.Base64Decoder;


    /**
     * 核心固定字幕
     */
    public class FixedPosComment extends SimpleCommentEngine implements IComment
    {
		/** 持续时间 **/
		public var duration:Number;
        /**
         * 完成地调用的函数,无参数
         */
        protected var _complete:Function;
        /** 配置数据 **/
        private var _item:SingleCommentData;
        /** 空间分配索引,记录所占用的弹幕空间层 **/
        protected var _index:int;
		protected var fileterOff:Boolean = true;
//		protected var debug:Boolean = false;
        protected var config:CommentConfig = CommentConfig.instance;
        //private var _user:String;
        private var _color:int;
        public static var _width:Number;
        public static var _height:Number;
		public static var unlocksize:Boolean;
		public static var xbase:Number;
		public static var ybase:Number;		
        private var _timeLine:TimelineLite = new TimelineLite({onComplete:completeHandler});
        private static var isInited:Boolean = false;
        private static var BMS:Vector.<String> = new <String>[BlendMode.NORMAL,BlendMode.MULTIPLY,BlendMode.SCREEN,BlendMode.LIGHTEN,BlendMode.DARKEN,BlendMode.DIFFERENCE,BlendMode.ADD,BlendMode.SUBTRACT,BlendMode.INVERT,BlendMode.OVERLAY,BlendMode.HARDLIGHT,BlendMode.LAYER,BlendMode.ALPHA,BlendMode.ERASE];
		private static var centerPP:PerspectiveProjection;
		
		/**
		 * 深度 
		 */		
		public var depth:int=0;
		
        /**
         * 构造方法
         * @param	data 弹幕数据信息
		 * @param	containerWidth	 参考宽度（新版缩放类型高级弹幕为固定值）
		 * @param	containerHeight	 参考高度（新版缩放类型高级弹幕为固定值）
         */        
        public function FixedPosComment(data:SingleCommentData,containerWidth:Number=0,containerHeight:Number=0) 
        {
			_item = data;
			
			var width:Number = containerWidth || _width;
			var height:Number = containerHeight || _height;			
			var addinf:Object = data.addon;
			var i:int;
			if (addinf.dep!=null) depth = addinf.dep;			
			var fsty:Object = addinf.w;
//			fsty = {f:config.font,b:config.bold,l:{t:1,c:0xCC0000,a:1,x:9,y:9,s:2,b:true,k:false}}
//			fsty = {g:{w:10,h:10,d:'NYzbK0MBHMc9+R88aB5cUrbyJpcX1ExnLqGmXDfD2+aBkge5x9ommzENjbl00Ij2wGjhuCzOw8a0NjNpS6L1M6X28nVefOtb3099+2yLxV6qqvKRRhOkvr5nUqmCVF/vJ4UiIHAoIWyjRHKbksl8uLj4hdebhMfzhmg0gf9w3Cfu75MphvGTVhvC5eUX0tNPkZZmhdXqQyTyAYbZFHgbbndC8IapuzsMuz2OpqYrwRlHLPYj/JJYW+Mhlx/CYgmQWh2iLjWP2Vk/5uYiYFkWZWVKVFZacHsTgdl2DG3/LimVj9TYcQKjnoekQAf/Qxiv0Q+h34i+vIOpGcL4lIsa28+phrELm4e4sA0rth3c8XGw+9dw7nHIEjVgeIKjWvk6FZfqYF4NYuvoDbn5vejtMSFD1Imx0QOoVHroZg5I0WxLZedNYmTiG2cewibLweEIYH45CMfGE1wuH5zO11RJicEkEg1STvY0VZTrqbVliWSyeaquXSCp1Ex1dYtUVGQwZWYO/AE='}}
			if (fsty == null) 
			{	
				// fontStyle
				fsty = {};
			}
			else
			{
				var filer:Array;
				if((fsty.l as Array) !=null)
				{
					var fi:Array = fsty.l;					
					var tmp:Object;
					filer = [];
					for(var k:uint=0;k<fi.length;k++)
					{
						tmp = fi[k];
						if (tmp is Array)
						{
							filer.push(getFilter(tmp as Array));
						}
						else
						{
							filer.push(getFilter(fi));
							break;
						}	
					}
					fileterOff = false;
				}
				
				var gr:DisplayObject = null;
				
				if(fsty.g != null && fsty.g.d != null)
				{
					if (fsty.g.w == null)
					{
						//新版图片弹幕，支持gif动画
						gr = getNewData(fsty.g.d);
					}
					else
					{
						//兼容旧版
						gr = getData(fsty.g.w,fsty.g.h,fsty.g.d);	
					}
					if(addinf.b){gr.scaleX = gr.scaleY = (config.sizee * data.size)/Math.max(fsty.g.w,fsty.g.h)}
					if (gr)
					{
						gr.filters = filer;	//图片弹幕滤镜
						addChild(gr);
					}
				}
				
//				if(fsty.f==null){fsty.f=config.font;}
//				if(fsty.b==null){fsty.b=config.bold;}
			}

//			if(addinf.bh!=null&&addinf.bh==true){debug=true;}
			
			/** 字幕形式，是普通字幕还是绘图指令 **/
			var isb:Boolean = (addinf.b == null) ? true:addinf.b;
			if(isb && fileterOff)
			{
				if(data.color == 0)
					filer = [new GlowFilter(16777215, 1, 2,2,1.5,1)];
				else 
					filer = config.filter;
			}
			
			var sx:Number = addinf.e||1;
			var sy:Number = addinf.f||1;
			var maxl:Number = addinf.l;
			if(addinf.z!= null)
			{
				var lastSx:Number = sx;
				var lastSy:Number = sy;
				for(i = 0;i<addinf.z.length;i++)
				{                    
					zinf = addinf.z[i];
					
					var update:Boolean = false;
					
					if (zinf.f != null)
					{
						lastSx = zinf.f;						
					}
					else
					{
						if (zinf.l > maxl)
						{					
							sx = lastSx;
							update = true;
						}
					}
					
					if (zinf.g != null)
					{
						lastSy = zinf.g;
					}
					else
					{
						if (zinf.l > maxl)
						{					
							sy = lastSy;
							update = true;
						}
					}
					
					if (update)
						maxl = zinf.l;
				}
				
				if (maxl == 0)
				{
					sx = lastSx;
					sy = lastSy;
				}
			}
			/** 解析出来初始字体，大小，颜色，是否粗体，边界颜色，文字信息 **/
			super(fsty.f!=null?fsty.f:config.font, config.sizee * data.size, data.color, fsty.b!=null?fsty.b:config.bold,-1,addinf.n,filer,false,sx,sy);
//			super(fsty.f, config.sizee * data.size, data.color, fsty.b,-1,addinf.n,unlocksize);
			
            /** 字幕形式，是普通字幕还是绘图指令 **/
            var commentType:uint = (addinf.t != null ) ? addinf.t : 0;
            /** 初始位置 **/
            if(addinf.p != null)
            {
                this.x = int(addinf.p.x * width / 1000 + xbase);
                this.y = int(addinf.p.y * height / 1000 + ybase);
            }
			if(addinf.pz != null)
			{
				this.z = addinf.pz;
			}
            //var stap:CommentPos = (commentObject.p != null) ? new CommentPos(commentObject.p.x,commentObject.p.y) : new CommentPos(0,0);
            //_user = data.user;
            /** 初始透明度 **/
            var startalpha:Number = (addinf.a == null) ? 1:addinf.a;

			/** 转角 **/
//			if(addinf.pz != null){local3d = true;}
			
            if(addinf.rx != null)
			{
				this.rotationX = addinf.rx;			
			}
            if(addinf.k != null)
			{
				this.rotationY = addinf.k;				
			}
			if(addinf.r != null)
			{
				this.rotationZ = addinf.r;
			}
			
			//设置3d中心为视频正中间
			if (centerPP == null)
			{
				var pp:PerspectiveProjection = new PerspectiveProjection();
				pp.projectionCenter = new Point(ConstValue.SPECIAL_MODE_PLAYER_WIDTH/2,(ConstValue.SPECIAL_MODE_PLAYER_HEIGHT-ConstValue.PLAYER_SKIN_DEFAULT_HEIGHT)/2);
				centerPP = pp;
			}
			this.transform.perspectiveProjection = centerPP;

            /** XY缩放 **/
            if(addinf.e != null)this.scaleX = addinf.e;
            if(addinf.f != null)this.scaleY = addinf.f;
			if(addinf.sz != null)this.scaleZ = addinf.sz;

			if(addinf.bm != null)
			{
				var bm:int = int(addinf.bm);
				if(0<bm && bm<BMS.length){this.blendMode = BMS[bm];}
			}		
			
            /** 生存周期 **/
            var life:Number = (addinf.l != null) ? addinf.l : 3;

			/** 锚点 **/
			var cor:int = int(addinf.c);
            if(cor > 0)transObj(this,cor,addinf.w==null||addinf.w.g==null);
			
            /** 初始化 **/
            this.alpha = startalpha ;//* config.alpha;
            
            /** 初始化计算,Sleep无变化参数 */
            _timeLine.append(new TweenLite(this,life,{}));
			var zinf:Object;
            if(addinf.z!= null)
            {
                for(i=0;i<addinf.z.length;i++)
                {                    
                    var moveObj:Object = new Object();
                    var mt:Number = 3;
					zinf = addinf.z[i];
                    if(zinf.x != null)moveObj.x = zinf.x * width / 1000 + xbase;
                    if(zinf.y != null)moveObj.y = zinf.y * height / 1000 + ybase;
					if(zinf.z != null)moveObj.z = zinf.z;
                    if(zinf.c != null)
                    {
                        if(!isInited)
                        {
                            isInited = true;
                            TweenPlugin.activate([TintPlugin]);
                        }
                        moveObj.tint = zinf.c;
                    }
                    if(zinf.rx != null)
					{moveObj.rotationX = zinf.rx;}
                    if(zinf.e != null)
					{moveObj.rotationY = zinf.e;}
					if(zinf.d != null)
					{
						moveObj.rotationZ = zinf.d;
					}
					
                    if(zinf.f != null)moveObj.scaleX = zinf.f;
                    if(zinf.g != null)moveObj.scaleY = zinf.g;
					if(zinf.sz != null)moveObj.scaleZ = zinf.sz;
					
                    if(zinf.t != null){
						moveObj.autoAlpha = zinf.t;
					}
                    
                    if(zinf.l != null)mt = zinf.l;
                    else mt = 3;
                    moveObj.ease = Linear.easeNone;
                    if(zinf.v != null)
                    {
                        /** GLOP EARSE FUNCTIONS**/
                        var s:int = zinf.v;
                        switch(s)
                        {
                            case 0:
                                break;
                            case 1:
                                moveObj.ease = null;
                                break;
                            case 2:
                                moveObj.ease = Back.easeOut;
                                break;
                            case 3:
                                moveObj.ease = Back.easeIn;
                                break;
                            case 4:
                                moveObj.ease = Back.easeInOut;
                                break;
                            case 5:
                                moveObj.ease = Bounce.easeOut;
                                break;
                            case 6:
                                moveObj.ease = Bounce.easeIn;
                                break;
                            case 7:
                                moveObj.ease = Bounce.easeInOut;
                                break;
                            default:
                                break;
                        }
                    }
                    if(mt == 0)mt = 0.000000001;
                    _timeLine.append(new TweenLite(this,mt,moveObj));
                }
            }
			
			if(addinf.bh!=null&&addinf.bh==true)
			{
				this.graphics.beginFill(16711680);
				this.graphics.drawCircle(0,0,2);
				this.graphics.endFill();
			}
			
			this.duration = this._timeLine.duration();
			
			this.cacheAsBitmap = false;
        }
		
		/**
         * 设置空间索引和y坐标
         **/
        /** 
         * 空间索引读取,在移除出空间时被空间管理者使用
         **/
        public static function setRect(w:Number,h:Number):void
        {
            _width =w;
            _height = h;
        }
        public function get index():int{return this._index;}
        public function get stime():Number{return this._item.stime;}
		
        /**
         * 初始化,由构造函数最后调用
         */
//        protected function init():void
//        {
//            //this.alpha = config.alpha;
//            //this.filters = config.filter;
//            
//            //if(item.color == 0)
//            //{
//            //    this.filters = [new GlowFilter(16777215, 1, 2,2,1.5,1)];
//            //}
//			/**↓弹幕里的矢量图形不多吧,有必要么?**/
//            this.cacheAsBitmap = config.spcacheAsBitmap;
//			if(debug)
//			{
//				this.graphics.beginFill(16711680);
//				this.graphics.drawCircle(0,0,2);
//				this.graphics.endFill();
//			}
//        }
		public function get item():SingleCommentData{return _item;}
        /**
         * 恢复播放
         */
        public function resume():void
		{
			this._timeLine.resume();
			
			if (numChildren > 0)
			{
				var obj:DisplayObject = getChildAt(0);
				if (obj is GIFPlayer)
				{
					(obj as GIFPlayer).play();
				}	
			}
		}
        /**
         * 暂停
         */
        public function pause():void
		{
			this._timeLine.pause();
			
			if (numChildren > 0)
			{
				var obj:DisplayObject = getChildAt(0);
				if (obj is GIFPlayer)
				{
					(obj as GIFPlayer).stop();
				}	
			}
		}
        /**
         * 开始播放
         */
        public function start(from:Number=0):void
		{
			this._timeLine.play(from);
		}
        /**
         * 时计结束事件监听
         */
        public function completeHandler():void
        {
			if (_complete != null)
            	_complete();
        }
        /**
         * 设置完成播放时调用的函数,调用一次仅一次
         * @param	foo 完成时调用的函数,无参数
         */
        public function set complete(foo:Function):void{this._complete = foo;}
        public function get innerText():String{return _item.text;}
        public function get user():String{return _item.user;}
		
		public function doComplete():void{completeHandler();}
		
        private function transObj(obj:SimpleCommentEngine,dock:int,textfix:Boolean):void
        {
			var numC:int = obj.numChildren;
            var w:Number = obj.width;
            var h:Number = obj.height;
			if(!textfix)
			{	
				var pic:DisplayObject = obj.getChildAt(0);
				if (pic is Loader)
				{
					if (pic["content"] == null)
					{
						pic["contentLoaderInfo"].addEventListener(Event.COMPLETE,function():void{
							pic["contentLoaderInfo"].removeEventListener(Event.COMPLETE,arguments.callee);
							transObj(obj,dock,textfix);
						});
						return;
					}
					else
					{
						w = pic["content"].width;
						h = pic["content"].height;
					}
				}
				w = obj.getChildAt(0).width;
				h = obj.getChildAt(0).height;
			}
			
            if(numC > 0)
            {
                for(var i:int = 0; i < numC; i++)
                {
                    var s:DisplayObject = obj.getChildAt(i);
                    switch(dock)
                    {
                        case 0:
                            //this.x = this.y = 0;
                            return;
                        case 1:
                            s.x -= w / 2;
                            //this.y = 0;
                            break;
                        case 2:
                            s.x -= w;
                            break;
                        case 3:
                            s.y -= h / 2;
                            break;
                        case 4:
                            s.x -= w / 2;
                            s.y -= h / 2;
                            break;
                        case 5:
                            s.x -= w;
                            s.y -= h / 2;
                            break;
                        case 6:
                            s.y -= h;
                            break;
                        case 7:
                            s.x -= w / 2;
                            s.y -= h;
                            break;
                        case 8:
                            s.x -= w;
                            s.y -= h;
                            break;
                        default:
                            //this.x = this.y = 0;
							break;                            
                    }
                }
            }
        }
		
		private function getData(w:int,h:int,sdata:String):DisplayObject
		{
			var base64Text:String = sdata;
			var dec:Base64Decoder = new Base64Decoder;
			dec.decode(base64Text);
			var bytesRet:ByteArray = dec.toByteArray();
			bytesRet.inflate();
			var retBD:BitmapData = new BitmapData(w, h, true, 0);
			retBD.setPixels(new Rectangle(0, 0, w, h), bytesRet);			
			return new Bitmap(retBD,"auto",true);
		}
		
		private function getNewData(sdata:String):DisplayObject
		{
			//解出原始数据
			var dec:Base64Decoder = new Base64Decoder;
			dec.decode(sdata);
			var bytes:ByteArray = dec.toByteArray();			
			//判断是否gif
			if (bytes.readUTFBytes(3) == "GIF")
			{
				bytes.position = 0;
				var gif:GIFPlayer = new GIFPlayer();
				gif.smoothing = true;
				gif.loadBytes(bytes);
				return gif;
			}
			else
			{
				bytes.position = 0;
				var loader:Loader = new Loader();				
				loader.loadBytes(bytes);
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE,function():void{
					(loader.content as Bitmap).smoothing = true;
				},false,0,true);
				return loader;
			}
		}	
		
		private function getFilter(tmp:Array):BitmapFilter
		{
			var filter:BitmapFilter;
			switch(tmp[0])
			{
				case 0:
					filter = new BlurFilter			(tmp[1],tmp[2],tmp[3]);
					break;
				case 1:
					filter = new GlowFilter			(tmp[1],tmp[2],tmp[3],tmp[4],tmp[5],tmp[6],tmp[7],tmp[8]);
					break;
				case 2:
					filter = new DropShadowFilter		(tmp[1],tmp[2],tmp[3],tmp[4],tmp[5],tmp[6],tmp[7],tmp[8],tmp[9],tmp[10],tmp[11]);
					break;
				case 3:
					filter = new BevelFilter			(tmp[1],tmp[2],tmp[3],tmp[4],tmp[5],tmp[6],tmp[7],tmp[8],tmp[9],tmp[10],tmp[11],tmp[12]);
					break;
				case 4:
					filter = new GradientGlowFilter	(tmp[1],tmp[2],tmp[3],tmp[4],tmp[5],tmp[6],tmp[7],tmp[8],tmp[9],tmp[10],tmp[11]);
					break;
				case 5:
					filter = new GradientBevelFilter	(tmp[1],tmp[2],tmp[3],tmp[4],tmp[5],tmp[6],tmp[7],tmp[8],tmp[9],tmp[10],tmp[11]);
					break;
				default:
					break;
			}
			return filter;
		}
    }	
}