<!-- tradingview-pine-id: PUB;11d65a5fe0724173b72c230c576947fc -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Momentum Sequence Strategy [Herman]

Source: https://www.tradingview.com/script/mmrInMTp-Momentum-Sequence-Strategy-Herman/

## Description

Momentum Sequence Strategy [Herman] is an open-source, rules-based price-action strategy designed to test momentum continuation following a defined candle sequence.

The strategy does not use moving averages, oscillators, volume indicators, or higher-timeframe data. Its signals are derived entirely from the relationship between consecutive OHLC candles.

The objective is to identify situations where an initial candle establishes a protected price extreme and is followed by a sequence of candles showing consistent momentum in the opposite direction.

How the strategy works

The model begins with a Main Candle, followed by a user-defined number of consecutive confirmation candles.

The number of following candles can be set to:

2
3
4
5

The default setting is 5 following candles.

Long setup

A Long setup requires:

The Main Candle to be bearish.
Every following candle to be bullish.
The low of every following candle must remain strictly above the low of the Main Candle.
Each new bullish candle must close higher than the previous bullish candle.
No position may already be open.

In simplified form:

Bearish Main Candle -> Bullish -> Bullish -> ... -> Long

The low of the Main Candle acts as the invalidation level for the sequence.

Short setup

The Short setup is the exact inverse of the Long setup.

A Short setup requires:

The Main Candle to be bullish.
Every following candle to be bearish.
The high of every following candle must remain strictly below the high of the Main Candle.
Each new bearish candle must close lower than the previous bearish candle.
No position may already be open.

In simplified form:

Bullish Main Candle -> Bearish -> Bearish -> ... -> Short

The high of the Main Candle acts as the invalidation level.

Long and Short trading can be enabled or disabled independently.

By default:

Long Trades: ON
Short Trades: OFF

The strategy allows only one open position at a time.

Stop Loss

For Long trades, the Stop Loss is placed at the low of the Main bearish Candle.

For Short trades, the Stop Loss is placed at the high of the Main bullish Candle.

This means the candle that begins the sequence defines the structural invalidation point of the trade.

Take Profit

The strategy uses configurable R-based targets:

0.5R / 1R / 1.5R / 2R

The default setting is 1.5R.

For a Long setup, risk is measured from the closing price of the final confirmation candle to the low of the Main Candle.

For a Short setup, risk is measured from the closing price of the final confirmation candle to the high of the Main Candle.

The selected R multiple is then applied to that distance to calculate the Take Profit level.

Important execution detail

The strategy identifies a completed sequence using confirmed candle data.

Under TradingView's standard historical strategy execution model, a market order generated after a confirmed bar will normally be filled on the next available tick, which is typically the open of the following bar.

The strategy calculates its R-based target using the close of the signal candle, rather than the eventual simulated market fill price.

Because of this, the selected 0.5R, 1R, 1.5R, or 2R setting represents the strategy's target calculation model and may not equal the exact realized risk-to-reward ratio measured from the simulated fill price. Gaps, market movement between bars, commissions, and slippage can further affect actual results.

Visuals

The strategy can display:

Long setup markers
Short setup markers
Active Stop Loss
Active Take Profit
A configurable statistics/settings table

The table displays the currently selected Take Profit, sequence length, and enabled trade directions.

Default configuration

The default script inputs are:

Following Candles: 5
Take Profit: 1.5R
Long Trades: ON
Short Trades: OFF
Entry Signals: ON
Stop Loss / Take Profit display: ON

These defaults are provided as a starting configuration for research and are not presented as optimized parameters for any particular market or timeframe.

Users are encouraged to evaluate different configurations across sufficiently large datasets rather than selecting parameters solely because they produced favorable historical results.

Intended use and limitations

This is a mechanical backtesting strategy intended for studying a specific candle-sequence behavior.

It does not evaluate market regime, trend, volatility, liquidity, volume, news events, session context, support/resistance, or other discretionary information.

A valid sequence therefore does not imply that a profitable trade will follow.

Historical strategy results are hypothetical and do not predict future performance. Results can vary materially depending on symbol, timeframe, trading costs, liquidity, execution assumptions, and selected parameters.

