# Global Macro Bias Indicator

- url: https://www.tradingview.com/script/0o5lgf6V-Global-Macro-Bias-Indicator/
- type: indicator
- pine_id: PUB;bc3e889e76504ba3a3dd421aacf547c8
- version: 1.0

## Description

[b]Global Macro Bias — Know the Environment Before You Trade[/b]

Most traders lose not because their setup was wrong — but because they traded against the macro environment without knowing it.

This indicator reads the macro backdrop for you. Every bar. Automatically.

It watches three things the big money watches:
— Whether the bond market is signaling growth or fear
— Whether the dollar is expanding or draining global liquidity
— Whether the market is in appetite or protection mode

Then it gives you one clear read:
🟢 RISK-ON — the environment favors longs and risk assets
🔴 RISK-OFF — the environment favors caution and safety
⚪ NEUTRAL — signals are mixed, better to wait

[i]No numbers to crunch. No settings to change. You open the chart and you know.[/i]

How to use it:
— Before you take any trade, glance at the bias
— If you're looking to [b]buy [/b]and it says [b]RISK-OFF[/b], that's your warning
— If it says [b]RISK-ON STRONG[/b] and your setup aligns — that's confluence
— [b]NEUTRAL [/b]means the macro isn't giving a clear edge, reduce size or wait

Works on any chart, any asset. Stocks, forex, crypto, commodities — macro affects everything.

[i]If this helped you see the bigger picture, like and follow. More macro tools coming.[/i]

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// © GlobalMacroBias v2.0
//
// GLOBAL MACRO BIAS -- Simple Edition
// One signal. One color. No math on your end.
//
// GREEN  = Macro aligned RISK-ON  -- favor longs, risk assets
// RED    = Macro aligned RISK-OFF -- favor shorts, safe havens
// GRAY   = Mixed signals          -- stay flat, wait for clarity
//
// Built on: Yield Curve (2s10s) + DXY Momentum + VIX Regime
// ─────────────────────────────────────────────────────────────

//@version=5
indicator(title="Global Macro Bias [GMB]", shorttitle="GMB", overlay=false)

// ── DATA ──────────────────────────────────────────────────────
t10y = request.security("TVC:US10Y", timeframe.period, close, ignore_invalid_symbol=true)
t2y  = request.security("TVC:US02Y", timeframe.period, close, ignore_invalid_symbol=true)
dxy  = request.security("TVC:DXY",   timeframe.period, close, ignore_invalid_symbol=true)
vix  = request.security("CBOE:VIX",  timeframe.period, close, ignore_invalid_symbol=true)

// ── SIGNALS ───────────────────────────────────────────────────
spread      = t10y - t2y
spreadSlope = ta.sma(spread, 20) - ta.sma(spread, 20)[5]
ycSignal    = spreadSlope > 0.10 ? 1 : spreadSlope < -0.10 ? -1 : 0

dxyROC    = ta.roc(dxy, 14)
dxySignal = dxyROC < -0.30 ? 1 : dxyROC > 0.30 ? -1 : 0

vixSmooth = ta.ema(vix, 10)
vixSignal = vixSmooth < 15 ? 1 : vixSmooth > 20 ? -1 : 0

score = ycSignal + dxySignal + vixSignal

// ── BIAS DEFINITION ───────────────────────────────────────────
// Strong = 2 or 3 signals aligned
// Weak   = only 1 signal firing
// Neutral = signals conflicting or flat

isStrongBull = score >= 2
isWeakBull   = score == 1
isNeutral    = score == 0
isWeakBear   = score == -1
isStrongBear = score <= -2

