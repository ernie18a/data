# RichmondHillCM - Log-Price Regression Channel V1.2

- url: https://www.tradingview.com/script/ubJjM0O1-RichmondHillCM-Log-Price-Regression-Channel-V1-2/
- type: indicator
- pine_id: PUB;22e72996193448ccaf474b5594ebde7f
- version: 1.0

## Description

[b]RichmondHillCM - Log-Price Regression Channel V1.2[/b]

An OLS linear regression fitted to the logarithm of price, with standard-deviation bands (±1σ / ±2σ / ±3σ) projected around the fitted mean. Because the fit is done in log-space, the channel is geometric — it scales proportionally across very different price levels, which makes it well suited to long-trending instruments like SPY where a raw-price channel would distort.
⚠️ Designed for the WEEKLY (1W) timeframe. The default 252-bar lookback (~5 years of weekly data) and the band logic are tuned for weekly candles. A live banner at the top of the stats table turns red whenever the chart is not on a weekly timeframe.

[b]Features
[/b]
Log-space regression mean + ±1σ/±2σ/±3σ bands with optional fills
BUY / SELL labels on ±2σ crosses, optional STRONG BUY / SELL on ±3σ
Stats table: each band's price, % distance from current price, and Z-score
Background shading when price is stretched beyond ±2σ / ±3σ
Built-in alert conditions for every band cross and the mean

[b]How to use[/b]

Best suited to long-term growth compounders like Google (GOOGL, SPY, NDX). Use it on the weekly (1W) timeframe and set your price axis to logarithmic scale for the bands to line up correctly.

[b]Instrument: [/b]growth compounders / steady long-term trenders (e.g. GOOGL, MSFT, SPY)
Timeframe: weekly (1W)
Price axis: log scale (right-click the axis → "Logarithmic")

[b]How to read it: [/b]price drifting toward ±2σ/±3σ is unusually far from its own trend; the bands act like a statistical rubber band. Use band touches as context, not standalone entries.


[i]For research and educational purposes only. Not financial advice.[/i]

## Source Code

````pine
// ============================================================================
//  RichmondHillCM — Log-Price Linear Regression Channel + Sigma Bands
// ----------------------------------------------------------------------------
//  WHAT IT DOES
//  ------------
//  Fits an Ordinary-Least-Squares (OLS) linear regression to the *logarithm*
//  of price over a configurable lookback window, then projects standard-
//  deviation bands (±1σ / ±2σ / ±3σ) around that fitted mean. Because the
//  regression is computed in log-space, the resulting channel is geometric:
//  it respects the way equities actually compound, so the bands stay
//  proportionally consistent across very different price levels.
//
//  Works best on growth compounders (e.g. GOOGL), on the WEEKLY timeframe,
//  with the price axis set to LOG scale. Working in log-space matters most on
//  long, trending instruments, where a linear (raw-price) channel would be too
//  wide at the bottom and too tight at the top. The σ-bands therefore act as a
//  statistical "rubber band": price stretched toward ±2σ / ±3σ is unusually
//  far from its own trend.
//
//  >>> DESIGNED FOR THE WEEKLY (1W) TIMEFRAME — PRICE AXIS ON LOG SCALE <<<
//  The default 252-bar lookback and the σ-band logic are tuned for weekly
//  candles. On lower timeframes the channel becomes noisy and the signals
//  fire far too often. A live advisory banner at the TOP of the stats table
//  turns RED whenever the chart is not on a weekly timeframe.
//
//  NOT FINANCIAL ADVICE. For research / educational use only.
// ============================================================================

//@version=6
indicator(
     title            = "RichmondHillCM - Log-Price Regression Channel V1.2",
     shorttitle       = "RichmondHillCM - Log-Price Regression Channel V1.2",
     overlay          = true,               // draw on top of the price chart
     max_lines_count  = 500,
     max_labels_count = 500
 )

// ──────────────────────────────────────────────────────────────
// INPUTS
//   Grouped for a tidy settings panel. Each input is exposed so the
//   indicator can be re-tuned without touching the source code.
// ──────────────────────────────────────────────────────────────
grp_main    = "Regression Settings"
grp_bands   = "Sigma Band Display"
grp_style   = "Style"
grp_signals = "Buy / Sell Signals"
grp_table   = "Stats Table"

// Number of bars fed into the OLS regression. On a weekly chart, 252 bars
// ≈ ~5 years of data, which is the intended default for this tool.
lookback  = input.int(252, "Lookback Window (bars)",
             minval  = 30,
             maxval  = 5000,
             step    = 21,
             group   = grp_main,
             tooltip = "Number of bars for the OLS regression.\n" +
                       "On a WEEKLY chart: 52 = 1y | 104 = 2y | 252 = ~5y | 520 = ~10y\n" +
                       "On a DAILY chart:  21 = 1m | 63 = 1q | 126 = 6m | 252 = 1y")

