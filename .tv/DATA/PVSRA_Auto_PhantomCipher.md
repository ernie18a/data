<!-- tradingview-pine-id: PUB;6db047bf184b4e4f9b867d4eeab3e827 -->
<!-- tradingview-pine-version: 1.0 -->
<!-- tradingviewscripts-format: 1 -->
# PVSRA Auto [PhantomCipher]

Source: https://www.tradingview.com/script/jZR20JlW-PVSRA-Auto-PhantomCipher/

## Description

PVSRA Auto

PVSRA Auto colours volume by how unusual it is, using the PVSRA (Price, Volume, Support and Resistance Analysis) method. Candles with unusually high volume, often called "vector candles", stand out from ordinary ones, so you can see where larger participants may be active.

SNAPSHOT: a 15m chart with the indicator in its pane, showing green, red, blue and fuchsia vector volume among grey normal volume

Shown on the 15-minute chart
The snapshots use the 15-minute timeframe. The indicator works on any timeframe, because each candle is always compared with the 10 candles before it on the same chart.

How it works
Each candle's volume is compared with the average volume of the previous 10 candles:

[*]Peak (200%): volume is at least twice that average, or volume multiplied by the candle's range (high minus low) is the highest of the last 10 candles. Green for bullish, red for bearish.
[*]Rising (150%): volume is at least 1.5 times that average. Blue for bullish, fuchsia for bearish.
[*]Normal: everything else. Light grey for bullish, dark grey for bearish.

A candle counts as bullish when it closes above its open, and bearish otherwise.

The two tests behind a Peak candle:
[pine]
volume >= averageVolume * 2 or volume * (high - low) >= highest10_hl_weightedVolume
[/pine]

SNAPSHOT: a 15m close-up of a Peak vector candle, with its volume column and candle colour side by side

Volume Source Settings

[*]Use Vol of the equivalent BINANCE PERP Chart: on by default. On crypto symbols, the indicator reads volume and prices from the matching Binance perpetual (for example BINANCE:BTCUSDT.P), which usually has deeper volume than a single spot exchange. If that perpetual doesn't exist, it uses the chart's own data.
[*]Force Symbol: off by default. When checked, every calculation uses the symbol you pick instead, on any market.

Candle Colours

[*]Set PVSRA candle colours on chart: off by default. When checked, the chart's candles take the same colours as the volume columns. Turning off candle borders in the chart settings makes the colours easier to read.
[*]All six colours (Peak, Rising and Normal, each bullish and bearish) can be changed in the same section.

Alerts

[*]Any Vector Candle
[*]Any Volume Peak(200%) Vector Candle
[*]Any Volume Rising(150%) Vector Candle
[*]Volume Peak(200%) Bullish / Bearish Vector Candle
[*]Volume Rising(150%) Bullish / Bearish Vector Candle

Create alerts with Once Per Bar Close. Volume keeps building while a candle is open, so a candle can become a vector candle, or change class, before it closes.

Limitations

[*]When volume comes from a Binance perpetual or a forced symbol, the colours describe that market's volume and candle direction, which can differ slightly from the chart you're viewing.
[*]The symbol, or the source it reads from, must have volume data.

Example chart: [symbol="BYBIT:BTCUSDT.P"]BYBIT:BTCUSDT.P[/symbol]

This indicator highlights unusual volume. It's not a trading signal on its own, so combine it with your own analysis and risk management.

---

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © phantomcipher

//@version=6
indicator(title = "PVSRA Auto [PhantomCipher]", shorttitle="PVSRA Auto [PhantomCipher]", overlay=false, scale=scale.right, format=format.volume)

//   Situation "Peak"
//   Bars with volume >= 200% of the average volume of the 10 previous chart TFs, and bars
//   where the product of candle spread x candle volume is >= the highest for the 10 previous

//   Situation "Volume Rising Above Average"
//   Bars with volume >= 150% of the average volume of the 10 previous chart TFs.
//   Default Colors:  Bull bars are blue and bear are blue-violet.

var settingsGroupSource = "Volume Source Settings"


var bool useBinancePerp = input.bool(defval=true, title="Use Vol of the equivalent BINANCE PERP Chart (If Available)", tooltip="This will only apply to Crypto Symbols and will revert to the actual charts volume if the Binance Perp Chart does not exist.", group=settingsGroupSource, display = display.none)

var bool force_imnt = input.bool(defval=false, title="Force Symbol", inline="0", group=settingsGroupSource, display = display.none)
var string pvsra_sym = input.symbol(title="", defval="BINANCE:BTCUSDT.P", inline="0", tooltip="If checked, this will force the volume profile to be used from the selected symbol and will ignore setting above.", group=settingsGroupSource, display = display.none)

