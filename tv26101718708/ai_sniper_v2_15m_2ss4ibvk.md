# Ai SNIPER v2 15M

- url: https://www.tradingview.com/script/2ss4IBvk-Ai-SNIPER-v2-15M/
- type: indicator
- pine_id: PUB;1d9d49fd4c5a485db7eca8b4cb87452f
- version: 2.0

## Description

Multi-Timeframe Trend Pullback Scanner (15M + 5M Refinement)

What it does
SNIPER v2 identifies trend-pullback continuation setups on the 15-minute chart and automatically pulls 5-minute data to display refined entry, stop-loss, and take-profit levels — so you get lower-timeframe precision without ever leaving the 15M chart.
How it works
A signal prints only when ALL of the following confluences align:

Higher-timeframe bias — price is above the 1H 200 EMA for longs, below for shorts (pulled via request.security, works from any chart)
Pullback — price has retraced into the 9/20 EMA zone within the lookback window
Momentum trigger — Stochastic RSI cross up from oversold (longs) or down from overbought (shorts) within the last 2 bars
Trend strength — ADX above threshold (default 20) filters out chop
Trigger candle — closes back through the 9 EMA in the signal direction
Late-entry protection — skips signals where the trigger candle has already run more than a set % (default 2%)
Cooldown — blocks repeat signals for a set number of bars

5M refinement layer
When a signal fires, the script pulls the 5-minute 9 EMA and 5-minute micro swing high/low (via request.security_lower_tf) and draws four levels on your chart:

ENTRY (5M) — refined limit-entry level at the 5M 9 EMA
SL TIGHT — 5M micro swing stop (tighter risk, larger size for the same dollar risk)
SL SAFE — original 15M pullback structure stop
TP 2R — 2:1 reward target calculated from the tight stop

All four levels are also included in the alert message, so a phone notification contains the complete trade plan.
Alerts
Uses both alert() and alertcondition(). To cover a watchlist: open each symbol on 15M, create one alert per symbol with "Any alert() function call," Once Per Bar Close.
Settings
ADX filter and threshold, optional declining-volume filter, pullback lookback, signal cooldown, late-entry %, Stoch RSI lengths/levels, and toggles for the 5M refinement lines.
Best use
Designed for the 15M chart on liquid instruments (major crypto pairs, index futures, large-cap stocks). The background tint shows current 1H bias at a glance. Signals are a starting point for your own analysis — always confirm structure before entering.
Disclaimer
This is a technical analysis tool for educational purposes only, not financial advice. No indicator predicts the future or guarantees results. Always use your own risk management.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © itsjustAL

// AL SNIPER v2.1 INDICATOR - Configurable EMAs + Auto TF Scaling + Entry/SL/TP lines
// Live trading version: signals, alerts, and trade levels drawn at every signal.
//@version=6
indicator("AL SNIPER v2.1 [INDICATOR]", shorttitle="SNIPER v2.1 IND", overlay=true, max_lines_count=500, max_labels_count=500)

// ===== TIMEFRAME ENGINE =====
grpTF = "Timeframes"
tfAuto = input.bool(true, "Auto TF Scaling (Bias = chart x4, Refine = chart /3)", group=grpTF)
htfMan = input.timeframe("60", "Manual Bias TF (only used if Auto is OFF)", group=grpTF)
ltfMan = input.timeframe("5", "Manual Refinement TF (only used if Auto is OFF)", group=grpTF)

baseMin = timeframe.in_seconds() / 60
autoOK = timeframe.isintraday and baseMin >= 3
htfTF = tfAuto and autoOK ? str.tostring(int(baseMin * 4)) : htfMan
ltfTF = tfAuto and autoOK ? str.tostring(math.max(int(math.round(baseMin / 3.0)), 1)) : ltfMan

