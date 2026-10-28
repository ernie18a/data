# PhantomFlow V4.1 Gold Indicator

- url: https://www.tradingview.com/script/hOXtxBUU-PhantomFlow-V4-1-Gold-Indicator/
- type: indicator
- pine_id: PUB;e65ff17e9bfa4f4f8e0b0aa6b58330c4
- version: 1.0

## Description

PhantomFlow V4.1 Gold Indicator is a structure-and-momentum trend tool built for XAUUSD and other fast intraday markets. It combines swing structure, EMA trend alignment, higher-timeframe bias, session filtering, and previous day/week liquidity levels to highlight cleaner continuation opportunities while reducing low-quality signals.
How it reads trend
The indicator uses confirmed swing highs and lows together with a fast and slow EMA. When structure and EMA direction agree, it marks bullish or bearish trend conditions. An optional higher-timeframe filter can be used to keep signals aligned with the broader market direction.
Candle colors
Lime = fresh bullish entry signal
Fuchsia = fresh bearish entry signal
Green = bullish trend / hold condition
Red = bearish trend / hold condition
Faded green = bullish trend weakening
Faded red = bearish trend weakening
Gray = neutral / no clear directional edge
Signal logic
Signals appear when price is in trend, pulls back toward value around the EMA zone, then shows momentum back in the trend direction. This is designed to help identify continuation entries rather than constantly calling reversals.
Previous Day / Previous Week levels
The indicator plots:
PDH = Previous Day High
PDL = Previous Day Low
PD50 = Previous Day Midpoint
PWH = Previous Week High
PWL = Previous Week Low
These levels act as liquidity and reaction zones. They can help identify likely targets, breakout points, and areas where price may hesitate or reject.
Level filter
An optional level-aware filter blocks new signals when price is too close to an important previous day or previous week level. This helps avoid entries with poor room to move.
Dashboard
The top-right dashboard shows:
current bias
current state
trend score
higher-timeframe direction
session status
previous day levels
previous week levels
available room to key levels
whether the level filter is on
Trend score
The score is a quick strength reading based on EMA spread, EMA slope, structure, break conditions, momentum, session alignment, and optional HTF agreement. Higher values mean stronger trend conditions.
Best use
This indicator is best used as a trend-bias and continuation-entry tool, especially on lower intraday timeframes such as 5m and 15m, with the 1H chart used as the higher-timeframe filter.
Here’s a shorter version for the TradingView description box if you want something tighter:
Short description:
PhantomFlow V4.1 Gold Indicator is a structure-based trend and continuation tool built for intraday trading. It combines swing structure, EMA alignment, HTF bias, session filtering, and previous day/week liquidity levels to highlight cleaner long and short opportunities. Candle colors show trend state and fresh entry triggers, while the dashboard displays bias, score, HTF direction, session status, and key PD/PW levels.

## Source Code

````pine
//@version=6
indicator("PhantomFlow V4.1 Gold Indicator", shorttitle="PFV41Ind", overlay=true, max_labels_count=500, max_lines_count=500)

//══════════════════════════════════════════════════════════════════════
// INPUTS
//══════════════════════════════════════════════════════════════════════
groupTrend = "Trend"
fastLen      = input.int(21, "Fast EMA", minval=1, group=groupTrend)
slowLen      = input.int(50, "Slow EMA", minval=1, group=groupTrend)
swingLen     = input.int(3, "Swing Confirmation", minval=1, group=groupTrend)
atrLen       = input.int(14, "ATR Length", minval=1, group=groupTrend)
breakAtrBuff = input.float(0.20, "Structure Break Buffer (ATR)", minval=0.0, step=0.05, group=groupTrend)
pullbackAtr  = input.float(0.60, "Pullback Zone Size (ATR)", minval=0.1, step=0.1, group=groupTrend)

groupEntry = "Entry"
bodyStrength   = input.float(0.55, "Min Body % of Candle Range", minval=0.1, maxval=0.95, step=0.05, group=groupEntry)
firstEntryOnly = input.bool(true, "First Entry Only Per Trend Leg", group=groupEntry)
allowLongs     = input.bool(true, "Allow Long Signals", group=groupEntry)
allowShorts    = input.bool(true, "Allow Short Signals", group=groupEntry)
showSignals    = input.bool(true, "Show Entry Labels", group=groupEntry)

