# RSI Div BROWNIETHERABBIT

- url: https://www.tradingview.com/script/CQbfAOxk-RSI-Div-BROWNIETHERABBIT/
- type: indicator
- pine_id: PUB;2411e1515a9c496bb74b5e2447769ead
- version: 1.0

## Description

The script is published and visible — that means it can be loaded by name. Remove Volume + RSI and add just the RSI Divergence Indicator:Edited a fileEdited a fileDone. Refresh the page — the chart will now load with only RSI Divergence Indicator in the lower panel, no Volume or standard RSI.
If the indicator doesn't auto-load (TradingView is sometimes strict about script name matching), the exact name needs to match what appears in the search. From your screenshot it shows RSI Divergence Indicator — if it still doesn't load, check the exact published name and let me know and I'll adjust it.

## Source Code

````pine
//@version=6
// ============================================================
// RSI DIVERGENCE — PRICE CHART ARROWS v3 (Overlay Companion)
// ============================================================
// v3 merges v2 (anti-repaint, tiered trend, channel, zone,
// invalidation, MTF, entry line) with the confirmed-edge stack:
//
//   • Equivalent index price on label (SPY → SPX)
//   • Volume Confluence (★ diamond when arrow coincides
//     with a recent MAJOR/EXTREME volume event)
//   • EMA Fan-Out momentum filter (optional gate)
//   • Key Levels — PDH / PDL / pre-market H & L (intraday)
//   • Decision Level — auto-detected structural pivot with
//     ONE dashed line + ONE direction arrow + ONE plan box
//
// All new modules default to NON-BLOCKING — arrows still fire
// exactly like v2 out of the box. Turn the gates on when you
// want ultra-selective output.
//
// GREEN ▲ below bar = bullish cross
// RED   ▼ above bar = bearish cross
// YELLOW ◆ on arrow = volume confluence confirmation
// ============================================================
indicator(
    title     = "RSI Div · Price Arrows v3",
    shorttitle= "RSI·Arrows",
    overlay   = true,
    max_lines_count  = 500,
    max_labels_count = 500
)

// ─────────────────────────────────────────────
//  INPUTS  (mirror these to your RSI pane script)
// ─────────────────────────────────────────────
rsiLen      = input.int  (14,   "RSI Period",           group="RSI Settings")
rsiSrc      = input      (close,"RSI Source",           group="RSI Settings")
lbL         = input.int  (5,    "Pivot Lookback Left",  group="RSI Settings")
lbR         = input.int  (5,    "Pivot Lookback Right", group="RSI Settings")
rangeUpper  = input.int  (60,   "Max Lookback Range",   group="RSI Settings")
rangeLower  = input.int  (5,    "Min Lookback Range",   group="RSI Settings")
useLastN    = input.int  (1,    "Which ray to test (1=latest)", minval=1, maxval=2, group="RSI Settings")

// ─────────────────────────────────────────────
//  ARROW DISPLAY OPTIONS
// ─────────────────────────────────────────────
showRawCross    = input.bool(false, "Show ALL ray crosses (yellow dot equivalent)", group="Display")
showStrictOnly  = input.bool(true,  "Show STRICT crosses only (higher confidence)", group="Display")
arrowSize       = input.string("tiny", "Arrow Size", options=["tiny","small","normal","large"], group="Display")
showEquiv       = input.bool(true,  "Show equivalent index price on label", group="Display")
equivSymbol     = input.symbol("SP:SPX", "Equivalent index symbol", group="Display", tooltip="Index price shown on the entry-line label, e.g. SP:SPX when trading SPY.")
equivLabel      = input.string("SPX", "Equivalent label prefix", group="Display", tooltip="Short label shown before the equivalent price, e.g. 'SPX', 'NDX', 'ES'.")

// ─────────────────────────────────────────────
//  VOLUME CONFIRMATION
// ─────────────────────────────────────────────
enableVolFilter  = input.bool(false, "Enable volume filter",       group="Volume", tooltip="Require above-average volume on signal bar. Turn OFF for CFD/index data with no real volume.")
volMaPeriod      = input.int(20,     "Volume MA period",           minval=5, maxval=100, group="Volume")
volMultiplier    = input.float(1.0,  "Min volume ratio vs MA",    step=0.1, minval=0.5, maxval=3.0, group="Volume", tooltip="1.0 = at least average volume. 1.2 = 20% above average.")

// ─────────────────────────────────────────────
//  EMA TREND FILTER (tiered: soft vs hard)
// ─────────────────────────────────────────────
enableTrendFilter = input.bool(true, "Enable EMA trend filter", group="Trend Filter")
trendMode         = input.string("Tiered", "Trend filter mode", options=["Hard block", "Tiered"], group="Trend Filter", tooltip="Hard block: kill all counter-trend signals. Tiered: counter-trend signals must pass strict + volume filter.")
trendEmaFast      = input.int(13,  "Fast EMA",  minval=5, group="Trend Filter")
trendEmaSlow      = input.int(48,  "Slow EMA",  minval=10, group="Trend Filter")
trendEmaAnchor    = input.int(200, "Anchor EMA", minval=50, group="Trend Filter")

// ─────────────────────────────────────────────
//  RSI ZONE WEIGHTING
// ─────────────────────────────────────────────
enableZoneFilter = input.bool(false, "Enable RSI zone filter", group="RSI Zones", tooltip="Bullish signals stronger below OS zone, bearish stronger above OB zone. Signals in neutral zone require extra confirmation.")
zoneBullMax      = input.float(40.0, "Bull signal: RSI must be below", step=1.0, group="RSI Zones", tooltip="Bullish cross more reliable when RSI is low")
zoneBearMin      = input.float(60.0, "Bear signal: RSI must be above", step=1.0, group="RSI Zones", tooltip="Bearish cross more reliable when RSI is high")
zoneNeutralPass  = input.bool(true,  "Allow neutral-zone signals with extra filters", group="RSI Zones", tooltip="If RSI is between zones, signal fires only if volume + strict filter pass")

