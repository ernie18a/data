# Single Candle Footprint v2 - Engine

- url: https://www.tradingview.com/script/ZXgnIKo9-Single-Candle-Footprint-v2-Engine/
- type: indicator
- pine_id: PUB;ed8dd0fc436042f58bebb8916bdf3bdc
- version: 1.0

## Description

Single Candle Footprint Delta Pro

Single Candle Footprint Delta Pro is an order flow inspired indicator designed to visualize intrabar buying and selling pressure directly on each candle.

Unlike traditional volume indicators that only show total volume, this script breaks each candle into multiple price levels and estimates the distribution of aggressive buying and selling activity using lower timeframe data.

Features

• Bid / Ask Footprint Visualization
Displays a footprint-style ladder beside each candle:

Left side: estimated selling volume (Bid)
Right side: estimated buying volume (Ask)
Each row represents a price level inside the candle range

This allows traders to analyze how volume is distributed at different prices.

• Delta Calculation

The script calculates:

Delta = Ask Volume - Bid Volume

Positive delta indicates stronger buying pressure, while negative delta indicates stronger selling pressure.

Delta helps identify:

Aggressive buyers
Aggressive sellers
Momentum strength
Potential exhaustion

• Volume Point of Control (POC)

Highlights the price level where the highest amount of volume occurred inside the candle.

POC can act as:

A short-term equilibrium level
A reaction zone
A potential retest area

• Imbalance Detection

Detects abnormal volume differences between buyers and sellers.

Example:

Ask: 3000
Bid: 500

The strong ratio suggests buyer imbalance.

This helps identify areas where one side is dominating the auction.

• Stacked Imbalance

Identifies multiple consecutive price levels with strong imbalance.

A stacked imbalance may indicate:

Strong directional participation
Institutional activity
Aggressive order flow continuation

• Absorption Detection

Highlights situations where price movement and delta disagree.

Examples:

Bullish absorption:

Price moves down
Delta remains positive

Meaning:
Sellers are aggressive, but buyers absorb their selling pressure.

Bearish absorption:

Price moves up
Delta turns negative

Meaning:
Buyers are aggressive, but sellers absorb the demand.

• Unfinished Auction (UA)

Detects extreme price levels where one side dominates without sufficient opposing volume.

This can indicate an incomplete auction process and possible future price revisit.

How It Works

The indicator uses lower timeframe candles to estimate intrabar order flow:

Lower timeframe bullish candles → estimated buying volume
Lower timeframe bearish candles → estimated selling volume

Because TradingView does not provide true exchange Bid/Ask volume data, this is an approximation of footprint behavior.

For true order flow data, platforms with exchange-level market data may provide more precise Bid/Ask footprints.

Recommended Use

Combine with:

Volume Profile
VWAP
Market Structure
Liquidity zones
Support / Resistance

Best used to analyze:

Absorption
Breakout confirmation
Failed breakouts
Liquidity reactions
Entry timing

Note: This indicator is designed as an order flow visualization tool, not a standalone trading system. It should be interpreted together with price action and market context.

## Source Code

````pine
//@version=6
indicator(
     "Single Candle Footprint v2 - Engine",
     overlay=true,
     max_boxes_count=500,
     max_labels_count=300
)


//================ INPUT =================

ltf = input.timeframe(
     "1",
     "Lower TF"
)

rows = input.int(
     12,
     "Price Levels",
     minval=5,
     maxval=30
)

showOnlyLast = input.bool(
     true,
     "Show Current Candle Only"
)

offset = input.int(
     2,
     "Footprint Offset"
)

width = input.int(
     5,
     "Footprint Width"
)

imbRatio = input.float(
     3.0,
     "Imbalance Ratio"
)


//================ LTF DATA =================


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



//================ STORAGE =================


var float[] levelPrice = array.new_float()
var float[] askVol = array.new_float()
var float[] bidVol = array.new_float()


