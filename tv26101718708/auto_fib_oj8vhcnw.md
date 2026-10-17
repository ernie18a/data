# Auto Fib

- url: https://www.tradingview.com/script/oj8VHCNW-Auto-Fib/
- type: indicator
- pine_id: PUB;fec22c26838345b18cef7c60fd9bc8c4
- version: 1.0

## Description

Adjustable window. I left it as a "Lookback Window (hours)" input defaulting to 24, so you can tighten it to 8 hours for a session fib or stretch it to 48 without touching code.
Guardrails. It's capped at 4,900 bars (Pine's history limit headroom) and clamped to available chart history, so it won't throw a runtime error on a fresh chart load or higher timeframes.
One note for the 1m: the 24-hour high on MNQ will usually be the overnight/RTH extreme, so on a day like today's chart the fib should anchor 1 right at that ~29,169 high and 0 at the 24h low — meaning your 0 anchor may shift lower than the 28,742 you drew manually, since the script grabs the absolute low of the window rather than a chosen swing point. If you want 0 pinned to a structural swing low instead of the raw 24h low, say the word and I'll switch the low anchor to pivot-confirmed logic.

## Source Code

````pine
//@version=6
indicator("Auto Fib", overlay=true, max_lines_count=20, max_labels_count=20, max_bars_back=5000)

hoursBack = input.float(24.0, "Lookback Window (hours)", minval=1.0, step=1.0)
flip = input.bool(false, "Flip Anchors")
extendRight = input.bool(true, "Extend Lines Right")
labelsOn = input.bool(true, "Show Labels")
colKey = input.color(color.black, "Key Levels (1 / 0 / -1)")
colFib = input.color(color.red, "Fib Levels")

ratios = array.from(1.0, 0.786, 0.236, 0.0, -0.236, -0.786, -1.0)

barsInWindow = math.round(hoursBack * 3600 / timeframe.in_seconds(timeframe.period))
lookback = math.max(2, math.min(math.min(barsInWindow, 4900), bar_index + 1))

hiVal = ta.highest(high, lookback)
loVal = ta.lowest(low, lookback)
hiOff = ta.highestbars(high, lookback)
loOff = ta.lowestbars(low, lookback)
startBar = bar_index + math.min(hiOff, loOff)

top = flip ? loVal : hiVal
bot = flip ? hiVal : loVal
rng = top - bot

var array<line> lns = array.new<line>()
var array<label> lbs = array.new<label>()

if barstate.islast
    if array.size(lns) == 0
        for i = 0 to array.size(ratios) - 1
            array.push(lns, line.new(bar_index, close, bar_index, close))
            array.push(lbs, label.new(bar_index, close, ""))
    for i = 0 to array.size(ratios) - 1
        r = array.get(ratios, i)
        p = bot + rng * r
        c = r == 1.0 or r == 0.0 or r == -1.0 ? colKey : colFib
        ln = array.get(lns, i)
        line.set_xy1(ln, startBar, p)
        line.set_xy2(ln, bar_index, p)
        line.set_extend(ln, extendRight ? extend.right : extend.none)
        line.set_color(ln, c)
        line.set_width(ln, 2)
        lb = array.get(lbs, i)
        if labelsOn
            label.set_xy(lb, bar_index, p)
            label.set_text(lb, str.tostring(r) + " (" + str.tostring(p, format.mintick) + ")")
            label.set_style(lb, label.style_label_left)
            label.set_textcolor(lb, c)
            label.set_color(lb, color.new(color.white, 100))
        else
            label.set_text(lb, "")

f0236 = bot + rng * 0.236
fn0236 = bot - rng * 0.236
alertcondition(ta.cross(close, f0236), "Cross 0.236", "Price crossed the 0.236 fib level")
alertcondition(ta.cross(close, fn0236), "Cross -0.236", "Price crossed the -0.236 fib level")
alertcondition(ta.cross(close, bot), "Cross 0", "Price crossed the 0 fib anchor")
````
