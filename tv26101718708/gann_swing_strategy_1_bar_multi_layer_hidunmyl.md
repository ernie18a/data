# Gann Swing Strategy [1 Bar - Multi Layer]

- url: https://www.tradingview.com/script/hiduNmYl-Gann-Swing-Strategy-1-Bar-Multi-Layer/
- type: strategy
- pine_id: PUB;9fb814f0d9244206a755b1f8ac7cad33
- version: 1.0

## Description

Use this Strategy to Fine-tune inputs for your Gann swing strategy.

Strategy allows you to fine-tune the indicator for 1 TimeFrame at a time; cross Timeframe Input fine-tuning is done manually after exporting the chart data.


[b]MEANINGFUL DESCRIPTION:
[/b]
The Gann Swing Chart using the One-Bar type, also known as the Minor Trend Chart, is designed to follow single-bar movements in the market. It helps identify trends by tracking price movements. When the market makes a higher high than the previous bar from a low price, the One-Bar trend line moves up, indicating a new high and establishing the previous low as a One-Bar bottom. Conversely, when the market makes a lower low than the previous bar from a high price, the One-Bar swing line moves down, marking a new low and setting the previous high as a One-Bar top. The crossing of these swing tops and bottoms indicates a change in trend direction.


[b]HOW TO USE THE INDICATOR / Gann-swing Strategy:
[/b]
The indicator shows 1, 2, and 3-bar swings. The strategy triggers a buy when the price crosses the previously determined high.


[b]HOW TO USE THE STRATEGY:
[/b]
Strategy to Fine-Tune Inputs for Your Gann Swing Strategy
This strategy allows for the fine-tuning of indicators for one timeframe at a time. Cross-timeframe input fine-tuning is done manually after exporting the chart data.

[b]Meaningful Description:
[/b]The Gann Swing Chart using the One-Bar type, also known as the Minor Trend Chart, is designed to follow single-bar movements in the market. It helps identify trends by tracking price movements. When the market makes a higher high than the previous bar from a low price, the One-Bar trend line moves up, indicating a new high and establishing the previous low as a One-Bar bottom. Conversely, when the market makes a lower low than the previous bar from a high price, the One-Bar swing line moves down, marking a new low and setting the previous high as a One-Bar top. The crossing of these swing tops and bottoms indicates a change in trend direction.

[b]How to Use the Indicator / Gann-Swing Strategy:
[/b]The indicator shows 1, 2, and 3-bar swings. The strategy triggers a buy when the price crosses the previously determined high.

[b]How to Use the Strategy:
[/b]The strategy initiates a buy if the price breaks 1, 2, or 3-bar highs, or any combination thereof. Use the inputs to determine which highs or lows need to be crossed for the strategy to go long or short.

[b]ORIGINALITY & USEFULNESS:
[/b]The One-Bar Swing Chart stands out for its simplicity and effectiveness in capturing minor market trends. Developed by meomeo105, this Gann high and low algorithm forms the basis of the strategy. I used my approach to creating  strategy out of Gann swing indicator.


[b]DETAILED DESCRIPTION:
[/b]
[b]What is a Swing Chart?
[/b]
Swing charts help traders visualize price movements and identify trends by focusing on price highs and lows. They are instrumental in spotting trend reversals and continuations.


[image]https://www.tradingview.com/x/Do3LsYLU/[/image]

[b]What is the One-Bar Swing Chart?
[/b]
The One-Bar Swing Chart, also known as the Minor Trend Chart, follows single-bar price movements. It plots upward swings from a low price when a higher high is made, and downward swings from a high price when a lower low is made.

[b]Key Features:
[/b]
[b]Trend Identification[/b]: Highlights minor trends by plotting swing highs and lows based on one-bar movements.

[b]Simple Interpretation[/b]: Crossing a swing top indicates an uptrend, while crossing a swing bottom signals a downtrend.

[b]Customizable Periods[/b]: Users can adjust the period to fine-tune the sensitivity of the swing chart to market movements.

[b]Practical Application:
[/b]
[b]Bullish Trend[/b]: When the One-Bar Swing line moves above a previous swing top, it indicates a bullish trend.

[b]Bearish Trend[/b]: When the One-Bar Swing line moves below a previous swing bottom, it signals a bearish trend.

[b]Trend Reversal[/b]: Watch for crossings of swing tops and bottoms to detect potential trend reversals.

[image]https://www.tradingview.com/x/nAivYHLb/[/image]

