# Moving Average MTF

- url: https://www.tradingview.com/script/LcLuynvf-Moving-Average-MTF/
- type: indicator
- pine_id: PUB;219f6ad5a9064b9398406e9fe299a682
- version: 6.0

## Description

**Moving Average MTF (Multi-Timeframe)**

This indicator plots three fully customizable moving averages, each calculated from an independent timeframe of your choice. Instead of being limited to the timeframe of your chart, each MA pulls data directly from its assigned timeframe — giving you a layered view of trend across multiple time horizons simultaneously.

By default the three MAs are set to 15 minutes, 1 hour, and 4 hours, all using a 50-period SMA. This makes the indicator best suited for use on a 5-minute chart, where all three timeframes sit above your chart and give you a clear short, medium, and macro trend stack in a single view.

---

**Settings**

Each of the three MAs has its own independent group of controls:

- **Show MA** — Toggles the MA line on or off without removing it from the settings.
- **Show Label** — Toggles the end-of-line label that appears to the right of the last candle. The label displays the MA type, length, timeframe, and current value.
- **Length** — The number of candles used to calculate the MA, based on its assigned timeframe. Default is 50 for all three.
- **Timeframe** — The timeframe the MA is calculated from, regardless of what timeframe your chart is on. You can type any valid timeframe directly into this field.
- **Type** — The moving average algorithm. Choose from SMA, EMA, WMA, VWMA, RMA, or HMA.
- **Line Style** — Choose between Solid, Stepline, or Circles.
- **Line Thickness** — Controls the width of the line from 1 to 10.
- **Color** — Full color picker to set each MA to any color you prefer.

---

**How to Use**

Keep your chart timeframe at or below the lowest MA timeframe you have set. With the defaults of 15min, 1h, and 4h, running the indicator on a 5-minute chart gives you the most meaningful read. When all three MAs are stacked and sloping in the same direction, trend is aligned across all three timeframes — the highest conviction environment for a trade. When they are tangled or conflicting, the market is in an indecisive state and it is generally best to wait for clarity.

---

**Important Note**

If your chart timeframe is higher than any of the MA timeframes you have set, that MA will still display but the value will not be meaningful. The indicator will not produce errors — it is purely a logical consideration. Always ensure your chart timeframe sits below your lowest MA timeframe for accurate results.

## Source Code

````pine
//@version=6
indicator('Moving Average MTF', overlay = true)

ma(source, length, type) =>
    switch type
        'SMA' => ta.sma(source, length)
        'EMA' => ta.ema(source, length)
        'WMA' => ta.wma(source, length)
        'VWMA' => ta.vwma(source, length)
        'RMA' => ta.rma(source, length)
        'HMA' => ta.hma(source, length)
        => ta.sma(source, length)

lineStyle(style) =>
    switch style
        'Solid'     => plot.style_line
        'Stepline'  => plot.style_stepline
        'Circles'   => plot.style_circles
        => plot.style_line

labelSize(s) =>
    switch s
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        'Large'  => size.large
        => size.tiny

tfLabel(tf) =>
    switch tf
        '1'   => '1m'
        '3'   => '3m'
        '5'   => '5m'
        '15'  => '15m'
        '30'  => '30m'
        '60'  => '1h'
        '120' => '2h'
        '240' => '4h'
        '720' => '12h'
        'D'   => '1D'
        'W'   => '1W'
        'M'   => '1M'
        => tf

// ─────────────────────────────────────
// Non-Repaint
// ─────────────────────────────────────
noRepaint = input.bool(true, 'Non-Repaint', group = 'Non-Repaint')

// ─────────────────────────────────────
// Global Label Settings
// ─────────────────────────────────────
showLabels = input.bool(true, 'Show Labels',  group = 'Labels')
showPrice  = input.bool(true, 'Show Price',   group = 'Labels')
lblSize    = input.string('Small', 'Label Size', group = 'Labels', options = ['Tiny', 'Small', 'Normal', 'Large'])
lblOffset  = input.int(2, 'Label Offset', group = 'Labels', minval = 0, maxval = 50)

