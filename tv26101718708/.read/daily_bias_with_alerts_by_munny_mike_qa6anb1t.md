# Daily Bias ( with Alerts) By: Munny Mike

- url: https://www.tradingview.com/script/Qa6Anb1T-Daily-Bias-with-Alerts-By-Munny-Mike/
- type: indicator
- pine_id: PUB;e69188d0b5a748dc891d94a8b58ccc09
- version: 2.0

## Description

Daily Bias (with Alerts) identifies market bias based on daily price action: Bullish when previous close > high of two days ago, Bearish when previous close < low of two days ago, otherwise Consolidation. It draws horizontal lines from the previous candle’s high/low accordingly, with full customization of color, style, extension, and line count. The indicator also marks the previous candle’s high/low with optional price labels, provides breakout alerts (above prior high / below prior low), and includes an optional on‑chart table displaying both daily and (on ≤4h charts) intraday bias. Designed for intraday and multi‑timeframe traders who follow daily structure.

 [symbol="PEPPERSTONE:NAS100"]PEPPERSTONE:NAS100[/symbol]

## Source Code

````pine
//@version=6
indicator(title='Daily Bias (with Alerts)', overlay=true, max_lines_count=500, max_bars_back=500)

//══════════════════════════════════════════
// 1. DAILY BIAS — BULLISH
//══════════════════════════════════════════
Bias_bull      = input.bool(true, 'Bullish', group='1 — Daily Bias')
col_Bias_bull  = input.color(color.green, '', group='1 — Daily Bias')
ext_Bias_bull  = input.string(extend.none, 'Extend', options=[extend.none, extend.right, extend.left, extend.both], group='1 — Daily Bias')
tot_Bias_bull  = input.int(1, 'Previous', group='1 — Daily Bias')
sty_Bias_bull  = input.string(line.style_solid, 'Style', options=[line.style_solid, line.style_dotted, line.style_dashed], group='1 — Daily Bias')
size_Bias_bull = input.int(1, 'Size', group='1 — Daily Bias')

//══════════════════════════════════════════
// 2. DAILY BIAS — BEARISH
//══════════════════════════════════════════
Bias_bear      = input.bool(true, 'Bearish', group='2 — Daily Bias')
col_Bias_bear  = input.color(color.red, '', group='2 — Daily Bias')
ext_Bias_bear  = input.string(extend.none, 'Extend', options=[extend.none, extend.right, extend.left, extend.both], group='2 — Daily Bias')
tot_Bias_bear  = input.int(1, 'Previous', group='2 — Daily Bias')
sty_Bias_bear  = input.string(line.style_solid, 'Style', options=[line.style_solid, line.style_dotted, line.style_dashed], group='2 — Daily Bias')
size_Bias_bear = input.int(1, 'Size', group='2 — Daily Bias')

//══════════════════════════════════════════
// 3. CONSOLIDATION (inside previous range)
//══════════════════════════════════════════
Bias_conso      = input.bool(true, 'Consolidation', group='3 — Consolidation')
col_Bias_conso  = input.color(color.gray, '', group='3 — Consolidation')
ext_Bias_conso  = input.string(extend.none, 'Extend', options=[extend.none, extend.right, extend.left, extend.both], group='3 — Consolidation')
tot_Bias_conso  = input.int(1, 'Previous', group='3 — Consolidation')
sty_Bias_conso  = input.string(line.style_solid, 'Style', options=[line.style_solid, line.style_dotted, line.style_dashed], group='3 — Consolidation')
size_Bias_conso = input.int(1, 'Size', group='3 — Consolidation')

