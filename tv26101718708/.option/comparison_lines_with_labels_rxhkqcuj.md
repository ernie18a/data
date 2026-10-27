# Comparison Lines with Labels

- url: https://www.tradingview.com/script/RXhKqcuj-Comparison-Lines-with-Labels/
- type: indicator
- pine_id: PUB;9b6ad2e2ef024b618a47dc3695a228c1
- version: 3.0

## Description

What It Does
This indicator overlays up to 7 additional ticker symbols onto your main chart as rebased price lines, allowing direct visual comparison of relative performance across multiple assets simultaneously.
The key mechanic is percentage rebasing: every line — including the main chart's own price — is normalised so that all series start at the same price point (the main chart's closing price at the left edge of your visible window). This means you're not comparing absolute prices, you're comparing relative returns from a common starting point.
Because the anchor point is tied to the visible left edge rather than a fixed date, the comparison automatically adjusts whenever you scroll or zoom. Every time you change your view window, all lines re-anchor together — no manual reconfiguration required.

End-of-Line Labels
Each line displays a floating label at the right edge of the chart showing:

The ticker symbol or full instrument name (your choice)
The % return from the visible left edge (e.g. +12.45% or -3.20%)

Labels stay pinned to their line's current price level at all times. Unlike static text boxes, they never need to be repositioned after zooming, scrolling, or changing timeframes — they're always exactly where you need them.

Intended Use Case — Sector Rotation & Comparative Analysis
The primary use case is sector scanning and money flow analysis. Load a basket of related tickers — for example, a set of sector ETFs, a group of resource stocks, or competing names within a theme — and immediately see:

Which instrument is leading or lagging from any given starting point
Where relative momentum is strongest
How quickly the spread between instruments is widening or narrowing

Because you can run up to 7 comparisons at once and each line is clearly labelled with its name and return percentage, you can monitor a dense watchlist without needing to cross-reference a legend, create manual text annotations, or maintain separate charts.

Settings Reference
GroupSettingPurposeSymbolsSymbol 1–7Enter any valid TradingView ticker (e.g. ASX:BHP, AMEX:XLE)SymbolsShow Base Symbol LinePlots the main chart's own rebased line — hidden by default as it overlaps candlesDisplayShow % Return in LabelAppends the return figure to each end labelDisplayShow Display NameUses the instrument's full name instead of the raw ticker codeDisplayShow Anchor Dot at StartPlaces a small circle on each line at the rebasing anchor barDisplayLabel OffsetPushes labels right by N bars so they don't overlap the last candleDisplayLine WidthVisual thickness of comparison lines (1–4)ColorsBase / Symbol 1–7Individual colour assignment per line

Important Notes

Remove any previous version before adding this indicator — two copies will cause price scale conflicts.
The indicator runs on the same timeframe as the main chart. Switching timeframes resets and recalculates everything automatically.
If a comparison ticker has no data at the visible left edge (e.g. a recently listed stock), its line will rebase from its own first available bar instead. The anchor dot will appear at a different height on those tickers, which is a visual cue that the start point differs.
max_labels_count=50 is set at the indicator level — labels are deleted and recreated on every tick so only the current set persists.

## Source Code

````pine
// ─────────────────────────────────────────────────────────────────────────────
// Comparison Lines + RSC Shading  │  Pine Script v5
// ─────────────────────────────────────────────────────────────────────────────
// Same as "Comparison + End Labels", but each line is shaded per-bar by the
// momentum of its Relative Strength Comparison (RSC) vs a configurable
// benchmark ticker (default ASX:XJO). Base hue per symbol is preserved; the
// line brightens (less transparent) when RSC ROC is positive and fades when
// RSC ROC is negative/flat. Labels also show the RSC % change vs benchmark
// over the visible window.
//
// ► IMPORTANT: Remove any previous version of this indicator before adding.
//
// ► HOW TO USE
//   1. Add to chart — overlays on the main price pane.
//   2. Open Settings → "Symbols" and enter up to 15 tickers.
//   3. In "Relative Strength" set the benchmark and tune the ROC lookback /
//      scale to taste. Default benchmark is ASX:XJO.
// ─────────────────────────────────────────────────────────────────────────────

