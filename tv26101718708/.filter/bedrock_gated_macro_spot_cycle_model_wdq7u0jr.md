# BEDROCK  Gated Macro Spot Cycle Model

- url: https://www.tradingview.com/script/WDq7u0JR-BEDROCK-Gated-Macro-Spot-Cycle-Model/
- type: indicator
- pine_id: PUB;3f0589ad6cb24c04bf916e073445dfa5
- version: 1.0

## Description

BEDROCK condenses several independent long-term Bitcoin valuation models into a single transparent 0–100 score, then maps that score onto a seven-tier ladder running from deep value to cycle-top risk — with capitulation and euphoria gates that hold back the two most common false signals at each extreme. It is built for spot investors making multi-month and multi-year allocation decisions, not for short-term trading.

The reference card below shows how to read the model and how each tier behaves:

[image]https://www.tradingview.com/x/he7RADI3/[/image]

[b]█ WHAT IT DOES[/b]
BEDROCK answers one question: where does price sit inside its macro cycle right now? Rather than a single oscillator, it scores a basket of slow-moving valuation measures, normalizes each to a common 0–100 "cheap → expensive" scale, blends them into a weighted composite, and classifies the result into an actionable tier with a suggested accumulation or distribution size. A higher composite means greater long-term value and lower risk; a lower composite means the market is stretched and risk is rising.

[b]█ HOW IT WORKS[/b]
The composite is built from four independent blocs, any of which can be reweighted or disabled:
[list]
[*][b]Trailing cost-basis bloc[/b] — price relative to the 200-week SMA, the 2-year SMA, and the 200-day SMA (Mayer Multiple). These three are deliberately collapsed into a single averaged, bounded factor so the moving-average family is represented once and cannot dominate the score through collinearity.
[*][b]Drawdown from all-time high[/b] — how far price has fallen from its peak. The heaviest-weighted leg by default.
[*][b]Weekly RSI[/b] — long-term momentum, as secondary confirmation.
[*][b]MVRV Z-Score (optional)[/b] — an on-chain valuation leg you can enable and feed from an external source.
[/list]
Each metric is mapped to 0–100 through its own linear calibration between a deep-value anchor and an expensive anchor, so every leg speaks the same language before being combined. Weights are auto-renormalized over whatever blocs are actually available — so the model stays coherent on early history where the 200-week isn't yet populated, or when MVRV is turned off. It simply reweights the parts it has.

[b]█ THE TWO GATES — THE CORE IDEA[/b]
A raw valuation score has two classic failure modes: it screams "generational buy" on the first leg down of a bear market, and it screams "top" every time price gets mildly extended. BEDROCK addresses both with directional gates that only ever cap the tier toward the middle — they never fabricate a signal, and they never block the core accumulate or trim reads.
[list]
[*][b]Capitulation gate (bottom)[/b] — the two deepest tiers stay locked until the market shows genuine capitulation. Generational requires a large drawdown from the all-time high (or a deeply negative MVRV-Z); Deep Accumulation requires price at or below its 200-week basis. Until then the score is capped at Accumulation, so you keep buying value without prematurely committing everything.
[*][b]Euphoria gate (top)[/b] — the two riskiest tiers stay locked until multiple independent overheating signs agree across the 200-week multiple, weekly RSI, the Mayer Multiple, and MVRV-Z. Euphoria requires at least one confirmation; Cycle Top requires at least two. This is what stops the model from calling a top on every rally.
[/list]
Because both gates only cap toward neutral, accumulation signals are never suppressed and trim signals are never suppressed. The gates restrain only the extreme calls, and only until the evidence is actually there.

[b]█ READING THE INDICATOR[/b]
[list]
[*][b]Composite line[/b] — the 0–100 score, colored by its current tier.
[*][b]Background[/b] — shaded by tier for at-a-glance cycle context.
[*][b]Threshold lines[/b] — the tier boundaries.
[*][b]Markers[/b] — gated triangles mark transitions into accumulation tiers (up) and distribution tiers (down).
[*][b]Data table[/b] — live composite, current tier, suggested action, both gate states, and every underlying metric (200W and 2Y multiples, Mayer, drawdown, weekly RSI, MVRV).
[/list]

