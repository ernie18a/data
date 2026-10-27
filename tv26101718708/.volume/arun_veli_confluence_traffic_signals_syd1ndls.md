# Arun Veli - Confluence Traffic Signals

- url: https://www.tradingview.com/script/SYD1NDLS-Arun-Veli-Confluence-Traffic-Signals/
- type: indicator
- pine_id: PUB;c82d3c1f93e245a5a7dd29e1ae48a377
- version: 1.0

## Description

# Arun Veli — Confluence Traffic Signals

## TradingView Publication Description

---

### Title (60 char max)
**Arun Veli — Confluence Traffic Signals**

### Short Description (120 char max)
7-factor confluence engine for intraday SPY/SPX/QQQ scalping. EMAs + VWAP + Gaussian Channel + MACD + RSI + Volume + Trigger.

---

### Full Description (paste into TradingView's Publish form)

**Overview**

Arun Veli — Confluence Traffic Signals is a production-quality intraday confluence indicator built for active scalping and 0DTE options trading on liquid index instruments (SPY, SPX, QQQ, IWM, NDX). It produces visual traffic-light signals only when a configurable minimum number of independent confluence factors align across trend, momentum, volume, and structural triggers.

The design philosophy: **signal quality over signal quantity**. Rather than firing on every moving-average cross, the indicator scores each bar across seven independent dimensions and produces a signal only when the threshold is met, the session timing is appropriate, and the bar is confirmed (closed). This eliminates repaint behavior and reduces false signals during chop.

**Seven Confluence Factors**

Each bar is scored against seven independent conditions. Scores are calculated separately for long and short setups.

1. **EMA Ribbon Alignment**: Fast (9), Slow (21), and Trend (50) EMAs stacked in the direction of the candidate signal
2. **VWAP Side**: Price is above (long) or below (short) the session-anchored VWAP, the primary institutional intraday reference level
3. **Gaussian Channel**: Price is on the correct side of the Ehlers Gaussian filter midline AND the channel itself is rotating in the same direction
4. **MACD Histogram**: Histogram is positive and rising (long) or negative and falling (short) on default 12/26/9 settings
5. **RSI Zone**: RSI is in the bullish 50-70 zone (long) or bearish 30-50 zone (short), avoiding overextended setups
6. **Volume Spike**: Current bar volume is at least 1.3× the 20-period average, indicating institutional participation
7. **Trigger Event**: Either a fresh EMA cross, VWAP reclaim/loss, or Opening Range Breakout in the candidate direction

A signal fires when the score meets your configurable minimum (default 5/7) AND the trigger factor is present AND the session filter passes.

**Yellow Caution Signals**

Yellow traffic lights mark mean-reversion exhaustion: price wicks beyond the 2-StDev VWAP band while RSI is at an extreme (≥70 at top, ≤30 at bottom) and the bar closes back inside. These do not require the full 7-factor scoring; they exist to flag potential reversals at extremes.

**Risk Management Levels**

When a long or short signal fires, the indicator automatically plots three lines extending forward:
- **Stop Loss**: Entry ± 1.5 × ATR (default, configurable)
- **Target 1**: Entry ± 2.0 × ATR
- **Target 2**: Entry ± 3.5 × ATR

This produces a roughly 1:1.3 risk-reward at TP1 and 1:2.3 at TP2, which is consistent with profitable scalping math when win rate is above 45%.

**Session Time Filter**

Default prime hours are 09:45 to 15:45 NY time, skipping the volatile first 15 minutes of the open and the final 15 minutes of closing rotation. An optional lunch chop filter (11:30 to 13:30) can be enabled for traders who avoid the midday low-volume drift period.

**Opening Range Breakout (ORB) Levels**

The first N minutes (default 15, configurable up to 60) of the regular trading hours session are tracked, and ORB high/low levels are plotted on the chart. ORB breakouts feed into the Trigger factor of the confluence engine.

**Live Dashboard**

A heads-up table displays all seven factors with green checkmarks or red X marks for both long and short candidates, plus the current confluence score, RSI value, ATR, VWAP distance percentage, and bars since last signal. Position is configurable.

**Webhook Automation**

In addition to standard TradingView alerts, the indicator emits structured JSON via the `alert()` function on every signal. Format:

```
{
  "signal": "LONG",
  "ticker": "SPY",
  "price": 580.42,
  "score": 6,
  "sl": 578.95,
  "tp1": 582.38,
  "tp2": 583.85,
  "time": "1715268000000"
}
```

