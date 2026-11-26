# ChronoForge - Multi-Timeframe Trend and Momentum

- url: https://www.tradingview.com/script/BMW6dSsX-ChronoForge-Multi-Timeframe-Trend-and-Momentum/
- type: indicator
- pine_id: PUB;aa5488580c6d40998952853da4f88cc3
- version: 1.0

## Description

ChronoForge combines a requested-timeframe EMA trend spread, chart-timeframe RSI momentum, and a configurable session boost into one smoothed oscillator. It is designed for examining agreement between these components. It does not place orders or provide a strategy backtest.

The fast/slow EMA spread is divided by the chart timeframe's 14-bar ATR and clamped to -1 to +1. RSI is centered with (RSI - 50) / 50 and clamped to the same range. Each component is weighted. During any enabled session, one boost is added in the combined direction; at exactly zero, that boost is positive. The result is divided by the configured sum of weights, scaled to -100 to +100, and smoothed with an EMA. The configured session weight stays in the denominator even outside sessions or with session weighting disabled.

Teal indicates a score at or above the positive threshold, red at or below the negative threshold, and gray between the thresholds. LONG/SHORT labels and alert conditions mark new entries into those regions. The table shows bias, score, trend contribution, and session status.

Start by inspecting standard 5-minute candles with the default 60-minute requested timeframe. This is a demonstration configuration, not a performance recommendation. Choose a requested timeframe above the chart timeframe. Session windows use the symbol's exchange timezone; the Asia, London and New York labels do not automatically convert local times or daylight-saving changes. Adjust them for the symbol. Keep the threshold above zero to avoid overlapping LONG/SHORT conditions at zero.

The combined normalized score with directional session weighting is the specific design of this script. The underlying EMA and RSI methods are standard indicators; no claim of novel statistical methods or proven predictive value is made.

This script can repaint. The current chart bar and requested higher-timeframe values can change until their candles close, and results can differ after a reload. lookahead_off does not freeze an open higher-timeframe candle. Once Per Bar Close reduces transient chart-bar alert crossings but does not finalize higher-timeframe data. No trading performance, signal accuracy, alert delivery or profitability has been established.

## Source Code

````pine
//@version=6
// MIT License
// 
// Copyright (c) 2026 andrey3969
// 
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
// 
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
// 
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// ─────────────────────────────────────────────────────────────────────────────
//  ChronoForge — Multi-Timeframe Trend & Momentum Forge
//
//  ChronoForge fuses three independent "time" perspectives into a single,
//  normalized trend score:
//    1. Higher-timeframe trend bias (EMA fast/slow on a configurable HTF)
//    2. Local momentum (RSI re-centered around zero)
//    3. Trading-session context (Asia / London / New York)
//
//  The blended score is rendered as a smoothed oscillator plus an on-chart
//  bias label, so you can read both the "what" (long/short/flat) and the
//  "why" (which forces are aligned) at a glance.
// ─────────────────────────────────────────────────────────────────────────────
indicator("ChronoForge", shorttitle = "ChronoForge", overlay = false, max_labels_count = 100)

// ── Inputs ───────────────────────────────────────────────────────────────────
grpTrend   = "Trend Forge"
htfTf      = input.timeframe("60",  "Higher Timeframe",        group = grpTrend)
emaFastLen = input.int(21, "Fast EMA Length", minval = 1,      group = grpTrend)
emaSlowLen = input.int(55, "Slow EMA Length", minval = 1,      group = grpTrend)

grpMom     = "Momentum"
rsiLen     = input.int(14, "RSI Length",      minval = 1,      group = grpMom)
momWeight  = input.float(1.0, "Momentum Weight", minval = 0.0, maxval = 5.0, step = 0.1, group = grpMom)
trendWeight= input.float(1.5, "Trend Weight",    minval = 0.0, maxval = 5.0, step = 0.1, group = grpTrend)

grpChrono  = "Chrono / Sessions"
useSession = input.bool(true,  "Weight by Active Session",     group = grpChrono)
sessAsia   = input.session("0000-0800", "Asia Session",        group = grpChrono)
sessLondon = input.session("0800-1600", "London Session",      group = grpChrono)
sessNY     = input.session("1300-2100", "New York Session",    group = grpChrono)
sessWeight = input.float(0.5, "Session Boost", minval = 0.0, maxval = 3.0, step = 0.1, group = grpChrono)

