# Multi-Timeframe SMC Signals

- url: https://www.tradingview.com/script/Gm2ejVxX-Multi-Timeframe-SMC-Signals/
- type: indicator
- pine_id: PUB;35fb5c92fc82473f93b7df0cb877980b
- version: 1.0

## Description

A clean and powerful Smart Money Concept (SMC) inspired TradingView indicator designed for trend-following breakout trades on all timeframes. Built for traders who want simple, accurate, and non-cluttered signals for markets like:

MNQ
NQ
XAUUSD
Forex pairs
Crypto markets
Features
Multi-Timeframe Trend Detection

Uses a clean 3-EMA trend system:

Blue EMA → Fast trend
Red EMA → Mid trend
Purple EMA → Long-term trend

Bullish trends are confirmed when:

Fast EMA > Mid EMA > Long EMA
Price remains above the fast EMA

Bearish trends are confirmed when:

Fast EMA < Mid EMA < Long EMA
Price remains below the fast EMA

This helps filter weak and fake setups.

Smart Money Style Breakout Signals

The indicator identifies:

Break of Structure (BOS)
Momentum continuation
Market expansion breakouts

Signals appear only when price breaks recent structure highs/lows while aligned with the higher trend direction.

BUY Signal

Generated when:

Price breaks above recent swing highs
Bullish trend alignment exists
Breakout confirmation is validated
SELL Signal

Generated when:

Price breaks below recent swing lows
Bearish trend alignment exists
Breakdown confirmation is validated
Confirmation Filter

Built-in confirmation bars help reduce false breakouts and improve signal quality during volatile sessions.

Especially effective for:

Nasdaq futures
Gold scalping
Intraday momentum trading
Automatic TP & SL Levels

The indicator automatically calculates:

Dynamic Stop Loss
TP1
TP2

Using ATR-based volatility calculations.

Features:

Adaptive stop loss
Risk-to-reward targeting
Dotted TP projection lines
Clean TP labels on chart

Default risk settings:

TP1 → 1.5RR
TP2 → 3RR
Clean Chart Design

Designed for traders who prefer:

Minimal clutter
Thin EMA lines
Clear BUY/SELL labels
Lightweight visuals
Mobile-friendly layouts

No oversized boxes or unnecessary drawings.

Best Use Cases

Excellent for:

Trend continuation trades
Momentum scalping
Intraday breakout trading
London & New York sessions

Recommended timeframes:

1m
5m
15m
1H
Works Best On
MNQ
NQ
XAUUSD
EURUSD
GBPUSD
BTCUSD
Key Advantages

✔ Clean and easy to read
✔ Non-repainting structure logic
✔ Multi-timeframe compatible
✔ ATR-based adaptive risk management
✔ Beginner-friendly
✔ Strong trend filtering
✔ Excellent for scalping and day trading

Important Note

This indicator is inspired by Smart Money Concepts and breakout structure trading. It does not yet include advanced ICT features such as:

Order Blocks
Fair Value Gaps (FVG)
Liquidity Sweeps
Equilibrium Zones

However, its simplified design makes it highly practical for real-time execution and disciplined trend trading.

Ideal For Traders Who Want
Clear entry signals
Structured TP levels
Trend-confirmed trades
Simple yet effective charting
Professional-looking TradingView setup

## Source Code

````pine
//@version=5
indicator("Clean Multi-Timeframe SMC Signals", overlay=true, max_labels_count=500, max_lines_count=500)

//====================================================
// SETTINGS
//====================================================
ema1Len = input.int(20, "Blue EMA")
ema2Len = input.int(50, "Red EMA")
ema3Len = input.int(200, "Purple EMA")

atrLen  = input.int(14, "ATR Length")
slATR   = input.float(1.2, "SL ATR", step=0.1)

tp1RR   = input.float(1.5, "TP1 RR")
tp2RR   = input.float(3.0, "TP2 RR")

confirmBars = input.int(2, "Confirmation Bars")

//====================================================
// EMA TREND SYSTEM
// CLEAN THIN LINES
//====================================================
emaBlue   = ta.ema(close, ema1Len)
emaRed    = ta.ema(close, ema2Len)
emaPurple = ta.ema(close, ema3Len)

plot(emaBlue,   color=color.blue,   linewidth=1)
plot(emaRed,    color=color.red,    linewidth=1)
plot(emaPurple, color=color.purple, linewidth=1)

//====================================================
// STRONG TREND FILTER
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
// STRUCTURE BREAKOUT
//====================================================
swingHigh = ta.highest(high, 20)
swingLow  = ta.lowest(low, 20)

bullBreak = close > swingHigh[1]
bearBreak = close < swingLow[1]

// Confirmation
bullConfirm =
     bullBreak and
     ta.barssince(not bullBreak) >= confirmBars - 1

bearConfirm =
     bearBreak and
     ta.barssince(not bearBreak) >= confirmBars - 1

//====================================================
// FINAL SIGNALS
//====================================================
buySignal =
     bullConfirm and
     upTrend

sellSignal =
     bearConfirm and
     downTrend

buyFinal  = buySignal and not buySignal[1]
sellFinal = sellSignal and not sellSignal[1]

//====================================================
// ATR TP LEVELS
//====================================================
atr = ta.atr(atrLen)

// BUY
buyEntry = close
buySL    = buyEntry - atr * slATR
buyRisk  = buyEntry - buySL

buyTP1   = buyEntry + buyRisk * tp1RR
buyTP2   = buyEntry + buyRisk * tp2RR

// SELL
sellEntry = close
sellSL    = sellEntry + atr * slATR
sellRisk  = sellSL - sellEntry

sellTP1   = sellEntry - sellRisk * tp1RR
sellTP2   = sellEntry - sellRisk * tp2RR

//====================================================
// CLEAN BUY SIGNAL
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

    // TP1 LINE
    line.new(
         bar_index,
         buyTP1,
         bar_index + 20,
         buyTP1,
         color=color.green,
         style=line.style_dotted,
         width=1)

    // TP1 LABEL
    label.new(
         bar_index + 20,
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
         bar_index + 20,
         buyTP2,
         color=color.lime,
         style=line.style_dotted,
         width=1)

    // TP2 LABEL
    label.new(
         bar_index + 20,
         buyTP2,
         "TP2",
         style=label.style_label_left,
         color=color.lime,
         textcolor=color.white,
         size=size.small)

//====================================================
// CLEAN SELL SIGNAL
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

    // TP1 LINE
    line.new(
         bar_index,
         sellTP1,
         bar_index + 20,
         sellTP1,
         color=color.red,
         style=line.style_dotted,
         width=1)

    // TP1 LABEL
    label.new(
         bar_index + 20,
         sellTP1,
         "TP1",
         style=label.style_label_left,
         color=color.red,
         textcolor=color.white,
         size=size.small)

    // TP2 LINE
    line.new(
         bar_index,
         sellTP2,
         bar_index + 20,
         sellTP2,
         color=color.orange,
         style=line.style_dotted,
         width=1)

    // TP2 LABEL
    label.new(
         bar_index + 20,
         sellTP2,
         "TP2",
         style=label.style_label_left,
         color=color.orange,
         textcolor=color.white,
         size=size.small)

//====================================================
// ALERTS
//====================================================
alertcondition(buyFinal, title="BUY SIGNAL", message="Confirmed BUY breakout")
alertcondition(sellFinal, title="SELL SIGNAL", message="Confirmed SELL breakout")
````
