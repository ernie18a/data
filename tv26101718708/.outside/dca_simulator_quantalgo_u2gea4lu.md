# DCA Simulator [QuantAlgo]

- url: https://www.tradingview.com/script/U2geA4LU-DCA-Simulator-QuantAlgo/
- type: indicator
- pine_id: PUB;d82d57a6b6af439ea33fe4b5d0d8fc9b
- version: 1.0

## Description

[b]🟢 Overview[/b]

The [b]DCA Simulator[/b] is a comprehensive dollar-cost averaging tool built for investors who want to see how a recurring buy strategy would have performed on any chart. It places scheduled buys at a chosen frequency and point in each period, can scale each buy by how far price sits from its long-term average, and applies configurable fees and slippage to every fill. A dashboard then tracks the average cost, return, and max drawdown of the DCA strategy and compares it with a single lump sum and a fixed amount DCA on the same schedule. Whether you accumulate crypto around the clock or build equity positions on a weekday schedule, the indicator turns a recurring plan into measurable results directly on the chart.
[image]https://www.tradingview.com/x/bDdVFZCJ/[/image]
[b]🟢 What is Dollar-Cost Averaging?[/b]

Dollar-cost averaging (DCA) invests a set amount at regular intervals regardless of price. Because the amount stays constant, each buy collects more units when price is low and fewer when it is high, so the average cost per unit lands at or below the simple average of the buy prices. Spreading entries across time also removes the need to pick a single entry point, which makes DCA a widely used way to build long-term positions. A valuation-weighted variant keeps the fixed schedule but buys more when price sits well below its long-term average and less when it is stretched above it, tilting capital toward periods when price is cheap relative to its own history. How either approach compares with investing everything at once depends on the path price takes, which is why the simulator measures all of them side by side.
[image]https://www.tradingview.com/x/jokl9jrt/[/image]
[b]🟢 Key Features[/b]

[b]▶ Flexible Buy Schedule[/b]

Frequency sets how often the DCA strategy buys:

[b]1. Daily[/b] buys once a day.

[b]2. Weekly [/b]buys once a week.

[b]3. Bi-Weekly[/b] buys once every two weeks.

[b]4. Monthly[/b] buys once a month.

[b]5. Quarterly[/b] buys once every three months.

Each of these spans is one period, and two schedule anchors decide how the periods line up.

Calendar keeps every buy on calendar weeks and months, starting with the first period that begins on or after the start date. Bi-Weekly and Quarterly count from that first week or month, so Quarterly lines up with calendar quarters when that first month is January, April, July, or October.

Start Date counts every period from the first bar on or after the chosen date, so buys repeat on that day, such as every Wednesday or the 15th of every month. This works the same way a recurring buy repeats from the day it is set up. When that day is the 29th, 30th, or 31st, shorter months use their last day. A scheduled day without a bar, such as a weekend or holiday on markets that close, moves to the next available bar.

Buy Timing places every buy at the start or the end of its period. Start of Period fills at the open of the period's first bar, the moment the period begins. End of Period fills at the close of the period's last bar and records the buy as the next period opens, since a bar is only known to be the last of its period once the next one starts. On markets that trade around the clock, one period's close and the next period's open are nearly the same price, so the two timings differ mainly by a one-period shift. Markets with overnight or weekend gaps separate them.
[image]https://www.tradingview.com/x/vsQ9U2LK/[/image]
[b]▶ Valuation Weighting[/b]

Mode chooses between two ways of sizing each buy. Fixed Amount invests the same base amount every time. Valuation Weighted scales each buy by how stretched price is compared with its own history.

To do this, Valuation Weighted measures the log distance between price and its moving average and divides it by the root mean square of that distance over the same window to form a z-score. It then multiplies the base amount by one minus Weight Sensitivity times that z-score, held between Min Weight and Max Weight. Buys at the start of a period read the valuation at the prior close, and buys at the end read it at their own close, so every buy is sized only with information available at that moment.

[b]1. Valuation Length:[/b] Sets the window behind both the moving average and the typical distance from it. Shorter lengths judge value against the recent trend, while longer lengths judge it against a broader cycle.

[b]2. Weight Sensitivity:[/b] Controls how strongly the z-score moves each buy. A buy placed exactly at the average uses the base amount, and higher values reach the minimum and maximum weights more often.

[b]3. Min Weight:[/b] Sets the smallest multiple of the base amount. At zero, buys are skipped entirely once price is stretched far enough above its average, while the fixed amount benchmark keeps buying on those dates.

[b]4. Max Weight:[/b] Caps how large a single buy can grow during deep discounts, keeping the capital committed to any one buy within a set limit.
[image]https://www.tradingview.com/x/hzITa3Tk/[/image]
[b]▶ Performance Dashboard[/b]

The dashboard summarizes the DCA strategy in a single table that can be placed in any of nine chart positions.

[b]1. Start Date:[/b] The first chart bar on or after the start date setting.

[b]2. Buys:[/b] The number of executed buys, excluding any skipped by valuation.

[b]3. Total Invested:[/b] All cash put in, fees included.

[b]4. Units Held:[/b] The quantity accumulated so far.

[b]5. Average Cost:[/b] The average price paid per unit, with every cost included.

[b]6. Current Value:[/b] The holdings marked at the latest price.

[b]7. Return:[/b] The gain or loss on the total invested.

[b]8. Max Drawdown:[/b] The deepest decline the DCA strategy has held through.

