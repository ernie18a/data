# BTC Macro Correlation Oscillator & Multi-Timeframe Matrix

- url: https://www.tradingview.com/script/MUJxi8oO-BTC-Macro-Correlation-Oscillator-Multi-Timeframe-Matrix/
- type: indicator
- pine_id: PUB;c569c649f9304aa19b9ce01413755f2b
- version: 1.0

## Description

The Macro Correlation Oscillator is an advanced analytical tool built for traders who need a top-down macro view of how their primary asset (like Bitcoin) aligns with traditional financial markets.

Instead of relying on a single, one-dimensional lookback period to understand macro shifts, this indicator provides a layered visual approach across six major structural barometers simultaneously: S&P 500, Gold, NASDAQ 100, DXY, US 10-Year Yields, and the VIX.

🌟 Key Features

Per-Asset Optimized Lines: Traditional correlation tools force you to use a static 30-day or 90-day window for everything. This script allows you to specify custom rolling windows per asset. This is critical because Gold moves on entirely different macro cycles than the VIX or NASDAQ.
Multi-Timeframe Assessment Matrix: The indicator boasts a clean, heads-up tabular dashboard summarizing cross-asset correlation across 5 predefined broad time horizons (30 Days, 3 Months, 6 Months, 1 Year, and 5 Years).
Auto-Sorting Intelligence: The matrix dynamically sorts the table from top to bottom based on the highest absolute correlation averages, instantly bubbling up the strongest macroeconomic forces currently moving your asset.
Star Rankings: Across each timeframe column, the indicator dynamically highlights the single highest correlated asset with a prominent "★" and golden text, enabling lightning-fast visual conclusions.
Floating Identity Tags: Clean, persistent floating labels stay attached to the end of each oscillator line in real-time, removing the guesswork involved with trying to match chaotic line charts to a legend.
💡 How to Use

Identify Risk Regimes: A strong negative correlation to the DXY and US10Y alongside a high positive correlation to NDX/SPX practically screams "risk-on liquidity regime".
Identify Haven Pivots: When correlation strongly pivots towards Gold and away from Equities while the primary asset drops, it signals a structural flight to safety.
Timeframe Intersections: Look for assets consistently scoring a "★" across multiple columns in the matrix to find long-lasting secular relationships rather than fleeting statistical noise.

## Source Code

````pine
//@version=5
// Define the indicator's name and set overlay to false so it plots in a separate pane below the chart.
indicator("BTC Macro Correlation Oscillator", overlay=false)

// ═══════════════════════════════════════════════════════════════════════
//  INPUTS — Assets
//  Allows the user to select the ticker symbols for the 6 macro assets.
// ═══════════════════════════════════════════════════════════════════════
grp_a = "━━ Assets ━━"
sym1 = input.symbol("SP:SPX",       "① S&P 500",         group=grp_a) // US Large Cap Equities
sym2 = input.symbol("OANDA:XAUUSD", "② Gold (XAU/USD)",  group=grp_a) // Safe-haven asset
sym3 = input.symbol("NASDAQ:NDX",   "③ NASDAQ 100",      group=grp_a) // Tech-heavy Equities
sym4 = input.symbol("TVC:DXY",      "④ US Dollar Index", group=grp_a) // Fiat currency strength
sym5 = input.symbol("TVC:US10Y",    "⑤ 10-Year Yield",   group=grp_a) // Interest rate benchmark
sym6 = input.symbol("CBOE:VIX",     "⑥ VIX",             group=grp_a) // Market volatility/Fear index

// ═══════════════════════════════════════════════════════════════════════
//  INPUTS — Oscillator (line graph lookbacks, per-asset optimized)
//  Sets the rolling window period for the correlation line plot.
// ═══════════════════════════════════════════════════════════════════════
grp_o = "━━ Oscillator Lookbacks (Bars) ━━"
i_tip = "Optimal rolling window for the line graph.\nDefaults are calibrated for a DAILY chart."
// Lookback periods (in days, assuming a daily chart) customized for each asset's standard macro cycle
ol1 = input.int(252,  "SPX   — 1 Trading Year",    minval=5, group=grp_o, tooltip=i_tip)
ol2 = input.int(1260, "Gold  — 5 Trading Years",   minval=5, group=grp_o, tooltip=i_tip)
ol3 = input.int(126,  "NDX   — 6 Months",          minval=5, group=grp_o, tooltip=i_tip)
ol4 = input.int(90,   "DXY   — 1 Quarter",         minval=5, group=grp_o, tooltip=i_tip)
ol5 = input.int(180,  "US10Y — 2 Quarters",        minval=5, group=grp_o, tooltip=i_tip)
ol6 = input.int(30,   "VIX   — 1 Month",           minval=5, group=grp_o, tooltip=i_tip)

