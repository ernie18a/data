# Edge Confirmation System

- url: https://www.tradingview.com/script/o7MbjI0C-Edge-Confirmation-System/
- type: indicator
- pine_id: PUB;1e29c90f9e964357b3f86603c879bbd2
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
//@version=6
indicator("ECS — Edge Confirmation System v2.1", shorttitle="ECS v2.1", overlay=true, max_labels_count=500)

// ─────────────────────────────────────────────
// INPUTS
// ─────────────────────────────────────────────

fastLen      = input.int(8,      "Fast EMA",             group="Trend Ribbon")
slowLen      = input.int(21,     "Slow EMA",             group="Trend Ribbon")
baseLen      = input.int(50,     "Base EMA",             group="Trend Ribbon")
showRibbon   = input.bool(true,  "Show Ribbon",          group="Trend Ribbon")

mpFast       = input.int(5,      "Momentum Fast",        group="Momentum")
mpSlow       = input.int(13,     "Momentum Slow",        group="Momentum")
mpSmooth     = input.int(3,      "Momentum Smooth",      group="Momentum")
obLevel      = input.float(0.8,  "Overbought",           group="Momentum", minval=0.1, maxval=1.5)
osLevel      = input.float(-0.8, "Oversold",             group="Momentum", minval=-1.5, maxval=-0.1)

volLen       = input.int(20,     "Volume Avg Period",    group="Volume")
volMult      = input.float(1.5,  "Surge Threshold",      group="Volume", minval=1.0, maxval=4.0)
showVolColor = input.bool(true,  "Highlight Surge Bars", group="Volume")

showSignals  = input.bool(true,  "Show BUY / SELL",      group="Signals")
needVol      = input.bool(true,  "Require Volume Surge", group="Signals")
showDash     = input.bool(true,  "Show Dashboard",       group="Signals")


// ─────────────────────────────────────────────
// LAYER 1 — TREND RIBBON
// ─────────────────────────────────────────────

float emaFast = ta.ema(close, fastLen)
float emaSlow = ta.ema(close, slowLen)
float emaBase = ta.ema(close, baseLen)

bool isBull = close > emaBase and emaFast > emaSlow
bool isBear = close < emaBase and emaFast < emaSlow

