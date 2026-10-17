# 4H Reversal: FVG / IFVG / BOS / CISD

- url: https://www.tradingview.com/script/ol6nu7Gp-4H-Reversal-FVG-IFVG-BOS-CISD/
- type: indicator
- pine_id: PUB;efe5adae8e94413ca71636106a9e5cf1
- version: 1.0

## Description

PUSS 4HR CRT, FVG, IFVG, BOS AND CISD... What it does:
- Lines on the last 7 closed 4H candles (high + low each), drawn right on the candles so they line up perfectly. The currently-forming candle stays bare until it closes. ⚠️ It shows a warning label if you're not on 4H.
- Reversal confluence from your four pieces, each marked on the chart and in the top-right table:
  - FVG zones, which flip to highlighted IFVG (orange) when closed through
  - BOS labels when price breaks the last swing high/low
  - CISD lines/labels when price closes back through the origin of the last move
- Confluence table — shows ✓/✗ for FVG · IFVG · BOS · CISD on both Bull and Bear sides, plus a REVERSAL n/4 score. A ▲/▼ REV label prints only when enough align.
- I verified it live: it correctly read Bull 4/4 at one point, and now reads 2/4 (no premature signal).

## Source Code

````pine
//@version=6
// =============================================================================
//  4H Reversal: FVG / IFVG / BOS / CISD  (confluence confirmation)
// -----------------------------------------------------------------------------
//  Built for the 4-HOUR chart. Plots a reversal when a confluence of:
//     FVG  - Fair Value Gap
//     IFVG - Inverse Fair Value Gap (an FVG that has been closed through)
//     BOS  - Break of Structure (price breaks the last swing high/low)
//     CISD - Change in State of Delivery (close back through the open that
//            started the last opposite-direction move)
//  ...lines up within a recent window. Each component is shown on the chart AND
//  in the table so you can see and confirm the confluence yourself.
//
//  Also draws the High & Low of the last N (default 7) CLOSED candles. The
//  candle currently forming has no lines until it closes.
//
//  RUN THIS ON A 4-HOUR CHART.
// =============================================================================
indicator("4H Reversal: FVG / IFVG / BOS / CISD", overlay = true, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500)

// ================================ Inputs =====================================
gG = "General"
warnTF = input.bool(true, "Warn if chart is not 4H", group = gG)

gL = "Previous-candle High/Low lines"
showPrevHL = input.bool(true, "Show previous-candle High/Low lines", group = gL)
prevCount  = input.int(7, "How many previous candles", minval = 1, maxval = 20, group = gL, tooltip = "Draws the High and Low of the last N CLOSED candles. The candle currently forming has no lines until it closes.")

gF = "Fair Value Gaps"
showFVG   = input.bool(true, "Show FVG zones", group = gF)
showIFVG  = input.bool(true, "Show IFVG (inverse FVG)", group = gF, tooltip = "When an FVG is closed through it flips to an Inverse FVG and is re-highlighted (orange) in the opposite direction.")
maxFVG    = input.int(6, "Max FVG zones to keep", minval = 1, maxval = 20, group = gF)
fvgExtend = input.int(20, "FVG box extend (bars)", minval = 1, group = gF)

gB = "Structure"
showBOS  = input.bool(true, "Show BOS (break of structure)", group = gB)
swingLen = input.int(3, "Swing strength (bars each side)", minval = 1, maxval = 10, group = gB)
showCISD = input.bool(true, "Show CISD (change in state of delivery)", group = gB)

gR = "Reversal confluence"
minConfl   = input.int(3, "Min confluences to plot reversal", minval = 1, maxval = 4, group = gR, tooltip = "How many of FVG / IFVG / BOS / CISD must align within the window to print a reversal. Higher = fewer, stronger signals (3-4 recommended); lower = more, earlier signals.")
confWindow = input.int(5, "Confluence window (bars)", minval = 1, maxval = 30, group = gR)

gS = "Style"
bullCol = input.color(color.teal, "Bullish", group = gS)
bearCol = input.color(color.red,  "Bearish", group = gS)
keyCol  = input.color(color.new(color.teal, 75),   "FVG fill", group = gS)
ifvgCol = input.color(color.new(color.orange, 60), "IFVG fill", group = gS)
hlCol   = input.color(color.new(color.gray, 25),   "Prev-candle line", group = gS)
showTbl = input.bool(true, "Show confluence table", group = gS)

// ================================ Types ======================================
type FVG
    box   bx
    float top
    float bot
    bool  isBull
    bool  inv
    bool  active

// ===================== Previous-candle High/Low lines ========================
var array<line> prevHi = array.new<line>()
var array<line> prevLo = array.new<line>()

if showPrevHL and barstate.isnew and bar_index > prevCount
    h = line.new(bar_index - 1, high[1], bar_index, high[1], color = hlCol, width = 1)
    l = line.new(bar_index - 1, low[1],  bar_index, low[1],  color = hlCol, width = 1)
    array.push(prevHi, h)
    array.push(prevLo, l)
    if array.size(prevHi) > prevCount
        line.delete(array.shift(prevHi))
    if array.size(prevLo) > prevCount
        line.delete(array.shift(prevLo))

