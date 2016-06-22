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
package com.acfun.comment.event
{
    import flash.events.Event;
    import com.acfun.comment.entity.SingleCommentData;
    
    public class CommentDataEvent extends Event
    {
        /** 从右往左的滚动弹幕,值为模式号的字符串 **/
        public static var FLOW_RIGHT_TO_LEFT:String = '1';
        /** 从左往右的滚动弹幕 **/
        public static var FLOW_LEFT_TO_RIGHT:String = '6';
        /** 顶部字幕 **/
        public static var TOP:String = '5';
        /** 底部字幕 **/
        public static var BOTTOM:String = '4';
        /** 固定字幕 **/
        public static var FIXED_POSITION_AND_FADE:String = '7';
        /** 脚本弹幕 **/
        public static var ECMA3_SCRIPT:String = '10';
        
        /** 清空管理者中的数据 **/
        public static var CLEAR:String = 'clear';
        
        private var _data:SingleCommentData;
        public function CommentDataEvent(type:String, data:SingleCommentData = null, bubbles:Boolean=false, cancelable:Boolean=false)
        {
            super(type, bubbles, cancelable);
            this._data = data;
        }
        
        public function get data():SingleCommentData
        {
            return this._data;
        }
    }
    
}