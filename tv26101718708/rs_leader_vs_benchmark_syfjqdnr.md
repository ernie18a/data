# RS Leader vs Benchmark

- url: https://www.tradingview.com/script/SyfJqdNR-RS-Leader-vs-Benchmark/
- type: indicator
- pine_id: PUB;93c16453e9284464a59647abdf6329d1
- version: 1.0

## Description

RS Leader vs Benchmark

1. Overview


RS Leader vs Benchmark is a relative strength analysis indicator designed to compare the current chart symbol against a selected benchmark.

The indicator calculates a relative strength line using:

Symbol Close / Benchmark Close

When the RS line rises, the chart symbol is outperforming the selected benchmark.

When the RS line falls, the chart symbol is lagging the selected benchmark.

This tool is designed as a market leadership and watchlist filtering indicator. It is not a trading strategy. It does not place trades, does not execute orders, and does not produce TradingView Strategy Tester results.

2. Purpose

The main purpose of this indicator is to help traders answer a simple question:

Is this symbol stronger or weaker than its benchmark?

This can be useful before applying other trading methods such as trend-following, breakout, pullback, or market structure analysis.

The indicator helps users identify symbols that are showing relative strength compared with a selected market, sector, crypto benchmark, forex benchmark, or custom reference symbol.

3. Relative Strength Line

The main RS line is calculated by dividing the chart symbol by the selected benchmark.

If the RS line is rising, the symbol is outperforming the benchmark.

If the RS line is falling, the symbol is underperforming or lagging the benchmark.

This allows users to study performance relative to a reference market rather than looking only at the symbol's own price movement.

4. RS EMA

https://www.tradingview.com/x/RawZajY9/

The script plots an EMA of the RS line.

This EMA acts as a relative strength trend reference.

When RS is above its EMA, the symbol is considered to be outperforming its own relative strength trend.

When RS is below its EMA, the symbol is considered to be lagging its own relative strength trend.

The default RS EMA length is 50.

Users can adjust this value depending on their timeframe and analysis style.

5. RS Momentum

The indicator calculates RS Momentum as the percentage change of the RS line over a selected lookback period.

The default momentum lookback is 63 bars.

On a daily chart, 63 bars is approximately three trading months.

Positive RS Momentum means the symbol's relative strength is improving.

Negative RS Momentum means the symbol's relative strength is weakening.

6. RS Rating

The script includes an RS Rating from 0 to 100.

This rating is calculated using the percentile rank of the current RS value within the symbol's own RS history.

A higher value means the current RS is strong compared with its own historical RS range.

A lower value means the current RS is weak compared with its own historical RS range.

Important note:

This RS Rating is a single-symbol historical percentile. It is not a full cross-sectional market ranking across all stocks or assets.

7. RS Leader State

The indicator defines an RS Leader state when the following conditions are met:

* RS is above its RS EMA
* RS Momentum is positive
* Optional RS Rating filter is satisfied, if enabled

When these conditions are met, the symbol is classified as an RS Leader relative to the selected benchmark.

When the conditions are not met, the symbol is classified as Not Leader.

This state is intended for watchlist filtering and relative strength review. It should not be treated as a direct buy or sell signal.

8. Optional RS Rating Filter

The script includes an optional RS Rating filter.

When enabled, the RS Leader state also requires the RS Rating to be above the selected minimum value.

For example, if the minimum rating is set to 60, the symbol must have:

* RS above RS EMA
* Positive RS Momentum
* RS Rating of 60 or higher

This gives users a stricter leadership filter.

9. Benchmark Mode

The script includes three benchmark modes:

* Auto Benchmark
* Benchmark Preset
* Custom Benchmark

This design makes the indicator easier for users who may not know which benchmark to select.

10. Auto Benchmark

Auto Benchmark attempts to select a benchmark based on the current symbol type.

Examples:

* US stocks and US funds use SPY as the automatic broad-market benchmark.
* Crypto symbols use BTCUSDT as the automatic crypto benchmark.
* BTC itself uses the total crypto market benchmark.
* Forex symbols use DXY as the automatic dollar-index benchmark.
* Unknown or unsupported cases fall back to the custom benchmark field.

