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

    import com.acfun.comment.entity.SingleCommentData;
    import com.greensock.TweenLite;
    import com.greensock.easing.Linear;
    
    import flash.utils.setTimeout;
    
    /** 反向滚动弹幕 **/
    public class RScrollComment extends ScrollComment
    {
        public function RScrollComment(data:SingleCommentData)
        {
            super(data);
        }
        /**
         * 开始播放
         * 从当前位置(已经在滚动空间管理类中设置)滚动到-this.width
         */
        override public function start(from:Number=0):void
        {
            //this.x = -width;
            var len:Number = this.x;
            this.x = -width + 10;
            _tw = new TweenLite(this,duration,{x:len + 10,onComplete:completeHandler,ease:Linear.easeNone});
            _tw.resume();
			setTimeout(sendComment,sendDuration * 1000);
        }
    }
}