//@version=5
indicator("Comparison + RSC Shading", shorttitle="Comparison RSC",
          overlay=true, max_labels_count=50)

// ══════════════════════════════════════════════════════════════════════════════
// INPUTS
// ══════════════════════════════════════════════════════════════════════════════
grpS = "Symbols"
show_base = input.bool(false, "Show Base Symbol Line (overlaps candles)", group=grpS)
t1  = input.symbol("", "Symbol 1",  group=grpS)
t2  = input.symbol("", "Symbol 2",  group=grpS)
t3  = input.symbol("", "Symbol 3",  group=grpS)
t4  = input.symbol("", "Symbol 4",  group=grpS)
t5  = input.symbol("", "Symbol 5",  group=grpS)
t6  = input.symbol("", "Symbol 6",  group=grpS)
t7  = input.symbol("", "Symbol 7",  group=grpS)
t8  = input.symbol("", "Symbol 8",  group=grpS)
t9  = input.symbol("", "Symbol 9",  group=grpS)
t10 = input.symbol("", "Symbol 10", group=grpS)
t11 = input.symbol("", "Symbol 11", group=grpS)
t12 = input.symbol("", "Symbol 12", group=grpS)
t13 = input.symbol("", "Symbol 13", group=grpS)
t14 = input.symbol("", "Symbol 14", group=grpS)
t15 = input.symbol("", "Symbol 15", group=grpS)

grpR = "Relative Strength"
use_rsc = input.bool(false,        "Enable RSC Shading",      group=grpR)
bench   = input.symbol("ASX:XJO", "Benchmark Ticker",        group=grpR)
rsc_lb  = input.int(10,           "RSC ROC Lookback (bars)", group=grpR, minval=1, maxval=200)
rsc_sc  = input.float(5.0,        "RSC ROC Scale (%)",       group=grpR, minval=0.1, step=0.5, tooltip="ROC value at which the line reaches maximum brightness. Higher = needs stronger RSC momentum to brighten.")
rsc_tmx = input.int(85,           "Faded Transparency",      group=grpR, minval=0, maxval=100, tooltip="Transparency used when RSC is flat/falling. 0=opaque, 100=invisible.")
rsc_tmn = input.int(0,            "Vivid Transparency",      group=grpR, minval=0, maxval=100, tooltip="Transparency used when RSC ROC ≥ scale. 0=fully opaque.")
show_rs = input.bool(true,        "Show RSC % in Label",     group=grpR)

grpD = "Display"
show_pct      = input.bool(true,      "Show % Return in Label",         group=grpD)
use_disp_name = input.bool(true,      "Show Display Name (not ticker)", group=grpD)
show_anchor   = input.bool(true,      "Show Anchor Dot at Start",       group=grpD)
lbl_size      = input.string("small", "Label Size",                     group=grpD, options=["tiny","small","normal","large","huge"])
lbl_offset    = input.int(2,          "Label Offset (bars right)",      group=grpD, minval=0, maxval=20)
lw            = input.int(2,          "Line Width",                     group=grpD, minval=1, maxval=4)