The strategy should be evaluated on standard price-based candlestick charts. Non-standard chart types such as Heikin Ashi, Renko, Range, Kagi, or Point & Figure can produce strategy results that do not correspond to tradable market prices.

This version extends that foundation with:

Pine Script v6 implementation
Configurable 2-5 candle sequence length
Mirrored Short-side logic
Independent Long/Short controls
Configurable R-based profit targets
One-position-at-a-time execution
Stop Loss and Take Profit visualization
Configurable on-chart settings table
Expanded user controls and documentation

The script is published open-source so users can inspect the complete methodology, verify its behavior, modify it, and conduct their own research.

---

## Source Code

````pine
// This Source Code Form is subject to the terms of the Mozilla Public License 2.0
// at https://mozilla.org/MPL/2.0/
//
// Momentum Sequence Strategy+ [Herman]
// Pine Script v6

//@version=6

strategy(
     "Momentum Sequence Strategy [Herman]",
     overlay = true,
     pyramiding = 0,
     initial_capital = 50000,
     currency = currency.USD,
     default_qty_type = strategy.fixed,
     default_qty_value = 1,
     commission_type = strategy.commission.cash_per_contract,
     commission_value = 2.50,
     slippage = 1,
     margin_long = 5,
     margin_short = 5
)

// ═════════════════════════════════════════════════════════════════════════════
// INPUT GROUPS
// ═════════════════════════════════════════════════════════════════════════════

string G_SEQUENCE = "Sequence Settings"
string G_TRADE    = "Trade Settings"
string G_VISUALS  = "Visuals"
string G_TABLE    = "Statistics Table"

// ═════════════════════════════════════════════════════════════════════════════
// SETTINGS
// ═════════════════════════════════════════════════════════════════════════════

followingCandles = input.int(
     5,
     title = "Following Candles",
     options = [2, 3, 4, 5],
     group = G_SEQUENCE,
     tooltip = "Number of consecutive candles required after the main candle."
)

takeProfitR = input.string(
     "1.5R",
     title = "Take Profit",
     options = ["0.5R", "1R", "1.5R", "2R"],
     group = G_TRADE
)

enableLongTrades = input.bool(
     true,
     title = "Long Trades",
     group = G_TRADE,
     tooltip = "Enable or disable Long trades."
)

enableShortTrades = input.bool(
     false,
     title = "Short Trades",
     group = G_TRADE,
     tooltip = "Enable or disable Short trades."
)

showSignal = input.bool(
     true,
     title = "Show Entry Signal",
     group = G_VISUALS
)

showSLTP = input.bool(
     true,
     title = "Show Stop Loss / Take Profit",
     group = G_VISUALS
)

// ═════════════════════════════════════════════════════════════════════════════
// STATISTICS TABLE SETTINGS
// ═════════════════════════════════════════════════════════════════════════════

showTable = input.bool(
     true,
     "Show Table",
     group = G_TABLE
)

tableTheme = input.string(
     "Light",
     "Theme",
     options = ["Dark", "Light"],
     group = G_TABLE
)

tableSize = input.string(
     "small",
     "Size",
     options = ["tiny", "small", "normal", "large"],
     group = G_TABLE
)

tablePos = input.string(
     position.top_right,
     "Position",
     options = [
         position.top_right,
         position.bottom_right,
         position.top_left,
         position.bottom_left
     ],
     group = G_TABLE
)

// ═════════════════════════════════════════════════════════════════════════════
// R MULTIPLE
// ═════════════════════════════════════════════════════════════════════════════

rrMultiple = switch takeProfitR
    "0.5R" => 0.5
    "1R"   => 1.0
    "1.5R" => 1.5
    "2R"   => 2.0
    => 1.5

// ═════════════════════════════════════════════════════════════════════════════
// VARIABLES
// ═════════════════════════════════════════════════════════════════════════════

var float stopLossPrice = na
var float takeProfitPrice = na

var float stopLossPriceDisplay = na
var float takeProfitPriceDisplay = na

// ═════════════════════════════════════════════════════════════════════════════
// MAIN CANDLE
// ═════════════════════════════════════════════════════════════════════════════

mainBearish =
     close[followingCandles] < open[followingCandles]

mainBullish =
     close[followingCandles] > open[followingCandles]

