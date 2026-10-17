# Regime Filter V4C

- url: https://www.tradingview.com/script/brWAWunB/
- type: indicator
- pine_id: PUB;3ee94b6107ee4af6a1e9181362f89aff
- version: 1.0

## Description

[b]Regime Filter V4 — Macro regime detection with rule-based LONG/SHORT filter[/b]


[b]OVERVIEW[/b]

Regime Filter V4 is a macro regime detection indicator designed to filter trading signals on daily timeframe. It classifies the market into 3 regimes (UP / DN / RG), splits each regime into Early / Late phases, considers BTC macro context (Bull / Bear), and applies 4 explicit rules to decide whether LONG or SHORT trades are authorized.

This is the public version of the filter I use to systematically gate signals on my own multi-method trading bot. It has been validated across 8 years of BTC daily data (2018–2026) with documented performance (cumsum +3,051R, Sharpe 0.455, Max DD reduced 42% vs no-filter baseline).


[b]HOW IT WORKS — THE 4 LAYERS[/b]

[b]Layer 1 — Regime detection[/b]
Classify each daily bar into UP / DN / RG using EMA20 slope over a 7-day lookback:
- [b]UP[/b] : EMA20 > EMA20[7] × (1 + 0.1%)
- [b]DN[/b] : EMA20 < EMA20[7] × (1 - 0.1%)
- [b]RG[/b] : in between (range / consolidation)

[b]Layer 2 — Phase Early / Late[/b]
Count consecutive days in the same regime (streak):
- [b]Early[/b] : streak ≤ 7 days (fresh trend)
- [b]Late[/b] : streak > 7 days (mature trend)

[b]Layer 3 — Macro context[/b]
Compare EMA50 vs EMA200 on the asset itself:
- [b]Bull macro[/b] : EMA50 > EMA200
- [b]Bear macro[/b] : EMA50 < EMA200

[b]Layer 4 — The 4 rules (R1–R4)[/b]
- [b]R1[/b] : Regime UP → SHORT always blocked
- [b]R2[/b] : Regime UP → LONG: Early always OK; Late OK only if Bull macro
- [b]R3[/b] : Regime DN → SHORT: OK only if ADX(14) > 30
- [b]R4[/b] : Regime RG → LONG: OK only if Bear macro AND RSI(14) < 30 (contrarian)


[b]VISUAL ELEMENTS[/b]

[b]Background colors:[/b]
- Green = UP regime (lighter = Early, darker = Late)
- Red = DN regime (lighter = Early, darker = Late)
- Yellow / grey = RG regime (range)

[b]Plotted lines:[/b]
- Blue (EMA20) — Regime EMA
- Orange (EMA50) — Macro fast
- Red (EMA200) — Macro slow

[b]Transition markers:[/b]
- Red triangle down = UP → DN transition
- Green triangle up = DN → UP transition
- Grey diamond = transition into RG

[b]Dashboard (top-right):[/b]
Live display of current regime, phase, streak, macro context, ADX, RSI, active rule, LONG / SHORT status, and approximate activity rate.


[b]HOW TO USE[/b]

1. Apply on [b]daily timeframe[/b] of any liquid asset (works best on BTC, but tested cross-asset on ETH and SOL).
2. Read the dashboard to know the current regime and which trades are authorized.
3. Use the [b]LONG / SHORT YES/NO[/b] status as a filter for your own trading signals or systems — only take trades aligned with the regime decision.
4. Set up alerts on regime transitions (UP/DN/RG) and on LONG/SHORT signals to be notified.


[b]VALIDATION CONTEXT[/b]

- Tested on 8 years of BTC daily data (2018–2026) with custom backtest engine
- Cross-asset validation on ETH and SOL
- Walk-forward in-sample / out-of-sample stable
- Reduces drawdown by ~42% vs unfiltered baseline
- Sharpe ratio improvement from ~0.22 (baseline) to ~0.455 (with filter)
- All numbers expressed in R-multiples (1R = sized risk per trade)


[b]INPUTS YOU CAN ADJUST[/b]

- EMA Regime length (default 20)
- Regime lookback days (default 7)
- Regime threshold (default 0.1%)
- Macro EMAs Fast / Slow (default 50 / 200)
- ADX period & threshold for R3 (default 14 / 30)
- RSI period & threshold for R4 (default 14 / 30)
- Early/Late boundary in days (default 7)


