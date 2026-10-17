# Latest Swing High / Low

- url: https://www.tradingview.com/script/inHu365K/
- type: indicator
- pine_id: PUB;87ed582ad64647d4b68dcaecbe1b7b5f
- version: 1.0

## Description

Latest highs and lows, always up-to-date with a strength of 6.

## Source Code

````pine
//@version=5
indicator("Latest Swing High / Low", overlay=true)

// ───── Einstellungen ─────
left  = input.int(5, "Links (Stärke)", minval=1)
right = input.int(5, "Rechts (Stärke)", minval=1)

// ───── Pivot Berechnung ─────
ph = ta.pivothigh(high, left, right)
pl = ta.pivotlow(low, left, right)

// ───── Letzte Werte speichern ─────
var float lastHigh = na
var float lastLow  = na

if not na(ph)
    lastHigh := ph

if not na(pl)
    lastLow := pl

// ───── Linien zeichnen ─────
var line highLine = na
var line lowLine  = na

// High Linie updaten
if not na(lastHigh)
    if na(highLine)
        highLine := line.new(bar_index, lastHigh, bar_index + 1, lastHigh, extend=extend.right, color=color.red, width=2)
    else
        line.set_xy1(highLine, bar_index, lastHigh)
        line.set_xy2(highLine, bar_index + 1, lastHigh)

// Low Linie updaten
if not na(lastLow)
    if na(lowLine)
        lowLine := line.new(bar_index, lastLow, bar_index + 1, lastLow, extend=extend.right, color=color.green, width=2)
    else
        line.set_xy1(lowLine, bar_index, lastLow)
        line.set_xy2(lowLine, bar_index + 1, lastLow)
````
