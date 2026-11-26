# Session Liquidity Deviation Matrix 

- url: https://www.tradingview.com/script/PCDI1JyH-Session-Liquidity-Deviation-Matrix/
- type: indicator
- pine_id: PUB;55e32441ceb24f5689a2ba558c54adb4
- version: 2.0

## Description

Plots standard deviations in the color in which market session they were created. Also allows deviation lines to be extended. User can control colors, opacity, etc. In the settings you can toggle which SD's you want to see by unclicking the TW1, TW2, or TW3.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// by Brian Cunningham
//@version=6
indicator('Session Liquidity Deviation Matrix', shorttitle = 'Sess Liq Dev', overlay = true, max_bars_back = 500, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)


//#region[User Inputs]
dvs = input.text_area('0\n1\n-1\n-1.5\n-2\n-2.5\n-3.25\n-4\n-5\n-6', title = 'Insert the Deviations you want to plot, one per line:')
label_size = input.string('Small', title = 'Label Size', options = ['Auto', 'Tiny', 'Small', 'Normal', 'Large', 'Huge'], inline = 'lbl')
lbl = input.bool(false, title = 'Hide Labels?', inline = 'lbl')
extend_mode = input.string("None", title="Line Extension Mode", options=["None", "Left", "Right", "Both"])

asiaSession  = input.session("1800-0200", "Asia Session")
londonSession = input.session("0200-0800", "London Session")
nySession    = input.session("0800-1700", "New York Session")

asiaColor  = input.color(color.new(color.orange, 0), "Asia Color")
londonColor = input.color(color.new(color.green, 0), "London Color")
nyColor    = input.color(color.new(color.blue, 0), "NY Color")

MLB = input.bool(true, title = 'Monthly', group = 'Fractal  Lookback', inline = 'M')
lMTF = input.timeframe('D', title = '', group = 'Fractal  Lookback', inline = 'M')
hMTF = input.timeframe('D', title = '', group = 'Fractal  Lookback', inline = 'M')
WLB = input.bool(true, title = 'Weekly ', group = 'Fractal  Lookback', inline = 'W')
lWTF = input.timeframe('240', title = '', group = 'Fractal  Lookback', inline = 'W')
hWTF = input.timeframe('480', title = '', group = 'Fractal  Lookback', inline = 'W')
DLB = input.bool(true, title = 'Daily     ', group = 'Fractal  Lookback', inline = 'D')
lDTF = input.timeframe('15', title = '', group = 'Fractal  Lookback', inline = 'D')
hDTF = input.timeframe('60', title = '', group = 'Fractal  Lookback', inline = 'D')
ILB = input.bool(true, title = 'Intraday', group = 'Fractal  Lookback', inline = 'I')
lITF = input.timeframe('1', title = '', group = 'Fractal  Lookback', inline = 'I')
hITF = input.timeframe('5', title = '', group = 'Fractal  Lookback', inline = 'I')
intraday_tf = input.string('60', title = 'Intraday Anchor Timeframe', options = ['15', '30', '60', '120', '240'], group = 'Fractal  Lookback')

remove = input.bool(true, title = 'Remove Deviations Once Invalidated?', group = 'Standard Deviations', tooltip = 'Once the \'1\' anchor price line is traded above/below the Deviation will disappear.')
tw3_up = input.bool(true, title = 'TW3 Up     ', group = 'Standard Deviations', inline = 'UP')
tw2_up = input.bool(true, title = 'TW2 Up    ', group = 'Standard Deviations', inline = 'UP')
tw1_up = input.bool(true, title = 'TW1 Up', group = 'Standard Deviations', inline = 'UP')
tw3_dw = input.bool(true, title = 'TW3 Down', group = 'Standard Deviations', inline = 'DW')
tw2_dw = input.bool(true, title = 'TW2 Down', group = 'Standard Deviations', inline = 'DW')
tw1_dw = input.bool(true, title = 'TW1 Down', group = 'Standard Deviations', inline = 'DW')
//#endregion


//#region[Global]
getSessionColor() =>
    sessA = not na(time(timeframe.period, asiaSession))
    sessL = not na(time(timeframe.period, londonSession))
    sessN = not na(time(timeframe.period, nySession))

    sessA ? asiaColor :
     sessL ? londonColor :
     sessN ? nyColor :
     chart.fg_color

noColor = color.new(color.white, 100)
midnight = hour(time, 'America/New_York') == 0 and hour(time[1], 'America/New_York') != 0

size(string _size) =>
    size = switch _size
        'Tiny' => size.tiny
        'Small' => size.small
        'Normal' => size.normal
        'Large' => size.large
        'Huge' => size.huge
    size

getExtend(string mode) =>
    switch mode
        "Left"  => extend.left
        "Right" => extend.right
        "Both"  => extend.both
        => extend.none

