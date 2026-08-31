<!-- tradingview-pine-id: PUB;310208d199cf48138da010725cb66349 -->
<!-- tradingviewscripts-format: 1 -->
# BIN Based Support and Resistance [SS]

Source: https://www.tradingview.com/script/AtzwB4pU-BIN-Based-Support-and-Resistance-SS/

## Description

This indicator presents a version of an alternative way to determine support and resistance, using a method called "Bins". 

Bins provide for a flexible and interesting way to determine support and resistance levels. 

First off, let's discuss BINS: 

Bins are ranges or containers into which your data points can be sorted. For example, if you're grouping ages, you might have bins like 0–18, 19–35, 36–50, and 51+. Any data point within these intervals gets placed in the corresponding bin.

Binning simplifies complex data sets by grouping values into categories. This is useful for such things as 

[*] Visualizing data in histograms or bar charts.
[*] Reducing noise and highlighting trends.

This indicator groups the price action into 10 separate bins. It determines the Support / Resistance level by averaging the values in the Bins to find an iteration of the "central tendency"  or average reoccurring value. 

Pros and Cons
Since this is a different approach to support and resistance, I think its important to highlight some of the pros and advantages, but also be open about the cons. 

First off the PROS

[*] Bin Based Support and Resistance Levels dynamically adjust to ranges as opposed to hard / fast peaks and valleys. This makes them better at analyzing price action vs simply drawing lines at random peaks and valleys. 

[*] Because Bins are analyzing ALL PA within a period's max and min range, Bin Support and Resistance can actually be used similar to Volume profile, where you are able to identify a pseudo-POC, or areas where price tends to consolidate. Take a look at this example on SPY: 
https://www.tradingview.com/x/wcgEZBzj/

You can see these 2 SR lines are close together. This represents that this general price range is an area where price likes to accumulate/consolidate. You can see the SPY ended up coming back to this range and consolidating there for a bit. 
This is a strength of using a BIN based approach to calculating support and resistance, because as indicated before, it looks at price action vs peaks and valleys. 
As a tip, these areas are areas you want to wait for a break in one direction or the other. 

[*] The indicator provides for backtest results of the support and resistance lines, to see how many times certain areas acted as resistance or support. Because this is analyzing and distributing PA evenly throughout the period's max and min, the indicator can tell you which areas tend to have higher rejection zones and which have higher support zones. 
 

Now the CONS

[*] Because bin based SR take an average approach, the SR lines can sometimes be slightly broken before the ticker finds rejection:
https://www.tradingview.com/x/WiMNxIfw/

To combat this, make sure there is confirmed support. How the indicator actually backtests these lines is by waiting to see if the ticker has 3 consecutive closes above the support line or below the resistance line. So these are things to be mindful of. 

[*] It doesn't consider pivots. Most support and resistance indicators either identify max and min peaks and valleys or use pivot points. Pivot points are a great way to identify peaks and valleys and thus by extension support and resistance. However, this is also somewhat of a strength, as using BINS forces the indicator to consider ALL price action and not just the extremes (highs and lows). 

[*] Can be slightly skewed in highly volatile environments. Any time there is a massive drop or rally, it can skew the indicator to give extreme ranges to both ends. For example, the Tariff news collapse on ES1!:
https://www.tradingview.com/x/gI4b2csA/

[*] Owning to limitations in lookback length, sometimes the min and max range can be exceeded and other traditional areas of support / resistance is where a ticker will find support. 

Using the indicator

Here are some basic use/functionalities of the indicator: 

[*] Selecting display of backtest results: You can select to have the backtest results shown in a table: 
https://www.tradingview.com/x/1dzoJAFt/

Or directly on the lines:
https://www.tradingview.com/x/ZfXgT7Lf/

Inversely, you can toggle them off completely:
https://www.tradingview.com/x/d3viJC2e/

[*]  You can modify the lookback length. The suggested lookback length is between 250 to 500 candles on smaller timeframes. I also suggest 252 on daily timeframes (which represents 1 trading year). 

And that's the indicator! 
It is very easy to use, so you should pick it up in no time! 