if showPrevHL and array.size(prevHi) > 0
    for i = 0 to array.size(prevHi) - 1
        line.set_x2(array.get(prevHi, i), bar_index)
        line.set_x2(array.get(prevLo, i), bar_index)

// ============================== FVG + IFVG ===================================
bullFVGev = low > high[2]
bearFVGev = high < low[2]

var array<FVG> fvgs = array.new<FVG>()
var int bullFVGbar  = na
var int bearFVGbar  = na
var int bullIFVGbar = na
var int bearIFVGbar = na

if barstate.isconfirmed and bullFVGev
    bullFVGbar := bar_index
if barstate.isconfirmed and bearFVGev
    bearFVGbar := bar_index

f_pushFVG(_cond, _top, _bot, _isBull) =>
    if _cond and showFVG
        bx = box.new(bar_index[2], _top, bar_index + fvgExtend, _bot, border_color = _isBull ? bullCol : bearCol, bgcolor = keyCol, border_width = 1)
        array.push(fvgs, FVG.new(bx, _top, _bot, _isBull, false, true))
        if array.size(fvgs) > maxFVG
            oldF = array.shift(fvgs)
            if oldF.active
                box.delete(oldF.bx)

f_pushFVG(barstate.isconfirmed and bullFVGev, low,  high[2], true)
f_pushFVG(barstate.isconfirmed and bearFVGev, high, low[2],  false)

if showFVG and array.size(fvgs) > 0
    for i = 0 to array.size(fvgs) - 1
        f = array.get(fvgs, i)
        if f.active
            box.set_right(f.bx, bar_index + fvgExtend)
            broken = f.isBull ? (close < f.bot) : (close > f.top)
            if broken
                if not f.inv and showIFVG
                    f.inv    := true
                    f.isBull := not f.isBull
                    box.set_bgcolor(f.bx, ifvgCol)
                    box.set_border_color(f.bx, color.orange)
                    if f.isBull
                        bullIFVGbar := bar_index
                    else
                        bearIFVGbar := bar_index
                else
                    f.active := false
                    box.delete(f.bx)

// ================================ BOS ========================================
ph = ta.pivothigh(swingLen, swingLen)
pl = ta.pivotlow(swingLen, swingLen)
var float lastPH = na
var float lastPL = na
if not na(ph)
    lastPH := ph
if not na(pl)
    lastPL := pl

bullBOS = not na(lastPH) and close > lastPH and close[1] <= lastPH
bearBOS = not na(lastPL) and close < lastPL and close[1] >= lastPL

var int bullBOSbar = na
var int bearBOSbar = na
var array<label> bosLbls = array.new<label>()

if showBOS and bullBOS
    bullBOSbar := bar_index
    array.push(bosLbls, label.new(bar_index, lastPH, "BOS", style = label.style_label_down, color = bullCol, textcolor = color.white, size = size.tiny))
if showBOS and bearBOS
    bearBOSbar := bar_index
    array.push(bosLbls, label.new(bar_index, lastPL, "BOS", style = label.style_label_up, color = bearCol, textcolor = color.white, size = size.tiny))
while array.size(bosLbls) > 25
    label.delete(array.shift(bosLbls))

// ================================ CISD =======================================
// Open of the first candle of the last opposite-direction run. A close back
// through it = change in state of delivery.
isBullC = close > open
isBearC = close < open
var float downFirstOpen = na
var float upFirstOpen   = na
if isBearC and not isBearC[1]
    downFirstOpen := open
if isBullC and not isBullC[1]
    upFirstOpen := open

bullCISD = showCISD and not na(downFirstOpen) and close > downFirstOpen and close[1] <= downFirstOpen
bearCISD = showCISD and not na(upFirstOpen)   and close < upFirstOpen   and close[1] >= upFirstOpen

var int bullCISDbar = na
var int bearCISDbar = na
var array<line>  cisdLines = array.new<line>()
var array<label> cisdLbls  = array.new<label>()

if bullCISD
    bullCISDbar := bar_index
    array.push(cisdLines, line.new(bar_index - 1, downFirstOpen, bar_index + 4, downFirstOpen, color = bullCol, width = 2))
    array.push(cisdLbls,  label.new(bar_index, downFirstOpen, "CISD", style = label.style_label_down, color = bullCol, textcolor = color.white, size = size.tiny))
if bearCISD
    bearCISDbar := bar_index
    array.push(cisdLines, line.new(bar_index - 1, upFirstOpen, bar_index + 4, upFirstOpen, color = bearCol, width = 2))
    array.push(cisdLbls,  label.new(bar_index, upFirstOpen, "CISD", style = label.style_label_up, color = bearCol, textcolor = color.white, size = size.tiny))
while array.size(cisdLines) > 15
    line.delete(array.shift(cisdLines))
while array.size(cisdLbls) > 15
    label.delete(array.shift(cisdLbls))