// ═════════════════════════════════════════════════════════════════════════════
// FOLLOWING BULLISH SEQUENCE
// ═════════════════════════════════════════════════════════════════════════════

bool validBullishSequence = true

for i = 0 to followingCandles - 1

    // Every following candle must be bullish.
    if close[i] <= open[i]
        validBullishSequence := false

    // Every following candle must stay above
    // the low of the main bearish candle.
    if low[i] <= low[followingCandles]
        validBullishSequence := false

    // Every newer candle must close higher
    // than the previous candle.
    if i < followingCandles - 1
        if close[i] <= close[i + 1]
            validBullishSequence := false

// ═════════════════════════════════════════════════════════════════════════════
// FOLLOWING BEARISH SEQUENCE
// ═════════════════════════════════════════════════════════════════════════════

bool validBearishSequence = true

for i = 0 to followingCandles - 1

    // Every following candle must be bearish.
    if close[i] >= open[i]
        validBearishSequence := false

    // Every following candle must stay below
    // the high of the main bullish candle.
    if high[i] >= high[followingCandles]
        validBearishSequence := false

    // Every newer candle must close lower
    // than the previous candle.
    if i < followingCandles - 1
        if close[i] >= close[i + 1]
            validBearishSequence := false

// ═════════════════════════════════════════════════════════════════════════════
// FULL SETUPS
// ═════════════════════════════════════════════════════════════════════════════

longSetup =
     mainBearish and
     validBullishSequence

shortSetup =
     mainBullish and
     validBearishSequence

// ═════════════════════════════════════════════════════════════════════════════
// LONG ENTRY
// ═════════════════════════════════════════════════════════════════════════════

if enableLongTrades and longSetup and strategy.position_size == 0

    stopLossPrice := low[followingCandles]

    longRisk = close - stopLossPrice

    takeProfitPrice :=
         close + longRisk * rrMultiple

    strategy.entry(
         "Long",
         strategy.long
    )

// ═════════════════════════════════════════════════════════════════════════════
// SHORT ENTRY
// ═════════════════════════════════════════════════════════════════════════════

if enableShortTrades and shortSetup and strategy.position_size == 0

    stopLossPrice := high[followingCandles]

    shortRisk = stopLossPrice - close

    takeProfitPrice :=
         close - shortRisk * rrMultiple

    strategy.entry(
         "Short",
         strategy.short
    )

// ═════════════════════════════════════════════════════════════════════════════
// LONG EXIT
// ═════════════════════════════════════════════════════════════════════════════

if not na(stopLossPrice) and strategy.position_size > 0

    strategy.exit(
         "Long Take Profit / Stop Loss",
         from_entry = "Long",
         stop = stopLossPrice,
         limit = takeProfitPrice
    )

// ═════════════════════════════════════════════════════════════════════════════
// SHORT EXIT
// ═════════════════════════════════════════════════════════════════════════════

if not na(stopLossPrice) and strategy.position_size < 0

    strategy.exit(
         "Short Take Profit / Stop Loss",
         from_entry = "Short",
         stop = stopLossPrice,
         limit = takeProfitPrice
    )

// ═════════════════════════════════════════════════════════════════════════════
// DISPLAY LEVELS
// ═════════════════════════════════════════════════════════════════════════════

if strategy.position_size == 0

    stopLossPriceDisplay := na
    takeProfitPriceDisplay := na

else

    stopLossPriceDisplay := stopLossPrice
    takeProfitPriceDisplay := takeProfitPrice

// ═════════════════════════════════════════════════════════════════════════════
// TABLE PALETTE
// ═════════════════════════════════════════════════════════════════════════════

var color c_green = na
var color c_red   = na
var color c_nbg   = na
var color c_ntxt  = na
var color c_hdr   = na
var color c_sep   = na

if tableTheme == "Dark"

    c_green := #29a071
    c_red   := #e54b4b

    c_nbg   := #2a2e39
    c_ntxt  := #e0e0e0

    c_hdr   := #3c415e
    c_sep   := #454955

else

    c_green := #29a071
    c_red   := #e54b4b

    c_nbg   := #f7f7f7
    c_ntxt  := #1e2025

    c_hdr   := #e5eef7
    c_sep   := #e1e4e6

