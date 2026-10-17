# POC Direction & Range

- url: https://www.tradingview.com/script/QUHKL44q-POC-Direction-Range/
- type: indicator
- pine_id: PUB;2b1fd99ad41c47b5be4db502a136a263
- version: 1.0

## Description

NDICATOR : POC Direction & Range
AUTHOR : Baan
VERSION : 1.0

DESCRIPTION:
A clean and simple dashboard indicator that shows two key pieces of information at a glance:

1. POC Direction — tells you whether the current price is above or below the Point of Control (POC). The POC is calculated by finding the price level where most candles closed within the lookback period.
• Bullish → price is above POC
• Bearish → price is below POC

2. Range Status — tells you whether the current price is still inside the recent high-low range or has broken out of it.
• In Range → price is inside the lookback high-low range
• Out Range → price has broken outside the lookback high-low range

RECOMMENDED LOOKBACK SETTINGS:
• 1 min chart → 30
• 3 min chart → 25
• 10 min chart → 20
• 20 min chart → 15

HOW TO USE:
• Bearish + In Range → price is below POC, still consolidating
• Bullish + In Range → price is above POC, still consolidating
• Out Range → price has broken out of the recent range, possible strong move developing

NOTE: This indicator is a tool to assist your analysis. Always combine it with proper price action, support/resistance levels, and risk management. Never trade based on a single indicator alone.

## Source Code

````pine
//@version=5
indicator("POC Direction & Range", overlay=true)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
length   = input.int(20, "Lookback Length", minval=5)
tablePos = input.string("Bottom Right", "Table Position", options=["Bottom Right", "Bottom Left", "Top Right", "Top Left"])

// ─── HELPERS ──────────────────────────────────────────────────────────────────
f_tablePos(p) =>
    switch p
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        "Top Right"    => position.top_right
        => position.top_left

// ─── POC CALCULATION ──────────────────────────────────────────────────────────
rangeHigh = ta.highest(high, length)
rangeLow  = ta.lowest(low,   length)
rangeSize = rangeHigh - rangeLow
rowSize   = 15
binSize   = rangeSize / rowSize

maxCount = 0
pocLevel = rangeLow

for i = 0 to rowSize - 1
    binLow  = rangeLow + i * binSize
    binHigh = binLow + binSize
    count   = 0
    for j = 0 to length - 1
        c = close[j]
        if c >= binLow and c < binHigh
            count += 1
    if count > maxCount
        maxCount := count
        pocLevel := (binLow + binHigh) / 2.0

poc = pocLevel

// ─── STATUS ───────────────────────────────────────────────────────────────────
pocDirection = close > poc ? "Bullish" : "Bearish"
dirColor     = close > poc ? color.new(color.green, 0) : color.new(color.red, 0)

isInRange   = close >= rangeLow and close <= rangeHigh
rangeStatus = isInRange ? "In Range" : "Out Range"
rangeColor  = isInRange ? color.new(color.green, 0) : color.new(color.orange, 0)

// ─── TABLE ────────────────────────────────────────────────────────────────────
var table dash = table.new(
  f_tablePos(tablePos), 2, 2,
  bgcolor      = color.new(color.black, 20),
  border_color = color.new(color.gray, 40),
  border_width = 1,
  frame_color  = color.new(color.gray, 40),
  frame_width  = 1
 )

if barstate.islast
    table.cell(dash, 0, 0, "POC Direction :",
      text_color = color.white,
      text_size  = size.normal,
      bgcolor    = color.new(color.black, 30))
    table.cell(dash, 1, 0, pocDirection,
      text_color = dirColor,
      text_size  = size.normal,
      bgcolor    = color.new(color.black, 30))

    table.cell(dash, 0, 1, "Range :",
      text_color = color.white,
      text_size  = size.normal,
      bgcolor    = color.new(color.black, 30))
    table.cell(dash, 1, 1, rangeStatus,
      text_color = rangeColor,
      text_size  = size.normal,
      bgcolor    = color.new(color.black, 30))
````
