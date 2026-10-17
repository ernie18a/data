# Polished

- url: https://www.tradingview.com/script/Md9KDR3V-Polished/
- type: indicator
- pine_id: PUB;79737867de864e45a9bed73b87eccada
- version: 1.0

## Description

mapping tension between compression and expansion with one buy sell suggestion per trading session.

## Source Code

````pine

//@version=6



indicator("Polished", shorttitle="POL", overlay=true, max_labels_count=200, max_lines_count=200)



//--------------------------------------------------



// Inputs



//--------------------------------------------------



fastLen = input.int(9, "Fast EMA", minval=1)



midLen = input.int(21, "Mid EMA", minval=1)



slowLen = input.int(50, "Slow EMA", minval=1)



rsiLen = input.int(14, "RSI Length", minval=1)



atrLen = input.int(14, "ATR Length", minval=1)



orbMinutes = input.int(30, "Opening Range Minutes", minval=5, step=5)



sessionInput = input.session("0830-1300", "Session")



tensionThresh = input.float(60.0, "Tension Threshold", minval=0, maxval=100)



bullBiasThresh = input.float(10.0, "Bull Bias Threshold", minval=0, maxval=100)



bearBiasThresh = input.float(-10.0, "Bear Bias Threshold", minval=-100, maxval=0)



confirmClose = input.bool(true, "Require Close Beyond ORB")



oneSignalPerDirection = input.bool(true, "One Signal Per Direction Per Session")



showBackground = input.bool(true, "Show Background")



showStopsTargets = input.bool(true, "Show Stop/Target Lines")



stopATRMult = input.float(1.0, "Stop ATR Mult", minval=0.1, step=0.1)



target1RR = input.float(1.0, "Target 1 R Multiple", minval=0.1, step=0.1)



target2RR = input.float(2.0, "Target 2 R Multiple", minval=0.1, step=0.1)



//--------------------------------------------------



// Core calculations



//--------------------------------------------------



emaFast = ta.ema(close, fastLen)



emaMid = ta.ema(close, midLen)



emaSlow = ta.ema(close, slowLen)



rsiVal = ta.rsi(close, rsiLen)



atrVal = ta.atr(atrLen)



// Simple bias model



trendBull = emaFast > emaMid and emaMid > emaSlow



trendBear = emaFast < emaMid and emaMid < emaSlow



biasScore = (trendBull ? 35.0 : trendBear ? -35.0 : 0.0) + (rsiVal - 50.0)



// Simple tension model



atrPct = atrVal / close



atrAvg = ta.sma(atrPct, 20)



tensionScore = atrAvg > 0 ? math.min(100.0, 100.0 * atrPct / atrAvg) : 0.0



//--------------------------------------------------



// Session and ORB



//--------------------------------------------------



inSession = not na(time(timeframe.period, sessionInput))



newSession = inSession and not inSession[1]



var float orbHigh = na



var float orbLow = na



var int sessionStartTime = na



if newSession



    orbHigh := high



    orbLow := low



    sessionStartTime := time



orbActive = inSession and not na(sessionStartTime) and time < sessionStartTime + orbMinutes * 60 * 1000



orbDefined = inSession and not na(sessionStartTime) and time >= sessionStartTime + orbMinutes * 60 * 1000



if orbActive



    orbHigh := math.max(orbHigh, high)



    orbLow := math.min(orbLow, low)



//--------------------------------------------------



// Break logic



//--------------------------------------------------



bullBreak = orbDefined and not na(orbHigh) and (confirmClose ? close > orbHigh : high > orbHigh)



bearBreak = orbDefined and not na(orbLow) and (confirmClose ? close < orbLow : low < orbLow)



buySuggestion = bullBreak and tensionScore >= tensionThresh and biasScore >= bullBiasThresh and emaFast > emaMid



sellSuggestion = bearBreak and tensionScore >= tensionThresh and biasScore <= bearBiasThresh and emaFast < emaMid



//--------------------------------------------------



// One signal per direction per session



//--------------------------------------------------



var bool longFiredThisSession = false



var bool shortFiredThisSession = false



