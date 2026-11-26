# Real Strength Scalper 

- url: https://www.tradingview.com/script/iCRFM0LS/
- type: strategy
- pine_id: PUB;1f3881daba1c4392ab6143dcde578fcb
- version: 1.0

## Description

Overview
A momentum-continuation scalping strategy designed for the 5-minute timeframe. It uses a single custom oscillator — the [i]Real Strength[/i] histogram — combined with a dual SMA trend filter to capture confirmed directional moves, while a static percentage stop loss and an adaptive, regime-dependent exit logic manage open trades.

[b] Concept and Originality[/b]
Most momentum oscillators answer either *which direction* or *how strong*, rarely both in a way that requires real conviction. The Real Strength histogram fuses three independent components into one signed value:

- Price momentum** — Rate of Change of price over N bars (provides the sign)
- Volume confirmation** — current volume divided by its moving average (amplifier)
- Trend strength** — ADX scaled around a 20 reference (amplifier)

These three are multiplied together (with a small floor to prevent the amplifiers from zeroing out the result on quiet bars) and then smoothed with an EMA. The output is an oscillator where the sign tells direction and the magnitude reflects how much *real* force is behind the move. A high histogram reading requires all three components to align — price moving, volume present, ADX confirming.

This composite differs from a standalone ROC, MACD, or volume-weighted oscillator because none of those three on their own require simultaneous confirmation across price, participation, and trend strength.

[b]Entry Logic[/b]
A long entry requires every condition below to be true on the same bar:

- Histogram above the positive threshold (default 1.0)
- Histogram rising vs. the previous bar (no entries on a fading peak)
- ADX above the minimum level (default 14)
- DI+ greater than DI− (directional confirmation)
- Volume ratio above minimum (default 1.2× average)
- *Optional:* Fast SMA above Slow SMA (default 30/60, toggleable)

Short entries mirror these conditions on the bearish side.

[b] Exit Logic — Regime-Dependent[/b]
The exit behavior changes based on whether the SMA trend filter still confirms the position. This is the central design choice of the strategy:

[b]While SMA still confirms the position:[/b]
The trade exits only when the histogram crosses through zero into the opposite zone past a defined flip threshold (default ±0.8). This allows winners to ride through pullbacks and consolidations as long as the larger structure (SMA cross) still favors the trade.

[b]After SMA reverses against the position:[/b]
The trade exits on a classic peak-drop rule — if the histogram falls 25% or more from its peak value reached during the trade, the position is closed. This protects open profits when structure breaks down.

A hard static stop loss (default 1%) is always active and overrides both exit modes if reached first. A minimum hold of 3 bars prevents premature exits caused by noise immediately after entry.

[b] Re-Entry Lock[/b]
After a stop loss is hit, the strategy refuses to re-enter in the same direction until the histogram returns to (or crosses) zero. This prevents immediately re-entering the same momentum that just stopped the previous trade out — a common cause of consecutive losses on choppy bars.

[b] Settings Guide[/b]
- Strength threshold (1.0):** minimum histogram magnitude required for entry. Lower values produce more trades; higher values are more selective.
- Min ADX (14):** filters out low-trending environments.
- Volume Ratio (1.2):** requires above-average participation on the entry bar.
- SMA Fast / Slow (30 / 60):** trend regime filter; can be disabled to compare baseline performance.
- Stop Loss % (1.0):** static distance from entry. Adjust per instrument volatility.
- Peak drop % (25):** how much the histogram must fall from peak to trigger peak-exit.
- Flip exit threshold (0.8):** how far the histogram must travel into the opposite zone to trigger flip-exit.
- Min bars before peak/flip (3):** protects against same-bar noise exits.

[b]Default Properties and Backtesting Realism[/b]
- Initial capital: 100,000
- Position size: 3% of equity per trade
- Commission: 0.04%
- Slippage: 3 ticks
- Process orders on close: true
- No pyramiding

These defaults reflect realistic crypto futures conditions. Users trading other instruments or venues should adjust commission and slippage to match their broker.

[b]Intended Use[/b]
- Built and validated on the 5-minute timeframe
- Best suited for liquid markets with consistent volume profile
- One position at a time, both long and short
- Re-tune thresholds per instrument; defaults are starting points, not optimal values for every market

[b]Notes[/b]
Past performance does not guarantee future results. Backtest outcomes depend strongly on the chosen instrument, time range, and parameter settings. This strategy is published as an educational tool to demonstrate a composite-momentum approach with regime-dependent exits — not as a turnkey trading system. Always test with your own data and risk parameters before any live use.

## Source Code

````pine
// @version=5
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © wielkieef

strategy(title="Real Strength Scalper [5m]", overlay=false, initial_capital=100000, default_qty_type=strategy.percent_of_equity, default_qty_value=3, commission_type=strategy.commission.percent, commission_value=0.04, slippage=3, process_orders_on_close=true, max_lines_count=500, max_labels_count=500)

// ===== INPUTS =====
momLen    = input.int(9,    "Momentum (ROC) length",  minval=1,   group="Strength")
volLen    = input.int(20,   "Volume MA length",        minval=1,   group="Strength")
adxLen    = input.int(14,   "ADX length",              minval=1,   group="Strength")
diLen     = input.int(14,   "DI length",               minval=1,   group="Strength")
smoothLen = input.int(8,    "Histogram smoothing",     minval=1,   group="Strength")

adxMin    = input.float(14.0, "Min ADX",               minval=0,   group="Filters")
volMin    = input.float(1.2,  "Min Volume Ratio",      minval=0.1, step=0.1, group="Filters")
strThr    = input.float(1.0,  "Strength threshold",    step=0.1,   group="Filters")

