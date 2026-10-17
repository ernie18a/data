# Z-Score Flow Pro [JOAT]

- url: https://www.tradingview.com/script/VPH1J8IW-Z-Score-Flow-Pro-JOAT/
- type: indicator
- pine_id: PUB;4ffbbbf51f274f78ab03bcd4c820e7e5
- version: 1.0

## Description

[b]Z-SCORE FLOW PRO [JOAT][/b]

A rigorously-statistical mean-reversion oscillator built on top of two of the cleanest primitives in market analysis — the [b]Z-score[/b] of price against its own rolling mean and the [b]EMA-smoothed RSI[/b] — and wrapped in a regime-aware visual and signal pipeline that knows when [i]not[/i] to fire.

[image]https://www.tradingview.com/x/orYfK1bd/[/image]

[b]Why Z-score[/b]

A Z-score answers the question every reversion trader is really asking: "How many standard deviations is price from where it usually sits?" It is regime-aware by construction — when realised volatility expands, the same dollar move produces a smaller Z; when it contracts, the same dollar move produces a larger Z. That means the signal levels (Z = ±2, ±3, etc.) carry [i]the same statistical meaning[/i] across instruments and timeframes, which a price-distance level never does.

Z-Score Flow Pro uses:

[list]
[*] [b]Z-score core[/b] — close vs SMA basis, normalised by rolling stdev, over a configurable lookback (default 100).
[*] [b]EMA trend filter[/b] — a long EMA (default 50) decides which side of the chart the engine considers in-regime. Signals are weighted by regime alignment, not blindly suppressed.
[*] [b]Smoothed RSI[/b] — RSI is computed, then EMA-smoothed (default 8-bar) to eliminate the single-bar whipsaws that plague the raw indicator without re-introducing visible lag.
[/list]

A signal needs [b]both[/b] the Z-score and the smoothed RSI to be at extremes on the same side — that AND-gating is what removes most of the false signals that pure RSI or pure Z systems produce.

[b]Signal engine[/b]

A Buy signal requires Z ≤ Buy threshold (default −2.0) [i]and[/i] smoothed RSI ≤ oversold level (default 30). A Sell signal requires Z ≥ Sell threshold (default +2.0) [i]and[/i] smoothed RSI ≥ overbought level (default 70). A configurable cooldown prevents back-to-back signals; the labels respect the EMA regime filter so the strongest read is when signal direction agrees with the EMA trend.

[b]Background heatmap (JOAT enhancement)[/b]

The chart pane is tinted bull or bear with an intensity proportional to |Z|. The mapping is linear: at Z = 0 the heatmap is nearly invisible, at |Z| = the saturation threshold (default 1.5) the tint reaches its loudest configured opacity. Both ends are tunable, so you can dial the heatmap from "barely there" to "institutional cockpit". This is the cleanest at-a-glance read of how stretched the market is right now — you do not need to read the Z value itself.

[b]Divergence engine (JOAT enhancement)[/b]

A slope-comparison divergence runs in parallel: it compares the slope of the Z-score against the slope of price over a configurable lookback. A bullish divergence requires price slope negative and Z slope positive; bearish is the mirror. Both slopes must exceed a small epsilon to suppress flat-region noise, and a divergence cooldown spaces them out. Divergences print directly in the chart pane in the palette colour.

[b]Slope-coloured Z-mean line[/b]

The Z-score's own running mean is plotted as a slope-coloured ribbon: bull / bear / flat colours based on the slope over a configurable sensitivity window. The shadow underneath the line uses an alpha-modulated version of the same colour so the line visually [i]breathes[/i] with regime.

[image]https://www.tradingview.com/x/9s8X3yjz/[/image]

[b]Dashboard[/b]

A compact monospaced table, positionable to any of nine corners, with togglable cell transparency. Rows surface:

[list]
[*] Current Z-score and its direction (Rising / Falling / Flat).
[*] One-year (252-bar) percentile of Z — how unusual the current reading is in its own recent history.
[*] Smoothed RSI and its slope direction.
[*] Active EMA regime (Up / Down / Neutral).
[*] Distance of Z from its own min/max range (position-in-Z, 0–100%).
[/list]

[b]Alerts[/b]

