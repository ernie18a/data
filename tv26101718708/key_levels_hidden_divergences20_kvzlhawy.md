# Key Levels & Hidden Divergences2.0

- url: https://www.tradingview.com/script/KvZLhawy-Key-Levels-Hidden-Divergences2-0/
- type: indicator
- pine_id: PUB;c1ffb24c7ac243abb27b32d175c73cca
- version: 1.0

## Description

this marks out key levelks ajnd determins fif porice fgoes up and down anf a

## Source Code

````pine
////@version=6
indicator("Key Levels & Hidden Divergences", overlay = true, max_lines_count = 500)

// --- Inputs ---
grp_levels = "Key Levels"
pivotLength = input.int(15, "Pivot Length", group = grp_levels)
levelColorBull = input.color(color.new(#089981, 50), "Support Color", group = grp_levels)
levelColorBear = input.color(color.new(#f23645, 50), "Resistance Color", group = grp_levels)

grp_divs = "Hidden Divergences"
oscLength = input.int(14, "Oscillator Length (RSI)", group = grp_divs)
lookback = input.int(5, "Divergence Pivot Lookback", group = grp_divs)

grp_candle = "Current Candle Projection"
candleOffset = input.int(5, "Offset from Current Bar", group = grp_candle)

// --- Key Levels ---
var line[] supportLines = array.new_line()
var line[] resistanceLines = array.new_line()

ph = ta.pivothigh(high, pivotLength, pivotLength)
pl = ta.pivotlow(low, pivotLength, pivotLength)

if not na(ph)
    l = line.new(bar_index[pivotLength], ph, bar_index, ph, color = levelColorBear, style = line.style_dashed)
    array.push(resistanceLines, l)
    if array.size(resistanceLines) > 10
        line.delete(array.shift(resistanceLines))

if not na(pl)
    l = line.new(bar_index[pivotLength], pl, bar_index, pl, color = levelColorBull, style = line.style_dashed)
    array.push(supportLines, l)
    if array.size(supportLines) > 10
        line.delete(array.shift(supportLines))

// --- Hidden Divergences ---
osc = ta.rsi(close, oscLength)

pl_div = ta.pivotlow(low, lookback, lookback)
ph_div = ta.pivothigh(high, lookback, lookback)

var float last_pl_price = na
var float last_pl_osc = na
var float last_ph_price = na
var float last_ph_osc = na

if not na(pl_div)
    current_pl_price = pl_div
    current_pl_osc = osc[lookback]
    
    // Hidden Bullish: Higher Low in price, Lower Low in oscillator
    if not na(last_pl_price)
        if current_pl_price > last_pl_price and current_pl_osc < last_pl_osc
            label.new(bar_index[lookback], low[lookback], "HD", color = color.new(#089981, 0), style = label.style_label_up, textcolor = color.white, size = size.tiny)
    
    last_pl_price := current_pl_price
    last_pl_osc := current_pl_osc

if not na(ph_div)
    current_ph_price = ph_div
    current_ph_osc = osc[lookback]
    
    // Hidden Bearish: Lower High in price, Higher High in oscillator
    if not na(last_ph_price)
        if current_ph_price < last_ph_price and current_ph_osc > last_ph_osc
            label.new(bar_index[lookback], high[lookback], "HD", color = color.new(#f23645, 0), style = label.style_label_down, textcolor = color.white, size = size.tiny)
            
    last_ph_price := current_ph_price
    last_ph_osc := current_ph_osc

// --- Current Candle Projection ---
var box currentBody = box.new(na, na, na, na, border_color = na)
var line currentWick = line.new(na, na, na, na)

if barstate.islast
    c_color = close >= open ? color.new(#089981, 0) : color.new(#f23645, 0)
    
    left_x = bar_index + candleOffset
    right_x = bar_index + candleOffset + 1
    
    box.set_lefttop(currentBody, left_x, math.max(open, close))
    box.set_rightbottom(currentBody, right_x, math.min(open, close))
    box.set_bgcolor(currentBody, c_color)
    
    // Wick
    center_x = left_x // We use left_x for the wick to align it roughly with the box center or left side, actually boxes are drawn between indices.
    // To center the wick, we can just draw it at left_x, and the box from left_x to right_x.
    // However, Pine Script coordinates are integers for bar_index.
    line.set_xy1(currentWick, left_x, high)
    line.set_xy2(currentWick, left_x, low)

// © Timvcutz

//@version=6

plot(close)
````
