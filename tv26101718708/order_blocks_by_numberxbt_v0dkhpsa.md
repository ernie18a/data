# Order Blocks by @numberxbt

- url: https://www.tradingview.com/script/v0dKHPsa-Order-Blocks-by-numberxbt/
- type: indicator
- pine_id: PUB;91010e09371d4e46a2145c2bf7010e98
- version: 1.0

## Description

[b]Overview[/b]
This indicator automatically detects and plots Bullish and Bearish Order Blocks based on SMC and ICT principles. It helps traders identify high probability naked supply and demand zones, tracks their mitigation status, and automatically removes invalidated zones to keep your chart clean.

[image]https://www.tradingview.com/x/MBlVcxCE/[/image]

[b]Key features[/b]
[list]
[*] [b]Automatic detection[/b] - Instantly identifies valid bullish and bearish order blocks based on a strict 3-candle displacement pattern.
[*] [b]Auto Invalidation[/b] - Automatically deletes order blocks if the price closes completely through them.
[*] [b]Equilibrium Midlines[/b] - Optional 50% midlines drawn through the center of each order block for precise, sniper-like entries.
[*] [b]Chart Clutter Control[/b] - Configurable limits on the maximum number of unmitigated and mitigated zones displayed.
[*] [b]Mitigation Tracking[/b] - Monitors price action to track when an order block has been tapped (mitigated).
[/list]

[b]Settings[/b]
[list]
[*] [b]Show Bull/Bear OB:[/b] Toggle the visibility of Bullish (Demand) and Bearish (Supply) Order Blocks.
[*] [b]Colors:[/b] Customize the background transparency and border colors for both Bullish and Bearish zones.
[*] [b]Hide Mitigated:[/b] Check these boxes to automatically hide Order Blocks once they have been tapped, keeping your chart focused only on fresh zones.
[*] [b]Max Unmitigated / Max Mitigated:[/b] Set the maximum number of active and mitigated zones allowed on the chart. Older zones will be deleted once the limit is reached.
[*] [b]Show Midline:[/b] Toggles the 50% equilibrium line inside the Order Blocks.
[/list]

[b]How it works[/b]
The indicator uses a classic 3-candle sequence to define institutional footprints:
[list]
[*] [b]Bullish Order Block:[/b] Formed by a bearish candle, followed by a bullish candle, followed by a strong bullish continuation. The zone is drawn over the initial bearish candle.
[*] [b]Bearish Order Block:[/b] Formed by a bullish candle, followed by a bearish candle, followed by a strong bearish continuation. The zone is drawn over the initial bullish candle.
[/list]

[i]Note: This indicator focuses purely on Order Blocks. Breaker blocks and other complex features have been removed to provide a clean, lightweight, and highly focused trading tool.[/i]

[b]Disclaimer[/b]
[i]This indicator is for educational and informational purposes only. It does not constitute financial advice. Trading involves risk, and past performance is not indicative of future results. Always do your own research and manage your risk accordingly.[/i]

## Source Code

````pine
//@version=6
indicator('Order Blocks by @numberxbt', overlay = true, max_boxes_count = 500, max_lines_count = 500)

sB = input.bool(true, 'Bull OB')
sS = input.bool(true, 'Bear OB')

bBg = input.color(color.new(color.green, 80), 'Bull OB BG')
bLn = input.color(color.green, 'Bull OB Line')
sBg = input.color(color.new(color.red, 80), 'Bear OB BG')
sLn = input.color(color.red, 'Bear OB Line')

hMB = input.bool(false, 'Hide Mit Bull')
hMS = input.bool(false, 'Hide Mit Bear')

mU = input.int(10, 'Max Unmit')
mM = input.int(10, 'Max Mit')

showMid = input.bool(true, 'Show Midline')
midCol = input.color(color.gray, 'Midline Color')

u = close > open
d = close < open

pB = sB and d[2] and u[1] and low > high[2]
pS = sS and u[2] and d[1] and high < low[2]

var uBB = array.new_box()
var uBS = array.new_box()
var mBB = array.new_box()
var mBS = array.new_box()

var lUB = array.new_line()
var lUS = array.new_line()
var lMB = array.new_line()
var lMS = array.new_line()

if pB
    array.push(uBB, box.new(bar_index - 2, high[2], bar_index, low[2], bgcolor = bBg, border_color = bLn))
    if showMid
        array.push(lUB, line.new(bar_index - 2, (high[2] + low[2]) / 2, bar_index, (high[2] + low[2]) / 2, color = midCol))

if pS
    array.push(uBS, box.new(bar_index - 2, high[2], bar_index, low[2], bgcolor = sBg, border_color = sLn))
    if showMid
        array.push(lUS, line.new(bar_index - 2, (high[2] + low[2]) / 2, bar_index, (high[2] + low[2]) / 2, color = midCol))

if array.size(uBB) > mU
    box.delete(array.shift(uBB))
    if showMid
        line.delete(array.shift(lUB))

if array.size(uBS) > mU
    box.delete(array.shift(uBS))
    if showMid
        line.delete(array.shift(lUS))

if array.size(mBB) > mM
    box.delete(array.shift(mBB))
    if showMid
        line.delete(array.shift(lMB))

if array.size(mBS) > mM
    box.delete(array.shift(mBS))
    if showMid
        line.delete(array.shift(lMS))

if array.size(uBB) > 0
    for i = array.size(uBB) - 1 to 0 by 1
        bx = array.get(uBB, i)
        ln = showMid ? array.get(lUB, i) : na
        tp = box.get_top(bx)
        bt = box.get_bottom(bx)
        lf = box.get_left(bx)

        if close < bt
            box.delete(bx)
            if showMid
                line.delete(ln)
            array.remove(uBB, i)
            if showMid
                array.remove(lUB, i)
        else if low <= tp
            box.set_right(bx, bar_index)
            if showMid
                line.set_x2(ln, bar_index)
            if not hMB
                array.push(mBB, bx)
                if showMid
                    array.push(lMB, ln)
            else
                box.delete(bx)
                if showMid
                    line.delete(ln)
            array.remove(uBB, i)
            if showMid
                array.remove(lUB, i)
        else
            box.set_right(bx, bar_index)
            if showMid
                line.set_x2(ln, bar_index)

if array.size(uBS) > 0
    for i = array.size(uBS) - 1 to 0 by 1
        bx = array.get(uBS, i)
        ln = showMid ? array.get(lUS, i) : na
        tp = box.get_top(bx)
        bt = box.get_bottom(bx)
        lf = box.get_left(bx)

        if close > tp
            box.delete(bx)
            if showMid
                line.delete(ln)
            array.remove(uBS, i)
            if showMid
                array.remove(lUS, i)
        else if high >= bt
            box.set_right(bx, bar_index)
            if showMid
                line.set_x2(ln, bar_index)
            if not hMS
                array.push(mBS, bx)
                if showMid
                    array.push(lMS, ln)
            else
                box.delete(bx)
                if showMid
                    line.delete(ln)
            array.remove(uBS, i)
            if showMid
                array.remove(lUS, i)
        else
            box.set_right(bx, bar_index)
            if showMid
                line.set_x2(ln, bar_index)
````
