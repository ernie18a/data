<!-- tradingview-pine-id: PUB;3ba6c6f519374988b3f0b6fe0505ae21 -->
<!-- tradingviewscripts-format: 1 -->
# Monte Carlo Simulation [Kioseff Trading]

Source: https://www.tradingview.com/script/cvEVOXaH-Monte-Carlo-Simulation-Your-Strategy-Kioseff-Trading/

## Description

Hello!

This script “Monte Carlo Simulation - Your Strategy” uses Monte Carlo simulations for your inputted strategy returns or the asset on your chart!

Features

[*]Monte Carlo Simulation: Performs Monte Carlo simulation to generate multiple future paths.
[*]Asset Price or Strategy: Can simulate either future asset prices based on historical log returns or a specific trading strategy's future performance.
[*]User-Defined Input: Allows you to input your own historical returns for simulation.
[*]Statistical Methods: Offers two simulation methods—Gaussian (Normal) distribution and Bootstrapping.
[*]Graphical Display: Provides options for graphical representation, including line plots and histograms.
[*]Cumulative Probability Target: Enables setting a user-defined cumulative probability target to quantify simulation results.
[*]Adjustable Parameters: Offers numerous user-adjustable settings like number of simulations, forecast length, and more.
[*]Historical Data Points: Option to specify the amount of historical data to be used in the simulation (price).
[*]Custom Binning: Allows you to select the binning method for histograms, with options like Sturges, Rice, and Square Root.
[*]Best/Worst Case: Allows you to show only the best case / worst case outcome (range) for all simulations!
[*]Scatterplot: allows you to show up to 1000 potential outcomes for a specified trade number (or bars forward price endpoint) using a scatter plot.

[image]https://www.tradingview.com/x/6i0yZ7Nl/[/image]

The image above shows the primary components of the indicator!

[image]https://www.tradingview.com/x/mZmX2eZm/[/image]

The image above shows the best/worst case outcome feature in action!

[image]https://www.tradingview.com/x/giyq0MEN/[/image]

The image above shows a "fun feature" where 1000 simulated end points for a 15-bar price trajectory are shown as a scatter plot!

How To Perform a Monte Carlo Simulation On Your Strategy

Really, you can input any data into the indicator it will perform a Monte Carlo Simulation on it :D

The following instructions show how to export your strategy results from TradingView to an Excel File, copy the data, and input it into the indicator.

However, you are not limited to following this method!

Wherever your strategy results are stored, simply copy and paste them into the indicator text area in the settings and simulations will begin.

Returns Should Follow This Format

1
3
-3
2
-5

The numbers are presented as a single column. No commas or separators used. 

The numbers above are in sequential order. A return of "1" for the first trade and a return of "-5" for the last trade. Your strategy returns will likely be in sequential order already so don't worry too much about this (:

How To Perform a Monte Carlo Simulation On Your TradingView Strategy With Excel Data

[*]Export your strategy returns to an excel file using TradingView
[*]Navigate to your downloads folder to column G "Profit"
[*]Click the column and press CTRL + SPACE to highlight the entire column
[*]Press CTRL + C to copy the entire column
[*]Open this indicator's settings and paste the returns into the text area

[image]https://www.tradingview.com/x/RLekTaFG/[/image]

The image above illustrates the process!

Notes on Inputting Returns

*Must input your returns without a separate as a vertical list
*The initial text area can only hold so many return values. If your list of trades is large you can input additional returns into two additional text areas at the bottom of the indicator settings.

That should be it; thank you for checking this out!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KioseffTrading

//@version=5
indicator("Monte Carlo Simulation [Kioseff Trading]", max_lines_count = 500, overlay = false, max_labels_count = 500, max_boxes_count = 500)

