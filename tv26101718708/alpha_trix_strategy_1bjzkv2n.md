# Alpha TRIX Strategy >_

- url: https://www.tradingview.com/script/1BJZkv2N-Alpha-TRIX-Strategy/
- type: strategy
- pine_id: PUB;bd51b13cfa26469aaa504e435a192977
- version: 2.0

## Description

The Alpha TRIX Strategy is a precision trend-following system built on a deceptively simple but powerful principle: only trade when the market is genuinely trending, genuinely moving, and genuinely tilted in your direction. It achieves this by stacking three independent validation layers — a momentum signal (TRIX), a regime filter (Choppiness Index), and a directional strength filter (ADX) — before a single entry is placed.

Unlike raw TRIX crossover systems that fire indiscriminately, this strategy demands that all three conditions are simultaneously satisfied. The result is a lower-frequency, higher-conviction signal profile that avoids the whipsaw-heavy environments where pure momentum strategies bleed equity.

═══════════════════════════════════════
KEY FEATURES
═══════════════════════════════════════

Momentum Engine (TRIX)
— Triple-smoothed EMA eliminates high-frequency noise
— ROC of EMA³ isolates trend acceleration
— Zero-line crossover generates long and short triggers
— Configurable TRIX length for sensitivity tuning

Regime Filter — Choppiness Index
— CHOP < threshold confirms non-choppy, directional structure
— Blocks entries during range-bound, sideways markets
— Eliminates the most expensive entry environment for trend-following systems

Directional Filter — ADX
— ADX > minimum threshold confirms trend force is sufficient
— Calculated via full DMI (DI+ / DI−)
— Guards against weak-trend entries that stall post-entry

ATR% Exit Framework
— Take profit and stop loss scaled to realized volatility at entry
— Levels locked at execution candle — no mid-trade recalculation
— Independent TP and SL multipliers for asymmetric risk configuration

Trade Direction Control
— Long only, short only, or both — configurable at runtime

═══════════════════════════════════════
HOW IT WORKS
═══════════════════════════════════════

Step 1 — TRIX Signal
EMA is applied three times to close price, producing EMA³. Rate-of-change of EMA³ over 1 bar yields the TRIX value. A crossover above zero triggers a long; a crossunder triggers a short.

Step 2 — Choppiness Gate
The Choppiness Index measures the ratio of summed 1-bar ATR to the total high-low range over the lookback window, log-normalized. Values below the threshold indicate the market is exhibiting directional structure rather than random oscillation.

Step 3 — ADX Gate
ADX above the minimum confirms that whatever direction the market is moving, it is doing so with sufficient force. Both filters must pass simultaneously with the TRIX signal for entry to execute.

Step 4 — Entry and Exit
Entry is placed immediately. Take profit and stop loss are calculated as Close × (ATR / Close) × Multiplier — which resolves to ATR × Multiplier — and passed directly to strategy.exit() at the entry bar. This prevents dynamic recalculation from altering risk parameters mid-trade, closing the gap between backtested and live performance.

═══════════════════════════════════════
DESIGN RATIONALE
═══════════════════════════════════════

[b]The TRIX advantage:[/b] triple-smoothing suppresses noise while the ROC step converts price level into momentum velocity. The zero-line crossing represents a genuine shift in trend acceleration — a higher-quality signal than single or double EMA crossovers.

[b]Why CHOP + ADX?[/b] Each filter attacks a different failure mode. The Choppiness Index identifies range-bound structure where momentum signals are statistically unreliable. ADX addresses weak-trend environments where the market has a direction but insufficient force to sustain movement. Together they gate out the two most expensive entry environments for trend-following systems.

[b]Locked exits: [/b]TP and SL are calculated once at the entry bar and immediately committed to the broker. This design closes a common source of backtest-to-live divergence in ATR-based systems — where dynamic recalculation on subsequent bars silently shifts risk levels mid-trade.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © BVLabs

//@version=6
strategy('Alpha TRIX Strategy', overlay = true, calc_on_every_tick = false,
     initial_capital = 1000, default_qty_type = strategy.cash, default_qty_value = 10000,
     commission_type = strategy.commission.percent, commission_value = 0, pyramiding = 0, margin_long = 0, margin_short = 0, slippage = 2)

// =========================================================================
// 1. INPUT SETTINGS
// =========================================================================
grp_main = 'Main Strategy Settings'
tradeDirection = input.string('Both', title = 'Trade Direction', options = ['Long', 'Short', 'Both'], group = grp_main)
allowReversal  = input.bool(true, title = 'Reverse Position on Opposite Signal', group = grp_main)

grp_filters = 'Entry Filters (CHOP & ADX)'
chopLen   = input.int(14, title = 'Choppiness Length', minval = 1, group = grp_filters)
chopThresh = input.float(50.0, title = 'Choppiness Threshold (<)', group = grp_filters)
adxLen    = input.int(7, title = 'ADX Length', minval = 1, group = grp_filters)
adxMin    = input.float(20.0, title = 'ADX Minimum Threshold (>)', group = grp_filters)