groupHTF = "Higher Timeframe"
useHTF     = input.bool(true, "Enable HTF Bias Filter", group=groupHTF)
htfTf      = input.timeframe("60", "HTF", group=groupHTF)
htfFastLen = input.int(21, "HTF Fast EMA", minval=1, group=groupHTF)
htfSlowLen = input.int(50, "HTF Slow EMA", minval=1, group=groupHTF)

groupSession = "Session Filter"
useSessionFilter = input.bool(false, "Enable Session Filter", group=groupSession)
sessionMode = input.string("London + New York", "Session Preset", options=["Asia", "London", "New York", "London + New York", "Asia + London", "All Sessions", "Custom"], group=groupSession)
customSession = input.session("0000-2359", "Custom Session", group=groupSession)

groupLevels = "Previous Day / Week Levels"
showPDH   = input.bool(true, "Show Previous Day High", group=groupLevels)
showPDL   = input.bool(true, "Show Previous Day Low", group=groupLevels)
showPD50  = input.bool(true, "Show Previous Day 50%", group=groupLevels)
showPWH   = input.bool(true, "Show Previous Week High", group=groupLevels)
showPWL   = input.bool(true, "Show Previous Week Low", group=groupLevels)

pdhColor  = input.color(color.new(color.green, 35), "PDH Color", group=groupLevels)
pdlColor  = input.color(color.new(color.red, 35), "PDL Color", group=groupLevels)
pd50Color = input.color(color.new(color.yellow, 35), "PD50 Color", group=groupLevels)
pwhColor  = input.color(color.new(color.aqua, 35), "PWH Color", group=groupLevels)
pwlColor  = input.color(color.new(color.fuchsia, 35), "PWL Color", group=groupLevels)

levelWidth      = input.int(1, "Level Width", minval=1, maxval=4, group=groupLevels)
levelOffset     = input.int(15, "Line Offset Right", minval=0, group=groupLevels)
levelLength     = input.int(80, "Line Length", minval=5, group=groupLevels)
showLevelLabels = input.bool(true, "Show Level Labels", group=groupLevels)

groupLevelLogic = "Level-Aware Logic"
useLevelEntryFilter = input.bool(true, "Block Signals Too Close To Key Levels", group=groupLevelLogic)
minRoomAtr          = input.float(0.40, "Minimum Room To Target Level (ATR)", minval=0.0, step=0.05, group=groupLevelLogic)
preferWeekLevels    = input.bool(true, "Prefer Weekly Levels For Room Filter", group=groupLevelLogic)

groupDash = "Dashboard"
showDashboard = input.bool(true, "Show Dashboard", group=groupDash)

groupVisual = "Visual"
colorBars      = input.bool(true, "Color Candles", group=groupVisual)
showRibbon     = input.bool(true, "Show EMA Ribbon", group=groupVisual)
showSwingLines = input.bool(false, "Show Swing Levels", group=groupVisual)
showBgTrend    = input.bool(false, "Show Trend Background", group=groupVisual)

//══════════════════════════════════════════════════════════════════════
// CORE SERIES
//══════════════════════════════════════════════════════════════════════
fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)
atrVal  = ta.atr(atrLen)

ph = ta.pivothigh(high, swingLen, swingLen)
pl = ta.pivotlow(low, swingLen, swingLen)

var float lastSwingHigh = na
var float prevSwingHigh = na
var float lastSwingLow  = na
var float prevSwingLow  = na

if not na(ph)
    prevSwingHigh := lastSwingHigh
    lastSwingHigh := ph

if not na(pl)
    prevSwingLow := lastSwingLow
    lastSwingLow := pl

hasHighs = not na(lastSwingHigh) and not na(prevSwingHigh)
hasLows  = not na(lastSwingLow) and not na(prevSwingLow)

higherHigh = hasHighs and lastSwingHigh > prevSwingHigh
lowerHigh  = hasHighs and lastSwingHigh < prevSwingHigh
higherLow  = hasLows and lastSwingLow > prevSwingLow
lowerLow   = hasLows and lastSwingLow < prevSwingLow

bullStructure = higherHigh and higherLow
bearStructure = lowerHigh and lowerLow

bullBreak = hasHighs and close > lastSwingHigh + atrVal * breakAtrBuff
bearBreak = hasLows and close < lastSwingLow - atrVal * breakAtrBuff