// ===== EMA SETTINGS =====
grpM = "EMA Settings"
emaFLen = input.int(9, "Fast EMA (trigger)", minval=1, group=grpM)
emaSLen = input.int(20, "Slow EMA (pullback zone)", minval=1, group=grpM)
emaTLen = input.int(200, "Bias EMA (on Bias TF)", minval=1, group=grpM)

// ===== FILTERS =====
grpF = "Filters"
useADX   = input.bool(true, "ADX Filter", group=grpF)
adxThr   = input.float(20, "ADX Threshold", group=grpF)
useVol   = input.bool(false, "Volume Declining On Pullback", group=grpF)
pbBars   = input.int(6, "Pullback Lookback (bars)", minval=2, maxval=20, group=grpF)
coolBars = input.int(10, "Signal Cooldown (bars)", minval=0, group=grpF)
maxRun   = input.float(2.0, "Skip If Candle Already Ran %", step=0.1, group=grpF)

grpS = "Stoch RSI"
kLen = input.int(14, "Stoch Length", group=grpS)
rLen = input.int(14, "RSI Length", group=grpS)
osLv = input.float(20, "Oversold", group=grpS)
obLv = input.float(80, "Overbought", group=grpS)

grpR = "Trade Levels"
showRef = input.bool(true, "Show Entry/SL/TP Lines", group=grpR)
rMult   = input.float(2.0, "Take Profit (R multiple)", step=0.5, group=grpR)
extBars = input.int(12, "Extend Lines (bars)", minval=4, group=grpR)

// ===== CORE (CHART TF) =====
emaF = ta.ema(close, emaFLen)
emaS = ta.ema(close, emaSLen)
htfBias = request.security(syminfo.tickerid, htfTF, ta.ema(close, emaTLen), lookahead=barmerge.lookahead_off)

rsiV = ta.rsi(close, rLen)
k = ta.sma(ta.stoch(rsiV, rsiV, rsiV, kLen), 3)
d = ta.sma(k, 3)

[diP, diM, adxV] = ta.dmi(14, 14)

// ===== REFINEMENT TF DATA =====
emaF_lo = request.security(syminfo.tickerid, ltfTF, ta.ema(close, emaFLen), lookahead=barmerge.lookahead_off)
lowArr  = request.security_lower_tf(syminfo.tickerid, ltfTF, low)
highArr = request.security_lower_tf(syminfo.tickerid, ltfTF, high)
curMinL = lowArr.size()  > 0 ? lowArr.min()  : low
curMaxH = highArr.size() > 0 ? highArr.max() : high
microLow  = math.min(curMinL, nz(curMinL[1], curMinL))
microHigh = math.max(curMaxH, nz(curMaxH[1], curMaxH))

// ===== CONDITIONS =====
bullBias = close > htfBias
bearBias = close < htfBias

pbZoneHi = math.max(emaF, emaS)
pbZoneLo = math.min(emaF, emaS)

touchedZoneL = ta.lowest(low, pbBars) <= pbZoneHi
touchedZoneS = ta.highest(high, pbBars) >= pbZoneLo

volDecl = not useVol or volume < ta.sma(volume, 10)
adxOK   = not useADX or adxV >= adxThr

crossUp = ta.crossover(k, d) and k[1] < osLv
crossDn = ta.crossunder(k, d) and k[1] > obLv
stochUpRecent = ta.barssince(crossUp) <= 2
stochDnRecent = ta.barssince(crossDn) <= 2

candleRun = math.abs(close - open) / open * 100
notLate = candleRun < maxRun

trigL = close > emaF and close > open
trigS = close < emaF and close < open

var int lastSig = -99999
coolOK = bar_index - lastSig >= coolBars

longSig  = bullBias and touchedZoneL and stochUpRecent and trigL and adxOK and volDecl and notLate and coolOK
shortSig = bearBias and touchedZoneS and stochDnRecent and trigS and adxOK and volDecl and notLate and coolOK

if longSig or shortSig
    lastSig := bar_index