[b]█ THE SEVEN TIERS[/b]
[list]
[*][b]Generational Value[/b] — extremely rare deep value; aggressive accumulation.
[*][b]Deep Accumulation[/b] — excellent value; size up.
[*][b]Accumulation[/b] — good value; keep building.
[*][b]Neutral / Hold[/b] — fairly valued; hold.
[*][b]Expensive / Trim[/b] — above fair value; begin scaling out.
[*][b]Euphoria / Distribute[/b] — high risk; distribute and protect profit.
[*][b]Cycle Top / Exit[/b] — extreme; high-probability macro top.
[/list]
Each tier also outputs a suggested DCA-in or trim-out multiplier, so the signal is sized rather than binary.

[b]█ HOW TO USE IT[/b]
[list]
[*]Use it on Bitcoin spot or index charts such as [symbol="BITSTAMP:BTCUSD"]BITSTAMP:BTCUSD[/symbol] or $BINANCE:BTCUSDT.
[*]Weekly is the primary timeframe; daily works as a secondary view.
[*]Accumulate through tiers 1–3, hold in tier 4, scale down in tiers 5–6, and treat tier 7 as exit territory.
[*]Built-in alerts fire on entry into each accumulation and distribution tier (gated).
[/list]

[b]█ WHAT MAKES IT ORIGINAL[/b]
BEDROCK is not a single valuation ratio dressed up as an oscillator. The combination is the point: a transparent additive composite over independent metrics, a deliberate collinearity fix that collapses the moving-average family into one bounded bloc, a dual directional-gate system that suppresses the two most common false signals at both extremes without ever blocking the core reads, and sized accumulate/trim output instead of a bare number. Every metric, weight, calibration anchor, and gate threshold is exposed as an input, so the entire model is auditable and tunable — nothing is hidden.

[b]█ NOTES & LIMITATIONS[/b]
BEDROCK is a long-horizon valuation tool, not a precise top/bottom timer and not a short-term trading system. It is designed to keep you positioned in the statistically favorable portion of the cycle, not to nail exact turns. Several display themes are included. This script is for educational purposes only and is not financial advice — size your own risk and do your own research.

## Source Code

````pine
//@version=6
indicator("BEDROCK — Gated Macro Spot Cycle Model", shorttitle="BEDROCK", overlay=false, max_labels_count=500)

// ============================================================================
// BEDROCK — long-term SPOT cycle model (accumulation AND distribution)
// ----------------------------------------------------------------------------
// ------------------------------ Theme & Colors ------------------------------
grpTheme = "Theme & Colors"
themeInput = input.string("Dark (Default)", "Theme Preset", options=["Dark (Default)", "Terminal", "Ocean", "Sunset", "High Contrast", "Custom"], group=grpTheme, tooltip="Select a visual theme for the BEDROCK indicator. 'Custom' unlocks the individual color selectors below.")

isCustom = themeInput == "Custom"