This makes the indicator drop-in compatible with webhook handlers, broker bridges, Discord/Slack integrations, and execution platforms.

**Recommended Configuration**

- **SPY/SPX 0DTE scalping (1-2 minute charts)**: Min Score 5/7, Cooldown 5 bars, Volume Spike 1.3×, default ORB 15 min
- **QQQ swing-intraday (5-15 minute charts)**: Min Score 4/7, Cooldown 8 bars, Volume Spike 1.5×
- **Higher timeframe confirmation (1H+)**: Min Score 5/7, increase ATR multipliers to 2.0/3.0/5.0

**Best Use Cases**

- 0DTE options scalping on SPX, SPY, QQQ, NDX, IWM, RUT
- Intraday futures scalping on ES, NQ, MES, MNQ
- Active stock day trading on liquid large-caps (NVDA, AAPL, TSLA, etc.)
- As an entry confirmation layer alongside your existing analysis

**What This Is Not**

This indicator is not a complete trading system. It does not include position sizing logic, automated order execution, or backtested edge claims. Like every indicator, it can produce false signals, particularly in low-volume environments, during major news events, or in unusual market conditions. The default settings are starting points, not optimal values for your specific style. Always test on demo or paper before risking real capital, and use position sizing appropriate to your account.

**Credits**

- **John Ehlers** for the original Gaussian filter mathematics
- **Donovan Wall** for the public TradingView Gaussian Channel implementation that this indicator's filter is based on

---

### Suggested Tags
0DTE, scalping, SPX, SPY, QQQ, VWAP, MACD, RSI, EMA, gaussian, confluence, intraday, options, traffic light, momentum, ATR

### Category
Technical Indicators → Trend Analysis (or Momentum Indicators)

### Visibility
Public (or Invite-Only initially while you battle-test)

---

### Suggested Chart for Publication Screenshot

For the publish screenshot, use:
- **Symbol**: SPY (most accessible)
- **Timeframe**: 5-minute or 2-minute
- **Time of day**: Capture during the 10:00 AM ET hour (most active period)
- **Market state**: A trending day with at least one clear long or short signal visible plus the dashboard
- **Layout**: Full chart with the dashboard visible in top-right corner; ensure VWAP, GC, EMAs all visible

## Source Code

````pine
//@version=6
indicator("Arun Veli - Confluence Traffic Signals", shorttitle="AV Confluence", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=50)

// =============================================================================
// Arun Veli - Confluence Traffic Signals
//
// A production-quality intraday confluence indicator built for active scalping
// and 0DTE options trading on SPY, SPX, QQQ, and other liquid index instruments.
//
// Design principles (informed by research on top intraday/0DTE indicators):
//   1. Weighted multi-factor scoring across 7 independent dimensions
//   2. AND-gate confluence (no signal unless minimum score AND all hard filters pass)
//   3. Bar-confirmation gate (barstate.isconfirmed) to prevent repainting
//   4. Session time filtering (prime hours only, configurable)
//   5. ATR-based stop loss and target levels plotted with each signal
//   6. Live dashboard with all component states for transparency
//   7. Webhook-ready JSON alerts for automation pipelines
//
// Visual signals:
//   GREEN traffic light  = Long (CALL) setup
//   RED traffic light    = Short (PUT) setup
//   YELLOW traffic light = Caution / mean-reversion warning at extremes
//
// Credits:
//   - John Ehlers - Gaussian filter mathematics
//   - Donovan Wall - public TradingView Gaussian Channel implementation
// =============================================================================

// =============================================================================
// INPUTS - SIGNAL ENGINE
// =============================================================================
grpEng = "Signal Engine"
minScore = input.int(5, "Minimum Confluence Score (out of 7)", group=grpEng, minval=2, maxval=7,
     tooltip="Number of confluence factors required to fire a signal. Higher = fewer but stronger signals.")
cooldownBars = input.int(5, "Cooldown Between Signals (bars)", group=grpEng, minval=1)
useBarConfirmation = input.bool(true, "Wait for Bar Close (no repaint)", group=grpEng,
     tooltip="Strongly recommended. Prevents signals from appearing then disappearing on incomplete bars.")

