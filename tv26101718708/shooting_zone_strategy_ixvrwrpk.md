# Shooting Zone Strategy

- url: https://www.tradingview.com/script/ixvRWRpK/
- type: indicator
- pine_id: PUB;bf3ecdb105194faaba2eadf86df177e0
- version: 1.0

## Description

📊 Shooting Zone Strategy (EMA Rejection + High Quality Price Action)
🧠 Overview
This indicator is a trend-based price action system that combines:
	• EMA trend direction 
	• EMA interaction (liquidity zone behavior) 
	• High-quality candlestick rejection patterns 
	• Engulfing confirmations 
	• Simple order lifecycle tracking (signal → activation → cancellation) 
The goal is to identify institutional-style pullbacks and reversals with reduced market noise.

📈 Trend Filter
The system uses two EMAs:
	• 🟢 Fast EMA (green) 
	• 🟣 Slow EMA (purple) 
Trend conditions:
	• Bullish trend: Fast EMA > Slow EMA 
	• Bearish trend: Fast EMA < Slow EMA 
Signals are only valid in the direction of the trend.

📍 EMA Interaction Zone
Price is monitored for interaction with dynamic EMA levels:
	• Fast EMA touch 
	• Slow EMA touch 
	• EMA zone interaction (liquidity area between both EMAs) 
This helps detect reaction points instead of random candles.

🟢 BUY Logic (Low Test Bar)
A BUY setup is triggered when price shows bullish rejection inside a bullish trend.
Conditions:
	• Bullish trend (Fast EMA above Slow EMA) 
	• Price interacts with EMA zone 
	• Valid bullish rejection candle OR bullish engulfing confirmation 
	• EMA touch confirmation 
Candle requirements:
	• Long lower wick (liquidity sweep below) 
	• Small upper wick 
	• Body closes near highs 
Interpretation:
Price sweeps downside liquidity into EMA zone and strongly rejects upward → potential continuation of bullish trend.

🔴 SELL Logic (High Test Bar)
A SELL setup is triggered when price shows bearish rejection inside a bearish trend.
Conditions:
	• Bearish trend (Fast EMA below Slow EMA) 
	• Price interacts with EMA zone 
	• Valid bearish rejection candle OR bearish engulfing confirmation 
	• EMA touch confirmation 
Candle requirements:
	• Long upper wick (liquidity sweep above) 
	• Small lower wick 
	• Body closes near lows 
Interpretation:
Price sweeps upside liquidity into EMA zone and rejects downward → potential continuation of bearish trend.

🔄 Order Lifecycle Tracking
Each signal is tracked through a simple lifecycle:
1. 📍 Signal
A BUY/SELL setup appears on the chart.
2. ⚡ Activation
Order is considered active if the next candle breaks the entry level.
3. ❌ Cancellation
Order is cancelled if:
	• it does not activate on the next candle 
	• AND price invalidates the setup (moves against structure) 

📊 Risk Management
For every setup:
	• Entry is placed beyond signal candle 
	• Stop Loss is placed beyond candle extreme 
	• Take Profit is fixed at 1:1 Risk/Reward 
This ensures consistent risk modeling across all trades.

🔔 Alerts
The system provides 3 levels of alerts:
📍 Setup Alerts
	• BUY SIGNAL 
	• SELL SIGNAL 
⚡ Execution Alerts
	• BUY ORDER ACTIVATED 
	• SELL ORDER ACTIVATED 
❌ Invalid Alerts
	• BUY ORDER CANCELLED 
	• SELL ORDER CANCELLED 

🎯 How to Use
1. Trend Alignment
Only take:
	• BUY signals in bullish trend 
	• SELL signals in bearish trend 

2. Wait for Quality Setup
Do NOT trade every signal.
Prefer setups where:
	• wick is strong (clear rejection) 
	• engulfing confirmation appears 
	• price clearly interacts with EMAs
	• you can see clear trending structure ledaing to the signal


3. Confirmation Flow
Best workflow:
	1. Signal appears (alert) 
	2. Wait for next candle activation 
	3. If not activated/hit SL without activation within the next time frame selection → ignore (cancelled setup) 

4. Risk Rules
	• Always respect SL level 
	• Take profit is fixed at 1:1 RR 
	• Avoid overtrading low-quality signals 

⚠️ Key Concept
This system is not a prediction tool.
It is a reaction-based liquidity model:
	• EMA acts as dynamic liquidity zone 
	• Candles represent rejection behavior 
	• Signals represent imbalance shifts 

🚀 Summary
This strategy focuses on:
	• Trend following via EMAs 
	• Liquidity-based candle rejection 
	• High-probability engulfing confirmation 
Structured order validation (signal → activation → invalidation)

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © The_stopless_trader

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
//@version=6
indicator("Shooting Zone Strategy", overlay=true)

// ======================================================
// INPUTS
// ======================================================

fastLen = input.int(20, "Fast EMA (Green)")
slowLen = input.int(50, "Slow EMA (Purple)")

showBuy = input.bool(true, "Show Buy Setups")
showSell = input.bool(true, "Show Sell Setups")

// ======================================================
// EMA
// ======================================================

fastEMA = ta.ema(close, fastLen)
slowEMA = ta.ema(close, slowLen)

plot(fastEMA, color=color.green, linewidth=2)
plot(slowEMA, color=color.purple, linewidth=2)

