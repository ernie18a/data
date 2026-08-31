<!-- tradingview-pine-id: PUB;e51680d37704498c8aa1593131f0e1f2 -->
<!-- tradingviewscripts-format: 1 -->
# Weighted percentile nearest rank

Source: https://www.tradingview.com/script/4LByGQj0-Weighted-percentile-nearest-rank/

## Description

Yo, posting it for the whole internet, took the whole day to find / to design the actual working solution for weighted percentile 'nearest rank' algorithm, almost no reliable info online and a lot of library-style/textbook-style solutions that don't provide on real world production level.

The principle:

0) initial data
data      = 22, 33, 11, 44, 55
weights = 5  , 3  , 2  , 1  , 4

array(s) size = 5

1) sort data array, apply the sorting pattern to the weights array, resulting:
data      = 11, 22, 33, 44, 55
weights = 2  , 5  , 3  , 1  , 4

2) get weights cumsum and sum:
weights         = 2, 5, 3  , 1  , 4
weights_cum = 2, 7, 10, 11, 15
weights_sum = 15

3) say we wanna find 50th percentile, get a threshold value:
n = 50
thres = weights_sum / 100 * n
7.5    = 15                / 100 * 50

4) iterate through weights_cum until you find a value that >= the threshold:
for i = 0 to size - 1
    2   >= 7.5 ? nah
    7   >= 7.5 ? nah
    10 >= 7.5 ? aye

5) take the iteration index that resulted "aye", and find the data value with the same index, that's gonna be the resulting percentile.
i = 2
data = 33

This one is not an approximation, not an estimator, it's the actual weighted percentile nearest rank as it is.

I tested the thing extensively and it works perfectly. 
For the skeptics, check lines 40, 41, 69 in the code, you can comment/uncomment dem to switch for unit (1) weights, resulting in the usual non-weighted percentile nearest rank that ideally matches the TV's built-in function.

Shoutout for @wallneradam for the sorting function mane
...
Live Long and Prosper

---

## Source Code

````pine
//@version=6
indicator('Weighted percentile nearest rank', 'WPNR', true, timeframe ='', timeframe_gaps = true)


multisort(array_base, array_second, reverse = false) =>
    len = array_base.size()

    sorted_indices      = array.sort_indices(array_base, reverse ? order.descending : order.ascending)
    sorted_array_base   = array.new_float(len)
    sorted_array_second = array.new_float(len)
    
    for i = 0 to len - 1
        idx = sorted_indices.get(i)
        
        sorted_array_base  .set(i, array_base  .get(idx))
        sorted_array_second.set(i, array_second.get(idx))
    
    [sorted_array_base, sorted_array_second]

wpnr(data, weights, len, p) =>
    [sorted_data, sorted_weights] = multisort(data, weights)
    
    sorted_weights_cum = array.new_float(len, sorted_weights.get(0))

    for i = 1 to len - 1
        sorted_weights_cum.set(i, sorted_weights_cum.get(i - 1) + sorted_weights.get(i))
    
    wpnr  = 0.0
    thres = sorted_weights.sum() / 100 * p

    for i = 0 to len - 1
        if sorted_weights_cum.get(i) >= thres
            wpnr := sorted_data.get(i)
            break
    
    wpnr


src   = input(close, 'Source'                                                )
len   = input(256  , 'Length'                                                )
p     = input(50   , '%'                                                     )
time_ = input(true , 'Time'           , inline = '1', group = 'Weighting by:')
iv    = input(true , 'Inferred volume', inline = '1', group = 'Weighting by:')


data    = array.new_float(len)
weights = array.new_float(len)

for i = 0 to len - 1
    weight = (time_ ? (len - i) : 1) * (iv ? math.abs(close[i] - open[i]) : 1)
    // weight = 1 //unit weights, if u wanna do a raincheck
    data   .set(i, src[i])
    weights.set(i, weight)

out = wpnr(data, weights, len, p)


plot(out, 'WPNR', color.gray)

// plot(percentile_nearest_rank(src, len, n)) //that one as well for a rainchech
````
