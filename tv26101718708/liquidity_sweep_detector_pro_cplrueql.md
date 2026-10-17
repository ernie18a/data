# Liquidity Sweep Detector Pro

- url: https://www.tradingview.com/script/cplrUeQl-Liquidity-Sweep-Detector-Pro/
- type: indicator
- pine_id: PUB;56023b14fed64d429ea8981196e834a0
- version: 3.0

## Description

[b]Liquidity Sweep Detector Pro[/b] is an advanced Smart Money Concepts (SMC) indicator designed to identify areas where liquidity is likely resting and detect potential buy-side and sell-side liquidity sweeps. The indicator combines equal highs/lows, market structure, and trend analysis to help traders recognize high-probability reversal and continuation zones.

Unlike traditional support and resistance indicators, this tool focuses on liquidity behavior created by stop-loss clusters around swing highs and swing lows.

### Features

• Automatic Equal High (EQH) Detection

• Automatic Equal Low (EQL) Detection

• Buy-Side Liquidity (BSL) Sweep Detection

• Sell-Side Liquidity (SSL) Sweep Detection

• Dynamic Liquidity Levels

• Automatic Liquidity Level Removal After Sweep

• EMA Trend Filter

• Market Bias Dashboard

• Clean Chart Visualization

• Non-Repainting Logic

### How It Works

The indicator continuously scans recent market structure to locate equal highs and equal lows where liquidity is commonly accumulated.

When price moves above an Equal High and quickly closes back below it, the indicator identifies a Buy-Side Liquidity Sweep.

When price moves below an Equal Low and closes back above it, the indicator identifies a Sell-Side Liquidity Sweep.

These sweeps often indicate stop hunts and can provide valuable context before potential reversals or trend continuations.

### Dashboard

The dashboard displays:

• Current Trend

• Latest Equal High

• Latest Equal Low

• Last Liquidity Sweep

This provides a quick overview of current market conditions.

### Best Markets

• Forex

• Gold (XAUUSD)

• Silver (XAGUSD)

• Indices

• Crypto

• Stocks

### Recommended Timeframes

• M5

• M15

• H1

• H4

The indicator adapts well across multiple timeframes, although higher timeframes generally produce stronger liquidity signals.

### Notes

Liquidity sweeps should always be combined with market structure, trend direction, and proper risk management. No indicator can guarantee future price movement, and this tool is intended to assist with market analysis rather than provide guaranteed trading signals.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader
//@version=6
indicator("Liquidity Sweep Detector Pro", overlay=true, max_lines_count=500, max_labels_count=500)

// ===================== INPUTS =====================
pivotLen      = input.int(3, "Pivot Strength", minval=1)
extendBars    = input.int(100, "Extend Liquidity Levels")
toleranceATR  = input.float(0.15, "Equal High/Low ATR Tolerance", step=0.01)
showLevels    = input.bool(true, "Show Liquidity Levels")
showSweeps    = input.bool(true, "Show Sweep Signals")
showTrend     = input.bool(true, "Show Trend Filter")

// ===================== TREND =====================
ema50  = ta.ema(close, 50)
ema200 = ta.ema(close, 200)

bullTrend = ema50 > ema200
bearTrend = ema50 < ema200

plot(showTrend ? ema50 : na, "EMA 50", color=color.green, linewidth=2)
plot(showTrend ? ema200 : na, "EMA 200", color=color.red, linewidth=2)

// ===================== ATR =====================
atr = ta.atr(14)

// ===================== PIVOTS =====================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float eqHigh = na
var float eqLow  = na

var line highLine = na
var line lowLine  = na

// ===================== EQUAL HIGHS =====================
if not na(ph)
    if not na(eqHigh)
        if math.abs(ph - eqHigh) <= atr * toleranceATR

            if showLevels
                line.delete(highLine)

                highLine := line.new(
                 bar_index - pivotLen,
                 eqHigh,
                 bar_index + extendBars,
                 eqHigh,
                 color=color.red,
                 width=2)

        eqHigh := ph
    else
        eqHigh := ph

// ===================== EQUAL LOWS =====================
if not na(pl)
    if not na(eqLow)
        if math.abs(pl - eqLow) <= atr * toleranceATR

            if showLevels
                line.delete(lowLine)

                lowLine := line.new(
                 bar_index - pivotLen,
                 eqLow,
                 bar_index + extendBars,
                 eqLow,
                 color=color.lime,
                 width=2)

        eqLow := pl
    else
        eqLow := pl

// ===================== SWEEP DETECTION =====================
bslSweep =
     not na(eqHigh) and
     high > eqHigh and
     close < eqHigh

sslSweep =
     not na(eqLow) and
     low < eqLow and
     close > eqLow

// ===================== SIGNALS =====================
plotshape(
 showSweeps and bslSweep,
 title="BSL Sweep",
 style=shape.triangledown,
 location=location.abovebar,
 color=color.red,
 size=size.large,
 text="BSL")

plotshape(
 showSweeps and sslSweep,
 title="SSL Sweep",
 style=shape.triangleup,
 location=location.belowbar,
 color=color.lime,
 size=size.large,
 text="SSL")

// ===================== LABELS =====================
if bslSweep
    label.new(
     bar_index,
     high,
     "BUY SIDE\nLIQUIDITY SWEEP",
     style=label.style_label_down,
     color=color.red,
     textcolor=color.white)

if sslSweep
    label.new(
     bar_index,
     low,
     "SELL SIDE\nLIQUIDITY SWEEP",
     style=label.style_label_up,
     color=color.green,
     textcolor=color.white)

// ===================== REMOVE SWEPT LEVELS =====================
if bslSweep
    line.delete(highLine)
    eqHigh := na

if sslSweep
    line.delete(lowLine)
    eqLow := na

// ===================== ALERTS =====================
alertcondition(
 bslSweep,
 title="BSL Sweep",
 message="Buy Side Liquidity Sweep Detected")

alertcondition(
 sslSweep,
 title="SSL Sweep",
 message="Sell Side Liquidity Sweep Detected")

// ===================== DASHBOARD =====================
var table dash = table.new(position.top_right, 2, 4)

if barstate.islast
    table.cell(dash, 0, 0, "Trend")
    table.cell(dash, 1, 0,
     bullTrend ? "Bullish" :
     bearTrend ? "Bearish" :
     "Neutral")

    table.cell(dash, 0, 1, "EQ High")
    table.cell(dash, 1, 1,
     na(eqHigh) ? "-" : str.tostring(eqHigh))

    table.cell(dash, 0, 2, "EQ Low")
    table.cell(dash, 1, 2,
     na(eqLow) ? "-" : str.tostring(eqLow))

    table.cell(dash, 0, 3, "Last Sweep")
    table.cell(dash, 1, 3,
     bslSweep ? "BSL" :
     sslSweep ? "SSL" :
     "None")
````
