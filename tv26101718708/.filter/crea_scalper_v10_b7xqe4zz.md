# CREA Scalper v1.0

- url: https://www.tradingview.com/script/b7xqe4ZZ-CREA-Scalper-v1-0/
- type: indicator
- pine_id: PUB;7812a11e2759400ba754164550848619
- version: 1.0

## Description

CREA Scalper v1.0 — Triple EMA Cross Edition
For NASDAQ markets only (1-minute and 5-minute timeframes)
CREA Scalper is a precision scalping indicator built for NASDAQ equities and indices, designed to surface high-probability intraday entries by requiring multiple independent conditions to align before firing a signal. It is optimized for the fast-moving, volume-driven nature of NASDAQ instruments such as QQQ, AAPL, TSLA, and similar.
7-Layer Confirmation Engine
Every signal is scored against seven independent layers. A signal only fires when a configurable minimum number of layers confirm simultaneously:

Trend — EMA 9/21/50 stack alignment with price position
Momentum — RSI threshold + MACD histogram direction (optionally growing)
Volume — Spike above moving average, filtered by VWAP side
Pullback — Stochastic memory-based zone recovery (OS/OB visited within N bars)
Candle Structure — Engulfing, pinbar, or momentum candle confirmation
RSI Divergence — Bullish or bearish divergence at pivots
Triple EMA Cross (new in v5.8) — EMA 9 freshly crosses EMA 21 while EMA 21 is already above/below EMA 50, confirming a full stack formation in real time

Fast Path Signals
When a Triple EMA Cross occurs and at least 2 other layers confirm, the indicator can bypass the state machine wait and fire immediately — shown as a distinct cyan ▲ EMA× / ▼ EMA× label for quick visual identification.
State Machine
Signals progress through IDLE → SETUP → ARMED → TRIGGERED states, reducing noise by requiring score persistence and an optional intra-setup pullback before arming. Armed signals expire automatically if no candle trigger fires within the configured window.
Built-in Risk Management
Each signal automatically plots scaled Stop Loss and three Take Profit levels (TP1/TP2/TP3) using ATR-based distance, adjusted by signal strength score. Higher-scoring signals receive tighter stops and wider targets.
Additional Features
Exhaustion blocker, volatility regime filter, BOS/CHoCH market structure detection, HTF trend filter (default 15-minute), Fair Value Gaps, liquidity level sweeps (EQH/EQL), VWAP standard deviation bands, order flow delta bar coloring, ADX/DI trending confirmation, Money Flow Index, win/loss streak tracker, multi-symbol HUD (bottom right), and a full real-time layer status HUD (top right).

This indicator is designed exclusively for NASDAQ-listed instruments. Performance on other exchanges or asset classes is not tested and not guaranteed.

## Source Code

````pine
// ============================================================
// CREA Scalper v5.8 — Triple EMA Cross: Layer 7 + Fast Path
// Pine Script v6
//
// KEY CHANGES vs v5.7:
//   • Triple EMA Cross added as Layer 7 in score engine (+1 to long/short score)
//     Fires on the bar EMA9 freshly crosses EMA21 while EMA21 is above/below EMA50
//     Cross "freshness" window configurable (default 3 bars) to avoid stale crosses
//   • Fast Path signal: when Triple EMA cross occurs + ≥ emaCrossMinConf other layers
//     confirm → fires immediately, bypassing state machine wait
//     Visually distinct: cyan diamond label "▲ EMA×" / "▼ EMA×" instead of triangle
//   • Score engine updated to /7 (max 7 layers)
//   • HUD updated: Layer 7 row added, SCORE shows /7, fast path shown in SIGNAL row
//   • All v5.7 fixes preserved
// ============================================================

