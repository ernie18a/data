# Open Interest Sosala

- url: https://www.tradingview.com/script/sZS8ISS2-open-interest-sosala/
- type: indicator
- pine_id: PUB;95d74b96b6634b7b963755ed05532f32
- version: 1.0

## Description

Похоже, ваше описание слишком краткое, добавьте...

## Source Code

````pine
//@version=6
indicator('Open Interest', 'OI', format = format.volume)

var bool isCrypto = syminfo.type == 'crypto'
var string timeframe = not isCrypto and timeframe.isintraday ? '1D' : timeframe.period

string currencyMode = input.string('Coins', 'Display OI in', options = ['Coins', 'USD'], tooltip = 'Доступно только для крипто-инструментов: пересчёт ОИ из количества монет в долларовый эквивалент по текущей цене закрытия.')
bool useUsd = isCrypto and currencyMode == 'USD'

[oiOpen, oiHigh, oiLow, oiClose, oiColorCond, priceClose] = request.security(str.format('{0}_OI', ticker.standard(syminfo.tickerid)), timeframe, [open, high, low, close, close > close[1], close[0]], ignore_invalid_symbol = true)

if barstate.islastconfirmedhistory and na(oiClose)
    runtime.error(str.format('No Open Interest data found for the `{0}` symbol.', syminfo.prefix + ':' + syminfo.ticker))

color openInterestColor = oiColorCond ? color.teal : color.red

float mult = useUsd ? close : 1.0

plot(isCrypto ? na : oiClose, 'Futures Open Interest', openInterestColor, style = plot.style_stepline, linewidth = 4)

float plotOpen  = oiOpen
float plotHigh  = oiHigh
float plotLow   = oiLow
float plotClose = oiClose

if not isCrypto
    plotOpen  := na
    plotHigh  := na
    plotLow   := na
    plotClose := na
else
    plotOpen  := oiOpen  * mult
    plotHigh  := oiHigh  * mult
    plotLow   := oiLow   * mult
    plotClose := oiClose * mult

plotcandle(plotOpen, plotHigh, plotLow, plotClose, 'Crypto Open Interest', color = openInterestColor, wickcolor = openInterestColor, bordercolor = openInterestColor)
````
