# Elaris Smart Pullback Hunter

- url: https://www.tradingview.com/script/jW9qnydg-Elaris-Smart-Pullback-Hunter/
- type: indicator
- pine_id: PUB;20826d276ebf48fb9a36414b0ac07ac4
- version: 1.0

## Description

[b]Elaris Smart Pullback Hunter[/b]

Elaris Smart Pullback Hunter is a trend-continuation indicator designed to help traders identify pullbacks within established market trends.

Instead of focusing on reversals, the indicator aims to locate areas where price temporarily retraces into a trend before showing signs of continuation. The goal is to help traders avoid chasing extended moves and instead focus on structured pullback opportunities.

The script combines trend analysis, pullback detection, volume confirmation, market structure evaluation, and optional higher-timeframe alignment to highlight potential continuation setups.

---

[b]Key Features[/b]

[b]Trend Detection[/b]

The indicator evaluates trend conditions using multiple exponential moving averages and EMA slope analysis.

Bullish trend conditions are based on:

• Fast EMA above Mid EMA
• Mid EMA above Slow EMA
• Positive EMA slope

Bearish trend conditions are based on:

• Fast EMA below Mid EMA
• Mid EMA below Slow EMA
• Negative EMA slope

This helps filter out many ranging market conditions.

---

[b]Pullback Identification[/b]

The script continuously monitors for pullbacks into key moving average zones.

Supported pullback types include:

• Shallow Pullbacks (EMA20 area)
• Healthy Pullbacks (EMA50 area)
• Deeper Retracements (optional)

This allows traders to evaluate different pullback depths according to their risk tolerance and trading style.

---

[b]Market Structure Filter[/b]

An optional structure filter can be enabled to require:

Bullish conditions:

• Higher lows
• Uptrend structure preservation

Bearish conditions:

• Lower highs
• Downtrend structure preservation

This helps reduce signals that occur during potential trend deterioration.

---

[b]Volume Confirmation[/b]

An optional volume filter compares current volume against a moving average of volume.

When enabled, signals require increased participation relative to recent activity.

---

[b]Rejection Candle Analysis[/b]

The indicator can evaluate candle structure using:

• Body size percentage
• Upper wick percentage
• Lower wick percentage

This helps identify candles that show rejection behavior near pullback zones.

---

[b]Multi-Timeframe Confirmation[/b]

Optional higher-timeframe confirmation can be used to align pullback signals with broader market direction.

For example:

• 15-minute pullbacks aligned with a 1-hour trend
• 30-minute pullbacks aligned with a 4-hour trend

This feature can help traders focus on signals that occur in the direction of the larger trend.

---

[b]Pullback Quality Scoring[/b]

Each setup receives a score based on multiple factors, including:

• Trend alignment
• EMA structure
• Pullback quality
• Momentum confirmation
• Volume confirmation
• Higher-timeframe agreement

Scores can be filtered so that only stronger setups are displayed.

---

[b]Dashboard[/b]

The built-in dashboard provides a quick overview of:

• Current trend state
• Pullback status
• EMA slope information
• Volume condition
• Higher-timeframe alignment
• Signal score

---

[b]Risk Projection Tools[/b]

Optional risk projection levels can display:

• Entry reference level
• Stop-loss reference level
• Risk-to-reward targets

These levels are intended as visual planning tools and should not be considered trading advice.

---

[b] Suggested Markets[/b]

The indicator can be used on:

• Cryptocurrency markets
• Forex markets
• Indices
• Stocks
• Commodities

---

[b]Suggested Timeframes[/b]

Commonly used timeframes include:

• 15 Minutes
• 30 Minutes
• 1 Hour
• 4 Hours

The indicator may also be used on other timeframes depending on the trader's workflow.

---

[b] Notes[/b]

• Signals are generated after candle close.
• Higher-timeframe calculations use non-lookahead security calls.
• The script is designed as a trend-continuation tool and may perform differently across market conditions.
• No indicator can guarantee future market behavior. Risk management remains essential.

---

Thank you for using Elaris Smart Pullback Hunter.

## Source Code

