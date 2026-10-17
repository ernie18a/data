# SeongMo_MA_V3(Elliot_helper)

- url: https://www.tradingview.com/script/b175MV7o/
- type: strategy
- pine_id: PUB;f8a5c37944e949ceaf6a45c24fd0c309
- version: 2.0

## Description

Made to make it easier to count Elliott waves.
If you renew your new high price, you'll continue your new high price
When the new low is renewed, the new low is continued.
If you are within the range of the previous candle, use the ratio of the difference between the median value of the previous candle and the closing price of the current candle to determine whether to continue the high or low price.
If a can with a tail that updates a new high price and a new low price at the same time comes out, the phrase "Check_candle!" appears to mean that you should check it with a lower time zone candle.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © suc1098

//@version=5
strategy("SeongMo_MA_V3(Elliot_helper)",overlay = true)
var A=close
var B=0.0
var C=0.0

if high[1] < high and low[1] < low  //A new high price
    
    if close[1]<close // Rising Candle -> High Point
        A:=high
    
    if close[1]>close // Decline candle -> median
        A:=(high+low)/2


if high[1] > high and low[1] > low //A new low price
   
    if close[1]>close // // Decline candle -> Low Point
        A:=low
    
    if close[1]<close // Rising candle -> median
        A:=(high+low)/2

if high[1] > high and low[1] < low // Previous Candle Range
    B:=(high[1]+low[1])/2 // After calculating the median of the previous cans
    C:= (100*(close-B)/close)// If the absolute value is 0.06 or less, the median value
    
    if C >= -0.06 and C <= 0.06 
        A:=(high+low)/2
// High point if the closing price is large for the median value of the previous candle and fluctuations above 0.06
    if B <= close and C >= 0.06 
        A:=high
// Low point if the closing price is small and changes below -0.06 for the median of the previous candle  
    if B >= close and C <= -0.06 
        A:=low
//Select a reference point after comparing the high and low prices of the reported and new lows simultaneously reached, and the previous and previous candles
if high[1] < high and low[1] > low 
    if low[2] < low[1]
        A:=high
    if high[2] < high[1]
        A:=low

plot(A,color=color.white)
//Update of new low price for previous candles requires fine counting
plotshape(high[1] < high and low[1] > low and ((100*(high-low)/((high+low)/2))<= -0.6 or (100*(high-low)/((high+low)/2))>= +0.6), "", shape.arrowup,location.abovebar, color=color.rgb(230, 236, 231),  text = "Check_candle!")
````
