# Vector Sniper Pro 

- url: https://www.tradingview.com/script/pWNFuBOn-Vector-Sniper-Pro/
- type: indicator
- pine_id: PUB;1ce4fffb4b504d4fb61b8e8501e28eed
- version: 1.0

## Description

Vector Sniper Pro V3 | Session Edge

Overview

Vector Sniper Pro V3 is a multi-layered signal detection system built around four core concepts: institutional order flow, smart money manipulation patterns, volume-weighted momentum, and inter-session directional bias. It paints candles to reflect signal state — no separate panel required.

Core Signal Engine

The foundation is a volatility-normalized momentum filter. Each bar is scored using a Z-score of ATR(1) against a rolling mean and standard deviation — this isolates bars where volatility is statistically elevated above baseline noise rather than simply "large." Volume is scored the same way. A signal requires both to exceed their respective thresholds simultaneously, filtering out high-volume low-range bars (absorption) and high-range low-volume bars (false breakouts) from the primary vector set.

Delta volume is approximated by weighting bar volume by the close position within the range: bull volume = volume × (close − low) / range, bear volume = volume × (high − close) / range. The delta ratio (net delta / total volume) must confirm directional conviction, requiring >0.2 for bull signals and <−0.2 for bear. This proxy for order flow imbalance eliminates candles where volume was present but directionally uncommitted.

Structure Break Requirement

Rather than using a raw N-bar highest/lowest comparison, the script identifies confirmed swing points — a pivot high requires the bar to be higher than the two bars on each side. Price must close beyond the most recent confirmed swing high (for bulls) or swing low (for bears) to qualify as a structure break. This reduces false signals during consolidation where price repeatedly tests but never genuinely breaks a level.

Smart Money / Manipulation Detection

Five manipulation signatures are detected independently and fed into the scoring system:

Stop Hunt: Price spikes below the N-bar low (or above the N-bar high) then immediately closes back in the opposite direction with elevated volume — characteristic of liquidity sweeps before reversal.
Absorption: High volume Z-score but very low ATR Z-score (range < 0.5 SD). When volume is present but range is compressed, large participants are absorbing retail orders rather than moving price.
Wick Rejection: A wick exceeding a configurable percentage of the total bar range, combined with volume above the 20-bar average — institutional rejection at a level.
Cumulative Delta Divergence: Price makes a new N-bar high but the current delta is lower than the prior period's highest delta (distribution). Conversely, price makes a new low while delta is rising (accumulation). This is the most reliable leading indicator of manipulation in the system and carries the highest score weight (2.0 points).
RSI Divergence: Price makes a new 14-bar extreme while RSI fails to confirm, indicating momentum exhaustion.
Pre-Signal Scoring System

Before a full vector fires, each bar receives a weighted composite score (maximum ~14 points) across 13 factors:

Factor	Weight
Spring / Upthrust (Wyckoff)	2.0
Cumulative Delta Divergence	2.0
RSI Divergence	1.5
Stop Hunt detection	1.5
VWAP + EMA trend alignment	1.5
Session bias alignment	1.5 (configurable)
Fade of prior session level	1.5
No Supply / No Demand (VSA)	1.0
Delta imbalance ratio	1.0
Near structure break zone	1.0
Break of prior session level	1.0
Volume ratio > 1.2× average	0.5
Bar direction (close vs open)	1.0
A pre-signal requires the score to meet a configurable minimum threshold and to appear N times within a rolling M-bar window, preventing single-bar spikes from triggering. A cooldown period prevents signal clustering, and a hysteresis lock prevents rapid directional flipping.

Session Edge System

The script tracks live OHLC for Asia (20:00–02:00 ET), London (02:00–08:00 ET), NY Pre-Market (04:00–09:30 ET), NY Regular (09:30–16:00 ET), and NY After-Hours (16:00–20:00 ET). All times and timezone are configurable.

When a session closes, its high, low, midpoint, and directional close (green or red) are stored. During the following session:

Prior session levels (H/L/Mid) are plotted as reference lines — yellow for Asia levels during London, aqua for London levels during NY.
Session bias activates based on the closing direction of the prior session. A green Asia close generates a bull bias for London; a red Asia close generates a bear bias. The same logic applies London→NY. Bias adds configurable weight to the scoring system and can optionally hard-block counter-trend signals.
Level interaction detection fires when price touches a prior session level: a fade signal requires a wick rejection back through the level with volume; a break signal requires a close through the level with volume. Both feed the scoring system.
Live hit-rate table (toggle-able) tracks how often the prior session's direction correctly predicted the current session's direction — validated on your specific instrument and timeframe in real time rather than relying on aggregate statistics.
Candle Color System

Color	Meaning
Neon green	Bull vector (base condition met)
Red	Bear vector
White	Confirmed bull trend change (regime flip + extreme conditions)
Purple	Confirmed bear trend change
Blue	Pre-bull signal (score threshold met, not yet full vector)
Orange	Pre-bear signal
Dark green (faint)	Regular bull reversal (regime flip, standard strength)
Dark purple (faint)	Regular bear reversal
Grey	No qualifying condition
How to Use

The indicator is designed to be used on any liquid instrument with real volume data. Session times are set for US Eastern Time by default — adjust the timezone input for your exchange.

