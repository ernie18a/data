<!-- tradingview-pine-id: PUB;8f3f00e9500c4cdc99c8f07a67bb22d5 -->
<!-- tradingviewscripts-format: 1 -->
# TRADLEWARE-DCA

Source: https://www.tradingview.com/script/OmrCq7H3-TRADLEWARE-DCA/

## Description

[image]https://www.tradingview.com/x/UHnYQUQM/[/image]

Dollar-Cost Averaging Benchmark

This is a passive reference strategy, not a signal-based trading system. It exists to give an honest, apples-to-apples comparison for active strategies: instead of trying to time entries, it buys a fixed amount of the asset on a regular schedule until a set capital budget is fully deployed.

How it works

Dollar-cost averaging (DCA) means investing a fixed amount of money at regular intervals, regardless of price. Some buys land at high prices, some at low prices, and over time the average purchase price smooths out. There is no attempt to predict direction — the schedule is the whole strategy.

This script buys on either a fixed day of the week (e.g. every Monday) or every fixed number of bars (e.g. every 30 daily bars, roughly monthly), and keeps buying until the total amount invested reaches the strategy's starting capital. After that, no more buys are placed — the same total capital pool as whatever active strategy this is being compared against, with no extra money added along the way.

Entry

A buy is placed each time the schedule fires, as long as the running total invested plus the next buy amount does not exceed the starting capital. If a scheduled buy would push the total over budget, it is skipped, but the schedule keeps advancing rather than getting stuck retrying.

Exit

There is no exit signal in the usual sense — the strategy only ever adds to its position. The full position is closed out once, on the final bar of the chart's history, purely so the backtest can report a final equity figure. This is bookkeeping, not a trading decision.

Parameters

[*] Start Date / End Date: window during which buys are allowed
[*] Use Day of Week Mode: switch between "buy on a specific weekday" and "buy every N bars"
[*] Day of Week: which weekday to buy on, when day-of-week mode is on
[*] Every X Bars: how many bars between buys, when day-of-week mode is off (30 on a daily chart is roughly monthly)
[*] Amount per buy: fixed amount invested at each scheduled buy

The strategy allows up to 500 stacked buy layers to accumulate into a single overall position — that number just needs to be large enough to never run out before the capital budget is spent; it is not a trading parameter to tune.

Costs modelled

0.1% commission per side, 3 ticks slippage, fills at the same bar's close (this benchmark intentionally fills immediately rather than waiting for the next bar's open, since there is no signal timing to protect).

Intended assets and timeframe

Works on any asset or timeframe — the frequency inputs just need to be set to match (e.g. 30 bars on a daily chart for roughly monthly buys, 7 for weekly). For higher-priced assets, check that the per-buy amount converts to at least a fraction TradingView will actually simulate.

Known limitations

The starting capital, buy amount, and buy frequency together decide how long full deployment actually takes — and depending on the chart's date range, that can run out in either direction. With the default settings (10,000 starting capital, 100 per buy, roughly monthly), full deployment takes 100 buys — about 8 years of monthly investing. Starting from 2018-01-01, that budget is exhausted by roughly mid-2026, so on a chart that runs through mid-2026 or later, this script will have already placed its last scheduled buy weeks or months before the present: it simply holds the fully-invested position afterward and stops buying, exactly as designed by the "never invest more than the starting capital" rule, not because of an error. On a shorter chart window relative to the amount and frequency chosen, the opposite can happen instead — the window ends before the full budget is spent, leaving some capital undeployed. Either way, check the strategy's equity and invested-capital tracking rather than assuming full deployment by the end of the chart. This script also has no risk management of any kind by design: it never sells until the very end, so it carries full exposure to any drawdown the asset experiences. That is the intended comparison point for an active strategy, not a flaw to fix.

---

## Source Code

````pine
//@version=6
// Author: cs_lev
// Strategy: TRADLEWARE-DCA
// Hypothesis: baseline reference — deploy a fixed tranche of the initial capital
//             at a regular interval; never add external money beyond initial_capital.
// Assumed regime: regime-agnostic (passive)
// Timeframe: any (adjust frequency inputs to match your bar size)
// Assets: any
// Known failure modes: full deployment in the first N weeks; no active risk management.
//
// Fair-comparison notes:
//   initial_capital here should match the strategy you are benchmarking against.
//   The script stops buying once the total invested reaches initial_capital,
//   so no external capital is ever added — the same total pool as the active strategy.
// Adjust DCA quantity for pricier ETFs like QQQ,VOO, as Tradingview might not show trades that would be fractional (<1)

