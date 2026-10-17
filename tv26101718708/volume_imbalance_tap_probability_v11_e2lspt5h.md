# Volume Imbalance Tap Probability v1.1

- url: https://www.tradingview.com/script/e2LSPt5h-Volume-Imbalance-Tap-Probability-v1-1/
- type: indicator
- pine_id: PUB;5ca717770a8e4a978fd5fcd1bc95d710
- version: 2.0

## Description

Tracks volume imbalances on the current chart time frame and produces a probability table for how often the imbalances are filled "n" bars later, based on user input (ie. 50, 100, etc. bars).

## Source Code

````pine
// ══════════════════════════════════════════════════════════════════════════════
//  ICT Volume Imbalance — Fill Probability
//  Author : Claude (Anthropic)
//  Modified by: leifl
//  Version: 1.1
//
//  Detects Volume Imbalances (close-to-open gap between consecutive candles)
//  within a user-defined session window, then tracks whether price re-enters
//  the imbalance zone within a user-defined candle lookback.  Results are
//  displayed in a color-coded probability table on the chart.
//
//  Volume Imbalance definition (ICT):
//    • Bullish VI  — close of bar[N-1]  <  open of bar[N]  (gap up)
//    • Bearish VI  — close of bar[N-1]  >  open of bar[N]  (gap down)
//
//  "Filled" definition:
//    • Bullish VI filled  — a future candle's LOW  trades ≤ the gap top (open of bar[N])
//    • Bearish VI filled  — a future candle's HIGH trades ≥ the gap bot (open of bar[N])
//
//  Note: the candle that CREATES the VI is excluded from fill-checking.
// ══════════════════════════════════════════════════════════════════════════════

//@version=5
indicator("Volume Imbalance Tap Probability",
     shorttitle  = "VI Fill Prob",
     overlay     = true,
     max_boxes_count = 500)

// ─── Input groups ─────────────────────────────────────────────────────────────
var string G_FILT = "⚙  Filters"
var string G_VIS  = "🎨  Visuals"
var string G_TBL  = "📊  Table"

// Filter inputs
i_session  = input.session("0930-1530",
             title   = "Session (exchange time)",
             group   = G_FILT,
             tooltip = "Only VIs that form inside this session window are counted.\nFormat: HHMM-HHMM  (24-hour, exchange-local time).")

i_lookback = input.int(50,
             title   = "Lookback — candles to check for fill",
             group   = G_FILT,
             minval  = 1,
             maxval  = 500,
             tooltip = "How many candles AFTER the VI forms to monitor for a fill.\nA VI that is not filled within this window is counted as 'unfilled'.")

i_fill_mode = input.string(
     "Tap",
     "Fill Mode",
     options = ["Tap", "Full Fill"],
     group = G_FILT,
     tooltip = "Tap = counts when price first touches VI.\nFull Fill = counts only when price trades through entire VI range.")

// Visual inputs
i_show_zones  = input.bool(true, title   = "Show VI zones on chart", group   = G_VIS)

