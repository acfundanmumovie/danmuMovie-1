package com.acfun.comment.control.space
{
	import com.acfun.comment.control.space.base.CommentSpaceManager;
	import com.acfun.comment.display.ScrollComment;
	import com.acfun.comment.display.base.Comment;
	import com.acfun.comment.entity.CommentConfig;
    

    /** 滚动字幕空间管理类 **/
    public class ScrollCommentSpaceManager extends CommentSpaceManager
    {
        /** 滚动秒数,或者要速度恒定则在getSpeed中定义速度 **/
        private var duration:Number = 4.8;
        private var config:CommentConfig =  CommentConfig.instance;
		
        override public function add(cmt:Comment):void
        {
			var scmt:ScrollComment = cmt as ScrollComment;
			if (scmt)
			{
				scmt.x = this.Width;
				scmt.speed = getSpeed(scmt);
				scmt.duration = (this.Width + scmt.width) / scmt.speed;
				scmt.sendDuration = this.Width /scmt.speed;
				if(scmt.height >= this.Height)
				{
					scmt.setY(0,-1,transformY);
				}
				else 
				{
					this.setY(scmt);
				}	
			}
        }
        override public function setRectangle(w:int,h:int):void
        {
            this.Width = w - 10;//OFFSET,
            this.Height = h;
        }
        override protected function vCheck(y:int, cmt:Comment, index:int):Boolean 
        {
            var bottom:int = y + cmt.height;
            var right:int = cmt.x + cmt.width;
			var middle:Number = getMiddle(cmt as ScrollComment);			
            for each(var c:Comment in this.Pools[index])
            {
				if(c.y > bottom || y > c.bottom)					
					continue;
				else
				{
					if (c.right < cmt.x || cmt.right < c.x)
					{
						if (getEnd(c) < middle)
							continue;							
					}
					return false;
				}
            }
            return true;
        }
		
        /** 弹幕速度,未在Comment中定义是因为与弹幕空间有关 **/
        private function getSpeed(cmt:ScrollComment):Number
        {
			var speede:Number = cmt.item.isTest?config.speede2:config.speede;
			//return (config.autoResize ? 1 : CommentConfig.instance.cmtfontResize) * config.speede * (this.Width + cmt.width) / this.duration;
			return (this.Width + cmt.width) * (config.width/this.Width + 0.1) * speede / this.duration;
		}
		
        /** 弹幕结束时间 **/
        private function getEnd(cmt:Comment):Number
        {
			return cmt.stime + cmt.duration;
//            return cmt.stime + (this.Width + cmt.width) / this.getSpeed(cmt);
        }
        /** 弹幕抵左边线时间 **/
        private function getMiddle(cmt:ScrollComment):Number
        {
			return cmt.stime + this.Width / cmt.speed;
//            return cmt.stime + this.Width / this.getSpeed(cmt);
        }
    }
}