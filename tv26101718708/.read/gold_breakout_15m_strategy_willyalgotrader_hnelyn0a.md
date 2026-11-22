# Gold Breakout 15M Strategy [WillyAlgoTrader]

- url: https://www.tradingview.com/script/HnelYN0A-Gold-Breakout-15M-Strategy-WillyAlgoTrader/
- type: strategy
- pine_id: PUB;42b9e30300f840c7af2787b46c8617cd
- version: 1.0

## Description

[b]🥇 Gold Breakout 15M Strategy[/b] is an overlay strategy for gold that builds the overnight price range, places stop orders on both of its boundaries, sizes the position from the distance to the stop, and closes everything at a fixed hour — with every order carrying a fully editable alert message, so the same logic can be executed by any trading bot that accepts webhooks or text alerts.

The core insight: gold spends the quiet overnight hours inside a range, and the first move out of that range during the active session often sets the direction for the day. The strategy does not try to predict that direction. It waits on both sides, takes whichever side breaks first, risks a fixed share of equity on it, and is flat again by the evening.

It is built for gold on the 15-minute chart. The script runs on any symbol and timeframe, but the default hours, stop and exit were chosen for gold.

[b]🧩 WHY THESE COMPONENTS WORK TOGETHER[/b]

A range breakout rule on its own is one line of logic. What makes it tradable — and what usually goes wrong when it is automated — is everything around it: whose clock defines the range, how large the position is, what happens when both sides are touched, and what exactly the bot receives.

This strategy connects those parts into one chain:

[b]Broker clock → Daily range → Dual stop entries (one cancels the other) → Stop-loss from entry → Risk-based size with leverage cap → Time exit → Order-level alert templates → On-chart math[/b]

The broker clock decides which candles belong to the range, so the range on the chart matches the range on your broker's chart. The range defines both entry levels. The stop distance defines the position size, so every trade risks the same share of equity whether the stop is wide or tight. The leverage cap and quantity step keep that size inside what an account can actually open. Each order then carries its own message with the real levels and size, so a bot receives the same numbers the tester used. The dashboard recomputes the plan and the statistics from those same values.

Without the broker clock, the range is built from the wrong hours. Without risk-based sizing, a narrow range produces an oversized position. Without the one-cancels-other link, a single volatile candle can open both sides. Without order-level messages, the bot and the backtest drift apart.

[b]🔍 WHAT MAKES IT ORIGINAL[/b]

1️⃣ [b]Broker-time range engine — the range follows your broker's server clock.[/b]

All session hours are defined in broker time, not exchange time. Two modes are available:

 — Fixed timezone (default GMT+3): any timezone string, used all year round.
 — New York + 7h: New York local time plus 7 hours. This is the clock most FX/CFD brokers use — GMT+2 in winter, GMT+3 in summer, switching on the US daylight-saving calendar.

Range High = highest high and Range Low = lowest low of all bars whose opening hour is at or after Range Start Hour (default 0) and before Range End Hour (default 7). The range resets every broker day. The first day of loaded history is skipped, because its range may be incomplete.

Why this matters: a one-hour error in the clock moves the range by four 15-minute candles and changes the entry levels.

2️⃣ [b]Dual stop entries with one-cancels-other.[/b]

From the first bar of the trading window, two stop orders are placed:

 — Buy stop at Range High
 — Sell stop at Range Low

Both belong to one OCA group: the first fill cancels the other immediately. Each entry has its stop-loss attached from the moment it is placed. Only one trade per day is taken, including the case when entry and exit happen inside the same candle. New entries are allowed only while the next bar opens before Close Hour.

3️⃣ [b]Two stop-loss modes, with the percent stop re-anchored to the real fill.[/b]

 — % of entry (default 1.0%): long stop = entry × (1 − SL% / 100), short stop = entry × (1 + SL% / 100). The stop is first placed from the breakout level; at the close of the entry candle it is re-set once from the actual fill price and then stays fixed.
 — Range boundary: the stop is the opposite side of the range.

There is no take-profit. A trade ends at the stop-loss or at Close Hour (default 20:00 broker time), whichever comes first.

4️⃣ [b]Risk-based position sizing with a leverage cap and step rounding.[/b]

The size is calculated before the orders are placed:

risk budget = equity × Risk% / 100
qty by risk = risk budget / (|entry − stop| × point value)
qty by leverage = equity × Max Leverage / (entry × point value)
qty = floor(min(qty by risk, qty by leverage) / step) × step

Defaults: Risk 1.0%, Max Leverage 10, step = the minimum contract size of the symbol. Rounding is always down, so rounding never increases the planned risk. If the result is smaller than one step, that side is skipped and the dashboard says why. When the account currency differs from the symbol currency, equity is converted before the calculation.

With the default 1% risk and 1% stop the position is roughly equal to equity (leverage about ×1). The cap matters in Range boundary mode, where a narrow range would otherwise produce a very large position.

5️⃣ [b]Equity guard — optional daily drawdown stop.[/b]

When enabled, the strategy tracks the equity peak of the current broker day. On every candle it estimates the worst point:

worst equity = equity at close − adverse move × position size × point value
day drawdown = (day peak before this candle − worst equity) / day peak × 100

where the adverse move is close − low for a long and high − close for a short. If the drawdown reaches the limit (default 4.0%), pending orders are cancelled, the position is closed and trading stops until the next day. The guard reacts at candle close; it is an estimate, not a tick-level stop.

6️⃣ [b]Alert template engine — one strategy, any bot.[/b]

Every order carries its own alert message, sent at the moment the order is filled. The message is built from a template that you edit in the settings. There are eight templates: Long Entry, Short Entry, Long Exit and Short Exit, each in a JSON version and a plain-text version. One switch selects which set is sent.

Templates accept placeholders that the strategy fills with real values:

 — Instrument: {{ticker}}, {{tickerid}}, {{exchange}}, {{interval}}
 — Event: {{event}} (entry / exit), {{side}} (long / short), {{action}} (buy / sell), {{reason}} (breakout / sl / time / equity_guard)
 — Levels: {{price}}, {{entry}}, {{sl}}, {{sl_pct}}, {{range_high}}, {{range_low}}
 — Size and risk: {{qty}}, {{oz}}, {{lots}}, {{risk_usd}}, {{risk_pct}}, {{equity}}
 — Integration: {{trade_id}} (the same in the entry and exit message of one trade), {{secret}} (your bot password)

Because the whole message is yours, you can paste the exact JSON your bot expects and put placeholders where the values go. A preview option writes all four messages to Pine Logs with the secret masked, so a template can be checked without waiting for a signal.

7️⃣ [b]Position plan and strategy math on the chart.[/b]

The dashboard shows the plan for the next trade — stop price, stop distance, risk amount, size in ounces and lots, notional and leverage — for both sides at once. A second block computes statistics from closed trades:

 — Win rate = wins / trades
 — Payoff = average win / average loss
 — Breakeven win rate = 100 / (1 + payoff)
 — Profit factor = gross profit / gross loss
 — Expectancy = (gross profit − gross loss) / trades, also in R
 — R of a trade = result / (|entry − stop| × size × point value)

8️⃣ [b]Performance chart drawn on screen.[/b]

An optional panel shows the cumulative PnL curve of closed trades with four key stats: total PnL, maximum drawdown, profitable trades and profit factor. The X axis is the trade number, and each column spans the lowest and highest value of the trades it covers, so a drawdown between two columns stays visible. The panel is fixed to a screen corner and does not move when you scroll.

[b]⚙️ HOW IT WORKS — CALCULATION FLOW[/b]

[b]Step 1 — Broker time:[/b] The bar time is converted to the broker clock. The broker day and hour are derived from it.

[b]Step 2 — Range:[/b] While the bar hour is inside the range window, Range High and Range Low are updated. A new broker day resets them.

[b]Step 3 — Position state:[/b] The script checks whether a position was opened or closed on this bar, counts the trade for the day and, in % mode, re-sets the stop from the fill price.

[b]Step 4 — Statistics:[/b] Trades closed on this bar are added to the statistics and to the PnL curve. The drawdown estimate is updated.

[b]Step 5 — Stop and size:[/b] The planned stop is calculated for both sides, then the quantity by risk, the leverage cap and the step rounding.

[b]Step 6 — Guard:[/b] If the equity guard is enabled and the daily drawdown limit is reached, everything is cancelled and closed.

[b]Step 7 — Orders:[/b] If the range is complete, the next bar opens inside the trading window, there is no position and no trade was taken today, both stop entries are placed with their stops and alert messages. Otherwise pending entries are cancelled.

[b]Step 8 — Exit:[/b] For an open position the stop is maintained. If the next bar opens at or after Close Hour, the position is closed.

[b]Step 9 — Drawing:[/b] Range box, boundaries, entry and exit labels, trade boxes, dashboard and performance chart are updated.

[b]📖 HOW TO USE[/b]

🎯 [b]Quick start:[/b]
 1. Open a gold chart on the 15-minute timeframe with regular candles.
 2. Add the strategy and open its settings.
 3. Set Broker Time Mode and Broker Timezone to your broker's server time.
 4. Check Risk per Trade and Max Leverage against your own account rules.
 5. Open the Strategy Tester and review the trade list before going any further.

👁️ [b]Reading the chart:[/b]
 — 🟦 Blue box = the range while it is being built
 — 🟦 Blue lines with Range High / Range Low labels = the entry levels for today
 — 🟢 Green label below a candle = long entry: entry price, stop, size, risk
 — 🔴 Red label above a candle = short entry
 — 🟢 Green / 🔴 red label at the exit = trade result in money and in R, price move, exit price and reason
 — Green / red box = the trade from entry to exit
 — Blue and red lines with a shaded zone = entry price and stop-loss of the open position
 — 🟡 Yellow note on the last bar = a warning about settings or range accuracy

📊 [b]Dashboard fields:[/b]
 — Trend: price above, below or inside the range
 — Signal: building range, wait breakout, long, short, done for today, halted
 — Timeframe / Session: chart timeframe, broker clock and trading hours
 — Range / Range width: today's levels and their distance
 — Open P&L: result of the open position in money and in R
 — Day drawdown (est.): the value the equity guard watches
 — Position Plan: stop, stop distance, risk amount, size, lots, notional, leverage and size limits for long and short
 — Strategy Math: trades, win rate, breakeven win rate, profit factor, average win and loss, payoff, expectancy, net profit, maximum drawdown, losing streak, last trade

🔧 [b]Tuning guide:[/b]
 — [b]The range does not match your broker's chart:[/b] change Broker Time Mode or Broker Timezone
 — [b]Dashboard shows "Below min step":[/b] the calculated size is smaller than one contract — raise the risk, the capital, or use a smaller contract
 — [b]Dashboard shows "Capped by max leverage":[/b] the range is very narrow; the size was reduced and the real risk is below the target
 — [b]Too many stop-outs:[/b] widen SL % or switch SL Mode
 — [b]Yellow accuracy note:[/b] use a timeframe that divides an hour evenly and regular candles

[b]🤖 TRADE IT WITH ANY BOT[/b]

The strategy does not depend on a specific bot, exchange or broker. Anything that can receive a TradingView alert can execute it.

 1. Create an alert on the strategy.
 2. In the alert's Message field leave only {{strategy.order.alert_message}}.
 3. Add your bot's webhook address in the alert's notification settings.
 4. In the strategy settings turn on Webhook JSON Format and paste your bot's JSON into the four JSON templates, replacing fixed values with placeholders.
 5. Turn on Preview Messages in Pine Logs and check the result before the first live signal.

