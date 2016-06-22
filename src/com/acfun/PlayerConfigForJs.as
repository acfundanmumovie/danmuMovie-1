package com.acfun
{
	import com.acfun.External.AcConfig;
	import com.acfun.External.JavascriptAPI;
	import com.acfun.signal.notify;
	
	import flash.display.Sprite;
	import flash.net.SharedObject;
	import com.acfun.External.SIGNALCONST;
	
	/**
	 * JS设置播放器参数接口 
	 * @author sky
	 * 
	 */
	public class PlayerConfigForJs extends Sprite
	{
		public function PlayerConfigForJs()
		{
			super();
			
			//js保存设置回调
			JavascriptAPI.addCall(JavascriptAPI.SAVE_PLAYER_CONFIG,onSave);
			
			//获取设置
			var config:AcConfig = AcConfig.getInstance();
			config.init();
			
			//获取过滤
			var cookie:SharedObject = SharedObject.getLocal("ACPlayerFilter", '/');
			var filter:String = cookie.data['CommentFilter'];			
			
			//传递给js
			JavascriptAPI.callJS(JavascriptAPI.PLAYER_READY,{config:config,filter:filter});
		}
		
		private function onSave(config:Object):void
		{
			if (config)
			{
				if (config["config"])
				{
					notify(SIGNALCONST.SET_CONFIG,config["config"]);				
				}
				
				if (config["filter"])
				{
					var cookie:SharedObject = SharedObject.getLocal("ACPlayerFilter", '/');
					cookie.data['CommentFilter'] = config["filter"];
					cookie.flush();
				}
			}
		}
	}
}