justPriceS = input.string   (defval = "Price",  title = "I Want To Simulate: ", options = ["Price" , "My Strategy"])
seed       = input.int      (defval = 0, title = "Set Seed", minval = 0)
distT      = input.string   (defval = "Normal", title = "Type", options = ["Normal", "Bootstrap"])
txt        = input.text_area(defval = "-3\n-2\n-1\n0\n1\n2\n3\n *If You Selected 'My Strategy'\n(Paste Your Returns Here Following This Format)", title ="Returns")
cumu       = input.float    (defval = 70, title = "Cumulative Probability Target", maxval = 99, minval = 5) / 100
lin        = input.bool     (defval = false,  title = "Line Plot Only")
lab        = input.bool     (defval = false,  title = "Represent With Circles")
hist       = input.bool     (defval = false,  title = "Probability Distribution Only")
binT       = input.string   (defval = "Rice", title = "Binning Method", options = ["Sturges", "Rice", "Square Root", "Custom"])
sims       = input.int      (defval = 250,    title = "Simulations", minval = 1)
forx       = input.int      (defval = 15,     title = "Forecast") + 1
only       = input.bool     (defval = false,  title = "Show Best Case / Worst Case Only")
back       = input.int      (defval = 200,    title = "Historical Data Points", minval = 5, group = "Simulate Price Instead", step = 10)
lineS      = input.string   (defval = "Solid", title = "Line Style", options= ["Solid", "Dotted", "Dashed"], group = "Line Style")

finS = switch lineS

    "Dotted" => line.style_dotted
    "Solid"  => line.style_solid
    "Dashed" => line.style_dashed

var ret    = array.new_float(), endPoints = array.new_float()

justPrice = justPriceS == "Price"

if lab 
    only := false
    hist := false

if hist 
    only := false
    lin  := false
    
binSize(size) =>  

    switch binT 
        
        "Square Root" => math.sqrt(size) 
        "Rice"        => 2 * (math.pow(size, 1./3))
        "Sturges"     => math.log(size) / math.log(2) + 1, 
        "Custom"      => input.int(20, title = "Custom Bin Amount (If Selected)", minval = 5, maxval = 200, group = "Custom Bin Amount")

txt2       = input.text_area(defval = "",     title = "Additional Returns")
txt3       = input.text_area(defval = "",     title = "Additional Returns")
txt4       = input.text_area(defval = "",     title = "Additional Returns")


Gauss(z, avg, std) => 
    
    avg + std * z

method boot(array <float> id) => 


    id.get(int(math.random(0, id.size(), seed)))

distribution() => 

    avg    = ret.avg(), std = ret.stdev(false), size = ret.size()
    r1     = math.random(0.01, 0.99, seed)
    r2     = math.random(0.01, 0.99, seed)  
    result = math.sqrt  (-2.0 * math.log(r1)) * math.cos(2.0 * math.pi * r2)

    switch distT

        "Normal"   => Gauss(result, avg, std)
        =>            ret.boot()


method num(float id, val) => 

    switch justPrice 

        false => id + val 
        =>       id * math.exp(val)

method dete (matrix <float> id, val, i, x, int col, matrix<color> id2, color val2) => 

    if not lab

        if i < id.rows()

            id.set (i, col, val)
            id2.set(i, col, val2)
    else 
        
        if x == forx - 1 and i < 1000

            id .set(i, 0, val)
            id2.set(i, 0, val2)

atr = ta.atr(14)

method mult(float id, up = 1.002, dn = .998) =>
    
    switch 

        justPrice           => id - atr
        math.sign(id) == -1 => id * up
        math.sign(id) == 1  => id * dn

if last_bar_index - bar_index <= back and justPrice 

    ret.push(math.log(close / close[1]))

method iSwitch(matrix <float> id, lastClos, i, x, colData, col, matrix <float> minMax) => 

    switch only

        false and not hist => id.dete(lastClos, i, x, x, colData, col) 
        
        =>       minMax.set(0, x, math.min(nz(minMax.get(0, x), 1e8 ), lastClos)), 
                 minMax.set(1, x, math.max(nz(minMax.get(1, x), -1e8), lastClos))


method endTrim (array <box> histBox, array<float> val, array<float> freq, array<label> histLabs) => 

    if freq.size() > 0 and val.size() == freq.size() and histLabs.size() == freq.size() and histBox.size() == freq.size()
        for i = 0 to freq.size() - 1
            switch val.get(i) == 9e9
                true => histBox.get(i).delete(), histLabs.get(i).delete()
                =>      break

        for i = freq.size() - 1 to 0
            switch val.get(i) == 9e9
                true => histBox.get(i).delete(), histLabs.get(i).delete()
                =>      break
