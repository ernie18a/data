# Bull Market Support Band + Dual Weekly Divergences

- url: https://www.tradingview.com/script/eIJubLvT-Bull-Market-Support-Band-Dual-Weekly-Divergences/
- type: indicator
- pine_id: PUB;caa05e28a57140f9833fdf52a5725705
- version: 1.0

## Description

Bull Market Support Band + Weekly Divergences

The Bull Market Support Band + Weekly Divergences expands the classic 20-Week SMA / 21-Week EMA Bull Market Support Band with a powerful divergence engine designed to help identify weakening trends, potential reversals and trend continuation on the weekly timeframe.

Instead of relying only on price crossing the support band, this indicator looks for situations where price begins to disagree with momentum or the behaviour of the support band itself, often providing earlier warnings of important market turning points.

Features

• Classic Bull Market Support Band (20W SMA & 21W EMA)

• Weekly calculations on any chart timeframe

• Simultaneous divergence detection using:

2 Left / 1 Right pivots
3 Left / 1 Right pivots

• Regular and Hidden divergences

• Four independent divergence engines:

RSI Divergences
Band Distance Divergences
Band Momentum Divergences
Band Width Divergences

• Individual enable/disable switches for every divergence family

• Optional divergence trend lines

• Compact chart labels with detailed hover explanations

• Bullish and bearish alerts

Divergence Types

RSI Divergence

Compares weekly price with weekly RSI.

Useful for detecting:

Momentum exhaustion
Early reversals
Trend continuation

Band Distance Divergence

Measures how far price is from the Bull Market Support Band.

Useful for identifying:

Weak breakouts
Weak breakdowns
Improving relative strength
Fading macro momentum

Band Momentum Divergence

Measures the rate of change of the support band itself.

This can reveal situations where:

Price continues making new highs while the support band loses momentum.
Price makes new lows while the macro trend is already stabilising.

Band Width Divergence

Monitors the distance between the weekly SMA and EMA.

Useful for spotting:

Trend compression
Expansion
Potential regime changes
Loss of long-term trend strength
Signal Labels

Signals remain intentionally short to keep charts clean.

Examples:

2L R+

2 Left / 1 Right RSI Regular Bullish Divergence

3L RH−

3 Left / 1 Right RSI Hidden Bearish Divergence

2L D+

Band Distance Regular Bullish Divergence

3L M−

Band Momentum Regular Bearish Divergence

WH

Band Width Hidden Divergence

Hover your mouse over any signal to view a detailed explanation of what it represents and why it was generated.

Pivot Detection

The indicator evaluates two weekly pivot structures simultaneously:

2 Left / 1 Right — earlier signals with higher sensitivity.
3 Left / 1 Right — more selective signals with stronger confirmation.

This lets traders compare faster and more conservative divergence setups without switching settings.

Best Used For
Bitcoin
Crypto markets
Long-term trend analysis
Macro cycle analysis
Swing trading
Position trading

Although optimized for cryptocurrencies, it can also be applied to stocks, indices, commodities and other markets.

Disclaimer

This indicator highlights potential divergence conditions. Divergences do not guarantee reversals or trend continuation and should be used alongside market structure, volume, support and resistance, and sound risk management.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
// © zkdev
// Modified: simultaneous 2-left/1-right and 3-left/1-right weekly divergences

