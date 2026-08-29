<!-- tradingview-pine-id: PUB;49d942c6929e4adabba28d09065d5c2a -->
<!-- tradingviewscripts-format: 1 -->
# QD Session Levels

Source: https://www.tradingview.com/script/BsfyhHCt-QD-Session-High-Low-Levels/

## Description

This indicator draws the high and low levels of the Asia, London, and New York sessions directly on your chart, extending each as a ray until price sweeps through it.

How to use it Session highs and lows often act as liquidity levels — areas where price is likely to react, reverse, or break through. This indicator lets you track those levels in real time without marking them manually, and see at a glance which levels are still active versus which have already been swept. Previous session levels stay visible on the chart until price takes them out, so you can track untouched liquidity across multiple sessions.

Session times (NY time):
* Asia: 20:00 – 00:00
* London: 02:00 – 07:00
* New York: 09:30 – 12:00

Features
* High/low rays for Asia, London, and NY sessions
* Sweep detection — a level automatically stops extending once price trades through it
* Option to keep swept levels visible on the chart instead of removing them
* Price axis labels for each level
* Adjustable label offset for positioning
* Style controls let you individually show/hide pane labels, lines, and price scale labels, and choose whether inputs appear on the status line

---

## Source Code

````pine
//@version=6
indicator("QD Session Levels", overlay=true, max_lines_count=500)

// --- COLORS ---
lineGrey  = color.rgb(150, 150, 150)
labelGrey = color.rgb(120, 120, 120)

// --- SESSION TOGGLES ---
showAsia   = input.bool(true,  title="Show Asia",         group="Session Visibility")
showLondon = input.bool(true,  title="Show London",       group="Session Visibility")
showNY     = input.bool(true,  title="Show New York",     group="Session Visibility")
showSwept  = input.bool(false, title="Show Swept Levels", group="Session Visibility")

// --- LABEL OFFSET ---
labelOffset = input.int(10, title="Label Offset (bars)", minval=1, maxval=100, group="Style")

// --- CYCLE TRACKER (increments each time Asia opens) ---
var int cycle = 0

// --- SWEPT OBJECT POOLS ---
var line[]  sweptLines = array.new_line()
var label[] sweptLbls  = array.new_label()
var int[]   sweptCycle = array.new_int()

// ============================================================
// ASIA (20:00 - 00:00) — defines start of new cycle
// ============================================================
inAsia    = not na(time(timeframe.period, "2000-0000:1234567", "America/New_York"))
isNewAsia = inAsia and not inAsia[1]

var float asiaHigh     = na
var float asiaLow      = na
var line  asiaHighLine = na
var line  asiaLowLine  = na
var label asiaHighLbl  = na
var label asiaLowLbl   = na

if isNewAsia
    cycle += 1
    // purge swept objects from the previous cycle
    int i = array.size(sweptCycle) - 1
    while i >= 0
        if array.get(sweptCycle, i) < cycle
            line.delete(array.get(sweptLines, i))
            label.delete(array.get(sweptLbls, i))
            array.remove(sweptLines, i)
            array.remove(sweptLbls,  i)
            array.remove(sweptCycle, i)
        i -= 1
    asiaHigh := high
    asiaLow  := low
    line.delete(asiaHighLine)
    line.delete(asiaLowLine)
    label.delete(asiaHighLbl)
    label.delete(asiaLowLbl)
    if showAsia
        asiaHighLine := line.new(bar_index, high, bar_index + 1, high, color=lineGrey, width=1, extend=extend.right)
        asiaLowLine  := line.new(bar_index, low,  bar_index + 1, low,  color=lineGrey, width=1, extend=extend.right)
        asiaHighLbl  := label.new(bar_index + labelOffset, high + syminfo.mintick * 15, "AH", color=color.new(color.white, 100), textcolor=labelGrey, style=label.style_none, size=size.normal, textalign=text.align_left)
        asiaLowLbl   := label.new(bar_index + labelOffset, low  + syminfo.mintick * 15, "AL", color=color.new(color.white, 100), textcolor=labelGrey, style=label.style_none, size=size.normal, textalign=text.align_left)

