# HTF Candle Boxes with FVG

- url: https://www.tradingview.com/script/07yUudf8-HTF-Candle-Boxes-with-FVG/
- type: indicator
- pine_id: PUB;8f2c928983fd4db8a601560f43a94baa
- version: 1.0

## Description

HTF Candle Boxes with FVG — See the higher timeframe structure as live, expanding boxes on your low-timeframe chart, with Fair Value Gaps highlighted as they print.

© syouske. All rights reserved.


This indicator combines two views in one: a real-time rendering of the current higher timeframe (HTF) candle drawn as expanding wick / body / wick boxes, and a Fair Value Gap (FVG) overlay that draws every 3-bar imbalance forming inside that HTF candle's range. FVGs whose gap range overlaps the HTF opening zone (open ± ATR) are highlighted in a distinct color so price-action context near the open is immediately obvious.


Disclaimer

This indicator is a tool for analysis, not financial advice. Past signals do not guarantee future results. Always use proper risk management.


What Is a Fair Value Gap

An FVG is a 3-candle imbalance:

- Bullish FVG — the low of the current candle is above the high of the candle two bars back. The empty space between them is the gap.
- Bearish FVG — the high of the current candle is below the low of the candle two bars back.

A gap represents inefficiency that price often revisits. Until it is revisited, it marks the area where momentum was strongest.


HTF Candle Boxes

Each higher timeframe candle is rendered as three live zones that expand in real time:

- Upper wick zone — where price was rejected from the top
- Body zone (green/red) — the accepted range between open and close
- Lower wick zone — where price was rejected from the bottom
- Optional outer box wraps the full candle range
- Optional dashed midline through the body

The boxes grow bar by bar as the HTF candle develops, so you always see the current structure clearly on any lower timeframe chart.


Opening Zone

An ATR-sized band around the HTF open price (ATR length, multiplier, and source timeframe are all configurable). This zone is the reference for FVG highlighting. The box is hidden by default to keep the chart clean — turn on "Show opening zone box" to make it visible.


FVG Boxes

Any FVG that prints within the current HTF candle's wick range (htf_low to htf_high) is drawn as a box:

- The box covers the exact price range of the gap.
- It extends right as long as the gap stays open.
- It is removed when the gap is fully filled (mitigated) — price trades all the way back through to the far edge of the gap.
- Any still-open FVGs freeze at the next HTF candle open.

FVGs whose gap overlaps the opening zone are filled in cyan by default — these are the gaps printed near the HTF open price, the most context-rich imbalances. FVGs outside the opening zone use a subtle gray fill.


Customization

- HTF timeframe: 1H, 4H, or 1D
- HTF box colors (upper wick, body bull/bear, lower wick), borders, outer box, midline dash
- Opening zone: ATR length, multiplier, source timeframe (5m / 15m / 30m / 1H), visibility, fill and border colors
- FVG: minimum gap size (ATR multiple), bull/bear fill, "near opening range" fill (cyan by default), border color, visibility toggle


Recommended Use

- Chart timeframe: 1M, 3M, 5M, or 15M
- Works on any liquid market: forex, crypto, indices, futures
- Best used alongside higher timeframe bias and key S/R levels
- Pair with the standalone "HTF Candle Boxes" indicator for multi-HTF analysis


Alerts

- "FVG Near HTF Open" — any FVG (bull or bear) printed inside the opening zone
- "FVG Near HTF Open — Bullish" — bullish FVG only
- "FVG Near HTF Open — Bearish" — bearish FVG only

Set alerts to "Once per bar close" for best accuracy.

## Source Code

````pine
//@version=5
// © syouske
// HTF Candle Boxes with FVG
// Draws each HTF candle as three boxes (upper wick, body, lower wick) that
// expand in real-time over LTF bars, plus an opening zone (open ± ATR) and
// any Fair Value Gaps (3-bar imbalances) that print within the HTF candle's
// wick range.
//
// FVGs whose gap overlaps the opening zone are highlighted (cyan by default);
// FVGs outside the zone use the subtle bull/bear fill. Each FVG box extends
// right until the gap is fully filled (mitigated) or the next HTF candle opens.

