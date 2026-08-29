<!-- tradingview-pine-id: PUB;40c3ad5b0fbe4ca487e7d24553b1f44f -->
<!-- tradingviewscripts-format: 1 -->
# CVD Profiles [TradingIQ]

Source: https://www.tradingview.com/script/zHFJQYwG-CVD-Profiles-TradingIQ/

## Description

Hello Traders!

🔹CVD Profiles

CVD Profiles is a profile-based order flow visualization tool designed to show how participation distributes across price levels - not just over time, but through price itself.

Think volume profile data + TPO time segmenting!

Instead of looking at cumulative delta as a single line, this tool breaks it down into a price-based structure, revealing where activity, imbalance, and participation actually occurred within the session.

It focuses on answering a more important question:

Where did participation concentrate… and how did it distribute across price/time?

 [*]cumulative delta distributed by price level
 [*]buy vs sell activity mapped into profiles
 [*]imbalance and dominance across structure
 [*]value areas and point of control
 [*]activity concentration (volume, USD, or delta-based)
 [*]how participation builds within a session
 
🔹What the tool shows

🔸CVD Profile (price-based structure)

Instead of viewing delta as a time series, this tool distributes it across price levels - forming a profile of participation.

This allows you to see:

 [*]where buying pressure accumulated
 [*]where selling pressure dominated
 [*]which price levels attracted the most activity
 
[image]https://www.tradingview.com/x/E0p2jifw/[/image]
[image]https://www.tradingview.com/x/hEgAXtAa/[/image] 

🔸Imbalance Ratio (dominance structure)

Imbalance mode shifts the focus from raw participation to relative dominance between buyers and sellers at each price level.

Each level reflects the ratio between buy and sell activity, highlighting where one side clearly outweighed the other.

This allows you to see:

[*]where buyers strongly dominated sellers
[*]where sellers overwhelmed buying pressure
[*]areas of clear directional conviction

High imbalance levels often represent:

[*]aggressive participation
[*]momentum-driven behavior
[*]one-sided control at specific prices

Balanced areas, on the other hand, suggest:

[*]indecision
[*]two-sided trade
[*]lack of conviction

[image]https://www.tradingview.com/x/ExnyJUFU/[/image]
[image]https://www.tradingview.com/x/ThqkHadJ/[/image] 

🔸Activity Mode (participation intensity)
Activity mode focuses on how much trading activity occurred at each price level, regardless of direction.

Instead of separating buyers and sellers, this mode aggregates total participation to reveal:

[*]high interest zones
[*]areas of heavy interaction
[*]where the market spent the most effort

This helps identify:

[*]key auction areas
[*]high liquidity regions
[*]zones where price is likely to react

Low activity areas often indicate:

[*]inefficient movement
[*]thin liquidity
[*]potential for fast price movement

This mode is about effort - not direction.

[image]https://www.tradingview.com/x/PBtXvhwB/[/image] 
[image]https://www.tradingview.com/x/5en1Nqg2/[/image] 

🔸USD Volume Mode (capital-weighted activity)

USD Volume mode builds on activity by incorporating price-weighted participation.

Instead of just counting volume, it measures:
“where was the most capital traded?”

This highlights:

[*]price levels with the highest notional value traded
[*]areas of significant financial commitment
[*]where larger participants may be involved

Compared to raw activity, this mode emphasizes:

[*]higher-priced transactions
[*]capital concentration rather than trade count

This is especially useful for:

[*]spotting institutional interest
[*]identifying meaningful participation zones
[*]filtering out low-value noise

This mode is about capital — not just volume.

[image]https://www.tradingview.com/x/placeholder3/[/image] 
[image]https://www.tradingview.com/x/QVezP0mC/[/image] 

🔸Multiple profile models
The script supports different ways to interpret participation:

 [*]CVD → raw cumulative delta distribution
 [*]Imbalance Ratio → relative dominance (buy vs sell strength)
 [*]Activity → total participation intensity
 [*]USD Volume → capital-weighted activity
 
