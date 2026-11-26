# Edge Confirmation System (ECS)

- url: https://www.tradingview.com/script/78fqcnBy-Edge-Confirmation-System-ECS/
- type: indicator
- pine_id: PUB;d0f8ed952b62475cbb52863b4fa36597
- version: 1.0

## Description

A multi-layer confluence indicator built for SPX and SPY options traders.
Combines three independent layers — Trend, Momentum, and Volume — and only fires a BUY or SELL signal when all three agree. No noise, no guessing.

What's included:

⚡ Trend Ribbon — Shows market direction using 3 EMAs. Grey ribbon means no trade.

🔥 Momentum Pulse — Custom oscillator that filters out weak, low-energy moves.

📊 Volume Surge — Blocks entries on low-volume candles where fakeouts happen most.

🎯 BUY / SELL Labels — Clean signals printed directly on price. Only when all layers confirm.

📋 Live Dashboard — Shows Trend, Momentum, Volume, Setup Strength, Signal, and Bias at a glance.

🔔 Built-in Alerts — Get notified on BUY, SELL, and Volume Surge signals.

For educational purposes only. Not financial advice. Always manage your risk.

## Source Code

````pine
// ============================================================
//  EDGE CONFIRMATION SYSTEM (ECS) v2.1 — Pine Script v6
//  Built for: SPX & SPY Options — Scalping & Day Trading
//  Platform: TradingView (Pine Script v6)
// ============================================================

//@version=6
indicator("Edge Confirmation System (ECS) v2.1", shorttitle="ECS v2.1", overlay=true, max_lines_count=10, max_labels_count=500)

// ─────────────────────────────────────────────
// ░░ INPUTS
// ─────────────────────────────────────────────

trendFastLen  = input.int(8,      "Fast EMA",                 group="Trend Ribbon")
trendSlowLen  = input.int(21,     "Slow EMA",                 group="Trend Ribbon")
trendBaseLen  = input.int(50,     "Base EMA",                 group="Trend Ribbon")
showRibbon    = input.bool(true,  "Show Trend Ribbon",        group="Trend Ribbon")

mpFastLen     = input.int(5,      "Momentum Fast Period",     group="Momentum Pulse")
mpSlowLen     = input.int(13,     "Momentum Slow Period",     group="Momentum Pulse")
mpSignalLen   = input.int(3,      "Momentum Smoothing",       group="Momentum Pulse")
mpOBLevel     = input.float(0.8,  "Overbought Level",         group="Momentum Pulse", minval=0.1,  maxval=1.5)
mpOSLevel     = input.float(-0.8, "Oversold Level",           group="Momentum Pulse", minval=-1.5, maxval=-0.1)

volLookback   = input.int(20,     "Volume Average Period",    group="Volume Surge")
volMultiplier = input.float(1.5,  "Surge Threshold (x Avg)", group="Volume Surge", minval=1.0, maxval=4.0)
showVolBars   = input.bool(true,  "Highlight Surge Candles",  group="Volume Surge")

showEntries   = input.bool(true,  "Show BUY / SELL Labels",  group="Signals")
requireVolume = input.bool(true,  "Require Volume Surge",    group="Signals")
showDash      = input.bool(true,  "Show Dashboard",          group="Signals")


// ─────────────────────────────────────────────
// ░░ LAYER 1: TREND RIBBON
// ─────────────────────────────────────────────

float emaFast = ta.ema(close, trendFastLen)
float emaSlow = ta.ema(close, trendSlowLen)
float emaBase = ta.ema(close, trendBaseLen)

bool trendBull    = close > emaBase and emaFast > emaSlow
bool trendBear    = close < emaBase and emaFast < emaSlow

