# Drop's Opening Range Breakout (ORB)

- url: https://www.tradingview.com/script/7SSRGEbI-Drop-s-Opening-Range-Breakout-ORB/
- type: strategy
- pine_id: PUB;32d3f7c084634182b102099d13d4fe82
- version: 1.0

## Description

[b]Overview[/b]
[b]Drop's Opening Range Breakout (DORB)[/b] is an institutional-grade intraday trading strategy built on classical Opening Range Breakout principles, but heavily upgraded with professional quant risk management and entry filters. 

While standard ORB strategies suffer from high slippage, fakeouts, and afternoon chop, DORB solves these issues using a pullback limit-order mechanism, macro daily trend alignment, and dynamic risk parity sizing. 

This strategy is shared [b]100% free[/b] for the community to study, backtest, and utilize.

[b]🧠 Core Strategy Logic[/b]
The strategy operates on a strict schedule to capture the high-momentum morning volatility while avoiding low-liquidity periods:

[list]
[*] [b]Opening Range Definition (09:30 - 09:45 EST):[/b] The high and low boundaries of the first 15 minutes of the New York session are locked in.
[*] [b]Trading Execution Window (09:45 - 11:30 EST):[/b] Breakout trades are triggered during this period when price breaks through the opening range boundaries.
[*] [b]Hard Time Cutoff (11:30 EST):[/b] Any active position is forcefully closed. This prevents the strategy from holding positions during lunch hours and the afternoon chop, locking in morning gains.
[/list]

[b]🚀 Quant-Grade Enhancements[/b]
To elevate this strategy from a simple retail indicator to a robust algorithmic model, the following upgrades are built in:

[list]
[*] [b]Pullback Limit Entry (Anti-Slippage):[/b] Chasing breakouts with market orders is a primary cause of slippage and trading losses. When enabled, this feature rests a Limit Order exactly at the range boundary (Range High for Longs, Range Low for Shorts) once a breakout is detected. Price must pull back to fill the order, ensuring a high-quality average entry price and avoiding fakeouts.
[*] [b]Macro Daily Trend Alignment:[/b] To avoid trading against institutional momentum, the strategy references the Daily 200 EMA. It only executes Long breakouts if the daily close is above the 200 EMA, and Short breakouts if below.
[*] [b]Quant Risk Parity (Dynamic Position Sizing):[/b] Sizes the contract/share volume dynamically based on a fixed percentage of account equity (e.g., risking exactly 1.0% per trade) relative to the stop loss distance.
[*] [b]Opening Range ATR Filter:[/b] Filters out trades if the opening range is abnormally wide (meaning momentum is already exhausted) or abnormally narrow (meaning it's a choppy, range-bound day).
[*] [b]Volume Expansion Filter:[/b] Requires the breakout candle's volume to exceed a rolling 20-period average volume by a user-defined multiplier, confirming institutional interest in the breakout.
[*] [b]Flexible Stop Loss Options:[/b] Features a "Range Midpoint Stop" option which places the Stop Loss at the 50% mark of the opening range for a tight risk profile, or opposite-side range placement for a wider stop.
[*] [b]Automatic Breakeven (Auto-BE):[/b] Once price reaches a 1:1 risk-to-reward ratio, the stop loss is automatically trailed to the entry price to lock in a risk-free trade.
[/list]

[b]📊 Backtest Performance & Key Metrics[/b]
Below is the performance summary of the strategy during its latest backtest run:

[list]
[*] [b]Backtest Period:[/b] April 5, 2026 – May 28, 2026
[*] [b]Total Profit/Loss:[/b] +$11,887.50 (+11.89%)
[*] [b]Profit Factor:[/b] 3.456 (An exceptional ratio showing high efficiency and quality wins)
[*] [b]Win Rate:[/b] 68.42% (13 wins out of 19 total trades)
[*] [b]Max Drawdown:[/b] $1,862.50 (A very conservative 1.76% of account equity)
[*] [b]Expected Payoff:[/b] $581.45 per trade
[*] [b]Sharpe Ratio:[/b] 0.343 (unannualized/raw short-term calculation)
[/list]

[b]⚙️ Settings & Configuration Guide[/b]
[list]
[*] [b]Timeframes:[/b] Intraday charts only (recommended: 5m, 10m, 15m).
[*] [b]Session Definitions:[/b] By default, configured for the New York equities session (Range: 0930-0945, Execution: 0945-1130, Cutoff: 1130). If trading other sessions or time zones, adjust the hours accordingly.
[*] [b]Risk Management:[/b] For professional testing, enable [i]Use Dynamic Risk Sizing[/i] and configure your [i]Risk Per Trade (% of Equity)[/i] alongside your target [i]Risk-to-Reward Ratio[/i] (default is 1.0).
[/list]

[i]Disclaimer: This script is an analytical and backtesting tool. Past performance is not indicative of future results. Trading carries substantial risk of loss. Always perform your own due diligence before executing trades with real capital.[/i]

## Source Code

````pine
//@version=6
strategy("Drop's Opening Range Breakout (ORB)", "DORB", 
         overlay=true, 
         initial_capital=100000, 
         default_qty_type=strategy.fixed, 
         default_qty_value=1, 
         commission_type=strategy.commission.cash_per_contract, 
         commission_value=2.50, // Pessimistic friction (commissions)
         slippage=2,            // Pessimistic friction (slippage)
         margin_long=0,
         margin_short=0)

// ==========================================
// 1. INPUTS & PARAMETERS
// ==========================================
gp_orb     = "Opening Range Settings"
rangeSession = input.session("0930-0945", title="Range Definition Session", tooltip="The 15-minute window used to define the High and Low boundaries (New York Time).", group=gp_orb)
tradeSession = input.session("0945-1130", title="Trading Execution Session", tooltip="The window where the strategy is allowed to enter breakout trades.", group=gp_orb)
cutoffTime   = input.string("1130", title="Hard Time Cutoff (HHMM)", tooltip="The time of day when all active positions are forcefully closed to avoid the afternoon chop.", group=gp_orb)

gp_risk    = "Risk Management"
useHalfwayStop = input.bool(true, title="Use Range Midpoint for Stop?", tooltip="If enabled, the Stop Loss is placed at the 50% mark of the opening range (tight stop). If disabled, it is placed at the opposite side of the range (wide stop).", group=gp_risk)
riskReward     = input.float(1.0, title="Risk-to-Reward Ratio (1:X)", minval=0.5, step=0.1, group=gp_risk)

gp_quant   = "Quant Institutional Upgrades"
usePullbackLimit = input.bool(true, title="Use Pullback Limit Entry?", tooltip="Instead of chasing breakouts with market orders, this rests a Limit Order at the breakout boundary. Dramatically reduces slippage and fakeouts.", group=gp_quant)
useDynamicSizing = input.bool(false, title="Use Dynamic Risk Sizing?", tooltip="Enables professional risk parity. Sizes contract volume dynamically based on a fixed percentage of account equity.", group=gp_quant)
riskPerTrade     = input.float(1.0, title="Risk Per Trade (% of Equity)", minval=0.1, maxval=5.0, step=0.1, group=gp_quant)
maxQtyCap        = input.int(10, title="Max Contract Limit Cap", minval=1, group=gp_quant)

useDailyTrend    = input.bool(true, title="Align with Daily Trend?", tooltip="Only allows Long breakouts if price is above the Daily 200 EMA, and Shorts if below. Prevents trading against institutional flows.", group=gp_quant)

gp_filters = "Advanced Filters"
useVolFilter = input.bool(false, title="Require Volume Expansion?", tooltip="Breakout candle volume must exceed the average volume of the last 20 bars to confirm institutional commitment.", group=gp_filters)
volMult      = input.float(1.2, title="Volume Multiplier", minval=0.5, step=0.1, group=gp_filters)

useRangeFilter = input.bool(false, title="Filter Extreme Range Sizes?", tooltip="Prevents trading if the opening range is too wide (exhausted momentum) or too narrow (noise).", group=gp_filters)
maxRangeAtrMult = input.float(2.0, title="Max Range ATR Mult", tooltip="Do not trade if opening range is wider than this multiple of the 14-period ATR.", group=gp_filters)
minRangeAtrMult = input.float(0.4, title="Min Range ATR Mult", tooltip="Do not trade if opening range is narrower than this multiple of the 14-period ATR.", group=gp_filters)

useAutoBE = input.bool(true, title="Move Stop to Breakeven?", tooltip="Once trade reaches a 1:1 risk-to-reward ratio, move stop loss to entry.", group=gp_filters)

// Force New York Timezone to make backtest independent of the user's local chart settings
tz = "America/New_York"

// ==========================================
// 2. DAILY TREND SECURITY RESOLUTION
// ==========================================
// Pull Daily SMA/EMA dynamically to establish institutional macro trend filter
dailyClose = request.security(syminfo.tickerid, "D", close)
dailyEma   = request.security(syminfo.tickerid, "D", ta.ema(close, 200))
dailyBullish = dailyClose > dailyEma

// ==========================================
// 3. SESSION TIMING LOGIC
// ==========================================
if not timeframe.isintraday
    runtime.error("This strategy is designed for intraday charts only (e.g. 1m, 2m, 5m, 15m).")

inRangePeriod = not na(time(timeframe.period, rangeSession + ":23456", tz))
inTradeWindow = not na(time(timeframe.period, tradeSession + ":23456", tz))

currentHour   = hour(time, tz)
currentMinute = minute(time, tz)
currentTimeFormatted = currentHour * 100 + currentMinute
cutoffFormatted      = str.tonumber(cutoffTime)
isPastCutoff         = currentTimeFormatted >= cutoffFormatted and currentTimeFormatted < 1600

// ==========================================
// 4. CAPTURING THE RANGE BOUNDARIES
// ==========================================
var float rangeHigh = na
var float rangeLow  = na
var bool  rangeDefined = false
var bool  tradedToday  = false
var bool  isRangeValid = true

isNewDay = ta.change(time("D", tz)) != 0

// Reset variables at the start of each trading day
if isNewDay
    rangeHigh := na
    rangeLow  := na
    rangeDefined := false
    tradedToday  := false
    isRangeValid := true

atrVal = ta.atr(14)

if inRangePeriod
    if na(rangeHigh)
        rangeHigh := high
        rangeLow  := low
    else
        rangeHigh := math.max(rangeHigh, high)
        rangeLow  := math.min(rangeLow, low)

if not inRangePeriod and not na(rangeHigh) and not rangeDefined
    rangeDefined := true
    rangeSize = rangeHigh - rangeLow
    
    if useRangeFilter and not na(atrVal)
        isRangeValid := (rangeSize <= (atrVal * maxRangeAtrMult)) and (rangeSize >= (atrVal * minRangeAtrMult))

// ==========================================
// 5. TRIGGER CONDITIONS
// ==========================================
volSma = ta.sma(volume, 20)
volExpansion = not useVolFilter or (volume > volSma * volMult)

// Macro trend check
trendLongAllowed  = not useDailyTrend or dailyBullish
trendShortAllowed = not useDailyTrend or not dailyBullish

// Standard breakouts
breakoutLong  = rangeDefined and isRangeValid and not tradedToday and inTradeWindow and ta.crossover(close, rangeHigh) and volExpansion and trendLongAllowed
breakoutShort = rangeDefined and isRangeValid and not tradedToday and inTradeWindow and ta.crossunder(close, rangeLow) and volExpansion and trendShortAllowed

// ==========================================
// 6. QUANT RISK PARITY POSITION SIZING
// ==========================================
// Calculate dynamic contract quantity based on custom risk budget
f_calculate_qty(float riskPrice) =>
    if useDynamicSizing
        riskCash = strategy.equity * (riskPerTrade / 100.0)
        pointVal = syminfo.pointvalue
        calculatedQty = riskCash / (riskPrice * pointVal)
        math.min(maxQtyCap, math.max(1, math.floor(calculatedQty)))
    else
        1

// ==========================================
// 7. STRATEGY EXECUTION (Trade Management)
// ==========================================
var float activeSL = na
var float activeTP = na
var bool  reachedBE = false

if strategy.position_size == 0
    reachedBE := false

// If the trade window closes or cutoff is reached, cancel any unfilled pullback limit orders
if not inTradeWindow or isPastCutoff
    strategy.cancel("ORB Long Pullback")
    strategy.cancel("ORB Short Pullback")

// Long Entry execution
if breakoutLong and strategy.position_size == 0
    rangeSize = rangeHigh - rangeLow
    stopPrice = useHalfwayStop ? (rangeHigh - (rangeSize * 0.5)) : rangeLow
    riskAmt   = close - stopPrice
    qtySize   = f_calculate_qty(riskAmt)
    
    activeSL  := stopPrice
    activeTP  := close + (riskAmt * riskReward)
    reachedBE := false
    
    if usePullbackLimit
        // Rests a limit buy order exactly at the Range High boundary
        strategy.entry("ORB Long Pullback", strategy.long, qty=qtySize, limit=rangeHigh)
    else
        strategy.entry("ORB Long", strategy.long, qty=qtySize)
    
    tradedToday := true

// Short Entry execution
if breakoutShort and strategy.position_size == 0
    rangeSize = rangeHigh - rangeLow
    stopPrice = useHalfwayStop ? (rangeLow + (rangeSize * 0.5)) : rangeHigh
    riskAmt   = stopPrice - close
    qtySize   = f_calculate_qty(riskAmt)
    
    activeSL  := stopPrice
    activeTP  := close - (riskAmt * riskReward)
    reachedBE := false
    
    if usePullbackLimit
        // Rests a limit sell order exactly at the Range Low boundary
        strategy.entry("ORB Short Pullback", strategy.short, qty=qtySize, limit=rangeLow)
    else
        strategy.entry("ORB Short", strategy.short, qty=qtySize)
    
    tradedToday := true

// Trade execution exit brackets
if strategy.position_size > 0
    initialRisk = strategy.position_avg_price - activeSL
    if useAutoBE and not reachedBE and (close >= strategy.position_avg_price + initialRisk)
        activeSL := strategy.position_avg_price
        reachedBE := true
    
    strategy.exit("Exit Long", stop=activeSL, limit=activeTP)

if strategy.position_size < 0
    initialRisk = activeSL - strategy.position_avg_price
    if useAutoBE and not reachedBE and (close <= strategy.position_avg_price - initialRisk)
        activeSL := strategy.position_avg_price
        reachedBE := true

    strategy.exit("Exit Short", stop=activeSL, limit=activeTP)

// Force Time Cutoff
if strategy.position_size != 0 and isPastCutoff
    strategy.close_all(comment="Time Cutoff (11:30 EST)")

// ==========================================
// 8. CHART VISUALIZATION
// ==========================================
plot(rangeDefined ? rangeHigh : na, title="Opening Range High", color=isRangeValid ? color.green : color.gray, style=plot.style_stepline, linewidth=2)
plot(rangeDefined ? rangeLow : na, title="Opening Range Low", color=isRangeValid ? color.red : color.gray, style=plot.style_stepline, linewidth=2)
plot(rangeDefined and useHalfwayStop ? (rangeHigh + rangeLow) / 2 : na, title="Range Midpoint", color=color.orange)

isTradingHour = inTradeWindow and not isPastCutoff
bgcolor(isTradingHour ? color.new(color.blue, 96) : na, title="Trading Session Background")
````