````pine
//@version=6
indicator("Elaris Smart Pullback Hunter", shorttitle="Elaris SPH", overlay=true, max_labels_count=500, max_lines_count=500)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// Smart Pullback Hunter Pro
// Non-repainting: signals only confirm on closed candles
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// INPUT GROUPS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupTrend = "01. Trend Engine"
fastLen    = input.int(20, "Fast EMA", minval=1, group=groupTrend)
midLen     = input.int(50, "Mid EMA", minval=1, group=groupTrend)
slowLen    = input.int(200, "Slow EMA", minval=1, group=groupTrend)
slopeLen   = input.int(10, "EMA Slope Lookback", minval=2, group=groupTrend)
minSlope   = input.float(0.05, "Minimum EMA Slope %", step=0.01, group=groupTrend)
useStructure = input.bool(true, "Use Market Structure Filter", group=groupTrend)

groupPullback = "02. Pullback Logic"
pullbackLookback = input.int(8, "Pullback Lookback Candles", minval=2, group=groupPullback)
maxPullbackBars  = input.int(12, "Max Pullback Age", minval=2, group=groupPullback)
useEma20Pullback = input.bool(true, "Allow EMA20 Pullback", group=groupPullback)
useEma50Pullback = input.bool(true, "Allow EMA50 Pullback", group=groupPullback)
deepPullbackPct  = input.float(1.5, "Max Deep Pullback Distance % From EMA50", step=0.1, group=groupPullback)

groupConfirm = "03. Confirmation Candle"
requireCloseBackFast = input.bool(true, "Require Close Back Above/Below EMA20", group=groupConfirm)
useVolumeFilter      = input.bool(true, "Use Volume Confirmation", group=groupConfirm)
volumeLen            = input.int(20, "Volume MA Length", minval=1, group=groupConfirm)
volumeMultiplier     = input.float(1.0, "Volume Multiplier", step=0.1, group=groupConfirm)
useWickFilter        = input.bool(true, "Use Rejection Wick Filter", group=groupConfirm)
minRejectionWickPct  = input.float(25.0, "Min Rejection Wick %", step=1.0, group=groupConfirm)
minBodyPct           = input.float(35.0, "Min Body %", step=1.0, group=groupConfirm)

groupScore = "04. Signal Score"
minScore = input.int(70, "Minimum Signal Score", minval=1, maxval=100, group=groupScore)
showScoreLabels = input.bool(true, "Show Score Labels", group=groupScore)
showOnlyAPlus = input.bool(false, "Show Only A+ Signals", group=groupScore)

groupMTF = "05. Multi-Timeframe Filter"
useMtfFilter = input.bool(false, "Use Higher Timeframe Confirmation", group=groupMTF)
mtfTf        = input.timeframe("60", "Higher Timeframe", group=groupMTF)

groupVisual = "06. Visuals"
showEma       = input.bool(true, "Show EMAs", group=groupVisual)
showZones     = input.bool(true, "Show Pullback Zones", group=groupVisual)
showDashboard = input.bool(true, "Show Dashboard", group=groupVisual)
paintBars     = input.bool(true, "Color Signal Bars", group=groupVisual)
showBg        = input.bool(false, "Show Pullback Background", group=groupVisual)

groupRisk = "07. Risk Projection"
showRiskLevels = input.bool(true, "Show Entry / SL / TP Projection", group=groupRisk)
rr1 = input.float(1.0, "Target 1 RR", step=0.25, group=groupRisk)
rr2 = input.float(2.0, "Target 2 RR", step=0.25, group=groupRisk)
atrLen = input.int(14, "ATR Length", minval=1, group=groupRisk)
atrStopMult = input.float(1.2, "ATR Stop Multiplier", step=0.1, group=groupRisk)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CORE CALCULATIONS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

emaFast = ta.ema(close, fastLen)
emaMid  = ta.ema(close, midLen)
emaSlow = ta.ema(close, slowLen)

atr = ta.atr(atrLen)
volMa = ta.sma(volume, volumeLen)

emaSlopePct = emaFast[slopeLen] != 0 ? ((emaFast - emaFast[slopeLen]) / emaFast[slopeLen]) * 100.0 : 0.0

bullEmaStack = emaFast > emaMid and emaMid > emaSlow
bearEmaStack = emaFast < emaMid and emaMid < emaSlow