Notes for bot builders:
 — Messages are sent when an order is filled, not at bar close.
 — {{price}} is the order level (or the bar close for time and guard exits), not the fill price of your broker.
 — In % mode the stop is re-set from the fill and no separate message is sent for that. A bot that places its own stop should calculate it as {{sl_pct}} from its own fill price.
 — {{trade_id}} is identical in the entry and exit message of a trade and can be used to ignore duplicates.
 — TradingView's own placeholders are not processed inside the templates; add them in the alert's Message field if you need them.
 — Always run a new template on a demo account first.

[b]📈 BACKTEST — REPRODUCE IT YOURSELF[/b]

You do not have to take any numbers on trust. Run the test with the default settings and compare:

 — Symbol: gold spot (XAUUSD) on the OANDA feed
 — Timeframe: 15 minutes
 — Period: January 1, 2011 — October 12, 2026 (Deep Backtesting)
 — Initial capital: 10,000 USD
 — Risk per trade: 1% of equity, stop 1% of entry
 — Commission: 0.4 per order, slippage: 0
 — Broker Timezone: GMT+3, range 00:00–07:00, close at 20:00

In the author's run this produced a net result of approximately +800% over the period, on roughly 4,000 trades, with a profit factor of about 1.27 and a maximum drawdown of about 14%.

How to read this number:
 — The position size is a share of current equity, so the result is compounded over almost 16 years.
 — The test uses a fixed commission per order and no slippage. Spread is not modeled by the tester. Real trading costs are higher, especially as the position grows, and the real result will be lower.
 — Results depend on the data feed, the broker clock and the tester settings. A different feed or timezone gives different trades.
 — Past performance does not guarantee future results.

[b]⚙️ KEY SETTINGS REFERENCE[/b]

⚙️ [b]Main Settings:[/b]
 — [b]Broker Time Mode[/b] (default Fixed timezone): Fixed timezone or New York + 7h
 — [b]Broker Timezone[/b] (default GMT+3): used in Fixed mode
 — [b]Range Start Hour[/b] (default 0): start of the range
 — [b]Range End / Trading Start Hour[/b] (default 7): the range is fixed, entries begin
 — [b]Close All Positions Hour[/b] (default 20): forced exit

🛡️ [b]Risk Management:[/b]
 — [b]SL Mode[/b] (default % of entry): % of entry or Range boundary
 — [b]SL, % of Entry Price[/b] (default 1.0)
 — [b]Position Size Mode[/b] (default % equity at risk): or Fixed quantity
 — [b]Risk per Trade, % of Equity[/b] (default 1.0)
 — [b]Fixed Quantity[/b] (default 1)
 — [b]Ounces per Lot[/b] (default 0 = auto): only for showing size in lots
 — [b]Max Leverage[/b] (default 10): cap for position notional
 — [b]Quantity Step[/b] (default 0 = auto): rounding step for the size
 — [b]Prop Firm Guard[/b] (default off) and [b]Max Drawdown from Daily Equity Peak[/b] (default 4.0%)
 — [b]Show Entry / SL Levels[/b] (default on)

🎨 [b]Visual Settings:[/b]
 — [b]Theme[/b] (default Auto): Auto, Dark, Light
 — [b]Show Range Box & Boundaries[/b], [b]Show Entry Labels[/b], [b]Show Exit Labels[/b], [b]Show Trade Box[/b] (all on)
 — [b]Label Size[/b] (default Small)
 — [b]Show Accuracy Warnings[/b], [b]Show Watermark[/b] (on)

📊 [b]Dashboard:[/b]
 — [b]Show Dashboard[/b], [b]Show Strategy Math[/b] (on)
 — [b]Dashboard Position[/b] (default Top Right), [b]Dashboard Text Size[/b] (default Small)

📈 [b]Performance Chart:[/b]
 — [b]Show Performance Chart[/b] (default off)
 — [b]Chart Position[/b] (default Bottom Left)
 — [b]Chart Columns[/b] (default 80), [b]Chart Rows[/b] (default 30)
 — [b]Chart Width[/b] (default 50% of screen), [b]Chart Height[/b] (default 35%)

🔔 [b]Alerts:[/b]
 — [b]Enable Alert Messages[/b] (default on)
 — [b]Webhook JSON Format[/b] (default off = text templates)
 — [b]Bot Secret[/b]: replaces {{secret}}
 — [b]JSON templates[/b]: Long Entry, Short Entry, Long Exit, Short Exit
 — [b]Text templates[/b]: Long Entry, Short Entry, Long Exit, Short Exit
 — [b]Preview Messages in Pine Logs[/b] (default off)

🎨 [b]Colors:[/b]
 — [b]Bull[/b], [b]Bear[/b], [b]Range[/b]

[b]🔔 Alerts[/b]

 — 🟢 LONG ENTRY — ticker, timeframe, entry level, stop, size, lots, risk
 — 🔴 SHORT ENTRY — the same for the short side
 — ⚪ LONG EXIT — ticker, timeframe, exit level, reason (stop-loss, time, equity guard), size
 — ⚪ SHORT EXIT — the same for the short side

All four exist as plain text and as JSON for webhooks, and all four are fully editable. Messages are sent on order fill.

[b]⚠️ IMPORTANT NOTES[/b]

 — 🚫 [b]No look-ahead.[/b] The strategy is calculated on bar close and orders are filled on the following bars. It does not request other timeframes or symbols and does not read future bars. Results can still change with the amount of loaded history, the chart type or the tester's bar magnifier, because the order of prices inside a candle is not known from one candle alone.
 — 📐 The range is exact when the timeframe divides an hour evenly (1 to 60 minutes) and the chart uses regular candles. On other charts the strategy still runs and shows a note.
 — 📐 If one candle touches both range boundaries, the tester decides which side was reached first. Enable the bar magnifier or test on a lower timeframe to see how many trades depend on this.
 — ⚖️ Risk per trade is a target. Commission, spread, slippage and gaps add to the actual loss.
 — ⚖️ The equity guard and the drawdown figures in the dashboard are estimates made at candle close. They are not a guarantee of staying within a prop firm's limit.
 — ⚖️ The performance chart and dashboard statistics cover the bars loaded on the chart, not the Deep Backtesting range. Use the Strategy Tester for the full period.
 — 🛠️ The script does not place live orders. It simulates orders in the Strategy Tester and sends alert messages; execution through a bot and all trade decisions remain yours.
 — 🌐 Built and tuned for gold on 15 minutes. It can be applied to other symbols and timeframes, but the default hours, stop and exit were not chosen for them.
 — ⚠️ This publication is for educational purposes and is not financial advice. Past performance does not guarantee future results.

## Source Code

````pine
//@version=6
// ══════════════════════════════════════════════════════════
// GOLD BREAKOUT 15M STRATEGY [WillyAlgoTrader]
// ══════════════════════════════════════════════════════════
// Author:  Willy | WillyAlgoTrader
// Version: 1.0.0
//
// Trades the breakout of the overnight range on gold.
//   • Range: high / low built between Range Start and Range End (broker time, default 00:00–07:00)
//   • Entry: stop orders on both range boundaries; the first fill cancels the other. One trade per day
//   • Stop:  percent of the entry price (default 1%) or the opposite range boundary. No take-profit
//   • Exit:  stop-loss, or forced close at Close Hour (default 20:00)
//   • Size:  percent of equity at risk, capped by Max Leverage, rounded down to the quantity step
//
// Before you trade it
//   • Built for gold on the 15-minute chart. Use a timeframe that divides an hour evenly (1–60 min), regular candles
//   • Set Broker Time Mode / Broker Timezone to your broker's server time: the range depends on it
//   • Default costs: commission 0.4 per order, slippage 0. Spread is not modeled. Adjust them in Properties
//   • Risk per trade is a target: commission, spread, slippage and gaps come on top of it
//   • Orders are calculated on bar close and filled on the next bar
//   • Alerts: create an alert on the strategy and leave only {{strategy.order.alert_message}} in the Message field
// ══════════════════════════════════════════════════════════

strategy(
     title              = "Gold Breakout 15M Strategy [WillyAlgoTrader]",
     shorttitle         = "Gold BO 15M",
     overlay            = true,
     initial_capital    = 10000,
     default_qty_type   = strategy.fixed,
     default_qty_value  = 1,
     calc_on_every_tick = false,
     process_orders_on_close = false,
     margin_long        = 5,
     margin_short       = 5,
     commission_type    = strategy.commission.cash_per_order,
     commission_value   = 0.4,
     slippage           = 0,
     max_lines_count    = 500,
     max_labels_count   = 500,
     max_boxes_count    = 500,
     max_bars_back      = 5000)

// ══════════════════════════════════════════════════════════
// 2. CONSTANTS
// ══════════════════════════════════════════════════════════
GRP_MAIN   = "⚙️ Main Settings"
GRP_RISK   = "🛡️ Risk Management"
GRP_VISUAL = "🎨 Visual Settings"
GRP_DASH   = "📊 Dashboard"
GRP_PERF   = "📈 Performance Chart"
GRP_ALERT  = "🔔 Alerts"
GRP_COLORS = "🎨 Colors"

STRATEGY_VERSION = "v1.0.0"

TZ_MODE_FIXED = "Fixed timezone"
TZ_MODE_NY7   = "New York + 7h"
NY7_SHIFT_MS  = 7 * 3600000
NY_TZ         = "America/New_York"

SL_MODE_PCT   = "% of entry"
SL_MODE_RANGE = "Range boundary"
SIZE_RISK     = "% equity at risk"
SIZE_FIXED    = "Fixed quantity"
OCA_GROUP     = "RB"
NO_VALUE      = "—"

DEF_JSON_IN   = '{"strategy":"Gold Breakout 15M","event":"entry","action":"{{action}}","side":"{{side}}","ticker":"{{ticker}}","price":{{price}},"sl":{{sl}},"qty":{{qty}},"lots":{{lots}},"risk_usd":{{risk_usd}},"range_high":{{range_high}},"range_low":{{range_low}},"secret":"{{secret}}"}'
DEF_JSON_OUT  = '{"strategy":"Gold Breakout 15M","event":"exit","action":"{{action}}","side":"{{side}}","ticker":"{{ticker}}","reason":"{{reason}}","price":{{price}},"qty":{{qty}},"secret":"{{secret}}"}'
DEF_TEXT_LONG_IN   = "🟢 BUY | {{tickerid}} | TF: {{interval}} | Price: {{price}} | SL: {{sl}} | Qty: {{qty}} ({{lots}} lots) | Risk: {{risk_usd}}"
DEF_TEXT_SHORT_IN  = "🔴 SELL | {{tickerid}} | TF: {{interval}} | Price: {{price}} | SL: {{sl}} | Qty: {{qty}} ({{lots}} lots) | Risk: {{risk_usd}}"
DEF_TEXT_LONG_OUT  = "⚪ EXIT LONG | {{tickerid}} | TF: {{interval}} | Price: {{price}} | Reason: {{reason}} | Qty: {{qty}}"
DEF_TEXT_SHORT_OUT = "⚪ EXIT SHORT | {{tickerid}} | TF: {{interval}} | Price: {{price}} | Reason: {{reason}} | Qty: {{qty}}"

TIP_TEMPLATE = "Editable message template. Placeholders are listed in the tooltip of 'Webhook JSON Format'."

