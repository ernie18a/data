# OR: NIFTY Regime Signal Engine v1.1

- url: https://www.tradingview.com/script/TteAHqWp-OR-NIFTY-Regime-Signal-Engine-v1-1/
- type: indicator
- pine_id: PUB;f00d09a8c7db4f4dacc9243489ecfa85
- version: 4.0

## Description

Institutional-grade NIFTY regime engine that converts market conditions into **clear trade direction, position sizing, and strike placement**. Combines ATR-normalized trend, realized volatility shifts, and India VIX to classify regimes and suggest optimal option structures (spreads/condors). Includes dynamic lot sizing, risk calculation, and dashboards. Built for systematic option sellers focused on **discipline, drawdown control, and consistency**.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © OpenRoad Capital
//
// V3-B (UI v2) — May 2026 System Review Updates
//
// UX changes from previous V3-B UI:
//   - Single dashboard preserved (no overlapping tables)
//   - Headlines (Regime, Final Lots) show LIVE only — that's what you act on
//   - Sub-rows show both LAST CLOSED | LIVE side-by-side for comparison
//   - When CLOSED and LIVE agree → LIVE column is muted (visual "no change")
//   - When CLOSED and LIVE disagree → LIVE column pops with color (forming change)
//   - Change indicator (●) appears when LIVE differs from CLOSED on key fields
//   - Hides Active Trade section when no trade is active
//   - Strike levels shown on chart labels, not duplicated in table

//@version=6
indicator("NIFTY Regime Engine V3-B", shorttitle="RegimeV3B", overlay=true, max_labels_count=20)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

i_emaLen        = input.int(20, "EMA Length", minval=5, maxval=100, group="Directional Bias")
i_atrLen        = input.int(14, "ATR Length", minval=5, maxval=50, group="Directional Bias")
i_biasBull      = input.float(0.75, "Bias Bull ENTRY", minval=0.1, step=0.05, group="Directional Bias")
i_biasBear      = input.float(-0.75, "Bias Bear ENTRY", maxval=-0.1, step=0.05, group="Directional Bias")
i_biasBullExit  = input.float(0.25, "Bias Bull EXIT", minval=0.0, step=0.05, group="Directional Bias")
i_biasBearExit  = input.float(-0.25, "Bias Bear EXIT", maxval=0.0, step=0.05, group="Directional Bias")

i_rvShort       = input.int(5, "RV Short Length", minval=3, maxval=20, group="Realized Volatility")
i_rvLong        = input.int(20, "RV Long Length", minval=10, maxval=60, group="Realized Volatility")
i_rvExpand      = input.float(1.2, "RV Expanding Threshold", minval=1.0, step=0.05, group="Realized Volatility")
i_rvCompress    = input.float(0.8, "RV Compressing Threshold", minval=0.1, maxval=1.0, step=0.05, group="Realized Volatility")

i_vixSymbol     = input.symbol("NSE:INDIAVIX", "India VIX Symbol", group="VIX Sizing")

i_wingWidth     = input.int(200, "Wing Width (points)", minval=50, maxval=1000, step=50, group="Strike Placement")
i_strikeRound   = input.int(50, "Round Strikes To (points)", minval=25, maxval=100, step=25, group="Strike Placement")
i_lotSize       = input.int(65, "NIFTY Lot Size", minval=1, group="Strike Placement")

i_drawdownBand  = input.string("0-3%", "Drawdown Band", options=["0-3%", "3-6%", "6-10%", ">10%"], group="Risk Management", tooltip="Update weekly during Friday regime evaluation")
i_volFilterOn   = input.bool(true, "Vol Regime Filter (×0.8 when bias trending + RV expanding)", group="Risk Management")

i_entrySpot     = input.float(0.0, "Entry Spot (0 = no active trade)", minval=0, step=1, group="Active Trade")
i_entryPEShort  = input.float(0.0, "PE Short Strike", minval=0, step=50, group="Active Trade")
i_entryCEShort  = input.float(0.0, "CE Short Strike", minval=0, step=50, group="Active Trade")

i_showBg        = input.bool(true, "Show Background Color", group="Display")
i_showTable     = input.bool(true, "Show Dashboard", group="Display")
i_showStrikeLabels = input.bool(true, "Show Strike Labels on Chart", group="Display")
i_showStops     = input.bool(true, "Show Stop Levels on Chart", group="Display")
i_tablePos      = input.string("Top Right", "Dashboard Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left", "Middle Right", "Middle Left"], group="Display")

// ─────────────────────────────────────────────────────────────────────────────
// HELPERS
// ─────────────────────────────────────────────────────────────────────────────

