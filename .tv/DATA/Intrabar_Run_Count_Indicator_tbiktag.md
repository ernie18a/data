<!-- tradingview-pine-id: PUB;4ff95623714249b3850157366820b413 -->
<!-- tradingviewscripts-format: 1 -->
# Intrabar Run Count Indicator [tbiktag]

Source: https://www.tradingview.com/script/XkBwnQ2h-Intrabar-Run-Count-Indicator-tbiktag/

## Description

• OVERVIEW

Introducing the Intrabar Run Count Indicator, a tool designed to detect potential non-randomness in intrabar price data. It utilizes the statistical [runs test](https://en.wikipedia.org/wiki/Wald–Wolfowitz_runs_test) to examine the number of sequences (runs) of positive and negative returns in the analyzed price series. As deviations from random-walk behavior of returns may indicate market [inefficiencies](https://www.investopedia.com/terms/r/randomwalktheory.asp), the Intrabar Run Count Indicator can help traders gain a better understanding of the price dynamics inside each chart bar and make more informed trading decisions.

• USAGE

The indicator line expresses​ the deviation between the number of runs observed in the dataset and the expected number of runs under the hypothesis of randomness​. Thus, it gauges the degree of deviation from random-walk behavior. If, for a given chart bar, it crosses above the [critical value](https://en.wikipedia.org/wiki/Z-test) or crosses below the negative critical value, this may indicate non-randomness in the underlying intrabar returns. These instances are highlighted by on-chart signals and bar coloring. The confidence level that defines the critical value, as well as the number of intrabars used for analysis, are selected in the input settings.

It is important to note that the readings of the Intrabar Run Count Indicator do not convey directional information and cannot predict future asset performance. Rather, they help distinguish between random and potentially tradable price movements, such as breakouts, reversals, and gap fillings.

• DETAILS

The [efficient-market hypothesis](https://en.wikipedia.org/wiki/Efficient-market_hypothesis) implies that the distribution of returns should be random, reflecting the idea that all available information is already priced into the asset. However, in practice, financial markets may not always be perfectly efficient due to factors such as market frictions, information asymmetry, and irrational behavior of market participants. As a result, inefficiency (non-randomness) can occur, potentially creating opportunities for trading strategies.

To search for potential inefficiencies, the Intrabar Run Count Indicator analyzes the distribution of the signs of returns. The central assumption underlying the indicator's logic is that if the asset price follows a random-walk pattern, then the probability of the next return being positive or negative (i.e., the next price value being larger or smaller than the current value) follows a binomial distribution. In this case, the number of runs is also a random variable, and, for a large sample, its conditional distribution is approximately normal with a well-defined mean and variance (see this [link](https://en.wikipedia.org/wiki/Wald–Wolfowitz_runs_test) for the exact expressions). Thus, the observed number of runs in the price series is indicative of whether or not the time series can be regarded as random. In simple words, if there are too few runs or too many runs, it is unlikely a random time series. A trivial example is a series with all returns of the same sign.

Quantitatively, the deviation from randomness can be gauged by calculating the test statistic of the runs test (that serves as an indicator line). It is defined as the absolute difference between the observed number of runs and the expected number of runs under the null hypothesis of randomness, divided by the standard deviation of the expected number of runs. If the test statistic is negative and exceeds the negative critical value (at a given confidence level), it suggests that there are fewer runs than expected for a random-walking time series. Likewise, if the test statistic exceeds the positive critical value, it is indicative of more runs than expected for a random series. The sign of the test statistic can also be informative, as too few runs can be sometimes indicative of mean-reverting behavior.

• CONCLUSION

The Intrabar Run Count Indicator can be a useful tool for traders seeking to exploit market inefficiencies and gain a better understanding of price action within each chart bar. However, it is important to note that the runs test only evaluates the distributional properties of the data and does not provide any information on the underlying causes of the non-randomness detected. Additionally, like any statistical test, it can sometimes produce false-positive signals. Therefore, this indicator should be used in conjunction with other analytical techniques as part of a trading strategy.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © tbiktag

//@version=5
indicator("Intrabar Run Count Indicator [tbiktag]", "IRCI", overlay = false)

// --- External libs ---
import PineCoders/lower_tf/4 as PCltf
//

// --- Constant variables ---
//     Titles and tooltips
string T0    = "N intrabars"
string T1    = "Confidence level"
string T2    = "Bar coloring" 
string T3    = "Background coloring" 
string T4    = "Show infobox" 
string T5    = "Signal / bar color     "
string T6    = "Test statistic color   " 
string T7    = "Lines / levels color   " 
string TT0   = "Select approximately how many intrabars will be analyzed for each chart bar. 
 To define the optimal lower timeframe in relation to the selected number of intrabars,
 the script uses the lower_ltf library published by TradingView."
string TT1   = "Select the desired confidence level that defines the critical value. 
 If the test statistic exceeds the critical value, it suggests non-randomness."
string TT2   = "The signal is triggered if \n 
 •the test statistic exceeds the critical value, and \n
 •there is sufficient number of data points in the sample (>20)." 
string TT3   = "If selected, bar coloring uses the following color scheme: \n
 •Signal color: the test statistic is greater than the critical value. \n
 •Transparent: not enough data point in the sample. \n
 •Default chart color: the test statistic is below the critical value."
string TT4   = "The infobox displays the number of intrabars used for analysis."
string GR0   = "Input"
string GR1   = "Style"
//
//     LTF distinction 
string LTF1  = "~50 intrabars per chart bar"
string LTF2  = "~100 intrabars per chart bar"
string LTF3  = "~250 intrabars per chart bar"
//
//     Minimum sample size for runs test
int    THRS  = 20
//
//     Color scheme
color  RED   = #f1363f
color  YELL  = #f1e836
color  GREY  = #CCCCCC
//
//     Confidence levels
float  ZC80  = 1.280 //alpha = 0.20
float  ZC90  = 1.645 //alpha = 0.10
float  ZC95  = 1.960 //alpha = 0.05
//

// --- Inputs ---
string ltfRes  = input.string(LTF2,  T0, [LTF1, LTF2, LTF3],    TT0, '', GR0)
string zMode   = input.string('90%', T1, ["80%", "90%", "95%"], TT1, '', GR0) 
bool   isColB  = input.bool(true,    T2,                        TT3, '', GR1)
bool   isBG    = input.bool(true,    T3,                        '',  '', GR1)
bool   isIBox  = input.bool(false,   T4,                        TT4, '', GR1)
color  CS      = input.color(YELL,   T5,                        '',  '', GR1)
color  C0      = input.color(RED,    T6,                        '',  '', GR1)
color  CL      = input.color(GREY,   T7,                        '',  '', GR1)
//

// --- Functions ---
runsTest(data) =>
    //
    // Calculate the test statistic of the Wald-Wolfowitz runs test,
    // by analyzing the signs of the input array elements.
    //
    // Input:  data,  float array  :: input data set
    // Output: zStat, float        :: test statistic
    //
    int   n        = array.size(data)
    int   nP       = 0
    int   nM       = 0
    int   R        = 1
    float lastR    = n>0?array.get(data, 0):na
    for  i = 0 to n>THRS?n-1:na
        iR = array.get(data, i)
        if iR > 0 
            nP    += 1
        else
            nM    += 1
        if   i > 0 and math.sign(iR) != math.sign(lastR)
            lastR := iR
            R     += 1 
    float mean     = 2*nP*nM/n + 1
    float sigma    = math.sqrt((mean-1)*(mean-2)/(n-1))
    float zStat    = (R - mean)/sigma
    zStat
//

// --- Calculations ---
var string   lSt        = PCltf.ltf(ltfRes, '', '', '', '', '', '', '', LTF1, LTF2, LTF3)
array<float> ltfReturns = request.security_lower_tf(syminfo.tickerid, lSt, ta.change(close))
float        zStat      = runsTest(ltfReturns)
int          nDataPts   = array.size(ltfReturns)
[nIBs, nCBs, avgIBs]    = PCltf.ltfStats(ltfReturns)
//
float  zCrit   = switch zMode
    "80%"       => ZC80
    "90%"       => ZC90
    "95%"       => ZC95
bool    isH1   = math.abs(zStat) >= zCrit
//

// --- Visuals ---
//     Define plot colors
color colZ   = isH1?color.new(C0, 30):color.new(C0, 60)
color colB   = switch
    isColB and isH1      => CS
    isColB and na(zStat) => color.new(CL, 100) 
    not (isColB or isH1) => na
//
//     Plot
plotZ  = plot(zStat,  'Test Statistic',             color=colZ,  style=plot.style_area)
plotshape(isH1,       'Signal', style=shape.circle, color=colB,  location=location.top)
plotshape(isH1,       'Signal', style=shape.circle, color=colB,  location=location.bottom)
plotC0 = hline(0.0,   'Zero',                       color=color.new(CL, 60))
plotC1 = hline( zCrit,'Critical Value',             color=color.new(CL, 60))
plotC2 = hline(-zCrit,'Critical Value',             color=color.new(CL, 60))
fill(plotC0, plotC1, 0,  zCrit, color.new(CL, 99),  color.new(CL, 80), display=isBG?display.all:display.none)
fill(plotC0, plotC2, 0, -zCrit, color.new(CL, 99),  color.new(CL, 80), display=isBG?display.all:display.none)
barcolor(colB)
//
//     Infobox
if isIBox
    var table iBox  = table.new(position.bottom_left, 1, 2, bgcolor = #FDE6E7)
    if barstate.islast 
        table.cell(iBox, 0, 0, "N intrabars used now: "+str.tostring(nIBs))
        table.cell(iBox, 0, 1, "N intrabars used on average: "+str.tostring(avgIBs,'#.##'))
//

// --- Error messages ---
if barstate.islast and avgIBs < THRS
    runtime.error('Insufficient intrabar data available at the given timeframe')
//
````