grpC = "Colors"
c0  = input.color(#1E88E5, "Base Symbol", group=grpC)
c1  = input.color(#E53935, "Symbol 1",    group=grpC)
c2  = input.color(#43A047, "Symbol 2",    group=grpC)
c3  = input.color(#FB8C00, "Symbol 3",    group=grpC)
c4  = input.color(#8E24AA, "Symbol 4",    group=grpC)
c5  = input.color(#00ACC1, "Symbol 5",    group=grpC)
c6  = input.color(#F06292, "Symbol 6",    group=grpC)
c7  = input.color(#FFB300, "Symbol 7",    group=grpC)
c8  = input.color(#26A69A, "Symbol 8",    group=grpC)
c9  = input.color(#EF5350, "Symbol 9",    group=grpC)
c10 = input.color(#66BB6A, "Symbol 10",   group=grpC)
c11 = input.color(#7E57C2, "Symbol 11",   group=grpC)
c12 = input.color(#FFA726, "Symbol 12",   group=grpC)
c13 = input.color(#26C6DA, "Symbol 13",   group=grpC)
c14 = input.color(#EC407A, "Symbol 14",   group=grpC)
c15 = input.color(#D4E157, "Symbol 15",   group=grpC)

// ══════════════════════════════════════════════════════════════════════════════
// REFERENCE BAR — leftmost visible bar on screen
// ══════════════════════════════════════════════════════════════════════════════
_lv = chart.left_visible_bar_time

var float _base = na
if na(_base) and time >= _lv
    _base := close

is_ref_bar = na(_base[1]) and not na(_base)

// ══════════════════════════════════════════════════════════════════════════════
// PRICE DATA
// ══════════════════════════════════════════════════════════════════════════════
p0  = close
p1  = t1  != "" ? request.security(t1,  timeframe.period, close, ignore_invalid_symbol=true) : na
p2  = t2  != "" ? request.security(t2,  timeframe.period, close, ignore_invalid_symbol=true) : na
p3  = t3  != "" ? request.security(t3,  timeframe.period, close, ignore_invalid_symbol=true) : na
p4  = t4  != "" ? request.security(t4,  timeframe.period, close, ignore_invalid_symbol=true) : na
p5  = t5  != "" ? request.security(t5,  timeframe.period, close, ignore_invalid_symbol=true) : na
p6  = t6  != "" ? request.security(t6,  timeframe.period, close, ignore_invalid_symbol=true) : na
p7  = t7  != "" ? request.security(t7,  timeframe.period, close, ignore_invalid_symbol=true) : na
p8  = t8  != "" ? request.security(t8,  timeframe.period, close, ignore_invalid_symbol=true) : na
p9  = t9  != "" ? request.security(t9,  timeframe.period, close, ignore_invalid_symbol=true) : na
p10 = t10 != "" ? request.security(t10, timeframe.period, close, ignore_invalid_symbol=true) : na
p11 = t11 != "" ? request.security(t11, timeframe.period, close, ignore_invalid_symbol=true) : na
p12 = t12 != "" ? request.security(t12, timeframe.period, close, ignore_invalid_symbol=true) : na
p13 = t13 != "" ? request.security(t13, timeframe.period, close, ignore_invalid_symbol=true) : na
p14 = t14 != "" ? request.security(t14, timeframe.period, close, ignore_invalid_symbol=true) : na
p15 = t15 != "" ? request.security(t15, timeframe.period, close, ignore_invalid_symbol=true) : na

pB = bench != "" ? request.security(bench, timeframe.period, close, ignore_invalid_symbol=true) : na

// ══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
// ══════════════════════════════════════════════════════════════════════════════

// Rebase src to main chart's left-edge price. Returns [rebased, pct_return].
rebase(src) =>
    var float _ref = na
    if na(_ref) and time >= _lv and not na(src)
        _ref := src
    rebased = na(_ref) or na(src) or na(_base) ? na : _base * (src / _ref)
    pct_ret = na(_ref) or na(src)               ? na : (src / _ref - 1.0) * 100.0
    [rebased, pct_ret]

// RSC ratio (NaN-safe)
rsc_of(p) => na(p) or na(pB) or pB == 0 ? na : p / pB

// RSC % change from left-edge reference bar — for label.
rsc_rebase(p) =>
    rsc = rsc_of(p)
    var float _ref = na
    if na(_ref) and time >= _lv and not na(rsc)
        _ref := rsc
    na(_ref) or na(rsc) ? na : (rsc / _ref - 1.0) * 100.0

// Per-bar shaded colour based on RSC momentum.
// When RSC shading is disabled the line is drawn in its solid base colour.
// Positive ROC → brighter (lower transparency); flat/negative → faded.
shade(base, rsc) =>
    if not use_rsc
        color.new(base, 0)
    else
        roc = ta.roc(rsc, rsc_lb)
        strength = na(roc) ? 0.0 : math.max(0.0, math.min(1.0, roc / rsc_sc))
        transp = int(math.round(rsc_tmx - strength * (rsc_tmx - rsc_tmn)))
        color.new(base, transp)

strip_exch(sym) =>
    parts = str.split(sym, ":")
    array.size(parts) > 1 ? array.get(parts, array.size(parts) - 1) : sym

sz() =>
    lbl_size == "tiny"  ? size.tiny  :
     lbl_size == "small" ? size.small :
     lbl_size == "large" ? size.large :
     lbl_size == "huge"  ? size.huge  : size.normal

mk_lbl(price_y, pct_val, rs_val, tick_str, name_str, clr) =>
    nstr = use_disp_name and name_str != "" ? "  " + name_str : ""
    pstr = show_pct and not na(pct_val) ? (pct_val >= 0 ? "  +" : "  ") + str.tostring(pct_val, "#.##") + "%" : ""
    rstr = use_rsc and show_rs and not na(rs_val) ? "  RS " + (rs_val >= 0 ? "+" : "") + str.tostring(rs_val, "#.##") + "%" : ""
    label.new(
         x         = bar_index + lbl_offset,
         y         = price_y,
         text      = tick_str + nstr + pstr + rstr,
         color     = color.new(clr, 88),
         textcolor = clr,
         style     = label.style_label_left,
         size      = sz(),
         xloc      = xloc.bar_index,
         yloc      = yloc.price
     )

// ══════════════════════════════════════════════════════════════════════════════
// DISPLAY NAMES
// ══════════════════════════════════════════════════════════════════════════════
d0  = syminfo.description
d1  = t1  != "" ? request.security(t1,  timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d2  = t2  != "" ? request.security(t2,  timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d3  = t3  != "" ? request.security(t3,  timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d4  = t4  != "" ? request.security(t4,  timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d5  = t5  != "" ? request.security(t5,  timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d6  = t6  != "" ? request.security(t6,  timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d7  = t7  != "" ? request.security(t7,  timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d8  = t8  != "" ? request.security(t8,  timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d9  = t9  != "" ? request.security(t9,  timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d10 = t10 != "" ? request.security(t10, timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d11 = t11 != "" ? request.security(t11, timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d12 = t12 != "" ? request.security(t12, timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d13 = t13 != "" ? request.security(t13, timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d14 = t14 != "" ? request.security(t14, timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""
d15 = t15 != "" ? request.security(t15, timeframe.period, syminfo.description, ignore_invalid_symbol=true) : ""

// Ticker strings (always shown first in the label)
lname0  = syminfo.ticker
lname1  = strip_exch(t1)
lname2  = strip_exch(t2)
lname3  = strip_exch(t3)
lname4  = strip_exch(t4)
lname5  = strip_exch(t5)
lname6  = strip_exch(t6)
lname7  = strip_exch(t7)
lname8  = strip_exch(t8)
lname9  = strip_exch(t9)
lname10 = strip_exch(t10)
lname11 = strip_exch(t11)
lname12 = strip_exch(t12)
lname13 = strip_exch(t13)
lname14 = strip_exch(t14)
lname15 = strip_exch(t15)

// ══════════════════════════════════════════════════════════════════════════════
// REBASED SERIES + RSC SERIES
// ══════════════════════════════════════════════════════════════════════════════
[n0,  r0]  = rebase(p0)
[n1,  r1]  = rebase(p1)
[n2,  r2]  = rebase(p2)
[n3,  r3]  = rebase(p3)
[n4,  r4]  = rebase(p4)
[n5,  r5]  = rebase(p5)
[n6,  r6]  = rebase(p6)
[n7,  r7]  = rebase(p7)
[n8,  r8]  = rebase(p8)
[n9,  r9]  = rebase(p9)
[n10, r10] = rebase(p10)
[n11, r11] = rebase(p11)
[n12, r12] = rebase(p12)
[n13, r13] = rebase(p13)
[n14, r14] = rebase(p14)
[n15, r15] = rebase(p15)

rs0  = rsc_rebase(p0)
rs1  = rsc_rebase(p1)
rs2  = rsc_rebase(p2)
rs3  = rsc_rebase(p3)
rs4  = rsc_rebase(p4)
rs5  = rsc_rebase(p5)
rs6  = rsc_rebase(p6)
rs7  = rsc_rebase(p7)
rs8  = rsc_rebase(p8)
rs9  = rsc_rebase(p9)
rs10 = rsc_rebase(p10)
rs11 = rsc_rebase(p11)
rs12 = rsc_rebase(p12)
rs13 = rsc_rebase(p13)
rs14 = rsc_rebase(p14)
rs15 = rsc_rebase(p15)

// Per-bar shaded colour for each line
col0  = shade(c0,  rsc_of(p0))
col1  = shade(c1,  rsc_of(p1))
col2  = shade(c2,  rsc_of(p2))
col3  = shade(c3,  rsc_of(p3))
col4  = shade(c4,  rsc_of(p4))
col5  = shade(c5,  rsc_of(p5))
col6  = shade(c6,  rsc_of(p6))
col7  = shade(c7,  rsc_of(p7))
col8  = shade(c8,  rsc_of(p8))
col9  = shade(c9,  rsc_of(p9))
col10 = shade(c10, rsc_of(p10))
col11 = shade(c11, rsc_of(p11))
col12 = shade(c12, rsc_of(p12))
col13 = shade(c13, rsc_of(p13))
col14 = shade(c14, rsc_of(p14))
col15 = shade(c15, rsc_of(p15))

// ══════════════════════════════════════════════════════════════════════════════
// PLOTS
// ══════════════════════════════════════════════════════════════════════════════
plot(show_base ? n0 : na, title="Base",      color=col0,  linewidth=lw)
plot(n1,                  title="Symbol 1",  color=col1,  linewidth=lw)
plot(n2,                  title="Symbol 2",  color=col2,  linewidth=lw)
plot(n3,                  title="Symbol 3",  color=col3,  linewidth=lw)
plot(n4,                  title="Symbol 4",  color=col4,  linewidth=lw)
plot(n5,                  title="Symbol 5",  color=col5,  linewidth=lw)
plot(n6,                  title="Symbol 6",  color=col6,  linewidth=lw)
plot(n7,                  title="Symbol 7",  color=col7,  linewidth=lw)
plot(n8,                  title="Symbol 8",  color=col8,  linewidth=lw)
plot(n9,                  title="Symbol 9",  color=col9,  linewidth=lw)
plot(n10,                 title="Symbol 10", color=col10, linewidth=lw)
plot(n11,                 title="Symbol 11", color=col11, linewidth=lw)
plot(n12,                 title="Symbol 12", color=col12, linewidth=lw)
plot(n13,                 title="Symbol 13", color=col13, linewidth=lw)
plot(n14,                 title="Symbol 14", color=col14, linewidth=lw)
plot(n15,                 title="Symbol 15", color=col15, linewidth=lw)

// Anchor dots — solid base colour at the reference bar.
_show = show_anchor and is_ref_bar
plotshape(_show and show_base and not na(n0)  ? n0  : na, title="Anchor 0",  style=shape.circle, color=c0,  size=size.tiny, location=location.absolute)
plotshape(_show and t1  != "" and not na(n1)  ? n1  : na, title="Anchor 1",  style=shape.circle, color=c1,  size=size.tiny, location=location.absolute)
plotshape(_show and t2  != "" and not na(n2)  ? n2  : na, title="Anchor 2",  style=shape.circle, color=c2,  size=size.tiny, location=location.absolute)
plotshape(_show and t3  != "" and not na(n3)  ? n3  : na, title="Anchor 3",  style=shape.circle, color=c3,  size=size.tiny, location=location.absolute)
plotshape(_show and t4  != "" and not na(n4)  ? n4  : na, title="Anchor 4",  style=shape.circle, color=c4,  size=size.tiny, location=location.absolute)
plotshape(_show and t5  != "" and not na(n5)  ? n5  : na, title="Anchor 5",  style=shape.circle, color=c5,  size=size.tiny, location=location.absolute)
plotshape(_show and t6  != "" and not na(n6)  ? n6  : na, title="Anchor 6",  style=shape.circle, color=c6,  size=size.tiny, location=location.absolute)
plotshape(_show and t7  != "" and not na(n7)  ? n7  : na, title="Anchor 7",  style=shape.circle, color=c7,  size=size.tiny, location=location.absolute)
plotshape(_show and t8  != "" and not na(n8)  ? n8  : na, title="Anchor 8",  style=shape.circle, color=c8,  size=size.tiny, location=location.absolute)
plotshape(_show and t9  != "" and not na(n9)  ? n9  : na, title="Anchor 9",  style=shape.circle, color=c9,  size=size.tiny, location=location.absolute)
plotshape(_show and t10 != "" and not na(n10) ? n10 : na, title="Anchor 10", style=shape.circle, color=c10, size=size.tiny, location=location.absolute)
plotshape(_show and t11 != "" and not na(n11) ? n11 : na, title="Anchor 11", style=shape.circle, color=c11, size=size.tiny, location=location.absolute)
plotshape(_show and t12 != "" and not na(n12) ? n12 : na, title="Anchor 12", style=shape.circle, color=c12, size=size.tiny, location=location.absolute)
plotshape(_show and t13 != "" and not na(n13) ? n13 : na, title="Anchor 13", style=shape.circle, color=c13, size=size.tiny, location=location.absolute)
plotshape(_show and t14 != "" and not na(n14) ? n14 : na, title="Anchor 14", style=shape.circle, color=c14, size=size.tiny, location=location.absolute)
plotshape(_show and t15 != "" and not na(n15) ? n15 : na, title="Anchor 15", style=shape.circle, color=c15, size=size.tiny, location=location.absolute)

// ══════════════════════════════════════════════════════════════════════════════
// END-OF-LINE LABELS
// ══════════════════════════════════════════════════════════════════════════════
var label lbl0  = na
var label lbl1  = na
var label lbl2  = na
var label lbl3  = na
var label lbl4  = na
var label lbl5  = na
var label lbl6  = na
var label lbl7  = na
var label lbl8  = na
var label lbl9  = na
var label lbl10 = na
var label lbl11 = na
var label lbl12 = na
var label lbl13 = na
var label lbl14 = na
var label lbl15 = na

if barstate.islast
    label.delete(lbl0)
    lbl0  := show_base and not na(n0)  ? mk_lbl(n0,  r0,  rs0,  lname0,  d0,  c0)  : na

    label.delete(lbl1)
    lbl1  := t1  != "" and not na(n1)  ? mk_lbl(n1,  r1,  rs1,  lname1,  d1,  c1)  : na

    label.delete(lbl2)
    lbl2  := t2  != "" and not na(n2)  ? mk_lbl(n2,  r2,  rs2,  lname2,  d2,  c2)  : na

    label.delete(lbl3)
    lbl3  := t3  != "" and not na(n3)  ? mk_lbl(n3,  r3,  rs3,  lname3,  d3,  c3)  : na

    label.delete(lbl4)
    lbl4  := t4  != "" and not na(n4)  ? mk_lbl(n4,  r4,  rs4,  lname4,  d4,  c4)  : na

    label.delete(lbl5)
    lbl5  := t5  != "" and not na(n5)  ? mk_lbl(n5,  r5,  rs5,  lname5,  d5,  c5)  : na

    label.delete(lbl6)
    lbl6  := t6  != "" and not na(n6)  ? mk_lbl(n6,  r6,  rs6,  lname6,  d6,  c6)  : na

    label.delete(lbl7)
    lbl7  := t7  != "" and not na(n7)  ? mk_lbl(n7,  r7,  rs7,  lname7,  d7,  c7)  : na

    label.delete(lbl8)
    lbl8  := t8  != "" and not na(n8)  ? mk_lbl(n8,  r8,  rs8,  lname8,  d8,  c8)  : na

    label.delete(lbl9)
    lbl9  := t9  != "" and not na(n9)  ? mk_lbl(n9,  r9,  rs9,  lname9,  d9,  c9)  : na

    label.delete(lbl10)
    lbl10 := t10 != "" and not na(n10) ? mk_lbl(n10, r10, rs10, lname10, d10, c10) : na

    label.delete(lbl11)
    lbl11 := t11 != "" and not na(n11) ? mk_lbl(n11, r11, rs11, lname11, d11, c11) : na

    label.delete(lbl12)
    lbl12 := t12 != "" and not na(n12) ? mk_lbl(n12, r12, rs12, lname12, d12, c12) : na

    label.delete(lbl13)
    lbl13 := t13 != "" and not na(n13) ? mk_lbl(n13, r13, rs13, lname13, d13, c13) : na

    label.delete(lbl14)
    lbl14 := t14 != "" and not na(n14) ? mk_lbl(n14, r14, rs14, lname14, d14, c14) : na

    label.delete(lbl15)
    lbl15 := t15 != "" and not na(n15) ? mk_lbl(n15, r15, rs15, lname15, d15, c15) : na
````
