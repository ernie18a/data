# Overnight Range & Sessions - Multi-Index

- url: https://www.tradingview.com/script/IziqgoZV/
- type: indicator
- pine_id: PUB;ba8f48673c2642cb85a4dde654317ab8
- version: 1.0

## Description

Draws the overnight range (ONR) of the instrument's own overnight session —
not a generic fixed window — plus EU/US/Asia session boxes and the previous
day's cash close as a gap reference.

What makes it original: generic session tools apply one fixed overnight
window to everything. This one carries per-instrument overnight definitions
(indices, metals, oil, forex), supports fragmented quiet-phase sessions for
24h markets, detects US/EU DST shifts automatically from the Berlin-New York
time difference, and captures the cash close timeframe-independently so the
gap reference works on any chart resolution.

How it works:
- The overnight window is auto-selected per instrument (DAX, FTSE, US indices,
  Russell, gold, silver, copper, oil, Nikkei, HK, forex) with a manual
  override and a custom session input.
- Commodities/forex can use fragmented sessions: several small quiet-phase
  boxes instead of one large overnight range.
- US/EU daylight-saving shifts are detected automatically from the
  Berlin-New York time difference (manual override available).
- An info table shows the detected index, session window and mode; the
  previous day cash close is drawn as a line for gap-up/gap-down context.

How to use it: before the cash open, read the overnight high/low as the first
breakout frame of the day — a cash-session break out of the ONR sets the
directional tone, while repeated rejections at the ONR edges frame fade
setups back into the range. Combine with the previous cash close line for gap
context (open above both ONR high and prior close is a very different day
than an open inside the range), and use the session boxes to see which region
built the current move.

## Source Code

````pine
//@version=6
indicator("Overnight Range & Sessions — Multi-Index", shorttitle="ONR Sessions", overlay=true, max_boxes_count=500, max_labels_count=500, max_lines_count=500)
// === TIMEZONE & DAYLIGHT SAVING ===
// auto-detection of the DST gap between EU and US
dstMode = input.string('Auto', 'DST mode', options=['Auto', 'Manual'], group='Timezone & DST', tooltip='Auto = detects the US/EU DST shift automatically from the Berlin-NY time difference')
manualEUDST = input.bool(true, 'EU summer time (CET→CEST)', group='Timezone & DST', tooltip='Manual mode only: is the EU currently on summer time?')
manualUSDST = input.bool(true, 'US summer time (EST→EDT)', group='Timezone & DST', tooltip='Manual mode only: is the US currently on summer time?')
// === INPUTS ===
manualOverride = input.bool(false, "Manual index selection", group="Index selection")
manualPreset = input.string("DAX", "Manual index", options=["DAX","FTSE","US","Russell","Gold","Silver","Copper","Oil","Nikkei","HK","Forex","Custom"], group="Index selection")
customSession = input.session("1730-0859", "Custom overnight", group="Index selection")
// === FRAGMENTIERTE SESSIONS ===
useFragmented = input.bool(true, "Fragmented sessions (forex/commodities)", group="Session mode", tooltip="Several small boxes for quiet phases instead of one large overnight range")
// === SESSION BOXEN ===
showSessionBoxes = input.bool(true, "Show session boxes", group="Session boxes")
showEuSession    = input.bool(true, "EU Session", group="Session boxes")
showUsSession    = input.bool(true, "US Session", group="Session boxes")
showAsiaSession  = input.bool(true, "Asia Session", group="Session boxes")
euSessionTime    = input.session("0900-1730", "EU session time", group="Session boxes")
asiaSessionTime  = input.session("0100-0900", "Asia session time", group="Session boxes")
euSessColor      = input.color(color.new(color.blue, 85), "EU color", group="Session boxes")
usSessColor      = input.color(color.new(color.red, 85), "US color", group="Session boxes")
asiaSessColor    = input.color(color.new(color.yellow, 85), "Asia color", group="Session boxes")
euBorderCol      = input.color(color.new(color.blue, 50), "EU border", group="Session boxes")
usBorderCol      = input.color(color.new(color.red, 50), "US border", group="Session boxes")
asiaBorderCol    = input.color(color.new(color.yellow, 50), "Asia border", group="Session boxes")
sessBorderWidth  = input.int(1, "Session border width", 1, 3, group="Session boxes")
sessFrameOnly    = input.bool(true, "Frame only (no fill)", group="Session boxes")
showSessLabels   = input.bool(true, "Session labels", group="Session boxes")
// === VISUALS ===
tz = input.string("Europe/Berlin", "Timezone", group="Timezone & DST")

