# BB RSI Scalping + Trend Mode Auto-Switch

- url: https://www.tradingview.com/script/mDqeNOGD-BB-RSI-Scalping-Trend-Mode-Auto-Switch/
- type: indicator
- pine_id: PUB;e93ebb001fe44adf95d7b5255fb5893d
- version: 1.0

## Description

# BB RSI Scalping + Trend Mode Auto-Switch

## Overview

This is a **multi-mode scalping indicator** for TradingView that combines Bollinger Bands mean reversion with intelligent trend detection. It automatically switches between two trading modes based on market conditions.

---

## Two Trading Modes

### 1. BB Mean Reversion Mode (Default when ranging)
- **Best for:** Ranging or choppy markets
- **Strategy:** Fade extremes—buy near the lower Bollinger Band, sell near the upper band
- **Entry Types:**
  - **Reversal** — Counter-trend trades at band extremes with RSI/MACD/volume confirmation
  - **Continuation** — Trades that continue toward the middle band (basis)
- **Exit Logic:** Based on momentum (MACD histogram inflection, MACD crosses, RSI 50 cross)

### 2. Trend Following Mode (When strong trend detected)
- **Best for:** Trending markets with clear direction
- **Strategy:** Trade with momentum on pullbacks during established trends
- **Entry Trigger:** ADX above threshold (default: 20) with +DI/-DI confirming direction
- **Exit Logic:** Exits when trend weakens (ADX drops 5+ from entry) or reverses

---

## Key Features

| Feature | Description |
|---------|-------------|
| **Auto Mode Switching** | Automatically detects trend vs. ranging and switches strategies |
| **Trend Detection** | Uses ADX + DI (Directional Index) to identify trend strength & direction |
| **Entry Modes** | Conservative (all confirmations), Balanced, or Aggressive |
| **Continuation Trading** | Midline Bollinger Band continuation trades when momentum aligns |
| **Dynamic Exits** | Stop levels that trail and adjust with price action |
| **Visual Labels** | Entry, HOLD, EXIT SOON, and warning labels on chart |
| **Mode Display Table** | Shows current mode, ADX level, trend direction, and strength |
| **Trade History** | Tracks recent trades with entry/exit prices, P&L, and results |
| **Webhook Alerts** | Sends JSON alerts for Google Sheets integration |

---

## How the Mode Display Table Works

The table in the **upper left corner** shows at a glance what's happening:

| Row | What It Shows | Example |
|-----|---------------|---------|
| **MODE** | Current strategy | `TREND FOLLOWING` or `BB MEAN REVERSION` |
| **ADX** | Trend strength (0-100) | `28.5` (color-coded: green ≥30, yellow 20-30, red <20) |
| **TREND** | Direction | `↑ BULL`, `↓ BEAR`, or `— RANGE` |
| **STRENGTH** | Classification | `STRONG`, `MODERATE`, or `WEAK/NONE` |

---

## Decision Flow

```
ADX < 20 (Weak/None)
        ↓
   BB MEAN REVERSION MODE
   - Buy at lower band
   - Sell at upper band
   - Exit on momentum

ADX > 20 (Trending)
        ↓
   TREND FOLLOWING MODE
   - Buy pullbacks in uptrend
   - Sell rallies in downtrend
   - Exit when trend weakens
```

---

## Entry Signal Types

| Label | Meaning |
|-------|---------|
| `REVERSAL` | Counter-trend trade at Bollinger Band extremes |
| `CONTINUATION` | Trade along the middle band with momentum |
| `TREND LONG/SHORT` | Pullback entry during established trend |

---

## Visual Elements on Chart

| Element | Description |
|---------|-------------|
| **BUY/SELL Labels** | Entry points with price, invalidation, and dynamic exit levels |
| **HOLD Labels** | Shows current target, stop, and any warnings |
| **EXIT SOON Labels** | Alerts when momentum is weakening |
| **TREND LONG/SHORT NEAR** | Warnings when trend setup is building |
| **Dotted Lines** | Dynamic exit levels, trailing stops, break-even |
| **Solid Lines** | Entry price, Bollinger Bands |

---

## Use Cases

| Market Condition | Mode Active | What to Watch For |
|------------------|-------------|-------------------|
| Ranging/Sideways | BB MEAN REVERSION | Reversal trades at bands, continuation trades at midline |
| Strong Uptrend | TREND FOLLOWING | Pullback entries to buy, exit when ADX drops |
| Strong Downtrend | TREND FOLLOWING | Rally entries to short, exit when trend reverses |
| Choppy/Weak | BB MEAN REVERSION | Conservative entries with all confirmations |

---

## Customization Options

- **Entry Mode:** Conservative, Balanced, or Aggressive
- **ADX Threshold:** When to switch to trend mode (default: 20)
- **Strong Trend Level:** When to consider trend "strong" (default: 30)
- **Trailing/Break-Even Stops:** ATR-based management
- **Take Profit Levels:** Multiple TP levels with partial exits
- **Session Filter:** Trade only during certain hours
- **Max Holding Time:** Auto-exit after X minutes

## Source Code

````pine
//@version=6
// ============================================================================
// SCRIPT PURPOSE
// ============================================================================
// This indicator is a Bollinger Band + RSI + MACD + Volume scalping tool with
// intelligent trend detection and auto-switching between BB mean reversion and
// trend following modes.
//
// BB Mean Reversion Mode (default when ranging):
// - Reversal trades near the outer Bollinger Bands
// - Continuation trades around the Bollinger Band midline/basis
// - Exits based on momentum weakness, retracement, invalidation
//
// Trend Following Mode (when strong trend detected):
// - Trend entries on pullbacks during established trends
// - Uses ADX + DI for trend direction and strength
// - Trailing stops for trend management
// - Mode auto-switches based on ADX threshold
//
// This is an indicator, not a TradingView strategy.
// It creates visual trade labels, dynamic exit lines, alert events, and tables.

// ============================================================================
// STRATEGY OVERVIEW
// ============================================================================
// Reversal Long (BB Mode):
// - Price is near or outside the lower Bollinger Band
// - RSI is weak/oversold relative to the dynamic RSI threshold
// - Candle/MACD/volume confirmation depends on Entry Mode
//
// Trend Long (Trend Mode):
// - ADX above threshold indicating strong trend
// - +DI > -DI for uptrend confirmation
// - Price pulling back toward middle band or trend support
// - RSI confirming momentum
//
// Trend Short (Trend Mode):
// - ADX above threshold indicating strong trend
// - -DI > +DI for downtrend confirmation
// - Price rejected at upper band or trend resistance
//
// Exit Logic:
// - Reversal and continuation trades have separate exit rules
// - Trend trades use trailing stops and trend invalidation
// - Exits may come from MACD weakness, ADX drop, trend invalidation

// ============================================================================
// GOOGLE SHEET / WEBHOOK PURPOSE
// ============================================================================
// The Google Sheet logging captures TradingView alert events in real time.
// Current base behavior:
// - Entry labels are created on the chart
// - Closed trade / exit alerts sent through TradingView webhooks
// - Google Apps Script receives webhook JSON and appends to Google Sheet
//
// Intended logged fields:
// - tradeId, receivedTime, eventTime, event, ticker, timeframe
// - side, type, entryPrice, exitPrice, move, heldBars, reason, result
//
// One trade = one entry log + one exit log

// ============================================================================
// NEW FEATURES IN THIS VERSION
// ============================================================================
// 1. Trend Detection System - ADX/DI based trend identification
// 2. Auto Mode Switching - Switches between BB and Trend modes automatically
// 3. Trend Following Entries - Pullback entries during strong trends
// 4. ADX-Based Exit Logic - Exit when trend weakens
// 5. Trend Warning Labels - Alerts when trend is building
// 6. Mode Indicator Display - Shows current mode (BB REVERSION / TREND FOLLOWING)
// 7. Trend Strength Visualization - ADX level indicator
// 8. Preserved Existing Features - All original BB/RSI/MACD logic intact