[b]9. Lump Sum Return:[/b] The result of investing the same total all at once at the first buy's price.

[b]10. Fixed DCA Return: [/b]The result of buying the base amount on every scheduled date, the benchmark for Valuation Weighted mode.

[b]11. Next Weight:[/b] The weight and z-score a buy would use at the latest close.

Units are fractional, and current value is marked before any selling fee.
[image]https://www.tradingview.com/x/MtJGUYAh/[/image]
[b]▶ Max Drawdown Tracking[/b]

Max Drawdown records the deepest point the DCA strategy has held through since its first buy, with three controls that define how it is measured.

[b]1. Drawdown Basis:[/b] Below Cost measures the fall of the holdings below the total invested. From Peak measures the fall from the highest value reached, with every later buy added to that peak, so gains given back also count.

[b]2. Drawdown Data:[/b] Confirmed counts completed bars only, while Live also updates the figure on the forming bar as price develops.

[b]3. Count Wicks:[/b] Adds each bar's open, low, and high to its close and values every price against the position held at that moment. A bar's high is never paired with its own low, since their order inside the bar is unknown.
[image]https://www.tradingview.com/x/0wgGLwgl/[/image]
[b]▶ Fees and Slippage[/b]

Two fee modes cover the common ways a purchase is billed:

[b]1. Deducted From Order[/b] takes the fee out of the buy, so each buy costs exactly its amount and receives fewer units. This works out the same whether the fee comes from the amount spent or from the coins received.

[b]2. Added On Top[/b] puts the full amount into the order and charges the fee separately, as when it is paid with a fee token or billed on top in the quote currency.

Slippage raises every fill price by a set percentage to account for the spread and movement during execution. Both costs flow through the average cost and returns. The lump sum and fixed amount comparisons pay the same fee and slippage, so every figure is measured on equal terms.
[image]https://www.tradingview.com/x/UMjacZ8P/[/image]
[b]▶ Average Cost Line and Buy Markers[/b]

A step line traces the running average cost, with a label at the latest bar, and each can be shown on its own. Price above the line means the DCA strategy is in profit, and price below it means the DCA strategy sits below its cost basis. Triangle markers print below every executed buy. In Valuation Weighted mode each marker is shaded by the weight of its buy, so heavier buying during discounts stands out at a glance, and skipped buys print no marker.
[image]https://www.tradingview.com/x/4HUq3N07/[/image]
[b]▶ Built-in Alerts[/b]

Six ready-made alert conditions cover every key event in the DCA strategy, and buy alerts can fire as soon as each buy is recorded.

[b]1. Scheduled Buy:[/b] Fires on every executed buy.

[b]2. Increased Buy:[/b] Fires when a buy uses more than the base amount in Valuation Weighted mode.

[b]3. Reduced Buy:[/b] Fires when a buy uses less than the base amount in Valuation Weighted mode.

[b]4. Skipped Buy:[/b] Fires when a scheduled buy is skipped because its valuation weight reached zero.

[b]5. Return Turned Positive:[/b] Fires when price closes above the average cost and the return turns positive.

[b]6. Return Turned Negative:[/b] Fires when price closes below the average cost and the return turns negative.

The Any alert() function call option also delivers a detailed message with the symbol, amount, price, and weight of each executed buy, along with the z-score of each skipped one.
[image]https://www.tradingview.com/x/o4NPcRrV/[/image]
[b]▶ Visual Customization[/b]

Six color presets (Classic, Aqua, Cosmic, Cyber, Neon, Custom) set the buy marker and negative return colors across the chart and dashboard, and Custom mode exposes individual color pickers. The average cost line, its label, and its dashboard figure keep their own color under every preset so the cost basis stays easy to spot. The label text switches between dark and light automatically to stay readable on any chosen color. Text size is adjustable from Tiny to Large for both the average cost label and the dashboard, suiting anything from a compact chart layout to presentations and screen recordings.
[image]https://www.tradingview.com/x/soeECK9X/[/image]
[b]▶ Timeframe Warning[/b]

With the Calendar anchor, each frequency is designed for these chart timeframes:

[b]1. Daily:[/b] one day or lower.

[b]2. Weekly and Bi-Weekly:[/b] one week or lower.

[b]3. Monthly and Quarterly:[/b] one month or lower.

This lets long histories run on weekly and monthly charts. With the Start Date anchor, every frequency is designed for chart timeframes of one day or lower, since its scheduled days fall inside weekly and monthly bars. When the chart timeframe is higher, a warning box in the center of the chart shows the timeframe the chosen settings are designed for, so the simulation always runs on bars that match its schedule. All prices come from the chart's own bars, so the simulation is designed for standard bar and candle charts.
[image]https://www.tradingview.com/x/UbGZTyBC/[/image]

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator("DCA Simulator [QuantAlgo]", overlay = true)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string plan_settings      = "════════ Plan Settings ════════"
var string valuation_settings = "════════ Valuation Settings ════════"
var string visual_settings    = "════════ Visualization Settings ════════"