Start with candle colors only (all markers off by default). Enable the hit-rate table to validate whether the Asia→London and London→NY bias is statistically meaningful on your specific symbol before relying on it. Enable prior session levels to identify the key prices where fade and break decisions occur. The pre-signal (blue/orange) candles appear before a full vector fires and can be used for earlier entries with the understanding that confirmation has not yet occurred.

All inputs have been grouped and labelled to allow systematic adjustment: tighten the Z-score thresholds to reduce signal frequency, raise the minimum score to require stronger multi-factor confluence, and use the cooldown and hysteresis settings to control how often the system can re-trigger in the same direction.

## Source Code

````pine
//@version=6
indicator("Vector Sniper Pro V3 | Session Edge", shorttitle="VSniperV3", overlay=true, max_labels_count=500, max_boxes_count=200, max_lines_count=500)

// ───────── Inputs

group_core = "🎯 Core"
atrLen   = input.int(14,  "ATR Period",           group=group_core, minval=5)
volLen   = input.int(20,  "Volume Period",         group=group_core, minval=5)
trZThr   = input.float(1.2, "Volatility Z-Score", group=group_core, step=0.1)
volZThr  = input.float(1.0, "Volume Z-Score",     group=group_core, step=0.1)
extMult  = input.float(1.8, "Extreme Multiplier", group=group_core, step=0.1)
rsiLen   = input.int(14,  "RSI Length",            group=group_core, minval=2)
cdLen    = input.int(10,  "Cum Delta Lookback",    group=group_core, minval=3)

group_confirm = "✅ Vector Filters"
minBodyPct = input.int(55, "Min Body %",              group=group_confirm, minval=1, maxval=100)
lbBreak    = input.int(5,  "Structure Break (bars)",  group=group_confirm, minval=1)
useBreak   = input.bool(true, "Require Structure Break", group=group_confirm)
useSwing   = input.bool(true, "Use Swing Point Breaks", group=group_confirm)
useTrap    = input.bool(true, "Detect Traps",            group=group_confirm)

group_manip = "🕵️ Manipulation Detection"
useAbsorption = input.bool(true, "Detect Absorption",        group=group_manip)
useStopHunt   = input.bool(true, "Detect Stop Hunts",        group=group_manip)
useWickRej    = input.bool(true, "Detect Wick Rejection",    group=group_manip)
useCDDiv      = input.bool(true, "Cum Delta Divergence",     group=group_manip)
useRSIDiv     = input.bool(true, "RSI Divergence",           group=group_manip)
stopHuntLB    = input.int(10,   "Stop Hunt Lookback",        group=group_manip, minval=3)
wickRejPct    = input.float(40.0,"Wick Rejection %",         group=group_manip, step=5.0)

group_pre = "🔮 Pre-Signal Filter"
preMinScore   = input.float(4.0, "Min Score",                group=group_pre, minval=1.0, maxval=14.0, step=0.5)
persistN      = input.int(2,   "Must occur N bars",          group=group_pre, minval=1, maxval=5)
persistWindow = input.int(4,   "Within last M bars",         group=group_pre, minval=1, maxval=10)
cooldownBars  = input.int(6,   "Cooldown",                   group=group_pre, minval=0, maxval=100)
conflictLock  = input.int(4,   "Hysteresis vs opposite",     group=group_pre, minval=0, maxval=20)
useVWAP       = input.bool(true, "VWAP side alignment",      group=group_pre)
useEMA        = input.bool(true, "EMA trend alignment",      group=group_pre)
emaLen        = input.int(50,  "EMA Length",                 group=group_pre, minval=5)
useHTF        = input.bool(false,"HTF confluence",           group=group_pre)
htf           = input.timeframe("60", "HTF",                 group=group_pre)

group_sess = "🌍 Session Edge (Asia→London→NY)"
useSessionEdge = input.bool(true, "Enable Session Edge Logic",  group=group_sess)
asiaSess   = input.session("2000-0200:1234567", "Asia Session (ET)",       group=group_sess)
londonSess = input.session("0200-0800:1234567", "London Session (ET)",     group=group_sess)
nyPreSess  = input.session("0400-0930:1234567", "NY Pre-Market (ET)",      group=group_sess)
nyRegSess  = input.session("0930-1600:1234567", "NY Regular (ET)",         group=group_sess)
nyAftSess  = input.session("1600-2000:1234567", "NY After-Hours (ET)",     group=group_sess)
sessTZ     = input.string("America/New_York", "Session Timezone",          group=group_sess, options=["America/New_York","Europe/London","Asia/Tokyo","UTC"])
biasDelayBars = input.int(0, "Bias activation delay (bars after close)", group=group_sess, minval=0, maxval=50)
showPrevLevels = input.bool(false, "Plot Prior Session Levels", group=group_sess)
showBiasBG     = input.bool(false, "Shade Bias Direction in Next Session", group=group_sess)
biasScoreWt    = input.float(1.5, "Bias score weight",          group=group_sess, minval=0.0, maxval=5.0, step=0.5)
useBiasFilter  = input.bool(false, "Hard-block counter-bias signals", group=group_sess)
levelTagATR    = input.float(0.15, "Level tag proximity (ATR mult)", group=group_sess, step=0.05)
hitRateWindow  = input.int(50, "Hit-rate sample size (sessions)", group=group_sess, minval=5, maxval=500)
showStatsTable = input.bool(false, "Show Hit-Rate Table",       group=group_sess)

