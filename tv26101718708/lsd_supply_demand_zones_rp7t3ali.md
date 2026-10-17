# LSD Supply & Demand Zones

- url: https://www.tradingview.com/script/RP7T3alI-LSD-Supply-Demand-Zones/
- type: indicator
- pine_id: PUB;9ee1b64bd5bc46a698052eb813a617fd
- version: 7.0

## Description

This will mark out supply zones in red and demand zones in green. Accuracy zones are included - if the zone candles wick is larger than the candle after, it will only mark the candle from the body. Mitigated zones which are those tapped by opposing colour candles are not valid and aren't shown.

## Source Code

````pine
//@version=6
indicator("Supply & Demand Zones", overlay = true, max_boxes_count = 500, max_lines_count = 500)

lookback      = input.int(15,    "Swing Lookback", minval = 2, maxval = 50)
impulseLen    = input.int(3,     "Impulse Length", minval = 2, maxval = 10)
hideMitigated = input.bool(true, "Hide Mitigated Zones")
accuracyMode  = input.bool(false,"Accuracy Zones (clip oversized wicks)")
showMidline   = input.bool(true, "Show Zone Midline")
ageFilterOn   = input.bool(false,"Hide Zones Older Than")
ageLimit      = input.string("1 Week", "Max Zone Age", options=["1 Day", "1 Week", "1 Month"])
supplyColor   = input.color(color.new(color.red,   75), "Supply Zone Color")
demandColor   = input.color(color.new(color.green, 75), "Demand Zone Color")
borderSupply  = input.color(color.new(color.red,   20), "Supply Border Color")
borderDemand  = input.color(color.new(color.green, 20), "Demand Border Color")

isBullish(i) => close[i] > open[i]
isBearish(i) => close[i] < open[i]

isBullishImpulse(i) => close[i] > close[i + impulseLen]
isBearishImpulse(i) => close[i] < close[i + impulseLen]

ageLimitMs() =>
    if ageLimit == "1 Day"
        86400000
    else if ageLimit == "1 Week"
        604800000
    else
        2592000000

makeLine(leftBar, price, col) =>
    line.new(x1=leftBar, y1=price, x2=leftBar+1, y2=price, color=col, style=line.style_solid, width=1, extend=extend.right)

makeMidline(leftBar, topPrice, botPrice, col) =>
    mid = (topPrice + botPrice) / 2
    line.new(x1=leftBar, y1=mid, x2=leftBar+1, y2=mid, color=color.new(col, 40), style=line.style_dashed, width=1, extend=extend.right)

makeInvisibleLine() =>
    line.new(bar_index, close, bar_index + 1, close, color=color.new(color.white, 100))

var supplyTopLines  = array.new<line>()
var supplyBotLines  = array.new<line>()
var supplyMidLines  = array.new<line>()
var supplyFills     = array.new<linefill>()
var supplyActivated = array.new<bool>()
var supplyInZone    = array.new<bool>()
var supplyTime      = array.new<int>()
var supplyTops      = array.new<float>()

var demandTopLines  = array.new<line>()
var demandBotLines  = array.new<line>()
var demandMidLines  = array.new<line>()
var demandFills     = array.new<linefill>()
var demandActivated = array.new<bool>()
var demandInZone    = array.new<bool>()
var demandTime      = array.new<int>()
var demandBots      = array.new<float>()

pivot = lookback

if bar_index > lookback * 4

    // ── DEMAND ZONE ──
    if isBullishImpulse(pivot)
        impulseBase = pivot + impulseLen - 1
        zoneBar = -1
        for k = impulseBase + 1 to impulseBase + lookback
            if isBearish(k)
                zoneBar := k
                break

        if zoneBar != -1
            nextBar  = zoneBar - 1
            topPrice = accuracyMode ? (high[zoneBar] > high[nextBar] ? open[zoneBar] : high[zoneBar]) : high[zoneBar]
            botPrice = math.min(low[zoneBar], low[nextBar])

            alreadyMitigated = false
            for m = zoneBar - 1 to 1
                if isBearish(m) and low[m] <= topPrice
                    alreadyMitigated := true
                    break

            isDuplicate = false
            for p in demandBots
                if math.abs(p - botPrice) < syminfo.mintick * 5
                    isDuplicate := true

            if topPrice > botPrice and not isDuplicate and not alreadyMitigated
                tl = makeLine(bar_index[zoneBar], topPrice, borderDemand)
                bl = makeLine(bar_index[zoneBar], botPrice, borderDemand)
                lf = linefill.new(tl, bl, demandColor)
                ml = showMidline ? makeMidline(bar_index[zoneBar], topPrice, botPrice, color.green) : makeInvisibleLine()
                array.push(demandTopLines, tl)
                array.push(demandBotLines, bl)
                array.push(demandFills, lf)
                array.push(demandMidLines, ml)
                array.push(demandActivated, false)
                array.push(demandInZone, false)
                array.push(demandTime, time[zoneBar])
                array.push(demandBots, botPrice)

    // ── SUPPLY ZONE ──
    if isBearishImpulse(pivot)
        impulseBase = pivot + impulseLen - 1
        zoneBar = -1
        for k = impulseBase + 1 to impulseBase + lookback
            if isBullish(k)
                zoneBar := k
                break

        if zoneBar != -1
            nextBar  = zoneBar - 1
            botPrice = accuracyMode ? (low[zoneBar] < low[nextBar] ? open[zoneBar] : low[zoneBar]) : low[zoneBar]
            topPrice = math.max(high[zoneBar], high[nextBar])

            alreadyMitigated = false
            for m = zoneBar - 1 to 1
                if isBullish(m) and high[m] >= botPrice
                    alreadyMitigated := true
                    break

            isDuplicate = false
            for p in supplyTops
                if math.abs(p - topPrice) < syminfo.mintick * 5
                    isDuplicate := true

            if topPrice > botPrice and not isDuplicate and not alreadyMitigated
                tl = makeLine(bar_index[zoneBar], topPrice, borderSupply)
                bl = makeLine(bar_index[zoneBar], botPrice, borderSupply)
                lf = linefill.new(tl, bl, supplyColor)
                ml = showMidline ? makeMidline(bar_index[zoneBar], topPrice, botPrice, color.red) : makeInvisibleLine()
                array.push(supplyTopLines, tl)
                array.push(supplyBotLines, bl)
                array.push(supplyFills, lf)
                array.push(supplyMidLines, ml)
                array.push(supplyActivated, false)
                array.push(supplyInZone, false)
                array.push(supplyTime, time[zoneBar])
                array.push(supplyTops, topPrice)

