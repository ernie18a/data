# VietRoadie's RVol Label

- url: https://www.tradingview.com/script/2K4bTkmp-VietRoadie-s-RVol-Label/
- type: indicator
- pine_id: PUB;84cdf031c0254df2a77ab8b4a3a29771
- version: 2.0

## Description

How the label is calculated
On an intraday or daily chart, the label compares the current day's cumulative volume with the average volume of the previous 20 completed days:

RVol = current daily volume / average(previous 20 daily volumes)

On a weekly chart, the calculation instead uses current-week volume against previous completed weeks; on a monthly chart, it uses current-month volume against previous completed months. The indicator does not compare the current 1-minute or 3-minute bar with the same clock-minute bar on earlier days.

The label reads Vol: … Avg Vol: … RVol: …x (…%) [zone]:

Field	Meaning
Vol	Accumulated volume for the current day, week, or month of the chart symbol
Avg Vol	Average total volume for the previous Relative Volume Length completed periods
RVol	Current period volume divided by Avg Vol; 1.00x means equal to that full-period average
%	RVol multiplied by 100 and rounded to a whole percent
For example, Vol: 30 Mil Avg Vol: 40 Mil RVol: 0.75x (75%) means the current period has traded 75% of the volume of an average completed period. Early in the session, a reading below 1.00x is normal because the current day is still forming. The label changes as volume accumulates; compare it with full-day average at the end of the day, not as a same-time participation gauge.

Color zones
RVol	Label zone	Label color
Below 1.00x	Ignore Zone	Gray
1.00x through 1.50x	Elevated Retail	Orange
Above 1.50x through 2.00x	Momentum Build	Green (partly transparent)
Above 2.00x	Strong BO, Big Institutional Acculumation	Green
These are indicator labels, not guarantees of trade quality or evidence of who traded.

Inputs
Input	Default	Effect
Relative Volume Length	20	Number of prior completed days, weeks, or months in the full-period average
Text Size	auto	Label font size
Panel position	top / center	Label placement: vertical top, middle, or bottom; horizontal left, center, or right
Show Selected Bar RVol Line	Off	Displays the separate Each Bar RVol plot in red
The optional Each Bar RVol line is a different measure: the chart bar's volume divided by the average volume of the previous 20 chart bars, multiplied by 100. At 150, the current chart bar traded 1.5 times the recent bar-volume average. This plot uses the chart timeframe, not the same-clock-time average over prior sessions. Because the indicator overlays price, enabling this percentage plot may affect the chart's scale.

Compared with IceBerg and Weighted A/D RVOL
The IceBerg TICK and Weighted SPX Sectors A/D RVOL filters use SPY volume at the same clock time across earlier sessions. Their readings are intended to assess participation at this point in the day; this label assesses accumulated volume against an entire average day (or week/month). They are different quantities and should not be expected to match, even on a SPY chart.

For SPX, which has no meaningful exchange-traded share volume, use a liquid proxy such as a SPY chart if you want this label to reflect equity volume. The label does not automatically substitute SPY on an SPX chart.

Data notes: Before enough completed periods exist, or if the symbol has no usable volume or the average is zero, RVol may be unavailable (na). On historical intraday candles, TradingView's higher-timeframe data merging can display the daily value only when that day's bar is available; use the live label for an in-progress reading. This indicator is context, not a standalone entry signal.

## Source Code

````pine
//@version=6
// Created by @VietRoadie
// Last Updated: 2026-09-28 09:03 CST
// Relative Volume and total volume with Average Volume in the same row

indicator("VietRoadie's RVol Label", "RVol", true)

// === Inputs ===
var string GP1 = "Input Data"
vol_len = input.int(20, title="Relative Volume Length", group=GP1)

var string GP2 = "Display"
txt_sizeopt = input.string("auto", title="Text Size", inline="10", options=["auto", "tiny", "small", "normal", "large", "huge"], group=GP2)
txt_size = txt_sizeopt == "auto" ? size.auto : txt_sizeopt == "tiny" ? size.tiny : txt_sizeopt == "small" ? size.small : txt_sizeopt == "normal" ? size.normal : txt_sizeopt == "large" ? size.large : size.huge
panelPosition = input.string("Top Center", "Panel position", options=["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], group=GP2)
tablePosition = panelPosition == "Top Left" ? position.top_left : panelPosition == "Top Center" ? position.top_center : panelPosition == "Top Right" ? position.top_right : panelPosition == "Middle Left" ? position.middle_left : panelPosition == "Middle Center" ? position.middle_center : panelPosition == "Middle Right" ? position.middle_right : panelPosition == "Bottom Left" ? position.bottom_left : panelPosition == "Bottom Center" ? position.bottom_center : position.bottom_right

showbarLine = input.bool(false, title="Show Selected Bar RVol Line")

// === Table ===
var table rvolDisplay = table.new(tablePosition, 1, 1, border_width=1, border_color=color.white)

// === Data ===
t = syminfo.tickerid
timeFrame = timeframe.isweekly ? "W" : timeframe.ismonthly ? "M" : "D"

today_vol = request.security(t, timeFrame, volume)
yday_vol  = request.security(t, timeFrame, volume[1])
avg_vol   = request.security(t, timeFrame, ta.sma(volume[1], vol_len))

rvol   = today_vol / avg_vol
volpct = math.round(rvol * 100)

// === Formatting ===
avg_vol_display   = avg_vol   >= 1000000 ? str.tostring(math.round(avg_vol   / 1000000, 2)) + " Mil" : str.tostring(math.round(avg_vol   / 1000, 2)) + "k"
today_vol_display = today_vol >= 1000000 ? str.tostring(math.round(today_vol / 1000000, 2)) + " Mil" : str.tostring(math.round(today_vol / 1000, 2)) + "k"

// === RVol zones ===
zoneText = rvol < 1.0 ? "Ignore Zone" : rvol <= 1.5 ? "Elevated Retail" : rvol > 2.0 ? "Strong BO, Big Institutional Acculumation" : "Momentum Build"

labelText = "Vol: " + today_vol_display + "   Avg Vol: " + avg_vol_display + "   RVol: " + str.tostring(math.round(rvol, 2)) + "x (" + str.tostring(volpct) + "%)" + "   " + zoneText

labelColor = rvol < 1.0 ? color.gray : rvol <= 1.5 ? color.orange : rvol > 2.0 ? color.green : color.new(color.green, 30)

if barstate.islast
    table.cell(rvolDisplay, 0, 0, labelText, bgcolor=labelColor, text_size=txt_size)

// === Optional per-bar RVol plot ===
bar_avg_vol = ta.sma(volume[1], vol_len)
bar_volpct  = math.round((volume / bar_avg_vol) * 100)
plot(bar_volpct, color=showbarLine ? color.red : na, linewidth=1, title="Each Bar RVol")
````
