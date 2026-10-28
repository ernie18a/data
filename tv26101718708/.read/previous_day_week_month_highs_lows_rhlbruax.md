# Previous Day / Week / Month Highs & Lows

- url: https://www.tradingview.com/script/rHlBruax-Previous-Day-Week-Month-Highs-Lows/
- type: indicator
- pine_id: PUB;5bfd4f2bd9634a4482c5a784fb4ba938
- version: 1.0

## Description

Previous Day / Week / Month Highs & Lows.

A precision multi-period key-level tool that automatically draws previous-period highs and lows from the Daily, Weekly and Monthly timeframes — plus optional midpoints, an optional grid of psychological round-number levels around price, and a compact right-side info table with distance-to-price for every visible level. Built for intraday, scalping and swing traders who want a clean, opinionated read of the reference levels that institutional desks actually watch.

How it works:
The indicator pulls the previous completed candle from D, W and M via request.security and anchors each level line at the exact open time of that source bar — so a Weekly line starts on last week's Monday, not on the current week's first bar. Lines stay live and extend to the right through the chart's future offset area, so the reference points from yesterday, last week and last month are always visible on the current bar. The optional round-number grid re-anchors to price on every bar, so the closest N round levels above and below are always in view.

What it calculates:
- Previous Day High / Low + optional Midpoint (PDH, PDL, PD MID)
- Previous Week High / Low + optional Midpoint (PWH, PWL, PW MID)
- Previous Month High / Low + optional Midpoint (PMH, PML, PM MID)
- Psychological round-number grid centered on the current price, with adjustable step and count
- Live distance from the current close to every enabled level (in %)

Key features:
- Per-period visibility toggles: enable exactly the levels you use, hide everything else
- Configurable history depth — keep 1 to 20 previous daily / 1 to 12 weekly / 1 to 6 monthly sessions on the chart
- Auto-hide only when the chart timeframe strictly exceeds the level period: Daily levels stay on 1D, Weekly stay on 1W, Monthly never hide
- Lines anchored at the source bar (open time of the previous D/W/M candle), not at the first bar of the new period — you see the actual range the level came from
- Label anti-collision system: each label sits on its own horizontal slot in the right-offset area, with configurable Label Spacing — PDH / PWH / PMH texts never overlap even when their prices are close together
- Compact right-side info table with three columns (level name, price, +/- % distance to close), positioning across 6 chart corners, three text sizes, adjustable background transparency
- Three line styles (Solid / Dashed / Dotted) applied independently to main lines, midpoints and round levels
- Adjustable line width, label size and label visibility for a clean or a dense look
- Line extension modes: Right (default), Both, or None
- Fully customizable color per period — defaults follow a heat-scale palette (Daily = yellow, Weekly = orange, Monthly = red — nearest to furthest horizon)
- Round-number step tuned per asset class (BTC / ETH / FX / index / equities)
- Built-in alerts: PDH / PDL touched, same for weekly and monthly
- Auto-adapts to any instrument and any chart timeframe

Who it's for:
Intraday, scalping and swing traders — SMC / ICT, price-action, order-flow, or classical technicals — who want the exact levels institutional desks pin their orders around, cleanly drawn, without the visual noise of a dozen overlapping tools.

## Source Code

````pine
// =============================================================================
// PREVIOUS DAY / WEEK / MONTH HIGHS & LOWS
// Auto-drawn previous-period High / Low (+ optional Midpoint) from the
// Daily / Weekly / Monthly timeframes, plus an optional psychological
// round-number grid around price and a compact right-side info table.
// =============================================================================
//@version=6
indicator("Previous Day / Week / Month Highs & Lows", "Prev H/L",
          overlay = true,
          max_lines_count = 500,
          max_labels_count = 500,
          max_bars_back = 3000)

// =============================================================================
// GROUP 1 — GENERAL
// =============================================================================
line_width = input.int(1, "Line width", minval = 1, maxval = 4, group = "General",
     tooltip = "Thickness of every level line drawn by the indicator.")

label_size_in = input.string("Small", "Label size",
     options = ["Tiny", "Small", "Normal"], group = "General",
     tooltip = "Text size of the level labels displayed on the right edge of each line.")

extend_side = input.string("Right", "Extend lines",
     options = ["Right", "Both", "None"], group = "General",
     tooltip = "How each level line is projected on the chart.\n\n" +
       "Right (default): from the start of its period to the far right of the chart.\n" +
       "Both: extended in both directions.\n" +
       "None: capped at the last real bar without projection.")

