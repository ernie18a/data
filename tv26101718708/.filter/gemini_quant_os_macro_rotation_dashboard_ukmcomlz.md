# Gemini Quant OS - Macro Rotation Dashboard 

- url: https://www.tradingview.com/script/uKmcOMlz/
- type: indicator
- pine_id: PUB;0007cfa7fe5a446e9004c76758be8e54
- version: 1.0

## Description

Overview

Gemini Quant OS — Macro Rotation is a macro market monitoring framework designed to help traders observe broad market conditions, capital rotation behavior, and intermarket relationships.

This script is part of the broader Gemini Quant OS ecosystem.


---

Core Concepts

The framework focuses on macro-level market behavior rather than individual trade signals.

The model monitors:

capital rotation

trend structure

volatility conditions

risk sentiment

intermarket relationships

macro directional bias


The dashboard is designed to provide a broader overview of market conditions across different asset classes.


---

Features

Macro market dashboard

Capital rotation monitoring

Risk sentiment framework

Multi-asset observation

Trend condition analysis

Intermarket structure monitoring



---

Best Use Cases

Best suited for:

macro analysis

portfolio observation

intermarket monitoring

directional bias analysis

higher timeframe market structure review



---

Notes

This script is designed for educational and analytical purposes only.

Not financial advice.

## Source Code

````pine
//@version=6
indicator("Gemini Macro Rotation Dashboard ", overlay=true, max_labels_count=500)

//====================================================
// Fixed symbols (no input.symbol() to avoid v5 issues)
//====================================================
sym2y = "TVC:US02Y"
sym10y = "TVC:US10Y"
symSPX = "SP:SPX"
symXAU = "OANDA:XAUUSD" // If no data, try "TVC:GOLD" or your broker's XAUUSD

//==============================
// Inputs
//==============================
lenTrend = input.int(20, "Macro trend lookback (bars)", minval=5)
lenDD = input.int(252, "SPX drawdown lookback (bars)", minval=50)

flatBand = input.int(10, "Flat band (bps)", minval=1)
rotPosBps = input.int(20, "Rotation confirm: spread > (bps)", minval=1)
sprRiseBps = input.int(30, "Rotation confirm: spread rising (bps)", minval=1)
bad10yReb = input.int(40, "Bond risk: 10Y rebound (bps)", minval=1)

ddWarn = input.float(15.0, "Portfolio guard: SPX DD warning %", minval=1)
ddHard = input.float(20.0, "Portfolio guard: SPX DD hard %", minval=1)

xauMomLen = input.int(60, "XAU momentum lookback", minval=10)
xauHedgeOn = input.bool(true, "Enable XAU hedge tilt")
showLabels = input.bool(true, "Show phase change labels")

//==============================
// Data
//==============================
y2 = request.security(sym2y, timeframe.period, close)
y10 = request.security(sym10y, timeframe.period, close)
spx = request.security(symSPX, timeframe.period, close)
xau = request.security(symXAU, timeframe.period, close)

//==============================
// Yield curve (2Y-10Y)
//==============================
spread_bps = (y10 - y2) * 100.0

d2_bps = (y2 - y2[lenTrend]) * 100.0
d10_bps = (y10 - y10[lenTrend]) * 100.0
dSpr_bps = spread_bps - spread_bps[lenTrend]

// Regime basics
isInverted = spread_bps < -flatBand
isFlat = math.abs(spread_bps) <= flatBand
isSteepPos = spread_bps > rotPosBps

// Good vs Bad steepening
goodSteepen = (dSpr_bps > sprRiseBps) and (d2_bps < 0) and (d10_bps <= 0 or math.abs(d10_bps) < math.abs(d2_bps))
badSteepen = (dSpr_bps > sprRiseBps) and (d10_bps > 0) and (math.abs(d10_bps) >= math.abs(d2_bps) * 0.6)

bondRisk = badSteepen or (d10_bps > bad10yReb)

//==============================
// Phase logic (robust & simple)
//==============================
phase1 = isInverted
phase2 = (isFlat or isInverted) and (dSpr_bps > sprRiseBps) // curve repairing → build bonds
phase3 = isSteepPos and goodSteepen // rotate into equities
phase4 = bondRisk // reduce duration / tighten risk

string phase =
     phase4 ? "PHASE 4 (Risk): Bad steepening / 10Y rebound" :
     phase3 ? "PHASE 3 (Rotate): Bonds -> SPX" :
     phase2 ? "PHASE 2 (Build): Add Bonds" :
     phase1 ? "PHASE 1 (Defensive): Inverted" :
              "NEUTRAL"

//==============================
// SPX Drawdown Guard
//==============================
spx_peak = ta.highest(spx, lenDD)
spx_dd = (spx - spx_peak) / spx_peak * 100.0

dd_warning = spx_dd <= -ddWarn
dd_hard = spx_dd <= -ddHard

//==============================
// XAU Hedge Signal (Momentum)
//==============================
xau_mom = (xau - xau[xauMomLen]) / xau[xauMomLen] * 100.0
xau_up = xau_mom > 0

