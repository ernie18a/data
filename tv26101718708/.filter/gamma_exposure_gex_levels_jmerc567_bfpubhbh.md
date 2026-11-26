# Gamma Exposure (GEX) Levels - JMerc567

- url: https://www.tradingview.com/script/BfpuBHBh-Gamma-Exposure-GEX-Levels-JMerc567/
- type: indicator
- pine_id: PUB;8e5659dd2b024b6890748783f1757566
- version: 1.0

## Description

Here's how to use it effectively:

Setting Up (Daily Pre-Market Routine)
Get your GEX data from one of these free/paid sources:

SpotGamma — best for SPX/SPY
Market Chameleon — free options data
SqueezeMetrics — DIX/GEX for SPY
Then open the indicator Settings and fill in:

Field	What to enter
Gamma Flip Strike	The price where dealers flip from positive to negative gamma
Call Gamma Wall	Strike with the most call open interest / highest positive gamma
Put Gamma Wall	Strike with the most put open interest / highest negative gamma
Levels L1–L8	Other high-OI strikes you want to watch
Reading the Dashboard
Regime (most important):

POSITIVE GEX (price above flip) → dealers are short gamma → they buy dips and sell rips → expect mean reversion, low volatility, price pinning near strikes
NEGATIVE GEX (price below flip) → dealers are long gamma → they buy drops and sell bounces acting as amplifiers → expect trending, higher volatility, larger moves
Environment label:

PINNING (low vol) — price tends to gravitate toward high-OI strikes, great for range strategies
TRENDING (high vol) — price can move fast and far, momentum strategies work better
Dist to Flip % — how far price is from the regime change level. Under 0.5% = watch closely.

Key Levels
Call Gamma Wall (green line) = strong resistance — dealers hedge by selling as price approaches
Put Gamma Wall (red line) = strong support — dealers hedge by buying as price drops here
GEX Flip (yellow dashed) = the most important level — crossing it signals a regime change
Alerts
Set these up via TradingView's Alert dialog (clock icon):

GEX Regime Change — flip cross, potential trend shift
Price Near Flip ±0.25% — watch for acceleration or reversal
Price Near Call/Put Wall — key S/R test incoming
High-Volume GEX Event — diamond marker on chart, potential unpin
Tips
Update levels daily pre-market — GEX resets on each expiration (especially 0DTE Fridays)
The GEX Proxy oscillator (in the dashboard) is volume-based — not real GEX, but useful as a directional bias confirmation
On opex weeks (monthly expiration), GEX effects are strongest

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jmercado5671

// © GammaExposure Indicator for TradingView
//@version=6
indicator("Gamma Exposure (GEX) Levels", shorttitle="GEX", overlay=true, max_lines_count=500, max_labels_count=200, max_boxes_count=100)

string G_FLIP    = "Gamma Flip Point"
string G_LEVELS  = "Key GEX Strike Levels"
string G_ZONES   = "GEX Zones (Positive / Negative)"
string G_WALLS   = "Gamma Walls"
string G_STYLE   = "Display Settings"
string G_PROXY   = "GEX Proxy (Volume-Based Estimate)"

flip_enabled    = input.bool(true,  "Show Gamma Flip Line",         group=G_FLIP)
flip_price      = input.float(0.0,  "Gamma Flip Strike Price",      group=G_FLIP, tooltip="Price level where dealer gamma transitions from positive to negative.")
flip_col        = input.color(color.new(color.yellow, 0), "Flip Line Color", group=G_FLIP)
flip_width      = input.int(2,      "Flip Line Width",              group=G_FLIP, minval=1, maxval=4)

lvl1_enabled = input.bool(true,   "Level 1 Enabled", group=G_LEVELS, inline="l1")
lvl1_price   = input.float(0.0,   "Price",           group=G_LEVELS, inline="l1")
lvl1_label   = input.string("L1", "Label",           group=G_LEVELS, inline="l1")
lvl1_col     = input.color(color.new(color.teal, 0), "Color",        group=G_LEVELS, inline="l1")

lvl2_enabled = input.bool(true,   "Level 2 Enabled", group=G_LEVELS, inline="l2")
lvl2_price   = input.float(0.0,   "Price",           group=G_LEVELS, inline="l2")
lvl2_label   = input.string("L2", "Label",           group=G_LEVELS, inline="l2")
lvl2_col     = input.color(color.new(color.teal, 0), "Color",        group=G_LEVELS, inline="l2")

