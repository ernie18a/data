# All in One SMA, EMA, AVWAPs

- url: https://www.tradingview.com/script/Bc0mhKYT-All-in-One-SMA-EMA-AVWAPs/
- type: indicator
- pine_id: PUB;3825fc1ab09042e78ad8ee38406f5bc5
- version: 1.0

## Description

Just a simple script with a legend to combine SMA, EMA, AVWAPs across timeframes onto one chart.

Great for traders with limited indicators.

Take some setting up but some ideas I use
8,21 EMAs
10,50,200 SMAs
AVWAPs from Mar lows, 04/07 Peace, Start of Hostilities (I use Feb 26th), YTD

## Source Code

````pine
//@version=6
indicator('All in One', overlay = true)

// ─────────────────────────────────────────────
// STYLE
// ─────────────────────────────────────────────
lw = input.int(2, 'Line Width', minval = 1, maxval = 4, group = 'Style')

// ─────────────────────────────────────────────
// TABLE SETTINGS
// ─────────────────────────────────────────────
showTable   = input.bool(true,                    'Show Legend Table', group = 'Table')
tablePos    = input.string('Top Right',           'Position',          group = 'Table',
              options = ['Top Left','Top Center','Top Right','Middle Left','Middle Center','Middle Right','Bottom Left','Bottom Center','Bottom Right'])
tableSize   = input.string('Small',               'Text Size',         group = 'Table',
              options = ['Auto','Tiny','Small','Normal','Large','Huge'])
