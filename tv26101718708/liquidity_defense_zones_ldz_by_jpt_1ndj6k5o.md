# Liquidity Defense Zones (LDZ) by JPT

- url: https://www.tradingview.com/script/1Ndj6k5O-Liquidity-Defense-Zones-LDZ-by-JPT/
- type: indicator
- pine_id: PUB;330f773e9ec542eebdba752f76eae69b
- version: 1.0

## Description

[b]🔷 OVERVIEW[/b]

[b]Liquidity Defense Zones (LDZ) by JPT[/b] is a technical analysis indicator that highlights potential liquidity areas above swing highs and below swing lows. It helps traders identify where liquidity may be targeted and where price could reverse after a liquidity sweep.

The indicator automatically plots liquidity zones, marks sweep events, and displays potential BUY and SELL reversal signals when the selected confirmation conditions are met.

https://www.tradingview.com/x/A9isDipR/
[b]🔹BUY Signal Example;[/b]
When the LDZ BUY signal appears, look for the needle-like spike below the Sell-Side Liquidity (SSL) zone. This indicates a potential liquidity sweep and bullish reversal.
Entry: Enter a BUY trade on the candle immediately following the spike, once the setup is confirmed. Stop-Loss: Place your stop-loss slightly below the spike's lowest point.
Take-Profit: Target a risk-to-reward ratio of 1:2 or 1:3.
Confirmation: Look for bullish momentum and signs of price rejection before entering the trade.

https://www.tradingview.com/x/OkXzdKSs/
[b]🔹 SELL Signal Example;[/b]
When the LDZ SELL signal appears, look for the needle-like spike above the Buy-Side Liquidity (BSL) zone. This indicates a potential liquidity sweep and bearish reversal. Entry: Enter a SELL trade on the candle immediately following the spike, once the setup is confirmed.Stop-Loss: Place your stop-loss slightly above the spike's highest point.
Take-Profit: Target a risk-to-reward ratio of 1:2 or 1:3.
Confirmation: Ensure price shows bearish momentum before entering the trade.

[b]🔷 HOW IT WORKS[/b]

• Buy-Side Liquidity (BSL): Identifies zones around confirmed swing highs, where buy-side liquidity may be present. https://www.tradingview.com/x/HAwm9Zxn/

• Sell-Side Liquidity (SSL): Identifies zones around confirmed swing lows, where sell-side liquidity may be present. https://www.tradingview.com/x/4AyoI2bs/

• ATR-Based Zones: Uses the Average True Range (ATR) to adjust zone thickness according to market volatility.
• Liquidity Sweep Detection: Detects price moving beyond a liquidity zone and closing back across its swing level, potentially indicating a liquidity grab.
• Reversal Confirmation: Generates bullish or bearish signals when a sweep occurs, optionally requiring a candle of the corresponding color.
• Visual Zone Management: Extends active zones, marks swept zones, and changes zone colors when liquidity is swept or price closes beyond a zone.

Alerts: Provides configurable alerts for bullish sweeps, bearish sweeps, and potential reversal signals.

[b]🔷 HOW TO USE[/b]

1. Add the indicator to your TradingView chart.
2. Adjust Pivot Strength to control swing detection sensitivity.
3. Configure ATR Length and Zone Thickness to suit the volatility of your market.
4. Enable liquidity zones, BSL/SSL labels, sweep signals, and reversal signals according to your preference.
5. Watch for a BSL sweep followed by a potential bearish reversal, or an SSL sweep followed by a potential bullish reversal.
6. Use the available alert conditions to receive notifications when liquidity sweeps or reversal signals occur.
7. Confirm signals with market structure, support and resistance, price action, or other analysis tools before entering a trade.

[b]🔷 IMPORTANT NOTE[/b]

the Liquidity sweeps can occur during strong breakouts, and signals may fail in trending or volatile conditions. Confirmed pivots appear only after the specified right-side pivot bars have elapsed, so zone identification involves a delay.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Jos-ProTrader

// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0
// © Jos-ProTrader

