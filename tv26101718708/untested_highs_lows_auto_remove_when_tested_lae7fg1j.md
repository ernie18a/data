# Untested Highs & Lows (Auto Remove When Tested)

- url: https://www.tradingview.com/script/LAE7fG1J-Untested-Highs-Lows-Auto-Remove-When-Tested/
- type: indicator
- pine_id: PUB;a9c30033402144758d1b73c698f2aca2
- version: 1.0

## Description

📌 Indicator Name: Untested Liquidity Highs & Lows
🧠 Description

This indicator plots untested swing highs and swing lows on the chart as horizontal liquidity levels.

These levels represent areas where price previously reversed (pivot points) but has not yet returned to “mitigate” or “take” the liquidity resting at those prices.

🔴 Red lines = Untested liquidity levels
When price revisits and “sweeps” a level, it is automatically removed from the chart.

The goal of this tool is not to predict direction, but to visualize where liquidity is resting in the market and how price interacts with those areas over time.

📊 How to Use It
1. Identify Liquidity Zones
Red lines mark swing highs and swing lows that have not yet been revisited
These are areas where stop orders and pending liquidity are likely resting
2. Understand Market Behavior

Price often moves toward liquidity before reversing or continuing trend direction.
These levels help you see where price may be drawn next.

3. Watch for Sweeps

When price moves through a level and does not respect it:

The line disappears automatically
This represents liquidity being taken (swept)

Sweeps are often followed by:

reversals
expansions
continuation moves after mitigation
🎯 Trading Application

Traders commonly use this tool to:

Identify potential target zones (liquidity pools)
Wait for liquidity sweeps before entries
Confirm market intent (accumulation vs distribution)
Avoid entering before liquidity is taken
⚠️ Important Note

This indicator does not predict direction.
It simply maps where liquidity exists and when it is removed, which is a core concept in modern price action and ICT-style trading models.

## Source Code

````pine
//@version=6
indicator("Untested Highs & Lows (Auto Remove When Tested)", overlay=true, max_lines_count=500)

// ─────────────────────────────
// INPUTS
// ─────────────────────────────
leftBars  = input.int(3, "Left Bars", minval=1)
rightBars = input.int(3, "Right Bars", minval=1)
tolPerc   = input.float(0.1, "Tolerance %", step=0.1)

// ─────────────────────────────
// SWINGS
// ─────────────────────────────
ph = ta.pivothigh(high, leftBars, rightBars)
pl = ta.pivotlow(low, leftBars, rightBars)

// ─────────────────────────────
// STORAGE
// ─────────────────────────────
var float[] levels = array.new_float()
var line[]  lines  = array.new_line()

tol(level) => level * (tolPerc / 100)

// ─────────────────────────────
// ADD HIGH (UNTESTED LIQUIDITY)
// ─────────────────────────────
if not na(ph)
    array.push(levels, ph)
    array.push(lines,
        line.new(bar_index - rightBars, ph, bar_index, ph,
        extend=extend.right, color=color.red, width=2))

// ─────────────────────────────
// ADD LOW (UNTESTED LIQUIDITY)
// ─────────────────────────────
if not na(pl)
    array.push(levels, pl)
    array.push(lines,
        line.new(bar_index - rightBars, pl, bar_index, pl,
        extend=extend.right, color=color.red, width=2))

// ─────────────────────────────
// CHECK + REMOVE WHEN TESTED
// ─────────────────────────────
if array.size(levels) > 0
    for i = array.size(levels) - 1 to 0
        lvl = array.get(levels, i)
        ln  = array.get(lines, i)

        // if price touches level → delete it
        if high >= lvl - tol(lvl) and low <= lvl + tol(lvl)
            line.delete(ln)
            array.remove(levels, i)
            array.remove(lines, i)
````
