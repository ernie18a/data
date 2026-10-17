# 1234up

- url: https://www.tradingview.com/script/jRZmnOqV-1234up/
- type: indicator
- pine_id: PUB;4baff4e4506f4ee0a326421e6841b625
- version: 1.0

## Description

look lhkjgh.ogoiuglifluyucuyf,iyf vgfuygflufylifyliyv  gfliyfliygk,v

## Source Code

````pine
//@version=6
indicator("ATR + Bollinger Bands + 21 SMA", overlay=true, max_lines_count=500)

// USER INPUTS

smaLength    = input.int(21, title="SMA Length", group="21 SMA")
smaColor     = input.color(color.yellow, title="SMA Color", group="21 SMA")

bbLength     = input.int(20, title="BB Length", minval=1, group="Bollinger Bands")
bbMult       = input.float(2.0, title="BB StdDev Multiplier", step=0.1, group="Bollinger Bands")
bbSrc        = input.source(close, title="BB Source", group="Bollinger Bands")
bbUpperColor = input.color(color.new(color.blue, 0), title="Upper Band Color", group="Bollinger Bands")
bbLowerColor = input.color(color.new(color.blue, 0), title="Lower Band Color", group="Bollinger Bands")
bbMidColor   = input.color(color.new(color.gray, 40), title="Middle Band Color", group="Bollinger Bands")
bbFillColor  = input.color(color.new(color.blue, 88), title="Band Fill Color", group="Bollinger Bands")

atrLength    = input.int(14, title="ATR Length", minval=1, group="ATR")
atrMult      = input.float(1.5, title="ATR Band Multiplier", step=0.1, group="ATR")
showATRBands = input.bool(true, title="Show ATR Envelope", group="ATR")
atrUpperColor = input.color(color.new(color.orange, 0), title="ATR Upper Color", group="ATR")
atrLowerColor = input.color(color.new(color.orange, 0), title="ATR Lower Color", group="ATR")
atrFillColor  = input.color(color.new(color.orange, 90), title="ATR Fill Color", group="ATR")

showSqueeze  = input.bool(true, title="Highlight Squeeze", group="Squeeze")
squeezeColor = input.color(color.new(color.red, 60), title="Squeeze Color", group="Squeeze")

// CALCULATIONS

sma21 = ta.sma(close, smaLength)

[bbUpper, bbMid, bbLower] = ta.bb(bbSrc, bbLength, bbMult)
bbWidth = bbUpper - bbLower

atrVal   = ta.atr(atrLength)
atrUpper = sma21 + atrVal * atrMult
atrLower = sma21 - atrVal * atrMult

isSqueeze = bbUpper < atrUpper and bbLower > atrLower

// PLOTS

atrU = plot(showATRBands ? atrUpper : na, title="ATR Upper", color=atrUpperColor, linewidth=1)
atrL = plot(showATRBands ? atrLower : na, title="ATR Lower", color=atrLowerColor, linewidth=1)
fill(atrU, atrL, color=showATRBands ? atrFillColor : na, title="ATR Fill")

bbU = plot(bbUpper, title="BB Upper", color=bbUpperColor, linewidth=1)
bbL = plot(bbLower, title="BB Lower", color=bbLowerColor, linewidth=1)
plot(bbMid, title="BB Middle", color=bbMidColor, linewidth=1)
fill(bbU, bbL, color=bbFillColor, title="BB Fill")

plot(sma21, title="21 SMA", color=smaColor, linewidth=2)

bgcolor(showSqueeze and isSqueeze ? squeezeColor : na, title="Squeeze Background")

// INFO TABLE

var table t = table.new(position.top_right, 2, 5, bgcolor=color.new(color.black, 70), border_color=color.new(color.gray, 50), border_width=1, frame_color=color.new(color.gray, 50), frame_width=1)

if barstate.islast
    table.cell(t, 0, 0, "Indicator", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 0, "Value", text_color=color.gray, text_size=size.small)
    table.cell(t, 0, 1, "21 SMA", text_color=color.yellow, text_size=size.small)
    table.cell(t, 1, 1, str.tostring(sma21, "#.##"), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 2, "ATR", text_color=color.orange, text_size=size.small)
    table.cell(t, 1, 2, str.tostring(atrVal, "#.##"), text_color=color.white, text_size=size.small)
    table.cell(t, 0, 3, "BB Width", text_color=color.blue, text_size=size.small)
    table.cell(t, 1, 3, str.tostring(bbWidth, "#.##"), text_color=color.white, text_size=size.small)
    squeezeLabel     = isSqueeze ? "YES" : "NO"
    squeezeTextColor = isSqueeze ? color.red : color.green
    table.cell(t, 0, 4, "Squeeze", text_color=color.gray, text_size=size.small)
    table.cell(t, 1, 4, squeezeLabel, text_color=squeezeTextColor, text_size=size.small)

// ALERTS

alertcondition(isSqueeze and not isSqueeze[1], title="Squeeze Begins", message="BB Squeeze detected.")
alertcondition(not isSqueeze and isSqueeze[1], title="Squeeze Ends", message="Squeeze released - potential breakout.")
alertcondition(close > atrUpper, title="Above ATR Upper", message="Price closed above ATR upper.")
alertcondition(close < atrLower, title="Below ATR Lower", message="Price closed below ATR lower.")
````
