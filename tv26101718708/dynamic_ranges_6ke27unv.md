# Dynamic Ranges

- url: https://www.tradingview.com/script/6kE27UnV-Dynamic-Ranges/
- type: indicator
- pine_id: PUB;2bca5a580e1f4c8a8ebbff2c1c5ce424
- version: 1.0

## Description

This Script is to Visualize Dynamic Ranges that is Presented By Hopiplaka. All of the working and logic is Derived and Extended from His Work. By no means I take any credit on this.

The User Can Enter Manually two things

[b]Fixed Price
Dynamic Ranges[/b]

Based on these two specific Parameters, a Dynamic Range will be plotted. The User can choose the wireframe too.

[b]IMP Nodes / 767 Levels
Goldbach Nodes / Goldbach Levels[/b]

All Credits to Hopiplaka!!!

## Source Code

````pine
//@version=5
indicator("Dynamic Ranges", overlay=true)

// Inputs
basePrice = input.float(title="Settlement", defval=26825.75)
percent   = input.float(title="Variant", defval=0.7)

// Node Set (single line)
nodeSet = input.string("IMP Nodes", title="Node Set", options=["IMP Nodes", "Goldbach Nodes"])

// ───── Color Options ─────
mainColor = input.color(color.rgb(255, 0, 0), title="EQ / H / L")
fibColor  = input.color(color.rgb(200, 200, 200), title="Wireframe")

// ───── Calculations ─────
percentDecimal = percent / 100

rangeValue = basePrice * percentDecimal
upperLevel = basePrice + rangeValue
lowerLevel = basePrice - rangeValue

// ───── Main Levels ─────
plot(upperLevel, title="High Level", color=mainColor, linewidth=1)
plot(basePrice,  title="EQ Level",   color=mainColor, linewidth=1)
plot(lowerLevel, title="Low Level",  color=mainColor, linewidth=1)

// ───── IMP Nodes ─────
imp0   = 0.07
imp1   = 0.13
imp2   = 0.2
imp3   = 0.3
imp4   = 0.37
imp5   = 0.43
imp6   = 0.57
imp7   = 0.63
imp8   = 0.7
imp9   = 0.8
imp10  = 0.87
imp11  = 0.93

// ───── Goldbach Nodes ─────
gb0   = 0.03
gb1   = 0.11
gb2   = 0.17
gb3   = 0.29
gb4   = 0.41
gb5   = 0.47
gb6   = 0.53
gb7   = 0.59
gb8   = 0.71
gb9   = 0.83
gb10  = 0.89
gb11  = 0.97

// ───── Mapping function ─────
fibLevel(val) =>
    lowerLevel + (upperLevel - lowerLevel) * val

// ───── Mode selector ─────
isIMP = nodeSet == "IMP Nodes"

// ───── Fib / Node Plots ─────
plot(fibLevel(isIMP ? imp0  : gb0),  color=fibColor, linewidth=1)
plot(fibLevel(isIMP ? imp1  : gb1),  color=fibColor, linewidth=1)
plot(fibLevel(isIMP ? imp2  : gb2),  color=fibColor, linewidth=1)
plot(fibLevel(isIMP ? imp3  : gb3),  color=fibColor, linewidth=1)
plot(fibLevel(isIMP ? imp4  : gb4),  color=fibColor, linewidth=1)
plot(fibLevel(isIMP ? imp5  : gb5),  color=fibColor, linewidth=1)
plot(fibLevel(isIMP ? imp6  : gb6),  color=fibColor, linewidth=1)
plot(fibLevel(isIMP ? imp7  : gb7),  color=fibColor, linewidth=1)
plot(fibLevel(isIMP ? imp8  : gb8),  color=fibColor, linewidth=1)
plot(fibLevel(isIMP ? imp9  : gb9),  color=fibColor, linewidth=1)
plot(fibLevel(isIMP ? imp10 : gb10), color=fibColor, linewidth=1)
plot(fibLevel(isIMP ? imp11 : gb11), color=fibColor, linewidth=1)
````
