# Volume Aggregation Bars [TradingIQ]

- url: https://www.tradingview.com/script/JYq3JqgD-Volume-Aggregation-Bars-TradingIQ/
- type: indicator
- pine_id: PUB;529f279d71004212b229599bb69851d2
- version: 1.0

## Description

Hello Traders!

🔹[b]Volume Aggregation Bars[/b]

Volume Aggregation Bars is a volume-based candle visualization tool designed to show how price moves after a fixed amount of trading activity has occurred.

Instead of building candles from fixed time intervals, this tool builds candles from fixed volume thresholds.

That means each displayed bar represents a comparable amount of participation, helping traders study price movement through the lens of [b]activity, effort, efficiency, and participation-based structure[/b].

[list]
[*]builds candles from volume instead of time
[*]supports automatic or custom volume thresholds
[*]optional dollar-volume aggregation
[*]uses lower-timeframe volume data for improved accuracy
[*]shows developing volume-bar progress in real time
[*]displays directional candles with optional wicks
[*]includes a volume progress table
[/list]

🔹[b]What the tool shows[/b]

🔸[b]Volume-based candles[/b]

Traditional candles are built from time.

For example, a 5-minute candle closes every 5 minutes whether the market was active or quiet.

Volume Aggregation Bars work differently.

A new candle is created only after the selected amount of volume has traded.

This helps normalize each candle around market participation rather than time.

In simple terms:

[list]
[*]high activity creates new candles faster
[*]low activity creates new candles slower
[*]each candle reflects a more comparable amount of traded volume
[*]price movement can be studied relative to actual participation
[/list]

🔸[b]Auto or custom volume thresholds[/b]

The script can automatically estimate a useful volume threshold, or traders can manually define their own required volume amount.

You can choose between:

[list]
[*]Auto
[*]Required Volume
[/list]

Auto mode uses recent volume behavior to create a dynamic aggregation threshold.

Required Volume mode lets you choose the exact volume needed to form each new candle.

This gives flexibility for traders who want either an adaptive setting or a fixed, repeatable volume model.

🔸[b]Dollar-volume mode[/b]

The tool can also treat the required volume setting as a dollar amount.

When enabled, the script converts traded volume into dollar-volume when appropriate.

This is useful because raw volume can vary heavily between assets.

Dollar-volume can help normalize activity across different markets by focusing on the value traded rather than only the number of units traded.

🔸[b]Lower-timeframe volume aggregation[/b]

Volume Aggregation Bars can use lower-timeframe data to build more accurate volume candles.

Instead of relying only on the chart timeframe, the script can request lower-timeframe volume and price data to better track when the volume threshold is reached.

This helps improve the accuracy of each volume-based candle, especially on higher chart timeframes.

🔸[b]Directional candle coloring[/b]

Each completed volume candle is colored based on whether price closed above or below the prior completed volume candle.

This makes it easy to see whether each block of market participation resulted in upward or downward price movement.

[list]
[*]green candles show upward movement
[*]red candles show downward movement
[*]optional wicks can display the high and low within each volume block
[/list]

🔸[b]Efficiency-based transparency[/b]

The script also adjusts candle transparency based on movement efficiency.

Efficiency compares how much price moved from the previous close relative to the total high-low range of that volume block.

A cleaner directional move will appear stronger.

A choppier or less efficient move will appear more faded.

This helps separate:

[list]
[*]clean directional movement
[*]choppy movement
[*]weak movement inside a wider range
[*]high-volume activity with limited directional progress
[/list]

🔸[b]Developing current candle[/b]

The current unfinished volume candle is displayed separately while it is still forming.

The script shows the current progress toward the next completed volume bar.

This lets traders see how close the market is to completing the next volume aggregation candle.

The developing candle can help answer:

[list]
[*]how much volume has already accumulated
[*]how much volume remains before the next bar forms
[*]whether the current volume block is moving price meaningfully
[*]whether activity is speeding up or slowing down
[/list]

🔸[b]Volume progress table[/b]