i_bull_col    = input.color(color.new(#009708, 78), title   = "Bullish VI fill color", group   = G_VIS)

i_bear_col    = input.color(color.new(#ef5350, 78), title   = "Bearish VI fill color", group   = G_VIS)

i_bull_border = input.color(color.new(#0da000, 20), title   = "Bullish VI border color", group   = G_VIS)

i_bear_border = input.color(color.new(#ef5350, 20), title   = "Bearish VI border color", group   = G_VIS)

// Table inputs
i_tbl_pos = input.string("Bottom Right", title   = "Table position", group   = G_TBL, options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"])

i_tbl_size = input.string("Small", title   = "Table text size", group   = G_TBL, options = ["Tiny", "Small", "Normal"])


// ─── Helper functions ─────────────────────────────────────────────────────────

// Map position string → Pine position constant
f_pos() =>
    switch i_tbl_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Left"  => position.bottom_left
        =>               position.bottom_right

// Map size string → Pine size constant
f_size() =>
    switch i_tbl_size
        "Tiny"   => size.tiny
        "Normal" => size.normal
        =>          size.small

// Format probability as "XX.X%" or "—" when no data
f_pct(hit, tot) =>
    tot > 0 ? str.tostring(math.round(hit / tot * 100, 1)) + "%" : "—"

// Color-code the probability cell (green ≥ 60 %, orange 40–59 %, red < 40 %)
f_prob_col(hit, tot) =>
    if tot == 0
        color.new(color.gray, 55)
    else
        p = hit / tot * 100
        p >= 60 ? color.new(#00897b, 35) :
         p >= 40 ? color.new(#f57c00, 35) :
                   color.new(#c62828, 35)


// ─── Session filter ───────────────────────────────────────────────────────────
in_session = not na(time(timeframe.period, i_session))


// ─── VI detection ─────────────────────────────────────────────────────────────
//   We need at least one completed bar behind us.
is_bull_vi = in_session and open > close[1] and low <= high[1] and close > open and close[1] > open[1]
is_bear_vi = in_session and open < close[1] and high >= low[1] and close < open and close[1] < open[1]


// ─── Active VI tracking arrays ────────────────────────────────────────────────
//   Each newly detected VI is pushed into these arrays.
//   Once a VI is filled OR expires (lookback exhausted), it is removed.
var int[]   a_bar  = array.new_int()    // bar_index of the VI candle
var float[] a_top  = array.new_float()  // upper edge of the imbalance zone
var float[] a_bot  = array.new_float()  // lower edge of the imbalance zone
var int[]   a_type = array.new_int()    // 1 = bullish, -1 = bearish
var box[] a_box = array.new_box()


// ─── Running counters ─────────────────────────────────────────────────────────
var int bull_total = 0   // all bullish VIs detected in session
var int bull_hit   = 0   // bullish VIs that were filled within lookback
var int bear_total = 0
var int bear_hit   = 0


// ─── Resolve existing VIs (check fill / expiry) ───────────────────────────────
sz = array.size(a_bar)
if sz > 0
    for i = sz - 1 to 0
        b       = array.get(a_bar,  i)
        top     = array.get(a_top,  i)
        bot     = array.get(a_bot,  i)
        t       = array.get(a_type, i)
        bx      = array.get(a_box,  i)
        elapsed = bar_index - b

        filled = elapsed >= 1 and (
               i_fill_mode == "Tap" ?
                      (t == 1 ? low <= top : high >= bot)
               :
                      (t == 1 ? low <= bot : high >= top)
          )

        expired = elapsed >= i_lookback
        // freeze box when tapped
        if filled
            box.set_right(bx, bar_index)

        if filled or expired
            if filled
                if t == 1
                    bull_hit += 1
                else
                    bear_hit += 1

            array.remove(a_bar,  i)
            array.remove(a_top,  i)
            array.remove(a_bot,  i)
            array.remove(a_type, i)
            array.remove(a_box,  i)


// ─── Register new VIs ─────────────────────────────────────────────────────────
if is_bull_vi
    bull_total += 1
    array.push(a_bar,  bar_index)
    array.push(a_top,  open)
    array.push(a_bot,  close[1])
    array.push(a_type, 1)

    if i_show_zones
        bx = box.new(
             left         = bar_index - 1,
             top          = open,
             right        = bar_index + i_lookback,
             bottom       = close[1],
             border_color = i_bull_border,
             border_width = 1,
             bgcolor      = i_bull_col)

        array.push(a_box, bx)
    else
        array.push(a_box, na)

if is_bear_vi
    bear_total += 1
    array.push(a_bar,  bar_index)
    array.push(a_top,  close[1])
    array.push(a_bot,  open)
    array.push(a_type, -1)

    if i_show_zones
        bx = box.new(
             left         = bar_index - 1,
             top          = close[1],
             right        = bar_index + i_lookback,
             bottom       = open,
             border_color = i_bear_border,
             border_width = 1,
             bgcolor      = i_bear_col)

        array.push(a_box, bx)
    else
        array.push(a_box, na)


// ─── Table ────────────────────────────────────────────────────────────────────
var table tbl = table.new(
     f_pos(), 4, 5,
     bgcolor      = color.new(#1a1a2e, 12),
     border_color = color.new(color.gray, 55),
     border_width = 1,
     frame_color  = color.new(color.gray, 40),
     frame_width  = 1)

// Shared style constants
HDR_BG  = color.new(#0d1b2a, 10)
CELL_BG = color.new(#1a1a2e, 25)
TXT     = color.white
MUTED   = color.new(color.white, 40)
TS      = f_size()

if barstate.islast

    // ── Row 0 — header ────────────────────────────────────────────────────────
    table.cell(tbl, 0, 0, "VI Type",
         text_color = MUTED, bgcolor = HDR_BG, text_size = TS,
         text_halign = text.align_center)
    table.cell(tbl, 1, 0, "Total",
         text_color = MUTED, bgcolor = HDR_BG, text_size = TS,
         text_halign = text.align_center)
    table.cell(tbl, 2, 0, "Filled",
         text_color = MUTED, bgcolor = HDR_BG, text_size = TS,
         text_halign = text.align_center)
    table.cell(tbl, 3, 0, "Fill %",
         text_color = MUTED, bgcolor = HDR_BG, text_size = TS,
         text_halign = text.align_center)

    // ── Row 1 — bullish VI ────────────────────────────────────────────────────
    table.cell(tbl, 0, 1, "▲  Bullish VI",
         text_color = #00bfa5, bgcolor = CELL_BG, text_size = TS,
         text_halign = text.align_left)
    table.cell(tbl, 1, 1, str.tostring(bull_total),
         text_color = TXT,    bgcolor = CELL_BG, text_size = TS,
         text_halign = text.align_center)
    table.cell(tbl, 2, 1, str.tostring(bull_hit),
         text_color = TXT,    bgcolor = CELL_BG, text_size = TS,
         text_halign = text.align_center)
    table.cell(tbl, 3, 1, f_pct(bull_hit, bull_total),
         text_color = TXT,    bgcolor = f_prob_col(bull_hit, bull_total),
         text_size = TS,      text_halign = text.align_center)

    // ── Row 2 — bearish VI ────────────────────────────────────────────────────
    table.cell(tbl, 0, 2, "▼  Bearish VI",
         text_color = #ef5350, bgcolor = CELL_BG, text_size = TS,
         text_halign = text.align_left)
    table.cell(tbl, 1, 2, str.tostring(bear_total),
         text_color = TXT,    bgcolor = CELL_BG, text_size = TS,
         text_halign = text.align_center)
    table.cell(tbl, 2, 2, str.tostring(bear_hit),
         text_color = TXT,    bgcolor = CELL_BG, text_size = TS,
         text_halign = text.align_center)
    table.cell(tbl, 3, 2, f_pct(bear_hit, bear_total),
         text_color = TXT,    bgcolor = f_prob_col(bear_hit, bear_total),
         text_size = TS,      text_halign = text.align_center)

    // ── Row 3 — overall ───────────────────────────────────────────────────────
    ot = bull_total + bear_total
    oh = bull_hit   + bear_hit
    table.cell(tbl, 0, 3, "◈  Overall",
         text_color = color.white, bgcolor = CELL_BG, text_size = TS,
         text_halign = text.align_left)
    table.cell(tbl, 1, 3, str.tostring(ot),
         text_color = TXT, bgcolor = CELL_BG, text_size = TS,
         text_halign = text.align_center)
    table.cell(tbl, 2, 3, str.tostring(oh),
         text_color = TXT, bgcolor = CELL_BG, text_size = TS,
         text_halign = text.align_center)
    table.cell(tbl, 3, 3, f_pct(oh, ot),
         text_color = TXT, bgcolor = f_prob_col(oh, ot),
         text_size = TS,   text_halign = text.align_center)

    // ── Row 4 — footer / settings summary ────────────────────────────────────
    footer_txt = "Lookback: " + str.tostring(i_lookback) +
                 " bars  |  Session: " + i_session +
                 "  |  Pending: " + str.tostring(array.size(a_bar))
    table.cell(tbl, 0, 4, footer_txt,
         text_color  = color.new(color.white, 55),
         bgcolor     = color.new(#0d1b2a, 5),
         text_size   = size.tiny,
         text_halign = text.align_left)
    table.merge_cells(tbl, 0, 4, 3, 4)
````
