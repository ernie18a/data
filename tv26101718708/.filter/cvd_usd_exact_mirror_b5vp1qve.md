# CVD USD (Exact Mirror)

- url: https://www.tradingview.com/script/b5vp1QVE-cvd-usd-exact-mirror/
- type: indicator
- pine_id: PUB;ba8bd3cb3a244f489e90b25c11311ec9
- version: 1.0

## Description

Описание сликом краткое, опять, пожалуйстадобавь что либо

## Source Code

````pine
//@version=6
indicator("CVD USD (Exact Mirror)", "CVD USD", format=format.volume)

import TradingView/ta/8

// Входные параметры как в оригинале
anchorInput = input.timeframe("1D", "Anchor period")
useCustomTimeframeInput = input.bool(false, "Use custom timeframe")
lowerTimeframeInput = input.timeframe("1", "Timeframe", active = useCustomTimeframeInput)

var lowerTimeframe = switch
    useCustomTimeframeInput => lowerTimeframeInput
    timeframe.isseconds     => "1S"
    timeframe.isintraday    => "1"
    timeframe.isdaily       => "5"
    => "60"

// 1. Получаем дельту в МОНЕТАХ (как в оригинале)
[o, h, l, c] = ta.requestVolumeDelta(lowerTimeframe, anchorInput)

// 2. Конвертируем дельту текущего бара в USD по цене ЭТОГО ЖЕ бара
// Умножаем каждый параметр на цену закрытия текущего бара
oUSD = o * close
hUSD = h * close
lUSD = l * close
cUSD = c * close

// 3. Рисуем свечи (теперь они в долларах)
col = cUSD >= oUSD ? color.teal : color.red
hline(0)
plotcandle(oUSD, hUSD, lUSD, cUSD, "CVD USD", color = col, bordercolor = col, wickcolor = col)

// Проверка объема
var cumVol = 0.
cumVol += nz(volume)
if barstate.islast and cumVol == 0
    runtime.error("The data vendor doesn't provide volume data for this symbol.")
````
