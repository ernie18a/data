<!-- tradingview-pine-id: PUB;983278eedd85479c9859656282b32b93 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# HTF Candle Box

Source: https://www.tradingview.com/script/vrl7hIMg-HTF-Candle-Box/

## Description

HTF Candle Box

Wraps every higher-timeframe (HTF) period into a single box drawn directly on your current chart - a way to see the weekly (or monthly, or any coarser) range and direction without leaving your intraday or daily view.

What it draws

Each box spans one HTF period:
- Top / bottom track that period's running high and low, growing live bar by bar as the period develops.
- Fill color reflects direction, like a candle: bullish (close at/above the period's open) or bearish (close below it) - using your two chosen colors. The still-forming box updates its color live too, so it can flip as price crosses back over the period's open, settling once the period actually closes.
- Border is optional - off by default, toggle it on and set its own color, style (solid/dashed/dotted), and width.

Settings

- Higher Timeframe - any timeframe coarser than your chart's own (defaults to Weekly). The indicator automatically skips itself if your chart is already at or coarser than the chosen HTF, since there'd be nothing meaningful to group.
- Bull / Bear Color - one row, two swatches. Each color's own opacity slider (in the picker itself) controls fill strength - no separate transparency setting needed.
- Show Border / Border Color / Border Style / Border Width - fully optional outline layer.

Use it for

Keeping higher-timeframe structure (this week's range so far, last week's completed range, etc.) visible while trading a lower timeframe, without switching charts or adding a second pane.

---

## Source Code

````pine
//@version=6
indicator("HTF Candle Box", overlay=true, max_boxes_count=500)

// ─── INPUTS ────────────────────────────────────────────────────────────────
string htf_res   = input.timeframe("W", "Higher Timeframe", group="HTF Candle Box")
// input.color()'s own picker has a built-in opacity slider (next to the hex
// value) — the color itself already carries fill strength, so no separate
// transparency/opacity input is needed alongside it. Default is 75%
// transparency (25% opacity) on both, per the user's requested default.
color  bull_color = input.color(color.new(color.white, 75), "Bull / Bear Color", inline="dir_color", group="HTF Candle Box")
color  bear_color = input.color(color.new(#2962FF, 75), "", inline="dir_color", group="HTF Candle Box")
bool   show_border  = input.bool(false, "Show Border", group="HTF Candle Box")
color  border_color = input.color(color.white, "Border Color", group="HTF Candle Box")
string border_style = input.string("Solid", "Border Style", options=["Solid", "Dashed", "Dotted"], group="HTF Candle Box")
int    border_width = input.int(2, "Border Width", minval=1, maxval=10, group="HTF Candle Box")

// ─── HELPER: resolve style string ────────────────────────────────────────────
f_style(s) =>
    s == "Solid" ? line.style_solid : s == "Dotted" ? line.style_dotted : line.style_dashed

// Skip entirely once the chart's own timeframe is already >= the target HTF —
// e.g. a "weekly box" on a weekly (or coarser) chart would just be the bar
// itself, so there's nothing meaningful to group.
bool valid_tf = timeframe.in_seconds() < timeframe.in_seconds(htf_res)

// ─── STATE ────────────────────────────────────────────────────────────────────
var box   htf_box  = na
var float htf_high = na
var float htf_low  = na
var float htf_open = na

// time(htf_res) returns the open time of the HTF bar containing the current
// chart bar; it changes exactly once per new HTF period, giving a clean
// per-bar boundary check with no request.security() needed.
bool new_period = ta.change(time(htf_res)) != 0

if valid_tf
    if barstate.isfirst or new_period
        // Start of a new HTF period: freeze the previous box in place (simply
        // stop mutating it) and open a fresh one-bar-wide box for this period.
        htf_high := high
        htf_low  := low
        htf_open := open
        // Direction is live, not just at period close: it's a comparison of
        // the still-forming period's own open against the running close, same
        // "grows/updates live" behavior already used for high/low — so a box
        // can flip white<->blue intraperiod as price crosses back over the
        // period's open, settling on whichever side it's on once the period
        // actually closes.
        color  cur_color = close >= htf_open ? bull_color : bear_color
        htf_box  := box.new(bar_index, htf_high, bar_index, htf_low,
             border_color=show_border ? border_color : na, border_width=border_width, border_style=f_style(border_style),
             bgcolor=cur_color)
    else
        // Still inside the current HTF period: widen the box rightward and
        // let its top/bottom track the period's running high/low so far.
        htf_high := math.max(htf_high, high)
        htf_low  := math.min(htf_low, low)
        color cur_color = close >= htf_open ? bull_color : bear_color
        box.set_top(htf_box, htf_high)
        box.set_bottom(htf_box, htf_low)
        box.set_right(htf_box, bar_index)
        box.set_bgcolor(htf_box, cur_color)
````
