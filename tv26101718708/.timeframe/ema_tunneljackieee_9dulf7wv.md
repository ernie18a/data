# EMA TUNNEL[jackieee]

- url: https://www.tradingview.com/script/9DULf7wV-EMA-TUNNEL-jackieee/
- type: indicator
- pine_id: PUB;e6fbff23460d4ce594cc61cd3ebb662f
- version: 1.0

## Description

EMA TUNNEL [jackieee] is a multi-timeframe EMA band indicator based on the Vegas Tunnel concept. It uses three main EMA groups to form trend bands, helping traders identify broader market direction, dynamic support and resistance zones, and potential trend continuation or reversal areas. The indicator also allows the tunnel to be calculated from a selected base timeframe, such as 1D, while displayed on any chart timeframe.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © jackieeeeeeeee

plot(close)
//@version=6
indicator(title='EMA TUNNEL[jackieee]', shorttitle='EMA TUNNEL[jackieee]', overlay=true, max_labels_count=500, max_lines_count=500)

// =====================================================
// MTF Settings
// =====================================================
base_tf = input.timeframe(title='Base timeframe for MA calculation', defval='D', group='MTF Settings', tooltip='Example: D = Daily based. If you view weekly chart, the tunnel is still calculated from daily candles.')

// =====================================================
// Utility
// =====================================================
strRoundValue(num) =>
    strv = ''
    if num >= 100000
        strv := str.tostring(num / 1000, '#K')
    else if num < 100000 and num >= 100
        strv := str.tostring(num, '#')
    else if num < 100 and num >= 1
        strv := str.tostring(num, '#.##')
    else if num < 1 and num >= 0.01
        strv := str.tostring(num, '#.####')
    else if num < 0.01 and num >= 0.0001
        strv := str.tostring(num, '#.######')
    else if num < 0.0001 and num >= 0.000001
        strv := str.tostring(num, '#.########')
    strv

maFunction(func, src, len, alma_offst, alma_sigma) =>
    float ma = na
    bool has_len = true

    if func == 'ALMA'
        ma := ta.alma(src, len, alma_offst, alma_sigma)
        has_len := true
    else if func == 'EMA'
        ma := ta.ema(src, len)
        has_len := true
    else if func == 'RMA'
        ma := ta.rma(src, len)
        has_len := true
    else if func == 'SMA'
        ma := ta.sma(src, len)
        has_len := true
    else if func == 'SWMA'
        ma := ta.swma(src)
        has_len := false
    else if func == 'VWAP'
        ma := ta.vwap(src)
        has_len := false
    else if func == 'VWMA'
        ma := ta.vwma(src, len)
        has_len := true
    else if func == 'WMA'
        ma := ta.wma(src, len)
        has_len := true

    [ma, has_len]

// =====================================================
// Inputs
// =====================================================
def_fn = input.string(title='Default moving average', defval='EMA', options=['ALMA', 'EMA', 'RMA', 'SMA', 'SWMA', 'VWAP', 'VWMA', 'WMA'])

ma1_on = input.bool(inline='MA1', title='Enable moving average 1', defval=true)
ma2_on = input.bool(inline='MA2', title='Enable moving average 2', defval=true)
ma3_on = input.bool(inline='MA3', title='Enable moving average 3', defval=true)
ma4_on = input.bool(inline='MA4', title='Enable moving average 4', defval=true)
ma5_on = input.bool(inline='MA5', title='Enable moving average 5', defval=true)
ma6_on = input.bool(inline='MA6', title='Enable moving average 6', defval=true)
ma7_on = input.bool(inline='MA7', title='Enable moving average 7', defval=true)

