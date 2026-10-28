# Large Order Delta Profile [TradingIQ]

- url: https://www.tradingview.com/script/kaJmAN96-Large-Order-Delta-Profile-TradingIQ/
- type: indicator
- pine_id: PUB;edcd8be76b734e6190c26194ef2cbbbd
- version: 1.0

## Description

Hello Traders!

🔹[*b]Large Order Delta Profile[/b]

Large Order Delta Profile is an order-flow visualization tool designed to split delta profiles across different transaction-size categories.

That is the core idea behind the tool: instead of showing one combined volume or delta profile, it separates activity by customizable dollar-value thresholds so you can compare how smaller, medium-sized, and very large transactions behaved during the same session.

This helps traders visualize [*b]where different sizes of market participants were active, where aggressive buying or selling concentrated, and whether large-order flow agreed or disagreed with smaller transaction flow[/b].

[list]
[*]splits the delta profile across multiple transaction-size ranges
[*]compares smaller, medium, and large-order activity side by side
[*]tracks bullish and bearish delta at price levels
[*]filters trades using customizable dollar-value thresholds
[*]supports tick, second, and minute-based granularity
[*]builds session-based delta profiles
[/list]

🔹[*b]What the tool shows[/b]

[image]https://www.tradingview.com/x/zScOOcGx/[/image]

🔸[*b]Transaction-size delta profiles[/b]

The main feature of this indicator is that it separates market activity into different transaction-size profiles.

Each profile represents a different dollar-value range of transactions, allowing you to compare:

[list]
[*]smaller transaction flow
[*]medium-sized transaction flow
[*]large-order activity
[*]extreme large-order activity
[/list]

This makes it easier to see whether large participants were active at the same price levels as smaller participants, or whether larger transactions were concentrated in completely different areas.

🔸[*b]Large order delta distribution[/b]

The script builds a profile showing where aggressive buying and selling activity occurred during the active session.

Instead of displaying simple volume-at-price, it separates:

[list]
[*]bullish delta
[*]bearish delta
[*]net directional pressure
[/list]

This helps identify where buyers or sellers were more aggressive across each transaction-size category.

🔸[*b]Custom dollar-value filters[/b]

The indicator allows you to define multiple transaction-size filters using estimated dollar value.

Each filter creates its own profile, so you can compare activity such as:

[list]
[*]all qualifying transactions
[*]transactions above a larger threshold
[*]transactions above an extreme threshold
[/list]

This is useful because not all market activity carries the same context.

A small transaction imbalance and a large transaction imbalance can tell very different stories.

🔸[*b]Delta-based directional analysis[/b]

The profile uses directional estimation to classify activity as bullish or bearish.

Depending on your selected granularity:

[list]
[*]tick-based bid/ask estimation can be used
[*]lower-timeframe candle direction can be used
[*]aggressive buying and selling pressure is separated
[/list]

Positive delta suggests stronger aggressive buying.

Negative delta suggests stronger aggressive selling.

This helps reveal where different transaction-size groups were actively lifting offers or hitting bids.

🔸[*b]Session-based profiling[/b]

The indicator resets and rebuilds based on a customizable session period.

This allows profiles to adapt dynamically to:

[list]
[*]daily sessions
[*]custom session structures
[*]intraday profiling
[*]higher-timeframe segmentation
[/list]

The profile continuously expands as price moves beyond existing ranges.

🔸[*b]Adaptive profile levels[/b]

The script uses ATR-based level spacing to dynamically build profile rows.

This allows the profile structure to adapt to:

[list]
[*]high-volatility conditions
[*]low-volatility conditions
[*]tight ranges
[*]expanding markets
[/list]

Instead of relying on static tick spacing, the levels automatically scale with market volatility.

🔸[*b]Visual imbalance mapping[/b]

Profile blocks expand horizontally based on the strength of bullish or bearish delta.

This creates a quick visual representation of:

[list]
[*]where aggressive buyers dominated
[*]where aggressive sellers dominated
[*]which price levels showed the strongest imbalance
[*]where directional pressure was concentrated
[*]how imbalance differed across transaction-size groups
[/list]

Bullish pressure is displayed using bullish profile coloring.

