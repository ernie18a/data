# Whales vs Leverage (Bitfinex Flows + Open Interest)

- url: https://www.tradingview.com/script/afpeWiWC/
- type: indicator
- pine_id: PUB;890bc340fa1c49c5883ef05d123f65b8
- version: 1.0

## Description

Whales vs Leverage (Bitfinex Flows + Open Interest)

OVERVIEW

Whales vs Leverage compares, in a single panel and in the same unit (coins), what two very different groups of market participants are doing:

- The "whales": large traders holding margin positions on Bitfinex, a group that historically keeps a very large and slow-moving long position.
- The "leverage": traders in the futures / perpetual market of the symbol loaded on the chart, measured through its open interest.

The indicator does not show how big each group's position is. It shows how much each group has ADDED or REMOVED over a chosen window of bars. The core idea is simple: when both groups move in the same direction, the move has support from both sides. When they move in opposite directions with similar size, one of the two groups is going to be wrong, and history on this chart shows it has usually been the leveraged side.


WHY ANOTHER BITFINEX INDICATOR

There are many scripts that plot Bitfinex longs and shorts, most of them showing the raw amounts or the long/short ratio. The problem today is that Bitfinex BTC longs represent more than 99% of all Bitfinex BTC margin positions (roughly 89,000 BTC long against about 200 BTC short at the time of writing). With numbers like these, the ratio is stuck near 100% and tells you almost nothing.

This script takes a different approach:

1. It measures FLOWS, not levels. It plots the change in coins over a window of N bars, so you see when the whales are buying or selling, and how much.
2. It puts derivatives open interest on the SAME scale, also as a change in coins, and colors it according to who is behind that change (new longs, new shorts, shorts closing or longs closing).
3. Everything is in the same unit, so the size of the whales' flow can be compared directly with the size of the leveraged flow.


DATA SOURCES

All data comes from feeds already available in TradingView. No external data is used.

- Bitfinex margin longs: BITFINEX:<COIN>USDLONGS (for example BITFINEX:BTCUSDLONGS). Total amount of coins held in long margin positions on Bitfinex.
- Bitfinex margin shorts: BITFINEX:<COIN>USDSHORTS (for example BITFINEX:BTCUSDSHORTS). Total amount of coins held in short margin positions on Bitfinex.
- Open interest: TradingView's open interest feed for the futures / perpetual symbol loaded on the chart (the chart symbol with the "_OI" suffix, for example BINANCE:BTCUSDT.P). It is the total number of open contracts on that market.

<COIN> is taken automatically from the base currency of the chart (BTC on BTCUSDT, ETH on ETHUSDT, and so on). It can also be set manually in the settings.

All values are requested on the chart timeframe and use closed bars, without lookahead. Historical values do not repaint. On the bar that is still open, the values update in real time until it closes, like any other indicator.


WHAT IT PLOTS

1. Net position change (columns)
   Change in the Bitfinex net position (longs minus shorts) over the last N bars, in coins.
   - Teal columns: the net position is growing (whales adding longs and/or removing shorts).
   - Maroon columns: the net position is shrinking (whales closing longs and/or adding shorts).

2. Longs change (green line)
   Change in Bitfinex long positions over the last N bars, in coins.

3. Shorts change (red line)
   Change in Bitfinex short positions over the last N bars, in coins. On BTC this line is almost flat nowadays because the short side is very small. If it ever moves visibly, that move is significant.

4. Open interest change (colored line)
   Change in the open interest of the chart's futures / perpetual over the last N bars, in coins. Its color depends on what price did over the same window:
   - Blue: price up and open interest up. New longs entering.
   - Aqua: price up and open interest down. Shorts closing (short covering).
   - Fuchsia: price down and open interest up. New shorts entering.
   - Orange: price down and open interest down. Longs closing (liquidations or profit taking).

5. Table (top right)
   Current Bitfinex longs, shorts and net position, each followed by its change over the window, plus the share of longs.


HOW TO READ IT

Two situations matter most.

