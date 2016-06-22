package com.acfun.PlayerSkin.Pad
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.SIGNALCONST;
	import com.acfun.PlayerSkin.SkinConfig;
	import com.acfun.Utils.Log;
	import com.acfun.signal.notify;
	import com.acfun.signal.register;
	import com.greensock.TweenMax;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.utils.setTimeout;

	public class RightPad extends Sprite
	{
		public static const FOLD_SPEED:Number = 0.77;
		public static const FALD_SPEED:Number = 0.48;
		
//		private var shap:SharePad;
		private var cfgp:ConfigPad;
		private var cmtp:CommentPad;
		private var unfold_btn:Minimize;
		private var fold_btn:Minimize;
		private var animate:TweenMax;
//		private var adArea:AdArea;
		
		private var is_cfgp_folded:Boolean = false;
		private var is_shap_folded:Boolean = true;
		private var is_folded:Boolean = true;
		private var is_show:Boolean = false;
		private var lastFlag:Number;
		private var animateLock:Boolean = false;
		
		public function RightPad()
		{
			super();
			init();
		}
		private function init():void {
//			shap = new SharePad();	// 分享PAD
			cfgp = new ConfigPad();	// 设置PAD
			cmtp = new CommentPad();// 弹幕PAD
//			adArea = new AdArea();	//广告位
			
			/** 初始化右边栏的Minimize, 因为是一个可伸缩的MovieClip, 所以要AS3构建  **/
			var w00:word_ = new word_;
			var w01:word = new word;
			var b00:back_ = new back_;
			var b01:back = new back;
			var w10:word0 = new word0;
			var w11:word1 = new word1;
			var b10:back0 = new back0;
			var b11:back0 = new back0;
			unfold_btn = new Minimize([w00,w01],[b00,b01]);
			unfold_btn.x = -SkinConfig.RIGHT_LINE_WIDTH;
			fold_btn = new Minimize([w10,w11],[b10, b11]);
			fold_btn.x = -SkinConfig.RIGHT_LINE_WIDTH;
			fold_btn.visible = false;
			this.visible = false;
			
			/** 你以为我想这么写啊 **/
			
			cfgp.title.buttonMode = true;
//			shap.title.buttonMode = true;
			cmtp.title.text.text = "弹幕列表";
			cfgp.title.text.text = "设置";
			//shap.title.text.text = "分享";
			
			cfgp.title.addEventListener(MouseEvent.CLICK, onCfgTitleClick);
//			shap.title.addEventListener(MouseEvent.CLICK, onShaTitleClick);
			unfold_btn.addEventListener(MouseEvent.CLICK, onUnfoldClick);
			fold_btn.addEventListener(MouseEvent.CLICK, onFoldClick);
			
			addChild(cmtp);
			addChild(cfgp);
			//addChild(shap);
			addChild(unfold_btn);
			addChild(fold_btn);
//			addChild(adArea);
			
			register(SIGNALCONST.SET_SIZE_CHANGE, resize);	// 注册resize方法
			register(SIGNALCONST.PAD_EXPAND_BUTTON_SHOW, setPadVisiable);
		}
		
		public function setPadVisiable(flag:Number = 1):void {
			if(lastFlag!=flag) {
				switch(flag) {
					case 0: // 普通显示						
//						this.visible = true;						
						animate = TweenMax.to(this, FALD_SPEED, {autoAlpha:1});
						break;
					case 1: // 普通消失
						if(is_folded && !animateLock) {
//							this.visible = true;
							animate = TweenMax.to(this, FALD_SPEED, {autoAlpha:0});
						}
						break;
					case 2: // 全屏消失
						this.visible = false;
						break;
					case 3:	// 全屏显示
						if(!is_folded)
							notify(SIGNALCONST.PAD_SIZE_CHANGE, SkinConfig.RIGHT_WIDTH + SkinConfig.RIGHT_LINE_WIDTH, unfold_btn.height);
//						this.visible = true;
						break;
					default: 
						break;
				}
				lastFlag = flag;
			}
		}
		
		private function setAniState(b:Boolean):void {
			unfold_btn.onAnimate(b);
			fold_btn.onAnimate(b);
		}
		public function onUnfoldClick(e:MouseEvent,hasAnimate:Boolean=true):void {
			if(is_folded) {
//				Log.info("Unfold");
				animateLock = true;
				resize(_w,_h);
				if (animate) animate.kill();
//				this.visible = true;
				this.alpha = 1;
				setAniState(true);
				notify(SIGNALCONST.PAD_SIZE_EXPAND_START);
				unfold_btn.removeEventListener(MouseEvent.CLICK, onUnfoldClick);
				unfold_btn.visible = false;
				fold_btn.visible = true;
				if (hasAnimate)
				{
					animate = TweenMax.to(this, FOLD_SPEED, {x: (stage.stageWidth - SkinConfig.RIGHT_WIDTH),onComplete:completeHandle});	
				}
				else
				{
					this.x = (stage.stageWidth - SkinConfig.RIGHT_WIDTH);
					completeHandle();
				}
				//打开
				function completeHandle():void
				{
					notify(SIGNALCONST.PAD_SIZE_CHANGE, SkinConfig.RIGHT_WIDTH + SkinConfig.RIGHT_LINE_WIDTH, unfold_btn.height);
					notify(SIGNALCONST.SET_CONFIG,{ auto_widescreen:false });
					fold_btn.addEventListener(MouseEvent.CLICK, onFoldClick);
					setAniState(false);
					is_folded = !is_folded;
					animateLock = false;					
				}
			}
		}
		public function onFoldClick(e:MouseEvent,hasAnimate:Boolean=true):void {
			if(!is_folded) {
//				Log.info("Fold");
				animateLock = true;
				if (animate) animate.kill();
//				this.visible = true;
				this.alpha = 1;
				setAniState(true);
				fold_btn.removeEventListener(MouseEvent.CLICK, onFoldClick);
				notify(SIGNALCONST.PAD_SIZE_CHANGE, 0, unfold_btn.height);				
				if (hasAnimate)
				{
					animate = TweenMax.to(this, FOLD_SPEED-0.045, {x: (stage.stageWidth),onComplete:completeHandle});	
				}
				else
				{
					this.x = stage.stageWidth;
					completeHandle();
				}
				//关闭
				function completeHandle():void
				{
					notify(SIGNALCONST.PAD_SIZE_PACKUP_END,lastFlag);
					notify(SIGNALCONST.SET_CONFIG,{ auto_widescreen:true });
					setAniState(false);
					is_folded = !is_folded;
					unfold_btn.visible = true;
					fold_btn.visible = false;
					unfold_btn.addEventListener(MouseEvent.CLICK, onUnfoldClick);
					animateLock = false;
					setPadVisiable(1);
				}
			}
		}
		
		public function onCfgTitleClick(e:MouseEvent):void {
			if(is_cfgp_folded) {
				cfgp.unfold();
				setTimeout(function():void{
					cmtp.cmtGrid.height = cfgp.y - cmtp.cmtGrid.y;
				},500);
			} else {
				cfgp.fold();
				cmtp.cmtGrid.height = _h - 2 * cfgp.title.height;
			}
			is_cfgp_folded = !is_cfgp_folded;			
		}
//		private function onShaTitleClick(e:MouseEvent):void {
//			if(is_shap_folded) {
//				shap.unfold(cfgp);
//			} else {
//				shap.fold(cfgp);
//			}
//			is_shap_folded = !is_shap_folded;
//		}
		
		private var _w:Number;
		private var _h:Number;
		public function resize(w:Number, h:Number):void {
			if (isNaN(w) || isNaN(h)) return;
			if (h < 200) return;	//防止高度过低导致计算错误
			
//			Log.debug("right pad resize: ",w,"*",h);
			
			_w = w;
			_h = h;
			
			if(is_folded) {
				x = w;
			} else {
				x = w - cmtp.title.width;
			}						
			/*if(is_shap_folded) {
				shap.y = h - shap.title.height;
			} else {
				shap.y = h - shap.height;
			}*/
			if(is_cfgp_folded) {
				cfgp.y = h - cfgp.title.height;
			} else {
				cfgp.y = h - cfgp.title.height - cfgp.body.height;
			}
			unfold_btn.resize(w, h);
			fold_btn.resize(w, h);
			cmtp.y = 0;
//			cmtp.cmtGrid.height = h - 2 * cfgp.title.height;
			cmtp.cmtGrid.height = cfgp.y - cmtp.cmtGrid.y;
			
			//广告位
//			adArea.x = (SkinConfig.RIGHT_WIDTH - adArea.width) / 2;
//			adArea.y = (h - adArea.height) / 2;
		}
		
//		public function showAd():void
//		{
//			adArea.show();
//		}
		
		public function get isFold():Boolean
		{
			return is_folded;
		}
	}
}