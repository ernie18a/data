# AetherEdge - SuperTrend Multi-Factor

- url: https://www.tradingview.com/script/FHHAvW1O/
- type: indicator
- pine_id: PUB;7fee1046673f4c359e5c013d993bfd7e
- version: 1.0

## Description

🖊️ Overview
AetherEdge SuperTrend Multi-Factor is a next-generation 3-layer confluence signal engine that evolves the classic SuperTrend with a volatility-adaptive dynamic multiplier. It integrates SuperTrend flips, EMA trend filtering, and volume confirmation into a unified scoring system, extracting only high-conviction entry points by ruthlessly eliminating noise. Combined with automatic SL/TP calculation, this is a professional-grade all-in-one trend-following system that supports the entire trade lifecycle from entry to exit.

🔶 Key Features

Dynamic ATR Multiplier: Auto-scales multiplier with volatility regime
3-Factor Confluence: Integrated score of ST + EMA + Volume
4 EMA Filter Modes: Fast>Slow / Price vs Fast / Price vs Slow / Slope of Fast
Volume Breakout Confirmation: MA-multiple threshold detects genuine momentum
Strong / Weak Signal Classification: Visually distinguishes 3/3 full alignment vs partial
Automatic SL/TP Generation: SuperTrend-based + ATR buffer + customizable RR
Trend Band Fill: Instant directional visualization
Statistics Dashboard: One-glance view of trend state, score, ATR dynamics
AetherEdge Premium UI: Dark mode support, refined palette

🧠 Technical Architecture

This indicator employs a multi-factor confluence architecture that probabilistically integrates multiple independent signal sources to overcome the fragility of single-indicator systems.

Dynamic Multiplier Engine:
volRatio = ATR(current) / ATR_SMA(lookback) measures current vs average volatility
Clamped to [0.6, 1.6] to suppress extremes
dynMult = baseMult × volRatioClamped achieves adaptive band width
Result: bands widen in high-vol (avoid fakeouts), tighten in low-vol (early response)
Custom SuperTrend Logic:
Upper/lower bands built around src = (H+L)/2
Persistence rule: upperBand updates only if new value is lower, or previous close exceeded prior band
trendDir flips +1 when close > upperBand[1], -1 when close < lowerBand[1]
EMA Filter Layer: 4 selectable modes for direction validation matched to market character
Volume Filter Layer: volume > volMA × volMult measures participant conviction
Confluence Scoring:
scoreBull = stFactor + emaFactorBull + volFactor (max 3 points)
3 points = Strong Signal (gold highlight)
1 point = Weak Signal (reference only)
Risk Management Engine:
SL = SuperTrend line ± (ATR × buffer)
TP = entry ± (Risk × rrRatio)
Mechanical exit levels via risk-reward ratio

⚙️ Recommended Settings & Tuning Guide

Crypto Defaults:

BTC (4H–1D): atrLen=10, atrMult=3.0, EMA 50/200, vol×1.2 (standard)
ETH (1H–4H): atrLen=12, atrMult=2.5, EMA 21/100 for momentum
SOL (high-vol): atrLen=14, atrMult=3.5, useDynMult=true essential
XRP (range-heavy): atrLen=10, atrMult=2.8, vol×1.5 for precision
EMA Mode Selection:

Trend-Following: Fast>Slow (both sides) is strongest
Pullback Hunting: Price vs Fast for short-term bounce capture
Macro View: Price vs Slow for major trend confirmation
Early Entry: Slope of Fast for momentum detection
Tuning Guide:

Strong Trend: atrMult=2.0–2.5, frequent entries
Range-Bound: atrMult=4.0–5.0, fewer fakeouts
Volatility Expansion: useDynMult=true for auto-adaptation
Conservative: rrRatio=2.5–3.0, win-rate focused
Aggressive: rrRatio=1.5, turnover focused

💡 How to Use in Practice

3/3 Strong Signal: Top-priority entry, consider full position
2/3 Signal: Half position or stand aside
ST Flip Only: Reference only, await additional confirmation
Pullbacks Within Trend: Re-enter on ST line touch
SL Line Management: Use ST as trailing stop
TP Hit: Mechanical exit at rrRatio target, eliminates emotion
AetherEdge Synergy:
Volume Profile Session POC + Strong Signal alignment = institutional sync entry
Self-Evolving S/R Grid strong line touch + ST flip = reversal candidate
Hull MA Ribbon Strong Bull + 3/3 Bull Signal = perfect long
Multi-TF Application: Confirm direction on daily ST → wait for 3/3 on 4H → precision entry on 1H

