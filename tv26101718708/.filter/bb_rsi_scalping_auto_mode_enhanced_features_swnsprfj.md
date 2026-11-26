# BB RSI Scalping Auto Mode + Enhanced Features

- url: https://www.tradingview.com/script/swNSPrFJ-BB-RSI-Scalping-Auto-Mode-Enhanced-Features/
- type: indicator
- pine_id: PUB;0841a5700be742b9a5f5976101834384
- version: 1.0

## Description

// =============================================
// DESCRIPTION
// =============================================
// BB RSI Scalping Auto Mode is a multi-timeframe scalping indicator that combines
// Bollinger Bands volatility analysis with RSI momentum readings to identify
// high-probability mean reversion and momentum continuation trade setups.
//
// KEY FEATURES:
// - Automatically detects overbought/oversold conditions using RSI
// - Identifies volatility squeezes and expansions using Bollinger Bands
// - Provides clear entry signals with visual feedback
// - Supports multiple timeframe analysis for confirmation
// - Includes auto mode that adapts to market conditions
//
// SIGNAL GENERATION LOGIC:
// - LONG SIGNALS: RSI crosses above oversold level while price is near lower BB band
// - SHORT SIGNALS: RSI crosses below overbought level while price is near upper BB band
// - AUTO MODE automatically adjusts RSI thresholds based on volatility
//
// BEST USED FOR:
// - Scalping on 1-5 minute timeframes
// - Mean reversion trades at band touches
// - Momentum continuation trades after RSI confirmations
// - Volatility breakout anticipation during BB squeezes
//
// DISCLAIMER: This indicator is for educational purposes only. Always use proper
// risk management and backtest before live trading.
//

## Source Code

````pine
//@version=6
// ============================================================================
// SCRIPT PURPOSE
// ============================================================================
// This indicator is a Bollinger Band + RSI + MACD + Volume scalping tool.
// It is designed for short-term intraday trade tracking.
//
// The script looks for:
// 1. Reversal trades near the outer Bollinger Bands.
// 2. Continuation trades around the Bollinger Band midline/basis.
// 3. Exit conditions based on momentum weakness, retracement, invalidation,
//    dynamic exit levels, and continuation-specific exit rules.
//
// This is an indicator, not a TradingView strategy.
// It does not place broker orders. It creates visual trade labels,
// dynamic exit lines, alert events, and a recent trade summary table.

// ============================================================================
// STRATEGY OVERVIEW
// ============================================================================
// Reversal Long:
// - Price is near or outside the lower Bollinger Band.
// - RSI is weak/oversold relative to the dynamic RSI threshold.
// - Candle/MACD/volume confirmation depends on the selected Entry Mode.
//
// Reversal Short:
// - Price is near or outside the upper Bollinger Band.
// - RSI is strong/overbought relative to the dynamic RSI threshold.
// - Candle/MACD/volume confirmation depends on the selected Entry Mode.
//
// Midline Continuation Long:
// - Price tests/reclaims the Bollinger Band basis.
// - RSI is above 50.
// - MACD histogram is improving.
// - MACD line is at/above signal line.
// - Recent volume confirmation exists.
//
// Midline Continuation Short:
// - Price tests/rejects the Bollinger Band basis.
// - RSI is below 50.
// - MACD histogram is weakening.
// - MACD line is at/below signal line.
// - Recent volume confirmation exists.
//
// Exit Logic:
// - Reversal and continuation trades have separate exit rules.
// - Exits may come from MACD weakness, MACD cross, first retrace,
//   basis break, initial invalidation, dynamic exit level, trailing stop,
//   break-even, take profit levels, or max holding time.

// ============================================================================
// GOOGLE SHEET / WEBHOOK PURPOSE
// ============================================================================
// The Google Sheet logging captures TradingView alert events in real time
// for review, trade tracking, and dashboard building.
//
// Current base behavior:
// - Entry labels are created on the chart.
// - Closed trade / exit alerts are sent through TradingView webhooks.
// - Google Apps Script receives the webhook JSON and appends it to a
//   Google Sheet, usually named "Trades".
//
// Intended logged fields:
// - tradeId, receivedTime, eventTime, event, ticker, timeframe
// - side, type, entryPrice, exitPrice, move, heldBars, reason, result
//
// One trade = one entry log + one exit log
// - Generate a stable tradeId at entry.
// - Send one ENTRY alert when the trade starts.
// - Send one EXIT or INVALID alert when the trade closes.
// - Avoid repeated alerts while already in a trade.
// - Use Google Sheet duplicate protection based on: tradeId + event

