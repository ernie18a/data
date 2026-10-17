# NQ Scalper Signals

- url: https://www.tradingview.com/script/fw6KwYXv-NQ-Scalper-Signals/
- type: indicator
- pine_id: PUB;3d324c4555c340a283dcd887e1111740
- version: 1.0

## Description

This is a script that will keep track of PMH, PML, LOD, and HOD and plot on chart.  It will also auto place fib levels based on that.  Includes signals/ candlestick analysis at those levels, but that is a work in progress. 

*Use at your own discretion*

## Source Code

````pine
//@version=6
indicator("NQ Scalper Signals", overlay=true, max_labels_count=200, max_lines_count=20)

// ═══════════════════════════════════════════════════════════════
//  NQ SCALPER SIGNALS v6
//  Added: Shooting Star/Hammer, Climactic Volume reversal
//  Tuned: keyProx 0.12%, emaAwayBars 3, dojiThresh 0.20
//  v4: Fib proximity + trend slope converted from absolute points
//      to % of price — auto-scales to ANY symbol (NQ, SPY, IWM,
//      stocks) with no per-chart tuning. Defaults 0.10% / 0.05%.
//  v5: Fib retracement re-anchored to measure DOWN from the high
//      (HOD = 0.0, LOD = 1.0) for a low→high move. .25/.50 now sit
//      near the top, .618/.75 near the bottom. Plot stacking, fills,
//      and the fib→resistance/support grouping flipped to match.
//  v6: Fib now auto-orients to the current leg instead of always
//      anchoring HOD→LOD. Direction is set by whichever extreme is
//      most recent (HOD newer = up-leg, retrace down from high; LOD
//      newer = down-leg, retrace up from low). Levels, plot stacking,
//      labels, fills, and resistance/support grouping all follow it.
// ═══════════════════════════════════════════════════════════════

// ─── INPUTS — REVERSAL ─────────────────────────────────────────
grpR = "━━━  Reversal Signals  ━━━"
showEngulf     = input.bool(true,  "Doji + Engulfing Combo",          group=grpR)
dojiThresh     = input.float(0.20, "Doji Max Body/Range Ratio",       group=grpR, minval=0.05, maxval=0.5, step=0.05, tooltip="0.20 = body must be < 20% of total range. Catches near-doji candles common on 5-min NQ.")
showShootStar  = input.bool(true,  "Shooting Star / Hammer",          group=grpR, tooltip="Single candle reversal — long wick rejection at high/low. No prior doji needed.")
wickRatioMin   = input.float(0.60, "Min Wick Ratio for Rejection",    group=grpR, minval=0.4, maxval=0.9, step=0.05, tooltip="Upper/lower wick must be > X% of total range")
recentHiLB     = input.int(20,     "At-High/Low Lookback (bars)",      group=grpR, minval=8, maxval=50, tooltip="How many bars back to define a meaningful high/low. 20 = 100 mins on 5-min chart")
showVolExh     = input.bool(true,  "Volume Exhaustion (declining)",   group=grpR)
volExhBars     = input.int(4,      "Declining Volume Bars",           group=grpR, minval=2, maxval=6)
volExhBelowAvg = input.bool(true,  "Require Below-Avg Volume",        group=grpR)
showVolSpike   = input.bool(true,  "Climactic Volume Spike",          group=grpR, tooltip="High volume at price extreme = climactic buying/selling. Opposite of exhaustion.")
volSpikeMult   = input.float(2.0,  "Volume Spike Multiplier",         group=grpR, minval=1.2, maxval=5.0, step=0.1, tooltip="Volume must be X times the 20-bar average")
showChoch      = input.bool(true,  "CHoCH — Change of Character",     group=grpR)
showKeyLvl     = input.bool(true,  "Key Level Rejection",             group=grpR)
keyProxPct     = input.float(0.12, "Key Level Proximity %",           group=grpR, minval=0.02, maxval=0.5, step=0.02, tooltip="Widened to 0.12% — ~36 pts on NQ at 30k")
showTLBreak    = input.bool(true,  "Trendline Break",                 group=grpR)
swingLen       = input.int(5,      "Swing Point Lookback (bars)",     group=grpR, minval=3, maxval=15)

// ─── INPUTS — CONTINUATION ─────────────────────────────────────
grpLVL = "━━━  Key Levels (PMH/PML/HOD/LOD)  ━━━"
showPMLevels   = input.bool(true,   "Show PM High / PM Low",            group=grpLVL)
showHODLOD     = input.bool(true,   "Show HOD / LOD",                   group=grpLVL)
pmSession      = input.string("1800-0930", "Premarket Session (EST)",              group=grpLVL,
                 tooltip="6:00 PM - 9:30 AM EST. Captures full overnight/premarket session.")
lvlLabelOffset = input.int(3,      "Level Label Right Offset (bars)", group=grpLVL, minval=0, maxval=30,
                 tooltip="Pushes the PMH/PML/HOD/LOD and 15m ORB price tags this many bars into the empty space right of the last candle so they don't sit on top of price. A connector line extends each level out to its tag. 0 = anchored to the current bar (old behavior). Independent of the fib offset.")

grpFIB = "━━━  Fibonacci Levels  ━━━"
showFibs       = input.bool(true,  "Show Fibonacci Levels (HOD → LOD)", group=grpFIB,
                 tooltip="Draws .25 .50 .618 .75 retracement levels between HOD and LOD. Auto-updates as new highs/lows form.")
fibProxPct     = input.float(0.10, "Fib Level Proximity (% of price)", group=grpFIB, minval=0.02, maxval=0.50, step=0.01,
                 tooltip="How close price must be to a fib level to score confluence, as a % of price. 0.10% auto-scales to any symbol — ~25 pts on NQ at 25k, ~0.30 on a $300 stock, ~0.60 on a $600 stock. No per-chart tuning needed.")
fibProxPoints  = close * fibProxPct / 100.0   // derived point distance — scales with instrument price
fibLabelOffset = input.int(3,      "Fib Label Right Offset (bars)",   group=grpFIB, minval=0, maxval=30,
                 tooltip="Pushes the .25/.50/.618/.75 fib price tags this many bars into the empty space right of the last candle so they don't sit on top of price. A connector line extends each fib out to its tag. 0 = anchored to the current bar (old behavior).")

grpVOL = "━━━  Signal Volume Filter  ━━━"
requireBreakoutVol = input.bool(true,   "Require Elevated Volume on Signal",  group=grpVOL,
                    tooltip="Signal candle volume must exceed prior candle by threshold below")
volBreakoutPct     = input.float(20.0,  "Min Volume % Above Prior Candle",    group=grpVOL,
                    minval=0.0, maxval=100.0, step=5.0,
                    tooltip="20 = signal bar volume must be at least 20% higher than the prior bar. Adjust in 5% increments.")

grpRSI = "━━━  RSI Settings  ━━━"
showRSI        = input.bool(true,  "Enable RSI Scoring",              group=grpRSI)
rsiLen         = input.int(14,     "RSI Length",                      group=grpRSI, minval=5, maxval=30)
rsiOB          = input.float(70.0, "Overbought Level",                group=grpRSI, minval=60.0, maxval=85.0, step=1.0)
rsiOS          = input.float(30.0, "Oversold Level",                  group=grpRSI, minval=15.0, maxval=40.0, step=1.0)
rsiDivLB       = input.int(5,      "Divergence Lookback (bars)",      group=grpRSI, minval=3, maxval=15, tooltip="Bars to look back for price vs RSI divergence")
showRSIPlot    = input.bool(false, "Plot RSI on Separate Pane",       group=grpRSI)
rsiDivRequired = input.bool(false, "Require RSI Divergence to Display", group=grpRSI,
                 tooltip="When ON, signals only display if RSI divergence is also present. Strictest filter — only highest conviction setups.")

