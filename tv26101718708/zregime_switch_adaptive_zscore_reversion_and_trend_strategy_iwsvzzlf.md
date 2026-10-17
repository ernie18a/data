# Z-Regime Switch | Adaptive Z-Score Reversion and Trend Strategy

- url: https://www.tradingview.com/script/IWsVZZLF-Z-Regime-Switch-Adaptive-Z-Score-Reversion-and-Trend-Strategy/
- type: strategy
- pine_id: PUB;e35e66fea73247e1b07f280a50ee3a28
- version: 1.0

## Description

Z-Regime Switch (ZRS) is a Z-score strategy that adapts to market conditions. Most Z-score systems either fade every extreme or chase every breakout. ZRS measures the volatility regime first, then picks the playbook that fits it.

[b]How it works[/b]

1. Price Z-Score. Measures how many standard deviations the close sits from its rolling mean.

2. Regime Z-Score. Takes ATR as a percent of price and standardizes it against its own history. This sorts the market into two states:

Calm regime: volatility is at or below its norm, so the strategy looks for mean reversion.
Hot regime: volatility is elevated, so the strategy looks for trend continuation.

3. Z Velocity. A smoothed rate of change of the Price Z-score. It confirms that momentum is turning (reversion) or accelerating (trend) before an entry.

4. Efficiency Ratio filter. Reversion trades are only allowed when the market is choppy (low ER). Trend trades are only allowed when the market is directional (high ER). This separates a violent trend from a violent whipsaw, which volatility alone cannot do.

5. Long-term bias filter. Longs are only taken above a slow EMA and shorts only below it, in both modes.

[b]Entry logic[/b]
[list]
[*]Reversion Long: calm regime, low ER, price above the bias EMA, Z crosses back above the lower extreme band, Z velocity positive.
[*]Reversion Short: the mirror image.
[*]Trend Long: hot regime, high ER, price above the bias EMA, Z breaks above the trend band, Z velocity positive.
[*]Trend Short: the mirror image.
[/list]

The strategy waits for Z to reject the extreme before fading it, rather than catching the knife on the first touch.

[b]Exit logic[/b]

Exits depend on the mode that opened the trade:
[list]
[*]Reversion trades exit when Z returns to the mean zone.
[*]Trend trades exit when Z fades back toward zero.
[*]ATR stop-loss is set at entry on every trade.
[*]Time stop closes any trade that has run too long.
[/list]

[b]Features[/b]
[list]
[*]Two strategies in one, selected automatically by regime
[*]Each mode can be enabled or disabled separately
[*]Long and short toggles
[*]Efficiency ratio and long-term bias filters, each with its own on/off switch
[*]Z-score pane colored by regime, with entry bands and a regime background tint
[*]Data Window readouts for Regime Z, Z velocity, Efficiency Ratio and active mode
[*]Entry and exit labels on trades showing the mode (REV, TREND, MEAN, ZFADE, TIME)
[*]Commission and slippage included in the defaults
[/list]

[b]Tips[/b]
[list]
[*]Test the modes separately first. Disable trend mode and test reversion alone, then swap. Whichever loses in your market can be turned off or tightened.
[*]Match the Z window to your timeframe. The default of 60 bars is a starting point. Shorter windows react faster but produce more noise.
[*]If trades are too rare, loosen the ER thresholds, lower the regime threshold, or widen the Z bands.
[*]If results are poor, try a longer ER window, a tighter ATR stop, or a shorter time stop.
[*]On intraday charts, increase the bias EMA length (500 or more), since 200 bars is very short-term there.
[*]Test across several symbols and timeframes instead of tuning to one chart.
[*]Use realistic costs. Set commission and slippage to match your broker and instrument.
[/list]

[b]Warnings[/b]
[list]
[*]This is not financial advice. It is an educational tool and a research template.
[*]Past performance does not guarantee future results. Backtests are hypothetical and cannot capture real-world execution, liquidity, spreads, or gaps.
[*]Overfitting risk. With many adjustable parameters, it is easy to find settings that look great on history and fail live. Prefer settings that work across a range of values and markets.
[*]Small samples mislead. Results from fewer than about 100 trades are not statistically meaningful.
[*]Z-scores assume a stable distribution. Price returns are fat-tailed and change over time, so extreme Z readings can persist or grow instead of reverting.
[*]Position sizing: the default is 25% of equity per trade. Adjust it to your own risk tolerance, since risk per trade also depends on the ATR stop distance.
[*]Orders fill on the next bar’s open in backtests. Live fills may differ.
[/list]

