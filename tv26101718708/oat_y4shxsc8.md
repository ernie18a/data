# OAT $$$

- url: https://www.tradingview.com/script/Y4shxSc8-OAT/
- type: indicator
- pine_id: PUB;8beac2cb828440c7bd4a27956d280050
- version: 1.0

## Description

Make bread, get rich, feed the family, get married, don't screw ppl ova.

## Source Code

````pine
//  Adapted for: GBPJPY | 1H Timeframe
//  Pine Script v5
// ═══════════════════════════════════════════════════════════════════════════
// TRADING RULES (1H GBPJPY):
//  LONG  — Entry Signal + Bullish Price Action + Green Indicator (Bull CHoCH/BOS)
//  SHORT — Entry Signal + Bearish Price Action + Red Indicator  (Bear CHoCH/BOS)
//  SL    — Use the Indicator SL level (or last swing extreme)
//  TP    — TP1/TP2/TP3 shown on chart, or use 1:2 RR with indicator SL
//  TIP   — Drop to lower TF once Entry signal appears for better RR
// ═══════════════════════════════════════════════════════════════════════════

//@version=5
indicator("Hull Market Structure [GBPJPY]",
          shorttitle    = "HMS · GBPJPY",
          overlay       = true,
          max_lines_count  = 500,
          max_labels_count = 500,
          max_boxes_count  = 200)

// ─────────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// Hull Settings
var GRP_HULL = "⚙️ Hull Settings"
hullLen     = input.int  (50,    "Hull Length",           minval=5,  maxval=500,               group=GRP_HULL)

// Swing Pivot Settings
var GRP_SWG = "⚙️ Swing Settings"
swingLen    = input.int  (5,     "Swing Length (L/R bars)",minval=2, maxval=50,                group=GRP_SWG)

// Signal Settings
var GRP_SIG = "⚙️ Signal Settings"
cooloff     = input.int  (10,    "Signal Cooloff (bars)",  minval=1, maxval=100,               group=GRP_SIG)

// Position Tool
var GRP_POS = "📐 Position Tool"
showTool    = input.bool (true,  "Show Position Tool (CHoCH)",                                 group=GRP_POS)
maxPos      = input.int  (2,     "Max Positions Visible",  minval=1, maxval=5,                 group=GRP_POS)
slBuf       = input.float(0.2,   "SL Buffer %",            minval=0.0, maxval=5.0, step=0.05, group=GRP_POS,
                           tooltip="GBPJPY default 0.20% (wider than BTC due to JPY volatility)")
tp1R        = input.float(1.0,   "TP1 (R Multiple)",       minval=0.1, maxval=20.0, step=0.1, group=GRP_POS)
tp2R        = input.float(2.0,   "TP2 (R Multiple)",       minval=0.1, maxval=20.0, step=0.1, group=GRP_POS)
tp3R        = input.float(3.0,   "TP3 (R Multiple)",       minval=0.1, maxval=20.0, step=0.1, group=GRP_POS)
posExtend   = input.int  (40,    "Extend Levels (bars)",   minval=5,  maxval=300,              group=GRP_POS)

