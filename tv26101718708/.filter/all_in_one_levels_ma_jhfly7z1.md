# All In One Levels + MA

- url: https://www.tradingview.com/script/jhFLY7Z1-All-In-One-Levels-MA/
- type: indicator
- pine_id: PUB;9722fa13ef484d8bb99047151cb72179
- version: 1.0

## Description

This has the previous sessions lows and highs. It also has the last 4 hour candle low and high incorporated. It includes the 10,50,100, and 200 SMAs. It also includes the 20,50,100, and 200 EMAs. This is a test script I am using myself. Feel free to test it out if this pops up.

## Source Code

````pine
//@version=6
indicator("All In One Levels + MA", overlay = true, max_lines_count = 500, max_labels_count = 500)

//━━━━━━━━━━━━━━━━━━━
// Inputs
//━━━━━━━━━━━━━━━━━━━
showPrevDay   = input.bool(true, "Previous Day High/Low")
showPrev4H    = input.bool(true, "Last Completed 4H Candle High/Low")
showAsia      = input.bool(true, "Asia High/Low")
showLondon    = input.bool(true, "London High/Low")
showNYOpen    = input.bool(true, "New York Open")
showLabels    = input.bool(true, "Show Level Labels")

showEMA20     = input.bool(true, "EMA 20")
showEMA50     = input.bool(true, "EMA 50")
showEMA100    = input.bool(true, "EMA 100")
showEMA200    = input.bool(true, "EMA 200")

showSMA10     = input.bool(true, "SMA 10")
showSMA50     = input.bool(true, "SMA 50")
showSMA100    = input.bool(true, "SMA 100")
showSMA200    = input.bool(true, "SMA 200")

asiaSession   = input.session("1700-0000", "Asia Session (CT)")
londonSession = input.session("0200-0500", "London Session (CT)")
nyOpenSession = input.session("0830-0835", "NY Open Window (CT)")

levelWidth    = input.int(1, "Session Level Width", minval = 1, maxval = 4)
emaWidth      = input.int(1, "EMA Width", minval = 1, maxval = 4)
smaWidth      = input.int(3, "SMA Width", minval = 1, maxval = 6)
labelOffset   = input.int(12, "Label Offset Right", minval = 1, maxval = 100)

//━━━━━━━━━━━━━━━━━━━
// MA Colors / Opacity
//━━━━━━━━━━━━━━━━━━━
// EMAs = 65% opacity
colEMA20   = color.new(color.red, 65)
colEMA50   = color.new(color.orange, 65)
colEMA100  = color.new(color.aqua, 65)
colEMA200  = color.new(color.yellow, 65)

// SMAs = 50% opacity
colSMA10   = color.new(color.green, 50)
colSMA50   = color.new(color.teal, 50)
colSMA100  = color.new(color.blue, 50)
colSMA200  = color.new(color.purple, 50)

//━━━━━━━━━━━━━━━━━━━
// Level line colors
//━━━━━━━━━━━━━━━━━━━
colPrevDayLine = color.new(color.aqua, 0)
colPrev4HLine  = color.new(color.orange, 0)
colAsiaLine    = color.new(color.white, 0)
colLondonLine  = color.new(color.silver, 0)
colNYOpenLine  = color.new(color.gray, 10)

//━━━━━━━━━━━━━━━━━━━
// Level label text colors
//━━━━━━━━━━━━━━━━━━━
colPrevDayText = color.rgb(90, 220, 235)
colPrev4HText  = color.rgb(235, 176, 70)
colAsiaText    = color.rgb(225, 228, 235)
colLondonText  = color.rgb(205, 210, 220)
colNYOpenText  = color.rgb(150, 160, 180)

// transparent label background
colLabelBg = color.new(color.black, 100)

//━━━━━━━━━━━━━━━━━━━
// Moving averages
//━━━━━━━━━━━━━━━━━━━
ema20  = ta.ema(close, 20)
ema50  = ta.ema(close, 50)
ema100 = ta.ema(close, 100)
ema200 = ta.ema(close, 200)

sma10  = ta.sma(close, 10)
sma50  = ta.sma(close, 50)
sma100 = ta.sma(close, 100)
sma200 = ta.sma(close, 200)

plot(showEMA20  ? ema20  : na, title = "EMA20",  color = colEMA20,  linewidth = emaWidth)
plot(showEMA50  ? ema50  : na, title = "EMA50",  color = colEMA50,  linewidth = emaWidth)
plot(showEMA100 ? ema100 : na, title = "EMA100", color = colEMA100, linewidth = emaWidth)
plot(showEMA200 ? ema200 : na, title = "EMA200", color = colEMA200, linewidth = emaWidth)

plot(showSMA10  ? sma10  : na, title = "SMA10",  color = colSMA10,  linewidth = smaWidth)
plot(showSMA50  ? sma50  : na, title = "SMA50",  color = colSMA50,  linewidth = smaWidth)
plot(showSMA100 ? sma100 : na, title = "SMA100", color = colSMA100, linewidth = smaWidth)
plot(showSMA200 ? sma200 : na, title = "SMA200", color = colSMA200, linewidth = smaWidth)

