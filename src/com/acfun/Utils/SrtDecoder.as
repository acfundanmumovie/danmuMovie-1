package com.acfun.Utils
{
	public class SrtDecoder
	{
		public function SrtDecoder()
		{}
		
		public static function decode(srt:String):Array
		{
			var result:Array = [];
			var parts:Array = srt.split("\r\r");
			for each (var part:String in parts)
			{
				var m:Array = part.match(/\d\r(\S+)\s*-->\s*(\S+)\r(.+)/s);
				if (m==null || m.length!=4)
				{
					continue;
				}
				var start:Number   = convertTime(m[1]);
				var end:Number     = convertTime(m[2]);
				var content:String = formatContent(m[3]);
				result.push([start,end-start,content]);
			}
			return result;
		}
		
		private static function convertTime(s:String):Number
		{
			var second:Number = 0;
			
			s = s.replace(",",".");
			var a:Array = s.split(":");
			second += 3600 * int(a[0]);
			second += 60 * int(a[1]);
			second += Number(a[2]);
			
			return second * 1000;
		}
		
		private static function formatContent(s:String):String
		{
			return s.replace(/^{.*}/,"");
		}
	}
}