Each model answers a slightly different question about the market.

🔸Value Area & POC
The tool automatically calculates:

 [*]Point of Control (POC) → highest participation level
 [*]Value Area High (VAH)
 [*]Value Area Low (VAL)
 
This helps identify:

 [*]fair value
 [*]high liquidity regions
 [*]areas where price is most accepted
 
These levels often act as key reference points for structure and reaction.

[image]https://www.tradingview.com/x/2oKx9M5U/[/image] 

🔸Initial Balance (IB)

The script tracks the initial balance range.
This highlights:

 [*]early session structure
 [*]range expansion vs containment
 [*]where price begins its auction
 
It provides context for how the session develops relative to its starting range.

[image]https://www.tradingview.com/x/1avPRoul/[/image] 

🔸Profile stacking (time progression)

Profiles are built over time and stacked horizontally, showing how participation evolves.
This allows you to observe:

 [*]shifts in dominance over time
 [*]expansion of participation into new price zones
 [*]whether activity is building or fading
 
Instead of a static snapshot, you get a dynamic structural progression.

[image]https://www.tradingview.com/x/tRYGQTuG/[/image] 
[image]https://www.tradingview.com/x/LIrx4czJ/[/image] 
[image]https://www.tradingview.com/x/ouurzNg0/[/image] 
[image]https://www.tradingview.com/x/XHYa5LUq/[/image] 

🔸Gradient-based intensity

Color gradients represent the magnitude of activity.
This helps highlight:

 [*]high participation nodes
 [*]low interest areas
 [*]extreme dominance zones
 
Stronger colors = stronger participation.

🔸CVD Delta / Acceleration histogram
An off-chart histogram shows:

[*]CVD Delta → change in participation
[*]CVD Acceleration → change in momentum of participation

CVD Delta represents the amount of buying vs selling pressure added during the current bar.

In simple terms:

[*]positive delta → more buying than selling
[*]negative delta → more selling than buying

This tells you who was in control during that bar.

CVD Acceleration takes it one step further.

It measures how quickly delta itself is changing:

[*]increasing acceleration → pressure is building
[*]decreasing acceleration → pressure is slowing
[*]sharp shifts → potential transitions in control

This helps answer a deeper question:

“Is participation just present… or is it expanding?”

Together, they give you a clearer read on:

[*]whether buying/selling is increasing
[*]whether momentum is building or fading
[*]when participation is strengthening vs weakening

Think of it like this:

[*]CVD Delta = current pressure
[*]CVD Acceleration = change in pressure

Strong trends are often accompanied by:

[*]consistent delta in one direction
[*]positive acceleration early in the move

While weakening moves often show:

[*]falling delta
[*]negative or declining acceleration

[image]https://www.tradingview.com/x/MHSxsjIz/[/image]
[image]https://www.tradingview.com/x/wYdWry0F/[/image]
🔹How to read it

Each component provides a different layer:

Profile → where participation occurred
POC / VA → where value is established
Model selection → what type of participation you're measuring
Histogram → how participation is changing

🔹Example interpretations

 [*]high activity at a level → strong interest / potential reaction zone
 [*]thin profile areas → low liquidity / fast movement zones
 [*]POC holding → acceptance
 [*]POC shifting → changing value
 [*]expanding profile → active auction
 [*]contracting profile → consolidation
 

🔹Why this tool is useful
It gives you:

 [*]price-based participation mapping
 [*]clear visualization of where trading actually occurred
 [*]context for value and liquidity
 [*]insight into dominance and imbalance
 [*]a structural view of order flow instead of just time-based data
 

🔹Best use cases

 [*]identifying key reaction levels
 [*]analyzing auction behavior
 [*]tracking value shifts across sessions
 [*]confirming strength or weakness at price
 [*]enhancing liquidity-based or structure-based strategies
 

