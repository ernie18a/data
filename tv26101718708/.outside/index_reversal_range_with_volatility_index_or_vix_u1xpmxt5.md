# Index Reversal Range with Volatility Index or VIX

- url: https://www.tradingview.com/script/u1xPMxT5-Index-Reversal-Range-with-Volatility-Index-or-VIX/
- type: indicator
- pine_id: PUB;4630fb1f1b1c471da7ea2b4a5f23f960
- version: 4.0

## Description

[b][i]What is the Indicator?[/i][/b]
• The indicator is a visualization of maximum price in which the respective index can go up to in comparison with it's Volatility Index or VIX.

[b][i]Who to use?[/i][/b]
• Intraday
• Swing
• Position
• Long term Investors
• Futures
• Options
• Portfolio Managers
• Mutual Fund Managers
• Index Traders
• Volatility based Traders
• Long term Investors and Options Traders gets the maximum benefit

[b][i]What timeframe to use?[/i][/b]
• 1 Year: Position & Investors
• 6 Months: Position & Investors
• 3 Months: Swing & Position
• 1 Month: Swing & Position
• 1 Week: Swing
• 1 Day: Swing
• 1 Hour: Intraday & Swing

[b][i]What are Upper and Lower lines?[/i][/b]
• Upper Line: If the index price reach closer to the Upper line there is a high chance of reversal to Bearish trend.
• Lower Line: If the index price reach closer to the Lower line there is a high chance of reversal to Bullish trend.
• This need to be confirmed with multiple levels like Daily, Weekly, Monthly etc.

[b][i]How to use?[/i][/b]
• If the price reach closer to that level there is a high chance of reversal from the current trend.
• To identify the reversal zone of the index.
• To identify the trend.
• Option Traders can Sell a Call or Put Option from that level.
• Long term Investors, Position or Swing traders can plan for a Long entry.
• Intraday traders can use lower timeframes to do the same. 

[b][i]Indicator Menu[/i][/b]
• Input VIX: Identify the VIX Symbol of your Index and type it in the box.
• For example for NIFTY Index chart type INDIAVIX in the box.
• Choose multiple timeframes according to your convenience.

[b][i]How to turn on indicator Name and Value labels?[/i][/b]
• Right side of the screen >
• Right click on the Price scale >
• Labels > Indicators and financial name labels, Indicators and financial value labels

[b][i]Further Reading:[/i][/b]
• Various videos and reading materials are available about this method.

## Source Code

````pine
// This crs code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Arun_K_Bhaskar

//@version=5

indicator(title="Index Reversal Range with Volatility Index or VIX", shorttitle="Index VIX Range", format=format.price, precision=2, overlay=true)//, timeframe="", timeframe_gaps=true)

ttVIX = "Type the Symbol of Volatility Index or VIX which measures volatility of the market. Eg: 'NSE:INDIAVIX' for 'NSE:NIFTY' Index"

input_vix = input.symbol(defval="NSE:INDIAVIX", title="Input VIX", confirm=true, tooltip=ttVIX)

gpTF = "Timeframe"
show_1m = input.bool(false, title="1 min   ", group=gpTF, inline="1")
show_5m = input.bool(true, title="5 min   ", group=gpTF, inline="1")
show_30m = input.bool(true, title="30 min  ", group=gpTF, inline="1")
show_1h = input.bool(false, title="Hourly  ", group=gpTF, inline="2")
show_D = input.bool(true, title="Daily    ", group=gpTF, inline="2")
show_W = input.bool(false, title="Weekly  ", group=gpTF, inline="2")
show_M = input.bool(false, title="Monthly ", group=gpTF, inline="3")
show_3M = input.bool(false, title="Quarterly", group=gpTF, inline="3")
show_6M = input.bool(false, title="Halfyearly", group=gpTF, inline="3")
show_1Y = input.bool(false, title="Yearly", group=gpTF, inline="4")

show_label = input.bool(true, title="Label")

color_1m = #00bcf2
color_5m = #ff8c00
color_30m = #00b294
color_1h = #e81123
color_D = #009e49
color_W = #ec008c
color_M = #bad80a
color_3M = #68217a
color_6M = #00188f
color_1Y = #fff100

