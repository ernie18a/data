# Numb 90m Cycle Sweep [Quarterly Theory]

- url: https://www.tradingview.com/script/uFyuxi5b-Numb-90m-Cycle-Sweep-Quarterly-Theory/
- type: indicator
- pine_id: PUB;8fb06bb5be3e444c941ab4cc23c084a1
- version: 1.0

## Description

How it reads on the chart:

Faint alternating shaded blocks mark each 90-min cycle inside the window.
Each cycle's prior high/low draws as a line that extends until swept (then dashes/fades).
✕ when the current cycle raids the prior cycle's level → BUY/SELL triangle on the CHoCH that confirms the reversal → Entry / SL / TP + R:R on the signal.
Panel (top-right): current cycle start time, prior H/L, and whether it's armed/fired.

## Source Code

````pine
//@version=6
// =====================================================================
//  Numb 90m Cycle Sweep  [Quarterly Theory]   v1.0   (variant #1)
//  --------------------------------------------------------------------
//  LIQUIDITY HANDOFF. The day is tiled into fixed cycles (default 90 min,
//  anchored at 07:00). Each cycle prints a high and a low; the NEXT cycle
//  is expected to raid that liquidity and reverse:
//    LONG : current cycle sweeps the PRIOR cycle's LOW (+ closes back in)
//           -> then breaks the last swing high (CHoCH) -> BUY
//    SHORT: current cycle sweeps the PRIOR cycle's HIGH (+ closes back in)
//           -> then breaks the last swing low  (CHoCH) -> SELL
//  Arming resets every cycle (each cycle is a fresh hunt of the prior one).
//  Optional active-window filter (default NY-AM 07:00-11:30).
//
//  This is the fractal 90-min layer that sits inside the session model
//  (Asia / London / NY-AM / NY-PM). Confirm-on-close = non-repainting.
//  Variant #2 (AMD positional rotation) is a separate build.
//  Analysis tooling, not financial advice.
// =====================================================================
indicator("Numb 90m Cycle Sweep [Quarterly Theory]", overlay = true, max_lines_count = 500, max_labels_count = 60)

// ---- Inputs : Time / cycle ----
gT = "Time / cycle"
tz       = input.string("America/New_York", "Timezone",
     options = ["America/New_York","America/Chicago","Europe/London","UTC","Asia/Tokyo","Asia/Shanghai","Asia/Karachi","Asia/Dubai","Australia/Sydney"],
     group = gT, tooltip = "All times in this timezone. DST handled automatically.")
anchorH  = input.int(7,  "Cycle anchor hour (0-23)", minval = 0, maxval = 23, group = gT, tooltip = "Cycles align to this time. 07:00 -> 07:00 / 08:30 / 10:00 / 11:30 ...")
anchorM  = input.int(0,  "Cycle anchor minute", minval = 0, maxval = 59, group = gT)
cycleMin = input.int(90, "Cycle length (minutes)", minval = 5, group = gT)
useWin   = input.bool(true, "Restrict to active window", group = gT)
win      = input.session("0700-1130", "Active window", group = gT, tooltip = "Only hunt inside this window (NY-AM by default). Turn off to run all day.")

// ---- Inputs : Sweep ----
gS = "Sweep"
bufMode    = input.string("Ticks", "Penetration buffer", options = ["Ticks","ATR"], group = gS)
bufVal     = input.float(2, "Buffer value", minval = 0, group = gS)
atrLen     = input.int(14, "ATR length (for ATR buffer)", minval = 1, group = gS)
reqReclaim = input.bool(true, "Require close back inside", group = gS)

// ---- Inputs : Structure ----
gC = "Structure (CHoCH)"
swingLen  = input.int(5, "Swing pivot length", minval = 1, group = gC)
confClose = input.bool(true, "Confirm on close (no repaint)", group = gC)

// ---- Inputs : Risk ----
gR = "Risk levels"
showRisk = input.bool(true, "Show Entry / SL / TP", group = gR)
tgtMode  = input.string("Opposite liquidity", "Target", options = ["Opposite liquidity","R multiple"], group = gR)
rMult    = input.float(2.0, "R multiple", minval = 0.1, step = 0.1, group = gR)
slBufTk  = input.float(2, "SL buffer (ticks)", minval = 0, group = gR)
projBars = input.int(18, "Line projection (bars)", minval = 2, group = gR)

