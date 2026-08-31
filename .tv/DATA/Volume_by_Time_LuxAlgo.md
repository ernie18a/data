<!-- tradingview-pine-id: PUB;a2daff770ece4336b451be4da12ce47e -->
<!-- tradingviewscripts-format: 1 -->
# Volume by Time [LuxAlgo]

Source: https://www.tradingview.com/script/uLzJcB7H-Volume-by-Time-LuxAlgo/

## Description

The Volume by Time indicator collects volume data for every point in time over the day and displays the average volume of the specific dataset collected at each respective bar.

The indicator overlays the current volume and the historical average to allow for better comparisons.

 🔶 USAGE

[image]https://www.tradingview.com/x/ZnhFiogc/[/image]

Throughout the day, the volume of every bar is stored in groups organized by the time when each bar occurred.

Over time, the datasets accumulate, and from that, we can simply determine the average value at each specific time of the day.

[image]https://www.tradingview.com/x/MNBben10/[/image]

The display is a histogram style, which consists of hollow bars and solid filled columns.

-Hollow bars represent the average volume at that time of the day.
-Solid columns display the current volume from the current bar.

[image]https://www.tradingview.com/x/x6yrPtzY/[/image]

By default, the entire history of data is used, but if desired, the number of days under analysis can be specified to provide a more relevant point of view.

A readout of the number of days being analyzed can be seen in the status bar at any time.

Note: Due to partial sessions, it is typical to see this value change throughout the day; this is simply due to the fact that not every trading session has the exact same schedule 100% of the time.

[image]https://www.tradingview.com/x/ZXeJ0gDO/[/image]

The analysis type can also be specified; these can be either Average (Default) or Median.

[image]https://www.tradingview.com/x/vkGlJP32/[/image]

Additionally, a Bi-directional can be toggled for a distinct difference between upwards volume and downwards volume.

🔶 SETTINGS

[*]Analysis Type: Choose between Average or Median analysis modes.
[*]Length (Days): Set the number of days to use for analysis. Set to 0 for full data (Default 0).
[*]Bi-Directional Toggle: Toggle between one-sided or two-sided display.

---

## Source Code

````pine
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © LuxAlgo

//@version=6
indicator("Volume by Time [LuxAlgo]", "LuxAlgo - Volume by Time", format = format.volume)

//---------------------------------------------------------------------------------------------------------------------}
//User Inputs
//---------------------------------------------------------------------------------------------------------------------{
avgType = input.string("Average", title = "Analysis Type", options = ["Average","Median"])
sz = input.int(0, title = "Length (Days)", tooltip = "Averaging Length\nSet Value to 0 for Max Analysis Length")
bidi = input.bool(false, title = "Bi-Directional", tooltip = "Enable Bi-Directional Display\nBearish Volume will be negative, Bullish Volume will be positive.")
upCol = input.color(#089981, title = "Bullish Color", group = "Style")
downCol = input.color(#f23645, title = "Bearish Color", group = "Style")
upVolCol = input.color(color.new(color.gray,60), title = "Up Volume Color", group = "Style")
downVolCol = input.color(color.new(color.black,60), title = "Down Volume Color", group = "Style")
invis = color.rgb(0,0,0,100)

//---------------------------------------------------------------------------------------------------------------------}
//UDTs
//---------------------------------------------------------------------------------------------------------------------{

type vols
    array<float> ary

//---------------------------------------------------------------------------------------------------------------------}
//Variables
//---------------------------------------------------------------------------------------------------------------------{

var data = map.new<int,vols>()

vol = volume
v = close > open  ? vol : -vol

hms = hour*10000 + minute*100 + second

//---------------------------------------------------------------------------------------------------------------------}
//Calculations
//---------------------------------------------------------------------------------------------------------------------{

if na(data.get(hms))
    data.put(hms,vols.new(array.from(float(vol))))
else
    if sz != 0 and data.get(hms).ary.size() == sz
        data.get(hms).ary.shift()
    data.get(hms).ary.push(v)

raw_avg = avgType == "Average" ? data.get(hms).ary.avg() : data.get(hms).ary.median()
avg = avgType == "Average" ? data.get(hms).ary.abs().avg() :  data.get(hms).ary.abs().median()

avg_col = raw_avg > 0 ? upCol : downCol
vol_col = close > open ? upVolCol : downVolCol
dir_avg = raw_avg > 0 ? avg : -avg

//---------------------------------------------------------------------------------------------------------------------}
//Display
//---------------------------------------------------------------------------------------------------------------------{

plotcandle(0,bidi?dir_avg:avg,0,bidi?dir_avg:avg, bordercolor = avg_col, color = invis, wickcolor = invis, title = "Average Volume", display = display.pane, editable = false)
plotcandle(0,bidi?v:vol,0,bidi?v:vol, bordercolor = vol_col, color = vol_col, wickcolor = invis, title = "Volume", display = display.pane, editable = false)

plot(vol, style = plot.style_columns, color = vol_col, title = "Volume", display = display.status_line, editable = false)
plot(avg, style = plot.style_columns, color = avg_col, title = "Average Volume", display = display.status_line, editable = false)

plot(data.get(hms).ary.size(), display = display.status_line, color = chart.fg_color, format = format.volume, title = "Avg Length Readout")

//---------------------------------------------------------------------------------------------------------------------}
````