// ─────────────────────────────────────────────
//  SIGNAL INVALIDATION
// ─────────────────────────────────────────────
enableInvalidation  = input.bool(false, "Enable signal invalidation",       group="Invalidation", tooltip="Kill signal if RSI re-crosses the ray within N bars")
invalidBars         = input.int(5,      "Re-cross window (bars)",           minval=2, maxval=20, group="Invalidation")
showInvalidX        = input.bool(true,  "Show X marker on invalidation",   group="Invalidation")

// ─────────────────────────────────────────────
//  MULTI-TIMEFRAME CONFIRMATION
// ─────────────────────────────────────────────
enableMTF       = input.bool(false,  "Enable higher-TF RSI confirmation", group="Multi-Timeframe", tooltip="Signal requires higher timeframe RSI to agree with direction")
mtfTimeframe    = input.timeframe("60", "Higher timeframe",               group="Multi-Timeframe")
mtfRsiLen       = input.int(14,      "Higher TF RSI period",             group="Multi-Timeframe")
mtfBullBelow    = input.float(50.0,  "HTF RSI must be below (for bull)", step=1.0, group="Multi-Timeframe", tooltip="For bullish signals, higher TF RSI should be below this — room to rise")
mtfBearAbove    = input.float(50.0,  "HTF RSI must be above (for bear)", step=1.0, group="Multi-Timeframe", tooltip="For bearish signals, higher TF RSI should be above this — room to fall")

// Strict filter thresholds (same as RSI pane script)
ag_lookback     = input.int  (20,  "Approach depth lookback",                         group="Strict Filters")
ag_minGap       = input.float(6,   "Min RSI distance from ray before break", step=0.1, group="Strict Filters")
ag_minBarsSince = input.int  (4,   "Min bars since deepest point",                    group="Strict Filters")
ag_preBars      = input.int  (3,   "Pre-break approach bars",                         group="Strict Filters")
ag_preBuf       = input.float(1.0, "Pre-break buffer (pts)",                step=0.1, group="Strict Filters")
ag_minJump      = input.float(2.0, "Min RSI jump on cross (pts)",           step=0.1, group="Strict Filters")

// ─────────────────────────────────────────────
//  CHANNEL DETECTION & BREAKOUT
// ─────────────────────────────────────────────
enableChannel   = input.bool(true,  "Enable channel breakout signals",  group="Channel")
chanSlopeTol    = input.float(0.15, "Slope similarity tolerance",       step=0.05, group="Channel", tooltip="Max slope difference for rays to count as parallel")
chanMinGap      = input.float(4.0,  "Min RSI gap between channel rays", step=0.5, group="Channel")
chanContainBars = input.int(5,      "Min bars RSI inside channel",      minval=2, maxval=20, group="Channel")
chanBuffer      = input.float(2.0,  "Containment buffer (RSI pts)",     step=0.5, group="Channel", tooltip="Allow small overshoots outside channel walls")

// ─────────────────────────────────────────────
//  VOLUME CONFLUENCE (edge module — decoration)
// ─────────────────────────────────────────────
enableConfluence  = input.bool(true,  "Enable volume confluence",        group="Confluence", tooltip="Paint a yellow diamond on arrows that coincide with a recent MAJOR/EXTREME volume event. Decoration only — does NOT block arrows unless 'Only show confluence arrows' is on.")
confOnlyMode      = input.bool(false, "Only show confluence arrows",     group="Confluence", tooltip="Ultra-selective mode: hide all non-confluence arrows. Only the highest-edge setups remain.")
confVolMa         = input.int(20,     "Confluence vol MA period",        minval=5, maxval=100, group="Confluence")
confMajorMult     = input.float(3.5,  "MAJOR volume multiplier",         step=0.1, minval=2.0, group="Confluence", tooltip="Multiple of avg volume that counts as a MAJOR event")
confExtremeMult   = input.float(6.0,  "EXTREME volume multiplier",       step=0.5, minval=3.0, group="Confluence", tooltip="Multiple of avg volume that counts as an EXTREME event")
confLookback      = input.int(5,      "Confluence window (bars back)",   minval=1, maxval=30, group="Confluence", tooltip="How many bars back to search. Weekly: 3-5. Daily: 5-10. Intraday: 10-20.")
confRequireCounter= input.bool(false, "Require counter-trend position",  group="Confluence", tooltip="Only tag confluence when price is stretched counter to trend (bull below EMA200, bear above)")
confStarSize      = input.string("small", "Confluence marker size", options=["tiny","small","normal","large"], group="Confluence")

// ─────────────────────────────────────────────
//  HIGHER-TF INTRA-BAR FIRING
// ─────────────────────────────────────────────
// On M / W / 4H / 1H: fire as soon as the candle colour matches the
// signal direction — no need to wait for bar close.
//   Bull signal → fires on a GREEN candle (close > open)
//   Bear signal → fires on a RED candle   (close < open)
// Lower timeframes keep the anti-repaint barstate.isconfirmed gate.
enableIntraBar = input.bool(true, "Fire on candle colour (M/W/4H/1H)", group="Intra-Bar Firing",
     tooltip="Higher timeframes (1H/4H/W/M): fire immediately when candle colour agrees with direction. Avoids waiting for bar close. Lower TFs always use bar-close gate.")

// ─────────────────────────────────────────────
//  FAN-OUT MOMENTUM FILTER (optional gate)
// ─────────────────────────────────────────────
enableFanOut     = input.bool(false, "Require EMA fan-out for signals", group="Fan-Out Filter", tooltip="Block signals while EMAs are bunched/choppy. Only fire when 13/48/200 are fanned out with real spacing. OFF by default — turn on for ultra-selective mode.")
fanOutMinPct     = input.float(0.05, "Min fan spacing % of price",     step=0.01, group="Fan-Out Filter", tooltip="Minimum |EMA13 - EMA200| / price * 100. Higher = stricter.")

// ─────────────────────────────────────────────
//  KEY LEVELS — PDH / PDL / pre-market (intraday)
// ─────────────────────────────────────────────
enableLevels     = input.bool(true,  "Enable PDH/PDL + pre-market levels", group="Key Levels", tooltip="Useful on intraday (2m–1h). Turn OFF on daily/weekly.")
usePDHL          = input.bool(false, "Show previous day high/low",        group="Key Levels")
usePMHL          = input.bool(false, "Show pre-market high/low",          group="Key Levels")
pmSession        = input.session("0400-0930", "Pre-market session",       group="Key Levels")
levelProxPct     = input.float(0.25, "Level proximity %",                 step=0.05, group="Key Levels", tooltip="How close price must be to a level to tag an arrow with it.")
requireLevelProx = input.bool(false, "Only fire arrows near a level",     group="Key Levels", tooltip="Ultra-selective: arrows fire only when near PDH/PDL/PMH/PML.")