⚠️ Important Notes

Dynamic Multiplier Behavior: Multiplier shifts rapidly during volatility spikes—tune base parameter carefully
EMA Repainting: None; safe on closed bars
Volume Data: Set useVol=false on instruments lacking volume (e.g., FX)
Sideways Markets: Native SuperTrend weakness—use cautiously in chop
SL Buffer: 0 is strict; 0.5+ helps avoid stop-hunting
Consecutive Signals: In strong trends, prioritize the first signal

🚨 Disclaimer

This indicator is a technical analysis tool provided for educational and research purposes only and does not constitute financial advice. Multi-factor confluence signals and automated SL/TP levels are statistical approaches based on historical data and do not guarantee future profits. All trading decisions are made at your own risk and should be accompanied by proper risk management.

## Source Code

````pine
//@version=5
indicator("AetherEdge - SuperTrend Multi-Factor", "AE-ST MF", overlay=true,
     max_lines_count=500, max_labels_count=500, max_boxes_count=100)

// ═══════════════════════════════════════════════════════════════
//  INPUTS
// ═══════════════════════════════════════════════════════════════
grpST = "① SuperTrend Core"
atrLen       = input.int(10,   "ATR Length",         minval=1, group=grpST)
atrMult      = input.float(3.0, "ATR Multiplier (base)", minval=0.5, maxval=10.0, step=0.1, group=grpST)
useDynMult   = input.bool(true, "Dynamic Multiplier (volatility-adaptive)", group=grpST)
volLookback  = input.int(50,   "Volatility Lookback (for dynamic)", minval=10, group=grpST)

grpEMA = "② EMA Trend Filter"
useEMA       = input.bool(true, "Enable EMA Filter", group=grpEMA)
emaFastLen   = input.int(50,   "EMA Fast",  minval=1, group=grpEMA, inline="e")
emaSlowLen   = input.int(200,  "EMA Slow",  minval=1, group=grpEMA, inline="e")
emaMode      = input.string("Fast>Slow (both sides)", "EMA Condition",options=["Fast>Slow (both sides)","Price vs Fast","Price vs Slow","Slope of Fast"], group=grpEMA)

grpVol = "③ Volume Confirmation"
useVol       = input.bool(true, "Enable Volume Filter", group=grpVol)
volMALen     = input.int(20,   "Volume MA Length", minval=1, group=grpVol)
volMult      = input.float(1.2, "Volume > MA ×",   minval=0.5, step=0.1, group=grpVol)

grpRisk = "④ Risk / Stop-Loss"
showSL       = input.bool(true, "Show Stop-Loss Line", group=grpRisk)
showTP       = input.bool(true, "Show Take-Profit (RR target)", group=grpRisk)
rrRatio      = input.float(2.0, "Risk:Reward Ratio", minval=0.5, step=0.1, group=grpRisk)
slBuffer     = input.float(0.0, "SL Buffer (ATR ×)", minval=0.0, step=0.1, group=grpRisk, tooltip="Extra cushion beyond SuperTrend level")

grpD = "🎨 Display"
darkMode     = input.bool(true, "Dark Mode", group=grpD)
showFill     = input.bool(true, "Fill Trend Band", group=grpD)
showEMAs     = input.bool(true, "Plot EMAs", group=grpD)
showSignals  = input.bool(true, "Plot Signal Labels", group=grpD)
showDash     = input.bool(true, "Show Dashboard", group=grpD)
dashPos      = input.string("Top Right", "Dashboard Position",options=["Top Right","Top Left","Middle Right","Middle Left","Bottom Right","Bottom Left"], group=grpD)

