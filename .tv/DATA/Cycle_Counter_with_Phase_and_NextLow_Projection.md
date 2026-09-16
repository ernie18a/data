<!-- tradingview-pine-id: PUB;e6f14f21d0544866a7094b7e60e9e907 -->
<!-- tradingview-pine-version: 2.0 -->
<!-- tradingviewscripts-format: 1 -->
# Cycle Counter with Phase and Next-Low Projection

Source: https://www.tradingview.com/script/Z2cwzfML-Cycle-Counter-with-Phase-and-Next-Low-Projection/

## Description

WHAT THIS SCRIPT DOES

Cycle Counter measures your position inside a low-to-low price cycle that you anchor yourself. On a Daily, Weekly or Monthly chart it reports four things:

how many candles have elapsed since the cycle low
which phase of the cycle that count falls into — Early, Mid or Late
the projected date of the next cycle low
how many periods remain until that date, or how many the cycle is overdue by

It produces no entries, no exits and no buy or sell signals. It is a timing-context tool that answers "where am I in this cycle" rather than "what should I do now".

HOW THE CYCLE START IS DEFINED

Everything the script reports is measured from a single anchored low, and you control how that anchor is set. Three methods are available in Cycle Start Method:

Manual Date — you type the exact date of the low. The date you enter does not change as new candles form.
Click on Chart — when you add the indicator you click the low candle directly. The clicked date is held once confirmed.
Auto Pivot Low — the script finds the most recent significant low using a symmetric pivot test with configurable strength, defaulting to three candles either side.

After the anchor is placed, the Snap to true lowest low option watches the first few candles from that point, defaulting to three, and re-anchors to the lowest wick it finds inside that window. This exists because a clicked candle or a typed date often lands one or two bars away from the true extreme, and without the correction every count and projection downstream inherits that error. With snap enabled the count begins at the actual low rather than the bar you happened to select, so the effective start can sit a candle or two away from the date you entered. Switch snap off if you want the count to begin exactly on your chosen date.

THE COUNT AND THE BASIS

The count is the number of candles from the anchored low to the current bar, with the low candle itself counting as 1. The unit therefore follows the chart: months on a Monthly chart, weeks on Weekly, days on Daily.

Cycle Basis set to Auto follows the chart timeframe automatically. You can also pin the basis manually. On any timeframe other than Daily, Weekly or Monthly the output is suppressed and a notice is shown instead, because a count expressed in cycle periods has no meaning on a 4-hour or 15-minute chart.

The count itself is displayed either as a number above every recent candle, or as a marker on the anchored low alone, depending on the On-Chart Display setting. When the low-marker display is active the anchored candle is recoloured, a triangle is plotted beneath it, and a dashed vertical line with a tag showing the low's date is drawn at that candle. Auto uses numbers on Monthly and the low marker on Weekly and Daily, since a number above every candle becomes unreadable on the shorter bases.

PHASE

The elapsed count is bucketed into three phases against boundaries you set separately for each basis. The Monthly defaults treat months 1 through 6 as Early, 7 through 18 as Mid, and anything beyond as Late. Weekly and Daily carry their own boundaries and their own defaults.

Phase drives the colour of the on-chart numbers, so the ageing of a cycle is legible at a glance without reading any figure — the run of numbers shifts from the Early colour through Mid to Late as the cycle matures. The boundaries are inputs rather than fixed values because a multi-year cycle on one instrument and a multi-week cycle on another do not divide into thirds the same way.

PROJECTING THE NEXT LOW

The expected cycle length comes from one of two places. Either the manual length for the active basis — defaults are 48 months, 26 weeks and 40 days — or, with Auto-detect cycle length enabled, the average spacing between all pivot lows the script has found on the loaded history, using the same pivot strength as the Auto Pivot Low anchor.

One detail worth knowing: when the Monthly lock is on, the auto-detected length replaces the manual monthly length only while you are viewing a Monthly chart, because that is where a monthly measurement can actually be taken. On Weekly or Daily the locked projection falls back to the manual monthly length. Set your cycle length on the Monthly chart, then move down.

