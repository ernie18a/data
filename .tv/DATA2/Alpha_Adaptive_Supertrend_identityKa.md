<!-- tradingview-pine-id: PUB;8d6ec1ae6eb448388f9ffe0a7138de1a -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Alpha Adaptive Supertrend [identityKa]

Source: https://www.tradingview.com/script/wrxWVnZF/

## Description

Alpha Adaptive Supertrend [identityKa]

A Supertrend that adjusts its own room for volatility.

The classic Supertrend uses a fixed ATR multiplier. That works when volatility is stable, but volatility is not stable: it compresses and expands in cycles. A multiplier that feels right in a quiet market is too tight in a violent one, and one that survives a violent market is too loose in a quiet one. This version lets the multiplier follow where volatility currently sits relative to its own history.

HOW IT WORKS

1. ATR percentile: the current ATR is ranked against its own last N bars (default 200) on a 0 to 100 scale. 0 means volatility is at the low end of its recent range, 100 means it is at the high end.
2. Adaptive multiplier: the multiplier moves linearly between two settings using that rank.
   - Compressed volatility: tighter multiplier (default 2.0)
   - Elevated volatility: wider multiplier (default 4.0)
   - At the 50th percentile the multiplier is the midpoint (default 3.0, the classic value)
3. Supertrend logic: the bands are built from the source plus and minus multiplier x ATR. The lower band can only rise while the trend is bullish, the upper band can only fall while the trend is bearish. The trend flips when price closes through the active band.

Why the percentile matters: ATR already scales with volatility, so a Supertrend already gets wider in volatile markets. The adaptation adds a second-order response, tighter when the market is unusually quiet and wider when it is unusually wild, relative to that specific market's own behavior. Because it uses a percentile rank, the same defaults transfer across crypto, stocks, indices and FX without manual retuning.

WHAT YOU SEE

- Bullish line below price and bearish line above price, with a soft fill toward the source
- Small triangles on the bar where the trend flips
- Dashboard: Trend State, Trend Age, current trailing line level, distance to line (in ATR and %), volatility state with its percentile, and the multiplier currently in use

HOW TO USE IT

- Use the line as a trend-direction reference and as a volatility-aware reference level for your own risk planning.
- Trend Age helps you see how mature the current leg is.
- The volatility row tells you why the line is where it is: when it shows Elevated, the line intentionally gives price more room.
- Like any Supertrend, it works best when the market is trending. In sideways markets it can flip repeatedly. Pair it with a regime tool, for example Alpha Regime Dashboard, to know which environment you are in.

SETTINGS

- Calculation: source, ATR length, rank window, multipliers for compressed and elevated volatility
- Volatility Rules: percentile levels for the Compressed and Elevated labels
- Display: colors, fill, flip markers, bar coloring
- Dashboard: position, text size, footer

ALERTS

Trend flipped Bullish, flipped Bearish, flipped in either direction, volatility became Elevated, volatility became Compressed. For stable, non-repainting triggers, set the alert to Once Per Bar Close.

NOTES AND LIMITATIONS

- The line reacts to closed prices, so it is a lagging tool by design.
- The percentile needs history. In the first bars the multiplier uses the midpoint.
- Values on the current, unfinished bar can change until the bar closes.

This script is for educational and informational purposes only and is not financial advice. Past behavior does not guarantee future results.

Part of the Alpha Quant Toolkit by identityKa. See also: Alpha Regime Dashboard [identityKa], Alpha ER Regime Bands [identityKa].

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © IdentityKa
//
// Alpha Quant Toolkit · #03 Adaptive Supertrend
// A Supertrend whose ATR multiplier is driven by the percentile rank of current volatility
// against its own history: tighter when volatility is compressed, wider when it is elevated.

//@version=6
indicator("Alpha Adaptive Supertrend [identityKa]", shorttitle="AQ AdaptiveST", overlay=true)

