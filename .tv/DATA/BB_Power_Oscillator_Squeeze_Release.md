<!-- tradingview-pine-id: PUB;ba6a91fac29c4941b9116901894bd720 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# BB Power Oscillator + Squeeze Release

Source: https://www.tradingview.com/script/M6uONKNI-Power-Surge-BB-Momentum-Squeeze-Release/

## Description

Strategy Overview
Power Surge trades the moment volatility compression turns into directional momentum. It combines two mechanisms: a Bull/Bear Power Oscillator that measures how forcefully price is pushing beyond its own Bollinger Band envelope (0–100 scale), and a classic BB-inside-Keltner-Channel squeeze filter that identifies periods of volatility contraction. Entries only trigger when the oscillator crosses above/below a threshold within a defined window after a squeeze has just released — filtering out random momentum crosses that happen outside of a genuine compression-to-expansion cycle.

Features

[*]Bull/Bear Power Oscillator with gradient glow visualization — color intensity reflects how forcefully price is breaking out of its envelope
[*]Squeeze detection with visible on/off dots (BB fully inside Keltner Channel = squeezed)
[*]Configurable "release window" filter — only takes signals within N bars of a squeeze release, keeping entries tied to genuine volatility expansion rather than every oscillator cross
[*]ATR-based initial stop-loss, sized dynamically to current volatility
[*]Automatic breakeven stop-move once price reaches a configurable % of planned risk
[*]Optional ATR trailing stop after breakeven — lets winners run instead of capping every trade at a fixed target
[*]Max-hold-bars failsafe — force-closes any trade that stagnates without hitting stop or target, so backtest stats never get skewed by an indefinitely open position
[*]Fixed % equity risk per trade — position size auto-adjusts to stop distance
[*]Full alert support for squeeze releases and long/short entries

Tips

[*]Start with default settings on a liquid asset/timeframe combo (squeezes need enough bars of history to form meaningfully — very short timeframes may produce noisy squeeze signals)
[*]Widen Release Window if trade frequency feels too low; tighten it if you want only the highest-conviction post-squeeze entries
[*]Toggle Only Trade Within N Bars of Squeeze Release off temporarily to see how the oscillator performs standalone — useful for isolating whether the squeeze filter is actually adding edge on your instrument
[*]If trades are getting stopped out at breakeven too often, raise Move SL to BE at % of Risk so the stop doesn't move up until price has proven the move further
[*]Adjust ATR Multiplier to match instrument volatility — tighter multiplier = smaller stops but more noise-driven stop-outs; wider = fewer whipsaws but larger risk per trade

---

## Source Code

````pine
//@version=6
strategy("BB Power Oscillator + Squeeze Release", shorttitle="BB Power+Sqz", overlay=false,
     commission_type=strategy.commission.percent, commission_value=0.05,
     default_qty_type=strategy.cash, default_qty_value=1000,
     initial_capital=1000, currency=currency.USD)

// ============ INPUTS ============
grpMM = "Money Management"
risk_per_trade = input.float(1.0, "Risk % per Trade", minval=0.1, maxval=100, step=0.1, group=grpMM)
rr_ratio       = input.float(1.5, "Risk Reward Ratio", minval=0.5, step=0.1, group=grpMM)
be_trigger_pct = input.float(0.75, "Move SL to BE at % of Risk", minval=0.1, maxval=1.0, step=0.05, group=grpMM)
trail_after_be = input.bool(true, "Trail Stop After Breakeven", group=grpMM)
trailAtrMult   = input.float(1.5, "Trail ATR Mult", group=grpMM)
maxHoldBars    = input.int(50, "Max Bars In Trade (failsafe)", minval=5, group=grpMM)

