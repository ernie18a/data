<!-- tradingview-pine-id: PUB;YIjxzmbj0tXQ5hhNQUDP4ZtFnaoHqwB2 -->
<!-- tradingviewscripts-format: 1 -->
# Black-Scholes Model

Source: https://www.tradingview.com/script/dgMumvhd-Black-Scholes-Options-Pricing-Model/

## Description

This is an updated version of my "Black-Scholes Model and Greeks for European Options" indicator, that i previously published. I decided to make this updated version open-source, so people can tweak and improve it.

The Black-Scholes model is a mathematical model used for pricing options. From this model you can derive the theoretical fair value of an options contract. Additionally, you can derive various risk parameters called Greeks. This indicator includes three types of data: Theoretical Option Price (blue), the Greeks (green), and implied volatility (red); their values are presented in that order.

1) Theoretical Option Price:
This first value gives only the theoretical fair value of an option with a given strike based on the Black-Scholes framework. Remember this is a model and does not reflect actual option prices, just the theoretical price based on the Black-Scholes model and its parameters and assumptions.

2)Greeks (all of the Greeks included in this indicator are listed below):

a)Delta is the rate of change of the theoretical option price with respect to the change in the underlying's price. This can also be used to approximate the probability of your option expiring in the money. For example, if you have an option with a delta of 0.62, then it has about a 62% chance of expiring in-the-money. This number runs from 0 to 1 for Calls, and 0 to -1 for Puts.

b)Gamma is the rate of change of delta with respect to the change in the underlying's price.

c)Theta, aka "time decay", is the rate of change in the theoretical option price with respect to the change in time. Theta tells you how much an option will lose its value day by day.

d) Vega is the rate of change in the theoretical option price with respect to change in implied volatility .

e)Rho is the rate of change in the theoretical option price with respect to change in the risk-free rate. Rho is rarely used because it is the parameter that options are least effected by, it is more useful for longer term options, like LEAPs.

f)Vanna is the sensitivity of delta to changes in implied volatility . Vanna is useful for checking the effectiveness of delta-hedged and vega-hedged portfolios.

g)Charm, aka "delta decay", is the instantaneous rate of change of delta over time. Charm is useful for monitoring delta-hedged positions.

h)Vomma measures the sensitivity of vega to changes in implied volatility .

i)Veta measures the rate of change in vega with respect to time.

j)Vera measures the rate of change of rho with respect to implied volatility .

k)Speed measures the rate of change in gamma with respect to changes in the underlying's price. Speed can be used when evaluating delta-hedged and gamma hedged portfolios.

l)Zomma measures the rate of change in gamma with respect to changes in implied volatility . Zomma can be used to evaluate the effectiveness of a gamma-hedged portfolio.

m)Color, aka "gamma decay", measures the rate of change of gamma over time. This can also be used to evaluate the effectiveness of a gamma-hedged portfolio.

n)Ultima measures the rate of change in vomma with respect to implied volatility .

o)Probability of Touch, is not a Greek, but a metric that I included, which tells you the probability of price touching your strike price before expiry.

3) Implied Volatility:
This is the market's forecast of future volatility . Implied volatility is directionless, it cannot be used to forecast future direction. All it tells you is the forecast for future volatility.

How to use this indicator:
1st. Input the strike price of your option. If you input a strike that is more than 3 standard deviations away from the current price, the model will return a value of n/a.
2nd. Input the current risk-free rate.(Including this is optional, because the risk-free rate is so small, you can just leave this number at zero.)
3rd. Input the time until expiry. You can enter this in terms of days, hours, and minutes.
4th.Input the chart time frame you are using in terms of minutes. For example if you're using the 1min time frame input 1, 4 hr time frame input 480, daily time frame input 1440, etc.
5th. Pick what style of option you want data for, European Vanilla or Binary.
6th. Pick what type of option you want data for, Long Call or Long Put.
7th . Finally, pick which Greek you want displayed from the drop-down list.

*Remember the Option price presented, and the Greeks presented, are theoretical in nature, and not based upon actual option prices. Also, remember the Black-Scholes model is just a model based upon various parameters, it is not an actual representation of reality, only a theoretical one.

*Note 1. If you choose binary, only data for Long Binary Calls will be presented. All of the Greeks for Long Binary Calls are available, except for rho and vera because they are negligible.

*Note 2. Unlike vanilla european options, the delta of a binary option cannot be used to approximate the probability of the option expiring in-the-money. For binary options, if you want to approximate the probability of the binary option expiring in-the-money, use the price. The price of a binary option can be used to approximate its probability of expiring in-the-money. So if a binary option has a price of $40, then it has approximately a 40% chance of expiring in-the-money.