## Source Code

````pine
//@version=6
strategy("Z-Regime Switch Strategy", shorttitle = "ZRS", overlay = false,
     initial_capital = 100000, default_qty_type = strategy.percent_of_equity, default_qty_value = 100,
     commission_type = strategy.commission.percent, commission_value = 0.05, slippage = 2,
     pyramiding = 0, process_orders_on_close = false, max_bars_back = 1000)

// ============================================================================
//  IDEA
//  Price Z  : how stretched close is versus its rolling mean (in sigmas).
//  Regime Z : how unusual current volatility (ATR % of price) is versus its history.
//  Calm regime -> fade extremes after Z rejects the band (with velocity confirmation).
//  Hot regime  -> trade continuation when Z breaks out of the trend band while accelerating.
//  FILTERS
//    1) Efficiency ratio: reversion only in choppy markets, trend only in directional ones.
//    2) Long-term bias  : longs only above the slow EMA, shorts only below it.
//  Exits are mode-specific, plus an ATR stop and a time stop.
// ============================================================================

// ---------------- Inputs ----------------
string gZ = "Price Z-score"
int   zLen     = input.int(60, "Z window", minval = 10, group = gZ)
int   velLen   = input.int(3, "Z velocity smoothing (bars)", minval = 1, group = gZ)

string gR = "Volatility regime"
int   atrLen   = input.int(14, "ATR length", minval = 2, group = gR)
int   regLen   = input.int(120, "Regime lookback", minval = 30, group = gR)
float hotZ     = input.float(0.5, "Hot regime above (regime Z)", step = 0.1, group = gR)

string gF = "Filters"
bool  useER     = input.bool(true, "Use efficiency ratio filter", group = gF)
int   erLen     = input.int(20, "Efficiency ratio length", minval = 5, group = gF)
float revMaxER  = input.float(0.35, "Reversion only if ER below", minval = 0.05, maxval = 1.0, step = 0.05, group = gF)
float trendMinER = input.float(0.40, "Trend only if ER above", minval = 0.05, maxval = 1.0, step = 0.05, group = gF)
bool  useBias   = input.bool(true, "Use long-term bias filter", group = gF)
int   biasLen   = input.int(200, "Bias EMA length", minval = 20, group = gF)

string gE = "Entries / exits"
float revEntryZ  = input.float(2.0, "Reversion: extreme band", minval = 0.5, step = 0.1, group = gE)
float revExitZ   = input.float(0.25, "Reversion: exit when |Z| within", minval = 0.0, step = 0.05, group = gE)
float trendEntryZ = input.float(1.5, "Trend: breakout band", minval = 0.5, step = 0.1, group = gE)
float trendExitZ  = input.float(0.25, "Trend: exit when Z falls back to", step = 0.05, group = gE)
float stopMult   = input.float(2.5, "ATR stop multiple", minval = 0.5, step = 0.1, group = gE)
int   maxBars    = input.int(30, "Time stop (bars)", minval = 2, group = gE)
bool  allowLong  = input.bool(true, "Allow longs", group = gE)
bool  allowShort = input.bool(true, "Allow shorts", group = gE)
bool  useReversion = input.bool(true, "Enable reversion mode", group = gE)
bool  useTrend     = input.bool(true, "Enable trend mode", group = gE)

// ---------------- Calculations ----------------
float mu = ta.sma(close, zLen)
float sd = ta.stdev(close, zLen)
float z  = sd > 0 ? (close - mu) / sd : na

float atr    = ta.atr(atrLen)
float atrPct = atr / close * 100.0
float rMu    = ta.sma(atrPct, regLen)
float rSd    = ta.stdev(atrPct, regLen)
float regimeZ = rSd > 0 ? (atrPct - rMu) / rSd : na

float zVel = ta.ema(ta.change(z), velLen)

