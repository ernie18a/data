# Supertrend Scalping

- url: https://www.tradingview.com/script/7ta14MGG/
- type: indicator
- pine_id: PUB;8f748ca905df4345829fb3ec4a45570c
- version: 1.0

## Description

This Pine Script indicator called “Supertrend Scalping” is designed for scalping strategies and is built around the Supertrend indicator, enhanced with a complete trade management system including multiple Take Profit (TP) levels and a dynamic Stop Loss (SL).

The script begins by calculating the ATR (Average True Range), which measures market volatility. The user can choose between the standard ATR (RMA) or a simple moving average version (SMA). This ATR is then used to construct the Supertrend bands by adding and subtracting a multiple of the ATR from a price source (by default, hl2). These bands adjust dynamically and define the trend: when price breaks above the upper band, the trend turns bullish; when it breaks below the lower band, the trend becomes bearish.

Trading signals are generated when the trend changes direction. A BUY (LONG) signal appears when the trend shifts from bearish to bullish, while a SELL (SHORT) signal appears when it shifts from bullish to bearish. At each new signal, the script initializes a virtual trade using the current closing price as the entry point.

The core strength of this script lies in its trade management system. It automatically calculates three Take Profit levels (TP1, TP2, TP3) and an initial Stop Loss, all based on configurable ATR multiples. These levels are displayed on the chart using colored lines and labels. The script then continuously monitors price action to detect when these levels are reached.

When a Take Profit level is hit, it is visually removed. If TP1 is reached, the Stop Loss can be moved to the entry price (break-even). If TP2 is reached, the Stop Loss is moved up to the TP1 level. This creates a smart trailing stop mechanism that progressively locks in profits. If either TP3 or the Stop Loss is hit, the trade is fully closed and all visual elements are cleared.

Additionally, the script updates label positions in real time so they follow the current bar, and it highlights the active trend with a colored background (green for bullish, red for bearish). It also includes alert conditions for entry signals as well as TP and SL hits.

In summary, this indicator goes beyond simple signal generation by offering a complete scalping framework, combining entry signals, structured profit targets, risk management, and volatility-based adaptability.

## Source Code

````pine
//@version=5
indicator("Supertrend Scalping", overlay=true, format=format.price, precision=5)

// ─── INPUTS ────────────────────────────────────────────────────────────────────
atrPeriod  = input.int(7,     "ATR Period",                minval=1)
src        = input.source(hl2,"Source")
mult       = input.float(2.0, "ATR Multiplier",            step=0.1, minval=0.5)
changeATR  = input.bool(true, "ATR RMA (sinon SMA)")
showLabels = input.bool(true, "Afficher Labels")
showTPSL   = input.bool(true, "Afficher TP / SL")
tp1Ratio   = input.float(1.0, "Ratio TP1 (x ATR)",        step=0.1, minval=0.3)
tp2Ratio   = input.float(2.0, "Ratio TP2 (x ATR)",        step=0.1, minval=0.3)
tp3Ratio   = input.float(3.0, "Ratio TP3 (x ATR)",        step=0.1, minval=0.3)
slRatio    = input.float(1.0, "Ratio SL initial (x ATR)", step=0.1, minval=0.3)
trailSL    = input.bool(true, "SL Trailing (TP1→BE  /  TP2→TP1)")
highlight  = input.bool(true, "Zone colorée")

// ─── ATR ───────────────────────────────────────────────────────────────────────
atr = changeATR ? ta.atr(atrPeriod) : ta.sma(ta.tr, atrPeriod)

// ─── SUPERTREND ────────────────────────────────────────────────────────────────
upRaw  = src - mult * atr
dnRaw  = src + mult * atr

var float up = na
var float dn = na
up := close[1] > nz(up[1], upRaw) ? math.max(upRaw, nz(up[1])) : upRaw
dn := close[1] < nz(dn[1], dnRaw) ? math.min(dnRaw, nz(dn[1])) : dnRaw

var int trend = 1
trend := nz(trend[1], 1)
trend := trend == -1 and close > nz(dn[1]) ? 1  : trend
trend := trend ==  1 and close < nz(up[1]) ? -1 : trend

buySignal  = trend ==  1 and trend[1] == -1
sellSignal = trend == -1 and trend[1] ==  1

