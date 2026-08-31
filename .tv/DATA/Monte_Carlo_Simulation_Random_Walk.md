<!-- tradingview-pine-id: PUB;DJv4dw1DryDE8FpJEBX5ybSMbHOg9zA1 -->
<!-- tradingviewscripts-format: 1 -->
# Monte Carlo Simulation - Random Walk

Source: https://www.tradingview.com/script/asVG5Mjc-Monte-Carlo-Simulation-Random-Walk/

## Description

Hello All,

Monte Carlo Simulation is a model used to predict the probability of different outcomes when the intervention of random variables is present. it is used by professionals in such widely disparate fields as finance, project management etc. You can find many articles about Monte Carlo Simulation on the net.

In this script I tried to make Monte Carlo Simulation and "Random Walk". it calculates results over and over, each time using a different set of random values that is created using historical data (500 times by default) and show min-max and some random paths. number of "random walks" is calculated by using number of bars to predict, so if you change "Number of Bars to Predict" then number of random walks may change. Total number of the lines must be less than 500.

"Number of Simulations" is 500 by default, more simulation better results. but if you increase it a lot then you may get "loop takes too long error"
"Number of Bars to Predict" can be between 10-100
"Number of Bars to use as Data Source" is the number of historical bars to use in simulations

Thanks to Ricardo Santos (@RicardoSantos) for letting me use his Random Number Generator Function.

P.S. I am not mathematician and I tried to make it as far as I understood the method. so if you see any issue let me know please.

Some examples:

Number of Bars to Predict = 100:
https://www.tradingview.com/x/aJH05N9q/

Number of Bars to Predict = 10:
https://www.tradingview.com/x/4dGBKa4J/

if you enable "Keep Past Min-Max Levels" option then min-max levels will stay on the chart
https://www.tradingview.com/x/OM2gwB5d/

Enjoy!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LonesomeTheBlue
 
//@version=4
study("Monte Carlo Simulation - Random Walk", overlay = true, max_lines_count = 500)
numprct = input(defval = 50, title = "Number of Bars to Predict", minval = 10, maxval = 100)
numsim = input(defval = 500, title = "Number of Simulations", minval = 5)
datalen = input(defval = 2000, title = "Number of Bars to use as Data Source", minval = 100)
keepmm = input(defval = false, title = "Keep Past Min-Max Levels")
minmaxupcol = input(defval = color.blue, title = "Min-Max Levels Up Color")
minmaxdncol = input(defval = color.navy, title = "Min-Max Levels Down Color")
rwupcol = input(defval = color.lime, title = "Random Walk Up Color")
rwdncol = input(defval = color.red, title = "Random Walk Down Color")

//==================================================================================================
// Thanks to Ricardo Santos for letting me use his Random Number Generator Function (@RicardoSantos)
//==================================================================================================
var float[] seed = array.new_float(size=1, initial_value=42.0)
f_prng(_range)=>
//| pseudo random function:
    var float _return = 1.0
    float _seed = array.get(id=seed, index=0)
    float _reseed =  271.828
    _return := ((3.1416 * _return % _seed) * _reseed) % _range
    array.set(id=seed, index=0, value=(1 + (_seed * 1.618) % _range) + _return)
    _return
//==================================================================================================

timediff = time - time[1]
// total walks except min/max levels
var totalwalk = floor(500 / numprct) - 2
var prdc_lines = array.new_line(numprct * (totalwalk + 2))
if barstate.isfirst
    for x = 0 to array.size(prdc_lines) - 1
        array.set(prdc_lines, x, line.new(x1 = time, y1 = close, x2 = time, y2 = close, xloc = xloc.bar_time, width = x < totalwalk * numprct ? 2 : 3))

// keep periodic daily returns using the natural logarithm
var pc = array.new_float(0)
array.unshift(pc, log(close / close[1]))
if array.size(pc) > datalen
    array.pop(pc)
