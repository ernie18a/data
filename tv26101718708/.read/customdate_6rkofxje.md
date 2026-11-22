# Customdate

- url: https://www.tradingview.com/script/6rkOFXJe-Customdate/
- type: indicator
- pine_id: PUB;ec3f85217d6c440a97040f59621e628b
- version: 1.0

## Description

customdate ROC
ROC
ROC
ROC
ewtet
Ewtwetew
ewtwet
t42 t243t 2kt'l4t 4
dfasgm'awegj

## Source Code

````pine
//@version=6
indicator("Multi-Stock ROC Basket [Dashboard]", overlay=false, max_lines_count=500, max_labels_count=500)

// ─────────────────────────────────────────────
// INPUTS — Settings
// ─────────────────────────────────────────────
i_startDate = input.time(timestamp("2024-01-01 00:00 +0000"), "Start Date (Baseline = 0%)", group="⚙️ Settings")
i_basketName = input.string("My Basket", "Basket Name", group="⚙️ Settings")
i_showLines = input.bool(true,  "Show Chart Lines",  group="⚙️ Settings")
i_showTable = input.bool(true,  "Show Table",        group="⚙️ Settings")
i_tablePos  = input.string("Top Right", "Table Position", options=["Top Right","Top Left","Bottom Right","Bottom Left"], group="⚙️ Settings")
i_sortBy    = input.string("Custom ROC", "Sort Table By", options=["Custom ROC","1D%","1W%","1M%","3M%","6M%","1Y%","ADR%"], group="⚙️ Settings")
i_lineWidth = input.int(2, "Line Width", minval=1, maxval=4, group="⚙️ Settings")

// ─────────────────────────────────────────────
// INPUTS — Stock Basket (leave blank to skip)
// ─────────────────────────────────────────────
sym01 = input.symbol("",  "Stock 01 (blank = skip)", group="📦 Basket")
sym02 = input.symbol("",   "Stock 02 (blank = skip)", group="📦 Basket")
sym03 = input.symbol("",   "Stock 03 (blank = skip)", group="📦 Basket")
sym04 = input.symbol("",  "Stock 04 (blank = skip)", group="📦 Basket")
sym05 = input.symbol("",  "Stock 05 (blank = skip)", group="📦 Basket")
sym06 = input.symbol("",             "Stock 06 (blank = skip)", group="📦 Basket")
sym07 = input.symbol("",             "Stock 07 (blank = skip)", group="📦 Basket")
sym08 = input.symbol("",             "Stock 08 (blank = skip)", group="📦 Basket")
sym09 = input.symbol("",             "Stock 09 (blank = skip)", group="📦 Basket")
sym10 = input.symbol("",             "Stock 10 (blank = skip)", group="📦 Basket")
sym11 = input.symbol("",             "Stock 11 (blank = skip)", group="📦 Basket")
sym12 = input.symbol("",             "Stock 12 (blank = skip)", group="📦 Basket")
sym13 = input.symbol("",             "Stock 13 (blank = skip)", group="📦 Basket")
sym14 = input.symbol("",             "Stock 14 (blank = skip)", group="📦 Basket")
sym15 = input.symbol("",             "Stock 15 (blank = skip)", group="📦 Basket")
sym16 = input.symbol("",             "Stock 16 (blank = skip)", group="📦 Basket")
sym17 = input.symbol("",             "Stock 17 (blank = skip)", group="📦 Basket")
sym18 = input.symbol("",             "Stock 18 (blank = skip)", group="📦 Basket")
sym19 = input.symbol("",             "Stock 19 (blank = skip)", group="📦 Basket")
sym20 = input.symbol("",             "Stock 20 (blank = skip)", group="📦 Basket")

