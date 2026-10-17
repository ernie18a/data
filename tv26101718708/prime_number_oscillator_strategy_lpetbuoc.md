# Prime Number Oscillator Strategy

- url: https://www.tradingview.com/script/lPetBuoc-Prime-Number-Oscillator-Strategy/
- type: indicator
- pine_id: PUB;LW4GZUkJzVJJBwt6S4jOwS8mQxe7n7Cz
- version: 1.0

## Description

Determining market trends has become a science even though a high number or people 
 still believe it’s a gambling game. Mathematicians, technicians, brokers and investors 
 have worked together in developing quite several indicators to help them better understand 
 and forecast market movements.

 Developed by Modulus Financial Engineering Inc., the prime number oscillator indicates the 
 nearest prime number, be it at the top or the bottom of the series, and outlines the 
 difference between that prime number and the respective series.

 WARNING:
 - This script to change bars colors.

## Source Code

````pine
//@version=2
////////////////////////////////////////////////////////////
//  Copyright by HPotter v1.0 29/03/2018
// Determining market trends has become a science even though a high number or people 
// still believe it’s a gambling game. Mathematicians, technicians, brokers and investors 
// have worked together in developing quite several indicators to help them better understand 
// and forecast market movements.
//
// Developed by Modulus Financial Engineering Inc., the prime number oscillator indicates the 
// nearest prime number, be it at the top or the bottom of the series, and outlines the 
// difference between that prime number and the respective series.
//
// WARNING:
// - This script to change bars colors.
////////////////////////////////////////////////////////////
PrimeNumberOscillator(price, percent) =>
    res = 0
    res1 = 0
    res2 = 0
    for j = price to price + (price * percent / 100)
        res1 := j
	    for i = 2 to sqrt(price)
        	res1 := iff(j % i == 0 , 0, j)
            if res1 == 0 
                break
		if res1 > 0 
		    break
    for j = price to price - (price * percent / 100)
        res2 := j
	    for i = 2 to sqrt(price)
        	res2 := iff(j % i == 0 , 0, j)
            if res2 == 0 
                break
		if res2 > 0 
		    break
    res := iff(res1 - price < price - res2,  res1 - price, res2 - price)
    res := iff(res == 0, res[1], res)
    res
    
study(title="Prime Number Oscillator Strategy")
percent = input(5, minval=0.01, step = 0.01, title="Tolerance Percentage")
xPNO = PrimeNumberOscillator(close, percent)
pos = iff(xPNO > 0, 1,
       iff(xPNO < 0, -1, nz(pos[1], 0))) 
barcolor(pos == -1 ? red: pos == 1 ? green : blue )
clr = iff(xPNO > 0, green, red)
p1 = plot(xPNO, color=blue, title="KPO")
p2 = plot(0, color=black, title="0")
fill(p1,p2,color=clr)
````
