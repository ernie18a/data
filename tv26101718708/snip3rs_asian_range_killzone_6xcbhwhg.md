# Snip3rs- Asian Range + Killzone

- url: https://www.tradingview.com/script/6XcBHwhG-Snip3rs-Asian-Range-Killzone/
- type: indicator
- pine_id: PUB;afe68e23dfab43c6b0b436bec8a5227a
- version: 1.0

## Description

This script is designed to map out the most critical intraday time windows in the market — the Asian Range, London Kill Zone, and New York Kill Zone — and visually structure them directly on your chart.

At its core, this tool helps traders identify where price is building liquidity and when it is most likely to expand. The Asian session establishes the range, while London and New York act as the primary engines for volatility, displacement, and directional moves.

Why timing matters:

Markets do not move randomly — they move in cycles of accumulation and expansion. Understanding when the market is most active is just as important as understanding where price is reacting.

The Asian Range highlights consolidation and liquidity buildup
The London Kill Zone often initiates the first real expansion of the day
The New York Kill Zone provides continuation or reversal opportunities

By aligning your entries with these windows, you shift from random participation to structured execution — focusing only on the moments that statistically produce movement.

This script is built for traders who value precision, patience, and timing — allowing you to frame your setups around high-probability windows instead of forcing trades throughout the day.

Credit:
Concepts of kill zones and time-based liquidity are widely taught within the trading space. Credit to Michael J. Huddleston for his educational contributions to these ideas[/b][b][/b]

## Source Code

````pine
//@version=6
indicator("Snip3rs- Asian Range + Scopes", overlay=true, max_lines_count=500, max_boxes_count=500, max_labels_count=500)

// ========= Inputs =========
tz              = input.string("America/New_York", "Timezone")
// UPDATED session times:
asianSess       = input.session("2000-0100", "Asian Range (HHMM-HHMM, local)")      // 8:00 PM → 1:00 AM
londonSess      = input.session("0200-0600", "London Kill Zone (local)")            // 2:00 AM → 6:00 AM
nySess          = input.session("0830-1100", "New York Kill Zone (local)")          // 8:30 AM → 11:00 AM

showAsianBox    = input.bool(true,  "Show Asian Range Box")
extendAsianHL   = input.bool(true,  "Extend Asian High/Low → right")
showAsianLabels = input.bool(true,  "Label Asian start/end")

showLKZBox      = input.bool(true,  "Show London Range Box")
extendLKZHL     = input.bool(true,  "Extend London High/Low → right")
showNYKZBox     = input.bool(true,  "Show New York Range Box")
extendNYKZHL    = input.bool(true,  "Extend New York High/Low → right")

showLKZBand     = input.bool(true,  "Show London Time-Span Band (full height)")
showNYKZBand    = input.bool(true,  "Show New York Time-Span Band (full height)")

showKZLabels    = input.bool(true,  "Label Kill Zone starts")
hideWeekends    = input.bool(true,  "Hide on Weekends")

// Debug + visibility
debugMarks      = input.bool(true,  "Show debug markers (A/L/N flags)")
boxOpacity      = input.int(70, "Box opacity 0–100", minval=0, maxval=100)
bandOpacity     = input.int(88, "Band opacity 0–100", minval=0, maxval=100)

// ========= Colors =========
snipBlue   = color.rgb(0,174,239)
asianFill  = color.new(snipBlue, boxOpacity)
asianEdge  = color.new(snipBlue,  0)
lkzBoxFill = color.new(color.purple, boxOpacity)
lkzEdge    = color.new(color.purple, 0)
lkzBandCol = color.new(color.purple, bandOpacity)
nykzBoxFill= color.new(color.teal,   boxOpacity)
nykzEdge   = color.new(color.teal,   0)
nykzBandCol= color.new(color.teal,   bandOpacity)
textCol    = color.white

// ========= Helpers =========
f_inSession(sess) =>
    not na(time(timeframe.period, sess, tz))

f_label_down(x, y, txt, bg) =>
    label.new(x, y, txt, xloc.bar_index, yloc.price, bg, label.style_label_down, textCol)

f_label_up(x, y, txt, bg) =>
    label.new(x, y, txt, xloc.bar_index, yloc.price, bg, label.style_label_up, textCol)

// Keep weekend hiding, but allow Sunday 8 PM+ for Asian session formation
isSundayAsianWindow = dayofweek == dayofweek.sunday and not na(time(timeframe.period, "2000-2359", tz))
isWeekend = dayofweek == dayofweek.saturday or (dayofweek == dayofweek.sunday and not isSundayAsianWindow)
allowed   = not (hideWeekends and isWeekend)

// ========= Session flags =========
inAsian = allowed and f_inSession(asianSess)
inLKZ   = allowed and f_inSession(londonSess)
inNYKZ  = allowed and f_inSession(nySess)

asianStart = inAsian and not inAsian[1]
asianEnd   = not inAsian and inAsian[1]
lkzStart   = inLKZ and not inLKZ[1]
lkzEnd     = not inLKZ and inLKZ[1]
nykzStart  = inNYKZ and not inNYKZ[1]
nykzEnd    = not inNYKZ and inNYKZ[1]