Enjoy and as always, 🚀🚀 safe trades! 🚀🚀

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Steversteves
//  /$$$$$$   /$$                                                         /$$                                            
// /$$__  $$ | $$                                                        | $$                                            
//| $$  \__//$$$$$$    /$$$$$$  /$$    /$$ /$$$$$$   /$$$$$$   /$$$$$$$ /$$$$$$    /$$$$$$  /$$    /$$ /$$$$$$   /$$$$$$$
//|  $$$$$$|_  $$_/   /$$__  $$|  $$  /$$//$$__  $$ /$$__  $$ /$$_____/|_  $$_/   /$$__  $$|  $$  /$$//$$__  $$ /$$_____/
// \____  $$ | $$    | $$$$$$$$ \  $$/$$/| $$$$$$$$| $$  \__/|  $$$$$$   | $$    | $$$$$$$$ \  $$/$$/| $$$$$$$$|  $$$$$$ 
// /$$  \ $$ | $$ /$$| $$_____/  \  $$$/ | $$_____/| $$       \____  $$  | $$ /$$| $$_____/  \  $$$/ | $$_____/ \____  $$
//|  $$$$$$/ |  $$$$/|  $$$$$$$   \  $/  |  $$$$$$$| $$       /$$$$$$$/  |  $$$$/|  $$$$$$$   \  $/  |  $$$$$$$ /$$$$$$$/
// \______/   \___/   \_______/    \_/    \_______/|__/      |_______/    \___/   \_______/    \_/    \_______/|_______/ 

//@version=6
indicator("BIN Based Support and Resistance [SS]", overlay=true)
lookback = input.int(500, "Lookback Length") 
displaylabel = input.string("On SR lines", "Where would you like the statistics to display?", ["On SR lines", "Table", "OFF"])
offset = input.int(100, "Offset the lines ahead") 
max = ta.highest(close, lookback) 
min = ta.lowest(close, lookback) 

bins = (max - min) / 10 

lbin1 = min + bins 
lbin2 = lbin1 + bins 
lbin3 = lbin2 + bins 
lbin4 = lbin3 + bins 
lbin5 = lbin4 + bins 
ubin10 = max - bins 
ubin9 = ubin10 - bins 
ubin8 = ubin9 - bins 
ubin7 = ubin8 - bins 
ubin6 = ubin7 -bins 

bool bin1 = close >= min and close < lbin1 
bool bin2 = close >= lbin1 and close < lbin2 
bool bin3 = close >= lbin2 and close < lbin3 
bool bin4 = close >= lbin3 and close < lbin4 
bool bin5 = close >= lbin4 and close < lbin5 
bool bin6 = close >= lbin5 and close < ubin6 
bool bin7 = close >= ubin6 and close < ubin7 
bool bin8 = close >= ubin7 and close < ubin8 
bool bin9 = close >= ubin8 and close < ubin9 
bool bin10 = close >= ubin10 


ar() => 
    array.new<float>() 

bin1a = ar(), bin2a = ar(), bin3a = ar(), bin4a = ar(), bin5a = ar(), bin6a = ar(), bin7a = ar(), bin8a = ar(), bin9a = ar(), bin10a = ar() 

for i = 0 to lookback 
    if bin1[i]
        bin1a.push(close[i])
    else if bin2[i]
        bin2a.push(close[i])
    else if bin3[i]
        bin3a.push(close[i])
    else if bin4[i]
        bin4a.push(close[i])
    else if bin5[i]
        bin5a.push(close[i])
    else if bin6[i]
        bin6a.push(close[i])
    else if bin7[i]
        bin7a.push(close[i])
    else if bin8[i]
        bin8a.push(close[i])
    else if bin9[i]
        bin9a.push(close[i])
    else if bin10[i]
        bin10a.push(close[i])
    else 
        na

sr1 = array.avg(bin1a), sr2 = array.avg(bin2a), sr3 = array.avg(bin3a), sr4 = array.avg(bin4a), sr5 = array.avg(bin5a), sr6 = array.avg(bin6a), sr7 = array.avg(bin7a), sr8 = array.avg(bin8a)
sr9 = array.avg(bin9a), sr10 = array.avg(bin10a) 


// statistica 

