# KN - Smart TP SL Signals

- url: https://www.tradingview.com/script/Xmti9o4w-KN-Smart-TP-SL-Signals/
- type: indicator
- pine_id: PUB;c49a225ed0be4a2c9dd9b3d55032b060
- version: 1.0

## Description

KN - Smart TP SL Signals is an EMA crossover trading indicator with built-in ATR-based risk management.

Features:
• Buy and Sell signals using EMA crossover
• Automatic Stop Loss and Take Profit levels
• TP1 / TP2 / TP3 visualization
• Dynamic risk-reward zones
• Automatic TP/SL tracking
• Expanding trade projection lines
• Clean and simple chart visualization

This indicator is designed for educational and chart analysis purposes only.

Not financial advice.

## Source Code

````pine
//@version=6
indicator('KN - Smart TP SL Signals', overlay = true, max_labels_count = 500, max_lines_count = 500)

// ═══════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════
emaFastLen      = input.int(5, 'Fast EMA', minval = 1)
emaSlowLen      = input.int(13, 'Slow EMA', minval = 1)
atrLen          = input.int(14, 'ATR Period', minval = 1)

slAtrMult       = input.float(1.5, 'SL ATR Multiplier', step = 0.1)

rr1             = input.float(1.0, 'TP1 RR', step = 0.1)
rr2             = input.float(2.0, 'TP2 RR', step = 0.1)
rr3             = input.float(3.0, 'TP3 RR', step = 0.1)

showRisk        = input.bool(true, 'Show TP/SL')
labelOffset     = input.int(15, 'Initial Line Length', minval = 5)

// CHỈ HIỆN TÍN HIỆU MỚI NHẤT
showOnlyLatest  = input.bool(true, 'Show Only Latest Signal')

// COLORS
bullColor       = input.color(color.lime, 'Buy Color')
bearColor       = input.color(color.red, 'Sell Color')

tpColor         = input.color(color.aqua, 'TP Color')
slColor         = input.color(color.orange, 'SL Color')

profitFillColor = input.color(color.new(color.green, 85), 'Profit Fill')
lossFillColor   = input.color(color.new(color.red, 85), 'Loss Fill')

// ═══════════════════════════════════════
// EMA SIGNAL
// ═══════════════════════════════════════
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
atrVal  = ta.atr(atrLen)

buySignal  = ta.crossover(emaFast, emaSlow)
sellSignal = ta.crossunder(emaFast, emaSlow)

plot(emaFast, color = color.green, title = 'EMA Fast')
plot(emaSlow, color = color.red, title = 'EMA Slow')

// ═══════════════════════════════════════
// SIGNAL LABELS
// ═══════════════════════════════════════
var label buyLbl  = na
var label sellLbl = na

if buySignal

    // XÓA LABEL BUY CŨ
    if showOnlyLatest and not na(buyLbl)
        label.delete(buyLbl)

    buyLbl := label.new(
         bar_index,
         low,
         "BUY",
         style = label.style_label_up,
         color = bullColor,
         textcolor = color.white,
         size = size.small)

if sellSignal

    // XÓA LABEL SELL CŨ
    if showOnlyLatest and not na(sellLbl)
        label.delete(sellLbl)

    sellLbl := label.new(
         bar_index,
         high,
         "SELL",
         style = label.style_label_down,
         color = bearColor,
         textcolor = color.white,
         size = size.small)

// ═══════════════════════════════════════
// TRADE VARIABLES
// ═══════════════════════════════════════
var int   tradeDir   = 0
var float tradeEntry = na
var float tradeSl    = na
var float tradeTp1   = na
var float tradeTp2   = na
var float tradeTp3   = na

var bool tp1Hit = false
var bool tp2Hit = false
var bool tp3Hit = false
var bool slHit  = false

var int tradeStartBar = na

// LINES
var line lineEntry = na
var line lineSL    = na
var line lineTp1   = na
var line lineTp2   = na
var line lineTp3   = na

