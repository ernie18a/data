# TSM Donchian Moving Average System_by_ucsgears

- url: https://www.tradingview.com/script/2QlSKxxY-TSM-Donchian-Moving-Average-System-by-ucsgears/
- type: indicator
- pine_id: PUB;1100
- version: -1.0

## Description

This is just the raw code for the system / strategies. 

Will Complete this when I get more time. 

Green - Setup Long
Red - Setup Short

## Source Code

````pine
study("TSM Donchian Moving Average System", overlay = true)

a = input(20, title = "Long Period")
b = input(5, title = "Short Period")
ca = input(1, title = "Band Factor")

// Moving average
malong = sma(close,a)
mashort = sma(close,b)
range = sma(tr, a)*ca
kclupper = malong + range
kcllower = malong - range

kcsupper = mashort + range
kcslower = mashort - range


// PLOT
plot(malong, offset=1, title = "SMA Long")
plot(mashort, offset=1, title = "SMA Short")
plot(kclupper, offset=1, title = "KC Upper")
plot(kcllower, offset=1, title = "KC Lower")

// SETUP 
// LONG 
setuplong = close > kclupper[1] and close > kcsupper[1] ? green : na
setupshort = close < kcllower[1] and close < kcslower[1] ? red : na

barcolor(setuplong)
barcolor(setupshort)

// EXIT
// LONG
//exitlong = close < kclupper[1] and close < kcsupper[1] ? blue : na
//exitshort = close > kcllower[1] and close > kcslower[1] ? orange : na

//barcolor(exitlong)
//barcolor(exitshort)
````
