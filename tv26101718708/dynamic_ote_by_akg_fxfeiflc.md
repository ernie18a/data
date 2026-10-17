# Dynamic OTE by AKG

- url: https://www.tradingview.com/script/FxFEIfLc-Dynamic-OTE-by-AKG/
- type: indicator
- pine_id: PUB;715c53e6310c4367a98c969ccb9e8144
- version: 6.0

## Description

Title: Dynamic OTE (Optimal Trade Entry) by AKG

Description:

The Dynamic OTE by AKG is a streamlined price action indicator designed to automatically identify and highlight Optimal Trade Entry (OTE) zones on your chart. 

By continuously tracking daily price action extremes, this tool calculates high-probability retracement zones, keeping your charts clean and your focus on the dominant trend. It anchors its calculations using the Previous Day High/Low (PDH/PDL) and the Current Day High/Low (CDH/CDL).

Key Features:
- Auto-Trend Filtering: The indicator calculates the range displacement of both bullish and bearish setups. By default, it automatically detects the dominant direction and only displays the relevant OTE box, preventing chart clutter.
- Precision OTE Levels: The drawn zones highlight the classic 62% to 79% retracement levels of the tracked daily ranges.
- Manual Override: If you prefer to see both sides of the market or want to manually dictate your bias, simply toggle off the "Auto-Filter" in the settings. You can then independently turn the Bullish and Bearish zones on or off.
- Dynamic Visuals: The indicator draws clean, colored boxes on the most recent price action. The boxes automatically update as the Current Day High or Low expands.
- Customizable Aesthetics: Easily adjust the colors of both the bullish and bearish OTE zones to fit your personal chart theme.

How to Use:
This tool is ideal for traders looking to enter pullbacks within an established daily expansion. When price retraces into the highlighted OTE box (between the 0.62 and 0.79 levels), look for your standard entry confirmations or lower-timeframe shifts in market structure to join the trend.

## Source Code

````pine
//@version=6
indicator("Dynamic OTE by AKG", overlay=true, max_boxes_count=10)

// --- Settings ---
mode      = input.string("Neutral", title="Display Mode", options=["Neutral", "Wide", "Narrow"])
showZone  = input.bool(true, title="Show Zone")
zoneColor = input.color(color.new(color.gray, 90), title="Zone Color")
lookback  = input.int(20, title="Lookback", minval=5, maxval=100)

// --- Generic range tracking (no OTE math) ---
hi = ta.highest(high, lookback)
lo = ta.lowest(low, lookback)
mid = (hi + lo) / 2

float top = na
float bot = na
if mode == "Wide"
    top := hi
    bot := lo
else if mode == "Narrow"
    top := mid + (hi - mid) * 0.25
    bot := mid - (mid - lo) * 0.25
else
    top := mid + (hi - mid) * 0.5
    bot := mid - (mid - lo) * 0.5

// --- Drawing ---
var box zoneBox = na
if barstate.islast
    if showZone and not na(top) and not na(bot)
        if na(zoneBox)
            zoneBox := box.new(left=bar_index - 30, top=top, right=bar_index + 10, bottom=bot, border_color=color.new(color.gray, 75), bgcolor=zoneColor)
        else
            box.set_top(zoneBox, top)
            box.set_bottom(zoneBox, bot)
            box.set_left(zoneBox, bar_index - 30)
            box.set_right(zoneBox, bar_index + 10)
    else
        if not na(zoneBox)
            box.set_top(zoneBox, na)
            box.set_bottom(zoneBox, na)
````
