# Swing Low Stop Loss Levels

- url: https://www.tradingview.com/script/J8tWBNvL-Swing-Low-Stop-Loss-Levels/
- type: indicator
- pine_id: PUB;09f4699deeb54542a264ab1778950394
- version: 3.0

## Description

Swing Low Stop Loss Levels plots volatility-adjusted stop loss levels below the most recent confirmed swing lows, so you can see at a glance where a structure-based stop for a long position would sit.

HOW IT WORKS

A swing low is a candle whose low is lower than the lows of the N candles on each side of it. Once a swing low is confirmed, the indicator draws a line below it at:

Stop level = Swing low − (ATR × multiplier)

The ATR value is taken from the swing low candle itself, so each level is fixed at the moment it forms and does not drift as volatility changes afterward. Each line starts at its swing low, runs to the current candle, and is labeled with its price.

The indicator keeps only the most recent swing lows (3 by default). When a new swing low is confirmed, the oldest level is removed.

SETTINGS

Swing detection
- N (candles on each side): how many candles on both sides must have higher lows. Higher values find more significant swings; lower values find more frequent, minor swings.
- Number of swing lows to show: how many recent stop levels are displayed.

ATR buffer
- ATR length: the ATR calculation period (default 14).
- ATR multiplier: how far below the swing low the stop is placed, in ATR units (default 0.25).

Style
- Line color, line style (Solid, Dashed, Dotted), and line width.
- Show price labels: displays the stop price next to each line.
- Remove a level once price closes below it: optionally clears levels that have already been broken, since a violated swing low is usually no longer a valid stop reference.

HOW TO USE IT

When planning a long entry, the nearest level below price gives a stop that sits beneath recent market structure with a small volatility buffer, which helps avoid being stopped out by normal noise right at the swing low. Deeper levels show alternative stops if you prefer more room. The distance between entry and stop can also be used for position sizing.

NOTES

- A swing low can only be confirmed after N candles have closed to its right, so each level appears N candles after the actual low. This is inherent to swing detection and means the indicator does not repaint.
- The indicator is designed for long positions (stops below swing lows).
- It works on any symbol and timeframe.

This tool is for chart analysis only and does not provide trading signals or guarantee results. Always apply your own risk management.

## Source Code

````pine
//@version=6
indicator("Swing Low Stop Loss Levels", shorttitle = "Swing SL", overlay = true, max_lines_count = 500, max_labels_count = 500)

// ───── Inputs ─────
grpSwing = "Swing detection"
swingN    = input.int(5, "N (candles on each side)", minval = 1, group = grpSwing, tooltip = "A swing low needs N candles with higher lows on each side. It is confirmed only after the Nth right-side candle has closed.")
numLevels = input.int(1, "Number of swing lows to show", minval = 1, maxval = 100, group = grpSwing)

grpAtr = "ATR buffer"
atrLen  = input.int(14, "ATR length", minval = 1, group = grpAtr)
atrMult = input.float(0.25, "ATR multiplier", minval = 0.0, step = 0.05, group = grpAtr, tooltip = "Stop level = swing low − (ATR at the swing bar × this multiplier)")

grpStyle = "Style"
lineCol      = input.color(color.red, "Line color", group = grpStyle)
lineStyleStr = input.string("Dashed", "Line style", options = ["Solid", "Dashed", "Dotted"], group = grpStyle)
lineWidth    = input.int(1, "Line width", minval = 1, maxval = 4, group = grpStyle)
showLabels   = input.bool(true, "Show price labels", group = grpStyle)
removeBroken = input.bool(false, "Remove a level once price closes below it", group = grpStyle)

lineStyle = switch lineStyleStr
    "Solid"  => line.style_solid
    "Dotted" => line.style_dotted
    => line.style_dashed

// ───── Calculations ─────
atrVal  = ta.atr(atrLen)
pivotLo = ta.pivotlow(low, swingN, swingN)

// Accept a swing low only on a closed candle. barstate.isconfirmed is always true on
// historical bars, and on the realtime bar it is true only on the closing tick, so an
// intrabar pivot that gets invalidated before the close is never drawn.
newSwing = barstate.isconfirmed and not na(pivotLo) and not na(atrVal[swingN])

var array<line>  slLines  = array.new<line>()
var array<label> slLabels = array.new<label>()
var array<float> slPrices = array.new<float>()

// New confirmed swing low → create a stop level
if newSwing
    pivotBar = bar_index - swingN
    slPrice  = pivotLo - atrMult * atrVal[swingN]
    ln = line.new(pivotBar, slPrice, bar_index, slPrice, color = lineCol, width = lineWidth, style = lineStyle)
    lb = showLabels ? label.new(bar_index, slPrice, "SL " + str.tostring(slPrice, format.mintick), style = label.style_label_left, color = color.new(color.black, 100), textcolor = lineCol, size = size.small) : na
    slLines.push(ln)
    slLabels.push(lb)
    slPrices.push(slPrice)
    // Keep only the most recent N levels
    if slLines.size() > numLevels
        line.delete(slLines.shift())
        label.delete(slLabels.shift())
        slPrices.shift()

// Remove levels that price has closed below (optional) — only on a closed candle
if removeBroken and barstate.isconfirmed and slLines.size() > 0
    for i = slLines.size() - 1 to 0
        if close < slPrices.get(i)
            line.delete(slLines.remove(i))
            label.delete(slLabels.remove(i))
            slPrices.remove(i)

// Keep line ends and labels at the current bar
if slLines.size() > 0
    for i = 0 to slLines.size() - 1
        slLines.get(i).set_x2(bar_index)
        lb = slLabels.get(i)
        if not na(lb)
            lb.set_x(bar_index)
````
