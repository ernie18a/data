<!-- tradingview-pine-id: PUB;12d143e9b2d942babee332077b83ac87 -->
<!-- tradingviewscripts-format: 1 -->
# Black Scholes Option Pricing Model w/ Greeks [Loxx]

Source: https://www.tradingview.com/script/WobQqSxF-Black-Scholes-Option-Pricing-Model-w-Greeks-Loxx/

## Description

The Black Scholes Merton model
If you are new to options I strongly advise you to profit from [Robert Shiller's lecture on same](https://oyc.yale.edu/economics/econ-252-11/lecture-17). It combines practical market insights with a strong authoritative grasp of key models in option theory. He explains many of the areas covered below and in the following pages with a lot intuition and relatable anecdotage. We start here with Black Scholes Merton which is probably the most popular option pricing framework, due largely to its simplicity and ease in terms of implementation. The closed-form solution is efficient in terms of speed and always compares favorably relative to any numerical technique. [The Black–Scholes–Merton model](http://new.math.msu.su/department/probab/os/spec/Materialy_po_kursam_Tutubalina/Pril_ver_met/Black%26Scholes/Black%26Scholes.pdf) is a mathematical go-to model for estimating the value of European calls and puts. In the early 1970’s, Myron Scholes, and Fisher Black made an important breakthrough in the pricing of complex financial instruments. Robert Merton simultaneously was working on the same problem and applied the term Black-Scholes model to describe new generation of pricing. The Black Scholes (1973) contribution developed insights originally proposed by Bachelier 70 years before. In 1997, Myron Scholes and Robert Merton received the Nobel Prize for Economics. Tragically, Fisher Black died in 1995. The Black–Scholes formula presents a theoretical estimate (or model estimate) of the price of European-style options independently of the risk of the underlying security. Future payoffs from options can be discounted using the risk-neutral rate. Earlier academic work on options (e.g., Malkiel and Quandt 1968, 1969) had contemplated using either empirical, econometric analyses or elaborate theoretical models that possessed parameters whose values could not be calibrated directly. In contrast, Black, Scholes, and Merton’s parameters were at their core simple and did not involve references to utility or to the shifting risk appetite of investors. Below, we present a standard type formula, where: c = Call option value, p = Put option value, S=Current stock (or other underlying) price, K or X=Strike price, r=Risk-free interest rate, q = dividend yield, T=Time to maturity and N denotes taking the normal cumulative probability. b = (r - q) = cost of carry. (via [VinegarHill-Financelab](https://sites.google.com/view/vinegarhill-financelabs/black-scholes-merton))

Things to know

[*]This can only be used on the daily timeframe
[*]You must select the option type and the greeks you wish to show
[*]This indicator is a work in process, functions may be updated in the future. I will also be adding additional greeks as I code them or they become available in finance literature. This indictor contains 18 greeks. Many more will be added later.

Inputs

[*]Spot price: select from 33 different types of price inputs
[*]Calculation Steps: how many iterations to be used in the BS model. In practice, this number would be anywhere from 5000 to 15000, for our purposes here, this is limited to 300
[*]Strike Price: the strike price of the option you're wishing to model
[*]% Implied Volatility: here you can manually enter implied volatility
[*]Historical Volatility Period: the input period for historical volatility ; historical volatility isn't used in the BS process, this is to serve as a sort of benchmark for the implied volatility ,
[*]Historical Volatility Type: choose from various types of implied volatility , search my indicators for details on each of these
[*]Option Base Currency: this is to calculate the risk-free rate, this is used if you wish to automatically calculate the risk-free rate instead of using the manual input. this uses the 10 year bold yield of the corresponding country
[*]% Manual Risk-free Rate: here you can manually enter the risk-free rate
[*]Use manual input for Risk-free Rate? : choose manual or automatic for risk-free rate
[*]% Manual Yearly Dividend Yield: here you can manually enter the yearly dividend yield
[*]Adjust for Dividends?: choose if you even want to use use dividends
[*]Automatically Calculate Yearly Dividend Yield? choose if you want to use automatic vs manual dividend yield calculation
[*]Time Now Type: choose how you want to calculate time right now, see the tool tip
[*]Days in Year: choose how many days in the year, 365 for all days, 252 for trading days, etc
[*]Hours Per Day: how many hours per day? 24, 8 working hours, or 6.5 trading hours
[*]Expiry date settings: here you can specify the exact time the option expires

The Black Scholes Greeks
The Option Greek formulae express the change in the option price with respect to a parameter change taking as fixed all the other inputs. ([Haug explores multiple  parameter changes at once](https://books.google.ie/books/about/The_Complete_Guide_to_Option_Pricing_For.html?id=tuoJAQAAMAAJ&redir_esc=y).) One significant use of Greek measures is to calibrate risk exposure. A market-making financial institution with a portfolio of options, for instance, would want a snap shot of its exposure to asset price, interest rates, dividend fluctuations. It would try to establish impacts of volatility and time decay. In the formulae below, the Greeks merely evaluate change to only one input at a time. In reality, we might expect a conflagration of changes in interest rates and stock prices etc. (via [VigengarHill-Financelab](https://sites.google.com/view/vinegarhill-financelabs/black-scholes-merton/black-scholes-greeks))

First-order Greeks
Delta:  Delta measures the rate of change of the theoretical option value with respect to changes in the underlying asset's price. Delta is the first derivative of the value 

Vega:  Vegameasures sensitivity to volatility. Vega is the derivative of the option value with respect to the volatility of the underlying asset.

Theta: Theta measures the sensitivity of the value of the derivative to the passage of time (see Option time value): the "time decay."

Rho:  Rho measures sensitivity to the interest rate: it is the derivative of the option value with respect to the risk free interest rate (for the relevant outstanding term).

Lambda:  Lambda, Omega, or elasticity is the percentage change in option value per percentage change in the underlying price, a measure of leverage, sometimes called gearing.

Epsilon:  Epsilon, also known as psi, is the percentage change in option value per percentage change in the underlying dividend yield, a measure of the dividend risk. The dividend yield impact is in practice determined using a 10% increase in those yields. Obviously, this sensitivity can only be applied to derivative instruments of equity products.

Second-order Greeks
Gamma:  Measures the rate of change in the delta with respect to changes in the underlying price. Gamma is the second derivative of the value function with respect to the underlying price.

Vanna:  Vanna, also referred to as DvegaDspot and DdeltaDvol, is a second order derivative of the option value, once to the underlying spot price and once to volatility. It is mathematically equivalent to DdeltaDvol, the sensitivity of the option delta with respect to change in volatility; or alternatively, the partial of vega with respect to the underlying instrument's price. Vanna can be a useful sensitivity to monitor when maintaining a delta- or vega-hedged portfolio as vanna will help the trader to anticipate changes to the effectiveness of a delta-hedge as volatility changes or the effectiveness of a vega-hedge against change in the underlying spot price.

Charm:  Charm or delta decay  measures the instantaneous rate of change of delta over the passage of time.

Vomma:  Vomma, volga, vega convexity, or DvegaDvol measures second order sensitivity to volatility. Vomma is the second derivative of the option value with respect to the volatility, or, stated another way, vomma measures the rate of change to vega as volatility changes.

Veta:  Veta or DvegaDtime measures the rate of change in the vega with respect to the passage of time. Veta is the second derivative of the value function; once to volatility and once to time.

Vera: Vera (sometimes rhova) measures the rate of change in rho with respect to volatility. Vera is the second derivative of the value function; once to volatility and once to interest rate.

Third-order Greeks
Speed:  Speed measures the rate of change in Gamma with respect to changes in the underlying price.

Zomma:  Zomma measures the rate of change of gamma with respect to changes in volatility.

Color:  Color, gamma decay or DgammaDtime measures the rate of change of gamma over the passage of time.

Ultima:  Ultima measures the sensitivity of the option vomma with respect to change in volatility.

Dual Delta:  Dual Delta determines how the option price changes in relation to the change in the option strike price; it is the first derivative of the option price relative to the option strike price

Dual Gamma: Dual Gamma determines by how much the coefficient will changedual delta when the option strike price changes; it is the second derivative of the option price relative to the option strike price.

Related Indicators
Cox-Ross-Rubinstein Binomial Tree Options Pricing Model [Loxx]
[chart]https://www.tradingview.com/script/hw252XKE-Cox-Ross-Rubinstein-Binomial-Tree-Options-Pricing-Model-Loxx/[/chart]

Implied Volatility Estimator using Black Scholes [Loxx]
[chart]https://www.tradingview.com/script/xT4abuhx-Implied-Volatility-Estimator-using-Black-Scholes-Loxx/[/chart]

Boyle Trinomial Options Pricing Model [Loxx]
[chart]https://www.tradingview.com/script/IgEbTjmh-Boyle-Trinomial-Options-Pricing-Model-Loxx/[/chart]

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © loxx

//@version=5
indicator("Black Scholes Option Pricing Model w/ Greeks [Loxx]", 
     shorttitle ="BSOPMG",
     overlay = true, 
     max_lines_count = 500)

if not timeframe.isdaily
    runtime.error("Error: Invald timeframe. Indicator only works on daily timeframe.") 

import loxx/loxxexpandedsourcetypes/4

//constants
color darkGreenColor = #1B7E02 
string callString = "Call"
string putString = "Put"

string rogersatch = "Roger-Satchell"
string parkinson = "Parkinson"
string c2c = "Close-to-Close"
string gkvol = "Garman-Klass"
string gkzhvol = "Garman-Klass-Yang-Zhang"
string ewmavolstr = "Exponential Weighted Moving Average"

string timtoolbar= "Time Now = Current time in UNIX format. It is the number of milliseconds that have elapsed since 00:00:00 UTC, 1 January 1970."
string timtoolnow = "Time Bar = The time function returns the UNIX time of the current bar for the specified timeframe and session or NaN if the time point is out of session."
string timetooltrade = "Trading Day = The beginning time of the trading day the current bar belongs to, in UNIX format (the number of milliseconds that have elapsed since 00:00:00 UTC, 1 January 1970)."

ewmavol(float src, int per) => 
    float lambda = (per - 1) / (per + 1)
    float temp = na
    temp := lambda * nz(temp[1], math.pow(src, 2)) + (1.0 - lambda) * math.pow(src, 2)
    out = math.sqrt(temp)
    out
    
rogerssatchel(int per) =>
    float sum = math.sum(math.log(high/ close) * math.log(high / open)
         + math.log(low / close) * math.log(low / open), per) / per
    float out = math.sqrt(sum) 
    out

closetoclose(float src, int per) => 
    float avg = ta.sma(src, per)
    float[] sarr = array.new_float(0)
    for i = 0 to per - 1 
        array.push(sarr, math.pow(nz(src[i]) - avg, 2))
    float out = math.sqrt(array.sum(sarr) / (per - 1))
    out 

parkinsonvol(int per)=>
    float volConst = 1.0 / (4.0 * per * math.log(2))
    float sum = volConst * math.sum(math.pow(math.log(high / low), 2), per)
    float out = math.sqrt(sum) 
    out

garmanKlass(int per)=>
    float hllog = math.log(high / low)
    float oplog = math.log(close / open)
    float garmult = (2 * math.log(2) - 1)
    float parkinsonsum = 1 / (2 * per) * math.sum(math.pow(hllog, 2), per)
    float garmansum = garmult / per * math.sum(math.pow(oplog, 2), per)
    float sum = parkinsonsum - garmansum
    float devpercent = math.sqrt(sum)  
    devpercent

gkyzvol(int per)=>
    float gzkylog = math.log(open / nz(close[1]))
    float pklog = math.log(high / low)
    float gklog = math.log(close / open)
    float garmult = (2 * math.log(2) - 1)
    float gkyzsum = 1 / per * math.sum(math.pow(gzkylog, 2), per)
    float parkinsonsum = 1 / (2 * per) * math.sum(math.pow(pklog, 2), per)
    float garmansum = garmult / per * math.sum(math.pow(gklog, 2), per)
    float sum = gkyzsum + parkinsonsum - garmansum
    float devpercent = math.sqrt(sum)  
    devpercent

f_tickFormat() =>
    _s = str.tostring(syminfo.mintick)
    _s := str.replace_all(_s, '25', '00')
    _s := str.replace_all(_s, '5', '0')
    _s := str.replace_all(_s, '1', '0')
    _s

// N(0,1) density
f(float x)=> 
    float out = math.exp(-x * x * 0.5) / math.sqrt(2 * math.pi)
    out 

// Boole's Rule
Boole(float StartPoint, float EndPoint, int n)=>
    float[] X = array.new<float>(n + 1 , 0)
    float[] Y = array.new<float>(n + 1 , 0)
    float delta_x = (EndPoint - StartPoint) / n
    for i = 0 to n
        array.set(X, i, StartPoint + i * delta_x)
        array.set(Y, i, f(array.get(X, i)))
    float sum = 0
    for t = 0 to (n - 1) / 4 
        int ind = 4 * t
        sum += (1 / 45.0) * 
             (14 * array.get(Y, ind) 
             + 64 * array.get(Y, ind + 1) 
             + 24 * array.get(Y, ind + 2) 
             + 64 * array.get(Y, ind + 3) 
             + 14 * array.get(Y, ind + 4)) 
             * delta_x
    sum

// alternate function not used
// Waissi and Rossin normal cdf approximation
normCDF(float z)=>
    float b1 = -0.0004406
    float b2 =  0.0418198
    float b3 =  0.9
    out = 1.0 / (1.0 + math.exp(-math.sqrt(math.pi) * (b1 * math.pow(z, 5) + b2 * math.pow(z, 3) + b3 * z)))
    out

// N(0,1) cdf by Boole's Rule
N(float x)=> 
    float out = Boole(-10.0, x, 240)
    out

d1(float S, float K, float r, float q, float v, float T)=>
    float d1 = (math.log(S / K) + T * (r - q + 0.5 * v * v)) / (v * math.sqrt(T))
    d1

d2(float S, float K, float r, float q, float v, float T)=>
    float d1 = (math.log(S / K) + T * (r - q + 0.5 * v * v)) / (v * math.sqrt(T))
    d2 = d1 - v * math.sqrt(T)
    d2

// Black-Scholes Option Price
BSPrice(float S, float K, float r, float T, float q, float v, string PutCall)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float call = S * math.exp(-q * T) * N(d1) - math.exp(-r * T) * K * N(d2)
    float out = 0
    out := PutCall == callString ? call : call - S * math.exp(-q * T) + K * math.exp(-r * T)
    out 

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
// 1° Order Greeks
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

// Black-Scholes Delta or Spot Delta
BSDelta(float S, float K, float T, float r, float q, float v, string OpType)=>
    float d1 = d1(S, K, r, q, v, T)
    float out = OpType == callString ? math.exp(-q * T) * N(d1) : math.exp(-q * T) * (N(d1) - 1)
    out

// Black-Scholes Vega or Zeta
BSVega(float S, float K, float T, float r, float q, float v)=>
    float d1 = d1(S, K, r, q, v, T)
    float out = S * math.exp(-q * T) * f(d1) * math.sqrt(T)
    out

// Black-Scholes Theta
BSTheta(float S, float K, float T, float r, float q, float v, string OpType)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float b = r - q 
    float num = S * math.exp((b - r) * T) * f(d1) * v
    float dom = 2 * math.sqrt(T)
    float mult1 = 0
    float mult2 = 0
    float out = 0
    if (OpType == callString)
        mult1 := (b - r) * S * math.exp((b - r) * T) * N(d1)
        mult2 := r * K * math.exp(-r * T) * N(d2)
        out := -num / dom - mult1 - mult2
    else
        mult1 := (b - r) * S * math.exp((b - r) * T) * N(-d1)
        mult2 := r * K * math.exp(-r * T) * N(-d2)
        out := -num / dom + mult1 + mult2
    out

// Black-Scholes Rho or Rho Call Futures Option
BSRho(float S, float K, float T, float r, float q, float v, string OpType)=>
    float d2 = d2(S, K, r, q, v, T)
    float price = BSPrice(S, K, r, T, q, v, OpType)
    float out = 0
    if OpType == callString
        out := syminfo.type == "futures" ? - T * price : T * K * math.exp(-r * T) * N(d2)
    else
        out :=  syminfo.type == "futures" ? - T * price : -T * K * math.exp(-r * T) * N(-d2)
    out

// Black-Scholes Lambda, omega, or elasticity 
BSLambda(float S, float K, float T, float r, float q, float v, string OpType)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float price = BSPrice(S, K, T, r, q, v, OpType)
    float delta = OpType == callString ? math.exp(-q * T) * N(d1) : math.exp(-q * T) * (N(d1) - 1)
    float out = delta * S / price
    out

// Black-Scholes Epsilon
BSEpsilon(float S, float K, float T, float r, float q, float v, string OpType)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float out = OpType == callString ? -S * T * math.exp(-q * T) * N(d2) : S * T * math.exp(-q * T) * N(d1) 
    out

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
// 2nd Order Greeks
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

// Black-Scholes Gamma or Convexity
BSGamma(float S, float K, float T, float r, float q, float v)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float out = (f(d1) * math.exp(-q * T)) / (S * v * math.sqrt(T))
    out

// Black-Scholes Vanna, DdeltaDvol, or DVegaDSpot
BSVanna(float S, float K, float T, float r, float q, float v)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float out = ((-math.exp(-q * T) * d2) / v) * f(d1)
    out

// Black-Scholes Charm, Delta Bleed, or DDeltaDTime
BSCharm(float S, float K, float T, float r, float q, float v, string OpType)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float b = r - q
    float out = 0
    if OpType == callString
        out := -math.exp((b - r) * T) * (f(d1) * (b / (v * math.sqrt(T)) - d2 / (2 * T)) + (b - r) * N(d1))
    else
        out := -math.exp((b - r) * T) * (f(d1) * (b / (v * math.sqrt(T)) - d2 / (2 * T)) - (b - r) * N(-d1))
    out 

// Black-Scholes Vomma, DvegaDvol, or volga
BSVomma(float S, float K, float T, float r, float q, float v)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float vega = BSVega(S, K, T, r, q, v)
    float out = vega * ((d1 * d2) / v)
    out 

// Black-Scholes Veta
BSVeta(float S, float K, float T, float r, float q, float v, string OpType)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float out = -S * math.exp(-q * T) * f(d1) * math.sqrt(T) * (q + ((r - q) * d1)/ (v * math.sqrt(T)) - ((1 + d1 * d2) / (2 * T)))
    out

// Black-Scholes Vera or rhova
BSVera(float S, float K, float T, float r, float q, float v, string OpType)=>
    float v2 = math.pow(v, 2)
    float out = math.exp(-r * T) * (1 / K) * (1 / math.sqrt(2 * math.pi * v2 * T)) * math.exp((-1 / (2 * v2 * T)) * math.pow(math.log(K / S) - ((r - q) - 0.5 * v2) * T, 2))
    out

//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////
// 3rd Order Greeks
//////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////

// Black-Scholes Speed or DGammaDSpot
BSSpeed(float S, float K, float T, float r, float q, float v)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float gamma = BSGamma(S, K, r, q, v, T)
    float dv = 1 + d1 / (v * math.sqrt(T))
    float out = -gamma * (dv / S)
    out

// Black-Scholes Zomma
BSZomma(float S, float K, float T, float r, float q, float v)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float gamma = BSGamma(S, K, r, q, v, T)
    float d1d2 = (d1 * d2) - 1
    float out = gamma * (d1d2 / v)
    out

// Black-Scholes Color, Gamma Bleed
BSColor(float S, float K, float T, float r, float q, float v)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float b = (r - q)
    float gamma = BSGamma(S, K, r, q, v, T)
    float out = gamma * ((r - b) + (b * d1) / (v * math.sqrt(T)) + (1 - d1 * d2) / (2 * T))
    out 

// Black-Scholes Ultima or DVommaDVol
BSUltima(float S, float K, float T, float r, float q, float v)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float vomma = BSVomma(S, K, T, r, q, v)
    float out =  vomma * (1 / v) * (d1 * d2 + d1 / d2 - d2 / d1 - 1)
    out 

// Black-Scholes Dual Delta or Strike Delta
BSDualDelta(float S, float K, float T, float r, float q, float v, string OpType)=>
    float d2 = d2(S, K, r, q, v, T)
    float out = OpType == callString ? -math.exp(-r * T) * N(d2) : math.exp(-r * T) * N(-d2)
    out

// Black-Scholes Dual Gamma or Strike Gamma
BSDualGamma(float S, float K, float T, float r, float q, float v, string OpType)=>
    float d1 = d1(S, K, r, q, v, T)
    float d2 = d2(S, K, r, q, v, T)
    float out = math.exp(-r * T) * (f(d2) / (K * v * math.sqrt(T)))
    out

smthtype = input.string("Kaufman", "Heikin-Ashi Better Caculation Type", options = ["AMA", "T3", "Kaufman"], group = "Spot Price Settings")
srcin = input.string("Close", "Spot Price", group= "Spot Price Settings", 
     options = 
     ["Close", "Open", "High", "Low", "Median", "Typical", "Weighted", "Average", "Average Median Body", "Trend Biased", "Trend Biased (Extreme)", 
     "HA Close", "HA Open", "HA High", "HA Low", "HA Median", "HA Typical", "HA Weighted", "HA Average", "HA Average Median Body", "HA Trend Biased", "HA Trend Biased (Extreme)",
     "HAB Close", "HAB Open", "HAB High", "HAB Low", "HAB Median", "HAB Typical", "HAB Weighted", "HAB Average", "HAB Average Median Body", "HAB Trend Biased", "HAB Trend Biased (Extreme)"])

float K = input.float(275, "Strike Price", group = "Basic Settings")   
string OpType = input.string(callString, "Option type", options = [callString, putString], group = "Basic Settings")   
string greeksshow = input.string("First-order", title = "Greeks to Show", options =["First-order", "Second-order", "Third-order"], group = "Basic Settings")

float v = input.float(25.6, "% Implied Volatility", group = "Implied Volatility Settings") / 100
int histvolper = input.int(22, "Historical Volatility Period", group = "Historical Volatility Settings", tooltip =  "Not used in calculation. This is here for comparison to implied volatility")
string hvoltype = input.string(c2c, "Historical Volatility Type", options = [c2c, gkvol, gkzhvol, rogersatch, ewmavolstr, parkinson], group = "Historical Volatility Settings")

string rfrtype = input.string("USD", "Option Base Currency", options = ['USD', 'GBP', 'JPY', 'CAD', 'CNH', 'SGD', 'INR', 'AUD', 'SEK', 'NOK', 'DKK'], group = "Risk-free Rate Settings", tooltip = "Automatically pulls 10-year bond yield from corresponding currency")
float rfrman = input.float(3.97, "% Manual Risk-free Rate", group = "Risk-free Rate Settings") / 100
bool usdrsrman = input.bool(false, "Use manual input for Risk-free Rate?", group = "Risk-free Rate Settings")

float divsman = input.float(7.5, "% Manual Yearly Dividend Yield", group = "Dividend Settings") / 100
bool usediv = input.bool(false, "Adjust for Dividends?", tooltip = "Only works if divdends exist for the current ticker", group = "Dividend Settings")
bool autodiv = input.bool(true, "Automatically Calculate Yearly Dividend Yield?", tooltip = "Only works if divdends exist for the current ticker", group = "Dividend Settings")

string timein = input.string("Time Now", title = "Time Now Type", options = ["Time Now", "Time Bar", "Trading Day"], group = "Time Intrevals", tooltip = timtoolnow + "; " + timtoolbar + "; " + timetooltrade)
int daysinyear = input.int(252, title = "Days in Year", minval = 1, maxval = 365, group = "Time Intrevals", tooltip = "Typically 252 or 365")
float hoursinday = input.float(24, title = "Hours Per Day", minval = 1, maxval = 24, group = "Time Intrevals", tooltip = "Typically 6.5, 8, or 24")

int thruMonth = input.int(3, title = "Expiry Month", minval = 1, maxval = 12, group = "Expiry Date/Time")
int thruDay = input.int(31, title = "Expiry Day", minval = 1, maxval = 31, group = "Expiry Date/Time")
int thruYear = input.int(2023, title = "Expiry Year", minval = 1970, group = "Expiry Date/Time")
int mins = input.int(0, title = "Expiry Minute", minval = 0, maxval = 60, group = "Expiry Date/Time")
int hours = input.int(9, title = "Expiry Hour", minval = 0, maxval = 24, group = "Expiry Date/Time")
int secs = input.int(0, title = "Expiry Second", minval = 0, maxval = 60, group = "Expiry Date/Time")


// seconds per year given inputs above
int spyr = math.round(daysinyear * hoursinday * 60 * 60)

// precision calculation miliseconds in time intreval from time equals now
start = timein == "Time Now" ? timenow : timein == "Time Bar" ? time : time_tradingday
finish = timestamp(thruYear, thruMonth, thruDay, hours, mins, secs) 
temp = (finish - start) 
float T = (finish - start) / spyr / 1000

float q = usediv ? (autodiv ? request.dividends(syminfo.tickerid) / close * 4 : divsman) : 0

string byield = switch rfrtype
    "USD"=> 'US10Y'
    "GBP"=> 'GB10Y'
    "JPY"=> 'US10Y'
    "CAD"=> 'CA10Y'
    "CNH"=> 'CN10Y'
    "SGD"=> 'SG10Y'
    "INR"=> 'IN10Y'
    "AUD"=> 'AU10Y'
    "USEKSD"=> 'SE10Y'
    "NOK"=> 'NO10Y'
    "DKK"=> 'DK10Y'
    => 'US10Y'

kfl=input.float(0.666, title="* Kaufman's Adaptive MA (KAMA) Only - Fast End", group = "Moving Average Inputs")
ksl=input.float(0.0645, title="* Kaufman's Adaptive MA (KAMA) Only - Slow End", group = "Moving Average Inputs")
amafl = input.int(2, title="* Adaptive Moving Average (AMA) Only - Fast", group = "Moving Average Inputs")
amasl = input.int(30, title="* Adaptive Moving Average (AMA) Only - Slow", group = "Moving Average Inputs")

haclose = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, close)
haopen = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, open)
hahigh = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, high)
halow = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, low)
hamedian = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, hl2)
hatypical = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, hlc3)
haweighted = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, hlcc4)
haaverage = request.security(ticker.heikinashi(syminfo.tickerid), timeframe.period, ohlc4)