// ═══════════════════════════════════════════════════════════════════════
//  INPUTS — Dashboard table windows
//  Defines the 5 static lookback windows used in the correlation dashboard.
// ═══════════════════════════════════════════════════════════════════════
grp_d = "━━ Dashboard Windows (Bars) ━━"
d_tip = "Snapshot lookback windows for the table matrix.\nDefaults are calibrated for a DAILY chart."
// Timeframes for the dashboard table (columns)
w1 = input.int(30,   "30 Days",    minval=5, group=grp_d, tooltip=d_tip)
w2 = input.int(90,   "3 Months",   minval=5, group=grp_d, tooltip=d_tip)
w3 = input.int(180,  "6 Months",   minval=5, group=grp_d, tooltip=d_tip)
w4 = input.int(365,  "1 Year",     minval=5, group=grp_d, tooltip=d_tip)
w5 = input.int(1825, "5 Years",    minval=5, group=grp_d, tooltip=d_tip)
// Toggles whether the dashboard table is rendered on the chart
show_tbl = input.bool(true, "Show Dashboard",   group=grp_d)
// Lets user choose which corner to place the dashboard table
tbl_pos  = input.string(position.top_right, "Table Position",
     options=[position.top_right, position.top_left, position.bottom_right, position.bottom_left], group=grp_d)