// ─────────────────────────────────────────────
//  DECISION LEVEL (expert-trader module)
// ─────────────────────────────────────────────
enableDecision   = input.bool(true,  "Enable decision level", group="Decision Level", tooltip="Auto-finds the single structural pivot that matters right now. Above it = long bias, below it = short bias.")
decisionLb       = input.int (10,    "Swing pivot lookback",  minval=3, maxval=50, group="Decision Level", tooltip="Bars for ta.pivothigh/pivotlow. Weekly: 5-8. Daily: 8-15. Intraday: 10-20.")
decisionBufPct   = input.float(0.15, "Bias buffer %",         step=0.05, group="Decision Level", tooltip="Price must be this far above/below the level to count as bullish/bearish.")
showDecisionArrow= input.bool(true,  "Show direction arrow on right edge", group="Decision Level")
showDecisionPlan = input.bool(true,  "Show trade plan label", group="Decision Level")

// ─────────────────────────────────────────────
//  ARROW SIZE FLAGS (plotshape size must be const)
// ─────────────────────────────────────────────
isTiny   = arrowSize == "tiny"
isSmall  = arrowSize == "small"
isLarge  = arrowSize == "large"
isNormal = arrowSize == "normal"

isStarTiny   = confStarSize == "tiny"
isStarSmall  = confStarSize == "small"
isStarNormal = confStarSize == "normal"
isStarLarge  = confStarSize == "large"

// ─────────────────────────────────────────────
//  RSI CALCULATION
// ─────────────────────────────────────────────
osc = ta.rsi(rsiSrc, rsiLen)

// ─────────────────────────────────────────────
//  VOLUME CALCULATION
// ─────────────────────────────────────────────
volMA       = ta.sma(volume, volMaPeriod)
volOk       = not enableVolFilter or (volume >= volMA * volMultiplier)

// ─────────────────────────────────────────────
//  EMA TREND CALCULATION
// ─────────────────────────────────────────────
emaF = ta.ema(close, trendEmaFast)
emaS = ta.ema(close, trendEmaSlow)
emaA = ta.ema(close, trendEmaAnchor)

trendBearishStack = enableTrendFilter and (emaF < emaS) and (emaS < emaA)
trendBullishStack = enableTrendFilter and (emaF > emaS) and (emaS > emaA)

// ─── Fan-out momentum detection ───
rawBullStack  = (emaF > emaS) and (emaS > emaA)
rawBearStack  = (emaF < emaS) and (emaS < emaA)
fanSpacingPct = close > 0 ? math.abs(emaF - emaA) / close * 100.0 : 0.0
fanOutBull    = rawBullStack and fanSpacingPct >= fanOutMinPct
fanOutBear    = rawBearStack and fanSpacingPct >= fanOutMinPct
fanOutBullOk  = not enableFanOut or fanOutBull
fanOutBearOk  = not enableFanOut or fanOutBear

// ─────────────────────────────────────────────
//  MULTI-TIMEFRAME RSI
// ─────────────────────────────────────────────
htfRsi = request.security(syminfo.tickerid, mtfTimeframe, ta.rsi(close, mtfRsiLen), lookahead=barmerge.lookahead_off)

// Equivalent index price (for ETFs → underlying index display on label)
equivPrice = request.security(equivSymbol, timeframe.period, close, lookahead=barmerge.lookahead_off)
mtfBullOk = not enableMTF or (htfRsi < mtfBullBelow)
mtfBearOk = not enableMTF or (htfRsi > mtfBearAbove)

// ─────────────────────────────────────────────
//  KEY LEVELS — PDH / PDL / pre-market H/L
// ─────────────────────────────────────────────
pdhLvl = request.security(syminfo.tickerid, "D", high[1], lookahead=barmerge.lookahead_off)
pdlLvl = request.security(syminfo.tickerid, "D", low[1],  lookahead=barmerge.lookahead_off)

inPMSession   = not na(time(timeframe.period, pmSession))
var float pmH = na
var float pmL = na
newDay = ta.change(time("D")) != 0
if newDay
    pmH := na
    pmL := na
if inPMSession
    pmH := na(pmH) ? high : math.max(pmH, high)
    pmL := na(pmL) ? low  : math.min(pmL, low)

nearLvl(lvl) => not na(lvl) and close > 0 and math.abs(close - lvl) / close * 100.0 <= levelProxPct
nearPDH = enableLevels and usePDHL and nearLvl(pdhLvl)
nearPDL = enableLevels and usePDHL and nearLvl(pdlLvl)
nearPMH = enableLevels and usePMHL and nearLvl(pmH)
nearPML = enableLevels and usePMHL and nearLvl(pmL)
nearAnyLevel = nearPDH or nearPDL or nearPMH or nearPML
levelTag     = nearPDH ? "PDH" : nearPDL ? "PDL" : nearPMH ? "PMH" : nearPML ? "PML" : ""
levelProxOk  = not requireLevelProx or nearAnyLevel

plot(enableLevels and usePDHL ? pdhLvl : na, title="PDH", color=color.new(color.aqua, 30),    style=plot.style_linebr, linewidth=1)
plot(enableLevels and usePDHL ? pdlLvl : na, title="PDL", color=color.new(color.aqua, 30),    style=plot.style_linebr, linewidth=1)
plot(enableLevels and usePMHL ? pmH   : na,  title="PMH", color=color.new(color.fuchsia, 40), style=plot.style_linebr, linewidth=1)
plot(enableLevels and usePMHL ? pmL   : na,  title="PML", color=color.new(color.fuchsia, 40), style=plot.style_linebr, linewidth=1)

// ─────────────────────────────────────────────
//  PIVOT DETECTION
// ─────────────────────────────────────────────
plFound = not na(ta.pivotlow (osc, lbL, lbR))
phFound = not na(ta.pivothigh(osc, lbL, lbR))

