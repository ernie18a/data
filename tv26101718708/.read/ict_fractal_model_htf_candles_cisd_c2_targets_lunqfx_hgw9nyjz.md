# ICT Fractal Model, HTF Candles, CISD & C2 Targets [LunqFX]

- url: https://www.tradingview.com/script/HGW9NYJZ-ICT-Fractal-Model-HTF-Candles-CISD-C2-Targets-LunqFX/
- type: indicator
- pine_id: PUB;121faffd16074f3496121f174a0a0805
- version: 1.0

## Description

ICT Fractal Model draws higher-timeframe (HTF) candles next to your chart and tracks the multi-timeframe fractal model on them from start to finish: candle 2 sweeps the high or low of candle 1 and closes back inside its range, and candle 3 is expected to expand to the other side. On your own timeframe the script confirms the move with a change in state of delivery (CISD), projects the targets of candle 1, and keeps a record of how often the model reached them on this symbol.

Most HTF candle and CISD indicators show one piece of the model — the higher-timeframe candles, or the CISD, or the candle 2 closure — and leave you to connect them. This one runs the whole sequence — liquidity sweep, CISD, candle 2 closure, candle 3 expansion — as one model, files every finished model as a result, and answers the question that decides whether the model is worth trading on your market: how often did candle 3 actually reach the other side of candle 1 here — with a CISD, and without one.

❶ THE MODEL, STEP BY STEP ① C1 — the last finished higher-timeframe candle. Its range is drawn as a pink box. ② C2 SWEEPS C1 — the candle now forming trades beyond C1's low (bullish model) or high (bearish model). The sweep is labelled on the chart and the deepest point is followed live. ③ CISD — on the chart timeframe, a close beyond the open of the run of candles that delivered price into the sweep. It is the first sign that delivery has turned. Drawn as a line labelled CISD. ④ C2 CLOSES INSIDE C1 — when candle 2 closes back inside candle 1's range, the model is confirmed and candle 3 begins. If candle 2 closes beyond C1, or takes both sides of it, it is not a fractal model and the drawings are removed. ⑤ C3 EXPANDS — candle 3 is expected to run to the opposite side of C1.

❷ TARGETS AND INVALIDATION ▸ T1 · C1 EQ — the middle of candle 1 ▸ T2 · C1 HIGH / LOW — the opposite side of candle 1; reaching it completes the model ▸ INVALID — the C2 sweep extreme. If price trades beyond it, the model fails. The model is resolved when T2 is reached, when it fails, or when candle 3 closes. Each target gets a ✓ when it trades; when the C2 close is already past the equilibrium, T1 is ticked at confirmation.

❸ HTF CANDLES ON THE RIGHT The last higher-timeframe candles are drawn to the right of price, with the forming one on the far right. While a model is in play they are tagged C1, C2 and C3, so you always see where you are in the sequence without switching timeframes. Separators mark where each HTF candle begins.

❹ THE TRACK RECORD Every confirmed model is filed by direction. The panel shows, for bullish, bearish and all models on this symbol: the number of models, the share that reached T1, the share that reached T2, and the share that failed. A separate row compares models that printed a CISD before candle 2 closed with models that did not — so you can see whether waiting for the CISD actually helped on this market. A CISD that only appears during candle 3 is drawn but not counted: price moving toward T2 would print one almost every time, and counting it would flatter the CISD. The average time to T2 is shown underneath.

❺ THE PANEL ▸ The higher timeframe in use and the time until its candle closes ▸ Model direction and stage ▸ C2 closure status and the CISD level (waiting or ✓) ▸ C1 range, T1, T2 and the invalidation level ▸ The track record table

❻ HOW TO USE IT

Use a classic pairing — the Auto setting does it for you: 1m → 15m, 5m → 1H, 15m and 30m → 4H, 1H → Daily, 4H → Weekly, Daily → Monthly.
Watch for "C2 SWEEPS C1". The sweep alone is not the model.
Look for the CISD on your timeframe, and for candle 2 to close back inside C1.
Once confirmed, T1 and T2 are the draw for candle 3. Check the track record first: it shows how often T2 is reached on this symbol, with and without a CISD.
Works on forex, gold (XAUUSD), index CFDs and crypto. It fits any smart money concepts workflow as the higher-timeframe context for your own entries.
[b]Tip: switch "Require C2 to close back inside C1" off[/b] to also accept a candle 2 that closes beyond C1 after the sweep — more models, and more failed ones. Settings → Model.

❼ SETTINGS Model ▸ Higher timeframe — Auto (recommended) or a fixed 15m, 1H, 4H, Daily or Weekly ▸ [b]Require C2 to close back inside C1[/b] — on by default; off also accepts a candle 2 that closes beyond C1. The model is still confirmed when candle 2 closes, and a candle 2 that takes both sides of C1 never counts. Drawing ▸ HTF candles on the right and how many are shown ▸ HTF candle separators ▸ Targets and invalidation ▸ Models drawn — how many finished models stay on the chart; the track record keeps all of them ▸ Label size Panel ▸ Show panel · position · text size Alerts ▸ C1 swept · CISD · Model confirmed · Target hit / complete / failed Visuals ▸ Neon candles — aqua rising, ultraviolet falling; C1 and the targets in neon pink. Off = your own chart candles. ▸ Glow candles — each body brightens towards the close. Off = flat neon bodies.