group_time = "⏰ Signal Time Filter"
useSession  = input.bool(false, "Restrict signals to a window", group=group_time)
sessionStr  = input.session("0700-1600", "Window",              group=group_time)

group_style = "🎨 Visuals"
colorizeCandles = input.bool(true,  "Color Candles",                group=group_style)
showMarks       = input.bool(false, "Show signal markers",          group=group_style)
showManip       = input.bool(false, "Show manipulation markers",    group=group_style)
showFadeBreak   = input.bool(false, "Show fade/break arrows",       group=group_style)

// ───────── Helpers

f_z(src, len) =>
    _ma = ta.sma(src, len)
    _sd = ta.stdev(src, len)
    _sd == 0.0 ? 0.0 : (src - _ma) / _sd

inSessFn(s) => not na(time(timeframe.period, s, sessTZ))

// ───────── Core calcs

atr1  = ta.atr(1)
atr10 = ta.atr(10)
atr14 = ta.atr(14)
trZ   = f_z(atr1, atrLen)
volZ  = f_z(volume, volLen)
rng   = math.max(high - low, 1e-10)
body  = math.abs(close - open)
bodyPct = (body / rng) * 100.0

avgVol   = ta.sma(volume, 20)
volRatio = volume / math.max(avgVol, 1e-10)

vwap = ta.vwap
ema  = ta.ema(close, emaLen)
emaUp = ema > ema[1]
emaDn = ema < ema[1]
vUp   = vwap > vwap[1]
vDn   = vwap < vwap[1]

htfBull = useHTF ? request.security(syminfo.tickerid, htf, close) > request.security(syminfo.tickerid, htf, ta.ema(close, emaLen)) : true
htfBear = useHTF ? request.security(syminfo.tickerid, htf, close) < request.security(syminfo.tickerid, htf, ta.ema(close, emaLen)) : true

bullVol    = volume * (close - low)  / rng
bearVol    = volume * (high  - close) / rng
delta      = bullVol - bearVol
deltaRatio = delta / math.max(volume, 1e-10)

// ───────── SESSION EDGE SYSTEM ─────────

// Session membership (this bar is inside which session)
inAsia    = inSessFn(asiaSess)
inLondon  = inSessFn(londonSess)
inNYPre   = inSessFn(nyPreSess)
inNYReg   = inSessFn(nyRegSess)
inNYAft   = inSessFn(nyAftSess)

// Session start transitions (first bar of each session)
asiaStart    = inAsia   and not inAsia[1]
londonStart  = inLondon and not inLondon[1]
nyPreStart   = inNYPre  and not inNYPre[1]
nyRegStart   = inNYReg  and not inNYReg[1]
nyAftStart   = inNYAft  and not inNYAft[1]

// Session end transitions
asiaEnd    = not inAsia   and inAsia[1]
londonEnd  = not inLondon and inLondon[1]
nyPreEnd   = not inNYPre  and inNYPre[1]
nyRegEnd   = not inNYReg  and inNYReg[1]
nyAftEnd   = not inNYAft  and inNYAft[1]

// Live session OHLC tracking
var float asiaO = na, var float asiaH = na, var float asiaL = na, var float asiaC = na
var float lonO  = na, var float lonH  = na, var float lonL  = na, var float lonC  = na
var float nyRO  = na, var float nyRH  = na, var float nyRL  = na, var float nyRC  = na

// Prior (completed) session values — what we trade off of
var float pAsiaO = na, var float pAsiaH = na, var float pAsiaL = na, var float pAsiaC = na, var float pAsiaMid = na
var float pLonO  = na, var float pLonH  = na, var float pLonL  = na, var float pLonC  = na, var float pLonMid  = na
var float pNYO   = na, var float pNYH   = na, var float pNYL   = na, var float pNYC   = na, var float pNYMid   = na

// Asia tracking
if asiaStart
    asiaO := open
    asiaH := high
    asiaL := low
if inAsia
    asiaH := math.max(nz(asiaH, high), high)
    asiaL := math.min(nz(asiaL, low),  low)
    asiaC := close
if asiaEnd
    pAsiaO   := asiaO
    pAsiaH   := asiaH
    pAsiaL   := asiaL
    pAsiaC   := asiaC
    pAsiaMid := (asiaH + asiaL) / 2.0

// London tracking
if londonStart
    lonO := open
    lonH := high
    lonL := low
if inLondon
    lonH := math.max(nz(lonH, high), high)
    lonL := math.min(nz(lonL, low),  low)
    lonC := close
if londonEnd
    pLonO   := lonO
    pLonH   := lonH
    pLonL   := lonL
    pLonC   := lonC
    pLonMid := (lonH + lonL) / 2.0

// NY Regular tracking
if nyRegStart
    nyRO := open
    nyRH := high
    nyRL := low
if inNYReg
    nyRH := math.max(nz(nyRH, high), high)
    nyRL := math.min(nz(nyRL, low),  low)
    nyRC := close
if nyRegEnd
    pNYO   := nyRO
    pNYH   := nyRH
    pNYL   := nyRL
    pNYC   := nyRC
    pNYMid := (nyRH + nyRL) / 2.0

