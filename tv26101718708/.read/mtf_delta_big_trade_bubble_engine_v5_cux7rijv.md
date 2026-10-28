# MTF Delta Big Trade Bubble Engine v5

- url: https://www.tradingview.com/script/CuX7RiJv-MTF-Delta-Big-Trade-Bubble-Engine-v5/
- type: indicator
- pine_id: PUB;e91167aa07804a05ae9b87f7a781ee97
- version: 1.0

## Description

MTF Order Flow Intelligence Engine

Description:

MTF Order Flow Intelligence Engine is an advanced order flow analysis indicator designed to work together with Volume Profile tools. Instead of replacing Volume Profile, it focuses on detecting aggressive buying/selling activity, liquidity reactions, and market participation inside higher timeframe candles.

The indicator automatically detects the current chart timeframe and selects a suitable lower timeframe to analyze intrabar order flow. Lower timeframe volume is aggregated into time blocks to identify significant order flow events and display them directly on the higher timeframe chart.

Core Features

1. Multi-Timeframe Delta Analysis

Automatically analyzes lower timeframe candles inside the current chart timeframe.
Estimates buying and selling pressure using volume distribution.
Displays aggregated Delta flow to reveal market aggression.

2. Buy/Sell Pressure Detection

Measures the dominance of buyers or sellers using Delta Pressure.
Helps identify whether market participants are actively pushing price.

3. Big Trade Bubble Detection
Detects abnormal order flow activity based on:

Relative volume expansion
Delta strength
Buying/selling pressure

Signals:

🟢 BIG BUY
Aggressive buyers entering the market.

🔴 BIG SELL
Aggressive sellers entering the market.

4. Absorption Detection
Identifies situations where aggressive traders fail to move price.

Signals:

🔵 ABS BUY

Strong selling pressure appears
Price refuses to move lower
Possible buyer absorption

🟠 ABS SELL

Strong buying pressure appears
Price fails to move higher
Possible seller absorption

5. Cumulative Delta & Divergence
Tracks cumulative delta behavior to detect potential reversals.

Signals:

🟣 Delta Divergence

Price movement disagrees with order flow
Possible exhaustion or reversal zone

6. Exhaustion Detection
Highlights moments when aggressive buyers or sellers lose momentum.

⚪ EXHAUST

Strong delta activity
Weak price response
Possible end of current move

7. Liquidity Trap Detection
Detects failed breakouts caused by trapped traders.

🟡 BUY TRAP

Buyers chase higher prices
Breakout fails

🟤 SELL TRAP

Sellers push lower
Breakdown fails
Recommended Usage

Combine this indicator with:

Fixed Range Volume Profile
Point of Control (POC)
Value Area High / Low
Support & Resistance zones

Example:

At Volume Profile support:

ABS BUY + Bull Delta Divergence
→ potential long confirmation

At Volume Profile resistance:

ABS SELL + BUY TRAP
→ potential short confirmation
Important Note

TradingView does not provide true bid/ask footprint data in Pine Script. This indicator uses OHLCV-based delta estimation to approximate order flow behavior. It is designed as a confirmation tool for volume-based trading analysis.

## Source Code

````pine
//@version=6
indicator(
 "MTF Delta Big Trade Bubble Engine v5",
 overlay=true,
 max_labels_count=500
)


//================ TF ENGINE ================


f_getLTF() =>

    tf = timeframe.in_seconds()

    string result = "1"

    if tf <= 300
        result := "1"

    else if tf <= 900
        result := "1"

    else if tf <= 3600
        result := "1"

    else if tf <= 14400
        result := "5"

    else if tf <= 86400
        result := "15"

    else
        result := "60"

    result



ltf =
 f_getLTF()



//================ INPUT ================


blockBars =
 input.int(
 5,
 "LTF candles per bubble"
 )


volX =
 input.float(
 2.0,
 "Big volume multiplier"
 )


