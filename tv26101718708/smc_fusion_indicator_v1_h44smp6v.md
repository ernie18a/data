# SMC Fusion Indicator v1

- url: https://www.tradingview.com/script/H44Smp6v-SMC-Fusion-Indicator-v1/
- type: indicator
- pine_id: PUB;c9d0ba0f7a91438d9e92e4c274b0d943
- version: 2.0

## Description

[b]SMC Fusion Indicator[/b]

[b]Overview[/b]

SMC Fusion Indicator is an original market structure tool designed to help traders identify trend shifts and key Smart Money Concepts (SMC) events in a clean and easy-to-read format.

Instead of filling the chart with unnecessary objects, the indicator focuses on highlighting important structural changes that can assist with market analysis and trade planning.

---

[b]Features

Market Structure[/b]

- Higher High (HH)
- Higher Low (HL)
- Lower High (LH)
- Lower Low (LL)

The indicator automatically identifies swing highs and swing lows to display the current market structure.

[b]Break of Structure (BOS)[/b]

A BOS is displayed when price breaks the previous confirmed swing in the direction of the current trend, indicating potential trend continuation.

[b]Change of Character (CHoCH)[/b]

A CHoCH is displayed when price breaks the previous swing against the current trend, signaling a possible market reversal or shift in direction.

[b]Visual Labels
[/b]
- Green labels indicate bullish structure.
- Red labels indicate bearish structure.
- Orange labels highlight CHoCH events.
- Clear labels keep the chart readable without excessive clutter.

[b]Alerts[/b]

Built-in alert conditions allow traders to receive notifications whenever a bullish or bearish market structure event occurs.

---

[b]How to Use[/b]

Bullish Scenario

1. Wait for a bullish CHoCH after a downtrend.
2. Watch for a bullish BOS confirming the new trend.
3. Use your own confirmation before entering a trade.

[b]Bearish Scenario[/b]

1. Wait for a bearish CHoCH after an uptrend.
2. Watch for a bearish BOS confirming the trend change.
3. Use proper risk management before entering a position.

---

[b]Recommended Timeframes[/b]

The indicator can be used on any timeframe, including:

- 1 Minute
- 5 Minute
- 15 Minute
- 1 Hour
- 4 Hour
- Daily

Higher timeframes generally produce stronger market structure signals.

---

[b]Risk Disclaimer[/b]

This indicator is designed as a market analysis tool and should not be considered financial or investment advice. No indicator guarantees profitable trades. Always use proper risk management and combine this tool with your own trading strategy and market analysis.

---

[b]Version[/b]

Current Release: SMC Fusion Indicator v1

Future updates may include:

- Order Blocks
- Fair Value Gaps (FVG)
- Liquidity Sweeps
- Equal Highs & Equal Lows
- Premium & Discount Zones
- Multi-Timeframe Analysis
- Additional alert options

[b]Thank you for using SMC Fusion Indicator. Your feedback and suggestions are always appreciated.[/b]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ExpertTraderASK

//@version=6
indicator("SMC Fusion Indicator v1", overlay = true, max_labels_count = 500, max_lines_count = 500)

//====================
// Inputs
//====================
pivotLen = input.int(5, "Swing Length", minval = 2)
showStructure = input.bool(true, "Show HH HL LH LL")
showBOS = input.bool(true, "Show BOS")
showCHOCH = input.bool(true, "Show CHoCH")

//====================
// Pivots
//====================
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var float lastHigh = na
var float lastLow = na
var int trend = 0

//====================
// Swing High
//====================
if not na(ph)
    swingHigh = high[pivotLen]

    if not na(lastHigh)
        txt = swingHigh > lastHigh ? "HH" : "LH"

        if showStructure
            label.new(
                 bar_index - pivotLen,
                 swingHigh,
                 txt,
                 style = label.style_label_down,
                 color = txt == "HH" ? color.green : color.red,
                 textcolor = color.white)

    lastHigh := swingHigh

//====================
// Swing Low
//====================
if not na(pl)
    swingLow = low[pivotLen]

    if not na(lastLow)
        txt = swingLow > lastLow ? "HL" : "LL"

        if showStructure
            label.new(
                 bar_index - pivotLen,
                 swingLow,
                 txt,
                 style = label.style_label_up,
                 color = txt == "HL" ? color.green : color.red,
                 textcolor = color.white)

    lastLow := swingLow

//====================
// BOS & CHOCH
//====================
bullBreak = not na(lastHigh) and close > lastHigh
bearBreak = not na(lastLow) and close < lastLow

if bullBreak
    if trend <= 0
        if showCHOCH
            label.new(bar_index, high, "CHoCH ↑", style=label.style_label_down, color=color.orange, textcolor=color.white)
        trend := 1
    else
        if showBOS
            label.new(bar_index, high, "BOS ↑", style=label.style_label_down, color=color.lime, textcolor=color.black)

if bearBreak
    if trend >= 0
        if showCHOCH
            label.new(bar_index, low, "CHoCH ↓", style=label.style_label_up, color=color.orange, textcolor=color.white)
        trend := -1
    else
        if showBOS
            label.new(bar_index, low, "BOS ↓", style=label.style_label_up, color=color.red, textcolor=color.white)

//====================
// Alerts
//====================
alertcondition(bullBreak, "Bullish Structure", "Bullish BOS / CHoCH")
alertcondition(bearBreak, "Bearish Structure", "Bearish BOS / CHoCH")
````
