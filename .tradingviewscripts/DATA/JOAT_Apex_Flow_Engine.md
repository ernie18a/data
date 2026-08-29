<!-- tradingview-pine-id: PUB;f6ae0e7b42ad42a3aa13360961dde790 -->
<!-- tradingviewscripts-format: 1 -->
# [JOAT] Apex Flow Engine

Source: https://www.tradingview.com/script/M17tBCIA-JOAT-Apex-Flow-Engine/

## Description

Apex Flow Engine [JOAT]

A volatility-adaptive trend-flow engine that only signals when the move has measurable quality behind it.

[image]https://www.tradingview.com/x/D08iDQf9/[/image]

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ WHAT IT IS

Apex Flow Engine tracks the market's underlying flow — the direction price is genuinely travelling once noise is stripped out — and grades every potential entry against a transparent Flow Quality score before a signal is ever printed. It is built to keep a chart clean while still giving a full trade framework: entry, stop, and three take-profit targets.

This is 100% original code. It does not reuse or repackage anyone else's script.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ HOW IT WORKS

1. The Flow Baseline. Instead of a fixed moving average, the baseline is an efficiency-weighted adaptive average. It measures how much net directional travel price achieved versus how much raw movement it burned to get there (an efficiency ratio). When price moves cleanly, the baseline speeds up and hugs price; when price chops sideways, it slows and flattens. This keeps the reference honest in both trending and ranging conditions.

2. The Flow Envelope. An ATR-scaled band is wrapped around the baseline. A flow flip is only registered when price closes beyond the opposite band for a configurable number of confirmation closes — this filters the marginal pokes that create false flips on lower timeframes.

3. The Flow Quality score (0–100). Every flip is scored on four independent components before it becomes a signal:
 • Momentum alignment — is momentum pushing in the flip direction
 • Volume pulse — is participation expanding versus its own average
 • Candle structure — did the trigger candle close with a decisive body
 • Efficiency — how clean the underlying move is
A signal fires only if the score meets your minimum threshold, so weak, low-conviction flips are skipped.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ WHAT YOU SEE

 • BUY / SELL labels carrying the live Quality score plus an efficiency and volume read at the moment of the signal
 • A full TP/SL framework on every signal — entry line, stop-loss, TP1 / TP2 / TP3, and shaded risk/reward zones — that automatically stops updating once the stop or the furthest target is reached
 • An optional gradient flow ribbon whose intensity scales with Quality, and three candle-coloring styles (Gradient, Solid, Two-Tone)
 • A resizable command dashboard with block-meter gauges for Quality, Efficiency, Volume, Body and Stretch, plus live position and stop readouts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ HOW TO USE IT

 • Trade in the direction of the current Flow State. Treat higher-Quality signals as higher-conviction.
 • The Stretch (ATR) reading shows how far price has extended from the baseline — large values warn that a pullback may be near before entering late.
 • Use the built-in SL and TP levels as a structured plan, or as a reference for your own risk model.
 • Works on all symbols and all timeframes. Raise the confirmation closes and minimum Quality on fast intraday charts for fewer, cleaner signals.

◆ SETTINGS THAT MATTER

 • Flow Baseline Length / Acceleration — responsiveness of the core
 • Envelope Width + Confirmation Closes — how strict a flip must be
 • Minimum Quality Score — the signal gate
 • TP/SL group — ATR or percent stops, and independent R:R per target

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

◆ NOTES & LIMITATIONS

Apply the indicator to standard candlestick charts. Signals are decision-support tools that describe current conditions — they are not financial advice and no indicator can predict the future or guarantee an outcome. Always combine with your own analysis and risk management.

— made with passion by officialjackofalltrade

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//
// ─────────────────────────────────────────────────────────────────────────────
//  [JOAT] APEX FLOW ENGINE
//  Institutional-grade trend-flow engine. A volatility-adaptive flow baseline
//  is wrapped in a dynamic ATR envelope; momentum, volume expansion and
//  candle-structure checks are scored into a Flow Quality reading. Signals
//  fire only when flow flips with sufficient quality — each entry ships with
//  a complete TP/SL suite (entry, SL, TP1–TP3, risk/reward fills).
//  Color identity: Deep Teal / Living Coral gradient.
// ─────────────────────────────────────────────────────────────────────────────

