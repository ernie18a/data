# Aggregated Volume Comparison

- url: https://www.tradingview.com/script/6tUuG3so-Aggregated-Volume-Comparison/
- type: indicator
- pine_id: PUB;df27ad2289604506840b882c2814732c
- version: 1.0

## Description

═══════════════════════════════════════════════════════════════════════════════
//  AGGREGATED VOLUME COMPARISON - FULL DOCUMENTATION
═══════════════════════════════════════════════════════════════════════════════
[b]Aggregated Volume Comparison[/b] is a multi-exchange volume aggregator that compares native volume of the current symbol against aggregated Spot + Perpetual volumes from top CEXs (Binance, Bybit, OKX, Bitget, Coinbase) for the symbol itself, BTC, and Gold (XAU). It displays everything in both coin and USD terms with clear ratios and a professional real-time table.


[b]🔍 WHAT MAKES IT ORIGINAL[/b]

1. True Cross-Exchange Aggregation — Pulls and sums real volume from 5 major exchanges for both Spot and Perp contracts in a single indicator.
2. Symbol + BTC + Gold Comparison — Instantly see how the current altcoin’s volume stacks up against Bitcoin and Gold liquidity.
3. Dual Denomination System — Seamlessly switch between raw coin volume and USD-equivalent volume with one click.
4. Smart Perp vs Spot Separation — Clearly distinguishes spot (real buying/selling) from perpetual futures (leveraged speculation) volumes.
5. Built-in Professional Table — Always-visible, well-organized table showing all raw numbers and key ratios on the top-right corner.
6. Instrument-Agnostic — Works perfectly on any crypto pair, altcoin, or Gold chart.


[b]⚙️ HOW IT WORKS[/b]

Native Volume:
- Uses the chart’s native `volume`.
- Converts to USD (volume × close) when “USD” denomination is selected.
- Applies user-defined SMA or EMA for trend context.

Aggregated Volume Engine:
- Dynamically builds symbols (e.g. BINANCE:BTCUSDT, BYBIT:ETHUSDT.P, etc.).
- Spot: Combines USDT + USDC pairs across enabled exchanges.
- Perp: Combines all perpetual contracts (USDT.P, USD.P, USDC.P).
- Gold uses dedicated XAU symbols with special handling.
- All data fetched via request.security() with ignore_invalid_symbol=true.

Ratios:
- Perp / Spot ratio for the current symbol.
- BTC Spot / Symbol ratio.
- Main Ratio: BTC Perp or Gold Perp vs current symbol volume.

Visualization:
- Colored columns for native volume (teal/red based on candle direction).
- Multiple line overlays for aggregated volumes.
- Real-time updating table with clean sections.


[b]📖 HOW TO USE[/b]

Reading the Chart:
- Tall teal/red columns = Current symbol’s native volume.
- Black line = Moving Average of native volume.
- Aqua line = Symbol Spot aggregated volume.
- Blue line = Symbol Perp aggregated volume.
- Orange lines = BTC aggregated volumes.
- Yellow lines = Gold aggregated volumes.
- Fuchsia line = Main Ratio (BTC or Gold Perp / Symbol).

Reading the Table:
- High Perp / Spot Ratio (>3–5x) → Strong leveraged/speculative activity.
- High BTC Perp / Symbol → Altcoin is heavily influenced by Bitcoin flow.
- Compare Symbol Spot vs Perp to judge real demand vs futures-driven moves.

Suggested Workflow:
1. Check if current symbol volume is above or below its MA.
2. Look at Perp/Spot ratio to gauge leverage intensity.
3. Compare with BTC and Gold volumes for market regime context.
4. Use ratios as confluence for breakout or reversal setups.


[b]⚙️ KEY SETTINGS REFERENCE[/b]

General
- Denomination: COINS or USD

Moving Average
- Native Volume MA Length (default 30)
- MA Type: SMA or EMA
- Show Native Volume MA

Plot Display
- Toggle individual plots: Symbol Native, Symbol Spot/Perp, BTC Spot/Perp, Gold Spot/Perp, Main Ratio

Display
- Show Ratios in Table
- Main Ratio Type: BTC or GOLD

Exchanges
- Enable/disable Binance, Bybit, OKX, Bitget, Coinbase individually


🔔 Alerts

This indicator does not include built-in alerts in the current version. 
You can easily create custom alerts on any plotted value (e.g., when Main Ratio crosses a level) directly from TradingView.


[b]⚠️ IMPORTANT NOTES & DISCLAIMER[/b]