From the anchored low the script steps forward in whole cycle lengths until it passes the current bar, and marks that date as the projected next low. Around it, a shaded window spans that date plus and minus a percentage of the cycle length, defaulting to 15%, converted into real calendar time.

Draw projected next-low line is the master switch for this whole group: with it off, nothing is projected. With it on, the shaded window, its border, the centre dotted line and the date label can each be turned on or off separately, and the window can be set to fill the full height of the pane.

The table reports the projected date alongside a countdown, which flips to reading how many periods the cycle is overdue once the projected date passes without a low.

THE MONTHLY LOCK

Lock projection to Monthly cycle is on by default and is the part of this script that behaves differently from a plain bar counter.

With it enabled, the projection is computed in calendar months from the Monthly cycle length regardless of which chart you are looking at. The consequence is that the projected date and the window width are identical on Daily, Weekly and Monthly. You anchor the cycle low once on the Monthly chart, and every lower timeframe then inherits that same forward target rather than computing its own from its own period count.

The practical difference: without the lock, a Daily chart with a 40-day cycle length projects a low roughly 40 days out while the Monthly chart projects one years out, and the two disagree. With the lock on, you can drop from Monthly to Daily to study a setup on a finer timeframe around the projected low, and the target date does not move under you. The count still re-bases to days so you keep the finer resolution — only the projection is held constant.

WHAT IS ORIGINAL HERE

Low-to-low cycle analysis is long-established public trading theory and this script makes no claim to have originated it. What is original is the implementation.

The only built-in technical indicator used anywhere in this script is ta.pivotlow, and it appears in just two optional roles: locating an anchor when you select Auto Pivot Low, and estimating average cycle length when you enable auto-detection. Anchor manually with a fixed length and the script calls no built-in indicator at all. The only other ta. function used is ta.change, which simply detects when you edit the anchor input so the count can reset.

Everything else is written for this script specifically: the snap-to-true-low correction window, the basis-aware counting that re-expresses the same cycle in months, weeks or days, the per-basis phase boundaries with their own colour mapping, the calendar-time projection that holds a single date constant across every timeframe, and the overdue countdown.

There is no moving average, RSI, Bollinger Band, MACD, WaveTrend, stochastic or supertrend derivative in the script. It is not a mashup of existing indicators and it is not a rehash of a built-in.

WHY THESE COMPONENTS ARE ONE SCRIPT

The parts form a single chain in which each stage consumes the output of the one before it. The anchor establishes an origin. The snap corrects that origin to the true extreme. The count measures elapsed time from it. Phase interprets that count against the expected cycle length. The projection extends the same origin and length forward to a date. The table reports all of it together.

None of these is useful in isolation. A phase reading with no count has nothing to classify. A projection with no anchor has no origin to project from. Separating them into individual scripts would force a user to keep the same anchor date synchronised by hand across several indicators, and any drift between them would silently corrupt every reading.

HOW TO USE IT

Open the Monthly chart of the instrument you want to track.
Add the indicator. With Click on Chart selected you will be asked to click a candle — click the cycle low you want to measure from. Alternatively choose Manual Date and type the date.
Check the Last low row in the table shows the date you intended. If it has moved by a candle or two, that is the snap finding a lower wick nearby.
Set the Monthly cycle length to whatever your framework expects, or switch on auto-detect and read the Detected row to see what the loaded history suggests.
Leave the Monthly lock enabled, then drop to Weekly or Daily. The count re-bases to weeks or days while the projected low date stays where it was.

Reading the output: a Late-phase count approaching the projected window is the cautious configuration, since the cycle is both old and near its expected turn. An Early-phase count well short of the window is the opposite. The Due row is the fastest read in the table — "in 3 mo" and "overdue 5 mo" are very different situations even at the same phase.

SETTINGS

Cycle Basis — Auto follows the chart, or pin to Monthly, Weekly or Daily.

Cycle Start — the method, the click target, the manual date, and the pivot strength used by Auto Pivot Low.