color ribbonColor = trendBull ? color.new(#26A69A, 78) : trendBear ? color.new(#EF5350, 78) : color.new(#78909C, 88)

p1 = plot(showRibbon ? emaFast : na, color=color.new(#26A69A, 50), linewidth=1, title="EMA Fast")
p2 = plot(showRibbon ? emaSlow : na, color=color.new(#EF5350, 50), linewidth=1, title="EMA Slow")
plot(showRibbon ? emaBase : na,      color=color.new(#FFB74D, 40), linewidth=2, title="EMA Base (50)")
fill(p1, p2, color=ribbonColor, title="Trend Ribbon")


// ─────────────────────────────────────────────
// ░░ LAYER 2: MOMENTUM PULSE
// ─────────────────────────────────────────────

float emaF     = ta.ema(close, mpFastLen)
float emaS     = ta.ema(close, mpSlowLen)
float mpRaw    = (emaF - emaS) / emaS * 100.0
float mpHigh   = ta.highest(mpRaw, 50)
float mpLow    = ta.lowest(mpRaw,  50)
float mpRange  = mpHigh - mpLow
float mpNorm   = mpRange > 0.0 ? 2.0 * ((mpRaw - mpLow) / mpRange) - 1.0 : 0.0
float mpSignal = ta.ema(mpNorm, mpSignalLen)

bool mpBullish = mpNorm > 0.0 and mpNorm > mpSignal
bool mpBearish = mpNorm < 0.0 and mpNorm < mpSignal
bool mpOB      = mpNorm >= mpOBLevel
bool mpOS      = mpNorm <= mpOSLevel


// ─────────────────────────────────────────────
// ░░ LAYER 3: VOLUME SURGE
// ─────────────────────────────────────────────

float avgVol       = ta.sma(volume, volLookback)
bool  volSurge     = volume >= avgVol * volMultiplier
bool  volBullSurge = volSurge and close > open
bool  volBearSurge = volSurge and close < open

barcolor(showVolBars and volBullSurge ? color.new(#26A69A, 25) : showVolBars and volBearSurge ? color.new(#EF5350, 25) : na, title="Volume Surge Candle")


// ─────────────────────────────────────────────
// ░░ LAYER 4: ENTRY SIGNALS
// ─────────────────────────────────────────────

int bullScore = (trendBull ? 1 : 0) + (mpBullish ? 1 : 0) + (volBullSurge ? 1 : 0)
int bearScore = (trendBear ? 1 : 0) + (mpBearish ? 1 : 0) + (volBearSurge ? 1 : 0)

bool longCondition  = trendBull and mpBullish and not mpOB and (requireVolume ? volBullSurge : true)
bool shortCondition = trendBear and mpBearish and not mpOS and (requireVolume ? volBearSurge : true)

var int lastSignal = 0
bool longEntry  = longCondition  and lastSignal != 1
bool shortEntry = shortCondition and lastSignal != -1

if longEntry
    lastSignal := 1
if shortEntry
    lastSignal := -1

if showEntries and longEntry
    label.new(bar_index, low - (low * 0.0005), text="▲  BUY", style=label.style_label_up, color=#26A69A, textcolor=color.white, size=size.normal)

if showEntries and shortEntry
    label.new(bar_index, high + (high * 0.0005), text="▼  SELL", style=label.style_label_down, color=#EF5350, textcolor=color.white, size=size.normal)


// ─────────────────────────────────────────────
// ░░ DASHBOARD — Simple original style, v6 safe
// ─────────────────────────────────────────────

// Trend
string trendText = trendBull ? "▲ BULLISH" : trendBear ? "▼ BEARISH" : "── NEUTRAL"
color  trendBg   = trendBull ? color.new(#00E5FF, 30) : trendBear ? color.new(#FF3D71, 30) : color.new(#334155, 30)
color  trendTxt  = trendBull ? color.white : trendBear ? color.white : color.new(#94A3B8, 0)

// Momentum
string mpText = mpBullish ? "▲ RISING" : mpBearish ? "▼ FALLING" : "── FLAT"
color  mpBg   = mpBullish ? color.new(#00E5FF, 30) : mpBearish ? color.new(#FF3D71, 30) : color.new(#334155, 30)
color  mpTxt  = mpBullish ? color.white : mpBearish ? color.white : color.new(#94A3B8, 0)

// Volume
string volText = volBullSurge ? "BULL SURGE" : volBearSurge ? "BEAR SURGE" : "Normal"
color  volBg   = volBullSurge ? color.new(#00E5FF, 30) : volBearSurge ? color.new(#FF3D71, 30) : color.new(#334155, 30)
color  volTxt  = volSurge ? color.white : color.new(#94A3B8, 0)

// Overextended
string extText = mpOB ? "OVERBOUGHT" : mpOS ? "OVERSOLD" : "Normal"
color  extBg   = (mpOB or mpOS) ? color.new(#F59E0B, 20) : color.new(#334155, 30)
color  extTxt  = (mpOB or mpOS) ? color.new(#F59E0B, 0) : color.new(#22C55E, 0)

// Confluence
int    activeScore = trendBull ? bullScore : bearScore
string scoreText   = activeScore == 3 ? "FULL  3/3" : activeScore == 2 ? "PARTIAL  2/3" : "WEAK  1/3"
color  scoreBg     = activeScore == 3 ? color.new(#00E5FF, 20) : activeScore == 2 ? color.new(#F59E0B, 20) : color.new(#334155, 30)
color  scoreTxt    = activeScore == 3 ? color.white : activeScore == 2 ? color.new(#F59E0B, 0) : color.new(#94A3B8, 0)

// Signal
string sigText = longEntry ? "▲ BUY" : shortEntry ? "▼ SELL" : "WAITING"
color  sigBg   = longEntry ? color.new(#00E5FF, 15) : shortEntry ? color.new(#FF3D71, 15) : color.new(#334155, 30)
color  sigTxt  = longEntry ? color.white : shortEntry ? color.white : color.new(#94A3B8, 0)

// Bias
string biasText = trendBull ? "CALLS / LONGS" : trendBear ? "PUTS / SHORTS" : "STAND ASIDE"
color  biasBg   = trendBull ? color.new(#00E5FF, 25) : trendBear ? color.new(#FF3D71, 25) : color.new(#334155, 30)
color  biasTxt  = trendBull ? color.white : trendBear ? color.white : color.new(#94A3B8, 0)

// Draw Table
if showDash and barstate.islast
    var table dash = table.new(position.top_right, 2, 9, bgcolor=color.new(#0F172A, 5), border_color=color.new(#1E293B, 0), border_width=1, frame_color=color.new(#334155, 0), frame_width=1)

    table.cell(dash, 0, 0, "ECS v2.1", text_color=color.new(#F59E0B, 0), bgcolor=color.new(#1E293B, 0), text_halign=text.align_left, text_size=size.small)
    table.cell(dash, 1, 0, "STATUS",   text_color=color.new(#F59E0B, 0), bgcolor=color.new(#1E293B, 0), text_halign=text.align_center, text_size=size.small)

    table.cell(dash, 0, 1, "Trend",       text_color=color.new(#94A3B8, 0), bgcolor=color.new(#0F172A, 0), text_size=size.small)
    table.cell(dash, 1, 1, trendText,     text_color=trendTxt, bgcolor=trendBg, text_size=size.small, text_halign=text.align_center)

    table.cell(dash, 0, 2, "Momentum",    text_color=color.new(#94A3B8, 0), bgcolor=color.new(#0F172A, 0), text_size=size.small)
    table.cell(dash, 1, 2, mpText,        text_color=mpTxt, bgcolor=mpBg, text_size=size.small, text_halign=text.align_center)

    table.cell(dash, 0, 3, "Volume",      text_color=color.new(#94A3B8, 0), bgcolor=color.new(#0F172A, 0), text_size=size.small)
    table.cell(dash, 1, 3, volText,       text_color=volTxt, bgcolor=volBg, text_size=size.small, text_halign=text.align_center)

    table.cell(dash, 0, 4, "Extreme",     text_color=color.new(#94A3B8, 0), bgcolor=color.new(#0F172A, 0), text_size=size.small)
    table.cell(dash, 1, 4, extText,       text_color=extTxt, bgcolor=extBg, text_size=size.small, text_halign=text.align_center)

    table.cell(dash, 0, 5, "Confluence",  text_color=color.new(#94A3B8, 0), bgcolor=color.new(#0F172A, 0), text_size=size.small)
    table.cell(dash, 1, 5, scoreText,     text_color=scoreTxt, bgcolor=scoreBg, text_size=size.small, text_halign=text.align_center)

    table.cell(dash, 0, 6, "Signal",      text_color=color.new(#94A3B8, 0), bgcolor=color.new(#0F172A, 0), text_size=size.small)
    table.cell(dash, 1, 6, sigText,       text_color=sigTxt, bgcolor=sigBg, text_size=size.small, text_halign=text.align_center)

    table.cell(dash, 0, 7, "Bias",        text_color=color.new(#94A3B8, 0), bgcolor=color.new(#0F172A, 0), text_size=size.small)
    table.cell(dash, 1, 7, biasText,      text_color=biasTxt, bgcolor=biasBg, text_size=size.small, text_halign=text.align_center)

    table.cell(dash, 0, 8, "Timeframe",   text_color=color.new(#94A3B8, 0), bgcolor=color.new(#0F172A, 0), text_size=size.small)
    table.cell(dash, 1, 8, timeframe.period + " min", text_color=color.new(#94A3B8, 0), bgcolor=color.new(#0F172A, 0), text_size=size.small, text_halign=text.align_center)


// ─────────────────────────────────────────────
// ░░ ALERTS
// ─────────────────────────────────────────────

alertcondition(longEntry,  title="ECS BUY Signal",        message="ECS BUY on {{ticker}} at {{close}} — Look for CALLS")
alertcondition(shortEntry, title="ECS SELL Signal",       message="ECS SELL on {{ticker}} at {{close}} — Look for PUTS")
alertcondition(volSurge,   title="ECS Volume Surge",      message="ECS Volume Surge on {{ticker}} — Watch for directional move")
````
