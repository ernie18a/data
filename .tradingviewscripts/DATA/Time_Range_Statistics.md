<!-- tradingview-pine-id: PUB;QPr1AMRTpLg6oGg7SYXoA8dF6fntEGiV -->
<!-- tradingviewscripts-format: 1 -->
# Time Range Statistics

Source: https://www.tradingview.com/script/XLV4MwjK-Time-Range-Statistics/

## Description

A good amount of users requested a text box showing various price statistics, the following script returns various of these stats in a user-selected range, and include classical ones such as a central tendency measurement (mean), dispersion (normalized range) and percent change, but also include less common statistics such as average traded volume and number of gaps. The script also calculates the correlation between the closing price and another user-selected instrument.

The script is currently the longest one I ever made and took some efforts, as I wasn't satisfied with the statistics to be originally included. Big thx to Gael for the enormous feedback and the idea of the normalized range, to user @Cookiecrush for the feedback (without ya I would have posted something bad you know umu ?), and Lulidolce for the support, friendship is magic!

Selected Range

The setting Start determine the bar at which the range starts, while End determine at which bar the range end. To help you select these values, the current bar number (bar index) is displayed at the right of the indicator title in blue.

The setting evaluate to last bar will use a range starting at Start and ending at the last bar, as such you can use a full range by using Start = 0 and select evaluate to last bar

[image]https://www.tradingview.com/x/wQljr1gc/[/image]

The range is highlighted by an area on the chart. By default Start = 9000 and End = 10000, you might not have this amount of data in your chart, as such use the displayed bar index to select Start and End, then set the settings as default.

Displayed Statistics

The statistics panel is displayed on the right side of the last bar, the panel has 3 sections, a title section who shows the symbol ticker, timeframe, and overall trends represented by a chart emoji, the overall trends are determined by comparing the number of higher highs with the number of lower low.

Below are displayed the date ranges with time format: year/month/day/hour:minute.

The second section shows the general statistics. The first one is the mean, also represented by the orange line in the chart, the blue line displayed represent the highest price value in the range, while the red one represents the lowest price value. 

The second stat is the normalized range, and determine how spread is the price in the user-selected range, why not the standard deviation? Because the standard deviation might return results varying widely depending on the scale of the closing price, you could get measures such as 0.0156 or 16 or even 56 depending on the instrument, as such using a normalized range can be more appropriate as it lays in a range of (0,1). Lower values indicate a low degree of price variation. Note that I still want to find another measure in the future.

The percentage change (or relative change) indicates at which percentage the price has increased or decreased, and is calculated by subtracting the closing at bar Start with the price at bar End, divided by the price at bar End, the result is then multiplied by 100. 

The average traded volume calculate the mean of the volume in the selected range, I used the same format used by the original volume indicator for clarity.

Finally, the last stats of the section is the number of gaps, this stat is by default hidden. An up gap is detected when the open price is superior to the previous high, while a down gap is detected when the open price is inferior to the previous low, this allow to only retain significant gaps.

The last section of the indicator panel shows the correlation between the closing price and another instrument, by default GOOG, this correlation is also calculated within the user-selected range. Positive values indicate a positive relationship, that is the two instruments tend to move in the same direction. Negative values indicate a negative relationship, both instruments tend to move in a direction opposite to each other. Values closer to 1 or -1 indicate a stronger relationship, while values closer to 0 indicate no relationship.

In Summary

The script shows various stats, each calculated within a user-selected range, in general one would be more interested in how these stats might evolve with time, but checking them in a custom range can be quite interesting.

Thx for reading. umu

---

## Source Code

````pine
// This work is licensed under a Creative Commons Attribution-ShareAlike 4.0 International License https://creativecommons.org/licenses/by-sa/4.0/
// © alexgrover

//@version=4
study("Time Range Statistics",overlay=true)
//------------------------------------------------------------------------------
// User Settings
//------------------------------------------------------------------------------
start = input(9000),End = input(10000)
Last = input(false,"Evaluate To Last Bar")
//----
Pt = input(true,"[-----------------Info & Date-----------------]")
Pp = input(true,"Ticker Prefix")
Pd = input(true,"Date Range")
//----
Ps = input(true,"[------------------Statistics-------------------]")
//----
Mu = input(true,"Mean")
Nn = input(true,"Normalized Range")
Pc = input(true,"Percent Change")
Av = input(true,"Average Volume")
Ng = input(false,"Number Of Gaps")
//----
Cor = input(true,"[-----------------Correlation-----------------]")
Sym = input("GOOG","Symbol",type=input.symbol)
//------------------------------------------------------------------------------
// Recurrent Data
//------------------------------------------------------------------------------
n = bar_index,o = open,c = close,y = year
mo = month,d = dayofmonth,h = hour,mi = minute
tick = Pp ? syminfo.tickerid : syminfo.ticker
tf = timeframe.period,end = Last ? n : End
//------------------------------------------------------------------------------
// Statistics
//------------------------------------------------------------------------------
//----
vs(x)=>valuewhen(n==start,x,0)
ve(x)=>valuewhen(n==end,x,0)
//----
mean(x)=>
    csum = cum(x)
    a = ve(csum)
    b = vs(csum)
    (a - b)/(end - start)
