package com.acfun.test
{
	import com.riaidea.text.RichTextField;
	
	import flash.display.Sprite;
	import flash.text.TextFormat;

	public class CommentBox extends Sprite
	{
		//private var _containerBox:Sprite;
		//var result:Number = bcs - int(bcs / cs) * cs;//取余数，运算小； %运算大
		private var smilesArray:Array= [new Lianmeng(),new Buluo(),new Gif1()];//表情包
		public static var _dmBox:Sprite;
		private  static var _instance:CommentBox;
		
		public function CommentBox()
		{
			//container()
		}
		
		public static function get instance():CommentBox
		{
			if(_instance ==null){_instance = new CommentBox();};
			return _instance;
		}
		
		public function container(smileSprite:Sprite=null,font:String= "微软雅黑,SimHei,",size:Number = 50,color:int =0xffffff,bold:Boolean = true,broder:int= -1,str:String="测试",useBitmap:Boolean=false):void
		{	
			/////////////////
			
			var rtf:RichTextField = new RichTextField();
			////设置rtf的类型
			rtf.type = RichTextField.DYNAMIC;
			////设置rtf的默认文本格式
			rtf.defaultTextFormat = new TextFormat(font, size, color,bold);
			//rtf.append(str)
			var testSprite:Sprite = smileSprite;//smilesArray[2]
			testSprite.scaleX = testSprite.scaleY =.3
			rtf.append(str, [ { index:1, src:testSprite }])
			//
			rtf.setSize(rtf._textRenderer.textWidth+10, rtf._textRenderer.textHeight);
			rtf.x = Math.random() *1000;rtf.y = Math.random() *1000
			if(_dmBox){
				trace("--getBox")
				_dmBox.addChild(rtf);
			}
			//trace("--addRichText")
			/////////////////////////////
			//过滤空弹幕
			/*if (text.search(/^\s*$/) == 0){
				trace(null)
				return;
			}*/
				
			/*var myArray:Array = ["a"]
			var records:Array = new Array();
			records.push({name1:"john", city:"omaha", zip:68144,length:myArray.length});
			records.push({name1:"john", city:"kansas city", zip:72345,length:myArray.length});
			records.push({name1:"bob", city:"omaha", zip:94010,length:myArray.length});
			// trace(records);
			
			for(var i:uint = 0; i < records.length; i++) {
				//trace(records[i].name1 + ", " + records[i].city);
			}
			// 输出:
			// john, omaha
			// john, kansas city
			// bob, omaha
			
			// trace("records.sortOn('name', 'city');");
			records.sortOn(["name1", "city"]);
			for(var j:uint = 0; j < records.length; j++) {
				myArray.push("a")
				trace("myArray.length:"+myArray.length)
				trace(records[j].name1 + ", " + records[j].city+","+records[j].length);
			}*/
			// Results:
			// bob, omaha
			// john, kansas city
			// john, omaha

		}
	}
}