grpOsc = "BB Power Oscillator"
bb_length = input.int(14, "Length", group=grpOsc)
bb_mult   = input.float(1.0, "Mult", group=grpOsc)
src       = input(close, "Source", group=grpOsc)
threshold = input.int(50, "Cross Threshold", minval=0, maxval=100, group=grpOsc)
bull_css  = input.color(#00e5ff, "Bullish Color", group=grpOsc)
bear_css  = input.color(#ff2e88, "Bearish Color", group=grpOsc)

grpSqz = "Squeeze Filter"
squeeze_length = input.int(20, "Squeeze Length", group=grpSqz)
BB_mult_sqz    = input.float(2.0, "BB StdDev Mult", group=grpSqz)
KC_mult        = input.float(1.5, "KC ATR Mult", group=grpSqz)
requireRecentSqz = input.bool(true, "Only Trade Within N Bars of Squeeze Release", group=grpSqz)
sqzReleaseWindow = input.int(10, "Release Window (bars)", group=grpSqz)

grpRisk = "ATR Stop"
atrLen        = input.int(30, "ATR Length", group=grpRisk)
atrMultiplier = input.float(1.4, "ATR Multiplier", group=grpRisk)

grpVis = "Visuals"
showGlow = input.bool(true, "Glow Effect", group=grpVis)

// ============ BB POWER OSCILLATOR ============
stdev = ta.stdev(src, bb_length) * bb_mult
ema   = ta.ema(src, bb_length)
upper = ema + stdev
lower = ema - stdev

bull = 0.0
bear = 0.0
bull_den = 0.0
bear_den = 0.0
for i = 0 to bb_length - 1
    bull += math.max(src[i] - upper[i], 0)
    bear += math.max(lower[i] - src[i], 0)
    bull_den += math.abs(src[i] - upper[i])
    bear_den += math.abs(lower[i] - src[i])
bull := bull_den != 0 ? bull / bull_den * 100 : 0
bear := bear_den != 0 ? bear / bear_den * 100 : 0

bull_grad = color.from_gradient(bull, 0, 100, color.new(bull_css, 100), color.new(bull_css, 30))
bear_grad = color.from_gradient(bear, 0, 100, color.new(bear_css, 100), color.new(bear_css, 30))

plot_bull = plot(bull, title="Bull Power", color=bull == 0 ? na : bull_css, linewidth=1)
plot_bear = plot(bear, title="Bear Power", color=bear == 0 ? na : bear_css, linewidth=1)
plot_zero = plot(0, color=na)
hline(threshold, "Threshold", color=color.new(color.gray, 50))
fill(plot_bull, plot_zero, color=bull_grad)
fill(plot_bear, plot_zero, color=bear_grad)

plot(showGlow ? bull : na, "Bull Glow", color=color.new(bull_css, 80), linewidth=6)
plot(showGlow ? bear : na, "Bear Glow", color=color.new(bear_css, 80), linewidth=6)

// ============ SQUEEZE ============
BB_basis = ta.sma(close, squeeze_length)
devBB    = BB_mult_sqz * ta.stdev(close, squeeze_length)
BB_upper = BB_basis + devBB
BB_lower = BB_basis - devBB

KC_basis = ta.ema(close, squeeze_length)
devKC    = ta.ema(ta.tr(true), squeeze_length)
KC_upper = KC_basis + devKC * KC_mult
KC_lower = KC_basis - devKC * KC_mult

squeezeOn  = BB_lower > KC_lower and BB_upper < KC_upper
squeezeOff = not squeezeOn
squeezeReleased = squeezeOff and squeezeOn[1]

var int barsSinceRelease = 999999
if squeezeReleased
    barsSinceRelease := 0
else if barsSinceRelease < 999999
    barsSinceRelease += 1

inReleaseWindow = not requireRecentSqz or barsSinceRelease <= sqzReleaseWindow

plot(0, title="Squeeze Dots", color=squeezeOn ? color.new(#ffaa00, 0) : color.new(color.gray, 80), style=plot.style_circles, linewidth=3)

// ============ ATR ============
atr = ta.atr(atrLen)

// ============ ENTRY LOGIC ============
bull_cross = ta.crossover(bull, threshold)
bear_cross = ta.crossover(bear, threshold)

longCondition  = bull_cross and inReleaseWindow and strategy.position_size == 0
shortCondition = bear_cross and inReleaseWindow and strategy.position_size == 0

// ============ STATE ============
var float plannedStop  = na
var float entryPrice   = na
var float initStop     = na
var float target       = na
var float trailStop    = na
var bool  beApplied    = false
var int   entryBarIndex = na

if longCondition
    plannedStop = close - atr * atrMultiplier
    riskAmt     = strategy.equity * (risk_per_trade / 100)
    riskDist    = close - plannedStop
    qty         = riskDist > 0 ? riskAmt / riskDist : 0
    if qty > 0
        strategy.entry("Long", strategy.long, qty=qty)

if shortCondition
    plannedStop = close + atr * atrMultiplier
    riskAmt     = strategy.equity * (risk_per_trade / 100)
    riskDist    = plannedStop - close
    qty         = riskDist > 0 ? riskAmt / riskDist : 0
    if qty > 0
        strategy.entry("Short", strategy.short, qty=qty)

// detect actual fill, use REAL fill price
justEnteredLong  = strategy.position_size > 0 and strategy.position_size[1] <= 0
justEnteredShort = strategy.position_size < 0 and strategy.position_size[1] >= 0

if justEnteredLong
    entryPrice    := strategy.position_avg_price
    initStop      := plannedStop
    target        := entryPrice + (entryPrice - plannedStop) * rr_ratio
    trailStop     := plannedStop
    beApplied     := false
    entryBarIndex := bar_index

if justEnteredShort
    entryPrice    := strategy.position_avg_price
    initStop      := plannedStop
    target        := entryPrice - (plannedStop - entryPrice) * rr_ratio
    trailStop     := plannedStop
    beApplied     := false
    entryBarIndex := bar_index

// ============ EXIT MANAGEMENT ============
if strategy.position_size > 0
    riskDist = entryPrice - initStop
    beLevel  = entryPrice + riskDist * be_trigger_pct
    if not beApplied and high >= beLevel
        beApplied := true
        trailStop := entryPrice
    if beApplied and trail_after_be
        trailStop := math.max(trailStop, high - atr * trailAtrMult)
    if bar_index - entryBarIndex >= maxHoldBars
        strategy.close("Long", comment="Max Hold")
    strategy.exit("Long Exit", "Long", stop=trailStop, limit=target)

if strategy.position_size < 0
    riskDist = initStop - entryPrice
    beLevel  = entryPrice - riskDist * be_trigger_pct
    if not beApplied and low <= beLevel
        beApplied := true
        trailStop := entryPrice
    if beApplied and trail_after_be
        trailStop := math.min(trailStop, low + atr * trailAtrMult)
    if bar_index - entryBarIndex >= maxHoldBars
        strategy.close("Short", comment="Max Hold")
    strategy.exit("Short Exit", "Short", stop=trailStop, limit=target)

if strategy.position_size == 0
    entryPrice    := na
    initStop      := na
    target        := na
    trailStop     := na
    beApplied     := false
    entryBarIndex := na
````