float spot = switch srcin
	"Close" => loxxexpandedsourcetypes.rclose()
	"Open" => loxxexpandedsourcetypes.ropen()
	"High" => loxxexpandedsourcetypes.rhigh()
	"Low" => loxxexpandedsourcetypes.rlow()
	"Median" => loxxexpandedsourcetypes.rmedian()
	"Typical" => loxxexpandedsourcetypes.rtypical()
	"Weighted" => loxxexpandedsourcetypes.rweighted()
	"Average" => loxxexpandedsourcetypes.raverage()
    "Average Median Body" => loxxexpandedsourcetypes.ravemedbody()
	"Trend Biased" => loxxexpandedsourcetypes.rtrendb()
	"Trend Biased (Extreme)" => loxxexpandedsourcetypes.rtrendbext()
	"HA Close" => loxxexpandedsourcetypes.haclose(haclose)
	"HA Open" => loxxexpandedsourcetypes.haopen(haopen)
	"HA High" => loxxexpandedsourcetypes.hahigh(hahigh)
	"HA Low" => loxxexpandedsourcetypes.halow(halow)
	"HA Median" => loxxexpandedsourcetypes.hamedian(hamedian)
	"HA Typical" => loxxexpandedsourcetypes.hatypical(hatypical)
	"HA Weighted" => loxxexpandedsourcetypes.haweighted(haweighted)
	"HA Average" => loxxexpandedsourcetypes.haaverage(haaverage)
    "HA Average Median Body" => loxxexpandedsourcetypes.haavemedbody(haclose, haopen)
	"HA Trend Biased" => loxxexpandedsourcetypes.hatrendb(haclose, haopen, hahigh, halow)
	"HA Trend Biased (Extreme)" => loxxexpandedsourcetypes.hatrendb(haclose, haopen, hahigh, halow)
	"HAB Close" => loxxexpandedsourcetypes.habclose(smthtype, amafl, amasl, kfl, ksl)
	"HAB Open" => loxxexpandedsourcetypes.habopen(smthtype, amafl, amasl, kfl, ksl)
	"HAB High" => loxxexpandedsourcetypes.habhigh(smthtype, amafl, amasl, kfl, ksl)
	"HAB Low" => loxxexpandedsourcetypes.hablow(smthtype, amafl, amasl, kfl, ksl)
	"HAB Median" => loxxexpandedsourcetypes.habmedian(smthtype, amafl, amasl, kfl, ksl)
    "HAB Typical" => loxxexpandedsourcetypes.habtypical(smthtype, amafl, amasl, kfl, ksl)
	"HAB Weighted" => loxxexpandedsourcetypes.habweighted(smthtype, amafl, amasl, kfl, ksl)
	"HAB Average" => loxxexpandedsourcetypes.habaverage(smthtype, amafl, amasl, kfl, ksl)
    "HAB Average Median Body" => loxxexpandedsourcetypes.habavemedbody(smthtype, amafl, amasl, kfl, ksl)
	"HAB Trend Biased" => loxxexpandedsourcetypes.habtrendb(smthtype, amafl, amasl, kfl, ksl)
	"HAB Trend Biased (Extreme)" => loxxexpandedsourcetypes.habtrendbext(smthtype, amafl, amasl, kfl, ksl)
	=> haclose

