<!-- tradingview-pine-id: PUB;f30937128c844c359da138147badc641 -->
<!-- tradingviewscripts-format: 1 -->
# ABQ 10-Min ORB Pro v9 ULTRA CLEAN

Source: https://www.tradingview.com/script/ZYfbAfz4-ABQ-10-Min-ORB-Pro-v9-ULTRA-CLEAN-V2/

## Description

Improvements
Risk and reward zones now use 93% transparency by default.
Zones and trade lines begin after the entry candle.
Entry candle only receives a tiny LONG/SHORT grade tag.
Removed the full-height dotted entry marker.
Large setup-details label is off by default.
SL, TP1 and TP2 lines are thinner and less dominant.
Trade-zone width reduced from 24 to 18 candles.
Key levels are softer and less visually aggressive.
Nearby overlapping key levels are merged using both ticks and ATR distance.
Prior MTD levels are optional and disabled by default to reduce duplicate lines.
ORB midpoint is disabled by default.
The checklist is now on by default, but reduced to a compact transparent 3-column panel.
Checklist still displays:
Long and short score
Current stat
Break readiness
VWAP and EMA alignment
RVOL and ORB quality
HTF bias
VIX and QQQ alignment

The core setup remains:

Confirmed 10-minute ORB break → entry at confirmed close → SL back inside the ORB reclaim area → TP2 exactly 2R.

---

## Source Code

````pine
//@version=6
indicator(
     "ABQ 10-Min ORB Pro v9 ULTRA CLEAN",
     shorttitle = "ABQ ORB v9",
     overlay = true,
     max_lines_count = 250,
     max_labels_count = 250,
     max_boxes_count = 50)

//==============================================================================
// ABQ 10-MIN ORB PRO v9 — ULTRA-CLEAN QUANT INDICATOR
// - Builds a true 09:30–09:40 opening range.
// - Signals only on confirmed candle closes.
// - Default stop invalidates when price reclaims the ORB and returns toward the
//   breakout candle's origin, capped so the stop does not sit too deep in range.
// - Main reward target is exactly 2R by default.
// - PDH/PDL, previous close, PWH/PWL, previous-month H/L, prior MTD H/L,
//   premarket H/L, and RTH open are drawn and used as liquidity checkpoints.
// - Entry candle uses one small exact-candle tag; no candle box or full-height marker.
// - Risk/reward zones begin AFTER the entry bar and use soft default opacity.
// - The quant checklist is visible by default in a compact three-column panel.
// - HTF, VWAP, EMA, RVOL, VIX, benchmark, ORB quality, displacement and candle
//   quality feed a weighted score. Context improves confidence without turning
//   every optional filter into a hard blocker.
//==============================================================================

string G_ORB     = "1. ORB & Entry"
string G_SCORE   = "2. Quant Confirmation"
string G_CONTEXT = "3. HTF / VIX / Benchmark"
string G_LEVELS  = "4. Key Liquidity Levels"
string G_RISK    = "5. Stop & 2R Target"
string G_VIS     = "6. Visuals"
string G_ALERTS  = "7. Alerts"

//------------------------------------------------------------------------------
// 1. ORB & entry
//------------------------------------------------------------------------------
string orbSession    = input.session("0930-0940", "10-minute ORB", group = G_ORB)
string entrySession  = input.session("0940-1200", "Signal window", group = G_ORB)
string entryMode     = input.string("Confirmed breakout", "Entry model",
     options = ["Confirmed breakout", "Breakout + retest"], group = G_ORB)
bool allowLongs      = input.bool(true, "Longs", inline = "SIDE", group = G_ORB)
bool allowShorts     = input.bool(true, "Shorts", inline = "SIDE", group = G_ORB)
int maxSignalsDay    = input.int(1, "Maximum signals per day", minval = 1, maxval = 3, group = G_ORB)
int breakBufferTicks = input.int(1, "Confirmed close beyond ORB (ticks)", minval = 0, maxval = 100, group = G_ORB)
bool freshBreakOnly  = input.bool(true, "Require fresh cross from inside range", group = G_ORB,
     tooltip = "ON: the signal candle must be the first confirmed close crossing the ORB boundary. Wicks do not count.")
int retestBars       = input.int(10, "Retest expires after bars", minval = 1, maxval = 60, group = G_ORB)
float retestTolAtr   = input.float(0.12, "Retest tolerance (ATR)", minval = 0.0, maxval = 1.0, step = 0.01, group = G_ORB)

//------------------------------------------------------------------------------
// 2. Quant confirmation
//------------------------------------------------------------------------------
int atrLength          = input.int(14, "ATR length", minval = 1, group = G_SCORE)
float minBodyPct       = input.float(40.0, "Minimum breakout body %", minval = 0, maxval = 100, step = 5, group = G_SCORE)
float minCloseLocPct   = input.float(60.0, "Minimum directional close location %", minval = 50, maxval = 100, step = 5, group = G_SCORE)
float minRangeAtr      = input.float(0.30, "Minimum breakout range / ATR", minval = 0.0, maxval = 5.0, step = 0.05, group = G_SCORE)
float maxExtensionAtr  = input.float(1.25, "Maximum close extension from ORB (ATR)", minval = 0.1, maxval = 10.0, step = 0.05, group = G_SCORE)
int volumeLength       = input.int(20, "RVOL average", minval = 1, group = G_SCORE)
float minimumRvol      = input.float(1.00, "Full RVOL score at", minval = 0.1, maxval = 10.0, step = 0.05, group = G_SCORE)
int fastEmaLength      = input.int(9, "Fast EMA", minval = 1, group = G_SCORE)
int slowEmaLength      = input.int(20, "Slow EMA", minval = 2, group = G_SCORE)
bool requireVwap       = input.bool(true, "Require price on correct side of VWAP", group = G_SCORE)
bool requireVwapSlope  = input.bool(false, "Also require VWAP slope", group = G_SCORE)
float minOrbWidthAtr5  = input.float(0.60, "Healthy ORB minimum / 5m ATR", minval = 0.0, maxval = 10.0, step = 0.05, group = G_SCORE)
float maxOrbWidthAtr5  = input.float(3.50, "Healthy ORB maximum / 5m ATR", minval = 0.1, maxval = 20.0, step = 0.05, group = G_SCORE)
float minimumScorePct  = input.float(55.0, "Minimum weighted score %", minval = 0, maxval = 100, step = 1, group = G_SCORE,
     tooltip = "Hard gates are the confirmed break, directional candle, displacement, anti-chase and optional VWAP. HTF/VIX/benchmark mainly affect the weighted score.")

