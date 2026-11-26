# XRP HODLER Framework / Infinity Signal v2.0

- url: https://www.tradingview.com/script/vYN9jfLz-XRP-HODLER-Framework-Infinity-Signal-v2-0/
- type: indicator
- pine_id: PUB;a84db797bca146589d7d091695b5f5f2
- version: 1.0

## Description

The XRP HODLER Framework is a long-term investor decision-support indicator designed to help identify when market conditions may be favorable for:

• Cost Averaging Down
• Cost Averaging Up
• Reducing Risk
• Waiting for Alignment

The indicator combines multiple market measurements into a single framework that is easy to interpret and designed to remove emotion from the decision-making process.

Core Components

The framework evaluates:

• Relative Strength Index (RSI)
• Stochastic RSI
• Money Flow Index (MFI)
• Optional Fear & Greed Sentiment

These components are combined into a scoring system that determines overall market pressure and investor positioning.

Value Zone

Value Zones identify periods where accumulation conditions are developing while price remains below the long-term trend.

These zones are intended to represent potential Cost Average Down environments.

The objective is not to identify an exact bottom, but to identify areas where value may be improving.

Trend Confirmation

Trend Confirmation Zones identify periods where accumulation conditions remain favorable while price trades above the long-term trend.

These zones are intended to represent potential Cost Average Up environments.

Rather than buying weakness, investors may choose to add to positions after evidence of trend recovery appears.

Reduce Risk

Reduce Risk Zones identify periods where market conditions may be becoming increasingly extended.

These zones may be useful for:

• Profit-taking evaluation
• Exposure reduction
• Risk management review

The framework is not designed to identify exact market tops.

Instead, it highlights areas where risk may be increasing.

Market Pressure Dashboard

The dashboard displays:

• Market State
• Market Pressure
• HODLER Mode
• RSI
• Stochastic RSI
• MFI
• Fear & Greed
• Buy Score
• Sell Score
• Final Signal

This allows investors to quickly assess current market conditions from a single location.

Final Signals

COST AVERAGE DOWN

Multiple accumulation conditions are aligning while price remains below the long-term trend.

COST AVERAGE UP

Multiple accumulation conditions are aligning while price remains above the long-term trend.

REDUCE RISK

Multiple risk conditions are aligning, and market conditions may be becoming increasingly 

extended.

How To Use

Step 1

Select the timeframe you wish to analyze.

Many long-term investors prefer the Weekly chart, while active investors may prefer the Daily chart.

Step 2

Monitor the HODLER MODE row.

COST AVERAGE DOWN

Potential value conditions may be developing below the long-term trend.

COST AVERAGE UP

Accumulation conditions remain favorable while price trades above the long-term trend.

Step 3

Review the Buy Score and Sell Score.

Higher Buy Scores indicate increasing accumulation pressure.

Higher Sell Scores indicate increasing risk pressure.

Step 4

Review the Final Signal.

WAIT FOR ALIGNMENT

Remain patient.

COST AVERAGE DOWN

Potential value accumulation conditions are present.

COST AVERAGE UP

Trend recovery conditions are present.

REDUCE RISK

Market conditions may be becoming increasingly extended.

Step 5

Use the framework as a decision-support tool rather than a prediction tool.

The objective is not to identify exact tops or bottoms.

The objective is to identify improving or deteriorating market conditions while maintaining discipline and consistency.

WAIT FOR ALIGNMENT

Market conditions remain mixed, and additional confirmation may be required.

Important Notes

The XRP HODLER Framework is designed to identify changing probabilities rather than predict future prices.

No indicator can consistently identify exact market tops or bottoms.

This framework is intended to provide structure, discipline, and context for long-term investors.

Disclaimer

This script is provided for educational and informational purposes only.

It does not constitute financial advice, investment advice, trading advice, or a recommendation to buy or sell any financial instrument.

Always conduct your own research and use proper risk management.

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

trendLen = input.int(50, "HODLER Trend MA Length", minval=1, group=groupCore)
showTrendMA = input.bool(false, "Show HODLER Trend MA", group=groupCore)

showTable    = input.bool(true, "Show Table", group=groupCore)
showZones    = input.bool(true, "Show Value / Confirmation / Risk Zones", group=groupCore)
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
confirmBg    = input.color(color.rgb(0, 110, 220), "TREND CONFIRMATION Background", group=groupColors)
sellBg       = input.color(color.rgb(190, 25, 45), "SELL Background", group=groupColors)
neutralBg    = input.color(color.rgb(130, 130, 140), "Neutral Background", group=groupColors)

inactiveBg   = input.color(color.rgb(45, 48, 56), "Inactive Cell Background", group=groupColors)
waitBg       = input.color(color.orange, "Wait Background", group=groupColors)

valueLabelBg   = input.color(color.green, "VALUE ZONE Label Color", group=groupColors)
confirmLabelBg = input.color(color.blue, "TREND CONFIRMATION Label Color", group=groupColors)
sellLabelBg    = input.color(color.red, "REDUCE RISK Label Color", group=groupColors)
labelTxt       = input.color(color.white, "Label Text Color", group=groupColors)