// Session direction (green = close > open)
pAsiaGreen = not na(pAsiaC) and not na(pAsiaO) and pAsiaC > pAsiaO
pAsiaRed   = not na(pAsiaC) and not na(pAsiaO) and pAsiaC < pAsiaO
pLonGreen  = not na(pLonC)  and not na(pLonO)  and pLonC  > pLonO
pLonRed    = not na(pLonC)  and not na(pLonO)  and pLonC  < pLonO
pNYGreen   = not na(pNYC)   and not na(pNYO)   and pNYC   > pNYO
pNYRed     = not na(pNYC)   and not na(pNYO)   and pNYC   < pNYO

// ACTIVE BIAS — derived from what just completed, applies during next session
// Asia closed → bias active for London
// London closed → bias active for NY Regular
// NY Regular closed → bias rolls into next Asia (for overnight/after-hours)
var int asiaClosedBarIdx = na
var int lonClosedBarIdx  = na
var int nyClosedBarIdx   = na

if asiaEnd
    asiaClosedBarIdx := bar_index
if londonEnd
    lonClosedBarIdx  := bar_index
if nyRegEnd
    nyClosedBarIdx   := bar_index

asiaBiasReady = not na(asiaClosedBarIdx) and (bar_index - asiaClosedBarIdx) >= biasDelayBars
lonBiasReady  = not na(lonClosedBarIdx)  and (bar_index - lonClosedBarIdx)  >= biasDelayBars
nyBiasReady   = not na(nyClosedBarIdx)   and (bar_index - nyClosedBarIdx)   >= biasDelayBars

// Which bias applies right now?
biasBull = useSessionEdge and ((inLondon and asiaBiasReady and pAsiaGreen) or ((inNYPre or inNYReg) and lonBiasReady and pLonGreen) or (inNYAft and nyBiasReady and pNYGreen))
biasBear = useSessionEdge and ((inLondon and asiaBiasReady and pAsiaRed)   or ((inNYPre or inNYReg) and lonBiasReady and pLonRed)   or (inNYAft and nyBiasReady and pNYRed))

// ───────── LEVEL TAGGING & FADE/BREAK ─────────

// Which prior-session levels are relevant now?
relevantH = inLondon ? pAsiaH : (inNYPre or inNYReg) ? pLonH : inNYAft ? pNYH : na
relevantL = inLondon ? pAsiaL : (inNYPre or inNYReg) ? pLonL : inNYAft ? pNYL : na
relevantM = inLondon ? pAsiaMid : (inNYPre or inNYReg) ? pLonMid : inNYAft ? pNYMid : na

tagProx = atr14 * levelTagATR

// Tag = price touched within proximity band
tagHi = not na(relevantH) and (high >= relevantH - tagProx) and (low <= relevantH + tagProx)
tagLo = not na(relevantL) and (high >= relevantL - tagProx) and (low <= relevantL + tagProx)
tagMi = not na(relevantM) and (high >= relevantM - tagProx) and (low <= relevantM + tagProx)

// Wick percentages
upperWickPct = (high - math.max(open, close)) / rng * 100
lowerWickPct = (math.min(open, close) - low)  / rng * 100

// Fade = touched, rejected back with volume; Break = closed through with volume

fadeHiBear = tagHi and close < relevantH and upperWickPct > 30 and volRatio > 1.2
fadeLoBull = tagLo and close > relevantL and lowerWickPct > 30 and volRatio > 1.2

breakHiBull = tagHi and close > relevantH and volRatio > 1.3 and (close - open) > 0
breakLoBear = tagLo and close < relevantL and volRatio > 1.3 and (open - close) > 0

// ───────── HIT-RATE TRACKING ─────────
// Live validation on this specific instrument

var int asiaGreenN   = 0, var int asiaGreenLonGreen = 0
var int asiaRedN     = 0, var int asiaRedLonRed     = 0
var int lonGreenN    = 0, var int lonGreenNYGreen   = 0
var int lonRedN      = 0, var int lonRedNYRed       = 0

// When London ends, score it against the prior Asia direction
if londonEnd and not na(pAsiaC) and not na(pAsiaO) and not na(lonO)
    lonWasGreen = lonC > lonO
    lonWasRed   = lonC < lonO
    if pAsiaGreen
        asiaGreenN := asiaGreenN + 1
        if lonWasGreen
            asiaGreenLonGreen := asiaGreenLonGreen + 1
    if pAsiaRed
        asiaRedN := asiaRedN + 1
        if lonWasRed
            asiaRedLonRed := asiaRedLonRed + 1

// When NY Regular ends, score it against prior London direction
if nyRegEnd and not na(pLonC) and not na(pLonO) and not na(nyRO)
    nyWasGreen = nyRC > nyRO
    nyWasRed   = nyRC < nyRO
    if pLonGreen
        lonGreenN := lonGreenN + 1
        if nyWasGreen
            lonGreenNYGreen := lonGreenNYGreen + 1
    if pLonRed
        lonRedN := lonRedN + 1
        if nyWasRed
            lonRedNYRed := lonRedNYRed + 1

hitRate_AG_LG = asiaGreenN > 0 ? (asiaGreenLonGreen / asiaGreenN) * 100 : 0.0
hitRate_AR_LR = asiaRedN   > 0 ? (asiaRedLonRed     / asiaRedN)   * 100 : 0.0
hitRate_LG_NG = lonGreenN  > 0 ? (lonGreenNYGreen   / lonGreenN)  * 100 : 0.0
hitRate_LR_NR = lonRedN    > 0 ? (lonRedNYRed       / lonRedN)    * 100 : 0.0