*Note 3. As time goes on you will have to update the expiry, this model does not do that automatically. So for example, if you originally have an option with 30 days to expiry, tomorrow you would have to manually update that to 29 days, then the next day manually update the expiry to 28, and so on and so forth.

There are various formulas that you can use to calculate the Greeks. I specifically chose the formulations included in this indicator because the Greeks that it presents are the closest to actual options data. I compared the Greeks given by this indicator to brokerage option data on a variety of asset classes from equity index future options to FX options and more. Because the indicator does not use actual option prices, its Greeks do not match the brokerage data exactly, but are close enough.

I may try to make future updates that include data for Long Binary Puts, American Options, Asian Options, etc.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © SegaRKO

//@version=4
study("Black-Scholes Model", precision=10)
 
spot = close
strike = input(1.375,"Strike Price",minval=0.0000001)
riskfreerate=input(title="Option Base Currency",defval="USD", options=["USD","GBP","JPY","CAD","CNH","SGD","INR","AUD","SEK","NOK","DKK"])

Bond_Yield= if riskfreerate=="USD"
    "US10Y"
else if riskfreerate=="GBP"
    "GB10Y"
else if riskfreerate=="JPY"
    "JP10Y"
else if riskfreerate=="CAD"
    "CA10Y"
else if riskfreerate=="CNH"
    "CN10Y"
else if riskfreerate=="SGD"
    "SG10Y"
else if riskfreerate=="INR"
    "IN10Y" 
else if riskfreerate=="AUD"
    "AU10Y"
else if riskfreerate=="SEK"
    "SE10Y"
else if riskfreerate=="NOK"
    "NO10Y"
else if riskfreerate=="DKK"
    "DK10Y"
r=security(Bond_Yield,timeframe.period,spot)/100
Minutes = input(0, title="Minutes until expiry")
Hours = input(0, title="Hours until expiry")*60
Days = input(33, minval=0, title="Days until expiry")+((Hours+Minutes)/1440)
iv_input=input(0.000,"Implied Volatility % [Recommended to supply your own IV if Your expiry is greater than 100 days]")/100
IV_provider = input(title="Do you want to use your own IV or indicator-calculated IV?",defval="Indicator Calculated", options=["Indicator Calculated","Own IV"])
geo_length=input(31,minval=0,title="Number of Candles until expiry (Asian Geometric Only)")
style= input(title="Style of Option", defval="European Vanilla", options=["European Vanilla", "Binary", "Asian Geometric"])
type= input(title="Type of Option", defval="Long Call", options=["Long Call", "Long Put"])

LogReturn = log(spot[1] / spot[2])
Average = sma(LogReturn, Days)
STDEV = stdev(LogReturn, Days)
Time_Average = Days * Average
Time_STDEV = STDEV * sqrt(Days)
Interval_Width=1
upper = spot * exp(Time_Average + Interval_Width * Time_STDEV)
lower = spot * exp(Time_Average - Interval_Width * Time_STDEV)

width = upper - lower
standard_dev = width / 2
//Optimizer
sig =(standard_dev / (spot * sqrt(Days/365)))

sigma=if IV_provider=="Own IV"
    iv_input
else
    sig
Time = Days/365    


//Gaussian Probability Function with mean 0.0 and stdev 1.0 at given parameter
phi(x)=>
    exp(-x * x / 2.0) / sqrt(2*3.14159265359)

//Gaussian Probability Function with mean and stdev at given parameter 
pdf(x)=>
    mu=0.0
    pdf_sigma=1.0
    phi((x - mu) / pdf_sigma) / pdf_sigma

//Gaussian Distribution function with mean 0.0 and stdev 1.0 at given parameter
Phi(z) =>
    total = 0.0
    term=z
    for i=3 to 300 by 2
        if total!=(total+term)
            total:=total+term
            term:=term*(z*z/float(i))
            continue
        else
            break
    if z<-8.0
        0.0
    else if z>8.0
        1.0
    else
        0.5+total*phi(z)

//Standard Guassian Cumulative Distribution Function
cdf(z)=>
    mu=0.0
    cdf_sigma=1.0
    Phi((z - mu) / cdf_sigma) 
    
callPrice(s, x, r, sigma, t)=>
    a = (log(s/x) + (r + sigma * sigma/2.0) * t) / (sigma * sqrt(t))
    b = a - sigma * sqrt(t)
    s * cdf(a) - x * exp(-r * t) * cdf(b)

putPrice(s, x, r, sigma, t)=>
    a = (log(s/x) + (r + sigma * sigma/2.0) * t) / (sigma * sqrt(t))
    b = a - sigma * sqrt(t)
    x * exp(-r * t) * (1-cdf(b))-s*(1-cdf(a))

