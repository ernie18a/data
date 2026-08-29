<!-- tradingview-pine-id: PUB;U8G21hxTLANgokqNnyQa5MSgixOW2Ots -->
<!-- tradingviewscripts-format: 1 -->
# Binomial Option Pricing Model

Source: https://www.tradingview.com/script/EjI1iGag-Binomial-Option-Pricing-Model/

## Description

A binomial option pricing model is an option pricing model that calculates an option's price using binomial trees. The BOPM method of calculating option prices is different from the Black-Scholes Model because it provides more flexibility in the type of options you want to price. The BOPM, unlike the BS model typically used for European style options, allows you to price options which have the ability to exercise early, such as American or Bermudan options. Although you can use the BOPM for any option style.

This specific model allows you to price both American and European vanilla options. 

The way the BOPM calculates option prices is by:

First, dividing up the time until expiry into equal parts called steps. This specific model presented only uses 2 steps. For example, say you have an option with an expiry of 60 days, and your binomial tree has only two steps. Then each step will contain 30 days. 

Second, the model will project the expected price of the underlying at the end of each step, called a node. The expected price is calculated by using the underlying's volatility and projecting what the price of the underlying would be if it were to rise and fall. This step is repeated until the terminal node, aka the end of the tree, is reached.

Third, once the terminal node's expected underlying prices are calculated, their expected option prices must be calculated.

Finally, after calculating the terminal option prices, backwards induction must be used to calculate the option prices at the previous nodes, until you reach Node 0, aka the current option price.

In order to use this model:

1st. Enter your option's strike price.
2nd. Enter the risk-free-rate of the currency the option is based in.
3rd. Enter the dividend yield of the underlying if it's a stock, or the foreign risk-free-rate if it's an FX option. 

*For example, if you were trading an AAPL stock option, in the risk-free-rate box mentioned in step 2, you would enter the US risk-free-rate because AAPL options are traded in US dollars. In the dividend yield box mentioned in step 3, you would enter the stock's dividend yield, which for AAPL is 0.82.

*If you were, for example, trading an option on the EUR/JPY currency pair, the risk-free-rate mentioned in step 2, would be the Japanese risk-free-rate. Then in the the dividend yield box from step 3, you'd input the Eurozone risk-free-rate.

*If you were trading an options on futures contract, the risk-free-rate mentioned in step 2, would be the risk-free-rate for whatever currency the futures contract is denominated in. For example EUR futures are denominated in USD, so you would input the US risk-free-rate. Meanwhile, something like FTSE futures are denominated in GBP, so you would input the British risk-free-rate. As for the dividend yield box mentioned in step 3, for all options on futures, enter 0.

4th. Pick what type of underlying the option is based on: stock, FX, or futures.
5th. Pick the style of option: American or European.
6th. Pick the type of option: Long Call or Long Put.
7th. Input your time until expiry. You can express this in terms of days, hours, and minutes.
8th. Lastly, input your chart time-frame in term of minutes. For example, if you're using the 1 min time-frame enter 1, 4hr time-frame enter 480, daily time-frame enter 1440.

*Disclaimer, because this particular model only uses 2 steps, it won't work on stocks with high prices (over $100). If you want to use this on stocks with prices greater than $100, you would need to add more steps to the code, shown below. The model in its current form should work for stocks below $100.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SegaRKO

//@version=4
study("Binomial Option Pricing Model", precision=5)
//Spot Price
S = close

//Your Option Inputs
strike=input(50,minval=0.0000,title="Your Strike Price")
r=input(0.00117, minval=0.000000, title="Risk Free Rate")
q=input(0.0,minval=0.0000000, title="Dividend Yield (Dividend yield is only for stock. For FX Option enter the foreign risk free rate. For an options on futures this value should be 0.)")
asset=input(title="Underlying Asset Class", defval="Stock", options=["Stock", "FX", "Futures"])
style= input(title="Style of Option", defval="American Vanilla", options=["American Vanilla", "European Vanilla"])
type= input(title="Type of Option", defval="Long Call", options=["Long Call", "Long Put"])

