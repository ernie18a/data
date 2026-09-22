<!-- tradingview-pine-id: PUB;f9fb9b593c96484f9bfb6ec2659188da -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Alpha ER Regime Bands [identityKa]

Source: https://www.tradingview.com/script/AvSzILUS/

## Description

Alpha ER Regime Bands [identityKa]

Bands that know when the market is noisy.

A fixed-multiplier band treats every market the same. But price behaves very differently when it is travelling in a straight line versus when it is churning sideways. This tool wraps an adaptive centre line in an envelope whose width automatically follows market noise, so a "stretch" means something in both environments.

HOW IT WORKS

1. Efficiency Ratio (ER): net price change over the lookback divided by the total distance price travelled. Near 1 = clean, directional movement. Near 0 = lots of movement, no progress.
2. Adaptive line: Perry Kaufman's Adaptive Moving Average. When ER is high it speeds up and hugs price; when ER is low it slows down and ignores noise.
3. Noise-scaled envelope: band half-width = ATR x multiplier, where the multiplier is interpolated between two settings by the smoothed ER:
   - Efficient market (ER high): tight multiplier (default 1.0). Price tends to hug the line, so a close outside the band is a meaningful departure.
   - Noisy market (ER low): wide multiplier (default 3.0). Price swings widely around the line, so wider bands avoid constant meaningless touches.
4. The line is colored by state: rising, falling, or grey when the market is noisy or the slope is flat.

Why this differs from standard bands: Bollinger, Keltner and fixed-ATR envelopes keep the same width logic regardless of how efficiently price is moving. Here, width is driven by efficiency itself, so the same visual cue (price outside the band) is calibrated to the current environment.

WHAT YOU SEE

- Adaptive line with color by slope and noise
- Envelope that widens and narrows with market noise
- Small markers on the first bar that closes outside a band
- Dashboard: Efficiency Ratio, Market Noise (Efficient / Mixed / Noisy), current band width in ATR, line slope in ATR per bar, price position versus the bands, and distance from the line in ATR

HOW TO USE IT

- Read it as context. In Efficient conditions, price outside the band is a sign of strong directional movement. In Noisy conditions, price outside the band is a sign of an extended swing that has room to revert. The same marker, two different readings: check the Market Noise row first.
- Watch band width. A rapid narrowing means the market is becoming efficient. A rapid widening means it is becoming noisy.
- Combine with your own structure, volume or higher-timeframe analysis. This tool describes conditions, it does not tell you when to act.

SETTINGS

- Calculation: ER length, fast and slow smoothing of the adaptive line, ATR length, ER smoothing, band multipliers for efficient and noisy markets
- Regime Rules: ER levels for Noisy and Efficient labels, flat-slope threshold
- Display: colors, bands, markers, bar coloring
- Dashboard: position, text size, footer

ALERTS

Price closed above upper band, price closed below lower band, price back inside bands, market became Efficient, market became Noisy, adaptive line turned rising, adaptive line turned falling. For stable, non-repainting triggers, set the alert to Once Per Bar Close.

NOTES AND LIMITATIONS

- The first bars show nothing until enough history exists for ER and ATR.
- ER depends on timeframe: a level that is "efficient" on 1m may be normal on 1D. Adjust the Noisy and Efficient levels to your market if needed.
- Values on the current, unfinished bar can change until the bar closes.

This script is for educational and informational purposes only and is not financial advice. Past behavior does not guarantee future results.

Part of the Alpha Quant Toolkit by identityKa. See also: Alpha Regime Dashboard [identityKa].

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IdentityKa
//
// Alpha Quant Toolkit · #02 Efficiency Ratio Regime Bands
// An adaptive centre line (Kaufman AMA) wrapped in an ATR envelope whose width is
// scaled by market noise: wide bands when price is noisy, tight bands when price is efficient.

//@version=6
indicator("Alpha ER Regime Bands [identityKa]", shorttitle="AQ ER Bands", overlay=true)

// ═══════════════════════════════════════════════════════════════
//  CONSTANTS
// ═══════════════════════════════════════════════════════════════
const string GRP_CALC = "Calculation"
const string GRP_RULE = "Regime Rules"
const string GRP_VIS  = "Display"
const string GRP_DASH = "Dashboard"
const string BRAND    = "Alpha Quant Toolkit · identityKa"

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
lenER    = input.int(10, "Efficiency Ratio Length", minval=2, group=GRP_CALC,
     tooltip="Lookback for Kaufman's Efficiency Ratio: net price change divided by total path travelled.")
fastLen  = input.int(2,  "Adaptive Line · Fast Length", minval=1, group=GRP_CALC,
     tooltip="Fastest smoothing the adaptive line can reach (efficient market). Kaufman default: 2.")
