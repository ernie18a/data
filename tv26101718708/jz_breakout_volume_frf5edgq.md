# JZ Breakout Volume

- url: https://www.tradingview.com/script/fRf5eDgq-JZ-Breakout-Volume/
- type: indicator
- pine_id: PUB;d899d9b721e542208c5f98c81f81ca83
- version: 1.0

## Description

# JZ Breakout Volume

**JZ Breakout Volume** is a price-overlay indicator designed to make abnormal volume immediately visible on the chart.

The indicator was built primarily as a **confirmation tool for breakouts and breakdowns**. Rather than relying on visually comparing standard volume bars, it colours price candles when volume is significantly elevated relative to recent trading activity.

## How It Works

The indicator calculates **Relative Volume (RVOL)** by comparing the current candle's volume with the average volume of the previous 20 completed candles:

**RVOL = Current Volume ÷ Average Volume of Previous 20 Candles**

Using relative rather than absolute volume allows the indicator to adapt across different assets and timeframes.

By default:

- **1.5× RVOL** — Elevated participation
- **2.0× RVOL** — Strong participation
- **3.0× RVOL** — Extreme / potentially climactic participation

The indicator also measures **price expansion relative to ATR**.

A candle that produces both **2×+ relative volume and a range of at least 1.25× ATR** receives the strongest bullish or bearish highlighting. This helps distinguish high-volume candles that actually produce meaningful price expansion from candles where substantial volume generates little price movement.

## Candle Colours

Faded green/red indicates elevated volume.

Strong green/red indicates high relative volume.

Bright green/red identifies the primary signal: **strong relative volume combined with meaningful price expansion**.

Purple identifies **extreme relative volume (3×+)**. Extreme volume is intentionally treated separately because exceptionally high volume can represent continuation, climax, absorption, or exhaustion depending on market structure.

## Intended Use

This is **not a standalone entry signal**.

It is designed to provide additional confirmation when price is already presenting a technically valid setup, particularly:

**Consolidation → Higher Low / Lower High → Level or Trendline Break → Volume Expansion**

The objective is simple: make it immediately obvious when genuine market participation arrives during a breakout.

All major thresholds, including volume lookback, RVOL levels, ATR length, and price-expansion requirements, can be customized in the indicator settings.

## Source Code

````pine
//@version=6
indicator("JZ Breakout Volume", shorttitle="JZ Volume", overlay=true)

// ─────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────

// Relative Volume
volLookback = input.int(20, "Volume Average Lookback", minval=5, group="Relative Volume")
elevatedRvol = input.float(1.5, "Elevated Volume (x)", step=0.1, group="Relative Volume")
strongRvol   = input.float(2.0, "Strong Volume (x)", step=0.1, group="Relative Volume")
extremeRvol  = input.float(3.0, "Extreme Volume (x)", step=0.1, group="Relative Volume")

// Price Expansion
atrLength    = input.int(14, "ATR Length", minval=1, group="Price Expansion")
atrThreshold = input.float(1.25, "Expansion Threshold (x ATR)", step=0.05, group="Price Expansion")

// Display
colorElevated = input.bool(true, "Colour Elevated Volume Candles", group="Display")
colorStrong   = input.bool(true, "Colour Strong Volume Candles", group="Display")
colorExpansion = input.bool(true, "Highlight Volume + Price Expansion", group="Display")
colorExtreme  = input.bool(true, "Highlight Extreme Volume", group="Display")

// ─────────────────────────────────────────────────────────────
// CALCULATIONS
// ─────────────────────────────────────────────────────────────

// Average volume from PREVIOUS completed candles.
// Current candle is deliberately excluded.
avgVolume = ta.sma(volume[1], volLookback)

// Relative Volume
rvol = avgVolume > 0 ? volume / avgVolume : na

// ATR
atr = ta.atr(atrLength)

// True Range of current candle
trueRange = ta.tr(true)

// Range relative to ATR
rangeExpansion = atr > 0 ? trueRange / atr : na

// Direction
bullish = close > open
bearish = close < open

// ─────────────────────────────────────────────────────────────
// CONDITIONS
// ─────────────────────────────────────────────────────────────

elevatedVolume = rvol >= elevatedRvol
strongVolume   = rvol >= strongRvol
extremeVolume  = rvol >= extremeRvol

// The key breakout condition:
// Strong relative volume AND meaningful price expansion
breakoutExpansion = strongVolume and rangeExpansion >= atrThreshold

// ─────────────────────────────────────────────────────────────
// COLOURS
// ─────────────────────────────────────────────────────────────

// Default = don't override normal candle colour
color candleColor = na

// Elevated volume
if colorElevated and elevatedVolume
    candleColor := bullish ? color.new(color.lime, 55) : color.new(color.red, 55)

// Strong volume
if colorStrong and strongVolume
    candleColor := bullish ? color.new(color.lime, 25) : color.new(color.red, 25)

// Strong volume + range expansion
if colorExpansion and breakoutExpansion
    candleColor := bullish ? color.lime : color.red

// Extreme volume gets its own colour.
// Purple highlights potential climax / exceptionally abnormal activity.
if colorExtreme and extremeVolume
    candleColor := color.purple

barcolor(candleColor)

// ─────────────────────────────────────────────────────────────
// OPTIONAL DATA WINDOW VALUES
// These don't clutter the chart but let you inspect values.
// ─────────────────────────────────────────────────────────────

plot(rvol, "Relative Volume", display=display.data_window)
plot(rangeExpansion, "Range / ATR", display=display.data_window)

// ─────────────────────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────────────────────

alertcondition(
     breakoutExpansion and bullish,
     title="Bullish High Volume Expansion",
     message="Bullish breakout-style candle: strong relative volume + price expansion."
     )

alertcondition(
     breakoutExpansion and bearish,
     title="Bearish High Volume Expansion",
     message="Bearish breakout-style candle: strong relative volume + price expansion."
     )

alertcondition(
     extremeVolume,
     title="Extreme Relative Volume",
     message="Extreme relative volume detected."
     )
````
