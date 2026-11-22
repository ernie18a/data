# Multiple Ticker Trader

- url: https://www.tradingview.com/script/0p4qZuRg-Multiple-Ticker-Trader/
- type: indicator
- pine_id: PUB;f512fa28e49a40a983ac5a7ef48b7410
- version: 2.0

## Description

This indicator can be used as an alternative to the built in Strategy Tester for those who want to (back) test a strategy on multiple tickers simultaneously and see it's performance.
Just change the buy and sell conditions in the code to fit your needs.

The strategy I've used here is scaling into up to 10 tickers a maximum of 5 times per ticker every time they retrace (another) 10% from their all time high. 

You can set the maximum number of total trades and disable scale ins by setting them to an impossible number (such as, 99% away from the all time high).

Credit to QuantNomad for the monthly/yearly returns table bottom left. 

The bottom right table shows the current number of shares the algo is long and also the total all-time returns from each individual ticker, and other data.

The blue line is the number of positions the script is currently long. Each scale into the same ticker represents one position.

The yellow line is the closed P&L. 

The green/red line is the live P&L.

I've used leverage for the example image just to showcase the liquidation display. 

These particular buy/sell conditions cannot close positions at a loss, so be careful if you're wild enough to use this setup live without understanding the script yourself. I haven't used it live myself yet and you should assume there are serious bugs before thinking about using it live, though I'm using a similar thing on cryptos and it's going fine. 

You can edit the leverage, maximum trades and back test range in the settings. The number following the ticker on each label represents which scale in was bought/sold. 

Enjoy :) let me know if you find any good results

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © barnabygraham

//@version=5
indicator("Multiple Ticker Trader", shorttitle="Multi-Ticker Trader",overlay=true)

typ1     = "Live"
typ2 = "Testing"
live = input.string('Live',title="Live or Test?", options=[typ1, typ2])

use1 = input("AAPL", title="Ticker 1")
use2 = input("MSFT", title="Ticker 2")
use3 = input("GOOGL", title="Ticker 3")
use4 = input("TLT", title="Ticker 4")
use5 = input("GS", title="Ticker 5")
use6 = input("FB", title="Ticker 6")
use7 = input("BRK.A", title="Ticker 7")
use8 = input("QQQ", title="Ticker 8")
use9 = input("JPM", title="Ticker 9")
use10 = input("UNH", title="Ticker 10")


high1 = request.security(use1,'',high)
high2 = request.security(use2,'',high)
high3 = request.security(use3,'',high)
high4 = request.security(use4,'',high)
high5 = request.security(use5,'',high)
high6 = request.security(use6,'',high)
high7 = request.security(use7,'',high)
high8 = request.security(use8,'',high)
high9 = request.security(use9,'',high)
high10 = request.security(use10,'',high)
close1 = na(request.security(use1,'',close)) ? 0 : request.security(use1,'',close)
close2 = na(request.security(use2,'',close)) ? 0 : request.security(use2,'',close)
close3 = na(request.security(use3,'',close)) ? 0 : request.security(use3,'',close)
close4 = na(request.security(use4,'',close)) ? 0 : request.security(use4,'',close)
close5 = na(request.security(use5,'',close)) ? 0 : request.security(use5,'',close)
close6 = na(request.security(use6,'',close)) ? 0 : request.security(use6,'',close)
close7 = na(request.security(use7,'',close)) ? 0 : request.security(use7,'',close)
close8 = na(request.security(use8,'',close)) ? 0 : request.security(use8,'',close)
close9 = na(request.security(use9,'',close)) ? 0 : request.security(use9,'',close)
close10 = na(request.security(use10,'',close)) ? 0 : request.security(use10,'',close)

// buy from ATH
var float highestHigh1 = 0
var float highestHigh2 = 0
var float highestHigh3 = 0
var float highestHigh4 = 0
var float highestHigh5 = 0
var float highestHigh6 = 0
var float highestHigh7 = 0
var float highestHigh8 = 0
var float highestHigh9 = 0
var float highestHigh10 = 0

if high1 > highestHigh1
    highestHigh1 := high1
if high2 > highestHigh2
    highestHigh2 := high2
if high3 > highestHigh3
    highestHigh3 := high3
if high4 > highestHigh4
    highestHigh4 := high4
if high5 > highestHigh5
    highestHigh5 := high5
if high6 > highestHigh6
    highestHigh6 := high6
if high7 > highestHigh7
    highestHigh7 := high7
if high8 > highestHigh8
    highestHigh8 := high8
if high9 > highestHigh9
    highestHigh9 := high9
if high10 > highestHigh10
    highestHigh10 := high10

buyzoneA = input(0.9,"Buy % 1")
buyzoneB = input(0.8,"Buy % 2")
buyzoneC = input(0.7,"Buy % 3")
buyzoneD = input(0.6,"Buy % 4")
buyzoneE = input(0.5,"Buy % 5")
sellzone = input(0.99,"Sell %")