Auto Benchmark is intended to help users get started quickly.

Because there is no single perfect benchmark for every market, users can still switch to Preset or Custom mode when needed.

11. Benchmark Preset

Benchmark Preset allows users to select from a ready-made list.

Available presets include:

* US Broad Market - SPY
* US Tech - QQQ
* US Small Caps - IWM
* Crypto vs Bitcoin - BTCUSDT
* Crypto vs Ethereum - ETHUSDT
* Crypto Total Market - TOTAL
* Forex vs Dollar Index - DXY
* Custom Benchmark

This is useful for users who want a guided benchmark selection without manually typing symbols.

12. Fallback / Custom Benchmark

The Fallback / Custom Benchmark field allows users to manually select any benchmark symbol.

This is especially useful for:

* Local stock markets
* Country-specific indices
* Sector indices
* ETFs
* Futures markets
* Custom relative strength comparisons
* Special benchmark studies

In Auto Benchmark mode, this field is used only when the script cannot reliably assign an automatic benchmark.

The field remains visible in the settings because TradingView Pine inputs cannot be dynamically hidden.

13. Badge Table

The indicator includes an optional badge table.

The badge displays:

* RS Status
* Benchmark mode
* Active benchmark
* Reason for benchmark selection
* Trend state
* RS Momentum
* RS Rating
* State rule
* Use context

The table helps users understand which benchmark is being used and why.

14. Badge Size

The badge table includes multiple text-size options:

* Tiny
* Small
* Normal
* Large

This allows users to adjust the table for different screen sizes, chart layouts, and visual preferences.

15. Background Tint

The script can display a background tint.

A green tint appears when the symbol is in RS Leader state.

A red tint can appear when the symbol is lagging its RS trend.

This visual layer is optional and can be turned on or off in the settings.

16. Alerts

The script includes alert conditions for:

* RS crossing above its EMA
* RS crossing below its EMA
* RS Leader state turning ON
* RS Leader state turning OFF

Alerts are notifications only. They do not place trades and do not confirm broker execution.

17. How to Use

A practical workflow:

1. Add the indicator to a chart.

2. Leave Benchmark Mode on Auto Benchmark for general use.

3. Use Benchmark Preset if you want to choose a guided benchmark.

4. Use Custom Benchmark for local markets or special comparisons.

5. Watch the RS line relative to the RS EMA.

6. Look for symbols where RS is above its EMA.

7. Review RS Momentum to see if leadership is improving.

8. Review RS Rating to understand where current RS stands compared with its own history.

9. Use RS Leader state as a watchlist filter, not as a direct trade entry signal.

10. Combine the indicator with trend, market structure, volume, support/resistance, and risk management.

11. Suggested Use Cases

RS Leader vs Benchmark can be useful for:

* Watchlist filtering
* Market leadership analysis
* Relative strength review
* Sector or benchmark comparison
* Crypto strength comparison
* Forex benchmark comparison
* Stock selection
* Trend-following preparation
* Breakout candidate filtering
* Comparing symbols against a broad market, sector, or custom reference

19. Important Limitations

This indicator does not predict future price movement.

It does not guarantee outperformance.

It does not guarantee profitable trades.

It is not a trading strategy.

It does not place orders.

It does not provide buy or sell recommendations.

RS Leader state is a relative strength condition, not a trade signal.

A symbol can show relative strength and still decline in price if the entire market is falling.

A symbol can lag its benchmark and still move upward if the benchmark is stronger.

Benchmark selection affects the result significantly.

Auto Benchmark is a helpful starting point, but it may not always select the best benchmark for every symbol or market.

Users should select an appropriate benchmark for their market, asset class, and analysis objective.

20. Originality and Purpose

RS Leader vs Benchmark combines relative strength ratio analysis with trend, momentum, rating, benchmark presets, automatic benchmark selection, and a visual leader-state table.

