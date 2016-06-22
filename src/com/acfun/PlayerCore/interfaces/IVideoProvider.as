package com.acfun.PlayerCore.interfaces
{
	[Event(name="VP_INIT", type="flash.events.Event")]
	
	[Event(name="VP_PLAY_END", type="flash.events.Event")]
	
	public interface IVideoProvider
	{
		function start(startTime:Number=0):void;
		function getVideoInfo():String;
		function resize(width:Number, height:Number):void;
		function setVideoRatio(type:int):void;
		function toggleSilent(isSilent:Boolean):void;
			
		function get playing():Boolean;
		function set playing(value:Boolean):void;		
		function get volume():Number;
		function set volume(value:Number):void;
		function get time():Number;
		function set time(value:Number):void;
		function get buffTime():Number;
		function get buffPercent():Number;
		function get buffering():Boolean;
		function get loop():Boolean;
		function set loop(value:Boolean):void;
		function get videoLength():Number;	
	}
}