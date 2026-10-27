# WTI Intraday Pressure (CL1!-CL2!)

- url: https://www.tradingview.com/script/My0e8hmQ-WTI-Intraday-Pressure-CL1-CL2/
- type: indicator
- pine_id: PUB;be803b4157934f3dbf01912dc158dffb
- version: 1.0

## Description

WTI INTRADAY FACTOR PRO (CL1/CL2)
User Manual

---

[1] OVERVIEW

This indicator uses the relationship between CL1 (front-month WTI futures)
and CL2 (second-month futures) to estimate intraday market pressure.

It helps identify:

* directional bias
* continuation vs mean reversion conditions
* higher-quality breakout environments

Important:
This is a [b]filter[/b], not a standalone trading system.

---

[2] CORE IDEA

The indicator is based on the spread:

S = CL2 - CL1

Interpretation:

* Backwardation (CL1 > CL2) → bullish pressure
* Contango (CL1 < CL2) → bearish pressure

However, the level alone is not enough.

The indicator focuses on:

* normalized spread (z-score)
* change in spread (most important)

---

[3] HOW THE FACTOR IS BUILT

The final factor combines:

* Spread (normalized)
* Change in spread (normalized)

Formula:

F = w1 * Z_spread + w2 * Z_delta

Default:

* w1 = 0.3
* w2 = 0.7

The change component drives most of the signal.

---

[4] ADDITIONAL FILTERS

The indicator includes several filters to improve accuracy.

[b]Volatility scaling[/b]

* increases signal importance during active periods
* reduces noise in quiet markets

[b]CL1 dominance filter[/b]

* requires front-month to lead the move
* removes weak or artificial spread changes

[b]Persistence filter[/b]

* requires signal to hold for multiple bars
* avoids one-bar spikes

[b]Momentum filter[/b]

* aligns trades with short-term direction

[b]Session filter[/b]

* focuses on high liquidity hours (US session)

[b]Adaptive thresholds[/b]

* adjusts sensitivity automatically based on market conditions

---

[5] SETTINGS EXPLANATION

[b]Z-score lookback[/b]
Default: 300

* lower = faster but noisier
* higher = smoother but slower

[b]EMA smoothing[/b]
Default: 10

* controls signal stability

[b]Weights (w1, w2)[/b]

* increase w2 → more reactive intraday signal
* increase w1 → more structural bias

[b]Filters[/b]
Each filter can be turned ON/OFF for testing.

Recommended:
keep all filters ON.

[b]Thresholds[/b]
Default:

* Long: +1
* Short: -1

Used only if adaptive thresholds are disabled.

---

[6] HOW TO READ THE INDICATOR

[b]Factor values[/b]

* F > +1 → bullish bias
* F < -1 → bearish bias
* |F| < 0.5 → neutral (no edge)

[b]Background color[/b]

* Green → long bias
* Red → short bias

[b]Signals[/b]

Triangles mark the start of a new bias.
They are not entry signals.

---

[7] HOW TO USE IT

[b]Main rule[/b]

Use the indicator to decide:
[b]"Should I trust this move?"[/b]

Do not trade signals blindly.

---

[b]Long setup[/b]

* Factor positive
* Price above VWAP
* Breakout or higher high

Enter on strength.

---

[b]Short setup[/b]

* Factor negative
* Price below VWAP
* Breakdown or failed bounce

Enter on weakness.

---

[b]Avoid[/b]

* trading in neutral zone
* counter-trend trades
* low liquidity periods

---

[8] USE CASES

[b]Intraday trend trading[/b]

* primary use
* improves breakout quality

[b]Scalping[/b]

* works with tighter settings
* requires confirmation

[b]Mean reversion[/b]

* when factor is near zero
* market is balanced

[b]News events[/b]

* useful after the move
* unreliable during releases

---

[9] OPTIMIZATION

If too many signals:

* increase smoothing
* increase thresholds

If too few signals:

* decrease thresholds
* reduce lookback

If signals are late:

* reduce smoothing

---

[10] LIMITATIONS

* not predictive alone
* depends on futures data quality
* weaker outside US session
* can fail during major news

---

[11] FINAL NOTES

This indicator reflects underlying futures positioning.

It will:

* reduce bad trades
* improve alignment with market pressure

It will NOT:

* generate signals by itself
* guarantee profitability

Focus on:
[b]better trade selection, not more trades[/b]

## Source Code

````pine
//@version=5
indicator("WTI CL1<>Cl2 Intraday Pressure", overlay=false)


// === INPUTS ===
cl1_symbol = input.symbol("NYMEX:CL1!", "CL1 (Front Month)")
cl2_symbol = input.symbol("NYMEX:CL2!", "CL2 (Second Month)")

lookback   = input.int(300, "Z-score Lookback", minval=50)
smooth_len = input.int(10, "EMA Smoothing", minval=1)

