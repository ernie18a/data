# Sheabot Relative Volume and Range

- url: https://www.tradingview.com/script/ICeZBK3s-Sheabot-Relative-Volume-and-Range/
- type: indicator
- pine_id: PUB;1bd72dfe4d764d8ba97f090f3a261408
- version: 2.0

## Description

Display a combined table showing relative volume and relative range (also known as Daily True Range vs Average True Range) on all timeframes. The table rows change colors based on the relative volume and relative range values. The values and colors can be configured.

These indicators are combined together for a more efficient display in the same location. These indicators also commonly move together. A low relative volume will also likely have a low relative range. A high relative volume may accompany the price breaking out past the average range and a relative range over 100%. The relative range can also help set price targets. If the relative range is less than 100%, then the stock has not yet moved to its average range.

These concepts are used and inspired by the great [url=https://www.tradingview.com/u/ripster47/]@ripster47[/url].

[b]Relative Volume[/b]
[list]
[*]Table displays current volume, average volume, and relative volume as a percent of current volume / average volume over the timeframe.
[*]When the timeframe is 1D or less, then the current volume is the volume for the day so far, and the average volume is calculated over the past bar length days.
[*]When the timeframe is greater than 1D, then the current volume is the volume for the week/month/year so far, and the average volume is calculated over the past bar length weeks/months/years.
[*] High Percent: Default is 100. Relative volume below this is considered low and the table row is colored grey. Relative volume above this is considered high and the table row is colored yellow.
[*] Unusual Percent. Default is 200. Relative volume above this is considered unusual and the table row is colored green.
[/list]

[b]Relative Range[/b]
[list]
[*]Table displays daily true range (DTR), average true range (ATR), and relative range as a percent of DTR / ATR over the timeframe.
[*]When the timeframe is 1D or less, then the daily true range is the difference between the high and low price since open, and the average true range is calculated over the past bar length days.
[*]When the timeframe is greater than 1D, then the daily true range is the difference between the high and low price for the past week/month/year, and the average true range is calculated over the past bar length weeks/months/years.
[*] Normal Percent: Default is 50. Relative range below this is considered low and the table row is colored grey. Relative range above this is considered normal and the table row is colored yellow.
[*] High Percent. Default is 90. Relative range above this is considered high and the table row is colored red.
[/list]

## Source Code

````pine
//@version=6
indicator('Sheabot Relative Volume and Range', 'RVol, RRange', overlay = true, scale = scale.none)

// Table Display inputs
var string grp_display = 'Table Display'
var string text_size = input.string(
    title = 'Text Size', 
    defval = size.auto, 
    options = [size.auto, size.tiny, size.small, size.normal, size.large, size.huge],
    group = grp_display)
var string table_pos = input.string(
    title = 'Table Position', 
    defval = position.top_right, 
    options = [
        position.top_left, position.top_center, position.top_right, 
        position.middle_left, position.middle_center, position.middle_right, 
        position.bottom_left, position.bottom_center, position.bottom_right],
    group = grp_display)

// Relative Volume inputs
var string group_volume_input = 'Relative Volume'
var int volume_len = input.int(title = 'Relative Volume Length', defval = 20,  minval = 1, group = group_volume_input)
var int rvolume_unusual = input.int(title = 'Unusual Percent', defval = 200, minval = 1, group = group_volume_input)
var color rvolume_unusual_color = input.color(title = 'Unusual Color', defval = color.green, group = group_volume_input)
var int rvolume_high = input.int(title = 'High Percent', defval = 100, minval = 1, group = group_volume_input)
var color rvolume_high_color = input.color(title = 'High Color', defval = color.yellow, group = group_volume_input)
var color rvolume_low_color = input.color(title = 'Low Color', defval = color.silver, group = group_volume_input)

// Validate relative volume inputs
if rvolume_unusual <= rvolume_high
    runtime.error('Validation Error: Relative Volume: Unusual Percent must be greater than High Percent')

// Relative Range inputs
var string group_range_input = 'Relative Range'
var int atr_len = input.int(title = 'ATR Length', defval = 14, minval = 1, group = group_range_input)
var string atr_smooth = input.string(title = 'Smoothing Type', defval = 'RMA', options = ['EMA', 'RMA', 'SMA', 'WMA'], group = group_range_input)
var int rrange_high = input.int(title = 'High Percent', defval = 90, minval = 1, group = group_range_input)
var color rrange_high_color = input.color(title = 'High Color', defval = color.red, group = group_range_input)
var int rrange_normal = input.int(title = 'Normal Percent', defval = 50, minval = 1, group = group_range_input)
var color rrange_normal_color = input.color(title = 'Normal Color', defval = color.yellow, group = group_range_input)
var color rrange_low_color = input.color(title = 'Low Color', defval = color.silver, group = group_range_input)

// Validate relative range inputs
if rrange_high <= rrange_normal
    runtime.error('Validation Error: Relative Range: High Percent must be greater than Normal Percent')

// Get timeframe for request.security
var tf = if timeframe.isweekly
    'W'
else if timeframe.ismonthly
    'M'
else
    'D'

// Calculate average volume by bar length over a timeframe
volume_today = request.security(syminfo.tickerid, tf, volume)
volume_yesterday = request.security(syminfo.tickerid, tf, volume[1])
volume_average = request.security(syminfo.tickerid, tf, ta.sma(volume_yesterday, volume_len))

// Calculate relative volume as a percentage
rvolume = math.round(volume_today / volume_average * 100)

// Determine relative volume color
rvolume_color = if rvolume < rvolume_high
    rvolume_low_color
else if rvolume < rvolume_unusual
    rvolume_high_color
else
    rvolume_unusual_color

// @function Return a volume string rounded to two decimal places with a B, M, or K suffix
volumeString(value) =>
    if value > 1000000000
        str.format('{0,number,#.##}B', value / 1000000000)
    else if value > 1000000
        str.format('{0,number,#.##}M', value / 1000000)
    else if value > 1000
        str.format('{0,number,#.##}K', value / 1000)
    else
        str.format('{0}', value)

// Calculate Average True Range (ATR) by smoothing type and bar length
atr_expression = switch atr_smooth
    'EMA' => ta.ema(ta.tr, atr_len)
    'RMA' => ta.rma(ta.tr, atr_len)
    'SMA' => ta.sma(ta.tr, atr_len)
    'WMA' => ta.wma(ta.tr, atr_len)

// Calculate Average True Range (ATR) and Daily True Range (DTR) by bar length over a timeframe
atr = request.security(syminfo.tickerid, tf, atr_expression, lookahead = barmerge.lookahead_on)
dtr = request.security(syminfo.tickerid, tf, high) - request.security(syminfo.tickerid, tf, low)

// Calculate relative range as a percentage
rrange = math.round(dtr / atr * 100)

// Determine relative range color
rrange_color = if rrange < rrange_normal
    rrange_low_color
else if rrange < rrange_high
    rrange_normal_color
else
    rrange_high_color

// Display output data in a table
// Optimize by only displaying table on last bar
var table display = table.new(position = table_pos, columns = 4, rows = 2, border_color = color.black, border_width = 1)
if barstate.islast
    // Relative Volume
    table.cell(display, 0, 0, str.format('RVol({0}{1})', volume_len, tf), bgcolor = rvolume_color, text_size = text_size, text_halign = text.align_left)
    table.cell(display, 1, 0, str.format('{0}', volumeString(volume_today)), bgcolor = rvolume_color, text_size = text_size)
    table.cell(display, 2, 0, str.format('{0}', volumeString(volume_average)), bgcolor = rvolume_color, text_size = text_size)
    table.cell(display, 3, 0, str.format('{0}%', rvolume), bgcolor = rvolume_color, text_size = text_size)

    // Relative Range
    table.cell(display, 0, 1, str.format('RRange({0}{1})', atr_len, tf), bgcolor = rrange_color, text_size = text_size, text_halign = text.align_left)
    table.cell(display, 1, 1, str.format('{0,number,#.##}', dtr), bgcolor = rrange_color, text_size = text_size)
    table.cell(display, 2, 1, str.format('{0,number,#.##}', atr), bgcolor = rrange_color, text_size = text_size)
    table.cell(display, 3, 1, str.format('{0}%', rrange), bgcolor = rrange_color, text_size = text_size)
````