indicator("BB RSI Scalping + Trend Mode Auto-Switch", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================================
// SECTION: INPUTS - TREND SETTINGS (NEW)
// ============================================================================

// --- Trend Mode Settings ---
enableTrendMode = input.bool(true, "Enable Trend Following Mode")
adxLength = input.int(14, "ADX Length", minval=1)
adxThreshold = input.float(20.0, "ADX Trend Threshold", minval=10.0, maxval=40.0, step=1.0)
strongTrendThreshold = input.float(30.0, "Strong Trend ADX Level", minval=20.0, maxval=50.0, step=1.0)

// --- Trend Entry Settings ---
trendEntryLookback = input.int(3, "Trend Pullback Lookback Bars", minval=1, maxval=10)
trendRsiThreshold = input.float(45.0, "Trend Entry Max RSI (Long)", minval=30.0, maxval=60.0)
trendRsiThresholdShort = input.float(55.0, "Trend Entry Min RSI (Short)", minval=40.0, maxval=70.0)
requireTrendConfirmation = input.bool(true, "Require Trend Confirmation for Entries")

// --- Trend Warning Settings ---
showTrendWarnings = input.bool(true, "Show Trend Setup Warnings")
trendWarningCooldown = input.int(10, "Trend Warning Cooldown Bars", minval=1)

// --- Mode Display Settings ---
showModeDisplay = input.bool(true, "Show Current Mode Indicator")
modeDisplayPosition = input.string("Top Right", "Mode Display Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

// ============================================================================
// SECTION: INPUTS - EXISTING BB SETTINGS
// ============================================================================

// --- Bollinger Band Inputs ---
bbLength = input.int(20, "BB Length", minval=1)
bbMult = input.float(2.0, "BB Multiplier", minval=0.1)

// --- RSI Inputs ---
rsiLength = input.int(14, "RSI Length", minval=1)
dynamicRsiLen = input.int(20, "Dynamic RSI Lookback", minval=5)
dynamicRsiBuffer = input.float(5.0, "Dynamic RSI Buffer", minval=0.0, step=0.5)
nearRsiBuffer = input.float(8.0, "Near Entry RSI Buffer", minval=0.0, step=0.5)

// --- Entry Mode Inputs ---
entryModeInput = input.string("Auto", "Entry Mode", options=["Auto", "Conservative", "Balanced", "Aggressive"])
enableContinuationMode = input.bool(true, "Enable BB Midline Continuation Mode")

// --- Continuation Warning Inputs ---
showContinuationWarnings = input.bool(true, "Show Continuation Almost Ready Warnings")
continuationWarningScore = input.int(5, "Continuation Warning Score Needed", minval=3, maxval=7)
continuationWarningCooldownBars = input.int(5, "Continuation Warning Cooldown Bars", minval=1)

// --- Auto Mode Inputs ---
autoBbWidthLen = input.int(20, "Auto Mode BB Width Lookback", minval=5)
autoAtrLen = input.int(14, "Auto Mode ATR Length", minval=1)
autoHighVolMult = input.float(1.15, "Auto Mode High Volume Multiplier", minval=0.1, step=0.05)

// --- MACD Inputs ---
macdFastLen = input.int(12, "MACD Fast Length", minval=1)
macdSlowLen = input.int(26, "MACD Slow Length", minval=1)
macdSignalLen = input.int(9, "MACD Signal Length", minval=1)
confirmationWindow = input.int(5, "MACD / Volume Recent Window", minval=0)

// --- Volume Inputs ---
volLength = input.int(20, "Volume SMA Length", minval=1)
volMult = input.float(1.1, "Volume Multiplier", minval=0.1, step=0.1)
requireVolumeIncreasing = input.bool(false, "Require Volume Increasing")

// --- Divergence Inputs ---
pivotLen = input.int(2, "Divergence Pivot Lookback", minval=1)
maxDivBars = input.int(50, "Max Bars Between Divergence Pivots", minval=5)

// --- Band Zone Inputs ---
nearEntryBandPct = input.float(12.0, "Near Band % Of BB Width", minval=1.0, maxval=50.0)
headsUpCooldownBars = input.int(5, "Heads-Up Repeat Cooldown Bars", minval=1)

// --- Entry/Exit Price Mode Inputs ---
entryPriceMode = input.string("Candle Extreme", "Estimated Entry Price", options=["Candle Extreme", "Bollinger Band", "Close"])
exitPriceMode = input.string("Candle Extreme", "Estimated Exit Price", options=["Candle Extreme", "Close"])

// --- Invalidation Inputs ---
initialInvalidLookback = input.int(2, "Initial Invalidation Lookback Bars", minval=1)
dynamicExitLookback = input.int(2, "Dynamic Exit Lookback Bars", minval=1)
invalidationTickBuffer = input.int(2, "Invalidation Tick Buffer", minval=0)
useDynamicExitInvalid = input.bool(true, "Use Dynamic Invalid As Exit While Holding")

// --- Exit Mode Inputs ---
reversalExitMode = input.string("Retrace + MACD Weakness", "REVERSAL Exit Mode", options=["Momentum Reversal", "First Retrace", "Retrace + MACD Weakness"])
continuationExitMode = input.string("Basis Break + MACD Weakness", "CONTINUATION Exit Mode", options=["Momentum Reversal", "Basis Break + MACD Weakness", "MACD Cross Only"])

// --- Momentum Exit Inputs ---
useMacdCrossExit = input.bool(true, "Momentum Exit: MACD Cross")
useHistInflectionExit = input.bool(true, "Momentum Exit: MACD Histogram Inflection")
useRsi50Exit = input.bool(false, "Momentum Exit: RSI 50 Cross")

// --- ATR-Based Stop Inputs ---
atrLength = input.int(14, "ATR Length for Stops", minval=1)
useTrailingStop = input.bool(false, "Enable ATR Trailing Stop")
trailingAtrMult = input.float(2.0, "Trailing Stop ATR Multiplier", minval=0.5, step=0.5)
trailingStartAtr = input.float(1.5, "Trailing Start ATR From Entry", minval=0.5, step=0.5)

useBreakEvenStop = input.bool(false, "Enable Break-Even Stop")
breakEvenAtrMult = input.float(1.0, "Break-Even ATR Move From Entry", minval=0.5, step=0.5)

// --- Take Profit Inputs ---
useTakeProfit = input.bool(false, "Enable ATR-Based Take Profit")
tp1AtrMult = input.float(1.0, "TP1 ATR Multiplier", minval=0.5, step=0.25)
tp1ExitPct = input.int(33, "TP1 Exit Percentage", minval=10, maxval=90)
tp2AtrMult = input.float(2.0, "TP2 ATR Multiplier", minval=0.5, step=0.25)
tp2ExitPct = input.int(33, "TP2 Exit Percentage", minval=10, maxval=90)
tp3AtrMult = input.float(3.0, "TP3 ATR Multiplier", minval=0.5, step=0.25)

// --- Session Filter Inputs ---
useSessionFilter = input.bool(false, "Enable Session Filter")
sessionInput = input.session("0930-1600:23456", "Trading Session", tooltip="Format: HHMM-HHMM:DDDDD (1=Sun, 7=Sat)")

// --- Max Holding Time Inputs ---
useMaxHoldingTime = input.bool(false, "Enable Max Holding Time")
maxHoldingMinutes = input.int(60, "Max Holding Time (Minutes)", minval=5, maxval=480, step=5)

// --- Visual Inputs ---
showBB = input.bool(true, "Show Bollinger Bands")
showLimitHeadsUp = input.bool(true, "Show Latest Limit Heads-Up Only")
showHoldLabel = input.bool(true, "Show Latest HOLD Label")
showExitSoon = input.bool(true, "Show Latest EXIT SOON Label")
showInvalidationLine = input.bool(true, "Show Dynamic Exit Line")
showTpLevels = input.bool(true, "Show TP Level Lines")
showEntryPriceLine = input.bool(true, "Show Entry Price Line")
entryLineColor = input.color(color.gray, "Entry Price Line Color")

// --- Real-Time Trade Info Table ---
showRealTimeTradeTable = input.bool(true, "Show Real-Time Trade Info Table")

// --- Table & Webhook Inputs ---
showTradeTable = input.bool(true, "Show Trade History Table")
tableRows = input.int(10, "Trade History Rows", minval=3, maxval=20)
sendWebhookAlerts = input.bool(true, "Send Webhook Alerts On Closed Trades")
showEnhancedStats = input.bool(true, "Show Enhanced Statistics")

// --- Color Inputs ---
bullColor = input.color(#089981, "Bull Color")
bearColor = input.color(#f23645, "Bear Color")
conservativeColor = input.color(color.yellow, "Conservative Entry Color")
balancedColor = input.color(color.lime, "Balanced Entry Color")
aggressiveColor = input.color(color.aqua, "Aggressive Entry Color")
continuationColor = input.color(color.fuchsia, "Midline Continuation Color")
warningColor = input.color(color.new(color.fuchsia, 15), "Continuation Warning Color")
exitColor = input.color(color.orange, "Exit Color")
invalidColor = input.color(color.red, "Initial Invalid Color")
dynamicExitColor = input.color(color.purple, "Dynamic Exit Color")
holdColor = input.color(color.blue, "Hold Label Color")
headsUpColor = input.color(color.aqua, "Heads-Up Color")
trailingColor = input.color(color.teal, "Trailing Stop Color")
breakEvenColor = input.color(color.green, "Break-Even Color")
tpColor = input.color(color.yellow, "Take Profit Color")

// Trend Mode Colors (NEW)
trendModeColor = input.color(color.orange, "Trend Mode Color")
trendWarningColor = input.color(color.new(color.orange, 20), "Trend Warning Color")
trendLongColor = input.color(color.lime, "Trend Long Color")
trendShortColor = input.color(color.red, "Trend Short Color")
modeBgColor = input.color(color.new(color.gray, 85), "Mode Display Background")

// ============================================================================
// SECTION: POSITION STATE VARIABLES
// ============================================================================

// --- Position State Variables ---
var bool inLong = false
var bool inShort = false
var bool longSignal = false
var bool shortSignal = false

// --- Trade ID Variables ---
var string activeTradeId = ""

// --- TP Level Variables ---
var float tp1Price = na
var float tp2Price = na
var float tp3Price = na
var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false

// --- Trailing Stop Variables ---
var float trailingStopPrice = na
var bool trailingActivated = false

// --- Break-Even Stop Variables ---
var float breakEvenPrice = na
var bool breakEvenActivated = false

// --- Max Holding Time Variables ---
var int maxExitTime = na

// --- Entry Price Line Variables ---
var line entryPriceLine = na
var int entryLineBar = na

// --- Real-Time Trade Info Table ---
var table realTimeTradeInfoTable = na

// --- Label References ---
var label activeEntryLabel = na
var label lastHoldLabel = na
var label lastExitSoonLabel = na
var label lastNearLongLabel = na
var label lastNearShortLabel = na
var label lastContinuationLongWarningLabel = na
var label lastContinuationShortWarningLabel = na
var line invalidLine = na
var label invalidLabel = na
var line trailingLine = na
var line breakEvenLine = na
var line tp1Line = na
var line tp2Line = na
var line tp3Line = na

// --- Mode Display Table (NEW) ---
var table modeDisplayTable = na

// --- Trend Warning Labels (NEW) ---
var label lastTrendLongWarningLabel = na
var label lastTrendShortWarningLabel = na
var int lastTrendLongWarningBar = na
var int lastTrendShortWarningBar = na

// ============================================================================
// SECTION: CALCULATIONS - TREND (NEW)
// ============================================================================

// --- ADX and DI Calculations ---
[diPlus, diMinus, adxValue] = ta.dmi(adxLength, adxLength)

// --- Trend Detection ---
isTrending = adxValue >= adxThreshold
isStrongTrend = adxValue >= strongTrendThreshold

// Trend direction: +1 = bullish, -1 = bearish, 0 = ranging
trendDirection = diPlus > diMinus ? 1 : diMinus > diPlus ? -1 : 0

// Determine current mode (BB Reversion vs Trend Following)
currentMode = enableTrendMode and isTrending ? "TREND FOLLOWING" : "BB MEAN REVERSION"

// Trend strength classification
trendStrength =
     adxValue < adxThreshold ? "WEAK/NONE" :
     adxValue < strongTrendThreshold ? "MODERATE" :
     "STRONG"

// Trend entry conditions
trendUptrend = trendDirection == 1 and isTrending
trendDowntrend = trendDirection == -1 and isTrending

// ============================================================================
// SECTION: CALCULATIONS - EXISTING
// ============================================================================

// --- ATR Calculation ---
atrValue = ta.atr(atrLength)

// --- Bollinger Bands ---
basis = ta.sma(close, bbLength)
dev = ta.stdev(close, bbLength) * bbMult
upper = basis + dev
lower = basis - dev
bbWidth = upper - lower
bbWidthAvg = ta.sma(bbWidth, autoBbWidthLen)
bbExpanding = bbWidth > bbWidthAvg

// --- RSI Calculations ---
rsi = ta.rsi(close, rsiLength)
dynamicRsiOS = ta.lowest(rsi, dynamicRsiLen) + dynamicRsiBuffer
dynamicRsiOB = ta.highest(rsi, dynamicRsiLen) - dynamicRsiBuffer

// --- MACD Calculations ---
[macdLine, signalLine, hist] = ta.macd(close, macdFastLen, macdSlowLen, macdSignalLen)

macdBullInflection = hist > hist[1] and hist[1] < hist[2]
macdBearInflection = hist < hist[1] and hist[1] > hist[2]

macdBullCross = ta.crossover(macdLine, signalLine)
macdBearCross = ta.crossunder(macdLine, signalLine)

macdBullRecent = ta.barssince(macdBullInflection) <= confirmationWindow
macdBearRecent = ta.barssince(macdBearInflection) <= confirmationWindow

// --- RSI Cross Calculations ---
rsiCrossDown50 = ta.crossunder(rsi, 50)
rsiCrossUp50 = ta.crossover(rsi, 50)

// --- Volume Calculations ---
volMA = ta.sma(volume, volLength)
volumeStrong = volume > volMA * volMult
volumeAutoStrong = volume > volMA * autoHighVolMult
volumeOK = requireVolumeIncreasing ? volumeStrong and volume > volume[1] : volumeStrong
volumeRecent = ta.barssince(volumeOK) <= confirmationWindow
volRatio = volMA != 0 ? volume / volMA : na

// --- Auto Mode ---
atrAvg = ta.sma(atrValue, autoAtrLen)
volatilityExpanding = atrValue > atrAvg

autoAggressive = bbExpanding and volatilityExpanding and volumeAutoStrong
autoConservative = not bbExpanding and not volumeAutoStrong

effectiveMode =
     entryModeInput != "Auto" ? entryModeInput :
     autoAggressive ? "Aggressive" :
     autoConservative ? "Conservative" :
     "Balanced"

// --- Divergence Calculations ---
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)
pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)

var float prevLowPrice = na
var float prevLowRsi = na
var int prevLowBar = na

var float prevHighPrice = na
var float prevHighRsi = na
var int prevHighBar = na

bullDivConfirmed = false
bearDivConfirmed = false

if not na(pivotLow)
    currLowPrice = low[pivotLen]
    currLowRsi = rsi[pivotLen]
    currLowBar = bar_index - pivotLen
    bullDivConfirmed := not na(prevLowPrice) and currLowPrice < prevLowPrice and currLowRsi > prevLowRsi and currLowBar - prevLowBar <= maxDivBars
    prevLowPrice := currLowPrice
    prevLowRsi := currLowRsi
    prevLowBar := currLowBar

if not na(pivotHigh)
    currHighPrice = high[pivotLen]
    currHighRsi = rsi[pivotLen]
    currHighBar = bar_index - pivotLen
    bearDivConfirmed := not na(prevHighPrice) and currHighPrice > prevHighPrice and currHighRsi < prevHighRsi and currHighBar - prevHighBar <= maxDivBars
    prevHighPrice := currHighPrice
    prevHighRsi := currHighRsi
    prevHighBar := currHighBar

// --- Session Check ---
inSession = useSessionFilter ? not na(time(timeframe.period, sessionInput)) : true

// ============================================================================
// SECTION: ENTRY SIGNALS - BB MODE
// ============================================================================

// --- Entry Prices ---
longEntryPrice =
     entryPriceMode == "Candle Extreme" ? low :
     entryPriceMode == "Bollinger Band" ? lower :
     close

shortEntryPrice =
     entryPriceMode == "Candle Extreme" ? high :
     entryPriceMode == "Bollinger Band" ? upper :
     close

// --- Invalidation Prices ---
tickBuffer = syminfo.mintick * invalidationTickBuffer

newInitialLongInvalid = ta.lowest(low, initialInvalidLookback) - tickBuffer
newInitialShortInvalid = ta.highest(high, initialInvalidLookback) + tickBuffer

newDynamicLongExit = ta.lowest(low, dynamicExitLookback) - tickBuffer
newDynamicShortExit = ta.highest(high, dynamicExitLookback) + tickBuffer

// --- BB Zones ---
outsideLower = low < lower
outsideUpper = high > upper

nearLowerBand = low <= lower + bbWidth * nearEntryBandPct / 100
nearUpperBand = high >= upper - bbWidth * nearEntryBandPct / 100

greenCandle = close > open
redCandle = close < open

longBetterClose = close > close[1]
shortBetterClose = close < close[1]

longReversalCandle = close > lower and longBetterClose
shortReversalCandle = close < upper and shortBetterClose

// --- Conservative Signals ---
conservativeLongSignal =
     outsideLower and
     rsi <= dynamicRsiOS and
     macdBullRecent and
     volumeRecent and
     longReversalCandle

conservativeShortSignal =
     outsideUpper and
     rsi >= dynamicRsiOB and
     macdBearRecent and
     volumeRecent and
     shortReversalCandle

// --- Divergence Signals ---
longDivSignal =
     bullDivConfirmed and
     low[pivotLen] < lower[pivotLen] and
     rsi[pivotLen] <= dynamicRsiOS[pivotLen] and
     macdBullRecent and
     volumeRecent

shortDivSignal =
     bearDivConfirmed and
     high[pivotLen] > upper[pivotLen] and
     rsi[pivotLen] >= dynamicRsiOB[pivotLen] and
     macdBearRecent and
     volumeRecent

// --- Balanced Signals ---
balancedLongSignal =
     nearLowerBand and
     rsi <= dynamicRsiOS + nearRsiBuffer and
     greenCandle

balancedShortSignal =
     nearUpperBand and
     rsi >= dynamicRsiOB - nearRsiBuffer and
     redCandle

// --- Aggressive Signals ---
aggressiveLongSignal =
     nearLowerBand and
     rsi <= dynamicRsiOS + nearRsiBuffer

aggressiveShortSignal =
     nearUpperBand and
     rsi >= dynamicRsiOB - nearRsiBuffer

// --- BB Midline Continuation Signals ---
midlineLongSignal =
     enableContinuationMode and
     low <= basis and
     close > basis and
     greenCandle and
     rsi > 50 and
     hist > hist[1] and
     macdLine >= signalLine and
     volumeRecent

midlineShortSignal =
     enableContinuationMode and
     high >= basis and
     close < basis and
     redCandle and
     rsi < 50 and
     hist < hist[1] and
     macdLine <= signalLine and
     volumeRecent

// --- Continuation Warning Score ---
continuationLongScore =
     (low <= basis ? 1 : 0) +
     (close > basis ? 1 : 0) +
     (greenCandle ? 1 : 0) +
     (rsi > 50 ? 1 : 0) +
     (hist > hist[1] ? 1 : 0) +
     (macdLine >= signalLine ? 1 : 0) +
     (volumeRecent ? 1 : 0)

continuationShortScore =
     (high >= basis ? 1 : 0) +
     (close < basis ? 1 : 0) +
     (redCandle ? 1 : 0) +
     (rsi < 50 ? 1 : 0) +
     (hist < hist[1] ? 1 : 0) +
     (macdLine <= signalLine ? 1 : 0) +
     (volumeRecent ? 1 : 0)

// --- Final Reversal Signals ---
reversalLongSignal =
     (effectiveMode == "Conservative" and (conservativeLongSignal or longDivSignal)) or
     (effectiveMode == "Balanced" and balancedLongSignal) or
     (effectiveMode == "Aggressive" and aggressiveLongSignal)

reversalShortSignal =
     (effectiveMode == "Conservative" and (conservativeShortSignal or shortDivSignal)) or
     (effectiveMode == "Balanced" and balancedShortSignal) or
     (effectiveMode == "Aggressive" and aggressiveShortSignal)

// ============================================================================
// SECTION: ENTRY SIGNALS - TREND MODE (NEW)
// ============================================================================

// --- Trend Pullback Detection ---
// For trend long: price pulled back from recent high, testing middle band or lower
trendLongPullback =
     trendUptrend and
     rsi <= trendRsiThreshold and
     rsi >= 30 and  // Not oversold, just pulling back
     close >= basis - bbWidth * 0.25 and  // Near middle band area
     greenCandle and
     macdBullInflection

// For trend short: price rallied from recent low, testing middle band or upper
trendShortPullback =
     trendDowntrend and
     rsi >= trendRsiThresholdShort and
     rsi <= 70 and  // Not overbought, just pulling back
     close <= basis + bbWidth * 0.25 and  // Near middle band area
     redCandle and
     macdBearInflection

// Trend confirmation signals (more strict entry)
trendLongConfirmed =
     trendLongPullback and
     requireTrendConfirmation ? (macdBullRecent and volumeRecent) : true

trendShortConfirmed =
     trendShortPullback and
     requireTrendConfirmation ? (macdBearRecent and volumeRecent) : true

// --- Trend Warning Detection (for pre-setup alerts) ---
trendLongWarningNow =
     showTrendWarnings and
     enableTrendMode and
     not inLong and not inShort and
     trendUptrend and
     not trendLongConfirmed and
     rsi <= trendRsiThreshold and
     (na(lastTrendLongWarningBar) or bar_index - lastTrendLongWarningBar >= trendWarningCooldown)

trendShortWarningNow =
     showTrendWarnings and
     enableTrendMode and
     not inLong and not inShort and
     trendDowntrend and
     not trendShortConfirmed and
     rsi >= trendRsiThresholdShort and
     (na(lastTrendShortWarningBar) or bar_index - lastTrendShortWarningBar >= trendWarningCooldown)

// ============================================================================
// SECTION: COMBINED ENTRY SIGNALS
// ============================================================================

// --- Combined Entry Signals ---
// In BB Mode: use reversal and continuation signals
// In Trend Mode: use trend following signals, fall back to BB signals if no trend setup

bbLongSignal = reversalLongSignal or midlineLongSignal
bbShortSignal = reversalShortSignal or midlineShortSignal

longSignal :=
     not inLong and not inShort and
     inSession and
     (
         // If in trend mode and trending, prioritize trend entries
         (enableTrendMode and isTrending and trendLongConfirmed) or
         // Otherwise use BB mode signals (if not strong trend)
         (not enableTrendMode or not isStrongTrend and bbLongSignal)
     )

shortSignal :=
     not inLong and not inShort and
     inSession and
     (
         // If in trend mode and trending, prioritize trend entries
         (enableTrendMode and isTrending and trendShortConfirmed) or
         // Otherwise use BB mode signals (if not strong trend)
         (not enableTrendMode or not isStrongTrend and bbShortSignal)
     )

// --- Trade Type & Signal Labels ---
longTradeType = 
     (enableTrendMode and isTrending and trendLongConfirmed) ? "TREND LONG" :
     midlineLongSignal ? "CONTINUATION" :
     "REVERSAL"

shortTradeType =
     (enableTrendMode and isTrending and trendShortConfirmed) ? "TREND SHORT" :
     midlineShortSignal ? "CONTINUATION" :
     "REVERSAL"

longSignalType =
     (enableTrendMode and isTrending and trendLongConfirmed) ? "TREND FOLLOWING\nADX + Pullback" :
     midlineLongSignal ? "MIDLINE CONTINUATION" :
     effectiveMode == "Conservative" ? "AUTO CONSERVATIVE\nBB + RSI + MACD + VOL" :
     effectiveMode == "Balanced" ? "AUTO BALANCED\nBB + RSI + REVERSAL" :
     "AUTO AGGRESSIVE\nBB + RSI"

shortSignalType =
     (enableTrendMode and isTrending and trendShortConfirmed) ? "TREND FOLLOWING\nADX + Pullback" :
     midlineShortSignal ? "MIDLINE CONTINUATION" :
     effectiveMode == "Conservative" ? "AUTO CONSERVATIVE\nBB + RSI + MACD + VOL" :
     effectiveMode == "Balanced" ? "AUTO BALANCED\nBB + RSI + REVERSAL" :
     "AUTO AGGRESSIVE\nBB + RSI"

entryLabelColor =
     (enableTrendMode and isTrending and (trendLongConfirmed or trendShortConfirmed)) ? trendModeColor :
     midlineLongSignal or midlineShortSignal ? continuationColor :
     effectiveMode == "Conservative" ? conservativeColor :
     effectiveMode == "Balanced" ? balancedColor :
     aggressiveColor

// ============================================================================
// SECTION: TRADE MANAGEMENT STATE
// ============================================================================

// --- Position State Variables (additional) ---
var float activeEntryPrice = na
var float initialInvalidPrice = na
var float dynamicExitPrice = na
var int activeSide = 0
var int activeEntryBar = na
var int activeEntryTime = na
var string activeTradeType = ""

var int tradeIdCounter = 0

// --- Trend-specific tracking (NEW) ---
var float trendEntryAdx = na  // ADX at entry for trend exits

// ============================================================================
// SECTION: TRADE HISTORY ARRAYS
// ============================================================================

var array<string> histSide = array.new_string()
var array<string> histType = array.new_string()
var array<string> histTradeId = array.new_string()
var array<string> histEntryTime = array.new_string()
var array<string> histExitTime = array.new_string()
var array<string> histEntry = array.new_string()
var array<string> histExit = array.new_string()
var array<string> histMove = array.new_string()
var array<string> histHeld = array.new_string()
var array<string> histReason = array.new_string()
var array<string> histResult = array.new_string()
var array<string> histTpHits = array.new_string()

// ============================================================================
// SECTION: TRADE HISTORY FUNCTIONS
// ============================================================================

addTrade(_side, _type, _tradeId, _entryTime, _exitTime, _entry, _exit, _move, _held, _reason, _tpHits) =>
    array.unshift(histSide, _side)
    array.unshift(histType, _type)
    array.unshift(histTradeId, _tradeId)
    array.unshift(histEntryTime, _entryTime)
    array.unshift(histExitTime, _exitTime)
    array.unshift(histEntry, _entry)
    array.unshift(histExit, _exit)
    array.unshift(histMove, _move)
    array.unshift(histHeld, _held)
    array.unshift(histReason, _reason)
    array.unshift(histResult, str.tonumber(_move) >= 0 ? "WIN" : "LOSS")
    array.unshift(histTpHits, _tpHits)
    
    if array.size(histSide) > tableRows
        array.pop(histSide)
        array.pop(histType)
        array.pop(histTradeId)
        array.pop(histEntryTime)
        array.pop(histExitTime)
        array.pop(histEntry)
        array.pop(histExit)
        array.pop(histMove)
        array.pop(histHeld)
        array.pop(histReason)
        array.pop(histResult)
        array.pop(histTpHits)

// ============================================================================
// SECTION: NEAR ENTRY HEAD SUP LABELS
// ============================================================================

nearLong =
     showLimitHeadsUp and
     nearLowerBand and
     rsi <= dynamicRsiOS + nearRsiBuffer and
     not inLong and
     not inShort

nearShort =
     showLimitHeadsUp and
     nearUpperBand and
     rsi >= dynamicRsiOB - nearRsiBuffer and
     not inLong and
     not inShort

var int lastNearLongBar = na
var int lastNearShortBar = na
var int lastContinuationLongWarningBar = na
var int lastContinuationShortWarningBar = na

nearLongNow = nearLong and (na(lastNearLongBar) or bar_index - lastNearLongBar >= headsUpCooldownBars)
nearShortNow = nearShort and (na(lastNearShortBar) or bar_index - lastNearShortBar >= headsUpCooldownBars)

continuationLongWarningNow =
     showContinuationWarnings and
     enableContinuationMode and
     not inLong and not inShort and
     not midlineLongSignal and
     continuationLongScore >= continuationWarningScore and
     (na(lastContinuationLongWarningBar) or bar_index - lastContinuationLongWarningBar >= continuationWarningCooldownBars)

continuationShortWarningNow =
     showContinuationWarnings and
     enableContinuationMode and
     not inLong and not inShort and
     not midlineShortSignal and
     continuationShortScore >= continuationWarningScore and
     (na(lastContinuationShortWarningBar) or bar_index - lastContinuationShortWarningBar >= continuationWarningCooldownBars)

// ============================================================================
// SECTION: GENERATE TRADE ID
// ============================================================================

generateTradeId() =>
    tickerLen = str.length(syminfo.tickerid)
    tickerHash = int(tickerLen * 1000 + bar_index % 1000)
    tradeId = "T" + str.tostring(bar_index) + "_" + str.tostring(tickerHash)
    tradeId

// ============================================================================
// SECTION: LONG ENTRY
// ============================================================================

if longSignal
    inLong := true
    inShort := false
    activeEntryPrice := longEntryPrice
    initialInvalidPrice := newInitialLongInvalid
    dynamicExitPrice := newDynamicLongExit
    activeSide := 1
    activeEntryBar := bar_index
    activeEntryTime := time
    activeTradeType := longTradeType
    activeTradeId := generateTradeId()
    
    // Store ADX at entry for trend exits (NEW)
    trendEntryAdx := adxValue
    
    // Reset TP levels
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    tp1Price := na
    tp2Price := na
    tp3Price := na
    
    // Calculate TP levels if enabled
    if useTakeProfit
        tp1Price := activeEntryPrice + atrValue * tp1AtrMult
        tp2Price := activeEntryPrice + atrValue * tp2AtrMult
        tp3Price := activeEntryPrice + atrValue * tp3AtrMult
    
    // Initialize trailing stop
    trailingActivated := false
    trailingStopPrice := na
    
    // Initialize break-even stop
    breakEvenActivated := false
    breakEvenPrice := na
    
    // Set max holding time
    if useMaxHoldingTime
        maxExitTime := time + maxHoldingMinutes * 60 * 1000
    
    // Clear old labels
    if not na(activeEntryLabel)
        label.delete(activeEntryLabel)
        activeEntryLabel := na
    if not na(lastHoldLabel)
        label.delete(lastHoldLabel)
        lastHoldLabel := na
    if not na(lastExitSoonLabel)
        label.delete(lastExitSoonLabel)
        lastExitSoonLabel := na
    if not na(lastNearLongLabel)
        label.delete(lastNearLongLabel)
        lastNearLongLabel := na
    if not na(lastNearShortLabel)
        label.delete(lastNearShortLabel)
        lastNearShortLabel := na
    if not na(lastContinuationLongWarningLabel)
        label.delete(lastContinuationLongWarningLabel)
        lastContinuationLongWarningLabel := na
    if not na(lastContinuationShortWarningLabel)
        label.delete(lastContinuationShortWarningLabel)
        lastContinuationShortWarningLabel := na
    if not na(lastTrendLongWarningLabel)
        label.delete(lastTrendLongWarningLabel)
        lastTrendLongWarningLabel := na
    if not na(lastTrendShortWarningLabel)
        label.delete(lastTrendShortWarningLabel)
        lastTrendShortWarningLabel := na
    
    // Clear old lines
    if not na(invalidLine)
        line.delete(invalidLine)
        invalidLine := na
    if not na(invalidLabel)
        label.delete(invalidLabel)
        invalidLabel := na
    if not na(trailingLine)
        line.delete(trailingLine)
        trailingLine := na
    if not na(breakEvenLine)
        line.delete(breakEvenLine)
        breakEvenLine := na
    if not na(tp1Line)
        line.delete(tp1Line)
        tp1Line := na
    if not na(tp2Line)
        line.delete(tp2Line)
        tp2Line := na
    if not na(tp3Line)
        line.delete(tp3Line)
        tp3Line := na
    if not na(entryPriceLine)
        line.delete(entryPriceLine)
        entryPriceLine := na
    
    // Build entry label text
    tpInfoText = useTakeProfit ? "\nTP1: " + str.tostring(tp1Price, format.mintick) + "\nTP2: " + str.tostring(tp2Price, format.mintick) + "\nTP3: " + str.tostring(tp3Price, format.mintick) : ""
    trailingInfoText = useTrailingStop ? "\nTrail Start: " + str.tostring(activeEntryPrice + atrValue * trailingStartAtr, format.mintick) : ""
    beInfoText = useBreakEvenStop ? "\nBE After: " + str.tostring(activeEntryPrice + atrValue * breakEvenAtrMult, format.mintick) : ""
    trendInfoText = (enableTrendMode and isTrending) ? "\n[TREND MODE]\nADX: " + str.tostring(adxValue, "#.#") : ""
    
    activeEntryLabel := label.new(bar_index, low, "BUY\nEntry: " + str.tostring(activeEntryPrice, format.mintick) + "\nInvalid: " + str.tostring(initialInvalidPrice, format.mintick) + "\nDynamic: " + str.tostring(dynamicExitPrice, format.mintick) + trendInfoText, style=label.style_label_up, color=entryLabelColor, textcolor=color.black, size=size.normal)
    
    // Draw dynamic exit line
    if showInvalidationLine
        invalidLine := line.new(bar_index, dynamicExitPrice, bar_index + 8, dynamicExitPrice, color=dynamicExitColor, width=2, style=line.style_dotted)
        invalidLabel := label.new(bar_index + 8, dynamicExitPrice, "DYNAMIC LONG EXIT\n" + str.tostring(dynamicExitPrice, format.mintick), style=label.style_label_left, color=dynamicExitColor, textcolor=color.white, size=size.small)
    
    // Draw TP lines
    if showTpLevels and useTakeProfit
        tp1Line := line.new(bar_index, tp1Price, bar_index + 8, tp1Price, color=tpColor, width=1, style=line.style_dashed)
        tp2Line := line.new(bar_index, tp2Price, bar_index + 8, tp2Price, color=tpColor, width=1, style=line.style_dashed)
        tp3Line := line.new(bar_index, tp3Price, bar_index + 8, tp3Price, color=tpColor, width=2, style=line.style_solid)
    
    // Draw entry price line
    if showEntryPriceLine
        if not na(entryPriceLine)
            line.delete(entryPriceLine)
        entryPriceLine := line.new(bar_index, activeEntryPrice, bar_index, activeEntryPrice, color=entryLineColor, width=1, style=line.style_dashed)
        entryLineBar := bar_index
    
    // Send entry webhook
    if sendWebhookAlerts
        entryTimeStr = str.format_time(activeEntryTime, "yyyy-MM-dd HH:mm:ss", "America/New_York")
        receivedTimeStr = str.format_time(timenow, "yyyy-MM-dd HH:mm:ss", "America/New_York")
        alert("{\"receivedTime\":\"" + receivedTimeStr + "\",\"eventTime\":\"" + entryTimeStr + "\",\"tradeId\":\"" + activeTradeId + "\",\"event\":\"ENTRY_LONG\",\"ticker\":\"" + syminfo.ticker + "\",\"timeframe\":\"" + timeframe.period + "\",\"tradeType\":\"" + activeTradeType + "\",\"entryPrice\":\"" + str.tostring(activeEntryPrice, format.mintick) + "\",\"exitPrice\":\"\",\"move\":\"\",\"holdDuration\":\"00:00:00\",\"heldBars\":\"\",\"reason\":\"\",\"result\":\"\"}", alert.freq_once_per_bar)

// ============================================================================
// SECTION: SHORT ENTRY
// ============================================================================

if shortSignal
    inShort := true
    inLong := false
    activeEntryPrice := shortEntryPrice
    initialInvalidPrice := newInitialShortInvalid
    dynamicExitPrice := newDynamicShortExit
    activeSide := -1
    activeEntryBar := bar_index
    activeEntryTime := time
    activeTradeType := shortTradeType
    activeTradeId := generateTradeId()
    
    // Store ADX at entry for trend exits (NEW)
    trendEntryAdx := adxValue
    
    // Reset TP levels
    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    tp1Price := na
    tp2Price := na
    tp3Price := na
    
    // Calculate TP levels if enabled
    if useTakeProfit
        tp1Price := activeEntryPrice - atrValue * tp1AtrMult
        tp2Price := activeEntryPrice - atrValue * tp2AtrMult
        tp3Price := activeEntryPrice - atrValue * tp3AtrMult
    
    // Initialize trailing stop
    trailingActivated := false
    trailingStopPrice := na
    
    // Initialize break-even stop
    breakEvenActivated := false
    breakEvenPrice := na
    
    // Set max holding time
    if useMaxHoldingTime
        maxExitTime := time + maxHoldingMinutes * 60 * 1000
    
    // Clear old labels
    if not na(activeEntryLabel)
        label.delete(activeEntryLabel)
        activeEntryLabel := na
    if not na(lastHoldLabel)
        label.delete(lastHoldLabel)
        lastHoldLabel := na
    if not na(lastExitSoonLabel)
        label.delete(lastExitSoonLabel)
        lastExitSoonLabel := na
    if not na(lastNearLongLabel)
        label.delete(lastNearLongLabel)
        lastNearLongLabel := na
    if not na(lastNearShortLabel)
        label.delete(lastNearShortLabel)
        lastNearShortLabel := na
    if not na(lastContinuationLongWarningLabel)
        label.delete(lastContinuationLongWarningLabel)
        lastContinuationLongWarningLabel := na
    if not na(lastContinuationShortWarningLabel)
        label.delete(lastContinuationShortWarningLabel)
        lastContinuationShortWarningLabel := na
    if not na(lastTrendLongWarningLabel)
        label.delete(lastTrendLongWarningLabel)
        lastTrendLongWarningLabel := na
    if not na(lastTrendShortWarningLabel)
        label.delete(lastTrendShortWarningLabel)
        lastTrendShortWarningLabel := na
    
    // Clear old lines
    if not na(invalidLine)
        line.delete(invalidLine)
        invalidLine := na
    if not na(invalidLabel)
        label.delete(invalidLabel)
        invalidLabel := na
    if not na(trailingLine)
        line.delete(trailingLine)
        trailingLine := na
    if not na(breakEvenLine)
        line.delete(breakEvenLine)
        breakEvenLine := na
    if not na(tp1Line)
        line.delete(tp1Line)
        tp1Line := na
    if not na(tp2Line)
        line.delete(tp2Line)
        tp2Line := na
    if not na(tp3Line)
        line.delete(tp3Line)
        tp3Line := na
    if not na(entryPriceLine)
        line.delete(entryPriceLine)
        entryPriceLine := na
    
    // Build entry label text
    tpInfoText = useTakeProfit ? "\nTP1: " + str.tostring(tp1Price, format.mintick) + "\nTP2: " + str.tostring(tp2Price, format.mintick) + "\nTP3: " + str.tostring(tp3Price, format.mintick) : ""
    trailingInfoText = useTrailingStop ? "\nTrail Start: " + str.tostring(activeEntryPrice - atrValue * trailingStartAtr, format.mintick) : ""
    beInfoText = useBreakEvenStop ? "\nBE After: " + str.tostring(activeEntryPrice - atrValue * breakEvenAtrMult, format.mintick) : ""
    trendInfoText = (enableTrendMode and isTrending) ? "\n[TREND MODE]\nADX: " + str.tostring(adxValue, "#.#") : ""
    
    activeEntryLabel := label.new(bar_index, high, "SELL\nEntry: " + str.tostring(activeEntryPrice, format.mintick) + "\nInvalid: " + str.tostring(initialInvalidPrice, format.mintick) + "\nDynamic: " + str.tostring(dynamicExitPrice, format.mintick) + trendInfoText, style=label.style_label_down, color=entryLabelColor, textcolor=color.black, size=size.normal)
    
    // Draw dynamic exit line
    if showInvalidationLine
        invalidLine := line.new(bar_index, dynamicExitPrice, bar_index + 8, dynamicExitPrice, color=dynamicExitColor, width=2, style=line.style_dotted)
        invalidLabel := label.new(bar_index + 8, dynamicExitPrice, "DYNAMIC SHORT EXIT\n" + str.tostring(dynamicExitPrice, format.mintick), style=label.style_label_left, color=dynamicExitColor, textcolor=color.white, size=size.small)
    
    // Draw TP lines
    if showTpLevels and useTakeProfit
        tp1Line := line.new(bar_index, tp1Price, bar_index + 8, tp1Price, color=tpColor, width=1, style=line.style_dashed)
        tp2Line := line.new(bar_index, tp2Price, bar_index + 8, tp2Price, color=tpColor, width=1, style=line.style_dashed)
        tp3Line := line.new(bar_index, tp3Price, bar_index + 8, tp3Price, color=tpColor, width=2, style=line.style_solid)
    
    // Draw entry price line
    if showEntryPriceLine
        if not na(entryPriceLine)
            line.delete(entryPriceLine)
        entryPriceLine := line.new(bar_index, activeEntryPrice, bar_index, activeEntryPrice, color=entryLineColor, width=1, style=line.style_dashed)
        entryLineBar := bar_index
    
    // Send entry webhook
    if sendWebhookAlerts
        entryTimeStr = str.format_time(activeEntryTime, "yyyy-MM-dd HH:mm:ss", "America/New_York")
        receivedTimeStr = str.format_time(timenow, "yyyy-MM-dd HH:mm:ss", "America/New_York")
        alert("{\"receivedTime\":\"" + receivedTimeStr + "\",\"eventTime\":\"" + entryTimeStr + "\",\"tradeId\":\"" + activeTradeId + "\",\"event\":\"ENTRY_SHORT\",\"ticker\":\"" + syminfo.ticker + "\",\"timeframe\":\"" + timeframe.period + "\",\"tradeType\":\"" + activeTradeType + "\",\"entryPrice\":\"" + str.tostring(activeEntryPrice, format.mintick) + "\",\"exitPrice\":\"\",\"move\":\"\",\"holdDuration\":\"00:00:00\",\"heldBars\":\"\",\"reason\":\"\",\"result\":\"\"}", alert.freq_once_per_bar)

// ============================================================================
// SECTION: STOP MANAGEMENT (WHILE IN TRADE)
// ============================================================================

// Update dynamic exit while holding
if useDynamicExitInvalid and inLong and not na(dynamicExitPrice)
    dynamicExitPrice := math.max(dynamicExitPrice, newDynamicLongExit)

if useDynamicExitInvalid and inShort and not na(dynamicExitPrice)
    dynamicExitPrice := math.min(dynamicExitPrice, newDynamicShortExit)

// --- Trailing Stop Logic ---
if useTrailingStop and (inLong or inShort) and not na(activeEntryPrice)
    longTrailTrigger = activeEntryPrice + atrValue * trailingStartAtr
    shortTrailTrigger = activeEntryPrice - atrValue * trailingStartAtr
    
    if inLong and not trailingActivated
        if high >= longTrailTrigger
            trailingActivated := true
            trailingStopPrice := high - atrValue * trailingAtrMult
            if not na(trailingLine)
                line.delete(trailingLine)
            trailingLine := line.new(bar_index, trailingStopPrice, bar_index + 8, trailingStopPrice, color=trailingColor, width=2, style=line.style_dotted)
    
    if inShort and not trailingActivated
        if low <= shortTrailTrigger
            trailingActivated := true
            trailingStopPrice := low + atrValue * trailingAtrMult
            if not na(trailingLine)
                line.delete(trailingLine)
            trailingLine := line.new(bar_index, trailingStopPrice, bar_index + 8, trailingStopPrice, color=trailingColor, width=2, style=line.style_dotted)
    
    // Update trailing stop if activated
    if trailingActivated
        if inLong
            newTrailingStop = high - atrValue * trailingAtrMult
            if newTrailingStop > trailingStopPrice
                trailingStopPrice := newTrailingStop
                line.set_y1(trailingLine, trailingStopPrice)
                line.set_y2(trailingLine, trailingStopPrice)
                line.set_x2(trailingLine, bar_index + 8)
        
        if inShort
            newTrailingStop = low + atrValue * trailingAtrMult
            if newTrailingStop < trailingStopPrice
                trailingStopPrice := newTrailingStop
                line.set_y1(trailingLine, trailingStopPrice)
                line.set_y2(trailingLine, trailingStopPrice)
                line.set_x2(trailingLine, bar_index + 8)
    
    // Update entry price line
    if showEntryPriceLine and not na(entryPriceLine)
        line.set_x2(entryPriceLine, bar_index)

// --- Break-Even Stop Logic ---
if useBreakEvenStop and (inLong or inShort) and not na(activeEntryPrice)
    longBeTrigger = activeEntryPrice + atrValue * breakEvenAtrMult
    shortBeTrigger = activeEntryPrice - atrValue * breakEvenAtrMult
    
    if inLong and not breakEvenActivated
        if high >= longBeTrigger
            breakEvenActivated := true
            breakEvenPrice := activeEntryPrice
            if not na(breakEvenLine)
                line.delete(breakEvenLine)
            breakEvenLine := line.new(bar_index, breakEvenPrice, bar_index + 8, breakEvenPrice, color=breakEvenColor, width=2, style=line.style_solid)
    
    if inShort and not breakEvenActivated
        if low <= shortBeTrigger
            breakEvenActivated := true
            breakEvenPrice := activeEntryPrice
            if not na(breakEvenLine)
                line.delete(breakEvenLine)
            breakEvenLine := line.new(bar_index, breakEvenPrice, bar_index + 8, breakEvenPrice, color=breakEvenColor, width=2, style=line.style_solid)

// ============================================================================
// SECTION: EXIT SIGNAL GENERATION
// ============================================================================

// --- Momentum Exit Signals ---
longMomentumReversal = (useHistInflectionExit and macdBearInflection) or (useMacdCrossExit and macdBearCross) or (useRsi50Exit and rsiCrossDown50)
shortMomentumReversal = (useHistInflectionExit and macdBullInflection) or (useMacdCrossExit and macdBullCross) or (useRsi50Exit and rsiCrossUp50)

// --- Trend Mode Exits (NEW) ---
// For trend trades: exit when trend weakens (ADX drops significantly) or reverses
trendLongAdxExit = 
     activeTradeType == "TREND LONG" and
     enableTrendMode and
     adxValue < trendEntryAdx - 5  // ADX dropped by 5 from entry

trendShortAdxExit =
     activeTradeType == "TREND SHORT" and
     enableTrendMode and
     adxValue < trendEntryAdx - 5  // ADX dropped by 5 from entry

// Trend direction reversal exit
trendLongReversalExit =
     activeTradeType == "TREND LONG" and
     enableTrendMode and
     diMinus > diPlus and  // DI reversed
     adxValue > 15  // Still some trend present

trendShortReversalExit =
     activeTradeType == "TREND SHORT" and
     enableTrendMode and
     diPlus > diMinus and  // DI reversed
     adxValue > 15  // Still some trend present

// --- Reversal Exit Mode Logic ---
longFirstRetrace = inLong and redCandle
shortFirstRetrace = inShort and greenCandle

longRetraceMacdWeakness = inLong and redCandle and hist < hist[1]
shortRetraceMacdWeakness = inShort and greenCandle and hist > hist[1]

reversalExitLongByMode =
     reversalExitMode == "Momentum Reversal" ? longMomentumReversal :
     reversalExitMode == "First Retrace" ? longFirstRetrace :
     longRetraceMacdWeakness

reversalExitShortByMode =
     reversalExitMode == "Momentum Reversal" ? shortMomentumReversal :
     reversalExitMode == "First Retrace" ? shortFirstRetrace :
     shortRetraceMacdWeakness

// --- Continuation Exit Mode Logic ---
continuationLongBasisBreak = inLong and close < basis and hist < hist[1]
continuationShortBasisBreak = inShort and close > basis and hist > hist[1]

continuationLongMacdCrossOnly = inLong and macdBearCross
continuationShortMacdCrossOnly = inShort and macdBullCross

continuationExitLongByMode =
     continuationExitMode == "Momentum Reversal" ? longMomentumReversal :
     continuationExitMode == "MACD Cross Only" ? continuationLongMacdCrossOnly :
     continuationLongBasisBreak

continuationExitShortByMode =
     continuationExitMode == "Momentum Reversal" ? shortMomentumReversal :
     continuationExitMode == "MACD Cross Only" ? continuationShortMacdCrossOnly :
     continuationShortBasisBreak

exitLongByType = 
     activeTradeType == "CONTINUATION" ? continuationExitLongByMode :
     activeTradeType == "TREND LONG" ? (trendLongAdxExit or trendLongReversalExit) :
     reversalExitLongByMode

exitShortByType = 
     activeTradeType == "CONTINUATION" ? continuationExitShortByMode :
     activeTradeType == "TREND SHORT" ? (trendShortAdxExit or trendShortReversalExit) :
     reversalExitShortByMode

// --- Initial Invalidation ---
hardInvalidLong = inLong and not na(initialInvalidPrice) and low <= initialInvalidPrice
hardInvalidShort = inShort and not na(initialInvalidPrice) and high >= initialInvalidPrice

// --- Dynamic Exit (Hold) ---
holdInvalidLong = inLong and not hardInvalidLong and not na(dynamicExitPrice) and low <= dynamicExitPrice
holdInvalidShort = inShort and not hardInvalidShort and not na(dynamicExitPrice) and high >= dynamicExitPrice

// --- Trailing Stop Exit ---
trailingStopLongExit = inLong and useTrailingStop and trailingActivated and not na(trailingStopPrice) and low <= trailingStopPrice
trailingStopShortExit = inShort and useTrailingStop and trailingActivated and not na(trailingStopPrice) and high >= trailingStopPrice

// --- Break-Even Stop Exit ---
breakEvenLongExit = inLong and useBreakEvenStop and breakEvenActivated and not na(breakEvenPrice) and low <= breakEvenPrice
breakEvenShortExit = inShort and useBreakEvenStop and breakEvenActivated and not na(breakEvenPrice) and high >= breakEvenPrice

// --- TP Level Exits ---
tp1LongExit = inLong and useTakeProfit and not tp1Hit and tp1AtrMult > 0 and high >= tp1Price
tp2LongExit = inLong and useTakeProfit and not tp2Hit and tp2AtrMult > 0 and high >= tp2Price
tp3LongExit = inLong and useTakeProfit and not tp3Hit and tp3AtrMult > 0 and high >= tp3Price

tp1ShortExit = inShort and useTakeProfit and not tp1Hit and tp1AtrMult > 0 and low <= tp1Price
tp2ShortExit = inShort and useTakeProfit and not tp2Hit and tp2AtrMult > 0 and low <= tp2Price
tp3ShortExit = inShort and useTakeProfit and not tp3Hit and tp3AtrMult > 0 and low <= tp3Price

// Mark TP levels as hit
if tp1LongExit or tp1ShortExit
    tp1Hit := true
if tp2LongExit or tp2ShortExit
    tp2Hit := true
if tp3LongExit or tp3ShortExit
    tp3Hit := true

// Determine if trade is fully exited
anyTpExitLong = tp1LongExit or tp2LongExit or tp3LongExit
anyTpExitShort = tp1ShortExit or tp2ShortExit or tp3ShortExit

// Full exit conditions
fullExitLong = inLong and (
     exitLongByType or
     hardInvalidLong or
     holdInvalidLong or
     trailingStopLongExit or
     breakEvenLongExit or
     (tp3LongExit and tp2Hit and tp1Hit) or
     (tp3LongExit and not tp1Hit) or
     (tp2LongExit and tp1Hit)
)

fullExitShort = inShort and (
     exitShortByType or
     hardInvalidShort or
     holdInvalidShort or
     trailingStopShortExit or
     breakEvenShortExit or
     (tp3ShortExit and tp2Hit and tp1Hit) or
     (tp3ShortExit and not tp1Hit) or
     (tp2ShortExit and tp1Hit)
)

// Partial TP exits
partialTpLongExit = inLong and useTakeProfit and not fullExitLong and (
     (tp1LongExit and not tp2Hit) or
     (tp2LongExit and tp1Hit and not tp3Hit)
)

partialTpShortExit = inShort and useTakeProfit and not fullExitShort and (
     (tp1ShortExit and not tp2Hit) or
     (tp2ShortExit and tp1Hit and not tp3Hit)
)

// --- Max Holding Time Exit ---
maxHoldingLongExit = inLong and useMaxHoldingTime and not na(maxExitTime) and time >= maxExitTime
maxHoldingShortExit = inShort and useMaxHoldingTime and not na(maxExitTime) and time >= maxExitTime

// --- Combined Exit Signals ---
exitLong = fullExitLong or maxHoldingLongExit
exitShort = fullExitShort or maxHoldingShortExit

// --- Early Exit Warning ---
earlyExitLong = showExitSoon and inLong and not exitLong and not partialTpLongExit and hist < hist[1]
earlyExitShort = showExitSoon and inShort and not exitShort and not partialTpShortExit and hist > hist[1]

// ============================================================================
// SECTION: EXIT EXECUTION
// ============================================================================

// --- EXIT PRICE DETERMINATION ---
longExitPrice =
     hardInvalidLong ? initialInvalidPrice :
     holdInvalidLong ? dynamicExitPrice :
     trailingStopLongExit ? trailingStopPrice :
     breakEvenLongExit ? breakEvenPrice :
     exitPriceMode == "Candle Extreme" ? high :
     close

shortExitPrice =
     hardInvalidShort ? initialInvalidPrice :
     holdInvalidShort ? dynamicExitPrice :
     trailingStopShortExit ? trailingStopPrice :
     breakEvenShortExit ? breakEvenPrice :
     exitPriceMode == "Candle Extreme" ? low :
     close

longMove = not na(activeEntryPrice) ? longExitPrice - activeEntryPrice : na
shortMove = not na(activeEntryPrice) ? activeEntryPrice - shortExitPrice : na

entryTimeText = not na(activeEntryTime) ? str.format_time(activeEntryTime, "HH:mm", "America/New_York") : ""
exitTimeText = str.format_time(time, "HH:mm", "America/New_York")
heldBars = not na(activeEntryBar) ? bar_index - activeEntryBar : na

// Build TP hits string
tpHitsStr = (tp1Hit ? "TP1" : "") + (tp2Hit ? ",TP2" : "") + (tp3Hit ? ",TP3" : "")

// --- LONG EXIT ---
if exitLong
    exitModeUsed = activeTradeType == "CONTINUATION" ? continuationExitMode : (activeTradeType == "TREND LONG" ? "TREND EXIT" : reversalExitMode)
    reason =
         hardInvalidLong ? "INITIAL INVALID" :
         holdInvalidLong ? "DYNAMIC EXIT" :
         trailingStopLongExit ? "TRAILING STOP" :
         breakEvenLongExit ? "BREAK-EVEN" :
         maxHoldingLongExit ? "MAX HOLDING TIME" :
         trendLongAdxExit ? "TREND ADX EXIT" :
         trendLongReversalExit ? "TREND REVERSAL" :
         activeTradeType + " " + exitModeUsed

    labelTitle =
         hardInvalidLong ? "INVALID LONG\nRESET" :
         holdInvalidLong ? "EXIT LONG\nDYNAMIC EXIT" :
         trailingStopLongExit ? "EXIT LONG\nTRAILING STOP" :
         breakEvenLongExit ? "EXIT LONG\nBREAK-EVEN" :
         maxHoldingLongExit ? "EXIT LONG\nMAX TIME" :
         trendLongAdxExit ? "EXIT LONG\nTREND WEAKENED" :
         "EXIT LONG\n" + reason

    moveText = str.tostring(longMove, format.mintick)
    result = str.tonumber(moveText) >= 0 ? "WIN" : "LOSS"
    
    // Calculate percentage move
    pctMove = activeEntryPrice > 0 ? (longMove / activeEntryPrice) * 100 : 0
    pctMoveText = str.tostring(pctMove, "#.##") + "%"
    
    // Calculate hold duration
    holdDurationSeconds = not na(activeEntryTime) ? int((time - activeEntryTime) / 1000) : 0
    holdHours = int(holdDurationSeconds / 3600)
    holdMinutes = int((holdDurationSeconds % 3600) / 60)
    holdSecs = holdDurationSeconds % 60
    holdDurationText = str.format("{0,number,00}:{1,number,00}:{2,number,00}", holdHours, holdMinutes, holdSecs)
    heldBarsText = str.tostring(bar_index - activeEntryBar)
    
    // Delete entry label on exit
    if not na(activeEntryLabel)
        label.delete(activeEntryLabel)
        activeEntryLabel := na
    
    // Delete entry price line on exit
    if not na(entryPriceLine)
        line.delete(entryPriceLine)
        entryPriceLine := na

    // Add trade to history
    addTrade("LONG", activeTradeType, activeTradeId, entryTimeText, exitTimeText, str.tostring(activeEntryPrice, format.mintick), str.tostring(longExitPrice, format.mintick), moveText, str.tostring(heldBars), reason, tpHitsStr)

    // Send exit webhook
    if sendWebhookAlerts
        exitTimeStr = str.format_time(time, "yyyy-MM-dd HH:mm:ss", "America/New_York")
        receivedTimeStr = str.format_time(timenow, "yyyy-MM-dd HH:mm:ss", "America/New_York")
        alert("{\"receivedTime\":\"" + receivedTimeStr + "\",\"eventTime\":\"" + exitTimeStr + "\",\"tradeId\":\"" + activeTradeId + "\",\"event\":\"EXIT_LONG\",\"ticker\":\"" + syminfo.ticker + "\",\"timeframe\":\"" + timeframe.period + "\",\"tradeType\":\"" + activeTradeType + "\",\"entryPrice\":\"" + str.tostring(activeEntryPrice, format.mintick) + "\",\"exitPrice\":\"" + str.tostring(longExitPrice, format.mintick) + "\",\"move\":\"" + moveText + "\",\"holdDuration\":\"" + holdDurationText + "\",\"heldBars\":\"" + heldBarsText + "\",\"reason\":\"" + reason + "\",\"result\":\"" + result + "\"}", alert.freq_once_per_bar)

    // Reset position state
    inLong := false
    activeEntryPrice := na
    initialInvalidPrice := na
    dynamicExitPrice := na
    activeSide := 0
    activeEntryBar := na
    activeEntryTime := na
    activeTradeType := ""
    activeTradeId := ""
    maxExitTime := na
    trendEntryAdx := na
    
    // Clear other labels
    if not na(lastHoldLabel)
        label.delete(lastHoldLabel)
        lastHoldLabel := na
    if not na(lastExitSoonLabel)
        label.delete(lastExitSoonLabel)
        lastExitSoonLabel := na
    if not na(lastNearLongLabel)
        label.delete(lastNearLongLabel)
        lastNearLongLabel := na
    if not na(lastNearShortLabel)
        label.delete(lastNearShortLabel)
        lastNearShortLabel := na
    if not na(lastContinuationLongWarningLabel)
        label.delete(lastContinuationLongWarningLabel)
        lastContinuationLongWarningLabel := na
    if not na(lastContinuationShortWarningLabel)
        label.delete(lastContinuationShortWarningLabel)
        lastContinuationShortWarningLabel := na
    if not na(lastTrendLongWarningLabel)
        label.delete(lastTrendLongWarningLabel)
        lastTrendLongWarningLabel := na
    if not na(lastTrendShortWarningLabel)
        label.delete(lastTrendShortWarningLabel)
        lastTrendShortWarningLabel := na
    
    // Clear lines
    if not na(invalidLine)
        line.delete(invalidLine)
        invalidLine := na
    if not na(invalidLabel)
        label.delete(invalidLabel)
        invalidLabel := na
    if not na(trailingLine)
        line.delete(trailingLine)
        trailingLine := na
    if not na(breakEvenLine)
        line.delete(breakEvenLine)
        breakEvenLine := na
    if not na(tp1Line)
        line.delete(tp1Line)
        tp1Line := na
    if not na(tp2Line)
        line.delete(tp2Line)
        tp2Line := na
    if not na(tp3Line)
        line.delete(tp3Line)
        tp3Line := na

// --- SHORT EXIT ---
if exitShort
    exitModeUsed = activeTradeType == "CONTINUATION" ? continuationExitMode : (activeTradeType == "TREND SHORT" ? "TREND EXIT" : reversalExitMode)
    reason =
         hardInvalidShort ? "INITIAL INVALID" :
         holdInvalidShort ? "DYNAMIC EXIT" :
         trailingStopShortExit ? "TRAILING STOP" :
         breakEvenShortExit ? "BREAK-EVEN" :
         maxHoldingShortExit ? "MAX HOLDING TIME" :
         trendShortAdxExit ? "TREND ADX EXIT" :
         trendShortReversalExit ? "TREND REVERSAL" :
         activeTradeType + " " + exitModeUsed

    labelTitle =
         hardInvalidShort ? "INVALID SHORT\nRESET" :
         holdInvalidShort ? "EXIT SHORT\nDYNAMIC EXIT" :
         trailingStopShortExit ? "EXIT SHORT\nTRAILING STOP" :
         breakEvenShortExit ? "EXIT SHORT\nBREAK-EVEN" :
         maxHoldingShortExit ? "EXIT SHORT\nMAX TIME" :
         trendShortAdxExit ? "EXIT SHORT\nTREND WEAKENED" :
         "EXIT SHORT\n" + reason

    moveText = str.tostring(shortMove, format.mintick)
    result = str.tonumber(moveText) >= 0 ? "WIN" : "LOSS"
    
    // Calculate percentage move
    pctMove = activeEntryPrice > 0 ? (shortMove / activeEntryPrice) * 100 : 0
    pctMoveText = str.tostring(pctMove, "#.##") + "%"
    
    // Calculate hold duration
    holdDurationSeconds = not na(activeEntryTime) ? int((time - activeEntryTime) / 1000) : 0
    holdHours = int(holdDurationSeconds / 3600)
    holdMinutes = int((holdDurationSeconds % 3600) / 60)
    holdSecs = holdDurationSeconds % 60
    holdDurationText = str.format("{0,number,00}:{1,number,00}:{2,number,00}", holdHours, holdMinutes, holdSecs)
    heldBarsText = str.tostring(bar_index - activeEntryBar)
    
    // Delete entry label on exit
    if not na(activeEntryLabel)
        label.delete(activeEntryLabel)
        activeEntryLabel := na
    
    // Delete entry price line on exit
    if not na(entryPriceLine)
        line.delete(entryPriceLine)
        entryPriceLine := na

    // Add trade to history
    addTrade("SHORT", activeTradeType, activeTradeId, entryTimeText, exitTimeText, str.tostring(activeEntryPrice, format.mintick), str.tostring(shortExitPrice, format.mintick), moveText, str.tostring(heldBars), reason, tpHitsStr)

    // Send exit webhook
    if sendWebhookAlerts
        exitTimeStr = str.format_time(time, "yyyy-MM-dd HH:mm:ss", "America/New_York")
        receivedTimeStr = str.format_time(timenow, "yyyy-MM-dd HH:mm:ss", "America/New_York")
        alert("{\"receivedTime\":\"" + receivedTimeStr + "\",\"eventTime\":\"" + exitTimeStr + "\",\"tradeId\":\"" + activeTradeId + "\",\"event\":\"EXIT_SHORT\",\"ticker\":\"" + syminfo.ticker + "\",\"timeframe\":\"" + timeframe.period + "\",\"tradeType\":\"" + activeTradeType + "\",\"entryPrice\":\"" + str.tostring(activeEntryPrice, format.mintick) + "\",\"exitPrice\":\"" + str.tostring(shortExitPrice, format.mintick) + "\",\"move\":\"" + moveText + "\",\"holdDuration\":\"" + holdDurationText + "\",\"heldBars\":\"" + heldBarsText + "\",\"reason\":\"" + reason + "\",\"result\":\"" + result + "\"}", alert.freq_once_per_bar)

    // Reset position state
    inShort := false
    activeEntryPrice := na
    initialInvalidPrice := na
    dynamicExitPrice := na
    activeSide := 0
    activeEntryBar := na
    activeEntryTime := na
    activeTradeType := ""
    activeTradeId := ""
    maxExitTime := na
    trendEntryAdx := na
    
    // Clear other labels
    if not na(lastHoldLabel)
        label.delete(lastHoldLabel)
        lastHoldLabel := na
    if not na(lastExitSoonLabel)
        label.delete(lastExitSoonLabel)
        lastExitSoonLabel := na
    if not na(lastNearLongLabel)
        label.delete(lastNearLongLabel)
        lastNearLongLabel := na
    if not na(lastNearShortLabel)
        label.delete(lastNearShortLabel)
        lastNearShortLabel := na
    if not na(lastContinuationLongWarningLabel)
        label.delete(lastContinuationLongWarningLabel)
        lastContinuationLongWarningLabel := na
    if not na(lastContinuationShortWarningLabel)
        label.delete(lastContinuationShortWarningLabel)
        lastContinuationShortWarningLabel := na
    if not na(lastTrendLongWarningLabel)
        label.delete(lastTrendLongWarningLabel)
        lastTrendLongWarningLabel := na
    if not na(lastTrendShortWarningLabel)
        label.delete(lastTrendShortWarningLabel)
        lastTrendShortWarningLabel := na
    
    // Clear lines
    if not na(invalidLine)
        line.delete(invalidLine)
        invalidLine := na
    if not na(invalidLabel)
        label.delete(invalidLabel)
        invalidLabel := na
    if not na(trailingLine)
        line.delete(trailingLine)
        trailingLine := na
    if not na(breakEvenLine)
        line.delete(breakEvenLine)
        breakEvenLine := na
    if not na(tp1Line)
        line.delete(tp1Line)
        tp1Line := na
    if not na(tp2Line)
        line.delete(tp2Line)
        tp2Line := na
    if not na(tp3Line)
        line.delete(tp3Line)
        tp3Line := na

// ============================================================================
// SECTION: WARNING LABELS - TREND (NEW)
// ============================================================================

// --- Trend Warning Labels ---
if trendLongWarningNow
    if not na(lastTrendLongWarningLabel)
        label.delete(lastTrendLongWarningLabel)
    trendDirText = trendDirection == 1 ? "BULLISH" : "BEARISH"
    lastTrendLongWarningLabel := label.new(bar_index, low, "TREND LONG NEAR\n" + trendDirText + " TREND DETECTED\nADX: " + str.tostring(adxValue, "#.#") + " | RSI: " + str.tostring(rsi, "#") + "\nWaiting for pullback entry", style=label.style_label_up, color=trendWarningColor, textcolor=color.white, size=size.small)
    lastTrendLongWarningBar := bar_index

if trendShortWarningNow
    if not na(lastTrendShortWarningLabel)
        label.delete(lastTrendShortWarningLabel)
    trendDirText = trendDirection == -1 ? "BEARISH" : "BULLISH"
    lastTrendShortWarningLabel := label.new(bar_index, high, "TREND SHORT NEAR\n" + trendDirText + " TREND DETECTED\nADX: " + str.tostring(adxValue, "#.#") + " | RSI: " + str.tostring(rsi, "#") + "\nWaiting for pullback entry", style=label.style_label_down, color=trendWarningColor, textcolor=color.white, size=size.small)
    lastTrendShortWarningBar := bar_index

// ============================================================================
// SECTION: WARNING LABELS - EXISTING
// ============================================================================

// --- Heads-Up Labels ---
if nearLongNow
    if not na(lastNearLongLabel)
        label.delete(lastNearLongLabel)
    lastNearLongLabel := label.new(bar_index, low, "LIMIT LONG NEAR\nEst. Entry: " + str.tostring(longEntryPrice, format.mintick), style=label.style_label_up, color=headsUpColor, textcolor=color.black, size=size.small)
    lastNearLongBar := bar_index

if nearShortNow
    if not na(lastNearShortLabel)
        label.delete(lastNearShortLabel)
    lastNearShortLabel := label.new(bar_index, high, "LIMIT SHORT NEAR\nEst. Entry: " + str.tostring(shortEntryPrice, format.mintick), style=label.style_label_down, color=headsUpColor, textcolor=color.black, size=size.small)
    lastNearShortBar := bar_index

// --- Continuation Warning Labels ---
if continuationLongWarningNow
    if not na(lastContinuationLongWarningLabel)
        label.delete(lastContinuationLongWarningLabel)
    lastContinuationLongWarningLabel := label.new(bar_index, low, "CONTINUATION BUY NEAR\nEst. Entry: " + str.tostring(basis, format.mintick) + "\nScore: " + str.tostring(continuationLongScore) + "/7\nWaiting for full confirmation", style=label.style_label_up, color=warningColor, textcolor=color.white, size=size.small)
    lastContinuationLongWarningBar := bar_index

if continuationShortWarningNow
    if not na(lastContinuationShortWarningLabel)
        label.delete(lastContinuationShortWarningLabel)
    lastContinuationShortWarningLabel := label.new(bar_index, high, "CONTINUATION SELL NEAR\nEst. Entry: " + str.tostring(basis, format.mintick) + "\nScore: " + str.tostring(continuationShortScore) + "/7\nWaiting for full confirmation", style=label.style_label_down, color=warningColor, textcolor=color.white, size=size.small)
    lastContinuationShortWarningBar := bar_index

// --- EXIT SOON Labels ---
if earlyExitLong
    if not na(lastExitSoonLabel)
        label.delete(lastExitSoonLabel)
    lastExitSoonLabel := label.new(bar_index, high, "EXIT SOON\nLONG\nMomentum weakening", style=label.style_label_down, color=color.new(exitColor, 10), textcolor=color.white, size=size.small)

if earlyExitShort
    if not na(lastExitSoonLabel)
        label.delete(lastExitSoonLabel)
    lastExitSoonLabel := label.new(bar_index, low, "EXIT SOON\nSHORT\nMomentum weakening", style=label.style_label_up, color=color.new(exitColor, 10), textcolor=color.white, size=size.small)

// ============================================================================
// SECTION: HOLD LABEL
// ============================================================================

holdLong = inLong and not exitLong
holdShort = inShort and not exitShort

if showHoldLabel and (holdLong or holdShort)
    if not na(lastHoldLabel)
        label.delete(lastHoldLabel)
    
    // Calculate estimated target based on ATR
    estimatedTarget = inLong ? activeEntryPrice + atrValue * 2 : activeEntryPrice - atrValue * 2
    
    // Calculate current stop loss
    currentStop = inLong ? 
         (not na(trailingStopPrice) and trailingActivated ? trailingStopPrice : 
          not na(breakEvenPrice) and breakEvenActivated ? breakEvenPrice : 
          dynamicExitPrice) :
         (not na(trailingStopPrice) and trailingActivated ? trailingStopPrice : 
          not na(breakEvenPrice) and breakEvenActivated ? breakEvenPrice : 
          dynamicExitPrice)
    
    // Check for momentum weakening
    momentumWeakLong = inLong and hist < hist[1] and hist[1] < hist[2]
    momentumWeakShort = inShort and hist > hist[1] and hist[1] > hist[2]
    momentumWarning = momentumWeakLong or momentumWeakShort
    
    // Trend warning for trend trades (NEW)
    trendWarning = ""
    if activeTradeType == "TREND LONG" and enableTrendMode
        if adxValue < trendEntryAdx - 3
            trendWarning := "\n⚠️ TREND WEAKENING"
        else if diMinus > diPlus
            trendWarning := "\n⚠️ TREND REVERSING"
    if activeTradeType == "TREND SHORT" and enableTrendMode
        if adxValue < trendEntryAdx - 3
            trendWarning := "\n⚠️ TREND WEAKENING"
        else if diPlus > diMinus
            trendWarning := "\n⚠️ TREND REVERSING"
    
    // Build label text
    warningText = momentumWarning ? "\n⚠️ MOMENTUM WEAKING" : trendWarning
    
    // Add trend info if in trend mode (NEW)
    trendInfo = (enableTrendMode and isTrending) ? "\n[TREND] ADX: " + str.tostring(adxValue, "#.#") : ""
    
    lastHoldLabel := label.new(bar_index, holdLong ? low : high, (holdLong ? "HOLD LONG" : "HOLD SHORT") + "\nTarget: " + str.tostring(estimatedTarget, format.mintick) + "\nStop: " + str.tostring(currentStop, format.mintick) + warningText + trendInfo, style=holdLong ? label.style_label_up : label.style_label_down, color=holdColor, textcolor=color.white, size=size.small)

// ============================================================================
// SECTION: DYNAMIC LINE UPDATES
// ============================================================================

if showInvalidationLine and not na(invalidLine) and (inLong or inShort)
    line.set_x2(invalidLine, bar_index + 8)
    line.set_y1(invalidLine, dynamicExitPrice)
    line.set_y2(invalidLine, dynamicExitPrice)
    
    if not na(invalidLabel)
        label.set_x(invalidLabel, bar_index + 8)
        label.set_y(invalidLabel, dynamicExitPrice)
        label.set_text(invalidLabel, (inLong ? "DYNAMIC LONG EXIT\n" : "DYNAMIC SHORT EXIT\n") + str.tostring(dynamicExitPrice, format.mintick))

if showTpLevels and useTakeProfit and (inLong or inShort)
    if not na(tp1Line) and not tp1Hit
        line.set_x2(tp1Line, bar_index + 8)
    if not na(tp2Line) and not tp2Hit
        line.set_x2(tp2Line, bar_index + 8)
    if not na(tp3Line) and not tp3Hit
        line.set_x2(tp3Line, bar_index + 8)

if not na(breakEvenLine) and (inLong or inShort)
    line.set_x2(breakEvenLine, bar_index + 8)

// Update entry price line to current bar
if showEntryPriceLine and not na(entryPriceLine) and (inLong or inShort)
    line.set_x2(entryPriceLine, bar_index)

// ============================================================================
// SECTION: MODE DISPLAY TABLE (NEW)
// ============================================================================

if showModeDisplay
    if not na(modeDisplayTable)
        table.delete(modeDisplayTable)
    
    // Determine table position
    tablePos = modeDisplayPosition == "Top Right" ? position.top_right :
               modeDisplayPosition == "Top Left" ? position.top_left :
               modeDisplayPosition == "Bottom Right" ? position.bottom_right :
               position.bottom_left
    
    // Create mode display table
    modeDisplayTable := table.new(tablePos, 2, 4, bgcolor=modeBgColor, border_width=1)
    
    // Mode header
    modeColor = currentMode == "TREND FOLLOWING" ? trendModeColor : continuationColor
    table.cell(modeDisplayTable, 0, 0, "MODE", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(modeDisplayTable, 1, 0, currentMode, bgcolor=color.new(modeColor, 30), text_color=color.white, text_size=size.small)
    
    // ADX Level
    adxColor = adxValue >= strongTrendThreshold ? color.new(color.lime, 30) :
               adxValue >= adxThreshold ? color.new(color.yellow, 30) :
               color.new(color.red, 30)
    table.cell(modeDisplayTable, 0, 1, "ADX", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(modeDisplayTable, 1, 1, str.tostring(adxValue, "#.#"), bgcolor=adxColor, text_color=color.white, text_size=size.small)
    
    // Trend Direction
    dirText = trendDirection == 1 ? "↑ BULL" : trendDirection == -1 ? "↓ BEAR" : "— RANGE"
    dirColor = trendDirection == 1 ? color.new(bullColor, 30) :
               trendDirection == -1 ? color.new(bearColor, 30) :
               color.new(color.gray, 30)
    table.cell(modeDisplayTable, 0, 2, "TREND", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(modeDisplayTable, 1, 2, dirText, bgcolor=dirColor, text_color=color.white, text_size=size.small)
    
    // Trend Strength
    strengthColor = (trendStrength == "STRONG" ? color.new(color.lime, 30) :
                     trendStrength == "MODERATE" ? color.new(color.yellow, 30) :
                     color.new(color.red, 30))
    table.cell(modeDisplayTable, 0, 3, "STRENGTH", bgcolor=color.black, text_color=color.white, text_size=size.small)
    table.cell(modeDisplayTable, 1, 3, trendStrength, bgcolor=strengthColor, text_color=color.white, text_size=size.small)

// ============================================================================
// SECTION: REAL-TIME TRADE INFO TABLE
// ============================================================================

if showRealTimeTradeTable
    if not na(realTimeTradeInfoTable)
        table.delete(realTimeTradeInfoTable)
    
    tablePos = position.bottom_left
    
    realTimeTradeInfoTable := table.new(tablePos, 2, 3, border_width=1)
    
    if inLong or inShort
        // Header
        table.cell(realTimeTradeInfoTable, 0, 0, "CURRENT TRADE", bgcolor=color.black, text_color=color.white, text_size=size.small)
        table.cell(realTimeTradeInfoTable, 1, 0, "LIVE", bgcolor=color.new(bullColor, 20), text_color=color.white, text_size=size.small)
        
        // Side / Type
        table.cell(realTimeTradeInfoTable, 0, 1, "Side", text_color=color.white, text_size=size.small)
        table.cell(realTimeTradeInfoTable, 1, 1, (inLong ? "LONG" : "SHORT") + " | " + activeTradeType, bgcolor=inLong ? color.new(bullColor, 70) : color.new(bearColor, 70), text_color=color.white, text_size=size.small)
        
        // Entry Price / Entry Time
        entryTimeDisplay = not na(activeEntryTime) ? str.format_time(activeEntryTime, "HH:mm", "America/New_York") : "?"
        table.cell(realTimeTradeInfoTable, 0, 2, "Entry", text_color=color.white, text_size=size.small)
        table.cell(realTimeTradeInfoTable, 1, 2, str.tostring(activeEntryPrice, format.mintick) + " @ " + entryTimeDisplay, text_color=color.white, text_size=size.small)
    else
        // No active trade - show waiting message
        table.cell(realTimeTradeInfoTable, 0, 0, "NO ACTIVE TRADE", bgcolor=color.black, text_color=color.white, text_size=size.small, text_halign=text.align_center)
        table.cell(realTimeTradeInfoTable, 1, 0, "WAITING...", bgcolor=color.new(color.gray, 70), text_color=color.white, text_size=size.small)

// ============================================================================
// SECTION: TRADE HISTORY TABLE
// ============================================================================

var table tradeTable = table.new(position.top_right, 10, tableRows + 1, border_width=1)

if barstate.islast and showTradeTable
    table.clear(tradeTable, 0, 0, 9, tableRows)
    
    // Header row
    table.cell(tradeTable, 0, 0, "Side", bgcolor=color.black, text_color=color.white)
    table.cell(tradeTable, 1, 0, "Type", bgcolor=color.black, text_color=color.white)
    table.cell(tradeTable, 2, 0, "Entry", bgcolor=color.black, text_color=color.white)
    table.cell(tradeTable, 3, 0, "Exit", bgcolor=color.black, text_color=color.white)
    table.cell(tradeTable, 4, 0, "Entry Px", bgcolor=color.black, text_color=color.white)
    table.cell(tradeTable, 5, 0, "Exit Px", bgcolor=color.black, text_color=color.white)
    table.cell(tradeTable, 6, 0, "Move", bgcolor=color.black, text_color=color.white)
    table.cell(tradeTable, 7, 0, "Held", bgcolor=color.black, text_color=color.white)
    table.cell(tradeTable, 8, 0, "Result", bgcolor=color.black, text_color=color.white)
    table.cell(tradeTable, 9, 0, "TPs", bgcolor=color.black, text_color=color.white)
    
    // Data rows
    rowsToShow = math.min(array.size(histSide), tableRows)
    
    for i = 0 to rowsToShow - 1
        result = array.get(histResult, i)
        resultColor = result == "WIN" ? color.new(bullColor, 20) : color.new(bearColor, 20)
        
        table.cell(tradeTable, 0, i + 1, array.get(histSide, i), text_color=color.white)
        table.cell(tradeTable, 1, i + 1, array.get(histType, i), text_color=color.white)
        table.cell(tradeTable, 2, i + 1, array.get(histEntryTime, i), text_color=color.white)
        table.cell(tradeTable, 3, i + 1, array.get(histExitTime, i), text_color=color.white)
        table.cell(tradeTable, 4, i + 1, array.get(histEntry, i), text_color=color.white)
        table.cell(tradeTable, 5, i + 1, array.get(histExit, i), text_color=color.white)
        table.cell(tradeTable, 6, i + 1, array.get(histMove, i), text_color=color.white)
        table.cell(tradeTable, 7, i + 1, array.get(histHeld, i), text_color=color.white)
        table.cell(tradeTable, 8, i + 1, result, bgcolor=resultColor, text_color=color.white)
        table.cell(tradeTable, 9, i + 1, array.get(histTpHits, i), text_color=color.white)

// ============================================================================
// SECTION: BOLLINGER BANDS PLOT
// ============================================================================

plot(showBB ? basis : na, "BB Basis", color=color.gray)
plot(showBB ? upper : na, "Upper BB", color=bearColor)
plot(showBB ? lower : na, "Lower BB", color=bullColor)

// ============================================================================
// SECTION: ALERTS
// ============================================================================

alertcondition(longSignal, "BUY Signal", "BUY signal triggered.")
alertcondition(shortSignal, "SELL Signal", "SELL signal triggered.")
alertcondition(midlineLongSignal, "Midline Long Continuation", "Midline long continuation triggered.")
alertcondition(midlineShortSignal, "Midline Short Continuation", "Midline short continuation triggered.")
alertcondition(continuationLongWarningNow, "Continuation Buy Near", "Continuation buy setup is almost ready.")
alertcondition(continuationShortWarningNow, "Continuation Sell Near", "Continuation sell setup is almost ready.")
alertcondition(exitLong, "Exit Long", "Exit long or invalid long.")
alertcondition(exitShort, "Exit Short", "Exit short or invalid short.")

// Trend Mode Alerts (NEW)
alertcondition(trendLongWarningNow, "Trend Long Near", "Trend long setup is almost ready.")
alertcondition(trendShortWarningNow, "Trend Short Near", "Trend short setup is almost ready.")
alertcondition(trendUptrend and adxValue >= adxThreshold, "Strong Uptrend Detected", "ADX indicates strong uptrend - consider trend following mode.")
alertcondition(trendDowntrend and adxValue >= adxThreshold, "Strong Downtrend Detected", "ADX indicates strong downtrend - consider trend following mode.")
````
