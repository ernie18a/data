# ATR Range Box

- url: https://www.tradingview.com/script/CGjurQSd-ATR-Range-Box/
- type: indicator
- pine_id: PUB;00d423193c0a4743a7a618a153eb73fc
- version: 1.0

## Description

The indicator is programmed to draw two separate boxes, one for a Stop Loss (SL) range and another for a Take Profit (TP). It serves as a visual aid for defining SL and TP ranges based on the period and the ATR multiple.

## Source Code

````pine
//@version=6
indicator("ATR SL & TP History Range", overlay=true)

// === INPUTS TP ===
tpAtrPMin = input.int(150, "TP ATR Period Min", group="TP")
tpAtrPMax = input.int(200, "TP ATR Period Max", group="TP")
tpMultMin = input.float(1.5, "TP Multiplier Min", group="TP")
tpMultMax = input.float(3.0, "TP Multiplier Max", group="TP")

// === INPUTS SL ===
slAtrPMin = input.int(150, "SL ATR Period Min", group="SL")
slAtrPMax = input.int(200, "SL ATR Period Max", group="SL")
slMultMin = input.float(1.0, "SL Multiplier Min", group="SL")
slMultMax = input.float(2.0, "SL Multiplier Max", group="SL")

// === CALCULATIONS ===
price = close

// TP Range
tpU = price + (ta.atr(tpAtrPMax) * tpMultMax)
tpL = price + (ta.atr(tpAtrPMin) * tpMultMin)

// SL Range
slU = price - (ta.atr(slAtrPMin) * slMultMin)
slL = price - (ta.atr(slAtrPMax) * slMultMax)

// === PLOTTING & FILL ===
// TP Plots
p_tpU = plot(tpU, "TP Upper", color.new(color.green, 50))
p_tpL = plot(tpL, "TP Lower", color.new(color.lime, 50))
fill(p_tpU, p_tpL, color.new(color.green, 85), "TP Zone")

// SL Plots
p_slU = plot(slU, "SL Upper", color.new(color.orange, 50))
p_slL = plot(slL, "SL Lower", color.new(color.red, 50))
fill(p_slU, p_slL, color.new(color.red, 85), "SL Zone")
````
