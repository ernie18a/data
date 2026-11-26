# Delta Tether System: Trade the Gap Between Price and Volume

- url: https://www.tradingview.com/script/5t9AmmPD-Delta-Tether-System-Trade-the-Gap-Between-Price-and-Volume/
- type: strategy
- pine_id: PUB;8dbf374fc7a341d8b8873609890bb1d4
- version: 1.0

## Description

[b]The Core Idea[/b]

Most indicators track price. This one tracks the gap between price and the buying or selling pressure behind it.

When price runs far ahead of volume weight, it tends to snap back. When price and volume stay close, moves are more likely to continue. The Delta Tether measures that gap and gives you two ways to trade it.

[b]What Is Delta?[/b]

Delta here is an estimate of cumulative buying versus selling pressure. If a bar closes up, its volume counts as buying. If it closes down, that volume counts as selling. These values are summed over the last 80 bars (adjustable), giving a running read on whether buyers or sellers have been in control. No tick data needed. Works on any timeframe and instrument.

[b]The Delta Line[/b]

The cumulative delta estimate is fitted to price using linear regression. The result is the Delta Line, shown as a white line on the chart. It represents the price level implied by recent volume balance. Optional EMA or SMA smoothing (default: EMA 8) reduces noise without adding significant lag.

[b]The Tether[/b]

The tether is the distance between the closing price and the delta line, measured in ATR(14) units. A green tether means price is above the delta line (buyers ahead). A red tether means price is below it (sellers ahead).

ATR scaling makes the gap comparable across instruments. A 2 ATR gap on Gold means the same thing as a 2 ATR gap on Bitcoin: price is two volatility units away from where volume says it should be.

Reference rungs at 1, 2, and 3 ATR above and below the delta line are plotted on the chart and used for stop placement.

[b]The Rank[/b]

The current tether distance is ranked as a percentile against the past 800 bars. A rank near zero means price and volume are aligned. A rank near 100 means the gap is unusually large by recent standards. A color coded table in the top right corner shows the live rank. When the rank stays at or above 90 for two or more consecutive bars, a triangle marker flags a persistent extreme on the chart.

[b]Two Strategy Modes[/b]

Select the mode from the input dropdown. They use opposite logic.

[list]
[*]Mode A: Mean Reversion
[/list]

Price stretched too far from volume tends to return to it. A long entry triggers when price is below the delta line, the rank is at or above 80 (adjustable), and the rank has started falling, meaning the peak is likely in. A short entry is the mirror image. The strategy does not enter just because the rank is high. It waits for the rank to start contracting first, which is a more reliable sign that the extreme has been reached. Exit is when price crosses back through the delta line or the stop or target is hit. Stop goes beyond the 3 ATR rung plus a 0.3 ATR buffer. Default target is 2:1 risk to reward.

[list]
[*]Mode B: Trend Following
[/list]

When price crosses the delta line while the tether is small, the move has volume support. A long entry triggers when the tether crosses from negative to positive and the rank is below 25 (adjustable), confirming the breakout is not already overextended. A short is the same in reverse. Exit is when price crosses back through the delta line the other way, or the stop or target is hit. Stop goes just beyond the delta line plus a 0.3 ATR buffer. Default target is 4:1.

[b]Confirmation Filters[/b]

Three filters are on by default. All must pass for an entry, and each can be turned off individually.

The trend filter uses a 100 period EMA to set the directional bias. In Mean Reversion mode, longs require price to be below the EMA and shorts require price above it. In Trend Following mode the logic is reversed. The volume filter requires the entry bar's volume to exceed its 20 period average by at least 1.8x, keeping out low conviction signals. The rank cooldown blocks a new trade in the same direction until the rank has reset below 50 since the last exit, so the strategy does not enter again into a market that is still stretched.

[b]Risk and Trade Management[/b]

The stop is placed beyond the relevant ATR rung plus a 0.3 ATR buffer. The take profit is a fixed multiple of that stop distance: 2:1 for Mean Reversion, 4:1 for Trend Following, both adjustable.

Position sizing is risk based. Each trade risks 1% of current equity (adjustable), calculated from the entry to stop distance. A tighter stop means a larger position. A wider stop means a smaller one. The dollar risk per trade stays consistent regardless of market conditions.

The trailing stop is on by default. Once the trade is 1 ATR in profit, the stop moves to the delta line, locking in a partial gain if price reverses all the way back. There is no pyramiding. One position per direction at a time.

[b]Backtest Defaults[/b]