strategy("TRADLEWARE-DCA", overlay=true,
     initial_capital=10000,
     commission_type=strategy.commission.percent,
     commission_value=0.1,
     slippage=3,
     pyramiding=500,
     calc_on_every_tick=false,
     process_orders_on_close=true,
     fill_orders_on_standard_ohlc=true)

// === Inputs ===
// Date range — integer year/month/day fields instead of input.time(), which does
// not reliably trigger a recalculation in TradingView.
startYear  = input.int(2018, "Start year",  minval=2000, maxval=2099, group="Date Range")
startMonth = input.int(1,    "Start month", minval=1,    maxval=12,   group="Date Range")
startDay   = input.int(1,    "Start day",   minval=1,    maxval=31,   group="Date Range")
endYear    = input.int(2099, "End year",    minval=2000, maxval=2099, group="Date Range")
endMonth   = input.int(12,   "End month",   minval=1,    maxval=12,   group="Date Range")
endDay     = input.int(31,   "End day",     minval=1,    maxval=31,   group="Date Range")
startDate  = timestamp(startYear, startMonth, startDay, 0, 0)
endDate    = timestamp(endYear, endMonth, endDay, 23, 59)

basedOnDayOfWeek = input.bool(title="Use Day of Week Mode", defval=false, group="Frequency",
     tooltip="Buy on a fixed day of the week (e.g. every Monday). Uncheck to buy every X bars instead.")
buyOnDayOfWeek = input.int(title="Day of Week", defval=2, minval=1, maxval=7,
     tooltip="1=Sunday, 2=Monday … 7=Saturday. Only active when 'Use Day of Week Mode' is checked.", group="Frequency")
basedOnXBars = input.int(title="Every X Bars", defval=30, minval=1,
     tooltip="Buy every X bars. Default 30 ≈ monthly on a daily chart. Use 7 for weekly, 1 for daily. Tip: set Amount per buy so that (bars in period / Every X Bars) × amount ≈ initial capital for full deployment.", group="Frequency")

toInvestQuote = input.float(title="Amount per buy (quote currency)", defval=100.0, minval=1.0,
     tooltip="Fixed dollar amount to invest on each buy event. Buying stops automatically once the total invested equals the strategy's initial capital.", group="Strategy")

// === State ===
var float investedCapital = 0.0
var int   lastBuyBarIndex = 0

toInvestBase = toInvestQuote / close  // units to buy at current price

// Exclude the last confirmed bar so DCA and close_all never fire on the same bar.
timeCondition = time >= startDate and time <= endDate and not barstate.islastconfirmedhistory

// Frequency condition
// Use >= not == so a missed cycle (capital cap, reload) doesn't permanently break the schedule.
bool freqCondition = false
if basedOnDayOfWeek
    freqCondition := dayofweek(time) == buyOnDayOfWeek
else
    freqCondition := (lastBuyBarIndex == 0) or (bar_index >= lastBuyBarIndex + basedOnXBars)

longCondition = freqCondition and timeCondition

// === Orders ===
// Always advance lastBuyBarIndex when the frequency fires, even if the capital cap blocks the buy.
// This prevents the == → permanent-miss bug when capital runs out mid-schedule.
// strategy.entry (not strategy.order) is required so TV's strategy tester tracks the trades
// and generates a report. pyramiding=500 lets all DCA layers stack into the same "dca" position.
if longCondition
    lastBuyBarIndex := bar_index
    if investedCapital + toInvestQuote <= strategy.initial_capital
        strategy.entry(id="dca", direction=strategy.long, qty=toInvestBase)
        investedCapital += toInvestQuote

// Close the entire accumulated position on the last confirmed (fully closed) bar.
// islastconfirmedhistory = yesterday's bar. With process_orders_on_close=false (default),
// the fill happens at today's open — so a sell arrow appears in chart history immediately.
// islast (the forming bar) won't show a sell until today's market close, which is why it looked missing.
if barstate.islastconfirmedhistory or time > endDate
    strategy.close_all()

// === Equity line ===
plot(strategy.equity, title="Equity", display=display.data_window, color=color.teal)
````
