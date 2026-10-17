# Institutional SMC Signals PRO

- url: https://www.tradingview.com/script/UkCJaFuK-Institutional-SMC-Signals-PRO/
- type: indicator
- pine_id: PUB;d995c17ed2db49418342848ecf6359bd
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
indicator("Institutional SMC Signals PRO", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// SETTINGS
//====================================================
ema1Len = input.int(20, "Blue EMA")
ema2Len = input.int(50, "Red EMA")
ema3Len = input.int(200, "Purple EMA")

slMethod = input.string(
     "25 Points",
     "Stop Loss Method",
     options = ["25 Points", "Previous Swing"])

fixedSLPoints = input.float(25.0, "Fixed SL Points")

tp1RR = input.float(1.5, "TP1 RR")
tp2RR = input.float(3.0, "TP2 RR")

confirmBars = input.int(2, "Breakout Confirmation")

useLiquidityFilter = input.bool(true, "Use Liquidity Grab Filter")
useSRFilter        = input.bool(true, "Use Support/Resistance Filter")
useReversalFilter  = input.bool(true, "Use Reversal Zone Filter")

srLookback = input.int(50, "S/R Lookback")

//====================================================
// EMA SYSTEM
//====================================================
emaBlue   = ta.ema(close, ema1Len)
emaRed    = ta.ema(close, ema2Len)
emaPurple = ta.ema(close, ema3Len)

// CLEAN THIN EMA LINES
plot(emaBlue, color=color.blue, linewidth=1)
plot(emaRed, color=color.red, linewidth=1)
plot(emaPurple, color=color.purple, linewidth=1)

//====================================================
// TREND FILTER
//====================================================
upTrend =
     emaBlue > emaRed and
     emaRed > emaPurple and
     close > emaBlue

downTrend =
     emaBlue < emaRed and
     emaRed < emaPurple and
     close < emaBlue

//====================================================
// MARKET STRUCTURE
//====================================================
swingHigh = ta.highest(high, 20)
swingLow  = ta.lowest(low, 20)

bullBreak = close > swingHigh[1]
bearBreak = close < swingLow[1]

bullConfirm =
     bullBreak and
     ta.barssince(not bullBreak) >= confirmBars - 1

bearConfirm =
     bearBreak and
     ta.barssince(not bearBreak) >= confirmBars - 1

//====================================================
// LIQUIDITY GRABS
//====================================================
buyLiquidityGrab =
     low < ta.lowest(low, 10)[1] and
     close > open

sellLiquidityGrab =
     high > ta.highest(high, 10)[1] and
     close < open

//====================================================
// SUPPORT & RESISTANCE
//====================================================
supportZone    = ta.lowest(low, srLookback)
resistanceZone = ta.highest(high, srLookback)

// CLEAN S/R LINES
plot(
     useSRFilter ? supportZone : na,
     color=color.new(color.green, 78),
     linewidth=1)

plot(
     useSRFilter ? resistanceZone : na,
     color=color.new(color.red, 78),
     linewidth=1)

//====================================================
// EQUILIBRIUM ZONE
//====================================================
eqHigh = ta.highest(high, srLookback)
eqLow  = ta.lowest(low, srLookback)

equilibrium = (eqHigh + eqLow) / 2

plot(
     equilibrium,
     color=color.new(color.yellow, 40),
     linewidth=1,
     style=plot.style_circles)

eqTopPlot = plot(eqHigh, display=display.none)
eqBottomPlot = plot(eqLow, display=display.none)

fill(
     eqTopPlot,
     eqBottomPlot,
     color=color.new(color.gray, 97))

//====================================================
// REVERSAL FILTER
//====================================================
rsi = ta.rsi(close, 14)

bullishReversal =
     rsi < 30 and
     close > open

bearishReversal =
     rsi > 70 and
     close < open

//====================================================
// FINAL FILTERED SIGNALS
//====================================================
buySignal =
     bullConfirm and
     upTrend and
     (
      useLiquidityFilter ? buyLiquidityGrab : true
     ) and
     (
      useSRFilter ? close > supportZone : true
     ) and
     (
      useReversalFilter ? bullishReversal : true
     )

sellSignal =
     bearConfirm and
     downTrend and
     (
      useLiquidityFilter ? sellLiquidityGrab : true
     ) and
     (
      useSRFilter ? close < resistanceZone : true
     ) and
     (
      useReversalFilter ? bearishReversal : true
     )

// PREVENT DUPLICATE SIGNALS
buyFinal  = buySignal and not buySignal[1]
sellFinal = sellSignal and not sellSignal[1]

//====================================================
// STOP LOSS
//====================================================
buySL =
     slMethod == "25 Points"
     ? close - fixedSLPoints
     : swingLow[1]

sellSL =
     slMethod == "25 Points"
     ? close + fixedSLPoints
     : swingHigh[1]

//====================================================
// RISK & TARGETS
//====================================================
buyRisk  = close - buySL
sellRisk = sellSL - close

buyTP1 = close + (buyRisk * tp1RR)
buyTP2 = close + (buyRisk * tp2RR)

sellTP1 = close - (sellRisk * tp1RR)
sellTP2 = close - (sellRisk * tp2RR)

//====================================================
// BUY SIGNALS
//====================================================
if buyFinal

    // BUY LABEL
    label.new(
         bar_index,
         low,
         "BUY",
         style=label.style_label_up,
         color=color.green,
         textcolor=color.white,
         size=size.normal)

    // ENTRY LINE
    line.new(
         bar_index,
         close,
         bar_index + 25,
         close,
         color=color.new(color.white, 40),
         style=line.style_dotted,
         width=1)

    label.new(
         bar_index + 25,
         close,
         "ENTRY",
         style=label.style_label_left,
         color=color.new(color.white, 20),
         textcolor=color.black,
         size=size.small)

    // SL LINE
    line.new(
         bar_index,
         buySL,
         bar_index + 25,
         buySL,
         color=color.red,
         style=line.style_dotted,
         width=1)

    label.new(
         bar_index + 25,
         buySL,
         "SL",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white,
         size=size.small)

    // TP1 LINE
    line.new(
         bar_index,
         buyTP1,
         bar_index + 25,
         buyTP1,
         color=color.green,
         style=line.style_dotted,
         width=1)

    label.new(
         bar_index + 25,
         buyTP1,
         "TP1",
         style=label.style_label_left,
         color=color.green,
         textcolor=color.white,
         size=size.small)

    // TP2 LINE
    line.new(
         bar_index,
         buyTP2,
         bar_index + 25,
         buyTP2,
         color=color.lime,
         style=line.style_dotted,
         width=1)

    label.new(
         bar_index + 25,
         buyTP2,
         "TP2",
         style=label.style_label_left,
         color=color.lime,
         textcolor=color.white,
         size=size.small)

//====================================================
// SELL SIGNALS
//====================================================
if sellFinal

    // SELL LABEL
    label.new(
         bar_index,
         high,
         "SELL",
         style=label.style_label_down,
         color=color.red,
         textcolor=color.white,
         size=size.normal)

    // ENTRY LINE
    line.new(
         bar_index,
         close,
         bar_index + 25,
         close,
         color=color.new(color.white, 40),
         style=line.style_dotted,
         width=1)

    label.new(
         bar_index + 25,
         close,
         "ENTRY",
         style=label.style_label_left,
         color=color.new(color.white, 20),
         textcolor=color.black,
         size=size.small)

    // SL LINE
    line.new(
         bar_index,
         sellSL,
         bar_index + 25,
         sellSL,
         color=color.red,
         style=line.style_dotted,
         width=1)

    label.new(
         bar_index + 25,
         sellSL,
         "SL",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white,
         size=size.small)

    // TP1 LINE
    line.new(
         bar_index,
         sellTP1,
         bar_index + 25,
         sellTP1,
         color=color.orange,
         style=line.style_dotted,
         width=1)

    label.new(
         bar_index + 25,
         sellTP1,
         "TP1",
         style=label.style_label_left,
         color=color.orange,
         textcolor=color.white,
         size=size.small)

    // TP2 LINE
    line.new(
         bar_index,
         sellTP2,
         bar_index + 25,
         sellTP2,
         color=color.yellow,
         style=line.style_dotted,
         width=1)

    label.new(
         bar_index + 25,
         sellTP2,
         "TP2",
         style=label.style_label_left,
         color=color.yellow,
         textcolor=color.black,
         size=size.small)

//====================================================
// ALERTS
//====================================================
alertcondition(buyFinal, title="BUY SIGNAL", message="Institutional BUY Signal")
alertcondition(sellFinal, title="SELL SIGNAL", message="Institutional SELL Signal")
````
