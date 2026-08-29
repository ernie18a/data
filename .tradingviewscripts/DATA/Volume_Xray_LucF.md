<!-- tradingview-pine-id: PUB;85c2251ed6314862aeedfc6fea473800 -->
<!-- tradingviewscripts-format: 1 -->
# Volume X-ray [LucF]

Source: https://www.tradingview.com/script/tPsEizhp-Volume-X-ray-LucF/

## Description

█ OVERVIEW

This tool analyzes the relative size of ​volume reported on intraday vs ​EOD (end of day) data feeds on historical bars. If you use ​​volume data to make trading decisions, it can help you improve your understanding of its nature and quality, which is especially important if you trade on intraday timeframes.

I often mention, when discussing ​volume analysis, how it's important for traders to understand the ​volume data they are using: where it originates, what it includes and does not include. By helping you spot sizeable differences between ​volume reported on intraday and ​EOD data feeds for any given instrument, "Volume X-ray" can point you to instruments where you might want to research the causes of the difference.

█ CONCEPTS

The information used to build a chart's historical bars originates from data providers (exchanges, brokers, etc.) who often maintain distinct historical feeds for intraday and ​EOD timeframes. How ​volume data is assembled for intraday and ​EOD feeds varies with instruments, brokers and exchanges. Variations between the two feeds — or their absence — can be due to how instruments are traded in a particular sector and/or the ​volume reporting policy for the feeds you are using. Instruments from crypto and forex markets, for example, will often display similar ​volume on both feeds. Stocks will often display variations because [block trades](https://en.wikipedia.org/wiki/Block_trade) or other types of trades may not be included in their intraday ​volume data. ​Futures will also typically display variations. It is even possible that ​volume from different feeds may not be of the same nature, as you can get trade ​volume (market ​volume) on one feed and tick ​volume (transaction counts) on another. You will sometimes be able to find the details of what different feeds contain from the technical information provided by exchanges/brokers on their feeds. This is an example for the [NASDAQ feeds](http://www.nasdaqtrader.com/trader.aspx?id=dpspecs). Once you determine which feeds you are using, you can look for the reporting specs for that feed. This is all research you will need to do on your own; "Volume X-ray" will not help you with that part.

You may elect to forego the deep dive in feed information and simply rely on the figure the indicator will calculate for the instruments you trade. One simple — and unproven — way to interpret "Volume X-ray"  values is to infer that instruments with larger percentages of intraday/​EOD ​​volume ratios are more "democratic" because at intraday timeframes, you are seeing a greater proportion of the actual traded ​volume for the instrument. This could conceivably lead one to conclude that such ​​volume data is more reliable than on an instrument where intraday ​volume accounts for only 3% of ​EOD ​volume, let's say.

Note that as intraday vs ​EOD variations exist for historical bars on some instruments, there will typically also be differences between the realtime feeds used on intraday vs 1D or greater timeframes for those same assets. Realtime reporting rules will often be different from historical feed reporting rules, so variations between realtime feeds will often be different from the variations between historical feeds for the same instrument. A deep dive in reporting rules will quickly reveal what a jungle they are for some instruments, yet it is the only way to really understand the ​volume information our charts display.

█ HOW TO USE IT

The script is very simple and has no inputs. Just add it to 1D charts and it will calculate the proportion of ​volume reported on the intraday feed over the ​​EOD ​volume. The plots show the daily values for both volumes: the teal area is the ​EOD ​volume, the orange line is the intraday ​volume. A value representing the average, cumulative intraday/​EOD ​volume percentage for the chart is displayed in the upper-right corner. Its background color changes with the percentage, with brightness levels proportional to the percentage for both the bull color (% >= 50) or the bear color (% < 50). When abnormal conditions are detected, such as missing ​volume of one kind or the other, a yellow background is used.

Daily and cumulative values are displayed in indicator values and the Data Window.

The indicator loads in a pane, but you can also use it in overlay mode by moving it on the chart with "Move to" in the script's "More" menu, and disabling the plot display from the "Settings/Style" tab.

█ LIMITATIONS

 • The script will not run on timeframes >1D because it cannot produce useful values on them.
 • The calculation of the cumulative average will vary on different intraday timeframes because of the varying number of days covered by the dataset.
  Variations can also occur because of irregularities in reported ​volume data. That is the reason I recommend using it on 1D charts.
 • The script only calculates on historical bars because in real time there is no distinction between intraday and ​EOD feeds.
 • You will see plenty of special cases if you use the indicator on a variety of instruments:
   • Some instruments have no intraday ​volume, while on others it's the opposite.
   • Missing information will sometimes appear here and there on datasets.
   • Some instruments have higher intraday than ​​EOD ​volume.
  Please do not ask me the reasons for these anomalies; it's your responsibility to find them. I supply a tool that will spot the anomalies for you — nothing more.