//------------------------------------------------------------------------------
// 3. HTF / VIX / benchmark
//------------------------------------------------------------------------------
bool scoreHtf = input.bool(true, "Score confirmed higher-timeframe bias", group = G_CONTEXT)
string htf1 = input.timeframe("15", "HTF 1", inline = "HTF", group = G_CONTEXT)
string htf2 = input.timeframe("60", "HTF 2", inline = "HTF", group = G_CONTEXT)
string htf3 = input.timeframe("240", "HTF 3", inline = "HTF2", group = G_CONTEXT)
string htf4 = input.timeframe("1D", "HTF 4", inline = "HTF2", group = G_CONTEXT)
int htfFastLength = input.int(20, "HTF fast EMA", minval = 1, group = G_CONTEXT)
int htfSlowLength = input.int(50, "HTF slow EMA", minval = 2, group = G_CONTEXT)

bool scoreVix = input.bool(true, "Score confirmed VIX alignment", group = G_CONTEXT)
string vixSymbol = input.symbol("CBOE:VIX", "VIX symbol", group = G_CONTEXT)
string vixTimeframe = input.timeframe("5", "VIX timeframe", group = G_CONTEXT)
int vixEmaLength = input.int(20, "VIX EMA", minval = 1, group = G_CONTEXT)
int vixSlopeBars = input.int(3, "VIX slope bars", minval = 1, maxval = 30, group = G_CONTEXT)

bool scoreBenchmark = input.bool(true, "Score benchmark alignment", group = G_CONTEXT)
string benchmarkSymbol = input.symbol("NASDAQ:QQQ", "Benchmark", group = G_CONTEXT)

//------------------------------------------------------------------------------
// 4. Key liquidity levels
//------------------------------------------------------------------------------
string premarketSession = input.session("0400-0930", "Premarket session", group = G_LEVELS)
bool useDayLevels       = input.bool(true, "PDH / PDL / previous close", group = G_LEVELS)
bool useWeekLevels      = input.bool(true, "PWH / PWL", group = G_LEVELS)
bool useMonthLevels     = input.bool(true, "Previous-month high / low", group = G_LEVELS)
bool usePriorMtdLevels  = input.bool(false, "Prior month-to-date high / low", group = G_LEVELS)
bool usePremarketLevels = input.bool(true, "Premarket high / low", group = G_LEVELS)
bool useRthOpen         = input.bool(true, "RTH open", group = G_LEVELS)
float minimumCheckpointR = input.float(0.75, "Minimum liquidity checkpoint distance (R)", minval = 0.1, maxval = 2.0, step = 0.05, group = G_LEVELS)
int mergeLevelTicks      = input.int(5, "Merge duplicate levels (ticks)", minval = 0, maxval = 100, group = G_LEVELS)
float mergeLevelAtr      = input.float(0.05, "Merge nearby levels (ATR)", minval = 0.0, maxval = 1.0, step = 0.01, group = G_LEVELS)

//------------------------------------------------------------------------------
// 5. Stop & 2R target
//------------------------------------------------------------------------------
string stopMode = input.string("Break origin + ORB reclaim", "Stop model",
     options = ["Break origin + ORB reclaim", "ORB reclaim only", "Breakout candle", "ORB midpoint", "Opposite ORB", "ATR"], group = G_RISK)
float reclaimDepthPct = input.float(3.0, "Minimum reclaim depth into ORB %", minval = 0, maxval = 100, step = 1, group = G_RISK,
     tooltip = "For a short, the stop sits back above the ORB low and inside the old range. For a long, it sits below the ORB high and inside the old range.")
float maxStopDepthPct = input.float(35.0, "Maximum stop depth into ORB %", minval = 1, maxval = 100, step = 1, group = G_RISK)
int stopBufferTicks   = input.int(1, "Stop buffer (ticks)", minval = 0, maxval = 100, group = G_RISK)
float atrStopMult     = input.float(0.75, "ATR stop multiplier", minval = 0.1, maxval = 5.0, step = 0.05, group = G_RISK)
float mainTargetR     = input.float(2.0, "Main reward target (R)", minval = 0.5, maxval = 10.0, step = 0.25, group = G_RISK)
float fallbackCheckpointR = input.float(1.0, "Fallback TP1 checkpoint (R)", minval = 0.25, maxval = 1.75, step = 0.25, group = G_RISK)
bool moveStopToBE     = input.bool(true, "Move tracked stop to breakeven after TP1", group = G_RISK)
int tradeBoxBars      = input.int(18, "Trade zone width (bars)", minval = 5, maxval = 100, group = G_RISK)

//------------------------------------------------------------------------------
// 6. Visuals
//------------------------------------------------------------------------------
bool showOrbMid       = input.bool(false, "Show ORB midpoint", group = G_VIS)
bool showAverages     = input.bool(true, "Show VWAP + 9/20 EMA", group = G_VIS)
bool showKeyLevels    = input.bool(true, "Show key-level lines", group = G_VIS)
bool showLevelLabels  = input.bool(true, "Show key-level names and prices", group = G_VIS)
int levelLabelOffset  = input.int(6, "Key-level label offset (bars)", minval = 1, maxval = 30, group = G_VIS)
bool showTradeZones   = input.bool(true, "Show soft risk/reward zones", group = G_VIS)
bool showDashboard    = input.bool(true, "Show mini quant checklist", group = G_VIS)
bool showBreakMarkers = input.bool(false, "Show retest-arm marker", group = G_VIS)
bool showEntryMarker  = input.bool(true, "Mark exact entry candle", group = G_VIS)
bool showSetupLabel   = input.bool(false, "Show extra setup note", group = G_VIS)

color orbHighColor = input.color(color.new(color.lime, 10), "ORB high", group = G_VIS)
color orbLowColor  = input.color(color.new(color.red, 10), "ORB low", group = G_VIS)
color orbMidColor  = input.color(color.new(color.gray, 60), "ORB midpoint", group = G_VIS)
color riskColor    = input.color(color.new(color.red, 93), "Risk zone", group = G_VIS)
color rewardColor  = input.color(color.new(color.green, 93), "Reward zone", group = G_VIS)

//------------------------------------------------------------------------------
// 7. Alerts
//------------------------------------------------------------------------------
bool alertOnEntry = input.bool(true, "Entry alerts", group = G_ALERTS)
bool alertOnTp    = input.bool(true, "TP alerts", group = G_ALERTS)
bool alertOnStop  = input.bool(true, "Stop alerts", group = G_ALERTS)

//------------------------------------------------------------------------------
// Helpers
//------------------------------------------------------------------------------
f_clamp(float value, float lowValue, float highValue) =>
    math.max(lowValue, math.min(highValue, value))

f_grade(float score) =>
    score >= 85 ? "A+" : score >= 75 ? "A" : score >= 65 ? "B" : score >= 55 ? "C" : "NO TRADE"

f_addLiquidity(array<float> prices, array<string> names, bool enabled, float price, string name) =>
    if enabled and not na(price) and price > 0
        array.push(prices, price)
        array.push(names, name)

