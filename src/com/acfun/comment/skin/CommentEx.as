package com.acfun.comment.skin 
{
	import com.acfun.Utils.Util;
	
	import fl.controls.NumericStepper;
	import fl.core.UIComponent;
	import fl.events.ComponentEvent;
	
	import flash.display.InteractiveObject;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFieldType;
	
	public class CommentEx extends CommentExUI 
	{
		private var ID:Array;
		private var Labs:Array;
		private var Labts:Array;
		private var Links:Array;
		private var storeCA:Object;
		public var getNowTime:Function;
		public var defFontIdx:uint;
		private var textfilter:String;
					
		public function CommentEx() {
			super();
		}

		public function resetvalue():void
		{
			var tls:Array = [[xpos,ypos,xposto,yposto,zposto,Sxpos,Sypos,Szpos,SxposA,SyposA,SzposA,sendTime,earse,zpos],[startAlpha,trans,SCxposA,SCyposA,SCzpos,SCxpos,SCypos,SCzpos],[life,depth]];
			var tvls:Array = [0,1,3];
			var stls:Array;
			var tns:NumericStepper;
			var tvl:Number;
			for(var i:int=tvls.length-1;i>=0;i--)
			{
				stls = tls[i];
				tvl = tvls[i];
				for each(tns in stls)
				{
					tns.value = tvl;
					tns.enabled = false;
				}
			}
			fontSize.value = 25;lifeA.value = 3;depth.value = 0;
			startSelectColor.selectedColor = transColor.selectedColor = 0;
			transColor.enabled = false;
			isBroder.selected = false;
			bMode.selectedIndex = Cmode.selectedIndex = 0;
			cord.selectedIndex = 4;
			filtersetDisable();
			Fontset.selectedIndex = defFontIdx;
			Fontset.enabled = false;
			isBold.selected = false;
			url.enabled = false;
			Name.enabled = false;
			Parent.enabled = false;
			Mask.enabled = false;
		}
		
		public function initc():void
		{
			// constructor code
			Labs = [txpos,typos,txposto,typosto,tzposto,tSxpos,tSypos,tSCxpos,tSCypos,tSxposA,tSyposA,tSCxposA,tSCyposA,tstartAlpha,tlife,tDepth,ttrans,tearse,tFontset,tbMode,tSzposA,tSCzposA,tSzpos,tSCzpos,tzpos,turl,tName,tParent,tMask];
			Labts = [xpos,ypos,xposto,yposto,zposto,Sxpos,Sypos,SCxpos,SCypos,SxposA,SyposA,SCxposA,SCyposA,startAlpha,life,depth,trans,earse,Fontset,bMode,SzposA,SCzposA,Szpos,SCzpos,zpos,url,Name,Parent,Mask];
			Links = new Array;
			var tlabs:TextField;
			var tlabts:UIComponent;
			for(var i:int=Labs.length-1;i>=0;i--)
			{
				tlabs = Labs[i] as TextField;
				tlabts = Labts[i] as UIComponent;
				if(tlabs != null && tlabts != null)
				{
					Links[tlabs.name] = tlabts;
					tlabs.addEventListener(MouseEvent.CLICK,MouseClickHandler);
					tlabts.enabled = false;
				}				
			}
			transColor.addEventListener(Event.ADDED,fixdo);
			tsendTime.addEventListener(MouseEvent.CLICK,timeClickHandler);
			sendTime.enabled = false;getNowTime = timeget;
			tFilterset.addEventListener(MouseEvent.CLICK,filtersetClickHandler);
//			textSwitch.addEventListener(Event.CHANGE,switch_clickHandler);
			filtersetDisable();
			textfilter="";
			cord.selectedIndex = 4;			
//			tSCzpos.visible = SCzpos.visible = false;
//			SCzposA.visible = tSCzposA.visible = false;			
			isVer2.addEventListener(MouseEvent.CLICK,ver2ClickHandler);
			
			var tabSequence:Array = 
				[
					Cmode,
					cord,
					Fontset,
					sendTime,
					life,
					startAlpha,
					depth,
					xpos,
					ypos,
					zpos,
					Sxpos,
					Sypos,
					Szpos,
					SCxpos,
					SCypos,
					SCzpos,
					xposto,
					yposto,
					zposto,
					SxposA,
					SyposA,
					SzposA,
					SCxposA,
					SCyposA,
					SCzposA,
					earse,
					trans,
					lifeA
				];
			var j:int = 1;
			for each (var obj:InteractiveObject in tabSequence)
				obj.tabIndex = j++;
				
			//默认不显示链接项
			seturl(false);
			//默认不显示容器和遮罩（等稳定之后开放）
//			setbiu(false);
			
			//给予colorPicker复制粘贴功能
			Util.colorPickerExtend(startSelectColor);
			Util.colorPickerExtend(transColor);
		}
		
		protected function ver2ClickHandler(event:MouseEvent):void
		{
			isOverVideoPartHidden.enabled = isVer2.selected;
		}
		
//		private function switch_clickHandler(event:Event):void
//		{
//			textActionList.visible = textSwitch.selected;
//			actionList.visible = !textSwitch.selected;
//		}
		
		private function filtersetClickHandler(evt:MouseEvent):void
		{
			if(Filterset.type == flash.text.TextFieldType.DYNAMIC)
			{filtersetEnable(textfilter);}
			else
			{filtersetDisable();}
		}
		
		public function setadvs(v:Boolean):void
		{
			Filterset.visible = tFilterset.visible = isBold.visible = Fontset.visible = tFontset.visible = v;
		}
		
		public function seturl(v:Boolean):void
		{
			turl.visible = url.visible = v;
		}
		
		public function setbiu(v:Boolean):void
		{
			tParent.visible = Parent.visible = v;
			tMask.visible = Mask.visible = v;
		}
		
		public function filtersetEnable(str:String):void
		{
			Filterset.type = flash.text.TextFieldType.INPUT;
			Filterset.mouseEnabled = true;
			trace(str);
			Filterset.text = str;
		}
	
		public function filtersetDisable():void
		{
			if(Filterset.type == flash.text.TextFieldType.DYNAMIC){return;}
			textfilter = Filterset.text;
			Filterset.text = "禁用";
			Filterset.type = flash.text.TextFieldType.DYNAMIC;
			Filterset.mouseEnabled = false;
		}
		
		private function timeClickHandler(evt:MouseEvent):void
		{
			
			sendTime.enabled = !sendTime.enabled;
			if(sendTime.enabled){sendTime.value = getNowTime();}
		}
		
		private function fixdo(e:Event):void
		{
			transColor.removeEventListener(Event.ADDED,fixdo);
			transColor.enabled = false;
//			Cmode.enabled = false;
			textActionList.visible = false;
			ttransColor.addEventListener(MouseEvent.CLICK,function(e:MouseEvent):void{transColor.enabled=!transColor.enabled;});
			transColor.setStyle('columnCount',20);
			startSelectColor.setStyle('columnCount',20);
			transColor.colors = startSelectColor.colors = [0,0,0,13056,26112,39168,52224,65280,3342336,3355392,3368448,3381504,3394560,3407616,6684672,6697728,6710784,6723840,6736896,6749952,
							0x333333,0,51,13107,26163,39219,52275,65331,3342387,3355443,3368499,3381555,3394611,3407667,6684723,6697779,6710835,6723891,6736947,6750003,
							0x666666,0,102,13158,26214,39270,52326,65382,3342438,3355494,3368550,3381606,3394662,3407718,6684774,6697830,6710886,6723942,6736998,6750054,
							0x999999,0,153,13209,26265,39321,52377,65433,3342489,3355545,3368601,3381657,3394713,3407769,6684825,6697881,6710937,6723993,6737049,6750105,
							0xcccccc,0,204,13260,26316,39372,52428,65484,3342540,3355596,3368652,3381708,3394764,3407820,6684876,6697932,6710988,6724044,6737100,6750156,
							0xffffff,0,255,13311,26367,39423,52479,65535,3342591,3355647,3368703,3381759,3394815,3407871,6684927,6697983,6711039,6724095,6737151,6750207,
							0xff0000,0,10027008,10040064,10053120,10066176,10079232,10092288,13369344,13382400,13395456,13408512,13421568,13434624,16711680,16724736,16737792,16750848,16763904,16776960,
							0x00ff00,0,10027059,10040115,10053171,10066227,10079283,10092339,13369395,13382451,13395507,13408563,13421619,13434675,16711731,16724787,16737843,16750899,16763955,16777011,
							0x0000ff,0,10027110,10040166,10053222,10066278,10079334,10092390,13369446,13382502,13395558,13408614,13421670,13434726,16711782,16724838,16737894,16750950,16764006,16777062,
							0xffff00,0,10027161,10040217,10053273,10066329,10079385,10092441,13369497,13382553,13395609,13408665,13421721,13434777,16711833,16724889,16737945,16751001,16764057,16777113,
							0x00ffff,0,10027212,10040268,10053324,10066380,10079436,10092492,13369548,13382604,13395660,13408716,13421772,13434828,16711884,16724940,16737996,16751052,16764108,16777164,
							0xff00ff,0,10027263,10040319,10053375,10066431,10079487,10092543,13369599,13382655,13395711,13408767,13421823,13434879,16711935,16724991,16738047,16751103,16764159,16777215];
		}
		
		public function timeget():Number	{return 0;}
		
		public function setXY(l:int,X:int,Y:int):Boolean
		{
			if(1>=l && l>=0)
			{
				l *= 2;
				var tlabts:NumericStepper;
				tlabts = Labts[l] as NumericStepper;
				if(tlabts != null){tlabts.value = X;tlabts.enabled = true;}
				tlabts = Labts[l+1] as NumericStepper;
				if(tlabts != null){tlabts.value = Y;tlabts.enabled = true;return true;}
			}
			return false;
		}
		
		private function MouseClickHandler(evt:MouseEvent):void
		{
			var tstrCT:String = evt.currentTarget.name;
			var tlabts:UIComponent;
			if(tstrCT != null)
			{
				tlabts = Links[tstrCT] as UIComponent;
				if(tlabts != null){tlabts.enabled = !tlabts.enabled;}
			}
		}
		
		public function getActData(lockpad:Boolean = true):Object
		{
			//强制失效，更新NumericStepper数据
			stage.focus = null;
			
			var myOBJ:Object = new Object();
			if(xposto.enabled)myOBJ.x = xposto.value;
			if(yposto.enabled)myOBJ.y = yposto.value;
			if(zposto.enabled)myOBJ.z = zposto.value;
			if(transColor.enabled)myOBJ.c = transColor.selectedColor;
			if(SxposA.enabled)myOBJ.rx = SxposA.value;
			if(SyposA.enabled)myOBJ.e = SyposA.value;
			if(SzposA.enabled)myOBJ.d = SzposA.value;
						
			if(SCxposA.enabled)myOBJ.f = SCxposA.value;
			if(SCyposA.enabled)myOBJ.g = SCyposA.value;
			if(SCzposA.enabled)myOBJ.sz= SCzposA.value;
			if(trans.enabled)myOBJ.t = trans.value;
			if(lifeA.enabled)myOBJ.l = lifeA.value;
			if(earse.enabled)myOBJ.v = uint(earse.value);
			/** 锁定面板 **/
			if(lockpad)
			{
				earse.enabled =
				xposto.enabled = 
				yposto.enabled =
				zposto.enabled =
				transColor.enabled =
				SxposA.enabled =
				SyposA.enabled =
				SzposA.enabled =
				SCxposA.enabled =
				SCyposA.enabled =
				SCzposA.enabled =
				trans.enabled = false;
			}
			return myOBJ;
		}
		
		public function setActData(so:Object):void
		{
			if(so.x!=null)	{xposto.value=so.x;xposto.enabled=true;}else{xposto.enabled=false;}
			if(so.y!=null)	{yposto.value=so.y;yposto.enabled=true;}else{yposto.enabled=false;}
			if(so.z!=null)	{zposto.value=so.z;zposto.enabled=true;}else{zposto.enabled=false;}
			if(so.c!=null)	{transColor.selectedColor=so.c;transColor.enabled=true;}else{transColor.enabled=false;}
			if(so.rx!=null)	{SxposA.value =so.rx;SxposA.enabled=true;}else{SxposA.enabled=false;}
			if(so.e!=null)	{SyposA.value=so.e;SyposA.enabled=true;}else{SyposA.enabled=false;}
			if(so.d!=null)	{SzposA.value =so.d;SzposA.enabled=true;}else{SzposA.enabled=false;}
			if(so.f!=null)	{SCxposA.value=so.f;SCxposA.enabled=true;}else{SCxposA.enabled=false;}
			if(so.g!=null)	{SCyposA.value=so.g;SCyposA.enabled=true;}else{SCyposA.enabled=false;}
			if(so.sz!=null)	{SCzposA.value=so.sz;SCzposA.enabled=true;}else{SCzposA.enabled=false;}
			if(so.t!=null)	{trans.value=so.t;trans.enabled=true;}else{trans.enabled=false;}
			if(so.l!=null)	{lifeA.value=so.l;lifeA.enabled=true;}else{lifeA.enabled=false;}
			if(so.v!=null)	{earse.value=so.v;earse.enabled=true;}else{earse.enabled=false;}
		}
		
		public function getCommentObject():Object
		{
			//强制失效，更新NumericStepper数据
			stage.focus = null;
			
			var commentObject:Object = new Object();
			commentObject.t = 0;
			if(xpos.enabled || ypos.enabled)commentObject.p = {x:(xpos.enabled?xpos.value:0),y:(ypos.enabled?ypos.value:0)};
			if(Sxpos.enabled)commentObject.rx = Sxpos.value;
			if(Sypos.enabled)commentObject.k = Sypos.value;
			if(Szpos.enabled)commentObject.r = Szpos.value;
			commentObject.b = isBroder.selected;
			if(life.enabled)commentObject.l = life.value;
			if(depth.enabled)commentObject.dep = depth.value;
			if(bMode.enabled)commentObject.bm = bMode.selectedIndex;
			if(zpos.enabled)commentObject.pz = zpos.value;
			
			if(cord.selectedIndex < cord.dataProvider.length - 1){commentObject.c = cord.selectedIndex;}
			else if(storeCA != null){commentObject.c == storeCA}
			
			if(startAlpha.enabled)commentObject.a = startAlpha.value;
			if(SCxpos.enabled)commentObject.e = SCxpos.value;
			if(SCypos.enabled)commentObject.f = SCypos.value;
			if(SCzpos.enabled)commentObject.sz= SCzpos.value;
			if(Fontset.enabled){commentObject.w = {f:Fontset.value,b:isBold.selected};}
			if(Filterset.text.length>3)
			{
				if(commentObject.w == null){commentObject.w = new Object;}
				commentObject.w.l = Filterset.text;
			}
			
			//追加
			commentObject.ver = isVer2.selected ? 2 : 1;			//新版缩放渲染
			if (isOverVideoPartHidden.enabled) commentObject.ovph = isOverVideoPartHidden.selected;	//超出视频外部分隐藏
			if (url.enabled && url.text.length > 0) commentObject.url = url.text;	//ac链接
			if (Name.enabled && Name.text.length > 0) commentObject.name = Name.text;	//弹幕名称
			if (Parent.enabled && Parent.text.length > 0) commentObject.parent = Parent.text;	//弹幕父容器
			if (Mask.enabled && Mask.text.length > 0) commentObject.mask = Mask.text;	//弹幕遮罩
			return commentObject;
		}
		
		public function setCommentObject(so:Object,iadd:Object):void
		{
			if(so.p!=null)	{xpos.value = so.p.x;ypos.value=so.p.y;xpos.enabled=ypos.enabled=true;}else{xpos.enabled=ypos.enabled=false}
			if(so.rx!=null)	{Sxpos.value=so.rx;	Sxpos.enabled=true}	else{Sxpos.enabled=false}
			if(so.k!=null)	{Sypos.value=so.k;	Sypos.enabled=true}	else{Sypos.enabled=false}
			if(so.r!=null)	{Szpos.value=so.r;	Szpos.enabled=true}	else{Szpos.enabled=false}
			if(so.pz!=null)	{zpos.value=so.pz;	zpos.enabled=true}	else{zpos.enabled=false}
			if(so.bm!=null)	{bMode.selectedIndex=so.bm;	bMode.enabled=true}	else{bMode.enabled=false}
			if(so.l!=null)	{life.value=so.l;	life.enabled=true}	else{life.enabled=false}
			if(so.dep!=null){depth.value=so.dep;depth.enabled=true}	else{depth.enabled=false}
			if(so.a!=null)	{startAlpha.value=so.a;	startAlpha.enabled=true}else{startAlpha.enabled=false}
			if(so.e!=null)	{SCxpos.value=so.e;	SCxpos.enabled=true}else{SCxpos.enabled=false}
			if(so.f!=null)	{SCypos.value=so.f;	SCypos.enabled=true}else{SCypos.enabled=false}
			if(so.sz!=null)	{SCzpos.value=so.sz;SCzpos.enabled=true}else{SCzpos.enabled=false}
			if(iadd!=null && iadd.fidx!=null){Fontset.enabled=true;Fontset.selectedIndex=iadd.fidx;isBold.selected=so.w.b}
			else {Fontset.selectedIndex=defFontIdx;Fontset.enabled=false;isBold.selected=false;}
			if(iadd!=null && iadd.ltxt!=null){filtersetEnable(iadd.ltxt);}else{filtersetDisable();}
			isBroder.selected=so.b;
			if(so.ca != null){storeCA = so.ca;cord.selectedIndex = cord.dataProvider.length - 1}
			else{cord.selectedIndex=so.c;}
			
			isVer2.selected = !(so.ver == 1);
			isOverVideoPartHidden.selected = !(so.ovph == false);
			if (so.url!=null) {url.text=so.url;url.enabled=true;} else {url.enabled=false;}
			if (so.name!=null) {Name.text=so.name;Name.enabled=true;} else {Name.enabled=false;}
			if (so.parent!=null) {Parent.text=so.parent;Parent.enabled=true;} else {Parent.enabled=false;}
			if (so.mask!=null) {Mask.text=so.mask;Mask.enabled=true;} else {Mask.enabled=false;}			
		}
		
		public function getComData(timepad:Boolean = false):Object
		{
			var comData:Object = new Object();
			comData.sc = startSelectColor.selectedColor;
			comData.sz = fontSize.value;
			if(sendTime.enabled){comData.st = sendTime.value;sendTime.enabled=timepad}
			else {comData.st = -1;}
			return comData;
		}
		
		public function setComData(so:Object):void
		{
			fontSize.value = so.sz;
			sendTime.value = so.st;
			sendTime.enabled=true;
			startSelectColor.selectedColor=so.sc
		}
		
		public function clearlifetime():void
		{
			life.value = 0;
			life.enabled = false;
		}
		
		public function getIDs():Array
		{
			if (ID == null)
			{
				ID = new Array();
				ID["textIp"] = textIp;
				ID["postoBt"] = postoBt;
				ID["posBt"] = posBt;
				ID["actionList"] = actionList;
				ID["Cmode"] = Cmode;
				ID["B_addACT"] = B_addACT;
				ID["B_fixACT"] = B_fixACT;
				ID["B_action_clear"] = B_action_clear;
				ID["B_action_reset"] = B_action_reset;
				ID["B_Prw"] = B_Prw;
				ID["B_Add"] = B_Add;				
				ID["B_reset"] = B_reset;
				ID["C_tFont"] = Fontset;
				ID["T_tFilter"] = Filterset;
				ID["B_tAct"] = textSwitch;
				ID["textAL"] = textActionList;
			}
			return ID;
		}
	}
	
}
