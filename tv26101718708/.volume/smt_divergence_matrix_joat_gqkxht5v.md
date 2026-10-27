# SMT Divergence Matrix [JOAT]

- url: https://www.tradingview.com/script/GqkXhT5v-SMT-Divergence-Matrix-JOAT/
- type: indicator
- pine_id: PUB;2cbe421610ab40849eeb0feb08d582f1
- version: 1.0

## Description

[b]════════════════════════════════[/b]
[b]  SMT DIVERGENCE MATRIX [JOAT][/b]
[b]════════════════════════════════[/b]

Smart Money Technique divergence, automated. This tool watches your chart symbol against up to two correlated reference assets and flags the moment they [i]disagree[/i] at a swing — the classic footprint of one market failing to confirm another. When your chart carves a new low that a correlated market refuses to match, that non-confirmation is highlighted as a potential turn.

[image]https://www.tradingview.com/x/nwQbO9vQ/[/image]

[b]▎ WHAT IT DOES[/b]
It compares swing highs and lows on your chart to the same swings on two reference instruments and looks for [b]SMT divergence[/b] — where the assets normally move together but split at a pivot. Each qualifying event is drawn as a connector line between the two chart pivots, tagged with a [b]BUY[/b] or [b]SELL[/b] pill, and paired with an optional ATR-based stop and target zone. A dashboard reports live correlation, structure, and which reference triggered.

[b]▎ HOW IT WORKS[/b]
• [b]Swing detection[/b] — confirmed pivot highs and lows are located on the chart using a configurable left/right [b]pivot length[/b]. Larger values isolate more significant swings.
• [b]Reference sync[/b] — the same high/low/close series are pulled for up to two reference assets on your chart's timeframe, guarded against invalid symbols.
• [b]Bullish SMT[/b] — the chart prints a [i]lower low[/i] while a correlated reference prints a [i]higher low[/i]. That failure to confirm the downside is read as bullish non-confirmation.
• [b]Bearish SMT[/b] — the chart prints a [i]higher high[/i] while a correlated reference prints a [i]lower high[/i], reading as bearish non-confirmation.
• [b]Either reference can trigger[/b] — a signal fires from whichever asset fails to confirm; the dashboard shows REF1, REF2, or both.
• [b]Correlation filter[/b] — rolling correlation between chart and reference is measured over a lookback. SMT only makes sense when assets normally track together, so signals can be restricted to references whose correlation is currently at or above a minimum.
• [b]Confirmation filter[/b] — the triggering bar can be gated by [b]RSI[/b] momentum turning in the signal direction, by a directional [b]candle[/b] close, by [b]both[/b], or by nothing.
• [b]Cooldown[/b] — a minimum bar gap between same-direction signals prevents clustering, and the engine never fires a buy and sell on the same bar.
• [b]Trade zones[/b] — on each signal, entry is taken at the close, stop is placed a chosen [b]ATR multiple[/b] away, and the target is projected at your [b]risk/reward[/b] ratio. The zones live-extend to the right each bar and freeze the moment price touches the stop or target.

[b]▎ HOW TO USE IT[/b]
• Set [b]Reference Asset 1 and 2[/b] to instruments that genuinely correlate with your chart (index futures, sector peers, a lead/lag pair). The technique is only meaningful when the assets normally move together.
• A [b]BUY[/b] pill below price marks bullish non-confirmation; a [b]SELL[/b] pill above price marks bearish non-confirmation. The pill text names the reference that triggered.
• The [b]divergence line[/b] connects the two chart pivots involved, so you can see the exact swings being compared.
• Treat the [b]red zone[/b] as risk (entry-to-stop) and the [b]blue/violet zone[/b] as reward (entry-to-target). Use them as a visual framework, not a mechanical order.
• Combine signals with your own read of market structure, session timing, and key levels rather than trading them in isolation.