The One-Bar Swing Chart is a powerful tool for traders looking to capture and understand market trends. By following the simple rules of swing highs and lows, it provides clear and actionable insights into market direction.

[b]Why the Strategy Uses 100% Allocation of a Portfolio:
[/b]This strategy allocates 100% of the portfolio to trading this specific pair, which does not mean 100% of all capital but 100% of the allocated trading capital for this pair. The strategy is swing-based and does not use take profit (TP) or stop losses.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © AutomatedTradingAlgorithms
//  Credit to meomeo105 for writing the gann swing part 

//@version=5
strategy('Gann Swing Strategy [1 Bar - Multi Layer]', shorttitle='GSC strat[1B-ML]', overlay=true, max_lines_count=500, default_qty_type ="percent_of_equity" , default_qty_value = 100, max_boxes_count = 500, max_labels_count = 500)

DefaultGannMLSetting = "[Gann][SGann][Color][ChoCh Gann][ChoCh SGann]"
showF1GannML = true // input.bool(true,"", group = DefaultGannMLSetting,inline = "showF1GannML")
showSF1GannML = true // input.bool(true,"F1", group = DefaultGannMLSetting,inline = "showF1GannML")
colorF1GannML = input.color(color.aqua, '', group = DefaultGannMLSetting,inline = "showF1GannML")
showChoChF1GannML = input.bool(true,"", group = DefaultGannMLSetting,inline = "showF1GannML")
showChoChSF1GannML = input.bool(true,"", group = DefaultGannMLSetting,inline = "showF1GannML")

showF2GannML = true // input.bool(true,"", group = DefaultGannMLSetting,inline = "showF2GannML")
showSF2GannML = true // input.bool(true,"F2", group = DefaultGannMLSetting,inline = "showF2GannML")
colorF2GannML = input.color(color.yellow, '', group = DefaultGannMLSetting,inline = "showF2GannML")
showChoChF2GannML = input.bool(true,"", group = DefaultGannMLSetting,inline = "showF2GannML")
showChoChSF2GannML = input.bool(false,"", group = DefaultGannMLSetting,inline = "showF2GannML")

showF3GannML = true // input.bool(true,"", group = DefaultGannMLSetting,inline = "showF3GannML")
showSF3GannML = true // input.bool(true,"F3", group = DefaultGannMLSetting,inline = "showF3GannML")
colorF3GannML = input.color(color.purple, '', group = DefaultGannMLSetting,inline = "showF3GannML")
showChoChF3GannML = input.bool(false,"", group = DefaultGannMLSetting,inline = "showF3GannML")
showChoChSF3GannML = input.bool(false,"", group = DefaultGannMLSetting,inline = "showF3GannML")


//  Credit to meomeo105 for writing the gann swing part 

f_CalculateF0(_pointX,_pointY,arrayX0,arrayY0)=>
	array.unshift(arrayX0,_pointX)
	array.unshift(arrayY0,_pointY)
	[1]

f_CalculateFn1(_pointX,_pointY,arrayXn,arrayYn,arrayXFn1,arrayYFn1)=>
	//_resultdraw 2:Tiếp tục 1:Đảo chiều
	int _resultdraw = 0
	//OSB pha dinh/day
	if((array.get(arrayYFn1,0) >= array.get(arrayYFn1,1) and array.get(arrayYn,0) < array.get(arrayYFn1,1)) or (array.get(arrayYFn1,0) <= array.get(arrayYFn1,1) and array.get(arrayYn,0) > array.get(arrayYFn1,1)))
		array.unshift(arrayXFn1,_pointX)
	    array.unshift(arrayYFn1,_pointY)
		_resultdraw := 1
	//Dao chieu sang giam
	else if(array.get(arrayYFn1,0) >= array.get(arrayYFn1,1) and (array.get(arrayYn,0) < array.get(arrayYn,1) and array.get(arrayYn,0) < array.get(arrayYn,2) and array.get(arrayYn,1) < array.get(arrayYn,3)) and array.get(arrayYn,2) < array.get(arrayYn,3))
		array.unshift(arrayXFn1,_pointX)
	    array.unshift(arrayYFn1,_pointY)
		_resultdraw := 1
	//Dao chieu sang tang
	else if(array.get(arrayYFn1,0) <= array.get(arrayYFn1,1) and (array.get(arrayYn,0) > array.get(arrayYn,1) and array.get(arrayYn,0) > array.get(arrayYn,2) and array.get(arrayYn,1) > array.get(arrayYn,3)) and array.get(arrayYn,2) > array.get(arrayYn,3))
		array.unshift(arrayXFn1,_pointX)
	    array.unshift(arrayYFn1,_pointY)
		_resultdraw := 1
	else if(array.get(arrayYFn1,0) >= array.get(arrayYFn1,1) and _pointY >= array.get(arrayYFn1,0) and (_pointY >= array.get(arrayYFn1,0) or (array.get(arrayYn,0) > array.get(arrayYn,2) and array.get(arrayYn,2) > array.get(arrayYn,1)) or (array.get(arrayYn,0) > array.get(arrayYn,1) and array.get(arrayYn,1) > array.get(arrayYn,2) and array.get(arrayYn,2) > array.get(arrayYn,3))))
		array.set(arrayXFn1, 0, _pointX)
		array.set(arrayYFn1, 0, _pointY)
		_resultdraw := 2
	else if(array.get(arrayYFn1,0) <= array.get(arrayYFn1,1) and _pointY <= array.get(arrayYFn1,0) and (_pointY <= array.get(arrayYFn1,0) or (array.get(arrayYn,0) < array.get(arrayYn,2) and array.get(arrayYn,2) < array.get(arrayYn,1)) or (array.get(arrayYn,0) < array.get(arrayYn,1) and array.get(arrayYn,1) < array.get(arrayYn,2) and array.get(arrayYn,2) < array.get(arrayYn,3))))
		array.set(arrayXFn1, 0, _pointX)
		array.set(arrayYFn1, 0, _pointY)
		_resultdraw := 2
	[_resultdraw]