show_labels = input.bool(true, "Show labels", group = "General",
     tooltip = "Show text tags at the right end of every level (PDH, PDL, PDC, MID, etc.).\n" +
       "Disable to keep the chart absolutely clean.")

hide_on_htf = input.bool(true, "Auto-hide when chart TF exceeds period",
     group = "General",
     tooltip = "Automatically hides:\n" +
       "  Daily levels on chart timeframes above 1D (1W and up),\n" +
       "  Weekly levels on chart timeframes above 1W (1M and up),\n" +
       "  Monthly levels never hide (kept as macro reference).\n\n" +
       "Daily levels stay visible on 1D so you can see the reaction to the previous session's high/low on the current daily candle.")

// =============================================================================
// GROUP 2 — PREVIOUS DAY
// =============================================================================
show_pdh = input.bool(true, "Prev Day High (PDH)", group = "Previous Day",
     tooltip = "High of the previous completed daily session — the primary intraday resistance reference.")
show_pdl = input.bool(true, "Prev Day Low (PDL)", group = "Previous Day",
     tooltip = "Low of the previous completed daily session — the primary intraday support reference.")
show_pdmid = input.bool(false, "Prev Day Midpoint", group = "Previous Day",
     tooltip = "(PDH + PDL) / 2. Popular pivot used by intraday range-traders as a fair-value proxy.")
keep_days = input.int(1, "Keep last N days on chart",
     minval = 1, maxval = 20, group = "Previous Day",
     tooltip = "How many previous daily sessions of levels to keep drawn on the chart.\n\n" +
       "1 (default): only the current day's PDH / PDL / PDC / MID.\n" +
       "5-10: build a visible history of prior daily reactions (useful for backtesting confluence).")

// =============================================================================
// GROUP 3 — PREVIOUS WEEK
// =============================================================================
show_pwh = input.bool(true, "Prev Week High (PWH)", group = "Previous Week",
     tooltip = "High of the previous completed weekly candle. Institutional swing reference.")
show_pwl = input.bool(true, "Prev Week Low (PWL)", group = "Previous Week",
     tooltip = "Low of the previous completed weekly candle. Institutional swing reference.")
show_pwmid = input.bool(false, "Prev Week Midpoint", group = "Previous Week",
     tooltip = "(PWH + PWL) / 2. Weekly fair-value reference.")
keep_weeks = input.int(1, "Keep last N weeks on chart",
     minval = 1, maxval = 12, group = "Previous Week",
     tooltip = "How many previous weekly ranges of levels to keep on the chart.")

// =============================================================================
// GROUP 4 — PREVIOUS MONTH
// =============================================================================
show_pmh = input.bool(true, "Prev Month High (PMH)", group = "Previous Month",
     tooltip = "High of the previous completed monthly candle. Positional swing reference.")
show_pml = input.bool(true, "Prev Month Low (PML)", group = "Previous Month",
     tooltip = "Low of the previous completed monthly candle. Positional swing reference.")
show_pmmid = input.bool(false, "Prev Month Midpoint", group = "Previous Month",
     tooltip = "(PMH + PML) / 2. Monthly fair-value reference.")
keep_months = input.int(1, "Keep last N months on chart",
     minval = 1, maxval = 6, group = "Previous Month",
     tooltip = "How many previous monthly ranges of levels to keep on the chart.")

// =============================================================================
// GROUP 5 — ROUND NUMBER LEVELS
// =============================================================================
show_round = input.bool(false, "Show round-number levels", group = "Round Numbers",
     tooltip = "Draws psychological round-number levels around the current price.\n\n" +
       "Round numbers act as magnets and reaction zones because a large share of stops, limits and take-profit orders cluster there.\n" +
       "The grid re-anchors on every bar so the closest levels around price are always visible.")
round_step = input.float(500.0, "Round step", minval = 0.00001, group = "Round Numbers",
     tooltip = "Distance between two consecutive round levels — in the instrument's price units.\n\n" +
       "Typical values:\n" +
       "  BTCUSD:  500 or 1000\n" +
       "  ETHUSD:  50 or 100\n" +
       "  EURUSD:  0.005 or 0.01\n" +
       "  SPX/ES:  25 or 50\n" +
       "  US stocks: 1 or 5")
round_count = input.int(3, "Levels above / below", minval = 1, maxval = 20,
     group = "Round Numbers",
     tooltip = "Number of round levels to draw above AND below the current price.\n" +
       "Total lines = 2 * this value.")

