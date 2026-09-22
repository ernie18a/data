<!-- tradingview-pine-id: PUB;4ca967ef30bf4df2b7cc795d54fd558b -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Alpha Regression Channel R2 [identityKa]

Source: https://www.tradingview.com/script/wGVmNfcg/

## Description

Alpha Regression Channel R2 [identityKa]

Not just "which way is the trend" but "how clean is it".

A regression channel draws the best-fit straight line through recent prices. The slope tells you direction. But the real question for any trend approach is how well price actually follows that line. This tool answers it with R² and shows the answer for three horizons at once.

HOW IT WORKS

1. Linear regression line: the least-squares straight line through the last N closes (default 100 bars).
2. R² (coefficient of determination): the share of price variation explained by that straight line, from 0 to 1. Close to 1 means price hugs the line, a clean trend. Close to 0 means the straight line explains almost nothing, price is wandering.
3. Channel width: the bands sit a chosen number of standard deviations of the residuals (the distance of price from the line) above and below the line. Residual standard deviation is computed directly as price standard deviation x square root of (1 - R²), so the channel automatically gets tighter when the trend is clean and wider when it is not.
4. Price position in sigma: where the current close sits relative to the line, in residual standard deviations. Beyond the band edge (default 2 sigma) is marked Above or Below Channel.
5. Trend quality labels: Clean at or above 0.70, Weak at or below 0.40, Moderate in between (adjustable).

Horizon comparison: R² and direction are also computed on two other lengths (default 50 and 200 bars). The dashboard shows which horizon is currently the cleanest, so you can see at a glance which time scale the market is actually trending on.

WHAT YOU SEE

- A regression channel drawn over the last N bars, dashed centre line, colored by direction, grey when the trend is weak
- Optional rolling version of the line and bands for every bar
- Dashboard: Trend Direction, Trend Quality (R²), Slope in ATR per bar and percent per bar, Channel Width as a percent of price, Price Position in sigma, an R² table for the three horizons, and the Cleanest Horizon

HOW TO USE IT

- Read R² before trusting a slope. A steep slope with low R² is a noisy move. A gentle slope with high R² is an orderly one.
- Compare horizons. If the short horizon is Clean but the long one is Weak, the market is trending only on a short scale.
- Use price position as a stretch gauge. Price beyond the channel edge means it is far from its fitted line relative to typical noise. What that means depends on trend quality: in a Clean trend it can signal strength, in a Weak one it can signal an extension.
- The tool describes conditions, it does not tell you when to act.

SETTINGS

- Calculation: channel length, two comparison horizons, channel width in standard deviations, ATR length
- Quality Rules: R² levels for Clean and Weak, flat-slope threshold
- Display: colors, channel, fill, extend to the right, rolling version
- Dashboard: position, text size, footer

ALERTS

Trend quality became Clean, trend quality became Weak, slope turned Up, slope turned Down, price crossed above the channel, price crossed below the channel. For stable, non-repainting triggers, set the alert to Once Per Bar Close.

NOTES AND LIMITATIONS

- A regression line is fitted to past prices, so the drawn channel changes as new bars arrive. It describes the window, it does not forecast.
- Regression assumes a straight-line relationship. Curved or stair-step moves can show a lower R² even when they are orderly.
- Channel length is capped at 400 bars for chart drawing limits.

This script is for educational and informational purposes only and is not financial advice. Past behavior does not guarantee future results.

Part of the Alpha Quant Toolkit by identityKa. See also: Alpha Regime Dashboard [identityKa], Alpha MTF Trend Matrix [identityKa].

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IdentityKa
//
// Alpha Quant Toolkit · #05 Regression Channel + R² Trend Quality
// Linear regression channel over the last N bars, with R² as a trend-quality score,
// a quality check on three horizons, and price position measured in residual standard deviations.

//@version=6
indicator("Alpha Regression Channel R2 [identityKa]", shorttitle="AQ RegChannel", overlay=true, max_bars_back=500)