bullSlope = emaSlopePct >= minSlope
bearSlope = emaSlopePct <= -minSlope

// Market structure proxy
swingHigh = ta.highest(high, pullbackLookback)
swingLow  = ta.lowest(low, pullbackLookback)

higherLowValid = low > ta.lowest(low, pullbackLookback)[1]
lowerHighValid = high < ta.highest(high, pullbackLookback)[1]

bullStructure = not useStructure or higherLowValid
bearStructure = not useStructure or lowerHighValid

bullTrend = bullEmaStack and bullSlope and bullStructure
bearTrend = bearEmaStack and bearSlope and bearStructure

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// MTF CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

mtfFast = request.security(syminfo.tickerid, mtfTf, ta.ema(close, fastLen), barmerge.gaps_off, barmerge.lookahead_off)
mtfMid  = request.security(syminfo.tickerid, mtfTf, ta.ema(close, midLen), barmerge.gaps_off, barmerge.lookahead_off)
mtfSlow = request.security(syminfo.tickerid, mtfTf, ta.ema(close, slowLen), barmerge.gaps_off, barmerge.lookahead_off)

mtfBull = mtfFast > mtfMid and mtfMid > mtfSlow
mtfBear = mtfFast < mtfMid and mtfMid < mtfSlow

mtfLongOk = not useMtfFilter or mtfBull
mtfShortOk = not useMtfFilter or mtfBear

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PULLBACK DETECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

touchFastLong = low <= emaFast and close > emaFast
touchMidLong  = low <= emaMid and close > emaMid
touchFastShort = high >= emaFast and close < emaFast
touchMidShort  = high >= emaMid and close < emaMid

deepLong = math.abs(low - emaMid) / emaMid * 100 <= deepPullbackPct and low < emaMid and close > emaMid
deepShort = math.abs(high - emaMid) / emaMid * 100 <= deepPullbackPct and high > emaMid and close < emaMid

longPullbackRaw = bullTrend and ((useEma20Pullback and touchFastLong) or (useEma50Pullback and touchMidLong) or deepLong)
shortPullbackRaw = bearTrend and ((useEma20Pullback and touchFastShort) or (useEma50Pullback and touchMidShort) or deepShort)

barsSinceLongPullback = ta.barssince(longPullbackRaw)
barsSinceShortPullback = ta.barssince(shortPullbackRaw)

longPullbackActive = barsSinceLongPullback >= 0 and barsSinceLongPullback <= maxPullbackBars
shortPullbackActive = barsSinceShortPullback >= 0 and barsSinceShortPullback <= maxPullbackBars

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// CONFIRMATION CANDLE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

body = math.abs(close - open)
barRange = high - low
bodyPct = barRange > 0 ? body / barRange * 100.0 : 0.0

upperWick = high - math.max(open, close)
lowerWick = math.min(open, close) - low

upperWickPct = barRange > 0 ? upperWick / barRange * 100.0 : 0.0
lowerWickPct = barRange > 0 ? lowerWick / barRange * 100.0 : 0.0

bullCandle = close > open
bearCandle = close < open

longCloseBack = not requireCloseBackFast or close > emaFast
shortCloseBack = not requireCloseBackFast or close < emaFast

volumeOk = not useVolumeFilter or volume > volMa * volumeMultiplier

longWickOk = not useWickFilter or lowerWickPct >= minRejectionWickPct
shortWickOk = not useWickFilter or upperWickPct >= minRejectionWickPct

bodyOk = bodyPct >= minBodyPct

longConfirmation = bullCandle and longCloseBack and volumeOk and longWickOk and bodyOk
shortConfirmation = bearCandle and shortCloseBack and volumeOk and shortWickOk and bodyOk

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// SCORE ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

trendScoreLong = bullEmaStack ? 20 : 0
trendScoreLong += bullSlope ? 15 : 0
trendScoreLong += bullStructure ? 10 : 0

trendScoreShort = bearEmaStack ? 20 : 0
trendScoreShort += bearSlope ? 15 : 0
trendScoreShort += bearStructure ? 10 : 0

