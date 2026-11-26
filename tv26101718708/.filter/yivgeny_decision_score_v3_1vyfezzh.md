# Yivgeny Decision Score v3

- url: https://www.tradingview.com/script/1VYfEZzH-Yivgeny-Decision-Score-v3/
- type: indicator
- pine_id: PUB;62219ae14bd545d6b37f466cd187d3c8
- version: 1.0

## Description

YDS (Yivgeny Decision Score) is a personal trading decision tool that scores each bar with an ENTRY score (0–10) and a HOLD score (0–10).
The indicator combines trend direction (SMA150), moving average position (MA20), MACD momentum, volume confirmation, candlestick patterns, and stretch analysis to produce a single actionable score.
Key features:

TRIG signal: BREAKOUT / PULLBACK / BOUNCE150 / NONE
Candlestick pattern recognition (Bullish/Bearish Engulfing, Hammer, Morning/Evening Star, Marubozu, Inside Bar Breakout)
Stretch warning from SMA150: OK / MILD / HIGH / SEVERE
Earnings warning flag (manual)
Entry caps and resistance proximity penalty

For personal use only.

## Source Code

````pine
//@version=5
indicator(title="Yivgeny Decision Score v3", shorttitle="YDS", overlay=true, max_labels_count=500)

//========================
// Inputs
//========================
ma20Type   = input.string("SMA", "MA20 Type", options=["SMA","EMA"])
ma20Len    = input.int(20,  "MA20 Length", minval=1)
smaLen     = input.int(150, "SMA150 Length", minval=1)

macdFast   = input.int(12,  "MACD Fast", minval=1)
macdSlow   = input.int(26,  "MACD Slow", minval=1)
macdSig    = input.int(9,   "MACD Signal", minval=1)

volLen     = input.int(20,  "Volume MA Length", minval=1)

touchTolPct150  = input.float(0.6,  "SMA150 Touch Tolerance %", step=0.1)
touchTolPct20   = input.float(0.4,  "MA20 Touch Tolerance %", step=0.1)
pbMinBelow20Pct = input.float(0.15, "Pullback: min dip BELOW MA20 % (strict)", step=0.05)

breakLookback  = input.int(52,    "Breakout Lookback weeks (high)", minval=5)
breakVolMult   = input.float(1.10,"Breakout Volume Mult (vs VolMA)", step=0.05)
confirmVolMult = input.float(1.10,"Confirm Candle Min Volume Mult", step=0.05)

entryCapNoTrig      = input.float(5.2, "Max ENTRY if NO trigger", step=0.1)
entryCapNonBreakout = input.float(8.4, "Max ENTRY for Pullback/Bounce (NON-breakout)", step=0.1)
entryCapNearRes     = input.float(5.0, "Max ENTRY near resistance (no breakout)", step=0.1)

resNearPct  = input.float(0.8, "Resistance proximity % (penalty zone)", step=0.1)
resPenalty  = input.float(1.5, "ENTRY penalty near resistance (no breakout)", step=0.1)

holdTolBelow150Pct     = input.float(2.0, "HOLD: allowed % below SMA150", step=0.25)
holdPenaltyBelow150    = input.float(3.5, "HOLD penalty if below SMA150 beyond tolerance", step=0.1)
holdPenaltyBelow20Down = input.float(1.5, "HOLD penalty if below MA20 and MA20 down", step=0.1)
holdMacdBearPenalty    = input.float(1.2, "HOLD penalty if MACD bearish & worsening", step=0.1)

stretchWarn1Pct    = input.float(20.0, "Stretch Warning 1: % above SMA150 (mild)",   step=1.0)
stretchWarn2Pct    = input.float(35.0, "Stretch Warning 2: % above SMA150 (medium)", step=1.0)
stretchWarn3Pct    = input.float(50.0, "Stretch Warning 3: % above SMA150 (severe)", step=1.0)
stretchPenalty1    = input.float(2.0,  "Stretch Penalty 1", step=0.5)
stretchPenalty2    = input.float(2.0,  "Stretch Penalty 2", step=0.5)
stretchPenalty3    = input.float(2.0,  "Stretch Penalty 3", step=0.5)