//━━━━━━━━━━━━━━━━━━━
// Session logic
//━━━━━━━━━━━━━━━━━━━
inAsia   = not na(time(timeframe.period, asiaSession))
inLondon = not na(time(timeframe.period, londonSession))
inNYOpen = not na(time(timeframe.period, nyOpenSession))

newAsia   = inAsia and not inAsia[1]
endAsia   = not inAsia and inAsia[1]

newLondon = inLondon and not inLondon[1]
endLondon = not inLondon and inLondon[1]

newNYOpen = inNYOpen and not inNYOpen[1]

//━━━━━━━━━━━━━━━━━━━
// Previous day and last completed 4H candle
//━━━━━━━━━━━━━━━━━━━
prevDayHigh = request.security(syminfo.tickerid, "D", high[1], barmerge.gaps_off, barmerge.lookahead_off)
prevDayLow  = request.security(syminfo.tickerid, "D", low[1],  barmerge.gaps_off, barmerge.lookahead_off)

last4HHigh  = request.security(syminfo.tickerid, "240", high[1], barmerge.gaps_off, barmerge.lookahead_off)
last4HLow   = request.security(syminfo.tickerid, "240", low[1],  barmerge.gaps_off, barmerge.lookahead_off)

//━━━━━━━━━━━━━━━━━━━
// Track session highs/lows
//━━━━━━━━━━━━━━━━━━━
var float asiaHigh = na
var float asiaLow = na
var float londonHigh = na
var float londonLow = na
var float nyOpenPrice = na

if newAsia
    asiaHigh := high
    asiaLow := low
else if inAsia
    asiaHigh := math.max(asiaHigh, high)
    asiaLow := math.min(asiaLow, low)

if newLondon
    londonHigh := high
    londonLow := low
else if inLondon
    londonHigh := math.max(londonHigh, high)
    londonLow := math.min(londonLow, low)

if newNYOpen
    nyOpenPrice := open

//━━━━━━━━━━━━━━━━━━━
// Objects
//━━━━━━━━━━━━━━━━━━━
var line pdhLine = na
var line pdlLine = na
var line h4HighLine = na
var line h4LowLine = na
var line asiaHighLine = na
var line asiaLowLine = na
var line londonHighLine = na
var line londonLowLine = na
var line nyOpenLine = na

var label pdhLbl = na
var label pdlLbl = na
var label h4HighLbl = na
var label h4LowLbl = na
var label asiaHighLbl = na
var label asiaLowLbl = na
var label londonHighLbl = na
var label londonLowLbl = na
var label nyOpenLbl = na

newDay = ta.change(time("D")) != 0
new4H  = ta.change(time("240")) != 0

tick = syminfo.mintick
pad1 = tick * 8
pad2 = tick * 16
pad3 = tick * 24
pad4 = tick * 32

//━━━━━━━━━━━━━━━━━━━
// Previous day lines
//━━━━━━━━━━━━━━━━━━━
if newDay or barstate.isfirst
    if not na(pdhLine)
        line.delete(pdhLine)
    if not na(pdlLine)
        line.delete(pdlLine)
    if not na(pdhLbl)
        label.delete(pdhLbl)
    if not na(pdlLbl)
        label.delete(pdlLbl)

    if showPrevDay
        pdhLine := line.new(bar_index, prevDayHigh, bar_index + 1, prevDayHigh, extend = extend.right, color = colPrevDayLine, width = levelWidth)
        pdlLine := line.new(bar_index, prevDayLow,  bar_index + 1, prevDayLow,  extend = extend.right, color = colPrevDayLine, width = levelWidth)

        if showLabels
            pdhLbl := label.new(bar_index + labelOffset, prevDayHigh + pad1, "Prev Day High", xloc = xloc.bar_index, style = label.style_label_left, textcolor = colPrevDayText, color = colLabelBg, size = size.small)
            pdlLbl := label.new(bar_index + labelOffset, prevDayLow - pad1,  "Prev Day Low",  xloc = xloc.bar_index, style = label.style_label_left, textcolor = colPrevDayText, color = colLabelBg, size = size.small)

//━━━━━━━━━━━━━━━━━━━
// Last completed 4H candle lines
//━━━━━━━━━━━━━━━━━━━
if new4H or barstate.isfirst
    if not na(h4HighLine)
        line.delete(h4HighLine)
    if not na(h4LowLine)
        line.delete(h4LowLine)
    if not na(h4HighLbl)
        label.delete(h4HighLbl)
    if not na(h4LowLbl)
        label.delete(h4LowLbl)

    if showPrev4H
        h4HighLine := line.new(bar_index, last4HHigh, bar_index + 1, last4HHigh, extend = extend.right, color = colPrev4HLine, width = levelWidth)
        h4LowLine  := line.new(bar_index, last4HLow,  bar_index + 1, last4HLow,  extend = extend.right, color = colPrev4HLine, width = levelWidth)

        if showLabels
            h4HighLbl := label.new(bar_index + labelOffset, last4HHigh + pad2, "Last 4H High", xloc = xloc.bar_index, style = label.style_label_left, textcolor = colPrev4HText, color = colLabelBg, size = size.small)
            h4LowLbl  := label.new(bar_index + labelOffset, last4HLow - pad2,  "Last 4H Low",  xloc = xloc.bar_index, style = label.style_label_left, textcolor = colPrev4HText, color = colLabelBg, size = size.small)

