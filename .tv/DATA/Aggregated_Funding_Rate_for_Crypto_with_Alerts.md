<!-- tradingview-pine-id: PUB;d08df2d28f0c4347b8dfdade57f0f2a4 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# Aggregated Funding Rate for Crypto with Alerts

Source: https://www.tradingview.com/script/EiZmDJlt-Aggregated-Funding-Rate-for-Crypto-with-Alerts/

## Description

This indicator aggregates perpetual futures funding rates across multiple major exchanges into a single unified view, weighted by open interest. Instead of checking each exchange separately, AFR gives you one clean reading that reflects the true market-wide funding sentiment for any perpetual contract.

How it works

Funding rates are periodic payments between long and short traders in perpetual futures markets. When funding is positive, longs pay shorts — the market is overheated to the upside. When negative, shorts pay longs — the market is leaning heavily short. Extremes in either direction often precede reversals or accelerations as overleveraged positions get squeezed.

This indicator pulls funding rate and open interest data from up to 5 exchanges simultaneously — Binance, Bybit, OKX, Bitget, and Coinbase — and aggregates them using open interest weighting by default. This means exchanges with more capital at stake have proportionally more influence on the final reading, giving a more accurate picture of where the majority of the market is positioned.

Settings

Mode — choose between Open Interest Weighted (recommended) or a simple average across enabled exchanges
Display — columns or line, personal preference
Measure — Rate (%), Total Spend Rate in USD, or Total Spend Rate in coins
Scaled Per — normalise the rate to 1 hour, 8 hours (default, one funding interval), 24 hours, or annualised
Exchanges — enable or disable individual exchanges; useful if a symbol is not listed on a particular exchange and you want to exclude it from the aggregation

How to use it

The most straightforward use is reading the absolute level. Funding consistently above 0.01% per 8 hours signals an overheated long market. Sustained negative funding signals excessive shorting. Neither extreme lasts forever.

More useful is watching for changes in direction after a prolonged period of stability. When funding has been flat for hours or days and then begins shifting meaningfully in one direction, it often signals a change in positioning before price reacts — traders are starting to lean one way and paying for it.

For multi-symbol scanning, add this indicator to a watchlist alert across your entire perpetual futures list. Symbols where funding is moving sharply relative to their recent norm are worth investigating further for potential setups.

Notes

OKX reports open interest in USD rather than coins, so the indicator automatically converts it using the current price to keep units consistent across exchanges
If a symbol does not exist on a particular exchange, that exchange is automatically excluded from the aggregation for that symbol via ignore_invalid_symbol
Funding rate data availability and update frequency depends on what TradingView receives from each exchange feed

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LuckSoon

//@version=6
indicator("Aggregated Funding Rate for Crypto with Alerts", shorttitle = "AFR with Alerts", overlay = false, format = format.percent, precision = 4)

base = syminfo.basecurrency

// ─── GENERAL ───────────────────────────────────────────────────────────────
mode         = input.string("Open Interest Weighted", "Mode",       ["Open Interest Weighted", "Average"],                           group = "General")
display_mode = input.string("Line",                "Display",    ["Line", "Columns"],                                             group = "General")
measure      = input.string("Rate (%)",               "Measure",    ["Rate (%)", "Total Spend Rate ($)", "Total Spend Rate (Coins)"], group = "General")
scale        = input.string("8 Hours",                "Scaled Per", ["1 Hour", "8 Hours", "24 Hours", "1 Year"],                     group = "General")

// ─── EXCHANGES ─────────────────────────────────────────────────────────────
enableBinance  = input.bool(true, "Enable Binance",  group = "Exchanges", tooltip = "Pairs: USDT.P")
enableBybit    = input.bool(true, "Enable Bybit",    group = "Exchanges", tooltip = "Pairs: USDT.P")
enableOKX      = input.bool(true, "Enable OKX",      group = "Exchanges", tooltip = "Pairs: USDT.P")
enableBitget   = input.bool(true, "Enable Bitget",   group = "Exchanges", tooltip = "Pairs: USDT.P")
enableCoinbase = input.bool(true, "Enable Coinbase", group = "Exchanges", tooltip = "Pairs: USDC.P")

// ─── SCALING ───────────────────────────────────────────────────────────────
scaleMult = switch scale
    "1 Hour"   => 1.0 / 8.0
    "8 Hours"  => 1.0
    "24 Hours" => 3.0
    "1 Year"   => 1095.0

// ─── FUNDING REQUESTS ──────────────────────────────────────────────────────
binanceUSDT_FR  = enableBinance  ? request.security("BINANCE:"  + base + "USDT.P_FR", timeframe.period, close, ignore_invalid_symbol = true) : na
bybitUSDT_FR    = enableBybit    ? request.security("BYBIT:"    + base + "USDT.P_FR", timeframe.period, close, ignore_invalid_symbol = true) : na
okxUSDT_FR      = enableOKX      ? request.security("OKX:"      + base + "USDT.P_FR", timeframe.period, close, ignore_invalid_symbol = true) : na
bitgetUSDT_FR   = enableBitget   ? request.security("BITGET:"   + base + "USDT.P_FR", timeframe.period, close, ignore_invalid_symbol = true) : na
coinbaseUSDC_FR = enableCoinbase ? request.security("COINBASE:" + base + "USDC.P_FR", timeframe.period, close, ignore_invalid_symbol = true) : na

