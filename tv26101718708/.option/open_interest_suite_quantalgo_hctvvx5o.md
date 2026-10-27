# Open Interest Suite [QuantAlgo]

- url: https://www.tradingview.com/script/hCTvvx5o-Open-Interest-Suite-QuantAlgo/
- type: indicator
- pine_id: PUB;352bd1f1ed154679a49e7325d3a36b1e
- version: 1.0

## Description

[b]🟢 Overview[/b]

The [b]Open Interest (OI) Suite[/b] is a comprehensive OI visualization and analysis tool built specifically for crypto perpetual futures traders. It reads open interest data directly from TradingView-supported exchanges, giving you a way to monitor how many active contracts are currently open in the market. Whether you are tracking a single exchange or aggregating OI across venues like Binance, Bybit, Bitget, Coinbase, Kraken, HTX, BitMEX, and OKX, this indicator is one of the most powerful contextual tools available, allowing traders to quickly gauge overall perpetual futures market positioning.
[image]https://www.tradingview.com/x/h0qhZVwU/[/image]
[b]🟢 What is Open Interest?[/b]

Open interest (OI) is the total number of live contracts between buyers and sellers at any given moment. Every long is matched to a short at a 1:1 ratio, so OI gives you a strong sense of how much capital and how many positions are currently committed to the market. Rising OI suggests new money and new positions are entering. Falling OI suggests positions are being closed or liquidated. When combined with price action, OI becomes one of the most valuable lenses available for understanding what is likely happening beneath the surface of price movement in perpetual markets.
[image]https://www.tradingview.com/x/C0yfkclA/[/image]
[b]🟢 How It Works[/b]

The indicator operates in two distinct modes. In Single (Chart) mode, it automatically reads open interest from whichever supported exchange and perpetual contract you are currently viewing, requiring no manual configuration. In Aggregated mode, it fetches OI from some of the highest-volume exchanges in crypto, for example, Binance, Bybit, Bitget, Coinbase, Kraken, HTX, BitMEX, and OKX, combines them into a single composite total, and gives you a cross-market view of positioning that no individual exchange feed can provide on its own. For each exchange in Aggregated mode, OI is fetched across both USDT and USDC perpetual pairs where applicable, then converted to a unified measure before summing. More exchanges will be added as their data becomes available on TradingView.
[image]https://www.tradingview.com/x/yc1LQdTH/[/image]

The Measure setting controls how OI values are expressed. In Coins mode, values are kept in their native unit, which may be more useful when you want to observe raw contract volume independent of price fluctuations. In Dollars mode, coin quantities are multiplied by the current bar price to convert values into USD, which is the standard way most traders and data providers report OI and tends to make cross-asset comparisons more intuitive. For exchanges that report natively in USD, the conversion is handled in reverse when Coins mode is active.
[image]https://www.tradingview.com/x/r0pZp9Aa/[/image]
[b]🟢 Key Features[/b]

[b]▶ View Modes[/b]

The indicator offers four ways to visualize OI, each suited to a different analytical purpose.

[b]1. Candles:[/b] Renders OI as full OHLC candlesticks, displaying open, high, low, and close OI for every bar. This is the richest view for studying OI structure, trends, compression, and expansion over time. You can watch OI build or unwind bar by bar similarly to how you read price action, which may help with spotting periods of aggressive position-building or rapid deleverage.

[b]2. Lines:[/b] Renders OI as a single continuous line using the close value of each bar. Cleaner and less visually demanding than candles, this mode works well for maintaining OI context alongside other indicators without crowding the chart.

[b]3. Change:[/b] Displays the bar-over-bar absolute difference in OI as a histogram. Positive bars indicate net new positions were likely opened. Negative bars suggest net positions were closed or liquidated. This mode can help identify the bars where positioning shifted most dramatically, which often corresponds to high-conviction entries, forced liquidations, or possible trend exhaustion.

[b]4. Change (%):[/b] The same histogram expressed as a percentage of the prior bar OI value. This normalises the signal across different asset sizes and OI magnitudes, which could make it easier to compare positioning dynamics between a large-cap asset and a smaller altcoin.
[image]https://www.tradingview.com/x/ixJAnEGw/[/image]
[b]▶ Aggregated Mode and Exchange Selection[/b]

