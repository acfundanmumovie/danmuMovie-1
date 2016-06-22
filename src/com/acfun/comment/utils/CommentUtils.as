package com.acfun.comment.utils
{
	import com.acfun.External.PARAM;
	import com.acfun.Utils.Util;
	import com.acfun.comment.communication.CommentHandler;
	import com.acfun.comment.display.CommentView;
	import com.acfun.comment.entity.CommentConfig;
	import com.acfun.comment.entity.CommentType;
	import com.acfun.comment.entity.SingleCommentData;
	import flash.utils.getTimer;
	import com.acfun.net.PtoP;

	public class CommentUtils
	{
		public static var commentIndex:uint = 0;
		
		public static const UNKOWN_USER:String = "unknow_user";
		
		public static const AVAILABEL_MODEL:Array = ["4","1","5","6","7","2","3"];
		
		public static const AVALIABEL_FONTSIZE:Array = [16,25,37];
		
		public static const TYPE_ARRAY:Array = ["visitor","lock","acuser"];
		
		/**
		 * 创建新的Comment实例，同时进行赋值 
		 * @param obj 传入的Object
		 * @return 
		 * 
		 */		
		public static function createNewComment(data:Object,isLock:Boolean = false,border:Boolean=false):SingleCommentData
		{
			
			data["mode"] = CommentType.FLOW_LEFT_TO_RIGHT;
			if(data["color"] == null) data["color"] = 16777215;
			if(data["size"] == null) data["size"] = 25;			
			if(data["stime"] == null || int(data["stime"]) < 0) data["stime"] = CommentView.instance.currentTime || 0.1;
			//直播模式下stime并不可靠，重置为标准时间以确保空间计算的正常运行
//			if(PARAM.acInfo.isLive) data["stime"] = getTimer()/1000.0;
			if(data["user"] == null) data["user"] = CommentHandler.instance.commentUser;
			if(data["time"] == null)data["time"] = new Date().time;
			if(data["preview"] == null) data["preview"] = false;
			if(data["commentid"] == null) data["commentid"] = "null";
			if(data["type"] == null) data["type"] = data["islock"] == null ? "0" : data["islock"];
			
			var newData:SingleCommentData;
			if(data["mode"] == CommentType.FIXED_POSITION_AND_FADE)
			{
				/* 特殊评论 */
				try
				{
					
					//var newData:SingleCommentData = new SingleCommentData(data.mode,s.n,data.color,data.size,data.stime,(data.time * 1000 ),null,data.user,false,++ commentIndex,isLock);
					var s:Object = data["addon"] ||JSON.parse(data.message);
					newData = new SingleCommentData(data.mode,s.n,data.color,data.size,data.stime,(data.time),null,data.user,data["preview"],++commentIndex,data.c,data.message,data.commentid,data.type,isLock,border);
					newData.addon = s;
					newData.specialDuration = getSpecialDuration(newData);
					newData.url = s.url;
				}
				catch(e:Error){}
			}
			else
			{
				//普通评论（超过500长度不予显示，库中有60W长度的普通评论直接播放器卡死...vid=1004）
				if(!data["message"] || data["message"].length > 500)data["message"] = "";
				if (AVALIABEL_FONTSIZE.indexOf(int(data["size"])) == -1) data["size"] = 25;
				newData = new SingleCommentData(data.mode,data.message,data.color,data.size,data.stime,(data.time),null,data.user,data["preview"],++commentIndex,data.c,data.message,data.commentid,data.type,isLock,border);
			}		
			if(data["test"])
			{
				newData.isTest = data["test"];
			}
			return newData;
		}
		
		public static function createNewComment1(data:Object,isLock:Boolean = false,border:Boolean=false):SingleCommentData
		{
			
			data["mode"] = CommentType.FLOW_LEFT_TO_RIGHT;

			if(data["color"] == null) data["color"] = 16777215;
			if(data["size"] == null) data["size"] = 25;			
			if(data["stime"] == null || int(data["stime"]) < 0) data["stime"] = CommentView.instance.currentTime || 0.1;
			//直播模式下stime并不可靠，重置为标准时间以确保空间计算的正常运行
			//			if(PARAM.acInfo.isLive) data["stime"] = getTimer()/1000.0;
			if(data["user"] == null) data["user"] = CommentHandler.instance.commentUser;
			if(data["time"] == null)data["time"] = new Date().time;
			if(data["preview"] == null) data["preview"] = false;
			if(data["commentid"] == null) data["commentid"] = "null";
			if(data["type"] == null) data["type"] = data["islock"] == null ? "0" : data["islock"];
			
			var newData:SingleCommentData;
			if(data["mode"] == CommentType.FIXED_POSITION_AND_FADE)
			{
				/* 特殊评论 */
				try
				{
					//var newData:SingleCommentData = new SingleCommentData(data.mode,s.n,data.color,data.size,data.stime,(data.time * 1000 ),null,data.user,false,++ commentIndex,isLock);
					var s:Object = data["addon"] || Util.decode(data.message);
					newData = new SingleCommentData(data.mode,s.n,data.color,data.size,data.stime,(data.time),null,data.user,data["preview"],++commentIndex,data.c,data.message,data.commentid,data.type,isLock,border);
					newData.addon = s;
					newData.specialDuration = getSpecialDuration(newData);
					newData.url = s.url;
				}
				catch(e:Error){}
			}
			else
			{
				//普通评论（超过500长度不予显示，库中有60W长度的普通评论直接播放器卡死...vid=1004）
				
				if (AVALIABEL_FONTSIZE.indexOf(int(data["size"])) == -1) data["size"] = 25;
				newData = new SingleCommentData(data.mode,data.msg,data.color,data.size,data.stime,(data.time),null,data.user,data["preview"],++commentIndex,data.c,data.message,data.commentid,data.type,isLock,border);
			}	
			if(data["test"])
			{
				newData.isTest = data["test"];
			}
			return newData;
		}
		
		public static function createNewComment2(data:Object,isLock:Boolean = false,border:Boolean=false):SingleCommentData
		{
			
			data["mode"] = CommentType.FLOW_LEFT_TO_RIGHT;
			
			if(data["color"] == null) data["color"] = 16777215;
			if(data["size"] == null) data["size"] = 25;			
			if(data["stime"] == null || int(data["stime"]) < 0) data["stime"] = CommentView.instance.currentTime || 0.1;
			//直播模式下stime并不可靠，重置为标准时间以确保空间计算的正常运行
			//			if(PARAM.acInfo.isLive) data["stime"] = getTimer()/1000.0;
			if(data["user"] == null) data["user"] = CommentHandler.instance.commentUser;
			if(data["time"] == null)data["time"] = new Date().time;
			if(data["preview"] == null) data["preview"] = false;
			if(data["commentid"] == null) data["commentid"] = "null";
			if(data["type"] == null) data["type"] = data["islock"] == null ? "0" : data["islock"];
			
			var newData:SingleCommentData;
			if(data["mode"] == CommentType.FIXED_POSITION_AND_FADE)
			{
				/* 特殊评论 */
				try
				{
					//var newData:SingleCommentData = new SingleCommentData(data.mode,s.n,data.color,data.size,data.stime,(data.time * 1000 ),null,data.user,false,++ commentIndex,isLock);
					var s:Object = data["addon"] || Util.decode(data.message);
					newData = new SingleCommentData(data.mode,s.n,data.color,data.size,data.stime,(data.time),null,data.user,data["preview"],++commentIndex,data.c,data.message,data.commentid,data.type,isLock,border);
					newData.addon = s;
					newData.specialDuration = getSpecialDuration(newData);
					newData.url = s.url;
				}
				catch(e:Error){}
			}
			else
			{
				//普通评论（超过500长度不予显示，库中有60W长度的普通评论直接播放器卡死...vid=1004）
				
				if (AVALIABEL_FONTSIZE.indexOf(int(data["size"])) == -1) data["size"] = 25;
				newData = new SingleCommentData(data.mode,data.msg,data.color,data.size,data.stime,(data.time),null,data.user,data["preview"],++commentIndex,data.c,data.message,data.commentid,data.type,isLock,border);
			}	
			if(data["test"])
			{
				newData.isTest = data["test"];
			}
			return newData;
		}
		
		public static function createObjectStringToSend(c:SingleCommentData,action:String="post"):String
		{			
			return Util.encode({"action" : action,"command":Util.encode({mode:c.mode,
				color:c.color,
				size:c.size,
				stime:c.stime,
				user:CommentHandler.instance.commentUser,
				message:c.getText(),
//				time:int(new Date().time/1000),
				time:(new Date().time),
//				islock : CommentConfig.instance.useOldSystem ? (c.isLock ? "1":"0") : (CommentConfig.instance.isCoop ? "3" : (c.isLock ? "2":(CommentHandler.instance.commentAuthResult["uid"]?"1":"0")))})}); 	//0：非会员，1：会员，2:锁定，3: 合作		
				islock : ((c.isLock ? "1":(CommentHandler.instance.commentAuthResult["uid"]?"2":"0")))})}); 	//0：非会员，1：锁定，2:会员，3: 合作
		}
		
		public static function createObjectStringToDelete(cs:Array):String
		{
			return Util.encode({"action" : "del" , "command" : Util.encode(cs.map(
				function (item:SingleCommentData, index:int, array:Array):Object{
					return {"type":CommentUtils.TYPE_ARRAY[item.type],"commentid":item.commentid};
				}
			))});
		}
		
		public static function getIsLock(isLock:String):Boolean
		{
			return isLock == "1";
		}
		
		/**
		 * 计算弹幕持续时长（仅对高级弹幕有效，滚动弹幕时长跟窗口大小有关）
		 * 
		 */
		public static function getSpecialDuration(s:SingleCommentData):Number
		{
			var duration:Number = 0;
			if (s.addon)
			{
				if (s.addon.l != null)
					duration += s.addon.l;
				else
					duration += 3;
				
				if (s.addon.z)
				{
					for each(var zinf:Object in s.addon.z)
					{
						if (zinf.l > 0)
							duration += int(zinf.l);
					}
				}
			}
			return duration;
		}
	}
	
}