//////////////////////////////////////////////////////////////////// 1 Minute Index Range

vix_ltp_1min = request.security(input_vix, "1", close, barmerge.gaps_on, barmerge.lookahead_on)

min_1_val = (vix_ltp_1min /  math.sqrt(252 * 375)) / 100

min_1_upper = close + (close * min_1_val)
min_1_lower = close - (close * min_1_val)

plot(show_1m ? min_1_upper : na, title="1 Minute Upper", color=color.new(color_1m, 0))
plot(show_1m ? min_1_lower : na, title="1 Minute Lower", color=color.new(color_1m, 0))

//////////////////////////////////////////////////////////////////// 5 Minute Index Range

vix_ltp_5min = request.security(input_vix, "5", close, barmerge.gaps_on, barmerge.lookahead_on)

min_5_val = (vix_ltp_5min /  math.sqrt(252 * 375 / 5)) / 100

min_5_upper = close + (close * min_5_val)
min_5_lower = close - (close * min_5_val)

plot(show_5m ? min_5_upper : na, title="5 Minute Upper", color=color.new(color_5m, 0))
plot(show_5m ? min_5_lower : na, title="5 Minute Lower", color=color.new(color_5m, 0))

//////////////////////////////////////////////////////////////////// 30 Minute Index Range

vix_ltp_30min = request.security(input_vix, "30", close, barmerge.gaps_on, barmerge.lookahead_on)

min_30_val = (vix_ltp_30min /  math.sqrt(252 * 375 / 30)) / 100

min_30_upper = close + (close * min_30_val)
min_30_lower = close - (close * min_30_val)

plot(show_30m ? min_30_upper : na, title="30 Minute Upper", color=color.new(color_30m, 0))
plot(show_30m ? min_30_lower : na, title="30 Minute Lower", color=color.new(color_30m, 0))

//////////////////////////////////////////////////////////////////// Hourly Index Range

vix_ltp_1h = request.security(input_vix, "60", close, barmerge.gaps_on, barmerge.lookahead_on)

hourly_val = (vix_ltp_1h /  math.sqrt(252 * 375 / 60)) / 100

hour_upper = close + (close * hourly_val)
hour_lower = close - (close * hourly_val)

plot(show_1h ? hour_upper : na, title="Hourly Upper", color=color.new(color_1h, 0))
plot(show_1h ? hour_lower : na, title="Hourly Lower", color=color.new(color_1h, 0))

//////////////////////////////////////////////////////////////////// Daily Index Range

vix_ltp_D = request.security(input_vix, "D", close, barmerge.gaps_on, barmerge.lookahead_on)

daily_val = (vix_ltp_D / math.sqrt(252)) / 100

day_upper = close + (close * daily_val)
day_lower = close - (close * daily_val)

plot(show_D ? day_upper : na, title="Daily Upper", color=color.new(color_D, 0))
plot(show_D ? day_lower : na, title="Daily Lower", color=color.new(color_D, 0))

//////////////////////////////////////////////////////////////////// Weekly Index Range

vix_ltp_W = request.security(input_vix, "W", close, barmerge.gaps_on, barmerge.lookahead_on)

weekly_val = (vix_ltp_W / math.sqrt(52)) / 100

week_upper = close + (close * weekly_val)
week_lower = close - (close * weekly_val)

plot(show_W ? week_upper : na, title="Weekly Upper", color=color.new(color_W, 0))
plot(show_W ? week_lower : na, title="Weekly Lower", color=color.new(color_W, 0))

//////////////////////////////////////////////////////////////////// Monthly Index Range

vix_ltp_M = request.security(input_vix, "M", close, barmerge.gaps_on, barmerge.lookahead_on)

monthly_val = (vix_ltp_M / math.sqrt(12)) / 100

month_upper = close + (close * monthly_val)
month_lower = close - (close * monthly_val)

plot(show_M ? month_upper : na, title="Monthly Upper", color=color.new(color_M, 0))
plot(show_M ? month_lower : na, title="Monthly Lower", color=color.new(color_M, 0))

//////////////////////////////////////////////////////////////////// Quarterly Index Range

