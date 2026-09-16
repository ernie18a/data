<!-- tradingview-pine-id: PUB;cb9c639dfd9743f092d41b52b3ac4456 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# EMA Trend + MTF Stochastic Strategy

Source: https://www.tradingview.com/script/o9dV6uWc-Trend-Trigger-EMA-Trend-Filter-MTF-Stochastic-Entry-with-ATR/

## Description

Overview
This strategy combines two proven, independent mechanisms rather than inventing a new indicator: a slow-moving EMA trend filter decides which direction is permitted, and a higher-timeframe-confirmed stochastic oscillator decides when to actually enter. Trend and timing are handled by separate logic layers so each does one job well, instead of stacking multiple overlapping conditions that rarely align.

How it works

[*]Trend permission (EMA 38/62): Trades are only allowed in the direction the EMA fast/slow relationship currently supports — longs when fast > slow, shorts when fast < slow. This keeps the strategy from fighting the prevailing trend. This filter can be disabled for a pure counter-trend/mean-reversion test.
[*]Entry timing (MTF Stochastic): The current-timeframe %K/%D stochastic must cross through the midline (50) with rising/falling momentum, and the same stochastic recalculated on the next higher timeframe (auto-stepped: 1m→5m, 1h→4h, 1D→1W, etc.) must agree in direction. This is the same core logic as classic MTF stochastic systems — entries are timed at momentum inflection points that are confirmed on a broader structural timeframe, not just the noisy current one.
[*]Staged, ATR-based risk management: Every position opens with an ATR-scaled hard stop. Once the trade reaches a configurable R-multiple (default 1.0R), the stop moves to breakeven — locking in "no loss" without capping upside. Past a second, larger R-multiple (default 1.5R), the stop begins trailing using ATR (not fixed ticks), so the trailing distance scales with the instrument's actual volatility instead of an arbitrary number.
[*]Secondary exits: A stochastic-fade exit (mirroring the entry logic in reverse) and an optional trend-flip exit close the trade early if the higher-timeframe signal reverses or the EMA trend turns against the position. A time-stop closes any trade that's gone nowhere after N bars.

Distinctive features

[*]Trend and timing are decoupled — you can test pure momentum-timing (trend filter off) versus trend-confirmed pullback entries (trend filter on) with one toggle.
[*]No fixed-tick trailing stop — every risk parameter (initial stop, breakeven trigger, trailing distance) is ATR-scaled, so the same settings behave sensibly across instruments with very different volatility (e.g., a $30 stock vs. a $60,000 crypto asset) without manual re-tuning.
[*]Risk-based position sizing ties trade size directly to the ATR stop distance and a fixed % of equity risked per trade, rather than a flat share/contract count.
[*]A compact confirmation meter (colored bar table) shows trend + stochastic alignment strength at a glance — no cluttered multi-line oscillator overlays on the chart.

Tips for use

[*]Test with the trend filter both on and off separately — they represent genuinely different strategies (trend-following pullback entries vs. pure momentum reversal) and will perform differently depending on the instrument's regime.
[*]Start testing on liquid instruments and a base timeframe of 1H or higher — the automatic higher-timeframe step needs enough bars underneath it to be meaningful; very low timeframes (1–5 min) compress the "higher timeframe" confirmation into something almost as noisy as the entry timeframe itself.
[*]Check Average Win vs. Average Loss in the Strategy Tester, not just win rate — this strategy is built to keep those two numbers close together (via the breakeven/trailing stages), and that ratio is a better health check than win rate alone.
[*]The breakEvenR and trailStartR inputs interact — a very tight breakeven trigger combined with a very close trail can choke off winners before they develop; a very loose one leaves more of the position exposed to giveback. Both are worth walking through several combinations on your specific instrument and timeframe rather than assuming one setting is universally correct.
[*]This is a rules-based tool, not a guarantee — past backtest results don't ensure future performance, and all trading involves risk of loss.

---

## Source Code

````pine
//@version=6
strategy("EMA Trend + MTF Stochastic Strategy", shorttitle="EMA+MTF Stoch", overlay=true,
     pyramiding=0, initial_capital=10000, currency=currency.USD,
     default_qty_type=strategy.percent_of_equity, default_qty_value=100,
     commission_type=strategy.commission.percent, commission_value=0.02)

// ============================================================================
// TREND FILTER
// ============================================================================
grpTrend = "Trend Filter (EMA)"
emaFastLen = input.int(38, "EMA Fast", minval=1, group=grpTrend)
emaSlowLen = input.int(62, "EMA Slow", minval=1, group=grpTrend)

emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)

trendUp   = emaFast > emaSlow
trendDown = emaFast < emaSlow

emaCol = trendUp ? color.lime : trendDown ? color.red : color.yellow
p1 = plot(emaSlow, "EMA Slow", color=emaCol, linewidth=2)
p2 = plot(emaFast, "EMA Fast", color=emaCol, linewidth=1)
fill(p1, p2, color=color.new(color.gray, 85))

// ============================================================================
// STOCHASTIC TIMING TRIGGER
// ============================================================================
grpStoch = "MTF Stochastic"
len      = input.int(11, "Stoch Length", minval=1, group=grpStoch)
smoothK  = input.int(3, "SmoothK", minval=1, group=grpStoch)
smoothD  = input.int(3, "SmoothD", minval=1, group=grpStoch)
upLine   = input.int(80, "Upper Line", minval=50, maxval=90, group=grpStoch)
lowLine  = input.int(20, "Lower Line", minval=10, maxval=50, group=grpStoch)

k = ta.sma(ta.stoch(close, high, low, len), smoothK)
d = ta.sma(k, smoothD)

mtfRes = timeframe.period == "1" ? "5" : timeframe.period == "5" ? "15" : timeframe.period == "15" ? "30" :
     timeframe.period == "30" ? "60" : timeframe.period == "60" ? "240" : timeframe.period == "240" ? "D" :
     timeframe.period == "D" ? "W" : "M"

f_stoch() =>
    kk = ta.sma(ta.stoch(close, high, low, len), smoothK)
    dd = ta.sma(kk, smoothD)
    [ta.linreg(kk, len, 0), ta.linreg(dd, len, 0)]

[mtfK, mtfD] = request.security(syminfo.tickerid, mtfRes, f_stoch(), lookahead=barmerge.lookahead_off)

// ============================================================================
// ENTRY
// ============================================================================
grpEntry = "Entry Logic"
requireTrend = input.bool(true, "Require EMA Trend Agreement?", group=grpEntry)
tradeDir = input.string("Both", "Trade Direction", options=["Both", "Long Only", "Short Only"], group=grpEntry)

stochLong  = ta.crossover(mtfK, 50) and k > 50 and ta.change(k, 1) > 0 and k > d and mtfK > mtfD
stochShort = ta.crossunder(mtfD, 50) and k < 50 and ta.change(k, 1) < 0 and k < d and mtfK < mtfD

longCondition  = stochLong  and (not requireTrend or trendUp)   and tradeDir != "Short Only"
shortCondition = stochShort and (not requireTrend or trendDown) and tradeDir != "Long Only"

// ============================================================================
// RISK / EXIT SETTINGS — staged, ATR-scaled throughout (no fixed-tick trail)
// ============================================================================
grpExit = "Exit Logic"
atrLen         = input.int(14, "ATR Length", minval=1, group=grpExit)
atrStopMult    = input.float(1.5, "ATR Initial Stop Multiple", minval=0.1, step=0.1, group=grpExit)
breakEvenR     = input.float(1.0, "Move Stop To Breakeven At (R)", minval=0.1, step=0.1, group=grpExit)
trailStartR    = input.float(1.5, "Start ATR Trailing At (R)", minval=0.1, step=0.1, group=grpExit)
trailATRMult   = input.float(1.5, "ATR Trailing Stop Multiple", minval=0.1, step=0.1, group=grpExit)
useTrendExit   = input.bool(true, "Exit If EMA Trend Flips Against Position?", group=grpExit)
maxBarsInTrade = input.int(60, "Max Bars In Trade (time stop, 0=off)", minval=0, group=grpExit)

exitLongSignal  = ta.crossunder(mtfD, upLine)
exitShortSignal = ta.crossover(mtfK, lowLine)

atrVal = ta.atr(atrLen)

// ============================================================================
// POSITION SIZING
// ============================================================================
grpSize = "Position Sizing"
sizeMode    = input.string("Risk-Based (ATR stop)", "Sizing Mode", options=["Percent of Equity", "Risk-Based (ATR stop)"], group=grpSize)
equityPct   = input.float(100, "Percent of Equity per Trade", minval=1, maxval=100, group=grpSize)
riskPercent = input.float(1.0, "Risk % of Equity (Risk-Based only)", minval=0.1, step=0.1, group=grpSize)

