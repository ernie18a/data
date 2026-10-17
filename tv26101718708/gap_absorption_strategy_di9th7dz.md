# Gap Absorption Strategy

- url: https://www.tradingview.com/script/Di9tH7dZ-Gap-Absorption-Strategy/
- type: strategy
- pine_id: PUB;69ecc82a69094e5d97434d48fb8b62e3
- version: 1.0

## Description

Like the nature, markets don't like the void, and this is something we can take advantage of by trading gaps on some markets.
This technique is well known, so I wanted to write a tiny script based on this strategy to get a bit more comfortable with it.

[b]IMPORTANT:[/b] Default parameters wont give you good trades on every markets, you need to modify these parameters to see which proportions correspond to the stock you're trading.

This script triggers signals on predefined variation of a stock price after a gap, and allows its user to configure TP and SL prices corresponding to a specific percentage of this gap movement.

[b]Note:[/b] We can observe that opening gaps are often the most interesting.

[b]Options[/b]
[list]
[*] Trigger: the price variation you want to trigger on (in % of the price)
[*] Stop Loss : in % of the gap
[*] Take profit : in % of the gap

[*] A small table is displayed in the top right corner of the chart to give you TP/SL/Signal prices for each opportunity
[*] SL (red line) and TP (green line) are also displayed on the chart when a signal is triggered
[*] Information concerning the current opportunity is given at the bottom of the chart
[/list]

[b]Note:[/b] This script is based on the Gap-Size-Indicator that I published a few weeks ago.
[chart]https://www.tradingview.com/script/dtSdvM0J-GSI-Gap-Size-Indicator/[/chart]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © noop42

//@version=5
strategy(title="Gap Absortion Strategy", shorttitle="GAS", overlay=true)

gap_value = 0.0
pct_trig = input(0.5, 'trigger (% of the price corresponding to the gap amount)')
stop_pct = input(0.25, 'StopLoss (in % of the gap)')
target_pct = input(0.8, 'Target, (in % of the gap) (default is the whole gap value)')

tp_color = input.color(color.green, "Target color")
sl_color = input.color(color.red, "Stop Loss Color")
entry_color = input.color(color.gray, "Entry color")

var line tpl = na
var line sll = na

gap = close[1] > open ? close[1] - open : close[1] < open ? open - close[1] : 0
gap_side = close[1] > open ? 1 : -1
gap_pct = gap / close[1] * 100
interesting_gap = gap_pct >= pct_trig
long = interesting_gap and gap_side == 1 and strategy.position_size == 0.0
short = interesting_gap and gap_side == -1 and strategy.position_size == 0.0

var entry = 0.0
var stop = 0.0
var target = 0.0
if gap and interesting_gap
    if long
        entry := open
        target := entry + gap * target_pct
        stop := entry - gap * stop_pct
        stop
    if short
        entry := open
        target := entry - gap * target_pct
        stop := entry + gap * stop_pct
        stop

exitTP = strategy.position_size != 0.0 and (ta.cross(high, target) or ta.cross(low, target))
exitSL = strategy.position_size != 0.0 and ta.cross(close, stop)
exit = exitTP or exitSL

strategy.entry('Buy', strategy.long, when=long)
strategy.close('Buy', when=exit)
strategy.entry('Sell', strategy.short, when=short)
strategy.close('Sell', when=exit)

if exit
    entry := 0.0
    target := 0.0
    stop := 0.0
    line.delete(tpl)
    line.delete(sll)
plotshape(long ? 1 : 0, style=shape.triangleup, size=size.tiny, location=location.bottom, color=color.new(color.lime, 0), text='Bearish gap\nBuy signal')
plotshape(short ? 1 : 0, style=shape.triangledown, size=size.tiny, location=location.bottom, color=color.new(color.red, 0), text='Bullish gap\nSell signal')

plotshape(exitTP ? 1 : 0, style=shape.xcross, size=size.tiny, location=location.bottom, color=color.new(color.green, 0), text='Hit TP')
plotshape(exitSL ? 1 : 0, style=shape.xcross, size=size.tiny, location=location.bottom, color=color.new(color.orange, 0), text='Hit SL')

var tbl = table.new(position.top_right, 2, 5)

if target[1] == 0.0 and target != 0.0
    tpl := line.new(bar_index[1], target, bar_index, target, extend=extend.right, color=tp_color)
    sll := line.new(bar_index[1], stop, bar_index, stop, extend=extend.right, color=sl_color)

table.cell(tbl, 0, 0, 'Current target', bgcolor=#cccccc)
table.cell(tbl, 1, 0, str.tostring(target, "#.####"), bgcolor=tp_color)
table.cell(tbl, 0, 1, 'Entry Signal', bgcolor=#cccccc)
table.cell(tbl, 1, 1, str.tostring(entry, "#.####"), bgcolor=entry_color)
table.cell(tbl, 0, 2, 'Stop Signal', bgcolor=#cccccc)
table.cell(tbl, 1, 2, str.tostring(stop, "#.####"), bgcolor=sl_color)
````