// ─────────────────────────────────────────────
// COLORS
// ─────────────────────────────────────────────
c01 = input.color(color.new(#FF6B6B, 0), "Color 01", group="🎨 Colors", inline="c1")
c02 = input.color(color.new(#FFD93D, 0), "Color 02", group="🎨 Colors", inline="c1")
c03 = input.color(color.new(#6BCB77, 0), "Color 03", group="🎨 Colors", inline="c2")
c04 = input.color(color.new(#4D96FF, 0), "Color 04", group="🎨 Colors", inline="c2")
c05 = input.color(color.new(#FF922B, 0), "Color 05", group="🎨 Colors", inline="c3")
c06 = input.color(color.new(#CC5DE8, 0), "Color 06", group="🎨 Colors", inline="c3")
c07 = input.color(color.new(#20C997, 0), "Color 07", group="🎨 Colors", inline="c4")
c08 = input.color(color.new(#F06595, 0), "Color 08", group="🎨 Colors", inline="c4")
c09 = input.color(color.new(#74C0FC, 0), "Color 09", group="🎨 Colors", inline="c5")
c10 = input.color(color.new(#A9E34B, 0), "Color 10", group="🎨 Colors", inline="c5")
c11 = input.color(color.new(#FFA8A8, 0), "Color 11", group="🎨 Colors", inline="c6")
c12 = input.color(color.new(#FFE066, 0), "Color 12", group="🎨 Colors", inline="c6")
c13 = input.color(color.new(#B2F2BB, 0), "Color 13", group="🎨 Colors", inline="c7")
c14 = input.color(color.new(#A5D8FF, 0), "Color 14", group="🎨 Colors", inline="c7")
c15 = input.color(color.new(#FFEC99, 0), "Color 15", group="🎨 Colors", inline="c8")
c16 = input.color(color.new(#E599F7, 0), "Color 16", group="🎨 Colors", inline="c8")
c17 = input.color(color.new(#96F2D7, 0), "Color 17", group="🎨 Colors", inline="c9")
c18 = input.color(color.new(#FFA94D, 0), "Color 18", group="🎨 Colors", inline="c9")
c19 = input.color(color.new(#DA77F2, 0), "Color 19", group="🎨 Colors", inline="c10")
c20 = input.color(color.new(#63E6BE, 0), "Color 20", group="🎨 Colors", inline="c10")

// ─────────────────────────────────────────────
// BAR LOOKBACKS
// ─────────────────────────────────────────────
barsPerDay  = timeframe.isintraday ? (60 / timeframe.multiplier) * 6.5 : 1
barsPerWeek = barsPerDay * 5
barsPerMon  = barsPerDay * 21
barsPerQtr  = barsPerDay * 63
barsPerHalf = barsPerDay * 126
barsPerYear = barsPerDay * 252

lb1d = math.round(barsPerDay)
lb1w = math.round(barsPerWeek)
lb1m = math.round(barsPerMon)
lb3m = math.round(barsPerQtr)
lb6m = math.round(barsPerHalf)
lb1y = math.round(barsPerYear)

// ─────────────────────────────────────────────
// SECURITY CALLS — TWO per stock only
//   call 1: current close
//   call 2: tuple of (high, low, c[1d], c[1w], c[1m], c[3m], c[6m], c[1y])
// Total: 40 unique request.security calls = within free plan limit
// ─────────────────────────────────────────────

// Helper that returns a tuple of historical/derived values for ONE security request
// All calculations happen on the requested symbol's series, returning floats only.
f_pkg(sym) =>
    if str.length(sym) == 0
        [float(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na), float(na)]
    else
        // ADR calculated on the source symbol so the daily H/L are correct
        adrSum = 0.0
        for k = 0 to 19
            adrSum += (high[k] - low[k]) / close[k] * 100
        adr = adrSum / 20
        [close, close[lb1d], close[lb1w], close[lb1m], close[lb3m], close[lb6m], close[lb1y], adr, close]

// Each stock = 1 unique request.security call returning tuple
[cl01, p1d01, p1w01, p1m01, p3m01, p6m01, p1y01, adr01, base01s] = request.security(sym01, timeframe.period, f_pkg(sym01), lookahead=barmerge.lookahead_off)
[cl02, p1d02, p1w02, p1m02, p3m02, p6m02, p1y02, adr02, base02s] = request.security(sym02, timeframe.period, f_pkg(sym02), lookahead=barmerge.lookahead_off)
[cl03, p1d03, p1w03, p1m03, p3m03, p6m03, p1y03, adr03, base03s] = request.security(sym03, timeframe.period, f_pkg(sym03), lookahead=barmerge.lookahead_off)
[cl04, p1d04, p1w04, p1m04, p3m04, p6m04, p1y04, adr04, base04s] = request.security(sym04, timeframe.period, f_pkg(sym04), lookahead=barmerge.lookahead_off)
[cl05, p1d05, p1w05, p1m05, p3m05, p6m05, p1y05, adr05, base05s] = request.security(sym05, timeframe.period, f_pkg(sym05), lookahead=barmerge.lookahead_off)
[cl06, p1d06, p1w06, p1m06, p3m06, p6m06, p1y06, adr06, base06s] = request.security(sym06, timeframe.period, f_pkg(sym06), lookahead=barmerge.lookahead_off)
[cl07, p1d07, p1w07, p1m07, p3m07, p6m07, p1y07, adr07, base07s] = request.security(sym07, timeframe.period, f_pkg(sym07), lookahead=barmerge.lookahead_off)
[cl08, p1d08, p1w08, p1m08, p3m08, p6m08, p1y08, adr08, base08s] = request.security(sym08, timeframe.period, f_pkg(sym08), lookahead=barmerge.lookahead_off)
[cl09, p1d09, p1w09, p1m09, p3m09, p6m09, p1y09, adr09, base09s] = request.security(sym09, timeframe.period, f_pkg(sym09), lookahead=barmerge.lookahead_off)
[cl10, p1d10, p1w10, p1m10, p3m10, p6m10, p1y10, adr10, base10s] = request.security(sym10, timeframe.period, f_pkg(sym10), lookahead=barmerge.lookahead_off)
[cl11, p1d11, p1w11, p1m11, p3m11, p6m11, p1y11, adr11, base11s] = request.security(sym11, timeframe.period, f_pkg(sym11), lookahead=barmerge.lookahead_off)
[cl12, p1d12, p1w12, p1m12, p3m12, p6m12, p1y12, adr12, base12s] = request.security(sym12, timeframe.period, f_pkg(sym12), lookahead=barmerge.lookahead_off)
[cl13, p1d13, p1w13, p1m13, p3m13, p6m13, p1y13, adr13, base13s] = request.security(sym13, timeframe.period, f_pkg(sym13), lookahead=barmerge.lookahead_off)
[cl14, p1d14, p1w14, p1m14, p3m14, p6m14, p1y14, adr14, base14s] = request.security(sym14, timeframe.period, f_pkg(sym14), lookahead=barmerge.lookahead_off)
[cl15, p1d15, p1w15, p1m15, p3m15, p6m15, p1y15, adr15, base15s] = request.security(sym15, timeframe.period, f_pkg(sym15), lookahead=barmerge.lookahead_off)
[cl16, p1d16, p1w16, p1m16, p3m16, p6m16, p1y16, adr16, base16s] = request.security(sym16, timeframe.period, f_pkg(sym16), lookahead=barmerge.lookahead_off)
[cl17, p1d17, p1w17, p1m17, p3m17, p6m17, p1y17, adr17, base17s] = request.security(sym17, timeframe.period, f_pkg(sym17), lookahead=barmerge.lookahead_off)
[cl18, p1d18, p1w18, p1m18, p3m18, p6m18, p1y18, adr18, base18s] = request.security(sym18, timeframe.period, f_pkg(sym18), lookahead=barmerge.lookahead_off)
[cl19, p1d19, p1w19, p1m19, p3m19, p6m19, p1y19, adr19, base19s] = request.security(sym19, timeframe.period, f_pkg(sym19), lookahead=barmerge.lookahead_off)
[cl20, p1d20, p1w20, p1m20, p3m20, p6m20, p1y20, adr20, base20s] = request.security(sym20, timeframe.period, f_pkg(sym20), lookahead=barmerge.lookahead_off)

// ─────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────
f_rocFromPrev(c, prev) =>
    not na(prev) and prev != 0 and not na(c) ? (c - prev) / prev * 100 : na

f_customRoc(c, base) =>
    not na(base) and base != 0 and not na(c) ? (c - base) / base * 100 : na

f_label(sym) =>
    parts = str.split(sym, ":")
    array.size(parts) > 1 ? array.get(parts, 1) : sym

f_pctColor(v) =>
    v > 0 ? color.new(#3FB950, 0) : v < 0 ? color.new(#F85149, 0) : color.new(#8B949E, 0)

f_pctStr(v) =>
    na(v) ? "—" : str.tostring(v, "+#.##;-#.##") + "%"

f_swapStr(arr, i, j) =>
    tmp = array.get(arr, i)
    array.set(arr, i, array.get(arr, j))
    array.set(arr, j, tmp)

f_swapFloat(arr, i, j) =>
    tmp = array.get(arr, i)
    array.set(arr, i, array.get(arr, j))
    array.set(arr, j, tmp)

f_swapColor(arr, i, j) =>
    tmp = array.get(arr, i)
    array.set(arr, i, array.get(arr, j))
    array.set(arr, j, tmp)

f_swapBool(arr, i, j) =>
    tmp = array.get(arr, i)
    array.set(arr, i, array.get(arr, j))
    array.set(arr, j, tmp)

// ─────────────────────────────────────────────
// LATCH BASE CLOSE ON START DATE
// ─────────────────────────────────────────────
var float baseClose01 = na
var float baseClose02 = na
var float baseClose03 = na
var float baseClose04 = na
var float baseClose05 = na
var float baseClose06 = na
var float baseClose07 = na
var float baseClose08 = na
var float baseClose09 = na
var float baseClose10 = na
var float baseClose11 = na
var float baseClose12 = na
var float baseClose13 = na
var float baseClose14 = na
var float baseClose15 = na
var float baseClose16 = na
var float baseClose17 = na
var float baseClose18 = na
var float baseClose19 = na
var float baseClose20 = na

bool atStart = time >= i_startDate and time[1] < i_startDate

if atStart
    baseClose01 := cl01
    baseClose02 := cl02
    baseClose03 := cl03
    baseClose04 := cl04
    baseClose05 := cl05
    baseClose06 := cl06
    baseClose07 := cl07
    baseClose08 := cl08
    baseClose09 := cl09
    baseClose10 := cl10
    baseClose11 := cl11
    baseClose12 := cl12
    baseClose13 := cl13
    baseClose14 := cl14
    baseClose15 := cl15
    baseClose16 := cl16
    baseClose17 := cl17
    baseClose18 := cl18
    baseClose19 := cl19
    baseClose20 := cl20

// ─────────────────────────────────────────────
// CUSTOM ROC FROM BASELINE
// ─────────────────────────────────────────────
roc01 = f_customRoc(cl01, baseClose01)
roc02 = f_customRoc(cl02, baseClose02)
roc03 = f_customRoc(cl03, baseClose03)
roc04 = f_customRoc(cl04, baseClose04)
roc05 = f_customRoc(cl05, baseClose05)
roc06 = f_customRoc(cl06, baseClose06)
roc07 = f_customRoc(cl07, baseClose07)
roc08 = f_customRoc(cl08, baseClose08)
roc09 = f_customRoc(cl09, baseClose09)
roc10 = f_customRoc(cl10, baseClose10)
roc11 = f_customRoc(cl11, baseClose11)
roc12 = f_customRoc(cl12, baseClose12)
roc13 = f_customRoc(cl13, baseClose13)
roc14 = f_customRoc(cl14, baseClose14)
roc15 = f_customRoc(cl15, baseClose15)
roc16 = f_customRoc(cl16, baseClose16)
roc17 = f_customRoc(cl17, baseClose17)
roc18 = f_customRoc(cl18, baseClose18)
roc19 = f_customRoc(cl19, baseClose19)
roc20 = f_customRoc(cl20, baseClose20)

// ─────────────────────────────────────────────
// PLOT LINES
// ─────────────────────────────────────────────
active01 = i_showLines and str.length(sym01) > 0 and not na(roc01)
active02 = i_showLines and str.length(sym02) > 0 and not na(roc02)
active03 = i_showLines and str.length(sym03) > 0 and not na(roc03)
active04 = i_showLines and str.length(sym04) > 0 and not na(roc04)
active05 = i_showLines and str.length(sym05) > 0 and not na(roc05)
active06 = i_showLines and str.length(sym06) > 0 and not na(roc06)
active07 = i_showLines and str.length(sym07) > 0 and not na(roc07)
active08 = i_showLines and str.length(sym08) > 0 and not na(roc08)
active09 = i_showLines and str.length(sym09) > 0 and not na(roc09)
active10 = i_showLines and str.length(sym10) > 0 and not na(roc10)
active11 = i_showLines and str.length(sym11) > 0 and not na(roc11)
active12 = i_showLines and str.length(sym12) > 0 and not na(roc12)
active13 = i_showLines and str.length(sym13) > 0 and not na(roc13)
active14 = i_showLines and str.length(sym14) > 0 and not na(roc14)
active15 = i_showLines and str.length(sym15) > 0 and not na(roc15)
active16 = i_showLines and str.length(sym16) > 0 and not na(roc16)
active17 = i_showLines and str.length(sym17) > 0 and not na(roc17)
active18 = i_showLines and str.length(sym18) > 0 and not na(roc18)
active19 = i_showLines and str.length(sym19) > 0 and not na(roc19)
active20 = i_showLines and str.length(sym20) > 0 and not na(roc20)

plot(active01 ? roc01 : na, "Stock 01", c01, i_lineWidth)
plot(active02 ? roc02 : na, "Stock 02", c02, i_lineWidth)
plot(active03 ? roc03 : na, "Stock 03", c03, i_lineWidth)
plot(active04 ? roc04 : na, "Stock 04", c04, i_lineWidth)
plot(active05 ? roc05 : na, "Stock 05", c05, i_lineWidth)
plot(active06 ? roc06 : na, "Stock 06", c06, i_lineWidth)
plot(active07 ? roc07 : na, "Stock 07", c07, i_lineWidth)
plot(active08 ? roc08 : na, "Stock 08", c08, i_lineWidth)
plot(active09 ? roc09 : na, "Stock 09", c09, i_lineWidth)
plot(active10 ? roc10 : na, "Stock 10", c10, i_lineWidth)
plot(active11 ? roc11 : na, "Stock 11", c11, i_lineWidth)
plot(active12 ? roc12 : na, "Stock 12", c12, i_lineWidth)
plot(active13 ? roc13 : na, "Stock 13", c13, i_lineWidth)
plot(active14 ? roc14 : na, "Stock 14", c14, i_lineWidth)
plot(active15 ? roc15 : na, "Stock 15", c15, i_lineWidth)
plot(active16 ? roc16 : na, "Stock 16", c16, i_lineWidth)
plot(active17 ? roc17 : na, "Stock 17", c17, i_lineWidth)
plot(active18 ? roc18 : na, "Stock 18", c18, i_lineWidth)
plot(active19 ? roc19 : na, "Stock 19", c19, i_lineWidth)
plot(active20 ? roc20 : na, "Stock 20", c20, i_lineWidth)

hline(0, "Zero", color=color.new(color.white, 60), linestyle=hline.style_dashed)

// ─────────────────────────────────────────────
// LINE-END LABELS (memory-safe — recreated only on last bar)
// ─────────────────────────────────────────────
var label lbl01 = na
var label lbl02 = na
var label lbl03 = na
var label lbl04 = na
var label lbl05 = na
var label lbl06 = na
var label lbl07 = na
var label lbl08 = na
var label lbl09 = na
var label lbl10 = na
var label lbl11 = na
var label lbl12 = na
var label lbl13 = na
var label lbl14 = na
var label lbl15 = na
var label lbl16 = na
var label lbl17 = na
var label lbl18 = na
var label lbl19 = na
var label lbl20 = na

f_drawLabel(lbl, sym, roc, active, col) =>
    label out = lbl
    if not na(lbl)
        label.delete(lbl)
        out := na
    if active and not na(roc)
        out := label.new(bar_index + 3, roc, text=f_label(sym),
             color=color.new(col, 80),
             textcolor=col,
             style=label.style_label_left,
             size=size.small,
             xloc=xloc.bar_index)
    out

if barstate.islast
    lbl01 := f_drawLabel(lbl01, sym01, roc01, active01, c01)
    lbl02 := f_drawLabel(lbl02, sym02, roc02, active02, c02)
    lbl03 := f_drawLabel(lbl03, sym03, roc03, active03, c03)
    lbl04 := f_drawLabel(lbl04, sym04, roc04, active04, c04)
    lbl05 := f_drawLabel(lbl05, sym05, roc05, active05, c05)
    lbl06 := f_drawLabel(lbl06, sym06, roc06, active06, c06)
    lbl07 := f_drawLabel(lbl07, sym07, roc07, active07, c07)
    lbl08 := f_drawLabel(lbl08, sym08, roc08, active08, c08)
    lbl09 := f_drawLabel(lbl09, sym09, roc09, active09, c09)
    lbl10 := f_drawLabel(lbl10, sym10, roc10, active10, c10)
    lbl11 := f_drawLabel(lbl11, sym11, roc11, active11, c11)
    lbl12 := f_drawLabel(lbl12, sym12, roc12, active12, c12)
    lbl13 := f_drawLabel(lbl13, sym13, roc13, active13, c13)
    lbl14 := f_drawLabel(lbl14, sym14, roc14, active14, c14)
    lbl15 := f_drawLabel(lbl15, sym15, roc15, active15, c15)
    lbl16 := f_drawLabel(lbl16, sym16, roc16, active16, c16)
    lbl17 := f_drawLabel(lbl17, sym17, roc17, active17, c17)
    lbl18 := f_drawLabel(lbl18, sym18, roc18, active18, c18)
    lbl19 := f_drawLabel(lbl19, sym19, roc19, active19, c19)
    lbl20 := f_drawLabel(lbl20, sym20, roc20, active20, c20)

// ─────────────────────────────────────────────
// TABLE (last bar only)
// ─────────────────────────────────────────────
if barstate.islast and i_showTable

    syms    = array.new_string(20)
    cols    = array.new_color(20)
    prices  = array.new_float(20)
    cRocs   = array.new_float(20)
    r1d     = array.new_float(20)
    r1w     = array.new_float(20)
    r1m     = array.new_float(20)
    r3m     = array.new_float(20)
    r6m     = array.new_float(20)
    r1y     = array.new_float(20)
    adrs    = array.new_float(20)
    enabled = array.new_bool(20)

    // Symbols
    array.set(syms, 0,  f_label(sym01))
    array.set(syms, 1,  f_label(sym02))
    array.set(syms, 2,  f_label(sym03))
    array.set(syms, 3,  f_label(sym04))
    array.set(syms, 4,  f_label(sym05))
    array.set(syms, 5,  f_label(sym06))
    array.set(syms, 6,  f_label(sym07))
    array.set(syms, 7,  f_label(sym08))
    array.set(syms, 8,  f_label(sym09))
    array.set(syms, 9,  f_label(sym10))
    array.set(syms, 10, f_label(sym11))
    array.set(syms, 11, f_label(sym12))
    array.set(syms, 12, f_label(sym13))
    array.set(syms, 13, f_label(sym14))
    array.set(syms, 14, f_label(sym15))
    array.set(syms, 15, f_label(sym16))
    array.set(syms, 16, f_label(sym17))
    array.set(syms, 17, f_label(sym18))
    array.set(syms, 18, f_label(sym19))
    array.set(syms, 19, f_label(sym20))

    // Colors
    array.set(cols, 0,  c01)
    array.set(cols, 1,  c02)
    array.set(cols, 2,  c03)
    array.set(cols, 3,  c04)
    array.set(cols, 4,  c05)
    array.set(cols, 5,  c06)
    array.set(cols, 6,  c07)
    array.set(cols, 7,  c08)
    array.set(cols, 8,  c09)
    array.set(cols, 9,  c10)
    array.set(cols, 10, c11)
    array.set(cols, 11, c12)
    array.set(cols, 12, c13)
    array.set(cols, 13, c14)
    array.set(cols, 14, c15)
    array.set(cols, 15, c16)
    array.set(cols, 16, c17)
    array.set(cols, 17, c18)
    array.set(cols, 18, c19)
    array.set(cols, 19, c20)

    // Prices
    array.set(prices, 0,  nz(cl01))
    array.set(prices, 1,  nz(cl02))
    array.set(prices, 2,  nz(cl03))
    array.set(prices, 3,  nz(cl04))
    array.set(prices, 4,  nz(cl05))
    array.set(prices, 5,  nz(cl06))
    array.set(prices, 6,  nz(cl07))
    array.set(prices, 7,  nz(cl08))
    array.set(prices, 8,  nz(cl09))
    array.set(prices, 9,  nz(cl10))
    array.set(prices, 10, nz(cl11))
    array.set(prices, 11, nz(cl12))
    array.set(prices, 12, nz(cl13))
    array.set(prices, 13, nz(cl14))
    array.set(prices, 14, nz(cl15))
    array.set(prices, 15, nz(cl16))
    array.set(prices, 16, nz(cl17))
    array.set(prices, 17, nz(cl18))
    array.set(prices, 18, nz(cl19))
    array.set(prices, 19, nz(cl20))

    // Custom ROC
    array.set(cRocs, 0,  nz(roc01))
    array.set(cRocs, 1,  nz(roc02))
    array.set(cRocs, 2,  nz(roc03))
    array.set(cRocs, 3,  nz(roc04))
    array.set(cRocs, 4,  nz(roc05))
    array.set(cRocs, 5,  nz(roc06))
    array.set(cRocs, 6,  nz(roc07))
    array.set(cRocs, 7,  nz(roc08))
    array.set(cRocs, 8,  nz(roc09))
    array.set(cRocs, 9,  nz(roc10))
    array.set(cRocs, 10, nz(roc11))
    array.set(cRocs, 11, nz(roc12))
    array.set(cRocs, 12, nz(roc13))
    array.set(cRocs, 13, nz(roc14))
    array.set(cRocs, 14, nz(roc15))
    array.set(cRocs, 15, nz(roc16))
    array.set(cRocs, 16, nz(roc17))
    array.set(cRocs, 17, nz(roc18))
    array.set(cRocs, 18, nz(roc19))
    array.set(cRocs, 19, nz(roc20))

    // Enabled
    array.set(enabled, 0,  str.length(sym01) > 0)
    array.set(enabled, 1,  str.length(sym02) > 0)
    array.set(enabled, 2,  str.length(sym03) > 0)
    array.set(enabled, 3,  str.length(sym04) > 0)
    array.set(enabled, 4,  str.length(sym05) > 0)
    array.set(enabled, 5,  str.length(sym06) > 0)
    array.set(enabled, 6,  str.length(sym07) > 0)
    array.set(enabled, 7,  str.length(sym08) > 0)
    array.set(enabled, 8,  str.length(sym09) > 0)
    array.set(enabled, 9,  str.length(sym10) > 0)
    array.set(enabled, 10, str.length(sym11) > 0)
    array.set(enabled, 11, str.length(sym12) > 0)
    array.set(enabled, 12, str.length(sym13) > 0)
    array.set(enabled, 13, str.length(sym14) > 0)
    array.set(enabled, 14, str.length(sym15) > 0)
    array.set(enabled, 15, str.length(sym16) > 0)
    array.set(enabled, 16, str.length(sym17) > 0)
    array.set(enabled, 17, str.length(sym18) > 0)
    array.set(enabled, 18, str.length(sym19) > 0)
    array.set(enabled, 19, str.length(sym20) > 0)

    // 1D ROC
    array.set(r1d, 0,  nz(f_rocFromPrev(cl01, p1d01)))
    array.set(r1d, 1,  nz(f_rocFromPrev(cl02, p1d02)))
    array.set(r1d, 2,  nz(f_rocFromPrev(cl03, p1d03)))
    array.set(r1d, 3,  nz(f_rocFromPrev(cl04, p1d04)))
    array.set(r1d, 4,  nz(f_rocFromPrev(cl05, p1d05)))
    array.set(r1d, 5,  nz(f_rocFromPrev(cl06, p1d06)))
    array.set(r1d, 6,  nz(f_rocFromPrev(cl07, p1d07)))
    array.set(r1d, 7,  nz(f_rocFromPrev(cl08, p1d08)))
    array.set(r1d, 8,  nz(f_rocFromPrev(cl09, p1d09)))
    array.set(r1d, 9,  nz(f_rocFromPrev(cl10, p1d10)))
    array.set(r1d, 10, nz(f_rocFromPrev(cl11, p1d11)))
    array.set(r1d, 11, nz(f_rocFromPrev(cl12, p1d12)))
    array.set(r1d, 12, nz(f_rocFromPrev(cl13, p1d13)))
    array.set(r1d, 13, nz(f_rocFromPrev(cl14, p1d14)))
    array.set(r1d, 14, nz(f_rocFromPrev(cl15, p1d15)))
    array.set(r1d, 15, nz(f_rocFromPrev(cl16, p1d16)))
    array.set(r1d, 16, nz(f_rocFromPrev(cl17, p1d17)))
    array.set(r1d, 17, nz(f_rocFromPrev(cl18, p1d18)))
    array.set(r1d, 18, nz(f_rocFromPrev(cl19, p1d19)))
    array.set(r1d, 19, nz(f_rocFromPrev(cl20, p1d20)))

    // 1W ROC
    array.set(r1w, 0,  nz(f_rocFromPrev(cl01, p1w01)))
    array.set(r1w, 1,  nz(f_rocFromPrev(cl02, p1w02)))
    array.set(r1w, 2,  nz(f_rocFromPrev(cl03, p1w03)))
    array.set(r1w, 3,  nz(f_rocFromPrev(cl04, p1w04)))
    array.set(r1w, 4,  nz(f_rocFromPrev(cl05, p1w05)))
    array.set(r1w, 5,  nz(f_rocFromPrev(cl06, p1w06)))
    array.set(r1w, 6,  nz(f_rocFromPrev(cl07, p1w07)))
    array.set(r1w, 7,  nz(f_rocFromPrev(cl08, p1w08)))
    array.set(r1w, 8,  nz(f_rocFromPrev(cl09, p1w09)))
    array.set(r1w, 9,  nz(f_rocFromPrev(cl10, p1w10)))
    array.set(r1w, 10, nz(f_rocFromPrev(cl11, p1w11)))
    array.set(r1w, 11, nz(f_rocFromPrev(cl12, p1w12)))
    array.set(r1w, 12, nz(f_rocFromPrev(cl13, p1w13)))
    array.set(r1w, 13, nz(f_rocFromPrev(cl14, p1w14)))
    array.set(r1w, 14, nz(f_rocFromPrev(cl15, p1w15)))
    array.set(r1w, 15, nz(f_rocFromPrev(cl16, p1w16)))
    array.set(r1w, 16, nz(f_rocFromPrev(cl17, p1w17)))
    array.set(r1w, 17, nz(f_rocFromPrev(cl18, p1w18)))
    array.set(r1w, 18, nz(f_rocFromPrev(cl19, p1w19)))
    array.set(r1w, 19, nz(f_rocFromPrev(cl20, p1w20)))

    // 1M ROC
    array.set(r1m, 0,  nz(f_rocFromPrev(cl01, p1m01)))
    array.set(r1m, 1,  nz(f_rocFromPrev(cl02, p1m02)))
    array.set(r1m, 2,  nz(f_rocFromPrev(cl03, p1m03)))
    array.set(r1m, 3,  nz(f_rocFromPrev(cl04, p1m04)))
    array.set(r1m, 4,  nz(f_rocFromPrev(cl05, p1m05)))
    array.set(r1m, 5,  nz(f_rocFromPrev(cl06, p1m06)))
    array.set(r1m, 6,  nz(f_rocFromPrev(cl07, p1m07)))
    array.set(r1m, 7,  nz(f_rocFromPrev(cl08, p1m08)))
    array.set(r1m, 8,  nz(f_rocFromPrev(cl09, p1m09)))
    array.set(r1m, 9,  nz(f_rocFromPrev(cl10, p1m10)))
    array.set(r1m, 10, nz(f_rocFromPrev(cl11, p1m11)))
    array.set(r1m, 11, nz(f_rocFromPrev(cl12, p1m12)))
    array.set(r1m, 12, nz(f_rocFromPrev(cl13, p1m13)))
    array.set(r1m, 13, nz(f_rocFromPrev(cl14, p1m14)))
    array.set(r1m, 14, nz(f_rocFromPrev(cl15, p1m15)))
    array.set(r1m, 15, nz(f_rocFromPrev(cl16, p1m16)))
    array.set(r1m, 16, nz(f_rocFromPrev(cl17, p1m17)))
    array.set(r1m, 17, nz(f_rocFromPrev(cl18, p1m18)))
    array.set(r1m, 18, nz(f_rocFromPrev(cl19, p1m19)))
    array.set(r1m, 19, nz(f_rocFromPrev(cl20, p1m20)))

    // 3M ROC
    array.set(r3m, 0,  nz(f_rocFromPrev(cl01, p3m01)))
    array.set(r3m, 1,  nz(f_rocFromPrev(cl02, p3m02)))
    array.set(r3m, 2,  nz(f_rocFromPrev(cl03, p3m03)))
    array.set(r3m, 3,  nz(f_rocFromPrev(cl04, p3m04)))
    array.set(r3m, 4,  nz(f_rocFromPrev(cl05, p3m05)))
    array.set(r3m, 5,  nz(f_rocFromPrev(cl06, p3m06)))
    array.set(r3m, 6,  nz(f_rocFromPrev(cl07, p3m07)))
    array.set(r3m, 7,  nz(f_rocFromPrev(cl08, p3m08)))
    array.set(r3m, 8,  nz(f_rocFromPrev(cl09, p3m09)))
    array.set(r3m, 9,  nz(f_rocFromPrev(cl10, p3m10)))
    array.set(r3m, 10, nz(f_rocFromPrev(cl11, p3m11)))
    array.set(r3m, 11, nz(f_rocFromPrev(cl12, p3m12)))
    array.set(r3m, 12, nz(f_rocFromPrev(cl13, p3m13)))
    array.set(r3m, 13, nz(f_rocFromPrev(cl14, p3m14)))
    array.set(r3m, 14, nz(f_rocFromPrev(cl15, p3m15)))
    array.set(r3m, 15, nz(f_rocFromPrev(cl16, p3m16)))
    array.set(r3m, 16, nz(f_rocFromPrev(cl17, p3m17)))
    array.set(r3m, 17, nz(f_rocFromPrev(cl18, p3m18)))
    array.set(r3m, 18, nz(f_rocFromPrev(cl19, p3m19)))
    array.set(r3m, 19, nz(f_rocFromPrev(cl20, p3m20)))

    // 6M ROC
    array.set(r6m, 0,  nz(f_rocFromPrev(cl01, p6m01)))
    array.set(r6m, 1,  nz(f_rocFromPrev(cl02, p6m02)))
    array.set(r6m, 2,  nz(f_rocFromPrev(cl03, p6m03)))
    array.set(r6m, 3,  nz(f_rocFromPrev(cl04, p6m04)))
    array.set(r6m, 4,  nz(f_rocFromPrev(cl05, p6m05)))
    array.set(r6m, 5,  nz(f_rocFromPrev(cl06, p6m06)))
    array.set(r6m, 6,  nz(f_rocFromPrev(cl07, p6m07)))
    array.set(r6m, 7,  nz(f_rocFromPrev(cl08, p6m08)))
    array.set(r6m, 8,  nz(f_rocFromPrev(cl09, p6m09)))
    array.set(r6m, 9,  nz(f_rocFromPrev(cl10, p6m10)))
    array.set(r6m, 10, nz(f_rocFromPrev(cl11, p6m11)))
    array.set(r6m, 11, nz(f_rocFromPrev(cl12, p6m12)))
    array.set(r6m, 12, nz(f_rocFromPrev(cl13, p6m13)))
    array.set(r6m, 13, nz(f_rocFromPrev(cl14, p6m14)))
    array.set(r6m, 14, nz(f_rocFromPrev(cl15, p6m15)))
    array.set(r6m, 15, nz(f_rocFromPrev(cl16, p6m16)))
    array.set(r6m, 16, nz(f_rocFromPrev(cl17, p6m17)))
    array.set(r6m, 17, nz(f_rocFromPrev(cl18, p6m18)))
    array.set(r6m, 18, nz(f_rocFromPrev(cl19, p6m19)))
    array.set(r6m, 19, nz(f_rocFromPrev(cl20, p6m20)))

    // 1Y ROC
    array.set(r1y, 0,  nz(f_rocFromPrev(cl01, p1y01)))
    array.set(r1y, 1,  nz(f_rocFromPrev(cl02, p1y02)))
    array.set(r1y, 2,  nz(f_rocFromPrev(cl03, p1y03)))
    array.set(r1y, 3,  nz(f_rocFromPrev(cl04, p1y04)))
    array.set(r1y, 4,  nz(f_rocFromPrev(cl05, p1y05)))
    array.set(r1y, 5,  nz(f_rocFromPrev(cl06, p1y06)))
    array.set(r1y, 6,  nz(f_rocFromPrev(cl07, p1y07)))
    array.set(r1y, 7,  nz(f_rocFromPrev(cl08, p1y08)))
    array.set(r1y, 8,  nz(f_rocFromPrev(cl09, p1y09)))
    array.set(r1y, 9,  nz(f_rocFromPrev(cl10, p1y10)))
    array.set(r1y, 10, nz(f_rocFromPrev(cl11, p1y11)))
    array.set(r1y, 11, nz(f_rocFromPrev(cl12, p1y12)))
    array.set(r1y, 12, nz(f_rocFromPrev(cl13, p1y13)))
    array.set(r1y, 13, nz(f_rocFromPrev(cl14, p1y14)))
    array.set(r1y, 14, nz(f_rocFromPrev(cl15, p1y15)))
    array.set(r1y, 15, nz(f_rocFromPrev(cl16, p1y16)))
    array.set(r1y, 16, nz(f_rocFromPrev(cl17, p1y17)))
    array.set(r1y, 17, nz(f_rocFromPrev(cl18, p1y18)))
    array.set(r1y, 18, nz(f_rocFromPrev(cl19, p1y19)))
    array.set(r1y, 19, nz(f_rocFromPrev(cl20, p1y20)))

    // ADR
    array.set(adrs, 0,  nz(adr01))
    array.set(adrs, 1,  nz(adr02))
    array.set(adrs, 2,  nz(adr03))
    array.set(adrs, 3,  nz(adr04))
    array.set(adrs, 4,  nz(adr05))
    array.set(adrs, 5,  nz(adr06))
    array.set(adrs, 6,  nz(adr07))
    array.set(adrs, 7,  nz(adr08))
    array.set(adrs, 8,  nz(adr09))
    array.set(adrs, 9,  nz(adr10))
    array.set(adrs, 10, nz(adr11))
    array.set(adrs, 11, nz(adr12))
    array.set(adrs, 12, nz(adr13))
    array.set(adrs, 13, nz(adr14))
    array.set(adrs, 14, nz(adr15))
    array.set(adrs, 15, nz(adr16))
    array.set(adrs, 16, nz(adr17))
    array.set(adrs, 17, nz(adr18))
    array.set(adrs, 18, nz(adr19))
    array.set(adrs, 19, nz(adr20))

    // ── Sort ──
    sortArr = switch i_sortBy
        "1D%"  => r1d
        "1W%"  => r1w
        "1M%"  => r1m
        "3M%"  => r3m
        "6M%"  => r6m
        "1Y%"  => r1y
        "ADR%" => adrs
        =>        cRocs

    for i = 0 to 18
        for j = 0 to 18 - i
            enJ  = array.get(enabled, j)
            enJ1 = array.get(enabled, j + 1)
            shouldSwap = (not enJ and enJ1) or (enJ and enJ1 and array.get(sortArr, j) < array.get(sortArr, j + 1))
            if shouldSwap
                f_swapStr(syms,     j, j + 1)
                f_swapColor(cols,   j, j + 1)
                f_swapFloat(prices, j, j + 1)
                f_swapFloat(cRocs,  j, j + 1)
                f_swapFloat(r1d,    j, j + 1)
                f_swapFloat(r1w,    j, j + 1)
                f_swapFloat(r1m,    j, j + 1)
                f_swapFloat(r3m,    j, j + 1)
                f_swapFloat(r6m,    j, j + 1)
                f_swapFloat(r1y,    j, j + 1)
                f_swapFloat(adrs,   j, j + 1)
                f_swapBool(enabled, j, j + 1)

    activeCount = 0
    for i = 0 to 19
        if array.get(enabled, i)
            activeCount += 1

    tPos = switch i_tablePos
        "Top Left"     => position.top_left
        "Bottom Right" => position.bottom_right
        "Bottom Left"  => position.bottom_left
        =>                position.top_right

    rowsNeeded = math.max(activeCount + 2, 3)   // +1 header, +1 AVG row

    tbl = table.new(tPos, columns=10, rows=rowsNeeded,
         bgcolor=color.new(#0D1117, 5),
         border_color=color.new(#30363D, 0),
         border_width=1,
         frame_color=color.new(#58A6FF, 0),
         frame_width=1)

    hBg  = color.new(#161B22, 0)
    hTxt = color.new(#8B949E, 0)

    table.cell(tbl, 0, 0, "#",       text_color=hTxt,                  bgcolor=hBg, text_size=size.small, text_halign=text.align_center)
    table.cell(tbl, 1, 0, "Symbol",  text_color=hTxt,                  bgcolor=hBg, text_size=size.small)
    table.cell(tbl, 2, 0, "Price",   text_color=hTxt,                  bgcolor=hBg, text_size=size.small, text_halign=text.align_right)
    table.cell(tbl, 3, 0, "Custom%", text_color=color.new(#FFD700, 0), bgcolor=hBg, text_size=size.small, text_halign=text.align_right)
    table.cell(tbl, 4, 0, "1D%",     text_color=hTxt,                  bgcolor=hBg, text_size=size.small, text_halign=text.align_right)
    table.cell(tbl, 5, 0, "1W%",     text_color=hTxt,                  bgcolor=hBg, text_size=size.small, text_halign=text.align_right)
    table.cell(tbl, 6, 0, "1M%",     text_color=hTxt,                  bgcolor=hBg, text_size=size.small, text_halign=text.align_right)
    table.cell(tbl, 7, 0, "3M%",     text_color=hTxt,                  bgcolor=hBg, text_size=size.small, text_halign=text.align_right)
    table.cell(tbl, 8, 0, "1Y%",     text_color=hTxt,                  bgcolor=hBg, text_size=size.small, text_halign=text.align_right)
    table.cell(tbl, 9, 0, "ADR%",    text_color=hTxt,                  bgcolor=hBg, text_size=size.small, text_halign=text.align_right)

    rBg  = color.new(#0D1117, 0)
    rBgA = color.new(#161B22, 0)
    row  = 0

    // Equal-weight sum accumulators for AVG row
    sumCustom = 0.0
    sum1d     = 0.0
    sum1w     = 0.0
    sum1m     = 0.0
    sum3m     = 0.0
    sum1y     = 0.0
    sumAdr    = 0.0

    for i = 0 to 19
        if array.get(enabled, i)
            row += 1
            bg  = row % 2 == 1 ? rBg : rBgA
            sym = array.get(syms,   i)
            col = array.get(cols,   i)
            px  = array.get(prices, i)
            cr  = array.get(cRocs,  i)
            d1  = array.get(r1d,    i)
            w1  = array.get(r1w,    i)
            m1  = array.get(r1m,    i)
            m3  = array.get(r3m,    i)
            y1  = array.get(r1y,    i)
            adr = array.get(adrs,   i)

            // accumulate for AVG
            sumCustom += cr
            sum1d     += d1
            sum1w     += w1
            sum1m     += m1
            sum3m     += m3
            sum1y     += y1
            sumAdr    += adr

            table.cell(tbl, 0, row, str.tostring(row),                text_color=color.new(#8B949E, 0), bgcolor=bg, text_size=size.small, text_halign=text.align_center)
            table.cell(tbl, 1, row, sym,                              text_color=col,                   bgcolor=bg, text_size=size.small)
            table.cell(tbl, 2, row, str.tostring(px, "#.##"),         text_color=color.new(#E6EDF3, 0), bgcolor=bg, text_size=size.small, text_halign=text.align_right)
            table.cell(tbl, 3, row, f_pctStr(cr),                     text_color=f_pctColor(cr),        bgcolor=bg, text_size=size.small, text_halign=text.align_right)
            table.cell(tbl, 4, row, f_pctStr(d1),                     text_color=f_pctColor(d1),        bgcolor=bg, text_size=size.small, text_halign=text.align_right)
            table.cell(tbl, 5, row, f_pctStr(w1),                     text_color=f_pctColor(w1),        bgcolor=bg, text_size=size.small, text_halign=text.align_right)
            table.cell(tbl, 6, row, f_pctStr(m1),                     text_color=f_pctColor(m1),        bgcolor=bg, text_size=size.small, text_halign=text.align_right)
            table.cell(tbl, 7, row, f_pctStr(m3),                     text_color=f_pctColor(m3),        bgcolor=bg, text_size=size.small, text_halign=text.align_right)
            table.cell(tbl, 8, row, f_pctStr(y1),                     text_color=f_pctColor(y1),        bgcolor=bg, text_size=size.small, text_halign=text.align_right)
            table.cell(tbl, 9, row, str.tostring(adr, "#.##") + "%",  text_color=color.new(#79C0FF, 0), bgcolor=bg, text_size=size.small, text_halign=text.align_right)

    // ── AVG row (equal-weight) ──
    if activeCount > 0
        avgRow    = row + 1
        avgBg     = color.new(#1F2937, 0)
        avgTxt    = color.new(#E6EDF3, 0)
        avgCustom = sumCustom / activeCount
        avg1d     = sum1d     / activeCount
        avg1w     = sum1w     / activeCount
        avg1m     = sum1m     / activeCount
        avg3m     = sum3m     / activeCount
        avg1y     = sum1y     / activeCount
        avgAdr    = sumAdr    / activeCount

        table.cell(tbl, 0, avgRow, "AVG",                              text_color=avgTxt,                bgcolor=avgBg, text_size=size.small, text_halign=text.align_center)
        table.cell(tbl, 1, avgRow, "Equal-Wt",                          text_color=avgTxt,                bgcolor=avgBg, text_size=size.small)
        table.cell(tbl, 2, avgRow, "",                                  text_color=avgTxt,                bgcolor=avgBg, text_size=size.small)
        table.cell(tbl, 3, avgRow, f_pctStr(avgCustom),                text_color=f_pctColor(avgCustom), bgcolor=avgBg, text_size=size.small, text_halign=text.align_right)
        table.cell(tbl, 4, avgRow, f_pctStr(avg1d),                    text_color=f_pctColor(avg1d),     bgcolor=avgBg, text_size=size.small, text_halign=text.align_right)
        table.cell(tbl, 5, avgRow, f_pctStr(avg1w),                    text_color=f_pctColor(avg1w),     bgcolor=avgBg, text_size=size.small, text_halign=text.align_right)
        table.cell(tbl, 6, avgRow, f_pctStr(avg1m),                    text_color=f_pctColor(avg1m),     bgcolor=avgBg, text_size=size.small, text_halign=text.align_right)
        table.cell(tbl, 7, avgRow, f_pctStr(avg3m),                    text_color=f_pctColor(avg3m),     bgcolor=avgBg, text_size=size.small, text_halign=text.align_right)
        table.cell(tbl, 8, avgRow, f_pctStr(avg1y),                    text_color=f_pctColor(avg1y),     bgcolor=avgBg, text_size=size.small, text_halign=text.align_right)
        table.cell(tbl, 9, avgRow, str.tostring(avgAdr, "#.##") + "%", text_color=color.new(#79C0FF, 0), bgcolor=avgBg, text_size=size.small, text_halign=text.align_right)

// ─────────────────────────────────────────────
// BASKET NAME PLATE (bottom-left)
// ─────────────────────────────────────────────
if barstate.islast
    nameTbl = table.new(position.bottom_left, columns=1, rows=1,
         bgcolor=color.new(#0D1117, 0),
         border_color=color.new(#58A6FF, 30),
         border_width=1,
         frame_color=color.new(#58A6FF, 0),
         frame_width=1)
    table.cell(nameTbl, 0, 0, "📦 " + i_basketName,
         text_color=color.new(#FFD700, 0),
         bgcolor=color.new(#0D1117, 0),
         text_size=size.large,
         text_halign=text.align_center)
````