$10,000 starting capital, 0.05% commission, 2 ticks of slippage. All signals use confirmed, closed bars only. No repainting, no lookahead bias. Entries fill on the bar after the signal closes.

[b]Before You Trust the Results[/b]

Results are not shown here because they depend entirely on the instrument, timeframe, and date range you test.

Wait for at least 100 closed trades before judging any metric. Check win rate, profit factor, and max drawdown together, not in isolation. Mean Reversion tends to suit ranging markets. Trend Following tends to suit trending ones. If your broker charges more than 0.05% or you trade futures, update the commission input before drawing any conclusions. The 800 bar rank lookback takes 800 bars to fully populate, so signals early in a backtest are based on incomplete rank data.

[b]Alerts[/b]

Five alert conditions are included: Long Entry, Short Entry, Long Exit, Short Exit, and Extreme Rank Warning (rank at or above 90 for two or more consecutive bars). The Extreme Rank Warning fires whether or not a position is open, so it works as a standalone context alert even without using the strategy entries.

[i][b]Disclaimer[/b]

This script is for educational purposes only. It is not financial advice. Treat it as a starting framework to test and adjust, not a finished system. Past backtest results do not guarantee future performance.[/i]

## Source Code

````pine
//@version=6
strategy("Delta Tether System", overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=10, commission_type=strategy.commission.percent, commission_value=0.05, slippage=2, pyramiding=0)

// ===== DELTA GROUP =====
int    deltaLookback   = input.int(80, "Cumulative Delta Lookback", minval=2, group="Delta")
bool   useSmoothing    = input.bool(true, "Enable Smoothing", group="Delta")
string smoothType      = input.string('EMA', "Smoothing Type", options=["EMA", "Gaussian"], group="Delta")
int    smoothLength    = input.int(8, "Smoothing Length", minval=1, group="Delta")
int    atrLength       = input.int(14, "ATR Length", minval=1, group="Delta")
int    rankLookback    = input.int(800, "Rank Lookback (bars)", minval=10, group="Delta")

// ===== DISPLAY GROUP =====
bool showDeltaLine  = input.bool(true, "Show Delta Line", group="Display")
bool showTether     = input.bool(true, "Show Tether Lines", group="Display")
bool showRungs      = input.bool(true, "Show ATR Rungs", group="Display")
bool showRankTable  = input.bool(true, "Show Rank Stack Table", group="Display")
bool showExtremity  = input.bool(true, "Show Extremity Markers", group="Display")

// ===== MODE GROUP =====
string strategyMode = input.string('Trend Following', "Strategy Mode", options=["Mean Reversion", "Trend Following"], group="Mode")

// ===== FILTERS GROUP =====
bool  useTrendFilter   = input.bool(true, "Enable Trend Filter", group="Filters")
int   trendEmaLength   = input.int(100, "Trend EMA Length", minval=1, group="Filters")
bool  useVolumeFilter  = input.bool(true, "Enable Volume Surge Filter", group="Filters")
int   volSmaLength     = input.int(20, "Volume SMA Length", minval=1, group="Filters")
float volMultiplier    = input.float(1.8, "Volume Surge Multiplier", minval=0.1, group="Filters")
bool  useRankCooldown  = input.bool(true, "Enable Rank Cooldown Filter", group="Filters")

// ===== RISK GROUP =====
float riskPercent = input.float(1.0, "Risk % of Equity per Trade", minval=0.01, group="Risk")

// ===== EXITS GROUP =====
float mrThreshold      = input.float(80.0, "MR Rank Threshold (Entry)", minval=50, maxval=100, group="Exits")
float tfThreshold       = input.float(25.0, "TF Rank Threshold (Entry)", minval=0, maxval=50, group="Exits")
float atrBuffer         = input.float(0.3, "ATR Buffer Beyond Rung", minval=0, group="Exits")
float mrRR              = input.float(2.0, "Mean Reversion R:R", minval=0.1, group="Exits")
float tfRR              = input.float(4.0, "Trend Following R:R", minval=0.1, group="Exits")
bool  useTrailStop      = input.bool(true, "Enable Trailing Stop to Delta Line", group="Exits")

// ===== CALCULATIONS =====
float barDelta = close >= open ? volume : -volume
float cumDelta = math.sum(barDelta, deltaLookback)

var float sumX  = 0.0
var float sumY  = 0.0
var float sumXY = 0.0
var float sumX2 = 0.0

float regSrc = cumDelta