float r = usdrsrman ? rfrman : request.security(byield, timeframe.period, close) / 100

float hvolout = switch hvoltype
    parkinson => parkinsonvol(histvolper)
    rogersatch => rogerssatchel(histvolper) 
    c2c => closetoclose(math.log(spot / nz(spot[1])), histvolper) 
    gkvol => garmanKlass(histvolper) 
    gkzhvol => gkyzvol(histvolper) 
    ewmavolstr => ewmavol(math.log(spot / nz(spot[1])), histvolper) 

if barstate.islast

    float tempr = syminfo.type == "futures" ? 0 : r 

    price =     BSPrice(spot, K, r, T, q, v, OpType)

    // 1rst order
    delta =     BSDelta(spot, K, T, r, q, v, OpType)
    vega =      BSVega(spot, K, T, r, q, v)
    theta =     BSTheta(spot, K, T, r, q, v, OpType)
    rho =       BSRho(spot, K, T, r, q, v, OpType)
    lambda =    BSLambda(spot, K, T, r, q, v, OpType)
    epsilon =   BSEpsilon(spot, K, T, r, q, v, OpType)

    // 2nd order
    gamma =     BSGamma(spot, K, T, r, q, v)
    vanna =     BSVanna(spot, K, T, r, q, v)
    charm =     BSCharm(spot, K, T, r, q, v, OpType)
    vomma =     BSVomma(spot, K, T, r, q, v)
    veta =      BSVeta(spot, K, T, r, q, v, OpType)
    vera =      BSVera(spot, K, T, r, q, v, OpType)

    // 3rd order
    speed =     BSSpeed(spot, K, T, r, q, v)
    zomma =     BSZomma(spot, K, T, r, q, v)
    colorz =    BSColor(spot, K, T, r, q, v)
    ultima =    BSUltima(spot, K, T, r, q, v)
    dualdelta = BSDualDelta(spot, K, T, r, q, v, OpType)
    dualgamma = BSDualGamma(spot, K, T, r, q, v, OpType)

    var testTable = table.new(position = position.middle_right, columns = 1, rows = 22, bgcolor = color.yellow, border_width = 1)

    table.cell(table_id = testTable, column = 0, row = 0,  text = "  Inputs for European " + OpType + " Option", bgcolor=color.yellow, text_color = color.black, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 1,  text = "  Spot Price: " + str.tostring(spot, f_tickFormat()) , bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 2,  text = "  Strike Price: " + str.tostring(K, f_tickFormat()), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 3,  text = "  Volatility (annual): " + str.tostring(v * 100, "##.##") + "%  ", bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 4,  text = "  Risk-free Rate Type: " + rfrtype , bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 5,  text = "  Risk-free Rate: " + str.tostring(tempr * 100, "##.##") + "%  ", bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 6,  text = "  Dividend Yield (annual): " + str.tostring(q * 100, "##.##") + "%  ", bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 7,  text = "  Time Now: " + str.format("{0,date,MMMM dd, yyyy - HH:mm:ss}", timenow) + "  ", bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 8,  text = "  Expiry Date: " + str.format("{0,date,MMMM dd, yyyy - HH:mm:ss}", finish) + "  ", bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)

    table.cell(table_id = testTable, column = 0, row = 9,  text = "  Output  ", bgcolor=color.yellow, text_color = color.black, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 10, text = "  Price: " + str.tostring(price, f_tickFormat()), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)

    table.cell(table_id = testTable, column = 0, row = 11, text = "  Calculated Values  ", bgcolor=color.yellow, text_color = color.black, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 12, text = "  Hist. Volatility Type: " + hvoltype, bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 13, text = "  Hist. Daily Volatility: " + str.tostring(hvolout * 100, "##.##") + "%  ", bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
    table.cell(table_id = testTable, column = 0, row = 14, text = "  Hist. Annualized Volatility: " + str.tostring(hvolout * math.sqrt(daysinyear) * 100, "##.##") + "%  ", bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)

    if greeksshow == "First-order"
        table.cell(table_id = testTable, column = 0, row = 15, text = "  First-order Greeks  ", bgcolor=color.yellow, text_color = color.black, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 16, text = "  Delta: " + str.tostring(delta, "##.#####"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 17, text = "  Vega: " + str.tostring(vega, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 18, text = "  Theta: " + str.tostring(theta, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 19, text = "  Rho: " + str.tostring(rho, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 20, text = "  Lambda: " + str.tostring(lambda, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 21, text = "  Epsilon: " + str.tostring(epsilon, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)

    if greeksshow == "Second-order"
        table.cell(table_id = testTable, column = 0, row = 15, text = "  Second-order Greeks  ", bgcolor=color.yellow, text_color = color.black, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 16, text = "  Gamma: " + str.tostring(gamma, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 17, text = "  Vanna: " + str.tostring(vanna, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 18, text = "  Charm: " + str.tostring(charm, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 19, text = "  Vomma: " + str.tostring(vomma, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 20, text = "  Veta: " + str.tostring(veta, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 21, text = "  Vera: " + str.tostring(vera, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)

    if greeksshow == "Third-order"
        table.cell(table_id = testTable, column = 0, row = 15, text = "  Third-order Greeks  ", bgcolor=color.yellow, text_color = color.black, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 16, text = "  Speed: " + str.tostring(zomma, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 17, text = "  Color: " + str.tostring(colorz, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 18, text = "  Ultima: " + str.tostring(ultima, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 19, text = "  Dual Delta: " + str.tostring(dualdelta, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
        table.cell(table_id = testTable, column = 0, row = 20, text = "  Dual Gamma: " + str.tostring(dualgamma, "##.########"), bgcolor=darkGreenColor, text_color = color.white, text_size = size.normal)
````