BSCallPrice=callPrice(spot, strike, r, sigma, Time)
BSPutPrice=putPrice(spot, strike, r, sigma, Time)

if BSCallPrice<0.0
    BSCallPrice:=0.0

if BSPutPrice<0.0
    BSPutPrice:=0.0

OptionPrice= if type=="Long Put"
    BSPutPrice
else
    BSCallPrice

//Greeks
d1 = (log(spot/strike) + (r + sigma * sigma/2.0) * Time) / (sigma * sqrt(Time))
d2 = d1 - sigma * sqrt(Time)
Nd1=cdf(d1)
Nd2=cdf(d2)
PVK=strike*exp(-r*Time)
//1st Order greeks
deltac=exp(-r*Time)*Nd1
deltap=-(1-(exp(-r*Time)*Nd1))

if deltac>1.0
    deltac:=1.0
else if deltac<0.0
    deltac:=0.0
else
    deltac
if deltap>0.0
    deltap:=0.0
else if deltap<-1.0
    deltap:=-1.0
else
    deltap
    
delta=if type=="Long Put"
    deltap
else
    deltac


vega=strike*exp(r*Time)*phi(d2)*sqrt(Time)
theta=(-((spot*Nd1*sigma)/(2*sqrt(Time)))-(r*PVK*Nd2))/365

rhoc=strike*Time*exp(r*Time)*Nd2
rhop=-(strike)*Time*exp(r*Time)*(1-Nd2)
rho= if type=="Long Put"
    rhop
else
    rhoc

//2nd Order Greeks
gamma=PVK*(phi(d2)/(pow(spot,2)*sigma*sqrt(Time)))
vanna=(vega/spot)*(1-(d1/(sigma*sqrt(Time))))
vomma=vega*((d1*d2)/sigma)
charm=-(change(theta)/change(spot))/365
veta=((-1*theta)*(1/vega)*(1/sigma)*change(vega))/(36500)
vera=((change(rho))/(change(sigma)))

//3rd Order Greeks
speed=-(gamma/spot)*((d1/(sigma*sqrt(Time)))+1)
zomma=gamma*((d1*d2-1)/sigma)
color_greek=(gamma*theta*(1/vega)*(1/change(sigma)))/365
ultima=change(vomma)/change(sigma)

//Probability of touch. This is typically 2*Probability of ITM. And since delta can be used to approximate proability of ITM. POT will be calculated as below.
pot=abs((2*delta)*100)
touch=if pot>99.9
    99.9
else
    pot

//Binary Pricing
BinaryPrice=abs(delta*100)//The price of a binary option is equivalent to the delta of a comparable vanilla option.
//1st order Binary Greeks (Gamma is 2nd order, but is incuded here because t it is necessary to calculate theta)
binary_delta=if type=="Long Put" //The delta of a binary option is equivalent to the gamma of a comparable vanilla option.
    -(gamma/100) 
else
    gamma/100
binary_gamma=abs(speed)/100
binary_theta=(-0.5*binary_gamma*pow(sigma,2)*pow(spot,2))/365
binary_vega=vomma

//2nd order Binary Greeks
binary_charm=-(change(binary_theta)/change(spot))/365
binary_vanna=abs((change(binary_delta)/change(sigma)))
binary_vomma=change(binary_vega)/change(sigma)
binary_veta=((-1*binary_theta)*(1/binary_vega)*(1/sigma)*change(binary_vega))/(36500)

//3rd order Binary Greeks
binary_speed=change(binary_gamma)/change(spot)
binary_zomma=change(binary_vanna)/change(spot)
binary_color_greek=(binary_gamma*binary_theta*(1/binary_vega)*(1/change(sigma)))/365
binary_ultima=(change(binary_vomma)/change(sigma)) 
     

//Asian Pricing:
//Geometric Average Calculation
my_gma(price, length) =>
    product = price
    for i = 1 to length-1
        product := product * price[i]
    product
exponent=1/geo_length
gma=pow(my_gma(close,geo_length),exponent)
//

geo_stdev=STDEV/sqrt(3)
b=0.5*(r-(0.5*pow(geo_stdev,2)))
GACall=abs((spot*exp(-(r*pow(sigma,2)/6)*(Time/2))*Nd1)-(PVK*Nd2))
GAPut=abs(GACall - ((spot*exp((b-r)*Time)) - PVK))

GAPrice= if type=="Long Put"
    GAPut
else
    GACall

//1st Order Asian Geomentric Greeks (Gamma is 2nd order, but is incuded here because t it is necessary to calculate theta)
GAdeltac=abs(change(GAPrice)/change(spot))

GAdelta = if type=="Long Put"
    -(abs(change(GAPrice)/change(spot)))
else
    GAdeltac