tooltip_start        = "Date from which the scheduled buys begin. Under the Calendar anchor, buys cover every period that begins on or after this date, so a date partway through a day, week, or month starts the schedule with the next full period. Under the Start Date anchor, the first period begins at the first chart bar on or after this date. Bars before this date still feed the moving average and deviation behind the valuation z-score, so when enough history sits before the start date, the Valuation Weighted mode sizes its first buys from a complete reading. When the chart history begins after this date, the DCA strategy starts from the first bars loaded on the chart. The dashboard totals and returns, including the lump sum and fixed amount comparisons, cover only the buys made on or after this date."
tooltip_frequency    = "How often a scheduled buy is placed, which also sets the period each buy belongs to: Daily buys once a day, Weekly once a week, Bi-Weekly once every two weeks, Monthly once a month, and Quarterly once every three months. Schedule Anchor sets whether those periods follow the calendar or count from the start date, and Buy Timing sets whether each buy lands at the start or end of its period. Under the Calendar anchor, Bi-Weekly and Quarterly count from the first week or month that begins on or after the start date, so Quarterly lines up with calendar quarters when its first counted month is January, April, July, or October. Daily places the most buys and spreads entries most evenly across price swings, while Quarterly places the fewest and mirrors a DCA strategy funded once per quarter. The Amount per Buy is the same at every frequency, so a higher frequency invests a larger total over the same period. Under the Calendar anchor the frequencies are designed for chart timeframes up to one day for Daily, one week for Weekly and Bi-Weekly, and one month for Monthly and Quarterly, and under the Start Date anchor for chart timeframes of one day or lower. On a higher timeframe the simulation pauses and a notice in the center of the chart names the timeframe the chosen settings run on. Every executed buy fires the Scheduled Buy alert and every skipped buy fires the Skipped Buy alert on the bar where the buy is recorded, as that bar opens with the Once Per Bar frequency or at its close with Once Per Bar Close, while the Any alert() function call option fires as that bar opens and carries the symbol, amount, price, and weight of each executed buy in its message, along with the z-score of each skipped one."
tooltip_anchor       = "Where the schedule counts its periods from. Calendar follows calendar days, weeks, and months, beginning with the first period that starts on or after the start date, so Weekly buys in every calendar week and Monthly in every calendar month, and it runs on chart timeframes up to the period length, including weekly and monthly charts. Start Date counts every period from the first chart bar on or after the start date, so Weekly and Bi-Weekly repeat on that day of the week and Monthly and Quarterly on that day of the month, the same way a recurring buy repeats from the day it is set up. When that day is the 29th, 30th, or 31st, shorter months use their last day, and a scheduled day without a bar, such as a weekend or holiday on markets that close, moves to the next available bar. Start Date runs on chart timeframes of one day or lower, since its scheduled days fall inside weekly and monthly bars. Buy Timing then places each buy at the start or end of its period under either anchor."
tooltip_timing       = "Where inside each period the scheduled buy executes. The period is the span one buy covers under Frequency: a day for Daily, a week for Weekly, two weeks for Bi-Weekly, a month for Monthly, and three months for Quarterly, counted as set by Schedule Anchor. Start of Period buys at the open of the period's first bar, the moment the period begins, such as the open of each week's first bar for Weekly or each month's first bar for Monthly. End of Period buys at the close of the period's last bar, such as the close of each week's last bar for Weekly or each month's last bar for Monthly, and records the buy as the next period opens, since a bar is only known to be the last of its period once the next period begins, with the marker printed on that last bar. Buys at the start are sized from the valuation at the prior close, and buys at the end from the valuation at their own closing price. On markets that trade around the clock, the close of one period and the open of the next are nearly the same price, so End of Period differs from Start of Period mainly by a one-period shift, while markets with overnight or weekend gaps separate the two."
tooltip_amount       = "Base amount of each scheduled buy, in the quote currency of the chart symbol, such as USD on BTCUSD or USDT on BTCUSDT. In Fixed Amount mode every buy uses exactly this amount. In Valuation Weighted mode each buy uses this amount multiplied by its weight, so it sets the reference size that the weight scales up or down. Fee Mode sets whether the fee comes out of this amount or is paid on top of it. The amount scales Total Invested, Units Held, and Current Value in the dashboard, while the average cost and every return depend only on the prices, weights, fees, and slippage of the buys."
tooltip_fee          = "Trading fee charged on each buy, as a percentage of its amount, applied as set by Fee Mode. The fee raises the average cost and reduces every return in the dashboard, including the lump sum and fixed amount comparisons, which pay the same rate. Lower values (0-0.1) reflect commission-free or low-cost exchange trading. Higher values (0.5-1.5) model platforms with higher per-purchase charges."
tooltip_fee_mode     = "How the fee is applied to each buy. Deducted From Order takes the fee out of the buy itself, whether from the amount spent or from the coins received, which work out the same, so each buy costs exactly its amount and receives fewer units. Added On Top puts the full amount into the order and charges the fee separately, as when it is paid with a fee token or billed on top in the quote currency, so each buy receives the full units and costs its amount plus the fee. The fee therefore shows as fewer Units Held in the first mode and as a higher Total Invested in the second, while the average cost, returns, lump sum, and fixed amount comparison all follow the selected mode."
tooltip_slippage     = "Price slippage on each buy, as a percentage above the scheduled price. Each buy fills at the open or close set by Buy Timing plus this percentage, covering the spread and any movement between the scheduled moment and the actual fill, so it lowers the units each buy receives and raises the average cost. The lump sum and fixed amount comparisons fill with the same slippage. Lower values (0-0.05) reflect deep, liquid markets and small orders. Higher values (0.2-0.5) model thinner markets, wider spreads, or orders that are large for the available liquidity."
tooltip_mode         = "Fixed Amount uses the same Amount per Buy for every scheduled buy, the classic form of DCA. Valuation Weighted scales each buy by how far price sits from its long-term average, spending more when price is below the average and less when it is above, so more units are accumulated at lower prices and fewer at higher ones. Each weighted buy is sized from the latest valuation available when it executes, as set out under Buy Timing. The dashboard compares the DCA strategy with a lump sum of the same total and with a fixed amount DCA on the same schedule, which matches the DCA strategy in Fixed Amount mode and serves as its benchmark in Valuation Weighted mode. The Increased Buy, Reduced Buy, and Skipped Buy alerts respond to the weight of each buy, so they fire only in Valuation Weighted mode."
tooltip_length       = "Number of chart bars used for both the moving average and the deviation window behind the valuation z-score. The z-score is the log distance of price from its moving average divided by the root mean square of that distance over the same window, so it measures how far price sits from the average compared with how far it has typically sat, rather than by a fixed percentage. Shorter lengths (50-100) judge value against the recent trend, so weights shift more often. Longer lengths (300-500) judge value against a longer cycle, so weights shift more gradually. The window is counted in chart bars, so the same length spans a longer period on higher timeframes. The first z-score needs roughly twice this many bars of history, and buys placed before it is available use the base amount. Only affects buy sizes when Mode is set to Valuation Weighted."
tooltip_sensitivity  = "How strongly the valuation z-score changes the size of each buy. The weight equals one minus this sensitivity times the z-score, then held between Min Weight and Max Weight, so a buy placed exactly at the average uses the base amount. A sensitivity of 1.0, for example, doubles a buy at a z-score of -1 and halves it at a z-score of +0.5. Lower values (0.1-0.3) keep buys close to the base amount, so the DCA strategy tracks a fixed amount DCA more closely. Higher values (0.8-1.5) make buys swing sharply with valuation and reach Min Weight and Max Weight more often. A value of zero holds every buy at the base amount, within the Min Weight and Max Weight limits. Only used when Mode is set to Valuation Weighted."
tooltip_min_weight   = "Smallest multiple of the base amount that a single buy can use. At zero, a scheduled buy is skipped entirely once price is stretched far enough above its average for the weight to reach zero, which happens when the z-score reaches one divided by Weight Sensitivity. Skipped buys print no marker and do not count toward Buys or Total Invested, while the fixed amount comparison still buys on those dates. Values above zero, such as 0.25 or 0.5, keep a smaller buy running in place of a skip, so the DCA strategy never stops accumulating. If Min Weight is set above Max Weight, the two limits swap, so every buy still stays between them. Only used when Mode is set to Valuation Weighted."
tooltip_max_weight   = "Largest multiple of the base amount that a single buy can use. It caps how far a buy can grow when price falls well below its average, which limits how much capital a deep drawdown can absorb in a single buy. Lower values (1.5-2.0) keep spending closer to a steady budget. Higher values (4.0-5.0) commit more capital to deep discounts. Only used when Mode is set to Valuation Weighted."
tooltip_color_preset = "Pre-configured color schemes for different chart themes and visual preferences. Classic uses traditional green and red. Aqua provides ocean-inspired blue and orange. Cosmic offers futuristic cyan and purple. Cyber features cool cyan and warm orange contrast. Neon delivers high-contrast yellow and magenta for maximum visibility. Each preset sets the buy marker and negative return colors, while Custom uses the Buy Marker Color and Negative Return Color set below. The Average Cost Color applies under every preset."
tooltip_buy_color    = "Color applied to the buy markers and to the Return figure in the dashboard when it is zero or positive. Use a vibrant color to highlight accumulation and gains. Only used when Color Preset is set to Custom."
tooltip_loss_color   = "Color applied to the Return figure in the dashboard when it is negative, meaning the DCA strategy's current value sits below its total invested, and to the Max Drawdown figure once it falls below zero. Use a warning color to highlight drawdowns in the DCA strategy. Only used when Color Preset is set to Custom."
tooltip_cost_color   = "Color applied to the average cost line, its label, and the Average Cost figure in the dashboard. It applies under every Color Preset, so the cost basis keeps one consistent color while the buy marker and return colors follow the preset."
tooltip_cost_line    = "Enable/disable the average cost line and its label, each on its own. The line is a step line at the running average price paid per unit, fees and slippage included, and steps to a new level with each buy, so price above it means the DCA strategy is in profit and price below it means the DCA strategy is at a loss. The label sits on the latest bar at the average cost level, filled in the Average Cost Color, and reads the current average cost, so it can mark the level with or without the line. A close across this level fires the Return Turned Positive and Return Turned Negative alerts, whether or not the line or label is shown. Disable both for a cleaner chart that relies on the dashboard alone."
tooltip_markers      = "Enable/disable the triangle markers printed below each bar where a scheduled buy executes. In Fixed Amount mode every marker is solid. In Valuation Weighted mode each marker is shaded by the weight of its buy, fainter for smaller buys and stronger for larger ones, reaching full strength at about 2.8 times the base amount, so heavier buying during discounts stands out. Skipped buys print no marker. Disable for an uncluttered chart where the average cost line, dashboard, or alerts track the buys instead."
tooltip_dashboard    = "Enable/disable the dashboard, which lists the start date, number of buys, total invested, units held, average cost, current value, return, and max drawdown of the simulated DCA strategy, with the drawdown measured as set by Drawdown Basis, Drawdown Data, and Count Wicks. It also compares the return with investing the same total as a single lump sum at the price of the first executed buy, and with a fixed amount DCA on the same schedule. The start date is the first chart bar on or after the Start Date setting, which falls later than the setting when that date has no bar of its own, such as a non-trading day or a date before the loaded chart history. The last row shows the weight a buy would use at the latest close, along with its z-score, as a preview of the next scheduled buy."
tooltip_dd_basis     = "How the Max Drawdown figure in the dashboard measures the worst stretch the DCA strategy has held through, from its first buy to the latest bar, using the bars and prices set by Drawdown Data and Count Wicks. Below Cost measures how far the DCA strategy's value has fallen below its total invested, with fees and slippage counted as costs, so it reads the deepest unrealized loss against the money put in. From Peak measures how far the DCA strategy's value has fallen from its highest point, with every later buy added to that peak, so it also counts gains given back while the DCA strategy is still in profit and always reads at least as deep as Below Cost. Only applies when Show Dashboard is turned on."
tooltip_dd_data      = "Which bars the Max Drawdown figure counts. Confirmed counts completed bars only, so the figure holds steady while a bar forms and updates once it closes. Live also counts the forming bar as price develops, so the figure can deepen before the close. With Count Wicks disabled, a dip on the forming bar that recovers before the close drops back out once the bar completes, since only the close is kept, while with Count Wicks enabled the bar's low keeps it. Only applies when Show Dashboard is turned on."
tooltip_dd_wicks     = "Enable/disable counting prices inside each bar in the Max Drawdown figure, alongside its close. When enabled, the DCA strategy is also valued at each bar's open, low, and high, so gaps and wicks count toward the drawdown, with the high only raising the From Peak peak. Each price is valued against the position held at that moment, so a buy at the start of a period joins from its open onward, and a buy at the end joins from its closing price onward. A bar's high is never paired with its own low, since their order inside the bar is unknown. When disabled, the DCA strategy is valued at closes only, so a bar that recovers from its low before closing counts at its close. Only applies when Show Dashboard is turned on."
tooltip_dash_pos     = "Position on the chart where the dashboard is anchored, covering every corner, the middle of each edge, and the center. Tables from other indicators placed at the same position overlap with it. Only applies when Show Dashboard is turned on."
tooltip_text_size    = "Text size for the average cost label, every row and figure in the dashboard, and the timeframe notice. Tiny and Small keep them compact beside price action, while Normal and Large suit presentation and screen recording."

