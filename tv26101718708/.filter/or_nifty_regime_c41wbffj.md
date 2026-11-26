# OR: Nifty Regime

- url: https://www.tradingview.com/script/C41wbFfJ-OR-Nifty-Regime/
- type: indicator
- pine_id: PUB;13873772556b40ed9a7ccfc626000fcc
- version: 1.0

## Description

NIFTY Regime Engine — Direction × Volatility × Risk

This indicator is a daily regime classification and execution framework for NIFTY options trading.

Instead of relying on price-only signals, the model combines three orthogonal dimensions:

1. Directional Bias

Normalized price displacement from EMA20 using ATR:

Captures trend strength in volatility-adjusted terms
2. Volatility Regime (RV Ratio)

Short-term vs long-term realized volatility:

Identifies compression (breakout risk)
Identifies expansion (active trend phase)
3. VIX-Based Position Sizing

India VIX is used to dynamically scale exposure:

Reduces size in high-volatility regimes
Eliminates trades in extreme conditions
What this solves

Most retail option systems fail because they:

Trade direction without understanding volatility
Sell premium in compressed regimes before expansion
Ignore position sizing entirely

This engine addresses those gaps by combining:

Direction + Structure + Risk

Outputs
Regime classification (Bullish / Bearish / Range / Breakout Risk / Skip)
Recommended position size (lots + %)
ATR-based strike mapping
Max loss estimation
Visual dashboard + alerts
Use case

Designed for:

Credit spread traders
Iron condor strategies
Systematic NIFTY option sellers

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// © OpenRoad Capital

//@version=6
indicator("NIFTY Regime Signal Engine", shorttitle="RegimeEngine", overlay=true, max_labels_count=10)

// ─────────────────────────────────────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────────────────────────────────────

// Bias inputs
i_emaLen        = input.int(20, "EMA Length", minval=5, maxval=100, group="Directional Bias")
i_atrLen        = input.int(14, "ATR Length", minval=5, maxval=50, group="Directional Bias")
i_biasBull      = input.float(0.5, "Bias Bullish Threshold", minval=0.1, step=0.1, group="Directional Bias")
i_biasBear      = input.float(-0.5, "Bias Bearish Threshold", maxval=-0.1, step=0.1, group="Directional Bias")

// RV inputs
i_rvShort       = input.int(5, "RV Short Length", minval=3, maxval=20, group="Realized Volatility")
i_rvLong        = input.int(20, "RV Long Length", minval=10, maxval=60, group="Realized Volatility")
i_rvExpand      = input.float(1.2, "RV Expanding Threshold", minval=1.0, step=0.05, group="Realized Volatility")
i_rvCompress    = input.float(0.8, "RV Compressing Threshold", minval=0.1, maxval=1.0, step=0.05, group="Realized Volatility")

// VIX inputs
i_vixSymbol     = input.symbol("NSE:INDIAVIX", "India VIX Symbol", group="VIX Sizing")

// Strike placement inputs
i_wingWidth     = input.int(200, "Wing Width (points)", minval=50, maxval=1000, step=50, group="Strike Placement")
i_strikeRound   = input.int(50, "Round Strikes To (points)", minval=25, maxval=100, step=25, group="Strike Placement")
i_lotSize       = input.int(15, "NIFTY Lot Size", minval=1, group="Strike Placement")