— Volume data depends on TradingView’s exchange feeds. Some lesser pairs may show incomplete data.
— Aggregated volumes are summed from enabled exchanges only. Disabling major exchanges (especially Binance) will significantly reduce total volume.
— Perp volumes are generally much higher than Spot due to leverage — high ratios are normal in crypto.
— This indicator is for informational and analytical purposes only. It is not financial advice.
— Always verify important volume levels with multiple sources before making trading decisions.
— Works on all timeframes and all symbols (crypto, forex, commodities). Best performance on major altcoins and BTC pairs.

[b]DISCLAIMER:[/b]
This indicator is provided for educational and informational purposes only. 
It is not financial advice, nor a recommendation to buy, sell, or trade any asset.

• Volume data is fetched from third-party exchanges via TradingView’s request.security(). 
  Accuracy depends on exchange data availability and TradingView’s data feeds.
• Some symbols or contracts may return zero or invalid data.
• Past performance or volume patterns do not guarantee future results.
• Always conduct your own research and verify data with multiple sources before making trading decisions.

## Source Code

````pine
//@version=6
indicator("Aggregated Volume Comparison", "Agg Vol Comparison", false, precision=0)

// ──────────────────────────────────────────────
// SETTINGS
// ──────────────────────────────────────────────
denomination = input.string("COINS", "Denomination", ["COINS", "USD"], group="General")

// Moving Average for Symbol Native Volume
maLength     = input.int(30, "Native Volume MA Length", minval=1, group="Moving Average")
maType       = input.string("SMA", "MA Type", ["SMA", "EMA"], group="Moving Average")
showNativeMA = input.bool(true, "Show Native Volume MA", group="Moving Average")

// Plot Visibility Controls
showSymbolNative = input.bool(true,   "Show Symbol Native Volume",     group="Plot Display")
showSymSpot      = input.bool(false,  "Show Symbol Spot Agg",          group="Plot Display")
showSymPerp      = input.bool(false,  "Show Symbol Perp Agg",          group="Plot Display")
showBTCSpot      = input.bool(false,  "Show BTC Spot Agg",             group="Plot Display")
showBTCPerp      = input.bool(false,  "Show BTC Perp Agg",             group="Plot Display")
showGoldSpot     = input.bool(false,  "Show Gold Spot Agg",            group="Plot Display")
showGoldPerp     = input.bool(false,  "Show Gold Perp Agg",            group="Plot Display")
showMainRatio    = input.bool(false,  "Show Main Ratio Line",          group="Plot Display")

// Display Settings
showRatios   = input.bool(true,  "Show Ratios in Table", group="Display")
ratioType    = input.string("BTC", "Main Ratio Type", ["BTC", "GOLD"], group="Display")

// Exchanges
binanceEx = "BINANCE:" 
bybitEx   = "BYBIT:" 
okxEx     = "OKX:" 
bitgetEx  = "BITGET:" 
coinbaseEx= "COINBASE:"

enableBinance  = input.bool(true,  "Enable Binance",  group="Exchanges")
enableBybit    = input.bool(true,  "Enable Bybit",    group="Exchanges")
enableOKX      = input.bool(true,  "Enable OKX",      group="Exchanges")
enableBitget   = input.bool(true,  "Enable Bitget",   group="Exchanges")
enableCoinbase = input.bool(false, "Enable Coinbase", group="Exchanges")

// ──────────────────────────────────────────────
// CALCULATIONS
// ──────────────────────────────────────────────
symVolume = volume
symFinal  = (denomination == "COINS") ? symVolume : symVolume * close

// Moving Average for Symbol Native Volume
maNative = maType == "EMA" ? ta.ema(symFinal, maLength) : ta.sma(symFinal, maLength)