Alerts are exposed for buy / sell signals, divergences, regime flips, and a configurable [b]Z-extreme[/b] alert that fires when |Z| crosses a user-set high level (default 3.0). The extreme alert is the cleanest "the market is genuinely far from home" trigger this script produces and is suitable for end-of-day notification workflows.

[b]How to read it[/b]

Three reads, in order of conviction:

[list=1]
[*] [b]Background heatmap[/b] — a glance tells you whether you are in a normal-Z regime (no tint) or stretched (bright tint). Most of the time, do nothing.
[*] [b]Signal labels[/b] — fade extremes only when both Z and RSI agree, and respect the EMA regime — counter-trend trades into a sustained EMA-aligned move are lower-conviction by definition.
[*] [b]Divergences[/b] — the highest-conviction reads. A bullish divergence with the heatmap saturated bear and the signal in the right direction is the cleanest setup the engine can produce.
[/list]

[b]Suggested settings[/b]

Defaults are tuned for 1H–4H on liquid markets. For 5m–15m, drop Z period to 50 and RSI period to 9. For daily and above, raise Z period to 200 and EMA trend filter to 100. The thresholds (±2.0 Z, 30/70 RSI) are intentionally classic — they correspond to the textbook two-sigma deviation and are well-understood; loosen them only if you are running on a less-liquid instrument.

[b]Originality / what's reused[/b]

Z-score and RSI are public-domain mathematics, used here as primitives. The implementation — the smoothed-RSI gating, the slope-coloured Z-mean line with alpha shadow, the |Z|-driven background heatmap, the 252-bar percentile rank, the divergence epsilon filter, and the AND-gated signal pipeline — is JOAT-original and tuned together. No third-party code reused.

[b]Open source[/b]

Published open-source under the default Mozilla Public License 2.0. Every section is banner-headed, every helper is documented inline, every input carries a tooltip. The Z-mean line, the heatmap, the divergence engine, and the dashboard are each in their own isolated module so you can study or adapt any single piece without reading the whole file.

[b]Limitations[/b]

Z-score mean-reversion is a counter-trend tool by definition. In sustained one-sided trends the Z will live at an extreme for many bars and the signals will give back giveback — the EMA regime filter exists to warn you when you are in this state. The 252-bar percentile rank needs ~1 year of data to be meaningful; on shorter histories it warms up to neutral. Divergences are non-repainting but carry the natural lag of slope-over-window comparison.

—

-made with passion by jackofalltrades

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator(title="Z-Score Flow Pro [JOAT]", shorttitle="ZSF [JOAT]", overlay=true,
     max_lines_count=500, max_boxes_count=500, max_labels_count=500, max_bars_back=5000)


// =============================================================================
//  SECTION 1 - INPUTS
// =============================================================================

grpZ      = "+----- Z-Score Engine -----+"
grpVis    = "+----- Visuals -----+"
grpDash   = "+----- Dashboard -----+"
grpDiv    = "+----- Divergence (NEW) -----+"
grpHeat   = "+----- Background Heatmap (NEW) -----+"
grpAlert  = "+----- Alerts -----+"

// ----- Z-Score Engine ---------------------------------------------------------
zLen          = input.int(100, "Z-Score Period",       minval=5,  maxval=2000, group=grpZ, tooltip="Lookback used for SMA basis and rolling stdev that builds the Z-score.")
emaTrendLen   = input.int(50,  "EMA Trend Filter",     minval=2,  maxval=2000, group=grpZ, tooltip="Long EMA used as the regime filter. close > EMA = up regime.")
rsiLen        = input.int(14,  "RSI Length",           minval=2,  maxval=200,  group=grpZ)
rsiEmaLen     = input.int(8,   "EMA of RSI Period",    minval=1,  maxval=100,  group=grpZ, tooltip="Smoother applied on top of RSI to suppress whipsaw.")
zBuyLevel     = input.float(-2.0, "Z-Score Buy Threshold",  step=0.1, group=grpZ)
zSellLevel    = input.float( 2.0, "Z-Score Sell Threshold", step=0.1, group=grpZ)
rsiOversold   = input.int(30, "RSI Oversold",  minval=1, maxval=49, group=grpZ)
rsiOverbought = input.int(70, "RSI Overbought", minval=51, maxval=99, group=grpZ)
cooldownBars  = input.int(10,  "Cooldown (Bars)",      minval=0,  maxval=200,  group=grpZ, tooltip="Minimum bar gap between an opposite-side signal and a fresh same-side signal.")
slopeIndex    = input.int(30,  "Slope Sensitivity",    minval=1,  maxval=200,  group=grpZ, tooltip="Lookback for slope-based colour of the Z-mean line.")