The script is designed to make relative strength analysis easier for users who may not know which benchmark to choose.

The main purpose is to provide a clear and practical market leadership filter for chart analysis and watchlist review.

21. Educational Disclaimer

This script is for educational and chart-analysis purposes only. It is not financial advice, investment advice, or a recommendation to buy or sell any financial instrument. Users should perform their own analysis and manage risk independently.

## Source Code

````pine
// This Pine Script(R) code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// (c) ADXAE

//@version=6
// ============================================================================
// RS Leader vs Benchmark
// ============================================================================
// Relative Strength compares the chart symbol against a selected benchmark.
// RS = Symbol Close / Benchmark Close.
//
// When RS rises, the chart symbol is outperforming the benchmark.
// When RS falls, the chart symbol is lagging the benchmark.
//
// This indicator is designed as a relative-strength selection and watchlist
// filter. It is not a strategy and does not place orders.
//
// Main outputs:
// - RS line.
// - RS EMA trend reference.
// - RS Momentum percentage.
// - RS Rating 0-100 based on percentile rank of the symbol's own RS history.
// - RS Leader / Not Leader state.
//
// Benchmark system:
// - Auto Benchmark: attempts to choose a benchmark based on symbol type.
// - Benchmark Preset: user selects a ready-made benchmark preset.
// - Custom Benchmark: user manually selects any symbol.
// - Fallback / Custom Benchmark: used when Auto cannot reliably assign a benchmark.
//
// Important:
// The RS Rating here is a single-symbol historical percentile of the RS line.
// It is not a full cross-sectional market ranking across all stocks.
// ============================================================================

indicator("RS Leader vs Benchmark", "RS Leader", overlay = false, precision = 4, dynamic_requests = true)

// ============================================================================
// Inputs
// ============================================================================

grpBench = "1) Benchmark"

benchMode = input.string(
     "Auto Benchmark",
     "Benchmark mode",
     options = [
         "Auto Benchmark",
         "Benchmark Preset",
         "Custom Benchmark"
     ],
     group = grpBench,
     tooltip = "Auto Benchmark attempts to select a benchmark based on the current symbol type. Preset lets users choose from ready-made benchmarks. Custom lets users manually choose any benchmark.")

benchPreset = input.string(
     "US Broad Market - SPY",
     "Preset benchmark (Preset mode only)",
     options = [
         "US Broad Market - SPY",
         "US Tech - QQQ",
         "US Small Caps - IWM",
         "Crypto vs Bitcoin - BTCUSDT",
         "Crypto vs Ethereum - ETHUSDT",
         "Crypto Total Market - TOTAL",
         "Forex vs Dollar Index - DXY",
         "Custom Benchmark"
     ],
     group = grpBench,
     tooltip = "Used only when Benchmark mode is set to Benchmark Preset. Choose a benchmark that matches the market you are analyzing.")

customBenchSym = input.symbol(
     "AMEX:SPY",
     "Fallback / Custom benchmark",
     group = grpBench,
     tooltip = "This field is always visible because TradingView Pine inputs cannot be hidden dynamically. It is used only when Benchmark mode is Custom Benchmark, or when Auto Benchmark cannot reliably assign a benchmark. For local markets, choose a local index, local ETF, sector index, or another suitable benchmark.")

grpRS = "2) Relative Strength"

smoothLen = input.int(
     50,
     "RS trend EMA",
     minval = 2,
     group = grpRS,
     tooltip = "RS above this EMA suggests the symbol is outperforming its own RS trend.")

momLen = input.int(
     63,
     "RS momentum lookback",
     minval = 5,
     group = grpRS,
     tooltip = "RS rate of change. 63 daily bars is approximately three months.")

ratingLen = input.int(
     252,
     "RS rating lookback",
     minval = 20,
     group = grpRS,
     tooltip = "Window for the 0-100 percentile rating. 252 daily bars is approximately one trading year.")

grpState = "3) Leader State"

