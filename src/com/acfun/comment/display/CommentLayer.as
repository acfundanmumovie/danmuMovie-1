package com.acfun.comment.display
{
	import com.acfun.External.ConstValue;
	import com.acfun.External.PARAM;
	import com.acfun.comment.control.CommentTime;
	import com.acfun.comment.entity.SingleCommentData;
	import com.acfun.comment.interfaces.IComment;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	public class CommentLayer extends Sprite
	{
		public var normal:Sprite;
		
		public var special:Sprite;
		
		public function CommentLayer()
		{
			normal = new Sprite();
			normal.name = "normalClip";
			normal.mouseEnabled = normal.mouseChildren = false;
			
			special = new Sprite();
			special.name = "specialClip";
			special.mouseChildren = false;
			ConstValue.STAGE.addEventListener(MouseEvent.CLICK,urlaction);
			
			this.addChild(special);
			this.addChild(normal);
		}
		
		private function urlaction(e:MouseEvent):void
		{
			var p:Point = new Point(mouseX,mouseY);
			for each (var comment:IComment in CommentTime.instance.getCurrentComments())
			{
				if (comment is FixedPosComment &&  (comment as FixedPosComment).hitTestPoint(mouseX,mouseY))
				{
					var url:String = comment.item.url;
					if (url && url.match(/[\d_,]+/))
					{
						var a:Array = url.split(",");
						var requestUrl:String = PARAM.host + "/v/ac" + a[0];
						var window:String = "_blank";
						if (a.length > 1)
						{
							if (a[1] == "1")
								window = "_top";
						}
						navigateToURL(new URLRequest(requestUrl),window);
						e.stopImmediatePropagation();
						return;
					}	
				}
			}
		}
	}
}