//@version=6
indicator("Liquidity Defense Zones (LDZ) by JPT",
     shorttitle="(LDZ) by JPT",
     overlay=true,
     max_boxes_count=200,
     max_labels_count=300)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 1. INPUTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

groupLiquidity = "Liquidity Engine"

pivotLen = input.int(28, "Pivot Strength", minval=2, group=groupLiquidity)
atrLen = input.int(14, "ATR Length", minval=1, group=groupLiquidity)
zoneAtrMult = input.float(0.20, "Zone Thickness (ATR)", minval=0.05, step=0.05, group=groupLiquidity)
maxZones = input.int(15, "Maximum Zones Per Side", minval=1, maxval=50, group=groupLiquidity)

groupDisplay = "Display Settings"

showZones = input.bool(true, "Show Liquidity Zones", group=groupDisplay)
showLabels = input.bool(true, "Show BSL / SSL Labels", group=groupDisplay)
showSweeps = input.bool(true, "Show Sweep Signals", group=groupDisplay)
extendZones = input.bool(true, "Extend Active Zones", group=groupDisplay)

groupSignals = "Reversal Confirmation"

requireCandleColor = input.bool(true, "Require Reversal Candle", group=groupSignals)
showReversals = input.bool(true, "Show Reversal Signals", group=groupSignals)

groupAlerts = "Alerts"

enableAlerts = input.bool(true, "Enable Alerts", group=groupAlerts)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 2. ATR & CONFIRMED PIVOTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

atr = ta.atr(atrLen)
zoneSize = atr * zoneAtrMult

pivotHigh = ta.pivothigh(high, pivotLen, pivotLen)
pivotLow = ta.pivotlow(low, pivotLen, pivotLen)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 3. LIQUIDITY STORAGE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

var box[] bslZones = array.new_box()
var box[] sslZones = array.new_box()

var float[] bslPrices = array.new_float()
var float[] sslPrices = array.new_float()

var bool[] bslActive = array.new_bool()
var bool[] sslActive = array.new_bool()

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 4. CREATE BUY-SIDE LIQUIDITY ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotHigh) and not na(zoneSize[pivotLen])

    float level = pivotHigh
    float thickness = zoneSize[pivotLen]

    box newZone = box.new(
         left=bar_index - pivotLen,
         top=level + thickness,
         right=bar_index,
         bottom=level - thickness,
         xloc=xloc.bar_index,
         extend=extendZones ? extend.right : extend.none,
         border_color=showZones ? color.red : color.new(color.red, 100),
         bgcolor=showZones ? color.new(color.red, 88) : color.new(color.red, 100))

    array.push(bslZones, newZone)
    array.push(bslPrices, level)
    array.push(bslActive, true)

    if showLabels
        label.new(
             bar_index - pivotLen,
             level + thickness,
             "BSL",
             style=label.style_label_down,
             color=color.red,
             textcolor=color.white,
             size=size.tiny)

    if array.size(bslZones) > maxZones
        box oldZone = array.shift(bslZones)
        box.delete(oldZone)
        array.shift(bslPrices)
        array.shift(bslActive)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 5. CREATE SELL-SIDE LIQUIDITY ZONES
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

if not na(pivotLow) and not na(zoneSize[pivotLen])

    float level = pivotLow
    float thickness = zoneSize[pivotLen]

    box newZone = box.new(
         left=bar_index - pivotLen,
         top=level + thickness,
         right=bar_index,
         bottom=level - thickness,
         xloc=xloc.bar_index,
         extend=extendZones ? extend.right : extend.none,
         border_color=showZones ? color.lime : color.new(color.lime, 100),
         bgcolor=showZones ? color.new(color.lime, 88) : color.new(color.lime, 100))

    array.push(sslZones, newZone)
    array.push(sslPrices, level)
    array.push(sslActive, true)

    if showLabels
        label.new(
             bar_index - pivotLen,
             level - thickness,
             "SSL",
             style=label.style_label_up,
             color=color.green,
             textcolor=color.white,
             size=size.tiny)

    if array.size(sslZones) > maxZones
        box oldZone = array.shift(sslZones)
        box.delete(oldZone)
        array.shift(sslPrices)
        array.shift(sslActive)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 6. LIQUIDITY SWEEP ENGINE
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bool bullishSweep = false
bool bearishSweep = false