// ----- Visuals ----------------------------------------------------------------
showMeanLine    = input.bool(true,  "Show Z-Score Mean Line",     group=grpVis)
shadowWidth     = input.int(10,    "Z-Mean Shadow Width", minval=1, maxval=20, group=grpVis)
lineWidth       = input.int(2,     "Z-Mean Line Width",   minval=1, maxval=10, group=grpVis)
showGradient    = input.bool(true,  "Show Gradient Fill (basis<->price)", group=grpVis)
gradTransparency= input.int(75,    "Gradient Transparency",     minval=0, maxval=100, group=grpVis, tooltip="0 = solid, 100 = invisible. Gradient between basis and price.")
showLabels      = input.bool(true,  "Show Buy/Sell Labels",     group=grpVis)
labelSize       = input.string("Small", "Label Size", options=["Tiny","Small","Normal","Large","Huge"], group=grpVis)

// ----- Dashboard --------------------------------------------------------------
showDash       = input.bool(true, "Show Dashboard", group=grpDash)
dashPosStr     = input.string("Top Right", "Dashboard Position",
     options=["Top Right","Top Left","Top Center","Middle Right","Middle Left","Middle Center","Bottom Right","Bottom Left","Bottom Center"],
     group=grpDash)
dashSizeStr    = input.string("Small", "Dashboard Text Size",
     options=["Tiny","Small","Normal","Large","Huge"], group=grpDash)
dashTransp     = input.int(80, "Cell Transparency", minval=0, maxval=100, group=grpDash)

// ----- Divergence (NEW) -------------------------------------------------------
showDiv        = input.bool(true, "Detect Divergence", group=grpDiv)
divLen         = input.int(14, "Divergence Lookback (bars)", minval=3, maxval=200, group=grpDiv, tooltip="Slope of Z compared to slope of price over this many bars.")
divLabel       = input.bool(true, "Plot Divergence Label", group=grpDiv)
divCooldown    = input.int(15, "Divergence Cooldown", minval=1, maxval=100, group=grpDiv, tooltip="Minimum bars between successive divergence labels.")
divEpsilon     = input.float(0.0001, "Divergence Slope Epsilon", step=0.0001, group=grpDiv, tooltip="Minimum |slope| considered non-flat. Prevents noise-triggered divergences.")

// ----- Heatmap (NEW) ----------------------------------------------------------
showHeat       = input.bool(true, "Show Background Heatmap", group=grpHeat)
heatThreshold  = input.float(1.5, "|Z| at which heatmap saturates", step=0.1, minval=0.5, maxval=5.0, group=grpHeat)
heatMaxAlpha   = input.int(70, "Min transparency at saturation", minval=30, maxval=99, group=grpHeat, tooltip="Lower = more visible at extreme Z. 70 is reasonable, 50 makes it loud.")
heatMinAlpha   = input.int(95, "Max transparency at zero", minval=70, maxval=100, group=grpHeat)

// ----- Alerts -----------------------------------------------------------------
zExtreme       = input.float(3.0, "Z Extreme Alert |Z|", step=0.5, minval=1.0, maxval=10.0, group=grpAlert)


// =============================================================================
//  SECTION 2 - COLOR PALETTE  (Vibrant - locked)
// =============================================================================
// Curated palette - spring green / orange-red on a dark blue ground, with a
// vivid yellow neutral for mid-range states.
const color C_BULL    = #00FF7F   // spring green
const color C_BEAR    = #FF4500   // orange-red
const color C_NEUTRAL = #FFFF00   // yellow (flat / mid-range)
const color C_BG      = #00008B   // dark blue
const color C_FRAME   = #1A1A6E   // deep indigo frame

