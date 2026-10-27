# Rolling VWAP Suite

- url: https://www.tradingview.com/script/AszD93fR/
- type: indicator
- pine_id: PUB;545b323f0a6140d0a3d21040b113bc68
- version: 1.0

## Description

Three independent Rolling VWAPs on one chart — each with its own period, color, and optional standard deviation bands. Unlike a session VWAP, a Rolling VWAP runs over a moving time window and never resets, giving you a continuous fair-value line for dynamic support/resistance.

Features
- 3 toggleable rVWAP slots
- Periods from 7D to 365D (7 / 14 / 30 / 60 / 90 / 180 / 270 days)
- Optional σ bands per slot with custom multiplier and fill
- Clean period labels on the right edge, value optional
- Global transparency and line-width controls

Why it's different: The window is calculated on real timestamps (rolling sums, not a fixed bar count), so there's no lookback limit — even the 365-day rVWAP runs stable on any timeframe.

Note: Long-period accuracy depends on loaded history. On very low timeframes your plan may not load a full year of bars, so the 365D computes over the available span. Use higher chart timeframes (1H/1D) for full long-term values.

## Source Code

````pine
//@version=6
indicator("Rolling VWAP Suite", shorttitle="rVWAP", overlay=true, max_labels_count=50)

import PineCoders/ConditionalAverages/2 as pc

MS_IN_DAY = 86400000

// ── Allgemein ──
gGen    = "Allgemein"
src     = input.source(hlc3, "Quelle",         group=gGen)
lw      = input.int(2,       "Linienstärke",    minval=1, maxval=6, group=gGen)
transp  = input.int(40,      "Transparenz",     minval=0, maxval=100, group=gGen)
minBars = input.int(10,      "Min. Bars",       minval=1, group=gGen, tooltip="Mindestanzahl Bars im Fenster gegen Datenlücken.")
showLbl = input.bool(true,   "Labels anzeigen", group=gGen, inline="l")
showVal = input.bool(false,  "+ Wert",          group=gGen, inline="l")
lblOff  = input.int(8,       "Label-Abstand",   minval=0, maxval=50, group=gGen)
fillOn  = input.bool(true,   "Bänder füllen",   group=gGen)

f_days(p) =>
    switch p
        "7D"   => 7
        "14D"  => 14
        "30D"  => 30
        "60D"  => 60
        "90D"  => 90
        "180D" => 180
        "270D" => 270
        "365D" => 365
        => 7

f_rvwap(ms, mult) =>
    sSV  = pc.totalForTimeWhen(src * volume, ms, true, minBars)
    sV   = pc.totalForTimeWhen(volume, ms, true, minBars)
    sSSV = pc.totalForTimeWhen(volume * src * src, ms, true, minBars)
    vw   = sSV / sV
    va   = math.max(sSSV / sV - vw * vw, 0.0)
    dv   = math.sqrt(va)
    [vw, vw + mult * dv, vw - mult * dv]

// ── rVWAP 1 ──
g1   = "① rVWAP"
on1  = input.bool(true,    "Aktiv",  group=g1, inline="a")
per1 = input.string("7D",  "",       options=["7D","14D","30D","60D","90D","180D","270D","365D"], group=g1, inline="a")
col1 = input.color(#1E40AF,"",       group=g1, inline="a")
bnd1 = input.bool(false,   "Bänder", group=g1, inline="b")
mlt1 = input.float(1.0,    "×σ",     minval=0.1, step=0.1, group=g1, inline="b")

// ── rVWAP 2 ──
g2   = "② rVWAP"
on2  = input.bool(true,    "Aktiv",  group=g2, inline="a")
per2 = input.string("30D", "",       options=["7D","14D","30D","60D","90D","180D","270D","365D"], group=g2, inline="a")
col2 = input.color(#FB923C,"",       group=g2, inline="a")
bnd2 = input.bool(false,   "Bänder", group=g2, inline="b")
mlt2 = input.float(1.0,    "×σ",     minval=0.1, step=0.1, group=g2, inline="b")

// ── rVWAP 3 ──
g3   = "③ rVWAP"
on3  = input.bool(true,    "Aktiv",  group=g3, inline="a")
per3 = input.string("365D","",       options=["7D","14D","30D","60D","90D","180D","270D","365D"], group=g3, inline="a")
col3 = input.color(#EF4444,"",       group=g3, inline="a")
bnd3 = input.bool(false,   "Bänder", group=g3, inline="b")
mlt3 = input.float(1.0,    "×σ",     minval=0.1, step=0.1, group=g3, inline="b")

// ── Berechnung ──
[v1,u1,l1] = f_rvwap(f_days(per1) * MS_IN_DAY, mlt1)
[v2,u2,l2] = f_rvwap(f_days(per2) * MS_IN_DAY, mlt2)
[v3,u3,l3] = f_rvwap(f_days(per3) * MS_IN_DAY, mlt3)

// ── Bänder ──
fillT = math.min(99, transp + 17)
pu1 = plot(on1 and bnd1 ? u1 : na, "1 Upper", color.new(col1,transp), 1)
pl1 = plot(on1 and bnd1 ? l1 : na, "1 Lower", color.new(col1,transp), 1)
fill(pu1, pl1, on1 and bnd1 and fillOn ? color.new(col1,fillT) : na)
pu2 = plot(on2 and bnd2 ? u2 : na, "2 Upper", color.new(col2,transp), 1)
pl2 = plot(on2 and bnd2 ? l2 : na, "2 Lower", color.new(col2,transp), 1)
fill(pu2, pl2, on2 and bnd2 and fillOn ? color.new(col2,fillT) : na)
pu3 = plot(on3 and bnd3 ? u3 : na, "3 Upper", color.new(col3,transp), 1)
pl3 = plot(on3 and bnd3 ? l3 : na, "3 Lower", color.new(col3,transp), 1)
fill(pu3, pl3, on3 and bnd3 and fillOn ? color.new(col3,fillT) : na)

// ── Linien ──
plot(on1 ? v1 : na, "rVWAP 1", color.new(col1,transp), lw)
plot(on2 ? v2 : na, "rVWAP 2", color.new(col2,transp), lw)
plot(on3 ? v3 : na, "rVWAP 3", color.new(col3,transp), lw)

// ── Labels ──
f_txt(p, v) => p + (showVal ? "  " + str.tostring(v, format.mintick) : "")

var label L1 = na
var label L2 = na
var label L3 = na

if barstate.islast
    label.delete(L1), label.delete(L2), label.delete(L3)
    if showLbl
        if on1
            L1 := label.new(bar_index+lblOff, v1, f_txt(per1,v1), xloc.bar_index, style=label.style_label_left, color=color.new(col1,85), textcolor=col1)
        if on2
            L2 := label.new(bar_index+lblOff, v2, f_txt(per2,v2), xloc.bar_index, style=label.style_label_left, color=color.new(col2,85), textcolor=col2)
        if on3
            L3 := label.new(bar_index+lblOff, v3, f_txt(per3,v3), xloc.bar_index, style=label.style_label_left, color=color.new(col3,85), textcolor=col3)
````