// ─────────────────────────────────────
// MA 1 Inputs
// ─────────────────────────────────────
showMA1  = input.bool(true, 'Show MA 1', group = 'MA 1')
lenMA1   = input.int(200, 'MA 1 Length', group = 'MA 1', minval = 1)
tfMA1    = input.timeframe('5', 'MA 1 Timeframe', group = 'MA 1')
typeMA1  = input.string('SMA', 'MA 1 Type', group = 'MA 1', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'RMA', 'HMA'])
styleMA1 = input.string('Solid', 'MA 1 Line Style', group = 'MA 1', options = ['Solid', 'Stepline', 'Circles'])
widthMA1 = input.int(2, 'MA 1 Line Thickness', group = 'MA 1', minval = 1, maxval = 10)
colorMA1 = input.color(color.blue, 'MA 1 Color', group = 'MA 1')

// ─────────────────────────────────────
// MA 2 Inputs
// ─────────────────────────────────────
showMA2  = input.bool(true, 'Show MA 2', group = 'MA 2')
lenMA2   = input.int(200, 'MA 2 Length', group = 'MA 2', minval = 1)
tfMA2    = input.timeframe('15', 'MA 2 Timeframe', group = 'MA 2')
typeMA2  = input.string('SMA', 'MA 2 Type', group = 'MA 2', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'RMA', 'HMA'])
styleMA2 = input.string('Solid', 'MA 2 Line Style', group = 'MA 2', options = ['Solid', 'Stepline', 'Circles'])
widthMA2 = input.int(3, 'MA 2 Line Thickness', group = 'MA 2', minval = 1, maxval = 10)
colorMA2 = input.color(color.orange, 'MA 2 Color', group = 'MA 2')

// ─────────────────────────────────────
// MA 3 Inputs
// ─────────────────────────────────────
showMA3  = input.bool(true, 'Show MA 3', group = 'MA 3')
lenMA3   = input.int(200, 'MA 3 Length', group = 'MA 3', minval = 1)
tfMA3    = input.timeframe('30', 'MA 3 Timeframe', group = 'MA 3')
typeMA3  = input.string('SMA', 'MA 3 Type', group = 'MA 3', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'RMA', 'HMA'])
styleMA3 = input.string('Solid', 'MA 3 Line Style', group = 'MA 3', options = ['Solid', 'Stepline', 'Circles'])
widthMA3 = input.int(4, 'MA 3 Line Thickness', group = 'MA 3', minval = 1, maxval = 10)
colorMA3 = input.color(color.purple, 'MA 3 Color', group = 'MA 3')

// ─────────────────────────────────────
// MA 4 Inputs
// ─────────────────────────────────────
showMA4  = input.bool(false, 'Show MA 4', group = 'MA 4')
lenMA4   = input.int(200, 'MA 4 Length', group = 'MA 4', minval = 1)
tfMA4    = input.timeframe('60', 'MA 4 Timeframe', group = 'MA 4')
typeMA4  = input.string('SMA', 'MA 4 Type', group = 'MA 4', options = ['SMA', 'EMA', 'WMA', 'VWMA', 'RMA', 'HMA'])
styleMA4 = input.string('Solid', 'MA 4 Line Style', group = 'MA 4', options = ['Solid', 'Stepline', 'Circles'])
widthMA4 = input.int(5, 'MA 4 Line Thickness', group = 'MA 4', minval = 1, maxval = 10)
colorMA4 = input.color(color.black, 'MA 4 Color', group = 'MA 4')

// ─────────────────────────────────────
// MTF Calculations
// ─────────────────────────────────────
ma1Raw = noRepaint ? request.security(syminfo.tickerid, tfMA1, ma(close, lenMA1, typeMA1)[1], lookahead = barmerge.lookahead_on) : request.security(syminfo.tickerid, tfMA1, ma(close, lenMA1, typeMA1), lookahead = barmerge.lookahead_off)
ma2Raw = noRepaint ? request.security(syminfo.tickerid, tfMA2, ma(close, lenMA2, typeMA2)[1], lookahead = barmerge.lookahead_on) : request.security(syminfo.tickerid, tfMA2, ma(close, lenMA2, typeMA2), lookahead = barmerge.lookahead_off)
ma3Raw = noRepaint ? request.security(syminfo.tickerid, tfMA3, ma(close, lenMA3, typeMA3)[1], lookahead = barmerge.lookahead_on) : request.security(syminfo.tickerid, tfMA3, ma(close, lenMA3, typeMA3), lookahead = barmerge.lookahead_off)
ma4Raw = noRepaint ? request.security(syminfo.tickerid, tfMA4, ma(close, lenMA4, typeMA4)[1], lookahead = barmerge.lookahead_on) : request.security(syminfo.tickerid, tfMA4, ma(close, lenMA4, typeMA4), lookahead = barmerge.lookahead_off)

