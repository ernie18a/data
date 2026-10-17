# Session King - ALMA with Session Filter

- url: https://www.tradingview.com/script/u5R6y8cl-Session-King-ALMA-with-Session-Filter/
- type: strategy
- pine_id: PUB;03dbf471af274d198ec75c53a0677a19
- version: 1.0

## Description

A session-gated trend strategy that restricts entries to high-liquidity
session windows using ALMA direction bias, with standardised ATR exits
(3 ATR stop, 6 ATR take profit — 2R fixed).

WHAT MAKES THIS ORIGINAL
Most trend strategies fire entries continuously throughout the trading day.
This strategy gates every entry through two independent filters before a
signal is accepted: a directional bias filter (ALMA) and a session timing
filter. Neither filter alone is the edge — the combination is. ALMA without
the session gate fires too many signals in low-liquidity periods. The session
gate without a directional filter trades noise in both directions. Together
they restrict entries to directional moves inside high-liquidity windows
where volume and participation are highest.

COMPONENTS
ALMA (Arnaud Legoux Moving Average, length 9): Direction baseline. Price
above ALMA = long bias; price below = short bias. ALMA applies Gaussian
weighting to reduce lag compared to EMAs of equivalent length, producing
fewer whipsaws at signal transitions.

Session Filter (toggleable): Entries are only permitted during defined
high-liquidity windows. London open (05:45-09:45 GMT), NY AM (12:00-16:00
GMT), and NY PM (19:00-21:00 GMT) can each be toggled independently.
Outside these windows the strategy does nothing. Most false signals in
forex and gold occur during low-volume inter-session periods.

TTM Squeeze (optional, off by default): Based on John Carter's published
TTM Squeeze concept. Compression detection (BB inside KC) is an independent
implementation using Pine built-ins only; Keltner Channel uses ATR via
Wilder's method. No momentum histogram is included — only the compression
gate is used. When Bollinger Bands contract inside the Keltner Channel the
market is in compression and entries are blocked. When BB expands back
outside the KC entries are permitted again. Enables lower-frequency,
post-compression entries when toggled on.

Exits: Fixed 3 ATR stop-loss and 6 ATR take-profit (2R) on every trade.
Position size is calculated so that 1% of equity is risked per trade at
the 3 ATR stop distance.

WHY THIS COMBINATION
ALMA provides direction bias with reduced lag. The session gate ensures
entries only occur when volume and institutional participation are highest.
Fixed ATR exits keep risk consistent across instruments and timeframes and
allow meaningful comparison of strategy performance across different market
conditions.

HOW TO USE
Enable the sessions that match your instrument. London + NY AM is the
default for forex and gold. Enable TTM Squeeze for lower-frequency,
higher-conviction setups. Best suited to 4H and 1H timeframes on XAUUSD,
GBPUSD, EURUSD, and major indices.

DEFAULT PROPERTIES
ATR Length: 14 | Stop: 3x ATR | Take Profit: 6x ATR (2R) | Risk: 1%
Commission: 0.01% per side | Slippage: 1 tick | Initial capital: 10,000

LIMITATIONS
Session filtering significantly reduces trade count. On 4H timeframes
expect 15-40 trades per year. To reach 100+ trades for a statistically
meaningful sample, backtest a minimum of 3-5 years on 1H or 8-10 years
on 4H. Past results do not guarantee future performance.

## Source Code

````pine

//@version=6
strategy("Session King - ALMA Baseline with Session Filter and Fixed 2R Exit",
     overlay           = true,
     initial_capital   = 10000,
     default_qty_type  = strategy.fixed,
     default_qty_value = 1,
     commission_type   = strategy.commission.percent,
     commission_value  = 0.01,
     slippage          = 1,
     pyramiding        = 0)

// ─── ALMA BASELINE ───────────────────────────────────────────────────────────
sourceALMA = input.source(close, "Source", group="ALMA")
almaWindow = input.int(9,        "Window", group="ALMA", minval=2, maxval=50)
almaOffset = input.float(0.85,   "Offset", group="ALMA", minval=0, maxval=1, step=0.01)
almaSigma  = input.float(6.0,    "Sigma",  group="ALMA", minval=0.5, maxval=10, step=0.1)

