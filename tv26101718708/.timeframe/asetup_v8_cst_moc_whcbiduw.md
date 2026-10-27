# A-Setup v8 CST + MOC

- url: https://www.tradingview.com/script/WhcBIduW-A-Setup-v8-CST-MOC/
- type: indicator
- pine_id: PUB;5be00eead5ef4e22891eb91003cfce45
- version: 3.0

## Description

═══════════════════════════════════════════════════════════
A-SETUP v8 — MULTI-CONFLUENCE PATTERN SCANNER
═══════════════════════════════════════════════════════════

A scoring-based intraday signal system that only fires when 
multiple independent conditions align. Built for traders who 
want fewer, higher-quality entries instead of constant noise.

───────────────────────────────────────────────────────────
HOW IT WORKS
───────────────────────────────────────────────────────────

Every bar is scored 0–6 on six independent bullish (or bearish)
conditions. A signal only fires if BOTH a high score AND a
confirmed candlestick pattern are present, AND the signal is
outside a cooldown period, AND the bar falls within an allowed
trading window.

THE 6 SCORING CONDITIONS

1. EMA stack alignment (9 > 21 > 50 bullish, reverse for bearish)
2. Price vs VWAP (above with VWAP rising = bullish)
3. Higher-timeframe trend agreement (configurable, default 60min)
4. RSI in trend zone (40–65 bullish, 35–60 bearish)
5. MACD aligned with histogram expanding
6. Volume above 1.5x its 20-period average (with optional
   "expanding volume" requirement)

THE 4 PATTERN FILTERS

A signal additionally requires one of these patterns:

- Bullish/Bearish Engulfing — body fully covers previous candle
- Hammer / Shooting Star — long wick + small body
- Breakout / Breakdown — close beyond 10-bar swing high/low
- Bounce / Rejection — touched key level + strong reversal close

This combination of scoring + pattern dramatically reduces
false signals compared to indicator-only systems.

───────────────────────────────────────────────────────────
SIGNAL TIERS
───────────────────────────────────────────────────────────

🟢 A SETUP — score 6/6 + pattern (premium, rare)
🟢 B SETUP — score 5/6 + pattern (good, more frequent)
🌙 MOC — end-of-day momentum signal (last 20 min before close)
💰 SELL — automatic exit on target, stop, or trend flip

───────────────────────────────────────────────────────────
SUPPORT & RESISTANCE LEVELS
───────────────────────────────────────────────────────────

11 levels are auto-detected and used for confluence:
- Previous Day High / Low / Close
- Previous Week High / Low
- Previous Month High / Low (toggleable)
- 52-Week High / Low (toggleable)
- Current Day High / Low
- Pre-Market High / Low (configurable session)
- Opening Range High / Low (configurable session)
- Last Swing High / Low (configurable lookback)
- Daily Pivots P / R1 / S1 (toggleable)

Plus EMA 21 and VWAP as dynamic levels.

A signal only fires near a confluence level — not in the
middle of a range.

───────────────────────────────────────────────────────────
TIME-OF-DAY FILTER (CST DEFAULT)
───────────────────────────────────────────────────────────

The script blocks signals during low-quality time windows
that historically produce more whipsaws:

❌ 8:30–9:00 AM CST (opening chop)
❌ 11:30 AM–12:30 PM CST (lunch)
❌ 1:30–2:30 PM CST (afternoon positioning)
✅ 9:00–11:30 AM CST (PRIME WINDOW)
✅ 12:30–1:30 PM CST (afternoon trend)
🌙 2:30–2:50 PM CST (MOC WINDOW)

All filters are toggleable via inputs. Sessions are configured
in CST by default but the underlying logic uses the
"America/Chicago" timezone, so it works correctly regardless
of your chart's display timezone. Adjust session strings to
your local market if trading non-US instruments.

───────────────────────────────────────────────────────────
DASHBOARD
───────────────────────────────────────────────────────────

A live status table in the top-right shows:
- Current CST time
- Active window (PRIME / OPEN / LUNCH / LATE / MOC)
- Trend direction with score
- Bull and Bear scores (0–6)
- RSI, MACD, Volume status
- S/R proximity
- HTF agreement
- Detected pattern
- Current ACTION (BUY CALL / BUY PUT / IN POSITION / WAIT)
- Live price

This lets you read system state at a glance without
interpreting individual indicators.

───────────────────────────────────────────────────────────
RIGHT-SIDE PRICE LABELS
───────────────────────────────────────────────────────────

Every key level has a persistent label to the right of the
current bar so you always know where major levels are
without manually drawing them.

───────────────────────────────────────────────────────────
RECOMMENDED USAGE
───────────────────────────────────────────────────────────

- TIMEFRAME: 5-minute (primary). 15-minute as a confirmation
  chart. Not optimized for 1-min or 30+ min — adjust cooldown
  and EMA periods if you want to use other timeframes.

- INSTRUMENTS: Liquid index ETFs (SPY, QQQ), large-cap stocks
  with active options (NVDA, AMD, PLTR, TSLA, META, AMZN),
  and futures (ES, NQ).

- MULTI-TIMEFRAME RULE: For best results, only take a 5-min
  signal if the 15-min chart shows the same trend direction.

- ENTRY: Wait for the labeled bar to close before entering.
  Repainting is minimized but not zero on intrabar levels.

- EXIT: Built-in target (1.5R default) and stop logic. SELL
  labels also fire on trend flip.

───────────────────────────────────────────────────────────
KEY INPUTS YOU CAN TUNE
───────────────────────────────────────────────────────────

- Volume Multiplier (default 1.5) — lower for more signals
- Level Proximity % (default 0.15) — wider catches more setups
- Cooldown Bars (default 12) — increase for fewer signals
- HTF Timeframe (default 60) — set to higher for more strict
- R:R Exit (default 1.5) — change to your preferred ratio
- Pattern toggles — enable/disable individual patterns
- Time filter toggles — disable for 24/7 markets like crypto
- Session windows — adjust for your market's open hours

───────────────────────────────────────────────────────────
ALERTS
───────────────────────────────────────────────────────────

8 alert conditions are exposed:
🟢 A CALL  /  🟢 B CALL  /  🌙 MOC CALL
🔴 A PUT   /  🔴 B PUT   /  🌙 MOC PUT
💰 SELL CALL  /  💰 SELL PUT