On-Chart Display — Auto shows numbers on Monthly and a highlighted low candle on lower timeframes; you can also force Numbers or Low Marker. Includes the highlight colour and a cap on how many recent bars carry numbers, defaulting to 60, which keeps long histories readable.

Projection — the Monthly lock, the next-low line master switch, the shaded window, full-height fill, border, centre line, label, the window tolerance as a percentage of cycle length, and colour.

Accuracy — snap to true lowest low, the snap search window, and whether to hide output on unsupported timeframes.

Number Appearance — plain text or label box, text size, and box text colour.

Phase — Monthly / Weekly / Daily — the Early and Mid boundaries for each basis.

Cycle Length — the auto-detect toggle and the manual length for each basis.

Phase Colors — Early, Mid and Late.

Table — show or hide, and corner position.

LIMITATIONS

Manual Date and Click on Chart do not repaint. The anchor is a fixed timestamp and every value derived from it is stable across reloads.
Auto Pivot Low does repaint. A pivot is only confirmed once the configured number of candles have printed past it, and if a new qualifying low forms later the anchor jumps to it and every count, phase and projection shifts accordingly. Anchor manually if you need stability.
The snap can move the anchor by up to the configured window during the first candles of a cycle.
The projection is arithmetic, not a probability estimate. It assumes the next cycle runs the same length as the configured or measured one, and real cycles stretch and compress.
Auto-detected length is a plain average of pivot spacings across the loaded history. It is only as good as the pivot strength setting and how much history the chart has loaded, and on noisy series it will underestimate true cycle length.
Window fills full height extends the box far beyond the data and will compress the price scale unless you right-click the price axis and enable Scale price chart only.
On instruments with no persistent cyclicality the outputs are arbitrary.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TOJI88

//@version=6
indicator("Cycle Counter with Phase and Next-Low Projection", shorttitle="Cycle Counter", overlay=true, max_labels_count=500, max_lines_count=500, max_boxes_count=500)

// ── CYCLE BASIS ──────────────────────────────────────────────
i_basis = input.string("Auto (follow chart)", "Cycle Basis",
     options=["Auto (follow chart)", "Monthly", "Weekly", "Daily"], group="Cycle Basis",
     tooltip="Auto = months on Monthly, weeks on Weekly, days on Daily.\nSet your cycle low ONCE on the Monthly chart; lower timeframes count from that same low automatically.")

// ── HOW THE CYCLE STARTS (set on the MONTHLY chart) ──────────
i_mode = input.string("Manual Date", "Cycle Start Method",
     options=["Click on Chart", "Auto Pivot Low", "Manual Date"], group="Cycle Start",
     tooltip="Click on Chart: when you ADD the indicator on Monthly, click your cycle-low candle.\nManual Date: type the exact low date.\nAuto Pivot Low: detect the most recent significant low. Note: this method updates as new pivots form.")
i_click_low  = input.time(timestamp("01 Jan 2025 00:00"), "→ Click the Cycle Low (Monthly)", confirm=true, group="Cycle Start")
i_manual_low = input.time(timestamp("01 Nov 2022 00:00"), "→ Manual Cycle Low Date", group="Cycle Start")
i_piv_len    = input.int(3, "→ Auto Pivot Strength", minval=1, maxval=20, group="Cycle Start")

// ── ON-CHART DISPLAY ─────────────────────────────────────────
i_display = input.string("Auto", "On-Chart Display", options=["Auto", "Numbers", "Low Marker"],
     group="On-Chart Display",
     tooltip="Auto = numbers on Monthly, low-candle marker on Weekly/Daily (recommended).\nNumbers = a number on every candle.\nLow Marker = highlight only the cycle-low candle.")