// LABELS
var label lbEntry = na
var label lbSL    = na
var label lbTp1   = na
var label lbTp2   = na
var label lbTp3   = na

// BOXES
var box profitBox = na
var box lossBox   = na

// ═══════════════════════════════════════
// BUY
// ═══════════════════════════════════════
if buySignal

    risk = atrVal * slAtrMult

    tradeDir   := 1
    tradeEntry := close
    tradeSl    := close - risk

    tradeTp1   := close + risk * rr1
    tradeTp2   := close + risk * rr2
    tradeTp3   := close + risk * rr3

    tradeStartBar := bar_index

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit  := false

// ═══════════════════════════════════════
// SELL
// ═══════════════════════════════════════
if sellSignal

    risk = atrVal * slAtrMult

    tradeDir   := -1
    tradeEntry := close
    tradeSl    := close + risk

    tradeTp1   := close - risk * rr1
    tradeTp2   := close - risk * rr2
    tradeTp3   := close - risk * rr3

    tradeStartBar := bar_index

    tp1Hit := false
    tp2Hit := false
    tp3Hit := false
    slHit  := false

// ═══════════════════════════════════════
// CREATE OBJECTS
// ═══════════════════════════════════════
if showRisk

    if (buySignal or sellSignal)

        // DELETE OLD
        line.delete(lineEntry)
        line.delete(lineSL)
        line.delete(lineTp1)
        line.delete(lineTp2)
        line.delete(lineTp3)

        label.delete(lbEntry)
        label.delete(lbSL)
        label.delete(lbTp1)
        label.delete(lbTp2)
        label.delete(lbTp3)

        box.delete(profitBox)
        box.delete(lossBox)

        // START SIZE
        lineEnd  = bar_index + labelOffset
        labelPos = lineEnd + 2

        // LINES
        lineEntry := line.new(bar_index, tradeEntry, lineEnd, tradeEntry, color=color.gray, width=2)

        lineSL := line.new(bar_index, tradeSl, lineEnd, tradeSl, color=slColor, width=2)

        lineTp1 := line.new(bar_index, tradeTp1, lineEnd, tradeTp1, color=tpColor, width=1, style=line.style_dashed)

        lineTp2 := line.new(bar_index, tradeTp2, lineEnd, tradeTp2, color=tpColor, width=1, style=line.style_dashed)

        lineTp3 := line.new(bar_index, tradeTp3, lineEnd, tradeTp3, color=tpColor, width=2)

        // LABELS
        lbEntry := label.new(labelPos, tradeEntry,
             'ENTRY ' + str.tostring(tradeEntry, format.mintick),
             style = label.style_label_left,
             color = color.new(color.gray, 30),
             textcolor = color.white)

        lbSL := label.new(labelPos, tradeSl,
             'SL ' + str.tostring(tradeSl, format.mintick),
             style = label.style_label_left,
             color = color.new(slColor, 40),
             textcolor = color.white)

        lbTp1 := label.new(labelPos, tradeTp1,
             'TP1 ' + str.tostring(tradeTp1, format.mintick),
             style = label.style_label_left,
             color = color.new(tpColor, 40),
             textcolor = color.white)

        lbTp2 := label.new(labelPos, tradeTp2,
             'TP2 ' + str.tostring(tradeTp2, format.mintick),
             style = label.style_label_left,
             color = color.new(tpColor, 40),
             textcolor = color.white)

        lbTp3 := label.new(labelPos, tradeTp3,
             'TP3 ' + str.tostring(tradeTp3, format.mintick),
             style = label.style_label_left,
             color = color.new(tpColor, 40),
             textcolor = color.white)

        // PROFIT ZONE
        profitTop    = tradeDir == 1 ? tradeTp3 : tradeEntry
        profitBottom = tradeDir == 1 ? tradeEntry : tradeTp3

        profitBox := box.new(
             left = bar_index,
             top = profitTop,
             right = lineEnd,
             bottom = profitBottom,
             bgcolor = profitFillColor,
             border_width = 0)

        // LOSS ZONE
        lossTop    = tradeDir == 1 ? tradeEntry : tradeSl
        lossBottom = tradeDir == 1 ? tradeSl : tradeEntry

        lossBox := box.new(
             left = bar_index,
             top = lossTop,
             right = lineEnd,
             bottom = lossBottom,
             bgcolor = lossFillColor,
             border_width = 0)