//------------------------------------------------------------------------------
// Time and base calculations
//------------------------------------------------------------------------------
string weekdays = ":23456"
bool inOrb = not na(time(timeframe.period, orbSession + weekdays))
bool inEntry = not na(time(timeframe.period, entrySession + weekdays))
bool inRth = not na(time(timeframe.period, "0930-1600" + weekdays))
bool rthStart = inRth and not inRth[1]
bool orbStart = inOrb and not inOrb[1]
bool orbEnd = not inOrb and inOrb[1]
bool newDay = timeframe.change("D")
bool newMonth = timeframe.change("M")
bool validTf = timeframe.isintraday and timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds("5")

float atr = ta.atr(atrLength)
float atr5 = request.security(syminfo.tickerid, "5", ta.atr(atrLength), gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off)
float emaFast = ta.ema(close, fastEmaLength)
float emaSlow = ta.ema(close, slowEmaLength)
float vwapValue = ta.vwap(hlc3)
float avgVolume = ta.sma(volume, volumeLength)
float rvol = not na(avgVolume) and avgVolume > 0 ? volume / avgVolume : na

float barRange = high - low
float barBody = math.abs(close - open)
float bodyPct = barRange > 0 ? barBody / barRange * 100.0 : 0.0
float longCloseLoc = barRange > 0 ? (close - low) / barRange * 100.0 : 50.0
float shortCloseLoc = barRange > 0 ? (high - close) / barRange * 100.0 : 50.0

//------------------------------------------------------------------------------
// Confirmed HTF context: previous completed HTF candle
//------------------------------------------------------------------------------
f_htfBias() =>
    float c = close[1]
    float fast = ta.ema(close, htfFastLength)[1]
    float slow = ta.ema(close, htfSlowLength)[1]
    int bias = c > fast and fast > slow ? 1 : c < fast and fast < slow ? -1 : 0
    [c, fast, slow, bias]

[h1Close, h1Fast, h1Slow, h1Bias] = request.security(syminfo.tickerid, htf1, f_htfBias(), lookahead = barmerge.lookahead_on)
[h2Close, h2Fast, h2Slow, h2Bias] = request.security(syminfo.tickerid, htf2, f_htfBias(), lookahead = barmerge.lookahead_on)
[h3Close, h3Fast, h3Slow, h3Bias] = request.security(syminfo.tickerid, htf3, f_htfBias(), lookahead = barmerge.lookahead_on)
[h4Close, h4Fast, h4Slow, h4Bias] = request.security(syminfo.tickerid, htf4, f_htfBias(), lookahead = barmerge.lookahead_on)

int htfBullCount = (h1Bias == 1 ? 1 : 0) + (h2Bias == 1 ? 1 : 0) + (h3Bias == 1 ? 1 : 0) + (h4Bias == 1 ? 1 : 0)
int htfBearCount = (h1Bias == -1 ? 1 : 0) + (h2Bias == -1 ? 1 : 0) + (h3Bias == -1 ? 1 : 0) + (h4Bias == -1 ? 1 : 0)

//------------------------------------------------------------------------------
// Confirmed VIX context and live benchmark context
//------------------------------------------------------------------------------
f_vixContext() =>
    float c = close[1]
    float e = ta.ema(close, vixEmaLength)[1]
    float d = close[1] - close[1 + vixSlopeBars]
    [c, e, d]

[vixClose, vixEma, vixDelta] = request.security(
     vixSymbol, vixTimeframe, f_vixContext(),
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)

bool vixAvailable = not na(vixClose) and not na(vixEma) and not na(vixDelta)
bool vixLongOk = not vixAvailable or (vixClose < vixEma and vixDelta <= 0)
bool vixShortOk = not vixAvailable or (vixClose > vixEma and vixDelta >= 0)