grpC = "━━━  Continuation Signals  ━━━"
showEMA        = input.bool(true,  "9 EMA Pullback Entry",            group=grpC)
emaLen         = input.int(9,      "Fast EMA Length",                 group=grpC, minval=5, maxval=21)
emaAwayBars    = input.int(3,      "EMA Away Bars Required",          group=grpC, tooltip="Lowered to 3 — catches pullbacks sooner")
showORB        = input.bool(true,  "ORB Breakout",                    group=grpC)
orbMins        = input.int(30,     "ORB Window (minutes)",            group=grpC, minval=5, maxval=60, step=5)
showFlag       = input.bool(true,  "Bull / Bear Flag Breakout",       group=grpC)
poleMovePct    = input.float(0.30, "Flag Pole Min Move %",            group=grpC, minval=0.1, maxval=2.0, step=0.1)
showHHLL       = input.bool(true,  "HH / LL Structure Confirm",       group=grpC)
volConfirm     = input.bool(true,  "Require Volume on Breakouts",     group=grpC)

// ─── INPUTS — DISPLAY ──────────────────────────────────────────
grpD = "━━━  Display & Alerts  ━━━"
rthSession     = input.string("0930-1615", "RTH Session (EST)",               group=grpD,
                 tooltip="9:30 AM - 4:15 PM EST. All times are Eastern. Default covers NQ/ES/MES/MNQ regular hours.")
minScore       = input.int(2,      "Min Score to Display (1-3)",      group=grpD, minval=1, maxval=3)
cooldownBars   = input.int(4,      "Signal Cooldown (bars)",          group=grpD)
rthOnly        = input.bool(true,  "RTH Only — Suppress Pre/After Hours", group=grpD,
                 tooltip="When ON, no signals fire before 9:30 AM or after 4:15 PM EST. Eliminates premarket noise.")
trendFilter    = input.bool(true,  "Trend Bias Filter",               group=grpD,
                 tooltip="When ON, counter-trend signals require score 3. With-trend signals pass at score 2. Prevents shorting strong uptrends and longing strong downtrends.")
slopeLB        = input.int(6,      "Trend Slope Lookback (bars)",     group=grpD, minval=3, maxval=20,
                 tooltip="Bars to measure EMA21 slope direction. 6 bars = 30 mins on 5-min chart.")
slopeThreshPct = input.float(0.05, "Trend Slope Threshold (% of price)",  group=grpD, minval=0.01, maxval=0.30, step=0.01,
                 tooltip="Minimum EMA21 move over the lookback to qualify as trending, as a % of price. 0.05% auto-scales to any symbol. This is what raises counter-trend signals to require 3/3 — if it never triggers, fades print at 2/3.")
slopeThresh    = close * slopeThreshPct / 100.0   // derived point threshold — scales with instrument price
showBG         = input.bool(true,  "Background Color on Score 3",     group=grpD)
showEMAPlot    = input.bool(true,  "Plot EMAs on Chart",              group=grpD)
showORBLines   = input.bool(true,  "Plot ORB High/Low Lines",         group=grpD)
show15mORB     = input.bool(true,  "Plot 15-Min ORB Lines (Yellow)",   group=grpD, tooltip="Marks the high and low of the first 15 minutes of RTH as yellow reference lines")

// ─── CORE CALCULATIONS ─────────────────────────────────────────
ema9      = ta.ema(close, emaLen)
ema21     = ta.ema(close, 21)
atrVal    = ta.atr(14)

// ─── TREND BIAS ────────────────────────────────────────────────
// Measure EMA21 slope over lookback — determines intraday trend direction
// Used to raise counter-trend signal threshold to 3/3
emaSlope   = ema21 - ema21[slopeLB]
trendBull  = trendFilter and emaSlope >  slopeThresh   // EMA21 rising — uptrend
trendBear  = trendFilter and emaSlope < -slopeThresh   // EMA21 falling — downtrend
// Counter-trend minimums: shorts need 3 in uptrend, longs need 3 in downtrend
minBullScore = trendBear ? 3 : minScore
minBearScore = trendBull ? 3 : minScore                     // Used for meaningful high/low threshold
avgVol    = ta.sma(volume, 20)
rsi       = ta.rsi(close, rsiLen)
bodySize  = math.abs(close - open)
totalRng  = math.max(high - low, 0.0001)
bodyRatio = bodySize / totalRng
isBull    = close > open
isBear    = close < open

// Centered doji check — body midpoint must sit within center 30% of candle range
// Widened to 35-65% to catch slightly off-center dojis common on 5-min NQ
// Still eliminates clear shooting stars (body 0-25%) and hammers (body 75-100%)
bodyMid    = (open + close) / 2.0
bodyMidPct = totalRng > 0 ? (bodyMid - low) / totalRng : 0.5
isCentered = bodyMidPct >= 0.35 and bodyMidPct <= 0.65
upTrend   = close > ema9  and ema9  > ema21
downTrend = close < ema9  and ema9  < ema21
upperWick = (high - math.max(open, close)) / totalRng
lowerWick = (math.min(open, close) - low)  / totalRng

// ─── EMA AWAY BARS TRACKING ────────────────────────────────────
var int barsAboveEMA = 0
var int barsBelowEMA = 0

if close > ema9
    barsAboveEMA += 1
    barsBelowEMA := 0
else if close < ema9
    barsBelowEMA += 1
    barsAboveEMA := 0
else
    barsAboveEMA := 0
    barsBelowEMA := 0

// ─── PIVOT TRACKING ────────────────────────────────────────────
pivH = ta.pivothigh(high, swingLen, swingLen)
pivL = ta.pivotlow(low,  swingLen, swingLen)

var float lastPH     = na
var float lastPL     = na
var float prev2PH    = na
var float prev2PL    = na
var int   lastPHBar  = 0
var int   lastPLBar  = 0
var int   prev2PHBar = 0
var int   prev2PLBar = 0

if not na(pivH)
    prev2PH    := lastPH
    prev2PHBar := lastPHBar
    lastPH     := pivH
    lastPHBar  := bar_index - swingLen

if not na(pivL)
    prev2PL    := lastPL
    prev2PLBar := lastPLBar
    lastPL     := pivL
    lastPLBar  := bar_index - swingLen

// ─── SESSION / ORB ─────────────────────────────────────────────
isRTH   = not na(time(timeframe.period, rthSession + ":23456", "America/New_York"))
newRTH  = isRTH and not isRTH[1]

// Premarket session detection
isPMSession = not na(time(timeframe.period, pmSession + ":23456", "America/New_York"))
newPMSession = isPMSession and not isPMSession[1]

// Weekly futures open — Sunday 1800 ET (start of the new trading week).
// Triggers a full level reset so Friday's HOD/LOD, fibs, and ORB lines
// can't carry over and keep firing on Sunday evening / overnight.
isSunday = dayofweek(time, "America/New_York") == dayofweek.sunday
newWeek  = isSunday and newPMSession

var float orbHigh   = na
var float orbLow    = na
var bool  orbSet    = false
var int   rthBarCnt = 0
var float orb15High = na
var float orb15Low  = na
var bool  orb15Set  = false
var label lbl15H    = na   // 15m ORB high label (stored so it can be cleared weekly)
var label lbl15L    = na   // 15m ORB low label

// ─── PMH / PML / HOD / LOD state ──────────────────────────────
var float pmHigh    = na   // premarket high (1800-0930 ET)
var float pmLow     = na   // premarket low
var bool  pmLocked  = false  // locks when RTH opens
var float hod       = na   // regular session high of day
var float lod       = na   // regular session low of day
var int   hodBar    = na   // bar_index when the current HOD was last set
var int   lodBar    = na   // bar_index when the current LOD was last set
var label lblPMH    = na
var label lblPML    = na
var label lblHOD    = na
var label lblLOD    = na
var label lblF75    = na
var label lblF618   = na
var label lblF50    = na
var label lblF25    = na