// ===== LEVELS =====
slSafeL = ta.lowest(low, pbBars)
slSafeS = ta.highest(high, pbBars)

entryRefL = math.min(emaF_lo, close)
entryRefS = math.max(emaF_lo, close)
slRefL = microLow
slRefS = microHigh

rRefL = entryRefL - slRefL
rRefS = slRefS - entryRefS
tpRefL = entryRefL + rMult * rRefL
tpRefS = entryRefS - rMult * rRefS

// ===== DRAW LEVELS =====
draw(_p, _txt, _col) =>
    line.new(bar_index, _p, bar_index + extBars, _p, color=_col, width=2)
    label.new(bar_index + extBars, _p, _txt + " " + str.tostring(_p, format.mintick), style=label.style_label_left, color=_col, textcolor=color.white, size=size.small)

if showRef and longSig and rRefL > 0
    draw(entryRefL, "ENTRY", color.new(#2962ff, 0))
    draw(slRefL, "SL TIGHT", color.new(#f23645, 0))
    draw(slSafeL, "SL SAFE", color.new(#f23645, 60))
    draw(tpRefL, "TP " + str.tostring(rMult, "#.#") + "R", color.new(#089981, 0))

if showRef and shortSig and rRefS > 0
    draw(entryRefS, "ENTRY", color.new(#2962ff, 0))
    draw(slRefS, "SL TIGHT", color.new(#f23645, 0))
    draw(slSafeS, "SL SAFE", color.new(#f23645, 60))
    draw(tpRefS, "TP " + str.tostring(rMult, "#.#") + "R", color.new(#089981, 0))

// ===== VISUALS =====
plot(emaF, "Fast EMA", color.new(color.aqua, 0), 1)
plot(emaS, "Slow EMA", color.new(color.orange, 0), 1)
plot(htfBias, "Bias EMA (HTF)", close > htfBias ? color.new(#089981, 0) : color.new(#f23645, 0), 2)
plotshape(longSig, "LONG", shape.labelup, location.belowbar, #089981, text="LONG", textcolor=color.white, size=size.small)
plotshape(shortSig, "SHORT", shape.labeldown, location.abovebar, #f23645, text="SHORT", textcolor=color.white, size=size.small)
bgcolor(bullBias ? color.new(#089981, 96) : color.new(#f23645, 96))

// ===== ALERTS =====
if longSig
    alert("SNIPER LONG " + syminfo.ticker + " | Entry " + str.tostring(entryRefL, format.mintick) + " | SL tight " + str.tostring(slRefL, format.mintick) + " | SL safe " + str.tostring(slSafeL, format.mintick) + " | TP " + str.tostring(tpRefL, format.mintick), alert.freq_once_per_bar_close)
if shortSig
    alert("SNIPER SHORT " + syminfo.ticker + " | Entry " + str.tostring(entryRefS, format.mintick) + " | SL tight " + str.tostring(slRefS, format.mintick) + " | SL safe " + str.tostring(slSafeS, format.mintick) + " | TP " + str.tostring(tpRefS, format.mintick), alert.freq_once_per_bar_close)

alertcondition(longSig, "Sniper Long", "SNIPER LONG {{ticker}} @ {{close}}")
alertcondition(shortSig, "Sniper Short", "SNIPER SHORT {{ticker}} @ {{close}}")

// ===== TF INFO TABLE =====
var table tf = table.new(position.bottom_right, 1, 3, bgcolor=color.new(chart.bg_color, 20))
if barstate.islast
    table.cell(tf, 0, 0, "Chart: " + timeframe.period, text_color=chart.fg_color, text_size=size.tiny)
    table.cell(tf, 0, 1, "Bias TF: " + htfTF, text_color=chart.fg_color, text_size=size.tiny)
    table.cell(tf, 0, 2, "Refine TF: " + ltfTF, text_color=chart.fg_color, text_size=size.tiny)
````