// 

method returnCheck(array<float> id, array<string> id2) => 

    if id2.size() > 0 
        for i = 0 to id2.size() - 1
            if not na(str.tonumber(id2.get(i)))
                id.push(str.tonumber(id2.get(i)))

if barstate.islastconfirmedhistory 

    subs    = str.split(txt , "\n")
    subs1   = str.split(txt2, "\n")
    subs2   = str.split(txt3, "\n")
    subs3   = str.split(txt4, "\n")

    if not justPrice

        ret.returnCheck(subs ), ret.returnCheck(subs1),
        ret.returnCheck(subs2), ret.returnCheck(subs3)

    sum  = switch justPrice 

        false => ret.sum()
        =>       close

    [row, column] = switch lab 

        false => [math.floor(500 / forx), forx] 
        =>       [           1000, 1          ]
    

    lines    = array.new_line()
    minMax   = matrix.new<float>(2, forx + 1)
    lineData = matrix.new<float>(row, column)
    colData  = matrix.new<color>(row, column)

    res = 0.

    for i = 0 to sims

        col = color.rgb(math.random(0, 255), math.random(0, 255), math.random(0, 255))

        lastClose = sum

        if not lab
            lineData.dete(sum, i, 0, 0, colData, col)


        for x = 1 to forx - 1
 
            res       := distribution()
            lineData  .iSwitch(lastClose, i, x, colData, col, minMax)
            lastClose := lastClose.num(res)

        endPoints.push(lastClose.num(res))
        log.info(str.tostring(lastClose.num(res)))

    if not hist

        if only 

            minMax.set(0, 0, sum)
            minMax.set(1, 0, sum)

            for i = 1 to forx 

                line.new(bar_index + i - 1, minMax.get(0, i - 1), bar_index + i, minMax.get(0, i), color = color.red , style = finS)
                line.new(bar_index + i - 1, minMax.get(1, i - 1), bar_index + i, minMax.get(1, i), color = color.lime, style = finS)

        else 

            if not lab
                for x = 0 to lineData.rows() - 1
                    for i = 1 to lineData.columns() - 1

                        modulo = i % forx

                        line.new(bar_index + modulo - 1, lineData.get(x, i - 1), bar_index + modulo, lineData.get(x, i), 
                                         color = colData.get(x, i), 
                                         style = finS
                                         )
            else 

                for x = 0 to lineData.rows() - 1

                    random = int(math.random(1, 250, seed))

                    switch label.all.size() >= 500

                        false => label.new(bar_index + random, lineData.get(x, 0), color = colData.get(x, 0), 
                                             text      = "◉", 
                                             style     = label.style_text_outline, 
                                             size      = size.tiny, 
                                             textcolor = chart.fg_color
                                             )

                        true  => box.new  (bar_index + random, lineData.get(x, 0), bar_index + random, lineData.get(x, 0), 
                                             text_color = colData.get(x, 0), 
                                             text       = "◉", 
                                             text_size  = size.tiny
                                             )

        if not justPrice

            line.new  (bar_index - 1, ret.sum(), bar_index, ret.sum(), color = chart.fg_color, extend = extend.left)

            label.new (bar_index - 1, ret.sum(), text = str.tostring(ret.sum()), size = size.tiny, 

                                 style     = label.style_label_down, 
                                 color     = #00000000, 
                                 textcolor = color.white
                                 )

    min = 1e8, max = -1e8, xmax = int(-1e8)

    if not only and not hist


        endPoint = switch lab 

            false => line.all .size() - 1
            =>       label.all.size() - 1

        for i = 0 to endPoint


            switch lab

                false => min := math.min(line.all .get(i).get_y2(), min),
                         max := math.max(line.all .get(i).get_y2(), max)

                =>       min  := math.min(nz(label.all.get(i).get_y (),  1e8), min ),
                         max  := math.max(nz(label.all.get(i).get_y (), -1e8), max ), 
                         xmax := math.max(nz(label.all.get(i).get_x(), int(-1e8)), xmax)

        if lab

            if box.all.size() > 0 

                for i = 0 to box.all.size() - 1  

                    btm = box.all.get(i).get_bottom()
                    min  := math.min(min,  nz(btm,  1e8))
                    max  := math.max(max,  nz(btm, -1e8))
                    xmax := math.max(xmax, nz(box.all.get(i).get_right (), int(-1e8)))
    else 

        if not hist

            min := minMax.min()
            max := minMax.max()


    if not lab and not hist

        for i = 0 to forx - 1

            label.new(bar_index + i, min.mult(), str.tostring(i), style = label.style_label_up, color = #00000000, textcolor = chart.fg_color, size = size.tiny)


    if not hist

        [xcoor, txtt, xcoor2] = switch lab 

            false => [bar_index - 2, justPrice ? "Time #" : "Trade #", bar_index + forx + 1]
            =>       [bar_index - 4, "All Results For " + (justPrice ? "Time # " : "Trade # ") + str.tostring(forx - 1), xmax + 5]


        label.new(xcoor, min.mult(), text = txtt, color = #00000000, 
                             textcolor = chart.fg_color, 
                             size      = size.tiny, 
                             style     = label.style_label_up)

        line.new (bar_index - 3, min.mult(), xcoor2, min.mult(), color = chart.fg_color)
        line.new (xcoor2,        min.mult(), xcoor2, max.mult(), color = chart.fg_color)

        calc = (max.mult() - min.mult()) / 10

        for i = 0 to 10 

            label.new(xcoor2, min.mult() + (i * calc), str.tostring(min.mult() + (i * calc), format.mintick), 
                         textcolor = chart.fg_color, 
                         style     = label.style_label_left, 
                         size      = size.tiny, 
                         color     = #00000000
                         )


    if not only and not lin
 

        k = math.ceil(binSize(endPoints.size()))

        maxR  = endPoints.max()
        minR  = endPoints.min()

        freq  = array.new_float(k, hist ? 0 : sum) 
        count = array.new_float(k, 0)
        val   = array.new_float(k, 9e9)


        sizE = (maxR - minR) / k 
        

        for i = 0 to endPoints.size() - 1

            ind = math.floor((endPoints.get(i) - minR) / sizE) 

            if ind >= 0 and ind < k

                freq.set(ind, freq.get(ind) + 1)
                count.set(ind, count.get(ind) + 1)

                if endPoints.get(i) < val.get(ind)
                    val.set(ind, endPoints.get(i))

        newMin = 1e8, newMax = -1e8

        if not hist

            if not only

                for i = 0 to line.all.size() - 1

                    newMin := math.min(newMin, line.all.get(i).get_y2()) 
                    newMax := math.max(newMax, line.all.get(i).get_y2()) 

            else 
                newMin := minMax.min(), newMax := minMax.max()

        else 
            newMin := close * .975, newMax := close * 1.025

        if not lab 

            histLabs = array.new_label(), histBox = array.new_box()

            if not hist

                freqMin = freq.min(), freqMax = freq.max(), freqRange = freqMax - freqMin, minimum = 1e8

                for i = 0 to freq.size() - 1

                    freq.set(i, ((freq.get(i) - freqMin) / freqRange) * (newMax - newMin) + newMin)

                    if freq.get(i) != newMin 
                        minimum := math.min(minimum, freq.get(i))

                for i = 0 to freq.size() - 1 


                    pretext = switch justPrice 

                        true => str.tostring((val.get(i) - close) / close, "###.0000") + "\n" + str.tostring(count.get(i))
                        =>      str.tostring(val.get(i), format.mintick) + "\n" + str.tostring(count.get(i))


                    strtxt = switch val.get(i) == 9e9
                        true => "--" 
                        =>      pretext

                    histBox.push(box.new(bar_index   + forx + 6 + i, newMin, bar_index + forx + 6 + i + 1, math.max(freq.get(i), minimum), 
                                                 bgcolor = color.new(#6929F2, 50), 
                                                 border_color = chart.fg_color
                                                 ))

                    histLabs.push(label.new(bar_index + forx + 6 + i, newMin, "   " + strtxt, 
                                                 style     = label.style_label_up, 
                                                 color     = #00000000, 
                                                 textcolor = chart.fg_color, 
                                                 size      = size.tiny))

                    histBox.endTrim(val, freq, histLabs)

            else 

                for i = 0 to freq.size() - 1 

                    pretext = switch justPrice
                        
                        true => str.tostring((val.get(i) - close) / close, "###.0000") + "\n" + str.tostring(count.get(i))
                        =>      str.tostring(val.get(i), format.mintick) + "\n" + str.tostring(count.get(i))
                    
                    strtxt = switch val.get(i) == 9e9

                        true => "--" 
                        =>      pretext


                    histBox.push(box.new(bar_index - 20 + i , 0, bar_index - 20 + i + 1, math.max(freq.get(i), 0.2), 
                                     bgcolor      = color.new(#6929F2, 50), 
                                     border_color = chart.fg_color))



                    histLabs.push(label.new(bar_index - 20 + i, 0,
                          "   " + strtxt, 
                                         style     = label.style_label_up, 
                                         color     = #00000000, 
                                         textcolor = chart.fg_color, 
                                         size      = size.tiny
                                         ))

                    histBox.endTrim(val, freq, histLabs)


            [yloc1, yloc2] = switch hist
                
                false => [newMin, newMax]
                =>       [0, freq.max()]

            xloc  = box.all.last ().get_right() + 2
            xloc1 = box.all.first().get_left()

            line.new(xloc , yloc1, xloc, yloc2, color = chart.fg_color)
            line.new(xloc1, yloc1, xloc, yloc1, color = chart.fg_color)

            calc = ((count.max() / count.sum() * 100) - (count.min() / count.sum() * 100)) / 10
            calcy = (yloc2 - yloc1) / 10
            label.new(xloc1 - 1, yloc1, "Return\nCount", style = label.style_label_up, color = #00000000, textcolor = chart.fg_color, size = size.tiny)
            
            for i = 0 to 10 

                label.new(xloc, yloc1 + (calcy * i), text = str.tostring(count.min() + (calc * i), format.percent), 

                                 style     = label.style_label_left,
                                 color     = #00000000, 
                                 textcolor = chart.fg_color,
                                 size      = size.tiny
                                 )

            highest = count.indexof(count.max())

            if not lab and not lin

                for i = 1 to count.size() - 1
    
                    slice = count.slice(highest - i, highest + i + 1)
    
                    if slice.sum() / count.sum() >= cumu 
                    
                        for x = highest - i to highest + i
                            histBox.get(x).set_bgcolor(color.new(#6929F2, 50)) 
                        
                        label.new(
                                 math.round(
                                     math.avg(
                                         histBox.get(highest).get_left(), histBox.get(highest).get_right())), histBox.get(highest).get_bottom(), 
                                         text = "Cumulative Prob: " + str.tostring(slice.sum() / count.sum() * 100, format.percent), 
                                         color = #00000000, textcolor = #6929F2, size = size.tiny)
    
                        left  = histBox.get(highest - i)
                        right = histBox.get(highest + i)
                        top   = histBox.get(highest)
    
                        l = line.new(left.get_left(), top.get_top(), left.get_left(), top.get_bottom()    , color = #00000000)
                        r = line.new(right.get_right(), top.get_top(), right.get_right(), top.get_bottom(), color = #00000000)
                        linefill.new(l, r, color.new(chart.fg_color, 75))
    
                        break

floatna () => 

    [float(na), float(na), float(na), float(na), color(na)]

[o, h, l, c, color] = switch justPrice 

    false =>             floatna()
    true and not hist => [open, high, low, close, close > open ? color.aqua : color.red]
    =>                   floatna()
    
plotcandle(o, h, l, c, color = color, wickcolor = color, bordercolor = chart.fg_color, display = display.pane)

//
````