// Price series the regression is run on (defaults to close).
src        = input.source(close, "Source", group=grp_main)

// Toggle which bands / overlays are visible.
show1s     = input.bool(true,  "Show ±1σ",                group=grp_bands)
show2s     = input.bool(true,  "Show ±2σ",                group=grp_bands)
show3s     = input.bool(true,  "Show ±3σ",                group=grp_bands)
showMid    = input.bool(true,  "Show Regression Mean",    group=grp_bands)
showFill   = input.bool(true,  "Fill Bands",              group=grp_bands)
showLabels = input.bool(true,  "Show End-of-Line Labels", group=grp_bands)

// Colours. Transparency (0-100) is baked into each colour via color.new().
colorMid  = input.color(color.new(#FFD700, 0),   "Mean Line",    group=grp_style)
colorUp1  = input.color(color.new(#26A69A, 70),  "1σ Up Fill",   group=grp_style)
colorDn1  = input.color(color.new(#EF5350, 70),  "1σ Down Fill", group=grp_style)
colorUp2  = input.color(color.new(#26A69A, 82),  "2σ Up Fill",   group=grp_style)
colorDn2  = input.color(color.new(#EF5350, 82),  "2σ Down Fill", group=grp_style)
colorUp3  = input.color(color.new(#26A69A, 91),  "3σ Up Fill",   group=grp_style)
colorDn3  = input.color(color.new(#EF5350, 91),  "3σ Down Fill", group=grp_style)
lw        = input.int(1, "Line Width", minval=1, maxval=4, group=grp_style)

labelSize = input.string("normal", "Label Size",
             options = ["tiny", "small", "normal", "large", "huge"],
             group   = grp_style)

// ── Signal inputs ──────────────────────────────────────────
// Signals fire when price *crosses* a band, not merely while it sits outside.
showBuy    = input.bool(true,  "Show BUY labels (cross below −2σ)",          group=grp_signals)
showSell   = input.bool(true,  "Show SELL labels (cross above +2σ)",         group=grp_signals)
showBuy3   = input.bool(false, "Show STRONG BUY labels (cross below −3σ)",   group=grp_signals)
showSell3  = input.bool(false, "Show STRONG SELL labels (cross above +3σ)",  group=grp_signals)
colorBuy   = input.color(color.new(#00C853, 0),  "BUY label colour",        group=grp_signals)
colorSell  = input.color(color.new(#FF1744, 0),  "SELL label colour",       group=grp_signals)

// ── Stats-table inputs ─────────────────────────────────────
// Show/hide the table and choose where it docks on the chart.
showTable  = input.bool(true, "Show Stats Table", group=grp_table)
tablePos   = input.string("Bottom Right", "Table Position",
             options = ["Top Left",    "Top Center",    "Top Right",
                        "Middle Left",  "Middle Center", "Middle Right",
                        "Bottom Left",  "Bottom Center", "Bottom Right"],
             group   = grp_table,
             tooltip = "Where the stats table docks on the chart.")

// ──────────────────────────────────────────────────────────────
// TIMEFRAME ADVISORY
//   This indicator is calibrated for the weekly timeframe. We detect the
//   current chart resolution so the stats-table banner can warn the user
//   when they are NOT on a weekly chart.
// ──────────────────────────────────────────────────────────────
isWeekly = timeframe.isweekly

// ──────────────────────────────────────────────────────────────
// LOG-PRICE LINEAR REGRESSION
//   ta.linreg returns the value of the regression line at the current bar
//   (offset 0). Running it on log(price) gives us the geometric trend.
// ──────────────────────────────────────────────────────────────
logP   = math.log(src)                 // work in log-space
regVal = ta.linreg(logP, lookback, 0)  // fitted mean (log units)

// ──────────────────────────────────────────────────────────────
// RESIDUAL STANDARD DEVIATION
//   We need the spread of price *around* the regression line, not the raw
//   spread of price. Decompose total variance into the part explained by the
//   trend (varFit) and the leftover residual variance (varRes):
//
//       varRes = var(logP) − cov(logP, t)² / var(t)
//
//   sigmaR (= √varRes) is the 1σ half-width of the channel, in log units.
// ──────────────────────────────────────────────────────────────
N      = lookback
varY   = math.pow(ta.stdev(logP, N), 2)                          // total variance of log-price
corr   = ta.correlation(logP, bar_index, N)                      // corr(logP, time)
covYT  = corr * ta.stdev(logP, N) * ta.stdev(bar_index, N)       // covariance(logP, time)
varT   = math.pow(ta.stdev(bar_index, N), 2)                     // variance of time
varFit = varT > 0 ? math.pow(covYT, 2) / varT : 0                // variance explained by the fit
varRes = math.max(varY - varFit, 0)                              // residual variance (clamped ≥ 0)
sigmaR = math.sqrt(varRes)                                       // residual σ (log units)

// ──────────────────────────────────────────────────────────────
// BAND LEVELS
//   Add k·σ in log-space, then exponentiate back to price-space.
//   math.exp() is the inverse of math.log(), so the bands return to real
//   price units and the channel becomes geometric.
// ──────────────────────────────────────────────────────────────
mid = math.exp(regVal)
up1 = math.exp(regVal + 1 * sigmaR)
dn1 = math.exp(regVal - 1 * sigmaR)
up2 = math.exp(regVal + 2 * sigmaR)
dn2 = math.exp(regVal - 2 * sigmaR)
up3 = math.exp(regVal + 3 * sigmaR)
dn3 = math.exp(regVal - 3 * sigmaR)

// ──────────────────────────────────────────────────────────────
// PLOTS
//   Each band gets its own plot so the fills below can reference them.
// ──────────────────────────────────────────────────────────────
pMid = plot(showMid ? mid : na, "Mean (regression)", color=colorMid,          linewidth=lw)
pUp1 = plot(show1s  ? up1 : na, "+1σ", color=color.new(#26A69A,  0),          linewidth=lw)
pDn1 = plot(show1s  ? dn1 : na, "-1σ", color=color.new(#EF5350,  0),          linewidth=lw)
pUp2 = plot(show2s  ? up2 : na, "+2σ", color=color.new(#26A69A, 30),          linewidth=lw)
pDn2 = plot(show2s  ? dn2 : na, "-2σ", color=color.new(#EF5350, 30),          linewidth=lw)
pUp3 = plot(show3s  ? up3 : na, "+3σ", color=color.new(#26A69A, 55),          linewidth=lw)
pDn3 = plot(show3s  ? dn3 : na, "-3σ", color=color.new(#EF5350, 55),          linewidth=lw)

// ── Fills ──────────────────────────────────────────────────
//   When showFill is off we push transparency to 100 (fully invisible)
//   instead of removing the fill, which keeps the plot pairing intact.
fill(pMid, pUp1, color=showFill ? colorUp1 : color.new(colorUp1, 100))
fill(pMid, pDn1, color=showFill ? colorDn1 : color.new(colorDn1, 100))
fill(pUp1, pUp2, color=showFill ? colorUp2 : color.new(colorUp2, 100))
fill(pDn1, pDn2, color=showFill ? colorDn2 : color.new(colorDn2, 100))
fill(pUp2, pUp3, color=showFill ? colorUp3 : color.new(colorUp3, 100))
fill(pDn2, pDn3, color=showFill ? colorDn3 : color.new(colorDn3, 100))

// ──────────────────────────────────────────────────────────────
// NUMBER FORMATTER
//   Formats a price into a compact, human-readable string:
//     • ≥ 1,000,000  → "1.23M"
//     • ≥ 1,000       → "1,234"
//     • otherwise     → "123.45"
// ──────────────────────────────────────────────────────────────
f_fmt(v) =>
    int whole    = math.floor(v)                       // integer part
    int thou     = whole / 1000                         // thousands
    int rem      = whole % 1000                         // remainder below 1000
    string cents = str.tostring(math.round((v - whole) * 100))
    string dec   = v >= 10 ? "" : "." + (str.length(cents) < 2 ? "0" + cents : cents)

    v >= 1000000 ?
         str.tostring(math.round(v / 1000000, 2)) + "M" :
     v >= 1000 ?
         str.tostring(thou) + "," + (rem < 10 ? "00" + str.tostring(rem) : rem < 100 ? "0" + str.tostring(rem) : str.tostring(rem)) :
     str.tostring(math.round(v, 2))

// ──────────────────────────────────────────────────────────────
// LABEL SIZE RESOLVER
//   Maps the user's text input to a Pine size.* constant.
// ──────────────────────────────────────────────────────────────
f_size() =>
    switch labelSize
        "tiny"  => size.tiny
        "small" => size.small
        "large" => size.large
        "huge"  => size.huge
        =>         size.normal

// ──────────────────────────────────────────────────────────────
// TABLE POSITION RESOLVER
//   Maps the "Table Position" dropdown to a Pine position.* constant.
// ──────────────────────────────────────────────────────────────
f_tablePos() =>
    switch tablePos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        =>                 position.bottom_right

// ──────────────────────────────────────────────────────────────
// END-OF-LINE LABELS
//   Drawn only on the last bar so we keep a single, clean label per band
//   floating just to the right of the most recent candle.
// ──────────────────────────────────────────────────────────────
f_label(yVal, txt, clr, show) =>
    if barstate.islast and show and showLabels
        label.new(
             x         = bar_index + 2,
             y         = yVal,
             text      = txt + "\n" + f_fmt(yVal),
             xloc      = xloc.bar_index,
             yloc      = yloc.price,
             color     = color.new(color.black, 80),
             textcolor = clr,
             style     = label.style_label_left,
             size      = f_size()
         )

f_label(up3, "+3σ",  color.new(#26A69A,  0), show3s)
f_label(up2, "+2σ",  color.new(#26A69A, 20), show2s)
f_label(up1, "+1σ",  color.new(#26A69A, 40), show1s)
f_label(mid, "Mean", colorMid,               showMid)
f_label(dn1, "-1σ",  color.new(#EF5350, 40), show1s)
f_label(dn2, "-2σ",  color.new(#EF5350, 20), show2s)
f_label(dn3, "-3σ",  color.new(#EF5350,  0), show3s)

// ──────────────────────────────────────────────────────────────
// BUY / SELL SIGNAL LABELS
//   Triggered on crossunder/crossover of the ±2σ and ±3σ bands.
//   Labels appear ON the bar where the cross occurs, pinned below
//   (BUY) or above (SELL) the candle for maximum clarity.
// ──────────────────────────────────────────────────────────────

// ±2σ signals — the standard mean-reversion triggers.
buySignal2  = ta.crossunder(src, dn2)
sellSignal2 = ta.crossover (src, up2)

// ±3σ signals — rare, "extreme stretch" triggers (off by default).
buySignal3  = ta.crossunder(src, dn3)
sellSignal3 = ta.crossover (src, up3)

if buySignal2 and showBuy
    label.new(
         x         = bar_index,
         y         = low,
         text      = "BUY\n−2σ\n" + f_fmt(src),
         xloc      = xloc.bar_index,
         yloc      = yloc.belowbar,
         color     = colorBuy,
         textcolor = color.white,
         style     = label.style_label_up,
         size      = f_size()
     )

if sellSignal2 and showSell
    label.new(
         x         = bar_index,
         y         = high,
         text      = "SELL\n+2σ\n" + f_fmt(src),
         xloc      = xloc.bar_index,
         yloc      = yloc.abovebar,
         color     = colorSell,
         textcolor = color.white,
         style     = label.style_label_down,
         size      = f_size()
     )

if buySignal3 and showBuy3
    label.new(
         x         = bar_index,
         y         = low,
         text      = "STRONG BUY\n−3σ\n" + f_fmt(src),
         xloc      = xloc.bar_index,
         yloc      = yloc.belowbar,
         color     = color.new(#00C853, 0),
         textcolor = color.white,
         style     = label.style_label_up,
         size      = f_size()
     )

if sellSignal3 and showSell3
    label.new(
         x         = bar_index,
         y         = high,
         text      = "STRONG SELL\n+3σ\n" + f_fmt(src),
         xloc      = xloc.bar_index,
         yloc      = yloc.abovebar,
         color     = color.new(#FF1744, 0),
         textcolor = color.white,
         style     = label.style_label_down,
         size      = f_size()
     )

// ──────────────────────────────────────────────────────────────
// STATS TABLE
//   Row 0      → TIMEFRAME ADVISORY banner (merged across all columns)
//   Row 1      → column headers
//   Rows 2..8  → the seven band levels with price / Δ% / Z-score
//
//   The table is created once (var) at the user-selected position. Changing
//   the "Table Position" input recompiles the script, which rebuilds it in
//   the new spot.
// ──────────────────────────────────────────────────────────────
var table tbl = table.new(
     f_tablePos(), 4, 9,
     bgcolor      = color.new(color.black, 72),
     border_width = 1,
     border_color = color.new(color.gray, 50),
     frame_width  = 1,
     frame_color  = color.new(color.gray, 40)
 )

// Generic cell helper with a custom text colour (transparent black background).
f_cell(col, row, txt, clr) =>
    table.cell(tbl, col, row, txt,
         text_color = clr,
         text_size  = size.small,
         bgcolor    = color.new(color.black, 78))

// Banner cell helper — lets us set both text colour AND background colour so
// the weekly advisory can flip between green (OK) and red (wrong timeframe).
f_banner(col, row, txt, txtClr, bgClr) =>
    table.cell(tbl, col, row, txt,
         text_color = txtClr,
         text_size  = size.normal,
         text_halign = text.align_center,
         bgcolor    = bgClr)

// Live z-score of the current price relative to the regression mean (log units).
zScore = sigmaR > 0 ? (logP - regVal) / sigmaR : 0

// Small formatting helpers for the table body.
pStr(v) => str.tostring(math.round(v, 2))                                        // plain price
pct(v)  => str.tostring(math.round((v / src - 1) * 100, 2)) + "%"                // % distance from current price
zStr(v) => sigmaR > 0 ? str.tostring(math.round(math.log(v / src) / sigmaR, 2)) + "σ" : "n/a"

// Parallel arrays describing each band row (label / level / colour).
lbls = array.from("+3σ", "+2σ", "+1σ", "Mean", "-1σ", "-2σ", "-3σ")
lvls = array.from(up3,   up2,   up1,   mid,    dn1,   dn2,   dn3)
clrs = array.from(
     color.new(#26A69A,  0),
     color.new(#26A69A, 20),
     color.new(#26A69A, 40),
     colorMid,
     color.new(#EF5350, 40),
     color.new(#EF5350, 20),
     color.new(#EF5350,  0))

// Build (or refresh) the table contents only on the last bar, and only when
// the user has the table enabled. Everything is rewritten each time so the
// banner colour and live values stay current.
if barstate.islast and showTable
    // ── Row 0 : weekly-timeframe advisory banner ────────────
    // Merge the four columns of the top row into a single wide banner, then
    // write a green "OK" message on weekly charts or a red warning elsewhere.
    table.merge_cells(tbl, 0, 0, 3, 0)
    f_banner(0, 0,
         isWeekly ? "✓  WEEKLY (1W) — CORRECT TIMEFRAME"
                  : "⚠  USE ON WEEKLY (1W) TIMEFRAME",
         color.white,
         isWeekly ? color.new(#1B5E20, 0)    // dark green when correct
                  : color.new(#B71C1C, 0))   // dark red when not

    // ── Row 1 : column headers ──────────────────────────────
    f_cell(0, 1, "Level",   color.gray)
    f_cell(1, 1, "Price",   color.gray)
    f_cell(2, 1, "Δ%",     color.gray)
    f_cell(3, 1, "Z-score", color.gray)

    // ── Rows 2..8 : band levels ─────────────────────────────
    // Body rows start at index 2 because row 0 = banner and row 1 = headers.
    for i = 0 to 6
        v = array.get(lvls, i)
        c = array.get(clrs, i)
        f_cell(0, i+2, array.get(lbls, i), c)
        f_cell(1, i+2, pStr(v),            c)
        f_cell(2, i+2, pct(v),             c)
        f_cell(3, i+2, zStr(v),            c)

// ──────────────────────────────────────────────────────────────
// BACKGROUND SHADING
//   Tints the chart background when price is beyond ±2σ / ±3σ, giving a
//   quick visual cue that the instrument is statistically stretched.
// ──────────────────────────────────────────────────────────────
bgColor =
     zScore >  3 ? color.new(#26A69A, 88) :
     zScore >  2 ? color.new(#26A69A, 93) :
     zScore < -3 ? color.new(#EF5350, 88) :
     zScore < -2 ? color.new(#EF5350, 93) :
     na

bgcolor(bgColor, title="Extreme Z-score Zone")

// ──────────────────────────────────────────────────────────────
// ALERTS
//   Create alert() conditions for each meaningful band cross. Attach them
//   from TradingView's "Add alert" dialog after applying the indicator.
// ──────────────────────────────────────────────────────────────
alertcondition(ta.crossover (src, up3), "Cross above +3σ", "Price crossed above +3σ regression band — extreme overextension")
alertcondition(ta.crossunder(src, dn3), "Cross below -3σ", "Price crossed below -3σ regression band — extreme undervaluation")
alertcondition(ta.crossover (src, up2), "Cross above +2σ", "Price crossed above +2σ regression band")
alertcondition(ta.crossunder(src, dn2), "Cross below -2σ", "Price crossed below -2σ regression band")
alertcondition(ta.crossover (src, mid), "Cross above Mean", "Price crossed above the log-regression mean")
alertcondition(ta.crossunder(src, mid), "Cross below Mean", "Price crossed below the log-regression mean")

// ============================================================================
//  END OF SCRIPT — RichmondHillCM Log-Price Regression Channel (v6)
// ============================================================================
````