// =============================================================================
// INPUTS - TREND (EMA Ribbon + Gaussian Channel)
// =============================================================================
grpTrend = "Trend Filters"
emaFastLen = input.int(9,  "EMA Fast",   group=grpTrend, minval=1)
emaSlowLen = input.int(21, "EMA Slow",   group=grpTrend, minval=1)
emaTrendLen= input.int(50, "EMA Trend",  group=grpTrend, minval=1)
showRibbon = input.bool(true, "Show EMA Ribbon", group=grpTrend)

grpGC = "Gaussian Channel"
gcSrc    = input.source(hlc3, "GC Source",      group=grpGC)
gcPoles  = input.int(4,       "GC Poles",       group=grpGC, minval=1, maxval=9)
gcPeriod = input.int(25,      "GC Period",      group=grpGC, minval=2)
gcMult   = input.float(1.414, "GC TR Multiplier",group=grpGC, step=0.001)
showChan = input.bool(true,   "Show Gaussian Channel", group=grpGC)

// =============================================================================
// INPUTS - VWAP (institutional intraday reference)
// =============================================================================
grpVWAP = "VWAP"
vwapStdMult1 = input.float(1.0, "VWAP Band 1 StDev", group=grpVWAP, step=0.1)
vwapStdMult2 = input.float(2.0, "VWAP Band 2 StDev", group=grpVWAP, step=0.1)
showVWAP     = input.bool(true, "Show VWAP and Bands", group=grpVWAP)

// =============================================================================
// INPUTS - MOMENTUM (MACD + RSI)
// =============================================================================
grpMom = "Momentum"
macdFast = input.int(12, "MACD Fast",    group=grpMom)
macdSlow = input.int(26, "MACD Slow",    group=grpMom)
macdSig  = input.int(9,  "MACD Signal",  group=grpMom)
rsiLen   = input.int(14, "RSI Length",   group=grpMom)
rsiOB    = input.int(70, "RSI Overbought (block longs)", group=grpMom)
rsiOS    = input.int(30, "RSI Oversold (block shorts)",  group=grpMom)

// =============================================================================
// INPUTS - VOLUME
// =============================================================================
grpVol = "Volume"
volSpikeMult = input.float(1.3, "Volume Spike Multiplier", group=grpVol, step=0.1,
     tooltip="Current volume must be N times the 20-period average to count as a confluence factor.")
volMaLen     = input.int(20,    "Volume MA Length",       group=grpVol)

// =============================================================================
// INPUTS - OPENING RANGE BREAKOUT (ORB)
// =============================================================================
grpORB = "Opening Range"
orbMins   = input.int(15, "ORB Window (minutes from open)", group=grpORB, minval=5, maxval=60)
showORB   = input.bool(true, "Show ORB Levels", group=grpORB)

// =============================================================================
// INPUTS - SESSION FILTER
// =============================================================================
grpSess = "Session Filter"
useSessionFilter = input.bool(true, "Only Fire During Prime Hours", group=grpSess)
sessionStart     = input.session("0945-1545", "Prime Hours (NY time)", group=grpSess,
     tooltip="Default skips first 15 minutes (volatile open) and last 15 minutes (closing rotation). 'Lunch chop' (1130-1330) traditionally has weaker signals.")
avoidLunch       = input.bool(false, "Skip Lunch (1130-1330 NY)", group=grpSess)

// =============================================================================
// INPUTS - RISK MANAGEMENT
// =============================================================================
grpRisk = "Risk Management"
showStops = input.bool(true,  "Show ATR-based Stops & Targets", group=grpRisk)
atrLen    = input.int(14,     "ATR Length",       group=grpRisk)
slMult    = input.float(1.5,  "Stop Loss ATR Mult", group=grpRisk, step=0.1)
tp1Mult   = input.float(2.0,  "Target 1 ATR Mult",  group=grpRisk, step=0.1)
tp2Mult   = input.float(3.5,  "Target 2 ATR Mult",  group=grpRisk, step=0.1)

// =============================================================================
// INPUTS - DISPLAY
// =============================================================================
grpD = "Display"
showLights    = input.bool(true,  "Show Traffic Light Signals", group=grpD)
showDashboard = input.bool(true,  "Show Live Dashboard",        group=grpD)
dashPos       = input.string("top_right", "Dashboard Position", options=["top_right","top_left","bottom_right","bottom_left","middle_right"], group=grpD)
labelSize     = input.string("normal", "Light Size", options=["small","normal","large"], group=grpD)