smaFast   = input.int(30,    "SMA Fast",               minval=1,   group="Trend Filter")
smaSlow   = input.int(60,    "SMA Slow",               minval=1,   group="Trend Filter")
useTrend  = input.bool(true, "Use SMA Trend Filter",               group="Trend Filter")

slPct     = input.float(1.0, "Stop Loss %",            minval=0.1, step=0.1, group="Risk")

peakDrop  = input.float(25.0, "Peak drop % to exit",   minval=1, maxval=99, step=5, group="Exit")
minHold   = input.int(3,      "Min bars before peak/flip exit", minval=0, group="Exit")
flipThr   = input.float(0.8,  "Flip exit threshold (with SMA hold)", step=0.1, group="Exit")

// ===== CALC =====
mom      = ta.roc(close, momLen)
volRatio = volume / ta.sma(volume, volLen)
[diPlus, diMinus, adxVal] = ta.dmi(diLen, adxLen)
adxBoost = adxVal / 20.0

rawStr   = mom * math.max(volRatio, 0.3) * math.max(adxBoost, 0.3)
strength = ta.ema(rawStr, smoothLen)

bullDir   = diPlus  > diMinus
bearDir   = diMinus > diPlus
strongAdx = adxVal  >= adxMin
strongVol = volRatio >= volMin

fastMA    = ta.sma(close, smaFast)
slowMA    = ta.sma(close, smaSlow)
uptrend   = fastMA > slowMA
downtrend = fastMA < slowMA

// ===== HISTOGRAM =====
hColor = strength > 0 and strength > strength[1] ? color.new(#00e676, 0)  : strength > 0 ? color.new(#00e676, 55) : strength < 0 and strength < strength[1] ? color.new(#ff1744, 0)  : color.new(#ff1744, 55)
plot(strength, "Strength", color=hColor, style=plot.style_columns)
hline(0,        "Zero",      color=color.new(color.gray, 50))
hline( strThr,  "+Thr",      color=color.new(color.gray, 70), linestyle=hline.style_dashed)
hline(-strThr,  "-Thr",      color=color.new(color.gray, 70), linestyle=hline.style_dashed)
hline( flipThr, "+Flip Thr", color=color.new(color.yellow, 60), linestyle=hline.style_dotted)
hline(-flipThr, "-Flip Thr", color=color.new(color.yellow, 60), linestyle=hline.style_dotted)

plot(fastMA, "SMA Fast", color=color.new(color.aqua, 0),   force_overlay=true)
plot(slowMA, "SMA Slow", color=color.new(color.orange, 0), force_overlay=true)

// ===== SIGNALS =====
longSig  = strength >  strThr and strongAdx and strongVol and bullDir and strength > strength[1] and (not useTrend or uptrend)
shortSig = strength < -strThr and strongAdx and strongVol and bearDir and strength < strength[1] and (not useTrend or downtrend)

// ===== PEAK TRACKING =====
var float longPeak  = na
var float shortPeak = na
var int   entryBar  = na

if strategy.position_size > 0 and strategy.position_size[1] <= 0
    longPeak := strength
    entryBar := bar_index

if strategy.position_size < 0 and strategy.position_size[1] >= 0
    shortPeak := strength
    entryBar  := bar_index

if strategy.position_size > 0
    longPeak := math.max(nz(longPeak, strength), strength)

if strategy.position_size < 0
    shortPeak := math.min(nz(shortPeak, strength), strength)

barsHeld    = na(entryBar) ? 0 : bar_index - entryBar

longPkExit  = longPeak  > 0 and strength < longPeak  * (1 - peakDrop/100) and barsHeld >= minHold
shortPkExit = shortPeak < 0 and strength > shortPeak * (1 - peakDrop/100) and barsHeld >= minHold

longFlipExit  = strength <= -flipThr and barsHeld >= minHold
shortFlipExit = strength >=  flipThr and barsHeld >= minHold

longExit  = strategy.position_size > 0 and not na(longPeak)  and (uptrend   ? longFlipExit  : longPkExit)
shortExit = strategy.position_size < 0 and not na(shortPeak) and (downtrend ? shortFlipExit : shortPkExit)

// ===== RE-ENTRY LOCK =====
var bool longLocked  = false
var bool shortLocked = false

longSLHit  = strategy.position_size[1] > 0 and strategy.position_size == 0
shortSLHit = strategy.position_size[1] < 0 and strategy.position_size == 0

if longSLHit
    longLocked := true
if shortSLHit
    shortLocked := true

if longLocked and strength <= 0
    longLocked := false
if shortLocked and strength >= 0
    shortLocked := false

// ===== EXECUTE =====
if longSig and strategy.position_size <= 0 and not longLocked
    strategy.entry("L", strategy.long)

if shortSig and strategy.position_size >= 0 and not shortLocked
    strategy.entry("S", strategy.short)

if strategy.position_size > 0
    slPrice = strategy.position_avg_price * (1 - slPct/100)
    strategy.exit("L-SL", from_entry="L", stop=slPrice)
    if longExit
        strategy.close("L", comment=uptrend ? "flip" : "peak")
        longLocked := false
else
    longPeak := na

if strategy.position_size < 0
    slPrice = strategy.position_avg_price * (1 + slPct/100)
    strategy.exit("S-SL", from_entry="S", stop=slPrice)
    if shortExit
        strategy.close("S", comment=downtrend ? "flip" : "peak")
        shortLocked := false
else
    shortPeak := na
````