indicator("HTF Candle Boxes with FVG", overlay = true, max_boxes_count = 500, max_lines_count = 500, max_labels_count = 500)

// ─── INPUTS: HTF Candle Boxes ────────────────────────────────────────────────
g_htf              = "HTF Candle Boxes"
htf_choice         = input.string("4H", "HTF timeframe", options = ["1H", "4H", "1D"], group = g_htf)
htf_tf             = htf_choice == "1D" ? "D" : htf_choice == "1H" ? "60" : "240"
show_htf_boxes     = input.bool(true,  "Show HTF Candle Boxes",       group = g_htf)
upper_wick_color   = input.color(color.new(color.gray,  90), "Upper wick fill",   group = g_htf)
body_bull_color    = input.color(color.new(color.green, 70), "Bullish body fill", group = g_htf)
body_bear_color    = input.color(color.new(color.red,   70), "Bearish body fill", group = g_htf)
lower_wick_color   = input.color(color.new(color.gray,  90), "Lower wick fill",   group = g_htf)
show_borders       = input.bool(true,  "Show borders",                group = g_htf)
border_color_in    = input.color(color.new(color.gray,  90), "Border color",      group = g_htf)
show_dash_line     = input.bool(true,  "Show dash line",              group = g_htf)
dash_line_color    = input.color(color.new(color.gray, 20), "Dash line color",    group = g_htf)
show_outer_box     = input.bool(true,  "Wrap HTF candle in outer box",group = g_htf)
outer_border_col   = input.color(color.new(color.gray,  90), "Outer box border",  group = g_htf)