grpC = "🎨 Colors"
cBull        = input.color(#00d4a0, "Bullish",  group=grpC, inline="c1")
cBear        = input.color(#ff5577, "Bearish",  group=grpC, inline="c1")
cStrong      = input.color(#ffd43b, "Strong Signal (3/3)", group=grpC, inline="c2")

// ═══════════════════════════════════════════════════════════════
//  PALETTE
// ═══════════════════════════════════════════════════════════════
cBg     = darkMode ? color.new(#0b1221, 10) : color.new(#f7f9fc, 10)
cBgAlt  = darkMode ? color.new(#111a2e, 15) : color.new(#ffffff, 0)
cBorder = darkMode ? color.new(#1f2a44, 0)  : color.new(#d8dee9, 0)
cText   = darkMode ? color.new(#e6edf7, 0)  : color.new(#1a202c, 0)
cMute   = darkMode ? color.new(#8892b0, 0)  : color.new(#64748b, 0)
cAccent = color.new(#00d4ff, 0)

// ═══════════════════════════════════════════════════════════════
//  DYNAMIC ATR MULTIPLIER
//  Scales multiplier up in high-vol regimes, down in low-vol
// ═══════════════════════════════════════════════════════════════
atrVal = ta.atr(atrLen)
atrAvg = ta.sma(atrVal, volLookback)
volRatio = atrAvg > 0 ? atrVal / atrAvg : 1.0
// clamp volatility ratio to [0.6, 1.6] range to avoid extreme multipliers
volRatioClamped = math.max(0.6, math.min(1.6, volRatio))
dynMult = useDynMult ? atrMult * volRatioClamped : atrMult

// ═══════════════════════════════════════════════════════════════
//  CUSTOM SUPERTREND (with dynamic multiplier)
// ═══════════════════════════════════════════════════════════════
src = (high + low) / 2
upperBasic = src + dynMult * atrVal
lowerBasic = src - dynMult * atrVal

var float upperBand = na
var float lowerBand = na
var int   trendDir  = 1

upperBand := na(upperBand[1]) ? upperBasic : (upperBasic < upperBand[1] or close[1] > upperBand[1]) ? upperBasic : upperBand[1]
lowerBand := na(lowerBand[1]) ? lowerBasic : (lowerBasic > lowerBand[1] or close[1] < lowerBand[1]) ? lowerBasic : lowerBand[1]

trendDir := na(trendDir[1]) ? 1 :
     trendDir[1] == -1 and close > upperBand[1] ? 1 :
     trendDir[1] ==  1 and close < lowerBand[1] ? -1 : trendDir[1]

stLine = trendDir == 1 ? lowerBand : upperBand

bullFlip = trendDir == 1  and trendDir[1] == -1
bearFlip = trendDir == -1 and trendDir[1] ==  1

// ═══════════════════════════════════════════════════════════════
//  EMA TREND FILTER
// ═══════════════════════════════════════════════════════════════
emaF = ta.ema(close, emaFastLen)
emaS = ta.ema(close, emaSlowLen)
emaSlope = emaF - emaF[3]

emaBull = not useEMA ? true :
     emaMode == "Fast>Slow (both sides)" ? emaF > emaS :
     emaMode == "Price vs Fast"          ? close > emaF :
     emaMode == "Price vs Slow"          ? close > emaS :
     emaMode == "Slope of Fast"          ? emaSlope > 0 : true

emaBear = not useEMA ? true :
     emaMode == "Fast>Slow (both sides)" ? emaF < emaS :
     emaMode == "Price vs Fast"          ? close < emaF :
     emaMode == "Price vs Slow"          ? close < emaS :
     emaMode == "Slope of Fast"          ? emaSlope < 0 : true

// ═══════════════════════════════════════════════════════════════
//  VOLUME CONFIRMATION
// ═══════════════════════════════════════════════════════════════
volMA = ta.sma(volume, volMALen)
volOK = not useVol ? true : volume > volMA * volMult
volRatio2 = volMA > 0 ? volume / volMA : 0.0

// ═══════════════════════════════════════════════════════════════
//  MULTI-FACTOR SIGNALS
// ═══════════════════════════════════════════════════════════════
// Confluence score: ST flip + EMA + Volume
stFactor  = 1
emaFactorBull = emaBull ? 1 : 0
emaFactorBear = emaBear ? 1 : 0
volFactor = volOK ? 1 : 0

scoreBull = stFactor + emaFactorBull + volFactor
scoreBear = stFactor + emaFactorBear + volFactor

// Only fire on fresh flips
longSignal  = bullFlip and emaBull and volOK
shortSignal = bearFlip and emaBear and volOK
// Strong = all 3 factors; Weak = ST flip only but EMA or Vol missing
longWeak  = bullFlip and not (emaBull and volOK)
shortWeak = bearFlip and not (emaBear and volOK)

// ═══════════════════════════════════════════════════════════════
//  STOP-LOSS / TAKE-PROFIT
// ═══════════════════════════════════════════════════════════════
slBufferVal = slBuffer * atrVal
slLong  = stLine - slBufferVal
slShort = stLine + slBufferVal
riskL   = close - slLong
riskS   = slShort - close
tpLong  = close + riskL * rrRatio
tpShort = close - riskS * rrRatio

// ═══════════════════════════════════════════════════════════════
//  PLOTS: SuperTrend Line & Fill
// ═══════════════════════════════════════════════════════════════
pUp   = plot(trendDir == 1  ? stLine : na, "ST Up",   color=color.new(cBull, 0), linewidth=2, style=plot.style_linebr)
pDn   = plot(trendDir == -1 ? stLine : na, "ST Down", color=color.new(cBear, 0), linewidth=2, style=plot.style_linebr)
pClose= plot(close, "Close (invisible)", display=display.none)

fill(pClose, pUp, color=showFill and trendDir == 1  ? color.new(cBull, 88) : na, title="Bull Fill")
fill(pClose, pDn, color=showFill and trendDir == -1 ? color.new(cBear, 88) : na, title="Bear Fill")

// ═══════════════════════════════════════════════════════════════
//  PLOTS: EMAs
// ═══════════════════════════════════════════════════════════════
plot(showEMAs and useEMA ? emaF : na, "EMA Fast", color=color.new(#4dabf7, 20), linewidth=1)
plot(showEMAs and useEMA ? emaS : na, "EMA Slow", color=color.new(#ffa94d, 20), linewidth=2)

// ═══════════════════════════════════════════════════════════════
//  SIGNAL LABELS
// ═══════════════════════════════════════════════════════════════
if showSignals and longSignal
    label.new(bar_index, low, "▲ LONG\n" + str.tostring(scoreBull) + "/3",
         color=color.new(cStrong, 0), textcolor=color.black,
         style=label.style_label_up, size=size.normal)

if showSignals and shortSignal
    label.new(bar_index, high, "▼ SHORT\n" + str.tostring(scoreBear) + "/3",
         color=color.new(cStrong, 0), textcolor=color.black,
         style=label.style_label_down, size=size.normal)

if showSignals and longWeak
    label.new(bar_index, low, "△",
         color=color.new(cBull, 40), textcolor=color.white,
         style=label.style_label_up, size=size.small,
         tooltip="Weak flip: missing EMA/Vol confirmation")

if showSignals and shortWeak
    label.new(bar_index, high, "▽",
         color=color.new(cBear, 40), textcolor=color.white,
         style=label.style_label_down, size=size.small,
         tooltip="Weak flip: missing EMA/Vol confirmation")

// ═══════════════════════════════════════════════════════════════
//  SL / TP LINES (active trade visualization)
// ═══════════════════════════════════════════════════════════════
var line slLine   = na
var line tpLine   = na
var line entryLine= na
var label slLbl   = na
var label tpLbl   = na
var label enLbl   = na
var float entryPrice = na
var int   entrySide  = 0  // 1 long, -1 short
var int   entryBar   = na

f_clearTrade() =>
    line.delete(slLine)
    line.delete(tpLine)
    line.delete(entryLine)
    label.delete(slLbl)
    label.delete(tpLbl)
    label.delete(enLbl)

if longSignal
    f_clearTrade()
    entryPrice := close
    entrySide  := 1
    entryBar   := bar_index
if shortSignal
    f_clearTrade()
    entryPrice := close
    entrySide  := -1
    entryBar   := bar_index

// Redraw every bar while a trade is active, trailing SL with SuperTrend
if barstate.islast and not na(entryPrice) and entrySide != 0
    f_clearTrade()
    curSL = entrySide == 1 ? slLong : slShort
    curTP = entrySide == 1 ? entryPrice + (entryPrice - curSL) * rrRatio
                           : entryPrice - (curSL - entryPrice) * rrRatio
    colSide = entrySide == 1 ? cBull : cBear

    entryLine := line.new(entryBar, entryPrice, bar_index + 20, entryPrice,
         color=color.new(cAccent, 0), width=2, style=line.style_solid)
    enLbl := label.new(bar_index + 20, entryPrice,
         "ENTRY " + str.tostring(entryPrice, format.mintick),
         color=color.new(cAccent, 20), textcolor=color.white,
         style=label.style_label_left, size=size.small)

    if showSL
        slLine := line.new(entryBar, curSL, bar_index + 20, curSL,
             color=color.new(cBear, 0), width=2, style=line.style_dashed)
        slLbl := label.new(bar_index + 20, curSL,
             "SL " + str.tostring(curSL, format.mintick),
             color=color.new(cBear, 20), textcolor=color.white,
             style=label.style_label_left, size=size.small)
    if showTP
        tpLine := line.new(entryBar, curTP, bar_index + 20, curTP,
             color=color.new(cBull, 0), width=2, style=line.style_dashed)
        tpLbl := label.new(bar_index + 20, curTP,
             "TP " + str.tostring(curTP, format.mintick) + " (1:" + str.tostring(rrRatio, "#.#") + ")",
             color=color.new(cBull, 20), textcolor=color.white,
             style=label.style_label_left, size=size.small)

// Reset trade if opposite flip occurs
if (entrySide == 1 and trendDir == -1) or (entrySide == -1 and trendDir == 1)
    entrySide := 0

// ═══════════════════════════════════════════════════════════════
//  BAR COLORING
// ═══════════════════════════════════════════════════════════════
barColor = trendDir == 1 ?
     (scoreBull >= 3 ? cStrong : color.new(cBull, 40)) :
     (scoreBear >= 3 ? cStrong : color.new(cBear, 40))
barcolor(barColor, title="Bar Color")

// ═══════════════════════════════════════════════════════════════
//  DASHBOARD
// ═══════════════════════════════════════════════════════════════
f_pos(p) =>
    p == "Top Right"    ? position.top_right    :
     p == "Top Left"     ? position.top_left     :
     p == "Middle Right" ? position.middle_right :
     p == "Middle Left"  ? position.middle_left  :
     p == "Bottom Right" ? position.bottom_right :
                           position.bottom_left

f_iconOK(b) => b ? "✓" : "✗"
f_colOK(b)  => b ? color.new(#00d4a0, 20) : color.new(#ff5577, 30)

var table dash = na
if barstate.islast and showDash
    dash := table.new(f_pos(dashPos), 3, 10,
         bgcolor=cBg, border_color=cBorder, border_width=1,
         frame_color=cAccent, frame_width=1)

    // Header
    table.cell(dash, 0, 0, "★ AETHEREDGE · SUPERTREND MF ★",
         text_color=cAccent, bgcolor=cBgAlt, text_size=size.normal, text_halign=text.align_center)
    table.merge_cells(dash, 0, 0, 2, 0)

    // Trend state
    trendTxt = trendDir == 1 ? "▲ BULLISH" : "▼ BEARISH"
    trendCol = trendDir == 1 ? cBull : cBear
    table.cell(dash, 0, 1, "TREND", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 1, trendTxt, text_color=color.white,
         bgcolor=color.new(trendCol, 30), text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(dash, 1, 1, 2, 1)

    // ST line value
    table.cell(dash, 0, 2, "ST LEVEL", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 2, str.tostring(stLine, format.mintick),
         text_color=cText, bgcolor=cBg, text_halign=text.align_center)
    table.cell(dash, 2, 2, "×" + str.tostring(dynMult, "#.##"),
         text_color=cAccent, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // Confluence score
    curScore = trendDir == 1 ? scoreBull : scoreBear
    scoreCol = curScore == 3 ? cStrong : curScore == 2 ? color.new(#4dabf7, 0) : color.new(#ff5577, 0)
    scoreTxt = str.tostring(curScore) + " / 3"
    table.cell(dash, 0, 3, "CONFLUENCE", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 3, scoreTxt, text_color=color.white,
         bgcolor=color.new(scoreCol, 30), text_halign=text.align_center, text_size=size.normal)
    table.merge_cells(dash, 1, 3, 2, 3)

    // Factor breakdown
    curEMA = trendDir == 1 ? emaBull : emaBear
    table.cell(dash, 0, 4, "• SuperTrend", text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 4, f_iconOK(true), text_color=color.white, bgcolor=f_colOK(true), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 4, (trendDir == 1 ? "UP" : "DN"), text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 5, "• EMA Filter",  text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 5, useEMA ? f_iconOK(curEMA) : "—", text_color=color.white,
         bgcolor=useEMA ? f_colOK(curEMA) : color.new(cMute, 50), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 5, useEMA ? emaMode : "OFF", text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 6, "• Volume",      text_color=cMute, bgcolor=cBg, text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 6, useVol ? f_iconOK(volOK) : "—", text_color=color.white,
         bgcolor=useVol ? f_colOK(volOK) : color.new(cMute, 50), text_halign=text.align_center, text_size=size.small)
    table.cell(dash, 2, 6, useVol ? "×" + str.tostring(volRatio2, "#.##") : "OFF",
         text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)

    // ATR info
    table.cell(dash, 0, 7, "ATR(" + str.tostring(atrLen) + ")", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 7, str.tostring(atrVal, format.mintick),
         text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    volRegime = volRatio > 1.2 ? "HIGH VOL" : volRatio < 0.8 ? "LOW VOL" : "NORMAL"
    volRegimeCol = volRatio > 1.2 ? color.new(#ff5577, 30) : volRatio < 0.8 ? color.new(#4dabf7, 30) : color.new(cMute, 30)
    table.cell(dash, 2, 7, volRegime, text_color=color.white, bgcolor=volRegimeCol, text_halign=text.align_center, text_size=size.small)

    // Active trade info
    activeTxt = entrySide == 0 ? "NO TRADE" : entrySide == 1 ? "LONG ACTIVE" : "SHORT ACTIVE"
    activeCol = entrySide == 0 ? cMute : entrySide == 1 ? cBull : cBear
    table.cell(dash, 0, 8, "POSITION", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
    table.cell(dash, 1, 8, activeTxt, text_color=color.white,
         bgcolor=color.new(activeCol, 30), text_halign=text.align_center, text_size=size.small)
    table.merge_cells(dash, 1, 8, 2, 8)

    // Live PnL / distance to SL
    if entrySide != 0 and not na(entryPrice)
        pnlTicks = entrySide == 1 ? (close - entryPrice) / syminfo.mintick : (entryPrice - close) / syminfo.mintick
        pnlCol = pnlTicks >= 0 ? color.new(cBull, 20) : color.new(cBear, 20)
        table.cell(dash, 0, 9, "UNREALIZED", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
        table.cell(dash, 1, 9, str.tostring(math.round(pnlTicks)) + " ticks",
             text_color=color.white, bgcolor=pnlCol, text_halign=text.align_center, text_size=size.small)
        table.cell(dash, 2, 9, "RR 1:" + str.tostring(rrRatio, "#.#"),
             text_color=cText, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
    else
        table.cell(dash, 0, 9, "WAITING", text_color=cMute, bgcolor=cBgAlt, text_halign=text.align_left)
        table.cell(dash, 1, 9, "for next signal",
             text_color=cMute, bgcolor=cBg, text_halign=text.align_center, text_size=size.small)
        table.merge_cells(dash, 1, 9, 2, 9)

// ═══════════════════════════════════════════════════════════════
//  ALERTS
// ═══════════════════════════════════════════════════════════════
alertcondition(longSignal,  "Strong LONG (3/3)",
     "AetherEdge MF: Strong LONG — SuperTrend flip + EMA + Volume confirmed")
alertcondition(shortSignal, "Strong SHORT (3/3)",
     "AetherEdge MF: Strong SHORT — SuperTrend flip + EMA + Volume confirmed")
alertcondition(bullFlip,    "ST Flip Bullish (any)", "AetherEdge MF: SuperTrend flipped bullish")
alertcondition(bearFlip,    "ST Flip Bearish (any)", "AetherEdge MF: SuperTrend flipped bearish")
alertcondition(not na(entryPrice) and entrySide == 1  and low  <= slLong,  "Long SL Hit",  "AetherEdge MF: Long stop-loss hit")
alertcondition(not na(entryPrice) and entrySide == -1 and high >= slShort, "Short SL Hit", "AetherEdge MF: Short stop-loss hit")
````
