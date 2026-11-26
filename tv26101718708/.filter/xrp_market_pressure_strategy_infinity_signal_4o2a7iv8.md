# XRP Market Pressure Strategy  / Infinity Signal

- url: https://www.tradingview.com/script/4O2a7iV8-XRP-Market-Pressure-Strategy-Infinity-Signal/
- type: indicator
- pine_id: PUB;884b518d752244229d61c97a8fa56d62
- version: 1.0

## Description

XRP Market Pressure Strategy — Infinity Signal is a rule-based market pressure indicator designed to help traders and investors identify periods of potential accumulation and periods where risk may be elevated.

The concept originated from a simple XRP market framework that focused on four major market conditions:

• RSI
• Stochastic RSI
• Money Flow Index (MFI)
• Fear & Greed sentiment

This indicator transforms those concepts into a visual scoring system and decision-support dashboard.

Features
Market Pressure Engine

The indicator continuously evaluates:

• RSI conditions
• Stochastic RSI conditions
• MFI conditions
• Optional Fear & Greed conditions

Each component contributes to an overall score that determines whether market pressure is bullish, bearish, or neutral.

Accumulation Zones

Green accumulation zones highlight periods where multiple conditions begin aligning toward potential accumulation.

These zones are designed to identify areas of improving conditions rather than attempting to pinpoint exact bottoms.

Reduce Risk Zones

Red zones identify periods where market conditions may be becoming increasingly extended.

These zones are intended to highlight elevated-risk environments rather than attempting to predict exact market tops.

Signal Dashboard

The built-in dashboard provides:

• Market State
• Market Pressure
• RSI Status
• Stochastic RSI Status
• MFI Status
• Fear & Greed Status
• Buy Score
• Sell Score
• Final Signal

Discipline Layer

The indicator intentionally includes a discipline component.

Markets rarely provide perfect entries and exits.

The objective is not to predict exact turning points but to identify periods where probabilities may be improving or deteriorating.

How It Works

Buy pressure increases when:

• RSI moves toward oversold levels
• Stochastic RSI reaches extreme lows
• MFI reaches low readings
• Fear & Greed conditions become fearful

Sell pressure increases when:

• RSI becomes elevated
• Stochastic RSI becomes extended
• MFI reaches elevated readings
• Fear & Greed conditions become greedy

The scoring engine combines these factors into a single visual framework.

Important Notes

This indicator does not predict future prices.

It is designed to identify periods of alignment between multiple market conditions.

No indicator is perfect, and signals should always be evaluated alongside price action, trend structure, risk management, and individual research.

Best Use Cases

• XRP market analysis
• Long-term accumulation studies
• Risk-management planning
• Market cycle observation
• Educational analysis

## Source Code

