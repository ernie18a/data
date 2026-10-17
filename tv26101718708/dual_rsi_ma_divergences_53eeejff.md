# Dual RSI + MA + Divergences

- url: https://www.tradingview.com/script/53eeeJfF/
- type: indicator
- pine_id: PUB;2e25bb3046484f908404e3b34947c361
- version: 1.0

## Description

# Dual RSI PRO — Indicator Description

## Overview

Dual RSI PRO is an advanced momentum and divergence indicator built around two Relative Strength Index calculations working together in a single oscillator window.

The indicator combines:

* RSI 14 (trend and structure)
* RSI 7 (fast momentum trigger)
* RSI-based Moving Average
* Optional Bollinger Bands on RSI
* Automatic bullish and bearish divergence detection
* Dynamic gradient visualization between both RSI lines
* Alert conditions for all divergences

The purpose of the indicator is to visualize the relationship between short-term momentum and broader market structure.

---

# Core Components

## 1. RSI 14 — Primary Momentum Structure

The 14-period RSI acts as the main trend and momentum reference.

It provides:

* smoother market structure
* trend confirmation
* overbought/oversold context
* divergence validation

Color:

* Purple

---

## 2. RSI 7 — Fast Momentum Trigger

The 7-period RSI reacts much faster to price changes.

It is designed for:

* early reversals
* scalping entries
* short-term momentum shifts
* aggressive divergence detection

Color:

* Orange

Because RSI 7 reacts earlier than RSI 14, it often provides leading signals before the slower RSI confirms the move.

---

# Dynamic Gradient Fill

The space between RSI 7 and RSI 14 is filled dynamically using a gradient color system.

## Green Gradient

Appears when:

* RSI 7 is above RSI 14

Interpretation:

* bullish acceleration
* increasing momentum
* upward pressure strengthening

---

## Red Gradient

Appears when:

* RSI 7 is below RSI 14

Interpretation:

* bearish acceleration
* weakening momentum
* downward pressure strengthening

---

## Gradient Intensity

The strength of the color depends on the distance between both RSI lines.

### Small Distance

* weak transparency
* soft color
* momentum equilibrium

### Large Distance

* strong color
* higher saturation
* momentum expansion

This creates a visual momentum heatmap directly inside the oscillator.

---

# RSI-Based Moving Average

The indicator includes a smoothing system applied directly to RSI 14.

Supported MA types:

* SMA
* EMA
* RMA / SMMA
* WMA
* VWMA
* SMA + Bollinger Bands

The RSI MA helps:

* reduce noise
* identify RSI trend direction
* confirm momentum continuation
* filter false reversals

Color:

* Yellow

---

# Bollinger Bands on RSI

When enabled, Bollinger Bands are calculated around the RSI Moving Average.

Purpose:

* volatility expansion analysis
* RSI compression detection
* momentum breakout zones

Interpretation:

* RSI touching upper band may indicate strong bullish momentum
* RSI touching lower band may indicate strong bearish momentum
* narrowing bands suggest consolidation
* expanding bands suggest volatility growth

---

# Divergence Detection

The indicator automatically detects:

## Bullish Divergence

Price:

* lower low

RSI:

* higher low

Meaning:

* bearish momentum weakening
* possible upward reversal

---

## Bearish Divergence

Price:

* higher high

RSI:

* lower high

Meaning:

* bullish momentum weakening
* possible downward reversal

---

# Divergences for Both RSI Lines

The system calculates divergences separately for:

* RSI 14
* RSI 7

This creates two layers of signal sensitivity.

---

## RSI 14 Divergences

Characteristics:

* slower
* more reliable
* structural reversals
* swing trading quality

Visualization:

* labels

---

## RSI 7 Divergences

Characteristics:

* faster
* earlier
* more aggressive
* better for scalping

Visualization:

* triangles

---

# Alert System

Built-in alerts include:

* RSI 14 bullish divergence
* RSI 14 bearish divergence
* RSI 7 bullish divergence
* RSI 7 bearish divergence

This allows automation and notification workflows inside TradingView.

---

# Typical Trading Interpretation

## Strong Bullish Environment

* RSI 7 above RSI 14
* strong green gradient
* RSI MA sloping upward
* bullish divergences appearing

