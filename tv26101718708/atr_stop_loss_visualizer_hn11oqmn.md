# ATR Stop Loss Visualizer

- url: https://www.tradingview.com/script/Hn11OQmn-ATR-Stop-Loss-Visualizer/
- type: indicator
- pine_id: PUB;b58b90ecc37741cbbbed6471f8b473a7
- version: 1.0

## Description

This script provides a line and label of a custom set ATR and provides risk settings so you can enter trades knowing exactly how to size based on current volatility of price action. 

it's adjustable risk settings, label, and a dashboard.

## Source Code

````pine
//@version=6
indicator('ATR Stop Loss Visualizer', overlay = true, max_labels_count = 10, max_lines_count = 10)

// === INPUTS ===
atrLen = input.int(14, 'ATR Length', minval = 1, group = 'ATR Settings')
atrMult = input.float(1.5, 'ATR Multiplier', minval = 0.1, step = 0.1, group = 'ATR Settings')
atrSmooth = input.string('RMA', 'ATR Smoothing', options = ['RMA', 'EMA', 'SMA', 'WMA'], group = 'ATR Settings')

showLong = input.bool(true, 'Show Long Stop', group = 'Visual Settings')
showShort = input.bool(true, 'Show Short Stop', group = 'Visual Settings')
showLabels = input.bool(true, 'Show Price Labels', group = 'Visual Settings')
showDash = input.bool(true, 'Show Dashboard', group = 'Visual Settings')
lineWidth = input.int(2, 'Line Width', minval = 1, maxval = 4, group = 'Visual Settings')