int startInput          = input.time(timestamp("2020-01-01 00:00 +0000"), "Start Date", group = plan_settings, tooltip = tooltip_start)
string freqInput        = input.string("Weekly", "Frequency", group = plan_settings, options = ["Daily", "Weekly", "Bi-Weekly", "Monthly", "Quarterly"], tooltip = tooltip_frequency)
string anchorInput      = input.string("Calendar", "Schedule Anchor", group = plan_settings, options = ["Calendar", "Start Date"], tooltip = tooltip_anchor)
string timingInput      = input.string("Start of Period", "Buy Timing", group = plan_settings, options = ["Start of Period", "End of Period"], tooltip = tooltip_timing)
float amountInput       = input.float(100.0, "Amount per Buy", group = plan_settings, minval = 1.0, step = 10.0, tooltip = tooltip_amount)
float feeInput          = input.float(0.1, "Fee (%)", group = plan_settings, minval = 0.0, maxval = 100.0, step = 0.05, tooltip = tooltip_fee)
string feeModeInput     = input.string("Deducted From Order", "Fee Mode", group = plan_settings, options = ["Deducted From Order", "Added On Top"], tooltip = tooltip_fee_mode)
float slipInput         = input.float(0.1, "Slippage (%)", group = plan_settings, minval = 0.0, maxval = 100.0, step = 0.01, tooltip = tooltip_slippage)

