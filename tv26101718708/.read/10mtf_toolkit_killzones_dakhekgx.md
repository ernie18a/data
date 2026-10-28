# 10-MTF Toolkit + Killzones

- url: https://www.tradingview.com/script/DaKhEKgX-10-MTF-Toolkit-Killzones/
- type: indicator
- pine_id: PUB;e13d25b03c6a4acdb7e00843fb0e8d72
- version: 1.0

## Description

PDL/PDH
London high/low
Asia high/low
ORB
pre-market ORB

200 SMA 1hr, 4hr, daily levels
50 SMA 1hr, 4hr, daily levels

Asia, London, NY AM, and NY PM killzones

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

sessionAsiaColor   = input.color(color.new(color.aqua, 85), "Asia Kill Zone Color")
sessionLondonColor = input.color(color.new(color.aqua, 85), "London Kill Zone Color")
sessionNYAMColor   = input.color(color.new(color.orange, 85), "NY AM Kill Zone Color")
sessionNYPMColor   = input.color(color.new(color.blue, 85), "NY PM Kill Zone Color")

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

// ==========================================
// 7. KILL ZONE BOXES
// ==========================================

// ---------- SESSION TIMES ----------
inAsiaKZ   = not na(time(timeframe.period, "2100-0100", timezone))
inLondonKZ = not na(time(timeframe.period, "0300-0600", timezone))
inNYAMKZ   = not na(time(timeframe.period, "0930-1200", timezone))
inNYPMKZ   = not na(time(timeframe.period, "1430-1600", timezone))

newAsiaKZ   = inAsiaKZ and not inAsiaKZ[1]
newLondonKZ = inLondonKZ and not inLondonKZ[1]
newNYAMKZ   = inNYAMKZ and not inNYAMKZ[1]
newNYPMKZ   = inNYPMKZ and not inNYPMKZ[1]

// ---------- ASIA ----------
var box asiaBox = na
var label asiaLbl = na
var line asiaHighLineKZ = na
var line asiaLowLineKZ = na
var float asiaHighKZ = na
var float asiaLowKZ = na

if newAsiaKZ

    box.delete(asiaBox)
    line.delete(asiaHighLineKZ)
    line.delete(asiaLowLineKZ)
    label.delete(asiaLbl)

    asiaHighKZ := high
    asiaLowKZ := low

    asiaBox := box.new(bar_index, high, bar_index, low,
         bgcolor=sessionAsiaColor,
         border_color=color.aqua)

    asiaLbl := label.new(bar_index, high,
         "Asian",
         style=label.style_none,
         textcolor=color.aqua)

if inAsiaKZ

    asiaHighKZ := math.max(nz(asiaHighKZ, high), high)
    asiaLowKZ := math.min(nz(asiaLowKZ, low), low)

    box.set_right(asiaBox, bar_index)
    box.set_top(asiaBox, asiaHighKZ)
    box.set_bottom(asiaBox, asiaLowKZ)

    label.set_x(asiaLbl,
         math.floor((box.get_left(asiaBox)+bar_index)/2))
    label.set_y(asiaLbl, asiaHighKZ)

if not inAsiaKZ and inAsiaKZ[1]

    asiaHighLineKZ := line.new(
         bar_index,
         asiaHighKZ,
         bar_index+1,
         asiaHighKZ,
         extend=extend.right,
         color=color.aqua)

    asiaLowLineKZ := line.new(
         bar_index,
         asiaLowKZ,
         bar_index+1,
         asiaLowKZ,
         extend=extend.right,
         color=color.aqua
       )


// ---------- LONDON ----------
var box londonBoxKZ = na
var label londonLbl = na
var line londonHighLineKZ = na
var line londonLowLineKZ = na
var float londonHighKZ = na
var float londonLowKZ = na

if newLondonKZ

    box.delete(londonBoxKZ)
    line.delete(londonHighLineKZ)
    line.delete(londonLowLineKZ)
    label.delete(londonLbl)

    londonHighKZ := high
    londonLowKZ := low

    londonBoxKZ := box.new(bar_index, high, bar_index, low,
         bgcolor=sessionLondonColor,
         border_color=color.aqua)

    londonLbl := label.new(bar_index, high,
         "London",
         style=label.style_none,
         textcolor=color.aqua)