_inRange(cond) =>
    bars = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper

inRangePl = _inRange(plFound[1])
inRangePh = _inRange(phFound[1])

// ─────────────────────────────────────────────
//  DIVERGENCE CONDITIONS (to build the rays)
// ─────────────────────────────────────────────
// ── Low pivots (bullish divergence source) ──
curOscPL  = osc[lbR]
curBarPL  = bar_index[lbR]
prevOscPL = ta.valuewhen(plFound, osc[lbR],       1)
prevBarPL = ta.valuewhen(plFound, bar_index[lbR], 1)
have2PL   = plFound and not na(prevOscPL) and not na(prevBarPL) and inRangePl

oscHL         = osc[lbR] > ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceLL       = low[lbR]  < ta.valuewhen(plFound, low[lbR],  1)
bullCondAlert = priceLL and oscHL and plFound

oscLL               = osc[lbR] < ta.valuewhen(plFound, osc[lbR], 1) and inRangePl
priceHL             = low[lbR]  > ta.valuewhen(plFound, low[lbR],  1)
hiddenBullCondAlert = priceHL and oscLL and plFound

// ── High pivots (bearish divergence source) ──
curOscPH  = osc[lbR]
curBarPH  = bar_index[lbR]
prevOscPH = ta.valuewhen(phFound, osc[lbR],       1)
prevBarPH = ta.valuewhen(phFound, bar_index[lbR], 1)
have2PH   = phFound and not na(prevOscPH) and not na(prevBarPH) and inRangePh

oscLH         = osc[lbR] < ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
priceHH       = high[lbR] > ta.valuewhen(phFound, high[lbR], 1)
bearCondAlert = priceHH and oscLH and phFound

oscHH               = osc[lbR] > ta.valuewhen(phFound, osc[lbR], 1) and inRangePh
priceLH             = high[lbR] < ta.valuewhen(phFound, high[lbR], 1)
hiddenBearCondAlert = priceLH and oscHH and phFound

// ─────────────────────────────────────────────
//  BUILD RAYS (same as RSI pane script)
// ─────────────────────────────────────────────
var line rayBullReg       = na
var line rayHiddenBullReg = na
var line rayBearReg       = na
var line rayHiddenBearReg = na

showLine = false
makeRay(x1, y1, x2, y2, col) =>
    line.new(x1=x1, y1=y1, x2=x2, y2=y2, xloc=xloc.bar_index, extend=extend.right, color=showLine ? col : na, width=2)

var line[] bullRays = array.new_line()
var line[] bearRays = array.new_line()

if barstate.isconfirmed
    if bullCondAlert and have2PL
        rayBullReg := makeRay(prevBarPL, prevOscPL, curBarPL, curOscPL, color.green)
        array.push(bullRays, rayBullReg)
    if hiddenBullCondAlert and have2PL
        rayHiddenBullReg := makeRay(prevBarPL, prevOscPL, curBarPL, curOscPL, color.new(color.green, 80))
        array.push(bullRays, rayHiddenBullReg)
    if bearCondAlert and have2PH
        rayBearReg := makeRay(prevBarPH, prevOscPH, curBarPH, curOscPH, color.red)
        array.push(bearRays, rayBearReg)
    if hiddenBearCondAlert and have2PH
        rayHiddenBearReg := makeRay(prevBarPH, prevOscPH, curBarPH, curOscPH, color.new(color.red, 80))
        array.push(bearRays, rayHiddenBearReg)

// Keep only last 2 rays active per direction
enforce_last_two(arr) =>
    arrSz = array.size(arr)
    if arrSz > 0
        for i = 0 to arrSz - 1
            l = array.get(arr, i)
            if not na(l)
                line.set_extend(l, i >= arrSz - 2 ? extend.right : extend.none)

enforce_last_two(bullRays)
enforce_last_two(bearRays)

// ─────────────────────────────────────────────
//  RAY MATH HELPERS
// ─────────────────────────────────────────────
last_from(arr, int n) =>
    int sz = array.size(arr)
    sz >= n ? array.get(arr, sz - n) : na

ray_y_at(line l, int x) =>
    na(l) ? na : line.get_y1(l) + (line.get_y2(l) - line.get_y1(l)) / (line.get_x2(l) - line.get_x1(l)) * (x - line.get_x1(l))

// Cross detection against RSI value
cross_up_ray(ser, line l) =>
    yNow = ray_y_at(l, bar_index)
    yPrev= ray_y_at(l, bar_index - 1)
    not na(l) and not na(yNow) and not na(yPrev) and ser[1] < yPrev and ser > yNow

cross_dn_ray(ser, line l) =>
    yNow = ray_y_at(l, bar_index)
    yPrev= ray_y_at(l, bar_index - 1)
    not na(l) and not na(yNow) and not na(yPrev) and ser[1] > yPrev and ser < yNow

// ─────────────────────────────────────────────
//  CROSS DETECTION
// ─────────────────────────────────────────────
line lastBearRay = last_from(bearRays, useLastN)
line lastBullRay = last_from(bullRays, useLastN)

rawUpRed   = cross_up_ray(osc, lastBearRay)   // RSI up through bearish ray -> BULLISH
rawDnGreen = cross_dn_ray(osc, lastBullRay)   // RSI down through bullish ray -> BEARISH

// ─────────────────────────────────────────────
//  CHANNEL DETECTION & BREAKOUT
// ─────────────────────────────────────────────
ray_slope(line l) =>
    na(l) ? na : (line.get_y2(l) - line.get_y1(l)) / math.max(line.get_x2(l) - line.get_x1(l), 1)

was_between(line r1, line r2, int bars, float buf) =>
    ok = true
    for i = 1 to bars
        y1 = ray_y_at(r1, bar_index - i)
        y2 = ray_y_at(r2, bar_index - i)
        if na(y1) or na(y2)
            ok := false
            break
        yHi = math.max(y1, y2)
        yLo = math.min(y1, y2)
        if osc[i] > yHi + buf or osc[i] < yLo - buf
            ok := false
            break
    ok

