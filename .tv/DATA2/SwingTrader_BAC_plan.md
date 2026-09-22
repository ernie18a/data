<!-- tradingview-pine-id: PUB;ed0e57c136a14038877126b9872eff72 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# SwingTrader BAC plan

Source: https://www.tradingview.com/script/C9Onj0Of-SwingTrader-BAC-plan/

## Description

Draws a fixed swing-trade plan for BAC on the chart: three scaled buy levels, a stop, a target, and the indicators behind them. It is an annotation of one idea, not a signal generator.

WHAT IT DRAWS
- Lime lines: three buy levels for a scaled entry (1/5, 2/5, 2/5 of the position). Each label says how many indicators line up there and which ones:
    57.11: level + 0.5 Fibonacci + parallel channel lower rail (3 indicators)
    52.87: level + 0.786 Fibonacci + a small 1.4% gap fill (3 indicators, the gap is minor)
    51.20: level only (1 indicator)
- Red line: the stop, 49.66 (about 3% below the last level)
- Aqua dashed line: the target, 63.46
- Orange dotted line: another level (54.63)
- Purple dashed lines: Fibonacci retracements (0.382 and 0.618)
- Blue lines: the two rails of a parallel channel (2 touches on each rail), extended to the right

HOW THE LEVELS WERE CHOSEN
The levels come from swing pivots, prior swing highs and lows clustered within about 1.5%. Each level is labeled with how many times price has already returned to it ("next hit #1" is the first return, "#2" the second). A level counts as an indicator when it lines up with a Fibonacci retracement, a channel rail, or an unfilled gap. Gaps under about 2% are weak.

READ THIS BEFORE USING
- The levels are fixed. They are hard-coded from data through 9/18/2026 and do not update. They will go stale as price moves.
- The 3.1 to 1 reward-to-risk applies only if all three levels fill. If only the first level fills, the reward is smaller than the risk.
- Nothing here has been backtested. It is not a trade signal.
- There are no inputs.

Not financial advice. For education only.

---

## Source Code

````pine
//@version=6
indicator("SwingTrader BAC plan", overlay=true, max_lines_count=200, max_labels_count=200)
// Built from the SwingTrader scanner on data through 2026-09-18. Levels are fixed; regenerate to refresh.
// lime = ladder rungs, red = stop, aqua = target, orange = other levels, purple = fib, blue = channel rails
var array<line> ls = array.new_line()
var array<label> lbs = array.new_label()
if barstate.islast
    for l in ls
        line.delete(l)
    array.clear(ls)
    for lb in lbs
        label.delete(lb)
    array.clear(lbs)
    array.push(ls, line.new(bar_index - 130, 57.11, bar_index, 57.11, color=color.lime, width=3, style=line.style_solid, extend=extend.right))
    array.push(lbs, label.new(bar_index + 3, 57.11, "RUNG 1 57.11: 3 indicators (level, fib 0.5, channel rail); next hit #2", style=label.style_none, textcolor=color.lime, size=size.small))
    array.push(ls, line.new(bar_index - 130, 52.87, bar_index, 52.87, color=color.lime, width=3, style=line.style_solid, extend=extend.right))
    array.push(lbs, label.new(bar_index + 3, 52.87, "RUNG 2 52.87: 3 indicators (level, fib 0.786, gap fill 1.4%); next hit #1", style=label.style_none, textcolor=color.lime, size=size.small))
    array.push(ls, line.new(bar_index - 130, 51.20, bar_index, 51.20, color=color.lime, width=3, style=line.style_solid, extend=extend.right))
    array.push(lbs, label.new(bar_index + 3, 51.20, "RUNG 3 51.20: 1 indicators (level); next hit #1", style=label.style_none, textcolor=color.lime, size=size.small))
    array.push(ls, line.new(bar_index - 130, 49.66, bar_index, 49.66, color=color.red, width=3, style=line.style_solid, extend=extend.right))
    array.push(lbs, label.new(bar_index + 3, 49.66, "STOP 49.66", style=label.style_none, textcolor=color.red, size=size.small))
    array.push(ls, line.new(bar_index - 130, 63.46, bar_index, 63.46, color=color.aqua, width=2, style=line.style_dashed, extend=extend.right))
    array.push(lbs, label.new(bar_index + 3, 63.46, "TARGET 63.46", style=label.style_none, textcolor=color.aqua, size=size.small))
    array.push(ls, line.new(bar_index - 130, 54.63, bar_index, 54.63, color=color.new(color.orange, 15), width=1, style=line.style_dotted, extend=extend.right))
    array.push(lbs, label.new(bar_index + 3, 54.63, "54.63: level; next hit #1", style=label.style_none, textcolor=color.new(color.orange, 15), size=size.small))
    array.push(ls, line.new(bar_index - 130, 59.14, bar_index, 59.14, color=color.new(color.purple, 25), width=1, style=line.style_dashed, extend=extend.right))
    array.push(lbs, label.new(bar_index + 3, 59.14, "fib 0.382 59.14", style=label.style_none, textcolor=color.new(color.purple, 25), size=size.small))
    array.push(ls, line.new(bar_index - 130, 55.38, bar_index, 55.38, color=color.new(color.purple, 25), width=1, style=line.style_dashed, extend=extend.right))
    array.push(lbs, label.new(bar_index + 3, 55.38, "fib 0.618 55.38", style=label.style_none, textcolor=color.new(color.purple, 25), size=size.small))
    array.push(ls, line.new(1784606400000, 66.60, 1789704000000, 63.57, xloc=xloc.bar_time, color=color.new(color.blue, 10), width=2, extend=extend.right))
    array.push(lbs, label.new(bar_index + 3, 63.57, "channel upper rail 2x 63.57", style=label.style_none, textcolor=color.blue, size=size.small))
    array.push(ls, line.new(1784606400000, 60.06, 1789704000000, 57.04, xloc=xloc.bar_time, color=color.new(color.blue, 10), width=2, extend=extend.right))
    array.push(lbs, label.new(bar_index + 3, 57.04, "channel lower rail 2x 57.04", style=label.style_none, textcolor=color.blue, size=size.small))
````