if inLondonKZ

    londonHighKZ := math.max(nz(londonHighKZ, high), high)
    londonLowKZ := math.min(nz(londonLowKZ, low), low)

    box.set_right(londonBoxKZ, bar_index)
    box.set_top(londonBoxKZ, londonHighKZ)
    box.set_bottom(londonBoxKZ, londonLowKZ)

    label.set_x(londonLbl,
         math.floor((box.get_left(londonBoxKZ)+bar_index)/2))
    label.set_y(londonLbl, londonHighKZ)

if not inLondonKZ and inLondonKZ[1]

    londonHighLineKZ := line.new(
         bar_index,
         londonHighKZ,
         bar_index+1,
         londonHighKZ,
         extend=extend.right,
         color=color.aqua)

    londonLowLineKZ := line.new(
         bar_index,
         londonLowKZ,
         bar_index+1,
         londonLowKZ,
         extend=extend.right,
         color=color.aqua)


// ---------- NY AM ----------
var box nyAMBox = na
var label nyAMLbl = na
var line nyAMHighLine = na
var line nyAMLowLine = na
var float nyAMHigh = na
var float nyAMLow = na

if newNYAMKZ

    box.delete(nyAMBox)
    line.delete(nyAMHighLine)
    line.delete(nyAMLowLine)
    label.delete(nyAMLbl)

    nyAMHigh := high
    nyAMLow := low

    nyAMBox := box.new(bar_index, high, bar_index, low,
         bgcolor=sessionNYAMColor,
         border_color=color.orange)

    nyAMLbl := label.new(bar_index, high,
         "New York AM",
         style=label.style_none,
         textcolor=color.orange)

if inNYAMKZ

    nyAMHigh := math.max(nz(nyAMHigh, high), high)
    nyAMLow := math.min(nz(nyAMLow, low), low)

    box.set_right(nyAMBox, bar_index)
    box.set_top(nyAMBox, nyAMHigh)
    box.set_bottom(nyAMBox, nyAMLow)

    label.set_x(nyAMLbl,
         math.floor((box.get_left(nyAMBox)+bar_index)/2))
    label.set_y(nyAMLbl, nyAMHigh)

if not inNYAMKZ and inNYAMKZ[1]

    nyAMHighLine := line.new(
         bar_index,
         nyAMHigh,
         bar_index+1,
         nyAMHigh,
         extend=extend.right,
         color=color.orange)

    nyAMLowLine := line.new(
         bar_index,
         nyAMLow,
         bar_index+1,
         nyAMLow,
         extend=extend.right,
         color=color.orange)


// ---------- NY PM ----------
var box nyPMBox = na
var label nyPMLbl = na
var line nyPMHighLine = na
var line nyPMLowLine = na
var float nyPMHigh = na
var float nyPMLow = na

if newNYPMKZ

    box.delete(nyPMBox)
    line.delete(nyPMHighLine)
    line.delete(nyPMLowLine)
    label.delete(nyPMLbl)

    nyPMHigh := high
    nyPMLow := low

    nyPMBox := box.new(bar_index, high, bar_index, low,
         bgcolor=sessionNYPMColor,
         border_color=color.blue)

    nyPMLbl := label.new(bar_index, high,
         "New York PM",
         style=label.style_none,
         textcolor=color.blue)

if inNYPMKZ

    nyPMHigh := math.max(nz(nyPMHigh, high), high)
    nyPMLow := math.min(nz(nyPMLow, low), low)

    box.set_right(nyPMBox, bar_index)
    box.set_top(nyPMBox, nyPMHigh)
    box.set_bottom(nyPMBox, nyPMLow)

    label.set_x(nyPMLbl,
         math.floor((box.get_left(nyPMBox)+bar_index)/2))
    label.set_y(nyPMLbl, nyPMHigh)

if not inNYPMKZ and inNYPMKZ[1]

    nyPMHighLine := line.new(
         bar_index,
         nyPMHigh,
         bar_index+1,
         nyPMHigh,
         extend=extend.right,
         color=color.blue)

    nyPMLowLine := line.new(
         bar_index,
         nyPMLow,
         bar_index+1,
         nyPMLow,
         extend=extend.right,
         color=color.blue)
````
