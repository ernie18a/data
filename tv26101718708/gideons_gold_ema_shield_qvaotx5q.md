# Gideons Gold - EMA Shield

- url: https://www.tradingview.com/script/QvaoTX5q-Gideons-Gold-EMA-Shield/
- type: indicator
- pine_id: PUB;648ff31f07bc4cb1a7e8535048a41802
- version: 1.0

## Description

[b]Gideons Gold — EMA Shield[/b]

EMA Shield provides a clear visual reference for where price stands. Inspired by the discipline of Gideon’s men holding their positions in Judges 7:21, it reflects our focus on preparation, patience, and a defined plan. At Gideons Gold, we aim to bring practical value to the trading community through focused, easy-to-use tools. Less Noise. Greater Focus.

EMA Shield plots an EMA of candle highs and an EMA of candle lows to form a channel. The length defaults to 20 periods, but you can change it in settings to suit your approach.

[b]Reading the colors:[/b]

- Green: The current close is above the upper EMA.
- Red: The current close is below the lower EMA.
- Orange: The current close is inside the channel or on either boundary.
Both lines and the optional fill change color together, making price’s position easy to recognize.

[b]Features:[/b]

- Adjustable EMA length, defaulting to 20.
- Custom colors for above, below, and inside the channel.
- Adjustable line thickness from 1–5.
- Optional channel fill with customizable transparency.

[b]Using EMA Shield[/b]

Use the channel alongside price structure and your own entry conditions to maintain a consistent view of price location. Orange identifies price within the channel; it does not automatically mean consolidation. Green and red identify price above or below the channel, not guaranteed trade opportunities.

The channel uses standard EMA calculations. Values and colors can change while a candle is forming. This version does not include built-in alert conditions or place trades. Despite its name, EMA Shield does not protect against trading losses.

[b]The inspiration behind Gideons Gold[/b]
Gideon’s story inspires humility, discipline, and the reminder that more is not always better. We bring that perspective to clearer charts and purposeful tools. The biblical connection reflects our values, not a promise of trading success.

[i][b]Less Noise. Greater Focus.[/b][/i]
Clearer charts. Focused tools. A rules-based approach.

## Source Code

````pine
// ©2026 Gideons Gold — EMA Shield
//@version=6
indicator("Gideons Gold — EMA Shield", shorttitle = "Gideons Gold — EMA Shield", overlay = true)

// ───────────── Channel Settings ─────────────
len = input.int(
    20,
    "EMA Length",
    minval = 1,
    tooltip = "Number of bars used to calculate both EMAs.",
    group = "Channel Settings"
)

// ───────────── Appearance ─────────────
bullColor = input.color(color.green, "Above Channel", group = "Appearance")
bearColor = input.color(color.red, "Below Channel", group = "Appearance")
neutralColor = input.color(color.orange, "Inside Channel", group = "Appearance")

lineWidth = input.int(
    2,
    "Line Width",
    minval = 1,
    maxval = 5,
    group = "Appearance"
)

showFill = input.bool(true, "Show Channel Fill", group = "Appearance")

fillTransparency = input.int(
    85,
    "Fill Transparency",
    minval = 0,
    maxval = 100,
    group = "Appearance"
)

// ───────────── Calculations ─────────────
emaHigh = ta.ema(high, len)
emaLow = ta.ema(low, len)

chColor = close < emaLow ? bearColor : close > emaHigh ? bullColor : neutralColor

// ───────────── Plots ─────────────
pHigh = plot(emaHigh, "EMA High", color = chColor, linewidth = lineWidth)
pLow = plot(emaLow, "EMA Low", color = chColor, linewidth = lineWidth)

fill(
    pHigh,
    pLow,
    color = showFill ? color.new(chColor, fillTransparency) : na
)
````
