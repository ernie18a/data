# Rajiv Fibonacci OTE

- url: https://www.tradingview.com/script/lBLsFUKN-Rajiv-Fibonacci-OTE/
- type: indicator
- pine_id: PUB;9de4a1e72c2c428e86c431cd87bd8960
- version: 1.0

## Description

Rajiv Fibonacci OTE RR System

The Rajiv Fibonacci OTE RR System is a smart multi-timeframe trading indicator designed for intraday and swing trading.
It combines Higher Timeframe Fibonacci retracement, OTE (Optimal Trade Entry) zone, and ATR-based Risk Management to generate high-probability BUY and SELL setups with automatic Entry, Stoploss, and Target levels.

Main Features
1. Multi-Timeframe Fibonacci

The script automatically calculates Fibonacci retracement levels from a higher timeframe candle.

Default HTF:

Daily timeframe (D)

Key levels:

0.50
0.618
0.786

These levels help identify:

institutional retracement zones
pullback entries
continuation setups
2. OTE Zone (Optimal Trade Entry)

The indicator highlights the:

0.618 to 0.786 Fibonacci zone

This zone is considered a:

smart money retracement area
institutional entry zone
trend continuation zone

Yellow shaded area visually marks the OTE region.

3. Automatic BUY & SELL Signals
BUY Signal

Generated when:

price crosses above 0.618 Fib level
price remains above 0.50 level
SELL Signal

Generated when:

price crosses below 0.618 Fib level
price remains below 0.50 level

Signals appear directly on chart.

4. ATR-Based Stoploss

The script uses:
SL=Entry±(ATR×Multiplier)

This creates dynamic stoploss levels based on market volatility.

Benefits:

adaptive risk control
works in all market conditions
avoids fixed stoploss problems
5. Risk Reward Targets

The indicator automatically calculates:

Target 1 → Risk Reward 1:2
Target 2 → Risk Reward 1:3
Target 3 → Risk Reward 1:4

Formula:
Target=Entry±(Risk×RR)

This ensures:

proper trade management
disciplined exits
professional risk handling
6. Automatic Lines

The script draws live chart levels for:

Entry
Stoploss
TP 1:2
TP 1:3
TP 1:4

This helps traders visualize:

trade structure
risk zones
reward zones
7. Alerts Included

Built-in TradingView alerts:

BUY Signal
SELL Signal

Useful for:

mobile notifications
automation
scanner setups
Best Timeframes

Recommended:

5 Min
15 Min
30 Min
1 Hour

Best suited for:

NSE Stocks
BankNifty
Nifty
Futures
Intraday Momentum Trading
Trading Style

Works best in:

trending markets
pullback continuation setups
momentum breakout conditions

Avoid during:

extremely sideways markets
low volatility sessions
Strategy Logic

The indicator follows:

Higher timeframe trend
Fibonacci retracement
OTE institutional zone
ATR volatility stoploss
Fixed professional risk reward

## Source Code

````pine
//@version=5
indicator("Rajiv Fibonacci OTE RR System", shorttitle="Rajiv OTE", overlay=true, max_lines_count=100, max_labels_count=100)

// ============================================================================
// INPUTS
// ============================================================================
grp1 = "REFERENCE TIMEFRAME"
htfTF = input.timeframe("D", "HTF Reference", group=grp1)

grp2 = "DISPLAY"
showFib = input.bool(true, "Show Fibonacci", group=grp2)
showOTE = input.bool(true, "Show OTE Zone", group=grp2)
showLabels = input.bool(true, "Show Labels", group=grp2)

grp3 = "RISK MANAGEMENT"
atrLen  = input.int(14, "ATR Length", group=grp3)
atrMult = input.float(1.0, "ATR Multiplier", step=0.1, group=grp3)

rr1 = input.float(2.0, "Target 1 RR", group=grp3)
rr2 = input.float(3.0, "Target 2 RR", group=grp3)
rr3 = input.float(4.0, "Target 3 RR", group=grp3)

// ============================================================================
// HTF DATA
// ============================================================================
[htfHi, htfLo, htfBull] = request.security(
     syminfo.tickerid,
     htfTF,
     [high[1], low[1], close[1] > open[1]],
     barmerge.gaps_off,
     barmerge.lookahead_on)

priceRange = htfHi - htfLo

// ============================================================================
// FIB LEVELS
// ============================================================================
fib50  = htfBull ? htfHi - (0.500 * priceRange) : htfLo + (0.500 * priceRange)
fib618 = htfBull ? htfHi - (0.618 * priceRange) : htfLo + (0.618 * priceRange)
fib786 = htfBull ? htfHi - (0.786 * priceRange) : htfLo + (0.786 * priceRange)

// ============================================================================
// PLOTS
// ============================================================================
plot(showFib ? fib50 : na, color=color.white, linewidth=2, title="0.50")
plot(showFib ? fib618 : na, color=color.yellow, linewidth=2, title="0.618")
plot(showFib ? fib786 : na, color=color.orange, linewidth=2, title="0.786")

p1 = plot(showOTE ? fib618 : na, display=display.none)
p2 = plot(showOTE ? fib786 : na, display=display.none)

fill(p1, p2, color=color.new(color.yellow, 88))

// ============================================================================
// BUY & SELL CONDITIONS
// ============================================================================
buySignal  = ta.crossover(close, fib618) and close > fib50
sellSignal = ta.crossunder(close, fib618) and close < fib50

// ============================================================================
// ATR STOPLOSS
// ============================================================================
atr = ta.atr(atrLen)