emaBull = fastEMA > slowEMA and fastEMA > fastEMA[1] and slowEMA > slowEMA[1]
emaBear = fastEMA < slowEMA and fastEMA < fastEMA[1] and slowEMA < slowEMA[1]

baseTrendUp = (emaBull and bullStructure) or bullBreak
baseTrendDn = (emaBear and bearStructure) or bearBreak

//══════════════════════════════════════════════════════════════════════
// HTF FILTER
//══════════════════════════════════════════════════════════════════════
htfFast = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfFastLen), barmerge.gaps_off, barmerge.lookahead_off)
htfSlow = request.security(syminfo.tickerid, htfTf, ta.ema(close, htfSlowLen), barmerge.gaps_off, barmerge.lookahead_off)

htfBull = htfFast > htfSlow
htfBear = htfFast < htfSlow

//══════════════════════════════════════════════════════════════════════
// SESSION FILTER
//══════════════════════════════════════════════════════════════════════
sessionStr =
     sessionMode == "Asia"              ? "1900-0400" :
     sessionMode == "London"            ? "0300-1100" :
     sessionMode == "New York"          ? "0800-1700" :
     sessionMode == "London + New York" ? "0300-1700" :
     sessionMode == "Asia + London"     ? "1900-1100" :
     sessionMode == "All Sessions"      ? "0000-2359" :
                                          customSession

inSession = not na(time(timeframe.period, sessionStr))
sessionOk = not useSessionFilter or inSession

//══════════════════════════════════════════════════════════════════════
// PREVIOUS DAY / WEEK VALUES
//══════════════════════════════════════════════════════════════════════
prevDayHigh  = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
prevDayLow   = request.security(syminfo.tickerid, "D", low[1],  barmerge.gaps_off, barmerge.lookahead_off)
prevDayMid   = (prevDayHigh + prevDayLow) / 2.0

prevWeekHigh = request.security(syminfo.tickerid, "W", high[1], barmerge.gaps_off, barmerge.lookahead_off)
prevWeekLow  = request.security(syminfo.tickerid, "W", low[1],  barmerge.gaps_off, barmerge.lookahead_off)

//══════════════════════════════════════════════════════════════════════
// FINAL TREND BIAS
//══════════════════════════════════════════════════════════════════════
trendUp = baseTrendUp and (not useHTF or htfBull)
trendDn = baseTrendDn and (not useHTF or htfBear)

//══════════════════════════════════════════════════════════════════════
// ENTRY LOGIC
//══════════════════════════════════════════════════════════════════════
bullValueZoneTop = math.max(fastEMA, slowEMA) + atrVal * pullbackAtr
bearValueZoneBot = math.min(fastEMA, slowEMA) - atrVal * pullbackAtr

inBullValue = trendUp and low <= bullValueZoneTop and close >= slowEMA
inBearValue = trendDn and high >= bearValueZoneBot and close <= slowEMA

barRange   = math.max(high - low, syminfo.mintick)
bullBodyOk = close > open and (close - open) / barRange >= bodyStrength
bearBodyOk = open > close and (open - close) / barRange >= bodyStrength

bullMomentum = close > fastEMA and close > high[1] and bullBodyOk
bearMomentum = close < fastEMA and close < low[1] and bearBodyOk

baseLongSignal  = allowLongs and inBullValue[1] and bullMomentum and sessionOk
baseShortSignal = allowShorts and inBearValue[1] and bearMomentum and sessionOk

//══════════════════════════════════════════════════════════════════════
// LEVEL-AWARE ENTRY FILTER
//══════════════════════════════════════════════════════════════════════
longRoomToPDH  = prevDayHigh - close
longRoomToPWH  = prevWeekHigh - close
shortRoomToPDL = close - prevDayLow
shortRoomToPWL = close - prevWeekLow

minRoom = atrVal * minRoomAtr

enoughRoomLongPDH  = longRoomToPDH > minRoom
enoughRoomLongPWH  = longRoomToPWH > minRoom
enoughRoomShortPDL = shortRoomToPDL > minRoom
enoughRoomShortPWL = shortRoomToPWL > minRoom

longRoomOk =
     not useLevelEntryFilter ? true :
     preferWeekLevels
     ? ((close < prevWeekHigh ? enoughRoomLongPWH : true) and (close < prevDayHigh ? enoughRoomLongPDH : true))
     : ((close < prevDayHigh ? enoughRoomLongPDH : true) and (close < prevWeekHigh ? enoughRoomLongPWH : true))

