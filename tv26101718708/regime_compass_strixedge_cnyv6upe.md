# Regime Compass [StrixEDGE]

- url: https://www.tradingview.com/script/cnyv6uPE-Regime-Compass-StrixEDGE/
- type: indicator
- pine_id: PUB;8cfee10671594fef832c0ffc3b211d52
- version: 1.0

## Description

[b]StrixEDGE - Regime Compass[/b]

[b]01 · Purpose and analytical question[/b]
Classifies trending, compressing and transitional regimes using EMA slope, RSI, ADX and ATR-normalized separation with persistence. Use this study to classify market context before considering any trade, rather than treating a single oscillator or trend label as an execution instruction. The intended result is a readable analytical interpretation, not a claim about future prices, institutional intent, or guaranteed trade outcomes.

[b]02 · Analytical framework[/b]
The concept combines Trend Indicators, Momentum Indicators, Volatility Indicators, Statistical & Quantitative. These components serve one defined workflow: Classifies trending, compressing and transitional regimes using EMA slope, RSI, ADX and ATR-normalized separation with persistence. For implementation, inputs, sampling windows, thresholds and the exact decision hierarchy must be disclosed and validated against both historical and developing bars. Bars and signals that require confirmation should be explicitly distinguished from provisional readings.

[b]03 · StrixEDGE dashboard[/b]
The proposed compact dashboard organizes the most important observations without hiding the underlying price action:
[list]
[*] Confirmed regime: a dedicated field in the proposed StrixEDGE information panel.
[*] Candidate regime: a dedicated field in the proposed StrixEDGE information panel.
[*] ADX: a dedicated field in the proposed StrixEDGE information panel.
[*] ATR gap: a dedicated field in the proposed StrixEDGE information panel.
[*] Data / bar status: visibility into missing inputs and whether a value is confirmed or still forming.
[/list]
Actual calculations and visual states must match the final audited code.

[b]04 · Suggested workflow[/b]
1. Select the market and chart timeframe you are analysing.
2. Review the primary state together with its supporting measurements.
3. Compare the conclusion against independent structure and nearby price levels.
4. Recheck the result after the relevant bar closes; use any alerts as prompts for review, not orders.

[b]05 · Alert specification[/b]
The following are planned, not certified working alerts:
[list]
[*] Regime confirmed: a proposed event requiring a precise, independently tested trigger and clear bar-confirmation timing.
[*] Compression started: a proposed event requiring a precise, independently tested trigger and clear bar-confirmation timing.
[/list]
Alert frequency and the meaning of a confirmed signal must be documented after TradingView testing. An alert does not constitute an order or a trading recommendation.

[b]06 · What distinguishes the design[/b]
The intended contribution is a task-specific integration that Classifies trending, compressing and transitional regimes using EMA slope, RSI, ADX and ATR-normalized separation with persistence, with explicit context and diagnostic dashboard fields. Merely combining standard indicators is not sufficient originality; the implemented source and its value to users require an independent review before public release.

[b]07 · Data, limitations and reliability[/b]
Data requirements: OHLCV. Primary limitation: Regime thresholds require calibration. Trend measures describe direction, not the certainty of continuation. Momentum readings can remain extreme while a trend persists. Volatility adapts with market conditions and is not inherently directional. Indicator values may depend on the exchange feed, session settings, available history, instrument liquidity and the selected timeframe. Test on appropriate chart types, avoid future data leakage and verify the behavior of higher-timeframe series, pivots and intrabar signals wherever relevant.

[i]Educational and analytical use only. No return, win-rate, broker execution or non-repainting guarantee is asserted.[/i]

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © StrixEDGE

//@version=6
indicator("Regime Compass [StrixEDGE]", shorttitle="Regime Compass [StrixEDGE]", overlay=true)
// StrixEDGE | Regime Compass | 1.0.0
// Purpose: Classify confirmed trend, compression, and transition regimes.
// Educational analytics; no forecast or trade execution.

grpCore = "01 | Regime Model"
fastLen = input.int(21, "Fast EMA", minval=2, group=grpCore)
slowLen = input.int(55, "Slow EMA", minval=3, group=grpCore)
rsiLen = input.int(14, "RSI length", minval=2, group=grpCore)
adxLen = input.int(14, "DI length", minval=2, group=grpCore)
adxSmooth = input.int(14, "ADX smoothing", minval=2, group=grpCore)
atrLen = input.int(14, "ATR length", minval=2, group=grpCore)
trendAdx = input.float(23.0, "Trending ADX floor", minval=5, maxval=70, step=0.5, group=grpCore)
neutralAdx = input.float(17.0, "Compression ADX ceiling", minval=5, maxval=50, step=0.5, group=grpCore)
minGap = input.float(0.25, "Minimum EMA gap (ATR)", minval=0.01, maxval=5, step=0.05, group=grpCore)
confirmBars = input.int(2, "Confirmed bars to accept regime", minval=1, maxval=10, group=grpCore)

grpView = "02 | Visuals"
showSignals = input.bool(true, "Show regime change markers", group=grpView)
showDashboard = input.bool(true, "Show dashboard", group=grpView)