// === AUTO DST-ERKENNUNG ===
// Berlin-NY difference: 6h=both equal, 5h=US summer/EU winter(-1), 7h=EU summer/US winter(+1)
f_autoUSDSTShift() =>
    berlinH = hour(time, "Europe/Berlin")
    nyH     = hour(time, "America/New_York")
    diff    = (berlinH - nyH + 24) % 24
    diff == 5 ? -1 : diff == 7 ? 1 : 0

f_manualUSDSTShift() =>
    if manualUSDST and not manualEUDST
        -1   // US summer, EU winter -> US times 1h earlier
    else if not manualUSDST and manualEUDST
        1    // EU summer, US winter -> US times 1h later
    else
        0    // both equal -> no shift

usDSTShift = dstMode == 'Auto' ? f_autoUSDSTShift() : f_manualUSDSTShift()
f_usHour(h) => int((h + usDSTShift + 24) % 24)
f_pad2(n) => n < 10 ? "0" + str.tostring(n) : str.tostring(n)

// US Session Box Zeit (dynamisch berechnet statt Input)
usSessionTime = f_pad2(f_usHour(15)) + "30-" + f_pad2(f_usHour(22)) + "00"

fillCol = input.color(color.new(color.aqua, 70), "Fill color", group="Display")
borderCol = input.color(color.aqua, "Border color", group="Display")
borderWidth = input.int(2, "Border width", 1, 5, group="Display")
keepN = input.int(60, "Keep N ranges", 1, 200, group="Display")
showLabels = input.bool(true, "Show labels", group="Display")
showDebug = input.bool(false, "Show Debug Info", group="Display")
// === AUTO-DETECTION ===
detectIndex() =>
    sym = syminfo.ticker
    symL = str.lower(sym)
    isGold = str.contains(symL, "xauusd") or str.contains(symL, "xau") or str.contains(symL, "gold") or (str.contains(symL, "gc") and not str.contains(symL, "agc"))
    isSilver = str.contains(symL, "xagusd") or str.contains(symL, "xag") or str.contains(symL, "silver")
    isCopper = str.contains(symL, "copper") or str.contains(symL, "xcuusd") or str.contains(symL, "hg1")
    isOil = str.contains(symL, "wti") or str.contains(symL, "crude") or str.contains(symL, "brent") or str.contains(symL, "ukoil") or str.contains(symL, "usoil") or str.contains(symL, "oil") or str.contains(symL, "natgas") or str.contains(symL, "ngas") or str.contains(symL, "naturalgas") or str.contains(symL, "xng") or str.contains(symL, "gas")
    isNikkei = str.contains(symL, "nikkei") or str.contains(symL, "ni225") or str.contains(symL, "jpn225") or str.contains(symL, "japan225") or str.contains(symL, "jp225") or str.contains(symL, "nk225")
    isHK = str.contains(symL, "hsi") or str.contains(symL, "hangseng") or str.contains(symL, "hk50") or str.contains(symL, "hkg33") or str.contains(symL, "hongkong")
    isRUT = str.contains(symL, "rut") or str.contains(symL, "rty") or str.contains(symL, "us2000") or str.contains(symL, "iwm") or str.contains(symL, "russell")
    isUS = str.contains(symL, "spx") or str.contains(symL, "sp500") or str.contains(symL, "spy") or str.contains(symL, "^spx") or str.contains(symL, "mes") or str.contains(symL, "nasdaq") or str.contains(symL, "ndx") or str.contains(symL, "qqq") or str.contains(symL, "nas100") or str.contains(symL, "us100") or str.contains(symL, "dji") or str.contains(symL, "djia") or str.contains(symL, "ym") or str.contains(symL, "us30") or str.contains(symL, "dia") or str.contains(symL, "us500") or str.contains(symL, "spx500")
    isDAX = str.contains(symL, "dax") or str.contains(symL, "de40") or str.contains(symL, "ger40") or str.contains(symL, "fdax")
    isFTSE = str.contains(symL, "ftse") or str.contains(symL, "uk100") or str.contains(symL, "ukx")
    isForex = (str.contains(symL, "eur") or str.contains(symL, "gbp") or str.contains(symL, "jpy") or str.contains(symL, "aud") or str.contains(symL, "nzd") or str.contains(symL, "cad") or str.contains(symL, "chf") or str.contains(symL, "usd")) and not isGold and not isSilver and not isCopper and not isOil
    if isNikkei
        "Nikkei"
    else if isHK
        "HK"
    else if isGold
        "Gold"
    else if isSilver
        "Silver"
    else if isCopper
        "Copper"
    else if isOil
        "Oil"
    else if isRUT
        "Russell"
    else if isUS
        "US"
    else if isDAX
        "DAX"
    else if isFTSE
        "FTSE"
    else if isForex
        "Forex"
    else
        "DAX"