getAggVolume(string base, string mode, bool isGold) =>
    float total = 0.0
    if mode == "Spot" or mode == "Both"
        total += nz(request.security(binanceEx + base + "USDT", timeframe.period, volume, ignore_invalid_symbol=true), 0)
        total += nz(request.security(binanceEx + base + "USDC", timeframe.period, volume, ignore_invalid_symbol=true), 0)
        total += nz(request.security(bybitEx   + base + "USDT", timeframe.period, volume, ignore_invalid_symbol=true), 0)
        total += nz(request.security(okxEx     + base + "USDT", timeframe.period, volume, ignore_invalid_symbol=true), 0)
        total += nz(request.security(bitgetEx  + base + "USDT", timeframe.period, volume, ignore_invalid_symbol=true), 0)
    
    if mode == "Perp" or mode == "Both"
        total += enableBinance  ? nz(request.security(binanceEx + base + "USDT.P", timeframe.period, volume, ignore_invalid_symbol=true), 0) : 0
        total += enableBinance  ? nz(request.security(binanceEx + base + "USDC.P", timeframe.period, volume, ignore_invalid_symbol=true), 0) : 0
        total += enableBybit    ? nz(request.security(bybitEx   + base + "USDT.P", timeframe.period, volume, ignore_invalid_symbol=true), 0) : 0
        total += enableBybit    ? nz(request.security(bybitEx   + base + "USD.P",  timeframe.period, volume, ignore_invalid_symbol=true), 0) : 0
        total += enableOKX      ? nz(request.security(okxEx     + base + "USDT.P", timeframe.period, volume, ignore_invalid_symbol=true), 0) : 0
        total += enableOKX      ? nz(request.security(okxEx     + base + "USD.P",  timeframe.period, volume, ignore_invalid_symbol=true), 0) : 0
        total += enableBitget   ? nz(request.security(bitgetEx  + base + "USDT.P", timeframe.period, volume, ignore_invalid_symbol=true), 0) : 0
        total += enableCoinbase ? nz(request.security(coinbaseEx+ base + "USDC.P", timeframe.period, volume, ignore_invalid_symbol=true), 0) : 0
    
    if isGold
        total := 0.0
        if mode == "Spot" or mode == "Both"
            total += nz(request.security("BINANCE:XAUUSDT", timeframe.period, volume, ignore_invalid_symbol=true), 0)
            total += nz(request.security("OANDA:XAUUSD", timeframe.period, volume, ignore_invalid_symbol=true), 0)
        if mode == "Perp" or mode == "Both"
            total += nz(request.security("BINANCE:XAUUSDT.P", timeframe.period, volume, ignore_invalid_symbol=true), 0)
            total += nz(request.security("BYBIT:XAUUSDT.P", timeframe.period, volume, ignore_invalid_symbol=true), 0)
    total

base = syminfo.basecurrency

aggSymSpot  = getAggVolume(base, "Spot", false)
aggSymPerp  = getAggVolume(base, "Perp", false)
aggBTCSpot  = getAggVolume("BTC", "Spot", false)
aggBTCPerp  = getAggVolume("BTC", "Perp", false)
aggGoldSpot = getAggVolume("XAU", "Spot", true)
aggGoldPerp = getAggVolume("XAU", "Perp", true)

f(val) => (denomination == "COINS") ? val : val * close

symAggSpotFinal = f(aggSymSpot)
symAggPerpFinal = f(aggSymPerp)
btcAggSpotFinal = f(aggBTCSpot)
btcAggPerpFinal = f(aggBTCPerp)
goldAggSpotFinal= f(aggGoldSpot)
goldAggPerpFinal= f(aggGoldPerp)

ratioMain       = ratioType == "BTC" ? (btcAggPerpFinal / (symFinal == 0 ? na : symFinal)) : (goldAggPerpFinal / (symFinal == 0 ? na : symFinal))
btcSpotRatio    = btcAggSpotFinal / (symFinal == 0 ? na : symFinal)
perpSpotRatio   = symAggPerpFinal / (symAggSpotFinal == 0 ? na : symAggSpotFinal)

// ──────────────────────────────────────────────
// PLOTTING
// ──────────────────────────────────────────────
candleColor = close > open ? color.teal : color.red

plot(showSymbolNative ? symFinal        : na, title="Symbol Native Volume",     color=color.new(candleColor, 20), style=plot.style_columns, linewidth=3)
plot(showNativeMA     ? maNative        : na, title="Native Volume MA",         color=color.new(color.black, 0),   style=plot.style_line, linewidth=3)

plot(showSymSpot      ? symAggSpotFinal : na, title="Symbol Spot Agg",          color=color.new(color.aqua, 50),  style=plot.style_line, linewidth=2)
plot(showSymPerp      ? symAggPerpFinal : na, title="Symbol Perp Agg",          color=color.new(color.blue, 40),  style=plot.style_line, linewidth=2)

plot(showBTCSpot      ? btcAggSpotFinal : na, title="BTC Spot Agg", color=color.new(color.orange, 60), style=plot.style_line, linewidth=1)
plot(showBTCPerp      ? btcAggPerpFinal : na, title="BTC Perp Agg", color=color.new(color.orange, 40), style=plot.style_line, linewidth=1)

plot(showGoldSpot     ? goldAggSpotFinal: na, title="Gold Spot Agg", color=color.new(color.yellow, 60), style=plot.style_line, linewidth=1)
plot(showGoldPerp     ? goldAggPerpFinal: na, title="Gold Perp Agg", color=color.new(color.yellow, 40), style=plot.style_line, linewidth=1)