Bearish pressure is displayed using bearish profile coloring.

Optional delta labels can also display the raw imbalance values directly on the chart.

🔹[*b]How to read it[/b]

Each component gives a different layer of order-flow context:

Transaction-size profile → which order-size group is being shown  
Bullish delta → aggressive buying pressure  
Bearish delta → aggressive selling pressure  
Large profile expansion → stronger directional imbalance  
Thin profile areas → weaker participation  
Filter ranges → separated transaction-size categories  
Session profile → where activity concentrated during the session  

🔹[*b]Why this tool is useful[/b]

It gives you:

[list]
[*]a way to compare delta across different transaction sizes
[*]a visual map of where larger orders were active
[*]separate profiles for smaller, medium, and larger transaction flow
[*]context around whether large-order activity confirms or conflicts with smaller flow
[*]session-based order-flow structure
[*]a clearer view of where aggressive participation concentrated
[/list]

🔹[*b]Best use cases[/b]

[list]
[*]comparing small vs large transaction behavior
[*]tracking where large participants were most active
[*]studying aggressive buying and selling by transaction size
[*]analyzing directional imbalance across multiple order-size groups
[*]identifying high-participation price zones
[*]building session-based order-flow context
[/list]

🔹[*b]Important note[/b]

This tool estimates directional pressure using lower-timeframe or tick-based data.

That means:

[list]
[*]delta estimation is not identical to centralized exchange order books
[*]transaction-size filters are based on estimated dollar value
[*]large imbalance does not guarantee continuation
[*]profiles represent historical participation, not future certainty
[*]market conditions can shift quickly
[*]outputs should be used as contextual analysis, not standalone signals
[/list]

🔹[*b]Inputs you can customize[/b]

The script includes flexible controls such as:

[list]
[*]data granularity selection
[*]session timeframe selection
[*]profile level granularity
[*]multiple dollar-value transaction filters
[*]profile offsets
[*]bullish and bearish profile colors
[*]delta label visibility
[*]delta label sizing
[/list]

[*b]Closing Notes[/b]

Large Order Delta Profile is built around one central idea: [*b]not all transaction sizes should be viewed the same way[/b].

By splitting delta profiles across different dollar-value thresholds, the tool helps traders compare how smaller flow, larger flow, and extreme transaction activity behave during the same session.

Rather than asking only where volume occurred, this tool helps ask [*b]which size of activity created the imbalance, where it happened, and whether larger transaction flow told a different story from the broader market[/b].

Thank you for checking it out!

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KioseffTrading

//@version=6
indicator("Large Order Delta Profile [TradingIQ]", overlay = true, max_labels_count = 500, max_boxes_count = 500, max_lines_count = 500, max_polylines_count = 100)