almaLine = ta.alma(sourceALMA, almaWindow, almaOffset, almaSigma)
almaBull = close > almaLine
almaBear = close < almaLine

// ─── TTM SQUEEZE ─────────────────────────────────────────────────────────────
squeezeOn = input.bool(false, "Enable Squeeze Filter", group="TTM Squeeze")
sqLen     = input.int(20,     "Length",                group="TTM Squeeze", minval=1)
sqBBMult  = input.float(2.0,  "BB Multiplier",         group="TTM Squeeze", minval=0.5, step=0.1)
sqKCMult  = input.float(1.5,  "KC Multiplier",         group="TTM Squeeze", minval=0.5, step=0.1)

sqBasis   = ta.sma(close, sqLen)
sqBBHalf  = sqBBMult * ta.stdev(close, sqLen)
sqBBUpper = sqBasis + sqBBHalf
sqBBLower = sqBasis - sqBBHalf
sqKCHalf  = ta.atr(sqLen) * sqKCMult
sqKCUpper = sqBasis + sqKCHalf
sqKCLower = sqBasis - sqKCHalf

sqCompressed  = sqBBUpper <= sqKCUpper and sqBBLower >= sqKCLower
squeezeActive = not sqCompressed

// ─── SESSION KILL ZONES ──────────────────────────────────────────────────────
useLondon = input.bool(true,  "London  05:45-09:45 GMT", group="Session Filter")
useNYAM   = input.bool(true,  "NY AM   12:00-16:00 GMT", group="Session Filter")
useNYPM   = input.bool(false, "NY PM   19:00-21:00 GMT", group="Session Filter")

londonStart = timestamp("Europe/London", year, month, dayofmonth,  5, 45)
londonEnd   = timestamp("Europe/London", year, month, dayofmonth,  9, 45)
nyAMStart   = timestamp("Europe/London", year, month, dayofmonth, 12,  0)
nyAMEnd     = timestamp("Europe/London", year, month, dayofmonth, 16,  0)
nyPMStart   = timestamp("Europe/London", year, month, dayofmonth, 19,  0)
nyPMEnd     = timestamp("Europe/London", year, month, dayofmonth, 21,  0)

inSession = (useLondon and time >= londonStart and time < londonEnd) or            (useNYAM   and time >= nyAMStart   and time < nyAMEnd)   or            (useNYPM   and time >= nyPMStart   and time < nyPMEnd)

// ─── EXITS ───────────────────────────────────────────────────────────────────
atrLen  = input.int(14,   "ATR Length",           group="Exits", minval=1)
slMult  = input.float(3.0,"SL ATR Multiplier",    group="Exits", minval=0.5, step=0.1)
tpMult  = input.float(6.0,"TP ATR Multiplier (2R)",group="Exits", minval=0.5, step=0.1)
riskPct = input.float(1.0,"Risk Per Trade (%)",   group="Exits", minval=0.1, step=0.1)

atrVal      = ta.atr(atrLen)
sl_distance = math.max(atrVal * slMult, syminfo.mintick)
qty         = (strategy.equity * (riskPct / 100)) / sl_distance

// ─── ENTRY CONDITIONS ────────────────────────────────────────────────────────
sqGate    = squeezeOn ? squeezeActive : true
longCond  = almaBull and sqGate and inSession and strategy.position_size == 0
shortCond = almaBear and sqGate and inSession and strategy.position_size == 0

// ─── ENTRIES ─────────────────────────────────────────────────────────────────
if longCond
    strategy.entry("Long", strategy.long, qty=qty)

if shortCond
    strategy.entry("Short", strategy.short, qty=qty)

// ─── EXITS (SL + TP only) ────────────────────────────────────────────────────
strategy.exit("LX", "Long",
     stop  = strategy.position_avg_price - slMult * atrVal,
     limit = strategy.position_avg_price + tpMult * atrVal)

strategy.exit("SX", "Short",
     stop  = strategy.position_avg_price + slMult * atrVal,
     limit = strategy.position_avg_price - tpMult * atrVal)

// ─── PLOTS ───────────────────────────────────────────────────────────────────
plot(almaLine, "ALMA", color=color.new(color.blue, 30), linewidth=1)
````