valueZoneBg   = input.color(color.new(color.green, 88), "Value Zone Background", group=groupColors)
confirmZoneBg = input.color(color.new(color.blue, 88), "Trend Confirmation Zone Background", group=groupColors)
sellZoneBg    = input.color(color.new(color.red, 88), "Reduce Risk Zone Background", group=groupColors)

progressBuyBg  = input.color(color.new(color.green, 55), "Buy Progress Background", group=groupColors)
progressSellBg = input.color(color.new(color.red, 55), "Sell Progress Background", group=groupColors)

disciplineBg   = input.color(color.rgb(20, 20, 25), "Discipline Row Background", group=groupColors)
disciplineText = input.color(color.yellow, "Discipline Text", group=groupColors)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HIGHER TIMEFRAME DATA
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
rsi = request.security(syminfo.tickerid, tfInput, ta.rsi(close, rsiLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

stochRsi = request.security(
     syminfo.tickerid,
     tfInput,
     ta.sma(
         100 * (ta.rsi(close, rsiLen) - ta.lowest(ta.rsi(close, rsiLen), stochLen)) /
         math.max(ta.highest(ta.rsi(close, rsiLen), stochLen) - ta.lowest(ta.rsi(close, rsiLen), stochLen), 0.000001),
         kLen),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off)

mfi = request.security(syminfo.tickerid, tfInput, ta.mfi(hlc3, mfiLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

trendMA = request.security(syminfo.tickerid, tfInput, ta.sma(close, trendLen), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

plot(showTrendMA ? trendMA : na, title="HODLER Trend MA", color=color.new(color.blue, 0), linewidth=2)

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

valueZone        = buyZone and close < trendMA
confirmationZone = buyZone and close >= trendMA

newValueZone        = valueZone and not valueZone[1]
newConfirmationZone = confirmationZone and not confirmationZone[1]
newSellZone         = sellZone and not sellZone[1]

marketPressure =
     valueZone ? "BUY WEAKNESS" :
     confirmationZone ? "BUY STRENGTH" :
     sellZone ? "SELL PRESSURE" :
     "NEUTRAL"

pressureColor =
     valueZone ? buyBg :
     confirmationZone ? confirmBg :
     sellZone ? sellBg :
     neutralBg

marketState =
     valueZone ? "VALUE ZONE" :
     confirmationZone ? "TREND CONFIRMATION" :
     sellZone ? "DISTRIBUTION" :
     "NEUTRAL"

marketStateColor =
     valueZone ? buyBg :
     confirmationZone ? confirmBg :
     sellZone ? sellBg :
     neutralBg

finalSignal =
     buySignal and valueZone ? "COST AVERAGE DOWN" :
     buySignal and confirmationZone ? "COST AVERAGE UP" :
     sellSignal ? "REDUCE RISK" :
     valueZone ? "VALUE ZONE" :
     confirmationZone ? "TREND CONFIRMATION" :
     sellZone ? "PROFIT / RISK ZONE" :
     "WAIT FOR ALIGNMENT"

finalColor =
     buySignal and valueZone ? buyBg :
     buySignal and confirmationZone ? confirmBg :
     sellSignal ? sellBg :
     valueZone ? color.new(buyBg, 20) :
     confirmationZone ? color.new(confirmBg, 20) :
     sellZone ? color.new(sellBg, 20) :
     waitBg

extremeBuyPressure  = buyScore == maxScore
extremeSellPressure = sellScore == maxScore

extremeText =
     extremeBuyPressure ? "MAX BUY PRESSURE" :
     extremeSellPressure ? "MAX SELL PRESSURE" :
     "NORMAL"

extremeColor =
     extremeBuyPressure ? buyBg :
     extremeSellPressure ? sellBg :
     neutralBg

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
bgcolor(showZones ? valueZone ? valueZoneBg : confirmationZone ? confirmZoneBg : sellZone ? sellZoneBg : na : na)

plotshape(
     showLabels and newValueZone,
     title="VALUE ZONE Start",
     style=shape.labelup,
     text="VALUE\nZONE",
     color=valueLabelBg,
     textcolor=labelTxt,
     size=size.small,
     location=location.belowbar)

plotshape(
     showLabels and newConfirmationZone,
     title="TREND CONFIRMATION Start",
     style=shape.labelup,
     text="TREND\nCONFIRM",
     color=confirmLabelBg,
     textcolor=labelTxt,
     size=size.small,
     location=location.belowbar)

plotshape(
     showLabels and newSellZone,
     title="REDUCE RISK Zone Start",
     style=shape.labeldown,
     text="REDUCE\nRISK",
     color=sellLabelBg,
     textcolor=labelTxt,
     size=size.small,
     location=location.abovebar)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(newValueZone, title="VALUE ZONE Started", message="Infinity Signal: VALUE ZONE started. Long-term cost-average-down conditions may be developing.")
alertcondition(newConfirmationZone, title="TREND CONFIRMATION Started", message="Infinity Signal: TREND CONFIRMATION started. Long-term cost-average-up conditions may be developing.")
alertcondition(newSellZone, title="REDUCE RISK Zone Started", message="Infinity Signal: REDUCE RISK zone has started.")
alertcondition(buySignal and valueZone, title="COST AVERAGE DOWN Active", message="Infinity Signal: COST AVERAGE DOWN conditions are active.")
alertcondition(buySignal and confirmationZone, title="COST AVERAGE UP Active", message="Infinity Signal: COST AVERAGE UP conditions are active.")
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
var table t = table.new(position.top_right, 4, 13, border_width=1)

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

    table.cell(t, 0, 3, "HODLER MODE", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 3, close < trendMA ? "COST AVERAGE DOWN" : "COST AVERAGE UP", bgcolor=close < trendMA ? buyBg : confirmBg, text_color=valueText)
    table.cell(t, 2, 3, close < trendMA ? "VALUE" : "CONFIRM", bgcolor=close < trendMA ? buyBg : confirmBg, text_color=valueText)
    table.cell(t, 3, 3, "", bgcolor=inactiveBg)

    table.cell(t, 0, 4, "RSI", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 4, str.tostring(rsi, "#.##"), bgcolor=valueBg, text_color=valueText)
    table.cell(t, 2, 4, f_status(buyRsiOk), bgcolor=f_color(buyRsiOk, true), text_color=valueText)
    table.cell(t, 3, 4, f_status(sellRsiOk), bgcolor=f_color(sellRsiOk, false), text_color=valueText)

    table.cell(t, 0, 5, "STOCH RSI", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 5, str.tostring(stochRsi, "#.##"), bgcolor=valueBg, text_color=valueText)
    table.cell(t, 2, 5, f_status(buyStochOk), bgcolor=f_color(buyStochOk, true), text_color=valueText)
    table.cell(t, 3, 5, f_status(sellStochOk), bgcolor=f_color(sellStochOk, false), text_color=valueText)

    table.cell(t, 0, 6, "MFI", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 6, str.tostring(mfi, "#.##"), bgcolor=valueBg, text_color=valueText)
    table.cell(t, 2, 6, f_status(buyMfiOk), bgcolor=f_color(buyMfiOk, true), text_color=valueText)
    table.cell(t, 3, 6, f_status(sellMfiOk), bgcolor=f_color(sellMfiOk, false), text_color=valueText)

    table.cell(t, 0, 7, "FEAR/GREED", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 7, useFearGreed ? fearGreed : "OFF", bgcolor=valueBg, text_color=valueText)
    table.cell(t, 2, 7, useFearGreed ? f_status(buyFearOk) : "OFF", bgcolor=useFearGreed ? f_color(buyFearOk, true) : inactiveBg, text_color=valueText)
    table.cell(t, 3, 7, useFearGreed ? f_status(sellFearOk) : "OFF", bgcolor=useFearGreed ? f_color(sellFearOk, false) : inactiveBg, text_color=valueText)

    table.cell(t, 0, 8, "BUY SCORE", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 8, str.tostring(buyScore) + "/" + str.tostring(maxScore), bgcolor=color.new(buyBg, 20), text_color=valueText)
    table.cell(t, 2, 8, showProgress ? buyBar : "", bgcolor=progressBuyBg, text_color=valueText)
    table.cell(t, 3, 8, "", bgcolor=inactiveBg)

    table.cell(t, 0, 9, "SELL SCORE", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 9, str.tostring(sellScore) + "/" + str.tostring(maxScore), bgcolor=color.new(sellBg, 20), text_color=valueText)
    table.cell(t, 2, 9, "", bgcolor=inactiveBg)
    table.cell(t, 3, 9, showProgress ? sellBar : "", bgcolor=progressSellBg, text_color=valueText)

    table.cell(t, 0, 10, "EXTREME", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 10, extremeText, bgcolor=extremeColor, text_color=valueText)
    table.cell(t, 2, 10, "", bgcolor=inactiveBg)
    table.cell(t, 3, 10, "", bgcolor=inactiveBg)

    table.cell(t, 0, 11, "FINAL SIGNAL", bgcolor=headerBg, text_color=headerText)
    table.cell(t, 1, 11, finalSignal, bgcolor=finalColor, text_color=valueText)
    table.cell(t, 2, 11, "", bgcolor=inactiveBg)
    table.cell(t, 3, 11, "", bgcolor=inactiveBg)

    table.cell(t, 0, 12, "DISCIPLINE", bgcolor=labelBg, text_color=labelText)
    table.cell(t, 1, 12, "NO EMOTIONS", bgcolor=disciplineBg, text_color=disciplineText)
    table.cell(t, 2, 12, "WAIT FOR", bgcolor=disciplineBg, text_color=valueText)
    table.cell(t, 3, 12, "ALIGNMENT", bgcolor=disciplineBg, text_color=valueText)
````