if barstate.isconfirmed

    i = 0
    while i < array.size(demandTopLines)
        top      = line.get_price(array.get(demandTopLines, i), bar_index)
        bot      = line.get_price(array.get(demandBotLines, i), bar_index)
        zoneTime = array.get(demandTime, i)
        tooOld   = ageFilterOn and (timenow - zoneTime) > ageLimitMs()

        if not array.get(demandActivated, i) and isBullish(0) and close > top
            array.set(demandActivated, i, true)

        inZone = array.get(demandInZone, i)
        if low <= top and high >= bot
            array.set(demandInZone, i, true)
        if low > top and inZone
            array.set(demandInZone, i, false)

        if (hideMitigated and isBearish(0) and close <= top) or tooOld
            line.delete(array.get(demandTopLines, i))
            line.delete(array.get(demandBotLines, i))
            line.delete(array.get(demandMidLines, i))
            linefill.delete(array.get(demandFills, i))
            array.remove(demandTopLines, i)
            array.remove(demandBotLines, i)
            array.remove(demandMidLines, i)
            array.remove(demandFills, i)
            array.remove(demandActivated, i)
            array.remove(demandInZone, i)
            array.remove(demandTime, i)
            array.remove(demandBots, i)
        else
            i += 1

    j = 0
    while j < array.size(supplyTopLines)
        top      = line.get_price(array.get(supplyTopLines, j), bar_index)
        bot      = line.get_price(array.get(supplyBotLines, j), bar_index)
        zoneTime = array.get(supplyTime, j)
        tooOld   = ageFilterOn and (timenow - zoneTime) > ageLimitMs()

        if not array.get(supplyActivated, j) and isBearish(0) and close < bot
            array.set(supplyActivated, j, true)

        inZone = array.get(supplyInZone, j)
        if high >= bot and low <= top
            array.set(supplyInZone, j, true)
        if high < bot and inZone
            array.set(supplyInZone, j, false)

        if (hideMitigated and isBullish(0) and close >= bot) or tooOld
            line.delete(array.get(supplyTopLines, j))
            line.delete(array.get(supplyBotLines, j))
            line.delete(array.get(supplyMidLines, j))
            linefill.delete(array.get(supplyFills, j))
            array.remove(supplyTopLines, j)
            array.remove(supplyBotLines, j)
            array.remove(supplyMidLines, j)
            array.remove(supplyFills, j)
            array.remove(supplyActivated, j)
            array.remove(supplyInZone, j)
            array.remove(supplyTime, j)
            array.remove(supplyTops, j)
        else
            j += 1

// ── TOUCH SIGNAL PLOTS ────────────────────────────────────────────────────────
demandTouched = false
for i = 0 to array.size(demandTopLines) - 1
    if array.size(demandTopLines) == 0
        break
    top = line.get_price(array.get(demandTopLines, i), bar_index)
    bot = line.get_price(array.get(demandBotLines, i), bar_index)
    if low <= top and high >= bot
        demandTouched := true

supplyTouched = false
for j = 0 to array.size(supplyTopLines) - 1
    if array.size(supplyTopLines) == 0
        break
    top = line.get_price(array.get(supplyTopLines, j), bar_index)
    bot = line.get_price(array.get(supplyBotLines, j), bar_index)
    if high >= bot and low <= top
        supplyTouched := true

// Zone Touch first so it appears as default in alert dropdown
plot(demandTouched or supplyTouched ? 1 : 0, title="Zone Touch",        color=color.new(color.white, 100))
plot(demandTouched ? 1 : 0,                  title="Demand Zone Touch", color=color.new(color.white, 100))
plot(supplyTouched ? 1 : 0,                  title="Supply Zone Touch", color=color.new(color.white, 100))
````
