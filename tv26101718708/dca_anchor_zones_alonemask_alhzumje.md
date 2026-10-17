# DCA Anchor Zones [AloneMask]

- url: https://www.tradingview.com/script/aLhZUmJe-DCA-Anchor-Zones-AloneMask/
- type: indicator
- pine_id: PUB;8a75095c5bbb481691809d7d7cff5e73
- version: 1.0

## Description

This indicator will show you the exact buy and sell levels for your DCA Strategy. The indicator contains 2 anchor lines, from which the required percentage change for buy/sell is automatically calculated exactly according to your own strategy settings. When changing the anchor position, the percentage distance of the buy and sell lines dependent on this anchor is automatically recalculated. The anchors can be moved with the mouse or by entering a specific price and time directly in the settings. When the required buy/sell levels are reached, you simply move the anchor and thus create new buy/sell levels. The number of dependent lines, names and style depend on your own strategy settings. Then you just need to set price alerts.
[image]https://www.tradingview.com/x/KATRRIWz/[/image]

## Source Code

````pine
//@version=6
indicator("DCA Anchor Zones [AloneMask]", overlay=true)


// --- Style features ---
get_style(s) => 
    s == "Solid" ? line.style_solid : s == "Dashed" ? line.style_dashed : line.style_dotted

// =============================================================================
// ── SELL ZONES ────────────────────────────────────────────────
// =============================================================================
// Update features
update_d(ln, lb, s, t, p, c, w, st, anchorsell_price, anchorsell_time) =>
    float pr = anchorsell_price * (1 + p/100)
    line.set_xy1(ln, anchorsell_time, pr)
    line.set_xy2(ln, anchorsell_time + 86400000, pr)
    line.set_color(ln, s ? c : color.new(color.white, 100))
    line.set_width(ln, w)
    line.set_style(ln, get_style(st))
    label.set_x(lb, anchorsell_time)
    label.set_y(lb, pr)
    label.set_text(lb, s ? t : "")
    label.set_textcolor(lb, s ? c : color.new(color.white, 100))
    label.set_style(lb, label.style_none)

// --- Inputs ---
show_vertsell_line = input.bool(true, "Show vertical line (time)", group="SELL ANCHOR")
anchorsell_price = input.price(100000.0, "Anchor price", group="SELL ANCHOR")
anchorsell_time = input.time(timestamp("2026-06-09 00:00"), "Sell Anchor time (date)", group="SELL ANCHOR")
anchorsell_text  = input.string("SELL ANCHOR", "Text", group="SELL ANCHOR"), anchorsell_color = input.color(color.rgb(6, 6, 255), "Anchor line color", group="SELL ANCHOR")
anchorsell_width = input.int(4, "Line thickness", group="SELL ANCHOR")
anchorsell_style = input.string("Solid", "Line style", options=["Solid", "Dashed", "Dotted"], group="SELL ANCHOR")

// Definition of deviations (sdev1-sdev6)
sdev1 = input.bool(true, "1. sell deviation", group="SELL ANCHOR"), p1 = input.float(1.0, "% 1", group="SELL ANCHOR"), t1 = input.string("1", "Text 1", group="SELL ANCHOR"), c1 = input.color(color.red, "Color 1", group="SELL ANCHOR"), w1 = input.int(2, "Thickness 1", group="SELL ANCHOR"), st1 = input.string("Solid", "Style 1", options=["Solid", "Dashed", "Dotted"], group="SELL ANCHOR")
sdev2 = input.bool(true, "2. sell deviation", group="SELL ANCHOR"), p2 = input.float(2.0, "% 2", group="SELL ANCHOR"), t2 = input.string("2", "Text 2", group="SELL ANCHOR"), c2 = input.color(color.red, "Color 2", group="SELL ANCHOR"), w2 = input.int(2, "Thickness 2", group="SELL ANCHOR"), st2 = input.string("Solid", "Style 2", options=["Solid", "Dashed", "Dotted"], group="SELL ANCHOR")
sdev3 = input.bool(true, "3. sell deviation", group="SELL ANCHOR"), p3 = input.float(3.0, "% 3", group="SELL ANCHOR"), t3 = input.string("3", "Text 3", group="SELL ANCHOR"), c3 = input.color(color.red, "Color 3", group="SELL ANCHOR"), w3 = input.int(2, "Thickness 3", group="SELL ANCHOR"), st3 = input.string("Solid", "Style 3", options=["Solid", "Dashed", "Dotted"], group="SELL ANCHOR")
sdev4 = input.bool(true, "4. sell deviation", group="SELL ANCHOR"), p4 = input.float(4.0, "% 4", group="SELL ANCHOR"), t4 = input.string("4", "Text 4", group="SELL ANCHOR"), c4 = input.color(color.red, "Color 4", group="SELL ANCHOR"), w4 = input.int(2, "Thickness 4", group="SELL ANCHOR"), st4 = input.string("Solid", "Style 4", options=["Solid", "Dashed", "Dotted"], group="SELL ANCHOR")
sdev5 = input.bool(true, "5. sell deviation", group="SELL ANCHOR"), p5 = input.float(5.0, "% 5", group="SELL ANCHOR"), t5 = input.string("5", "Text 5", group="SELL ANCHOR"), c5 = input.color(color.red, "Color 5", group="SELL ANCHOR"), w5 = input.int(2, "Thickness 5", group="SELL ANCHOR"), st5 = input.string("Solid", "Style 5", options=["Solid", "Dashed", "Dotted"], group="SELL ANCHOR")
sdev6 = input.bool(true, "6. sell deviation", group="SELL ANCHOR"), p6 = input.float(6.0, "% 6", group="SELL ANCHOR"), t6 = input.string("6", "Text 6", group="SELL ANCHOR"), c6 = input.color(color.red, "Color 6", group="SELL ANCHOR"), w6 = input.int(2, "Thickness 6", group="SELL ANCHOR"), st6 = input.string("Solid", "Style 6", options=["Solid", "Dashed", "Dotted"], group="SELL ANCHOR")