Right-click any signal arrow → "Add alert on..." to set up
notifications for the specific tier you want.

───────────────────────────────────────────────────────────
IMPORTANT NOTES
───────────────────────────────────────────────────────────

This indicator is a research and decision-support tool, not
an automated trading system. It does not predict outcomes.
Signals are based on historical conditions and patterns; past
performance does not guarantee future results.

This is NOT financial advice. Always do your own analysis,
size positions according to your own risk tolerance, and
consider consulting a licensed financial advisor before
trading. Options trading carries significant risk including
total loss of premium.

The author makes no claims about win rates or profitability.
Backtest the script in your specific market and timeframe
before risking real capital.

───────────────────────────────────────────────────────────
CHANGELOG
───────────────────────────────────────────────────────────

v8 — CST timezone integration, MOC end-of-day signal tier,
     time-of-day filter, expanded dashboard
v7 — Pattern matching, cooldown logic, A/B tier separation
v6 — Tiered scoring system (A/B/C signals)
v5 — Full S/R level set with right-side labels
v4 — Removed strict session restrictions
v3 — Persistent right-side level labels
v2 — Light pastel color scheme
v1 — Initial release

───────────────────────────────────────────────────────────
CREDITS
───────────────────────────────────────────────────────────

Built using standard Pine Script v6 functions. No external
libraries. All logic is open source and visible in the code.

If you find this useful, a like and comment helps others
discover it. Feedback and suggestions welcome.

═══════════════════════════════════════════════════════════

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © saivivek0192

//@version=6
indicator("A-Setup v9.3 + Wyckoff", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=500)

// ============================================================
// ============== INPUTS ======================================
// ============================================================
showEMAs    = input.bool(true,  "EMAs (9/21/50)",       group="📊 Display")
showVWAP    = input.bool(true,  "VWAP",                 group="📊 Display")
showPD      = input.bool(true,  "Prev Day H/L/C",       group="📊 Display")
showWk      = input.bool(true,  "Prev Week H/L",        group="📊 Display")
showDayHL   = input.bool(true,  "Current Day H/L",      group="📊 Display")
showSessHL  = input.bool(true,  "Pre-Session H/L",      group="📊 Display")
showOR      = input.bool(true,  "Opening Range",        group="📊 Display")
showSwings  = input.bool(true,  "Swing H/L",            group="📊 Display")
showTPSL    = input.bool(true,  "TP/SL lines on active trade", group="📊 Display")
showRevWarn = input.bool(true,  "Reversal warnings on chart",  group="📊 Display")

showA       = input.bool(true, "A-Setup (6/6 + pattern + trend)", group="🎯 Signals")
showB       = input.bool(true, "B-Setup (4-5/6 + pattern + 2-of-3 trend)", group="🎯 Signals")
showMOC     = input.bool(true, "MOC end-of-day",                  group="🎯 Signals")
strictMode  = input.bool(true, "Trend agreement filter (2 of 3)", group="🎯 Signals")
cooldownBars = input.int(8, "Cooldown bars between signals",      minval=3, group="🎯 Signals")

volMult     = input.float(1.5, "Volume multiplier",     group="🔧 Logic", step=0.1)
volExpand   = input.bool(true, "Require expanding volume", group="🔧 Logic")
levelProx   = input.float(0.15,"Level proximity %",     group="🔧 Logic", step=0.05)
swingLen    = input.int(10,    "Swing detection bars",  group="🔧 Logic")
useHTF      = input.bool(true, "HTF trend filter",      group="🔧 Logic")
htfTF       = input.timeframe("60", "HTF timeframe",    group="🔧 Logic")

useATR      = input.bool(true, "ATR-based dynamic stops", group="💰 Risk")
atrLen      = input.int(14,   "ATR length",              group="💰 Risk")
atrStopMult = input.float(1.5,"ATR stop multiplier",     group="💰 Risk", step=0.1)
tp1RR       = input.float(1.0,"TP1 R:R (partial exit)",  group="💰 Risk", step=0.1)
tp2RR       = input.float(2.0,"TP2 R:R (full exit)",     group="💰 Risk", step=0.1)
useTimeStop = input.bool(true,"Time stop after N bars",  group="💰 Risk")
timeStopBars = input.int(12,  "Time stop bars",          group="💰 Risk")

patEngulf   = input.bool(true, "Engulfing",       group="🕯️ Patterns")
patHammer   = input.bool(true, "Hammer/Star",     group="🕯️ Patterns")
patBreak    = input.bool(true, "Breakout/down",   group="🕯️ Patterns")
patBounce   = input.bool(true, "Bounce/Reject",   group="🕯️ Patterns")
patWyckoff  = input.bool(true, "Wyckoff Spring/Upthrust", group="🕯️ Patterns")
wyckoffLookback = input.int(10, "Wyckoff lookback bars", minval=5, maxval=20, group="🕯️ Patterns")

sessionPre  = input.session("0300-0830", "Pre-Market (CST)",     group="🕒 Sessions (CST)")
sessionOR   = input.session("0830-0930", "Opening Range (CST)",  group="🕒 Sessions (CST)")
sessionMOC  = input.session("1430-1450", "MOC Window (CST)",     group="🕒 Sessions (CST)")

useTimeFilter = input.bool(true, "Block bad windows",            group="🚫 Time Filter (CST)")
blockOpen     = input.bool(true, "Block 8:30-9:00 AM open chop", group="🚫 Time Filter (CST)")
blockLunch    = input.bool(true, "Block 11:30 AM-12:30 PM lunch", group="🚫 Time Filter (CST)")
blockLateAft  = input.bool(true, "Block 1:30-2:30 PM late",       group="🚫 Time Filter (CST)")

// ============================================================
// ============== COLORS ======================================
// ============================================================
cText   = #ECEFF4
cEma9   = #5EBAA8
cEma21  = #E8C547
cEma50  = #E07856
cVwap   = #8E7CC3
cPD     = #6FA8DC
cWk     = #76C8B5
cPM     = #B19CD9
cOR     = #93C572
cDay    = #E5B17F
cSwing  = #A8C5E8
cA_Bull = #00C853
cA_Bear = #D50000
cB_Bull = #4CAF50
cB_Bear = #E53935
cMOC_Bl = #2196F3
cMOC_Br = #FF6F00
cTP     = #00ACC1
cSL     = #B71C1C
cBE     = #FFA726
cRev    = #FFEB3B
cWyBull = #00E676
cWyBear = #FF1744

