# VWAP Levels - Actual + Previa

- url: https://www.tradingview.com/script/doWhNwdw-VWAP-Levels-Actual-Previa/
- type: indicator
- pine_id: PUB;f698c3459a564797bf3963af74d0fd66
- version: 7.0

## Description

Niveles de VWAP por temporalidades.

Código de Javier Rodríguez y Aitor.

## Source Code

````pine
//@version=5
indicator(title="VWAP Lvls", overlay=true)

    
computeVWAP(src, isNewPeriod, stDevMultiplier) =>
	var float sumSrcVol = na
	var float sumVol = na
    var float sumSrcSrcVol = na

	sumSrcVol := isNewPeriod ? src * volume : src * volume + sumSrcVol[1]
	sumVol := isNewPeriod ? volume : volume + sumVol[1]
	// sumSrcSrcVol calculates the dividend of the equation that is later used to calculate the standard deviation
	sumSrcSrcVol := isNewPeriod ? volume * math.pow(src, 2) : volume * math.pow(src, 2) + sumSrcSrcVol[1]

	_vwap = sumSrcVol / sumVol
	variance = sumSrcSrcVol / sumVol - math.pow(_vwap, 2)
	variance := variance < 0 ? 0 : variance
	stDev = math.sqrt(variance)

	lowerBand = _vwap - stDev * stDevMultiplier
	upperBand = _vwap + stDev * stDevMultiplier
    
	[_vwap, lowerBand, upperBand]

var anchor = input.string(defval = "Session", title="Anchor Period",
 options=["Session", "Week", "Month", "Quarter", "Year", "Decade", "Half Decade"], group="VWAP Settings")
 
src = input(title = "Source", defval = hlc3, group="VWAP Settings")
hideonDWM = input(false, title="Hide VWAP on 1D or Above", group="VWAP Settings")
showBands = input(true, title="Calculate Bands", group="Standard Deviation Bands Settings")
showPrevious= input.bool(false, title= "Show Previous ZONES")
stdevMult = input.float(1.0, title="DVA", group="Standard Deviation Bands Settings", step= 0.1)
stdevMult2 = input.float(2.0, title="DVA+2", group="Standard Deviation Bands Settings", step= 0.1)
stdevMult3 = input.float(3.0, title="DVA+3", group="Standard Deviation Bands Settings", step= 0.1)

timeChange(period) =>
	ta.change(time(period))


isNewPeriod = switch anchor
	"Session" => timeChange("D")
	"Week" => timeChange("W")
	"Month" => timeChange("M")
	"Quarter" => timeChange("3M")
	"Year" => timeChange("12M")
	"Half Decade" => timeChange("12M") and year % 05 == 0
	"Decade" => timeChange("12M") and year % 10 == 0
	=> false

isEsdAnchor = anchor == "Earnings" or anchor == "Dividends" or anchor == "Splits"
if na(src[1]) and not isEsdAnchor
	isNewPeriod := true

float vwapValue = na
float std = na
float upperBandValue = na
float lowerBandValue = na
float upperBandValue2 = na
float lowerBandValue2 = na
float upperBandValue3 = na
float lowerBandValue3 = na
float prevwap = na



if  not timeframe.isdwm or timeframe.isdwm
    [_vwap, bottom, top] = computeVWAP(src, isNewPeriod, stdevMult3)
    vwapValue := _vwap
    upperBandValue3 := showBands ? top : na
    lowerBandValue3 := showBands ? bottom : na
    prevwap:= isNewPeriod? na : _vwap[1]
    
    
if  not timeframe.isdwm or timeframe.isdwm
    [_vwap, bottom, top] = computeVWAP(src, isNewPeriod, stdevMult2)
    vwapValue := _vwap
    upperBandValue2 := showBands ? top : na
    lowerBandValue2 := showBands ? bottom : na
    prevwap:= isNewPeriod? na : _vwap[1]
    
