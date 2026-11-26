# Trend EMA (MTF) + 4H 200 EMAf

- url: https://www.tradingview.com/script/z1e5pg5n-Trend-EMA-MTF-4H-200-EMAf/
- type: indicator
- pine_id: PUB;10d607776eda449d9c1f1b81df874824
- version: 4.0

## Description

WHAT THIS DOES

Plots a higher-timeframe trend EMA on any chart (default: 60-period EMA of daily closes), colored by its slope: green while rising, red while falling. A second reference line plots the 200 EMA computed on 4-hour bars regardless of your chart timeframe. Floating chips at the end of each line identify them at a glance ("Daily trend EMA" / "4H 200 EMA"), with the trend chip showing a live direction arrow.

KEY FEATURES

- Trend EMA timeframe is selectable: Hourly, 4-Hour, or Daily (length configurable, default 60)
- Slope coloring: the line turns green when rising and red when falling, so trend state is readable without any oscillator
- Hover-to-peek bar coloring: hover over or select the indicator and the price bars instantly color green/red based on whether price is above or below the trend EMA. Click empty chart space and the coloring disappears. No settings required.
- Permanent bar coloring: if you prefer always-on painting, enable it in the Style tab ("Price bar coloring (permanent)")
- Session pinning: EMAs are computed on a fixed data session (Extended 24H by default), so the 4H 200 EMA shows the SAME value whether you view it from a 15-minute, 4-hour, or 3-day chart
- Smart labels: the two chips automatically split apart vertically when the lines converge, so they never overlap

HOW IT WORKS

- The higher-timeframe EMA is requested with gaps enabled, so it prints once per HTF bar and draws as a smooth connected line on intraday charts instead of a stair-step
- Slope state is persisted across the in-between bars, driving the line color, the label color, and the direction arrow
- The data session is pinned via ticker.modify(). Extended-hours data only exists on intraday charts, so an intraday EMA inherited from chart data changes value when you switch to daily+ timeframes. Pinning the session removes that inconsistency, which is a subtle but real problem with most MTF EMA scripts.
- The peek feature works by plotting exact candle copies behind the main price bars, colored by position vs the EMA. TradingView raises a hovered or selected indicator above the main series, which reveals them; deselecting drops them behind the bars again.

HOW TO USE IT

- Trend filter: take longs while the trend EMA is green and price holds above it, shorts while red and below. The bar-peek gives an instant read on how price has interacted with the EMA historically.
- Pullback reference: on intraday charts, the daily trend EMA often acts as a dynamic pullback zone within trends.
- The 4H 200 EMA is a slower structural reference; confluence of the two lines tends to mark meaningful support/resistance zones.

SETTINGS

- Trend EMA: timeframe, length, width, rising/falling colors
- Bar coloring: above/below colors (used by both peek and permanent modes)
- 4H 200 EMA: show/hide, color, width
- Labels: show/hide, offset from last bar
- Data: session used for intraday EMAs (Extended 24H / Regular hours / Chart)

NOTES

- Designed for chart timeframes at or below the selected EMA timeframe. On higher timeframes the intraday EMAs are sampled once per chart bar (coarser but consistent thanks to session pinning).
- The peek feature relies on solid candle/bar styles. With hollow candles, disable the "Bars above/below EMA" plots in the Style tab.
- If bars appear permanently colored after adding the indicator, right-click it and choose Visual order > Send to back.

This is a technical analysis tool for educational purposes, not financial advice.

## Source Code

````pine
//@version=6
indicator("Trend EMA (MTF) + 4H 200 EMA + 200D MA + 50W MA", "Trend EMA", overlay = true)

// ─── Inputs: Trend EMA ───────────────────────────────────────────
tfChoice   = input.string("Daily", "Trend EMA timeframe", options = ["Hourly", "4 Hour", "Daily"], group = "Trend EMA")
showAllTf  = input.bool(false, "Show hourly + 4H + daily together", group = "Trend EMA",
     tooltip = "Plots all three trend EMAs at once — thin hourly, medium 4H, thick daily — each colored by its own slope. The dropdown above still picks which EMA drives the bar coloring, and stays the single line shown when this is off.")
