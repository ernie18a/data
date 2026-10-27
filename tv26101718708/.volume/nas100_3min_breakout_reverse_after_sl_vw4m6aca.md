# NAS100 3-Min Breakout + Reverse After SL

- url: https://www.tradingview.com/script/VW4M6aCA-NAS100-3-Min-Breakout-Reverse-After-SL/
- type: strategy
- pine_id: PUB;805c043c86f14b8bb4cdd9fd79d4472f
- version: 1.0

## Description

# NAS100 3-Minute Lowest Volume Breakout Strategy with Reverse Trade

## Overview
This strategy is designed for the NAS100 index on a 3-minute chart. It combines a lowest-volume candle range, a time-based breakout setup, confirmed swing-point stop-losses, and a risk-to-reward ratio of 1:2.

The strategy identifies the candle with the lowest volume during the 04:00–07:00 New York time session and uses its high and low as key breakout levels. At 09:15 New York time, it evaluates the market for a potential breakout trade.

## Strategy Rules

**1. Lowest-Volume Candle**
- Identifies the lowest-volume candle between 04:00 and 07:00 New York time.
- Highlights the selected candle in yellow.
- Draws the candle's high and low as the breakout range.

**2. Breakout Entry**
- Evaluates the breakout at 09:15 New York time.
- A close above the range high may trigger a BUY.
- A close below the range low may trigger a SELL.
- Entries also require a valid confirmed swing point for stop-loss placement.

**3. Stop-Loss and Take-Profit**
- BUY trade: Stop-loss at the previous confirmed swing low.
- SELL trade: Stop-loss at the previous confirmed swing high.
- Target is set at a 1:2 risk-to-reward ratio.

**4. Reverse Trade After Stop-Loss**
- If the first trade hits its stop-loss, the strategy can attempt one trade in the opposite direction.
- The reverse trade uses the appropriate confirmed swing point for its stop-loss.
- The same 1:2 risk-to-reward ratio applies.

**5. Daily Trade Limit**
- Maximum of two trades per day: one initial trade and one potential reverse trade.
- If the first trade reaches its target, no further trade is taken that day.
- Trading stops for the day after the second trade closes.

## Chart Settings
- **Market:** NAS100
- **Timeframe:** 3 minutes
- **Timezone:** America/New_York
- **Range session:** 04:00–07:00
- **Breakout evaluation:** 09:15 New York time
- **Risk-to-reward:** 1:2

## Important Notes
This script is a technical trading strategy intended for research, chart analysis, and backtesting. Results may vary depending on the broker's NAS100 feed, available volume data, spreads, commissions, slippage, and execution settings.

Historical backtest results do not guarantee future performance. Please test the strategy thoroughly on your selected data feed and use appropriate risk management before considering live trading.

**Disclaimer:** This script is provided for educational and informational purposes only. It is not financial advice or a recommendation to buy or sell any financial instrument. Trading leveraged indices involves substantial risk, and losses can exceed expectations.

## Source Code

````pine

 //@version=6
strategy("NAS100 3-Min Breakout + Reverse After SL", overlay=true, initial_capital=1000000, default_qty_type=strategy.fixed, default_qty_value=1, process_orders_on_close=true, pyramiding=0, max_labels_count=500)

//==================================================
// SETTINGS
//==================================================
string TZ = "America/New_York"
string rangeSession = input.session("0400-0700", "Lowest Volume Window")
int swingLength = input.int(3, "Swing Pivot Length", minval=1)
float riskReward = input.float(2.0, "Risk/Reward", minval=0.1, step=0.1)

color lowVolColor = input.color(color.yellow, "Lowest Volume Candle")
color decisionColor = input.color(color.aqua, "09:00–09:15 Window")
color highColor = input.color(color.lime, "Range High")
color lowColor = input.color(color.red, "Range Low")

//==================================================
// TIMEFRAME CHECK
//==================================================
if barstate.isfirst and (not timeframe.isminutes or timeframe.multiplier != 3)
    runtime.error("Please set the chart timeframe to 3 minutes.")

//==================================================
// NEW YORK DATE
//==================================================
int localDate = year(time, TZ) * 10000 + month(time, TZ) * 100 + dayofmonth(time, TZ)
bool newDay = na(localDate[1]) or localDate != localDate[1]

bool inRange = not na(time(timeframe.period, rangeSession, TZ))
bool inDecisionWindow = hour(time, TZ) == 9 and minute(time, TZ) >= 0 and minute(time, TZ) < 15
bool decisionBar = hour(time_close, TZ) == 9 and minute(time_close, TZ) == 15

//==================================================
// DAILY STATE
//==================================================
var float lowestVolume = na
var float rangeHigh = na
var float rangeLow = na
var int lowestVolumeBar = na

var float previousSwingHigh = na
var float previousSwingLow = na

var int tradesToday = 0
var bool dayDone = false
var bool reversePending = false
var bool firstTradeWasLong = false
var int lastClosedTrades = 0

