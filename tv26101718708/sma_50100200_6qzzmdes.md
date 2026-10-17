# SMA 50/100/200

- url: https://www.tradingview.com/script/6qZzMdES-SMA-50-100-200/
- type: indicator
- pine_id: PUB;75fd829f63b646c987bb67cf417ca1b9
- version: 3.0

## Description

Plots SMA for 50/100/200.

Can alert based on cross over too.

## Source Code

````pine
//@version=6
// Name:        SMA 50/100/200
// Author:      <you>
// Description: Plots three simple moving averages (50, 100, 200) on the chart
//              with toggles, configurable source, and optional crossover signals.
// License:     MPL-2.0
indicator(title = "SMA", shorttitle = "SMA 21/50/200", overlay = true)

// ── Inputs ───────────────────────────────────────────────────────────────────
src       = input.source(close, "Source",        group = "General")

show1    = input.bool(true,  "Show SMA 1",   inline = "21",  group = "Lengths")
len1     = input.int(21,     "",              inline = "21",  group = "Lengths", minval = 1)

show2   = input.bool(true,  "Show SMA 2",  inline = "50", group = "Lengths")
len2    = input.int(50,    "",              inline = "50", group = "Lengths", minval = 1)

show3   = input.bool(true,  "Show SMA 3",  inline = "200", group = "Lengths")
len3   = input.int(200,    "",              inline = "200", group = "Lengths", minval = 1)

showSig   = input.bool(false, "Show 50/200 Cross Signals (Golden/Death Cross)",
                       group = "Signals")

// ── Calculations ─────────────────────────────────────────────────────────────
sma50  = ta.sma(src, len1)
sma100 = ta.sma(src, len2)
sma200 = ta.sma(src, len3)

// ── Plots ────────────────────────────────────────────────────────────────────
plot(show1  ? sma50  : na, title = "SMA 50",  color = color.new(color.orange, 0), linewidth = 2)
plot(show2 ? sma100 : na, title = "SMA 100", color = color.new(color.blue,   0), linewidth = 2)
plot(show3 ? sma200 : na, title = "SMA 200", color = color.new(color.red,    0), linewidth = 2)

// ── Golden / Death Cross ─────────────────────────────────────────────────────
goldenCross = ta.crossover(sma50,  sma200)
deathCross  = ta.crossunder(sma50, sma200)

plotshape(showSig and goldenCross, title = "Golden Cross",
     style = shape.labelup,   location = location.belowbar,
     color = color.new(color.green, 0), textcolor = color.white, text = "GC", size = size.tiny)

plotshape(showSig and deathCross,  title = "Death Cross",
     style = shape.labeldown, location = location.abovebar,
     color = color.new(color.red, 0),   textcolor = color.white, text = "DC", size = size.tiny)

alertcondition(goldenCross, "Golden Cross (50/200)", "Golden Cross on {{ticker}} ({{interval}})")
alertcondition(deathCross,  "Death Cross (50/200)",  "Death Cross on {{ticker}} ({{interval}})")
````
