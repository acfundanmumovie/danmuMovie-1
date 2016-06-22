package com.letvcloud.stat
{
	import flash.external.ExternalInterface;
	import flash.net.SharedObject;
	import flash.net.URLRequest;
	import flash.net.sendToURL;
	import flash.system.Capabilities;
	
	public class Stat
	{
		
		public function Stat(ins:outStat)
		{
			
		}
		public static function getInstance():Stat{
			if (Stat.instance == null)
			{
				Stat.instance = new Stat(new outStat());
			}
			return Stat.instance;
		}
		/**
		 * vv cv报数
		 */
		public function sendStat(value:Object = null):void
		{
			var url:String = "http://dc.letv.com/pl/";
			//清空uuid
			if(value.ac == "init"){
				//每次初始化都清空uuid
				this._uuid ="";
			}
			try
			{
				url += "?ver=2.0"
				url += "&ac="+value.ac;
				url += "&p1=3";
				url += "&p2=30";
				url += "&p3=-";
				url += "&lc="+lc;
				url += "&uid=-";
				url += "&uuid="+uuid;
				url += "&auid=-";
				url += "&cid=-";
				url += "&pid=-";
				url += "&vid=-";
				url += "&vlen=-";
				url += "&ch="+value.ch;
				url += "&ty=0";
				url += "&vt=-";
				url += "&url="+encodeURIComponent(BrowserUtil.url);
				url += "&ref="+encodeURIComponent(BrowserUtil.referer);
				url += "&pv="+Capabilities.version;
				url += "&st=-";
				url += "&ilu=-";
				url += "&pcode=-";
				url += "&pt=0"; 
				url += "&ap=1";				
				var pystr:String="-";
				url += "&py="+pystr;
				
				if(value.hasOwnProperty("error")){
					url += "&err="+value['error'];
				}else{
					url += "&err=0";
				}
				if(value.hasOwnProperty("utime")){
					url += "&ut="+value['utime'];
				}else{
					url += "&ut=0";
				}
				if(value.hasOwnProperty("retry")){
					url += "&ry="+value['retry'];
				}							
				url += "&r="+Math.random();
				url += "&cid=100";
				sendToURL(new URLRequest(url));
				trace(url);
			}
			catch(e:Error)
			{
				
			}
		}
		/**
		 * 环境报数 
		 * @param value
		 * 
		 */		
		public function sendEnvStat():void
		{
			
			var url:String = "http://dc.letv.com/env/";
			try
			{
				url += "?p1=3";
				url += "&p2=30";
				url += "&p3=-";
				url += "&lc="+lc;
				url += "&uuid="+uuid;
				url += "&ip=-";
				url += "&mac=-";
				url += "&nt=-";
				url += "&os="+os;
				url += "&osv=-";
				url += "&app="+Capabilities.version;
				url += "&bd=-";
				url += "&xh=-";
				url += "&ro="+Capabilities.screenResolutionX+"_"+Capabilities.screenResolutionY;
				url += "&br="+BrowserUtil.name;
				url += "&r="+Math.random();
				url += "&cid=100";
				sendToURL(new URLRequest(url));
				trace(url);
			}catch(e:Error){
			}
		}
		
		private function get lc():String
		{
			var value:String;
			try
			{
				if(storage_so == null)storage_so = SharedObject.getLocal("com.letv.storage.1","/");
				if(storage_so.data.hasOwnProperty("lc")){
					value = storage_so.data['lc'];
				}
				if(value==null || value==""){
					value = GUUID.create();
					storage_so.data['lc'] = value;
					storage_so.flush();
				}
			}catch(e:Error){}
			return value;
		}
		private function get uuid():String
		{
			if(_uuid == "") _uuid = GUUID.create()
			return _uuid;
		}
		private function get os():String
		{
			var value:String = Capabilities.os.toLowerCase();
			if(value.indexOf("windows xp") >= 0){
				return "winxp";
			}
			if(value.indexOf("windows 7") >= 0){
				return "win7";
			}
			if(value.indexOf("windows 8") >= 0){
				return "win8";
			}
			if(value.indexOf("windows vista") >= 0){
				return "vista";
			}
			if(value.indexOf("windows ce") >= 0){
				return "wince";
			}
			if(value.indexOf("linux") >= 0){
				return "linux";
			}
			return value;
		}
		private var storage_so:SharedObject;
		private var _uuid:String = "";
		private static var instance:Stat;
	}
}
class outStat
{}
import flash.system.Capabilities;
class GUUID
{
	private static var counter:Number = 0;		
	internal static function create():String {
		var id1:Number = (new Date()).time;
		var id2:Number = Math.random() * Number.MAX_VALUE;
		var id3:String = Capabilities.serverString;
		var rawID:String = calculate(id1 + id3 + id2 + counter++).toUpperCase();
		return rawID;
	}
	private static function calculate(src:String):String {
		return hex_sha1(src);
	}
	private static function hex_sha1(src:String):String {
		return binb2hex(core_sha1(str2binb(src), src.length*8));
	}
	private static function core_sha1(x:Array, len:Number):Array {
		x[len >> 5] |= 0x80 << (24-len%32);
		x[((len+64 >> 9) << 4)+15] = len;
		var w:Array = new Array(80), a:Number = 1732584193;
		var b:Number = -271733879, c:Number = -1732584194;
		var d:Number = 271733878, e:Number = -1009589776;
		for (var i:Number = 0; i<x.length; i += 16) {
			var olda:Number = a, oldb:Number = b;
			var oldc:Number = c, oldd:Number = d, olde:Number = e;
			for (var j:Number = 0; j<80; j++) {
				if (j<16){
					w[j] = x[i+j];
				}else{
					w[j] = rol(w[j-3] ^ w[j-8] ^ w[j-14] ^ w[j-16], 1);
				}
				var t:Number = safe_add(safe_add(rol(a, 5), sha1_ft(j, b, c, d)), safe_add(safe_add(e, w[j]), sha1_kt(j)));
				e = d; 
				d = c;
				c = rol(b, 30);
				b = a; 
				a = t;
			}
			a = safe_add(a, olda);
			b = safe_add(b, oldb);
			c = safe_add(c, oldc);
			d = safe_add(d, oldd);
			e = safe_add(e, olde);
		}
		return new Array(a, b, c, d, e);
	}
	
