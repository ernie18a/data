# Sniper Gang by DoubleTheGreat

- url: https://www.tradingview.com/script/v3eBOAh6-Sniper-Gang-by-DoubleTheGreat/
- type: indicator
- pine_id: PUB;23c0dcbcddb64778bc2d957d2a0faafd
- version: 2.0

## Description

Where the snipers use emas price action stops  are based off of structure always use htf bias and pull back bounces for entries to match htf bias

## Source Code

````pine
//@version=6
// © DoubleTheGreat - 2026. All rights reserved.
// Sniper Gang V4 — ICT + HPS Quad + MSS Complete Build
indicator("Sniper Gang V4 by DoubleTheGreat", overlay=true, max_labels_count=500, max_boxes_count=500, max_bars_back=1000)

// ═══════════════════════════════════════════════════════════════════════════════
// COLORS
// ═══════════════════════════════════════════════════════════════════════════════
color c_turquoise = #40E0D0
color c_gold      = #FFD700
color c_purple    = #CE93D8

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — VISUALS
// ═══════════════════════════════════════════════════════════════════════════════
groupVis       = "Visuals & UI"
dashTextSize   = input.string("small", "Dashboard Font Size", options=["tiny","small","normal","large","huge"], group=groupVis)
tradeTextSize  = input.string("small", "Trade Label Size",    options=["tiny","small","normal","large","huge"], group=groupVis)
ribbonOpacity  = input.int(75, "EMA Ribbon Opacity", minval=0, maxval=100, group=groupVis)
labelOffset    = input.int(12, "Label Right Offset (Bars)", minval=1, group=groupVis)
showRetest     = input.bool(true, "Show Retest Candles", group=groupVis)
retestColor    = input.color(color.orange, "Retest Candle Color", group=groupVis)
signalColor    = input.color(color.black,  "Signal Candle Color", group=groupVis)
dashPosition   = input.string("Middle Left", "Dashboard Position", options=["Top Left","Top Right","Middle Left","Middle Right","Bottom Left","Bottom Right"], group=groupVis)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — EMA
// ═══════════════════════════════════════════════════════════════════════════════
groupEMA      = "EMA Settings"
emaFastLen    = input.int(9,  "Fast EMA Length", minval=1, group=groupEMA)
emaSlowLen    = input.int(21, "Slow EMA Length", minval=1, group=groupEMA)
emaFastColor  = input.color(color.green, "Fast EMA Color",   group=groupEMA)
emaSlowColor  = input.color(color.red,   "Slow EMA Color",   group=groupEMA)
emaBullFill   = input.color(color.green, "Bull Ribbon Fill", group=groupEMA)
emaBearFill   = input.color(color.red,   "Bear Ribbon Fill", group=groupEMA)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — RISK
// ═══════════════════════════════════════════════════════════════════════════════
groupRisk     = "Risk Management"
atrMultiplier = input.float(1.5,   "SL ATR Multiplier",                     minval=0.1, step=0.1, group=groupRisk)
dollarRisk    = input.float(100.0, "Dollar Risk Per Trade ($)",              minval=1,   step=10,  group=groupRisk)
pointValue    = input.float(0.0,   "Point Value Override (0 = auto-detect)", minval=0,   step=0.5, group=groupRisk)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — HTF BIAS FILTER
// ═══════════════════════════════════════════════════════════════════════════════
groupHTF      = "HTF Bias Filter"
useHTFFilter  = input.bool(false, "Enable HTF Bias Filter", group=groupHTF)
htfTF1        = input.timeframe("60",  "HTF Reference 1", group=groupHTF)
htfTF2        = input.timeframe("240", "HTF Reference 2", group=groupHTF)
useHTF2       = input.bool(true, "Use HTF Reference 2 as well", group=groupHTF)
htfEMAFast    = input.int(9,  "HTF Fast EMA", minval=1, group=groupHTF)
htfEMASlow    = input.int(21, "HTF Slow EMA", minval=1, group=groupHTF)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — UT BOT
// ═══════════════════════════════════════════════════════════════════════════════
groupUT        = "UT Bot"
showUT         = input.bool(true,  "Show UT Bot",                                       group=groupUT)
showUTLine     = input.bool(true,  "Show Trailing Stop Line",                           group=groupUT)
showUTLabels   = input.bool(true,  "Show Buy/Sell Labels",                              group=groupUT)
showUTBarcolor = input.bool(false, "Show UT Bot Bar Color (overrides Sniper barcolor)", group=groupUT)
keyvalue       = input.float(3.0,  "Key Value (Sensitivity)", minval=0.5, step=0.5,     group=groupUT)
atrperiod      = input.int(10,     "ATR Period", minval=1,                              group=groupUT)
utBullColor    = input.color(color.green, "UT Bot Bull Bar Color", group=groupUT)
utBearColor    = input.color(color.red,   "UT Bot Bear Bar Color", group=groupUT)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — HPS QUAD
// ═══════════════════════════════════════════════════════════════════════════════
groupHPS       = "HPS Quad System"
showHPS        = input.bool(true, "Show HPS Signals on Dashboard", group=groupHPS)
stoch1K        = input.int(9,  "Fast Stoch K",   minval=1, group=groupHPS)
stoch1D        = input.int(3,  "Fast Stoch D",   minval=1, group=groupHPS)
stoch2K        = input.int(14, "Medium Stoch K", minval=1, group=groupHPS)
stoch2D        = input.int(3,  "Medium Stoch D", minval=1, group=groupHPS)
stoch3K        = input.int(40, "Slow Stoch K",   minval=1, group=groupHPS)
stoch3D        = input.int(4,  "Slow Stoch D",   minval=1, group=groupHPS)
stoch4K        = input.int(60, "Trend Stoch K",  minval=1, group=groupHPS)
stoch4D        = input.int(10, "Trend Stoch D",  minval=1, group=groupHPS)
stoch4TF       = input.timeframe("5", "Trend Stoch Timeframe", group=groupHPS)
quadOBLevel    = input.int(80, "Overbought Level", minval=50, maxval=100, group=groupHPS)
quadOSLevel    = input.int(20, "Oversold Level",   minval=0,  maxval=50,  group=groupHPS)
trendStrongLvl = input.int(85, "Trend Strong Level", minval=50, maxval=100, group=groupHPS)

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — MSS
// ═══════════════════════════════════════════════════════════════════════════════
groupMSS     = "Market Structure Oscillator"
showMSS      = input.bool(true, "Show MSS on Dashboard",          group=groupMSS)
showMSSSig   = input.bool(true, "Show MSS Cross Signals on Chart", group=groupMSS)
showCycleOsc = input.bool(true, "Show Cycle Oscillator Crosses",   group=groupMSS)
cycSmooth    = input.int(7,     "Cycle Oscillator Length", minval=1, group=groupMSS)
msWeightK1   = input.float(1,   "Short Term Weight",        minval=0, step=0.1, group=groupMSS)
msWeightK2   = input.float(3,   "Intermediate Term Weight", minval=0, step=0.1, group=groupMSS)
msWeightK3   = input.float(2,   "Long Term Weight",         minval=0, step=0.1, group=groupMSS)
norm_Smooth  = input.int(4,     "Oscillator Smoothing",     minval=1,           group=groupMSS)
msBullColor  = input.color(#3179f5,                    "MSS Bull Signal Color",   group=groupMSS)
msBearColor  = input.color(#ffa726,                    "MSS Bear Signal Color",   group=groupMSS)
cycBullColor = input.color(color.new(#90bff9, 25),     "Cycle Bull Signal Color", group=groupMSS)
cycBearColor = input.color(color.new(#ffcc80, 25),     "Cycle Bear Signal Color", group=groupMSS)

// ═══════════════════════════════════════════════════════════════════════════════
// AUTO DETECT POINT VALUE
// ═══════════════════════════════════════════════════════════════════════════════
isMNQ = str.contains(syminfo.tickerid, "MNQ")
isMGC = str.contains(syminfo.tickerid, "MGC")
isNAS = str.contains(syminfo.tickerid, "NAS100") or str.contains(syminfo.tickerid, "US100") or str.contains(syminfo.tickerid, "USTEC")
isXAU = str.contains(syminfo.tickerid, "XAUUSD") or str.contains(syminfo.tickerid, "GOLD")
float autoPointVal  = isMNQ ? 2.0 : isMGC ? 10.0 : isNAS ? 1.0 : isXAU ? 1.0 : 0.0
float finalPointVal = pointValue > 0 ? pointValue : autoPointVal

// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD HELPER
// ═══════════════════════════════════════════════════════════════════════════════
f_addDashRow(_table, _row, _title, _val, _col, _size) =>
    table.cell(_table, 0, _row, _title, text_color=color.black, text_halign=text.align_left,  text_size=_size)
    table.cell(_table, 1, _row, _val,   text_color=_col,        text_size=_size, text_halign=text.align_right)

// ═══════════════════════════════════════════════════════════════════════════════
// CORE INDICATORS
// ═══════════════════════════════════════════════════════════════════════════════
ema9   = ta.ema(close, emaFastLen)
ema21  = ta.ema(close, emaSlowLen)
vwapV  = ta.vwap(hlc3)
atr    = ta.atr(14)
rsiVal = ta.rsi(close, 14)
rsi5m  = request.security(syminfo.tickerid, "5", ta.rsi(close, 14))
[m, s, _]   = ta.macd(close, 12, 26, 9)
[_, _, adx] = ta.dmi(14, 14)
volAvg = ta.sma(volume, 20)

// ═══════════════════════════════════════════════════════════════════════════════
// HTF BIAS
// ═══════════════════════════════════════════════════════════════════════════════
htf1EMAFast = request.security(syminfo.tickerid, htfTF1, ta.ema(close, htfEMAFast))
htf1EMASlow = request.security(syminfo.tickerid, htfTF1, ta.ema(close, htfEMASlow))
htf2EMAFast = request.security(syminfo.tickerid, htfTF2, ta.ema(close, htfEMAFast))
htf2EMASlow = request.security(syminfo.tickerid, htfTF2, ta.ema(close, htfEMASlow))
htf1Vwap    = request.security(syminfo.tickerid, htfTF1, ta.vwap(hlc3))
htf2Vwap    = request.security(syminfo.tickerid, htfTF2, ta.vwap(hlc3))

bool htf1Bull = htf1EMAFast > htf1EMASlow and close > htf1Vwap
bool htf1Bear = htf1EMAFast < htf1EMASlow and close < htf1Vwap
bool htf2Bull = htf2EMAFast > htf2EMASlow and close > htf2Vwap
bool htf2Bear = htf2EMAFast < htf2EMASlow and close < htf2Vwap

bool htfBullAligned = useHTF2 ? (htf1Bull and htf2Bull) : htf1Bull
bool htfBearAligned = useHTF2 ? (htf1Bear and htf2Bear) : htf1Bear

string htfText = htfBullAligned ? "✅ BULL ALIGNED" : htfBearAligned ? "✅ BEAR ALIGNED" : "⚠️ MIXED"
color  htfCol  = htfBullAligned ? color.green : htfBearAligned ? color.red : color.orange

// ═══════════════════════════════════════════════════════════════════════════════
// DUAL SCORE
// ═══════════════════════════════════════════════════════════════════════════════
float bScore = 0
bScore += (close > vwapV ? 1 : 0)
bScore += (rsiVal > 50 ? 1 : 0)
bScore += (m > s ? 1 : 0)
bScore += (ema9 > ema21 ? 1 : 0)
bScore += (adx > 25 and close > ema9 ? 1 : 0)
bScore += (volume > volAvg and close > open ? 1 : 0)
bScore += (rsi5m > 50 ? 1 : 0)
float bullPct = (bScore / 7) * 100

float rScore = 0
rScore += (close < vwapV ? 1 : 0)
rScore += (rsiVal < 50 ? 1 : 0)
rScore += (m < s ? 1 : 0)
rScore += (ema9 < ema21 ? 1 : 0)
rScore += (adx > 25 and close < ema9 ? 1 : 0)
rScore += (volume > volAvg and close < open ? 1 : 0)
rScore += (rsi5m < 50 ? 1 : 0)
float bearPct = (rScore / 7) * 100

string biasText = (bullPct - bearPct) >= 40 ? "STRONG BULL" : (bearPct - bullPct) >= 40 ? "STRONG BEAR" : bullPct > bearPct ? "MILD BULL" : "MILD BEAR"
color  biasCol  = biasText == "STRONG BULL" ? color.green : biasText == "STRONG BEAR" ? color.red : color.gray

// ═══════════════════════════════════════════════════════════════════════════════
// SIGNAL LOGIC
// ═══════════════════════════════════════════════════════════════════════════════
var int   lastSignalState = 0
var float entryP = 0.0, var float slP = 0.0
var float t1 = 0.0, var float t2 = 0.0, var float t3 = 0.0, var float t4 = 0.0, var float t5 = 0.0
var bool  t1Hit = false, var bool t2Hit = false, var bool t3Hit = false, var bool t4Hit = false, var bool t5Hit = false

buyCond  = ta.crossover(ema9,  ema21)
sellCond = ta.crossunder(ema9, ema21)

bool buyAllowed  = useHTFFilter ? htfBullAligned : true
bool sellAllowed = useHTFFilter ? htfBearAligned : true

triggerBuy  = buyCond  and lastSignalState <= 0 and buyAllowed
triggerSell = sellCond and lastSignalState >= 0 and sellAllowed

if triggerBuy or triggerSell
    lastSignalState := triggerBuy ? 1 : -1
    entryP := close
    float risk = atr * atrMultiplier
    slP := triggerBuy ? entryP - risk : entryP + risk
    t1  := triggerBuy ? entryP + risk       : entryP - risk
    t2  := triggerBuy ? entryP + (risk * 2) : entryP - (risk * 2)
    t3  := triggerBuy ? entryP + (risk * 3) : entryP - (risk * 3)
    t4  := triggerBuy ? entryP + (risk * 4) : entryP - (risk * 4)
    t5  := triggerBuy ? entryP + (risk * 5) : entryP - (risk * 5)
    t1Hit := false, t2Hit := false, t3Hit := false, t4Hit := false, t5Hit := false

// ═══════════════════════════════════════════════════════════════════════════════
// TARGET HIT DETECTION
// ═══════════════════════════════════════════════════════════════════════════════
if lastSignalState == 1
    if high >= t1
        t1Hit := true
    if high >= t2
        t2Hit := true
    if high >= t3
        t3Hit := true
    if high >= t4
        t4Hit := true
    if high >= t5
        t5Hit := true
if lastSignalState == -1
    if low <= t1
        t1Hit := true
    if low <= t2
        t2Hit := true
    if low <= t3
        t3Hit := true
    if low <= t4
        t4Hit := true
    if low <= t5
        t5Hit := true

// ═══════════════════════════════════════════════════════════════════════════════
// UT BOT
// ═══════════════════════════════════════════════════════════════════════════════
utSrc  = close
utATR  = ta.atr(atrperiod)
nLoss  = keyvalue * utATR

var float xATRTrailingStop = 0.0
float prevStop = nz(xATRTrailingStop[1], 0.0)

if utSrc > prevStop and utSrc[1] > prevStop
    xATRTrailingStop := math.max(prevStop, utSrc - nLoss)
else if utSrc < prevStop and utSrc[1] < prevStop
    xATRTrailingStop := math.min(prevStop, utSrc + nLoss)
else if utSrc > prevStop
    xATRTrailingStop := utSrc - nLoss
else
    xATRTrailingStop := utSrc + nLoss

var int utPos = 0
if utSrc[1] < nz(xATRTrailingStop[1], 0.0) and utSrc > nz(xATRTrailingStop[1], 0.0)
    utPos := 1
else if utSrc[1] > nz(xATRTrailingStop[1], 0.0) and utSrc < nz(xATRTrailingStop[1], 0.0)
    utPos := -1
else
    utPos := nz(utPos[1], 0)

utBuy   = ta.crossover(utSrc,  xATRTrailingStop)
utSell  = ta.crossunder(utSrc, xATRTrailingStop)
utBarUp = utSrc > xATRTrailingStop
color utLineColor = utPos == -1 ? color.red : utPos == 1 ? color.green : color.blue

// ═══════════════════════════════════════════════════════════════════════════════
// HPS STOCHASTICS
// ═══════════════════════════════════════════════════════════════════════════════
s1_smooth = ta.sma(ta.stoch(close, high, low, stoch1K), stoch1D)
s2_smooth = ta.sma(ta.stoch(close, high, low, stoch2K), stoch2D)
s3_smooth = ta.sma(ta.stoch(close, high, low, stoch3K), stoch3D)
s4_smooth = request.security(syminfo.tickerid, stoch4TF, ta.sma(ta.stoch(close, high, low, stoch4K), stoch4D))

bool s1AtOversold   = s1_smooth <= quadOSLevel
bool s1AtOverbought = s1_smooth >= quadOBLevel
bool s1TurningUp    = s1_smooth > s1_smooth[1]
bool s1TurningDown  = s1_smooth < s1_smooth[1]
bool trendBull      = s4_smooth >= 60
bool trendBear      = s4_smooth <= 40

string stochTrendText = s4_smooth >= trendStrongLvl ? "💪 STRONG BULL" : s4_smooth >= 60 ? "↑ BULL" : s4_smooth <= (100 - trendStrongLvl) ? "💪 STRONG BEAR" : s4_smooth <= 40 ? "↓ BEAR" : "— NEUTRAL"
color  stochTrendCol  = s4_smooth >= trendStrongLvl ? color.green : s4_smooth >= 60 ? color.rgb(0,180,0) : s4_smooth <= (100 - trendStrongLvl) ? color.rgb(180,0,0) : s4_smooth <= 40 ? color.red : color.gray

string stochPullText = ""
color  stochPullCol  = color.gray
if trendBull and s1AtOversold and s1TurningUp
    stochPullText := "🎯 BULL FLAG ENTRY"
    stochPullCol  := color.green
else if trendBear and s1AtOverbought and s1TurningDown
    stochPullText := "🎯 BEAR FLAG ENTRY"
    stochPullCol  := color.red
else if s1AtOversold
    stochPullText := "📉 FAST OVERSOLD"
    stochPullCol  := color.orange
else if s1AtOverbought
    stochPullText := "📈 FAST OVERBOUGHT"
    stochPullCol  := color.orange
else if trendBull and s1_smooth <= 40
    stochPullText := "⏳ FLAG FORMING"
    stochPullCol  := color.rgb(144, 238, 144)
else if trendBear and s1_smooth >= 60
    stochPullText := "⏳ FLAG FORMING"
    stochPullCol  := color.rgb(238, 144, 144)
else
    stochPullText := "— TRENDING"
    stochPullCol  := color.gray

bool allBelowOS = s1_smooth <= quadOSLevel and s2_smooth <= quadOSLevel and s3_smooth <= quadOSLevel and s4_smooth <= quadOSLevel
bool allAboveOB = s1_smooth >= quadOBLevel and s2_smooth >= quadOBLevel and s3_smooth >= quadOBLevel and s4_smooth >= quadOBLevel

var float stage1Low      = na
var float stage1StochLow = na
var bool  quadStage1Bull = false
var bool  quadStage1Bear = false
var bool  quadDivBull    = false
var bool  quadDivBear    = false

if allBelowOS and not allBelowOS[1]
    stage1Low      := low
    stage1StochLow := s1_smooth
    quadStage1Bull := true
    quadStage1Bear := false
    quadDivBull    := false

if allAboveOB and not allAboveOB[1]
    stage1Low      := high
    stage1StochLow := s1_smooth
    quadStage1Bear := true
    quadStage1Bull := false
    quadDivBear    := false

if quadStage1Bull and not allBelowOS
    if low <= stage1Low and s1_smooth > stage1StochLow and s1TurningUp and s1_smooth <= quadOSLevel + 10
        quadDivBull := true

if quadStage1Bear and not allAboveOB
    if high >= stage1Low and s1_smooth < stage1StochLow and s1TurningDown and s1_smooth >= quadOBLevel - 10
        quadDivBear := true

if triggerBuy or triggerSell
    quadStage1Bull := false
    quadStage1Bear := false
    quadDivBull    := false
    quadDivBear    := false

bool hiddenBullDiv = s4_smooth >= trendStrongLvl and s2_smooth >= 50 and s3_smooth >= 50 and s1AtOversold and s1TurningUp
bool hiddenBearDiv = s4_smooth <= (100 - trendStrongLvl) and s2_smooth <= 50 and s3_smooth <= 50 and s1AtOverbought and s1TurningDown

string quadText = quadDivBull ? "🔥 QUAD BULL REV" : quadDivBear ? "🔥 QUAD BEAR REV" : hiddenBullDiv ? "📈 HIDDEN BULL" : hiddenBearDiv ? "📉 HIDDEN BEAR" : quadStage1Bull and not allBelowOS ? "⏳ WATCHING BULL" : quadStage1Bear and not allAboveOB ? "⏳ WATCHING BEAR" : allBelowOS ? "🔴 STAGE 1 BULL" : allAboveOB ? "🔴 STAGE 1 BEAR" : "— NO SIGNAL"
color  quadCol  = quadDivBull ? color.green : quadDivBear ? color.red : hiddenBullDiv ? color.rgb(0,200,100) : hiddenBearDiv ? color.rgb(200,50,50) : (quadStage1Bull and not allBelowOS) or (quadStage1Bear and not allAboveOB) ? color.orange : allBelowOS ? color.rgb(144,238,144) : allAboveOB ? color.rgb(238,144,144) : color.gray

bool exitWarnBull = lastSignalState == 1  and s1AtOverbought and s4_smooth < s4_smooth[1] and close < ema21
bool exitWarnBear = lastSignalState == -1 and s1AtOversold   and s4_smooth > s4_smooth[1] and close > ema21

string exitText = exitWarnBull or exitWarnBear ? "⚠️ TAKE PROFITS" : lastSignalState == 1 and s4_smooth >= trendStrongLvl ? "✅ LET IT RUN" : lastSignalState == -1 and s4_smooth <= (100 - trendStrongLvl) ? "✅ LET IT RUN" : lastSignalState != 0 ? "👀 MONITOR" : "— NO TRADE"
color  exitCol  = exitWarnBull or exitWarnBear ? color.red : (lastSignalState == 1 and s4_smooth >= trendStrongLvl) or (lastSignalState == -1 and s4_smooth <= (100 - trendStrongLvl)) ? color.green : lastSignalState != 0 ? color.orange : color.gray

// ═══════════════════════════════════════════════════════════════════════════════
// MSS OSCILLATOR
// ═══════════════════════════════════════════════════════════════════════════════
f_normalize(bool buy, bool sell, int smooth) =>
    var int os = 0
    var float maxV = na
    var float minV = na
    os   := buy ? 1 : sell ? -1 : os
    maxV := os > os[1] ? close : os < os[1] ? maxV : math.max(close, maxV)
    minV := os < os[1] ? close : os > os[1] ? minV : math.min(close, minV)
    ta.sma((close - minV) / (maxV - minV), smooth) * 100

var float stHighLast = na, var bool stHighCrossed = false
var float stLowLast  = na, var bool stLowCrossed  = false
bool stBull = false, bool stBear = false

if high[1] > high[2] and high[1] >= high
    stHighLast := high[1], stHighCrossed := false
if not na(stHighLast) and close > stHighLast and not stHighCrossed
    stHighCrossed := true, stBull := true
if low[1] < low[2] and low[1] <= low
    stLowLast := low[1], stLowCrossed := false
if not na(stLowLast) and close < stLowLast and not stLowCrossed
    stLowCrossed := true, stBear := true

float stValue1 = f_normalize(stBull, stBear, norm_Smooth)

var float itHighLast = na, var bool itHighCrossed = false
var float itLowLast  = na, var bool itLowCrossed  = false
bool itBull = false, bool itBear = false
bool cStHigh = not na(stHighLast) and high[1] > high[2] and high[1] >= high
bool cStLow  = not na(stLowLast)  and low[1]  < low[2]  and low[1]  <= low

if cStHigh and cStHigh != cStHigh[1]
    itHighLast := stHighLast, itHighCrossed := false
if not na(itHighLast) and close > itHighLast and not itHighCrossed
    itHighCrossed := true, itBull := true
if cStLow and cStLow != cStLow[1]
    itLowLast := stLowLast, itLowCrossed := false
if not na(itLowLast) and close < itLowLast and not itLowCrossed
    itLowCrossed := true, itBear := true

float stValue2 = f_normalize(itBull, itBear, norm_Smooth)

var float ltHighLast = na, var bool ltHighCrossed = false
var float ltLowLast  = na, var bool ltLowCrossed  = false
bool ltBull = false, bool ltBear = false
bool cItHigh = not na(itHighLast) and cStHigh
bool cItLow  = not na(itLowLast)  and cStLow

if cItHigh and cItHigh != cItHigh[1]
    ltHighLast := itHighLast, ltHighCrossed := false
if not na(ltHighLast) and close > ltHighLast and not ltHighCrossed
    ltHighCrossed := true, ltBull := true
if cItLow and cItLow != cItLow[1]
    ltLowLast := itLowLast, ltLowCrossed := false
if not na(ltLowLast) and close < ltLowLast and not ltLowCrossed
    ltLowCrossed := true, ltBear := true

float stValue3 = f_normalize(ltBull, ltBear, norm_Smooth)

float totalWeight = msWeightK1 + msWeightK2 + msWeightK3
float msOSC = (msWeightK1 * nz(stValue1,0) + msWeightK2 * nz(stValue2,0) + msWeightK3 * nz(stValue3,0)) / totalWeight
float cycleFast = msOSC - ta.ema(msOSC, cycSmooth) + 50

bool mssCrossUp   = ta.change(math.sign(msOSC - 50)) > 0
bool mssCrossDown = ta.change(math.sign(msOSC - 50)) < 0
bool cycCrossUp   = ta.change(math.sign(cycleFast - 50)) > 0
bool cycCrossDown = ta.change(math.sign(cycleFast - 50)) < 0

string mssText = msOSC >= 85 ? "🔥 STRONG BULL" : msOSC >= 60 ? "↑ BULL STRUCTURE" : msOSC <= 15 ? "🔥 STRONG BEAR" : msOSC <= 40 ? "↓ BEAR STRUCTURE" : "— NEUTRAL"
color  mssCol  = msOSC >= 85 ? color.green : msOSC >= 60 ? color.rgb(0,180,0) : msOSC <= 15 ? color.rgb(180,0,0) : msOSC <= 40 ? color.red : color.gray

bool chochBull = itBull and not ltBull
bool chochBear = itBear and not ltBear
bool bosBull   = ltBull
bool bosBear   = ltBear

string structText = bosBull ? "⬆️ BOS BULL" : bosBear ? "⬇️ BOS BEAR" : chochBull ? "🔄 CHoCH BULL" : chochBear ? "🔄 CHoCH BEAR" : "— RANGING"
color  structCol  = bosBull ? color.green : bosBear ? color.red : chochBull ? color.rgb(0,200,150) : chochBear ? color.rgb(200,100,0) : color.gray

// ═══════════════════════════════════════════════════════════════════════════════
// HOLD STRENGTH
// ═══════════════════════════════════════════════════════════════════════════════
float activeScore = lastSignalState == 1 ? bScore : lastSignalState == -1 ? rScore : math.max(bScore, rScore)
float prevScore   = lastSignalState == 1 ? bScore[1] : lastSignalState == -1 ? rScore[1] : math.max(bScore[1], rScore[1])

string holdText = activeScore <= 1 ? "❌ EXIT ZONE" : activeScore <= 3 and activeScore > prevScore ? "🔄 RECOVERING" : activeScore >= 4 and activeScore > prevScore ? "👀 BUILDING" : activeScore >= 6 ? "✅ STRONG HOLD" : activeScore < prevScore ? "⚠️ WEAKENING" : "HOLD"
color  holdCol  = activeScore <= 1 ? color.rgb(139,0,0) : activeScore <= 3 and activeScore > prevScore ? color.orange : activeScore >= 4 and activeScore > prevScore ? color.rgb(144,238,144) : activeScore >= 6 ? color.green : activeScore < prevScore ? color.red : color.orange

// ═══════════════════════════════════════════════════════════════════════════════
// LIVE R
// ═══════════════════════════════════════════════════════════════════════════════
float riskDist   = math.abs(entryP - slP)
string liveRText = ""
color  liveRCol  = color.gray

if lastSignalState != 0 and riskDist > 0
    float distToSL = lastSignalState == 1 ? (close - slP) : (slP - close)
    float rRatio   = distToSL / riskDist
    float nextTP   = na
    string nextLbl = ""
    if not t1Hit
        nextTP := t1, nextLbl := "TP1"
    else if not t2Hit
        nextTP := t2, nextLbl := "TP2"
    else if not t3Hit
        nextTP := t3, nextLbl := "TP3"
    else if not t4Hit
        nextTP := t4, nextLbl := "TP4"
    else if not t5Hit
        nextTP := t5, nextLbl := "TP5"
    if na(nextTP)
        liveRText := "🏆 ALL TP HIT"
        liveRCol  := color.green
    else if rRatio <= 0.2
        liveRText := "🚨 SL CLOSE"
        liveRCol  := color.rgb(139,0,0)
    else if rRatio <= 0.5
        liveRText := "⚠️ AT RISK"
        liveRCol  := color.red
    else
        float tpR = math.abs(nextTP - close) / riskDist
        liveRText := nextLbl + " " + str.tostring(tpR,"#.#") + "R AWAY"
        liveRCol  := tpR >= 2.0 ? color.green : tpR >= 1.0 ? color.orange : color.gray
else
    liveRText := "NO ACTIVE TRADE"
    liveRCol  := color.gray

// ═══════════════════════════════════════════════════════════════════════════════
// CONTRACT SIZE
// ═══════════════════════════════════════════════════════════════════════════════
string contractText = ""
color  contractCol  = color.black
if lastSignalState != 0 and riskDist > 0 and finalPointVal > 0
    float contracts = dollarRisk / (riskDist * finalPointVal)
    float rounded   = math.round(contracts * 2) / 2
    string instrLbl = isMNQ ? "MNQ" : isMGC ? "MGC" : isNAS ? "NAS100" : isXAU ? "XAU" : "CONT"
    contractText := str.tostring(rounded,"#.#") + " " + instrLbl
    contractCol  := rounded >= 1.0 ? color.green : color.orange
else if finalPointVal == 0
    contractText := "SET POINT VAL"
    contractCol  := color.red
else
    contractText := "NO SIGNAL"
    contractCol  := color.gray

// ═══════════════════════════════════════════════════════════════════════════════
// A+ SETUP
// ═══════════════════════════════════════════════════════════════════════════════
bool htfOk     = not useHTFFilter or (lastSignalState == 1 ? htfBullAligned : htfBearAligned)
bool aPlusBull = lastSignalState == 1  and activeScore >= 5 and (quadDivBull or hiddenBullDiv or stochPullText == "🎯 BULL FLAG ENTRY") and msOSC >= 50 and close > vwapV and htfOk
bool aPlusBear = lastSignalState == -1 and activeScore >= 5 and (quadDivBear or hiddenBearDiv or stochPullText == "🎯 BEAR FLAG ENTRY") and msOSC <= 50 and close < vwapV and htfOk

string aplusText = aPlusBull ? "🎯 A+ LONG" : aPlusBear ? "🎯 A+ SHORT" : activeScore >= 4 and msOSC >= 55 and close > vwapV ? "B LONG SETUP" : activeScore >= 4 and msOSC <= 45 and close < vwapV ? "B SHORT SETUP" : "— WAIT"
color  aplusCol  = aPlusBull ? color.green : aPlusBear ? color.red : activeScore >= 4 and msOSC >= 55 and close > vwapV ? color.rgb(0,180,0) : activeScore >= 4 and msOSC <= 45 and close < vwapV ? color.rgb(180,0,0) : color.gray

// ═══════════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════════
var table d = table.new(position.middle_left, 2, 26, bgcolor=color.new(#0A0A0A, 5), border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast
    string pos = dashPosition
    table.set_position(d, pos == "Top Left" ? position.top_left : pos == "Top Right" ? position.top_right : pos == "Middle Right" ? position.middle_right : pos == "Bottom Left" ? position.bottom_left : pos == "Bottom Right" ? position.bottom_right : position.middle_left)
    table.cell(d, 0, 0, "BULL SCORE",  text_color=color.white, bgcolor=color.green, text_size=dashTextSize)
    table.cell(d, 1, 0, str.tostring(bullPct,"#") + "%", text_color=color.white, bgcolor=color.green, text_size=dashTextSize)
    table.cell(d, 0, 1, "BEAR SCORE",  text_color=color.white, bgcolor=color.red,   text_size=dashTextSize)
    table.cell(d, 1, 1, str.tostring(bearPct,"#") + "%", text_color=color.white, bgcolor=color.red,   text_size=dashTextSize)
    table.cell(d, 0, 2, "MARKET BIAS", text_color=color.white, bgcolor=color.black, text_size=dashTextSize)
    table.cell(d, 1, 2, biasText, text_color=color.white, bgcolor=biasCol, text_size=dashTextSize)
    f_addDashRow(d, 3,  "Price/VWAP",   close > vwapV ? "ABOVE" : "BELOW",       close > vwapV ? color.green : color.red,    dashTextSize)
    f_addDashRow(d, 4,  "RSI (14)",     str.tostring(rsiVal,"#.#"),               rsiVal > 50 ? color.green : color.red,      dashTextSize)
    f_addDashRow(d, 5,  "MACD Trend",   m > s ? "BULL" : "BEAR",                 m > s ? color.green : color.red,            dashTextSize)
    f_addDashRow(d, 6,  "ADX Power",    str.tostring(adx,"#.#"),                  adx > 25 ? color.green : color.gray,        dashTextSize)
    f_addDashRow(d, 7,  "EMA Cross",    ema9 > ema21 ? "BULL" : "BEAR",           ema9 > ema21 ? color.green : color.red,     dashTextSize)
    f_addDashRow(d, 8,  "ATR 14",       str.tostring(atr,"#.##"),                 color.black,                                dashTextSize)
    f_addDashRow(d, 9,  "Vol Status",   volume > volAvg ? "HIGH" : "LOW",         volume > volAvg ? color.green : color.gray, dashTextSize)
    f_addDashRow(d, 10, "5m RSI",       str.tostring(rsi5m,"#.#"),                rsi5m > 50 ? color.green : color.red,       dashTextSize)
    f_addDashRow(d, 11, "Trend Str",    adx > 25 ? "STRONG" : "WEAK",             adx > 25 ? color.green : color.red,         dashTextSize)
    f_addDashRow(d, 12, "HTF Bias",     useHTFFilter ? htfText : "FILTER OFF",    useHTFFilter ? htfCol : color.gray,         dashTextSize)
    f_addDashRow(d, 13, "MSS Osc",      mssText,   mssCol,    dashTextSize)
    f_addDashRow(d, 14, "Structure",    structText, structCol, dashTextSize)
    f_addDashRow(d, 15, "Stoch Trend",  stochTrendText, stochTrendCol, dashTextSize)
    f_addDashRow(d, 16, "Stoch Pull",   stochPullText,  stochPullCol,  dashTextSize)
    f_addDashRow(d, 17, "Quad Status",  quadText, quadCol, dashTextSize)
    f_addDashRow(d, 18, "Exit Signal",  exitText, exitCol, dashTextSize)
    f_addDashRow(d, 19, "Hold Strength", holdText, holdCol, dashTextSize)
    f_addDashRow(d, 20, "Live R",        liveRText, liveRCol, dashTextSize)
    f_addDashRow(d, 21, "Size ($" + str.tostring(dollarRisk,"#") + "R)", contractText, contractCol, dashTextSize)
    f_addDashRow(d, 22, "Setup Grade",  aplusText, aplusCol, dashTextSize)
    f_addDashRow(d, 23, "MACD",         str.tostring(m,"#.##") + " / " + str.tostring(s,"#.##"), color.black, dashTextSize)
    f_addDashRow(d, 24, "Cycle Osc",    str.tostring(cycleFast,"#.#"), cycleFast > 50 ? color.green : color.red, dashTextSize)
    f_addDashRow(d, 25, "Sniper Mode",  "V4 — DoubleTheGreat", c_gold, dashTextSize)

// ═══════════════════════════════════════════════════════════════════════════════
// CHART VISUALS
// ═══════════════════════════════════════════════════════════════════════════════
p9  = plot(ema9,  color=color.new(emaFastColor, 20), linewidth=1, title="Fast EMA")
p21 = plot(ema21, color=color.new(emaSlowColor, 20), linewidth=1, title="Slow EMA")
fill(p9, p21, color = ema9 > ema21 ? color.new(emaBullFill, 100 - ribbonOpacity) : color.new(emaBearFill, 100 - ribbonOpacity))
plot(vwapV, color=close > vwapV ? color.green : color.red, linewidth=2, title="VWAP")

plot(showUT and showUTLine ? xATRTrailingStop : na, color=utLineColor, linewidth=2, title="UT Bot Trailing Stop")
plotshape(showUT and showUTLabels and utBuy,  title="UT Buy",  text="Buy",  style=shape.labelup,   location=location.belowbar, color=color.green, textcolor=color.white, size=size.tiny)
plotshape(showUT and showUTLabels and utSell, title="UT Sell", text="Sell", style=shape.labeldown, location=location.abovebar, color=color.red,   textcolor=color.white, size=size.tiny)

plotshape(showMSS and showMSSSig and mssCrossUp,   title="MSS Bull Cross", text="M▲", style=shape.labelup,   location=location.belowbar, color=msBullColor, textcolor=color.white, size=size.tiny)
plotshape(showMSS and showMSSSig and mssCrossDown, title="MSS Bear Cross", text="M▼", style=shape.labeldown, location=location.abovebar, color=msBearColor, textcolor=color.white, size=size.tiny)
plotshape(showMSS and showCycleOsc and cycCrossUp,   title="Cycle Bull", text="C▲", style=shape.labelup,   location=location.belowbar, color=cycBullColor, textcolor=color.white, size=size.tiny)
plotshape(showMSS and showCycleOsc and cycCrossDown, title="Cycle Bear", text="C▼", style=shape.labeldown, location=location.abovebar, color=cycBearColor, textcolor=color.white, size=size.tiny)

plotshape(aPlusBull, title="A+ Long",  text="A+", style=shape.labelup,   location=location.belowbar, color=color.new(color.green,20), textcolor=color.white, size=size.small)
plotshape(aPlusBear, title="A+ Short", text="A+", style=shape.labeldown, location=location.abovebar, color=color.new(color.red,  20), textcolor=color.white, size=size.small)
plotshape(quadDivBull,   title="Quad Bull",   text="Q▲", style=shape.labelup,   location=location.belowbar, color=c_gold,   textcolor=color.black, size=size.tiny)
plotshape(quadDivBear,   title="Quad Bear",   text="Q▼", style=shape.labeldown, location=location.abovebar, color=c_gold,   textcolor=color.black, size=size.tiny)
plotshape(hiddenBullDiv, title="Hidden Bull", text="H▲", style=shape.labelup,   location=location.belowbar, color=c_purple, textcolor=color.white, size=size.tiny)
plotshape(hiddenBearDiv, title="Hidden Bear", text="H▼", style=shape.labeldown, location=location.abovebar, color=c_purple, textcolor=color.white, size=size.tiny)

isRetest = (lastSignalState == 1 and low <= ema9 and low > ema21) or (lastSignalState == -1 and high >= ema9 and high < ema21)
barcolor(showUT and showUTBarcolor ? (utBarUp ? utBullColor : utBearColor) : (triggerBuy or triggerSell) ? signalColor : showRetest and isRetest ? retestColor : na)

plotshape(triggerBuy,  text="BUY",  style=shape.labelup,   location=location.belowbar, color=color.green, textcolor=color.white, size=size.small)
plotshape(triggerSell, text="SELL", style=shape.labeldown,  location=location.abovebar, color=color.red,   textcolor=color.white, size=size.small)

// ═══════════════════════════════════════════════════════════════════════════════
// TP / SL LINES & LABELS
// ═══════════════════════════════════════════════════════════════════════════════
var line lE = na, var line lSL = na
var line lT1 = na, var line lT2 = na, var line lT3 = na, var line lT4 = na, var line lT5 = na
var label lbE  = label.new(na, na, "", color=color.blue,         textcolor=color.white, style=label.style_label_left, size=tradeTextSize)
var label lbSL = label.new(na, na, "", color=color.red,          textcolor=color.white, style=label.style_label_left, size=tradeTextSize)
var label lbT1 = label.new(na, na, "", color=color.green,        textcolor=color.white, style=label.style_label_left, size=tradeTextSize)
var label lbT2 = label.new(na, na, "", color=color.green,        textcolor=color.white, style=label.style_label_left, size=tradeTextSize)
var label lbT3 = label.new(na, na, "", color=color.green,        textcolor=color.white, style=label.style_label_left, size=tradeTextSize)
var label lbT4 = label.new(na, na, "", color=color.rgb(0,100,0), textcolor=color.white, style=label.style_label_left, size=tradeTextSize)
var label lbT5 = label.new(na, na, "", color=color.rgb(0,70,0),  textcolor=color.white, style=label.style_label_left, size=tradeTextSize)

if triggerBuy or triggerSell
    line.delete(lE),  line.delete(lSL)
    line.delete(lT1), line.delete(lT2), line.delete(lT3), line.delete(lT4), line.delete(lT5)
    lE  := line.new(bar_index, entryP, bar_index+20, entryP, color=color.blue,        width=2, extend=extend.right)
    lSL := line.new(bar_index, slP,    bar_index+20, slP,    color=color.red,          width=2, extend=extend.right)
    lT1 := line.new(bar_index, t1,     bar_index+20, t1,     color=color.green,        style=line.style_dashed, extend=extend.right)
    lT2 := line.new(bar_index, t2,     bar_index+20, t2,     color=color.green,        style=line.style_dashed, extend=extend.right)
    lT3 := line.new(bar_index, t3,     bar_index+20, t3,     color=color.green,        style=line.style_dashed, extend=extend.right)
    lT4 := line.new(bar_index, t4,     bar_index+20, t4,     color=color.rgb(0,100,0), width=2, extend=extend.right)
    lT5 := line.new(bar_index, t5,     bar_index+20, t5,     color=color.rgb(0,70,0),  width=3, extend=extend.right)

if lastSignalState != 0
    int tX = bar_index + labelOffset
    line.set_color(lT1, t1Hit ? c_turquoise : color.green)
    line.set_color(lT2, t2Hit ? c_turquoise : color.green)
    line.set_color(lT3, t3Hit ? c_turquoise : color.green)
    line.set_color(lT4, t4Hit ? c_turquoise : color.rgb(0,100,0))
    line.set_color(lT5, t5Hit ? c_turquoise : color.rgb(0,70,0))
    label.set_xy(lbE,  tX, entryP), label.set_text(lbE,  "ENTRY: " + str.tostring(entryP,"#.##"))
    label.set_xy(lbSL, tX, slP),    label.set_text(lbSL, "SL: "    + str.tostring(slP,   "#.##"))
    label.set_xy(lbT1, tX, t1),     label.set_text(lbT1, "TP1: "   + str.tostring(t1,"#.##") + (t1Hit ? " 🔥" : ""))
    label.set_xy(lbT2, tX, t2),     label.set_text(lbT2, "TP2: "   + str.tostring(t2,"#.##") + (t2Hit ? " 🔥" : ""))
    label.set_xy(lbT3, tX, t3),     label.set_text(lbT3, "TP3: "   + str.tostring(t3,"#.##") + (t3Hit ? " 🔥" : ""))
    label.set_xy(lbT4, tX, t4),     label.set_text(lbT4, "TP4: "   + str.tostring(t4,"#.##") + (t4Hit ? " 🔥" : ""))
    label.set_xy(lbT5, tX, t5),     label.set_text(lbT5, "TP5: "   + str.tostring(t5,"#.##") + (t5Hit ? " 🔥" : ""))

// ═══════════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(aPlusBull,                    title="A+ Long Setup",      message="Sniper Gang V4 — A+ LONG setup confirmed")
alertcondition(aPlusBear,                    title="A+ Short Setup",     message="Sniper Gang V4 — A+ SHORT setup confirmed")
alertcondition(quadDivBull,                  title="Quad Bull Reversal", message="Sniper Gang V4 — QUAD BULL REVERSAL fired")
alertcondition(quadDivBear,                  title="Quad Bear Reversal", message="Sniper Gang V4 — QUAD BEAR REVERSAL fired")
alertcondition(hiddenBullDiv,                title="Hidden Bull Div",    message="Sniper Gang V4 — HIDDEN BULL divergence")
alertcondition(hiddenBearDiv,                title="Hidden Bear Div",    message="Sniper Gang V4 — HIDDEN BEAR divergence")
alertcondition(exitWarnBull or exitWarnBear, title="Exit Warning",       message="Sniper Gang V4 — EXIT WARNING")
alertcondition(mssCrossUp,                   title="MSS Bull Cross",     message="Sniper Gang V4 — MSS BULL cross")
alertcondition(mssCrossDown,                 title="MSS Bear Cross",     message="Sniper Gang V4 — MSS BEAR cross")
alertcondition(cycCrossUp,                   title="Cycle Bull Cross",   message="Sniper Gang V4 — CYCLE BULL cross")
alertcondition(cycCrossDown,                 title="Cycle Bear Cross",   message="Sniper Gang V4 — CYCLE BEAR cross")
alertcondition(showUT and utBuy,             title="UT BOT Buy",         message="UT BOT Buy")
alertcondition(showUT and utSell,            title="UT BOT Sell",        message="UT BOT Sell")
````
