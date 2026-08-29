<!-- tradingview-pine-id: PUB;EYxGe4WReoTZ3iTIO9l4efKCzvUNHYWY -->
<!-- tradingviewscripts-format: 1 -->
# Spearman Rank Correlation Coefficient

Source: https://www.tradingview.com/script/y5n6dlJm-Spearman-Rank-Correlation-Coefficient/

## Description

I'm pleased to introduce this script in honor of the new [array functions](https://www.tradingview.com/blog/en/arrays-are-now-available-in-pine-script-20052/) introduced to PineScript version 4.0. This update is a long time coming and opens the door to amazing scripting possibilities!

Definition

Named after Charles Spearman and denoted by the Greek letter ‘ρ’ (rho), the [Spearman rank correlation coefficient](https://mathworld.wolfram.com/SpearmanRankCorrelationCoefficient.html) is the nonparametric version of the [Pearson correlation coefficient](https://mathworld.wolfram.com/CorrelationCoefficient.html). Use the Spearman rank correlation when you have two ranked variables, and you want to see whether the two variables covary. That is, as one variable increases/decreases, the other variable tends to increase/decrease respectively.

It is best used to discover if two variables (and in this first version of the indicator, two ticker symbols) increase and decrease together. There are advantages to using this version of correlation vs. the Pearson R.

Interpretation

The value oscillates between +1 and -1. 

[*] A value of +1 means the two variables are perfectly correlated, that is they are increasing and decreasing together in perfect harmony.
[*] A value of -1 means the two variables exhibit a perfect negative correlation, that is they increase and decrease oppositely. 
[*] A value of zero means the two variables are not correlated at all (noise).

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © mortdiggiddy

//@version=4
study("Spearman Rank Correlation Coefficient")

src1 = input(close, "Primary Source", type = input.source, tooltip = "The source input that is correlated to the selected symbol's closing price. By default the close of the chart's symbol is correlated against the close of the selected symbol below, however an alternate source can be used to correlated against the selected symbol, such as an indicator on the chart.")
sym = input("TVC:SPX", "Symbol", type = input.symbol)
length = input(10, "Length", minval = 1)

src2 = security(sym, timeframe.period, close)

var a1 = array.new_float(0)
var a2 = array.new_float(0)
var a1_sorted = array.new_float(0)
var a2_sorted = array.new_float(0)

var a1_ranked = array.new_float(length, 0)
var a2_ranked = array.new_float(length, 0)
var diff = array.new_float(length, 0)

// initially the array sizes are zero at the very first bar 
// index, they grow to 'length' as the chart data is traversed

if array.size(a1) <= length
    array.unshift(a1, src1)
    array.unshift(a2, src2)
    
// pop off last value if a.size > 'length'

if array.size(a1) > length
    array.pop(a1)
    
if array.size(a2) > length 
    array.pop(a2)
    
// update arrays with the current values at the array head

array.set(a1, 0, src1)
array.set(a2, 0, src2)

rank(a, sorted, ranked) =>
    dupe = array.new_float(0)
    size = array.size(a)
    
    // re-populate and re-sort

    array.clear(sorted)
    array.concat(sorted, a)
    array.sort(sorted, order.ascending) 
    
    for i = 0 to (size - 1)
        v = array.get(sorted, i)
        
        if not array.includes(dupe, v)
            // locate the original index of the sorted value at index 'i'
            
            index = array.indexof(a, v)
            lastIndex = array.lastindexof(a, v)
            
            if index >= 0
                // we have to check for duplicate entries
                //
                // ex)        a = [1   5   3  7   5   9  8]
                //     a_ranked = [1  3.5  2  5  3.5  6  7]
                
                rank = if index != lastIndex
                    array.push(dupe, v)
                    
                    total = array.lastindexof(sorted, v) - i + 1
                    mod = i
                    
                    for j = 1 to (total - 1)
                        mod := mod + i + j
                    
                    rank = mod / total
                else
                    rank = i
                
                // assign the rank to all occurrences of the value
                
                for j = index to lastIndex
                    if array.get(a, j) == v
                        array.set(ranked, j, rank)
                    
    tie = array.size(dupe)
                
corr(tie) =>
    // https://i.imgur.com/W6yPFGk.png
    
    size = array.size(a1)
    d2_sum = 0.0
    
    corr = if tie == 0
        for i = 0 to (size - 1)
            v1 = array.get(a1_ranked, i)
            v2 = array.get(a2_ranked, i)
            
            d2_sum := d2_sum + (v1 - v2) * (v1 - v2)
            
        corr = 1 - (6 * d2_sum / (size * (size * size - 1)))
    else
        // Tied Ranks (Full calc): https://i.imgur.com/iVieah3.png
        
        r1_avg = array.avg(array.slice(a1_ranked, 0, size)) 
        r2_avg = array.avg(array.slice(a2_ranked, 0, size))
        
        covar = 0.0
        r1_sq_sum = 0.0
        r2_sq_sum = 0.0
        
        for i = 0 to (size - 1)
            v1 = array.get(a1_ranked, i) - r1_avg
            v2 = array.get(a2_ranked, i) - r2_avg
            
            covar := covar + v1 * v2
            
            r1_sq_sum := r1_sq_sum + v1 * v1 
            r2_sq_sum := r2_sq_sum + v2 * v2
            
        corr = covar / sqrt(r1_sq_sum * r2_sq_sum)
            
    corr

tie1 = rank(a1, a1_sorted, a1_ranked)
tie2 = rank(a2, a2_sorted, a2_ranked)

correlation = corr(tie1 + tie2)

hline(0, "Zero Line", color = #909090C0, linestyle = hline.style_dotted) 
hline(1, "+1 Line", color = #00FF00C0, linestyle = hline.style_dotted)
hline(-1, "-1 Line", color = #FF0000C0, linestyle = hline.style_dotted)

colorUp = correlation > 0.95 ? #00FF00FF : correlation > 0.82 ? #00E114FF : correlation > 0.79 ? #00C328FF : correlation > 0.66 ? #00A53CFF : correlation > 0.53 ? #008750FF : correlation > 0.40 ? #006964FF : correlation > 0.27 ? #004B78FF : #002D8CFF
colorDn = correlation < -0.95 ? #FF0000FF : correlation < -0.82 ? #E10014FF : correlation < -0.79 ? #C30028FF : correlation < -0.66 ? #A5003CFF : correlation < -0.53 ? #870050FF : correlation < -0.40 ? #690064FF : correlation < -0.27 ? #4B0078FF : #2D008CFF

plot(correlation, "Spearman Rank Correlation", color = correlation > 0 ? colorUp : correlation < 0 ? colorDn : #808080FF, style = plot.style_columns)
````
