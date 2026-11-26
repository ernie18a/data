# Funding Rate 5 Aggregated

- url: https://www.tradingview.com/script/QPUHZwq7/
- type: indicator
- pine_id: PUB;8f91e69a176e429ba555f79932357092
- version: 1.0

## Description

Funding Rate with 5 aggregates, Green colors show negative rates and red colors show positive rates, helping to understand the trend.

## Source Code

````pine
//────────────────────────────────────────────────────────────────────────────
//   FUNDING RATE 5 AGGREGATED
//────────────────────────────────────────────────────────────────────────────
//   Author   : @criptonizado
//   Version  : v6.0 (2026-06-03)
//────────────────────────────────────────────────────────────────────────────

//@version=6
indicator("Funding Rate 5 Aggregated", overlay = false, format = format.percent, precision = 4)

base = syminfo.basecurrency

mode = input.string("Open Interest Weighted", "Mode", ["Open Interest Weighted", "Average"], group = "General")
display_mode = input.string("Columns", "Display", ["Line", "Columns"], group = "General")
measure      = input.string("Rate (%)", "Measure", ["Rate (%)", "Total Spend Rate ($)", "Total Spend Rate (Coins)"], group = "General")
scale        = input.string("8 Hours", "Scaled Per", ["5 Minutes", "15 Minutes", "30 Minutes", "1 Hour", "8 Hours", "24 Hours", "1 Year"], group = "General")

enableBinance = input.bool(true, "Enable Binance", group = "Exchanges (Aggregation)", tooltip = "Pairs: USDT.P")
enableBybit = input.bool(true, "Enable Bybit", group = "Exchanges (Aggregation)", tooltip = "Pairs: USDT.P")
enableOKX = input.bool(true, "Enable OKX", group = "Exchanges (Aggregation)", tooltip = "Pairs: USDT.P")
enableBitget = input.bool(true, "Enable Bitget", group = "Exchanges (Aggregation)", tooltip = "Pairs: USDT.P")
enableCoinbase = input.bool(true, "Enable Coinbase", group = "Exchanges (Aggregation)", tooltip = "Pairs: USDC.P")


// ─── SCALING MULTIPLIER ────────────────────────────────────────────────────
// Assumes standard 8H interval for default FR payouts
scaleMult = switch scale
    "5 Minutes" => 5.0 / 480.0 // (8 Hours = 480 Minutes)
    "15 Minutes" => 15.0 / 480.0
    "30 Minutes" => 30.0 / 480.0
    "1 Hour"   => 1.0 / 8.0
    "8 Hours"  => 1.0
    "24 Hours" => 3.0
    "1 Year"   => 1095.0 // 3 payments/day * 365 days


//Funding
binanceUSDT_FR = enableBinance ? request.security("BINANCE:" + base + "USDT.P_FR", timeframe.period, close, ignore_invalid_symbol = true) : na
bybitUSDT_FR = enableBybit ? request.security("BYBIT:" + base + "USDT.P_FR", timeframe.period, close, ignore_invalid_symbol = true) : na 
okxUSDT_FR = enableOKX ? request.security("OKX:" + base + "USDT.P_FR", timeframe.period, close, ignore_invalid_symbol = true) : na 
bitgetUSDT_FR = enableBitget ? request.security("BITGET:" + base + "USDT.P_FR", timeframe.period, close, ignore_invalid_symbol = true) : na 
coinbaseUSDC_FR = enableCoinbase ? request.security("COINBASE:" + base + "USDC.P_FR", timeframe.period, close, ignore_invalid_symbol = true) : na 


//Open Interest
binanceUSDTClose = enableBinance ? request.security("BINANCE:" + base + "USDT.P_OI", timeframe.period, close, ignore_invalid_symbol = true) : na
bybitUSDTClose = enableBybit ? request.security("BYBIT:" + base + "USDT.P_OI", timeframe.period, close, ignore_invalid_symbol = true) : na
okxUSDTClose = enableOKX ? request.security("OKX:" + base + "USDT.P_OI", timeframe.period, close, ignore_invalid_symbol = true) : na
bitgetUSDTClose = enableBitget ? request.security("BITGET:" + base + "USDT.P_OI", timeframe.period, close, ignore_invalid_symbol = true) : na
coinbaseUSDCClose = enableCoinbase ? request.security("COINBASE:" + base + "USDC.P_OI", timeframe.period, close, ignore_invalid_symbol = true) : na


binanceTotalClose = nz(enableBinance ? binanceUSDTClose : na, 0)
bybitTotalClose = nz(enableBybit ? bybitUSDTClose : na, 0)
okxTotalClose = nz(enableOKX ? (okxUSDTClose / close) : na, 0)
bitgetTotalClose = nz(enableBitget ? bitgetUSDTClose : na, 0)
coinbaseTotalClose = nz(enableCoinbase ? coinbaseUSDCClose : na, 0)


// ─── AGGREGATION LOGIC ─────────────────────────────────────────────────────
sum_oi_coins     = 0.0
sum_spend_coins  = 0.0
avg_fr_sum       = 0.0
active_exchanges = 0

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

// ─── CALCULATE FINAL OUTPUT VALUES ─────────────────────────────────────────
weighted_fr_raw = sum_oi_coins > 0 ? (sum_spend_coins / sum_oi_coins) : 0.0
average_fr_raw  = active_exchanges > 0 ? (avg_fr_sum / active_exchanges) : 0.0

// Select base metric depending on mode
selected_fr_raw       = mode == "Open Interest Weighted" ? weighted_fr_raw : average_fr_raw
total_spend_coins_raw = mode == "Open Interest Weighted" ? sum_spend_coins : (sum_oi_coins * average_fr_raw)

// Apply scaling and formatting based on user 'Measure' choice
final_value = 0.0
if measure == "Rate (%)"
    final_value := selected_fr_raw * 100 * scaleMult
else if measure == "Total Spend Rate ($)"
    final_value := total_spend_coins_raw * close * scaleMult
else if measure == "Total Spend Rate (Coins)"
    final_value := total_spend_coins_raw * scaleMult

// ─── PLOTTING ──────────────────────────────────────────────────────────────
plot_color = final_value > 0 ? color.rgb(244, 17, 17) : color.rgb(65, 255, 52)
plot_style = display_mode == "Line" ? plot.style_line : plot.style_columns

plot(final_value, "Aggregated Funding Value", plot_color, style = plot_style)
hline(0, "Zero", color.gray, hline.style_dashed, 1)

//────────────────────────────────────────────────────────────────────────────
//   THE END
//────────────────────────────────────────────────────────────────────────────
````