---

## Strong Bearish Environment

* RSI 7 below RSI 14
* strong red gradient
* RSI MA sloping downward
* bearish divergences appearing

---

## Momentum Compression

* RSI lines close together
* weak gradient
* narrowing Bollinger Bands

Usually indicates:

* consolidation
* low volatility
* possible breakout preparation

---

# Best Use Cases

The indicator works especially well for:

* scalping
* momentum trading
* intraday trading
* reversal detection
* divergence trading
* volatility expansion analysis

Recommended markets:

* Nasdaq
* Crypto
* Forex
* High-volatility instruments

---

# Visual Philosophy

The indicator is designed to work as a “momentum battlefield map.”

Instead of showing only a single RSI line, it visualizes:

* momentum direction
* acceleration
* distance between momentum layers
* structural weakness
* volatility state
* reversal probability

All inside one compact oscillator.

## Source Code

````pine
//@version=6
indicator("Dual RSI + MA + Divergences", shorttitle="Dual RSI PRO", overlay=false, max_labels_count=500)

// =====================================================
// INPUTS
// =====================================================

src = input.source(close, "Source")

rsiLen1 = input.int(14, minval=1, title="RSI 1 Length")
rsiLen2 = input.int(7, minval=1, title="RSI 2 Length")

showDivs = input.bool(true, "Show Divergences")

// =====================================================
// RSI CALCULATIONS
// =====================================================

rsi1 = ta.rsi(src, rsiLen1)
rsi2 = ta.rsi(src, rsiLen2)

// =====================================================
// RSI PLOTS
// =====================================================

plot(rsi1, title="RSI 14", color=na, linewidth=1)
plot(rsi2, title="RSI 7", color=na, linewidth=1)

// =====================================================
// STRONGER GRADIENT FILL
// =====================================================

rsiSpread = math.abs(rsi1 - rsi2)

// mocniejsze reagowanie gradientu
strength = math.min(rsiSpread * 4, 80)

// mniejsza przezroczystość = mocniejszy kolor
transparency = 85 - strength

// ograniczenia
transparency := math.max(5, transparency)

// bardziej nasycone kolory
bullColor = color.rgb(0, 255, 120)
bearColor = color.rgb(255, 40, 40)

fillColor =
     rsi2 > rsi1
     ? color.new(bullColor, transparency)
     : color.new(bearColor, transparency)

// fill plots
rsi1Fill = plot(rsi1, display=display.none)
rsi2Fill = plot(rsi2, display=display.none)

fill(
     rsi1Fill,
     rsi2Fill,
     color=fillColor,
     title="Enhanced RSI Gradient")

// wypełnienie
fill(
     rsi1Fill,
     rsi2Fill,
     color=fillColor,
     title="RSI Spread Gradient")

h70 = hline(70, "Overbought", color=color.rgb(255, 82, 82, 53))
h50 = hline(50, "Middle", color=color.rgb(120, 123, 134, 57))
h30 = hline(30, "Oversold", color=color.rgb(76, 175, 79, 54))

fill(h70, h30, color=color.new(color.purple, 92))

// =====================================================
// RSI-BASED MA
// =====================================================

GRP = "Smoothing"

maTypeInput = input.string(
     "SMA",
     "MA Type",
     options = [
         "None",
         "SMA",
         "SMA + Bollinger Bands",
         "EMA",
         "SMMA (RMA)",
         "WMA",
         "VWMA"
     ],
     group = GRP)

maLengthInput = input.int(14, "MA Length", group=GRP)

bbMultInput = input.float(
     2.0,
     "BB StdDev",
     minval = 0.1,
     step = 0.1,
     group = GRP)

isBB = maTypeInput == "SMA + Bollinger Bands"
enableMA = maTypeInput != "None"

// =====================================================
// MA FUNCTION
// =====================================================

ma(source, length, type) =>
    switch type
        "SMA"                   => ta.sma(source, length)
        "SMA + Bollinger Bands" => ta.sma(source, length)
        "EMA"                   => ta.ema(source, length)
        "SMMA (RMA)"            => ta.rma(source, length)
        "WMA"                   => ta.wma(source, length)
        "VWMA"                  => ta.vwma(source, length)