❽ ALERTS ▸ C1 swept — the forming HTF candle took C1's high or low ▸ CISD — with the level ▸ Model confirmed — C2 closed inside C1, with T1, T2 and the invalidation level ▸ Target hit, model complete, model failed Create the alert with "Any alert() function call" for the full messages, or use the five alert conditions.

❾ NON-REPAINTING The higher-timeframe candles are built from the chart's own closed bars, so they match what you see and never change after the fact. Every sweep, CISD, confirmation, target hit and failure is decided on a closed bar. The script does not use request.security or lookahead.

LIMITATIONS ▸ The higher timeframe must be above the chart timeframe; if it is not (for example a fixed 1H on a 4H chart, or a monthly chart), the panel shows a notice instead. ▸ HTF candles are built from the bars loaded on your chart. On symbols with session gaps, the first HTF candle after a gap can differ slightly from the one on the higher-timeframe chart. ▸ CISD is defined here as a close beyond the open of the candle run that delivered the sweep. Other traders define it differently. ▸ One model is tracked at a time. A sweep that happens while a model is running is not tracked. ▸ The track record covers only the history loaded on your chart. Small samples are noisy — check the "Models" column before trusting a percentage. Past rates are not a forecast. ▸ The model gives a structure and targets, not an entry. It has no stop loss or position sizing; combine it with your own entry rules and risk management.

This script is for educational purposes only and is not financial advice. Trading involves risk.

## Source Code

````pine
//@version=6
// ============================================================================
//  ICT Fractal Model, HTF Candles, CISD & C2 Targets [LunqFX]
// ----------------------------------------------------------------------------
//  Builds higher-timeframe candles from the chart's own bars, watches for the
//  fractal model — candle 2 sweeps candle 1's high or low and closes back
//  inside, candle 3 expands to the other side — confirms it with a change in
//  state of delivery (CISD) on the chart timeframe, projects the targets, and
//  keeps a record of how often the model reached them on this symbol.
//
//  NON-REPAINTING: HTF candles are built from the chart's closed bars; every
//  stage, CISD, target hit and failure is decided on closed bars.
//  No request.security, no lookahead.
// ============================================================================
indicator("ICT Fractal Model, HTF Candles, CISD & C2 Targets [LunqFX]", "Fractal Model [LunqFX]",
     overlay = true, max_lines_count = 300, max_labels_count = 300, max_boxes_count = 120)

// ─────────────────────────────────────────────────────────────────────────
//  INPUTS
// ─────────────────────────────────────────────────────────────────────────
gM = "Model"
htfMode = input.string("Auto", "Higher timeframe", options = ["Auto", "15", "60", "240", "D", "W"], group = gM,
     tooltip = "Auto pairs the chart with the classic fractal timeframe: 1m → 15m, 5m → 1H, 15m → 4H, 1H → Daily, 4H → Weekly.")
needClose = input.bool(true, "Require C2 to close back inside C1", group = gM,
     tooltip = "On: the model is valid only when candle 2 closes back inside candle 1's range after the sweep. Off: the sweep alone starts the model.")

gD = "Drawing"
showHtf  = input.bool(true, "HTF candles on the right", group = gD)
htfCount = input.int(4, "HTF candles shown", minval = 2, maxval = 8, group = gD)
showSep  = input.bool(true, "HTF candle separators", group = gD)
showTgt  = input.bool(true, "Targets and invalidation", group = gD)
keepN    = input.int(3, "Models drawn", minval = 1, maxval = 20, group = gD, tooltip = "Finished models older than this are removed from the chart. The track record keeps all of them.")
lblSize  = input.string("Normal", "Label size", options = ["Small", "Normal", "Large"], group = gD)

gP = "Panel"
showTbl  = input.bool(true, "Show panel", group = gP)
tblPos   = input.string("Top Right", "Position", options = ["Top Right", "Bottom Right", "Top Left", "Bottom Left"], group = gP)
tblSize  = input.string("Normal", "Text size", options = ["Small", "Normal", "Large"], group = gP)

gA = "Alerts"
alSweep  = input.bool(true, "Alert: C1 swept", group = gA)
alCisd   = input.bool(true, "Alert: CISD", group = gA)
alLive   = input.bool(true, "Alert: model confirmed (C2 closed inside)", group = gA)
alRes    = input.bool(true, "Alert: target hit / complete / failed", group = gA)

candOn_  = input.bool(true, "Neon candles", group = "Visuals")
candGlw  = input.bool(true, "Glow candles", group = "Visuals", tooltip = "Each body is drawn in four bands that brighten towards the close, so the candle reads in the direction it moved. Off = flat translucent bodies.")

