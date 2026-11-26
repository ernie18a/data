# Smart Momentum Scanner STRAT

- url: https://www.tradingview.com/script/4wtDEKsl-Smart-Momentum-Scanner-STRAT/
- type: strategy
- pine_id: PUB;39ae84ce090c437e8c6effeaccf79300
- version: 1.0

## Description

# Smart Momentum Scanner STRAT — Support, Reversal & Trend Continuation

**Author: PUNJAB64**

## Overview

Smart Momentum Scanner STRAT is a price-action-based trading strategy designed to identify potential bullish reversals, higher-low formations, and trend-continuation opportunities.

Rather than generating buy signals simply because price touches a support level or crosses a moving average, the strategy follows a structured confirmation process:

**Support → Reversal → Higher Low → Continuation → Momentum Confirmation → Potential Buy**

The strategy combines market structure, exponential moving averages (EMAs), volume confirmation, VWAP, and optional broader-market and sector filters to identify potential long-entry opportunities.

It also incorporates ATR-based stop-loss calculations, risk-based position sizing, and configurable exit rules.

The primary objective is to help traders identify bullish setups with evidence of improving price structure and momentum rather than relying on a single indicator.

## 1. Market Structure: The Foundation

The strategy begins by identifying potential support using confirmed pivot lows.

Once a support level is established, it monitors price for a potential bullish reversal.

A valid reversal requires:

* Price to test the identified support zone.
* A bullish candle to form.
* The candle to close above the previous candle's high.

This combination provides an initial indication that buying pressure may be returning near support.

**Important:** A support touch alone does not trigger a buy signal.

## 2. Higher-Low Confirmation

After a reversal is identified, the strategy waits for a confirmed pivot low above the original support level.

This higher low indicates that price has pulled back without revisiting the previous support level.

The purpose is to identify improving market structure before considering a continuation entry.

The setup is invalidated if price closes below the original support level.

## 3. Breakout and Continuation

Once a higher low is confirmed, the strategy waits for price to close above the high of the original reversal candle.

This is the continuation trigger.

The breakout must then satisfy the strategy's momentum and confirmation filters before a buy signal can be generated.

This approach seeks to avoid entering solely because price rebounds from support, instead waiting for evidence that bullish momentum is continuing.

## 4. EMA Trend and Recovery Filters

The strategy uses four configurable exponential moving averages:

* **EMA 9:** Short-term momentum.
* **EMA 20:** Near-term trend and price recovery.
* **EMA 50:** Intermediate trend direction.
* **EMA 200:** Longer-term trend context.

It identifies two types of bullish conditions.

**Early Recovery BUY**

This setup requires:

* Price above EMA 20.
* EMA 9 above EMA 20.
* EMA 20 rising relative to its value five bars earlier.

It is designed to identify improving momentum before all longer-term trend conditions are established.

**Trend BUY**

This setup requires:

* Price above EMA 200.
* EMA 9 above EMA 20.
* EMA 20 above EMA 50.
* EMA 200 rising relative to its value five bars earlier.

This represents a more established bullish trend structure.

Both setups must satisfy the strategy's remaining entry conditions.

## 5. Volume Confirmation

The strategy compares current volume with its 20-bar average volume.

By default, volume must be at least 1.20 times average volume.

This filter is intended to confirm that the potential entry has sufficient trading activity behind it.

The volume length and confirmation multiplier can be adjusted in the strategy settings.

## 6. VWAP Confirmation

VWAP is enabled as an entry filter by default.

When enabled, the current closing price must be above VWAP for a buy signal to qualify.

This provides an additional price-position confirmation alongside market structure, moving averages, and volume.

VWAP confirmation can be disabled through the settings.

## 7. Optional Market and Sector Confirmation

The strategy includes optional filters for broader-market and sector conditions.

Default reference symbols:

* **SPY:** Broad U.S. equity market.
* **SMH:** Semiconductor sector.

When enabled, the selected market ETF and sector ETF must each trade above their respective 20-period EMAs on the chart's timeframe.

These filters are optional and can be enabled or disabled independently.

The default settings do not require either filter.

Traders should select reference ETFs appropriate for the security and sector being analyzed.

## 8. Risk Management and Position Sizing

Risk management is an integral part of the strategy.

The script calculates position size using account equity, the selected risk percentage, and the estimated distance between the entry price and stop level.

Default risk settings:

* **Risk per trade:** 1% of strategy equity.
* **Maximum position size:** 100% of strategy equity.
* **ATR length:** 14 bars.
* **Maximum stop distance:** 3 ATR.
* **Structure stop buffer:** 0.25 ATR.

When structure-based stops are enabled, the stop is placed below the identified support level, adjusted by the ATR buffer. The stop distance is capped by the configured maximum ATR distance.

If structure-based stops are disabled, the strategy uses an ATR-based stop distance instead.

Position size is limited by both the risk calculation and the maximum position percentage.

These calculations are estimates and do not guarantee that realized losses will remain within the selected risk percentage. Gaps, slippage, liquidity, and execution conditions can cause larger losses.

## 9. Exit Management

The strategy provides several configurable exit mechanisms.

**ATR-Based Stop-Loss**

An initial stop level is calculated using market structure or the ATR-based fallback method.

**EMA 20 Exit**

Enabled by default. The strategy closes a long position when price closes below EMA 20.

**Support-Break Exit**

Optional. When enabled, the strategy closes a long position if price closes below the support level recorded for the trade.

**ATR-Based Take Profit**

Optional and disabled by default. When enabled, the strategy sets a profit target at a configurable ATR multiple above the entry price.

The default target distance is 4 ATR.

**Maximum Holding Period**

Optional and disabled by default. Traders can specify a maximum number of chart bars to hold a position.

These settings allow traders to adapt exit behavior to their preferred trading timeframe and holding period.

## 10. Chart Visuals and Alerts

The strategy plots:

* EMA 9, EMA 20, EMA 50, and EMA 200.
* VWAP.
* Identified support levels.
* Higher-low levels.
* Reversal-candle highs.
* Support and reversal labels.
* Continuation labels.
* Early Recovery BUY and Trend BUY signals.
* Setup invalidation markers.
* Trade entry and exit markers.

A status table displays the current setup state, position status, ATR value, current stop price, and last signal type.

Available alert conditions include:

* Early Recovery BUY.
* Trend BUY.
* Support Invalidated.

Alerts help traders monitor potential setups without continuously watching every chart.

## 11. Configurable Strategy Settings

The script allows users to adjust:

* EMA periods.
* Average-volume length and volume multiplier.
* Pivot confirmation parameters.
* Support-zone tolerance.
* VWAP confirmation.
* Market and sector confirmation.
* Stop-loss calculation method.
* ATR stop buffer and maximum stop distance.
* EMA 20 and support-break exits.
* Take-profit settings.
* Maximum holding period.
* Risk per trade.
* Maximum position allocation.

The default settings are starting parameters, not universally optimal values.

## Intended Use

Smart Momentum Scanner STRAT is designed primarily for traders who prefer structured bullish setups based on support, price action, trend development, and continuation confirmation.

It may be useful for analyzing individual stocks and ETFs across different chart timeframes.

The strategy focuses on long positions. It does not currently implement a short-selling entry system.

Traders should evaluate the strategy on the relevant security and timeframe before using it with real capital.

## Important Limitations

* Confirmed pivot points require subsequent bars, so support and higher-low confirmation are not immediate.
* A bullish signal does not guarantee continuation or profitability.
* EMA, VWAP, and volume filters can delay entries or exclude otherwise valid setups.
* Results can vary substantially by security, timeframe, market regime, and parameter selection.
* Backtest results depend on the strategy's execution assumptions, commissions, and slippage settings.
* Historical performance does not guarantee future results.

This script is an analytical and backtesting tool, not financial advice. Traders are responsible for their own research, risk management, and trading decisions.

**Core principle: Do not buy merely because price touches support. Wait for a reversal, a higher low, a continuation breakout, and the required momentum confirmations.**

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PUNJAB64

//@version=6
strategy("Smart Momentum Scanner STRAT", overlay=true, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=10, commission_type=strategy.commission.percent, commission_value=0.03, slippage=2, calc_on_every_tick=false, process_orders_on_close=true, pyramiding=0, max_labels_count=500)

// =====================================================
// INPUTS
// =====================================================

// EMA
fastEMA  = input.int(9, "Fast EMA")
midEMA   = input.int(20, "Mid EMA")
slowEMA  = input.int(50, "Slow EMA")
trendEMA = input.int(200, "Trend EMA")

// Volume
volLength     = input.int(20, "Average Volume Length")
volMultiplier = input.float(1.20, "Volume Confirmation", step=0.05)

