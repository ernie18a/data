<!-- tradingview-pine-id: PUB;941196f603d84baeb1e4a33aaee64b11 -->
<!-- tradingviewscripts-format: 1 -->
# RSI Smart Divergence [josseliani]

Source: https://www.tradingview.com/script/FIWh4SUe-RSI-Smart-Divergence-josseliani/

## Description

RSI Smart Divergence is an RSI divergence indicator designed to provide a clean and flexible way to work with confirmed bullish and bearish divergences.

There are many RSI divergence indicators available. I created this version because I wanted two different approaches to divergence detection in one simple tool: a selective Zone mode focused on overbought and oversold areas, and a separate Regular mode for more traditional divergence analysis.

One of the main visual features of RSI Smart Divergence is that confirmed divergences can be displayed simultaneously on the RSI and directly on the main price chart. The RSI line shows the momentum structure, while the price-chart line connects the corresponding local price extremes. This makes it possible to see the disagreement between price and RSI without manually matching oscillator pivots to candles.

ZONE MODE

Zone mode is the original logic of RSI Smart Divergence and is enabled by default.

Instead of evaluating every RSI pivot as the next divergence reference, this mode focuses specifically on divergence structures formed within the overbought and oversold zones.

For bullish divergence, the relevant RSI pivot points are evaluated within the oversold area.

For bearish divergence, the relevant RSI pivot points are evaluated within the overbought area.

Intermediate RSI pivots outside the relevant zone do not replace the previous zone reference point. This allows the indicator to compare significant momentum extremes inside the same zone even when other RSI swings occur between them.

As a result, Zone mode behaves differently from a standard adjacent-pivot divergence detector and provides a more selective view of divergence developing in already stretched momentum conditions.

REGULAR MODE

Regular mode is available as a separate optional mode.

It identifies classic regular bullish and bearish divergence using confirmed RSI pivots and corresponding local price extremes.

Additional structural filtering checks the price path between the selected endpoints and rejects structures where an intermediate price extreme invalidates the divergence being evaluated.

Regular mode is disabled by default.

The two modes operate independently and can identify different divergences. You can use Zone mode, Regular mode, or enable both at the same time.

CONFIRMED PIVOTS

Both modes use confirmed RSI pivots.

Pivot Left and Pivot Right determine how many bars are required around a potential RSI swing before it is considered confirmed.

The important setting for signal timing is Pivot Right.

For example:

Pivot Right = 3 — confirmation requires 3 bars to form to the right of the pivot.

Pivot Right = 10 — confirmation requires 10 bars to form to the right of the pivot.

Because of this confirmation process, a divergence becomes known only after the required right-side bars have formed.

The divergence lines are drawn back to the confirmed pivot locations, while the triangle marker and alert appear when the divergence is actually confirmed.

This distinction is important when reviewing historical charts: the lines identify the structure that produced the divergence, but the divergence was not known in real time until its confirmation bar.

PRICE AND RSI DISPLAY

Each confirmed divergence can be visualized in two places:

— on the RSI;
— directly on the corresponding price structure on the main chart.

The RSI line connects the confirmed momentum pivots used for the divergence.

The price-chart line connects the corresponding local price extremes.

This makes the relationship between price and oscillator structure immediately visible without manually matching RSI pivots to individual candles.

The RSI and price divergence lines can be enabled or disabled independently.

Small green and red triangles mark the confirmation of bullish and bearish divergence events in the RSI pane.

HOW I USE IT

The RSI period and pivot settings can be adjusted depending on the timeframe and the amount of market detail you want the indicator to capture.

For faster lower-timeframe trading, I may use a shorter RSI period such as 5 or 9 together with a smaller pivot setting around 3. This makes the indicator more responsive, but naturally includes more short-term market movement.

RSI 14 is a useful general starting point.

For higher timeframes, or when I want to focus on larger divergence structures, I normally keep RSI at 14 and increase the pivot setting.

For example, on a 15-minute chart I may use a pivot value around 10. This is one example configuration shown on the chart attached to this publication.

Smaller pivot settings produce faster and more frequent structures.

Larger pivot settings require more confirmation and tend to focus on broader swings.

WHAT MAKES THIS VERSION DIFFERENT

The main purpose of RSI Smart Divergence is not simply to mark every regular RSI divergence.

The original Zone mode maintains its own overbought and oversold divergence structure and ignores intermediate RSI pivots outside the relevant extreme zone when selecting the next comparison point.

Regular mode provides a separate approach for traders who also want traditional divergence detection.