stretchMa20Pct     = input.float(15.0, "Stretch from MA20: % threshold", step=1.0)
stretchMa20Penalty = input.float(1.5,  "Stretch from MA20: penalty", step=0.5)

earningsWarning = input.bool(false, "⚠️ Earnings within 30 days? (manual)")

posIn         = input.string("Top Right", "Panel Position", options=["Top Right","Middle Right","Bottom Right","Top Center","Middle Center","Bottom Center"])
textSizeIn    = input.string("Normal", "Text Size", options=["Tiny","Small","Normal","Large","Huge"])
textColor     = input.color(color.white, "Text Color")
bgAlpha       = input.int(85, "Background Transparency (0=solid, 100=transparent)", minval=0, maxval=100)
topCenterDrop = input.int(2,  "Top Center: Drop Lines (push down)", minval=0, maxval=10)

//========================
// Helpers
//========================
f_size(_s) =>
    sz = size.normal
    if _s == "Tiny"
        sz := size.tiny
    else if _s == "Small"
        sz := size.small
    else if _s == "Large"
        sz := size.large
    else if _s == "Huge"
        sz := size.huge
    sz

f_pos(_p) =>
    p = position.top_right
    if _p == "Top Right"
        p := position.top_right
    else if _p == "Middle Right"
        p := position.middle_right
    else if _p == "Bottom Right"
        p := position.bottom_right
    else if _p == "Top Center"
        p := position.top_center
    else if _p == "Middle Center"
        p := position.middle_center
    else if _p == "Bottom Center"
        p := position.bottom_center
    p

f_prefixNewlines(_n) =>
    s = ""
    for i = 0 to _n - 1
        s += "\n"
    s

//========================
// Core indicators
//========================
ma20   = ma20Type == "SMA" ? ta.sma(close, ma20Len) : ta.ema(close, ma20Len)
sma150 = ta.sma(close, smaLen)
volMA  = ta.sma(volume, volLen)

macdLine = ta.ema(close, macdFast) - ta.ema(close, macdSlow)
signal   = ta.ema(macdLine, macdSig)
hist     = macdLine - signal

//========================
// Stretch
//========================
stretchFrom150  = not na(sma150) and sma150 > 0 ? (close - sma150) / sma150 * 100.0 : 0.0
stretchFromMa20 = not na(ma20)   and ma20   > 0 ? (close - ma20)   / ma20   * 100.0 : 0.0

stretchLevel =
     stretchFrom150 >= stretchWarn3Pct ? "🔴 SEVERE" :
     stretchFrom150 >= stretchWarn2Pct ? "🟠 HIGH"   :
     stretchFrom150 >= stretchWarn1Pct ? "🟡 MILD"   : "🟢 OK"

//========================
// נרות אישור
//========================
bodySize  = math.abs(close - open)
upperWick = high - math.max(close, open)
lowerWick = math.min(close, open) - low
fullRange = high - low
bodyRatio = fullRange > 0 ? bodySize / fullRange : 0.0

// חיוביים
bullEngulfing  = (close > open) and (open[1] > close[1]) and (close > open[1]) and (open < close[1])
isHammer       = (lowerWick >= 2.0 * bodySize) and (upperWick <= bodySize * 0.5) and (bodyRatio < 0.4)
morningStar    = (open[2] > close[2]) and (math.abs(close[1] - open[1]) < math.abs(close[2] - open[2]) * 0.4) and (close > open) and (close > (open[2] + close[2]) / 2.0)
bullMarubozu   = (close > open) and (upperWick <= bodySize * 0.05) and (lowerWick <= bodySize * 0.05) and (bodyRatio >= 0.92)
isInsideBar    = (high[1] < high[2]) and (low[1] > low[2])
insideBreakout = isInsideBar and (close > high[1]) and (close > open)

// שליליים
bearEngulfing = (open > close) and (close[1] > open[1]) and (open > close[1]) and (close < open[1])
shootingStar  = (upperWick >= 2.0 * bodySize) and (lowerWick <= bodySize * 0.5) and (bodyRatio < 0.4)
eveningStar   = (close[2] > open[2]) and (math.abs(close[1] - open[1]) < math.abs(close[2] - open[2]) * 0.4) and (open > close) and (close < (open[2] + close[2]) / 2.0)
bearMarubozu  = (open > close) and (upperWick <= bodySize * 0.05) and (lowerWick <= bodySize * 0.05) and (bodyRatio >= 0.92)