ma1_fn = input.string(inline='MA1', title='', defval='default', options=['default', 'ALMA', 'EMA', 'RMA', 'SMA', 'SWMA', 'VWAP', 'VWMA', 'WMA'])
ma2_fn = input.string(inline='MA2', title='', defval='default', options=['default', 'ALMA', 'EMA', 'RMA', 'SMA', 'SWMA', 'VWAP', 'VWMA', 'WMA'])
ma3_fn = input.string(inline='MA3', title='', defval='default', options=['default', 'ALMA', 'EMA', 'RMA', 'SMA', 'SWMA', 'VWAP', 'VWMA', 'WMA'])
ma4_fn = input.string(inline='MA4', title='', defval='default', options=['default', 'ALMA', 'EMA', 'RMA', 'SMA', 'SWMA', 'VWAP', 'VWMA', 'WMA'])
ma5_fn = input.string(inline='MA5', title='', defval='default', options=['default', 'ALMA', 'EMA', 'RMA', 'SMA', 'SWMA', 'VWAP', 'VWMA', 'WMA'])
ma6_fn = input.string(inline='MA6', title='', defval='default', options=['default', 'ALMA', 'EMA', 'RMA', 'SMA', 'SWMA', 'VWAP', 'VWMA', 'WMA'])
ma7_fn = input.string(inline='MA7', title='', defval='default', options=['default', 'ALMA', 'EMA', 'RMA', 'SMA', 'SWMA', 'VWAP', 'VWMA', 'WMA'])

ma1_len = input.int(inline='MA1', title='', defval=12, minval=1)
ma2_len = input.int(inline='MA2', title='', defval=144, minval=1)
ma3_len = input.int(inline='MA3', title='', defval=169, minval=1)
ma4_len = input.int(inline='MA4', title='', defval=288, minval=1)
ma5_len = input.int(inline='MA5', title='', defval=338, minval=1)
ma6_len = input.int(inline='MA6', title='', defval=576, minval=1)
ma7_len = input.int(inline='MA7', title='', defval=676, minval=1)

ma1_clr = input.color(inline='MA1', title='', defval=color.fuchsia)
ma2_clr = input.color(inline='MA2', title='', defval=color.aqua)
ma3_clr = input.color(inline='MA3', title='', defval=color.yellow)
ma4_clr = input.color(inline='MA4', title='', defval=color.blue)
ma5_clr = input.color(inline='MA5', title='', defval=color.orange)
ma6_clr = input.color(inline='MA6', title='', defval=color.green)
ma7_clr = input.color(inline='MA7', title='', defval=color.red)

alma1_offst = input.float(group='MA1 other settings', inline='MA11', title='ALMA offset', defval=0.85, minval=-1, maxval=1, step=0.01)
alma1_sigma = input.float(group='MA1 other settings', inline='MA11', title=', sigma', defval=6, minval=0, maxval=100, step=0.01)
ma1_src = input.source(group='MA1 other settings', inline='MA12', title='Source', defval=close)
ma1_plt_offst = input.int(group='MA1 other settings', inline='MA12', title=', plot offset', defval=0, minval=-500, maxval=500)

alma2_offst = input.float(group='MA2 other settings', inline='MA21', title='ALMA Offset', defval=0.85, minval=-1, maxval=1, step=0.01)
alma2_sigma = input.float(group='MA2 other settings', inline='MA21', title='Sigma', defval=6, minval=0, maxval=100, step=0.01)
ma2_src = input.source(group='MA2 other settings', inline='MA22', title='Source', defval=close)
ma2_plt_offst = input.int(group='MA2 other settings', inline='MA22', title='Plot offset', defval=0, minval=-500, maxval=500)

alma3_offst = input.float(group='MA3 other settings', inline='MA31', title='ALMA Offset', defval=0.85, minval=-1, maxval=1, step=0.01)
alma3_sigma = input.float(group='MA3 other settings', inline='MA31', title='Sigma', defval=6, minval=0, maxval=100, step=0.01)
ma3_src = input.source(group='MA3 other settings', inline='MA32', title='Source', defval=close)
ma3_plt_offst = input.int(group='MA3 other settings', inline='MA32', title='Plot offset', defval=0, minval=-500, maxval=500)

alma4_offst = input.float(group='MA4 other settings', inline='MA41', title='ALMA Offset', defval=0.85, minval=-1, maxval=1, step=0.01)
alma4_sigma = input.float(group='MA4 other settings', inline='MA41', title='Sigma', defval=6, minval=0, maxval=100, step=0.01)
ma4_src = input.source(group='MA4 other settings', inline='MA42', title='Source', defval=close)
ma4_plt_offst = input.int(group='MA4 other settings', inline='MA42', title='Plot offset', defval=0, minval=-500, maxval=500)