// ============================================================
// ============== INDICATORS ==================================
// ============================================================
emaFast = ta.ema(close, 9)
emaMid  = ta.ema(close, 21)
emaSlow = ta.ema(close, 50)
rsiVal  = ta.rsi(close, 14)
[macdLine, signalLine, histLine] = ta.macd(close, 12, 26, 9)

atrVal = ta.atr(atrLen)

volMa = ta.sma(volume, 20)
volOk = volume >= volMa * volMult
volExpanding = volume > volume[1] and volume[1] > volume[2]
volQualified = volExpand ? (volOk and volExpanding) : volOk

vwapVal = ta.vwap(hlc3)
vwapUp  = vwapVal > vwapVal[3]
vwapDn  = vwapVal < vwapVal[3]

htfFast = request.security(syminfo.tickerid, htfTF, ta.ema(close, 9),  lookahead=barmerge.lookahead_off)
htfMid  = request.security(syminfo.tickerid, htfTF, ta.ema(close, 21), lookahead=barmerge.lookahead_off)
htfSlow = request.security(syminfo.tickerid, htfTF, ta.ema(close, 50), lookahead=barmerge.lookahead_off)
htfBull = htfFast > htfMid and htfMid > htfSlow
htfBear = htfFast < htfMid and htfMid < htfSlow

// ============================================================
// ============== CST TIME LOGIC ==============================
// ============================================================
hourCST = hour(time, "America/Chicago")
minCST  = minute(time, "America/Chicago")
timeMin = hourCST * 60 + minCST

inOpenChop = blockOpen     and timeMin >= 510 and timeMin < 540
inLunch    = blockLunch    and timeMin >= 690 and timeMin < 750
inLateAft  = blockLateAft  and timeMin >= 810 and timeMin < 870
inGoodWindow = not useTimeFilter or (not inOpenChop and not inLunch and not inLateAft)

inMOCWindow = not na(time(timeframe.period, sessionMOC))

// ============================================================
// ============== LEVELS ======================================
// ============================================================
isNewDay = ta.change(time("D")) != 0

prevDayHigh  = request.security(syminfo.tickerid, "D", high[1],  lookahead=barmerge.lookahead_on)
prevDayLow   = request.security(syminfo.tickerid, "D", low[1],   lookahead=barmerge.lookahead_on)
prevDayClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
prevWkHigh   = request.security(syminfo.tickerid, "W", high[1],  lookahead=barmerge.lookahead_on)
prevWkLow    = request.security(syminfo.tickerid, "W", low[1],   lookahead=barmerge.lookahead_on)

var float dayHigh = na
var float dayLow  = na
if isNewDay
    dayHigh := high
    dayLow  := low
else
    dayHigh := na(dayHigh) ? high : math.max(dayHigh, high)
    dayLow  := na(dayLow)  ? low  : math.min(dayLow,  low)

inPreSession = not na(time(timeframe.period, sessionPre))
var float preHigh = na
var float preLow  = na
if isNewDay
    preHigh := na
    preLow  := na
if inPreSession
    preHigh := na(preHigh) ? high : math.max(preHigh, high)
    preLow  := na(preLow)  ? low  : math.min(preLow,  low)

inORWindow = not na(time(timeframe.period, sessionOR))
var float orHigh = na
var float orLow  = na
if isNewDay
    orHigh := na
    orLow  := na
if inORWindow
    orHigh := na(orHigh) ? high : math.max(orHigh, high)
    orLow  := na(orLow)  ? low  : math.min(orLow,  low)

swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low,  swingLen, swingLen)
var float lastSwingHigh = na
var float lastSwingLow  = na
if not na(swingHigh)
    lastSwingHigh := swingHigh
if not na(swingLow)
    lastSwingLow := swingLow

recentHigh = ta.highest(high[1], 10)
recentLow  = ta.lowest(low[1], 10)

// ============================================================
// ============== PATTERN DETECTION ===========================
// ============================================================
bodySize    = math.abs(close - open)
candleRange = high - low
upperWick   = high - math.max(open, close)
lowerWick   = math.min(open, close) - low
bodyPct     = candleRange > 0 ? bodySize / candleRange : 0

bullishEngulfing = patEngulf and close[1] < open[1] and close > open and close > open[1] and open <= close[1] and bodySize > bodySize[1]
bearishEngulfing = patEngulf and close[1] > open[1] and close < open and close < open[1] and open >= close[1] and bodySize > bodySize[1]

isHammer       = patHammer and lowerWick > bodySize * 2 and upperWick < bodySize * 0.5 and bodyPct < 0.4 and close >= open
isShootingStar = patHammer and upperWick > bodySize * 2 and lowerWick < bodySize * 0.5 and bodyPct < 0.4 and close <= open

isBreakout  = patBreak and close > recentHigh and close > open and bodyPct > 0.5
isBreakdown = patBreak and close < recentLow  and close < open and bodyPct > 0.5

nearLong(lvl) =>
    not na(lvl) and low <= lvl * (1 + levelProx/100) and low >= lvl * (1 - levelProx/100)
nearShort(lvl) =>
    not na(lvl) and high >= lvl * (1 - levelProx/100) and high <= lvl * (1 + levelProx/100)

touchedSupport = nearLong(prevDayLow) or nearLong(prevDayClose) or nearLong(dayLow) or nearLong(emaMid) or nearLong(vwapVal) or nearLong(prevWkLow) or nearLong(preLow) or nearLong(orLow) or nearLong(lastSwingLow)
touchedResistance = nearShort(prevDayHigh) or nearShort(prevDayClose) or nearShort(dayHigh) or nearShort(emaMid) or nearShort(vwapVal) or nearShort(prevWkHigh) or nearShort(preHigh) or nearShort(orHigh) or nearShort(lastSwingHigh)

