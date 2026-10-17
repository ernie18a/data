# Prime Number Bands Strategy

- url: https://www.tradingview.com/script/etULrfTX-Prime-Number-Bands-Strategy/
- type: indicator
- pine_id: PUB;u76AG1wxgeh4rqFEpDAuxdBskxwyA6wR
- version: 1.0

## Description

Determining market trends has become a science even though a high number 
 or people still believe it’s a gambling game. Mathematicians, technicians, 
 brokers and investors have worked together in developing quite several 
 indicators to help them better understand and forecast market movements.
 The Prime Number Bands indicator was developed by Modulus Financial Engineering 
 Inc. This indicator is charted by indentifying the highest and lowest prime number 
 in the neighborhood and plotting the two series as a band.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 05/03/2018
// Determining market trends has become a science even though a high number 
// or people still believe it’s a gambling game. Mathematicians, technicians, 
// brokers and investors have worked together in developing quite several 
// indicators to help them better understand and forecast market movements.
// The Prime Number Bands indicator was developed by Modulus Financial Engineering 
// Inc. This indicator is charted by indentifying the highest and lowest prime number 
// in the neighborhood and plotting the two series as a band.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
PrimeNumberUpBand(price, percent) =>
    res = 0
    res1 = 0
    for j = price to price + (price * percent / 100)
        res1 := j
	    for i = 2 to sqrt(price)
        	res1 := iff(j % i == 0 , 0, j)
            if res1 == 0 
                break
		if res1 > 0 
		    break
    res := iff(res1 == 0, res[1], res1)
    res

PrimeNumberDnBand(price, percent) =>
    res = 0
    res2 = 0
    for j = price to price - (price * percent / 100)
        res2 := j
	    for i = 2 to sqrt(price)
        	res2 := iff(j % i == 0 , 0, j)
            if res2 == 0 
                break
		if res2 > 0 
		    break
    res := iff(res2 == 0, res[1], res2)
    res

study(title="Prime Number Bands Strategy", overlay = true)
percent = input(5, minval=0.01, step = 0.01, title="Tolerance Percentage")
Length = input(5, minval=1)
srcUp = input(title="Source Up Band", type=source, defval=high)
srcDn = input(title="Source Down Band", type=source, defval=low)
xPNUB = PrimeNumberUpBand(srcUp, percent)
xPNDB = PrimeNumberDnBand(srcDn, percent)
xHighestPNUB = highest(xPNUB, Length)
xLowestPNUB = lowest(xPNDB, Length)
pos = iff(close > xHighestPNUB[1], 1,
       iff(close < xLowestPNUB[1], -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
plot(xHighestPNUB, color=red, title="PNUp")
plot(xLowestPNUB, color=green, title="PNDn")
````