selectedIndex = manualOverride ? manualPreset : detectIndex()
// === CHECK WHETHER FRAGMENTED MODE MAKES SENSE ===
isFragmentedType = selectedIndex == "Forex" or selectedIndex == "Gold" or selectedIndex == "Silver" or selectedIndex == "Copper"
useFragmentedSessions = useFragmented and isFragmentedType
// === STANDARD SESSION SETUP ===
usOvernightStart = f_pad2(f_usHour(22)) + "00"
usOvernightEnd   = f_pad2(f_usHour(15)) + "29"
usSession = usOvernightStart + "-" + usOvernightEnd
standardSession = selectedIndex == "FTSE" ? "1830-0900" :
     selectedIndex == "US" or selectedIndex == "Russell" ? usSession :
     selectedIndex == "Oil" ? usSession :
     selectedIndex == "Nikkei" ? "0730-0059" :
     selectedIndex == "HK" ? "0800-0129" :
     selectedIndex == "Custom" ? customSession :
     selectedIndex == "Gold" and not useFragmentedSessions ? usSession :
     selectedIndex == "Silver" and not useFragmentedSessions ? usSession :
     selectedIndex == "Copper" and not useFragmentedSessions ? usSession :
     selectedIndex == "Forex" and not useFragmentedSessions ? (f_pad2(f_usHour(22)) + "00-0759") :
     "1730-0859"
// === FRAGMENTIERTE SESSION DEFINITIONEN ===
forex_session1  = f_pad2(f_usHour(22)) + "00-2359"
forex_session2  = "0500-0759"
gold_session1   = f_pad2(f_usHour(22)) + "00-0129"
gold_session2   = "1030-1359"
silver_session1 = f_pad2(f_usHour(22)) + "00-0129"
silver_session2 = "1030-1359"
copper_session1 = f_pad2(f_usHour(22)) + "00-0059"
copper_session2 = "1000-1359"
// === SESSION FLAGS - STANDARD ===
inStandardONR = not useFragmentedSessions and not na(time(timeframe.period, standardSession, tz))
startStandardONR = inStandardONR and not inStandardONR[1]
endStandardONR = not inStandardONR and inStandardONR[1]
// === SESSION FLAGS - FRAGMENTIERT ===
inForex1 = useFragmentedSessions and selectedIndex == "Forex" and not na(time(timeframe.period, forex_session1, tz))
inForex2 = useFragmentedSessions and selectedIndex == "Forex" and not na(time(timeframe.period, forex_session2, tz))
startForex1 = inForex1 and not inForex1[1]
startForex2 = inForex2 and not inForex2[1]
endForex1 = not inForex1 and inForex1[1]
endForex2 = not inForex2 and inForex2[1]
inGold1 = useFragmentedSessions and selectedIndex == "Gold" and not na(time(timeframe.period, gold_session1, tz))
inGold2 = useFragmentedSessions and selectedIndex == "Gold" and not na(time(timeframe.period, gold_session2, tz))
startGold1 = inGold1 and not inGold1[1]
startGold2 = inGold2 and not inGold2[1]
endGold1 = not inGold1 and inGold1[1]
endGold2 = not inGold2 and inGold2[1]
inSilver1 = useFragmentedSessions and selectedIndex == "Silver" and not na(time(timeframe.period, silver_session1, tz))
inSilver2 = useFragmentedSessions and selectedIndex == "Silver" and not na(time(timeframe.period, silver_session2, tz))
startSilver1 = inSilver1 and not inSilver1[1]
startSilver2 = inSilver2 and not inSilver2[1]
endSilver1 = not inSilver1 and inSilver1[1]
endSilver2 = not inSilver2 and inSilver2[1]
inCopper1 = useFragmentedSessions and selectedIndex == "Copper" and not na(time(timeframe.period, copper_session1, tz))
inCopper2 = useFragmentedSessions and selectedIndex == "Copper" and not na(time(timeframe.period, copper_session2, tz))
startCopper1 = inCopper1 and not inCopper1[1]
startCopper2 = inCopper2 and not inCopper2[1]
endCopper1 = not inCopper1 and inCopper1[1]
endCopper2 = not inCopper2 and inCopper2[1]
// === KOMBINIERTE FLAGS ===
inAnyFragmented = inForex1 or inForex2 or inGold1 or inGold2 or inSilver1 or inSilver2 or inCopper1 or inCopper2
startAnyFragmented = startForex1 or startForex2 or startGold1 or startGold2 or startSilver1 or startSilver2 or startCopper1 or startCopper2
endAnyFragmented = endForex1 or endForex2 or endGold1 or endGold2 or endSilver1 or endSilver2 or endCopper1 or endCopper2
inONR = inStandardONR or inAnyFragmented
startONR = startStandardONR or startAnyFragmented
endONR = endStandardONR or endAnyFragmented
// === ONR RANGE TRACKING ===
var float h = na
var float l = na
var int leftTime = na
var int rightTime = na
var string currentSessionName = na
getSessionName() =>
    if startStandardONR
        selectedIndex + " ONR"
    else if startForex1
        "FX NY-Wind"
    else if startForex2
        "FX Pre-London"
    else if startGold1
        "Gold NY-Asia"
    else if startGold2
        "Gold EU-Lunch"
    else if startSilver1
        "Silver NY-Asia"
    else if startSilver2
        "Silver EU-Lunch"
    else if startCopper1
        "Copper NY-Asia"
    else if startCopper2
        "Copper EU-Lunch"
    else
        selectedIndex + " ONR"
