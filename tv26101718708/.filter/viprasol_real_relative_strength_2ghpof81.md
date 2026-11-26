# [Viprasol] Real Relative Strength

- url: https://www.tradingview.com/script/2ghPOf81-Viprasol-Real-Relative-Strength/
- type: indicator
- pine_id: PUB;459f4be3172b455693de28fe4d269205
- version: 1.0

## Description

Overview

This indicator is based on the open-source "Real Relative Strength" (RRS) concept, which measures how an asset is performing against a benchmark after normalising for volatility. The original plots ATR-normalised relative momentum versus a benchmark (e.g. SPY) with zero-cross arrows and strong/weak zones. This version keeps that calculation and adds RRS/price divergence detection, a second-benchmark agreement filter, a signal cooldown, an RRS acceleration read, and a compact dashboard.

How It Works

Real Relative Strength (from original concept):
Relative momentum = (asset momentum − benchmark momentum) / average ATR × multiplier, where momentum is close − close[length] for both the asset and the benchmark, and the divisor is the average of the asset and benchmark ATR. The result is smoothed with an EMA. Positive = the asset is outperforming the benchmark on a volatility-adjusted basis; negative = underperforming. Strong/weak zones mark RRS beyond a configurable level.

Divergence (new):
Using pivots on the smoothed RRS, a bearish divergence is flagged when RRS makes a lower pivot high while price makes a higher high; bullish when RRS makes a higher pivot low while price makes a lower low.

Second-Benchmark Agreement (new):
Optionally compute RRS against a second benchmark and only confirm a zero-cross when both agree in sign — a confluence filter against single-benchmark noise.

Signal Cooldown (new):
A minimum bar gap between confirmed zero-cross signals to prevent clustering.

RRS Acceleration (new):
The bar-to-bar change in smoothed RRS, shown as a rising/falling momentum read in the dashboard.

What Is Original (Viprasol Additions)

1. RRS/price divergence detection (regular bullish and bearish).
2. Optional second-benchmark agreement filter on zero-cross signals.
3. Signal cooldown.
4. RRS acceleration (momentum-of-RRS) state.
5. Compact relative-strength dashboard.

Key Features

From the Original:
- ATR-normalised relative strength vs a benchmark
- EMA smoothing, zero-cross arrows, strong/weak zones, extreme background tint

Added in This Version (Viprasol):
- Divergence detection, dual-benchmark agreement, cooldown, acceleration read, dashboard
- Six alerts with dynamic {{ticker}}/{{close}}/{{interval}} messages

How to Use

1. Set the benchmark to match your asset class (SPY/QQQ stocks, IWM small-caps, BTCUSD crypto).
2. Above zero (aqua/green area) = outperforming; below zero (red area) = underperforming.
3. Zero-cross arrows mark fresh shifts; circles mark divergences; the strong/weak zones flag standout strength.

Recommended Starting Points:
- Intraday (15m-1H): Length 10-14
- Swing (Daily/4H): Length 14-20
- Use dual-benchmark agreement for higher-conviction crosses

These are starting points only — backtest and adjust before trading live.

Settings

Core: benchmark symbol, momentum length, ATR multiplier, RRS smoothing.
Confluence & Filters: 2nd-benchmark agreement (+ symbol), signal cooldown, strong/weak zone level.
Divergence: detect divergence toggle, pivot length.
Visuals: zero-cross arrows, RRS line, RRS area.
Dashboard: toggle and position.

Alerts

1. Bullish Cross — now outperforming the benchmark
2. Bearish Cross — now underperforming the benchmark
3. Strong Outperformance — RRS beyond the strong level
4. Strong Underperformance — RRS below the weak level
5. Bullish Divergence — RRS/price bullish divergence
6. Bearish Divergence — RRS/price bearish divergence

All alerts include {{ticker}}, {{close}}, and {{interval}}.

Limitations & Disclaimer