[benchClose, benchFast, benchSlow, benchVwap] = request.security(
     benchmarkSymbol, timeframe.period,
     [close, ta.ema(close, fastEmaLength), ta.ema(close, slowEmaLength), ta.vwap(hlc3)],
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

bool benchAvailable = not na(benchClose) and not na(benchFast) and not na(benchSlow) and not na(benchVwap)
bool benchLongOk = not benchAvailable or (benchClose > benchVwap and benchFast > benchSlow)
bool benchShortOk = not benchAvailable or (benchClose < benchVwap and benchFast < benchSlow)

//------------------------------------------------------------------------------
// Confirmed and session liquidity levels
//------------------------------------------------------------------------------
[pdh, pdl, prevClose] = request.security(syminfo.tickerid, "1D", [high[1], low[1], close[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl] = request.security(syminfo.tickerid, "1W", [high[1], low[1]], lookahead = barmerge.lookahead_on)
[pmh, pml] = request.security(syminfo.tickerid, "1M", [high[1], low[1]], lookahead = barmerge.lookahead_on)

var float monthHighLive = na
var float monthLowLive = na
var float priorMtdHigh = na
var float priorMtdLow = na

if newMonth
    monthHighLive := na
    monthLowLive := na
    priorMtdHigh := na
    priorMtdLow := na
else if newDay
    priorMtdHigh := monthHighLive
    priorMtdLow := monthLowLive

if inRth
    monthHighLive := na(monthHighLive) ? high : math.max(monthHighLive, high)
    monthLowLive := na(monthLowLive) ? low : math.min(monthLowLive, low)

var float rthOpen = na
if newDay
    rthOpen := na
if rthStart
    rthOpen := open

f_premarketRange() =>
    var float pmHighLocal = na
    var float pmLowLocal = na
    bool localNewDay = timeframe.change("D")
    bool inPm = not na(time(timeframe.period, premarketSession + weekdays))
    if localNewDay
        pmHighLocal := na
        pmLowLocal := na
    if inPm
        pmHighLocal := na(pmHighLocal) ? high : math.max(pmHighLocal, high)
        pmLowLocal := na(pmLowLocal) ? low : math.min(pmLowLocal, low)
    [pmHighLocal, pmLowLocal]

string extendedTicker = ticker.modify(syminfo.tickerid, session.extended)
[premarketHigh, premarketLow] = request.security(
     extendedTicker, timeframe.period, f_premarketRange(),
     gaps = barmerge.gaps_off, lookahead = barmerge.lookahead_off, ignore_invalid_symbol = true)

//------------------------------------------------------------------------------
// ORB state and drawings
//------------------------------------------------------------------------------
var float orbHigh = na
var float orbLow = na
var bool orbReady = false
var int orbStartBar = na
var int signalsToday = 0

var line orbHighLine = na
var line orbLowLine = na
var line orbMidLine = na
var array<line> keyLines = array.new_line()
var array<label> keyLabels = array.new_label()
var array<float> keyPrices = array.new_float()

if newDay
    orbHigh := na
    orbLow := na
    orbReady := false
    orbStartBar := na
    signalsToday := 0

    if not na(orbHighLine)
        line.delete(orbHighLine)
        orbHighLine := na
    if not na(orbLowLine)
        line.delete(orbLowLine)
        orbLowLine := na
    if not na(orbMidLine)
        line.delete(orbMidLine)
        orbMidLine := na

    if array.size(keyLines) > 0
        for i = 0 to array.size(keyLines) - 1
            line ln = array.get(keyLines, i)
            if not na(ln)
                line.delete(ln)
        array.clear(keyLines)
    if array.size(keyLabels) > 0
        for i = 0 to array.size(keyLabels) - 1
            label lb = array.get(keyLabels, i)
            if not na(lb)
                label.delete(lb)
        array.clear(keyLabels)
    array.clear(keyPrices)

if orbStart
    orbStartBar := bar_index
    orbHigh := high
    orbLow := low
    orbReady := false

    orbHighLine := line.new(orbStartBar, orbHigh, bar_index, orbHigh, xloc = xloc.bar_index, extend = extend.none, color = orbHighColor, width = 2)
    orbLowLine := line.new(orbStartBar, orbLow, bar_index, orbLow, xloc = xloc.bar_index, extend = extend.none, color = orbLowColor, width = 2)
    if showOrbMid
        orbMidLine := line.new(orbStartBar, (orbHigh + orbLow) / 2.0, bar_index, (orbHigh + orbLow) / 2.0,
             xloc = xloc.bar_index, extend = extend.none, color = orbMidColor, width = 1, style = line.style_dashed)
else if inOrb
    orbHigh := math.max(nz(orbHigh, high), high)
    orbLow := math.min(nz(orbLow, low), low)
    float buildingMid = (orbHigh + orbLow) / 2.0

    if not na(orbHighLine)
        line.set_xy1(orbHighLine, orbStartBar, orbHigh)
        line.set_xy2(orbHighLine, bar_index, orbHigh)
    if not na(orbLowLine)
        line.set_xy1(orbLowLine, orbStartBar, orbLow)
        line.set_xy2(orbLowLine, bar_index, orbLow)
    if showOrbMid
        if na(orbMidLine)
            orbMidLine := line.new(orbStartBar, buildingMid, bar_index, buildingMid, xloc = xloc.bar_index,
                 extend = extend.none, color = orbMidColor, width = 1, style = line.style_dashed)
        else
            line.set_xy1(orbMidLine, orbStartBar, buildingMid)
            line.set_xy2(orbMidLine, bar_index, buildingMid)

f_drawKeyLevel(array<line> lines, array<label> labels, array<float> prices, float price, string name, color clr, string lnStyle) =>
    bool duplicate = false
    float mergeDistance = math.max(syminfo.mintick * mergeLevelTicks, nz(atr, 0.0) * mergeLevelAtr)
    if not na(price) and array.size(prices) > 0
        for i = 0 to array.size(prices) - 1
            if math.abs(price - array.get(prices, i)) <= mergeDistance
                duplicate := true
    if not duplicate and not na(price) and not na(orbStartBar)
        line ln = line.new(orbStartBar, price, bar_index, price, xloc = xloc.bar_index, extend = extend.right, color = clr, width = 1, style = lnStyle)
        array.push(lines, ln)
        array.push(prices, price)
        if showLevelLabels
            label lb = label.new(bar_index + levelLabelOffset, price, name + "  " + str.tostring(price, format.mintick),
                 xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.black, 82), textcolor = color.new(clr, 0), size = size.tiny)
            array.push(labels, lb)

if orbEnd and not na(orbHigh) and not na(orbLow)
    orbReady := true
    float fixedMid = (orbHigh + orbLow) / 2.0

    if not na(orbHighLine)
        line.set_xy2(orbHighLine, bar_index, orbHigh)
        line.set_extend(orbHighLine, extend.right)
    if not na(orbLowLine)
        line.set_xy2(orbLowLine, bar_index, orbLow)
        line.set_extend(orbLowLine, extend.right)
    if showOrbMid and not na(orbMidLine)
        line.set_xy1(orbMidLine, orbStartBar, fixedMid)
        line.set_xy2(orbMidLine, bar_index, fixedMid)
        line.set_extend(orbMidLine, extend.right)

    if showKeyLevels
        if useDayLevels
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, pdh, "PDH", color.new(color.yellow, 45), line.style_solid)
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, pdl, "PDL", color.new(color.yellow, 45), line.style_solid)
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, prevClose, "PDC", color.new(color.yellow, 68), line.style_dotted)
        if useWeekLevels
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, pwh, "PWH", color.new(color.orange, 55), line.style_solid)
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, pwl, "PWL", color.new(color.orange, 55), line.style_solid)
        if useMonthLevels
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, pmh, "PMH", color.new(color.purple, 55), line.style_solid)
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, pml, "PML", color.new(color.purple, 55), line.style_solid)
        if usePriorMtdLevels
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, priorMtdHigh, "MTD H", color.new(color.fuchsia, 70), line.style_dashed)
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, priorMtdLow, "MTD L", color.new(color.fuchsia, 70), line.style_dashed)
        if usePremarketLevels
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, premarketHigh, "PM HIGH", color.new(color.aqua, 55), line.style_dashed)
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, premarketLow, "PM LOW", color.new(color.aqua, 55), line.style_dashed)
        if useRthOpen
            f_drawKeyLevel(keyLines, keyLabels, keyPrices, rthOpen, "RTH OPEN", color.new(color.white, 68), line.style_dotted)

if barstate.islast and array.size(keyLabels) > 0
    for i = 0 to array.size(keyLabels) - 1
        label lb = array.get(keyLabels, i)
        if not na(lb)
            label.set_x(lb, bar_index + levelLabelOffset)

float orbMid = not na(orbHigh) and not na(orbLow) ? (orbHigh + orbLow) / 2.0 : na
float orbRange = not na(orbHigh) and not na(orbLow) ? orbHigh - orbLow : na
float orbWidthAtr5 = not na(orbRange) and not na(atr5) and atr5 > 0 ? orbRange / atr5 : na
float breakBuffer = syminfo.mintick * breakBufferTicks

//------------------------------------------------------------------------------
// Weighted quant score
//------------------------------------------------------------------------------
bool directionalLong = close > open
bool directionalShort = close < open
bool strongLong = directionalLong and bodyPct >= minBodyPct and longCloseLoc >= minCloseLocPct
bool strongShort = directionalShort and bodyPct >= minBodyPct and shortCloseLoc >= minCloseLocPct
bool displacementOk = atr > 0 and barRange / atr >= minRangeAtr
bool rvolOk = na(rvol) or rvol >= minimumRvol
bool longVwapPriceOk = close > vwapValue
bool shortVwapPriceOk = close < vwapValue
bool longVwapOk = longVwapPriceOk and (not requireVwapSlope or vwapValue >= vwapValue[1])
bool shortVwapOk = shortVwapPriceOk and (not requireVwapSlope or vwapValue <= vwapValue[1])
bool longEmaOk = close > emaFast and emaFast > emaSlow
bool shortEmaOk = close < emaFast and emaFast < emaSlow
bool longExtensionOk = orbReady and atr > 0 and close - orbHigh <= atr * maxExtensionAtr
bool shortExtensionOk = orbReady and atr > 0 and orbLow - close <= atr * maxExtensionAtr
bool orbWidthHealthy = na(orbWidthAtr5) or (orbWidthAtr5 >= minOrbWidthAtr5 and orbWidthAtr5 <= maxOrbWidthAtr5)