// ═══════════════════════════════════════════════════════════════
//  CONSTANTS
// ═══════════════════════════════════════════════════════════════
const string GRP_CALC = "Calculation"
const string GRP_RULE = "Quality Rules"
const string GRP_VIS  = "Display"
const string GRP_DASH = "Dashboard"
const string BRAND    = "Alpha Quant Toolkit · identityKa"

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
lenMain = input.int(100, "Channel Length (bars)", minval=10, maxval=400, group=GRP_CALC,
     tooltip="Number of bars in the regression window drawn on the chart.")
lenB    = input.int(50,  "Horizon B (bars)", minval=10, maxval=400, group=GRP_CALC,
     tooltip="Second horizon shown in the R² comparison table.")
lenC    = input.int(200, "Horizon C (bars)", minval=10, maxval=400, group=GRP_CALC,
     tooltip="Third horizon shown in the R² comparison table.")
devMult = input.float(2.0, "Channel Width (residual std devs)", minval=0.5, maxval=4.0, step=0.1, group=GRP_CALC,
     tooltip="Band distance from the regression line, in standard deviations of the residuals (distance of price from the line).")
lenATR  = input.int(14, "ATR Length", minval=2, group=GRP_CALC)

cleanThr = input.float(0.70, "Clean Trend: R² at or above", minval=0.3, maxval=0.99, step=0.01, group=GRP_RULE,
     tooltip="R² is the share of price variation explained by a straight line. 1.0 = price sits exactly on a line.")
weakThr  = input.float(0.40, "Weak Trend: R² at or below", minval=0.0, maxval=0.7, step=0.01, group=GRP_RULE)
flatThr  = input.float(0.02, "Flat Slope Below (ATR/bar)", minval=0.0, maxval=0.2, step=0.005, group=GRP_RULE)