// Downstream aliases (preserve original symbol names)
color bullColor = C_BULL
color bearColor = C_BEAR
color flatColor = C_NEUTRAL
color bgRaw     = C_BG
color frameCol  = C_FRAME


// =============================================================================
//  SECTION 3 - HELPER FUNCTIONS
//      - f_colorGradient       (KB 2.1)
//      - f_clamp               (KB 2.3)
//      - strToPos / strToSize  (KB 2.4)
//      - heatAlpha             (linear ramp from minAlpha at z=0 to maxAlpha at threshold)
// =============================================================================

// ----- f_colorGradient: linear interp between two colours by 0..1 ratio ------
f_colorGradient(float _ratio, color _colA, color _colB) =>
    rA = color.r(_colA), gA = color.g(_colA), bA = color.b(_colA)
    rB = color.r(_colB), gB = color.g(_colB), bB = color.b(_colB)
    rr = rA + int((rB - rA) * _ratio)
    rg = gA + int((gB - gA) * _ratio)
    rb = bA + int((bB - bA) * _ratio)
    color.rgb(rr, rg, rb, 0)

// ----- f_clamp ---------------------------------------------------------------
f_clamp(float _x, float _min, float _max) => math.max(_min, math.min(_x, _max))

// ----- strToPos --------------------------------------------------------------
strToPos(string s) =>
    switch s
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        =>               position.bottom_right