valid_channel(line r1, line r2) =>
    s1 = ray_slope(r1)
    s2 = ray_slope(r2)
    if na(s1) or na(s2)
        false
    else
        slopeOk = math.abs(s1 - s2) <= chanSlopeTol
        y1 = ray_y_at(r1, bar_index)
        y2 = ray_y_at(r2, bar_index)
        gapOk = not na(y1) and not na(y2) and math.abs(y1 - y2) >= chanMinGap
        slopeOk and gapOk

line bearR1 = last_from(bearRays, 1)
line bearR2 = last_from(bearRays, 2)
line bullR1 = last_from(bullRays, 1)
line bullR2 = last_from(bullRays, 2)

bearChanOk = enableChannel and not na(bearR1) and not na(bearR2) and valid_channel(bearR1, bearR2) and was_between(bearR1, bearR2, chanContainBars, chanBuffer)
bearY1 = ray_y_at(bearR1, bar_index)
bearY2 = ray_y_at(bearR2, bar_index)
r1IsUpperBear = not na(bearY1) and not na(bearY2) and bearY1 >= bearY2
chanBullBreak = bearChanOk and (r1IsUpperBear ? cross_up_ray(osc, bearR1) : cross_up_ray(osc, bearR2))

bullChanOk = enableChannel and not na(bullR1) and not na(bullR2) and valid_channel(bullR1, bullR2) and was_between(bullR1, bullR2, chanContainBars, chanBuffer)
bullY1 = ray_y_at(bullR1, bar_index)
bullY2 = ray_y_at(bullR2, bar_index)
r1IsLowerBull = not na(bullY1) and not na(bullY2) and bullY1 <= bullY2
chanBearBreak = bullChanOk and (r1IsLowerBull ? cross_dn_ray(osc, bullR1) : cross_dn_ray(osc, bullR2))

// ─────────────────────────────────────────────
//  STRICT FILTER (optional, mirrors pane script)
// ─────────────────────────────────────────────
gap_below_at(ser, line l, int x) =>
    y = ray_y_at(l, x)
    na(y) ? na : (y - ser)

gap_above_at(ser, line l, int x) =>
    y = ray_y_at(l, x)
    na(y) ? na : (ser - y)

deepest_below(line l, lookback) =>
    float m = -1e9
    int idx = na
    if na(l)
        [float(na), int(na)]
    else
        for i = 1 to lookback
            g = gap_below_at(osc[i], l, bar_index - i)
            if not na(g) and g > m
                m := g
                idx := i
        [m, idx]

deepest_above(line l, lookback) =>
    float m = -1e9
    int idx = na
    if na(l)
        [float(na), int(na)]
    else
        for i = 1 to lookback
            g = gap_above_at(osc[i], l, bar_index - i)
            if not na(g) and g > m
                m := g
                idx := i
        [m, idx]

stayed_below(line l, n, buf) =>
    ok = true
    for i = 1 to n
        g = gap_below_at(osc[i], l, bar_index - i)
        ok := ok and (not na(g) and g > buf)
    ok

stayed_above(line l, n, buf) =>
    ok = true
    for i = 1 to n
        g = gap_above_at(osc[i], l, bar_index - i)
        ok := ok and (not na(g) and g > buf)
    ok

[dBelowRed, dBelowRedAgo]    = deepest_below(lastBearRay, ag_lookback)
[dAboveGreen, dAboveGreenAgo]= deepest_above(lastBullRay, ag_lookback)

strictBullRed = rawUpRed and not na(dBelowRed) and dBelowRed >= ag_minGap and not na(dBelowRedAgo) and dBelowRedAgo >= ag_minBarsSince and stayed_below(lastBearRay, ag_preBars, ag_preBuf) and (osc - osc[1]) >= ag_minJump

strictBearGreen = rawDnGreen and not na(dAboveGreen) and dAboveGreen >= ag_minGap and not na(dAboveGreenAgo) and dAboveGreenAgo >= ag_minBarsSince and stayed_above(lastBullRay, ag_preBars, ag_preBuf) and (osc[1] - osc) >= ag_minJump

// ─────────────────────────────────────────────
//  RSI ZONE GATING
// ─────────────────────────────────────────────
bullInZone   = not enableZoneFilter or (osc <= zoneBullMax)
bearInZone   = not enableZoneFilter or (osc >= zoneBearMin)
inNeutralZone = (osc > zoneBullMax) and (osc < zoneBearMin)
bullNeutral   = enableZoneFilter and inNeutralZone and zoneNeutralPass and strictBullRed and volOk
bearNeutral   = enableZoneFilter and inNeutralZone and zoneNeutralPass and strictBearGreen and volOk

// ─────────────────────────────────────────────
//  TIERED TREND FILTER LOGIC
// ─────────────────────────────────────────────
trendHardBlock = enableTrendFilter and trendMode == "Hard block"
trendTiered    = enableTrendFilter and trendMode == "Tiered"

bullTrendOk = not enableTrendFilter or not trendBearishStack
bearTrendOk = not enableTrendFilter or not trendBullishStack

bullHardOk = not trendHardBlock or not trendBearishStack
bearHardOk = not trendHardBlock or not trendBullishStack

bullTieredCounterOk = trendTiered and trendBearishStack and strictBullRed and volOk
bearTieredCounterOk = trendTiered and trendBullishStack and strictBearGreen and volOk

bullTrendPass = bullTrendOk or bullTieredCounterOk
bearTrendPass = bearTrendOk or bearTieredCounterOk

bullTrendFinal = trendHardBlock ? bullHardOk : bullTrendPass
bearTrendFinal = trendHardBlock ? bearHardOk : bearTrendPass

// ─────────────────────────────────────────────
//  COMBINE ALL SIGNAL SOURCES
// ─────────────────────────────────────────────
rawBull = rawUpRed or chanBullBreak
rawBear = rawDnGreen or chanBearBreak

bullVolOk = not enableVolFilter or volOk
bearVolOk = not enableVolFilter or volOk

bullZonePass = bullInZone or bullNeutral
bearZonePass = bearInZone or bearNeutral

// ─────────────────────────────────────────────
//  FINAL SIGNAL SELECTION (CONFIRMED BARS ONLY)
// ─────────────────────────────────────────────
rawBullSignal = rawBull and bullVolOk and bullTrendFinal and bullZonePass and mtfBullOk
rawBearSignal = rawBear and bearVolOk and bearTrendFinal and bearZonePass and mtfBearOk

