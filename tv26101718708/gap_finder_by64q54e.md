# Gap Finder

- url: https://www.tradingview.com/script/BY64Q54e-Gap-Finder/
- type: indicator
- pine_id: PUB;5c1a61a646c24f5684e614e08b25c248
- version: 1.0

## Description

This indicator automatically detects and highlights significant price gaps using semi-transparent boxes. It draws a precise zone from the previous close to the current open, giving you an immediate visual representation of the gap area.


Key Features:
[list]
[*]Customizable Sensitivity: Set your own minimum gap size (default is 3%).
[*]Visual Precision: Clear green (Gap Up) and red (Gap Down) boxes explicitly mark the empty price action space without hiding future candles.
[*]Adjustable Length: Choose how many bars the box extends to the right to keep the gap zone visible as the price develops.
[/list]

## Source Code

````pine
//@version=5
indicator("Gap Finder 3% - Obdélníky", overlay=true)

// Nastavení
minGap = input.float(3.0, title="Minimální velikost gapu (%)", minval=0.1)
boxLength = input.int(5, title="Délka obdélníku (počet svíček)", minval=1)

// Výpočet procentuálního rozdílu mezi dnešním open a včerejším close
gapPercent = ((open - close[1]) / close[1]) * 100

gapUp = gapPercent >= minGap
gapDown = gapPercent <= -minGap

// Vykreslení obdélníku pro Gap Up
if gapUp
    box.new(left=bar_index - 1, top=open, right=bar_index + boxLength, bottom=close[1], border_color=color.green, border_width=1, bgcolor=color.new(color.green, 85))

// Vykreslení obdélníku pro Gap Down
if gapDown
    box.new(left=bar_index - 1, top=close[1], right=bar_index + boxLength, bottom=open, border_color=color.red, border_width=1, bgcolor=color.new(color.red, 85))
````
