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
    import com.acfun.External.SIGNALCONST;
    import com.acfun.comment.display.base.Comment;
    import com.acfun.comment.entity.SingleCommentData;
    import com.acfun.signal.notify;
    import com.greensock.TweenLite;
    import com.greensock.easing.Linear;
    
    import flash.utils.setTimeout;

    /** 滚动字幕类 **/
    public class ScrollComment extends Comment
    {
		/** 速度 **/
		public var speed:Number;
        /** 动画对象 **/
        protected var _tw:TweenLite;
        
        /** 构造函数 **/
        public function ScrollComment(data:SingleCommentData)
        {
            super(data);
        }
        
        /**
         * 开始播放
         * 从当前位置(已经在滚动空间管理类中设置)滚动到-this.width
         */
        override public function start(from:Number=0):void
        {
           _tw = new TweenLite(this,duration,{x:-width,onComplete:completeHandler,ease:Linear.easeInOut});

            _tw.play();
			setTimeout(sendComment,sendDuration * 1000);
        }
		public function sendComment():void{
			notify(SIGNALCONST.SEND_COMMENT,item);
//			CommentTime.instance.start(item);
		}
		
		override public function setY(py:int, idx:int, trans:Function):void
		{
			super.setY(py,idx,trans);
		}
		
        /**
         * 结束事件监听
         */
		override public function completeHandler():void
        {
            _complete();
			
            _tw.kill();
//			_tw = null;
        }
		
        /**
         * 恢复播放
         */
        override public function resume():void{_tw.resume();}
        /**
         * 暂停
         */
        override public function pause():void{_tw.pause();}        
        override public function doComplete():void{completeHandler();}

    }
}