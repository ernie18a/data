# PULSE RAILS

- url: https://www.tradingview.com/script/DfT9uAw1/
- type: indicator
- pine_id: PUB;76cdb0ed0517401d8709dd7b47cad714
- version: 1.0

## Description

# PULSE RAILS

PULSE RAILS is a hybrid market structure and energy visualization tool designed to combine trend context with internal market activity.

The indicator consists of two complementary components:

• A dynamic rail system that visualizes trend structure and directional context.

• An Energy Matrix that combines multiple normalized market measurements into a single energy flow model.

The Energy Matrix is built from:

• On Balance Volume (OBV) Pressure
• Momentum Acceleration
• MACD Histogram Expansion
• Volatility-Based Energy

These components are blended into a unified wave designed to highlight changes in participation, momentum conditions and relative market activity.

Key Features:

• Dynamic Trend Rails
• Trend Context Visualization
• Energy Flow Wave
• Support and Resistance Levels
• Momentum Transition Detection
• Market Activity Analysis
• Clean Overlay Design

The rail system focuses on market structure while the Energy Matrix provides additional context about the strength and quality of underlying price movement.

PULSE RAILS is intended to assist chart analysis by presenting trend and energy information within a single workflow.

This script is provided for educational and analytical purposes only. It does not provide financial advice and should not be used as the sole basis for trading decisions.

## Source Code

````pine
//@version=6
indicator("OMEGA RAILS PRO • FAST PRE Wave Hybrid", overlay=false, max_lines_count=100, max_labels_count=100)

//━━━━━━━━━━━━━━━━━━
// INPUTS
//━━━━━━━━━━━━━━━━━━
atrLen      = input.int(14, "ATR Length", minval=1, group="TREND RAIL")
stFactor    = input.float(2.4, "Rail ATR Factor", step=0.1, group="TREND RAIL")
emaLen      = input.int(100, "EMA Trend", minval=1, group="TREND RAIL")

energyLen   = input.int(80, "Energy Normalize", minval=10, group="FAST PRE WAVE")
smoothLen   = input.int(6, "Wave Smooth", minval=1, group="FAST PRE WAVE")
macdFast    = input.int(12, "MACD Fast", group="FAST PRE WAVE")
macdSlow    = input.int(26, "MACD Slow", group="FAST PRE WAVE")
macdSignal  = input.int(9, "MACD Signal", group="FAST PRE WAVE")
showWaveBg  = input.bool(true, "Show Wave Background", group="FAST PRE WAVE")

pivotLen    = input.int(8, "S/R Pivot Length", minval=1, group="DISPLAY")
showSR      = input.bool(true, "Show Support / Resistance", group="DISPLAY")
showSignals = input.bool(true, "Show Small Signals", group="DISPLAY")
showPanel   = input.bool(true, "Show Info Panel", group="DISPLAY")
showBgTrend = input.bool(true, "Panel Trend Background", group="DISPLAY")

//━━━━━━━━━━━━━━━━━━
// COLORS
//━━━━━━━━━━━━━━━━━━
LIME   = color.rgb(0, 255, 170)
RED    = color.rgb(255, 82, 82)
AQUA   = color.rgb(0, 245, 255)
YELLOW = color.rgb(255, 215, 64)
WHITE  = color.rgb(255, 255, 255)
GRAY   = color.rgb(120, 120, 120)

//━━━━━━━━━━━━━━━━━━
// TREND RAIL
//━━━━━━━━━━━━━━━━━━
atr = ta.atr(atrLen)
ema = ta.ema(close, emaLen)

[st, dir] = ta.supertrend(stFactor, atrLen)

bullTrend = close > st and close > ema
bearTrend = close < st and close < ema

railColor = bullTrend ? LIME : bearTrend ? RED : GRAY

railTop = st + atr * 0.18
railBot = st - atr * 0.18

pTop = plot(railTop, "Rail Top", color=color.new(railColor, 75), linewidth=1, force_overlay=true)
pBot = plot(railBot, "Rail Bottom", color=color.new(railColor, 75), linewidth=1, force_overlay=true)

fill(pTop, pBot, color=color.new(railColor, 72), title="Rail Fill")

plot(st, "Main Rail", color=railColor, linewidth=4, style=plot.style_linebr, force_overlay=true)
plot(ema, "EMA Trend", color=color.new(WHITE, 75), linewidth=1, force_overlay=true)

//━━━━━━━━━━━━━━━━━━
// PANEL BACKGROUND
//━━━━━━━━━━━━━━━━━━
bgTrendCol = bullTrend ? color.new(LIME, 94) : bearTrend ? color.new(RED, 94) : color.new(GRAY, 97)
bgcolor(showBgTrend ? bgTrendCol : na)

//━━━━━━━━━━━━━━━━━━
// SUPPORT / RESISTANCE
//━━━━━━━━━━━━━━━━━━
ph = ta.pivothigh(high, pivotLen, pivotLen)
pl = ta.pivotlow(low, pivotLen, pivotLen)

var line resLine = na
var line supLine = na

if showSR and not na(ph)
    line.delete(resLine)
    resLine := line.new(bar_index - pivotLen, ph, bar_index, ph, xloc=xloc.bar_index, extend=extend.right, color=color.new(RED, 0), width=2, force_overlay=true)

if showSR and not na(pl)
    line.delete(supLine)
    supLine := line.new(bar_index - pivotLen, pl, bar_index, pl, xloc=xloc.bar_index, extend=extend.right, color=color.new(AQUA, 0), width=2, force_overlay=true)