grp_trend = 'Trend Filter (EMA)'
useTrendFilter = input.bool(true, title = 'Only trade with the trend', group = grp_trend)
trendLen  = input.int(200, title = 'Trend EMA Length', minval = 1, group = grp_trend)

grp_trigger = 'Trigger Settings (TRIX)'
trixLen     = input.int(8, title = 'TRIX Length', minval = 1, group = grp_trigger)
minTrixSlope = input.float(0.0, title = 'Min TRIX Slope at Cross (abs value)', minval = 0.0, step = 0.01, group = grp_trigger)

grp_exit = 'Exit Settings (ATR % Based)'
atrLen = input.int(7, title = 'Fast ATR Length', minval = 1, group = grp_exit)
tpMult = input.float(1.5, title = 'Take Profit Multiplier (x ATR)', step = 0.1, group = grp_exit)
slMult = input.float(1.0, title = 'Stop Loss Multiplier (x ATR)', step = 0.1, group = grp_exit)

grp_risk = 'Risk Management'
useEquityRisk = input.bool(false, title = 'Size Position by % Equity Risk', group = grp_risk)
riskPct = input.float(1.0, title = 'Risk per Trade (% of Equity)', minval = 0.1, step = 0.1, group = grp_risk)

// =========================================================================
// 2. INDICATOR CALCULATIONS
// =========================================================================
rangeHL = ta.highest(high, chopLen) - ta.lowest(low, chopLen)
chopValue = rangeHL == 0 ? 0.0 : 100 * math.log10(math.sum(ta.atr(1), chopLen) / rangeHL) / math.log10(chopLen)

[diPlus, diMinus, adxValue] = ta.dmi(adxLen, adxLen)

trendEma = ta.ema(close, trendLen)
uptrend   = close > trendEma
downtrend = close < trendEma

ema1 = ta.ema(close, trixLen)
ema2 = ta.ema(ema1, trixLen)
ema3 = ta.ema(ema2, trixLen)
trixValue = ta.roc(ema3, 1)
trixSlope = trixValue - trixValue[1]

fastAtr = ta.atr(atrLen)
tpDistance = fastAtr * tpMult
slDistance = fastAtr * slMult

// =========================================================================
// 3. LOGIC & CONDITIONS
// =========================================================================
canLong  = tradeDirection == 'Both' or tradeDirection == 'Long'
canShort = tradeDirection == 'Both' or tradeDirection == 'Short'

filtersMet = chopValue < chopThresh and adxValue > adxMin

trendOkLong  = not useTrendFilter or uptrend
trendOkShort = not useTrendFilter or downtrend

longTrigger  = ta.crossover(trixValue, 0) and math.abs(trixSlope) >= minTrixSlope
shortTrigger = ta.crossunder(trixValue, 0) and math.abs(trixSlope) >= minTrixSlope

enterLong  = canLong and filtersMet and trendOkLong and longTrigger
enterShort = canShort and filtersMet and trendOkShort and shortTrigger

// =========================================================================
// 4. POSITION SIZING (FIXED: Capped to available equity)
// =========================================================================
equity = strategy.equity
riskAmount = equity * (riskPct / 100)

// Calculate maximum units we can afford without using margin
maxQty = equity / close 

// math.min ensures we never attempt to buy more than our account can afford
longQty  = useEquityRisk and slDistance > 0 ? math.min(riskAmount / slDistance, maxQty) : na
shortQty = useEquityRisk and slDistance > 0 ? math.min(riskAmount / slDistance, maxQty) : na

// =========================================================================
// 5. ORDER EXECUTION & STATIC EXITS (FIXED)
// =========================================================================
inLong  = strategy.position_size > 0
inShort = strategy.position_size < 0
flat    = strategy.position_size == 0

// Variables to lock in the ATR values at the time of entry
var float locked_tp = na
var float locked_sl = na

if enterLong and (flat or (inShort and allowReversal))
    locked_tp := tpDistance
    locked_sl := slDistance
    if useEquityRisk
        strategy.entry('Long', strategy.long, qty = longQty)
    else
        strategy.entry('Long', strategy.long)

if enterShort and (flat or (inLong and allowReversal))
    locked_tp := tpDistance
    locked_sl := slDistance
    if useEquityRisk
        strategy.entry('Short', strategy.short, qty = shortQty)
    else
        strategy.entry('Short', strategy.short)

if strategy.position_size > 0
    strategy.exit('Exit Long', 'Long',
         limit = strategy.position_avg_price + locked_tp,
         stop  = strategy.position_avg_price - locked_sl)

if strategy.position_size < 0
    strategy.exit('Exit Short', 'Short',
         limit = strategy.position_avg_price - locked_tp,
         stop  = strategy.position_avg_price + locked_sl)

// =========================================================================
// 6. VISUALS
// =========================================================================
plot(useTrendFilter ? trendEma : na, title = 'Trend EMA', color = color.orange, linewidth = 2)
plotshape(enterLong, title = 'Long Signal', style = shape.triangleup, location = location.belowbar, color = color.green, size = size.small)
plotshape(enterShort, title = 'Short Signal', style = shape.triangledown, location = location.abovebar, color = color.red, size = size.small)
````