shortRoomOk =
     not useLevelEntryFilter ? true :
     preferWeekLevels
     ? ((close > prevWeekLow ? enoughRoomShortPWL : true) and (close > prevDayLow ? enoughRoomShortPDL : true))
     : ((close > prevDayLow ? enoughRoomShortPDL : true) and (close > prevWeekLow ? enoughRoomShortPWL : true))

rawLongSignal  = baseLongSignal and longRoomOk
rawShortSignal = baseShortSignal and shortRoomOk

//══════════════════════════════════════════════════════════════════════
// FIRST ENTRY ONLY CONTROL
//══════════════════════════════════════════════════════════════════════
var int trendState = 0
var bool longArmed = false
var bool shortArmed = false

newBullTrend = trendUp and trendState != 1
newBearTrend = trendDn and trendState != -1
lostTrend    = not trendUp and not trendDn

if newBullTrend
    trendState := 1
    longArmed := true
    shortArmed := false
else if newBearTrend
    trendState := -1
    shortArmed := true
    longArmed := false
else if lostTrend
    trendState := 0

longSignal  = firstEntryOnly ? (rawLongSignal and longArmed) : rawLongSignal
shortSignal = firstEntryOnly ? (rawShortSignal and shortArmed) : rawShortSignal

if longSignal
    longArmed := false
if shortSignal
    shortArmed := false

//══════════════════════════════════════════════════════════════════════
// TREND SCORE
//══════════════════════════════════════════════════════════════════════
emaSpreadScoreRaw = math.abs(fastEMA - slowEMA) / math.max(atrVal, syminfo.mintick) * 25.0
emaSpreadScore = math.min(25.0, emaSpreadScoreRaw)
emaSlopeScore = ((fastEMA > fastEMA[1] and slowEMA > slowEMA[1]) or (fastEMA < fastEMA[1] and slowEMA < slowEMA[1])) ? 20.0 : 0.0
structureScore = (bullStructure or bearStructure) ? 20.0 : 0.0
breakScore = (bullBreak or bearBreak) ? 20.0 : 0.0
htfScore = not useHTF ? 0.0 : ((trendUp and htfBull) or (trendDn and htfBear) ? 10.0 : 0.0)
sessionScore = sessionOk ? 5.0 : 0.0
momentumScore = (bullMomentum or bearMomentum) ? 10.0 : 0.0
trendScore = math.round(math.min(100.0, emaSpreadScore + emaSlopeScore + structureScore + breakScore + htfScore + sessionScore + momentumScore))

//══════════════════════════════════════════════════════════════════════
// FLOATING RIGHT-SIDE PD / PW LINES
//══════════════════════════════════════════════════════════════════════
var line pdhLine  = na
var line pdlLine  = na
var line pd50Line = na
var line pwhLine  = na
var line pwlLine  = na

var label pdhLabel  = na
var label pdlLabel  = na
var label pd50Label = na
var label pwhLabel  = na
var label pwlLabel  = na

if barstate.isfirst
    pdhLine  := line.new(na, na, na, na, xloc=xloc.bar_index, extend=extend.none, style=line.style_dotted)
    pdlLine  := line.new(na, na, na, na, xloc=xloc.bar_index, extend=extend.none, style=line.style_dotted)
    pd50Line := line.new(na, na, na, na, xloc=xloc.bar_index, extend=extend.none, style=line.style_dotted)
    pwhLine  := line.new(na, na, na, na, xloc=xloc.bar_index, extend=extend.none, style=line.style_dotted)
    pwlLine  := line.new(na, na, na, na, xloc=xloc.bar_index, extend=extend.none, style=line.style_dotted)