f_CalculateSFn1(_pointX,_pointY,_arrayMark,_mIdxMark,arraySXFn1,arraySYFn1)=>
	int _resultdraw = 0
	if(array.get(_arrayMark,_mIdxMark) == 0)
		if((array.get(arraySYFn1,0) >= array.get(arraySYFn1,1) and _pointY >= array.get(arraySYFn1,0)) or (array.get(arraySYFn1,0) <= array.get(arraySYFn1,1) and _pointY <= array.get(arraySYFn1,0)))
			array.set(arraySXFn1, 0, _pointX)
			array.set(arraySYFn1, 0, _pointY)
			_resultdraw := 2
		else if((array.get(arraySYFn1,0) >= array.get(arraySYFn1,1) and _pointY < array.get(arraySYFn1,1)) or (array.get(arraySYFn1,0) <= array.get(arraySYFn1,1) and _pointY > array.get(arraySYFn1,1)))
			array.unshift(arraySXFn1,_pointX)
			array.unshift(arraySYFn1,_pointY)
			_resultdraw := 1
		else if((array.get(arraySYFn1,0) >= array.get(arraySYFn1,1) and _pointY < array.get(arraySYFn1,0) and _pointY > array.get(arraySYFn1,1)) or (array.get(arraySYFn1,0) <= array.get(arraySYFn1,1) and _pointY > array.get(arraySYFn1,0) and _pointY < array.get(arraySYFn1,1)))
			array.unshift(arraySXFn1,_pointX)
			array.unshift(arraySYFn1,_pointY)
			array.set(_arrayMark,_mIdxMark,_pointY)
			_resultdraw := 1
	else if(array.get(_arrayMark,_mIdxMark) > 0)
		if((array.get(arraySYFn1,0) >= array.get(arraySYFn1,1) and _pointY < array.get(arraySYFn1,1)) or (array.get(arraySYFn1,0) <= array.get(arraySYFn1,1) and _pointY > array.get(arraySYFn1,1)))
			array.unshift(arraySXFn1,_pointX)
			array.unshift(arraySYFn1,_pointY)
			array.set(_arrayMark,_mIdxMark,0)
			_resultdraw := 1
		else if((array.get(arraySYFn1,0) >= array.get(arraySYFn1,1) and _pointY > array.get(arraySYFn1,2)) or (array.get(arraySYFn1,0) <= array.get(arraySYFn1,1) and _pointY < array.get(arraySYFn1,2)))
			array.set(arraySXFn1, 0, _pointX)
			array.set(arraySYFn1, 0, _pointY)
			array.set(_arrayMark,_mIdxMark,0)
			_resultdraw := 2
		else if((array.get(arraySYFn1,0) >= array.get(arraySYFn1,1) and _pointY <= array.get(arraySYFn1,2) and _pointY >= array.get(arraySYFn1,0)) or (array.get(arraySYFn1,0) <= array.get(arraySYFn1,1) and _pointY >= array.get(arraySYFn1,2) and _pointY <= array.get(arraySYFn1,0)))
			array.set(arraySXFn1, 0, _pointX)
			array.set(arraySYFn1, 0, _pointY)
			array.set(_arrayMark,_mIdxMark,_pointY)
			_resultdraw := 2

	[_resultdraw]