//══════════════════════════════════════════
// 4. PREVIOUS CANDLE MARKING (High/Low)
//══════════════════════════════════════════
showPrevHL     = input.bool(true, 'Show Previous High/Low', group='4 — Previous Candle')
prevHighColor  = input.color(color.gray, 'High Line Color', group='4 — Previous Candle')
prevLowColor   = input.color(color.gray, 'Low Line Color', group='4 — Previous Candle')
prevHighExt    = input.string(extend.right, 'High Extend', options=[extend.none, extend.right], group='4 — Previous Candle')
prevLowExt     = input.string(extend.right, 'Low Extend', options=[extend.none, extend.right], group='4 — Previous Candle')
prevHighStyle  = input.string(line.style_solid, 'High Style', options=[line.style_solid, line.style_dotted, line.style_dashed], group='4 — Previous Candle')
prevLowStyle   = input.string(line.style_solid, 'Low Style', options=[line.style_solid, line.style_dotted, line.style_dashed], group='4 — Previous Candle')
prevHighWidth  = input.int(1, 'High Line Width', minval=1, maxval=5, group='4 — Previous Candle')   // <-- line thickness
prevLowWidth   = input.int(1, 'Low Line Width', minval=1, maxval=5, group='4 — Previous Candle')    // <-- line thickness
showLabels     = input.bool(true, 'Show Price Labels', group='4 — Previous Candle')
labelTextColor = input.color(color.white, 'Label Text Color', group='4 — Previous Candle')
labelOffset    = input.int(3, 'Label Offset (bars)', tooltip='Shift labels right', group='4 — Previous Candle')
// NEW: Font size for labels
labelFontSize  = input.string('small', 'Label Font Size', options=['tiny', 'small', 'normal', 'large', 'huge'], group='4 — Previous Candle')

//══════════════════════════════════════════
// 5. TABLE
//══════════════════════════════════════════
show_TAB    = input.bool(false, 'Show Table', group='5 — Table')
cho_Pos_TAB = input.string('↑→', 'Position', options=['↑', '←↑', '↑→', '↓', '←↓', '↓→'], group='5 — Table')
posi_TAB    = cho_Pos_TAB == '↑→' ? position.top_right : cho_Pos_TAB == '←↑' ? position.top_left : cho_Pos_TAB == '↑' ? position.top_center : cho_Pos_TAB == '↓' ? position.bottom_center : cho_Pos_TAB == '←↓' ? position.bottom_left : cho_Pos_TAB == '↓→' ? position.bottom_right : na

//══════════════════════════════════════════
// CALCULATIONS
//══════════════════════════════════════════
prevHigh = high[1]
prevLow  = low[1]

bull = close[1] > high[2]
bear = close[1] < low[2]

breakPrevHigh = high > prevHigh
breakPrevLow  = low < prevLow

alertcondition(breakPrevHigh, 'Break Previous Candle High', '{{ticker}} broke ABOVE previous candle HIGH on {{interval}}')
alertcondition(breakPrevLow,  'Break Previous Candle Low',  '{{ticker}} broke BELOW previous candle LOW on {{interval}}')

// Daily data for table
DOM240 = (timeframe.multiplier <= 240)
[D_o_0, D_c_0, D_h_0, D_l_0] = request.security(syminfo.tickerid, 'D', [open[0], close[0], high[0], low[0]], lookahead = barmerge.lookahead_on)
[D_o_1, D_c_1, D_h_1, D_l_1] = request.security(syminfo.tickerid, 'D', [open[1], close[1], high[1], low[1]], lookahead = barmerge.lookahead_on)
[D_o_2, D_c_2, D_h_2, D_l_2] = request.security(syminfo.tickerid, 'D', [open[2], close[2], high[2], low[2]], lookahead = barmerge.lookahead_on)

D_bull = D_c_1 > D_h_2
D_bear = D_c_1 < D_l_2
txt_D = D_bull ? 'Bullish' : D_bear ? 'Bearish' : 'Consolidation'
txt   = bull ? 'Bullish' : bear ? 'Bearish' : 'Consolidation'

//══════════════════════════════════════════
// BIAS LINES (Bullish / Bearish / Consolidation)
//══════════════════════════════════════════
var line line_bull   = na
var line line_bear   = na
var line line_cons_h = na
var line line_cons_l = na

