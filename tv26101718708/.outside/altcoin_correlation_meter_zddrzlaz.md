# Altcoin correlation Meter

- url: https://www.tradingview.com/script/zDDrZLAZ-Altcoin-correlation-Meter/
- type: strategy
- pine_id: PUB;uDxtgWxOTr5aK12qfedWhnwA2em2Z5N1
- version: 1.0

## Description

Dear TV'ers,

Hereby a script where the relative strength of an (in this case) altcoin is measured. The script produces a correlation between the altcoin and total altcoin market (Total2 index, see script). Using this script you can see when there is a strong correlation between the two and when there isn't. Moreover, it also produces long/short signals using hull moving average crossover.

Long signals are produced when correlation is below 0 and the hma of the pair is higher than the lagging hma.
Short signals are produced when correlation is below 0 and the hma of the pair is lower than the lagging hma.
Short/Long is closed after correlation is going back towards a set correlation target as well as the Take profit percentage is reached.

In the above example the script is applied to one of my favorite altcoin projects (rose). 
Looking forward to feedback/suggestions.

## Source Code

````pine
// @version=4
strategy("Altcoin correlation Meter", overlay=false, pyramiding=0, default_qty_type= strategy.percent_of_equity, default_qty_value = 100, calc_on_order_fills=false, slippage=0,commission_type=strategy.commission.percent,commission_value=0.04)

// Get user input 
resolution_sec = input(title="resolution of reference pair (in min, hr or day)", type=input.string, defval="120")
lookback    = input(title="Lookback", type=input.integer, defval=5) 
lengthHMA    = input(title="length of Hull MA, for opening long/short", type=input.integer, defval=5) 
source_type      = input(title="Source", type=input.source, defval=close)
reference_pair = security(syminfo.tickerid, resolution=resolution_sec, expression=source_type)
reference_TOTAL   = input(title="Reference Market", type=input.string, defval="CRYPTOCAP:TOTAL2")  //"binance:ethusdtperp"   //"CRYPTOCAP:TOTAL"
correlationclose = input(title="if correlation above this number, close long/short", type=input.float, defval=0.95) 
TPpercentage = input(title="minimum percentage in profit to close long/short", type=input.float, defval=1) 

// Get % change of reference data source
referenceData_TOTAL = security(symbol=reference_TOTAL, resolution=resolution_sec, expression=source_type)
referenceChange = ((referenceData_TOTAL - referenceData_TOTAL[1]) / referenceData_TOTAL[1]) * 100

// Get % change of current market
currentData = reference_pair
currentChange = ((currentData - currentData[1]) / currentData[1]) * 100

// Declare arrays
var referenceArray = array.new_float(lookback)
var currentArray = array.new_float(lookback)

// Shift (remove) the last (first entered) value from our arrays (FIFO)
array.shift(referenceArray)
array.shift(currentArray)

// Add the current values to our arrays
array.push(referenceArray, referenceChange)
array.push(currentArray, currentChange)

hma_REF = hma(referenceData_TOTAL,lengthHMA)
hma_pair = hma(reference_pair,lengthHMA)
// Determine & plot our covariance relationship
covariance = array.covariance(currentArray, referenceArray)
plot(covariance, color=color.purple, style=plot.style_area, transp=0, display=display.none, title="Covariance")

// Plot our reference data
plot(referenceChange, color=color.red, style=plot.style_columns, transp=10, display=display.none, title="Reference Market")
plot(currentChange, color=color.blue, style=plot.style_histogram, linewidth=4, display=display.none, title="Current Market")

// Determine the standard deviation of our arrays
referenceDev = array.stdev(referenceArray)
currentDev = array.stdev(currentArray)
correlation = covariance / (referenceDev * currentDev)
correlation1 = correlation[1]
plot(correlation, color=color.yellow, linewidth=2, style=plot.style_stepline, title="Correlation Strength")
plot(correlation1, color=color.green, linewidth=2, style=plot.style_stepline, title="Correlation1 Strength")

// Plot reference lines
hline(price=0.9, color=color.red)
hline(price=0.5, color=color.white)
hline(price=-0.5, color=color.white)
hline(price=-0.9, color=color.red)
hline(price=0.0)

long = hma_pair > hma_pair[2] and correlation<0
short = hma_pair < hma_pair[2] and correlation<0 //crossover(correlation, correlation1) and close>open and close>close[1] and correlation<0.9
closelong = correlation>correlationclose
closeshort = correlation>correlationclose 
TPlong = (100-TPpercentage)/100
TPshort =(100+TPpercentage)/100 

if long
    strategy.entry("long", strategy.long)
if short
    strategy.entry("short", strategy.short)
    
if closelong and close*TPlong>strategy.position_avg_price
    strategy.close("long")
if closeshort and close*TPshort<strategy.position_avg_price
    strategy.close("short")
````