emaLen     = input.int(60, "Trend EMA length", minval = 1, group = "Trend EMA")
trendWidth = input.int(3, "Line width", minval = 1, maxval = 10, group = "Trend EMA")
colUp      = input.color(#00E676, "Rising", inline = "col", group = "Trend EMA")
colDn      = input.color(#FF1744, "Falling", inline = "col", group = "Trend EMA")

// ─── Inputs: Bar coloring ────────────────────────────────────────
barUp      = input.color(#00FF00, "Bar above EMA", inline = "bar", group = "Bar coloring")
barDn      = input.color(#FF0000, "Bar below EMA", inline = "bar", group = "Bar coloring")

// ─── Inputs: 4H 200 EMA ──────────────────────────────────────────
show200    = input.bool(true, "Show 4H 200 EMA", group = "4H 200 EMA")
col200     = input.color(#2962FF, "Color", group = "4H 200 EMA")
width200   = input.int(2, "Line width", minval = 1, maxval = 10, group = "4H 200 EMA")

// ─── Inputs: 200D MA ─────────────────────────────────────────────
showD200   = input.bool(true, "Show 200D MA", group = "200D MA")
d200Type   = input.string("SMA", "Type", options = ["SMA", "EMA"], group = "200D MA")
d200Len    = input.int(200, "Length (days)", minval = 1, group = "200D MA")
colD200    = input.color(#FF9800, "Color", group = "200D MA")
widthD200  = input.int(2, "Line width", minval = 1, maxval = 10, group = "200D MA")

// ─── Inputs: 50W MA ──────────────────────────────────────────────
showW50    = input.bool(true, "Show 50W MA", group = "50W MA")
w50Type    = input.string("SMA", "Type", options = ["SMA", "EMA"], group = "50W MA")
w50Len     = input.int(50, "Length (weeks)", minval = 1, group = "50W MA")
colW50     = input.color(#AB47BC, "Color", group = "50W MA")
widthW50   = input.int(2, "Line width", minval = 1, maxval = 10, group = "50W MA")

// ─── Inputs: Labels ──────────────────────────────────────────────
showBubble = input.bool(true, "Show floating labels", group = "Labels")
lblOffset  = input.int(3, "Label offset (bars)", minval = 0, group = "Labels")

// ─── Inputs: Data ────────────────────────────────────────────────
sessChoice = input.string("Extended (24H)", "Intraday session for EMAs", options = ["Extended (24H)", "Regular hours", "Chart"], group = "Data",
     tooltip = "Pins the data session so the hourly and 4H EMAs stay identical on every chart timeframe. Use the setting that matches how you normally chart (24H on = Extended).")

reqSym = switch sessChoice
    "Extended (24H)" => ticker.modify(syminfo.tickerid, session.extended)
    "Regular hours"  => ticker.modify(syminfo.tickerid, session.regular)
    => syminfo.tickerid

// ─── Trend EMAs (all three timeframes; dropdown picks the driver) ─
emaPair() =>
    e = ta.ema(close, emaLen)
    [e, e[1]]

[emaH, emaHPrev] = request.security(reqSym, "60",  emaPair(), gaps = barmerge.gaps_on)
[ema4, ema4Prev] = request.security(reqSym, "240", emaPair(), gaps = barmerge.gaps_on)
[emaD, emaDPrev] = request.security(reqSym, "D",   emaPair(), gaps = barmerge.gaps_on)

// slope direction, persisted across the gap bars between HTF prints
// (each call site keeps its own `d`, so the three timeframes don't mix)
trendDir(float e, float ePrev) =>
    var int d = 0
    if not na(e) and not na(ePrev)
        d := e > ePrev ? 1 : e < ePrev ? -1 : d
    d

dirH = trendDir(emaH, emaHPrev)
dir4 = trendDir(ema4, ema4Prev)
dirD = trendDir(emaD, emaDPrev)

colFor(int d) =>
    d < 0 ? colDn : colUp

// the dropdown's timeframe: the single line in normal view, and always
// the driver for bar coloring
htfEma   = tfChoice == "Hourly" ? emaH : tfChoice == "4 Hour" ? ema4 : emaD
dir      = tfChoice == "Hourly" ? dirH : tfChoice == "4 Hour" ? dir4 : dirD
trendCol = colFor(dir)

// continuous copies for bar coloring and the labels (gapped copies get plotted)
emaHNow = fixnan(emaH)
ema4Now = fixnan(ema4)
emaDNow = fixnan(emaD)
emaNow  = tfChoice == "Hourly" ? emaHNow : tfChoice == "4 Hour" ? ema4Now : emaDNow

plot(showAllTf ? na : htfEma, "Trend EMA", trendCol, trendWidth)

// all-timeframes view: thin hourly → medium 4H → thick daily, each colored
// by its own slope (widths fixed here; restyle per line in the Style tab)
plot(showAllTf ? emaH : na, "Hourly trend EMA (all TFs)", colFor(dirH), 1)
plot(showAllTf ? ema4 : na, "4H trend EMA (all TFs)",     colFor(dir4), 2)
plot(showAllTf ? emaD : na, "Daily trend EMA (all TFs)",  colFor(dirD), 3)

// ─── Bar coloring: two modes ─────────────────────────────────────
above = close >= emaNow

// 1) Hover/click-to-peek: visible candle copies drawn BEHIND the price bars.
//    Hovering or selecting this indicator lifts it to the front, revealing
//    the colors; clicking empty chart drops it behind again.
plotcandle(above ? open : na, above ? high : na, above ? low : na, above ? close : na,
     "Bars above EMA", color = barUp, wickcolor = barUp, bordercolor = barUp)
plotcandle(above ? na : open, above ? na : high, above ? na : low, above ? na : close,
     "Bars below EMA", color = barDn, wickcolor = barDn, bordercolor = barDn)

// 2) Always-on painting: off by default, enable via double-click on the
//    EMA line → Style → "Price bar coloring (permanent)"
barcolor(above ? barUp : barDn, title = "Price bar coloring (permanent)", display = display.none)

// ─── 4H 200 EMA ──────────────────────────────────────────────────
ema200_4h = request.security(reqSym, "240", ta.ema(close, 200), gaps = barmerge.gaps_on)
e200Now   = fixnan(ema200_4h)
plot(show200 ? ema200_4h : na, "4H 200 EMA", col200, width200)

// ─── 200D MA ─────────────────────────────────────────────────────
d200Calc() =>
    s = ta.sma(close, d200Len)
    e = ta.ema(close, d200Len)
    d200Type == "SMA" ? s : e

ma200d  = request.security(reqSym, "D", d200Calc(), gaps = barmerge.gaps_on)
d200Now = fixnan(ma200d)
plot(showD200 ? ma200d : na, "200D MA", colD200, widthD200)

// ─── 50W MA ──────────────────────────────────────────────────────
// Long-term trend line. 50 weeks ≈ 250 trading days, so it sits a little
// slower than the 200D and the two cross rarely — when they do, that gap is
// the whole regime question in one picture.
w50Calc() =>
    s = ta.sma(close, w50Len)
    e = ta.ema(close, w50Len)
    w50Type == "SMA" ? s : e

ma50w  = request.security(reqSym, "W", w50Calc(), gaps = barmerge.gaps_on)
w50Now = fixnan(ma50w)
plot(showW50 ? ma50w : na, "50W MA", colW50, widthW50)

// ─── Labels ──────────────────────────────────────────────────────
CHIP_BG = color.new(#1E222D, 10)   // quiet dark pill, all chips
TXT_200 = #82B1FF                  // lighter blue than the line, for contrast on the dark chip
TXT_W50 = #E1BEE7                  // lighter purple than the line, same reason

// which trend chips are on: the selected one, or all three in all-TFs view
showTrendH = showAllTf or tfChoice == "Hourly"
showTrend4 = showAllTf or tfChoice == "4 Hour"
showTrendD = showAllTf or tfChoice == "Daily"

// collision handling: when any lines run close together, spread the chips
// vertically by rank (highest line's chip above, lowest below, middle inline)
rangeApprox = ta.highest(high, 120) - ta.lowest(low, 120)
thresh      = rangeApprox * 0.06

chipsCollide(array<float> vals, float th) =>
    hit = false
    for [i, a] in vals
        for [j, b] in vals
            if j > i and math.abs(a - b) < th
                hit := true
    hit

// how many shown lines sit above this one — 0 = topmost, n - 1 = bottom
rankOf(float v, array<float> vals) =>
    r = 0
    for x in vals
        if x > v
            r += 1
    r

styleFor(int rank, int n, bool collide) =>
    not collide ? label.style_label_left :
     rank == 0 ? label.style_label_lower_left :
     rank == n - 1 ? label.style_label_upper_left :
     label.style_label_left

var label lblTrendH = na
var label lblTrend4 = na
var label lblTrendD = na
var label lbl200    = na
var label lblD200   = na
var label lblW50    = na
if barstate.islast
    label.delete(lblTrendH)
    label.delete(lblTrend4)
    label.delete(lblTrendD)
    label.delete(lbl200)
    label.delete(lblD200)
    label.delete(lblW50)
    if showBubble
        levels = array.new_float()
        if showTrendH
            array.push(levels, emaHNow)
        if showTrend4
            array.push(levels, ema4Now)
        if showTrendD
            array.push(levels, emaDNow)
        if show200
            array.push(levels, e200Now)
        if showD200
            array.push(levels, d200Now)
        if showW50
            array.push(levels, w50Now)
        n       = array.size(levels)
        collide = chipsCollide(levels, thresh)
        if showTrendH
            lblTrendH := label.new(bar_index + lblOffset, emaHNow,
                 (dirH < 0 ? "▼ " : "▲ ") + "Hourly trend EMA",
                 xloc.bar_index, yloc.price, CHIP_BG, styleFor(rankOf(emaHNow, levels), n, collide), colFor(dirH), size.small,
                 tooltip = "EMA " + str.tostring(emaLen) + " · Hourly timeframe")
        if showTrend4
            lblTrend4 := label.new(bar_index + lblOffset, ema4Now,
                 (dir4 < 0 ? "▼ " : "▲ ") + "4H trend EMA",
                 xloc.bar_index, yloc.price, CHIP_BG, styleFor(rankOf(ema4Now, levels), n, collide), colFor(dir4), size.small,
                 tooltip = "EMA " + str.tostring(emaLen) + " · 4H timeframe")
        if showTrendD
            lblTrendD := label.new(bar_index + lblOffset, emaDNow,
                 (dirD < 0 ? "▼ " : "▲ ") + "Daily trend EMA",
                 xloc.bar_index, yloc.price, CHIP_BG, styleFor(rankOf(emaDNow, levels), n, collide), colFor(dirD), size.small,
                 tooltip = "EMA " + str.tostring(emaLen) + " · Daily timeframe")
        if show200
            lbl200 := label.new(bar_index + lblOffset, e200Now, "4H 200 EMA",
                 xloc.bar_index, yloc.price, CHIP_BG, styleFor(rankOf(e200Now, levels), n, collide), TXT_200, size.small,
                 tooltip = "EMA 200 · 4H timeframe")
        if showD200
            lblD200 := label.new(bar_index + lblOffset, d200Now, "200D " + d200Type,
                 xloc.bar_index, yloc.price, CHIP_BG, styleFor(rankOf(d200Now, levels), n, collide), colD200, size.small,
                 tooltip = d200Type + " " + str.tostring(d200Len) + " · Daily timeframe")
        if showW50
            lblW50 := label.new(bar_index + lblOffset, w50Now,
                 str.tostring(w50Len) + "W " + w50Type,
                 xloc.bar_index, yloc.price, CHIP_BG, styleFor(rankOf(w50Now, levels), n, collide), TXT_W50, size.small,
                 tooltip = w50Type + " " + str.tostring(w50Len) + " · Weekly timeframe")
````