// ───────── Cumulative Delta Divergence

cumDelta     = ta.cum(delta)
priceMadeHH  = high == ta.highest(high, cdLen)
deltaMadeLH  = delta < nz(ta.highest(delta, cdLen)[1])
cdDivBear    = useCDDiv and priceMadeHH and deltaMadeLH and volRatio > 1.2

priceMadeLL  = low == ta.lowest(low, cdLen)
deltaMadeHL  = delta > nz(ta.lowest(delta, cdLen)[1])
cdDivBull    = useCDDiv and priceMadeLL and deltaMadeHL and volRatio > 1.2

// ───────── RSI Divergence

rsiVal     = ta.rsi(close, rsiLen)
rsiDivBull = useRSIDiv and (low == ta.lowest(low, 14)) and (rsiVal > nz(ta.lowest(rsiVal, 14)[1]))
rsiDivBear = useRSIDiv and (high == ta.highest(high, 14)) and (rsiVal < nz(ta.highest(rsiVal, 14)[1]))

// ───────── Structure

swingHigh = high[2] > high[1] and high[2] > high[3] and high[2] > high[0]
swingLow  = low[2]  < low[1]  and low[2]  < low[3]  and low[2]  < low[0]
lastSwingHigh = ta.valuewhen(swingHigh, high[2], 0)
lastSwingLow  = ta.valuewhen(swingLow,  low[2],  0)
trueBreakBull = close > lastSwingHigh
trueBreakBear = close < lastSwingLow

prevHighN = ta.highest(high, lbBreak)[1]
prevLowN  = ta.lowest(low,  lbBreak)[1]
legacyBreakBull = high > prevHighN
legacyBreakBear = low  < prevLowN

bullBreak = useSwing ? trueBreakBull : legacyBreakBull
bearBreak = useSwing ? trueBreakBear : legacyBreakBear

// ───────── Manipulation Detection

wickRejBull = useWickRej and lowerWickPct > wickRejPct and volRatio > 1.5
wickRejBear = useWickRej and upperWickPct > wickRejPct and volRatio > 1.5

absorptionBull = useAbsorption and volZ >= volZThr and trZ < 0.5 and close > open
absorptionBear = useAbsorption and volZ >= volZThr and trZ < 0.5 and close < open

stopHuntBull = useStopHunt and (low < ta.lowest(low, stopHuntLB)[1]) and (close > open) and (close > low[1]) and volRatio > 1.3
stopHuntBear = useStopHunt and (high > ta.highest(high, stopHuntLB)[1]) and (close < open) and (close < high[1]) and volRatio > 1.3

bearTrap = useTrap and low  < low[1]  and low  < low[2]  and close > high[1]
bullTrap = useTrap and high > high[1] and high > high[2] and close < low[1]

manipBull = wickRejBull or absorptionBull or stopHuntBull or bearTrap or cdDivBull or rsiDivBull
manipBear = wickRejBear or absorptionBear or stopHuntBear or bullTrap or cdDivBear or rsiDivBear

// ───────── Smart-money hints

lowest3  = ta.lowest(low, 3)
highest3 = ta.highest(high, 3)
spring   = (low < lowest3[1])   and (close > lowest3[1])   and volRatio > 1.0
upthrust = (high > highest3[1]) and (close < highest3[1])  and volRatio > 1.0
noSupply = (close > close[1]) and (volume < volume[1]) and (rng < atr10 * 0.7)
noDemand = (close < close[1]) and (volume < volume[1]) and (rng < atr10 * 0.7)
imbBull = deltaRatio > 0.25
imbBear = deltaRatio < -0.25
nearBullBreak = math.abs(close - prevHighN) <= atr14 * 0.3
nearBearBreak = math.abs(close - prevLowN)  <= atr14 * 0.3

bullSideOK = (not useVWAP or (close > vwap and vUp)) and (not useEMA or emaUp) and htfBull
bearSideOK = (not useVWAP or (close < vwap and vDn)) and (not useEMA or emaDn) and htfBear

// ───────── Weighted Score (with session bias)

bullScoreW = (spring       ? 2.0 : 0.0) +
             (cdDivBull    ? 2.0 : 0.0) +
             (rsiDivBull   ? 1.5 : 0.0) +
             (stopHuntBull ? 1.5 : 0.0) +
             (noSupply     ? 1.0 : 0.0) +
             (imbBull      ? 1.0 : 0.0) +
             (volRatio > 1.2 ? 0.5 : 0.0) +
             (bullSideOK   ? 1.5 : 0.0) +
             (nearBullBreak? 1.0 : 0.0) +
             (close > open ? 1.0 : 0.0) +
             (fadeLoBull   ? 1.5 : 0.0) +
             (breakHiBull  ? 1.0 : 0.0) +
             (biasBull     ? biasScoreWt : 0.0)

