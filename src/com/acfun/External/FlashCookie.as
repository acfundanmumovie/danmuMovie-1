package com.acfun.External 
{
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	import flash.system.Security;
	import flash.display.MovieClip;
	import flash.utils.Timer;
	import flash.events.TimerEvent;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.external.ExternalInterface;

	public class FlashCookie extends MovieClip
	{

		private var toHart:Timer;
		private var aoHartBak:Array;
		private var aoHartCount:Array;
		private var vRunStatus:String;
		private var vDebugInfo:String;
		private var vShareInfo:String;
		private var vSessionID:String;
		private var vVideoID:String;
		private var vPlayTime:int;
		private var vActCount:int;
		private var vRunTime:int;
		private var vSetID:int;
		private var varLoader:URLLoader;

		private var vPlayName:String;
		private var vUrl:String;

		//****************环境变量设置 StartLine ************

		public var _MaxSave:int = 10;//最大缓存条数
		public var _CheckStep:int = 5;//轮询数据间隔，默认5秒
		public var _MaxStepCount:int = 3;//轮询超期阀值，默认2次
		public var _IWT_UAID:String = "UA-xxxxx-xxxxx";//监测群组标示，每个监测项目不同设置
		public var _IWT_URL:String = "http://irs01.com/irt";//调用统计服务器URL
		public var _IWT_FDir:String = "/";//共享数据存储位置，默认"/"
		public var _IWT_FMark:String = "irs_ftrack";//共享数据存储标签，默认"irs_ftrack"
		public var _IWT_FVer:String = "v1.8";//监测代码版本号
		public var _IWT_Debug:Boolean = false;//调试模式

		//****************环境变量设置 EndLine ************

		public function FlashCookie()
		{

			Security.allowDomain('*');
			Security.allowInsecureDomain('*');

			if (aoHartBak == null)
			{
				aoHartBak = new Array(_MaxSave);
				aoHartCount = new Array(_MaxSave);
				for (var j:int=0; j<aoHartBak.length; j++)
				{
					aoHartBak[j] = -1;
					aoHartCount[j] = 0;
				}
				vRunTime = 0;
				vDebugInfo = "";
				vSetID = -1;
				vSessionID = null;
				vVideoID = null;
				vRunStatus = "load";
			}

			if (toHart == null)
			{
				toHart = new Timer(1000,0);
				toHart.addEventListener(TimerEvent.TIMER,RunTimeHandler);
				toHart.start();
			}

			vSessionID = UvidLoadSet();


		}

		//****************公共接口部分 StartLine ************

		public function IRS_NewPlay(uVideoID:String, uTotalTime:int, uPlay:Boolean, uPlayName:String, uUrl:String):void
		{
			DebugInfo("IRS_NewPlay："+ uVideoID +"|"+uTotalTime);

			vSetID = HartSaveSet(-1,0);

			if (vSetID != -1)
			{
				//生成新的视频播放记录
				vPlayTime = 0;
				vActCount = 0;
				vVideoID = uVideoID;

				vPlayName = uPlayName;
				if (uUrl == null)
				{
					try
					{
						if (ExternalInterface.available)
						{
							vUrl = ExternalInterface.call("eval","window.location.href");
						}
						else
						{
							vUrl = "";
						}
					}
					catch (e:Error)
					{
						vUrl = "error";
					}
					
					//vUrl = ExternalInterface.call("eval","window.location.href");
				}
				else
				{
					vUrl = uUrl;
				}
				//DebugInfo(vUrl);

				DataSaveSet(vSetID, _IWT_UAID, vSessionID, vVideoID, uTotalTime, 0, 0, 0, 0,vPlayName,vUrl);
				doDataSend(vSetID, "A");
				if (uPlay)
				{
					IRS_UserACT("play");
				}

			}
			else
			{
				DebugInfo('vSetID无效，IRSNewPlay出错!');
			}
		}

		public function IRS_UserACT(uStatus:String):void
		{

			if (uStatus == "play" || uStatus == "pause")
			{
				vActCount++;
				vRunStatus = uStatus;
			}
			else if (uStatus == "drag")
			{
				vActCount++;
			}
			else if (uStatus == "end")
			{
				vActCount++;
				vRunStatus = uStatus;
				doDataCheck();
				if (vSetID != -1)
				{
					doDataSend(vSetID, "B");
					vSetID = -1;
				}
			}
			else if (uStatus == "stop")
			{
				vActCount++;
				vRunStatus = uStatus;
			}
			else
			{
				DebugInfo("IRS_UserACT参数不合法!");
			}

		}

		public function IRS_GetXValue(vItem:String):String
		{
			if (this[vItem] != null)
			{
				return this[vItem].toString();
			}
			else
			{
				return "Null";
			}
		}

		public function IRS_FlashClear():void
		{
			var soHart_Clear:SharedObject;
			//调试期间，初始化用代码
			try
			{
				soHart_Clear = SharedObject.getLocal(_IWT_FMark,_IWT_FDir);
				soHart_Clear.clear();
			}
			catch (e:Error)
			{
				DebugInfo("清除FT_Hart失败!"+e);
			}
			soHart_Clear = null;
			for (var j:int=0; j<_MaxSave; j++)
			{
				try
				{
					soHart_Clear = SharedObject.getLocal(_IWT_FMark+"_"+j, _IWT_FDir);
					soHart_Clear.clear();
				}
				catch (e:Error)
				{
					DebugInfo("清除FT_Data_"+j+"失败!"+e);
				}
				soHart_Clear = null;
			}
			vSetID = -1;
			vVideoID = null;
			vRunStatus = "clear";
		}

		//****************公共接口部分 EndLine ************
		private function RunTimeHandler(event:TimerEvent):void
		{
			vRunTime++;
			if (vRunTime%_CheckStep == 0)
			{
				doDataCheck();
			}

			if (vRunStatus == "play" && vSetID != -1)
			{
				//如果是播放状态，PlayTime计时累加
				vPlayTime++;
			}
		}

		private function doDataCheck():void
		{
			DebugInfo("调用:doDataCheck检查是否有历史数据");
			var aoHart_Check:Array = HartLoadSet();
			if (aoHart_Check != null)
			{
				if (vSetID != -1)
				{
					//更新当前记录的心跳。
					aoHart_Check[vSetID]++;
					HartSaveSet(vSetID, aoHart_Check[vSetID]);
					DataSaveSet(vSetID, null, vSessionID, null, -2, vPlayTime, vActCount, aoHart_Check[vSetID], -2,null,null);
					//播放时长更新，还需要修改
				}

				//检查是否有心跳超期数据，查到就发送。
				for (var i:int=0; i<aoHart_Check.length; i++)
				{
					if (aoHart_Check[i] == aoHartBak[i] && aoHart_Check[i] != -1)
					{
						//trace("aoHartCount:i:"+i);
						aoHartCount[i]++;
						if (aoHartCount[i] >= _MaxStepCount)
						{
							aoHartCount[i] = 0;
							doDataSend(i, "C");
							break;
						}
						break;
					}
					else
					{
						aoHartBak[i] = aoHart_Check[i];
						aoHartCount[i] = 0;
					}
				}
			}
		}

		private function doDataSend(uSetID:int, uPSet:String):void
		{
			if (uSetID != -1)
			{
				var aoData_Send:Array = DataLoadSet(uSetID) as Array;
				if (aoData_Send != null)
				{
					var QUrl:String = _IWT_URL;
					QUrl +=  "?_iwt_id=" + aoData_Send[2];
					QUrl +=  "&_iwt_UA=" + aoData_Send[1];
					QUrl +=  "&jsonp=SetID" + uPSet + uSetID;
					QUrl +=  "&_iwt_p1=" + uPSet + "-" + aoData_Send[0] + "-" + aoData_Send[8];
					QUrl +=  "&_iwt_p2=" + aoData_Send[3];
					QUrl +=  "&_iwt_p3=" + aoData_Send[4] + "-" + aoData_Send[5] + "-" + aoData_Send[6] + "-" + aoData_Send[7];
					QUrl +=  "&_iwt_p4=" + encodeURI(aoData_Send[9]);
					QUrl +=  "&_iwt_p5=" + encodeURI(aoData_Send[10]);
					QUrl +=  "&r=" + int(Math.random() * 9999);//Fix IE Cache Jason 120709

					if (aoData_Send[8] < 2)
					{
						DataSaveSet(aoData_Send[0], null, null, null, -2, -2, -2, -2, aoData_Send[8]+1,aoData_Send[9],aoData_Send[10]);
					}
					else
					{
						DataSaveSet(aoData_Send[0], null, null, null, -2, -2, -2, -2, aoData_Send[8]+1,aoData_Send[9],aoData_Send[10]);
						HartSaveSet(uSetID, -1);
					}

					varLoader = new URLLoader();
					var varSend:URLRequest = new URLRequest(QUrl);
					varLoader.addEventListener(Event.COMPLETE, loaderCompleteHandler);
					varLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadersecurityError);
					varLoader.addEventListener(IOErrorEvent.IO_ERROR, loaderioError);
					varLoader.load(varSend);
					if (uPSet == "A")
					{
						DebugInfo("开始播放视频A点发送doDataSend_"+uPSet+":"+varLoader);
					}
					else if (uPSet == "B")
					{
						DebugInfo("正常结束播放B点发送doDataSend_"+uPSet+":"+varLoader);
					}
					else if (uPSet == "C")
					{
						DebugInfo("历史播放记录C点补发doDataSend_"+uPSet+":"+varLoader);
					}
				}
				else
				{
					DebugInfo("意外调用:doDataSend_"+uPSet+"|uSetID:"+uSetID);
				}
			}

		}

		private function loaderCompleteHandler(event:Event):void
		{

			var netreturn:String = varLoader.data;
			var nSetID:int,nPSet:String,nInx:int,aInx:int;
			if (netreturn != null)
			{
				//DebugInfo("netreturn:"+netreturn);
				aInx = netreturn.indexOf("SetID");
				nInx = netreturn.indexOf("(");
				if (aInx == 0 && nInx != -1)
				{
					vSessionID = netreturn.substr(nInx+2,23);
					nSetID = int(netreturn.substring(6,nInx));
					nPSet = netreturn.substr(5,1);

					DebugInfo("loaderComplete:"+netreturn+"|"+vSessionID+"|"+nSetID+"|"+nPSet);
					if (nPSet == "A")
					{
						UvidSaveSet(vSessionID);
					}
					if (nPSet == "B")
					{
						HartSaveSet(nSetID, -1);
						vSetID = -1;
					}
					if (nPSet == "C")
					{
						HartSaveSet(nSetID, -1);
					}
				}
				else
				{
					DebugInfo("异常格式的返回值 loaderComplete:"+netreturn);
				}
			}
			else
			{
				DebugInfo("异常的网络返回值 loaderComplete:"+netreturn);
			}

		}

		private function loadersecurityError(event:Event):void
		{
			DebugInfo("loadersecurityError:"+event);
		}

		private function loaderioError(event:Event):void
		{
			DebugInfo("loaderioError:"+event);
		}

		private function UvidSaveSet(uSessionID:String):void
		{
			var soUvid_Save:SharedObject;
			try
			{
				soUvid_Save = SharedObject.getLocal(_IWT_FMark+"_UV", _IWT_FDir);
			}
			catch (e:Error)
			{
				DebugInfo("创建FT_Uvid失败!"+e);
			}
			soUvid_Save.data["FT_Uvid"] = uSessionID;
			try
			{
				soUvid_Save.flush();
			}
			catch (e:Error)
			{
				DebugInfo('保存FT_Uvid出错!');
			}
			soUvid_Save = null;
		}

		private function UvidLoadSet():String
		{
			var soUvid_Load:SharedObject;
			try
			{
				soUvid_Load = SharedObject.getLocal(_IWT_FMark+"_UV", _IWT_FDir);
			}
			catch (e:Error)
			{
				DebugInfo("读取FT_Uvid失败!"+e);
			}
			if (soUvid_Load.data["FT_Uvid"] != null)
			{
				return soUvid_Load.data["FT_Uvid"];
			}
			else
			{
				return null;
			}
			soUvid_Load = null;
		}

		private function DataSaveSet(uSetID:int, uUAID:String, uSessionID:String, uVideoID:String, uTotalTime:int, uPlayTime:int, uActCount:int, uLiveHart:int, 
		 uSendCount:int, uPlayName:String, uUrl:String):void
		{
			if (uSetID != -1)
			{
				var soData_Save:SharedObject;

				try
				{
					soData_Save = SharedObject.getLocal(_IWT_FMark+"_"+uSetID, _IWT_FDir);
				}
				catch (e:Error)
				{
					DebugInfo("创建FT_Data失败!"+e);
				}
				if (soData_Save.data["FT_Data"] is Array)
				{
					soData_Save.data["FT_Data"][0] = uSetID;
					if (uUAID != null)
					{
						soData_Save.data["FT_Data"][1] = uUAID;
					}
					if (uSessionID != null)
					{
						soData_Save.data["FT_Data"][2] = uSessionID;
					}
					if (uVideoID != null)
					{
						soData_Save.data["FT_Data"][3] = uVideoID;
					}
					if (uTotalTime != -2)
					{
						soData_Save.data["FT_Data"][4] = uTotalTime;
					}
					if (uPlayTime != -2)
					{
						soData_Save.data["FT_Data"][5] = uPlayTime;
					}
					if (uActCount != -2)
					{
						soData_Save.data["FT_Data"][6] = uActCount;
					}
					if (uLiveHart != -2)
					{
						soData_Save.data["FT_Data"][7] = uLiveHart;
					}
					if (uSendCount != -2)
					{
						soData_Save.data["FT_Data"][8] = uSendCount;
					}
					if (uPlayName != null)
					{
						soData_Save.data["FT_Data"][9] = uPlayName;
					}
					if (uUrl != null)
					{
						soData_Save.data["FT_Data"][10] = uUrl;
					}
					try
					{
						soData_Save.flush();
					}
					catch (e:Error)
					{
						DebugInfo('保存FT_Data出错!');
					}
					soData_Save = null;
				}
				else
				{
					var aoData_Save:Array = new Array(9);
					aoData_Save[0] = uSetID;
					aoData_Save[1] = uUAID;
					aoData_Save[2] = uSessionID;
					aoData_Save[3] = uVideoID;
					aoData_Save[4] = uTotalTime;
					aoData_Save[5] = uPlayTime;
					aoData_Save[6] = uActCount;
					aoData_Save[7] = uLiveHart;
					aoData_Save[8] = uSendCount;
					aoData_Save[9] = uPlayName;
					aoData_Save[10] = uUrl;
					soData_Save.data["FT_Data"] = aoData_Save;
					try
					{
						soData_Save.flush();
					}
					catch (e:Error)
					{
						DebugInfo('保存FT_Data出错!');
					}
					soData_Save = null;
				}
				ShareInfo();
			}
		}

		private function DataLoadSet(uSetID:int):Array
		{
			var soData_Load:SharedObject;
			try
			{
				soData_Load = SharedObject.getLocal(_IWT_FMark+"_"+uSetID, _IWT_FDir);
			}
			catch (e:Error)
			{
				DebugInfo("读取FT_Data失败!"+e);
			}
			if (soData_Load.data["FT_Data"] is Array)
			{
				var aoData_Load:Array = soData_Load.data["FT_Data"] as Array;
				soData_Load = null;
				return aoData_Load;
			}
			else
			{
				return null;
			}
		}

		private function HartSaveSet(uSetID:int, uLiveHart:int):int
		{
			var soHart_Save:SharedObject;
			var aoHart_Save:Array;
			try
			{
				soHart_Save = SharedObject.getLocal(_IWT_FMark,_IWT_FDir);
			}
			catch (e:Error)
			{
				DebugInfo("创建FT_Hart失败!"+e);
			}

			if (soHart_Save.data["FT_Hart"] is Array)
			{
				if (uSetID != -1)
				{
					soHart_Save.data["FT_Hart"][uSetID] = uLiveHart;
					try
					{
						soHart_Save.flush();
					}
					catch (e:Error)
					{
						DebugInfo('保存FT_Hart出错!'+e);
					}
					DebugInfo('更新FT_Hart数据! uSetID:'+ uSetID + "LiveHart:"+ uLiveHart);
				}
				else
				{
					var MaxTime:int,MaxID:int,uSetID:int;
					aoHart_Save = soHart_Save.data["FT_Hart"];
					for (var i:int=0; i<aoHart_Save.length; i++)
					{
						if (aoHart_Save[i] == -1)
						{
							uSetID = i;
							break;
						}
						if (MaxTime < aoHart_Save[i])
						{
							//如果10个位置都被占用，则使用时间最长的那个位置
							MaxTime = aoHart_Save[i];
							MaxID = i;
						}
					}
					if (uSetID == -1)
					{
						uSetID = MaxID;
					}
					aoHart_Save[uSetID] = uLiveHart;
					soHart_Save.data["FT_Hart"] = aoHart_Save;
					try
					{
						soHart_Save.flush();
					}
					catch (e:Error)
					{
						DebugInfo('保存FT_Hart出错!'+e);
					}
					DebugInfo('获得新FT_Hart位置! uSetID:'+ uSetID);
				}
			}
			else
			{
				//没有存储或清空了，新用户生成对象
				aoHart_Save = new Array(_MaxSave);
				for (var j:int=0; j<aoHart_Save.length; j++)
				{
					aoHart_Save[j] = -1;
				}
				uSetID = 0;
				aoHart_Save[uSetID] = uLiveHart;
				soHart_Save.data["FT_Hart"] = aoHart_Save;
				try
				{
					soHart_Save.flush();
				}
				catch (e:Error)
				{
					DebugInfo('保存FT_Hart出错!'+e);
				}
				DebugInfo('新用户，获得新FT_Hart位置! uSetID:'+ uSetID);

			}

			soHart_Save = null;
			ShareInfo();
			return uSetID;
		}

		private function HartLoadSet():Array
		{
			var soHart_Load:SharedObject;
			try
			{
				soHart_Load = SharedObject.getLocal(_IWT_FMark,_IWT_FDir);
			}
			catch (e:Error)
			{
				DebugInfo("读取FT_Hart失败!"+e);
			}
			if (soHart_Load.data["FT_Hart"] is Array)
			{
				var aoHart_Load:Array = soHart_Load.data["FT_Hart"] as Array;
				soHart_Load = null;
				return aoHart_Load;
			}
			else
			{
				return null;
			}
		}

		private function ShareInfo():void
		{
			if (_IWT_Debug)
			{
				vShareInfo = "ShareObject:" + _IWT_FMark + ".FT_Hart\n";
				var aoHart_Info:Array = HartLoadSet();
				if (aoHart_Info != null)
				{
					for (var i:int=0; i<aoHart_Info.length; i++)
					{
						vShareInfo +=  "FT_Hart[" + i + "]=" + aoHart_Info[i] + "\n";
					}
				}

				var aoData_Info:Array;
				for (var j:int=0; j<_MaxSave; j++)
				{
					aoData_Info = DataLoadSet(j);
					if (aoData_Info != null)
					{
						vShareInfo +=  "\nShareObject:" + _IWT_FMark + ".FT_Data_" + j + "\n";
						vShareInfo +=  "FT_Data_" + j + "[0]=" + aoData_Info[0] + "\n";
						vShareInfo +=  "FT_Data_" + j + "[1]=" + aoData_Info[1] + "\n";
						vShareInfo +=  "FT_Data_" + j + "[2]=" + aoData_Info[2] + "\n";
						vShareInfo +=  "FT_Data_" + j + "[3]=" + aoData_Info[3] + "\n";
						vShareInfo +=  "FT_Data_" + j + "[4]=" + aoData_Info[4] + "\n";
						vShareInfo +=  "FT_Data_" + j + "[5]=" + aoData_Info[5] + "\n";
						vShareInfo +=  "FT_Data_" + j + "[6]=" + aoData_Info[6] + "\n";
						vShareInfo +=  "FT_Data_" + j + "[7]=" + aoData_Info[7] + "\n";
						vShareInfo +=  "FT_Data_" + j + "[8]=" + aoData_Info[8] + "\n";
						vShareInfo +=  "FT_Data_" + j + "[9]=" + aoData_Info[9] + "\n";
						vShareInfo +=  "FT_Data_" + j + "[10]=" + aoData_Info[10] + "\n";
					}
				}
			}
			else
			{
				vShareInfo = "Debug Off!";
			}
		}

		private function DebugInfo(eInfo:String):void
		{
			if (_IWT_Debug)
			{
				if (vDebugInfo.split("\n").length > 15)
				{
					vDebugInfo = vDebugInfo.substr(vDebugInfo.indexOf("\n") + 1,9999);
				}
				vDebugInfo +=  eInfo + "\n";
			}
			else
			{
				vDebugInfo = "Debug Off!";
			}
		}

	}
}