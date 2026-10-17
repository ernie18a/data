# Last Kiss - Naked Forex

- url: https://www.tradingview.com/script/IdMmVrtZ/
- type: indicator
- pine_id: PUB;b37fc4c0ab5f41d4abb61d0c8d86807b
- version: 1.0

## Description

Marca maxims i minins de un rang lateral , marca el rebot i el T.P. i S.L.

## Source Code

````pine
//@version=5
indicator("Last Kiss - Naked Forex", overlay=true)

// ══════════════════════════════════════════
//  INPUTS — Definició de la Caixa
// ══════════════════════════════════════════
box_top    = input.price(0.0, title="🔲 Caixa — Part Superior (Resistència)", confirm=true)
box_bottom = input.price(0.0, title="🔲 Caixa — Part Inferior (Suport)",      confirm=true)

// ══════════════════════════════════════════
//  CÀLCULS
// ══════════════════════════════════════════
box_height = box_top - box_bottom
midpoint   = box_bottom + box_height / 2

// TP projeccions
tp1_bull = box_top    + box_height * 1.0
tp2_bull = box_top    + box_height * 1.618
tp1_bear = box_bottom - box_height * 1.0
tp2_bear = box_bottom - box_height * 1.618

// ══════════════════════════════════════════
//  DIBUIX DE LA CAIXA (box.new = marc complet)
// ══════════════════════════════════════════
var box  b_main = na
var line l_mid  = na

if barstate.islast
    box.delete(b_main)
    line.delete(l_mid)

    b_main := box.new(
         left         = bar_index - 50,
         top          = box_top,
         right        = bar_index + 50,
         bottom       = box_bottom,
         border_color = color.new(color.white, 0),
         border_width = 2,
         bgcolor      = color.new(color.blue, 85))

    l_mid := line.new(
         bar_index - 50, midpoint,
         bar_index + 50, midpoint,
         color = color.new(color.red, 30),
         width = 1,
         style = line.style_dashed)

// ══════════════════════════════════════════
//  NIVELLS TP i STOP
// ══════════════════════════════════════════
hline(tp2_bull, "TP2 ↑ (1.618R)",     color=color.new(color.green,  0),  linestyle=hline.style_dashed, linewidth=1)
hline(tp1_bull, "TP1 ↑ (1R)",         color=color.new(color.green,  40), linestyle=hline.style_dashed, linewidth=1)
hline(tp1_bear, "TP1 ↓ (1R)",         color=color.new(color.orange, 40), linestyle=hline.style_dashed, linewidth=1)
hline(tp2_bear, "TP2 ↓ (1.618R)",     color=color.new(color.orange, 0),  linestyle=hline.style_dashed, linewidth=1)

// ══════════════════════════════════════════
//  ETIQUETES
// ══════════════════════════════════════════
if barstate.islast
    label.new(bar_index + 3, box_top,    "RESISTÈNCIA",      style=label.style_label_left, color=color.white,  textcolor=color.black, size=size.small)
    label.new(bar_index + 3, box_bottom, "SUPORT",           style=label.style_label_left, color=color.white,  textcolor=color.black, size=size.small)
    label.new(bar_index + 3, midpoint,   "STOP EMERGÈNCIA",  style=label.style_label_left, color=color.red,    textcolor=color.white, size=size.small)
    label.new(bar_index + 3, tp1_bull,   "TP1 ↑ (1R)",       style=label.style_label_left, color=color.green,  textcolor=color.white, size=size.small)
    label.new(bar_index + 3, tp2_bull,   "TP2 ↑ (1.618R)",   style=label.style_label_left, color=color.lime,   textcolor=color.black, size=size.small)
    label.new(bar_index + 3, tp1_bear,   "TP1 ↓ (1R)",       style=label.style_label_left, color=color.orange, textcolor=color.white, size=size.small)
    label.new(bar_index + 3, tp2_bear,   "TP2 ↓ (1.618R)",   style=label.style_label_left, color=color.red,    textcolor=color.white, size=size.small)

// ══════════════════════════════════════════
//  DETECCIÓ LAST KISS
// ══════════════════════════════════════════
touched_top_from_above    = high[1] > box_top    and close <= box_top    and close >= box_bottom
touched_bottom_from_below = low[1]  < box_bottom and close >= box_bottom and close <= box_top

plotshape(touched_top_from_above,    title="Last Kiss Bajista 💋", style=shape.labeldown, location=location.abovebar, color=color.red,   text="💋 LK", textcolor=color.white, size=size.normal)
plotshape(touched_bottom_from_below, title="Last Kiss Alcista 💋", style=shape.labelup,   location=location.belowbar, color=color.green, text="💋 LK", textcolor=color.white, size=size.normal)

// ══════════════════════════════════════════
//  TAULA RESUM
// ══════════════════════════════════════════
var table info = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 20), border_color=color.gray, border_width=1)

if barstate.islast
    table.cell(info, 0, 0, "LAST KISS",       text_color=color.white, bgcolor=color.new(color.blue, 20), text_size=size.normal)
    table.cell(info, 1, 0, "Nivells",         text_color=color.white, bgcolor=color.new(color.blue, 20), text_size=size.normal)
    table.cell(info, 0, 1, "Resistència",     text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, str.tostring(box_top,    "#.#####"), text_color=color.white,  text_size=size.small)
    table.cell(info, 0, 2, "Suport",          text_color=color.white, text_size=size.small)
    table.cell(info, 1, 2, str.tostring(box_bottom, "#.#####"), text_color=color.white,  text_size=size.small)
    table.cell(info, 0, 3, "Stop Emergència", text_color=color.red,   text_size=size.small)
    table.cell(info, 1, 3, str.tostring(midpoint,   "#.#####"), text_color=color.red,    text_size=size.small)
    table.cell(info, 0, 4, "TP1 (1R)",        text_color=color.green, text_size=size.small)
    table.cell(info, 1, 4, str.tostring(tp1_bull, "#.#####") + " / " + str.tostring(tp1_bear, "#.#####"), text_color=color.green, text_size=size.small)
    table.cell(info, 0, 5, "TP2 (1.618R)",    text_color=color.lime,  text_size=size.small)
    table.cell(info, 1, 5, str.tostring(tp2_bull, "#.#####") + " / " + str.tostring(tp2_bear, "#.#####"), text_color=color.lime,  text_size=size.small)
````
