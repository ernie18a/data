# Liquidity Walls [TradingIQ]

- url: https://www.tradingview.com/script/ntds0eKp-Liquidity-Walls-TradingIQ/
- type: indicator
- pine_id: PUB;72b6986757524c189d0501840e181954
- version: 1.0

## Description

Hello Traders!

🔹[b]Liquidity Walls [TradingIQ][/b]

Liquidity Walls is an [b]order-flow efficiency and absorption tool[/b] designed to highlight areas where aggressive buying or selling pressure fails to move price as expected.

Instead of only showing where price moved, this indicator asks a deeper question:

[i]Did the market respond properly to the pressure behind the move?[/i]

When strong delta enters the market but price does not travel efficiently, that can suggest [b]absorption, trapped aggression, or opposing liquidity[/b].

Liquidity Walls is built to identify those moments and project potential liquidity clusters directly onto the chart.

[list]
[*]lower timeframe delta analysis
[*]delta-implied price movement
[*]inefficient candle detection
[*]absorption-based liquidity zones
[*]adaptive expected close modeling
[*]active liquidity wall tracking
[*]automatic zone invalidation
[/list]

🔹[b]What the indicator shows[/b]

🔸[b]Delta-Based Expected Close[/b]

The indicator estimates where price [i]should have closed[/i] based on the relationship between delta and price movement.

It compares:

[list]
[*]actual price movement
[*]delta-driven expected movement
[*]how much price should have moved based on recent behavior
[/list]

This creates a [b]delta-implied close[/b], shown directly on the chart.

The core idea is simple:

[i]If aggressive buyers or sellers entered the market, price should usually respond.[/i]

When it does not, that mismatch can reveal hidden liquidity.

🔸[b]Inefficient Candle Detection[/b]

Candles are colored when the script detects inefficient movement between delta and price.

This means:

[list]
[*]delta was strong, but price response was weak
[*]price failed to move as much as expected
[*]aggressive pressure may have been absorbed
[*]the market may be interacting with a liquidity wall
[/list]

The stronger the inefficiency, the more aggressively the candle is highlighted.

This helps you quickly identify bars where:

[i]the effort was high, but the result was weak.[/i]

🔸[b]Absorption Logic[/b]

Liquidity Walls uses a regression-style model to estimate the expected price move from delta.

It calculates:

[list]
[*]lower timeframe signed volume
[*]net delta
[*]actual movement in ticks
[*]expected movement in ticks
[*]difference between expected and actual movement
[/list]

When the difference becomes statistically extreme, the indicator treats that candle as a potential absorption event.

In simple terms:

[b]Strong delta + weak price response = possible absorption.[/b]

🔸[b]Liquidity Wall Zones[/b]

When absorption is detected, the indicator creates a projected liquidity zone.

If buy-side aggression is absorbed, a zone is drawn above price.

If sell-side aggression is absorbed, a zone is drawn below price.

These zones represent areas where price may have interacted with significant opposing liquidity.

[list]
[*]absorbed buying can suggest overhead liquidity
[*]absorbed selling can suggest downside liquidity
[*]zones remain active until price invalidates them
[*]invalidated zones fade automatically
[/list]

This allows you to visually track areas where the market previously struggled to move through pressure.

🔸[b]Active Zone Tracking[/b]

Liquidity zones extend forward until price breaks through them.

When price clears a zone, the indicator:

[list]
[*]stops extending the box
[*]fades the visual appearance
[*]removes it from the active liquidity wall list
[/list]

This keeps the chart focused on currently relevant liquidity zones instead of cluttering the screen with old levels.

🔸[b]Granularity Selection[/b]

The indicator allows you to choose the lower timeframe source used for delta reconstruction.

Available granularity options include:

[list]
[*]1-Minute
[*]1-Second
[*]1-Tick
[/list]

Lower granularity can provide more detailed flow analysis when data is available.

[b]Important Note[/b]
[i]Lower timeframe accuracy depends on the symbol, exchange, TradingView plan, and available historical data. Tick and second-based data may not be available on all markets.[/i]

🔹[b]How the model works[/b]

The script looks at the relationship between:

[list]
[*]net delta
[*]price movement in ticks
[*]recent correlation between delta and price movement
[*]recent volatility of both delta and price movement
[/list]

From this, it estimates how far price should have moved based on the current delta.

Then it compares that expected move to the actual move.

If price dramatically underperforms relative to delta, the script marks the candle as inefficient and creates a potential liquidity wall.

🔹[b]How to read it[/b]

🔸[b]Highlighted candles[/b]

Highlighted candles suggest inefficient price movement.

This means aggressive flow entered the market, but price did not respond normally.

Possible interpretations:

[list]
[*]absorption
[*]hidden liquidity
[*]exhaustion
[*]trapped aggression
[*]failed continuation
[/list]

