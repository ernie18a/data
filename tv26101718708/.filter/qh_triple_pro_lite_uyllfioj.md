# QH Triple Pro Lite 

- url: https://www.tradingview.com/script/uYLlfioJ-QH-Triple-Pro-Lite/
- type: indicator
- pine_id: PUB;96d3be1e4aef4fb49a78808177ca75ac
- version: 1.0

## Description

QH Triple Pro Lite was created to simplify the decision-making process for traders who want clear directional bias without filling their charts with dozens of indicators.

The script evaluates multiple market factors and converts them into a simple visual dashboard.

The panel displays:

• Trade Direction
• Setup Quality
• Entry Readiness
• Confidence Score
• Trade Status

The objective is not to predict every market move, but to identify higher-quality trend opportunities and filter out lower-probability conditions.

Typical outputs include:

YES – LONG
YES – SHORT
NO TRADE

The indicator is designed primarily for cryptocurrency markets and performs best when used on higher timeframes such as 1H, 2H, 4H, 6H and Daily charts.

Suggested Use:
1. Wait for the panel to display a valid trade direction.
2. Focus on higher-confidence setups.
3. Use your own risk management and position sizing.
4. Combine with support/resistance and market structure analysis for confirmation.

Disclaimer:
This indicator is for educational and informational purposes only and does not provide financial advice. Trading involves risk and past performance does not guarantee future results.

Created by Quantum Harmonics
QH Triple Pro Series

## Source Code

````pine
//@version=6
indicator("QH Triple Pro Lite v3", shorttitle="QH Triple Lite v3", overlay=true, max_labels_count=500)