Together with confirmed-pivot logic, corresponding price-extreme mapping, divergence lines on both RSI and price, adjustable structural distance and alerts, the two modes provide different ways to analyze divergence without requiring several separate indicators.

SETTINGS

RSI Length controls the RSI calculation period.

Overbought and Oversold Levels define the extreme RSI zones used by Zone mode.

Zone oversold / overbought enables the original Zone mode.

Regular enables regular divergence detection.

Pivot Left and Pivot Right control pivot confirmation.

Max bars between points limits the maximum distance between the two points of a divergence.

The RSI and price divergence lines can be shown or hidden independently.

Optional background highlighting can also be enabled for the overbought and oversold areas.

ALERTS

Alerts are available for confirmed bullish and bearish RSI divergences.

Alerts trigger when the divergence is confirmed, not retrospectively on the original pivot bar.

NOTES

RSI Smart Divergence is an analytical tool rather than an automatic trading system.

Divergence does not guarantee a market reversal. Different RSI periods and pivot settings can produce significantly different results, so settings should be selected according to the market, timeframe and trading approach being used.

The indicator should be used together with independent market analysis and appropriate risk management.

---

## Source Code

````pine
//@version=6
indicator("RSI Smart Divergence [josseliani]", overlay=false, max_lines_count=300, max_labels_count=300)
//====================================================
// INPUTS
//====================================================
groupRsi = "RSI Settings"
rsiLen = input.int(14, "RSI Length", minval=1, group=groupRsi)
src = input.source(close, "Source", group=groupRsi)
overbought = input.float(70.0, "Overbought Level", group=groupRsi)
oversold = input.float(30.0, "Oversold Level", group=groupRsi)

groupDiv = "Smart Divergence Settings"
modeZone = input.bool(true, "Zone oversold / overbought", group=groupDiv,
     tooltip="Marks divergences only in oversold/overbought RSI zones.\nThe two modes can show different signals. Enable both if you want all of them.")
modeRegular = input.bool(false, "Regular", group=groupDiv,
     tooltip="Regular divergences with stricter adjacent-pivot rules.\nThe two modes can show different signals. Enable both if you want all of them.")
pivotLeft = input.int(3, "Pivot Left", minval=1, group=groupDiv,
     tooltip="Bars to the left to confirm a swing. Higher = fewer, stronger pivots.")
pivotRight = input.int(3, "Pivot Right", minval=1, group=groupDiv,
     tooltip="Bars to the right to confirm a swing (signal delay). Triangles appear on the confirmation bar.")
maxBarsBetweenPoints = input.int(80, "Max bars between points", minval=5, group=groupDiv,
     tooltip="Maximum bar distance between the two divergence points.")
showOscDivLines = input.bool(true, "Draw divergence line on RSI", group=groupDiv)
showPriceDivLines = input.bool(true, "Draw divergence line on price chart", group=groupDiv)
maxDivLines = input.int(50, "Max divergence lines", minval=1, maxval=150, group=groupDiv)

groupView = "Display"
showLevels = input.bool(true, "Show RSI levels", group=groupView)
showBgZones = input.bool(false, "Color overbought/oversold background", group=groupView)

colBull = color.lime
colBear = color.red
lineStyle = line.style_dashed

// Zone mode uses the original ±3 price search (same as the first published logic).
zonePriceRadius = 3

//====================================================
// RSI + PIVOTS
//====================================================
rsi = ta.rsi(src, rsiLen)
rsiPivotLow = ta.pivotlow(rsi, pivotLeft, pivotRight)
rsiPivotHigh = ta.pivothigh(rsi, pivotLeft, pivotRight)

//====================================================
// FUNCTIONS
//====================================================
// Highest high / lowest low within ±radius of the RSI pivot bar (always returns a value).
f_priceLowNear(int centerOffset, int radius) =>
    int startOffset = math.max(centerOffset - radius, 0)
    int endOffset = centerOffset + radius
    float bestLow = low[startOffset]
    int bestBar = bar_index - startOffset
    for i = startOffset to endOffset
        if low[i] < bestLow
            bestLow := low[i]
            bestBar := bar_index - i
    [bestLow, bestBar]

f_priceHighNear(int centerOffset, int radius) =>
    int startOffset = math.max(centerOffset - radius, 0)
    int endOffset = centerOffset + radius
    float bestHigh = high[startOffset]
    int bestBar = bar_index - startOffset
    for i = startOffset to endOffset
        if high[i] > bestHigh
            bestHigh := high[i]
            bestBar := bar_index - i
    [bestHigh, bestBar]