lvl3_enabled = input.bool(true,   "Level 3 Enabled", group=G_LEVELS, inline="l3")
lvl3_price   = input.float(0.0,   "Price",           group=G_LEVELS, inline="l3")
lvl3_label   = input.string("L3", "Label",           group=G_LEVELS, inline="l3")
lvl3_col     = input.color(color.new(color.teal, 0), "Color",        group=G_LEVELS, inline="l3")

lvl4_enabled = input.bool(true,   "Level 4 Enabled", group=G_LEVELS, inline="l4")
lvl4_price   = input.float(0.0,   "Price",           group=G_LEVELS, inline="l4")
lvl4_label   = input.string("L4", "Label",           group=G_LEVELS, inline="l4")
lvl4_col     = input.color(color.new(color.teal, 0), "Color",        group=G_LEVELS, inline="l4")

lvl5_enabled = input.bool(false,  "Level 5 Enabled", group=G_LEVELS, inline="l5")
lvl5_price   = input.float(0.0,   "Price",           group=G_LEVELS, inline="l5")
lvl5_label   = input.string("L5", "Label",           group=G_LEVELS, inline="l5")
lvl5_col     = input.color(color.new(color.blue, 0), "Color",        group=G_LEVELS, inline="l5")

lvl6_enabled = input.bool(false,  "Level 6 Enabled", group=G_LEVELS, inline="l6")
lvl6_price   = input.float(0.0,   "Price",           group=G_LEVELS, inline="l6")
lvl6_label   = input.string("L6", "Label",           group=G_LEVELS, inline="l6")
lvl6_col     = input.color(color.new(color.blue, 0), "Color",        group=G_LEVELS, inline="l6")

lvl7_enabled = input.bool(false,  "Level 7 Enabled", group=G_LEVELS, inline="l7")
lvl7_price   = input.float(0.0,   "Price",           group=G_LEVELS, inline="l7")
lvl7_label   = input.string("L7", "Label",           group=G_LEVELS, inline="l7")
lvl7_col     = input.color(color.new(color.purple, 0), "Color",      group=G_LEVELS, inline="l7")

lvl8_enabled = input.bool(false,  "Level 8 Enabled", group=G_LEVELS, inline="l8")
lvl8_price   = input.float(0.0,   "Price",           group=G_LEVELS, inline="l8")
lvl8_label   = input.string("L8", "Label",           group=G_LEVELS, inline="l8")
lvl8_col     = input.color(color.new(color.purple, 0), "Color",      group=G_LEVELS, inline="l8")

wall_enabled     = input.bool(true,  "Show Gamma Walls",         group=G_WALLS)
call_wall_price  = input.float(0.0,  "Call Gamma Wall (Strike)", group=G_WALLS, tooltip="Strike with largest positive gamma — acts as resistance.")
put_wall_price   = input.float(0.0,  "Put Gamma Wall (Strike)",  group=G_WALLS, tooltip="Strike with largest negative gamma — acts as support.")
call_wall_col    = input.color(color.new(color.green, 0), "Call Wall Color", group=G_WALLS)
put_wall_col     = input.color(color.new(color.red,   0), "Put Wall Color",  group=G_WALLS)
wall_width       = input.int(2, "Wall Line Width", group=G_WALLS, minval=1, maxval=4)

zone_enabled   = input.bool(true,  "Show GEX Zones",             group=G_ZONES)
pos_zone_top   = input.float(0.0,  "Positive GEX Zone — Top",    group=G_ZONES)
pos_zone_bot   = input.float(0.0,  "Positive GEX Zone — Bottom", group=G_ZONES)
neg_zone_top   = input.float(0.0,  "Negative GEX Zone — Top",    group=G_ZONES)
neg_zone_bot   = input.float(0.0,  "Negative GEX Zone — Bottom", group=G_ZONES)
pos_zone_col   = input.color(color.new(color.green, 88), "Positive Zone Color", group=G_ZONES)
neg_zone_col   = input.color(color.new(color.red,   88), "Negative Zone Color",  group=G_ZONES)

proxy_enabled  = input.bool(true,  "Show GEX Proxy Oscillator",       group=G_PROXY)
proxy_len      = input.int(20,     "Lookback Length",                  group=G_PROXY, minval=5, maxval=100)
proxy_smooth   = input.int(5,      "Signal Smoothing",                 group=G_PROXY, minval=1, maxval=20)
proxy_vol_mult = input.float(1.5,  "High-Volume Threshold Multiplier", group=G_PROXY, minval=1.0, maxval=5.0, step=0.1)