GAvega1=abs(change(GAPrice)/change(sigma))
GAvega2=vega/sqrt(3) //The Vega of an ATM Asian option is equal to the Vega of a comparable European Vanilla/sqrt(3) 
GAvega = if gma==strike
    GAvega2
else
    GAvega1
GAgamma=PVK*(phi(d2)/(pow(spot,2)*sigma*sqrt(Time)))
GAtheta=(-0.5*GAgamma*pow(sigma,2)*pow(spot,2))/365

//2nd order Asian Geomentric Greeks
GAcharm=-(change(GAtheta)/change(spot))/365
GAvanna=abs((change(GAdelta)/change(sigma)))
GAvomma=change(GAvega)/change(sigma)
GAveta=((-1*GAtheta)*(1/GAvega)*(1/sigma)*change(GAvega))/(36500)

//3rd order Asian Geomentric Greeks
GAspeed=change(GAgamma)/change(spot)
GAzomma=change(GAvanna)/change(spot)
GA_color_greek=(GAgamma*GAtheta*(1/GAvega)*(1/change(sigma)))/365
GAultima=(change(GAvomma)/change(sigma)) 

//Greek choices
greek_choice=input(title="Choose Greek", defval="Delta", options=["Delta", "Gamma", "Theta", "Vega", "Rho", "Vanna", "Charm", "Vomma",  "Veta", "Vera", "Speed", "Zomma", "Color", "Ultima", "Probability of Touch"])

Vanilla_Greeks=iff(greek_choice=="Delta",delta,
     iff(greek_choice=="Gamma",gamma,
     iff(greek_choice=="Theta",theta,
     iff(greek_choice=="Vega",vega,
     iff(greek_choice=="Rho",rho,
     iff(greek_choice=="Vanna",vanna,
     iff(greek_choice=="Charm",charm,
     iff(greek_choice=="Vomma",vomma,
     iff(greek_choice=="Veta",veta,
     iff(greek_choice=="Vera",vera,
     iff(greek_choice=="Speed",speed,
     iff(greek_choice=="Zomma",zomma,
     iff(greek_choice=="Color",color_greek,
     iff(greek_choice=="Ultima",ultima,
     iff(greek_choice=="Probability of Touch",touch,
     delta)))))))))))))))

Binary_Greeks=iff(greek_choice=="Delta",binary_delta,
     iff(greek_choice=="Gamma",binary_gamma,
     iff(greek_choice=="Theta",binary_theta,
     iff(greek_choice=="Vega",binary_vega,
     iff(greek_choice=="Rho",0,
     iff(greek_choice=="Vanna",binary_vanna,
     iff(greek_choice=="Charm",binary_charm,
     iff(greek_choice=="Vomma",binary_vomma,
     iff(greek_choice=="Veta",binary_veta,
     iff(greek_choice=="Vera",0,
     iff(greek_choice=="Speed",binary_speed,
     iff(greek_choice=="Zomma",binary_zomma,
     iff(greek_choice=="Color",binary_color_greek,
     iff(greek_choice=="Ultima",binary_ultima,
     iff(greek_choice=="Probability of Touch",touch,
     binary_delta)))))))))))))))

Geometric_Greeks=iff(greek_choice=="Delta",GAdelta,
     iff(greek_choice=="Gamma",GAgamma,
     iff(greek_choice=="Theta",GAtheta,
     iff(greek_choice=="Vega",GAvega,
     iff(greek_choice=="Rho",0,
     iff(greek_choice=="Vanna",GAvanna,
     iff(greek_choice=="Charm",GAcharm,
     iff(greek_choice=="Vomma",GAvomma,
     iff(greek_choice=="Veta",GAveta,
     iff(greek_choice=="Vera",0,
     iff(greek_choice=="Speed",GAspeed,
     iff(greek_choice=="Zomma",GAzomma,
     iff(greek_choice=="Color",GA_color_greek,
     iff(greek_choice=="Ultima",GAultima,
     iff(greek_choice=="Probability of Touch",0,
     binary_delta)))))))))))))))

//Which Greeks will be presented: Vanilla or Long Binary Call
Greeks=if style=="Binary"
    Binary_Greeks
else if style=="Asian Geometric"
    Geometric_Greeks
else
    Vanilla_Greeks

//Which Price will be presented: Vanilla or Long Binary Call
Price = if style=="Binary"
    BinaryPrice 
else if style=="Asian Geometric"
    GAPrice //Geometric Average Asian Option Price
else
    OptionPrice //This is the vanilla option price.

//Plot Arguments
plot(Price, title="Theoretical Option Value")
plot(Greeks,title="Greeks", color=color.green)
plot(sigma*100, title="Implied volatility", color=color.red)
````