alma5_offst = input.float(group='MA5 other settings', inline='MA51', title='ALMA Offset', defval=0.85, minval=-1, maxval=1, step=0.01)
alma5_sigma = input.float(group='MA5 other settings', inline='MA51', title='Sigma', defval=6, minval=0, maxval=100, step=0.01)
ma5_src = input.source(group='MA5 other settings', inline='MA52', title='Source', defval=close)
ma5_plt_offst = input.int(group='MA5 other settings', inline='MA52', title='Plot offset', defval=0, minval=-500, maxval=500)

alma6_offst = input.float(group='MA6 other settings', inline='MA61', title='ALMA Offset', defval=0.85, minval=-1, maxval=1, step=0.01)
alma6_sigma = input.float(group='MA6 other settings', inline='MA61', title='Sigma', defval=6, minval=0, maxval=100, step=0.01)
ma6_src = input.source(group='MA6 other settings', inline='MA62', title='Source', defval=close)
ma6_plt_offst = input.int(group='MA6 other settings', inline='MA62', title='Plot offset', defval=0, minval=-500, maxval=500)

alma7_offst = input.float(group='MA7 other settings', inline='MA71', title='ALMA Offset', defval=0.85, minval=-1, maxval=1, step=0.01)
alma7_sigma = input.float(group='MA7 other settings', inline='MA71', title='Sigma', defval=6, minval=0, maxval=100, step=0.01)
ma7_src = input.source(group='MA7 other settings', inline='MA72', title='Source', defval=close)
ma7_plt_offst = input.int(group='MA7 other settings', inline='MA72', title='Plot offset', defval=0, minval=-500, maxval=500)

// Background fills between MAs
fill_12_on = input.bool(group='Background fills between MAs', inline='FILL1', title='MA1-2', defval=false)
fill_23_on = input.bool(group='Background fills between MAs', inline='FILL2', title='MA2-3', defval=true)
fill_34_on = input.bool(group='Background fills between MAs', inline='FILL3', title='MA3-4', defval=false)
fill_45_on = input.bool(group='Background fills between MAs', inline='FILL4', title='MA4-5', defval=true)
fill_56_on = input.bool(group='Background fills between MAs', inline='FILL5', title='MA5-6', defval=false)
fill_67_on = input.bool(group='Background fills between MAs', inline='FILL6', title='MA6-7', defval=true)

fill_12_trans = input.int(group='Background fills between MAs', inline='FILL1', title=', transparency', defval=70, minval=0, maxval=100)
fill_23_trans = input.int(group='Background fills between MAs', inline='FILL2', title=', transparency', defval=70, minval=0, maxval=100)
fill_34_trans = input.int(group='Background fills between MAs', inline='FILL3', title=', transparency', defval=70, minval=0, maxval=100)
fill_45_trans = input.int(group='Background fills between MAs', inline='FILL4', title=', transparency', defval=70, minval=0, maxval=100)
fill_56_trans = input.int(group='Background fills between MAs', inline='FILL5', title=', transparency', defval=70, minval=0, maxval=100)
fill_67_trans = input.int(group='Background fills between MAs', inline='FILL6', title=', transparency', defval=70, minval=0, maxval=100)

// Labels
ma1_tag_on = input.bool(group='Label', inline='LBL1', title='MA1,', defval=false)
ma2_tag_on = input.bool(group='Label', inline='LBL1', title='MA2,', defval=false)
ma3_tag_on = input.bool(group='Label', inline='LBL1', title='MA3,', defval=false)
ma4_tag_on = input.bool(group='Label', inline='LBL1', title='MA4,', defval=false)
ma5_tag_on = input.bool(group='Label', inline='LBL1', title='MA5,', defval=false)
ma6_tag_on = input.bool(group='Label', inline='LBL1', title='MA6,', defval=false)
ma7_tag_on = input.bool(group='Label', inline='LBL1', title='MA7', defval=false)

tag_row_1 = input.string(group='Label', title='Row 1 text', defval='Price Bar', options=['Date', 'Peroid', 'Price Bar', 'Price MA', 'Type'])
tag_row_2 = input.string(group='Label', title='Row 2 text', defval='Price MA', options=['none', 'Date', 'Peroid', 'Price Bar', 'Price MA', 'Type'])
tag_row_3 = input.string(group='Label', title='Row 3 text', defval='Date', options=['none', 'Date', 'Peroid', 'Price Bar', 'Price MA', 'Type'])
tag_row_4 = input.string(group='Label', title='Row 4 text', defval='Peroid', options=['none', 'Date', 'Peroid', 'Price Bar', 'Price MA', 'Type'])
tag_row_5 = input.string(group='Label', title='Row 5 text', defval='Type', options=['none', 'Date', 'Peroid', 'Price Bar', 'Price MA', 'Type'])