// ── COLORS ────────────────────────────────────────────────────
C_STRONG_BULL = #26a69a
C_WEAK_BULL   = color.new(#26a69a, 55)
C_NEUTRAL     = color.new(#9e9e9e, 40)
C_WEAK_BEAR   = color.new(#ef5350, 55)
C_STRONG_BEAR = #ef5350

biasColor = isStrongBull ? C_STRONG_BULL : isWeakBull ? C_WEAK_BULL : isNeutral ? C_NEUTRAL : isWeakBear ? C_WEAK_BEAR : C_STRONG_BEAR

// ── SINGLE BAR PLOT ───────────────────────────────────────────
// One solid bar. Tall when strong. Short when weak.
biasLevel = isStrongBull ? 3 : isWeakBull ? 1 : isNeutral ? 0 : isWeakBear ? -1 : -3

plot(biasLevel, "Macro Bias", style=plot.style_histogram, color=biasColor, linewidth=4)
hline(0, "Flat", color=color.new(color.gray, 60), linewidth=1)

// Chart background tint -- subtle, not distracting
bgcolor(isStrongBull ? color.new(#26a69a, 88) : isWeakBull   ? color.new(#26a69a, 94) : isStrongBear ? color.new(#ef5350, 88) : isWeakBear ? color.new(#ef5350, 94) : na, title="Bias Background")

// ── DASHBOARD TABLE ───────────────────────────────────────────
// Simple 1-column card. No numbers. Just the read.

biasText  = isStrongBull ? "RISK-ON" : isWeakBull ? "RISK-ON" : isNeutral ? "NEUTRAL" : isWeakBear ? "RISK-OFF" : "RISK-OFF"
strengthText = isStrongBull ? "STRONG" : isWeakBull ? "BUILDING" : isNeutral ? "MIXED" : isWeakBear ? "BUILDING" : "STRONG"

ycText  = ycSignal  ==  1 ? "Curve steepening  [+]" : ycSignal  == -1 ? "Curve flattening  [-]" : "Curve flat        [=]"
dxyText = dxySignal ==  1 ? "Dollar weakening  [+]" : dxySignal == -1 ? "Dollar rising     [-]" : "Dollar flat       [=]"
vixText = vixSignal ==  1 ? "VIX calm          [+]" : vixSignal == -1 ? "VIX elevated      [-]" : "VIX neutral       [=]"

var table dash = table.new(position.top_right, 1, 7, border_width=1, border_color=color.new(color.gray, 70), frame_width=1, frame_color=color.new(color.gray, 60))

if barstate.islast
    // Bias header -- big and obvious
    table.cell(dash, 0, 0, "MACRO BIAS", bgcolor=color.new(#1a1a2e, 5), text_color=color.new(color.white, 20), text_size=size.small, text_halign=text.align_center)

    // The one thing traders need to see
    table.cell(dash, 0, 1, biasText, bgcolor=biasColor, text_color=color.white, text_size=size.huge, text_halign=text.align_center)
    table.cell(dash, 0, 2, strengthText, bgcolor=color.new(biasColor, 40), text_color=color.white, text_size=size.normal, text_halign=text.align_center)

    // Divider
    table.cell(dash, 0, 3, "── what's driving it ──", bgcolor=color.new(color.gray, 88), text_color=color.new(color.gray, 30), text_size=size.tiny, text_halign=text.align_center)

    // Signal breakdown -- plain English, no numbers
    table.cell(dash, 0, 4, ycText,  bgcolor=color.new(color.gray, 90), text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 0, 5, dxyText, bgcolor=color.new(color.gray, 90), text_color=color.silver, text_size=size.small, text_halign=text.align_left)
    table.cell(dash, 0, 6, vixText, bgcolor=color.new(color.gray, 90), text_color=color.silver, text_size=size.small, text_halign=text.align_left)

// ── ALERTS ────────────────────────────────────────────────────
alertcondition(isStrongBull,                          "Strong Risk-On",  "GMB: Macro fully aligned BULLISH -- risk assets favored")
alertcondition(isStrongBear,                          "Strong Risk-Off", "GMB: Macro fully aligned BEARISH -- safe havens favored")
alertcondition(ta.crossover(score,  1),               "Bias shifting Risk-On",  "GMB: Macro bias turning bullish")
alertcondition(ta.crossunder(score, -1),              "Bias shifting Risk-Off", "GMB: Macro bias turning bearish")
````