// ══════════════════════════════════════════════════════════
// 3. INPUTS
// ══════════════════════════════════════════════════════════
// ── Main ────────────────────────────────────────
tzModeInput = input.string(TZ_MODE_FIXED, "Broker Time Mode", options = [TZ_MODE_FIXED, TZ_MODE_NY7], group = GRP_MAIN,
     tooltip = "How broker server time is derived.\n" +
               "• Fixed timezone: uses 'Broker Timezone' below all year round\n" +
               "• New York + 7h: server clock used by most FX/CFD brokers (GMT+2 in winter, GMT+3 in summer, US daylight-saving calendar)\n" +
               "Pick the one matching your broker's server time; a wrong choice shifts the range by an hour for part of the year.")
tzInput = input.string("GMT+3", "Broker Timezone", group = GRP_MAIN,
     tooltip = "Used in 'Fixed timezone' mode. Timezone of your broker's server: all session hours below are in this time.\n" +
               "• Most FX/CFD brokers use GMT+2 in winter and GMT+3 in summer\n" +
               "• Examples: GMT+3, GMT+2, UTC, Europe/Moscow")
rangeFromInput = input.int(0, "Range Start Hour", minval = 0, maxval = 22, step = 1, group = GRP_MAIN,
     tooltip = "Hour (broker time) when the daily range starts building.\n" +
               "• Default: 0 (start of the broker day)")
rangeToInput = input.int(7, "Range End / Trading Start Hour", minval = 1, maxval = 23, step = 1, group = GRP_MAIN,
     tooltip = "Hour when the range is fixed and breakout trading begins.\n" +
               "• Default 7: range 00:00–06:59, trading from 07:00\n" +
               "• Later hour = wider range, fewer breakouts")
closeHourInput = input.int(20, "Close All Positions Hour", minval = 2, maxval = 23, step = 1, group = GRP_MAIN,
     tooltip = "Hour when any open position is force-closed.\n" +
               "• Default: 20. The strategy has no take-profit, this is the main exit")

// ── Risk Management ─────────────────────────────
slModeInput = input.string(SL_MODE_PCT, "SL Mode", options = [SL_MODE_PCT, SL_MODE_RANGE], group = GRP_RISK,
     tooltip = "Where the stop-loss is placed.\n" +
               "• % of entry: fixed percent from the entry price (default 1%). Placed from the breakout level, then re-set from the actual fill price at the close of the entry bar\n" +
               "• Range boundary: opposite side of the range; a narrow range means a tight stop and a larger position")
slPctInput = input.float(1.0, "SL, % of Entry Price", minval = 0.05, maxval = 20.0, step = 0.05, group = GRP_RISK,
     tooltip = "Stop distance in percent of entry price (used in '% of entry' mode).\n" +
               "• Higher = wider stop, smaller position\n" +
               "• Default: 1.0")
sizeModeInput = input.string(SIZE_RISK, "Position Size Mode", options = [SIZE_RISK, SIZE_FIXED], group = GRP_RISK,
     tooltip = "How the order quantity is calculated.\n" +
               "• % equity at risk: qty = equity × risk% / loss to stop\n" +
               "• Fixed quantity: constant number of contracts")
riskPctInput = input.float(1.0, "Risk per Trade, % of Equity", minval = 0.01, maxval = 100.0, step = 0.1, group = GRP_RISK,
     tooltip = "Share of equity lost if the stop is hit.\n" +
               "• Conservative 0.5, balanced 1.0, aggressive 2.0\n" +
               "• This is a target: commission, spread, slippage and gaps add to the actual loss")
fixedQtyInput = input.float(1.0, "Fixed Quantity (contracts)", minval = 0.0001, maxval = 1000000.0, step = 0.01, group = GRP_RISK,
     tooltip = "Order quantity used in 'Fixed quantity' mode.")
lotOzInput = input.float(0.0, "Ounces per Lot (0 = auto)", minval = 0.0, maxval = 1000000.0, step = 1.0, group = GRP_RISK,
     tooltip = "Used only to show size in lots (labels, dashboard, {{lots}} placeholder) on ounce-quoted instruments.\n" +
               "• 0 = auto: 100 oz for gold, 5000 oz for silver (standard broker lots)\n" +
               "• Does not affect trades")
maxLeverageInput = input.float(10.0, "Max Leverage", minval = 0.1, maxval = 100.0, step = 1.0, group = GRP_RISK,
     tooltip = "Upper limit for position notional ÷ equity. Size = the smaller of risk-based size and this cap.\n" +
               "• 1% risk with 1% stop needs ×1; range-boundary stops usually need ×2–5\n" +
               "• When the cap is hit, actual risk is lower than requested (shown in the dashboard)\n" +
               "• Strategy margin is declared as 5% (20x in Properties), so this input is the effective limiter\n" +
               "• Values near or above 20 also need a higher Long/Short leverage in Properties, otherwise the tester may reject the orders")
qtyStepInput = input.float(0.0, "Quantity Step (0 = auto)", minval = 0.0, maxval = 1000000.0, step = 0.01, group = GRP_RISK,
     tooltip = "Order quantity is rounded DOWN to this step, so the planned risk (before commission, spread and gaps) stays within the budget.\n" +
               "• 0 = minimum contract size reported by TradingView for the symbol\n" +
               "• Set your exchange / bot step if it differs\n" +
               "• If the size is below one step, the entry is skipped")
guardOnInput = input.bool(false, "Prop Firm Guard: Close on Daily Drawdown", group = GRP_RISK,
     tooltip = "Closes everything and stops trading until the next day when equity falls from the daily peak by the limit below.\n" +
               "• Drawdown is measured at the worst point of each candle (not on the entry candle), but the guard reacts only at candle close\n" +
               "• For a live prop account use a low timeframe; this is not a guarantee of staying within a firm's limit")
guardDdInput = input.float(4.0, "Max Drawdown from Daily Equity Peak, %", minval = 0.1, maxval = 100.0, step = 0.1, group = GRP_RISK,
     tooltip = "Daily drawdown limit for the Prop Firm Guard.\n" +
               "• Typical prop firm daily limit: 4–5%")
showSlInput = input.bool(true, "Show Entry / SL Levels", group = GRP_RISK,
     tooltip = "Draw entry price and stop-loss lines with a risk zone while a position is open.")

// ── Visual ──────────────────────────────────────
themeInput = input.string("Auto", "Theme", options = ["Auto", "Dark", "Light"], group = GRP_VISUAL,
     tooltip = "Chart color theme.\n" +
               "• Auto: detects from chart background\n" +
               "• Dark: optimized for dark backgrounds\n" +
               "• Light: optimized for light/white backgrounds")
showRangeInput = input.bool(true, "Show Range Box & Boundaries", group = GRP_VISUAL,
     tooltip = "Draw the daily range box and its high/low lines extended over the trading session.")
showEntryLabelsInput = input.bool(true, "Show Entry Labels", group = GRP_VISUAL,
     tooltip = "Label at each entry: direction, entry price, stop, size and risk.")
showExitLabelsInput = input.bool(true, "Show Exit Labels (Trade Result)", group = GRP_VISUAL,
     tooltip = "Label at each exit: P&L in money and in R, price move, exit price and reason.")
showTradeBoxInput = input.bool(true, "Show Trade Box (Entry → Exit)", group = GRP_VISUAL,
     tooltip = "Green/red box between entry and exit of every closed trade.")
labelSizeInput = input.string("Small", "Label Size", options = ["Small", "Normal"], group = GRP_VISUAL,
     tooltip = "Text size of entry/exit labels.")
showWarningsInput = input.bool(true, "Show Accuracy Warnings", group = GRP_VISUAL,
     tooltip = "Note on the last bar when the range may be inaccurate: timeframe above 1H or not dividing an hour evenly, or a non-standard chart (Heikin Ashi, Renko…).\n" +
               "Informational only: trading is not disabled.")
showWatermarkInput = input.bool(true, "Show Watermark", group = GRP_VISUAL,
     tooltip = "Display 'WillyAlgoTrader' watermark on chart")

// ── Dashboard ───────────────────────────────────
showDashInput = input.bool(true, "Show Dashboard", group = GRP_DASH,
     tooltip = "Status panel with range, session and position calculator.")
showMathInput = input.bool(true, "Show Strategy Math", group = GRP_DASH,
     tooltip = "Trade statistics: win rate, breakeven win rate, profit factor, payoff, expectancy in money and in R, drawdown, losing streak.\n" +
               "R = trade result divided by the initial risk to the stop.")
dashPosInput = input.string("Top Right", "Dashboard Position", options = ["Top Left", "Top Right", "Bottom Left", "Bottom Right", "Middle Right"], group = GRP_DASH,
     tooltip = "Corner of the chart where the dashboard is placed.")
dashSizeInput = input.string("Small", "Dashboard Text Size", options = ["Small", "Normal", "Large"], group = GRP_DASH,
     tooltip = "Text size of dashboard rows.")

// ── Performance Chart ───────────────────────────
showPerfInput = input.bool(false, "Show Performance Chart", group = GRP_PERF,
     tooltip = "Cumulative PnL curve with key stats, drawn over the chart.\n" +
               "• Built from closed trades on the bars loaded on the chart — NOT from the Deep Backtesting range\n" +
               "• Covers the candles behind it while enabled")
perfPosInput = input.string("Bottom Left", "Chart Position", options = ["Bottom Left", "Bottom Center", "Bottom Right", "Middle Center", "Top Left", "Top Center"], group = GRP_PERF,
     tooltip = "Where the performance chart is placed.\n" +
               "• Bottom Center: the watermark is hidden while the chart is there\n" +
               "• Same corner as the dashboard: a warning is shown, move one of them")
perfColsInput = input.int(80, "Chart Columns", minval = 20, maxval = 150, step = 10, group = GRP_PERF,
     tooltip = "Horizontal resolution of the curve.\n" +
               "• Higher = smoother curve, slower drawing\n" +
               "• Recommended: 60–100")
perfRowsInput = input.int(30, "Chart Rows", minval = 10, maxval = 60, step = 5, group = GRP_PERF,
     tooltip = "Vertical resolution of the curve.\n" +
               "• Higher = finer steps, slower drawing\n" +
               "• Recommended: 24–40")
perfWidthInput = input.float(50.0, "Chart Width, % of Screen", minval = 20.0, maxval = 90.0, step = 5.0, group = GRP_PERF,
     tooltip = "Width of the curve area as a share of the chart pane.")
perfHeightInput = input.float(35.0, "Chart Height, % of Screen", minval = 10.0, maxval = 70.0, step = 5.0, group = GRP_PERF,
     tooltip = "Height of the curve area as a share of the chart pane.")

// ── Alerts ──────────────────────────────────────
enableAlertsInput = input.bool(true, "Enable Alert Messages", group = GRP_ALERT,
     tooltip = "When off, order alert messages are sent empty.\n" +
               "Setup: create an alert on this strategy and leave only {{strategy.order.alert_message}} in the Message field.")