// ניקוד נרות — קאפ ±2
float candleScore = 0.0
candleScore += bullEngulfing  ? 2.0 : 0.0
candleScore += morningStar    ? 2.0 : 0.0
candleScore += isHammer       ? 1.0 : 0.0
candleScore += bullMarubozu   ? 1.0 : 0.0
candleScore += insideBreakout ? 1.0 : 0.0
candleScore -= bearEngulfing  ? 2.0 : 0.0
candleScore -= eveningStar    ? 2.0 : 0.0
candleScore -= shootingStar   ? 1.0 : 0.0
candleScore -= bearMarubozu   ? 1.0 : 0.0
candleScore := math.max(-2.0, math.min(2.0, candleScore))

//========================
// ENTRY logic
//========================
trendUp150 = sma150 > sma150[10]
above150   = close > sma150
above20    = close > ma20
ma20Up     = ma20 > ma20[3]
ma20Down   = ma20 < ma20[3]

tol150        = touchTolPct150 * 0.01
touched150    = low <= sma150 * (1 + tol150)
reclaim150    = close > sma150

pbMin         = pbMinBelow20Pct * 0.01
dippedBelow20 = low <= ma20 * (1 - pbMin)
reclaim20     = close > ma20

bullCandle    = close > open
confirmCandle = bullCandle and (close > high[1]) and (volume >= volMA * confirmVolMult)

bounce150 = touched150 and reclaim150 and confirmCandle

lost20Recently = (close[1] < ma20[1]) or (low[1] < ma20[1]) or dippedBelow20
pullback20     = dippedBelow20 and reclaim20 and confirmCandle and lost20Recently and trendUp150 and ma20Up

int bkDays = breakLookback * 5
priorHigh  = ta.highest(high, bkDays)[1]
high52w    = ta.highest(high, 252)[1]

breakoutNow = not na(priorHigh) and (close > priorHigh) and bullCandle and (volume >= volMA * breakVolMult) and (close >= high52w * 0.90)

macdBull      = macdLine > signal
macdImproving = hist > hist[1]
volOK         = volume >= volMA * 0.9

nearRes = false
if not na(priorHigh)
    distPct = (priorHigh - close) / close * 100.0
    nearRes := (distPct >= 0) and (distPct <= resNearPct) and not breakoutNow

// ENTRY Score
float entryRaw = 0.0
entryRaw += trendUp150             ? 2.0 : 0.0
entryRaw += above150               ? 2.0 : 0.0
entryRaw += touched150             ? 1.2 : 0.0
entryRaw += reclaim150             ? 0.8 : 0.0
entryRaw += (reclaim20 or above20) ? 1.0 : 0.0
entryRaw += bounce150              ? 2.2 : 0.0
entryRaw += pullback20             ? 2.0 : 0.0
entryRaw += breakoutNow            ? 2.2 : 0.0
entryRaw += macdBull               ? 0.8 : 0.0
entryRaw += macdImproving          ? 0.5 : 0.0
entryRaw += volOK                  ? 0.3 : 0.0
entryRaw += candleScore
entryRaw -= nearRes          ? resPenalty : 0.0
entryRaw -= earningsWarning  ? 1.5 : 0.0
entryRaw -= stretchFrom150 >= stretchWarn1Pct ? stretchPenalty1 : 0.0
entryRaw -= stretchFrom150 >= stretchWarn2Pct ? stretchPenalty2 : 0.0
entryRaw -= stretchFrom150 >= stretchWarn3Pct ? stretchPenalty3 : 0.0
entryRaw -= stretchFromMa20 >= stretchMa20Pct ? stretchMa20Penalty : 0.0

float entryScore = math.max(0.0, math.min(10.0, entryRaw))