if newDay
    lowestVolume := na
    rangeHigh := na
    rangeLow := na
    lowestVolumeBar := na
    previousSwingHigh := na
    previousSwingLow := na
    tradesToday := 0
    dayDone := false
    reversePending := false
    firstTradeWasLong := false
    lastClosedTrades := strategy.closedtrades

//==================================================
// LOWEST-VOLUME CANDLE: 04:00–07:00
//==================================================
if inRange and barstate.isconfirmed and not na(volume)
    if na(lowestVolume) or volume < lowestVolume
        lowestVolume := volume
        rangeHigh := high
        rangeLow := low
        lowestVolumeBar := bar_index

//==================================================
// CONFIRMED SWINGS
//==================================================
float pivotHigh = ta.pivothigh(high, swingLength, swingLength)
float pivotLow = ta.pivotlow(low, swingLength, swingLength)

if not na(pivotHigh)
    previousSwingHigh := pivotHigh

if not na(pivotLow)
    previousSwingLow := pivotLow

//==================================================
// CHART DISPLAY
//==================================================
color candleColor = bar_index == lowestVolumeBar ? lowVolColor : inDecisionWindow ? decisionColor : na
barcolor(candleColor, title="Session Highlights")

plotshape(bar_index == lowestVolumeBar, title="Lowest Volume Candle", style=shape.diamond, location=location.abovebar, color=color.yellow, size=size.small)

plot(rangeHigh, title="Range High", color=highColor, linewidth=2, style=plot.style_linebr)
plot(rangeLow, title="Range Low", color=lowColor, linewidth=2, style=plot.style_linebr)

//==================================================
// DETECT CLOSED TRADE AND CHECK EXIT REASON
//==================================================
if strategy.closedtrades > lastClosedTrades
    int closedIndex = strategy.closedtrades - 1
    string exitReason = strategy.closedtrades.exit_comment(closedIndex)

    if tradesToday == 1
        if exitReason == "SL"
            reversePending := true
        else
            dayDone := true
    else
        dayDone := true

    lastClosedTrades := strategy.closedtrades

//==================================================
// FIRST TRADE: 09:15 BREAKOUT
//==================================================
bool canStart = decisionBar and barstate.isconfirmed and not dayDone and not reversePending and tradesToday == 0 and strategy.position_size == 0 and not na(rangeHigh) and not na(rangeLow)

bool buySignal = canStart and close > rangeHigh and not na(previousSwingLow) and previousSwingLow < close
bool sellSignal = canStart and close < rangeLow and not na(previousSwingHigh) and previousSwingHigh > close

if buySignal
    float entryPrice = close
    float stopLoss = previousSwingLow
    float risk = entryPrice - stopLoss
    float takeProfit = entryPrice + risk * riskReward

    if risk > 0
        firstTradeWasLong := true
        strategy.entry("BUY", strategy.long)
        strategy.exit("BUY Exit", from_entry="BUY", stop=stopLoss, limit=takeProfit, comment_loss="SL", comment_profit="TP")
        tradesToday := 1

if sellSignal
    float entryPrice = close
    float stopLoss = previousSwingHigh
    float risk = stopLoss - entryPrice
    float takeProfit = entryPrice - risk * riskReward

    if risk > 0
        firstTradeWasLong := false
        strategy.entry("SELL", strategy.short)
        strategy.exit("SELL Exit", from_entry="SELL", stop=stopLoss, limit=takeProfit, comment_loss="SL", comment_profit="TP")
        tradesToday := 1

//==================================================
// REVERSE TRADE AFTER FIRST TRADE HITS STOP-LOSS
//==================================================
bool canReverse = reversePending and not dayDone and tradesToday == 1 and strategy.position_size == 0 and barstate.isconfirmed

// First trade was BUY and stopped out: reverse to SELL using swing-high SL.
if canReverse and firstTradeWasLong and not na(previousSwingHigh)
    float entryPrice = close
    float stopLoss = previousSwingHigh
    float risk = stopLoss - entryPrice
    float takeProfit = entryPrice - risk * riskReward

    if risk > 0
        strategy.entry("Reverse SELL", strategy.short)
        strategy.exit("Reverse SELL Exit", from_entry="Reverse SELL", stop=stopLoss, limit=takeProfit, comment_loss="SL", comment_profit="TP")
        tradesToday := 2
        reversePending := false

// First trade was SELL and stopped out: reverse to BUY using swing-low SL.
if canReverse and not firstTradeWasLong and not na(previousSwingLow)
    float entryPrice = close
    float stopLoss = previousSwingLow
    float risk = entryPrice - stopLoss
    float takeProfit = entryPrice + risk * riskReward

    if risk > 0
        strategy.entry("Reverse BUY", strategy.long)
        strategy.exit("Reverse BUY Exit", from_entry="Reverse BUY", stop=stopLoss, limit=takeProfit, comment_loss="SL", comment_profit="TP")
        tradesToday := 2
        reversePending := false

//==================================================
// DAILY STOP: NO MORE TRADES AFTER SECOND TRADE
//==================================================
if tradesToday >= 2 and strategy.position_size == 0
    dayDone := true
````
