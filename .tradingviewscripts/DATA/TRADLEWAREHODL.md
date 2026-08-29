<!-- tradingview-pine-id: PUB;ae015ec01b2047a3a73411ed5fe22aa0 -->
<!-- tradingviewscripts-format: 1 -->
# TRADLEWARE-HODL

Source: https://www.tradingview.com/script/wgsvzsT3-TRADLEWARE-HODL/

## Description

[image]https://www.tradingview.com/x/19tASr7p/[/image]
Buy and Hold Benchmark

This is a passive reference strategy, not a signal-based trading system. It exists to give an honest baseline: buy once, hold through everything, and see what an active strategy actually needs to beat.

How it works

Buy-and-hold ("HODL") is the simplest possible approach to markets: put the money in once and do nothing else, regardless of what price does afterward. There is no attempt to time entries or exits, no reaction to drawdowns, and no risk management of any kind. Any active strategy that cannot beat this, risk-adjusted, over the same period has not demonstrated an edge.

Entry

The entire starting capital is deployed in a single buy, on the first bar at or after the start date.

Exit

The position is held until the end date, or the end of the chart's available history, whichever comes first — at which point it is closed once so the backtest can report a final equity figure. This is bookkeeping, not a trading decision; the whole point of the strategy is that it does not exit early.

Parameters

[*] Start Date / End Date: the single buy fires on the first bar at or after the start date; the position is held until the end date

Position sizing is set to 99.95% of equity rather than a full 100%. That small gap avoids a TradingView position-sizing rounding artifact that can otherwise show up as an extra "Margin call" row even on a strategy with only one real trade; the effect on the actual result is negligible.

Costs modelled

0.1% commission per side, 3 ticks slippage.

Intended assets and timeframe

Works on any asset or timeframe — there is no technical logic to adapt, just a buy date and a hold period.

Known limitations

Full exposure to every drawdown the asset experiences, for the entire holding period, by design. This is not a flaw to fix — it is the deliberate point of comparison for any strategy that claims to manage risk better than doing nothing.

---

## Source Code

````pine
//@version=6
// Author: cs_lev
// Strategy: TRADLEWARE-HODL
// Hypothesis: baseline reference — buy once at the start date and hold forever.
// Assumed regime: regime-agnostic (passive)
// Timeframe: any
// Assets: any
// Known failure modes: full drawdown exposure at all times; psychologically hard to hold through bear markets.

strategy("TRADLEWARE-HODL", overlay=true,
     initial_capital=10000,
     default_qty_type=strategy.percent_of_equity,
     default_qty_value=99.95,      // not 100 — avoids a TradingView margin-call rounding
                                    // artifact on the single buy; negligible sizing impact.
                                    // See pinescript-conventions.md's "Margin-call
                                    // micro-trades" section.
     commission_type=strategy.commission.percent,
     commission_value=0.1,
     slippage=3,
     pyramiding=0,
     calc_on_every_tick=false,
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

// === Orders ===
// Buy 100% of capital on the first bar at or after startDate, then hold.
if time >= startDate and strategy.closedtrades == 0 and strategy.position_size == 0
    strategy.entry("hodl", strategy.long)

if time >= endDate or bar_index >= last_bar_index - 1
    strategy.close_all()

// === Equity line ===
plot(strategy.equity, title="Equity", display=display.data_window, color=color.teal)
````