The built-in table shows real-time volume progress information.

Depending on your settings, it can display:

[list]
[*]current cumulative volume
[*]volume required to create the next bar
[*]remaining volume before the next aggregation candle completes
[/list]

This gives a quick reference for how close the current candle is to completion.

🔹[b]How to read it[/b]

Each component gives a different layer of market context:

Volume candle → price movement after a fixed amount of activity  
Green candle → price moved higher after the volume block completed  
Red candle → price moved lower after the volume block completed  
Wick → high and low reached during the volume block  
Transparency → directional efficiency of the move  
Current candle → unfinished volume block in progress  
Volume table → remaining activity needed before the next bar forms  

🔹[b]Why this tool is useful[/b]

It gives you:

[list]
[*]a cleaner way to study price movement by participation
[*]an alternative to fixed-time candles
[*]a way to see whether volume is producing meaningful movement
[*]better context during high-volume and low-volume conditions
[*]a visual map of activity-based price movement
[*]a framework for comparing effort versus result
[/list]

🔹[b]Best use cases[/b]

[list]
[*]studying price movement after fixed volume thresholds
[*]analyzing high-volume market activity
[*]identifying efficient directional moves
[*]comparing active and inactive market periods
[*]observing how price reacts as participation builds
[*]filtering out some of the distortion created by fixed-time candles
[*]building context around effort versus result
[/list]

🔹[b]Important note[/b]

This tool is based on historical volume and price movement.

That means:

[list]
[*]volume bars do not predict future price direction
[*]strong volume does not guarantee continuation
[*]low efficiency does not automatically mean reversal
[*]high efficiency does not automatically mean trend strength will continue
[*]volume aggregation should be used as context, not certainty
[/list]

🔹[b]Inputs you can customize[/b]

The script includes flexible controls such as:

[list]
[*]lower-timeframe volume source
[*]automatic volume aggregation mode
[*]custom required volume threshold
[*]optional dollar-volume setting
[*]wick display
[*]number of volume blocks shown
[*]time label display options
[*]time label size
[*]candle border width
[*]volume progress table
[*]table position
[/list]

[b]Closing Notes[/b]

Volume Aggregation Bars is built to shift the focus from asking [b]what did price do after a fixed amount of time[/b] to asking [b]what did price do after a fixed amount of market activity[/b].

It helps traders visualize price movement through participation, volume efficiency, and activity-based structure.

Thank you for checking it out!

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KioseffTrading

//@version=6
indicator("Volume Aggregation Bars [Kioseff Trading]", overlay          = false, 
                                                                                          max_labels_count = 500 ,
                                                                                          max_boxes_count  = 500 ,
                                                                                          max_lines_count  = 500 , 
                                                                                          max_bars_back    = 500 , 
                                                                                          dynamic_requests = true, 
                                                                                          max_polylines_count = 100 
                                                                                          )


useLowerTFVol = input.bool(defval = true, title = "Use Lower Timeframe Volume (More Accurate)")
lowerTFvol    = input.timeframe("1", title = "Lower Timeframe", active = useLowerTFVol)

tra1     = input.string(defval = "Auto"   , title = "Auto Volume Aggregation Candles? Or Set Your Own Volume?", group = "Volume Aggregation", options = ["Auto", "Required Volume"])
volInt   = input.int   (defval = 1000000  , minval = 0, title = "Required Volume", step = 10000, group = "Volume Aggregation", inline = "Req"), useDollar = input.bool(defval = false, title = "Set As Dollar Amount", group = "Volume Aggregation", inline = "Req")
showWicks = input.bool(defval = false, title = "Show Wicks")
arrSize  = input.int   (defval = 3, minval = 1, title = "Blocks To Show", tooltip = "Increasing this shows more volume bars. Decreasing this shows less")

