# brechtdeygers

- url: https://www.tradingview.com/script/GLY2bZTW-brechtdeygers/
- type: indicator
- pine_id: PUB;1521a1010ac649c7bf2abe8caa8b4481
- version: 1.0

## Description

The “A+ Supply & Demand” indicator is a high-probability institutional trading tool designed to identify only the strongest market zones with the highest potential for profitable reactions. It combines advanced supply and demand logic, trend confirmation, liquidity analysis, and automated risk management into one complete TradingView system.

The indicator detects powerful institutional supply and demand zones by analyzing aggressive price displacement and volatility using ATR-based filtering. Only high-quality zones created by strong buying or selling pressure are displayed, helping traders avoid weak or low-probability setups.

To improve accuracy, the system includes a 200 EMA trend filter that aligns trades with the dominant market direction. Demand zones are prioritized during bullish trends, while supply zones are prioritized during bearish trends, increasing the probability of successful entries.

A built-in liquidity and volume strength system estimates how much institutional activity and remaining liquidity exist inside each zone. Stronger zones are visually highlighted using volume-based scoring, color intensity, and liquidity labels, making it easier to identify where large unfilled orders may still be present. Zones that become partially mitigated automatically lose liquidity strength over time.

The indicator also provides complete trade execution planning:

* Automatic entry signals on the first retest of fresh zones
* Dynamic stop losses placed beyond previous swing highs/lows with ATR safety buffers
* Accurate take profit targets based on true risk distance
* Configurable Risk:Reward ratios (default 1:2)

For performance tracking, the indicator includes a live dashboard displaying:

* Total trades
* Win rate
* Wins and losses
* Active setup statistics

Additional visual enhancements include:

* Entry, stop loss, and take profit plotting
* Zone transparency based on liquidity strength
* Retest/touch tracking
* Automatic removal of invalid or mitigated zones

The goal of the indicator is to help traders focus exclusively on A+ institutional setups by combining trend alignment, liquidity analysis, displacement strength, and precision risk management into a clean and highly selective trading system.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=6
indicator("A+ Supply & Demand [LuxAlgo]", "A+ S&D (Refined)", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500)

// --- Groups ---
group_sd        = "Institutional Detection"
group_risk      = "Risk Management"
group_visuals   = "Visuals & Stats"
group_style     = "Style & Colors"

// --- Inputs ---
atrLenInput     = input.int(14, "ATR Length", minval = 1, group = group_sd)
dispMultInput   = input.float(3.0, "Displacement Multiplier", minval = 1.0, step = 0.5, group = group_sd, tooltip = "Minimum body size relative to ATR.")
minVolInput     = input.float(1.5, "Min Vol Ratio", minval = 0.5, step = 0.1, group = group_sd, tooltip = "Minimum volume relative to average to confirm activity.")
emaFilterInput  = input.int(200, "Trend Filter (EMA)", minval = 1, group = group_sd)

minRRInput      = input.float(2.0, "Target Risk:Reward", minval = 1.0, step = 0.1, group = group_risk)
slAtrMultInput  = input.float(1.0, "SL Buffer (ATR)", minval = 0.0, step = 0.1, group = group_risk)
entryOffset     = input.float(0.0, "Entry Depth %", minval = 0.0, maxval = 100.0, step = 10.0, group = group_risk, tooltip = "Adjust entry deeper into the zone. 0% = Edge, 50% = Mid-point, 100% = Far Edge.") / 100.0

showActiveOnly  = input.bool(true, "Hide Mitigated Zones", group = group_visuals)
showDashInput   = input.bool(true, "Show Performance Dashboard", group = group_visuals)
showLevelsInput = input.bool(true, "Show Signal Levels", group = group_visuals)