// Connector lines — extend each level out to its floated right-edge tag
var line lnPMH      = na
var line lnPML      = na
var line lnHOD      = na
var line lnLOD      = na
var line lnF75      = na
var line lnF618     = na
var line lnF50      = na
var line lnF25      = na
var line ln15H      = na
var line ln15L      = na

if newRTH
    orbHigh   := na
    orbLow    := na
    orbSet    := false
    rthBarCnt := 0
    orb15High := na
    orb15Low  := na
    orb15Set  := false
    // Lock PM levels when RTH opens — keep them visible all day
    pmLocked  := true
    // Reset HOD/LOD for new RTH session
    hod       := na
    lod       := na
    hodBar    := na
    lodBar    := na

// Reset PM levels when new premarket session begins (after RTH close)
if newPMSession
    pmHigh   := na
    pmLow    := na
    pmLocked := false

// Weekly open (Sun 1800 ET): reset ALL levels for the new trading week.
// Clears the HOD/LOD basis (so fibs go na and stop firing alerts), the
// regular + 15m ORB, and deletes any carried-over fib / 15m ORB labels.
// PM levels are reset separately by the newPMSession block above.
if newWeek
    hod       := na
    lod       := na
    hodBar    := na
    lodBar    := na
    orbHigh   := na
    orbLow    := na
    orbSet    := false
    rthBarCnt := 0
    orb15High := na
    orb15Low  := na
    orb15Set  := false
    if not na(lbl15H)
        label.delete(lbl15H)
        lbl15H := na
    if not na(lbl15L)
        label.delete(lbl15L)
        lbl15L := na
    if not na(lblF75)
        label.delete(lblF75)
        lblF75 := na
    if not na(lblF618)
        label.delete(lblF618)
        lblF618 := na
    if not na(lblF50)
        label.delete(lblF50)
        lblF50 := na
    if not na(lblF25)
        label.delete(lblF25)
        lblF25 := na
    // Delete carried-over connector lines too
    if not na(ln15H)
        line.delete(ln15H)
        ln15H := na
    if not na(ln15L)
        line.delete(ln15L)
        ln15L := na
    if not na(lnF75)
        line.delete(lnF75)
        lnF75 := na
    if not na(lnF618)
        line.delete(lnF618)
        lnF618 := na
    if not na(lnF50)
        line.delete(lnF50)
        lnF50 := na
    if not na(lnF25)
        line.delete(lnF25)
        lnF25 := na

// Build PM High/Low during premarket window
if isPMSession and not pmLocked
    pmHigh := na(pmHigh) ? high : math.max(pmHigh, high)
    pmLow  := na(pmLow)  ? low  : math.min(pmLow,  low)

// Build HOD/LOD during regular session only.
// Record the bar each extreme is set on so we know which leg is most recent:
// HOD newer than LOD = price is in an up-leg (retrace down from the high);
// LOD newer = down-leg (retrace up from the low).
if isRTH
    if na(hod) or high > hod
        hod    := high
        hodBar := bar_index
    if na(lod) or low < lod
        lod    := low
        lodBar := bar_index

if isRTH
    rthBarCnt += 1

orbBarsNeeded  = math.max(1, orbMins / timeframe.multiplier)
orb15BarsNeeded = math.max(1, 15.0   / timeframe.multiplier)
isORBBuilding = isRTH and rthBarCnt <= orbBarsNeeded

if isORBBuilding
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow,  low)

// Build 15-min ORB — use elapsed minutes since RTH open for accuracy
// More reliable than bar counting on CME futures charts
var int   rthOpenTime = 0
if newRTH
    rthOpenTime := time

minsElapsed = rthOpenTime > 0 ? (time - rthOpenTime) / 60000 : 999
orb15Building = isRTH and minsElapsed < 15 and rthOpenTime > 0

if orb15Building
    orb15High := na(orb15High) ? high : math.max(orb15High, high)
    orb15Low  := na(orb15Low)  ? low  : math.min(orb15Low,  low)

if isRTH and minsElapsed >= 15 and not orb15Set and not na(orb15High)
    orb15Set := true

if isRTH and rthBarCnt == orbBarsNeeded + 1 and not orbSet
    orbSet := true

// ══════════════════════════════════════════════════════════════
//  REVERSAL SIGNALS
// ══════════════════════════════════════════════════════════════

// ─── 1. DOJI + ENGULFING ──────────────────────────────────────
prevDoji   = bodyRatio[1] < dojiThresh and isCentered[1]  // body small AND centered within range

// Key level proximity (used for scoring bonus and EMA exceptions)
// Pivot proximity — swing pivots
atSwingRes = not na(lastPH) and math.abs(close - lastPH) / lastPH * 100.0 < keyProxPct
atSwingSup = not na(lastPL) and math.abs(close - lastPL) / lastPL * 100.0 < keyProxPct

// Daily session pivot proximity — PMH, PML, HOD, LOD
nearPMH = showPMLevels and not na(pmHigh) and math.abs(close - pmHigh) / pmHigh * 100.0 < keyProxPct
nearPML = showPMLevels and not na(pmLow)  and math.abs(close - pmLow)  / pmLow  * 100.0 < keyProxPct
nearHOD = showHODLOD   and not na(hod)    and math.abs(close - hod)    / hod    * 100.0 < keyProxPct
nearLOD = showHODLOD   and not na(lod)    and math.abs(close - lod)    / lod    * 100.0 < keyProxPct

atDailyRes = nearPMH or nearHOD  // daily overhead resistance levels
atDailySup = nearPML or nearLOD  // daily support levels

// Combined — swing pivots OR daily session pivots
atResistance = atSwingRes or atDailyRes
atSupport    = atSwingSup or atDailySup

// Pure pattern detection — no trend filter here
// Context handled by EMA gate at display level + scoring
// True doji engulf: confirmation candle must close OUTSIDE the doji's full range
// close < low[1]  = closes below doji's low  (bearish confirmation)
// close > high[1] = closes above doji's high (bullish confirmation)
// Prevents firing when candle stays inside the doji range
bearEngulf = showEngulf and prevDoji and isBear and close < low[1]  and bodySize > bodySize[1]
bullEngulf = showEngulf and prevDoji and isBull and close > high[1] and bodySize > bodySize[1]

// Strong Engulf — no prior doji required
// Large candle fully engulfs prior candle body — valid reversal signal on its own
// Prior candle must be smaller (not itself a strong trend bar)
prevSmall     = bodySize[1] < bodySize * 0.7   // prior body smaller than 70% of current
strongBearEng = showEngulf and isBear and open >= close[1] and close <= open[1] and bodySize > bodySize[1] and prevSmall and not prevDoji
strongBullEng = showEngulf and isBull and open <= close[1] and close >= open[1] and bodySize > bodySize[1] and prevSmall and not prevDoji

// ─── 2. SHOOTING STAR / HAMMER ────────────────────────────────
// Shooting Star: long upper wick, body must be in LOWER portion of candle, at meaningful high
// Hammer:        long lower wick, body must be in UPPER portion of candle, at meaningful low
// Require high/low to exceed prior extreme by meaningful margin (15% of ATR)
// Prevents "barely new high" in uptrend from qualifying
atrMargin = atrVal * 0.15

// Prior bar at meaningful extreme OR at known key level
// The doji bar could be AT resistance without exceeding the prior ATR range
priorBarAtHigh = high[1] > ta.highest(high, recentHiLB)[2] + atrMargin or (not na(lastPH) and math.abs(high[1] - lastPH) / lastPH * 100.0 < keyProxPct)
priorBarAtLow  = low[1]  < ta.lowest(low,   recentHiLB)[2] - atrMargin or (not na(lastPL) and math.abs(low[1]  - lastPL) / lastPL * 100.0 < keyProxPct)