showY = input.bool(defval = true, title = "Show Year")
showM = input.bool(defval = true, title = "Show Month")
showD = input.bool(defval = true, title = "Show Day")
txtSize = input.string(defval = size.auto, title = "Time Label Size", options = [size.auto, size.tiny, size.small, size.normal])
bordW = input.int(minval = 1, defval = 2, title = "Candle Border Width")
showTab = input.bool(defval = true, title = "Show Volume Table", inline = "TAB")
position = input.string(defval = position.bottom_right, title = "", options = [position.bottom_right, position.bottom_left, position.bottom_center, position.top_left, position.top_right, position.top_center], inline = "TAB")

type HL 

    float H 
    float L
    float C 
    int   T

type price3D 

    array<HL> priceArr
    
type indexCount 

    int idx

method loopSplit(array<price3D> D3arr, start, end, timeArr, lastBarPolys, indexCount iCount) =>


    var timeLabels = array.new<label>() 

    size = timeLabels.size() 

    if size > 0 
        for i = 0 to size - 1
            timeLabels.shift().delete()

    for i = start to end

        points  = array.new<chart.point>()
        arrayID = D3arr.get(i)

        c = 0

        if arrayID.priceArr.size() > 1

            for x = arrayID.priceArr.size() - 1 to 1

                getTime  = timeArr.get(iCount.idx)    , getPrice  = arrayID.priceArr.get(x)
                getTimeP = timeArr.get(iCount.idx - 1), getPriceP = arrayID.priceArr.get(x - 1)


                points.unshift(chart.point.from_time(getTime, getPrice.C))

                iCount.idx -= switch 
                    showWicks => 2
                    =>           1

                if iCount.idx == 0 or polyline.all.size() > 45

                    lastBarPolys.unshift(polyline.new(points, xloc = xloc.bar_time, line_color = color.new(chart.fg_color, 25)))
                    break 
            
            if iCount.idx == 0 or polyline.all.size() > 45
                break 

            lastBarPolys.unshift(polyline.new(points, xloc = xloc.bar_time, line_color = color.new(chart.fg_color, 25)))

var pointsNow = array.new<chart.point>()

