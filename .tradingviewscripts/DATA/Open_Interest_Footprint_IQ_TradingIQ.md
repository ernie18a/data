<!-- tradingview-pine-id: PUB;c7fad98f385448ca87d1b8b880287562 -->
<!-- tradingviewscripts-format: 1 -->
# Open Interest Footprint IQ [TradingIQ]

Source: https://www.tradingview.com/script/lLG6gDb4-Open-Interest-Footprint-IQ-TradingIQ/

## Description

Hello Traders!

The Open Interest Footprint IQ indicator is an advanced visualization tool designed for cryptocurrency markets. It provides a granular, real-time breakdown of open interest changes across different price levels, allowing traders to see how aggressive market participation is distributed within each bar.

Unlike standard footprint charts that rely solely on volume, this indicator offers unique insights by focusing on the interaction between price action and changes in open interest (OI) — a leading metric often used to infer trader intent and positioning.

How it works

The Open Interest Footprint IQ processes lower timeframe price and open interest data to build a footprint-style chart that shows how traders are positioning themselves within each candle.

Here’s a breakdown of the process:

1. Granular OI & Price Sampling
The script retrieves lower-timeframe data (1-minute, 1-second, or 1-tick, based on your setting).

For each candle, it captures:

[*]High and low prices
[*]Price change direction
[*]Change in open interest (OI)

2. Classifying Trader Behavior
For each lower-timeframe segment, the indicator determines the type of positioning occurring based on price movement and OI change:

[*]If price is moving up and open interest is increasing, it suggests that long positions are being opened. This is considered a "Longs Opening" event, labeled as UU (Up/Up).
[*]If price is moving up but open interest is decreasing, it indicates that short positions are being closed. This is referred to as UD (Up/Down), or "Shorts Closing."
[*]If price is moving down and open interest is increasing, it signals that short positions are being opened. This is known as DU (Down/Up), or "Shorts Opening."
[*]If price is moving down while open interest is also decreasing, it means that long positions are being closed. This is labeled as DD (Down/Down), or "Longs Closing."

These are stored in separate arrays and displayed at specific price levels.

It is particularly useful for identifying:

[*]Where longs or shorts are opening/closing positions
[*]Stacked imbalances (indicative of potential absorption or exhaustion)
[*]Value area zones and POC (Point of Control) based on OI, not volume

This footprint runs on your choice of sub-bar granularity and is ideal for high-frequency trading, scalping, and entries based on order flow dynamics.

Key Features

Footprint Visualization

At each price level within a candle:

[*]Long/short opening and closing behavior is broken down.
[*]Delta (net open interest change) is displayed both numerically and color-coded.
[*]Optional gradient coloring shows intensity and type of flow (longs/shorts opened/closed).
[*]Cumulative or per-bar reset modes allow you to track OI evolution over time.

[image]https://www.tradingview.com/x/VNdG8wDX/[/image]

The image above explains the information that each Footprint box shows across a candlestick!

Each footprint box shows:

[*]OI Delta 
[*]OI Delta %
[*]Longs Opened (LO)
[*]Longs Closed (LC)
[*]Shorts Opened (SO) 
[*]Shorts Closed (SC)

[image]https://www.tradingview.com/x/dMrZrVvs/[/image]

The image above explains the color-coding feature of the indicator.

Boxes are color coded to show which position action 
dominated at the price area.

For this example:

[*]Green boxes = Long positions being opened dominated
[*]Purple boxes = Long positions being closed dominated
[*]Red boxes = Short positions being opened dominated
[*]Yellow boxes = Short positions being closed dominated

All colors are customizable.

Additionally, for traders who are only interested in whether OI increased/decreased, a "two-color" option is available in the settings.

[image]https://www.tradingview.com/x/kUKRtthX/[/image]

For the two-color option, footprint boxes can be one of two colors. Showing whether OI increased or decreased at the level.

Cumulative Levels

Open Interest Footprint IQ contains a "Cumulative Levels" feature that tracks/stores open interest change at tick levels over time, rather than resetting per bar.

[image]https://www.tradingview.com/x/ZHoyJ6oC/[/image]