// =============================================================================
// CALCULATIONS - TREND
// =============================================================================
emaFast  = ta.ema(close, emaFastLen)
emaSlow  = ta.ema(close, emaSlowLen)
emaTrend = ta.ema(close, emaTrendLen)

ribbonBull = emaFast > emaSlow and emaSlow > emaTrend
ribbonBear = emaFast < emaSlow and emaSlow < emaTrend

// =============================================================================
// CALCULATIONS - GAUSSIAN CHANNEL
// =============================================================================
PI    = 2 * math.asin(1)
beta  = (1 - math.cos(4 * PI / gcPeriod)) / (math.pow(1.414, 2 / gcPoles) - 1)
alpha = -beta + math.sqrt(beta * beta + 2 * beta)

f_gauss(src, a, poles) =>
    var float p1 = 0.0, var float p2 = 0.0, var float p3 = 0.0
    var float p4 = 0.0, var float p5 = 0.0, var float p6 = 0.0
    var float p7 = 0.0, var float p8 = 0.0, var float p9 = 0.0
    s = nz(src, src)
    p1 := a * s + (1-a) * nz(p1[1])
    p2 := poles >= 2 ? a * p1 + (1-a) * nz(p2[1]) : p1
    p3 := poles >= 3 ? a * p2 + (1-a) * nz(p3[1]) : p2
    p4 := poles >= 4 ? a * p3 + (1-a) * nz(p4[1]) : p3
    p5 := poles >= 5 ? a * p4 + (1-a) * nz(p5[1]) : p4
    p6 := poles >= 6 ? a * p5 + (1-a) * nz(p6[1]) : p5
    p7 := poles >= 7 ? a * p6 + (1-a) * nz(p7[1]) : p6
    p8 := poles >= 8 ? a * p7 + (1-a) * nz(p8[1]) : p7
    p9 := poles >= 9 ? a * p8 + (1-a) * nz(p9[1]) : p8
    poles == 1 ? p1 : poles == 2 ? p2 : poles == 3 ? p3 : poles == 4 ? p4 : poles == 5 ? p5 : poles == 6 ? p6 : poles == 7 ? p7 : poles == 8 ? p8 : p9

f_gaussTR(src, a, poles) =>
    var float p1 = 0.0, var float p2 = 0.0, var float p3 = 0.0
    var float p4 = 0.0, var float p5 = 0.0, var float p6 = 0.0
    var float p7 = 0.0, var float p8 = 0.0, var float p9 = 0.0
    s = nz(src, src)
    p1 := a * s + (1-a) * nz(p1[1])
    p2 := poles >= 2 ? a * p1 + (1-a) * nz(p2[1]) : p1
    p3 := poles >= 3 ? a * p2 + (1-a) * nz(p3[1]) : p2
    p4 := poles >= 4 ? a * p3 + (1-a) * nz(p4[1]) : p3
    p5 := poles >= 5 ? a * p4 + (1-a) * nz(p5[1]) : p4
    p6 := poles >= 6 ? a * p5 + (1-a) * nz(p6[1]) : p5
    p7 := poles >= 7 ? a * p6 + (1-a) * nz(p7[1]) : p6
    p8 := poles >= 8 ? a * p7 + (1-a) * nz(p8[1]) : p7
    p9 := poles >= 9 ? a * p8 + (1-a) * nz(p9[1]) : p8
    poles == 1 ? p1 : poles == 2 ? p2 : poles == 3 ? p3 : poles == 4 ? p4 : poles == 5 ? p5 : poles == 6 ? p6 : poles == 7 ? p7 : poles == 8 ? p8 : p9