// INPUTS
mode = input.string("Balanced", "Mode", options=["Conservative", "Balanced", "Aggressive"])
fastLen = input.int(34, "Fast EMA")
slowLen = input.int(144, "Slow EMA")
ceLen = input.int(22, "Chandelier ATR Length")
ceMult = input.float(3.0, "Chandelier ATR Multiplier", step=0.1)
rsiLen = input.int(14, "RSI Length")
rsiSmooth = input.int(5, "RSI Smooth")
volLen = input.int(20, "Volume MA")
useHTF = input.bool(true, "Use Higher Timeframe Bias")
oneSignalOnly = input.bool(true, "One Signal Per Direction")
cooldownBars = input.int(8, "Signal Cooldown Bars", minval=1)
showPanel = input.bool(true, "Show Panel")
showSignals = input.bool(true, "Show Signals")
showEMAs = input.bool(true, "Show EMAs")
panelPos = input.string("Top Right", "Panel Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])
panelSize = input.string("Small", "Panel Size", options=["Tiny", "Small", "Normal", "Large"])

pos = panelPos == "Top Left" ? position.top_left : panelPos == "Bottom Right" ? position.bottom_right : panelPos == "Bottom Left" ? position.bottom_left : position.top_right
txt = panelSize == "Tiny" ? size.tiny : panelSize == "Normal" ? size.normal : panelSize == "Large" ? size.large : size.small

// CORE TREND
atr = ta.atr(ceLen)
longStopRaw = ta.highest(close, ceLen) - ceMult * atr
shortStopRaw = ta.lowest(close, ceLen) + ceMult * atr

var float longStop = na
var float shortStop = na
longStop := na(longStop[1]) ? longStopRaw : close[1] > longStop[1] ? math.max(longStopRaw, longStop[1]) : longStopRaw
shortStop := na(shortStop[1]) ? shortStopRaw : close[1] < shortStop[1] ? math.min(shortStopRaw, shortStop[1]) : shortStopRaw

var int ceDir = 1
ceDir := close > nz(shortStop[1], shortStop) ? 1 : close < nz(longStop[1], longStop) ? -1 : ceDir

emaFast = ta.ema(close, fastLen)
emaSlow = ta.ema(close, slowLen)

trendLong = emaFast > emaSlow
trendShort = emaFast < emaSlow
ceLong = ceDir == 1
ceShort = ceDir == -1

// MOMENTUM
rsi = ta.rsi(close, rsiLen)
rsiMa = ta.ema(rsi, rsiSmooth)
momLong = rsiMa > 50 and rsiMa > rsiMa[1]
momShort = rsiMa < 50 and rsiMa < rsiMa[1]

// VOLUME
volMA = ta.sma(volume, volLen)
volRatio = volMA > 0 ? volume / volMA : 0.0
volStrong = volRatio >= 1.0
volGood = volRatio >= 0.75
volOkay = volRatio >= 0.50

// HTF BIAS
dFast = request.security(syminfo.tickerid, "D", ta.ema(close, 20))
dSlow = request.security(syminfo.tickerid, "D", ta.ema(close, 50))
wFast = request.security(syminfo.tickerid, "W", ta.ema(close, 20))
wSlow = request.security(syminfo.tickerid, "W", ta.ema(close, 50))

htfLong = dFast > dSlow and wFast > wSlow
htfShort = dFast < dSlow and wFast < wSlow
htfLongOK = not useHTF or htfLong or mode == "Aggressive"
htfShortOK = not useHTF or htfShort or mode == "Aggressive"

// CONFIDENCE SCORE
float longScore = 0.0
float shortScore = 0.0

longScore += trendLong ? 25 : 0
longScore += ceLong ? 25 : 0
longScore += momLong ? 20 : 0
longScore += htfLongOK ? 20 : 0
longScore += volStrong ? 10 : volGood ? 7 : volOkay ? 4 : 0

shortScore += trendShort ? 25 : 0
shortScore += ceShort ? 25 : 0
shortScore += momShort ? 20 : 0
shortScore += htfShortOK ? 20 : 0
shortScore += volStrong ? 10 : volGood ? 7 : volOkay ? 4 : 0

direction = longScore > shortScore ? 1 : shortScore > longScore ? -1 : 0
confidence = direction == 1 ? longScore : direction == -1 ? shortScore : 0.0

grade = confidence >= 90 ? "A+" : confidence >= 80 ? "A" : confidence >= 70 ? "B" : confidence >= 60 ? "C" : "D"

// ENTRY LOGIC
entryReadyLong = confidence >= 90 or (confidence >= 80 and (low <= emaFast or close > high[1]))
entryReadyShort = confidence >= 90 or (confidence >= 80 and (high >= emaFast or close < low[1]))

rawLong = direction == 1 and htfLongOK and entryReadyLong and confidence >= 80
rawShort = direction == -1 and htfShortOK and entryReadyShort and confidence >= 80

// ONE SIGNAL CONTROL
var int lastSignalDir = 0
var int lastSignalBar = na

cooldownOK = na(lastSignalBar) or bar_index - lastSignalBar > cooldownBars
dirOKLong = not oneSignalOnly or lastSignalDir != 1
dirOKShort = not oneSignalOnly or lastSignalDir != -1

takeLong = rawLong and cooldownOK and dirOKLong
takeShort = rawShort and cooldownOK and dirOKShort

if takeLong
    lastSignalDir := 1
    lastSignalBar := bar_index

if takeShort
    lastSignalDir := -1
    lastSignalBar := bar_index

entryReady = direction == 1 ? entryReadyLong : direction == -1 ? entryReadyShort : false

tradeText = confidence >= 90 and direction == 1 ? "YES - LONG" : confidence >= 90 and direction == -1 ? "YES - SHORT" : takeLong ? "YES - LONG" : takeShort ? "YES - SHORT" : "NO"
statusText = confidence >= 90 and direction == 1 ? "TAKE LONG" : confidence >= 90 and direction == -1 ? "TAKE SHORT" : takeLong ? "TAKE LONG" : takeShort ? "TAKE SHORT" : confidence >= 80 ? "WAIT ENTRY" : confidence >= 70 ? "WATCHLIST" : "WAIT"

tradeColor = confidence >= 90 and direction == 1 ? color.green : confidence >= 90 and direction == -1 ? color.red : takeLong ? color.green : takeShort ? color.red : color.gray
dirColor = direction == 1 ? color.green : direction == -1 ? color.red : color.gray
gradeColor = confidence >= 90 ? color.green : confidence >= 80 ? color.lime : confidence >= 70 ? color.orange : color.red
entryColor = entryReady ? color.green : color.orange

// PLOTS
plot(showEMAs ? emaFast : na, "Fast EMA", color=color.blue)
plot(showEMAs ? emaSlow : na, "Slow EMA", color=color.orange)
plot(ceDir == 1 ? longStop : na, "Bull Stop", color=color.green, linewidth=2, style=plot.style_linebr)
plot(ceDir == -1 ? shortStop : na, "Bear Stop", color=color.red, linewidth=2, style=plot.style_linebr)

plotshape(showSignals and takeLong, title="QH Lite TAKE LONG", text="TAKE\nLONG", style=shape.labelup, location=location.belowbar, color=color.lime, textcolor=color.black, size=size.small)
plotshape(showSignals and takeShort, title="QH Lite TAKE SHORT", text="TAKE\nSHORT", style=shape.labeldown, location=location.abovebar, color=color.red, textcolor=color.white, size=size.small)

// ALERTS
alertcondition(takeLong, title="QH Triple Lite TAKE LONG", message="QH Triple Pro Lite v3: TAKE LONG")
alertcondition(takeShort, title="QH Triple Lite TAKE SHORT", message="QH Triple Pro Lite v3: TAKE SHORT")

// PANEL
var table panel = table.new(pos, 2, 7, border_width=1)

if showPanel and barstate.islast
    table.cell(panel, 0, 0, "QH TRIPLE PRO", text_color=color.white, bgcolor=color.black, text_size=txt)
    table.cell(panel, 1, 0, "LITE v3", text_color=color.white, bgcolor=color.black, text_size=txt)

    table.cell(panel, 0, 1, "TRADE?", text_color=color.white, bgcolor=color.black, text_size=txt)
    table.cell(panel, 1, 1, tradeText, text_color=color.white, bgcolor=tradeColor, text_size=txt)

    table.cell(panel, 0, 2, "DIRECTION", text_color=color.white, bgcolor=color.black, text_size=txt)
    table.cell(panel, 1, 2, direction == 1 ? "LONG" : direction == -1 ? "SHORT" : "NEUTRAL", text_color=color.white, bgcolor=dirColor, text_size=txt)

    table.cell(panel, 0, 3, "SETUP", text_color=color.white, bgcolor=color.black, text_size=txt)
    table.cell(panel, 1, 3, grade, text_color=color.white, bgcolor=gradeColor, text_size=txt)

    table.cell(panel, 0, 4, "ENTRY READY", text_color=color.white, bgcolor=color.black, text_size=txt)
    table.cell(panel, 1, 4, entryReady ? "YES" : "NO", text_color=color.white, bgcolor=entryColor, text_size=txt)

    table.cell(panel, 0, 5, "CONFIDENCE", text_color=color.white, bgcolor=color.black, text_size=txt)
    table.cell(panel, 1, 5, str.tostring(confidence, "#") + "%", text_color=color.white, bgcolor=gradeColor, text_size=txt)

    table.cell(panel, 0, 6, "STATUS", text_color=color.white, bgcolor=color.black, text_size=txt)
    table.cell(panel, 1, 6, statusText, text_color=color.white, bgcolor=tradeColor, text_size=txt)
````