pullbackScoreLong = touchMidLong ? 20 : touchFastLong ? 14 : deepLong ? 12 : 0
pullbackScoreShort = touchMidShort ? 20 : touchFastShort ? 14 : deepShort ? 12 : 0

volumeScore = volumeOk ? 15 : 0
momentumScoreLong = bullCandle and bodyOk ? 20 : 0
momentumScoreShort = bearCandle and bodyOk ? 20 : 0

mtfScoreLong = mtfLongOk ? 10 : 0
mtfScoreShort = mtfShortOk ? 10 : 0

longScoreRaw = trendScoreLong + pullbackScoreLong + volumeScore + momentumScoreLong + mtfScoreLong
shortScoreRaw = trendScoreShort + pullbackScoreShort + volumeScore + momentumScoreShort + mtfScoreShort

longScore = math.min(longScoreRaw, 100)
shortScore = math.min(shortScoreRaw, 100)

getGrade(score) =>
    score >= 90 ? "A+" :
     score >= 80 ? "A" :
     score >= 70 ? "B" :
     score >= 60 ? "C" : "D"

longGrade = getGrade(longScore)
shortGrade = getGrade(shortScore)

longAllowedByScore = showOnlyAPlus ? longScore >= 90 : longScore >= minScore
shortAllowedByScore = showOnlyAPlus ? shortScore >= 90 : shortScore >= minScore

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// FINAL SIGNALS — NON-REPAINTING
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longSignal = barstate.isconfirmed and longPullbackActive and longConfirmation and mtfLongOk and longAllowedByScore
shortSignal = barstate.isconfirmed and shortPullbackActive and shortConfirmation and mtfShortOk and shortAllowedByScore

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PULLBACK TYPE TEXT
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

longType =
     touchMidLong ? "Healthy Pullback" :
     touchFastLong ? "Shallow Pullback" :
     deepLong ? "Deep Pullback" : "Pullback"

shortType =
     touchMidShort ? "Healthy Pullback" :
     touchFastShort ? "Shallow Pullback" :
     deepShort ? "Deep Pullback" : "Pullback"

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// PLOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plot(showEma ? emaFast : na, "EMA Fast", color=color.new(color.aqua, 0), linewidth=2)
plot(showEma ? emaMid : na, "EMA Mid", color=color.new(color.orange, 0), linewidth=2)
plot(showEma ? emaSlow : na, "EMA Slow", color=color.new(color.white, 0), linewidth=2)

pFast = plot(showZones ? emaFast : na, "Pullback Zone Fast", color=color.new(color.aqua, 85))
pMid  = plot(showZones ? emaMid : na, "Pullback Zone Mid", color=color.new(color.orange, 85))
fill(pFast, pMid, color=bullTrend ? color.new(color.green, 88) : bearTrend ? color.new(color.red, 88) : color.new(color.gray, 95))

bgcolor(showBg and longPullbackActive ? color.new(color.green, 90) : na)
bgcolor(showBg and shortPullbackActive ? color.new(color.red, 90) : na)

barcolor(paintBars and longSignal ? color.lime : paintBars and shortSignal ? color.red : na)

plotshape(longSignal, title="Smart Long Pullback", style=shape.triangleup, location=location.belowbar, size=size.small, color=color.lime, text="PB")
plotshape(shortSignal, title="Smart Short Pullback", style=shape.triangledown, location=location.abovebar, size=size.small, color=color.red, text="PB")

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// LABELS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if showScoreLabels and longSignal
    label.new(
         bar_index,
         low,
         "LONG\n" + longType + "\nScore: " + str.tostring(longScore) + "% " + longGrade,
         style=label.style_label_up,
         textcolor=color.white,
         color=color.new(color.green, 0),
         size=size.small
     )

if showScoreLabels and shortSignal
    label.new(
         bar_index,
         high,
         "SHORT\n" + shortType + "\nScore: " + str.tostring(shortScore) + "% " + shortGrade,
         style=label.style_label_down,
         textcolor=color.white,
         color=color.new(color.red, 0),
         size=size.small
     )

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// RISK PROJECTION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var line entryLine = na
var line slLine = na
var line tp1Line = na
var line tp2Line = na