if startONR
    h := high
    l := low
    leftTime := time
    rightTime := time
    currentSessionName := getSessionName()
if inONR
    h := math.max(nz(h, high), high)
    l := math.min(nz(l, low), low)
    rightTime := time
// === STORAGE ===
var array<box> boxes = array.new<box>()
var array<label> labels = array.new<label>()
// === FARBEN PRO SESSION ===
getSessionColor(sess) =>
    if str.contains(sess, "FX") or str.contains(sess, "Forex")
        color.purple
    else if str.contains(sess, "Gold")
        color.orange
    else if str.contains(sess, "Silver") or str.contains(sess, "Silver")
        color.silver
    else if str.contains(sess, "Copper") or str.contains(sess, "Copper")
        color.rgb(184, 115, 51)
    else if str.contains(sess, "Oil") or str.contains(sess, "Oil")
        color.rgb(50, 50, 50)
    else if str.contains(sess, "DAX") or str.contains(sess, "FTSE")
        color.aqua
    else if str.contains(sess, "US") or str.contains(sess, "Russell")
        color.rgb(255, 100, 100)
    else if str.contains(sess, "Nikkei") or str.contains(sess, "HK")
        color.rgb(255, 200, 100)
    else
        borderCol
// === ONR BOX ERSTELLEN ===
if endONR and not na(leftTime) and not na(rightTime) and not na(h) and not na(l) and not na(currentSessionName)
    sessColor = useFragmentedSessions ? getSessionColor(currentSessionName) : borderCol
    sessFill = useFragmentedSessions ? color.new(sessColor, 80) : fillCol
    b = box.new(leftTime, h, rightTime, l, xloc=xloc.bar_time, border_color=sessColor, bgcolor=sessFill, border_width=borderWidth)
    array.push(boxes, b)
    if showLabels
        lblTxt = currentSessionName + "\nH: " + str.tostring(h, format.mintick) + "\nL: " + str.tostring(l, format.mintick)
        lbl = label.new(rightTime, h, lblTxt, xloc=xloc.bar_time, style=label.style_label_down, color=sessColor, textcolor=color.white, size=size.small)
        array.push(labels, lbl)
    while array.size(boxes) > keepN
        box.delete(array.shift(boxes))
    while array.size(labels) > keepN
        label.delete(array.shift(labels))
    h := na
    l := na
    leftTime := na
    rightTime := na
    currentSessionName := na
// ============================================================
//  SESSION BOXEN (EU / US / ASIA)
// ============================================================
// EU Session
inEU = showSessionBoxes and showEuSession and not na(time(timeframe.period, euSessionTime, tz))
startEU = inEU and not inEU[1]
endEU = not inEU and inEU[1]
var float euH = na, var float euL = na
var int euLeft = na, var int euRight = na
if startEU
    euH := high, euL := low, euLeft := time, euRight := time