webhookInput = input.bool(false, "Webhook JSON Format", group = GRP_ALERT,
     tooltip = "On: JSON templates are sent (for bots / webhooks). Off: text templates.\n\n" +
               "Placeholders filled by the strategy:\n" +
               "{{ticker}} {{tickerid}} {{exchange}} {{interval}}\n" +
               "{{event}} = entry / exit\n" +
               "{{side}} = long / short\n" +
               "{{action}} = buy / sell\n" +
               "{{reason}} = breakout / sl / time / equity_guard\n" +
               "{{price}} = order level (entry stop / SL) or bar close for time and guard exits — not the fill price\n" +
               "{{entry}} = entry reference price, {{sl}} = planned stop-loss, {{sl_pct}} = stop distance in % of entry\n" +
               "{{trade_id}} = ticker + day, identical in the entry and exit messages of one trade\n" +
               "Note: in '% of entry' mode the stop is re-set from the actual fill and no separate alert is sent. " +
               "A bot that places its own stop should compute it as {{sl_pct}} from its own fill price.\n" +
               "{{qty}} = contracts, {{oz}} = qty × point value (ounces on ounce-quoted instruments), {{lots}} = lots\n" +
               "{{risk_usd}} {{risk_pct}} = initial risk of the trade (entry to SL)\n" +
               "{{equity}} {{range_high}} {{range_low}} {{secret}}\n\n" +
               "TradingView's own placeholders (e.g. {{strategy.order.price}}, {{timenow}}) are NOT processed inside these templates. " +
               "Put them into the Message field of the alert itself, next to {{strategy.order.alert_message}}.")
secretInput = input.string("", "Bot Secret → {{secret}}", group = GRP_ALERT,
     tooltip = "Replaces {{secret}} in templates.\n" +
               "Note: stored in chart settings and visible to anyone you share the chart with.")
jsonLongInInput   = input.text_area(DEF_JSON_IN,  "JSON · Long Entry",  group = GRP_ALERT, tooltip = TIP_TEMPLATE)
jsonShortInInput  = input.text_area(DEF_JSON_IN,  "JSON · Short Entry", group = GRP_ALERT, tooltip = TIP_TEMPLATE)
jsonLongOutInput  = input.text_area(DEF_JSON_OUT, "JSON · Long Exit",   group = GRP_ALERT, tooltip = TIP_TEMPLATE)
jsonShortOutInput = input.text_area(DEF_JSON_OUT, "JSON · Short Exit",  group = GRP_ALERT, tooltip = TIP_TEMPLATE)
textLongInInput   = input.text_area(DEF_TEXT_LONG_IN,   "Text · Long Entry",  group = GRP_ALERT, tooltip = TIP_TEMPLATE)
textShortInInput  = input.text_area(DEF_TEXT_SHORT_IN,  "Text · Short Entry", group = GRP_ALERT, tooltip = TIP_TEMPLATE)
textLongOutInput  = input.text_area(DEF_TEXT_LONG_OUT,  "Text · Long Exit",   group = GRP_ALERT, tooltip = TIP_TEMPLATE)
textShortOutInput = input.text_area(DEF_TEXT_SHORT_OUT, "Text · Short Exit",  group = GRP_ALERT, tooltip = TIP_TEMPLATE)
showPreviewInput = input.bool(false, "Preview Messages in Pine Logs", group = GRP_ALERT,
     tooltip = "Writes all four messages to Pine Logs as they would be sent (values of the last historical bar), with the bot secret masked as ***. Use it to check a template without waiting for a signal.")

// ── Colors ──────────────────────────────────────
bullColorInput  = input.color(#00E676, "Bull",  inline = "colors", group = GRP_COLORS,
     tooltip = "Background of long entry labels, winning exit labels and winning trade boxes.")
bearColorInput  = input.color(#FF5252, "Bear",  inline = "colors", group = GRP_COLORS,
     tooltip = "Background of short entry labels, losing exit labels and losing trade boxes.")
rangeColorInput = input.color(#2962FF, "Range", inline = "colors", group = GRP_COLORS,
     tooltip = "Color of the daily range box, its boundaries and range labels.")

// ══════════════════════════════════════════════════════════
// 4. THEME DETECTION & COLORS
// ══════════════════════════════════════════════════════════
isDark = switch themeInput
    "Dark"  => true
    "Light" => false
    =>         color.r(chart.bg_color) < 128   // Auto