wantHedge = xauHedgeOn and (phase1 or phase4 or dd_warning) and xau_up

//==============================
// Allocation Engine (suggested weights)
// Buckets: Bonds / SPX / XAU / Cash
//==============================
float wB = na
float wE = na
float wG = na
float wC = na

// Base by phase (aggressive default)
if phase1
    wB := 0.30
    wE := 0.20
    wG := 0.30
    wC := 0.20
else if phase2
    wB := 0.55
    wE := 0.20
    wG := 0.15
    wC := 0.10
else if phase3
    wB := 0.30
    wE := 0.55
    wG := 0.10
    wC := 0.05
else if phase4
    wB := 0.20
    wE := 0.35
    wG := 0.25
    wC := 0.20
else
    wB := 0.35
    wE := 0.35
    wG := 0.15
    wC := 0.15

// Drawdown overrides
if dd_warning and not dd_hard
    // reduce equity 15%, add cash 10%, add gold 5%
    wE := math.max(wE - 0.15, 0.05)
    wC := math.min(wC + 0.10, 0.50)
    wG := math.min(wG + 0.05, 0.50)

if dd_hard
    // hard risk-off
    wE := 0.20
    wB := math.min(wB, 0.30)
    wG := 0.30
    wC := 0.20

// Hedge tilt
if wantHedge
    shift = 0.05
    wE := math.max(wE - shift, 0.05)
    wG := math.min(wG + shift, 0.50)

// Normalize
sumW = wB + wE + wG + wC
wB := wB / sumW
wE := wE / sumW
wG := wG / sumW
wC := wC / sumW

fmtPct(x) => str.tostring(x * 100.0, "#.0") + "%"

//==============================
// Plots
//==============================
plot(spread_bps, "10Y-2Y Spread (bps)", color=color.white, linewidth=2)
hline(0, "Zero", color=color.new(color.gray, 70))

plot(spx_dd, "SPX Drawdown (%)", color=color.new(color.red, 0), linewidth=1)
hline(-ddWarn, "DD Warning", color=color.new(color.red, 70))
hline(-ddHard, "DD Hard", color=color.new(color.red, 70))

plot(xau_mom, "XAU Momentum (%)", color=color.new(color.yellow, 0), linewidth=1)

//==============================
// Dashboard Table
//==============================
var table t = table.new(position.top_right, 1, 10, border_width=1)

fcell(_r, _txt) =>
    table.cell(t, 0, _r, _txt, text_color=color.white, bgcolor=color.new(color.black, 0))

if barstate.islast
    // v5 requires coordinates
    table.clear(t, 0, 0)
    fcell(0, "Macro Rotation Dashboard")
    fcell(1, "Phase: " + phase)
    fcell(2, "2Y: " + str.tostring(y2, "#.###") + "% 10Y: " + str.tostring(y10, "#.###") + "%")
    fcell(3, "Spread: " + str.tostring(spread_bps, "#") + " bps ΔSpread: " + str.tostring(dSpr_bps, "#") + " bps")
    fcell(4, "SPX DD: " + str.tostring(spx_dd, "#.##") + "% (" + (dd_hard ? "HARD" : dd_warning ? "WARN" : "OK") + ")")
    fcell(5, "XAU Mom(" + str.tostring(xauMomLen) + "): " + str.tostring(xau_mom, "#.##") + "% (" + (xau_up ? "UP" : "DOWN") + ")")
    fcell(6, "Hedge: " + (wantHedge ? "ON (Risk + XAU↑)" : "OFF/Neutral"))
    fcell(7, "Suggested Allocation")
    fcell(8, "Bonds: " + fmtPct(wB) + " | SPX: " + fmtPct(wE))
    fcell(9, "XAU: " + fmtPct(wG) + " | Cash: " + fmtPct(wC))

//==============================
// Phase change label
//==============================
var string prevPhase = na
phaseChanged = showLabels and (phase != prevPhase)

if phaseChanged
    label.new(bar_index, spread_bps,
      phase + "\nAlloc: B " + fmtPct(wB) + " / SPX " + fmtPct(wE) + " / XAU " + fmtPct(wG) + " / Cash " + fmtPct(wC),
      style=label.style_label_up, textcolor=color.white, color=color.new(color.black, 0))

prevPhase := phase

//==============================
// Alerts
//==============================
alertcondition(phase2, "Build: Add Bonds", "Phase 2: curve repairing → add bonds gradually.")
alertcondition(phase3, "Rotate: Bonds -> SPX", "Phase 3: good steepening → rotate gradually into SPX.")
alertcondition(phase4, "Risk: Reduce Duration", "Phase 4: bad steepening / 10Y rebound → reduce duration, tighten risk.")
alertcondition(dd_warning, "SPX Drawdown Warning", "SPX drawdown breached warning threshold → reduce equity, add cash/hedge.")
alertcondition(dd_hard, "SPX Drawdown HARD", "SPX drawdown breached HARD threshold → risk-off protocol.")
alertcondition(wantHedge, "XAU Hedge ON", "Risk regime + XAU momentum positive → enable/increase gold hedge.")
````
