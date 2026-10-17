# Impulse Decay Coefficient [K]

- url: https://www.tradingview.com/script/HrIeFbOg-Impulse-Decay-Coefficient-K/
- type: indicator
- pine_id: PUB;584600ebe0324a21ad22757a9b365efc
- version: 1.0

## Description

Facilitates to see whether impulse is fully decayed by pullback or not

## Source Code

````pine

//@version=6
indicator("Impulse Decay Coefficient [K]", overlay=true)

// INPUTS — offset от текущего бара (сколько свечей назад)
a_offset = input.int(50, "A: Дно импульса (свечей назад)",  minval=1)
b_offset = input.int(30, "B: Пик импульса (свечей назад)",  minval=1)
c_offset = input.int(10, "C: Низ отката (свечей назад)",    minval=1)

// ВЫЧИСЛЯЕМ bar_index каждой точки
a_bar = bar_index - a_offset
b_bar = bar_index - b_offset
c_bar = bar_index - c_offset

// ЦЕНЫ — берём автоматически
a_price = low[a_offset]
b_price = high[b_offset]
c_price = low[c_offset]

// РАСЧЁТЫ
impulse_bars  = b_bar - a_bar
pullback_bars = c_bar - b_bar

safe_impulse_bars  = impulse_bars  > 0 ? impulse_bars  : 1
safe_pullback_bars = pullback_bars > 0 ? pullback_bars : 1

Vi = ((b_price - a_price) / a_price * 100) / safe_impulse_bars
Vr = ((b_price - c_price) / b_price * 100) / safe_pullback_bars

safe_Vr = math.abs(Vr) > 0 ? math.abs(Vr) : 0.0001
K = math.abs(Vi) / safe_Vr

// МЕТКИ
if barstate.islast
    label.new(a_bar, a_price, "A\nДНО", style=label.style_label_up, color=color.blue, textcolor=color.white, size=size.small)
    label.new(b_bar, b_price, "B\nПИК", style=label.style_label_down, color=color.orange, textcolor=color.white, size=size.small)
    label.new(c_bar, c_price, "C\nОТКАТ", style=label.style_label_up, color=color.red, textcolor=color.white, size=size.small)
    line.new(a_bar, a_price, b_bar, b_price, color=color.green, width=2)
    line.new(b_bar, b_price, c_bar, c_price, color=color.red, width=2, style=line.style_dashed)

// ТАБЛИЦА
var table t = table.new(position.top_right, 2, 6, bgcolor=color.new(color.black, 20), border_width=1, border_color=color.gray)

k_color = K >= 5.0 ? color.lime : K >= 2.0 ? color.yellow : color.red

if barstate.islast
    table.cell(t, 0, 0, "ПАРАМЕТР",       text_color=color.yellow, text_size=size.small)
    table.cell(t, 1, 0, "ЗНАЧЕНИЕ",       text_color=color.yellow, text_size=size.small)
    table.cell(t, 0, 1, "Баров импульса", text_color=color.white,  text_size=size.small)
    table.cell(t, 1, 1, str.tostring(impulse_bars), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 2, "Баров отката",   text_color=color.white,  text_size=size.small)
    table.cell(t, 1, 2, str.tostring(pullback_bars), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 3, "Vi (%/бар)",     text_color=color.white,  text_size=size.small)
    table.cell(t, 1, 3, str.tostring(math.round(Vi, 4)), text_color=color.lime, text_size=size.small)
    table.cell(t, 0, 4, "Vr (%/бар)",     text_color=color.white,  text_size=size.small)
    table.cell(t, 1, 4, str.tostring(math.round(Vr, 4)), text_color=color.red, text_size=size.small)
    table.cell(t, 0, 5, "K",              text_color=color.white,  text_size=size.normal)
    table.cell(t, 1, 5, str.tostring(math.round(K, 2)), text_color=k_color, text_size=size.normal)
````
