# LND & NY Liq Sweep + VWAP 1.4

- url: https://www.tradingview.com/script/EUARRykw-LND-NY-Liq-Sweep-VWAP-1-4/
- type: indicator
- pine_id: PUB;68401894260b4e1eb8e1832ac5f61e32
- version: 1.0

## Description

Plots the London range and NY range according to Day Trading Rauf's strategy. Dashboard shows the status of the range and the HTF Bias.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("LND & NY Liq Sweep + VWAP 1.4", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ══════════════════════════════════════════════════════════════════════════════
// CONSTANTS
// ══════════════════════════════════════════════════════════════════════════════
string T_NY   = "America/New_York"
int MS_IN_DAY = 24 * 60 * 60 * 1000

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════

// ── 80/20 Levels ─────────────────────────────────────────────────────────────
groupLevels  = "80/20 Level Settings"
int   step       = input.int(100,   "Price Step (e.g., 100 points)", minval = 10, group = groupLevels)
float offset1    = input.float(20.0, "Level Offset 1",               group = groupLevels)
float offset2    = input.float(80.0, "Level Offset 2",               group = groupLevels)
int   numVisible = input.int(2, "Visible Levels Above/Below", minval = 1, maxval = 20, group = groupLevels,
     tooltip = "Number of 80/20 levels to display above and below the current price")
color levelColor = input.color(color.black, "Level Line Color", group = groupLevels,
     tooltip = "Color for the dashed 80/20 level lines")

// ── Sessions ──────────────────────────────────────────────────────────────────
groupSessions   = "Session Settings (EST)"
string ldnRangeTime = input.session("0112-0212", "London Range Session", group = groupSessions)
string ldnTradeTime = input.session("0230-0500", "London Trade Window",  group = groupSessions)
string nyRangeTime  = input.session("0812-0912", "NY Range Session",     group = groupSessions)
string nyTradeTime  = input.session("0930-1200", "NY Trade Window",      group = groupSessions)
string dashTime     = input.session("0100-1600", "Dashboard Visibility", group = groupSessions)

// ── Signal Filters ────────────────────────────────────────────────────────────
groupFilters = "Signal Filters"
int  minCandles  = input.int(1,    "Min Consecutive Candles for Sweep", minval = 1, group = groupFilters)
bool useDisplace = input.bool(true,  "Require Displacement (High > Prev 5)",  group = groupFilters)
bool useFVG      = input.bool(false, "Require FVG after Rejection",           group = groupFilters)

// ── VWAP ──────────────────────────────────────────────────────────────────────
groupVwap   = "VWAP Settings"
bool  showVwap  = input.bool(true,       "Show Daily VWAP", group = groupVwap)
color vwapColor = input.color(color.blue, "VWAP Color",     group = groupVwap)

// ── EMA ───────────────────────────────────────────────────────────────────────
groupEma   = "EMA Settings"
bool  showEma  = input.bool(true,        "Show 20 EMA (1m only)", group = groupEma)
color emaColor = input.color(color.green, "20 EMA Color",         group = groupEma)

