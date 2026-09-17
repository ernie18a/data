<!-- tradingview-pine-id: PUB;907d4929073f4692a7595832a6a9be97 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Apollo Wave X-Lunar

Source: https://www.tradingview.com/script/uUEcDUMX/

## Description

Apollo Wave X-Lunar

Apollo Wave X-Lunar is a momentum and directional indicator based on the movement and slope of three independent waves: F1, XA, and AK. Each source uses a different price calculation to provide complementary readings of market movement.

The indicator displays three “lights” on the panel:

▲ Lime: wave slope is equal to or above zero, indicating upward momentum.
▼ Orange: wave slope is below zero, indicating downward momentum.

In addition to the lights, the indicator displays a Wave Line whose source can be selected by the user.

⚙️ Parameters
Base Period — len

Defines the period used to filter the waves.

Lower periods: higher sensitivity to price changes and more frequent directional changes.
Higher periods: greater smoothing and lower sensitivity to short-term fluctuations.

The default value is 21.

There is no universally optimal period. The appropriate setting may vary depending on the asset, timeframe, and trading style.

Line Source — lineSource

Selects which of the three sources is used to construct the main chart line.

F1 — HLCC4
Uses the average of High, Low, and twice the Close.

XA — HLC3
Uses the average of High, Low, and Close.

AK — OHLC4
Uses the average of Open, High, Low, and Close.

The three sources are calculated independently for the lights. This parameter only changes the Wave Line displayed on the chart.

📊 How to Interpret

The indicator compares the current wave movement with its previous slope.

▲ F1

Shows the slope direction of the wave based on HLCC4.

▲ XA

Shows the slope direction of the wave based on HLC3.

▲ AK

Shows the slope direction of the wave based on OHLC4.

When all three lights point upward simultaneously, there is greater directional agreement between the three price sources. When all three point downward, there is greater agreement toward the downside.

Differences between the lights may indicate that the different price sources are producing different momentum readings.

🌊 Wave Line

The main line uses the source selected under Line Source.

F1: HLCC4
XA: HLC3
AK: OHLC4

The line color follows its slope:

Lime: positive or neutral slope.
Orange: negative slope.
🔧 Suggested Configuration

The default value of 21 can be used as a starting point.

For a faster reading, try lower periods.

For a smoother reading, try higher periods.

The appropriate configuration should be evaluated according to the asset and timeframe being analyzed. It is recommended to test different settings before using the indicator as part of trading decisions.

⚠️ Disclaimer

Apollo Wave X-Lunar is a technical analysis tool and does not constitute investment advice, an offer, or a guarantee of results.

The indicator's signals and readings should be used together with other analysis tools, risk management, and overall market context.

No technical indicator can guarantee future results.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Canhoto-Medium

//@version=6

indicator("Apollo Wave X-Lunar", shorttitle="W-Apollo", precision=4, overlay=false)

import TradingView/ta/12

// === Inputs ===

len = input.int(21, "Base Period")

lineSource = input.string("F1", "Line Source", options=["F1", "XA", "AK"], tooltip="Recommended sources: XA and AK")

// === Independent Sources for the Lights ===

srcF1 = hlcc4
srcXA = hlc3
srcAK = ohlc4

alpha = 2 / (len + 1)

// ==============================

// === Waves for the Lights ===

var float filtF1 = na
var float filtXA = na
var float filtAK = na

filtF1 := alpha * srcF1 + (1 - alpha) * nz(filtF1[1])
filtXA := alpha * srcXA + (1 - alpha) * nz(filtXA[1])
filtAK := alpha * srcAK + (1 - alpha) * nz(filtAK[1])

waveF1 = filtF1 - nz(filtF1[1])
waveXA = filtXA - nz(filtXA[1])
waveAK = filtAK - nz(filtAK[1])

slopeF1 = waveF1 - nz(waveF1[1])
slopeXA = waveXA - nz(waveXA[1])
slopeAK = waveAK - nz(waveAK[1])

// === Light Colors ===

colF1 = slopeF1 >= 0 ? color.lime : color.orange
colXA = slopeXA >= 0 ? color.lime : color.orange
colAK = slopeAK >= 0 ? color.lime : color.orange

// === Light Panel with ▲ ▼ Arrows ===

var table t = table.new(position.bottom_right, 3, 1, force_overlay=true)

table.cell(t, 0, 0, slopeF1 >= 0 ? "▲ F1" : "▼ F1", text_color=colF1, text_size=size.small)
table.cell(t, 1, 0, slopeXA >= 0 ? "▲ XA" : "▼ XA", text_color=colXA, text_size=size.small)
table.cell(t, 2, 0, slopeAK >= 0 ? "▲ AK" : "▼ AK", text_color=colAK, text_size=size.small)

// ==============================

// === Chart Wave Line (Switcher) ===

srcLine = switch lineSource
    "F1" => srcF1
    "XA" => srcXA
    "AK" => srcAK

var float filtLine = na

filtLine := alpha * srcLine + (1 - alpha) * nz(filtLine[1])

waveLine = filtLine - nz(filtLine[1])
slopeLine = waveLine - nz(waveLine[1])

colLine = slopeLine >= 0 ? color.lime : color.orange

plot(waveLine, color=colLine, linewidth=2, title="Wave Line")
````
