# Displacement Acceptance Engine [PhenLabs]

- url: https://www.tradingview.com/script/JdwSilCu-Displacement-Acceptance-Engine-PhenLabs/
- type: indicator
- pine_id: PUB;fa22ddd33a51454ab68e4d0720dfc358
- version: 1.0

## Description

[b]📊 Displacement Acceptance Engine [PhenLabs][/b]

Version: PineScript™ v6

[b]📌 Description[/b]
The Displacement Acceptance Engine grades what happens after a liquidity sweep — not just the sweep itself. Most sweep tools fire on a wick beyond a swing and stop there. DAE waits for a real displacement leg, then scores whether price accepts that move or rejects it.

Traders see a clean story on the chart: sweep zone → neon displacement beam → scored ▲ ACC / ✕ REJ label, plus a live dashboard with bias, state, score, last event, HTF context, and volume pulse. Built for SMC/ICT retail who want continuation quality after stop-hunts on crypto, indices, FX, and metals.

[b]🔧 Core Features[/b]
• Confirmed BSL/SSL liquidity pools from swing pivots
• Stop-hunt sweep detection with ATR buffer and optional close-back-inside
• Displacement window that requires body + ATR expansion beyond the sweep
• Acceptance vs rejection resolve with hold-fraction logic
• Mechanical 0–10 score (depth, displacement, body, volume, structure, HTF)
• Neon beams, sweep zones, scored labels, and PhenLabs command dashboard
• Cooldown + max visible events to keep charts readable

[b]⚙️ How It Works[/b]
• Sweep Depth — wick pierce beyond the pool normalized by ATR
• Displacement Magnitude — impulse leg size vs ATR after the sweep
• Body Quality — displacement candle body strength vs ATR
• Volume Pulse — bar volume vs SMA (HOT / OK / SOFT)
• Structure Break — close through recent swing extreme or pool buffer
• HTF Bias — optional higher-timeframe alignment bonus
• Final score gates high-conviction ▲ ACC labels; failed holds print ✕ REJ

[b]🎨 Visual Guide[/b]
• Dotted pool rails — active buyside / sellside liquidity
• Translucent sweep boxes — stop-hunt event footprint
• Dual-glow displacement beams — core + outer rail from origin to impulse close
• ▲ ACC / ✕ REJ scored labels — continuation quality at a glance
• Soft bar highlight — high-score acceptance bars only
• Top-right dashboard — BIAS · STATE · SCORE · EVENT · HTF · VOL · POOLS

[b]📡 Alerts[/b]
• Bull Liquidity Sweep
• Bear Liquidity Sweep
• Bull Displacement
• Bear Displacement
• Bull Acceptance High Score
• Bear Acceptance High Score
• Displacement Rejection

[b]⚙️ Key Settings[/b]
• Pivot Lookback — Default: 5 — pool sensitivity
• Require Close Back Inside — Default: true — classic stop-hunt reclaim
• Displacement Window — Default: 6 bars — time allowed for impulse
• Min Displacement (ATR) — Default: 0.55 — impulse size gate
• Acceptance Window — Default: 8 bars — hold / fail resolve time
• Hold Fraction of Disp Leg — Default: 0.45 — acceptance hold line
• Min Acceptance Score — Default: 6.0 — label / highlight gate
• HTF Bias Timeframe — Default: 60 — score alignment context
• Max Visible Events — Default: 8 — clutter control

[quote][b]⚠️ Disclaimer[/b]
Educational tool only. Not financial advice. Past structure ≠ future results. Always manage risk.[/quote]

## Source Code

````pine
//@version=6
indicator("Displacement Acceptance Engine [PhenLabs]", shorttitle="DAE", overlay=true,
     max_labels_count=500, max_lines_count=500, max_boxes_count=500,
     explicit_plot_zorder=true)

// ═══════════════════════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════════════════════
string G_DET = "Detection"
int    pivotLen     = input.int(5, "Pivot Lookback", minval=2, maxval=30, group=G_DET,
     tooltip="Bars left/right to confirm BSL/SSL swing pools.")
float  sweepBufAtr  = input.float(0.05, "Sweep Buffer (ATR)", minval=0.0, maxval=1.0, step=0.01, group=G_DET)
bool   reqReclaim   = input.bool(true, "Require Close Back Inside", group=G_DET,
     tooltip="Classic stop-hunt: wick beyond pool, close back inside.")
