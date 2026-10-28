# RBD Cash Session Focus

- url: https://www.tradingview.com/script/nRsW7USm-RBD-Cash-Session-Focus/
- type: indicator
- pine_id: PUB;22bffcbaf7e94e67a081805a69effadf
- version: 1.0

## Description

Cash Session Focus

  Auction-aware indicator that strips overnight noise and focuses on the cash session: Initial Balance + cash-anchored
  VWAP.

  What it does

  Most charts blend overnight, pre-market, and cash-hour price action into one continuous stream — which hides what
  actually matters. This indicator:

  • Detects the symbol's cash session automatically (US indices, DAX, Nikkei, Gold) and dims everything outside it
  • Plots the Initial Balance (1st-hour high/low range) as a translucent box — the day's reference rectangle
  • Plots cash-session anchored VWAP (HLC3 × volume, reset each session) — true fair-value benchmark, uncontaminated by
  overnight
  • Optional ±1σ / ±2σ VWAP bands, prior-day closing VWAP level, and individual IB lines

  Supported markets (auto-detected)

  ▸ US indices (NQ / ES / YM / SPX / NDX / DJI / Nasdaq / S&P / Dow CFDs)
     Cash: 09:30–16:00 New York · 1st hour 09:30–10:30

  ▸ DAX (FDAX / GER40 / DE40)
     Cash: 09:00–17:30 Frankfurt · 1st hour 09:00–10:00

  ▸ Nikkei (NK225 / JP225)
     Cash: 09:00–15:30 Tokyo · 1st hour 09:00–10:00

  ▸ Gold (XAUUSD / GC / MGC)
     Cash: 08:00–17:30 London · 1st hour 08:00–09:00

  Manual override available for any symbol.

  How to read it

  • Price above VWAP + above IB box → trend-day long bias; pullbacks to VWAP / IB top are textbook entries
  • Price below VWAP + below IB box → trend-day short bias; rallies to VWAP / IB bottom are entries
  • Price oscillating inside IB box around VWAP → balanced auction / range day, fade extremes
  • VWAP slope → fair-value drift direction (flat = balance, sloped = directional auction)
  • ±2σ band touch in a trend → statistical exhaustion, candidate fade toward VWAP
  • Prior-day closing VWAP → magnetic level the next day, like a settlement reference

  Default view (institutional minimalism)

  Only two visual elements are on by default:
  1. IB box — cyan translucent rectangle from 1st-hour high to 1st-hour low
  2. VWAP — cyan line

  Everything else (bands, fill, Cash Open, IBH / IBL / IBC lines, prior VWAP, labels) is a toggle — summon detail only
  when you need it.

  Best results

  Use on real-volume futures (CME E-minis, EUREX FDAX, OSE Nikkei, COMEX GC). VWAP and IB only carry institutional
  weight when volume is real exchange volume. On CFDs (IG, OANDA) or spot forex the indicator still works structurally
  but VWAP becomes a tick-volume proxy — fine as a reference, less precise as a benchmark.

  Notes

  • Prior days' levels auto-fade to dashed / thin so today dominates visually
  • Keep "Keep N prior days' levels" at 2 for a clean chart, push higher for deeper context
  • Indicator is overlay-only, no repaint, no future leak — all calculations run forward-only per bar
  • Background dim color, line / box colors, line widths, and styles all customizable

  ---
  Built for traders who treat the cash session as the day's primary auction.

## Source Code

````pine
// © Mansred — Cash Session Focus
//@version=6
indicator("RBD Cash Session Focus", "RBD Cash Focus", overlay=true, max_lines_count=500, max_labels_count=200, max_boxes_count=100)

