<!-- tradingview-pine-id: PUB;SbsoQvkekufRGuQKVuclT45aoPvnONzh -->
<!-- tradingviewscripts-format: 1 -->
# VAMA Volume Adjusted Moving Average Function r2

Source: https://www.tradingview.com/script/WzvigqK7-VAMA-Volume-Adjusted-Moving-Average-Function/

## Description

This indicator is a live analysis adaptation of Richard Arms' Volume Adjusted Moving Average coded as a single function. VAMA utilizes a period length that is based on volume increments rather than time. Settings are provided for using as a pair of fast and slow moving averages. 

• SampleN - N volume bars used as sample to calculate average volume , 0 equals all bars. 

• VAMA Source - Price used for volume weighted calculations. 

• VAMA Length - Specified number of volume ratio buckets to be reached. 

• VAMA VI Fct - Size of volume ratio buckets. 

• VAMA Strict - Must meet desired volume requirements, even if number of bars has to exceed VAMA Length to do it. 

Please see previous published example [here](https://www.tradingview.com/script/RLnFKoAx-VAMA-Volume-Adjusted-Moving-Average/) for more details on VAMA's usage and inability to redraw the past on time based charts. 

NOTICE: This is an example script and not meant to be used as an actual strategy. By using this script or any portion thereof, you acknowledge that you have read and understood that this is for research purposes only and I am not responsible for any financial losses you may incur by using this script!

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © allanster

//@version=5
indicator("VAMA Volume Adjusted Moving Average Function r2", shorttitle = "VAMA", overlay = true)

nvb  = input.int  (defval = 0,     title = "SampleN (0 = All)", minval = 0)                 // N volume bars used as sample to calculate average volume, 0 equals all bars
scF  = input      (defval = close, title = "VAMA Fast Source")                              // Richard Arms' default is close
lnF  = input.int  (defval = 13,    title = "VAMA Fast Length",  minval = 1)                 // Richard Arms' default is 55
fvF  = input.float(defval = 0.67,  title = "VAMA Fast VI Fct",  minval = 0.01, step = 0.1)  // Richard Arms' default is 0.67
rlF  = input      (defval = true,  title = "VAMA Fast Strict")                              // rule must meet volume requirements even if N bars' v2vi ratios has to exceed VAMA Length to do it
scS  = input      (defval = close, title = "VAMA Slow Source")                              // Richard Arms' default is close
lnS  = input.int  (defval = 55,    title = "VAMA Slow Length",  minval = 1)                 // Richard Arms' default is 55
fvS  = input.float(defval = 0.67,  title = "VAMA Slow VI Fct",  step = 0.1)                 // Richard Arms' default is 0.67
rlS  = input      (defval = true,  title = "VAMA Slow Strict")                              // rule must meet volume requirements even if N bars' v2vi ratios has to exceed VAMA Length to do it

vama(_src,_len,_fct,_rul,_nvb) =>                                                           // vama(source,length,factor,rule,sample)
    tvb = 0, tvb := _nvb == 0 ? nz(tvb[1]) + 1 : _nvb                                       // total volume bars used in sample            
    tvs = _nvb == 0 ? ta.cum(volume) : math.sum(volume, _nvb)                               // total volume in sample
    v2i = volume / ((tvs / tvb) * _fct)                                                     // ratio of volume to increments of volume                                                  
    wtd = _src*v2i                                                                          // weighted prices 
    nmb = 1                                                                                 // initialize number of bars summed back               
    wtdSumB = 0.0                                                                           // initialize weighted prices summed back
    v2iSumB = 0.0                                                                           // initialize ratio of volume to increments of volume summed back
    for i = 1 to _len * 10                                                                  // set artificial cap for strict to VAMA length * 10 to help reduce edge case timeout errors
        strict = _rul ? false : i == _len                                                   // strict rule N bars' v2i ratios >= vama length, else <= vama length
        wtdSumB := wtdSumB + nz(wtd[i-1])                                                   // increment number of bars' weighted prices summed back
        v2iSumB := v2iSumB + nz(v2i[i-1])                                                   // increment number of bars' v2i's summed back
        if v2iSumB >= _len or strict                                                        // if chosen rule met
            break                                                                           // break (exit loop)
        nmb := nmb + 1                                                                      // increment number of bars summed back counter
    nmb                                                                                     // number of bars summed back to fulfill volume requirements or vama length
    wtdSumB                                                                                 // number of bars' weighted prices summed back
    v2iSumB                                                                                 // number of bars' v2i's summed back
    vama = (wtdSumB - (v2iSumB - _len) * _src[nmb]) / _len                                  // volume adjusted moving average

vamaFast = vama(scF,lnF,fvF,rlF,nvb), plot(vamaFast, title = "Fast", color = color.new(color.fuchsia, 0), linewidth = 2)
vamaSlow = vama(scS,lnS,fvS,rlS,nvb), plot(vamaSlow, title = "Slow", color = color.new(color.yellow, 0),  linewidth = 2)
````