show_labels    = input.bool(true,  "Show Price Labels on Lines",  group=G_STYLE)
show_dashboard = input.bool(true,  "Show GEX Dashboard (Table)",  group=G_STYLE)
dash_pos       = input.string("Top Right", "Dashboard Position",  group=G_STYLE, options=["Top Right","Top Left","Bottom Right","Bottom Left"])
label_size_inp = input.string("Small", "Label Size",              group=G_STYLE, options=["Tiny","Small","Normal","Large"])
line_extend    = input.bool(true,  "Extend Lines to Right",       group=G_STYLE)

// ── Helpers ──────────────────────────────────────────────────────────────────
f_label_size() =>
    switch label_size_inp
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_extend() => line_extend ? extend.right : extend.none

f_dash_pos() =>
    switch dash_pos
        "Top Right"    => position.top_right
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        => position.top_right

f_draw_level(price, lbl, col, lw) =>
    if barstate.islast and price != 0.0
        line.new(bar_index - 1, price, bar_index, price, color=col, width=lw, extend=f_extend(), style=line.style_solid)
        if show_labels
            label.new(bar_index, price, text=" " + lbl + " " + str.tostring(price, "#.##"), color=color.new(col, 85), textcolor=col, style=label.style_label_left, size=f_label_size())

f_draw_dashed(price, lbl, col, lw) =>
    if barstate.islast and price != 0.0
        line.new(bar_index - 1, price, bar_index, price, color=col, width=lw, extend=f_extend(), style=line.style_dashed)
        if show_labels
            label.new(bar_index, price, text=" " + lbl + " " + str.tostring(price, "#.##"), color=color.new(col, 85), textcolor=col, style=label.style_label_left, size=f_label_size())

// ── Gamma Flip Line ───────────────────────────────────────────────────────────
if flip_enabled
    f_draw_dashed(flip_price, "GEX Flip", flip_col, flip_width)

// ── Gamma Walls ───────────────────────────────────────────────────────────────
if wall_enabled
    f_draw_level(call_wall_price, "Call Wall", call_wall_col, wall_width)
    f_draw_level(put_wall_price,  "Put Wall",  put_wall_col,  wall_width)

// ── Key GEX Levels ────────────────────────────────────────────────────────────
if lvl1_enabled
    f_draw_level(lvl1_price, lvl1_label, lvl1_col, 1)
if lvl2_enabled
    f_draw_level(lvl2_price, lvl2_label, lvl2_col, 1)
if lvl3_enabled
    f_draw_level(lvl3_price, lvl3_label, lvl3_col, 1)
if lvl4_enabled
    f_draw_level(lvl4_price, lvl4_label, lvl4_col, 1)
if lvl5_enabled
    f_draw_level(lvl5_price, lvl5_label, lvl5_col, 1)
if lvl6_enabled
    f_draw_level(lvl6_price, lvl6_label, lvl6_col, 1)
if lvl7_enabled
    f_draw_level(lvl7_price, lvl7_label, lvl7_col, 1)
if lvl8_enabled
    f_draw_level(lvl8_price, lvl8_label, lvl8_col, 1)

// ── GEX Zones ─────────────────────────────────────────────────────────────────
var box pos_box = na
var box neg_box = na

if zone_enabled and barstate.islast
    box.delete(pos_box)
    box.delete(neg_box)
    if pos_zone_top != 0.0 and pos_zone_bot != 0.0
        pos_box := box.new(bar_index - 1, pos_zone_top, bar_index + 50, pos_zone_bot, border_color=color.new(color.green, 60), bgcolor=pos_zone_col, border_width=1, extend=extend.right)
    if neg_zone_top != 0.0 and neg_zone_bot != 0.0
        neg_box := box.new(bar_index - 1, neg_zone_top, bar_index + 50, neg_zone_bot, border_color=color.new(color.red, 60), bgcolor=neg_zone_col, border_width=1, extend=extend.right)

// ── GEX Regime ────────────────────────────────────────────────────────────────
gex_regime_pos = flip_price != 0.0 ? close > flip_price : bool(na)
regime_col     = gex_regime_pos ? color.new(color.green, 0) : color.new(color.red, 0)
regime_text    = gex_regime_pos ? "POSITIVE GEX" : "NEGATIVE GEX"

