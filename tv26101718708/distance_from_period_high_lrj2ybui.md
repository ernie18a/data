# Distance From Period High (%)

- url: https://www.tradingview.com/script/LRJ2yBUi-Distance-From-Period-High/
- type: indicator
- pine_id: PUB;99d94d819a4749a693e8184178e22b6b
- version: 1.0

## Description

Improved version of the one by ZulSyirah.

Shows distance from ATH - but ATH can be set 1M/3M/6M/12M/2Y/5Y.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZulSyirah

//@version=6
indicator("Distance From Period High (%)", overlay = true, max_bars_back = 5000)

// === SETTINGS ===
boxPosition = position.top_right   // change if needed

period = input.string("12M", "Lookback period", options = ["1M", "3M", "6M", "12M", "2Y", "5Y"])

// Chosen period expressed in calendar milliseconds (time is in ms)
periodMs = switch period
    "1M"  => 30   * 24 * 60 * 60 * 1000
    "3M"  => 91   * 24 * 60 * 60 * 1000
    "6M"  => 182  * 24 * 60 * 60 * 1000
    "12M" => 365  * 24 * 60 * 60 * 1000
    "2Y"  => 730  * 24 * 60 * 60 * 1000
    "5Y"  => 1825 * 24 * 60 * 60 * 1000
    => 365 * 24 * 60 * 60 * 1000

maxScan = 5000   // history buffer cap — matches max_bars_back, stays well under the 15000 limit

currentPrice = close

// === PERIOD HIGH (time-accurate, bounded scan) ===
var float periodHigh = na
var bool  capped     = false

if barstate.islast
    threshold = time - periodMs
    float hh  = high
    bool  hit = false
    for i = 0 to maxScan
        if i > bar_index            // reached the start of the chart
            break
        if time[i] < threshold      // reached the period boundary — done
            hit := true
            break
        hh := math.max(hh, high[i])
    periodHigh := hh
    capped     := not hit           // window limited by data/scan, not the full period

    // === PERCENT DIFFERENCE ===
    percentFromHigh = ((currentPrice - periodHigh) / periodHigh) * 100

    // === READABLE PERCENT STRING (sign + 1 decimal) ===
    pctText = (percentFromHigh >= 0 ? "+" : "") + str.tostring(percentFromHigh, "#,##0.0") + "%"

    // Color logic
    bgColor = percentFromHigh >= -5  ? color.new(color.green, 80) :
              percentFromHigh >= -15 ? color.new(color.orange, 80) :
                                       color.new(color.red, 80)

    // === TABLE (CORNER BOX) ===
    var table athTable = table.new(boxPosition, 1, 3, border_width = 1)
    hdr = period + " High" + (capped ? " (max avail.)" : "")
    table.cell(athTable, 0, 0, hdr + ": "      + str.tostring(periodHigh, format.mintick),   text_color = color.gray)
    table.cell(athTable, 0, 1, "Current: "     + str.tostring(currentPrice, format.mintick), text_color = color.gray)
    table.cell(athTable, 0, 2, "From High: "   + pctText, bgcolor = bgColor, text_color = color.white, text_size = size.large)
````
