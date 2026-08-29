<!-- tradingview-pine-id: PUB;qADnaAfCPpBEGLqLJaMaVZrYTmlIHPGN -->
<!-- tradingviewscripts-format: 1 -->
# Delta Volume Candles [LucF]

Source: https://www.tradingview.com/script/h0yZPTiS-Delta-Volume-Candles-LucF/

## Description

█ OVERVIEW

This indicator plots on-chart volume delta information using candles that can replace your normal candles, tops and bottoms appended to normal candles, optional MAs of those tops and bottoms levels, a divergence channel and a chart background. The indicator calculates volume delta using intrabar analysis, meaning that it uses the lower timeframe bars constituting each chart bar.

█ CONCEPTS

Volume Delta

​The ​volume delta concept divides a bar's ​volume in "up" and "down" ​volumes. The delta is calculated by subtracting down ​volume from up ​volume. Many calculation techniques exist to isolate up and down ​volume within a bar. The simplest use the polarity of interbar price changes to assign their ​volume to up or down slots, e.g., [On Balance Volume](https://www.tradingview.com/u/?solution=43000502593) or the [Klinger Oscillator](https://www.tradingview.com/u/?solution=43000589157). Others such as [Chaikin Money Flow](https://www.tradingview.com/chart/?solution=43000501974) use assumptions based on a bar's OHLC values. The most precise calculation method uses tick data and assigns the ​volume of each tick to the up or down slot depending on whether the transaction occurs at the bid or ask price. While this technique is ideal, it requires huge amounts of data on historical bars, which considerably limits the historical depth of charts and the number of symbols for which tick data is available. Furthermore, historical tick data is not yet available on TradingView.

This indicator uses intrabar analysis to achieve a compromise between the simplest and most precise methods of calculating ​volume delta. It is currently the most precise method usable on TradingView charts. TradingView's [Volume Profile built-in indicators](https://www.tradingview.com/u/?solution=43000502040) use it, as do the [CVD - Cumulative ​Volume Delta Candles](https://www.tradingview.com/script/NlM312nK-CVD-Cumulative-Volume-Delta-Candles/) and [CVD - Cumulative Volume Delta (Chart)](https://www.tradingview.com/script/hFcy7CIq-CVD-Cumulative-Volume-Delta-Chart/) indicators published from the [TradingView account](https://www.tradingview.com/u/TradingView/#published-scripts). My [Delta Volume Channels](https://www.tradingview.com/script/zkBuiFk7-Delta-Volume-Channels-LucF/) and [Volume Delta Columns Pro](https://www.tradingview.com/script/F2ylEYOO-Delta-Volume-Columns-Pro-LucF/) indicators also use intrabar analysis. Other ​volume delta indicators such as my [Realtime 5D Profile](https://www.tradingview.com/script/tNG177SV-Realtime-5D-Profile-LucF/) use realtime chart updates to calculate volume delta without intrabar analysis, but that type of indicator only works in real time; they cannot calculate on historical bars.

