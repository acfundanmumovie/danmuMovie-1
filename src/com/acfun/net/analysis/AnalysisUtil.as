/**
 * ===================================
 * Author:	iDzeir					
 * Email:	qiyanlong@wozine.com	
 * Company:	http://www.acfun.tv		
 * Created:	May 18, 2015 12:34:35 PM			
 * ===================================
 */

package com.acfun.net.analysis
{
	import com.acfun.Utils.Util;
	
	import flash.net.URLRequest;
	import flash.net.sendToURL;

	/**
	 * 统计提交类
	 */	
	public class AnalysisUtil
	{
		
		/**
		 * 直接发送统计消息消息
		 */		
		public static function send(iAnalysis:IAnalysis):void
		{
			var urlReq:URLRequest = new URLRequest();
			urlReq.url = iAnalysis.url;
			try{
				urlReq.data = iAnalysis.info&&Util.encode(iAnalysis.info);
			}catch(e:Error){
				return;
			};
			//只是发送不关心接收成功与否
			//sendToURL(urlReq);
		}
	}
}