# Williams Fractals Ultimate (Low Latency)

- url: https://www.tradingview.com/script/eY33jEO4/
- type: indicator
- pine_id: PUB;1852fb1cfd26444db66ac4c46f4dafbc
- version: 1.0

## Description

拐点分型显示

## Source Code

````pine
//@version=6
indicator("Williams Fractals Ultimate (Low Latency)", shorttitle="Fractals Fast", overlay=true, format=format.price, precision=0)

// ———— 低延迟参数 ————
fractalPeriod    = input.int(title="分形周期", defval=3, minval=2) // 3比5快
donchianPeriod   = input.int(title="唐奇安周期", defval=20, minval=1)
applyDonchFilter = input.bool(title="启用唐奇安过滤", defval=true)
showLines        = input.bool(title="显示分形折线", defval=false)

// 唐奇安通道
upperDonch = ta.highest(high, donchianPeriod)
lowerDonch = ta.lowest(low, donchianPeriod)
baseline   = (upperDonch + lowerDonch) / 2

// ———— 分形计算（精简提速） ————
fp = fractalPeriod
upFractal = true
for i = 1 to fp
    upFractal := upFractal and (high[fp-i] < high[fp]) and (high[fp+i] < high[fp])

dnFractal = true
for i = 1 to fp
    dnFractal := dnFractal and (low[fp-i] > low[fp]) and (low[fp+i] > low[fp])

// 过滤
showUp = upFractal and (not applyDonchFilter or high[fp] > baseline[fp])
showDn = dnFractal and (not applyDonchFilter or low[fp] < baseline[fp])

// ———— 关键：offset=-2 消除人为延迟 ————
plotshape(showUp, style=shape.triangledown, location=location.abovebar, offset=-2, color=#F44336, size=size.small)
plotshape(showDn, style=shape.triangleup,   location=location.belowbar, offset=-2, color=#009688, size=size.small)

// 折线（略，同原代码）
var float lastSwingPrice = na
var int   lastSwingBar   = na
var int   lastSwingType  = 0
var float candidatePrice = na
var int   candidateBar   = na
var line  lastLine       = na

updateLine(_bar, _price) =>
    if not na(lastLine)
        line.set_xy2(lastLine, _bar, _price)

if showLines
    if showUp
        candPrice = high[fp]
        candBar = bar_index - fp
        if na(lastSwingPrice)
            lastSwingPrice := candPrice, lastSwingBar := candBar, lastSwingType := 2
        else
            if lastSwingType == 2
                if na(candidatePrice) or candPrice > candidatePrice
                    candidatePrice := candPrice, candidateBar := candBar
                    updateLine(candidateBar, candidatePrice)
                    lastSwingPrice := candidatePrice, lastSwingBar := candidateBar
            else
                candidatePrice := candPrice, candidateBar := candBar
                lastLine := line.new(lastSwingBar, lastSwingPrice, candidateBar, candidatePrice, width=2, color=#009688)
                lastSwingPrice := candidatePrice, lastSwingBar := candidateBar, lastSwingType := 2, candidatePrice := na

    if showDn
        candPrice = low[fp]
        candBar = bar_index - fp
        if na(lastSwingPrice)
            lastSwingPrice := candPrice, lastSwingBar := candBar, lastSwingType := 1
        else
            if lastSwingType == 1
                if na(candidatePrice) or candPrice < candidatePrice
                    candidatePrice := candPrice, candidateBar := candBar
                    updateLine(candidateBar, candidatePrice)
                    lastSwingPrice := candidatePrice, lastSwingBar := candidateBar
            else
                candidatePrice := candPrice, candidateBar := candBar
                lastLine := line.new(lastSwingBar, lastSwingPrice, candidateBar, candidatePrice, width=2, color=#F44336)
                lastSwingPrice := candidatePrice, lastSwingBar := candidateBar, lastSwingType := 1, candidatePrice := na
````