1. Opposite moves (divergence between whales and leverage)
   - Teal columns (whales buying) together with a fuchsia line (leveraged traders opening shorts) during a decline: the leveraged side is betting on further downside while the whales absorb the selling.
   - Maroon columns (whales selling) together with a blue line (leveraged traders opening longs) during a rally: the leveraged side is buying what the whales are selling. This combination is a warning sign for the rally.
   The larger and more similar in size the two moves are, the more relevant the divergence.

2. Aligned moves
   When the columns and the open interest line point the same way (for example whales adding and new longs entering), both groups support the move and there is no divergence signal.

Historical examples on BTC (Binance perpetual chart, monthly, 6-bar window):
- 2022 bear market: whales added around 70,000 BTC of longs while open interest grew on the short side (fuchsia). Price later bottomed and recovered, and a long period of short covering (aqua) followed.
- First half of 2024: whales reduced their longs by roughly 40,000 BTC during the rally towards 73,000, while the futures market did not show a similar reduction. Price then spent months in a range.
- Early 2026: whales added longs during the drop towards 60,000 while new shorts entered the futures market. Price then rebounded.

These are examples to illustrate how the indicator reads, not a guarantee that the same pattern will work in the future.

Another useful reading: on higher timeframes, Bitfinex whales have tended to accumulate during large declines and reduce exposure during strong rallies. Over a full cycle this gives context about which phase the market is in.


RECOMMENDED CHARTS AND TIMEFRAMES

Chart:
- Best on BTC. It also works on any coin for which Bitfinex publishes longs/shorts data (for example ETH). If the data does not exist for a coin, the table shows "no data".
- To see the open interest line, load a futures or perpetual symbol, for example BINANCE:BTCUSDT.P. On spot or index charts the open interest line is not shown, while the Bitfinex part still works.

Timeframe:
- Weekly and monthly: the clearest readings. Whale flows are slow, and on these timeframes they show the cycle phase.
- Daily: useful for medium-term context.
- 4h and below: whales accumulate systematically, so on short timeframes their buying often happens in the middle of a decline. Use it only as background context, not for entries.

Suggested window ("Change measured over"):
- Monthly: 6 to 12 bars (half a year to a year).
- Weekly: 20 to 30 bars (about 5 to 7 months).
- Daily: 30 to 90 bars.
- 4h: 30 to 90 bars.
A larger window gives smoother, slower readings. A smaller window reacts faster but is noisier.


SETTINGS

- Coin: Auto (base currency of the chart) or Manual.
- Coin (manual): coin used when Coin is set to Manual (for example BTC, ETH).
- Change measured over (bars): window N used for all changes.
- Show current positions table: shows or hides the table.
- Open interest of the chart symbol: shows or hides the open interest line.
- Colors for every element, including the four open interest states.


LIMITATIONS

- Bitfinex is a single exchange. Its margin positions represent one group of large traders, not the whole market.
- The open interest line reflects only the futures / perpetual market of the symbol on the chart, not all exchanges combined.
- Open interest history in TradingView is shorter than Bitfinex history (on BTCUSDT.P it starts in 2022), so on long windows or high timeframes the line appears later than the columns.
- Open interest is assumed to be expressed in coins, as it is on Binance USDT perpetuals. If a different exchange reports it in another unit, the line will not be on the same scale as the Bitfinex data.
- Flows show what the groups are doing, not when price will turn. Divergences can last a long time before they resolve.


DISCLAIMER

This indicator is a tool for market context and education. It does not give buy or sell signals and it is not financial advice. Past behavior of these groups does not guarantee future results. Always combine it with your own analysis and risk management.

## Source Code

````pine
//@version=6
indicator("Whales vs Leverage (Bitfinex Flows + Open Interest)", shorttitle = "Whales vs Leverage", overlay = false, format = format.volume)