float slope  = 0.0
float intercept = 0.0
if barstate.isconfirmed or barstate.islast
    sumX  := 0.0
    sumY  := 0.0
    sumXY := 0.0
    sumX2 := 0.0
    for i = 0 to deltaLookback - 1
        xi = float(i)
        yi = close[i]
        sumX  += xi
        sumY  += yi
        sumXY += xi * yi
        sumX2 += xi * xi
    n = float(deltaLookback)
    denom = (n * sumX2 - sumX * sumX)
    slope := denom != 0 ? (n * sumXY - sumX * sumY) / denom : 0.0
    intercept := (sumY - slope * sumX) / n

float rawDeltaLine = intercept
float smoothedDeltaLine = useSmoothing ? (smoothType == "EMA" ? ta.ema(rawDeltaLine, smoothLength) : ta.sma(rawDeltaLine, smoothLength)) : rawDeltaLine
float deltaLine = smoothedDeltaLine

float atrValue = ta.atr(atrLength)

float tetherDistance = atrValue != 0 ? (close - deltaLine) / atrValue : 0.0
float absTether = math.abs(tetherDistance)

float rankPctRaw = ta.percentrank(absTether, rankLookback)
float tetherRank = na(rankPctRaw) ? 0.0 : rankPctRaw
float prevTetherRank = nz(tetherRank[1])

bool rankContracting = tetherRank < prevTetherRank

float rung1Up = deltaLine + 1.0 * atrValue
float rung2Up = deltaLine + 2.0 * atrValue
float rung3Up = deltaLine + 3.0 * atrValue
float rung1Dn = deltaLine - 1.0 * atrValue
float rung2Dn = deltaLine - 2.0 * atrValue
float rung3Dn = deltaLine - 3.0 * atrValue

bool tetherCrossUpZero = ta.crossover(tetherDistance, 0.0)
bool tetherCrossDnZero = ta.crossunder(tetherDistance, 0.0)

// ===== FILTERS =====
float trendEma = ta.ema(close, trendEmaLength)
bool trendUp   = close > trendEma
bool trendDn   = close < trendEma

float volSma = ta.sma(volume, volSmaLength)
bool volumeSurge = volume > volSma * volMultiplier

var bool cooldownLongReady  = true
var bool cooldownShortReady = true
if tetherRank < 50.0
    cooldownLongReady := true
    cooldownShortReady := true

// ===== MODE LOGIC =====
bool isMeanReversion = strategyMode == "Mean Reversion"
bool isTrendFollowing = strategyMode == "Trend Following"

bool mrLongRaw  = tetherDistance < 0 and tetherRank >= mrThreshold and rankContracting
bool mrShortRaw = tetherDistance > 0 and tetherRank >= mrThreshold and rankContracting

bool tfLongRaw  = tetherCrossUpZero and tetherRank < tfThreshold
bool tfShortRaw = tetherCrossDnZero and tetherRank < tfThreshold

bool trendFilterLongOk  = not useTrendFilter or (isMeanReversion ? trendDn : trendUp)
bool trendFilterShortOk = not useTrendFilter or (isMeanReversion ? trendUp : trendDn)
bool volFilterOk = not useVolumeFilter or volumeSurge
bool cooldownLongOk  = not useRankCooldown or cooldownLongReady
bool cooldownShortOk = not useRankCooldown or cooldownShortReady

bool longCondition  = (isMeanReversion ? mrLongRaw : tfLongRaw) and trendFilterLongOk and volFilterOk and cooldownLongOk and barstate.isconfirmed and strategy.position_size == 0
bool shortCondition = (isMeanReversion ? mrShortRaw : tfShortRaw) and trendFilterShortOk and volFilterOk and cooldownShortOk and barstate.isconfirmed and strategy.position_size == 0

// ===== STATE =====
var float longSL = na
var float longTP = na
var float shortSL = na
var float shortTP = na
var bool justEntered = false
var bool tradeWasLong = false
var bool tradeWasShort = false

// ===== ENTRY =====
if longCondition
    float stopBase = isMeanReversion ? rung3Dn : deltaLine
    longSL := stopBase - atrBuffer * atrValue
    float riskDist = close - longSL
    float rr = isMeanReversion ? mrRR : tfRR
    longTP := close + riskDist * rr
    strategy.entry("Long", strategy.long)
    justEntered := true
    if useRankCooldown
        cooldownLongReady := false

if shortCondition
    float stopBase = isMeanReversion ? rung3Up : deltaLine
    shortSL := stopBase + atrBuffer * atrValue
    float riskDist = shortSL - close
    float rr = isMeanReversion ? mrRR : tfRR
    shortTP := close - riskDist * rr
    strategy.entry("Short", strategy.short)
    justEntered := true
    if useRankCooldown
        cooldownShortReady := false