// atHi/atLo: fires at new ATR-margin extreme OR known key level (for shooting star/engulf)
atHi = high > ta.highest(high, recentHiLB)[1] + atrMargin or atResistance
atLo = low  < ta.lowest(low,   recentHiLB)[1] - atrMargin or atSupport

// Strict version — pure ATR-based only, no resistance fallback
// Used for Doji at Extreme signal where no resistance is established yet
atHiStrict = high > ta.highest(high, recentHiLB)[1] + atrMargin
atLoStrict = low  < ta.lowest(low,   recentHiLB)[1] - atrMargin

// Body in lower 35% of range = true shooting star (sellers pushed close back down)
bodyTopInLower  = math.max(open, close) < low + totalRng * 0.35
// Body in upper 35% of range = true hammer (buyers pushed close back up)
bodyBotInUpper  = math.min(open, close) > low + totalRng * 0.65

// Shooting star fires at: meaningful new high (atHi) OR known resistance level
// Hammer fires at: meaningful new low (atLo) OR known support level
// This catches reversals at established key levels even without a new extreme
shootingStar = showShootStar and (atHi or atResistance) and upperWick >= wickRatioMin and bodyTopInLower
hammer       = showShootStar and (atLo or atSupport)    and lowerWick >= wickRatioMin and bodyBotInUpper

// ─── NEW: DOJI AT EXTREME + RSI ──────────────────────────────
// Pure candle + momentum signal — no resistance needed
// Fires when a centered doji forms at a meaningful ATR-based high/low
// AND RSI confirms overbought/oversold momentum warning
// This fires ON the doji bar itself — before any engulf or resistance confirmation
dojiAtHigh = bodyRatio < dojiThresh and isCentered and atHiStrict
dojiAtLow  = bodyRatio < dojiThresh and isCentered and atLoStrict

// ─── 3. VOLUME EXHAUSTION (declining) ────────────────────────
vol4Falling = volume < volume[1] and volume[1] < volume[2] and volume[2] < volume[3]
vol3Falling = volume < volume[1] and volume[1] < volume[2]
volFalling  = volExhBars >= 4 ? vol4Falling : vol3Falling
belowAvgVol = not volExhBelowAvg or volume < avgVol

// Vol exhaust needs meaningful extreme — same ATR margin as shooting star
atRecentHi  = high > ta.highest(high, recentHiLB)[1] + atrMargin
atRecentLo  = low  < ta.lowest(low,   recentHiLB)[1] - atrMargin

// In strong uptrend, vol exhaust bear only fires if at a known resistance level
// Prevents triggering on normal pullback volume in a healthy trend
notStrongUpTrend   = not upTrend or (not na(lastPH) and math.abs(close - lastPH) / lastPH * 100.0 < keyProxPct)
notStrongDownTrend = not downTrend or (not na(lastPL) and math.abs(close - lastPL) / lastPL * 100.0 < keyProxPct)

// Also require bar body is small (showing indecision, not strong trend continuation)
exhaustionBody = bodyRatio < 0.50

volExhBear  = showVolExh and volFalling and belowAvgVol and atRecentHi and exhaustionBody and notStrongUpTrend   and (isBear or bodyRatio < dojiThresh)
volExhBull  = showVolExh and volFalling and belowAvgVol and atRecentLo  and exhaustionBody and notStrongDownTrend and (isBull or bodyRatio < dojiThresh)

// Carry-back ONLY applies when engulf also fires on same bar (specific 3-bar pattern)
// Doji (bar N-1) + Vol Exhaust (bar N-1) + Engulf (bar N) = combo bonus
// Prevents vol exhaust crediting unrelated bars
engulfExhBear = bearEngulf and (volExhBear or volExhBear[1])
engulfExhBull = bullEngulf and (volExhBull or volExhBull[1])

// ─── 4. CLIMACTIC VOLUME SPIKE ────────────────────────────────
// High volume at price extreme = institutional climax reversal
volSpike     = volume >= avgVol * volSpikeMult
// Climactic bear: high volume at meaningful high AND close is bearish or has large upper wick
// Prevents firing on high-volume UP bars that aren't reversals
climaxBear   = showVolSpike and volSpike and atRecentHi and (isBear or upperWick > 0.35)
climaxBull   = showVolSpike and volSpike and atRecentLo  and (isBull or lowerWick  > 0.35)

// ─── 5. CHOCH ─────────────────────────────────────────────────
bearChoch = showChoch and not na(lastPL) and close < lastPL and upTrend
bullChoch = showChoch and not na(lastPH) and close > lastPH and downTrend

// ─── 6. KEY LEVEL REJECTION ───────────────────────────────────
nearLevel(lvl) => not na(lvl) and math.abs(close - lvl) / lvl * 100.0 < keyProxPct
keyRejBear = showKeyLvl and nearLevel(lastPH) and upperWick > 0.35 and isBear
keyRejBull = showKeyLvl and nearLevel(lastPL) and lowerWick  > 0.35 and isBull

// ─── 7. TRENDLINE BREAK ───────────────────────────────────────
tlBarDiffH = lastPHBar - prev2PHBar
tlBarDiffL = lastPLBar - prev2PLBar

tlSlopeH = not na(lastPH) and not na(prev2PH) and tlBarDiffH != 0 ? (lastPH - prev2PH) / tlBarDiffH : na
tlSlopeL = not na(lastPL) and not na(prev2PL) and tlBarDiffL != 0 ? (lastPL - prev2PL) / tlBarDiffL : na
tlValH   = not na(tlSlopeH) ? lastPH + tlSlopeH * (bar_index - lastPHBar) : na
tlValL   = not na(tlSlopeL) ? lastPL + tlSlopeL * (bar_index - lastPLBar) : na

bullTLBreak = showTLBreak and not na(tlValH) and tlSlopeH < 0 and close > tlValH and close[1] <= tlValH
bearTLBreak = showTLBreak and not na(tlValL) and tlSlopeL > 0 and close < tlValL and close[1] >= tlValL

// ══════════════════════════════════════════════════════════════
//  CONTINUATION SIGNALS
// ══════════════════════════════════════════════════════════════

// ─── 8. 9 EMA PULLBACK ────────────────────────────────────────
// EMA touch: low/high enters EMA zone
emaTouchLong  = low  <= ema9 * 1.0015 and close > ema9
emaTouchShort = high >= ema9 * 0.9985 and close < ema9

// Buying/selling pressure confirmation: close must be decisively away from EMA
// after the touch — not just barely crossing it
decBullClose  = close > ema9 * 1.001   // closes at least 0.1% above EMA
decBearClose  = close < ema9 * 0.999   // closes at least 0.1% below EMA

emaPullLong   = showEMA and upTrend   and emaTouchLong  and isBull and decBullClose and barsAboveEMA[1] >= emaAwayBars
emaPullShort  = showEMA and downTrend and emaTouchShort and isBear and decBearClose and barsBelowEMA[1] >= emaAwayBars

// ─── 9. ORB BREAKOUT ──────────────────────────────────────────
volOK    = not volConfirm or volume > avgVol
orbLong  = showORB and orbSet and not na(orbHigh) and close > orbHigh and close[1] <= orbHigh and volOK
orbShort = showORB and orbSet and not na(orbLow)  and close < orbLow  and close[1] >= orbLow  and volOK

// ─── 10. BULL / BEAR FLAG ─────────────────────────────────────
poleUpPct   = (close[5] - close[15]) / math.max(close[15], 1) * 100.0
poleDnPct   = (close[15] - close[5]) / math.max(close[5],  1) * 100.0
hasPoleUp   = poleUpPct > poleMovePct
hasPoleDn   = poleDnPct > poleMovePct
flagRng     = ta.highest(high, 5) - ta.lowest(low, 5)
poleRng     = math.abs(close[5] - close[15])
tightFlag   = flagRng < poleRng * 0.4

