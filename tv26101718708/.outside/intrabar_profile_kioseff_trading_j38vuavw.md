# Intrabar Profile [Kioseff Trading]

- url: https://www.tradingview.com/script/j38vuAvW-Intrabar-Profile-Kioseff-Trading/
- type: indicator
- pine_id: PUB;f8b6df85e8cc440f84c04efb527f12fe
- version: 1.0

## Description

Hello Traders!

🔹[b]Intrabar Profile [Kioseff Trading][/b]

Intrabar Profile is a [b]lower-timeframe profile tool[/b] designed to draw a volume profile or delta profile on [b]each individual candle[/b].

Instead of only looking at where a candle opened, closed, wicked, or changed color, this indicator attempts to show:

[i]Where did volume actually trade inside the bar?[/i]

It focuses on answering a deeper question:

[b]What happened inside the candle that normal candlesticks do not show?[/b]

[list]
[*]volume profile on every visible bar
[*]delta profile on every visible bar
[*]lower-timeframe volume distribution
[*]POC detection per candle
[*]value area visualization
[*]buy-side vs sell-side imbalance display
[*]optional volume-at-level labels
[*]adaptive scaling as the chart zooms in or out
[/list]


🔹[b]What the indicator shows[/b]

🔸[b]Intrabar Volume Profile[/b]

The indicator reconstructs a mini volume profile for each candle using lower timeframe data.

This allows you to see:

[list]
[*]where volume was concentrated inside each bar
[*]which price level had the highest volume
[*]how volume was distributed across the candle range
[*]whether volume was balanced or concentrated near specific levels
[/list]

This shifts your perspective from:

[i]“this candle closed bullish or bearish”[/i]

to:

[i]“where did participation actually take place inside this candle?”[/i]


🔸[b]POC Per Candle[/b]

Each intrabar profile includes a [b]Point of Control[/b], or POC.

The POC marks the price level inside the candle where the highest amount of volume was detected.

This helps identify:

[list]
[*]where the most trading activity occurred inside the bar
[*]whether volume was concentrated near the high, low, or middle of the candle
[*]potential areas of intrabar acceptance or rejection
[*]where participation clustered before price moved away
[/list]


🔸[b]Value Area Per Candle[/b]

The indicator can also display a value area for each profile.

The value area is calculated from total volume and highlights the region where the majority of volume occurred inside the bar.

This helps separate:

[list]
[*]high-participation areas
[*]lower-participation areas
[*]balanced candles
[*]thin or inefficient areas of the candle
[/list]

Together, the POC and value area help show the internal structure of each candle instead of only the candle body and wick.


🔸[b]Intrabar Delta Profile[/b]

Intrabar Profile can also switch from standard volume profile mode to [b]delta profile mode[/b].

Delta mode estimates buy-side and sell-side pressure using lower timeframe price movement and volume.

This allows you to see:

[list]
[*]where positive delta appeared inside the candle
[*]where negative delta appeared inside the candle
[*]whether aggressive activity was concentrated at the top, middle, or bottom of the bar
[*]when total volume and directional pressure tell different stories
[/list]

This can help answer:

[b]Was volume only present, or was it meaningfully skewed toward buyers or sellers?[/b]


🔸[b]Volume Profile vs Delta Profile[/b]

The indicator includes two profile modes:

[list]
[*][b]VP[/b] - displays total volume distribution inside each candle
[*][b]Delta[/b] - displays directional volume imbalance inside each candle
[/list]

Volume profile mode focuses on:

[list]
[*]where participation occurred
[*]where volume was concentrated
[*]where the candle’s POC and value area formed
[/list]

Delta profile mode focuses on:

[list]
[*]which side had more pressure
[*]where buy-side or sell-side imbalance appeared
[*]whether pressure was distributed evenly or concentrated at specific levels
[/list]


🔸[b]Adaptive Mini Profiles[/b]

The profiles are drawn directly on top of the chart candles and are designed to stay proportional as the chart is adjusted.

This means the visual structure adapts as you:

[list]
[*]zoom in
[*]zoom out
[*]stretch the chart
[*]compress the chart
[/list]

The goal is to keep the profile readable without turning the chart into visual clutter.


🔹[b]Granularity Options[/b]

The indicator uses lower timeframe data to build each intrabar profile.

Available granularity options include:

[list]
[*]5-minute
[*]1-minute
[*]1-second
[*]1-tick
[/list]

Lower granularity can provide a more detailed reconstruction of intrabar activity, depending on the symbol and data available from TradingView.

[b]Important Note[/b]

[i]Some lower timeframe data options may require specific TradingView data access or plan availability. If a selected granularity is not available on your chart or account, the indicator can only work with the data TradingView provides.[/i]