plot(showMainRatio and showRatios ? ratioMain : na, title="Main Ratio", color=color.fuchsia, style=plot.style_line, linewidth=2)

// ──────────────────────────────────────────────
// TABLE — ALWAYS FULL DISPLAY
// ──────────────────────────────────────────────
var table info = table.new(position.top_right, 2, 14, 
     bgcolor=color.new(color.black, 80), 
     border_width=2, 
     frame_color=color.white, 
     frame_width=3, 
     border_color=color.gray)

if barstate.islast
    r = 0
    table.cell(info, 0, r, "VOLUME",                  text_color=color.white, bgcolor=color.new(color.black, 30))
    table.cell(info, 1, r, "SPOT                  PERP", text_color=color.white, bgcolor=color.new(color.black, 30))
    r += 1
    
    table.cell(info, 0, r, "Denomination", text_color=color.white)
    table.cell(info, 1, r, denomination, text_color=color.white)
    r += 1
    
    table.cell(info, 0, r, "Symbol Native", text_color=color.white, bgcolor=color.new(color.gray, 70))
    table.cell(info, 1, r, str.tostring(symFinal, "#,###"), text_color=candleColor, bgcolor=color.new(color.gray, 70))
    r += 1
    
    // SPOT SECTION
    table.cell(info, 0, r, "=== SPOT ===", text_color=color.lime, bgcolor=color.new(#004d00, 60))
    table.cell(info, 1, r, "", bgcolor=color.new(#004d00, 60))
    r += 1
    
    table.cell(info, 0, r, "Symbol Spot Agg", text_color=color.aqua, bgcolor=color.new(color.teal, 85))
    table.cell(info, 1, r, str.tostring(symAggSpotFinal, "#,###"), text_color=color.aqua, bgcolor=color.new(color.teal, 85))
    r += 1
    table.cell(info, 0, r, "BTC Spot Agg", text_color=color.orange, bgcolor=color.new(color.teal, 85))
    table.cell(info, 1, r, str.tostring(btcAggSpotFinal, "#,###"), text_color=color.orange, bgcolor=color.new(color.teal, 85))
    r += 1
    table.cell(info, 0, r, "Gold Spot Agg", text_color=color.yellow, bgcolor=color.new(color.teal, 85))
    table.cell(info, 1, r, str.tostring(goldAggSpotFinal, "#,###"), text_color=color.yellow, bgcolor=color.new(color.teal, 85))
    r += 1
    
    // PERP SECTION
    table.cell(info, 0, r, "=== PERP ===", text_color=color.blue, bgcolor=color.new(#00004d, 60))
    table.cell(info, 1, r, "", bgcolor=color.new(#00004d, 60))
    r += 1
    
    table.cell(info, 0, r, "Symbol Perp Agg", text_color=color.blue, bgcolor=color.new(color.navy, 85))
    table.cell(info, 1, r, str.tostring(symAggPerpFinal, "#,###"), text_color=color.blue, bgcolor=color.new(color.navy, 85))
    r += 1
    table.cell(info, 0, r, "BTC Perp Agg", text_color=color.orange, bgcolor=color.new(color.navy, 85))
    table.cell(info, 1, r, str.tostring(btcAggPerpFinal, "#,###"), text_color=color.orange, bgcolor=color.new(color.navy, 85))
    r += 1
    table.cell(info, 0, r, "Gold Perp Agg", text_color=color.yellow, bgcolor=color.new(color.navy, 85))
    table.cell(info, 1, r, str.tostring(goldAggPerpFinal, "#,###"), text_color=color.yellow, bgcolor=color.new(color.navy, 85))
    r += 1
    
    // RATIOS
    table.cell(info, 0, r, "Perp / Spot Ratio", text_color=color.fuchsia, bgcolor=color.new(color.black, 70))
    table.cell(info, 1, r, str.tostring(perpSpotRatio, "0.##") + "x", text_color=color.fuchsia, bgcolor=color.new(color.black, 70))
    r += 1
    
    table.cell(info, 0, r, "BTC Spot / Symbol", text_color=color.orange, bgcolor=color.new(color.black, 70))
    table.cell(info, 1, r, str.tostring(btcSpotRatio, "0.##") + "x", text_color=color.orange, bgcolor=color.new(color.black, 70))
    r += 1
    
    table.cell(info, 0, r, ratioType + " Perp / Symbol", text_color=color.fuchsia, bgcolor=color.new(color.black, 70))
    table.cell(info, 1, r, str.tostring(ratioMain, "0.##") + "x", text_color=color.fuchsia, bgcolor=color.new(color.black, 70))
````
