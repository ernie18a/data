<!-- tradingview-pine-id: PUB;cf2e74679dda49e1984b29dc09063566 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Multi EMA/SMA Pro — 5/13/20/50/100/200 + MTF

Source: https://www.tradingview.com/script/B3xvdK72-Multi-EMA-SMA-Pro-5-13-20-50-100-200-MTF/

## Description

MULTI EMA/SMA PRO — 5/13/20/50/100/200 + MTF

Nine independent moving averages in one indicator, each with its own length,
type, timeframe, color and width. Defaults give you the classic 20 / 50 / 100 /
200 on your chart timeframe, with 5 and 13 a click away.

EVERY LINE IS LABELLED
No more guessing which line is which. Each average is tagged at the right edge
with its length — and optionally its type, its timeframe, its current value, and
how far price sits from it in percent. You read "200 D  +18.06%" straight off the
chart instead of hovering over lines to find out.

DAILY / WEEKLY / MONTHLY AVERAGES ON ANY CHART
Every slot has a Chart / Daily / Weekly / Monthly / Custom selector, so you can
sit on a 5-minute chart and still see exactly where the daily 200 and the weekly
200 are — the levels that actually decide intraday reversals. Slots 7, 8 and 9
come pre-set to 200 D, 30 W and 200 W. Each higher-timeframe line is tagged with
D, W or M so there is never any ambiguity about what you are looking at. Ask for
a timeframe below your chart and the slot quietly falls back to chart data rather
than returning misleading values.

INFO TABLE
An on-chart panel lists every enabled average, its current value, and how far
price is above or below it in percent, color-coded green and red. It is the
fastest way to tell whether price is extended and due a snap back, or resting on
support. Decimal precision is adjustable.

GOLDEN CROSS / DEATH CROSS, DONE PROPERLY
GC/DC detection is on by default and measured on the DAILY 50 vs 200 no matter
what timeframe you are viewing — so an intraday chart shows the real cross, not a
5-minute imitation of one. Markers carry their own context: "GC 50/200 D".
Lengths, timeframe and MA type are all configurable, or you can point the cross
logic at any two of your plotted lines instead.

EVERYTHING ELSE
- EMA / SMA / WMA / HMA / RMA / VWMA globally, or overridden per line
- Custom source, plot offset, transparency, per-line width and color
- Line / step-line / circles / cross plot styles
- Slope-based coloring (green rising, red falling)
- Ribbon fill between any two averages
- Alerts for price crossing each average, plus golden and death cross
- Palette chosen to stay readable on both light and dark chart backgrounds

A NOTE ON HIGHER-TIMEFRAME DATA
Leave "wait for bar close" off and the daily and weekly lines update live inside
the forming candle, which is usually what you want when trading. The trade-off is
that an intraday cross can appear and then disappear before the session closes.
Turn it on for confirmed, non-repainting values that step one bar late.

If you find this useful, a boost is appreciated. Suggestions and feedback welcome in the comments.
Open-source — feel free to study, fork, and adapt.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © sunilp303

//@version=6
// ═══════════════════════════════════════════════════════════════════════════
//  MULTI EMA/SMA PRO — 5 / 13 / 20 / 50 / 100 / 200  +  MTF (D / W / M)
//  Author: sunilp303
//  • 9 fully independent MA slots (length, type, timeframe, color, width)
//  • Defaults ON: 20, 50, 100, 200 on the chart timeframe
//  • Slots 7/8/9 default to 200 D, 30 W, 200 W (off by default) so you can
//    see higher-timeframe averages while viewing a 1H / 15m / 5m chart
//  • Every line can be tagged on the right with "200", "200 D", "200 EMA W"...
//  • Global EMA/SMA switch + per-slot type override (EMA/SMA/WMA/HMA/RMA/VWMA)
//  • Golden / Death cross ON by default, measured on the DAILY 50 vs 200
//    (works on any chart timeframe), plus ribbon fill, info table, alerts
//  • Palette uses mid-tone hues that stay readable on light AND dark charts
// ═══════════════════════════════════════════════════════════════════════════
indicator("Multi EMA/SMA Pro — 5/13/20/50/100/200 + MTF", shorttitle="Multi MA Pro", overlay=true, max_labels_count=500)