// ============================ Confluence =====================================
f_recent(_b) => not na(_b) and (bar_index - _b) <= confWindow

bFVG  = f_recent(bullFVGbar)
bIFVG = f_recent(bullIFVGbar)
bBOS  = f_recent(bullBOSbar)
bCISD = f_recent(bullCISDbar)
bScore = (bFVG ? 1 : 0) + (bIFVG ? 1 : 0) + (bBOS ? 1 : 0) + (bCISD ? 1 : 0)

sFVG  = f_recent(bearFVGbar)
sIFVG = f_recent(bearIFVGbar)
sBOS  = f_recent(bearBOSbar)
sCISD = f_recent(bearCISDbar)
sScore = (sFVG ? 1 : 0) + (sIFVG ? 1 : 0) + (sBOS ? 1 : 0) + (sCISD ? 1 : 0)

bullRev = bScore >= minConfl
bearRev = sScore >= minConfl

plotshape(bullRev and not bullRev[1], title = "Bull reversal", style = shape.labelup,   location = location.belowbar, color = bullCol, textcolor = color.white, text = "▲ REV", size = size.small)
plotshape(bearRev and not bearRev[1], title = "Bear reversal", style = shape.labeldown, location = location.abovebar, color = bearCol, textcolor = color.white, text = "▼ REV", size = size.small)

alertcondition(bullRev and not bullRev[1], "Bull reversal", "Bullish reversal confluence met (FVG/IFVG/BOS/CISD)")
alertcondition(bearRev and not bearRev[1], "Bear reversal", "Bearish reversal confluence met (FVG/IFVG/BOS/CISD)")

// ============================ Confluence table ===============================
var table tb = table.new(position.top_right, 3, 6, border_width = 1)
hdrBg = color.new(color.black, 20)
f_yn(_b) => _b ? "✓" : "·"
if showTbl and barstate.islast
    table.cell(tb, 0, 0, "Confluence", text_color = color.white, bgcolor = hdrBg)
    table.cell(tb, 1, 0, "Bull",       text_color = color.white, bgcolor = color.new(bullCol, 20))
    table.cell(tb, 2, 0, "Bear",       text_color = color.white, bgcolor = color.new(bearCol, 20))
    table.cell(tb, 0, 1, "FVG",  text_color = color.white, bgcolor = hdrBg)
    table.cell(tb, 1, 1, f_yn(bFVG),  text_color = color.white, bgcolor = bFVG  ? color.new(bullCol, 40) : hdrBg)
    table.cell(tb, 2, 1, f_yn(sFVG),  text_color = color.white, bgcolor = sFVG  ? color.new(bearCol, 40) : hdrBg)
    table.cell(tb, 0, 2, "IFVG", text_color = color.white, bgcolor = hdrBg)
    table.cell(tb, 1, 2, f_yn(bIFVG), text_color = color.white, bgcolor = bIFVG ? color.new(bullCol, 40) : hdrBg)
    table.cell(tb, 2, 2, f_yn(sIFVG), text_color = color.white, bgcolor = sIFVG ? color.new(bearCol, 40) : hdrBg)
    table.cell(tb, 0, 3, "BOS",  text_color = color.white, bgcolor = hdrBg)
    table.cell(tb, 1, 3, f_yn(bBOS),  text_color = color.white, bgcolor = bBOS  ? color.new(bullCol, 40) : hdrBg)
    table.cell(tb, 2, 3, f_yn(sBOS),  text_color = color.white, bgcolor = sBOS  ? color.new(bearCol, 40) : hdrBg)
    table.cell(tb, 0, 4, "CISD", text_color = color.white, bgcolor = hdrBg)
    table.cell(tb, 1, 4, f_yn(bCISD), text_color = color.white, bgcolor = bCISD ? color.new(bullCol, 40) : hdrBg)
    table.cell(tb, 2, 4, f_yn(sCISD), text_color = color.white, bgcolor = sCISD ? color.new(bearCol, 40) : hdrBg)
    table.cell(tb, 0, 5, "REVERSAL", text_color = color.white, bgcolor = hdrBg)
    table.cell(tb, 1, 5, (bullRev ? "▲ " : "") + str.tostring(bScore) + "/4", text_color = color.white, bgcolor = bullRev ? bullCol : hdrBg)
    table.cell(tb, 2, 5, (bearRev ? "▼ " : "") + str.tostring(sScore) + "/4", text_color = color.white, bgcolor = bearRev ? bearCol : hdrBg)

// ============================ 4H timeframe warning ===========================
var label warnLbl = na
if warnTF and barstate.islast
    if timeframe.period != "240"
        if na(warnLbl)
            warnLbl := label.new(bar_index, high, "⚠ Use the 4H timeframe", style = label.style_label_down, color = color.orange, textcolor = color.black, size = size.normal)
        else
            label.set_xy(warnLbl, bar_index, high)
    else if not na(warnLbl)
        label.delete(warnLbl)
        warnLbl := na
````