// ─────────────────────────────────────────────────────────────────────────
//  THEME
// ─────────────────────────────────────────────────────────────────────────
bgLum   = 0.2126 * color.r(chart.bg_color) + 0.7152 * color.g(chart.bg_color) + 0.0722 * color.b(chart.bg_color)
isLight = bgLum > 128
UP      = isLight ? #0097A7 : #00E5FF   // aqua: bullish
DN      = isLight ? #5B2BD9 : #7C4DFF   // ultraviolet: bearish
TGT     = isLight ? #C2189B : #FF4FD8   // neon pink: C1 range and targets
TGTX    = isLight ? #A0127F : #FF9BEA   // light pink for text
GREY    = isLight ? #8A8F9C : #6B7080
TXT     = isLight ? #1A1D24 : #E8EAF0
MUTE    = isLight ? #5E6472 : #9AA0AE
PANEL   = isLight ? #FFFFFF : #0B0E14
ROW     = isLight ? #F1F3F7 : #141823
INK     = #0B0E14
NONE    = color.new(color.black, 100)

lSize = lblSize == "Small" ? size.small : lblSize == "Large" ? size.large : size.normal
tSize = tblSize == "Small" ? size.small : tblSize == "Large" ? size.large : size.normal

px(float v) =>
    str.tostring(v, format.mintick)

pct(int a, int b) =>
    b > 0 ? str.tostring(a * 100.0 / b, "0") + "%" : "—"

// ─────────────────────────────────────────────────────────────────────────
//  HIGHER TIMEFRAME
// ─────────────────────────────────────────────────────────────────────────
tfSec = timeframe.in_seconds()
autoHtf = tfSec <= 60 ? "15" : tfSec <= 300 ? "60" : tfSec <= 1800 ? "240" : tfSec <= 3600 ? "D" : tfSec <= 14400 ? "W" : "M"
htf    = htfMode == "Auto" ? autoHtf : htfMode
htfOk  = timeframe.in_seconds(htf) > tfSec
htfName = htf == "15" ? "15m" : htf == "60" ? "1H" : htf == "240" ? "4H" : htf == "D" ? "Daily" : htf == "W" ? "Weekly" : htf == "M" ? "Monthly" : htf
newH   = timeframe.change(htf)
htfEnd = time_close(htf)

// the HTF candle being built, and the finished ones
var float hO = na
var float hH = na
var float hL = na
var int   hS = na
var array<float> cO = array.new_float()
var array<float> cH = array.new_float()
var array<float> cL = array.new_float()
var array<float> cC = array.new_float()
var array<int>   cS = array.new_int()
var array<int>   cE = array.new_int()

var array<line> seps = array.new_line()

htfClosed = false
if newH and not na(hO)
    array.push(cO, hO)
    array.push(cH, hH)
    array.push(cL, hL)
    array.push(cC, close[1])
    array.push(cS, hS)
    array.push(cE, bar_index - 1)
    if array.size(cO) > 12
        array.shift(cO)
        array.shift(cH)
        array.shift(cL)
        array.shift(cC)
        array.shift(cS)
        array.shift(cE)
    htfClosed := true
if newH or na(hO)
    hO := open
    hH := high
    hL := low
    hS := bar_index
    if showSep and htfOk and newH
        array.push(seps, line.new(bar_index, low, bar_index, high, extend = extend.both, color = color.new(GREY, 82), style = line.style_dotted))
        if array.size(seps) > 40
            line.delete(array.shift(seps))
else
    hH := math.max(hH, high)
    hL := math.min(hL, low)

// ─────────────────────────────────────────────────────────────────────────
//  CISD — the open of the run of candles that delivered price into the sweep
// ─────────────────────────────────────────────────────────────────────────
var float dnRunOpen = na    // open of the latest run of down-closing candles
var int   dnRunBar  = na
var float upRunOpen = na
var int   upRunBar  = na
if close < open and not (close[1] < open[1])
    dnRunOpen := open
    dnRunBar  := bar_index
if close > open and not (close[1] > open[1])
    upRunOpen := open
    upRunBar  := bar_index

// ─────────────────────────────────────────────────────────────────────────
//  STATE
//  stage 0 searching · 1 C2 has swept C1 · 2 C2 closed inside, C3 running
//  dir 1 = bullish (C1 low swept, C3 expected up) · -1 = bearish
// ─────────────────────────────────────────────────────────────────────────
var int   stage = 0
var int   dir   = 0
var float c1H = na
var float c1L = na
var int   c1S = na
var float swX = na      // sweep extreme
var int   swBar = na
var float cisdLvl = na
var int   cisdLvlBar = na
var bool  cisdOn = false
var bool  cisdEarly = false   // CISD printed before C2 closed — the only CISD that counts in the record
var int   cisdBar = na
var float t1 = na
var float t2 = na
var float inv = na
var int   liveBar = na
var int   hitMax = 0

var box   c1Bx = na
var label swLb = na
var line  t1Ln = na
var line  t2Ln = na
var line  invLn = na
var label t1Lb = na
var label t2Lb = na
var label invLb = na

