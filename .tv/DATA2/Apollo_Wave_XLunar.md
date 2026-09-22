<!-- tradingview-pine-id: PUB;907d4929073f4692a7595832a6a9be97 -->
<!-- tradingview-pine-version: 3.0 -->
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

// === Inputs ===

filterMode = input.string("NL", "Filter Mode", options=["NL", "SSE"], tooltip="NL = Normal -> EMA\nSSE = Ehlers Super Smoother",group="🔔 Sound Alerts")

len = input.int(21, "Base Period",group="🔔 Sound Alerts")

lineSource = input.string("C1", "Line Source", options=["C1", "S2", "S3"], tooltip="Recommended sources: S2 and S3",group="🔔 Sound Alerts")

// === Fixed Colors ===

colUp     = color.lime
colDown   = color.orange
colLineUp = color.blue

// === Independent Sources for the Lights ===

srcC1 = hlcc4
srcS2 = hlc3
srcS3 = ohlc4

alpha = 2 / (len + 1)

// === Ehlers Super Smoother (2-pole) ===

superSmoother(src, period) =>
    var float filt  = na
    var float filt1 = na
    var float filt2 = na
    a1 = math.exp(-1.414 * math.pi / period)
    b1 = 2 * a1 * math.cos(1.414 * math.pi / period)
    c2 = b1
    c3 = -a1 * a1
    c1 = 1 - c2 - c3
    filt := na(filt1) or na(filt2) ? src : c1 * (src + nz(src[1])) / 2 + c2 * filt1 + c3 * filt2
    filt2 := filt1
    filt1 := filt
    filt

// === EMA (Normal mode) ===

emaFilter(src) =>
    var float filt = na
    filt := na(filt[1]) ? src : alpha * src + (1 - alpha) * filt[1]
    filt

// === Unified filter switch ===

applyFilter(src) =>
    filterMode == "SSE" ? superSmoother(src, len) : emaFilter(src)

// ==============================

// === Waves for the Lights ===

filtC1 = applyFilter(srcC1)
filtS2 = applyFilter(srcS2)
filtS3 = applyFilter(srcS3)

waveC1 = na(filtC1[1]) ? 0.0 : filtC1 - filtC1[1]
waveS2 = na(filtS2[1]) ? 0.0 : filtS2 - filtS2[1]
waveS3 = na(filtS3[1]) ? 0.0 : filtS3 - filtS3[1]

slopeC1 = na(waveC1[1]) ? 0.0 : waveC1 - waveC1[1]
slopeS2 = na(waveS2[1]) ? 0.0 : waveS2 - waveS2[1]
slopeS3 = na(waveS3[1]) ? 0.0 : waveS3 - waveS3[1]

// === Light Colors ===

colC1 = slopeC1 >= 0 ? colUp : colDown
colS2 = slopeS2 >= 0 ? colUp : colDown
colS3 = slopeS3 >= 0 ? colUp : colDown

// === Light Panel with ▲ ▼ Arrows ===

var table t = table.new(position.bottom_right, 3, 1, force_overlay=true)

table.cell(t, 0, 0, slopeC1 >= 0 ? "▲ C1" : "▼ C1", text_color=colC1, text_size=size.small)
table.cell(t, 1, 0, slopeS2 >= 0 ? "▲ S2" : "▼ S2", text_color=colS2, text_size=size.small)
table.cell(t, 2, 0, slopeS3 >= 0 ? "▲ S3" : "▼ S3", text_color=colS3, text_size=size.small)

// ==============================

// === Chart Wave Line (Switcher) ===

filtLine = switch lineSource
    "C1" => filtC1
    "S2" => filtS2
    "S3" => filtS3

waveLine = na(filtLine[1]) ? 0.0 : filtLine - filtLine[1]
slopeLine = na(waveLine[1]) ? 0.0 : waveLine - waveLine[1]

colLine = slopeLine >= 0 ? colLineUp : colDown

pLine = plot(waveLine, color=colLine, linewidth=2, title="Wave Line")
pZero = plot(0,precision=0, color=color.new(color.gray, 70), title="Zero Line")

fill(pLine, pZero, color=color.new(colLine, 85), title="Wave Fill")

// ==============================

// === Bullish/Bearish Confluence ===

upC1 = slopeC1 >= 0
upS2 = slopeS2 >= 0
upS3 = slopeS3 >= 0

// === Alert Conditions (trigger only on transition) ===

alertC1Up      = upC1 and not upC1[1]
alertC1S2Up    = (upC1 and upS2) and not (upC1[1] and upS2[1])
alertC1S2S3Up  = (upC1 and upS2 and upS3) and not (upC1[1] and upS2[1] and upS3[1])

alertC1Down     = not upC1 and upC1[1]
alertC1S2Down   = (not upC1 and not upS2) and not (not upC1[1] and not upS2[1])
alertC1S2S3Down = (not upC1 and not upS2 and not upS3) and not (not upC1[1] and not upS2[1] and not upS3[1])

// === Sound Alerts ===

alertcondition(alertC1Up,      title="C1 -> Positive I",         message=" C1 -> Positive I")
alertcondition(alertC1S2Up,    title="C1 + S2 -> Positive II",    message="C1 + S2 -> Positive II")
alertcondition(alertC1S2S3Up,  title="C1 + S2 + S3 -> Positive III", message="C1 + S2 + S3 -> Positive III")

alertcondition(alertC1Down,      title="C1 -> Negative -1",         message="C1 -> Negative -1")
alertcondition(alertC1S2Down,    title="C1 + S2 -> Negative -2",    message="C1 + S2 -> Negative -2")
alertcondition(alertC1S2S3Down,  title="C1 + S2 + S3 -> Negative -3", message="C1 + S2 + S3 -> Negative -3")
````