float  minWickAtr   = input.float(0.12, "Min Sweep Wick (ATR)", minval=0.02, maxval=2.0, step=0.01, group=G_DET)
int    maxPools     = input.int(8, "Max Pools / Side", minval=2, maxval=20, group=G_DET)

string G_DISP = "Displacement"
int    dispWindow   = input.int(6, "Displacement Window (bars)", minval=2, maxval=30, group=G_DISP,
     tooltip="Bars after sweep to hunt for displacement.")
float  dispMinAtr   = input.float(0.55, "Min Displacement (ATR)", minval=0.1, maxval=5.0, step=0.05, group=G_DISP)
float  bodyMinAtr   = input.float(0.35, "Min Displacement Body (ATR)", minval=0.05, maxval=3.0, step=0.05, group=G_DISP)
int    acceptWindow = input.int(8, "Acceptance Window (bars)", minval=2, maxval=40, group=G_DISP,
     tooltip="Bars after displacement to confirm acceptance or rejection.")
float  holdPct      = input.float(0.45, "Hold Fraction of Disp Leg", minval=0.15, maxval=0.9, step=0.05, group=G_DISP,
     tooltip="Acceptance needs close beyond this fraction of the displacement leg from origin.")

string G_SCORE = "Score Model"
float  minScore     = input.float(6.0, "Min Acceptance Score", minval=0.0, maxval=10.0, step=0.1, group=G_SCORE)
int    volLen       = input.int(20, "Volume SMA Length", minval=5, maxval=100, group=G_SCORE)
float  volMult      = input.float(1.25, "Volume Pulse Mult", minval=1.0, maxval=5.0, step=0.05, group=G_SCORE)
string htfTf        = input.timeframe("60", "HTF Bias Timeframe", group=G_SCORE)
bool   useHtf       = input.bool(true, "Use HTF Bias in Score", group=G_SCORE)