// Filter 1: Kaufman efficiency ratio (0 = pure chop, 1 = straight line)
float pathLen = math.sum(math.abs(ta.change(close)), erLen)
float er      = pathLen > 0 ? math.abs(close - close[erLen]) / pathLen : na

// Filter 2: long-term bias
float biasMA = ta.ema(close, biasLen)
bool  longBiasOK  = not useBias or close > biasMA
bool  shortBiasOK = not useBias or close < biasMA

bool ready = not na(z) and not na(regimeZ) and not na(zVel) and not na(atr) and not na(er) and not na(biasMA)
bool hot   = ready and regimeZ > hotZ
bool calm  = ready and not hot

bool revErOK   = not useER or er <= revMaxER
bool trendErOK = not useER or er >= trendMinER

// Reversion: Z rejects the extreme with turning velocity, in a choppy calm market
bool revLong  = useReversion and calm and revErOK and longBiasOK  and ta.crossover(z, -revEntryZ) and zVel > 0
bool revShort = useReversion and calm and revErOK and shortBiasOK and ta.crossunder(z, revEntryZ) and zVel < 0

// Trend: Z breaks out while accelerating, in a hot and directional market
bool trLong  = useTrend and hot and trendErOK and longBiasOK  and ta.crossover(z, trendEntryZ) and zVel > 0
bool trShort = useTrend and hot and trendErOK and shortBiasOK and ta.crossunder(z, -trendEntryZ) and zVel < 0

// ---------------- State ----------------
var int   posMode  = 0     // 1 = reversion, 2 = trend
var float entryAtr = na
var int   entryBar = na

bool flat = strategy.position_size == 0

if flat and allowLong and (revLong or trLong)
    posMode  := revLong ? 1 : 2
    entryAtr := atr
    entryBar := bar_index
    strategy.entry("L", strategy.long, comment = revLong ? "L-REV" : "L-TREND")
else if flat and allowShort and (revShort or trShort)
    posMode  := revShort ? 1 : 2
    entryAtr := atr
    entryBar := bar_index
    strategy.entry("S", strategy.short, comment = revShort ? "S-REV" : "S-TREND")

// ---------------- Exits ----------------
int barsHeld = na(entryBar) ? 0 : bar_index - entryBar
bool timeUp  = barsHeld >= maxBars

if strategy.position_size > 0
    bool exitSig = posMode == 1 ? z >= -revExitZ : ta.crossunder(z, trendExitZ)
    if exitSig
        strategy.close("L", comment = posMode == 1 ? "L-MEAN" : "L-ZFADE")
    else if timeUp
        strategy.close("L", comment = "L-TIME")
    strategy.exit("L-SL", "L", stop = strategy.position_avg_price - stopMult * entryAtr)

if strategy.position_size < 0
    bool exitSig = posMode == 1 ? z <= revExitZ : ta.crossover(z, -trendExitZ)
    if exitSig
        strategy.close("S", comment = posMode == 1 ? "S-MEAN" : "S-ZFADE")
    else if timeUp
        strategy.close("S", comment = "S-TIME")
    strategy.exit("S-SL", "S", stop = strategy.position_avg_price + stopMult * entryAtr)

// ---------------- Plots ----------------
color calmCol = color.new(#00A6A6, 0)
color hotCol  = color.new(#E06B3C, 0)
plot(ready ? z : na, "Price Z", hot ? hotCol : calmCol, 2)
plot(0.0, "Mean", color.new(color.gray, 60))
plot(revEntryZ, "Reversion upper", color.new(calmCol, 55), 1, plot.style_circles)
plot(-revEntryZ, "Reversion lower", color.new(calmCol, 55), 1, plot.style_circles)
plot(trendEntryZ, "Trend upper", color.new(hotCol, 55), 1, plot.style_cross)
plot(-trendEntryZ, "Trend lower", color.new(hotCol, 55), 1, plot.style_cross)
bgcolor(hot ? color.new(hotCol, 92) : calm ? color.new(calmCol, 95) : na, title = "Regime")

plot(regimeZ, "Regime Z", display = display.data_window)
plot(zVel, "Z velocity", display = display.data_window)
plot(er, "Efficiency ratio", display = display.data_window)
plot(posMode, "Position mode (1 rev, 2 trend)", display = display.data_window)
````