grpSmooth  = "Output"
smoothLen  = input.int(5, "Score Smoothing", minval = 1,       group = grpSmooth)
threshold  = input.float(20.0, "Signal Threshold", minval = 0.0, maxval = 100.0, group = grpSmooth)

// ── Helpers ──────────────────────────────────────────────────────────────────
// Clamp a value into [-1, 1] without leaving the chart's numeric range.
clamp1(float x) =>
    math.max(-1.0, math.min(1.0, x))

// Is the current bar inside the given session string?
inSession(string s) =>
    not na(time(timeframe.period, s))

// ── Trend bias from a higher timeframe ───────────────────────────────────────
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
[htfFast, htfSlow] = request.security(syminfo.tickerid, htfTf, [emaFast, emaSlow], lookahead = barmerge.lookahead_off)

// Normalize the EMA spread by ATR so the score is comparable across symbols.
atr     = ta.atr(14)
spread  = atr > 0 ? (htfFast - htfSlow) / atr : 0.0
trendScore = clamp1(spread) * trendWeight

// ── Momentum, re-centered to [-1, 1] ─────────────────────────────────────────
rsi       = ta.rsi(close, rsiLen)
momScore  = clamp1((rsi - 50.0) / 50.0) * momWeight

// ── Chrono / session weighting ───────────────────────────────────────────────
activeSession = useSession and (inSession(sessAsia) or inSession(sessLondon) or inSession(sessNY))
sessBoost     = activeSession ? sessWeight : 0.0
// Session amplifies whichever directional pressure already exists.
directional   = trendScore + momScore
chronoScore   = directional + sessBoost * (directional >= 0 ? 1.0 : -1.0)

// ── Blend → normalized 0..±100 oscillator ────────────────────────────────────
maxRaw    = trendWeight + momWeight + sessWeight
rawScore  = maxRaw > 0 ? (chronoScore / maxRaw) * 100.0 : 0.0
score     = ta.ema(rawScore, smoothLen)

// ── Bias classification ──────────────────────────────────────────────────────
isLong  = score >=  threshold
isShort = score <= -threshold
bias    = isLong ? "LONG" : isShort ? "SHORT" : "FLAT"

// ── Plotting ─────────────────────────────────────────────────────────────────
colUp   = color.new(color.teal, 0)
colDn   = color.new(color.red,  0)
colFlat = color.new(color.gray, 20)
scoreCol = isLong ? colUp : isShort ? colDn : colFlat

plot(score, "ChronoForge Score", color = scoreCol, linewidth = 2)
hline( threshold, "Long Threshold",  color = color.new(color.teal, 60), linestyle = hline.style_dashed)
hline(-threshold, "Short Threshold", color = color.new(color.red,  60), linestyle = hline.style_dashed)
hline(0, "Zero", color = color.new(color.gray, 70))

bgcolor(activeSession ? color.new(color.blue, 92) : na, title = "Active Session")

// Mark fresh bias flips with a label.
flippedLong  = isLong  and not isLong[1]
flippedShort = isShort and not isShort[1]
if flippedLong
    label.new(bar_index, score, "▲ LONG", style = label.style_label_down,
              color = colUp, textcolor = color.white, size = size.small)
if flippedShort
    label.new(bar_index, score, "▼ SHORT", style = label.style_label_up,
              color = colDn, textcolor = color.white, size = size.small)

// ── Status table ─────────────────────────────────────────────────────────────
var table tbl = table.new(position.top_right, 2, 4, border_width = 1)
if barstate.islast
    table.cell(tbl, 0, 0, "Bias",     text_color = color.white, bgcolor = color.new(color.black, 30))
    table.cell(tbl, 1, 0, bias,       text_color = scoreCol,    bgcolor = color.new(color.black, 30))
    table.cell(tbl, 0, 1, "Score",    text_color = color.white)
    table.cell(tbl, 1, 1, str.tostring(score, "#.0"), text_color = scoreCol)
    table.cell(tbl, 0, 2, "Trend",    text_color = color.white)
    table.cell(tbl, 1, 2, str.tostring(trendScore, "#.00"), text_color = color.gray)
    table.cell(tbl, 0, 3, "Session",  text_color = color.white)
    table.cell(tbl, 1, 3, activeSession ? "ON" : "OFF", text_color = activeSession ? colUp : colFlat)

// ── Alerts ───────────────────────────────────────────────────────────────────
alertcondition(flippedLong,  "ChronoForge LONG",  "ChronoForge flipped LONG")
alertcondition(flippedShort, "ChronoForge SHORT", "ChronoForge flipped SHORT")
````
