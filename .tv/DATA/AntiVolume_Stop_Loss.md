<!-- tradingview-pine-id: PUB;QyDEhGL8DBRp0dSHvun5TTcwgM2HiKVn -->
<!-- tradingviewscripts-format: 1 -->
# Anti-Volume Stop Loss

Source: https://www.tradingview.com/script/GpvwlRQm/

## Description

FINALLY!

As everyone who tried to create, understand, or even find the Buff Pelz Dormeier Anti-volume stop-loss indicator knows that - it's not easy. Personally, I have partially, or perhaps completely figured out, the tips Buff had given in Investing with Volume Analysis book.

AVSL now is ready.
Please do some test and give me a feedback how it works in your trade strategy.

Anti-Volume stop loss - AVSL
from Investing with Volume Analysis book CHAPTER 20 • RISKY BUSINESS 253-256:

"It is important in any risk-management process to predetermine an objective decision point level (a stop loss) to exit, thereby protecting principal in case you are wrong. My objective sell point is determined by using a quantitative formula I refer to as Anti-Volume Stop Loss (AVSL). Having a quantitative, yet intelligent sell point eliminates the emotional struggles involved in deciding when to exit a position. 
AVSL is a technical methodology that incorporates the concepts of support, volatility, and, most importantly, the inverse relationship between price and volume. The AVSL combines the concepts of the VPCI (Volume Price Confirmation Indicator) and John Bollinger’s Bollinger Bands to create a trailing stop loss.

AVSL = Lower Bollinger Band – (Price, Length, Standard Deviation)

Where:
Length = Round (3 + VPCI)
Price = Average (Lows × 1 / VPC × 1 / VPR, Length)
Standard Deviation = 2 × (VPCI × VM)

One of the most difficult decisions is determining what one’s maximum loss threshold should be. Some say 2 percent; others say 20 percent. I believe the more volatile a security, the looser the stop should be. A nonvolatile security, such as Coca-Cola, might move 7 percent a year, while a volatile security such as Google might move 7 percent in a day. If you use a 7 percent stop for Coca-Cola, it might take a year to be stopped out while the security underperforms.
However, if you use 7 percent for Google, you can be stopped out intraday, not allowing the investment an opportunity to develop. By using the lower Bollinger Band of the securities lows, the AVSL considers each individual security’s own volatility. Thus, a volatile security would be granted more room of the stocks low while a stable security would have a tighter leash (see Figure 20.7).
The next important step is employing the price-volume relationship into the calculation. Volume gauges the power behind price moves. In accounting for this, when a security is in an uptrend and has positive volume characteristics, it is given more room. However, if the security exhibits contracting volume characteristics, then the stop is tightened. In this way, if a negative news event affects an unhealthy security, the stop is tighter, thus preserving more of your profits.
However, if the negative news event affects a security whose price-volume relationship is healthy, the stop has been loosened, avoiding the temporary whipsaw of an otherwise strong position. In these ways, AVSL lets the market decide when to exit your position.

AVSL tailors each security for support, volatility, and the pricevolume relationship based on an investor’s time frame as calculated from the chart data. For example, my portfolio positions are continually re-evaluated with this AVSL methodology, which yields the possibility of raising the decision point threshold periodically based on the time frame of my investment objective. With my short-term Giddy-up portfolios, I use daily chart data and seek to raise my maximum loss stop on a daily basis.
My intermediate ETF and stock positions are calculated off of weekly data and then re-evaluated weekly. With my longer term stock portfolios, the decision point is calculated off data revised monthly. This analytical approach that uses measurable facts over emotion or gut instincts allows me to maintain my objectivity. Thus objectivity, not emotion, informs my investment decisions."

How look mine AVSL:

Price component = low × 1/VPC × 1/VPR   :   for VPC > 1 and VPC < -1   |   low × 1 × 1/VPR    :   for 1 > VPC > 0  |   low × -1 × 1/VPR   :   for 0 > VPC > -1
AVSL Price = sma((low × 1/VPC × 1/VPR) , length) / 100
length = round [3 + VPCI]   :   for VPCI > 0   |   round [ absolute [ -3+VPCI ] ]    :    for VPCI < 0   |  3   :    for VPCI=0
Standard Deviation = mult × VPCI × VM)

AVSL = sma(Actual low price - AWSL Price + Standard Deviation, 26)

It's hard to say is it the same as in Buff Pelz Dormeier book, but I encourage you to modify the script for better results.

---

## Source Code

````pine
// @version=4
study("Anti-Volume Stop Loss", shorttitle = "AVSL", max_bars_back=5000 ,overlay = true)


lenF = input(12, minval=1, title="Fast average")                                // amount of bars used as sample to calculate fast moving average   
srcF = input(close, title="Fast Price type" )                                   // type of price reading for fast moving average
lenS = input(26, minval=1, title="Slow average")                                // amount of bars used as sample to calculate slow moving average
srcS = input(close, title="Slow Price type" )                                   // type of price reading for slow moving average, 
lenT = input(9, minval=1, title="Signal")                                       // amount of bars used to calculate signal for VPCI
mult = input(2.0, minval=0.001, maxval=50, title="StdDev")
offset = input(2, "Offset", type = input.integer, minval = -500, maxval = 500)

// Functions

PriceFun(VPC,VPR,VM,src) =>                                                     //function calculating stop-loss step in relation with Volume and minimal price
    VPCI=VPC*VPR*VM
    
    lenV = if VPC <0
        int(round(abs(VPCI-3)))
    else if VPC>=0
        round(VPCI+3)
    else
        1
    
    VPCc = if (VPC > -1 and VPC <0)
        -1
    else if (VPC < 1 and VPC >= 0)
        1
    else
        VPC
        
    Price=0.0
    for i=0 to lenV - 1
        Price:=Price+(src[i]*1/VPCc[i]*1/VPR[i])
    PriceV=Price/lenV/100
    max_bars_back(PriceV, 5000)
    PriceV
    
// Caluclations

VWmaS = vwma(srcS,lenS)                                                         // Fast volume weighted moving average
VWmaF = vwma(srcF,lenF)                                                         // Slow volume weighted moving average
AvgS = sma(srcS,lenS)                                                           // Slow Volume average
AvgF = sma(srcF,lenF)                                                           // Fast Volume average
VPC = VWmaS - AvgS                                                              // Volume-Price Confirmation/Contradication VPC+/-
VPR = VWmaF/AvgF                                                                // Volume-Price Ratio
VM = sma(volume,lenF)/sma(volume,lenS)                                          // Volume Multipler
VPCI=VPC*VPR*VM                                                                 // Volume-Price Confiramtion indicator

DeV = mult*VPCI*VM                                                              // Deviation
AVSL = sma(low - PriceFun(VPC,VPR,VM,low) + DeV , lenS)                         

// Plots

plot(AVSL, title="AWSL", color = color.white, transp=0, linewidth=1, style=plot.style_cross, offset=offset)
````
