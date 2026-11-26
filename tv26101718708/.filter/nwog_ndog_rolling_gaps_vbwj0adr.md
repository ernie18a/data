# NWOG & NDOG Rolling Gaps

- url: https://www.tradingview.com/script/VbWJ0aDR-NWOG-NDOG-Rolling-Gaps/
- type: indicator
- pine_id: PUB;111beeb91fa34baba79d887f770b382f
- version: 1.0

## Description

Description:
This indicator automatically detects, plots, and manages a rolling window of New Week Opening Gaps (NWOG) and New Day Opening Gaps (NDOG) on your chart. It is designed for traders who use opening gap zones as key areas of interest for price delivery, liquidity, and potential reversal or continuation setups.

WHAT IS AN OPENING GAP?
An opening gap forms when the current session's opening price differs from the previous session's closing price. This creates a price range between the two levels that often acts as a significant area of interest. These zones are widely monitored by price action traders as areas where price may return to seek liquidity or rebalance.

A New Week Opening Gap (NWOG) forms at the open of each new trading week relative to the prior weekly close
A New Day Opening Gap (NDOG) forms at the open of each new trading day relative to the prior daily close


HOW THE INDICATOR WORKS
On every new weekly open the indicator compares the current opening price to the previous weekly closing price. If a gap exists between the two levels it registers a new NWOG zone. The same logic applies on every new daily open for NDOGs, with Sunday excluded to avoid false gaps from weekend opens.
The indicator maintains a strict rolling window at all times:

The 4 most recent NWOGs are kept active and visible
The 5 most recent NDOGs are kept active and visible

As each new gap forms the oldest gap in the window is automatically deleted from the chart, keeping your chart clean and focused on the most relevant recent zones only.

ZONE STRUCTURE
Each gap zone is drawn with the following internal levels:

Top boundary — the higher of the two prices (open or prior close)
Bottom boundary — the lower of the two prices (open or prior close)
50% CE Midline — the exact midpoint between the top and bottom, representing the equilibrium of the gap. Drawn as a dashed line and can be toggled on or off
Q1 Level (25%) — sits one quarter of the way up from the bottom of the zone. Drawn as a dotted line
Q3 Level (75%) — sits three quarters of the way up from the bottom of the zone. Drawn as a dotted line
Filled box — a shaded rectangle covering the full gap range for easy visual identification


DYNAMIC EXTENSION
All drawings including the box, boundary lines, midline, quartile lines, and labels extend dynamically to the right of the current bar on every single bar update. The extension distance is fully user controlled in minutes and the indicator automatically converts that time into the correct number of bars based on whatever timeframe you are using. This means the zones always appear to float ahead of price giving you a clear forward-looking visual.

LABELS
Each zone carries an optional label displayed at the right edge of the zone showing:

Whether it is a NWOG or NDOG
The date the gap was formed in MM/DD format

Labels update their position dynamically alongside the zone extension so they never fall behind the current bar.

INFO TABLE
A small table is displayed in the top right corner of the chart showing:

How many NWOG zones are currently active
How many NDOG zones are currently active

This updates on the final bar so you always know exactly how many zones are plotted at any given time.

SETTINGS
NWOG Settings

NWOG box fill color — controls the background fill of the weekly gap zone
NWOG border and line color — controls the color of the top line, bottom line, midline, and quartile lines
NWOG line width — controls the thickness of the boundary lines, between 1 and 4
Show NWOG labels — toggles the date label on or off
Show NWOG 50% CE midline — toggles the dashed midline on or off

NDOG Settings

NDOG box fill color — controls the background fill of the daily gap zone
NDOG border and line color — controls the color of the top line, bottom line, midline, and quartile lines
NDOG line width — controls the thickness of the boundary lines, between 1 and 4
Show NDOG labels — toggles the date label on or off
Show NDOG 50% CE midline — toggles the dashed midline on or off

Extension Settings

Extend lines (mins past current bar) — sets how far ahead of the current bar all zone drawings extend, measured in minutes. Accepts values between 1 and 240. The indicator converts this automatically to the correct bar count for any timeframe


RECOMMENDED TIMEFRAMES
The indicator works on any intraday timeframe. The gap zones are most clearly visible and useful on timeframes between 1 minute and 1 hour where the internal structure of each zone can be seen clearly relative to price action.