// Regular only: nothing between the two glued price vertices may stick out above/below them.
f_noHighPopsBetween(int barA, float priceA, int barB, float priceB) =>
    int leftBar = math.min(barA, barB)
    int rightBar = math.max(barA, barB)
    float cap = math.max(priceA, priceB)
    bool clean = true
    int leftOff = bar_index - leftBar
    int rightOff = bar_index - rightBar
    if leftOff - rightOff > 1
        for off = rightOff + 1 to leftOff - 1
            if high[off] > cap
                clean := false
    clean

f_noLowPopsBetween(int barA, float priceA, int barB, float priceB) =>
    int leftBar = math.min(barA, barB)
    int rightBar = math.max(barA, barB)
    float floor_ = math.min(priceA, priceB)
    bool clean = true
    int leftOff = bar_index - leftBar
    int rightOff = bar_index - rightBar
    if leftOff - rightOff > 1
        for off = rightOff + 1 to leftOff - 1
            if low[off] < floor_
                clean := false
    clean

f_addLine(line[] arr, line ln, int maxCount) =>
    array.push(arr, ln)
    if array.size(arr) > maxCount
        line.delete(array.shift(arr))

f_drawDiv(line[] oscArr, line[] priceArr, int maxCount, bool showOsc, bool showPrice, int r1, float y1, int r2, float y2, int p1, float py1, int p2, float py2, color col) =>
    if showOsc
        f_addLine(oscArr, line.new(r1, y1, r2, y2, xloc=xloc.bar_index, extend=extend.none, color=col, style=lineStyle, width=1), maxCount)
    if showPrice
        f_addLine(priceArr, line.new(p1, py1, p2, py2, xloc=xloc.bar_index, extend=extend.none, color=col, style=lineStyle, width=1, force_overlay=true), maxCount)

//====================================================
// STATE
//====================================================
var float zBullRsi = na
var int zBullRsiBar = na
var float zBullPrice = na
var int zBullPriceBar = na
var float zBearRsi = na
var int zBearRsiBar = na
var float zBearPrice = na
var int zBearPriceBar = na

var float pBullRsi = na
var int pBullRsiBar = na
var float pBullPrice = na
var int pBullPriceBar = na
var float pBearRsi = na
var int pBearRsiBar = na
var float pBearPrice = na
var int pBearPriceBar = na

var line[] oscLines = array.new_line()
var line[] priceLines = array.new_line()

bullDiv = false
bearDiv = false
var float bullSignalY = na
var float bearSignalY = na
bullSignalY := na
bearSignalY := na

// Regular: wider window so price line locks to the real local extreme near the RSI pivot
regularPriceRadius = pivotLeft + pivotRight

//====================================================
// BULLISH
//====================================================
if barstate.isconfirmed and not na(rsiPivotLow)
    float currRsi = rsi[pivotRight]
    int currRsiBar = bar_index - pivotRight
    bool currInOs = currRsi < oversold

    // ----- Zone (original): both in OS, skip mid-zone pivots, price ±3 -----
    if modeZone
        [zPrice, zPriceBar] = f_priceLowNear(pivotRight, zonePriceRadius)
        bool prevOk = not na(zBullRsi) and not na(zBullRsiBar) and not na(zBullPrice) and not na(zBullPriceBar)
        int bars = prevOk ? currRsiBar - zBullRsiBar : 0
        bool inWin = prevOk and bars > 0 and bars <= maxBarsBetweenPoints
        if currInOs and inWin and currRsi > zBullRsi and zPrice < zBullPrice
            bullDiv := true
            bullSignalY := rsi
            f_drawDiv(oscLines, priceLines, maxDivLines, showOscDivLines, showPriceDivLines, zBullRsiBar, zBullRsi, currRsiBar, currRsi, zBullPriceBar, zBullPrice, zPriceBar, zPrice, colBull)
        if currInOs
            zBullRsi := currRsi
            zBullRsiBar := currRsiBar
            zBullPrice := zPrice
            zBullPriceBar := zPriceBar

    // ----- Regular: adjacent RSI pivots; glue to local price extreme; no pivot between -----
    if modeRegular
        [rPrice, rPriceBar] = f_priceLowNear(pivotRight, regularPriceRadius)
        bool prevOk = not na(pBullRsi) and not na(pBullPrice) and not na(pBullRsiBar) and not na(pBullPriceBar)
        int bars = prevOk ? currRsiBar - pBullRsiBar : 0
        bool inWin = prevOk and bars > 0 and bars <= maxBarsBetweenPoints
        bool priceStruct = inWin and currRsi > pBullRsi and rPrice < pBullPrice
        bool pathClean = priceStruct and f_noLowPopsBetween(pBullPriceBar, pBullPrice, rPriceBar, rPrice)
        if pathClean
            bullDiv := true
            bullSignalY := rsi
            f_drawDiv(oscLines, priceLines, maxDivLines, showOscDivLines, showPriceDivLines, pBullRsiBar, pBullRsi, currRsiBar, currRsi, pBullPriceBar, pBullPrice, rPriceBar, rPrice, colBull)
        pBullRsi := currRsi
        pBullRsiBar := currRsiBar
        pBullPrice := rPrice
        pBullPriceBar := rPriceBar