tfRange(string LOW, string HIGH) =>
    timeframe.in_seconds(timeframe.period) >= timeframe.in_seconds(LOW) and timeframe.in_seconds(timeframe.period) <= timeframe.in_seconds(HIGH)

var deviations = array.new_float()
array<string> chrs = str.split(dvs, '')
if deviations.size() == 0 and chrs.size() > 0
    var string num = ''
    for i = 0 to chrs.size() - 1 by 1
        c = chrs.get(i)
        if chrs.get(i) == '\n'
            deviations.unshift(str.tonumber(num))
            num := ''
            num
        else
            num := num + c
            num
    deviations.unshift(str.tonumber(num))
    //#endregion


//#region[Functions & Types]
type StandardDev
	string side
	array<line> lines
	array<label> labels

type TimeWindow
	chart.point h
	chart.point h_stl
	chart.point l
	chart.point l_sth
	line edge
	StandardDev up
	StandardDev dw
    color col

swing_high_point(chart.point prev) =>
    if high < high[1] and high[1] > high[2] or high <= high[1] and high[1] > high[2] or high < high[1] and high[1] >= high[2]
        chart.point.from_time(time[1], high[1])
    else
        prev

swing_low_point(chart.point prev) =>
    if low > low[1] and low[1] < low[2] or low >= low[1] and low[1] < low[2] or low > low[1] and low[1] <= low[2]
        chart.point.from_time(time[1], low[1])
    else
        prev

method delete(StandardDev DV) =>
    lines = DV.lines
    if lines.size() > 0
        for i = lines.size() - 1 to 0 by 1
            line.delete(lines.get(i))
        lines.clear()

    labels = DV.labels
    if labels.size() > 0
        for i = labels.size() - 1 to 0 by 1
            label.delete(labels.get(i))
        labels.clear()

method plotStandardDev(TimeWindow TW) =>
    col = TW.col

    StandardDev stdev_up = StandardDev.new('UP', array.new_line(), array.new_label())
    StandardDev stdev_dw = StandardDev.new('DW', array.new_line(), array.new_label())

    if not na(TW.h) and not na(TW.h_stl)
        rxh = TW.h.time
        lxh = TW.h_stl.time
        zyh = TW.h_stl.price
        yh = TW.h.price - zyh

        // DOWN anchor 1
        stdev_dw.lines.unshift(line.new(
            lxh,
            TW.h.price,
            rxh,
            TW.h.price,
            xloc.bar_time,
            extend = getExtend(extend_mode),
            color = col
        ))

        stdev_dw.labels.unshift(label.new(
            rxh,
            TW.h.price,
            '1',
            xloc.bar_time,
            color = noColor,
            style = label.style_label_left,
            textcolor = not lbl ? col : noColor,
            size = size(label_size),
            text_font_family = font.family_monospace
        ))

        // DOWN anchor 0
        stdev_dw.lines.unshift(line.new(
            lxh,
            zyh,
            rxh,
            zyh,
            xloc.bar_time,
            extend = getExtend(extend_mode),
            color = col
        ))

        stdev_dw.labels.unshift(label.new(
            rxh,
            zyh,
            '0',
            xloc.bar_time,
            color = noColor,
            style = label.style_label_left,
            textcolor = not lbl ? col : noColor,
            size = size(label_size),
            text_font_family = font.family_monospace
        ))

        // DOWN deviations
        for dv = 0 to deviations.size() - 1 by 1
            dev = deviations.get(dv)
            price = zyh + yh * dev

            stdev_dw.lines.unshift(line.new(
                lxh,
                price,
                rxh,
                price,
                xloc.bar_time,
                extend = getExtend(extend_mode),
                color = col
            ))

            stdev_dw.labels.unshift(label.new(
                rxh,
                price,
                str.tostring(dev),
                xloc.bar_time,
                color = noColor,
                style = label.style_label_left,
                textcolor = not lbl ? col : noColor,
                size = size(label_size),
                text_font_family = font.family_monospace
            ))

    if not na(TW.l) and not na(TW.l_sth)
        rxl = TW.l.time
        lxl = TW.l_sth.time
        zyl = TW.l_sth.price
        yl = zyl - TW.l.price

        // UP anchor 1
        stdev_up.lines.unshift(line.new(
            lxl,
            TW.l.price,
            rxl,
            TW.l.price,
            xloc.bar_time,
            extend = getExtend(extend_mode),
            color = col
        ))

        stdev_up.labels.unshift(label.new(
            rxl,
            TW.l.price,
            '1',
            xloc.bar_time,
            color = noColor,
            style = label.style_label_left,
            textcolor = not lbl ? col : noColor,
            size = size(label_size),
            text_font_family = font.family_monospace
        ))

        // UP anchor 0
        stdev_up.lines.unshift(line.new(
            lxl,
            zyl,
            rxl,
            zyl,
            xloc.bar_time,
            extend = getExtend(extend_mode),
            color = col
        ))

        stdev_up.labels.unshift(label.new(
            rxl,
            zyl,
            '0',
            xloc.bar_time,
            color = noColor,
            style = label.style_label_left,
            textcolor = not lbl ? col : noColor,
            size = size(label_size),
            text_font_family = font.family_monospace
        ))

        // UP deviations
        for dv = 0 to deviations.size() - 1 by 1
            dev = deviations.get(dv)
            price = zyl - yl * dev

            stdev_up.lines.unshift(line.new(
                lxl,
                price,
                rxl,
                price,
                xloc.bar_time,
                extend = getExtend(extend_mode),
                color = col
            ))

            stdev_up.labels.unshift(label.new(
                rxl,
                price,
                str.tostring(dev),
                xloc.bar_time,
                color = noColor,
                style = label.style_label_left,
                textcolor = not lbl ? col : noColor,
                size = size(label_size),
                text_font_family = font.family_monospace
            ))

    TW.up := stdev_up
    TW.dw := stdev_dw
    TW.dw