// Visuals
var GRP_VIS = "🎨 Visual Settings"
colorBars   = input.bool (true,  "Color Candles by Structure",                                 group=GRP_VIS)
showHullBnd = input.bool (true,  "Show Hull Band",                                             group=GRP_VIS)
bullCol     = input.color(color.new(#00C853, 0), "Bull Color",                                group=GRP_VIS)
bearCol     = input.color(color.new(#FF1744, 0), "Bear Color",                                group=GRP_VIS)

// ─────────────────────────────────────────────────────────────────────────────
//  COLOR HELPERS
// ─────────────────────────────────────────────────────────────────────────────
bullC10  = color.new(bullCol, 10)
bullC40  = color.new(bullCol, 40)
bullC60  = color.new(bullCol, 60)
bullC80  = color.new(bullCol, 80)
bullC88  = color.new(bullCol, 88)
bearC10  = color.new(bearCol, 10)
bearC40  = color.new(bearCol, 40)
bearC60  = color.new(bearCol, 60)
bearC80  = color.new(bearCol, 80)
bearC88  = color.new(bearCol, 88)

// ─────────────────────────────────────────────────────────────────────────────
//  HULL MOVING AVERAGE ENGINE
//  Formula: HMA = WMA(2 × WMA(close, n/2) − WMA(close, n), √n)
//  Trend direction: HMA > HMA[2] → bullish, HMA < HMA[2] → bearish
// ─────────────────────────────────────────────────────────────────────────────
hullCalc(src, length) =>
    halfLen  = math.round(length / 2)
    sqrtLen  = math.round(math.sqrt(length))
    wmaHalf  = ta.wma(src, halfLen)
    wmaFull  = ta.wma(src, length)
    ta.wma(2.0 * wmaHalf - wmaFull, sqrtLen)

hull     = hullCalc(close, hullLen)
hullLag  = hull[2]
hullBull = hull > hullLag
hullBear = hull < hullLag

// Hull Band Visualization
hullLineColor = hullBull ? bullC40 : bearC40
hullFillColor = hullBull ? bullC88 : bearC88

hullPlot    = plot(showHullBnd ? hull    : na, "Hull",    color=hullLineColor, linewidth=2)
hullLagPlot = plot(showHullBnd ? hullLag : na, "Hull Lag",color=hullLineColor, linewidth=1)
fill(hullPlot, hullLagPlot, color=hullFillColor, title="Hull Band Fill")

// ─────────────────────────────────────────────────────────────────────────────
//  SWING PIVOT DETECTION
//  Pivots are confirmed after swingLen bars on each side
// ─────────────────────────────────────────────────────────────────────────────
rawPivHigh = ta.pivothigh(high, swingLen, swingLen)
rawPivLow  = ta.pivotlow (low,  swingLen, swingLen)

// Confirmed swing high tracking
var float phCur     = na    // most recent confirmed pivot high price
var int   phCurBar  = na    // bar index of the pivot high candle
var float phPrev    = na    // previous confirmed pivot high price
var int   phPrevBar = na

// Confirmed swing low tracking
var float plCur     = na
var int   plCurBar  = na
var float plPrev    = na
var int   plPrevBar = na

if not na(rawPivHigh)
    phPrev    := phCur
    phPrevBar := phCurBar
    phCur     := rawPivHigh
    phCurBar  := bar_index - swingLen   // actual bar the pivot occurred

if not na(rawPivLow)
    plPrev    := plCur
    plPrevBar := plCurBar
    plCur     := rawPivLow
    plCurBar  := bar_index - swingLen

// ─────────────────────────────────────────────────────────────────────────────
//  STRUCTURAL TREND STATE
//   1 = bullish structure   (last structural break was bullish)
//  -1 = bearish structure   (last structural break was bearish)
//   0 = neutral / unset
// ─────────────────────────────────────────────────────────────────────────────
var int structState = 0

// ─────────────────────────────────────────────────────────────────────────────
//  SIGNAL COOLOFF TRACKING (independent per direction)
// ─────────────────────────────────────────────────────────────────────────────
var int lastBullBar = -9999
var int lastBearBar = -9999

bullCoolOK = (bar_index - lastBullBar) >= cooloff
bearCoolOK = (bar_index - lastBearBar) >= cooloff

// ─────────────────────────────────────────────────────────────────────────────
//  BOS / CHoCH BREAK DETECTION
//  BOS   = break in same direction as current structure (trend continuation)
//  CHoCH = break against current structure (trend reversal)
// ─────────────────────────────────────────────────────────────────────────────
var string lastBullLabel = na
var string lastBearLabel = na

bullBreak  = false
bearBreak  = false
bullChoch  = false   // true when bull break is a CHoCH
bearChoch  = false   // true when bear break is a CHoCH
bullBos    = false   // true when bull break is a BOS
bearBos    = false   // true when bear break is a BOS

// ── Bull break: close crosses above last confirmed pivot high during Hull uptrend ──
if hullBull and not na(phCur) and bullCoolOK
    crossAbove = close > phCur and close[1] <= phCur
    if crossAbove
        bullBreak      := true
        lastBullBar    := bar_index
        // CHoCH if prior structure was not bullish; BOS if it was already bullish
        if structState <= 0
            structState    := 1
            bullChoch      := true
            lastBullLabel  := "CHoCH"
        else
            bullBos        := true
            lastBullLabel  := "BOS"

// ── Bear break: close crosses below last confirmed pivot low during Hull downtrend ──
if hullBear and not na(plCur) and bearCoolOK
    crossBelow = close < plCur and close[1] >= plCur
    if crossBelow
        bearBreak      := true
        lastBearBar    := bar_index
        if structState >= 0
            structState    := -1
            bearChoch      := true
            lastBearLabel  := "CHoCH"
        else
            bearBos        := true
            lastBearLabel  := "BOS"

// ─────────────────────────────────────────────────────────────────────────────
//  STRUCTURAL LEVEL LINES & LABELS
//  Dashed line from pivot origin bar → signal bar at the broken level
//  Label (BOS / CHoCH) centered along the line
// ─────────────────────────────────────────────────────────────────────────────
if bullBreak and not na(phCurBar)
    lvl       = phCur
    originBar = phCurBar
    lnCol     = bullChoch ? bullC10 : bullC40
    line.new(originBar, lvl, bar_index, lvl,
             color=lnCol, width=1, style=line.style_dashed)
    midBar    = math.round((originBar + bar_index) / 2)
    label.new(midBar, lvl, lastBullLabel,
              color=color.new(color.black, 100),
              textcolor=lnCol, style=label.style_none, size=size.small)

if bearBreak and not na(plCurBar)
    lvl       = plCur
    originBar = plCurBar
    lnCol     = bearChoch ? bearC10 : bearC40
    line.new(originBar, lvl, bar_index, lvl,
             color=lnCol, width=1, style=line.style_dashed)
    midBar    = math.round((originBar + bar_index) / 2)
    label.new(midBar, lvl, lastBearLabel,
              color=color.new(color.black, 100),
              textcolor=lnCol, style=label.style_none, size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
//  POSITION TOOL ENGINE
//  Fires on CHoCH events only (structural reversals)
//  Draws: Entry · Stop Loss · TP1 · TP2 · TP3 + filled risk/reward zones
//  Entry = close of signal bar (proxy for next-bar market open)
// ─────────────────────────────────────────────────────────────────────────────

// Drawing object stores — all position tool objects live here
// Each position contributes exactly: 5 lines, 4 boxes, 5 labels
var int LINES_PP  = 5
var int BOXES_PP  = 4
var int LABELS_PP = 5

var line[]  ptLines  = array.new_line()
var box[]   ptBoxes  = array.new_box()
var label[] ptLabels = array.new_label()
var int     ptCount  = 0

// ── Helper: remove the oldest position's drawing objects ──
// (always call before adding a new one when at max)
removeOldestPosition() =>
    for _i = 0 to LINES_PP - 1
        if array.size(ptLines) > 0
            line.delete(array.shift(ptLines))
    for _i = 0 to BOXES_PP - 1
        if array.size(ptBoxes) > 0
            box.delete(array.shift(ptBoxes))
    for _i = 0 to LABELS_PP - 1
        if array.size(ptLabels) > 0
            label.delete(array.shift(ptLabels))

// ── Draw a LONG position tool ──
drawLongTool(entryP, signalLow, rightBar) =>
    sl     = signalLow  * (1.0 - slBuf / 100.0)
    risk   = entryP - sl
    tp1    = entryP + risk * tp1R
    tp2    = entryP + risk * tp2R
    tp3    = entryP + risk * tp3R

    // Lines
    l1 = line.new(bar_index, entryP, rightBar, entryP, color=color.white,    width=1, style=line.style_solid)
    l2 = line.new(bar_index, sl,     rightBar, sl,     color=bearC10,        width=1, style=line.style_dotted)
    l3 = line.new(bar_index, tp1,    rightBar, tp1,    color=bullC60,        width=1, style=line.style_dotted)
    l4 = line.new(bar_index, tp2,    rightBar, tp2,    color=bullC40,        width=1, style=line.style_dotted)
    l5 = line.new(bar_index, tp3,    rightBar, tp3,    color=bullC10,        width=1, style=line.style_dotted)
    array.push(ptLines, l1)
    array.push(ptLines, l2)
    array.push(ptLines, l3)
    array.push(ptLines, l4)
    array.push(ptLines, l5)

    // Boxes
    b1 = box.new(bar_index, entryP, rightBar, sl,     bgcolor=bearC80, border_color=bearC60)  // risk zone
    b2 = box.new(bar_index, tp1,    rightBar, entryP, bgcolor=bullC88, border_color=bullC80)  // TP1 zone
    b3 = box.new(bar_index, tp2,    rightBar, tp1,    bgcolor=bullC80, border_color=bullC60)  // TP2 zone
    b4 = box.new(bar_index, tp3,    rightBar, tp2,    bgcolor=bullC60, border_color=bullC40)  // TP3 zone
    array.push(ptBoxes, b1)
    array.push(ptBoxes, b2)
    array.push(ptBoxes, b3)
    array.push(ptBoxes, b4)

    // Labels
    lb1 = label.new(rightBar, entryP, "  ENTRY", color=color.new(color.black,100), textcolor=color.white, style=label.style_label_right, size=size.tiny)
    lb2 = label.new(rightBar, sl,     "  SL",    color=color.new(color.black,100), textcolor=bearC10,    style=label.style_label_right, size=size.tiny)
    lb3 = label.new(rightBar, tp1,    "  TP1",   color=color.new(color.black,100), textcolor=bullC40,    style=label.style_label_right, size=size.tiny)
    lb4 = label.new(rightBar, tp2,    "  TP2",   color=color.new(color.black,100), textcolor=bullC40,    style=label.style_label_right, size=size.tiny)
    lb5 = label.new(rightBar, tp3,    "  TP3",   color=color.new(color.black,100), textcolor=bullC10,    style=label.style_label_right, size=size.tiny)
    array.push(ptLabels, lb1)
    array.push(ptLabels, lb2)
    array.push(ptLabels, lb3)
    array.push(ptLabels, lb4)
    array.push(ptLabels, lb5)

// ── Draw a SHORT position tool ──
drawShortTool(entryP, signalHigh, rightBar) =>
    sl     = signalHigh * (1.0 + slBuf / 100.0)
    risk   = sl - entryP
    tp1    = entryP - risk * tp1R
    tp2    = entryP - risk * tp2R
    tp3    = entryP - risk * tp3R

    // Lines
    l1 = line.new(bar_index, entryP, rightBar, entryP, color=color.white,    width=1, style=line.style_solid)
    l2 = line.new(bar_index, sl,     rightBar, sl,     color=bullC10,        width=1, style=line.style_dotted)
    l3 = line.new(bar_index, tp1,    rightBar, tp1,    color=bearC60,        width=1, style=line.style_dotted)
    l4 = line.new(bar_index, tp2,    rightBar, tp2,    color=bearC40,        width=1, style=line.style_dotted)
    l5 = line.new(bar_index, tp3,    rightBar, tp3,    color=bearC10,        width=1, style=line.style_dotted)
    array.push(ptLines, l1)
    array.push(ptLines, l2)
    array.push(ptLines, l3)
    array.push(ptLines, l4)
    array.push(ptLines, l5)

    // Boxes
    b1 = box.new(bar_index, sl,     rightBar, entryP, bgcolor=bullC80, border_color=bullC60)  // risk zone
    b2 = box.new(bar_index, entryP, rightBar, tp1,    bgcolor=bearC88, border_color=bearC80)  // TP1 zone
    b3 = box.new(bar_index, tp1,    rightBar, tp2,    bgcolor=bearC80, border_color=bearC60)  // TP2 zone
    b4 = box.new(bar_index, tp2,    rightBar, tp3,    bgcolor=bearC60, border_color=bearC40)  // TP3 zone
    array.push(ptBoxes, b1)
    array.push(ptBoxes, b2)
    array.push(ptBoxes, b3)
    array.push(ptBoxes, b4)

    // Labels
    lb1 = label.new(rightBar, entryP, "  ENTRY", color=color.new(color.black,100), textcolor=color.white, style=label.style_label_right, size=size.tiny)
    lb2 = label.new(rightBar, sl,     "  SL",    color=color.new(color.black,100), textcolor=bullC10,    style=label.style_label_right, size=size.tiny)
    lb3 = label.new(rightBar, tp1,    "  TP1",   color=color.new(color.black,100), textcolor=bearC40,    style=label.style_label_right, size=size.tiny)
    lb4 = label.new(rightBar, tp2,    "  TP2",   color=color.new(color.black,100), textcolor=bearC40,    style=label.style_label_right, size=size.tiny)
    lb5 = label.new(rightBar, tp3,    "  TP3",   color=color.new(color.black,100), textcolor=bearC10,    style=label.style_label_right, size=size.tiny)
    array.push(ptLabels, lb1)
    array.push(ptLabels, lb2)
    array.push(ptLabels, lb3)
    array.push(ptLabels, lb4)
    array.push(ptLabels, lb5)

// ── Trigger position tool on CHoCH ──
if showTool and (bullChoch or bearChoch)
    if ptCount >= maxPos
        removeOldestPosition()
        ptCount := ptCount - 1

    rightEdge = bar_index + posExtend

    if bullChoch
        drawLongTool (close, low,  rightEdge)
    else
        drawShortTool(close, high, rightEdge)

    ptCount := ptCount + 1

// ─────────────────────────────────────────────────────────────────────────────
//  CANDLE COLORING (structural trend state)
// ─────────────────────────────────────────────────────────────────────────────
candleColor = if colorBars
    if structState == 1
        bullC60
    else if structState == -1
        bearC60
    else
        color.new(color.gray, 60)
else
    na

barcolor(candleColor, title="Structure Candle Color")

// ─────────────────────────────────────────────────────────────────────────────
//  SIGNAL SHAPE MARKERS
//  Large triangle  = CHoCH (reversal — primary entry signal)
//  Small triangle  = BOS   (continuation — secondary entry signal)
// ─────────────────────────────────────────────────────────────────────────────
plotshape(bullChoch, "🟢 Bull CHoCH (LONG Entry)",
          style    = shape.triangleup,
          location = location.belowbar,
          color    = bullCol,
          size     = size.normal,
          text     = "LONG")

plotshape(bullBos, "🟢 Bull BOS (Continuation)",
          style    = shape.triangleup,
          location = location.belowbar,
          color    = bullC60,
          size     = size.tiny)

plotshape(bearChoch, "🔴 Bear CHoCH (SHORT Entry)",
          style    = shape.triangledown,
          location = location.abovebar,
          color    = bearCol,
          size     = size.normal,
          text     = "SHORT")

plotshape(bearBos, "🔴 Bear BOS (Continuation)",
          style    = shape.triangledown,
          location = location.abovebar,
          color    = bearC60,
          size     = size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
//  LIVE STATUS TABLE (top-right corner)
// ─────────────────────────────────────────────────────────────────────────────
var table tbl = table.new(
     position     = position.top_right,
     columns      = 2,
     rows         = 6,
     bgcolor      = color.new(#1A1A1A, 5),
     border_color = color.new(color.gray, 60),
     border_width = 1,
     frame_color  = color.new(color.gray, 40),
     frame_width  = 1)

if barstate.islast
    // Header
    table.cell(tbl, 0, 0, "HMS · GBPJPY",
               text_color=color.white, text_size=size.small,
               bgcolor=color.new(#1A1A1A, 0), text_halign=text.align_center)
    table.cell(tbl, 1, 0, "1H",
               text_color=color.silver, text_size=size.small,
               bgcolor=color.new(#1A1A1A, 0), text_halign=text.align_center)

    // Hull Trend
    hTrendTxt = hullBull ? "▲  BULLISH" : "▼  BEARISH"
    hTrendCol = hullBull ? bullCol : bearCol
    table.cell(tbl, 0, 1, "Hull Trend",  text_color=color.new(color.silver, 20), text_size=size.tiny)
    table.cell(tbl, 1, 1, hTrendTxt,     text_color=hTrendCol, text_size=size.tiny)

    // Structure State
    sTxt = structState ==  1 ? "▲  BULLISH" : structState == -1 ? "▼  BEARISH" : "—  NEUTRAL"
    sCol = structState ==  1 ? bullCol       : structState == -1 ? bearCol       : color.gray
    table.cell(tbl, 0, 2, "Structure",   text_color=color.new(color.silver, 20), text_size=size.tiny)
    table.cell(tbl, 1, 2, sTxt,          text_color=sCol, text_size=size.tiny)

    // Directional Bias (alignment of both layers)
    bothBull = hullBull and structState ==  1
    bothBear = hullBear and structState == -1
    biasTxt  = bothBull ? "🟢  LONG" : bothBear ? "🔴  SHORT" : "⚪  WAIT"
    biasCol  = bothBull ? bullCol : bothBear ? bearCol : color.gray
    table.cell(tbl, 0, 3, "Bias",        text_color=color.new(color.silver, 20), text_size=size.tiny)
    table.cell(tbl, 1, 3, biasTxt,       text_color=biasCol, text_size=size.small)

    // Hull Length (for reference)
    table.cell(tbl, 0, 4, "Hull Len",    text_color=color.new(color.silver, 20), text_size=size.tiny)
    table.cell(tbl, 1, 4, str.tostring(hullLen), text_color=color.white, text_size=size.tiny)

    // Swing Length
    table.cell(tbl, 0, 5, "Swing Len",   text_color=color.new(color.silver, 20), text_size=size.tiny)
    table.cell(tbl, 1, 5, str.tostring(swingLen), text_color=color.white, text_size=size.tiny)

// ─────────────────────────────────────────────────────────────────────────────
//  ALERTS
//  Set frequency to "Once Per Bar Close" for best results on 1H GBPJPY
// ─────────────────────────────────────────────────────────────────────────────
alertcondition(bullBos,
     title   = "GBPJPY 🟢 Bull BOS",
     message = "GBPJPY | 🟢 BULL BOS — Break of Structure (Continuation)\nHull: Bullish ✅ | Structure: Bullish ✅\nConsider LONG on pullback. Drop TF for entry.")

alertcondition(bullChoch,
     title   = "GBPJPY 🟢 Bull CHoCH — LONG SETUP",
     message = "GBPJPY | 🟢 BULL CHoCH — Change of Character (REVERSAL)\nHull: Bullish ✅ | Structure flipped Bullish ⬆️\n>>> LONG ENTRY SIGNAL — Check position tool for SL/TP levels.\nDrop TF for better RR.")

alertcondition(bearBos,
     title   = "GBPJPY 🔴 Bear BOS",
     message = "GBPJPY | 🔴 BEAR BOS — Break of Structure (Continuation)\nHull: Bearish ✅ | Structure: Bearish ✅\nConsider SHORT on pullback. Drop TF for entry.")

alertcondition(bearChoch,
     title   = "GBPJPY 🔴 Bear CHoCH — SHORT SETUP",
     message = "GBPJPY | 🔴 BEAR CHoCH — Change of Character (REVERSAL)\nHull: Bearish ✅ | Structure flipped Bearish ⬇️\n>>> SHORT ENTRY SIGNAL — Check position tool for SL/TP levels.\nDrop TF for better RR.")

alertcondition(bullChoch or bearChoch,
     title   = "GBPJPY ⚡ Any CHoCH (Entry Signal)",
     message = "GBPJPY | ⚡ CHoCH SIGNAL FIRED\nDirection: {{ticker}} — Check chart for full position tool.")

alertcondition(bullBreak or bearBreak,
     title   = "GBPJPY 📊 Any BOS or CHoCH",
     message = "GBPJPY | Market structure event detected on 1H chart.")

// ═══════════════════════════════════════════════════════════════════════════
//  END OF SCRIPT
// ═══════════════════════════════════════════════════════════════════════════
````
