# Annual Return V6

- url: https://www.tradingview.com/script/rGJ2Esgc-Annual-Return-V6/
- type: indicator
- pine_id: PUB;676111debade4767b783dcb13d32cb03
- version: 1.0

## Description

Provide the annual return calculation in the subplot. Moved to version 6 and asked Claude to also get this to work on annual bars (12M).  Nice job Claude. Please comment if there are errors or if you enjoy the script.

## Source Code

````pine
//@version=6
indicator("Annual Return V6", shorttitle="YrReturn", overlay=false, max_labels_count=500)

// ─── Colors ───────────────────────────────────────────────────────────────────
color C_GREEN    = color.new(color.green, 20)
color C_RED      = color.new(color.red,   20)
color C_BOUNDARY = color.new(color.blue,  85)

// ─── Mode detection ───────────────────────────────────────────────────────────
bool is_12M = timeframe.period == "12M"

// ─── Helper functions ─────────────────────────────────────────────────────────
f_sign(float v) => v >= 0.0 ? "+" : ""
f_pct(float v)  => f_sign(v) + str.tostring(v, "#.##") + "%"

// ─── Mode A: 12M chart ────────────────────────────────────────────────────────
// Each bar IS a year — compare close to prior bar's close directly.
float return_12M = not na(close[1]) and close[1] != 0.0 ? (close - close[1]) / close[1] * 100.0 : na
col_12M          = not na(return_12M) ? (return_12M >= 0.0 ? C_GREEN : C_RED) : na

// ─── Mode B: Sub-annual timeframes ────────────────────────────────────────────
// close[1] on the 12M series = the previous completed year's close.
// lookahead_on delivers that settled prior-year close to every bar within the
// current year — no future leakage because close[1] is the prior year, not the
// forming one. Works on all timeframes including 5-min.
float prev_year_close = request.security(syminfo.tickerid, "12M", close[1], lookahead=barmerge.lookahead_on)
float return_line     = not na(prev_year_close) and prev_year_close != 0.0 ? (close - prev_year_close) / prev_year_close * 100.0 : na
col_line              = not na(return_line) ? (return_line >= 0.0 ? C_GREEN : C_RED) : na

// ─── Year boundary detection (Mode B only) ────────────────────────────────────
// Watch prev_year_close changing instead of year(time) — the latter can misfire
// on monthly charts due to exchange timezone offsets.
bool is_new_year = not is_12M and not na(prev_year_close) and ta.change(prev_year_close) != 0.0

// ─── Plots ────────────────────────────────────────────────────────────────────
// Mode A — histogram: one bar per year. Hover to see value in the data window.
plot(is_12M ? return_12M : na, title="Annual Return", style=plot.style_columns, color=col_12M, linewidth=1)

// Mode B — line showing how annual return evolves bar by bar
// Plot na on the first bar of each new year to break the line connection
// between December's return and January's near-zero reset.
plot(not is_12M ? (is_new_year ? na : return_line) : na, title="Annual Return", style=plot.style_linebr, color=col_line, linewidth=2)

// Zero reference
hline(0, "Zero", color=color.gray, linestyle=hline.style_dashed)

// Year boundary flash (Mode B only)
bgcolor(is_new_year ? C_BOUNDARY : na, title="Year Boundary")

// ─── Labels ───────────────────────────────────────────────────────────────────

// Mode A: no persistent labels — data window shows value on hover.

// Mode B: year-end label pinned to the last bar of the completed year.
// xloc.bar_time + time[1] anchors to December rather than January.
if is_new_year and not na(return_line[1])
    float r  = return_line[1]
    int   yr = year(time[1])
    label.new(
         x         = int(time[1]),
         xloc      = xloc.bar_time,
         y         = r,
         text      = str.tostring(yr) + ": " + f_pct(r),
         style     = r >= 0.0 ? label.style_label_down : label.style_label_up,
         color     = r >= 0.0 ? C_GREEN : C_RED,
         textcolor = color.white,
         size      = size.small)

// Mode B: live YTD label — recreated every tick on the last bar
var label lbl_ytd = na
if barstate.islast and not is_12M and not na(return_line)
    label.delete(lbl_ytd)
    bool   ytd_pos  = return_line >= 0.0
    string ytd_text = str.tostring(year(time)) + " YTD: " + f_pct(return_line)
    lbl_ytd := label.new(
         x         = bar_index,
         y         = return_line,
         text      = ytd_text,
         style     = ytd_pos ? label.style_label_down : label.style_label_up,
         color     = ytd_pos ? C_GREEN : C_RED,
         textcolor = color.white,
         size      = size.small)
````