// ===== TRAILING STOP =====
if useTrailStop and strategy.position_size > 0 and not na(longSL)
    if (close - strategy.position_avg_price) >= atrValue
        longSL := math.max(longSL, deltaLine)

if useTrailStop and strategy.position_size < 0 and not na(shortSL)
    if (strategy.position_avg_price - close) >= atrValue
        shortSL := math.min(shortSL, deltaLine)

// ===== EXIT =====
bool mrLongExitSignal  = tetherCrossUpZero
bool mrShortExitSignal = tetherCrossDnZero
bool tfLongExitSignal  = tetherCrossDnZero
bool tfShortExitSignal = tetherCrossUpZero

if strategy.position_size > 0 and not na(longSL)
    bool structExit = isMeanReversion ? mrLongExitSignal : tfLongExitSignal
    if structExit and barstate.isconfirmed
        strategy.close("Long")
        tradeWasLong := true
    else
        strategy.exit("Long Exit", "Long", stop=longSL, limit=longTP)

if strategy.position_size < 0 and not na(shortSL)
    bool structExit = isMeanReversion ? mrShortExitSignal : tfShortExitSignal
    if structExit and barstate.isconfirmed
        strategy.close("Short")
        tradeWasShort := true
    else
        strategy.exit("Short Exit", "Short", stop=shortSL, limit=shortTP)

// ===== RESET =====
if strategy.position_size == 0 and not justEntered
    longSL := na
    longTP := na
    shortSL := na
    shortTP := na

justEntered := false

// ===== EXTREMITY TRACKING =====
var int extremeCount = 0
bool isExtreme = tetherRank >= 90.0
if isExtreme
    extremeCount += 1
else
    extremeCount := 0
bool extremeFlag = extremeCount >= 2

// ===== VISUALS =====
plot(showDeltaLine ? deltaLine : na, "Delta Line", color=color.white, linewidth=2)

color tetherColor = tetherDistance >= 0 ? color.green : color.red
plot(showTether ? close : na, "Tether Anchor", color=color.new(color.black, 100), display=display.none)

if showTether and barstate.isconfirmed
    line.new(bar_index, close, bar_index, deltaLine, color=tetherColor, width=1)

plot(showRungs ? rung1Up : na, "Rung +1 ATR", color=color.aqua, style=plot.style_circles)
plot(showRungs ? rung2Up : na, "Rung +2 ATR", color=color.aqua, style=plot.style_circles)
plot(showRungs ? rung3Up : na, "Rung +3 ATR", color=color.aqua, style=plot.style_circles)
plot(showRungs ? rung1Dn : na, "Rung -1 ATR", color=color.orange, style=plot.style_circles)
plot(showRungs ? rung2Dn : na, "Rung -2 ATR", color=color.orange, style=plot.style_circles)
plot(showRungs ? rung3Dn : na, "Rung -3 ATR", color=color.orange, style=plot.style_circles)

plotshape(showExtremity and extremeFlag and tetherDistance > 0 ? high : na, title="Extreme Up", style=shape.triangledown, location=location.abovebar, color=color.red, size=size.tiny)
plotshape(showExtremity and extremeFlag and tetherDistance < 0 ? low : na, title="Extreme Down", style=shape.triangleup, location=location.belowbar, color=color.green, size=size.tiny)

var table rankTable = table.new(position.top_right, 2, 10, border_width=1)
if showRankTable and barstate.islast
    int litCellsUp = int(math.round(tetherRank / 10))
    for i = 0 to 9
        bool lit = (9 - i) < litCellsUp
        color cellColor = lit ? (tetherRank >= 90 ? color.red : color.orange) : color.new(color.black, 80)
        table.cell(rankTable, 0, i, "", bgcolor=cellColor)
        table.cell(rankTable, 1, i, "", bgcolor=cellColor)

// ===== ALERTS =====
alertcondition(longCondition, "Long Entry", "Delta Tether: Long entry signal")
alertcondition(shortCondition, "Short Entry", "Delta Tether: Short entry signal")
alertcondition(strategy.position_size[1] > 0 and strategy.position_size == 0, "Long Exit", "Delta Tether: Long exit")
alertcondition(strategy.position_size[1] < 0 and strategy.position_size == 0, "Short Exit", "Delta Tether: Short exit")
alertcondition(extremeFlag, "Extreme Rank Warning", "Delta Tether: Rank >= 90th percentile for 2+ bars")
````
