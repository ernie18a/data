<!-- tradingview-pine-id: PUB;1db9f55e4f944451b4e02b4e1b799545 -->
<!-- tradingviewscripts-format: 1 -->
# Kloom Turtle System

Source: https://www.tradingview.com/script/TnkefIeX-Kloom-Turtle-System-Donchian-Breakout-with-Trend-Filter/

## Description

Classic Turtle-style Donchian breakout system with an explicit, non-repainting state engine.

How it works
• Entry channel: highest high / lowest low of the last 20 bars (Donchian). A break of the previous bar's channel triggers a long/short state — signals only fire on confirmed breaks, so nothing repaints.
• Exit channel: 10-bar Donchian on the opposite side, the classic Turtle S1 exit.
• Optional 200 EMA trend filter: longs only above it, shorts only below it.
• A state table shows the current system state (LONG / SHORT / FLAT) at a glance, and exit levels are drawn continuously so you always know where the system would flip.

How to use it
Works on any symbol and timeframe. Behaves best on markets that actually trend (crypto majors, gold, indices) on 1h-4h. Entry/exit lengths, the trend filter and its length are all configurable.

Why another Donchian script
Most Donchian scripts plot the channel and stop there. Here the position state is tracked bar by bar, exits are always visible, and the breakout reference is the previous bar's channel — the detail that keeps historical signals honest.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KloomStudio

//@version=6
indicator("Kloom Turtle System", shorttitle="K.Turtle", overlay=true)

// ── Inputs ─────────────────────────────────────────────────────────────────────
grpSys   = "Turtle System"
entryLen = input.int(20, "Entry channel length (Donchian)", minval=5, maxval=200, group=grpSys)
exitLen  = input.int(10, "Exit channel length (Donchian)",  minval=3, maxval=100, group=grpSys)
useTrend = input.bool(true, "Filter entries with trend EMA", group=grpSys)
trendLen = input.int(200, "Trend EMA length", minval=20, maxval=500, group=grpSys)

grpViz   = "Display"
showCh   = input.bool(true,  "Show Donchian channels", group=grpViz)
showSig  = input.bool(true,  "Show entry/exit markers", group=grpViz)

// ── Donchian channels (previous bar, classic Turtle) ───────────────────────────
entryHi = ta.highest(high, entryLen)[1]
entryLo = ta.lowest(low,  entryLen)[1]
exitHi  = ta.highest(high, exitLen)[1]
exitLo  = ta.lowest(low,  exitLen)[1]

trendEma  = ta.ema(close, trendLen)
longOk    = not useTrend or close > trendEma
shortOk   = not useTrend or close < trendEma

// ── Position state (visual only — this is an indicator, not a strategy) ────────
var int pos = 0
longEntry  = high > entryHi and longOk  and pos <= 0
shortEntry = low  < entryLo and shortOk and pos >= 0
longExit   = pos == 1  and low  < exitLo
shortExit  = pos == -1 and high > exitHi

if longEntry
    pos := 1
else if shortEntry
    pos := -1
else if longExit or shortExit
    pos := 0

// ── Plots ──────────────────────────────────────────────────────────────────────
pEntryHi = plot(showCh ? entryHi : na, "Entry High", color=color.new(color.teal, 30))
pEntryLo = plot(showCh ? entryLo : na, "Entry Low",  color=color.new(color.teal, 30))
plot(showCh ? exitHi : na, "Exit High", color=color.new(color.orange, 60), style=plot.style_circles)
plot(showCh ? exitLo : na, "Exit Low",  color=color.new(color.orange, 60), style=plot.style_circles)
fill(pEntryHi, pEntryLo, color=color.new(color.teal, 94), title="Channel fill")
plot(useTrend ? trendEma : na, "Trend EMA", color=color.new(color.gray, 40), linewidth=2)

plotshape(showSig and longEntry,  "Long entry",  style=shape.triangleup,   location=location.belowbar, color=color.teal,   size=size.small, text="L")
plotshape(showSig and shortEntry, "Short entry", style=shape.triangledown, location=location.abovebar, color=color.red,    size=size.small, text="S")
plotshape(showSig and (longExit or shortExit), "Exit", style=shape.xcross, location=location.absolute, color=color.orange, size=size.tiny)

// ── State table ────────────────────────────────────────────────────────────────
var table t = table.new(position.top_right, 2, 2, border_width=1)
if barstate.islast
    posTxt   = pos == 1 ? "LONG" : pos == -1 ? "SHORT" : "FLAT"
    posColor = pos == 1 ? color.teal : pos == -1 ? color.red : color.gray
    table.cell(t, 0, 0, "Turtle state", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
    table.cell(t, 1, 0, posTxt, text_color=color.white, bgcolor=posColor, text_size=size.small)
    table.cell(t, 0, 1, "Regime", text_color=color.white, bgcolor=color.new(color.black, 20), text_size=size.small)
    table.cell(t, 1, 1, close > trendEma ? "Bull" : "Bear", text_color=color.white, bgcolor=close > trendEma ? color.new(color.teal, 40) : color.new(color.red, 40), text_size=size.small)
````