cUp    = input.color(#19D3A2, "Rising",  group=GRP_VIS, inline="c1")
cDn    = input.color(#FF4D6A, "Falling", group=GRP_VIS, inline="c1")
cChop  = input.color(#8A94A6, "Weak / Flat", group=GRP_VIS, inline="c2")
showChannel = input.bool(true,  "Show regression channel", group=GRP_VIS)
showFill    = input.bool(true,  "Show channel fill", group=GRP_VIS)
extendRight = input.bool(false, "Extend channel to the right", group=GRP_VIS)
showRolling = input.bool(false, "Show rolling bands (per-bar version)", group=GRP_VIS,
     tooltip="Plots the regression value and bands for every bar, each computed from the window ending on that bar.")

showTable = input.bool(true, "Show Dashboard", group=GRP_DASH)
posInput  = input.string("Top Right", "Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=GRP_DASH)
sizeInput = input.string("Normal", "Text Size", options=["Small", "Normal", "Large"], group=GRP_DASH)
showBrand = input.bool(true, "Show footer", group=GRP_DASH)

// ═══════════════════════════════════════════════════════════════
//  CALCULATION
//  residual std dev = std dev of price x sqrt(1 - R²)
// ═══════════════════════════════════════════════════════════════
f_stats(int len) =>
    mid   = ta.linreg(close, len, 0)
    prev  = ta.linreg(close, len, 1)
    slope = mid - prev
    r     = ta.correlation(close, bar_index, len)
    r2    = r * r
    sd    = ta.stdev(close, len) * math.sqrt(math.max(0.0, 1.0 - nz(r2)))
    [mid, slope, r2, sd]

[midA, slopeA, r2A, sdA] = f_stats(lenMain)
[midB, slopeB, r2B, sdB] = f_stats(lenB)
[midC, slopeC, r2C, sdC] = f_stats(lenC)

atrVal   = ta.atr(lenATR)
yStart   = ta.linreg(close, lenMain, lenMain - 1)     // regression value at the first bar of the window

upperA   = midA + devMult * sdA
lowerA   = midA - devMult * sdA

slopeAtr = (na(atrVal) or atrVal == 0) ? 0.0 : slopeA / atrVal
slopePct = close == 0 ? 0.0 : slopeA / close * 100.0
posSigma = (na(sdA) or sdA == 0) ? 0.0 : (close - midA) / sdA
widthPct = (na(midA) or midA == 0) ? na : 2.0 * devMult * sdA / midA * 100.0

ready = not na(r2A) and not na(midA)

f_q(float r2) => na(r2) ? "—" : r2 >= cleanThr ? "Clean" : r2 <= weakThr ? "Weak" : "Moderate"
f_d(float s, float a) =>
    float sa = (na(a) or a == 0) ? 0.0 : s / a
    sa > flatThr ? "Up" : sa < -flatThr ? "Down" : "Flat"

qualCode = not ready ? 0 : r2A >= cleanThr ? 2 : r2A <= weakThr ? 0 : 1
dirCode  = slopeAtr > flatThr ? 1 : slopeAtr < -flatThr ? -1 : 0
lineCol  = qualCode == 0 ? cChop : dirCode == 1 ? cUp : dirCode == -1 ? cDn : cChop

// ═══════════════════════════════════════════════════════════════
//  DRAWING: regression channel over the last N bars
// ═══════════════════════════════════════════════════════════════
var line lnMid = na
var line lnUp  = na
var line lnLo  = na
var linefill lf = na

if barstate.islast and showChannel and ready and bar_index >= lenMain
    int x1 = bar_index - lenMain + 1
    int x2 = bar_index
    float off = devMult * sdA
    ext = extendRight ? extend.right : extend.none
    if na(lnMid)
        lnMid := line.new(x1, yStart, x2, midA, color=lineCol, width=2, style=line.style_dashed, extend=ext)
        lnUp  := line.new(x1, yStart + off, x2, midA + off, color=lineCol, width=1, extend=ext)
        lnLo  := line.new(x1, yStart - off, x2, midA - off, color=lineCol, width=1, extend=ext)
        if showFill
            lf := linefill.new(lnUp, lnLo, color.new(lineCol, 90))
    else
        line.set_xy1(lnMid, x1, yStart)
        line.set_xy2(lnMid, x2, midA)
        line.set_xy1(lnUp, x1, yStart + off)
        line.set_xy2(lnUp, x2, midA + off)
        line.set_xy1(lnLo, x1, yStart - off)
        line.set_xy2(lnLo, x2, midA - off)
        line.set_color(lnMid, lineCol)
        line.set_color(lnUp, lineCol)
        line.set_color(lnLo, lineCol)
        line.set_extend(lnMid, ext)
        line.set_extend(lnUp, ext)
        line.set_extend(lnLo, ext)
        if not na(lf)
            linefill.set_color(lf, color.new(lineCol, 90))

// ═══════════════════════════════════════════════════════════════
//  PLOTS (optional rolling version)
// ═══════════════════════════════════════════════════════════════
plot(showRolling and ready ? midA   : na, "Rolling Regression", color=lineCol, linewidth=2)
plot(showRolling and ready ? upperA : na, "Rolling Upper",      color=color.new(lineCol, 40))
plot(showRolling and ready ? lowerA : na, "Rolling Lower",      color=color.new(lineCol, 40))

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

var table dash = table.new(tblPos, 2, 12, bgcolor=color.new(#0F1420, 8), border_width=1, border_color=color.new(#2A3350, 0), frame_width=1, frame_color=color.new(#2A3350, 0))

if barstate.islast and showTable
    cTxt = #E6EAF2
    cDim = #9AA4B8
    hdrBg = color.new(#1B2440, 0)

    dirText = not ready ? "—" : dirCode == 1 ? "Up" : dirCode == -1 ? "Down" : "Flat"
    dirCol  = dirCode == 1 ? cUp : dirCode == -1 ? cDn : cDim
    qText   = f_q(r2A)
    qCol    = qualCode == 2 ? cUp : qualCode == 0 ? cChop : cTxt
    zoneText = not ready ? "—" : posSigma >= devMult ? "Above Channel" : posSigma <= -devMult ? "Below Channel" : "Inside Channel"
    zoneCol  = (posSigma >= devMult or posSigma <= -devMult) ? #FFB020 : cTxt

    // cleanest horizon
    float bestR2 = math.max(nz(r2A, -1), math.max(nz(r2B, -1), nz(r2C, -1)))
    string bestTxt = bestR2 < 0 ? "—" : nz(r2A, -1) == bestR2 ? str.tostring(lenMain) + " bars" : nz(r2B, -1) == bestR2 ? str.tostring(lenB) + " bars" : str.tostring(lenC) + " bars"

    table.cell(dash, 0, 0, "REGRESSION CHANNEL", text_color=cTxt, text_size=txtSize, text_halign=text.align_center, bgcolor=hdrBg)
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Trend Direction", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, dirText, text_color=dirCol, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 2, "Trend Quality (R²)", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, fmt(r2A, 2) + "  " + qText, text_color=qCol, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Slope", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, fmt(slopeAtr, 3) + " ATR/bar  (" + fmt(slopePct, 3) + "%)", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Channel Width", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, fmt(widthPct, 2) + "% of price", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Price Position", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, fmt(posSigma, 2) + " σ  " + zoneText, text_color=zoneCol, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 6, "R² BY HORIZON", text_color=cTxt, text_size=txtSize, text_halign=text.align_center, bgcolor=hdrBg)
    table.merge_cells(dash, 0, 6, 1, 6)

    table.cell(dash, 0, 7, str.tostring(lenB) + " bars", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 7, fmt(r2B, 2) + " · " + f_d(slopeB, atrVal) + " · " + f_q(r2B), text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 8, str.tostring(lenMain) + " bars (channel)", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 8, fmt(r2A, 2) + " · " + f_d(slopeA, atrVal) + " · " + f_q(r2A), text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 9, str.tostring(lenC) + " bars", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 9, fmt(r2C, 2) + " · " + f_d(slopeC, atrVal) + " · " + f_q(r2C), text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 10, "Cleanest Horizon", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 10, bestTxt, text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 11, showBrand ? BRAND : "", text_color=cDim, text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dash, 0, 11, 1, 11)

// ═══════════════════════════════════════════════════════════════
//  ALERTS  (set to "Once Per Bar Close" for stable, non-repainting triggers)
// ═══════════════════════════════════════════════════════════════
qualBecameClean = ready and ta.crossover(r2A, cleanThr)
qualBecameWeak  = ready and ta.crossunder(r2A, weakThr)
dirFlipUp       = ready and dirCode == 1  and nz(dirCode[1]) != 1
dirFlipDn       = ready and dirCode == -1 and nz(dirCode[1]) != -1
brokeAbove      = ready and ta.crossover(close, upperA)
brokeBelow      = ready and ta.crossunder(close, lowerA)

alertcondition(qualBecameClean, "Trend quality became Clean", "{{ticker}} ({{interval}}): regression R² rose into the Clean zone")
alertcondition(qualBecameWeak,  "Trend quality became Weak",  "{{ticker}} ({{interval}}): regression R² fell into the Weak zone")
alertcondition(dirFlipUp,       "Regression slope turned Up",   "{{ticker}} ({{interval}}): regression slope turned Up")
alertcondition(dirFlipDn,       "Regression slope turned Down", "{{ticker}} ({{interval}}): regression slope turned Down")
alertcondition(brokeAbove,      "Price crossed above channel", "{{ticker}} ({{interval}}): price crossed above the regression channel")
alertcondition(brokeBelow,      "Price crossed below channel", "{{ticker}} ({{interval}}): price crossed below the regression channel")
````