// Price lines
ma1_price_line_on = input.bool(group='Price lines', inline='PRCL1', title='MA1,', defval=false)
ma2_price_line_on = input.bool(group='Price lines', inline='PRCL1', title='MA2,', defval=false)
ma3_price_line_on = input.bool(group='Price lines', inline='PRCL1', title='MA3,', defval=false)
ma4_price_line_on = input.bool(group='Price lines', inline='PRCL1', title='MA4,', defval=false)
ma5_price_line_on = input.bool(group='Price lines', inline='PRCL1', title='MA5,', defval=false)
ma6_price_line_on = input.bool(group='Price lines', inline='PRCL1', title='MA6,', defval=false)
ma7_price_line_on = input.bool(group='Price lines', inline='PRCL1', title='MA7', defval=false)

// =====================================================
// MTF MA Calculation
// =====================================================
actualFn(fn) =>
    fn == 'default' ? def_fn : fn

calcAllMAs() =>
    [m1, h1] = maFunction(actualFn(ma1_fn), ma1_src, ma1_len, alma1_offst, alma1_sigma)
    [m2, h2] = maFunction(actualFn(ma2_fn), ma2_src, ma2_len, alma2_offst, alma2_sigma)
    [m3, h3] = maFunction(actualFn(ma3_fn), ma3_src, ma3_len, alma3_offst, alma3_sigma)
    [m4, h4] = maFunction(actualFn(ma4_fn), ma4_src, ma4_len, alma4_offst, alma4_sigma)
    [m5, h5] = maFunction(actualFn(ma5_fn), ma5_src, ma5_len, alma5_offst, alma5_sigma)
    [m6, h6] = maFunction(actualFn(ma6_fn), ma6_src, ma6_len, alma6_offst, alma6_sigma)
    [m7, h7] = maFunction(actualFn(ma7_fn), ma7_src, ma7_len, alma7_offst, alma7_sigma)
    [m1, m2, m3, m4, m5, m6, m7, h1, h2, h3, h4, h5, h6, h7]