🔹Important note
This tool uses lower timeframe data to reconstruct participation.
This means:

 [*]it is an approximation of order flow
 [*]accuracy depends on available intrabar data
 [*]lower timeframe selection impacts precision
 

🔹Important consideration
CVD and participation:

 [*]can drive price
 [*]can fail to move price
 [*]can be absorbed by opposing liquidity
 
Location matters just as much as magnitude.

🔹Inputs you can customize
The script includes flexible controls such as:

 [*]profile model selection
 [*]lower timeframe input
 [*]profile resolution (tick size)
 [*]value area percentage
 [*]fixed start vs rolling sessions
 [*]color customization
 [*]histogram mode (delta vs acceleration)
 

Closing Notes

This tool is built to shift your perspective from time-based indicators to price-based participation analysis.

It helps you understand not just what the market did — but where it mattered most.

It may receive updates based on feedback - stay tuned!

Thank you TradingView as always!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingIQ

//@version=6
indicator("CVD Profiles [TradingIQ]", calc_bars_count = 10000, overlay = false, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, max_bars_back = 1500)


enum calcType 

    REG = "Regular"
    FS  = "Fixed Start"

model                                  = input.string(defval = "CVD", title = "Model", options = ["CVD", "Imbalance Ratio", "Activity", "USD Volume"])
timeframe                              = input.timeframe(defval = "", title = "Timeframe To Calculate New Blocks On")
TF                                     = input.timeframe(defval = "1", title = "Lower Timeframe Volume")
offChart                               = input.string(defval = "CVD Delta", title = "CVD Offchart Data", options = ["CVD Delta", "CVD Acceleration"])

calcTypeInput                          = input.enum(defval = calcType.REG, title = "Calculation Type", options = [calcType.REG, calcType.FS], group = "Calculation Type")
fixedStartTime                         = input.time(timestamp("01 Apr 2026 00:00"), title = "Fixed Start Time", active = calcTypeInput == calcType.FS)
ticks                                  = input.float(defval = 0 ,title = "Ticks Per Row (0 == Auto)", group = "Calculation Type")
textSize                               = input.string(title = "Text Size", defval = "Small", options = ["Auto","Tiny", "Small", "Normal", "Large", "Huge"], group = "Current Session Configurations")
showVA                                 = input.bool(defval = true, title = "Show Single VA Lines", group = "Current Session Configurations")

