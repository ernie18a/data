<!-- tradingview-pine-id: PUB;02f5bb06126f471085239dbf9358d189 -->
<!-- tradingviewscripts-format: 1 -->
# Risk Management Chart

Source: https://www.tradingview.com/script/Nl9IHqV1-risk-management-chart/

## Description

█ OVERVIEW

Risk Management Chart allows you to calculate and visualize equity and risk depend on your risk-reward statistics which you can set at the settings.
This script generates random trades and variants of each trade based on your settings of win/loss percent and shows it on the chart as different polyline and also shows thick line which is average of all trades.
It allows you to visualize and possible to analyze probability of your risk management. Be using different settings you can adjust and change your risk management for better profit in future.
It uses compound interest  for each trade. 
Each variant of trade is shown as a polyline with color from gradient depended on it last profit.
Also I made blurred lines for better visualization with function :
[pine]
poly(_arr, _col, _t, _tr) =>
    for t = 1 to _t
        polyline.new(_arr, false, false, xloc.bar_index, color.new(_col, 0 + t * _tr), line_width = t)
[/pine]

█ HOW TO USE

Just add it to the cart and expand the window.
https://www.tradingview.com/x/X6gEMQVC/

█ SETTINGS

Start Equity $ - Amount of money to start with (your equity for trades)
Win Probability % -  Percent of your win / loss trades
Risk/Reward Ratio - How many profit you will get for each risk(depends on risk per trade %)
Number of Trades - How many trades will be generated for each variant of random trading
Number of variants(lines) - How many variants will be generated for each trade
Risk per Trade % -risk % of current equity for each trade
 
If you have any ask it at comments.
Hope it will be useful.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © NoveltyTrade

//@version=5
indicator("Risk Management Chart", max_labels_count = 500, max_lines_count = 500, max_polylines_count = 100)

s_equ       = input.float   (1000, 'Start Equity $')
win         = input.int     (  55, 'Win Probability %')
rrr         = input.float   ( 1.5, 'Risk/Reward Ratio', step = 0.5)
num         = input.int     (  40, 'Number of Trades')
lin         = input.int     (  40, 'Number of variants(lines)', 2, 100)
risk        = input.float   ( 1.0, 'Risk per Trade %', step = 0.1)
col1        = input.color   (#3333ff, 'colors', inline = 'col')
col2        = input.color   (#ff0000, '', inline = 'col')
col3        = input.color   (#3333ff, '', inline = 'col')

var tb      = table.new(position.top_center, 2, 3, na, na, 0, na)
var cp      = array.new <chart.point> (num + 1, na)
var cpa     = array.new <chart.point> (num + 1, na)
var m       = matrix.new      <float> (lin, num, na)
var coef    = num > 150 ? 10 : num > 50 ? 5 : 2
var transp  = color.new(col1, 100)
var pr      = s_equ * 0.02
var tmp     = s_equ
var rnd     = 0.

poly(_arr, _col, _t, _tr) =>
    for t = 1 to _t
        polyline.new(_arr, false, false, xloc.bar_index, color.new(_col, 0 + t * _tr), line_width = t)

method t_c(table _id, int _c, int _r, string _txt, float _val ,color _col) =>
    _id.cell(_c, _r, _txt, 0, 0, color.gray)
    _id.cell(_c + 1, _r, str.tostring(_val / s_equ * 100, format.percent) + ' (' + str.tostring(_val, '#.##') + ' $)', 0, 0, _col)    

if barstate.islastconfirmedhistory
    cp.set (0, chart.point.from_index(bar_index - num, s_equ))
    cpa.set(0, chart.point.from_index(bar_index - num, s_equ))  
    for i = 0 to lin - 1
        for j = 0 to num - 1
            rnd := math.round(math.random() * 100)
            tmp := rnd > win ? tmp * (1 - risk / 100) : tmp * (1 + risk * rrr / 100)
            m.set(i, j, tmp)
        tmp := s_equ

    min     = s_equ - int((s_equ - m.min() * 0.98) / pr ) * pr
    max     = s_equ + int((m.max() * 1.02 - s_equ) / pr ) * pr
    ff      = min
    pr      := (max - min) > s_equ * 1.5 ? (max - min) / 10 : s_equ * 0.02

    for i = 0 to lin - 1    
        for j = 0 to num - 1
            cp.set(j + 1, chart.point.from_index(bar_index - num + j + 1, m.get(i, j)))
        poly(cp, color.from_gradient(m.get(i, num - 1), array.min(m.col(num - 1)), array.max(m.col(num - 1)), col2, col1), 3, 33)

    for k = 0 to num - 1
        cpa.set(k + 1, chart.point.from_index(bar_index - num + k + 1, array.avg(m.col(k))))   
        label.new(bar_index - num + k + 1, array.avg(m.col(k)), tooltip =  str.tostring(array.avg(m.col(k)), '#.##'), style = label.style_label_down, color = transp)
        if k % coef == 0
            line.new(bar_index - num + k + coef, min, bar_index - num + k + 1, max, color = color.new(color.gray, 80), style = line.style_dashed)
            label.new(bar_index - num + k + coef, min, str.tostring(k + coef), style = label.style_label_up, color = transp,  textcolor = color.gray)

    for f = min to max - pr by pr
        ff += pr
        line.new(bar_index - num - 1, f, bar_index, f, color = color.new(color.gray, 80), style = line.style_dashed)
        label.new(bar_index - num - 1, ff, str.tostring(ff), style = label.style_label_right, color = transp, textcolor = color.gray)
    
    box.new(bar_index - num - 1, max, bar_index + 2, min, color.gray, 1, bgcolor = na)
    tb.t_c(0, 0, 'max profit', m.max() - s_equ, color.green)
    tb.t_c(0, 1, 'avg profit', array.avg(m.col(num-1)) - s_equ, col3)
    tb.t_c(0, 2, 'max drawdown', -(s_equ - m.min()), col2)
    poly(cpa, col3, 10, 10)
````