// ═══════════════════════════════════════
// TP/SL HIT
// ═══════════════════════════════════════
if tradeDir == 1

    if high >= tradeTp1 and not tp1Hit
        tp1Hit := true
        line.set_color(lineTp1, color.green)
        line.set_style(lineTp1, line.style_solid)
        label.set_text(lbTp1, 'TP1 ✓')
        label.set_color(lbTp1, color.new(color.green, 40))

    if high >= tradeTp2 and not tp2Hit
        tp2Hit := true
        line.set_color(lineTp2, color.green)
        line.set_style(lineTp2, line.style_solid)
        label.set_text(lbTp2, 'TP2 ✓')
        label.set_color(lbTp2, color.new(color.green, 40))

    if high >= tradeTp3 and not tp3Hit
        tp3Hit := true
        line.set_color(lineTp3, color.green)
        line.set_style(lineTp3, line.style_solid)
        label.set_text(lbTp3, 'TP3 ✓')
        label.set_color(lbTp3, color.new(color.green, 40))

    if low <= tradeSl and not slHit
        slHit := true
        line.set_color(lineSL, color.red)
        label.set_text(lbSL, 'SL ✕')
        label.set_color(lbSL, color.new(color.red, 40))

if tradeDir == -1

    if low <= tradeTp1 and not tp1Hit
        tp1Hit := true
        line.set_color(lineTp1, color.green)
        line.set_style(lineTp1, line.style_solid)
        label.set_text(lbTp1, 'TP1 ✓')
        label.set_color(lbTp1, color.new(color.green, 40))

    if low <= tradeTp2 and not tp2Hit
        tp2Hit := true
        line.set_color(lineTp2, color.green)
        line.set_style(lineTp2, line.style_solid)
        label.set_text(lbTp2, 'TP2 ✓')
        label.set_color(lbTp2, color.new(color.green, 40))

    if low <= tradeTp3 and not tp3Hit
        tp3Hit := true
        line.set_color(lineTp3, color.green)
        line.set_style(lineTp3, line.style_solid)
        label.set_text(lbTp3, 'TP3 ✓')
        label.set_color(lbTp3, color.new(color.green, 40))

    if high >= tradeSl and not slHit
        slHit := true
        line.set_color(lineSL, color.red)
        label.set_text(lbSL, 'SL ✕')
        label.set_color(lbSL, color.new(color.red, 40))

// ═══════════════════════════════════════
// AUTO EXPAND UNTIL TP3 OR SL HIT
// ═══════════════════════════════════════
tradeFinished = tp3Hit or slHit

if tradeDir != 0 and not na(lineEntry)

    // CHƯA HIT TP3/SL → TỰ ĐỘNG MỞ RỘNG
    dynamicEnd = tradeFinished ? line.get_x2(lineEntry) : bar_index + labelOffset

    line.set_x2(lineEntry, dynamicEnd)
    line.set_x2(lineSL, dynamicEnd)
    line.set_x2(lineTp1, dynamicEnd)
    line.set_x2(lineTp2, dynamicEnd)
    line.set_x2(lineTp3, dynamicEnd)

    labelPos = dynamicEnd + 2

    label.set_x(lbEntry, labelPos)
    label.set_x(lbSL, labelPos)
    label.set_x(lbTp1, labelPos)
    label.set_x(lbTp2, labelPos)
    label.set_x(lbTp3, labelPos)

    // EXPAND BOXES
    box.set_right(profitBox, dynamicEnd)
    box.set_right(lossBox, dynamicEnd)

alertcondition(buySignal, title='Buy Signal', message='KN Buy Signal')
alertcondition(sellSignal, title='Sell Signal', message='KN Sell Signal')
````