[b]▎ KEY SETTINGS[/b]
• [b]Engine[/b] — swing pivot length, the two reference symbols and their enable toggles, and correlation lookback.
• [b]Filters[/b] — confirmation mode (None / RSI / Candle / Both), RSI length, positive-correlation requirement with a minimum threshold, and signal cooldown.
• [b]Trade Model[/b] — show ATR SL/TP toggle, ATR length, stop distance in ATR multiples, risk/reward target, and a cap on drawn setups for performance.
• [b]Visuals[/b] — divergence lines, signal labels, pivot markers, label size, custom bull/bear colors, an optional candle zone-reader, and a session VWAP with ±σ bands.
• [b]Dashboard[/b] — show toggle, position, and text size.

[b]▎ DASHBOARD[/b]
The panel reports [b]correlation state and value[/b] for each reference (Strong+, Positive, Weak, Negative, Strong−, or OFF), the [b]last SMT[/b] side with the triggering reference, current market [b]structure[/b] (HH / HL / LH / LL), running [b]bull/bear counts[/b], total [b]divergences[/b], live [b]signal status[/b], and current [b]ATR[/b].

[b]▎ ALERTS[/b]
• [b]Bullish SMT[/b] — chart lower low versus a correlated higher low.
• [b]Bearish SMT[/b] — chart higher high versus a correlated lower high.
Both include ticker and interval placeholders in the message.

[b]▎ NOTES[/b]
• Works on any symbol and any timeframe; references are read on the chart's own timeframe.
• Signals are based on [i]confirmed[/i] pivots, which require the configured right-side bars to close before a swing is validated.
• Colored candles and VWAP bands are off by default for a clean chart, and the drawn-setup cap keeps performance stable.
• Reference data uses non-lookahead requests and tolerates invalid symbols without breaking the script.

[i]For research and education only. This is not financial advice. No indicator predicts the future, on-chart signals and counts are illustrative of historical behavior only, and past behavior does not guarantee future results. Always manage your own risk.[/i]