🔸[b]Liquidity walls above price[/b]

A zone above price can suggest that aggressive buying was absorbed.

This may indicate:

[list]
[*]overhead liquidity
[*]resistance from passive sellers
[*]buyers pushing into supply
[*]possible failed breakout conditions
[/list]

🔸[b]Liquidity walls below price[/b]

A zone below price can suggest that aggressive selling was absorbed.

This may indicate:

[list]
[*]downside liquidity
[*]support from passive buyers
[*]sellers pushing into demand
[*]possible failed breakdown conditions
[/list]

🔹[b]Example interpretations[/b]

[list]
[*]strong buy delta + weak upward movement → buying may be absorbed
[*]strong sell delta + weak downward movement → selling may be absorbed
[*]price returns to a liquidity wall → possible reaction area
[*]price breaks through a wall → zone is invalidated
[*]multiple inefficient candles near the same level → potential liquidity cluster
[/list]

🔹[b]Why this indicator is useful[/b]

Liquidity Walls helps shift your analysis from:

[i]“price moved here”[/i]

to:

[i]“how did price respond to the pressure behind the move?”[/i]

This is useful because not all movement is equal.

Sometimes large aggressive volume creates a clean directional move.

Other times, large aggressive volume gets absorbed and price barely moves.

This indicator is designed to highlight those moments.

🔹[b]Best use cases[/b]

[list]
[*]spotting absorption near highs and lows
[*]identifying weak breakouts
[*]tracking potential liquidity clusters
[*]finding areas where aggressive traders may be trapped
[*]confirming failed continuation attempts
[*]adding order-flow context to price action
[*]analyzing reaction zones around key levels
[/list]

🔹[b]Inputs you can customize[/b]

[list]
[*]Granularity
[*]Inefficient candle coloring
[*]Liquidity cluster color
[/list]

🔸[b]Granularity[/b]

Controls which lower timeframe data is used to estimate signed volume and delta behavior.

🔸[b]Show Inefficient Candles[/b]

Turns candle coloring on or off.

When enabled, candles are colored based on the strength of the inefficiency signal.

🔸[b]Liquidity Cluster Color[/b]

Controls the color used for liquidity walls, inefficient candles, and projected absorption zones.

🔹[b]Important Notes[/b]

This script uses lower timeframe data to approximate aggressive buying and selling activity.

This means:

[list]
[*]accuracy depends on available lower timeframe data
[*]results may vary between markets
[*]tick and second data may not be available everywhere
[*]the model is interpretive, not predictive
[*]zones should be used as context, not standalone signals
[/list]

Liquidity Walls does not predict the future.

It identifies areas where recent order-flow pressure did not produce the expected price response.

That information can help traders better understand where liquidity may be absorbing movement.

🔹[b]Closing Notes[/b]

Liquidity Walls is built to visualize the relationship between [b]aggression, efficiency, and absorption[/b].

It helps reveal when the market is moving cleanly — and when price is struggling against hidden liquidity.

As always, thank you TradingView!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradingIQ 

//@version=6
indicator("Liquidity Walls [TradingIQ]", overlay = true)
// 
enum granularity

    m5 = "5-Minute"
    m1 = "1-Minute"  
    s1 = "1-Second"  
    t1 = "1-Tick"  