// Display inputs
i_showBg        = input.bool(true, "Show Background Color", group="Display")
i_showTable     = input.bool(true, "Show Regime Dashboard", group="Display")
i_showStrikes   = input.bool(true, "Show Strike Dashboard", group="Display")
i_tablePos      = input.string("Top Right", "Regime Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Display")
i_strikePos     = input.string("Bottom Right", "Strike Table Position", options=["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group="Display")

// ─────────────────────────────────────────────────────────────────────────────
// HELPER: TABLE POSITION
// ─────────────────────────────────────────────────────────────────────────────

f_tablePos(pos) =>
    switch pos
        "Top Right"     => position.top_right
        "Top Left"      => position.top_left
        "Bottom Right"  => position.bottom_right
        "Bottom Left"   => position.bottom_left
        => position.top_right

// Helper: round to nearest strike
f_roundDown(val, step) =>
    math.floor(val / step) * step

f_roundUp(val, step) =>
    math.ceil(val / step) * step

// ─────────────────────────────────────────────────────────────────────────────
// A) VIX-BASED POSITION SIZING
// ─────────────────────────────────────────────────────────────────────────────

// Fetch India VIX daily close — confirmed bar only (no repaint)
vixClose = request.security(i_vixSymbol, "D", close[1], barmerge.gaps_off, barmerge.lookahead_on)

// Map VIX to lots and position size percentage
var int    recLots   = 0
var int    posPct    = 0
var string vixZone   = ""

if not na(vixClose)
    if vixClose >= 35
        recLots  := 0
        posPct   := 0
        vixZone  := "EXTREME"
    else if vixClose >= 25
        recLots  := 4
        posPct   := 50
        vixZone  := "HIGH"
    else if vixClose >= 20
        recLots  := 6
        posPct   := 75
        vixZone  := "ELEVATED"
    else
        recLots  := 8
        posPct   := 100
        vixZone  := "NORMAL"

// ─────────────────────────────────────────────────────────────────────────────
// B) DIRECTIONAL BIAS
// ─────────────────────────────────────────────────────────────────────────────

ema20 = ta.ema(close, i_emaLen)
atr14 = ta.atr(i_atrLen)

bias = atr14 > 0 ? (close - ema20) / atr14 : 0.0

var string biasState = "NEUTRAL"
if bias > i_biasBull
    biasState := "BULL"
else if bias < i_biasBear
    biasState := "BEAR"
else
    biasState := "NEUTRAL"

// ─────────────────────────────────────────────────────────────────────────────
// C) REALIZED VOLATILITY RATIO
// ─────────────────────────────────────────────────────────────────────────────

// Daily log returns
logReturn = math.log(close / close[1])

// Annualized realized volatility (standard deviation of log returns × √252)
rv5  = ta.stdev(logReturn, i_rvShort) * math.sqrt(252)
rv20 = ta.stdev(logReturn, i_rvLong)  * math.sqrt(252)

rvRatio = rv20 > 0 ? rv5 / rv20 : na

var string rvState = "NORMAL"
if not na(rvRatio)
    if rvRatio > i_rvExpand
        rvState := "EXPANDING"
    else if rvRatio < i_rvCompress
        rvState := "COMPRESSING"
    else
        rvState := "NORMAL"

// ─────────────────────────────────────────────────────────────────────────────
// D) COMBINED REGIME OUTPUT
// ─────────────────────────────────────────────────────────────────────────────

var string regime     = "RANGE"
var color  regimeCol  = color.yellow

if recLots == 0
    regime    := "NO TRADE"
    regimeCol := color.gray
else if biasState == "BULL" and (rvState == "NORMAL" or rvState == "EXPANDING")
    regime    := "BULLISH"
    regimeCol := color.green
else if biasState == "BULL" and rvState == "COMPRESSING"
    regime    := "BULLISH (FADING)"
    regimeCol := color.new(color.green, 50)
else if biasState == "BEAR" and (rvState == "NORMAL" or rvState == "EXPANDING")
    regime    := "BEARISH"
    regimeCol := color.red
else if biasState == "BEAR" and rvState == "COMPRESSING"
    regime    := "BEARISH (FADING)"
    regimeCol := color.new(color.red, 50)
else if biasState == "NEUTRAL" and rvState == "NORMAL"
    regime    := "RANGE"
    regimeCol := color.yellow
else if biasState == "NEUTRAL" and rvState == "COMPRESSING"
    regime    := "RANGE / BREAKOUT RISK"
    regimeCol := color.orange
else if biasState == "NEUTRAL" and rvState == "EXPANDING"
    regime    := "UNSTABLE / SKIP"
    regimeCol := color.new(color.gray, 30)

// ─────────────────────────────────────────────────────────────────────────────
// E) STRIKE PLACEMENT LOGIC
// ─────────────────────────────────────────────────────────────────────────────

// ATR multipliers per regime — [put_mult, call_mult]
var float putMult  = 2.0
var float callMult = 2.0
var string structure = "—"

if regime == "BULLISH"
    putMult    := 1.5
    callMult   := 3.0
    structure  := "PUT SPREAD"
else if regime == "BULLISH (FADING)"
    putMult    := 2.0
    callMult   := 2.5
    structure  := "IRON CONDOR"
else if regime == "BEARISH"
    putMult    := 3.0
    callMult   := 1.5
    structure  := "CALL SPREAD"
else if regime == "BEARISH (FADING)"
    putMult    := 2.5
    callMult   := 2.0
    structure  := "IRON CONDOR"
else if regime == "RANGE"
    putMult    := 2.0
    callMult   := 2.0
    structure  := "IRON CONDOR"
else if regime == "RANGE / BREAKOUT RISK"
    putMult    := 2.5
    callMult   := 2.5
    structure  := "IRON CONDOR (WIDE)"
else
    putMult    := 0.0
    callMult   := 0.0
    structure  := "NO TRADE"

// Calculate strike levels
atrVal       = nz(atr14, 0)
putDistance   = atrVal * putMult
callDistance  = atrVal * callMult

// Short strikes — round away from price (puts round down, calls round up)
putShort     = f_roundDown(close - putDistance, i_strikeRound)
callShort    = f_roundUp(close + callDistance, i_strikeRound)

// Long strikes — wing width away from short
putLong      = putShort - i_wingWidth
callLong     = callShort + i_wingWidth

// Max loss per lot
maxLossPerLot = i_wingWidth * i_lotSize

// Total max loss at recommended lots
totalMaxLoss  = maxLossPerLot * recLots

// Stop loss level (2x premium) — shown as a concept, actual premium is unknown at signal time
// We show max loss instead since premium depends on market conditions at entry

// ─────────────────────────────────────────────────────────────────────────────
// F) BACKGROUND COLOR
// ─────────────────────────────────────────────────────────────────────────────

bgcolor(i_showBg ? color.new(regimeCol, 88) : na)

// ─────────────────────────────────────────────────────────────────────────────
// G) REGIME DASHBOARD TABLE
// ─────────────────────────────────────────────────────────────────────────────

if i_showTable and barstate.islast
    var table dash = table.new(f_tablePos(i_tablePos), 3, 10, border_width=1)

    // Colors
    headerBg  = color.new(#1a1a2e, 0)
    headerTxt = color.white
    rowBg     = color.new(#16213e, 0)
    rowTxt    = color.new(color.white, 10)

    // Bias color
    biasCol = biasState == "BULL" ? color.green : biasState == "BEAR" ? color.red : color.yellow

    // RV color
    rvCol = rvState == "EXPANDING" ? color.red : rvState == "COMPRESSING" ? color.aqua : color.yellow

    // VIX color
    vixCol = vixZone == "EXTREME" ? color.red : vixZone == "HIGH" ? color.orange : vixZone == "ELEVATED" ? color.yellow : color.green

    // ── Header ──
    table.cell(dash, 0, 0, "REGIME ENGINE", bgcolor=headerBg, text_color=headerTxt, text_size=size.normal, text_halign=text.align_left)
    table.merge_cells(dash, 0, 0, 2, 0)

    // ── Row 1: India VIX ──
    table.cell(dash, 0, 1, "India VIX", bgcolor=rowBg, text_color=rowTxt, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 1, not na(vixClose) ? str.tostring(vixClose, "#.##") : "N/A", bgcolor=rowBg, text_color=vixCol, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 1, vixZone, bgcolor=rowBg, text_color=vixCol, text_size=size.small, text_halign=text.align_right)

    // ── Row 2: Lots ──
    table.cell(dash, 0, 2, "Lots", bgcolor=rowBg, text_color=rowTxt, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(recLots), bgcolor=rowBg, text_color=vixCol, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 2, str.tostring(posPct) + "%", bgcolor=rowBg, text_color=vixCol, text_size=size.small, text_halign=text.align_right)

    // ── Row 3: Separator ──
    table.cell(dash, 0, 3, "", bgcolor=headerBg, text_color=headerTxt, text_size=size.tiny)
    table.merge_cells(dash, 0, 3, 2, 3)

    // ── Row 4: Bias ──
    table.cell(dash, 0, 4, "Bias", bgcolor=rowBg, text_color=rowTxt, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 4, str.tostring(bias, "#.##"), bgcolor=rowBg, text_color=biasCol, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 4, biasState, bgcolor=rowBg, text_color=biasCol, text_size=size.small, text_halign=text.align_right)

    // ── Row 5: RV Ratio ──
    table.cell(dash, 0, 5, "RV Ratio", bgcolor=rowBg, text_color=rowTxt, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 1, 5, not na(rvRatio) ? str.tostring(rvRatio, "#.##") : "N/A", bgcolor=rowBg, text_color=rvCol, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 5, rvState, bgcolor=rowBg, text_color=rvCol, text_size=size.small, text_halign=text.align_right)

    // ── Row 6: RV5 / RV20 raw ──
    table.cell(dash, 0, 6, "RV5 / RV20", bgcolor=rowBg, text_color=rowTxt, text_size=size.small, text_halign=text.align_left)
    rv5Str  = not na(rv5)  ? str.tostring(rv5 * 100, "#.#") + "%" : "N/A"
    rv20Str = not na(rv20) ? str.tostring(rv20 * 100, "#.#") + "%" : "N/A"
    table.cell(dash, 1, 6, rv5Str, bgcolor=rowBg, text_color=rowTxt, text_size=size.small, text_halign=text.align_center)
    table.cell(dash, 2, 6, rv20Str, bgcolor=rowBg, text_color=rowTxt, text_size=size.small, text_halign=text.align_right)

    // ── Row 7: Separator ──
    table.cell(dash, 0, 7, "", bgcolor=headerBg, text_color=headerTxt, text_size=size.tiny)
    table.merge_cells(dash, 0, 7, 2, 7)

    // ── Row 8: Final Regime ──
    table.cell(dash, 0, 8, "REGIME", bgcolor=color.new(regimeCol, 70), text_color=color.white, text_size=size.normal, text_halign=text.align_left)
    table.cell(dash, 1, 8, regime, bgcolor=color.new(regimeCol, 70), text_color=color.white, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 1, 8, 2, 8)

    // ── Row 9: Timestamp ──
    table.cell(dash, 0, 9, "As of", bgcolor=rowBg, text_color=color.new(color.white, 50), text_size=size.tiny, text_halign=text.align_left)
    table.cell(dash, 1, 9, str.format("{0,date,dd-MMM-yy}", time), bgcolor=rowBg, text_color=color.new(color.white, 50), text_size=size.tiny, text_halign=text.align_center)
    table.merge_cells(dash, 1, 9, 2, 9)

// ─────────────────────────────────────────────────────────────────────────────
// H) STRIKE PLACEMENT DASHBOARD
// ─────────────────────────────────────────────────────────────────────────────

if i_showStrikes and barstate.islast
    var table stk = table.new(f_tablePos(i_strikePos), 4, 12, border_width=1)

    // Colors
    sHeaderBg  = color.new(#0f3460, 0)
    sHeaderTxt = color.white
    sRowBg     = color.new(#16213e, 0)
    sRowTxt    = color.new(color.white, 10)
    putCol     = color.new(#e94560, 0)
    callCol    = color.new(#0ea5e9, 0)
    warnCol    = color.orange

    // ── Header ──
    table.cell(stk, 0, 0, "STRIKE MAP", bgcolor=sHeaderBg, text_color=sHeaderTxt, text_size=size.normal, text_halign=text.align_left)
    table.merge_cells(stk, 0, 0, 3, 0)

    // ── Row 1: Structure ──
    table.cell(stk, 0, 1, "Structure", bgcolor=sRowBg, text_color=sRowTxt, text_size=size.small, text_halign=text.align_left)
    table.cell(stk, 1, 1, structure, bgcolor=sRowBg, text_color=color.white, text_size=size.small, text_halign=text.align_center)
    table.merge_cells(stk, 1, 1, 3, 1)

    // ── Row 2: ATR value ──
    table.cell(stk, 0, 2, "ATR(" + str.tostring(i_atrLen) + ")", bgcolor=sRowBg, text_color=sRowTxt, text_size=size.small, text_halign=text.align_left)
    table.cell(stk, 1, 2, str.tostring(atrVal, "#.#"), bgcolor=sRowBg, text_color=sRowTxt, text_size=size.small, text_halign=text.align_center)
    table.cell(stk, 2, 2, "Wing", bgcolor=sRowBg, text_color=sRowTxt, text_size=size.small, text_halign=text.align_center)
    table.cell(stk, 3, 2, str.tostring(i_wingWidth) + " pts", bgcolor=sRowBg, text_color=sRowTxt, text_size=size.small, text_halign=text.align_right)

    // ── Row 3: Separator ──
    table.cell(stk, 0, 3, "", bgcolor=sHeaderBg, text_color=sHeaderTxt, text_size=size.tiny)
    table.merge_cells(stk, 0, 3, 3, 3)

    // ── Row 4: Column headers ──
    table.cell(stk, 0, 4, "", bgcolor=sRowBg, text_color=sRowTxt, text_size=size.tiny)
    table.cell(stk, 1, 4, "Short", bgcolor=sRowBg, text_color=sRowTxt, text_size=size.tiny, text_halign=text.align_center)
    table.cell(stk, 2, 4, "Long", bgcolor=sRowBg, text_color=sRowTxt, text_size=size.tiny, text_halign=text.align_center)
    table.cell(stk, 3, 4, "Mult", bgcolor=sRowBg, text_color=sRowTxt, text_size=size.tiny, text_halign=text.align_center)

    // ── Row 5: Put spread ──
    showPuts = structure != "NO TRADE" and structure != "CALL SPREAD"
    table.cell(stk, 0, 5, "PE", bgcolor=sRowBg, text_color=putCol, text_size=size.small, text_halign=text.align_left)
    table.cell(stk, 1, 5, showPuts ? str.tostring(putShort, "#") : "—", bgcolor=sRowBg, text_color=putCol, text_size=size.small, text_halign=text.align_center)
    table.cell(stk, 2, 5, showPuts ? str.tostring(putLong, "#") : "—", bgcolor=sRowBg, text_color=putCol, text_size=size.small, text_halign=text.align_center)
    table.cell(stk, 3, 5, showPuts ? str.tostring(putMult, "#.#") + "x" : "—", bgcolor=sRowBg, text_color=putCol, text_size=size.small, text_halign=text.align_center)

    // ── Row 6: Call spread ──
    showCalls = structure != "NO TRADE" and structure != "PUT SPREAD"
    table.cell(stk, 0, 6, "CE", bgcolor=sRowBg, text_color=callCol, text_size=size.small, text_halign=text.align_left)
    table.cell(stk, 1, 6, showCalls ? str.tostring(callShort, "#") : "—", bgcolor=sRowBg, text_color=callCol, text_size=size.small, text_halign=text.align_center)
    table.cell(stk, 2, 6, showCalls ? str.tostring(callLong, "#") : "—", bgcolor=sRowBg, text_color=callCol, text_size=size.small, text_halign=text.align_center)
    table.cell(stk, 3, 6, showCalls ? str.tostring(callMult, "#.#") + "x" : "—", bgcolor=sRowBg, text_color=callCol, text_size=size.small, text_halign=text.align_center)

    // ── Row 7: Separator ──
    table.cell(stk, 0, 7, "", bgcolor=sHeaderBg, text_color=sHeaderTxt, text_size=size.tiny)
    table.merge_cells(stk, 0, 7, 3, 7)

    // ── Row 8: Risk summary header ──
    table.cell(stk, 0, 8, "RISK", bgcolor=sHeaderBg, text_color=sHeaderTxt, text_size=size.tiny, text_halign=text.align_left)
    table.merge_cells(stk, 0, 8, 3, 8)

    // ── Row 9: Max loss per lot ──
    table.cell(stk, 0, 9, "Max Loss/Lot", bgcolor=sRowBg, text_color=sRowTxt, text_size=size.small, text_halign=text.align_left)
    table.merge_cells(stk, 0, 9, 1, 9)
    table.cell(stk, 2, 9, "₹" + str.tostring(maxLossPerLot, "#,###"), bgcolor=sRowBg, text_color=warnCol, text_size=size.small, text_halign=text.align_right)
    table.merge_cells(stk, 2, 9, 3, 9)

    // ── Row 10: Total max loss ──
    table.cell(stk, 0, 10, "Total Max Loss", bgcolor=sRowBg, text_color=sRowTxt, text_size=size.small, text_halign=text.align_left)
    table.merge_cells(stk, 0, 10, 1, 10)
    totalMaxStr = recLots > 0 ? "₹" + str.tostring(totalMaxLoss, "#,###") + " (" + str.tostring(recLots) + " lots)" : "—"
    table.cell(stk, 2, 10, totalMaxStr, bgcolor=sRowBg, text_color=warnCol, text_size=size.small, text_halign=text.align_right)
    table.merge_cells(stk, 2, 10, 3, 10)

    // ── Row 11: Stop rule reminder ──
    table.cell(stk, 0, 11, "Stop: Exit at 2× premium collected", bgcolor=color.new(warnCol, 80), text_color=warnCol, text_size=size.tiny, text_halign=text.align_left)
    table.merge_cells(stk, 0, 11, 3, 11)

// ─────────────────────────────────────────────────────────────────────────────
// I) STRIKE LEVEL LINES ON CHART (last bar only)
// ─────────────────────────────────────────────────────────────────────────────

if barstate.islast and structure != "NO TRADE"
    // Put strikes
    showPutsLine = structure != "CALL SPREAD"
    if showPutsLine
        label.new(bar_index + 2, putShort, "PE Short " + str.tostring(putShort, "#"), style=label.style_label_left, color=color.new(#e94560, 20), textcolor=color.white, size=size.small)
        label.new(bar_index + 2, putLong, "PE Long " + str.tostring(putLong, "#"), style=label.style_label_left, color=color.new(#e94560, 60), textcolor=color.white, size=size.small)

    // Call strikes
    showCallsLine = structure != "PUT SPREAD"
    if showCallsLine
        label.new(bar_index + 2, callShort, "CE Short " + str.tostring(callShort, "#"), style=label.style_label_left, color=color.new(#0ea5e9, 20), textcolor=color.white, size=size.small)
        label.new(bar_index + 2, callLong, "CE Long " + str.tostring(callLong, "#"), style=label.style_label_left, color=color.new(#0ea5e9, 60), textcolor=color.white, size=size.small)

// ─────────────────────────────────────────────────────────────────────────────
// J) ALERT CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────

alertcondition(regime == "BULLISH" or regime == "BULLISH (FADING)", "Bullish Regime", "Regime: BULLISH | Bias: {{bias}} | RV: {{rvRatio}}")
alertcondition(regime == "BEARISH" or regime == "BEARISH (FADING)", "Bearish Regime", "Regime: BEARISH | Bias: {{bias}} | RV: {{rvRatio}}")
alertcondition(regime == "RANGE", "Range Regime", "Regime: RANGE | Bias: {{bias}} | RV: {{rvRatio}}")
alertcondition(regime == "RANGE / BREAKOUT RISK", "Breakout Risk", "Regime: BREAKOUT RISK | Bias: {{bias}} | RV: {{rvRatio}}")
alertcondition(regime == "UNSTABLE / SKIP", "Unstable Regime", "Regime: UNSTABLE | Bias: {{bias}} | RV: {{rvRatio}}")
alertcondition(regime == "NO TRADE", "No Trade", "Regime: NO TRADE | VIX >= 35")

// ─────────────────────────────────────────────────────────────────────────────
// K) DATA WINDOW PLOTS (invisible on chart, available for inspection)
// ─────────────────────────────────────────────────────────────────────────────

plot(bias, "Bias", color=color.new(color.blue, 100), display=display.data_window)
plot(not na(rvRatio) ? rvRatio : na, "RV Ratio", color=color.new(color.orange, 100), display=display.data_window)
plot(not na(vixClose) ? vixClose : na, "India VIX", color=color.new(color.purple, 100), display=display.data_window)
plot(putShort, "PE Short Strike", color=color.new(color.red, 100), display=display.data_window)
plot(callShort, "CE Short Strike", color=color.new(color.blue, 100), display=display.data_window)
````