if  not timeframe.isdwm or timeframe.isdwm
    [_vwap, bottom, top] = computeVWAP(src, isNewPeriod, stdevMult)
    vwapValue := _vwap
    upperBandValue := showBands ? top : na
    lowerBandValue := showBands ? bottom : na
    prevwap:= isNewPeriod? na : _vwap[1]
    
    
    


                     
//PREVIOUS VALUE AREAS
pdvavwap = ta.valuewhen(isNewPeriod, vwapValue[1],0)
pdvah = ta.valuewhen(isNewPeriod, upperBandValue[1],0)
pdval = ta.valuewhen(isNewPeriod, lowerBandValue[1],0)

prvwap=  showPrevious? line.new(bar_index[30], pdvavwap, bar_index[0],pdvavwap, extend=extend.both,width= 2   , color=color.rgb(255,111,123,50)):na
line.delete(prvwap[1])
prevdvah= showPrevious? line.new(bar_index[30], pdvah, bar_index[0],pdvah, extend=extend.both, width= 2   ,color=color.rgb(255,111,123,50)):na
line.delete(prevdvah[1])
prevdval= showPrevious? line.new(bar_index[30], pdval, bar_index[0],pdval, extend=extend.both, width= 2   ,color=color.rgb(255,111,123,50)):na
line.delete(prevdval[1])

line.set_style(prvwap, line.style_dashed)
line.set_style(prevdvah, line.style_dashed)
line.set_style(prevdval, line.style_dashed)

//.........................LABELS

labelvwap= showPrevious? label.new(bar_index[0], pdvavwap, text="PDVA VWAP",color=color.rgb(255,111,123,75), textcolor=color.rgb(255,255,255,10), textalign=text.align_right,size=size.small):na
label.delete(labelvwap[1])

labeldval= showPrevious? label.new(bar_index[0], pdval, text="PDVAL",color=color.rgb(255,111,123,75), textcolor=color.rgb(255,255,255,10), textalign=text.align_right,size=size.small):na
label.delete(labeldval[1])

labeldvah= showPrevious? label.new(bar_index[0], pdvah, text="PDVAH",color=color.rgb(255,111,123,75), textcolor=color.rgb(255,255,255,10), textalign=text.align_right,size=size.small):na
label.delete(labeldvah[1])


plot(vwapValue, title="VWAP", color= close > vwapValue ?  color.green : color.red, linewidth = 2)
upperBand = plot(upperBandValue, title="DVAH", color=color.new(color.black,70))
lowerBand = plot(lowerBandValue, title="DVAL", color=color.new(color.black,70))
upper2 = plot(upperBandValue2, title="DVA+2",  color=color.new(color.black,70))
lower2 = plot(lowerBandValue2, title="DVA-2",  color=color.new(color.black,70))
upper3 = plot(upperBandValue3, title="DVA+3",  color=color.new(color.black,70))
lower3 = plot(lowerBandValue3, title="DVA-3",  color=color.new(color.black,70))
mu05  = plot(((vwapValue+upperBandValue)/2), title= "middle up 0.5", color= color.rgb(247,79,94,50), style = plot.style_circles)
ml05 = plot(((vwapValue+lowerBandValue)/2), title= "middle down 0.5",color= color.rgb(247,79,94,50), style = plot.style_circles)
mup2 =plot(((upperBandValue+upperBandValue2)/2), title= "Middle up 1.5",color= color.rgb(247,79,94,50), style = plot.style_circles)
mudn2  =plot(((lowerBandValue+lowerBandValue2)/2), title= "Middle down 1.5", color= color.rgb(247,79,94,50), style = plot.style_circles)

fill(upperBand, lowerBand, title="Bands Fill", color= showBands ? color.new(color.blue, 85) : na)
fill(upper3, upper2, title="Bands Fill", color= showBands ? color.new(color.blue, 85) : na)
fill(lower3, lower2, title="Bands Fill", color= showBands ? color.new(color.blue, 85) : na)
````