useSeconds = input.string(defval = "1-Minute", title = "Data Granularity", options = ["1-Tick", "1-Second", "1-Minute"])
session    = input.timeframe("1D", title = "Session")
multiplier   = input.float(defval = 2.5, step = 0.1, minval = 0.1, title = "Level Granularity (Lower = More Levels)")
filterValue1 = input.float(defval = 0, minval = 0, step = 100, title = "Filter Value (Dollars)", tooltip = "Set a dollar value volume filter for small trades. The number selected will require the dollar amount for trades added to the profile to be greater than this value.", inline = "1"), offset1      = input.int(defval = 35 , inline = "1", title = "Offset")
filterValue2 = input.float(defval = 1000000, minval = 0, step = 100, title = "Filter Value (Dollars)", tooltip = "Set a dollar value volume filter for small trades. The number selected will require the dollar amount for trades added to the profile to be greater than this value.", inline = "2"), offset2      = input.int(defval = 95 , inline = "2", title = "Offset")
filterValue3 = input.float(defval = 10000000, minval = 0, step = 100, title = "Filter Value (Dollars)", tooltip = "Set a dollar value volume filter for small trades. The number selected will require the dollar amount for trades added to the profile to be greater than this value.", inline = "3"), offset3      = input.int(defval = 155, inline = "3", title = "Offset")
bullCol = input.color(defval = #00ffff, title = "Bull Color") 
bearCol = input.color(defval = #8f1b1b, title = "Bear Color")
showDelta = input.bool(defval = false, title = "Show Delta", inline = "Delta"), deltaLabSize = input.string(defval = "Small", title = "", options = ["Tiny", "Small", "Normal"], inline = "Delta")
var getTF = switch useSeconds

    "1-Minute" => "1"
    "1-Second" => "1S"
    =>            "1T"

[oneLTFclose, oneLTFvol, oneLTFcloseP, oneLTFopen, oneLTFhigh, oneLTFlow, oneLTFbid, oneLTFask, oneLTFdir] = request.security_lower_tf(syminfo.tickerid, getTF, [close, volume, close[1], open, high, low, bid, ask, math.sign(close - open)])

var values = array.from(filterValue1, filterValue2, filterValue3)

if barstate.isfirst
    values.sort(order.ascending)

atr = ta.atr(14) / 10

type barData 

    float o
    float h 
    float l 
    float c

getVP(int offsetVP, filterValue) => 
            
    var levels = array.new<float>()
    var volAtLevelBull = array.new<float>()
    var volAtLevelBear = array.new<float>()
    var sumVol         = array.new<float>()
    var trueAtr = float(na)
    var getIndexVal = values.indexof(filterValue)
    var getStart = values.get(getIndexVal)

    var getEnd = switch getIndexVal

        2 => 20e20 
        =>   values.get(getIndexVal + 1)

    var sessLine = line.new(bar_index, high, bar_index, low, color = #00000000, width = 2, extend = extend.both)
    
    var finLine = line(na)
    
    var sessionBar = barData.new(open, high, low, close)

    if barstate.islast 
        finLine.delete()
        finLine := line.new(bar_index, high, bar_index, low, color = #00000000, extend = extend.both)
        linefill.new(finLine, sessLine, color = color.new(chart.fg_color, 97))

    if timeframe.change(session) 
        trueAtr := atr * multiplier

        sessionBar.o := open 
        sessionBar.c := close 
        sessionBar.h := high 
        sessionBar.l := low

        sessLine.set_xy1(bar_index, high)
        sessLine.set_xy2(bar_index, low)

        levels := array.from(open - trueAtr, open, open + trueAtr)
        volAtLevelBull := array.from(0, 0, 0)
        volAtLevelBear := array.from(0, 0, 0)
        sumVol         := array.from(0, 0, 0)

    sessionBar.h := math.max(sessionBar.h, high)
    sessionBar.l := math.min(sessionBar.l, low)
    sessionBar.c := close

    if levels.size() > 0

        while high >= levels.last()

            levels.push(levels.last() + trueAtr)
            volAtLevelBull.push(0)
            volAtLevelBear.push(0)
            sumVol        .push(0)

        while low <= levels.first()

            levels.unshift(levels.first() - trueAtr)
            volAtLevelBull.unshift(0)
            volAtLevelBear.unshift(0)
            sumVol        .unshift(0)


        if getTF != "1T"

            if oneLTFvol.size() > 0

                for i = 0 to oneLTFvol.size() - 1

                    filterValueMult = switch syminfo.volumetype

                        "quote" =>  oneLTFvol.get(i)
                        =>         (oneLTFvol.get(i)) * oneLTFclose.get(i)

                    if filterValueMult > filterValue and filterValueMult < getEnd

                        difference = filterValueMult * oneLTFdir.get(i)

                        bot  = levels.binary_search_leftmost(oneLTFlow.get(i))
                        top  = levels.binary_search_leftmost(oneLTFhigh.get(i))

                        div = filterValueMult / (math.abs(top - bot) + 1)

                        for x = bot to top 

                            switch math.sign(difference)

                                1  => volAtLevelBull.set(x, nz(volAtLevelBull.get(x)) + div)
                                -1 => volAtLevelBear.set(x, nz(volAtLevelBear.get(x)) + div)

                            sumVol.set(x, nz(sumVol.get(x)) + filterValueMult)

        else if getTF == "1T"

            if oneLTFvol.size() > 0

                for i = 0 to oneLTFvol.size() - 1

                    filterValueMult = switch syminfo.volumetype

                        "quote" =>  oneLTFvol.get(i)
                        =>         (oneLTFvol.get(i)) * oneLTFclose.get(i)

                    if filterValueMult > filterValue and filterValueMult < getEnd

                        getClose = oneLTFclose.get(i), getBid = oneLTFbid.get(i), getAsk = oneLTFask.get(i), getCloseP = oneLTFcloseP.get(i)

                        direction = switch 

                            getClose <= getBid   => -1 
                            getClose >= getAsk   => 1
                            getClose > getCloseP => 1
                            getClose < getCloseP => -1
                            => 0

                        difference = filterValueMult * direction

                        getIndex = levels.binary_search_leftmost(getClose)

                        switch math.sign(difference)

                            1  => volAtLevelBull.set(getIndex, nz(volAtLevelBull.get(getIndex)) + filterValueMult)
                            -1 => volAtLevelBear.set(getIndex, nz(volAtLevelBear.get(getIndex)) + filterValueMult)

                        sumVol.set(getIndex, nz(sumVol.get(getIndex)) + filterValueMult)


    if barstate.islast

        var boxes = array.new<box>()
        var rangeLab  = label(na)
        var wicks = array.new<line>()
        var deltaLabs = array.new<label>()


        rangeLab.delete()

        size = boxes.size()

        if boxes.size() > 0 
            for i = 0 to size - 1
                boxes.shift().delete()

        size := wicks.size()

        if size > 0 
            for i = 0 to size - 1
                wicks.shift().delete()

        size := deltaLabs.size()

        if size > 0 
            for i = 0 to size - 1
                deltaLabs.shift().delete()

        if levels.size() > 0

            deltaArr = array.new<float>(volAtLevelBull.size())

            for i = 0 to volAtLevelBull.size() - 1
                deltaArr.set(i, volAtLevelBull.get(i) - volAtLevelBear.get(i))

            max = math.max(deltaArr.max(), deltaArr.min() * -1)
            min = 0


            for i = 0 to levels.size() - 1

                getDelta = deltaArr.get(i)

                norm = ((math.abs(getDelta) - min) / (max)) * (20)

                dir = math.sign(getDelta)

                offset = math.max(-20, math.round(norm * dir)) 
                offset := nz(math.min(offset, 20))

                col = switch dir 

                    1 => bullCol
                    =>   bearCol

                add = math.round(7 * math.sign(offset))

                getLevel = levels.get(i)

                if norm != 0 and offset != 0

                    boxes.push(box.new(bar_index + offsetVP + offset + add, getLevel, bar_index + offsetVP + add, getLevel + trueAtr, border_color = chart.bg_color, border_width = 2, bgcolor = color.new(col, 30)))
                    
                    if showDelta
                        deltaLabs.push(label.new(bar_index + offsetVP, getLevel, text = str.tostring(getDelta, format.volume), textcolor = chart.fg_color, size = size.small, color = #00000000))


            col = switch math.sign(sessionBar.c - sessionBar.o)

                1 => #00ffff 
                =>   #8f1b1b

            top = math.max(sessionBar.o, sessionBar.c)
            bot = math.min(sessionBar.o, sessionBar.c)

            transp = switch showDelta

                true => 50 
                =>      0

            boxes.push(box.new(bar_index - 7 + offsetVP, top, bar_index + 7 + offsetVP, bot, bgcolor = color.new(col, transp), border_color = chart.bg_color, border_width = 2))
            wicks.push(line.new(bar_index + offsetVP, sessionBar.h, bar_index + offsetVP, top, color = col))
            wicks.push(line.new(bar_index + offsetVP, bot, bar_index + offsetVP, sessionBar.l, color = col))

        txt = switch getEnd 

            20e20 => str.tostring(getStart, format.volume) + "+\n" + str.tostring(sumVol.sum(), format.volume) 
            =>       str.tostring(getStart, format.volume) + " - " + str.tostring(getEnd, format.volume)  + "\n" + str.tostring(sumVol.sum(), format.volume) 

        rangeLab := label.new(bar_index + offsetVP, levels.last(), text = txt, color = #00000000, textcolor = chart.fg_color, size = size.large)

getVP(offset1, filterValue1)
getVP(offset2, filterValue2)
getVP(offset3, filterValue3)
````