slowLen  = input.int(30, "Adaptive Line · Slow Length", minval=5, group=GRP_CALC,
     tooltip="Slowest smoothing the adaptive line can reach (noisy market). Kaufman default: 30.")
lenATR   = input.int(14, "ATR Length", minval=2, group=GRP_CALC)
smoothER = input.int(3,  "ER Smoothing (band scaling)", minval=1, maxval=20, group=GRP_CALC,
     tooltip="Smooths the Efficiency Ratio that drives band width so the bands do not jump bar to bar.")
minMult  = input.float(1.0, "Band Multiplier · Efficient Market", minval=0.3, step=0.1, group=GRP_CALC,
     tooltip="ATR multiplier used when Efficiency Ratio is high (price moves in a straight line).")
maxMult  = input.float(3.0, "Band Multiplier · Noisy Market", minval=0.3, step=0.1, group=GRP_CALC,
     tooltip="ATR multiplier used when Efficiency Ratio is low (price moves a lot but goes nowhere).")

noiseThr = input.float(0.25, "Noisy Below (ER)", minval=0.05, maxval=0.5, step=0.01, group=GRP_RULE,
     tooltip="Smoothed Efficiency Ratio at or below this level is labelled Noisy.")
effThr   = input.float(0.50, "Efficient Above (ER)", minval=0.3, maxval=0.9, step=0.01, group=GRP_RULE,
     tooltip="Smoothed Efficiency Ratio at or above this level is labelled Efficient.")
flatThr  = input.float(0.02, "Flat Slope Below (ATR/bar)", minval=0.0, maxval=0.2, step=0.005, group=GRP_RULE,
     tooltip="Adaptive line slope, measured in ATR per bar. Below this absolute value the line is considered flat.")