// ═══════════════════════════════════════════════════════════════════════
//  DATA — Fetch closes for all 6 comparison assets (only 6 calls total)
//  We fetch 'close' prices from the specified symbols at the chart's current timeframe.
//  'lookahead_off' ensures we do not peek into future data, preventing repainting.
// ═══════════════════════════════════════════════════════════════════════
c1 = request.security(sym1, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
c2 = request.security(sym2, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
c3 = request.security(sym3, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
c4 = request.security(sym4, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
c5 = request.security(sym5, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)
c6 = request.security(sym6, timeframe.period, close, barmerge.gaps_off, barmerge.lookahead_off)


// ═══════════════════════════════════════════════════════════════════════
//  OSCILLATOR — Rolling Pearson correlation line graphs
//  Calculate the correlation between the primary chart's close (e.g., BTC) 
//  and the selected assets over the custom lookback periods defined above.
// ═══════════════════════════════════════════════════════════════════════
osc1 = ta.correlation(close, c1, ol1)
osc2 = ta.correlation(close, c2, ol2)
osc3 = ta.correlation(close, c3, ol3)
osc4 = ta.correlation(close, c4, ol4)
osc5 = ta.correlation(close, c5, ol5)
osc6 = ta.correlation(close, c6, ol6)

// Plot Colors (matching the dashboard legend)
// These colors will be used for both the line graphs, labels, and table rows
color COL_1 = color.rgb(33, 150, 243)    // SPX  — Blue
color COL_2 = color.rgb(255, 215, 0)     // Gold — Gold
color COL_3 = color.rgb(0, 229, 255)     // NDX  — Cyan
color COL_4 = color.rgb(200, 200, 200)   // DXY  — Silver
color COL_5 = color.rgb(255, 152, 0)     // 10Y  — Orange
color COL_6 = color.rgb(186, 104, 200)   // VIX  — Purple

// Threshold Lines & Zones
// Add horizontal lines to help visually identify strong positive/negative alignments
h_zero = hline(0,    "Zero",  color=color.new(color.gray, 40), linestyle=hline.style_dotted)
h_p7   = hline(0.7,  "+0.70", color=color.new(#089981, 70),    linestyle=hline.style_dashed) // +0.7 is commonly a strong positive correlation
h_n7   = hline(-0.7, "−0.70", color=color.new(#f23645, 70),    linestyle=hline.style_dashed) // -0.7 is commonly a strong negative/inverse correlation
h_p1   = hline(1.0,  " ",     color=color.new(color.gray, 90), linestyle=hline.style_solid)  // Max correlation
h_n1   = hline(-1.0, " ",     color=color.new(color.gray, 90), linestyle=hline.style_solid)  // Min correlation

// Fill the areas between 0.7 to 1.0 (Green) and -0.7 to -1.0 (Red) to highlight extreme correlation
fill(h_p7, h_p1, color=color.new(#089981, 92), title="Strong Positive Zone")
fill(h_n7, h_n1, color=color.new(#f23645, 92), title="Strong Negative Zone")

// Line Plots
// Render the actual oscillator lines on the indicator pane
plot(osc1, "SPX",   color=COL_1, linewidth=2)
plot(osc2, "Gold",  color=COL_2, linewidth=2)
plot(osc3, "NDX",   color=COL_3, linewidth=2)
plot(osc4, "DXY",   color=COL_4, linewidth=2)
plot(osc5, "US10Y", color=COL_5, linewidth=2)
plot(osc6, "VIX",   color=COL_6, linewidth=2)

// ═══════════════════════════════════════════════════════════════════════
//  LINE LABELS — Display asset names at the end of the oscillator lines
// ═══════════════════════════════════════════════════════════════════════
// Initialize labels once (using 'var') with fully transparent backgrounds.
// By setting x and y to 'na' initially, we avoid plotting until explicitly told.
var label lbl_spx  = label.new(na, na, "SPX",   color=color.new(color.white, 100), textcolor=COL_1, style=label.style_label_left, size=size.small, textalign=text.align_center)
var label lbl_gold = label.new(na, na, "Gold",  color=color.new(color.white, 100), textcolor=COL_2, style=label.style_label_left, size=size.small, textalign=text.align_center)
var label lbl_ndx  = label.new(na, na, "NDX",   color=color.new(color.white, 100), textcolor=COL_3, style=label.style_label_left, size=size.small, textalign=text.align_center)
var label lbl_dxy  = label.new(na, na, "DXY",   color=color.new(color.white, 100), textcolor=COL_4, style=label.style_label_left, size=size.small, textalign=text.align_center)
var label lbl_10y  = label.new(na, na, "US10Y", color=color.new(color.white, 100), textcolor=COL_5, style=label.style_label_left, size=size.small, textalign=text.align_center)
var label lbl_vix  = label.new(na, na, "VIX",   color=color.new(color.white, 100), textcolor=COL_6, style=label.style_label_left, size=size.small, textalign=text.align_center)

// Update label coordinates dynamically only on the final bar.
// This ensures labels remain floating at the right-edge of the screen mirroring the latest values.
if barstate.islast
    label.set_xy(lbl_spx,  bar_index, osc1)
    label.set_xy(lbl_gold, bar_index, osc2)
    label.set_xy(lbl_ndx,  bar_index, osc3)
    label.set_xy(lbl_dxy,  bar_index, osc4)
    label.set_xy(lbl_10y,  bar_index, osc5)
    label.set_xy(lbl_vix,  bar_index, osc6)


// ═══════════════════════════════════════════════════════════════════════
//  TABLE — Pre-compute all 30 snapshot correlations (6 assets × 5 windows)
//  These must run on every bar because ta.correlation is stateful (it builds 
//  history sequentially, and correctly passing it requires continuous evaluation).
// ═══════════════════════════════════════════════════════════════════════
// SPX  ×  5 dashboard windows
float r1_w1 = ta.correlation(close, c1, w1)
float r1_w2 = ta.correlation(close, c1, w2)
float r1_w3 = ta.correlation(close, c1, w3)
float r1_w4 = ta.correlation(close, c1, w4)
float r1_w5 = ta.correlation(close, c1, w5)

// Gold  ×  5 dashboard windows
float r2_w1 = ta.correlation(close, c2, w1)
float r2_w2 = ta.correlation(close, c2, w2)
float r2_w3 = ta.correlation(close, c2, w3)
float r2_w4 = ta.correlation(close, c2, w4)
float r2_w5 = ta.correlation(close, c2, w5)

// NDX  ×  5 dashboard windows
float r3_w1 = ta.correlation(close, c3, w1)
float r3_w2 = ta.correlation(close, c3, w2)
float r3_w3 = ta.correlation(close, c3, w3)
float r3_w4 = ta.correlation(close, c3, w4)
float r3_w5 = ta.correlation(close, c3, w5)

// DXY  ×  5 dashboard windows
float r4_w1 = ta.correlation(close, c4, w1)
float r4_w2 = ta.correlation(close, c4, w2)
float r4_w3 = ta.correlation(close, c4, w3)
float r4_w4 = ta.correlation(close, c4, w4)
float r4_w5 = ta.correlation(close, c4, w5)

// US10Y  ×  5 dashboard windows
float r5_w1 = ta.correlation(close, c5, w1)
float r5_w2 = ta.correlation(close, c5, w2)
float r5_w3 = ta.correlation(close, c5, w3)
float r5_w4 = ta.correlation(close, c5, w4)
float r5_w5 = ta.correlation(close, c5, w5)

// VIX  ×  5 dashboard windows
float r6_w1 = ta.correlation(close, c6, w1)
float r6_w2 = ta.correlation(close, c6, w2)
float r6_w3 = ta.correlation(close, c6, w3)
float r6_w4 = ta.correlation(close, c6, w4)
float r6_w5 = ta.correlation(close, c6, w5)


// ═══════════════════════════════════════════════════════════════════════
//  TABLE — Helper functions
// ═══════════════════════════════════════════════════════════════════════
// Helper function to color map dashboard cells based on correlation strength
f_clr(v) =>
    if na(v)
        color.new(color.gray, 80) // Missing data mapping
    else if v >= 0.7
        color.new(#089981, 10)    // Very strong positive mapping (Bright Green)
    else if v >= 0.3
        color.new(#089981, 50)    // Medium-weak positive mapping (Dimmed Green)
    else if v <= -0.7
        color.new(#f23645, 10)    // Very strong negative mapping (Bright Red)
    else if v <= -0.3
        color.new(#f23645, 50)    // Medium-weak negative mapping (Dimmed Red)
    else
        color.new(color.gray, 60) // Neutral correlation mapping (Grayish)

// Helper function to format correlation floats strictly to 2 decimal places
f_fmt(v) =>
    na(v) ? "—" : str.tostring(v, "#.##")

// Helper function to extract just the ticker segment (removes the exchange code)
// e.g. "OANDA:XAUUSD" becomes "XAUUSD"
f_nm(s) =>
    a = str.split(s, ":")
    array.size(a) > 1 ? array.get(a, 1) : s


// ═══════════════════════════════════════════════════════════════════════
//  TABLE — Render dashboard on last bar only
// ═══════════════════════════════════════════════════════════════════════
// We only need to draw the table once at the end of the chart, significantly saving processing power.
if barstate.islast and show_tbl
    // Instantiate the table frame. Size is 8 cols x 8 rows to accommodate headers + our 6 assets.
    var table tbl = table.new(tbl_pos, 8, 8, border_width=1, border_color=color.new(color.gray, 75))

    // Consolidate the 30 scalar metrics into a single contiguous array for easy iteration.
    // Mathematical mapping: index = asset_idx * 5 + window_idx
    r = array.from(
         r1_w1, r1_w2, r1_w3, r1_w4, r1_w5, // Indexed 0-4
         r2_w1, r2_w2, r2_w3, r2_w4, r2_w5, // Indexed 5-9
         r3_w1, r3_w2, r3_w3, r3_w4, r3_w5, // Indexed 10-14
         r4_w1, r4_w2, r4_w3, r4_w4, r4_w5, // Indexed 15-19
         r5_w1, r5_w2, r5_w3, r5_w4, r5_w5, // Indexed 20-24
         r6_w1, r6_w2, r6_w3, r6_w4, r6_w5) // Indexed 25-29

    // Calculate a row-wise average correlation per asset (across all 5 timeframes)
    avgs = array.new_float(6, na)
    for i = 0 to 5 // Over the 6 assets
        float sm = 0.0
        int cnt = 0
        for j = 0 to 4 // Over the 5 windows
            float v = array.get(r, i * 5 + j)
            if not na(v)
                sm += v
                cnt += 1
        // Store average mapping for asset row 'i'
        array.set(avgs, i, cnt > 0 ? sm / cnt : na)

    // Sort index array to place the strongest overall correlated assets at the top of the table.
    // We sort by absolute average correlation (strongest positive or negative rises to top).
    idx = array.from(0, 1, 2, 3, 4, 5)
    for i = 0 to 4
        for j = i + 1 to 5
            int ii = array.get(idx, i)
            int jj = array.get(idx, j)
            // Perform swap if subsequent absolute average is higher
            if math.abs(nz(array.get(avgs, jj))) > math.abs(nz(array.get(avgs, ii)))
                array.set(idx, i, jj)
                array.set(idx, j, ii)

    // Determine the highest absolute correlation value per timeframe column.
    // This allows us to prefix the top score per column with a '★'.
    max_asset = array.new_int(5, -1)
    max_abs   = array.new_float(5, 0.0)
    for w = 0 to 4 // over the windows
        for a = 0 to 5 // over the assets
            float v = array.get(r, a * 5 + w)
            if not na(v) and math.abs(v) > array.get(max_abs, w)
                array.set(max_abs, w, math.abs(v)) // Update highest |correlation| seen
                array.set(max_asset, w, a)         // Update which asset achieved this score

    // Ready our asset label names and colors mapping for the table loops
    names  = array.from(f_nm(sym1), f_nm(sym2), f_nm(sym3), f_nm(sym4), f_nm(sym5), f_nm(sym6))
    colors = array.from(COL_1, COL_2, COL_3, COL_4, COL_5, COL_6)

    // ── Build the Header Row of the Table ──
    hdr_bg = color.new(#0d1117, 0)
    table.cell(tbl, 0, 0, "ASSET",  text_color=color.white, bgcolor=hdr_bg, text_size=size.small)
    table.cell(tbl, 1, 0, "30D",    text_color=color.white, bgcolor=hdr_bg, text_size=size.small)
    table.cell(tbl, 2, 0, "3M",     text_color=color.white, bgcolor=hdr_bg, text_size=size.small)
    table.cell(tbl, 3, 0, "6M",     text_color=color.white, bgcolor=hdr_bg, text_size=size.small)
    table.cell(tbl, 4, 0, "1Y",     text_color=color.white, bgcolor=hdr_bg, text_size=size.small)
    table.cell(tbl, 5, 0, "5Y",     text_color=color.white, bgcolor=hdr_bg, text_size=size.small)
    table.cell(tbl, 6, 0, "AVG",    text_color=color.white, bgcolor=color.new(color.purple, 40), text_size=size.small)

    // ── Build Data Rows dynamically via sorting indices (Highest Correlated goes First) ──
    for row = 0 to 5
        int ai = array.get(idx, row) // Identify original asset underlying index from ranked mappings

        // Setup Column 0: Render Asset ticker text and use mapped colors to match the line charts
        table.cell(tbl, 0, row + 1, array.get(names, ai),
             text_color=array.get(colors, ai), bgcolor=color.new(#0d1117, 20), text_size=size.small)

        // Setup Columns 1–5 (The 5 predefined data windows for each timeframe)
        for w = 0 to 4
            float v  = array.get(r, ai * 5 + w)
            // Determine if this cell contains highest absolute correlation across assets per column timeframe
            bool top = array.get(max_asset, w) == ai 
            // Pre-pend a star icon indicator and switch text color to yellow on highest scores
            string txt = top ? "★ " + f_fmt(v) : f_fmt(v)
            color  tc  = top ? color.yellow : color.white
            table.cell(tbl, w + 1, row + 1, txt, text_color=tc, bgcolor=f_clr(v), text_size=size.small)

        // Setup Column 6 (Average value correlation per asset row mapping)
        float va = array.get(avgs, ai)
        table.cell(tbl, 6, row + 1, f_fmt(va), text_color=color.white, bgcolor=f_clr(va), text_size=size.small)
````