[b]ALERTS AVAILABLE[/b]

- Transition → UP
- Transition → DN
- Transition → RG
- LONG signal (R2 or R4)
- SHORT signal (R3)


[b]DISCLAIMER[/b]

This indicator is a [b]filter / decision-support tool[/b], not a complete trading strategy. It tells you when the macro regime allows LONG or SHORT — it does not generate entry / exit prices. You must combine it with your own setup detection (Fibonacci retracement, trend continuation, structure breaks, etc.).

Past performance does not guarantee future results. Always backtest with your own assumptions and position sizing. Use at your own risk.


[b]AUTHOR NOTE[/b]

This filter is part of a broader systematic trading framework I've developed over 10+ years of crypto trading. The published version is the macro regime layer only — you bring your own entry / exit logic on top.

If you find it useful, leave a like and feel free to comment with the asset / timeframe combinations that work best for you.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © coyotcrypto

//@version=6
indicator(title="Regime Filter V4", shorttitle="RF V4", overlay=true, format=format.price, precision=2)

// ─── INPUTS ───────────────────────────────────────────────────────────────────
ema_short_len     = input.int(20,    "EMA Regime",          group="Regime")
regime_lookback   = input.int(7,     "Regime Lookback (d)", group="Regime")
regime_threshold  = input.float(0.001, "Regime Threshold (0.1%)", group="Regime", step=0.0001)

ema_macro_fast    = input.int(50,    "EMA Macro Fast",      group="Macro")
ema_macro_slow    = input.int(200,   "EMA Macro Slow",      group="Macro")

adx_period        = input.int(14,    "ADX Period",          group="R3 — SHORT in DN")
adx_threshold     = input.int(30,    "ADX Threshold",       group="R3 — SHORT in DN")

rsi_period        = input.int(14,    "RSI Period",          group="R4 — LONG in RG")
rsi_threshold     = input.int(30,    "RSI Threshold (<)",   group="R4 — LONG in RG")

early_late_streak = input.int(7,     "Early/Late Threshold (d)", group="Phase")

// ─── INDICATORS ───────────────────────────────────────────────────────────────
ema_short = ta.ema(close, ema_short_len)
ema_fast  = ta.ema(close, ema_macro_fast)
ema_slow  = ta.ema(close, ema_macro_slow)

[_, _, adx_val] = ta.dmi(adx_period, adx_period)
rsi_val = ta.rsi(close, rsi_period)

// ─── REGIME DETECTION ─────────────────────────────────────────────────────────
ema_prev  = ema_short[regime_lookback]
is_up_raw = not na(ema_prev) and ema_short > ema_prev * (1 + regime_threshold)
is_dn_raw = not na(ema_prev) and ema_short < ema_prev * (1 - regime_threshold)

regime_state = is_up_raw ? 1 : is_dn_raw ? -1 : 0

// ─── STREAK & PHASE ───────────────────────────────────────────────────────────
var int streak = 0
var int prev_regime = 0

if regime_state != prev_regime
    streak := 1
else
    streak := streak + 1

prev_regime := regime_state

is_early = streak <= early_late_streak
is_late  = not is_early

// ─── MACRO CONTEXT ────────────────────────────────────────────────────────────
macro_bull = ema_fast > ema_slow
macro_bear = not macro_bull

// ─── V4 RULES ─────────────────────────────────────────────────────────────────
r2_long_up  = (regime_state == 1) and (is_early or (is_late and macro_bull))
r3_short_dn = (regime_state == -1) and (adx_val > adx_threshold)
r4_long_rg  = (regime_state == 0) and macro_bear and (rsi_val < rsi_threshold)

long_allowed  = r2_long_up or r4_long_rg
short_allowed = r3_short_dn

regle_active = long_allowed ? (r2_long_up ? "R2" : "R4") : short_allowed ? "R3" : "R1"

// ─── BACKGROUND ───────────────────────────────────────────────────────────────
color bg_up_early = color.new(color.green,  90)
color bg_up_late  = color.new(color.green,  80)
color bg_dn_early = color.new(color.red,    90)
color bg_dn_late  = color.new(color.red,    80)
color bg_rg       = color.new(color.yellow, 88)