useRatingFilter = input.bool(
     false,
     "Use RS rating filter",
     group = grpState,
     tooltip = "When ON, RS Leader state also requires RS Rating to be above the selected minimum.")

minRating = input.float(
     60.0,
     "Minimum RS rating",
     minval = 0.0,
     maxval = 100.0,
     step = 1.0,
     group = grpState,
     tooltip = "Minimum RS Rating required when the RS rating filter is enabled.")

grpDisplay = "4) Display"

showBadge = input.bool(
     true,
     "Show badge",
     group = grpDisplay)

posStr = input.string(
     "top_right",
     "Badge position",
     options = ["top_left", "top_right", "bottom_left", "bottom_right", "middle_left", "middle_right"],
     group = grpDisplay)

tableSizeOpt = input.string(
     "Small",
     "Badge text size",
     options = ["Tiny", "Small", "Normal", "Large"],
     group = grpDisplay)

showBg = input.bool(
     true,
     "Show leader background tint",
     group = grpDisplay)

// ============================================================================
// Helper functions
// ============================================================================

f_pos(string s) =>
    s == "top_left" ? position.top_left :
     s == "top_right" ? position.top_right :
     s == "bottom_left" ? position.bottom_left :
     s == "bottom_right" ? position.bottom_right :
     s == "middle_left" ? position.middle_left :
     position.middle_right

f_text_size(string s) =>
    s == "Tiny" ? size.tiny :
     s == "Small" ? size.small :
     s == "Normal" ? size.normal :
     size.large

f_clean_symbol(string s) =>
    str.replace_all(
         str.replace_all(
             str.replace_all(
                 str.replace_all(
                     str.replace_all(
                         str.replace_all(
                             str.replace_all(s, "AMEX:", ""),
                         "NASDAQ:", ""),
                     "NYSE:", ""),
                 "NYSEARCA:", ""),
             "BINANCE:", ""),
         "CRYPTOCAP:", ""),
     "TVC:", "")

// ============================================================================
// Benchmark preset resolver
// ============================================================================

presetBenchSym = switch benchPreset
    "US Broad Market - SPY"        => "AMEX:SPY"
    "US Tech - QQQ"                => "NASDAQ:QQQ"
    "US Small Caps - IWM"          => "AMEX:IWM"
    "Crypto vs Bitcoin - BTCUSDT"  => "BINANCE:BTCUSDT"
    "Crypto vs Ethereum - ETHUSDT" => "BINANCE:ETHUSDT"
    "Crypto Total Market - TOTAL"  => "CRYPTOCAP:TOTAL"
    "Forex vs Dollar Index - DXY"  => "TVC:DXY"
    => customBenchSym

presetReason = switch benchPreset
    "US Broad Market - SPY"        => "Preset: US market"
    "US Tech - QQQ"                => "Preset: US tech"
    "US Small Caps - IWM"          => "Preset: small caps"
    "Crypto vs Bitcoin - BTCUSDT"  => "Preset: crypto vs BTC"
    "Crypto vs Ethereum - ETHUSDT" => "Preset: crypto vs ETH"
    "Crypto Total Market - TOTAL"  => "Preset: crypto total"
    "Forex vs Dollar Index - DXY"  => "Preset: forex vs DXY"
    => "Preset: custom"

// ============================================================================
// Auto benchmark resolver
// ============================================================================

isCrypto = syminfo.type == "crypto"
isForex = syminfo.type == "forex"
isStock = syminfo.type == "stock"
isFund = syminfo.type == "fund"
isUS = syminfo.country == "US"

baseCur = syminfo.basecurrency

autoBenchSym = switch
    isCrypto and baseCur == "BTC" => "CRYPTOCAP:TOTAL"
    isCrypto                      => "BINANCE:BTCUSDT"
    isForex                       => "TVC:DXY"
    (isStock or isFund) and isUS  => "AMEX:SPY"
    => customBenchSym

autoReason = switch
    isCrypto and baseCur == "BTC" => "BTC chart -> TOTAL"
    isCrypto                      => "Crypto -> BTC"
    isForex                       => "Forex -> DXY"
    (isStock or isFund) and isUS  => "US stock -> SPY"
    => "Auto fallback -> custom"