float candleWeight = 20.0
float displacementWeight = 10.0
float rvolWeight = 10.0
float vwapWeight = 15.0
float emaWeight = 10.0
float orbWeight = 5.0
float htfWeight = scoreHtf ? 15.0 : 0.0
float vixWeight = scoreVix ? 7.5 : 0.0
float benchWeight = scoreBenchmark ? 7.5 : 0.0
float maximumWeight = candleWeight + displacementWeight + rvolWeight + vwapWeight + emaWeight + orbWeight + htfWeight + vixWeight + benchWeight

float longCandleComponent = directionalLong ?
     f_clamp(bodyPct / math.max(minBodyPct, 1.0), 0.0, 1.0) * 10.0 +
     f_clamp(longCloseLoc / math.max(minCloseLocPct, 1.0), 0.0, 1.0) * 10.0 : 0.0
float shortCandleComponent = directionalShort ?
     f_clamp(bodyPct / math.max(minBodyPct, 1.0), 0.0, 1.0) * 10.0 +
     f_clamp(shortCloseLoc / math.max(minCloseLocPct, 1.0), 0.0, 1.0) * 10.0 : 0.0
float displacementComponent = atr > 0 ? f_clamp((barRange / atr) / math.max(minRangeAtr, 0.01), 0.0, 1.0) * displacementWeight : 0.0
float rvolComponent = na(rvol) ? rvolWeight * 0.5 : f_clamp(rvol / math.max(minimumRvol, 0.01), 0.0, 1.0) * rvolWeight
float longVwapComponent = longVwapOk ? vwapWeight : 0.0
float shortVwapComponent = shortVwapOk ? vwapWeight : 0.0
float longEmaComponent = longEmaOk ? emaWeight : 0.0
float shortEmaComponent = shortEmaOk ? emaWeight : 0.0
float orbComponent = orbWidthHealthy ? orbWeight : 0.0
float longHtfComponent = scoreHtf ? htfWeight * htfBullCount / 4.0 : 0.0
float shortHtfComponent = scoreHtf ? htfWeight * htfBearCount / 4.0 : 0.0
float longVixComponent = scoreVix ? (vixAvailable ? (vixLongOk ? vixWeight : 0.0) : vixWeight * 0.5) : 0.0
float shortVixComponent = scoreVix ? (vixAvailable ? (vixShortOk ? vixWeight : 0.0) : vixWeight * 0.5) : 0.0
float longBenchComponent = scoreBenchmark ? (benchAvailable ? (benchLongOk ? benchWeight : 0.0) : benchWeight * 0.5) : 0.0
float shortBenchComponent = scoreBenchmark ? (benchAvailable ? (benchShortOk ? benchWeight : 0.0) : benchWeight * 0.5) : 0.0

float longScoreRaw = longCandleComponent + displacementComponent + rvolComponent + longVwapComponent + longEmaComponent + orbComponent + longHtfComponent + longVixComponent + longBenchComponent
float shortScoreRaw = shortCandleComponent + displacementComponent + rvolComponent + shortVwapComponent + shortEmaComponent + orbComponent + shortHtfComponent + shortVixComponent + shortBenchComponent
float longScorePct = maximumWeight > 0 ? longScoreRaw / maximumWeight * 100.0 : 100.0
float shortScorePct = maximumWeight > 0 ? shortScoreRaw / maximumWeight * 100.0 : 100.0

bool freshLongBreak = not freshBreakOnly or close[1] <= orbHigh + breakBuffer
bool freshShortBreak = not freshBreakOnly or close[1] >= orbLow - breakBuffer
bool rawLongBreak = validTf and barstate.isconfirmed and orbReady and inEntry and close > orbHigh + breakBuffer and freshLongBreak
bool rawShortBreak = validTf and barstate.isconfirmed and orbReady and inEntry and close < orbLow - breakBuffer and freshShortBreak

bool longCorePass = strongLong and displacementOk and longExtensionOk and (not requireVwap or longVwapOk)
bool shortCorePass = strongShort and displacementOk and shortExtensionOk and (not requireVwap or shortVwapOk)
bool longBreakQualified = rawLongBreak and allowLongs and longCorePass and longScorePct >= minimumScorePct
bool shortBreakQualified = rawShortBreak and allowShorts and shortCorePass and shortScorePct >= minimumScorePct

//------------------------------------------------------------------------------
// Optional retest state
//------------------------------------------------------------------------------
var int armedDirection = 0
var int armedBar = na
var float armedScorePct = na
var float armedBreakOpen = na

if newDay
    armedDirection := 0
    armedBar := na
    armedScorePct := na
    armedBreakOpen := na

bool longSignal = false
bool shortSignal = false
float selectedSignalScore = na
float selectedBreakOpen = na

if signalsToday < maxSignalsDay
    if entryMode == "Confirmed breakout"
        longSignal := longBreakQualified
        shortSignal := shortBreakQualified
        if longSignal or shortSignal
            selectedSignalScore := longSignal ? longScorePct : shortScorePct
            selectedBreakOpen := open
    else
        if armedDirection == 0
            if longBreakQualified
                armedDirection := 1
                armedBar := bar_index
                armedScorePct := longScorePct
                armedBreakOpen := open
            else if shortBreakQualified
                armedDirection := -1
                armedBar := bar_index
                armedScorePct := shortScorePct
                armedBreakOpen := open

        if armedDirection != 0 and not na(armedBar)
            int barsArmed = bar_index - armedBar
            bool expired = barsArmed > retestBars or not inEntry
            bool longFailed = armedDirection == 1 and close < orbHigh - atr * retestTolAtr
            bool shortFailed = armedDirection == -1 and close > orbLow + atr * retestTolAtr

            if expired or longFailed or shortFailed
                armedDirection := 0
                armedBar := na
                armedScorePct := na
                armedBreakOpen := na
            else if barsArmed >= 1
                bool longTouch = armedDirection == 1 and low <= orbHigh + atr * retestTolAtr and high >= orbHigh
                bool shortTouch = armedDirection == -1 and high >= orbLow - atr * retestTolAtr and low <= orbLow
                bool longReject = close > orbHigh and close > open and longCloseLoc >= 55
                bool shortReject = close < orbLow and close < open and shortCloseLoc >= 55
                longSignal := longTouch and longReject and (not requireVwap or close > vwapValue)
                shortSignal := shortTouch and shortReject and (not requireVwap or close < vwapValue)
                if longSignal or shortSignal
                    selectedSignalScore := nz(armedScorePct, longSignal ? longScorePct : shortScorePct)
                    selectedBreakOpen := armedBreakOpen