//Time Calculations
Minutes = input(0, title="Minutes until expiry")
Hours = input(0, title="Hours until expiry")
Days = input(23, minval=0, title="Days until expiry")
Expiry = (Hours + Minutes / 60) / 24 + Days
TimeFrame = input(1440, minval=0, title="Timeframe in minutes")
len = 252  //Number of Days in a year. 
Time = 60 * 24 * Expiry / TimeFrame
Interval_Width=1
T=Time/len

//Sigma Calculation
sigma=sqrt(variance(S,len))

//Binomial Tree Parameters
stepnum=2 //Number of steps within tree.
deltaT=T/stepnum //Amount of time between each node.

up=exp(sigma*sqrt(deltaT))
down=1/up

a_stock=exp((r-q)*deltaT)
a_futures=1

a= if asset=="Futures"
    a_futures
else if asset=="FX"
    a_stock
else
    a_stock

pup=(a-down)/(up-down) //Probability of Up Move based on sigma
pdown=1-pup //Probability of Down Move based on sigma

//Binomial Tree for European Vanilla Options
//Node 1 Spot Prices
Su1=S*up
Sd1=S*down

//Node 2 Spot Prices
Su2a=Su1*up
Su2b=Su1*down

Sd2a=Sd1*up
Sd2b=Sd1*down


//Binomial Tree Backwards Induction
//Node 2 Option Prices
//Because this tree only has two steps, Node 2 is the terminal node. 
//For terminal nodes their option values is the price of the underlying - strike.
Su2a_Price=Su2a-strike
Su2b_Price=Su2b-strike

Sd2a_Price=Sd2a-strike
Sd2b_Price=Sd2b-strike

//Call Option Logic for Node 2
Cu2a= if Su2a_Price<0
    0
else
    Su2a_Price
Cu2b= if Su2b_Price<0
    0
else
    Su2b_Price
Cd2a= if Sd2a_Price<0
    0
else
    Sd2a_Price
Cd2b= if Sd2b_Price<0
    0
else
    Sd2b_Price

//Put Option Logic for Node 2
Pu2a= if Su2a_Price>0
    0
else
    abs(Su2a_Price)
Pu2b= if Su2b_Price>0
    0
else
    abs(Su2b_Price)
Pd2a= if Sd2a_Price>0
    0
else
    abs(Sd2a_Price)
Pd2b= if Sd2b_Price>0
    0
else
    abs(Sd2b_Price)

//Node 2 Logic
Nu2a= if type=="Long Put"
    Pu2a
else
    Cu2a
Nu2b= if type=="Long Put"
    Pu2b
else
    Cu2b
Nd2a= if type=="Long Put"
    Pd2a
else
    Cd2a
Nd2b= if type=="Long Put"
    Pd2b
else
    Cd2b

//Node 1 European Option Prices
Nu1=(pup*Nu2a+(pdown*Nu2b))*exp(-r*deltaT)
Nd1=(pup*Nu2b+(pdown*Nd2b))*exp(-r*deltaT)

//American Pricing for Node 1
D= if type=="Long Put"
    -1
else
    1

Intrinsic_u1=(Su1-strike)*D
Intrinsic_d1=(Sd1-strike)*D
ANu1=max(Intrinsic_u1,Nu1)
ANd1=max(Intrinsic_d1,Nd1)

//European Pricing for Node 0 
European=(pup*Nu1+(pdown*Nd1))*exp(-r*deltaT)

//American Pricing for Node 0
Intrinsic_0=(S-strike)*D
EDV=(pup*ANu1+(pdown*ANd1))*exp(-r*deltaT)
American=max(Intrinsic_0, EDV)

OptionPrice=if style=="European Vanilla"
    European
else
    American

plot(OptionPrice)
````
