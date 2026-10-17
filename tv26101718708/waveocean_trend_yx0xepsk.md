# Wave-Ocean Trend

- url: https://www.tradingview.com/script/yx0xePsK/
- type: indicator
- pine_id: PUB;9037aef568064e199ff525e301285973
- version: 8.0

## Description

Wave-Ocean Trend 

 Description

Wave-Ocean Trend is a momentum indicator based on a combination of Exponential Moving Averages (EMA), mean deviation, and Simple Moving Average (SMA).

The indicator is designed to help visualize market direction and momentum changes  through the relationship between two waves:

* X1 — Aqua:  the fast wave, designed to respond to changes in momentum.
* X2 — Orange: the smoothed wave, used as a reference for identifying changes in market momentum.

## How to Use

 🌊 Bullish Crossover

When X1 (Aqua) crosses above X2 (Orange), an  Aqua ball appears.

This event represents a potential shift in momentum to the upside and can be used as a reference when analyzing possible bullish movements.

 🔻 Bearish Crossover

When **X1 (Aqua)** crosses below **X2 (Orange)**, a **red-orange ball** appears.

This event represents a potential shift in momentum to the downside and can be used as a reference when analyzing possible bearish movements.

 Reference Zones

The indicator includes two main reference zones:

* Above +60: elevated momentum zone.
* Below -60: negative momentum zone.
* Between +60 and -60: intermediate momentum zone.

These zones should not be interpreted independently as automatic buy or sell signals. They are intended to provide additional context when evaluating momentum.

## X1-X2 Area

The area between X1 and X2 helps visualize the difference between the two waves:

* Green: X1 is above X2.
* Red: X1 is below X2.

A wider separation between the waves indicates a larger momentary difference between fast momentum and its smoothed reference.

 Settings

The indicator has two main parameters:

Fast Wave ⚡ — Default: 10
Controls the responsiveness of the fast wave.

Slow Wave 🐌 — Default: 21
Controls the smoothing of the reference wave.

Lower values may make the indicator more responsive to market changes, while higher values generally produce a smoother reading.

 Suggested Use

Wave-Ocean Trend can be used together with:

* Market structure
* Support and resistance
* Higher-timeframe trend
* Volume
* Price action
* Risk management

One possible approach is to identify the broader trend on a higher timeframe and then use Wave-Ocean Trend crossovers on a lower timeframe to evaluate momentum within that context.

 Important

Wave-Ocean Trend is a **technical analysis tool and does not guarantee financial results.

No crossover should be considered, by itself, a recommendation to buy or sell. Signals may occur during consolidation, choppy markets, or periods of high volatility and should be evaluated within the broader market context.

Use proper risk management and perform your own testing before using the indicator in live trading.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at
// https://mozilla.org/MPL/2.0/

// © Canhoto-Medium

//@version=6
indicator("Wave-Ocean Trend", shorttitle="WT-Ocean", precision=0, overlay=false)

// === Inputs Config ⚙️ ===

p1 = input.int(10, "Fast Wave ⚡", group="🔔 Sound Alerts")
p2 = input.int(21, "Slow Wave 🐌", group="🔔 Sound Alerts")

// === Multi-Timeframe Alert Alignment ===

mtfMode = input.string("Triple", "Alignment Mode", options=["Dual", "Triple"],display=display.none, group="🕒 Multi-Timeframe Alerts")
tf1     = input.timeframe("60",  "Timeframe 1", group="🕒 Multi-Timeframe Alerts", display=display.none)
tf2     = input.timeframe("240", "Timeframe 2", group="🕒 Multi-Timeframe Alerts", display=display.none)
tf3     = input.timeframe("D",   "Timeframe 3", group="🕒 Multi-Timeframe Alerts", display=display.none)

// === Wave-Trend Formula ===

alfa = hlc3
beta = ta.ema(alfa, p1)
m = ta.ema(math.abs(alfa - beta), p1)
omega = ta.ema((alfa - beta) / (0.015 * m), p2)

x1 = omega
x2 = ta.sma(x1, 4)

// === Reference Levels ===

midLine = 0

upLine = input.int(60, "Upper Line", group="🔔 Sound Alerts", display=display.none)
lowLine = input.int(-60, "Lower Line", group="🔔 Sound Alerts", display=display.none)

// === Reference Plots ===

pMid = plot(midLine, title="Mid Line", linewidth=2, color=color.new(color.gray, 100), display=display.pane, editable=false)
pUp = plot(upLine, title="Upper Line", linewidth=3, color=color.new(color.red, 100), display=display.pane, editable=false)
pLow = plot(lowLine, title="Lower Line", linewidth=3, color=color.new(color.lime, 100), display=display.pane, editable=false)

// === Background ===

fill(pUp, pMid, color=color.new(color.orange, 75), title="BG Color Bear")
fill(pLow, pMid, color=color.new(color.blue, 75), title="BG Color Bull")