isBounce    = patBounce and touchedSupport    and close > open and bodyPct > 0.55 and close > (high + low) / 2
isRejection = patBounce and touchedResistance and close < open and bodyPct > 0.55 and close < (high + low) / 2

// ============================================================
// ============== WYCKOFF SPRING / UPTHRUST ===================
// ============================================================
recentLowLevel  = ta.lowest(low[1],  wyckoffLookback)
recentHighLevel = ta.highest(high[1], wyckoffLookback)

sweptLow  = low < recentLowLevel
sweptHigh = high > recentHighLevel

var bool pendingSpring = false
var bool pendingUpthrust = false
var float springLevel = na
var float upthrustLevel = na
var int sweepBarSpring = 0
var int sweepBarUpthrust = 0

if sweptLow and not pendingSpring
    pendingSpring := true
    springLevel := recentLowLevel
    sweepBarSpring := bar_index

if sweptHigh and not pendingUpthrust
    pendingUpthrust := true
    upthrustLevel := recentHighLevel
    sweepBarUpthrust := bar_index

isSpring = patWyckoff and pendingSpring and (bar_index - sweepBarSpring <= 3) and close > springLevel and close > open and volQualified
isUpthrust = patWyckoff and pendingUpthrust and (bar_index - sweepBarUpthrust <= 3) and close < upthrustLevel and close < open and volQualified

// Capture levels for label display BEFORE reset
displaySpringLevel = isSpring ? springLevel : na
displayUpthrustLevel = isUpthrust ? upthrustLevel : na

if isSpring or (pendingSpring and bar_index - sweepBarSpring > 3)
    pendingSpring := false
    springLevel := na

if isUpthrust or (pendingUpthrust and bar_index - sweepBarUpthrust > 3)
    pendingUpthrust := false
    upthrustLevel := na

// ============================================================
// ============== COMBINED PATTERN STACK ======================
// ============================================================
bullPattern = bullishEngulfing or isHammer or isBreakout or isBounce or isSpring
bearPattern = bearishEngulfing or isShootingStar or isBreakdown or isRejection or isUpthrust

bullPatternName = isSpring ? "★ SPRING" : bullishEngulfing ? "Engulf" : isBreakout ? "Breakout" : isBounce ? "Bounce" : isHammer ? "Hammer" : ""
bearPatternName = isUpthrust ? "★ UPTHRUST" : bearishEngulfing ? "Engulf" : isBreakdown ? "Breakdn" : isRejection ? "Reject" : isShootingStar ? "ShootStar" : ""

// ============================================================
// ============== SCORING SYSTEM ==============================
// ============================================================
emaBull        = emaFast > emaMid and emaMid > emaSlow
emaBear        = emaFast < emaMid and emaMid < emaSlow
priceAboveVwap = close > vwapVal
priceBelowVwap = close < vwapVal

rsiBullOk = rsiVal >= 40 and rsiVal <= 65
rsiBearOk = rsiVal >= 35 and rsiVal <= 60

macdBullOk = macdLine > signalLine and histLine > histLine[1]
macdBearOk = macdLine < signalLine and histLine < histLine[1]

bullScore = 0
bullScore := bullScore + (emaBull ? 1 : 0)
bullScore := bullScore + (priceAboveVwap and vwapUp ? 1 : 0)
bullScore := bullScore + ((not useHTF) or htfBull ? 1 : 0)
bullScore := bullScore + (rsiBullOk ? 1 : 0)
bullScore := bullScore + (macdBullOk ? 1 : 0)
bullScore := bullScore + (volQualified ? 1 : 0)

bearScore = 0
bearScore := bearScore + (emaBear ? 1 : 0)
bearScore := bearScore + (priceBelowVwap and vwapDn ? 1 : 0)
bearScore := bearScore + ((not useHTF) or htfBear ? 1 : 0)
bearScore := bearScore + (rsiBearOk ? 1 : 0)
bearScore := bearScore + (macdBearOk ? 1 : 0)
bearScore := bearScore + (volQualified ? 1 : 0)

trendBullCount = (emaBull ? 1 : 0) + (priceAboveVwap ? 1 : 0) + (((not useHTF) or htfBull) ? 1 : 0)
trendBearCount = (emaBear ? 1 : 0) + (priceBelowVwap ? 1 : 0) + (((not useHTF) or htfBear) ? 1 : 0)
trendBull = trendBullCount >= 2
trendBear = trendBearCount >= 2

// ============================================================
// ============== SIGNAL TIERS ================================
// ============================================================
var int lastCallBar = -9999
var int lastPutBar  = -9999
var int lastMOCBar  = -9999

cooldownCallOk = bar_index - lastCallBar >= cooldownBars
cooldownPutOk  = bar_index - lastPutBar  >= cooldownBars
cooldownMOCOk  = bar_index - lastMOCBar  >= cooldownBars

trendOkBull = strictMode ? trendBull : true
trendOkBear = strictMode ? trendBear : true

rawACall = bullScore == 6 and bullPattern and trendOkBull and cooldownCallOk and showA and inGoodWindow and not inMOCWindow
rawAPut  = bearScore == 6 and bearPattern and trendOkBear and cooldownPutOk and showA and inGoodWindow and not inMOCWindow

rawBCall = bullScore >= 4 and bullScore <= 5 and bullPattern and trendOkBull and cooldownCallOk and showB and inGoodWindow and not inMOCWindow and not rawACall
rawBPut  = bearScore >= 4 and bearScore <= 5 and bearPattern and trendOkBear and cooldownPutOk and showB and inGoodWindow and not inMOCWindow and not rawAPut

clearOverhead   = na(prevDayHigh) or close < prevDayHigh * 0.998
clearUnderneath = na(prevDayLow)  or close > prevDayLow  * 1.002

mocCall = showMOC and inMOCWindow and bullScore >= 4 and bullPattern and trendOkBull and volQualified and clearOverhead and cooldownMOCOk
mocPut  = showMOC and inMOCWindow and bearScore >= 4 and bearPattern and trendOkBear and volQualified and clearUnderneath and cooldownMOCOk

finalACall = rawACall
finalBCall = rawBCall
finalAPut  = rawAPut
finalBPut  = rawBPut
finalMOCCall = mocCall and not finalACall and not finalBCall
finalMOCPut  = mocPut  and not finalAPut  and not finalBPut