This is the logic I use to determine the polarity of intrabars, which determines the up or down slot where its ​volume is added:
 • If the intrabar's [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) and [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) values are different, their relative position is used.
 • If the intrabar's [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) and [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) values are the same, the difference between the intrabar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) and the previous intrabar's [close](https://www.tradingview.com/pine-script-reference/v5/#var_close) is used.
 • As a last resort, when there is no movement during an intrabar, and it closes at the same price as the previous intrabar, the last known polarity is used.

Once all intrabars making up a chart bar have been analyzed and the up or down property of each intrabar's ​volume determined, the up volumes are added, and the down volumes subtracted. The resulting value is ​volume delta for that chart bar, which can be used as an estimate of the buying/selling pressure on an instrument. Not all markets have volume information. Without it, this indicator is useless.

Intrabar analysis

Intrabars are chart bars at a lower timeframe than the chart's. The timeframe used to access intrabars determines the number of intrabars accessible for each chart bar. On a 1H chart, each chart bar of an active market will, for example, usually contain 60 bars at the lower timeframe of 1min, provided there was market activity during each minute of the hour.

This indicator automatically calculates an appropriate lower timeframe using the chart's timeframe and the settings you use in the script's "Intrabars" section of the inputs. As it can access lower timeframes as small as seconds when available, the indicator can be used on charts at relatively small timeframes such as 1min, provided the market is active enough to produce bars at second timeframes.

The quantity of intrabars analyzed in each chart bar determines:
 • The precision of calculations (more intrabars yield more precise results).
 • The chart coverage of calculations (there is a 100K limit to the quantity of intrabars that can be analyzed on any chart, 
  so the more intrabars you analyze per chart bar, the less chart bars can be calculated by the indicator).

The information box displayed at the bottom right of the chart shows the lower timeframe used for intrabars, as well as the average number of intrabars detected for chart bars and statistics on chart coverage.

Balances

This indicator calculates five balances from volume delta values. The balances are oscillators with a zero centerline; positive values are bullish, and negative values are bearish. It is important to understand the balances as they can be used to:
 • Color candle bodies.
 • Calculate body and top and bottom divergences.
 • Color an EMA channel.
 • Color the chart's background.
 • Configure markers and alerts.

The five balances are:

1 — Bar Balance: This is the only balance using instant values; it is simply the subtraction of the down volume​ from the up volume​ on the bar, so the instant volume delta for that bar.
2 — Average Balance: Calculates a distinct EMA for both the up and down volumes, and subtracts the down EMA from the up EMA.
  The result is akin to MACD's histogram because it is the subtraction of two moving averages.
3 — Momentum Balance: Starts by calculating, separately for both up and down volumes, the difference between the same EMAs used in "Average Balance" and
  an SMA of twice the period used for the "Average Balance" EMAs. The difference for the up side is subtracted from the difference for the down side, 
  and an RSI of that value is calculated and brought over the −50/+50 scale.
4 — Relative Balance: The reference values used in the calculation are the up and down EMAs used in the "Average Balance".
  From those, we calculate two intermediate values using how much the instant up and down volumes on the bar exceed their respective EMA — but with a twist.
  If the bar's up volume​ does not exceed the EMA of up volume​, a zero value is used. The same goes for the down volume​ with the EMA of down volume​.
  Once we have our two intermediate values for the up and down volumes exceeding their respective MA, we subtract them. The final value is an ALMA of that subtraction.
  The rationale behind using zero values when the bar's up/down volume​ does not exceed its EMA is to only take into account the more significant volume​.
  If both instant volume​ values exceed their MA, then the difference between the two is the signal's value.
  The signal is called "relative" because the intermediate values are the difference between the instant up/down volumes and their respective MA.
  This balance flatlines when the bar's up/down volumes do not exceed their EMAs, which makes it useful to spot areas where trader interest dwindles, such as consolidations.
  The smaller the period of the final value's ALMA, the more easily it will flatline. These flat zones should be considered no-trade zones. 
5 — Percent Balance: This balance is the ALMA of the ratio of the "Bar Balance" over the total volume for that bar.

From the balances and marker conditions, two more values are calculated:
1 — Marker Bias: This sums the up/down (+1/‒1) occurrences of the markers 1 to 4 over a period you define, so it ranges from −4 to +4, times the period.
  Its calculation will depend on the modes used to calculate markers 3 and 4.
2 — Combined Balances: This is the sum of the bull/bear (+1/−1) states of each of the five balances, so it ranges from −5 to +5.

The periods for all of these balances can be configured in the "Periods" section at the bottom of the script's inputs. As you cannot see the balances on the chart, you can use my [Volume Delta Columns Pro](https://www.tradingview.com/script/F2ylEYOO-Delta-Volume-Columns-Pro-LucF/) indicator in a pane; it can plot the same balances, so you will be able to analyze them.

Divergences

In the context of this indicator, a divergence is any bar where the bear/bull state of a balance (above/below its zero centerline) diverges from the polarity of a chart bar. No directional bias is assigned to divergences when they occur. Candle bodies and tops/bottoms can each be colored differently on divergences detected from distinct balances.

Divergence Channel

The divergence channel is the space between two levels (by default, the bar's [open](https://www.tradingview.com/pine-script-reference/v5/#var_open) and [close](https://www.tradingview.com/pine-script-reference/v5/#var_close)) saved when divergences occur. When price (by default the [close](https://www.tradingview.com/pine-script-reference/v5/#var_close)) has breached a channel and a new divergence occurs, a new channel is created. Until that new channel is breached, bars where additional divergences occur will expand the channel's levels if the bar's price points are outside the channel.

Prices breaches of the divergence channel will change its state. Divergence channels can be in one of three different states:
 • Bull (green): Price has breached the channel to the upside.
 • Bear (red): Price has breached the channel to the downside.
 • Neutral (gray): The channel has not yet been breached.

█ HOW TO USE THE INDICATOR

I do not make videos to explain how to use my indicators. I do, however, try hard to include in their description everything one needs to understand what they do. From there, it's up to you to explore and figure out if they can be useful in your trading practice. Communicating in videos what this description and the script's tooltips contain would make for very long videos that would likely exceed the attention span of most people who find this description too long. There is no quick way to understand an indicator such as this one because it uses many different concepts and has quite a bit of settings one can use to modify its visuals and behavior — thus how one uses it. I will happily answer questions on the inner workings of the indicator, but I do not answer questions like "How do I trade using this indicator?" A useful answer to that question would require an in-depth analysis of who you are, your trading methodology and objectives, which I do not have time for. I do not teach trading.

Start by loading the indicator on an active chart containing volume information. See [here](https://www.tradingview.com/u/?solution=43000555216) if you need help.

The default configuration displays:
 • Normal candles where the bodies are only colored if the bar's volume has increased since the last bar.
  If you want to use this indicator's candles, you may want to disable your chart's candles by clicking the eye icon to the right of the symbol's name in the top left of the chart.
 • A top or bottom appended to the normal candles. It represents the difference between up and down volume for that bar 
  and is positioned at the top or bottom, depending on its polarity. If up volume is greater than down volume, a top is displayed. If down volume is greater, a bottom is plotted. 
  The size of tops and bottoms is determined by calculating a factor which is the proportion of volume delta over the bar's total volume. 
  That factor is then used to calculate the top or bottom size relative to a baseline of the average candle body size of the last 100 bars.
 • An information box in the bottom right displaying intrabar and chart coverage information.
 • A light red background when the intrabar volume differs from the chart's volume by more than 1%.

The script's inputs contain tooltips explaining most of the fields. I will not repeat them here. Following is a brief description of each section of the indicator's inputs which will give you an idea of what the indicator can do:

Normal Candles is where you configure the replacement candles plotted by the script. You can choose from different coloring schemes for their bodies and specify a unique color for bodies where a divergence calculated using the method you choose occurs.

Volume Tops & Botttoms is where you configure the display of tops and bottoms, and their EMAs. The EMAs are calculated from the high point of tops and the low point of bottoms. They can act as a channel to evaluate price, and you can choose to color the channel using a gradient reflecting the advances/declines in the balance of your choice.

Divergence Channel is where you set up the appearance and behavior of the divergence channel. These areas represent levels where price and volume delta information do not converge. They can be interpreted as regions with no clear direction from where one will look for breaches. You can configure the channel to take into account one or both types of divergences you have configured for candle bodies and tops/bottoms.

Background allows you to configure a gradient background color that reflects the advances/declines in the balance of your choice. You can use this to provide context to the volume delta values from bars. You can also control the background color displayed on volume discrepancies between the intrabar and the chart's timeframe.

Intrabars is where you choose the calculation mode determining the lower timeframe used to access intrabars. The indicator uses the chart's timeframe and the type of market you are on to calculate the lower timeframe. Your setting there should reflect which compromise you prefer between the precision of calculations and chart coverage. This is also where you control the display of the information box in the lower right corner of the chart.

Markers allows you to control the plotting of chart markers on different conditions. Their configuration determines when alerts generated from the indicator will fire. Note that in order to generate alerts from this script, they must be created from your chart. See this [Help Center page](https://www.tradingview.com/?solution=43000597494) to learn how. Only the last 500 markers will be visible on the chart, but this will not affect the generation of alerts.

Periods is where you configure the periods for the balances and the EMAs used in the indicator.

The raw values calculated by this script can be inspected using the Data Window.

█ INTERPRETATION

Rightly or wrongly, volume delta is considered by many a useful complement to the interpretation of price action. I use it extensively in an attempt to find convergence between my read of volume delta and price movement — not so much as a predictor of future price movement. No system or person can predict the future. Accordingly, I consider people who speak or act as if they know the future with certainty to be dangerous to themselves and others; they are charlatans, imprudent or blissfully ignorant.

I try to avoid elaborate volume delta interpretation schemes involving too many variables and prefer to keep things simple:
 • Trends that have more chances of continuing should be accompanied by VD of the same polarity.
  In trends, I am looking for "slow and steady". I work from the assumption that traders and systems often overreact, which translates into unproductive volatility. 
  Wild trends are more susceptible to overreactions. 
 • I prefer steady VD values over wildly increasing ones, as large VD increases often come with increased price volatility, which can backfire.
  Large VD values caused by stopping volume will also often occur on trend reversals with abnormally high candles.
 • Prices escaping divergence channels may be leading a trend in that direction, although there is no telling how long that trend will last; could be just a few bars or hundreds.
  When price is in a channel, shifts in VD balances can sometimes give us an idea of the direction where price has the most chance of breaking.
 • Dwindling VD will often indicate trend exhaustion and predate reversals by many bars, but the problem is that mere pauses in a trend will often produce the same behavior in VD.
  I think it is too perilous to infer rigidly from VD decreases.

Divergence Channel

Here I have configured the divergence channels to be visible. First, I set the bodies to display divergences on the default Bar Balance. They are indicated by yellow bodies. Then I activated the divergence channels by choosing to draw levels on body divergences and checked the "Fill" checkbox to fill the channel with the same color as the levels. The divergence channel is best understood as a direction-less area from where a breach can be acted on if other variables converge with the breach's direction:
https://www.tradingview.com/x/S7Oc6uii/

Tops and Bottoms EMAs

I find these EMAs rather interesting. They have no equivalent elsewhere, as they are calculated from the top and bottom values this indicator plots. The only similarity they have with volume-weighted MAs, including VWAP, is that they use price and volume. This indicator's Tops and Bottoms EMAs, however, use the price and volume delta. While the channel differs from other channels in how it is calculated, it can be used like others, as a baseline from which to evaluate price movement or, alternatively, as stop levels. Remember that you can change the period used for the EMAs in the "Periods" section of the inputs.

This chart shows the EMAs in action, filled with a gradient representing the advances/decline from the Momentum balance. Notice the anomaly in the chart's latest bars where the Momentum balance gradient has been indicating a bullish bias for some time, during which price was mostly below the EMAs. Price has just broken above the channel on positive VD. My interpretation of this situation would be that it is a risky opportunity for a long trade in the larger context where the market has been in a downtrend since the 5th. Intrepid traders choosing to enter here could do so with a "make or break" tight stop that will minimize their losses should the market continue its downtrend while hopefully preserving the potential upside of price continuing on the longer-term uptrend prevalent since the 28th:
https://www.tradingview.com/x/3xUUtP57/

█ NOTES

Volume

If you use indicators such as this one which depends on volume information, it is important to realize that the volume data they consume comes from data feeds, and that all data feeds are NOT created equally. Those who create the data feeds we use must make decisions concerning the nature of the transactions they tally and the way they are tallied in each feed, and these decisions affect the nature of our volume data. My [Volume X-ray ](https://www.tradingview.com/script/tPsEizhp-Volume-X-ray-LucF/) publication discusses some of the reasons why volume information from different timeframes, brokers/exchanges or sectors may vary considerably. I encourage you to read it. This indicator's display of a warning through a background color on volume discrepancies between the timeframe used to access intrabars and the chart's timeframe is an attempt to help you realize these variations in feeds. Don't take things for granted, and understand that the quality of a given feed's volume information affects the quality of the results this indicator calculates.

Markets as ecosystems

I believe it is perilous to think that behavioral patterns you discover in one market through the lens of this or any other indicator will necessarily port to other markets. While this may sometimes be the case, it will often not. Why is that? Because each market is its own ecosystem. As cities do, all markets share some common characteristics, but they also all have their idiosyncrasies. A proportion of a city's inhabitants is always composed of outsiders who come and go, but a core population of regulars and systems is usually the force that actually defines most of the city's observable characteristics. I believe markets work somewhat the same way; they may look the same, but if you live there for a while and pay attention, you will notice the idiosyncrasies. Some things that work in some markets will, accordingly, not work in others. Please keep that in mind when you draw conclusions.

On Up/Down or Buy/Sell Volume

Buying or selling volume are misnomers, as every unit of volume transacted is both bought and sold by two different traders. While this does not keep me from using the terms, there is no such thing as “buy only” or “sell only” volume. Trader lingo is riddled with peculiarities. Without access to order book information, traders work with the assumption that when price moves up during a bar, there was more buying pressure than selling pressure, just as when buy market orders take out limit ask orders in the order book at successively higher levels. The built-in volume indicator available on TradingView uses this logic to color the volume columns green or red. While this script’s calculations are more precise because it analyses intrabars to calculate its information, it uses pretty much the same imperfect logic. Until Pine scripts can have access to how much volume was transacted at the bid/ask prices, our volume delta calculations will remain a mere proxy.

Repainting

 • The values calculated on the realtime bar will update as new information comes from the feed.
 • Historical values may recalculate if the historical feed is updated or when calculations start from a new point in history.
 • Markers and alerts will not repaint as they only occur on a bar's close. Keep this in mind when viewing markers on historical bars, 
  where one could understandably and incorrectly assume they appear at the bar's open.

To learn more about repainting, see the [Pine Script™ User Manual's page on the subject](https://www.tradingview.com/pine-script-docs/en/v5/concepts/Repainting.html).

Superfluity

In "The Bed of Procrustes", Nassim Nicholas Taleb writes: To bankrupt a fool, give him information. This indicator can display a lot of information. The inevitable adaptation period you will need to figure out how to use it should help you eliminate all the visuals you do not need. The more you eliminate, the easier it will be to focus on those that are the most useful to your trading practice. Don't be a fool.

█ THANKS

Thanks to [alexgrover](https://www.tradingview.com/u/alexgrover/) for his [Dekidaka-Ashi](https://www.tradingview.com/script/QeqcSffc-Dekidaka-Ashi-Candles-And-Volume-Teaming-Up-Again/) indicator. His volume plots on candles were the inspiration for my top/bottom plots.

Kudos to PineCoders for their libraries. I use two of them in this script: [Time](https://www.tradingview.com/script/UxiDkNg0-lower-tf/) and [lower_tf](https://www.tradingview.com/script/UxiDkNg0-lower-tf/).

The first versions of this script used functionality that I would not have known about were it not for these two guys:
— A guy called Kuan who commented on a [Backtest Rookies presentation](https://backtest-rookies.com/2019/02/15/tradingview-volume-profile-with-lower-time-frame-data/)  of their [Volume Profile](https://www.tradingview.com/script/28iP8MSD-Volume-Profile-Intra-bar-Volume/) indicator.
— [theheirophant](https://www.tradingview.com/u/theheirophant/), my partner in the exploration of the sometimes weird abysses of [request.security()](https://www.tradingview.com/pine-script-reference/v5/#fun_request{dot}security)’s behavior at lower timeframes.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=5
//@author=LucF

// Delta Volume Candles [LucF]
//  v8, 2023.04.09 19:31 — LucF

// This indicator plots replacement candles colored using delta volume calculated with intrabar information. 
// It can also help visualize delta volume by appending top and bottom segments to candles and plotting their averages.

// This code was written using the following:
//  • The recommendations from the Pine Script™ User Manual's Style Guide: https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html
//  • The "lower_tf" library from PineCoders to manage the LTF user selection: https://www.tradingview.com/script/UxiDkNg0-lower-tf/
//  • The "Time" library from PineCoders to convert a TF string into long form for display: https://www.tradingview.com/script/tyeeNU9I-Time/
//  • My "ta" lib which holds many of the functions I use across my scripts: https://www.tradingview.com/script/UZQxuS7X-ta/
//    The `gradientAdvDecPro()` function in that lib comes from the PineCoders Color Gradient Framework: https://www.tradingview.com/script/hqH4YIFa-Color-Gradient-Framework-PineCoders/

// This indicator's page on TV: https://www.tradingview.com/script/h0yZPTiS-Delta-Volume-Candles-LucF/

indicator("Delta Volume Candles [LucF]", "Delta Volume Candles", true, max_labels_count = 500, linktoseries = true)


import PineCoders/Time/2 as PCtime
import PineCoders/lower_tf/4 as PCltf
import LucF/ta/3 as LucfTa



//#region ———————————————————— Constants


// Colors used as defaults in inputs.
color GRAY    = #808080ff
color GREEN   = #008000ff
color LIME    = #00FF00ff
color MAROON  = #800000ff
color ORANGE  = #FF8000ff
color PINK    = #FF0080ff
color RED     = #FF0000ff
color REDLITE = #EF535018
color YELLOW  = #FFFF00ff

// Colors used for Data Window and markers.
color GENERAL_UP_HI = LIME
color GENERAL_DN_HI = RED
color GENERAL_UP_LO = GREEN
color GENERAL_DN_LO = MAROON
color GENERAL_NT    = GRAY

// Input options
string ON  = "On"
string OFF = "Off"

string CB0 = "None"
string CB1 = "Bar Balance"
string CB2 = "Average Balance"
string CB3 = "Momentum Balance"
string CB4 = "Relative Balance"
string CB5 = "Percent Balance"
string CB6 = "Combined Balances"
string CB7 = "Markers Bias"
string CB8 = "Bar polarity (like normal candles)"

string TB0 = "None"
string TB1 = "Up volume on top, down volume at bottom"
string TB2 = "Volume delta on winning side only"
string TB3 = "Momentum Balance on winning side only"

string SR0 = "Each candle's body size"
string SR1 = "Average body size of last 100 bars"

string DL0 = "None"
string DL1 = "Body divergences"
string DL2 = "Top and bottom divergences"
string DL3 = "Both divergences"

string HL0 = "Full Range"
string HL1 = "Top and Bottom"
string HL2 = "Open and Close"
string HL3 = "High and Low"

string DV0 = "Range: Full"
string DV1 = "Range: Top to Bottom"
string DV2 = "Range: Open to Close"
string DV3 = "Range: High to Low"
string DV4 = "Level: Top or Bottom"
string DV5 = "Level: High or Low"
string DV6 = "Level: Close"

string LTF1  = "Covering most chart bars (least precise)"
string LTF2  = "Covering some chart bars (less precise)"
string LTF3  = "Covering less chart bars (more precise)"
string LTF4  = "Covering few chart bars (very precise)"
string LTF5  = "Covering the least chart bars (most precise)"
string LTF6  = "~12 intrabars per chart bar"
string LTF7  = "~24 intrabars per chart bar"
string LTF8  = "~50 intrabars per chart bar"
string LTF9  = "~100 intrabars per chart bar"
string LTF10 = "~250 intrabars per chart bar"

string TD1 = "Both"
string TD2 = "Longs Only"
string TD3 = "Shorts Only"

// Tooltips
string TT_BODIES        = "These choices determine the coloring scheme used for candle bodies only, i.e., not the wicks nor the tops and bottoms. 
  \n\nWhen 'Gradient' is selected, a color gradient is calculated on the advances/declines of the signal used. The gradient has no effect when '" + CB8 + "' is selected).
  \n\nUse 'None' if you do not want the indicator to display candle bodies and wicks so you can use your own candles on charts."
string TT_BODY_DIVS     = "Body divergences occur on discrepancies between the polarity of the bar and that of the specified balance, 
  which is independent from the one used above to determine the color of bodies."
string TT_EMPTY_BODIES  = "Coloring only the body of bars where volume increases can help you identify more significant bars.
  \n\nIf you choose to color bodies on divergences, that setting has precedence over this one."
string TT_BORDERS       = "Borders and wicks are always colored using the bar's polarity."
string TT_TB            = ""
string TT_TB_SIZE       = "This determines the baseline from which the size of tops and bottoms is calculated.
  \n\nWith the first choice, the body size of each candle is used as the baseline. With the second choice an average is used,
  making it easier to appraise the relative size of consecutive tops and bottomes, as their size will be calculated from a more stable baseline."
string TT_TB_DIVS       = "Top and bottom divergences occur on discrepancies between the polarity of the bar and that of the specified balance." 
string TT_DL            = "This controls the type of divergences that will trigger the creation of a new set of levels if the previous levels were breached,
  or the expansion of the current levels if they were not breached yet."
string TT_DL_LEVELS     = "The first selection here controls the levels used to establish or resize levels when a divergence occurs.
  The second choice determines which values must reach outside divergence levels for them to be breached.
  \n\nTogether, these settings control the sensitivity of the levels."
string TT_BRITE         = "0 (darkest) — 100 (brightest)."
string TT_LTF           = "Your selection here controls how many intrabars will be analyzed for each chart bar. 
  The more intrabars you analyze, the more precise the calculations will be,
  but the less chart bars will be covered by the indicator's calculations because a maximum of 100K intrabars can be analyzed.
  \n\nThe first five choices determine the lower timeframe used for intrabars using how much chart coverage you want.
  The last five choices allow you to select approximately how many intrabars you want analyzed per chart bar."
string TT_LTF_BOX       = "Displays the lower timeframe used to access intrabars and intrabar statistics in a configurable position and color."
string TT_MARKER1       = "A bump up occurs when: 
  \n• The bar's polarity is up.
  \n• The `close` is higher than the previous bar's `close`.
  \n• Bar Balance (VD) is positive.
  \n• Up volume is greater than the EMA of up volume calculated in the Average Balance.
  \n• Up volume is greater than the previous bar's up volume.
  \n\nA bump down occurs when:
  \n• The bar's polarity is down.
  \n• The `close` is lower than the previous bar's `close`.
  \n• Bar Balance (VD) is negative.
  \n• Down volume is greater than the EMA of down volume calculated in the Average Balance.
  \n• Down volume is greater (more negative) than the previous bar's down volume."
string TT_MARKER2       = "A double bump is two consecutive bumps up or down."
string TT_MARKER3       = "A divergence is confirmed up/dn when the chosen balance is up/dn on the previous bar when that bar was dn/up, and this bar is up/dn."
string TT_MARKER4       = "Balance shifts occur when the chosen balance crosses into bull/bear territory."
string TT_MARKER5       = "Marker bias shifts occur when it crosses into bull/bear territory."
string TT_MARKER6       = "All balances are bull or bear."
string TT_TEXT_UP       = "This text will replace the alert message for up alerts."
string TT_TEXT_DN       = "This text will replace the alert message for down alerts."
string TT_VOL_DISC      = "This displays a background coloron historical bars to indicate that the volume from the chart's timeframe does not match the sum of intrabar volume.
  \n\nDiscrepancies occur when the two values differ by more than the percentage in the 'Tolerance' field, where '1' indicates 1%.
  \n\nSee my 'Volume X-ray' indicator's description for an explanation of why this occurs."
//#endregion



//#region ———————————————————— Inputs


string  GP00 = "Normal Candles"
string  bodyColorCalcInput           = input.string(CB8,             "Color bodies on",                         inline = "bodies", group = GP00, options = [CB0, CB8, CB1, CB2, CB3, CB4, CB5, CB6])
color   bodyUpColorInput             = input.color(GREEN,            "",                                        inline = "bodies", group = GP00)
color   bodyDnColorInput             = input.color(MAROON,           "",                                        inline = "bodies", group = GP00, tooltip = TT_BODIES)
bool    bodyGradientInput            = input.bool(false,             "Gradient",                                inline = "bodies", group = GP00)
bool    bodyShowDivInput             = input.bool(false,             "Body divergences calculated on",          inline = "bodyDivs", group = GP00)
string  bodyDivModeInput             = input.string(CB1,             "",                                        inline = "bodyDivs", group = GP00, options = [CB0, CB1, CB2, CB3, CB4, CB5, CB6])
color   bodyDivColorInput            = input.color(YELLOW,           "",                                        inline = "bodyDivs", group = GP00, tooltip = TT_BODY_DIVS)
bool    bodyHollowOnDecVolInput      = input.bool(true,              "Empty bodies on decreasing volume",       group = GP00, tooltip = TT_EMPTY_BODIES)
color   borderWickUpColorInput       = input.color(GREEN,            "Borders & wicks ",                        inline = "b&w", group = GP00)
color   borderWickDnColorInput       = input.color(MAROON,           "",                                        inline = "b&w", group = GP00, tooltip = TT_BORDERS)

string  GP01 = "Volume Tops & Bottoms"
string  topBotRefModeInput           = input.string(SR1,             "Size tops and bottoms relative to",       inline = "ref", group = GP01, options = [SR0, SR1], tooltip = TT_TB_SIZE)
string  topBotModeInput              = input.string(TB2,             "Display",                                 inline = "tbCalc", group = GP01, options = [TB0, TB1, TB2, TB3])
color   topBotBodyUpColorInput       = input.color(LIME,             "Fills: ",                                 inline = "tbCalc", group = GP01)
color   topBotBodyDnColorInput       = input.color(RED,              "",                                        inline = "tbCalc", group = GP01)
color   topBotWickUpColorInput       = input.color(LIME,             "Borders: ",                               inline = "tbCalc", group = GP01)
color   topBotWickDnColorInput       = input.color(PINK,             "",                                        inline = "tbCalc", group = GP01, tooltip = TT_TB)
bool    topBotShowDivInput           = input.bool(false,             "Top & bottom divergences calculated on",  inline = "tbDivs", group = GP01)
string  topBotDivModeInput           = input.string(CB2,             "",                                        inline = "tbDivs", group = GP01, options = [CB0, CB1, CB2, CB3, CB4, CB5, CB6])
color   topBotDivColorInput          = input.color(ORANGE,           "",                                        inline = "tbDivs", group = GP01, tooltip = TT_TB_DIVS)
bool    showMasInput                 = input.bool(false,             "Show EMAs of tops/bottoms",               inline = "mas", group = GP01)
color   maUpColorInput               = input.color(GREEN,            "",                                        inline = "mas", group = GP01)
color   maDnColorInput               = input.color(MAROON,           "",                                        inline = "mas", group = GP01)
string  maFillCalcInput              = input.string(CB1,             "Color the EMA channel on",                inline = "masColor", group = GP01, options = [CB0, CB1, CB2, CB3, CB4, CB5, CB6])
color   maFillUpColorInput           = input.color(GREEN,            "",                                        inline = "masColor", group = GP01)
color   maFillDnColorInput           = input.color(MAROON,           "",                                        inline = "masColor", group = GP01)

string  GP02 = "Divergence Channel"
string  divLevelsModeInput           = input.string(DL0,             "Draw levels on",                          inline = "divsLevels", group = GP02, options = [DL0, DL1, DL2, DL3])
color   divLevelsBullColorInput      = input.color(GREEN,            "",                                        inline = "divsLevels", group = GP02)
color   divLevelsBearColorInput      = input.color(MAROON,           "",                                        inline = "divsLevels", group = GP02)
color   divLevelsNeutColorInput      = input.color(GRAY,             "",                                        inline = "divsLevels", group = GP02, tooltip = TT_DL)
string  divLevelsModeHiLoInput       = input.string(HL2,             "Hi/Lo levels",                            inline = "hiLoLevels", group = GP02, options = [HL0, HL1, HL2, HL3])
string  divLevelsModeHiLoRefInput    = input.string(DV6,             "Breach reference",                        inline = "hiLoLevels", group = GP02, options = [DV0, DV1, DV2, DV3, DV4, DV5, DV6], tooltip = TT_DL_LEVELS)
bool    divLevelsFillInput           = input.bool(false,             "Fill",                                    inline = "fillLevels", group = GP02)
float   divLevelsFillBriteInput      = 100 - input.int(50,           "🔆",                                      inline = "fillLevels", group = GP02, minval = 0, maxval = 100, step = 5, tooltip = TT_BRITE)

string  GP03 = "Background"
string  bgCalcInput                  = input.string(CB0,             "Color On",                                inline = "31", group = GP03, options = [CB0, CB1, CB2, CB3, CB4, CB5, CB6])
color   bgUpColorInput               = input.color(GREEN,            "",                                        inline = "31", group = GP03)
color   bgDnColorInput               = input.color(MAROON,           "",                                        inline = "31", group = GP03)
float   bgBriteInput                 = 100 - input.int(30,           "🔆",                                      inline = "31", group = GP03, minval = 0, maxval = 100, step = 5, tooltip = TT_BRITE)
bool    volDiscShowInput             = input.bool(true,              "Show volume discrepancies",               inline = "volDiscs", group = GP03)
color   volDiscColorInput            = input.color(REDLITE,          "",                                        inline = "volDiscs", group = GP03)
float   volDiscToleranceInput        = input.float(1.,               "Tolerance (%)",                           inline = "volDiscs", group = GP03, minval = 0., step = 0.25, tooltip = TT_VOL_DISC) / 100

string  GP04 = "Intrabars"
string  ltfModeInput                 = input.string(LTF9,            "Intrabar precision",                      options = [LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10], group = GP04, tooltip = TT_LTF)
bool    showInfoBoxInput             = input.bool(true,              "Show information box",                    group = GP04, tooltip = TT_LTF_BOX)
string  infoBoxSizeInput             = input.string("small",         "Size ",                                   inline = "infoBox", group = GP04, options = ["tiny", "small", "normal", "large", "huge", "auto"])
string  infoBoxYPosInput             = input.string("bottom",        "↕",                                       inline = "infoBox", group = GP04, options = ["top", "middle", "bottom"])
string  infoBoxXPosInput             = input.string("right",         "↔",                                       inline = "infoBox", group = GP04, options = ["left", "center", "right"])
color   infoBoxColorInput            = input.color(color.gray,     "",                                        inline = "infoBox", group = GP04)
color   infoBoxTxtColorInput         = input.color(color.black,    "T",                                       inline = "infoBox", group = GP04)

string  GP05 = "Markers"
string  markerDirInput               = input.string(TD1,             "Direction",                               inline = "dir", group = GP05, options = [TD1, TD2, TD3])
bool    showMarker1Input             = input.bool(false,             "Marker 1: bumps",                         group = GP05, tooltip = TT_MARKER1)
bool    showMarker2Input             = input.bool(false,             "Marker 2: double bumps",                  group = GP05, tooltip = TT_MARKER2)
bool    showMarker3Input             = input.bool(false,             "Marker 3: divergence confirmations",      inline = "m3", group = GP05, tooltip = TT_MARKER3)
string  marker3ModeInput             = input.string(CB1,             "on",                                      inline = "m3", group = GP05, options = [CB1, CB2, CB3, CB4, CB5, CB6])
bool    showMarker4Input             = input.bool(false,             "Marker 4: Balance shifts",                inline = "m4", group = GP05, tooltip = TT_MARKER4)
string  marker4ModeInput             = input.string(CB2,             "on",                                      inline = "m4", group = GP05, options = [CB2, CB3, CB4, CB5, CB6])
bool    showMarker5Input             = input.bool(false,             "Marker 5: Markers Bias shifts",           group = GP05, tooltip = TT_MARKER5)
bool    showMarker6Input             = input.bool(false,             "Marker 6: All balances agree",            group = GP05, tooltip = TT_MARKER6)
string  alertMsgUpInput              = input.text_area("",           "Up alert message",                        group = GP05, tooltip = TT_TEXT_UP)
string  alertMsgDnInput              = input.text_area("",           "Down alert message",                      group = GP05, tooltip = TT_TEXT_DN)

string  GP06 = "Periods"
int     balAvgPeriodInput            = input.int(50,                 "Average Balance",                         group = GP06, minval = 2)
int     balMomPeriodInput            = input.int(14,                 "Momentum Balance",                        group = GP06, minval = 2)
int     balRelPeriodInput            = input.int(14,                 "Relative Balance",                        group = GP06, minval = 1)
int     balPctPeriodInput            = input.int(14,                 "Percent Balance",                         group = GP06, minval = 1)
int     biasPeriodInput              = input.int(14,                 "Markers Bias",                            group = GP06, minval = 2)
int     topBotMasPeriodInput         = input.int(14,                 "Tops/Bottoms EMAs",                       group = GP06, minval = 1)
//#endregion



//#region ———————————————————— Calculations


// ————— Calculate DV using LTF intrabars.
// Determine intrabar LTF.
string intrabarTf = PCltf.ltf(ltfModeInput, LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10)
// Fetch two arrays containing one element per intrabar. One array contains up volume values (positive), the other down volume values (negative). Volume for each intrabar is either up or down.
[ltfVolumesUp, ltfVolumesDn] = request.security_lower_tf(syminfo.tickerid, intrabarTf, LucfTa.upDnIntrabarVolumesByPolarity())
// Total up/dn volumes for intrabars.
float ltfVolUp = nz(array.sum(ltfVolumesUp))
float ltfVolDn = nz(array.sum(ltfVolumesDn))

// ———— Intrabar stats
[intrabars, chartBarsCovered, avgIntrabars] = PCltf.ltfStats(ltfVolumesUp)
int chartBars = bar_index + 1

// ————— Bar polarity.
bool  barUp = close > open
bool  barDn = close < open
bool  closeUp = ta.rising(close, 1)
bool  closeDn = ta.falling(close, 1)

// ————— Rising volume.
bool  volUp = ta.rising(volume, 1)

// ————— Total intrabar volume for the bar.
float volB = ltfVolUp
float volS = - ltfVolDn
float volT = volB + volS

// ————— Determine if intrabar volume is available for the symbol.
bool  intrabarVolumeIsAvailable = ta.cum(nz(volT)) != 0

// ————— Bar Balance (Volume Delta) (CB1).
float balBar          = volB - volS
bool  balBarBull      = balBar > 0
bool  balBarBear      = balBar < 0
// ————— Average Balance (CB2).
float balAvgBMa       = ta.ema(volB, balAvgPeriodInput)
float balAvgSMa       = ta.ema(volS, balAvgPeriodInput)
float balAvg          = balAvgBMa - balAvgSMa
bool  balAvgBull      = balAvg > 0
bool  balAvgBear      = balAvg < 0
// ————— Momentum Balance (CB3).
float balMomBMa       = ta.sma(volB, balAvgPeriodInput * 2)
float balMomSMa       = ta.sma(volS, balAvgPeriodInput * 2)
float balMomBMaDelta  = balAvgBMa - balMomBMa
float balMomSMaDelta  = balAvgSMa - balMomSMa
float balMomDeltaDelta= balMomBMaDelta - balMomSMaDelta
float balMom          = ta.rsi(balMomDeltaDelta, balMomPeriodInput) - 50
bool  balMomBull      = balMom > 0
bool  balMomBear      = balMom < 0
// ————— Relative Balance (CB4).
float volUpDelta      = math.max(0, volB - balAvgBMa)
float volDnDelta      = math.max(0, volS - balAvgSMa)
float balRel          = ta.alma(volUpDelta - volDnDelta, balRelPeriodInput, 0.85, 6)
bool  balRelBull      = balRel > 0
bool  balRelBear      = balRel < 0
// ————— Percent Balance (CB5).
float balPct          = ta.alma(100 * balBar / volume, balPctPeriodInput, 0.85, 6)
bool  balPctBull      = balPct > 0
bool  balPctBear      = balPct < 0
// ————— Combined Balances (CB6).
int   BALANCES_QTY    = 5
float balAll          = LucfTa.zeroOne(balBarBull) + LucfTa.zeroOne(balAvgBull) + LucfTa.zeroOne(balMomBull) + LucfTa.zeroOne(balRelBull) + LucfTa.zeroOne(balPctBull) 
                      - LucfTa.zeroOne(balBarBear) - LucfTa.zeroOne(balAvgBear) - LucfTa.zeroOne(balMomBear) - LucfTa.zeroOne(balRelBear) - LucfTa.zeroOne(balPctBear)
bool  balAllBull      = balAll > 0
bool  balAllBear      = balAll < 0

// ————— Size of tops and bottoms
float bodyTop       = math.max(close, open)
float bodyBot       = math.min(close, open)
float bodySize      = bodyTop - bodyBot
float referenceSize = switch topBotRefModeInput
    SR0 => bodySize
    SR1 => ta.sma(bodySize, 100)
    => na
float topFactor = switch topBotModeInput
    TB1 => volB / volT
    TB2 => balBar > 0 ? balBar / volT : na
    TB3 => balAll > 0 ? balAll / BALANCES_QTY : na
    => na
float botFactor = switch topBotModeInput
    TB1 => volS / volT
    TB2 => balBar < 0 ? math.abs(balBar / volT) : na
    TB3 => balAll < 0 ? math.abs(balAll / BALANCES_QTY) : na
    => na
float volTop = bodyTop + (referenceSize * topFactor)
float volBot = bodyBot - (referenceSize * botFactor)


// @function            Converts the type of balance to its actual value.
// @param balance       (string) The string identifying the type of balance.
// @returns             (float) The value of the balance.
markerSignal(string balance) =>
    float result = 
      switch balance
        CB1 => balBar
        CB2 => balAvg
        CB3 => balMom
        CB4 => balRel
        CB5 => balPct
        CB6 => balAll
        => na


// @function            Detects a divergence for a given balance, i.e., a difference in the polarity of the balance and the bar.
// @param balance       (string) The string identifying the type of balance.
// @returns             (bool) `true` when a divergence occurred, `false` otherwise.
divFromMode(string balance) =>
    bool result = math.sign(markerSignal(balance)) != math.sign(close - open)


// ————— Marker calcs
// User-selected marker directions.
bool doLongs     = markerDirInput == TD1 or markerDirInput == TD2
bool doShorts    = markerDirInput == TD1 or markerDirInput == TD3
// Marker conditions 1 to 4
bool  bumpUp     = barUp and closeUp and balBarBull and volB > balAvgBMa and ta.rising(volB, 1)
bool  bumpDn     = barDn and closeDn and balBarBear and volS > balAvgSMa and ta.rising(volS, 1)
bool  div        = divFromMode(marker3ModeInput)
bool  c1U        = bumpUp
bool  c1D        = bumpDn
bool  c2U        = bumpUp and bumpUp[1]
bool  c2D        = bumpDn and bumpDn[1]
bool  c3U        = div[1] and barUp and not div
bool  c3D        = div[1] and barDn and not div
bool  c4U        = ta.crossover( markerSignal(marker4ModeInput), 0)
bool  c4D        = ta.crossunder(markerSignal(marker4ModeInput), 0)
// Marker bias needed for marker 5.
float cUps       = LucfTa.zeroOne(c1U) + LucfTa.zeroOne(c2U) + LucfTa.zeroOne(c3U) + LucfTa.zeroOne(c4U)
float cDns       = LucfTa.zeroOne(c1D) + LucfTa.zeroOne(c2D) + LucfTa.zeroOne(c3D) + LucfTa.zeroOne(c4D)
float balMrk     = math.sum(cUps - cDns, biasPeriodInput)
bool  balMrkBull = balMrk > 0
bool  balMrkBear = balMrk < 0
// Marker conditions 5 and 6
bool  c5U        = ta.crossover( balMrk, 0)
bool  c5D        = ta.crossunder(balMrk, 0)
bool  c6U        = balAll ==   BALANCES_QTY
bool  c6D        = balAll == - BALANCES_QTY
// Assembly.
bool  a1U        = showMarker1Input and doLongs  and c1U
bool  a1D        = showMarker1Input and doShorts and c1D
bool  a2U        = showMarker2Input and doLongs  and c2U
bool  a2D        = showMarker2Input and doShorts and c2D
bool  a3U        = showMarker3Input and doLongs  and c3U
bool  a3D        = showMarker3Input and doShorts and c3D
bool  a4U        = showMarker4Input and doLongs  and c4U
bool  a4D        = showMarker4Input and doShorts and c4D
bool  a5U        = showMarker5Input and doLongs  and c5U
bool  a5D        = showMarker5Input and doShorts and c5D
bool  a6U        = showMarker6Input and doLongs  and c6U
bool  a6D        = showMarker6Input and doShorts and c6D

// ————— Divergence levels
// Detect divergences.
bool  bodyDiv      = intrabarVolumeIsAvailable and divFromMode(bodyDivModeInput)
bool  topBotDiv    = intrabarVolumeIsAvailable and divFromMode(topBotDivModeInput)
bool  divLevelsDiv = switch divLevelsModeInput
    DL1 => bodyDiv
    DL2 => topBotDiv
    DL3 => bodyDiv or topBotDiv
    => false
// Determine reference and breach levels for the divergence channel.
float divLevelsHiNew = switch divLevelsModeHiLoInput
    HL0 => math.max(nz(volTop, high), high)
    HL1 => nz(volTop, high)
    HL2 => bodyTop
    HL3 => high
    => high
float divLevelsLoNew = switch divLevelsModeHiLoInput
    HL0 => math.min(nz(volBot, low), low)
    HL1 => nz(volBot, low)
    HL2 => bodyBot
    HL3 => low
    => low
float divLevelsHiRef = switch divLevelsModeHiLoRefInput
    DV0 => math.min(nz(volBot, low), low)
    DV1 => nz(volBot, low)
    DV2 => bodyBot
    DV3 => low
    DV4 => nz(volTop, high)
    DV5 => high
    DV6 => close
    => close
float divLevelsLoRef = switch divLevelsModeHiLoRefInput
    DV0 => math.max(nz(volTop, high), high)
    DV1 => nz(volTop, high)
    DV2 => bodyTop
    DV3 => high
    DV4 => nz(volBot, low)
    DV5 => low
    DV6 => close
    => close
// Update the divergence channel.
[divLevelsHi, divLevelsLo, divLevelsHState, divLevelsLState, divLevelsBreached, divLevelsChanged, _, _] = 
  LucfTa.divergenceChannel(divLevelsDiv, divLevelsHiNew, divLevelsLoNew, divLevelsHiRef, divLevelsLoRef)
bool  divLevelsNState = not (divLevelsHState or divLevelsLState)
//#endregion



//#region ———————————————————— Visuals

// @function            Determines the correct number of steps to be used in gradient for each type of balance.
// @param signalCalc    (simple string) The string identifying the type of balance.
// @returns             (int) The number of steps.
gradientSteps(simple string signalCalc) =>
    int result = signalCalc == CB8 ? 4 : 8

// @function            Converts the type of balance to its actual value.
// @param signalCalc    (string) The string identifying the type of balance.
// @returns             (float) The value of the balance.
signal(string signalCalc) => 
    float result = switch signalCalc
        CB1 => balBar
        CB2 => balAvg
        CB3 => balMom
        CB4 => balRel
        CB5 => balPct
        CB6 => balAll
        CB7 => balMrk
        CB8 => close - open
        => na

// ————— Data Window
plotLocations = display.data_window + display.status_line
plot(balBar,              "Volume Delta",       balBarBull ? GENERAL_UP_HI : GENERAL_DN_HI,  display = plotLocations)
plot(100 * balBar / volT, "Volume Delta %",     balBarBull ? GENERAL_UP_HI : GENERAL_DN_HI,  display = plotLocations)
plot(volB,                "Up Volume",          balBarBull ? GENERAL_UP_HI : GENERAL_UP_LO,  display = plotLocations)
plot(volS,                "Dn Volume",          balBarBear ? GENERAL_DN_HI : GENERAL_DN_LO,  display = plotLocations)
plot(volT,                "Intrabar Volume",    balBarBull ? GENERAL_UP_HI : GENERAL_DN_HI,  display = plotLocations)
plot(volume,              "Chart bar Volume",   balBarBull ? GENERAL_UP_HI : GENERAL_DN_HI,  display = plotLocations)
plot(na,                  "═════════════",      GENERAL_NT,                                  display = plotLocations)
plot(balBar,              "Bar Balance",        balBarBull ? GENERAL_UP_HI : GENERAL_DN_HI,  display = plotLocations)
plot(balAvg,              "Average Balance",    balAvgBull ? GENERAL_UP_HI : GENERAL_DN_HI,  display = plotLocations)
plot(balMom,              "Momentum Balance ",  balMomBull ? GENERAL_UP_HI : GENERAL_DN_HI,  display = plotLocations)
plot(balRel,              "Relative Balance",   balRelBull ? GENERAL_UP_HI : GENERAL_DN_HI,  display = plotLocations)
plot(balPct,              "Percent Balance",    balPctBull ? GENERAL_UP_HI : GENERAL_DN_HI,  display = plotLocations)
plot(balAll,              "Combined Balances",  balAllBull ? GENERAL_UP_HI : GENERAL_DN_HI,  display = plotLocations)
plot(balMrk,              "Marker Bias",        balMrkBull ? GENERAL_UP_HI : GENERAL_DN_HI,  display = plotLocations)
plot(na,                  "═════════════",      GENERAL_NT,                                  display = plotLocations)
plot(volTop,              "Top",                GENERAL_UP_HI,                               display = plotLocations)
plot(volBot,              "Bottom",             GENERAL_DN_HI,                               display = plotLocations)

// ————— Divergence levels
color divLevelsColor = divLevelsHState ? divLevelsBullColorInput : divLevelsLState ? divLevelsBearColorInput : divLevelsNeutColorInput
divLevelsHiPlot = plot(divLevelsModeInput != CB0 ? divLevelsHi : na, "Divergence Hi Level", divLevelsChanged ? na : divLevelsColor)
divLevelsLoPlot = plot(divLevelsModeInput != CB0 ? divLevelsLo : na, "Divergence Lo Level", divLevelsChanged ? na : divLevelsColor)
fill(divLevelsHiPlot, divLevelsLoPlot, divLevelsFillInput and not divLevelsChanged ? color.new(divLevelsColor, divLevelsFillBriteInput) : na)

// ————— Tops/Bottoms
var color borderBriteTop = color.new(topBotBodyUpColorInput, 0)
var color borderBriteBot = color.new(topBotBodyDnColorInput, 0)
bool buyWins = nz(topFactor) > nz(botFactor)
color topsColor = topBotShowDivInput and topBotDiv ? topBotDivColorInput : buyWins ? topBotBodyUpColorInput : na
color botsColor = topBotShowDivInput and topBotDiv ? topBotDivColorInput : buyWins ? na : topBotBodyDnColorInput
color topsBorderColor = topBotShowDivInput and topBotDiv ? topBotDivColorInput : buyWins ? borderBriteTop : topBotBodyUpColorInput
color botsBorderColor = topBotShowDivInput and topBotDiv ? topBotDivColorInput : buyWins ? topBotBodyDnColorInput : borderBriteBot
plotcandle(bodyTop, volTop, bodyTop, volTop, "Tops",    buyWins ? topsColor : na, bordercolor = topBotWickUpColorInput, display = display.pane)
plotcandle(bodyBot, volBot, bodyBot, volBot, "Bottoms", buyWins ? na : botsColor, bordercolor = topBotWickDnColorInput, display = display.pane)

// ————— MAs
color masFillColor = LucfTa.gradientAdvDecPro(signal(maFillCalcInput), 0, gradientSteps(maFillCalcInput), color.new(maFillDnColorInput, 90), maFillDnColorInput, color.new(maFillUpColorInput, 90), maFillUpColorInput)
topsPlot = plot(showMasInput ? ta.ema(fixnan(volTop), topBotMasPeriodInput) : na, "Tops MA",     maUpColorInput)
botsPlot = plot(showMasInput ? ta.ema(fixnan(volBot), topBotMasPeriodInput) : na, "Botttoms MA", maDnColorInput)
fill(topsPlot, botsPlot, masFillColor)

// ————— Normal candles
// Build colors.
float bodySignal = signal(bodyColorCalcInput)
bool  bodyBull   = bodySignal > 0
bool  bodyBear   = bodySignal < 0
color bodyGradientColor = LucfTa.gradientAdvDecPro(bodySignal, 0, gradientSteps(bodyColorCalcInput), color.new(bodyDnColorInput, 90), bodyDnColorInput, color.new(bodyUpColorInput, 90), bodyUpColorInput)
color bodyColor  = switch
    bodyColorCalcInput == CB0 => na
    bodyShowDivInput and bodyDiv => bodyDivColorInput
    bodyHollowOnDecVolInput and not volUp => na
    bodyColorCalcInput != CB8 and bodyGradientInput => bodyGradientColor
    bodyBull => bodyUpColorInput
    bodyBear => bodyDnColorInput
    => na
color bordersAndWicksColor = switch
    bodyColorCalcInput == CB0 => na
    barUp => borderWickUpColorInput
    => borderWickDnColorInput
// Plot candles.
plotcandle(open, high, low, close, "Candle Structure", color = bodyColor, wickcolor = bordersAndWicksColor, bordercolor = bordersAndWicksColor, display = display.pane)

// ————— Background
var color bgUpLoColor = color.new(bgUpColorInput, math.max(90, bgBriteInput))
var color bgUpHiColor = color.new(bgUpColorInput, bgBriteInput)
var color bgDnLoColor = color.new(bgDnColorInput, math.max(90, bgBriteInput))
var color bgDnHiColor = color.new(bgDnColorInput, bgBriteInput)
color bgFillColor = LucfTa.gradientAdvDecPro(signal(bgCalcInput), 0, gradientSteps(bgCalcInput), bgDnLoColor, bgDnHiColor, bgUpLoColor, bgUpHiColor)
bool volDiscrepancy = math.abs(volT - volume) / volume > volDiscToleranceInput
bgcolor(not barstate.isrealtime and volDiscShowInput and volDiscrepancy and color.t(volDiscColorInput) != 100 ? volDiscColorInput : bgFillColor)

// ————— Information box
// Display information box only once on the last historical bar, instead of on all realtime updates, as when `barstate.islast` is used.
if showInfoBoxInput and barstate.islastconfirmedhistory
    var table infoBox = table.new(infoBoxYPosInput + "_" + infoBoxXPosInput, 1, 1)
    color infoBoxBgColor = infoBoxColorInput
    string txt = str.format(
      "Uses intrabars at {0}\nAvg intrabars per chart bar: {1,number,#.##}\nChart bars covered: {2} / {3} ({4,number,percent})", 
      PCtime.formattedNoOfPeriods(timeframe.in_seconds(intrabarTf) * 1000), 
      avgIntrabars, chartBarsCovered, bar_index + 1, chartBarsCovered / (bar_index + 1))
    if avgIntrabars < 5
        txt := "This quantity of intrabars is dangerously small.\nResults will not be as reliable with so few.\n\n" + txt
        infoBoxBgColor := color.red
    else if not intrabarVolumeIsAvailable
        txt := "No intrabar volume exists for the symbol.\nCannot calculate values.\n\n" + txt
        infoBoxBgColor := color.red
    table.cell(infoBox, 0, 0, txt, text_color = infoBoxTxtColorInput, text_size = infoBoxSizeInput, bgcolor = infoBoxBgColor)

// ————— Markers and alerts
// Only process markers and alerts on the bar's close.
if barstate.isconfirmed
    topPos = math.max(nz(volTop), high)
    botPos = math.min(nz(volBot, 10e15), low)
    array<bool> markerCondUps = array.from(a1U, a2U, a3U, a4U, a5U, a6U)
    array<bool> markerCondDns = array.from(a1D, a2D, a3D, a4D, a5D, a6D)
    // Build marker label's text from user-selected marker conditions.
    string labelMsgUp   = ""
    string labelMsgDn   = ""
    bool   triggerLong  = false
    bool   triggerShort = false
    for markerNo = 0 to array.size(markerCondUps) - 1
        bool cUp = array.get(markerCondUps, markerNo)
        bool cDn = array.get(markerCondDns, markerNo)
        triggerLong  := triggerLong  or cUp
        triggerShort := triggerShort or cDn
        labelMsgUp   := LucfTa.addTextIf(cUp, labelMsgUp, "M" + str.tostring(markerNo + 1) + "▲", "\n")
        labelMsgDn   := LucfTa.addTextIf(cDn, labelMsgDn, "M" + str.tostring(markerNo + 1) + "▼", "\n")
    // Display marker and generate alert when needed.
    if triggerLong
        alert(alertMsgUpInput == "" ? labelMsgUp : alertMsgUpInput, alert.freq_once_per_bar)
        label.new(bar_index, botPos, labelMsgUp, style = label.style_label_up, color = color(na), textcolor = GENERAL_UP_HI)
    if triggerShort
        alert(alertMsgDnInput == "" ? labelMsgDn : alertMsgDnInput, alert.freq_once_per_bar)
        label.new(bar_index, topPos, labelMsgDn, style = label.style_label_down, color = color(na), textcolor = GENERAL_DN_HI)
//#endregion
````