// 关键：所有 MA 都在 base_tf 里计算，然后映射回当前图表
[ma1, ma2, ma3, ma4, ma5, ma6, ma7, ma1_has_len, ma2_has_len, ma3_has_len, ma4_has_len, ma5_has_len, ma6_has_len, ma7_has_len] =
     request.security(syminfo.tickerid, base_tf, calcAllMAs(), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

// =====================================================
// Plot MA curves
// =====================================================
p1 = plot(series=ma1_on ? ma1 : na, color=ma1_clr, trackprice=false, offset=ma1_plt_offst)
p2 = plot(series=ma2_on ? ma2 : na, color=ma2_clr, trackprice=false, offset=ma2_plt_offst)
p3 = plot(series=ma3_on ? ma3 : na, color=ma3_clr, trackprice=false, offset=ma3_plt_offst)
p4 = plot(series=ma4_on ? ma4 : na, color=ma4_clr, trackprice=false, offset=ma4_plt_offst)
p5 = plot(series=ma5_on ? ma5 : na, color=ma5_clr, trackprice=false, offset=ma5_plt_offst)
p6 = plot(series=ma6_on ? ma6 : na, color=ma6_clr, trackprice=false, offset=ma6_plt_offst)
p7 = plot(series=ma7_on ? ma7 : na, color=ma7_clr, trackprice=false, offset=ma7_plt_offst)

// =====================================================
// Background fills between MAs
// =====================================================
fill(p1, p2, color.new(ma1 > ma2 ? ma1_clr : ma2_clr, ma1_on and ma2_on and fill_12_on ? fill_12_trans : 100))
fill(p2, p3, color.new(ma2 > ma3 ? ma2_clr : ma3_clr, ma2_on and ma3_on and fill_23_on ? fill_23_trans : 100))
fill(p3, p4, color.new(ma3 > ma4 ? ma3_clr : ma4_clr, ma3_on and ma4_on and fill_34_on ? fill_34_trans : 100))
fill(p4, p5, color.new(ma4 > ma5 ? ma4_clr : ma5_clr, ma4_on and ma5_on and fill_45_on ? fill_45_trans : 100))
fill(p5, p6, color.new(ma5 > ma6 ? ma5_clr : ma6_clr, ma5_on and ma6_on and fill_56_on ? fill_56_trans : 100))
fill(p6, p7, color.new(ma6 > ma7 ? ma6_clr : ma7_clr, ma6_on and ma7_on and fill_67_on ? fill_67_trans : 100))

// =====================================================
// Price lines
// =====================================================
if ma1_on and ma1_price_line_on
    ma1_price = line.new(x1=bar_index + 4, y1=ma1, x2=bar_index + 5, y2=ma1, xloc=xloc.bar_index, extend=extend.right, color=ma1_clr, style=line.style_dotted, width=1)
    line.delete(ma1_price[1])

if ma2_on and ma2_price_line_on
    ma2_price = line.new(x1=bar_index + 4, y1=ma2, x2=bar_index + 5, y2=ma2, xloc=xloc.bar_index, extend=extend.right, color=ma2_clr, style=line.style_dotted, width=1)
    line.delete(ma2_price[1])

if ma3_on and ma3_price_line_on
    ma3_price = line.new(x1=bar_index + 4, y1=ma3, x2=bar_index + 5, y2=ma3, xloc=xloc.bar_index, extend=extend.right, color=ma3_clr, style=line.style_dotted, width=1)
    line.delete(ma3_price[1])

if ma4_on and ma4_price_line_on
    ma4_price = line.new(x1=bar_index + 4, y1=ma4, x2=bar_index + 5, y2=ma4, xloc=xloc.bar_index, extend=extend.right, color=ma4_clr, style=line.style_dotted, width=1)
    line.delete(ma4_price[1])

if ma5_on and ma5_price_line_on
    ma5_price = line.new(x1=bar_index + 4, y1=ma5, x2=bar_index + 5, y2=ma5, xloc=xloc.bar_index, extend=extend.right, color=ma5_clr, style=line.style_dotted, width=1)
    line.delete(ma5_price[1])

if ma6_on and ma6_price_line_on
    ma6_price = line.new(x1=bar_index + 4, y1=ma6, x2=bar_index + 5, y2=ma6, xloc=xloc.bar_index, extend=extend.right, color=ma6_clr, style=line.style_dotted, width=1)
    line.delete(ma6_price[1])

if ma7_on and ma7_price_line_on
    ma7_price = line.new(x1=bar_index + 4, y1=ma7, x2=bar_index + 5, y2=ma7, xloc=xloc.bar_index, extend=extend.right, color=ma7_clr, style=line.style_dotted, width=1)
    line.delete(ma7_price[1])

// =====================================================
// Labels
// 注意：跨周期时 label 的位置仍按当前图表 bar 映射。
// 核心 MA 计算已经完全 base on 你选择的 timeframe。
// =====================================================
ma1_len_indx = ma1_len - 1
ma2_len_indx = ma2_len - 1
ma3_len_indx = ma3_len - 1
ma4_len_indx = ma4_len - 1
ma5_len_indx = ma5_len - 1
ma6_len_indx = ma6_len - 1
ma7_len_indx = ma7_len - 1

rowText(name, head, fn, len, indx, src, ma) =>
    row_text = ''
    if name == 'Date'
        if head
            row_text += str.tostring(month(time[indx])) + '-' + str.tostring(dayofmonth(time[indx]))
        else
            row_text += '\n' + str.tostring(month(time[indx])) + '-' + str.tostring(dayofmonth(time[indx]))
    else if name == 'Peroid'
        if head
            row_text += str.tostring(len) + ' @ ' + base_tf
        else
            row_text += '\n' + str.tostring(len) + ' @ ' + base_tf
    else if name == 'Type'
        if head
            row_text += fn == 'default' ? def_fn : fn
        else
            row_text += '\n' + (fn == 'default' ? def_fn : fn)
    else if name == 'Price Bar'
        if head
            row_text += strRoundValue(src[indx])
        else
            row_text += '\n' + strRoundValue(src[indx])
    else if name == 'Price MA'
        if head
            row_text += strRoundValue(ma[indx])
        else
            row_text += '\n' + strRoundValue(ma[indx])
    row_text

_row1 = rowText(tag_row_1, true, ma1_fn, ma1_len, ma1_len_indx, ma1_src, ma1)
_row2 = rowText(tag_row_2, false, ma1_fn, ma1_len, ma1_len_indx, ma1_src, ma1)
_row3 = rowText(tag_row_3, false, ma1_fn, ma1_len, ma1_len_indx, ma1_src, ma1)
_row4 = rowText(tag_row_4, false, ma1_fn, ma1_len, ma1_len_indx, ma1_src, ma1)
_row5 = rowText(tag_row_5, false, ma1_fn, ma1_len, ma1_len_indx, ma1_src, ma1)
ma1_tag_txt = _row1 + _row2 + _row3 + _row4 + _row5

_row1 := rowText(tag_row_1, true, ma2_fn, ma2_len, ma2_len_indx, ma2_src, ma2)
_row2 := rowText(tag_row_2, false, ma2_fn, ma2_len, ma2_len_indx, ma2_src, ma2)
_row3 := rowText(tag_row_3, false, ma2_fn, ma2_len, ma2_len_indx, ma2_src, ma2)
_row4 := rowText(tag_row_4, false, ma2_fn, ma2_len, ma2_len_indx, ma2_src, ma2)
_row5 := rowText(tag_row_5, false, ma2_fn, ma2_len, ma2_len_indx, ma2_src, ma2)
ma2_tag_txt = _row1 + _row2 + _row3 + _row4 + _row5

_row1 := rowText(tag_row_1, true, ma3_fn, ma3_len, ma3_len_indx, ma3_src, ma3)
_row2 := rowText(tag_row_2, false, ma3_fn, ma3_len, ma3_len_indx, ma3_src, ma3)
_row3 := rowText(tag_row_3, false, ma3_fn, ma3_len, ma3_len_indx, ma3_src, ma3)
_row4 := rowText(tag_row_4, false, ma3_fn, ma3_len, ma3_len_indx, ma3_src, ma3)
_row5 := rowText(tag_row_5, false, ma3_fn, ma3_len, ma3_len_indx, ma3_src, ma3)
ma3_tag_txt = _row1 + _row2 + _row3 + _row4 + _row5

_row1 := rowText(tag_row_1, true, ma4_fn, ma4_len, ma4_len_indx, ma4_src, ma4)
_row2 := rowText(tag_row_2, false, ma4_fn, ma4_len, ma4_len_indx, ma4_src, ma4)
_row3 := rowText(tag_row_3, false, ma4_fn, ma4_len, ma4_len_indx, ma4_src, ma4)
_row4 := rowText(tag_row_4, false, ma4_fn, ma4_len, ma4_len_indx, ma4_src, ma4)
_row5 := rowText(tag_row_5, false, ma4_fn, ma4_len, ma4_len_indx, ma4_src, ma4)
ma4_tag_txt = _row1 + _row2 + _row3 + _row4 + _row5

_row1 := rowText(tag_row_1, true, ma5_fn, ma5_len, ma5_len_indx, ma5_src, ma5)
_row2 := rowText(tag_row_2, false, ma5_fn, ma5_len, ma5_len_indx, ma5_src, ma5)
_row3 := rowText(tag_row_3, false, ma5_fn, ma5_len, ma5_len_indx, ma5_src, ma5)
_row4 := rowText(tag_row_4, false, ma5_fn, ma5_len, ma5_len_indx, ma5_src, ma5)
_row5 := rowText(tag_row_5, false, ma5_fn, ma5_len, ma5_len_indx, ma5_src, ma5)
ma5_tag_txt = _row1 + _row2 + _row3 + _row4 + _row5

_row1 := rowText(tag_row_1, true, ma6_fn, ma6_len, ma6_len_indx, ma6_src, ma6)
_row2 := rowText(tag_row_2, false, ma6_fn, ma6_len, ma6_len_indx, ma6_src, ma6)
_row3 := rowText(tag_row_3, false, ma6_fn, ma6_len, ma6_len_indx, ma6_src, ma6)
_row4 := rowText(tag_row_4, false, ma6_fn, ma6_len, ma6_len_indx, ma6_src, ma6)
_row5 := rowText(tag_row_5, false, ma6_fn, ma6_len, ma6_len_indx, ma6_src, ma6)
ma6_tag_txt = _row1 + _row2 + _row3 + _row4 + _row5

_row1 := rowText(tag_row_1, true, ma7_fn, ma7_len, ma7_len_indx, ma7_src, ma7)
_row2 := rowText(tag_row_2, false, ma7_fn, ma7_len, ma7_len_indx, ma7_src, ma7)
_row3 := rowText(tag_row_3, false, ma7_fn, ma7_len, ma7_len_indx, ma7_src, ma7)
_row4 := rowText(tag_row_4, false, ma7_fn, ma7_len, ma7_len_indx, ma7_src, ma7)
_row5 := rowText(tag_row_5, false, ma7_fn, ma7_len, ma7_len_indx, ma7_src, ma7)
ma7_tag_txt = _row1 + _row2 + _row3 + _row4 + _row5

var label ma1_tag = label.new(bar_index, na)
var label ma2_tag = label.new(bar_index, na)
var label ma3_tag = label.new(bar_index, na)
var label ma4_tag = label.new(bar_index, na)
var label ma5_tag = label.new(bar_index, na)
var label ma6_tag = label.new(bar_index, na)
var label ma7_tag = label.new(bar_index, na)

label.delete(ma1_tag)
label.delete(ma2_tag)
label.delete(ma3_tag)
label.delete(ma4_tag)
label.delete(ma5_tag)
label.delete(ma6_tag)
label.delete(ma7_tag)

if barstate.islast
    if ma1_on and ma1_tag_on and ma1_has_len
        ma1_tag := label.new(bar_index - ma1_len_indx, na, ma1_tag_txt, color=ma1_clr, textcolor=color.white, style=close[ma1_len_indx] > open[ma1_len_indx] ? label.style_label_down : label.style_label_up, yloc=close[ma1_len_indx] > open[ma1_len_indx] ? yloc.abovebar : yloc.belowbar)

    if ma2_on and ma2_tag_on and ma2_has_len
        ma2_tag := label.new(bar_index - ma2_len_indx, na, ma2_tag_txt, color=ma2_clr, textcolor=color.white, style=close[ma2_len_indx] > open[ma2_len_indx] ? label.style_label_down : label.style_label_up, yloc=close[ma2_len_indx] > open[ma2_len_indx] ? yloc.abovebar : yloc.belowbar)

    if ma3_on and ma3_tag_on and ma3_has_len
        ma3_tag := label.new(bar_index - ma3_len_indx, na, ma3_tag_txt, color=ma3_clr, textcolor=color.white, style=close[ma3_len_indx] > open[ma3_len_indx] ? label.style_label_down : label.style_label_up, yloc=close[ma3_len_indx] > open[ma3_len_indx] ? yloc.abovebar : yloc.belowbar)

    if ma4_on and ma4_tag_on and ma4_has_len
        ma4_tag := label.new(bar_index - ma4_len_indx, na, ma4_tag_txt, color=ma4_clr, textcolor=color.white, style=close[ma4_len_indx] > open[ma4_len_indx] ? label.style_label_down : label.style_label_up, yloc=close[ma4_len_indx] > open[ma4_len_indx] ? yloc.abovebar : yloc.belowbar)

    if ma5_on and ma5_tag_on and ma5_has_len
        ma5_tag := label.new(bar_index - ma5_len_indx, na, ma5_tag_txt, color=ma5_clr, textcolor=color.white, style=close[ma5_len_indx] > open[ma5_len_indx] ? label.style_label_down : label.style_label_up, yloc=close[ma5_len_indx] > open[ma5_len_indx] ? yloc.abovebar : yloc.belowbar)

    if ma6_on and ma6_tag_on and ma6_has_len
        ma6_tag := label.new(bar_index - ma6_len_indx, na, ma6_tag_txt, color=ma6_clr, textcolor=color.white, style=close[ma6_len_indx] > open[ma6_len_indx] ? label.style_label_down : label.style_label_up, yloc=close[ma6_len_indx] > open[ma6_len_indx] ? yloc.abovebar : yloc.belowbar)

    if ma7_on and ma7_tag_on and ma7_has_len
        ma7_tag := label.new(bar_index - ma7_len_indx, na, ma7_tag_txt, color=ma7_clr, textcolor=color.white, style=close[ma7_len_indx] > open[ma7_len_indx] ? label.style_label_down : label.style_label_up, yloc=close[ma7_len_indx] > open[ma7_len_indx] ? yloc.abovebar : yloc.belowbar)
````