if timeframe.isintraday or timeframe.isdwm
    if Bias_bull and bull
        line_bull := line.new(bar_index[1], high[1], bar_index+1, high[1], extend=ext_Bias_bull, color=col_Bias_bull, style=sty_Bias_bull, width=size_Bias_bull)
        line.delete(line_bull[tot_Bias_bull])
    if Bias_bear and bear
        line_bear := line.new(bar_index[1], low[1], bar_index+1, low[1], extend=ext_Bias_bear, color=col_Bias_bear, style=sty_Bias_bear, width=size_Bias_bear)
        line.delete(line_bear[tot_Bias_bear])
    if Bias_conso and not bull and not bear
        line_cons_h := line.new(bar_index[1], high[1], bar_index+1, high[1], extend=ext_Bias_conso, color=col_Bias_conso, style=sty_Bias_conso, width=size_Bias_conso)
        line_cons_l := line.new(bar_index[1], low[1], bar_index+1, low[1], extend=ext_Bias_conso, color=col_Bias_conso, style=sty_Bias_conso, width=size_Bias_conso)
        line.delete(line_cons_h[tot_Bias_conso])
        line.delete(line_cons_l[tot_Bias_conso])

//══════════════════════════════════════════
// PREVIOUS CANDLE HIGH / LOW MARKING
//══════════════════════════════════════════
var line  prevHighLine = na
var line  prevLowLine  = na
var label prevHighLbl  = na
var label prevLowLbl   = na

// Convert font size string to label size constant
fontSize = 
   labelFontSize == 'tiny'  ? size.tiny :
   labelFontSize == 'small' ? size.small :
   labelFontSize == 'normal'? size.normal :
   labelFontSize == 'large' ? size.large :
   labelFontSize == 'huge'  ? size.huge : size.small

if showPrevHL
    line.delete(prevHighLine)
    line.delete(prevLowLine)
    label.delete(prevHighLbl)
    label.delete(prevLowLbl)

    prevHighLine := line.new(
        bar_index - 1, prevHigh,
        bar_index,     prevHigh,
        extend = prevHighExt,
        color  = prevHighColor,
        style  = prevHighStyle,
        width  = prevHighWidth
    )
    prevLowLine := line.new(
        bar_index - 1, prevLow,
        bar_index,     prevLow,
        extend = prevLowExt,
        color  = prevLowColor,
        style  = prevLowStyle,
        width  = prevLowWidth
    )

    if showLabels
        prevHighLbl := label.new(
            bar_index + labelOffset, prevHigh,
            text      = "H: " + str.tostring(prevHigh),
            xloc      = xloc.bar_index,
            yloc      = yloc.price,
            style     = label.style_none,
            textcolor = labelTextColor,
            size      = fontSize
        )
        prevLowLbl := label.new(
            bar_index + labelOffset, prevLow,
            text      = "L: " + str.tostring(prevLow),
            xloc      = xloc.bar_index,
            yloc      = yloc.price,
            style     = label.style_none,
            textcolor = labelTextColor,
            size      = fontSize
        )
else
    line.delete(prevHighLine)
    line.delete(prevLowLine)
    label.delete(prevHighLbl)
    label.delete(prevLowLbl)
    prevHighLine := na
    prevLowLine  := na
    prevHighLbl  := na
    prevLowLbl   := na

//══════════════════════════════════════════
// TABLE
//══════════════════════════════════════════
var table tableData = table.new(position=posi_TAB, columns=6, rows=15, frame_color=color.new(color.black,0), frame_width=1, border_color=color.new(color.black,0), border_width=1)
if show_TAB
    table.cell(tableData, 0, 0, 'D', bgcolor=color.new(color.blue, 80))
    table.cell(tableData, 0, 1, txt_D, bgcolor=color.new(color.yellow, 80))
    if DOM240 and not timeframe.isdwm
        table.cell(tableData, 1, 0, str.tostring(timeframe.period), bgcolor=color.new(color.blue, 80))
        table.cell(tableData, 1, 1, txt, bgcolor=color.new(color.yellow, 80))
````