// ── Text ────────────────────────────────────────
TEXT_COLOR      = isDark ? #E0E0E0 : #1A1A1A
TEXT_MUTED      = isDark ? color.new(#9E9E9E, 0) : color.new(#757575, 0)

// ── Signal colors for text on the chart / table ─
BULL_TEXT       = isDark ? #00E676 : #00A152
BEAR_TEXT       = isDark ? #FF5252 : #D32F2F
NEUTRAL_TEXT    = isDark ? #FFEB3B : #F57F17

// ── Labels ──────────────────────────────────────
BULL_LABEL_TEXT = #004D25
BEAR_LABEL_TEXT = #FFFFFF
WARN_BG         = #FFEB3B
WARN_TEXT       = #1A1A1A

// ── Zones ───────────────────────────────────────
BULL_BG         = color.new(bullColorInput, 85)
BEAR_BG         = color.new(bearColorInput, 85)
RANGE_BG        = color.new(rangeColorInput, 85)
RANGE_BORDER    = color.new(rangeColorInput, 40)

// ── Dashboard ───────────────────────────────────
TABLE_BG        = isDark ? color.new(#131722, 5) : color.new(#FFFFFF, 5)
TABLE_BORDER    = isDark ? color.new(#2A2E39, 0) : color.new(#D0D0D0, 0)
TABLE_ROW_ALT   = isDark ? color.new(#1C2030, 0) : color.new(#F0F4F8, 0)
HEADER_BG       = isDark ? color.new(#0D47A1, 0) : color.new(#1565C0, 0)
HEADER_TEXT     = #FFFFFF

// ── Levels ──────────────────────────────────────
SL_COLOR        = color.new(#FF5252, 0)
ENTRY_COLOR     = color.new(#2962FF, 0)
WM_COLOR        = isDark ? color.new(#FFFFFF, 80) : color.new(#000000, 80)
TRANSPARENT     = color.new(#000000, 100)

// ── Performance Chart ───────────────────────────
PERF_FILL_UP    = color.new(BULL_TEXT, 82)
PERF_FILL_DN    = color.new(BEAR_TEXT, 82)

labelSize = labelSizeInput == "Normal" ? size.normal : size.small
dashSize  = dashSizeInput == "Large" ? size.large : dashSizeInput == "Normal" ? size.normal : size.small

dashPos = switch dashPosInput
    "Top Left"     => position.top_left
    "Top Right"    => position.top_right
    "Bottom Left"  => position.bottom_left
    "Bottom Right" => position.bottom_right
    "Middle Right" => position.middle_right
    => position.top_right

perfPos = switch perfPosInput
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    "Middle Center" => position.middle_center
    "Top Left"      => position.top_left
    "Top Center"    => position.top_center
    => position.bottom_left

// ── Broker time mode ────────────────────────────
bool   useNy7  = tzModeInput == TZ_MODE_NY7
string calcTz  = useNy7 ? "UTC" : tzInput
string tzLabel = useNy7 ? "NY+7h" : tzInput

// ── Instrument type ─────────────────────────────
// Used only for size units (oz / units) and lot size in labels, dashboard and alerts. It does not restrict trading.
string tickerUpper = str.upper(syminfo.ticker)
string rootUpper   = str.upper(syminfo.root)
string prefixUpper = str.upper(syminfo.prefix)
bool   isFutures   = syminfo.type == "futures"

bool isXauName   = str.contains(tickerUpper, "XAU") and not str.startswith(tickerUpper, "XAG")
bool isGoldName  = str.contains(tickerUpper, "GOLD") or str.contains(tickerUpper, "PAXG") or str.startswith(tickerUpper, "GLDRUB")
bool isCmeRoot   = isFutures and (rootUpper == "GC" or rootUpper == "MGC" or rootUpper == "1OZ" or rootUpper == "QO")
bool isHkexRoot  = isFutures and (rootUpper == "GDU" or rootUpper == "GDR")
bool isShfeRoot  = isFutures and rootUpper == "AU" and syminfo.currency == "CNY"
bool isMoexRoot  = isFutures and rootUpper == "GD" and (prefixUpper == "MOEX" or prefixUpper == "RUS")
bool isSgeName   = prefixUpper == "SGE" and (str.startswith(tickerUpper, "AU") or str.startswith(tickerUpper, "MAU"))
bool isGold      = isXauName or isGoldName or isCmeRoot or isHkexRoot or isShfeRoot or isMoexRoot or isSgeName

bool isXagName     = str.contains(tickerUpper, "XAG")
bool isSilverName  = str.contains(tickerUpper, "SILVER") or str.startswith(tickerUpper, "SLVRUB")
bool isCmeSilver   = isFutures and (rootUpper == "SIL" or rootUpper == "QI" or (rootUpper == "SI" and syminfo.currency == "USD"))
bool isShfeSilver  = isFutures and rootUpper == "AG" and syminfo.currency == "CNY"
bool isMoexSilver  = isFutures and (rootUpper == "SV" or rootUpper == "SILV") and (prefixUpper == "MOEX" or prefixUpper == "RUS")
bool isSgeSilver   = prefixUpper == "SGE" and str.startswith(tickerUpper, "AG")
bool isSilver      = not isGold and (isXagName or isSilverName or isCmeSilver or isShfeSilver or isMoexSilver or isSgeSilver)

float lotOz        = lotOzInput > 0 ? lotOzInput : isSilver ? 5000.0 : 100.0

bool   isOunceGold   = isXauName or str.contains(tickerUpper, "PAXG") or isCmeRoot or isMoexRoot or (str.contains(tickerUpper, "GOLD") and syminfo.currency == "USD")
bool   isOunceSilver = isSilver and (isXagName or isCmeSilver or isMoexSilver or (str.contains(tickerUpper, "SILVER") and syminfo.currency == "USD"))
bool   isOunceQuoted = isOunceGold or isOunceSilver
string unitLabel     = isOunceQuoted ? "oz" : "units"

// ══════════════════════════════════════════════════════════
// 5. FUNCTIONS
// ══════════════════════════════════════════════════════════
safeDiv(float num, float den, float fallback = 0.0) =>
    den != 0 and not na(num) and not na(den) ? num / den : fallback

// Rounds quantity down to the instrument step, so the planned risk never grows from rounding
roundQtyDown(float qty, float step) =>
    float q = math.max(nz(qty), 0.0)
    step > 0 ? math.floor(q / step + 1e-9) * step : q

signedStr(float x, string fmt) =>
    na(x) ? NO_VALUE : (x > 0 ? "+" : "") + str.tostring(x, fmt)

priceStr(float x) =>
    na(x) ? NO_VALUE : str.tostring(x, format.mintick)

numStr(float x, string fmt) =>
    na(x) ? NO_VALUE : str.tostring(x, fmt)

maskSecret(string s) =>
    secretInput == "" ? s : str.replace_all(s, secretInput, "***")

// Fills an alert template. entryRef is the entry price the risk is measured from; tradeId is shared by the entry
// and exit messages of one trade; equityRef is equity at entry, so {{risk_pct}} stays the initial risk.
fillTemplate(string tpl, bool isLong, string event, string reason, float price, float entryRef, float sl, float qty, float rHigh, float rLow, string tradeId, float equityRef) =>
    string s = ""
    if enableAlertsInput
        float oz      = nz(qty) * syminfo.pointvalue
        float riskUsd = math.abs(nz(entryRef) - nz(sl)) * oz
        s := tpl
        s := str.replace_all(s, "{{ticker}}",     syminfo.ticker)
        s := str.replace_all(s, "{{tickerid}}",   syminfo.tickerid)
        s := str.replace_all(s, "{{exchange}}",   syminfo.prefix)
        s := str.replace_all(s, "{{interval}}",   timeframe.period)
        s := str.replace_all(s, "{{event}}",      event)
        s := str.replace_all(s, "{{trade_id}}",   tradeId)
        s := str.replace_all(s, "{{side}}",       isLong ? "long" : "short")
        s := str.replace_all(s, "{{action}}",     (event == "entry") == isLong ? "buy" : "sell")
        s := str.replace_all(s, "{{reason}}",     reason)
        s := str.replace_all(s, "{{price}}",      str.tostring(nz(price), format.mintick))
        s := str.replace_all(s, "{{entry}}",      str.tostring(nz(entryRef), format.mintick))
        s := str.replace_all(s, "{{sl}}",         str.tostring(nz(sl), format.mintick))
        s := str.replace_all(s, "{{sl_pct}}",     str.tostring(safeDiv(math.abs(nz(entryRef) - nz(sl)), entryRef) * 100.0, "0.####"))
        s := str.replace_all(s, "{{qty}}",        str.tostring(nz(qty), "0.########"))
        s := str.replace_all(s, "{{oz}}",         str.tostring(oz, "0.########"))
        s := str.replace_all(s, "{{lots}}",       str.tostring(safeDiv(oz, lotOz), "0.########"))
        s := str.replace_all(s, "{{risk_usd}}",   str.tostring(riskUsd, "0.00"))
        s := str.replace_all(s, "{{risk_pct}}",   str.tostring(safeDiv(riskUsd, equityRef) * 100.0, "0.00"))
        s := str.replace_all(s, "{{equity}}",     str.tostring(strategy.equity, "0.00"))
        s := str.replace_all(s, "{{range_high}}", str.tostring(nz(rHigh), format.mintick))
        s := str.replace_all(s, "{{range_low}}",  str.tostring(nz(rLow), format.mintick))
        s := str.replace_all(s, "{{secret}}",     secretInput)
    s

// Broker server time. In "New York + 7h" mode: New York local time plus 7 hours (follows the US daylight-saving calendar)
brokerClock(int t) =>
    useNy7 ? timestamp("UTC", year(t, NY_TZ), month(t, NY_TZ), dayofmonth(t, NY_TZ), hour(t, NY_TZ), minute(t, NY_TZ), second(t, NY_TZ)) + NY7_SHIFT_MS : t

// Row index (from the bottom) of a PnL value on the performance chart
perfLevel(float v, float vMin, float span, int rows) =>
    span > 0 ? math.round((v - vMin) / span * (rows - 1)) : 0

drawEntryLabel(bool isLong, float price, float sl, float qty) =>
    label result = na
    if showEntryLabelsInput and not na(price) and not na(sl)
        float oz   = nz(qty) * syminfo.pointvalue
        string txt = (isLong ? "▲ LONG" : "▼ SHORT") + "\nEntry " + priceStr(price) + "\nSL " + priceStr(sl) + " (" + str.tostring(safeDiv(math.abs(price - sl), price) * 100.0, "0.00") + "%)" + "\nSize " + str.tostring(oz, "0.####") + " " + unitLabel + (isOunceQuoted ? " · " + str.tostring(safeDiv(oz, lotOz), "0.####") + " lots" : "") + "\nRisk " + str.tostring(math.abs(price - sl) * oz, "0.00") + " " + syminfo.currency
        result := label.new(bar_index, price, txt,
             yloc      = isLong ? yloc.belowbar : yloc.abovebar,
             style     = isLong ? label.style_label_up : label.style_label_down,
             color     = isLong ? bullColorInput : bearColorInput,
             textcolor = isLong ? BULL_LABEL_TEXT : BEAR_LABEL_TEXT,
             size      = labelSize,
             textalign = text.align_left,
             tooltip   = (isLong ? "Buy Signal" : "Sell Signal") + "\nReason: range breakout")
    result

// Dashboard helpers: each returns the index of the next row
dashHeader(table t, int r, string s) =>
    table.cell(t, 0, r, s, text_color = HEADER_TEXT, bgcolor = HEADER_BG, text_size = dashSize, text_halign = text.align_center)
    table.merge_cells(t, 0, r, 1, r)
    r + 1

dashRow(table t, int r, string k, string v, color valueColor) =>
    color rowBg = r % 2 == 0 ? TABLE_BG : TABLE_ROW_ALT
    table.cell(t, 0, r, k, text_color = TEXT_MUTED, bgcolor = rowBg, text_size = dashSize, text_halign = text.align_left)
    table.cell(t, 1, r, v, text_color = valueColor, bgcolor = rowBg, text_size = dashSize, text_halign = text.align_right)
    r + 1

// ══════════════════════════════════════════════════════════
// 6. CALCULATIONS
// ══════════════════════════════════════════════════════════
// The strategy runs on bar close only, so the forming bar is never the "last" one while the market is open;
// the last confirmed bar is used as well, otherwise tables would appear only after the next bar closes.
bool isLastBar = barstate.islast or barstate.islastconfirmedhistory

// The range is exact only when the timeframe divides an hour evenly; otherwise a warning is shown.
// Trading is disabled only when the session hours are out of order.
int  tfSec   = timeframe.in_seconds()
bool tfOk    = tfSec > 0 and tfSec <= 3600 and 3600 % tfSec == 0
bool hoursOk = rangeFromInput < rangeToInput and rangeToInput < closeHourInput
bool envOk   = hoursOk

// ── Bar time (broker clock) ─────────────────────
// nextHour is the hour of the next bar's open: orders placed now are filled on that bar.
int  barTime  = brokerClock(time)
int  barHour  = hour(barTime, calcTz)
int  nextHour = hour(brokerClock(time_close), calcTz)
int  dayKey   = year(barTime, calcTz) * 10000 + month(barTime, calcTz) * 100 + dayofmonth(barTime, calcTz)
bool isNewDay = dayKey != nz(dayKey[1], -1)
bool inRange  = barHour >= rangeFromInput and barHour < rangeToInput

// ── Daily range ─────────────────────────────────
var float rangeHigh     = na
var float rangeLow      = na
var int   rangeStartBar = na
var int   tradedDay     = -1
var bool  isHalted      = false
var float dayEquityPeak = na
var float slActiveLong  = na
var float slActiveShort = na
// The first day of loaded history is skipped: its range may be incomplete
var int   firstDayKey   = na
if na(firstDayKey)
    firstDayKey := dayKey
float prevEquity = nz(strategy.equity[1], strategy.equity)

if isNewDay
    rangeHigh     := na
    rangeLow      := na
    rangeStartBar := na
    isHalted      := false
    dayEquityPeak := prevEquity

if inRange
    if na(rangeHigh)
        rangeStartBar := bar_index
    rangeHigh := na(rangeHigh) ? high : math.max(rangeHigh, high)
    rangeLow  := na(rangeLow)  ? low  : math.min(rangeLow, low)

bool rangeReady   = not na(rangeHigh) and not na(rangeLow) and rangeHigh > rangeLow
bool nextInWindow = nextHour >= rangeToInput and nextHour < closeHourInput

// ── Position state ──────────────────────────────
bool inPos      = strategy.position_size != 0
bool posLong    = strategy.position_size > 0
bool justOpened = inPos and strategy.position_size[1] == 0
if justOpened
    tradedDay := dayKey             // one trade per day
    strategy.cancel("Long")
    strategy.cancel("Short")
    // In % mode the stop is re-set once from the actual fill price and then stays fixed
    if slModeInput == SL_MODE_PCT
        if posLong
            slActiveLong  := math.round_to_mintick(strategy.position_avg_price * (1.0 - slPctInput / 100.0))
        else
            slActiveShort := math.round_to_mintick(strategy.position_avg_price * (1.0 + slPctInput / 100.0))

// ── Closed-trade statistics ─────────────────────
// R = trade result divided by its initial risk (entry to stop)
var int   seenClosed    = 0
var int   tradeCount    = 0
var int   winCount      = 0
var int   lossCount     = 0
var float grossWin      = 0.0
var float grossLoss     = 0.0
var float sumR          = 0.0
var int   lossStreak    = 0
var int   maxLossStreak = 0
var float lastPnl       = na
var float lastR         = na
var array<float> equityCurve = array.new<float>()
var float cumPnl         = 0.0
var int   firstTradeTime = na
var int   lastTradeTime  = na

int newClosedFrom = seenClosed
int newClosedTo   = strategy.closedtrades - 1
if newClosedTo >= newClosedFrom
    for i = newClosedFrom to newClosedTo
        float tSize  = strategy.closedtrades.size(i)
        float tPnl   = strategy.closedtrades.profit(i)
        float tEntry = strategy.closedtrades.entry_price(i)
        float tSl    = tSize > 0 ? slActiveLong : slActiveShort
        float tRisk  = strategy.convert_to_account(math.abs(tEntry - nz(tSl, tEntry)) * math.abs(tSize) * syminfo.pointvalue)
        float tR     = tRisk > 0 ? tPnl / tRisk : na
        // Entry and exit inside one bar: the position is already flat at bar close, so count the day here
        if strategy.closedtrades.entry_bar_index(i) == strategy.closedtrades.exit_bar_index(i)
            tradedDay := dayKey
        tradeCount += 1
        if tPnl > 0
            winCount   += 1
            grossWin   += tPnl
            lossStreak := 0
        else if tPnl < 0
            lossCount  += 1
            grossLoss  += -tPnl
            lossStreak += 1
            maxLossStreak := math.max(maxLossStreak, lossStreak)
        sumR    += nz(tR)
        lastPnl := tPnl
        lastR   := tR
        cumPnl  += tPnl
        if showPerfInput
            array.push(equityCurve, cumPnl)
        if na(firstTradeTime)
            firstTradeTime := strategy.closedtrades.entry_time(i)
        lastTradeTime := strategy.closedtrades.exit_time(i)
    seenClosed := strategy.closedtrades

// ── Equity drawdown (estimate) ──────────────────
// Uses the worst point of each candle (low for longs, high for shorts) against the equity peak reached before
// that candle. It is an estimate: the order of high and low inside a candle is unknown and the entry candle
// is measured at its close only.
var float equityHigh = strategy.initial_capital
var float maxDdPct   = 0.0
var float maxDdMoney = 0.0
float adverseMove = inPos and not justOpened ? (posLong ? close - low : high - close) : 0.0
float worstEquity = strategy.equity - strategy.convert_to_account(math.max(adverseMove, 0.0) * math.abs(strategy.position_size) * syminfo.pointvalue)

maxDdPct   := math.max(maxDdPct, safeDiv(equityHigh - worstEquity, equityHigh) * 100.0)
maxDdMoney := math.max(maxDdMoney, equityHigh - worstEquity)
equityHigh := math.max(equityHigh, strategy.equity)

float dayDdPct = math.max(safeDiv(dayEquityPeak - worstEquity, dayEquityPeak) * 100.0, 0.0)
dayEquityPeak := math.max(nz(dayEquityPeak, strategy.equity), strategy.equity)

// ══════════════════════════════════════════════════════════
// 7. SIGNAL LOGIC
// ══════════════════════════════════════════════════════════
// A breakout can be armed when the range is complete, the next bar opens inside the trading window,
// there is no position and no trade has been taken today
bool setupReady = envOk and rangeReady and nextInWindow and not inPos and tradedDay != dayKey and dayKey != firstDayKey

// ══════════════════════════════════════════════════════════
// 8. RISK MANAGEMENT (SL / SIZE / GUARD)
// ══════════════════════════════════════════════════════════
// Planned stop from the breakout level. Size = equity × risk% / (stop distance × point value),
// capped by Max Leverage and rounded down to the quantity step. Equity is converted to the symbol currency.
float slLong    = slModeInput == SL_MODE_PCT ? math.round_to_mintick(rangeHigh * (1.0 - slPctInput / 100.0)) : rangeLow
float slShort   = slModeInput == SL_MODE_PCT ? math.round_to_mintick(rangeLow * (1.0 + slPctInput / 100.0)) : rangeHigh
float riskLong  = rangeHigh - slLong
float riskShort = slShort - rangeLow
float equitySym   = strategy.convert_to_symbol(strategy.equity)
float riskMoney   = equitySym * riskPctInput / 100.0
float rawQtyLong  = sizeModeInput == SIZE_FIXED ? fixedQtyInput : (riskLong > 0 ? safeDiv(riskMoney, riskLong * syminfo.pointvalue) : 0.0)
float rawQtyShort = sizeModeInput == SIZE_FIXED ? fixedQtyInput : (riskShort > 0 ? safeDiv(riskMoney, riskShort * syminfo.pointvalue) : 0.0)
float capQtyLong  = math.max(safeDiv(equitySym * maxLeverageInput, rangeHigh * syminfo.pointvalue), 0.0)
float capQtyShort = math.max(safeDiv(equitySym * maxLeverageInput, rangeLow * syminfo.pointvalue), 0.0)
bool  isCappedLong  = rawQtyLong > capQtyLong
bool  isCappedShort = rawQtyShort > capQtyShort
float qtyStep  = qtyStepInput > 0 ? qtyStepInput : nz(syminfo.mincontract)
float qtyLong  = roundQtyDown(math.min(rawQtyLong, capQtyLong), qtyStep)
float qtyShort = roundQtyDown(math.min(rawQtyShort, capQtyShort), qtyStep)

string tplLongIn   = webhookInput ? jsonLongInInput   : textLongInInput
string tplShortIn  = webhookInput ? jsonShortInInput  : textShortInInput
string tplLongOut  = webhookInput ? jsonLongOutInput  : textLongOutInput
string tplShortOut = webhookInput ? jsonShortOutInput : textShortOutInput

string idPlan = syminfo.ticker + "-" + str.tostring(dayKey)
string idOpen = syminfo.ticker + "-" + str.tostring(tradedDay)
var float entryEquitySym = na

// ── Equity guard ────────────────────────────────
// Pending orders are cancelled before the close order is created: cancel_all would remove that order too
bool guardFired = false
if guardOnInput and not isHalted and dayDdPct >= guardDdInput
    string guardMsg = inPos ? fillTemplate(posLong ? tplLongOut : tplShortOut, posLong, "exit", "equity_guard", close, strategy.position_avg_price, posLong ? slActiveLong : slActiveShort, math.abs(strategy.position_size), rangeHigh, rangeLow, idOpen, entryEquitySym) : ""
    strategy.cancel_all()
    strategy.close_all(comment = "Equity guard", alert_message = guardMsg)
    isHalted   := true
    guardFired := true

// ── Orders ──────────────────────────────────────
// Both breakout entries share an OCA group: the first fill cancels the other. Each entry has its stop attached.
bool canTrade = setupReady and not isHalted
if canTrade
    slActiveLong   := slLong
    slActiveShort  := slShort
    entryEquitySym := equitySym
    if qtyLong > 0 and riskLong > 0
        strategy.entry("Long", strategy.long, qty = qtyLong, stop = rangeHigh, oca_name = OCA_GROUP, oca_type = strategy.oca.cancel, comment = "RB long",
             alert_message = fillTemplate(tplLongIn, true, "entry", "breakout", rangeHigh, rangeHigh, slLong, qtyLong, rangeHigh, rangeLow, idPlan, equitySym))
        strategy.exit("SL-L", from_entry = "Long", stop = slLong, comment = "SL",
             alert_message = fillTemplate(tplLongOut, true, "exit", "sl", slLong, rangeHigh, slLong, qtyLong, rangeHigh, rangeLow, idPlan, equitySym))
    if qtyShort > 0 and riskShort > 0
        strategy.entry("Short", strategy.short, qty = qtyShort, stop = rangeLow, oca_name = OCA_GROUP, oca_type = strategy.oca.cancel, comment = "RB short",
             alert_message = fillTemplate(tplShortIn, false, "entry", "breakout", rangeLow, rangeLow, slShort, qtyShort, rangeHigh, rangeLow, idPlan, equitySym))
        strategy.exit("SL-S", from_entry = "Short", stop = slShort, comment = "SL",
             alert_message = fillTemplate(tplShortOut, false, "exit", "sl", slShort, rangeLow, slShort, qtyShort, rangeHigh, rangeLow, idPlan, equitySym))
else if not inPos
    strategy.cancel("Long")
    strategy.cancel("Short")

// ── Open position ───────────────────────────────
// No alert is sent when the stop is re-set: a bot placing its own stop should use {{sl_pct}} from its own fill
if inPos
    float  posQty = math.abs(strategy.position_size)
    float  posSl  = posLong ? slActiveLong : slActiveShort
    string posTpl = posLong ? tplLongOut : tplShortOut
    float  posEntry = strategy.position_avg_price
    if posLong
        strategy.exit("SL-L", from_entry = "Long", stop = slActiveLong, comment = "SL",
             alert_message = fillTemplate(posTpl, true, "exit", "sl", posSl, posEntry, posSl, posQty, rangeHigh, rangeLow, idOpen, entryEquitySym))
    else
        strategy.exit("SL-S", from_entry = "Short", stop = slActiveShort, comment = "SL",
             alert_message = fillTemplate(posTpl, false, "exit", "sl", posSl, posEntry, posSl, posQty, rangeHigh, rangeLow, idOpen, entryEquitySym))
    // Time exit: the close order is filled on the open of the next bar
    if (nextHour >= closeHourInput or nextHour < rangeToInput) and not guardFired
        strategy.close_all(comment = "Time exit " + str.tostring(closeHourInput) + ":00",
             alert_message = fillTemplate(posTpl, posLong, "exit", "time", close, posEntry, posSl, posQty, rangeHigh, rangeLow, idOpen, entryEquitySym))

// ══════════════════════════════════════════════════════════
// 9. PLOTS & VISUALS
// ══════════════════════════════════════════════════════════
// Range box while the range is building, then its boundaries extended over the trading session
var box  rangeBox = na
var line highLine = na
var line lowLine  = na
if showRangeInput
    if isNewDay
        rangeBox := na
        highLine := na
        lowLine  := na
    if inRange and not na(rangeHigh)
        if na(rangeBox)
            rangeBox := box.new(rangeStartBar, rangeHigh, bar_index, rangeLow, border_color = RANGE_BORDER, bgcolor = RANGE_BG)
        else
            box.set_top(rangeBox, rangeHigh)
            box.set_bottom(rangeBox, rangeLow)
            box.set_right(rangeBox, bar_index)
    if not inRange and rangeReady and barHour < closeHourInput
        if na(highLine)
            string widthStr = priceStr(rangeHigh - rangeLow) + " (" + str.tostring(safeDiv(rangeHigh - rangeLow, rangeLow) * 100.0, "0.00") + "%)"
            highLine := line.new(bar_index - 1, rangeHigh, bar_index, rangeHigh, color = rangeColorInput, width = 2)
            lowLine  := line.new(bar_index - 1, rangeLow, bar_index, rangeLow, color = rangeColorInput, width = 2)
            label.new(bar_index, rangeHigh, "Range High " + priceStr(rangeHigh), style = label.style_label_down, color = rangeColorInput, textcolor = HEADER_TEXT, size = size.small)
            label.new(bar_index, rangeLow, "Range Low " + priceStr(rangeLow) + " · width " + widthStr, style = label.style_label_up, color = rangeColorInput, textcolor = HEADER_TEXT, size = size.small)
        else
            line.set_x2(highLine, bar_index)
            line.set_x2(lowLine, bar_index)

// ══════════════════════════════════════════════════════════
// 10. LABELS & SHAPES
// ══════════════════════════════════════════════════════════
// Entry label, then result label and trade box for every trade closed on this bar
var int lastEntryBar = -1
if justOpened
    drawEntryLabel(posLong, strategy.position_avg_price, posLong ? slActiveLong : slActiveShort, math.abs(strategy.position_size))
    lastEntryBar := bar_index

if newClosedTo >= newClosedFrom
    for i = newClosedFrom to newClosedTo
        float  cSize    = strategy.closedtrades.size(i)
        bool   cIsLong  = cSize > 0
        float  cPnl     = strategy.closedtrades.profit(i)
        float  cEntry   = strategy.closedtrades.entry_price(i)
        float  cExit    = strategy.closedtrades.exit_price(i)
        int    cEntryBar = strategy.closedtrades.entry_bar_index(i)
        int    cExitBar = strategy.closedtrades.exit_bar_index(i)
        string cComment = strategy.closedtrades.exit_comment(i)
        float  cSl      = cIsLong ? slActiveLong : slActiveShort
        float  cRisk    = strategy.convert_to_account(math.abs(cEntry - nz(cSl, cEntry)) * math.abs(cSize) * syminfo.pointvalue)
        float  cR       = cRisk > 0 ? cPnl / cRisk : na
        float  cMovePct = safeDiv(cExit - cEntry, cEntry) * 100.0 * (cIsLong ? 1.0 : -1.0)
        bool   cIsWin   = cPnl >= 0

        if cEntryBar == cExitBar and cEntryBar != lastEntryBar
            drawEntryLabel(cIsLong, cEntry, cSl, math.abs(cSize))
            lastEntryBar := cEntryBar

        if showExitLabelsInput
            string cReason = cComment == "SL" ? "stop-loss" : str.startswith(cComment, "Time") ? "time exit " + str.tostring(closeHourInput) + ":00" : cComment == "Equity guard" ? "equity guard" : cComment
            string cRStr   = na(cR) ? "" : signedStr(cR, "0.00") + "R · "
            string cText   = (cIsWin ? "✔ " : "✖ ") + signedStr(cPnl, "0.00") + " " + strategy.account_currency + "\n" + cRStr + "move " + signedStr(cMovePct, "0.00") + "%\nExit " + priceStr(cExit) + "\n" + cReason
            label.new(cExitBar, cExit, cText,
                 yloc      = cIsLong ? yloc.abovebar : yloc.belowbar,
                 style     = cIsLong ? label.style_label_down : label.style_label_up,
                 color     = cIsWin ? bullColorInput : bearColorInput,
                 textcolor = cIsWin ? BULL_LABEL_TEXT : BEAR_LABEL_TEXT,
                 size      = labelSize,
                 textalign = text.align_left,
                 tooltip   = "Trade closed\nReason: " + cReason)
        if showTradeBoxInput
            box.new(cEntryBar, math.max(cEntry, cExit), cExitBar, math.min(cEntry, cExit), border_color = color.new(cIsWin ? bullColorInput : bearColorInput, 50), bgcolor = cIsWin ? BULL_BG : BEAR_BG)
            line.new(cEntryBar, cEntry, cExitBar, cExit, color = cIsWin ? BULL_TEXT : BEAR_TEXT, style = line.style_dotted, width = 1)

// Warnings: wrong session hours disable trading; timeframe and chart type only affect range accuracy
var label warnLabel = na
if isLastBar
    string warnHours = not hoursOk ? "Trading is disabled:\n• Hours must satisfy: Range Start < Range End < Close Hour.\n" : ""
    string warnChart = not chart.is_standard ? "• Non-standard chart (Heikin Ashi, Renko…): the range is built from synthetic candles.\n" : ""
    string warnTf    = not tfOk ? "• Timeframe above 1H or not dividing an hour evenly: candles cross the range window.\n" : ""
    string warnNote  = showWarningsInput and (warnChart != "" or warnTf != "") ? "Range may be inaccurate:\n" + warnChart + warnTf : ""
    bool   isSameCorner = showPerfInput and (showDashInput or showMathInput) and perfPosInput == dashPosInput
    string warnLayout = isSameCorner ? "Layout:\n• Dashboard and Performance Chart share the same corner: move one of them.\n" : ""
    string warnText  = warnHours + warnNote + warnLayout
    if warnText != ""
        if na(warnLabel)
            warnLabel := label.new(bar_index, high, warnText, style = label.style_label_down, color = WARN_BG, textcolor = WARN_TEXT, size = size.small, textalign = text.align_left)
        else
            label.set_xy(warnLabel, bar_index, high)

// ══════════════════════════════════════════════════════════
// 11. SL / ENTRY LINES
// ══════════════════════════════════════════════════════════
bool  showLevels = showSlInput and inPos
entryPlot = plot(showLevels ? strategy.position_avg_price : na, "Entry Price", color = ENTRY_COLOR, style = plot.style_linebr, linewidth = 1)
slPlot    = plot(showLevels ? (posLong ? slActiveLong : slActiveShort) : na, "Stop-Loss", color = SL_COLOR, style = plot.style_linebr, linewidth = 2)
fill(entryPlot, slPlot, color = color.new(#FF5252, 88), title = "Risk Zone")

// ══════════════════════════════════════════════════════════
// 12. DASHBOARD
// ══════════════════════════════════════════════════════════
var table dashTable = table.new(
     position     = dashPos,
     columns      = 2,
     rows         = 40,
     bgcolor      = TABLE_BG,
     border_color = TABLE_BORDER,
     border_width = 1,
     frame_color  = TABLE_BORDER,
     frame_width  = 1)

if isLastBar and (showDashInput or showMathInput)
    int    row = 0
    string cur    = " " + strategy.account_currency
    string symCur = " " + syminfo.currency

    if showDashInput
        string trendStr   = not rangeReady ? NO_VALUE : close > rangeHigh ? "Bullish (above range)" : close < rangeLow ? "Bearish (below range)" : "Neutral (inside range)"
        color  trendColor = not rangeReady ? TEXT_COLOR : close > rangeHigh ? BULL_TEXT : close < rangeLow ? BEAR_TEXT : NEUTRAL_TEXT
        string disabledStr = "Disabled (check hours)"
        string signalStr  = not envOk ? disabledStr : isHalted ? "Halted: equity guard" : inPos ? (posLong ? "Long" : "Short") : inRange ? "Building range" : tradedDay == dayKey ? "Done for today" : rangeReady and barHour >= rangeToInput and barHour < closeHourInput ? "Wait breakout" : "Outside session"
        color  signalColor = inPos ? (posLong ? BULL_TEXT : BEAR_TEXT) : isHalted or not envOk ? BEAR_TEXT : TEXT_COLOR
        string widthStr   = rangeReady ? priceStr(rangeHigh - rangeLow) + " (" + str.tostring(safeDiv(rangeHigh - rangeLow, rangeLow) * 100.0, "0.00") + "%)" : NO_VALUE

        row := dashHeader(dashTable, row, "Gold Breakout 15M · " + syminfo.ticker)
        row := dashRow(dashTable, row, "Trend", trendStr, trendColor)
        row := dashRow(dashTable, row, "Signal", signalStr, signalColor)
        row := dashRow(dashTable, row, "Timeframe", timeframe.period + " · " + tzLabel, TEXT_COLOR)
        row := dashRow(dashTable, row, "Session", str.tostring(rangeToInput) + ":00 – " + str.tostring(closeHourInput) + ":00", TEXT_COLOR)
        row := dashRow(dashTable, row, "Range", rangeReady ? priceStr(rangeLow) + " – " + priceStr(rangeHigh) : NO_VALUE, TEXT_COLOR)
        row := dashRow(dashTable, row, "Range width", widthStr, TEXT_COLOR)
        float  openRisk = inPos ? strategy.convert_to_account(math.abs(strategy.position_avg_price - nz(posLong ? slActiveLong : slActiveShort, strategy.position_avg_price)) * math.abs(strategy.position_size) * syminfo.pointvalue) : 0.0
        string openRStr = openRisk > 0 ? " · " + signedStr(strategy.openprofit / openRisk, "0.00") + "R" : ""
        string openStr  = inPos ? signedStr(strategy.openprofit, "0.00") + cur + openRStr : NO_VALUE
        row := dashRow(dashTable, row, "Open P&L", openStr, not inPos ? TEXT_COLOR : strategy.openprofit >= 0 ? BULL_TEXT : BEAR_TEXT)
        row := dashRow(dashTable, row, "Day drawdown (est.)", str.tostring(dayDdPct, "0.00") + "%", guardOnInput and dayDdPct >= guardDdInput ? BEAR_TEXT : TEXT_COLOR)

        float  ozLong      = nz(qtyLong) * syminfo.pointvalue
        float  ozShort     = nz(qtyShort) * syminfo.pointvalue
        float  slPctLong   = safeDiv(riskLong, rangeHigh) * 100.0
        float  slPctShort  = safeDiv(riskShort, rangeLow) * 100.0
        float  slPctMax    = math.max(slPctLong, slPctShort)
        color  riskColor   = slPctMax > 3.0 ? BEAR_TEXT : slPctMax > 1.0 ? NEUTRAL_TEXT : BULL_TEXT
        string slStr       = rangeReady ? priceStr(slLong) + " / " + priceStr(slShort) : NO_VALUE
        string distStr     = rangeReady ? priceStr(riskLong) + " / " + priceStr(riskShort) : NO_VALUE
        string riskPctStr  = rangeReady ? str.tostring(slPctLong, "0.00") + "% / " + str.tostring(slPctShort, "0.00") + "%" : NO_VALUE
        string riskUsdStr  = rangeReady ? str.tostring(riskLong * ozLong, "0.00") + " / " + str.tostring(riskShort * ozShort, "0.00") + symCur : NO_VALUE
        string ozStr       = rangeReady ? str.tostring(ozLong, "0.####") + " / " + str.tostring(ozShort, "0.####") : NO_VALUE
        string lotsStr     = rangeReady and isOunceQuoted ? str.tostring(safeDiv(ozLong, lotOz), "0.####") + " / " + str.tostring(safeDiv(ozShort, lotOz), "0.####") : NO_VALUE
        string notionalStr = rangeReady ? str.tostring(ozLong * rangeHigh, "0") + " / " + str.tostring(ozShort * rangeLow, "0") + symCur : NO_VALUE
        string leverageStr = rangeReady ? "×" + str.tostring(safeDiv(ozLong * rangeHigh, equitySym), "0.00") + " / ×" + str.tostring(safeDiv(ozShort * rangeLow, equitySym), "0.00") : NO_VALUE

        row := dashHeader(dashTable, row, "Position Plan · current range (long / short)")
        row := dashRow(dashTable, row, "SL", slStr, SL_COLOR)
        row := dashRow(dashTable, row, "SL distance", distStr, TEXT_COLOR)
        row := dashRow(dashTable, row, "SL distance, % of price", riskPctStr, rangeReady ? riskColor : TEXT_COLOR)
        row := dashRow(dashTable, row, "Risk amount", riskUsdStr, TEXT_COLOR)
        row := dashRow(dashTable, row, "Size, " + unitLabel, ozStr, TEXT_COLOR)
        row := dashRow(dashTable, row, "Size, lots", lotsStr, TEXT_COLOR)
        row := dashRow(dashTable, row, "Notional", notionalStr, TEXT_COLOR)
        row := dashRow(dashTable, row, "Leverage vs equity", leverageStr, TEXT_COLOR)
        bool   isBelowStep = rangeReady and (qtyLong <= 0 or qtyShort <= 0)
        bool   isCapped    = rangeReady and (isCappedLong or isCappedShort)
        string limitStr    = not rangeReady ? NO_VALUE : isBelowStep ? "Below min step: side skipped" : isCapped ? "Capped by max leverage" : "OK"
        color  limitColor  = not rangeReady ? TEXT_COLOR : isBelowStep ? BEAR_TEXT : isCapped ? NEUTRAL_TEXT : BULL_TEXT
        row := dashRow(dashTable, row, "Size limits", limitStr, limitColor)

    if showMathInput
        float winRate    = tradeCount > 0 ? 100.0 * winCount / tradeCount : na
        float avgWin     = winCount > 0 ? grossWin / winCount : na
        float avgLoss    = lossCount > 0 ? grossLoss / lossCount : na
        float payoff     = not na(avgWin) and not na(avgLoss) and avgLoss > 0 ? avgWin / avgLoss : na
        float profitFactor = grossLoss > 0 ? grossWin / grossLoss : na
        float expectancy = tradeCount > 0 ? (grossWin - grossLoss) / tradeCount : na
        float expectancyR = tradeCount > 0 ? sumR / tradeCount : na
        float breakevenWr = not na(payoff) ? 100.0 / (1.0 + payoff) : na
        float netPct     = safeDiv(strategy.netprofit, strategy.initial_capital) * 100.0

        string tradesStr = str.tostring(tradeCount) + " (" + str.tostring(winCount) + " / " + str.tostring(lossCount) + ")"
        string avgStr    = numStr(avgWin, "0.00") + " / " + numStr(avgLoss, "0.00") + cur
        string expStr    = na(expectancy) ? NO_VALUE : signedStr(expectancy, "0.00") + cur + " · " + signedStr(expectancyR, "0.00") + "R"
        string netStr    = signedStr(strategy.netprofit, "0.00") + cur + " (" + signedStr(netPct, "0.00") + "%)"
        string lastStr   = na(lastPnl) ? NO_VALUE : signedStr(lastPnl, "0.00") + cur + (na(lastR) ? "" : " · " + signedStr(lastR, "0.00") + "R")
        color  wrColor   = na(breakevenWr) or na(winRate) ? TEXT_COLOR : winRate >= breakevenWr ? BULL_TEXT : BEAR_TEXT
        color  pfColor   = na(profitFactor) ? TEXT_COLOR : profitFactor >= 1 ? BULL_TEXT : BEAR_TEXT
        color  expColor  = na(expectancy) ? TEXT_COLOR : expectancy >= 0 ? BULL_TEXT : BEAR_TEXT
        color  lastColor = na(lastPnl) ? TEXT_COLOR : lastPnl >= 0 ? BULL_TEXT : BEAR_TEXT

        row := dashHeader(dashTable, row, "Strategy Math")
        row := dashRow(dashTable, row, "Trades (win / loss)", tradesStr, TEXT_COLOR)
        row := dashRow(dashTable, row, "Win rate", na(winRate) ? NO_VALUE : str.tostring(winRate, "0.0") + "%", wrColor)
        row := dashRow(dashTable, row, "Breakeven win rate", na(breakevenWr) ? NO_VALUE : str.tostring(breakevenWr, "0.0") + "%", TEXT_COLOR)
        row := dashRow(dashTable, row, "Profit factor", numStr(profitFactor, "0.00"), pfColor)
        row := dashRow(dashTable, row, "Avg win / avg loss", avgStr, TEXT_COLOR)
        row := dashRow(dashTable, row, "Payoff (win ÷ loss)", numStr(payoff, "0.00"), TEXT_COLOR)
        row := dashRow(dashTable, row, "Expectancy per trade", expStr, expColor)
        row := dashRow(dashTable, row, "Net profit", netStr, strategy.netprofit >= 0 ? BULL_TEXT : BEAR_TEXT)
        row := dashRow(dashTable, row, "Max equity drawdown (est.)", str.tostring(maxDdPct, "0.00") + "%", TEXT_COLOR)
        row := dashRow(dashTable, row, "Max losing streak", str.tostring(maxLossStreak), TEXT_COLOR)
        row := dashRow(dashTable, row, "Last trade", lastStr, lastColor)

    table.cell(dashTable, 0, row, "Version", text_color = TEXT_MUTED, bgcolor = TABLE_BG, text_size = size.tiny, text_halign = text.align_left)
    table.cell(dashTable, 1, row, STRATEGY_VERSION, text_color = TEXT_MUTED, bgcolor = TABLE_BG, text_size = size.tiny, text_halign = text.align_right)

// ══════════════════════════════════════════════════════════
// 12b. PERFORMANCE CHART
// ══════════════════════════════════════════════════════════
// Cumulative PnL of closed trades, drawn with table cells so it stays fixed on screen.
// X axis is the trade number; each column spans the lowest and highest PnL of its trades.
// It covers the bars loaded on the chart, not the Deep Backtesting range. Redrawn only after a new closed trade.
var table perfTable      = na
var bool  perfMerged     = false
var int   perfDrawnCount = -1
if isLastBar and showPerfInput
    int pCols  = perfColsInput
    int pRows  = perfRowsInput
    int pTop   = 3
    int pDates = pRows + pTop
    if na(perfTable)
        perfTable := table.new(
             position     = perfPos,
             columns      = pCols + 1,
             rows         = pRows + pTop + 1,
             bgcolor      = TABLE_BG,
             border_color = TRANSPARENT,
             border_width = 0,
             frame_color  = TABLE_BORDER,
             frame_width  = 1)

    // ── Key stats ───────────────────────────────
    string pCur      = " " + strategy.account_currency
    float  pNetPct   = safeDiv(strategy.netprofit, strategy.initial_capital) * 100.0
    float  pWinRate  = tradeCount > 0 ? 100.0 * winCount / tradeCount : na
    float  pPf       = grossLoss > 0 ? grossWin / grossLoss : na
    string pPnlStr   = signedStr(strategy.netprofit, "#,##0.00") + pCur + "   " + signedStr(pNetPct, "0.00") + "%"
    string pDdStr    = str.tostring(maxDdMoney, "#,##0.00") + pCur + "   " + str.tostring(maxDdPct, "0.00") + "%"
    string pWinStr   = (na(pWinRate) ? NO_VALUE : str.tostring(pWinRate, "0.00") + "%") + "   " + str.tostring(winCount) + "/" + str.tostring(tradeCount)
    string pPfStr    = numStr(pPf, "0.000")
    color  pPnlColor = strategy.netprofit >= 0 ? BULL_TEXT : BEAR_TEXT

    int pBlock = int(pCols / 4)
    table.cell(perfTable, 0, 0, "Key stats · Cumulative PnL · " + syminfo.ticker + " " + timeframe.period, text_color = HEADER_TEXT, bgcolor = HEADER_BG, text_size = size.small, text_halign = text.align_left)
    table.cell(perfTable, 0,          1, "Total PnL",         text_color = TEXT_MUTED, bgcolor = TABLE_BG, text_size = size.small, text_halign = text.align_left)
    table.cell(perfTable, pBlock,     1, "Max drawdown",      text_color = TEXT_MUTED, bgcolor = TABLE_BG, text_size = size.small, text_halign = text.align_left)
    table.cell(perfTable, pBlock * 2, 1, "Profitable trades", text_color = TEXT_MUTED, bgcolor = TABLE_BG, text_size = size.small, text_halign = text.align_left)
    table.cell(perfTable, pBlock * 3, 1, "Profit factor",     text_color = TEXT_MUTED, bgcolor = TABLE_BG, text_size = size.small, text_halign = text.align_left)
    table.cell(perfTable, 0,          2, pPnlStr, text_color = pPnlColor,  bgcolor = TABLE_BG, text_size = size.normal, text_halign = text.align_left)
    table.cell(perfTable, pBlock,     2, pDdStr,  text_color = TEXT_COLOR, bgcolor = TABLE_BG, text_size = size.normal, text_halign = text.align_left)
    table.cell(perfTable, pBlock * 2, 2, pWinStr, text_color = TEXT_COLOR, bgcolor = TABLE_BG, text_size = size.normal, text_halign = text.align_left)
    table.cell(perfTable, pBlock * 3, 2, pPfStr,  text_color = TEXT_COLOR, bgcolor = TABLE_BG, text_size = size.normal, text_halign = text.align_left)

    int pMid   = int(pRows / 2)
    int pHalf  = int(pCols / 2)
    int pCount = array.size(equityCurve)
    if pCount != perfDrawnCount
        int   pPts   = pCount + 1
        float pMax   = pCount > 0 ? math.max(array.max(equityCurve), 0.0) : 0.0
        float pMin   = pCount > 0 ? math.min(array.min(equityCurve), 0.0) : 0.0
        float pSpan  = pMax - pMin
        int   pZero  = perfLevel(0.0, pMin, pSpan, pRows)
        float pCellW = perfWidthInput / pCols
        float pCellH = perfHeightInput / pRows
        int   pPrevIdx   = -1
        int   pPrevLevel = pZero
        for c = 0 to pCols - 1
            int   pIdx  = math.round(1.0 * c * (pPts - 1) / (pCols - 1))
            float pVal  = pIdx == 0 ? 0.0 : array.get(equityCurve, pIdx - 1)
            float pBMin = pVal
            float pBMax = pVal
            if pIdx - pPrevIdx > 1
                for k = pPrevIdx + 1 to pIdx - 1
                    float pMidVal = k == 0 ? 0.0 : array.get(equityCurve, k - 1)
                    pBMin := math.min(pBMin, pMidVal)
                    pBMax := math.max(pBMax, pMidVal)
            int pLevel  = perfLevel(pVal, pMin, pSpan, pRows)
            int pLineLo = math.min(perfLevel(pBMin, pMin, pSpan, pRows), pPrevLevel)
            int pLineHi = math.max(perfLevel(pBMax, pMin, pSpan, pRows), pPrevLevel)
            for r = 0 to pRows - 1
                int   pH      = pRows - 1 - r
                bool  pIsLine = pH >= pLineLo and pH <= pLineHi
                color pColor  = pIsLine ? (pVal >= 0 ? BULL_TEXT : BEAR_TEXT) : (pH >= pZero and pH < pLineLo) ? PERF_FILL_UP : (pH <= pZero and pH > pLineHi) ? PERF_FILL_DN : TRANSPARENT
                table.cell(perfTable, c, r + pTop, "", width = pCellW, height = pCellH, bgcolor = pColor, text_size = size.tiny)
            pPrevIdx   := pIdx
            pPrevLevel := pLevel

        string pMaxStr = signedStr(pMax, "#,##0")
        string pMinStr = signedStr(pMin, "#,##0")
        table.cell(perfTable, pCols, pTop,        pMaxStr, text_color = TEXT_MUTED, bgcolor = TABLE_BG, text_size = size.small, text_halign = text.align_left, text_valign = text.align_top)
        table.cell(perfTable, pCols, pTop + pMid, pMinStr, text_color = TEXT_MUTED, bgcolor = TABLE_BG, text_size = size.small, text_halign = text.align_left, text_valign = text.align_bottom)
        perfDrawnCount := pCount

    string pFromStr = na(firstTradeTime) ? "No closed trades yet" : str.format_time(firstTradeTime, "yyyy-MM-dd", syminfo.timezone) + "  ·  closed trades, x = trade #"
    string pToStr   = na(lastTradeTime) ? "" : str.format_time(lastTradeTime, "yyyy-MM-dd", syminfo.timezone)
    table.cell(perfTable, 0,     pDates, pFromStr, text_color = TEXT_MUTED, bgcolor = TABLE_BG, text_size = size.small, text_halign = text.align_left)
    table.cell(perfTable, pHalf, pDates, pToStr,   text_color = TEXT_MUTED, bgcolor = TABLE_BG, text_size = size.small, text_halign = text.align_right)

    if not perfMerged
        table.merge_cells(perfTable, 0, 0, pCols, 0)
        table.merge_cells(perfTable, 0,          1, pBlock - 1,     1)
        table.merge_cells(perfTable, pBlock,     1, pBlock * 2 - 1, 1)
        table.merge_cells(perfTable, pBlock * 2, 1, pBlock * 3 - 1, 1)
        table.merge_cells(perfTable, pBlock * 3, 1, pCols,          1)
        table.merge_cells(perfTable, 0,          2, pBlock - 1,     2)
        table.merge_cells(perfTable, pBlock,     2, pBlock * 2 - 1, 2)
        table.merge_cells(perfTable, pBlock * 2, 2, pBlock * 3 - 1, 2)
        table.merge_cells(perfTable, pBlock * 3, 2, pCols,          2)
        table.merge_cells(perfTable, pCols, pTop,        pCols, pTop + pMid - 1)
        table.merge_cells(perfTable, pCols, pTop + pMid, pCols, pTop + pRows - 1)
        table.merge_cells(perfTable, 0,     pDates, pHalf - 1, pDates)
        table.merge_cells(perfTable, pHalf, pDates, pCols,     pDates)
        perfMerged := true

// ══════════════════════════════════════════════════════════
// 13. WATERMARK
// ══════════════════════════════════════════════════════════
bool isWmBlocked = showPerfInput and perfPosInput == "Bottom Center"
if isLastBar and showWatermarkInput and not isWmBlocked
    var wmTable = table.new(
         position     = position.bottom_center,
         columns      = 1,
         rows         = 1,
         bgcolor      = TRANSPARENT,
         border_color = TRANSPARENT,
         border_width = 0,
         frame_color  = TRANSPARENT,
         frame_width  = 0)
    table.cell(wmTable, 0, 0, "WillyAlgoTrader",
         text_color  = WM_COLOR,
         text_size   = size.normal,
         text_halign = text.align_center,
         bgcolor     = TRANSPARENT)

// ══════════════════════════════════════════════════════════
// 14. ALERTS
// ══════════════════════════════════════════════════════════
// Alert messages are attached to the orders in section 8 and are sent when an order is filled.
// This block only previews the four templates in Pine Logs.
if showPreviewInput and barstate.islastconfirmedhistory
    float pvHigh = nz(rangeHigh, close)
    float pvLow  = nz(rangeLow, close)
    float pvSlL  = nz(slLong, pvHigh * 0.99)
    float pvSlS  = nz(slShort, pvLow * 1.01)
    log.info("LONG ENTRY → "  + maskSecret(fillTemplate(tplLongIn,   true,  "entry", "breakout", pvHigh, pvHigh, pvSlL, nz(qtyLong, 1.0),  pvHigh, pvLow, idPlan, equitySym)))
    log.info("SHORT ENTRY → " + maskSecret(fillTemplate(tplShortIn,  false, "entry", "breakout", pvLow,  pvLow,  pvSlS, nz(qtyShort, 1.0), pvHigh, pvLow, idPlan, equitySym)))
    log.info("LONG EXIT → "   + maskSecret(fillTemplate(tplLongOut,  true,  "exit",  "time",     close,  pvHigh, pvSlL, nz(qtyLong, 1.0),  pvHigh, pvLow, idPlan, equitySym)))
    log.info("SHORT EXIT → "  + maskSecret(fillTemplate(tplShortOut, false, "exit",  "time",     close,  pvLow,  pvSlS, nz(qtyShort, 1.0), pvHigh, pvLow, idPlan, equitySym)))
````