// =============================================================================
// GROUP 6 — STYLE
// =============================================================================
main_style_str = input.string("Solid", "Main line style",
     options = ["Solid", "Dashed", "Dotted"], group = "Style",
     tooltip = "Style applied to High / Low / Close lines of every period.")
mid_style_str = input.string("Dashed", "Midpoint line style",
     options = ["Solid", "Dashed", "Dotted"], group = "Style",
     tooltip = "Style applied to Midpoint lines only.")
round_style_str = input.string("Dotted", "Round-level line style",
     options = ["Solid", "Dashed", "Dotted"], group = "Style",
     tooltip = "Style applied to round-number lines.")
label_spacing = input.int(3, "Label spacing (bars)", minval = 0, maxval = 30,
     group = "Style",
     tooltip = "Horizontal spacing between labels of different levels, in bars.\n\n" +
       "Each level's label is offset from the last bar by (level_slot × this value):\n" +
       "  Day    labels: slots 1-3 (High, Low, Midpoint)\n" +
       "  Week   labels: slots 4-6\n" +
       "  Month  labels: slots 7-9\n\n" +
       "With the default 3, labels stagger up to ~27 bars into the right offset area — enough to prevent PDH/PWH/PMH texts from overlapping when their prices sit close together.\n\n" +
       "Set to 0 to align all labels at the last bar (previous behavior)." )

// =============================================================================
// GROUP 8 — INFO TABLE
// Compact right-side table listing every enabled level with its price and
// distance to the current close (%). Works alongside the on-chart labels.
// =============================================================================
show_info_table = input.bool(true, "Show info table", group = "Info Table",
     tooltip = "Compact table in the corner of the chart listing every enabled level with its price and distance to the current close in %.\n\nSurvives label collisions even at zero label spacing.")
tbl_position_str = input.string("Top Right", "Position",
     options = ["Top Right", "Middle Right", "Bottom Right", "Top Left", "Middle Left", "Bottom Left"],
     group = "Info Table",
     tooltip = "Where to anchor the table on the chart.")
tbl_size_str = input.string("Small", "Text size",
     options = ["Tiny", "Small", "Normal"], group = "Info Table")
tbl_show_dist = input.bool(true, "Show distance column (%)", group = "Info Table",
     tooltip = "Third column with % distance from the current close to each level.\nPositive = level sits above price; negative = below.")
tbl_bg_opacity = input.int(85, "Background transparency", minval = 0, maxval = 100,
     group = "Info Table",
     tooltip = "0 = fully opaque, 100 = fully transparent.")

// =============================================================================
// GROUP 7 — COLORS
// =============================================================================
col_pd     = input.color(#ffd60a, "Prev Day color",      group = "Colors",
     tooltip = "Color for PDH / PDL / PD Midpoint (default: yellow — nearest horizon).")
col_pw     = input.color(#ff9500, "Prev Week color",     group = "Colors",
     tooltip = "Color for PWH / PWL / PW Midpoint (default: orange — mid horizon).")
col_pm     = input.color(#ff453a, "Prev Month color",    group = "Colors",
     tooltip = "Color for PMH / PML / PM Midpoint (default: red — macro horizon).")
col_round  = input.color(color.new(color.gray, 30), "Round-level color", group = "Colors",
     tooltip = "Color for round-number lines and labels.")

// =============================================================================
// HELPERS AND CONSTANTS
// Style / extend / size are resolved with ternaries so they carry a
// consistent int/string type into line.new() and label.new().
// =============================================================================
LABEL_SIZE = label_size_in == "Tiny"   ? size.tiny :
             label_size_in == "Normal" ? size.normal :
                                          size.small

MAIN_STYLE  = main_style_str  == "Solid"  ? line.style_solid :
              main_style_str  == "Dashed" ? line.style_dashed :
                                             line.style_dotted
MID_STYLE   = mid_style_str   == "Solid"  ? line.style_solid :
              mid_style_str   == "Dashed" ? line.style_dashed :
                                             line.style_dotted
ROUND_STYLE = round_style_str == "Solid"  ? line.style_solid :
              round_style_str == "Dashed" ? line.style_dashed :
                                             line.style_dotted

EXTEND = extend_side == "Right" ? extend.right :
         extend_side == "Both"  ? extend.both :
                                   extend.none

TBL_POS = tbl_position_str == "Top Right"    ? position.top_right    :
          tbl_position_str == "Middle Right" ? position.middle_right :
          tbl_position_str == "Bottom Right" ? position.bottom_right :
          tbl_position_str == "Top Left"     ? position.top_left     :
          tbl_position_str == "Middle Left"  ? position.middle_left  :
                                               position.bottom_left