if longSignal or shortSignal
    signalsToday += 1
    armedDirection := 0
    armedBar := na
    armedScorePct := na
    armedBreakOpen := na

//------------------------------------------------------------------------------
// Liquidity checkpoint engine: TP2 remains exact 2R; liquidity becomes TP1/context
//------------------------------------------------------------------------------
f_liquidityCheckpoint(int direction, float entryPrice, float riskUnit, float mainTargetPrice) =>
    array<float> prices = array.new_float()
    array<string> names = array.new_string()

    f_addLiquidity(prices, names, useDayLevels, pdh, "PDH")
    f_addLiquidity(prices, names, useDayLevels, pdl, "PDL")
    f_addLiquidity(prices, names, useDayLevels, prevClose, "PDC")
    f_addLiquidity(prices, names, useWeekLevels, pwh, "PWH")
    f_addLiquidity(prices, names, useWeekLevels, pwl, "PWL")
    f_addLiquidity(prices, names, useMonthLevels, pmh, "PMH")
    f_addLiquidity(prices, names, useMonthLevels, pml, "PML")
    f_addLiquidity(prices, names, usePriorMtdLevels, priorMtdHigh, "MTD H")
    f_addLiquidity(prices, names, usePriorMtdLevels, priorMtdLow, "MTD L")
    f_addLiquidity(prices, names, usePremarketLevels, premarketHigh, "PM HIGH")
    f_addLiquidity(prices, names, usePremarketLevels, premarketLow, "PM LOW")
    f_addLiquidity(prices, names, useRthOpen, rthOpen, "RTH OPEN")

    array<int> orderIndex = direction == 1 ? array.sort_indices(prices, order.ascending) : array.sort_indices(prices, order.descending)
    float checkpoint = na
    string checkpointName = ""
    float nearest = na
    string nearestName = ""
    float minDistance = math.max(riskUnit, syminfo.mintick) * minimumCheckpointR

    if array.size(orderIndex) > 0
        for i = 0 to array.size(orderIndex) - 1
            int idx = array.get(orderIndex, i)
            float levelPrice = array.get(prices, idx)
            string levelName = array.get(names, idx)
            float distance = direction == 1 ? levelPrice - entryPrice : entryPrice - levelPrice
            bool ahead = distance > 0
            if ahead and na(nearest)
                nearest := levelPrice
                nearestName := levelName
            bool beforeMainTarget = direction == 1 ? levelPrice < mainTargetPrice : levelPrice > mainTargetPrice
            if ahead and distance >= minDistance and beforeMainTarget and na(checkpoint)
                checkpoint := levelPrice
                checkpointName := levelName

    float fallback = direction == 1 ? entryPrice + riskUnit * fallbackCheckpointR : entryPrice - riskUnit * fallbackCheckpointR
    if na(checkpoint)
        checkpoint := fallback
        checkpointName := str.tostring(fallbackCheckpointR, "#.##") + "R"

    [checkpoint, checkpointName, nearest, nearestName]

//------------------------------------------------------------------------------
// Active trade drawings and alert tracking
//------------------------------------------------------------------------------
var int activeDirection = 0
var int activeEntryBar = na
var float activeEntry = na
var float activeStop = na
var float activeRisk = na
var float activeTp1 = na
var float activeTp2 = na
var float activeNearestLiquidity = na
var string activeTp1Name = ""
var string activeNearestLiquidityName = ""
var bool tp1Hit = false

var box riskBox = na
var box rewardBox = na
var box entryCandleBox = na
var line entryLine = na
var line stopLine = na
var line tp1Line = na
var line tp2Line = na
var line entryMarkerLine = na
var label entryMarkerLabel = na
var label setupLabel = na
var label stopTag = na
var label tpTag = na

f_deleteTradeDrawings(box rb, box wb, box eb, line el, line sl, line t1l, line t2l, line eml, label emlb, label setup, label slTag, label targetTag) =>
    if not na(rb)
        box.delete(rb)
    if not na(wb)
        box.delete(wb)
    if not na(eb)
        box.delete(eb)
    if not na(el)
        line.delete(el)
    if not na(sl)
        line.delete(sl)
    if not na(t1l)
        line.delete(t1l)
    if not na(t2l)
        line.delete(t2l)
    if not na(eml)
        line.delete(eml)
    if not na(emlb)
        label.delete(emlb)
    if not na(setup)
        label.delete(setup)
    if not na(slTag)
        label.delete(slTag)
    if not na(targetTag)
        label.delete(targetTag)

if newDay
    activeDirection := 0
    activeEntryBar := na
    activeEntry := na
    activeStop := na
    activeRisk := na
    activeTp1 := na
    activeTp2 := na
    activeNearestLiquidity := na
    activeTp1Name := ""
    activeNearestLiquidityName := ""
    tp1Hit := false
    f_deleteTradeDrawings(riskBox, rewardBox, entryCandleBox, entryLine, stopLine, tp1Line, tp2Line, entryMarkerLine, entryMarkerLabel, setupLabel, stopTag, tpTag)
    riskBox := na
    rewardBox := na
    entryCandleBox := na
    entryLine := na
    stopLine := na
    tp1Line := na
    tp2Line := na
    entryMarkerLine := na
    entryMarkerLabel := na
    setupLabel := na
    stopTag := na
    tpTag := na