gran                = input.enum(defval = granularity.m1, title = "Granularity", options = [granularity.m5, granularity.m1, granularity.s1, granularity.t1])
showBGcandles       = input.bool(defval = true, title = "Show Inefficient Candles (Candle Coloring)")
zoneCol             = input.color(defval = #ffcf55, title = "Liquidity Cluster Color")
var tf = switch gran

    granularity.m1  => "1"
    granularity.s1  => "1S"
    granularity.t1  => "1T"


direction() => 

    if gran == granularity.t1

        switch 

            close == bid => -1 
            close == ask =>  1
            =>               math.sign(close - close[1]) 
        
    else 

        math.sign(close - close[1])


z(val) => 

    (val - ta.sma(val, 100)) / ta.stdev(val, 100)

delta() => 
        

    [signedVol, price] = request.security_lower_tf("", tf, [volume * direction(), close])

    delta     = signedVol.sum() 
    moveTicks = (close - open) / syminfo.mintick

    beta  = nz(ta.correlation(delta, moveTicks, 100)[1] * (ta.stdev(moveTicks, 100)[1] / ta.stdev(delta, 100)[1]))
    alpha = nz(ta.sma(moveTicks, 100)[1] - beta * ta.sma(delta, 100)[1])

    expectedTicks = alpha + beta * delta
    expectedClose = open + expectedTicks * syminfo.mintick

    failTicks = math.sign(expectedTicks) * (expectedTicks - moveTicks)

    [z(failTicks), expectedTicks, delta, expectedClose]


[z, e, d, ec] = delta()

plotcandle(ec, ec, ec, ec, color = zoneCol, wickcolor = zoneCol, bordercolor = zoneCol)

method updatePivot(array<chart.point> id, bool isContinuation, float pricePoint) => 

    getRec = id.first(), getP = id.last()

    switch isContinuation

        true => id.set(1, chart.point.from_time(getRec.time, getP.price))  , id.set(0, chart.point.from_time(time, pricePoint))
        =>      id.set(1, chart.point.from_time(getRec.time, getRec.price)), id.set(0, chart.point.from_time(time, pricePoint))

    id.first()

IQZZ(float atrMult) =>
    
    atr          = ta.atr(14) * atrMult
    var points   = array.from(chart.point.from_time(time, close), chart.point.from_time(time, close))
    pointPrev    = points.last(), pointP2      = pointPrev[1]
    
    var pointArr = array.new<float>()
    var timeArr  = array.new<int>  ()
    var dir      = 0

    getRec = points.first()

    if dir == 1

        price = math.max(getRec.price, high)

        if price == high 
            getRec := points.updatePivot(true, high)
            
        if low <= getRec.price - atr  and high != getRec.price

            dir   := -1 
            points.updatePivot(false, low)

    else if dir == -1

        price = math.min(low, getRec.price)

        if price == low 
            getRec := points.updatePivot(true, low)

        if high >= getRec.price + atr and low != getRec.price

            dir   := 1
            points.updatePivot(false, high)

    if dir == 0 

        if high >= getRec.price + atr 

            dir   := 1
            points.updatePivot(false, high)

        else if low <= getRec.price - atr

            dir   := -1 
            points.updatePivot(false, low)

    if not na(pointP2)
        if pointP2.price != pointPrev.price
        
            pointArr.push(pointPrev.price)
            timeArr .push(pointPrev.time)
    
    [dir, pointArr, timeArr]
    
[marketState, pointArr, timeArr] = IQZZ(2)


col = color.from_gradient(z, 0, 2, color.gray, zoneCol)

plotcandle(showBGcandles ? open : na, high, low, close, color = col, wickcolor = col, bordercolor = col)
barcolor(showBGcandles? col : na)

absorbSide = math.sign(e)

atr = ta.atr(14)

var liqBoxes = array.new<box>()

method boxAddDel(array<box> id) => 
        
    size = id.size() 

    if size > 0 

        for i = size - 1 to 0 

            getZone = id.get(i)

            top = getZone.get_top(), bot = getZone.get_bottom()

            if top > bot 
                if high > top 

                    getZone.set_extend(extend.none)
                    getZone.set_right (time)
                    getZone.set_border_color(color.new(zoneCol, 75))
                    getZone.set_bgcolor(color.new(zoneCol, 90))

                    id.remove(i)//.delete()
            else 
                if low < top 

                    getZone.set_extend(extend.none)
                    getZone.set_right (time)
                    getZone.set_border_color(color.new(zoneCol, 75))
                    getZone.set_bgcolor(color.new(zoneCol, 90))

                    id.remove(i)//.delete()

    if z >= 2 

        switch absorbSide

            1  => id.push(box.new(time, high + atr, time("", -1), high, border_color = color.new(zoneCol, 75), bgcolor = color.new(zoneCol, 80), extend = extend.right, xloc = xloc.bar_time))
            -1 => id.push(box.new(time, low - atr , time("", -1), low , border_color = color.new(zoneCol, 75), bgcolor = color.new(zoneCol, 80), extend = extend.right, xloc = xloc.bar_time))

    if barstate.islast 

        var liqLines = array.new<line>()

        size := liqLines.size() 

        if size > 0 
            for i = size - 1 to 0 
                liqLines.shift().delete()

        activeZones = id.size()
            
        var transpArr = array.from(65, 35, 0, 65, 35)

        max = 0., min = 10e10

        for zones in id 

            top = zones.get_top(), bot = zones.get_bottom()

            switch top > bot 

                true => zones.set_top(bot + atr)
                =>      zones.set_top(bot - atr)

            top := zones.get_top(), bot := zones.get_bottom()

            trueBot = math.min(top, bot), trueTop = math.max(top, bot)
            Range   = math.abs(math.max(top, bot) - trueBot) / 4

            min := math.min(nz(trueBot, 10e10), min)
            max := math.max(nz(trueTop), max)

            // zones.set_border_color(#00000000)

            // for i = 0 to 4 

            //     y = trueBot + Range * i

            //     liqLines.push(line.new(zones.get_left(), y, time, y, extend = extend.right, color = color.new(zoneCol, transpArr.get(i)), xloc = xloc.bar_time))

            //     if i == 2 
                
            //         liqLines.push(line.new(zones.get_left(), y, time, y, extend = extend.right, color = color.new(zoneCol, 80), width = 5, xloc = xloc.bar_time))



    

liqBoxes.boxAddDel()
````