f_CalculateRemoveDuplicateLine(arrayLine,arraySLine)=>
	if(array.size(arraySLine) > 1 and array.size(arrayLine) >1)
		if(line.get_y1(array.get(arraySLine,1)) == line.get_y1(array.get(arrayLine,1)) and line.get_y2(array.get(arraySLine,1)) == line.get_y2(array.get(arrayLine,1))and line.get_x1(array.get(arraySLine,1)) == line.get_x1(array.get(arrayLine,1)) and line.get_x2(array.get(arraySLine,1)) == line.get_x2(array.get(arrayLine,1)))
			line.delete(array.get(arrayLine,1))
			array.remove(arrayLine,1)

f_CalculateChoCh(arraySXFn1,arraySYFn1) =>
	int _X = 0
	float _Y = 0
	// ChoCh Trường hợp chữ N ngược, chữ N
	if((array.get(arraySYFn1,3) > array.get(arraySYFn1,2) and array.get(arraySYFn1,3) < array.get(arraySYFn1,1) and array.get(arraySYFn1,0) < array.get(arraySYFn1,2)) or (array.get(arraySYFn1,3) < array.get(arraySYFn1,2) and array.get(arraySYFn1,3) > array.get(arraySYFn1,1) and array.get(arraySYFn1,0) > array.get(arraySYFn1,2)))
		_X := array.get(arraySXFn1,2)
		_Y := array.get(arraySYFn1,2)
	[_X,_Y]

f_CalculateDrawF(_drawF,_showSF,arrayLine,arrayX,arrayY,showChoCh,arrayMChoCh,idxChoCh,_color) =>
	if(_drawF > 0)
		if(_drawF == 1)
			array.unshift(arrayLine,line.new(array.get(arrayX,1),array.get(arrayY,1),array.get(arrayX,0),array.get(arrayY,0), color = _color,xloc = xloc.bar_time,width = 1,style = line.style_dotted))
		else if(_drawF == 2 and array.size(arrayLine) >0)
			line.set_xy2(array.get(arrayLine,0),array.get(arrayX,0),array.get(arrayY,0))
		[XChoCh,YChoCh] = f_CalculateChoCh(arrayX,arrayY)
		if(showChoCh and YChoCh >0 and array.get(arrayMChoCh,idxChoCh) != YChoCh)
			array.set(arrayMChoCh,idxChoCh,YChoCh)
			line.new(XChoCh,YChoCh,time,YChoCh, color = _color,xloc = xloc.bar_time,width = 1,style = line.style_dotted)
	
f_CalculateDrawSF(_drawSF,arrayLine,arraySLine,arraySX,arraySY,showChoCh,arrayMChoCh,idxChoCh,_color) =>
	if(_drawSF > 0)
		if(_drawSF == 1)
			array.unshift(arraySLine,line.new(array.get(arraySX,1),array.get(arraySY,1),array.get(arraySX,0),array.get(arraySY,0), color = _color,xloc = xloc.bar_time,width = 1))
		else if(_drawSF == 2 and array.size(arraySLine) >0)
			line.set_xy2(array.get(arraySLine,0),array.get(arraySX,0),array.get(arraySY,0))
		f_CalculateRemoveDuplicateLine(arrayLine,arraySLine)
		[XChoChS,YChoChS] = f_CalculateChoCh(arraySX,arraySY)
		if(showChoCh and YChoChS >0 and array.get(arrayMChoCh,idxChoCh) != YChoChS)
			array.set(arrayMChoCh,idxChoCh,YChoChS)
			line.new(XChoChS,YChoChS,time,YChoChS, color = _color,xloc = xloc.bar_time,width = 1,style = line.style_dashed)