// ============ Inputs ============
grpV = "Display"
showShade   = input.bool(true,  "Dim non-cash hours",                                                            group=grpV)
shadeCol    = input.color(color.new(#5a6b8a, 94), "Non-cash background",                                         group=grpV)
showIBBox   = input.bool(true,  "IB box (1st-hour range)",                                                       group=grpV)
showOpen    = input.bool(false, "Cash Open line",                                                                group=grpV)
showIBH     = input.bool(false, "1st-Hour High line",                                                            group=grpV)
showIBL     = input.bool(false, "1st-Hour Low line",                                                             group=grpV)
showIBC     = input.bool(false, "1st-Hour Close line",                                                           group=grpV)
showLbls    = input.bool(false, "Show labels",                                                                   group=grpV)
labelOffset = input.int(6, "Label offset (bars right of last bar)", minval=0, maxval=50,                         group=grpV)
keepDays    = input.int(2, "Keep N prior days' levels", minval=0, maxval=20,                                     group=grpV)

grpW = "VWAP"
showVwap      = input.bool(true,  "Cash-session VWAP",                                                           group=grpW)
showBand1     = input.bool(false, "±1σ band",                                                                    group=grpW)
showBand2     = input.bool(false, "±2σ band",                                                                    group=grpW)
showPriorVwap = input.bool(false, "Prior-day closing VWAP (horizontal level)",                                   group=grpW)
fillBands     = input.bool(false, "Subtle fill between ±1σ",                                                     group=grpW)

grpC = "Colors / Style"
colIBBox     = input.color(color.new(#29b6f6, 90), "IB box fill",                                                group=grpC)
colIBBorder  = input.color(color.new(#29b6f6, 60), "IB box border",                                              group=grpC)
colOpen      = input.color(#e8e8e8, "Cash Open",                                                                 group=grpC)
colIBH       = input.color(#26a69a, "1H High",                                                                   group=grpC)
colIBL       = input.color(#ef5350, "1H Low",                                                                    group=grpC)
colIBC       = input.color(#ffb74d, "1H Close",                                                                  group=grpC)
colVwap      = input.color(#29b6f6, "VWAP",                                                                      group=grpC)
colPriorVwap = input.color(#ce93d8, "Prior closing VWAP",                                                        group=grpC)
lw           = input.int(2, "Line width (today)", minval=1, maxval=4,                                            group=grpC)
lineStl      = input.string("solid", "Line style (today)", options=["solid","dashed","dotted"],                  group=grpC)

grpM = "Market"
autoMkt = input.bool(true, "Auto-detect from symbol",                                                            group=grpM)
manMkt  = input.string("US", "Manual market (if auto off)", options=["US","DAX","Nikkei","Gold"],                group=grpM)

lineStyle = lineStl == "dashed" ? line.style_dashed : lineStl == "dotted" ? line.style_dotted : line.style_solid

// ============ Detect market ============
sym = syminfo.ticker
isDAX    = str.contains(sym, "DAX")    or str.contains(sym, "FDAX")  or str.contains(sym, "GER40")  or str.contains(sym, "DE40")  or str.contains(sym, "GDAXI")
isNikkei = str.contains(sym, "NIKKEI") or str.contains(sym, "NK225") or str.contains(sym, "JP225")  or str.contains(sym, "NKY")  or str.contains(sym, "N225") or str.contains(sym, "NI225")
isGold   = str.contains(sym, "XAUUSD") or str.contains(sym, "XAU")   or str.contains(sym, "GOLD")   or sym == "GC"               or str.contains(sym, "GC1!") or str.contains(sym, "MGC")
isUS     = str.contains(sym, "NQ")     or str.contains(sym, "ES")    or str.contains(sym, "YM")    or str.contains(sym, "NDX")  or str.contains(sym, "SPX")  or str.contains(sym, "DJI")   or str.contains(sym, "US100") or str.contains(sym, "US500") or str.contains(sym, "US30") or str.contains(sym, "NASDAQ") or str.contains(sym, "SPTRD") or str.contains(sym, "WALL") or str.contains(sym, "SPX500") or str.contains(sym, "NAS100")

detected = isDAX ? "DAX" : isNikkei ? "Nikkei" : isGold ? "Gold" : isUS ? "US" : "Unknown"
market   = autoMkt ? detected : manMkt

sessionStr = market == "DAX"    ? "0900-1730:23456" : market == "Nikkei" ? "0900-1530:23456" : market == "Gold" ? "0800-1730:23456" : "0930-1600:23456"
fhStr      = market == "DAX"    ? "0900-1000:23456" : market == "Nikkei" ? "0900-1000:23456" : market == "Gold" ? "0800-0900:23456" : "0930-1030:23456"
tz         = market == "DAX"    ? "Europe/Berlin"   : market == "Nikkei" ? "Asia/Tokyo"       : market == "Gold" ? "Europe/London"   : "America/New_York"

// ============ Session detection ============
inCash    = not na(time(timeframe.period, sessionStr, tz))
in1H      = not na(time(timeframe.period, fhStr,      tz))
cashStart = inCash and not inCash[1]
fhEnd     = not in1H and in1H[1]

bgcolor(showShade and not inCash and market != "Unknown" ? shadeCol : na, title="Non-cash hours")

// ============ State — IB ============
var float curOpen = na
var float curIBH  = na
var float curIBL  = na
var float curIBC  = na
var int   sessBar = na

var line  lnOpen = na
var line  lnIBH  = na
var line  lnIBL  = na
var line  lnIBC  = na
var box   bxIB   = na
var label lbOpen = na
var label lbIBH  = na
var label lbIBL  = na
var label lbIBC  = na

// ============ State — VWAP ============
var float sumV    = 0.0
var float sumPV   = 0.0
var float sumP2V  = 0.0
var float vwapVal = na
var float stdVal  = na
var float lastVwap = na
var line  lnPVwap  = na

// ============ Archive ============
var array<line>  arcLines = array.new<line>()
var array<label> arcLbls  = array.new<label>()
var array<box>   arcBoxes = array.new<box>()

archiveLine(line ln) =>
    if not na(ln)
        line.set_style(ln, line.style_dashed)
        line.set_width(ln, 1)
        array.push(arcLines, ln)

archiveLbl(label lb) =>
    if not na(lb)
        array.push(arcLbls, lb)

archiveBox(box bx) =>
    if not na(bx)
        box.set_bgcolor(bx, color.new(colIBBox, 96))
        box.set_border_color(bx, color.new(colIBBorder, 80))
        array.push(arcBoxes, bx)

trimArchive() =>
    maxL = keepDays * 5
    maxB = keepDays
    while array.size(arcLines) > maxL
        line.delete(array.shift(arcLines))
    while array.size(arcLbls) > maxL
        label.delete(array.shift(arcLbls))
    while array.size(arcBoxes) > maxB
        box.delete(array.shift(arcBoxes))

// ============ Cash open ============
if cashStart and market != "Unknown"
    archiveLine(lnOpen)
    archiveLine(lnIBH)
    archiveLine(lnIBL)
    archiveLine(lnIBC)
    archiveLine(lnPVwap)
    archiveBox(bxIB)
    archiveLbl(lbOpen)
    archiveLbl(lbIBH)
    archiveLbl(lbIBL)
    archiveLbl(lbIBC)
    trimArchive()

    lnOpen  := na
    lnIBH   := na
    lnIBL   := na
    lnIBC   := na
    lnPVwap := na
    bxIB    := na
    lbOpen  := na
    lbIBH   := na
    lbIBL   := na
    lbIBC   := na

    curOpen := open
    curIBH  := high
    curIBL  := low
    curIBC  := na
    sessBar := bar_index

    if showOpen
        lnOpen := line.new(bar_index, curOpen, bar_index, curOpen, color=colOpen, width=lw, style=lineStyle)

    if showPriorVwap and not na(lastVwap)
        lnPVwap := line.new(bar_index, lastVwap, bar_index, lastVwap, color=colPriorVwap, width=1, style=line.style_dashed)

    sumV    := 0.0
    sumPV   := 0.0
    sumP2V  := 0.0
    vwapVal := na
    stdVal  := na

// ============ Force VWAP to na outside cash session ============
if not inCash
    vwapVal := na
    stdVal  := na

// ============ During cash session: accumulate VWAP ============
if inCash and market != "Unknown" and not na(volume) and volume > 0
    tp = hlc3
    sumV   := sumV + volume
    sumPV  := sumPV + tp * volume
    sumP2V := sumP2V + tp * tp * volume
    if sumV > 0
        vwapVal := sumPV / sumV
        variance = math.max(sumP2V / sumV - vwapVal * vwapVal, 0.0)
        stdVal := math.sqrt(variance)
        lastVwap := vwapVal

// ============ Track during 1st hour ============
if in1H
    curIBH := math.max(nz(curIBH, high), high)
    curIBL := math.min(nz(curIBL, low),  low)
    curIBC := close

// ============ End of 1st hour ============
if fhEnd
    if showIBBox
        bxIB := box.new(sessBar, curIBH, bar_index, curIBL, border_color=colIBBorder, bgcolor=colIBBox, border_width=1)
    if showIBH
        lnIBH := line.new(sessBar, curIBH, bar_index, curIBH, color=colIBH, width=lw, style=lineStyle)
    if showIBL
        lnIBL := line.new(sessBar, curIBL, bar_index, curIBL, color=colIBL, width=lw, style=lineStyle)
    if showIBC
        lnIBC := line.new(bar_index - 1, curIBC, bar_index, curIBC, color=colIBC, width=lw, style=lineStyle)

// ============ Extend through session ============
if inCash
    if not na(lnOpen)
        line.set_x2(lnOpen, bar_index)
    if not na(lnIBH)
        line.set_x2(lnIBH, bar_index)
    if not na(lnIBL)
        line.set_x2(lnIBL, bar_index)
    if not na(lnIBC)
        line.set_x2(lnIBC, bar_index)
    if not na(lnPVwap)
        line.set_x2(lnPVwap, bar_index)
    if not na(bxIB)
        box.set_right(bxIB, bar_index)

// ============ Plot VWAP + bands ============
vwapPlot = showVwap  and inCash ? vwapVal              : na
b1U      = showBand1 and inCash ? vwapVal + stdVal     : na
b1D      = showBand1 and inCash ? vwapVal - stdVal     : na
b2U      = showBand2 and inCash ? vwapVal + 2 * stdVal : na
b2D      = showBand2 and inCash ? vwapVal - 2 * stdVal : na

pV  = plot(vwapPlot, "VWAP",  color=colVwap, linewidth=2, style=plot.style_linebr)
p1U = plot(b1U,      "+1σ",   color=color.new(colVwap, 55), linewidth=1, style=plot.style_linebr)
p1D = plot(b1D,      "-1σ",   color=color.new(colVwap, 55), linewidth=1, style=plot.style_linebr)
p2U = plot(b2U,      "+2σ",   color=color.new(colVwap, 75), linewidth=1, style=plot.style_linebr)
p2D = plot(b2D,      "-2σ",   color=color.new(colVwap, 75), linewidth=1, style=plot.style_linebr)

fill(p1U, p1D, color=(fillBands and showBand1 and inCash) ? color.new(colVwap, 92) : na, title="±1σ fill")

// ============ Live labels ============
mkLbl(string txt, float lvl, color c) =>
    label.new(bar_index + labelOffset, lvl, txt, textcolor=color.white, color=color.new(c, 20), style=label.style_label_left, size=size.tiny)

updateLbl(label lb, float lvl, string txt) =>
    label.set_xy(lb, bar_index + labelOffset, lvl)
    label.set_text(lb, txt)

if showLbls and barstate.islast
    if not na(lnOpen)
        t1 = "Open " + str.tostring(curOpen, format.mintick)
        if na(lbOpen)
            lbOpen := mkLbl(t1, curOpen, colOpen)
        else
            updateLbl(lbOpen, curOpen, t1)
    if not na(lnIBH)
        t2 = "IBH " + str.tostring(curIBH, format.mintick)
        if na(lbIBH)
            lbIBH := mkLbl(t2, curIBH, colIBH)
        else
            updateLbl(lbIBH, curIBH, t2)
    if not na(lnIBL)
        t3 = "IBL " + str.tostring(curIBL, format.mintick)
        if na(lbIBL)
            lbIBL := mkLbl(t3, curIBL, colIBL)
        else
            updateLbl(lbIBL, curIBL, t3)
    if not na(lnIBC)
        t4 = "1H Close " + str.tostring(curIBC, format.mintick)
        if na(lbIBC)
            lbIBC := mkLbl(t4, curIBC, colIBC)
        else
            updateLbl(lbIBC, curIBC, t4)

// ============ Unknown market warning ============
var label warnLbl = na
if barstate.islast and market == "Unknown"
    if na(warnLbl)
        warnLbl := label.new(bar_index, close, "Cash Focus: symbol not recognized — set 'Manual market' in settings.", color=color.new(color.orange, 20), textcolor=color.white, style=label.style_label_left)
    else
        label.set_xy(warnLbl, bar_index, close)
````
