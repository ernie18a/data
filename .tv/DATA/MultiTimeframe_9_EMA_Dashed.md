<!-- tradingview-pine-id: PUB;14b35af578e5411bb24420b88259d772 -->
<!-- tradingviewscripts-format: 1 -->
# Multi-Timeframe 9 EMA — Dashed

Source: https://www.tradingview.com/script/k9lf3izI-Multi-Timeframe-9-EMA-Dashed/

## Description

Shows 9ema from 3 min, 5 min and 10 min on a 30 min chart.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ghoritrading718

//@version=6
indicator(
     "Multi-Timeframe 9 EMA — Dashed",
     overlay=true,
     max_lines_count=500
)

// Settings
emaLength   = input.int(9, "EMA Length", minval=1)
historyBars = input.int(150, "Displayed History", minval=20, maxval=160)

// Lower-timeframe EMAs
ema3Min = request.security(
     syminfo.tickerid,
     "3",
     ta.ema(close, emaLength),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)

ema5Min = request.security(
     syminfo.tickerid,
     "5",
     ta.ema(close, emaLength),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)

ema10Min = request.security(
     syminfo.tickerid,
     "10",
     ta.ema(close, emaLength),
     gaps=barmerge.gaps_off,
     lookahead=barmerge.lookahead_off
)

// Price-axis labels
plot(
     ema3Min,
     title="3m 9EMA",
     color=color.orange,
     display=display.price_scale
)

plot(
     ema5Min,
     title="5m 9EMA",
     color=color.rgb(255, 105, 180),
     display=display.price_scale
)

plot(
     ema10Min,
     title="10m 9EMA",
     color=color.red,
     display=display.price_scale
)

// Store dashed line segments
var ema3Lines  = array.new_line()
var ema5Lines  = array.new_line()
var ema10Lines = array.new_line()

// Dashed EMA function
drawDashedEMA(lineArray, emaValue, lineColor) =>
    if bar_index > 0 and not na(emaValue) and not na(emaValue[1])
        newLine = line.new(
             x1=bar_index[1],
             y1=emaValue[1],
             x2=bar_index,
             y2=emaValue,
             xloc=xloc.bar_index,
             extend=extend.none,
             color=lineColor,
             style=line.style_dashed,
             width=2
        )

        array.push(lineArray, newLine)

        if array.size(lineArray) > historyBars
            oldLine = array.shift(lineArray)
            line.delete(oldLine)

// Draw dashed EMAs
drawDashedEMA(ema3Lines, ema3Min, color.orange)
drawDashedEMA(ema5Lines, ema5Min, color.rgb(255, 105, 180))
drawDashedEMA(ema10Lines, ema10Min, color.red)
````