bullFlagBrk = showFlag and hasPoleUp and tightFlag and close > ta.highest(high, 5)[1] and volOK
bearFlagBrk = showFlag and hasPoleDn and tightFlag and close < ta.lowest(low,   5)[1] and volOK

// ─── 11. HH / LL STRUCTURE ────────────────────────────────────
newHH = showHHLL and not na(pivH) and not na(lastPH) and not na(prev2PH) and lastPH > prev2PH and upTrend
newLL = showHHLL and not na(pivL) and not na(lastPL) and not na(prev2PL) and lastPL < prev2PL and downTrend

// ══════════════════════════════════════════════════════════════
//  RSI SIGNALS
// ══════════════════════════════════════════════════════════════

// ─── RSI OVERBOUGHT / OVERSOLD ────────────────────────────────
// At reversal extremes — confirms the candle signal with momentum
rsiOverbought  = showRSI and rsi >= rsiOB
rsiOversold    = showRSI and rsi <= rsiOS

// ─── RSI DIVERGENCE ───────────────────────────────────────────
// Bearish divergence: price makes higher high, RSI makes lower high
// Price momentum is fading at the top — confirms reversal signals
priceHH = high  > ta.highest(high, rsiDivLB)[1]   // current bar is new high
rsiLH   = rsi   < ta.highest(rsi,  rsiDivLB)[1]   // but RSI is lower than recent RSI high
bearDiv = showRSI and priceHH and rsiLH and rsi > 50.0  // only meaningful above midline

// Bullish divergence: price makes lower low, RSI makes higher low
// Sellers losing momentum at the bottom — confirms reversal signals
pricLL  = low   < ta.lowest(low, rsiDivLB)[1]     // current bar is new low
rsiHL   = rsi   > ta.lowest(rsi, rsiDivLB)[1]     // but RSI is higher than recent RSI low
bullDiv = showRSI and pricLL and rsiHL and rsi < 50.0   // only meaningful below midline

// ──────────────────────────────────────────────────────────────

// ══════════════════════════════════════════════════════════════
//  SIGNAL COOLDOWN
// ══════════════════════════════════════════════════════════════
var int lastBullBar = -999
var int lastBearBar = -999

bullCooldownOK = bar_index - lastBullBar > cooldownBars
bearCooldownOK = bar_index - lastBearBar > cooldownBars

// ══════════════════════════════════════════════════════════════
//  SCORING
// ══════════════════════════════════════════════════════════════
// Scoring — doji+engulf at meaningful extreme auto-scores 2 (complete reversal setup)
// priorBarAtHigh/Low = the doji bar was at a genuine new extreme by ATR margin
// This handles spike tops/bottoms where pivot confirmation lags by swingLen bars
// ─── FIBONACCI LEVELS ─────────────────────────────────────────
// Calculated from HOD/LOD — auto-updates as session extremes change
fibRange = not na(hod) and not na(lod) ? hod - lod : na
// Direction of the current leg, from which extreme is most recent.
// fibUp  = up-leg  (LOD → HOD): retrace measured DOWN from the high,
//          so .25/.50 sit near the top and .618/.75 near the bottom.
// !fibUp = down-leg (HOD → LOD): retrace measured UP from the low,
//          so .618/.75 sit near the top and .25/.50 near the bottom.
// Defaults to up when not yet established (start of session).
fibUp    = na(hodBar) or na(lodBar) ? true : hodBar >= lodBar
fib25    = not na(fibRange) ? (fibUp ? hod - fibRange * 0.250 : lod + fibRange * 0.250) : na
fib50    = not na(fibRange) ? (fibUp ? hod - fibRange * 0.500 : lod + fibRange * 0.500) : na
fib618   = not na(fibRange) ? (fibUp ? hod - fibRange * 0.618 : lod + fibRange * 0.618) : na
fib75    = not na(fibRange) ? (fibUp ? hod - fibRange * 0.750 : lod + fibRange * 0.750) : na

// Plots — colors track each fib ratio (.25 red, .50 green, .618 teal, .75 aqua).
// The interior levels reverse vertical order when the leg flips direction, so
// we plot them by physical tier (top → bottom) and color per ratio. This keeps
// the fills shading between vertically-adjacent levels in both orientations.
fibTier1 = fibUp ? fib25  : fib75    // highest interior level (nearest HOD)
fibTier2 = fibUp ? fib50  : fib618
fibTier3 = fibUp ? fib618 : fib50
fibTier4 = fibUp ? fib75  : fib25    // lowest interior level (nearest LOD)
cTier1   = fibUp ? color.red   : color.aqua
cTier2   = fibUp ? color.green : color.teal
cTier3   = fibUp ? color.teal  : color.green
cTier4   = fibUp ? color.aqua  : color.red

p_fib0   = plot(showFibs and not na(hod)      ? hod      : na, "Fib 0.0",  color=color.new(color.gray, 20), linewidth=1, style=plot.style_linebr)
p_t1     = plot(showFibs and not na(fibTier1) ? fibTier1 : na, "Fib hi",   color=color.new(cTier1, 0), linewidth=1, style=plot.style_linebr)
p_t2     = plot(showFibs and not na(fibTier2) ? fibTier2 : na, "Fib u-mid",color=color.new(cTier2, 0), linewidth=1, style=plot.style_linebr)
p_t3     = plot(showFibs and not na(fibTier3) ? fibTier3 : na, "Fib l-mid",color=color.new(cTier3, 0), linewidth=1, style=plot.style_linebr)
p_t4     = plot(showFibs and not na(fibTier4) ? fibTier4 : na, "Fib lo",   color=color.new(cTier4, 0), linewidth=1, style=plot.style_linebr)
p_fib1   = plot(showFibs and not na(lod)      ? lod      : na, "Fib 1.0",  color=color.new(color.gray, 20), linewidth=1, style=plot.style_linebr)

// Fills between vertically-adjacent levels — 2% opacity (98% transparent)
fill(p_fib0, p_t1, color=color.new(color.red,    98))
fill(p_t1,   p_t2, color=color.new(color.orange, 98))
fill(p_t2,   p_t3, color=color.new(color.green,  98))
fill(p_t3,   p_t4, color=color.new(color.teal,   98))
fill(p_t4, p_fib1, color=color.new(color.aqua,   98))

// ─── FIB PROXIMITY & CONFLUENCE ──────────────────────────────
// Price proximity to each fib level (absolute NQ points)
nearFib75  = showFibs and not na(fib75)  and math.abs(close - fib75)  < fibProxPoints
nearFib618 = showFibs and not na(fib618) and math.abs(close - fib618) < fibProxPoints
nearFib50  = showFibs and not na(fib50)  and math.abs(close - fib50)  < fibProxPoints
nearFib25  = showFibs and not na(fib25)  and math.abs(close - fib25)  < fibProxPoints
atAnyFib   = nearFib75 or nearFib618 or nearFib50 or nearFib25

// Fib-to-pivot confluence: is this fib level within 20pts of another established pivot?
// When a fib aligns with PMH/PML/HOD/LOD/swing pivot = stronger level
fibPivotCheck(fibLvl) =>
    not na(fibLvl) and (
    (not na(pmHigh) and math.abs(fibLvl - pmHigh) < fibProxPoints) or
    (not na(pmLow)  and math.abs(fibLvl - pmLow)  < fibProxPoints) or
    (not na(hod)    and math.abs(fibLvl - hod)     < fibProxPoints) or
    (not na(lod)    and math.abs(fibLvl - lod)     < fibProxPoints) or
    (not na(lastPH) and math.abs(fibLvl - lastPH)  < fibProxPoints) or
    (not na(lastPL) and math.abs(fibLvl - lastPL)  < fibProxPoints))