// ─────────────────────────────────────
// Plots
// ─────────────────────────────────────
plot(showMA1 ? ma1Raw : na, title = 'MA 1', color = colorMA1, linewidth = math.max(1, widthMA1), style = lineStyle(styleMA1), editable = false)
plot(showMA2 ? ma2Raw : na, title = 'MA 2', color = colorMA2, linewidth = math.max(1, widthMA2), style = lineStyle(styleMA2), editable = false)
plot(showMA3 ? ma3Raw : na, title = 'MA 3', color = colorMA3, linewidth = math.max(1, widthMA3), style = lineStyle(styleMA3), editable = false)
plot(showMA4 ? ma4Raw : na, title = 'MA 4', color = colorMA4, linewidth = math.max(1, widthMA4), style = lineStyle(styleMA4), editable = false)

// ─────────────────────────────────────
// Persistent End-of-Line Labels
// ─────────────────────────────────────
var label ma1Label = na
var label ma2Label = na
var label ma3Label = na
var label ma4Label = na

maLabelText(maType, maLen, maTf, maVal) =>
    base = maType + str.tostring(maLen) + ' (' + tfLabel(maTf) + ')'
    showPrice ? base + '\n' + str.tostring(maVal, format.mintick) : base

if barstate.islast
    sz = labelSize(lblSize)

    // MA 1
    if showLabels and showMA1 and not na(ma1Raw)
        ma1Text = maLabelText(typeMA1, lenMA1, tfMA1, ma1Raw)
        if na(ma1Label)
            ma1Label := label.new(x = bar_index + lblOffset, y = ma1Raw, text = ma1Text, color = colorMA1, textcolor = color.white, style = label.style_label_left, size = sz)
        else
            label.set_text(ma1Label, ma1Text)
            label.set_y(ma1Label, ma1Raw)
            label.set_x(ma1Label, bar_index + lblOffset)
            label.set_color(ma1Label, colorMA1)
            label.set_size(ma1Label, sz)
    else
        if not na(ma1Label)
            label.delete(ma1Label)
            ma1Label := na

    // MA 2
    if showLabels and showMA2 and not na(ma2Raw)
        ma2Text = maLabelText(typeMA2, lenMA2, tfMA2, ma2Raw)
        if na(ma2Label)
            ma2Label := label.new(x = bar_index + lblOffset, y = ma2Raw, text = ma2Text, color = colorMA2, textcolor = color.white, style = label.style_label_left, size = sz)
        else
            label.set_text(ma2Label, ma2Text)
            label.set_y(ma2Label, ma2Raw)
            label.set_x(ma2Label, bar_index + lblOffset)
            label.set_color(ma2Label, colorMA2)
            label.set_size(ma2Label, sz)
    else
        if not na(ma2Label)
            label.delete(ma2Label)
            ma2Label := na

    // MA 3
    if showLabels and showMA3 and not na(ma3Raw)
        ma3Text = maLabelText(typeMA3, lenMA3, tfMA3, ma3Raw)
        if na(ma3Label)
            ma3Label := label.new(x = bar_index + lblOffset, y = ma3Raw, text = ma3Text, color = colorMA3, textcolor = color.white, style = label.style_label_left, size = sz)
        else
            label.set_text(ma3Label, ma3Text)
            label.set_y(ma3Label, ma3Raw)
            label.set_x(ma3Label, bar_index + lblOffset)
            label.set_color(ma3Label, colorMA3)
            label.set_size(ma3Label, sz)
    else
        if not na(ma3Label)
            label.delete(ma3Label)
            ma3Label := na

    // MA 4
    if showLabels and showMA4 and not na(ma4Raw)
        ma4Text = maLabelText(typeMA4, lenMA4, tfMA4, ma4Raw)
        if na(ma4Label)
            ma4Label := label.new(x = bar_index + lblOffset, y = ma4Raw, text = ma4Text, color = colorMA4, textcolor = color.white, style = label.style_label_left, size = sz)
        else
            label.set_text(ma4Label, ma4Text)
            label.set_y(ma4Label, ma4Raw)
            label.set_x(ma4Label, bar_index + lblOffset)
            label.set_color(ma4Label, colorMA4)
            label.set_size(ma4Label, sz)
    else
        if not na(ma4Label)
            label.delete(ma4Label)
            ma4Label := na
````