if array.size(bslZones) > 0
    for i = 0 to array.size(bslZones) - 1

        if array.get(bslActive, i)
            box zone = array.get(bslZones, i)
            float level = array.get(bslPrices, i)
            float zoneTop = box.get_top(zone)
            float zoneBottom = box.get_bottom(zone)

            if high > zoneTop and close < level
                bearishSweep := true
                array.set(bslActive, i, false)

                box.set_extend(zone, extend.none)
                box.set_right(zone, bar_index)
                box.set_bgcolor(zone, color.new(color.orange, 82))
                box.set_border_color(zone, color.orange)

                if showSweeps
                    label.new(
                         bar_index,
                         high,
                         "BSL SWEEP",
                         style=label.style_label_down,
                         color=color.orange,
                         textcolor=color.white,
                         size=size.small)

            else if close > zoneTop
                array.set(bslActive, i, false)
                box.set_extend(zone, extend.none)
                box.set_right(zone, bar_index)
                box.set_bgcolor(zone, color.new(color.gray, 90))
                box.set_border_color(zone, color.gray)

if array.size(sslZones) > 0
    for i = 0 to array.size(sslZones) - 1

        if array.get(sslActive, i)
            box zone = array.get(sslZones, i)
            float level = array.get(sslPrices, i)
            float zoneTop = box.get_top(zone)
            float zoneBottom = box.get_bottom(zone)

            if low < zoneBottom and close > level
                bullishSweep := true
                array.set(sslActive, i, false)

                box.set_extend(zone, extend.none)
                box.set_right(zone, bar_index)
                box.set_bgcolor(zone, color.new(color.aqua, 82))
                box.set_border_color(zone, color.aqua)

                if showSweeps
                    label.new(
                         bar_index,
                         low,
                         "SSL SWEEP",
                         style=label.style_label_up,
                         color=color.aqua,
                         textcolor=color.black,
                         size=size.small)

            else if close < zoneBottom
                array.set(sslActive, i, false)
                box.set_extend(zone, extend.none)
                box.set_right(zone, bar_index)
                box.set_bgcolor(zone, color.new(color.gray, 90))
                box.set_border_color(zone, color.gray)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 7. REVERSAL CONFIRMATION
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

bullishCandle = close > open
bearishCandle = close < open

buySignal = bullishSweep and (not requireCandleColor or bullishCandle)
sellSignal = bearishSweep and (not requireCandleColor or bearishCandle)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 8. PLOT REVERSAL SIGNALS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

plotshape(
     showReversals and buySignal,
     title="Bullish Liquidity Reversal",
     style=shape.cross,
     location=location.belowbar,
     color=color.lime,
     text="BUY",
     textcolor=color.black,
     size=size.small)

plotshape(
     showReversals and sellSignal,
     title="Bearish Liquidity Reversal",
     style=shape.cross,
     location=location.abovebar,
     color=color.red,
     text="SELL",
     textcolor=color.white,
     size=size.small)

//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 9. ALERTS
//━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

alertcondition(
     enableAlerts and bullishSweep,
     title="Sell-Side Liquidity Sweep",
     message="LDZ [JPT]: Sell-side liquidity swept. Price moved below a liquidity zone and closed back above its swing level.")

alertcondition(
     enableAlerts and bearishSweep,
     title="Buy-Side Liquidity Sweep",
     message="LDZ [JPT]: Buy-side liquidity swept. Price moved above a liquidity zone and closed back below its swing level.")

alertcondition(
     enableAlerts and buySignal,
     title="Bullish Liquidity Reversal",
     message="LDZ [JPT]: Bullish liquidity reversal confirmed.")

alertcondition(
     enableAlerts and sellSignal,
     title="Bearish Liquidity Reversal",
     message="LDZ [JPT]: Bearish liquidity reversal confirmed.")
````