strictBullSignal = (strictBullRed or chanBullBreak) and bullVolOk and bullTrendFinal and bullZonePass and mtfBullOk
strictBearSignal = (strictBearGreen or chanBearBreak) and bearVolOk and bearTrendFinal and bearZonePass and mtfBearOk

preBull = showStrictOnly ? strictBullSignal : (showRawCross and rawBullSignal)
preBear = showStrictOnly ? strictBearSignal : (showRawCross and rawBearSignal)

// ── Higher-TF intra-bar candle-colour gate ────────────────────────────────
// On 1H / 4H / W / M: green candle confirms bull, red confirms bear.
// Lower TFs keep barstate.isconfirmed (anti-repaint).
bool isHigherTF  = timeframe.period == "60" or timeframe.period == "240" or timeframe.period == "W" or timeframe.period == "M"
bool greenCandle = close > open   // bullish body
bool redCandle   = close < open   // bearish body

// Per-direction confirmation gate:
//   Higher TF + intra-bar enabled → candle colour alone is sufficient
//   Everything else               → must be confirmed (bar closed)
bool bullConfGate = barstate.isconfirmed or (enableIntraBar and isHigherTF and greenCandle)
bool bearConfGate = barstate.isconfirmed or (enableIntraBar and isHigherTF and redCandle)

// ANTI-REPAINT GATE + optional fan-out + optional level proximity
drawBullArrow = bullConfGate and preBull and fanOutBullOk and levelProxOk
drawBearArrow = bearConfGate and preBear and fanOutBearOk and levelProxOk

// ─────────────────────────────────────────────
//  SIGNAL INVALIDATION
// ─────────────────────────────────────────────
var int   lastSignalBar  = na
var int   lastSignalDir  = 0    // 1 = bull, -1 = bear
var bool  signalActive   = false
var line  lastSigRayRef  = na

if drawBullArrow
    lastSignalBar := bar_index
    lastSignalDir := 1
    signalActive  := true
    lastSigRayRef := lastBearRay

if drawBearArrow
    lastSignalBar := bar_index
    lastSignalDir := -1
    signalActive  := true
    lastSigRayRef := lastBullRay

bool invalidated = false

if enableInvalidation and signalActive and not na(lastSignalBar) and barstate.isconfirmed
    barsElapsed = bar_index - lastSignalBar
    if barsElapsed >= 1 and barsElapsed <= invalidBars and not na(lastSigRayRef)
        if lastSignalDir == 1 and cross_dn_ray(osc, lastSigRayRef)
            invalidated := true
            signalActive := false
        if lastSignalDir == -1 and cross_up_ray(osc, lastSigRayRef)
            invalidated := true
            signalActive := false
    if barsElapsed > invalidBars
        signalActive := false

plotshape(invalidated and showInvalidX, title="X Invalidated", style=shape.xcross, location=location.belowbar, color=color.new(color.orange, 0), size=size.small)

// ─────────────────────────────────────────────
//  VOLUME CONFLUENCE DETECTION
//  Self-contained: replicates the MAJOR/EXTREME
//  volume tier logic so this file has no
//  dependency on the volume detector script.
// ─────────────────────────────────────────────
volMaConf    = ta.sma(volume, confVolMa)
volRatioConf = volMaConf > 0 ? volume / volMaConf : 0.0
isMajorVol   = enableConfluence and volRatioConf >= confMajorMult
isExtremeVol = enableConfluence and volRatioConf >= confExtremeMult
isHighVol    = isMajorVol or isExtremeVol
recentHighVol = ta.barssince(isHighVol) <= confLookback

belowAnchor = close < emaA
aboveAnchor = close > emaA
confBullOK  = confRequireCounter ? belowAnchor : true
confBearOK  = confRequireCounter ? aboveAnchor : true

bullConfluence = drawBullArrow and enableConfluence and recentHighVol and confBullOK
bearConfluence = drawBearArrow and enableConfluence and recentHighVol and confBearOK

// Only-confluence mode: hide non-confluence arrows
showBullArrow = confOnlyMode ? bullConfluence : drawBullArrow
showBearArrow = confOnlyMode ? bearConfluence : drawBearArrow

// ─────────────────────────────────────────────
//  PRICE CHART ARROWS
// ─────────────────────────────────────────────
plotshape(showBullArrow and isTiny,   title="Bull (tiny)",   style=shape.triangleup, location=location.belowbar, color=color.new(color.lime,0), size=size.tiny)
plotshape(showBullArrow and isSmall,  title="Bull (small)",  style=shape.triangleup, location=location.belowbar, color=color.new(color.lime,0), size=size.small)
plotshape(showBullArrow and isNormal, title="Bull (normal)", style=shape.triangleup, location=location.belowbar, color=color.new(color.lime,0), size=size.normal)
plotshape(showBullArrow and isLarge,  title="Bull (large)",  style=shape.triangleup, location=location.belowbar, color=color.new(color.lime,0), size=size.large)

plotshape(showBearArrow and isTiny,   title="Bear (tiny)",   style=shape.triangledown, location=location.abovebar, color=color.new(color.red,0), size=size.tiny)
plotshape(showBearArrow and isSmall,  title="Bear (small)",  style=shape.triangledown, location=location.abovebar, color=color.new(color.red,0), size=size.small)
plotshape(showBearArrow and isNormal, title="Bear (normal)", style=shape.triangledown, location=location.abovebar, color=color.new(color.red,0), size=size.normal)
plotshape(showBearArrow and isLarge,  title="Bear (large)",  style=shape.triangledown, location=location.abovebar, color=color.new(color.red,0), size=size.large)

// Confluence diamonds — overlaid on arrows that coincide with recent MAJOR/EXTREME vol
plotshape(bullConfluence and isStarTiny,   title="Bull Conf (tiny)",   style=shape.diamond, location=location.belowbar, color=color.new(color.yellow, 0), size=size.tiny)
plotshape(bullConfluence and isStarSmall,  title="Bull Conf (small)",  style=shape.diamond, location=location.belowbar, color=color.new(color.yellow, 0), size=size.small)
plotshape(bullConfluence and isStarNormal, title="Bull Conf (normal)", style=shape.diamond, location=location.belowbar, color=color.new(color.yellow, 0), size=size.normal)
plotshape(bullConfluence and isStarLarge,  title="Bull Conf (large)",  style=shape.diamond, location=location.belowbar, color=color.new(color.yellow, 0), size=size.large)