volAgg() => 

    var D3arr = array.new<price3D>(), var timeArr = array.new<int>()

    if barstate.isfirst 

        D3arr.push(price3D.new(array.new<HL>()))

    timeArr.push(time)

    getVol = switch useDollar 

        false => volume 
        =>       syminfo.volumetype != "quote" ? volume * close : volume

    [vol, price, Time] = switch useLowerTFVol

        true => request.security_lower_tf("", lowerTFvol, [getVol, close, time])
        =>      [array.from(getVol), array.from(close), array.from(time)]

    var cumuVol = 0., autoRank = ta.percentile_nearest_rank(volume, 500, 90)
    var lastBar = time
    var max = 0. 
    var min = 20e20

    volThres = switch tra1 

        "Auto" =>            autoRank
        "Required Volume" => volInt

    if vol.size() > 0 

        for [i, data] in vol 

            cumuVol += data 
            getPrice = price.get(i)
            max := math.max(max, getPrice)
            min := math.min(min, getPrice)
            if cumuVol >= volThres 


                D3arr.last().priceArr.push(HL.new(max, min, getPrice, Time.get(i)))
                lastBar := time, max := getPrice, min := getPrice

                if D3arr.last().priceArr.size() >= 4500

                    D3arr.push(price3D.new(array.new<HL>()))

                if D3arr.size() > arrSize
                    D3arr.shift()

                cumuVol *= 0


    if barstate.islast

        if not useDollar
            var tab = table.new(position, 99, 99, force_overlay = true, bgcolor = #20222C, border_color = #363843, frame_color  = #363843, border_width = 1, frame_width = 1)

            if showTab 

                tab.cell(0, 0, "Cumulative Vol: ", text_color = color.white)
                tab.cell(1, 0, str.tostring(cumuVol, format.volume), text_color = color.white)
                tab.cell(0, 1, "Volume To Create Next Bar: ", text_color = color.white)
                tab.cell(1, 1, str.tostring(volThres - cumuVol, format.volume), text_color = color.white)
            

        var lastBarPolys = array.new<polyline>()
        var recentBoxes  = array.new<box>() 
        var recentWicks  = array.new<line>()   
    
        polySize = lastBarPolys.size()

        if polySize > 0 
            for i = 0 to polySize - 1
                lastBarPolys.shift().delete()

        sizeBox = recentBoxes.size() 

        if sizeBox > 0 
            for i = 0 to sizeBox - 1
                recentBoxes.shift().delete()

        sizeWicks = recentWicks.size()

        if sizeWicks > 0 
            for i = 0 to sizeWicks - 1
                recentWicks.shift().delete()

        if D3arr.size() > 0 

            last     = D3arr.last().priceArr
            sizeLast = last.size()
            c = 0

            if sizeLast > 0 
                for i = sizeLast - 1 to math.max(1, sizeLast - 500)

                    getP  = last.get(i)
                    getP1 = last.get(i - 1)

                    col = switch getP.C > getP1.C 
                        true => #55ffda
                        =>      color.rgb(255, 116, 116)

                    move       = math.abs(getP.C - getP1.C)
                    Range      = math.max(getP.H - getP.L, syminfo.mintick)

                    efficiency = move / Range
                    y  = year(getP.T)
                    mo = month(getP.T)
                    d  = dayofmonth(getP.T)
                    h  = hour(getP.T)
                    mi = minute(getP.T)

                    effTransp = switch 
                        efficiency  > 0.75 => 15 
                        efficiency  > 0.50 => 35 
                        efficiency  > 0.25 => 70 
                        =>                    90

                    bgCol = color.new(col, effTransp)
                    txt = ""

                    dateTxt = ""

                    if showY
                        dateTxt += str.tostring(y)

                    if showM
                        dateTxt += (dateTxt == "" ? "" : "/") + str.tostring(mo, "00")

                    if showD
                        dateTxt += (dateTxt == "" ? "" : "/") + str.tostring(d, "00")

                    txt := dateTxt

                    timeTxt = str.tostring(h) + ":" + str.tostring(mi, "00")

                    txt += (txt == "" ? "" : "\n") + timeTxt 
                    txt += "\n" + str.tostring((getP.C /getP1.C - 1) * 100, format.percent)

                    
                    endPoint = switch showWicks 
                        true => 2 
                        =>      1
            
                    recentBoxes.push(box.new(bar_index - c, last.get(i - 1).C, bar_index - c - endPoint , last.get(i).C, border_color = chart.bg_color, bgcolor = bgCol, text = txt, text_color = chart.fg_color, border_width = bordW))
                   
                    if showWicks 
                        
                        recentWicks.push(line.new(bar_index - c - 1, getP.H, bar_index - c - 1, getP.L, color = col))
                    
                    c += switch 
                        showWicks => 2
                        =>           1
                            
            if cumuVol > 0 and sizeLast > 0
                prevP = last.last()

                curHigh = math.max(max, close)
                curLow  = math.min(min, close)

                curCol = close > prevP.C ? #55ffda : color.rgb(255, 116, 116)

                progress = cumuVol / volThres
                curTransp = 100 - int(math.min(progress, 1.0) * 70)
                end = switch showWicks
                    true => 2 
                    =>      1
                recentBoxes.push(box.new(
                    bar_index,
                    prevP.C,
                    bar_index + end,
                    close,
                    border_color = chart.bg_color,
                    bgcolor = color.new(curCol, curTransp),
                    text = "Current\n" + str.tostring(progress * 100, format.percent),
                    text_color = chart.fg_color,
                    border_width = bordW
                ))

                if showWicks
                    recentWicks.push(line.new(bar_index + 1, curHigh, bar_index + 1, curLow, color = curCol))

            iCount = indexCount.new(timeArr.size() - 1)

            size  = D3arr.size(), step  = math.floor(size / 5)
            start = size - 1,     end   = start - step

            D3arr.loopSplit(start, 0, timeArr, lastBarPolys, iCount)

volAgg()
````