TBL_SIZE = tbl_size_str == "Tiny"   ? size.tiny :
           tbl_size_str == "Normal" ? size.normal :
                                       size.small

// Timeframe classification for auto-hide -------------------------------------
chart_secs = timeframe.in_seconds()
DAY_SECS   = 60 * 60 * 24
WEEK_SECS  = DAY_SECS * 7
MONTH_SECS = DAY_SECS * 30

// Auto-hide only when the chart TF is STRICTLY greater than the level period,
// so daily levels stay on the 1D chart, weekly on the 1W chart, and monthly
// levels remain visible on any timeframe.
allow_daily   = (not hide_on_htf) or chart_secs <= DAY_SECS
allow_weekly  = (not hide_on_htf) or chart_secs <= WEEK_SECS
allow_monthly = true

// =============================================================================
// FETCH PREVIOUS-PERIOD OHLC
// Using [1] with lookahead_on is safe: we request the CLOSED previous bar.
// =============================================================================
// time[1] returns the open-time of the previous D/W/M bar — the exact bar
// the High/Low was taken from. Used as the line's x1 anchor so the line
// starts at that bar, not at the first bar of the new period.
[pdh, pdl, pd_start_t] = request.security(syminfo.tickerid, "D",
     [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)
[pwh, pwl, pw_start_t] = request.security(syminfo.tickerid, "W",
     [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)
[pmh, pml, pm_start_t] = request.security(syminfo.tickerid, "M",
     [high[1], low[1], time[1]], lookahead = barmerge.lookahead_on)

pdmid = na(pdh) or na(pdl) ? na : (pdh + pdl) / 2.0
pwmid = na(pwh) or na(pwl) ? na : (pwh + pwl) / 2.0
pmmid = na(pmh) or na(pml) ? na : (pmh + pml) / 2.0

// Period-start signals -------------------------------------------------------
is_new_day   = ta.change(time("D")) != 0
is_new_week  = ta.change(time("W")) != 0
is_new_month = ta.change(time("M")) != 0

// =============================================================================
// LEVEL STORAGE — one pair of arrays (lines + labels) per period/subtype
// =============================================================================
// Previous Day
var array<line>  ln_pdh = array.new_line()
var array<label> lb_pdh = array.new_label()
var array<line>  ln_pdl = array.new_line()
var array<label> lb_pdl = array.new_label()
var array<line>  ln_pdmid = array.new_line()
var array<label> lb_pdmid = array.new_label()

// Previous Week
var array<line>  ln_pwh = array.new_line()
var array<label> lb_pwh = array.new_label()
var array<line>  ln_pwl = array.new_line()
var array<label> lb_pwl = array.new_label()
var array<line>  ln_pwmid = array.new_line()
var array<label> lb_pwmid = array.new_label()

// Previous Month
var array<line>  ln_pmh = array.new_line()
var array<label> lb_pmh = array.new_label()
var array<line>  ln_pml = array.new_line()
var array<label> lb_pml = array.new_label()
var array<line>  ln_pmmid = array.new_line()
var array<label> lb_pmmid = array.new_label()

// Round-number levels — refreshed each bar
var array<line>  ln_round = array.new_line()
var array<label> lb_round = array.new_label()

// =============================================================================
// LEVEL MANAGER — create on period start, extend on subsequent bars
// =============================================================================
// xloc.bar_time is required for extend.right to reach the right-offset area
// of the chart. bar_index-based extension is capped at the last real bar.
//
// start_time: open-time of the source bar (previous D/W/M candle) — used as
// the line's x1 anchor so the line begins at the bar the High/Low was
// actually taken from, not at the first bar of the new period.
// label_slot: horizontal slot index (1..N). Actual pixel offset =
// slot * label_spacing bars, applied as time delta so the label sits
// ahead of the last bar and never overlaps other slots.
f_add_or_update(array<line> arr_ln, array<label> arr_lb, simple bool visible,
                bool is_start, simple int keep_n, float price, color col, string style_i,
                string txt, simple int label_slot, int start_time) =>
    if visible and not na(price)
        bar_ms   = timeframe.in_seconds() * 1000
        label_dx = bar_ms * label_slot * label_spacing
        if is_start
            // Freeze the previously-active line so it stops extending right
            n_prev = array.size(arr_ln)
            if n_prev > 0
                prev_ln = array.get(arr_ln, n_prev - 1)
                line.set_extend(prev_ln, extend.none)
                line.set_x2(prev_ln, time)
            x1 = not na(start_time) ? start_time : time
            new_ln = line.new(x1, price, time + bar_ms, price,
                 xloc = xloc.bar_time, extend = EXTEND,
                 style = style_i, color = col, width = line_width)
            array.push(arr_ln, new_ln)
            if show_labels
                new_lb = label.new(time + label_dx, price, txt,
                     xloc = xloc.bar_time, style = label.style_none,
                     textcolor = col, size = LABEL_SIZE,
                     textalign = text.align_left)
                array.push(arr_lb, new_lb)
            // Trim to keep_n
            while array.size(arr_ln) > keep_n
                line.delete(array.shift(arr_ln))
            while array.size(arr_lb) > keep_n
                label.delete(array.shift(arr_lb))
        else
            // Move x2 of the current (last) line and its label forward every bar
            n = array.size(arr_ln)
            if n > 0
                last_ln = array.get(arr_ln, n - 1)
                line.set_x2(last_ln, time)
            m = array.size(arr_lb)
            if m > 0
                last_lb = array.get(arr_lb, m - 1)
                label.set_x(last_lb, time + label_dx)

// =============================================================================
// DRAW PREVIOUS DAY LEVELS
// =============================================================================
if allow_daily
    f_add_or_update(ln_pdh,   lb_pdh,   show_pdh,   is_new_day, keep_days, pdh,   col_pd, MAIN_STYLE, "PDH",    1, pd_start_t)
    f_add_or_update(ln_pdl,   lb_pdl,   show_pdl,   is_new_day, keep_days, pdl,   col_pd, MAIN_STYLE, "PDL",    2, pd_start_t)
    f_add_or_update(ln_pdmid, lb_pdmid, show_pdmid, is_new_day, keep_days, pdmid, col_pd, MID_STYLE,  "PD MID", 3, pd_start_t)

// =============================================================================
// DRAW PREVIOUS WEEK LEVELS
// =============================================================================
if allow_weekly
    f_add_or_update(ln_pwh,   lb_pwh,   show_pwh,   is_new_week, keep_weeks, pwh,   col_pw, MAIN_STYLE, "PWH",    4, pw_start_t)
    f_add_or_update(ln_pwl,   lb_pwl,   show_pwl,   is_new_week, keep_weeks, pwl,   col_pw, MAIN_STYLE, "PWL",    5, pw_start_t)
    f_add_or_update(ln_pwmid, lb_pwmid, show_pwmid, is_new_week, keep_weeks, pwmid, col_pw, MID_STYLE,  "PW MID", 6, pw_start_t)

// =============================================================================
// DRAW PREVIOUS MONTH LEVELS
// =============================================================================
if allow_monthly
    f_add_or_update(ln_pmh,   lb_pmh,   show_pmh,   is_new_month, keep_months, pmh,   col_pm, MAIN_STYLE, "PMH",    7, pm_start_t)
    f_add_or_update(ln_pml,   lb_pml,   show_pml,   is_new_month, keep_months, pml,   col_pm, MAIN_STYLE, "PML",    8, pm_start_t)
    f_add_or_update(ln_pmmid, lb_pmmid, show_pmmid, is_new_month, keep_months, pmmid, col_pm, MID_STYLE,  "PM MID", 9, pm_start_t)

// =============================================================================
// INFO TABLE — compact right-side summary of every enabled level
// One row per level: name, price, % distance to current close.
// Built once, refilled on the last bar only.
// =============================================================================
var table info_tbl = na

f_dist_col(float d) =>
    if na(d)
        color.new(color.gray, 20)
    else if d > 0.05
        color.new(#1d7d6a, 0)
    else if d < -0.05
        color.new(#f23645, 0)
    else
        color.new(color.gray, 20)

f_dist_txt(float d) =>
    if na(d)
        "—"
    else
        (d >= 0 ? "+" : "") + str.tostring(d, "#.##") + "%"

// Add a single row into the table if the level is enabled and non-na.
f_tbl_row(int row, simple bool visible, float price, string name, color col) =>
    if visible and not na(price)
        d = na(close) or close == 0 ? na : (price - close) / close * 100.0
        table.cell(info_tbl, 0, row, name,
             text_color = col,             text_size = TBL_SIZE, text_halign = text.align_left)
        table.cell(info_tbl, 1, row, str.tostring(price, format.mintick),
             text_color = color.new(color.white, 0),
             text_size = TBL_SIZE, text_halign = text.align_right)
        if tbl_show_dist
            table.cell(info_tbl, 2, row, f_dist_txt(d),
                 text_color = f_dist_col(d),
                 text_size = TBL_SIZE, text_halign = text.align_right)
        row + 1
    else
        row

if show_info_table and barstate.islast
    if na(info_tbl)
        info_tbl := table.new(TBL_POS, columns = 3, rows = 14,
             bgcolor = color.new(#0a0a0b, tbl_bg_opacity),
             border_width = 0,
             frame_width  = 0)
    // Wipe the entire table first (safer than tracking prior row count)
    for _r = 0 to 13
        for _c = 0 to 2
            table.cell(info_tbl, _c, _r, "", bgcolor = color.new(color.white, 100))

    r = 0
    if allow_daily
        r := f_tbl_row(r, show_pdh,   pdh,   "PDH",    col_pd)
        r := f_tbl_row(r, show_pdl,   pdl,   "PDL",    col_pd)
        r := f_tbl_row(r, show_pdmid, pdmid, "PD MID", col_pd)
    if allow_weekly
        r := f_tbl_row(r, show_pwh,   pwh,   "PWH",    col_pw)
        r := f_tbl_row(r, show_pwl,   pwl,   "PWL",    col_pw)
        r := f_tbl_row(r, show_pwmid, pwmid, "PW MID", col_pw)
    if allow_monthly
        r := f_tbl_row(r, show_pmh,   pmh,   "PMH",    col_pm)
        r := f_tbl_row(r, show_pml,   pml,   "PML",    col_pm)
        r := f_tbl_row(r, show_pmmid, pmmid, "PM MID", col_pm)

// =============================================================================
// ROUND-NUMBER GRID
// Re-anchors around price on every bar; drawn only on the last real bar
// to keep chart light and avoid history clutter.
// =============================================================================
if show_round and barstate.islast
    // clear previous frame
    while array.size(ln_round) > 0
        line.delete(array.shift(ln_round))
    while array.size(lb_round) > 0
        label.delete(array.shift(lb_round))

    base = math.round(close / round_step) * round_step
    bar_ms = timeframe.in_seconds() * 1000
    left_time = time - bar_ms * 50
    for i = -round_count to round_count
        if i != 0
            lvl = base + i * round_step
            if lvl > 0
                new_ln = line.new(left_time, lvl, time, lvl,
                     xloc = xloc.bar_time, extend = EXTEND,
                     style = ROUND_STYLE, color = col_round, width = 1)
                array.push(ln_round, new_ln)
                if show_labels
                    new_lb = label.new(time, lvl,
                         str.tostring(lvl, format.mintick),
                         xloc = xloc.bar_time, style = label.style_none,
                         textcolor = col_round, size = size.tiny,
                         textalign = text.align_left)
                    array.push(lb_round, new_lb)

// =============================================================================
// ALERTS
// ta.crossover/crossunder/cross must be called in the global scope on every
// bar so their history is consistent. We compute the raw cross first, then
// gate it with na-checks and visibility flags inside alertcondition().
// =============================================================================
raw_cross_pdh = ta.crossover(high,  pdh)
raw_cross_pdl = ta.crossunder(low,  pdl)

raw_cross_pwh = ta.crossover(high,  pwh)
raw_cross_pwl = ta.crossunder(low,  pwl)

raw_cross_pmh = ta.crossover(high,  pmh)
raw_cross_pml = ta.crossunder(low,  pml)

alertcondition(allow_daily   and show_pdh and not na(pdh) and raw_cross_pdh,
     "PDH touched",  "Key Levels: price touched previous day high (PDH)")
alertcondition(allow_daily   and show_pdl and not na(pdl) and raw_cross_pdl,
     "PDL touched",  "Key Levels: price touched previous day low (PDL)")

alertcondition(allow_weekly  and show_pwh and not na(pwh) and raw_cross_pwh,
     "PWH touched",  "Key Levels: price touched previous week high (PWH)")
alertcondition(allow_weekly  and show_pwl and not na(pwl) and raw_cross_pwl,
     "PWL touched",  "Key Levels: price touched previous week low (PWL)")

alertcondition(allow_monthly and show_pmh and not na(pmh) and raw_cross_pmh,
     "PMH touched",  "Key Levels: price touched previous month high (PMH)")
alertcondition(allow_monthly and show_pml and not na(pml) and raw_cross_pml,
     "PML touched",  "Key Levels: price touched previous month low (PML)")
````
