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
package com.acfun.comment.control.manager
{
    import com.acfun.comment.control.CommentTime;
    import com.acfun.comment.event.CommentDataEvent;
    import com.acfun.comment.control.manager.base.CommentManager;
    import com.acfun.comment.control.space.base.CommentSpaceManager;
    import com.acfun.comment.control.space.ScrollCommentSpaceManager;
    
    import flash.display.Sprite;
    import com.acfun.comment.entity.SingleCommentData;
    import com.acfun.comment.interfaces.IComment;
    import com.acfun.comment.display.ScrollComment;

    /** 滚动字幕管理 **/
    public class ScrollCommentManager extends CommentManager
    {
        public function ScrollCommentManager(clip:Sprite)
        {
            super(clip);
        }
		
        /**
         * 设置空间管理者
         **/
		override protected function setSpaceManager():void
        {
			this.space_manager = CommentSpaceManager(new ScrollCommentSpaceManager());
			return;
        }
		
        /**
         * 设置要监听的模式
         **/
		override protected function setModeList():void
        {
			CommentTime.instance.mode_list.push(CommentDataEvent.FLOW_RIGHT_TO_LEFT);
			return;
        }
		
        /**
         * 获取弹幕对象
         * @param	data 弹幕数据
         * @return 弹幕呈现方法对象
         */
		override public function getComment(data:SingleCommentData):IComment
        {
			return IComment(new ScrollComment(data));
        }
    }
}