string G_VIS = "Visuals"
int    maxEvents    = input.int(8, "Max Visible Events", minval=1, maxval=30, group=G_VIS)
bool   showPools    = input.bool(true, "Show Liquidity Pools", group=G_VIS)
bool   showSweepZ   = input.bool(true, "Show Sweep Zones", group=G_VIS)
bool   showBeams    = input.bool(true, "Show Displacement Beams", group=G_VIS)
bool   showLabels   = input.bool(true, "Show Scored Labels", group=G_VIS)
bool   showDash     = input.bool(true, "Show Dashboard", group=G_VIS)
bool   showBg       = input.bool(true, "Highlight High-Score Bars", group=G_VIS)
color  bullCol      = input.color(#00F5FF, "Bull Color", group=G_VIS)
color  bearCol      = input.color(#FF2BD6, "Bear Color", group=G_VIS)
color  neutCol      = input.color(#A855F7, "Neutral / Accent", group=G_VIS)
color  dashBg       = input.color(#0B0F1A, "Dashboard Background", group=G_VIS)
color  dashTxt      = input.color(#E8F1FF, "Dashboard Text", group=G_VIS)

string G_ALERT = "Alerts"
float  alertScore   = input.float(7.0, "High-Score Alert Threshold", minval=0.0, maxval=10.0, step=0.1, group=G_ALERT)

// ═══════════════════════════════════════════════════════════════════════════
// CORE SERIES
// ═══════════════════════════════════════════════════════════════════════════
float atrVal = ta.atr(14)
float volSma = ta.sma(volume, volLen)
float volPulse = volSma > 0 ? volume / volSma : 1.0
float priorHi10 = ta.highest(high, 10)[1]
float priorLo10 = ta.lowest(low, 10)[1]

float htfClose = request.security(syminfo.tickerid, htfTf, close, barmerge.gaps_off, barmerge.lookahead_off)
float htfClose1 = request.security(syminfo.tickerid, htfTf, close[1], barmerge.gaps_off, barmerge.lookahead_off)
int   htfBias = useHtf ? (htfClose > htfClose1 ? 1 : htfClose < htfClose1 ? -1 : 0) : 0

float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low, pivotLen, pivotLen)

// ═══════════════════════════════════════════════════════════════════════════
// POOL BUFFERS
// ═══════════════════════════════════════════════════════════════════════════
var array<float> bslPx  = array.new_float()
var array<int>   bslBar = array.new_int()
var array<float> sslPx  = array.new_float()
var array<int>   sslBar = array.new_int()
var array<line>  bslLn  = array.new_line()
var array<line>  sslLn  = array.new_line()

f_pushPool(array<float> pxA, array<int> barA, array<line> lnA, float px, int b, color c) =>
    array.push(pxA, px)
    array.push(barA, b)
    color lc = showPools ? color.new(c, 55) : color.new(c, 100)
    line nl = line.new(b, px, bar_index, px, color=lc, width=1, style=line.style_dotted)
    array.push(lnA, nl)
    if array.size(pxA) > maxPools
        array.shift(pxA)
        array.shift(barA)
        line old = array.shift(lnA)
        line.delete(old)

if not na(ph) and bar_index > pivotLen * 2
    f_pushPool(bslPx, bslBar, bslLn, ph, bar_index - pivotLen, bearCol)

if not na(pl) and bar_index > pivotLen * 2
    f_pushPool(sslPx, sslBar, sslLn, pl, bar_index - pivotLen, bullCol)

if array.size(bslLn) > 0
    for i = 0 to array.size(bslLn) - 1
        line.set_x2(array.get(bslLn, i), bar_index)
if array.size(sslLn) > 0
    for i = 0 to array.size(sslLn) - 1
        line.set_x2(array.get(sslLn, i), bar_index)

// ═══════════════════════════════════════════════════════════════════════════
// EVENT STATE MACHINE
// dir: 1 bull (SSL sweep → up disp), -1 bear (BSL sweep → down disp)
// phase: 0 idle, 1 sweep armed, 2 displacement, 3 resolved
// ═══════════════════════════════════════════════════════════════════════════
var int   evDir       = 0
var int   evPhase     = 0
var int   evSweepBar  = na
var float evSweepLvl  = na
var float evSweepExt  = na
var float evOrigin    = na
var float evDispEnd   = na
var int   evDispBar   = na
var float evScore     = 0.0
var string evLast     = "—"
var string evState    = "IDLE"
var float evLastScore = 0.0
var int   evLastDir   = 0
var int   cooldown    = 0

var array<box>   evBoxes  = array.new_box()
var array<line>  evBeams  = array.new_line()
var array<label> evLabs   = array.new_label()

f_cap(array<box> ba, array<line> la, array<label> lb, int cap) =>
    while array.size(ba) > cap
        box.delete(array.shift(ba))
    while array.size(la) > cap * 2
        line.delete(array.shift(la))
    while array.size(lb) > cap
        label.delete(array.shift(lb))

f_score(float depthAtr, float dispAtr, float bodyAtr, float vPulse, bool bosHit, int dir) =>
    float sDepth = math.min(2.0, depthAtr / 0.35 * 1.0)
    float sDisp  = math.min(2.5, dispAtr / math.max(dispMinAtr, 0.01) * 1.4)
    float sBody  = math.min(2.0, bodyAtr / math.max(bodyMinAtr, 0.01) * 1.2)
    float sVol   = vPulse >= volMult ? math.min(2.0, 1.0 + (vPulse - volMult) * 0.6) : math.min(1.0, vPulse / volMult)
    float sBos   = bosHit ? 1.0 : 0.0
    float sHtf   = useHtf ? (dir == htfBias ? 1.0 : htfBias == 0 ? 0.4 : 0.0) : 0.5
    float raw = sDepth + sDisp + sBody + sVol + sBos + sHtf
    math.min(10.0, math.round(raw * 10.0) / 10.0)

// Nearest pool sweeps (confirmed bar only)
bool warm = bar_index > pivotLen * 3 and not na(atrVal) and atrVal > 0
float buf = atrVal * sweepBufAtr

bool bullSweep = false
bool bearSweep = false
float bullLvl = na
float bearLvl = na
float bullExt = na
float bearExt = na
float bullDepth = 0.0
float bearDepth = 0.0

if warm and evPhase == 0 and cooldown == 0
    if array.size(sslPx) > 0
        for i = 0 to array.size(sslPx) - 1
            float lvl = array.get(sslPx, i)
            float pierce = lvl - low
            bool wickOk = pierce >= atrVal * minWickAtr + buf
            bool beyond = low < lvl - buf
            bool backIn = not reqReclaim or close > lvl
            float depthNow = pierce / atrVal
            if beyond and wickOk and backIn and depthNow >= bullDepth
                bullSweep := true
                bullLvl := lvl
                bullExt := low
                bullDepth := depthNow
    if array.size(bslPx) > 0
        for i = 0 to array.size(bslPx) - 1
            float lvl = array.get(bslPx, i)
            float pierce = high - lvl
            bool wickOk = pierce >= atrVal * minWickAtr + buf
            bool beyond = high > lvl + buf
            bool backIn = not reqReclaim or close < lvl
            float depthNow = pierce / atrVal
            if beyond and wickOk and backIn and depthNow >= bearDepth
                bearSweep := true
                bearLvl := lvl
                bearExt := high
                bearDepth := depthNow

// Arm sweep (prefer deeper if both — rare)
if bullSweep or bearSweep
    bool pickBull = bullSweep and (not bearSweep or bullDepth >= bearDepth)
    if pickBull
        evDir := 1
        evPhase := 1
        evSweepBar := bar_index
        evSweepLvl := bullLvl
        evSweepExt := bullExt
        evOrigin := bullExt
        evDispEnd := na
        evDispBar := na
        evScore := 0.0
        evState := "SWEEP"
        if showSweepZ
            box zb = box.new(bar_index, bullLvl, bar_index + 1, bullExt,
                 border_color=color.new(bullCol, 30), bgcolor=color.new(bullCol, 88),
                 border_width=1)
            array.push(evBoxes, zb)
    else if bearSweep
        evDir := -1
        evPhase := 1
        evSweepBar := bar_index
        evSweepLvl := bearLvl
        evSweepExt := bearExt
        evOrigin := bearExt
        evDispEnd := na
        evDispBar := na
        evScore := 0.0
        evState := "SWEEP"
        if showSweepZ
            box zb = box.new(bar_index, bearExt, bar_index + 1, bearLvl,
                 border_color=color.new(bearCol, 30), bgcolor=color.new(bearCol, 88),
                 border_width=1)
            array.push(evBoxes, zb)

// Extend sweep box while armed
if evPhase == 1 and showSweepZ and array.size(evBoxes) > 0
    box lastB = array.get(evBoxes, array.size(evBoxes) - 1)
    box.set_right(lastB, bar_index)

// Displacement hunt
bool dispNow = false
if evPhase == 1 and not na(evSweepBar)
    int age = bar_index - evSweepBar
    if age > dispWindow
        evPhase := 0
        evState := "IDLE"
        evDir := 0
        cooldown := 3
    else if age >= 1
        if evDir == 1
            float leg = close - evOrigin
            float bodySz = math.abs(close - open)
            bool strong = close > evSweepLvl and leg >= atrVal * dispMinAtr and bodySz >= atrVal * bodyMinAtr and close > open
            if strong
                dispNow := true
                evDispEnd := close
                evDispBar := bar_index
                evPhase := 2
                evState := "DISPLACEMENT"
        else if evDir == -1
            float leg = evOrigin - close
            float bodySz = math.abs(close - open)
            bool strong = close < evSweepLvl and leg >= atrVal * dispMinAtr and bodySz >= atrVal * bodyMinAtr and close < open
            if strong
                dispNow := true
                evDispEnd := close
                evDispBar := bar_index
                evPhase := 2
                evState := "DISPLACEMENT"

if dispNow and showBeams and not na(evDispEnd)
    color coreC = evDir == 1 ? bullCol : bearCol
    int x1 = evSweepBar
    float y1 = evOrigin
    int x2 = bar_index
    float y2 = evDispEnd
    line glow = line.new(x1, y1, x2, y2, color=color.new(coreC, 75), width=6)
    line core = line.new(x1, y1, x2, y2, color=color.new(coreC, 15), width=2)
    array.push(evBeams, glow)
    array.push(evBeams, core)

// Acceptance / Rejection resolve
bool accFire = false
bool rejFire = false
float fireScore = 0.0

if evPhase == 2 and not na(evDispBar) and not na(evDispEnd)
    int aAge = bar_index - evDispBar
    float legSpan = math.abs(evDispEnd - evOrigin)
    float holdLine = evDir == 1 ? evOrigin + legSpan * holdPct : evOrigin - legSpan * holdPct

    // Structure break proxy: close beyond pre-sweep swing mid of last 10 bars before sweep
    bool bosHit = false
    if evDir == 1
        bosHit := close > priorHi10 or close > evSweepLvl + atrVal * 0.25
    else
        bosHit := close < priorLo10 or close < evSweepLvl - atrVal * 0.25

    float depthAtr = math.abs(evSweepLvl - evOrigin) / atrVal
    float dispAtr  = legSpan / atrVal
    float bodyAtr  = math.abs(close - open) / atrVal

    // Rejection: reclaim through sweep level against displacement
    bool rejected = false
    if evDir == 1
        rejected := close < evSweepLvl and close < open
    else
        rejected := close > evSweepLvl and close > open

    // Acceptance: hold beyond holdLine for this bar, not rejected
    bool accepted = false
    if not rejected
        if evDir == 1
            accepted := close >= holdLine and low > evOrigin
        else
            accepted := close <= holdLine and high < evOrigin

    if rejected or (aAge >= 1 and accepted) or aAge > acceptWindow
        float sc = f_score(depthAtr, dispAtr, bodyAtr, volPulse, bosHit, evDir)
        fireScore := sc
        evScore := sc
        evLastScore := sc
        evLastDir := evDir

        if rejected or (aAge > acceptWindow and not accepted)
            rejFire := true
            evState := "REJECTED"
            evLast := evDir == 1 ? "BULL REJ" : "BEAR REJ"
            if showLabels
                color lc = evDir == 1 ? bullCol : bearCol
                string txt = evDir == 1 ? "✕ REJ " + str.tostring(sc, "#.0") : "✕ REJ " + str.tostring(sc, "#.0")
                label lab = label.new(bar_index, evDir == 1 ? low : high, txt,
                     style=evDir == 1 ? label.style_label_up : label.style_label_down,
                     color=color.new(lc, 70), textcolor=lc, yloc=evDir == 1 ? yloc.belowbar : yloc.abovebar,
                     size=size.small)
                array.push(evLabs, lab)
        else
            accFire := true
            evState := "ACCEPTED"
            evLast := evDir == 1 ? "BULL ACC" : "BEAR ACC"
            if showLabels and sc >= minScore * 0.7
                color lc = evDir == 1 ? bullCol : bearCol
                string mark = evDir == 1 ? "▲ ACC " : "▼ ACC "
                string txt = mark + str.tostring(sc, "#.0")
                label lab = label.new(bar_index, evDir == 1 ? low : high, txt,
                     style=evDir == 1 ? label.style_label_up : label.style_label_down,
                     color=color.new(lc, 55), textcolor=lc, yloc=evDir == 1 ? yloc.belowbar : yloc.abovebar,
                     size=size.normal)
                array.push(evLabs, lab)
            // Intensify beam end glow on strong acceptance
            if showBeams and sc >= minScore and not na(evDispBar)
                color lc = evDir == 1 ? bullCol : bearCol
                line tipG = line.new(evDispBar, evDispEnd, bar_index, close, color=color.new(lc, 80), width=5)
                line tipC = line.new(evDispBar, evDispEnd, bar_index, close, color=color.new(lc, 20), width=2)
                array.push(evBeams, tipG)
                array.push(evBeams, tipC)

        evPhase := 0
        cooldown := 5
        f_cap(evBoxes, evBeams, evLabs, maxEvents)

if cooldown > 0
    cooldown -= 1

// Soft bg on high-score acceptance
bool hiBull = accFire and evLastDir == 1 and fireScore >= minScore
bool hiBear = accFire and evLastDir == -1 and fireScore >= minScore
bgcolor(showBg and hiBull ? color.new(bullCol, 92) : showBg and hiBear ? color.new(bearCol, 92) : na)

// Lightweight markers (gated with and, never ternary-na)
plotshape(accFire and evLastDir == 1 and fireScore >= minScore and showLabels, title="Bull ACC",
     style=shape.triangleup, location=location.belowbar, color=bullCol, size=size.tiny, text="")
plotshape(accFire and evLastDir == -1 and fireScore >= minScore and showLabels, title="Bear ACC",
     style=shape.triangledown, location=location.abovebar, color=bearCol, size=size.tiny, text="")
plotshape(rejFire and showLabels, title="Rejection",
     style=shape.xcross, location=location.abovebar, color=neutCol, size=size.tiny)

// ═══════════════════════════════════════════════════════════════════════════
// DASHBOARD
// ═══════════════════════════════════════════════════════════════════════════
var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(dashBg, 10),
     border_color=color.new(neutCol, 40), border_width=1, frame_color=color.new(neutCol, 20), frame_width=1)

if showDash and barstate.islast
    color biasC = htfBias == 1 ? bullCol : htfBias == -1 ? bearCol : color.new(dashTxt, 40)
    string biasS = htfBias == 1 ? "BULL" : htfBias == -1 ? "BEAR" : "FLAT"
    color stC = evState == "ACCEPTED" ? bullCol : evState == "REJECTED" ? bearCol : evState == "DISPLACEMENT" ? neutCol : color.new(dashTxt, 20)
    string vpS = volPulse >= volMult ? "HOT" : volPulse >= 1.0 ? "OK" : "SOFT"
    color vpC = volPulse >= volMult ? bullCol : volPulse >= 1.0 ? dashTxt : color.new(dashTxt, 50)
    string scS = str.tostring(evLastScore, "#.0")
    color scC = evLastScore >= minScore ? bullCol : evLastScore >= minScore * 0.7 ? neutCol : color.new(dashTxt, 40)

    table.cell(dash, 0, 0, "DAE", text_color=neutCol, text_size=size.small, bgcolor=color.new(neutCol, 85))
    table.cell(dash, 1, 0, "𓄀", text_color=dashTxt, text_size=size.small, bgcolor=color.new(neutCol, 85))
    table.cell(dash, 0, 1, "BIAS", text_color=color.new(dashTxt, 30), text_size=size.tiny)
    table.cell(dash, 1, 1, biasS, text_color=biasC, text_size=size.small)
    table.cell(dash, 0, 2, "STATE", text_color=color.new(dashTxt, 30), text_size=size.tiny)
    table.cell(dash, 1, 2, evState, text_color=stC, text_size=size.small)
    table.cell(dash, 0, 3, "SCORE", text_color=color.new(dashTxt, 30), text_size=size.tiny)
    table.cell(dash, 1, 3, scS, text_color=scC, text_size=size.small)
    table.cell(dash, 0, 4, "EVENT", text_color=color.new(dashTxt, 30), text_size=size.tiny)
    table.cell(dash, 1, 4, evLast, text_color=dashTxt, text_size=size.small)
    table.cell(dash, 0, 5, "HTF", text_color=color.new(dashTxt, 30), text_size=size.tiny)
    table.cell(dash, 1, 5, htfTf + " " + biasS, text_color=biasC, text_size=size.small)
    table.cell(dash, 0, 6, "VOL", text_color=color.new(dashTxt, 30), text_size=size.tiny)
    table.cell(dash, 1, 6, vpS + " " + str.tostring(volPulse, "#.00"), text_color=vpC, text_size=size.small)
    int bslN = array.size(bslPx)
    int sslN = array.size(sslPx)
    table.cell(dash, 0, 7, "POOLS", text_color=color.new(dashTxt, 30), text_size=size.tiny)
    table.cell(dash, 1, 7, "B" + str.tostring(bslN) + " / S" + str.tostring(sslN), text_color=dashTxt, text_size=size.small)

// ═══════════════════════════════════════════════════════════════════════════
// ALERTS
// ═══════════════════════════════════════════════════════════════════════════
alertcondition(bullSweep, title="Bull Liquidity Sweep", message="DAE: Bull SSL sweep detected")
alertcondition(bearSweep, title="Bear Liquidity Sweep", message="DAE: Bear BSL sweep detected")
alertcondition(dispNow and evDir == 1, title="Bull Displacement", message="DAE: Bull displacement after sweep")
alertcondition(dispNow and evDir == -1, title="Bear Displacement", message="DAE: Bear displacement after sweep")
alertcondition(accFire and evLastDir == 1 and fireScore >= alertScore, title="Bull Acceptance High Score",
     message="DAE: Bull acceptance high score")
alertcondition(accFire and evLastDir == -1 and fireScore >= alertScore, title="Bear Acceptance High Score",
     message="DAE: Bear acceptance high score")
alertcondition(rejFire, title="Displacement Rejection", message="DAE: Displacement rejected / failed hold")
````