var arrayMarkGannML = array.new_float(3,0)
var arrayMarkChoChGannML = array.new_float(6,0)
var arrayXF0GannML = array.new_int(5,time)
var arrayYF0GannML = array.new_float(5,close)
var arrayXF1GannML = array.new_int(5,time)
var arrayYF1GannML = array.new_float(5,close)
var arrayLineF1GannML = array.new_line()
var arraySXF1GannML = array.new_int(5,time)
var arraySYF1GannML = array.new_float(5,close)
var arraySLineF1GannML = array.new_line()
var arrayXF2GannML = array.new_int(5,time)
var arrayYF2GannML = array.new_float(5,close)
var arrayLineF2GannML = array.new_line()
var arraySXF2GannML = array.new_int(5,time)
var arraySYF2GannML = array.new_float(5,close)
var arraySLineF2GannML = array.new_line()
var arrayXF3GannML = array.new_int(5,time)
var arrayYF3GannML = array.new_float(5,close)
var arrayLineF3GannML = array.new_line()
var arraySXF3GannML = array.new_int(5,time)
var arraySYF3GannML = array.new_float(5,close)
var arraySLineF3GannML = array.new_line()
f_CalculateAndDrawFn1(_pointX,_pointY) =>
	//F0 : Song cua nen
	array.unshift(arrayXF0GannML,_pointX)
	array.unshift(arrayYF0GannML,_pointY)
	//F1,F2,...: Song cua song theo Gann
	if(showF1GannML or showF2GannML or showF3GannML or showSF1GannML or showSF2GannML or showSF3GannML)
		[drawF1] = f_CalculateFn1(_pointX,_pointY,arrayXF0GannML,arrayYF0GannML,arrayXF1GannML,arrayYF1GannML)
		f_CalculateDrawF(showF1GannML?drawF1:0,showSF1GannML,arrayLineF1GannML,arrayXF1GannML,arrayYF1GannML,showChoChF1GannML,arrayMarkChoChGannML,0,colorF1GannML)
		if(drawF1 > 0 and (showF2GannML or showF3GannML or showSF1GannML or showSF2GannML or showSF3GannML))
			[drawSF1] = f_CalculateSFn1(_pointX,_pointY,arrayMarkGannML,0,arraySXF1GannML,arraySYF1GannML)
			f_CalculateDrawSF(showSF1GannML?drawSF1:0,arrayLineF1GannML,arraySLineF1GannML,arraySXF1GannML,arraySYF1GannML,showChoChSF1GannML,arrayMarkChoChGannML,1,colorF1GannML)
			if(drawSF1 > 0 and (showF2GannML or showF3GannML or showSF2GannML or showSF3GannML))
				[drawF2] = f_CalculateFn1(_pointX,_pointY,arraySXF1GannML,arraySYF1GannML,arrayXF2GannML,arrayYF2GannML)
				f_CalculateDrawF(showF2GannML?drawF2:0,showSF2GannML,arrayLineF2GannML,arrayXF2GannML,arrayYF2GannML,showChoChF2GannML,arrayMarkChoChGannML,2,colorF2GannML)
				if(drawF2 > 0 and (showF3GannML or showSF2GannML or showSF3GannML))
					[drawSF2] = f_CalculateSFn1(_pointX,_pointY,arrayMarkGannML,1,arraySXF2GannML,arraySYF2GannML)
					f_CalculateDrawSF(showSF2GannML?drawSF2:0,arrayLineF2GannML,arraySLineF2GannML,arraySXF2GannML,arraySYF2GannML,showChoChSF2GannML,arrayMarkChoChGannML,3,colorF2GannML)
					if(drawSF2 > 0 and (showF3GannML or showSF3GannML))
						[drawF3] = f_CalculateFn1(_pointX,_pointY,arraySXF2GannML,arraySYF2GannML,arrayXF3GannML,arrayYF3GannML)
						f_CalculateDrawF(showF3GannML?drawF3:0,showSF3GannML,arrayLineF3GannML,arrayXF3GannML,arrayYF3GannML,showChoChF3GannML,arrayMarkChoChGannML,4,colorF3GannML)
						if(drawF3 > 0 and (showSF3GannML))
							[drawSF3] = f_CalculateSFn1(_pointX,_pointY,arrayMarkGannML,2,arraySXF3GannML,arraySYF3GannML)
							f_CalculateDrawSF(showSF3GannML?drawSF3:0,arrayLineF3GannML,arraySLineF3GannML,arraySXF3GannML,arraySYF3GannML,showChoChSF3GannML,arrayMarkChoChGannML,5,colorF3GannML)

f_CalculateAndDraw(_pointX,_pointY1,_pointY2) =>
	if((array.get(arrayYF0GannML,0) > _pointY1 and array.get(arrayYF0GannML,0) > _pointY2) or (array.get(arrayYF0GannML,0) < _pointY1 and array.get(arrayYF0GannML,0) < _pointY2))
		f_CalculateAndDrawFn1(time,array.get(arrayYF0GannML,1))
	f_CalculateAndDrawFn1(time,_pointY1)
	f_CalculateAndDrawFn1(time,_pointY2)
	
