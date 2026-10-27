# EDC's Weekly Vol Index SD Levels

- url: https://www.tradingview.com/script/hEaqDKhY-EDC-s-Weekly-Vol-Index-SD-Levels/
- type: indicator
- pine_id: PUB;26c3f11c495e424b98b170cde75fdec7
- version: 2.0

## Description

EDC's Weekly Vol Index SD Levels plots weekly expected move levels from a 9-day volatility index. The levels are calculated once at the start of the week and stay fixed until the next week begins.

How it works
The script reads last week's closing value of the selected volatility index (default CBOE:VIX9D) and the prior week close of the chart symbol. It converts the annualized volatility reading into a one-week expected move and plots 1σ, 2σ and 3σ levels above and below the prior week close.

What's on the chart
Weekly 1σ, 2σ and 3σ highs and lows
Weekly references: weekly open, prior week close, running week high and low
Daily references: opening price, previous session close and open, running session high and low
A table showing the volatility index value used, the weekly expected move in points, and each σ high and low

Settings
Week Basis lets you choose how the week is measured. 5 Trading Days (default) uses a 252-day year. 7 Calendar Days uses a 365-day year and gives a slightly smaller move.
Every level has its own toggle and color. The table position, size and rows are adjustable. Custom overrides are available for the prior week close and weekly open if you want to use your own values. Labels can be offset from price, and values can be shown in the status line.

Built for SPX, ES and SPY with VIX9D. Levels are statistical reference points based on implied volatility, not trade signals.

## Source Code

````pine
//@version=6
indicator("EDC's Weekly Vol Index SD Levels", overlay=true, max_bars_back=500)

// ─── Volatility Index Standard Deviations ────────────────────────────────────
// The volatility index is read automatically off last week's final close, same way the
// prior week close works for price, so it's fixed for the whole week and never moves intraday.
// Built around a 9-day volatility index, which fits a one-week window. Default is VIX9D for SPX/ES/SPY.
// Expected Move = (Vol Index / sqrt(days per year)) * sqrt(days in week) / 100 * Prior Week Close
// 5 Trading Days: sqrt(252) = 15.87 and sqrt(5). 7 Calendar Days: sqrt(365) = 19.10 and sqrt(7).
// Levels are centered on the prior week close.
vix_ticker = input.symbol("CBOE:VIX9D", title="Volatility Index", tooltip="9-day volatility index used for the expected move. Default is VIX9D for SPX/ES/SPY. Labels and the table update to match the index name.", group="Volatility Index Standard Deviations")
use_custom_prior_close = input.bool(false, title="Use Custom Prior Week Close", tooltip="Enable to manually enter a prior week close instead of using TradingView's weekly close", group="Volatility Index Standard Deviations")
custom_prior_close     = input.float(0.0, title="Custom Prior Week Close", tooltip="Only used when 'Use Custom Prior Week Close' is enabled", step=0.25, group="Volatility Index Standard Deviations")
use_custom_open        = input.bool(false, title="Use Custom Weekly Open", tooltip="Enable to manually enter a weekly open instead of using TradingView's weekly open", group="Volatility Index Standard Deviations")
custom_open            = input.float(0.0, title="Custom Weekly Open", tooltip="Only used when 'Use Custom Weekly Open' is enabled", step=0.25, group="Volatility Index Standard Deviations")

week_basis = input.string("5 Trading Days", title="Week Basis", options=["5 Trading Days", "7 Calendar Days"], tooltip="5 Trading Days: one trading week's move. Divides the index by 15.87 (sqrt of 252) and scales up by sqrt(5).\n\n7 Calendar Days: one calendar week's move. Divides the index by 19.10 (sqrt of 365) and scales up by sqrt(7). Slightly smaller than 5 Trading Days.\n\nVIX9D is the best fit for either option. VIX prices 30 days out, while VIX9D prices 9 days out, which is closer to a one-week window.", group="Volatility Index Standard Deviations")

use_calendar = week_basis == "7 Calendar Days"
VOL_DIVISOR  = use_calendar ? math.sqrt(365.0) : 15.87             // Converts the annualized reading to one day
WEEK_FACTOR  = use_calendar ? math.sqrt(7.0)   : math.sqrt(5.0)    // Scales one day up to the week

// ─── Display ──────────────────────────────────────────────────────────────────
show_values_status_line = input.bool(false, title="Show Values in Status Line", tooltip="Off by default to keep the status line clean. Turn on to see live values next to the indicator name.", group="Display")
label_offset            = input.int(10, title="Label Offset (bars)", minval=0, tooltip="How many bars to the right of the last bar the labels are placed.", group="Display")
disp      = show_values_status_line ? display.all : display.pane + display.price_scale

