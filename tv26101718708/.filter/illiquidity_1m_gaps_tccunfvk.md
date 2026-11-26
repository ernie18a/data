# Illiquidity 1m gaps

- url: https://www.tradingview.com/script/tCcunFvk-Illiquidity-1m-gaps/
- type: indicator
- pine_id: PUB;e20fc925e1f14f6ea83386d02d616e49
- version: 1.0

## Description

// WHAT IT DOES
//   Detects illiquid stocks by counting how often consecutive 1-minute bars
//   fail to touch each other. On liquid names trades print continuously, so
//   each bar's open is essentially equal to the previous bar's close. On
//   illiquid names there are minutes with zero trades, and when a trade
//   finally happens it can land at a meaningfully different price - leaving
//   a visible gap between bars. Many such gaps in a session is a direct
//   signal of thin liquidity.
//
//   The indicator runs the 1-min gap analysis even when applied to higher
//   timeframes (e.g. daily). Each daily candle is annotated with the total
//   number of 1-min gaps that occurred during that session, broken into
//   gap-ups and gap-downs. When the count exceeds the threshold, the
//   display turns red.
//
// HOW IT WORKS
//   1. Fetches 1-minute data via request.security_lower_tf(), regardless
//      of the chart's current timeframe.
//   2. For each 1-min bar, compares open to the prior close.
//   3. A gap is registered when |open - prevClose| / prevClose * 100
//      exceeds the configured threshold.
//   4. Session-boundary jumps (overnight, lunch break) are excluded by
//      checking the time delta between consecutive bars - only bars less
//      than 5 minutes apart in real time are considered.
//   5. Gaps are summed across all 1-min bars within the current chart bar.
//
// INPUTS
//   - Min gap size pct: Minimum price jump (% of price) that counts as a
//     gap. Default 0.10%. Increase for cheap stocks (<Rs.100 use 0.20%),
//     decrease for high-priced names (>Rs.3000 use 0.05%).
//   - Gaps per chart bar to flag illiquid: Threshold above which the bar
//     is marked red. Suggested starting values by category:
//       Nifty 50 / large caps : 10
//       Mid caps              : 20  (default)
//       Small caps            : 35
//       Microcaps / SME       : 60+
//   - Show on chart (table): Toggle the corner table.
//   - Show in status line: Toggle the three numbers in TradingView's
//     status line (Total / Up / Down).
//   - Table position: 9-way position picker (top/middle/bottom x
//     left/center/right).
//   - Text size: Tiny / Small / Normal / Large.
//
// DISPLAY
//   - Table shows: "<total>g  <up>u  <down>d" e.g. "14g  8u 6d".
//   - Status line shows the same three numbers as separate plot values.
//   - Background of the readout flips red when total >= threshold.
//
// LIMITATIONS
//   - TradingView caches a limited amount of lower-timeframe history. On
//     a daily chart pulling 1-min data, typically only the most recent
//     10-40 trading days will populate accurately. Older bars may show
//     zero gaps because the 1-min data is unavailable, not because the
//     stock was liquid.
//   - Free/Basic plans have stricter intrabar limits than paid plans.
//   - Works best on equity instruments with regular sessions. For 24/7
//     markets (crypto), the session-boundary filter is unused.
//
// USE CASE
//   Screen out illiquid stocks before adding them to a watchlist or sizing
//   into a position. Apply this indicator to your daily chart, glance at
//   the corner readout, and skip any name flagged red - the spread and
//   slippage on those will eat your edge.
//
// CALIBRATION
//   Apply to three reference tickers on your daily chart:
//   - A known liquid name (RELIANCE) - should read ~0-5 gaps.
//   - A midcap you actually trade - note the typical count.
//   - A microcap or SME - should read 50+.
//   Set your threshold to roughly 2x the typical count of your tradeable
//   midcap.
// =============================================================================

## Source Code

````pine
//@version=6
indicator("Illiquidity 1m gaps", overlay = true)

gapThresholdPct = input.float(0.10, "Min gap size pct", minval = 0.0, step = 0.05)
maxGapsPerBar   = input.int(20, "Gaps per chart bar to flag illiquid", minval = 1)

showTable      = input.bool(true,  "Show on chart (table)")
showStatusLine = input.bool(true,  "Show in status line")

posChoice = input.string("Bottom right", "Table position",
     options = ["Top left", "Top center", "Top right",
                "Middle left", "Middle center", "Middle right",
                "Bottom left", "Bottom center", "Bottom right"])

textSize = input.string("Small", "Text size",
     options = ["Tiny", "Small", "Normal", "Large"])

sameSession = (time - time[1]) < 1000 * 60 * 5
prevC       = close[1]
gapPct      = na(prevC) ? 0.0 : math.abs(open - prevC) / prevC * 100
isGap       = sameSession and not na(prevC) and gapPct >= gapThresholdPct
isUp        = isGap and open > prevC
isDn        = isGap and open < prevC

upArr   = request.security_lower_tf(syminfo.tickerid, "1", isUp ? 1 : 0)
downArr = request.security_lower_tf(syminfo.tickerid, "1", isDn ? 1 : 0)

upCount   = array.size(upArr)   > 0 ? array.sum(upArr)   : 0
downCount = array.size(downArr) > 0 ? array.sum(downArr) : 0
total     = upCount + downCount
illiquid  = total >= maxGapsPerBar

getPos(s) =>
    s == "Top left"       ? position.top_left       :
     s == "Top center"     ? position.top_center     :
     s == "Top right"      ? position.top_right      :
     s == "Middle left"    ? position.middle_left    :
     s == "Middle center"  ? position.middle_center  :
     s == "Middle right"   ? position.middle_right   :
     s == "Bottom left"    ? position.bottom_left    :
     s == "Bottom center"  ? position.bottom_center  :
                             position.bottom_right

getSize(s) =>
    s == "Tiny"   ? size.tiny   :
     s == "Small"  ? size.small  :
     s == "Normal" ? size.normal :
                     size.large

var table tbl = table.new(getPos(posChoice), 1, 1, border_width = 0)

if showTable and barstate.islast
    txt = str.tostring(total) + "g  " + str.tostring(upCount) + "u " + str.tostring(downCount) + "d"
    table.cell(tbl, 0, 0, txt,
         text_color = color.white,
         bgcolor    = illiquid ? color.red : color.new(color.gray, 30),
         text_size  = getSize(textSize))

plot(showStatusLine ? total     : na, title = "Total gaps", color = illiquid ? color.red : color.gray,
     display = display.status_line)
plot(showStatusLine ? upCount   : na, title = "Up gaps",   color = color.green,
     display = display.status_line)
plot(showStatusLine ? downCount : na, title = "Down gaps", color = color.red,
     display = display.status_line)

alertcondition(illiquid, "Illiquid bar", "1-min gap count exceeded threshold on this bar")
````