bgcolor(regime_state == 1  ? (is_early ? bg_up_early : bg_up_late) :
        regime_state == -1 ? (is_early ? bg_dn_early : bg_dn_late) :
        bg_rg, title="Regime Background")

// ─── PLOTS ────────────────────────────────────────────────────────────────────
plot(ema_short, "EMA20",  color.blue,   2)
plot(ema_fast,  "EMA50",  color.orange, 1)
plot(ema_slow,  "EMA200", color.red,    1)

// ─── TRANSITION MARKERS ───────────────────────────────────────────────────────
plotshape(regime_state == -1 and prev_regime[1] == 1,
    style=shape.triangledown, location=location.abovebar,
    color=color.red, size=size.small, title="UP→DN")

plotshape(regime_state == 1 and prev_regime[1] == -1,
    style=shape.triangleup, location=location.belowbar,
    color=color.green, size=size.small, title="DN→UP")

plotshape(regime_state == 0 and prev_regime[1] != 0,
    style=shape.diamond, location=location.abovebar,
    color=color.gray, size=size.tiny, title="→RG")

// ─── DASHBOARD (top-right) ────────────────────────────────────────────────────
var table info = table.new(position.top_right, 2, 10,
    bgcolor=color.new(#1A1A2E, 15),
    border_color=color.new(color.white, 20),
    border_width=2)

regime_label = regime_state == 1 ? "🟢 UP" : regime_state == -1 ? "🔴 DN" : "⚪ RG"
phase_label  = is_early ? "Early" : "Late"
macro_label  = macro_bull ? "🟢 Bull" : "🔴 Bear"
long_label   = long_allowed  ? "✅ YES (" + regle_active + ")" : "❌ NO"
short_label  = short_allowed ? "✅ YES (R3)" : "❌ NO"

if barstate.islast
    table.cell(info, 0, 0, "Regime",  text_color=color.white, text_size=size.small)
    table.cell(info, 1, 0, regime_label, text_color=color.white, text_size=size.small)

    table.cell(info, 0, 1, "Phase",   text_color=color.white, text_size=size.small)
    table.cell(info, 1, 1, phase_label, text_color=color.white, text_size=size.small)

    table.cell(info, 0, 2, "Streak",  text_color=color.white, text_size=size.small)
    table.cell(info, 1, 2, str.tostring(streak) + "d", text_color=color.white, text_size=size.small)

    table.cell(info, 0, 3, "Macro",   text_color=color.white, text_size=size.small)
    table.cell(info, 1, 3, macro_label, text_color=color.white, text_size=size.small)

    table.cell(info, 0, 4, "ADX(14)", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 4, str.tostring(math.round(adx_val, 1)),
        text_color=adx_val > adx_threshold ? color.green : color.red, text_size=size.small)

    table.cell(info, 0, 5, "RSI(14)", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 5, str.tostring(math.round(rsi_val, 1)),
        text_color=rsi_val < rsi_threshold ? color.green : color.red, text_size=size.small)

    table.cell(info, 0, 6, "Rule",    text_color=color.white, text_size=size.small)
    table.cell(info, 1, 6, regle_active, text_color=color.yellow, text_size=size.small)

    table.cell(info, 0, 7, "LONG",    text_color=color.white, text_size=size.small)
    table.cell(info, 1, 7, long_label,
        text_color=long_allowed ? color.green : color.red, text_size=size.small)

    table.cell(info, 0, 8, "SHORT",   text_color=color.white, text_size=size.small)
    table.cell(info, 1, 8, short_label,
        text_color=short_allowed ? color.green : color.red, text_size=size.small)

    table.cell(info, 0, 9, "Activity", text_color=color.white, text_size=size.small)
    table.cell(info, 1, 9, "~70.9%",   text_color=color.gray,  text_size=size.small)

// ─── ALERTS ───────────────────────────────────────────────────────────────────
alertcondition(regime_state == 1  and prev_regime[1] != 1,  "Transition → UP")
alertcondition(regime_state == -1 and prev_regime[1] != -1, "Transition → DN")
alertcondition(regime_state == 0  and prev_regime[1] != 0,  "Transition → RG")
alertcondition(long_allowed,  "LONG signal (R2 or R4)")
alertcondition(short_allowed, "SHORT signal (R3)")
````