if finalACall or finalBCall
    lastCallBar := bar_index
if finalAPut or finalBPut
    lastPutBar := bar_index
if finalMOCCall or finalMOCPut
    lastMOCBar := bar_index

// ============================================================
// ============== ADAPTIVE EXIT MANAGEMENT ====================
// ============================================================
var float callEntry  = na
var float callStop   = na
var float callTP1    = na
var float callTP2    = na
var bool  inCall     = false
var bool  callTP1Hit = false
var int   callBars   = 0
var string callTier  = ""

var float putEntry  = na
var float putStop   = na
var float putTP1    = na
var float putTP2    = na
var bool  inPut     = false
var bool  putTP1Hit = false
var int   putBars   = 0
var string putTier  = ""

if inCall
    callBars := callBars + 1
if inPut
    putBars := putBars + 1

if (finalACall or finalBCall or finalMOCCall) and not inCall
    callEntry := close
    if useATR
        callStop := close - atrVal * atrStopMult
    else
        callStop := math.min(low, low[1], emaMid) * 0.998
    riskC = callEntry - callStop
    callTP1 := callEntry + riskC * tp1RR
    callTP2 := callEntry + riskC * tp2RR
    inCall := true
    callTP1Hit := false
    callBars := 0
    callTier := finalACall ? "A" : finalBCall ? "B" : "MOC"

if (finalAPut or finalBPut or finalMOCPut) and not inPut
    putEntry := close
    if useATR
        putStop := close + atrVal * atrStopMult
    else
        putStop := math.max(high, high[1], emaMid) * 1.002
    riskP = putStop - putEntry
    putTP1 := putEntry - riskP * tp1RR
    putTP2 := putEntry - riskP * tp2RR
    inPut := true
    putTP1Hit := false
    putBars := 0
    putTier := finalAPut ? "A" : finalBPut ? "B" : "MOC"

tp1HitCall = inCall and high >= callTP1 and not callTP1Hit
tp1HitPut  = inPut  and low  <= putTP1  and not putTP1Hit

if tp1HitCall
    callTP1Hit := true
    callStop := callEntry

if tp1HitPut
    putTP1Hit := true
    putStop := putEntry

strongBearReversal = emaBear and priceBelowVwap and bearPattern
strongBullReversal = emaBull and priceAboveVwap and bullPattern

timeStopCallHit = useTimeStop and callBars >= timeStopBars
timeStopPutHit  = useTimeStop and putBars  >= timeStopBars

sellCall = inCall and (high >= callTP2 or low <= callStop or strongBearReversal or timeStopCallHit)
sellPut  = inPut  and (low  <= putTP2  or high >= putStop  or strongBullReversal or timeStopPutHit)

if sellCall
    inCall := false
    callTier := ""
    callTP1Hit := false
    callBars := 0
if sellPut
    inPut := false
    putTier := ""
    putTP1Hit := false
    putBars := 0

// ============================================================
// ============== REVERSAL DETECTION ==========================
// ============================================================
revWarnInCall = inCall and bearScore >= 4 and bearPattern and (priceBelowVwap or emaBear)
revWarnInPut  = inPut  and bullScore >= 4 and bullPattern and (priceAboveVwap or emaBull)

recentPutFired = bar_index - lastPutBar < 20
recentCallFired = bar_index - lastCallBar < 20
bullReversalZone = not inCall and not inPut and recentPutFired and bullScore >= 4 and bullPattern and trendBull and inGoodWindow
bearReversalZone = not inCall and not inPut and recentCallFired and bearScore >= 4 and bearPattern and trendBear and inGoodWindow

// ============================================================
// ============== PLOTS — MAIN INDICATORS =====================
// ============================================================
plot(showEMAs ? emaFast : na, "EMA 9",  color=cEma9,  linewidth=1)
plot(showEMAs ? emaMid  : na, "EMA 21", color=cEma21, linewidth=1)
plot(showEMAs ? emaSlow : na, "EMA 50", color=cEma50, linewidth=2)
plot(showVWAP ? vwapVal : na, "VWAP",   color=cVwap,  linewidth=2)

plot(showPD ? prevDayHigh  : na, "PDH", color=cPD, linewidth=1, style=plot.style_circles)
plot(showPD ? prevDayLow   : na, "PDL", color=cPD, linewidth=1, style=plot.style_circles)
plot(showPD ? prevDayClose : na, "PDC", color=color.new(cPD, 50), linewidth=1)
plot(showWk ? prevWkHigh : na, "PWH", color=cWk, linewidth=1)
plot(showWk ? prevWkLow  : na, "PWL", color=cWk, linewidth=1)
plot(showDayHL ? dayHigh : na, "Day H", color=cDay, linewidth=1)
plot(showDayHL ? dayLow  : na, "Day L", color=cDay, linewidth=1)
plot(showSessHL ? preHigh : na, "Pre H", color=cPM, linewidth=1)
plot(showSessHL ? preLow  : na, "Pre L", color=cPM, linewidth=1)
plot(showOR ? orHigh : na, "OR H", color=cOR, linewidth=1)
plot(showOR ? orLow  : na, "OR L", color=cOR, linewidth=1)
plot(showSwings ? lastSwingHigh : na, "Swing H", color=cSwing, linewidth=1)
plot(showSwings ? lastSwingLow  : na, "Swing L", color=cSwing, linewidth=1)

plot(showTPSL and inCall ? callTP1 : na, "Call TP1", color=cTP, linewidth=2, style=plot.style_linebr)
plot(showTPSL and inCall ? callTP2 : na, "Call TP2", color=color.new(cTP, 30), linewidth=2, style=plot.style_linebr)
plot(showTPSL and inCall ? callStop : na, "Call SL", color=callTP1Hit ? cBE : cSL, linewidth=2, style=plot.style_linebr)

plot(showTPSL and inPut ? putTP1 : na, "Put TP1", color=cTP, linewidth=2, style=plot.style_linebr)
plot(showTPSL and inPut ? putTP2 : na, "Put TP2", color=color.new(cTP, 30), linewidth=2, style=plot.style_linebr)
plot(showTPSL and inPut ? putStop : na, "Put SL", color=putTP1Hit ? cBE : cSL, linewidth=2, style=plot.style_linebr)