// =====================================================
// === X1-X2 AREA — WAVE STATE
// =====================================================

waveBull = x1 > x2
waveBear = x1 < x2

plot(x1 - x2, color=waveBull ? color.new(color.green, 20) : color.new(color.red, 20), style=plot.style_areabr, title="X1-X2 Wave")

// === Wave State Change ===

waveBullChange = waveBull and not waveBull[1]
waveBearChange = waveBear and not waveBear[1]

// === Confirmed Wave State Change ===

waveBullChangeConfirmed = waveBullChange and barstate.isconfirmed
waveBearChangeConfirmed = waveBearChange and barstate.isconfirmed

// === Main Plots ===

plot(x1, color=color.aqua, linewidth=1, title="Line-X1")
plot(x2, color=color.orange, linewidth=1, title="Line-X2")

// =====================================================
// === CROSSOVER POINTS — BALLS
// =====================================================

crossUp = ta.crossover(x1, x2)
crossDn = ta.crossunder(x1, x2)

// === Long: Aqua Ball on X1 ===

plot(crossUp ? x1 : na, style=plot.style_circles, linewidth=2, color=color.aqua, title="Bull Ball-X1", display=display.pane)

// === Short: Red-Orange Ball on X2 ===

plot(crossDn ? x2 : na, style=plot.style_circles, linewidth=2, color=color.rgb(255, 69, 0), title="Bear Ball-X2", display=display.pane)

// =====================================================
// === BALL CONDITIONS
// =====================================================

// === Real-Time — Current Candle ===

crossUpRealTime = crossUp
crossDnRealTime = crossDn

// === Confirmed — Closed Candle ===

crossUpConfirmed = crossUp and barstate.isconfirmed
crossDnConfirmed = crossDn and barstate.isconfirmed


// === 8 SOUND ALERTS === //

// === BALL — REAL-TIME ===

alertcondition(crossUpRealTime, title="Long Ball X1 Real-Time", message="Long Ball X1 — Real-Time")
alertcondition(crossDnRealTime, title="Short Ball X2 Real-Time", message="Short Ball X2 — Real-Time")

// === BALL — CONFIRMED ===

alertcondition(crossUpConfirmed, title="Ball / X1 Bull Confirmed", message="Ball-X1 Bull — Confirmed")
alertcondition(crossDnConfirmed, title="Ball / X2 Bear Confirmed", message="Ball-X2 Bear — Confirmed")

// =====================================================

// === 4 WAVE ALERTS ===

// === BASED ON X1-X2 AREA STATE ===

// =====================================================

// === WAVE — REAL-TIME ===

alertcondition(waveBullChange, title="Wave Long Real-Time", message="Wave Long — Real-Time")
alertcondition(waveBearChange, title="Wave Short Real-Time", message="Wave Short — Real-Time")

// === WAVE — CONFIRMED ===

alertcondition(waveBullChangeConfirmed, title="Wave Bull Confirmed", message="Wave Bull — Confirmed")
alertcondition(waveBearChangeConfirmed, title="Wave Bear Confirmed", message="Wave Bear — Confirmed")

// =====================================================
// --- MULTI-TIMEFRAME ALIGNMENT ---
// =====================================================

f_waveState(pf, ps) =>
    _alfa = hlc3
    _beta = ta.ema(_alfa, pf)
    _m = ta.ema(math.abs(_alfa - _beta), pf)
    _omega = ta.ema((_alfa - _beta) / (0.015 * _m), ps)
    _x1 = _omega
    _x2 = ta.sma(_x1, 4)
    _x1 > _x2 ? 1 : -1

state_cur = waveBull ? 1 : -1
state_tf1 = request.security(syminfo.tickerid, tf1, f_waveState(p1, p2), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
state_tf2 = request.security(syminfo.tickerid, tf2, f_waveState(p1, p2), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)
state_tf3 = request.security(syminfo.tickerid, tf3, f_waveState(p1, p2), gaps=barmerge.gaps_off, lookahead=barmerge.lookahead_off)

alignBullDual = state_cur > 0 and state_tf1 > 0 and state_tf2 > 0
alignBearDual = state_cur < 0 and state_tf1 < 0 and state_tf2 < 0

alignBullTriple = alignBullDual and state_tf3 > 0
alignBearTriple = alignBearDual and state_tf3 < 0

mtfBullish = mtfMode == "Dual" ? alignBullDual : alignBullTriple
mtfBearish = mtfMode == "Dual" ? alignBearDual : alignBearTriple

alertcondition(mtfBullish and not mtfBullish[1], title="WT-Ocean MTF Bullish Alignment", message="Wave-Ocean Trend: bullish alignment across selected timeframes.")
alertcondition(mtfBearish and not mtfBearish[1], title="WT-Ocean MTF Bearish Alignment", message="Wave-Ocean Trend: bearish alignment across selected timeframes.")
````