plotshape(bearConfluence and isStarTiny,   title="Bear Conf (tiny)",   style=shape.diamond, location=location.abovebar, color=color.new(color.yellow, 0), size=size.tiny)
plotshape(bearConfluence and isStarSmall,  title="Bear Conf (small)",  style=shape.diamond, location=location.abovebar, color=color.new(color.yellow, 0), size=size.small)
plotshape(bearConfluence and isStarNormal, title="Bear Conf (normal)", style=shape.diamond, location=location.abovebar, color=color.new(color.yellow, 0), size=size.normal)
plotshape(bearConfluence and isStarLarge,  title="Bear Conf (large)",  style=shape.diamond, location=location.abovebar, color=color.new(color.yellow, 0), size=size.large)

// ─────────────────────────────────────────────
//  ENTRY-LEVEL PRICE LINE (non-overlapping)
// ─────────────────────────────────────────────
var line  prevLine    = na
var label prevLabel   = na
var int   prevLineX1  = na
var bool  prevClipped = false

if showBullArrow or showBearArrow
    if not na(prevLine) and not na(prevLineX1)
        line.set_x2(prevLine, prevLineX1 + 3)
        prevClipped := true
    if not na(prevLabel) and not na(prevLineX1)
        label.set_x(prevLabel, prevLineX1 + 3)
    isBull = showBullArrow
    isConf = (showBullArrow and bullConfluence) or (showBearArrow and bearConfluence)
    col    = isBull ? color.new(color.lime, 0) : color.new(color.red, 0)
    lblCol = isConf ? color.new(color.yellow, 0) : (isBull ? color.new(color.lime, 15) : color.new(color.red, 15))
    txtCol = isConf ? color.black : (isBull ? color.black : color.white)
    confTag = isConf ? "★ " : ""
    lvlTag  = levelTag != "" ? "  [" + levelTag + "]" : ""
    entryTxt = confTag + str.tostring(close, format.mintick) + (showEquiv and not na(equivPrice) ? "  " + equivLabel + " " + str.tostring(equivPrice, format.mintick) : "") + lvlTag
    prevLine    := line.new(bar_index, close, bar_index + 10, close, xloc=xloc.bar_index, color=col, width=2, style=line.style_solid)
    prevLabel   := label.new(bar_index + 10, close, entryTxt, style=label.style_label_left, color=lblCol, textcolor=txtCol, size=size.tiny)
    prevLineX1  := bar_index
    prevClipped := false

    // ── Webhook alert: fires exactly when the green/red line is drawn ──────────
    // TradingView will POST this JSON to your webhook URL.
    // Create a TradingView alert on "RSI Div · Price Arrows v3" →
    // "Any alert() function call" → Once Per Bar Close → paste webhook URL.
    _dir     = isBull ? "BULLISH" : "BEARISH"
    _sig     = isBull ? "BULL_ARROW" : "BEAR_ARROW"
    _conf    = isConf ? "true" : "false"
    _price   = str.tostring(math.round(close, 4))
    _rsi     = str.tostring(math.round(osc, 2))
    _equiv   = showEquiv and not na(equivPrice) ? str.tostring(math.round(equivPrice, 2)) : "null"
    _ema     = trendBullishStack ? "BULL" : trendBearishStack ? "BEAR" : "NEUTRAL"
    _ema200  = close > emaA ? "ABOVE" : "BELOW"
    _atr     = str.tostring(math.round(ta.atr(14), 2))
    _rayage  = isBull ? (not na(lastBearRay) ? str.tostring(bar_index - line.get_x2(lastBearRay)) : "0") : (not na(lastBullRay) ? str.tostring(bar_index - line.get_x2(lastBullRay)) : "0")
    _sigtype = (isBull and chanBullBreak) or (not isBull and chanBearBreak) ? "CHANNEL_BREAK" : "RAY_CROSS"
    _rslope  = (osc - osc[3]) > 1.5 ? "RISING" : (osc - osc[3]) < -1.5 ? "FALLING" : "FLAT"
    // ray_rsi = the RSI level of the CROSSED ray at the moment of the cross
    _rayRsiRaw = isBull ? (not na(lastBearRay) ? ray_y_at(lastBearRay, bar_index) : na) : (not na(lastBullRay) ? ray_y_at(lastBullRay, bar_index) : na)
    _rayRsi  = not na(_rayRsiRaw) ? str.tostring(math.round(_rayRsiRaw, 1)) : "null"
    // intra_bar: true = fired before bar close (higher TF candle-colour gate)
    _intraBar = enableIntraBar and isHigherTF and not barstate.isconfirmed ? "true" : "false"
    _candleCol = greenCandle ? "GREEN" : redCandle ? "RED" : "DOJI"
    _msg = '{"ticker":"' + syminfo.ticker + '","exchange":"' + syminfo.prefix + '","timeframe":"' + timeframe.period + '","price":' + _price + ',"rsi":' + _rsi + ',"ray_rsi":' + _rayRsi + ',"direction":"' + _dir + '","signal":"' + _sig + '","confluence":' + _conf + ',"equiv_price":' + _equiv + ',"ema_stack":"' + _ema + '","price_vs_ema200":"' + _ema200 + '","atr":' + _atr + ',"ray_age":' + _rayage + ',"signal_type":"' + _sigtype + '","rsi_slope":"' + _rslope + '","intra_bar":' + _intraBar + ',"candle":"' + _candleCol + '"}'
    // alert() requires const string — cannot use a ternary variable.
    // Two explicit calls, only one path executes per bar.
    if enableIntraBar and isHigherTF
        alert(_msg, alert.freq_once_per_bar)
    else
        alert(_msg, alert.freq_once_per_bar_close)

// Clip line on invalidation — short 3-bar stub + dotted
if invalidated and not na(prevLine) and not na(prevLineX1)
    line.set_x2(prevLine, prevLineX1 + 3)
    line.set_style(prevLine, line.style_dotted)
    prevClipped := true