pressureLimit =
 input.float(
 45,
 "Pressure threshold"
 )


showAbs =
 input.bool(
 true,
 "Show absorption"
 )




//================ LOWER TF =================


[o,h,l,c,v] =
 request.security_lower_tf(
 syminfo.tickerid,
 ltf,
 [
 open,
 high,
 low,
 close,
 volume
 ]
)




//================ DELTA =================


float buy = 0
float sell = 0
float volumeSum = 0


n =
 array.size(v)


if n > 0

    for i = 0 to n-1

        hh =
         array.get(h,i)

        ll =
         array.get(l,i)

        cc =
         array.get(c,i)

        vv =
         array.get(v,i)


        priceRange =
          math.max(
          hh-ll,
          syminfo.mintick
          )


        buy +=vv*(cc-ll)/priceRange


        sell +=  vv*(hh-cc)/priceRange

        volumeSum += vv




delta =
 buy-sell


total =
 buy+sell


pressure =
 total>0 ?
 delta/total*100 :
 0



//================ BLOCK =================


var float bDelta = 0
var float bVol = 0
var float bPressure = 0


var int counter = 0


counter += 1


if counter >= blockBars

    bDelta := delta
    bVol := volumeSum
    bPressure := pressure

    counter := 0




avgVol =
 ta.sma(
 bVol,
 50
 )


relative =
 avgVol>0 ?
 bVol/avgVol :
 0



//================ SIGNALS =================


bigBuy =
 relative > volX and
 bPressure > pressureLimit



bigSell =
 relative > volX and
 bPressure < -pressureLimit




atr =
 ta.atr(14)



body =
 math.abs(close-open)



absBuy =
 showAbs and
 relative>1.5 and
 bPressure < -35 and
 body < atr*0.5



absSell =
 showAbs and
 relative>1.5 and
 bPressure > 35 and
 body < atr*0.5




//================ DRAW =================



if bigBuy

    label.new(
     bar_index,
     close,
     "BUY\n"+
     str.tostring(relative,"#.1x"),
     style=label.style_circle,
     size=size.large,
     color=color.lime,
     textcolor=color.black
     )


if bigSell

    label.new(
     bar_index,
     close,
     "SELL\n"+
     str.tostring(relative,"#.1x"),
     style=label.style_circle,
     size=size.large,
     color=color.red,
     textcolor=color.black
     )


if absBuy

    label.new(
     bar_index,
     low,
     "ABS BUY",
     style=label.style_circle,
     color=color.aqua
     )


if absSell

    label.new(
     bar_index,
     high,
     "ABS SELL",
     style=label.style_circle,
     color=color.orange
     )



//================ DEBUG =================


plot(
 bDelta,
 "Block Delta",
 display=display.data_window
)


plot(
 bPressure,
 "Block Pressure",
 display=display.data_window
)
//================ LEGEND TABLE =================

var table info = table.new(
     position.top_right,
     3,
     12,
     border_width = 1
)


