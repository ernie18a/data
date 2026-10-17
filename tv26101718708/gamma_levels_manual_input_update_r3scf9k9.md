# Gamma Levels (Manual Input) update

- url: https://www.tradingview.com/script/R3scF9k9-Gamma-Levels-Manual-Input-update/
- type: indicator
- pine_id: PUB;1a5224e2386f47d9994e374de2d800cb
- version: 2.0

## Description

Manually input your own gamma levels 
CALL WALL 
PUT WALL 
GAMMA FLIP

## Source Code

````pine
//@version=6
indicator("Gamma Levels (Auto Symbol Filter)", overlay=true)

// =========================
// 🔧 INPUTS
// =========================

// QQQ
qqq_call_top     = input.float(662, "QQQ Call Wall Top")
qqq_call_bottom  = input.float(660, "QQQ Call Wall Bottom")
qqq_put_top      = input.float(655, "QQQ Put Wall Top")
qqq_put_bottom   = input.float(653, "QQQ Put Wall Bottom")
qqq_flip         = input.float(657, "QQQ Flip Level")

// SPX
spx_call_top     = input.float(7150, "SPX Call Wall Top")
spx_call_bottom  = input.float(7140, "SPX Call Wall Bottom")
spx_put_top      = input.float(7100, "SPX Put Wall Top")
spx_put_bottom   = input.float(7080, "SPX Put Wall Bottom")
spx_flip         = input.float(7125, "SPX Flip Level")

// =========================
// 🎨 COLORS
// =========================
callColor = input.color(color.red, "Call Zone Color")
putColor  = input.color(color.green, "Put Zone Color")
flipColor = input.color(color.yellow, "Flip Line Color")

// =========================
// 📌 SYMBOL DETECTION
// =========================
isQQQ = str.contains(syminfo.ticker, "QQQ")
isSPX = str.contains(syminfo.ticker, "SPX")

// =========================
// 📦 QQQ ZONES
// =========================
var box qqq_call = na
var box qqq_put  = na

if isQQQ
    if na(qqq_call)
        qqq_call := box.new(bar_index, qqq_call_top, bar_index, qqq_call_bottom,
            bgcolor=color.new(callColor, 80), border_color=callColor)

        qqq_put := box.new(bar_index, qqq_put_top, bar_index, qqq_put_bottom,
            bgcolor=color.new(putColor, 80), border_color=putColor)

    box.set_right(qqq_call, bar_index)
    box.set_right(qqq_put, bar_index)

    box.set_top(qqq_call, qqq_call_top)
    box.set_bottom(qqq_call, qqq_call_bottom)

    box.set_top(qqq_put, qqq_put_top)
    box.set_bottom(qqq_put, qqq_put_bottom)

// =========================
// 📦 SPX ZONES
// =========================
var box spx_call = na
var box spx_put  = na

if isSPX
    if na(spx_call)
        spx_call := box.new(bar_index, spx_call_top, bar_index, spx_call_bottom,
            bgcolor=color.new(callColor, 85), border_color=callColor)

        spx_put := box.new(bar_index, spx_put_top, bar_index, spx_put_bottom,
            bgcolor=color.new(putColor, 85), border_color=putColor)

    box.set_right(spx_call, bar_index)
    box.set_right(spx_put, bar_index)

    box.set_top(spx_call, spx_call_top)
    box.set_bottom(spx_call, spx_call_bottom)

    box.set_top(spx_put, spx_put_top)
    box.set_bottom(spx_put, spx_put_bottom)

// =========================
// 📏 FLIP LEVELS
// =========================
plot(isQQQ ? qqq_flip : na, "QQQ Flip", color=flipColor, linewidth=2)
plot(isSPX ? spx_flip : na, "SPX Flip", color=flipColor, linewidth=2)
````
