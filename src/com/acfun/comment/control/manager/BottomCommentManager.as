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
    import com.acfun.comment.control.space.BottomCommentSpaceManager;
    import com.acfun.comment.control.space.base.CommentSpaceManager;
    
    import flash.display.Sprite;

    /** 底部字幕管理者 **/
    public class BottomCommentManager extends CommentManager
    {
        /** 构造函数 **/
        public function BottomCommentManager(clip:Sprite)
        {
            super(clip);
        }
        /**
         * 设置空间管理者
         **/
        override protected function setSpaceManager():void
        {
			this.space_manager = CommentSpaceManager(new BottomCommentSpaceManager());
        }
        /**
         * 设置要监听的模式
         **/
        override protected function setModeList():void
        {
			CommentTime.instance.mode_list.push(CommentDataEvent.BOTTOM);
        }
    }
}