var array<int> rN    = array.new_int(2, 0)
var array<int> rT1   = array.new_int(2, 0)
var array<int> rT2   = array.new_int(2, 0)
var array<int> rFail = array.new_int(2, 0)
var array<int> rCisd = array.new_int(2, 0)   // models with a CISD
var array<int> rCisdT2 = array.new_int(2, 0) // ...that reached T2
var array<int> rBars = array.new_int(2, 0)

// drawing registry (same pattern as the MMXM script): keep the last N models
var int mid = 0
var array<line>  gLn  = array.new<line>()
var array<int>   gLnI = array.new_int()
var array<label> gLb  = array.new<label>()
var array<int>   gLbI = array.new_int()
var array<box>   gBx  = array.new<box>()
var array<int>   gBxI = array.new_int()

bump(array<int> a, int i, int add) =>
    array.set(a, i, array.get(a, i) + add)
regLn(line o) =>
    array.push(gLn, o)
    array.push(gLnI, mid)
regLb(label o) =>
    array.push(gLb, o)
    array.push(gLbI, mid)
regBx(box o) =>
    array.push(gBx, o)
    array.push(gBxI, mid)
prune(int upTo) =>
    while array.size(gLnI) > 0 and array.get(gLnI, 0) <= upTo
        line.delete(array.shift(gLn))
        array.shift(gLnI)
    while array.size(gLbI) > 0 and array.get(gLbI, 0) <= upTo
        label.delete(array.shift(gLb))
        array.shift(gLbI)
    while array.size(gBxI) > 0 and array.get(gBxI, 0) <= upTo
        box.delete(array.shift(gBx))
        array.shift(gBxI)

// temporary drawings of a model that is not confirmed yet
var array<line>  tmpLn = array.new<line>()
var array<label> tmpLb = array.new<label>()
dropTmp() =>
    for o in tmpLn
        line.delete(o)
    for o in tmpLb
        label.delete(o)
    array.clear(tmpLn)
    array.clear(tmpLb)
keepTmp() =>
    for o in tmpLn
        regLn(o)
    for o in tmpLb
        regLb(o)
    array.clear(tmpLn)
    array.clear(tmpLb)

evSweep = false
evCisd  = false
evLive  = false
evHit   = 0
evFrom  = 0
evDone  = false
evFail  = false
evEnd   = false

finish(int d, bool failed) =>
    bump(rN, d, 1)
    bump(rT1, d, hitMax >= 1 ? 1 : 0)
    bump(rT2, d, hitMax >= 2 ? 1 : 0)
    bump(rFail, d, failed ? 1 : 0)
    bump(rCisd, d, cisdEarly ? 1 : 0)
    bump(rCisdT2, d, cisdEarly and hitMax >= 2 ? 1 : 0)
    bump(rBars, d, hitMax >= 2 ? bar_index - liveBar : 0)

