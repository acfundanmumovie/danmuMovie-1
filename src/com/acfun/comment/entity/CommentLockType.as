package com.acfun.comment.entity
{
	public class CommentLockType
	{
		/** isLock非会员 **/
		public static const UNACUSER_TYPE:int = 0;
		/** isLock锁定 **/
		public static const LOCK_TYPE:int = 1;
		/** isLock会员 **/
		public static const ACUSER_TYPE:int = 2;
		/** isLock合作 **/
		public static const COOP_TYPE:int = 3;
		
		public function CommentLockType()
		{
		}
	}
}