````pine
//@version=6
indicator("When to Buy and Sell XRP — Infinity Signal", overlay=true, scale=scale.right)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCALE LOCK — MERGE THIS INDICATOR SCALE WITH CHART SCALE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
scaleLock = close
plot(scaleLock, title="Scale Lock — Merge With Chart Scale", color=color.new(color.gray, 100), linewidth=1, trackprice=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupCore = "Core Settings"

tfInput = input.timeframe("D", "Signal Timeframe", group=groupCore)

rsiLen   = input.int(14, "RSI Length", minval=1, group=groupCore)
stochLen = input.int(14, "Stoch RSI Length", minval=1, group=groupCore)
kLen     = input.int(3, "Stoch RSI Smoothing", minval=1, group=groupCore)
mfiLen   = input.int(14, "MFI Length", minval=1, group=groupCore)

buyRsiLevel    = input.float(40, "BUY RSI ≤", group=groupCore)
sellRsiLevel   = input.float(75, "SELL RSI ≥", group=groupCore)
buyStochLevel  = input.float(5, "BUY Stoch RSI ≤", group=groupCore)
sellStochLevel = input.float(90, "SELL Stoch RSI ≥", group=groupCore)
buyMfiLevel    = input.float(20, "BUY MFI ≤", group=groupCore)
sellMfiLevel   = input.float(75, "SELL MFI ≥", group=groupCore)

useFearGreed = input.bool(true, "Enable Manual Fear / Greed Filter", group=groupCore)
fearGreed = input.string("Neutral", "Manual Fear / Greed", options=["Extreme Fear", "Fear", "Neutral", "Greed", "Extreme Greed"], group=groupCore)

strictMode = input.bool(false, "Strict Mode: Require Full Score", group=groupCore)

showTable    = input.bool(true, "Show Table", group=groupCore)
showZones    = input.bool(true, "Show Accumulate / Reduce Risk Zones", group=groupCore)
showLabels   = input.bool(true, "Show Start Labels", group=groupCore)
showProgress = input.bool(true, "Show Progress Bars", group=groupCore)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupColors = "Color Controls"

headerBg     = input.color(color.rgb(20, 65, 180), "Header Background", group=groupColors)
headerText   = input.color(color.white, "Header Text", group=groupColors)

labelBg      = input.color(color.rgb(35, 38, 46), "Label Cell Background", group=groupColors)
labelText    = input.color(color.white, "Label Cell Text", group=groupColors)

valueBg      = input.color(color.rgb(28, 28, 34), "Value Cell Background", group=groupColors)
valueText    = input.color(color.white, "Value Cell Text", group=groupColors)

buyBg        = input.color(color.rgb(0, 130, 45), "BUY Background", group=groupColors)
sellBg       = input.color(color.rgb(190, 25, 45), "SELL Background", group=groupColors)
neutralBg    = input.color(color.rgb(130, 130, 140), "Neutral Background", group=groupColors)

inactiveBg   = input.color(color.rgb(45, 48, 56), "Inactive Cell Background", group=groupColors)
waitBg       = input.color(color.orange, "Wait Background", group=groupColors)

buyLabelBg   = input.color(color.green, "ACCUMULATE Label Color", group=groupColors)
sellLabelBg  = input.color(color.red, "REDUCE RISK Label Color", group=groupColors)
labelTxt     = input.color(color.white, "Label Text Color", group=groupColors)

buyZoneBg    = input.color(color.new(color.green, 88), "Accumulation Zone Background", group=groupColors)
sellZoneBg   = input.color(color.new(color.red, 88), "Reduce Risk Zone Background", group=groupColors)

progressBuyBg  = input.color(color.new(color.green, 55), "Buy Progress Background", group=groupColors)
progressSellBg = input.color(color.new(color.red, 55), "Sell Progress Background", group=groupColors)

disciplineBg   = input.color(color.rgb(20, 20, 25), "Discipline Row Background", group=groupColors)
disciplineText = input.color(color.yellow, "Discipline Text", group=groupColors)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGHER TIMEFRAME DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsi = request.security(syminfo.tickerid, tfInput, ta.rsi(close, rsiLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

stochRsi = request.security(syminfo.tickerid, tfInput, ta.sma(100 * (ta.rsi(close, rsiLen) - ta.lowest(ta.rsi(close, rsiLen), stochLen)) / math.max(ta.highest(ta.rsi(close, rsiLen), stochLen) - ta.lowest(ta.rsi(close, rsiLen), stochLen), 0.000001), kLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

mfi = request.security(syminfo.tickerid, tfInput, ta.mfi(hlc3, mfiLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONDITIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
buyRsiOk   = rsi <= buyRsiLevel
buyStochOk = stochRsi <= buyStochLevel
buyMfiOk   = mfi <= buyMfiLevel
buyFearOk  = fearGreed == "Extreme Fear"

sellRsiOk   = rsi >= sellRsiLevel
sellStochOk = stochRsi >= sellStochLevel
sellMfiOk   = mfi >= sellMfiLevel
sellFearOk  = fearGreed == "Extreme Greed"

maxScore = useFearGreed ? 4 : 3

buyScore = (buyRsiOk ? 1 : 0) + (buyStochOk ? 1 : 0) + (buyMfiOk ? 1 : 0) + (useFearGreed and buyFearOk ? 1 : 0)
sellScore = (sellRsiOk ? 1 : 0) + (sellStochOk ? 1 : 0) + (sellMfiOk ? 1 : 0) + (useFearGreed and sellFearOk ? 1 : 0)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SIGNAL LOGIC
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
requiredScore = strictMode ? maxScore : math.max(maxScore - 1, 2)

buySignal  = buyScore >= requiredScore
sellSignal = sellScore >= requiredScore

buyZone  = buyScore >= 2 and buyScore > sellScore
sellZone = sellScore >= 2 and sellScore > buyScore

newBuyZone  = buyZone and not buyZone[1]
newSellZone = sellZone and not sellZone[1]

marketPressure = buyZone ? "BUY PRESSURE" : sellZone ? "SELL PRESSURE" : "NEUTRAL"
pressureColor = buyZone ? buyBg : sellZone ? sellBg : neutralBg

marketState = buyZone ? "ACCUMULATION" : sellZone ? "DISTRIBUTION" : "NEUTRAL"
marketStateColor = buyZone ? buyBg : sellZone ? sellBg : neutralBg

finalSignal = buySignal ? "ACCUMULATE" : sellSignal ? "REDUCE RISK" : buyZone ? "EARLY ACCUMULATION" : sellZone ? "PROFIT / RISK ZONE" : "WAIT FOR ALIGNMENT"
finalColor = buySignal ? buyBg : sellSignal ? sellBg : buyZone ? color.new(buyBg, 20) : sellZone ? color.new(sellBg, 20) : waitBg

extremeBuyPressure  = buyScore == maxScore
extremeSellPressure = sellScore == maxScore

extremeText = extremeBuyPressure ? "MAX BUY PRESSURE" : extremeSellPressure ? "MAX SELL PRESSURE" : "NORMAL"
extremeColor = extremeBuyPressure ? buyBg : extremeSellPressure ? sellBg : neutralBg

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PROGRESS BARS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_bar(_score, _max) =>
    _max == 4 ? (_score == 0 ? "□□□□" : _score == 1 ? "■□□□" : _score == 2 ? "■■□□" : _score == 3 ? "■■■□" : "■■■■") : (_score == 0 ? "□□□" : _score == 1 ? "■□□" : _score == 2 ? "■■□" : "■■■")

buyBar  = f_bar(buyScore, maxScore)
sellBar = f_bar(sellScore, maxScore)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CLEAN VISUAL DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bgcolor(showZones ? buyZone ? buyZoneBg : sellZone ? sellZoneBg : na : na)

plotshape(showLabels and newBuyZone, title="ACCUMULATE Zone Start", style=shape.labelup, text="ACCUMULATE", color=buyLabelBg, textcolor=labelTxt, size=size.small, location=location.belowbar)

plotshape(showLabels and newSellZone, title="REDUCE RISK Zone Start", style=shape.labeldown, text="REDUCE\nRISK", color=sellLabelBg, textcolor=labelTxt, size=size.small, location=location.abovebar)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(newBuyZone, title="ACCUMULATE Zone Started", message="Infinity Signal: ACCUMULATE zone has started.")
alertcondition(newSellZone, title="REDUCE RISK Zone Started", message="Infinity Signal: REDUCE RISK zone has started.")
alertcondition(buySignal, title="ACCUMULATE Active", message="Infinity Signal: ACCUMULATE conditions are active.")
alertcondition(sellSignal, title="REDUCE RISK Active", message="Infinity Signal: REDUCE RISK conditions are active.")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE FUNCTIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_status(_bool) =>
    _bool ? "ACTIVE" : "—"

f_color(_bool, _bull) =>
    _bool ? (_bull ? buyBg : sellBg) : inactiveBg

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// TABLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var table t = table.new(position.top_right, 4, 12, border_width=1)

if showTable and barstate.islast
    table.cell(t, 0, 0, "INFINITY SIGNAL", bgcolor=headerBg, text_color=headerText)
    table.cell(t, 1, 0, "STATUS", bgcolor=headerBg, text_color=headerText)
    table.cell(t, 2, 0, "BUY", bgcolor=headerBg, text_color=color.lime)
    table.cell(t, 3, 0, "SELL", bgcolor=headerBg, text_color=color.red)

    table.cell(t, 0, 1, "MARKET STATE", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 1, marketState, bgcolor=marketStateColor, text_color=valueText)
    table.cell(t, 2, 1, "", bgcolor=inactiveBg)
    table.cell(t, 3, 1, "", bgcolor=inactiveBg)

    table.cell(t, 0, 2, "MARKET PRESSURE", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 2, marketPressure, bgcolor=pressureColor, text_color=valueText)
    table.cell(t, 2, 2, "", bgcolor=inactiveBg)
    table.cell(t, 3, 2, "", bgcolor=inactiveBg)

    table.cell(t, 0, 3, "RSI", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 3, str.tostring(rsi, "#.##"), bgcolor=valueBg, text_color=valueText)
    table.cell(t, 2, 3, f_status(buyRsiOk), bgcolor=f_color(buyRsiOk, true), text_color=valueText)
    table.cell(t, 3, 3, f_status(sellRsiOk), bgcolor=f_color(sellRsiOk, false), text_color=valueText)

    table.cell(t, 0, 4, "STOCH RSI", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 4, str.tostring(stochRsi, "#.##"), bgcolor=valueBg, text_color=valueText)
    table.cell(t, 2, 4, f_status(buyStochOk), bgcolor=f_color(buyStochOk, true), text_color=valueText)
    table.cell(t, 3, 4, f_status(sellStochOk), bgcolor=f_color(sellStochOk, false), text_color=valueText)

    table.cell(t, 0, 5, "MFI", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 5, str.tostring(mfi, "#.##"), bgcolor=valueBg, text_color=valueText)
    table.cell(t, 2, 5, f_status(buyMfiOk), bgcolor=f_color(buyMfiOk, true), text_color=valueText)
    table.cell(t, 3, 5, f_status(sellMfiOk), bgcolor=f_color(sellMfiOk, false), text_color=valueText)

    table.cell(t, 0, 6, "FEAR/GREED", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 6, useFearGreed ? fearGreed : "OFF", bgcolor=valueBg, text_color=valueText)
    table.cell(t, 2, 6, useFearGreed ? f_status(buyFearOk) : "OFF", bgcolor=useFearGreed ? f_color(buyFearOk, true) : inactiveBg, text_color=valueText)
    table.cell(t, 3, 6, useFearGreed ? f_status(sellFearOk) : "OFF", bgcolor=useFearGreed ? f_color(sellFearOk, false) : inactiveBg, text_color=valueText)

    table.cell(t, 0, 7, "BUY SCORE", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 7, str.tostring(buyScore) + "/" + str.tostring(maxScore), bgcolor=color.new(buyBg, 20), text_color=valueText)
    table.cell(t, 2, 7, showProgress ? buyBar : "", bgcolor=progressBuyBg, text_color=valueText)
    table.cell(t, 3, 7, "", bgcolor=inactiveBg)

    table.cell(t, 0, 8, "SELL SCORE", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 8, str.tostring(sellScore) + "/" + str.tostring(maxScore), bgcolor=color.new(sellBg, 20), text_color=valueText)
    table.cell(t, 2, 8, "", bgcolor=inactiveBg)
    table.cell(t, 3, 8, showProgress ? sellBar : "", bgcolor=progressSellBg, text_color=valueText)

    table.cell(t, 0, 9, "EXTREME", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 9, extremeText, bgcolor=extremeColor, text_color=valueText)
    table.cell(t, 2, 9, "", bgcolor=inactiveBg)
    table.cell(t, 3, 9, "", bgcolor=inactiveBg)

    table.cell(t, 0, 10, "FINAL SIGNAL", bgcolor=headerBg, text_color=headerText)
    table.cell(t, 1, 10, finalSignal, bgcolor=finalColor, text_color=valueText)
    table.cell(t, 2, 10, "", bgcolor=inactiveBg)
    table.cell(t, 3, 10, "", bgcolor=inactiveBg)

    table.cell(t, 0, 11, "DISCIPLINE", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 11, "NO EMOTIONS", bgcolor=disciplineBg, text_color=disciplineText)
    table.cell(t, 2, 11, "WAIT FOR", bgcolor=disciplineBg, text_color=valueText)
    table.cell(t, 3, 11, "ALIGNMENT", bgcolor=disciplineBg, text_color=valueText)
````
