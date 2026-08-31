<!-- tradingview-pine-id: PUB;92867c47dbde492c853f3b43cf22c77a -->
<!-- tradingviewscripts-format: 1 -->
# Prem

Source: https://www.tradingview.com/script/x1smV1jT-CALL-PUT-previous-close-average-Prem/

## Description

A call option gives the right to buy an asset, a put option gives the right to sell an asset, the previous close price is the final price from the last session, and an average price is the mean value over a set period.

using TF - 5 mins

First set the Expiry date as YYMMDD, (260811)

then choose the 5min Day Open Candle of NIFTY 50 closing strike price as ATM then type (eg:24500) in first page of indicator

then automatically it creates call and put value of each strike price up and down 15 stikes closing price average value as lines, 

Green colour(Support) buy area,

 Red color Sell area(Resistance),

 yellow color ATM or choose strike price act as center of chart

Best wishes to all

---

## Source Code

````pine
//@version=6
indicator("Prem", overlay=true)

// Inputs
expiry       = input.string("260811", "Option Expiry")
centreStrike = input.int(24500, "Centre Strike", step=50)
strikeStep   = input.int(50, "Strike Difference", step=50)
lineWidth    = input.int(1, "Line Width", minval=1, maxval=4)

// Previous-day close
previousClose(string symbol) =>
    request.security(
         symbol,
         "D",
         close[1],
         gaps=barmerge.gaps_off,
         lookahead=barmerge.lookahead_on,
         ignore_invalid_symbol=true)

// CALL + PUT previous-close average
cpAverage(int strike) =>
    callSymbol = "NSE:NIFTY" + expiry + "C" + str.tostring(strike)
    putSymbol  = "NSE:NIFTY" + expiry + "P" + str.tostring(strike)

    callClose = previousClose(callSymbol)
    putClose  = previousClose(putSymbol)

    not na(callClose) and not na(putClose) ?
         (callClose + putClose) / 2 : na

CPAverage = cpAverage(centreStrike)
// 10 lower strikes
avgL9  = cpAverage(centreStrike - strikeStep * 9)
avgL8  = cpAverage(centreStrike - strikeStep * 8)
avgL7  = cpAverage(centreStrike - strikeStep * 7)
avgL6  = cpAverage(centreStrike - strikeStep * 6)
avgL5  = cpAverage(centreStrike - strikeStep * 5)
avgL4  = cpAverage(centreStrike - strikeStep * 4)
avgL3  = cpAverage(centreStrike - strikeStep * 3)
avgL2  = cpAverage(centreStrike - strikeStep * 2)
avgL1  = cpAverage(centreStrike - strikeStep)

// 10 upper strikes
avgU1  = cpAverage(centreStrike + strikeStep)
avgU2  = cpAverage(centreStrike + strikeStep * 2)
avgU3  = cpAverage(centreStrike + strikeStep * 3)
avgU4  = cpAverage(centreStrike + strikeStep * 4)
avgU5  = cpAverage(centreStrike + strikeStep * 5)
avgU6  = cpAverage(centreStrike + strikeStep * 6)
avgU7  = cpAverage(centreStrike + strikeStep * 7)
avgU8  = cpAverage(centreStrike + strikeStep * 8)
avgU9  = cpAverage(centreStrike + strikeStep * 9)
avgU10 = cpAverage(centreStrike + strikeStep * 10)


plot(CPAverage, "CPA", color=color.rgb(242, 254, 3), linewidth=lineWidth)
// Lower strike average lines
plot(avgL9,  "S9",  color=color.rgb(109, 253, 5), linewidth=lineWidth)
plot(avgL8,  "S8",  color=color.rgb(109, 253, 5), linewidth=lineWidth)
plot(avgL7,  "S7",  color=color.rgb(109, 253, 5), linewidth=lineWidth)
plot(avgL6,  "S6",  color=color.rgb(109, 253, 5), linewidth=lineWidth)
plot(avgL5,  "S5",  color=color.rgb(109, 253, 5), linewidth=lineWidth)
plot(avgL4,  "S4",  color=color.rgb(109, 253, 5), linewidth=lineWidth)
plot(avgL3,  "S3",  color=color.rgb(109, 253, 5), linewidth=lineWidth)
plot(avgL2,  "S2",  color=color.rgb(109, 253, 5), linewidth=lineWidth)
plot(avgL1,  "S1",   color=color.rgb(109, 253, 5), linewidth=lineWidth)

// Upper strike average lines
plot(avgU1,  "R1",  color=color.rgb(242, 0, 0), linewidth=lineWidth)
plot(avgU2,  "R2",  color=color.rgb(242, 0, 0), linewidth=lineWidth)
plot(avgU3,  "R3",  color=color.rgb(242, 0, 0), linewidth=lineWidth)
plot(avgU4,  "R4",  color=color.rgb(242, 0, 0), linewidth=lineWidth)
plot(avgU5,  "R5",  color=color.rgb(242, 0, 0), linewidth=lineWidth)
plot(avgU6,  "R6",  color=color.rgb(242, 0, 0), linewidth=lineWidth)
plot(avgU7,  "R7",  color=color.rgb(242, 0, 0), linewidth=lineWidth)
plot(avgU8,  "R8",  color=color.rgb(242, 0, 0), linewidth=lineWidth)
plot(avgU9,  "R9",  color=color.rgb(242, 0, 0), linewidth=lineWidth)
plot(avgU10, "R10", color=color.rgb(242, 0, 0), linewidth=lineWidth)
````