With the "Cumulative Levels" feature enabled, traders can see open interest changes persist across all candlesticks. This feature is useful for determining whether longs opening, longs closing, shorts opening, or shorts closing are dominating at particular price areas over time rather than on a single bar. 

A useful feature to see if shorts/longs are favoring certain price throughout the day, week, month, etc.

Input Settings Explained

Granularity (Dropdown: Granularity)
Options: 1-Minute, 1-Second, 1-Tick

Determines how finely the script samples the lower timeframe data to construct the footprint.

For precision:

1-Tick = Highest accuracy, but more resource-intensive.

1-Second/1-Minute = Suitable for broader or more zoomed-out analysis.

Tick Level Distance (Tick Level Distance (0 = Auto))
Defines the vertical spacing between levels in the footprint chart.

If 0, the script uses an automatic calculation based on ATR to adapt to volatility.

Set a manual value (e.g., 5) to control the height granularity of each level in ticks.

Cumulative Levels (Toggle)
If enabled, the footprint builds cumulatively over time, rather than resetting per candle.

Use case: Visualize ongoing buildup of OI activity across a session or day.

Cumulative Levels Reset TF (Timeframe)
Sets the reset interval for the cumulative view (e.g., reset daily, hourly, etc.)

Works only when Cumulative Levels is enabled.

Delta Box Display Settings

Show Delta Percentage
Toggles the display of the percentage change in OI across the footprint level.

Helpful to gauge how aggressive positioning is relative to total OI at that level.

Show Longs/Shorts (Opened/Closed)
Show Longs Opened: Displays OI increase in up candles (price ↑, OI ↑).

Show Longs Closed: Displays OI decrease in down candles (price ↓, OI ↓).

Show Shorts Opened: OI increase in down candles (price ↓, OI ↑).

Show Shorts Closed: OI decrease in up candles (price ↑, OI ↓).

These behaviors are color-coded to give traders instant context:

Blue-green for longs opening.

Purple for longs closing.

Red for shorts opening.

Yellow for shorts closing.

Value Area & POC

Value Area % (Value Area %)
Controls how much cumulative open interest is used to define the value area.

Example: 70% means the smallest range of prices that contains 70% of total OI in that bar will be marked.

Helps identify zones of interest, support/resistance, and institutional levels.

[image]https://www.tradingview.com/x/xZU6kTMF/[/image]

The image above explains how to identify the VAH/VAL/POC shown by Open Interest Footprint IQ.

[*]VAH = Upper 🞂
[*]POC = ●
[*]VAL = Lower 🞂

Imbalances

Imbalance Percentage

Defines the minimum delta % required at a level to be marked as an imbalance.

If the net open interest change at a level exceeds this threshold, a visual marker appears.

[image]https://www.tradingview.com/x/8stvXvlF/[/image]

Stacked Imbalance Count

If the number of consecutive imbalance levels meets this count, a “Stacked Imbalance” alert will trigger.

This can signal aggressive buying or selling pressure, potential breakout zones, or institutional absorption.

[image]https://www.tradingview.com/x/mmovVBtg/[/image]

Color Settings
Longs Opened / Closed, Shorts Opened / Closed
Customize the color palette for each order flow behavior.

These colors appear in the background gradient of the footprint boxes.

Up/Down Only Mode
Toggle to override all behavior-based colors with a single Up Color and Down Color.

Useful if you prefer a simple bull/bear view.

Up Color / Down Color
If "Up/Down Only" is enabled, these two colors are used to represent all net positive or negative deltas.

Special Notes
Crypto only: This script works only with crypto tickers on TradingView.

For other assets (stocks, futures), a warning message will appear instead.

OI data must be available from the exchange (many perpetual pairs support this).

If the footprint is too small or invisible, increase your tick level spacing in the settings.

Alerts
When a stacked imbalance is detected, an alert is fired ("Stacked Imbalance").

This feature is useful for automated systems, bots, or simply staying informed of potential trade setups.

And that's all for now!

If you have any questions or features you'd like to see feel free to share them in the comments below! 

Thank you traders!

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingIQ

//@version=6
indicator("Open Interest Footprint IQ [TradingIQ]", overlay = true, max_boxes_count = 500,  max_lines_count = 500, max_labels_count = 500, max_polylines_count = 100)