if barstate.islast

    table.cell(
        info, 0, 0,
        "SIGNAL",
        bgcolor=color.black,
        text_color=color.black
    )

    table.cell(
        info, 1, 0,
        "COLOR",
        bgcolor=color.black,
        text_color=color.black
    )

    table.cell(
        info, 2, 0,
        "MEANING",
        bgcolor=color.black,
        text_color=color.black
    )


    table.cell(info,0,1,"BIG BUY",
        bgcolor=color.lime,
        text_color=color.black)

    table.cell(info,1,1,"🟢")
    table.cell(info,2,1,"Aggressive Buyer")


    table.cell(info,0,2,"BIG SELL",
        bgcolor=color.red,
        text_color=color.black)

    table.cell(info,1,2,"🔴")
    table.cell(info,2,2,"Aggressive Seller")


    table.cell(info,0,3,"ABS BUY",
        bgcolor=color.aqua,
        text_color=color.black)

    table.cell(info,1,3,"🔵")
    table.cell(info,2,3,"Seller absorbed")


    table.cell(info,0,4,"ABS SELL",
        bgcolor=color.orange,
        text_color=color.black)

    table.cell(info,1,4,"🟠")
    table.cell(info,2,4,"Buyer absorbed")


    table.cell(info,0,5,"BULL DIV",
        bgcolor=color.purple,
        text_color=color.black)

    table.cell(info,1,5,"🟣")
    table.cell(info,2,5,"CVD Bull divergence")


    table.cell(info,0,6,"BEAR DIV",
        bgcolor=color.purple,
        text_color=color.black)

    table.cell(info,1,6,"🟣")
    table.cell(info,2,6,"CVD Bear divergence")


    table.cell(info,0,7,"EXHAUST",
        bgcolor=color.gray,
        text_color=color.black)

    table.cell(info,1,7,"⚪")
    table.cell(info,2,7,"Momentum weak")


    table.cell(info,0,8,"BUY TRAP",
        bgcolor=color.yellow,
        text_color=color.black)

    table.cell(info,1,8,"🟡")
    table.cell(info,2,8,"Buyer trapped")


    table.cell(info,0,9,"SELL TRAP",
        bgcolor=color.orange,
        text_color=color.black)

    table.cell(info,1,9,"🟤")
    table.cell(info,2,9,"Seller trapped")


    table.cell(info,0,10,"PRESSURE")

    table.cell(
        info,
        1,
        10,
        str.tostring(pressure,"#.1")+"%"
    )

    table.cell(
        info,
        2,
        10,
        pressure > 0 ? "BULL" : "BEAR"
    )


    table.cell(info,0,11,"DELTA")

    table.cell(
        info,
        1,
        11,
        str.tostring(delta,"#")
    )

    table.cell(info,2,11,"FLOW")
     //============== CVD =================


var float cvd = 0

cvd += delta


cvdMA =
 ta.sma(
 cvd,
 20
 )



//============== DIVERGENCE ==============


bullDiv =
 low < low[10] and
 cvd > cvd[10]


bearDiv =
 high > high[10] and
 cvd < cvd[10]



//============== EXHAUSTION ==============


atr2 =
 ta.atr(14)

rangeNow =
 high-low

bullExhaust =
 pressure > 70 and
 rangeNow < atr2*0.5


bearExhaust =
 pressure < -70 and
 rangeNow < atr2*0.5



//============== TRAP ===================


var float lastHigh = na
var float lastLow = na


if bigBuy
    lastHigh := high


if bigSell
    lastLow := low



bullTrap =
 not na(lastHigh) and
 high > lastHigh and
 close < lastHigh



bearTrap =
 not na(lastLow) and
 low < lastLow and
 close > lastLow

//============== EXTRA BUBBLES ==============


if bullDiv

    label.new(
     bar_index,
     low,
     "🟣\nΔ DIV",
     style=label.style_circle,
     color=color.purple,
     textcolor=color.black
    )


if bearDiv

    label.new(
     bar_index,
     high,
     "🟣\nΔ DIV",
     style=label.style_circle,
     color=color.purple,
     textcolor=color.black
    )



if bullExhaust

    label.new(
     bar_index,
     high,
     "⚪\nBUY EXH",
     style=label.style_circle,
     color=color.gray,
     textcolor=color.black
    )



if bearExhaust

    label.new(
     bar_index,
     low,
     "⚪\nSELL EXH",
     style=label.style_circle,
     color=color.gray,
     textcolor=color.black
    )



if bullTrap

    label.new(
     bar_index,
     high,
     "🟡\nBUY TRAP",
     style=label.style_circle,
     color=color.yellow,
     textcolor=color.black
    )



if bearTrap

    label.new(
     bar_index,
     low,
     "🟤\nSELL TRAP",
     style=label.style_circle,
     color=color.orange,
     textcolor=color.black
    )
````