f_tablePos(pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        "Middle Right"  => position.middle_right
        "Middle Left"   => position.middle_left
        => position.top_right

f_roundDown(val, step) => math.floor(val / step) * step
f_roundUp(val, step)   => math.ceil(val / step) * step

// Color used for unchanged LIVE values (must be module-scoped for f_liveColor)
// At 60% transparency: visibly muted vs CLOSED column but still readable
var color C_TXT_GHOST = color.new(color.white, 60)

// Returns the LIVE-column text color: dim if unchanged, bright (baseColor) if changed
f_liveColor(changed, baseColor) =>
    changed ? baseColor : C_TXT_GHOST

// Builds the strike display string for any structure/leg combination
// Format: "PE 23050" for put spread, "CE 24950" for call spread,
//         "PE 23050 · CE 24950" for iron condor variants
f_strikeStr(structure, putShort, putLong, callShort, callLong) =>
    string s = "—"
    if structure == "PUT SPREAD"
        s := "PE " + str.tostring(putShort, "#")
    else if structure == "CALL SPREAD"
        s := "CE " + str.tostring(callShort, "#")
    else if structure != "NO TRADE"
        s := "PE " + str.tostring(putShort, "#") + " · CE " + str.tostring(callShort, "#")
    s

// ─────────────────────────────────────────────────────────────────────────────
// A) VIX-BASED SIZING
// ─────────────────────────────────────────────────────────────────────────────

vixCloseLast = request.security(i_vixSymbol, "D", close[1], barmerge.gaps_off, barmerge.lookahead_on)
vixCloseLive = request.security(i_vixSymbol, "D", close,    barmerge.gaps_off, barmerge.lookahead_on)

f_vixZone(v) =>
    int    lots = 0
    int    pct  = 0
    string zone = ""
    if not na(v)
        if v >= 35
            lots := 0
            pct  := 0
            zone := "EXTREME"
        else if v >= 25
            lots := 2
            pct  := 40
            zone := "HIGH"
        else if v >= 20
            lots := 4
            pct  := 80
            zone := "ELEVATED"
        else
            lots := 5
            pct  := 100
            zone := "NORMAL"
    [lots, pct, zone]

[baseLotsLast, pctLast, zoneLast] = f_vixZone(vixCloseLast)
[baseLotsLive, pctLive, zoneLive] = f_vixZone(vixCloseLive)

// ─────────────────────────────────────────────────────────────────────────────
// B) BIAS
// ─────────────────────────────────────────────────────────────────────────────

ema20 = ta.ema(close, i_emaLen)
atr14 = ta.atr(i_atrLen)

biasLive = atr14    > 0 ? (close    - ema20)    / atr14    : 0.0
biasLast = atr14[1] > 0 ? (close[1] - ema20[1]) / atr14[1] : 0.0

var string biasStateLive = "NEUTRAL"
if biasStateLive == "NEUTRAL"
    if biasLive > i_biasBull
        biasStateLive := "BULL"
    else if biasLive < i_biasBear
        biasStateLive := "BEAR"
else if biasStateLive == "BULL"
    if biasLive < i_biasBullExit
        biasStateLive := "NEUTRAL"
else if biasStateLive == "BEAR"
    if biasLive > i_biasBearExit
        biasStateLive := "NEUTRAL"

biasStateLast = biasStateLive[1]

// ─────────────────────────────────────────────────────────────────────────────
// C) RV
// ─────────────────────────────────────────────────────────────────────────────

logReturn = math.log(close / close[1])
rv5  = ta.stdev(logReturn, i_rvShort) * math.sqrt(252)
rv20 = ta.stdev(logReturn, i_rvLong)  * math.sqrt(252)

rvRatioLive = rv20    > 0 ? rv5    / rv20    : na
rvRatioLast = rv20[1] > 0 ? rv5[1] / rv20[1] : na

f_rvState(r) =>
    string s = "NORMAL"
    if not na(r)
        if r > i_rvExpand
            s := "EXPANDING"
        else if r < i_rvCompress
            s := "COMPRESS"
    s

rvStateLive = f_rvState(rvRatioLive)
rvStateLast = f_rvState(rvRatioLast)

// ─────────────────────────────────────────────────────────────────────────────
// D) REGIME
// ─────────────────────────────────────────────────────────────────────────────

f_regime(lots, biasState, rvState) =>
    string r = "RANGE"
    color  c = color.yellow
    if lots == 0
        r := "NO TRADE"
        c := color.gray
    else if biasState == "BULL" and (rvState == "NORMAL" or rvState == "EXPANDING")
        r := "BULLISH"
        c := color.green
    else if biasState == "BULL" and rvState == "COMPRESS"
        r := "BULL FADING"
        c := color.new(color.green, 50)
    else if biasState == "BEAR" and (rvState == "NORMAL" or rvState == "EXPANDING")
        r := "BEARISH"
        c := color.red
    else if biasState == "BEAR" and rvState == "COMPRESS"
        r := "BEAR FADING"
        c := color.new(color.red, 50)
    else if biasState == "NEUTRAL" and rvState == "NORMAL"
        r := "RANGE"
        c := color.yellow
    else if biasState == "NEUTRAL" and rvState == "COMPRESS"
        r := "BREAKOUT RISK"
        c := color.orange
    else if biasState == "NEUTRAL" and rvState == "EXPANDING"
        r := "UNSTABLE"
        c := color.new(color.gray, 30)
    [r, c]

[regimeLive, regimeColLive] = f_regime(baseLotsLive, biasStateLive, rvStateLive)
[regimeLast, regimeColLast] = f_regime(baseLotsLast, biasStateLast, rvStateLast)

// ─────────────────────────────────────────────────────────────────────────────
// E) RISK OVERLAYS
// ─────────────────────────────────────────────────────────────────────────────

f_volMult(biasState, rvState) =>
    float m = 1.0
    if i_volFilterOn and (biasState == "BULL" or biasState == "BEAR") and rvState == "EXPANDING"
        m := 0.8
    m

f_ddMult(band) =>
    float m = 1.0
    if band == "0-3%"
        m := 1.0
    else if band == "3-6%"
        m := 0.5
    else if band == "6-10%"
        m := 0.25
    else
        m := 0.0
    m

volMultLive = f_volMult(biasStateLive, rvStateLive)
volMultLast = f_volMult(biasStateLast, rvStateLast)
ddMult      = f_ddMult(i_drawdownBand)

finalLotsLive = math.max(0, math.floor(baseLotsLive * volMultLive * ddMult))
finalLotsLast = math.max(0, math.floor(baseLotsLast * volMultLast * ddMult))

// ─────────────────────────────────────────────────────────────────────────────
// F) STRIKES
// ─────────────────────────────────────────────────────────────────────────────

f_strikes(regime) =>
    float pm = 1.75
    float cm = 1.75
    string s = "-"
    if regime == "BULLISH"
        pm := 1.25
        cm := 2.5
        s  := "PUT SPREAD"
    else if regime == "BULL FADING"
        pm := 1.75
        cm := 1.75
        s  := "IRON CONDOR"
    else if regime == "BEARISH"
        pm := 2.5
        cm := 1.25
        s  := "CALL SPREAD"
    else if regime == "BEAR FADING"
        pm := 1.75
        cm := 1.75
        s  := "IRON CONDOR"
    else if regime == "RANGE"
        pm := 1.75
        cm := 1.75
        s  := "IRON CONDOR"
    else if regime == "BREAKOUT RISK"
        pm := 2.5
        cm := 2.5
        s  := "CONDOR (WIDE)"
    else
        pm := 0.0
        cm := 0.0
        s  := "NO TRADE"
    [pm, cm, s]

[putMultLive, callMultLive, structureLive] = f_strikes(regimeLive)
[putMultLast, callMultLast, structureLast] = f_strikes(regimeLast)

atrValLive = nz(atr14, 0)
putShortLive  = f_roundDown(close - atrValLive * putMultLive,  i_strikeRound)
callShortLive = f_roundUp(  close + atrValLive * callMultLive, i_strikeRound)
putLongLive   = putShortLive  - i_wingWidth
callLongLive  = callShortLive + i_wingWidth

atrValLast = nz(atr14[1], 0)
putShortLast  = f_roundDown(close[1] - atrValLast * putMultLast,  i_strikeRound)
callShortLast = f_roundUp(  close[1] + atrValLast * callMultLast, i_strikeRound)
putLongLast   = putShortLast  - i_wingWidth
callLongLast  = callShortLast + i_wingWidth

maxLossPerLot = i_wingWidth * i_lotSize

// ─────────────────────────────────────────────────────────────────────────────
// G) ACTIVE TRADE STOPS
// ─────────────────────────────────────────────────────────────────────────────

hasActiveTrade = i_entrySpot > 0
hasActivePE    = hasActiveTrade and i_entryPEShort > 0
hasActiveCE    = hasActiveTrade and i_entryCEShort > 0

peStopLevel = hasActivePE ? i_entrySpot - 0.75 * (i_entrySpot - i_entryPEShort) : na
ceStopLevel = hasActiveCE ? i_entrySpot + 0.75 * (i_entryCEShort - i_entrySpot) : na

// ─────────────────────────────────────────────────────────────────────────────
// H) BACKGROUND
// ─────────────────────────────────────────────────────────────────────────────

bgcolor(i_showBg ? color.new(regimeColLive, 92) : na)

// ─────────────────────────────────────────────────────────────────────────────
// CHANGE DETECTION (LIVE differs from CLOSED)
// ─────────────────────────────────────────────────────────────────────────────

regimeChanged = regimeLive != regimeLast
biasChanged   = biasStateLive != biasStateLast
rvChanged     = rvStateLive != rvStateLast
vixZoneChanged = zoneLive != zoneLast
finalLotsChanged = finalLotsLive != finalLotsLast
structureChanged = structureLive != structureLast

// Any change → headline indicator
anyChange = regimeChanged or biasChanged or rvChanged or vixZoneChanged or finalLotsChanged

// ─────────────────────────────────────────────────────────────────────────────
// TIMESTAMP
// ─────────────────────────────────────────────────────────────────────────────

f_fmtTime(t) =>
    str.format_time(t, "dd-MMM HH:mm", "Asia/Kolkata")

// ─────────────────────────────────────────────────────────────────────────────
// I) UNIFIED DASHBOARD — 3-column (Label | Closed | Live)
// ─────────────────────────────────────────────────────────────────────────────

if i_showTable and barstate.islast
    var table d = table.new(f_tablePos(i_tablePos), 3, 22, border_width=1, frame_color=color.new(#0a0e27, 0), frame_width=2)

    // Color palette
    bgDark    = color.new(#0a0e27, 0)
    bgMid     = color.new(#1a1f3a, 0)
    bgAccent  = color.new(#0f3460, 0)
    bgHeader  = color.new(#16213e, 0)

    txtPrime  = color.white
    txtMuted  = color.new(color.white, 50)
    txtDim    = color.new(color.white, 70)

    cGood     = color.new(#10b981, 0)
    cWarn     = color.new(#f59e0b, 0)
    cDanger   = color.new(#ef4444, 0)
    cInfo     = color.new(#06b6d4, 0)
    cNeutral  = color.new(#94a3b8, 0)
    cChange   = color.new(#fbbf24, 0)  // bright yellow for "changed" highlight

    // VIX colors
    vixColLast = zoneLast == "EXTREME" ? cDanger : zoneLast == "HIGH" ? cWarn : zoneLast == "ELEVATED" ? color.yellow : cGood
    vixColLive = zoneLive == "EXTREME" ? cDanger : zoneLive == "HIGH" ? cWarn : zoneLive == "ELEVATED" ? color.yellow : cGood

    // Bias colors
    biasColLast = biasStateLast == "BULL" ? cGood : biasStateLast == "BEAR" ? cDanger : color.yellow
    biasColLive = biasStateLive == "BULL" ? cGood : biasStateLive == "BEAR" ? cDanger : color.yellow

    // RV colors
    rvColLast = rvStateLast == "EXPANDING" ? cDanger : rvStateLast == "COMPRESS" ? cInfo : cNeutral
    rvColLive = rvStateLive == "EXPANDING" ? cDanger : rvStateLive == "COMPRESS" ? cInfo : cNeutral

    // ═══ ROW 0: Title ═══
    titleStr = "REGIME ENGINE V3-B  ·  " + timeframe.period + (anyChange ? "   ⚡ FORMING" : "   ✓ SETTLED")
    titleColor = anyChange ? cChange : color.new(cGood, 30)
    table.cell(d, 0, 0, titleStr, bgcolor=bgDark, text_color=titleColor, text_size=size.normal, text_halign=text.align_left)
    table.merge_cells(d, 0, 0, 2, 0)

    // ═══ ROW 1: HEADLINE — Regime ═══
    // Show LIVE big, with CLOSED reference if changed
    headlineRegime = regimeLive
    if regimeChanged
        headlineRegime := regimeLast + "  →  " + regimeLive
    table.cell(d, 0, 1, headlineRegime, bgcolor=color.new(regimeColLive, 60), text_color=txtPrime, text_size=size.large, text_halign=text.align_center)
    table.merge_cells(d, 0, 1, 2, 1)

    // ═══ ROW 2: HEADLINE — Final Lots ═══
    finalLotsCol = finalLotsLive == 0 ? cDanger : finalLotsLive < baseLotsLive ? cWarn : cGood
    lotsHeadline = str.tostring(finalLotsLive) + " LOTS"
    if finalLotsChanged
        lotsHeadline := str.tostring(finalLotsLast) + "  →  " + str.tostring(finalLotsLive) + " LOTS"
    else if finalLotsLive < baseLotsLive and finalLotsLive > 0
        lotsHeadline := lotsHeadline + "  ↓ from " + str.tostring(baseLotsLive)
    if finalLotsLive == 0 and baseLotsLive > 0
        lotsHeadline := "0 LOTS  ·  HALTED"
    table.cell(d, 0, 2, lotsHeadline, bgcolor=bgMid, text_color=finalLotsCol, text_size=size.large, text_halign=text.align_center)
    table.merge_cells(d, 0, 2, 2, 2)

    // ═══ ROW 3: Column headers (CLOSED | LIVE) ═══
    formingTag = barstate.isrealtime ? " ●" : ""
    table.cell(d, 0, 3, "", bgcolor=bgAccent, text_color=txtMuted, text_size=size.tiny)
    table.cell(d, 1, 3, "CLOSED", bgcolor=bgAccent, text_color=txtMuted, text_size=size.tiny, text_halign=text.align_center)
    table.cell(d, 2, 3, "LIVE" + formingTag, bgcolor=bgAccent, text_color=txtMuted, text_size=size.tiny, text_halign=text.align_center)

    // ═══ ROW 4: Section header — SIZING ═══
    table.cell(d, 0, 4, "SIZING", bgcolor=bgHeader, text_color=txtMuted, text_size=size.tiny, text_halign=text.align_left)
    table.merge_cells(d, 0, 4, 2, 4)

    // ═══ ROW 5: VIX ═══
    vixLastVal = not na(vixCloseLast) ? str.tostring(vixCloseLast, "#.##") : "—"
    vixLiveVal = not na(vixCloseLive) ? str.tostring(vixCloseLive, "#.##") : "—"
    vixLastDisplay = vixLastVal + " " + zoneLast
    vixLiveDisplay = vixLiveVal + " " + zoneLive + (vixZoneChanged ? " ●" : "")
    table.cell(d, 0, 5, "India VIX", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 5, vixLastDisplay, bgcolor=bgMid, text_color=vixColLast, text_size=size.small, text_halign=text.align_center)
    table.cell(d, 2, 5, vixLiveDisplay, bgcolor=bgMid, text_color=f_liveColor(vixZoneChanged, vixColLive), text_size=size.small, text_halign=text.align_center)

    // ═══ ROW 6: Base Lots ═══
    baseLotsLastStr = str.tostring(baseLotsLast)
    baseLotsLiveStr = str.tostring(baseLotsLive)
    baseLotsChanged = baseLotsLast != baseLotsLive
    table.cell(d, 0, 6, "Base Lots", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 6, baseLotsLastStr, bgcolor=bgMid, text_color=vixColLast, text_size=size.small, text_halign=text.align_center)
    table.cell(d, 2, 6, baseLotsLiveStr + (baseLotsChanged ? " ●" : ""), bgcolor=bgMid, text_color=f_liveColor(baseLotsChanged, vixColLive), text_size=size.small, text_halign=text.align_center)

    // ═══ ROW 7: Vol Multiplier ═══
    volMultChanged = volMultLast != volMultLive
    volColLast = volMultLast < 1.0 ? cWarn : cNeutral
    volColLive = volMultLive < 1.0 ? cWarn : cNeutral
    table.cell(d, 0, 7, "Vol Filter", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 7, str.tostring(volMultLast, "#.##") + "×", bgcolor=bgMid, text_color=volColLast, text_size=size.small, text_halign=text.align_center)
    table.cell(d, 2, 7, str.tostring(volMultLive, "#.##") + "×" + (volMultChanged ? " ●" : ""), bgcolor=bgMid, text_color=f_liveColor(volMultChanged, volColLive), text_size=size.small, text_halign=text.align_center)

    // ═══ ROW 8: Drawdown ═══
    ddCol = ddMult >= 1.0 ? cGood : ddMult >= 0.5 ? color.yellow : ddMult >= 0.25 ? cWarn : cDanger
    ddDisplay = i_drawdownBand + " (" + str.tostring(ddMult, "#.##") + "×)"
    table.cell(d, 0, 8, "Drawdown", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 8, ddDisplay, bgcolor=bgMid, text_color=ddCol, text_size=size.small, text_halign=text.align_center)
    table.cell(d, 2, 8, ddDisplay, bgcolor=bgMid, text_color=ddCol, text_size=size.small, text_halign=text.align_center)

    // ═══ ROW 9: Final Lots breakdown ═══
    finalLastStr = str.tostring(finalLotsLast) + " lots"
    finalLiveStr = str.tostring(finalLotsLive) + " lots" + (finalLotsChanged ? " ●" : "")
    finalColLast = finalLotsLast == 0 ? cDanger : finalLotsLast < baseLotsLast ? cWarn : cGood
    finalColLive = finalLotsLive == 0 ? cDanger : finalLotsLive < baseLotsLive ? cWarn : cGood
    table.cell(d, 0, 9, "Final Lots", bgcolor=bgMid, text_color=color.white, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 9, finalLastStr, bgcolor=bgMid, text_color=finalColLast, text_size=size.small, text_halign=text.align_center)
    table.cell(d, 2, 9, finalLiveStr, bgcolor=bgMid, text_color=f_liveColor(finalLotsChanged, finalColLive), text_size=size.small, text_halign=text.align_center)

    // ═══ ROW 10: Max Risk ═══
    riskLast = finalLotsLast > 0 ? "₹" + str.tostring(maxLossPerLot * finalLotsLast, "#,###") : "—"
    riskLive = finalLotsLive > 0 ? "₹" + str.tostring(maxLossPerLot * finalLotsLive, "#,###") : "—"
    table.cell(d, 0, 10, "Max Risk", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 10, riskLast, bgcolor=bgMid, text_color=cWarn, text_size=size.small, text_halign=text.align_center)
    table.cell(d, 2, 10, riskLive, bgcolor=bgMid, text_color=f_liveColor(finalLotsChanged, cWarn), text_size=size.small, text_halign=text.align_center)

    // ═══ ROW 11: Section header — SIGNALS ═══
    table.cell(d, 0, 11, "SIGNALS", bgcolor=bgHeader, text_color=txtMuted, text_size=size.tiny, text_halign=text.align_left)
    table.merge_cells(d, 0, 11, 2, 11)

    // ═══ ROW 12: Bias ═══
    biasLastStr = biasStateLast + " " + str.tostring(biasLast, "#.##")
    biasLiveStr = biasStateLive + " " + str.tostring(biasLive, "#.##") + (biasChanged ? " ●" : "")
    table.cell(d, 0, 12, "Bias", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 12, biasLastStr, bgcolor=bgMid, text_color=biasColLast, text_size=size.small, text_halign=text.align_center)
    table.cell(d, 2, 12, biasLiveStr, bgcolor=bgMid, text_color=f_liveColor(biasChanged, biasColLive), text_size=size.small, text_halign=text.align_center)

    // ═══ ROW 13: RV ═══
    rvLastStr = not na(rvRatioLast) ? rvStateLast + " " + str.tostring(rvRatioLast, "#.##") : "—"
    rvLiveStr = not na(rvRatioLive) ? rvStateLive + " " + str.tostring(rvRatioLive, "#.##") + (rvChanged ? " ●" : "") : "—"
    table.cell(d, 0, 13, "RV5/RV20", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 13, rvLastStr, bgcolor=bgMid, text_color=rvColLast, text_size=size.small, text_halign=text.align_center)
    table.cell(d, 2, 13, rvLiveStr, bgcolor=bgMid, text_color=f_liveColor(rvChanged, rvColLive), text_size=size.small, text_halign=text.align_center)

    // ═══ ROW 14: Structure ═══
    structLiveStr = structureLive + (structureChanged ? " ●" : "")
    table.cell(d, 0, 14, "Structure", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 14, structureLast, bgcolor=bgMid, text_color=txtPrime, text_size=size.small, text_halign=text.align_center)
    table.cell(d, 2, 14, structLiveStr, bgcolor=bgMid, text_color=f_liveColor(structureChanged, txtPrime), text_size=size.small, text_halign=text.align_center)

    // ═══ ROW 15: Strikes ═══
    strikeLastStr = f_strikeStr(structureLast, putShortLast, putLongLast, callShortLast, callLongLast)
    strikeLiveStr = f_strikeStr(structureLive, putShortLive, putLongLive, callShortLive, callLongLive)
    strikesChanged = strikeLastStr != strikeLiveStr
    table.cell(d, 0, 15, "Strikes", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 15, strikeLastStr, bgcolor=bgMid, text_color=cInfo, text_size=size.small, text_halign=text.align_center)
    table.cell(d, 2, 15, strikeLiveStr + (strikesChanged ? " ●" : ""), bgcolor=bgMid, text_color=f_liveColor(strikesChanged, cInfo), text_size=size.small, text_halign=text.align_center)

    // ═══ ROW 16: ATR ═══
    table.cell(d, 0, 16, "ATR(" + str.tostring(i_atrLen) + ")", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
    table.cell(d, 1, 16, str.tostring(atrValLast, "#"), bgcolor=bgMid, text_color=cNeutral, text_size=size.small, text_halign=text.align_center)
    table.cell(d, 2, 16, str.tostring(atrValLive, "#"), bgcolor=bgMid, text_color=cNeutral, text_size=size.small, text_halign=text.align_center)

    // ═══ ACTIVE TRADE BLOCK (only if active) ═══
    footerRow = 17
    if hasActiveTrade
        table.cell(d, 0, 17, "ACTIVE TRADE", bgcolor=bgHeader, text_color=txtMuted, text_size=size.tiny, text_halign=text.align_left)
        table.merge_cells(d, 0, 17, 2, 17)

        table.cell(d, 0, 18, "Entry Spot", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
        table.cell(d, 1, 18, str.tostring(i_entrySpot, "#"), bgcolor=bgMid, text_color=txtPrime, text_size=size.small, text_halign=text.align_center)
        table.cell(d, 2, 18, str.tostring(close, "#"), bgcolor=bgMid, text_color=txtPrime, text_size=size.small, text_halign=text.align_center)

        // PE Stop with proximity
        if hasActivePE
            peDist = (close - peStopLevel) / (i_entrySpot - peStopLevel) * 100
            peStopCol = close <= peStopLevel ? cDanger : peDist < 50 ? cWarn : cGood
            peStopWarn = close <= peStopLevel ? "⚠ HIT" : peDist < 50 ? "near" : ""
            peStopStr = str.tostring(peStopLevel, "#") + (peStopWarn != "" ? "  " + peStopWarn : "")
            table.cell(d, 0, 19, "PE Stop", bgcolor=bgMid, text_color=color.new(#e94560, 30), text_size=size.small, text_halign=text.align_left)
            table.cell(d, 1, 19, str.tostring(peStopLevel, "#"), bgcolor=bgMid, text_color=color.new(#e94560, 30), text_size=size.small, text_halign=text.align_center)
            table.cell(d, 2, 19, peStopStr, bgcolor=bgMid, text_color=peStopCol, text_size=size.small, text_halign=text.align_center)
        else
            table.cell(d, 0, 19, "PE Stop", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
            table.cell(d, 1, 19, "—", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_center)
            table.cell(d, 2, 19, "—", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_center)

        // CE Stop
        if hasActiveCE
            ceDist = (ceStopLevel - close) / (ceStopLevel - i_entrySpot) * 100
            ceStopCol = close >= ceStopLevel ? cDanger : ceDist < 50 ? cWarn : cGood
            ceStopWarn = close >= ceStopLevel ? "⚠ HIT" : ceDist < 50 ? "near" : ""
            ceStopStr = str.tostring(ceStopLevel, "#") + (ceStopWarn != "" ? "  " + ceStopWarn : "")
            table.cell(d, 0, 20, "CE Stop", bgcolor=bgMid, text_color=color.new(#0ea5e9, 30), text_size=size.small, text_halign=text.align_left)
            table.cell(d, 1, 20, str.tostring(ceStopLevel, "#"), bgcolor=bgMid, text_color=color.new(#0ea5e9, 30), text_size=size.small, text_halign=text.align_center)
            table.cell(d, 2, 20, ceStopStr, bgcolor=bgMid, text_color=ceStopCol, text_size=size.small, text_halign=text.align_center)
        else
            table.cell(d, 0, 20, "CE Stop", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_left)
            table.cell(d, 1, 20, "—", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_center)
            table.cell(d, 2, 20, "—", bgcolor=bgMid, text_color=txtDim, text_size=size.small, text_halign=text.align_center)

        footerRow := 21

    // ═══ FOOTER ═══
    timeStrLive = barstate.isrealtime ? f_fmtTime(timenow) : f_fmtTime(time_close)
    table.cell(d, 0, footerRow, "Time", bgcolor=bgDark, text_color=txtMuted, text_size=size.tiny, text_halign=text.align_left)
    table.cell(d, 1, footerRow, f_fmtTime(time_close[1]), bgcolor=bgDark, text_color=txtMuted, text_size=size.tiny, text_halign=text.align_center)
    table.cell(d, 2, footerRow, timeStrLive, bgcolor=bgDark, text_color=txtMuted, text_size=size.tiny, text_halign=text.align_center)

// ─────────────────────────────────────────────────────────────────────────────
// J) STRIKE LEVELS ON CHART — horizontal plot lines + single combined label per side
// ─────────────────────────────────────────────────────────────────────────────

// Plot lines extend across visible chart range so strikes are always visible
// regardless of zoom level. Only plotted when structure has that side.
showPutsOnChart  = i_showStrikeLabels and structureLive != "NO TRADE" and structureLive != "CALL SPREAD"
showCallsOnChart = i_showStrikeLabels and structureLive != "NO TRADE" and structureLive != "PUT SPREAD"

plot(showPutsOnChart  ? putShortLive  : na, "PE Short", color=color.new(#e94560, 0),  linewidth=2, style=plot.style_linebr)
plot(showPutsOnChart  ? putLongLive   : na, "PE Long",  color=color.new(#e94560, 50), linewidth=1, style=plot.style_linebr)
plot(showCallsOnChart ? callShortLive : na, "CE Short", color=color.new(#0ea5e9, 0),  linewidth=2, style=plot.style_linebr)
plot(showCallsOnChart ? callLongLive  : na, "CE Long",  color=color.new(#0ea5e9, 50), linewidth=1, style=plot.style_linebr)

// Single combined label per side (right of last bar) — placed midway between short & long
if barstate.islast and i_showStrikeLabels and structureLive != "NO TRADE"
    if showPutsOnChart
        peLabelY = (putShortLive + putLongLive) / 2
        peLabelText = "PE  " + str.tostring(putShortLive, "#") + " / " + str.tostring(putLongLive, "#")
        label.new(bar_index + 2, peLabelY, peLabelText, style=label.style_label_left, color=color.new(#e94560, 15), textcolor=color.white, size=size.small)

    if showCallsOnChart
        ceLabelY = (callShortLive + callLongLive) / 2
        ceLabelText = "CE  " + str.tostring(callShortLive, "#") + " / " + str.tostring(callLongLive, "#")
        label.new(bar_index + 2, ceLabelY, ceLabelText, style=label.style_label_left, color=color.new(#0ea5e9, 15), textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
// K) ACTIVE TRADE STOP LINES
// ─────────────────────────────────────────────────────────────────────────────

plot(i_showStops and hasActivePE ? peStopLevel : na, "PE Stop (75%)", color=color.new(#ff6b35, 0), linewidth=2, style=plot.style_linebr)
plot(i_showStops and hasActiveCE ? ceStopLevel : na, "CE Stop (75%)", color=color.new(#ff6b35, 0), linewidth=2, style=plot.style_linebr)
plot(i_showStops and hasActivePE ? i_entryPEShort : na, "PE Short Strike", color=color.new(#e94560, 30), linewidth=1, style=plot.style_circles)
plot(i_showStops and hasActiveCE ? i_entryCEShort : na, "CE Short Strike", color=color.new(#0ea5e9, 30), linewidth=1, style=plot.style_circles)
plot(i_showStops and hasActiveTrade ? i_entrySpot : na, "Entry Spot", color=color.new(color.white, 50), linewidth=1, style=plot.style_cross)

if barstate.islast and i_showStops and hasActivePE
    label.new(bar_index + 2, peStopLevel, "PE STOP " + str.tostring(peStopLevel, "#"), style=label.style_label_left, color=color.new(#ff6b35, 0), textcolor=color.white, size=size.small)

if barstate.islast and i_showStops and hasActiveCE
    label.new(bar_index + 2, ceStopLevel, "CE STOP " + str.tostring(ceStopLevel, "#"), style=label.style_label_left, color=color.new(#ff6b35, 0), textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
// L) ALERTS
// ─────────────────────────────────────────────────────────────────────────────

peStopHit = hasActivePE and close <= peStopLevel
ceStopHit = hasActiveCE and close >= ceStopLevel

alertcondition(peStopHit, "PE Stop Hit (75%)", "PE 75% stop breached. Confirm with 5-min candle, then exit threatened leg.")
alertcondition(ceStopHit, "CE Stop Hit (75%)", "CE 75% stop breached. Confirm with 5-min candle, then exit threatened leg.")

vixExtreme   = not na(vixCloseLive) and vixCloseLive >= 35
vixHighRate  = not na(vixCloseLive) and not na(vixCloseLast) and vixCloseLive >= 30 and (vixCloseLive - vixCloseLast) / vixCloseLast > 0.20
alertcondition(vixExtreme,  "VIX Extreme (>=35)",  "EMERGENCY: VIX >= 35. Close all positions.")
alertcondition(vixHighRate, "VIX Shock (>30 + >20%)", "EMERGENCY: VIX shock. Close all positions.")

alertcondition(regimeLive == "BULLISH" or regimeLive == "BULL FADING", "Bullish Regime", "Regime: BULLISH")
alertcondition(regimeLive == "BEARISH" or regimeLive == "BEAR FADING", "Bearish Regime", "Regime: BEARISH")
alertcondition(regimeLive == "RANGE",          "Range Regime",   "Regime: RANGE")
alertcondition(regimeLive == "BREAKOUT RISK", "Breakout Risk",   "Regime: BREAKOUT RISK")
alertcondition(regimeLive == "UNSTABLE",       "Unstable",       "Regime: UNSTABLE")
alertcondition(regimeLive == "NO TRADE",       "No Trade",       "Regime: NO TRADE")

biasFlipFromBull = biasStateLive[1] == "BULL" and biasStateLive == "NEUTRAL"
biasFlipFromBear = biasStateLive[1] == "BEAR" and biasStateLive == "NEUTRAL"
alertcondition(biasFlipFromBull, "Bias Exit BULL", "EMERGENCY: Bias dropped below +0.25.")
alertcondition(biasFlipFromBear, "Bias Exit BEAR", "EMERGENCY: Bias rose above -0.25.")

// Regime change alert (LIVE differs from CLOSED)
alertcondition(regimeChanged, "Regime Forming Change", "Live regime differs from last closed. Forming change in progress.")

// ─────────────────────────────────────────────────────────────────────────────
// M) DATA WINDOW
// ─────────────────────────────────────────────────────────────────────────────

plot(biasLive,       "Bias Live",      color=color.new(color.blue, 100),   display=display.data_window)
plot(biasLast,       "Bias Last",      color=color.new(color.aqua, 100),   display=display.data_window)
plot(rvRatioLive,    "RV Ratio Live",  color=color.new(color.orange, 100), display=display.data_window)
plot(rvRatioLast,    "RV Ratio Last",  color=color.new(color.orange, 100), display=display.data_window)
plot(vixCloseLive,   "VIX Live",       color=color.new(color.purple, 100), display=display.data_window)
plot(vixCloseLast,   "VIX Last",       color=color.new(color.purple, 100), display=display.data_window)
plot(putShortLive,   "PE Short Live",  color=color.new(color.red, 100),    display=display.data_window)
plot(callShortLive,  "CE Short Live",  color=color.new(color.blue, 100),   display=display.data_window)
plot(finalLotsLive,  "Final Lots Live",color=color.new(color.aqua, 100),   display=display.data_window)
plot(finalLotsLast,  "Final Lots Last",color=color.new(color.aqua, 100),   display=display.data_window)
plot(volMultLive,    "Vol Mult",       color=color.new(color.orange, 100), display=display.data_window)
plot(ddMult,         "DD Mult",        color=color.new(color.red, 100),    display=display.data_window)
plot(peStopLevel,    "PE Stop",        color=color.new(#ff6b35, 100),      display=display.data_window)
plot(ceStopLevel,    "CE Stop",        color=color.new(#ff6b35, 100),      display=display.data_window)
````