- RRS uses request.security for the benchmark; benchmark data quality and session alignment affect readings, especially across asset classes/exchanges.
- Divergence uses confirmed pivots, which lag by the pivot length.
- Relative strength shows leadership, not absolute direction — a rising RRS in a falling market only means the asset is falling less.
- Past performance does not guarantee future results. This indicator is for educational purposes only and is not financial advice. Always use proper risk management and test on historical data before trading live.

Credits & Attribution

Based on the open-source "Real Relative Strength" concept (community / SMB-style), which provided the ATR-normalised relative-momentum calculation, EMA smoothing, zero-cross signals, and strong/weak zones. Added by Viprasol: RRS/price divergence detection, optional second-benchmark agreement, signal cooldown, RRS acceleration, and the dashboard.

Published open-source per TradingView House Rules.

## Source Code

````pine
// This Pine Script™ v6 indicator is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/
// (c) Viprasol
//
// Based on the open-source "Real Relative Strength" concept (community / SMB-style),
// which measures an asset's ATR-normalised momentum against a benchmark.

//@version=6
indicator(
    title      = "[Viprasol] Real Relative Strength",
    shorttitle = "VP - RRS",
    overlay    = false,
    scale      = scale.right,
    max_labels_count = 200
)

// ══════════════════════════════════════════════════════════════
// Constants
// ══════════════════════════════════════════════════════════════

const color BULL_COL  = #00ffaa
const color BEAR_COL  = #ff3d71
const color LINE_COL  = #1E90FF
const color PANEL_BG     = #111725
const color PANEL_HEADER = #18233a
const color PANEL_BORDER = #000000
const color PANEL_TEXT   = #e6e9f0
const color PANEL_MUTED  = #8a93a6

// ══════════════════════════════════════════════════════════════
// Inputs
// ══════════════════════════════════════════════════════════════

string GRP_CORE = "Core"
string GRP_CONF = "Confluence & Filters (Viprasol)"
string GRP_DIV  = "Divergence (Viprasol)"
string GRP_VIS  = "Visuals"
string GRP_DASH = "Dashboard"

benchInput = input.symbol("SPY", "Benchmark Symbol", group = GRP_CORE,
     tooltip = "Stocks → SPY or QQQ | Small-caps → IWM | Crypto → BTCUSD/ETHUSD. Match the asset class you trade.")
lenInput   = input.int(14, "Length (Momentum Period)", minval = 5, maxval = 50, group = GRP_CORE,
     tooltip = "Bars to measure momentum over. Swing 14-20 | Intraday 10-14 | Weekly 8-13.")
multInput  = input.float(1.0, "ATR Multiplier", step = 0.1, minval = 0.5, maxval = 3.0, group = GRP_CORE,
     tooltip = "Volatility sensitivity. 1.0 standard | >1 more signals | <1 fewer.")
smoothInput = input.int(3, "RRS Smoothing", minval = 1, maxval = 20, group = GRP_CORE,
     tooltip = "EMA smoothing applied to raw RRS.")

useDualInput  = input.bool(false, "Require 2nd Benchmark Agreement", group = GRP_CONF,
     tooltip = "Only confirm a cross when RRS vs a second benchmark agrees in sign.")
bench2Input   = input.symbol("QQQ", "2nd Benchmark", group = GRP_CONF, active = useDualInput)
cooldownInput = input.int(5, "Signal Cooldown (bars)", minval = 0, maxval = 100, group = GRP_CONF,
     tooltip = "Minimum bars between confirmed zero-cross signals. 0 = disabled.")
strongLevelInput = input.float(2.0, "Strong/Weak Zone Level", minval = 0.5, step = 0.5, group = GRP_CONF,
     tooltip = "RRS magnitude that counts as strong outperformance / underperformance.")

useDivInput = input.bool(true, "Detect RRS/Price Divergence", group = GRP_DIV)
divPivotInput = input.int(5, "Divergence Pivot Length", minval = 2, maxval = 20, group = GRP_DIV, active = useDivInput)

showArrowsInput = input.bool(true, "Show Zero-Cross Arrows", group = GRP_VIS)
showLineInput   = input.bool(true, "Show RRS Line", group = GRP_VIS)
showAreaInput   = input.bool(true, "Show RRS Area", group = GRP_VIS)