bgcolor(flip_price != 0.0 ? color.new(gex_regime_pos ? color.green : color.red, 96) : na, title="GEX Regime Background")

flip_dist_pct = flip_price != 0.0 ? math.abs(close - flip_price) / flip_price * 100 : na

// ── Volume-Based GEX Proxy ────────────────────────────────────────────────────
up_vol         = close >= open ? volume : 0.0
down_vol       = close <  open ? volume : 0.0
sum_up         = math.sum(up_vol,   proxy_len)
sum_down       = math.sum(down_vol, proxy_len)
total_v        = sum_up + sum_down
raw_proxy      = total_v != 0 ? (sum_up - sum_down) / total_v : 0.0
proxy_signal   = ta.ema(raw_proxy, proxy_smooth)
avg_vol        = ta.sma(volume, proxy_len)
high_vol_bar   = volume > avg_vol * proxy_vol_mult
proxy_momentum = proxy_signal - proxy_signal[3]

// ── Distance Calculations ─────────────────────────────────────────────────────
call_wall_dist = call_wall_price != 0.0 ? (call_wall_price - close) / close * 100 : na
put_wall_dist  = put_wall_price  != 0.0 ? (close - put_wall_price)  / close * 100 : na

nearest_above = math.max(
     lvl1_enabled and lvl1_price > close ? lvl1_price : 0,
     lvl2_enabled and lvl2_price > close ? lvl2_price : 0,
     lvl3_enabled and lvl3_price > close ? lvl3_price : 0,
     lvl4_enabled and lvl4_price > close ? lvl4_price : 0)

nearest_below = math.min(
     lvl1_enabled and lvl1_price < close and lvl1_price > 0 ? lvl1_price : 999999,
     lvl2_enabled and lvl2_price < close and lvl2_price > 0 ? lvl2_price : 999999,
     lvl3_enabled and lvl3_price < close and lvl3_price > 0 ? lvl3_price : 999999,
     lvl4_enabled and lvl4_price < close and lvl4_price > 0 ? lvl4_price : 999999)

// ── Dashboard ─────────────────────────────────────────────────────────────────
var table dash = na