🔹[b]How to read it[/b]

Each candle can be read as its own mini profile.

[list]
[*]larger profile rows show more volume or stronger absolute delta
[*]the POC marks the highest-volume level inside the candle
[*]the value area highlights the primary participation zone
[*]gray areas show volume outside the selected value area
[*]positive delta shows stronger buy-side pressure
[*]negative delta shows stronger sell-side pressure
[/list]

This helps you compare:

[list]
[*]where the candle closed
[*]where the most volume traded
[*]where delta was strongest
[*]whether the candle’s appearance matches its internal activity
[/list]


🔹[b]Example interpretations[/b]

[list]
[*]bullish candle + volume concentrated near the high → possible acceptance higher
[*]bullish candle + heavy volume near the low → possible absorption or delayed response
[*]bearish candle + negative delta near the low → aggressive selling into the bottom of the bar
[*]large candle + thin profile → fast movement with less balanced participation
[*]small candle + heavy profile → high activity with limited price movement
[*]strong delta but weak candle movement → potential absorption or opposition
[/list]


🔹[b]Why this indicator is useful[/b]

Intrabar Profile gives you a way to look beyond standard candles.

It helps you see:

[list]
[*]where volume formed inside each candle
[*]where the candle’s POC developed
[*]whether participation was concentrated or spread out
[*]whether buyers or sellers dominated specific levels
[*]how volume and delta behaved inside the bar
[*]whether the candle’s structure supports or contradicts the price action
[/list]

Instead of only asking:

[i]“Did this candle close green or red?”[/i]

you can ask:

[i]“Where did the trading actually happen inside this candle?”[/i]


🔹[b]Best use cases[/b]

[list]
[*]studying intrabar volume structure
[*]analyzing candle quality
[*]identifying high-volume zones inside individual bars
[*]spotting possible absorption or imbalance
[*]comparing price action against internal volume distribution
[*]enhancing volume profile, order flow, or liquidity-based analysis
[/list]


🔹[b]Inputs you can customize[/b]

[list]
[*]profile type: VP or Delta
[*]granularity: 5-minute, 1-minute, 1-second, or 1-tick
[*]number of profile rows
[*]buy-side and sell-side colors
[*]POC color
[*]mini profile transparency
[*]value area visibility
[*]volume-at-level labels
[/list]


🔹[b]Important note[/b]

This script uses lower timeframe data to approximate intrabar volume and delta structure.

This means:

[list]
[*]accuracy depends on available lower timeframe data
[*]different symbols may behave differently
[*]1-second or tick data may not be available for every user or market
[*]delta is estimated from lower timeframe price movement and volume
[*]this is an analytical visualization tool, not a predictive engine
[/list]


[b]Closing Notes[/b]

Intrabar Profile is built to show the [b]internal volume structure of each candle[/b].

It helps turn a normal candlestick chart into a more detailed profile-based view of participation, imbalance, and intrabar activity.

As always, thank you TradingView!

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © KioseffTrading

//@version=6
indicator("Intrabar Profile [Kioseff Trading]", overlay = true, max_boxes_count = 500, max_labels_count = 500, max_lines_count = 500, max_polylines_count = 100, calc_bars_count = 500)


enum granularity

    m5 = "5-Minute"
    m1 = "1-Minute"  
    s1 = "1-Second"  
    t1 = "1-Tick"  

