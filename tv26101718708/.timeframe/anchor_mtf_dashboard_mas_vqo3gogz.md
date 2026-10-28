# Anchor MTF Dashboard + MAs

- url: https://www.tradingview.com/script/Vqo3goGZ-Anchor-MTF-Dashboard-MAs/
- type: indicator
- pine_id: PUB;1593f7a6fcbd402397cf94fbcc535643
- version: 1.0

## Description

Anchor MTF Dashboard + MAs
A multi-timeframe trend dashboard built around the 20 SMA "anchor line." It reads the anchor's direction across ten timeframes at once — from the 2-minute up to the monthly — so you can spot trend confluence at a glance instead of flipping through charts. Pair the scalp block for intraday entries with the swing block for the bigger-picture bias.

What it shows
On the chart:

The anchor SMA, color-coded by direction — green when rising, red when falling, gray when flat.
Flat-zone shading that highlights when the anchor is going sideways — the conditions where trend trades tend to chop out.
Up to 8 fully customizable SMAs — each with its own on/off toggle, length, source, color, and line width.
The dashboard table:

Every timeframe's anchor direction: ▲ UP / ▼ DOWN / — flat, with a slope value (steeper = stronger trend).
A SCALP block (2 / 4 / 8 / 16 / 32 min) and a SWING block (1H / 4H / 1D / 1W / 1M), each with its own tally and an ALL UP / ALL DN flag when the whole block agrees.
An ALL row summarizing full-stack confluence across all ten timeframes.
Why it works the way it does
Trend direction is measured as the anchor's slope, normalized by ATR. That means "flat" carries the same meaning on a 2-minute chart as on the monthly — no per-timeframe tuning, and signals stay comparable across instruments and timeframes.

How to use it
Scalping: look for entries when the scalp block is aligned (mostly or fully one direction). "Mixed" or flat readings are the chop to avoid.
Swing trading: trade in the direction of an aligned swing block — those moves have the higher-timeframe tide behind them.
Best setups: when scalp and swing point the same way (the FULL ▲ / ▼ flag), trend trades have the most wind at their back. Counter-trend trades against an aligned swing block are the ones most likely to fail.
Settings
Anchor: length, source, slope lookback, flat threshold, ATR length, direction colors, width, flat-zone shading.
Moving Averages: 8 independent SMAs, each fully configurable.
Timeframes: all ten slots are editable — build any ladder you want.
Table: position and text size.
For educational purposes only. Not financial advice. Trend confluence improves context but does not guarantee outcomes — always manage your own risk.

## Source Code

````pine
//@version=6
indicator("Anchor MTF Dashboard + MAs", overlay=true)

// ═══════════════ ANCHOR SETTINGS ═══════════════
len        = input.int(20, "Anchor SMA Length", minval=1, group="Anchor")
src        = input.source(close, "Source", group="Anchor")
slopeLB    = input.int(3, "Slope Lookback (bars)", minval=1, group="Anchor")
flatThresh = input.float(0.05, "Flat Threshold (ATR units)", minval=0.0, step=0.01, group="Anchor",
                 tooltip="Slope-per-bar below this (ATR-normalized) counts as FLAT.")
atrLen     = input.int(14, "ATR Length", minval=1, group="Anchor")
showAnchor = input.bool(true, "Show anchor on chart", group="Anchor")
anchorW    = input.int(2, "Anchor width", minval=1, group="Anchor")
upCol      = input.color(color.green, "Up",   inline="ac", group="Anchor")
dnCol      = input.color(color.red,   "Down", inline="ac", group="Anchor")
flatCol    = input.color(color.gray,  "Flat", inline="ac", group="Anchor")
showFlatBg = input.bool(true, "Shade flat zones", group="Anchor")