if show_dashboard and barstate.islast
    table.delete(dash)
    dash := table.new(f_dash_pos(), 2, 12, bgcolor=color.new(color.black, 75), border_color=color.new(color.gray, 60), border_width=1, frame_color=color.new(color.gray, 40), frame_width=1)

    table.cell(dash, 0, 0, "GEX DASHBOARD", text_color=color.white, text_size=size.small, bgcolor=color.new(color.navy, 30), text_halign=text.align_center)
    table.cell(dash, 1, 0, syminfo.ticker + " · " + timeframe.period, text_color=color.silver, text_size=size.tiny, text_halign=text.align_center, bgcolor=color.new(color.navy, 30))

    table.cell(dash, 0, 1, "Regime", text_color=color.silver, text_size=size.tiny)
    table.cell(dash, 1, 1, flip_price != 0.0 ? regime_text : "Set Flip Price", text_color=flip_price != 0.0 ? regime_col : color.gray, text_size=size.tiny)

    table.cell(dash, 0, 2, "Dist to Flip", text_color=color.silver, text_size=size.tiny)
    table.cell(dash, 1, 2, not na(flip_dist_pct) ? str.tostring(flip_dist_pct, "#.##") + "%" : "—", text_color=color.white, text_size=size.tiny)

    table.cell(dash, 0, 3, "Call Wall", text_color=color.silver, text_size=size.tiny)
    table.cell(dash, 1, 3, call_wall_price != 0.0 ? str.tostring(call_wall_price, "#.##") + (not na(call_wall_dist) ? "  (" + str.tostring(call_wall_dist, "#.##") + "%)" : "") : "—", text_color=call_wall_price != 0.0 ? color.new(color.green, 0) : color.gray, text_size=size.tiny)

    table.cell(dash, 0, 4, "Put Wall", text_color=color.silver, text_size=size.tiny)
    table.cell(dash, 1, 4, put_wall_price != 0.0 ? str.tostring(put_wall_price, "#.##") + (not na(put_wall_dist) ? "  (" + str.tostring(put_wall_dist, "#.##") + "%)" : "") : "—", text_color=put_wall_price != 0.0 ? color.new(color.red, 0) : color.gray, text_size=size.tiny)

    table.cell(dash, 0, 5, "GEX Flip", text_color=color.silver, text_size=size.tiny)
    table.cell(dash, 1, 5, flip_price != 0.0 ? str.tostring(flip_price, "#.##") : "Not Set", text_color=flip_col, text_size=size.tiny)

    proxy_col_val = proxy_signal > 0 ? color.new(color.green, 0) : color.new(color.red, 0)
    table.cell(dash, 0, 6, "GEX Proxy", text_color=color.silver, text_size=size.tiny)
    table.cell(dash, 1, 6, str.tostring(proxy_signal, "#.###") + (proxy_signal > 0 ? " ▲" : " ▼"), text_color=proxy_col_val, text_size=size.tiny)

    mom_col = proxy_momentum > 0 ? color.new(color.green, 0) : color.new(color.red, 0)
    table.cell(dash, 0, 7, "Proxy Mom.", text_color=color.silver, text_size=size.tiny)
    table.cell(dash, 1, 7, str.tostring(proxy_momentum, "#.####") + (proxy_momentum > 0 ? " ↑" : " ↓"), text_color=mom_col, text_size=size.tiny)

    table.cell(dash, 0, 8, "High Vol Bar", text_color=color.silver, text_size=size.tiny)
    table.cell(dash, 1, 8, high_vol_bar ? "YES ⚡" : "No", text_color=high_vol_bar ? color.orange : color.gray, text_size=size.tiny)

    table.cell(dash, 0, 9, "Next Level ↑", text_color=color.silver, text_size=size.tiny)
    table.cell(dash, 1, 9, nearest_above > 0 ? str.tostring(nearest_above, "#.##") : "—", text_color=color.new(color.green, 0), text_size=size.tiny)

    table.cell(dash, 0, 10, "Next Level ↓", text_color=color.silver, text_size=size.tiny)
    table.cell(dash, 1, 10, nearest_below < 999999 ? str.tostring(nearest_below, "#.##") : "—", text_color=color.new(color.red, 0), text_size=size.tiny)

    env_text = gex_regime_pos ? "PINNING (low vol)" : "TRENDING (high vol)"
    env_col  = gex_regime_pos ? color.new(color.teal, 0) : color.orange
    table.cell(dash, 0, 11, "Environment", text_color=color.silver, text_size=size.tiny)
    table.cell(dash, 1, 11, flip_price != 0.0 ? env_text : "—", text_color=flip_price != 0.0 ? env_col : color.gray, text_size=size.tiny)

// ── Markers ───────────────────────────────────────────────────────────────────
plotshape(high_vol_bar, title="High Volume GEX Event", style=shape.diamond, location=location.belowbar, color=color.new(color.orange, 20), size=size.tiny)

regime_change = flip_price != 0.0 and ta.cross(close, flip_price)
plotshape(regime_change, title="GEX Regime Change", style=shape.labelup, location=location.belowbar, color=color.new(color.yellow, 0), textcolor=color.black, text="FLIP", size=size.small)

// ── Plots ─────────────────────────────────────────────────────────────────────
plot(proxy_enabled ? proxy_signal   : na, "GEX Proxy Signal",   color=color.new(color.aqua,   0), display=display.none)
plot(proxy_enabled ? proxy_momentum : na, "GEX Proxy Momentum", color=color.new(color.orange, 0), display=display.none)

// ── Alerts ────────────────────────────────────────────────────────────────────
alertcondition(regime_change, title="GEX Regime Change (Flip Cross)", message="{{ticker}} crossed the GEX Flip level at {{close}}. Regime change possible.")
alertcondition(flip_price != 0.0 and math.abs(close - flip_price) / flip_price * 100 < 0.25, title="Price Near GEX Flip (±0.25%)", message="{{ticker}} is within 0.25% of the GEX Flip. Watch for pinning or acceleration.")
alertcondition(call_wall_price != 0.0 and math.abs(close - call_wall_price) / call_wall_price * 100 < 0.25, title="Price Near Call Gamma Wall (±0.25%)", message="{{ticker}} is within 0.25% of the Call Gamma Wall.")
alertcondition(put_wall_price != 0.0 and math.abs(close - put_wall_price) / put_wall_price * 100 < 0.25, title="Price Near Put Gamma Wall (±0.25%)", message="{{ticker}} is within 0.25% of the Put Gamma Wall.")
alertcondition(high_vol_bar, title="High-Volume GEX Event", message="{{ticker}} high-volume bar detected — potential gamma unpin or acceleration event.")
````