// =====================================================
// MA CALCULATION
// =====================================================

rsiMA = enableMA ? ma(rsi1, maLengthInput, maTypeInput) : na

bbStdev = isBB
     ? ta.stdev(rsi1, maLengthInput) * bbMultInput
     : na

// =====================================================
// MA PLOTS
// =====================================================

plot(
     rsiMA,
     title="RSI-based MA",
     color=color.rgb(133, 130, 105, 36),
     linewidth=1)

bbUpper = plot(
     isBB ? rsiMA + bbStdev : na,
     title="BB Upper",
     color=color.green)

bbLower = plot(
     isBB ? rsiMA - bbStdev : na,
     title="BB Lower",
     color=color.green)

fill(
     bbUpper,
     bbLower,
     color=color.new(color.green, 90))

// =====================================================
// DIVERGENCE SETTINGS
// =====================================================

lookbackLeft = 5
lookbackRight = 5

// =====================================================
// DIVERGENCE FUNCTIONS
// =====================================================

bullDiv(rsiValue) =>
    plFound = not na(
         ta.pivotlow(
         rsiValue,
         lookbackLeft,
         lookbackRight))

    rsiHL =
         rsiValue[lookbackRight] >
         ta.valuewhen(
         plFound,
         rsiValue[lookbackRight],
         1)

    priceLL =
         low[lookbackRight] <
         ta.valuewhen(
         plFound,
         low[lookbackRight],
         1)

    bullCond =
         priceLL and
         rsiHL and
         plFound

    [bullCond, rsiValue[lookbackRight]]

bearDiv(rsiValue) =>
    phFound = not na(
         ta.pivothigh(
         rsiValue,
         lookbackLeft,
         lookbackRight))

    rsiLH =
         rsiValue[lookbackRight] <
         ta.valuewhen(
         phFound,
         rsiValue[lookbackRight],
         1)

    priceHH =
         high[lookbackRight] >
         ta.valuewhen(
         phFound,
         high[lookbackRight],
         1)

    bearCond =
         priceHH and
         rsiLH and
         phFound

    [bearCond, rsiValue[lookbackRight]]

// =====================================================
// RSI 14 DIVERGENCES
// =====================================================

[bull1, bullRsi1] = bullDiv(rsi1)
[bear1, bearRsi1] = bearDiv(rsi1)

plotshape(
     showDivs and bull1 ? bullRsi1 : na,
     offset=-lookbackRight,
     title="Bull Div RSI14",
     text="14",
     style=shape.labelup,
     location=location.absolute,
     color=color.lime,
     textcolor=color.black,
     size=size.tiny)

plotshape(
     showDivs and bear1 ? bearRsi1 : na,
     offset=-lookbackRight,
     title="Bear Div RSI14",
     text="14",
     style=shape.labeldown,
     location=location.absolute,
     color=color.red,
     textcolor=color.white,
     size=size.tiny)

// =====================================================
// RSI 7 DIVERGENCES
// =====================================================

[bull2, bullRsi2] = bullDiv(rsi2)
[bear2, bearRsi2] = bearDiv(rsi2)

plotshape(
     showDivs and bull2 ? bullRsi2 : na,
     offset=-lookbackRight,
     title="Bull Div RSI7",
     text="7",
     style=shape.triangleup,
     location=location.absolute,
     color=color.aqua,
     size=size.tiny)

plotshape(
     showDivs and bear2 ? bearRsi2 : na,
     offset=-lookbackRight,
     title="Bear Div RSI7",
     text="7",
     style=shape.triangledown,
     location=location.absolute,
     color=color.orange,
     size=size.tiny)

// =====================================================
// ALERTS
// =====================================================

alertcondition(
     bull1,
     title="RSI14 Bullish Divergence",
     message="Bullish divergence on RSI 14")

alertcondition(
     bear1,
     title="RSI14 Bearish Divergence",
     message="Bearish divergence on RSI 14")

alertcondition(
     bull2,
     title="RSI7 Bullish Divergence",
     message="Bullish divergence on RSI 7")

alertcondition(
     bear2,
     title="RSI7 Bearish Divergence",
     message="Bearish divergence on RSI 7")
````