if inEU
    euH := math.max(nz(euH, high), high)
    euL := math.min(nz(euL, low), low)
    euRight := time
var array<box> euBoxes = array.new<box>()
var array<label> euLabels = array.new<label>()
if endEU and not na(euLeft) and not na(euH) and not na(euL)
    b = box.new(euLeft, euH, euRight, euL, xloc=xloc.bar_time, border_color=euBorderCol, bgcolor=sessFrameOnly ? color.new(color.white, 100) : euSessColor, border_width=sessBorderWidth)
    array.push(euBoxes, b)
    if showSessLabels
        lbl = label.new(euRight, euH, "EU Session\nH: " + str.tostring(euH, format.mintick) + "\nL: " + str.tostring(euL, format.mintick), xloc=xloc.bar_time, style=label.style_label_down, color=euBorderCol, textcolor=color.white, size=size.tiny)
        array.push(euLabels, lbl)
    while array.size(euBoxes) > keepN
        box.delete(array.shift(euBoxes))
    while array.size(euLabels) > keepN
        label.delete(array.shift(euLabels))
    euH := na, euL := na, euLeft := na
// US Session
inUS = showSessionBoxes and showUsSession and not na(time(timeframe.period, usSessionTime, tz))
startUS = inUS and not inUS[1]
endUS = not inUS and inUS[1]
var float usH = na, var float usL = na
var int usLeft = na, var int usRight = na
if startUS
    usH := high, usL := low, usLeft := time, usRight := time
if inUS
    usH := math.max(nz(usH, high), high)
    usL := math.min(nz(usL, low), low)
    usRight := time
var array<box> usBoxes = array.new<box>()
var array<label> usLabels = array.new<label>()
if endUS and not na(usLeft) and not na(usH) and not na(usL)
    b = box.new(usLeft, usH, usRight, usL, xloc=xloc.bar_time, border_color=usBorderCol, bgcolor=sessFrameOnly ? color.new(color.white, 100) : usSessColor, border_width=sessBorderWidth)
    array.push(usBoxes, b)
    if showSessLabels
        lbl = label.new(usRight, usH, "US Session\nH: " + str.tostring(usH, format.mintick) + "\nL: " + str.tostring(usL, format.mintick), xloc=xloc.bar_time, style=label.style_label_down, color=usBorderCol, textcolor=color.white, size=size.tiny)
        array.push(usLabels, lbl)
    while array.size(usBoxes) > keepN
        box.delete(array.shift(usBoxes))
    while array.size(usLabels) > keepN
        label.delete(array.shift(usLabels))
    usH := na, usL := na, usLeft := na
// Asia Session
inAsia = showSessionBoxes and showAsiaSession and not na(time(timeframe.period, asiaSessionTime, tz))
startAsia = inAsia and not inAsia[1]
endAsia = not inAsia and inAsia[1]
var float asH = na, var float asL = na
var int asLeft = na, var int asRight = na
if startAsia
    asH := high, asL := low, asLeft := time, asRight := time
if inAsia
    asH := math.max(nz(asH, high), high)
    asL := math.min(nz(asL, low), low)
    asRight := time
var array<box> asBoxes = array.new<box>()
var array<label> asLabels = array.new<label>()
if endAsia and not na(asLeft) and not na(asH) and not na(asL)
    b = box.new(asLeft, asH, asRight, asL, xloc=xloc.bar_time, border_color=asiaBorderCol, bgcolor=sessFrameOnly ? color.new(color.white, 100) : asiaSessColor, border_width=sessBorderWidth)
    array.push(asBoxes, b)
    if showSessLabels
        lbl = label.new(asRight, asH, "Asia Session\nH: " + str.tostring(asH, format.mintick) + "\nL: " + str.tostring(asL, format.mintick), xloc=xloc.bar_time, style=label.style_label_down, color=asiaBorderCol, textcolor=color.white, size=size.tiny)
        array.push(asLabels, lbl)
    while array.size(asBoxes) > keepN
        box.delete(array.shift(asBoxes))
    while array.size(asLabels) > keepN
        label.delete(array.shift(asLabels))
    asH := na, asL := na, asLeft := na
// ============================================================
//  GAP REFERENCE: PREVIOUS DAY CASH CLOSE (PDC)
//  The cash-session close drawn as a line into the following day —
//  reference level for gap-up/-down and gap fill (fill = touch of the line).
// ============================================================
showPrevClose = input.bool(true, "Show previous day close (gap reference)", group="Gap reference")
pdcColor      = input.color(color.new(color.white, 25), "PDC color", group="Gap reference")
pdcWidth      = input.int(1, "PDC line width", 1, 3, group="Gap reference")
showPdcLabel  = input.bool(true, "PDC label", group="Gap reference")