if newSession



    longFiredThisSession := false



    shortFiredThisSession := false



rawBuyTrigger = buySuggestion and not buySuggestion[1]



rawSellTrigger = sellSuggestion and not sellSuggestion[1]



buyTrigger = rawBuyTrigger and (not oneSignalPerDirection or not longFiredThisSession)



sellTrigger = rawSellTrigger and (not oneSignalPerDirection or not shortFiredThisSession)



if buyTrigger



    longFiredThisSession := true



if sellTrigger



    shortFiredThisSession := true



//--------------------------------------------------



// Trade levels



//--------------------------------------------------



var float longEntry = na



var float longStop = na



var float longT1 = na



var float longT2 = na



var float shortEntry = na



var float shortStop = na



var float shortT1 = na



var float shortT2 = na



if buyTrigger



    longEntry := close



    longStop := close - atrVal * stopATRMult



    longRisk = longEntry - longStop



    longT1 := longEntry + longRisk * target1RR



    longT2 := longEntry + longRisk * target2RR



    shortEntry := na



    shortStop := na



    shortT1 := na



    shortT2 := na



if sellTrigger



    shortEntry := close



    shortStop := close + atrVal * stopATRMult



    shortRisk = shortStop - shortEntry



    shortT1 := shortEntry - shortRisk * target1RR



    shortT2 := shortEntry - shortRisk * target2RR



    longEntry := na



    longStop := na



    longT1 := na



    longT2 := na



//--------------------------------------------------



// Exit invalidation helpers



//--------------------------------------------------



longInvalid = not na(longEntry) and (close < emaFast or biasScore < 0)



shortInvalid = not na(shortEntry) and (close > emaFast or biasScore > 0)



//--------------------------------------------------



// Plots



//--------------------------------------------------



plot(orbHigh, "ORB High", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)



plot(orbLow, "ORB Low", color=color.new(color.red, 0), linewidth=2, style=plot.style_linebr)



plotshape(buyTrigger, title="Buy Suggestion", style=shape.labelup, location=location.belowbar, color=color.new(color.green, 0), text="BUY", textcolor=color.white, size=size.small)



plotshape(sellTrigger, title="Sell Suggestion", style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 0), text="SELL", textcolor=color.white, size=size.small)



plot(showStopsTargets ? longStop : na, "Long Stop", color=color.new(color.red, 20), linewidth=2, style=plot.style_linebr)



plot(showStopsTargets ? longT1 : na, "Long Target 1", color=color.new(color.green, 20), linewidth=1, style=plot.style_linebr)



plot(showStopsTargets ? longT2 : na, "Long Target 2", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)



plot(showStopsTargets ? shortStop : na, "Short Stop", color=color.new(color.red, 20), linewidth=2, style=plot.style_linebr)



plot(showStopsTargets ? shortT1 : na, "Short Target 1", color=color.new(color.green, 20), linewidth=1, style=plot.style_linebr)



plot(showStopsTargets ? shortT2 : na, "Short Target 2", color=color.new(color.green, 0), linewidth=2, style=plot.style_linebr)



plotshape(longInvalid, title="Long Caution", style=shape.circle, location=location.abovebar, color=color.new(color.yellow, 0), size=size.tiny)



plotshape(shortInvalid, title="Short Caution", style=shape.circle, location=location.belowbar, color=color.new(color.yellow, 0), size=size.tiny)



bgBull = tensionScore >= tensionThresh and biasScore >= bullBiasThresh



bgBear = tensionScore >= tensionThresh and biasScore <= bearBiasThresh



bgcolor(showBackground ? (bgBull ? color.new(color.green, 90) : bgBear ? color.new(color.red, 90) : na) : na)



// Hidden data-window values



plot(tensionScore, "Tension Score", color=color.orange, display=display.data_window)



plot(biasScore, "Bias Score", color=color.blue, display=display.data_window)



// Alerts



alertcondition(buyTrigger, "BUY Suggestion", "ART ORB GC BUY suggestion")



alertcondition(sellTrigger, "SELL Suggestion", "ART ORB GC SELL suggestion")
````