//@version=6
indicator('[JOAT] Apex Flow Engine', shorttitle='[JOAT] APEX', overlay = true,
     max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

// ═════════════════════════════════ INPUTS ═══════════════════════════════════

// ── Flow Engine ──
flowLen = input.int(34, 'Flow Baseline Length', minval = 2, group = 'Flow Engine',
     tooltip = 'Length of the volatility-adaptive flow baseline.\n\nHigher = smoother, slower flow. Lower = faster reaction to price.')
flowAccel = input.float(2.0, 'Flow Acceleration', minval = 0.5, maxval = 10, step = 0.1, group = 'Flow Engine',
     tooltip = 'How aggressively the baseline accelerates when efficiency is high.\n\nHigher values hug price during strong trends and flatten in chop.')
envMult = input.float(1.6, 'Envelope Width (ATR ×)', minval = 0.2, step = 0.1, group = 'Flow Engine',
     tooltip = 'ATR multiplier for the flow envelope. A flip requires a close beyond the opposite envelope band.')
atrLenFlow = input.int(14, 'Envelope ATR Length', minval = 1, group = 'Flow Engine')
confirmCloses = input.int(1, 'Confirmation Closes', minval = 1, maxval = 5, group = 'Flow Engine',
     tooltip = 'Number of consecutive closes beyond the envelope required to confirm a flow flip. Higher = fewer, cleaner signals.')

// ── Flow Quality Filter ──
useQuality = input.bool(true, 'Use Flow Quality Filter', group = 'Flow Quality',
     tooltip = 'When enabled, signals only fire if the Flow Quality score meets the minimum threshold.')
minQuality = input.int(60, 'Minimum Quality Score', minval = 0, maxval = 100, group = 'Flow Quality',
     tooltip = 'Quality score (0–100) needed for a signal.\n\nScore components: momentum alignment, volume expansion, candle structure, envelope efficiency.')
volLenQ = input.int(20, 'Volume Baseline Length', minval = 1, group = 'Flow Quality')
momLenQ = input.int(10, 'Momentum Length', minval = 1, group = 'Flow Quality')

// ── Signals ──
showSignals = input.bool(true, 'Show BUY/SELL Labels', group = 'Signals')
showTriangles = input.bool(false, 'Show Triangle Signals', group = 'Signals')
signalSizeStr = input.string('Small', 'Signal Size', options = ['Tiny', 'Small', 'Normal'], group = 'Signals')
showQualityInLabel = input.bool(true, 'Show Quality Score In Label', group = 'Signals',
     tooltip = 'Appends the Flow Quality score (e.g. "BUY 78") to entry labels.')
richLabels = input.bool(true, 'Detailed Signal Labels (stats line)', group = 'Signals',
     tooltip = 'Adds a second line to BUY/SELL labels with the live Efficiency and Volume Pulse readings at the moment of the signal.')

// ── Visuals ──
bullColor = input.color(#00c9a7, 'Bull Flow Color', group = 'Visuals')
bearColor = input.color(#ff6b6b, 'Bear Flow Color', group = 'Visuals')
showBaseline = input.bool(true, 'Show Flow Baseline', group = 'Visuals')
showEnvelope = input.bool(true, 'Show Flow Envelope', group = 'Visuals')
showRibbon = input.bool(true, 'Show Gradient Flow Ribbon', group = 'Visuals',
     tooltip = 'Fills the area between price and the flow baseline with a quality-weighted gradient.')
colorCandles = input.bool(true, 'Color Candles By Flow', group = 'Visuals')
candleStyleStr = input.string('Gradient', 'Candle Coloring Style', options = ['Gradient', 'Solid', 'Two-Tone'], group = 'Visuals',
     tooltip = 'Gradient → candle intensity follows Flow Quality.\nSolid → pure bull/bear colors.\nTwo-Tone → bright body in trend direction, dim against it.')

// ── TP/SL ──
show_targets = input.bool(true, 'Show TP/SL Levels', group = 'TP/SL')
use_atr_sl = input.bool(true, 'SL = ATR × instead of %', group = 'TP/SL')
tp_atr_period = input.int(14, 'ATR Period For TP/SL', minval = 1, group = 'TP/SL')
sl_atr_mult = input.float(1.5, 'ATR Multiplier For SL', step = 0.1, group = 'TP/SL')
sl_percent = input.float(1.0, 'SL % From Entry', step = 0.1, group = 'TP/SL')
rr_tp1 = input.float(1.0, 'RR For TP1', step = 0.1, group = 'TP/SL')
rr_tp2 = input.float(2.0, 'RR For TP2', step = 0.1, group = 'TP/SL')
rr_tp3 = input.float(3.0, 'RR For TP3', step = 0.1, group = 'TP/SL')
show_sl_level = input.bool(true, 'Show SL Level', group = 'TP/SL Display')
show_tp1_level = input.bool(true, 'Show TP1 Level', group = 'TP/SL Display')
show_tp2_level = input.bool(true, 'Show TP2 Level', group = 'TP/SL Display')
show_tp3_level = input.bool(true, 'Show TP3 Level', group = 'TP/SL Display')

// ── Flow Dashboard ──
showDash = input.bool(true, 'Show Flow Dashboard', group = 'Flow Dashboard')
dashPos = input.string('Top Right', 'Dashboard Position',
     options = ['Top Left', 'Top Right', 'Bottom Left', 'Bottom Right', 'Top Center', 'Bottom Center', 'Middle Left', 'Middle Right'],
     group = 'Flow Dashboard')
dashSize = input.string('Normal', 'Dashboard Text Size', options = ['Tiny', 'Small', 'Normal', 'Large'], group = 'Flow Dashboard')
dashTheme = input.string('Onyx', 'Dashboard Theme', options = ['Onyx', 'Slate', 'Glass'], group = 'Flow Dashboard',
     tooltip = 'Onyx → near-black panel.\nSlate → dark blue-grey panel.\nGlass → translucent panel.')

// ══════════════════════════════ CORE ENGINE ═════════════════════════════════

// Volatility-adaptive flow baseline (efficiency-ratio weighted moving average)
float erChange = math.abs(close - close[flowLen])
float erNoise = math.sum(math.abs(close - close[1]), flowLen)
float efficiency = erNoise > 0 ? erChange / erNoise : 0.0
float fastSC = 2.0 / (2.0 + 1.0)
float slowSC = 2.0 / (30.0 + 1.0)
float scRaw = efficiency * (fastSC - slowSC) + slowSC
float smoothConst = math.pow(scRaw, 2) * flowAccel
smoothConst := math.min(smoothConst, 1.0)

var float flowBase = na
flowBase := na(flowBase) ? close : flowBase + smoothConst * (close - flowBase)

// Envelope
float atrFlow = ta.atr(atrLenFlow)
float envUp = flowBase + atrFlow * envMult
float envDn = flowBase - atrFlow * envMult

// Flip state machine with confirmation closes
var int flowDir = 0
var int upCloses = 0
var int dnCloses = 0
upCloses := close > envUp ? upCloses + 1 : 0
dnCloses := close < envDn ? dnCloses + 1 : 0

int prevDir = flowDir
if flowDir <= 0 and upCloses >= confirmCloses
    flowDir := 1
else if flowDir >= 0 and dnCloses >= confirmCloses
    flowDir := -1
bool flipUp = flowDir == 1 and prevDir != 1
bool flipDn = flowDir == -1 and prevDir != -1

// Flow age + last-signal memory (dashboard telemetry)
var int flowFlipBar = 0
if flipUp or flipDn
    flowFlipBar := bar_index
var int lastSigBar = na
var int lastSigDir = 0

// ─── Flow Quality Score (0–100) ───
float momQ = ta.mom(close, momLenQ)
float volBase = ta.sma(volume, volLenQ)
float volRatio = volBase > 0 ? volume / volBase : 1.0
float bodySize = math.abs(close - open)
float candleRange = math.max(high - low, syminfo.mintick)
float bodyPct = bodySize / candleRange

int qMomLong = momQ > 0 ? 25 : 0
int qMomShort = momQ < 0 ? 25 : 0
int qVol = volRatio >= 1.2 ? 25 : volRatio >= 1.0 ? 15 : 0
int qBody = bodyPct >= 0.6 ? 25 : bodyPct >= 0.4 ? 15 : 5
int qEff = efficiency >= 0.4 ? 25 : efficiency >= 0.25 ? 15 : 5

int qualityLong = qMomLong + qVol + qBody + qEff
int qualityShort = qMomShort + qVol + qBody + qEff
int flowQuality = flowDir == 1 ? qualityLong : flowDir == -1 ? qualityShort : 0

// ─── Signal conditions ───
bool longSignal = flipUp and (not useQuality or qualityLong >= minQuality)
bool shortSignal = flipDn and (not useQuality or qualityShort >= minQuality)

// ═══════════════════════════════ VISUALS ════════════════════════════════════

color flowColor = flowDir == 1 ? bullColor : flowDir == -1 ? bearColor : color.gray
int ribbonTransp = 96 - int(math.min(flowQuality, 100) * 0.28)   // 96 → 68 as quality rises
ribbonTransp := math.max(math.min(ribbonTransp, 100), 60)

pBase = plot(showBaseline ? flowBase : na, 'Flow Baseline', color = color.new(flowColor, 0), linewidth = 2, style = plot.style_linebr)
pUp = plot(showEnvelope ? envUp : na, 'Envelope Upper', color = color.new(flowColor, 75), linewidth = 1)
pDn = plot(showEnvelope ? envDn : na, 'Envelope Lower', color = color.new(flowColor, 75), linewidth = 1)
pPrice = plot(hl2, 'Price Anchor', display = display.none)
fill(pBase, pPrice, top_value = math.max(flowBase, hl2), bottom_value = math.min(flowBase, hl2),
     top_color = showRibbon ? color.new(flowColor, ribbonTransp) : na,
     bottom_color = showRibbon ? color.new(flowColor, 99) : na, title = 'Flow Ribbon')

// Candle coloring
color candleCol = na
if colorCandles
    if candleStyleStr == 'Solid'
        candleCol := flowColor
    else if candleStyleStr == 'Two-Tone'
        bool withFlow = (flowDir == 1 and close >= open) or (flowDir == -1 and close < open)
        candleCol := withFlow ? flowColor : color.new(flowColor, 62)
    else
        int gradT = 55 - int(math.min(flowQuality, 100) * 0.55)   // quality 0→55 transp, 100→0
        candleCol := color.new(flowColor, math.max(gradT, 0))
barcolor(candleCol, title = 'Flow Candles')

// ═════════════════════════════ TP/SL ENGINE ═════════════════════════════════

buyLabelColor = bullColor
sellLabelColor = bearColor
buyColorLight = color.new(buyLabelColor, 40)
sellColorLight = color.new(sellLabelColor, 40)
buyFill = color.new(buyLabelColor, 70)
sellFill = color.new(sellLabelColor, 70)
float atr_for_targets = ta.atr(tp_atr_period)

var int trade_dir = 0
var float sl_level = na
var float extreme_level = na
var line entry_line = na
var label entry_label = na
var line sl_line = na
var label sl_label = na
var line tp1_line = na
var label tp1_label = na
var line tp2_line = na
var label tp2_label = na
var line tp3_line = na
var label tp3_label = na
var line extreme_line = na
var linefill risk_fill = na
var linefill reward_fill = na
var int entry_bar = na

if (longSignal or shortSignal) and show_targets
    line.delete(entry_line)
    label.delete(entry_label)
    line.delete(sl_line)
    label.delete(sl_label)
    line.delete(tp1_line)
    label.delete(tp1_label)
    line.delete(tp2_line)
    label.delete(tp2_label)
    line.delete(tp3_line)
    label.delete(tp3_label)
    line.delete(extreme_line)
    linefill.delete(risk_fill)
    linefill.delete(reward_fill)

    trade_dir := longSignal ? 1 : -1
    entry_bar := bar_index
    float entry_price = close
    float risk_dist = use_atr_sl ? atr_for_targets * sl_atr_mult : entry_price * (sl_percent / 100)

    float tp1_p = na
    float tp2_p = na
    float tp3_p = na

    if trade_dir == 1
        sl_level := entry_price - risk_dist
        tp1_p := entry_price + risk_dist * rr_tp1
        tp2_p := entry_price + risk_dist * rr_tp2
        tp3_p := entry_price + risk_dist * rr_tp3
        extreme_level := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na

        string buyTxt = (showQualityInLabel ? 'BUY ' + str.tostring(qualityLong) : 'BUY ' + str.tostring(entry_price, format.mintick)) +
             (richLabels ? '\nEff ' + str.tostring(efficiency * 100, '#') + '% · Vol ' + str.tostring(volRatio, '#.#') + 'x' : '')
        entry_line := line.new(bar_index, entry_price, bar_index + 1, entry_price, color = buyLabelColor, width = 2, extend = extend.none)
        entry_label := label.new(bar_index, entry_price, buyTxt, style = label.style_label_left, color = buyLabelColor, textcolor = color.white, size = size.small)

        if show_sl_level
            sl_line := line.new(bar_index, sl_level, bar_index + 1, sl_level, color = sellColorLight, width = 1, style = line.style_dashed, extend = extend.none)
            sl_label := label.new(bar_index, sl_level, 'SL ' + str.tostring(sl_level, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small)
        if show_tp1_level
            tp1_line := line.new(bar_index, tp1_p, bar_index + 1, tp1_p, color = buyColorLight, width = 1, extend = extend.none)
            tp1_label := label.new(bar_index, tp1_p, 'TP1 ' + str.tostring(tp1_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
        if show_tp2_level
            tp2_line := line.new(bar_index, tp2_p, bar_index + 1, tp2_p, color = buyColorLight, width = 1, extend = extend.none)
            tp2_label := label.new(bar_index, tp2_p, 'TP2 ' + str.tostring(tp2_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
        if show_tp3_level
            tp3_line := line.new(bar_index, tp3_p, bar_index + 1, tp3_p, color = buyColorLight, width = 1, style = line.style_dotted, extend = extend.none)
            tp3_label := label.new(bar_index, tp3_p, 'TP3 ' + str.tostring(tp3_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)

        if show_sl_level
            risk_fill := linefill.new(entry_line, sl_line, sellFill)

        float max_tp_for_fill = entry_price
        if show_tp1_level
            max_tp_for_fill := math.max(max_tp_for_fill, tp1_p)
        if show_tp2_level
            max_tp_for_fill := math.max(max_tp_for_fill, tp2_p)
        if show_tp3_level
            max_tp_for_fill := math.max(max_tp_for_fill, tp3_p)
        if max_tp_for_fill > entry_price
            extreme_line := line.new(bar_index, max_tp_for_fill, bar_index + 1, max_tp_for_fill, color = na, extend = extend.none)
            reward_fill := linefill.new(entry_line, extreme_line, buyFill)
    else
        sl_level := entry_price + risk_dist
        tp1_p := entry_price - risk_dist * rr_tp1
        tp2_p := entry_price - risk_dist * rr_tp2
        tp3_p := entry_price - risk_dist * rr_tp3
        extreme_level := show_tp3_level ? tp3_p : show_tp2_level ? tp2_p : show_tp1_level ? tp1_p : na

        string sellTxt = (showQualityInLabel ? 'SELL ' + str.tostring(qualityShort) : 'SELL ' + str.tostring(entry_price, format.mintick)) +
             (richLabels ? '\nEff ' + str.tostring(efficiency * 100, '#') + '% · Vol ' + str.tostring(volRatio, '#.#') + 'x' : '')
        entry_line := line.new(bar_index, entry_price, bar_index + 1, entry_price, color = sellLabelColor, width = 2, extend = extend.none)
        entry_label := label.new(bar_index, entry_price, sellTxt, style = label.style_label_left, color = sellLabelColor, textcolor = color.white, size = size.small)

        if show_sl_level
            sl_line := line.new(bar_index, sl_level, bar_index + 1, sl_level, color = sellColorLight, width = 1, style = line.style_dashed, extend = extend.none)
            sl_label := label.new(bar_index, sl_level, 'SL ' + str.tostring(sl_level, format.mintick), style = label.style_label_left, color = sellColorLight, textcolor = color.white, size = size.small)
        if show_tp1_level
            tp1_line := line.new(bar_index, tp1_p, bar_index + 1, tp1_p, color = buyColorLight, width = 1, extend = extend.none)
            tp1_label := label.new(bar_index, tp1_p, 'TP1 ' + str.tostring(tp1_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
        if show_tp2_level
            tp2_line := line.new(bar_index, tp2_p, bar_index + 1, tp2_p, color = buyColorLight, width = 1, extend = extend.none)
            tp2_label := label.new(bar_index, tp2_p, 'TP2 ' + str.tostring(tp2_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)
        if show_tp3_level
            tp3_line := line.new(bar_index, tp3_p, bar_index + 1, tp3_p, color = buyColorLight, width = 1, style = line.style_dotted, extend = extend.none)
            tp3_label := label.new(bar_index, tp3_p, 'TP3 ' + str.tostring(tp3_p, format.mintick), style = label.style_label_left, color = buyColorLight, textcolor = color.white, size = size.small)

        if show_sl_level
            risk_fill := linefill.new(entry_line, sl_line, sellFill)

        float min_tp_for_fill = entry_price
        if show_tp1_level
            min_tp_for_fill := math.min(min_tp_for_fill, tp1_p)
        if show_tp2_level
            min_tp_for_fill := math.min(min_tp_for_fill, tp2_p)
        if show_tp3_level
            min_tp_for_fill := math.min(min_tp_for_fill, tp3_p)
        if min_tp_for_fill < entry_price
            extreme_line := line.new(bar_index, min_tp_for_fill, bar_index + 1, min_tp_for_fill, color = na, extend = extend.none)
            reward_fill := linefill.new(entry_line, extreme_line, buyFill)

// Position update + close on SL/TP hit
if trade_dir != 0
    if not na(entry_label)
        label.set_x(entry_label, bar_index)
    if not na(sl_label)
        label.set_x(sl_label, bar_index)
    if not na(tp1_label)
        label.set_x(tp1_label, bar_index)
    if not na(tp2_label)
        label.set_x(tp2_label, bar_index)
    if not na(tp3_label)
        label.set_x(tp3_label, bar_index)

    if not na(entry_line)
        line.set_x2(entry_line, bar_index + 1)
    if not na(sl_line)
        line.set_x2(sl_line, bar_index + 1)
    if not na(tp1_line)
        line.set_x2(tp1_line, bar_index + 1)
    if not na(tp2_line)
        line.set_x2(tp2_line, bar_index + 1)
    if not na(tp3_line)
        line.set_x2(tp3_line, bar_index + 1)
    if not na(extreme_line)
        line.set_x2(extreme_line, bar_index + 1)

    bool sl_hit = false
    bool tp_hit = false
    if trade_dir == 1
        sl_hit := low <= sl_level
        tp_hit := not na(extreme_level) and high >= extreme_level
    else if trade_dir == -1
        sl_hit := high >= sl_level
        tp_hit := not na(extreme_level) and low <= extreme_level

    if bar_index > entry_bar and (sl_hit or tp_hit)
        line.set_x2(entry_line, bar_index)
        if not na(sl_line)
            line.set_x2(sl_line, bar_index)
        if not na(tp1_line)
            line.set_x2(tp1_line, bar_index)
        if not na(tp2_line)
            line.set_x2(tp2_line, bar_index)
        if not na(tp3_line)
            line.set_x2(tp3_line, bar_index)
        if not na(extreme_line)
            line.set_x2(extreme_line, bar_index)
        trade_dir := 0

// ═══════════════════════════ SIGNAL MARKERS ═════════════════════════════════

string sigStats = 'Eff ' + str.tostring(efficiency * 100, '#') + '% · Vol ' + str.tostring(volRatio, '#.#') + 'x'
if longSignal
    lastSigBar := bar_index
    lastSigDir := 1
if shortSignal
    lastSigBar := bar_index
    lastSigDir := -1
if longSignal and showSignals
    string txt = (showQualityInLabel ? 'BUY ' + str.tostring(qualityLong) : 'BUY') + (richLabels ? '\n' + sigStats : '')
    label.new(bar_index, low - atrFlow * 0.4, txt, style = label.style_label_up,
         color = color.new(bullColor, 15), textcolor = color.white, size = size.small)
if shortSignal and showSignals
    string txt = (showQualityInLabel ? 'SELL ' + str.tostring(qualityShort) : 'SELL') + (richLabels ? '\n' + sigStats : '')
    label.new(bar_index, high + atrFlow * 0.4, txt, style = label.style_label_down,
         color = color.new(bearColor, 15), textcolor = color.white, size = size.small)

plotshape(showTriangles and longSignal and signalSizeStr == 'Tiny', title = 'Buy Triangle', style = shape.triangleup, location = location.belowbar, color = bullColor, size = size.tiny)
plotshape(showTriangles and longSignal and signalSizeStr == 'Small', title = 'Buy Triangle', style = shape.triangleup, location = location.belowbar, color = bullColor, size = size.small)
plotshape(showTriangles and longSignal and signalSizeStr == 'Normal', title = 'Buy Triangle', style = shape.triangleup, location = location.belowbar, color = bullColor, size = size.normal)
plotshape(showTriangles and shortSignal and signalSizeStr == 'Tiny', title = 'Sell Triangle', style = shape.triangledown, location = location.abovebar, color = bearColor, size = size.tiny)
plotshape(showTriangles and shortSignal and signalSizeStr == 'Small', title = 'Sell Triangle', style = shape.triangledown, location = location.abovebar, color = bearColor, size = size.small)
plotshape(showTriangles and shortSignal and signalSizeStr == 'Normal', title = 'Sell Triangle', style = shape.triangledown, location = location.abovebar, color = bearColor, size = size.normal)

// ═══════════════════════════ FLOW DASHBOARD ═════════════════════════════════

finalDashPos =
     dashPos == 'Top Left' ? position.top_left :
     dashPos == 'Top Right' ? position.top_right :
     dashPos == 'Bottom Left' ? position.bottom_left :
     dashPos == 'Bottom Right' ? position.bottom_right :
     dashPos == 'Top Center' ? position.top_center :
     dashPos == 'Bottom Center' ? position.bottom_center :
     dashPos == 'Middle Left' ? position.middle_left :
     dashPos == 'Middle Right' ? position.middle_right : position.top_right
finalDashSize =
     dashSize == 'Tiny' ? size.tiny :
     dashSize == 'Small' ? size.small :
     dashSize == 'Large' ? size.large : size.normal
color dashBg = dashTheme == 'Onyx' ? color.new(#0d1117, 8) : dashTheme == 'Slate' ? color.new(#1e222d, 12) : color.new(#2a2e39, 55)
color dashRow = dashTheme == 'Glass' ? color.new(#2a2e39, 70) : color.new(#161b22, 28)
color dashRowAlt = dashTheme == 'Glass' ? color.new(#343a4a, 72) : color.new(#101722, 28)
color dashLabel = color.new(color.white, 18)

// Meters — filled block + segment gauges
f_meter(int score) =>
    int filledBlocks = math.round(score / 12.5)
    string m = ''
    for i = 1 to 8
        m += i <= filledBlocks ? '█' : '░'
    m

f_gauge(float frac) =>
    int seg = math.round(math.max(math.min(frac, 1.0), 0.0) * 8)
    string g = ''
    for i = 1 to 8
        g += i <= seg ? '▰' : '▱'
    g

var table dash = na
if barstate.islast and showDash
    if not na(dash)
        table.delete(dash)
        dash := na
    dash := table.new(finalDashPos, columns = 3, rows = 12, bgcolor = dashBg,
         border_width = 1, border_color = color.new(#000000, 100),
         frame_width = 2, frame_color = color.new(flowColor, 30))

    string flowTxt = flowDir == 1 ? '▲ BULLISH' : flowDir == -1 ? '▼ BEARISH' : '— NEUTRAL'
    float distATR = atrFlow > 0 ? math.abs(close - flowBase) / atrFlow : 0.0
    int liveQuality = flowDir == 1 ? qualityLong : flowDir == -1 ? qualityShort : 0
    int flowAge = bar_index - flowFlipBar

    // ── Title band ──
    table.cell(dash, 0, 0, '⚡ APEX FLOW ENGINE', text_color = color.white, bgcolor = color.new(flowColor, 22), text_size = finalDashSize)
    table.cell(dash, 1, 0, '', bgcolor = color.new(flowColor, 22), text_size = finalDashSize)
    table.cell(dash, 2, 0, syminfo.ticker + ' · ' + timeframe.period, text_color = color.new(color.white, 10), bgcolor = color.new(flowColor, 22), text_size = finalDashSize)
    // ── Gradient accent strip ──
    table.cell(dash, 0, 1, '', bgcolor = color.new(flowColor, 80), text_size = size.tiny)
    table.cell(dash, 1, 1, '', bgcolor = color.new(flowColor, 55), text_size = size.tiny)
    table.cell(dash, 2, 1, '', bgcolor = color.new(flowColor, 25), text_size = size.tiny)
    // ── Flow state ──
    table.cell(dash, 0, 2, 'Flow State', text_color = dashLabel, bgcolor = dashRow, text_size = finalDashSize)
    table.cell(dash, 1, 2, flowTxt, text_color = color.white, bgcolor = color.new(flowColor, 45), text_size = finalDashSize)
    table.cell(dash, 2, 2, 'for ' + str.tostring(flowAge) + ' bars', text_color = color.new(color.white, 35), bgcolor = dashRow, text_size = finalDashSize)
    // ── Flow quality ──
    table.cell(dash, 0, 3, 'Flow Quality', text_color = dashLabel, bgcolor = dashRowAlt, text_size = finalDashSize)
    table.cell(dash, 1, 3, f_meter(liveQuality) + ' ' + str.tostring(liveQuality), text_color = liveQuality >= minQuality ? flowColor : color.new(color.white, 40), bgcolor = dashRowAlt, text_size = finalDashSize)
    table.cell(dash, 2, 3, liveQuality >= minQuality ? '✓ ARMED' : '… BUILDING', text_color = liveQuality >= minQuality ? color.white : color.new(color.white, 45), bgcolor = liveQuality >= minQuality ? color.new(flowColor, 40) : dashRowAlt, text_size = finalDashSize)
    // ── Efficiency ──
    table.cell(dash, 0, 4, 'Efficiency', text_color = dashLabel, bgcolor = dashRow, text_size = finalDashSize)
    table.cell(dash, 1, 4, str.tostring(efficiency * 100, '#.#') + '%', text_color = efficiency >= 0.4 ? flowColor : color.new(color.white, 30), bgcolor = dashRow, text_size = finalDashSize)
    table.cell(dash, 2, 4, f_gauge(efficiency / 0.6), text_color = color.new(flowColor, 20), bgcolor = dashRow, text_size = finalDashSize)
    // ── Volume pulse ──
    table.cell(dash, 0, 5, 'Volume Pulse', text_color = dashLabel, bgcolor = dashRowAlt, text_size = finalDashSize)
    table.cell(dash, 1, 5, str.tostring(volRatio, '#.##') + 'x', text_color = volRatio >= 1.2 ? flowColor : color.new(color.white, 30), bgcolor = dashRowAlt, text_size = finalDashSize)
    table.cell(dash, 2, 5, f_gauge(volRatio / 2.0), text_color = color.new(flowColor, 20), bgcolor = dashRowAlt, text_size = finalDashSize)
    // ── Candle body ──
    table.cell(dash, 0, 6, 'Candle Body', text_color = dashLabel, bgcolor = dashRow, text_size = finalDashSize)
    table.cell(dash, 1, 6, str.tostring(bodyPct * 100, '#') + '%', text_color = bodyPct >= 0.6 ? flowColor : color.new(color.white, 30), bgcolor = dashRow, text_size = finalDashSize)
    table.cell(dash, 2, 6, f_gauge(bodyPct), text_color = color.new(flowColor, 20), bgcolor = dashRow, text_size = finalDashSize)
    // ── Stretch ──
    table.cell(dash, 0, 7, 'Stretch (ATR)', text_color = dashLabel, bgcolor = dashRowAlt, text_size = finalDashSize)
    table.cell(dash, 1, 7, str.tostring(distATR, '0.00') + 'x', text_color = distATR >= 3 ? bearColor : color.new(color.white, 30), bgcolor = dashRowAlt, text_size = finalDashSize)
    table.cell(dash, 2, 7, f_gauge(distATR / 4.0), text_color = distATR >= 3 ? color.new(bearColor, 15) : color.new(flowColor, 20), bgcolor = dashRowAlt, text_size = finalDashSize)
    // ── Baseline ──
    table.cell(dash, 0, 8, 'Flow Baseline', text_color = dashLabel, bgcolor = dashRow, text_size = finalDashSize)
    table.cell(dash, 1, 8, str.tostring(flowBase, format.mintick), text_color = color.new(flowColor, 10), bgcolor = dashRow, text_size = finalDashSize)
    table.cell(dash, 2, 8, 'env ±' + str.tostring(atrFlow * envMult, format.mintick), text_color = color.new(color.white, 35), bgcolor = dashRow, text_size = finalDashSize)
    // ── Signal gate ──
    table.cell(dash, 0, 9, 'Signal Gate', text_color = dashLabel, bgcolor = dashRowAlt, text_size = finalDashSize)
    table.cell(dash, 1, 9, 'min quality ' + str.tostring(minQuality), text_color = color.new(color.white, 30), bgcolor = dashRowAlt, text_size = finalDashSize)
    table.cell(dash, 2, 9, str.tostring(confirmCloses) + ' close confirm', text_color = color.new(color.white, 30), bgcolor = dashRowAlt, text_size = finalDashSize)
    // ── Last signal ──
    string lastSigTxt = na(lastSigBar) ? '—' : (lastSigDir == 1 ? 'BUY' : 'SELL') + ' · ' + str.tostring(bar_index - lastSigBar) + ' bars ago'
    table.cell(dash, 0, 10, 'Last Signal', text_color = dashLabel, bgcolor = dashRow, text_size = finalDashSize)
    table.cell(dash, 1, 10, lastSigTxt, text_color = lastSigDir == 1 ? bullColor : lastSigDir == -1 ? bearColor : color.new(color.white, 40), bgcolor = dashRow, text_size = finalDashSize)
    table.cell(dash, 2, 10, '', bgcolor = dashRow, text_size = finalDashSize)
    // ── Position ──
    string tradeTxt = trade_dir == 1 ? '● LONG ACTIVE' : trade_dir == -1 ? '● SHORT ACTIVE' : '○ FLAT'
    table.cell(dash, 0, 11, 'Position', text_color = dashLabel, bgcolor = dashRowAlt, text_size = finalDashSize)
    table.cell(dash, 1, 11, tradeTxt, text_color = color.white, bgcolor = trade_dir == 1 ? color.new(bullColor, 40) : trade_dir == -1 ? color.new(bearColor, 40) : dashRowAlt, text_size = finalDashSize)
    table.cell(dash, 2, 11, trade_dir != 0 and not na(sl_level) ? 'SL ' + str.tostring(sl_level, format.mintick) : '', text_color = color.new(bearColor, 25), bgcolor = dashRowAlt, text_size = finalDashSize)

// ════════════════════════════════ ALERTS ════════════════════════════════════

alertcondition(longSignal, title = 'APEX Buy Signal', message = '[JOAT] Apex Flow Engine — BUY {{ticker}} @ {{close}} ({{interval}})')
alertcondition(shortSignal, title = 'APEX Sell Signal', message = '[JOAT] Apex Flow Engine — SELL {{ticker}} @ {{close}} ({{interval}})')
alertcondition(flipUp, title = 'Flow Flip Bullish', message = '[JOAT] Apex Flow — flow flipped BULLISH on {{ticker}}')
alertcondition(flipDn, title = 'Flow Flip Bearish', message = '[JOAT] Apex Flow — flow flipped BEARISH on {{ticker}}')
````
