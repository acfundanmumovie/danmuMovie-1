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
    import com.acfun.External.ConstValue;
    import com.acfun.External.SIGNALCONST;
    import com.acfun.Utils.Log;
    import com.acfun.Utils.Util;
    import com.acfun.comment.control.CommentTime;
    import com.acfun.comment.control.manager.base.CommentManager;
    import com.acfun.comment.display.CommentView;
    import com.acfun.comment.display.FixedPosComment;
    import com.acfun.comment.entity.CommentConfig;
    import com.acfun.comment.entity.SingleCommentData;
    import com.acfun.comment.event.CommentDataEvent;
    import com.acfun.comment.interfaces.IComment;
    import com.acfun.signal.register;
    import com.adobe.utils.StringUtil;
    
    import flash.display.DisplayObject;
    import flash.display.Sprite;
    import flash.geom.PerspectiveProjection;
    import flash.geom.Point;
    import flash.geom.Rectangle;
	
    /** 评论处理 **/
    public class FixedPosCommentManager extends CommentManager
    {
		private var config:CommentConfig = CommentConfig.instance;
		
		private var clip:Sprite;		
		private var scaleClip:Sprite;		
		private var videoClip:Sprite;
		
		private var width:Number = 0;
		private var height:Number = 0;
		
		private var videoWidth:Number = ConstValue.SPECIAL_MODE_PLAYER_WIDTH;
		private var videoHeight:Number = ConstValue.SPECIAL_MODE_PLAYER_HEIGHT-ConstValue.PLAYER_SKIN_DEFAULT_HEIGHT;
		
		private const defaultRect:Rectangle = new Rectangle(0,0,ConstValue.SPECIAL_MODE_PLAYER_WIDTH,ConstValue.SPECIAL_MODE_PLAYER_HEIGHT-ConstValue.PLAYER_SKIN_DEFAULT_HEIGHT);
		
        public function FixedPosCommentManager(clip:Sprite)
        {
			FixedPosComment.xbase = 0;
			FixedPosComment.ybase = 0;
			scaleClip = new Sprite();
			scaleClip.name = "scaleClip";
//			scaleClip.opaqueBackground = 0xff0000;			
			scaleClip.graphics.lineStyle(0,0,0);
			scaleClip.graphics.drawRect(0,0,defaultRect.width,defaultRect.height);
			videoClip = new Sprite();
			videoClip.name = "videoClip";
//			videoClip.opaqueBackground = 0x00ff00;
			videoClip.graphics.lineStyle(0,0,0);
			videoClip.graphics.drawRect(0,0,defaultRect.width,defaultRect.height);
			scaleClip.addChild(videoClip);
			clip.addChild(scaleClip);
			this.clip = clip;
            super(clip);
			
			register(SIGNALCONST.VIDEO_INFO,onGetVideoInfo);
        }
		
		private function onGetVideoInfo(info:Object):void
		{
			if (info.width > 0)
			{
				Log.debug("get video info",info.width,info.height);
				videoWidth = info.width;
				videoHeight = info.height;
				var vrect:Rectangle = Util.getCenterRectangle(defaultRect,new Rectangle(0,0,videoWidth,videoHeight));
				videoClip.scrollRect = vrect;
				videoClip.x = vrect.x;
				videoClip.y = vrect.y;	
				
				resize(this.width,this.height);
			}
		}
		
		override protected function setSpaceManager():void
        {
            /** 置空 **/
        }
        override protected function setModeList():void
        {
			CommentTime.instance.mode_list.push(CommentDataEvent.FIXED_POSITION_AND_FADE);
        }
        override protected function add2Space(cmt:IComment):void
        {
            /** 置空 **/
        }
        override protected function removeFromSpace(cmt:IComment):void
        {
            /** 置空 **/
        }
        override public function getComment(data:SingleCommentData):IComment
        {
			if (isScaleComment(data))
				return new FixedPosComment(data,ConstValue.SPECIAL_MODE_PLAYER_WIDTH,ConstValue.SPECIAL_MODE_PLAYER_HEIGHT-ConstValue.PLAYER_SKIN_DEFAULT_HEIGHT);
			else
            	return new FixedPosComment(data);
        }
        override public function resize(width:Number, height:Number):void
        {
			this.width = width;
			this.height = height;
			
            if (config.spsizelock)
			{
				var w:Number = config.spwidth;
				var h:Number = config.spheight;
				if(width>w && height>h)
				{
					FixedPosComment.unlocksize = false;
					FixedPosComment.xbase = (width-w)/2;
					FixedPosComment.ybase = (height-h)/2;
					FixedPosComment.setRect(w,h);
					return;
				}
			}
			FixedPosComment.unlocksize = true;
			FixedPosComment.xbase = 0;
			FixedPosComment.ybase = 0;
			FixedPosComment.setRect(width,height);
			
			//计算缩放区域的比例和位置			
			var videoRect:Rectangle = new Rectangle(0,0,videoWidth,videoHeight);
			var rect1:Rectangle = Util.getCenterRectangle(defaultRect,videoRect);
			var rect2:Rectangle = Util.getCenterRectangle(new Rectangle(0,0,width,height),videoRect);
			scaleClip.scaleX = scaleClip.scaleY = rect2.width / rect1.width; 	//直接设置宽度会有副作用
			scaleClip.x = (width - defaultRect.width * scaleClip.scaleX) / 2;
			scaleClip.y = (height - defaultRect.height * scaleClip.scaleY) / 2;
        } 
		
		override public function start(data:SingleCommentData,from:Number=0):void
		{
			/** 在终结前不再被渲染 **/
			data.on = true;
			//高级弹幕不同版本
			var clip:Sprite = this.clip;
			if (isScaleComment(data))
			{
				if (isInVideoComment(data))
					clip = videoClip;
				else
					clip = scaleClip;	
			}
			//是否关联父容器
			var parent:FixedPosComment = getCommentByName(data.addon.parent);
			if (parent)
				clip = parent;
			
//			if (data.display == null)
//				data.display = getComment(data);
//			var cmt:IComment = data.display;
			var cmt:IComment = getComment(data);
			CommentTime.instance.addToCurrent(cmt);
			cmt.complete = function():void {
				if (cmt)
				{
					CommentTime.instance.removeFromCurrent(cmt);					
					complete(data);				
					if (DisplayObject(cmt).parent)
						DisplayObject(cmt).parent.removeChild(DisplayObject(cmt));
					commentCount --;
					cmt.complete = null;
					cmt["mask"] = null;
					//同时删除遮罩
					if (cmt.item.addon.mask)
					{
						var mask:FixedPosComment = getCommentByName(cmt.item.addon.mask);
						if (mask)
							mask.doComplete();
					}
				}
			};
			commentCount ++;
			/** 添加到舞台 **/
			for (var i:int=0;i<clip.numChildren;i++)
			{
				var child:FixedPosComment = clip.getChildAt(i) as FixedPosComment;
				if (child)
				{
					if (child.depth > cmt["depth"])
					{
						break;
					}
				}
			}
			
			//名称为mask开头的默认为遮罩
			if (!cmt.item.preview && cmt.item.name && StringUtil.beginsWith(cmt.item.name,"mask"))
				DisplayObject(cmt).visible = false;
			
			clip.addChildAt(DisplayObject(cmt),i);
			
			//是否有遮罩
			var mask:FixedPosComment = getCommentByName(data.addon.mask);
			if (mask)
			{
				mask.visible = true;
				mask.cacheAsBitmap = true;
				cmt["cacheAsBitmap"] = true;
				cmt["mask"] = mask;
			}
			
			cmt.start(from);
			if(!CommentView.instance.playing && data.border && data.addon==null)
			{
				cmt.pause();
			}
		}
		
		private function isScaleComment(s:SingleCommentData):Boolean
		{
			return s.addon["ver"] == ConstValue.SPECIAL_COMMENT_VERSION;
		}
		
		private function isInVideoComment(s:SingleCommentData):Boolean
		{
			return s.addon["ovph"];
		}
		
		private function getCommentByName(name:String):FixedPosComment
		{
			if (name != null && name != "")
			{
				for each (var s:IComment in CommentTime.instance.getCurrentComments())
				{
					if (s.item.name == name)
					{
						return s as FixedPosComment;
					}
				}				
			}
			return null;
		}
    }
}