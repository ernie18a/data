# MSNR + Close-Based QML | Stage 18.9 Minimal

- url: https://www.tradingview.com/script/ixfQDRAf-MSNR-Close-Based-QML-Stage-18-9-Minimal/
- type: indicator
- pine_id: PUB;c0078806e48e410eab57a11388791cf2
- version: 3.0

## Description

# MSNR + Close-Based QML | Multi-Timeframe Structure & Freshness Indicator

## ⚠️ IMPORTANT — 5-MINUTE CHART ONLY

**This indicator is designed exclusively for the 5-minute (M5) chart.**

Although it analyzes multiple higher timeframes, all detected levels, freshness tracking, structural confirmations, and chart displays are designed to operate on the **M5 chart only**.

**Set your TradingView chart to 5 minutes before using this indicator.** Other chart timeframes are not supported.

---

## Overview

MSNR + Close-Based QML is an advanced technical analysis indicator that combines **Multi-Timeframe Support and Resistance (MSNR)** with **Close-Based Quasimodo (QML)** market structure analysis.

The indicator automatically identifies key support and resistance levels, tracks their freshness, detects structural shifts, and highlights potential reaction zones.

Its primary objective is to help traders identify meaningful price levels while maintaining a clean, minimal, and uncluttered chart.

## 1. Multi-Timeframe MSNR Detection

The indicator automatically detects three MSNR structure types:

- **V Levels:** Rejection-based support and resistance structures.
- **A Levels:** Candle-body engulfing structures.
- **OCL Levels:** Levels derived from the relationship between consecutive candle openings and closings.

Supported MSNR source timeframes:

- H4 — 4 Hours
- D1 — Daily
- W1 — Weekly
- MN1 — Monthly

All levels are projected onto the 5-minute chart.

## 2. Freshness Tracking

The indicator continuously evaluates whether each detected level remains fresh.

**FRESH:** The level has not been touched by price since activation.

**UNFRESH:** Price has revisited the level after activation.

Freshness is tracked using 5-minute candle highs and lows, including wick touches.

The indicator prioritizes fresh levels to reduce unnecessary chart clutter.

## 3. RBS and SBR Conversion

The indicator supports H4 support/resistance role conversion using confirmed H1 candle closes.

**RBS — Resistance Becomes Support:** A resistance level is broken upward and subsequently treated as support.

**SBR — Support Becomes Resistance:** A support level is broken downward and subsequently treated as resistance.

After a confirmed conversion, the level's freshness tracking is reset.

## 4. Intelligent MSNR Confluence Clustering

Nearby fresh MSNR levels are grouped using a configurable maximum cluster span.

Rather than plotting every nearby level separately, the indicator identifies a representative level closest to the current market price.

Example:

**4H A F +4**

This represents a fresh H4 A level with four additional levels in its confluence cluster.

The original calculated prices remain unchanged.

Users can configure how many nearby fresh levels are displayed above and below current market price.

## 5. Close-Based Quasimodo (QML)

The QML engine identifies bullish and bearish market structures using closing-price swing points rather than wick-based pivots.

Its detection sequence includes:

1. Left Shoulder
2. Head
3. Confirmed Market Structure Shift (MSS)
4. QML Level Activation

Supported QML source timeframes:

- M5
- M15
- M30
- H1
- H4

All confirmed structures are projected onto the M5 chart.

## 6. QML Shoulder-Body Zones

Instead of displaying QML as a single horizontal line, the indicator highlights the complete candle body of the left shoulder.

**Green zones:** Bullish QML structures.

**Red zones:** Bearish QML structures.

The zones extend toward the right side of the chart, allowing traders to identify potential future interaction areas.

A separate dotted line marks the Head's extreme as a failure or invalidation reference.

## 7. Minimal Chart Display

The indicator is designed to prioritize readability.

Display features include:

- Thin MSNR support and resistance lines.
- Transparent QML zones.
- Small, clean labels.
- Labels positioned toward the right side of the chart.
- Configurable nearest fresh levels.
- Optional QML structure markers.
- Optional MSNR freshness audit.
- Adjustable colors and transparency.

## 8. Customizable Settings

Users can configure:

- MSNR source timeframes and pattern types.
- ATR-based A/V structure filters.
- Freshness and H4 conversion settings.
- MSNR confluence clustering distance.
- Number of fresh levels above and below price.
- QML source timeframes.
- QML swing sensitivity and maximum pattern age.
- QML zone appearance and failure-line visibility.
- Label placement, colors, and transparency.

## Intended Use

This indicator is designed for technical traders who use support and resistance, market structure, and multi-timeframe analysis.

It can assist with identifying potential reaction zones, studying price behavior around fresh levels, and planning trades with defined invalidation references.

It is particularly suited to intraday analysis of **XAU/USD (Gold)**, although its calculations can be applied to other instruments.

## Limitations and Disclaimer

**The indicator must be used on a 5-minute chart.**

MSNR and QML are independent detection systems. Their overlap may provide additional technical confluence but does not automatically confirm a trade.

QML swing confirmation requires subsequent candles, meaning patterns are recognized only after the necessary structure has developed.

Fresh levels are potential areas of interest, not guaranteed reversal points.

This indicator does not provide guaranteed buy or sell signals and should not be used as a standalone trading system.

**Trading involves financial risk. Always use appropriate risk management and independent confirmation.**

## Source Code

````pine
//@version=6
indicator("testing", overlay=true)

// This public version is retired and no longer maintained.
// The author now keeps the indicator private.

var label note = na
if barstate.islast
    label.delete(note)
    note := label.new(bar_index, high, "This public version is retired", style=label.style_label_down)
````