fast = ta.ema(close, fastLen)
slow = ta.ema(close, slowLen)
rsi = ta.rsi(close, rsiLen)
atr = ta.atr(atrLen)
[plusDI, minusDI, adx] = ta.dmi(adxLen, adxSmooth)
atrSafe = math.max(nz(atr, syminfo.mintick), syminfo.mintick)
gapAtr = math.abs(fast - slow) / atrSafe
bool ready = not na(slow) and not na(rsi) and not na(adx) and not na(atr)
int raw = not ready ? 0 : adx <= neutralAdx and gapAtr < minGap ? 3 : adx >= trendAdx and gapAtr >= minGap and fast > slow and rsi >= 52 and plusDI > minusDI ? 1 : adx >= trendAdx and gapAtr >= minGap and fast < slow and rsi <= 48 and minusDI > plusDI ? -1 : 0

// Regimes: +1 bullish, -1 bearish, 3 compressed, 0 transitional.
// A new state requires N completed bars of persistence. Historical markers
// are placed on the actual confirmation bar, never shifted into the past.
var int regime = 0
var int candidate = 0
var int streak = 0
if barstate.isconfirmed
    if raw == candidate
        streak += 1
    else
        candidate := raw
        streak := 1
    if streak >= confirmBars
        regime := candidate

bool becameBull = barstate.isconfirmed and regime == 1 and regime[1] != 1
bool becameBear = barstate.isconfirmed and regime == -1 and regime[1] != -1
bool becameCompress = barstate.isconfirmed and regime == 3 and regime[1] != 3

plot(fast, "Fast EMA", color=color.new(color.aqua, 0), linewidth=2)
plot(slow, "Slow EMA", color=color.new(color.orange, 0), linewidth=2)
plotshape(showSignals and becameBull, title="Bullish regime confirmed", style=shape.triangleup, location=location.belowbar, size=size.tiny, color=color.lime, text="R+")
plotshape(showSignals and becameBear, title="Bearish regime confirmed", style=shape.triangledown, location=location.abovebar, size=size.tiny, color=color.red, text="R-")
plotshape(showSignals and becameCompress, title="Compression confirmed", style=shape.circle, location=location.bottom, size=size.tiny, color=color.yellow)

string regimeText = regime == 1 ? "TREND UP" : regime == -1 ? "TREND DOWN" : regime == 3 ? "COMPRESSION" : "TRANSITION"
color regimeColor = regime == 1 ? color.lime : regime == -1 ? color.red : regime == 3 ? color.yellow : color.silver
var table dash = table.new(position.top_right, 2, 8, bgcolor=color.new(#101827, 5), border_width=1, border_color=#334155)
if barstate.islast and showDashboard
    table.cell(dash, 0, 0, "StrixEDGE", text_color=color.aqua, bgcolor=#142234)
    table.cell(dash, 1, 0, "REGIME COMPASS", text_color=color.white, bgcolor=#142234)
    table.cell(dash, 0, 1, "Confirmed state", text_color=color.silver)
    table.cell(dash, 1, 1, regimeText, text_color=regimeColor)
    table.cell(dash, 0, 2, "Current candidate", text_color=color.silver)
    table.cell(dash, 1, 2, raw == 1 ? "UP" : raw == -1 ? "DOWN" : raw == 3 ? "COMPRESSED" : "NEUTRAL", text_color=color.white)
    table.cell(dash, 0, 3, "ADX / floor", text_color=color.silver)
    table.cell(dash, 1, 3, str.tostring(adx, "#.0") + " / " + str.tostring(trendAdx, "#.0"), text_color=color.white)
    table.cell(dash, 0, 4, "EMA gap / ATR", text_color=color.silver)
    table.cell(dash, 1, 4, str.tostring(gapAtr, "#.00"), text_color=color.white)
    table.cell(dash, 0, 5, "RSI", text_color=color.silver)
    table.cell(dash, 1, 5, str.tostring(rsi, "#.0"), text_color=color.white)
    table.cell(dash, 0, 6, "Persistence", text_color=color.silver)
    table.cell(dash, 1, 6, str.tostring(math.min(streak, confirmBars)) + " / " + str.tostring(confirmBars), text_color=color.white)
    table.cell(dash, 0, 7, "Bar status", text_color=color.silver)
    table.cell(dash, 1, 7, barstate.isconfirmed ? "CLOSED" : "FORMING", text_color=barstate.isconfirmed ? color.lime : color.yellow)
if barstate.islast and not showDashboard
    table.clear(dash, 0, 0, 1, 7)

alertcondition(becameBull, "StrixEDGE confirmed bullish regime", "StrixEDGE Regime Compass: confirmed bullish regime on {{ticker}} {{interval}}")
alertcondition(becameBear, "StrixEDGE confirmed bearish regime", "StrixEDGE Regime Compass: confirmed bearish regime on {{ticker}} {{interval}}")
alertcondition(becameCompress, "StrixEDGE confirmed compression", "StrixEDGE Regime Compass: confirmed compression on {{ticker}} {{interval}}")
````