// ── Daily Bias ────────────────────────────────────────────────────────────────
groupBias = "Daily Bias Settings"
bool  showMidnightLine  = input.bool(true, "Show NY Midnight Open Line", group = groupBias)
color midnightLineColor = input.color(color.new(#FF9800, 20), "Midnight Open Color", group = groupBias)
float consolidationMult = input.float(0.4, "Consolidation ATR Multiplier",
     minval = 0.1, maxval = 1.0, step = 0.05, group = groupBias,
     tooltip = "During the first NY hour, if range < this × ATR(14), bias is NEUTRAL.")
bool useWeeklyFilter = input.bool(true, "Require Weekly Trend Alignment", group = groupBias,
     tooltip = "When enabled, bias requires the weekly 20 EMA to agree with the daily 50 EMA direction.")

// ── Visuals ───────────────────────────────────────────────────────────────────
groupStyle = "Visuals"
color bullColor     = input.color(#089981, "Bull Color",             group = groupStyle)
color bearColor     = input.color(#f23645, "Bear Color",             group = groupStyle)
color obColor       = input.color(#FFD700, "Order Block Star Color", group = groupStyle)
color ldnRangeColor = input.color(color.new(#d9e220, 70), "London Range Color", group = groupStyle)
color nyRangeColor  = input.color(color.new(#19e04e, 70), "NY Range Color",     group = groupStyle)
int   daysVisible   = input.int(6, "Days Visible", minval = 1, group = groupStyle)

// ══════════════════════════════════════════════════════════════════════════════
// TIME & SESSION FLAGS
// ══════════════════════════════════════════════════════════════════════════════
int  lastDaysTimestamp = timenow - (daysVisible * MS_IN_DAY)
bool isWithinHistory   = time >= lastDaysTimestamp

bool isLdnRange  = not na(time(timeframe.period, ldnRangeTime, T_NY))
bool isLdnTrade  = not na(time(timeframe.period, ldnTradeTime, T_NY))
int  ldnTradeEnd = time_close(timeframe.period, ldnTradeTime, T_NY)

bool isNyRange   = not na(time(timeframe.period, nyRangeTime, T_NY))
bool isNyTrade   = not na(time(timeframe.period, nyTradeTime, T_NY))
int  nyTradeEnd  = time_close(timeframe.period, nyTradeTime, T_NY)

bool isDashVisible  = not na(time(timeframe.period, dashTime, T_NY))
bool isNyFirstHour  = not na(time(timeframe.period, "0930-1030", T_NY))
bool postFirstHour  = not na(time(timeframe.period, "1031-1600", T_NY))
bool isNewDay       = ta.change(time("D", T_NY)) != 0

// ══════════════════════════════════════════════════════════════════════════════
// DAILY VWAP
// ══════════════════════════════════════════════════════════════════════════════
var float vwapSum   = na
var float volumeSum = na

if isNewDay or na(vwapSum)
    vwapSum   := hlcc4 * volume
    volumeSum := volume
else
    vwapSum   += hlcc4 * volume
    volumeSum += volume

float dailyVwap = vwapSum / volumeSum
plot(showVwap and isWithinHistory ? dailyVwap : na, "Daily VWAP", color = vwapColor, linewidth = 1)

// ══════════════════════════════════════════════════════════════════════════════
// 20 EMA (1m)
// ══════════════════════════════════════════════════════════════════════════════
float ema20 = ta.ema(close, 20)
plot(showEma and timeframe.period == "1" and isWithinHistory ? ema20 : na, "20 EMA", color = emaColor, linewidth = 1)

// ══════════════════════════════════════════════════════════════════════════════
// 1-MINUTE CONSECUTIVE CANDLE CONTEXT (MTF)
// ══════════════════════════════════════════════════════════════════════════════
float m1Close = request.security(syminfo.tickerid, "1", close)

var int consecutiveDown = 0
var int consecutiveUp   = 0

if m1Close < m1Close[1]
    consecutiveDown += 1
    consecutiveUp   := 0
else if m1Close > m1Close[1]
    consecutiveUp   += 1
    consecutiveDown := 0
else
    consecutiveDown := 0
    consecutiveUp   := 0

// ══════════════════════════════════════════════════════════════════════════════
// HTF BIAS ENGINE  (v1.4 — fixes "HTF Flat" always appearing)
//
//  WHAT CHANGED FROM v1.3
//  ────────────────────────────────────────────────────────────────────────────
//  • htfBullish / htfBearish now derive solely from price vs 50 EMA.
//    Previously both required slope agreement → silence when EMA was flat.
//  • EMA slope measured over 5 daily bars (was 1 bar — very noisy).
//  • Daily 200 EMA added as a macro alignment layer.
//  • Weekly 20 EMA added as an optional cross-timeframe filter.
//  • Three strength tiers replace the flat/bull/bear binary:
//      Strong   – price, 50 EMA slope, and 200 EMA all agree
//      Confirmed – price + 50 EMA slope agree (200 EMA mixed)
//      Caution  – price above/below 50 EMA but slope is counter-directional
//  • "HTF Flat" label is gone; replaced with "Caution" when diverging.
//  • Bias engine gains a CAUTION state when weekly disagrees or slope fights.
//  • Dashboard gains a 5th row: D200 position, W20 position, consolidation.
// ══════════════════════════════════════════════════════════════════════════════

// ── 1. HTF Data (single request for efficiency) ───────────────────────────────
[daily50EMA, daily200EMA, dailyCloseH] = request.security(
     syminfo.tickerid, "D",
     [ta.ema(close, 50), ta.ema(close, 200), close],
     lookahead = barmerge.lookahead_off)

float weekly20EMA = request.security(syminfo.tickerid, "W", ta.ema(close, 20),
     lookahead = barmerge.lookahead_off)

// ── 2. Smoothed slope (5-bar window reduces single-day noise) ─────────────────
float d50Slope = daily50EMA - daily50EMA[5]

// ── 3. Price position — PRIMARY signal, always resolves bull or bear ──────────
bool priceAbove50    = dailyCloseH > daily50EMA
bool priceAbove200   = dailyCloseH > daily200EMA
bool ema50Above200   = daily50EMA  > daily200EMA   // golden / death cross context

bool htfBullish = priceAbove50          // always true or false — never "flat"
bool htfBearish = not priceAbove50

// ── 4. Strength tiers (slope + 200 EMA are modifiers, not gates) ──────────────
bool htfBullStrong    = htfBullish and d50Slope > 0 and priceAbove200 and ema50Above200
bool htfBullConfirmed = htfBullish and d50Slope > 0 and not htfBullStrong
bool htfBullCaution   = htfBullish and d50Slope <= 0   // pullback / transition

bool htfBearStrong    = htfBearish and d50Slope < 0 and not priceAbove200 and not ema50Above200
bool htfBearConfirmed = htfBearish and d50Slope < 0 and not htfBearStrong
bool htfBearCaution   = htfBearish and d50Slope >= 0   // bounce / transition

// ── 5. Weekly alignment ───────────────────────────────────────────────────────
bool weeklyBullish = dailyCloseH > weekly20EMA
bool weeklyBearish = not weeklyBullish
bool weeklyAligned = useWeeklyFilter ? (htfBullish == weeklyBullish) : true

// ── 6. HTF dashboard label and color ─────────────────────────────────────────
string htfLabel = htfBullStrong    ? "HTF ▲▲ Strong"
     : htfBullConfirmed            ? "HTF ▲  Bull"
     : htfBullCaution              ? "HTF △  Caution"
     : htfBearStrong               ? "HTF ▼▼ Strong"
     : htfBearConfirmed            ? "HTF ▼  Bear"
     :                               "HTF ▽  Caution"

color htfColor = htfBullStrong    ? #00E676
     : htfBullConfirmed           ? color.new(#00E676, 20)
     : htfBullCaution             ? #FFD700
     : htfBearStrong              ? #FF6666
     : htfBearConfirmed           ? color.new(#FF6666, 10)
     :                              #FFD700

// ── 7. NY Midnight Open ───────────────────────────────────────────────────────
var float midnightOpen = na
if isNewDay
    midnightOpen := open

plot(showMidnightLine and isWithinHistory and not na(midnightOpen) ? midnightOpen : na,
     "NY Midnight Open", color = midnightLineColor, linewidth = 1, style = plot.style_stepline)

// ── 8. First NY Hour Consolidation Lock (09:30–10:30 EST) ────────────────────
var float nyFHHigh = na
var float nyFHLow  = na
if isNewDay
    nyFHHigh := na
    nyFHLow  := na
if isNyFirstHour and isWithinHistory
    nyFHHigh := na(nyFHHigh) ? high : math.max(nyFHHigh, high)
    nyFHLow  := na(nyFHLow)  ? low  : math.min(nyFHLow,  low)

float atr14 = ta.atr(14)

// State-lock: freeze consolidation flag after first hour ends
var bool isConsolidating = false
if isNyFirstHour
    isConsolidating := not na(nyFHHigh) and not na(nyFHLow) and
         ((nyFHHigh - nyFHLow) < (consolidationMult * atr14))
else if postFirstHour
    isConsolidating := isConsolidating[1]
else
    isConsolidating := false

// ── 9. Intraday Bias ──────────────────────────────────────────────────────────
//   HTF Bullish + price < Midnight Open  →  market drawing low-side liquidity
//                                            before continuing up  →  look long
//   HTF Bearish + price > Midnight Open  →  market drawing high-side liquidity
//                                            before continuing down →  look short
bool bullishBias = htfBullish and weeklyAligned
     and not na(midnightOpen) and (close < midnightOpen) and not isConsolidating
bool bearishBias = htfBearish and weeklyAligned
     and not na(midnightOpen) and (close > midnightOpen) and not isConsolidating

// Caution when slope fights price direction or weekly trend disagrees
bool biasCaution = (htfBullCaution or htfBearCaution)
     or (useWeeklyFilter and not weeklyAligned)

string biasText  = bullishBias ? "▲  BULLISH"
     : bearishBias             ? "▼  BEARISH"
     : biasCaution             ? "⚠  CAUTION"
     :                           "●  NEUTRAL"

color biasColor  = bullishBias ? #00E676
     : bearishBias             ? #FF6666
     : biasCaution             ? #FFD700
     :                           #FFFFFF

color biasBg     = bullishBias ? color.new(#424242, 30)
     : bearishBias             ? color.new(#424242, 30)
     : biasCaution             ? color.new(#424242, 30)
     :                           color.new(#424242, 30)

string mnoLabel  = not na(midnightOpen)
     ? "MNO " + str.tostring(midnightOpen, format.mintick) : "MNO  ──"

// ══════════════════════════════════════════════════════════════════════════════
// SESSION RANGE TRACKING
// ══════════════════════════════════════════════════════════════════════════════
updateRange(bool isRange, bool isWithin, float h, float l) =>
    var float rHigh = na
    var float rLow  = na
    if isRange and isWithin
        if not isRange[1] or isNewDay
            rHigh := h
            rLow  := l
        else
            rHigh := math.max(rHigh, h)
            rLow  := math.min(rLow, l)
    [rHigh, rLow]

[ldnHigh, ldnLow] = updateRange(isLdnRange, isWithinHistory, high, low)
[nyHigh,  nyLow]  = updateRange(isNyRange,  isWithinHistory, high, low)

// ══════════════════════════════════════════════════════════════════════════════
// RANGE BOXES & LEVEL LINES
// ══════════════════════════════════════════════════════════════════════════════
var box  ldnBox   = na
var line ldnHLine = na, var line ldnMLine = na, var line ldnLLine = na
var box  nyBox    = na
var line nyHLine  = na, var line nyMLine  = na, var line nyLLine  = na

// London range box
if isLdnRange and isWithinHistory
    float mid = (ldnHigh + ldnLow) / 2
    if not isLdnRange[1] or isNewDay
        ldnBox   := box.new(bar_index, ldnHigh, bar_index, ldnLow, bgcolor = ldnRangeColor, border_color = na)
        ldnHLine := line.new(bar_index, ldnHigh, bar_index, ldnHigh, color = color.new(#902e2e, 10), style = line.style_solid,  width = 2)
        ldnMLine := line.new(bar_index, mid,     bar_index, mid,     color = color.new(#902e2e, 30), style = line.style_dotted, width = 2)
        ldnLLine := line.new(bar_index, ldnLow,  bar_index, ldnLow,  color = color.new(#902e2e, 10), style = line.style_solid,  width = 2)
    else
        box.set_top(ldnBox, ldnHigh)
        box.set_bottom(ldnBox, ldnLow)
        box.set_right(ldnBox, bar_index)
        line.set_xy1(ldnHLine, line.get_x1(ldnHLine), ldnHigh)
        line.set_xy2(ldnHLine, bar_index, ldnHigh)
        line.set_xy1(ldnMLine, line.get_x1(ldnMLine), mid)
        line.set_xy2(ldnMLine, bar_index, mid)
        line.set_xy1(ldnLLine, line.get_x1(ldnLLine), ldnLow)
        line.set_xy2(ldnLLine, bar_index, ldnLow)
else if not na(ldnHLine) and time <= ldnTradeEnd
    line.set_x2(ldnHLine, bar_index)
    line.set_x2(ldnMLine, bar_index)
    line.set_x2(ldnLLine, bar_index)

// NY range box
if isNyRange and isWithinHistory
    float mid = (nyHigh + nyLow) / 2
    if not isNyRange[1] or isNewDay
        nyBox   := box.new(bar_index, nyHigh, bar_index, nyLow, bgcolor = nyRangeColor, border_color = na)
        nyHLine := line.new(bar_index, nyHigh, bar_index, nyHigh, color = color.new(#357d38, 10), style = line.style_solid,  width = 2)
        nyMLine := line.new(bar_index, mid,    bar_index, mid,    color = color.new(#357d38, 30), style = line.style_dotted, width = 2)
        nyLLine := line.new(bar_index, nyLow,  bar_index, nyLow,  color = color.new(#357d38, 10), style = line.style_solid,  width = 2)
    else
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)
        box.set_right(nyBox, bar_index)
        line.set_xy1(nyHLine, line.get_x1(nyHLine), nyHigh)
        line.set_xy2(nyHLine, bar_index, nyHigh)
        line.set_xy1(nyMLine, line.get_x1(nyMLine), mid)
        line.set_xy2(nyMLine, bar_index, mid)
        line.set_xy1(nyLLine, line.get_x1(nyLLine), nyLow)
        line.set_xy2(nyLLine, bar_index, nyLow)
else if not na(nyHLine) and time <= nyTradeEnd
    line.set_x2(nyHLine, bar_index)
    line.set_x2(nyMLine, bar_index)
    line.set_x2(nyLLine, bar_index)

// ══════════════════════════════════════════════════════════════════════════════
// SWEEP LOGIC
// ══════════════════════════════════════════════════════════════════════════════
var bool ldnSweptLow  = false
var bool ldnSweptHigh = false
var bool nySweptLow   = false
var bool nySweptHigh  = false

var int ldnSweptLowTime  = na
var int ldnSweptHighTime = na
var int nySweptLowTime   = na
var int nySweptHighTime  = na

if isNewDay
    ldnSweptLow      := false
    ldnSweptHigh     := false
    nySweptLow       := false
    nySweptHigh      := false
    consecutiveDown  := 0
    consecutiveUp    := 0
    ldnSweptLowTime  := na
    ldnSweptHighTime := na
    nySweptLowTime   := na
    nySweptHighTime  := na

if isLdnTrade
    if low < ldnLow and consecutiveDown >= minCandles
        ldnSweptLow := true
    if high > ldnHigh and consecutiveUp >= minCandles
        ldnSweptHigh := true

if isNyTrade
    if low < nyLow and consecutiveDown >= minCandles
        nySweptLow := true
    if high > nyHigh and consecutiveUp >= minCandles
        nySweptHigh := true

// ══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ══════════════════════════════════════════════════════════════════════════════
bool alertLdnLow  = not ldnSweptLow[1]  and ldnSweptLow  and isLdnTrade
bool alertLdnHigh = not ldnSweptHigh[1] and ldnSweptHigh and isLdnTrade
bool alertNyLow   = not nySweptLow[1]   and nySweptLow   and isNyTrade
bool alertNyHigh  = not nySweptHigh[1]  and nySweptHigh  and isNyTrade

if alertLdnLow
    ldnSweptLowTime := time_close
    alert("London Range Swept LOW | Ticker: " + syminfo.ticker, alert.freq_once_per_bar)
if alertLdnHigh
    ldnSweptHighTime := time_close
    alert("London Range Swept HIGH | Ticker: " + syminfo.ticker, alert.freq_once_per_bar)
if alertNyLow
    nySweptLowTime := time_close
    alert("NY Range Swept LOW | Ticker: " + syminfo.ticker, alert.freq_once_per_bar)
if alertNyHigh
    nySweptHighTime := time_close
    alert("NY Range Swept HIGH | Ticker: " + syminfo.ticker, alert.freq_once_per_bar)

alertcondition(alertLdnLow or alertLdnHigh or alertNyLow or alertNyHigh,
     title = "Any Session Range Swept", message = "{{ticker}} - Range Swept")

// ══════════════════════════════════════════════════════════════════════════════
// 80/20 LEVEL VISUALIZATION  (last bar only)
// ══════════════════════════════════════════════════════════════════════════════
float p20 = math.round((close - offset1) / step) * step + offset1
float p80 = math.round((close - offset2) / step) * step + offset2

var line[]  levelLines  = array.new<line>()
var label[] levelLabels = array.new<label>()

if barstate.islast
    for l  in levelLines
        line.delete(l)
    for lb in levelLabels
        label.delete(lb)
    array.clear(levelLines)
    array.clear(levelLabels)

    float midBase = math.floor(close / step) * step

    for i = -numVisible to numVisible
        float base = midBase + (i * step)
        float l20  = base + offset1
        float l80  = base + offset2

        array.push(levelLines,  line.new(bar_index[100], l20, bar_index + 11, l20, color = levelColor, style = line.style_dashed))
        array.push(levelLabels, label.new(bar_index + 10, l20, str.tostring(l20, format.mintick),
             color = #00000000, textcolor = bullColor, style = label.style_label_left, size = size.small))

        array.push(levelLines,  line.new(bar_index[100], l80, bar_index + 11, l80, color = levelColor, style = line.style_dashed))
        array.push(levelLabels, label.new(bar_index + 10, l80, str.tostring(l80, format.mintick),
             color = #00000000, textcolor = bearColor, style = label.style_label_left, size = size.small))

// ══════════════════════════════════════════════════════════════════════════════
// SIGNAL CONDITIONS
// ══════════════════════════════════════════════════════════════════════════════
bool touches20    = low  <= p20 and close > p20
bool touches80    = high >= p80 and close < p80
bool displacement = (high - low) > ta.highest(high - low, 5)[1]
bool bullFVG      = low  > high[2] and close > high[2]
bool bearFVG      = high < low[2]  and close < low[2]

bool ldnLong  = isLdnTrade and ldnSweptLow  and touches20 and (useDisplace ? displacement : true) and (useFVG ? bullFVG : true)
bool ldnShort = isLdnTrade and ldnSweptHigh and touches80 and (useDisplace ? displacement : true) and (useFVG ? bearFVG : true)
bool nyLong   = isNyTrade  and nySweptLow   and touches20 and (useDisplace ? displacement : true) and (useFVG ? bullFVG : true)
bool nyShort  = isNyTrade  and nySweptHigh  and touches80 and (useDisplace ? displacement : true) and (useFVG ? bearFVG : true)

// ══════════════════════════════════════════════════════════════════════════════
// ORDER BLOCK DETECTION
// ══════════════════════════════════════════════════════════════════════════════
bool isLdnHighSweep = isLdnTrade and high > ldnHigh and consecutiveUp   >= minCandles
bool isLdnLowSweep  = isLdnTrade and low  < ldnLow  and consecutiveDown >= minCandles
bool isNyHighSweep  = isNyTrade  and high > nyHigh  and consecutiveUp   >= minCandles
bool isNyLowSweep   = isNyTrade  and low  < nyLow   and consecutiveDown >= minCandles

bool isGreenCandle = close > open
bool isRedCandle   = close < open

bool isBullishOBMatch = (isLdnLowSweep  or isNyLowSweep)  and isRedCandle
bool isBearishOBMatch = (isLdnHighSweep or isNyHighSweep) and isGreenCandle

// ══════════════════════════════════════════════════════════════════════════════
// VISUAL SIGNALS
// ══════════════════════════════════════════════════════════════════════════════
plotshape(isWithinHistory and (ldnLong  or nyLong),  "Bull Sweep", shape.triangleup,   location.belowbar, bullColor, size = size.tiny)
plotshape(isWithinHistory and (ldnShort or nyShort), "Bear Sweep", shape.triangledown, location.abovebar, bearColor, size = size.tiny)
plotshape(isWithinHistory and isBullishOBMatch, "Bullish OB", shape.arrowup,   location.belowbar, obColor, size = size.small)
plotshape(isWithinHistory and isBearishOBMatch, "Bearish OB", shape.arrowdown, location.abovebar, obColor, size = size.small)

// ══════════════════════════════════════════════════════════════════════════════
// DASHBOARD  (5 rows × 4 columns)
// ══════════════════════════════════════════════════════════════════════════════
sweepTimeStr(int t) =>
    na(t) ? "" : "\n" + str.format_time(t, "HH:mm", T_NY)

var table dash = table.new(position.bottom_right, 4, 5,
     border_width = 1, border_color = chart.fg_color,
     bgcolor = color.new(#0A0A0A, 90))

if barstate.islast
    if isDashVisible
        color c_header = color.new(chart.fg_color, 80)

        // Row 0 — column headers
        table.cell(dash, 0, 0, "Session",    bgcolor = c_header, text_size = size.small, text_color = chart.fg_color)
        table.cell(dash, 1, 0, "Status",     bgcolor = c_header, text_size = size.small, text_color = chart.fg_color)
        table.cell(dash, 2, 0, "Low Swept",  bgcolor = c_header, text_size = size.small, text_color = chart.fg_color)
        table.cell(dash, 3, 0, "High Swept", bgcolor = c_header, text_size = size.small, text_color = chart.fg_color)

        // Row 1 — London
        table.cell(dash, 0, 1, "London", text_color = chart.fg_color, text_size = size.small)
        table.cell(dash, 1, 1,
             isLdnTrade ? "TRADING" : isLdnRange ? "RANGE" : "WAITING",
             bgcolor    = isLdnTrade ? bullColor : isLdnRange ? #5b9cf6 : color.gray,
             text_size  = size.small)
        table.cell(dash, 2, 1, ldnSweptLow  ? "YES" + sweepTimeStr(ldnSweptLowTime)  : "NO",
             bgcolor = ldnSweptLow  ? bullColor : color.gray, text_size = size.small,
             text_color = ldnSweptLow  ? color.white : na)
        table.cell(dash, 3, 1, ldnSweptHigh ? "YES" + sweepTimeStr(ldnSweptHighTime) : "NO",
             bgcolor = ldnSweptHigh ? bearColor : color.gray, text_size = size.small,
             text_color = ldnSweptHigh ? color.white : na)

        // Row 2 — NY
        table.cell(dash, 0, 2, "NY", text_color = chart.fg_color, text_size = size.small)
        table.cell(dash, 1, 2,
             isNyTrade ? "TRADING" : isNyRange ? "RANGE" : "WAITING",
             bgcolor   = isNyTrade ? bullColor : isNyRange ? #5b9cf6 : color.gray,
             text_size = size.small)
        table.cell(dash, 2, 2, nySweptLow  ? "YES" + sweepTimeStr(nySweptLowTime)  : "NO",
             bgcolor = nySweptLow  ? bullColor : color.gray, text_size = size.small,
             text_color = nySweptLow  ? color.white : na)
        table.cell(dash, 3, 2, nySweptHigh ? "YES" + sweepTimeStr(nySweptHighTime) : "NO",
             bgcolor = nySweptHigh ? bearColor : color.gray, text_size = size.small,
             text_color = nySweptHigh ? color.white : na)

        // Row 3 — Daily Bias
        table.cell(dash, 0, 3, "Daily Bias",
             bgcolor = color.new(#1A1A1A, 30), text_color = color.new(#BDBDBD, 0), text_size = size.small)
        table.cell(dash, 1, 3, biasText,
             bgcolor = biasBg, text_color = biasColor, text_size = size.small)
        table.cell(dash, 2, 3, htfLabel,
             bgcolor = color.new(#1A1A1A, 30), text_color = htfColor, text_size = size.small)
        table.cell(dash, 3, 3, mnoLabel,
             bgcolor = color.new(#1A1A1A, 30), text_color = color.new(#FF9800, 10), text_size = size.small)

        // Row 4 — HTF Context (new in v1.4)
        string d200Label  = priceAbove200  ? "D200 ▲"  : "D200 ▼"
        color  d200Color  = priceAbove200  ? #00E676   : #FF6666
        string wkLabel    = weeklyBullish  ? "W20  ▲"  : "W20  ▼"
        color  wkColor    = weeklyBullish  ? #00E676   : #FF6666
        string consLabel  = isConsolidating ? "CONSOL"  : "CLEAR"
        color  consBg     = isConsolidating
             ? color.new(#FFD700, 70) : color.new(#1A1A1A, 50)

        table.cell(dash, 0, 4, "HTF Ctx",
             bgcolor = color.new(#1A1A1A, 30), text_color = color.new(#BDBDBD, 0), text_size = size.small)
        table.cell(dash, 1, 4, d200Label,
             bgcolor = color.new(#1A1A1A, 30), text_color = d200Color, text_size = size.small)
        table.cell(dash, 2, 4, wkLabel,
             bgcolor = color.new(#1A1A1A, 30), text_color = wkColor,   text_size = size.small)
        table.cell(dash, 3, 4, consLabel,
             bgcolor = consBg, text_color = chart.fg_color, text_size = size.small)
    else
        table.clear(dash, 0, 0, 3, 4)
````