TECHNICAL NOTES

Built in Pine Script v6
Uses request.security with lookahead_on to accurately read the prior daily and weekly close without repainting
Maximum of 500 lines, 500 boxes, and 100 labels supported
All drawings are fully managed through arrays ensuring no object leaks or buildup over time

## Source Code

````pine
//@version=6
indicator(title="ICT NWOG & NDOG Rolling Gaps", shorttitle="ICT Gaps", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=100)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
var string g_nwog       = "NWOG Settings"
color nwog_fill         = input.color(color.new(color.red, 70), "NWOG box fill",                group=g_nwog)
color nwog_border       = input.color(color.new(color.red, 20), "NWOG border / line color",     group=g_nwog)
int   nwog_lw           = input.int(1,    "NWOG line width", minval=1, maxval=4,                group=g_nwog)
bool  nwog_labels       = input.bool(true, "Show NWOG labels",                                  group=g_nwog)
bool  nwog_midline      = input.bool(true, "Show NWOG 50% CE midline",                          group=g_nwog)

var string g_ndog       = "NDOG Settings"
color ndog_fill         = input.color(color.new(color.blue, 75), "NDOG box fill",               group=g_ndog)
color ndog_border       = input.color(color.new(color.blue, 20), "NDOG border / line color",    group=g_ndog)
int   ndog_lw           = input.int(1,    "NDOG line width", minval=1, maxval=4,                group=g_ndog)
bool  ndog_labels       = input.bool(true, "Show NDOG labels",                                  group=g_ndog)
bool  ndog_midline      = input.bool(true, "Show NDOG 50% CE midline",                          group=g_ndog)

var string g_ext        = "Extension Settings"
int   extend_mins       = input.int(20, "Extend lines (mins past current bar)", minval=1, maxval=240, group=g_ext)

// ─── ARRAYS (persistent across bars) ─────────────────────────────────────────
var array<float> nwog_hi     = array.new<float>()
var array<float> nwog_lo     = array.new<float>()
var array<int>   nwog_ts     = array.new<int>()
var array<box>   nwog_boxes  = array.new<box>()
var array<line>  nwog_tops   = array.new<line>()
var array<line>  nwog_bots   = array.new<line>()
var array<line>  nwog_mids   = array.new<line>()
var array<line>  nwog_q1s    = array.new<line>()
var array<line>  nwog_q3s    = array.new<line>()
var array<label> nwog_lbls   = array.new<label>()

var array<float> ndog_hi     = array.new<float>()
var array<float> ndog_lo     = array.new<float>()
var array<int>   ndog_ts     = array.new<int>()
var array<box>   ndog_boxes  = array.new<box>()
var array<line>  ndog_tops   = array.new<line>()
var array<line>  ndog_bots   = array.new<line>()
var array<line>  ndog_mids   = array.new<line>()
var array<line>  ndog_q1s    = array.new<line>()
var array<line>  ndog_q3s    = array.new<line>()
var array<label> ndog_lbls   = array.new<label>()

// ─── EXTENSION OFFSET (timeframe-aware) ───────────────────────────────────────
int ext_offset = math.max(1, math.round(extend_mins * 60.0 / timeframe.in_seconds()))

// ─── HTF CLOSE REFERENCES ─────────────────────────────────────────────────────
float daily_close  = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_on)
float weekly_close = request.security(syminfo.tickerid, "W", close[1], lookahead=barmerge.lookahead_on)

// ─── SESSION CHANGE DETECTION ─────────────────────────────────────────────────
bool is_new_week = ta.change(time("W")) != 0
bool is_new_day  = ta.change(time("D")) != 0 and dayofweek != dayofweek.sunday

// ─── DELETE HELPERS ───────────────────────────────────────────────────────────
f_del_nwog(int idx) =>
    box.delete(nwog_boxes.get(idx))
    line.delete(nwog_tops.get(idx))
    line.delete(nwog_bots.get(idx))
    line.delete(nwog_mids.get(idx))
    line.delete(nwog_q1s.get(idx))
    line.delete(nwog_q3s.get(idx))
    label.delete(nwog_lbls.get(idx))