// ─────────────────────────────────────────────────────────────────────────
//  STATE MACHINE — closed bars only
// ─────────────────────────────────────────────────────────────────────────
if barstate.isconfirmed and htfOk

    // ── CISD: a close beyond the open of the run that delivered the sweep
    if stage >= 1 and not cisdOn and not na(cisdLvl)
        if dir == 1 ? close > cisdLvl : close < cisdLvl
            cisdOn := true
            cisdBar := bar_index
            evCisd := true
            cc = dir == 1 ? UP : DN
            ln = line.new(cisdLvlBar, cisdLvl, bar_index, cisdLvl, color = cc, width = 2)
            lb = label.new(bar_index, cisdLvl, "CISD", style = label.style_label_left, color = NONE, textcolor = cc, size = size.small)
            if stage == 1
                array.push(tmpLn, ln)
                array.push(tmpLb, lb)
            else
                regLn(ln)
                regLb(lb)

    // ── 2 · C3 running: targets in order, invalidation beyond the sweep
    if stage == 2
        evFrom := hitMax
        failNow = dir == 1 ? low < inv : high > inv
        if failNow
            evFail := true
        else
            for k = 1 to 2
                tk = k == 1 ? t1 : t2
                if hitMax == k - 1 and (dir == 1 ? high >= tk : low <= tk)
                    hitMax := k
                    evHit := k
        expired = htfClosed and bar_index > liveBar   // C3 itself has closed
        if evFail or hitMax == 2 or expired
            finish(dir == 1 ? 0 : 1, evFail)
            evDone := hitMax == 2
            evEnd := true
            resTxt = hitMax == 2 ? "✓ MODEL COMPLETE · " + str.tostring(bar_index - liveBar) + " bars" : evFail ? "✕ MODEL FAILED" + (hitMax > 0 ? " · T1 reached" : "") : "C3 CLOSED" + (hitMax > 0 ? " · T1 reached" : " · no target")
            regLb(label.new(bar_index, dir == 1 ? high : low, resTxt, style = dir == 1 ? label.style_label_down : label.style_label_up,
                 color = hitMax == 2 ? TGT : color.new(GREY, 0), textcolor = hitMax == 2 ? color.white : INK, size = lSize))
            box.set_right(c1Bx, bar_index)
            prune(mid - keepN)
            stage := 0
            dir := 0

    // ── 1 · C2 has swept C1: follow the sweep, wait for C2 to close
    if stage == 1
        if htfClosed
            // the candle that just closed is C2
            c2C = array.get(cC, array.size(cC) - 1)
            c2H = array.get(cH, array.size(cH) - 1)
            c2L = array.get(cL, array.size(cL) - 1)
            bothSides = c2H > c1H and c2L < c1L
            inside = c2C > c1L and c2C < c1H
            if not bothSides and (inside or not needClose)
                // confirmed: C3 starts now
                stage := 2
                evLive := true
                // a CISD that only appears during C3 would be counted after the fact — it does not count
                cisdEarly := cisdOn
                mid += 1
                liveBar := bar_index
                hitMax := 0
                t1 := (c1H + c1L) / 2
                t2 := dir == 1 ? c1H : c1L
                inv := swX
                // the C2 close can already be past the equilibrium
                if dir == 1 ? c2C >= t1 : c2C <= t1
                    hitMax := 1
                regBx(c1Bx)
                regLb(swLb)
                keepTmp()
                if showTgt
                    t1Ln := line.new(bar_index, t1, bar_index + 1, t1, color = color.new(TGT, 30), width = 1, style = line.style_dotted)
                    t2Ln := line.new(bar_index, t2, bar_index + 1, t2, color = TGT, width = 2)
                    invLn := line.new(bar_index, inv, bar_index + 1, inv, color = color.new(dir == 1 ? DN : UP, 20), width = 1, style = line.style_dashed)
                    t1Lb := label.new(bar_index + 1, t1, (hitMax >= 1 ? "✓ " : "") + "T1 · C1 EQ " + px(t1), style = label.style_label_left, color = color.new(PANEL, 10), textcolor = TGTX, size = size.small)
                    t2Lb := label.new(bar_index + 1, t2, "T2 · C1 " + (dir == 1 ? "HIGH " : "LOW ") + px(t2), style = label.style_label_left, color = TGT, textcolor = color.white, size = size.small)
                    invLb := label.new(bar_index + 1, inv, "INVALID " + px(inv), style = label.style_label_left, color = color.new(PANEL, 10), textcolor = dir == 1 ? DN : UP, size = size.small)
                    regLn(t1Ln)
                    regLn(t2Ln)
                    regLn(invLn)
                    regLb(t1Lb)
                    regLb(t2Lb)
                    regLb(invLb)
                label.set_text(swLb, (dir == 1 ? "C2 SWEPT C1 LOW" : "C2 SWEPT C1 HIGH") + (cisdOn ? " · CISD ✓" : ""))
            else
                // C2 closed beyond C1 or took both sides: not a fractal model
                box.delete(c1Bx)
                label.delete(swLb)
                dropTmp()
                stage := 0
                dir := 0
        else
            // still inside C2: a deeper sweep resets the CISD reference
            deeper = dir == 1 ? low < swX : high > swX
            if deeper
                swX := dir == 1 ? low : high
                swBar := bar_index
                cisdLvl := dir == 1 ? dnRunOpen : upRunOpen
                cisdLvlBar := dir == 1 ? dnRunBar : upRunBar
                label.set_xy(swLb, swBar, swX)
            box.set_right(c1Bx, bar_index)

    // ── 0 · searching: the forming HTF candle (C2) takes the last finished one (C1)
    if stage == 0 and array.size(cH) > 0 and not htfClosed
        pH = array.get(cH, array.size(cH) - 1)
        pL = array.get(cL, array.size(cL) - 1)
        pS = array.get(cS, array.size(cS) - 1)
        upSw = hH > pH
        dnSw = hL < pL
        if upSw != dnSw
            stage := 1
            dir := dnSw ? 1 : -1
            evSweep := true
            c1H := pH
            c1L := pL
            c1S := pS
            swX := dnSw ? hL : hH
            swBar := bar_index
            cisdOn := false
            cisdEarly := false
            cisdLvl := dir == 1 ? dnRunOpen : upRunOpen
            cisdLvlBar := dir == 1 ? dnRunBar : upRunBar
            array.clear(tmpLn)
            array.clear(tmpLb)
            c1Bx := box.new(c1S, c1H, bar_index, c1L, border_color = color.new(TGT, 40), border_width = 1, border_style = line.style_dotted,
                 bgcolor = color.new(TGT, 94), text = "C1 · " + htfName, text_color = TGTX, text_size = size.small, text_halign = text.align_left, text_valign = text.align_top)
            swLb := label.new(swBar, swX, dir == 1 ? "C2 SWEEPS C1 LOW" : "C2 SWEEPS C1 HIGH", style = dir == 1 ? label.style_label_up : label.style_label_down,
                 color = dir == 1 ? UP : DN, textcolor = dir == 1 ? INK : color.white, size = lSize)