vix_ltp_3M = request.security(input_vix, "3M", close, barmerge.gaps_on, barmerge.lookahead_on)

quarterly_val = (vix_ltp_3M / math.sqrt(4)) / 100

quarter_upper = close + (close * quarterly_val)
quarter_lower = close - (close * quarterly_val)

plot(show_3M ? quarter_upper : na, title="Quarterly Upper", color=color.new(color_3M, 0))
plot(show_3M ? quarter_lower : na, title="Quarterly Lower", color=color.new(color_3M, 0))

//////////////////////////////////////////////////////////////////// Halfyearly Index Range

vix_ltp_6M = request.security(input_vix, "6M", close, barmerge.gaps_on, barmerge.lookahead_on)

halfyearly_val = (vix_ltp_6M / math.sqrt(2)) / 100

halfyear_upper = close + (close * halfyearly_val)
halfyear_lower = close - (close * halfyearly_val)

plot(show_6M ? halfyear_upper : na, title="Halfyearly Upper", color=color.new(color_6M, 0))
plot(show_6M ? halfyear_lower : na, title="Halfyearly Lower", color=color.new(color_6M, 0))

//////////////////////////////////////////////////////////////////// Yearly Index Range

vix_ltp_Y = request.security(input_vix, "12M", close, barmerge.gaps_on, barmerge.lookahead_on)

year_upper = close + ((close / 100) * vix_ltp_Y)
year_lower = close - ((close / 100) * vix_ltp_Y)

plot(show_1Y ? year_upper : na, title="Yearly Upper", color=color.new(color_1Y, 0))//, style=plot.style_circles, linewidth=2, join=true)
plot(show_1Y ? year_lower : na, title="Yearly Lower", color=color.new(color_1Y, 0))

//////////////////////////////////////////////////////////////////// Live Levels and Labels

year_volt_ln = request.security(input_vix, "D", close)
year_volt_prev_ln = request.security(input_vix, "D", close[1])

min_1_volt_ln = year_volt_ln / math.sqrt(252 * 375)
min_5_volt_ln = year_volt_ln / math.sqrt(252 * 375 / 5)
min_30_volt_ln = year_volt_ln / math.sqrt(252 * 375 / 30)
hour_volt_ln = year_volt_ln / math.sqrt(252 * 375 / 60)
day_volt_ln = year_volt_ln / math.sqrt(252)
week_volt_ln = year_volt_ln / math.sqrt(52)
month_volt_ln = year_volt_ln / math.sqrt(12)
quarter_volt_ln = year_volt_ln / math.sqrt(4)
halfyear_volt_ln = year_volt_ln / math.sqrt(2)

min_1_upper_ln = close * (1 + min_1_volt_ln / 100)
min_1_lower_ln = close * (1 - min_1_volt_ln / 100)

min_5_upper_ln = close * (1 + min_5_volt_ln / 100)
min_5_lower_ln = close * (1 - min_5_volt_ln / 100)

min_30_upper_ln = close * (1 + min_30_volt_ln / 100)
min_30_lower_ln = close * (1 - min_30_volt_ln / 100)

hour_upper_ln = close * (1 + hour_volt_ln / 100)
hour_lower_ln = close * (1 - hour_volt_ln / 100)

day_upper_ln = close * (1 + day_volt_ln / 100)
day_lower_ln = close * (1 - day_volt_ln / 100)

week_upper_ln = close * (1 + week_volt_ln / 100)
week_lower_ln = close * (1 - week_volt_ln / 100)

month_upper_ln = close * (1 + month_volt_ln / 100)
month_lower_ln = close * (1 - month_volt_ln / 100)

year_upper_ln = close * (1 + year_volt_ln / 100)
year_lower_ln = close * (1 - year_volt_ln / 100)

quarter_upper_ln = close * (1 + quarter_volt_ln / 100)
quarter_lower_ln = close * (1 - quarter_volt_ln / 100)

halfyear_upper_ln = close * (1 + halfyear_volt_ln / 100)
halfyear_lower_ln = close * (1 - halfyear_volt_ln / 100)

// Label