f_del_ndog(int idx) =>
    box.delete(ndog_boxes.get(idx))
    line.delete(ndog_tops.get(idx))
    line.delete(ndog_bots.get(idx))
    line.delete(ndog_mids.get(idx))
    line.delete(ndog_q1s.get(idx))
    line.delete(ndog_q3s.get(idx))
    label.delete(ndog_lbls.get(idx))

// ─── REMOVE HELPERS ───────────────────────────────────────────────────────────
f_remove_nwog(int idx) =>
    f_del_nwog(idx)
    nwog_hi.remove(idx)
    nwog_lo.remove(idx)
    nwog_ts.remove(idx)
    nwog_boxes.remove(idx)
    nwog_tops.remove(idx)
    nwog_bots.remove(idx)
    nwog_mids.remove(idx)
    nwog_q1s.remove(idx)
    nwog_q3s.remove(idx)
    nwog_lbls.remove(idx)

f_remove_ndog(int idx) =>
    f_del_ndog(idx)
    ndog_hi.remove(idx)
    ndog_lo.remove(idx)
    ndog_ts.remove(idx)
    ndog_boxes.remove(idx)
    ndog_tops.remove(idx)
    ndog_bots.remove(idx)
    ndog_mids.remove(idx)
    ndog_q1s.remove(idx)
    ndog_q3s.remove(idx)
    ndog_lbls.remove(idx)

// ─── CREATE HELPERS ───────────────────────────────────────────────────────────
f_add_nwog(float hi, float lo, int ts) =>
    float mid = math.avg(hi, lo)
    float q1  = lo  + (hi - lo) * 0.25
    float q3  = lo  + (hi - lo) * 0.75
    int   x1  = bar_index
    int   x2  = bar_index + ext_offset
    // Box with no border; top & bottom drawn as separate lines
    box   b   = box.new(x1, hi, x2, lo,
                 border_color=color.new(color.white, 100),
                 bgcolor=nwog_fill)
    line  t   = line.new(x1, hi,  x2, hi,  color=nwog_border, width=nwog_lw)
    line  bot = line.new(x1, lo,  x2, lo,  color=nwog_border, width=nwog_lw)
    line  m   = nwog_midline ?
                 line.new(x1, mid, x2, mid, color=nwog_border, width=1, style=line.style_dashed) :
                 line.new(x1, mid, x2, mid, color=color.new(color.white, 100))
    line  lq1 = line.new(x1, q1, x2, q1, color=nwog_border, width=1, style=line.style_dotted)
    line  lq3 = line.new(x1, q3, x2, q3, color=nwog_border, width=1, style=line.style_dotted)
    label lb  = nwog_labels ?
                 label.new(x2, hi,
                  "NWOG " + str.format("{0,date,MM/dd}", ts),
                  style=label.style_label_left,
                  color=color.new(color.red, 88),
                  textcolor=nwog_border, size=size.tiny) :
                 label.new(x2, hi, "", color=color.new(color.white, 100), textcolor=color.new(color.white, 100))
    nwog_hi.push(hi)
    nwog_lo.push(lo)
    nwog_ts.push(ts)
    nwog_boxes.push(b)
    nwog_tops.push(t)
    nwog_bots.push(bot)
    nwog_mids.push(m)
    nwog_q1s.push(lq1)
    nwog_q3s.push(lq3)
    nwog_lbls.push(lb)

f_add_ndog(float hi, float lo, int ts) =>
    float mid = math.avg(hi, lo)
    float q1  = lo  + (hi - lo) * 0.25
    float q3  = lo  + (hi - lo) * 0.75
    int   x1  = bar_index
    int   x2  = bar_index + ext_offset
    // Box with no border; top & bottom drawn as separate lines
    box   b   = box.new(x1, hi, x2, lo,
                 border_color=color.new(color.white, 100),
                 bgcolor=ndog_fill)
    line  t   = line.new(x1, hi,  x2, hi,  color=ndog_border, width=ndog_lw)
    line  bot = line.new(x1, lo,  x2, lo,  color=ndog_border, width=ndog_lw)
    line  m   = ndog_midline ?
                 line.new(x1, mid, x2, mid, color=ndog_border, width=1, style=line.style_dashed) :
                 line.new(x1, mid, x2, mid, color=color.new(color.white, 100))
    line  lq1 = line.new(x1, q1, x2, q1, color=ndog_border, width=1, style=line.style_dotted)
    line  lq3 = line.new(x1, q3, x2, q3, color=ndog_border, width=1, style=line.style_dotted)
    label lb  = ndog_labels ?
                 label.new(x2, hi,
                  "NDOG " + str.format("{0,date,MM/dd}", ts),
                  style=label.style_label_left,
                  color=color.new(color.blue, 88),
                  textcolor=ndog_border, size=size.tiny) :
                 label.new(x2, hi, "", color=color.new(color.white, 100), textcolor=color.new(color.white, 100))
    ndog_hi.push(hi)
    ndog_lo.push(lo)
    ndog_ts.push(ts)
    ndog_boxes.push(b)
    ndog_tops.push(t)
    ndog_bots.push(bot)
    ndog_mids.push(m)
    ndog_q1s.push(lq1)
    ndog_q3s.push(lq3)
    ndog_lbls.push(lb)

