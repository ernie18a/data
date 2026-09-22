<!-- tradingview-pine-id: PUB;c9734d109c7649c8b9bd24aefc5480c8 -->
<!-- tradingview-pine-version: 5.0 -->
<!-- tradingviewscripts-format: 1 -->
# SMI Ergodic Oscillator PRO

Source: https://www.tradingview.com/script/MfB6OYvQ/

## Description

SMI Ergodic Oscillator PRO

The SMI Ergodic Oscillator PRO is a momentum indicator designed to help traders identify changes in the strength and direction of price movement.

The indicator displays a histogram, making momentum behavior easy to visualize:

🟢 Green/Lime: momentum is gaining strength or positive slope.
🔴 Red: momentum is weakening or showing negative slope.
Larger bars: indicate stronger momentum.
Smaller bars: may indicate declining momentum and a possible loss of strength.

The main purpose of the indicator is not to generate trades by itself, but to help confirm market direction and identify potential changes in momentum.

How to Use
1. Trend Confirmation

During an uptrend, look for a sequence of consistent positive bars. Sustained momentum can provide additional confirmation that the current move remains strong.

During a downtrend, look for persistent negative bars.

2. Momentum Changes

A change in histogram color can highlight a potential shift in market momentum.

Red → Green
May indicate improving bullish momentum.

Green → Red
May indicate weakening bullish momentum or increasing bearish momentum.

Color changes should be evaluated together with price action, market structure, and the overall trend.

3. Loss of Momentum

When histogram bars begin to decrease in size, even while remaining on the same side, this may indicate that the current movement is losing strength.

This can be used as an alert to:

Reduce exposure
Protect an existing position
Wait for additional confirmation
Monitor for a potential reversal
Parameter Settings

The indicator provides three main parameters:

Parameter	Practical Function	Effect
Long Length	Controls the longer-term sensitivity	Higher values = smoother response
Short Length	Controls responsiveness to recent price movements	Lower values = faster response
Signal Length	Controls signal smoothing	Higher values = less noise
Suggested Settings
Balanced — 20 / 5 / 5

A good starting configuration for general market analysis and most timeframes.

Fast — 10 / 3 / 3

More responsive to recent momentum changes. Suitable for traders looking for earlier signals, but it may produce more noise.

Conservative — 30 / 7 / 7

Produces a smoother reading and reduces sensitivity to smaller market fluctuations.

Very Conservative — 50 / 10 / 10

Designed for traders who prefer to focus on larger and more sustained market movements.

Choosing the Right Settings

There is no universal "best" configuration. Parameters should be adapted to:

Asset: Crypto, Forex, stocks, indices, etc.
Timeframe: Scalping, day trading, or swing trading.
Volatility: Highly volatile markets may require more conservative settings.
Trading style: Faster settings can be useful for earlier momentum detection, while slower settings can provide stronger confirmation.
Simple Trading Approach

A practical approach is to use the indicator in combination with price structure and market context.

Potential Long Setup:
Favorable market structure + positive momentum + confirmation from the histogram.

Potential Short Setup:
Favorable bearish structure + negative momentum + confirmation from the histogram.

Avoid: entering a trade solely because the histogram changes color. A color change is better treated as a confirmation or warning signal, rather than an independent trading signal.

Important Notice

The SMI Ergodic Oscillator PRO is a technical analysis tool designed to assist with market analysis. It does not guarantee trading results and should not be considered financial advice. Always combine the indicator with proper risk management and independent market analysis.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/

// © Canhoto-Medium

//@version=6
indicator(title="SMI Ergodic Oscillator PRO", shorttitle="SMIO PRO", format=format.price, precision=4, max_labels_count=500)

// === INPUTS ===

longlen  = input.int(20, minval=1, title="Long Length", group="🔔 Sound Alerts")
shortlen = input.int(5, minval=1, title="Short Length", group="🔔 Sound Alerts")
siglen   = input.int(5, minval=1, title="Signal Length", group="🔔 Sound Alerts")

// === MA TYPE ===

maType = input.string("SMA", "Signal MA Type", options=["SMA", "EMA", "WMA"])

// === SOURCE ===

srcOpt = input.string("close", "Source", options=["close", "hl2", "hlc3", "hlcc4", "ohlc4"])

src = switch srcOpt
    "close" => close
    "hl2"   => hl2
    "hlc3"  => hlc3
    "hlcc4" => hlcc4
    => ohlc4

// === BASE (TSI) ===

erg = ta.tsi(src, shortlen, longlen)

// === SIGNAL ===

sig = switch maType
    "SMA" => ta.sma(erg, siglen)
    "EMA" => ta.ema(erg, siglen)
    => ta.wma(erg, siglen)

// === OSCILLATOR ===

osc = erg - sig

// === COLOR BY SLOPE ===

slope = osc - osc[1]

isGreen = slope >= 0
isRed   = slope < 0

colorHist = isGreen ? color.lime : color.red

// === COLOR CHANGE ===

greenChange = isGreen and not isGreen[1]
redChange   = isRed and not isRed[1]
colorChange = greenChange or redChange

// === HISTOGRAM ===

plot(osc, title="SMI Ergodic", style=plot.style_histogram, color=colorHist, linewidth=3)

// === STATUS ===

var table statusTable = table.new(position.middle_right, 1, 1)

if barstate.islast
    txt = redChange ? "🔵" :
          greenChange ? "🟠" :
          isGreen ? "🟢" :
          isRed ? "🔴" : "🟡"

    table.cell(statusTable, 0, 0, text=txt, text_size=size.normal, bgcolor=color.new(color.black, 100))

// === ALERTS ===

alertcondition(greenChange, title="SMIO → Long 🟢", message="SMIO PRO: LONG - 🟢 Histogram changed to GREEN.")
alertcondition(redChange, title="SMIO ← Short 🔴", message="SMIO PRO: SHORT - 🔴 Histogram changed to RED.")
alertcondition(colorChange, title="SMIO ↑ ↓ Color Change 🔵🟠", message="SMIO PRO - 🔵🟠 Histogram color changed.")
````
