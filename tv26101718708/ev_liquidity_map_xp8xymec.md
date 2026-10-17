# EV Liquidity Map

- url: https://www.tradingview.com/script/XP8xYMec-EV-Liquidity-Map/
- type: indicator
- pine_id: PUB;a246d92f9779492b8f12700f433858e7
- version: 1.0

## Description

Automatically maps resting liquidity pools on any symbol and timeframe — then marks when they get swept.

What it shows:

BSL (Buy Side Liquidity) — swing highs where short sellers place stops. Blue dashed lines above price.
SSL (Sell Side Liquidity) — swing lows where long traders place stops. Red dashed lines below price.
Swept levels — when price takes out a level, the line turns gray/dotted so you always know what's fresh vs. consumed.
Wick Sweep labels — when price wicks through a level but closes back inside. This is the high-quality sweep: liquidity taken, smart money absorbed, reversal probable.
How to use it:

Price approaching a BSL/SSL = potential target for a liquidity hunt
Wick sweep label appears = look for reversal entry confirmation on your entry TF
Combine with your structure tools (BOS/CHoCH) for full confluent setups
Inputs:

Swing Length — pivot lookback for detecting highs/lows (default 10)
Max Levels Each Side — how many live levels to keep on screen (default 5)
Show Sweep Labels — toggle wick sweep markers
BSL / SSL / Swept colors — fully customizable
Alerts included:

BSL Wick Sweep
SSL Wick Sweep
Works on all symbols and timeframes. Pairs well with EV BOS/CHoCH Zones and EV Fair Value Gaps.

## Source Code

````pine
//@version=6
indicator("EV Liquidity Map", shorttitle="LIQ", overlay=true, max_lines_count=300, max_labels_count=200)

// ─── Inputs ───────────────────────────────────────────────────────────────────
swingLen  = input.int(10,    "Swing Length",         minval=3,  maxval=50)
maxLevels = input.int(5,     "Max Levels Each Side", minval=1,  maxval=15)
showSweep = input.bool(true, "Show Sweep Labels")
bslCol    = input.color(color.new(#2962ff, 0),  "BSL Color")
sslCol    = input.color(color.new(#f23645, 0),  "SSL Color")
sweptCol  = input.color(color.new(#787b86, 60), "Swept Color")

// ─── Pivots ───────────────────────────────────────────────────────────────────
swingH = ta.pivothigh(high, swingLen, swingLen)
swingL = ta.pivotlow(low,  swingLen, swingLen)

// ─── State ────────────────────────────────────────────────────────────────────
var line[]  bslLines = array.new_line()
var bool[]  bslSwept = array.new_bool()
var line[]  sslLines = array.new_line()
var bool[]  sslSwept = array.new_bool()

f_trim(line[] lines, bool[] swept, int maxN) =>
    while array.size(lines) > maxN
        line.delete(array.shift(lines))
        array.shift(swept)

// ─── New BSL (swing high = resting sell stops above) ─────────────────────────
if not na(swingH)
    pBar = bar_index - swingLen
    ln   = line.new(pBar, swingH, pBar, swingH, color=bslCol, width=1, style=line.style_dashed, extend=extend.right)
    label.new(pBar, swingH, "BSL", style=label.style_label_right, color=color.new(bslCol, 80), textcolor=bslCol, size=size.small)
    array.push(bslLines, ln)
    array.push(bslSwept, false)
    f_trim(bslLines, bslSwept, maxLevels)

// ─── New SSL (swing low = resting buy stops below) ────────────────────────────
if not na(swingL)
    pBar = bar_index - swingLen
    ln   = line.new(pBar, swingL, pBar, swingL, color=sslCol, width=1, style=line.style_dashed, extend=extend.right)
    label.new(pBar, swingL, "SSL", style=label.style_label_right, color=color.new(sslCol, 80), textcolor=sslCol, size=size.small)
    array.push(sslLines, ln)
    array.push(sslSwept, false)
    f_trim(sslLines, sslSwept, maxLevels)

// ─── Sweep detection ─────────────────────────────────────────────────────────
bslSweepBar = false
sslSweepBar = false

n = array.size(bslLines)
if n > 0
    for i = 0 to n - 1
        if not array.get(bslSwept, i)
            lvl = line.get_y1(array.get(bslLines, i))
            if high > lvl
                array.set(bslSwept, i, true)
                line.set_color(array.get(bslLines, i), sweptCol)
                line.set_style(array.get(bslLines, i), line.style_dotted)
                if showSweep and close < lvl
                    label.new(bar_index, high, "⚡ BSL", style=label.style_label_down, color=color.new(#2962ff, 55), textcolor=color.white, size=size.tiny)
                    bslSweepBar := true

m = array.size(sslLines)
if m > 0
    for i = 0 to m - 1
        if not array.get(sslSwept, i)
            lvl = line.get_y1(array.get(sslLines, i))
            if low < lvl
                array.set(sslSwept, i, true)
                line.set_color(array.get(sslLines, i), sweptCol)
                line.set_style(array.get(sslLines, i), line.style_dotted)
                if showSweep and close > lvl
                    label.new(bar_index, low, "⚡ SSL", style=label.style_label_up, color=color.new(#f23645, 55), textcolor=color.white, size=size.tiny)
                    sslSweepBar := true

// ─── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(bslSweepBar, "BSL Wick Sweep", "Buy Side Liquidity wick swept — {{ticker}} {{interval}}")
alertcondition(sslSweepBar, "SSL Wick Sweep", "Sell Side Liquidity wick swept — {{ticker}} {{interval}}")
````