// ─── Inputs ─────────────────────────────────────────────────────────────────
mode    = input.string("Auto", "Coin", options = ["Auto", "Manual"], tooltip = "Auto: uses the base coin of the chart (BTC on BTCUSDT, ETH on ETHUSDT...).")
coinMan = input.string("BTC", "Coin (manual)")
len     = input.int(30, "Change measured over (bars)", minval = 1)
showTbl = input.bool(true, "Show current positions table")
colL    = input.color(color.green, "Longs", group = "Style")
colS    = input.color(color.red, "Shorts", group = "Style")
colNetU = input.color(color.new(color.teal, 40), "Net position rising", group = "Style")
colNetD = input.color(color.new(color.maroon, 40), "Net position falling", group = "Style")
showOI  = input.bool(true, "Open interest of the chart symbol", group = "Open interest", tooltip = "Change in open interest, in coins, of the futures / perpetual loaded on the chart (e.g. BINANCE:BTCUSDT.P). The line color tells who is behind the change.")
cNL     = input.color(color.blue, "Price up + OI up: new longs", group = "Open interest")
cSC     = input.color(color.aqua, "Price up + OI down: shorts closing", group = "Open interest")
cNS     = input.color(color.fuchsia, "Price down + OI up: new shorts", group = "Open interest")
cLC     = input.color(color.orange, "Price down + OI down: longs closing", group = "Open interest")

string coin = mode == "Auto" ? syminfo.basecurrency : coinMan

// Bitfinex margin positions, in coins
float L = request.security("BITFINEX:" + coin + "USDLONGS", timeframe.period, close, ignore_invalid_symbol = true)
float S = request.security("BITFINEX:" + coin + "USDSHORTS", timeframe.period, close, ignore_invalid_symbol = true)

// Change over the window, in coins: everything on the same scale
float dL   = L - L[len]
float dS   = S - S[len]
float dNet = dL - dS     // net position change (longs minus shorts)

hline(0, "Zero", color = color.gray, linestyle = hline.style_dashed)
plot(dNet, "Net position change", color = dNet >= 0 ? colNetU : colNetD, style = plot.style_columns)
plot(dL, "Longs change", color = colL, linewidth = 2)
plot(dS, "Shorts change", color = colS, linewidth = 2)

// Open interest of the chart symbol, change in coins (same scale as the Bitfinex positions)
float oi     = request.security(syminfo.tickerid + "_OI", timeframe.period, close, ignore_invalid_symbol = true)
float dOI    = oi - oi[len]
float dPrice = close - close[len]
color cOI    = dPrice >= 0 ? (dOI >= 0 ? cNL : cSC) : (dOI >= 0 ? cNS : cLC)
plot(showOI ? dOI : na, "Open interest change", color = cOI, linewidth = 2)

// Current positions
var table tbl = table.new(position.top_right, 2, 5, bgcolor = color.new(color.gray, 85), border_color = color.gray, border_width = 1)
if showTbl and barstate.islast
    tbl.cell(0, 0, "Bitfinex " + coin, text_size = size.small)
    tbl.cell(1, 0, na(L) ? "no data" : "last " + str.tostring(len) + " bars", text_size = size.small)
    tbl.cell(0, 1, "Longs", text_size = size.small, text_color = colL)
    tbl.cell(1, 1, str.tostring(L, format.volume) + "  (" + (dL >= 0 ? "+" : "") + str.tostring(dL, format.volume) + ")", text_size = size.small)
    tbl.cell(0, 2, "Shorts", text_size = size.small, text_color = colS)
    tbl.cell(1, 2, str.tostring(S, format.volume) + "  (" + (dS >= 0 ? "+" : "") + str.tostring(dS, format.volume) + ")", text_size = size.small)
    tbl.cell(0, 3, "Net", text_size = size.small)
    tbl.cell(1, 3, str.tostring(L - S, format.volume) + "  (" + (dNet >= 0 ? "+" : "") + str.tostring(dNet, format.volume) + ")", text_size = size.small)
    tbl.cell(0, 4, "Longs share", text_size = size.small)
    tbl.cell(1, 4, na(L) or na(S) ? "-" : str.tostring(100 * L / (L + S), "0.0") + " %", text_size = size.small)
````
