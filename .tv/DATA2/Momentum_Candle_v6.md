<!-- tradingview-pine-id: PUB;e896c30743ba4623b0341b2b8329ebc0 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Momentum Candle [v6]

Source: https://www.tradingview.com/script/G22QzFe9-Momentum-Candle-By-Skyrooth/

## Description

Momentum Candle By Skyrooth highlights expansion candles — the bars where one
side takes control decisively — and filters out the ordinary bars that only look
big because volatility happened to be high at the time.

WHAT PROBLEM THIS SOLVES

Most price action methods depend on a single instruction: "wait for
displacement". A break of structure only counts if the candle that caused it was
decisive. An order block only counts if the move leaving it was strong.

The problem is that "strong" is usually judged by eye, and the eye is unreliable.
A 40 point candle is large on a quiet morning and unremarkable during a news
release. Traders end up calling the same candle valid or invalid depending on
what they want to see.

This indicator applies one fixed measurement instead.

HOW IT WORKS

A candle is marked when all of the following are true:

1. BODY DOMINANCE — the body is large relative to the total range of the bar, so
   the close finishes near the extreme rather than in the middle. This is what
   separates a decisive bar from a bar that spent the session being rejected.

2. RANGE VS RECENT VOLATILITY — the range is compared against a rolling average
   of recent ranges, not against a fixed point value. This is what makes the
   measurement adapt: the same threshold works on a quiet session and a volatile
   one, and on gold as well as an index.

3. VOLUME CONFIRMATION — the bar is compared against its own recent volume
   average. Expansion on thin volume is usually a liquidity gap rather than
   participation.

4. DIRECTIONAL AGREEMENT — the bar's direction is checked against the prevailing
   trend, so continuation bars are separated from isolated spikes.

Bars meeting the conditions are coloured and marked on the chart. Everything
else is left alone.

HOW TO USE IT

This is a filter, not an entry signal. It answers one question — "was that move
decisive?" — and nothing else. There is no entry, stop or target here.

Typical use:

- CONFIRMING A STRUCTURE BREAK. When price breaks a swing high or low, check
  whether the breaking candle is marked. An unmarked break is more likely to be
  a liquidity sweep that reverses.

- VALIDATING AN ORDER BLOCK OR IMBALANCE. The candle that leaves the zone should
  be marked. If the departure was weak, the zone is weak.

- AVOIDING CHASING. A marked candle means the move already happened. Wait for a
  retracement into the area the candle originated from rather than entering at
  the extreme.

SETTINGS

- Body ratio threshold — minimum share of the range the body must occupy.
  Raise it for fewer, cleaner signals.
- Volatility lookback — number of bars in the rolling range average.
- Volume multiplier — how far above its own average the bar's volume must be.
  Set to zero to disable the volume condition on instruments with unreliable
  volume data, such as spot forex.
- Trend filter — enable to keep only bars aligned with the prevailing direction.

NOTES AND LIMITATIONS

- Signals are confirmed on bar close. An intrabar candle can meet the conditions
  and then lose them before closing.
- Volume conditions depend on the feed. Centralised futures volume is reliable;
  spot forex volume is broker specific and often is not.
- A marked candle describes what already happened. It carries no claim about
  what happens next, and no win rate is implied.
- Works on any symbol and timeframe, though the volume condition is most
  meaningful on instruments with genuine exchange volume.

---

## Source Code

````pine
//@version=6
indicator("Momentum Candle [v6]", shorttitle="MomCandle", overlay=true)

// ─── INPUTS ───────────────────────────────────────────
body_min  = input.float(80.0, "Min Body %", minval=50.0, maxval=100.0, step=5.0, group="🕯️ Filter")
wick_max  = input.float(20.0, "Max Wick %", minval=0.0,  maxval=50.0,  step=5.0, group="🕯️ Filter")
show_bo   = input.bool(true,  "Detect Breakout (beda warna)", group="🕯️ Filter")
bo_len    = input.int(20,     "Breakout Lookback",            minval=5, maxval=200, group="🕯️ Filter")

c_bull    = input.color(#26a69a, "Bull Momentum", group="🎨 Warna")
c_bear    = input.color(#ef5350, "Bear Momentum", group="🎨 Warna")
c_bull_bo = input.color(#00E676, "Bull Breakout", group="🎨 Warna")
c_bear_bo = input.color(#FF1744, "Bear Breakout", group="🎨 Warna")

// ─── CALC ─────────────────────────────────────────────
atr      = ta.atr(14)
_rng     = high - low
_body    = math.abs(close - open)
_wick    = math.max(high - math.max(close, open), math.min(close, open) - low)
body_pct = _rng > 0 ? _body / _rng * 100 : 0.0
wick_pct = _rng > 0 ? _wick / _rng * 100 : 0.0

is_mom      = body_pct >= body_min and wick_pct <= wick_max and _rng > atr * 0.3
is_bull_mom = is_mom and close > open
is_bear_mom = is_mom and close < open

prev_high = ta.highest(high, bo_len)[1]
prev_low  = ta.lowest(low,   bo_len)[1]
bull_bo   = show_bo and is_bull_mom and close > prev_high
bear_bo   = show_bo and is_bear_mom and close < prev_low

// ─── WARNA BODI ───────────────────────────────────────
// Breakout = warna lebih terang, momentum biasa = warna normal
body_color = bull_bo   ? c_bull_bo :
             bear_bo   ? c_bear_bo :
             is_bull_mom ? c_bull    :
             is_bear_mom ? c_bear    : na

// Hanya recolor candle yang momentum — yang lain tetap warna chart asli
barcolor(body_color)

// ─── ALERTS ───────────────────────────────────────────
alertcondition(bull_bo,     "Bull Breakout Momentum", "BO ▲ {{ticker}} {{interval}}")
alertcondition(bear_bo,     "Bear Breakout Momentum", "BO ▼ {{ticker}} {{interval}}")
alertcondition(is_bull_mom, "Bull Momentum Candle",   "Bull Mom {{ticker}}")
alertcondition(is_bear_mom, "Bear Momentum Candle",   "Bear Mom {{ticker}}")
````