buyzoneA1=highestHigh1*buyzoneA
buyzoneB1=highestHigh1*buyzoneB
buyzoneC1=highestHigh1*buyzoneC
buyzoneD1=highestHigh1*buyzoneD
buyzoneE1=highestHigh1*buyzoneE
sellzone1=highestHigh1*sellzone

buyzoneA2=highestHigh2*buyzoneA
buyzoneB2=highestHigh2*buyzoneB
buyzoneC2=highestHigh2*buyzoneC
buyzoneD2=highestHigh2*buyzoneD
buyzoneE2=highestHigh2*buyzoneE
sellzone2=highestHigh2*sellzone

buyzoneA3=highestHigh3*buyzoneA
buyzoneB3=highestHigh3*buyzoneB
buyzoneC3=highestHigh3*buyzoneC
buyzoneD3=highestHigh3*buyzoneD
buyzoneE3=highestHigh3*buyzoneE
sellzone3=highestHigh3*sellzone

buyzoneA4=highestHigh4*buyzoneA
buyzoneB4=highestHigh4*buyzoneB
buyzoneC4=highestHigh4*buyzoneC
buyzoneD4=highestHigh4*buyzoneD
buyzoneE4=highestHigh4*buyzoneE
sellzone4=highestHigh4*sellzone

buyzoneA5=highestHigh5*buyzoneA
buyzoneB5=highestHigh5*buyzoneB
buyzoneC5=highestHigh5*buyzoneC
buyzoneD5=highestHigh5*buyzoneD
buyzoneE5=highestHigh5*buyzoneE
sellzone5=highestHigh5*sellzone

buyzoneA6=highestHigh6*buyzoneA
buyzoneB6=highestHigh6*buyzoneB
buyzoneC6=highestHigh6*buyzoneC
buyzoneD6=highestHigh6*buyzoneD
buyzoneE6=highestHigh6*buyzoneE
sellzone6=highestHigh6*sellzone

buyzoneA7=highestHigh7*buyzoneA
buyzoneB7=highestHigh7*buyzoneB
buyzoneC7=highestHigh7*buyzoneC
buyzoneD7=highestHigh7*buyzoneD
buyzoneE7=highestHigh7*buyzoneE
sellzone7=highestHigh7*sellzone

buyzoneA8=highestHigh8*buyzoneA
buyzoneB8=highestHigh8*buyzoneB
buyzoneC8=highestHigh8*buyzoneC
buyzoneD8=highestHigh8*buyzoneD
buyzoneE8=highestHigh8*buyzoneE
sellzone8=highestHigh8*sellzone

buyzoneA9=highestHigh9*buyzoneA
buyzoneB9=highestHigh9*buyzoneB
buyzoneC9=highestHigh9*buyzoneC
buyzoneD9=highestHigh9*buyzoneD
buyzoneE9=highestHigh9*buyzoneE
sellzone9=highestHigh9*sellzone

buyzoneA10=highestHigh10*buyzoneA
buyzoneB10=highestHigh10*buyzoneB
buyzoneC10=highestHigh10*buyzoneC
buyzoneD10=highestHigh10*buyzoneD
buyzoneE10=highestHigh10*buyzoneE
sellzone10=highestHigh10*sellzone

//End Buy from all time high


////////////////////////////
SETTINGS3=input(true,title="----- Backtest Range -----")
beginYear = input(2018, title="Start Year")
beginMonth = input(1, title="Start Month")
beginDay = input(1, title="Start Day")
endYear = input(2025, title="End Year")
endMonth = input(1, title="End Month")
endDay = input(1, title="End Day")
begin = timestamp(beginYear,beginMonth,beginDay,0,0)//backtest period 
end = timestamp(endYear,endMonth,endDay,0,0)
////////////////////////////

var intrades = 0

var in1 = 0
var in2 = 0
var in3 = 0
var in4 = 0
var in5 = 0
var in6 = 0
var in7 = 0
var in8 = 0
var in9 = 0
var in10 = 0

maxtrades = input(25,title="Maximum Simultaneous Positions (each scale in counts as one)")


var startingAccountValue = input(100,title="Starting Account Value (For Backtesting)")
var realCashInAccount = input(100,title="Real Cash In Account")
var totalCash = realCashInAccount
var totalCashTest = startingAccountValue
//var runningTotal = totalCash + 

var leverage = input(1,title="Leverage")
var netpnl = 0.0

var runningTotal = 0.0 + startingAccountValue // currently only used on closed trades
runningTotalTest = runningTotal