float minlevel = na
float maxlevel = na

if barstate.islast
    cls = array.new_float(numprct, na)
    maxcls = array.new_float(numprct, -1e15)
    mincls = array.new_float(numprct, 1e15)
    r = 0
    
    drift = array.avg(pc) - array.variance(pc) / 2
    //start simulations and get random 5 random and max-min paths
    for x = 0 to numsim - 1
        lastclose = close
        for y = 0 to numprct - 1
            rchg = round(f_prng(min(array.size(pc) - 1, bar_index - 1)))
            nextclose = max(0, lastclose * exp(array.get(pc, rchg) + drift))
            array.set(cls, y, nextclose)
            lastclose := nextclose
            
            array.set(maxcls, y, max(array.get(maxcls, y), nextclose))
            array.set(mincls, y, min(array.get(mincls, y), nextclose))
        
        // draw random paths
        if r < totalwalk
            line.set_xy1(array.get(prdc_lines, r * numprct), time, close)
            line.set_xy2(array.get(prdc_lines, r * numprct), time + timediff , array.get(cls, 0))
            line.set_color(array.get(prdc_lines, r * numprct), array.get(cls, 0) >= close ? rwupcol : rwdncol)
            for y = 1 to numprct - 1
                line.set_xy1(array.get(prdc_lines, r * numprct + y), time + timediff * y, array.get(cls, y - 1))
                line.set_xy2(array.get(prdc_lines, r * numprct + y), time + timediff * (y + 1), array.get(cls, y))
                line.set_color(array.get(prdc_lines, r * numprct + y), array.get(cls, y) >= array.get(cls, y - 1) ? rwupcol : rwdncol)
            
            r := r + 1
            
    // draw estimaded max-min closing prices
    line.set_xy1(array.get(prdc_lines, totalwalk * numprct), time, close)
    line.set_xy2(array.get(prdc_lines, totalwalk * numprct), time + timediff, array.get(maxcls, 0))
    line.set_color(array.get(prdc_lines, totalwalk * numprct), array.get(maxcls, 0) >= close ? minmaxupcol : minmaxdncol)
    line.set_xy1(array.get(prdc_lines, (totalwalk + 1) * numprct), time, close)
    line.set_xy2(array.get(prdc_lines, (totalwalk + 1) * numprct), time + timediff, array.get(mincls, 0))
    line.set_color(array.get(prdc_lines, (totalwalk + 1) * numprct), array.get(mincls, 0) >= close ? minmaxupcol : minmaxdncol)
    for y = 1 to numprct - 1
        line.set_xy1(array.get(prdc_lines, totalwalk * numprct + y), time + timediff * y, array.get(maxcls, y - 1))
        line.set_xy2(array.get(prdc_lines, totalwalk * numprct + y), time + timediff * (y + 1), array.get(maxcls, y))
        line.set_color(array.get(prdc_lines, totalwalk * numprct + y), array.get(maxcls, y) >= array.get(maxcls, y - 1) ? minmaxupcol : minmaxdncol)
        line.set_xy1(array.get(prdc_lines, (totalwalk + 1) * numprct + y), time + timediff * y, array.get(mincls, y - 1))
        line.set_xy2(array.get(prdc_lines, (totalwalk + 1) * numprct + y), time + timediff * (y + 1), array.get(mincls, y))
        line.set_color(array.get(prdc_lines, (totalwalk + 1) * numprct + y), array.get(mincls, y) >= array.get(mincls, y - 1) ? minmaxupcol : minmaxdncol)
    
    maxlevel := array.get(maxcls, 0)
    minlevel := array.get(mincls, 0)

plot(maxlevel, color = keepmm ? maxlevel >= maxlevel[1] ? minmaxupcol : minmaxdncol : na)
plot(minlevel, color = keepmm ? minlevel >= minlevel[1] ? minmaxupcol : minmaxdncol : na)
````