cUp        = input.color(#19D3A2, "Rising",   group=GRP_VIS, inline="c1")
cDn        = input.color(#FF4D6A, "Falling",  group=GRP_VIS, inline="c1")
cChop      = input.color(#8A94A6, "Noisy / Flat", group=GRP_VIS, inline="c2")
cWarn      = input.color(#FFB020, "Stretch Marker", group=GRP_VIS, inline="c2")
showBands  = input.bool(true,  "Show bands", group=GRP_VIS)
showMarkers = input.bool(true, "Show stretch markers", group=GRP_VIS,
     tooltip="Marks the first bar that closes outside a band.")
colorBars  = input.bool(false, "Color bars by line state", group=GRP_VIS)

showTable = input.bool(true, "Show Dashboard", group=GRP_DASH)
posInput  = input.string("Top Right", "Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=GRP_DASH)
sizeInput = input.string("Normal", "Text Size", options=["Small", "Normal", "Large"], group=GRP_DASH)
showBrand = input.bool(true, "Show footer", group=GRP_DASH)

// ═══════════════════════════════════════════════════════════════
//  CALCULATION
// ═══════════════════════════════════════════════════════════════
// Efficiency Ratio (0..1)
erNum = math.abs(close - close[lenER])
erDen = math.sum(math.abs(close - close[1]), lenER)
er    = erDen == 0 ? 0.0 : erNum / erDen
erS   = ta.ema(er, smoothER)

// Adaptive line (Kaufman AMA)
fastSC = 2.0 / (fastLen + 1)
slowSC = 2.0 / (slowLen + 1)
sc     = math.pow(nz(er) * (fastSC - slowSC) + slowSC, 2)

var float kama = na
kama := na(kama) ? close : kama + sc * (close - kama)

// Noise-scaled envelope
atrVal  = ta.atr(lenATR)
loMult  = math.min(minMult, maxMult)
hiMult  = math.max(minMult, maxMult)
erClamp = math.max(0.0, math.min(1.0, nz(erS)))
mult    = loMult + (hiMult - loMult) * (1.0 - erClamp)
half    = mult * atrVal
upper   = kama + half
lower   = kama - half

// Position of price inside the envelope: -1 = lower band, 0 = line, +1 = upper band
pos     = (na(half) or half == 0) ? 0.0 : (close - kama) / half
distATR = (na(atrVal) or atrVal == 0) ? 0.0 : (close - kama) / atrVal
slopeAtr = (na(atrVal) or atrVal == 0) ? 0.0 : nz(kama - kama[1]) / atrVal

ready = bar_index >= math.max(lenER, lenATR) + smoothER

// States
dirSlope  = slopeAtr > flatThr ? 1 : slopeAtr < -flatThr ? -1 : 0
levelCode = erS >= effThr ? 2 : erS <= noiseThr ? 0 : 1          // 2 Efficient, 1 Mixed, 0 Noisy
stateCode = not ready ? 0 : pos >= 1 ? 1 : pos <= -1 ? -1 : 0     // 1 stretched up, -1 stretched down

levelText = not ready ? "Warming up" : levelCode == 2 ? "Efficient" : levelCode == 0 ? "Noisy" : "Mixed"
lineColor = levelCode == 0 ? cChop : dirSlope == 1 ? cUp : dirSlope == -1 ? cDn : cChop

stretchUp   = stateCode == 1  and nz(stateCode[1]) != 1
stretchDn   = stateCode == -1 and nz(stateCode[1]) != -1
backInFromUp = nz(stateCode[1]) == 1  and stateCode != 1
backInFromDn = nz(stateCode[1]) == -1 and stateCode != -1

// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════
plot(ready ? kama : na, "Adaptive Line", color=lineColor, linewidth=2)
pU = plot(ready and showBands ? upper : na, "Upper Band", color=color.new(lineColor, 45), linewidth=1)
pL = plot(ready and showBands ? lower : na, "Lower Band", color=color.new(lineColor, 45), linewidth=1)
fill(pU, pL, color=color.new(lineColor, 92), title="Envelope")

plotshape(showMarkers and stretchUp, "Stretch Above Upper Band", style=shape.circle, location=location.abovebar, color=cWarn, size=size.tiny)
plotshape(showMarkers and stretchDn, "Stretch Below Lower Band", style=shape.circle, location=location.belowbar, color=cWarn, size=size.tiny)

barcolor(colorBars and ready ? lineColor : na)

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
tblPos = switch posInput
    "Top Left"     => position.top_left
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    => position.top_right

txtSize = switch sizeInput
    "Small" => size.small
    "Large" => size.large
    => size.normal

fmt(float x, int d) => na(x) ? "—" : str.tostring(math.round(x, d))

var table dash = table.new(tblPos, 2, 8, bgcolor=color.new(#0F1420, 8), border_width=1, border_color=color.new(#2A3350, 0), frame_width=1, frame_color=color.new(#2A3350, 0))

if barstate.islast and showTable
    cTxt = #E6EAF2
    cDim = #9AA4B8
    levelCol = levelCode == 2 ? cUp : levelCode == 0 ? cChop : cWarn
    slopeText = dirSlope == 1 ? "Rising" : dirSlope == -1 ? "Falling" : "Flat"
    slopeCol  = dirSlope == 1 ? cUp : dirSlope == -1 ? cDn : cDim
    posText   = not ready ? "—" : stateCode == 1 ? "Above Upper" : stateCode == -1 ? "Below Lower" : "Inside Bands"
    posCol    = stateCode == 0 ? cTxt : cWarn

    table.cell(dash, 0, 0, "ER REGIME BANDS", text_color=cTxt, text_size=txtSize, text_halign=text.align_center, bgcolor=color.new(#1B2440, 0))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Efficiency Ratio", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, fmt(erS, 2), text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 2, "Market Noise", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, levelText, text_color=levelCol, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Band Width (x ATR)", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, fmt(mult, 2), text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Line Slope", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, slopeText + "  (" + fmt(slopeAtr, 2) + ")", text_color=slopeCol, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Price vs Bands", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, posText, text_color=posCol, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 6, "Distance from Line", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, fmt(distATR, 2) + " ATR", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 7, showBrand ? BRAND : "", text_color=cDim, text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dash, 0, 7, 1, 7)

// ═══════════════════════════════════════════════════════════════
//  ALERTS  (set to "Once Per Bar Close" for stable, non-repainting triggers)
// ═══════════════════════════════════════════════════════════════
levelChanged = ready and ta.change(levelCode) != 0
slopeFlipUp  = ready and dirSlope == 1  and nz(dirSlope[1]) != 1
slopeFlipDn  = ready and dirSlope == -1 and nz(dirSlope[1]) != -1

alertcondition(stretchUp,                         "Price closed above Upper Band", "{{ticker}} ({{interval}}): price closed above the noise-scaled upper band")
alertcondition(stretchDn,                         "Price closed below Lower Band", "{{ticker}} ({{interval}}): price closed below the noise-scaled lower band")
alertcondition(backInFromUp or backInFromDn,      "Price back inside Bands",       "{{ticker}} ({{interval}}): price re-entered the noise-scaled bands")
alertcondition(levelChanged and levelCode == 2,   "Market became Efficient",       "{{ticker}} ({{interval}}): market noise dropped, price is moving efficiently")
alertcondition(levelChanged and levelCode == 0,   "Market became Noisy",           "{{ticker}} ({{interval}}): market noise increased, price is moving inefficiently")
alertcondition(slopeFlipUp,                       "Adaptive Line turned Rising",   "{{ticker}} ({{interval}}): adaptive line turned rising")
alertcondition(slopeFlipDn,                       "Adaptive Line turned Falling",  "{{ticker}} ({{interval}}): adaptive line turned falling")
````