// ─── ÉTAT ─────────────────────────────────────────────────────────────────────
var float entryPrice = na
var int   sigDir     = 0        //  1 = long,  -1 = short,  0 = inactif
var float tp1Val     = na
var float tp2Val     = na
var float tp3Val     = na
var float slVal      = na

var bool tp1Active   = false
var bool tp2Active   = false
var bool tp3Active   = false
var bool slActive    = false

var line  tp1Line    = na
var line  tp2Line    = na
var line  tp3Line    = na
var line  slLine     = na
var label tp1Lbl     = na
var label tp2Lbl     = na
var label tp3Lbl     = na
var label slLbl      = na

// Couleurs ──────────────────────────────────────────────────────────────────────
col_tp1 = color.new(#00C853, 15)   // Vert vif
col_tp2 = color.new(#00BFA5, 15)   // Teal
col_tp3 = color.new(#2979FF, 15)   // Bleu
col_sl  = color.new(#FF1744, 15)   // Rouge  (SL initial)
col_be  = color.new(#FF9800, 15)   // Orange (SL trailé)

// ─── RESET COMPLET (helper inline) ────────────────────────────────────────────
resetAll() =>
    line.delete(tp1Line)
    line.delete(tp2Line)
    line.delete(tp3Line)
    line.delete(slLine)
    label.delete(tp1Lbl)
    label.delete(tp2Lbl)
    label.delete(tp3Lbl)
    label.delete(slLbl)

// ─── NOUVEAU SIGNAL ────────────────────────────────────────────────────────────
if (buySignal or sellSignal) and showTPSL
    resetAll()

    entryPrice := close
    sigDir     := buySignal ? 1 : -1

    tp1Val := buySignal ? close + tp1Ratio * atr : close - tp1Ratio * atr
    tp2Val := buySignal ? close + tp2Ratio * atr : close - tp2Ratio * atr
    tp3Val := buySignal ? close + tp3Ratio * atr : close - tp3Ratio * atr
    slVal  := buySignal ? close - slRatio  * atr : close + slRatio  * atr

    tp1Active := true
    tp2Active := true
    tp3Active := true
    slActive  := true

    // Lignes (épaisseur croissante TP1 → TP3)
    tp1Line := line.new(bar_index, tp1Val, bar_index + 1, tp1Val,
         extend=extend.right, color=col_tp1, width=1, style=line.style_dashed)
    tp2Line := line.new(bar_index, tp2Val, bar_index + 1, tp2Val,
         extend=extend.right, color=col_tp2, width=2, style=line.style_dashed)
    tp3Line := line.new(bar_index, tp3Val, bar_index + 1, tp3Val,
         extend=extend.right, color=col_tp3, width=2, style=line.style_dashed)
    slLine  := line.new(bar_index, slVal,  bar_index + 1, slVal,
         extend=extend.right, color=col_sl,  width=1, style=line.style_dashed)

    // Labels
    tp1Lbl := label.new(bar_index, tp1Val, text="TP1",
         color=col_tp1, textcolor=color.white,
         style=label.style_label_left, size=size.tiny)
    tp2Lbl := label.new(bar_index, tp2Val, text="TP2",
         color=col_tp2, textcolor=color.white,
         style=label.style_label_left, size=size.tiny)
    tp3Lbl := label.new(bar_index, tp3Val, text="TP3",
         color=col_tp3, textcolor=color.white,
         style=label.style_label_left, size=size.tiny)
    slLbl  := label.new(bar_index, slVal,  text="SL",
         color=col_sl,  textcolor=color.white,
         style=label.style_label_left, size=size.tiny)

// ─── MISE À JOUR POSITION DES LABELS (suivent la barre courante) ──────────────
if sigDir != 0 and not (buySignal or sellSignal) and showTPSL
    if tp1Active
        label.set_x(tp1Lbl, bar_index)
    if tp2Active
        label.set_x(tp2Lbl, bar_index)
    if tp3Active
        label.set_x(tp3Lbl, bar_index)
    if slActive
        label.set_x(slLbl, bar_index)

// ─── LOGIQUE HITS ─────────────────────────────────────────────────────────────
if sigDir != 0 and not (buySignal or sellSignal) and showTPSL

    hitTP1 = tp1Active and (sigDir == 1 ? high >= tp1Val : low  <= tp1Val)
    hitTP2 = tp2Active and (sigDir == 1 ? high >= tp2Val : low  <= tp2Val)
    hitTP3 = tp3Active and (sigDir == 1 ? high >= tp3Val : low  <= tp3Val)
    hitSL  = slActive  and (sigDir == 1 ? low  <= slVal  : high >= slVal)

    // ── TP3 ou SL → on ferme tout ──────────────────────────────────────────
    if hitTP3 or hitSL
        resetAll()
        tp1Line   := na
        tp2Line   := na
        tp3Line   := na
        slLine    := na
        tp1Lbl    := na
        tp2Lbl    := na
        tp3Lbl    := na
        slLbl     := na
        tp1Active := false
        tp2Active := false
        tp3Active := false
        slActive  := false
        sigDir    := 0

    else
        // ── TP1 touché ────────────────────────────────────────────────────
        if hitTP1
            line.delete(tp1Line)
            label.delete(tp1Lbl)
            tp1Line   := na
            tp1Lbl    := na
            tp1Active := false

        // ── TP2 touché ────────────────────────────────────────────────────
        if hitTP2
            line.delete(tp2Line)
            label.delete(tp2Lbl)
            tp2Line   := na
            tp2Lbl    := na
            tp2Active := false

        // ── SL TRAILING ──────────────────────────────────────────────────
        //    TP2 touché → SL monte au niveau TP1
        //    TP1 touché seul → SL monte au Breakeven (entry)
        if trailSL and slActive
            if hitTP2
                line.delete(slLine)
                label.delete(slLbl)
                slVal  := tp1Val
                slLine := line.new(bar_index, slVal, bar_index + 1, slVal,
                     extend=extend.right, color=col_be, width=1, style=line.style_dashed)
                slLbl  := label.new(bar_index, slVal, text="SL+",
                     color=col_be, textcolor=color.white,
                     style=label.style_label_left, size=size.tiny)

            else if hitTP1
                line.delete(slLine)
                label.delete(slLbl)
                slVal  := entryPrice
                slLine := line.new(bar_index, slVal, bar_index + 1, slVal,
                     extend=extend.right, color=col_be, width=1, style=line.style_dashed)
                slLbl  := label.new(bar_index, slVal, text="BE",
                     color=col_be, textcolor=color.white,
                     style=label.style_label_left, size=size.tiny)

// ─── TRACÉ SUPERTREND ─────────────────────────────────────────────────────────
upPlot = plot(trend ==  1 ? up : na, "Hausse",
     color=color.new(#00C853, 0), style=plot.style_linebr, linewidth=2)
dnPlot = plot(trend == -1 ? dn : na, "Baisse",
     color=color.new(#FF1744, 0), style=plot.style_linebr, linewidth=2)

midPlot = plot(ohlc4, display=display.none)
fill(midPlot, upPlot, color=highlight and trend ==  1 ? color.new(#00C853, 92) : na)
fill(midPlot, dnPlot, color=highlight and trend == -1 ? color.new(#FF1744, 92) : na)

// ─── LABELS SIGNAL ─────────────────────────────────────────────────────────────
if buySignal and showLabels
    label.new(bar_index, low, text="▲ LONG",
         color=color.new(#00C853, 0), textcolor=color.white,
         style=label.style_label_up, size=size.small, yloc=yloc.belowbar)

if sellSignal and showLabels
    label.new(bar_index, high, text="▼ SHORT",
         color=color.new(#FF1744, 0), textcolor=color.white,
         style=label.style_label_down, size=size.small, yloc=yloc.abovebar)

// ─── ALERTES ──────────────────────────────────────────────────────────────────
alertcondition(buySignal,  "Long Signal",  "Supertrend Scalping — LONG !")
alertcondition(sellSignal, "Short Signal", "Supertrend Scalping — SHORT !")
alertcondition(tp1Active and (sigDir == 1 ? high >= tp1Val : low  <= tp1Val), "TP1 atteint", "TP1 touché !")
alertcondition(tp2Active and (sigDir == 1 ? high >= tp2Val : low  <= tp2Val), "TP2 atteint", "TP2 touché !")
alertcondition(tp3Active and (sigDir == 1 ? high >= tp3Val : low  <= tp3Val), "TP3 atteint", "TP3 touché !")
alertcondition(slActive  and (sigDir == 1 ? low  <= slVal  : high >= slVal),  "SL atteint",  "Stop Loss touché !")
````
