# R:R Levels

- url: https://www.tradingview.com/script/MQbrXduO-r-r-levels/
- type: indicator
- pine_id: PUB;d9f24ce59f894eda8f35fabd681b665d
- version: 1.0

## Description

просто 3 горизонтальні лінії TP на графіку, нічого зайвого!Created a file, read a fileCreated a file, read a fileВсе максимально чисто — тільки лінії:

🔵 Вхід
🟠 SL — пунктир
1:1 — тонка лінія
🟢 1:2 — товста
🟠 1:3 — точкова

## Source Code

````pine
//@version=5
indicator("R:R Levels", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
grp1 = "Позиція"
direction   = input.string("Short", "Напрямок", options=["Long", "Short"], group=grp1)
entry_price = input.price(defval=84300.0, title="Ціна входу",    confirm=true, group=grp1)
stop_price  = input.price(defval=82620.0, title="Стоп-лос ціна", confirm=true, group=grp1)

// ─── РОЗРАХУНКИ ───────────────────────────────────────────────────────────────
sl_dist = math.abs(entry_price - stop_price)

tp1 = direction == "Short" ? entry_price - sl_dist * 1.0 : entry_price + sl_dist * 1.0
tp2 = direction == "Short" ? entry_price - sl_dist * 2.0 : entry_price + sl_dist * 2.0
tp3 = direction == "Short" ? entry_price - sl_dist * 3.0 : entry_price + sl_dist * 3.0

// ─── ЛІНІЇ ────────────────────────────────────────────────────────────────────
var line l_entry = na
var line l_stop  = na
var line l_tp1   = na
var line l_tp2   = na
var line l_tp3   = na
var label lb_entry = na
var label lb_stop  = na
var label lb_tp1   = na
var label lb_tp2   = na
var label lb_tp3   = na

if barstate.islast and entry_price > 0

    line.delete(l_entry)
    line.delete(l_stop)
    line.delete(l_tp1)
    line.delete(l_tp2)
    line.delete(l_tp3)
    label.delete(lb_entry)
    label.delete(lb_stop)
    label.delete(lb_tp1)
    label.delete(lb_tp2)
    label.delete(lb_tp3)

    x1 = bar_index - 30
    x2 = bar_index + 60

    l_entry := line.new(x1, entry_price, x2, entry_price,
         color=color.new(#2196F3, 0), width=2, style=line.style_solid)

    l_stop := line.new(x1, stop_price, x2, stop_price,
         color=color.new(#FF9800, 0), width=2, style=line.style_dashed)

    l_tp1 := line.new(x1, tp1, x2, tp1,
         color=color.new(#90CAF9, 0), width=1, style=line.style_dashed)

    l_tp2 := line.new(x1, tp2, x2, tp2,
         color=color.new(#4CAF50, 0), width=2, style=line.style_solid)

    l_tp3 := line.new(x1, tp3, x2, tp3,
         color=color.new(#FF9800, 0), width=2, style=line.style_dotted)

    lb_entry := label.new(x2, entry_price, "ВХІД  $" + str.tostring(math.round_to_mintick(entry_price)),
         style=label.style_label_left,
         color=color.new(#1565C0, 5), textcolor=color.white, size=size.small)

    lb_stop := label.new(x2, stop_price, "SL  $" + str.tostring(math.round_to_mintick(stop_price)),
         style=label.style_label_left,
         color=color.new(#E65100, 5), textcolor=color.white, size=size.small)

    lb_tp1 := label.new(x2, tp1, "1:1  $" + str.tostring(math.round_to_mintick(tp1)),
         style=label.style_label_left,
         color=color.new(#0D47A1, 5), textcolor=color.white, size=size.small)

    lb_tp2 := label.new(x2, tp2, "1:2  $" + str.tostring(math.round_to_mintick(tp2)),
         style=label.style_label_left,
         color=color.new(#1B5E20, 5), textcolor=color.white, size=size.small)

    lb_tp3 := label.new(x2, tp3, "1:3  $" + str.tostring(math.round_to_mintick(tp3)),
         style=label.style_label_left,
         color=color.new(#E65100, 5), textcolor=color.white, size=size.small)
````