// ═══════════════ EXTRA MOVING AVERAGES (8) ═══════════════
g = "Moving Averages"
en1 = input.bool(true,  "MA1", inline="m1", group=g), l1 = input.int(9,   "", inline="m1", group=g, minval=1), c1 = input.color(color.aqua,    "", inline="m1", group=g), sc1 = input.source(close, "src", inline="m1b", group=g), w1 = input.int(1, "w", inline="m1b", group=g, minval=1)
en2 = input.bool(false, "MA2", inline="m2", group=g), l2 = input.int(21,  "", inline="m2", group=g, minval=1), c2 = input.color(color.lime,    "", inline="m2", group=g), sc2 = input.source(close, "src", inline="m2b", group=g), w2 = input.int(1, "w", inline="m2b", group=g, minval=1)
en3 = input.bool(true,  "MA3", inline="m3", group=g), l3 = input.int(50,  "", inline="m3", group=g, minval=1), c3 = input.color(color.orange,  "", inline="m3", group=g), sc3 = input.source(close, "src", inline="m3b", group=g), w3 = input.int(1, "w", inline="m3b", group=g, minval=1)
en4 = input.bool(false, "MA4", inline="m4", group=g), l4 = input.int(100, "", inline="m4", group=g, minval=1), c4 = input.color(color.fuchsia, "", inline="m4", group=g), sc4 = input.source(close, "src", inline="m4b", group=g), w4 = input.int(1, "w", inline="m4b", group=g, minval=1)
en5 = input.bool(false, "MA5", inline="m5", group=g), l5 = input.int(150, "", inline="m5", group=g, minval=1), c5 = input.color(color.yellow,  "", inline="m5", group=g), sc5 = input.source(close, "src", inline="m5b", group=g), w5 = input.int(1, "w", inline="m5b", group=g, minval=1)
en6 = input.bool(true,  "MA6", inline="m6", group=g), l6 = input.int(200, "", inline="m6", group=g, minval=1), c6 = input.color(color.red,     "", inline="m6", group=g), sc6 = input.source(close, "src", inline="m6b", group=g), w6 = input.int(2, "w", inline="m6b", group=g, minval=1)
en7 = input.bool(false, "MA7", inline="m7", group=g), l7 = input.int(8,   "", inline="m7", group=g, minval=1), c7 = input.color(color.white,   "", inline="m7", group=g), sc7 = input.source(close, "src", inline="m7b", group=g), w7 = input.int(1, "w", inline="m7b", group=g, minval=1)
en8 = input.bool(false, "MA8", inline="m8", group=g), l8 = input.int(34,  "", inline="m8", group=g, minval=1), c8 = input.color(color.blue,    "", inline="m8", group=g), sc8 = input.source(close, "src", inline="m8b", group=g), w8 = input.int(1, "w", inline="m8b", group=g, minval=1)

plot(en1 ? ta.sma(sc1, l1) : na, "MA1", color=c1, linewidth=w1)
plot(en2 ? ta.sma(sc2, l2) : na, "MA2", color=c2, linewidth=w2)
plot(en3 ? ta.sma(sc3, l3) : na, "MA3", color=c3, linewidth=w3)
plot(en4 ? ta.sma(sc4, l4) : na, "MA4", color=c4, linewidth=w4)
plot(en5 ? ta.sma(sc5, l5) : na, "MA5", color=c5, linewidth=w5)
plot(en6 ? ta.sma(sc6, l6) : na, "MA6", color=c6, linewidth=w6)
plot(en7 ? ta.sma(sc7, l7) : na, "MA7", color=c7, linewidth=w7)
plot(en8 ? ta.sma(sc8, l8) : na, "MA8", color=c8, linewidth=w8)

// ═══════════════ TABLE SETTINGS ═══════════════
tblPos = input.string("Top Right", "Table position", options=["Top Right","Top Left","Bottom Right","Bottom Left","Middle Right"], group="Table")
tblSize= input.string("Normal", "Text size", options=["Tiny","Small","Normal","Large"], group="Table")

s1t = input.timeframe("2",  "Scalp 1", group="Timeframes — Scalp")
s2t = input.timeframe("4",  "Scalp 2", group="Timeframes — Scalp")
s3t = input.timeframe("8",  "Scalp 3", group="Timeframes — Scalp")
s4t = input.timeframe("16", "Scalp 4", group="Timeframes — Scalp")
s5t = input.timeframe("32", "Scalp 5", group="Timeframes — Scalp")
w1t = input.timeframe("60",  "Swing 1", group="Timeframes — Swing")
w2t = input.timeframe("240", "Swing 2", group="Timeframes — Swing")
w3t = input.timeframe("D",   "Swing 3", group="Timeframes — Swing")
w4t = input.timeframe("W",   "Swing 4", group="Timeframes — Swing")
w5t = input.timeframe("M",   "Swing 5", group="Timeframes — Swing")

// ═══════════════ ANCHOR MATH (chart TF) ═══════════════
anchor = ta.sma(src, len)
aSlope = (anchor - anchor[slopeLB]) / slopeLB / ta.atr(atrLen)
aFlat  = math.abs(aSlope) < flatThresh
aUp    = aSlope > 0
plot(showAnchor ? anchor : na, "Anchor", color=aFlat ? flatCol : aUp ? upCol : dnCol, linewidth=anchorW)
bgcolor(showFlatBg and aFlat ? color.new(flatCol, 92) : na)

// ═══════════════ ANCHOR SLOPE PER TIMEFRAME ═══════════════
getSlope(simple string tf) =>
    request.security(syminfo.tickerid, tf,
         (ta.sma(src, len) - ta.sma(src, len)[slopeLB]) / slopeLB / ta.atr(atrLen),
         lookahead = barmerge.lookahead_off)