if (longSignal or shortSignal) and activeDirection == 0
    int direction = longSignal ? 1 : -1
    float entryPrice = close
    float tickBuffer = syminfo.mintick * stopBufferTicks
    float minimumReclaimDepth = nz(orbRange, 0.0) * reclaimDepthPct / 100.0
    float maximumReclaimDepth = nz(orbRange, 0.0) * math.max(maxStopDepthPct, reclaimDepthPct) / 100.0
    float breakOrigin = nz(selectedBreakOpen, open)

    float longReclaim = orbHigh - minimumReclaimDepth - tickBuffer
    float shortReclaim = orbLow + minimumReclaimDepth + tickBuffer
    float longMaxDeep = orbHigh - maximumReclaimDepth - tickBuffer
    float shortMaxDeep = orbLow + maximumReclaimDepth + tickBuffer
    float longOriginStop = breakOrigin - tickBuffer
    float shortOriginStop = breakOrigin + tickBuffer

    float stopPrice = na
    if direction == 1
        stopPrice := switch stopMode
            "Break origin + ORB reclaim" => math.max(math.min(longOriginStop, longReclaim), longMaxDeep)
            "ORB reclaim only" => longReclaim
            "Breakout candle" => low - tickBuffer
            "ORB midpoint" => orbMid - tickBuffer
            "Opposite ORB" => orbLow - tickBuffer
            => entryPrice - atr * atrStopMult
    else
        stopPrice := switch stopMode
            "Break origin + ORB reclaim" => math.min(math.max(shortOriginStop, shortReclaim), shortMaxDeep)
            "ORB reclaim only" => shortReclaim
            "Breakout candle" => high + tickBuffer
            "ORB midpoint" => orbMid + tickBuffer
            "Opposite ORB" => orbHigh + tickBuffer
            => entryPrice + atr * atrStopMult

    if direction == 1 and (na(stopPrice) or stopPrice >= entryPrice)
        stopPrice := math.min(longReclaim, entryPrice - syminfo.mintick * 2)
    if direction == -1 and (na(stopPrice) or stopPrice <= entryPrice)
        stopPrice := math.max(shortReclaim, entryPrice + syminfo.mintick * 2)

    float riskUnit = math.abs(entryPrice - stopPrice)
    if riskUnit < syminfo.mintick * 2
        stopPrice := direction == 1 ? entryPrice - syminfo.mintick * 2 : entryPrice + syminfo.mintick * 2
        riskUnit := math.abs(entryPrice - stopPrice)

    float target2 = direction == 1 ? entryPrice + riskUnit * mainTargetR : entryPrice - riskUnit * mainTargetR
    [target1, target1Name, nearestLiquidity, nearestLiquidityName] = f_liquidityCheckpoint(direction, entryPrice, riskUnit, target2)

    if direction == 1 and target1 >= target2
        target1 := entryPrice + riskUnit * fallbackCheckpointR
        target1Name := str.tostring(fallbackCheckpointR, "#.##") + "R"
    if direction == -1 and target1 <= target2
        target1 := entryPrice - riskUnit * fallbackCheckpointR
        target1Name := str.tostring(fallbackCheckpointR, "#.##") + "R"

    activeDirection := direction
    activeEntryBar := bar_index
    activeEntry := entryPrice
    activeStop := stopPrice
    activeRisk := riskUnit
    activeTp1 := target1
    activeTp2 := target2
    activeNearestLiquidity := nearestLiquidity
    activeTp1Name := target1Name
    activeNearestLiquidityName := nearestLiquidityName
    tp1Hit := false

    f_deleteTradeDrawings(riskBox, rewardBox, entryCandleBox, entryLine, stopLine, tp1Line, tp2Line, entryMarkerLine, entryMarkerLabel, setupLabel, stopTag, tpTag)

    int leftBoxBar = bar_index + 1
    int rightBar = bar_index + tradeBoxBars
    float riskTop = math.max(activeEntry, activeStop)
    float riskBottom = math.min(activeEntry, activeStop)
    float rewardTop = math.max(activeEntry, activeTp2)
    float rewardBottom = math.min(activeEntry, activeTp2)
    color sideColor = direction == 1 ? color.lime : color.red

    if showTradeZones
        riskBox := box.new(leftBoxBar, riskTop, rightBar, riskBottom, xloc = xloc.bar_index,
             border_color = color.new(color.red, 82), bgcolor = riskColor)
        rewardBox := box.new(leftBoxBar, rewardTop, rightBar, rewardBottom, xloc = xloc.bar_index,
             border_color = color.new(color.green, 82), bgcolor = rewardColor)

    // Begin every trade level after the signal candle so the entry bar stays unobstructed.
    entryLine := line.new(leftBoxBar, activeEntry, rightBar, activeEntry, xloc = xloc.bar_index,
         color = color.new(color.yellow, 45), width = 1, style = line.style_dotted)
    stopLine := line.new(leftBoxBar, activeStop, rightBar, activeStop, xloc = xloc.bar_index,
         color = color.new(color.red, 10), width = 1)
    tp1Line := line.new(leftBoxBar, activeTp1, rightBar, activeTp1, xloc = xloc.bar_index,
         color = color.new(color.green, 45), width = 1, style = line.style_dashed)
    tp2Line := line.new(leftBoxBar, activeTp2, rightBar, activeTp2, xloc = xloc.bar_index,
         color = color.new(color.green, 10), width = 1)

    float signalScore = nz(selectedSignalScore, direction == 1 ? longScorePct : shortScorePct)
    string sideText = direction == 1 ? "LONG" : "SHORT"
    string gradeText = f_grade(signalScore)

    if showEntryMarker
        // One small exact-candle tag. No vertical marker and no candle overlay.
        entryMarkerLabel := label.new(bar_index, direction == 1 ? low : high,
             sideText + " " + gradeText + "\n" + str.tostring(activeEntry, format.mintick),
             xloc = xloc.bar_index,
             yloc = direction == 1 ? yloc.belowbar : yloc.abovebar,
             style = direction == 1 ? label.style_label_up : label.style_label_down,
             color = color.new(sideColor, 12), textcolor = direction == 1 ? color.black : color.white, size = size.tiny)
    string nearestText = not na(activeNearestLiquidity) ? activeNearestLiquidityName + " " + str.tostring(activeNearestLiquidity, format.mintick) : "none ahead"

    if showSetupLabel
        string details = gradeText + " " + str.tostring(signalScore, "#") + "%" +
             " | SL " + str.tostring(activeStop, format.mintick) +
             " | TP1 " + activeTp1Name + " " + str.tostring(activeTp1, format.mintick) +
             " | TP2 " + str.tostring(activeTp2, format.mintick)
        setupLabel := label.new(rightBar + 1, activeEntry, details,
             xloc = xloc.bar_index, style = label.style_label_left,
             color = color.new(color.black, 78), textcolor = color.white, size = size.tiny)

    stopTag := label.new(rightBar + 1, activeStop, "SL " + str.tostring(activeStop, format.mintick),
         xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.red, 35), textcolor = color.white, size = size.tiny)
    tpTag := label.new(rightBar + 1, activeTp2, "TP2 " + str.tostring(activeTp2, format.mintick),
         xloc = xloc.bar_index, style = label.style_label_left, color = color.new(color.green, 35), textcolor = color.white, size = size.tiny)

    if alertOnEntry
        alert("ABQ ORB " + sideText + " | " + syminfo.ticker +
             " | grade " + gradeText + " " + str.tostring(signalScore, "#") + "%" +
             " | entry " + str.tostring(activeEntry, format.mintick) +
             " | stop " + str.tostring(activeStop, format.mintick) +
             " | TP1 " + activeTp1Name + " " + str.tostring(activeTp1, format.mintick) +
             " | TP2 " + str.tostring(mainTargetR, "#.##") + "R " + str.tostring(activeTp2, format.mintick) +
             " | next liquidity " + nearestText, alert.freq_once_per_bar_close)