// Market structure
pivotLeft  = input.int(3, "Pivot Left Bars", minval=1)
pivotRight = input.int(3, "Pivot Right Bars", minval=1)

supportTolerance = input.float(1.0, "Support Zone Tolerance %", step=0.1)

// Confirmation
useVWAP = input.bool(true, "Require VWAP")

useMarketConfirmation = input.bool(false, "Require Market Confirmation")
useSectorConfirmation = input.bool(false, "Require Sector Confirmation")

// IMPORTANT: Correct exchanges
marketSymbol = input.symbol("AMEX:SPY", "Market ETF")
sectorSymbol = input.symbol("NASDAQ:SMH", "Sector ETF")

// Exits / sizing
useStructureStop = input.bool(true, "Use Structure Stop")
stopBufferAtr = input.float(0.25, "Stop Buffer ATR", step=0.05)
atrLen = input.int(14, "ATR Length")
maxRiskAtr = input.float(3.0, "Max Risk ATR", step=0.1)
exitOnEma20Loss = input.bool(true, "Exit On EMA20 Loss")
exitOnSupportBreak = input.bool(false, "Exit On Support Break")
useTakeProfit = input.bool(false, "Use Take Profit")
tpAtrMult = input.float(4.0, "TP ATR Mult", step=0.1)
maxBarsInTrade = input.int(0, "Max Bars In Trade", minval=0)
riskPerTradePct = input.float(1.0, "Risk Per Trade %", step=0.1)
maxPositionPct = input.float(100.0, "Max Position %", step=0.1)

// =====================================================
// SERIES CALCULATIONS
// =====================================================

ema9   = ta.ema(close, fastEMA)
ema20  = ta.ema(close, midEMA)
ema50  = ta.ema(close, slowEMA)
ema200 = ta.ema(close, trendEMA)

vwapValue = ta.vwap(close, timeframe.change("1D"))
avgVol = ta.sma(volume, volLength)
volumeConfirmed = volume >= avgVol * volMultiplier
atrValue = ta.atr(atrLen)