//----
Stdev(x)=>sqrt(mean(x*x) - pow(mean(x),2))
//----
max=0.,min = 0.
max := n > end ? max[1] : n >= start ? nz(max(c,max[1]),c) : c
min := n > end ? min[1] : n >= start ? nz(min(c,min[1]),c) : c
//----
ngap = cum(n > end ? 0 : n >= start and o > high[1] or o < low[1] ? 1 : 0)
nh = cum(n > end ? 0 : n >= start and change(max) ? 1 : 0)
nl = cum(n > end ? 0 : n >= start and change(min) ? 1 : 0)
//----
pmean = mean(c)
avgv = mean(volume)
normR = (max - min)/(max + min)
pc = (ve(c) - vs(c))/vs(c)*100
trend = nh > nl ? " 📈" : " 📉"
//----
sym = security(Sym,tf,c)
cov = mean(c*sym) - pmean*mean(sym)
pdev = Stdev(c)*Stdev(sym)
cor = cov/pdev
//------------------------------------------------------------------------------
// Date Range Text
//------------------------------------------------------------------------------
Sy=vs(y),Smo=vs(mo),Sd=vs(d),Sh=vs(h),Smi=vs(mi)
Ey=ve(y),Emo=ve(mo),Ed=ve(d),Eh=ve(h),Emi=ve(mi)
//----
Z(x)=>x/10 < 1 ? "0" : ""
Sdate = "From : " + tostring(Sy) + "/" + Z(Smo) + tostring(Smo) + "/"
  + Z(Sd) + tostring(Sd) + "/" + Z(Sh) + tostring(Sh) + ":" + Z(Smi) 
  + tostring(Smi) 
Edate = "To     : " + tostring(Ey) + "/" + Z(Emo) + tostring(Emo) + "/"
  + Z(Ed) + tostring(Ed) + "/" + Z(Eh) + tostring(Eh) + ":" + Z(Emi) 
  + tostring(Emi)
//------------------------------------------------------------------------------
// Text 
//------------------------------------------------------------------------------
lim = "------------------------------------------------------"
title = Pt ? lim + "\n" + tick + " " + tf + trend + " " + "\n" + lim + "\n" : na
daterange = Pt and Pd ? Sdate + "\n" + "\n" + Edate + "\n" + lim + "\n" : na
stats = Ps ? iff(Mu,"\n" + "Mean : " + tostring(pmean) + "\n",na)
  + iff(Nn,"\n" + "Normalized Range : " + tostring(normR,"#.####") + "\n",na) 
  + iff(Pc,"\n" + "Percent Change : " + tostring(pc,"#.####") + "%" + "\n",na) 
  + iff(Av,"\n" + "Average Volume : " + tostring(avgv/1000,"#.###") 
  + (avgv >= 1E6 ? "M" : avgv >= 1E3 ? "K" : na) + "\n",na) 
  + iff(Ng,"\n" + "Number Of Gaps : " + tostring(ngap) + "\n",na) 
  + "\n" + lim : na
correl = Cor ? "\n" + "Correlation " + "[" + Sym + "] : " 
  + tostring(cor,"#.####") : na
//------------------------------------------------------------------------------
// Plots
//------------------------------------------------------------------------------
label l = label.new(n,c,text=title+daterange+stats+correl,color=color.black,
  style=label.style_label_left,textcolor=color.white,
  textalign=text.align_left)
label.delete(l[1])
//----
line maxl = line.new(n[1],max,n,max,extend=extend.left,
  color=#2157f3,width=2)
line meanl = line.new(n[1],pmean,n,pmean,extend=extend.left,
  color=color.orange,width=2)
line minl = line.new(n[1],min,n,min,extend=extend.left,
  color=#ff1100,width=2)
line.delete(maxl[1]),line.delete(meanl[1]),line.delete(minl[1])
//----
css = n >= start and n <= end ? #2157f3 : na
bgcolor(css,transp=80)
plotchar(n,"Bar Index","‎",color=#2157f3,editable=false)
````