p1 = plot(showRibbon ? emaFast : na, color=color.new(#26A69A, 55), linewidth=1, title="EMA Fast")
p2 = plot(showRibbon ? emaSlow : na, color=color.new(#EF5350, 55), linewidth=1, title="EMA Slow")
plot(showRibbon ? emaBase : na,      color=color.new(#FFB74D, 45), linewidth=2, title="EMA Base")
fill(p1, p2, color=isBull ? color.new(#26A69A, 82) : isBear ? color.new(#EF5350, 82) : color.new(#78909C, 90), title="Ribbon Fill")


// ─────────────────────────────────────────────
// LAYER 2 — MOMENTUM PULSE
// ─────────────────────────────────────────────

float mFast  = ta.ema(close, mpFast)
float mSlow  = ta.ema(close, mpSlow)
float mRaw   = (mFast - mSlow) / mSlow * 100.0
float mHigh  = ta.highest(mRaw, 50)
float mLow   = ta.lowest(mRaw, 50)
float mRange = mHigh - mLow
float mNorm  = mRange > 0.0 ? 2.0 * ((mRaw - mLow) / mRange) - 1.0 : 0.0
float mSig   = ta.ema(mNorm, mpSmooth)

bool mUp   = mNorm > 0.0 and mNorm > mSig
bool mDown = mNorm < 0.0 and mNorm < mSig
bool mOB   = mNorm >= obLevel
bool mOS   = mNorm <= osLevel


// ─────────────────────────────────────────────
// LAYER 3 — VOLUME SURGE
// ─────────────────────────────────────────────

float avgVol = ta.sma(volume, volLen)
bool  vSurge = volume >= avgVol * volMult
bool  vBull  = vSurge and close > open
bool  vBear  = vSurge and close < open

barcolor(showVolColor and vBull ? color.new(#26A69A, 20) : showVolColor and vBear ? color.new(#EF5350, 20) : na, title="Volume Surge Bar")


// ─────────────────────────────────────────────
// LAYER 4 — BUY / SELL SIGNALS
// ─────────────────────────────────────────────

int bullScore = (isBull ? 1 : 0) + (mUp   ? 1 : 0) + (vBull ? 1 : 0)
int bearScore = (isBear ? 1 : 0) + (mDown ? 1 : 0) + (vBear ? 1 : 0)

bool goLong  = isBull and mUp   and not mOB and (needVol ? vBull : true)
bool goShort = isBear and mDown and not mOS and (needVol ? vBear : true)

var int lastSig = 0
bool buyNow  = goLong  and lastSig != 1
bool sellNow = goShort and lastSig != -1

if buyNow
    lastSig := 1
if sellNow
    lastSig := -1

if showSignals and buyNow
    label.new(bar_index, low - (low * 0.0006), text="▲  BUY", style=label.style_label_up, color=#26A69A, textcolor=color.white, size=size.normal)

if showSignals and sellNow
    label.new(bar_index, high + (high * 0.0006), text="▼  SELL", style=label.style_label_down, color=#EF5350, textcolor=color.white, size=size.normal)


// ─────────────────────────────────────────────
// DASHBOARD — Single column, label + value in one cell
// ─────────────────────────────────────────────

int    score    = isBull ? bullScore : bearScore
string dTrend   = isBull ? "Trend:          GOING UP ▲"    : isBear ? "Trend:          GOING DOWN ▼"     : "Trend:          NO DIRECTION"
string dMom     = mUp    ? "Momentum:   RISING ▲"          : mDown  ? "Momentum:   FALLING ▼"            : "Momentum:   FLAT"
string dVol     = vBull  ? "Volume:         BIG BUY ▲"     : vBear  ? "Volume:         BIG SELL ▼"       : "Volume:         NORMAL"
string dWarn    = mOB    ? "Warning:        STRETCHED ⚠"   : mOS    ? "Warning:        STRETCHED ⚠"      : "Warning:        ALL CLEAR ✓"
string dScore   = score == 3 ? "Strength:      STRONG  3/3 ★★★" : score == 2 ? "Strength:      MODERATE  2/3 ★★" : "Strength:      WEAK  1/3 ★"
string dSig     = buyNow ? "Signal:          BUY NOW ▲"    : sellNow ? "Signal:          SELL NOW ▼"     : "Signal:          WAITING..."
string dBias    = isBull ? "Bias:              CALLS / LONGS" : isBear ? "Bias:              PUTS / SHORTS" : "Bias:              STAND ASIDE"
string dTF      = "Timeframe:    " + timeframe.period + " min"

color cGreen  = color.new(#26A69A, 20)
color cRed    = color.new(#EF5350, 20)
color cAmber  = color.new(#F57C00, 20)
color cNeutral= color.new(#37474F, 30)
color cDark   = color.new(#0D1117, 0)

color tWhite  = color.white
color tGrey   = color.new(#8B949E, 0)
color tAmber  = color.new(#FFB74D, 0)

color bgTrend  = isBull ? cGreen  : isBear ? cRed    : cNeutral
color bgMom    = mUp     ? cGreen  : mDown  ? cRed    : cNeutral
color bgVol    = vBull   ? cGreen  : vBear  ? cRed    : cNeutral
color bgWarn   = (mOB or mOS) ? cAmber : cNeutral
color bgScore  = score == 3 ? cGreen : score == 2 ? cAmber : cNeutral
color bgSig    = buyNow  ? cGreen  : sellNow ? cRed   : cNeutral
color bgBias   = isBull  ? cGreen  : isBear  ? cRed   : cNeutral

color txtTrend = isBull ? tWhite : isBear ? tWhite : tGrey
color txtMom   = mUp    ? tWhite : mDown  ? tWhite : tGrey
color txtVol   = vSurge ? tWhite : tGrey
color txtWarn  = (mOB or mOS) ? tAmber : color.new(#80CBC4, 0)
color txtScore = score == 3 ? tWhite : score == 2 ? tAmber : tGrey
color txtSig   = buyNow ? tWhite : sellNow ? tWhite : tGrey
color txtBias  = isBull ? tWhite : isBear  ? tWhite : tAmber

if showDash and barstate.islast
    var table t = table.new(position.top_right, 1, 10, bgcolor=cDark, border_color=color.new(#21262D, 0), border_width=1, frame_color=color.new(#30363D, 0), frame_width=1)

    table.cell(t, 0, 0, "⚡  ECS — EDGE CONFIRMATION SYSTEM", text_color=color.new(#F0B429, 0), bgcolor=color.new(#161B22, 0), text_halign=text.align_center, text_size=size.small)
    table.cell(t, 0, 1, dTrend,  text_color=txtTrend, bgcolor=bgTrend,  text_halign=text.align_left, text_size=size.small)
    table.cell(t, 0, 2, dMom,    text_color=txtMom,   bgcolor=bgMom,    text_halign=text.align_left, text_size=size.small)
    table.cell(t, 0, 3, dVol,    text_color=txtVol,   bgcolor=bgVol,    text_halign=text.align_left, text_size=size.small)
    table.cell(t, 0, 4, dWarn,   text_color=txtWarn,  bgcolor=bgWarn,   text_halign=text.align_left, text_size=size.small)
    table.cell(t, 0, 5, dScore,  text_color=txtScore, bgcolor=bgScore,  text_halign=text.align_left, text_size=size.small)
    table.cell(t, 0, 6, dSig,    text_color=txtSig,   bgcolor=bgSig,    text_halign=text.align_left, text_size=size.small)
    table.cell(t, 0, 7, dBias,   text_color=txtBias,  bgcolor=bgBias,   text_halign=text.align_left, text_size=size.small)
    table.cell(t, 0, 8, dTF,     text_color=tGrey,    bgcolor=cDark,    text_halign=text.align_left, text_size=size.small)
    table.cell(t, 0, 9, "For educational purposes only. Not financial advice.", text_color=color.new(#484F58, 0), bgcolor=cDark, text_halign=text.align_center, text_size=size.tiny)


// ─────────────────────────────────────────────
// ALERTS
// ─────────────────────────────────────────────

alertcondition(buyNow,  title="ECS BUY Signal",   message="ECS BUY on {{ticker}} at {{close}} — Look for CALLS")
alertcondition(sellNow, title="ECS SELL Signal",  message="ECS SELL on {{ticker}} at {{close}} — Look for PUTS")
alertcondition(vSurge,  title="ECS Volume Surge", message="ECS Volume Surge on {{ticker}} — Watch for move")
````