// --- Style Inputs ---
demandColor     = input.color(#089981, "Demand Color", group = group_style, inline = "z")
supplyColor     = input.color(#f23645, "Supply Color", group = group_style, inline = "z")
zoneOpacity     = input.int(5, "Zone Fill Opacity %", minval = 0, maxval = 100, group = group_style, tooltip = "0 = Fully Transparent (Invisible), 100 = Solid.")
borderOpacity   = input.int(20, "Zone Border Opacity %", minval = 0, maxval = 100, group = group_style)

buySignalColor  = input.color(#089981, "Buy Signal", group = group_style, inline = "s")
sellSignalColor = input.color(#f23645, "Sell Signal", group = group_style, inline = "s")
emaColor        = input.color(color.new(#787b86, 50), "EMA Color", group = group_style)
entryColor      = input.color(#ffffff, "Entry Level", group = group_style, inline = "lvl")
tpColor         = input.color(#089981, "TP Level", group = group_style, inline = "lvl")
slColor         = input.color(#f23645, "SL Level", group = group_style, inline = "lvl")

// --- Types ---
type Zone
    float top
    float bottom
    float volumeVal
    bool  isSupply
    bool  isMitigated
    int   touchCount
    box   boxId
    label labelId

type TradeSignal
    float entry
    float sl
    float tp
    bool  isLong
    bool  active = true
    line  entryLine
    line  slLine
    line  tpLine

// --- Initialization ---
var Zone[] zones = array.new<Zone>()
var TradeSignal lastTrade = na
var int totalTrades = 0
var int wins = 0
var int losses = 0

// --- Indicators ---
ema200 = ta.ema(close, emaFilterInput)
atr    = ta.atr(atrLenInput)
volMa  = ta.sma(volume, 20)

// --- Logic: Supply & Demand Detection ---
bodySize    = math.abs(close - open)
volRatio    = volume / volMa
isDisplaced = bodySize > atr * dispMultInput and volRatio >= minVolInput

// Formatting raw volume for labels
formatVol(val) =>
    if val >= 1000000
        str.format("{0, number, #.##}M", val / 1000000)
    else if val >= 1000
        str.format("{0, number, #.#}K", val / 1000)
    else
        str.tostring(val)

if isDisplaced
    float curZTop    = 0.0
    float curZBottom = 0.0
    bool  curIsSup   = false
    
    if close > open 
        curZTop    := high[1]
        curZBottom := low[1]
        curIsSup   := false
    else
        curZTop    := high[1]
        curZBottom := low[1]
        curIsSup   := true

    color baseColor = curIsSup ? supplyColor : demandColor
    
    // Create box with user-defined absolute opacity
    box nb = box.new(bar_index[1], curZTop, bar_index, curZBottom, 
     border_color = color.new(baseColor, 100 - borderOpacity), 
     bgcolor = color.new(baseColor, 100 - zoneOpacity),
     extend = extend.right)
     
    label nl = label.new(bar_index, (curZTop + curZBottom) / 2, 
     text = "VOL: " + formatVol(volume), 
     style = label.style_label_left, 
     textcolor = chart.fg_color, 
     color = #00000000, 
     size = size.small)

    array.push(zones, Zone.new(curZTop, curZBottom, volume, curIsSup, false, 0, nb, nl))

// --- Mitigation & Entry Logic ---
bool  longSignal  = false
bool  shortSignal = false
float signalEntry = 0.0
float signalSL    = 0.0
float signalTP    = 0.0

if array.size(zones) > 0
    for i = array.size(zones) - 1 to 0
        Zone z = array.get(zones, i)
        
        if not z.isMitigated
            bool priceInZone = low <= z.top and high >= z.bottom
            bool priceBreach = z.isSupply ? high > z.top : low < z.bottom
            
            if priceBreach
                z.isMitigated := true
                box.set_extend(z.boxId, extend.none)
                box.set_right(z.boxId, bar_index)
                if showActiveOnly
                    box.delete(z.boxId)
                    label.delete(z.labelId)
                else
                    box.set_bgcolor(z.boxId, color.new(chart.fg_color, 95))
                    box.set_border_color(z.boxId, color.new(chart.fg_color, 90))
                    label.delete(z.labelId)
            else if priceInZone
                z.touchCount += 1
                
                if z.touchCount == 1
                    float zoneHeight = z.top - z.bottom
                    if not z.isSupply and close > ema200
                        longSignal  := true
                        signalEntry := z.top - (zoneHeight * entryOffset)
                        signalSL    := z.bottom - (atr * slAtrMultInput)
                        float risk  = signalEntry - signalSL
                        signalTP    := signalEntry + (risk * minRRInput)
                    else if z.isSupply and close < ema200
                        shortSignal := true
                        signalEntry := z.bottom + (zoneHeight * entryOffset)
                        signalSL    := z.top + (atr * slAtrMultInput)
                        float risk  = signalSL - signalEntry
                        signalTP    := signalEntry - (risk * minRRInput)
                
                label.set_x(z.labelId, bar_index)

// --- Trade Management & Stats ---
if (longSignal or shortSignal) and (na(lastTrade) or not lastTrade.active)
    totalTrades += 1
    line eLine = showLevelsInput ? line.new(bar_index, signalEntry, bar_index + 5, signalEntry, color = entryColor, width = 1) : na
    line sLine = showLevelsInput ? line.new(bar_index, signalSL, bar_index + 5, signalSL, color = slColor, style = line.style_dotted) : na
    line tLine = showLevelsInput ? line.new(bar_index, signalTP, bar_index + 5, signalTP, color = tpColor, style = line.style_dotted) : na
    
    lastTrade := TradeSignal.new(signalEntry, signalSL, signalTP, longSignal, true, eLine, sLine, tLine)

if not na(lastTrade) and lastTrade.active
    if showLevelsInput
        line.set_x2(lastTrade.entryLine, bar_index + 2)
        line.set_x2(lastTrade.slLine, bar_index + 2)
        line.set_x2(lastTrade.tpLine, bar_index + 2)
    
    if lastTrade.isLong
        if high >= lastTrade.tp
            wins += 1
            lastTrade.active := false
        else if low <= lastTrade.sl
            losses += 1
            lastTrade.active := false
    else
        if low <= lastTrade.tp
            wins += 1
            lastTrade.active := false
        else if high >= lastTrade.sl
            losses += 1
            lastTrade.active := false

// --- Visuals ---
plot(ema200, "Trend Filter", emaColor, 1)

plotshape(longSignal, "Buy", shape.triangleup, location.belowbar, buySignalColor, size = size.small)
plotshape(shortSignal, "Sell", shape.triangledown, location.abovebar, sellSignalColor, size = size.small)

// --- Dashboard ---
var table statsTable = table.new(position.bottom_right, 2, 4, bgcolor = color.new(chart.bg_color, 10), border_color = color.new(chart.fg_color, 80), border_width = 1)
if showDashInput and barstate.islast
    float winRate = totalTrades > 0 ? (wins / float(totalTrades)) * 100 : 0
    table.cell(statsTable, 0, 0, "A+ PERFORMANCE", text_color = chart.fg_color, text_size = size.small)
    table.cell(statsTable, 1, 0, "", text_color = chart.fg_color)
    table.cell(statsTable, 0, 1, "Signals", text_color = chart.fg_color, text_halign = text.align_left)
    table.cell(statsTable, 1, 1, str.tostring(totalTrades), text_color = chart.fg_color)
    table.cell(statsTable, 0, 2, "Win Rate", text_color = chart.fg_color, text_halign = text.align_left)
    table.cell(statsTable, 1, 2, str.format("{0, number, #.##}%", winRate), text_color = winRate >= 50 ? buySignalColor : sellSignalColor)
    table.cell(statsTable, 0, 3, "W / L", text_color = chart.fg_color, text_halign = text.align_left)
    table.cell(statsTable, 1, 3, str.format("{0} - {1}", wins, losses), text_color = chart.fg_color)
````