bearScoreW = (upthrust     ? 2.0 : 0.0) +
             (cdDivBear    ? 2.0 : 0.0) +
             (rsiDivBear   ? 1.5 : 0.0) +
             (stopHuntBear ? 1.5 : 0.0) +
             (noDemand     ? 1.0 : 0.0) +
             (imbBear      ? 1.0 : 0.0) +
             (volRatio > 1.2 ? 0.5 : 0.0) +
             (bearSideOK   ? 1.5 : 0.0) +
             (nearBearBreak? 1.0 : 0.0) +
             (close < open ? 1.0 : 0.0) +
             (fadeHiBear   ? 1.5 : 0.0) +
             (breakLoBear  ? 1.0 : 0.0) +
             (biasBear     ? biasScoreWt : 0.0)

preBullRaw = bullScoreW >= preMinScore
preBearRaw = bearScoreW >= preMinScore

// ───────── Base vectors

sigWindow = not useSession or not na(time(timeframe.period, sessionStr, sessTZ))

// Hard bias filter (optional)
biasAllowBull = not useBiasFilter or not useSessionEdge or not biasBear
biasAllowBear = not useBiasFilter or not useSessionEdge or not biasBull

baseBull = (close > open) and (trZ >= trZThr) and (volZ >= volZThr) and (bodyPct >= minBodyPct) and (deltaRatio > 0.2) and sigWindow and biasAllowBull
baseBear = (close < open) and (trZ >= trZThr) and (volZ >= volZThr) and (bodyPct >= minBodyPct) and (deltaRatio < -0.2) and sigWindow and biasAllowBear

bullCond = (baseBull and (not useBreak or bullBreak)) or (bearTrap and biasAllowBull) or (stopHuntBull and biasAllowBull)
bearCond = (baseBear and (not useBreak or bearBreak)) or (bullTrap and biasAllowBear) or (stopHuntBear and biasAllowBear)

extBull = bullCond and trZ >= trZThr * extMult and volZ >= volZThr * extMult
extBear = bearCond and trZ >= trZThr * extMult and volZ >= volZThr * extMult

// ───────── Persistence + Cooldown

bullRawNum = preBullRaw ? 1 : 0
bearRawNum = preBearRaw ? 1 : 0
bullCum = ta.cum(bullRawNum)
bearCum = ta.cum(bearRawNum)
recentBull = bullCum - nz(bullCum[persistWindow], 0)
recentBear = bearCum - nz(bearCum[persistWindow], 0)
preBullPersist = recentBull >= persistN
preBearPersist = recentBear >= persistN

var int lastPreBull = na
var int lastPreBear = na
canBull = (na(lastPreBull) or bar_index - lastPreBull > cooldownBars) and (na(lastPreBear) or bar_index - lastPreBear > conflictLock)
canBear = (na(lastPreBear) or bar_index - lastPreBear > cooldownBars) and (na(lastPreBull) or bar_index - lastPreBull > conflictLock)

preBull = preBullPersist and canBull and sigWindow and biasAllowBull
preBear = preBearPersist and canBear and sigWindow and biasAllowBear

lastPreBull := preBull ? bar_index : lastPreBull
lastPreBear := preBear ? bar_index : lastPreBear

// ───────── Regime Tracker

var int trendRegime = 0
trendRegime := bullCond or extBull ? 1 : bearCond or extBear ? -1 : trendRegime
regimeFlipBull = trendRegime == 1  and trendRegime[1] == -1
regimeFlipBear = trendRegime == -1 and trendRegime[1] == 1

confirmedBullTrend = regimeFlipBull and (extBull or (bullCond and trZ >= trZThr * 1.5 and volZ >= volZThr * 1.5))
confirmedBearTrend = regimeFlipBear and (extBear or (bearCond and trZ >= trZThr * 1.5 and volZ >= volZThr * 1.5))
regularReversalBull = regimeFlipBull and not confirmedBullTrend
regularReversalBear = regimeFlipBear and not confirmedBearTrend

// ───────── Colors