chper = time - time[1]
chper := ta.change(chper) > 0 ? chper[1] : chper

if show_1m
    var line min_1_upper_ln_line = na
    min_1_upper_ln_line := line.new(bar_index[1], min_1_upper_ln, bar_index, min_1_upper_ln, color=color.new(color_1m, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(min_1_upper_ln_line[1])
    var line min_1_lower_ln_line = na
    min_1_lower_ln_line := line.new(bar_index[1], min_1_lower_ln, bar_index, min_1_lower_ln, color=color.new(color_1m, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(min_1_lower_ln_line[1])
    if show_label
        var label min_1_upper_ln_label = na
        label.delete(min_1_upper_ln_label)
        min_1_upper_ln_label := label.new(x = time + chper * 0, y = min_1_upper_ln, text = str.tostring(min_1_upper_ln, "#.##") + " (1m⌃) " + str.tostring(min_1_volt_ln, "#.##") + "%\n", textcolor=color_1m, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)
        var label min_1_lower_ln_label = na
        label.delete(min_1_lower_ln_label)
        min_1_lower_ln_label := label.new(x = time + chper * 0, y = min_1_lower_ln, text = str.tostring(min_1_lower_ln, "#.##") + " (1m⌄) " + str.tostring(min_1_volt_ln, "#.##") + "%\n", textcolor=color_1m, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)

if show_5m
    var line min_5_upper_ln_line = na
    min_5_upper_ln_line := line.new(bar_index[1], min_5_upper_ln, bar_index, min_5_upper_ln, color=color.new(color_5m, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(min_5_upper_ln_line[1])
    var line min_5_lower_ln_line = na
    min_5_lower_ln_line := line.new(bar_index[1], min_5_lower_ln, bar_index, min_5_lower_ln, color=color.new(color_5m, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(min_5_lower_ln_line[1])
    if show_label
        var label min_5_upper_ln_label = na
        label.delete(min_5_upper_ln_label)
        min_5_upper_ln_label := label.new(x = time + chper * 0, y = min_5_upper_ln, text = str.tostring(min_5_upper_ln, "#.##") + " (5m⌃) " + str.tostring(min_5_volt_ln, "#.##") + "%\n", textcolor=color_5m, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)
        var label min_5_lower_ln_label = na
        label.delete(min_5_lower_ln_label)
        min_5_lower_ln_label := label.new(x = time + chper * 0, y = min_5_lower_ln, text = str.tostring(min_5_lower_ln, "#.##") + " (5m⌄) " + str.tostring(min_5_volt_ln, "#.##") + "%\n", textcolor=color_5m, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)

if show_30m
    var line min_30_upper_ln_line = na
    min_30_upper_ln_line := line.new(bar_index[1], min_30_upper_ln, bar_index, min_30_upper_ln, color=color.new(color_30m, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(min_30_upper_ln_line[1])
    var line min_30_lower_ln_line = na
    min_30_lower_ln_line := line.new(bar_index[1], min_30_lower_ln, bar_index, min_30_lower_ln, color=color.new(color_30m, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(min_30_lower_ln_line[1])
    if show_label
        var label min_30_upper_ln_label = na
        label.delete(min_30_upper_ln_label)
        min_30_upper_ln_label := label.new(x = time + chper * 0, y = min_30_upper_ln, text = str.tostring(min_30_upper_ln, "#.##") + " (30m⌃) " + str.tostring(min_30_volt_ln, "#.##") + "%\n", textcolor=color_30m, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)
        var label min_30_lower_ln_label = na
        label.delete(min_30_lower_ln_label)
        min_30_lower_ln_label := label.new(x = time + chper * 0, y = min_30_lower_ln, text = str.tostring(min_30_lower_ln, "#.##") + " (30m⌄) " + str.tostring(min_30_volt_ln, "#.##") + "%\n", textcolor=color_30m, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)

if show_1h
    var line hour_upper_ln_line = na
    hour_upper_ln_line := line.new(bar_index[1], hour_upper_ln, bar_index, hour_upper_ln, color=color.new(color_1h, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(hour_upper_ln_line[1])
    var line hour_lower_ln_line = na
    hour_lower_ln_line := line.new(bar_index[1], hour_lower_ln, bar_index, hour_lower_ln, color=color.new(color_1h, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(hour_lower_ln_line[1])
    if show_label
        var label hour_upper_ln_label = na
        label.delete(hour_upper_ln_label)
        hour_upper_ln_label := label.new(x = time + chper * 0, y = hour_upper_ln, text = str.tostring(hour_upper_ln, "#.##") + " (1h⌃) " + str.tostring(hour_volt_ln, "#.##") + "%\n", textcolor=color_1h, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)
        var label hour_lower_ln_label = na
        label.delete(hour_lower_ln_label)
        hour_lower_ln_label := label.new(x = time + chper * 0, y = hour_lower_ln, text = str.tostring(hour_lower_ln, "#.##") + " (1h⌄) " + str.tostring(hour_volt_ln, "#.##") + "%\n", textcolor=color_1h, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)

if show_D
    var line day_upper_ln_line = na
    day_upper_ln_line := line.new(bar_index[1], day_upper_ln, bar_index, day_upper_ln, color=color.new(color_D, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(day_upper_ln_line[1])
    var line day_lower_ln_line = na
    day_lower_ln_line := line.new(bar_index[1], day_lower_ln, bar_index, day_lower_ln, color=color.new(color_D, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(day_lower_ln_line[1])
    if show_label    
        var label day_upper_ln_label = na
        label.delete(day_upper_ln_label)
        day_upper_ln_label := label.new(x = time + chper * 0, y = day_upper_ln, text = str.tostring(day_upper_ln, "#.##") + " (D⌃) " + str.tostring(day_volt_ln, "#.##") + "%\n", textcolor=color_D, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)
        var label day_lower_ln_label = na
        label.delete(day_lower_ln_label)
        day_lower_ln_label := label.new(x = time + chper * 0, y = day_lower_ln, text = str.tostring(day_lower_ln, "#.##") + " (D⌄) " + str.tostring(day_volt_ln, "#.##") + "%\n", textcolor=color_D, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)

if show_W
    var line week_upper_ln_line = na
    week_upper_ln_line := line.new(bar_index[1], week_upper_ln, bar_index, week_upper_ln, color=color.new(color_W, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(week_upper_ln_line[1])
    var line week_lower_ln_line = na
    week_lower_ln_line := line.new(bar_index[1], week_lower_ln, bar_index, week_lower_ln, color=color.new(color_W, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(week_lower_ln_line[1])
    if show_label  
        var label week_upper_ln_label = na
        label.delete(week_upper_ln_label)
        week_upper_ln_label := label.new(x = time + chper * 0, y = week_upper_ln, text = str.tostring(week_upper_ln, "#.##") + " (W⌃) " + str.tostring(week_volt_ln, "#.##") + "%\n", textcolor=color_W, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)
        var label week_lower_ln_label = na
        label.delete(week_lower_ln_label)
        week_lower_ln_label := label.new(x = time + chper * 0, y = week_lower_ln, text = str.tostring(week_lower_ln, "#.##") + " (W⌄) " + str.tostring(week_volt_ln, "#.##") + "%\n", textcolor=color_W, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)

if show_M
    var line month_upper_ln_line = na
    month_upper_ln_line := line.new(bar_index[1], month_upper_ln, bar_index, month_upper_ln, color=color.new(color_M, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(month_upper_ln_line[1])
    var line month_lower_ln_line = na
    month_lower_ln_line := line.new(bar_index[1], month_lower_ln, bar_index, month_lower_ln, color=color.new(color_M, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(month_lower_ln_line[1])
    if show_label  
        var label month_upper_ln_label = na
        label.delete(month_upper_ln_label)
        month_upper_ln_label := label.new(x = time + chper * 0, y = month_upper_ln, text = str.tostring(month_upper_ln, "#.##") + " (M⌃) " + str.tostring(month_volt_ln, "#.##") + "%\n", textcolor=color_M, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)
        var label month_lower_ln_label = na
        label.delete(month_lower_ln_label)
        month_lower_ln_label := label.new(x = time + chper * 0, y = month_lower_ln, text = str.tostring(month_lower_ln, "#.##") + " (M⌄) " + str.tostring(month_volt_ln, "#.##") + "%\n", textcolor=color_M, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)

if show_3M
    var line quarter_upper_ln_line = na
    quarter_upper_ln_line := line.new(bar_index[1], quarter_upper_ln, bar_index, quarter_upper_ln, color=color.new(color_3M, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(quarter_upper_ln_line[1])
    var line quarter_lower_ln_line = na
    quarter_lower_ln_line := line.new(bar_index[1], quarter_lower_ln, bar_index, quarter_lower_ln, color=color.new(color_3M, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(quarter_lower_ln_line[1])
    if show_label  
        var label quarter_upper_ln_label = na
        label.delete(quarter_upper_ln_label)
        quarter_upper_ln_label := label.new(x = time + chper * 0, y = quarter_upper_ln, text = str.tostring(quarter_upper_ln, "#.##") + " (3M⌃) " + str.tostring(quarter_volt_ln, "#.##") + "%\n", textcolor=color_3M, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)
        var label quarter_lower_ln_label = na
        label.delete(quarter_lower_ln_label)
        quarter_lower_ln_label := label.new(x = time + chper * 0, y = quarter_lower_ln, text = str.tostring(quarter_lower_ln, "#.##") + " (3M⌄) " + str.tostring(quarter_volt_ln, "#.##") + "%\n", textcolor=color_3M, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)

if show_6M
    var line halfyear_upper_ln_line = na
    halfyear_upper_ln_line := line.new(bar_index[1], halfyear_upper_ln, bar_index, halfyear_upper_ln, color=color.new(color_6M, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(halfyear_upper_ln_line[1])
    var line halfyear_lower_ln_line = na
    halfyear_lower_ln_line := line.new(bar_index[1], halfyear_lower_ln, bar_index, halfyear_lower_ln, color=color.new(color_6M, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(halfyear_lower_ln_line[1])
    if show_label  
        var label halfyear_upper_ln_label = na
        label.delete(halfyear_upper_ln_label)
        halfyear_upper_ln_label := label.new(x = time + chper * 0, y = halfyear_upper_ln, text = str.tostring(halfyear_upper_ln, "#.##") + " (6M⌃) " + str.tostring(halfyear_volt_ln, "#.##") + "%\n", textcolor=color_6M, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)
        var label halfyear_lower_ln_label = na
        label.delete(halfyear_lower_ln_label)
        halfyear_lower_ln_label := label.new(x = time + chper * 0, y = halfyear_lower_ln, text = str.tostring(halfyear_lower_ln, "#.##") + " (6M⌄) " + str.tostring(halfyear_volt_ln, "#.##") + "%\n", textcolor=color_6M, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)

if show_1Y
    var line year_upper_ln_line = na
    year_upper_ln_line := line.new(bar_index[1], year_upper_ln, bar_index, year_upper_ln, color=color.new(color_1Y, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(year_upper_ln_line[1])
    var line year_lower_ln_line = na
    year_lower_ln_line := line.new(bar_index[1], year_lower_ln, bar_index, year_lower_ln, color=color.new(color_1Y, 0), style=line.style_solid, width=1, extend=extend.right)
    line.delete(year_lower_ln_line[1])
    if show_label  
        var label year_upper_ln_label = na
        label.delete(year_upper_ln_label)
        year_upper_ln_label := label.new(x = time + chper * 0, y = year_upper_ln, text = str.tostring(year_upper_ln, "#.##") + " (Y⌃) " + str.tostring(year_volt_ln, "#.##") + "%\n", textcolor=color_1Y, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)
        var label year_lower_ln_label = na
        label.delete(year_lower_ln_label)
        year_lower_ln_label := label.new(x = time + chper * 0, y = year_lower_ln, text = str.tostring(year_lower_ln, "#.##") + " (Y⌄) " + str.tostring(year_volt_ln, "#.##") + "%\n", textcolor=color_1Y, color=color.new(color.white, 100), style=label.style_label_left, size=size.normal, xloc = xloc.bar_time, yloc=yloc.price)

//////////////////////////////////////////////////////////////////// End
````