method delete(TimeWindow TW) =>
    line.delete(TW.edge)
    TW.up.delete()
    TW.dw.delete()

method removeDev(array<TimeWindow> A) =>
    if A.size() > 0
        for i = 0 to A.size() - 1 by 1
            tw = A.get(i)
            if not na(tw.up)
                if tw.up.lines.size() > 0
                    if low < tw.up.lines.last().get_y1()
                        tw.up.delete()
            if not na(tw.dw)
                if tw.dw.lines.size() > 0
                    if high > tw.dw.lines.last().get_y1()
                        tw.dw.delete()

method hideDev(array<TimeWindow> A, int N, bool UP, bool DW) =>
    if A.size() > N
        tw = A.get(N)
        if not na(tw.up)
            if tw.up.lines.size() > 0
                for i = 0 to tw.up.lines.size() - 1 by 1
                    _line = tw.up.lines.get(i)
                    _label = tw.up.labels.get(i)
                    if UP
                        _line.set_color(tw.col)
                        if not lbl
                            _label.set_textcolor(tw.col)
                    else
                        _line.set_color(noColor)
                        _label.set_textcolor(noColor)

        if not na(tw.dw)
            if tw.dw.lines.size() > 0
                for i = 0 to tw.dw.lines.size() - 1 by 1
                    _line = tw.dw.lines.get(i)
                    _label = tw.dw.labels.get(i)
                    if DW
                        _line.set_color(tw.col)
                        if not lbl
                            _label.set_textcolor(tw.col)
                    else
                        _line.set_color(noColor)
                        _label.set_textcolor(noColor)
                        //#endregion


//#region[Find & Plot]
var TWA = array.new<TimeWindow>()
TF = if MLB and tfRange(lMTF, hMTF)
    'M'
else if WLB and tfRange(lWTF, hWTF)
    'W'
else if DLB and tfRange(lDTF, hDTF)
    'D'
else if ILB and tfRange(lITF, hITF)
    intraday_tf

var chart.point prev_h_stl = na
var chart.point prev_l_sth = na
prev_h_stl := swing_low_point(prev_h_stl)
prev_l_sth := swing_high_point(prev_l_sth)

TimeWindow tw = na
if TWA.size() > 0
    tw := TWA.first()

// FIX: separate ternary into variable (IMPORTANT)
tfChange = TF == 'D' ? midnight : timeframe.change(TF)

if tfChange
    if not na(tw)
        tw.plotStandardDev()

        if TWA.size() > 10
            TWA.pop().delete()

    edgeLine = line.new(
        time,
        low,
        time,
        high,
        xloc.bar_time,
        extend.both,
        color.new(chart.fg_color, 50),
        line.style_dotted
    )    

    TWA.unshift(TimeWindow.new(
        chart.point.from_time(time, high),
        na,
        chart.point.from_time(time, low),
        na,
        edgeLine,
        na,
        na,
        getSessionColor()
    ))

else if not na(tw)
    if math.max(tw.h.price, high) == high
        tw.h := chart.point.from_time(time, high)
        tw.h_stl := na(prev_h_stl) ? tw.h_stl : prev_h_stl
        tw.h_stl

    if math.min(tw.l.price, low) == low
        tw.l := chart.point.from_time(time, low)
        tw.l_sth := na(prev_l_sth) ? tw.l_sth : prev_l_sth
        tw.l_sth
        //#endregion


//#region[Hide & Remove]
TWA.hideDev(1, tw1_up, tw1_dw)
TWA.hideDev(2, tw2_up, tw2_dw)
TWA.hideDev(3, tw3_up, tw3_dw)

if remove
    TWA.removeDev()
//#endregion
````