color c_dhdr = #f0f3f6

color nbg2 = color.new(c_nbg, 50)

// ═════════════════════════════════════════════════════════════════════════════
// TABLE HELPERS
// ═════════════════════════════════════════════════════════════════════════════

font_sz(sz) =>

    switch sz
        "tiny"   => size.tiny
        "small"  => size.small
        "normal" => size.normal
        "large"  => size.large
        => size.small

// ═════════════════════════════════════════════════════════════════════════════
// STATISTICS TABLE
// ═════════════════════════════════════════════════════════════════════════════

var table tbl = table.new(
     tablePos,
     2,
     6
)

if barstate.islast

    table.clear(
         tbl,
         0,
         0,
         1,
         5
    )

    if showTable

        int r = 0

        fsz = font_sz(tableSize)

        // TITLE

        table.cell(
             tbl,
             0,
             r,
             "Momentum Sequence Strategy [Herman]",
             text_color = c_ntxt,
             bgcolor = c_hdr,
             text_size = fsz
        )

        table.cell(
             tbl,
             1,
             r,
             "",
             text_color = c_ntxt,
             bgcolor = c_hdr
        )

        r += 1

        // SECTION HEADER

        table.cell(
             tbl,
             0,
             r,
             "Current Settings",
             text_color = c_ntxt,
             bgcolor = c_dhdr,
             text_size = fsz
        )

        table.cell(
             tbl,
             1,
             r,
             "",
             bgcolor = c_dhdr
        )

        r += 1

        // TAKE PROFIT

        table.cell(
             tbl,
             0,
             r,
             "Take Profit",
             bgcolor = nbg2,
             text_color = c_ntxt,
             text_size = fsz
        )

        table.cell(
             tbl,
             1,
             r,
             takeProfitR,
             bgcolor = nbg2,
             text_color = c_ntxt,
             text_size = fsz
        )

        r += 1

        // CONSECUTIVE CANDLES

        table.cell(
             tbl,
             0,
             r,
             "Consecutive Candles",
             bgcolor = c_nbg,
             text_color = c_ntxt,
             text_size = fsz
        )

        table.cell(
             tbl,
             1,
             r,
             str.tostring(followingCandles),
             bgcolor = c_nbg,
             text_color = c_ntxt,
             text_size = fsz
        )

        r += 1

        // LONG TRADES

        table.cell(
             tbl,
             0,
             r,
             "Long Trades",
             bgcolor = nbg2,
             text_color = c_ntxt,
             text_size = fsz
        )

        table.cell(
             tbl,
             1,
             r,
             enableLongTrades ? "ON" : "OFF",
             bgcolor = nbg2,
             text_color = enableLongTrades ? c_green : c_red,
             text_size = fsz
        )

        r += 1

        // SHORT TRADES

        table.cell(
             tbl,
             0,
             r,
             "Short Trades",
             bgcolor = c_nbg,
             text_color = c_ntxt,
             text_size = fsz
        )

        table.cell(
             tbl,
             1,
             r,
             enableShortTrades ? "ON" : "OFF",
             bgcolor = c_nbg,
             text_color = enableShortTrades ? c_green : c_red,
             text_size = fsz
        )

// ═════════════════════════════════════════════════════════════════════════════
// VISUALS
// ═════════════════════════════════════════════════════════════════════════════

plotshape(
     showSignal and
     enableLongTrades and
     longSetup and
     strategy.position_size == 0,
     title = "Long Setup",
     location = location.belowbar,
     color = color.green,
     style = shape.triangleup,
     size = size.small
)

plotshape(
     showSignal and
     enableShortTrades and
     shortSetup and
     strategy.position_size == 0,
     title = "Short Setup",
     location = location.abovebar,
     color = color.red,
     style = shape.triangledown,
     size = size.small
)

plot(
     showSLTP ? stopLossPriceDisplay : na,
     color = color.red,
     title = "Stop Loss",
     linewidth = 2,
     style = plot.style_linebr
)

plot(
     showSLTP ? takeProfitPriceDisplay : na,
     color = color.green,
     title = "Take Profit",
     linewidth = 2,
     style = plot.style_linebr
)
````