if barstate.islast
    x1 = bar_index + levelOffset
    x2 = bar_index + levelOffset + levelLength
    labelX = x2 + 1

    // Delete and recreate labels so they stay synced on the right
    label.delete(pdhLabel)
    label.delete(pdlLabel)
    label.delete(pd50Label)
    label.delete(pwhLabel)
    label.delete(pwlLabel)

    // PDH
    if showPDH
        line.set_xy1(pdhLine, x1, prevDayHigh)
        line.set_xy2(pdhLine, x2, prevDayHigh)
        line.set_color(pdhLine, pdhColor)
        line.set_width(pdhLine, levelWidth)
        line.set_style(pdhLine, line.style_dotted)
        pdhLabel := showLevelLabels ? label.new(labelX, prevDayHigh, "PDH", xloc=xloc.bar_index, style=label.style_label_left, color=pdhColor, textcolor=color.white, size=size.tiny) : na
    else
        line.set_xy1(pdhLine, na, na)
        line.set_xy2(pdhLine, na, na)

    // PDL
    if showPDL
        line.set_xy1(pdlLine, x1, prevDayLow)
        line.set_xy2(pdlLine, x2, prevDayLow)
        line.set_color(pdlLine, pdlColor)
        line.set_width(pdlLine, levelWidth)
        line.set_style(pdlLine, line.style_dotted)
        pdlLabel := showLevelLabels ? label.new(labelX, prevDayLow, "PDL", xloc=xloc.bar_index, style=label.style_label_left, color=pdlColor, textcolor=color.white, size=size.tiny) : na
    else
        line.set_xy1(pdlLine, na, na)
        line.set_xy2(pdlLine, na, na)

    // PD50
    if showPD50
        line.set_xy1(pd50Line, x1, prevDayMid)
        line.set_xy2(pd50Line, x2, prevDayMid)
        line.set_color(pd50Line, pd50Color)
        line.set_width(pd50Line, levelWidth)
        line.set_style(pd50Line, line.style_dotted)
        pd50Label := showLevelLabels ? label.new(labelX, prevDayMid, "PD50", xloc=xloc.bar_index, style=label.style_label_left, color=pd50Color, textcolor=color.black, size=size.tiny) : na
    else
        line.set_xy1(pd50Line, na, na)
        line.set_xy2(pd50Line, na, na)

    // PWH
    if showPWH
        line.set_xy1(pwhLine, x1, prevWeekHigh)
        line.set_xy2(pwhLine, x2, prevWeekHigh)
        line.set_color(pwhLine, pwhColor)
        line.set_width(pwhLine, levelWidth)
        line.set_style(pwhLine, line.style_dotted)
        pwhLabel := showLevelLabels ? label.new(labelX, prevWeekHigh, "PWH", xloc=xloc.bar_index, style=label.style_label_left, color=pwhColor, textcolor=color.black, size=size.tiny) : na
    else
        line.set_xy1(pwhLine, na, na)
        line.set_xy2(pwhLine, na, na)

    // PWL
    if showPWL
        line.set_xy1(pwlLine, x1, prevWeekLow)
        line.set_xy2(pwlLine, x2, prevWeekLow)
        line.set_color(pwlLine, pwlColor)
        line.set_width(pwlLine, levelWidth)
        line.set_style(pwlLine, line.style_dotted)
        pwlLabel := showLevelLabels ? label.new(labelX, prevWeekLow, "PWL", xloc=xloc.bar_index, style=label.style_label_left, color=pwlColor, textcolor=color.white, size=size.tiny) : na
    else
        line.set_xy1(pwlLine, na, na)
        line.set_xy2(pwlLine, na, na)

//══════════════════════════════════════════════════════════════════════
// VISUAL STATES
//══════════════════════════════════════════════════════════════════════
bullHold = trendUp and not longSignal
bearHold = trendDn and not shortSignal
weakBull = bullHold and close < fastEMA
weakBear = bearHold and close > fastEMA

barCol =
     longSignal  ? color.lime :
     shortSignal ? color.fuchsia :
     weakBull    ? color.new(color.green, 55) :
     weakBear    ? color.new(color.red, 55) :
     bullHold    ? color.new(color.green, 0) :
     bearHold    ? color.new(color.red, 0) :
                   color.new(color.gray, 55)

//══════════════════════════════════════════════════════════════════════
// MAIN PLOTS
//══════════════════════════════════════════════════════════════════════
fastPlot = plot(showRibbon ? fastEMA : na, "Fast EMA", color=color.new(color.aqua, 0), linewidth=1)
slowPlot = plot(showRibbon ? slowEMA : na, "Slow EMA", color=color.new(color.blue, 20), linewidth=2)

ribbonCol =
     trendUp ? color.new(color.green, 88) :
     trendDn ? color.new(color.red, 88) :
               color.new(color.gray, 92)

fill(fastPlot, slowPlot, showRibbon ? ribbonCol : na, title="Trend Ribbon")

