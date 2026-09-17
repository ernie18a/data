<!-- tradingview-pine-id: PUB;91f07d5ed0eb4a95b8a95c8760455c88 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Stock Breakout Momentum Strategy

Source: https://www.tradingview.com/script/n7sVlEUq-Stock-Breakout-Momentum-Strategy/

## Description

Description

A breakout entry alone isn't a system, it's the first third of one. What happens after the breakout fires is what usually decides whether the equity curve goes up or down: does every close beyond a lookback high get traded, or only the ones with real trend and participation behind them? Does a winning trade get room to develop, or does it get cut off by an exit window built for a losing trade? This strategy answers both questions directly: breakout entries are screened by a trend filter and a volume filter before they're taken, and once in a trade, a fixed ATR profit target works alongside a trailing stop and a materially longer time-based exit — instead of the time exit doing double duty as the only thing standing between a trade and an open-ended hold.

The Breakout Trigger, Now Screened by Trend and Volume

The core signal is unchanged from a classic breakout: a long triggers when a bar closes above the highest high of a lookback window (20 bars by default); a short triggers on a close below the lowest low. The signal only evaluates on barstate.isconfirmed, so it reacts to a bar's final, settled value rather than an intrabar tick, a non-repainting design where the order is submitted on the confirmed signal bar and fills at the next bar's open. What's new is what has to be true alongside that close: an optional trend filter requires price to be above a 50-period SMA for longs (below it for shorts), and an optional volume filter requires the breakout bar's volume to exceed 1.2× its 20-period average. Both are on by default and both can be switched off independently: turning them off reproduces the original unfiltered breakout-only version, which is a useful baseline to compare against.

Why Two Confirmation Filters Instead of One

A breakout on a stock trading below its own trend line, or on below-average volume, is a weaker signal than a breakout with the reverse conditions, a common cause of a low win rate is a system taking every technically-valid breakout regardless of context. The trend filter keeps the strategy from fighting its own directional bias; the volume filter is a basic conviction check against thin, low-participation moves that are more likely to be noise than the start of a real trend.

A Trailing Stop That Only Moves in Your Favor

Once in a position, the stop is recalculated every bar as entry ATR × a multiplier (2.0 by default) behind price, but it only ever ratchets in the trade's favor, a long's stop can rise as price rises but can't be pulled back down on a pullback, and a short's stop mirrors that in reverse.

An Explicit Profit Target, Not Just a Trailing Stop