//========================
// GATING
//========================
bool hasTrigger         = bounce150 or pullback20 or breakoutNow
bool nonBreakoutTrigger = (bounce150 or pullback20) and not breakoutNow
bool shifiBlockedByRes  = nearRes and not breakoutNow

if not hasTrigger
    entryScore := math.min(entryScore, entryCapNoTrig)
if nonBreakoutTrigger
    entryScore := math.min(entryScore, entryCapNonBreakout)
if shifiBlockedByRes
    entryScore := math.min(entryScore, entryCapNearRes)

//========================
// HOLD logic
//========================
tolBelow150  = holdTolBelow150Pct * 0.01
near150      = close >= sma150 * (1 - tolBelow150)
wellBelow150 = close <  sma150 * (1 - tolBelow150)

macdBearWorsen = (macdLine < signal) and (hist < hist[1])

float holdRaw = 0.0
holdRaw += trendUp150          ? 2.2 : 0.0
holdRaw += (close > sma150)    ? 2.6 : (near150 ? 1.2 : 0.0)
holdRaw += (close > ma20)      ? 2.0 : 0.0
holdRaw += ma20Up              ? 0.8 : 0.0
holdRaw += macdBull            ? 1.6 : 0.0
holdRaw += macdImproving       ? 0.8 : 0.0
holdRaw += (close >= close[1]) ? 0.6 : 0.0
holdRaw -= wellBelow150                  ? holdPenaltyBelow150    : 0.0
holdRaw -= ((close < ma20) and ma20Down) ? holdPenaltyBelow20Down : 0.0
holdRaw -= macdBearWorsen                ? holdMacdBearPenalty    : 0.0
holdRaw -= earningsWarning               ? 0.8 : 0.0
holdRaw -= stretchFrom150 >= stretchWarn2Pct ? 1.0 : 0.0
holdRaw -= stretchFrom150 >= stretchWarn3Pct ? 1.5 : 0.0

float holdScore = math.max(0.0, math.min(10.0, holdRaw))

//========================
// Display
//========================
txtSize = f_size(textSizeIn)
tbPos   = f_pos(posIn)
bgCol   = color.new(color.black, bgAlpha)

var table t = table.new(position.top_right, 1, 1, border_width=0)

if barstate.islast
    table.set_position(t, tbPos)
    int drop = (posIn == "Top Center") ? topCenterDrop : 0

    string trigTxt = breakoutNow ? "TRIG: BREAKOUT" :
                     pullback20  ? "TRIG: PULLBACK"  :
                     bounce150   ? "TRIG: BOUNCE150" : "TRIG: NONE"

    string earnTxt    = earningsWarning ? "\n⚠️ EARNINGS SOON" : ""
    string stretchTxt = stretchFrom150 >= stretchWarn1Pct ? "\nSTR: " + str.tostring(stretchFrom150, "#.#") + "% " + stretchLevel : ""

    string candleTxt = ""
    if bullEngulfing
        candleTxt := "\n🕯 Bullish Engulfing"
    else if morningStar
        candleTxt := "\n🕯 Morning Star"
    else if isHammer
        candleTxt := "\n🕯 Hammer"
    else if bullMarubozu
        candleTxt := "\n🕯 Marubozu ↑"
    else if insideBreakout
        candleTxt := "\n🕯 Inside Breakout"
    else if bearEngulfing
        candleTxt := "\n🕯 Bearish Engulfing"
    else if eveningStar
        candleTxt := "\n🕯 Evening Star"
    else if shootingStar
        candleTxt := "\n🕯 Shooting Star"
    else if bearMarubozu
        candleTxt := "\n🕯 Marubozu ↓"

    string txt = f_prefixNewlines(drop) +
         "ENTRY: " + str.tostring(entryScore, "#.#") + "\n" +
         "HOLD:  " + str.tostring(holdScore,  "#.#") + "\n" +
         trigTxt + earnTxt + stretchTxt + candleTxt

    table.cell(t, 0, 0, txt, text_color=textColor, text_size=txtSize, bgcolor=bgCol)

//========================
// Plots (hidden)
//========================
plot(ma20,   title="MA20 (hidden)",   display=display.none)
plot(sma150, title="SMA150 (hidden)", display=display.none)
````