//@version=6
indicator("CREA Scalper v5.8", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

grpTrend = "── Trend Filter ──────────────────"
ema1Len  = input.int(9,    "EMA Fast",   group=grpTrend)
ema2Len  = input.int(21,   "EMA Mid",    group=grpTrend)
ema3Len  = input.int(50,   "EMA Slow",   group=grpTrend)
showEMAs = input.bool(true, "Show EMAs", group=grpTrend)

grpEMACross      = "── Triple EMA Cross ──────────────"
useEMACross      = input.bool(true,  "Enable Triple EMA Cross (Layer 7)",       group=grpEMACross)
emaCrossFreshBars= input.int(3,      "Cross freshness window (bars, def 3)",    group=grpEMACross)
useEMACrossFast  = input.bool(true,  "Enable Fast Path on cross",               group=grpEMACross)
emaCrossMinConf  = input.int(2,      "Fast Path: min other layers (def 2)",     group=grpEMACross, minval=1, maxval=6)
emaCrossColor    = input.color(color.new(#00FFFF, 0), "Fast Path label color",  group=grpEMACross)
showEMACrossLabel= input.bool(true,  "Show cross event markers on chart",       group=grpEMACross)

grpHTF          = "── HTF Trend Filter ──────────────"
useHTF          = input.bool(true,  "Enable HTF trend filter",       group=grpHTF)
htfTF           = input.timeframe("15", "HTF timeframe",             group=grpHTF)
htfEmaFast      = input.int(9,  "HTF EMA Fast",                      group=grpHTF)
htfEmaSlow      = input.int(21, "HTF EMA Slow",                      group=grpHTF)
htfStrictShorts = input.bool(false, "Require HTF bearish for shorts", group=grpHTF)

grpMom   = "── Momentum ──────────────────────"
rsiLen   = input.int(14, "RSI Length",                    group=grpMom)
rsiOB    = input.int(52, "RSI Bull min — Long (def 52)",  group=grpMom)
rsiOS    = input.int(48, "RSI Bear max — Short (def 48)", group=grpMom)
macdFast = input.int(12, "MACD Fast",                     group=grpMom)
macdSlow = input.int(26, "MACD Slow",                     group=grpMom)
macdSig  = input.int(9,  "MACD Signal",                   group=grpMom)
useMacdGrow = input.bool(true, "Require MACD hist growing (stricter)", group=grpMom)

grpDiv      = "── RSI Divergence ────────────────"
useDiv      = input.bool(true, "Enable divergence layer",   group=grpDiv)
divLookback = input.int(5,     "Divergence pivot lookback", group=grpDiv)

grpVol     = "── Volume Confirmation ───────────"
volLen     = input.int(20,    "Volume MA Length",        group=grpVol)
volMult    = input.float(1.2, "Volume spike multiplier", group=grpVol)
vwapFilter = input.bool(true, "Use VWAP side filter",    group=grpVol)

grpPull   = "── Pullback Zone ─────────────────"
stochKLen = input.int(14, "Stoch %K",                         group=grpPull)
stochSm   = input.int(3,  "Stoch Smooth",                     group=grpPull)
stochOB   = input.int(80, "Stoch OB — must have visited",     group=grpPull)
stochOS   = input.int(20, "Stoch OS — must have visited",     group=grpPull)
stochMemBars = input.int(20, "Stoch zone memory (bars, def 20)", group=grpPull)
bbLen     = input.int(20,    "BB Length",                      group=grpPull)
bbMult    = input.float(2.0, "BB Mult",                        group=grpPull)

grpCandle = "── Entry Trigger (Candle) ────────"
useEngulf = input.bool(true,  "Engulfing candle",                group=grpCandle)
usePinbar = input.bool(true,  "Pinbar / hammer",                 group=grpCandle)
useMomC   = input.bool(true,  "Momentum candle (body > avg)",    group=grpCandle)
bodyMult  = input.float(1.2,  "Momentum candle body multiplier (def 1.2)", group=grpCandle)

grpVola       = "── Volatility Regime ─────────────"
useVolaFilter = input.bool(true,  "Enable volatility filter", group=grpVola)
atrLen        = input.int(14,     "ATR Length",               group=grpVola)
atrMinMult    = input.float(0.2,  "Min ATR (× 20-bar avg)",   group=grpVola)
atrMaxMult    = input.float(4.0,  "Max ATR (× 20-bar avg)",   group=grpVola)

grpADX    = "── ADX / DI ──────────────────────"
adxLen    = input.int(14,   "ADX Length",             group=grpADX)
adxSmooth = input.int(14,   "ADX Smoothing",          group=grpADX)
adxStrong = input.int(25,   "ADX strong trend level", group=grpADX)
showADX   = input.bool(true,"Show ADX in HUD",        group=grpADX)

grpMFI    = "── Money Flow ────────────────────"
mfiLen    = input.int(14,   "MFI Length",     group=grpMFI)
mfiOB     = input.int(80,   "MFI overbought", group=grpMFI)
mfiOS     = input.int(20,   "MFI oversold",   group=grpMFI)
showMFI   = input.bool(true,"Show MFI in HUD",group=grpMFI)

grpBOS    = "── BOS Gate ──────────────────────"
useBOS    = input.bool(true, "Require BOS on signal bar",      group=grpBOS)
bosLookback = input.int(8,   "BOS swing lookback (bars)",      group=grpBOS)
showBOS   = input.bool(true, "Show BOS/CHoCH labels on chart", group=grpBOS)

grpExhaust = "── Exhaustion Blocker ────────────"
useExhaust      = input.bool(true,  "Enable exhaustion filter",                  group=grpExhaust)
exhaustRsiOB    = input.int(75,     "RSI overbought block — kills longs",        group=grpExhaust)
exhaustRsiOS    = input.int(25,     "RSI oversold block — kills shorts",         group=grpExhaust)
exhaustStochOB  = input.int(90,     "Stoch OB block — kills longs (def 90)",     group=grpExhaust)
exhaustStochOS  = input.int(10,     "Stoch OS block — kills shorts (def 10)",    group=grpExhaust)
exhaustVwapSD   = input.float(2.5,  "VWAP SD band block (def 2.5)",              group=grpExhaust)
exhaustBarCount = input.int(4,      "Min bars since last same-dir signal",       group=grpExhaust)

grpState  = "── State Machine ─────────────────"
useStateMachine  = input.bool(true, "Enable state machine (recommended)",      group=grpState)
setupBars        = input.int(2,     "Min bars in SETUP before ARMED (def 2)",  group=grpState)
armedExpiry      = input.int(12,    "ARMED state expiry (bars, def 12)",       group=grpState)
pullbackRequired = input.bool(false,"Require intra-SETUP pullback (stricter)", group=grpState)
showStateLabel   = input.bool(false,"Show state debug labels",                 group=grpState)

grpSig           = "── Signal Settings ───────────────"
confirmThreshold = input.int(3,  "Min confirmations (1–6, def 3)", minval=1, maxval=6, group=grpSig)
cooldownBars     = input.int(3,  "Hard cooldown bars (safety net)", minval=1, maxval=50, group=grpSig)
showTable        = input.bool(true, "Show HUD table",              group=grpSig)
showStreak       = input.bool(true, "Show streak counter",         group=grpSig)
showAnticipation = input.bool(true, "Show anticipation shading",   group=grpSig)
showOutcomes     = input.bool(true, "Show signal outcome markers",  group=grpSig)

grpSLTP       = "── Stop Loss & Targets ───────────"
atrSlMult     = input.float(1.5, "SL ATR multiplier (base)",   group=grpSLTP)
tp1R          = input.float(1.0, "TP1 R-multiple", minval=0.1, group=grpSLTP)
tp2R          = input.float(2.0, "TP2 R-multiple", minval=0.1, group=grpSLTP)
tp3R          = input.float(3.0, "TP3 R-multiple", minval=0.1, group=grpSLTP)
showSLTP      = input.bool(true, "Show SL/TP lines on chart",  group=grpSLTP)
extendBars    = input.int(20,    "Extend lines N bars",         group=grpSLTP)
sltpBgOpacity = input.int(85,    "Zone fill opacity (0=solid, 100=invisible)", minval=0, maxval=100, group=grpSLTP)

grpMulti  = "── Multi-Symbol HUD ──────────────"
showMulti = input.bool(true,  "Show multi-symbol table",     group=grpMulti)
sym1      = input.symbol("NASDAQ:QQQ",  "Symbol 1",          group=grpMulti)
sym2      = input.symbol("NASDAQ:AAPL", "Symbol 2",          group=grpMulti)
sym3      = input.symbol("NASDAQ:TSLA", "Symbol 3",          group=grpMulti)

grpDelta  = "── Order Flow Delta ──────────────"
showDelta = input.bool(true, "Show delta bar colors", group=grpDelta)

grpFVG     = "── Fair Value Gaps ───────────────"
showFVG    = input.bool(true,  "Show Fair Value Gaps",  group=grpFVG)
fvgMinSize = input.float(0.1,  "Min FVG size (× ATR)",  group=grpFVG)
fvgMaxBars = input.int(50,     "Max bars to show FVG",  group=grpFVG)

grpLiq       = "── Liquidity Levels ──────────────"
showLiq      = input.bool(true,  "Show liquidity levels",         group=grpLiq)
liqLookback  = input.int(20,     "Liquidity pivot lookback",      group=grpLiq)
liqEqualPips = input.float(0.05, "Equal level tolerance (ATR ×)", group=grpLiq)

grpVWAPSD   = "── VWAP Std Dev Bands ────────────"
showVWAPSD  = input.bool(true,  "Show VWAP SD bands",   group=grpVWAPSD)
vwapSD1Mult = input.float(1.0,  "SD band 1 multiplier", group=grpVWAPSD)
vwapSD2Mult = input.float(2.0,  "SD band 2 multiplier", group=grpVWAPSD)
vwapSD3Mult = input.float(3.0,  "SD band 3 multiplier", group=grpVWAPSD)

grpVis     = "── Visual ────────────────────────"
bullColor  = input.color(color.new(#00C897, 0), "Bull signal color", group=grpVis)
bearColor  = input.color(color.new(#FF4F5E, 0), "Bear signal color", group=grpVis)
slColor    = input.color(color.new(#FF4F5E, 0), "SL line color",     group=grpVis)
entryColor = input.color(color.new(#FFFFFF, 0), "Entry line color",  group=grpVis)
tp1Color   = input.color(color.new(#FFD700, 0), "TP1 line color",    group=grpVis)
tp2Color   = input.color(color.new(#00C897, 0), "TP2 line color",    group=grpVis)
tp3Color   = input.color(color.new(#00BFFF, 0), "TP3 line color",    group=grpVis)

// ─────────────────────────────────────────────
// CORE CALCULATIONS
// ─────────────────────────────────────────────

atr      = ta.atr(atrLen)
atrAvg   = ta.sma(atr, 20)
atrRatio = atr / atrAvg
isNewDay = ta.change(time("D")) != 0

// ─────────────────────────────────────────────
// VWAP + SD BANDS
// ─────────────────────────────────────────────

vwap = ta.vwap(hlc3)

var float vwapSumPV  = 0.0
var float vwapSumV   = 0.0
var float vwapSumPV2 = 0.0

if isNewDay
    vwapSumPV  := 0.0
    vwapSumV   := 0.0
    vwapSumPV2 := 0.0

vwapSumPV  += hlc3 * volume
vwapSumV   += volume
vwapSumPV2 += hlc3 * hlc3 * volume

vwapCalc  = vwapSumV > 0 ? vwapSumPV  / vwapSumV : hlc3
vwapVar   = vwapSumV > 0 ? math.max(vwapSumPV2 / vwapSumV - vwapCalc * vwapCalc, 0.0) : 0.0
vwapStdev = math.sqrt(vwapVar)

vwapSD1Up = vwapCalc + vwapSD1Mult * vwapStdev
vwapSD1Dn = vwapCalc - vwapSD1Mult * vwapStdev
vwapSD2Up = vwapCalc + vwapSD2Mult * vwapStdev
vwapSD2Dn = vwapCalc - vwapSD2Mult * vwapStdev
vwapSD3Up = vwapCalc + vwapSD3Mult * vwapStdev
vwapSD3Dn = vwapCalc - vwapSD3Mult * vwapStdev

plot(vwap,                        "VWAP",      color=color.new(#AA88FF, 0),  linewidth=1)
plot(showVWAPSD ? vwapSD1Up : na, "VWAP +1SD", color=color.new(#AA88FF, 60), linewidth=1)
plot(showVWAPSD ? vwapSD1Dn : na, "VWAP -1SD", color=color.new(#AA88FF, 60), linewidth=1)
plot(showVWAPSD ? vwapSD2Up : na, "VWAP +2SD", color=color.new(#AA88FF, 40), linewidth=1)
plot(showVWAPSD ? vwapSD2Dn : na, "VWAP -2SD", color=color.new(#AA88FF, 40), linewidth=1)
plot(showVWAPSD ? vwapSD3Up : na, "VWAP +3SD", color=color.new(#AA88FF, 20), linewidth=2)
plot(showVWAPSD ? vwapSD3Dn : na, "VWAP -3SD", color=color.new(#AA88FF, 20), linewidth=2)

aboveVWAP    = close > vwapCalc
belowVWAP    = close < vwapCalc
extendedHigh = close > vwapSD3Up
extendedLow  = close < vwapSD3Dn

// ─────────────────────────────────────────────
// ORDER FLOW DELTA
// ─────────────────────────────────────────────

barRange = high - low
upVol    = barRange > 0 ? volume * (close - low)  / barRange : volume * 0.5
downVol  = barRange > 0 ? volume * (high - close) / barRange : volume * 0.5
delta    = upVol - downVol
deltaAvg = ta.sma(math.abs(delta), 20)

var float cumDelta = 0.0
if isNewDay
    cumDelta := 0.0
else
    cumDelta += delta

barcolor(showDelta ? (delta > 0 ?
         color.new(#00C897, delta > deltaAvg ? 0 : 60) :
         color.new(#FF4F5E, math.abs(delta) > deltaAvg ? 0 : 60)) : na,
         title="Delta bar color")

// ─────────────────────────────────────────────
// EMAs
// ─────────────────────────────────────────────

ema1 = ta.ema(close, ema1Len)
ema2 = ta.ema(close, ema2Len)
ema3 = ta.ema(close, ema3Len)

plot(showEMAs ? ema1 : na, "EMA Fast", color=color.new(#FFD700, 0), linewidth=1)
plot(showEMAs ? ema2 : na, "EMA Mid",  color=color.new(#00C0FF, 0), linewidth=1)
plot(showEMAs ? ema3 : na, "EMA Slow", color=color.new(#FF8C00, 0), linewidth=2)

// ─────────────────────────────────────────────
// TRIPLE EMA CROSS (Layer 7)
//
// Bull cross: EMA9 crosses above EMA21 while EMA21 is above EMA50
//   → perfect stack just formed, early trend entry
// Bear cross: EMA9 crosses below EMA21 while EMA21 is below EMA50
//   → perfect bear stack just formed
//
// "Fresh" cross: the crossover happened within the last emaCrossFreshBars bars.
// This means Layer 7 stays active for a window, not just 1 bar, giving the
// state machine and fast path time to see it.
// ─────────────────────────────────────────────

ema1CrossAbove2 = ta.crossover(ema1,  ema2)   // EMA9 crosses above EMA21
ema1CrossBelow2 = ta.crossunder(ema1, ema2)   // EMA9 crosses below EMA21

// Track bars since last cross
var int barsSinceBullCross = 999
var int barsSinceBearCross = 999

if ema1CrossAbove2
    barsSinceBullCross := 0
else
    barsSinceBullCross := barsSinceBullCross + 1

if ema1CrossBelow2
    barsSinceBearCross := 0
else
    barsSinceBearCross := barsSinceBearCross + 1

// Fresh cross within window
freshBullCross = barsSinceBullCross <= emaCrossFreshBars
freshBearCross = barsSinceBearCross <= emaCrossFreshBars

// Triple condition: fresh cross + full stack alignment
tripleCrossBull = useEMACross and freshBullCross and ema2 > ema3
tripleCrossBear = useEMACross and freshBearCross and ema2 < ema3

// Visual markers on the exact crossover bar (not the whole window)
if showEMACrossLabel and ema1CrossAbove2 and ema2 > ema3
    label.new(bar_index, low, "3×▲",
              yloc=yloc.belowbar, color=color.new(#00FFFF, 30),
              textcolor=color.new(#00FFFF, 0), size=size.tiny, style=label.style_label_up)

if showEMACrossLabel and ema1CrossBelow2 and ema2 < ema3
    label.new(bar_index, high, "3×▼",
              yloc=yloc.abovebar, color=color.new(#00FFFF, 30),
              textcolor=color.new(#00FFFF, 0), size=size.tiny, style=label.style_label_down)

// ─────────────────────────────────────────────
// HTF FILTER
// ─────────────────────────────────────────────

htfEma1 = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfEmaFast), lookahead=barmerge.lookahead_off)
htfEma2 = request.security(syminfo.tickerid, htfTF, ta.ema(close, htfEmaSlow),  lookahead=barmerge.lookahead_off)
htfBull  = htfEma1 > htfEma2
htfBear  = htfEma1 < htfEma2

htfOk(dir) =>
    if dir == 1
        not useHTF or htfBull
    else
        not useHTF or not htfStrictShorts or htfBear

// ─────────────────────────────────────────────
// LAYER 1: TREND
// ─────────────────────────────────────────────

stackBull = ema1 > ema2 and ema2 > ema3
stackBear = ema1 < ema2 and ema2 < ema3

trendBull = stackBull and close > ema1
trendBear = close < ema1 and close < ema2

// ─────────────────────────────────────────────
// LAYER 2: MOMENTUM
// RSI threshold tightened to 55/45 from 52/48
// ─────────────────────────────────────────────

rsi = ta.rsi(close, rsiLen)
[macdLine, signalLine, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)

// MACD: optionally require histogram to be growing (stricter)
macdHistGrowingBull = macdHist > 0 and macdHist > macdHist[1]
macdHistGrowingBear = macdHist < 0 and macdHist < macdHist[1]

momBull = rsi > rsiOB and (useMacdGrow ? macdHistGrowingBull : macdHist > 0)
momBear = rsi < rsiOS and (useMacdGrow ? macdHistGrowingBear : macdHist < 0)

// ─────────────────────────────────────────────
// LAYER 3: VOLUME
// ─────────────────────────────────────────────

volMA    = ta.sma(volume, volLen)
volSpike = volume > volMA * volMult

volBull = volSpike and (vwapFilter ? aboveVWAP : true)
volBear = volSpike and (vwapFilter ? belowVWAP : true)

// ─────────────────────────────────────────────
// LAYER 4: PULLBACK (tightened — memory-based)
// Stoch must have VISITED OS/OB zone within stochMemBars
// before being allowed to trigger. This means we only fire
// after a genuine pullback, not mid-extension.
// ─────────────────────────────────────────────

stochKRaw = ta.stoch(close, high, low, stochKLen)
stochKS   = ta.sma(stochKRaw, stochSm)

[bbUpper, bbMid, bbLower] = ta.bb(close, bbLen, bbMult)

// Track whether stoch visited the OS/OB zone recently
var bool stochVisitedOS = false
var bool stochVisitedOB = false
var int  stochOSbar     = 0
var int  stochOBbar     = 0

if stochKS <= stochOS
    stochVisitedOS := true
    stochOSbar     := bar_index
if stochKS >= stochOB
    stochVisitedOB := true
    stochOBbar     := bar_index

// Memory expires after stochMemBars bars
stochOSrecent = stochVisitedOS and (bar_index - stochOSbar) <= stochMemBars
stochOBrecent = stochVisitedOB and (bar_index - stochOBbar) <= stochMemBars

// Long: stoch came from OS and is now recovering (not yet extended)
// Short: stoch came from OB and is now declining (not yet extended)
// Cap raised to 70/30 (was 60/40) — 60 was too tight for trending 1m
pullBull = stochOSrecent and stochKS > stochOS and stochKS < 70 and close > ema2
pullBear = stochOBrecent and stochKS < stochOB and stochKS > 30 and close < ema2

// ─────────────────────────────────────────────
// LAYER 5: ENTRY TRIGGER (candle structure)
// bodyMult raised to 1.2 for stricter momentum candle
// ─────────────────────────────────────────────

bodySize  = math.abs(close - open)
avgBody   = ta.sma(bodySize, 10)
lowerWick = math.min(open, close) - low
upperWick = high - math.max(open, close)

bullEngulf    = useEngulf and close > open and close > close[1] and open < close[1]
bearEngulf    = useEngulf and close < open and open >= close[1] and close < close[1]
pinBull       = usePinbar and lowerWick > bodySize * 2.0 and lowerWick > upperWick * 2.0
pinBear       = usePinbar and upperWick > bodySize * 2.0 and upperWick > lowerWick * 2.0
momCandleBull = useMomC and close > open and bodySize > avgBody * bodyMult
momCandleBear = useMomC and close < open and bodySize > avgBody * bodyMult

candleBull = bullEngulf or pinBull or momCandleBull
candleBear = bearEngulf or pinBear or momCandleBear

// ─────────────────────────────────────────────
// LAYER 6: RSI DIVERGENCE
// ─────────────────────────────────────────────

pricePivotLow  = ta.pivotlow(low,   divLookback, divLookback)
pricePivotHigh = ta.pivothigh(high, divLookback, divLookback)
rsiPivotLow    = ta.pivotlow(rsi,   divLookback, divLookback)
rsiPivotHigh   = ta.pivothigh(rsi,  divLookback, divLookback)

var float lastPriceLow  = na
var float lastRsiLow    = na
var float lastPriceHigh = na
var float lastRsiHigh   = na

if not na(pricePivotLow)
    lastPriceLow  := pricePivotLow
if not na(rsiPivotLow)
    lastRsiLow    := rsiPivotLow
if not na(pricePivotHigh)
    lastPriceHigh := pricePivotHigh
if not na(rsiPivotHigh)
    lastRsiHigh   := rsiPivotHigh

bullDiv = (useDiv and not na(pricePivotLow)  and not na(lastPriceLow)  and
          low[divLookback]  < lastPriceLow  and rsi[divLookback] > lastRsiLow)
bearDiv = (useDiv and not na(pricePivotHigh) and not na(lastPriceHigh) and
          high[divLookback] > lastPriceHigh and rsi[divLookback] < lastRsiHigh)

// ─────────────────────────────────────────────
// VOLATILITY FILTER
// ─────────────────────────────────────────────

volaOk = not useVolaFilter or (atrRatio >= atrMinMult and atrRatio <= atrMaxMult)

// ─────────────────────────────────────────────
// ADX + DI
// ─────────────────────────────────────────────

[diPlus, diMinus, adxVal] = ta.dmi(adxLen, adxSmooth)

adxTrending = adxVal >= adxStrong
adxBullConf = diPlus  > diMinus and adxTrending
adxBearConf = diMinus > diPlus  and adxTrending

// ─────────────────────────────────────────────
// MONEY FLOW INDEX (MFI)
// ─────────────────────────────────────────────

mfi = ta.mfi(hlc3, mfiLen)

mfiBull = mfi > 50 and mfi < mfiOB
mfiBear = mfi < 50 and mfi > mfiOS

// ─────────────────────────────────────────────
// TREND STRENGTH 0–10
// ─────────────────────────────────────────────

adxScore  = adxVal >= 50 ? 4 : adxVal >= 40 ? 3 : adxVal >= 25 ? 2 : adxVal >= 15 ? 1 : 0
ema1Slope = (ema1 - ema1[3]) / atr
ema2Slope = (ema2 - ema2[3]) / atr
slopeAbs  = math.abs(ema1Slope) + math.abs(ema2Slope)
slopeScore = slopeAbs >= 1.5 ? 3 : slopeAbs >= 0.8 ? 2 : slopeAbs >= 0.3 ? 1 : 0
priceScore = (close > ema1 ? 1 : 0) + (close > ema2 ? 1 : 0) + (close > ema3 ? 1 : 0)
isBearContext  = stackBear or (not stackBull and close < ema2)
priceScoreAdj  = isBearContext ? (close < ema1 ? 1 : 0) + (close < ema2 ? 1 : 0) + (close < ema3 ? 1 : 0) : priceScore
trendStrength  = math.min(adxScore + slopeScore + priceScoreAdj, 10)

// ─────────────────────────────────────────────
// BOS GATE
// Break of Structure: price closes above recent swing high (long)
// or below recent swing low (short) on the signal bar.
// Uses a rolling highest/lowest over bosLookback bars.
// ─────────────────────────────────────────────

swingHigh = ta.highest(high, bosLookback)[1]   // highest of prior N bars (exclude current)
swingLow  = ta.lowest(low,   bosLookback)[1]   // lowest  of prior N bars (exclude current)

// BOS: high breaks above prior swing high (long) or low breaks below prior swing low (short)
// Relaxed from close > swingHigh — on 1m close above swing high almost never happens
// on the same bar. Using high/low gives earlier, more realistic detection.
bosLong  = high  > swingHigh
bosShort = low   < swingLow

// CHoCH: trend was bearish but BOS is bullish (and vice-versa) — marks character change
chochLong  = bosLong  and stackBear   // BOS against current bear structure
chochShort = bosShort and stackBull   // BOS against current bull structure

if showBOS
    if bosLong
        label.new(bar_index, low, chochLong ? "CHoCH" : "BOS",
                  yloc=yloc.belowbar, color=color.new(#00C897, 60),
                  textcolor=color.white, size=size.tiny, style=label.style_label_up)
    if bosShort
        label.new(bar_index, high, chochShort ? "CHoCH" : "BOS",
                  yloc=yloc.abovebar, color=color.new(#FF4F5E, 60),
                  textcolor=color.white, size=size.tiny, style=label.style_label_down)

bosGateLong  = not useBOS or bosLong
bosGateShort = not useBOS or bosShort

// ─────────────────────────────────────────────
// EXHAUSTION BLOCKER
// Kills signals when any of these conditions are true:
//   1. RSI is deeply overbought/oversold
//   2. Stoch is deeply extended at time of signal
//   3. Price is beyond VWAP +/-N SD bands
//   4. Adverse RSI divergence present (would reverse soon)
//   5. MFI is deeply overbought/oversold (flow exhausted)
// ─────────────────────────────────────────────

// Exhaustion blocker — 4 conditions (MFI removed: OB during genuine trend killed valid longs)
//   1. RSI deeply OB/OS
//   2. Stoch deeply extended at signal time (raised to 90/10 from 85/15)
//   3. Price beyond VWAP +/-2.5SD (raised from 2.0)
//   4. Adverse RSI divergence (would-be reversal signal)
exhaustLong  = useExhaust and (
               rsi     >= exhaustRsiOB   or
               stochKS >= exhaustStochOB or
               close   >= vwapCalc + exhaustVwapSD * vwapStdev or
               bearDiv)

exhaustShort = useExhaust and (
               rsi     <= exhaustRsiOS   or
               stochKS <= exhaustStochOS or
               close   <= vwapCalc - exhaustVwapSD * vwapStdev or
               bullDiv)

// ─────────────────────────────────────────────
// HARD COOLDOWN (safety net)
// Declared here so it is available to both the
// fast path and the main final gates below.
// ─────────────────────────────────────────────

var int lastSignalBar = -99
barsElapsed = bar_index - lastSignalBar
cooldownOk  = barsElapsed >= cooldownBars

// ─────────────────────────────────────────────
// SCORE ENGINE  (max 7)
// ─────────────────────────────────────────────

longScore  = (trendBull      ? 1 : 0) + (momBull    ? 1 : 0) + (volBull  ? 1 : 0) +
             (pullBull       ? 1 : 0) + (candleBull ? 1 : 0) + (bullDiv  ? 1 : 0) +
             (tripleCrossBull ? 1 : 0)
shortScore = (trendBear      ? 1 : 0) + (momBear    ? 1 : 0) + (volBear  ? 1 : 0) +
             (pullBear       ? 1 : 0) + (candleBear ? 1 : 0) + (bearDiv  ? 1 : 0) +
             (tripleCrossBear ? 1 : 0)

longSignal  = longScore  >= confirmThreshold
shortSignal = shortScore >= confirmThreshold

// ─────────────────────────────────────────────
// FAST PATH — Triple EMA Cross
// Fires immediately (bypasses state machine wait) when:
//   • Fresh triple cross just occurred (within window)
//   • At least emaCrossMinConf OTHER layers also confirm
//   • Exhaustion blocker clear, HTF ok, volatility ok
// Score for fast path excludes the cross layer itself to avoid
// the cross counting as one of its own confirmations.
// ─────────────────────────────────────────────

longScoreNoX  = longScore  - (tripleCrossBull ? 1 : 0)
shortScoreNoX = shortScore - (tripleCrossBear ? 1 : 0)

fastPathLong  = (useEMACrossFast and tripleCrossBull and
                longScoreNoX >= emaCrossMinConf and
                not exhaustLong and volaOk and htfOk(1) and
                not extendedHigh and cooldownOk)

fastPathShort = (useEMACrossFast and tripleCrossBear and
                shortScoreNoX >= emaCrossMinConf and
                not exhaustShort and volaOk and htfOk(-1) and
                not extendedLow and cooldownOk)

// ─────────────────────────────────────────────
// STATE MACHINE
// States: 0=IDLE, 1=SETUP, 2=ARMED, 3=TRIGGERED
//
// IDLE    → SETUP:     score first reaches threshold
// SETUP   → ARMED:     score stays ≥ threshold for setupBars AND
//                      a pullback occurs (stoch dips then recovers)
// ARMED   → TRIGGERED: candle trigger fires (or BOS fires)
// ARMED   → IDLE:      armedExpiry bars pass without trigger
// TRIGGERED → IDLE:    next bar after signal
//
// When state machine is OFF, falls back to score-only mode.
// ─────────────────────────────────────────────

var int   smStateLong   = 0   // 0=IDLE 1=SETUP 2=ARMED 3=TRIGGERED
var int   smStateShort  = 0
var int   smSetupBarL   = 0   // bar when SETUP started
var int   smSetupBarS   = 0
var int   smArmedBarL   = 0   // bar when ARMED started
var int   smArmedBarS   = 0
var float smArmedPriceL = na  // close when armed (for context)
var float smArmedPriceS = na

// Pullback within SETUP: stoch dipped below 50 then recovered for long,
// stoch climbed above 50 then dropped for short
var bool smPullSeenL = false
var bool smPullSeenS = false

// Track score going below threshold as a "reset" while in SETUP
if smStateLong == 1 and longScore < confirmThreshold - 1
    smStateLong := 0
    smPullSeenL := false
if smStateShort == 1 and shortScore < confirmThreshold - 1
    smStateShort := 0
    smPullSeenS  := false

// IDLE → SETUP
if smStateLong == 0 and longSignal and not exhaustLong
    smStateLong  := 1
    smSetupBarL  := bar_index
    smPullSeenL  := false

if smStateShort == 0 and shortSignal and not exhaustShort
    smStateShort := 1
    smSetupBarS  := bar_index
    smPullSeenS  := false

// Track pullback during SETUP
if smStateLong == 1 and stochKS < 50
    smPullSeenL := true
if smStateShort == 1 and stochKS > 50
    smPullSeenS := true

// SETUP → ARMED
// pullbackRequired toggle: when OFF, just needs setupBars elapsed + score held
// When ON, also requires stoch to have dipped (long) or risen (short) during SETUP
if smStateLong == 1 and longSignal and
   (bar_index - smSetupBarL) >= setupBars and
   (not pullbackRequired or smPullSeenL)
    smStateLong   := 2
    smArmedBarL   := bar_index
    smArmedPriceL := close

if smStateShort == 1 and shortSignal and
   (bar_index - smSetupBarS) >= setupBars and
   (not pullbackRequired or smPullSeenS)
    smStateShort  := 2
    smArmedBarS   := bar_index
    smArmedPriceS := close

// ARMED → IDLE (expiry)
if smStateLong == 2 and (bar_index - smArmedBarL) > armedExpiry
    smStateLong := 0
    smPullSeenL := false

if smStateShort == 2 and (bar_index - smArmedBarS) > armedExpiry
    smStateShort := 0
    smPullSeenS  := false

// TRIGGERED → IDLE (reset after signal fires)
if smStateLong  == 3
    smStateLong  := 0
    smPullSeenL  := false
if smStateShort == 3
    smStateShort := 0
    smPullSeenS  := false

// State machine gate: ARMED requires candle trigger
smGateLong  = not useStateMachine or (smStateLong  == 2 and candleBull)
smGateShort = not useStateMachine or (smStateShort == 2 and candleBear)

// When state machine is OFF, armed is implicitly true if score >= threshold
smGateLong  := useStateMachine ? smGateLong  : longSignal
smGateShort := useStateMachine ? smGateShort : shortSignal

// ─────────────────────────────────────────────
// FINAL SIGNAL GATES
// Standard path: state machine + full gate stack
// Fast path: triple cross fires immediately with fewer confirmations
// ─────────────────────────────────────────────

finalLong  = fastPathLong or (smGateLong  and longSignal  and not shortSignal and
              bosGateLong and not exhaustLong and not extendedHigh and
              cooldownOk  and volaOk and htfOk(1))

finalShort = fastPathShort or (smGateShort and shortSignal and not longSignal  and
              bosGateShort and not exhaustShort and not extendedLow and
              cooldownOk  and volaOk and htfOk(-1))

// Tag which path fired (for label distinction)
isFastLong  = fastPathLong  and not (smGateLong  and longSignal)
isFastShort = fastPathShort and not (smGateShort and shortSignal)

if finalLong
    lastSignalBar := bar_index
    smStateLong   := 3

if finalShort
    lastSignalBar := bar_index
    smStateShort  := 3

// ─────────────────────────────────────────────
// STATE DEBUG LABELS
// ─────────────────────────────────────────────

if showStateLabel
    stateTextL = smStateLong  == 0 ? "L:IDLE" : smStateLong  == 1 ? "L:SETUP" :
                 smStateLong  == 2 ? "L:ARMED" : "L:TRIG"
    stateTextS = smStateShort == 0 ? "S:IDLE" : smStateShort == 1 ? "S:SETUP" :
                 smStateShort == 2 ? "S:ARMED" : "S:TRIG"
    label.new(bar_index, high, stateTextL + " " + stateTextS,
              yloc=yloc.abovebar, color=color.new(color.gray, 80),
              textcolor=color.gray, size=size.tiny, style=label.style_label_down)

// ─────────────────────────────────────────────
// ANTICIPATION SHADING
// Shows when score is 1 away from threshold (SETUP or near-signal)
// ─────────────────────────────────────────────

nearLong  = showAnticipation and (longScore  == confirmThreshold - 1 or smStateLong  == 2) and volaOk and not exhaustLong
nearShort = showAnticipation and (shortScore == confirmThreshold - 1 or smStateShort == 2) and volaOk and not exhaustShort

bgcolor(nearLong  ? color.new(bullColor, 90) : na, title="Anticipation long")
bgcolor(nearShort ? color.new(bearColor, 90) : na, title="Anticipation short")

// ─────────────────────────────────────────────
// FAIR VALUE GAPS
// ─────────────────────────────────────────────

bullFVG = showFVG and low  > high[2] and (low   - high[2]) > atr * fvgMinSize
bearFVG = showFVG and high < low[2]  and (low[2] - high)   > atr * fvgMinSize

var array<box>  fvgBoxes  = array.new<box>()
var array<bool> fvgIsBull = array.new<bool>()

if bullFVG
    array.push(fvgBoxes, box.new(bar_index - 2, low, bar_index + fvgMaxBars, high[2],
               border_color=color.new(#00C897, 80), bgcolor=color.new(#00C897, 90), border_width=1))
    array.push(fvgIsBull, true)

if bearFVG
    array.push(fvgBoxes, box.new(bar_index - 2, low[2], bar_index + fvgMaxBars, high,
               border_color=color.new(#FF4F5E, 80), bgcolor=color.new(#FF4F5E, 90), border_width=1))
    array.push(fvgIsBull, false)

inBullFVGZone = false
inBearFVGZone = false

fvgSize = array.size(fvgBoxes)
if fvgSize > 0
    for i = 0 to fvgSize - 1
        if i < array.size(fvgBoxes)
            b      = array.get(fvgBoxes,  i)
            isBull = array.get(fvgIsBull, i)
            bTop   = box.get_top(b)
            bBot   = box.get_bottom(b)
            box.set_right(b, bar_index + fvgMaxBars)
            if close >= bBot and close <= bTop
                if isBull
                    inBullFVGZone := true
                else
                    inBearFVGZone := true

var array<int> fvgRemove = array.new<int>()
array.clear(fvgRemove)
fvgSize2 = array.size(fvgBoxes)
if fvgSize2 > 0
    for i = 0 to fvgSize2 - 1
        if i < array.size(fvgBoxes)
            b = array.get(fvgBoxes, i)
            if bar_index > box.get_left(b) + fvgMaxBars
                array.push(fvgRemove, i)

rSize = array.size(fvgRemove)
if rSize > 0
    for j = rSize - 1 to 0
        idx = array.get(fvgRemove, j)
        if idx < array.size(fvgBoxes)
            array.remove(fvgBoxes,  idx)
            array.remove(fvgIsBull, idx)

// ─────────────────────────────────────────────
// LIQUIDITY LEVELS
// ─────────────────────────────────────────────

liqTolerance = atr * liqEqualPips
pivHigh      = ta.pivothigh(high, liqLookback, liqLookback)
pivLow       = ta.pivotlow(low,   liqLookback, liqLookback)

var array<float> liqHighs = array.new<float>()
var array<float> liqLows  = array.new<float>()

if not na(pivHigh)
    array.push(liqHighs, pivHigh)
    if array.size(liqHighs) > 10
        array.shift(liqHighs)

if not na(pivLow)
    array.push(liqLows, pivLow)
    if array.size(liqLows) > 10
        array.shift(liqLows)

if showLiq and not na(pivHigh) and array.size(liqHighs) >= 2
    prevHigh = array.get(liqHighs, array.size(liqHighs) - 2)
    if math.abs(pivHigh - prevHigh) <= liqTolerance
        line.new(bar_index - liqLookback, pivHigh, bar_index + 10, pivHigh,
                 color=color.new(#FFD700, 40), width=1, style=line.style_dotted)
        label.new(bar_index - liqLookback, pivHigh, "EQH",
                  color=color.new(#FFD700, 70), textcolor=color.new(#FFD700, 0),
                  size=size.tiny, style=label.style_label_left)

if showLiq and not na(pivLow) and array.size(liqLows) >= 2
    prevLow = array.get(liqLows, array.size(liqLows) - 2)
    if math.abs(pivLow - prevLow) <= liqTolerance
        line.new(bar_index - liqLookback, pivLow, bar_index + 10, pivLow,
                 color=color.new(#FF8C00, 40), width=1, style=line.style_dotted)
        label.new(bar_index - liqLookback, pivLow, "EQL",
                  color=color.new(#FF8C00, 70), textcolor=color.new(#FF8C00, 0),
                  size=size.tiny, style=label.style_label_left)

nearLiqHigh = (array.size(liqHighs) > 0 and
              math.abs(close - array.get(liqHighs, array.size(liqHighs) - 1)) < atr * 0.5)
nearLiqLow  = (array.size(liqLows)  > 0 and
              math.abs(close - array.get(liqLows,  array.size(liqLows)  - 1)) < atr * 0.5)

// ─────────────────────────────────────────────
// STREAK + OUTCOME TRACKER
// ─────────────────────────────────────────────

var int   winStreak  = 0
var int   lossStreak = 0
var int   totalW     = 0
var int   totalL     = 0
var float trackSL    = na
var float trackTP1   = na
var bool  trackLong  = false
var bool  tracking   = false

if finalLong or finalShort
    trackSL   := finalLong ? close - atr * atrSlMult : close + atr * atrSlMult
    trackTP1  := finalLong ? close + atr * atrSlMult * tp1R : close - atr * atrSlMult * tp1R
    trackLong := finalLong
    tracking  := true

if tracking and not na(trackSL)
    hitSL  = trackLong ? low  <= trackSL  : high >= trackSL
    hitTP1 = trackLong ? high >= trackTP1 : low  <= trackTP1

    if hitTP1
        totalW     += 1
        winStreak  += 1
        lossStreak := 0
        tracking   := false
        if showOutcomes
            label.new(bar_index, trackLong ? high : low, "✓",
                      yloc      = trackLong ? yloc.abovebar : yloc.belowbar,
                      color     = color.new(bullColor, 20),
                      textcolor = color.white, size=size.tiny,
                      style     = trackLong ? label.style_label_down : label.style_label_up)

    else if hitSL
        totalL     += 1
        lossStreak += 1
        winStreak  := 0
        tracking   := false
        if showOutcomes
            label.new(bar_index, trackLong ? low : high, "✗",
                      yloc      = trackLong ? yloc.belowbar : yloc.abovebar,
                      color     = color.new(bearColor, 20),
                      textcolor = color.white, size=size.tiny,
                      style     = trackLong ? label.style_label_up : label.style_label_down)

// ─────────────────────────────────────────────
// BAR COLORING
// Standard signal: bull/bear color; Fast path: cyan tint
// ─────────────────────────────────────────────

barcolor(isFastLong   ? color.new(#00FFFF, 50) :
         isFastShort  ? color.new(#00FFFF, 50) :
         finalLong    ? color.new(bullColor, 60) :
         finalShort   ? color.new(bearColor, 60) : na)

// ─────────────────────────────────────────────
// SL/TP SCORE SCALING
// ─────────────────────────────────────────────

scoreMultSL(score) =>
    score >= 6 ? 0.7 : score == 5 ? 0.8 : score == 4 ? 0.9 : 1.0

scoreMultTP(score) =>
    score >= 6 ? 1.8 : score == 5 ? 1.5 : score == 4 ? 1.2 : 1.0

// ─────────────────────────────────────────────
// LONG SIGNAL LABEL + SL/TP + ENTRY LINE + ZONE FILLS
// ─────────────────────────────────────────────

if finalLong
    slDist = atr * atrSlMult * scoreMultSL(longScore)
    tpMult = scoreMultTP(longScore)
    entryP = close
    slP    = entryP - slDist
    tp1P   = entryP + slDist * tp1R * tpMult
    tp2P   = entryP + slDist * tp2R * tpMult
    tp3P   = entryP + slDist * tp3R * tpMult
    rr     = math.round((tp1P - entryP) / (entryP - slP) * 10) / 10
    x1     = bar_index
    x2     = bar_index + extendBars

    if showSLTP
        line.new(x1, entryP, x2, entryP, color=entryColor, width=1, style=line.style_solid)
        label.new(x2, entryP, " ENTRY", color=color.new(entryColor, 80), textcolor=entryColor, size=size.small, style=label.style_label_right)
        line.new(x1, slP,  x2, slP,  color=slColor,  width=1, style=line.style_dashed)
        label.new(x2, slP,  " SL",  color=color.new(slColor,  80), textcolor=slColor,  size=size.small, style=label.style_label_right)
        line.new(x1, tp1P, x2, tp1P, color=tp1Color, width=1, style=line.style_dashed)
        line.new(x1, tp2P, x2, tp2P, color=tp2Color, width=1, style=line.style_dashed)
        line.new(x1, tp3P, x2, tp3P, color=tp3Color, width=1, style=line.style_dashed)
        label.new(x2, tp1P, " TP1", color=color.new(tp1Color, 80), textcolor=tp1Color, size=size.small, style=label.style_label_right)
        label.new(x2, tp2P, " TP2", color=color.new(tp2Color, 80), textcolor=tp2Color, size=size.small, style=label.style_label_right)
        label.new(x2, tp3P, " TP3", color=color.new(tp3Color, 80), textcolor=tp3Color, size=size.small, style=label.style_label_right)
        box.new(x1, entryP, x2, slP,    bgcolor=color.new(slColor,  sltpBgOpacity), border_color=color.new(color.black, 100))
        box.new(x1, tp1P,   x2, entryP, bgcolor=color.new(tp1Color, sltpBgOpacity), border_color=color.new(color.black, 100))
        box.new(x1, tp2P,   x2, tp1P,   bgcolor=color.new(tp2Color, sltpBgOpacity), border_color=color.new(color.black, 100))
        box.new(x1, tp3P,   x2, tp2P,   bgcolor=color.new(tp3Color, sltpBgOpacity), border_color=color.new(color.black, 100))

    fvgTag  = inBullFVGZone ? " FVG" : ""
    liqTag  = nearLiqHigh   ? " LIQ" : ""
    // Fast path label is cyan diamond; standard path is green triangle
    if isFastLong
        label.new(bar_index, low,
                  "▲ EMA× " + str.tostring(longScore) + "/7  R:" + str.tostring(rr) + fvgTag + liqTag,
                  yloc=yloc.belowbar, color=color.new(emaCrossColor, 10),
                  textcolor=color.black, size=size.normal, style=label.style_label_up)
    else
        label.new(bar_index, low,
                  "▲ " + str.tostring(longScore) + "/7  R:" + str.tostring(rr) + fvgTag + liqTag,
                  yloc=yloc.belowbar, color=color.new(bullColor, 10),
                  textcolor=color.white, size=size.normal, style=label.style_label_up)

// ─────────────────────────────────────────────
// SHORT SIGNAL LABEL + SL/TP + ENTRY LINE + ZONE FILLS
// ─────────────────────────────────────────────

if finalShort
    slDist = atr * atrSlMult * scoreMultSL(shortScore)
    tpMult = scoreMultTP(shortScore)
    entryP = close
    slP    = entryP + slDist
    tp1P   = entryP - slDist * tp1R * tpMult
    tp2P   = entryP - slDist * tp2R * tpMult
    tp3P   = entryP - slDist * tp3R * tpMult
    rr     = math.round((entryP - tp1P) / (slP - entryP) * 10) / 10
    x1     = bar_index
    x2     = bar_index + extendBars

    if showSLTP
        line.new(x1, entryP, x2, entryP, color=entryColor, width=1, style=line.style_solid)
        label.new(x2, entryP, " ENTRY", color=color.new(entryColor, 80), textcolor=entryColor, size=size.small, style=label.style_label_right)
        line.new(x1, slP,  x2, slP,  color=slColor,  width=1, style=line.style_dashed)
        label.new(x2, slP,  " SL",  color=color.new(slColor,  80), textcolor=slColor,  size=size.small, style=label.style_label_right)
        line.new(x1, tp1P, x2, tp1P, color=tp1Color, width=1, style=line.style_dashed)
        line.new(x1, tp2P, x2, tp2P, color=tp2Color, width=1, style=line.style_dashed)
        line.new(x1, tp3P, x2, tp3P, color=tp3Color, width=1, style=line.style_dashed)
        label.new(x2, tp1P, " TP1", color=color.new(tp1Color, 80), textcolor=tp1Color, size=size.small, style=label.style_label_right)
        label.new(x2, tp2P, " TP2", color=color.new(tp2Color, 80), textcolor=tp2Color, size=size.small, style=label.style_label_right)
        label.new(x2, tp3P, " TP3", color=color.new(tp3Color, 80), textcolor=tp3Color, size=size.small, style=label.style_label_right)
        box.new(x1, slP,    x2, entryP, bgcolor=color.new(slColor,  sltpBgOpacity), border_color=color.new(color.black, 100))
        box.new(x1, entryP, x2, tp1P,   bgcolor=color.new(tp1Color, sltpBgOpacity), border_color=color.new(color.black, 100))
        box.new(x1, tp1P,   x2, tp2P,   bgcolor=color.new(tp2Color, sltpBgOpacity), border_color=color.new(color.black, 100))
        box.new(x1, tp2P,   x2, tp3P,   bgcolor=color.new(tp3Color, sltpBgOpacity), border_color=color.new(color.black, 100))

    fvgTag  = inBearFVGZone ? " FVG" : ""
    liqTag  = nearLiqLow    ? " LIQ" : ""
    if isFastShort
        label.new(bar_index, high,
                  "▼ EMA× " + str.tostring(shortScore) + "/7  R:" + str.tostring(rr) + fvgTag + liqTag,
                  yloc=yloc.abovebar, color=color.new(emaCrossColor, 10),
                  textcolor=color.black, size=size.normal, style=label.style_label_down)
    else
        label.new(bar_index, high,
                  "▼ " + str.tostring(shortScore) + "/7  R:" + str.tostring(rr) + fvgTag + liqTag,
                  yloc=yloc.abovebar, color=color.new(bearColor, 10),
                  textcolor=color.white, size=size.normal, style=label.style_label_down)

// ─────────────────────────────────────────────
// HELPER FUNCTIONS
// ─────────────────────────────────────────────

tfmt(v) =>
    v ? "✓" : "✗"
fc(v) =>
    v ? color.new(#00C897, 0) : color.new(#FF4F5E, 0)

// ─────────────────────────────────────────────
// MAIN HUD TABLE
// ─────────────────────────────────────────────

if showTable
    var table hud = table.new(position.top_right, 3, 18,
                              bgcolor      = color.new(color.black, 75),
                              border_color = color.new(color.gray, 60),
                              border_width = 1,
                              frame_color  = color.new(color.gray, 50),
                              frame_width  = 1)

    col_label = color.new(color.gray, 30)
    col_bull  = color.new(#00C897, 20)
    col_bear  = color.new(#FF4F5E, 20)
    col_black = color.new(color.black, 50)
    col_hdr   = color.new(color.black, 60)
    col_warn  = color.new(#FF8C00, 40)
    col_cyan  = color.new(#00FFFF, 20)

    table.cell(hud, 0, 0, "Layer",         text_color=color.silver,          bgcolor=col_hdr, text_size=size.small)
    table.cell(hud, 1, 0, "Long",          text_color=color.new(#00C897, 0), bgcolor=col_hdr, text_size=size.small)
    table.cell(hud, 2, 0, "Short",         text_color=color.new(#FF4F5E, 0), bgcolor=col_hdr, text_size=size.small)

    table.cell(hud, 0, 1, "1 · Trend",     text_color=color.silver,  bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 1, tfmt(trendBull), text_color=fc(trendBull), bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 1, tfmt(trendBear), text_color=fc(trendBear), bgcolor=col_label, text_size=size.small)

    table.cell(hud, 0, 2, "2 · Momentum",  text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 2, tfmt(momBull),   text_color=fc(momBull),  bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 2, tfmt(momBear),   text_color=fc(momBear),  bgcolor=col_label, text_size=size.small)

    table.cell(hud, 0, 3, "3 · Volume",    text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 3, tfmt(volBull),   text_color=fc(volBull),  bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 3, tfmt(volBear),   text_color=fc(volBear),  bgcolor=col_label, text_size=size.small)

    table.cell(hud, 0, 4, "4 · Pullback",  text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 4, tfmt(pullBull),  text_color=fc(pullBull), bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 4, tfmt(pullBear),  text_color=fc(pullBear), bgcolor=col_label, text_size=size.small)

    table.cell(hud, 0, 5, "5 · Candle",     text_color=color.silver,   bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 5, tfmt(candleBull), text_color=fc(candleBull), bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 5, tfmt(candleBear), text_color=fc(candleBear), bgcolor=col_label, text_size=size.small)

    table.cell(hud, 0, 6, "6 · Divergence", text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 6, tfmt(bullDiv),    text_color=fc(bullDiv),  bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 6, tfmt(bearDiv),    text_color=fc(bearDiv),  bgcolor=col_label, text_size=size.small)

    // Layer 7 — Triple EMA Cross (cyan when active)
    crossBgL = tripleCrossBull ? col_cyan : col_label
    crossBgS = tripleCrossBear ? col_cyan : col_label
    crossTxtL = tripleCrossBull ? "✓ CROSS" : "✗"
    crossTxtS = tripleCrossBear ? "✓ CROSS" : "✗"
    crossColL = tripleCrossBull ? color.new(#00FFFF, 0) : color.new(#FF4F5E, 0)
    crossColS = tripleCrossBear ? color.new(#00FFFF, 0) : color.new(#FF4F5E, 0)
    table.cell(hud, 0, 7, "7 · 3×EMA",    text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 7, crossTxtL,       text_color=crossColL,    bgcolor=crossBgL,  text_size=size.small)
    table.cell(hud, 2, 7, crossTxtS,       text_color=crossColS,    bgcolor=crossBgS,  text_size=size.small)

    table.cell(hud, 0, 8, "SCORE",          text_color=color.white, bgcolor=col_black, text_size=size.small)
    table.cell(hud, 1, 8, str.tostring(longScore)  + "/7",
               text_color=longScore  >= confirmThreshold ? color.new(#00C897, 0) : color.silver,
               bgcolor=longScore  >= confirmThreshold ? col_bull : col_black, text_size=size.small)
    table.cell(hud, 2, 8, str.tostring(shortScore) + "/7",
               text_color=shortScore >= confirmThreshold ? color.new(#00C897, 0) : color.silver,
               bgcolor=shortScore >= confirmThreshold ? col_bear : col_black, text_size=size.small)

    // State machine row
    smTextL = smStateLong  == 0 ? "IDLE" : smStateLong  == 1 ? "SETUP" : smStateLong  == 2 ? "ARMED▶" : "TRIG"
    smTextS = smStateShort == 0 ? "IDLE" : smStateShort == 1 ? "SETUP" : smStateShort == 2 ? "ARMED▶" : "TRIG"
    smColL  = smStateLong  == 2 ? color.new(#00C897, 0) : smStateLong  == 1 ? color.new(#FFD700, 0) : color.gray
    smColS  = smStateShort == 2 ? color.new(#FF4F5E, 0) : smStateShort == 1 ? color.new(#FFD700, 0) : color.gray
    table.cell(hud, 0, 9, "State",   text_color=color.silver, bgcolor=col_black, text_size=size.small)
    table.cell(hud, 1, 9, smTextL,   text_color=smColL,       bgcolor=col_black, text_size=size.small)
    table.cell(hud, 2, 9, smTextS,   text_color=smColS,       bgcolor=col_black, text_size=size.small)

    // Signal row — distinguish fast path with cyan
    sigText  = finalLong  ? (isFastLong  ? "▲ EMA×" : "▲ LONG")  :
               finalShort ? (isFastShort ? "▼ EMA×" : "▼ SHORT") : "–"
    sigColor = finalLong  ? (isFastLong  ? color.new(#00FFFF, 0) : color.new(#00C897, 0)) :
               finalShort ? (isFastShort ? color.new(#00FFFF, 0) : color.new(#FF4F5E, 0)) : color.gray
    sigBg    = (isFastLong or isFastShort) ? col_cyan : col_black
    table.cell(hud, 0, 10, "SIGNAL",  text_color=color.white, bgcolor=col_black, text_size=size.small)
    table.cell(hud, 1, 10, sigText,   text_color=sigColor,    bgcolor=sigBg,     text_size=size.small)
    table.cell(hud, 2, 10, "BOS:" + tfmt(bosGateLong) + "/" + tfmt(bosGateShort),
               text_color=color.gray, bgcolor=col_black, text_size=size.small)

    exhTextL = exhaustLong  ? "⚠ BLOCK" : "clear"
    exhTextS = exhaustShort ? "⚠ BLOCK" : "clear"
    exhColL  = exhaustLong  ? color.new(#FF8C00, 0) : color.new(#00C897, 0)
    exhColS  = exhaustShort ? color.new(#FF8C00, 0) : color.new(#00C897, 0)
    table.cell(hud, 0, 11, "Exhaust",  text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 11, exhTextL,   text_color=exhColL,      bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 11, exhTextS,   text_color=exhColS,      bgcolor=col_label, text_size=size.small)

    volaText = atrRatio < atrMinMult ? "▼ low" : atrRatio > atrMaxMult ? "▲ high" : "● ok"
    volaCol  = atrRatio < atrMinMult or atrRatio > atrMaxMult ? color.new(#FF4F5E, 0) : color.new(#00C897, 0)
    table.cell(hud, 0, 12, "Volatility", text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 12, volaText,     text_color=volaCol,      bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 12, "ATR×" + str.tostring(math.round(atrRatio * 10) / 10),
               text_color=color.gray, bgcolor=col_label, text_size=size.small)

    deltaText = delta > 0 ? "▲ " + str.tostring(math.round(delta)) : "▼ " + str.tostring(math.round(delta))
    deltaCol  = delta > 0 ? color.new(#00C897, 0) : color.new(#FF4F5E, 0)
    cumText   = cumDelta > 0 ? "cum ▲" : "cum ▼"
    cumCol    = cumDelta > 0 ? color.new(#00C897, 0) : color.new(#FF4F5E, 0)
    table.cell(hud, 0, 13, "Delta",   text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 13, deltaText, text_color=deltaCol,     bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 13, cumText,   text_color=cumCol,       bgcolor=col_label, text_size=size.small)

    adxText    = str.tostring(math.round(adxVal))
    adxDispCol = adxTrending ? color.new(#FFD700, 0) : color.gray
    diText     = "D+:" + str.tostring(math.round(diPlus)) + " D-:" + str.tostring(math.round(diMinus))
    diDispCol  = diPlus > diMinus ? color.new(#00C897, 0) : color.new(#FF4F5E, 0)
    table.cell(hud, 0, 14, "ADX",           text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 14, "ADX " + adxText, text_color=adxDispCol,  bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 14, diText,           text_color=diDispCol,    bgcolor=col_label, text_size=size.small)

    mfiText    = str.tostring(math.round(mfi))
    mfiDispCol = mfi >= mfiOB ? color.new(#FF4F5E, 0) : mfi <= mfiOS ? color.new(#00C897, 0) :
                 mfi > 50 ? color.new(#00C897, 0) : color.new(#FF4F5E, 0)
    mfiState   = mfi >= mfiOB ? "OB" : mfi <= mfiOS ? "OS" : mfi > 50 ? "▲" : "▼"
    table.cell(hud, 0, 15, "MFI",           text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 15, "MFI " + mfiText, text_color=mfiDispCol,  bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 15, mfiState,         text_color=mfiDispCol,   bgcolor=col_label, text_size=size.small)

    tsText  = str.tostring(trendStrength) + "/10"
    tsCol   = trendStrength >= 7 ? color.new(#00C897, 0) :
              trendStrength >= 4 ? color.new(#FFD700, 0) : color.new(#FF4F5E, 0)
    tsLabel = trendStrength >= 7 ? "Strong" : trendStrength >= 4 ? "Moderate" : "Weak"
    table.cell(hud, 0, 16, "Trend Str", text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(hud, 1, 16, tsText,      text_color=tsCol,        bgcolor=col_label, text_size=size.small)
    table.cell(hud, 2, 16, tsLabel,     text_color=tsCol,        bgcolor=col_label, text_size=size.small)

    if showStreak
        wText = "W:" + str.tostring(totalW) + " str:" + str.tostring(winStreak)
        lText = "L:" + str.tostring(totalL) + " str:" + str.tostring(lossStreak)
        wCol  = winStreak  >= 3 ? color.new(#00C897, 0) : color.silver
        lCol  = lossStreak >= 3 ? color.new(#FF4F5E, 0) : color.silver
        table.cell(hud, 0, 17, "Streak", text_color=color.silver, bgcolor=col_label, text_size=size.small)
        table.cell(hud, 1, 17, wText,    text_color=wCol,         bgcolor=col_label, text_size=size.small)
        table.cell(hud, 2, 17, lText,    text_color=lCol,         bgcolor=col_label, text_size=size.small)

// ─────────────────────────────────────────────
// MULTI-SYMBOL HUD
// ─────────────────────────────────────────────

getSymData(sym) =>
    s_ema1  = request.security(sym, timeframe.period, ta.ema(close, ema1Len), lookahead=barmerge.lookahead_off)
    s_ema2  = request.security(sym, timeframe.period, ta.ema(close, ema2Len), lookahead=barmerge.lookahead_off)
    s_ema3  = request.security(sym, timeframe.period, ta.ema(close, ema3Len), lookahead=barmerge.lookahead_off)
    s_close = request.security(sym, timeframe.period, close,                  lookahead=barmerge.lookahead_off)
    s_rsi   = request.security(sym, timeframe.period, ta.rsi(close, rsiLen),  lookahead=barmerge.lookahead_off)
    s_vol   = request.security(sym, timeframe.period, volume,                 lookahead=barmerge.lookahead_off)
    s_volma = request.security(sym, timeframe.period, ta.sma(volume, volLen), lookahead=barmerge.lookahead_off)
    s_bull  = s_ema1 > s_ema2 and s_ema2 > s_ema3 and s_close > s_ema1
    s_bear  = s_ema1 < s_ema2 and s_ema2 < s_ema3 and s_close < s_ema1
    s_dir   = s_bull ? 1 : s_bear ? -1 : 0
    [s_dir, math.round(s_rsi), s_vol > s_volma * volMult]

[d1, r1, v1] = getSymData(sym1)
[d2, r2, v2] = getSymData(sym2)
[d3, r3, v3] = getSymData(sym3)

dirText(d) => d == 1 ? "▲ Bull" : d == -1 ? "▼ Bear" : "– Flat"
dirCol(d)  => d == 1 ? color.new(#00C897, 0) : d == -1 ? color.new(#FF4F5E, 0) : color.gray
rsiCol(r)  => r > 60 ? color.new(#00C897, 0) : r < 40 ? color.new(#FF4F5E, 0) : color.gray

symLabel(sym) =>
    parts = str.split(sym, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : sym

if showMulti
    var table msHud = table.new(position.bottom_right, 4, 4,
                                bgcolor      = color.new(color.black, 75),
                                border_color = color.new(color.gray, 60),
                                border_width = 1,
                                frame_color  = color.new(color.gray, 50),
                                frame_width  = 1)

    col_label = color.new(color.gray, 30)
    col_hdr   = color.new(color.black, 60)

    table.cell(msHud, 0, 0, "Symbol", text_color=color.silver, bgcolor=col_hdr, text_size=size.small)
    table.cell(msHud, 1, 0, "Trend",  text_color=color.silver, bgcolor=col_hdr, text_size=size.small)
    table.cell(msHud, 2, 0, "RSI",    text_color=color.silver, bgcolor=col_hdr, text_size=size.small)
    table.cell(msHud, 3, 0, "Vol",    text_color=color.silver, bgcolor=col_hdr, text_size=size.small)

    table.cell(msHud, 0, 1, symLabel(sym1),   text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(msHud, 1, 1, dirText(d1),      text_color=dirCol(d1),   bgcolor=col_label, text_size=size.small)
    table.cell(msHud, 2, 1, str.tostring(r1), text_color=rsiCol(r1),   bgcolor=col_label, text_size=size.small)
    table.cell(msHud, 3, 1, v1 ? "spike" : "–",
               text_color=v1 ? color.new(#FFD700, 0) : color.gray, bgcolor=col_label, text_size=size.small)

    table.cell(msHud, 0, 2, symLabel(sym2),   text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(msHud, 1, 2, dirText(d2),      text_color=dirCol(d2),   bgcolor=col_label, text_size=size.small)
    table.cell(msHud, 2, 2, str.tostring(r2), text_color=rsiCol(r2),   bgcolor=col_label, text_size=size.small)
    table.cell(msHud, 3, 2, v2 ? "spike" : "–",
               text_color=v2 ? color.new(#FFD700, 0) : color.gray, bgcolor=col_label, text_size=size.small)

    table.cell(msHud, 0, 3, symLabel(sym3),   text_color=color.silver, bgcolor=col_label, text_size=size.small)
    table.cell(msHud, 1, 3, dirText(d3),      text_color=dirCol(d3),   bgcolor=col_label, text_size=size.small)
    table.cell(msHud, 2, 3, str.tostring(r3), text_color=rsiCol(r3),   bgcolor=col_label, text_size=size.small)
    table.cell(msHud, 3, 3, v3 ? "spike" : "–",
               text_color=v3 ? color.new(#FFD700, 0) : color.gray, bgcolor=col_label, text_size=size.small)

// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

alertcondition(finalLong,
               title   = "CREA Scalper — LONG",
               message = "LONG | Score: {{longScore}}/7 | {{ticker}} {{interval}}")
alertcondition(finalShort,
               title   = "CREA Scalper — SHORT",
               message = "SHORT | Score: {{shortScore}}/7 | {{ticker}} {{interval}}")
alertcondition(finalLong or finalShort,
               title   = "CREA Scalper — Any signal",
               message = "Signal on {{ticker}} {{interval}}")
alertcondition(isFastLong,
               title   = "CREA Scalper — FAST LONG (EMA×)",
               message = "FAST LONG — Triple EMA Cross | Score: {{longScore}}/7 | {{ticker}} {{interval}}")
alertcondition(isFastShort,
               title   = "CREA Scalper — FAST SHORT (EMA×)",
               message = "FAST SHORT — Triple EMA Cross | Score: {{shortScore}}/7 | {{ticker}} {{interval}}")
alertcondition(nearLong,
               title   = "CREA Scalper — LONG forming",
               message = "Long forming (ARMED or near threshold) | {{ticker}} {{interval}}")
alertcondition(nearShort,
               title   = "CREA Scalper — SHORT forming",
               message = "Short forming (ARMED or near threshold) | {{ticker}} {{interval}}")
alertcondition(smStateLong == 2,
               title   = "CREA Scalper — LONG ARMED",
               message = "Long state ARMED — awaiting candle trigger | {{ticker}} {{interval}}")
alertcondition(smStateShort == 2,
               title   = "CREA Scalper — SHORT ARMED",
               message = "Short state ARMED — awaiting candle trigger | {{ticker}} {{interval}}")
alertcondition(ema1CrossAbove2 and ema2 > ema3,
               title   = "CREA Scalper — Triple EMA Bull Cross",
               message = "Triple EMA bullish cross detected | {{ticker}} {{interval}}")
alertcondition(ema1CrossBelow2 and ema2 < ema3,
               title   = "CREA Scalper — Triple EMA Bear Cross",
               message = "Triple EMA bearish cross detected | {{ticker}} {{interval}}")
````