// ═══════════════════════════════════════════════════════════════
//  CONSTANTS
// ═══════════════════════════════════════════════════════════════
const string GRP_CALC = "Calculation"
const string GRP_RULE = "Volatility Rules"
const string GRP_VIS  = "Display"
const string GRP_DASH = "Dashboard"
const string BRAND    = "Alpha Quant Toolkit · identityKa"

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
src     = input.source(hl2, "Source", group=GRP_CALC)
lenATR  = input.int(10, "ATR Length", minval=2, group=GRP_CALC)
rankLen = input.int(200, "Volatility Rank Window", minval=50, maxval=1000, group=GRP_CALC,
     tooltip="Current ATR is ranked against its own last N bars (percentile 0-100). This rank drives the multiplier.")
minMult = input.float(2.0, "Multiplier · Compressed Volatility", minval=0.5, step=0.1, group=GRP_CALC,
     tooltip="Multiplier used when ATR percentile is 0 (volatility very low versus its own history).")
maxMult = input.float(4.0, "Multiplier · Elevated Volatility", minval=0.5, step=0.1, group=GRP_CALC,
     tooltip="Multiplier used when ATR percentile is 100 (volatility very high versus its own history). At the 50th percentile the multiplier is the midpoint of the two settings.")

lowVol  = input.float(25, "Compressed Below (percentile)", minval=5, maxval=45, step=1, group=GRP_RULE)
highVol = input.float(75, "Elevated Above (percentile)", minval=55, maxval=95, step=1, group=GRP_RULE)