plot(showSwingLines ? lastSwingHigh : na, "Last Swing High", color=color.new(color.red, 50), style=plot.style_linebr)
plot(showSwingLines ? lastSwingLow  : na, "Last Swing Low",  color=color.new(color.green, 50), style=plot.style_linebr)

bgcolor(showBgTrend ? (trendUp ? color.new(color.green, 94) : trendDn ? color.new(color.red, 94) : na) : na)
barcolor(colorBars ? barCol : na)

plotshape(showSignals and longSignal, title="BUY", style=shape.labelup, location=location.belowbar, color=color.lime, text="BUY", textcolor=color.black, size=size.tiny)
plotshape(showSignals and shortSignal, title="SELL", style=shape.labeldown, location=location.abovebar, color=color.fuchsia, text="SELL", textcolor=color.white, size=size.tiny)

//══════════════════════════════════════════════════════════════════════
// DASHBOARD
//══════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 10, border_width=1)

biasText =
     trendUp ? "BULLISH" :
     trendDn ? "BEARISH" :
               "NEUTRAL"

stateText =
     longSignal ? "BUY TRIGGER" :
     shortSignal ? "SELL TRIGGER" :
     trendUp ? "BULL HOLD" :
     trendDn ? "BEAR HOLD" :
     "WAIT"

htfText =
     htfBull ? "HTF BULL" :
     htfBear ? "HTF BEAR" :
               "HTF FLAT"

sessionText = sessionOk ? "SESSION OK" : "OUTSIDE SESSION"
roomLongText = "PDH " + str.tostring(longRoomToPDH, format.mintick) + " | PWH " + str.tostring(longRoomToPWH, format.mintick)
roomShortText = "PDL " + str.tostring(shortRoomToPDL, format.mintick) + " | PWL " + str.tostring(shortRoomToPWL, format.mintick)

if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "Bias", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 0, biasText, text_color=color.white, bgcolor=trendUp ? color.new(color.green, 0) : trendDn ? color.new(color.red, 0) : color.new(color.gray, 25))

    table.cell(dash, 0, 1, "State", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 1, stateText, text_color=color.white, bgcolor=longSignal ? color.new(color.green, 35) : shortSignal ? color.new(color.red, 35) : color.new(color.gray, 40))

    table.cell(dash, 0, 2, "Score", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 2, str.tostring(trendScore) + "/100", text_color=color.white, bgcolor=color.new(color.purple, 55))

    table.cell(dash, 0, 3, "HTF", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 3, htfText, text_color=color.white, bgcolor=color.new(color.navy, 55))

    table.cell(dash, 0, 4, "Session", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 4, sessionText, text_color=color.white, bgcolor=color.new(color.teal, 55))

    table.cell(dash, 0, 5, "PD", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 5, "H " + str.tostring(prevDayHigh, format.mintick) + " | L " + str.tostring(prevDayLow, format.mintick), text_color=color.white, bgcolor=color.new(color.orange, 65))

    table.cell(dash, 0, 6, "PD50", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 6, str.tostring(prevDayMid, format.mintick), text_color=color.white, bgcolor=color.new(color.yellow, 70))

    table.cell(dash, 0, 7, "PW", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 7, "H " + str.tostring(prevWeekHigh, format.mintick) + " | L " + str.tostring(prevWeekLow, format.mintick), text_color=color.white, bgcolor=color.new(color.aqua, 70))

    table.cell(dash, 0, 8, "Room", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 8, trendUp ? roomLongText : trendDn ? roomShortText : "N/A", text_color=color.white, bgcolor=color.new(color.gray, 60))

    table.cell(dash, 0, 9, "Filter", text_color=color.white, bgcolor=color.black)
    table.cell(dash, 1, 9, useLevelEntryFilter ? "LEVEL FILTER ON" : "LEVEL FILTER OFF", text_color=color.white, bgcolor=color.new(color.blue, 65))

//══════════════════════════════════════════════════════════════════════
// ALERTS
//══════════════════════════════════════════════════════════════════════
alertcondition(longSignal, "BUY Entry", "PF V4.1 Indicator BUY on {{ticker}}")
alertcondition(shortSignal, "SELL Entry", "PF V4.1 Indicator SELL on {{ticker}}")
alertcondition(newBullTrend, "New Bull Trend", "PF V4.1 Indicator new bullish trend on {{ticker}}")
alertcondition(newBearTrend, "New Bear Trend", "PF V4.1 Indicator new bearish trend on {{ticker}}")
````