var settingsGroupCandles = "Candle Colours"
bool setCandleColours = input(false,title="Set PVSRA candle colours on chart", group=settingsGroupCandles, tooltip="To help improve display uncheck the candle borders in the chart settings.", display = display.none)
var Bull200CandleColor = input.color(color.new(color.lime, 0), title="200% Volume", group=settingsGroupCandles, inline="1", display = display.none)  
var Bear200CandleColor = input.color(color.new(color.red, 0), title="", group=settingsGroupCandles, inline = "1", display = display.none) 
var Bull150CandleColor = input.color(color.new(color.blue, 0), title="150% Volume", group=settingsGroupCandles, inline="2", display = display.none)   
var Bear150CandleColor = input.color(color.new(color.fuchsia, 0), title="", group=settingsGroupCandles, inline="2", display = display.none)  
var BullNormCandleColor = input.color(color.new(#999999, 0), title="Norm Volume", group=settingsGroupCandles, inline="3", display = display.none)
var BearNormCandleColor = input.color(color.new(#4d4d4d, 0), title="", group=settingsGroupCandles, inline="3", display = display.none)


var color candleColor = na

var string binancePerpSymbol = na
binancePerpSymbol := "BINANCE:"+syminfo.basecurrency + syminfo.currency+".P"
var bool isCrypto = (syminfo.type == "crypto")

pvsra_imntAll(sresolution) => request.security(force_imnt ? pvsra_sym : (useBinancePerp and isCrypto)? binancePerpSymbol : syminfo.tickerid ,sresolution,[volume,high,low,close,open], barmerge.gaps_off,barmerge.lookahead_off,ignore_invalid_symbol=true)

[volume_imnt,high_imnt,low_imnt,close_imnt,open_imnt] = pvsra_imntAll("")

if (force_imnt == true or useBinancePerp == true ) and na(volume_imnt) 
    volume_imnt := volume
    high_imnt := high
    low_imnt := low
    close_imnt := close
    open_imnt := open

var float highest10_hl_weightedVolume = na
var float hl_weightedVolume = na 
var float averageVolume = na 

// PVSRA Calculation 
averageVolume := ta.sma(volume_imnt[1], 10)
hl_weightedVolume := volume_imnt * (high_imnt - low_imnt) 
highest10_hl_weightedVolume := ta.highest(hl_weightedVolume[1], 10)

va150 = volume_imnt >= averageVolume * 1.5 ? 150 : 0
va = volume_imnt >= averageVolume * 2 or hl_weightedVolume >= highest10_hl_weightedVolume ? 200 : va150

// Bull or bear Candle Colors
isBull =  close_imnt > open_imnt 

// Bullish or bearish coloring

is200Bull = false
is150Bull = false
is100Bull = false
is200Bear = false
is150Bear = false
is100Bear = false
isVector = false




if isBull
    if va == 200
        candleColor := Bull200CandleColor
        is200Bull := true
        isVector :=true
    else if va == 150 
        candleColor := Bull150CandleColor
        is150Bull := true
        isVector :=true
    else 
        is100Bull := true
        isVector :=false
        candleColor := BullNormCandleColor
else
    if va == 200
        candleColor := Bear200CandleColor 
        is200Bear := true
        isVector :=true
    else if va == 150
        candleColor := Bear150CandleColor
        is150Bear := true
        isVector :=true
    else 
        is100Bear := true
        candleColor := BearNormCandleColor
        isVector :=false
 
var color NO_COLOR = na

barcolor(setCandleColours ? candleColor : NO_COLOR)


// Plot volume with volume formatting to encourage compact display
plot(volume_imnt, style=plot.style_columns, linewidth=1, color = candleColor, title="Volume", format=format.volume)

alertcondition(isVector, title="Any Vector Candle", message="{{ticker}} Vector Candle on the {{interval}}")// 
alertcondition((is200Bull or is200Bear), title="Any Volume Peak(200%) Vector Candle", message="{{ticker}} 200% Peak Vector Candle on the {{interval}}")
alertcondition((is150Bull or is150Bear), title="Any Volume Rising(150%) Vector Candle", message="{{ticker}} 150% Vector Candle on the {{interval}}")

alertcondition(is200Bear, title="Volume Peak(200%) Bearish Vector Candle", message="{{ticker}} 200% Peak Bearish Vector Candle on the {{interval}}")
alertcondition(is200Bull, title="Volume Peak(200%) Bullish Vector Candle", message="{{ticker}} 200% Peak Bullish Vector Candle on the {{interval}}")
alertcondition(is150Bear, title="Volume Rising(150%) Bearish Vector Candle", message="{{ticker}} 150% Bearish Vector Candle on the {{interval}}")
alertcondition(is150Bull, title="Volume Rising(150%) Bullish Vector Candle", message="{{ticker}} 150% Vector Candle on the {{interval}}")
````