// running drawings follow the current bar
if stage == 2 and showTgt
    line.set_x2(t1Ln, bar_index + 3)
    line.set_x2(t2Ln, bar_index + 3)
    line.set_x2(invLn, bar_index + 3)
    label.set_x(t1Lb, bar_index + 3)
    label.set_x(t2Lb, bar_index + 3)
    label.set_x(invLb, bar_index + 3)
    box.set_right(c1Bx, bar_index)
if evHit > 0 and showTgt
    for k = evFrom + 1 to evHit
        lb = k == 1 ? t1Lb : t2Lb
        label.set_text(lb, "✓ " + label.get_text(lb))
if evEnd and showTgt
    line.set_x2(t1Ln, bar_index)
    line.set_x2(t2Ln, bar_index)
    line.set_x2(invLn, bar_index)
    label.set_x(t1Lb, bar_index + 1)
    label.set_x(t2Lb, bar_index + 1)
    label.set_x(invLb, bar_index + 1)

// ─────────────────────────────────────────────────────────────────────────
//  HTF CANDLES ON THE RIGHT
// ─────────────────────────────────────────────────────────────────────────
HTF_GAP = 22   // HTF candles start this many bars right of price, clear of the T1 / T2 / INVALID labels
var array<box>   hBx = array.new<box>()
var array<line>  hWk = array.new<line>()
var array<label> hLb = array.new<label>()
if barstate.islast and showHtf and htfOk
    for o in hBx
        box.delete(o)
    for o in hWk
        line.delete(o)
    for o in hLb
        label.delete(o)
    array.clear(hBx)
    array.clear(hWk)
    array.clear(hLb)
    nDone = math.min(array.size(cO), htfCount - 1)
    total = nDone + 1
    lowAll = hL
    for i = 0 to total - 1
        isLive = i == total - 1
        idx = array.size(cO) - nDone + i
        o_ = isLive ? hO : array.get(cO, idx)
        h_ = isLive ? hH : array.get(cH, idx)
        l_ = isLive ? hL : array.get(cL, idx)
        c_ = isLive ? close : array.get(cC, idx)
        col = c_ >= o_ ? UP : DN
        lowAll := math.min(lowAll, l_)
        x0 = bar_index + HTF_GAP + i * 7
        array.push(hBx, box.new(x0, math.max(o_, c_), x0 + 4, math.min(o_, c_), border_color = col, border_width = 1, bgcolor = color.new(col, isLive ? 55 : 35)))
        array.push(hWk, line.new(x0 + 2, h_, x0 + 2, l_, color = col, width = 2))
        // C1 / C2 / C3 tags while a model is in play
        back = total - 1 - i   // 0 = forming candle
        tagTxt = stage == 1 ? (back == 0 ? "C2" : back == 1 ? "C1" : "") : stage == 2 ? (back == 0 ? "C3" : back == 1 ? "C2" : back == 2 ? "C1" : "") : ""
        if tagTxt != ""
            array.push(hLb, label.new(x0 + 2, h_, tagTxt, style = label.style_label_down, color = tagTxt == "C1" ? TGT : (dir == 1 ? UP : DN), textcolor = tagTxt == "C1" or dir == -1 ? color.white : INK, size = size.small))
    array.push(hLb, label.new(bar_index + HTF_GAP + int(math.round((total - 1) * 3.5)), lowAll, str.upper(htfName) + " CANDLES", style = label.style_label_up, color = NONE, textcolor = MUTE, size = size.small))

// ─────────────────────────────────────────────────────────────────────────
//  PANEL
// ─────────────────────────────────────────────────────────────────────────
pos = tblPos == "Top Right" ? position.top_right : tblPos == "Bottom Right" ? position.bottom_right : tblPos == "Top Left" ? position.top_left : position.bottom_left
var table tb = na

cell(int c, int r, string t, color fg, color bg, string al = text.align_left) =>
    table.cell(tb, c, r, t, text_color = fg, bgcolor = bg, text_size = tSize, text_halign = al)