//━━━━━━━━━━━━━━━━━━
// FAST PRE ENERGY WAVE
//━━━━━━━━━━━━━━━━━━
safeVol = nz(volume, 0)

obv = ta.cum(close > close[1] ? safeVol : close < close[1] ? -safeVol : 0)
obvPressure = ta.roc(ta.ema(obv, 13), 8)

momentum = ta.roc(close, 8)

macdLine = ta.ema(close, macdFast) - ta.ema(close, macdSlow)
macdSig  = ta.ema(macdLine, macdSignal)
macdHist = macdLine - macdSig

atrEnergy = math.pi * math.pow(atr, 2)

f_norm(src, len) =>
    lo = ta.lowest(src, len)
    hi = ta.highest(src, len)
    hi == lo ? 50.0 : 100.0 * (src - lo) / (hi - lo)

nObv  = f_norm(obvPressure, energyLen)
nMom  = f_norm(momentum, energyLen)
nMacd = f_norm(macdHist, energyLen)
nAtr  = f_norm(atrEnergy, energyLen)

preRaw = nObv * 0.35 + nMom * 0.35 + nMacd * 0.20 + nAtr * 0.10
pre    = ta.ema(preRaw, smoothLen)

wave = pre - 50
waveSignal = ta.ema(wave, smoothLen)

waveColor = wave >= 0 ? color.new(LIME, 15) : color.new(RED, 15)

hline(0, "Zero Line", color=color.new(WHITE, 70))

plot(wave, "FAST PRE Energy Wave", style=plot.style_area, color=showWaveBg ? waveColor : na, linewidth=2)
plot(waveSignal, "Wave Signal", color=color.new(WHITE, 45), linewidth=2)

//━━━━━━━━━━━━━━━━━━
// SIGNALS
//━━━━━━━━━━━━━━━━━━
bullSignal = showSignals and bullTrend and ta.crossover(wave, waveSignal) and wave > -15
bearSignal = showSignals and bearTrend and ta.crossunder(wave, waveSignal) and wave < 15

plotshape(bullSignal, title="Bull Triangle", style=shape.triangleup, location=location.belowbar, color=color.new(AQUA, 0), size=size.tiny, force_overlay=true)
plotshape(bearSignal, title="Bear Triangle", style=shape.triangledown, location=location.abovebar, color=color.new(RED, 0), size=size.tiny, force_overlay=true)

//━━━━━━━━━━━━━━━━━━
// CANDLE COLOR
//━━━━━━━━━━━━━━━━━━
barcolor(
     bullTrend and wave > 15 ? color.new(LIME, 0) :
     bearTrend and wave < -15 ? color.new(RED, 0) :
     na
)

//━━━━━━━━━━━━━━━━━━
// INFO PANEL
//━━━━━━━━━━━━━━━━━━
rowBg(rowIdx) => rowIdx % 2 == 0 ? color.rgb(22, 22, 22) : color.rgb(16, 16, 16)

var table infoPanel = table.new(position.top_right, 2, 5, border_width=2, frame_color=color.rgb(40,40,40), border_color=color.rgb(60,60,60), frame_width=2)

if showPanel and barstate.islast
    table.cell(infoPanel, 0, 0, "OMEGA RAILS", text_color=color.white, bgcolor=color.rgb(30,30,30), text_size=size.small)
    table.cell(infoPanel, 1, 0, "FAST", text_color=railColor, bgcolor=color.rgb(30,30,30), text_size=size.small)

    table.cell(infoPanel, 0, 1, "TREND", text_color=color.white, bgcolor=rowBg(1), text_size=size.small)
    table.cell(infoPanel, 1, 1, bullTrend ? "BULL ▲" : bearTrend ? "BEAR ▼" : "NEUTRAL —", text_color=railColor, bgcolor=rowBg(1), text_size=size.small)

    table.cell(infoPanel, 0, 2, "WAVE", text_color=color.white, bgcolor=rowBg(2), text_size=size.small)
    table.cell(infoPanel, 1, 2, str.tostring(wave, "#.##"), text_color=wave >= 0 ? LIME : RED, bgcolor=rowBg(2), text_size=size.small)

    table.cell(infoPanel, 0, 3, "PRE RAW", text_color=color.white, bgcolor=rowBg(3), text_size=size.small)
    table.cell(infoPanel, 1, 3, str.tostring(pre, "#.##"), text_color=YELLOW, bgcolor=rowBg(3), text_size=size.small)

    table.cell(infoPanel, 0, 4, "MACD H", text_color=color.white, bgcolor=rowBg(4), text_size=size.small)
    table.cell(infoPanel, 1, 4, str.tostring(macdHist, "#.####"), text_color=WHITE, bgcolor=rowBg(4), text_size=size.small)

//━━━━━━━━━━━━━━━━━━
// ALERTS
//━━━━━━━━━━━━━━━━━━
alertcondition(bullSignal, "OMEGA Bull Signal", "OMEGA FAST PRE Bull Signal")
alertcondition(bearSignal, "OMEGA Bear Signal", "OMEGA FAST PRE Bear Signal")
alertcondition(ta.crossover(wave, 0), "FAST PRE Zero Cross Up", "FAST PRE crossed above zero")
alertcondition(ta.crossunder(wave, 0), "FAST PRE Zero Cross Down", "FAST PRE crossed below zero")
````