//====================================================
// BEARISH
//====================================================
if barstate.isconfirmed and not na(rsiPivotHigh)
    float currRsi = rsi[pivotRight]
    int currRsiBar = bar_index - pivotRight
    bool currInOb = currRsi > overbought

    // ----- Zone (original): both in OB, skip mid-zone pivots, price ±3 -----
    if modeZone
        [zPrice, zPriceBar] = f_priceHighNear(pivotRight, zonePriceRadius)
        bool prevOk = not na(zBearRsi) and not na(zBearRsiBar) and not na(zBearPrice) and not na(zBearPriceBar)
        int bars = prevOk ? currRsiBar - zBearRsiBar : 0
        bool inWin = prevOk and bars > 0 and bars <= maxBarsBetweenPoints
        if currInOb and inWin and currRsi < zBearRsi and zPrice > zBearPrice
            bearDiv := true
            bearSignalY := rsi
            f_drawDiv(oscLines, priceLines, maxDivLines, showOscDivLines, showPriceDivLines, zBearRsiBar, zBearRsi, currRsiBar, currRsi, zBearPriceBar, zBearPrice, zPriceBar, zPrice, colBear)
        if currInOb
            zBearRsi := currRsi
            zBearRsiBar := currRsiBar
            zBearPrice := zPrice
            zBearPriceBar := zPriceBar

    // ----- Regular: adjacent RSI pivots; glue to local price extreme; no pivot between -----
    if modeRegular
        [rPrice, rPriceBar] = f_priceHighNear(pivotRight, regularPriceRadius)
        bool prevOk = not na(pBearRsi) and not na(pBearPrice) and not na(pBearRsiBar) and not na(pBearPriceBar)
        int bars = prevOk ? currRsiBar - pBearRsiBar : 0
        bool inWin = prevOk and bars > 0 and bars <= maxBarsBetweenPoints
        bool priceStruct = inWin and currRsi < pBearRsi and rPrice > pBearPrice
        bool pathClean = priceStruct and f_noHighPopsBetween(pBearPriceBar, pBearPrice, rPriceBar, rPrice)
        if pathClean
            bearDiv := true
            bearSignalY := rsi
            f_drawDiv(oscLines, priceLines, maxDivLines, showOscDivLines, showPriceDivLines, pBearRsiBar, pBearRsi, currRsiBar, currRsi, pBearPriceBar, pBearPrice, rPriceBar, rPrice, colBear)
        pBearRsi := currRsi
        pBearRsiBar := currRsiBar
        pBearPrice := rPrice
        pBearPriceBar := rPriceBar

//====================================================
// PLOTS
//====================================================
plot(rsi, "RSI", color=color.aqua, linewidth=2)
plot(showLevels ? overbought : na, "Overbought", color=color.new(color.red, 40), linewidth=1)
plot(showLevels ? 50 : na, "Middle", color=color.new(color.gray, 70), linewidth=1)
plot(showLevels ? oversold : na, "Oversold", color=color.new(color.lime, 40), linewidth=1)
bgcolor(showBgZones and rsi > overbought ? color.new(color.red, 92) : na)
bgcolor(showBgZones and rsi < oversold ? color.new(color.green, 92) : na)
plotshape(bullDiv ? bullSignalY : na, title="Bullish RSI Divergence", style=shape.triangleup, location=location.absolute, color=color.lime, size=size.tiny)
plotshape(bearDiv ? bearSignalY : na, title="Bearish RSI Divergence", style=shape.triangledown, location=location.absolute, color=color.red, size=size.tiny)

alertcondition(bullDiv, title="Bullish RSI Divergence", message="Bullish RSI Divergence on {{ticker}} {{interval}}")
alertcondition(bearDiv, title="Bearish RSI Divergence", message="Bearish RSI Divergence on {{ticker}} {{interval}}")
````