// Any nearby fib that also aligns with another pivot = confluent level
fibIsConfluent = (nearFib75  and fibPivotCheck(fib75))  or
                 (nearFib618 and fibPivotCheck(fib618)) or
                 (nearFib50  and fibPivotCheck(fib50))  or
                 (nearFib25  and fibPivotCheck(fib25))

// Add the physically-upper fibs to resistance, lower fibs to support, so
// existing keyRejBear/Bull, EMA exceptions etc. also fire at fib levels.
// Which ratios sit on top depends on the leg direction:
//   up-leg   → .25/.50 are upper (resistance), .618/.75 lower (support)
//   down-leg → .75/.618 are upper (resistance), .50/.25 lower (support)
if fibUp
    atResistance := atResistance or nearFib25  or nearFib50
    atSupport    := atSupport    or nearFib618 or nearFib75
else
    atResistance := atResistance or nearFib75  or nearFib618
    atSupport    := atSupport    or nearFib50  or nearFib25

// Daily pivot level confluence — +1 when reversal candle fires at PMH/PML/HOD/LOD
atDailyResSignal = atDailyRes and (shootingStar or bearEngulf or strongBearEng or bodyRatio < dojiThresh)
atDailySapSignal = atDailySup and (hammer or bullEngulf or strongBullEng or bodyRatio < dojiThresh)

bearEngulfScore = bearEngulf ? (priorBarAtHigh or atResistance ? 2 : 1) : 0
bullEngulfScore = bullEngulf ? (priorBarAtLow  or atSupport    ? 2 : 1) : 0


bearRaw = bearEngulfScore      + (shootingStar    ? 1 : 0) +
          (strongBearEng ? 1 : 0) + (volExhBear   ? 1 : 0) +
          (engulfExhBear ? 1 : 0) + (climaxBear   ? 1 : 0) +
          (bearChoch     ? 1 : 0) + (keyRejBear   ? 1 : 0) +
          (bearTLBreak   ? 1 : 0) + (emaPullShort ? 1 : 0) +
          (orbShort      ? 1 : 0) + (bearFlagBrk  ? 1 : 0) +
          (newLL         ? 1 : 0) + (rsiOverbought? 1 : 0) +
          (bearDiv       ? 1 : 0) + (dojiAtHigh   ? 1 : 0) +
          (atDailyResSignal ? 1 : 0) +
          (atAnyFib and (shootingStar or bearEngulf or strongBearEng or bodyRatio < dojiThresh) ? 1 : 0) +
          (fibIsConfluent and isBear ? 1 : 0)

bullRaw = bullEngulfScore      + (hammer          ? 1 : 0) +
          (strongBullEng ? 1 : 0) + (volExhBull    ? 1 : 0) +
          (engulfExhBull ? 1 : 0) + (climaxBull    ? 1 : 0) +
          (bullChoch     ? 1 : 0) + (keyRejBull    ? 1 : 0) +
          (bullTLBreak   ? 1 : 0) + (emaPullLong   ? 1 : 0) +
          (orbLong       ? 1 : 0) + (bullFlagBrk   ? 1 : 0) +
          (newHH         ? 1 : 0) + (rsiOversold   ? 1 : 0) +
          (bullDiv       ? 1 : 0) +
          (dojiAtLow     ? 1 : 0) +
          (atAnyFib and (hammer or bullEngulf or strongBullEng or bodyRatio < dojiThresh) ? 1 : 0) +
          (fibIsConfluent and isBull ? 1 : 0)

// ─── PMH / PML / HOD / LOD PLOTS ─────────────────────────────
plot(showPMLevels and not na(pmHigh) ? pmHigh : na, "PM High", color=color.white, linewidth=1, style=plot.style_linebr)
plot(showPMLevels and not na(pmLow)  ? pmLow  : na, "PM Low",  color=color.white, linewidth=1, style=plot.style_linebr)
plot(showHODLOD   and not na(hod)    ? hod    : na, "HOD",     color=color.white, linewidth=1, style=plot.style_linebr)
plot(showHODLOD   and not na(lod)    ? lod    : na, "LOD",     color=color.white, linewidth=1, style=plot.style_linebr)

// Labels — update on last bar so they stay at right edge
// Draw/update a horizontal connector from the last candle (x1) out to the
// floated tag (x2) at the level's y value. Created once, repositioned after.
drawConn(line ln, int x1, int x2, float y, color c) =>
    line result = ln
    if na(result)
        result := line.new(x1, y, x2, y, color=c, width=1)
    else
        line.set_xy1(result, x1, y)
        line.set_xy2(result, x2, y)
        line.set_color(result, c)
    result

if barstate.islast
    xLvl = bar_index + lvlLabelOffset   // right-edge anchor for daily/ORB tags
    xFib = bar_index + fibLabelOffset   // right-edge anchor for fib tags
    // PMH label + connector
    if showPMLevels and not na(pmHigh)
        if na(lblPMH)
            lblPMH := label.new(xLvl, pmHigh, "PMH  " + str.tostring(pmHigh, "#.00"),
                 style=label.style_label_left, color=color.new(color.white, 15),
                 textcolor=color.black, size=size.small)
        else
            label.set_xy(lblPMH, xLvl, pmHigh)
            label.set_text(lblPMH, "PMH  " + str.tostring(pmHigh, "#.00"))
        lnPMH := drawConn(lnPMH, bar_index, xLvl, pmHigh, color.new(color.white, 50))
    // PML label + connector
    if showPMLevels and not na(pmLow)
        if na(lblPML)
            lblPML := label.new(xLvl, pmLow, "PML  " + str.tostring(pmLow, "#.00"),
                 style=label.style_label_left, color=color.new(color.white, 15),
                 textcolor=color.black, size=size.small)
        else
            label.set_xy(lblPML, xLvl, pmLow)
            label.set_text(lblPML, "PML  " + str.tostring(pmLow, "#.00"))
        lnPML := drawConn(lnPML, bar_index, xLvl, pmLow, color.new(color.white, 50))
    // Fib labels + connectors
    if showFibs and not na(fib75)
        if na(lblF75)
            lblF75 := label.new(xFib, fib75, "0.75  " + str.tostring(fib75, "#.00"),
                 style=label.style_label_left, color=color.new(color.aqua, 20),
                 textcolor=color.black, size=size.small)
        else
            label.set_xy(lblF75, xFib, fib75)
            label.set_text(lblF75, "0.75  " + str.tostring(fib75, "#.00"))
        lnF75 := drawConn(lnF75, bar_index, xFib, fib75, color.new(color.aqua, 40))
    if showFibs and not na(fib618)
        if na(lblF618)
            lblF618 := label.new(xFib, fib618, "0.618  " + str.tostring(fib618, "#.00"),
                 style=label.style_label_left, color=color.new(color.teal, 20),
                 textcolor=color.black, size=size.small)
        else
            label.set_xy(lblF618, xFib, fib618)
            label.set_text(lblF618, "0.618  " + str.tostring(fib618, "#.00"))
        lnF618 := drawConn(lnF618, bar_index, xFib, fib618, color.new(color.teal, 40))
    if showFibs and not na(fib50)
        if na(lblF50)
            lblF50 := label.new(xFib, fib50, "0.5  " + str.tostring(fib50, "#.00"),
                 style=label.style_label_left, color=color.new(color.green, 20),
                 textcolor=color.black, size=size.small)
        else
            label.set_xy(lblF50, xFib, fib50)
            label.set_text(lblF50, "0.5  " + str.tostring(fib50, "#.00"))
        lnF50 := drawConn(lnF50, bar_index, xFib, fib50, color.new(color.green, 40))
    if showFibs and not na(fib25)
        if na(lblF25)
            lblF25 := label.new(xFib, fib25, "0.25  " + str.tostring(fib25, "#.00"),
                 style=label.style_label_left, color=color.new(color.red, 20),
                 textcolor=color.black, size=size.small)
        else
            label.set_xy(lblF25, xFib, fib25)
            label.set_text(lblF25, "0.25  " + str.tostring(fib25, "#.00"))
        lnF25 := drawConn(lnF25, bar_index, xFib, fib25, color.new(color.red, 40))

    // HOD label + connector
    if showHODLOD and not na(hod)
        if na(lblHOD)
            lblHOD := label.new(xLvl, hod, "HOD  " + str.tostring(hod, "#.00"),
                 style=label.style_label_left, color=color.new(color.white, 15),
                 textcolor=color.black, size=size.small)
        else
            label.set_xy(lblHOD, xLvl, hod)
            label.set_text(lblHOD, "HOD  " + str.tostring(hod, "#.00"))
        lnHOD := drawConn(lnHOD, bar_index, xLvl, hod, color.new(color.white, 50))
    // LOD label + connector
    if showHODLOD and not na(lod)
        if na(lblLOD)
            lblLOD := label.new(xLvl, lod, "LOD  " + str.tostring(lod, "#.00"),
                 style=label.style_label_left, color=color.new(color.white, 15),
                 textcolor=color.black, size=size.small)
        else
            label.set_xy(lblLOD, xLvl, lod)
            label.set_text(lblLOD, "LOD  " + str.tostring(lod, "#.00"))
        lnLOD := drawConn(lnLOD, bar_index, xLvl, lod, color.new(color.white, 50))

    // 15m ORB labels + connectors — follow price to the right edge like the others
    if show15mORB and orb15Set and not na(orb15High)
        if na(lbl15H)
            lbl15H := label.new(xLvl, orb15High, "15m H: " + str.tostring(orb15High, "#.00"),
                 style=label.style_label_left, color=color.new(color.yellow, 10),
                 textcolor=color.black, size=size.small)
        else
            label.set_xy(lbl15H, xLvl, orb15High)
            label.set_text(lbl15H, "15m H: " + str.tostring(orb15High, "#.00"))
        ln15H := drawConn(ln15H, bar_index, xLvl, orb15High, color.new(color.yellow, 40))
    if show15mORB and orb15Set and not na(orb15Low)
        if na(lbl15L)
            lbl15L := label.new(xLvl, orb15Low, "15m L: " + str.tostring(orb15Low, "#.00"),
                 style=label.style_label_left, color=color.new(color.yellow, 10),
                 textcolor=color.black, size=size.small)
        else
            label.set_xy(lbl15L, xLvl, orb15Low)
            label.set_text(lbl15L, "15m L: " + str.tostring(orb15Low, "#.00"))
        ln15L := drawConn(ln15L, bar_index, xLvl, orb15Low, color.new(color.yellow, 40))