if inAsia
    if high > asiaHigh
        asiaHigh := high
    if low < asiaLow
        asiaLow := low
    if showAsia
        line.set_y1(asiaHighLine, asiaHigh)
        line.set_y2(asiaHighLine, asiaHigh)
        line.set_y1(asiaLowLine,  asiaLow)
        line.set_y2(asiaLowLine,  asiaLow)
        label.set_x(asiaHighLbl, bar_index + labelOffset)
        label.set_y(asiaHighLbl, asiaHigh + syminfo.mintick * 15)
        label.set_x(asiaLowLbl,  bar_index + labelOffset)
        label.set_y(asiaLowLbl,  asiaLow  + syminfo.mintick * 15)

if not inAsia and showAsia
    label.set_x(asiaHighLbl, bar_index + labelOffset)
    label.set_x(asiaLowLbl,  bar_index + labelOffset)
    if not na(asiaHigh) and high > asiaHigh
        if not showSwept
            line.delete(asiaHighLine)
            label.delete(asiaHighLbl)
        else
            array.push(sweptLines, asiaHighLine)
            array.push(sweptLbls,  asiaHighLbl)
            array.push(sweptCycle, cycle)
        asiaHighLine := na
        asiaHighLbl  := na
        asiaHigh     := na
    if not na(asiaLow) and low < asiaLow
        if not showSwept
            line.delete(asiaLowLine)
            label.delete(asiaLowLbl)
        else
            array.push(sweptLines, asiaLowLine)
            array.push(sweptLbls,  asiaLowLbl)
            array.push(sweptCycle, cycle)
        asiaLowLine := na
        asiaLowLbl  := na
        asiaLow     := na

// ============================================================
// LONDON (02:00 - 05:00)
// ============================================================
inLondon    = not na(time(timeframe.period, "0200-0700:1234567", "America/New_York"))
isNewLondon = inLondon and not inLondon[1]

var float lonHigh     = na
var float lonLow      = na
var line  lonHighLine = na
var line  lonLowLine  = na
var label lonHighLbl  = na
var label lonLowLbl   = na

if isNewLondon
    lonHigh := high
    lonLow  := low
    line.delete(lonHighLine)
    line.delete(lonLowLine)
    label.delete(lonHighLbl)
    label.delete(lonLowLbl)
    if showLondon
        lonHighLine := line.new(bar_index, high, bar_index + 1, high, color=lineGrey, width=1, extend=extend.right)
        lonLowLine  := line.new(bar_index, low,  bar_index + 1, low,  color=lineGrey, width=1, extend=extend.right)
        lonHighLbl  := label.new(bar_index + labelOffset, high + syminfo.mintick * 15, "LH", color=color.new(color.white, 100), textcolor=labelGrey, style=label.style_none, size=size.normal, textalign=text.align_left)
        lonLowLbl   := label.new(bar_index + labelOffset, low  + syminfo.mintick * 15, "LL", color=color.new(color.white, 100), textcolor=labelGrey, style=label.style_none, size=size.normal, textalign=text.align_left)

if inLondon
    if high > lonHigh
        lonHigh := high
    if low < lonLow
        lonLow := low
    if showLondon
        line.set_y1(lonHighLine, lonHigh)
        line.set_y2(lonHighLine, lonHigh)
        line.set_y1(lonLowLine,  lonLow)
        line.set_y2(lonLowLine,  lonLow)
        label.set_x(lonHighLbl, bar_index + labelOffset)
        label.set_y(lonHighLbl, lonHigh + syminfo.mintick * 15)
        label.set_x(lonLowLbl,  bar_index + labelOffset)
        label.set_y(lonLowLbl,  lonLow  + syminfo.mintick * 15)

if not inLondon and showLondon
    label.set_x(lonHighLbl, bar_index + labelOffset)
    label.set_x(lonLowLbl,  bar_index + labelOffset)
    if not na(lonHigh) and high > lonHigh
        if not showSwept
            line.delete(lonHighLine)
            label.delete(lonHighLbl)
        else
            array.push(sweptLines, lonHighLine)
            array.push(sweptLbls,  lonHighLbl)
            array.push(sweptCycle, cycle)
        lonHighLine := na
        lonHighLbl  := na
        lonHigh     := na
    if not na(lonLow) and low < lonLow
        if not showSwept
            line.delete(lonLowLine)
            label.delete(lonLowLbl)
        else
            array.push(sweptLines, lonLowLine)
            array.push(sweptLbls,  lonLowLbl)
            array.push(sweptCycle, cycle)
        lonLowLine := na
        lonLowLbl  := na
        lonLow     := na