riskCapital = strategy.equity * (riskPercent / 100)
stopDistEstimate = atrVal * atrStopMult
qty = sizeMode == "Risk-Based (ATR stop)" ? (stopDistEstimate > 0 ? riskCapital / stopDistEstimate : 0.0) : (strategy.equity * equityPct / 100) / close

// ============================================================================
// ORDERS + STAGED STOP MANAGEMENT
// ============================================================================
var int   entryBar      = na
var float entryPrice    = na
var float entryStopDist = na
var float stopLevel     = na

if longCondition and strategy.position_size <= 0 and qty > 0
    entryStopDist := atrVal * atrStopMult
    stopLevel := close - entryStopDist
    entryPrice := close
    strategy.entry("Long", strategy.long, qty=qty)
    entryBar := bar_index

if shortCondition and strategy.position_size >= 0 and qty > 0
    entryStopDist := atrVal * atrStopMult
    stopLevel := close + entryStopDist
    entryPrice := close
    strategy.entry("Short", strategy.short, qty=qty)
    entryBar := bar_index

// staged stop logic, recalculated every bar while in a position
if strategy.position_size > 0 and not na(entryStopDist) and entryStopDist > 0
    currentR = (close - entryPrice) / entryStopDist
    if currentR >= trailStartR
        stopLevel := math.max(stopLevel, close - atrVal * trailATRMult)   // ATR trail, only after target reached
    else if currentR >= breakEvenR
        stopLevel := math.max(stopLevel, entryPrice)                       // lock breakeven
    // else: stopLevel stays at the original ATR initial stop

if strategy.position_size < 0 and not na(entryStopDist) and entryStopDist > 0
    currentR = (entryPrice - close) / entryStopDist
    if currentR >= trailStartR
        stopLevel := math.min(stopLevel, close + atrVal * trailATRMult)
    else if currentR >= breakEvenR
        stopLevel := math.min(stopLevel, entryPrice)

if strategy.position_size > 0
    strategy.exit("Long Exit", from_entry="Long", stop=stopLevel)
    if exitLongSignal
        strategy.close("Long", comment="Stoch Fade")
    if useTrendExit and trendDown
        strategy.close("Long", comment="Trend Flip")

if strategy.position_size < 0
    strategy.exit("Short Exit", from_entry="Short", stop=stopLevel)
    if exitShortSignal
        strategy.close("Short", comment="Stoch Fade")
    if useTrendExit and trendUp
        strategy.close("Short", comment="Trend Flip")

if maxBarsInTrade > 0 and strategy.position_size != 0 and not na(entryBar) and (bar_index - entryBar) >= maxBarsInTrade
    strategy.close_all(comment="Time Stop")
    entryBar := na

if strategy.position_size == 0
    entryBar := na
    entryPrice := na
    entryStopDist := na
    stopLevel := na

// ============================================================================
// VISUALS
// ============================================================================
grpVis = "Visuals"
showMeter = input.bool(true, "Show Confirmation Meter", group=grpVis)
showLevels = input.bool(true, "Show Stop Line", group=grpVis)

bullScore = (trendUp ? 40 : 0) + (k > d ? 20 : 0) + (mtfK > mtfD ? 20 : 0) + (k > 50 ? 20 : 0)
bearScore = (trendDown ? 40 : 0) + (k < d ? 20 : 0) + (mtfK < mtfD ? 20 : 0) + (k < 50 ? 20 : 0)

var table meter = table.new(position.top_right, 11, 2, border_width=1)
if showMeter and barstate.islast
    table.cell(meter, 0, 0, "BULL " + str.tostring(bullScore), text_color=color.white, bgcolor=color.new(color.green, 40))
    table.cell(meter, 0, 1, "BEAR " + str.tostring(bearScore), text_color=color.white, bgcolor=color.new(color.red, 40))
    for i = 1 to 10
        table.cell(meter, i, 0, "", bgcolor = i <= math.round(bullScore / 10) ? color.green : color.new(color.gray, 80))
        table.cell(meter, i, 1, "", bgcolor = i <= math.round(bearScore / 10) ? color.red : color.new(color.gray, 80))

plot(showLevels and strategy.position_size != 0 ? stopLevel : na, "Stop", color=color.red, style=plot.style_circles, linewidth=2)

plotshape(longCondition, "Long Entry", shape.triangleup, location.belowbar, color=color.lime, size=size.small)
plotshape(shortCondition, "Short Entry", shape.triangledown, location.abovebar, color=color.red, size=size.small)
````