// Debug markers at top of bar
plotchar(debugMarks and inAsian, title="inAsian", char='A', location=location.top, size=size.tiny, color=asianEdge)
plotchar(debugMarks and inLKZ,   title="inLKZ",   char='L', location=location.top, size=size.tiny, color=lkzEdge)
plotchar(debugMarks and inNYKZ,  title="inNYKZ",  char='N', location=location.top, size=size.tiny, color=nykzEdge)

// ========= Asian range tracking =========
var float aHigh = na
var float aLow  = na
var box   aBox  = na
var line  aHiLn = na
var line  aLoLn = na

if asianStart
    aHigh := high
    aLow  := low
    if showAsianBox
        aBox := box.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, bgcolor=asianFill, border_color=asianEdge, border_width=2)
    if showAsianLabels
        f_label_down(bar_index, high, "ASIAN START", asianEdge)

if inAsian
    aHigh := math.max(na(aHigh) ? high : aHigh, high)
    aLow  := math.min(na(aLow)  ? low  : aLow,  low)
    if showAsianBox and not na(aBox)
        box.set_top(aBox, aHigh)
        box.set_bottom(aBox, aLow)
        box.set_right(aBox, bar_index)

if asianEnd
    if showAsianBox and not na(aBox)
        box.set_right(aBox, bar_index)
    if extendAsianHL and not na(aHigh) and not na(aLow)
        if not na(aHiLn)
            line.delete(aHiLn)
        if not na(aLoLn)
            line.delete(aLoLn)
        aHiLn := line.new(bar_index, aHigh, bar_index + 1, aHigh, xloc=xloc.bar_index, extend=extend.right, color=asianEdge, width=2)
        aLoLn := line.new(bar_index, aLow,  bar_index + 1, aLow,  xloc=xloc.bar_index, extend=extend.right, color=asianEdge, width=2)
    if showAsianLabels
        f_label_up(bar_index, low, "ASIAN END", asianEdge)

// ========= London KZ =========
var float lkzHigh = na
var float lkzLow  = na
var box   lkzBox  = na
var line  lkzHiLn = na
var line  lkzLoLn = na

if lkzStart
    lkzHigh := high
    lkzLow  := low
    if showLKZBox
        lkzBox := box.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, bgcolor=lkzBoxFill, border_color=lkzEdge, border_width=2)
    if showKZLabels
        f_label_down(bar_index, high, "London KZ", lkzEdge)

if inLKZ
    lkzHigh := math.max(na(lkzHigh) ? high : lkzHigh, high)
    lkzLow  := math.min(na(lkzLow)  ? low  : lkzLow,  low)
    if showLKZBox and not na(lkzBox)
        box.set_top(lkzBox, lkzHigh)
        box.set_bottom(lkzBox, lkzLow)
        box.set_right(lkzBox, bar_index)

bgcolor(showLKZBand and inLKZ ? lkzBandCol : na)

if lkzEnd
    if showLKZBox and not na(lkzBox)
        box.set_right(lkzBox, bar_index)
    if extendLKZHL and not na(lkzHigh) and not na(lkzLow)
        if not na(lkzHiLn)
            line.delete(lkzHiLn)
        if not na(lkzLoLn)
            line.delete(lkzLoLn)
        lkzHiLn := line.new(bar_index, lkzHigh, bar_index + 1, lkzHigh, xloc=xloc.bar_index, extend=extend.right, color=lkzEdge, width=2)
        lkzLoLn := line.new(bar_index, lkzLow,  bar_index + 1, lkzLow,  xloc=xloc.bar_index, extend=extend.right, color=lkzEdge, width=2)

// ========= New York KZ =========
var float nyHigh = na
var float nyLow  = na
var box   nyBox  = na
var line  nyHiLn = na
var line  nyLoLn = na

if nykzStart
    nyHigh := high
    nyLow  := low
    if showNYKZBox
        nyBox := box.new(bar_index, high, bar_index, low, xloc=xloc.bar_index, bgcolor=nykzBoxFill, border_color=nykzEdge, border_width=2)
    if showKZLabels
        f_label_down(bar_index, high, "NY KZ", nykzEdge)

if inNYKZ
    nyHigh := math.max(na(nyHigh) ? high : nyHigh, high)
    nyLow  := math.min(na(nyLow)  ? low  : nyLow,  low)
    if showNYKZBox and not na(nyBox)
        box.set_top(nyBox, nyHigh)
        box.set_bottom(nyBox, nyLow)
        box.set_right(nyBox, bar_index)

bgcolor(showNYKZBand and inNYKZ ? nykzBandCol : na)

if nykzEnd
    if showNYKZBox and not na(nyBox)
        box.set_right(nyBox, bar_index)
    if extendNYKZHL and not na(nyHigh) and not na(nyLow)
        if not na(nyHiLn)
            line.delete(nyHiLn)
        if not na(nyLoLn)
            line.delete(nyLoLn)
        nyHiLn := line.new(bar_index, nyHigh, bar_index + 1, nyHigh, xloc=xloc.bar_index, extend=extend.right, color=nykzEdge, width=2)
        nyLoLn := line.new(bar_index, nyLow,  bar_index + 1, nyLow,  xloc=xloc.bar_index, extend=extend.right, color=nykzEdge, width=2)
````
