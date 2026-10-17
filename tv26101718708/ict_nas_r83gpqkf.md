# ICT NAS

- url: https://www.tradingview.com/script/r83gPQKF-ICT-NAS/
- type: indicator
- pine_id: PUB;ce1939b19af9405ca99a204a628c81b2
- version: 2.0

## Description

Pre-BOS FVG — NAS100 (15m / 1H)

  The same Pre-BOS FVG engine proven on gold, ported to NAS100. Built on ICT 2022 mentorship. — Fair Value Gap, Break of Structure, draw on liquidity

  Setups:
  - A (FVG): higher low → close breaks the last swing high → buy the gap left in the breakout leg on the pullback (mirror for shorts: lower high → break of swing low → sell).
  - B (retest): if a clean break has no gap, enter the retest of the broken level instead.

  Management: stop behind the swing, bank half at +1R, move to breakeven, then trail behind structure. Long above the EMA, short below it. Entries confirm on candle close (no repainting).

  How it tested (backtest — not live — real NAS100, ~2yr, no-lookahead, 70/30 out-of-sample split, costs included).
  Scored at a flat 2R per win so the numbers are honest and comparable:
  - 15m: 70% / 69% win, profit factor 4.4, +331R / +153R — 144 out-of-sample trades, in-sample ≈ out-of-sample (robust).
  - 1H: 69% / 61% win, profit factor ~3–4, +92R / +19R (smaller sample, 23 OOS trades).

  Honest limits: the live version trails its winners further than a flat 2R, so on the chart it looks like ~89% win / huge profit factor — don't trust that PF, it's flattered by a few big trend rides; judge it by the 2R numbers above. NAS 1H sample is modest. Past backtest performance is not a promise of future results. 
Forward-test before risking money. Educational tool, not financial advice. Credit: ICT

  ---
  NAS 15m is the strongest, most trustworthy version (big sample, holds out-of-sample).

## Source Code