[i]Made with passion by JackOfAllTrades ⚡[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © officialjackofalltrades
//@version=6
indicator("SMT Divergence Matrix [JOAT]", shorttitle="SMT [JOAT]", overlay=true, max_lines_count=500, max_labels_count=500)

//══════════════════════════════════════════════════════════════════════
// SMT DIVERGENCE MATRIX [JOAT]
// Smart Money Technique divergence between the chart symbol and up to
// two correlated reference assets. Blue / purple institutional scheme.
//══════════════════════════════════════════════════════════════════════

//──────────────────────────────────────────────────────────────────────
// 01 · ENGINE
//──────────────────────────────────────────────────────────────────────
string G_ENG = "01 · Engine"
int    pivotLen  = input.int(5, "Swing Pivot Length", minval=1, maxval=50, group=G_ENG, tooltip="Left/right bars for ta.pivothigh / ta.pivotlow. Larger = more significant swings, fewer signals.")
string ref1Sym   = input.symbol("CME_MINI:ES1!", "Reference Asset 1", group=G_ENG, tooltip="First correlated instrument compared against the chart. SMT looks for the chart and this asset disagreeing at a swing.")
bool   useRef1   = input.bool(true, "Enable Reference 1", group=G_ENG)
string ref2Sym   = input.symbol("CME_MINI:NQ1!", "Reference Asset 2", group=G_ENG, tooltip="Second correlated instrument. A signal can trigger from either reference (whichever fails to confirm the chart's new extreme).")
bool   useRef2   = input.bool(true, "Enable Reference 2", group=G_ENG)
int    corrLen   = input.int(20, "Correlation Length", minval=5, maxval=200, group=G_ENG, tooltip="Lookback used to report chart-vs-reference correlation state on the dashboard.")

//──────────────────────────────────────────────────────────────────────
// 02 · CONFIRMATION FILTERS
//──────────────────────────────────────────────────────────────────────
string G_FLT = "02 · Filters"
string confMode  = input.string("RSI", "Confirmation", options=["None", "RSI", "Candle", "Both"], group=G_FLT, tooltip="Extra filter on the confirming bar to reduce noise. RSI = momentum turning in the signal direction. Candle = directional close. Both = both required.")
int    rsiLen    = input.int(14, "RSI Length", minval=2, maxval=100, group=G_FLT)
bool   requireCorr = input.bool(true, "Require Positive Correlation", group=G_FLT, tooltip="Only accept SMT from a reference whose correlation to the chart is currently positive. SMT logic assumes the assets normally move together.")
float  corrMin   = input.float(0.2, "Min Correlation", minval=-1.0, maxval=1.0, step=0.05, group=G_FLT, tooltip="Minimum chart-vs-reference correlation required when the positive-correlation filter is on.")
int    cooldownBars = input.int(5, "Signal Cooldown (bars)", minval=0, maxval=200, group=G_FLT, tooltip="Minimum bars between same-direction signals.")

//──────────────────────────────────────────────────────────────────────
// 03 · TRADE MODEL (ATR SL / TP)
//──────────────────────────────────────────────────────────────────────
string G_TR = "03 · Trade Model"
bool   showSLTP  = input.bool(true, "Show ATR SL / TP", group=G_TR, tooltip="Draws ATR-anchored stop and target lines with labels on each signal.")
int    atrLen    = input.int(14, "ATR Length", minval=1, maxval=200, group=G_TR)
float  slMult    = input.float(1.5, "Stop Distance (× ATR)", minval=0.1, maxval=10.0, step=0.1, group=G_TR)
float  rrTarget  = input.float(2.0, "Risk / Reward", minval=0.25, maxval=15.0, step=0.25, group=G_TR)
int    maxSetups = input.int(12, "Max Drawn Setups", minval=1, maxval=60, group=G_TR, tooltip="Caps stored divergence lines, labels, and SL/TP objects for performance.")

//──────────────────────────────────────────────────────────────────────
// 04 · VISUALS
//──────────────────────────────────────────────────────────────────────
string G_VIS = "04 · Visuals"
bool   showDiv   = input.bool(true, "Show Divergence Lines", group=G_VIS)
bool   showSig   = input.bool(true, "Show Signal Labels", group=G_VIS)
bool   showPivots= input.bool(false, "Show Pivot Markers", group=G_VIS, tooltip="Marks confirmed chart swing highs/lows.")
string lblSizeIn = input.string("Small", "Label Size", options=["Tiny", "Small", "Normal", "Large"], group=G_VIS)
color  bullCol   = input.color(#2962FF, "Bullish SMT (Buy)", group=G_VIS, tooltip="Electric blue institutional bull.")
color  bearCol   = input.color(#7E57C2, "Bearish SMT (Sell)", group=G_VIS, tooltip="Violet institutional bear.")
bool   colorCandles = input.bool(false, "Color Candles (Zone Reader)", group=G_VIS, tooltip="Tints candles by the active setup — signal bars solid, in-profit bars toward the target hue, underwater bars red. Off by default for a clean chart.")
bool   useVwap   = input.bool(false, "Show VWAP + σ Bands", group=G_VIS, tooltip="Session VWAP with ±σ chrome bands. Off by default.")
float  vwapDev   = input.float(1.0, "VWAP Band σ", minval=0.5, maxval=4.0, step=0.5, group=G_VIS, tooltip="Standard-deviation multiplier for the VWAP bands.")

//──────────────────────────────────────────────────────────────────────
// 05 · DASHBOARD
//──────────────────────────────────────────────────────────────────────
string G_DASH = "05 · Dashboard"
bool   showDash  = input.bool(true, "Show Dashboard", group=G_DASH)
string dashPosIn = input.string("Top Right", "Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right"], group=G_DASH)
string dashSizeIn= input.string("Small", "Text Size", options=["Tiny", "Small", "Normal"], group=G_DASH)

//──────────────────────────────────────────────────────────────────────
// PALETTE (dark institutional)
//──────────────────────────────────────────────────────────────────────
color panelBg  = #0b0e17
color panelAlt = #121722
color panelBrd = #2a3a66
color txtHi    = #e8ecf5
color txtLo    = #8a93a8
color neutCol  = #6b7488
color goodCol  = #26c281
color badCol   = #ff5370
color bullSoft = color.new(#2962FF, 82)
color bearSoft = color.new(#7E57C2, 82)
color chrome   = #aab7d4

f_size(string s) =>
    switch s
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        => size.small

f_pos(string p) =>
    switch p
        "Top Left"     => position.top_left
        "Top Right"    => position.top_right
        "Bottom Left"  => position.bottom_left
        "Bottom Right" => position.bottom_right
        "Middle Right" => position.middle_right
        => position.top_right

//──────────────────────────────────────────────────────────────────────
// REFERENCE DATA (global-scope security, na-guarded)
//──────────────────────────────────────────────────────────────────────
[r1H, r1L] = request.security(ref1Sym, timeframe.period, [high, low], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
[r2H, r2L] = request.security(ref2Sym, timeframe.period, [high, low], lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
float r1C = request.security(ref1Sym, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
float r2C = request.security(ref2Sym, timeframe.period, close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)

bool r1Valid = useRef1 and not na(r1C)
bool r2Valid = useRef2 and not na(r2C)

// ta.* must run every bar (never gated) for correct state; guard display via r1Valid/r2Valid
float corr1raw = ta.correlation(close, r1C, corrLen)
float corr2raw = ta.correlation(close, r2C, corrLen)
float corr1 = r1Valid ? corr1raw : na
float corr2 = r2Valid ? corr2raw : na

//──────────────────────────────────────────────────────────────────────
// CORE SERIES (evaluated every bar)
//──────────────────────────────────────────────────────────────────────
float atr    = ta.atr(atrLen)
float rsiVal = ta.rsi(close, rsiLen)
float ph = ta.pivothigh(high, pivotLen, pivotLen)
float pl = ta.pivotlow(low, pivotLen, pivotLen)
bool newPH = not na(ph)
bool newPL = not na(pl)

// VWAP + σ bands (computed every bar; displayed via toggle)
float vwapV = ta.vwap(hlc3)
float vwSd  = ta.stdev(close, 100)
float vwUp1 = vwapV + vwapDev * vwSd
float vwLo1 = vwapV - vwapDev * vwSd

// confirmation gates (evaluated on the confirming bar)
bool rsiUp   = not na(rsiVal) and not na(rsiVal[1]) and rsiVal > rsiVal[1]
bool rsiDn   = not na(rsiVal) and not na(rsiVal[1]) and rsiVal < rsiVal[1]
bool confBull = switch confMode
    "None"   => true
    "RSI"    => rsiUp
    "Candle" => close > open
    => rsiUp and close > open
bool confBear = switch confMode
    "None"   => true
    "RSI"    => rsiDn
    "Candle" => close < open
    => rsiDn and close < open

bool corr1Ok = not requireCorr or (not na(corr1) and corr1 >= corrMin)
bool corr2Ok = not requireCorr or (not na(corr2) and corr2 >= corrMin)

//──────────────────────────────────────────────────────────────────────
// SWING STATE
//──────────────────────────────────────────────────────────────────────
var float cPrevPH = na
var int   cPrevPHbar = na
var float cPrevPL = na
var int   cPrevPLbar = na
var float r1PrevPH = na
var float r1PrevPL = na
var float r2PrevPH = na
var float r2PrevPL = na
var string lastStruct = "—"

//──────────────────────────────────────────────────────────────────────
// SMT DETECTION
// Bullish: chart lower low while a correlated ref makes a higher low.
// Bearish: chart higher high while a correlated ref makes a lower high.
//──────────────────────────────────────────────────────────────────────
bool bull1 = false
bool bull2 = false
bool bear1 = false
bool bear2 = false

float sigCPrev = na
int   sigCPrevBar = na
float sigCCur = na
int   sigCCurBar = na

if newPL
    float cPL = pl
    int   cPLbar = bar_index - pivotLen
    float r1PL = r1Valid ? r1L[pivotLen] : na
    float r2PL = r2Valid ? r2L[pivotLen] : na
    // structure
    lastStruct := na(cPrevPL) ? lastStruct : (cPL > cPrevPL ? "HL" : "LL")
    if not na(cPrevPL)
        bool chartLL = cPL < cPrevPL
        bull1 := chartLL and r1Valid and not na(r1PL) and not na(r1PrevPL) and r1PL > r1PrevPL and corr1Ok
        bull2 := chartLL and r2Valid and not na(r2PL) and not na(r2PrevPL) and r2PL > r2PrevPL and corr2Ok
        if bull1 or bull2
            sigCPrev := cPrevPL
            sigCPrevBar := cPrevPLbar
            sigCCur := cPL
            sigCCurBar := cPLbar
    // advance state
    cPrevPL := cPL
    cPrevPLbar := cPLbar
    r1PrevPL := r1PL
    r2PrevPL := r2PL

if newPH
    float cPH = ph
    int   cPHbar = bar_index - pivotLen
    float r1PH = r1Valid ? r1H[pivotLen] : na
    float r2PH = r2Valid ? r2H[pivotLen] : na
    lastStruct := na(cPrevPH) ? lastStruct : (cPH > cPrevPH ? "HH" : "LH")
    if not na(cPrevPH)
        bool chartHH = cPH > cPrevPH
        bear1 := chartHH and r1Valid and not na(r1PH) and not na(r1PrevPH) and r1PH < r1PrevPH and corr1Ok
        bear2 := chartHH and r2Valid and not na(r2PH) and not na(r2PrevPH) and r2PH < r2PrevPH and corr2Ok
        if bear1 or bear2
            sigCPrev := cPrevPH
            sigCPrevBar := cPrevPHbar
            sigCCur := cPH
            sigCCurBar := cPHbar
    cPrevPH := cPH
    cPrevPHbar := cPHbar
    r1PrevPH := r1PH
    r2PrevPH := r2PH

bool rawBull = (bull1 or bull2) and confBull
bool rawBear = (bear1 or bear2) and confBear

//──────────────────────────────────────────────────────────────────────
// COOLDOWN + FINAL SIGNALS
//──────────────────────────────────────────────────────────────────────
var int lastBullBar = na
var int lastBearBar = na
bool bullOk = rawBull and (na(lastBullBar) or bar_index - lastBullBar >= cooldownBars)
bool bearOk = rawBear and (na(lastBearBar) or bar_index - lastBearBar >= cooldownBars)
// never fire both on one bar
bool bullSig = bullOk and not bearOk
bool bearSig = bearOk and not bullOk

//──────────────────────────────────────────────────────────────────────
// STATS / DASHBOARD STATE
//──────────────────────────────────────────────────────────────────────
var int   bullCount = 0
var int   bearCount = 0
var string lastSMT  = "—"
var string lastRef  = "—"

trigRef(bool a1, bool a2) => a1 and a2 ? "REF1+REF2" : a1 ? "REF1" : a2 ? "REF2" : "—"

if bullSig
    bullCount += 1
    lastSMT := "BULLISH"
    lastRef := trigRef(bull1, bull2)
    lastBullBar := bar_index
if bearSig
    bearCount += 1
    lastSMT := "BEARISH"
    lastRef := trigRef(bear1, bear2)
    lastBearBar := bar_index

//──────────────────────────────────────────────────────────────────────
// DRAW OBJECTS (divergence line, label, SL/TP zones) — capped + live-extend-then-freeze
//──────────────────────────────────────────────────────────────────────
type SMTViz
    line  divl
    label sigl
    line  entl
    line  sll
    line  tpl
    label sllb
    label tplb
    box   tpbx
    box   slbx

var array<SMTViz> vizHist = array.new<SMTViz>()

int projBars = 20
// live-extend-then-freeze state for the most recent setup
var SMTViz actViz   = na
var bool   actLive  = false
var int    actSide  = 0
var int    actBar   = na
var float  actEntry = na
var float  actStop  = na
var float  actTgt   = na

// live-extend the active zone each bar; freeze (pin right edge) on TP/SL touch
if actLive and not na(actViz)
    bool tpTouch  = actSide == 1 ? high >= actTgt : low <= actTgt
    bool slTouch  = actSide == 1 ? low <= actStop : high >= actStop
    bool freeze   = tpTouch or slTouch
    int  rightNow = freeze ? bar_index : math.min(bar_index + projBars, actBar + 500)
    if not na(actViz.tpbx)
        box.set_right(actViz.tpbx, rightNow)
    if not na(actViz.slbx)
        box.set_right(actViz.slbx, rightNow)
    if not na(actViz.entl)
        line.set_x2(actViz.entl, rightNow)
    if not na(actViz.sll)
        line.set_x2(actViz.sll, rightNow)
    if not na(actViz.tpl)
        line.set_x2(actViz.tpl, rightNow)
    if not na(actViz.sllb)
        label.set_x(actViz.sllb, rightNow)
    if not na(actViz.tplb)
        label.set_x(actViz.tplb, rightNow)
    if freeze
        actLive := false

if (bullSig or bearSig) and not na(atr)
    bool isBull = bullSig
    color c = isBull ? bullCol : bearCol
    line divl0 = na
    label sigl0 = na
    line entl0 = na
    line sll0 = na
    line tpl0 = na
    label sllb0 = na
    label tplb0 = na
    box tpbx0 = na
    box slbx0 = na

    // divergence line connecting the two chart pivots
    if showDiv and not na(sigCPrevBar) and not na(sigCCurBar)
        divl0 := line.new(sigCPrevBar, sigCPrev, sigCCurBar, sigCCur, xloc=xloc.bar_index, color=color.new(c, 15), width=2, style=line.style_solid)

    // signal label (clean pill — never a triangle/arrow)
    if showSig
        string head = isBull ? "SMT BUY" : "SMT SELL"
        string ref  = isBull ? trigRef(bull1, bull2) : trigRef(bear1, bear2)
        string txt  = head + "\n" + ref
        // ATR-offset the label off the bar so it never overlaps the divergence line or candle
        float lblY  = isBull ? low - atr * 0.35 : high + atr * 0.35
        sigl0 := label.new(bar_index, lblY, txt, xloc=xloc.bar_index, style=isBull ? label.style_label_up : label.style_label_down, color=color.new(c, 0), textcolor=color.white, size=f_size(lblSizeIn), text_formatting=text.format_bold)

    // arm live-extend only when zones are drawn
    actLive := false

    // ATR SL / TP zone boxes — red risk zone, blue/violet reward zone
    if showSLTP
        float entry = close
        float risk  = atr * slMult
        float stop  = isBull ? entry - risk : entry + risk
        float tgt   = isBull ? entry + risk * rrTarget : entry - risk * rrTarget
        int   xr    = bar_index + projBars
        color zoneFill = isBull ? bullSoft : bearSoft
        tpbx0 := box.new(bar_index, math.max(entry, tgt),  xr, math.min(entry, tgt),  xloc=xloc.bar_index, bgcolor=zoneFill, border_color=color.new(c, 55), border_width=1)
        slbx0 := box.new(bar_index, math.max(entry, stop), xr, math.min(entry, stop), xloc=xloc.bar_index, bgcolor=color.new(badCol, 85), border_color=color.new(badCol, 50), border_width=1)
        entl0 := line.new(bar_index, entry, xr, entry, xloc=xloc.bar_index, color=color.new(txtHi, 10), width=1, style=line.style_solid)
        sll0  := line.new(bar_index, stop, xr, stop, xloc=xloc.bar_index, color=color.new(badCol, 10), width=1, style=line.style_dashed)
        tpl0  := line.new(bar_index, tgt, xr, tgt, xloc=xloc.bar_index, color=color.new(c, 10), width=1, style=line.style_dashed)
        sllb0 := label.new(xr, stop, "SL @ " + str.tostring(stop, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(badCol, 15), textcolor=color.white, size=f_size(lblSizeIn))
        tplb0 := label.new(xr, tgt, "TP " + str.tostring(rrTarget, "#.#") + "R @ " + str.tostring(tgt, format.mintick), xloc=xloc.bar_index, style=label.style_label_left, color=color.new(c, 15), textcolor=color.white, size=f_size(lblSizeIn))
        actSide  := isBull ? 1 : -1
        actBar   := bar_index
        actEntry := entry
        actStop  := stop
        actTgt   := tgt

    SMTViz v = SMTViz.new(divl0, sigl0, entl0, sll0, tpl0, sllb0, tplb0, tpbx0, slbx0)
    array.push(vizHist, v)
    while array.size(vizHist) > maxSetups
        SMTViz old = array.shift(vizHist)
        if not na(old.divl)
            line.delete(old.divl)
        if not na(old.sigl)
            label.delete(old.sigl)
        if not na(old.entl)
            line.delete(old.entl)
        if not na(old.sll)
            line.delete(old.sll)
        if not na(old.tpl)
            line.delete(old.tpl)
        if not na(old.sllb)
            label.delete(old.sllb)
        if not na(old.tplb)
            label.delete(old.tplb)
        if not na(old.tpbx)
            box.delete(old.tpbx)
        if not na(old.slbx)
            box.delete(old.slbx)
    // newest setup becomes the live-extending one
    if showSLTP
        actViz  := v
        actLive := true

//──────────────────────────────────────────────────────────────────────
// PLOTS (global scope, boolean-gated)
//──────────────────────────────────────────────────────────────────────
plotshape(showPivots and newPH, title="Swing High", style=shape.triangledown, location=location.abovebar, color=color.new(bearCol, 40), size=size.tiny)
plotshape(showPivots and newPL, title="Swing Low", style=shape.triangleup, location=location.belowbar, color=color.new(bullCol, 40), size=size.tiny)

// VWAP + σ bands (chrome) — toggle, default off (idiom #4)
plot(useVwap ? vwapV : na, "VWAP", color=color.new(chrome, 0), linewidth=2)
pU1 = plot(useVwap ? vwUp1 : na, "VWAP +σ", color=color.new(chrome, 70))
pL1 = plot(useVwap ? vwLo1 : na, "VWAP -σ", color=color.new(chrome, 70))
fill(pU1, pL1, color=useVwap ? color.new(chrome, 92) : na, title="VWAP σ Band")

// colored candles (zone reader) — toggle, default off (idiom #3)
color barCol = na
if colorCandles
    if bullSig or bearSig
        barCol := color.new(bullSig ? bullCol : bearCol, 0)
    else if actLive
        bool inProfit = actSide == 1 ? close >= actEntry : close <= actEntry
        barCol := inProfit ? color.new(actSide == 1 ? bullCol : bearCol, 55) : color.new(badCol, 70)
barcolor(barCol, title="Zone Reader Candles")

//──────────────────────────────────────────────────────────────────────
// DASHBOARD
//──────────────────────────────────────────────────────────────────────
f_corrTxt(float cv) => na(cv) ? "N/A" : str.tostring(cv, "#.##")
f_corrState(float cv) => na(cv) ? "—" : cv >= 0.5 ? "STRONG +" : cv >= corrMin ? "POSITIVE" : cv <= -0.5 ? "STRONG −" : cv < 0 ? "NEGATIVE" : "WEAK"
f_corrCol(float cv) => na(cv) ? neutCol : cv >= corrMin ? goodCol : cv < 0 ? badCol : neutCol

var table dash = table.new(f_pos(dashPosIn), 2, 9, frame_color=color.new(panelBrd, 0), frame_width=1, border_width=1, border_color=color.new(panelBrd, 40))

if barstate.islast and showDash
    string ts = f_size(dashSizeIn)
    string status = bullSig ? "BULLISH SMT" : bearSig ? "BEARISH SMT" : "SCANNING"
    color statusC = bullSig ? bullCol : bearSig ? bearCol : neutCol
    color structC = lastStruct == "HH" or lastStruct == "HL" ? goodCol : lastStruct == "LH" or lastStruct == "LL" ? badCol : neutCol
    color smtC = lastSMT == "BULLISH" ? bullCol : lastSMT == "BEARISH" ? bearCol : neutCol

    table.cell(dash, 0, 0, "SMT MATRIX", text_color=color.white, text_size=ts, text_halign=text.align_left, bgcolor=bullCol)
    table.cell_set_text_formatting(dash, 0, 0, text.format_bold + text.format_italic)
    table.cell(dash, 1, 0, "[JOAT]", text_color=color.white, text_size=ts, text_halign=text.align_right, bgcolor=bearCol)
    table.cell_set_text_formatting(dash, 1, 0, text.format_bold + text.format_italic)

    table.cell(dash, 0, 1, "Corr R1", text_color=txtLo, text_size=ts, text_halign=text.align_left, bgcolor=panelBg)
    table.cell(dash, 1, 1, r1Valid ? f_corrState(corr1) + " " + f_corrTxt(corr1) : "OFF", text_color=r1Valid ? f_corrCol(corr1) : neutCol, text_size=ts, text_halign=text.align_right, bgcolor=panelBg)

    table.cell(dash, 0, 2, "Corr R2", text_color=txtLo, text_size=ts, text_halign=text.align_left, bgcolor=panelAlt)
    table.cell(dash, 1, 2, r2Valid ? f_corrState(corr2) + " " + f_corrTxt(corr2) : "OFF", text_color=r2Valid ? f_corrCol(corr2) : neutCol, text_size=ts, text_halign=text.align_right, bgcolor=panelAlt)

    table.cell(dash, 0, 3, "Last SMT", text_color=txtLo, text_size=ts, text_halign=text.align_left, bgcolor=panelBg)
    table.cell(dash, 1, 3, lastSMT + " · " + lastRef, text_color=smtC, text_size=ts, text_halign=text.align_right, bgcolor=panelBg)

    table.cell(dash, 0, 4, "Structure", text_color=txtLo, text_size=ts, text_halign=text.align_left, bgcolor=panelAlt)
    table.cell(dash, 1, 4, lastStruct, text_color=structC, text_size=ts, text_halign=text.align_right, bgcolor=panelAlt)

    table.cell(dash, 0, 5, "Bull / Bear", text_color=txtLo, text_size=ts, text_halign=text.align_left, bgcolor=panelBg)
    table.cell(dash, 1, 5, str.tostring(bullCount) + " / " + str.tostring(bearCount), text_color=txtHi, text_size=ts, text_halign=text.align_right, bgcolor=panelBg)

    table.cell(dash, 0, 6, "Divergences", text_color=txtLo, text_size=ts, text_halign=text.align_left, bgcolor=panelAlt)
    table.cell(dash, 1, 6, str.tostring(bullCount + bearCount), text_color=txtHi, text_size=ts, text_halign=text.align_right, bgcolor=panelAlt)

    table.cell(dash, 0, 7, "Signal", text_color=txtLo, text_size=ts, text_halign=text.align_left, bgcolor=panelBg)
    table.cell(dash, 1, 7, status, text_color=statusC, text_size=ts, text_halign=text.align_right, bgcolor=color.new(statusC, 88))

    table.cell(dash, 0, 8, "ATR", text_color=txtLo, text_size=ts, text_halign=text.align_left, bgcolor=panelAlt)
    table.cell(dash, 1, 8, na(atr) ? "—" : str.tostring(atr, format.mintick), text_color=txtHi, text_size=ts, text_halign=text.align_right, bgcolor=panelAlt)

//──────────────────────────────────────────────────────────────────────
// ALERTS
//──────────────────────────────────────────────────────────────────────
alertcondition(bullSig, "Bullish SMT", "SMT Divergence Matrix [JOAT]: BULLISH SMT — chart lower low vs correlated higher low on {{ticker}} {{interval}}.")
alertcondition(bearSig, "Bearish SMT", "SMT Divergence Matrix [JOAT]: BEARISH SMT — chart higher high vs correlated lower high on {{ticker}} {{interval}}.")
````