	private static function sha1_ft(t:Number, b:Number, c:Number, d:Number):Number {
		if (t<20) return (b & c) | ((~b) & d);
		if (t<40) return b ^ c ^ d;
		if (t<60) return (b & c) | (b & d) | (c & d);
		return b ^ c ^ d;
	}
	private static function sha1_kt(t:Number):Number {
		return (t<20) ? 1518500249 : (t<40) ? 1859775393 : (t<60) ? -1894007588 : -899497514;
	}
	
	private static function safe_add(x:Number, y:Number):Number {
		var lsw:Number = (x & 0xFFFF)+(y & 0xFFFF);
		var msw:Number = (x >> 16)+(y >> 16)+(lsw >> 16);
		return (msw << 16) | (lsw & 0xFFFF);
	}
	private static function rol(num:Number, cnt:Number):Number {
		return (num << cnt) | (num >>> (32-cnt));
	}
	
	private static function str2binb(str:String):Array {
		var bin:Array = new Array();
		var mask:Number = (1 << 8)-1;
		for (var i:Number = 0; i<str.length*8; i += 8) {
			bin[i >> 5] |= (str.charCodeAt(i/8) & mask) << (24-i%32);
		}
		return bin;
	}
	
	private static function binb2hex(binarray:Array):String {
		var str:String = new String("");
		var tab:String = new String("0123456789abcdef");
		for (var i:Number = 0; i<binarray.length*4; i++) {
			str += tab.charAt((binarray[i >> 2] >> ((3-i%4)*8+4)) & 0xF) + tab.charAt((binarray[i >> 2] >> ((3-i%4)*8)) & 0xF);
		}
		return str;
	}
}

import flash.external.ExternalInterface;
class BrowserUtil
{
	//浏览器名称.
	private static var _name:String;
	
	private static function getEval(type:String):String
	{
		try{
			return ExternalInterface.call("eval",type);
		}catch(e:Error){}
		return null;
	}
	
	private static function getBrowserName():String
	{
		var value:String = getEval("navigator.userAgent");
		if(value == null){
			return "-";
		}
		value = value.toLowerCase();
		if(value.indexOf("msie") >= 0){
			value = value.split(";")[1];
			value = value.split(" ")[1];
			return "ie"+int(value);
		}
		if(value.indexOf("360se")>=0){
			return "360";
		}
		if(value.indexOf("tencent") >= 0){
			return "qq";
		}
		if(value.indexOf("se 2.x") >= 0){
			return "sogou";
		}
		if(value.indexOf("tencent") >= 0){
			return "qq";
		}
		if(value.indexOf("firefox") >= 0){
			return "ff";
		}
		if(value.indexOf("chrome") >= 0){
			return "chrome";
		}
		if(value.indexOf("safari") >= 0){
			return "safa";
		}
		if(value.indexOf("opera") >= 0){
			value = "opera";
		}
		return "other";
	}
	
	/**
	 * 返回符合标准的浏览器版本号.
	 */
	public static function get name():String
	{
		if(_name == null){
			_name = getBrowserName();
		}
		return _name;
	}
	/**
	 * 页面地址.
	 */
	public static function get url():String 
	{
		return getEval("window.location.href");
	}
	
	/**
	 * 页面来源.
	 */ 
	public static function get referer():String
	{
		var url:String;
		try{
			url = getEval("document.referrer");
			if(url.indexOf("http://")>-1) return url;
		}catch(e:Error){}
		return "-";
	}	
}