// ─── DETECT & REGISTER NEW NWOG ───────────────────────────────────────────────
if is_new_week and not na(weekly_close) and not na(open)
    float ghi = math.max(open, weekly_close)
    float glo = math.min(open, weekly_close)
    if ghi > glo
        f_add_nwog(ghi, glo, time)

// ─── DETECT & REGISTER NEW NDOG ───────────────────────────────────────────────
if is_new_day and not is_new_week and not na(daily_close) and not na(open)
    float ghi = math.max(open, daily_close)
    float glo = math.min(open, daily_close)
    if ghi > glo
        f_add_ndog(ghi, glo, time)

// ─── ROLLING CUTOFF: keep last 4 NWOGs and last 5 NDOGs ──────────────────────
while nwog_ts.size() > 4
    f_remove_nwog(0)

while ndog_ts.size() > 5
    f_remove_ndog(0)

// ─── EXTEND ALL DRAWINGS TO (current bar + offset) EVERY BAR ─────────────────
int new_x2 = bar_index + ext_offset

int nwog_sz = nwog_boxes.size()
if nwog_sz > 0
    for j = 0 to nwog_sz - 1
        box.set_right(nwog_boxes.get(j), new_x2)
        line.set_x2(nwog_tops.get(j), new_x2)
        line.set_x2(nwog_bots.get(j), new_x2)
        line.set_x2(nwog_mids.get(j), new_x2)
        line.set_x2(nwog_q1s.get(j), new_x2)
        line.set_x2(nwog_q3s.get(j), new_x2)
        label.set_x(nwog_lbls.get(j), new_x2)
        label.set_y(nwog_lbls.get(j), nwog_hi.get(j))

int ndog_sz = ndog_boxes.size()
if ndog_sz > 0
    for j = 0 to ndog_sz - 1
        box.set_right(ndog_boxes.get(j), new_x2)
        line.set_x2(ndog_tops.get(j), new_x2)
        line.set_x2(ndog_bots.get(j), new_x2)
        line.set_x2(ndog_mids.get(j), new_x2)
        line.set_x2(ndog_q1s.get(j), new_x2)
        line.set_x2(ndog_q3s.get(j), new_x2)
        label.set_x(ndog_lbls.get(j), new_x2)
        label.set_y(ndog_lbls.get(j), ndog_hi.get(j))



// ─── INFO TABLE ───────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 3,
     border_color=color.new(color.gray,60), border_width=1,
     frame_color=color.new(color.gray,60),  frame_width=1)

if barstate.islast
    table.cell(tbl, 0, 0, "Type",   bgcolor=color.new(color.gray,70), text_color=color.white, text_size=size.tiny)
    table.cell(tbl, 1, 0, "Active", bgcolor=color.new(color.gray,70), text_color=color.white, text_size=size.tiny)
    table.cell(tbl, 0, 1, "NWOG",   bgcolor=color.new(color.red,80),  text_color=color.new(color.red,10),  text_size=size.tiny)
    table.cell(tbl, 1, 1, str.tostring(nwog_sz), bgcolor=color.new(color.red,80), text_color=color.new(color.red,10), text_size=size.tiny)
    table.cell(tbl, 0, 2, "NDOG",   bgcolor=color.new(color.blue,80), text_color=color.new(color.blue,10), text_size=size.tiny)
    table.cell(tbl, 1, 2, str.tostring(ndog_sz), bgcolor=color.new(color.blue,80), text_color=color.new(color.blue,10), text_size=size.tiny)
````