var box[] fpBoxes = array.new_box()
var label[] fpLabels = array.new_label()



//================ CLEAN =================


if barstate.isnew

    array.clear(levelPrice)
    array.clear(askVol)
    array.clear(bidVol)


    if array.size(fpBoxes)>0

        for b in fpBoxes
            box.delete(b)

        array.clear(fpBoxes)



    if array.size(fpLabels)>0

        for x in fpLabels
            label.delete(x)

        array.clear(fpLabels)




//================ PRICE LADDER =================


barRange = high - low


step =
 barRange > 0 ?
 barRange / rows :
 syminfo.mintick



for i = 0 to rows-1


    p =
     low + step*i


    array.push(
      levelPrice,
      p
    )


    array.push(
      askVol,
      0
    )


    array.push(
      bidVol,
      0
    )





//================ DISTRIBUTE LTF =================



if array.size(v)>0


    for x = 0 to array.size(v)-1


        ltfH =
         array.get(h,x)

        ltfL =
         array.get(l,x)

        ltfV =
         array.get(v,x)



        isAsk =
         array.get(c,x)
         >
         array.get(o,x)



        touched = 0



        for r=0 to rows-1


            p =
             array.get(levelPrice,r)


            if ltfH >= p and ltfL <= p+step

                touched += 1




        if touched > 0


            part =
             ltfV / touched



            for r=0 to rows-1


                p =
                 array.get(levelPrice,r)



                if ltfH >= p and ltfL <= p+step



                    if isAsk

                        array.set(
                          askVol,
                          r,
                          array.get(askVol,r)+part
                        )

                    else

                        array.set(
                          bidVol,
                          r,
                          array.get(bidVol,r)+part
                        )





//================ DELTA =================


float totalDelta = 0


float maxVolume = 0
int pocIndex = 0



for i=0 to rows-1


    ask =
     array.get(askVol,i)

    bid =
     array.get(bidVol,i)


    delta =
     ask-bid


    totalDelta += delta



    vol =
     ask+bid


    if vol > maxVolume

        maxVolume := vol
        pocIndex := i



deltaPct =
 volume != 0 ?
 totalDelta / volume :
 0

//================ DRAW FOOTPRINT =================


// vị trí footprint

fpX =
 bar_index + offset


midX =
 fpX + width/2



// tìm max để scale độ rộng

maxAsk = 0.0
maxBid = 0.0


for i=0 to rows-1

    a =
     array.get(askVol,i)

    b =
     array.get(bidVol,i)


    maxAsk :=
     math.max(maxAsk,a)

    maxBid :=
     math.max(maxBid,b)



//================ CREATE CELLS =================


for i=0 to rows-1


    price =
     array.get(levelPrice,i)


    ask =
     array.get(askVol,i)


    bid =
     array.get(bidVol,i)



    delta =
     ask - bid



    // scale width

    askW =
     maxAsk > 0 ?
     math.round(
       ask/maxAsk*width
     ) :
     1


    bidW =
     maxBid > 0 ?
     math.round(
       bid/maxBid*width
     ) :
     1




    // imbalance

    buyImb =
     ask > bid*imbRatio


    sellImb =
     bid > ask*imbRatio




    // POC

    isPOC =
     i == pocIndex




    // colors


    bidColor =
     sellImb ?
     color.new(color.red,10) :
     color.new(color.red,65)


    askColor =
     buyImb ?
     color.new(color.lime,10) :
     color.new(color.green,65)



    if isPOC

        bidColor :=
         color.new(color.yellow,20)

        askColor :=
         color.new(color.yellow,20)





    //================ BID BOX =================


    bidBox =
     box.new(
       fpX - bidW,
       price+step,
       fpX,
       price,
       bgcolor=bidColor,
       border_color=color.gray
     )


    array.push(
      fpBoxes,
      bidBox
    )





    //================ ASK BOX =================


    askBox =
     box.new(
       fpX,
       price+step,
       fpX+askW,
       price,
       bgcolor=askColor,
       border_color=color.gray
     )


    array.push(
      fpBoxes,
      askBox
    )






    //================ TEXT =================


    txt =
     str.tostring(
       bid,
       format.volume
     )
     +
     " | "
     +
     str.tostring(
       price,
       format.mintick
     )
     +
     " | "
     +
     str.tostring(
       ask,
       format.volume
     )



    lb =
     label.new(
       fpX,
       price+step/2,
       txt,
       style=label.style_label_left,
       textcolor=color.white,
       color=color.new(color.black,80),
       size=size.tiny
     )


    array.push(
      fpLabels,
      lb
    )