````pine
//@version=6
indicator("Pre-BOS FVG — NAS", overlay = true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

L         = input.int(5, "Pivot lookback (confirm bars)", minval = 2)
bufA      = input.float(0.10, "Stop buffer (x ATR)", minval = 0.0, step = 0.05)
p1        = input.float(1.0, "Bank HALF at (R) -> then trail", minval = 0.5, step = 0.5)
retraceN  = input.int(20, "Bars to wait for retrace", minval = 1)
useRetest = input.bool(true, "Also trade NO-GAP breaks (break-retest, B-grade)")
emaFilt   = input.bool(true, "Trend filter (buy above EMA / sell below EMA)")
emaLen    = input.int(50, "Trend EMA length", minval = 5)
cooldown  = input.int(6, "Min bars between trades", minval = 0)
allowLong = input.bool(true, "Allow LONGS")
allowShort= input.bool(true, "Allow SHORTS")
showPanel = input.bool(true, "Show guidance panel")
showZones = input.bool(true, "Draw setup (BOS, zone, entry/SL/TP)")

atrv = ta.atr(14)
emaT = ta.ema(close, emaLen)
plot(emaT, "Trend EMA", color = color.new(color.blue, 55))
passLong  = not emaFilt or close > emaT
passShort = not emaFilt or close < emaT

ph = ta.pivothigh(L, L)
pl = ta.pivotlow(L, L)
var float sh1 = na, var float sh0 = na
var float sl1 = na, var float sl0 = na
var int shBar = na, var int slBar = na
if not na(ph)
    sh0 := sh1, sh1 := ph, shBar := bar_index - L
if not na(pl)
    sl0 := sl1, sl1 := pl, slBar := bar_index - L

var float uTop = na, var float uBot = na, var int uBar = na
if not na(high[2]) and high[2] < low
    uTop := low, uBot := high[2], uBar := bar_index
var float dTop = na, var float dBot = na, var int dBar = na
if not na(low[2]) and low[2] > high
    dTop := low[2], dBot := high, dBar := bar_index

var bool armedL = false, var float brkL = na, var int hlBar = na, var float hlLow = na, var int brkBarL = na
var bool armedS = false, var float brkS = na, var int lhBar = na, var float lhHigh = na, var int brkBarS = na
if not na(pl) and not na(sl0) and sl1 > sl0 and not na(sh1)
    armedL := true, brkL := sh1, hlBar := bar_index, hlLow := sl1, brkBarL := shBar
if not na(ph) and not na(sh0) and sh1 < sh0 and not na(sl1)
    armedS := true, brkS := sl1, lhBar := bar_index, lhHigh := sh1, brkBarS := slBar

if not na(ph)
    bool isHH = na(sh0) or sh1 > sh0
    label.new(bar_index - L, ph + 0.5 * atrv, isHH ? "HH" : "LH", style = label.style_none, textcolor = isHH ? color.new(color.green, 0) : color.new(color.red, 0), size = size.small)
if not na(pl)
    bool isHL = na(sl0) or sl1 > sl0
    label.new(bar_index - L, pl - 0.5 * atrv, isHL ? "HL" : "LL", style = label.style_none, textcolor = isHL ? color.new(color.green, 0) : color.new(color.red, 0), size = size.small)

var int state = 0
var int dir = 0
var bool isRetest = false
var float entLvl = na, var float stpLvl = na, var float invLvl = na
var float ent = na, var float stop = na, var float t1 = na, var float risk = na
var bool half = false
var int bosBar = na
var int lastExit = -100000

var box   zBox  = na
var line  zLine = na
var line  bosLn = na
var label bosLb = na
var label zLbl  = na
var line  eLn = na, var line sLn = na, var line tLn = na
var label eLb = na
var label slLb = na, var label tpLb = na

bool fireLong = false, bool fireShort = false
bool bosJustSet = false
float bosLvl = na
float zTop = na, float zBot = na
int   zLeft = na
bool  zIsBox = false
bool didExit = false, bool wasWin = false
float exitPx = na

if state == 2
    if dir == 1
        if not half and high >= t1
            half := true, stop := math.max(stop, ent)
        if half and not na(sl1) and sl1 - bufA * atrv > stop
            stop := sl1 - bufA * atrv
        if low <= stop
            didExit := true, wasWin := (half or stop > ent), exitPx := stop, state := 0, lastExit := bar_index
    else
        if not half and low <= t1
            half := true, stop := math.min(stop, ent)
        if half and not na(sh1) and sh1 + bufA * atrv < stop
            stop := sh1 + bufA * atrv
        if high >= stop
            didExit := true, wasWin := (half or stop < ent), exitPx := stop, state := 0, lastExit := bar_index

if state == 2 and not na(sLn)
    line.set_y1(sLn, stop), line.set_y2(sLn, stop)
if state == 2 and not na(eLn)
    line.set_x2(eLn, bar_index)
    if not na(sLn)
        line.set_x2(sLn, bar_index)
    if not na(tLn)
        line.set_x2(tLn, bar_index)
    if not na(slLb)
        label.set_x(slLb, bar_index), label.set_y(slLb, stop)
    if not na(tpLb)
        label.set_x(tpLb, bar_index)

if didExit
    alert((wasWin ? "Pre-BOS FVG NAS exit (win) @ " : "Pre-BOS FVG NAS stop @ ") + str.tostring(exitPx, format.mintick), alert.freq_once_per_bar)

if state == 0 and (bar_index - lastExit) >= cooldown and barstate.isconfirmed
    if allowLong and armedL and bar_index > hlBar and close > brkL and passLong
        armedL := false
        bool fvgOK = not na(uTop) and uBar >= hlBar
        if fvgOK
            state := 1, dir := 1, isRetest := false, entLvl := uTop, stpLvl := uBot - bufA * atrv, invLvl := uBot, bosBar := bar_index, bosJustSet := true, bosLvl := brkL
            zTop := uTop, zBot := uBot, zLeft := uBar - 2, zIsBox := true
        else if useRetest and not na(hlLow)
            state := 1, dir := 1, isRetest := true, entLvl := brkL, stpLvl := hlLow - bufA * atrv, invLvl := hlLow, bosBar := bar_index, bosJustSet := true, bosLvl := brkL
            zTop := not na(uTop) ? uTop : brkL, zBot := not na(uTop) ? uBot : brkL - 0.6 * atrv, zLeft := not na(uTop) ? uBar - 1 : hlBar, zIsBox := true
    else if allowShort and armedS and bar_index > lhBar and close < brkS and passShort
        armedS := false
        bool fvgOK = not na(dTop) and dBar >= lhBar
        if fvgOK
            state := 1, dir := -1, isRetest := false, entLvl := dBot, stpLvl := dTop + bufA * atrv, invLvl := dTop, bosBar := bar_index, bosJustSet := true, bosLvl := brkS
            zTop := dTop, zBot := dBot, zLeft := dBar - 2, zIsBox := true
        else if useRetest and not na(lhHigh)
            state := 1, dir := -1, isRetest := true, entLvl := brkS, stpLvl := lhHigh + bufA * atrv, invLvl := lhHigh, bosBar := bar_index, bosJustSet := true, bosLvl := brkS
            zTop := not na(dTop) ? dTop : brkS + 0.6 * atrv, zBot := not na(dTop) ? dBot : brkS, zLeft := not na(dTop) ? dBar - 1 : lhBar, zIsBox := true

if bosJustSet and showZones
    if not na(bosLn)
        line.delete(bosLn)
    if not na(bosLb)
        label.delete(bosLb)
    if not na(zLbl)
        label.delete(zLbl)
    if not na(zBox)
        box.delete(zBox), zBox := na
    if not na(zLine)
        line.delete(zLine), zLine := na
    if not na(eLn)
        line.delete(eLn), eLn := na
    if not na(sLn)
        line.delete(sLn), sLn := na
    if not na(tLn)
        line.delete(tLn), tLn := na
    if not na(eLb)
        label.delete(eLb), eLb := na
    if not na(slLb)
        label.delete(slLb), slLb := na
    if not na(tpLb)
        label.delete(tpLb), tpLb := na
    bc = dir == 1 ? color.green : color.red
    int bosLeftBar = dir == 1 ? brkBarL : brkBarS
    if na(bosLeftBar)
        bosLeftBar := bosBar - 4 * L
    bosLn := line.new(bosLeftBar, bosLvl, bosBar + 4, bosLvl, color = color.new(color.black, 0), width = 2)
    bosLb := label.new(bosBar + 4, bosLvl, "BOS " + (dir == 1 ? "▲" : "▼"), style = label.style_none, textcolor = bc, size = size.small)
    zname = dir == 1 ? "Demand" : "Supply"
    if zIsBox
        zBox := box.new(zLeft, zTop, bar_index, zBot, border_color = color.new(bc, 20), border_width = 1, bgcolor = color.new(bc, 84))
    else
        zLine := line.new(zLeft, zTop, bar_index, zTop, color = color.new(bc, 25), width = 1, style = line.style_dotted)
    zLbl := label.new(bar_index, math.max(zTop, zBot), zname, style = label.style_none, textcolor = color.new(bc, 0), size = size.small)

if state == 1
    if not na(zBox)
        box.set_right(zBox, bar_index)
    if not na(zLine)
        line.set_x2(zLine, bar_index)
    if not na(zLbl)
        label.set_x(zLbl, bar_index)
    bool invalid = bar_index - bosBar > retraceN or (dir == 1 ? close < invLvl : close > invLvl)
    if not barstate.isconfirmed
        invalid := false
    if invalid
        state := 0
    else if barstate.isconfirmed and dir == 1 and low <= entLvl
        ent := entLvl, stop := stpLvl, risk := ent - stop, t1 := ent + p1 * (ent - stop), half := false
        if risk > 0
            state := 2, fireLong := true
    else if barstate.isconfirmed and dir == -1 and high >= entLvl
        ent := entLvl, stop := stpLvl, risk := stop - ent, t1 := ent - p1 * (stop - ent), half := false
        if risk > 0
            state := 2, fireShort := true

if fireLong or fireShort
    isL = fireLong
    col = isL ? color.green : color.red
    eLn := line.new(bar_index, ent,  bar_index, ent,  color = color.new(color.blue, 0),  width = 1)
    sLn := line.new(bar_index, stop, bar_index, stop, color = color.new(color.red, 0),   width = 1, style = line.style_dashed)
    tLn := line.new(bar_index, t1,   bar_index, t1,   color = color.new(color.green, 0), width = 1, style = line.style_dashed)
    eLb := label.new(bar_index, ent, (isL ? "ENTER ▲ " : "ENTER ▼ ") + str.tostring(ent, format.mintick), style = isL ? label.style_label_up : label.style_label_down, color = color.new(col, 0), textcolor = color.white, size = size.small, tooltip = "Entry " + str.tostring(ent, format.mintick) + "   SL " + str.tostring(stop, format.mintick) + "   target " + str.tostring(t1, format.mintick) + " then trail")
    slLb := label.new(bar_index, stop, "SL " + str.tostring(stop, format.mintick), style = label.style_none, textcolor = color.new(color.red, 0), size = size.small)
    tpLb := label.new(bar_index, t1, "TP " + str.tostring(t1, format.mintick), style = label.style_none, textcolor = color.new(color.green, 0), size = size.small)
    alert((isL ? "Pre-BOS FVG NAS BUY" : "Pre-BOS FVG NAS SELL") + (isRetest ? " [B]" : " [A]") + " @ " + str.tostring(ent, format.mintick) + " | SL " + str.tostring(stop, format.mintick) + " | target " + str.tostring(t1, format.mintick) + " then trail", alert.freq_once_per_bar_close)

plotshape(fireLong,  "BUY",  shape.triangleup,   location.belowbar, color.new(color.green, 0), size = size.tiny)
plotshape(fireShort, "SELL", shape.triangledown, location.abovebar, color.new(color.red, 0),   size = size.tiny)

var table P = table.new(position.top_right, 2, 5, frame_color = color.new(color.gray, 40), frame_width = 1)
f_cell(tbl, i, k, v, c) =>
    table.cell(tbl, 0, i, k, text_color = color.white, text_size = size.normal, text_halign = text.align_left, bgcolor = color.new(color.black, 10))
    table.cell(tbl, 1, i, v, text_color = c, text_size = size.normal, text_halign = text.align_left, bgcolor = color.new(color.black, 30))
if showPanel and barstate.islast
    string nd = ""
    color nc = color.silver
    if state == 2
        cr = risk > 0 ? (dir == 1 ? (close - ent) / risk : (ent - close) / risk) : 0.0
        nd := (dir == 1 ? "IN LONG (" : "IN SHORT (") + str.tostring(cr, "+0.0") + "R)  " + (half ? "1/2 banked, trailing" : "stop " + str.tostring(stop, format.mintick)) + (isRetest ? "  [B]" : "  [A]")
        nc := dir == 1 ? color.lime : color.orange
    else if state == 1
        nd := (dir == 1 ? "Break UP done - wait entry " : "Break DOWN done - wait entry ") + str.tostring(entLvl, format.mintick) + (isRetest ? " (retest)" : " (FVG)")
        nc := color.yellow
    else if armedL and passLong
        nd := "Higher low set - need a close > " + str.tostring(brkL, format.mintick) + " (up break)"
        nc := color.aqua
    else if armedS and passShort
        nd := "Lower high set - need a close < " + str.tostring(brkS, format.mintick) + " (down break)"
        nc := color.fuchsia
    else
        nd := "Waiting for a setup (higher low to buy / lower high to sell)"
        nc := color.silver
    f_cell(P, 0, "Pre-BOS FVG NAS", syminfo.ticker + " " + timeframe.period, color.aqua)
    f_cell(P, 1, "Trend EMA", close > emaT ? "above (longs ok)" : "below (shorts ok)", close > emaT ? color.lime : color.orange)
    f_cell(P, 2, "NOW DO", nd, nc)
    f_cell(P, 3, "Setup", "A = FVG before break · B = retest of broken level", color.silver)
    f_cell(P, 4, "Exit", "bank 1/2 at +" + str.tostring(p1, "#.#") + "R, stop to BE, trail the rest", color.silver)
````