// ============================================================================
// NEW FEATURES IN THIS VERSION
// ============================================================================
// 1. Trade ID System - Unique ID per trade for Google Sheet logging
// 2. Enhanced Webhook Format - Complete JSON with all fields
// 3. ATR-Based Trailing Stop - Locks in profits as price moves
// 4. Session Filter - Trade only during specific market hours
// 5. Break-Even Stop - Moves stop to entry after ATR profit threshold
// 6. ATR-Based Take Profit Levels - Multiple TP levels with partial exits
// 7. RSI 50 Cross Fix - Corrected exit logic for RSI 50 crossings
// 8. Max Holding Time - Time-based exit to prevent overnight holds
// 9. Enhanced Trade Statistics - Win rate, avg win, avg loss, profit factor, expectancy
// 10. Improved Code Organization - Clear sections for all components
// 11. Entry Price Line - Horizontal dashed line from entry price to current bar
// 12. Real-Time Trade Info Table - Live table showing current trade P&L
// 13. Delete Entry Label on Exit - Remove instead of keeping

indicator("BB RSI Scalping Auto Mode + Enhanced Features", overlay=true, max_labels_count=500, max_lines_count=500)

// ============================================================================
// SECTION: INPUTS
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

// ============================================================================
// SECTION: POSITION STATE VARIABLES (declared early to use in signals)
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

// ============================================================================
// SECTION: CALCULATIONS
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
// SECTION: ENTRY SIGNALS
// ============================================================================

// --- Entry Prices (calculated early for signal use) ---
longEntryPrice =
     entryPriceMode == "Candle Extreme" ? low :
     entryPriceMode == "Bollinger Band" ? lower :
     close

shortEntryPrice =
     entryPriceMode == "Candle Extreme" ? high :
     entryPriceMode == "Bollinger Band" ? upper :
     close

// --- Invalidation Prices (calculated early for signal use) ---
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

// --- Combined Entry Signals ---
longSignal :=
     not inLong and not inShort and
     inSession and
     (reversalLongSignal or midlineLongSignal)

shortSignal :=
     not inLong and not inShort and
     inSession and
     (reversalShortSignal or midlineShortSignal)

// --- Trade Type & Signal Labels ---
longTradeType = midlineLongSignal ? "CONTINUATION" : "REVERSAL"
shortTradeType = midlineShortSignal ? "CONTINUATION" : "REVERSAL"

longSignalType =
     midlineLongSignal ? "MIDLINE CONTINUATION" :
     effectiveMode == "Conservative" ? "AUTO CONSERVATIVE\nBB + RSI + MACD + VOL" :
     effectiveMode == "Balanced" ? "AUTO BALANCED\nBB + RSI + REVERSAL" :
     "AUTO AGGRESSIVE\nBB + RSI"

shortSignalType =
     midlineShortSignal ? "MIDLINE CONTINUATION" :
     effectiveMode == "Conservative" ? "AUTO CONSERVATIVE\nBB + RSI + MACD + VOL" :
     effectiveMode == "Balanced" ? "AUTO BALANCED\nBB + RSI + REVERSAL" :
     "AUTO AGGRESSIVE\nBB + RSI"

entryLabelColor =
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



// --- LONG ENTRY ---
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
    
    activeEntryLabel := label.new(bar_index, low, "BUY\nEntry: " + str.tostring(activeEntryPrice, format.mintick) + "\nInvalid: " + str.tostring(initialInvalidPrice, format.mintick) + "\nDynamic: " + str.tostring(dynamicExitPrice, format.mintick), style=label.style_label_up, color=entryLabelColor, textcolor=color.black, size=size.normal)
    
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
        alert("{\"receivedTime\":\"" + receivedTimeStr + "\",\"eventTime\":\"" + entryTimeStr + "\",\"tradeId\":\"" + activeTradeId + "\",\"event\":\"LONG\",\"ticker\":\"" + syminfo.ticker + "\",\"timeframe\":\"" + timeframe.period + "\",\"tradeType\":\"" + activeTradeType + "\",\"entryPrice\":\"" + str.tostring(activeEntryPrice, format.mintick) + "\",\"exitPrice\":\"\",\"move\":\"\",\"holdDuration\":\"00:00:00\",\"heldBars\":\"\",\"reason\":\"\",\"result\":\"\"}", alert.freq_once_per_bar)