clrBull          = color.new(#00ff00, 0)
clrBear          = color.new(#ff0000, 0)
clrPreB          = color.new(#1e90ff, 0)
clrPreS          = color.new(#ffa500, 0)
clrConfirmedBull = color.new(#ffffff, 0)
clrConfirmedBear = color.new(#800080, 0)
clrReversalBull  = color.new(#006400, 85)
clrReversalBear  = color.new(#4b0082, 85)
clrManipBull     = color.new(#00ffff, 0)
clrManipBear     = color.new(#ff00ff, 0)
clrNeutral       = color.new(#808080, 70)
clrBiasBullBG    = color.new(#00ff00, 93)
clrBiasBearBG    = color.new(#ff0000, 93)

paint =
     confirmedBullTrend ? clrConfirmedBull :
     confirmedBearTrend ? clrConfirmedBear :
     regularReversalBull ? clrReversalBull :
     regularReversalBear ? clrReversalBear :
     extBull or bullCond ? clrBull :
     extBear or bearCond ? clrBear :
     preBull ? clrPreB :
     preBear ? clrPreS :
     clrNeutral

barcolor(colorizeCandles ? paint : na)

bgcolor(showBiasBG and biasBull ? clrBiasBullBG : showBiasBG and biasBear ? clrBiasBearBG : na, title="Session Bias BG")

// ───────── Plot Prior Session Levels

plot(showPrevLevels and inLondon ? pAsiaH : na,   "Prev Asia High",   color=color.new(color.yellow, 0),  style=plot.style_linebr, linewidth=2)
plot(showPrevLevels and inLondon ? pAsiaL : na,   "Prev Asia Low",    color=color.new(color.yellow, 0),  style=plot.style_linebr, linewidth=2)
plot(showPrevLevels and inLondon ? pAsiaMid : na, "Prev Asia Mid",    color=color.new(color.yellow, 50), style=plot.style_linebr, linewidth=1)

plot(showPrevLevels and (inNYPre or inNYReg) ? pLonH   : na, "Prev London High", color=color.new(color.aqua, 0),  style=plot.style_linebr, linewidth=2)
plot(showPrevLevels and (inNYPre or inNYReg) ? pLonL   : na, "Prev London Low",  color=color.new(color.aqua, 0),  style=plot.style_linebr, linewidth=2)
plot(showPrevLevels and (inNYPre or inNYReg) ? pLonMid : na, "Prev London Mid",  color=color.new(color.aqua, 50), style=plot.style_linebr, linewidth=1)

plot(showPrevLevels and inNYAft ? pNYH   : na, "Prev NY High", color=color.new(color.orange, 0),  style=plot.style_linebr, linewidth=2)
plot(showPrevLevels and inNYAft ? pNYL   : na, "Prev NY Low",  color=color.new(color.orange, 0),  style=plot.style_linebr, linewidth=2)
plot(showPrevLevels and inNYAft ? pNYMid : na, "Prev NY Mid",  color=color.new(color.orange, 50), style=plot.style_linebr, linewidth=1)

// ───────── Markers

plotshape(showMarks and extBull,  title="Extreme Bull", style=shape.diamond,      location=location.belowbar, color=color.new(clrBull,0),  size=size.small)
plotshape(showMarks and extBear,  title="Extreme Bear", style=shape.diamond,      location=location.abovebar, color=color.new(clrBear,0),  size=size.small)
plotshape(showMarks and preBull,  title="Pre-Bull",     style=shape.triangleup,   location=location.belowbar, color=clrPreB,               size=size.tiny)
plotshape(showMarks and preBear,  title="Pre-Bear",     style=shape.triangledown, location=location.abovebar, color=clrPreS,               size=size.tiny)

plotshape(showMarks and confirmedBullTrend, title="Confirmed Bull Trend", style=shape.labelup,   location=location.belowbar, color=clrConfirmedBull, textcolor=color.black, text="TC↑", size=size.small)
plotshape(showMarks and confirmedBearTrend, title="Confirmed Bear Trend", style=shape.labeldown, location=location.abovebar, color=clrConfirmedBear, textcolor=color.white, text="TC↓", size=size.small)

plotshape(showManip and stopHuntBull,    title="Stop Hunt Bull",  style=shape.xcross, location=location.belowbar, color=clrManipBull, size=size.tiny)
plotshape(showManip and stopHuntBear,    title="Stop Hunt Bear",  style=shape.xcross, location=location.abovebar, color=clrManipBear, size=size.tiny)
plotshape(showManip and cdDivBull,       title="CD Div Bull",     style=shape.circle, location=location.belowbar, color=clrManipBull, size=size.tiny)
plotshape(showManip and cdDivBear,       title="CD Div Bear",     style=shape.circle, location=location.abovebar, color=clrManipBear, size=size.tiny)
plotshape(showManip and absorptionBull,  title="Absorption Bull", style=shape.square, location=location.belowbar, color=color.new(clrManipBull,40), size=size.tiny)
plotshape(showManip and absorptionBear,  title="Absorption Bear", style=shape.square, location=location.abovebar, color=color.new(clrManipBear,40), size=size.tiny)

// Session event markers
plotshape(showFadeBreak and fadeHiBear,  title="Fade Prev High", style=shape.arrowdown, location=location.abovebar, color=color.new(color.red, 0),    size=size.tiny, text="F")
plotshape(showFadeBreak and fadeLoBull,  title="Fade Prev Low",  style=shape.arrowup,   location=location.belowbar, color=color.new(color.green, 0),  size=size.tiny, text="F")
plotshape(showFadeBreak and breakHiBull, title="Break Prev High",style=shape.arrowup,   location=location.belowbar, color=color.new(color.lime, 0),   size=size.tiny, text="B")
plotshape(showFadeBreak and breakLoBear, title="Break Prev Low", style=shape.arrowdown, location=location.abovebar, color=color.new(color.maroon, 0), size=size.tiny, text="B")

// ───────── Hit-Rate Stats Table

var table statsTable = table.new(position.top_right, 3, 6, border_width=1)

if showStatsTable and barstate.islast
    table.cell(statsTable, 0, 0, "Prior → Next", bgcolor=color.new(color.gray, 70), text_color=color.white)
    table.cell(statsTable, 1, 0, "Hit Rate",     bgcolor=color.new(color.gray, 70), text_color=color.white)
    table.cell(statsTable, 2, 0, "N",            bgcolor=color.new(color.gray, 70), text_color=color.white)

    table.cell(statsTable, 0, 1, "Asia🟢 → London🟢", text_color=color.white)
    table.cell(statsTable, 1, 1, str.tostring(hitRate_AG_LG, "#.0") + "%", text_color=hitRate_AG_LG >= 70 ? color.lime : hitRate_AG_LG >= 50 ? color.yellow : color.red)
    table.cell(statsTable, 2, 1, str.tostring(asiaGreenN), text_color=color.white)

    table.cell(statsTable, 0, 2, "Asia🔴 → London🔴", text_color=color.white)
    table.cell(statsTable, 1, 2, str.tostring(hitRate_AR_LR, "#.0") + "%", text_color=hitRate_AR_LR >= 70 ? color.lime : hitRate_AR_LR >= 50 ? color.yellow : color.red)
    table.cell(statsTable, 2, 2, str.tostring(asiaRedN), text_color=color.white)

    table.cell(statsTable, 0, 3, "London🟢 → NY🟢", text_color=color.white)
    table.cell(statsTable, 1, 3, str.tostring(hitRate_LG_NG, "#.0") + "%", text_color=hitRate_LG_NG >= 70 ? color.lime : hitRate_LG_NG >= 50 ? color.yellow : color.red)
    table.cell(statsTable, 2, 3, str.tostring(lonGreenN), text_color=color.white)

    table.cell(statsTable, 0, 4, "London🔴 → NY🔴", text_color=color.white)
    table.cell(statsTable, 1, 4, str.tostring(hitRate_LR_NR, "#.0") + "%", text_color=hitRate_LR_NR >= 70 ? color.lime : hitRate_LR_NR >= 50 ? color.yellow : color.red)
    table.cell(statsTable, 2, 4, str.tostring(lonRedN), text_color=color.white)

    biasText = biasBull ? "BULL BIAS" : biasBear ? "BEAR BIAS" : "NO BIAS"
    biasClr  = biasBull ? color.lime : biasBear ? color.red : color.gray
    table.cell(statsTable, 0, 5, "Current Bias", text_color=color.white, bgcolor=color.new(color.gray,85))
    table.cell(statsTable, 1, 5, biasText, text_color=biasClr, bgcolor=color.new(color.gray,85))
    table.cell(statsTable, 2, 5, "", bgcolor=color.new(color.gray,85))

// ───────── Alerts

alertcondition(bullCond,            "🟢 Bull Vector",          "BULL VECTOR: {{ticker}} @ {{close}}")
alertcondition(bearCond,            "🔴 Bear Vector",          "BEAR VECTOR: {{ticker}} @ {{close}}")
alertcondition(extBull,             "🚀 Extreme Bull",         "EXTREME BULL: {{ticker}} @ {{close}}")
alertcondition(extBear,             "🔥 Extreme Bear",         "EXTREME BEAR: {{ticker}} @ {{close}}")
alertcondition(preBull,             "📘 Pre-Bull",             "PRE-BULL: {{ticker}} @ {{close}}")
alertcondition(preBear,             "📙 Pre-Bear",             "PRE-BEAR: {{ticker}} @ {{close}}")
alertcondition(confirmedBullTrend,  "⚪ Confirmed Bull Trend", "CONFIRMED BULL TREND: {{ticker}} @ {{close}}")
alertcondition(confirmedBearTrend,  "🟣 Confirmed Bear Trend", "CONFIRMED BEAR TREND: {{ticker}} @ {{close}}")
alertcondition(regularReversalBull, "🟢 Bull Reversal",        "BULL REVERSAL: {{ticker}} @ {{close}}")
alertcondition(regularReversalBear, "🟣 Bear Reversal",        "BEAR REVERSAL: {{ticker}} @ {{close}}")
alertcondition(stopHuntBull,        "🎣 Stop Hunt Bull",       "STOP HUNT BULL: {{ticker}} @ {{close}}")
alertcondition(stopHuntBear,        "🎣 Stop Hunt Bear",       "STOP HUNT BEAR: {{ticker}} @ {{close}}")
alertcondition(cdDivBull,           "📊 CD Div Bull",          "CD DIV BULL: {{ticker}} @ {{close}}")
alertcondition(cdDivBear,           "📊 CD Div Bear",          "CD DIV BEAR: {{ticker}} @ {{close}}")

// Session edge alerts
alertcondition(asiaEnd   and pAsiaGreen, "🌏 Asia Closed GREEN",   "ASIA GREEN → Bull bias for London: {{ticker}}")
alertcondition(asiaEnd   and pAsiaRed,   "🌏 Asia Closed RED",     "ASIA RED → Bear bias for London: {{ticker}}")
alertcondition(londonEnd and pLonGreen,  "🇬🇧 London Closed GREEN", "LONDON GREEN → Bull bias for NY: {{ticker}}")
alertcondition(londonEnd and pLonRed,    "🇬🇧 London Closed RED",   "LONDON RED → Bear bias for NY: {{ticker}}")
alertcondition(tagHi,     "🎯 Tagged Prev High", "TAG PREV HIGH: {{ticker}} @ {{close}}")
alertcondition(tagLo,     "🎯 Tagged Prev Low",  "TAG PREV LOW: {{ticker}} @ {{close}}")
alertcondition(fadeHiBear,"↩️ Fade Prev High",   "FADE PREV HIGH (bearish): {{ticker}} @ {{close}}")
alertcondition(fadeLoBull,"↩️ Fade Prev Low",    "FADE PREV LOW (bullish): {{ticker}} @ {{close}}")
alertcondition(breakHiBull,"⚡ Break Prev High", "BREAK PREV HIGH: {{ticker}} @ {{close}}")
alertcondition(breakLoBear,"⚡ Break Prev Low",  "BREAK PREV LOW: {{ticker}} @ {{close}}")
````