plot(showORBLines and orbSet  ? orbHigh   : na, "ORB High",     color=color.new(color.yellow, 20), linewidth=1, style=plot.style_linebr)
plot(showORBLines and orbSet  ? orbLow    : na, "ORB Low",      color=color.new(color.yellow, 20), linewidth=1, style=plot.style_linebr)
p15High = plot(show15mORB and orb15Set ? orb15High : na, "15m ORB High", color=color.new(color.yellow, 0), linewidth=2, style=plot.style_linebr)
p15Low  = plot(show15mORB and orb15Set ? orb15Low  : na, "15m ORB Low",  color=color.new(color.yellow, 0), linewidth=2, style=plot.style_linebr)

// 15m ORB tags are drawn in the barstate.islast block above so they float at
// the right edge with the other level tags (see lbl15H / lbl15L there).

// ══════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════

bullScore = math.min(bullRaw, 3)
bearScore = math.min(bearRaw, 3)

// ─── EMA GATE EXCEPTIONS ──────────────────────────────────────
// Doji + Engulf at a key extreme bypasses the EMA gate
// These are the highest conviction reversal signals — resistance top or support bottom
// The doji bar itself is the "at extreme" bar; the engulf fires 1 bar later
// So check whether the PRIOR bar (the doji) was at a meaningful extreme
// Also allow exception when engulf fires directly at a known key level
// EMA gate exception covers both doji+engulf AND strong engulf at extremes
engulfExceptBear = (bearEngulf or strongBearEng) and (atResistance or priorBarAtHigh)
engulfExceptBull = (bullEngulf or strongBullEng) and (atSupport    or priorBarAtLow)

// Doji at extreme + RSI also bypasses EMA gate — pure candle+momentum reversal
dojiRSIExceptBear = dojiAtHigh and rsiOverbought
dojiRSIExceptBull = dojiAtLow  and rsiOversold

// Global EMA gate with doji+engulf exception at key extremes
// Optional RSI divergence gate
divGateBull = not rsiDivRequired or bullDiv
divGateBear = not rsiDivRequired or bearDiv

// Volume breakout gate — signal candle must show elevated volume vs prior candle
// Filters out low-conviction signals where volume didn't confirm the move
volBreakoutOK = not requireBreakoutVol or volume > volume[1] * (1.0 + volBreakoutPct / 100.0)

// RTH gate — suppress signals outside regular trading hours when enabled
rthGate = not rthOnly or isRTH

showBull = bullScore >= minBullScore and bullRaw > 0 and bullCooldownOK and rthGate and divGateBull and volBreakoutOK and (close > ema9 or engulfExceptBull or dojiRSIExceptBull)
showBear = bearScore >= minBearScore and bearRaw > 0 and bearCooldownOK and rthGate and divGateBear and volBreakoutOK and (close < ema9 or engulfExceptBear or dojiRSIExceptBear)

if showBull
    lastBullBar := bar_index
if showBear
    lastBearBar := bar_index

// ══════════════════════════════════════════════════════════════
//  SIGNAL TEXT
// ══════════════════════════════════════════════════════════════
bullText() =>
    t = ""
    t := bullEngulf        ? t + (priorBarAtLow or atSupport ? "Doji+Engulf[2] " : "Doji+Engulf ") : t
    t := strongBullEng     ? t + "StrongEngulf "  : t
    t := hammer            ? t + "Hammer "      : t
    t := engulfExhBull     ? t + "Engulf+Exh "  : t
    t := volExhBull        ? t + "Vol Exhaust " : t
    t := climaxBull        ? t + "Clim.Vol "    : t
    t := bullChoch         ? t + "CHoCH↑ "     : t
    t := keyRejBull        ? t + "Key Level "  : t
    t := bullTLBreak       ? t + "TL Break "   : t
    t := emaPullLong       ? t + "EMA Pull "   : t
    t := orbLong           ? t + "ORB↑ "      : t
    t := bullFlagBrk       ? t + "Flag↑ "     : t
    t := newHH             ? t + "New HH "    : t
    t := dojiAtLow         ? t + "DojiExtreme " : t
    t := atDailySapSignal  ? t + (nearLOD ? "LOD " : nearPML ? "PML " : "DailyLvl ") : t
    t := atAnyFib and isBull ? t + (nearFib25 ? "Fib.25@" + str.tostring(fib25, "#.00") + " " : nearFib50 ? "Fib.50@" + str.tostring(fib50, "#.00") + " " : nearFib618 ? "Fib.618@" + str.tostring(fib618, "#.00") + " " : "Fib.75@" + str.tostring(fib75, "#.00") + " ") : t
    t := fibIsConfluent and isBull ? t + "FibConfl " : t
    t := rsiOversold       ? t + "RSI OS "    : t
    t := bullDiv           ? t + "RSI Div↑ "  : t
    t

