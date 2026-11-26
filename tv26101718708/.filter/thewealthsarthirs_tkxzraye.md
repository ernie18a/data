# TheWealthSarthiRS

- url: https://www.tradingview.com/script/tKxzrAYE-TheWealthSarthiRS/
- type: indicator
- pine_id: PUB;46985fee5c7f40c097ac108a7cf177c0
- version: 1.0

## Description

This is combined Indicator
has Moving Average
RS
Buying Force
Purple Dot

## Source Code

````pine
//@version=6
indicator('TheWealthSaarthiRS', overlay = true)

// Dynamic Relative Strength Indicator

//Input
source = input(title = 'Source', defval = close)
comparativeTickerId = input.symbol('NSE:CNXSMALLCAP', title = 'Comparative Symbol')
length = input.int(123, minval = 1, title = 'Daily Period')
inpLen2 = input(52, title = 'Weekly Period')
length := timeframe.isweekly ? inpLen2 : length
Monthly = input(10, title = 'Monthly Period')
length := timeframe.ismonthly ? Monthly : length

// Bollinger Bands settings
lengthBB = input(20, title = 'BB Length')
multBB = input(2.0, title = 'BB Mult')

// Other Settings
showRefDateLbl = input(defval = false, title = 'Show Reference Label')
toggleRSColor = input(defval = true, title = 'Toggle RS color on crossovers')
showRSTrend = input.bool(defval = false, title = 'RS Trend,', group = 'RS Trend', inline = 'RS Trend')
base = input.int(title = 'Range', minval = 1, defval = 5, group = 'RS Trend', inline = 'RS Trend')

//Set up
baseSymbol = request.security(syminfo.tickerid, timeframe.period, source)
comparativeSymbol = request.security(comparativeTickerId, timeframe.period, source)

//Calculations
res = baseSymbol / baseSymbol[length] / (comparativeSymbol / comparativeSymbol[length]) - 1
resColor = toggleRSColor ? res > 0 ? color.green : color.red : color.blue
refDay = showRefDateLbl and barstate.islast ? dayofmonth(time[length]) : na
refMonth = showRefDateLbl and barstate.islast ? month(time[length]) : na
refYear = showRefDateLbl and barstate.islast ? year(time[length]) : na
refLabelStyle = res[length] > 0 ? label.style_label_up : label.style_label_down
refDateLabel = showRefDateLbl and barstate.islast ? label.new(bar_index - length, 0, text = 'RS-' + str.tostring(length) + ' reference, ' + str.tostring(refDay) + '-' + str.tostring(refMonth) + '-' + str.tostring(refYear), color = color.blue, style = refLabelStyle, yloc = yloc.price) : na
y0 = res - res[base]
angle0 = math.atan(y0 / base) // radians
zeroLineColor = showRSTrend ? angle0 > 0.0 ? color.green : color.maroon : color.maroon

// Color the chart background based on the relative strength value
bgcolor(res > 0 ? color.new(color.green, 70) : color.new(color.red, 70))

// Combined Up Down with Volume Indicator

use = input(true, 'Combine the conditions?')
vol = input(1000000, 'Volume above')
per = input(5, '% check')
roc = math.abs(ta.roc(close, 1)) >= per
check = volume >= vol

// Plot shapes for Combined Up Down with Volume Indicator
plotshape(not use ? roc : false, style = shape.circle, location = location.belowbar, color = color.new(color.yellow, 0))
plotshape(not use ? check : false, style = shape.triangleup, location = location.belowbar, color = color.new(color.lime, 0))
plotshape(use ? roc and check : false, style = shape.circle, location = location.belowbar, color = color.new(color.purple, 0))

// Relative Volume in Percentage (%) label

var string GP1 = 'Input Data'
vol_len = input.int(title = 'Relative Volume Length', defval = 20, group = GP1)


var string GP2 = 'Display'
txt_sizeopt = input.string(title = 'Text Size', defval = 'auto', inline = '10', options = ['auto', 'tiny', 'small', 'normal', 'large', 'huge'], group = GP2)
txt_size = txt_sizeopt == 'auto' ? size.auto : txt_sizeopt == 'tiny' ? size.tiny : txt_sizeopt == 'small' ? size.small : txt_sizeopt == 'normal' ? size.normal : txt_sizeopt == 'large' ? size.large : size.huge
string i_tableYpos = input.string('top', 'Panel position', inline = '11', options = ['top', 'middle', 'bottom'], group = GP2)
string i_tableXpos = input.string('right', '', inline = '11', options = ['left', 'center', 'right'], group = GP2)