// ============================================================================
// Final benchmark selection
// ============================================================================

benchSym = switch benchMode
    "Auto Benchmark"   => autoBenchSym
    "Benchmark Preset" => presetBenchSym
    => customBenchSym

benchSourceText = switch benchMode
    "Auto Benchmark"   => "Auto"
    "Benchmark Preset" => "Preset"
    => "Custom"

benchReasonText = switch benchMode
    "Auto Benchmark"   => autoReason
    "Benchmark Preset" => presetReason
    => "User selected"

// ============================================================================
// Palette
// ============================================================================

cUp = color.rgb(54, 168, 112)
cDn = color.rgb(205, 85, 95)
cMid = color.rgb(150, 158, 170)
cCard = color.rgb(16, 20, 26)
cHdr = color.new(color.white, 25)
cDim = color.new(color.white, 55)
cWarn = color.rgb(235, 142, 52)

tblSize = f_text_size(tableSizeOpt)

// ============================================================================
// Relative strength calculation
// ============================================================================

bench = request.security(
     benchSym,
     timeframe.period,
     close,
     ignore_invalid_symbol = true)

validBench = not na(bench) and bench != 0

rs = validBench ? close / bench : na

rsEma = ta.ema(rs, smoothLen)

rsMom = not na(rs[momLen]) and rs[momLen] != 0 ? (rs / rs[momLen] - 1.0) * 100.0 : na

rating = ta.percentrank(rs, ratingLen)

// ============================================================================
// Leader logic
// ============================================================================

leadingTrend = not na(rs) and not na(rsEma) and rs > rsEma
positiveMomentum = not na(rsMom) and rsMom > 0
ratingOK = not useRatingFilter or (not na(rating) and rating >= minRating)

isLeader = validBench and leadingTrend and positiveMomentum and ratingOK

isLeaderPrev = isLeader[1] == true

leaderOn = isLeader and not isLeaderPrev
leaderOff = not isLeader and isLeaderPrev

// ============================================================================
// Plot
// ============================================================================

rsCol = na(rs) ? cMid : leadingTrend ? cUp : cDn

plot(
     rs,
     "RS",
     color = rsCol,
     linewidth = 2)

plot(
     rsEma,
     "RS EMA",
     color = color.new(cMid, 20),
     linewidth = 1)

bgcolor(
     showBg ? (isLeader ? color.new(cUp, 90) : validBench and not leadingTrend ? color.new(cDn, 93) : na) : na,
     title = "Leader background tint")

// ============================================================================
// Badge
// ============================================================================

var table tbl = table.new(
     f_pos(posStr),
     2,
     9,
     bgcolor = cCard,
     frame_color = color.new(color.gray, 70),
     frame_width = 1,
     border_color = color.new(color.gray, 75),
     border_width = 1)