█ FOR PINE CODERS

 • This script uses a little-known feature of [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security), which allows us to specify `"1440"` for the `timeframe` argument. 
  When you do, data from the 1min intrabars of the historical intraday feed is aggregated over one day, as opposed to the usual ​EOD feed used with `"D"`.
 • I use gaps on my [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security) calls. This is useful because at intraday timeframes I can cumulate non-[na](https://www.tradingview.com/pine-script-reference/v5/#fun_box{dot}new) values only.
 • I use [fixnan()](https://www.tradingview.com/pine-script-reference/v5/#fun_fixnan) on some values. For those who don't know about it yet, it eliminates [na](https://www.tradingview.com/pine-script-reference/v5/#var_na) values from a series, just like not using gaps will do in a [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security) call.
 • I like how the new [switch](https://www.tradingview.com/pine-script-reference/v5/#op_switch) structure makes for more readable code than equivalent [if](https://www.tradingview.com/pine-script-reference/v5/#op_if) structures.
 • I wrote my script using the revised recommendations in the [Style Guide](https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html) from the Pine v5 User Manual.
 • I use the new [runtime.error()](https://www.tradingview.com/pine-script-reference/v5/#fun_runtime{dot}error) to throw an error when the script user tries to use a timeframe >1D. 
  Why? Because then, my [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security) calls would be returning values from the last 1D intrabar of the dilation of the, let's say, 1W chart bar.
  This of course would be of no use whatsoever — and misleading. I encourage all Pine coders fetching HTF data to protect their script users in the same way.
  As tool builders, it is our responsibility to shield unsuspecting users of our scripts from contexts where our calcs produce invalid results.
 • While we're on the subject of accessing intrabar timeframes, I will add this to the intention of coders falling victim to what appears to be 
  a new misconception where the mere fact of using intrabar timeframes with [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security) is believed to provide some sort of edge.
  This is a fallacy unless you are sending down functions specifically designed to mine values from [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security)'s intrabar context.
  These coders do not seem to realize that:
   • They are only retrieving information from the last intrabar of the chart bar.
   • The already flawed behavior of their scripts on historical bars will not improve on realtime bars. It will actually worsen because in real time, 
    intrabars are not yet ordered sequentially as they are on historical bars.
   • Alerts or strategy orders using intrabar information acquired through [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security) will be using flawed logic and data most of the time.
  The situation reminds me of the mania where using Heikin-Ashi charts to backtest was all the rage because it produced magnificent — and flawed — results.
  Trading is difficult enough when doing the right things; I hate to see traders infected by lethal beliefs.
  Strive to sharpen your "herd immunity", as Lionel Shriver calls it. She also writes: "Be leery of orthodoxy. Hold back from shared cultural enthusiasms." 
  Be your own trader.

█ THANKS

This indicator would not exist without the invaluable insights from Tim, a member of the Pine team. Thanks Tim!

---

## Source Code

````pine
//@version=5
//@author=LucF
 
// Volume X-ray [LucF]
//  v4, 2021.11.01 12:20 — LucF

// Compares daily volume from the intraday and EOD feeds.

// This code was written using:
//  • The recommendations in Pine's Style Guide: https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html

indicator("Volume X-ray [LucF]", "Volume X-ray", format = format.volume)

color BULL_COLOR  = #008000
color BEAR_COLOR  = #FF0000
color ERROR_COLOR = color.yellow
color EOD_COLOR   = #008080
color INT_COLOR   = #FF8000

printTable(txt, txtColor, bgColor) => 
    var table t = table.new(position.top_right, 1, 1)
    table.cell(t, 0, 0, txt, text_color = txtColor, text_size = size.large, bgcolor = bgColor)

// Doesn't make sense to run the script on >1D TFs, as `request.security()` calls would be fetching incomplete intrabar data.
if (timeframe.isdaily and timeframe.multiplier != 1) or timeframe.isweekly or timeframe.ismonthly
    runtime.error("Use at timeframes of 1D or less.")

// Volume from EOD feed.
float volumeEod = request.security(syminfo.tickerid, "D",    volume, gaps = barmerge.gaps_on)
// Create a regular session ticker for intraday volume because EOD feed does not contain extended session volume.
regularSessionInt = ticker.modify(syminfo.tickerid, session.regular)
// Volume from intraday feed (sum of 1min intraday bars).
float volumeInt = request.security(regularSessionInt, "1440", volume, gaps = barmerge.gaps_on)
// Cumul of daily values only when volume data exists in both feeds.
float volumeEodCum = fixnan(ta.cum(not na(volumeInt) and barstate.ishistory? volumeEod : 0))
float volumeIntCum = fixnan(ta.cum(not na(volumeEod) and barstate.ishistory? volumeInt : 0))
// Percentage that daily intraday volume represents over daily EOD volume.
float volumeIntradayPct = volumeIntCum / volumeEodCum


// ————— Plots

// Daily area and line. Plot darker if the other feed supplies no data.
plot(barstate.ishistory ? volumeEod : na, "EOD Volume",      nz(volumeInt) != 0 ? EOD_COLOR : color.new(EOD_COLOR, 50), style = plot.style_area)
plot(barstate.ishistory ? volumeInt : na, "Intraday Volume", nz(volumeEod) != 0 ? INT_COLOR : color.new(INT_COLOR, 50), 2)

// Colored table cell with cumulative %
bool noEodVolumeCum = nz(volumeEodCum) == 0
bool noIntVolumeCum = nz(volumeIntCum) == 0
color msgBgColor = 
  switch
    noEodVolumeCum or noIntVolumeCum => ERROR_COLOR
    volumeIntradayPct <  0.50        => color.from_gradient(volumeIntradayPct, 0.0, 0.5, BEAR_COLOR, color.new(BEAR_COLOR, 70))
    volumeIntradayPct >= 0.50        => color.from_gradient(volumeIntradayPct, 0.5, 1.0, color.new(BULL_COLOR, 70), BULL_COLOR)
string msg = 
  switch
    noEodVolumeCum and noIntVolumeCum => "No volume"
    noEodVolumeCum => "No EOD volume"
    noIntVolumeCum => "No Intraday volume"
    => "Intraday volume: " + (not na(volumeIntradayPct) ? str.tostring(volumeIntradayPct, "0  %") : "—")
printTable(msg, msgBgColor == ERROR_COLOR ? color.black : color.white, msgBgColor)

// Data Window plots.
plotchar(volumeEodCum, "Cumulative EOD volume", "", location.top, msgBgColor)
plotchar(volumeIntCum, "Cumulative Intraday volume", "", location.top, msgBgColor)
plotchar(volumeIntradayPct * 100, "volumeIntradayPct", "", location.top, msgBgColor)
````