cUp   = input.color(#19D3A2, "Bullish", group=GRP_VIS, inline="c1")
cDn   = input.color(#FF4D6A, "Bearish", group=GRP_VIS, inline="c1")
cWarn = input.color(#FFB020, "Elevated Volatility", group=GRP_VIS, inline="c2")
showFill  = input.bool(true, "Show trend fill", group=GRP_VIS)
showFlips = input.bool(true, "Show trend flip markers", group=GRP_VIS)
colorBars = input.bool(false, "Color bars by trend", group=GRP_VIS)

showTable = input.bool(true, "Show Dashboard", group=GRP_DASH)
posInput  = input.string("Top Right", "Position", options=["Top Left", "Top Right", "Bottom Left", "Bottom Right"], group=GRP_DASH)
sizeInput = input.string("Normal", "Text Size", options=["Small", "Normal", "Large"], group=GRP_DASH)
showBrand = input.bool(true, "Show footer", group=GRP_DASH)

// ═══════════════════════════════════════════════════════════════
//  CALCULATION
// ═══════════════════════════════════════════════════════════════
atrVal = ta.atr(lenATR)
pctl   = ta.percentrank(atrVal, rankLen)          // 0..100 vs own history

loM  = math.min(minMult, maxMult)
hiM  = math.max(minMult, maxMult)
mult = loM + (hiM - loM) * nz(pctl, 50.0) / 100.0

upperBasic = src + mult * atrVal
lowerBasic = src - mult * atrVal

var float fu    = na
var float fl    = na
var int   trend = 1        // 1 = bullish (line below price), -1 = bearish (line above price)

fuPrev = nz(fu[1], upperBasic)
flPrev = nz(fl[1], lowerBasic)

fu := (upperBasic < fuPrev or close[1] > fuPrev) ? upperBasic : fuPrev
fl := (lowerBasic > flPrev or close[1] < flPrev) ? lowerBasic : flPrev

trendPrev = nz(trend[1], 1)
trend := trendPrev == 1 ? (close < fl ? -1 : 1) : (close > fu ? 1 : -1)

stLine = trend == 1 ? fl : fu
ready  = not na(stLine)

flipped = ready and trend != trendPrev
flipUp  = flipped and trend == 1
flipDn  = flipped and trend == -1

var int age = 0
age := flipped ? 1 : age + 1

// Volatility regime label: 2 elevated, 1 normal, 0 compressed
volCode = pctl >= highVol ? 2 : pctl <= lowVol ? 0 : 1
volText = na(pctl) ? "—" : volCode == 2 ? "Elevated" : volCode == 0 ? "Compressed" : "Normal"

distATR = (na(atrVal) or atrVal == 0) ? na : math.abs(close - stLine) / atrVal
distPct = (na(stLine) or close == 0) ? na : math.abs(close - stLine) / close * 100.0

// ═══════════════════════════════════════════════════════════════
//  PLOTS
// ═══════════════════════════════════════════════════════════════
pMid = plot(ready ? src : na, "Source (fill anchor)", display=display.none)
pUp  = plot(ready and trend == 1  ? fl : na, "Bullish Line", color=cUp, linewidth=2, style=plot.style_linebr)
pDn  = plot(ready and trend == -1 ? fu : na, "Bearish Line", color=cDn, linewidth=2, style=plot.style_linebr)

fill(pMid, pUp, color=showFill ? color.new(cUp, 88) : na, title="Bullish Fill")
fill(pMid, pDn, color=showFill ? color.new(cDn, 88) : na, title="Bearish Fill")

plotshape(showFlips and flipUp, "Trend Flip Up",   style=shape.triangleup,   location=location.belowbar, color=cUp, size=size.tiny)
plotshape(showFlips and flipDn, "Trend Flip Down", style=shape.triangledown, location=location.abovebar, color=cDn, size=size.tiny)

barcolor(colorBars and ready ? (trend == 1 ? cUp : cDn) : na)

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
    trendText = not ready ? "Warming up" : trend == 1 ? "Bullish" : "Bearish"
    trendCol  = not ready ? cDim : trend == 1 ? cUp : cDn
    volCol    = volCode == 2 ? cWarn : cTxt

    table.cell(dash, 0, 0, "ADAPTIVE SUPERTREND", text_color=cTxt, text_size=txtSize, text_halign=text.align_center, bgcolor=color.new(#1B2440, 0))
    table.merge_cells(dash, 0, 0, 1, 0)

    table.cell(dash, 0, 1, "Trend State", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 1, trendText, text_color=trendCol, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 2, "Trend Age", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 2, ready ? str.tostring(age) + " bars" : "—", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 3, "Trailing Line", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 3, ready ? str.tostring(stLine, format.mintick) : "—", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 4, "Distance to Line", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 4, fmt(distATR, 2) + " ATR  (" + fmt(distPct, 2) + "%)", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 5, "Volatility (ATR pctl)", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 5, volText + "  (P" + fmt(pctl, 0) + ")", text_color=volCol, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 6, "Active Multiplier", text_color=cDim, text_size=txtSize, text_halign=text.align_left)
    table.cell(dash, 1, 6, fmt(mult, 2) + " x ATR", text_color=cTxt, text_size=txtSize, text_halign=text.align_right)

    table.cell(dash, 0, 7, showBrand ? BRAND : "", text_color=cDim, text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dash, 0, 7, 1, 7)

// ═══════════════════════════════════════════════════════════════
//  ALERTS  (set to "Once Per Bar Close" for stable, non-repainting triggers)
// ═══════════════════════════════════════════════════════════════
volChanged = ready and ta.change(volCode) != 0

alertcondition(flipUp,                        "Trend flipped Bullish",     "{{ticker}} ({{interval}}): Adaptive Supertrend flipped Bullish")
alertcondition(flipDn,                        "Trend flipped Bearish",     "{{ticker}} ({{interval}}): Adaptive Supertrend flipped Bearish")
alertcondition(flipped,                       "Trend flipped (any)",       "{{ticker}} ({{interval}}): Adaptive Supertrend changed direction")
alertcondition(volChanged and volCode == 2,   "Volatility became Elevated",   "{{ticker}} ({{interval}}): volatility rank is now Elevated, multiplier widened")
alertcondition(volChanged and volCode == 0,   "Volatility became Compressed", "{{ticker}} ({{interval}}): volatility rank is now Compressed, multiplier tightened")
````
