# ATR Based Entry and Exit Levels

- url: https://www.tradingview.com/script/zEniRPsq-ATR-Based-Entry-and-Exit-Levels/
- type: indicator
- pine_id: PUB;b648b756fcb849e2ae6e77a89c3e3823
- version: 5.0

## Description

This indicator calculates ATR‑based Entry and Exit levels for every candle using ATR(14) with RMA. Entry = High + ATR, Exit = Low − ATR. All values appear in the Data Window when hovering any candle. Plot lines are transparent by default to keep the chart clean, but can be shown by toggling the indicator visibility. Color‑coded: Entry (green), Exit (red), ATR (purple).

## Source Code

````pine
//@version=6
indicator("ATR Based Entry and Exit Levels By Nish", overlay = true, precision = 2)

// ATR length input
atrLength = input.int(14, "ATR Length", minval = 1)

// Manual ATR multiplier
atrMult = input.float(1.0, "ATR Multiplier", minval = 0.0, step = 0.1)

// ATR using RMA
atrValue  = ta.rma(ta.tr(true), atrLength)

// Entry & Exit formulas using multiplier
entryPrice = high + atrValue * atrMult
exitPrice  = low  - atrValue * atrMult

// Round to 2 decimals
round(x) => math.round(x * 100) / 100

entryRounded = round(entryPrice)
exitRounded  = round(exitPrice)
atrRounded   = round(atrValue)

// Entry & Exit: invisible lines, values in data window only
plot(entryRounded, "Entry (High + ATR * Mult)", color = color.new(color.green, 100),
     display = display.pane + display.data_window + display.status_line)

plot(exitRounded, "Exit (Low - ATR * Mult)", color = color.new(color.red, 100),
     display = display.pane + display.data_window + display.status_line)

// ATR: completely hidden everywhere
plot(atrRounded, "ATR (RMA)", color = color.purple, display = display.none)
````