string modeInput        = input.string("Fixed Amount", "Mode", group = valuation_settings, options = ["Fixed Amount", "Valuation Weighted"], tooltip = tooltip_mode)
int maLenInput          = input.int(200, "Valuation Length", group = valuation_settings, minval = 10, maxval = 2000, tooltip = tooltip_length)
float sensInput         = input.float(0.5, "Weight Sensitivity", group = valuation_settings, minval = 0.0, step = 0.05, tooltip = tooltip_sensitivity)
float minMultInput      = input.float(0.0, "Min Weight", group = valuation_settings, minval = 0.0, step = 0.1, tooltip = tooltip_min_weight)
float maxMultInput      = input.float(3.0, "Max Weight", group = valuation_settings, minval = 0.1, step = 0.1, tooltip = tooltip_max_weight)

string colorPreset      = input.string("Custom", "Color Preset", group = visual_settings, options = ["Custom", "Classic", "Aqua", "Cosmic", "Cyber", "Neon"], tooltip = tooltip_color_preset)
color buyColorInput     = input.color(#00ffaa, "Buy Marker Color", group = visual_settings, tooltip = tooltip_buy_color)
color lossColorInput    = input.color(#ff0000, "Negative Return Color", group = visual_settings, tooltip = tooltip_loss_color)
color costColorInput    = input.color(#f0b90b, "Average Cost Color", group = visual_settings, tooltip = tooltip_cost_color)
bool costLineInput      = input.bool(true, "Show Average Cost", group = visual_settings, inline = "cost")
bool costLabelInput     = input.bool(true, "Show Label", group = visual_settings, inline = "cost", tooltip = tooltip_cost_line)
bool markersInput       = input.bool(true, "Show Buy Markers", group = visual_settings, tooltip = tooltip_markers)
bool tableInput         = input.bool(true, "Show Dashboard", group = visual_settings, tooltip = tooltip_dashboard)
string ddBasisInput     = input.string("Below Cost", "Drawdown Basis", group = visual_settings, options = ["Below Cost", "From Peak"], tooltip = tooltip_dd_basis)
string ddDataInput      = input.string("Confirmed", "Drawdown Data", group = visual_settings, options = ["Confirmed", "Live"], tooltip = tooltip_dd_data)
bool ddWicksInput       = input.bool(false, "Count Wicks", group = visual_settings, tooltip = tooltip_dd_wicks)
string tablePosInput    = input.string("Bottom Right", "Dashboard Position", group = visual_settings, options = ["Top Left", "Top Center", "Top Right", "Middle Left", "Middle Center", "Middle Right", "Bottom Left", "Bottom Center", "Bottom Right"], tooltip = tooltip_dash_pos)
string textSizeInput    = input.string("Small", "Text Size", group = visual_settings, options = ["Tiny", "Small", "Normal", "Large"], tooltip = tooltip_text_size)

//              ╔════════════════════════════════╗              //
//              ║      PRESET CONFIGURATION      ║              //
//              ╚════════════════════════════════╝              //

[buyCol, lossCol] = switch colorPreset
    "Classic" => [#00ff00, #ff0000]
    "Aqua" => [#00d4ff, #ff8c00]
    "Cosmic" => [#49ffce, #9932cc]
    "Cyber" => [#00cccc, #ff6600]
    "Neon" => [#ffff00, #ff00ff]
    => [buyColorInput, lossColorInput]

string textSize = switch textSizeInput
    "Tiny"   => size.tiny
    "Normal" => size.normal
    "Large"  => size.large
    => size.small

//              ╔════════════════════════════════╗              //
//              ║        VALUATION ENGINE        ║              //
//              ╚════════════════════════════════╝              //

float lnDev    = math.log(close) - math.log(ta.sma(close, maLenInput))
float devRms   = math.sqrt(ta.sma(lnDev * lnDev, maLenInput))
float zVal     = not na(devRms) and devRms > 0 ? lnDev / devRms : na
float weightLo = math.min(minMultInput, maxMultInput)
float weightHi = math.max(minMultInput, maxMultInput)
float weight   = modeInput == "Fixed Amount" or na(zVal) ? 1.0 : math.max(math.min(1.0 - sensInput * zVal, weightHi), weightLo)

//              ╔════════════════════════════════╗              //
//              ║           DCA ENGINE           ║              //
//              ╚════════════════════════════════╝              //

string freqTf    = freqInput == "Weekly" or freqInput == "Bi-Weekly" ? "W" : freqInput == "Monthly" or freqInput == "Quarterly" ? "M" : "D"
int freqStep     = freqInput == "Bi-Weekly" ? 2 : freqInput == "Quarterly" ? 3 : 1
bool fromStart   = anchorInput == "Start Date"
bool tfSupported = timeframe.isticks or timeframe.in_seconds() <= timeframe.in_seconds(fromStart ? "D" : freqTf)
bool newPeriod   = timeframe.change(freqTf)
bool inRange     = time >= startInput

int tdRef     = time_tradingday + 43200000
int tdYear    = year(tdRef, syminfo.timezone)
int tdMonth   = month(tdRef, syminfo.timezone)
int tdDom     = dayofmonth(tdRef, syminfo.timezone)
int tdNum     = math.floor(timestamp("UTC", tdYear, tdMonth, tdDom, 0, 0, 0) / 86400000.0)
int monthDays = math.round((timestamp("UTC", tdMonth == 12 ? tdYear + 1 : tdYear, tdMonth == 12 ? 1 : tdMonth + 1, 1, 0, 0, 0) - timestamp("UTC", tdYear, tdMonth, 1, 0, 0, 0)) / 86400000.0)

var int planStart   = na
var int anchorNum   = na
var int anchorMonth = na
var int anchorDom   = na
var int anchorLast  = na
var int periodCount = 0
var bool endPending = false
bool windowStart    = false
bool buyBar         = false
float fillPrice     = open

if inRange and na(planStart)
    planStart   := time
    anchorNum   := tdNum
    anchorMonth := tdYear * 12 + tdMonth - 1
    anchorDom   := tdDom

int monthsIn   = tdYear * 12 + tdMonth - 1 - nz(anchorMonth)
int monthsDone = tdDom >= math.min(nz(anchorDom), monthDays) ? monthsIn : monthsIn - 1
int anchorIdx  = freqTf == "M" ? math.floor(monthsDone / (1.0 * freqStep)) : math.floor((tdNum - nz(anchorNum)) / ((freqTf == "W" ? 7.0 : 1.0) * freqStep))

if inRange and tfSupported
    if fromStart
        windowStart := na(anchorLast) or anchorIdx > anchorLast
        anchorLast  := anchorIdx
    else if newPeriod
        periodCount += 1
        windowStart := (periodCount - 1) % freqStep == 0

if windowStart
    if timingInput == "Start of Period"
        buyBar := true
    else
        buyBar     := endPending
        fillPrice  := close[1]
        endPending := true

float buyWeight = nz(weight[1], 1.0)
float feeRate   = feeInput / 100.0
float slipRate  = slipInput / 100.0
float unitShare = feeModeInput == "Added On Top" ? 1.0 : 1.0 - feeRate
float cashShare = feeModeInput == "Added On Top" ? 1.0 + feeRate : 1.0

var float invested    = 0.0
var float units       = 0.0
var int buys          = 0
var float firstPrice  = na
var float fixInvested = 0.0
var float fixUnits    = 0.0

bool didBuy  = false
bool didSkip = false

if buyBar
    float spend     = amountInput * buyWeight
    float execPrice = fillPrice * (1.0 + slipRate)
    if spend > 0
        units    += spend * unitShare / execPrice
        invested += spend * cashShare
        buys     += 1
        didBuy   := true
        if na(firstPrice)
            firstPrice := execPrice
    else
        didSkip := true
    fixUnits    += amountInput * unitShare / execPrice
    fixInvested += amountInput * cashShare

float avgCost = units > 0 ? invested / units : na
float value   = units * close
float roi     = invested > 0 ? (value / invested - 1.0) * 100.0 : na
float lumpRoi = invested > 0 and not na(firstPrice) ? (unitShare / cashShare * close / firstPrice - 1.0) * 100.0 : na
float fixRoi  = fixInvested > 0 ? (fixUnits * close / fixInvested - 1.0) * 100.0 : na

float unitsPre    = nz(units[1])
float investedPre = nz(invested[1])
float cashIn      = invested - investedPre
bool fillAtOpen   = cashIn > 0 and timingInput != "End of Period"
float openUnits   = fillAtOpen ? unitsPre : units
float openBase    = fillAtOpen ? investedPre : invested

var float peakValue = 0.0
var float maxDd     = 0.0

if ddDataInput == "Live" or barstate.isconfirmed
    float peakPrior   = peakValue
    float peakPreOpen = fillAtOpen ? peakPrior : peakPrior + cashIn
    float peakOpen    = math.max(peakPreOpen, ddWicksInput ? openUnits * open : 0.0) + (fillAtOpen ? cashIn : 0.0)
    peakValue := math.max(peakOpen, ddWicksInput ? units * high : 0.0, value)
    if invested > 0
        bool fromPeak  = ddBasisInput == "From Peak"
        float ddClose  = value / (fromPeak ? peakValue : invested) - 1.0
        float ddLow    = ddWicksInput ? units * low / (fromPeak ? peakOpen : invested) - 1.0 : 0.0
        float ddOpen   = ddWicksInput and openBase > 0 ? openUnits * open / (fromPeak ? peakPreOpen : openBase) - 1.0 : 0.0
        float ddFill   = cashIn > 0 and not fillAtOpen ? units * close[1] / (fromPeak ? peakPreOpen : invested) - 1.0 : 0.0
        maxDd := math.min(maxDd, math.min(ddClose, ddLow, ddOpen, ddFill, 0.0) * 100.0)

//              ╔════════════════════════════════╗              //
//              ║          VISUALIZATION         ║              //
//              ╚════════════════════════════════╝              //

readoutTextColor(color fillColor) =>
    float brightness = (color.r(fillColor) * 299.0 + color.g(fillColor) * 587.0 + color.b(fillColor) * 114.0) / 1000.0
    brightness >= 128.0 ? color.black : color.white

plot(costLineInput ? avgCost : na, "Average Cost", costColorInput, 2, plot.style_stepline)
plotshape(markersInput and didBuy, "Buy", shape.triangleup, location.belowbar, color.new(buyCol, modeInput == "Fixed Amount" ? 0 : math.round(math.max(0.0, 70.0 - 25.0 * buyWeight))), size = size.tiny, offset = timingInput == "End of Period" ? -1 : 0)

var label costLabel = na

if barstate.islast
    label.delete(costLabel)
    costLabel := na
    if costLabelInput and not na(avgCost)
        costLabel := label.new(bar_index, avgCost, "  Avg Cost " + str.tostring(avgCost, format.mintick) + "  ", style = label.style_label_left, color = costColorInput, textcolor = readoutTextColor(costColorInput), size = textSize)

//              ╔════════════════════════════════╗              //
//              ║            DASHBOARD           ║              //
//              ╚════════════════════════════════╝              //

fmtCash(float v) =>
    na(v) ? "n/a" : str.tostring(v, "#,##0.00") + " " + syminfo.currency

fmtPct(float v) =>
    na(v) ? "n/a" : (v > 0 ? "+" : "") + str.tostring(v, "#.##") + "%"

string tablePos = switch tablePosInput
    "Top Center"    => position.top_center
    "Top Right"     => position.top_right
    "Middle Left"   => position.middle_left
    "Middle Center" => position.middle_center
    "Middle Right"  => position.middle_right
    "Bottom Left"   => position.bottom_left
    "Bottom Center" => position.bottom_center
    "Bottom Right"  => position.bottom_right
    => position.top_left

color hdrBg  = color.new(chart.fg_color, 85)
color cellBg = color.new(chart.bg_color, 10)
color txt    = chart.fg_color

var table dash   = tableInput and tfSupported ? table.new(tablePos, 2, 12, border_width = 1, border_color = color.new(chart.fg_color, 85), frame_width = 1, frame_color = color.new(chart.fg_color, 70)) : na
var table notice = tfSupported ? na : table.new(position.middle_center, 1, 2, border_width = 1, border_color = color.new(chart.fg_color, 85), frame_width = 1, frame_color = color.new(chart.fg_color, 70))

if barstate.islast and not na(dash)
    table.cell(dash, 0, 0, freqInput + " DCA", text_color = txt, bgcolor = hdrBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 0, modeInput, text_color = txt, bgcolor = hdrBg, text_size = textSize)
    table.cell(dash, 0, 1, "Start Date", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 1, na(planStart) ? "n/a" : str.format_time(planStart, "dd MMM yyyy", syminfo.timezone), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 2, "Buys", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 2, str.tostring(buys), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 3, "Total Invested", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 3, fmtCash(invested), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 4, "Units Held", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 4, str.tostring(units, "#.######"), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 5, "Average Cost", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 5, na(avgCost) ? "n/a" : str.tostring(avgCost, format.mintick), text_color = costColorInput, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 6, "Current Value", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 6, fmtCash(value), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 7, "Return", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 7, fmtPct(roi), text_color = na(roi) ? txt : roi >= 0 ? buyCol : lossCol, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 8, "Max Drawdown", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 8, invested > 0 ? fmtPct(maxDd) : "n/a", text_color = maxDd < 0 ? lossCol : txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 9, "Lump Sum Return", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 9, fmtPct(lumpRoi), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 10, "Fixed DCA Return", text_color = txt, bgcolor = cellBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 10, fmtPct(fixRoi), text_color = txt, bgcolor = cellBg, text_size = textSize)
    table.cell(dash, 0, 11, "Next Weight", text_color = txt, bgcolor = hdrBg, text_size = textSize, text_halign = text.align_left)
    table.cell(dash, 1, 11, str.tostring(weight, "0.00") + "x" + (na(zVal) ? "" : " (z " + str.tostring(zVal, "0.00") + ")"), text_color = txt, bgcolor = hdrBg, text_size = textSize)

if barstate.islast and not na(notice)
    string periodText = fromStart or freqTf == "D" ? "one day" : freqTf == "W" ? "one week" : "one month"
    string buyText    = freqInput + (fromStart ? " buys counted from the start date" : " buys")
    table.cell(notice, 0, 0, "⚠️ WARNING ⚠️", text_color = txt, bgcolor = hdrBg, text_size = textSize)
    table.cell(notice, 0, 1, buyText + " run on chart timeframes of " + periodText + " or lower.\nEach bar on this chart spans more than " + periodText + ", so the simulation is paused.", text_color = txt, bgcolor = cellBg, text_size = textSize)

//              ╔════════════════════════════════╗              //
//              ║             ALERTS             ║              //
//              ╚════════════════════════════════╝              //

bool increasedBuy   = didBuy and buyWeight > 1.0
bool reducedBuy     = didBuy and buyWeight < 1.0
bool crossAboveCost = ta.crossover(close, avgCost)
bool crossBelowCost = ta.crossunder(close, avgCost)
bool turnedPositive = barstate.isconfirmed and crossAboveCost
bool turnedNegative = barstate.isconfirmed and crossBelowCost
string symbolText   = syminfo.prefix + ":" + syminfo.ticker

alertcondition(didBuy, title = "Scheduled Buy", message = "DCA Simulator: scheduled BUY executed on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(increasedBuy, title = "Increased Buy", message = "DCA Simulator: INCREASED buy above the base amount on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(reducedBuy, title = "Reduced Buy", message = "DCA Simulator: REDUCED buy below the base amount on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(didSkip, title = "Skipped Buy", message = "DCA Simulator: scheduled buy SKIPPED as the valuation weight reached zero on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(turnedPositive, title = "Return Turned Positive", message = "DCA Simulator: return turned POSITIVE as price closed above the average cost on {{exchange}}:{{ticker}} - {{interval}}")
alertcondition(turnedNegative, title = "Return Turned Negative", message = "DCA Simulator: return turned NEGATIVE as price closed below the average cost on {{exchange}}:{{ticker}} - {{interval}}")

if didBuy
    alert("DCA Simulator: buy of " + fmtCash(amountInput * buyWeight) + " at " + str.tostring(fillPrice, format.mintick) + " on " + symbolText + " (weight " + str.tostring(buyWeight, "0.00") + ")", alert.freq_once_per_bar)
if didSkip
    alert("DCA Simulator: scheduled buy skipped on " + symbolText + " as the valuation weight reached zero (z " + str.tostring(zVal[1], "0.00") + ")", alert.freq_once_per_bar)

//              ╔════════════════════════════════╗              //
//              ║           CREATED BY           ║              //
//              ╚════════════════════════════════╝              //

// ██████╗ ██╗   ██╗ █████╗ ███╗   ██╗████████╗     █████╗ ██╗      ██████╗  ██████╗ 
//██╔═══██╗██║   ██║██╔══██╗████╗  ██║╚══██╔══╝    ██╔══██╗██║     ██╔════╝ ██╔═══██╗
//██║   ██║██║   ██║███████║██╔██╗ ██║   ██║       ███████║██║     ██║  ███╗██║   ██║
//██║▄▄ ██║██║   ██║██╔══██║██║╚██╗██║   ██║       ██╔══██║██║     ██║   ██║██║   ██║
//╚██████╔╝╚██████╔╝██║  ██║██║ ╚████║   ██║       ██║  ██║███████╗╚██████╔╝╚██████╔╝
// ╚══▀▀═╝  ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝       ╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝
````