i_low_col  = input.color(color.new(#00E5FF, 0), "Cycle-Low Highlight Color", group="On-Chart Display")
i_max_labels = input.int(60, "Numbers: show only on last N bars", minval=5, maxval=500, group="On-Chart Display")

// ── PROJECTION ───────────────────────────────────────────────
i_proj_lock = input.bool(true, "Lock projection to Monthly cycle (same on all timeframes)", group="Projection",
     tooltip="On = the line and timing window use the Monthly cycle in real calendar time, so they appear at the same date and same width on Weekly/Daily too.\nOff = each timeframe projects its own cycle.")
i_proj_line = input.bool(true,  "Draw projected next-low line", group="Projection")
i_proj_win  = input.bool(true,  "Shade timing window", group="Projection")
i_proj_fullheight = input.bool(false, "Window fills full height", group="Projection",
     tooltip="Extends the shaded window top-to-bottom. This will distort the price scale unless you right-click the price axis and enable 'Scale price chart only'.")
i_proj_border = input.bool(true, "Window border", group="Projection")
i_proj_center = input.bool(true, "Center dotted line", group="Projection")
i_proj_label  = input.bool(true, "Projection label", group="Projection")
i_proj_tol  = input.float(15, "Timing window (± % of cycle length)", minval=0, maxval=50, group="Projection")
i_proj_col  = input.color(color.new(#A78BFA, 0), "Projection Color", group="Projection")

// ── ACCURACY ─────────────────────────────────────────────────
i_snap        = input.bool(true, "Snap to true lowest low (wick)", group="Accuracy")
i_snap_window = input.int(3, "Snap search window (bars)", minval=0, maxval=24, group="Accuracy")
i_guard       = input.bool(true, "Hide on unsupported timeframes", group="Accuracy")

// ── NUMBER APPEARANCE ────────────────────────────────────────
i_appearance = input.string("Text Only", "Number Appearance", options=["Text Only", "Label Box"], group="Number Appearance")
i_text_size  = input.string("Normal", "Number Size", options=["Tiny", "Small", "Normal", "Large", "Huge"], group="Number Appearance")
i_box_text   = input.color(color.white, "Label Box Text Color", group="Number Appearance")

// ── PHASE BOUNDARIES (per basis) ─────────────────────────────
i_m_early = input.int(6,  "Monthly: Early ends at month", minval=1, maxval=120, group="Phase — Monthly")
i_m_mid   = input.int(18, "Monthly: Mid ends at month",   minval=1, maxval=120, group="Phase — Monthly")
i_w_early = input.int(8,  "Weekly: Early ends at week",    minval=1, maxval=200, group="Phase — Weekly")
i_w_mid   = input.int(22, "Weekly: Mid ends at week",      minval=1, maxval=200, group="Phase — Weekly")
i_d_early = input.int(12, "Daily: Early ends at day",      minval=1, maxval=400, group="Phase — Daily")
i_d_mid   = input.int(28, "Daily: Mid ends at day",        minval=1, maxval=400, group="Phase — Daily")

// ── EXPECTED CYCLE LENGTH (for projection) ──────────────────
i_auto_len = input.bool(false, "Auto-detect cycle length from chart", group="Cycle Length",
     tooltip="On = use the average spacing between detected lows as the cycle length (works on any asset). Off = use the manual lengths below.\nUses the same detection strength as 'Auto Pivot Strength' in Cycle Start. Set/run on the Monthly chart for the monthly-locked projection.")
i_m_len = input.int(48, "Monthly cycle length (months)", minval=1, maxval=240, group="Cycle Length")
i_w_len = input.int(26, "Weekly cycle length (weeks)",    minval=1, maxval=200, group="Cycle Length")
i_d_len = input.int(40, "Daily cycle length (days)",      minval=1, maxval=400, group="Cycle Length")

// ── PHASE COLORS ─────────────────────────────────────────────
i_col_early = input.color(color.new(#00E5FF, 0), "Early Phase Color", group="Phase Colors")
i_col_mid   = input.color(color.new(#F5A623, 0), "Mid Phase Color",   group="Phase Colors")
i_col_late  = input.color(color.new(#FF4757, 0), "Late Phase Color",  group="Phase Colors")

// ── TABLE ────────────────────────────────────────────────────
i_show_table = input.bool(true, "Show info table", group="Table")
i_table_pos  = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="Table")

// ── RESOLVE EFFECTIVE BASIS ──────────────────────────────────
string eff_basis = i_basis
if i_basis == "Auto (follow chart)"
    eff_basis := timeframe.ismonthly ? "Monthly" : timeframe.isweekly ? "Weekly" : timeframe.isdaily ? "Daily" : "None"

bool is_m = eff_basis == "Monthly"
bool is_w = eff_basis == "Weekly"
bool is_d = eff_basis == "Daily"

int    early_end = is_m ? i_m_early : is_w ? i_w_early : i_d_early
int    mid_end   = is_m ? i_m_mid   : is_w ? i_w_mid   : i_d_mid
int    exp_len   = is_m ? i_m_len   : is_w ? i_w_len   : i_d_len
string unit      = is_m ? "mo" : is_w ? "wk" : "d"

bool tf_ok = (is_m and timeframe.ismonthly) or (is_w and timeframe.isweekly) or (is_d and timeframe.isdaily)

// ── DISPLAY FLAGS ────────────────────────────────────────────
bool show_numbers = i_display == "Numbers" or (i_display == "Auto" and is_m)
bool show_marker  = i_display == "Low Marker" or (i_display == "Auto" and not is_m)

// ── TEXT SIZE ────────────────────────────────────────────────
txt_size = switch i_text_size
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    "Huge"  => size.huge
    =>         size.normal

// ── TRACK CHART EXTREMES (for full-height lines/boxes) ──────
var float hi_all = na
var float lo_all = na
hi_all := na(hi_all) ? high : math.max(hi_all, high)
lo_all := na(lo_all) ? low  : math.min(lo_all, low)

// ── RESOLVE THE CYCLE START + AUTO-DETECT CYCLE LENGTH ──────
pl = ta.pivotlow(low, i_piv_len, i_piv_len)
var int auto_time = na
var array<int> pv_bars = array.new<int>()
if not na(pl)
    auto_time := time[i_piv_len]
    array.push(pv_bars, bar_index[i_piv_len])

// average spacing between detected lows (in chart-basis periods)
int det_len = na
if array.size(pv_bars) >= 2
    int s = 0
    for i = 1 to array.size(pv_bars) - 1
        s += array.get(pv_bars, i) - array.get(pv_bars, i - 1)
    det_len := int(math.round(s / (array.size(pv_bars) - 1)))

int anchor = switch i_mode
    "Manual Date"    => i_manual_low
    "Auto Pivot Low" => auto_time
    =>                  i_click_low

// ── SNAP TO TRUE LOW (tracks value, time and bar) ───────────
var float ll_val  = na
var int   ll_time = na
var int   ll_bar  = na
var int   bars_in = na

if ta.change(anchor) != 0
    ll_val  := na
    ll_time := na
    ll_bar  := na
    bars_in := 0

if not na(anchor) and time >= anchor
    bars_in := na(bars_in) ? 0 : bars_in + 1
    if i_snap and bars_in <= i_snap_window
        if na(ll_val) or low <= ll_val
            ll_val  := low
            ll_time := time
            ll_bar  := bar_index
    else if not i_snap and na(ll_bar)
        ll_val  := low
        ll_time := anchor
        ll_bar  := bar_index

// ── COUNT = candles since the low ───────────────────────────
int count = na
if not na(ll_bar) and bar_index >= ll_bar
    count := bar_index - ll_bar + 1

// ── PHASE ────────────────────────────────────────────────────
color phase_col = na
string phase_nm = "—"
if not na(count)
    if count <= early_end
        phase_col := i_col_early
        phase_nm  := "Early"
    else if count <= mid_end
        phase_col := i_col_mid
        phase_nm  := "Mid"
    else
        phase_col := i_col_late
        phase_nm  := "Late"

// ── PROJECTED NEXT LOW ───────────────────────────────────────
// When "lock to Monthly" is on, the projection uses the MONTHLY cycle
// in absolute calendar time, so the line + window are identical on every
// timeframe (same date, same width). Otherwise it uses the chart's basis.
// Effective cycle lengths: auto-detected (if enabled and available) else manual.
// Monthly-locked projection only auto-overrides when measured on a Monthly chart.
int eff_m_len = (i_auto_len and is_m and not na(det_len)) ? det_len : i_m_len
int eff_len   = (i_auto_len and not na(det_len)) ? det_len : exp_len

int    next_low_time = na
int    due_in        = na
string proj_unit     = unit
float  win_half_ms   = na

if not na(ll_time)
    if i_proj_lock
        int ms_since = (year(time) - year(ll_time)) * 12 + (month(time) - month(ll_time))
        int cyc      = int(ms_since / eff_m_len)
        int total    = (cyc + 1) * eff_m_len
        due_in       := total - ms_since
        proj_unit    := "mo"
        int base = (month(ll_time) - 1) + total
        int ny = year(ll_time) + int(base / 12)
        int nm = (base % 12) + 1
        next_low_time := timestamp(ny, nm, dayofmonth(ll_time), 0, 0)
        win_half_ms   := eff_m_len * 2629746000.0 * i_proj_tol / 100.0
    else if not na(count)
        int periods_since = count - 1
        int cyc   = int(periods_since / eff_len)
        int total = (cyc + 1) * eff_len
        due_in    := total - periods_since
        if is_m
            int base = (month(ll_time) - 1) + total
            int ny = year(ll_time) + int(base / 12)
            int nm = (base % 12) + 1
            next_low_time := timestamp(ny, nm, dayofmonth(ll_time), 0, 0)
            win_half_ms   := eff_len * 2629746000.0 * i_proj_tol / 100.0
        else if is_w
            next_low_time := ll_time + total * 604800000
            win_half_ms   := eff_len * 604800000.0 * i_proj_tol / 100.0
        else
            next_low_time := ll_time + total * 86400000
            win_half_ms   := eff_len * 86400000.0 * i_proj_tol / 100.0

bool can_draw = (not i_guard) or tf_ok
bool is_low_bar = not na(ll_bar) and bar_index == ll_bar

// ════════════════════════════════════════════════════════════
//  ON-CHART DRAWING
// ════════════════════════════════════════════════════════════

// ── NUMBERS (recent bars only) ───────────────────────────────
bool recent = bar_index > last_bar_index - i_max_labels
if show_numbers and not na(count) and can_draw and recent
    bool text_only = i_appearance == "Text Only"
    label.new(bar_index, high, str.tostring(count),
         style     = text_only ? label.style_none : label.style_label_down,
         color     = text_only ? color.new(color.white, 100) : color.new(phase_col, 20),
         textcolor = text_only ? phase_col : i_box_text,
         size      = txt_size, yloc = yloc.abovebar)

// ── LOW-CANDLE HIGHLIGHT (the clean alternative to numbers) ──
barcolor(show_marker and can_draw and is_low_bar ? i_low_col : na, title="Cycle Low Candle")
plotshape(show_marker and can_draw and is_low_bar, title="Cycle Low Mark",
     style=shape.triangleup, location=location.belowbar, color=i_low_col, size=size.small)

// ── MARKER + PROJECTION (drawn once on the last bar) ────────
var line  lo_line   = na
var label lo_lbl    = na
var line  proj_ln   = na
var label proj_lbl  = na
var box   proj_box  = na

if barstate.islast
    line.delete(lo_line)
    label.delete(lo_lbl)
    line.delete(proj_ln)
    label.delete(proj_lbl)
    box.delete(proj_box)

    if can_draw and not na(ll_time)
        string low_date = str.format_time(ll_time, "yyyy-MM-dd", syminfo.timezone)

        // full-height extent (extends well beyond data so it fills the pane)
        float pad   = hi_all - lo_all
        float top_y = i_proj_fullheight ? hi_all + pad * 100 : hi_all
        float bot_y = i_proj_fullheight ? lo_all - pad * 100 : lo_all

        // mark the confirmed low
        if show_marker
            lo_line := line.new(ll_time, bot_y, ll_time, top_y, xloc=xloc.bar_time,
                 color=color.new(i_low_col, 40), width=1, style=line.style_dashed)
            lo_lbl := label.new(ll_time, ll_val, "▲ CYCLE LOW\n" + low_date, xloc=xloc.bar_time,
                 style=label.style_label_up, color=i_low_col, textcolor=color.white,
                 size=size.small, yloc=yloc.price)

        // project the next low forward
        if i_proj_line and not na(next_low_time)
            string next_date = str.format_time(next_low_time, "yyyy-MM-dd", syminfo.timezone)

            if i_proj_win and not na(win_half_ms)
                int win_ms = int(win_half_ms)
                proj_box := box.new(next_low_time - win_ms, top_y, next_low_time + win_ms, bot_y,
                     xloc=xloc.bar_time,
                     border_color = i_proj_border ? color.new(i_proj_col, 70) : color.new(i_proj_col, 100),
                     bgcolor=color.new(i_proj_col, 90))

            if i_proj_center
                proj_ln := line.new(next_low_time, bot_y, next_low_time, top_y, xloc=xloc.bar_time,
                     color=i_proj_col, width=2, style=line.style_dashed)

            if i_proj_label
                proj_lbl := label.new(next_low_time, hi_all, "Next low ≈\n" + next_date, xloc=xloc.bar_time,
                     style=label.style_label_down, color=i_proj_col, textcolor=color.white, size=size.small)

// ── TABLE ────────────────────────────────────────────────────
tpos = switch i_table_pos
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    =>                position.top_right

if i_show_table and barstate.islast and can_draw
    var table t = table.new(tpos, 2, 5, bgcolor=color.new(#0D0D0D, 8),
         border_color=color.new(#333333, 0), border_width=1,
         frame_color=color.new(#444444, 0), frame_width=1)

    string low_date  = na(ll_time)       ? "—" : str.format_time(ll_time, "yyyy-MM-dd", syminfo.timezone)
    string next_date = na(next_low_time) ? "—" : str.format_time(next_low_time, "yyyy-MM-dd", syminfo.timezone)
    string cur_txt   = na(count)  ? "—" : str.tostring(count) + " " + unit + (phase_nm == "—" ? "" : "  ·  " + phase_nm)
    string due_txt   = na(due_in) ? "—" : (due_in >= 0 ? "in " + str.tostring(due_in) + " " + proj_unit : "overdue " + str.tostring(-due_in) + " " + proj_unit)
    color  cur_col   = na(phase_col) ? color.new(#888888, 0) : phase_col

    table.cell(t, 0, 0, "CYCLE",      text_color=color.white, text_size=size.normal, bgcolor=color.new(#111111,0))
    table.cell(t, 1, 0, eff_basis,    text_color=color.new(#AAAAAA,0), text_size=size.small, bgcolor=color.new(#111111,0))
    table.cell(t, 0, 1, "Last low",   text_color=color.new(#888888,0), text_size=size.small, bgcolor=color.new(#0D0D0D,0))
    table.cell(t, 1, 1, low_date,     text_color=color.white, text_size=size.small, bgcolor=color.new(#0D0D0D,0))
    table.cell(t, 0, 2, "Current",    text_color=color.new(#888888,0), text_size=size.small, bgcolor=color.new(#111111,0))
    table.cell(t, 1, 2, cur_txt,      text_color=cur_col, text_size=size.normal, bgcolor=color.new(#111111,0))
    table.cell(t, 0, 3, "Next low ≈", text_color=color.new(#888888,0), text_size=size.small, bgcolor=color.new(#0D0D0D,0))
    table.cell(t, 1, 3, next_date,    text_color=i_proj_col, text_size=size.small, bgcolor=color.new(#0D0D0D,0))
    table.cell(t, 0, 4, "Due",        text_color=color.new(#888888,0), text_size=size.small, bgcolor=color.new(#111111,0))
    table.cell(t, 1, 4, due_txt,      text_color=color.white, text_size=size.small, bgcolor=color.new(#111111,0))

// ── WARNING IF ON UNSUPPORTED TIMEFRAME ─────────────────────
if i_guard and not tf_ok and barstate.islast
    label.new(bar_index, high, "⚠ Use a Daily, Weekly or Monthly chart",
         style=label.style_label_left, color=color.new(#FF4757, 0),
         textcolor=color.white, size=size.normal, yloc=yloc.price)
````