// Trend
bullTrend = fastEMA > slowEMA
bearTrend = fastEMA < slowEMA

// ======================================================
// EMA TOUCH LOGIC
// ======================================================

touchFast = high >= fastEMA and low <= fastEMA
touchSlow = high >= slowEMA and low <= slowEMA
touchZone = touchFast or touchSlow

// ======================================================
// CANDLE COMPONENTS
// ======================================================

bodyTop = math.max(open, close)
bodyBottom = math.min(open, close)

candleRange = high - low
upperWick = high - bodyTop
lowerWick = bodyBottom - low

validRange = candleRange > 0

bodySize = math.abs(close - open)
bodySmall = bodySize <= candleRange * 0.35

// ======================================================
// 🔥 IMPROVED CANDLE QUALITY (HAMMER)
// ======================================================

validBuyCandle = (
    lowerWick >= candleRange * 0.55 and
    upperWick <= candleRange * 0.20 and
    bodySmall and
    bodyTop >= low + candleRange * 0.60
)

validSellCandle = (
    upperWick >= candleRange * 0.55 and
    lowerWick <= candleRange * 0.20 and
    bodySmall and
    bodyBottom <= low + candleRange * 0.40
)
// ======================================================
// 🔥 ENGULFING + EMA CONFIRMATION
// ======================================================

bullEngulf = (
    close > open and
    close[1] < open[1] and
    close > open[1] and
    open < close[1]
)
bearEngulf = (
    close < open and
    close[1] > open[1] and
    close < open[1] and
    open > close[1]
)
// EMA requirement for engulfing
bullEngulfValid = bullEngulf and (low <= fastEMA or low <= slowEMA)
bearEngulfValid = bearEngulf and (high >= fastEMA or high >= slowEMA)

// ======================================================
// BUY - LOW TEST BAR (ENHANCED)
// ======================================================

lowTestBar = (
    bullTrend and
    touchZone and
    validRange and
    (
        validBuyCandle or
        bullEngulfValid
    ) and
    (low <= fastEMA or low <= slowEMA)
)

// ======================================================
// SELL - HIGH TEST BAR (ENHANCED)
// ======================================================

highTestBar = (
    bearTrend and
    touchZone and
    validRange and
    (
        validSellCandle or
        bearEngulfValid
    ) and
    (high >= fastEMA or high >= slowEMA)
)

// ======================================================
// ORDER TRACKING (SAFE VERSION)
// ======================================================

buySignal  = lowTestBar
sellSignal = highTestBar

nextHigh = high
nextLow  = low

buyEntryLevel  = high[1] + syminfo.mintick
sellEntryLevel = low[1] - syminfo.mintick

buyActivated = buySignal[1] and nextHigh >= buyEntryLevel
buyCancelled = buySignal[1] and not buyActivated and nextLow < low[1]

sellActivated = sellSignal[1] and nextLow <= sellEntryLevel
sellCancelled = sellSignal[1] and not sellActivated and nextHigh > high[1]

// ======================================================
// ENTRY LOGIC
// ======================================================

buyEntry = high + syminfo.mintick
buySL = low - syminfo.mintick
buyTP = buyEntry + (buyEntry - buySL)

sellEntry = low - syminfo.mintick
sellSL = high + syminfo.mintick
sellTP = sellEntry - (sellSL - sellEntry)

// ======================================================
// PLOTS
// ======================================================

plotshape(showBuy and lowTestBar,
     title="BUY Low Test Bar",
     location=location.belowbar,
     color=color.lime,
     style=shape.triangleup,
     text="BUY")

plotshape(showSell and highTestBar,
     title="SELL High Test Bar",
     location=location.abovebar,
     color=color.red,
     style=shape.triangledown,
     text="SELL")

// ======================================================
// LEVELS
// ======================================================

if lowTestBar
    line.new(bar_index, buyEntry, bar_index + 1, buyEntry, color=color.lime, width=2)
    line.new(bar_index, buySL, bar_index + 1, buySL, color=color.red)
    line.new(bar_index, buyTP, bar_index + 1, buyTP, color=color.blue)

if highTestBar
    line.new(bar_index, sellEntry, bar_index + 1, sellEntry, color=color.red, width=2)
    line.new(bar_index, sellSL, bar_index + 1, sellSL, color=color.orange)
    line.new(bar_index, sellTP, bar_index + 1, sellTP, color=color.blue)

// ======================================================
// BACKGROUND
// ======================================================

bgcolor(bullTrend ? color.new(color.green, 92) :
       bearTrend ? color.new(color.red, 92) :
       na)

// ======================================================
// ALERTS
// ======================================================

alertcondition(showBuy and lowTestBar, title="BUY SIGNAL", message="BUY Low Test Bar detected")
alertcondition(showSell and highTestBar, title="SELL SIGNAL", message="SELL High Test Bar detected")

alertcondition(buyActivated, title="BUY ORDER ACTIVATED", message="BUY order activated")
alertcondition(buyCancelled, title="BUY ORDER CANCELLED", message="BUY order cancelled")

alertcondition(sellActivated, title="SELL ORDER ACTIVATED", message="SELL order activated")
alertcondition(sellCancelled, title="SELL ORDER CANCELLED", message="SELL order cancelled")
````