if barstate.islast and showTbl
    table.delete(tb)   // rebuilt each time: merged cells cannot be merged twice
    tb := table.new(pos, 5, 16, bgcolor = PANEL, border_color = PANEL, border_width = 2, frame_color = color.new(TGT, 30), frame_width = 1)
    if not htfOk
        cell(0, 0, "FRACTAL MODEL", TGTX, PANEL)
        cell(0, 1, "Pick a higher timeframe above the chart's", TXT, ROW)
    else
        mc = dir == 1 ? UP : dir == -1 ? DN : GREY
        stName = stage == 0 ? "SEARCHING" : stage == 1 ? "① C1 SWEPT" : "② C3 RUNNING"
        cell(0, 0, "FRACTAL MODEL · " + htfName, MUTE, PANEL)
        table.merge_cells(tb, 0, 0, 1, 0)
        cell(2, 0, stName, stage == 0 ? TXT : dir == -1 ? color.white : INK, stage == 0 ? ROW : mc, text.align_center)
        table.merge_cells(tb, 2, 0, 4, 0)
        mins = (htfEnd - timenow) / 60000.0
        left = na(htfEnd) ? "—" : mins >= 1440 ? str.tostring(mins / 1440, "0.0") + "d" : mins >= 60 ? str.tostring(mins / 60, "0.0") + "h" : str.tostring(math.max(mins, 0), "0") + "m"
        cell(0, 1, "HTF candle closes in", MUTE, ROW)
        cell(1, 1, left, TXT, ROW)
        table.merge_cells(tb, 1, 1, 4, 1)
        cell(0, 2, "Model", MUTE, ROW)
        cell(1, 2, dir == 1 ? "BULLISH · C1 low swept" : dir == -1 ? "BEARISH · C1 high swept" : "—", dir == 0 ? TXT : mc, ROW)
        table.merge_cells(tb, 1, 2, 4, 2)
        cell(0, 3, "C2 closure", MUTE, ROW)
        cell(1, 3, stage == 2 ? "✓ closed inside C1" : stage == 1 ? "waiting for C2 to close" : "—", stage == 2 ? mc : TXT, ROW)
        table.merge_cells(tb, 1, 3, 4, 3)
        cell(0, 4, "CISD", MUTE, ROW)
        cell(1, 4, stage == 0 ? "—" : cisdOn ? "✓ " + px(cisdLvl) : na(cisdLvl) ? "—" : "waiting · " + px(cisdLvl), cisdOn ? mc : TXT, ROW)
        table.merge_cells(tb, 1, 4, 4, 4)
        cell(0, 5, "C1 range", MUTE, ROW)
        cell(1, 5, stage == 0 ? "—" : px(c1L) + " – " + px(c1H), TGTX, ROW)
        table.merge_cells(tb, 1, 5, 4, 5)
        cell(0, 6, "T1 · C1 equilibrium", MUTE, ROW)
        cell(1, 6, stage == 2 ? (hitMax >= 1 ? "✓ " : "") + px(t1) : "—", stage == 2 and hitMax >= 1 ? TGTX : TXT, ROW)
        table.merge_cells(tb, 1, 6, 4, 6)
        cell(0, 7, "T2 · C1 opposite side", MUTE, ROW)
        cell(1, 7, stage == 2 ? (hitMax >= 2 ? "✓ " : "") + px(t2) : "—", stage == 2 and hitMax >= 2 ? TGTX : TXT, ROW)
        table.merge_cells(tb, 1, 7, 4, 7)
        cell(0, 8, "Invalid beyond", MUTE, ROW)
        cell(1, 8, stage >= 1 ? px(stage == 2 ? inv : swX) : "—", dir == 1 ? DN : UP, ROW)
        table.merge_cells(tb, 1, 8, 4, 8)

        cell(0, 9, "TRACK RECORD · THIS SYMBOL", TGTX, PANEL)
        table.merge_cells(tb, 0, 9, 4, 9)
        cell(0, 10, "", MUTE, PANEL)
        cell(1, 10, "Models", MUTE, PANEL, text.align_center)
        cell(2, 10, "T1", MUTE, PANEL, text.align_center)
        cell(3, 10, "T2", MUTE, PANEL, text.align_center)
        cell(4, 10, "Failed", MUTE, PANEL, text.align_center)
        for d = 0 to 2
            n  = d < 2 ? array.get(rN, d) : array.sum(rN)
            a1 = d < 2 ? array.get(rT1, d) : array.sum(rT1)
            a2 = d < 2 ? array.get(rT2, d) : array.sum(rT2)
            af = d < 2 ? array.get(rFail, d) : array.sum(rFail)
            nm = d == 0 ? "▲ Bullish" : d == 1 ? "▼ Bearish" : "All models"
            rb = d == 2 ? PANEL : ROW
            cell(0, 11 + d, nm, d == 0 ? UP : d == 1 ? DN : TXT, rb)
            cell(1, 11 + d, str.tostring(n), TXT, rb, text.align_center)
            cell(2, 11 + d, pct(a1, n), TXT, rb, text.align_center)
            cell(3, 11 + d, pct(a2, n), TGTX, rb, text.align_center)
            cell(4, 11 + d, pct(af, n), MUTE, rb, text.align_center)
        cN = array.sum(rCisd)
        cT = array.sum(rCisdT2)
        nN = array.sum(rN) - cN
        nT = array.sum(rT2) - cT
        cell(0, 14, "T2 · CISD before C3", TXT, ROW)
        cell(1, 14, str.tostring(cN), TXT, ROW, text.align_center)
        cell(2, 14, "", TXT, ROW)
        cell(3, 14, pct(cT, cN), TGTX, ROW, text.align_center)
        cell(4, 14, "vs " + pct(nT, nN) + " without", MUTE, ROW, text.align_center)
        t2n = array.sum(rT2)
        avgB = t2n > 0 ? array.sum(rBars) * 1.0 / t2n : na
        cell(0, 15, "Avg time to T2: " + (na(avgB) ? "—" : str.tostring(avgB, "0") + " bars"), MUTE, PANEL)
        table.merge_cells(tb, 0, 15, 4, 15)

