# TSP Sexy RSI

- url: https://www.tradingview.com/script/RzlqlfKb-TSP-Sexy-RSI/
- type: indicator
- pine_id: PUB;u9A4rAUcABhn2C9RsRBwTJh8fovHfPaw
- version: 2.0

## Description

The Sexiest RSI in Town !
- Range zone are indicated with lower colors
- MA 10 cross signals

## Source Code

````pine
////////////////////////////////////////////////////////////
// TSP
// original Copyright by HPotter v1.0 07/08/2014
// This simple indicator modified RSI
// You can use in the xPrice any series: Open, High, Low, Close, HL2, HLC3, OHLC4 and ect...
////////////////////////////////////////////////////////////
study(title="TSP RSI v3")
RSIPeriod = input(13, minval=1)
BuyAlertLevel = input(-10)
SellAlertLevel = input(10)
RSIHistoModify = input(1.5)
hline(0, color=purple, linestyle=line)
hline(BuyAlertLevel, color=green, linestyle=dashed)
hline(SellAlertLevel, color=red, linestyle=dashed)
xPrice = close
RSIMain = (rsi(xPrice, RSIPeriod) - 50) * RSIHistoModify
//rsiHcolor = iff(RSIMain >= 0 , green,
//        iff(RSIMain < 0, red, black))
pos =iff(RSIMain > BuyAlertLevel, 1,
	    iff(RSIMain < SellAlertLevel, -1, nz(pos[1], 0))) 
//rsiHcolor = pos == -1 ? red: pos == 1 ? green : blue  

//rsiHcolor =iff(RSIMain > BuyAlertLevel, green,	    iff(RSIMain < SellAlertLevel, red, blue)) 
	    
//rsiHcolor =RSIMain < BuyAlertLevel ? red : RSIMain > SellAlertLevel ? green : black


showBB = input(true)
///////////// Bollinger Bands
BBlength = input(10, minval=1,title="Bollinger Bands SMA Period Length")
BBmult = input(1.8, minval=0.001, maxval=50,title="Bollinger Bands Standard Deviation")
BBbasis = sma(RSIMain, BBlength)
BBdev = BBmult * stdev(RSIMain, BBlength)
BBupper = BBbasis + BBdev
BBlower = BBbasis - BBdev

//p1 = plot(showBB?BBupper:na, color=#666666,title="BB Up")
//p2 = plot(showBB?BBlower:na, color=#666666,title="BB Lo")
//fill(p1, p2,color=#ffe6b3)


//pbb2 = plot(showBB?sma(RSIMain, BBlength*2):na, color=#999999,title="BB SMA Bas",transp=0)

// Plot buy alert
//plot(cross(RSIMain,BBbasis)?(RSIMain >BuyAlertLevel ? (RSIMain<RSIMain[1]?RSIMain:na) : RSIMain <SellAlertLevel ?(RSIMain>RSIMain[1]?RSIMain:na):na ) :na,style=cross,linewidth=3,color=RSIMain>0?red:green)

//plot(cross(RSIMain,BBbasis)?(RSIMain >BuyAlertLevel ? (RSIMain<RSIMain[1]?RSIMain:na) : RSIMain <SellAlertLevel ?(RSIMain>RSIMain[1]?RSIMain:na):na ) :na,style=cross,linewidth=3,color=RSIMain>0?red:green)


rsiBarcolor = RSIMain < BuyAlertLevel ? red : RSIMain < 0 ? orange : RSIMain < SellAlertLevel ? olive : green


rsiHcolor =RSIMain < BBbasis ? red : RSIMain > BBbasis ? green : black

plot(showBB?BBbasis:na, color=rsiHcolor,title="BB SMA Bas",transp=0)


//barcolor(pos == -1 ? red: pos == 1 ? green : blue )        
//prsi = plot(RSIMain, color=rsiHcolor, title="RSI HistoAlert")
plot(RSIMain, color=rsiBarcolor, title="Histogram", style = histogram, linewidth  = 5,transp=55)
//plot(cross(RSIMain,0)?RSIMain:na,style=cross,linewidth=3,color=RSIMain>0?green:red)

plot(cross(RSIMain, BBbasis)  ? RSIMain : na, color = black , style = circles, linewidth = 3)
plot(cross(RSIMain, BBbasis)  ? RSIMain : na, color = (RSIMain< BBbasis  ? red : lime) , style = circles, linewidth = 2)

//fill(pbb,prsi,color= BBbasis > RSIMain?red:green)
````
