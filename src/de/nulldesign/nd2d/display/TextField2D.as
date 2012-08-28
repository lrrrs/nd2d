/*
 * ND2D - A Flash Molehill GPU accelerated 2D engine
 *
 * Author: Lars Gerckens
 * Copyright (c) nulldesign 2011
 * Repository URL: http://github.com/nulldesign/nd2d
 * Getting started: https://github.com/nulldesign/nd2d/wiki
 *
 *
 * Licence Agreement
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package de.nulldesign.nd2d.display {

	import de.nulldesign.nd2d.materials.texture.Texture2D;

	import flash.display.BitmapData;
	import flash.geom.Point;
	import flash.text.AntiAliasType;
	import flash.text.GridFitType;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * TextField2D
	 * <p>Renders a flash native textfield to a bitmap / texture.</p>
	 * Note that changing the text in the textfield will cause a complete invalidation and therefore a new texture upload to the GPU, in other words: It's slow! It's good for static text. For dynamic text try to use the BitmapFont2D
	 * @author Ryan
	 */
	public class TextField2D extends Sprite2D {

		protected var _nativeTextField:TextField = new TextField();

		protected var _textTexture:Texture2D;
		protected var _textBitmapData:BitmapData = new BitmapData(1, 1, true, 0);

		// Text Field Properties (Dynamic)
		protected var _textFormat:TextFormat = new TextFormat(null, null, 0xffffff);

		protected var _type:String = TextFieldType.DYNAMIC;
		protected var _autoSize:String = TextFieldAutoSize.LEFT;

		protected var _text:String = "";
		protected var _textWidth:Number = 0;
		protected var _textHeight:Number = 0;

		protected var _border:Boolean = false;
		protected var _borderColor:uint = 0xffffff;
		protected var _borderPadding:int = 1;
		protected var _background:Boolean = false;
		protected var _backgroundColor:uint = 0x888888;

		protected var _thickness:Number = 0;
		protected var _sharpness:Number = 0;
		protected var _gridFitType:String = GridFitType.NONE;
		protected var _antiAliasType:String = AntiAliasType.NORMAL;

		protected var _autoWrap:Boolean = true;
		protected var _wordWrap:Boolean = false;
		protected var _embedFonts:Boolean = false;
		protected var _condenseWhite:Boolean = false;

		// TODO: Text Field Properties (Input)
		//protected var _restrict:String = null;
		//protected var _maxChars:uint = 0;
		//protected var _multiline:Boolean = false;
		//protected var _displayAsPassword:Boolean = false;

		// Flags
		protected var _needsRedraw:Boolean = true;

		// Accessors (TextField)
		public function get length():int {
			return _text.length;
		}

		public function get textFormat():TextFormat {
			return _textFormat;
		}

		public function set textFormat(v:TextFormat):void {
			_textFormat = v;
			_needsRedraw = true;
		}

		public function get type():String {
			return _type;
		}

		public function set type(v:String):void {
			_type = v;
			// TODO: Allow switching back and forth from dynamic text to input text?
			_needsRedraw = true;
		}

		public function get autoSize():String {
			return _autoSize;
		}

		public function set autoSize(v:String):void {
			_autoSize = v;
			_needsRedraw = true;
		}

		public function get text():String {
			return _text;
		}

		public function set text(v:String):void {
			_text = v;
			_needsRedraw = true;
		}

		public function get textColor():uint {
			return uint(_textFormat.color);
		}

		public function set textColor(v:uint):void {
			_textFormat.color = v;
			_needsRedraw = true;
		}

		public function get textWidth():int {
			return _textWidth;
		}

		public function set textWidth(v:int):void {
			_textWidth = Math.max(0, v);

			if(_autoWrap)
				_wordWrap = _textWidth > 0;

			_needsRedraw = true;
		}

		public function get textHeight():int {
			return _textHeight;
		}

		public function set textHeight(v:int):void {
			_textHeight = Math.max(0, v);
			_needsRedraw = true;
		}

		public function get border():Boolean {
			return _border;
		}

		public function set border(v:Boolean):void {
			_border = v;
			_needsRedraw = true;
		}

		public function get borderColor():uint {
			return _borderColor;
		}

		public function set borderColor(v:uint):void {
			_borderColor = v;
			_needsRedraw = true;
		}

		public function get background():Boolean {
			return _background;
		}

		public function set background(v:Boolean):void {
			_background = v;
			_needsRedraw = true;
		}

		public function get backgroundColor():uint {
			return _backgroundColor;
		}

		public function set backgroundColor(v:uint):void {
			_backgroundColor = v;
			_needsRedraw = true;
		}

		public function get wordWrap():Boolean {
			return _wordWrap;
		}

		public function set wordWrap(v:Boolean):void {
			_wordWrap = v;
			_needsRedraw = true;
		}

		public function get embedFonts():Boolean {
			return _embedFonts;
		}

		public function set embedFonts(v:Boolean):void {
			_embedFonts = v;
			_needsRedraw = true;
		}

		public function get condenseWhite():Boolean {
			return _condenseWhite;
		}

		public function set condenseWhite(v:Boolean):void {
			_condenseWhite = v;
			_needsRedraw = true;
		}

		// Accessors (TextFormat)
		public function get font():String {
			return _textFormat.font;
		}

		public function set font(v:String):void {
			_textFormat.font = v;
			_needsRedraw = true;
		}

		public function get size():Object {
			return _textFormat.size;
		}

		public function set size(v:Object):void {
			_textFormat.size = v;
			_needsRedraw = true;
		}

		public function get align():String {
			return _textFormat.align;
		}

		public function set align(v:String):void {
			_textFormat.align = v;
			_needsRedraw = true;
		}

		public function get bold():Boolean {
			return _textFormat.bold;
		}

		public function set bold(v:Boolean):void {
			_textFormat.bold = v;
			_needsRedraw = true;
		}

		public function get italic():Boolean {
			return _textFormat.italic;
		}

		public function set italic(v:Boolean):void {
			_textFormat.italic = v;
			_needsRedraw = true;
		}

		public function get underline():Boolean {
			return _textFormat.underline;
		}

		public function set underline(v:Boolean):void {
			_textFormat.underline = v;
			_needsRedraw = true;
		}

		public function get filters():Array {
			return _nativeTextField.filters;
		}

		public function set filters(v:Array):void {
			_nativeTextField.filters = v;
			_needsRedraw = true;
		}

		public function TextField2D() {
			super(Texture2D.textureFromBitmapData(_textBitmapData));
		}

		public function redraw():void {

			// Set text field properties.
			_nativeTextField.defaultTextFormat = _textFormat;
			_nativeTextField.htmlText = _text;

			_nativeTextField.border = _border;
			_nativeTextField.borderColor = _borderColor;
			_nativeTextField.background = _background;
			_nativeTextField.backgroundColor = _backgroundColor;

			_nativeTextField.thickness = _thickness;
			_nativeTextField.sharpness = _sharpness;
			_nativeTextField.gridFitType = _gridFitType;
			_nativeTextField.antiAliasType = _antiAliasType;

			_nativeTextField.type = _type;
			_nativeTextField.autoSize = _autoSize;
			_nativeTextField.wordWrap = _wordWrap;
			_nativeTextField.embedFonts = _embedFonts;
			_nativeTextField.condenseWhite = _condenseWhite;

			// Adjust native text field width and height.
			_nativeTextField.width = _textWidth > 0 ? _textWidth : _nativeTextField.textWidth;
			_nativeTextField.height = _textHeight > 0 ? _textHeight : _nativeTextField.textHeight;

			switch(_type) {
				case TextFieldType.DYNAMIC:

					// Draw textfield onto bitmap data.
					_textBitmapData = new BitmapData(
							_nativeTextField.width + _borderPadding,
							_nativeTextField.height + _borderPadding,
							true,
							0
					);
					_textBitmapData.draw(_nativeTextField);

					_textTexture = Texture2D.textureFromBitmapData(_textBitmapData);
					setTexture(_textTexture);

					// Set pivot to top left corner because it's better for laying out text than a center pivot point.
					// NOTE: Rounding with int() because blurryness can occur if x/y values for pivot are not whole numbers.
					switch(align) {
						case TextFormatAlign.LEFT:
							pivot = new Point(int(-_nativeTextField.width / 2), /*int(-_nativeTextField.height / 2)*/ 0.0);
							break;
						case TextFormatAlign.CENTER:
							pivot = new Point(0.0, /*int(-_nativeTextField.height / 2)*/ 0.0);
							break;
						case TextFormatAlign.RIGHT:
							pivot = new Point(int(_nativeTextField.width / 2), /*int(-_nativeTextField.height / 2)*/ 0.0);
							break;
					}

					break;

				// Since you can't select or input text in Stage3D, we "simulate" an input text field by
				// adding a native TextField to the regular stage where the TextField2D would be located.
				case TextFieldType.INPUT:
					// TODO: Draw native text field on stage.
					break;

				default:
					throw new Error("The type specified is not a member of flash.text.TextFieldType");
					break;
			}

			_needsRedraw = false;
		}

		override protected function step(elapsed:Number):void {
			if(_needsRedraw) {
				redraw();
			}

			// TODO: If type is INPUT we need to update the native text field position relative to this x/y.

			super.step(elapsed);
		}

		override public function dispose():void 
		{
			if(_textTexture)
			{
				_textTexture.dispose();
				_textTexture = null;
			}

			if(_textBitmapData)
			{
				_textBitmapData.dispose();
				_textBitmapData = null;
			}

			super.dispose();
		}
	}
}