Earlier versions of this approach relied on the trailing stop as the only way to close a trade in profit, which meant a short exit window could cut a winning trade off before the stop had room to ratchet up. This version adds a fixed ATR profit target (3.0× ATR by default, set once at entry and left in place; it doesn't trail the way the stop does) placed alongside the stop as a bracket order. Paired with the default 2.0× ATR stop, that's a built-in 1.5:1 reward-to-risk skew: the strategy doesn't need a high win rate to be net positive, it needs winners to average meaningfully more than losers, which is what the target is there to enforce. This can be turned off entirely if you'd rather rely on the trailing stop alone.

A Longer Time-Based Exit

Trades that haven't been stopped out or hit target within a set number of bars are closed as a housekeeping measure, a fixed exit window is there to purge trades that have stopped developing rather than to signal a directional call. That window is now 20 bars by default rather than a handful, giving the trailing stop and profit target actual room to do their jobs before the clock forces a decision. Whichever of the three exit conditions: stop, target, or time is met first is what closes the trade.

Position Sizing Tied to Equity, Not a Fixed Share Count

Instead of trading a static number of shares, the strategy calculates how many shares fit within a configurable percentage of current account equity (100% by default) divided by the current share price, floored to a whole share count with a floor of one. Sizing compounds with account equity rather than staying fixed at the starting balance. A dedicated "Allow Short Entries" toggle exists because not every account can short every stock; turn it off to backtest and trade long-only.

A Note on Shorting and Margin

Short positions on equities require margin, and margin requirements for shorting are not the same as the cash-equivalent share count this script computes for sizing; real brokers generally require posting more buying power to hold a short than to hold an equivalent long. Sizing at 100% of equity while shorting is enabled can produce trades a real margin account would reject or forcibly liquidate before the strategy's own exit logic gets to close them on its own terms. If you intend to trade this live with shorting on, size conservatively (well under 100%) and confirm your broker's actual margin requirements rather than relying on this script's sizing as a margin calculation.

Backtest Realism Settings

The strategy ships with commission modeled at 0.05% and 2 ticks of slippage baked into every fill, pyramiding disabled, and no same-bar order fills: defaults chosen so Strategy Tester numbers reflect something closer to live execution rather than an idealized fill.

Timeframes and Instruments

Built for equities, and tested across multiple timeframes and symbols with meaningfully different results depending on the instrument's underlying trend regime during the test window — a stock that trended cleanly produced a very different outcome than one that chopped sideways over the same period, even with identical settings. Because the exit logic is bar-count based, results will also vary by timeframe: retest breakoutLength, trendLength, atrMultiplier, profitTargetATRMult, and barsInTrade together whenever you change timeframe rather than assuming the defaults transfer.

What to Examine in Backtesting

Because of the built-in 1.5:1 reward-to-risk skew, a win rate meaningfully below 50% can still be net profitable: check the Strategy Tester's average win versus average loss alongside the raw win rate rather than judging on hit rate alone. 

Watch trade count relative to your test window: a strategy that only fires a handful of times over several months (which the trend and volume filters will produce, by design) needs a longer test period or a broader set of symbols before a positive or negative result says much about a real edge versus a lucky or unlucky stretch. Also check the Margin Usage tab specifically if shorting is enabled, and compare max drawdown against total return, a strategy that gives back most of an open gain before ending marginally positive is a different risk profile than one that climbs more steadily, even if the final number looks the same.

Shared for educational purposes. This is not investment advice. Backtest results, including any shown in this listing's chart or comments, reflect a specific historical period and instrument and are not a representation of future performance. Trading involves substantial risk of loss and is not suitable for all investors.

---

## Source Code

````pine
//@version=6
strategy("Stock Breakout Momentum Strategy", overlay=true, initial_capital=10000, currency=currency.USD, default_qty_type=strategy.fixed, default_qty_value=1, commission_type=strategy.commission.percent, commission_value=0.05, slippage=2, pyramiding=0, process_orders_on_close=false)

// ===================== INPUTS =====================
int breakoutLength   = input.int(20, "Breakout Lookback (bars)", minval=1)
int barsInTrade      = input.int(20, "Time-Based Exit (bars)", minval=1)
int atrLength        = input.int(14, "ATR Length", minval=1)
float atrMultiplier  = input.float(2.0, "ATR Trailing Stop Multiplier", minval=0.1)
float accountRiskPct = input.float(100.0, "Percent of Equity to Allocate per Trade (%)", minval=1.0, maxval=500.0, tooltip="100% = use the full account for each trade (cash account). Values above 100% assume a margin account.")
bool  allowShort     = input.bool(true, "Allow Short Entries", tooltip="Turn off if your broker/stock doesn't support shorting, to backtest long-only.")

bool  useProfitTarget    = input.bool(true, "Use Profit Target", group="Profit Target")
float profitTargetATRMult = input.float(3.0, "Profit Target ATR Multiplier", group="Profit Target")

bool useTrendFilter      = input.bool(true, "Use Trend Filter", group="Filters")
int  trendLength         = input.int(50, "Trend SMA Length", group="Filters")
bool useVolumeFilter     = input.bool(true, "Use Volume Filter", group="Filters")
int  volLength           = input.int(20, "Volume SMA Length", group="Filters")
float volumeMultiplier   = input.float(1.2, "Volume Multiplier", group="Filters")

// ===================== VARIABLES =====================
var float longSL = na
var float shortSL = na
var float longTP = na
var float shortTP = na
var int entryBarIndex = na
var bool justEntered = false

// ===================== CALCULATIONS =====================
float highestHigh = ta.highest(high, breakoutLength)
float lowestLow = ta.lowest(low, breakoutLength)
float atrValue = ta.atr(atrLength)
float trendSMA = ta.sma(close, trendLength)
float volSMA = ta.sma(volume, volLength)

bool dataReady = not na(highestHigh[1]) and not na(lowestLow[1]) and not na(atrValue) and (not useTrendFilter or not na(trendSMA)) and (not useVolumeFilter or not na(volSMA))

bool trendOKLong = not useTrendFilter or close > trendSMA
bool trendOKShort = not useTrendFilter or close < trendSMA
bool volOK = not useVolumeFilter or volume > volSMA * volumeMultiplier

bool longBreakout = dataReady and barstate.isconfirmed and close > highestHigh[1] and trendOKLong and volOK
bool shortBreakout = allowShort and dataReady and barstate.isconfirmed and close < lowestLow[1] and trendOKShort and volOK

// ===================== SHARE SIZING =====================
float availableEquity = strategy.equity * (accountRiskPct / 100.0)
int sharesToTrade = close > 0 ? math.max(1, math.floor(availableEquity / close)) : 1

// ===================== ENTRY =====================
if longBreakout and strategy.position_size == 0
    justEntered := true
    entryBarIndex := bar_index
    longSL := open - atrValue * atrMultiplier
    longTP := useProfitTarget ? open + atrValue * profitTargetATRMult : na
    strategy.entry("Long", strategy.long, qty=sharesToTrade)

if shortBreakout and strategy.position_size == 0
    justEntered := true
    entryBarIndex := bar_index
    shortSL := open + atrValue * atrMultiplier
    shortTP := useProfitTarget ? open - atrValue * profitTargetATRMult : na
    strategy.entry("Short", strategy.short, qty=sharesToTrade)

// ===================== TRAILING STOP UPDATE =====================
if strategy.position_size > 0
    longSL := math.max(nz(longSL, open), close - atrValue * atrMultiplier)
if strategy.position_size < 0
    shortSL := math.min(nz(shortSL, open), close + atrValue * atrMultiplier)

// ===================== EXIT LOGIC =====================
bool timeExitLong = strategy.position_size > 0 and not na(entryBarIndex) and (bar_index - entryBarIndex) >= barsInTrade
bool timeExitShort = strategy.position_size < 0 and not na(entryBarIndex) and (bar_index - entryBarIndex) >= barsInTrade

if strategy.position_size > 0
    if timeExitLong
        strategy.close("Long", comment="Time Exit")
    else
        strategy.exit("Trail Exit Long", "Long", stop=longSL, limit=longTP)
if strategy.position_size < 0
    if timeExitShort
        strategy.close("Short", comment="Time Exit")
    else
        strategy.exit("Trail Exit Short", "Short", stop=shortSL, limit=shortTP)

// ===================== RESET BLOCK =====================
if strategy.position_size == 0 and not justEntered
    longSL := na
    shortSL := na
    longTP := na
    shortTP := na
    entryBarIndex := na

// ===================== CLEAR LATCH =====================
justEntered := false

// ===================== PLOTS =====================
plot(highestHigh, "20-Bar Highest High", color=color.green, linewidth=1)
plot(lowestLow, "20-Bar Lowest Low", color=color.red, linewidth=1)
plot(strategy.position_size > 0 ? longSL : na, "Long Trailing Stop", color=color.aqua, style=plot.style_linebr, linewidth=2)
plot(strategy.position_size < 0 ? shortSL : na, "Short Trailing Stop", color=color.orange, style=plot.style_linebr, linewidth=2)
plot(trendSMA, "Trend SMA", color=color.yellow, linewidth=1)
plot(strategy.position_size > 0 ? longTP : na, "Long Profit Target", color=color.blue, style=plot.style_linebr, linewidth=2)
plot(strategy.position_size < 0 ? shortTP : na, "Short Profit Target", color=color.blue, style=plot.style_linebr, linewidth=2)
````