tableBgCol  = input.color(color.new(#000000, 60), 'Background',        group = 'Table')
tableTxtCol = input.color(color.new(#FFFFFF, 0),  'Text Color',        group = 'Table')

// ─────────────────────────────────────────────
// LINE INPUTS
// Type | Period | Timeframe (MA only) | Date (AVWAP only) | Label | Show | Color
// ─────────────────────────────────────────────
type1   = input.string('Anchored VWAP',       'Type',  group = 'Line 1',  inline = 'a1', options = ['Anchored VWAP','EMA','SMA'])
period1 = input.int(21,                       'Per',   group = 'Line 1',  inline = 'a1', minval = 1)
tf1     = input.string('Daily',               '',      group = 'Line 1',  inline = 'a1', options = ['Daily','Weekly'])
date1   = input.time(timestamp('2024-08-05 02:00'), 'Date', group = 'Line 1', inline = 'd1')
lbl1    = input.string('8/05/24 Low',         'Label', group = 'Line 1',  inline = 'e1')
show1   = input.bool(true,                    'Show',  group = 'Line 1',  inline = 'f1')
c1      = input.color(color.new(#CC99FF, 0),  '',      group = 'Line 1',  inline = 'f1')

type2   = input.string('Anchored VWAP',       'Type',  group = 'Line 2',  inline = 'a2', options = ['Anchored VWAP','EMA','SMA'])
period2 = input.int(50,                       'Per',   group = 'Line 2',  inline = 'a2', minval = 1)
tf2     = input.string('Daily',               '',      group = 'Line 2',  inline = 'a2', options = ['Daily','Weekly'])
date2   = input.time(timestamp('2025-02-20 04:00'), 'Date', group = 'Line 2', inline = 'd2')
lbl2    = input.string('2/20/25',             'Label', group = 'Line 2',  inline = 'e2')
show2   = input.bool(true,                    'Show',  group = 'Line 2',  inline = 'f2')
c2      = input.color(color.new(#008080, 0),  '',      group = 'Line 2',  inline = 'f2')

type3   = input.string('Anchored VWAP',       'Type',  group = 'Line 3',  inline = 'a3', options = ['Anchored VWAP','EMA','SMA'])
period3 = input.int(100,                      'Per',   group = 'Line 3',  inline = 'a3', minval = 1)
tf3     = input.string('Daily',               '',      group = 'Line 3',  inline = 'a3', options = ['Daily','Weekly'])
date3   = input.time(timestamp('2025-04-07 06:00'), 'Date', group = 'Line 3', inline = 'd3')
lbl3    = input.string('Liberation Day',      'Label', group = 'Line 3',  inline = 'e3')
show3   = input.bool(true,                    'Show',  group = 'Line 3',  inline = 'f3')
c3      = input.color(color.new(#FF8C00, 0),  '',      group = 'Line 3',  inline = 'f3')

type4   = input.string('Anchored VWAP',       'Type',  group = 'Line 4',  inline = 'a4', options = ['Anchored VWAP','EMA','SMA'])
period4 = input.int(200,                      'Per',   group = 'Line 4',  inline = 'a4', minval = 1)
tf4     = input.string('Daily',               '',      group = 'Line 4',  inline = 'a4', options = ['Daily','Weekly'])
date4   = input.time(timestamp('2025-08-01 11:00'), 'Date', group = 'Line 4', inline = 'd4')
lbl4    = input.string('8/01/25',             'Label', group = 'Line 4',  inline = 'e4')
show4   = input.bool(true,                    'Show',  group = 'Line 4',  inline = 'f4')
c4      = input.color(color.new(#6600CC, 0),  '',      group = 'Line 4',  inline = 'f4')

type5   = input.string('Anchored VWAP',       'Type',  group = 'Line 5',  inline = 'a5', options = ['Anchored VWAP','EMA','SMA'])
period5 = input.int(21,                       'Per',   group = 'Line 5',  inline = 'a5', minval = 1)
tf5     = input.string('Daily',               '',      group = 'Line 5',  inline = 'a5', options = ['Daily','Weekly'])
date5   = input.time(timestamp('2025-10-10 08:00'), 'Date', group = 'Line 5', inline = 'd5')
lbl5    = input.string('10/10/25',            'Label', group = 'Line 5',  inline = 'e5')
show5   = input.bool(true,                    'Show',  group = 'Line 5',  inline = 'f5')
c5      = input.color(color.new(#0066FF, 0),  '',      group = 'Line 5',  inline = 'f5')

type6   = input.string('Anchored VWAP',       'Type',  group = 'Line 6',  inline = 'a6', options = ['Anchored VWAP','EMA','SMA'])
period6 = input.int(21,                       'Per',   group = 'Line 6',  inline = 'a6', minval = 1)
tf6     = input.string('Daily',               '',      group = 'Line 6',  inline = 'a6', options = ['Daily','Weekly'])
date6   = input.time(timestamp('2026-04-17 16:00'), 'Date', group = 'Line 6', inline = 'd6')
lbl6    = input.string('April OPEX',          'Label', group = 'Line 6',  inline = 'e6')
show6   = input.bool(true,                    'Show',  group = 'Line 6',  inline = 'f6')
c6      = input.color(color.new(#FF0000, 0),  '',      group = 'Line 6',  inline = 'f6')

type7   = input.string('Anchored VWAP',       'Type',  group = 'Line 7',  inline = 'a7', options = ['Anchored VWAP','EMA','SMA'])
period7 = input.int(21,                       'Per',   group = 'Line 7',  inline = 'a7', minval = 1)
tf7     = input.string('Daily',               '',      group = 'Line 7',  inline = 'a7', options = ['Daily','Weekly'])
date7   = input.time(timestamp('2025-11-21 05:00'), 'Date', group = 'Line 7', inline = 'd7')
lbl7    = input.string('11/21/25',            'Label', group = 'Line 7',  inline = 'e7')
show7   = input.bool(true,                    'Show',  group = 'Line 7',  inline = 'f7')
c7      = input.color(color.new(#00AA00, 0),  '',      group = 'Line 7',  inline = 'f7')

type8   = input.string('Anchored VWAP',       'Type',  group = 'Line 8',  inline = 'a8', options = ['Anchored VWAP','EMA','SMA'])
period8 = input.int(21,                       'Per',   group = 'Line 8',  inline = 'a8', minval = 1)
tf8     = input.string('Daily',               '',      group = 'Line 8',  inline = 'a8', options = ['Daily','Weekly'])
date8   = input.time(timestamp('2025-11-26 02:00'), 'Date', group = 'Line 8', inline = 'd8')
lbl8    = input.string('11/26/25',            'Label', group = 'Line 8',  inline = 'e8')
show8   = input.bool(true,                    'Show',  group = 'Line 8',  inline = 'f8')
c8      = input.color(color.new(#FFD700, 0),  '',      group = 'Line 8',  inline = 'f8')

type9   = input.string('Anchored VWAP',       'Type',  group = 'Line 9',  inline = 'a9', options = ['Anchored VWAP','EMA','SMA'])
period9 = input.int(21,                       'Per',   group = 'Line 9',  inline = 'a9', minval = 1)
tf9     = input.string('Daily',               '',      group = 'Line 9',  inline = 'a9', options = ['Daily','Weekly'])
date9   = input.time(timestamp('2025-12-17 11:00'), 'Date', group = 'Line 9', inline = 'd9')
lbl9    = input.string('12/17/25',            'Label', group = 'Line 9',  inline = 'e9')
show9   = input.bool(true,                    'Show',  group = 'Line 9',  inline = 'f9')
c9      = input.color(color.new(#FF69B4, 0),  '',      group = 'Line 9',  inline = 'f9')

type10   = input.string('Anchored VWAP',      'Type',  group = 'Line 10', inline = 'a10', options = ['Anchored VWAP','EMA','SMA'])
period10 = input.int(21,                      'Per',   group = 'Line 10', inline = 'a10', minval = 1)
tf10     = input.string('Daily',              '',      group = 'Line 10', inline = 'a10', options = ['Daily','Weekly'])
date10   = input.time(timestamp('2026-01-01 02:00'), 'Date', group = 'Line 10', inline = 'd10')
lbl10    = input.string('YTD 2026',           'Label', group = 'Line 10', inline = 'e10')
show10   = input.bool(true,                   'Show',  group = 'Line 10', inline = 'f10')
c10      = input.color(color.new(#00BFFF, 0), '',      group = 'Line 10', inline = 'f10')

type11   = input.string('Anchored VWAP',      'Type',  group = 'Line 11', inline = 'a11', options = ['Anchored VWAP','EMA','SMA'])
period11 = input.int(21,                      'Per',   group = 'Line 11', inline = 'a11', minval = 1)
tf11     = input.string('Daily',              '',      group = 'Line 11', inline = 'a11', options = ['Daily','Weekly'])
date11   = input.time(timestamp('2026-01-27 22:00'), 'Date', group = 'Line 11', inline = 'd11')
lbl11    = input.string('1/27/26 YTD High',   'Label', group = 'Line 11', inline = 'e11')
show11   = input.bool(true,                   'Show',  group = 'Line 11', inline = 'f11')
c11      = input.color(color.new(#808080, 0), '',      group = 'Line 11', inline = 'f11')

type12   = input.string('Anchored VWAP',      'Type',  group = 'Line 12', inline = 'a12', options = ['Anchored VWAP','EMA','SMA'])
period12 = input.int(21,                      'Per',   group = 'Line 12', inline = 'a12', minval = 1)
tf12     = input.string('Daily',              '',      group = 'Line 12', inline = 'a12', options = ['Daily','Weekly'])
date12   = input.time(timestamp('2026-04-07 16:00'), 'Date', group = 'Line 12', inline = 'd12')
lbl12    = input.string('Peace',              'Label', group = 'Line 12', inline = 'e12')
show12   = input.bool(true,                   'Show',  group = 'Line 12', inline = 'f12')
c12      = input.color(color.new(#800000, 0), '',      group = 'Line 12', inline = 'f12')

type13   = input.string('Anchored VWAP',      'Type',  group = 'Line 13', inline = 'a13', options = ['Anchored VWAP','EMA','SMA'])
period13 = input.int(21,                      'Per',   group = 'Line 13', inline = 'a13', minval = 1)
tf13     = input.string('Daily',              '',      group = 'Line 13', inline = 'a13', options = ['Daily','Weekly'])
date13   = input.time(timestamp('2026-03-30 18:00'), 'Date', group = 'Line 13', inline = 'd13')
lbl13    = input.string('3/30 Low',           'Label', group = 'Line 13', inline = 'e13')
show13   = input.bool(true,                   'Show',  group = 'Line 13', inline = 'f13')
c13      = input.color(color.new(#1A1A1A, 0), '',      group = 'Line 13', inline = 'f13')

type14   = input.string('Anchored VWAP',      'Type',  group = 'Line 14', inline = 'a14', options = ['Anchored VWAP','EMA','SMA'])
period14 = input.int(21,                      'Per',   group = 'Line 14', inline = 'a14', minval = 1)
tf14     = input.string('Daily',              '',      group = 'Line 14', inline = 'a14', options = ['Daily','Weekly'])
date14   = input.time(timestamp('2026-05-01 09:30'), 'Date', group = 'Line 14', inline = 'd14')
lbl14    = input.string('May 1 Cash Open',    'Label', group = 'Line 14', inline = 'e14')
show14   = input.bool(true,                   'Show',  group = 'Line 14', inline = 'f14')
c14      = input.color(color.new(#c58b1e, 0), '',      group = 'Line 14', inline = 'f14')

type15   = input.string('Anchored VWAP',      'Type',  group = 'Line 15', inline = 'a15', options = ['Anchored VWAP','EMA','SMA'])
period15 = input.int(21,                      'Per',   group = 'Line 15', inline = 'a15', minval = 1)
tf15     = input.string('Daily',              '',      group = 'Line 15', inline = 'a15', options = ['Daily','Weekly'])
date15   = input.time(timestamp('2026-05-17 16:00'), 'Date', group = 'Line 15', inline = 'd15')
lbl15    = input.string('5/17/26',            'Label', group = 'Line 15', inline = 'e15')
show15   = input.bool(true,                   'Show',  group = 'Line 15', inline = 'f15')
c15      = input.color(color.new(#22fdce, 0), '',      group = 'Line 15', inline = 'f15')

type16   = input.string('EMA',                'Type',  group = 'Line 16', inline = 'a16', options = ['Anchored VWAP','EMA','SMA'])
period16 = input.int(21,                      'Per',   group = 'Line 16', inline = 'a16', minval = 1)
tf16     = input.string('Daily',              '',      group = 'Line 16', inline = 'a16', options = ['Daily','Weekly'])
date16   = input.time(timestamp('2026-01-01 00:00'), 'Date', group = 'Line 16', inline = 'd16')
lbl16    = input.string('21 EMA D',           'Label', group = 'Line 16', inline = 'e16')
show16   = input.bool(true,                   'Show',  group = 'Line 16', inline = 'f16')
c16      = input.color(color.new(#FF6B6B, 0), '',      group = 'Line 16', inline = 'f16')

type17   = input.string('EMA',                'Type',  group = 'Line 17', inline = 'a17', options = ['Anchored VWAP','EMA','SMA'])
period17 = input.int(50,                      'Per',   group = 'Line 17', inline = 'a17', minval = 1)
tf17     = input.string('Daily',              '',      group = 'Line 17', inline = 'a17', options = ['Daily','Weekly'])
date17   = input.time(timestamp('2026-01-01 00:00'), 'Date', group = 'Line 17', inline = 'd17')
lbl17    = input.string('50 EMA D',           'Label', group = 'Line 17', inline = 'e17')
show17   = input.bool(true,                   'Show',  group = 'Line 17', inline = 'f17')
c17      = input.color(color.new(#4ECDC4, 0), '',      group = 'Line 17', inline = 'f17')

type18   = input.string('SMA',                'Type',  group = 'Line 18', inline = 'a18', options = ['Anchored VWAP','EMA','SMA'])
period18 = input.int(100,                     'Per',   group = 'Line 18', inline = 'a18', minval = 1)
tf18     = input.string('Daily',              '',      group = 'Line 18', inline = 'a18', options = ['Daily','Weekly'])
date18   = input.time(timestamp('2026-01-01 00:00'), 'Date', group = 'Line 18', inline = 'd18')
lbl18    = input.string('100 SMA D',          'Label', group = 'Line 18', inline = 'e18')
show18   = input.bool(true,                   'Show',  group = 'Line 18', inline = 'f18')
c18      = input.color(color.new(#45B7D1, 0), '',      group = 'Line 18', inline = 'f18')

type19   = input.string('SMA',                'Type',  group = 'Line 19', inline = 'a19', options = ['Anchored VWAP','EMA','SMA'])
period19 = input.int(200,                     'Per',   group = 'Line 19', inline = 'a19', minval = 1)
tf19     = input.string('Daily',              '',      group = 'Line 19', inline = 'a19', options = ['Daily','Weekly'])
date19   = input.time(timestamp('2026-01-01 00:00'), 'Date', group = 'Line 19', inline = 'd19')
lbl19    = input.string('200 SMA D',          'Label', group = 'Line 19', inline = 'e19')
show19   = input.bool(true,                   'Show',  group = 'Line 19', inline = 'f19')
c19      = input.color(color.new(#96CEB4, 0), '',      group = 'Line 19', inline = 'f19')

type20   = input.string('EMA',                'Type',  group = 'Line 20', inline = 'a20', options = ['Anchored VWAP','EMA','SMA'])
period20 = input.int(200,                     'Per',   group = 'Line 20', inline = 'a20', minval = 1)
tf20     = input.string('Daily',              '',      group = 'Line 20', inline = 'a20', options = ['Daily','Weekly'])
date20   = input.time(timestamp('2026-01-01 00:00'), 'Date', group = 'Line 20', inline = 'd20')
lbl20    = input.string('200 EMA D',          'Label', group = 'Line 20', inline = 'e20')
show20   = input.bool(true,                   'Show',  group = 'Line 20', inline = 'f20')
c20      = input.color(color.new(#FFEAA7, 0), '',      group = 'Line 20', inline = 'f20')

// ─────────────────────────────────────────────
// PRICE SOURCE — OHLC4 for AVWAP
// ─────────────────────────────────────────────
price = (open + high + low + close) / 4

// ─────────────────────────────────────────────
// AVWAP CALCULATION
// ─────────────────────────────────────────────
avwapCalc(anchorT) =>
    var float cumVol = 0.0
    var float cumPV  = 0.0
    var float lastT  = na
    if na(lastT) or anchorT != lastT
        cumVol := 0.0
        cumPV  := 0.0
        lastT  := anchorT
        lastT
    if time >= anchorT
        cumVol := cumVol + volume
        cumPV  := cumPV  + price * volume
        cumPV
    cumVol > 0 ? cumPV / cumVol : na

// ─────────────────────────────────────────────
// TIMEFRAME STRING RESOLVER
// ─────────────────────────────────────────────
tfStr(tf) =>
    tf == 'Weekly' ? 'W' : 'D'

// ─────────────────────────────────────────────
// UNIFIED LINE VALUE RESOLVER
// AVWAPs use current chart resolution
// EMAs/SMAs use request.security to pull from
// the selected Daily or Weekly timeframe
// ─────────────────────────────────────────────
lineVal(typ, per, tf, anchorT) =>
    float result = na
    if typ == 'Anchored VWAP'
        result := avwapCalc(anchorT)
    else if typ == 'EMA'
        result := request.security(syminfo.tickerid, tfStr(tf), ta.ema(close, per), lookahead = barmerge.lookahead_off)
    else if typ == 'SMA'
        result := request.security(syminfo.tickerid, tfStr(tf), ta.sma(close, per), lookahead = barmerge.lookahead_off)
    result

// ─────────────────────────────────────────────
// COMPUTE ALL 20 LINES
// ─────────────────────────────────────────────
v1  = lineVal(type1,  period1,  tf1,  date1)
v2  = lineVal(type2,  period2,  tf2,  date2)
v3  = lineVal(type3,  period3,  tf3,  date3)
v4  = lineVal(type4,  period4,  tf4,  date4)
v5  = lineVal(type5,  period5,  tf5,  date5)
v6  = lineVal(type6,  period6,  tf6,  date6)
v7  = lineVal(type7,  period7,  tf7,  date7)
v8  = lineVal(type8,  period8,  tf8,  date8)
v9  = lineVal(type9,  period9,  tf9,  date9)
v10 = lineVal(type10, period10, tf10, date10)
v11 = lineVal(type11, period11, tf11, date11)
v12 = lineVal(type12, period12, tf12, date12)
v13 = lineVal(type13, period13, tf13, date13)
v14 = lineVal(type14, period14, tf14, date14)
v15 = lineVal(type15, period15, tf15, date15)
v16 = lineVal(type16, period16, tf16, date16)
v17 = lineVal(type17, period17, tf17, date17)
v18 = lineVal(type18, period18, tf18, date18)
v19 = lineVal(type19, period19, tf19, date19)
v20 = lineVal(type20, period20, tf20, date20)

// ─────────────────────────────────────────────
// PLOT ALL 20 LINES
// ─────────────────────────────────────────────
plot(show1  ? v1  : na, 'Line 1',  color = c1,  linewidth = math.max(1, lw))
plot(show2  ? v2  : na, 'Line 2',  color = c2,  linewidth = math.max(1, lw))
plot(show3  ? v3  : na, 'Line 3',  color = c3,  linewidth = math.max(1, lw))
plot(show4  ? v4  : na, 'Line 4',  color = c4,  linewidth = math.max(1, lw))
plot(show5  ? v5  : na, 'Line 5',  color = c5,  linewidth = math.max(1, lw))
plot(show6  ? v6  : na, 'Line 6',  color = c6,  linewidth = math.max(1, lw))
plot(show7  ? v7  : na, 'Line 7',  color = c7,  linewidth = math.max(1, lw))
plot(show8  ? v8  : na, 'Line 8',  color = c8,  linewidth = math.max(1, lw))
plot(show9  ? v9  : na, 'Line 9',  color = c9,  linewidth = math.max(1, lw))
plot(show10 ? v10 : na, 'Line 10', color = c10, linewidth = math.max(1, lw))
plot(show11 ? v11 : na, 'Line 11', color = c11, linewidth = math.max(1, lw))
plot(show12 ? v12 : na, 'Line 12', color = c12, linewidth = math.max(1, lw))
plot(show13 ? v13 : na, 'Line 13', color = c13, linewidth = math.max(1, lw))
plot(show14 ? v14 : na, 'Line 14', color = c14, linewidth = math.max(1, lw))
plot(show15 ? v15 : na, 'Line 15', color = c15, linewidth = math.max(1, lw))
plot(show16 ? v16 : na, 'Line 16', color = c16, linewidth = math.max(1, lw))
plot(show17 ? v17 : na, 'Line 17', color = c17, linewidth = math.max(1, lw))
plot(show18 ? v18 : na, 'Line 18', color = c18, linewidth = math.max(1, lw))
plot(show19 ? v19 : na, 'Line 19', color = c19, linewidth = math.max(1, lw))
plot(show20 ? v20 : na, 'Line 20', color = c20, linewidth = math.max(1, lw))
// ─────────────────────────────────────────────
// TABLE HELPERS
// ─────────────────────────────────────────────
posMap(p) =>
    switch p
        'Top Left'      => position.top_left
        'Top Center'    => position.top_center
        'Top Right'     => position.top_right
        'Middle Left'   => position.middle_left
        'Middle Center' => position.middle_center
        'Middle Right'  => position.middle_right
        'Bottom Left'   => position.bottom_left
        'Bottom Center' => position.bottom_center
        => position.bottom_right

sizeMap(s) =>
    switch s
        'Tiny'   => size.tiny
        'Small'  => size.small
        'Normal' => size.normal
        'Large'  => size.large
        'Huge'   => size.huge
        => size.auto

tableRow(tbl, row, lbl, col, txtCol, sz) =>
    table.cell(tbl, 0, row, lbl, text_color = txtCol, text_size = sz,
      text_halign = text.align_left, bgcolor = color.new(col, 82))

// ─────────────────────────────────────────────
// LEGEND TABLE
// ─────────────────────────────────────────────
var table legend = na

if showTable and barstate.islast
    if not na(legend)
        table.delete(legend)

    visCount =
      (show1  ? 1 : 0) + (show2  ? 1 : 0) + (show3  ? 1 : 0) + (show4  ? 1 : 0) +
      (show5  ? 1 : 0) + (show6  ? 1 : 0) + (show7  ? 1 : 0) + (show8  ? 1 : 0) +
      (show9  ? 1 : 0) + (show10 ? 1 : 0) + (show11 ? 1 : 0) + (show12 ? 1 : 0) +
      (show13 ? 1 : 0) + (show14 ? 1 : 0) + (show15 ? 1 : 0) + (show16 ? 1 : 0) +
      (show17 ? 1 : 0) + (show18 ? 1 : 0) + (show19 ? 1 : 0) + (show20 ? 1 : 0)

    legend := table.new(
      posMap(tablePos), columns = 1, rows = visCount + 1,
      bgcolor = tableBgCol, border_width = 0,
      frame_width = 1, frame_color = color.new(#FFFFFF, 80))

    // Header
    table.cell(legend, 0, 0, 'Levels', text_color = tableTxtCol,
      text_size = sizeMap(tableSize), text_halign = text.align_center,
      bgcolor = color.new(#FFFFFF, 88))

    sz  = sizeMap(tableSize)
    row = 1

    if show1
        tableRow(legend, row, lbl1,  c1,  tableTxtCol, sz)
        row := row + 1
    if show2
        tableRow(legend, row, lbl2,  c2,  tableTxtCol, sz)
        row := row + 1
    if show3
        tableRow(legend, row, lbl3,  c3,  tableTxtCol, sz)
        row := row + 1
    if show4
        tableRow(legend, row, lbl4,  c4,  tableTxtCol, sz)
        row := row + 1
    if show5
        tableRow(legend, row, lbl5,  c5,  tableTxtCol, sz)
        row := row + 1
    if show6
        tableRow(legend, row, lbl6,  c6,  tableTxtCol, sz)
        row := row + 1
    if show7
        tableRow(legend, row, lbl7,  c7,  tableTxtCol, sz)
        row := row + 1
    if show8
        tableRow(legend, row, lbl8,  c8,  tableTxtCol, sz)
        row := row + 1
    if show9
        tableRow(legend, row, lbl9,  c9,  tableTxtCol, sz)
        row := row + 1
    if show10
        tableRow(legend, row, lbl10, c10, tableTxtCol, sz)
        row := row + 1
    if show11
        tableRow(legend, row, lbl11, c11, tableTxtCol, sz)
        row := row + 1
    if show12
        tableRow(legend, row, lbl12, c12, tableTxtCol, sz)
        row := row + 1
    if show13
        tableRow(legend, row, lbl13, c13, tableTxtCol, sz)
        row := row + 1
    if show14
        tableRow(legend, row, lbl14, c14, tableTxtCol, sz)
        row := row + 1
    if show15
        tableRow(legend, row, lbl15, c15, tableTxtCol, sz)
        row := row + 1
    if show16
        tableRow(legend, row, lbl16, c16, tableTxtCol, sz)
        row := row + 1
    if show17
        tableRow(legend, row, lbl17, c17, tableTxtCol, sz)
        row := row + 1
    if show18
        tableRow(legend, row, lbl18, c18, tableTxtCol, sz)
        row := row + 1
    if show19
        tableRow(legend, row, lbl19, c19, tableTxtCol, sz)
        row := row + 1
    if show20
        tableRow(legend, row, lbl20, c20, tableTxtCol, sz)
        row := row + 1
````