bearText() =>
    t = ""
    t := bearEngulf        ? t + (priorBarAtHigh or atResistance ? "Doji+Engulf[2] " : "Doji+Engulf ") : t
    t := strongBearEng     ? t + "StrongEngulf "  : t
    t := shootingStar      ? t + "Shoot.Star "  : t
    t := engulfExhBear     ? t + "Engulf+Exh "  : t
    t := volExhBear        ? t + "Vol Exhaust " : t
    t := climaxBear        ? t + "Clim.Vol "    : t
    t := bearChoch         ? t + "CHoCH↓ "     : t
    t := keyRejBear        ? t + "Key Level "  : t
    t := bearTLBreak       ? t + "TL Break "   : t
    t := emaPullShort      ? t + "EMA Pull "   : t
    t := orbShort          ? t + "ORB↓ "      : t
    t := bearFlagBrk       ? t + "Flag↓ "     : t
    t := newLL             ? t + "New LL "    : t
    t := dojiAtHigh        ? t + "DojiExtreme " : t
    t := atDailyResSignal  ? t + (nearHOD ? "HOD " : nearPMH ? "PMH " : "DailyLvl ") : t
    t := atAnyFib and isBear ? t + (nearFib75 ? "Fib.75@" + str.tostring(fib75, "#.00") + " " : nearFib618 ? "Fib.618@" + str.tostring(fib618, "#.00") + " " : nearFib50 ? "Fib.50@" + str.tostring(fib50, "#.00") + " " : "Fib.25@" + str.tostring(fib25, "#.00") + " ") : t
    t := fibIsConfluent and isBear ? t + "FibConfl " : t
    t := rsiOverbought     ? t + "RSI OB "    : t
    t := bearDiv           ? t + "RSI Div↓ "  : t
    t

// ══════════════════════════════════════════════════════════════
//  DISPLAY
// ══════════════════════════════════════════════════════════════
if showBull
    sc   = str.tostring(bullScore)
    txt  = "▲ LONG  [" + sc + "/3]\n" + bullText()
    bClr = bullScore == 3 ? color.new(color.green, 5) : bullScore == 2 ? color.new(color.green, 30) : color.new(color.green, 55)
    label.new(bar_index, low * 0.9994, txt, style=label.style_label_up,   color=bClr, textcolor=color.white, size=size.small)

if showBear
    sc   = str.tostring(bearScore)
    txt  = "▼ SHORT [" + sc + "/3]\n" + bearText()
    bClr = bearScore == 3 ? color.new(color.red, 5) : bearScore == 2 ? color.new(color.red, 30) : color.new(color.red, 55)
    label.new(bar_index, high * 1.0006, txt, style=label.style_label_down, color=bClr, textcolor=color.white, size=size.small)

plotshape(showBull and bullScore == 1, "Bull S1", shape.triangleup,   location.belowbar, color.new(color.green, 20), size=size.small)
plotshape(showBull and bullScore == 2, "Bull S2", shape.triangleup,   location.belowbar, color.new(color.green,  5), size=size.normal)
plotshape(showBull and bullScore == 3, "Bull S3", shape.triangleup,   location.belowbar, color.new(color.green,  0), size=size.large)
plotshape(showBear and bearScore == 1, "Bear S1", shape.triangledown, location.abovebar, color.new(color.red,   20), size=size.small)
plotshape(showBear and bearScore == 2, "Bear S2", shape.triangledown, location.abovebar, color.new(color.red,    5), size=size.normal)
plotshape(showBear and bearScore == 3, "Bear S3", shape.triangledown, location.abovebar, color.new(color.red,    0), size=size.large)

bgcolor(showBG and bullScore == 3 and bullCooldownOK ? color.new(color.green, 90) : showBG and bearScore == 3 and bearCooldownOK ? color.new(color.red, 90) : na)
// Subtle trend bias backdrop — very faint so it doesn't clutter
bgcolor(trendFilter and trendBull ? color.new(color.green, 97) : trendFilter and trendBear ? color.new(color.red, 97) : na, title="Trend Bias Background")

// RSI plot (separate pane when enabled - add to new pane in chart settings)

// ══════════════════════════════════════════════════════════════
//  ALERTS
// ══════════════════════════════════════════════════════════════
// ── PREMARKET SIGNALS (bypass RTH gate) ─────────────────────
// Same scoring/filters but fires outside RTH for premarket alerts
// Requires score >= 2, all other filters active, just no RTH restriction
showBullPM = bullScore >= minBullScore and bullRaw > 0 and bullCooldownOK and not isRTH and divGateBull and volBreakoutOK and (close > ema9 or engulfExceptBull or dojiRSIExceptBull)
showBearPM = bearScore >= minBearScore and bearRaw > 0 and bearCooldownOK and not isRTH and divGateBear and volBreakoutOK and (close < ema9 or engulfExceptBear or dojiRSIExceptBear)

alertcondition(showBullPM, title="⚡ Premarket Long Signal",  message="{{ticker}} PREMARKET LONG at {{close}} — low size, let it run. Check chart for score and fib levels.")
alertcondition(showBearPM, title="⚡ Premarket Short Signal", message="{{ticker}} PREMARKET SHORT at {{close}} — low size, let it run. Check chart for score and fib levels.")
alertcondition(showBullPM and bullScore == 3, title="⚡ Premarket Long 3/3",  message="{{ticker}} PREMARKET LONG 3/3 at {{close}} — high conviction premarket setup.")
alertcondition(showBearPM and bearScore == 3, title="⚡ Premarket Short 3/3", message="{{ticker}} PREMARKET SHORT 3/3 at {{close}} — high conviction premarket setup.")

// ── ANY SIGNAL — use this one for audio alerts ──────────────
// Fires whenever a signal passes ALL active filters:
// score threshold, EMA gate, volume filter, RSI div gate, cooldown
alertcondition(showBull or showBear,
     title   = "⚡ Any Signal (Bull or Bear)",
     message = "{{ticker}} Signal fired at {{close}} — check chart for direction and score.")

alertcondition(showBull,
     title   = "⚡ Any Long Signal",
     message = "{{ticker}} LONG signal at {{close}} — check chart for score and details.")

alertcondition(showBear,
     title   = "⚡ Any Short Signal",
     message = "{{ticker}} SHORT signal at {{close}} — check chart for score and details.")

alertcondition(showBull and bullScore >= 2, title="Bull Confluence 2+",          message="{{ticker}} LONG setup — Score 2+. Check chart.")
alertcondition(showBear and bearScore >= 2, title="Bear Confluence 2+",          message="{{ticker}} SHORT setup — Score 2+. Check chart.")
alertcondition(showBull and bullScore == 3, title="HIGH CONVICTION Long (3/3)",  message="{{ticker}} HIGH CONVICTION LONG — Score 3/3.")
alertcondition(showBear and bearScore == 3, title="HIGH CONVICTION Short (3/3)", message="{{ticker}} HIGH CONVICTION SHORT — Score 3/3.")
alertcondition(shootingStar or climaxBear,  title="Momentum Reversal Top",       message="{{ticker}} Shooting Star or Climactic Volume at high.")
alertcondition(hammer or climaxBull,        title="Momentum Reversal Bottom",    message="{{ticker}} Hammer or Climactic Volume at low.")
alertcondition(bearChoch or bullChoch,      title="CHoCH Structure Break",       message="{{ticker}} Change of Character — potential trend reversal.")
alertcondition(orbLong or orbShort,         title="ORB Breakout",                message="{{ticker}} ORB breakout detected.")
alertcondition(bearDiv,  title="RSI Bearish Divergence", message="{{ticker}} RSI Bearish Divergence — price new high, RSI lower high.")
alertcondition(bullDiv,  title="RSI Bullish Divergence",  message="{{ticker}} RSI Bullish Divergence — price new low, RSI higher low.")
````
