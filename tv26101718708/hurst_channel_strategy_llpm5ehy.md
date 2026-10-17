# HURST Channel Strategy

- url: https://www.tradingview.com/script/llpM5Ehy-HURST-Channel-Strategy/
- type: strategy
- pine_id: PUB;409cf74420144ad68dda7974fe22a84e
- version: 2.0

## Description

Based on the work TJS / Trading Zoom / Svoboda

Strategy based on Hurst channel with loss averaging when an open position is below 0.5 channel range.

How it works:
1. opens the long position when the close price crosses over the lower band (from bottom to top) 
2. opens additional position (double in size) when average position price is lower than average channel value (0.5)
3. closes the position when the close price crosses over the higher band (from top to bottom) 


Works the best on :
- volatile and continuous instruments (futures) 
- on timeframes above 15 minutes
- uptrends or consolidations
- downtrends require more capital to open double positions

## Source Code

````pine
// //@version=4
// study(title="HURST OSCILATOR", shorttitle="HURST OSC", overlay=false)


//@version=5
strategy("HURST Strategy", overlay=true, pyramiding=5)

// HURST
mcl_t = input(30, title="HURST - PERIOD")
mcm = input(1.8, title="HURST - SIZE")
src = input(close, title="SOURCE")
long = input(true, title="Enable Long Strategy")
short = input(false, title="Enable Short Strategy (weak performance)") //weak performance

mcl = mcl_t/2

ma_mcl = ta.rma(src,mcl)
mcm_off = mcm*ta.atr(mcl)

mcl_2 = mcl/2

mct =  nz(ma_mcl[mcl_2], src)+ mcm_off
mcb =  nz(ma_mcl[mcl_2], src)- mcm_off


oshort=(src-mcb)/(mct-mcb)

co = ta.crossover(oshort, 0)
cm = ta.crossover(oshort, 0.5)
cu2 = ta.crossover(oshort, 1)
cu = ta.crossunder(oshort, 1)

curProfitInPts() =>
    if strategy.position_size > 0
        (src - strategy.position_avg_price)
    else if strategy.position_size < 0
        (strategy.position_avg_price - src)
    else
        0
        
points = math.round(curProfitInPts())

delta = math.round(mct - mcb)


if(long == true and close < mcb and (na(strategy.position_avg_price) or strategy.position_avg_price>math.avg(mct,mcb)))
	strategy.entry("long", strategy.long,  math.max((strategy.position_size+1), 1), stop=mcb, comment="Long Open")
	

if(long == true and close > mct)
    strategy.exit("exit-l", "long", stop=mct, comment="Long Close profit=" + str.tostring(points)) 
    
if(short == true and close > mct and (na(strategy.position_avg_price) or strategy.position_avg_price<math.avg(mct,mcb)))
	strategy.entry("short", strategy.long,  math.max((strategy.position_size+1), 1), limit=mct, comment="Short Open")
	

if(short == true and close < mcb)
    strategy.exit("exit-s", "short", limit=mcb, comment="Short Close profit=" + str.tostring(-1*points)) 
    

plot(strategy.position_avg_price, title="Position", style=plot.style_linebr)



//Plot

mcc=#E8E8E8 
mccm=#C8C8C8 
mctl=plot(mct, color=mcc, title="MediumCycleTop", style=plot.style_line, linewidth=0)
mcbl=plot(mcb, color=mcc, title="MediumCycleBottom", style=plot.style_line, linewidth=0)
plot(math.avg(mct,mcb), title="MediumCycleMedian", color=mccm, style=plot.style_line)
````