if showRiskLevels and (longSignal or shortSignal)
    line.delete(entryLine)
    line.delete(slLine)
    line.delete(tp1Line)
    line.delete(tp2Line)

    entry = close

    longStop = low - atr * atrStopMult
    shortStop = high + atr * atrStopMult

    stop = longSignal ? longStop : shortStop
    risk = math.abs(entry - stop)

    tp1 = longSignal ? entry + risk * rr1 : entry - risk * rr1
    tp2 = longSignal ? entry + risk * rr2 : entry - risk * rr2

    entryLine := line.new(bar_index, entry, bar_index + 20, entry, extend=extend.none, color=color.new(color.white, 0), style=line.style_solid, width=1)
    slLine    := line.new(bar_index, stop, bar_index + 20, stop, extend=extend.none, color=color.new(color.red, 0), style=line.style_dashed, width=1)
    tp1Line   := line.new(bar_index, tp1, bar_index + 20, tp1, extend=extend.none, color=color.new(color.green, 0), style=line.style_dotted, width=1)
    tp2Line   := line.new(bar_index, tp2, bar_index + 20, tp2, extend=extend.none, color=color.new(color.green, 0), style=line.style_dashed, width=1)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// DASHBOARD
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var table dash = table.new(position.top_right, 2, 7, border_width=1)

trendText = bullTrend ? "BULLISH" : bearTrend ? "BEARISH" : "NEUTRAL"
trendColor = bullTrend ? color.green : bearTrend ? color.red : color.gray

activeText = longPullbackActive ? "LONG ZONE" : shortPullbackActive ? "SHORT ZONE" : "NONE"
activeColor = longPullbackActive ? color.green : shortPullbackActive ? color.red : color.gray

bestScore = bullTrend ? longScore : bearTrend ? shortScore : 0
bestGrade = getGrade(bestScore)

if showDashboard and barstate.islast
    table.cell(dash, 0, 0, "Smart Pullback Hunter", text_color=color.white, bgcolor=color.new(color.black, 0))
    table.cell(dash, 1, 0, "PRO", text_color=color.white, bgcolor=color.new(color.black, 0))

    table.cell(dash, 0, 1, "Trend", text_color=color.white)
    table.cell(dash, 1, 1, trendText, text_color=color.white, bgcolor=color.new(trendColor, 20))

    table.cell(dash, 0, 2, "EMA Slope", text_color=color.white)
    table.cell(dash, 1, 2, str.tostring(emaSlopePct, "#.##") + "%", text_color=color.white)

    table.cell(dash, 0, 3, "Pullback", text_color=color.white)
    table.cell(dash, 1, 3, activeText, text_color=color.white, bgcolor=color.new(activeColor, 25))

    table.cell(dash, 0, 4, "Volume", text_color=color.white)
    table.cell(dash, 1, 4, volumeOk ? "CONFIRMED" : "WEAK", text_color=color.white, bgcolor=volumeOk ? color.new(color.green, 30) : color.new(color.red, 30))

    table.cell(dash, 0, 5, "MTF", text_color=color.white)
    table.cell(dash, 1, 5, useMtfFilter ? (mtfBull ? "BULL" : mtfBear ? "BEAR" : "NEUTRAL") : "OFF", text_color=color.white)

    table.cell(dash, 0, 6, "Score", text_color=color.white)
    table.cell(dash, 1, 6, str.tostring(bestScore) + "% " + bestGrade, text_color=color.white)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(longSignal, title="Smart Pullback Long", message="Smart Pullback Hunter Pro: Bullish pullback continuation detected.")
alertcondition(shortSignal, title="Smart Pullback Short", message="Smart Pullback Hunter Pro: Bearish pullback continuation detected.")
alertcondition(longSignal and longScore >= 90, title="A+ Long Pullback", message="Smart Pullback Hunter Pro: A+ bullish pullback detected.")
alertcondition(shortSignal and shortScore >= 90, title="A+ Short Pullback", message="Smart Pullback Hunter Pro: A+ bearish pullback detected.")
alertcondition(bullTrend and not bullTrend[1], title="Bull Trend Started", message="Smart Pullback Hunter Pro: Bull trend detected.")
alertcondition(bearTrend and not bearTrend[1], title="Bear Trend Started", message="Smart Pullback Hunter Pro: Bear trend detected.")
````