calculate_statistics(bin, lookback) =>
    bool bullish_rejection = high[2] >= bin and close < bin 
    bool bearish_rejection = low[2] <= bin and close > bin 

    int reject_bull = 0 
    int reject_bear = 0 
    for i = 0 to lookback 
        if bullish_rejection[i]
            reject_bull += 1 
        if bearish_rejection[i]
            reject_bear += 1 
    
    support_success = (reject_bear/ (reject_bear + reject_bull)) * 100 
    resistance_success = (reject_bull / (reject_bear + reject_bull)) * 100 
    [support_success, resistance_success]


[sr1_ss, sr1_rs] = calculate_statistics(sr1, lookback)
[sr2_ss, sr2_rs] = calculate_statistics(sr2, lookback)
[sr3_ss, sr3_rs] = calculate_statistics(sr3, lookback)
[sr4_ss, sr4_rs] = calculate_statistics(sr4, lookback)
[sr5_ss, sr5_rs] = calculate_statistics(sr5, lookback)
[sr6_ss, sr6_rs] = calculate_statistics(sr6, lookback)
[sr7_ss, sr7_rs] = calculate_statistics(sr7, lookback)
[sr8_ss, sr8_rs] = calculate_statistics(sr8, lookback)
[sr9_ss, sr9_rs] = calculate_statistics(sr9, lookback)
[sr10_ss, sr10_rs] = calculate_statistics(sr10, lookback)

// Gradient colours 

color[] gradient_array = array.from(#ff00c8, #e100ff, #0d00ff, #007bff, #00ffd5, #00ff15, #00ff15, #ffc400, #ff7700, #ff1500, #ff008c, #e3000b)

// Combine data 
sr_array = array.from(sr1, sr2, sr3, sr4, sr5, sr6, sr7, sr8, sr9, sr10, max, min)
support_success_array = array.from(sr1_ss, sr2_ss, sr3_ss, sr4_ss, sr5_ss, sr6_ss, sr7_ss, sr8_ss, sr9_ss, sr10_ss, 0, 100)
resistance_success_array = array.from(sr1_rs, sr2_rs, sr3_rs, sr4_rs, sr5_rs, sr6_rs, sr7_rs, sr8_rs, sr9_rs, sr10_rs, 100, 0)
num_array = array.from(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12)

create_label(idx) => 
    label.new(bar_index + offset, array.get(sr_array, idx), text = "% Success as Support: " + str.tostring(array.get(support_success_array, idx)) + "\n % Success as Resistance: " + str.tostring(array.get(resistance_success_array, idx)), color = na, style = label.style_label_right, size = size.normal)


if barstate.islast 
    for lines in line.all 
        line.delete(lines) 
    for labels in label.all 
        label.delete(labels)

if barstate.islast
    for i = 0 to array.size(sr_array) - 1 
        line.new(bar_index - lookback, array.get(sr_array, i), bar_index + offset, array.get(sr_array, i), color = array.get(gradient_array, i), width = 1)
        line.new(bar_index - lookback, array.get(sr_array, i), bar_index + offset, array.get(sr_array, i), color = color.new(array.get(gradient_array, i), 70), width = 3)
        line.new(bar_index - lookback, array.get(sr_array, i), bar_index + offset, array.get(sr_array, i), color = color.new(array.get(gradient_array, i), 80), width = 6)
        line.new(bar_index - lookback, array.get(sr_array, i), bar_index + offset, array.get(sr_array, i), color = color.new(array.get(gradient_array, i), 95), width = 8)
        if displaylabel == "On SR lines"
            create_label(i) 
        if displaylabel == "Table"
            label.new(bar_index + offset, array.get(sr_array, i), text = str.tostring(array.get(num_array,i)), color = na, textcolor = color.white)
            table data = table.new(position.middle_right, 3, 14, bgcolor = color.new(color.rgb(0, 0, 0), 65))
            for j = 0 to array.size(sr_array) - 1 
                table.cell(data, 1, 1, text = "SR Line", text_color = color.white) 
                table.cell(data, 2, 1, text = "Backtest Results", text_color = color.white) 
                table.cell(data, 1, 2 + j, text = str.tostring(array.get(num_array, j)), bgcolor = array.get(gradient_array, j), text_color = color.black) 
                table.cell(data, 2, 2 + j, text = "% Support Success: " + str.tostring(math.round(array.get(support_success_array, j), 2)) + "\n % Resistance Success: " + str.tostring(math.round(array.get(resistance_success_array, j), 2)), text_color = color.white)
````