if activeDirection != 0 and not na(activeEntryBar) and bar_index > activeEntryBar
    bool stopTouched = activeDirection == 1 ? low <= activeStop : high >= activeStop
    bool tp1Touched = activeDirection == 1 ? high >= activeTp1 : low <= activeTp1
    bool tp2Touched = activeDirection == 1 ? high >= activeTp2 : low <= activeTp2

    // Conservative same-bar assumption: stop is evaluated before targets.
    if stopTouched
        if alertOnStop
            alert("ABQ ORB STOP | " + syminfo.ticker + " @ " + str.tostring(activeStop, format.mintick), alert.freq_once_per_bar_close)
        activeDirection := 0
    else
        if tp1Touched and not tp1Hit
            tp1Hit := true
            if moveStopToBE
                activeStop := activeEntry
                if not na(stopLine)
                    line.set_y1(stopLine, activeStop)
                    line.set_y2(stopLine, activeStop)
                if not na(stopTag)
                    label.set_y(stopTag, activeStop)
                    label.set_text(stopTag, "SL BE  " + str.tostring(activeStop, format.mintick))
            if alertOnTp
                alert("ABQ ORB TP1 | " + syminfo.ticker + " | " + activeTp1Name + " @ " + str.tostring(activeTp1, format.mintick), alert.freq_once_per_bar_close)

        if tp2Touched
            if alertOnTp
                alert("ABQ ORB TP2 | " + syminfo.ticker + " | " + str.tostring(mainTargetR, "#.##") + "R @ " + str.tostring(activeTp2, format.mintick), alert.freq_once_per_bar_close)
            activeDirection := 0

//------------------------------------------------------------------------------
// Clean chart outputs: three plot counts only
//------------------------------------------------------------------------------
plot(showAverages ? emaFast : na, "EMA 9", color = color.new(color.red, 0), linewidth = 1)
plot(showAverages ? emaSlow : na, "EMA 20", color = color.new(color.orange, 0), linewidth = 1)
plot(showAverages ? vwapValue : na, "Session VWAP", color = color.new(color.fuchsia, 0), linewidth = 2)

if showBreakMarkers and longBreakQualified and entryMode == "Breakout + retest"
    label.new(bar_index, low, "LONG ARMED", yloc = yloc.belowbar, style = label.style_label_up, color = color.new(color.lime, 20), textcolor = color.black, size = size.tiny)
if showBreakMarkers and shortBreakQualified and entryMode == "Breakout + retest"
    label.new(bar_index, high, "SHORT ARMED", yloc = yloc.abovebar, style = label.style_label_down, color = color.new(color.red, 20), textcolor = color.white, size = size.tiny)

//------------------------------------------------------------------------------
// Mini quant checklist — visible by default, three columns, transparent cells
//------------------------------------------------------------------------------
f_check(bool value) => value ? "✓" : "·"
f_checkColor(bool value) => value ? color.lime : color.new(color.white, 55)
f_scoreColor(float value) => value >= minimumScorePct ? color.lime : value >= minimumScorePct - 10 ? color.orange : color.new(color.white, 45)

var table dash = table.new(position.top_right, 3, 7, border_width = 0)

if barstate.islast
    if showDashboard
        string stateText = not validTf ? "USE 1–5m" : not orbReady ? "BUILDING" : activeDirection == 1 ? "LONG LIVE" : activeDirection == -1 ? "SHORT LIVE" : armedDirection == 1 ? "L ARMED" : armedDirection == -1 ? "S ARMED" : "SCANNING"
        color headBg = color.new(color.rgb(43, 30, 105), 28)
        color cellBg = color.new(color.black, 76)
        color labelColor = color.new(color.white, 18)

        table.cell(dash, 0, 0, "ABQ ORB", bgcolor = headBg, text_color = color.white, text_size = size.tiny)
        table.cell(dash, 1, 0, "L " + str.tostring(longScorePct, "#") + "%", bgcolor = headBg, text_color = f_scoreColor(longScorePct), text_size = size.tiny)
        table.cell(dash, 2, 0, "S " + str.tostring(shortScorePct, "#") + "%", bgcolor = headBg, text_color = f_scoreColor(shortScorePct), text_size = size.tiny)

        table.cell(dash, 0, 1, "STATE", bgcolor = cellBg, text_color = labelColor, text_size = size.tiny)
        table.cell(dash, 1, 1, stateText, bgcolor = cellBg, text_color = color.white, text_size = size.tiny)
        table.cell(dash, 2, 1, str.tostring(signalsToday) + "/" + str.tostring(maxSignalsDay), bgcolor = cellBg, text_color = color.white, text_size = size.tiny)

        table.cell(dash, 0, 2, "BREAK", bgcolor = cellBg, text_color = labelColor, text_size = size.tiny)
        table.cell(dash, 1, 2, longBreakQualified ? "READY" : "WAIT", bgcolor = cellBg, text_color = f_checkColor(longBreakQualified), text_size = size.tiny)
        table.cell(dash, 2, 2, shortBreakQualified ? "READY" : "WAIT", bgcolor = cellBg, text_color = f_checkColor(shortBreakQualified), text_size = size.tiny)

        table.cell(dash, 0, 3, "VWAP•EMA", bgcolor = cellBg, text_color = labelColor, text_size = size.tiny)
        table.cell(dash, 1, 3, f_check(longVwapOk) + " • " + f_check(longEmaOk), bgcolor = cellBg, text_color = f_checkColor(longVwapOk and longEmaOk), text_size = size.tiny)
        table.cell(dash, 2, 3, f_check(shortVwapOk) + " • " + f_check(shortEmaOk), bgcolor = cellBg, text_color = f_checkColor(shortVwapOk and shortEmaOk), text_size = size.tiny)

        table.cell(dash, 0, 4, "RVOL•ORB", bgcolor = cellBg, text_color = labelColor, text_size = size.tiny)
        table.cell(dash, 1, 4, (na(rvol) ? "n/a" : str.tostring(rvol, "#.##") + "x"), bgcolor = cellBg, text_color = f_checkColor(rvolOk), text_size = size.tiny)
        table.cell(dash, 2, 4, (na(orbWidthAtr5) ? "n/a" : str.tostring(orbWidthAtr5, "#.##") + "A"), bgcolor = cellBg, text_color = f_checkColor(orbWidthHealthy), text_size = size.tiny)

        table.cell(dash, 0, 5, "HTF", bgcolor = cellBg, text_color = labelColor, text_size = size.tiny)
        table.cell(dash, 1, 5, str.tostring(htfBullCount) + "/4 B", bgcolor = cellBg, text_color = f_checkColor(htfBullCount >= 2), text_size = size.tiny)
        table.cell(dash, 2, 5, str.tostring(htfBearCount) + "/4 S", bgcolor = cellBg, text_color = f_checkColor(htfBearCount >= 2), text_size = size.tiny)

        table.cell(dash, 0, 6, "VIX•QQQ", bgcolor = cellBg, text_color = labelColor, text_size = size.tiny)
        table.cell(dash, 1, 6, f_check(vixLongOk) + " • " + f_check(benchLongOk), bgcolor = cellBg, text_color = f_checkColor(vixLongOk and benchLongOk), text_size = size.tiny)
        table.cell(dash, 2, 6, f_check(vixShortOk) + " • " + f_check(benchShortOk), bgcolor = cellBg, text_color = f_checkColor(vixShortOk and benchShortOk), text_size = size.tiny)
    else
        table.clear(dash, 0, 0, 2, 6)
````