// ----- strToSize -------------------------------------------------------------
strToSize(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        =>          size.normal

// ----- heatAlpha: maps |Z| in [0, threshold] to transparency in [maxA, minA] -
heatAlpha(float absZ, float threshold, int minA, int maxA) =>
    // minA = MIN transparency value (loudest when |Z| is high)
    // maxA = MAX transparency value (almost invisible when |Z| is near zero)
    // KB note: lower transparency = more visible, so we INVERT mapping.
    pct = f_clamp(absZ / math.max(threshold, 0.0001), 0.0, 1.0)
    int(maxA - (maxA - minA) * pct)


// =============================================================================
//  SECTION 4 - CORE CALCULATIONS
//      Z-score, EMA trend filter, RSI + EMA-of-RSI smoothing, slopes
// =============================================================================

// ----- Z-score core ----------------------------------------------------------
basis     = ta.sma(close, zLen)
sdev      = ta.stdev(close, zLen)
zscore    = sdev > 0 ? (close - basis) / sdev : 0.0

// ----- EMA trend filter ------------------------------------------------------
emaTrend  = ta.ema(close, emaTrendLen)
isUptrend   = close > emaTrend
isDowntrend = close < emaTrend

// ----- RSI + EMA smoothing ---------------------------------------------------
rsiVal      = ta.rsi(close, rsiLen)
rsiEma      = ta.ema(rsiVal, rsiEmaLen)
rsiEmaSlope = rsiEma - nz(rsiEma[1], rsiEma)

// ----- Z statistics ----------------------------------------------------------
z_max     = ta.highest(zscore, zLen)
z_min     = ta.lowest(zscore,  zLen)
z_mean    = ta.sma(zscore, zLen)
z_range   = z_max - z_min
z_position= z_range > 0 ? (zscore - z_min) / z_range : 0.5
z_dev     = zscore - z_mean

// ----- 1-year (252-bar) percentile of Z (NEW JOAT enhancement) --------------
zPercentile = ta.percentrank(zscore, 252)

// ----- Slope of basis for line colour ---------------------------------------
basisSlopeUp   = basis > basis[slopeIndex]
basisSlopeDn   = basis < basis[slopeIndex]
color slopeColor     = basisSlopeUp ? bullColor : basisSlopeDn ? bearColor : flatColor

// Alpha-weighted shadow colour (always a faded version of the slope colour)
color bullShadow = color.new(bullColor, 50)
color bearShadow = color.new(bearColor, 50)
color flatShadow = color.new(flatColor, 80)
color shadowColor = basisSlopeUp ? bullShadow : basisSlopeDn ? bearShadow : flatShadow

// ----- Z-direction text glyph (used in dashboard) ---------------------------
zTrendStr = zscore > nz(zscore[1], zscore) ? "Rising" : zscore < nz(zscore[1], zscore) ? "Falling" : "Flat"


// =============================================================================
//  SECTION 5 - STATE / TRACKING
//      Single-signal cross-side lockout (KB 6.2) + cooldown gate (KB 6.1)
// =============================================================================

var bool canBuy       = true
var bool canSell      = true
var int  lastBuyBar   = na
var int  lastSellBar  = na
var int  lastDivBar   = -1000

// Re-arm flags when RSI exits its zones
if rsiEma > rsiOversold
    canBuy := true
if rsiEma < rsiOverbought
    canSell := true

// RSI confirmations: oversold + rising slope + arm flag
rsiBuyConfirm  = rsiEma < rsiOversold   and rsiEmaSlope > 0 and canBuy
rsiSellConfirm = rsiEma > rsiOverbought and rsiEmaSlope < 0 and canSell


// =============================================================================
//  SECTION 6 - SIGNAL ENGINE
//      Trend + Z + RSI confluence stack, with cross-side cooldown
// =============================================================================

rawBuy  = zscore < zBuyLevel  and isDowntrend and rsiBuyConfirm
rawSell = zscore > zSellLevel and isUptrend   and rsiSellConfirm

// Cooldown vs the OPPOSITE signal (prevents instant flips). Confirmed bar
// gating ensures non-repainting BUY/SELL labels.
buySignal  = barstate.isconfirmed and rawBuy  and (na(lastSellBar) or (bar_index - lastSellBar) > cooldownBars)
sellSignal = barstate.isconfirmed and rawSell and (na(lastBuyBar)  or (bar_index - lastBuyBar)  > cooldownBars)

// Cross-side lockout: once a side has fired, lock that side until RSI exits
if buySignal
    canBuy     := false
    lastBuyBar := bar_index
if sellSignal
    canSell      := false
    lastSellBar  := bar_index

// =============================================================================
//  SECTION 6b - DIVERGENCE DETECTION (NEW JOAT enhancement)
//      Compare slope of Z-score vs slope of price over `divLen` bars.
//      Bull divergence: price slope < 0  AND  Z slope > 0   (price down, Z up)
//      Bear divergence: price slope > 0  AND  Z slope < 0   (price up, Z down)
// =============================================================================

priceNow  = close
priceThen = nz(close[divLen],  close)
zNow      = zscore
zThen     = nz(zscore[divLen], zscore)

// Normalise price slope to a comparable scale
priceSlope = priceThen != 0 ? (priceNow - priceThen) / priceThen : 0.0
zSlope     = zNow - zThen

bullDivRaw = showDiv and priceSlope < -divEpsilon and zSlope >  divEpsilon
bearDivRaw = showDiv and priceSlope >  divEpsilon and zSlope < -divEpsilon

// Cooldown to suppress noisy divergence labels
canEmitDiv = (bar_index - lastDivBar) >= divCooldown
bullDiv    = bullDivRaw and canEmitDiv
bearDiv    = bearDivRaw and canEmitDiv

if bullDiv or bearDiv
    lastDivBar := bar_index


// =============================================================================
//  SECTION 7 - PLOTS / FILLS / BACKGROUND HEATMAP
// =============================================================================

// ----- Z-Mean line + thick shadow underneath ---------------------------------
plot(showMeanLine ? basis : na, "Z-Mean Shadow", color=shadowColor, linewidth=shadowWidth)
plot(showMeanLine ? basis : na, "Z-Mean",        color=slopeColor,  linewidth=lineWidth)

// ----- Gradient fills basis<->price -----------------------------------------
//   Bullish zone (price BELOW basis): fill in bull colour to suggest reversion
//   Bearish zone (price ABOVE basis): fill in bear colour to suggest reversion
priceAbove = close > basis
priceBelow = close < basis

bullFillColor = color.new(bullColor, gradTransparency)
bearFillColor = color.new(bearColor, gradTransparency)

// We need plot IDs for fill(). Use display.none so they don't render lines.
pBasisBull = plot(showGradient and priceBelow ? basis : na, "Bull Basis Anchor", display=display.none)
pPriceBull = plot(showGradient and priceBelow ? close : na, "Bull Price Anchor", display=display.none)
pBasisBear = plot(showGradient and priceAbove ? basis : na, "Bear Basis Anchor", display=display.none)
pPriceBear = plot(showGradient and priceAbove ? close : na, "Bear Price Anchor", display=display.none)

fill(pBasisBull, pPriceBull, bullFillColor, "Bull Reversion Fill")
fill(pBasisBear, pPriceBear, bearFillColor, "Bear Reversion Fill")

// ----- Background heatmap (NEW JOAT enhancement) ----------------------------
//   bgcolor() that intensifies more red as Z > +1.5 and more green as Z < -1.5
//   Use the bear colour when Z is high (suggests reversion-down) and the bull
//   colour when Z is low (suggests reversion-up). This matches a mean-reversion
//   trader's visual cue: extreme red = "expect to come down".
absZ      = math.abs(zscore)
heatAlphaVal = heatAlpha(absZ, heatThreshold, heatMaxAlpha, heatMinAlpha)
heatBaseCol  = zscore >  0 ? bearColor : zscore < 0 ? bullColor : flatColor
heatColor    = color.new(heatBaseCol, heatAlphaVal)
bgcolor(showHeat ? heatColor : na, title="Z-Score Heatmap Background")


// =============================================================================
//  SECTION 8 - DRAWINGS / LABELS / SIGNAL SHAPES
// =============================================================================

labSize = strToSize(labelSize)

// ----- BUY / SELL labels (script font, per spec)
plotshape(showLabels and buySignal,
     title    = "Buy",
     location = location.belowbar,
     color    = bullColor,
     style    = shape.labelup,
     text     = "Buy",
     textcolor = color.black,
     size     = size.small)

plotshape(showLabels and sellSignal,
     title    = "Sell",
     location = location.abovebar,
     color    = bearColor,
     style    = shape.labeldown,
     text     = "Sell",
     textcolor = color.white,
     size     = size.small)

// ----- Divergence labels (NEW) ----------------------------------------------
//   Use label.new for richer styling than plotshape
if divLabel and bullDiv
    label.new(bar_index, low,
         text      = "Bull Div",
         style     = label.style_label_up,
         color     = color.new(bullColor, 20),
         textcolor = color.black,
         size      = labSize,
         tooltip   = "Bullish divergence: price made a lower close while Z-score sloped up over the lookback. Possible bottom forming.")
if divLabel and bearDiv
    label.new(bar_index, high,
         text      = "Bear Div",
         style     = label.style_label_down,
         color     = color.new(bearColor, 20),
         textcolor = color.white,
         size      = labSize,
         tooltip   = "Bearish divergence: price made a higher close while Z-score sloped down over the lookback. Possible top forming.")


// =============================================================================
//  SECTION 9 - DASHBOARD
//      8-row fancy unicode dashboard (per spec):
//        0 - METRIC / VALUE header
//        1 - Current Z
//        2 - Mean Z
//        3 - Position % within Z range
//        4 - Min / Max Z
//        5 - Trend direction
//        6 - Percentile (1y) (NEW)
//        7 - Divergence (NEW)
// =============================================================================

dashPos    = strToPos(dashPosStr)
dashSize   = strToSize(dashSizeStr)

// Use the theme's bg + frame for dashboard chrome
hdrBg      = color.new(frameCol,  20)
cellBg     = color.new(bgRaw,     dashTransp)
hdrText    = color.white
cellText   = color.white

var table tbl = table.new(dashPos, 2, 8,
     bgcolor      = na,
     frame_color  = frameCol,
     frame_width  = 1,
     border_color = color.new(frameCol, 65),
     border_width = 1)

// Dashboard re-renders only on the last bar to avoid wasted draws
if barstate.islast and showDash
    // ----- Header row -----------------------------------------------------
    table.cell(tbl, 0, 0, "𝓜𝓔𝓣𝓡𝓘𝓒",
         text_color   = hdrText,
         bgcolor      = hdrBg,
         text_halign  = text.align_center,
         text_valign  = text.align_center,
         text_size    = dashSize)
    table.cell(tbl, 1, 0, "𝓥𝓐𝓛𝓤𝓔",
         text_color   = hdrText,
         bgcolor      = hdrBg,
         text_halign  = text.align_center,
         text_valign  = text.align_center,
         text_size    = dashSize)

    // ----- Row 1: Current Z ----------------------------------------------
    table.cell(tbl, 0, 1, "𝓒𝓾𝓻𝓻𝓮𝓷𝓽",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    zCurCol = zscore > 0 ? bearColor : zscore < 0 ? bullColor : flatColor
    table.cell(tbl, 1, 1, str.tostring(zscore, "0.000"),
         text_color = zCurCol, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right)

    // ----- Row 2: Z mean -------------------------------------------------
    table.cell(tbl, 0, 2, "𝓜𝓮𝓪𝓷",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    table.cell(tbl, 1, 2, str.tostring(z_mean, "0.000"),
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right)

    // ----- Row 3: Position within rolling Z range ------------------------
    table.cell(tbl, 0, 3, "𝓟𝓸𝓼𝓲𝓽𝓲𝓸𝓷",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    posCol = z_position > 0.66 ? bearColor : z_position < 0.34 ? bullColor : flatColor
    table.cell(tbl, 1, 3, str.tostring(z_position * 100, "0.0") + "%",
         text_color = posCol, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right)

    // ----- Row 4: Min / Max ----------------------------------------------
    table.cell(tbl, 0, 4, "𝓜𝓲𝓷 / 𝓜𝓪𝔁",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    table.cell(tbl, 1, 4, str.tostring(z_min, "0.00") + " / " + str.tostring(z_max, "0.00"),
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right)

    // ----- Row 5: Trend (Rising / Falling / Flat) ------------------------
    table.cell(tbl, 0, 5, "𝓣𝓻𝓮𝓷𝓭",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    trendCol = zTrendStr == "Rising" ? bullColor : zTrendStr == "Falling" ? bearColor : flatColor
    table.cell(tbl, 1, 5, zTrendStr,
         text_color = trendCol, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right)

    // ----- Row 6: Percentile (1y) (NEW) ----------------------------------
    table.cell(tbl, 0, 6, "𝓟𝓮𝓻𝓬𝓮𝓷𝓽𝓲𝓵𝓮",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    pctRatio = f_clamp(zPercentile / 100.0, 0.0, 1.0)
    pctCol   = pctRatio > 0.5 ? f_colorGradient((pctRatio - 0.5) * 2.0, flatColor, bearColor)
                              : f_colorGradient((0.5 - pctRatio) * 2.0, flatColor, bullColor)
    pctText  = str.tostring(zPercentile, "0.0") + "%"
    table.cell(tbl, 1, 6, pctText,
         text_color = pctCol, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right)

    // ----- Row 7: Divergence (NEW) ---------------------------------------
    table.cell(tbl, 0, 7, "𝓓𝓲𝓿𝓮𝓻𝓰𝓮𝓷𝓬𝓮",
         text_color = cellText, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_left)
    divStr = bullDiv ? "Bull div" : bearDiv ? "Bear div" : "—"
    divCol = bullDiv ? bullColor   : bearDiv ? bearColor   : flatColor
    table.cell(tbl, 1, 7, divStr,
         text_color = divCol, bgcolor = cellBg,
         text_size  = dashSize, text_halign = text.align_right)


// =============================================================================
//  SECTION 10 - ALERTS
// =============================================================================

alertcondition(buySignal,
     title   = "Z-Score Buy Signal",
     message = "ZSF [JOAT] BUY: Z-score below threshold + downtrend + RSI oversold confirm.")

alertcondition(sellSignal,
     title   = "Z-Score Sell Signal",
     message = "ZSF [JOAT] SELL: Z-score above threshold + uptrend + RSI overbought confirm.")

alertcondition(absZ >= zExtreme,
     title   = "Z-Score Extreme",
     message = "ZSF [JOAT] EXTREME: |Z| has crossed the extreme threshold.")

alertcondition(bullDiv,
     title   = "Bullish Divergence",
     message = "ZSF [JOAT] BULL DIV: Price down, Z-score up over divLen bars.")

alertcondition(bearDiv,
     title   = "Bearish Divergence",
     message = "ZSF [JOAT] BEAR DIV: Price up, Z-score down over divLen bars.")


// =============================================================================
//  END OF FILE - Z-Score Flow Pro [JOAT]
// =============================================================================
````