slopes = array.from(getSlope(s1t), getSlope(s2t), getSlope(s3t), getSlope(s4t), getSlope(s5t), getSlope(w1t), getSlope(w2t), getSlope(w3t), getSlope(w4t), getSlope(w5t))
labels = array.from(s1t, s2t, s3t, s4t, s5t, w1t, w2t, w3t, w4t, w5t)

f_txt(float s) => na(s) ? "n/a" : s > flatThresh ? "▲ UP" : s < -flatThresh ? "▼ DOWN" : "— flat"
f_col(float s) => na(s) ? color.gray : s > flatThresh ? color.new(color.green,15) : s < -flatThresh ? color.new(color.red,15) : color.new(color.gray,40)
f_dir(float s) => na(s) ? 0 : s > flatThresh ? 1 : s < -flatThresh ? -1 : 0

scalpUp = 0, scalpDn = 0, swingUp = 0, swingDn = 0
for i = 0 to 4
    d = f_dir(array.get(slopes, i))
    scalpUp += d == 1 ? 1 : 0
    scalpDn += d == -1 ? 1 : 0
for i = 5 to 9
    d = f_dir(array.get(slopes, i))
    swingUp += d == 1 ? 1 : 0
    swingDn += d == -1 ? 1 : 0

// ═══════════════ TABLE ═══════════════
pos = tblPos == "Top Left" ? position.top_left : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Bottom Left" ? position.bottom_left : tblPos == "Middle Right" ? position.middle_right : position.top_right
sz  = tblSize == "Tiny" ? size.tiny : tblSize == "Small" ? size.small : tblSize == "Large" ? size.large : size.normal
var table t = table.new(pos, 3, 14, border_width=1, frame_width=1, frame_color=color.gray)

f_row(int row, string lab, float s) =>
    table.cell(t, 0, row, lab, text_color=color.white, bgcolor=color.new(color.black,30), text_size=sz)
    table.cell(t, 1, row, f_txt(s), text_color=color.white, bgcolor=f_col(s), text_size=sz)
    table.cell(t, 2, row, na(s) ? "" : str.tostring(s, "#.##"), text_color=color.white, bgcolor=color.new(color.black,30), text_size=sz)

if barstate.islast
    table.cell(t, 0, 0, "TF", text_color=color.black, bgcolor=color.gray, text_size=sz)
    table.cell(t, 1, 0, "Anchor", text_color=color.black, bgcolor=color.gray, text_size=sz)
    table.cell(t, 2, 0, "Slope", text_color=color.black, bgcolor=color.gray, text_size=sz)
    table.cell(t, 0, 1, "SCALP", text_color=color.yellow, bgcolor=color.new(color.blue,50), text_size=sz)
    table.cell(t, 1, 1, str.tostring(scalpUp)+"▲ "+str.tostring(scalpDn)+"▼", text_color=color.white, bgcolor=color.new(color.blue,50), text_size=sz)
    table.cell(t, 2, 1, scalpUp==5 ? "ALL UP" : scalpDn==5 ? "ALL DN" : "mixed", text_color=color.white, bgcolor=color.new(color.blue,50), text_size=sz)
    f_row(2, labels.get(0), slopes.get(0))
    f_row(3, labels.get(1), slopes.get(1))
    f_row(4, labels.get(2), slopes.get(2))
    f_row(5, labels.get(3), slopes.get(3))
    f_row(6, labels.get(4), slopes.get(4))
    table.cell(t, 0, 7, "SWING", text_color=color.yellow, bgcolor=color.new(color.purple,50), text_size=sz)
    table.cell(t, 1, 7, str.tostring(swingUp)+"▲ "+str.tostring(swingDn)+"▼", text_color=color.white, bgcolor=color.new(color.purple,50), text_size=sz)
    table.cell(t, 2, 7, swingUp==5 ? "ALL UP" : swingDn==5 ? "ALL DN" : "mixed", text_color=color.white, bgcolor=color.new(color.purple,50), text_size=sz)
    f_row(8,  labels.get(5), slopes.get(5))
    f_row(9,  labels.get(6), slopes.get(6))
    f_row(10, labels.get(7), slopes.get(7))
    f_row(11, labels.get(8), slopes.get(8))
    f_row(12, labels.get(9), slopes.get(9))
    allUp = scalpUp+swingUp == 10
    allDn = scalpDn+swingDn == 10
    table.cell(t, 0, 13, "ALL", text_color=color.black, bgcolor=color.gray, text_size=sz)
    table.cell(t, 1, 13, allUp ? "FULL ▲" : allDn ? "FULL ▼" : "mixed", text_color=color.white, bgcolor=allUp?color.green:allDn?color.red:color.new(color.gray,30), text_size=sz)
    table.cell(t, 2, 13, str.tostring(scalpUp+swingUp)+"▲/"+str.tostring(scalpDn+swingDn)+"▼", text_color=color.white, bgcolor=color.new(color.black,30), text_size=sz)
````