// ─── OI REQUESTS ───────────────────────────────────────────────────────────
binanceUSDTClose  = enableBinance  ? request.security("BINANCE:"  + base + "USDT.P_OI", timeframe.period, close, ignore_invalid_symbol = true) : na
bybitUSDTClose    = enableBybit    ? request.security("BYBIT:"    + base + "USDT.P_OI", timeframe.period, close, ignore_invalid_symbol = true) : na
okxUSDTClose      = enableOKX      ? request.security("OKX:"      + base + "USDT.P_OI", timeframe.period, close, ignore_invalid_symbol = true) : na
bitgetUSDTClose   = enableBitget   ? request.security("BITGET:"   + base + "USDT.P_OI", timeframe.period, close, ignore_invalid_symbol = true) : na
coinbaseUSDCClose = enableCoinbase ? request.security("COINBASE:" + base + "USDC.P_OI", timeframe.period, close, ignore_invalid_symbol = true) : na

binanceTotalClose  = nz(enableBinance  ? binanceUSDTClose       : na, 0)
bybitTotalClose    = nz(enableBybit    ? bybitUSDTClose         : na, 0)
okxTotalClose      = nz(enableOKX      ? (okxUSDTClose / close) : na, 0)
bitgetTotalClose   = nz(enableBitget   ? bitgetUSDTClose        : na, 0)
coinbaseTotalClose = nz(enableCoinbase ? coinbaseUSDCClose      : na, 0)

// ─── AGGREGATION ───────────────────────────────────────────────────────────
var float sum_oi_coins     = 0.0
var float sum_spend_coins  = 0.0
var float avg_fr_sum       = 0.0
var int   active_exchanges = 0

sum_oi_coins     := 0.0
sum_spend_coins  := 0.0
avg_fr_sum       := 0.0
active_exchanges := 0

if enableBinance and not na(binanceUSDT_FR)
    sum_oi_coins     += binanceTotalClose
    sum_spend_coins  += binanceTotalClose * binanceUSDT_FR
    avg_fr_sum       += binanceUSDT_FR
    active_exchanges += 1

if enableBybit and not na(bybitUSDT_FR)
    sum_oi_coins     += bybitTotalClose
    sum_spend_coins  += bybitTotalClose * bybitUSDT_FR
    avg_fr_sum       += bybitUSDT_FR
    active_exchanges += 1

if enableOKX and not na(okxUSDT_FR)
    sum_oi_coins     += okxTotalClose
    sum_spend_coins  += okxTotalClose * okxUSDT_FR
    avg_fr_sum       += okxUSDT_FR
    active_exchanges += 1

if enableBitget and not na(bitgetUSDT_FR)
    sum_oi_coins     += bitgetTotalClose
    sum_spend_coins  += bitgetTotalClose * bitgetUSDT_FR
    avg_fr_sum       += bitgetUSDT_FR
    active_exchanges += 1

if enableCoinbase and not na(coinbaseUSDC_FR)
    sum_oi_coins     += coinbaseTotalClose
    sum_spend_coins  += coinbaseTotalClose * coinbaseUSDC_FR
    avg_fr_sum       += coinbaseUSDC_FR
    active_exchanges += 1

// ─── FINAL VALUE ───────────────────────────────────────────────────────────
weighted_fr_raw       = sum_oi_coins > 0 ? (sum_spend_coins / sum_oi_coins) : 0.0
average_fr_raw        = active_exchanges > 0 ? (avg_fr_sum / active_exchanges) : 0.0
selected_fr_raw       = mode == "Open Interest Weighted" ? weighted_fr_raw : average_fr_raw
total_spend_coins_raw = mode == "Open Interest Weighted" ? sum_spend_coins  : (sum_oi_coins * average_fr_raw)

final_value = 0.0
if measure == "Rate (%)"
    final_value := selected_fr_raw * 100 * scaleMult
else if measure == "Total Spend Rate ($)"
    final_value := total_spend_coins_raw * close * scaleMult
else if measure == "Total Spend Rate (Coins)"
    final_value := total_spend_coins_raw * scaleMult

// ─── PLOT ──────────────────────────────────────────────────────────────────
plot_color = final_value > 0 ? color.teal : color.red
plot_style = display_mode == "Line" ? plot.style_line : plot.style_columns
plot(final_value, "Aggregated Funding Value", plot_color, style = plot_style)

//────────────────────────────────────────────────────────────────────────────
//   THE END
//────────────────────────────────────────────────────────────────────────────
````