// ---- Inputs : Visuals ----
gV = "Visuals"
upCol      = input.color(#089981, "Bullish", group = gV)
dnCol      = input.color(#f23645, "Bearish", group = gV)
showCycBg  = input.bool(true, "Shade cycle blocks", group = gV)
showRef    = input.bool(true, "Show prior-cycle H/L", group = gV)
showSwp    = input.bool(true, "Show sweep marks", group = gV)
showPanel  = input.bool(true, "Show status panel", group = gV)
panelPos   = input.string("Top right", "Panel position", options = ["Top right","Top left","Bottom right","Bottom left"], group = gV)

// ---- Time / cycle id ----
m = hour(time, tz) * 60 + minute(time, tz)
anchorMin = anchorH * 60 + anchorM
cycId = int(((m - anchorMin + 1440) % 1440) / cycleMin)
newCyc = na(cycId[1]) or cycId != cycId[1]
inWin = (not useWin) or not na(time(timeframe.period, win, tz))

atrV   = ta.atr(atrLen)
bufPts = bufMode == "ATR" ? bufVal * atrV : bufVal * syminfo.mintick
slBuf  = slBufTk * syminfo.mintick

// ---- Cycle high/low ----
var float curH = na
var float curL = na
var float prevH = na
var float prevL = na
if newCyc
    prevH := curH
    prevL := curL
    curH := high
    curL := low
else
    curH := na(curH) ? high : math.max(curH, high)
    curL := na(curL) ? low  : math.min(curL, low)

// ---- Swing pivots ----
ph = ta.pivothigh(swingLen, swingLen)
pl = ta.pivotlow(swingLen, swingLen)
var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

// ---- State (resets each cycle) ----
var bool  armedLong  = false
var bool  armedShort = false
var bool  firedLong  = false
var bool  firedShort = false
var float swpLow  = na
var float swpHigh = na
if newCyc
    armedLong  := false
    armedShort := false
    firedLong  := false
    firedShort := false
    swpLow  := na
    swpHigh := na

canDetect = inWin and not na(prevH) and not na(prevL)
bullSweep = canDetect and (low  < prevL - bufPts) and (reqReclaim ? close > prevL : true)
bearSweep = canDetect and (high > prevH + bufPts) and (reqReclaim ? close < prevH : true)

if bullSweep
    swpLow := armedLong ? math.min(swpLow, low) : low
    armedLong := true
    firedLong := false
if bearSweep
    swpHigh := armedShort ? math.max(swpHigh, high) : high
    armedShort := true
    firedShort := false

if armedLong and (not bullSweep) and (close < prevL)
    armedLong := false
    swpLow := na
if armedShort and (not bearSweep) and (close > prevH)
    armedShort := false
    swpHigh := na

confBar = confClose ? barstate.isconfirmed : true
longCHoCH  = armedLong  and not firedLong  and not na(lastPH) and (confClose ? close > lastPH : high > lastPH)
shortCHoCH = armedShort and not firedShort and not na(lastPL) and (confClose ? close < lastPL : low  < lastPL)
buySignal  = longCHoCH  and confBar
sellSignal = shortCHoCH and confBar
if buySignal
    firedLong := true
    armedLong := false
if sellSignal
    firedShort := true
    armedShort := false

// ---- Prior-cycle H/L lines (extend until swept) ----
var line  rHi = na
var line  rLo = na
var float rHiLvl = na
var float rLoLvl = na
var bool  hiAct = false
var bool  loAct = false
drawRef = showRef and newCyc and not na(prevH) and not na(prevL) and ((not useWin) or inWin)
if drawRef
    rHi := line.new(bar_index, prevH, bar_index, prevH, color = color.new(dnCol, 20), width = 1, style = line.style_solid)
    rLo := line.new(bar_index, prevL, bar_index, prevL, color = color.new(upCol, 20), width = 1, style = line.style_solid)
    rHiLvl := prevH
    rLoLvl := prevL
    hiAct := true
    loAct := true
if showRef and not newCyc
    if hiAct and not na(rHi)
        line.set_x2(rHi, bar_index)
        if high > rHiLvl
            line.set_style(rHi, line.style_dashed)
            line.set_color(rHi, color.new(dnCol, 65))
            hiAct := false
    if loAct and not na(rLo)
        line.set_x2(rLo, bar_index)
        if low < rLoLvl
            line.set_style(rLo, line.style_dashed)
            line.set_color(rLo, color.new(upCol, 65))
            loAct := false

// ---- Risk drawing ----
var line  lnE = na
var line  lnS = na
var line  lnT = na
var label lbR = na
if (buySignal or sellSignal) and showRisk
    if not na(lnE)
        line.delete(lnE)
    if not na(lnS)
        line.delete(lnS)
    if not na(lnT)
        line.delete(lnT)
    if not na(lbR)
        label.delete(lbR)
    bool  isLong = buySignal
    float entry  = close
    float sl     = isLong ? (na(swpLow) ? low : swpLow) - slBuf : (na(swpHigh) ? high : swpHigh) + slBuf
    float risk   = math.abs(entry - sl)
    float tp     = tgtMode == "R multiple" ? (isLong ? entry + rMult * risk : entry - rMult * risk) : (isLong ? prevH : prevL)
    float rr     = risk > 0 ? math.abs(tp - entry) / risk : na
    int x1 = bar_index
    int x2 = bar_index + projBars
    lnE := line.new(x1, entry, x2, entry, color = color.new(color.gray, 0), width = 1, style = line.style_solid)
    lnS := line.new(x1, sl,    x2, sl,    color = color.new(dnCol, 0),     width = 1, style = line.style_dashed)
    lnT := line.new(x1, tp,    x2, tp,    color = color.new(upCol, 0),     width = 1, style = line.style_dashed)
    lbR := label.new(x2, tp, "TP " + str.tostring(tp, format.mintick) + "  •  " + str.tostring(rr, "#.0") + "R", style = label.style_label_left, color = color.new(color.gray, 20), textcolor = color.white, size = size.small)

// ---- Plots ----
bgcolor(showCycBg and ((not useWin) or inWin) ? (cycId % 2 == 0 ? color.new(color.blue, 94) : color.new(color.purple, 94)) : na, title = "Cycle blocks")
plotshape(showSwp and bullSweep, "Bull sweep", style = shape.xcross, location = location.belowbar, color = color.new(upCol, 0), size = size.tiny)
plotshape(showSwp and bearSweep, "Bear sweep", style = shape.xcross, location = location.abovebar, color = color.new(dnCol, 0), size = size.tiny)
plotshape(buySignal,  "BUY",  style = shape.triangleup,   location = location.belowbar, color = upCol, text = "BUY",  textcolor = upCol, size = size.small)
plotshape(sellSignal, "SELL", style = shape.triangledown, location = location.abovebar, color = dnCol, text = "SELL", textcolor = dnCol, size = size.small)

// ---- Alerts ----
alertcondition(buySignal,  "Cycle Sweep BUY",  "90m cycle sweep BUY")
alertcondition(sellSignal, "Cycle Sweep SELL", "90m cycle sweep SELL")
alertcondition(bullSweep or bearSweep, "Cycle Liquidity Sweep", "Prior-cycle liquidity swept")

// ---- Status panel ----
cycStartMin = (cycId * cycleMin + anchorMin) % 1440
cycHH = int(cycStartMin / 60)
cycMM = cycStartMin % 60
cycLab = (cycHH < 10 ? "0" : "") + str.tostring(cycHH) + ":" + (cycMM < 10 ? "0" : "") + str.tostring(cycMM)
pPos = panelPos == "Top right" ? position.top_right : panelPos == "Top left" ? position.top_left : panelPos == "Bottom right" ? position.bottom_right : position.bottom_left
var table pnl = na
if showPanel and barstate.islast
    if na(pnl)
        pnl := table.new(pPos, 2, 6, border_width = 1, border_color = color.new(color.gray, 60))
    armTxt = armedLong ? "LONG armed" : armedShort ? "SHORT armed" : firedLong ? "LONG fired" : firedShort ? "SHORT fired" : "waiting"
    table.cell(pnl, 0, 0, "90m Cycle", text_color = color.white, bgcolor = color.new(color.gray, 20), text_size = size.small, text_halign = text.align_left)
    table.cell(pnl, 1, 0, inWin ? "IN WINDOW" : "—", bgcolor = color.new(color.gray, 20), text_color = inWin ? upCol : color.gray, text_size = size.small)
    table.cell(pnl, 0, 1, "Cycle start", text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    table.cell(pnl, 1, 1, cycLab, text_color = color.white, text_size = size.small)
    table.cell(pnl, 0, 2, "Prior High", text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    table.cell(pnl, 1, 2, na(prevH) ? "—" : str.tostring(prevH, format.mintick), text_color = color.white, text_size = size.small)
    table.cell(pnl, 0, 3, "Prior Low", text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    table.cell(pnl, 1, 3, na(prevL) ? "—" : str.tostring(prevL, format.mintick), text_color = color.white, text_size = size.small)
    table.cell(pnl, 0, 4, "State", text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    table.cell(pnl, 1, 4, armTxt, text_color = color.white, text_size = size.small)
    table.cell(pnl, 0, 5, "Cycle len", text_color = color.gray, text_size = size.small, text_halign = text.align_left)
    table.cell(pnl, 1, 5, str.tostring(cycleMin) + "m", text_color = color.white, text_size = size.small)
````
