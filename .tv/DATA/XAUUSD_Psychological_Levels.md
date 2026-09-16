<!-- tradingview-pine-id: PUB;ae504ae481cd424fa0a087d04907307d -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# XAUUSD Psychological Levels

Source: https://www.tradingview.com/script/cx9Y0Jd7/

## Description

XAUUSD Psychological Levels – 00 / 25 / 50 / 75

This indicator was designed to automatically highlight important psychological price levels on the XAUUSD chart.

It draws horizontal lines at fixed **$25 intervals**, automatically marking key psychological levels such as:

* 4500
* 4525
* 4550
* 4575
* 4600
* 4625

The levels are calculated automatically based on the current market price and update accordingly.

**00 levels** such as 4500, 4600, or 4700 are highlighted more prominently, as round-number levels often have stronger psychological significance in the market.

The intermediate **25, 50, and 75 levels** are displayed using more subtle horizontal lines.

The indicator settings allow you to customize:

* Number of levels displayed above the current price
* Number of levels displayed below the current price
* Color of standard levels
* Color of 00 levels
* Line width of standard levels
* Line width of major 00 levels

All levels are extended across the entire chart, making it easy to identify important price zones regardless of the selected timeframe.

The level values can also be displayed directly on TradingView's right-hand price scale without placing additional labels inside the chart.

This indicator can be useful for traders who monitor psychological price levels as potential areas for:

* Support and resistance
* Entries and exits
* Take-profit targets
* Reactions and rejections
* Breakouts
* Liquidity zones

The indicator was primarily designed for **XAUUSD (Gold)** using $25 intervals.

---

## Source Code

````pine
//@version=6
indicator(
     "XAUUSD Psychological Levels",
     overlay=true,
     scale=scale.none,
     max_lines_count=100,
     format=format.price,
     precision=2
)

// ─────────────────────────────
// Einstellungen
// ─────────────────────────────
stepSize = input.float(25.0, "Level-Abstand", step=0.25)

levelsAbove = input.int(8, "Levels über Preis", minval=1, maxval=8)
levelsBelow = input.int(8, "Levels unter Preis", minval=1, maxval=8)

normalColor = input.color(color.gray, "25/50/75 Farbe")
majorColor  = input.color(color.red, "00 Farbe")

normalWidth = input.int(1, "Normale Linienstärke", minval=1, maxval=4)
majorWidth  = input.int(2, "00 Linienstärke", minval=1, maxval=4)


// ─────────────────────────────
// Aktuelles Grund-Level
// Beispiel:
// Kurs 4589 -> 4575
// ─────────────────────────────
base = math.floor(close / stepSize) * stepSize


// ─────────────────────────────
// Linien zeichnen
// ─────────────────────────────
var line[] lines = array.new_line()

if barstate.islast

    if array.size(lines) > 0
        for i = 0 to array.size(lines) - 1
            line.delete(array.get(lines, i))

    array.clear(lines)

    for i = -levelsBelow to levelsAbove

        level = base + i * stepSize

        isMajor = math.abs(level % 100) < 0.001

        newLine = line.new(
             bar_index - 1,
             level,
             bar_index,
             level,
             extend=extend.both,
             color=isMajor ? majorColor : normalColor,
             width=isMajor ? majorWidth : normalWidth
         )

        array.push(lines, newLine)


// ─────────────────────────────
// Werte für rechte Preisskala
// NICHT im Chart sichtbar
// ─────────────────────────────

plot(levelsBelow >= 8 ? base - 200 : na, "Level -8", color=normalColor, display=display.price_scale)
plot(levelsBelow >= 7 ? base - 175 : na, "Level -7", color=normalColor, display=display.price_scale)
plot(levelsBelow >= 6 ? base - 150 : na, "Level -6", color=normalColor, display=display.price_scale)
plot(levelsBelow >= 5 ? base - 125 : na, "Level -5", color=normalColor, display=display.price_scale)
plot(levelsBelow >= 4 ? base - 100 : na, "Level -4", color=normalColor, display=display.price_scale)
plot(levelsBelow >= 3 ? base - 75  : na, "Level -3", color=normalColor, display=display.price_scale)
plot(levelsBelow >= 2 ? base - 50  : na, "Level -2", color=normalColor, display=display.price_scale)
plot(levelsBelow >= 1 ? base - 25  : na, "Level -1", color=normalColor, display=display.price_scale)

plot(base, "Level 0", color=normalColor, display=display.price_scale)

plot(levelsAbove >= 1 ? base + 25  : na, "Level +1", color=normalColor, display=display.price_scale)
plot(levelsAbove >= 2 ? base + 50  : na, "Level +2", color=normalColor, display=display.price_scale)
plot(levelsAbove >= 3 ? base + 75  : na, "Level +3", color=normalColor, display=display.price_scale)
plot(levelsAbove >= 4 ? base + 100 : na, "Level +4", color=normalColor, display=display.price_scale)
plot(levelsAbove >= 5 ? base + 125 : na, "Level +5", color=normalColor, display=display.price_scale)
plot(levelsAbove >= 6 ? base + 150 : na, "Level +6", color=normalColor, display=display.price_scale)
plot(levelsAbove >= 7 ? base + 175 : na, "Level +7", color=normalColor, display=display.price_scale)
plot(levelsAbove >= 8 ? base + 200 : na, "Level +8", color=normalColor, display=display.price_scale)
````