bgcolor(finalACall ? color.new(cA_Bull, 70) : finalBCall ? color.new(cB_Bull, 80) : finalMOCCall ? color.new(cMOC_Bl, 78) : na, title="Call BG")
bgcolor(finalAPut  ? color.new(cA_Bear, 70) : finalBPut  ? color.new(cB_Bear, 80) : finalMOCPut  ? color.new(cMOC_Br, 78) : na, title="Put BG")
bgcolor(inMOCWindow ? color.new(#2196F3, 96) : na, title="MOC Window Tint")
bgcolor(sellCall or sellPut ? color.new(#FFA726, 75) : na, title="Sell Flash")
bgcolor(tp1HitCall or tp1HitPut ? color.new(cBE, 88) : na, title="TP1 Hit")
bgcolor(showRevWarn and (revWarnInCall or revWarnInPut) ? color.new(cRev, 88) : na, title="Reversal Warning")
bgcolor(showRevWarn and (bullReversalZone or bearReversalZone) ? color.new(cRev, 92) : na, title="Reversal Zone")
bgcolor(isSpring ? color.new(cWyBull, 80) : na, title="Spring BG")
bgcolor(isUpthrust ? color.new(cWyBear, 80) : na, title="Upthrust BG")

// ============================================================
// ============== SIGNAL LABELS ===============================
// ============================================================
patStrCall = bullPatternName != "" ? " · " + bullPatternName : ""
patStrPut  = bearPatternName != "" ? " · " + bearPatternName : ""

if finalACall
    label.new(bar_index, low, "▲ A CALL  " + str.tostring(close, "#.##") + patStrCall + "\nTP1 " + str.tostring(callTP1, "#.##") + " · TP2 " + str.tostring(callTP2, "#.##"), style=label.style_label_up, color=cA_Bull, textcolor=color.white, size=size.normal, yloc=yloc.belowbar)
else if finalBCall
    label.new(bar_index, low, "▲ B CALL  " + str.tostring(close, "#.##") + patStrCall + "\nScore " + str.tostring(bullScore) + "/6", style=label.style_label_up, color=cB_Bull, textcolor=color.white, size=size.small, yloc=yloc.belowbar)
else if finalMOCCall
    label.new(bar_index, low, "● MOC CALL  " + str.tostring(close, "#.##") + patStrCall, style=label.style_label_up, color=cMOC_Bl, textcolor=color.white, size=size.normal, yloc=yloc.belowbar)

if finalAPut
    label.new(bar_index, high, "▼ A PUT  " + str.tostring(close, "#.##") + patStrPut + "\nTP1 " + str.tostring(putTP1, "#.##") + " · TP2 " + str.tostring(putTP2, "#.##"), style=label.style_label_down, color=cA_Bear, textcolor=color.white, size=size.normal, yloc=yloc.abovebar)
else if finalBPut
    label.new(bar_index, high, "▼ B PUT  " + str.tostring(close, "#.##") + patStrPut + "\nScore " + str.tostring(bearScore) + "/6", style=label.style_label_down, color=cB_Bear, textcolor=color.white, size=size.small, yloc=yloc.abovebar)
else if finalMOCPut
    label.new(bar_index, high, "● MOC PUT  " + str.tostring(close, "#.##") + patStrPut, style=label.style_label_down, color=cMOC_Br, textcolor=color.white, size=size.normal, yloc=yloc.abovebar)

if tp1HitCall
    label.new(bar_index, high, "✓ TP1 · BE", style=label.style_label_down, color=cBE, textcolor=color.white, size=size.small, yloc=yloc.abovebar)
if tp1HitPut
    label.new(bar_index, low, "✓ TP1 · BE", style=label.style_label_up, color=cBE, textcolor=color.white, size=size.small, yloc=yloc.belowbar)

if sellCall
    reason = high >= callTP2 ? "TP2 ✓" : low <= callStop ? (callTP1Hit ? "BE ✓" : "SL") : strongBearReversal ? "Flip" : "Time"
    label.new(bar_index, high, "$ EXIT CALL · " + reason + "\n" + str.tostring(close, "#.##"), style=label.style_label_down, color=#FFA726, textcolor=color.white, size=size.normal, yloc=yloc.abovebar)
if sellPut
    reason = low <= putTP2 ? "TP2 ✓" : high >= putStop ? (putTP1Hit ? "BE ✓" : "SL") : strongBullReversal ? "Flip" : "Time"
    label.new(bar_index, low, "$ EXIT PUT · " + reason + "\n" + str.tostring(close, "#.##"), style=label.style_label_up, color=#FFA726, textcolor=color.white, size=size.normal, yloc=yloc.belowbar)

// Wyckoff standalone visual markers
if isSpring and not (finalACall or finalBCall or finalMOCCall)
    label.new(bar_index, low, "★ SPRING\n" + str.tostring(displaySpringLevel, "#.##"), style=label.style_label_up, color=color.new(cWyBull, 0), textcolor=#000000, size=size.small, yloc=yloc.belowbar)

if isUpthrust and not (finalAPut or finalBPut or finalMOCPut)
    label.new(bar_index, high, "★ UPTHRUST\n" + str.tostring(displayUpthrustLevel, "#.##"), style=label.style_label_down, color=color.new(cWyBear, 0), textcolor=#FFFFFF, size=size.small, yloc=yloc.abovebar)

// Reversal warning labels
if showRevWarn and revWarnInCall
    label.new(bar_index, high, "⚠ REVERSAL\nExit CALL?", style=label.style_label_down, color=cRev, textcolor=#1A1A1A, size=size.small, yloc=yloc.abovebar)
if showRevWarn and revWarnInPut
    label.new(bar_index, low, "⚠ REVERSAL\nExit PUT?", style=label.style_label_up, color=cRev, textcolor=#1A1A1A, size=size.small, yloc=yloc.belowbar)
if showRevWarn and bullReversalZone
    label.new(bar_index, low, "↗ BULL REV ZONE\nWatch for entry", style=label.style_label_up, color=color.new(cB_Bull, 30), textcolor=color.white, size=size.small, yloc=yloc.belowbar)
if showRevWarn and bearReversalZone
    label.new(bar_index, high, "↘ BEAR REV ZONE\nWatch for entry", style=label.style_label_down, color=color.new(cB_Bear, 30), textcolor=color.white, size=size.small, yloc=yloc.abovebar)

// ============================================================
// ============== RIGHT-SIDE PRICE LABELS =====================
// ============================================================
var label lblPdh = na, var label lblPdl = na, var label lblPdc = na
var label lblPwh = na, var label lblPwl = na
var label lblDyH = na, var label lblDyL = na
var label lblPreH = na, var label lblPreL = na
var label lblOrH = na, var label lblOrL = na
var label lblSwH = na, var label lblSwL = na
var label lblE9 = na, var label lblE21 = na, var label lblE50 = na
var label lblVw = na

f_lbl(lbl, cond, x, y, txt, col) =>
    if cond and not na(y)
        if na(lbl)
            label.new(x, y, txt, style=label.style_label_left, color=col, textcolor=cText, size=size.small, xloc=xloc.bar_index)
        else
            label.set_xy(lbl, x, y), label.set_text(lbl, txt), label.set_color(lbl, col)
            lbl
    else
        lbl

if barstate.islast
    rx = bar_index + 3
    if showPD
        lblPdh := f_lbl(lblPdh, true, rx, prevDayHigh,  "PDH " + str.tostring(prevDayHigh, "#.##"),  color.new(cPD, 25))
        lblPdl := f_lbl(lblPdl, true, rx, prevDayLow,   "PDL " + str.tostring(prevDayLow, "#.##"),   color.new(cPD, 25))
        lblPdc := f_lbl(lblPdc, true, rx, prevDayClose, "PDC " + str.tostring(prevDayClose, "#.##"), color.new(cPD, 50))
    if showWk
        lblPwh := f_lbl(lblPwh, true, rx, prevWkHigh, "PWH " + str.tostring(prevWkHigh, "#.##"), color.new(cWk, 25))
        lblPwl := f_lbl(lblPwl, true, rx, prevWkLow,  "PWL " + str.tostring(prevWkLow, "#.##"),  color.new(cWk, 25))
    if showDayHL
        lblDyH := f_lbl(lblDyH, true, rx, dayHigh, "DH " + str.tostring(dayHigh, "#.##"), color.new(cDay, 25))
        lblDyL := f_lbl(lblDyL, true, rx, dayLow,  "DL " + str.tostring(dayLow, "#.##"),  color.new(cDay, 25))
    if showSessHL
        lblPreH := f_lbl(lblPreH, true, rx, preHigh, "PreH " + str.tostring(preHigh, "#.##"), color.new(cPM, 25))
        lblPreL := f_lbl(lblPreL, true, rx, preLow,  "PreL " + str.tostring(preLow, "#.##"),  color.new(cPM, 25))
    if showOR
        lblOrH := f_lbl(lblOrH, true, rx, orHigh, "ORH " + str.tostring(orHigh, "#.##"), color.new(cOR, 25))
        lblOrL := f_lbl(lblOrL, true, rx, orLow,  "ORL " + str.tostring(orLow, "#.##"),  color.new(cOR, 25))
    if showSwings
        lblSwH := f_lbl(lblSwH, true, rx, lastSwingHigh, "SwH " + str.tostring(lastSwingHigh, "#.##"), color.new(cSwing, 25))
        lblSwL := f_lbl(lblSwL, true, rx, lastSwingLow,  "SwL " + str.tostring(lastSwingLow, "#.##"),  color.new(cSwing, 25))
    if showEMAs
        lblE9  := f_lbl(lblE9,  true, rx, emaFast, "9 "  + str.tostring(emaFast, "#.##"), color.new(cEma9, 25))
        lblE21 := f_lbl(lblE21, true, rx, emaMid,  "21 " + str.tostring(emaMid, "#.##"),  color.new(cEma21, 25))
        lblE50 := f_lbl(lblE50, true, rx, emaSlow, "50 " + str.tostring(emaSlow, "#.##"), color.new(cEma50, 25))
    if showVWAP
        lblVw := f_lbl(lblVw, true, rx, vwapVal, "VWAP " + str.tostring(vwapVal, "#.##"), color.new(cVwap, 25))

// ============================================================
// ============== DASHBOARD ===================================
// ============================================================
var table dash = table.new(position.top_right, 2, 16, bgcolor=color.new(#1A1F2E, 10), border_width=1, border_color=color.new(#2C3E50, 50), frame_color=color.new(#2C3E50, 50), frame_width=2)

cHeader = color.new(#34495E, 0)
cCellBg = color.new(#2C3E50, 60)

if barstate.islast
    cstStr = str.format("{0,number,00}:{1,number,00}", hourCST, minCST)

    timeStatus = inMOCWindow ? "MOC ●"     : inOpenChop ? "OPEN ✗"  : inLunch ? "LUNCH ✗" : inLateAft ? "LATE ✗"  : inGoodWindow ? "PRIME ✓" : "—"
    timeCol = inMOCWindow ? cMOC_Bl : (inOpenChop or inLunch or inLateAft) ? color.gray : cB_Bull

    trendStr = bullScore >= 5 ? "▲ STRONG BULL" : bullScore == 4 ? "▲ Bull" : bearScore >= 5 ? "▼ STRONG BEAR" : bearScore == 4 ? "▼ Bear" : "— Chop"
    trendCol = bullScore >= 5 ? cA_Bull : bullScore == 4 ? cB_Bull : bearScore >= 5 ? cA_Bear : bearScore == 4 ? cB_Bear : color.gray

    patStr = bullPatternName != "" ? "▲ " + bullPatternName : bearPatternName != "" ? "▼ " + bearPatternName : "—"
    patCol = isSpring ? cWyBull : isUpthrust ? cWyBear : bullPatternName != "" ? cB_Bull : bearPatternName != "" ? cB_Bear : color.gray

    actionStr = inCall ? "● IN " + callTier + " CALL" : inPut ? "● IN " + putTier + " PUT" : finalACall ? "▲ A CALL" : finalBCall ? "▲ B CALL" : finalMOCCall ? "● MOC CALL" : finalAPut ? "▼ A PUT" : finalBPut ? "▼ B PUT" : finalMOCPut ? "● MOC PUT" : "WAIT"
    actionCol = inCall or finalACall or finalBCall or finalMOCCall ? cB_Bull : inPut or finalAPut or finalBPut or finalMOCPut ? cB_Bear : color.new(color.gray, 30)

    revStr = revWarnInCall ? "⚠ EXIT CALL" : revWarnInPut ? "⚠ EXIT PUT" : bullReversalZone ? "↗ BULL ZONE" : bearReversalZone ? "↘ BEAR ZONE" : "—"
    revCol = revWarnInCall or revWarnInPut ? cRev : bullReversalZone ? cB_Bull : bearReversalZone ? cB_Bear : color.gray

    wyStr = isSpring ? "★ SPRING" : isUpthrust ? "★ UPTHRUST" : pendingSpring ? "Sweep ↓ pending" : pendingUpthrust ? "Sweep ↑ pending" : "—"
    wyCol = isSpring ? cWyBull : isUpthrust ? cWyBear : pendingSpring or pendingUpthrust ? cRev : color.gray

    table.cell(dash, 0, 0, "TIME (CST)", text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 0, cstStr,        text_color=cText, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 1, "WINDOW",      text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 1, timeStatus,    text_color=timeCol, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 2, "TREND",       text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 2, trendStr,      text_color=trendCol, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 3, "BULL",        text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 3, str.tostring(bullScore) + "/6", text_color=bullScore >= 5 ? cA_Bull : bullScore >= 4 ? cB_Bull : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 4, "BEAR",        text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 4, str.tostring(bearScore) + "/6", text_color=bearScore >= 5 ? cA_Bear : bearScore >= 4 ? cB_Bear : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 5, "RSI",         text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 5, str.tostring(rsiVal, "#.#"), text_color=rsiVal > 70 ? cA_Bear : rsiVal < 30 ? cA_Bull : cText, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 6, "MACD",        text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 6, macdBullOk ? "▲" : macdBearOk ? "▼" : "—", text_color=macdBullOk ? cB_Bull : macdBearOk ? cB_Bear : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 7, "VOL",         text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 7, volQualified ? "✓ HIGH" : "low", text_color=volQualified ? cB_Bull : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 8, "S/R",         text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 8, touchedSupport ? "SUPPORT" : touchedResistance ? "RESIST" : "—", text_color=touchedSupport ? cB_Bull : touchedResistance ? cB_Bear : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 9, "HTF",         text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 9, htfBull ? "▲" : htfBear ? "▼" : "—", text_color=htfBull ? cB_Bull : htfBear ? cB_Bear : color.gray, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 10, "PATTERN",    text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 10, patStr,       text_color=patCol, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 11, "WYCKOFF",    text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 11, wyStr,        text_color=wyCol, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 12, "ATR",        text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 12, str.tostring(atrVal, "#.##"), text_color=cText, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 13, "REVERSAL",   text_color=cText, bgcolor=cHeader, text_size=size.small)
    table.cell(dash, 1, 13, revStr,       text_color=revCol, bgcolor=cCellBg, text_size=size.small)

    table.cell(dash, 0, 14, "ACTION",     text_color=color.white, bgcolor=actionCol, text_size=size.normal)
    table.cell(dash, 1, 14, actionStr,    text_color=color.white, bgcolor=actionCol, text_size=size.normal)

    if inCall
        tpStr = callTP1Hit ? "TP2 " + str.tostring(callTP2, "#.##") + " · BE" : "TP1 " + str.tostring(callTP1, "#.##") + " · SL " + str.tostring(callStop, "#.##")
        table.cell(dash, 0, 15, "TGT/SL", text_color=cText, bgcolor=cHeader, text_size=size.small)
        table.cell(dash, 1, 15, tpStr, text_color=cText, bgcolor=cCellBg, text_size=size.small)
    else if inPut
        tpStr = putTP1Hit ? "TP2 " + str.tostring(putTP2, "#.##") + " · BE" : "TP1 " + str.tostring(putTP1, "#.##") + " · SL " + str.tostring(putStop, "#.##")
        table.cell(dash, 0, 15, "TGT/SL", text_color=cText, bgcolor=cHeader, text_size=size.small)
        table.cell(dash, 1, 15, tpStr, text_color=cText, bgcolor=cCellBg, text_size=size.small)
    else
        table.cell(dash, 0, 15, "PRICE", text_color=cText, bgcolor=cHeader, text_size=size.small)
        table.cell(dash, 1, 15, str.tostring(close, "#.##"), text_color=cText, bgcolor=cCellBg, text_size=size.small)

// ============================================================
// ============== ALERTS ======================================
// ============================================================
alertcondition(finalACall,    title="A CALL",     message="A-Setup CALL fired — 6/6 score")
alertcondition(finalBCall,    title="B CALL",     message="B-Setup CALL fired — 4-5/6 score")
alertcondition(finalAPut,     title="A PUT",      message="A-Setup PUT fired — 6/6 score")
alertcondition(finalBPut,     title="B PUT",      message="B-Setup PUT fired — 4-5/6 score")
alertcondition(finalMOCCall,  title="MOC CALL",   message="MOC CALL fired")
alertcondition(finalMOCPut,   title="MOC PUT",    message="MOC PUT fired")
alertcondition(tp1HitCall or tp1HitPut, title="TP1 Hit", message="TP1 hit — stop moved to breakeven")
alertcondition(sellCall,      title="EXIT CALL",  message="Exit call signal")
alertcondition(sellPut,       title="EXIT PUT",   message="Exit put signal")
alertcondition(revWarnInCall, title="Reversal Warning - In Call", message="Bearish reversal building while in CALL — consider exit")
alertcondition(revWarnInPut,  title="Reversal Warning - In Put",  message="Bullish reversal building while in PUT — consider exit")
alertcondition(bullReversalZone, title="Bull Reversal Zone", message="Bull reversal zone — watch for clean entry")
alertcondition(bearReversalZone, title="Bear Reversal Zone", message="Bear reversal zone — watch for clean entry")
alertcondition(isSpring,      title="★ SPRING",    message="Wyckoff Spring detected — bullish reversal")
alertcondition(isUpthrust,    title="★ UPTHRUST",  message="Wyckoff Upthrust detected — bearish reversal")
````