// ───────────────────────────── GENERAL ─────────────────────────────────────
gGen       = "① General"
maTypeG    = input.string("EMA", "Default MA type", options=["EMA","SMA","WMA","HMA","RMA","VWMA"], group=gGen, tooltip="Master EMA vs SMA switch. Each MA slot can override this.")
srcG       = input.source(close, "Source", group=gGen)
waitClose  = input.bool(false, "Higher TF: wait for bar close (non-repainting)", group=gGen, tooltip="ON  = the HTF line only updates when the daily/weekly/monthly candle closes (no repaint, value lags one HTF bar).\nOFF = the HTF line updates live inside the forming HTF candle.")
styleSel   = input.string("Line", "Line style", options=["Line","Step line","Circles","Cross"], group=gGen, tooltip="'Step line' is the honest way to draw higher-timeframe averages.")
plotOffset = input.int(0, "Plot offset (bars)", minval=-100, maxval=100, group=gGen)
transpG    = input.int(0, "Line transparency", minval=0, maxval=100, group=gGen)

// ───────────────────────────── COLORING ────────────────────────────────────
gCol     = "② Slope coloring"
slopeCol = input.bool(false, "Color lines by slope (overrides slot colors)", group=gCol)
upCol    = input.color(#26A69A, "Rising", inline="sl", group=gCol)
dnCol    = input.color(#EF5350, "Falling", inline="sl", group=gCol)

// ───────────────────────────── LABELS ──────────────────────────────────────
gLab        = "③ Line labels"
showLabels  = input.bool(true, "Show a label on each line", group=gLab)
labShowLen  = input.bool(true,  "Length (200)",        inline="l1", group=gLab)
labShowType = input.bool(false, "Type (EMA)",          inline="l1", group=gLab)
labShowTF   = input.bool(true,  "Timeframe (D/W/M)",   inline="l1", group=gLab)
labShowVal  = input.bool(false, "Value",               inline="l1", group=gLab)
labShowPct  = input.bool(false, "Distance of price from the MA in % (e.g. 200 D  +18.06%)", group=gLab)
labStyle    = input.string("Text only", "Label style", options=["Text only","Bubble"], group=gLab)
labSize     = input.string("Small", "Label size", options=["Tiny","Small","Normal","Large"], group=gLab)
labOffset   = input.int(6, "Label offset (bars to the right)", minval=0, maxval=100, group=gLab)

// ───────────────────────────── MA SLOTS ────────────────────────────────────
tfOpts  = "Chart"
gA = "④ MA 1  ·  default 5"
en_1  = input.bool(false, "Show", inline="a1", group=gA)
len_1 = input.int(5, "Length", minval=1, inline="a1", group=gA)
typ_1 = input.string("Default", "Type", options=["Default","EMA","SMA","WMA","HMA","RMA","VWMA"], inline="b1", group=gA)
tfs_1 = input.string("Chart", "TF", options=["Chart","Daily","Weekly","Monthly","Custom"], inline="b1", group=gA)
tfc_1 = input.timeframe("60", "Custom TF", inline="c1", group=gA)
col_1 = input.color(#FF6D00, "", inline="c1", group=gA)
wid_1 = input.int(1, "Width", minval=1, maxval=5, inline="c1", group=gA)

gB = "⑤ MA 2  ·  default 13"
en_2  = input.bool(false, "Show", inline="a2", group=gB)
len_2 = input.int(13, "Length", minval=1, inline="a2", group=gB)
typ_2 = input.string("Default", "Type", options=["Default","EMA","SMA","WMA","HMA","RMA","VWMA"], inline="b2", group=gB)
tfs_2 = input.string("Chart", "TF", options=["Chart","Daily","Weekly","Monthly","Custom"], inline="b2", group=gB)
tfc_2 = input.timeframe("60", "Custom TF", inline="c2", group=gB)
col_2 = input.color(#F9A825, "", inline="c2", group=gB)
wid_2 = input.int(1, "Width", minval=1, maxval=5, inline="c2", group=gB)

gC = "⑥ MA 3  ·  default 20"
en_3  = input.bool(true, "Show", inline="a3", group=gC)
len_3 = input.int(20, "Length", minval=1, inline="a3", group=gC)
typ_3 = input.string("Default", "Type", options=["Default","EMA","SMA","WMA","HMA","RMA","VWMA"], inline="b3", group=gC)
tfs_3 = input.string("Chart", "TF", options=["Chart","Daily","Weekly","Monthly","Custom"], inline="b3", group=gC)
tfc_3 = input.timeframe("60", "Custom TF", inline="c3", group=gC)
col_3 = input.color(#00ACC1, "", inline="c3", group=gC)
wid_3 = input.int(2, "Width", minval=1, maxval=5, inline="c3", group=gC)

gD = "⑦ MA 4  ·  default 50"
en_4  = input.bool(true, "Show", inline="a4", group=gD)
len_4 = input.int(50, "Length", minval=1, inline="a4", group=gD)
typ_4 = input.string("Default", "Type", options=["Default","EMA","SMA","WMA","HMA","RMA","VWMA"], inline="b4", group=gD)
tfs_4 = input.string("Chart", "TF", options=["Chart","Daily","Weekly","Monthly","Custom"], inline="b4", group=gD)
tfc_4 = input.timeframe("60", "Custom TF", inline="c4", group=gD)
col_4 = input.color(#43A047, "", inline="c4", group=gD)
wid_4 = input.int(2, "Width", minval=1, maxval=5, inline="c4", group=gD)

gE = "⑧ MA 5  ·  default 100"
en_5  = input.bool(true, "Show", inline="a5", group=gE)
len_5 = input.int(100, "Length", minval=1, inline="a5", group=gE)
typ_5 = input.string("Default", "Type", options=["Default","EMA","SMA","WMA","HMA","RMA","VWMA"], inline="b5", group=gE)
tfs_5 = input.string("Chart", "TF", options=["Chart","Daily","Weekly","Monthly","Custom"], inline="b5", group=gE)
tfc_5 = input.timeframe("60", "Custom TF", inline="c5", group=gE)
col_5 = input.color(#1E88E5, "", inline="c5", group=gE)
wid_5 = input.int(2, "Width", minval=1, maxval=5, inline="c5", group=gE)

gF = "⑨ MA 6  ·  default 200"
en_6  = input.bool(true, "Show", inline="a6", group=gF)
len_6 = input.int(200, "Length", minval=1, inline="a6", group=gF)
typ_6 = input.string("Default", "Type", options=["Default","EMA","SMA","WMA","HMA","RMA","VWMA"], inline="b6", group=gF)
tfs_6 = input.string("Chart", "TF", options=["Chart","Daily","Weekly","Monthly","Custom"], inline="b6", group=gF)
tfc_6 = input.timeframe("60", "Custom TF", inline="c6", group=gF)
col_6 = input.color(#E53935, "", inline="c6", group=gF)
wid_6 = input.int(3, "Width", minval=1, maxval=5, inline="c6", group=gF)

gG = "⑩ MA 7  ·  default 200 DAILY"
en_7  = input.bool(false, "Show", inline="a7", group=gG)
len_7 = input.int(200, "Length", minval=1, inline="a7", group=gG)
typ_7 = input.string("Default", "Type", options=["Default","EMA","SMA","WMA","HMA","RMA","VWMA"], inline="b7", group=gG)
tfs_7 = input.string("Daily", "TF", options=["Chart","Daily","Weekly","Monthly","Custom"], inline="b7", group=gG)
tfc_7 = input.timeframe("240", "Custom TF", inline="c7", group=gG)
col_7 = input.color(#8E24AA, "", inline="c7", group=gG)
wid_7 = input.int(2, "Width", minval=1, maxval=5, inline="c7", group=gG)

gH = "⑪ MA 8  ·  default 30 WEEKLY"
en_8  = input.bool(false, "Show", inline="a8", group=gH)
len_8 = input.int(30, "Length", minval=1, inline="a8", group=gH)
typ_8 = input.string("Default", "Type", options=["Default","EMA","SMA","WMA","HMA","RMA","VWMA"], inline="b8", group=gH)
tfs_8 = input.string("Weekly", "TF", options=["Chart","Daily","Weekly","Monthly","Custom"], inline="b8", group=gH)
tfc_8 = input.timeframe("240", "Custom TF", inline="c8", group=gH)
col_8 = input.color(#546E7A, "", inline="c8", group=gH)
wid_8 = input.int(2, "Width", minval=1, maxval=5, inline="c8", group=gH)

gI = "⑫ MA 9  ·  default 200 WEEKLY"
en_9  = input.bool(false, "Show", inline="a9", group=gI)
len_9 = input.int(200, "Length", minval=1, inline="a9", group=gI)
typ_9 = input.string("Default", "Type", options=["Default","EMA","SMA","WMA","HMA","RMA","VWMA"], inline="b9", group=gI)
tfs_9 = input.string("Weekly", "TF", options=["Chart","Daily","Weekly","Monthly","Custom"], inline="b9", group=gI)
tfc_9 = input.timeframe("240", "Custom TF", inline="c9", group=gI)
col_9 = input.color(#EC407A, "", inline="c9", group=gI)
wid_9 = input.int(2, "Width", minval=1, maxval=5, inline="c9", group=gI)

// ───────────────────────────── EXTRAS ──────────────────────────────────────
gX     = "⑬ Ribbon fill"
fillOn = input.bool(false, "Fill between two MAs", group=gX)
fillA  = input.int(3, "Slot A", minval=1, maxval=9, inline="f1", group=gX)
fillB  = input.int(6, "Slot B", minval=1, maxval=9, inline="f1", group=gX)
fillUp = input.color(color.new(#26A69A, 88), "A above", inline="f2", group=gX)
fillDn = input.color(color.new(#EF5350, 88), "A below", inline="f2", group=gX)

gY       = "⑭ Golden / Death cross"
xOn      = input.bool(true, "Mark GC / DC crosses", group=gY)
xMode    = input.string("Dedicated", "Measured on", options=["Dedicated","Use MA slots"], group=gY, tooltip="'Dedicated' uses its own length/timeframe pair below (default 50 vs 200 on the DAILY, so intraday charts still show the real golden cross).\n'Use MA slots' reads two of the nine MA slots instead.")
xTF      = input.string("Daily", "Timeframe", options=["Chart","Daily","Weekly","Monthly","Custom"], inline="x0", group=gY)
xTFc     = input.timeframe("1D", "Custom", inline="x0", group=gY)
xFastLen = input.int(50, "Fast length", minval=1, inline="x1", group=gY)
xSlowLen = input.int(200, "Slow length", minval=1, inline="x1", group=gY)
xType    = input.string("Default", "Type", options=["Default","EMA","SMA","WMA","HMA","RMA","VWMA"], group=gY)
xFast    = input.int(4, "Fast slot", minval=1, maxval=9, inline="x2", group=gY)
xSlow    = input.int(6, "Slow slot", minval=1, maxval=9, inline="x2", group=gY)
xShowTxt = input.bool(true, "Text on markers (e.g. GC 50/200 D)", group=gY)

gZ      = "⑮ Info table"
tblOn   = input.bool(true, "Show MA table", group=gZ)
tblPos  = input.string("Top right", "Position", options=["Top left","Top right","Bottom left","Bottom right"], group=gZ)
tblBg   = input.color(color.new(color.black, 70), "Background", group=gZ)
tblDec  = input.int(2, "% decimals", minval=0, maxval=4, group=gZ, tooltip="The last column shows how far the current price is from each MA, e.g. ▲ +2.35% / ▼ -18.40%.")

// ───────────────────────────── ENGINE ──────────────────────────────────────
f_ma(_src, _len, _type) =>
    l = math.max(_len, 1)
    s = ta.sma(_src, l)
    e = ta.ema(_src, l)
    w = ta.wma(_src, l)
    h = ta.hma(_src, math.max(l, 4))
    r = ta.rma(_src, l)
    v = ta.vwma(_src, l)
    switch _type
        "SMA"  => s
        "WMA"  => w
        "HMA"  => h
        "RMA"  => r
        "VWMA" => v
        => e

f_pair(_len, _type) =>
    m = f_ma(srcG, _len, _type)
    [m, m[1]]

// returns [value, timeframe-suffix, resolved type]
f_slot(_len, _tfSel, _tfCustom, _typSel) =>
    ty  = _typSel == "Default" ? maTypeG : _typSel
    tfI = _tfSel == "Daily" ? "1D" : _tfSel == "Weekly" ? "1W" : _tfSel == "Monthly" ? "1M" : _tfSel == "Custom" ? _tfCustom : timeframe.period
    // never request a timeframe lower than the chart — fall back to chart TF
    useChart = timeframe.in_seconds(tfI) <= timeframe.in_seconds(timeframe.period)
    tfR      = useChart ? timeframe.period : tfI
    local    = f_ma(srcG, _len, ty)
    [htfNow, htfPrev] = request.security(syminfo.tickerid, tfR, f_pair(_len, ty), lookahead=barmerge.lookahead_off)
    val = useChart ? local : (waitClose ? htfPrev : htfNow)
    sfx = useChart ? "" : (_tfSel == "Daily" ? "D" : _tfSel == "Weekly" ? "W" : _tfSel == "Monthly" ? "M" : _tfCustom)
    [val, sfx, ty]

[val_1, sfx_1, ty_1] = f_slot(len_1, tfs_1, tfc_1, typ_1)
[val_2, sfx_2, ty_2] = f_slot(len_2, tfs_2, tfc_2, typ_2)
[val_3, sfx_3, ty_3] = f_slot(len_3, tfs_3, tfc_3, typ_3)
[val_4, sfx_4, ty_4] = f_slot(len_4, tfs_4, tfc_4, typ_4)
[val_5, sfx_5, ty_5] = f_slot(len_5, tfs_5, tfc_5, typ_5)
[val_6, sfx_6, ty_6] = f_slot(len_6, tfs_6, tfc_6, typ_6)
[val_7, sfx_7, ty_7] = f_slot(len_7, tfs_7, tfc_7, typ_7)
[val_8, sfx_8, ty_8] = f_slot(len_8, tfs_8, tfc_8, typ_8)
[val_9, sfx_9, ty_9] = f_slot(len_9, tfs_9, tfc_9, typ_9)

// dedicated pair for the golden / death cross (defaults to 50 vs 200 daily)
[xdFast, xdSfx, xdTy] = f_slot(xFastLen, xTF, xTFc, xType)
[xdSlow, xdSfx2, xdTy2] = f_slot(xSlowLen, xTF, xTFc, xType)

f_col(_v, _base) =>
    c = slopeCol ? (_v > _v[1] ? upCol : _v < _v[1] ? dnCol : _base) : _base
    color.new(c, transpG)

pStyle = switch styleSel
    "Step line" => plot.style_stepline
    "Circles"   => plot.style_circles
    "Cross"     => plot.style_cross
    => plot.style_line

p1 = plot(en_1 ? val_1 : na, "MA 1", color=f_col(val_1, col_1), linewidth=wid_1, style=pStyle, offset=plotOffset)
p2 = plot(en_2 ? val_2 : na, "MA 2", color=f_col(val_2, col_2), linewidth=wid_2, style=pStyle, offset=plotOffset)
p3 = plot(en_3 ? val_3 : na, "MA 3", color=f_col(val_3, col_3), linewidth=wid_3, style=pStyle, offset=plotOffset)
p4 = plot(en_4 ? val_4 : na, "MA 4", color=f_col(val_4, col_4), linewidth=wid_4, style=pStyle, offset=plotOffset)
p5 = plot(en_5 ? val_5 : na, "MA 5", color=f_col(val_5, col_5), linewidth=wid_5, style=pStyle, offset=plotOffset)
p6 = plot(en_6 ? val_6 : na, "MA 6", color=f_col(val_6, col_6), linewidth=wid_6, style=pStyle, offset=plotOffset)
p7 = plot(en_7 ? val_7 : na, "MA 7", color=f_col(val_7, col_7), linewidth=wid_7, style=pStyle, offset=plotOffset)
p8 = plot(en_8 ? val_8 : na, "MA 8", color=f_col(val_8, col_8), linewidth=wid_8, style=pStyle, offset=plotOffset)
p9 = plot(en_9 ? val_9 : na, "MA 9", color=f_col(val_9, col_9), linewidth=wid_9, style=pStyle, offset=plotOffset)

// ───────────────────────────── LABELS ──────────────────────────────────────
labSizeC = switch labSize
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

f_txt(_len, _ty, _sfx, _val) =>
    t = labShowLen ? str.tostring(_len) : ""
    t := labShowType ? (t == "" ? _ty : t + " " + _ty) : t
    t := labShowTF and _sfx != "" ? (t == "" ? _sfx : t + " " + _sfx) : t
    t := labShowVal ? (t == "" ? "" : t + "  ") + str.tostring(math.round_to_mintick(_val)) : t
    pct = na(_val) or _val == 0 ? na : (close - _val) / _val * 100
    t := labShowPct and not na(pct) ? (t == "" ? "" : t + "  ") + (pct >= 0 ? "+" : "") + str.tostring(math.round(pct, 2)) + "%" : t
    t

f_label(_on, _val, _len, _ty, _sfx, _base) =>
    var label lb = na
    if barstate.islast
        label.delete(lb)
        if _on and showLabels and not na(_val)
            bubble = labStyle == "Bubble"
            lb := label.new(x=bar_index + labOffset, y=_val, text=f_txt(_len, _ty, _sfx, _val), xloc=xloc.bar_index, yloc=yloc.price,
                 color=bubble ? color.new(_base, 15) : color.new(color.black, 100),
                 textcolor=bubble ? color.white : _base,
                 style=bubble ? label.style_label_left : label.style_none,
                 size=labSizeC)
    lb

f_label(en_1, val_1, len_1, ty_1, sfx_1, col_1)
f_label(en_2, val_2, len_2, ty_2, sfx_2, col_2)
f_label(en_3, val_3, len_3, ty_3, sfx_3, col_3)
f_label(en_4, val_4, len_4, ty_4, sfx_4, col_4)
f_label(en_5, val_5, len_5, ty_5, sfx_5, col_5)
f_label(en_6, val_6, len_6, ty_6, sfx_6, col_6)
f_label(en_7, val_7, len_7, ty_7, sfx_7, col_7)
f_label(en_8, val_8, len_8, ty_8, sfx_8, col_8)
f_label(en_9, val_9, len_9, ty_9, sfx_9, col_9)

// ───────────────────────────── FILL ────────────────────────────────────────
f_pick(_n) =>
    _n == 1 ? val_1 : _n == 2 ? val_2 : _n == 3 ? val_3 : _n == 4 ? val_4 : _n == 5 ? val_5 : _n == 6 ? val_6 : _n == 7 ? val_7 : _n == 8 ? val_8 : val_9

fa = plot(fillOn ? f_pick(fillA) : na, "Fill A", display=display.none, editable=false)
fb = plot(fillOn ? f_pick(fillB) : na, "Fill B", display=display.none, editable=false)
fill(fa, fb, color=f_pick(fillA) >= f_pick(fillB) ? fillUp : fillDn, title="MA ribbon fill")

// ───────────────────────────── CROSSES ─────────────────────────────────────
useSlots = xMode == "Use MA slots"
fastV    = useSlots ? f_pick(xFast) : xdFast
slowV    = useSlots ? f_pick(xSlow) : xdSlow
gold     = xOn and ta.crossover(fastV, slowV)
death    = xOn and ta.crossunder(fastV, slowV)
plotshape(gold,  "Golden cross", shape.triangleup,   location.belowbar, color.new(#26A69A, 0), size=size.tiny)
plotshape(death, "Death cross",  shape.triangledown, location.abovebar, color.new(#EF5350, 0), size=size.tiny)

xTxt = useSlots ? "" : " " + str.tostring(xFastLen) + "/" + str.tostring(xSlowLen) + (xdSfx != "" ? " " + xdSfx : "")
if xShowTxt and (gold or death)
    label.new(bar_index, gold ? low : high, (gold ? "GC" : "DC") + xTxt,
         xloc=xloc.bar_index, yloc=gold ? yloc.belowbar : yloc.abovebar,
         style=gold ? label.style_label_up : label.style_label_down,
         color=color.new(gold ? #26A69A : #EF5350, 10), textcolor=color.white, size=size.tiny)

// ───────────────────────────── TABLE ───────────────────────────────────────
tblPosC = switch tblPos
    "Top left"     => position.top_left
    "Bottom left"  => position.bottom_left
    "Bottom right" => position.bottom_right
    => position.top_right

var table infoT = table.new(tblPosC, 3, 10, bgcolor=tblBg, border_width=1, border_color=color.new(color.gray, 60))

if barstate.islast
    table.clear(infoT, 0, 0, 2, 9)
    if tblOn
        ens  = array.from(en_1, en_2, en_3, en_4, en_5, en_6, en_7, en_8, en_9)
        lens = array.from(len_1, len_2, len_3, len_4, len_5, len_6, len_7, len_8, len_9)
        vals = array.from(val_1, val_2, val_3, val_4, val_5, val_6, val_7, val_8, val_9)
        sfxs = array.from(sfx_1, sfx_2, sfx_3, sfx_4, sfx_5, sfx_6, sfx_7, sfx_8, sfx_9)
        tyss = array.from(ty_1, ty_2, ty_3, ty_4, ty_5, ty_6, ty_7, ty_8, ty_9)
        cols = array.from(col_1, col_2, col_3, col_4, col_5, col_6, col_7, col_8, col_9)
        table.cell(infoT, 0, 0, "MA",    text_color=color.gray, text_size=size.small)
        table.cell(infoT, 1, 0, "Value", text_color=color.gray, text_size=size.small)
        table.cell(infoT, 2, 0, "Price", text_color=color.gray, text_size=size.small)
        r = 1
        for i = 0 to 8
            if array.get(ens, i)
                sfx = array.get(sfxs, i)
                nm  = str.tostring(array.get(lens, i)) + " " + array.get(tyss, i) + (sfx != "" ? " " + sfx : "")
                vv  = array.get(vals, i)
                table.cell(infoT, 0, r, nm, text_color=array.get(cols, i), text_size=size.small)
                table.cell(infoT, 1, r, na(vv) ? "n/a" : str.tostring(math.round_to_mintick(vv)), text_color=color.new(color.white, 20), text_size=size.small)
                pct = na(vv) or vv == 0 ? na : (close - vv) / vv * 100
                pxTxt = na(pct) ? "n/a" : (pct >= 0 ? "▲ +" : "▼ ") + str.tostring(math.round(pct, tblDec)) + "%"
                table.cell(infoT, 2, r, pxTxt, text_color=na(pct) ? color.gray : (pct >= 0 ? #26A69A : #EF5350), text_size=size.small)
                r := r + 1

// ───────────────────────────── ALERTS ──────────────────────────────────────
alertcondition(en_1 and ta.crossover(close, val_1),  "Price crossed ABOVE MA 1", "Price crossed above MA 1")
alertcondition(en_1 and ta.crossunder(close, val_1), "Price crossed BELOW MA 1", "Price crossed below MA 1")
alertcondition(en_2 and ta.crossover(close, val_2),  "Price crossed ABOVE MA 2", "Price crossed above MA 2")
alertcondition(en_2 and ta.crossunder(close, val_2), "Price crossed BELOW MA 2", "Price crossed below MA 2")
alertcondition(en_3 and ta.crossover(close, val_3),  "Price crossed ABOVE MA 3", "Price crossed above MA 3")
alertcondition(en_3 and ta.crossunder(close, val_3), "Price crossed BELOW MA 3", "Price crossed below MA 3")
alertcondition(en_4 and ta.crossover(close, val_4),  "Price crossed ABOVE MA 4", "Price crossed above MA 4")
alertcondition(en_4 and ta.crossunder(close, val_4), "Price crossed BELOW MA 4", "Price crossed below MA 4")
alertcondition(en_5 and ta.crossover(close, val_5),  "Price crossed ABOVE MA 5", "Price crossed above MA 5")
alertcondition(en_5 and ta.crossunder(close, val_5), "Price crossed BELOW MA 5", "Price crossed below MA 5")
alertcondition(en_6 and ta.crossover(close, val_6),  "Price crossed ABOVE MA 6", "Price crossed above MA 6")
alertcondition(en_6 and ta.crossunder(close, val_6), "Price crossed BELOW MA 6", "Price crossed below MA 6")
alertcondition(en_7 and ta.crossover(close, val_7),  "Price crossed ABOVE MA 7", "Price crossed above MA 7")
alertcondition(en_7 and ta.crossunder(close, val_7), "Price crossed BELOW MA 7", "Price crossed below MA 7")
alertcondition(en_8 and ta.crossover(close, val_8),  "Price crossed ABOVE MA 8", "Price crossed above MA 8")
alertcondition(en_8 and ta.crossunder(close, val_8), "Price crossed BELOW MA 8", "Price crossed below MA 8")
alertcondition(en_9 and ta.crossover(close, val_9),  "Price crossed ABOVE MA 9", "Price crossed above MA 9")
alertcondition(en_9 and ta.crossunder(close, val_9), "Price crossed BELOW MA 9", "Price crossed below MA 9")
alertcondition(gold,  "Golden cross", "Fast MA crossed above slow MA")
alertcondition(death, "Death cross",  "Fast MA crossed below slow MA")
````