showTableInput = input.bool(true, "Show Dashboard", group = GRP_DASH)
dashPosInput   = input.string("Top Right", "Dashboard Position", options = ["Top Right", "Top Left", "Bottom Right", "Bottom Left"], group = GRP_DASH)

// ══════════════════════════════════════════════════════════════
// Core RRS calculation  [from original concept]
// ══════════════════════════════════════════════════════════════

rrsFor(string sym) =>
    float bClose = request.security(sym, timeframe.period, close, lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
    float bATR   = request.security(sym, timeframe.period, ta.atr(lenInput), lookahead = barmerge.lookahead_off, gaps = barmerge.gaps_off)
    float mATR   = ta.atr(lenInput)
    float aAvg   = math.avg(mATR, nz(bATR, mATR)) * multInput
    aAvg := nz(aAvg, mATR)
    aAvg := aAvg <= 0 ? mATR : aAvg
    float mMom = close - close[lenInput]
    float bMom = bClose - bClose[lenInput]
    (mMom - bMom) / aAvg

float rrsRaw = rrsFor(benchInput)
float rrsMA  = ta.ema(rrsRaw, smoothInput)
float rrsPlot = math.max(math.min(rrsMA, 20), -20)

// [new] RRS acceleration (momentum of RRS)
float rrsAccel = ta.change(rrsMA)

// [new] second-benchmark agreement
float rrs2 = useDualInput ? ta.ema(rrsFor(bench2Input), smoothInput) : na
bool  dualBullOk = not useDualInput or (not na(rrs2) and rrs2 > 0)
bool  dualBearOk = not useDualInput or (not na(rrs2) and rrs2 < 0)

// ══════════════════════════════════════════════════════════════
// Signals  [original cross + Viprasol cooldown/confluence]
// ══════════════════════════════════════════════════════════════

bool crossUp   = ta.crossover(rrsMA, 0)
bool crossDown = ta.crossunder(rrsMA, 0)

var int lastSigBar = -100000
bool coolOk = cooldownInput == 0 or (bar_index - lastSigBar) >= cooldownInput

bool bull = crossUp   and dualBullOk and coolOk
bool bear = crossDown and dualBearOk and coolOk
if bull or bear
    lastSigBar := bar_index

// Strength state
bool strongOut = rrsMA >=  strongLevelInput
bool strongUnd = rrsMA <= -strongLevelInput

// ══════════════════════════════════════════════════════════════
// Divergence (RRS vs price)  [new — Viprasol]
// ══════════════════════════════════════════════════════════════

float phRRS = ta.pivothigh(rrsMA, divPivotInput, divPivotInput)
float plRRS = ta.pivotlow(rrsMA, divPivotInput, divPivotInput)

var float lastPH = na
var float lastPHprice = na
var float lastPL = na
var float lastPLprice = na
bool bearDiv = false
bool bullDiv = false

if useDivInput and not na(phRRS)
    float priceAtPivot = high[divPivotInput]
    if not na(lastPH) and phRRS < lastPH and priceAtPivot > lastPHprice
        bearDiv := true
    lastPH := phRRS
    lastPHprice := priceAtPivot
if useDivInput and not na(plRRS)
    float priceAtPivot = low[divPivotInput]
    if not na(lastPL) and plRRS > lastPL and priceAtPivot < lastPLprice
        bullDiv := true
    lastPL := plRRS
    lastPLprice := priceAtPivot

// ══════════════════════════════════════════════════════════════
// Visuals
// ══════════════════════════════════════════════════════════════

color areaCol = rrsPlot >= 0 ? color.new(BULL_COL, 55) : color.new(BEAR_COL, 55)
plot(showAreaInput ? rrsPlot : na, "RRS Area", color = areaCol, style = plot.style_area, linewidth = 1)
plot(showLineInput ? rrsPlot : na, "RRS Line", color = LINE_COL, linewidth = 1)

hline(0, "Zero", color = color.gray, linestyle = hline.style_dashed)
hline(strongLevelInput,  "Strong", color = color.new(BULL_COL, 80), linestyle = hline.style_dotted)
hline(-strongLevelInput, "Weak",   color = color.new(BEAR_COL, 80), linestyle = hline.style_dotted)

bgcolor(rrsMA > strongLevelInput * 2 ? color.new(BULL_COL, 92) : rrsMA < -strongLevelInput * 2 ? color.new(BEAR_COL, 92) : na)

plotshape(showArrowsInput and bull, "Bullish Cross", location = location.bottom, color = BULL_COL, style = shape.triangleup,   size = size.small)
plotshape(showArrowsInput and bear, "Bearish Cross", location = location.top,    color = BEAR_COL, style = shape.triangledown, size = size.small)

plotshape(bullDiv, "Bullish Divergence", location = location.bottom, color = BULL_COL, style = shape.circle, size = size.tiny)
plotshape(bearDiv, "Bearish Divergence", location = location.top,    color = BEAR_COL, style = shape.circle, size = size.tiny)

// ══════════════════════════════════════════════════════════════
// Dashboard
// ══════════════════════════════════════════════════════════════

dashPos = switch dashPosInput
    "Top Left"     => position.top_left
    "Bottom Right" => position.bottom_right
    "Bottom Left"  => position.bottom_left
    => position.top_right

var table tbl = table.new(dashPos, 2, 5, bgcolor = PANEL_BG, border_color = PANEL_BORDER, border_width = 1, frame_color = PANEL_BORDER, frame_width = 1)
if barstate.islast and showTableInput
    string state = rrsMA >= 0 ? "Outperforming" : "Underperforming"
    color  stCol = rrsMA >= 0 ? BULL_COL : BEAR_COL
    string strength = strongOut ? "Strong +" : strongUnd ? "Strong -" : "Normal"

    table.cell(tbl, 0, 0, "VP — RRS", text_color = PANEL_TEXT, text_size = size.small, bgcolor = PANEL_HEADER)
    table.cell(tbl, 1, 0, "vs " + str.tostring(benchInput), text_color = PANEL_TEXT, text_size = size.small, bgcolor = PANEL_HEADER)
    table.cell(tbl, 0, 1, "State", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 1, state, text_color = stCol, text_size = size.small)
    table.cell(tbl, 0, 2, "RRS", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 2, str.tostring(rrsMA, "#.##"), text_color = stCol, text_size = size.small)
    table.cell(tbl, 0, 3, "Strength", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 3, strength, text_color = strongOut ? BULL_COL : strongUnd ? BEAR_COL : PANEL_MUTED, text_size = size.small)
    table.cell(tbl, 0, 4, "Momentum", text_color = PANEL_TEXT, text_size = size.small)
    table.cell(tbl, 1, 4, rrsAccel >= 0 ? "▲ Rising" : "▼ Falling", text_color = rrsAccel >= 0 ? BULL_COL : BEAR_COL, text_size = size.small)

// ══════════════════════════════════════════════════════════════
// Alerts
// ══════════════════════════════════════════════════════════════

alertcondition(bull, "VP RRS Bullish Cross", "[Viprasol] RRS: {{ticker}} now OUTPERFORMING benchmark ({{interval}}) at {{close}}")
alertcondition(bear, "VP RRS Bearish Cross", "[Viprasol] RRS: {{ticker}} now UNDERPERFORMING benchmark ({{interval}}) at {{close}}")
alertcondition(strongOut, "VP RRS Strong Outperformance", "[Viprasol] RRS: {{ticker}} strong outperformance ({{interval}}) at {{close}}")
alertcondition(strongUnd, "VP RRS Strong Underperformance", "[Viprasol] RRS: {{ticker}} strong underperformance ({{interval}}) at {{close}}")
alertcondition(bullDiv, "VP RRS Bullish Divergence", "[Viprasol] RRS: bullish RRS/price divergence on {{ticker}} ({{interval}})")
alertcondition(bearDiv, "VP RRS Bearish Divergence", "[Viprasol] RRS: bearish RRS/price divergence on {{ticker}} ({{interval}})")
````