In Aggregated mode, each of the eight supported exchanges can be toggled on or off independently. This flexibility allows several useful configurations beyond a simple total. You can enable only one exchange to track that specific venue regardless of which chart you are currently viewing. You can also add the indicator to your layout multiple times with a different single exchange selected each time, letting you compare individual exchange OI side by side on the same chart.
[image]https://www.tradingview.com/x/heY8oFh9/[/image]
[b]▶ Color Presets[/b]

Five built-in color presets (Classic, Aqua, Cosmic, Cyber, Neon) allow you to match the indicator's appearance to your chart setup with a single click. A Custom preset exposes individual color pickers for bull, bear, and line colors, giving full control over every visual element including candle bodies, wicks, borders, histogram columns, and the line overlay.
[image]https://www.tradingview.com/x/w0UVzknJ/[/image]
[b]▶ Unsupported Exchange Warning[/b]

When Single (Chart) mode is active and the current exchange does not provide open interest data on TradingView, the indicator displays a warning label on the chart identifying the unsupported exchange and listing supported alternatives.
[image]https://www.tradingview.com/x/Y7hkvJsb/[/image]
[b]🟢 Price + OI Interpretation[/b]

Reading OI in isolation is only part of the picture. More meaningful analysis tends to come from combining OI direction with price action and, where available, volume data, along with other trend-following or mean-reversion indicators.

Examples:

[b]1. Price Up + OI Up:[/b] New capital is likely entering on the long side. This could indicate bullish trend continuation, with fresh positioning supporting the move rather than just short covering. The stronger the OI growth relative to price movement, the higher the probability that the trend has genuine participation behind it.
[image]https://www.tradingview.com/x/p5iUK8Nm/[/image]
[b]2. Price Down + OI Up:[/b] New shorts are probably being added aggressively. Bearish momentum may be building through fresh positioning, which tends to be a more sustained signal than a move driven purely by long liquidations.
[image]https://www.tradingview.com/x/rvjmEYqK/[/image]
[b]3. Price Down + OI Down:[/b] Longs are likely closing or being liquidated. The selling pressure in this scenario is coming from position unwinds rather than new short entries, which could sometimes suggest exhaustion near a local low rather than fresh trend initiation.
[image]https://www.tradingview.com/x/vHLWp55m/[/image]
[b]4. Price Up + OI Down:[/b] Shorts are probably closing or being squeezed out. This is the likely mechanics of a short squeeze: buyers overwhelm sellers, underwater shorts cover, and the resulting buy pressure may accelerate the move higher. This pattern tends to produce some of the fastest and sharpest price moves seen in crypto perpetual markets.
[image]https://www.tradingview.com/x/Q9hA2Rf3/[/image]
It is worth noting that for every short there is a long. When OI increases during a downtrend, it does not necessarily mean only shorts are entering. Longs are participating too, often more passively through limit orders. [url=https://www.tradingview.com/script/UFnl9AgC-Cumulative-Volume-Delta-CVD-Suite-QuantAlgo/]Cumulative Volume Delta (CVD)[/url] can help distinguish which side is more likely driving the flow, since it measures aggressive buying versus aggressive selling pressure within each bar.

[b]🟢 Important Notes[/b]

[b]1.[/b] This indicator is designed exclusively for crypto perpetual futures and will not produce output on spot tickers, equity symbols, or any instrument without a corresponding OI feed on TradingView. In Single (Chart) mode, if the exchange you are viewing is not among the currently supported venues (Binance, Bybit, Bitget, Coinbase, Kraken, HTX, BitMEX, and OKX), the indicator will display a warning and produce no data. Switching to a supported exchange will restore functionality. More exchanges will be added as their data becomes available on TradingView.

[b]2.[/b] OI is most useful as a context layer rather than a standalone signal. Using it alongside price structure, volume, and order flow analysis may help you assess whether a move is likely backed by new positioning or driven by position unwinds. That distinction could have meaningful implications for how far a move extends and how quickly it might reverse.

## Source Code

````pine
// This script is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © QuantAlgo

//@version=6
indicator('Open Interest Suite [QuantAlgo]', overlay = false, format = format.volume, precision = 2)

//              ╔════════════════════════════════╗              //
//              ║      USER-DEFINED SETTINGS     ║              //
//              ╚════════════════════════════════╝              //

var string group_type      = '═══════════ OI Type ═══════════'
var string group_exchanges = '══════════ Exchanges ══════════'
var string group_display   = '═══════════ Display ═══════════'
var string group_colors    = '═══════════ Colors ═══════════'

tooltip_type      = 'Single (Chart): automatically reads open interest from the exchange and perpetual contract you are currently viewing on the chart. Works with any supported exchange without any manual setup.\n\nAggregated: combines open interest from all exchanges you enable in the Exchanges section. Each enabled exchange contributes its OI to a single total, giving a cross-market view of positioning.\n\nTip: in Aggregated mode, you can enable only one exchange to monitor that specific exchange OI regardless of which exchange you are currently charting. You can also add this indicator to your chart multiple times with a different single exchange selected each time, letting you compare individual exchange OI on the same layout.'
tooltip_binance   = 'Include Binance open interest in the aggregated total.'
tooltip_bybit     = 'Include Bybit open interest in the aggregated total.'
tooltip_coinbase  = 'Include Coinbase open interest in the aggregated total.'
tooltip_kraken    = 'Include Kraken open interest in the aggregated total.'
tooltip_okx       = 'Include OKX open interest in the aggregated total.'
tooltip_bitget    = 'Include Bitget open interest in the aggregated total.'
tooltip_htx       = 'Include HTX (formerly Huobi) open interest in the aggregated total.'
tooltip_bitmex    = 'Include BitMEX open interest in the aggregated total.'
tooltip_measure   = 'Dollars: converts all open interest values into USD by multiplying coin quantities by the current bar price. This is the standard way most traders and data providers display OI, making it easy to compare across assets.\n\nCoins: displays open interest in the native coin unit (e.g. BTC, ETH). Useful when you want to see the raw number of contracts regardless of price. For exchanges that report in USD natively, the coin value is calculated by dividing by price.'
tooltip_view      = 'Candles: renders OI as full OHLC candlesticks, showing open, high, low, and close OI values for each bar. Best for spotting OI structure, trends, and reversals.\n\nLines: renders OI as a single continuous line using the close value of each bar. Cleaner and less visually demanding than candles.\n\nChange: displays the bar-over-bar absolute change in OI as a histogram. Positive bars mean OI increased (new positions opened or shorts covered), negative bars mean OI decreased (positions closed).\n\nChange (%): same as Change but expressed as a percentage of the prior bar OI value. Useful for normalising across different asset sizes.'
tooltip_preset    = 'Select a pre-configured color scheme for the OI candles and histogram bars.\n\nClassic: bright green for bullish and red for bearish.\nAqua: sky blue for bullish and orange for bearish.\nCosmic: cyan-green for bullish and purple for bearish.\nCyber: teal for bullish and orange-red for bearish.\nNeon: yellow for bullish and magenta for bearish.\nCustom: use the individual color pickers below to set your own colors.'
tooltip_bullColor = 'Bull color applied to candle bodies, wicks, and borders on up bars, and to positive histogram columns. Only active when Color Preset is set to Custom.'
tooltip_bearColor = 'Bear color applied to candle bodies, wicks, and borders on down bars, and to negative histogram columns. Only active when Color Preset is set to Custom.'
tooltip_line      = 'Color of the line in Lines view mode. Also used as the fallback line color in Candles mode before enough OHLC data has accumulated.'


//              ╔════════════════════════════════╗              //
//              ║          OI TYPE INPUT         ║              //
//              ╚════════════════════════════════╝              //

type = input.string('Single (Chart)', 'Type', options = ['Single (Chart)', 'Aggregated'], group = group_type, tooltip = tooltip_type)

//              ╔════════════════════════════════╗              //
//              ║        EXCHANGE TOGGLES        ║              //
//              ╚════════════════════════════════╝              //

showBinance  = input.bool(true,  'Binance',     group = group_exchanges, tooltip = tooltip_binance)
showBybit    = input.bool(true,  'Bybit',       group = group_exchanges, tooltip = tooltip_bybit)
showCoinbase = input.bool(true,  'Coinbase',    group = group_exchanges, tooltip = tooltip_coinbase)
showKraken   = input.bool(true,  'Kraken',      group = group_exchanges, tooltip = tooltip_kraken)
showOKX      = input.bool(true,  'OKX',         group = group_exchanges, tooltip = tooltip_okx)
showBitget   = input.bool(false, 'Bitget',      group = group_exchanges, tooltip = tooltip_bitget)
showHTX      = input.bool(false, 'HTX (Huobi)', group = group_exchanges, tooltip = tooltip_htx)
showBitMEX   = input.bool(false, 'BitMEX',      group = group_exchanges, tooltip = tooltip_bitmex)

//              ╔════════════════════════════════╗              //
//              ║        DISPLAY SETTINGS        ║              //
//              ╚════════════════════════════════╝              //

measure = input.string('Coins', 'Measure', options = ['Coins', 'Dollars'],                         group = group_display, tooltip = tooltip_measure)
view    = input.string('Candles', 'View',  options = ['Candles', 'Lines', 'Change', 'Change (%)'], group = group_display, tooltip = tooltip_view)

//              ╔════════════════════════════════╗              //
//              ║         COLOR SETTINGS         ║              //
//              ╚════════════════════════════════╝              //

colorPreset  = input.string('Custom', 'Color Preset', options = ['Classic', 'Aqua', 'Cosmic', 'Cyber', 'Neon', 'Custom'], group = group_colors, tooltip = tooltip_preset)
bullColorIn  = input.color(#00ffaa, 'Bull Color', group = group_colors, tooltip = tooltip_bullColor)
bearColorIn  = input.color(#ff0000, 'Bear Color', group = group_colors, tooltip = tooltip_bearColor)
lineColorIn  = input.color(#00ffaa, 'Line Color', group = group_colors, tooltip = tooltip_line)

[bullColor, bearColor] = switch colorPreset
    'Classic' => [color(#00ff00), color(#ff0000)]
    'Aqua'    => [color(#00bfff), color(#ff8c00)]
    'Cosmic'  => [color(#49ffce), color(#9932cc)]
    'Cyber'   => [color(#00cccc), color(#ff6600)]
    'Neon'    => [color(#ffff00), color(#ff00ff)]
    'Custom'  => [bullColorIn,    bearColorIn]

lineColor = colorPreset == 'Custom' ? lineColorIn : bullColor


//              ╔════════════════════════════════╗              //
//              ║         SYMBOL PARSING         ║              //
//              ╚════════════════════════════════╝              //

exchange = syminfo.prefix
asset    = str.replace(str.replace(str.replace(str.replace(str.replace(str.replace(str.replace(str.replace(
     syminfo.ticker, 'USDT', ''), 'USDC', ''), 'GUSD', ''), 'USD', ''), '.PUM', ''), '.PM', ''), '.P', ''), 'PERP', '')

isSupported = exchange == 'BINANCE' or exchange == 'BYBIT'  or exchange == 'BITGET' or
     exchange == 'COINBASE' or exchange == 'KRAKEN' or exchange == 'HTX' or
     exchange == 'BITMEX'   or exchange == 'OKX'

isUSDNative = exchange == 'KRAKEN' or exchange == 'OKX'

//              ╔════════════════════════════════╗              //
//              ║            OI FETCH            ║              //
//              ╚════════════════════════════════╝              //

fetchOI(sym) =>
    [o, h, l, c] = request.security(sym + '_OI', timeframe.period, [open, high, low, close], ignore_invalid_symbol = true)
    [o, h, l, c]

convert(val, px, usdNative) =>
    if na(val)
        float(na)
    else if measure == 'Dollars'
        usdNative ? val : val * px
    else
        usdNative ? (px != 0 ? val / px : float(na)) : val

//              ╔════════════════════════════════╗              //
//              ║          SINGLE MODE           ║              //
//              ╚════════════════════════════════╝              //

symbol = syminfo.prefix + ':' + syminfo.ticker
[sO, sH, sL, sC] = fetchOI(symbol)

singleOpen  = convert(sO, open,  isUSDNative)
singleHigh  = convert(sH, high,  isUSDNative)
singleLow   = convert(sL, low,   isUSDNative)
singleClose = convert(sC, close, isUSDNative)

//              ╔════════════════════════════════╗              //
//              ║        AGGREGATED MODE         ║              //
//              ╚════════════════════════════════╝              //

[binUsdtO,    binUsdtH,    binUsdtL,    binUsdtC]    = fetchOI('BINANCE:' + asset + 'USDT.P')
[binUsdcO,    binUsdcH,    binUsdcL,    binUsdcC]    = fetchOI('BINANCE:' + asset + 'USDC.P')
[bybitUsdtO,  bybitUsdtH,  bybitUsdtL,  bybitUsdtC]  = fetchOI('BYBIT:'   + asset + 'USDT.P')
[bybitUsdcO,  bybitUsdcH,  bybitUsdcL,  bybitUsdcC]  = fetchOI('BYBIT:'   + asset + 'USDC.P')
[bitgetUsdtO, bitgetUsdtH, bitgetUsdtL, bitgetUsdtC] = fetchOI('BITGET:'  + asset + 'USDT.P')
[bitgetUsdcO, bitgetUsdcH, bitgetUsdcL, bitgetUsdcC] = fetchOI('BITGET:'  + asset + 'USDC.P')
[coinbaseO,   coinbaseH,   coinbaseL,   coinbaseC]   = fetchOI('COINBASE:' + asset + 'USDC.P')
[krakenO,     krakenH,     krakenL,     krakenC]     = fetchOI('KRAKEN:'  + asset + 'USD.PM')
[htxO,        htxH,        htxL,        htxC]        = fetchOI('HTX:'     + asset + 'USDT.P')
[bitmexO,     bitmexH,     bitmexL,     bitmexC]     = fetchOI('BITMEX:'  + asset + 'USDT.P')
[okxO,        okxH,        okxL,        okxC]        = fetchOI('OKX:'     + asset + 'USDT.P')

aggregate(binUsdt, binUsdc, bybitUsdt, bybitUsdc, bitgetUsdt, bitgetUsdc,
          coinbase, kraken, htx, bitmex, okx, px) =>
    t = 0.0
    t += showBinance  and not na(binUsdt)    ? convert(binUsdt,    px, false) : 0.0
    t += showBinance  and not na(binUsdc)    ? convert(binUsdc,    px, false) : 0.0
    t += showBybit    and not na(bybitUsdt)  ? convert(bybitUsdt,  px, false) : 0.0
    t += showBybit    and not na(bybitUsdc)  ? convert(bybitUsdc,  px, false) : 0.0
    t += showBitget   and not na(bitgetUsdt) ? convert(bitgetUsdt, px, false) : 0.0
    t += showBitget   and not na(bitgetUsdc) ? convert(bitgetUsdc, px, false) : 0.0
    t += showCoinbase and not na(coinbase)   ? convert(coinbase,   px, false) : 0.0
    t += showKraken   and not na(kraken)     ? convert(kraken,     px, true)  : 0.0
    t += showHTX      and not na(htx)        ? convert(htx,        px, false) : 0.0
    t += showBitMEX   and not na(bitmex)     ? convert(bitmex,     px, false) : 0.0
    t += showOKX      and not na(okx)        ? convert(okx,        px, true)  : 0.0
    t

aggOpen  = aggregate(binUsdtO,  binUsdcO,  bybitUsdtO,  bybitUsdcO,  bitgetUsdtO,  bitgetUsdcO,  coinbaseO, krakenO, htxO, bitmexO, okxO, open)
aggHigh  = aggregate(binUsdtH,  binUsdcH,  bybitUsdtH,  bybitUsdcH,  bitgetUsdtH,  bitgetUsdcH,  coinbaseH, krakenH, htxH, bitmexH, okxH, high)
aggLow   = aggregate(binUsdtL,  binUsdcL,  bybitUsdtL,  bybitUsdcL,  bitgetUsdtL,  bitgetUsdcL,  coinbaseL, krakenL, htxL, bitmexL, okxL, low)
aggClose = aggregate(binUsdtC,  binUsdcC,  bybitUsdtC,  bybitUsdcC,  bitgetUsdtC,  bitgetUsdcC,  coinbaseC, krakenC, htxC, bitmexC, okxC, close)

//              ╔════════════════════════════════╗              //
//              ║         ACTIVE SERIES          ║              //
//              ╚════════════════════════════════╝              //

isSingle = type == 'Single (Chart)'

oiOpen  = isSingle ? singleOpen  : aggOpen
oiHigh  = isSingle ? singleHigh  : aggHigh
oiLow   = isSingle ? singleLow   : aggLow
oiClose = isSingle ? singleClose : aggClose

//              ╔════════════════════════════════╗              //
//              ║           VIEW LOGIC           ║              //
//              ╚════════════════════════════════╝              //

isUp        = oiClose >= oiOpen
bodyColor   = isUp ? bullColor : bearColor
wickColor   = isUp ? bullColor : bearColor
borderColor = isUp ? bullColor : bearColor

changeVal = oiClose - oiClose[1]
changePct = oiClose[1] != 0 ? (oiClose / oiClose[1] - 1) * 100 : na
color changeColor = changeVal >= 0 ? bullColor : bearColor
color pctColor    = changePct  >= 0 ? bullColor : bearColor

isCandles   = view == 'Candles'
isLines     = view == 'Lines'
isChange    = view == 'Change'
isChangePct = view == 'Change (%)'
hasOHLC     = ta.cum(oiOpen) > 0

//              ╔════════════════════════════════╗              //
//              ║        NO-DATA WARNING         ║              //
//              ╚════════════════════════════════╝              //

var label noDataLabel = na

if isSingle and not isSupported
    warningText = '\n⚠️  NO OPEN INTEREST DATA  ⚠️\n\n' + exchange + ' does not provide open interest data on TradingView.\n\nPlease switch to a supported exchange:\nBinance, Bybit, Bitget, Coinbase, Kraken, HTX, BitMEX, OKX\n'
    midPrice    = (high + low) / 2
    if na(noDataLabel)
        noDataLabel := label.new(x = bar_index, y = midPrice, text = warningText, xloc = xloc.bar_index, yloc = yloc.price, style = label.style_label_center, color = color.red, textcolor = color.white, size = size.huge, textalign = text.align_center)
    else
        label.set_x(noDataLabel, bar_index)
        label.set_y(noDataLabel, midPrice)
else
    if not na(noDataLabel)
        label.delete(noDataLabel)
        noDataLabel := na

//              ╔════════════════════════════════╗              //
//              ║             PLOTS              ║              //
//              ╚════════════════════════════════╝              //

canPlot = not isSingle or isSupported

plotcandle(
     canPlot and isCandles ? oiOpen  : na,
     canPlot and isCandles ? oiHigh  : na,
     canPlot and isCandles ? oiLow   : na,
     canPlot and isCandles and hasOHLC ? oiClose : na,
     'OI Candles',
     color = bodyColor, wickcolor = wickColor, bordercolor = borderColor, editable = false)

plot(canPlot and (isLines or (isCandles and not hasOHLC)) ? oiClose : na,
     'OI Line', color = lineColor, style = plot.style_line, linewidth = 3)

plot(canPlot and isChange    ? changeVal : na, 'OI Change',     color = changeColor, style = plot.style_columns)
plot(canPlot and isChangePct ? changePct : na, 'OI Change (%)', color = pctColor,    style = plot.style_columns)

hline(not isCandles and not isLines ? 0 : na, 'Zero', color = color.new(color.gray, 50), linestyle = hline.style_dashed)


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