// ─── INPUTS: Opening Zone ────────────────────────────────────────────────────
g_zone             = "Opening Zone"
show_zone          = input.bool(false, "Show opening zone box",       group = g_zone)
zone_atr_len       = input.int(14,    "Zone ATR length",  minval = 1, maxval = 200, group = g_zone)
zone_atr_mult      = input.float(0.3, "Zone ATR multiplier", minval = 0.1, maxval = 2.0, step = 0.1, group = g_zone)
zone_atr_tf        = input.string("15m", "Zone ATR timeframe", options = ["5m", "15m", "30m", "1H"], group = g_zone)
zone_fill_color    = input.color(color.new(#00bcd4,   88), "Zone fill color",   group = g_zone)
zone_border_color  = input.color(color.new(#00bcd4,   50), "Zone border color", group = g_zone)

// ─── INPUTS: FVG Conviction ──────────────────────────────────────────────────
g_fvg              = "FVG Conviction"
show_fvg           = input.bool(true,  "Show FVG boxes",                group = g_fvg, tooltip = "Draws every FVG whose gap range sits within the current HTF candle's wick range (htf_low → htf_high). The box extends right until the gap is fully filled or the next HTF candle opens.")
fvg_min_mult       = input.float(0.0,  "Min FVG size (ATR mult)",       minval = 0.0, maxval = 5.0, step = 0.1, group = g_fvg, tooltip = "Ignore FVGs smaller than this many zone-ATRs. 0 = accept any gap.")
fvg_bull_col       = input.color(color.new(color.gray, 85), "Bullish FVG fill", group = g_fvg)
fvg_bear_col       = input.color(color.new(color.gray, 85), "Bearish FVG fill", group = g_fvg)
fvg_near_col       = input.color(color.new(#00bcd4, 75), "FVG near opening range fill", group = g_fvg, tooltip = "Color used when the FVG gap overlaps the opening zone. Otherwise the bull/bear fill color is used.")
fvg_border_col     = input.color(color.new(color.gray, 100), "FVG border color", group = g_fvg)

// ─── HTF CANDLE TRACKING ─────────────────────────────────────────────────────
htf_open_time = time(htf_tf)
new_htf       = not na(htf_open_time) and htf_open_time != nz(htf_open_time[1], htf_open_time)

var float htf_o = na
var float htf_h = na
var float htf_l = na
var float htf_c = na

if new_htf
    htf_o := open
    htf_h := high
    htf_l := low
    htf_c := close
else
    htf_h := math.max(nz(htf_h, high), high)
    htf_l := math.min(nz(htf_l, low),  low)
    htf_c := close

// ─── ATR & ZONE ──────────────────────────────────────────────────────────────
_atr_tf = zone_atr_tf == "15m" ? "15" : zone_atr_tf == "30m" ? "30" : zone_atr_tf == "1H" ? "60" : "5"
atr_val = request.security(syminfo.tickerid, _atr_tf, ta.atr(zone_atr_len))

var float htf_zone_top = na
var float htf_zone_bot = na
var float htf_atr_snap = na

if new_htf
    htf_atr_snap  := atr_val
    htf_zone_top  := open + atr_val * zone_atr_mult
    htf_zone_bot  := open - atr_val * zone_atr_mult

// ─── HTF CANDLE BOXES ────────────────────────────────────────────────────────
var int  start_bar  = bar_index
var box  upper_box  = na
var box  body_box   = na
var box  lower_box  = na
var box  outer_box  = na
var line dash_ln    = na
var box  zone_box   = na

if new_htf
    start_bar := bar_index

body_top   = math.max(htf_o, htf_c)
body_bot   = math.min(htf_o, htf_c)
body_mid_y = (body_top + body_bot) / 2
body_color = htf_c >= htf_o ? body_bull_color : body_bear_color
brd        = show_borders ? border_color_in : color.new(color.gray, 100)
outer_brd  = show_outer_box ? outer_border_col : color.new(color.gray, 100)

if show_htf_boxes and new_htf
    upper_box := box.new(start_bar, htf_h,    bar_index, body_top, bgcolor = upper_wick_color, border_color = brd)
    body_box  := box.new(start_bar, body_top, bar_index, body_bot, bgcolor = body_color,       border_color = brd)
    lower_box := box.new(start_bar, body_bot, bar_index, htf_l,    bgcolor = lower_wick_color, border_color = brd)
    outer_box := box.new(start_bar, htf_h,    bar_index, htf_l,    bgcolor = color.new(color.white, 100), border_color = outer_brd)
    if show_dash_line
        dash_ln := line.new(start_bar, body_mid_y, bar_index, body_mid_y,
             color = dash_line_color, style = line.style_dotted, width = 1)
    if show_zone
        zone_box := box.new(start_bar, htf_zone_top, bar_index, htf_zone_bot,
             bgcolor = zone_fill_color, border_color = zone_border_color, border_width = 1)

if show_htf_boxes and not new_htf
    if not na(upper_box)
        box.set_right(upper_box,  bar_index)
        box.set_top(upper_box,    htf_h)
        box.set_bottom(upper_box, body_top)
    if not na(body_box)
        box.set_right(body_box,   bar_index)
        box.set_top(body_box,     body_top)
        box.set_bottom(body_box,  body_bot)
        box.set_bgcolor(body_box, body_color)
    if not na(lower_box)
        box.set_right(lower_box,  bar_index)
        box.set_top(lower_box,    body_bot)
        box.set_bottom(lower_box, htf_l)
    if not na(outer_box)
        box.set_right(outer_box,  bar_index)
        box.set_top(outer_box,    htf_h)
        box.set_bottom(outer_box, htf_l)
        box.set_border_color(outer_box, outer_brd)
    if show_dash_line and not na(dash_ln)
        line.set_x2(dash_ln,  bar_index)
        line.set_y1(dash_ln,  body_mid_y)
        line.set_y2(dash_ln,  body_mid_y)
    if show_zone and not na(zone_box)
        box.set_right(zone_box, bar_index)

// ─── FVG CONVICTION ──────────────────────────────────────────────────────────
// A Fair Value Gap is a 3-bar imbalance, confirmed once the third bar closes:
//   Bullish FVG: low > high[2]   (gap between high[2] and current low)
//   Bearish FVG: high < low[2]   (gap between current high and low[2])
// Conviction = any FVG whose gap range sits within the current HTF candle's
// wick range (htf_low → htf_high).
var array<box>   fvg_bx   = array.new<box>()
var array<float> fvg_t    = array.new<float>()
var array<float> fvg_b    = array.new<float>()
var array<bool>  fvg_bull = array.new<bool>()

if new_htf
    // Freeze any still-open FVG boxes at the new HTF open, then stop tracking them.
    if array.size(fvg_bx) > 0
        for i = 0 to array.size(fvg_bx) - 1
            box.set_right(array.get(fvg_bx, i), bar_index)
        array.clear(fvg_bx)
        array.clear(fvg_t)
        array.clear(fvg_b)
        array.clear(fvg_bull)

fvg_atr     = nz(htf_atr_snap, atr_val)
min_gap     = fvg_atr * fvg_min_mult
new_bull_fvg = barstate.isconfirmed and low  > high[2] and (low  - high[2]) >= min_gap
new_bear_fvg = barstate.isconfirmed and high < low[2]  and (low[2] - high)  >= min_gap
new_fvg      = new_bull_fvg or new_bear_fvg

// Gap edges (top >= bottom). Valid only when new_fvg is true.
float ft = new_bull_fvg ? low     : low[2]
float fb = new_bull_fvg ? high[2] : high

// Qualify any FVG whose gap range sits within the HTF candle's wick range
// (from htf_low up to htf_high, spanning both wicks and the body).
fvg_in_range  = new_fvg and not na(htf_h) and not na(htf_l) and ft <= htf_h and fb >= htf_l
fvg_near_zone = fvg_in_range and not na(htf_zone_top) and ft >= htf_zone_bot and fb <= htf_zone_top

if show_fvg and fvg_in_range
    fill_col = fvg_near_zone ? fvg_near_col : (new_bull_fvg ? fvg_bull_col : fvg_bear_col)
    bx = box.new(bar_index - 1, ft, bar_index, fb,
         bgcolor = fill_col, border_color = fvg_border_col)
    array.push(fvg_bx,   bx)
    array.push(fvg_t,    ft)
    array.push(fvg_b,    fb)
    array.push(fvg_bull, new_bull_fvg)

// Extend active FVG boxes; delete once the gap is fully filled (mitigated).
if array.size(fvg_bx) > 0
    i = array.size(fvg_bx) - 1
    while i >= 0
        b     = array.get(fvg_bx,   i)
        ftop  = array.get(fvg_t,    i)
        fbot  = array.get(fvg_b,    i)
        isb   = array.get(fvg_bull, i)
        filled = isb ? (low <= fbot) : (high >= ftop)
        if filled
            box.delete(b)
            array.remove(fvg_bx,   i)
            array.remove(fvg_t,    i)
            array.remove(fvg_b,    i)
            array.remove(fvg_bull, i)
        else
            box.set_right(b, bar_index)
        i := i - 1

// ─── ALERTS ──────────────────────────────────────────────────────────────────
alertcondition(fvg_near_zone,                  "FVG Near HTF Open",            "HTF Candle Boxes with FVG: FVG printed near the HTF open")
alertcondition(fvg_near_zone and new_bull_fvg, "FVG Near HTF Open — Bullish",  "HTF Candle Boxes with FVG: Bullish FVG printed near the HTF open")
alertcondition(fvg_near_zone and new_bear_fvg, "FVG Near HTF Open — Bearish",  "HTF Candle Boxes with FVG: Bearish FVG printed near the HTF open")
````