// Short name of the chosen index for labels and the table (CBOE:VIX9D -> VIX9D)
vol_parts = str.split(vix_ticker, ":")
vol_name  = array.get(vol_parts, array.size(vol_parts) - 1)

// Transparency: this week's levels fully bright, reference levels pushed back
T_SD   = 0
T_REF  = 35

// ─── Table ────────────────────────────────────────────────────────────────────
show_em      = input.bool(true, title="Show Table", tooltip="Table with the volatility index value, this week's expected move, and the σ levels.", group="Table")
em_pos_in    = input.string("Top Right", title="Position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group="Table")
em_size_in   = input.string("Normal", title="Size", options=["Tiny", "Small", "Normal", "Large"], group="Table")
tbl_show_em  = input.bool(true, title="Show Vol Index / Expected Move Row", group="Table")
tbl_show_sd1 = input.bool(true, title="Show 1σ Row", group="Table")
tbl_show_sd2 = input.bool(true, title="Show 2σ Row", group="Table")
tbl_show_sd3 = input.bool(true, title="Show 3σ Row", group="Table")

// ─── SD Colors ────────────────────────────────────────────────────────────────
show_sd      = input.bool(true, title="Show Weekly Standard Deviation Levels", tooltip="Solid σ lines: this week's levels. Held all week. The live index does not move these.", group="SD Colors")
show_sd_sd1  = input.bool(true, title="Standard Deviation 1", inline="sd1", group="SD Colors")
col_sd1      = input.color(#4FD1C5, title="",                 inline="sd1", group="SD Colors")
show_sd_sd2  = input.bool(true, title="Standard Deviation 2", inline="sd2", group="SD Colors")
col_sd2      = input.color(#E58FD8, title="",                 inline="sd2", group="SD Colors")
show_sd_sd3  = input.bool(true, title="Standard Deviation 3", inline="sd3", group="SD Colors")
col_sd3      = input.color(#F5A65B, title="",                 inline="sd3", group="SD Colors")

sd_on_sd1 = show_sd and show_sd_sd1
sd_on_sd2 = show_sd and show_sd_sd2
sd_on_sd3 = show_sd and show_sd_sd3

// ─── Weekly Reference Colors ────────────────────────────────────────────────────────
show_open            = input.bool(true, title="Show Weekly Open",          inline="ref_open",    tooltip="Weekly open. Updates when the new weekly bar opens.", group="Weekly Reference Colors")
col_open             = input.color(#8F8CFF, title="",                      inline="ref_open",    group="Weekly Reference Colors")
show_prev_close      = input.bool(true, title="Show Prior Week Close",     inline="ref_pclose",  tooltip="Anchor for this week's σ levels.", group="Weekly Reference Colors")
col_prev_close       = input.color(#6A4FB0, title="",                      inline="ref_pclose",  group="Weekly Reference Colors")
show_hod             = input.bool(true, title="Show Week High",            inline="ref_hod",     tooltip="Running week high. Updates live.", group="Weekly Reference Colors")
col_hod              = input.color(#3FA06B, title="",                      inline="ref_hod",     group="Weekly Reference Colors")
show_lod             = input.bool(true, title="Show Week Low",             inline="ref_lod",     tooltip="Running week low. Updates live.", group="Weekly Reference Colors")
col_lod              = input.color(#B0578F, title="",                      inline="ref_lod",     group="Weekly Reference Colors")

// ─── Daily Reference Colors ───────────────────────────────────────────────────
show_d_open       = input.bool(true, title="Show Opening Price",          inline="d_open",   tooltip="Session open. Updates when the new daily bar opens.", group="Daily Reference Colors")
col_d_open        = input.color(#21c9f3, title="",                        inline="d_open",   group="Daily Reference Colors")
show_d_prev_close = input.bool(true, title="Show Previous Session Close", inline="d_pclose", tooltip="Close of the previous session.", group="Daily Reference Colors")
col_d_prev_close  = input.color(#005eff, title="",                        inline="d_pclose", group="Daily Reference Colors")
show_d_prev_open  = input.bool(true, title="Show Previous Session Open",  inline="d_popen",  tooltip="Open of the previous session.", group="Daily Reference Colors")
col_d_prev_open   = input.color(color.rgb(25, 105, 0), title="",                        inline="d_popen",  group="Daily Reference Colors")
show_d_high       = input.bool(true, title="Show Session High",           inline="d_high",   tooltip="Running session high. Updates live.", group="Daily Reference Colors")
col_d_high        = input.color(color.green, title="",                        inline="d_high",   group="Daily Reference Colors")
show_d_low        = input.bool(true, title="Show Session Low",            inline="d_low",    tooltip="Running session low. Updates live.", group="Daily Reference Colors")
col_d_low         = input.color(color.red, title="",                        inline="d_low",    group="Daily Reference Colors")

// ─── Data ────────────────────────────────────────────────────────────────────
open_price      = use_custom_open ? custom_open : request.security(syminfo.tickerid, "W", open, lookahead=barmerge.lookahead_on)
prev_close      = use_custom_prior_close ? custom_prior_close : request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)

vix_close_1 = request.security(vix_ticker, "W", close[1], lookahead=barmerge.lookahead_on)

// Daily reference values off the chart symbol's daily bar
d_open       = request.security(syminfo.tickerid, "D", open,     lookahead=barmerge.lookahead_on)
d_prev_close = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
d_prev_open  = request.security(syminfo.tickerid, "D", open[1],  lookahead=barmerge.lookahead_on)

// Running session high/low, reset on the first bar of each new session
new_day = ta.change(time("D")) != 0
var float d_high = na
var float d_low  = na
if new_day or na(d_high)
    d_high := high
    d_low  := low
else
    d_high := math.max(d_high, high)
    d_low  := math.min(d_low, low)

// Running week high/low, reset on the first bar of each new week
new_week = ta.change(time("W")) != 0
var float hod = na
var float lod = na
if new_week or na(hod)
    hod := high
    lod := low
else
    hod := math.max(hod, high)
    lod := math.min(lod, low)

// ─── σ Levels ───────────────────────────────────────────────────────────
// This week: centered on the prior week close, using last week's volatility index close
sd1_pts = (vix_close_1 / VOL_DIVISOR) * WEEK_FACTOR / 100.0 * prev_close

d1h = prev_close + 1 * sd1_pts,  d1l = prev_close - 1 * sd1_pts
d2h = prev_close + 2 * sd1_pts,  d2l = prev_close - 2 * sd1_pts
d3h = prev_close + 3 * sd1_pts,  d3l = prev_close - 3 * sd1_pts

// ─── Plots ───────────────────────────────────────────────────────────────────
// Reference levels (muted)
plot(show_open            ? open_price      : na, "Weekly Open",           color=color.new(col_open, T_REF),            linewidth=1, display=disp)
plot(show_prev_close      ? prev_close      : na, "Prior Week Close",      color=color.new(col_prev_close, T_REF),      linewidth=1, display=disp)
plot(show_hod             ? hod             : na, "Week High",             color=color.new(col_hod, T_REF),             linewidth=1, display=disp)
plot(show_lod             ? lod             : na, "Week Low",              color=color.new(col_lod, T_REF),             linewidth=1, display=disp)

// Daily reference levels (muted)
plot(show_d_open       ? d_open       : na, "Opening Price",          color=color.new(col_d_open, T_REF),       linewidth=1, display=disp)
plot(show_d_prev_close ? d_prev_close : na, "Previous Session Close", color=color.new(col_d_prev_close, T_REF), linewidth=1, display=disp)
plot(show_d_prev_open  ? d_prev_open  : na, "Previous Session Open",  color=color.new(col_d_prev_open, T_REF),  linewidth=1, display=disp)
plot(show_d_high       ? d_high       : na, "Session High",           color=color.new(col_d_high, T_REF),       linewidth=1, display=disp)
plot(show_d_low        ? d_low        : na, "Session Low",            color=color.new(col_d_low, T_REF),        linewidth=1, display=disp)

// This week's σ levels (bright, primary)
plot(sd_on_sd3 ? d3h : na, "Weekly 3σ High", color=color.new(col_sd3, T_SD), linewidth=3, display=disp)
plot(sd_on_sd2 ? d2h : na, "Weekly 2σ High", color=color.new(col_sd2, T_SD), linewidth=3, display=disp)
plot(sd_on_sd1 ? d1h : na, "Weekly 1σ High", color=color.new(col_sd1, T_SD), linewidth=2, display=disp)
plot(sd_on_sd1 ? d1l : na, "Weekly 1σ Low",  color=color.new(col_sd1, T_SD), linewidth=2, display=disp)
plot(sd_on_sd2 ? d2l : na, "Weekly 2σ Low",  color=color.new(col_sd2, T_SD), linewidth=3, display=disp)
plot(sd_on_sd3 ? d3l : na, "Weekly 3σ Low",  color=color.new(col_sd3, T_SD), linewidth=3, display=disp)

// ─── Level → Label Connector Lines (this week + reference) ───────────────────
var line[] conn_lines = array.new_line()

f_conn(cond, y, col, width) =>
    if cond
        array.push(conn_lines, line.new(bar_index, y, bar_index + label_offset, y, xloc=xloc.bar_index, extend=extend.none, color=col, width=width))

if barstate.islast
    if array.size(conn_lines) > 0
        for i = 0 to array.size(conn_lines) - 1
            line.delete(array.get(conn_lines, i))
        array.clear(conn_lines)

    f_conn(show_open,            open_price,      color.new(col_open, T_REF),            1)
    f_conn(show_prev_close,      prev_close,      color.new(col_prev_close, T_REF),      1)
    f_conn(show_hod,             hod,             color.new(col_hod, T_REF),             1)
    f_conn(show_lod,             lod,             color.new(col_lod, T_REF),             1)

    f_conn(show_d_open,          d_open,          color.new(col_d_open, T_REF),          1)
    f_conn(show_d_prev_close,    d_prev_close,    color.new(col_d_prev_close, T_REF),    1)
    f_conn(show_d_prev_open,     d_prev_open,     color.new(col_d_prev_open, T_REF),     1)
    f_conn(show_d_high,          d_high,          color.new(col_d_high, T_REF),          1)
    f_conn(show_d_low,           d_low,           color.new(col_d_low, T_REF),           1)

    f_conn(sd_on_sd3, d3h, color.new(col_sd3, T_SD), 3)
    f_conn(sd_on_sd2, d2h, color.new(col_sd2, T_SD), 3)
    f_conn(sd_on_sd1, d1h, color.new(col_sd1, T_SD), 2)
    f_conn(sd_on_sd1, d1l, color.new(col_sd1, T_SD), 2)
    f_conn(sd_on_sd2, d2l, color.new(col_sd2, T_SD), 3)
    f_conn(sd_on_sd3, d3l, color.new(col_sd3, T_SD), 3)

// ─── Labels ──────────────────────────────────────────────────────────────────
var label lb_open            = na
var label lb_prev_close      = na
var label lb_hod             = na
var label lb_lod             = na
var label lb_d_open          = na
var label lb_d_prev_close    = na
var label lb_d_prev_open     = na
var label lb_d_high          = na
var label lb_d_low           = na
var label lb_d1h = na
var label lb_d1l = na
var label lb_d2h = na
var label lb_d2l = na
var label lb_d3h = na
var label lb_d3l = na

// Creates/updates the label when shown, deletes it when hidden
f_label(lb, cond, price, txt, col, tcol) =>
    l = lb
    if cond
        if na(l)
            l := label.new(bar_index + label_offset, price, txt, style=label.style_label_left, color=col, textcolor=tcol, size=size.normal)
        else
            label.set_xy(l, bar_index + label_offset, price)
            label.set_text(l, txt)
            label.set_color(l, col)
            label.set_textcolor(l, tcol)
    else if not na(l)
        label.delete(l)
        l := na
    l

f_txt(name, price) => name + ": " + str.tostring(price, "#,##0.00")

TXT_REF = color.white
TXT_SD  = color.black

if barstate.islast
    // Reference labels (muted)
    lb_open            := f_label(lb_open,            show_open,            open_price,      f_txt("Weekly Open",         open_price),      color.new(col_open, T_REF),            TXT_REF)
    lb_prev_close      := f_label(lb_prev_close,      show_prev_close,      prev_close,      f_txt("Prior Week Close",    prev_close),      color.new(col_prev_close, T_REF),      TXT_REF)
    lb_hod             := f_label(lb_hod,             show_hod,             hod,             f_txt("Week High",           hod),             color.new(col_hod, T_REF),             TXT_REF)
    lb_lod             := f_label(lb_lod,             show_lod,             lod,             f_txt("Week Low",            lod),             color.new(col_lod, T_REF),             TXT_REF)

    // Daily reference labels (muted)
    lb_d_open       := f_label(lb_d_open,       show_d_open,       d_open,       f_txt("Opening Price",          d_open),       color.new(col_d_open, T_REF),       TXT_REF)
    lb_d_prev_close := f_label(lb_d_prev_close, show_d_prev_close, d_prev_close, f_txt("Previous Session Close", d_prev_close), color.new(col_d_prev_close, T_REF), TXT_REF)
    lb_d_prev_open  := f_label(lb_d_prev_open,  show_d_prev_open,  d_prev_open,  f_txt("Previous Session Open",  d_prev_open),  color.new(col_d_prev_open, T_REF),  TXT_REF)
    lb_d_high       := f_label(lb_d_high,       show_d_high,       d_high,       f_txt("Session High",           d_high),       color.new(col_d_high, T_REF),       TXT_REF)
    lb_d_low        := f_label(lb_d_low,        show_d_low,        d_low,        f_txt("Session Low",            d_low),        color.new(col_d_low, T_REF),        TXT_REF)

    // This week's σ labels (bright)
    lb_d1h := f_label(lb_d1h, sd_on_sd1, d1h, f_txt("Weekly 1σ High", d1h), color.new(col_sd1, T_SD), TXT_SD)
    lb_d1l := f_label(lb_d1l, sd_on_sd1, d1l, f_txt("Weekly 1σ Low",  d1l), color.new(col_sd1, T_SD), TXT_SD)
    lb_d2h := f_label(lb_d2h, sd_on_sd2, d2h, f_txt("Weekly 2σ High", d2h), color.new(col_sd2, T_SD), TXT_SD)
    lb_d2l := f_label(lb_d2l, sd_on_sd2, d2l, f_txt("Weekly 2σ Low",  d2l), color.new(col_sd2, T_SD), TXT_SD)
    lb_d3h := f_label(lb_d3h, sd_on_sd3, d3h, f_txt("Weekly 3σ High", d3h), color.new(col_sd3, T_SD), TXT_SD)
    lb_d3l := f_label(lb_d3l, sd_on_sd3, d3l, f_txt("Weekly 3σ Low",  d3l), color.new(col_sd3, T_SD), TXT_SD)

// ─── Table ────────────────────────────────────────────────────────────────────
// Volatility index value used, one expected move in points, and this week's σ highs and lows.
// Each row can be turned on or off under the Table settings.
em_pos = switch em_pos_in
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.top_right

em_size = switch em_size_in
    "Tiny"  => size.tiny
    "Small" => size.small
    "Large" => size.large
    => size.normal

TBL_HEAD = color.new(#2A2E39, 0)
TBL_ROW  = color.new(#131722, 10)
TBL_TXT  = color.white
TBL_LINE = color.new(#434651, 0)

var table em_tbl = table.new(em_pos, 3, 6, border_color=TBL_LINE, border_width=1, frame_color=TBL_LINE, frame_width=1)

f_num(v) => na(v) ? "n/a" : str.tostring(v, "#,##0.00")

f_head(r, a, b, c) =>
    table.cell(em_tbl, 0, r, a, text_color=TBL_TXT, bgcolor=TBL_HEAD, text_size=em_size, text_halign=text.align_left)
    table.cell(em_tbl, 1, r, b, text_color=TBL_TXT, bgcolor=TBL_HEAD, text_size=em_size)
    table.cell(em_tbl, 2, r, c, text_color=TBL_TXT, bgcolor=TBL_HEAD, text_size=em_size)

f_row(r, name, name_col, b, c) =>
    table.cell(em_tbl, 0, r, name, text_color=name_col, bgcolor=TBL_ROW, text_size=em_size, text_halign=text.align_left)
    table.cell(em_tbl, 1, r, b,    text_color=TBL_TXT,  bgcolor=TBL_ROW, text_size=em_size, text_halign=text.align_right)
    table.cell(em_tbl, 2, r, c,    text_color=TBL_TXT,  bgcolor=TBL_ROW, text_size=em_size, text_halign=text.align_right)

if barstate.islast
    table.clear(em_tbl, 0, 0, 2, 5)
    if show_em
        r = 0
        if tbl_show_em
            f_head(r, "Weekly EM", "Vol", "Move")
            r += 1
            f_row(r, vol_name, col_sd1, f_num(vix_close_1), f_num(sd1_pts) + " pts")
            r += 1
        if tbl_show_sd1 or tbl_show_sd2 or tbl_show_sd3
            f_head(r, "Level", "High", "Low")
            r += 1
            if tbl_show_sd1
                f_row(r, "1σ", col_sd1, f_num(d1h), f_num(d1l))
                r += 1
            if tbl_show_sd2
                f_row(r, "2σ", col_sd2, f_num(d2h), f_num(d2l))
                r += 1
            if tbl_show_sd3
                f_row(r, "3σ", col_sd3, f_num(d3h), f_num(d3l))
                r += 1
````