buySL  = close - (atr * atrMult)
sellSL = close + (atr * atrMult)

buyRisk  = close - buySL
sellRisk = sellSL - close

// ============================================================================
// TARGETS
// ============================================================================
buyTP1 = close + (buyRisk * rr1)
buyTP2 = close + (buyRisk * rr2)
buyTP3 = close + (buyRisk * rr3)

sellTP1 = close - (sellRisk * rr1)
sellTP2 = close - (sellRisk * rr2)
sellTP3 = close - (sellRisk * rr3)

// ============================================================================
// SIGNALS
// ============================================================================
plotshape(
     buySignal,
     title="BUY",
     text="BUY",
     style=shape.labelup,
     location=location.belowbar,
     color=color.green,
     textcolor=color.white,
     size=size.normal)

plotshape(
     sellSignal,
     title="SELL",
     text="SELL",
     style=shape.labeldown,
     location=location.abovebar,
     color=color.red,
     textcolor=color.white,
     size=size.normal)

// ============================================================================
// LINE VARIABLES
// ============================================================================
var line buyEntryLine = na
var line buySLLine    = na
var line buyTP1Line   = na
var line buyTP2Line   = na
var line buyTP3Line   = na

var line sellEntryLine = na
var line sellSLLine    = na
var line sellTP1Line   = na
var line sellTP2Line   = na
var line sellTP3Line   = na

// ============================================================================
// BUY SETUP
// ============================================================================
if buySignal

    line.delete(buyEntryLine)
    line.delete(buySLLine)
    line.delete(buyTP1Line)
    line.delete(buyTP2Line)
    line.delete(buyTP3Line)

    buyEntryLine := line.new(
         bar_index,
         close,
         bar_index + 25,
         close,
         color=color.green,
         width=3)

    buySLLine := line.new(
         bar_index,
         buySL,
         bar_index + 25,
         buySL,
         color=color.red,
         width=3)

    buyTP1Line := line.new(
         bar_index,
         buyTP1,
         bar_index + 25,
         buyTP1,
         color=color.blue,
         width=2)

    buyTP2Line := line.new(
         bar_index,
         buyTP2,
         bar_index + 25,
         buyTP2,
         color=color.blue,
         width=2)

    buyTP3Line := line.new(
         bar_index,
         buyTP3,
         bar_index + 25,
         buyTP3,
         color=color.blue,
         width=2)

    if showLabels

        label.new(bar_index + 25, close,
             "ENTRY",
             style=label.style_label_left,
             color=color.green,
             textcolor=color.white)

        label.new(bar_index + 25, buySL,
             "SL",
             style=label.style_label_left,
             color=color.red,
             textcolor=color.white)

        label.new(bar_index + 25, buyTP1,
             "TP 1:2",
             style=label.style_label_left,
             color=color.blue,
             textcolor=color.white)

        label.new(bar_index + 25, buyTP2,
             "TP 1:3",
             style=label.style_label_left,
             color=color.blue,
             textcolor=color.white)

        label.new(bar_index + 25, buyTP3,
             "TP 1:4",
             style=label.style_label_left,
             color=color.blue,
             textcolor=color.white)

// ============================================================================
// SELL SETUP
// ============================================================================
if sellSignal

    line.delete(sellEntryLine)
    line.delete(sellSLLine)
    line.delete(sellTP1Line)
    line.delete(sellTP2Line)
    line.delete(sellTP3Line)

    sellEntryLine := line.new(
         bar_index,
         close,
         bar_index + 25,
         close,
         color=color.red,
         width=3)

    sellSLLine := line.new(
         bar_index,
         sellSL,
         bar_index + 25,
         sellSL,
         color=color.green,
         width=3)

    sellTP1Line := line.new(
         bar_index,
         sellTP1,
         bar_index + 25,
         sellTP1,
         color=color.orange,
         width=2)

    sellTP2Line := line.new(
         bar_index,
         sellTP2,
         bar_index + 25,
         sellTP2,
         color=color.orange,
         width=2)

    sellTP3Line := line.new(
         bar_index,
         sellTP3,
         bar_index + 25,
         sellTP3,
         color=color.orange,
         width=2)

    if showLabels

        label.new(bar_index + 25, close,
             "ENTRY",
             style=label.style_label_left,
             color=color.red,
             textcolor=color.white)

        label.new(bar_index + 25, sellSL,
             "SL",
             style=label.style_label_left,
             color=color.green,
             textcolor=color.white)

        label.new(bar_index + 25, sellTP1,
             "TP 1:2",
             style=label.style_label_left,
             color=color.orange,
             textcolor=color.white)

        label.new(bar_index + 25, sellTP2,
             "TP 1:3",
             style=label.style_label_left,
             color=color.orange,
             textcolor=color.white)

        label.new(bar_index + 25, sellTP3,
             "TP 1:4",
             style=label.style_label_left,
             color=color.orange,
             textcolor=color.white)

// ============================================================================
// ALERTS
// ============================================================================
alertcondition(buySignal, title="BUY SIGNAL", message="Rajiv BUY Signal")
alertcondition(sellSignal, title="SELL SIGNAL", message="Rajiv SELL Signal")

// ============================================================================
// WATERMARK
// ============================================================================
if barstate.islast
    label.new(
         bar_index,
         high,
         "RAJIV FIBONACCI OTE SYSTEM",
         style=label.style_label_center,
         color=color.new(color.black, 100),
         textcolor=color.new(color.white, 30),
         size=size.large)
````