enum granularity

    m1 = "1-Minute"  
    s1 = "1-Second"  
    t1 = "1-Tick"  

enum profile 

    uu = "Up/Up"
    ud = "Up/Dn"
    du = "Dn/Up"
    dd = "Dn/Dn"

gran            = input.enum(defval = granularity.m1, title = "Granularity", options = [granularity.m1, granularity.s1, granularity.t1])

ticks           = input.float(0, title = "Tick Level Distance (0 = Auto)")
useCumulative   = input.bool(defval = false, title = "Cumulative Levels", group = "Cumulative Levels")
cumulativeRes   = input.timeframe("1D", title = "Cumulative Levels Reset TF", group = "Cumulative Levels")
showDeltaP      = input.bool(defval = true, title = "Show Delta Percentage", group = "Delta Boxes")
showupup        = input.bool(defval = true, title = "Show Longs Opened", group = "Delta Boxes")
showdndn        = input.bool(defval = true, title = "Show Longs Closed", group = "Delta Boxes")
showdnup        = input.bool(defval = true, title = "Show Shorts Opened", group = "Delta Boxes")
showupdn        = input.bool(defval = true, title = "Show Shorts Closed", group = "Delta Boxes")

useSymbols      = input.bool(defval = true, title = "Use Symbols", group = "Delta Boxes")

vaCumu          = input.float(defval = 70, title = "Value Area %", minval = 0, maxval = 100) / 100


imbalanceP      = input.float(defval = 80, minval = 0, maxval = 100, title = "Imbalance Percentage", group = "Imbalances")
stacked         = input.int  (defval = 3, title = "Stacked Imbalance Count", minval = 2, group = "Imbalances")

