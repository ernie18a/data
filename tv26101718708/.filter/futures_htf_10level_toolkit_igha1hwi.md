# Futures HTF 10-Level Toolkit

- url: https://www.tradingview.com/script/IGHA1HWI-Futures-HTF-10-Level-Toolkit/
- type: indicator
- pine_id: PUB;14d3ebc146e349c6b331dce1ed5857ed
- version: 2.0

## Description

SMA 50 on the 1hr, 4hr, and daily
SMA 200 on the 1hr, 4hr, and daily

premarket ORB
9:30-10 ORB

asia ranges.. 
NY AM range

## Source Code

````pine
//@version=6
indicator("Futures HTF 10-Level Toolkit", overlay=true, max_lines_count=500, max_labels_count=500)

// ==========================================
// INPUTS & SETTINGS
// ==========================================
timezone = "America/New_York"

colorPDH     = input.color(color.green,  "PDH/PDL Color")
colorAsia    = input.color(color.aqua,   "Asia High/Low Color")
colorLondon  = input.color(color.orange, "London High/Low Color")
colorPM      = input.color(color.purple, "8:00-8:15 Premarket Range Color")
colorNYOpen  = input.color(color.fuchsia, "NY Open Range Color")

colorSMA1 = input.color(color.gray,   "1H SMA Color")
colorSMA4 = input.color(color.blue,   "4H SMA Color")
colorSMAD = input.color(color.orange, "Daily SMA Color")

showPDH_PDL   = input.bool(true, "Show PDH / PDL")
showAsia      = input.bool(true, "Show Asia High / Low")
showLondon    = input.bool(true, "Show London High / Low")
showPMRange   = input.bool(true, "Show 8:00-8:15 Premarket Range")
showNYOpen    = input.bool(true, "Show NY Open Range 9:30-10:00")
showSMAs      = input.bool(true, "Show HTF 50 / 200 SMAs")

// ==========================================
// HELPER FUNCTIONS
// ==========================================
update_line(levelLine, price, col, lineStyle, width) =>
    line result = levelLine
    if not na(price)
        if na(result)
            result := line.new(bar_index, price, bar_index + 1, price, xloc=xloc.bar_index, extend=extend.right, color=col, style=lineStyle, width=width)
        else
            line.set_y1(result, price)
            line.set_y2(result, price)
            line.set_color(result, col)
            line.set_style(result, lineStyle)
            line.set_width(result, width)
    result

