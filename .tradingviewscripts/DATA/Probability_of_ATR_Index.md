<!-- tradingview-pine-id: PUB;RQIytRSurbASZndobLAth4QS00RoyyqD -->
<!-- tradingviewscripts-format: 1 -->
# Probability of ATR Index

Source: https://www.tradingview.com/script/P0H2AFk4-Probability-of-ATR-Index-racer8/

## Description

Deriving the indicator:

PAI is an indicator I created that tells you the probability of current price moving a specified ATR distance over a specified number of periods into the future. It takes into account 4 variables: the ATR  & the standard deviation of price, and the 2 parameters: ATR distance and # bars (time).
The formula is very complex so I will not be able to explain it without confusion arising.

What I can say is that I used integral calculus & the Taylor series to derive a formula that calculates the area under half of the normal distribution function. Thus, the formula was repeated twice in the code to derive the full probability (half + half = whole). If you can read the code, you might be wondering why the formula is so long...

The reason for this is because in Pine Script, the erf function doesn't exist. You see, the formula for normal distribution is: f(x) = (1/sqrt(2pi))*e^(-xx/2), assuming of course that the standard deviation = 1 and mu (mean) = 1. The next step is to take the integral of this formula in order to find the area under f(x). The problem is that I found the integral, F(x), of the normal distribution formula to be equal to F(x) = erf(x/sqrt(2))/2...and the erf function cannot be directly computed into Pinescript. 

So I developed a solution...why not estimate the integral function? So that's exactly what I did using a technique involving the Taylor series. The Taylor series is an algebraic function that allows you to create a new function that can estimate the existing function. On a graph, the new function has the same values as the existing one, the only difference is that it uses a differnt formula, in this case, a formula that makes it possible to compute the integral. The disadvantage of using this new formula is that it is super long and if you want it to better represent the original integral over a wider range of x-values, you have to make it longer. 

Signal Interpretion: 
The hotter the colour, the more likely price will reach your specified distance.
The 2 values of PAI in the bottom window represent probability & average probability of your specifed distance geting hit.

Applications:
Stop loss placement---
This indicator is useful because it gives you an idea of the likelihood that a stop loss at a particular distance away from price (in ATRs) will be hit over a period of time specified. This is helpful in placing stop losses.
Options trading---
PAI can also be used in options trading. For example, you are using a strangle options strategy, and you want to make sure that price stays within the Strangle's profit range. So you only trade when PAI presents a low probability value of moving at a particular distance in ATRs over n periods.

Anyhow, I hope you guys like it. Enjoy! and hit that like button for me :)

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © racer8
//@version=4
study("Probability of ATR Index","PAI 💙",precision=0)

//---------------------------------------- Inputs & calculate ATR -----------------------------------------------------------

m = input(1.5,"ATR (distance)",minval=0)
n = input(8,"# Bars (time)",minval=1)
p = max(8,n)
r = atr(p)

//------------------------ Calculate standard deviation of high & low for each period ----------------------------------------

sum = 0.0                           
for i = 0 to p-1
    sum := sum + high[i] + low[i]
u = sum/(2*p) 
SUM = 0.0
for I = 0 to p-1
    SUM := SUM + pow((high[I]-u),2) + pow((low[I]-u),2)
v = SUM/(2*p)
a = sqrt(v)

//----------------------------- Input for probability function (based on all previous inputs) -------------------------------------

d = (m*r)/(n*a)     
x = d>=0? d:na

//------------------------------------------ Probability function -------------------------------------------------------------

a1 = 0.278393
a2 = 0.230389
a3 = 0.000972
a4 = 0.078108

z = x/sqrt(2) 
de = 1 + a1*z + a2*pow(z,2) + a3*pow(z,3) + a4*pow(z,4) 
den = pow(de,4)
Fx = 0.5*(1 - 1/den)

z2 = 100/sqrt(2) 
de2 = 1 + a1*z2 + a2*pow(z2,2) + a3*pow(z2,3) + a4*pow(z2,4) 
den2 = pow(de2,4)
Fx2 = 0.5*(1 - 1/den2)

P = 100*(1 - ( Fx + Fx2 ))   

//---------------------------------------------- Plotting & colors ------------------------------------------------------------------------

Ma = sma(P,1000)
plot(P,color=color.blue,style=plot.style_line,title="Current Probability",transp=0)
plot(Ma,color=color.yellow,style=plot.style_circles,title="Average Probability",transp=0)

co(P) =>            
    if P>40 
        color.red
    else if P>30
        color.orange
    else if P>20
        color.yellow
    else if P>10 
        color.blue
    else if P>0
        color.purple
    
barcolor(co(P))


//   @@@@  @@@@
//  @@@@@@@@@@@@
//   @@@@@@@@@@   
//     @@@@@@
//       @@
````