if showBadge and barstate.islast
    string bnm = f_clean_symbol(benchSym)

    statusText = not validBench ? "NO DATA" : isLeader ? "RS LEADER" : "NOT LEADER"
    statusColor = not validBench ? cWarn : isLeader ? cUp : cDn

    trendText = not validBench or na(rs) ? "--" : leadingTrend ? "OUTPERFORM" : "LAG"
    trendColor = not validBench or na(rs) ? cMid : leadingTrend ? cUp : cDn

    momText = na(rsMom) ? "--" : str.tostring(rsMom, "#.#") + "%"
    momColor = na(rsMom) ? cMid : positiveMomentum ? cUp : cDn

    ratingText = na(rating) ? "--" : str.tostring(rating, "#") + "/100"
    ratingColor = na(rating) ? cMid : rating >= 70 ? cUp : rating <= 30 ? cDn : cHdr

    filterText = useRatingFilter ? "Rating >= " + str.tostring(minRating, "#") : "Trend + Momentum"
    filterColor = useRatingFilter ? cWarn : cDim

    useText = isLeader ? "Watchlist leader" : "Review / wait"
    useColor = isLeader ? cUp : cDim

    table.cell(
         tbl,
         0,
         0,
         "RS Status",
         text_color = statusColor,
         bgcolor = cCard,
         text_size = tblSize,
         text_halign = text.align_left)

    table.cell(
         tbl,
         1,
         0,
         statusText,
         text_color = cCard,
         bgcolor = statusColor,
         text_size = tblSize)

    table.cell(
         tbl,
         0,
         1,
         "Mode",
         text_color = cHdr,
         bgcolor = cCard,
         text_size = tblSize,
         text_halign = text.align_left)

    table.cell(
         tbl,
         1,
         1,
         benchSourceText,
         text_color = cHdr,
         bgcolor = cCard,
         text_size = tblSize)

    table.cell(
         tbl,
         0,
         2,
         "Benchmark",
         text_color = cHdr,
         bgcolor = cCard,
         text_size = tblSize,
         text_halign = text.align_left)

    table.cell(
         tbl,
         1,
         2,
         bnm,
         text_color = cHdr,
         bgcolor = cCard,
         text_size = tblSize)

    table.cell(
         tbl,
         0,
         3,
         "Reason",
         text_color = cDim,
         bgcolor = cCard,
         text_size = tblSize,
         text_halign = text.align_left)

    table.cell(
         tbl,
         1,
         3,
         benchReasonText,
         text_color = cDim,
         bgcolor = cCard,
         text_size = tblSize)

    table.cell(
         tbl,
         0,
         4,
         "Trend",
         text_color = cHdr,
         bgcolor = cCard,
         text_size = tblSize,
         text_halign = text.align_left)

    table.cell(
         tbl,
         1,
         4,
         trendText,
         text_color = trendColor,
         bgcolor = cCard,
         text_size = tblSize)

    table.cell(
         tbl,
         0,
         5,
         "RS momentum",
         text_color = cHdr,
         bgcolor = cCard,
         text_size = tblSize,
         text_halign = text.align_left)

    table.cell(
         tbl,
         1,
         5,
         momText,
         text_color = momColor,
         bgcolor = cCard,
         text_size = tblSize)

    table.cell(
         tbl,
         0,
         6,
         "RS rating",
         text_color = cHdr,
         bgcolor = cCard,
         text_size = tblSize,
         text_halign = text.align_left)

    table.cell(
         tbl,
         1,
         6,
         ratingText,
         text_color = ratingColor,
         bgcolor = cCard,
         text_size = tblSize)

    table.cell(
         tbl,
         0,
         7,
         "State rule",
         text_color = cDim,
         bgcolor = cCard,
         text_size = tblSize,
         text_halign = text.align_left)

    table.cell(
         tbl,
         1,
         7,
         filterText,
         text_color = filterColor,
         bgcolor = cCard,
         text_size = tblSize)

    table.cell(
         tbl,
         0,
         8,
         "Use",
         text_color = cDim,
         bgcolor = cCard,
         text_size = tblSize,
         text_halign = text.align_left)

    table.cell(
         tbl,
         1,
         8,
         useText,
         text_color = useColor,
         bgcolor = cCard,
         text_size = tblSize)

// ============================================================================
// Alerts
// ============================================================================

rsCrossAbove = ta.crossover(rs, rsEma)
rsCrossBelow = ta.crossunder(rs, rsEma)

alertcondition(
     rsCrossAbove,
     title = "RS turned outperforming",
     message = "RS Leader vs Benchmark: RS crossed above its EMA")

alertcondition(
     rsCrossBelow,
     title = "RS turned lagging",
     message = "RS Leader vs Benchmark: RS crossed below its EMA")

alertcondition(
     leaderOn,
     title = "RS Leader state ON",
     message = "RS Leader vs Benchmark: symbol entered RS Leader state")

alertcondition(
     leaderOff,
     title = "RS Leader state OFF",
     message = "RS Leader vs Benchmark: symbol left RS Leader state")

// ============================================================================
// End of file
// ============================================================================
````