// cash session per index type (independent of the session-box toggles):
// US types -> US cash end, otherwise EU cash end (DAX/FTSE standard)
pdcUseUS   = selectedIndex == "US" or selectedIndex == "Russell" or selectedIndex == "Oil"
pdcSession = pdcUseUS ? usSessionTime : euSessionTime

// capture TIMEFRAME-INDEPENDENTLY on a fixed 15m resolution via security —
// on the chart TF the session detection fails on H1+ (candles do not end at
// the cash close) and breaks completely on H4/daily.
f_pdcCapture() =>
    inS  = not na(time(timeframe.period, pdcSession, tz))
    endS = not inS and inS[1]
    var float pdcV = na
    var int   pdcT = na
    if endS
        pdcV := close[1]
        pdcT := time
    [pdcV, pdcT]

[pdcVal, pdcTime] = request.security(syminfo.tickerid, "15", f_pdcCapture(), lookahead=barmerge.lookahead_off)

// PLOT instead of line objects: draws on EVERY historical bar — during day D
// the close of day D-1 automatically sits in the chart as a level (also
// retroactively across the whole history, for gap-fill review).
// At the day change the line is broken via na (no staircase jump).
pdcJump = not na(pdcVal[1]) and pdcVal != pdcVal[1]
pdcPlotVal = showPrevClose ? (pdcJump ? na : pdcVal) : na
plot(pdcPlotVal, "PDC (previous day cash close)", color=pdcColor, linewidth=pdcWidth, style=plot.style_linebr)

// one small label per day change (can be disabled)
var array<label> pdcLabels = array.new<label>()
if showPrevClose and showPdcLabel and pdcJump
    pdcLbl = label.new(time, pdcVal, "PDC " + str.tostring(pdcVal, format.mintick), xloc=xloc.bar_time, style=label.style_label_left, color=color.new(color.black, 100), textcolor=pdcColor, size=size.tiny)
    array.push(pdcLabels, pdcLbl)
    while array.size(pdcLabels) > keepN
        label.delete(array.shift(pdcLabels))

// === INFO TABLE ===
var table t = table.new(position.top_right, 2, 6, border_width=1)
if barstate.islast
    table.cell(t, 0, 0, "Index:", text_color=color.white, bgcolor=color.new(color.blue, 80))
    table.cell(t, 1, 0, selectedIndex, text_color=color.yellow, bgcolor=color.new(color.blue, 80))
    table.cell(t, 0, 1, "Symbol:", text_color=color.white, bgcolor=color.new(color.blue, 80))
    table.cell(t, 1, 1, syminfo.ticker, text_color=color.aqua, bgcolor=color.new(color.blue, 80))
    table.cell(t, 0, 2, "Mode:", text_color=color.white, bgcolor=color.new(color.blue, 80))
    table.cell(t, 1, 2, useFragmentedSessions ? "Fragmented" : "Standard", text_color=useFragmentedSessions ? color.lime : color.yellow, bgcolor=color.new(color.blue, 80))
    displaySession = useFragmentedSessions ? (selectedIndex == "Forex" ? forex_session1 + " + " + forex_session2 : selectedIndex == "Gold" ? gold_session1 + " + " + gold_session2 : selectedIndex == "Silver" ? silver_session1 + " + " + silver_session2 : selectedIndex == "Copper" ? copper_session1 + " + " + copper_session2 : standardSession) : standardSession
    table.cell(t, 0, 3, "Session:", text_color=color.white, bgcolor=color.new(color.blue, 80))
    table.cell(t, 1, 3, displaySession, text_color=color.yellow, bgcolor=color.new(color.blue, 80))
    table.cell(t, 0, 4, "Boxes:", text_color=color.white, bgcolor=color.new(color.blue, 80))
    table.cell(t, 1, 4, str.tostring(array.size(boxes)), text_color=color.lime, bgcolor=color.new(color.blue, 80))
    table.cell(t, 0, 5, "In ONR:", text_color=color.white, bgcolor=color.new(color.blue, 80))
    table.cell(t, 1, 5, str.tostring(inONR), text_color=inONR ? color.green : color.red, bgcolor=color.new(color.blue, 80))
bgcolor(inONR ? color.new(color.yellow, 97) : na)
````