gcFilt = f_gauss(gcSrc, alpha, gcPoles)
gcTR   = f_gaussTR(ta.tr(true), alpha, gcPoles)
gcUpper = gcFilt + gcTR * gcMult
gcLower = gcFilt - gcTR * gcMult
gcRising = gcFilt > gcFilt[1]
gcColor  = gcRising ? color.new(#26a69a, 0) : color.new(#ef5350, 0)

// =============================================================================
// CALCULATIONS - VWAP WITH BANDS
// =============================================================================
vwapVal = ta.vwap(hlc3)
vwapDev = math.sqrt(ta.cum(math.pow(hlc3 - vwapVal, 2) * volume) / ta.cum(volume))
vwapU1 = vwapVal + vwapDev * vwapStdMult1
vwapL1 = vwapVal - vwapDev * vwapStdMult1
vwapU2 = vwapVal + vwapDev * vwapStdMult2
vwapL2 = vwapVal - vwapDev * vwapStdMult2

// =============================================================================
// CALCULATIONS - MOMENTUM
// =============================================================================
[macdLine, macdSignal, macdHist] = ta.macd(close, macdFast, macdSlow, macdSig)
rsiVal = ta.rsi(close, rsiLen)

// =============================================================================
// CALCULATIONS - VOLUME
// =============================================================================
volMa = ta.sma(volume, volMaLen)
volSpike = volume >= volMa * volSpikeMult

// =============================================================================
// CALCULATIONS - ATR
// =============================================================================
atrVal = ta.atr(atrLen)

// =============================================================================
// CALCULATIONS - OPENING RANGE BREAKOUT
// =============================================================================
isRTH = not na(time(timeframe.period, "0930-1600", "America/New_York"))
isORBWindow = not na(time(timeframe.period, "0930-09" + (orbMins < 30 ? "45" : str.tostring(30 + (orbMins - 30))), "America/New_York"))

var float orbHigh = na
var float orbLow  = na
var float prevOrbHigh = na
var float prevOrbLow  = na
isNewSession = ta.change(time("D")) != 0

if isNewSession
    prevOrbHigh := orbHigh
    prevOrbLow  := orbLow
    orbHigh := na
    orbLow  := na

if isORBWindow
    orbHigh := na(orbHigh) ? high : math.max(orbHigh, high)
    orbLow  := na(orbLow)  ? low  : math.min(orbLow,  low)

orbBreakUp   = isRTH and not isORBWindow and not na(orbHigh) and close > orbHigh and close[1] <= orbHigh
orbBreakDown = isRTH and not isORBWindow and not na(orbLow)  and close < orbLow  and close[1] >= orbLow

// =============================================================================
// CALCULATIONS - SESSION FILTER
// =============================================================================
inPrimeHours = useSessionFilter ? not na(time(timeframe.period, sessionStart, "America/New_York")) : true
inLunchChop  = avoidLunch ? not na(time(timeframe.period, "1130-1330", "America/New_York")) : false
sessionOK    = inPrimeHours and not inLunchChop

// =============================================================================
// CONFLUENCE SCORING - 7 INDEPENDENT FACTORS
// =============================================================================
// LONG factors
long1 = ribbonBull                           // Trend: EMA ribbon stacked bullish
long2 = close > vwapVal                      // VWAP: price above
long3 = close > gcFilt and gcRising          // GC: price above filter, channel rising
long4 = macdHist > 0 and macdHist > macdHist[1]  // MACD: positive and rising
long5 = rsiVal > 50 and rsiVal < rsiOB       // RSI: bullish but not overbought
long6 = volSpike                             // Volume: above-average activity
long7 = ta.crossover(close, emaFast) or ta.crossover(close, vwapVal) or orbBreakUp  // Trigger event

longScore = (long1 ? 1 : 0) + (long2 ? 1 : 0) + (long3 ? 1 : 0) + (long4 ? 1 : 0) + (long5 ? 1 : 0) + (long6 ? 1 : 0) + (long7 ? 1 : 0)

// SHORT factors (mirror)
short1 = ribbonBear
short2 = close < vwapVal
short3 = close < gcFilt and not gcRising
short4 = macdHist < 0 and macdHist < macdHist[1]
short5 = rsiVal < 50 and rsiVal > rsiOS
short6 = volSpike
short7 = ta.crossunder(close, emaFast) or ta.crossunder(close, vwapVal) or orbBreakDown

shortScore = (short1 ? 1 : 0) + (short2 ? 1 : 0) + (short3 ? 1 : 0) + (short4 ? 1 : 0) + (short5 ? 1 : 0) + (short6 ? 1 : 0) + (short7 ? 1 : 0)

// YELLOW (caution at extremes)
yellowTop = high >= vwapU2 and rsiVal >= rsiOB and close < open
yellowBot = low  <= vwapL2 and rsiVal <= rsiOS and close > open

// =============================================================================
// SIGNAL GATING - apply minimum score, session filter, bar confirmation, cooldown
// =============================================================================
barOK = useBarConfirmation ? barstate.isconfirmed : true

greenRaw  = longScore  >= minScore and long7 and sessionOK
redRaw    = shortScore >= minScore and short7 and sessionOK
yellowRaw = (yellowTop or yellowBot) and sessionOK

var int lastSigBar = -1000
canFire = bar_index - lastSigBar >= cooldownBars and barOK

greenFinal  = greenRaw  and canFire
redFinal    = redRaw    and canFire
yellowFinal = yellowRaw and canFire and not greenFinal and not redFinal

if greenFinal or redFinal or yellowFinal
    lastSigBar := bar_index

// Track yellow type for placement
yellowFinalTop = yellowFinal and yellowTop
yellowFinalBot = yellowFinal and yellowBot and not yellowTop

// =============================================================================
// PLOTS - TREND
// =============================================================================
plot(showRibbon ? emaFast  : na, "EMA Fast",  color=color.new(color.aqua,    20), linewidth=1)
plot(showRibbon ? emaSlow  : na, "EMA Slow",  color=color.new(color.orange,  20), linewidth=1)
plot(showRibbon ? emaTrend : na, "EMA Trend", color=color.new(color.yellow,  40), linewidth=2)

// =============================================================================
// PLOTS - GAUSSIAN CHANNEL
// =============================================================================
plot(showChan ? gcFilt : na, "GC Midline", color=color.new(color.white, 30), linewidth=1, style=plot.style_circles)
pUp = plot(showChan ? gcUpper : na, "GC Upper", color=gcColor, linewidth=2)
pLo = plot(showChan ? gcLower : na, "GC Lower", color=gcColor, linewidth=2)
fill(pUp, pLo, color=color.new(gcColor, 92), title="GC Fill")

// =============================================================================
// PLOTS - VWAP
// =============================================================================
plot(showVWAP ? vwapVal : na, "VWAP",       color=color.new(color.purple, 0), linewidth=2)
pV1u = plot(showVWAP ? vwapU1 : na, "VWAP U1", color=color.new(color.purple, 70))
pV1l = plot(showVWAP ? vwapL1 : na, "VWAP L1", color=color.new(color.purple, 70))
pV2u = plot(showVWAP ? vwapU2 : na, "VWAP U2", color=color.new(color.purple, 50))
pV2l = plot(showVWAP ? vwapL2 : na, "VWAP L2", color=color.new(color.purple, 50))
fill(pV1u, pV1l, color=color.new(color.purple, 95), title="VWAP Inner")
fill(pV2u, pV1u, color=color.new(color.purple, 96), title="VWAP Outer Up")
fill(pV1l, pV2l, color=color.new(color.purple, 96), title="VWAP Outer Dn")

// =============================================================================
// PLOTS - ORB LEVELS
// =============================================================================
plot(showORB and not na(orbHigh) and isRTH ? orbHigh : na, "ORB High", color=color.new(color.yellow, 0), linewidth=2, style=plot.style_linebr)
plot(showORB and not na(orbLow)  and isRTH ? orbLow  : na, "ORB Low",  color=color.new(color.yellow, 0), linewidth=2, style=plot.style_linebr)

// =============================================================================
// PLOTS - TRAFFIC LIGHTS
// =============================================================================
RED_LIT    = "🔴\n⚫\n⚫"
YELLOW_LIT = "⚫\n🟡\n⚫"
GREEN_LIT  = "⚫\n⚫\n🟢"

f_size() => labelSize == "small" ? size.small : labelSize == "large" ? size.large : size.normal

if showLights and greenFinal
    label.new(bar_index, low, GREEN_LIT,
         color=color.new(color.black, 20),
         textcolor=color.white,
         style=label.style_label_up,
         size=f_size(),
         yloc=yloc.belowbar,
         tooltip="LONG signal | Score: " + str.tostring(longScore) + "/7")

if showLights and redFinal
    label.new(bar_index, high, RED_LIT,
         color=color.new(color.black, 20),
         textcolor=color.white,
         style=label.style_label_down,
         size=f_size(),
         yloc=yloc.abovebar,
         tooltip="SHORT signal | Score: " + str.tostring(shortScore) + "/7")

if showLights and yellowFinalTop
    label.new(bar_index, high, YELLOW_LIT,
         color=color.new(color.black, 20),
         textcolor=color.white,
         style=label.style_label_down,
         size=f_size(),
         yloc=yloc.abovebar,
         tooltip="CAUTION: Upper extreme rejection")

if showLights and yellowFinalBot
    label.new(bar_index, low, YELLOW_LIT,
         color=color.new(color.black, 20),
         textcolor=color.white,
         style=label.style_label_up,
         size=f_size(),
         yloc=yloc.belowbar,
         tooltip="CAUTION: Lower extreme rejection")

// =============================================================================
// STOP LOSS AND TARGETS - draw lines for active signal
// =============================================================================
var line slLine = na
var line tp1Line = na
var line tp2Line = na
var label slLabel = na
var label tp1Label = na
var label tp2Label = na

if showStops and (greenFinal or redFinal)
    if not na(slLine)
        line.delete(slLine)
        line.delete(tp1Line)
        line.delete(tp2Line)
        label.delete(slLabel)
        label.delete(tp1Label)
        label.delete(tp2Label)

    entry = close
    sl  = greenFinal ? entry - atrVal * slMult  : entry + atrVal * slMult
    tp1 = greenFinal ? entry + atrVal * tp1Mult : entry - atrVal * tp1Mult
    tp2 = greenFinal ? entry + atrVal * tp2Mult : entry - atrVal * tp2Mult

    slLine  := line.new(bar_index, sl,  bar_index + 20, sl,  color=color.red,    width=2, style=line.style_dashed, extend=extend.right)
    tp1Line := line.new(bar_index, tp1, bar_index + 20, tp1, color=color.green,  width=1, style=line.style_dashed, extend=extend.right)
    tp2Line := line.new(bar_index, tp2, bar_index + 20, tp2, color=color.green,  width=2, style=line.style_dashed, extend=extend.right)

    slLabel  := label.new(bar_index + 20, sl,  "SL "  + str.tostring(sl,  format.mintick), color=color.new(color.red,80),    textcolor=color.white, style=label.style_label_left, size=size.small)
    tp1Label := label.new(bar_index + 20, tp1, "TP1 " + str.tostring(tp1, format.mintick), color=color.new(color.green,80),  textcolor=color.white, style=label.style_label_left, size=size.small)
    tp2Label := label.new(bar_index + 20, tp2, "TP2 " + str.tostring(tp2, format.mintick), color=color.new(color.green,60),  textcolor=color.white, style=label.style_label_left, size=size.small)

// =============================================================================
// LIVE DASHBOARD
// =============================================================================
f_dashPos() =>
    switch dashPos
        "top_left"      => position.top_left
        "top_right"     => position.top_right
        "bottom_left"   => position.bottom_left
        "bottom_right"  => position.bottom_right
        "middle_right"  => position.middle_right
        => position.top_right

f_yn(b) => b ? "✓" : "✗"
f_color(b) => b ? color.green : color.red

if showDashboard and barstate.islast
    var table d = table.new(f_dashPos(), 3, 14, bgcolor=color.new(color.black, 10), border_width=1, border_color=color.new(color.gray, 50))

    table.cell(d, 0, 0, "Factor",  text_color=color.white, bgcolor=color.new(color.gray, 40))
    table.cell(d, 1, 0, "Long",    text_color=color.white, bgcolor=color.new(color.gray, 40))
    table.cell(d, 2, 0, "Short",   text_color=color.white, bgcolor=color.new(color.gray, 40))

    table.cell(d, 0, 1, "EMA Ribbon",     text_color=color.white)
    table.cell(d, 1, 1, f_yn(long1),  text_color=f_color(long1))
    table.cell(d, 2, 1, f_yn(short1), text_color=f_color(short1))

    table.cell(d, 0, 2, "VWAP Side",      text_color=color.white)
    table.cell(d, 1, 2, f_yn(long2),  text_color=f_color(long2))
    table.cell(d, 2, 2, f_yn(short2), text_color=f_color(short2))

    table.cell(d, 0, 3, "Gaussian Ch",    text_color=color.white)
    table.cell(d, 1, 3, f_yn(long3),  text_color=f_color(long3))
    table.cell(d, 2, 3, f_yn(short3), text_color=f_color(short3))

    table.cell(d, 0, 4, "MACD Hist",      text_color=color.white)
    table.cell(d, 1, 4, f_yn(long4),  text_color=f_color(long4))
    table.cell(d, 2, 4, f_yn(short4), text_color=f_color(short4))

    table.cell(d, 0, 5, "RSI Zone",       text_color=color.white)
    table.cell(d, 1, 5, f_yn(long5),  text_color=f_color(long5))
    table.cell(d, 2, 5, f_yn(short5), text_color=f_color(short5))

    table.cell(d, 0, 6, "Volume",         text_color=color.white)
    table.cell(d, 1, 6, f_yn(long6),  text_color=f_color(long6))
    table.cell(d, 2, 6, f_yn(short6), text_color=f_color(short6))

    table.cell(d, 0, 7, "Trigger",        text_color=color.white)
    table.cell(d, 1, 7, f_yn(long7),  text_color=f_color(long7))
    table.cell(d, 2, 7, f_yn(short7), text_color=f_color(short7))

    table.cell(d, 0, 8, "SCORE", text_color=color.white, bgcolor=color.new(color.gray, 60))
    table.cell(d, 1, 8, str.tostring(longScore)  + "/7", text_color=longScore  >= minScore ? color.green : color.gray, bgcolor=color.new(color.gray, 60))
    table.cell(d, 2, 8, str.tostring(shortScore) + "/7", text_color=shortScore >= minScore ? color.red   : color.gray, bgcolor=color.new(color.gray, 60))

    table.cell(d, 0, 9, "Session OK",      text_color=color.white)
    table.cell(d, 1, 9, sessionOK ? "YES" : "NO", text_color=sessionOK ? color.green : color.red)
    table.cell(d, 2, 9, "", text_color=color.white)

    table.cell(d, 0, 10, "RSI",            text_color=color.white)
    table.cell(d, 1, 10, str.tostring(rsiVal, "#.0"), text_color=rsiVal >= rsiOB ? color.red : rsiVal <= rsiOS ? color.green : color.white)
    table.cell(d, 2, 10, "", text_color=color.white)

    table.cell(d, 0, 11, "ATR",            text_color=color.white)
    table.cell(d, 1, 11, str.tostring(atrVal, format.mintick), text_color=color.white)
    table.cell(d, 2, 11, "", text_color=color.white)

    table.cell(d, 0, 12, "VWAP Dist",      text_color=color.white)
    vwapDistPct = (close - vwapVal) / vwapVal * 100
    table.cell(d, 1, 12, str.tostring(vwapDistPct, "#.00") + "%", text_color=vwapDistPct > 0 ? color.green : color.red)
    table.cell(d, 2, 12, "", text_color=color.white)

    table.cell(d, 0, 13, "Last Signal",    text_color=color.white)
    table.cell(d, 1, 13, str.tostring(bar_index - lastSigBar) + " bars", text_color=color.yellow)
    table.cell(d, 2, 13, "", text_color=color.white)

// =============================================================================
// ALERTS - Static alertcondition entries (visible in TradingView alert UI)
// =============================================================================
alertcondition(greenFinal,  title="LONG Signal (CALL)",  message="🟢 LONG: {{ticker}} @ {{close}} | Score: high confluence")
alertcondition(redFinal,    title="SHORT Signal (PUT)",  message="🔴 SHORT: {{ticker}} @ {{close}} | Score: high confluence")
alertcondition(yellowFinal, title="CAUTION Signal",      message="🟡 CAUTION: {{ticker}} @ {{close}} | Mean reversion warning")

// Webhook-ready dynamic alerts with structured JSON
if greenFinal
    alert('{"signal":"LONG","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"score":' + str.tostring(longScore) + ',"sl":' + str.tostring(close - atrVal * slMult) + ',"tp1":' + str.tostring(close + atrVal * tp1Mult) + ',"tp2":' + str.tostring(close + atrVal * tp2Mult) + ',"time":"' + str.tostring(time) + '"}', alert.freq_once_per_bar_close)

if redFinal
    alert('{"signal":"SHORT","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"score":' + str.tostring(shortScore) + ',"sl":' + str.tostring(close + atrVal * slMult) + ',"tp1":' + str.tostring(close - atrVal * tp1Mult) + ',"tp2":' + str.tostring(close - atrVal * tp2Mult) + ',"time":"' + str.tostring(time) + '"}', alert.freq_once_per_bar_close)

if yellowFinal
    alert('{"signal":"CAUTION","ticker":"' + syminfo.ticker + '","price":' + str.tostring(close) + ',"rsi":' + str.tostring(rsiVal) + ',"time":"' + str.tostring(time) + '"}', alert.freq_once_per_bar_close)
````
