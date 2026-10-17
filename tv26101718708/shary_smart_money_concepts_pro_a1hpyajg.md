# Shary Smart Money Concepts PRO

- url: https://www.tradingview.com/script/a1hPyAJg-Shary-Smart-Money-Concepts-PRO/
- type: indicator
- pine_id: PUB;d6ece996c16b4c4691ab09c34dbc0b53
- version: 1.0

## Description

Institutional SMC Signals PRO

A professional-grade Smart Money Concept (SMC) inspired TradingView indicator designed for traders who want clean institutional-style breakout confirmations, liquidity grab detection, trend filtering, and automatic TP/SL projections.

Built for:

MNQ
NQ
XAUUSD
Forex markets
Crypto trading
Scalping and intraday trading
Core Features
Institutional Trend Engine

The indicator uses a powerful 3-EMA institutional trend filter:

Blue EMA → Fast momentum
Red EMA → Market direction
Purple EMA → Long-term bias
Bullish Trend

A bullish market is confirmed when:

Blue EMA > Red EMA > Purple EMA

and price remains above the fast EMA.

Bearish Trend

A bearish market is confirmed when:

Blue EMA < Red EMA < Purple EMA

and price remains below the fast EMA.

This helps remove low-quality countertrend entries.

Smart Money Structure Breakouts

The indicator detects:

Break of Structure (BOS)
Trend continuation breakouts
Institutional momentum shifts

Using recent swing highs and lows:

Highest High = Resistance
Lowest Low = Support
BUY Signals

BUY signals appear when:

Price breaks above previous structure highs
Trend alignment is bullish
Breakout confirmation is validated
Additional SMC filters agree
SELL Signals

SELL signals appear when:

Price breaks below previous structure lows
Trend alignment is bearish
Breakdown confirmation is validated
Smart filters confirm weakness
Liquidity Grab Detection

One of the advanced institutional features included in this indicator.

The script attempts to detect:

Buy-side liquidity sweeps
Sell-side liquidity sweeps
Bullish Liquidity Grab

Occurs when:

Price sweeps previous lows
Buyers aggressively reclaim price
Bearish Liquidity Grab

Occurs when:

Price sweeps previous highs
Sellers reject higher prices

This helps identify:

Stop hunts
Fake breakouts
Institutional reversals
Support & Resistance Filter

The indicator automatically plots:

Dynamic support
Dynamic resistance

These zones act as:

Institutional reaction areas
Market decision points
Trend continuation zones

Signals are filtered to avoid trades directly into major support or resistance.

Reversal Zone Filter

Uses RSI-based reversal logic to identify potential exhaustion areas.

Bullish Reversal Zone

Triggered when:

RSI is oversold
Bullish candle forms
Bearish Reversal Zone

Triggered when:

RSI is overbought
Bearish candle forms

This improves signal quality during:

Market reversals
Pullback entries
Momentum shifts
Intelligent Stop Loss System

The indicator includes two stop loss modes:

Fixed Point Stop Loss

Example:

25-point stop for Nasdaq scalping

Best for:

Fast execution
Futures trading
Consistent risk models
Previous Swing Stop Loss

Places stop behind:

Previous swing low (BUY)
Previous swing high (SELL)

Best for:

Smart Money trading
Swing structure protection
Institutional positioning
Automatic TP1 & TP2 Targets

The indicator calculates dynamic targets using Risk:Reward logic.

Default settings:

TP1 → 1.5RR
TP2 → 3RR

Formula:

TP=Entry±(Risk×RR)

This creates:

Structured exits
Partial profit-taking
Better trade management
Visual Design

Designed to remain:

Clean
Professional
Easy to read
Mobile-friendly
Includes

✔ Thin EMA lines
✔ BUY / SELL labels
✔ SL labels
✔ TP1 / TP2 labels
✔ Dotted target lines
✔ Support & resistance overlays

No excessive chart clutter.

Best Timeframes
Scalping
1 Minute
3 Minute
5 Minute
Intraday Trading
15 Minute
1 Hour
Best Markets

Excellent performance on:

MNQ
NQ
XAUUSD

Also works well on:

BTCUSD
EURUSD
GBPUSD
Key Advantages

✔ Institutional-style breakout logic
✔ Liquidity sweep filtering
✔ Trend confirmation system
✔ Automatic TP & SL plotting
✔ Beginner-friendly visual design
✔ Multi-timeframe compatibility
✔ Support & resistance filtering
✔ Reversal zone detection
✔ Non-repainting structure conditions

Important Notes

This indicator is inspired by:

ICT concepts
Smart Money trading
Institutional breakout logic

It is not a fully automated institutional algorithm and does not yet include:

Order Blocks
Fair Value Gaps (FVG)
Volume profile
Session kill zones
Premium/discount arrays

However, it combines several high-probability concepts into one clean and practical trading system.

Ideal For Traders Who Want
Institutional-style entries
Clean TradingView charts
Smart breakout confirmations
TP & SL automation
Trend-following scalping
Structured risk management
Simple but powerful SMC tools
Overall Summary

Institutional SMC Signals PRO is a clean institutional-style breakout indicator combining:

Smart trend filtering
Liquidity sweeps
Structure breakouts
Reversal zones
Support/resistance analysis
Automatic risk management

Designed for traders who want professional-looking Smart Money signals without overwhelming chart clutter.

## Source Code

````pine