update_label(levelLabel, price, txt, col) =>
    label result = levelLabel
    if not na(price) and barstate.islast
        if na(result)
            result := label.new(bar_index + 5, price, txt, xloc=xloc.bar_index, yloc=yloc.price, color=#00000000, style=label.style_label_left, textcolor=col, size=size.small)
        else
            label.set_x(result, bar_index + 5)
            label.set_y(result, price)
            label.set_text(result, txt)
            label.set_textcolor(result, col)
    result

delete_line(levelLine) =>
    if not na(levelLine)
        line.delete(levelLine)

delete_label(levelLabel) =>
    if not na(levelLabel)
        label.delete(levelLabel)

// ==========================================
// SESSION DETECTION
// ==========================================
newDay = ta.change(time("D", "0000-2359", timezone)) != 0

inRTH     = not na(time(timeframe.period, "0930-1600", timezone))
inAsia    = not na(time(timeframe.period, "1800-0300", timezone))
inLondon  = not na(time(timeframe.period, "0300-0930", timezone))
inPMRange = not na(time(timeframe.period, "0800-0815", timezone))
inNYOpen  = not na(time(timeframe.period, "0930-1000", timezone))

newRTH     = inRTH and not inRTH[1]
endRTH     = not inRTH and inRTH[1]
newAsia    = inAsia and not inAsia[1]
newLondon  = inLondon and not inLondon[1]
newPMRange = inPMRange and not inPMRange[1]
newNYOpen  = inNYOpen and not inNYOpen[1]

// ==========================================
// 1. CORRECTED PDH / PDL
// Previous regular trading session high/low, 9:30-4:00 NY time
// Shows only most recent PDH / PDL as horizontal lines
// ==========================================
var float rthHigh = na
var float rthLow  = na
var float pdh = na
var float pdl = na

var line pdhLine = na
var line pdlLine = na
var label pdhLabel = na
var label pdlLabel = na

if newRTH
    rthHigh := high
    rthLow := low

if inRTH
    rthHigh := math.max(nz(rthHigh, high), high)
    rthLow := math.min(nz(rthLow, low), low)

if endRTH
    pdh := rthHigh
    pdl := rthLow

if showPDH_PDL and not na(pdh)
    pdhLine := update_line(pdhLine, pdh, colorPDH, line.style_solid, 2)
    pdlLine := update_line(pdlLine, pdl, colorPDH, line.style_solid, 2)

    pdhLabel := update_label(pdhLabel, pdh, "PDH", colorPDH)
    pdlLabel := update_label(pdlLabel, pdl, "PDL", colorPDH)


// ==========================================
// 2. ASIA HIGH / LOW
// ==========================================
var float asiaHigh = na
var float asiaLow = na

var line asiaHighLine = na
var line asiaLowLine = na
var label asiaHighLabel = na
var label asiaLowLabel = na

if newAsia
    asiaHigh := high
    asiaLow := low
    delete_line(asiaHighLine)
    delete_line(asiaLowLine)
    delete_label(asiaHighLabel)
    delete_label(asiaLowLabel)
    asiaHighLine := na
    asiaLowLine := na
    asiaHighLabel := na
    asiaLowLabel := na

if inAsia
    asiaHigh := math.max(nz(asiaHigh, high), high)
    asiaLow := math.min(nz(asiaLow, low), low)

if showAsia and not na(asiaHigh)
    asiaHighLine := update_line(asiaHighLine, asiaHigh, colorAsia, line.style_solid, 1)
    asiaLowLine := update_line(asiaLowLine, asiaLow, colorAsia, line.style_solid, 1)
    asiaHighLabel := update_label(asiaHighLabel, asiaHigh, "Asia High", colorAsia)
    asiaLowLabel := update_label(asiaLowLabel, asiaLow, "Asia Low", colorAsia)

// ==========================================
// 3. LONDON HIGH / LOW
// ==========================================
var float londonHigh = na
var float londonLow = na

var line londonHighLine = na
var line londonLowLine = na
var label londonHighLabel = na
var label londonLowLabel = na

if newLondon
    londonHigh := high
    londonLow := low
    delete_line(londonHighLine)
    delete_line(londonLowLine)
    delete_label(londonHighLabel)
    delete_label(londonLowLabel)
    londonHighLine := na
    londonLowLine := na
    londonHighLabel := na
    londonLowLabel := na

if inLondon
    londonHigh := math.max(nz(londonHigh, high), high)
    londonLow := math.min(nz(londonLow, low), low)

if showLondon and not na(londonHigh)
    londonHighLine := update_line(londonHighLine, londonHigh, colorLondon, line.style_solid, 1)
    londonLowLine := update_line(londonLowLine, londonLow, colorLondon, line.style_solid, 1)
    londonHighLabel := update_label(londonHighLabel, londonHigh, "London High", colorLondon)
    londonLowLabel := update_label(londonLowLabel, londonLow, "London Low", colorLondon)

// ==========================================
// 4. CURRENT-DAY 8:00-8:15 PREMARKET RANGE
// Old premarket lines are removed at the start of each day
// ==========================================
var float pmHigh = na
var float pmLow = na

var line pmHighLine = na
var line pmLowLine = na
var label pmHighLabel = na
var label pmLowLabel = na

if newDay
    delete_line(pmHighLine)
    delete_line(pmLowLine)
    delete_label(pmHighLabel)
    delete_label(pmLowLabel)
    pmHighLine := na
    pmLowLine := na
    pmHighLabel := na
    pmLowLabel := na
    pmHigh := na
    pmLow := na

if newPMRange
    pmHigh := high
    pmLow := low

if inPMRange
    pmHigh := math.max(nz(pmHigh, high), high)
    pmLow := math.min(nz(pmLow, low), low)

if showPMRange and not na(pmHigh)
    pmHighLine := update_line(pmHighLine, pmHigh, colorPM, line.style_dashed, 2)
    pmLowLine := update_line(pmLowLine, pmLow, colorPM, line.style_dashed, 2)
    pmHighLabel := update_label(pmHighLabel, pmHigh, "8:00 AM High", colorPM)
    pmLowLabel := update_label(pmLowLabel, pmLow, "8:15 AM Low", colorPM)

// ==========================================
// 5. NY OPEN RANGE 9:30-10:00
// ==========================================
var float nyOpenHigh = na
var float nyOpenLow = na

var line nyOpenHighLine = na
var line nyOpenLowLine = na
var label nyOpenHighLabel = na
var label nyOpenLowLabel = na

if newNYOpen
    nyOpenHigh := high
    nyOpenLow := low
    delete_line(nyOpenHighLine)
    delete_line(nyOpenLowLine)
    delete_label(nyOpenHighLabel)
    delete_label(nyOpenLowLabel)
    nyOpenHighLine := na
    nyOpenLowLine := na
    nyOpenHighLabel := na
    nyOpenLowLabel := na

if inNYOpen
    nyOpenHigh := math.max(nz(nyOpenHigh, high), high)
    nyOpenLow := math.min(nz(nyOpenLow, low), low)

if showNYOpen and not na(nyOpenHigh)
    nyOpenHighLine := update_line(nyOpenHighLine, nyOpenHigh, colorNYOpen, line.style_solid, 2)
    nyOpenLowLine := update_line(nyOpenLowLine, nyOpenLow, colorNYOpen, line.style_solid, 2)
    nyOpenHighLabel := update_label(nyOpenHighLabel, nyOpenHigh, "NY Open High", colorNYOpen)
    nyOpenLowLabel := update_label(nyOpenLowLabel, nyOpenLow, "NY Open Low", colorNYOpen)

// ==========================================
// ==========================================
// 6. HTF SMAs: 1H, 4H, DAILY
// Horizontal line + right-side label style
// ==========================================
s50_1h  = request.security(syminfo.tickerid, "60",  ta.sma(close, 50),  barmerge.gaps_off, barmerge.lookahead_off)
s200_1h = request.security(syminfo.tickerid, "60",  ta.sma(close, 200), barmerge.gaps_off, barmerge.lookahead_off)

s50_4h  = request.security(syminfo.tickerid, "240", ta.sma(close, 50),  barmerge.gaps_off, barmerge.lookahead_off)
s200_4h = request.security(syminfo.tickerid, "240", ta.sma(close, 200), barmerge.gaps_off, barmerge.lookahead_off)

s50_D   = request.security(syminfo.tickerid, "D",   ta.sma(close, 50),  barmerge.gaps_off, barmerge.lookahead_off)
s200_D  = request.security(syminfo.tickerid, "D",   ta.sma(close, 200), barmerge.gaps_off, barmerge.lookahead_off)

var line s50_1h_line = na
var line s200_1h_line = na
var line s50_4h_line = na
var line s200_4h_line = na
var line s50_D_line = na
var line s200_D_line = na

var label s50_1h_label = na
var label s200_1h_label = na
var label s50_4h_label = na
var label s200_4h_label = na
var label s50_D_label = na
var label s200_D_label = na

if showSMAs
    s50_1h_line := update_line(s50_1h_line, s50_1h, colorSMA1, line.style_solid, 1)
    s200_1h_line := update_line(s200_1h_line, s200_1h, color.purple, line.style_solid, 1)

    s50_4h_line := update_line(s50_4h_line, s50_4h, colorSMA4, line.style_solid, 1)
    s200_4h_line := update_line(s200_4h_line, s200_4h, color.navy, line.style_solid, 1)

    s50_D_line := update_line(s50_D_line, s50_D, color.yellow, line.style_solid, 1)
    s200_D_line := update_line(s200_D_line, s200_D, colorSMAD, line.style_solid, 1)

    s50_1h_label := update_label(s50_1h_label, s50_1h, "1H 50 SMA", colorSMA1)
    s200_1h_label := update_label(s200_1h_label, s200_1h, "1H 200 SMA", color.purple)

    s50_4h_label := update_label(s50_4h_label, s50_4h, "4H 50 SMA", colorSMA4)
    s200_4h_label := update_label(s200_4h_label, s200_4h, "4H 200 SMA", color.navy)

    s50_D_label := update_label(s50_D_label, s50_D, "D 50 SMA", color.yellow)
    s200_D_label := update_label(s200_D_label, s200_D, "D 200 SMA", colorSMAD)
````