// ─────────────────────────────────────────────────────────────────────────
//  ALERTS
// ─────────────────────────────────────────────────────────────────────────
if alSweep and evSweep
    alert(syminfo.ticker + " fractal model: " + htfName + " C2 swept C1 " + (dir == 1 ? "low " + px(c1L) : "high " + px(c1H)), alert.freq_once_per_bar_close)
if alCisd and evCisd
    alert(syminfo.ticker + " fractal model: CISD " + (dir == 1 ? "up" : "down") + " at " + px(cisdLvl), alert.freq_once_per_bar_close)
if alLive and evLive
    alert(syminfo.ticker + " fractal model confirmed: C2 closed inside C1 · T1 " + px(t1) + " · T2 " + px(t2) + " · invalid beyond " + px(inv), alert.freq_once_per_bar_close)
if alRes and evHit > 0 and not evDone
    alert(syminfo.ticker + " fractal model: T" + str.tostring(evHit) + " hit", alert.freq_once_per_bar_close)
if alRes and evDone
    alert(syminfo.ticker + " fractal model complete: C1 " + (dir == 1 ? "high" : "low") + " reached", alert.freq_once_per_bar_close)
if alRes and evFail
    alert(syminfo.ticker + " fractal model failed: price traded beyond the C2 sweep", alert.freq_once_per_bar_close)

alertcondition(evSweep, "C1 swept", "{{ticker}} fractal model: C2 swept C1")
alertcondition(evCisd, "CISD", "{{ticker}} fractal model: CISD")
alertcondition(evLive, "Model confirmed", "{{ticker}} fractal model confirmed: C2 closed inside C1")
alertcondition(evDone, "Model complete", "{{ticker}} fractal model complete")
alertcondition(evFail, "Model failed", "{{ticker}} fractal model failed")

// ─────────────────────────────────────────────────────────────────────────
//  GLOW CANDLES (LunqFX house style)
// ─────────────────────────────────────────────────────────────────────────
GLOW_UP_DARK  = #00E5FF
GLOW_DN_DARK  = #7C4DFF
GLOW_UP_LIGHT = #0097A7
GLOW_DN_LIGHT = #5B2BD9

glowUp   = isLight ? GLOW_UP_LIGHT : GLOW_UP_DARK
glowDn   = isLight ? GLOW_DN_LIGHT : GLOW_DN_DARK
glowEdge = close >= open ? glowUp : glowDn
glowOn   = candOn_ and candGlw
GLOW_NONE = color.new(color.black, 100)

plotcandle(candOn_ and not glowOn ? open : na, high, low, close, "Candles", color = color.new(glowEdge, 24), wickcolor = color.new(glowEdge, 18), bordercolor = glowEdge, display = display.pane)

gQ = (close - open) / 4.0
plotcandle(glowOn ? open : na, glowOn ? math.max(open, close) : na, glowOn ? math.min(open, close) : na, glowOn ? close : na, "Glow mask", color = chart.bg_color, wickcolor = GLOW_NONE, bordercolor = chart.bg_color, display = display.pane)
plotcandle(glowOn ? open : na, glowOn ? math.max(open, open + gQ) : na, glowOn ? math.min(open, open + gQ) : na, glowOn ? open + gQ : na, "Glow band 1", color = color.new(glowEdge, 78), wickcolor = GLOW_NONE, bordercolor = GLOW_NONE, display = display.pane)
plotcandle(glowOn ? open + gQ : na, glowOn ? math.max(open + gQ, open + 2 * gQ) : na, glowOn ? math.min(open + gQ, open + 2 * gQ) : na, glowOn ? open + 2 * gQ : na, "Glow band 2", color = color.new(glowEdge, 58), wickcolor = GLOW_NONE, bordercolor = GLOW_NONE, display = display.pane)
plotcandle(glowOn ? open + 2 * gQ : na, glowOn ? math.max(open + 2 * gQ, open + 3 * gQ) : na, glowOn ? math.min(open + 2 * gQ, open + 3 * gQ) : na, glowOn ? open + 3 * gQ : na, "Glow band 3", color = color.new(glowEdge, 36), wickcolor = GLOW_NONE, bordercolor = GLOW_NONE, display = display.pane)
plotcandle(glowOn ? open + 3 * gQ : na, glowOn ? math.max(open + 3 * gQ, close) : na, glowOn ? math.min(open + 3 * gQ, close) : na, glowOn ? close : na, "Glow band 4", color = color.new(glowEdge, 8), wickcolor = GLOW_NONE, bordercolor = GLOW_NONE, display = display.pane)
plotcandle(glowOn ? open : na, glowOn ? high : na, glowOn ? low : na, glowOn ? close : na, "Glow wick", color = GLOW_NONE, wickcolor = color.new(glowEdge, 10), bordercolor = color.new(glowEdge, 30), display = display.pane)
````