upupCol         = input.color(defval = #55ffda, title = "Longs Opened", group = "Colors")
dndnCol         = input.color(defval = #8c5bff, title = "Longs Closed", group = "Colors")
dnupCol         = input.color(defval = color.rgb(255, 116, 116), title = "Shorts Opened", group = "Colors")
updnCol         = input.color(defval = #fff174, title = "Shorts Closed", group = "Colors")

col2Only        = input.bool (defval = false, title = "Up Color and Down Color Only", group = "Up/Down Only")
upCol           = input.color(defval = #55ffda, title = "Up Color", group = "Up/Down Only")
dnCol           = input.color(defval = color.rgb(255, 116, 116), title = "Down Color", group = "Up/Down Only")



var tf = switch gran

    granularity.m1  => "1"
    granularity.s1  => "1S"
    granularity.t1  => "1T"



req() => 
    
    cont = switch str.contains(syminfo.ticker, ".P")
        
        true => syminfo.ticker + "_OI"
        =>      str.endswith(syminfo.ticker, "USDT") ? syminfo.ticker + ".P_OI" : syminfo.ticker + "T.P_OI"

    switch syminfo.type

        "crypto" =>          cont
        =>                   string(na)

getDiffernceCorrect() => 

    trueSign = nz(close - open)

    if trueSign == 0 
        trueSign := nz(close - close[1])

    trueSign

[ltfV, ltfD, ltfC, ltfH, ltfL, ltfBid, ltfAsk, ltfC1, oi, oiChange] = 
     request.security_lower_tf(syminfo.tickerid, tf, [volume, getDiffernceCorrect(), close, high, low, bid, ask, close[1], request.security(req(), tf, close), request.security(req(), tf, close - close[1])])


type oiFootprint

    array<float> tickLevels 
    array<float> upOIupPrice
    array<float> upOIdnPrice
    array<float> dnOIupPrice
    array<float> dnOIdnPrice


type heatmapData

    array<float> gradientLevelsDelta
    array<float> gradientLevelsPrice

type gradientDrawings 

    array<line>     gradientLine
    array<linefill> gradientLineFill
    label           deltaLabel

atr = ta.atr(14)

method shiftPopAll(array<float> tickLevels, upOIupPrice, upOIdnPrice, dnOIupPrice, dnOIdnPrice, pop = false) =>

    if tickLevels.size() > 90000

        switch pop 

            false => 

                  tickLevels .shift(), upOIupPrice.shift(),
                  upOIdnPrice.shift(), dnOIupPrice.shift(), 
                          dnOIdnPrice  .shift()

            =>    
                  tickLevels .pop(), upOIupPrice.pop(),
                  upOIdnPrice.pop(), dnOIupPrice.pop(), 
                          dnOIdnPrice  .pop()

method pushUnshiftAll(array<float> tickLevels, upOIupPrice, upOIdnPrice, dnOIupPrice, dnOIdnPrice, tickAmount, unshift = false) => 

    switch unshift 

        false => tickLevels .push(tickAmount), 
                 upOIupPrice.push(0), upOIdnPrice.push(0), dnOIupPrice.push(0), dnOIdnPrice.push(0)

        =>       tickLevels .unshift(tickAmount), 
                 upOIupPrice.unshift(0), upOIdnPrice.unshift(0), dnOIupPrice.unshift(0), dnOIdnPrice.unshift(0)


method fillAll(array<float> upOIupPrice, upOIdnPrice, dnOIupPrice, dnOIdnPrice) => 

    if gran != granularity.t1

        if timeframe.change("") and not useCumulative

            if upOIupPrice.size() > 0

                upOIupPrice.fill(0), upOIdnPrice.fill(0), dnOIupPrice.fill(0), dnOIdnPrice.fill(0)

    else 

        if not useCumulative

            if upOIupPrice.size() > 0

                upOIupPrice.fill(0), upOIdnPrice.fill(0), dnOIupPrice.fill(0), dnOIdnPrice.fill(0)
            

method textGenerate(array<string> boxText, condition, useSymbols, textSymbol, textGeneric) => 

    if condition

        switch useSymbols

            true => boxText.set(0, boxText.first() + textSymbol)
            =>      boxText.set(0, boxText.first() + textGeneric)

generateFootprint() => 


    if ltfV.size() > 0 


        var FD = oiFootprint.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>())
        var HD = heatmapData  .new(array.new<float>(), array.new<float>())

        var tickAmount = 0.
            
        FD.upOIupPrice.fillAll(FD.upOIdnPrice, FD.dnOIupPrice, FD.dnOIdnPrice)

        cond = switch gran == granularity.t1

            false => timeframe.change("1D") and not useCumulative or useCumulative and timeframe.change(cumulativeRes)    
            =>       ltfV.size() > 0 and na(ltfV.size()[1]) or timeframe.change("1D") and not useCumulative or useCumulative and timeframe.change(cumulativeRes) 


        if cond 

            tickAmount := switch ticks == 0 

                true => atr   * syminfo.mintick
                =>      ticks * syminfo.mintick

            FD.tickLevels     := array.from(open - tickAmount, open, open + tickAmount)
            FD.upOIupPrice    := array.from(0, 0, 0), FD.upOIdnPrice   := array.from(0, 0, 0)
            FD.dnOIupPrice    := array.from(0, 0, 0), FD.dnOIdnPrice   := array.from(0, 0, 0)

        if FD.tickLevels.size() > 0

            if HD.gradientLevelsDelta.size() == 0

                HD.gradientLevelsPrice := array.from(open - tickAmount, open, open + tickAmount)
                HD.gradientLevelsDelta := array.from(0, 0, 0)

            last  = FD.tickLevels.last () 
            first = FD.tickLevels.first()

            while high >= last

                last += tickAmount
                FD.tickLevels.pushUnshiftAll(FD.upOIupPrice, FD.upOIdnPrice, FD.dnOIupPrice, FD.dnOIdnPrice, last)
                FD.tickLevels.shiftPopAll   (FD.upOIupPrice, FD.upOIdnPrice, FD.dnOIupPrice, FD.dnOIdnPrice)

            while low <= first

                first -= tickAmount

                FD.tickLevels.pushUnshiftAll(FD.upOIupPrice, FD.upOIdnPrice, FD.dnOIupPrice, FD.dnOIdnPrice, first, true)
                FD.tickLevels.shiftPopAll   (FD.upOIupPrice, FD.upOIdnPrice, FD.dnOIupPrice, FD.dnOIdnPrice, true)

            last  := HD.gradientLevelsPrice.last()
            first := HD.gradientLevelsPrice.first()

            while high >= last 

                last += tickAmount

                HD.gradientLevelsPrice.push(last)
                HD.gradientLevelsDelta.push(0)

                if HD.gradientLevelsPrice.size() > 90000

                    HD.gradientLevelsPrice.shift()
                    HD.gradientLevelsDelta.shift()

            while low <= first 

                first -= tickAmount

                HD.gradientLevelsPrice.unshift(first)
                HD.gradientLevelsDelta.unshift(0)

                if HD.gradientLevelsPrice.size() > 90000

                    HD.gradientLevelsPrice.pop()
                    HD.gradientLevelsDelta.pop()

                
            for i = 0 to ltfV.size() - 1

                getHigh = ltfH.get(i), getLow = ltfL.get(i), getOIchange = oiChange.get(i), getPriceChange = ltfD.get(i)
        
                getTop = FD.tickLevels.binary_search_leftmost(getHigh)
                getBot = FD.tickLevels.binary_search_leftmost(getLow)

                signOIChange    = math.sign(getOIchange)
                signPriceChange = math.sign(getPriceChange)

                status = switch 

                    signPriceChange == 1  and signOIChange ==  1 => profile.uu
                    signPriceChange == 1  and signOIChange == -1 => profile.ud
                    signPriceChange == -1 and signOIChange ==  1 => profile.du
                    signPriceChange == -1 and signOIChange == -1 => profile.dd


                div = getOIchange / (getTop - getBot + 1) 
        
                for x = getBot to getTop 

                    switch status 

                        profile.uu => FD.upOIupPrice.set(x, FD.upOIupPrice.get(x) + div)
                        profile.ud => FD.upOIdnPrice.set(x, FD.upOIdnPrice.get(x) + div)
                        profile.du => FD.dnOIupPrice.set(x, FD.dnOIupPrice.get(x) + div)
                        profile.dd => FD.dnOIdnPrice.set(x, FD.dnOIdnPrice.get(x) + div)

                getTop := HD.gradientLevelsPrice.binary_search_leftmost(getHigh)
                getBot := HD.gradientLevelsPrice.binary_search_leftmost(getLow)

                for x = getBot to getTop 

                    HD.gradientLevelsDelta.set(x, HD.gradientLevelsDelta.get(x) + div)


            getStart = FD.tickLevels.binary_search_leftmost(low), getEnd = FD.tickLevels.binary_search_leftmost(high)

            getLevelsSize = FD.tickLevels.size()

            posVals = array.new<float>(), negVals = array.new<float>()

            valUpUp = 0., valUpDn = 0.
            valDnUp = 0., valDnDn = 0.

            for i = 0 to FD.upOIupPrice.size() - 1

                getUpUp = FD.upOIupPrice.get(i)
                getUpDn = FD.upOIdnPrice.get(i)
                getDnUp = FD.dnOIupPrice.get(i)
                getDnDn = FD.dnOIdnPrice.get(i) 

                sum = getUpUp + getUpDn + getDnUp + getDnDn
            
                switch 

                    sum > 0 => posVals.push(sum)
                    sum < 0 => negVals.push(sum)

                valUpUp := math.max(valUpUp, getUpUp)
                valUpDn := math.min(valUpDn, getUpDn)
                valDnUp := math.max(valDnUp, getDnUp)
                valDnDn := math.min(valDnDn, getDnDn)

            minGrad = math.min(nz(posVals.min()), nz(math.abs(negVals.max())))
            maxGrad = math.max(nz(posVals.max()), nz(math.abs(negVals.min())))

            stackCount = 0

            imbalanceLab = array.new<label>()

            var finalLevel = float(na)
                    
            levelsBox = array.new<box>()

            for i = getStart to getEnd 

                getLevel = FD.tickLevels.get(i)

                getLevelNext = switch i + 1 == getLevelsSize 

                    false => FD.tickLevels.get(i + 1)
                    =>       getLevel + tickAmount

                getUpUp = FD.upOIupPrice.get(i)
                getUpDn = FD.upOIdnPrice.get(i)
                getDnUp = FD.dnOIupPrice.get(i)
                getDnDn = FD.dnOIdnPrice.get(i) 

                getDelta    = getUpUp + getUpDn + getDnUp + getDnDn
                getTotalOI = math.abs(getUpUp) + math.abs(getUpDn) + math.abs(getDnUp) + math.abs(getDnDn)

                finalLevel := getLevelNext

                gradient = color(na)

                maxAction = math.max(getUpUp, math.abs(getUpDn), getDnUp, math.abs(getDnDn))

                status = switch maxAction

                    getUpUp           => profile.uu 
                    math.abs(getUpDn) => profile.ud
                    getDnUp           => profile.du 
                    math.abs(getDnDn) => profile.dd


                if col2Only

                    gradient := switch math.sign(getDelta)

                        1 => color.from_gradient(getDelta, minGrad, maxGrad, color.new(upCol, 70), color.new(upCol, 10))
                        =>   color.from_gradient(getDelta, -maxGrad, -minGrad, color.new(dnCol, 10), color.new(dnCol, 70))

                else 

                    gradient := switch status 

                        profile.uu => color.from_gradient(getUpUp, 0, valUpUp, color.new(upupCol, 70), color.new(upupCol, 10))
                        profile.ud => color.from_gradient(getUpDn, valUpDn, 0, color.new(updnCol, 10), color.new(updnCol, 70))
                        profile.du => color.from_gradient(getDnUp, 0, valDnUp, color.new(dnupCol, 70), color.new(dnupCol, 10))
                        profile.dd => color.from_gradient(getDnDn, valDnDn, 0, color.new(dndnCol, 10), color.new(dndnCol, 70))


                getDeltaP = getDelta / getTotalOI * 100

    
                txtValues = ""

                textArr = switch useSymbols

                    true => array.from("δ: ", "\nδ%: ", "\nLO: ", "\nLC: ", "\nSO: ", "\nSC:")
                    =>      array.from("Delta: ", "\nDelta Percentage: ", "\nLongs Opened: ", "\nLongs Closed: ", "\nShorts Opened: ", "\nShorts Closed: ")

                addArr = array.from(true, showDeltaP, showupup, showdndn, showdnup, showupdn)

                valuesArr = array.from(
                                         str.tostring(getDelta, format.volume), 
                                         str.tostring(getDeltaP, format.percent), 
                                         str.tostring(math.abs(FD.upOIupPrice.get(i)), format.volume), 
                                         str.tostring(math.abs(FD.dnOIdnPrice.get(i)), format.volume), 
                                         str.tostring(math.abs(FD.upOIdnPrice.get(i)), format.volume),
                                         str.tostring(math.abs(FD.dnOIupPrice.get(i)), format.volume)
                                         )


                for [x, data] in valuesArr 

                    if addArr.get(x)

                        txtValues += textArr.get(x) + data


                levelsBox.push(box.new(bar_index, getLevel, bar_index + 1, getLevelNext, border_color = chart.bg_color, border_width = 4, bgcolor = gradient,
                     text = txtValues))


                if math.abs(getDeltaP) >= imbalanceP 

                    stackCount += 1

                    [getSign, getCol] = switch status 
                        
                        profile.uu => [ 1, upupCol] 
                        profile.ud => [-1, updnCol]
                        profile.du => [ 1, dnupCol]
                        profile.dd => [-1, dndnCol]

                    if col2Only
                        
                        getCol := switch getSign 

                            1 => upCol
                            =>   dnCol


                    imbalanceLab.push(label.new(bar_index + 1, math.avg(getLevel, getLevelNext), textcolor = getCol,    
                                             text    = "▌", 
                                             size    = size.normal, 
                                             color   = #00000000,
                                             style   = label.style_label_center,
                                             tooltip = str.tostring(getDeltaP, format.percent) + " Imbalance"
                                             ))


                    if stackCount == stacked

                        alert("Stacked Imbalance", freq = alert.freq_once_per_bar_close)

                        for x = 0 to imbalanceLab.size() - 1

                            imbalanceLab.get(x).set_text(" ▏")

                    else if stackCount > stacked 

                        imbalanceLab.last() .set_text(" ▏")

                else 

                    stackCount := 0
                    imbalanceLab.clear()


            if not useCumulative

                sliceUpUp = FD.upOIupPrice.slice(getStart, getEnd + 1).abs(), sliceUpDn = FD.upOIdnPrice.slice(getStart, getEnd + 1).abs()
                sliceDnUp = FD.dnOIupPrice.slice(getStart, getEnd + 1).abs(), sliceDnDn = FD.dnOIdnPrice.slice(getStart, getEnd + 1).abs()

                sumTotal = array.new<float>()

                for i = 0 to sliceUpUp.size() - 1
                    sumTotal.push(sliceUpUp.get(i) + sliceUpDn.get(i) + sliceDnUp.get(i) + sliceDnDn.get(i)) 

                sliceVolMax   = sumTotal    .max()
                newPoc        = sumTotal    .indexof(sliceVolMax)

    
                POC = newPoc, bottom = 0, top = 0
                sliceLevels = FD.tickLevels.slice(getStart, getEnd + 1)

                label.new(bar_index, sliceLevels.get(newPoc), text = "●", textcolor = chart.fg_color, size = size.small, style = label.style_label_center, color = #00000000)

                sumOI = sumTotal.sum(), arrSize = sumTotal.size()

                for x = 0 to arrSize - 1

                    slice = sumTotal.slice(math.max(newPoc - x, 0), math.min(newPoc + x + 1, arrSize))

                    if slice.sum() / sumOI >= vaCumu

                        bottom := math.max(newPoc - x, 0)
                        top    := math.min(newPoc + x + 1, arrSize - 1)

                        getBottom = sliceLevels.get(bottom), getTop = sliceLevels.get(top)

                        label.new(bar_index, getBottom, "🞂", color = #00000000, size = size.small, style = label.style_label_center, textcolor = color.white)
                        label.new(bar_index, getTop, "🞂", color = #00000000, size = size.small, style = label.style_label_center, textcolor = color.white   )

                        if levelsBox.size() > 0
                            for data in levelsBox

                                if data.get_bottom() >= getBottom and data.get_top() <= getTop
                                    // data.set_border_color(#000000)
                                    data.set_border_width(4)
                                    // data.set_border_style(line.style_dotted)
                                    

                        break 

            if not useCumulative

                txtValues = ""


                textArr = switch useSymbols

                    true => array.from("δ: ", "\nδ%: ", "\nLO: ", "\nLC: ", "\nSO: ", "\nSC:")
                    =>      array.from("Delta: ", "\nDelta Percentage: ", "\nLongs Opened: ", "\nLongs Closed: ", "\nShorts Opened: ", "\nShorts Closed: ")

                addArr = array.from(true, showDeltaP, showupup, showdndn, showdnup, showupdn)



                getUpUp = FD.upOIupPrice.sum()
                getUpDn = FD.upOIdnPrice.sum()
                getDnUp = FD.dnOIupPrice.sum()
                getDnDn = FD.dnOIdnPrice.sum() 

                getDelta    = getUpUp + getUpDn + getDnUp + getDnDn
                getTotalOI  = math.abs(getUpUp) + math.abs(getUpDn) + math.abs(getDnUp) + math.abs(getDnDn)
                getDeltaP   = getDelta / getTotalOI * 100

                valuesArr = array.from(
                                         str.tostring(getDelta, format.volume), 
                                         str.tostring(getDeltaP, format.percent), 
                                         str.tostring(math.abs(getUpUp), format.volume), 
                                         str.tostring(math.abs(getUpDn), format.volume), 
                                         str.tostring(math.abs(getDnUp), format.volume),
                                         str.tostring(math.abs(getDnDn), format.volume)
                                         )

                for [x, data] in valuesArr 

                    if addArr.get(x)

                        txtValues += textArr.get(x) + data


                box.new(bar_index, finalLevel, bar_index + 1, finalLevel + tickAmount, border_color = #00000000, bgcolor = #00000000, text = txtValues)


if syminfo.type == "crypto"

    generateFootprint()
    var warning = table.new(position.top_right, 99, 99, bgcolor = #00000000)
    warning.cell(0, 0, "If Footprint Is Small, Please Increase Tick Size In Settings", text_color = chart.fg_color, text_size = size.tiny)


else 

    if barstate.islastconfirmedhistory

        var warning = table.new(position.middle_center, 99, 99, bgcolor = #00000000)
        warning.cell(0, 0, "Please Use A Cryptocurrency For Your Chart", text_color = chart.fg_color, text_size = size.huge)
````
