# Simple RSI Strategy - Rule Based Higher Timeframe Trading

- url: https://www.tradingview.com/script/kxT5f5rq-Simple-RSI-Strategy-Rule-Based-Higher-Timeframe-Trading/
- type: strategy
- pine_id: PUB;9827801238794f24b6dee536d7700d38
- version: 3.0

## Description

[image]https://www.tradingview.com/x/JhAFl2Ok/[/image]

[b]HOW IT WORKS[/b]
With the default settings, the strategy [b]buys when RSI reaches 30[/b] and [b]closes when RSI reaches 40[/b].

That’s it.

A [b]simple, rule-based mean reversion strategy[/b] designed for [b]higher timeframes[/b], where market noise is lower and trading becomes easier to manage.

[b]Core logic:[/b]
[list]
[*]Long when RSI moves into oversold territory
[*]Exit when RSI mean-reverts upward
[*]Optional short trades from overbought levels
[*]One position at a time (no pyramiding)
[/list]

No filters.  
No discretion.  
Just clear, testable rules.

[image]https://www.tradingview.com/x/1ZEN9vcv/[/image]

[b]MARKETS & TIMEFRAMES[/b]
This strategy is intended for:
[list]
[*]Indices (Nasdaq, S&P 500, DAX, etc.)
[*]Liquid futures and CFDs
[*]Higher timeframes: [b]2H, 4H and Daily[/b]
[/list]

The published example is [b]Nasdaq (NDX) on the 2-hour timeframe[/b].  
Higher timeframes are strongly recommended.

[b]HOW TO USE IT[/b]
[list]
[*]Apply the strategy on a higher timeframe
[*]Adjust RSI levels per market if needed
[*]Use TradingView alerts to avoid constant screen-watching
[*]Focus on execution, risk control, and consistency
[/list]

This strategy is meant to be a [b]building block[/b], not a complete trading business on its own.  
For long-term consistency, it works best when combined with other uncorrelated, rule-based systems.

[b]IMPORTANT[/b]
[list]
[*]This is not financial advice
[*]All results are historical and not indicative of future performance
[*]Always forward-test and apply proper risk management
[/list]

For additional notes, setups and related systems, visit my [url=https://www.tradingview.com/u/EdgeLab/]TradingView profile page[/url].

## Source Code

````pine
//@version=6
strategy(
     "Simple RSI [EdgeLab]",
     overlay = true,
     initial_capital = 100000,
     default_qty_type = strategy.percent_of_equity,
     default_qty_value = 100,
     pyramiding = 0,
     process_orders_on_close = true,
     margin_long = 0,
     margin_short = 0)

//────────────────────
// General inputs
//────────────────────
dir = input.string(
     "Long",
     "Trade Direction",
     options = ["Long", "Short", "Both"],
     group = "General")

len = input.int(14, "RSI Length", minval = 1, group = "General")
src = input.source(close, "RSI Source", group = "General")

//────────────────────
// Long levels
//────────────────────
entryL = input.int(30, "Long: Enter when RSI ≤", minval = 1, maxval = 99, group = "Long")
exitL  = input.int(40, "Long: Exit when RSI ≥",  minval = 2, maxval = 100, group = "Long")

//────────────────────
// Short levels
//────────────────────
entryS = input.int(70, "Short: Enter when RSI ≥", minval = 1, maxval = 99, group = "Short")
exitS  = input.int(60, "Short: Exit when RSI ≤",  minval = 1, maxval = 99, group = "Short")

//────────────────────
// Risk management
//────────────────────
use_sl = input.bool(false, "Enable Stop Loss", group = "Risk")
use_tp = input.bool(false, "Enable Take Profit", group = "Risk")

override_rsi_exit = input.bool(
    false,
    "Disable RSI exits when TP enabled",
    tooltip = "If enabled, RSI-based exits are ignored when Take Profit is active.",
    group = "Risk")

atr_len     = input.int(14, "ATR Length", group = "Risk")
sl_atr_mult = input.float(2.0, "Stop Loss (ATR ×)", step = 0.1, group = "Risk")
tp_atr_mult = input.float(2.0, "Take Profit (ATR ×)", step = 0.1, group = "Risk")

atr = ta.atr(atr_len)

//────────────────────
// Direction flags
//────────────────────
allowLong  = dir == "Long" or dir == "Both"
allowShort = dir == "Short" or dir == "Both"

//────────────────────
// RSI
//────────────────────
r = ta.rsi(src, len)

//────────────────────
// Entry conditions
//────────────────────
enterLong  = allowLong  and ta.crossunder(r, entryL) and strategy.position_size == 0
enterShort = allowShort and ta.crossover(r, entryS)  and strategy.position_size == 0

//────────────────────
// Exit conditions (RSI)
//────────────────────
rsiExitAllowed = not (use_tp and override_rsi_exit)

exitLong  = rsiExitAllowed and allowLong  and ta.crossover(r, exitL)  and strategy.position_size > 0
exitShort = rsiExitAllowed and allowShort and ta.crossunder(r, exitS) and strategy.position_size < 0

//────────────────────
// Orders
//────────────────────
if enterLong
    strategy.entry("Long", strategy.long)
    stopPrice  = use_sl ? close - atr * sl_atr_mult : na
    limitPrice = use_tp ? close + atr * tp_atr_mult : na
    if use_sl or use_tp
        strategy.exit(
            "Long SL/TP",
            from_entry = "Long",
            stop  = stopPrice,
            limit = limitPrice)

if exitLong
    strategy.close("Long")

if enterShort
    strategy.entry("Short", strategy.short)
    stopPrice  = use_sl ? close + atr * sl_atr_mult : na
    limitPrice = use_tp ? close - atr * tp_atr_mult : na
    if use_sl or use_tp
        strategy.exit(
            "Short SL/TP",
            from_entry = "Short",
            stop  = stopPrice,
            limit = limitPrice)

if exitShort
    strategy.close("Short")

//────────────────────
// Alerts
//────────────────────
alertcondition(enterLong,  "Enter Long",  "RSI crossed into long entry zone")
alertcondition(exitLong,   "Exit Long",   "RSI crossed into long exit zone")
alertcondition(enterShort, "Enter Short", "RSI crossed into short entry zone")
alertcondition(exitShort,  "Exit Short",  "RSI crossed into short exit zone")
````