profType            = input.string(defval = "VP", title = "Profile Type", options = ["VP", "Delta"])
gran                = input.enum(defval = granularity.m1, title = "Granularity", options = [granularity.m5, granularity.m1, granularity.s1, granularity.t1])
upColAdv2           = input.color(defval = #96d3c8, title = "Buy-Side Color", inline = "ADV UP", group = "Focus Mode"), upColAdv = input.color(defval = #00ffff, title = "", inline = "ADV UP", group = "Focus Mode")
dnColAdv2           = input.color(defval = #d39696, title = "Sell-Side Color", inline = "ADV DN", group = "Focus Mode"), dnColAdv = input.color(defval = #8f1b1b, title = "", inline = "ADV DN", group = "Focus Mode")
advCol              = input.color(defval = color.white, title = "Text Color", group = "Focus Mode")
rows                = input.int(defval = 11, minval = 5, maxval = 200, title = "Profile Rows")

showVolAtLevel     = input.bool(defval = false, title = "Show Volume At Level", group = "Mini Profile Main Settings")
miniProfTransp     = input.int(0, minval = 0, maxval = 100, title = "Mini Profile Transparency", group = "All Profile Settings")
showVA          = input.bool(defval = true, title = "Show VA", group = "VA")
customPOCcol    = input.bool(defval = true, title = "", inline = "POC")
pocCol          = input.color(defval = #e5ff55, title = "POC Color", inline = "POC")

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

everyBarVP() => 

    [h, l, vol] = request.security_lower_tf("", tf, [high, low, volume * direction()])

    if vol.size() > 0 

        Range = (high - low) / (rows - 1)

        levelsArr  = array.new<float>(rows, 0)
        vpArr      = array.new<float>(rows, 0)
        deltaArr   = array.new<float>(rows, 0)

        for i = 0 to rows - 1

            levelsArr.set(i, low + (Range * i))

        for [i, data] in vol 

            bot = levelsArr.binary_search_leftmost(l.get(i))
            top = levelsArr.binary_search_leftmost(h.get(i))

            div    = data / (math.abs(top - bot) + 1) 
            absDiv = math.abs(div) 

            for x = bot to top 

                vpArr   .set(x, vpArr.get(x) + absDiv)
                deltaArr.set(x, deltaArr.get(x) + div)

        poc   = vpArr.indexof(vpArr.max()), 
        indUp = poc, indDn = poc, sum = 0., size = vpArr.size()
        total = vpArr.sum() * .7

        for i = 0 to size - 1

            if indUp == indDn 

                sum += vpArr.get(indUp)

                if sum >= total 
                    break 

                indUp += 1 
                indDn -= 1
                continue 

            if indUp < size 

                sum += vpArr.get(indUp)

                if sum >= total 
                    break 

                indUp += 1

            if indDn > -1 

                sum += vpArr.get(indDn)

                if sum >= total 
                    break 

                indDn -= 1

    
        if vpArr.sum() != 0

            minVol = vpArr.min(), rangeVol = vpArr.range()

            absDeltaArr = deltaArr   .abs()
            minDelta    = absDeltaArr.min() 
            rangeDelta  = absDeltaArr.range()

            for [i, data] in vpArr 

                norm = int(na), getDelta = deltaArr.get(i), absDelta = absDeltaArr.get(i)
                
                if profType == "VP"

                    norm := math.round(1 + ((data - minVol) * 10) / rangeVol)

                else 

                    norm := math.round(1 + ((absDelta - minDelta) * 10) / rangeDelta)

                    if math.sign(getDelta) == -1 

                        norm *= -1

                level = levelsArr.get(i)
                getText = "█"

                signNorm = math.sign(norm)

                if signNorm == 1 or profType == "VP"

                    if norm > 1 
                        for x = 0 to math.min(norm - 1, 9)
                            getText += "█"

                    if str.length(getText) < 10 

                        for x = str.length(getText) to 10 
                            getText += " "

                    else if str.length(getText) == 10 

                        getText += " "

                else 

                    getText := ""

                    width  = 11
                    blocks = math.min(math.abs(norm), width)
                    spaces = width - blocks

                    if spaces > 0
                        for x = 0 to spaces - 1
                            getText += " "

                    if blocks > 0
                        for x = 0 to blocks - 1
                            getText += "█"

                    
                    volAtLevel = str.tostring(getDelta, format.volume)

                    if showVolAtLevel
                         
                        getText := volAtLevel + getText

                col = switch math.sign(close - open) 

                    1  => color.new(color.from_gradient(norm, 0, 10, upColAdv, upColAdv2), miniProfTransp)
                    -1 => color.new(color.from_gradient(norm, 0, 10, dnColAdv, dnColAdv2), miniProfTransp)

                if showVolAtLevel 

                    if profType == "VP" or signNorm == 1    

                        getText += switch 

                            profType == "VP" => str.tostring(data, format.volume) 
                            => str.tostring(getDelta, format.volume) 

                if showVA 
                    
                    if i <= indDn or i >= indUp 

                        col := color.new(color.gray, miniProfTransp)

                if customPOCcol
                    if i == poc 
                        col := pocCol

                if profType == "VP" or signNorm == 1

                    box.new(bar_index, level, bar_index + 1, level + Range, text = getText, 
                                                            text_halign   = text.align_left, 
                                                            text_valign   = text.align_center, 
                                                            border_color  = color(na), 
                                                            bgcolor       = #00000000, 
                                                            text_color    = col,
                                                            force_overlay = true 
                                                            )

                else 

                    box.new(bar_index - 1, level, bar_index, level + Range, text = getText, 
                                                            text_halign   = text.align_right, 
                                                            text_valign   = text.align_center, 
                                                            border_color  = color(na), 
                                                            bgcolor       = #00000000, 
                                                            text_color    = col,
                                                            force_overlay = true 
                                                            )


everyBarVP()
````
