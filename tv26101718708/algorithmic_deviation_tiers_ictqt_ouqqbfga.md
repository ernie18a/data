# Algorithmic Deviation Tiers [ICT/QT]

- url: https://www.tradingview.com/script/ouQQbfGA-Algorithmic-Deviation-Tiers-ICT-QT/
- type: indicator
- pine_id: PUB;3e3543f6b8674f78b84d74cf72be0385
- version: 1.0

## Description

Algorithmic Deviation Tiers [ICT/QT] this is just a test script

## Source Code

````pine
//@version=5
indicator("Algorithmic Deviation Tiers [ICT/QT]", overlay=true)

// --- Inputs ---
anchorTime = input.string("0000-0015", title="Algorithmic Anchor (Midnight Open)")
showSD = input.bool(true, title="Show Standard Deviations")

// --- Logic: Capture Opening Price ---
var float openPrice = na
if time("1", anchorTime)
    openPrice := open

// --- Uniformed Measure Calculations ---
// Based on institutional 0.25% (Accumulation) and 0.75% (Distribution) benchmarks
acc_high = openPrice * 1.0025  // 0.25% Tier
acc_low  = openPrice * 0.9975
dist_high = openPrice * 1.0075 // 0.75% Tier
dist_low  = openPrice * 0.9925

// --- Plotting ---
plot(openPrice, "Midnight Open", color.new(color.gray, 0), 2, plot.style_linebr)

// Accumulation Tiers (Q1/Q2 Areas)
plot(acc_high, "ACC High", color.new(color.blue, 50), 1, plot.style_linebr)
plot(acc_low,  "ACC Low",  color.new(color.blue, 50), 1, plot.style_linebr)

// Distribution Tiers (Q3 Targets)
plot(dist_high, "DIST High (2.5 SD)", color.new(color.green, 20), 2, plot.style_linebr)
plot(dist_low,  "DIST Low (2.5 SD)",  color.new(color.red, 20), 2, plot.style_linebr)
````