// --- Initialization ---
var line l_sell_anc = line.new(anchorsell_time, anchorsell_price, anchorsell_time + 86400000, anchorsell_price, xloc=xloc.bar_time, extend=extend.right, color=anchorsell_color)
var label lb_sell_anc = label.new(anchorsell_time, anchorsell_price, style=label.style_none, xloc=xloc.bar_time, textcolor=anchorsell_color)
var line l_sell_vert = line.new(anchorsell_time, 0, anchorsell_time, 1, xloc=xloc.bar_time, extend=extend.both, color=color.new(anchorsell_color, 50), style=line.style_dashed)

var line l_sell1 = line.new(anchorsell_time, 0, anchorsell_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_sell1 = label.new(anchorsell_time, 0, style=label.style_none, xloc=xloc.bar_time)
var line l_sell2 = line.new(anchorsell_time, 0, anchorsell_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_sell2 = label.new(anchorsell_time, 0, style=label.style_none, xloc=xloc.bar_time)
var line l_sell3 = line.new(anchorsell_time, 0, anchorsell_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_sell3 = label.new(anchorsell_time, 0, style=label.style_none, xloc=xloc.bar_time)
var line l_sell4 = line.new(anchorsell_time, 0, anchorsell_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_sell4 = label.new(anchorsell_time, 0, style=label.style_none, xloc=xloc.bar_time)
var line l_sell5 = line.new(anchorsell_time, 0, anchorsell_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_sell5 = label.new(anchorsell_time, 0, style=label.style_none, xloc=xloc.bar_time)
var line l_sell6 = line.new(anchorsell_time, 0, anchorsell_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_sell6 = label.new(anchorsell_time, 0, style=label.style_none, xloc=xloc.bar_time)

// --- Update ---
if barstate.islast
    line.set_xy1(l_sell_anc, anchorsell_time, anchorsell_price)
    line.set_xy2(l_sell_anc, anchorsell_time + 86400000, anchorsell_price)
    line.set_color(l_sell_anc, anchorsell_color)
    line.set_width(l_sell_anc, anchorsell_width)
    line.set_style(l_sell_anc, get_style(anchorsell_style))
    
    label.set_x(lb_sell_anc, anchorsell_time)
    label.set_y(lb_sell_anc, anchorsell_price)
    label.set_text(lb_sell_anc, anchorsell_text)
    label.set_textcolor(lb_sell_anc, anchorsell_color)
    label.set_style(lb_sell_anc, label.style_arrowup)
    
    update_d(l_sell1, lb_sell1, sdev1, t1, p1, c1, w1, st1, anchorsell_price, anchorsell_time)
    update_d(l_sell2, lb_sell2, sdev2, t2, p2, c2, w2, st2, anchorsell_price, anchorsell_time)
    update_d(l_sell3, lb_sell3, sdev3, t3, p3, c3, w3, st3, anchorsell_price, anchorsell_time)
    update_d(l_sell4, lb_sell4, sdev4, t4, p4, c4, w4, st4, anchorsell_price, anchorsell_time)
    update_d(l_sell5, lb_sell5, sdev5, t5, p5, c5, w5, st5, anchorsell_price, anchorsell_time)
    update_d(l_sell6, lb_sell6, sdev6, t6, p6, c6, w6, st6, anchorsell_price, anchorsell_time)

if barstate.islast
    // Show vert line is active
    if show_vertsell_line
        line.set_x1(l_sell_vert, anchorsell_time)
        line.set_x2(l_sell_vert, anchorsell_time)
        line.set_color(l_sell_vert, color.new(anchorsell_color, 50))
    else
        // Show vert line is inactive
        line.set_x1(l_sell_vert, 0)
        line.set_x2(l_sell_vert, 0)
        line.set_color(l_sell_vert, color.new(color.white, 100))

// =============================================================================
// ── BUY ZONES ────────────────────────────────────────────────
// =============================================================================
// --- Inputs ---
show_vertbuy_line = input.bool(true, "Show vertical line (time)", group="BUY ANCHOR")
anchorbuy_price = input.price(96000.0, "Anchor price", group="BUY ANCHOR")
anchorbuy_time = input.time(timestamp("2026-06-09 00:00"), "Buy Anchor time (date)", group="BUY ANCHOR")
anchorbuy_text  = input.string("BUY ANCHOR", "Text", group="BUY ANCHOR"), anchorbuy_color = input.color(color.rgb(0, 226, 242), "Anchor line color", group="BUY ANCHOR")
anchorbuy_width = input.int(4, "Line thickness", group="BUY ANCHOR")
anchorbuy_style = input.string("Dotted", "Line style", options=["Solid", "Dashed", "Dotted"], group="BUY ANCHOR")

// Definition of deviations (bdev1-bdev6)
bdev1 = input.bool(true, "1. buy deviation", group="BUY ANCHOR"), qp1 = input.float(-1.0, "% 1", group="BUY ANCHOR"), qt1 = input.string("1", "Text 1", group="BUY ANCHOR"), qc1 = input.color(color.green, "Color 1", group="BUY ANCHOR"), qw1 = input.int(2, "Thickness 1", group="BUY ANCHOR"), qst1 = input.string("Solid", "Style 1", options=["Solid", "Dashed", "Dotted"], group="BUY ANCHOR")
bdev2 = input.bool(true, "2. buy deviation", group="BUY ANCHOR"), qp2 = input.float(-2.0, "% 2", group="BUY ANCHOR"), qt2 = input.string("2", "Text 2", group="BUY ANCHOR"), qc2 = input.color(color.green, "Color 2", group="BUY ANCHOR"), qw2 = input.int(2, "Thickness 2", group="BUY ANCHOR"), qst2 = input.string("Solid", "Style 2", options=["Solid", "Dashed", "Dotted"], group="BUY ANCHOR")
bdev3 = input.bool(true, "3. buy deviation", group="BUY ANCHOR"), qp3 = input.float(-3.0, "% 3", group="BUY ANCHOR"), qt3 = input.string("3", "Text 3", group="BUY ANCHOR"), qc3 = input.color(color.green, "Color 3", group="BUY ANCHOR"), qw3 = input.int(2, "Thickness 3", group="BUY ANCHOR"), qst3 = input.string("Solid", "Style 3", options=["Solid", "Dashed", "Dotted"], group="BUY ANCHOR")
bdev4 = input.bool(true, "4. buy deviation", group="BUY ANCHOR"), qp4 = input.float(-4.0, "% 4", group="BUY ANCHOR"), qt4 = input.string("4", "Text 4", group="BUY ANCHOR"), qc4 = input.color(color.green, "Color 4", group="BUY ANCHOR"), qw4 = input.int(2, "Thickness 4", group="BUY ANCHOR"), qst4 = input.string("Solid", "Style 4", options=["Solid", "Dashed", "Dotted"], group="BUY ANCHOR")
bdev5 = input.bool(true, "5. buy deviation", group="BUY ANCHOR"), qp5 = input.float(-5.0, "% 5", group="BUY ANCHOR"), qt5 = input.string("5", "Text 5", group="BUY ANCHOR"), qc5 = input.color(color.green, "Color 5", group="BUY ANCHOR"), qw5 = input.int(2, "Thickness 5", group="BUY ANCHOR"), qst5 = input.string("Solid", "Style 5", options=["Solid", "Dashed", "Dotted"], group="BUY ANCHOR")
bdev6 = input.bool(true, "6. buy deviation", group="BUY ANCHOR"), qp6 = input.float(-6.0, "% 6", group="BUY ANCHOR"), qt6 = input.string("6", "Text 6", group="BUY ANCHOR"), qc6 = input.color(color.green, "Color 6", group="BUY ANCHOR"), qw6 = input.int(2, "Thickness 6", group="BUY ANCHOR"), qst6 = input.string("Solid", "Style 6", options=["Solid", "Dashed", "Dotted"], group="BUY ANCHOR")

// --- Initialization ---
var line l_buy_anc = line.new(anchorbuy_time, anchorbuy_price, anchorbuy_time + 86400000, anchorbuy_price, xloc=xloc.bar_time, extend=extend.right, color=anchorbuy_color)
var label lb_buy_anc = label.new(anchorbuy_time, anchorbuy_price, style=label.style_none, xloc=xloc.bar_time, textcolor=anchorbuy_color)
var line l_buy_vert = line.new(anchorbuy_time, 0, anchorbuy_time, 1, xloc=xloc.bar_time, extend=extend.both, color=color.new(anchorbuy_color, 50), style=line.style_dashed)

var line l_buy1 = line.new(anchorbuy_time, 0, anchorbuy_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_buy1 = label.new(anchorbuy_time, 0, style=label.style_none, xloc=xloc.bar_time)
var line l_buy2 = line.new(anchorbuy_time, 0, anchorbuy_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_buy2 = label.new(anchorbuy_time, 0, style=label.style_none, xloc=xloc.bar_time)
var line l_buy3 = line.new(anchorbuy_time, 0, anchorbuy_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_buy3 = label.new(anchorbuy_time, 0, style=label.style_none, xloc=xloc.bar_time)
var line l_buy4 = line.new(anchorbuy_time, 0, anchorbuy_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_buy4 = label.new(anchorbuy_time, 0, style=label.style_none, xloc=xloc.bar_time)
var line l_buy5 = line.new(anchorbuy_time, 0, anchorbuy_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_buy5 = label.new(anchorbuy_time, 0, style=label.style_none, xloc=xloc.bar_time)
var line l_buy6 = line.new(anchorbuy_time, 0, anchorbuy_time + 86400000, 0, xloc=xloc.bar_time, extend=extend.both, color=color.new(color.white, 100))
var label lb_buy6 = label.new(anchorbuy_time, 0, style=label.style_none, xloc=xloc.bar_time)

// --- Update ---
if barstate.islast
    line.set_xy1(l_buy_anc, anchorbuy_time, anchorbuy_price)
    line.set_xy2(l_buy_anc, anchorbuy_time + 86400000, anchorbuy_price)
    line.set_color(l_buy_anc, anchorbuy_color)
    line.set_width(l_buy_anc, anchorbuy_width)
    line.set_style(l_buy_anc, get_style(anchorbuy_style))
    
    label.set_x(lb_buy_anc, anchorbuy_time)
    label.set_y(lb_buy_anc, anchorbuy_price)
    label.set_text(lb_buy_anc, anchorbuy_text)
    label.set_textcolor(lb_buy_anc, anchorbuy_color)
    label.set_style(lb_buy_anc, label.style_arrowup)
    
    update_d(l_buy1, lb_buy1, bdev1, qt1, qp1, qc1, qw1, qst1, anchorbuy_price, anchorbuy_time)
    update_d(l_buy2, lb_buy2, bdev2, qt2, qp2, qc2, qw2, qst2, anchorbuy_price, anchorbuy_time)
    update_d(l_buy3, lb_buy3, bdev3, qt3, qp3, qc3, qw3, qst3, anchorbuy_price, anchorbuy_time)
    update_d(l_buy4, lb_buy4, bdev4, qt4, qp4, qc4, qw4, qst4, anchorbuy_price, anchorbuy_time)
    update_d(l_buy5, lb_buy5, bdev5, qt5, qp5, qc5, qw5, qst5, anchorbuy_price, anchorbuy_time)
    update_d(l_buy6, lb_buy6, bdev6, qt6, qp6, qc6, qw6, qst6, anchorbuy_price, anchorbuy_time)
 
if barstate.islast
    // Show vert line is active
    if show_vertbuy_line
        line.set_x1(l_buy_vert, anchorbuy_time)
        line.set_x2(l_buy_vert, anchorbuy_time)
        line.set_color(l_buy_vert, color.new(anchorbuy_color, 50))
    else
        // Show vert line is inactive
        line.set_x1(l_buy_vert, 0)
        line.set_x2(l_buy_vert, 0)
        line.set_color(l_buy_vert, color.new(color.white, 100))
````