//var leveragedcashpertrade = (leverage*totalCash)/maxtrades
leveragedcash = leverage*startingAccountValue
leveragedcashpertrade = live == "Live" ? (leverage*(startingAccountValue))/maxtrades : (leverage*(runningTotal))/maxtrades

var cash1 = 0.0
var cash2 = 0.0
var cash3 = 0.0
var cash4 = 0.0
var cash5 = 0.0
var cash6 = 0.0
var cash7 = 0.0
var cash8 = 0.0
var cash9 = 0.0
var cash10 = 0.0

marketValue1 = (cash1*close1)
marketValue2 = (cash2*close2)
marketValue3 = (cash3*close3)
marketValue4 = (cash4*close4)
marketValue5 = (cash5*close5)
marketValue6 = (cash6*close6)
marketValue7 = (cash7*close7)
marketValue8 = (cash8*close8)
marketValue9 = (cash9*close9)
marketValue10 = (cash10*close10)

var pnl1 = 0.0
var pnl2 = 0.0
var pnl3 = 0.0
var pnl4 = 0.0
var pnl5 = 0.0
var pnl6 = 0.0
var pnl7 = 0.0
var pnl8 = 0.0
var pnl9 = 0.0
var pnl10 = 0.0

var pnl1_2 = 0.0
var pnl2_2 = 0.0
var pnl3_2 = 0.0
var pnl4_2 = 0.0
var pnl5_2 = 0.0
var pnl6_2 = 0.0
var pnl7_2 = 0.0
var pnl8_2 = 0.0
var pnl9_2 = 0.0
var pnl10_2 = 0.0

openvalue = marketValue1 + marketValue2 + marketValue3 + marketValue4 + marketValue5 + marketValue6 + marketValue7 + marketValue8 + marketValue9 + marketValue10
openunleveragedvalue = openvalue/maxtrades
openpnl = (marketValue1-pnl1) + (marketValue2-pnl2) + (marketValue3-pnl3) + (marketValue4-pnl4) + (marketValue5-pnl5) + (marketValue6-pnl6) + (marketValue7-pnl7) + (marketValue8-pnl8) + (marketValue9-pnl9) + (marketValue10-pnl10)
liveRunningTotal = runningTotal + openpnl

plot(intrades)
plot(runningTotal,color=color.yellow)
plot(liveRunningTotal,color= liveRunningTotal > runningTotal ? color.green : color.red)
//plot(openpnl,color=color.red)

maxdrawdown=1/leverage

Liquidated = openpnl < (runningTotal*maxdrawdown) ? true : false
var liq2 = false
var liq = false
if liq2 == false
    liq := openpnl + (openvalue*maxdrawdown) < 0 ? true : false
    if liq == true
        liq2 := true

liquidationLabel = liq2[1]==false and liq2 ? label.new(bar_index,close,text="LIQUIDATED",style=label.style_xcross, color=color.red, textcolor=color.red, size=size.large) : na