//@version=5
indicator("LuxAlgo Style Smart Money Concepts PRO", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// SETTINGS
//====================================================
showBOS      = input.bool(true,  "Show BOS")
showCHOCH    = input.bool(true,  "Show CHOCH")
showFVG      = input.bool(true,  "Show Fair Value Gap")
showSignals  = input.bool(true,  "Show Buy/Sell Signals")

swingLen     = input.int(5, "Swing Length", minval=2)
rr           = input.float(2.0, "Risk Reward", step=0.1)

atrLen        = input.int(14, "ATR Length")
atrMultiplier = input.float(1.2, "SL ATR Multiplier", step=0.1)

//====================================================
// EMA TREND FILTER
//====================================================
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

plot(ema20,  color=color.blue,   linewidth=2)
plot(ema50,  color=color.red,    linewidth=2)
plot(ema200, color=color.purple, linewidth=2)

//====================================================
// SWING HIGHS & LOWS
//====================================================
swingHigh = ta.pivothigh(high, swingLen, swingLen)
swingLow  = ta.pivotlow(low, swingLen, swingLen)

var float lastHigh = na
var float lastLow  = na

if not na(swingHigh)
    lastHigh := swingHigh

if not na(swingLow)
    lastLow := swingLow

//====================================================
// BOS & CHOCH
//====================================================
bullBOS = close > lastHigh and close[1] <= lastHigh
bearBOS = close < lastLow  and close[1] >= lastLow

bullCHOCH = bullBOS and ema20 > ema50
bearCHOCH = bearBOS and ema20 < ema50

//====================================================
// FAIR VALUE GAP
//====================================================
bullFVG = low > high[2]
bearFVG = high < low[2]

if showFVG and bullFVG
    box.new(
         left=bar_index-2,
         right=bar_index,
         top=low,
         bottom=high[2],
         bgcolor=color.new(color.green, 85),
         border_color=color.new(color.green, 50)
     )

if showFVG and bearFVG
    box.new(
         left=bar_index-2,
         right=bar_index,
         top=low[2],
         bottom=high,
         bgcolor=color.new(color.red, 85),
         border_color=color.new(color.red, 50)
     )

//====================================================
// BOS LABELS
//====================================================
if showBOS and bullBOS
    label.new(
         bar_index,
         high,
         "BOS",
         style=label.style_label_down,
         color=color.green,
         textcolor=color.white,
         size=size.small
     )

if showBOS and bearBOS
    label.new(
         bar_index,
         low,
         "BOS",
         style=label.style_label_up,
         color=color.red,
         textcolor=color.white,
         size=size.small
     )

//====================================================
// CHOCH LABELS
//====================================================
if showCHOCH and bullCHOCH
    label.new(
         bar_index,
         high,
         "CHOCH",
         style=label.style_label_down,
         color=color.lime,
         textcolor=color.black,
         size=size.small
     )

if showCHOCH and bearCHOCH
    label.new(
         bar_index,
         low,
         "CHOCH",
         style=label.style_label_up,
         color=color.orange,
         textcolor=color.white,
         size=size.small
     )

//====================================================
// BUY / SELL SIGNALS
//====================================================
atr = ta.atr(atrLen)

buySignal =
     bullCHOCH and
     bullFVG and
     close > ema200

sellSignal =
     bearCHOCH and
     bearFVG and
     close < ema200

//====================================================
// BUY SETUP
//====================================================
if showSignals and buySignal
    entryPrice = close
    stopLoss   = low - (atr * atrMultiplier)
    takeProfit = entryPrice + ((entryPrice - stopLoss) * rr)

    // BUY LABEL
    label.new(
         bar_index,
         low,
         "BUY",
         style=label.style_label_up,
         color=color.lime,
         textcolor=color.black,
         size=size.normal
     )

    // SL LABEL
    label.new(
         bar_index,
         stopLoss,
         "SL",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.small
     )

    // TP LABEL
    label.new(
         bar_index,
         takeProfit,
         "TP",
         style=label.style_label_down,
         color=color.green,
         textcolor=color.white,
         size=size.small
     )

    // LINES
    line.new(bar_index, entryPrice, bar_index + 10, entryPrice, color=color.green, width=2)
    line.new(bar_index, stopLoss, bar_index + 10, stopLoss, color=color.red, width=2)
    line.new(bar_index, takeProfit, bar_index + 10, takeProfit, color=color.blue, width=2)

//====================================================
// SELL SETUP
//====================================================
if showSignals and sellSignal
    entryPrice = close
    stopLoss   = high + (atr * atrMultiplier)
    takeProfit = entryPrice - ((stopLoss - entryPrice) * rr)

    // SELL LABEL
    label.new(
         bar_index,
         high,
         "SELL",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.normal
     )

    // SL LABEL
    label.new(
         bar_index,
         stopLoss,
         "SL",
         style=label.style_label_up,
         color=color.red,
         textcolor=color.white,
         size=size.small
     )

    // TP LABEL
    label.new(
         bar_index,
         takeProfit,
         "TP",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.small
     )

    // LINES
    line.new(bar_index, entryPrice, bar_index + 10, entryPrice, color=color.red, width=2)
    line.new(bar_index, stopLoss, bar_index + 10, stopLoss, color=color.red, width=2)
    line.new(bar_index, takeProfit, bar_index + 10, takeProfit, color=color.blue, width=2)

//====================================================
// ALERTS
//====================================================
alertcondition(buySignal, title="BUY SIGNAL", message="Smart Money BUY Signal")
alertcondition(sellSignal, title="SELL SIGNAL", message="Smart Money SELL Signal")
````