//━━━━━━━━━━━━━━━━━━━
// Asia lines
//━━━━━━━━━━━━━━━━━━━
if endAsia
    if not na(asiaHighLine)
        line.delete(asiaHighLine)
    if not na(asiaLowLine)
        line.delete(asiaLowLine)
    if not na(asiaHighLbl)
        label.delete(asiaHighLbl)
    if not na(asiaLowLbl)
        label.delete(asiaLowLbl)

    if showAsia
        asiaHighLine := line.new(bar_index, asiaHigh, bar_index + 1, asiaHigh, extend = extend.right, color = colAsiaLine, width = levelWidth)
        asiaLowLine  := line.new(bar_index, asiaLow,  bar_index + 1, asiaLow,  extend = extend.right, color = colAsiaLine, width = levelWidth)

        if showLabels
            asiaHighLbl := label.new(bar_index + labelOffset, asiaHigh + pad3, "Asia High", xloc = xloc.bar_index, style = label.style_label_left, textcolor = colAsiaText, color = colLabelBg, size = size.small)
            asiaLowLbl  := label.new(bar_index + labelOffset, asiaLow - pad3,  "Asia Low",  xloc = xloc.bar_index, style = label.style_label_left, textcolor = colAsiaText, color = colLabelBg, size = size.small)

//━━━━━━━━━━━━━━━━━━━
// London lines
//━━━━━━━━━━━━━━━━━━━
if endLondon
    if not na(londonHighLine)
        line.delete(londonHighLine)
    if not na(londonLowLine)
        line.delete(londonLowLine)
    if not na(londonHighLbl)
        label.delete(londonHighLbl)
    if not na(londonLowLbl)
        label.delete(londonLowLbl)

    if showLondon
        londonHighLine := line.new(bar_index, londonHigh, bar_index + 1, londonHigh, extend = extend.right, color = colLondonLine, width = levelWidth)
        londonLowLine  := line.new(bar_index, londonLow,  bar_index + 1, londonLow,  extend = extend.right, color = colLondonLine, width = levelWidth)

        if showLabels
            londonHighLbl := label.new(bar_index + labelOffset, londonHigh + pad4, "London High", xloc = xloc.bar_index, style = label.style_label_left, textcolor = colLondonText, color = colLabelBg, size = size.small)
            londonLowLbl  := label.new(bar_index + labelOffset, londonLow - pad4,  "London Low",  xloc = xloc.bar_index, style = label.style_label_left, textcolor = colLondonText, color = colLabelBg, size = size.small)

//━━━━━━━━━━━━━━━━━━━
// NY open line
//━━━━━━━━━━━━━━━━━━━
if newNYOpen
    if not na(nyOpenLine)
        line.delete(nyOpenLine)
    if not na(nyOpenLbl)
        label.delete(nyOpenLbl)

    if showNYOpen
        nyOpenLine := line.new(bar_index, nyOpenPrice, bar_index + 1, nyOpenPrice, extend = extend.right, color = colNYOpenLine, width = levelWidth, style = line.style_dashed)

        if showLabels
            nyOpenLbl := label.new(bar_index + labelOffset, nyOpenPrice, "New York Open", xloc = xloc.bar_index, style = label.style_label_left, textcolor = colNYOpenText, color = colLabelBg, size = size.small)

//━━━━━━━━━━━━━━━━━━━
// Push labels right every bar
//━━━━━━━━━━━━━━━━━━━
if not na(pdhLbl)
    label.set_x(pdhLbl, bar_index + labelOffset)
if not na(pdlLbl)
    label.set_x(pdlLbl, bar_index + labelOffset)
if not na(h4HighLbl)
    label.set_x(h4HighLbl, bar_index + labelOffset)
if not na(h4LowLbl)
    label.set_x(h4LowLbl, bar_index + labelOffset)
if not na(asiaHighLbl)
    label.set_x(asiaHighLbl, bar_index + labelOffset)
if not na(asiaLowLbl)
    label.set_x(asiaLowLbl, bar_index + labelOffset)
if not na(londonHighLbl)
    label.set_x(londonHighLbl, bar_index + labelOffset)
if not na(londonLowLbl)
    label.set_x(londonLowLbl, bar_index + labelOffset)
if not na(nyOpenLbl)
    label.set_x(nyOpenLbl, bar_index + labelOffset)
````