//@version=6
indicator("Bull Market Support Band + Dual Weekly Divergences", shorttitle="BMSB Dual Div", overlay=true, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SUPPORT BAND
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupBand = "Bull Market Support Band"

source = input.source(close, "Source", group=groupBand)
smaLength = input.int(20, "Weekly SMA Length", minval=1, group=groupBand)
emaLength = input.int(21, "Weekly EMA Length", minval=1, group=groupBand)
showBand = input.bool(true, "Show Support Band", group=groupBand)
showFill = input.bool(true, "Fill Support Band", group=groupBand)

weeklySma = request.security(syminfo.tickerid, "W", ta.sma(source, smaLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
weeklyEma = request.security(syminfo.tickerid, "W", ta.ema(source, emaLength), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

smaPlot = plot(showBand ? weeklySma : na, title="20W SMA", color=color.red, linewidth=2)
emaPlot = plot(showBand ? weeklyEma : na, title="21W EMA", color=color.green, linewidth=2)
fill(smaPlot, emaPlot, title="Bull Market Support Band", color=showFill ? color.new(color.orange, 75) : na, fillgaps=true)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIVERGENCE SETTINGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDetection = "Weekly Divergence Detection"

show2Left = input.bool(true, "Show 2-Left / 1-Right Divergences", group=groupDetection)
show3Left = input.bool(true, "Show 3-Left / 1-Right Divergences", group=groupDetection)

minimumPivotDistance = input.int(2, "Minimum Weeks Between Pivots", minval=1, group=groupDetection)
maximumPivotDistance = input.int(40, "Maximum Weeks Between Pivots", minval=5, group=groupDetection)

showRegular = input.bool(true, "Show Regular Divergences", group=groupDetection)
showHidden = input.bool(true, "Show Hidden Divergences", group=groupDetection)
showLines = input.bool(true, "Show Price Divergence Lines", group=groupDetection)

// Both engines use one completed weekly candle on the right.
pivotRight = 1

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DIVERGENCE FAMILIES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupFamilies = "Divergence Families"

showRsi = input.bool(true, "RSI Divergences", group=groupFamilies)
rsiLength = input.int(14, "Weekly RSI Length", minval=2, group=groupFamilies)

showDistance = input.bool(true, "Band-Distance Divergences", group=groupFamilies)
showMomentum = input.bool(true, "Band-Momentum Divergences", group=groupFamilies)
momentumLength = input.int(4, "Band Momentum Length", minval=1, group=groupFamilies)
showWidth = input.bool(false, "Band-Width Divergences", group=groupFamilies)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DISPLAY
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
groupDisplay = "Display"

bullishColor = input.color(color.rgb(0, 100, 50), "Bullish Colour", group=groupDisplay)
bearishColor = input.color(color.rgb(115, 45, 150), "Bearish Colour", group=groupDisplay)
hiddenTransparency = input.int(25, "Hidden Signal Transparency", minval=0, maxval=90, group=groupDisplay)
lineWidth = input.int(2, "Divergence Line Width", minval=1, maxval=4, group=groupDisplay)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// WEEKLY PIVOT PACKAGES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_lowPackage(int leftBars) =>
    float smaW = ta.sma(source, smaLength)
    float emaW = ta.ema(source, emaLength)
    float midW = math.avg(smaW, emaW)
    float rsiW = ta.rsi(source, rsiLength)
    float distanceW = not na(midW) and midW != 0.0 ? ((source - midW) / midW) * 100.0 : na
    float momentumW = not na(midW[momentumLength]) and midW[momentumLength] != 0.0 ? ((midW - midW[momentumLength]) / midW[momentumLength]) * 100.0 : na
    float widthW = not na(midW) and midW != 0.0 ? math.abs(smaW - emaW) / midW * 100.0 : na
    float p = ta.pivotlow(low, leftBars, pivotRight)
    [p, not na(p) ? rsiW[pivotRight] : na, not na(p) ? distanceW[pivotRight] : na, not na(p) ? momentumW[pivotRight] : na, not na(p) ? widthW[pivotRight] : na, not na(p) ? time[pivotRight] : na]

f_highPackage(int leftBars) =>
    float smaW = ta.sma(source, smaLength)
    float emaW = ta.ema(source, emaLength)
    float midW = math.avg(smaW, emaW)
    float rsiW = ta.rsi(source, rsiLength)
    float distanceW = not na(midW) and midW != 0.0 ? ((source - midW) / midW) * 100.0 : na
    float momentumW = not na(midW[momentumLength]) and midW[momentumLength] != 0.0 ? ((midW - midW[momentumLength]) / midW[momentumLength]) * 100.0 : na
    float widthW = not na(midW) and midW != 0.0 ? math.abs(smaW - emaW) / midW * 100.0 : na
    float p = ta.pivothigh(high, leftBars, pivotRight)
    [p, not na(p) ? rsiW[pivotRight] : na, not na(p) ? distanceW[pivotRight] : na, not na(p) ? momentumW[pivotRight] : na, not na(p) ? widthW[pivotRight] : na, not na(p) ? time[pivotRight] : na]

[low2, lowRsi2, lowDistance2, lowMomentum2, lowWidth2, lowTime2] = request.security(syminfo.tickerid, "W", f_lowPackage(2), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
[high2, highRsi2, highDistance2, highMomentum2, highWidth2, highTime2] = request.security(syminfo.tickerid, "W", f_highPackage(2), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)

[low3, lowRsi3, lowDistance3, lowMomentum3, lowWidth3, lowTime3] = request.security(syminfo.tickerid, "W", f_lowPackage(3), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)
[high3, highRsi3, highDistance3, highMomentum3, highWidth3, highTime3] = request.security(syminfo.tickerid, "W", f_highPackage(3), gaps=barmerge.gaps_on, lookahead=barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// HELPERS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
f_weeksApart(int currentTime, int previousTime) =>
    int millisecondsPerWeek = 7 * 24 * 60 * 60 * 1000
    int(math.round((currentTime - previousTime) / millisecondsPerWeek))

f_validDistance(int currentTime, int previousTime) =>
    int weeks = f_weeksApart(currentTime, previousTime)
    weeks >= minimumPivotDistance and weeks <= maximumPivotDistance

f_bullRegular(float currentPrice, float previousPrice, float currentOsc, float previousOsc) =>
    currentPrice < previousPrice and currentOsc > previousOsc

f_bullHidden(float currentPrice, float previousPrice, float currentOsc, float previousOsc) =>
    currentPrice > previousPrice and currentOsc < previousOsc

f_bearRegular(float currentPrice, float previousPrice, float currentOsc, float previousOsc) =>
    currentPrice > previousPrice and currentOsc < previousOsc

f_bearHidden(float currentPrice, float previousPrice, float currentOsc, float previousOsc) =>
    currentPrice < previousPrice and currentOsc > previousOsc

f_bullLabel(int signalTime, float signalPrice, string signalText, string tooltipText, color signalColor) =>
    label.new(signalTime, signalPrice, signalText, xloc=xloc.bar_time, yloc=yloc.belowbar, style=label.style_label_up, color=signalColor, textcolor=color.white, size=size.tiny, tooltip=tooltipText)

f_bearLabel(int signalTime, float signalPrice, string signalText, string tooltipText, color signalColor) =>
    label.new(signalTime, signalPrice, signalText, xloc=xloc.bar_time, yloc=yloc.abovebar, style=label.style_label_down, color=signalColor, textcolor=color.white, size=size.tiny, tooltip=tooltipText)

f_divLine(int previousTime, float previousPrice, int currentTime, float currentPrice, color signalColor) =>
    if showLines
        line.new(previousTime, previousPrice, currentTime, currentPrice, xloc=xloc.bar_time, extend=extend.none, color=signalColor, width=lineWidth)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERT FLAGS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
bool bullRegularAlert = false
bool bullHiddenAlert = false
bool bearRegularAlert = false
bool bearHiddenAlert = false

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORED PIVOTS: 2 LEFT / 1 RIGHT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float prevRLowPrice2 = na
var float prevRLowValue2 = na
var int prevRLowTime2 = na
var float prevRHighPrice2 = na
var float prevRHighValue2 = na
var int prevRHighTime2 = na

var float prevDLowPrice2 = na
var float prevDLowValue2 = na
var int prevDLowTime2 = na
var float prevDHighPrice2 = na
var float prevDHighValue2 = na
var int prevDHighTime2 = na

var float prevMLowPrice2 = na
var float prevMLowValue2 = na
var int prevMLowTime2 = na
var float prevMHighPrice2 = na
var float prevMHighValue2 = na
var int prevMHighTime2 = na

var float prevWLowPrice2 = na
var float prevWLowValue2 = na
var int prevWLowTime2 = na
var float prevWHighPrice2 = na
var float prevWHighValue2 = na
var int prevWHighTime2 = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// STORED PIVOTS: 3 LEFT / 1 RIGHT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
var float prevRLowPrice3 = na
var float prevRLowValue3 = na
var int prevRLowTime3 = na
var float prevRHighPrice3 = na
var float prevRHighValue3 = na
var int prevRHighTime3 = na

var float prevDLowPrice3 = na
var float prevDLowValue3 = na
var int prevDLowTime3 = na
var float prevDHighPrice3 = na
var float prevDHighValue3 = na
var int prevDHighTime3 = na

var float prevMLowPrice3 = na
var float prevMLowValue3 = na
var int prevMLowTime3 = na
var float prevMHighPrice3 = na
var float prevMHighValue3 = na
var int prevMHighTime3 = na

var float prevWLowPrice3 = na
var float prevWLowValue3 = na
var int prevWLowTime3 = na
var float prevWHighPrice3 = na
var float prevWHighValue3 = na
var int prevWHighTime3 = na

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2-LEFT / 1-RIGHT LOW PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if show2Left and not na(low2) and not na(lowTime2)
    int currentTime = int(lowTime2)
    float currentPrice = low2

    if showRsi and not na(lowRsi2)
        bool hasPrevious = not na(prevRLowPrice2) and not na(prevRLowValue2) and not na(prevRLowTime2)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevRLowTime2) : false
        bool regularSignal = distanceValid and showRegular and f_bullRegular(currentPrice, prevRLowPrice2, lowRsi2, prevRLowValue2)
        bool hiddenSignal = distanceValid and showHidden and f_bullHidden(currentPrice, prevRLowPrice2, lowRsi2, prevRLowValue2)

        if regularSignal
            f_bullLabel(currentTime, currentPrice, "2L R+", "RSI Regular Bullish Divergence — 2 Left / 1 Right\n\nPrice formed a lower weekly low while Weekly RSI formed a higher low.\n\nThis shows disagreement between price and momentum.", bullishColor)
            f_divLine(prevRLowTime2, prevRLowPrice2, currentTime, currentPrice, bullishColor)
            bullRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bullishColor, hiddenTransparency)
            f_bullLabel(currentTime, currentPrice, "2L RH+", "RSI Hidden Bullish Divergence — 2 Left / 1 Right\n\nPrice formed a higher weekly low while Weekly RSI formed a lower low.\n\nThis can support bullish trend continuation.", hiddenColor)
            f_divLine(prevRLowTime2, prevRLowPrice2, currentTime, currentPrice, hiddenColor)
            bullHiddenAlert := true

        prevRLowPrice2 := currentPrice
        prevRLowValue2 := lowRsi2
        prevRLowTime2 := currentTime

    if showDistance and not na(lowDistance2)
        bool hasPrevious = not na(prevDLowPrice2) and not na(prevDLowValue2) and not na(prevDLowTime2)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevDLowTime2) : false
        bool regularSignal = distanceValid and showRegular and f_bullRegular(currentPrice, prevDLowPrice2, lowDistance2, prevDLowValue2)
        bool hiddenSignal = distanceValid and showHidden and f_bullHidden(currentPrice, prevDLowPrice2, lowDistance2, prevDLowValue2)

        if regularSignal
            f_bullLabel(currentTime, currentPrice, "2L D+", "Band Distance Regular Bullish Divergence — 2 Left / 1 Right\n\nPrice formed a lower weekly low while price's percentage distance from the centre of the weekly support band formed a higher low.\n\nThis shows disagreement between price and relative strength.", bullishColor)
            f_divLine(prevDLowTime2, prevDLowPrice2, currentTime, currentPrice, bullishColor)
            bullRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bullishColor, hiddenTransparency)
            f_bullLabel(currentTime, currentPrice, "2L DH+", "Band Distance Hidden Bullish Divergence — 2 Left / 1 Right\n\nPrice formed a higher weekly low while price's percentage distance from the centre of the weekly support band formed a lower low.\n\nThis can support bullish trend continuation.", hiddenColor)
            f_divLine(prevDLowTime2, prevDLowPrice2, currentTime, currentPrice, hiddenColor)
            bullHiddenAlert := true

        prevDLowPrice2 := currentPrice
        prevDLowValue2 := lowDistance2
        prevDLowTime2 := currentTime

    if showMomentum and not na(lowMomentum2)
        bool hasPrevious = not na(prevMLowPrice2) and not na(prevMLowValue2) and not na(prevMLowTime2)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevMLowTime2) : false
        bool regularSignal = distanceValid and showRegular and f_bullRegular(currentPrice, prevMLowPrice2, lowMomentum2, prevMLowValue2)
        bool hiddenSignal = distanceValid and showHidden and f_bullHidden(currentPrice, prevMLowPrice2, lowMomentum2, prevMLowValue2)

        if regularSignal
            f_bullLabel(currentTime, currentPrice, "2L M+", "Band Momentum Regular Bullish Divergence — 2 Left / 1 Right\n\nPrice formed a lower weekly low while the weekly support band's rate of change formed a higher low.\n\nThis shows disagreement between price and macro support momentum.", bullishColor)
            f_divLine(prevMLowTime2, prevMLowPrice2, currentTime, currentPrice, bullishColor)
            bullRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bullishColor, hiddenTransparency)
            f_bullLabel(currentTime, currentPrice, "2L MH+", "Band Momentum Hidden Bullish Divergence — 2 Left / 1 Right\n\nPrice formed a higher weekly low while the weekly support band's rate of change formed a lower low.\n\nThis can support bullish trend continuation.", hiddenColor)
            f_divLine(prevMLowTime2, prevMLowPrice2, currentTime, currentPrice, hiddenColor)
            bullHiddenAlert := true

        prevMLowPrice2 := currentPrice
        prevMLowValue2 := lowMomentum2
        prevMLowTime2 := currentTime

    if showWidth and not na(lowWidth2)
        bool hasPrevious = not na(prevWLowPrice2) and not na(prevWLowValue2) and not na(prevWLowTime2)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevWLowTime2) : false
        bool regularSignal = distanceValid and showRegular and f_bullRegular(currentPrice, prevWLowPrice2, lowWidth2, prevWLowValue2)
        bool hiddenSignal = distanceValid and showHidden and f_bullHidden(currentPrice, prevWLowPrice2, lowWidth2, prevWLowValue2)

        if regularSignal
            f_bullLabel(currentTime, currentPrice, "2L W+", "Band Width Regular Bullish Divergence — 2 Left / 1 Right\n\nPrice formed a lower weekly low while the percentage separation between the weekly SMA and EMA formed a higher low.\n\nThis shows disagreement between price and support-band expansion.", bullishColor)
            f_divLine(prevWLowTime2, prevWLowPrice2, currentTime, currentPrice, bullishColor)
            bullRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bullishColor, hiddenTransparency)
            f_bullLabel(currentTime, currentPrice, "2L WH+", "Band Width Hidden Bullish Divergence — 2 Left / 1 Right\n\nPrice formed a higher weekly low while the percentage separation between the weekly SMA and EMA formed a lower low.\n\nThis can support bullish trend continuation.", hiddenColor)
            f_divLine(prevWLowTime2, prevWLowPrice2, currentTime, currentPrice, hiddenColor)
            bullHiddenAlert := true

        prevWLowPrice2 := currentPrice
        prevWLowValue2 := lowWidth2
        prevWLowTime2 := currentTime

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2-LEFT / 1-RIGHT HIGH PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if show2Left and not na(high2) and not na(highTime2)
    int currentTime = int(highTime2)
    float currentPrice = high2

    if showRsi and not na(highRsi2)
        bool hasPrevious = not na(prevRHighPrice2) and not na(prevRHighValue2) and not na(prevRHighTime2)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevRHighTime2) : false
        bool regularSignal = distanceValid and showRegular and f_bearRegular(currentPrice, prevRHighPrice2, highRsi2, prevRHighValue2)
        bool hiddenSignal = distanceValid and showHidden and f_bearHidden(currentPrice, prevRHighPrice2, highRsi2, prevRHighValue2)

        if regularSignal
            f_bearLabel(currentTime, currentPrice, "2L R−", "RSI Regular Bearish Divergence — 2 Left / 1 Right\n\nPrice formed a higher weekly high while Weekly RSI formed a lower high.\n\nThis shows disagreement between price and momentum.", bearishColor)
            f_divLine(prevRHighTime2, prevRHighPrice2, currentTime, currentPrice, bearishColor)
            bearRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bearishColor, hiddenTransparency)
            f_bearLabel(currentTime, currentPrice, "2L RH−", "RSI Hidden Bearish Divergence — 2 Left / 1 Right\n\nPrice formed a lower weekly high while Weekly RSI formed a higher high.\n\nThis can support bearish trend continuation.", hiddenColor)
            f_divLine(prevRHighTime2, prevRHighPrice2, currentTime, currentPrice, hiddenColor)
            bearHiddenAlert := true

        prevRHighPrice2 := currentPrice
        prevRHighValue2 := highRsi2
        prevRHighTime2 := currentTime

    if showDistance and not na(highDistance2)
        bool hasPrevious = not na(prevDHighPrice2) and not na(prevDHighValue2) and not na(prevDHighTime2)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevDHighTime2) : false
        bool regularSignal = distanceValid and showRegular and f_bearRegular(currentPrice, prevDHighPrice2, highDistance2, prevDHighValue2)
        bool hiddenSignal = distanceValid and showHidden and f_bearHidden(currentPrice, prevDHighPrice2, highDistance2, prevDHighValue2)

        if regularSignal
            f_bearLabel(currentTime, currentPrice, "2L D−", "Band Distance Regular Bearish Divergence — 2 Left / 1 Right\n\nPrice formed a higher weekly high while price's percentage distance from the centre of the weekly support band formed a lower high.\n\nThis shows disagreement between price and relative strength.", bearishColor)
            f_divLine(prevDHighTime2, prevDHighPrice2, currentTime, currentPrice, bearishColor)
            bearRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bearishColor, hiddenTransparency)
            f_bearLabel(currentTime, currentPrice, "2L DH−", "Band Distance Hidden Bearish Divergence — 2 Left / 1 Right\n\nPrice formed a lower weekly high while price's percentage distance from the centre of the weekly support band formed a higher high.\n\nThis can support bearish trend continuation.", hiddenColor)
            f_divLine(prevDHighTime2, prevDHighPrice2, currentTime, currentPrice, hiddenColor)
            bearHiddenAlert := true

        prevDHighPrice2 := currentPrice
        prevDHighValue2 := highDistance2
        prevDHighTime2 := currentTime

    if showMomentum and not na(highMomentum2)
        bool hasPrevious = not na(prevMHighPrice2) and not na(prevMHighValue2) and not na(prevMHighTime2)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevMHighTime2) : false
        bool regularSignal = distanceValid and showRegular and f_bearRegular(currentPrice, prevMHighPrice2, highMomentum2, prevMHighValue2)
        bool hiddenSignal = distanceValid and showHidden and f_bearHidden(currentPrice, prevMHighPrice2, highMomentum2, prevMHighValue2)

        if regularSignal
            f_bearLabel(currentTime, currentPrice, "2L M−", "Band Momentum Regular Bearish Divergence — 2 Left / 1 Right\n\nPrice formed a higher weekly high while the weekly support band's rate of change formed a lower high.\n\nThis shows disagreement between price and macro support momentum.", bearishColor)
            f_divLine(prevMHighTime2, prevMHighPrice2, currentTime, currentPrice, bearishColor)
            bearRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bearishColor, hiddenTransparency)
            f_bearLabel(currentTime, currentPrice, "2L MH−", "Band Momentum Hidden Bearish Divergence — 2 Left / 1 Right\n\nPrice formed a lower weekly high while the weekly support band's rate of change formed a higher high.\n\nThis can support bearish trend continuation.", hiddenColor)
            f_divLine(prevMHighTime2, prevMHighPrice2, currentTime, currentPrice, hiddenColor)
            bearHiddenAlert := true

        prevMHighPrice2 := currentPrice
        prevMHighValue2 := highMomentum2
        prevMHighTime2 := currentTime

    if showWidth and not na(highWidth2)
        bool hasPrevious = not na(prevWHighPrice2) and not na(prevWHighValue2) and not na(prevWHighTime2)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevWHighTime2) : false
        bool regularSignal = distanceValid and showRegular and f_bearRegular(currentPrice, prevWHighPrice2, highWidth2, prevWHighValue2)
        bool hiddenSignal = distanceValid and showHidden and f_bearHidden(currentPrice, prevWHighPrice2, highWidth2, prevWHighValue2)

        if regularSignal
            f_bearLabel(currentTime, currentPrice, "2L W−", "Band Width Regular Bearish Divergence — 2 Left / 1 Right\n\nPrice formed a higher weekly high while the percentage separation between the weekly SMA and EMA formed a lower high.\n\nThis shows disagreement between price and support-band expansion.", bearishColor)
            f_divLine(prevWHighTime2, prevWHighPrice2, currentTime, currentPrice, bearishColor)
            bearRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bearishColor, hiddenTransparency)
            f_bearLabel(currentTime, currentPrice, "2L WH−", "Band Width Hidden Bearish Divergence — 2 Left / 1 Right\n\nPrice formed a lower weekly high while the percentage separation between the weekly SMA and EMA formed a higher high.\n\nThis can support bearish trend continuation.", hiddenColor)
            f_divLine(prevWHighTime2, prevWHighPrice2, currentTime, currentPrice, hiddenColor)
            bearHiddenAlert := true

        prevWHighPrice2 := currentPrice
        prevWHighValue2 := highWidth2
        prevWHighTime2 := currentTime

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3-LEFT / 1-RIGHT LOW PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if show3Left and not na(low3) and not na(lowTime3)
    int currentTime = int(lowTime3)
    float currentPrice = low3

    if showRsi and not na(lowRsi3)
        bool hasPrevious = not na(prevRLowPrice3) and not na(prevRLowValue3) and not na(prevRLowTime3)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevRLowTime3) : false
        bool regularSignal = distanceValid and showRegular and f_bullRegular(currentPrice, prevRLowPrice3, lowRsi3, prevRLowValue3)
        bool hiddenSignal = distanceValid and showHidden and f_bullHidden(currentPrice, prevRLowPrice3, lowRsi3, prevRLowValue3)

        if regularSignal
            f_bullLabel(currentTime, currentPrice, "3L R+", "RSI Regular Bullish Divergence — 3 Left / 1 Right\n\nPrice formed a lower weekly low while Weekly RSI formed a higher low.\n\nThis shows disagreement between price and momentum.", bullishColor)
            f_divLine(prevRLowTime3, prevRLowPrice3, currentTime, currentPrice, bullishColor)
            bullRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bullishColor, hiddenTransparency)
            f_bullLabel(currentTime, currentPrice, "3L RH+", "RSI Hidden Bullish Divergence — 3 Left / 1 Right\n\nPrice formed a higher weekly low while Weekly RSI formed a lower low.\n\nThis can support bullish trend continuation.", hiddenColor)
            f_divLine(prevRLowTime3, prevRLowPrice3, currentTime, currentPrice, hiddenColor)
            bullHiddenAlert := true

        prevRLowPrice3 := currentPrice
        prevRLowValue3 := lowRsi3
        prevRLowTime3 := currentTime

    if showDistance and not na(lowDistance3)
        bool hasPrevious = not na(prevDLowPrice3) and not na(prevDLowValue3) and not na(prevDLowTime3)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevDLowTime3) : false
        bool regularSignal = distanceValid and showRegular and f_bullRegular(currentPrice, prevDLowPrice3, lowDistance3, prevDLowValue3)
        bool hiddenSignal = distanceValid and showHidden and f_bullHidden(currentPrice, prevDLowPrice3, lowDistance3, prevDLowValue3)

        if regularSignal
            f_bullLabel(currentTime, currentPrice, "3L D+", "Band Distance Regular Bullish Divergence — 3 Left / 1 Right\n\nPrice formed a lower weekly low while price's percentage distance from the centre of the weekly support band formed a higher low.\n\nThis shows disagreement between price and relative strength.", bullishColor)
            f_divLine(prevDLowTime3, prevDLowPrice3, currentTime, currentPrice, bullishColor)
            bullRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bullishColor, hiddenTransparency)
            f_bullLabel(currentTime, currentPrice, "3L DH+", "Band Distance Hidden Bullish Divergence — 3 Left / 1 Right\n\nPrice formed a higher weekly low while price's percentage distance from the centre of the weekly support band formed a lower low.\n\nThis can support bullish trend continuation.", hiddenColor)
            f_divLine(prevDLowTime3, prevDLowPrice3, currentTime, currentPrice, hiddenColor)
            bullHiddenAlert := true

        prevDLowPrice3 := currentPrice
        prevDLowValue3 := lowDistance3
        prevDLowTime3 := currentTime

    if showMomentum and not na(lowMomentum3)
        bool hasPrevious = not na(prevMLowPrice3) and not na(prevMLowValue3) and not na(prevMLowTime3)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevMLowTime3) : false
        bool regularSignal = distanceValid and showRegular and f_bullRegular(currentPrice, prevMLowPrice3, lowMomentum3, prevMLowValue3)
        bool hiddenSignal = distanceValid and showHidden and f_bullHidden(currentPrice, prevMLowPrice3, lowMomentum3, prevMLowValue3)

        if regularSignal
            f_bullLabel(currentTime, currentPrice, "3L M+", "Band Momentum Regular Bullish Divergence — 3 Left / 1 Right\n\nPrice formed a lower weekly low while the weekly support band's rate of change formed a higher low.\n\nThis shows disagreement between price and macro support momentum.", bullishColor)
            f_divLine(prevMLowTime3, prevMLowPrice3, currentTime, currentPrice, bullishColor)
            bullRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bullishColor, hiddenTransparency)
            f_bullLabel(currentTime, currentPrice, "3L MH+", "Band Momentum Hidden Bullish Divergence — 3 Left / 1 Right\n\nPrice formed a higher weekly low while the weekly support band's rate of change formed a lower low.\n\nThis can support bullish trend continuation.", hiddenColor)
            f_divLine(prevMLowTime3, prevMLowPrice3, currentTime, currentPrice, hiddenColor)
            bullHiddenAlert := true

        prevMLowPrice3 := currentPrice
        prevMLowValue3 := lowMomentum3
        prevMLowTime3 := currentTime

    if showWidth and not na(lowWidth3)
        bool hasPrevious = not na(prevWLowPrice3) and not na(prevWLowValue3) and not na(prevWLowTime3)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevWLowTime3) : false
        bool regularSignal = distanceValid and showRegular and f_bullRegular(currentPrice, prevWLowPrice3, lowWidth3, prevWLowValue3)
        bool hiddenSignal = distanceValid and showHidden and f_bullHidden(currentPrice, prevWLowPrice3, lowWidth3, prevWLowValue3)

        if regularSignal
            f_bullLabel(currentTime, currentPrice, "3L W+", "Band Width Regular Bullish Divergence — 3 Left / 1 Right\n\nPrice formed a lower weekly low while the percentage separation between the weekly SMA and EMA formed a higher low.\n\nThis shows disagreement between price and support-band expansion.", bullishColor)
            f_divLine(prevWLowTime3, prevWLowPrice3, currentTime, currentPrice, bullishColor)
            bullRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bullishColor, hiddenTransparency)
            f_bullLabel(currentTime, currentPrice, "3L WH+", "Band Width Hidden Bullish Divergence — 3 Left / 1 Right\n\nPrice formed a higher weekly low while the percentage separation between the weekly SMA and EMA formed a lower low.\n\nThis can support bullish trend continuation.", hiddenColor)
            f_divLine(prevWLowTime3, prevWLowPrice3, currentTime, currentPrice, hiddenColor)
            bullHiddenAlert := true

        prevWLowPrice3 := currentPrice
        prevWLowValue3 := lowWidth3
        prevWLowTime3 := currentTime

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3-LEFT / 1-RIGHT HIGH PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
if show3Left and not na(high3) and not na(highTime3)
    int currentTime = int(highTime3)
    float currentPrice = high3

    if showRsi and not na(highRsi3)
        bool hasPrevious = not na(prevRHighPrice3) and not na(prevRHighValue3) and not na(prevRHighTime3)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevRHighTime3) : false
        bool regularSignal = distanceValid and showRegular and f_bearRegular(currentPrice, prevRHighPrice3, highRsi3, prevRHighValue3)
        bool hiddenSignal = distanceValid and showHidden and f_bearHidden(currentPrice, prevRHighPrice3, highRsi3, prevRHighValue3)

        if regularSignal
            f_bearLabel(currentTime, currentPrice, "3L R−", "RSI Regular Bearish Divergence — 3 Left / 1 Right\n\nPrice formed a higher weekly high while Weekly RSI formed a lower high.\n\nThis shows disagreement between price and momentum.", bearishColor)
            f_divLine(prevRHighTime3, prevRHighPrice3, currentTime, currentPrice, bearishColor)
            bearRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bearishColor, hiddenTransparency)
            f_bearLabel(currentTime, currentPrice, "3L RH−", "RSI Hidden Bearish Divergence — 3 Left / 1 Right\n\nPrice formed a lower weekly high while Weekly RSI formed a higher high.\n\nThis can support bearish trend continuation.", hiddenColor)
            f_divLine(prevRHighTime3, prevRHighPrice3, currentTime, currentPrice, hiddenColor)
            bearHiddenAlert := true

        prevRHighPrice3 := currentPrice
        prevRHighValue3 := highRsi3
        prevRHighTime3 := currentTime

    if showDistance and not na(highDistance3)
        bool hasPrevious = not na(prevDHighPrice3) and not na(prevDHighValue3) and not na(prevDHighTime3)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevDHighTime3) : false
        bool regularSignal = distanceValid and showRegular and f_bearRegular(currentPrice, prevDHighPrice3, highDistance3, prevDHighValue3)
        bool hiddenSignal = distanceValid and showHidden and f_bearHidden(currentPrice, prevDHighPrice3, highDistance3, prevDHighValue3)

        if regularSignal
            f_bearLabel(currentTime, currentPrice, "3L D−", "Band Distance Regular Bearish Divergence — 3 Left / 1 Right\n\nPrice formed a higher weekly high while price's percentage distance from the centre of the weekly support band formed a lower high.\n\nThis shows disagreement between price and relative strength.", bearishColor)
            f_divLine(prevDHighTime3, prevDHighPrice3, currentTime, currentPrice, bearishColor)
            bearRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bearishColor, hiddenTransparency)
            f_bearLabel(currentTime, currentPrice, "3L DH−", "Band Distance Hidden Bearish Divergence — 3 Left / 1 Right\n\nPrice formed a lower weekly high while price's percentage distance from the centre of the weekly support band formed a higher high.\n\nThis can support bearish trend continuation.", hiddenColor)
            f_divLine(prevDHighTime3, prevDHighPrice3, currentTime, currentPrice, hiddenColor)
            bearHiddenAlert := true

        prevDHighPrice3 := currentPrice
        prevDHighValue3 := highDistance3
        prevDHighTime3 := currentTime

    if showMomentum and not na(highMomentum3)
        bool hasPrevious = not na(prevMHighPrice3) and not na(prevMHighValue3) and not na(prevMHighTime3)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevMHighTime3) : false
        bool regularSignal = distanceValid and showRegular and f_bearRegular(currentPrice, prevMHighPrice3, highMomentum3, prevMHighValue3)
        bool hiddenSignal = distanceValid and showHidden and f_bearHidden(currentPrice, prevMHighPrice3, highMomentum3, prevMHighValue3)

        if regularSignal
            f_bearLabel(currentTime, currentPrice, "3L M−", "Band Momentum Regular Bearish Divergence — 3 Left / 1 Right\n\nPrice formed a higher weekly high while the weekly support band's rate of change formed a lower high.\n\nThis shows disagreement between price and macro support momentum.", bearishColor)
            f_divLine(prevMHighTime3, prevMHighPrice3, currentTime, currentPrice, bearishColor)
            bearRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bearishColor, hiddenTransparency)
            f_bearLabel(currentTime, currentPrice, "3L MH−", "Band Momentum Hidden Bearish Divergence — 3 Left / 1 Right\n\nPrice formed a lower weekly high while the weekly support band's rate of change formed a higher high.\n\nThis can support bearish trend continuation.", hiddenColor)
            f_divLine(prevMHighTime3, prevMHighPrice3, currentTime, currentPrice, hiddenColor)
            bearHiddenAlert := true

        prevMHighPrice3 := currentPrice
        prevMHighValue3 := highMomentum3
        prevMHighTime3 := currentTime

    if showWidth and not na(highWidth3)
        bool hasPrevious = not na(prevWHighPrice3) and not na(prevWHighValue3) and not na(prevWHighTime3)
        bool distanceValid = hasPrevious ? f_validDistance(currentTime, prevWHighTime3) : false
        bool regularSignal = distanceValid and showRegular and f_bearRegular(currentPrice, prevWHighPrice3, highWidth3, prevWHighValue3)
        bool hiddenSignal = distanceValid and showHidden and f_bearHidden(currentPrice, prevWHighPrice3, highWidth3, prevWHighValue3)

        if regularSignal
            f_bearLabel(currentTime, currentPrice, "3L W−", "Band Width Regular Bearish Divergence — 3 Left / 1 Right\n\nPrice formed a higher weekly high while the percentage separation between the weekly SMA and EMA formed a lower high.\n\nThis shows disagreement between price and support-band expansion.", bearishColor)
            f_divLine(prevWHighTime3, prevWHighPrice3, currentTime, currentPrice, bearishColor)
            bearRegularAlert := true

        if hiddenSignal
            color hiddenColor = color.new(bearishColor, hiddenTransparency)
            f_bearLabel(currentTime, currentPrice, "3L WH−", "Band Width Hidden Bearish Divergence — 3 Left / 1 Right\n\nPrice formed a lower weekly high while the percentage separation between the weekly SMA and EMA formed a higher high.\n\nThis can support bearish trend continuation.", hiddenColor)
            f_divLine(prevWHighTime3, prevWHighPrice3, currentTime, currentPrice, hiddenColor)
            bearHiddenAlert := true

        prevWHighPrice3 := currentPrice
        prevWHighValue3 := highWidth3
        prevWHighTime3 := currentTime

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
alertcondition(bullRegularAlert, title="Bullish Regular Weekly Divergence", message="BMSB bullish regular weekly divergence confirmed on {{ticker}}.")
alertcondition(bullHiddenAlert, title="Bullish Hidden Weekly Divergence", message="BMSB bullish hidden weekly divergence confirmed on {{ticker}}.")
alertcondition(bearRegularAlert, title="Bearish Regular Weekly Divergence", message="BMSB bearish regular weekly divergence confirmed on {{ticker}}.")
alertcondition(bearHiddenAlert, title="Bearish Hidden Weekly Divergence", message="BMSB bearish hidden weekly divergence confirmed on {{ticker}}.")
````