w1 = input.float(0.3, "Weight Z Spread")
w2 = input.float(0.7, "Weight Z Delta")

// Filters toggles
use_vol_filter  = input.bool(true, "Use Volatility Scaling")
use_dom_filter  = input.bool(true, "Use CL1 Dominance Filter")
use_persistence = input.bool(true, "Use Persistence Filter")
use_momentum    = input.bool(true, "Use Momentum Filter")
use_session     = input.bool(true, "Use Session Filter")
use_dynamic_th  = input.bool(true, "Use Adaptive Thresholds")

// Thresholds
base_long_th  = input.float(1.2, "Base Long Threshold")
base_short_th = input.float(-1.2, "Base Short Threshold")

// === DATA ===
cl1 = request.security(cl1_symbol, timeframe.period, close)
cl2 = request.security(cl2_symbol, timeframe.period, close)

// === SPREAD ===
spread = cl2 - cl1

// === Z-SCORE SPREAD ===
mean_spread = ta.sma(spread, lookback)
std_spread  = ta.stdev(spread, lookback)
z_spread    = std_spread != 0 ? (spread - mean_spread) / std_spread : 0

// === DELTA ===
delta_spread = spread - spread[1]

mean_delta = ta.sma(delta_spread, lookback)
std_delta  = ta.stdev(delta_spread, lookback)
z_delta    = std_delta != 0 ? (delta_spread - mean_delta) / std_delta : 0

// === BASE FACTOR ===
F_raw = w1 * z_spread + w2 * z_delta
F = ta.ema(F_raw, smooth_len)

// === VOLATILITY SCALING ===
ret = math.log(cl1 / cl1[1])
vol = ta.stdev(ret, 50)
vol_norm = ta.sma(vol, 200) != 0 ? vol / ta.sma(vol, 200) : 1

F_vol = use_vol_filter ? F * vol_norm : F

// === DOMINANCE FILTER (CL1 must lead) ===
cl1_move = math.abs(cl1 - cl1[1])
cl2_move = math.abs(cl2 - cl2[1])
dominant = cl1_move > cl2_move

F_dom = use_dom_filter ? (dominant ? F_vol : 0) : F_vol

// === PERSISTENCE FILTER (correct v5 implementation) ===
persist_long =
     (F_dom > base_long_th ? 1 : 0) +
     (F_dom[1] > base_long_th ? 1 : 0) +
     (F_dom[2] > base_long_th ? 1 : 0) +
     (F_dom[3] > base_long_th ? 1 : 0) +
     (F_dom[4] > base_long_th ? 1 : 0) >= 3

persist_short =
     (F_dom < base_short_th ? 1 : 0) +
     (F_dom[1] < base_short_th ? 1 : 0) +
     (F_dom[2] < base_short_th ? 1 : 0) +
     (F_dom[3] < base_short_th ? 1 : 0) +
     (F_dom[4] < base_short_th ? 1 : 0) >= 3

F_persist = use_persistence ? (persist_long or persist_short ? F_dom : 0) : F_dom

// === MOMENTUM FILTER ===
momentum = ta.ema(close - close[10], 5)

long_mom_ok  = momentum > 0
short_mom_ok = momentum < 0

// === SESSION FILTER (exchange time) ===
session_ok = (hour >= 14 and hour <= 17)

// === ADAPTIVE THRESHOLDS ===
F_volatility = ta.stdev(F_persist, 100)

long_th  = use_dynamic_th ? 0.8 * F_volatility : base_long_th
short_th = use_dynamic_th ? -0.8 * F_volatility : base_short_th

// === FINAL CONDITIONS ===
long_cond =
     F_persist > long_th and
     (not use_momentum or long_mom_ok) and
     (not use_session or session_ok)

short_cond =
     F_persist < short_th and
     (not use_momentum or short_mom_ok) and
     (not use_session or session_ok)

// === PLOTS ===
plot(F_persist, title="Enhanced Factor", linewidth=2)

hline(0, "Zero", color=color.gray)
plot(long_th, "Long Threshold", color=color.green)
plot(short_th, "Short Threshold", color=color.red)

// Background regimes
bgcolor(long_cond ? color.new(color.green, 85) : na)
bgcolor(short_cond ? color.new(color.red, 85) : na)

// Signals
plotshape(long_cond and not long_cond[1],
     title="Long Signal",
     location=location.bottom,
     color=color.green,
     style=shape.triangleup,
     size=size.small)

plotshape(short_cond and not short_cond[1],
     title="Short Signal",
     location=location.top,
     color=color.red,
     style=shape.triangledown,
     size=size.small)

// === DEBUG ===
show_debug = input.bool(false, "Show Debug")

plot(show_debug ? z_spread : na, "Z Spread", color=color.blue)
plot(show_debug ? z_delta  : na, "Z Delta", color=color.orange)
plot(show_debug ? vol_norm : na, "Vol Norm", color=color.purple)
````