var table rvolDisplay = table.new(i_tableYpos + '_' + i_tableXpos, 2, 1, border_width = 1, border_color = color.white)

Round(_val, _decimals) =>
    // Rounds _val to _decimals places.
    _p = math.pow(10, _decimals)
    math.round(math.abs(_val) * _p) / _p * math.sign(_val)

format_text(str) =>
    str + '\n'

t = ticker.new(syminfo.prefix, syminfo.ticker)


timeFrame = timeframe.isweekly ? 'W' : timeframe.ismonthly ? 'M' : 'D'

today_vol = request.security(t, timeFrame, volume)
yday_vol = request.security(t, timeFrame, volume[1])
avg_vol = request.security(t, timeFrame, ta.sma(yday_vol, vol_len))
volpct = math.round(today_vol / avg_vol * 100)

final_rvol = format_text(str.tostring(volpct) + '%')

color_vol = volpct <= 20 ? color.new(color.red, 0) : color.new(color.green, 0)

if barstate.islast
    // We only populate the table on the last bar.
    table.cell(rvolDisplay, 0, 0, timeFrame + '_RVol: ' + str.tostring(volpct, '#.##') + '%', bgcolor = color_vol, text_size = txt_size)


showbarLine = input(false, title = 'Show Selected Bar RVol Line')
bar_today_vol = volume
bar_avg_vol = ta.sma(volume[1], vol_len)
bar_volpct = math.round(bar_today_vol / bar_avg_vol * 100)
plot(bar_volpct, color = showbarLine ? color.red : na, linewidth = 1, title = 'Each Bar RVol')

// Calculate the percentage increase in the last 66 days
lowest_low_66 = ta.lowest(low, 66)
highest_high_66 = ta.highest(high, 66)
price_increase_66 = (close - lowest_low_66) / lowest_low_66 * 100

// Display the percentage increase in the last 66 days in the table
if barstate.islast
    table.cell(rvolDisplay, 1, 0, 'BF' + str.tostring(price_increase_66, '#.##') + '%', text_size = txt_size)

// Define SMA for different time frames
dailySMA = ta.sma(close, 20) // 20-period SMA on daily time frame
weeklySMA10 = request.security(syminfo.tickerid, 'W', ta.sma(close, 10)) // 10-period SMA on weekly time frame
weeklySMA40 = request.security(syminfo.tickerid, 'W', ta.sma(close, 40)) // 40-period SMA on weekly time frame
monthlySMA12 = request.security(syminfo.tickerid, 'M', ta.sma(close, 12)) // 12-period SMA on monthly time frame
monthlySMA24 = request.security(syminfo.tickerid, 'M', ta.sma(close, 24)) // 24-period SMA on monthly time frame
monthlySMA36 = request.security(syminfo.tickerid, 'M', ta.sma(close, 36)) // 36-period SMA on monthly time frame

// Plot the SMAs
plot(timeframe.isdaily ? dailySMA : na, color = color.new(color.blue, 0), linewidth = 2, title = '20-Day SMA')
plot(timeframe.isweekly ? weeklySMA10 : na, color = color.new(color.green, 0), linewidth = 2, title = '10-Week SMA')
plot(timeframe.isweekly ? weeklySMA40 : na, color = color.new(color.red, 0), linewidth = 2, title = '40-Week SMA')
plot(timeframe.ismonthly ? monthlySMA12 : na, color = color.new(color.purple, 0), linewidth = 2, title = '12-Month SMA')
plot(timeframe.ismonthly ? monthlySMA24 : na, color = color.new(color.orange, 0), linewidth = 2, title = '24-Month SMA')
plot(timeframe.ismonthly ? monthlySMA36 : na, color = color.new(color.yellow, 0), linewidth = 2, title = '36-Month SMA')



// Previous day's low
prevLow = low[1]

// 1% breach level above previous low
targetCross = prevLow * 1.01

// Conditions
openedBelowPrevLow = open < prevLow
smallDip = low >= open * 0.99 // Low is not more than 1% below open
strongReversal = high >= targetCross

// Final condition
bullishOops = openedBelowPrevLow and smallDip and strongReversal

// Plot signal
plotshape(bullishOops, title = 'Bullish Oops', location = location.belowbar, style = shape.labelup, color = color.new(color.green, 0), text = 'Oops↑')
````