// --- SHORT ENTRY ---
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
    
    activeEntryLabel := label.new(bar_index, high, "SELL\nEntry: " + str.tostring(activeEntryPrice, format.mintick) + "\nInvalid: " + str.tostring(initialInvalidPrice, format.mintick) + "\nDynamic: " + str.tostring(dynamicExitPrice, format.mintick), style=label.style_label_down, color=entryLabelColor, textcolor=color.black, size=size.normal)
    
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
        alert("{\"receivedTime\":\"" + receivedTimeStr + "\",\"eventTime\":\"" + entryTimeStr + "\",\"tradeId\":\"" + activeTradeId + "\",\"event\":\"SHORT\",\"ticker\":\"" + syminfo.ticker + "\",\"timeframe\":\"" + timeframe.period + "\",\"tradeType\":\"" + activeTradeType + "\",\"entryPrice\":\"" + str.tostring(activeEntryPrice, format.mintick) + "\",\"exitPrice\":\"\",\"move\":\"\",\"holdDuration\":\"00:00:00\",\"heldBars\":\"\",\"reason\":\"\",\"result\":\"\"}", alert.freq_once_per_bar)

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

// --- Momentum Exit Signals (CORRECTED RSI 50 CROSS) ---
// Long exits when RSI crosses UNDER 50 (momentum weakening)
// Short exits when RSI crosses OVER 50 (momentum strengthening)
longMomentumReversal = (useHistInflectionExit and macdBearInflection) or (useMacdCrossExit and macdBearCross) or (useRsi50Exit and ta.crossunder(rsi, 50))
shortMomentumReversal = (useHistInflectionExit and macdBullInflection) or (useMacdCrossExit and macdBullCross) or (useRsi50Exit and ta.crossover(rsi, 50))

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

exitLongByType = activeTradeType == "CONTINUATION" ? continuationExitLongByMode : reversalExitLongByMode
exitShortByType = activeTradeType == "CONTINUATION" ? continuationExitShortByMode : reversalExitShortByMode

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

// Determine if trade is fully exited (all targeted TP levels hit or regular exit)
anyTpExitLong = tp1LongExit or tp2LongExit or tp3LongExit
anyTpExitShort = tp1ShortExit or tp2ShortExit or tp3ShortExit