//================ DELTA LABEL =================



deltaColor =
 totalDelta > 0 ?
 color.green :
 color.red



deltaLabel =
 label.new(
   bar_index,
   high,
   "Δ "
   +
   str.tostring(
    totalDelta,
    format.volume
   ),
   color=deltaColor,
   textcolor=color.white,
   style=label.style_label_down
 )


array.push(
 fpLabels,
 deltaLabel
)

//================ STACKED IMBALANCE =================


// đếm chuỗi imbalance

bullStack = 0
bearStack = 0


bool stackedBull = false
bool stackedBear = false



for i = 0 to rows-1


    ask =
     array.get(askVol,i)

    bid =
     array.get(bidVol,i)



    if ask > bid * imbRatio

        bullStack += 1
        bearStack := 0


    else if bid > ask * imbRatio

        bearStack += 1
        bullStack := 0


    else

        bullStack := 0
        bearStack := 0




if bullStack >= 3

    stackedBull := true


if bearStack >= 3

    stackedBear := true





//================ STACK LABEL =================


if stackedBull

    label.new(
      bar_index,
      low,
      "STACK BUY",
      style=label.style_label_up,
      color=color.green,
      textcolor=color.white
    )



if stackedBear

    label.new(
      bar_index,
      high,
      "STACK SELL",
      style=label.style_label_down,
      color=color.red,
      textcolor=color.white
    )







//================ UNFINISHED AUCTION =================


// chỉ xét đầu nến


topAsk =
 array.get(
  askVol,
  rows-1
 )


topBid =
 array.get(
  bidVol,
  rows-1
 )


bottomAsk =
 array.get(
  askVol,
  0
 )


bottomBid =
 array.get(
  bidVol,
  0
 )



// UA high

unfinishedHigh =
 topAsk > topBid * imbRatio
 and topBid < syminfo.mintick * 10



// UA low

unfinishedLow =
 bottomBid > bottomAsk * imbRatio
 and bottomAsk < syminfo.mintick * 10




if unfinishedHigh

    label.new(
      bar_index,
      high,
      "UA ↑",
      style=label.style_label_down,
      color=color.orange,
      textcolor=color.black
    )



if unfinishedLow

    label.new(
      bar_index,
      low,
      "UA ↓",
      style=label.style_label_up,
      color=color.orange,
      textcolor=color.black
    )







//================ ABSORPTION =================



// giá tăng nhưng delta âm
bearAbsorb =
 close > open
 and totalDelta < 0



// giá giảm nhưng delta dương
bullAbsorb =
 close < open
 and totalDelta > 0




if bullAbsorb

    label.new(
      bar_index,
      low,
      "ABS BUY",
      color=color.blue,
      textcolor=color.white,
      style=label.style_label_up
    )



if bearAbsorb

    label.new(
      bar_index,
      high,
      "ABS SELL",
      color=color.purple,
      textcolor=color.white,
      style=label.style_label_down
    )





//================ DELTA CANDLE COLOR =================



deltaBarColor =
 bullAbsorb or bearAbsorb ?
 color.orange :
 totalDelta > 0 ?
 color.green :
 color.red



barcolor(deltaBarColor)





//================ INFO =================



plot(
 totalDelta,
 title="Delta",
 display=display.data_window
)
````