// ============================================================
// NEW YORK (09:30 - 12:00)
// ============================================================
inNY    = not na(time(timeframe.period, "0930-1200:1234567", "America/New_York"))
isNewNY = inNY and not inNY[1]

var float nyHigh     = na
var float nyLow      = na
var line  nyHighLine = na
var line  nyLowLine  = na
var label nyHighLbl  = na
var label nyLowLbl   = na

if isNewNY
    nyHigh := high
    nyLow  := low
    line.delete(nyHighLine)
    line.delete(nyLowLine)
    label.delete(nyHighLbl)
    label.delete(nyLowLbl)
    if showNY
        nyHighLine := line.new(bar_index, high, bar_index + 1, high, color=lineGrey, width=1, extend=extend.right)
        nyLowLine  := line.new(bar_index, low,  bar_index + 1, low,  color=lineGrey, width=1, extend=extend.right)
        nyHighLbl  := label.new(bar_index + labelOffset, high + syminfo.mintick * 15, "NYH", color=color.new(color.white, 100), textcolor=labelGrey, style=label.style_none, size=size.normal, textalign=text.align_left)
        nyLowLbl   := label.new(bar_index + labelOffset, low  + syminfo.mintick * 15, "NYL", color=color.new(color.white, 100), textcolor=labelGrey, style=label.style_none, size=size.normal, textalign=text.align_left)

if inNY
    if high > nyHigh
        nyHigh := high
    if low < nyLow
        nyLow := low
    if showNY
        line.set_y1(nyHighLine, nyHigh)
        line.set_y2(nyHighLine, nyHigh)
        line.set_y1(nyLowLine,  nyLow)
        line.set_y2(nyLowLine,  nyLow)
        label.set_x(nyHighLbl, bar_index + labelOffset)
        label.set_y(nyHighLbl, nyHigh + syminfo.mintick * 15)
        label.set_x(nyLowLbl,  bar_index + labelOffset)
        label.set_y(nyLowLbl,  nyLow  + syminfo.mintick * 15)

if not inNY and showNY
    label.set_x(nyHighLbl, bar_index + labelOffset)
    label.set_x(nyLowLbl,  bar_index + labelOffset)
    if not na(nyHigh) and high > nyHigh
        if not showSwept
            line.delete(nyHighLine)
            label.delete(nyHighLbl)
        else
            array.push(sweptLines, nyHighLine)
            array.push(sweptLbls,  nyHighLbl)
            array.push(sweptCycle, cycle)
        nyHighLine := na
        nyHighLbl  := na
        nyHigh     := na
    if not na(nyLow) and low < nyLow
        if not showSwept
            line.delete(nyLowLine)
            label.delete(nyLowLbl)
        else
            array.push(sweptLines, nyLowLine)
            array.push(sweptLbls,  nyLowLbl)
            array.push(sweptCycle, cycle)
        nyLowLine := na
        nyLowLbl  := na
        nyLow     := na

// ============================================================
// PRICE AXIS LABELS via plot()
// ============================================================
plot(showAsia   ? asiaHigh : na, title="AH",  color=labelGrey, linewidth=1, style=plot.style_circles, display=display.price_scale)
plot(showAsia   ? asiaLow  : na, title="AL",  color=labelGrey, linewidth=1, style=plot.style_circles, display=display.price_scale)
plot(showLondon ? lonHigh  : na, title="LH",  color=labelGrey, linewidth=1, style=plot.style_circles, display=display.price_scale)
plot(showLondon ? lonLow   : na, title="LL",  color=labelGrey, linewidth=1, style=plot.style_circles, display=display.price_scale)
plot(showNY     ? nyHigh   : na, title="NYH", color=labelGrey, linewidth=1, style=plot.style_circles, display=display.price_scale)
plot(showNY     ? nyLow    : na, title="NYL", color=labelGrey, linewidth=1, style=plot.style_circles, display=display.price_scale)
````