// table
var table divTable = table.new(position.bottom_right, 18, 3, color.new(#ffffff,100), color.new(#ff0000,50),0, color.new(#ffff55,50),0)
//if barstate.islast

table.cell(divTable, 1, 0, use1, text_color=color.new(color.red,50))
table.cell(divTable, 2, 0, use2, text_color=color.new(color.red,50))
table.cell(divTable, 3, 0, use3, text_color=color.new(color.red,50))
table.cell(divTable, 4, 0, use4, text_color=color.new(color.red,50))
table.cell(divTable, 5, 0, use5, text_color=color.new(color.red,50))
table.cell(divTable, 6, 0, use6, text_color=color.new(color.red,50))
table.cell(divTable, 7, 0, use7, text_color=color.new(color.red,50))
table.cell(divTable, 8, 0, use8, text_color=color.new(color.red,50))
table.cell(divTable, 9, 0, use9, text_color=color.new(color.red,50))
table.cell(divTable, 10, 0, use10, text_color=color.new(color.red,50))
table.cell(divTable, 11, 0, "Starting $", text_color=color.new(color.red,50))
table.cell(divTable, 12, 0, "Closed P&L", text_color=color.new(color.red,50))
table.cell(divTable, 13, 0, "Open Value (live)", text_color=color.new(color.red,50))
table.cell(divTable, 14, 0, "Liquidated?", text_color=color.new(color.red,50))
table.cell(divTable, 15, 0, "Open P&L", text_color=color.new(color.red,50))
table.cell(divTable, 16, 0, "Open Unleveraged Value (live)", text_color=color.new(color.red,50))
table.cell(divTable, 17, 0, "Open Value (test)", text_color=color.new(color.red,50))
// table.cell(divTable, 18, 0, "test", text_color=color.new(color.red,50))
table.cell(divTable, 1, 1, in1 ? str.tostring(cash1) : "", text_color=color.new(color.red,50))
table.cell(divTable, 2, 1, in2 ? str.tostring(cash2) : "", text_color=color.new(color.red,50))
table.cell(divTable, 3, 1, in3 ? str.tostring(cash3) : "", text_color=color.new(color.red,50))
table.cell(divTable, 4, 1, in4 ? str.tostring(cash4) : "", text_color=color.new(color.red,50))
table.cell(divTable, 5, 1, in5 ? str.tostring(cash5) : "", text_color=color.new(color.red,50))
table.cell(divTable, 6, 1, in6 ? str.tostring(cash6) : "", text_color=color.new(color.red,50))
table.cell(divTable, 7, 1, in7 ? str.tostring(cash7) : "", text_color=color.new(color.red,50))
table.cell(divTable, 8, 1, in8 ? str.tostring(cash8) : "", text_color=color.new(color.red,50))
table.cell(divTable, 9, 1, in9 ? str.tostring(cash9) : "", text_color=color.new(color.red,50))
table.cell(divTable, 10, 1, in10 ? str.tostring(cash10) : "", text_color=color.new(color.red,50))
table.cell(divTable, 11, 1, str.tostring(startingAccountValue), text_color=color.new(color.red,50))
table.cell(divTable, 12, 1, str.tostring(math.round(netpnl)), text_color=color.new(color.red,50))
table.cell(divTable, 13, 1, str.tostring(math.round(openvalue)), text_color=color.new(color.red,50))
table.cell(divTable, 14, 1, str.tostring(liq2), text_color=color.new(color.red,50))
table.cell(divTable, 15, 1, str.tostring(math.round(openpnl)), text_color=color.new(color.red,50))
table.cell(divTable, 16, 1, str.tostring(openunleveragedvalue), text_color=color.new(color.red,50))
table.cell(divTable, 17, 1, str.tostring(math.round(runningTotal)), text_color=color.new(color.red,50))
// table.cell(divTable, 18, 1, str.tostring(("test")), text_color=color.new(color.red,50))
table.cell(divTable, 1, 2, str.tostring(math.round(pnl1_2+marketValue1)), text_color=color.new(color.red,50))
table.cell(divTable, 2, 2, str.tostring(math.round(pnl2_2+marketValue2)), text_color=color.new(color.red,50))
table.cell(divTable, 3, 2, str.tostring(math.round(pnl3_2+marketValue3)), text_color=color.new(color.red,50))
table.cell(divTable, 4, 2, str.tostring(math.round(pnl4_2+marketValue4)), text_color=color.new(color.red,50))
table.cell(divTable, 5, 2, str.tostring(math.round(pnl5_2+marketValue5)), text_color=color.new(color.red,50))
table.cell(divTable, 6, 2, str.tostring(math.round(pnl6_2+marketValue6)), text_color=color.new(color.red,50))
table.cell(divTable, 7, 2, str.tostring(math.round(pnl7_2+marketValue7)), text_color=color.new(color.red,50))
table.cell(divTable, 8, 2, str.tostring(math.round(pnl8_2+marketValue8)), text_color=color.new(color.red,50))
table.cell(divTable, 9, 2, str.tostring(math.round(pnl9_2+marketValue9)), text_color=color.new(color.red,50))
table.cell(divTable, 10, 2, str.tostring(math.round(pnl10_2+marketValue10)), text_color=color.new(color.red,50))

if time >=begin and time <=end

// EXITS // SHORTS // CLOSES // EXITS // SHORTS // CLOSES // EXITS // SHORTS // CLOSES //

    closeTicker1 = close1 > sellzone1
    closeTicker2 = close2 > sellzone2
    closeTicker3 = close3 > sellzone3
    closeTicker4 = close4 > sellzone4
    closeTicker5 = close5 > sellzone5
    closeTicker6 = close6 > sellzone6
    closeTicker7 = close7 > sellzone7
    closeTicker8 = close8 > sellzone8
    closeTicker9 = close9 > sellzone9
    closeTicker10 = close10 > sellzone10

    if (closeTicker1 and in1 > 0)
        intrades := intrades-in1
        in1 := 0
        pnl1_2 := pnl1_2 + ((cash1*close1)-pnl1)
        netpnl := netpnl + pnl1_2
        runningTotal := runningTotal + pnl1_2
        cash1 := 0
        pnl1 := 0

    if (closeTicker2 and in2 > 0)
        intrades := intrades-in2
        in2 := 0
        pnl2_2 := pnl2_2 + ((cash2*close2)-pnl2)
        netpnl := netpnl + pnl2_2
        runningTotal := runningTotal + pnl2_2
        cash2 := 0
        pnl2 := 0


    if (closeTicker3 and in3 > 0)
        intrades := intrades-in3
        in3 := 0
        pnl3_2 := pnl3_2 + ((cash3*close3)-pnl3)
        netpnl := netpnl + pnl3_2
        runningTotal := runningTotal + pnl3_2
        cash3 := 0
        pnl3 := 0

    if (closeTicker4 and in4 > 0)
        intrades := intrades-in4
        in4 := 0
        pnl4_2 := pnl4_2 + ((cash4*close4)-pnl4)
        netpnl := netpnl + pnl4_2
        runningTotal := runningTotal + pnl4_2
        cash4 := 0
        pnl4 := 0

    if (closeTicker5 and in5 > 0)
        intrades := intrades-in5
        in5 := 0
        pnl5_2 := pnl5_2 + ((cash5*close5)-pnl5)
        netpnl := netpnl + pnl5_2
        runningTotal := runningTotal + pnl5_2
        cash5 := 0
        pnl5 := 0

    if (closeTicker6 and in6 > 0)
        intrades := intrades-in6
        in6 := 0
        pnl6_2 := pnl6_2 + ((cash6*close6)-pnl6)
        netpnl := netpnl + pnl6_2
        runningTotal := runningTotal + pnl6_2
        cash6 := 0
        pnl6 := 0

    if (closeTicker7 and in7 > 0)
        intrades := intrades-in7
        in7 := 0
        pnl7_2 := pnl7_2 + ((cash7*close7)-pnl7)
        netpnl := netpnl + pnl7_2
        runningTotal := runningTotal + pnl7_2
        cash7 := 0
        pnl7 := 0


    if (closeTicker8 and in8 > 0)
        intrades := intrades-in8
        in8 := 0
        pnl8_2 := pnl8_2 + ((cash8*close8)-pnl8)
        netpnl := netpnl + pnl8_2
        runningTotal := runningTotal + pnl8_2
        cash8 := 0
        pnl8 := 0

    if (closeTicker9 and in9 > 0)
        intrades := intrades-in9
        in9 := 0
        pnl9_2 := pnl9_2 + ((cash9*close9)-pnl9)
        netpnl := netpnl + pnl9_2
        runningTotal := runningTotal + pnl9_2
        cash9 := 0
        pnl9 := 0

    if (closeTicker10 and in10 > 0)
        intrades := intrades-in10
        in10 := 0
        pnl10_2 := pnl10_2 + ((cash10*close10)-pnl10)
        netpnl := netpnl + pnl10_2
        runningTotal := runningTotal + pnl10_2
        cash10 := 0
        pnl10 := 0



// ENTRIES // LONGS // BUYS // ENTRIES // LONGS // BUYS // ENTRIES // LONGS // BUYS //

    long1scale1 = (close1 < buyzoneA1) and use1 != ""
    long1scale2 = (close1 < buyzoneB1) and use1 != ""
    long1scale3 = (close1 < buyzoneC1) and use1 != ""
    long1scale4 = (close1 < buyzoneD1) and use1 != ""
    long1scale5 = (close1 < buyzoneE1) and use1 != ""
    if ((intrades < maxtrades) and (((long1scale1) and (in1 == 0)) or ((long1scale2) and (in1 == 1)) or ((long1scale3) and (in1 == 2)) or ((long1scale4) and (in1 == 3)) or ((long1scale5) and (in1 == 4))))
        cash1 := cash1 + math.round(leveragedcashpertrade/close1,2)
        intrades := intrades+1
        in1 := in1 + 1
        pnl1 := (cash1*close1)
        
    long2scale1 = (close2 < buyzoneA2) and use2 != ""
    long2scale2 = (close2 < buyzoneB2) and use2 != ""
    long2scale3 = (close2 < buyzoneC2) and use2 != ""
    long2scale4 = (close2 < buyzoneD2) and use2 != ""
    long2scale5 = (close2 < buyzoneE2) and use2 != ""
    if ((intrades < maxtrades) and (((long2scale1) and (in2 == 0)) or ((long2scale2) and (in2 == 1)) or ((long2scale3) and (in2 == 2)) or ((long2scale4) and (in2 == 3)) or ((long2scale5) and (in2 == 4))))
        cash2 := cash2 + math.round(leveragedcashpertrade/close2,2)
        intrades := intrades+1
        in2 := in2 + 1
        pnl2 := (cash2*close2)
        
    long3scale1 = (close3 < buyzoneA3) and use3 != ""
    long3scale2 = (close3 < buyzoneB3) and use3 != ""
    long3scale3 = (close3 < buyzoneC3) and use3 != ""
    long3scale4 = (close3 < buyzoneD3) and use3 != ""
    long3scale5 = (close3 < buyzoneE3) and use3 != ""
    if ((intrades < maxtrades) and (((long3scale1) and (in3 == 0)) or ((long3scale2) and (in3 == 1)) or ((long3scale3) and (in3 == 2)) or ((long3scale4) and (in3 == 3)) or ((long3scale5) and (in3 == 4))))
        cash3 := cash3 + math.round(leveragedcashpertrade/close3,2)
        intrades := intrades+1
        in3 := in3 + 1
        pnl3 := (cash3*close3)
        
    long4scale1 = (close4 < buyzoneA4) and use4 != ""
    long4scale2 = (close4 < buyzoneB4) and use4 != ""
    long4scale3 = (close4 < buyzoneC4) and use4 != ""
    long4scale4 = (close4 < buyzoneD4) and use4 != ""
    long4scale5 = (close4 < buyzoneE4) and use4 != ""
    if ((intrades < maxtrades) and (((long4scale1) and (in4 == 0)) or ((long4scale2) and (in4 == 1)) or ((long4scale3) and (in4 == 2)) or ((long4scale4) and (in4 == 3)) or ((long4scale5) and (in4 == 4))))
        cash4 := cash4 + math.round(leveragedcashpertrade/close4,2)
        intrades := intrades+1
        in4 := in4 + 1
        pnl4 := (cash4*close4)
        
    long5scale1 = (close5 < buyzoneA5) and use5 != ""
    long5scale2 = (close5 < buyzoneB5) and use5 != ""
    long5scale3 = (close5 < buyzoneC5) and use5 != ""
    long5scale4 = (close5 < buyzoneD5) and use5 != ""
    long5scale5 = (close5 < buyzoneE5) and use5 != ""
    if ((intrades < maxtrades) and (((long5scale1) and (in5 == 0)) or ((long5scale2) and (in5 == 1)) or ((long5scale3) and (in5 == 2)) or ((long5scale4) and (in5 == 3)) or ((long5scale5) and (in5 == 4))))
        cash5 := cash5 + math.round(leveragedcashpertrade/close5,2)
        intrades := intrades+1
        in5 := in5 + 1
        pnl5 := (cash5*close5)
        
    long6scale1 = (close6 < buyzoneA6) and use6 != ""
    long6scale2 = (close6 < buyzoneB6) and use6 != ""
    long6scale3 = (close6 < buyzoneC6) and use6 != ""
    long6scale4 = (close6 < buyzoneD6) and use6 != ""
    long6scale5 = (close6 < buyzoneE6) and use6 != ""
    if ((intrades < maxtrades) and (((long6scale1) and (in6 == 0)) or ((long6scale2) and (in6 == 1)) or ((long6scale3) and (in6 == 2)) or ((long6scale4) and (in6 == 3)) or ((long6scale5) and (in6 == 4))))
        cash6 := cash6 + math.round(leveragedcashpertrade/close6,2)
        intrades := intrades+1
        in6 := in6 + 1
        pnl6 := (cash6*close6)
        
    long7scale1 = (close7 < buyzoneA7) and use7 != ""
    long7scale2 = (close7 < buyzoneB7) and use7 != ""
    long7scale3 = (close7 < buyzoneC7) and use7 != ""
    long7scale4 = (close7 < buyzoneD7) and use7 != ""
    long7scale5 = (close7 < buyzoneE7) and use7 != ""
    if ((intrades < maxtrades) and (((long7scale1) and (in7 == 0)) or ((long7scale2) and (in7 == 1)) or ((long7scale3) and (in7 == 2)) or ((long7scale4) and (in7 == 3)) or ((long7scale5) and (in7 == 4))))
        cash7 := cash7 + math.round(leveragedcashpertrade/close7,2)
        intrades := intrades+1
        in7 := in7 + 1
        pnl7 := (cash7*close7)
        
    long8scale1 = (close8 < buyzoneA8) and use8 != ""
    long8scale2 = (close8 < buyzoneB8) and use8 != ""
    long8scale3 = (close8 < buyzoneC8) and use8 != ""
    long8scale4 = (close8 < buyzoneD8) and use8 != ""
    long8scale5 = (close8 < buyzoneE8) and use8 != ""
    if ((intrades < maxtrades) and (((long8scale1) and (in8 == 0)) or ((long8scale2) and (in8 == 1)) or ((long8scale3) and (in8 == 2)) or ((long8scale4) and (in8 == 3)) or ((long8scale5) and (in8 == 4))))
        cash8 := cash8 + math.round(leveragedcashpertrade/close8,2)
        intrades := intrades+1
        in8 := in8 + 1
        pnl8 := (cash8*close8)
        
    long9scale1 = (close9 < buyzoneA9) and use9 != ""
    long9scale2 = (close9 < buyzoneB9) and use9 != ""
    long9scale3 = (close9 < buyzoneC9) and use9 != ""
    long9scale4 = (close9 < buyzoneD9) and use9 != ""
    long9scale5 = (close9 < buyzoneE9) and use9 != ""
    if ((intrades < maxtrades) and (((long9scale1) and (in9 == 0)) or ((long9scale2) and (in9 == 1)) or ((long9scale3) and (in9 == 2)) or ((long9scale4) and (in9 == 3)) or ((long9scale5) and (in9 == 4))))
        cash9 := cash9 + math.round(leveragedcashpertrade/close9,2)
        intrades := intrades+1
        in9 := in9 + 1
        pnl9 := (cash9*close9)
        
    long10scale1 = (close10 < buyzoneA10) and use10 != ""
    long10scale2 = (close10 < buyzoneB10) and use10 != ""
    long10scale3 = (close10 < buyzoneC10) and use10 != ""
    long10scale4 = (close10 < buyzoneD10) and use10 != ""
    long10scale5 = (close10 < buyzoneE10) and use10 != ""
    if ((intrades < maxtrades) and (((long10scale1) and (in10 == 0)) or ((long10scale2) and (in10 == 1)) or ((long10scale3) and (in10 == 2)) or ((long10scale4) and (in10 == 3)) or ((long10scale5) and (in10 == 4))))
        cash10 := cash10 + math.round(leveragedcashpertrade/close10,2)
        intrades := intrades+1
        in10 := in10 + 1
        pnl10 := (cash10*close10)


BuyArrow1 = in1[1] < in1
SellArrow1= in1[1] > in1
BuyArrow2 = in2[1] < in2
SellArrow2= in2[1] > in2
BuyArrow3 = in3[1] < in3
SellArrow3= in3[1] > in3
BuyArrow4 = in4[1] < in4
SellArrow4= in4[1] > in4
BuyArrow5 = in5[1] < in5
SellArrow5= in5[1] > in5
BuyArrow6 = in6[1] < in6
SellArrow6= in6[1] > in6
BuyArrow7 = in7[1] < in7
SellArrow7= in7[1] > in7
BuyArrow8 = in8[1] < in8
SellArrow8= in8[1] > in8
BuyArrow9 = in9[1] < in9
SellArrow9= in9[1] > in9
BuyArrow10 = in10[1] < in10
SellArrow10= in10[1] > in10

buy1 = BuyArrow1 ? use1 + str.tostring(in1) + "\n" : ""
sell1 = SellArrow1 ? use1 + str.tostring(in1[1]) + "\n" : ""
buy2 = BuyArrow2 ? use2 + str.tostring(in2) + "\n" : ""
sell2 = SellArrow2 ? use2 + str.tostring(in2[1]) + "\n" : ""
buy3 = BuyArrow3 ? use3 + str.tostring(in3) + "\n" : ""
sell3 = SellArrow3 ? use3 + str.tostring(in3[1]) + "\n" : ""
buy4 = BuyArrow4 ? use4 + str.tostring(in4) + "\n" : ""
sell4 = SellArrow4 ? use4 + str.tostring(in4[1]) + "\n" : ""
buy5 = BuyArrow5 ? use5 + str.tostring(in5) + "\n" : ""
sell5 = SellArrow5 ? use5 + str.tostring(in5[1]) + "\n" : ""
buy6 = BuyArrow6 ? use6 + str.tostring(in6) + "\n" : ""
sell6 = SellArrow6 ? use6 + str.tostring(in6[1]) + "\n" : ""
buy7 = BuyArrow7 ? use7 + str.tostring(in7) + "\n" : ""
sell7 = SellArrow7 ? use7 + str.tostring(in7[1]) + "\n" : ""
buy8 = BuyArrow8 ? use8 + str.tostring(in8) + "\n" : ""
sell8 = SellArrow8 ? use8 + str.tostring(in8[1]) + "\n" : ""
buy9 = BuyArrow9 ? use9 + str.tostring(in9) + "\n" : ""
sell9 = SellArrow9 ? use9 + str.tostring(in9[1]) + "\n" : ""
buy10 = BuyArrow10 ? use10 + str.tostring(in10) + "\n" : ""
sell10 = SellArrow10 ? use10 + str.tostring(in10[1]) + "\n" : ""

buyLabel = BuyArrow1 or BuyArrow2 or BuyArrow3 or BuyArrow4 or BuyArrow5 or BuyArrow6 or BuyArrow7 or BuyArrow8 or BuyArrow9 or BuyArrow10 ? label.new(bar_index,high*0.9,text=buy1+buy2+buy3+buy4+buy5+buy6+buy7+buy8+buy9+buy10,style=label.style_triangleup, color=color.green, textcolor=color.green, size=size.normal) : na
sellLabel= SellArrow1 or SellArrow2 or SellArrow3 or SellArrow4 or SellArrow5 or SellArrow6 or SellArrow7 or SellArrow8 or SellArrow9 or SellArrow10 ? label.new(bar_index,low*1.1,text=sell1+sell2+sell3+sell4+sell5+sell6+sell7+sell8+sell9+sell10,style=label.style_triangledown, color=color.red, textcolor=color.red, size=size.normal) : na

// RETURNS TABLE //

// monthly returns
// Inputs 
leftBars = 2//input(2)
rightBars = 1//input(1)
prec = 2//input(2, title='Return Precision')

// Pivot Points 
swh = ta.pivothigh(leftBars, rightBars)
swl = ta.pivotlow(leftBars, rightBars)

hprice = 0.0
hprice := not na(swh) ? swh : hprice[1]

lprice = 0.0
lprice := not na(swl) ? swl : lprice[1]

le = false
le := not na(swh) ? true : le[1] and high > hprice ? false : le[1]

se = false
se := not na(swl) ? true : se[1] and low < lprice ? false : se[1]

///////////////////
// MONTHLY TABLE //

new_month = month(time) != month(time[1])
new_year = year(time) != year(time[1])

eq = runningTotal //Liquidated == false ? (runningTotal) : 0 //+ openvalue      // strategy.equity // Initial capital + net pnl + open pnl

bar_pnl = eq / eq[1] - 1

cur_month_pnl = 0.0
cur_year_pnl = 0.0

// Current Monthly P&L
cur_month_pnl := new_month ? 0.0 : (1 + cur_month_pnl[1]) * (1 + bar_pnl) - 1

// Current Yearly P&L
cur_year_pnl := new_year ? 0.0 : (1 + cur_year_pnl[1]) * (1 + bar_pnl) - 1

// Arrays to store Yearly and Monthly P&Ls
var month_pnl = array.new_float(0)
var month_time = array.new_int(0)

var year_pnl = array.new_float(0)
var year_time = array.new_int(0)

last_computed = false

if not na(cur_month_pnl[1]) and (new_month)// or barstate.islast)
    if last_computed[1]
        array.pop(month_pnl)
        array.pop(month_time)

    array.push(month_pnl, cur_month_pnl[1])
    array.push(month_time, time[1])

if not na(cur_year_pnl[1]) and (new_year)// or barstate.islast)
    if last_computed[1]
        array.pop(year_pnl)
        array.pop(year_time)

    array.push(year_pnl, cur_year_pnl[1])
    array.push(year_time, time[1])

last_computed := barstate.islast ? true : nz(last_computed[1])

// Monthly P&L Table    
var monthly_table = table(na)

if barstate.islast
    monthly_table := table.new(position.bottom_left, columns=14, rows=array.size(year_pnl) + 2, border_width=1)
    table.cell(monthly_table, 0, 0, '', bgcolor=#cccccc)
    table.cell(monthly_table, 1, 0, 'Jan', bgcolor=#cccccc)
    table.cell(monthly_table, 2, 0, 'Feb', bgcolor=#cccccc)
    table.cell(monthly_table, 3, 0, 'Mar', bgcolor=#cccccc)
    table.cell(monthly_table, 4, 0, 'Apr', bgcolor=#cccccc)
    table.cell(monthly_table, 5, 0, 'May', bgcolor=#cccccc)
    table.cell(monthly_table, 6, 0, 'Jun', bgcolor=#cccccc)
    table.cell(monthly_table, 7, 0, 'Jul', bgcolor=#cccccc)
    table.cell(monthly_table, 8, 0, 'Aug', bgcolor=#cccccc)
    table.cell(monthly_table, 9, 0, 'Sep', bgcolor=#cccccc)
    table.cell(monthly_table, 10, 0, 'Oct', bgcolor=#cccccc)
    table.cell(monthly_table, 11, 0, 'Nov', bgcolor=#cccccc)
    table.cell(monthly_table, 12, 0, 'Dec', bgcolor=#cccccc)
    table.cell(monthly_table, 13, 0, 'Year', bgcolor=#999999)
    
    
    for yi = 0 to array.size(year_pnl) - 1 by 1
        table.cell(monthly_table, 0, yi + 1, str.tostring(year(array.get(year_time, yi))), bgcolor=#cccccc)
    
        y_color = array.get(year_pnl, yi) > 0 ? color.new(color.green, transp=50) : color.new(color.red, transp=80)
        table.cell(monthly_table, 13, yi + 1, str.tostring(math.round(array.get(year_pnl, yi) * 100, prec)), bgcolor=y_color, text_color=color.white)
    
    for mi = 0 to array.size(month_time) - 1 by 1
        m_row = year(array.get(month_time, mi)) - year(array.get(year_time, 0)) + 1
        m_col = month(array.get(month_time, mi))
        m_color = array.get(month_pnl, mi) > 0 ? color.new(color.green, transp=70) : color.new(color.red, transp=90)
    
        table.cell(monthly_table, m_col, m_row, str.tostring(math.round(array.get(month_pnl, mi) * 100, prec)), bgcolor=m_color, text_color=color.white)
````