marketClose = request.security(marketSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
marketEMA20 = request.security(marketSymbol, timeframe.period, ta.ema(close, 20), barmerge.gaps_off, barmerge.lookahead_off)
sectorClose = request.security(sectorSymbol, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
sectorEMA20 = request.security(sectorSymbol, timeframe.period, ta.ema(close, 20), barmerge.gaps_off, barmerge.lookahead_off)

pivotLow = ta.pivotlow(low, pivotLeft, pivotRight)
pivotHigh = ta.pivothigh(high, pivotLeft, pivotRight)

// =====================================================
// STATE MACHINE
//
// 0 = WAITING FOR SUPPORT
// 1 = REVERSAL FOUND
// 2 = HIGHER LOW FOUND
// 3 = CONTINUATION FOUND
// =====================================================

var int state = 0

// Important structure levels
var float supportLevel = na
var float reversalHigh = na
var float higherLow = na

// Trade state storage
var float setupSupport = na
var float setupAtr = na
var float setupStop = na
var int entryBar = na
var int lastSignalType = 0  // 1 = Early Recovery, 2 = Trend

// =====================================================
// SUPPORT / CONFIRMATION CONDITIONS
// =====================================================

marketConfirmed = not useMarketConfirmation or marketClose > marketEMA20
sectorConfirmed = not useSectorConfirmation or sectorClose > sectorEMA20

// =====================================================
// STATE 0 — FIND SUPPORT
// =====================================================

if state == 0 and not na(pivotLow)
    supportLevel := pivotLow
    reversalHigh := na
    higherLow := na

// =====================================================
// SUPPORT TEST
// =====================================================

supportTest = state == 0 and not na(supportLevel) and low <= supportLevel * (1 + supportTolerance / 100)

// =====================================================
// REVERSAL
//
// Requirements:
// - Price is near support
// - Bullish candle
// - Closes above previous candle high
// =====================================================

bullishCandle = close > open

reversalCondition = supportTest and bullishCandle and close > high[1]

if reversalCondition
    state := 1
    // Freeze the reversal high.
    // We do NOT update this while waiting for the higher low.
    reversalHigh := high

// =====================================================
// HIGHER LOW
//
// After reversal:
// - A confirmed pivot low appears
// - New low must be above original support
// =====================================================

higherLowCondition = state == 1 and not na(pivotLow) and pivotLow > supportLevel

if higherLowCondition
    higherLow := pivotLow
    state := 2

// =====================================================
// CONTINUATION
//
// Price must break the frozen reversal high.
// =====================================================

continuationCondition = state == 2 and not na(reversalHigh) and close > reversalHigh

if continuationCondition
    state := 3

// =====================================================
// TREND CONDITIONS
// =====================================================

establishedTrend = close > ema200 and ema9 > ema20 and ema20 > ema50 and ema200 > ema200[5]

// =====================================================
// EARLY RECOVERY
// =====================================================

earlyRecovery = close > ema20 and ema9 > ema20 and ema20 > ema20[5]

// =====================================================
// TREND PERMISSION
// =====================================================

trendPermission = establishedTrend or earlyRecovery

// =====================================================
// VWAP CONFIRMATION
// =====================================================

vwapConfirmed = not useVWAP or close > vwapValue

// =====================================================
// FINAL BUY
// =====================================================

buySignal = state == 3 and volumeConfirmed and trendPermission and vwapConfirmed and marketConfirmed and sectorConfirmed

// =====================================================
// BUY TYPE
// =====================================================

earlyRecoveryBuy = buySignal and not establishedTrend
trendBuy = buySignal and establishedTrend

// =====================================================
// INVALIDATION
//
// If price closes below support,
// the structure fails.
// =====================================================

supportBroken = state > 0 and not na(supportLevel) and close < supportLevel

if supportBroken
    state := 0
    supportLevel := na
    reversalHigh := na
    higherLow := na

// =====================================================
// POSITION SIZING / ENTRY PRICE STAGING
// =====================================================

stopCandidateRaw = useStructureStop and not na(supportLevel) ? supportLevel - stopBufferAtr * atrValue : close - maxRiskAtr * atrValue
riskDistanceRaw = math.max(close - stopCandidateRaw, syminfo.mintick)
riskDistanceCapped = math.min(riskDistanceRaw, maxRiskAtr * atrValue)
stopDistance = math.max(riskDistanceCapped, syminfo.mintick)
qtyRisk = strategy.equity * (riskPerTradePct / 100.0) / stopDistance
qtyCap = strategy.equity * (maxPositionPct / 100.0) / close
orderQty = math.max(0.0, math.min(qtyRisk, qtyCap))

// =====================================================
// STRATEGY ENTRIES
// =====================================================

if buySignal and strategy.position_size == 0 and orderQty > 0
    setupSupport := supportLevel
    setupAtr := atrValue
    setupStop := math.max(0.0, strategy.position_avg_price)
    entryBar := bar_index
    lastSignalType := earlyRecoveryBuy ? 1 : 2
    strategy.entry("Long", strategy.long, qty=orderQty)
    state := 0
    supportLevel := na
    reversalHigh := na
    higherLow := na

// =====================================================
// POST-ENTRY STATE CAPTURE
// =====================================================

newLong = strategy.position_size > 0 and strategy.position_size[1] == 0
flatNow = strategy.position_size == 0
closedLong = strategy.position_size == 0 and strategy.position_size[1] > 0

if newLong
    entryBar := bar_index
    if na(setupSupport)
        setupSupport := supportLevel
    if na(setupAtr)
        setupAtr := atrValue
    entryPx = strategy.position_avg_price
    rawStop = useStructureStop and not na(setupSupport) ? setupSupport - stopBufferAtr * setupAtr : entryPx - maxRiskAtr * setupAtr
    cappedStop = math.max(rawStop, entryPx - maxRiskAtr * setupAtr)
    setupStop := math.min(cappedStop, entryPx - syminfo.mintick)

if flatNow
    setupSupport := na
    setupAtr := na
    setupStop := na
    entryBar := na

// =====================================================
// EXIT MANAGEMENT
// =====================================================

entryPxLive = strategy.position_avg_price
atrAtEntry = nz(setupAtr, atrValue)
float stopPrice = na
if strategy.position_size > 0
    stopBase = useStructureStop and not na(setupSupport) ? setupSupport - stopBufferAtr * atrAtEntry : entryPxLive - maxRiskAtr * atrAtEntry
    cappedBase = math.max(stopBase, entryPxLive - maxRiskAtr * atrAtEntry)
    stopPrice := math.min(cappedBase, entryPxLive - syminfo.mintick)

float limitPrice = na
if strategy.position_size > 0 and useTakeProfit and not na(entryPxLive)
    limitPrice := entryPxLive + tpAtrMult * atrAtEntry

if strategy.position_size > 0 and not na(stopPrice)
    strategy.exit("Long Exit", from_entry="Long", stop=stopPrice, limit=limitPrice)

if strategy.position_size > 0 and exitOnEma20Loss and close < ema20
    strategy.close("Long", comment="EMA20 Loss")

if strategy.position_size > 0 and exitOnSupportBreak and not na(setupSupport) and close < setupSupport
    strategy.close("Long", comment="Support Break")

if strategy.position_size > 0 and maxBarsInTrade > 0 and not na(entryBar) and bar_index - entryBar >= maxBarsInTrade
    strategy.close("Long", comment="Time Stop")

// =====================================================
// PLOTS
// =====================================================

plot(ema9, title="EMA 9", color=color.blue)
plot(ema20, title="EMA 20", color=color.orange)
plot(ema50, title="EMA 50", color=color.yellow)
plot(ema200, title="EMA 200", color=color.red)
plot(vwapValue, title="VWAP", color=color.white)

plot(supportLevel, title="Support", color=color.new(color.green, 20), style=plot.style_linebr)
plot(higherLow, title="Higher Low", color=color.lime, style=plot.style_linebr)
plot(reversalHigh, title="Reversal High", color=color.orange, style=plot.style_linebr)

// =====================================================
// STRUCTURE LABELS
// =====================================================

plotshape(state == 0 and not na(pivotLow), title="Support Pivot", location=location.belowbar, color=color.blue, style=shape.circle, size=size.tiny, offset=-pivotRight, text="S")
plotshape(reversalCondition, title="Reversal", location=location.belowbar, color=color.orange, style=shape.labelup, text="REV")
plotshape(higherLowCondition, title="Higher Low", location=location.belowbar, color=color.yellow, style=shape.labelup, offset=-pivotRight, text="HL")
plotshape(continuationCondition, title="Continuation", location=location.belowbar, color=color.aqua, style=shape.labelup, text="CONT")
plotshape(earlyRecoveryBuy, title="Early Recovery BUY", location=location.belowbar, color=color.green, style=shape.labelup, size=size.normal, text="BUY\nEARLY")
plotshape(trendBuy, title="Trend BUY", location=location.belowbar, color=color.green, style=shape.labelup, size=size.normal, text="BUY")
plotshape(supportBroken, title="Invalidation", location=location.abovebar, color=color.red, style=shape.labeldown, text="INVALID")

entryMarker = newLong
exitMarker = closedLong
plotshape(entryMarker, title="Entry", location=location.belowbar, color=color.green, style=shape.triangleup, size=size.small, text="IN")
plotshape(exitMarker, title="Exit", location=location.abovebar, color=color.red, style=shape.triangledown, size=size.small, text="OUT")

// =====================================================
// ALERTS
// =====================================================

alertcondition(earlyRecoveryBuy, title="Early Recovery BUY", message="Parmjit Strategy: Support → Reversal → Higher Low → Continuation → Early Recovery BUY")
alertcondition(trendBuy, title="Trend BUY", message="Parmjit Strategy: Support → Reversal → Higher Low → Continuation → Trend BUY")
alertcondition(supportBroken, title="Support Invalidated", message="Parmjit Strategy: Support broken — setup invalidated")

// =====================================================
// STATUS TABLE
// =====================================================

var table statusTable = table.new(position.top_right, 2, 5, border_width=1)
if barstate.islast
    table.cell(statusTable, 0, 0, "State", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(statusTable, 1, 0, str.tostring(state), text_color=color.white)
    table.cell(statusTable, 0, 1, "Position", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(statusTable, 1, 1, strategy.position_size > 0 ? "Long" : strategy.position_size < 0 ? "Short" : "Flat", text_color=color.white)
    table.cell(statusTable, 0, 2, "ATR", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(statusTable, 1, 2, str.tostring(atrValue, format.mintick), text_color=color.white)
    table.cell(statusTable, 0, 3, "Current Stop", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(statusTable, 1, 3, na(stopPrice) ? "na" : str.tostring(stopPrice, format.mintick), text_color=color.white)
    table.cell(statusTable, 0, 4, "Last Signal", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(statusTable, 1, 4, lastSignalType == 1 ? "Early-Recovery" : lastSignalType == 2 ? "Trend" : "None", text_color=color.white)
````