bullClr = input.color(color.new(#00C853, 0), 'Long Stop Colour', group = 'Colours')
bearClr = input.color(color.new(#FF1744, 0), 'Short Stop Colour', group = 'Colours')

riskAmt = input.float(1000.0, 'Risk Amount ($)', minval = 0.01, step = 100, group = 'Position Sizing')
dpp = input.float(1.0, 'Dollar Per Point', minval = 0.0001, step = 1, group = 'Position Sizing', tooltip = 'Contract value per 1 point move. Examples: ES futures = 50, NQ = 20, Forex micro lot = 0.1, Stocks = 1')

tblPos = input.string('Bottom Right', 'Dashboard Position', options = ['Top Right', 'Top Left', 'Bottom Right', 'Bottom Left', 'Top Center', 'Bottom Center'], group = 'Dashboard')

// === ATR CALCULATION ===
float atrRaw = na
if atrSmooth == 'EMA'
    atrRaw := ta.ema(ta.tr(true), atrLen)
    atrRaw
else if atrSmooth == 'SMA'
    atrRaw := ta.sma(ta.tr(true), atrLen)
    atrRaw
else if atrSmooth == 'WMA'
    atrRaw := ta.wma(ta.tr(true), atrLen)
    atrRaw
else
    atrRaw := ta.rma(ta.tr(true), atrLen)
    atrRaw

atrVal = atrRaw * atrMult
longStop = close - atrVal
shortStop = close + atrVal

// === POSITION SIZE CALCULATION ===
// Size = Risk $ / (Stop Distance in points x Dollar Per Point)
posSize = riskAmt / (atrVal[1] * dpp)
posSizeR = math.round(posSize, 2)

// === HELPER ===
_fmt(val) =>
    str.tostring(val, format.mintick)

// === CURRENT-BAR LINES (delete & redraw each bar) ===
var line longLine = na
var line shortLine = na
var label longLbl = na
var label shortLbl = na

line.delete(longLine)
line.delete(shortLine)
label.delete(longLbl)
label.delete(shortLbl)

if showLong
    longLine := line.new(bar_index, longStop[1], bar_index + 1, longStop[1], color = bullClr, width = lineWidth, extend = extend.right, style = line.style_solid)
    if showLabels
        longLbl := label.new(bar_index + 2, longStop[1], 'Long SL: ' + _fmt(longStop[1]) + '\nSize: ' + str.tostring(posSizeR), style = label.style_label_right, color = color.new(bullClr, 20), textcolor = color.white, size = size.small)
        longLbl

if showShort
    shortLine := line.new(bar_index, shortStop[1], bar_index + 1, shortStop[1], color = bearClr, width = lineWidth, extend = extend.right, style = line.style_solid)
    if showLabels
        shortLbl := label.new(bar_index + 2, shortStop[1], 'Short SL: ' + _fmt(shortStop[1]) + '\nSize: ' + str.tostring(posSizeR), style = label.style_label_right, color = color.new(bearClr, 20), textcolor = color.white, size = size.small)
        shortLbl

// === DASHBOARD ===
var tblPosition = position.bottom_right
if tblPos == 'Top Right'
    tblPosition := position.top_right
    tblPosition
else if tblPos == 'Top Left'
    tblPosition := position.top_left
    tblPosition
else if tblPos == 'Bottom Left'
    tblPosition := position.bottom_left
    tblPosition
else if tblPos == 'Top Center'
    tblPosition := position.top_center
    tblPosition
else if tblPos == 'Bottom Center'
    tblPosition := position.bottom_center
    tblPosition

var table dash = table.new(tblPosition, columns = 2, rows = 10, bgcolor = color.new(color.black, 30), border_color = color.new(color.gray, 60), border_width = 1, frame_color = color.new(color.gray, 40), frame_width = 1)

if showDash
    riskPct = math.round(atrVal / close * 100, 2)

    // Header
    table.cell(dash, 0, 0, 'ATR Stop Loss Visualizer', text_color = color.white, text_size = size.normal, bgcolor = color.new(color.navy, 10), text_halign = text.align_center)
    table.cell(dash, 1, 0, '', bgcolor = color.new(color.navy, 10))
    table.merge_cells(dash, 0, 0, 1, 0)

    // ATR info
    table.cell(dash, 0, 1, '  Current Price', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_left)
    table.cell(dash, 1, 1, _fmt(close), text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_right)

    table.cell(dash, 0, 2, '  Raw ATR(' + str.tostring(atrLen) + ')', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(math.round(atrRaw, 5)), text_color = color.yellow, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_right)

    table.cell(dash, 0, 3, '  Multiplier', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_left)
    table.cell(dash, 1, 3, 'x' + str.tostring(atrMult), text_color = color.gray, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_right)

    table.cell(dash, 0, 4, '  Stop Distance', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_left)
    table.cell(dash, 1, 4, _fmt(atrVal) + ' (' + str.tostring(riskPct) + '%)', text_color = color.orange, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_right)

    if showLong
        table.cell(dash, 0, 5, '  Long Stop', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_left)
        table.cell(dash, 1, 5, _fmt(longStop), text_color = bullClr, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_right)
    else
        table.cell(dash, 0, 5, '', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_left)
        table.cell(dash, 1, 5, '', text_color = bullClr, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_right)

    if showShort
        table.cell(dash, 0, 6, '  Short Stop', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_left)
        table.cell(dash, 1, 6, _fmt(shortStop), text_color = bearClr, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_right)
    else
        table.cell(dash, 0, 6, '', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_left)
        table.cell(dash, 1, 6, '', text_color = bearClr, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_right)

    // Divider row
    table.cell(dash, 0, 7, '  Position Sizing', text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 60), text_halign = text.align_left)
    table.cell(dash, 1, 7, '', text_color = color.white, text_size = size.small, bgcolor = color.new(color.gray, 60), text_halign = text.align_right)
    table.merge_cells(dash, 0, 7, 1, 7)

    table.cell(dash, 0, 8, '  Risk / $ Per Pt', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_left)
    table.cell(dash, 1, 8, '$' + str.tostring(riskAmt) + ' / $' + str.tostring(dpp), text_color = color.white, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_right)

    table.cell(dash, 0, 9, '  Position Size', text_color = color.silver, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_left)
    table.cell(dash, 1, 9, str.tostring(posSizeR) + ' units', text_color = color.aqua, text_size = size.small, bgcolor = color.new(color.black, 50), text_halign = text.align_right)

// === ALERTS ===
alertcondition(close < longStop[1], 'Price hit Long Stop', 'Close crossed below long ATR stop!')
alertcondition(close > shortStop[1], 'Price hit Short Stop', 'Close crossed above short ATR stop!')
````