highPrev = high
lowPrev = low
if(true)
	if(high > highPrev[1] and low > lowPrev[1])
		f_CalculateAndDraw(time,low,high)
	else if(high < highPrev[1] and low < lowPrev[1])
		f_CalculateAndDraw(time,high,low)
	else if((high >= highPrev[1] and low < lowPrev[1]) or (high > highPrev[1] and low <= lowPrev[1]))
		if(close > open)
			f_CalculateAndDraw(time,low,high)
		else
			f_CalculateAndDraw(time,high,low)
	else if(high[0] <= highPrev[1] and low[0] >= lowPrev[1])
		highPrev := highPrev[1]
		lowPrev := lowPrev[1]

//plot(array.get(arrayMarkChoChGannML,1), color = colorF1GannML)
//plot(array.get(arrayMarkChoChGannML,1)[1], color =colorF1GannML )

//plot(array.get(arrayMarkChoChGannML,2), color = colorF2GannML)
//plot(array.get(arrayMarkChoChGannML,2)[1], color = colorF2GannML)
//plot(array.get(arrayMarkChoChGannML,3), color = colorF3GannML)
//plot(array.get(arrayMarkChoChGannML,3)[1], color =colorF3GannML)
//plot(array.get(arrayMarkChoChGannML,4))
//plot(array.get(arrayMarkChoChGannML,4)[1])



var a = true
var b = true
var e = true
var f = true
var a2 = true
var b2 = true
var a3 = true
var b3 = true


if array.get(arrayMarkChoChGannML,4) < array.get(arrayMarkChoChGannML,4)[1] 
	a := true
	b := false
if array.get(arrayMarkChoChGannML,4) > array.get(arrayMarkChoChGannML,4)[1] 
	a := false
	b := true

if array.get(arrayMarkChoChGannML,1) < array.get(arrayMarkChoChGannML,1)[1] 
	e := true
	f := false
if array.get(arrayMarkChoChGannML,1) > array.get(arrayMarkChoChGannML,1)[1] 
	e := false
	f := true

if array.get(arrayMarkChoChGannML,3) < array.get(arrayMarkChoChGannML,3)[1] 
	a3 := true
	b3 := false
if array.get(arrayMarkChoChGannML,3) > array.get(arrayMarkChoChGannML,3)[1] 
	a3 := false
	b3 := true

if array.get(arrayMarkChoChGannML,2) < array.get(arrayMarkChoChGannML,2)[1] 
	a2 := true
	b2 := false
if array.get(arrayMarkChoChGannML,2) > array.get(arrayMarkChoChGannML,2)[1] 
	a2 := false
	b2 := true

c = array.get(arrayMarkChoChGannML,0) != array.get(arrayMarkChoChGannML,0)[1] and array.get(arrayMarkChoChGannML,0) < high and ( array.get(arrayMarkChoChGannML,0) > close[1] ) and  ( f or (b or b2 or b3)) ? true : false
d = array.get(arrayMarkChoChGannML,0) != array.get(arrayMarkChoChGannML,0)[1] and array.get(arrayMarkChoChGannML,0) > low and ( array.get(arrayMarkChoChGannML,0) < close[1] ) and (  e or (a or a2 or a3)) ? true : false

var position = 1
toggle = true //, "Stay in trade for longer.")
short = input.bool(true, "ir true: short ; else close")

if ((d[0]   )and short   ) 
	//strategy.entry("short",strategy.short)
	strategy.entry("short",strategy.short)
	position := -1
if ((c or (((b and b2 and b3)) and toggle) ) and not (((d[0] and not short) or not (c or (((b and b2 and b3) and f) and toggle))))  )
	strategy.entry("long",strategy.long)
	position := 1





if (((d[0] and not short) or not (c and not short or (((b and b2 and b3) and f) and toggle)))) 
	//strategy.entry("short",strategy.short)
	strategy.close_all()
	position := 0




	
plot(position , "position")





//plot(high > highPrev[1] and low > lowPrev[1] ? 1 :0)
//plot(high < highPrev[1] and low < lowPrev[1] ? 1 :0)
//plot((high >= highPrev[1] and low < lowPrev[1]) or (high > highPrev[1] and low <= lowPrev[1]) ? 1 :0)
//plot(high[0] <= highPrev[1] and low[0] >= lowPrev[1] ? 1 :0)
````