if invalidated and not na(prevLabel) and not na(prevLineX1)
    label.set_x(prevLabel, prevLineX1 + 3)
    label.set_text(prevLabel, "X")
    label.set_color(prevLabel, color.new(color.gray, 30))

if not na(prevLine) and not prevClipped
    line.set_x2(prevLine, bar_index + 10)
if not na(prevLabel) and not prevClipped
    label.set_x(prevLabel, bar_index + 10)

// ─────────────────────────────────────────────
//  DECISION LEVEL MODULE
//  Auto-detects the structural pivot that matters
//  RIGHT NOW. One dashed line, one bias arrow,
//  one plan label. Expert-trader simplification.
// ─────────────────────────────────────────────
dPivHi = ta.pivothigh(high, decisionLb, decisionLb)
dPivLo = ta.pivotlow (low,  decisionLb, decisionLb)

var float lastSwingHi    = na
var float lastSwingLo    = na
var int   lastSwingHiBar = na
var int   lastSwingLoBar = na

if not na(dPivHi)
    lastSwingHi    := dPivHi
    lastSwingHiBar := bar_index - decisionLb

if not na(dPivLo)
    lastSwingLo    := dPivLo
    lastSwingLoBar := bar_index - decisionLb

hiMoreRecent = not na(lastSwingHiBar) and not na(lastSwingLoBar) and lastSwingHiBar > lastSwingLoBar
loMoreRecent = not na(lastSwingHiBar) and not na(lastSwingLoBar) and lastSwingLoBar > lastSwingHiBar

decisionLvl  = hiMoreRecent ? lastSwingHi : loMoreRecent ? lastSwingLo : na
decisionTgt  = hiMoreRecent ? lastSwingLo : loMoreRecent ? lastSwingHi : na

bufMult      = decisionBufPct / 100.0
decisionBull = not na(decisionLvl) and close > decisionLvl * (1 + bufMult)
decisionBear = not na(decisionLvl) and close < decisionLvl * (1 - bufMult)

var line  decLine  = na
var label decArrow = na
var label decPlan  = na

if enableDecision and not na(decisionLvl)
    if not na(decLine)
        line.delete(decLine)
    decLineCol = decisionBull ? color.new(color.lime, 0) : decisionBear ? color.new(color.red, 0) : color.new(color.yellow, 0)
    decLine := line.new(bar_index - 50, decisionLvl, bar_index + 20, decisionLvl, xloc=xloc.bar_index, color=decLineCol, width=2, style=line.style_dashed)

if enableDecision and showDecisionArrow and barstate.islast and not na(decisionLvl)
    if not na(decArrow)
        label.delete(decArrow)
    arrowTxt  = decisionBull ? "▲ LONG" : decisionBear ? "▼ SHORT" : "◆ WAIT"
    arrowCol  = decisionBull ? color.new(color.lime, 0) : decisionBear ? color.new(color.red, 0) : color.new(color.yellow, 0)
    arrowTxtC = decisionBull ? color.black : decisionBear ? color.white : color.black
    decArrow := label.new(bar_index + 15, close, arrowTxt, style=label.style_label_left, color=arrowCol, textcolor=arrowTxtC, size=size.small)

if enableDecision and showDecisionPlan and barstate.islast and not na(decisionLvl)
    if not na(decPlan)
        label.delete(decPlan)
    lvlStr  = str.tostring(decisionLvl, format.mintick)
    tgtStr  = na(decisionTgt) ? "—" : str.tostring(decisionTgt, format.mintick)
    planTxt = decisionBull ? "LONG bias\nAbove " + lvlStr + "  (support)\nTarget ~ " + tgtStr + "\nInvalidate < " + lvlStr : decisionBear ? "SHORT bias\nBelow " + lvlStr + "  (resistance)\nTarget ~ " + tgtStr + "\nInvalidate > " + lvlStr : "DECISION ZONE\nLevel: " + lvlStr + "\nWait for break & close"
    planCol  = decisionBull ? color.new(color.green, 15) : decisionBear ? color.new(color.maroon, 15) : color.new(color.gray, 15)
    planTxtC = color.white
    decPlan := label.new(bar_index + 15, high, planTxt, style=label.style_label_lower_left, color=planCol, textcolor=planTxtC, size=size.small)

// ─────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────
alertcondition(
    drawBullArrow,
    title   = "Bullish RSI Ray Cross v3",
    message = "BULLISH cross on {{ticker}} ({{interval}}) | Price: {{close}} | RSI ray broken upward | Confirmed bar"
)

alertcondition(
    drawBearArrow,
    title   = "Bearish RSI Ray Cross v3",
    message = "BEARISH cross on {{ticker}} ({{interval}}) | Price: {{close}} | RSI ray broken downward | Confirmed bar"
)

alertcondition(
    invalidated,
    title   = "Signal Invalidated",
    message = "INVALIDATED signal on {{ticker}} ({{interval}}) | RSI re-crossed ray within window"
)

alertcondition(
    bullConfluence,
    title   = "★ BULL CONFLUENCE (Vol + RSI)",
    message = "★ BULL CONFLUENCE on {{ticker}} ({{interval}}) | Price: {{close}} | RSI ray break WITH recent MAJOR/EXTREME volume | HIGH-EDGE SETUP"
)

alertcondition(
    bearConfluence,
    title   = "★ BEAR CONFLUENCE (Vol + RSI)",
    message = "★ BEAR CONFLUENCE on {{ticker}} ({{interval}}) | Price: {{close}} | RSI ray break WITH recent MAJOR/EXTREME volume | HIGH-EDGE SETUP"
)

alertcondition(
    drawBullArrow and nearAnyLevel,
    title   = "★ BULL at KEY LEVEL",
    message = "★ BULL at key level on {{ticker}} ({{interval}}) | Price: {{close}} | RSI ray break at PDH/PDL/PMH/PML | HIGH-EDGE"
)

alertcondition(
    drawBearArrow and nearAnyLevel,
    title   = "★ BEAR at KEY LEVEL",
    message = "★ BEAR at key level on {{ticker}} ({{interval}}) | Price: {{close}} | RSI ray break at PDH/PDL/PMH/PML | HIGH-EDGE"
)
````