// Custom Color Inputs (only active when 'Custom' is selected)
cGen_in  = input.color(#00e676, "Generational Value",    group=grpTheme, active=isCustom)
cDeep_in = input.color(#26a69a, "Deep Accumulation",     group=grpTheme, active=isCustom)
cAcc_in  = input.color(#9ccc65, "Accumulation",          group=grpTheme, active=isCustom)
cHold_in = input.color(#ffd54f, "Neutral / Hold",        group=grpTheme, active=isCustom)
cTrim_in = input.color(#ffb74d, "Expensive / Trim",      group=grpTheme, active=isCustom)
cEuph_in = input.color(#ff7043, "Euphoria / Distribute", group=grpTheme, active=isCustom)
cTop_in  = input.color(#ef5350, "Cycle Top / Exit",      group=grpTheme, active=isCustom)

// Resolve active colors based on the dropdown
cGen = switch themeInput
    "Terminal"      => #00ff00
    "Ocean"         => #00bfff
    "Sunset"        => #673ab7
    "High Contrast" => #00ffff
    "Custom"        => cGen_in
    => #00e676 // Dark (Default)

cDeep = switch themeInput
    "Terminal"      => #00cc00
    "Ocean"         => #0088cc
    "Sunset"        => #9c27b0
    "High Contrast" => #00ff88
    "Custom"        => cDeep_in
    => #26a69a

cAcc = switch themeInput
    "Terminal"      => #009900
    "Ocean"         => #005599
    "Sunset"        => #e91e63
    "High Contrast" => #ffff00
    "Custom"        => cAcc_in
    => #9ccc65

cHold = switch themeInput
    "Terminal"      => #aaaaaa
    "Ocean"         => #cccccc
    "Sunset"        => #ff9800
    "High Contrast" => #ffffff
    "Custom"        => cHold_in
    => #ffd54f

cTrim = switch themeInput
    "Terminal"      => #ff9900
    "Ocean"         => #ff77a9
    "Sunset"        => #ff5722
    "High Contrast" => #ff8800
    "Custom"        => cTrim_in
    => #ffb74d

cEuph = switch themeInput
    "Terminal"      => #cc0000
    "Ocean"         => #e91e63
    "Sunset"        => #f44336
    "High Contrast" => #ff00ff
    "Custom"        => cEuph_in
    => #ff7043

cTop = switch themeInput
    "Terminal"      => #ff0000
    "Ocean"         => #880e4f
    "Sunset"        => #b71c1c
    "High Contrast" => #ff0000
    "Custom"        => cTop_in
    => #ef5350

// ----------------------------- Component weights ----------------------------
grpW = "Component Weights (auto-renormalized over available parts)"
wMA     = input.float(0.25, "Trailing MA cost-basis bloc (200W/2Y/Mayer)", minval=0, maxval=1, step=0.05, group=grpW, tooltip="Weight of the Trailing Moving Average Cost-Basis (200W, 2Y, Mayer). A core valuation metric built for long-term spot investors.")
wDD     = input.float(0.35, "Drawdown from ATH",  minval=0, maxval=1, step=0.05, group=grpW, tooltip="Weight of the Drawdown from All-Time High metric.")
wRSI    = input.float(0.15, "Weekly RSI",         minval=0, maxval=1, step=0.05, group=grpW, tooltip="Weight of the Weekly RSI Momentum metric.")
useMvrv = input.bool(false, "Enable MVRV Z-score leg", group=grpW, tooltip="Optional on-chain metric. Enables MVRV Z-Score in the multi-factor composite formula.")
wMVRV   = input.float(0.25, "  MVRV Z-score weight", minval=0, maxval=1, step=0.05, group=grpW, tooltip="Weight of the optional MVRV Z-Score leg.")
mvrvSym = input.symbol("",  "  MVRV Z symbol (search 'MVRV'; blank = use source)", group=grpW)
mvrvSrc = input.source(close, "  MVRV Z source fallback (external plot)", group=grpW)

// --------------------------- Calibration anchors ----------------------------
grpC = "Calibration  (deep-value anchor -> expensive anchor)"
m200w_full = input.float(0.85, "200W mult @100", group=grpC, tooltip="Multiplier of the 200W SMA considered deep value (100).")
m200w_zero = input.float(2.20, "200W mult @0",   group=grpC, tooltip="Multiplier of the 200W SMA considered expensive (0).")
m2y_full   = input.float(0.85, "2Y mult @100",   group=grpC)
m2y_zero   = input.float(2.50, "2Y mult @0",     group=grpC)
mayer_full = input.float(0.55, "Mayer @100",     group=grpC)
mayer_zero = input.float(2.20, "Mayer @0",       group=grpC)
dd_full    = input.float(0.80, "Drawdown @100",  group=grpC)
dd_zero    = input.float(0.20, "Drawdown @0",    group=grpC)
rsi_full   = input.float(30.0, "Weekly RSI @100",group=grpC)
rsi_zero   = input.float(55.0, "Weekly RSI @0",  group=grpC)
mvrv_full  = input.float(0.10, "MVRV Z @100",    group=grpC)
mvrv_zero  = input.float(4.00, "MVRV Z @0",      group=grpC)

// -------------------------- Capitulation gate (bottom) ----------------------
grpG = "Capitulation Gate (caps tier toward middle; never blocks Accumulation)"
useGate      = input.bool(true,  "Enforce capitulation gate", group=grpG, tooltip="Caps the tier down toward Accumulation to prevent premature 'Generational' signals during initial sell-offs.")
gateDD_gen   = input.float(0.65, "GENERATIONAL requires drawdown ≥", step=0.01, group=grpG, tooltip="Requires at least this % drawdown from ATH to unlock Generational Value (Tier 1).")
gate200w_deep= input.float(1.00, "DEEP requires 200W mult ≤",        step=0.01, group=grpG, tooltip="Requires price to be at or below the 200W SMA to unlock Deep Accumulation (Tier 2).")
gateMVRV_gen = input.float(0.10, "GENERATIONAL also unlocks if MVRV Z ≤", step=0.05, group=grpG)

// -------------------------- Distribution gate (top) -------------------------
grpD = "Euphoria Gate (caps tier toward middle; never blocks Trim)"
useTopGate   = input.bool(true, "Enforce euphoria gate", group=grpD, tooltip="Requires independent overheating signs (Mayer, RSI, 200W, MVRV) to unlock Euphoria/Top tiers.")
topMult200w  = input.float(2.00, "Euphoria sign: 200W mult ≥", step=0.05, group=grpD)
topRSI       = input.float(70.0, "Euphoria sign: Weekly RSI ≥", step=1, group=grpD)
topMayer     = input.float(2.20, "Euphoria sign: Mayer ≥",      step=0.05, group=grpD)
topMVRV      = input.float(5.00, "Euphoria sign: MVRV Z ≥",     step=0.25, group=grpD)

// -------------------------------- Tiers -------------------------------------
grpT = "Tier Ladder & Display"
tGen   = input.float(80, "Generational Value ≥", group=grpT, tooltip="Generational Value (80-100): Extremely rare value. Aggressive accumulation recommended.")
tDeep  = input.float(65, "Deep Accumulation ≥",  group=grpT, tooltip="Deep Accumulation (65-80): Excellent value. Strong accumulation zone.")
tAcc   = input.float(50, "Accumulation ≥",       group=grpT, tooltip="Accumulation (50-65): Good value. Continue building positions.")
tHold  = input.float(40, "Neutral / Hold ≥",     group=grpT, tooltip="Neutral / Hold (40-50): Fairly valued. Hold existing positions.")
tTrim  = input.float(25, "Expensive / Trim ≥",   group=grpT, tooltip="Expensive / Trim (25-40): Above fair value. Start reducing exposure.")
tEuph  = input.float(12, "Euphoria / Distribute ≥ (below = Cycle Top)", group=grpT, tooltip="Euphoria / Distribute (12-25): High risk. Distribute and protect profits.\n\nCycle Top (0-12): Extreme euphoria. High probability macro top.")
showBG = input.bool(true,  "Color background by tier", group=grpT)
showTbl= input.bool(true,  "Show data table",          group=grpT)

// ----------------- Linear map (handles increasing & decreasing) -------------
mapScore(float x, float x100, float x0) =>
    na(x) ? na : math.max(0.0, math.min(100.0, (x - x0) / (x100 - x0) * 100.0))

// -------------------- Source metrics (TF-robust security) -------------------
sym     = syminfo.tickerid
sma200d = request.security(sym, "1D", ta.sma(close, 200), lookahead=barmerge.lookahead_off)
sma200w = request.security(sym, "1W", ta.sma(close, 200), lookahead=barmerge.lookahead_off)
sma2y   = request.security(sym, "1D", ta.sma(close, 730), lookahead=barmerge.lookahead_off)
wrsiVal = request.security(sym, "1W", ta.rsi(close, 14),  lookahead=barmerge.lookahead_off)

var float ath = 0.0
ath := math.max(ath, high)

px        = close
mult200w  = na(sma200w) or sma200w == 0 ? na : px / sma200w
mult2y    = na(sma2y)   or sma2y   == 0 ? na : px / sma2y
mayer     = na(sma200d) or sma200d == 0 ? na : px / sma200d
ddFromAth = ath == 0 ? na : (ath - px) / ath

mvrvSymUsed = str.length(mvrvSym) > 0
reqSym      = mvrvSymUsed ? mvrvSym : syminfo.tickerid
mvrvFromSym = request.security(reqSym, "1D", close, lookahead=barmerge.lookahead_off, ignore_invalid_symbol=true)
mvrvVal     = not useMvrv ? na : mvrvSymUsed ? mvrvFromSym : mvrvSrc
mvrvOn      = useMvrv and not na(mvrvVal)

// ----------------------- Sub-scores + collapsed MA bloc ---------------------
s200w  = mapScore(mult200w,  m200w_full, m200w_zero)
s2y    = mapScore(mult2y,    m2y_full,   m2y_zero)
smayer = mapScore(mayer,     mayer_full, mayer_zero)
sdd    = mapScore(ddFromAth, dd_full,    dd_zero)
srsi   = mapScore(wrsiVal,   rsi_full,   rsi_zero)
smvrv  = mvrvOn ? mapScore(mvrvVal, mvrv_full, mvrv_zero) : na

maCount  = (na(s200w) ? 0 : 1) + (na(s2y) ? 0 : 1) + (na(smayer) ? 0 : 1)
maSum    = nz(s200w) + nz(s2y) + nz(smayer)
maFactor = maCount > 0 ? maSum / maCount : na

// ----------------- Weighted composite (renormalize over parts) --------------
cwMA   = na(maFactor) ? 0.0 : wMA
cwDD   = na(sdd)      ? 0.0 : wDD
cwRSI  = na(srsi)     ? 0.0 : wRSI
cwMVRV = na(smvrv)    ? 0.0 : wMVRV

sumW  = cwMA + cwDD + cwRSI + cwMVRV
sumWS = nz(maFactor)*cwMA + nz(sdd)*cwDD + nz(srsi)*cwRSI + nz(smvrv)*cwMVRV
composite = sumW > 0 ? sumWS / sumW : na

// ---------------------------- Gate eligibility ------------------------------
genEligible  = not useGate or (not na(ddFromAth) and ddFromAth >= gateDD_gen) or (mvrvOn and mvrvVal <= gateMVRV_gen)
deepEligible = not useGate or genEligible or (not na(mult200w) and mult200w <= gate200w_deep)
maxTier      = genEligible ? 6 : deepEligible ? 5 : 4

euphSigns = (not na(mult200w) and mult200w >= topMult200w ? 1 : 0) + (not na(wrsiVal) and wrsiVal >= topRSI ? 1 : 0) + (not na(mayer) and mayer >= topMayer ? 1 : 0) + (mvrvOn and mvrvVal >= topMVRV ? 1 : 0)
euphEligible = not useTopGate or euphSigns >= 1
topEligible  = not useTopGate or euphSigns >= 2
minTier      = topEligible ? 0 : euphEligible ? 1 : 2

// --------------------------------- Tier -------------------------------------
rawTier = na(composite) ? -1 : composite >= tGen ? 6 : composite >= tDeep ? 5 : composite >= tAcc ? 4 : composite >= tHold ? 3 : composite >= tTrim ? 2 : composite >= tEuph ? 1 : 0
tierIdx = rawTier < 0 ? -1 : math.max(math.min(rawTier, maxTier), minTier)

tierTxt = tierIdx==6?"GENERATIONAL VALUE":tierIdx==5?"DEEP ACCUMULATION":tierIdx==4?"ACCUMULATION":tierIdx==3?"NEUTRAL / HOLD":tierIdx==2?"EXPENSIVE / TRIM":tierIdx==1?"EUPHORIA / DISTRIBUTE":tierIdx==0?"CYCLE TOP / EXIT":"n/a"
col = tierIdx==6?cGen:tierIdx==5?cDeep:tierIdx==4?cAcc:tierIdx==3?cHold:tierIdx==2?cTrim:tierIdx==1?cEuph:tierIdx==0?cTop:color.gray

// --------------------- Action weights (DCA in / Trim out) -------------------
denomB  = math.max(1.0, 90.0 - tAcc)
dcaCap  = tierIdx>=6?3.0:tierIdx>=5?2.0:tierIdx>=4?1.5:0.0
dcaW    = na(composite) ? na : composite < tAcc ? 0.0 : math.min(dcaCap, 1.0 + (composite - tAcc)/denomB*2.0)

denomT  = math.max(1.0, tTrim)
trimCap = tierIdx<=0?3.0:tierIdx<=1?2.0:tierIdx==2?1.5:0.0
trimW   = na(composite) ? na : (composite > tTrim or tierIdx>=3) ? 0.0 : math.min(trimCap, 1.0 + (tTrim - composite)/denomT*2.0)

actionTxt = na(composite) ? "n/a" : nz(dcaW)>0 ? ("DCA " + str.tostring(dcaW,"#.#") + "x") : nz(trimW)>0 ? ("TRIM " + str.tostring(trimW,"#.#") + "x") : "HOLD"

// ----------------------------------- Plot -----------------------------------
plot(composite, "BEDROCK Composite", color=col, linewidth=2)
plot(tGen,  "Generational Threshold", color=color.new(cGen, 50))
plot(tDeep, "Deep Accum Threshold",   color=color.new(cDeep, 50))
plot(tAcc,  "Accumulation Threshold", color=color.new(cAcc, 50))
plot(tHold, "Hold Threshold",         color=color.new(cHold, 60))
plot(tTrim, "Trim Threshold",         color=color.new(cTrim, 50))
plot(tEuph, "Euphoria Threshold",     color=color.new(cEuph, 50))
bgcolor(showBG and tierIdx >= 0 ? color.new(col, 88) : na, title="Tier background")

// ------------------- Discrete events (buy side, gated) ----------------------
enteredAccum = ta.crossover(composite, tAcc)
enteredDeep  = ta.crossover(composite, tDeep) and deepEligible
enteredGen   = ta.crossover(composite, tGen)  and genEligible
plotshape(enteredAccum, "Entered Accumulation", shape.triangleup, location.bottom, color.new(cAcc, 0), size=size.small)
plotshape(enteredDeep,  "Entered Deep Accum",   shape.triangleup, location.bottom, color.new(cDeep, 0), size=size.small)
plotshape(enteredGen,   "Generational Buy",     shape.triangleup, location.bottom, color.new(cGen, 0), size=size.normal)

// ------------------- Discrete events (sell side, gated) ---------------------
crossDown12  = ta.crossunder(composite, tEuph)
enteredTrim  = ta.crossunder(composite, tTrim)
enteredTop   = crossDown12 and topEligible
enteredEuph  = crossDown12 and euphEligible and not topEligible
plotshape(enteredTrim, "Entered Trim",      shape.triangledown, location.top, color.new(cTrim, 0), size=size.small)
plotshape(enteredEuph, "Entered Euphoria",  shape.triangledown, location.top, color.new(cEuph, 0), size=size.small)
plotshape(enteredTop,  "Cycle Top / Exit",  shape.triangledown, location.top, color.new(cTop, 0), size=size.normal)

// ----------------------------------- Alerts ---------------------------------
alertcondition(enteredAccum, "BEDROCK: Accumulation entered",   "BEDROCK crossed into ACCUMULATION — DCA on.")
alertcondition(enteredDeep,  "BEDROCK: Deep accumulation",      "BEDROCK DEEP ACCUMULATION (gate passed) — size up.")
alertcondition(enteredGen,   "BEDROCK: Generational",           "BEDROCK GENERATIONAL VALUE (capitulation gate passed).")
alertcondition(enteredTrim,  "BEDROCK: Trim zone",              "BEDROCK crossed into EXPENSIVE / TRIM — scale out begins.")
alertcondition(enteredEuph,  "BEDROCK: Euphoria / Distribute",  "BEDROCK EUPHORIA (euphoria gate passed) — distribute.")
alertcondition(enteredTop,   "BEDROCK: Cycle Top / Exit",       "BEDROCK CYCLE TOP (euphoria gate strong) — exit.")

// ---------------------------------- Table -----------------------------------
// Premium Glass Aesthetic: Removed internal borders, ultra-subtle frame, high transparency
var table t = table.new(position.bottom_right, 2, 14, border_width=0, frame_width=1, frame_color=color.new(color.white, 90))

f2(float x) => na(x) ? "n/a" : str.tostring(x, "#.##")
f0(float x) => na(x) ? "n/a" : str.tostring(x, "#")
botGateTxt = not useGate    ? "off" : genEligible ? "PASS (Gen)" : deepEligible ? "PASS (Deep)" : "CAPPED→Accum"
topGateTxt = not useTopGate ? "off" : topEligible ? "STRONG (Top)" : euphEligible ? "WARN (Euph)" : "clear"

if showTbl and barstate.islast
    // See-through variables (75-85 range allows the chart grid and candles to bleed through cleanly)
    color bgH     = color.new(#000000, 75)       
    color bgR1    = color.new(#131722, 85)       
    color bgR2    = color.new(#1e222d, 82)       
    color lblCol  = color.new(color.white, 30)   

    table.cell(t, 0, 0, "BEDROCK", text_color=color.white, bgcolor=bgH, text_halign=text.align_left, text_formatting=text.format_bold)
    table.cell(t, 1, 0, syminfo.ticker, text_color=color.white, bgcolor=bgH, text_halign=text.align_right, text_formatting=text.format_bold)
    
    // Tier background also made highly transparent to match the sleek vibe
    table.cell(t, 0, 1, "Tier", text_color=lblCol, bgcolor=bgR1, text_halign=text.align_left)
    table.cell(t, 1, 1, tierTxt, text_color=color.white, bgcolor=color.new(col, 80), text_halign=text.align_right, text_formatting=text.format_bold)
    
    table.cell(t, 0, 2, "Composite", text_color=lblCol, bgcolor=bgR2, text_halign=text.align_left)
    table.cell(t, 1, 2, f0(composite), text_color=col, bgcolor=bgR2, text_halign=text.align_right, text_formatting=text.format_bold)
    
    table.cell(t, 0, 3, "Action", text_color=lblCol, bgcolor=bgR1, text_halign=text.align_left)
    table.cell(t, 1, 3, actionTxt, text_color=col, bgcolor=bgR1, text_halign=text.align_right, text_formatting=text.format_bold)
    
    table.cell(t, 0, 4, "Capit. gate", text_color=lblCol, bgcolor=bgR2, text_halign=text.align_left)
    table.cell(t, 1, 4, botGateTxt, text_color = botGateTxt == "CAPPED→Accum" ? cTop : color.white, bgcolor=bgR2, text_halign=text.align_right)
    
    table.cell(t, 0, 5, "Euphoria gate", text_color=lblCol, bgcolor=bgR1, text_halign=text.align_left)
    table.cell(t, 1, 5, topGateTxt, text_color = topGateTxt == "STRONG (Top)" ? cTop : color.white, bgcolor=bgR1, text_halign=text.align_right)
    
    table.cell(t, 0, 6, "MA bloc", text_color=lblCol, bgcolor=bgR2, text_halign=text.align_left)
    table.cell(t, 1, 6, f0(maFactor), text_color=color.white, bgcolor=bgR2, text_halign=text.align_right)
    
    table.cell(t, 0, 7, "200W mult", text_color=lblCol, bgcolor=bgR1, text_halign=text.align_left)
    table.cell(t, 1, 7, na(mult200w) ? "n/a (history)" : f2(mult200w), text_color=color.white, bgcolor=bgR1, text_halign=text.align_right)
    
    table.cell(t, 0, 8, "2Y mult", text_color=lblCol, bgcolor=bgR2, text_halign=text.align_left)
    table.cell(t, 1, 8, na(mult2y) ? "n/a (history)" : f2(mult2y), text_color=color.white, bgcolor=bgR2, text_halign=text.align_right)
    
    table.cell(t, 0, 9, "Mayer (200D)", text_color=lblCol, bgcolor=bgR1, text_halign=text.align_left)
    table.cell(t, 1, 9, f2(mayer), text_color=color.white, bgcolor=bgR1, text_halign=text.align_right)
    
    table.cell(t, 0, 10, "Off ATH", text_color=lblCol, bgcolor=bgR2, text_halign=text.align_left)
    table.cell(t, 1, 10, na(ddFromAth) ? "n/a" : str.tostring(ddFromAth * 100, "#") + "%", text_color=color.white, bgcolor=bgR2, text_halign=text.align_right)
    
    table.cell(t, 0, 11, "Weekly RSI", text_color=lblCol, bgcolor=bgR1, text_halign=text.align_left)
    table.cell(t, 1, 11, f0(wrsiVal), text_color=color.white, bgcolor=bgR1, text_halign=text.align_right)
    
    table.cell(t, 0, 12, "MVRV Z", text_color=lblCol, bgcolor=bgR2, text_halign=text.align_left)
    table.cell(t, 1, 12, mvrvOn ? f2(mvrvVal) : (useMvrv ? "no feed" : "off"), text_color=color.white, bgcolor=bgR2, text_halign=text.align_right)
    
    table.cell(t, 0, 13, "", bgcolor=bgR1)
    table.cell(t, 1, 13, "", bgcolor=bgR1)
````