// Full exit conditions
fullExitLong = inLong and (
     exitLongByType or
     hardInvalidLong or
     holdInvalidLong or
     trailingStopLongExit or
     breakEvenLongExit or
     (tp3LongExit and tp2Hit and tp1Hit) or  // Full exit when TP3 hit and previous TPs also hit
     (tp3LongExit and not tp1Hit) or  // Or if TP3 is hit but not TP1 (catches up to TP3)
     (tp2LongExit and tp1Hit)  // Or TP2 hit with TP1 already hit
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

// Partial TP exits (mark as exit but don't close full position yet)
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
    exitModeUsed = activeTradeType == "CONTINUATION" ? continuationExitMode : reversalExitMode
    reason =
         hardInvalidLong ? "INITIAL INVALID" :
         holdInvalidLong ? "DYNAMIC EXIT" :
         trailingStopLongExit ? "TRAILING STOP" :
         breakEvenLongExit ? "BREAK-EVEN" :
         maxHoldingLongExit ? "MAX HOLDING TIME" :
         activeTradeType + " " + exitModeUsed

    labelTitle =
         hardInvalidLong ? "INVALID LONG\nRESET" :
         holdInvalidLong ? "EXIT LONG\nDYNAMIC EXIT" :
         trailingStopLongExit ? "EXIT LONG\nTRAILING STOP" :
         breakEvenLongExit ? "EXIT LONG\nBREAK-EVEN" :
         maxHoldingLongExit ? "EXIT LONG\nMAX TIME" :
         "EXIT LONG\n" + reason

    moveText = str.tostring(longMove, format.mintick)
    result = str.tonumber(moveText) >= 0 ? "WIN" : "LOSS"
    
    // Calculate percentage move
    pctMove = activeEntryPrice > 0 ? (longMove / activeEntryPrice) * 100 : 0
    pctMoveText = str.tostring(pctMove, "#.##") + "%"
    
    // Calculate hold duration in HH:MM:SS format
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
        alert("{\"receivedTime\":\"" + receivedTimeStr + "\",\"eventTime\":\"" + exitTimeStr + "\",\"tradeId\":\"" + activeTradeId + "\",\"event\":\"EXIT\",\"ticker\":\"" + syminfo.ticker + "\",\"timeframe\":\"" + timeframe.period + "\",\"tradeType\":\"" + activeTradeType + "\",\"entryPrice\":\"" + str.tostring(activeEntryPrice, format.mintick) + "\",\"exitPrice\":\"" + str.tostring(longExitPrice, format.mintick) + "\",\"move\":\"" + moveText + "\",\"holdDuration\":\"" + holdDurationText + "\",\"heldBars\":\"" + heldBarsText + "\",\"reason\":\"" + reason + "\",\"result\":\"" + result + "\"}", alert.freq_once_per_bar)

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
    exitModeUsed = activeTradeType == "CONTINUATION" ? continuationExitMode : reversalExitMode
    reason =
         hardInvalidShort ? "INITIAL INVALID" :
         holdInvalidShort ? "DYNAMIC EXIT" :
         trailingStopShortExit ? "TRAILING STOP" :
         breakEvenShortExit ? "BREAK-EVEN" :
         maxHoldingShortExit ? "MAX HOLDING TIME" :
         activeTradeType + " " + exitModeUsed

    labelTitle =
         hardInvalidShort ? "INVALID SHORT\nRESET" :
         holdInvalidShort ? "EXIT SHORT\nDYNAMIC EXIT" :
         trailingStopShortExit ? "EXIT SHORT\nTRAILING STOP" :
         breakEvenShortExit ? "EXIT SHORT\nBREAK-EVEN" :
         maxHoldingShortExit ? "EXIT SHORT\nMAX TIME" :
         "EXIT SHORT\n" + reason

    moveText = str.tostring(shortMove, format.mintick)
    result = str.tonumber(moveText) >= 0 ? "WIN" : "LOSS"
    
    // Calculate percentage move
    pctMove = activeEntryPrice > 0 ? (shortMove / activeEntryPrice) * 100 : 0
    pctMoveText = str.tostring(pctMove, "#.##") + "%"
    
    // Calculate hold duration in HH:MM:SS format
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
        alert("{\"receivedTime\":\"" + receivedTimeStr + "\",\"eventTime\":\"" + exitTimeStr + "\",\"tradeId\":\"" + activeTradeId + "\",\"event\":\"EXIT\",\"ticker\":\"" + syminfo.ticker + "\",\"timeframe\":\"" + timeframe.period + "\",\"tradeType\":\"" + activeTradeType + "\",\"entryPrice\":\"" + str.tostring(activeEntryPrice, format.mintick) + "\",\"exitPrice\":\"" + str.tostring(shortExitPrice, format.mintick) + "\",\"move\":\"" + moveText + "\",\"holdDuration\":\"" + holdDurationText + "\",\"heldBars\":\"" + heldBarsText + "\",\"reason\":\"" + reason + "\",\"result\":\"" + result + "\"}", alert.freq_once_per_bar)

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
// SECTION: WARNING LABELS
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
    
    // Calculate current stop loss (minimum of dynamic exit and any stop level)
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
    
    // Build label text
    warningText = momentumWarning ? "\n⚠️ MOMENTUM WEAKENING" : ""
    
    lastHoldLabel := label.new(bar_index, holdLong ? low : high, holdLong ? "HOLD LONG\nTarget: " + str.tostring(estimatedTarget, format.mintick) + "\nStop: " + str.tostring(currentStop, format.mintick) + warningText : "HOLD SHORT\nTarget: " + str.tostring(estimatedTarget, format.mintick) + "\nStop: " + str.tostring(currentStop, format.mintick) + warningText, style=holdLong ? label.style_label_up : label.style_label_down, color=holdColor, textcolor=color.white, size=size.small)

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
// SECTION: REAL-TIME TRADE INFO TABLE
// ============================================================================

if showRealTimeTradeTable
    if not na(realTimeTradeInfoTable)
        table.delete(realTimeTradeInfoTable)
    
    // Table position - lower left corner
    tablePos = position.bottom_left
    
    // Create table with 3 rows (1 header + 2 data rows)
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

// Create tables
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
````