vaCumu                                 = input.float(defval = 70, title = "Value Area %", minval = 0, maxval = 100) / 100
upCol                                  = input.color(defval = #55ffda, title = "Up Color", group = "Colors")
dnCol                                  = input.color(defval = color.rgb(255, 116, 116), title = "Down Color", group = "Colors")
actCol                                 = input.color(defval = #ff65fb, title = "Activity Color", group = "Colors")
usdCol                                  = input.color(defval = #5855ff, title = "USD Volume", group = "Colors")
IBcol                                  = input.color(defval = #ff65fb, title = "IB Character Color", group = "Colors")
vaCol                                  = input.color(defval = #74ffbc, title = "Value Area Color", group = "Colors")
POCcol                                 = input.color(defval = #c7ff74, title = "POC Character Color", group = "Colors")



type cvdData

    array<float>  tickLevels 
    array<float>  cvd
    array<float>  buyVol 
    array<float>  sellVol 
    array<float>  totalVol 
    array<float>  deltaVol
    array<float>  activity

type singleProfileUDT

    array<box>   singleProfiledraw
    array<color> proColor
    int right = bar_index
    array<float> usdVol
    int         timeBlock




finTim = switch calcTypeInput
    
    calcType.REG => timeframe.change("1D")
    calcType.FS  => time[1] < fixedStartTime and time >= fixedStartTime


sz = switch textSize
    
    "Auto"             => size.auto
    "Tiny"             => size.tiny
    "Small"            => size.small
    "Normal"           => size.normal
    "Large"            => size.large
    "Huge"             => size.huge


method shifprofilespAll(array<float> tickLevels, array<float> cvd, array<float> buyVol, array<float> sellVol, array<float> totalVol, array<float> deltaVol, array<float> activity, pop = false) =>

    if tickLevels.size() > 90000

        switch pop 

            false => 

                     tickLevels.shift(), cvd.shift(), buyVol.shift(), sellVol.shift(), totalVol.shift(), deltaVol.shift(), activity.shift()

            =>    
                     tickLevels.pop() , cvd.shift(), buyVol.pop(), sellVol.pop(), totalVol.pop(), deltaVol.pop(), activity.pop()


method extendLines(array<line> id, sizeCount, startIndex) => 

    if id.size() > sizeCount 

        for i = id.size() - startIndex to 0 

            getValue = id.get(i).get_y1()

            if high >= getValue and low <= getValue 

                id.remove(i)
                continue 

            id.get(i).set_x2(time)


direction() => 
    if TF == "1T" 
        switch 
            close == bid => -1 
            close == ask =>  1
            =>               math.sign(close - close[1]) 
    else 
        math.sign(close - close[1])



profiles() => 

    var valueAreas          = array.new<float>()
    var valueAreaDrawings   = array.new<line> ()
    var pocDrawings         = array.new<line>()

    atr = ta.atr(14)

    [dayStart, dayEnd]             = request.security(syminfo.tickerid, "1D", [last_bar_time, time_close], lookahead = barmerge.lookahead_on)
    [ltfV, ltfD, ltfC, ltfH, ltfL] = request.security_lower_tf(syminfo.tickerid, TF, [volume * direction(), math.sign(close - close[1]), close, high, low])

    var cvd = 0. 

    cvd += nz(ltfV.sum())

    cvdDelta = nz(cvd - cvd[1]) 

    cvdAccel = nz(cvdDelta - (cvd[1] - cvd[2]))



    var lowOfMain = float(na), var highOfMain = float(na)

    desiredTF = timeframe.in_seconds(timeframe)

    var finalTF = switch 

        desiredTF < timeframe.in_seconds("") => timeframe.in_seconds("")
        =>          desiredTF

    lastDay = time >= dayStart and calcTypeInput == calcType.REG or time >= fixedStartTime and calcTypeInput == calcType.FS

    var tickAmount = 0.

    var TP = cvdData.new(array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>(), array.new<float>())

    var indexGet = 0 , var numberAdd  = 0, var startTime  = 0, 
    var max      = 0., var min = 20e20   , var IBend      = 0, 
    var indexIBS = 0., var indexIBE  = 0., var startTick  = 0.
    var maxIndex = 0 , var indexMax  = 0 , var startBar   = 0

    var profilesdraw       = array.new<label>(), var letterCount = array.new<int>(), 
    var singleProData = array.new<singleProfileUDT>(), isNew = false       

    if barstate.isfirst

        for i = 0 to 2
            singleProData.push(singleProfileUDT.new(array.new<box>(), array.new<color>(), bar_index, array.new<float>()))


    if profilesdraw.size() > 0 

        for i = 0 to profilesdraw.size() - 1

            profilesdraw.shift().delete()

    valueAreaDrawings.extendLines(2, 3)
    pocDrawings      .extendLines(1, 2)


    if finTim

        tickAmount := switch ticks == 0 

            true => atr   * syminfo.mintick
            =>      ticks * syminfo.mintick

        startTick     := math.floor(open / tickAmount) * tickAmount
        TP.tickLevels := array.from(startTick - tickAmount, startTick, startTick + tickAmount)
        TP.cvd        := array.from(0, 0, 0)
        TP.buyVol     := array.from(0, 0, 0)
        TP.sellVol    := array.from(0, 0, 0)
        TP.totalVol   := array.from(0, 0, 0)
        TP.deltaVol   := array.from(0, 0, 0)
        TP.activity   := array.from(0, 0, 0)

        isNew         := true 

        singleProData := array.new<singleProfileUDT>()

        
        if lastDay
                
            for i = 0 to 2
                singleProData.push(singleProfileUDT.new(array.new<box>(), array.new<color>(), bar_index, array.new<float>()))

                if i < 2 and showVA

                    valueAreaDrawings.push(line.new(time, close, time, close, xloc = xloc.bar_time, color = vaCol, style = line.style_dotted, force_overlay = true))

            pocDrawings.push(line.new(time, close, time, close, xloc = xloc.bar_time, color = POCcol, style = line.style_dotted, force_overlay = true))

        label.new(bar_index + 1, open, color = IBcol, style = label.style_circle, size = 2, force_overlay = true)
        label.new(bar_index + 1, open, color = color.new(IBcol, 80), style = label.style_circle, size = 3, force_overlay = true)

        IBend := timestamp(year, month, dayofmonth, hour + 1, 00, 00)

        indexGet := -1, numberAdd := 0,     startTime := time, startBar := bar_index
        max      := 0, min       := 20e20, indexIBS  := startTick, 
                             indexIBE := startTick
    var minUSDvol = float(na), var maxUSDvol = 0.
                


    if TP.tickLevels.size() > 0 and lastDay

        last  = TP.tickLevels.last () 
        first = TP.tickLevels.first()
        if TP.activity.size() > 0
            TP.activity.fill(0)

        max := math.max(max, high), min := math.min(min, low), 

        while high >= last

            last += tickAmount

            TP.tickLevels.push(last)
            TP.cvd       .push(0)
            TP.buyVol    .push(0)
            TP.sellVol   .push(0)
            TP.totalVol  .push(0)
            TP.deltaVol  .push(0)
            TP.activity  .push(0)

            TP.tickLevels.shifprofilespAll(TP.cvd, TP.buyVol, TP.sellVol, TP.totalVol, TP.deltaVol, TP.activity)

            if lastDay 

                singleProData.push(singleProfileUDT.new(array.new<box>(), array.new<color>(), bar_index, array.new<float>()))

        if time_close <= IBend

            indexIBE := math.max(high, indexIBE)

        while low <= first

            first -= tickAmount

            TP.tickLevels.unshift(first)
            TP.cvd       .unshift(0)
            TP.buyVol    .unshift(0)
            TP.sellVol   .unshift(0)
            TP.totalVol  .unshift(0)
            TP.deltaVol  .unshift(0)
            TP.activity  .unshift(0)

            TP.tickLevels.shifprofilespAll(TP.cvd, TP.buyVol, TP.sellVol, TP.totalVol, TP.deltaVol, TP.activity, true)
                
            if lastDay 

                singleProData.unshift(singleProfileUDT.new(array.new<box>(), array.new<color>(), bar_index, array.new<float>()))

        if time_close <= IBend 

            indexIBS := math.min(indexIBS, low)

        if ltfV.size() > 0 
            for [i, data] in ltfV

                start = TP.tickLevels.binary_search_leftmost(ltfL.get(i))
                end   = TP.tickLevels.binary_search_leftmost(ltfH.get(i))

                div   = data / (math.abs(end - start) + 1)

                for x = start to end 

                    add = TP.cvd.get(x) + nz(div)

                    TP.cvd.set(x, add)

                    absAmount = math.abs(nz(div))

                    switch math.sign(div)

                        1  => TP.buyVol .set(x, absAmount)
                        -1 => TP.sellVol.set(x, absAmount)

                    TP.totalVol.set(x, TP.totalVol.get(x) + absAmount)
                    TP.deltaVol.set(x, (nz(TP.buyVol.get(x) / TP.sellVol.get(x))))

                    mult = switch syminfo.volumetype != "quote"

                        false => 1
                        =>       ltfC.get(i)

                    switch model 

                        "USD Volume" => TP.activity.set(x, TP.activity.get(x) + (absAmount * mult))
                        =>              TP.activity.set(x, TP.activity.get(x) + absAmount)
                            
        timeN1 = startTime + timeframe.in_seconds("") * 1000, getTF = timeframe.from_seconds(desiredTF)

        getMax = TP.totalVol.max()

        valueIndexStart = 0, valueIndexEnd = 0, pocStart = TP.totalVol.indexof(getMax)

        bottom = 0, top = 0

        sumCount = TP.totalVol.sum(), arrSize = TP.totalVol.size()
        
        if na(lowOfMain)
            lowOfMain := low 
            highOfMain := high 

        lowOfMain  := math.min(low, lowOfMain)
        highOfMain := math.max(high, highOfMain)

        startIndex = TP.tickLevels.binary_search_leftmost(lowOfMain)
        endIndex   = TP.tickLevels.binary_search_leftmost(highOfMain)

        geprofilesCprice = switch 
            
            not na(pocStart) => TP.tickLevels.get(pocStart)
            =>                  float(na)

        if lastDay 

            pocDrawings.last().set_xy2(time, geprofilesCprice)
            pocDrawings.last().set_y1 (geprofilesCprice)

            for x = 0 to arrSize - 1

                slice = TP.totalVol.slice(math.max(pocStart - x, 0), math.min(pocStart + x + 1, arrSize))

                if slice.sum() / sumCount >= vaCumu

                    bottom := math.max(pocStart - x, 0)
                    top    := math.min(pocStart + x + 1, arrSize - 1)

                    getTop      = TP.tickLevels.get(top), getBot = TP.tickLevels.get(bottom)

                    if valueAreaDrawings.size() > 0

                        getDrawings = valueAreaDrawings.last()

                        getDrawings.set_y1(getTop), getDrawings.set_xy2(time, getTop)

                        getDrawings := valueAreaDrawings.get(-2)

                        getDrawings.set_y1(getBot), getDrawings.set_xy2(time, getBot)

                    break 

            midDay = math.avg(dayStart, dayEnd)


            lowOfMain := float(na)
            highOfMain := float(na)

            var timeBlock = time

            if timeframe.change(timeframe)

                timeBlock := time 

                if model == "Activity" or model == "USD Volume"

                    if singleProData.size() > 0 

                        for data in singleProData 
                            for boxes in data.singleProfiledraw

                                boxes.set_border_color(#000000)

            for i = startIndex to endIndex 

                getLevel = singleProData.get(i), 
                getPrice = TP.tickLevels.get(i), 
                getSize = getLevel.singleProfiledraw.size()
                getCVD   = TP.cvd.get(i), 
                deltaRatio = TP.deltaVol.get(i)

                left = switch getSize
            
                    0 => startBar + 2
                    =>   getLevel.right 

                transp = switch 
                    
                    i >= bottom and i <= top => 0
                    =>                          60


                absCVD = TP.cvd.abs(), absDelta = TP.deltaVol.abs()
                
                [minSeries, maxSeries, seriesNow] = switch model

                    "Imbalance Ratio" => [absDelta.min(), absDelta.max(), deltaRatio]
                    =>                   [absCVD.min(), absCVD.max(), getCVD]

                colorBox = switch math.sign(seriesNow)

                    1  => color.from_gradient(seriesNow, minSeries, maxSeries, color.new(upCol, 90), upCol)
                    -1 => color.from_gradient(math.abs(seriesNow), minSeries, maxSeries, color.new(dnCol, 90), dnCol)
                    =>    color.gray 

                if model == "Imbalance Ratio"

                    colorBox := switch 

                        seriesNow >= 1  => color.from_gradient(seriesNow, 1, absDelta.max(), color.new(upCol, 90), upCol)
                        seriesNow < 1   => color.from_gradient(math.abs(seriesNow), absDelta.min(), 1, dnCol, color.new(dnCol, 90))
                        =>    color.gray 


                if model == "Activity"

                    seriesNow := TP.activity.get(i) / volume 

                    colorBox := color.from_gradient(seriesNow, 0, 0.75, color.new(actCol, 90), actCol)

                if model == "USD Volume"

                    seriesNow := TP.activity.get(i)

                    colorBox := color.from_gradient(seriesNow, 0, 75, color.new(actCol, 90), actCol)

                if na(minUSDvol)

                    minUSDvol := seriesNow 

                minUSDvol := math.min(seriesNow, minUSDvol)
                maxUSDvol := math.max(seriesNow, maxUSDvol)

                if na(getLevel.timeBlock) or timeBlock > getLevel.timeBlock

                    getLevel.usdVol.push(seriesNow)

                    getLevel.singleProfiledraw.push(
                            box.new(
                                    left, getPrice , left + 1, getPrice + tickAmount,
                                            border_color = model == "Activity" or model == "USD Volume" ? #fff455: #000000,
                                            bgcolor      = colorBox, 
                                            text         = str.tostring(seriesNow, model == "Activity" or model == "Imbalance Ratio"  ? "0%" : model != "CVD" and model != "USD Volume" ? format.percent : format.volume), 
                                            text_color   = color.white, force_overlay = true
                                            )) 

                    getLevel.right := left + 1
                    getLevel.timeBlock := timeBlock

                else 

                    getLevel.usdVol.set(getLevel.usdVol.size() - 1, seriesNow)

                    getBox = getLevel.singleProfiledraw.last()

                    getBox.set_border_color(model == "Activity" or model == "USD Volume" ? #fff455: #000000)

                    getBox.set_bgcolor(colorBox)
                    getBox.set_text(str.tostring(seriesNow, model != "CVD" and model != "USD Volume" ? format.percent : format.volume))

    
        if lastDay 
                
            var box       VAbox                 = box  (na)
            var line      sessionLineLower      = line (na)
            var line      sessionOutlineLower   = line (na)
            var line      sessionLineUpper      = line (na)
            var line      sessionOutlineUpper   = line (na)
            var label     profilesLab                = label(na)
            var line      VAline                = line(na)
            var line      VAlineOutline         = line(na)
            var line      IBline                = line(na)
            var line      IBoutline             = line(na)

            VAbox               .delete(), sessionLineLower    .delete(), sessionOutlineLower .delete()
            sessionLineUpper    .delete(), sessionOutlineUpper .delete(), profilesLab              .delete()
            VAline              .delete(), VAlineOutline       .delete(), IBline              .delete(),
                                                 IBoutline.delete()

            getTop    = TP.tickLevels.get(top), getBot = TP.tickLevels.get(bottom), 

            IBline                := line.new(timeN1, indexIBS, timeN1, indexIBE, 
                                            xloc  = xloc.bar_time, 
                                            color = IBcol, force_overlay = true
                                            )
                
            var modelLab = label(na)
            modelLab.delete()

            if TP.tickLevels.size() > 0

                modelLab := label.new(timeN1 + timeframe.in_seconds("") * 1000 * 2, TP.tickLevels.last(), xloc = xloc.bar_time, text = model, textcolor = chart.fg_color, size = size.normal, color = #00000000, force_overlay = true)

            var ibOutLines = array.new<line>()

            if ibOutLines.size() > 0

                for i = 0 to ibOutLines.size() - 1
                    ibOutLines.shift().delete()

            transp = array.from(96, 97, 98, 99)

            for i = 0 to 3

                ibOutLines.push(line.new(timeN1, indexIBS, timeN1, indexIBE, xloc = xloc.bar_time, color = color.new(IBcol, transp.get(i)), width = (i + 1) * 4, force_overlay = true))

            var keyLevelsLabels = array.new<label>()
                
            size = keyLevelsLabels.size()

            if size > 0 
                for i = 0 to size - 1
                    keyLevelsLabels.shift().delete()

            prices = array.from(getBot, getTop, TP.tickLevels.get(math.floor(TP.tickLevels.size() / 2)), startTick, geprofilesCprice)
            texts  = array.from("VAL", "VAH", "Mid", "IB", "POC")
            colors = array.from(vaCol, vaCol, color.rgb(255, 116, 116), IBcol, POCcol)

            for [i, data] in prices 

                keyLevelsLabels.push(label.new(startTime, data, xloc = xloc.bar_time, 
                                            text      = texts.get(i) + " ▸",
                                            color     = #00000000, 
                                            textcolor = colors.get(i), 
                                            size      = size.small, 
                                            style     = label.style_label_right,
                                            force_overlay = true
                                            ))

                keyLevelsLabels.push(label.new(startTime, data, xloc = xloc.bar_time, 
                                            text      = texts.get(i) + " ▸",
                                            color     = #00000000, 
                                            textcolor = colors.get(i), 
                                            size      = size.small, 
                                            style     = label.style_label_right,
                                            force_overlay = true
                                            ))


            if session.islastbar and calcTypeInput == calcType.REG

                sizeLab = keyLevelsLabels.size()

                if sizeLab > 0 
                    for i = 0 to sizeLab - 1
                        keyLevelsLabels.shift().delete()

                profilesdraw             .clear(), sessionLineLower    := na
                sessionOutlineLower := na   , profilesLab              := na
                sessionLineUpper    := na   , sessionOutlineUpper := na
                VAbox               := na   , VAline              := na
                VAlineOutline       := na   , IBline              := na, 
                IBoutline           := na   , keyLevelsLabels.clear()
                ibOutLines.clear()
                singleProData.clear()
                minUSDvol := float(na)
                maxUSDvol := 0.
   
    if barstate.islast 

        getLabX = label.all.first().get_x()
            
        for lines in line.all 
            if lines.get_x1() < getLabX 
                lines.delete()

        if model == "USD Volume"

            if singleProData.size() > 0 
                for data in singleProData
                    for [x, boxes] in data.singleProfiledraw 

                        getVol   = data.usdVol.get(x)

                        boxes.set_bgcolor(color.from_gradient(getVol, minUSDvol, maxUSDvol, color.new(usdCol, 90), usdCol))



    [cvdAccel, cvdDelta]

[cvdAccel, cvdDelta] = profiles()

var maxAmt = array.new<float>(0) 

plotSeries = switch offChart == "CVD Delta"

    true => cvdDelta
    =>      cvdAccel


if not na(plotSeries)

    absData = math.abs(plotSeries)

    if maxAmt.size() == 0 

        maxAmt .push(absData)

    else 

        if absData > maxAmt.min()

            search = maxAmt.binary_search_rightmost(absData)

            maxAmt.insert(search, absData)

            if maxAmt.size() > 50
                maxAmt.shift()

colCols = switch

    plotSeries >= 0 => color.from_gradient(plotSeries, 0, maxAmt.min() , color.new(upCol, 90), upCol)
    =>                 color.from_gradient(plotSeries, -maxAmt.min() , 0, dnCol, color.new(dnCol, 90))

plot(plotSeries, style = plot.style_columns, color = colCols)

if barstate.islast 

    if calcTypeInput == calcType.FS

        var vline = line(na), var vlab = label(na)

        vline.delete(), vlab.delete()

        vline := line.new (fixedStartTime, 0, fixedStartTime, 0.0001, xloc = xloc.bar_time, extend = extend.both, color = chart.fg_color, width = 2)
        vlab  := label.new(fixedStartTime, 0, xloc = xloc.bar_time, color = #00000000, textcolor = chart.fg_color, text = "Drag Me")


    if box.all.size() >= 495 

        var tab    = table.new(position.top_right, 99, 99, 
                                        bgcolor       = #20222C, 
                                        border_color  = #363843, 
                                        frame_color   = #363843, 
                                        border_width  = 1, 
                                        frame_width   = 1, 
                                        force_overlay = true
                                        )
        tab.clear(0, 0, 0, 0)
        tab.cell(0, 0, text = 'Increase "Tick Size" Or "Timeframe To Calculate On"', text_color = color.white, text_size = size.small)
````
