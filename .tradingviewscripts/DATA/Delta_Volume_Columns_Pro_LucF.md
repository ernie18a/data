<!-- tradingview-pine-id: PUB;NLRx5KoTBJgEqhzzoiNhRnBSxYzLTS2D -->
<!-- tradingviewscripts-format: 1 -->
# Delta Volume Columns Pro [LucF]

Source: https://www.tradingview.com/script/F2ylEYOO-Delta-Volume-Columns-Pro-LucF/

## Description

█ OVERVIEW

This indicator displays volume​​ delta information calculated with intrabar inspection on historical bars, and feed updates when running in realtime. It is designed to run in a pane and can display either stacked buy/sell volume​ columns or a signal line which can be calculated and displayed in many different ways.

Five different models are offered to reveal different characteristics of the calculated volume​ delta information. Many options are offered to visualize the calculations, giving you much leeway in morphing the indicator's visuals to suit your needs. If you value delta volume​ information, I hope you will find the time required to master Delta Volume​ Columns Pro well worth the investment. I am confident that if you combine a proper understanding of the indicator's information with an intimate knowledge of the volume​ idiosyncrasies on the markets you trade, you can extract useful market intelligence using this tool.

█ WARNINGS

1. The indicator only works on markets where volume​ information is available, 
  Please validate that your symbol's feed carries volume​ information before asking me why the indicator doesn't plot values.
2. When you refresh your chart or re-execute the script on the chart, the indicator will repaint because elapsed realtime bars will then recalculate as historical bars.
3. Because the indicator uses different modes of calculation on historical and realtime bars, it's critical that you understand the differences between them. Details are provided further down.
4. Calculations using intrabar inspection on historical bars can only be done from some chart timeframes. See further down for a list of supported timeframes.
  If the chart's timeframe is not supported, no historical volume​ delta will display.

█ CONCEPTS

Chart bars
Three different types of bars are used in charts:
 1. Historical bars are bars that have already closed when the script executes on them. 
 2. The realtime bar is the current, incomplete bar where a script is running on an open market. There is only one active realtime bar on your chart at any given time.
   The realtime bar is where alerts trigger.
 3. Elapsed realtime bars are bars that were calculated when they were realtime bars but have since closed. 
   When a script re-executes on a chart because the browser tab is refreshed or some of its inputs are changed, elapsed realtime bars are recalculated as historical bars.

Why does this indicator use two modes of calculation?
Historical bars on TradingView charts contain OHLCV data only, which is insufficient to calculate volume​ delta on them with any level of precision. To mine more detailed information from those bars we look at intrabars, i.e., bars from a smaller timeframe (we call it the intrabar timeframe) that are contained in one chart bar. If your chart Is running at 1D on a 24x7 market for example, most 1D chart bars will contain 24 underlying 1H bars in their dilation. On historical bars, this indicator looks at those intrabars to amass volume​ delta information. If the intrabar is up, its volume​ goes in the Buy bin, and inversely for the Sell bin. When price does not move on an intrabar, the polarity of the last known movement is used to determine in which bin its volume​ goes.

In realtime, we have access to price and volume​ change for each update of the chart. Because a 1D chart bar can be updated tens of thousands of times during the day, volume​ delta calculations on those updates is much more precise. This precision, however, comes at a price:
 — The script must be running on the chart for it to keep calculating in realtime.
 — If you refresh your chart you will lose all accumulated realtime calculations on elapsed realtime bars, and the realtime bar.
  Elapsed realtime bars will recalculate as historical bars, i.e., using intrabar inspection, and the realtime bar's calculations will reset.
  When the script recalculates elapsed realtime bars as historical bars, the values on those bars will change, which means the script repaints in those conditions.
 — When the indicator first calculates on a chart containing an incomplete realtime bar, it will count ALL the existing volume​ on the bar as Buy or Sell volume​, 
  depending on the polarity of the bar at that point. This will skew calculations for that first bar. Scripts have no access to the history of a realtime bar's previous updates, 
  and intrabar inspection cannot be used on realtime bars, so this is the only to go about this.
 — Even if alerts only trigger upon confirmation of their conditions after the realtime bar closes, they are repainting alerts 
  because they would perhaps not have calculated the same way using intrabar inspection.
 — On markets like stocks that often have different EOD​ and intraday feeds and volume​ information,
  the volume's scale may not be the same for the realtime bar if your chart is at 1D, for example, 
  and the indicator is using an intraday timeframe to calculate on historical bars.
 — Any chart timeframe can be used in realtime mode, but plots that include moving averages in their calculations may require many elapsed realtime bars before they can calculate.
  You might prefer drastically reducing the periods of the moving averages, or using the volume​ columns mode, which displays instant values, instead of the line.

Volume Delta Balances
This indicator uses a variety of methods to evaluate five volume​ delta balances and derive other values from those balances. The five balances are:
1 — On Bar Balance: This is the only balance using instant values; it is simply the subtraction of the Sell volume​ from the Buy volume​ on the bar.
2 — Average Balance: Calculates a distinct EMA for both the Buy and Sell volumes, and subtracts the Sell EMA from the Buy EMA.
3 — Momentum Balance: Starts by calculating, separately for both Buy and Sell volumes, the difference between the same EMAs used in "Average Balance" and
  an SMA of double the period used for the "Average Balance" EMAs. The difference for the Sell side is subtracted from the difference for the Buy side, 
  and an RSI of that value is calculated and brought over the −50/+50 scale.
4 — Relative Balance: The reference values used in the calculation are the Buy and Sell EMAs used in the "Average Balance".
  From those, we calculate two intermediate values using how much the instant Buy and Sell volumes on the bar exceed their respective EMA — but with a twist.
  If the bar's Buy volume​ does not exceed the EMA of Buy volume​, a zero value is used. The same goes for the Sell volume​ with the EMA of Sell volume​.
  Once we have our two intermediate values for the Buy and Sell volumes exceeding their respective MA, we subtract them. The final "Relative Balance" value is an ALMA of that subtraction.
  The rationale behind using zero values when the bar's Buy/Sell volume​ does not exceed its EMA is to only take into account the more significant volume​.
  If both instant volume​ values exceed their MA, then the difference between the two is the signal's value.
  The signal is called "relative" because the intermediate values are the difference between the instant Buy/Sell volumes and their respective MA.
  This balance flatlines when the bar's Buy/Sell volumes do not exceed their EMAs, which makes it useful to spot areas where trader interest dwindles, such as consolidations.
  The smaller the period of the final value's ALMA, the more easily you will see the balance flatline. These flat zones should be considered no-trade zones. 
5 — Percent Balance: This balance is the ALMA of the ratio of the "On Bar Balance" value, i.e., the volume​ delta balance on the bar (which can be positive or negative), 
  over the total volume for that bar.

From the balances and marker conditions, two more values are calculated:
1 — Marker Bias: It sums the up/down (+1/‒1) occurrences of the markers 1 to 4 over a period you define, so it ranges from −4 to +4, times the period.
  Its calculation will depend on the modes used to calculate markers 3 and 4.
2 — Combined Balances: This is the sum of the bull/bear (+1/−1) states of each of the five balances, so it ranges from −5 to +5.

█ FEATURES

The indicator has two main modes of operation: Columns and Line.

Columns
• In Columns mode you can display stacked Buy/Sell volume​ columns.
• The buy section always appears above the centerline, the sell section below.
• The top and bottom sections can be colored independently using eight different methods.
• The EMAs of the Buy/Sell values can be displayed (these are the same EMAs used to calculate the "Average Balance").

Line
• Displays one of seven signals: the five balances or one of two complementary values, i.e., the "Marker Bias" or the "Combined Balances".
• You can color the line and its fill using independent calculation modes to pack more information in the display.
 You can thus appraise the state of 3 different values using the line itself, its color and the color of its fill.
• A "Divergence Levels" feature will use the line to automatically draw expanding levels on divergence events.

Default settings
Using the indicator's default settings, this is the information displayed:
• The line is calculated on the "Average Balance".
• The line's color is determined by the bull/bear state of the "Percent Balance".
• The line's fill gradient is determined by the advances/declines of the "Momentum Balance".
• The orange divergence dots are calculated using discrepancies between the polarity of the "On Bar Balance" and the chart's bar.
• The divergence levels are determined using the line's level when a divergence occurs.
• The background's fill gradient is calculated on advances/declines of the "Marker Bias".
• The chart bars are colored using advances/declines of the "Relative Balance". Divergences are shown in orange.
• The intrabar timeframe is automatically determined from the chart's timeframe so that a minimum of 50 intrabars are used to calculate volume​ delta on historical bars.

Alerts
The configuration of the marker conditions explained further is what determines the conditions that will trigger alerts created from this script. Note that simply selecting the display of markers does not create alerts. To create an alert on this script, you must use ALT-A from the chart. You can create multiple alerts triggering on different conditions from this same script; simply configure the markers so they define the trigger conditions for each alert before creating the alert. The configuration of the script's inputs is saved with the alert, so from then on you can change them without affecting the alert. Alert messages will mention the marker(s) that triggered the specific alert event. Keep in mind, when creating alerts on small chart timeframes, that discrepancies between alert triggers and markers displayed on your chart are to be expected. This is because the alert and your chart are running two distinct instances of the indicator on different servers and different feeds. Also keep in mind that while alerts only trigger on confirmed conditions, they are calculated using realtime calculation mode, which entails that if you refresh your chart and elapsed realtime bars recalculate as historical bars using intrabar inspection, markers will not appear in the same places they appeared in realtime. So it's important to understand that even though the alert conditions are confirmed when they trigger, these alerts will repaint.

Let's go through the sections of the script's inputs.

Columns
The size of the Buy/Sell columns always represents their respective importance on the bar, but the coloring mode for tops and bottoms is independent. The default setup uses a standard coloring mode where the Buy/Sell columns are always in the bull/bear color with a higher intensity for the winning side. Seven other coloring modes allow you to pack more information in the columns. When choosing to color the top columns using a bull/bear gradient on "Average Balance", for example, you will have bull/bear colored tops. In order for the color of the bottom columns to continue to show the instant bar balance, you can then choose the "On Bar Balance — Dual Solid Colors" coloring mode to make those bars the color of the winning side for that bar. You can display the averages of the Buy and Sell columns. If you do, its coloring is controlled through the "Line" and "Line fill" sections below.

Line and Line fill
You can select the calculation mode and the thickness of the line, and independent calculations to determine the line's color and fill.

Zero Line
The zero line can display dots when all five balances are bull/bear.

Divergences
You first select the detection mode. Divergences occur whenever the up/down direction of the signal does not match the up/down polarity of the bar. Divergences are used in three components of the indicator's visuals: the orange dot, colored chart bars, and to calculate the divergence levels on the line. The divergence levels are dynamic levels that automatically build from the line's values on divergence events. On consecutive divergences, the levels will expand, creating a channel. This implementation of the divergence levels corresponds to my view that divergences indicate anomalies, hesitations, points of uncertainty if you will. It precludes any attempt to identify a directional bias to divergences. Accordingly, the levels merely take note of divergence events and mark those points in time with levels. Traders then have a reference point from which they can evaluate further movement. The bull/bear/neutral colors used to plot the levels are also congruent with this view in that they are determined by the line's position relative to the levels, which is how I think divergences can be put to the most effective use. One of the coloring modes for the line's fill uses advances/declines in the line after divergence events.

Background
The background can show a bull/bear gradient on six different calculations. As with other gradients, you can adjust its brightness to make its importance proportional to how you use it in your analysis.

Chart bars
Chart bars can be colored using seven different methods. You have the option of emptying the body of bars where volume​ does not increase, as does my [TLD](https://www.tradingview.com/script/SeO3jRdj-The-Lie-Detector-LucF/) indicator, and you can choose whether you want to show divergences.

Intrabar Timeframe
This is the intrabar timeframe that will be used to calculate volume​ delta using intrabar inspection on historical bars. You can choose between four modes. The three "Auto-steps" modes calculate, from the chart's timeframe, the intrabar timeframe where the said number of intrabars will make up the dilation of chart bars. Adjustments are made for non-24x7 markets. "Fixed" mode allows you to select the intrabar timeframe you want. Checking the "Show TF" box will display in the lower-right corner the intrabar timeframe used at any given moment. The proper selection of the intrabar timeframe is important. It must achieve maximal granularity to produce precise results while not unduly slowing down calculations, or worse, causing runtime errors. Note that historical depth will vary with the intrabar timeframe. The smaller the timeframe, the shallower historical plots you will be.

Markers
Markers appear when the required condition has been confirmed on a closed bar. The configuration of the markers when you create an alert is what determines when the alert will trigger. Five markers are available:
• Balances Agreement: All five balances are either bullish​ or bearish​.
• Double Bumps: A double bump is two consecutive up/down bars with +/‒ volume​​ delta, and rising Buy/Sell volume​ above its average.
• Divergence confirmations: A divergence is confirmed up/down when the chosen balance is up/down on the previous bar when that bar was down/up, and this bar is up/down.
• Balance Shifts: These are bull/bear transitions of the selected signal.
• Marker Bias Shifts: Marker bias shifts occur when it crosses into bull/bear territory.

Periods
Allows control over the periods of the different moving averages used to calculate the balances.

Volume​ Discrepancies
Stock exchanges do not report the same volume​ for intraday and daily (or higher) resolutions. Other variations in how volume​ information is reported can also occur in other markets, namely Forex, where volume​ irregularities can even occur between different intraday timeframes. This will cause discrepancies between the total volume​ on the bar at the chart's timeframe, and the total volume​​ calculated by adding the volume​​ of the intrabars in that bar's dilation. This does not necessarily invalidate the volume​​ delta information calculated from intrabars, but it tells us that we are using partial volume​ data. A mechanism to detect chart vs intrabar timeframe volume​​ discrepancies is provided. It allows you to define a threshold percentage above which the background will indicate a difference has been detected.

Other Settings
You can control here the display of the gray dot reminder on realtime bars, and the display of error messages if you are using a chart timeframe that is not greater than the fixed intrabar timeframe, when you use that mode. Disabling the message can be useful if you only use realtime mode at chart timeframes that do not support intrabar inspection.

█ RAMBLINGS

On Volume​ Delta
Volume​ is arguably the best complement to interpret price action, and I consider volume​ delta to be the most effective way of processing volume​ information. In periods of low-volatility price consolidations, volume​ will typically also be lower than normal, but slight imbalances in the trend of the buy/sell volume​ balance can sometimes help put early odds on the direction of the break from consolidation. Additionally, the progression of the volume​ imbalance can help determine the proximity of the breakout. I also find volume​ delta and the number of divergences very useful to evaluate the strength of trends. In trends, I am looking for "slow and steady", i.e., relatively low volatility​ and pauses where price action doesn't look like world affairs are being reassessed. In my personal mythology, this type of trend is often more resilient than high-volatility breakouts, especially when volume​ balance confirms the general agreement of traders signaled by the low-volatility usually accompanying this type of trend. The volume​ action on pauses will often help me decide between aggressively taking profits, tightening a stop or going for a longer-term movement. As for reversals, they generally occur in high-volatility areas where entering trades is more expensive and riskier. While the identification of counter-trend reversals fascinates many traders to no end, they represent poor opportunities in my view. Volume​ imbalances often precede reversals, but I prefer to use volume​ delta information to identify the areas following reversals where I can confirm them and make relatively low-cost entries with better odds.

On "Buy/Sell" Volume
Buying or selling volume​ are misnomers, as every unit of volume​ transacted is both bought and sold by two different traders. While this does not keep me from using the terms, there is no such thing as “buy only” or “sell only” volume​. Trader lingo is riddled with peculiarities.

Divergences
The divergence detection method used here relies on a difference between the direction of a signal and the polarity (up/down) of a chart bar. When using the default "On Bar Balance" to detect divergences, however, only the bar's volume​ delta is used. You may wonder how there can be divergences between buying/selling volume​ information and price movement on one bar. This will sometimes be due to the calculation's shortcomings, but divergences may also occur in instances where because of order book structure, it takes less volume​ to increase the price of an asset than it takes to decrease it. As usual, divergences are points of interest because they reveal imbalances, which may or may not become turning points. To your pattern-hungry brain, the divergences displayed by this indicator will — as they do on other indicators — appear to often indicate turnarounds. My opinion is that reality is generally quite sobering and I have no reliable information that would tend to prove otherwise. Exercise caution when using them. Consequently, I do not share the overwhelming enthusiasm of traders in identifying bullish​/bearish​ divergences. For me, the best course of action when a divergence occurs is to wait and see what happens from there. That is the rationale underlying how my divergence levels work; they take note of a signal's level when a divergence occurs, and it's the signal's behavior from that point on that determines if the post-divergence action is bullish​/bearish​.

Superfluity
In "The Bed of Procrustes", Nassim Nicholas Taleb writes: To bankrupt a fool, give him information. This indicator can display lots of information. While learning to use a new indicator inevitably requires an adaptation period where we put it through its paces and try out all its options, once you have become used to it and decide to adopt it, rigorously eliminate the components you don't use and configure the remaining ones so their visual prominence reflects their relative importance in your analysis. I tried to provide flexible options for traders to control this indicator's visuals for that exact reason — not for window dressing.

█ LIMITATIONS

• This script uses a special characteristic of the `security()` function allowing the inspection of intrabars — which is not officially supported by TradingView. 
 It has the advantage of permitting a more robust calculation of volume​ delta than other methods on historical bars, but also has its limits.
• Intrabar inspection only works on some chart timeframes: 3, 5, 10, 15 and 30 minutes, 1, 2, 3, 4, 6, and 12 hours, 1 day, 1 week and 1 month. 
 The script’s code can be modified to run on other resolutions.
• When the difference between the chart’s timeframe and the intrabar timeframe is too great, runtime errors will occur. The Auto-Steps selection mechanisms should avoid this.
• All volume​ is not created equally. Its source, components, quality and reliability will vary considerably with sectors and instruments. 
 The higher the quality, the more reliably volume​ delta information can be used to guide your decisions. 
 You should make it your responsibility to understand the volume​ information provided in the data feeds you use. It will help you make the most of volume​ delta.

█ NOTES

For traders
• The Data Window shows key values for the indicator.
• While this indicator displays some of the same information calculated in my [Delta Volume Columns](https://www.tradingview.com/script/YFBNr8I6-Delta-Volume-Columns-LucF/), 
 I have elected to make it a separate publication so that traders continue to have a simpler alternative available to them. Both code bases will continue to evolve separately.
• All gradients used in this indicator determine their brightness intensities using advances/declines in the signal—not their relative position in a pre-determined scale.
• Volume​ delta being relative, by nature, it is particularly well-suited to Forex markets, as it filters out quite elegantly the cyclical volume​ data characterizing the sector.

If you are interested in volume​ delta, consider having a look at my other "Delta Volume" indicators:
• [Delta Volume Realtime Action](https://www.tradingview.com/script/Xh8tLDTe-Delta-Volume-Realtime-Action-LucF/)  displays realtime volume​ delta and tick information on the chart.
• [Delta Volume Candles](https://www.tradingview.com/script/h0yZPTiS-Delta-Volume-Candles-LucF/)  builds volume​​ delta candles on the chart.
• [Delta Volume Columns](https://www.tradingview.com/script/YFBNr8I6-Delta-Volume-Columns-LucF/)  is a simpler version of this indicator.

For coders
• I use the `f_c_gradientRelativePro()` from the PineCoders [Color Gradient Framework](https://www.tradingview.com/script/hqH4YIFa-Color-Gradient-Framework-PineCoders/) to build my gradients.
 This function has the advantage of allowing begin/end colors for both the bull and bear colors. It also allows us to define the number of steps allowed for each gradient. 
 I use this to modulate the gradients so they perform optimally on the combination of the signal used to calculate advances/declines, 
 but also the nature of the visual component the gradient applies to. I use fewer steps for choppy signals and when the gradient is used on discrete visual components 
 such as volume​ columns or chart bars.
• I use the [PineCoders Coding Conventions for Pine](http://www.pinecoders.com/coding_conventions/) to write my scripts.
• I used functions modified from the [PineCoders MTF Selection Framework](https://www.tradingview.com/script/90mqACUV-MTF-Selection-Framework-PineCoders-FAQ/) for the selection of timeframes.

█ THANKS TO:

— The devs from TradingView's Pine and other teams, and the PineCoders who collaborate with them. They are doing amazing work, 
 and much of what this indicator does could not be done without their recent improvements to Pine.
— A guy called Kuan who commented on a [Backtest Rookies presentation](https://backtest-rookies.com/2019/02/15/tradingview-volume-profile-with-lower-time-frame-data/)  of their [Volume Profile indicator](https://www.tradingview.com/script/28iP8MSD-Volume-Profile-Intra-bar-Volume/) using a `for` loop.
 This indicator started from the intrabar inspection technique illustrated in Kuan's snippet.
— [theheirophant](https://www.tradingview.com/u/theheirophant/), my partner in the exploration of the sometimes weird abysses of `security()`’s behavior at intrabar timeframes.
— [midtownsk8rguy](https://www.tradingview.com/u/midtownsk8rguy/), my brilliant companion in mining the depths of Pine graphics.

---

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
//@version=5
//@author=LucF
 
// Delta Volume Columns Pro [LucF]
//  v8 2023.03.27 10:49 — LucF

// This indicator plots either delta volume columns or a volume balance line.

// This code was written using the following:
//  • The recommendations from the Pine Script™ User Manual's Style Guide: https://www.tradingview.com/pine-script-docs/en/v5/writing/Style_guide.html
//  • The `gradientAdvDecPro()` function from the PineCoders Color Gradient Framework: https://www.tradingview.com/script/hqH4YIFa-Color-Gradient-Framework-PineCoders/
//  • The "Time" library from PineCoders to convert a TF string into long form for display: https://www.tradingview.com/script/tyeeNU9I-Time/
//  • The "lower_tf" library from PineCoders to manage the LTF user selection: https://www.tradingview.com/script/UxiDkNg0-lower-tf/

// My indicator displaying "Delta Volume Candles" using the same method of calculation is here: https://www.tradingview.com/script/h0yZPTiS-Delta-Volume-Candles-LucF/
// A simpler version of this indicator is my "Delta Volume Columns": https://www.tradingview.com/script/YFBNr8I6-Delta-Volume-Columns-LucF/
// My "Realtime Delta Volume Action" provides realtime volume delta only, calculated from chart updates instead of from a LTF: https://www.tradingview.com/script/Xh8tLDTe-Delta-Volume-Realtime-Action-LucF/
// My "Realtime 5D Profile" also provides realtime volume delta, but presented as a profile: https://www.tradingview.com/script/tNG177SV-Realtime-5D-Profile-LucF/
// For "CVD - Cumulative Volume Delta Candles", see this TradingView script: https://www.tradingview.com/script/NlM312nK-CVD-Cumulative-Volume-Delta-Candles/

// This indicator's page on TV: https://www.tradingview.com/script/F2ylEYOO-Delta-Volume-Columns-Pro-LucF/

indicator("Delta Volume Columns Pro [LucF]", "Delta Volume Columns Pro", format = format.volume, max_labels_count = 500)


import PineCoders/Time/2 as PCtime
import PineCoders/lower_tf/4 as PCltf
import LucF/ta/2 as LucfTa



//#region ———————————————————— Constants


// Colors used as defaults in inputs.
color AQUA    = #0080FFff
color BLACK   = #000000ff
color BLUE    = #013BCAff
color CORAL   = #FF8080ff
color GOLD    = #CCCC00ff
color GRAY    = #808080ff
color GREEN   = #008000ff
color LIME    = #00FF00ff
color MAROON  = #800000ff
color NONE    = #FFFFFF00
color ORANGE  = #FF8000ff
color PINK    = #FF0080ff
color RED     = #FF0000ff
color REDLITE = #EF535030
color VIOLET  = #AA00FFff
color YELLOW  = #FFFF00ff
color WHITE   = #FFFFFFff

// Colors used for Data Window and markers.
color GENERAL_UP_HI = LIME
color GENERAL_DN_HI = RED
color GENERAL_UP_LO = GREEN
color GENERAL_DN_LO = MAROON
color GENERAL_NT    = GRAY

// Input options.
string ON  = "On"
string OFF = "Off"

string ZR0 = "Hide"
string ZR1 = "Combined Balances — Dual Solid Colors (All Bull/All Bear Only)"

string CB0 = "None"
string CB1 = "On Bar Balance"
string CB2 = "Average Balance"
string CB3 = "Momentum Balance"
string CB4 = "Markers Bias"
string CB5 = "CB5"
string CB6 = "Combined Balances"
string CB7 = "Relative Balance"
string CB8 = "Percent Balance"

string CC0  = "None"
string CC1  = "On Bar Balance — Single Color Gradient"
string CC2  = "On Bar Balance — Dual Color Gradient"
string CC3  = "Average Balance — Dual Color Gradient"
string CC4  = "Momentum Balance — Dual Color Gradient"
string CC5  = "Marker Bias — Dual Color Gradient"
string CC6  = "On Bar Balance — Single color, 2 tones"
string CC7  = "On Bar Balance — Dual Solid Colors"
string CC8  = "Combined Balances — Dual Color Gradient"
string CC9  = "Relative Balance — Dual Color Gradient"
string CC10 = "Line vs divergence levels — Dual Color Gradient"
string CC11 = "Percent Balance — Dual Color Gradient"

string TD1 = "Both"
string TD2 = "Longs Only"
string TD3 = "Shorts Only"

string LTF1   = "Covering most chart bars (least precise)"
string LTF2   = "Covering some chart bars (less precise)"
string LTF3   = "Covering less chart bars (more precise)"
string LTF4   = "Covering few chart bars (very precise)"
string LTF5   = "Covering the least chart bars (most precise)"
string LTF6   = "~12 intrabars per chart bar"
string LTF7   = "~24 intrabars per chart bar"
string LTF8   = "~50 intrabars per chart bar"
string LTF9   = "~100 intrabars per chart bar"
string LTF10  = "~250 intrabars per chart bar"

string TT_BRITE             = "0 (darkest) — 100 (brightest)."
string TT_COL_AVG           = "Turning averages on here overrides the Line calculation selection below. The lines' color and fill are controlled in the 'Line' and Line fill' sections below."
string TT_COL_COLOR_CALC    = "You can color the top and bottom columns using different calculations."
string TT_LINE_COLOR_CALC   = "You can color the line using a different calculation than the one used to calulate the line. This allows you to show more information with the line."
string TT_CHART_BARS        = "As calculated in the 'Divergences' section."
string TT_LTF               = "Your selection here controls how many intrabars will be analyzed for each chart bar. 
  The more intrabars you analyze, the more precise the calculations will be,
  but the less chart bars will be covered by the indicator's calculations because a maximum of 100K intrabars can be analyzed.\n\n
  The first five choices determine the lower timeframe used for intrabars using how much chart coverage you want.
  The last five choices allow you to select approximately how many intrabars you want analyzed per chart bar."
string TT_LTF_BOX           = "Displays the LTF used and intrabar statistics in a configurable position and color."
string TT_MARKER1           = "All five balances (On Bar, Average, Momentum, Relative and Percent) are bull/bear."
string TT_MARKER2           = "A double bump is two consecutive up/dn bars with +/‒ volume delta, and rising buy/sell volume above its average."
string TT_MARKER3           = "A divergence is confirmed up/dn when the chosen balance is up/dn on the previous bar when that bar was dn/up, and this bar is up/dn."
string TT_MARKER4           = "Balance shifts occur when the chosen balance crosses into bull/bear territory."
string TT_MARKER5           = "Marker bias shifts occur when it crosses into bull/bear territory."
string TT_ALERT_UP          = "This text will replace the alert message for up alerts."
string TT_ALERT_DN          = "This text will replace the alert message for down alerts."
string TT_VOL_DISC          = "This displays a background to indicate that the volume from the chart's TF does not match the volume at the intrabar TF."
//#endregion



//#region ———————————————————— Inputs


string  GP00 = "Columns"
bool    columnsOnInput             = input.string(OFF,     "Columns",                               inline = "00", options = [OFF, ON], group = GP00) == ON
bool    columnsAvgsOnInput         = input.string(OFF,     "Averages",                              inline = "00", options = [OFF, ON], group = GP00, tooltip = TT_COL_AVG) == ON
string  columnsTopColorCalcInput   = input.string(CC6,     "Color Tops on",                         inline = "01", options = [CC6, CC7, CC1, CC3, CC4, CC9, CC11, CC5], group = GP00)
string  columnsBotColorCalcInput   = input.string(CC6,     "Bottoms",                               inline = "01", options = [CC6, CC7, CC1, CC3, CC4, CC9, CC11, CC5], group = GP00, tooltip = TT_COL_COLOR_CALC)
color   columnsUpZeroOneColorInput = input(GREEN,        "🡑",                                       inline = "02", group = GP00)
color   columnsDnZeroOneColorInput = input(MAROON,       "🡓",                                       inline = "02", group = GP00)
float   columnsBriteInput          = 100 - input.int(100,  "🔆",                                    inline = "02", minval = 0, maxval = 100, step = 5, group = GP00, tooltip = TT_BRITE)

string  GP01 = "Line"
string  balanceLineCalcInput       = input.string(CB2,     "Calculation",                           inline = "11", options = [CB0, CB1, CB2, CB3, CB7, CB8, CB4, CB6], group = GP01)
int     balanceLineThicknessInput  = input.int(1,          "Line Thickness",                        inline = "11", minval  = 1, maxval = 16, group = GP01)
string  balanceLineColorCalcInput  = input.string(CB8,     "Color on",                              inline = "12", options = [CB0, CB1, CB2, CB3, CB7, CB8, CB4, CB6], group = GP01, tooltip = TT_LINE_COLOR_CALC)
color   balanceLineUpColorInput    = input(WHITE,          "🡑",                                     inline = "12", group = GP01)
color   balanceLineDnColorInput    = input(AQUA,           "🡓",                                     inline = "12", group = GP01)
float   balanceLineBriteInput      = 100 - input.int(100,  "🔆",                                    inline = "12", minval = 0, maxval = 100, step = 5, group = GP01, tooltip = TT_BRITE)

string  GP02 = "Line Fill"
string  balanceFillColorCalcInput  = input.string(CC4,     "Color on",                              inline = "21", options = [CC0, CC2, CC3, CC4, CC9, CC11, CC5, CC10], group = GP02)
color   balanceFillUpColorInput    = input(GOLD,           "🡑",                                     inline = "21", group = GP02)
color   balanceFillDnColorInput    = input(VIOLET,         "🡓",                                     inline = "21", group = GP02)
float   balanceFillBriteInput      = 100 - input.int(100,  "🔆",                                    inline = "21", minval = 0, maxval = 100, step = 5, group = GP02, tooltip = TT_BRITE)

string  GP03 = "Zero Line"
string  zeroLineColorCalcInput     = input.string(ZR1,     "Display",                               inline = "31", options = [ZR0, ZR1], group = GP03)
int     zeroLineThicknessInput     = input.int(1,          "Line Thickness",                        inline = "31", minval = 0, group = GP03)
color   zeroLineUpColorInput       = input(LIME,           "🡑",                                     inline = "32", group = GP03)
color   zeroLineDnColorInput       = input(RED,            "🡓",                                     inline = "32", group = GP03)
float   zeroLineBriteInput         = 100 - input.int(100,  "🔆",                                    inline = "32", minval = 0, maxval = 100, step = 5, group = GP03, tooltip = TT_BRITE)

string  GP04 = "Divergences"
string  divergenceCalcInput        = input.string(CB1,     "Detection",                             inline = "41", options = [CB0, CB1, CB2, CB3, CB7, CB8, CB6], group = GP04)
color   divergenceDotColorInput    = input(ORANGE,         "Dot color",                             inline = "41", group = GP04)
color   divLevelsUpColorInput      = input(GREEN,          "Levels: 🡑",                             inline = "42", group = GP04)
color   divLevelsDnColorInput      = input(MAROON,         "🡓",                                     inline = "42", group = GP04)
color   divLevelsNtColorInput      = input(GRAY,           "•",                                     inline = "42", group = GP04)
float   divLevelsBriteInput        = 100 - input.int(100,  "🔆",                                    inline = "42", minval = 0, maxval = 100, step = 5, group = GP04, tooltip = TT_BRITE)
bool    filldivLevelsInput         = input(false,          "Fill expanded levels",                  inline = "43", group = GP04)
float   filldivLevelsBriteInput    = 100 - input.int(50,   "🔆",                                    inline = "43", minval = 0, maxval = 100, step = 5, group = GP04, tooltip = TT_BRITE)

string  GP05 = "Background"
string  bgFillColorCalcInput       = input.string(CC5,     "Color on",                              inline = "51", options = [CC0, CC2, CC3, CC4, CC9, CC11, CC5], group = GP05)
color   bgUpColorInput             = input(GRAY,           "🡑",                                     inline = "51", group = GP05)
color   bgDnColorInput             = input(BLUE,           "🡓",                                     inline = "51", group = GP05)
float   bgFillBriteInput           = 100 - input.int(100,  "🔆",                                    inline = "51", minval = 0, maxval = 100, step = 5, group = GP05, tooltip = TT_BRITE)

string  GP06 = "Chart Bars"
string  chartBarsColorCalcInput    = input.string(CC9,     "Color on",                              inline = "61", options = [CC0, CC7, CC2, CC3, CC4, CC9, CC11, CC5], group = GP06)
color   chartBarsUpColorInput      = input(WHITE,          "🡑",                                     inline = "61", group = GP06)
color   chartBarsDnColorInput      = input(AQUA,           "🡓",                                     inline = "61", group = GP06)
float   chartBarsBriteInput        = 100 - input.int(100,  "🔆",                                    inline = "61", minval = 0, maxval = 100, step = 5, group = GP06, tooltip = TT_BRITE)
bool    hollowOutBodiesInput       = input(false,          "Empty bodies on decreasing volume",     group = GP06)
bool    chartBarsShowDivInput      = input(true,           "Show divergences",                      inline = "62", group = GP06)
color   chartBarsDivColorInput     = input(ORANGE,         "",                                      inline = "62", group = GP06, tooltip = TT_CHART_BARS)

string  GP07 = "Intrabars (LTF)"
string  ltfModeInput               = input.string(LTF9,          "Intrabar precision",               options = [LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10], group = GP07, tooltip = TT_LTF)
bool    showInfoBoxInput           = input.bool(true,            "Show information box",             group = GP07, tooltip = TT_LTF_BOX)
string  infoBoxSizeInput           = input.string("small",       "Size ",                            inline = "72", group = GP07, options = ["tiny", "small", "normal", "large", "huge", "auto"])
string  infoBoxYPosInput           = input.string("bottom",      "↕",                                inline = "72", group = GP07, options = ["top", "middle", "bottom"])
string  infoBoxXPosInput           = input.string("right",       "↔",                                inline = "72", group = GP07, options = ["left", "center", "right"])
color   infoBoxColorInput          = input.color(color.gray,   "",                                 inline = "72", group = GP07)
color   infoBoxTxtColorInput       = input.color(color.black,  "T",                                inline = "72", group = GP07)

string  GP08 = "Markers"
string  markerDirInput             = input.string(TD1,     "Direction",                             inline = "81", options = [TD1, TD2, TD3], group = GP08)
bool    showMarker1Input           = input(false,          "Marker 1: Balances Agreement",          group = GP08, tooltip = TT_MARKER1)
bool    showMarker2Input           = input(false,          "Marker 2: Double Bumps",                group = GP08, tooltip = TT_MARKER2)
bool    showMarker3Input           = input(false,          "Marker 3: Divergence Confirmations",    inline = "82", group = GP08, tooltip = TT_MARKER3)
string  marker3ModeInput           = input.string(CB1,     "On",                                    inline = "82", options = [CB1, CB2, CB3, CB7, CB8, CB6], group = GP08)
bool    showMarker4Input           = input(false,          "Marker 4: Balance Shifts",              inline = "83", group = GP08, tooltip = TT_MARKER4)
string  marker4ModeInput           = input.string(CB2,     "On",                                    inline = "83", options = [CB2, CB3, CB7, CB8, CB6], group = GP08)
bool    showMarker5Input           = input(false,          "Marker 5: Markers Bias Shifts",         group = GP08, tooltip = TT_MARKER5)
string  alertMsgUpInput            = input.text_area("",   "Up alert message",                      group = GP08, tooltip = TT_ALERT_UP)
string  alertMsgDnInput            = input.text_area("",   "Down alert message",                    group = GP08, tooltip = TT_ALERT_DN)

string  GP09 = "Periods"
int     balAvgPeriodInput          = input.int(50,         "Average Balance",                       minval = 2, group = GP09)
int     balMomPeriodInput          = input.int(14,         "Momentum Balance",                      minval = 2, group = GP09)
int     balRelPeriodInput          = input.int(14,         "Relative Balance",                      minval = 1, group = GP09)
int     balPctPeriodInput          = input.int(14,         "Percent Balance",                       minval = 1, group = GP09)
int     biasPeriodInput            = input.int(14,         "Markers Bias",                          minval = 2, group = GP09)

string  GP10 = "Volume Discrepancies"
color   bgColorInput               = input(REDLITE,        "Background Color",                      inline = "100", group = GP10)
float   failureToleranceInput      = input.float(1.,       "Failure Tolerance (%)",                 inline = "100", minval = 0., maxval = 50., step = 0.25, group = GP10, tooltip = TT_VOL_DISC) / 100
//#endregion



//#region ———————————————————— Functions


// ————— Returns 1 when boolean `cond` is true, 0 if false.
zeroOne(cond) => 
    int result = cond ? 1 : 0


// ————— Function appends `sep` and `txt` to `msg` when `cond` is true.
addTextIf(cond, msg, txt, sep) => 
    string result = cond ? msg + (msg != "" ? sep : "") + txt : msg


// ————— Function returning a gradient between two bull or two bear colors, depending on whether the source signal is above/below the centerline.
//       The gradient is proportional to the current qty of advances/declines of the `source`.
//       The count of advances/declines resets to one when the `source` crosses the `center` and is limited by `steps`.
gradientAdvDecPro(source, center, steps, bearWeakColor, bearStrongColor, bullWeakColor, bullStrongColor) =>
    // float source         : input signal.
    // float center         : (- ∞ to ∞) centerline used to determine if signal is bullish/bearish.
    // float steps          : Maximum number of steps in the gradient from the weak color to the strong color.
    // color bearWeakColor  : bear color at adv/dec qty of 1.
    // color bearStrongColor: bear color at adv/dec qty of `steps`.
    // color bullWeakColor  : bull color at adv/dec qty of 1.
    // color bullStrongColor: bull color at adv/dec qty of `steps`.
    var float qtyAdvDec = 0.
    var float maxSteps  = math.max(1, steps)
    bool  xUp     = ta.crossover(source, center)
    bool  xDn     = ta.crossunder(source, center)
    float chg     = ta.change(source)
    bool  up      = chg > 0
    bool  dn      = chg < 0
    bool  srcBull = source > center
    bool  srcBear = source < center
    qtyAdvDec := 
      srcBull ? xUp ? 1 : up ? math.min(maxSteps, qtyAdvDec + 1) : dn ? math.max(1, qtyAdvDec - 1) : qtyAdvDec :
      srcBear ? xDn ? 1 : dn ? math.min(maxSteps, qtyAdvDec + 1) : up ? math.max(1, qtyAdvDec - 1) : qtyAdvDec : qtyAdvDec
    var color result = na
    result := 
      srcBull ? color.from_gradient(qtyAdvDec, 1, maxSteps, bullWeakColor, bullStrongColor) : 
      srcBear ? color.from_gradient(qtyAdvDec, 1, maxSteps, bearWeakColor, bearStrongColor) : result


// @function    Determines if the volume for an intrabar is up or down.
// @returns     ([float, float]) A tuple of two values, one of which contains the bar's volume. `upVol` is the positive volume of up bars. `dnVol` is the negative volume of down bars.
//              Note that when this function is called with `request.security_lower_tf()` a tuple of float[] arrays will be returned.
upDnIntrabarVolumesByPolarity() =>
    float upVol = 0.0
    float dnVol = 0.0
    switch
        // Bar polarity can be determined.
        close > open => upVol += volume
        close < open => dnVol -= volume
        // If not, use price movement since last bar.
        close > nz(close[1]) => upVol += volume
        close < nz(close[1]) => dnVol -= volume
        // If not, use previously known polarity.
        nz(upVol[1]) > 0 => upVol += volume
        nz(dnVol[1]) < 0 => dnVol -= volume
    [upVol, dnVol]
//#endregion



//#region ———————————————————— Calculations


// ————— Calculate DV using LTF intrabars.
// Determine intrabar TF.
string intrabarTf = PCltf.ltf(ltfModeInput, LTF1, LTF2, LTF3, LTF4, LTF5, LTF6, LTF7, LTF8, LTF9, LTF10)
// Fetch two arrays containing one element per intrabar. One array contains up volume values (positive), the other down volume values (negative). Volume for each intrabar is either up or down.
[ltfVolumesUp, ltfVolumesDn] = request.security_lower_tf(syminfo.tickerid, intrabarTf, upDnIntrabarVolumesByPolarity())
// Total up/dn volumes for intrabars.
float ltfVolUp = nz(array.sum(ltfVolumesUp))
float ltfVolDn = nz(array.sum(ltfVolumesDn))
// ———— Intrabar stats
[intrabars, chartBarsCovered, avgIntrabars] = PCltf.ltfStats(ltfVolumesUp)
int chartBars = bar_index + 1


// —————————— ASSEMBLE VOLUME INFORMATION.

// ————— Bar polarity.
bool barUp = ta.rising(close, 1)
bool barDn = ta.falling(close, 1)

// ————— Select between historical and realtime delta calcs. In rt, use user selection.
float volB = ltfVolUp
float volS = - ltfVolDn
float volT = volB + volS

// ————— Column top/bottom.
float barBTop         = volB
float barSTop         = - volS
// ————— Buy/Sell Balance On Bar (CB1).
bool  volUp           = ta.rising(volume, 1)
float balBar          = volB - volS
bool  balBarBull      = volB > volS
bool  balBarBear      = volB < volS
bool  balBarDivUp     = ta.rising( balBar, 1) and barDn
bool  balBarDivDn     = ta.falling(balBar, 1) and barUp
bool  balBarDiv       = balBarDivUp or balBarDivDn
// ————— Buy/Sell Balance Averages (CB2).
float balAvgBMa       = ta.ema(volB, balAvgPeriodInput)
float balAvgSMa       = ta.ema(volS, balAvgPeriodInput)
float balAvg          = balAvgBMa - balAvgSMa
bool  balAvgBull      = balAvg > 0
bool  balAvgBear      = balAvg < 0
bool  balAvgDivUp     = ta.rising( balAvg, 1) and barDn
bool  balAvgDivDn     = ta.falling(balAvg, 1) and barUp
bool  balAvgDiv       = balAvgDivUp or balAvgDivDn
// ————— Buy/Sell Balance Momentum (CB3).
float balMomBMa       = ta.sma(volB, balAvgPeriodInput * 2)
float balMomSMa       = ta.sma(volS, balAvgPeriodInput * 2)
float balMomBMaDelta  = balAvgBMa - balMomBMa
float balMomSMaDelta  = balAvgSMa - balMomSMa
float balMomDeltaDelta= balMomBMaDelta - balMomSMaDelta
float balMom          = ta.rsi(balMomDeltaDelta, balMomPeriodInput) - 50
bool  balMomBull      = balMom > 0
bool  balMomBear      = balMom < 0
bool  balMomDivUp     = ta.rising( balMom, 1) and barDn
bool  balMomDivDn     = ta.falling(balMom, 1) and barUp
bool  balMomDiv       = balMomDivUp or balMomDivDn
// ————— Buy/Sell Balance Relative (CB7).
float volUpDelta      = math.max(0, volB - balAvgBMa)
float volDnDelta      = math.max(0, volS - balAvgSMa)
float balRel          = ta.alma(volUpDelta - volDnDelta, balRelPeriodInput, 0.85, 6)
bool  balRelBull      = balRel > 0
bool  balRelBear      = balRel < 0
bool  balRelDivUp     = ta.rising( balRel, 1) and barDn
bool  balRelDivDn     = ta.falling(balRel, 1) and barUp
bool  balRelDiv       = balRelDivUp or balRelDivDn
// ————— Buy/Sell Balance Percent (CB8).
float balPct          = ta.alma(100 * balBar / volume, balPctPeriodInput, 0.85, 6)
bool  balPctBull      = balPct > 0
bool  balPctBear      = balPct < 0
bool  balPctDivUp     = ta.rising( balPct, 1) and barDn
bool  balPctDivDn     = ta.falling(balPct, 1) and barUp
bool  balPctDiv       = balPctDivUp or balPctDivDn
// ————— Combined Balances bull/bear values (CB6).
float balAll          = zeroOne(balBarBull) + zeroOne(balAvgBull) + zeroOne(balMomBull) + zeroOne(balRelBull) + zeroOne(balPctBull) - zeroOne(balBarBear) - zeroOne(balAvgBear) - zeroOne(balMomBear) - zeroOne(balRelBear) - zeroOne(balPctBear)
bool  balAllBull      = balAll > 0
bool  balAllBear      = balAll < 0
bool  balAllBullFull  = balAll ==   5
bool  balAllBearFull  = balAll == - 5
bool  balAllDivUp     = ta.rising( balAll, 1) and barDn
bool  balAllDivDn     = ta.falling(balAll, 1) and barUp
bool  balAllDiv       = balAllDivUp or balAllDivDn

// ————— Return divergence as per user-selected detection mode.
f_divUp(divCalc) => 
    bool result =
      switch divCalc
        CB1 => balBarDivUp
        CB2 => balAvgDivUp
        CB3 => balMomDivUp
        CB6 => balAllDivUp
        CB7 => balRelDivUp
        CB8 => balPctDivUp
        => false

f_divDn(divCalc) => 
    bool result =
      switch divCalc
        CB1 => balBarDivDn
        CB2 => balAvgDivDn
        CB3 => balMomDivDn
        CB6 => balAllDivDn
        CB7 => balRelDivDn
        CB8 => balPctDivDn
        => false

f_markerSignal(signalCalc) => 
    float result = 
      switch signalCalc
        CB2 => balAvg
        CB3 => balMom
        CB6 => balAll
        CB7 => balRel
        CB8 => balPct
        => na

// —————————— Marker Calcs
// User-selected marker directions.
bool doLongs  = markerDirInput == TD1 or markerDirInput == TD2
bool doShorts = markerDirInput == TD1 or markerDirInput == TD3

// ————— Marker Conditions.
bool  bumpUp     = barUp and balBarBull and volB > balAvgBMa and ta.rising(volB, 1)
bool  bumpDn     = barDn and balBarBear and volS > balAvgSMa and ta.rising(volS, 1)
bool  divUp      = f_divUp(marker3ModeInput)
bool  divDn      = f_divDn(marker3ModeInput)
bool  c1U        = balAllBullFull
bool  c1D        = balAllBearFull
bool  c2U        = bumpUp[1] and bumpUp[2] and ta.rising(close, 1)[1]
bool  c2D        = bumpDn[1] and bumpDn[2] and ta.falling(close, 1)[1]
bool  c3U        = divUp[2]  and barUp[1]  and not (divUp[1] or divDn[1])
bool  c3D        = divDn[2]  and barDn[1]  and not (divUp[1] or divDn[1])
bool  c4U        = ta.crossover( f_markerSignal(marker4ModeInput), 0)[1]
bool  c4D        = ta.crossunder(f_markerSignal(marker4ModeInput), 0)[1]
// ————— Marker bias.
float cUps       = zeroOne(c1U) + zeroOne(c2U) + zeroOne(c3U) + zeroOne(c4U)
float cDns       = zeroOne(c1D) + zeroOne(c2D) + zeroOne(c3D) + zeroOne(c4D)
float balMrk     = math.sum(cUps - cDns, biasPeriodInput)
bool  balMrkBull = balMrk > 0
bool  balMrkBear = balMrk < 0
// Crosses above/below a middle buffer zone.
int   buffer     = 0
bool  c5U        = ta.crossover( balMrk,   buffer)[1]
bool  c5D        = ta.crossunder(balMrk, - buffer)[1]
// ————— Assembly.
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

// —————————— User-selected line calculation
if columnsAvgsOnInput
    // Dual Buy/Sell Averages are displayed with columns; override user selection of line calc.
    balanceLineCalcInput := CB5
float balance = 
  switch balanceLineCalcInput
    CB1 => balBar
    CB2 => balAvg
    CB3 => balMom
    CB4 => balMrk
    CB5 => balAvgBMa
    CB6 => balAll
    CB7 => balRel
    CB8 => balPct
    => na
      
// =>————————— Divergence levels.
bool divLevelsDiv = f_divUp(divergenceCalcInput) or f_divDn(divergenceCalcInput)
// Update the divergence channel.
[divLevelsHi, divLevelsLo, divLevelsHState, divLevelsLState, divLevelsBreached, divLevelsChanged, preBreachUpChanges, preBreachDnChanges] = 
  LucfTa.divergenceChannel(divLevelsDiv, balance, balance, balance, balance)
bool  divLevelsNState = not (divLevelsHState or divLevelsLState)
//#endregion



//#region ———————————————————— Visuals


// ————— Returns signal from coloring mode.
colorModeToSignal(colorMode) => 
    float result = 
      switch colorMode
        CC1  => balBar
        CC2  => balBar
        CC3  => balAvg
        CC4  => balMom
        CC5  => balMrk
        CC8  => balAll
        CC9  => balRel
        CC10 => math.avg(divLevelsHi, divLevelsLo)
        CC11 => balPct
        => na


// —————————— Data Window
plotLocations = display.data_window + display.status_line
plot(volB,              "Buy Volume",         balBarBull ? GENERAL_UP_HI : GENERAL_UP_LO, display = plotLocations)
plot(volS,              "Sell Volume",        balBarBear ? GENERAL_DN_HI : GENERAL_DN_LO, display = plotLocations)
plot(volT,              "Buy + Sell Volume",  balBarBull ? GENERAL_UP_HI : GENERAL_DN_HI, display = plotLocations)
plot(volume,            "Total Volume",       balBarBull ? GENERAL_UP_HI : GENERAL_DN_HI, display = plotLocations)
plot(balBar,            "Balance",            balBarBull ? GENERAL_UP_HI : GENERAL_DN_HI, display = plotLocations)
plot(balMrk,            "Marker Bias",        GENERAL_NT,                                 display = plotLocations)
plot(avgIntrabars,      "Average intrabars",  GENERAL_NT,                                 display = plotLocations)
plot(intrabars,         "Intrabars",          GENERAL_NT,                                 display = plotLocations)
plot(chartBarsCovered,  "Chart bars covered", GENERAL_NT,                                 display = plotLocations)
plot(chartBars,         "Chart bars total",   GENERAL_NT,                                 display = plotLocations)


// —————————— Columns

// ————— #1: Build colors.
// Used when a bull/bear gradient coloring mode is selected, so bars can be of bull or bear color.
color barsGradientUpLoColor = color.new(columnsUpZeroOneColorInput, math.max(90, columnsBriteInput))
color barsGradientUpHiColor = color.new(columnsUpZeroOneColorInput, columnsBriteInput)
color barsGradientDnLoColor = color.new(columnsDnZeroOneColorInput, math.max(90, columnsBriteInput))
color barsGradientDnHiColor = color.new(columnsDnZeroOneColorInput, columnsBriteInput)
color barsGradientBColor = columnsTopColorCalcInput == CC7 ? balBarBull ? columnsUpZeroOneColorInput : columnsDnZeroOneColorInput : gradientAdvDecPro(colorModeToSignal(columnsTopColorCalcInput), 0, 8, barsGradientDnLoColor, barsGradientDnHiColor, barsGradientUpLoColor, barsGradientUpHiColor)
color barsGradientSColor = columnsBotColorCalcInput == CC7 ? balBarBull ? columnsUpZeroOneColorInput : columnsDnZeroOneColorInput : gradientAdvDecPro(colorModeToSignal(columnsBotColorCalcInput), 0, 8, barsGradientDnLoColor, barsGradientDnHiColor, barsGradientUpLoColor, barsGradientUpHiColor)
// Selection between hard colors or single color gradient on adv/dec of buy/sell ratio.
color barsSolidUpLoColor = color.new(columnsUpZeroOneColorInput, 50)
color barsSolidUpHiColor = color.new(columnsUpZeroOneColorInput, columnsBriteInput)
color barsSolidDnLoColor = color.new(columnsDnZeroOneColorInput, 50)
color barsSolidDnHiColor = color.new(columnsDnZeroOneColorInput, columnsBriteInput)
color barsBBalBarColor = columnsTopColorCalcInput == CC1 ? gradientAdvDecPro(barBTop, 0, 6, barsGradientDnLoColor, barsGradientDnHiColor, barsGradientUpLoColor, barsGradientUpHiColor) : columnsTopColorCalcInput == CC6 ? balBarBull ? barsSolidUpHiColor : barsSolidUpLoColor : columnsTopColorCalcInput == CC7 ? balBarBull ? barsSolidUpHiColor : barsSolidDnHiColor : na
color barsSBalBarColor = columnsBotColorCalcInput == CC1 ? gradientAdvDecPro(barSTop, 0, 6, barsGradientDnLoColor, barsGradientDnHiColor, barsGradientUpLoColor, barsGradientUpHiColor) : columnsBotColorCalcInput == CC6 ? balBarBull ? barsSolidDnLoColor : barsSolidDnHiColor : columnsBotColorCalcInput == CC7 ? balBarBull ? barsSolidUpHiColor : barsSolidDnHiColor : na
// Final assembly of top/bot/middle column colors.
bool solidColTop = columnsTopColorCalcInput == CC1 or columnsTopColorCalcInput == CC6 or columnsTopColorCalcInput == CC7
bool solidColBot = columnsBotColorCalcInput == CC1 or columnsBotColorCalcInput == CC6 or columnsBotColorCalcInput == CC7
color barsBColor = solidColTop ? barsBBalBarColor : barsGradientBColor
color barsSColor = solidColBot ? barsSBalBarColor : barsGradientSColor

// ————— #2: Plot columns.
// Plot Buy part above.
plotcandle(columnsOnInput ? barBTop : na, columnsOnInput ? 0 : na, columnsOnInput ? barBTop : na, columnsOnInput ? 0 : na, "Column Buy",  barsBColor, wickcolor = na, bordercolor = na)
// Plot Sell part below.
plotcandle(columnsOnInput ? barSTop : na, columnsOnInput ? 0 : na, columnsOnInput ? barSTop : na, columnsOnInput ? 0 : na, "Column Sell", barsSColor, wickcolor = na, bordercolor = na)


// —————————— Line
bool signalIsBull = 
  switch balanceLineColorCalcInput
    CB0 => false
    CB1 => balBarBull
    CB2 => balAvgBull
    CB3 => balMomBull
    CB4 => balMrkBull
    CB6 => balAllBull
    CB7 => balRelBull
    CB8 => balPctBull
    => na
color balanceLineColor = signalIsBull ? color.new(balanceLineUpColorInput, balanceLineBriteInput) : color.new(balanceLineDnColorInput, balanceLineBriteInput)
balancePlot = plot(balance, "Volume Balance", balanceLineColor, balanceLineThicknessInput)
balanceLoPlot = plot(balanceLineCalcInput == CB5 ? - balAvgSMa : na, "Volume Balance Lo Line for Sell Ma", balanceLineColor, balanceLineThicknessInput)
color zeroLineColor = zeroLineColorCalcInput == ZR1 ? balAllBullFull ? color.new(zeroLineUpColorInput, zeroLineBriteInput) : balAllBearFull ? color.new(zeroLineDnColorInput, zeroLineBriteInput) : na : na
zeroPlot = plot(0, "Zero Line", zeroLineColor, zeroLineThicknessInput, plot.style_circles)
// Normal fill between balance and zero line.
color lineFillUpLoColor = color.new(balanceFillUpColorInput, math.max(90, balanceFillBriteInput))
color lineFillUpHiColor = color.new(balanceFillUpColorInput, balanceFillBriteInput)
color lineFillDnLoColor = color.new(balanceFillDnColorInput, math.max(90, balanceFillBriteInput))
color lineFillDnHiColor = color.new(balanceFillDnColorInput, balanceFillBriteInput)
int lineFillGradientSteps = balanceFillColorCalcInput == CC10 ? 8 : balanceFillColorCalcInput == CC2 ? 4 : 16
float lineFillGradientCenter = balanceFillColorCalcInput != CC10 ? 0 : math.avg(divLevelsHi, divLevelsLo)
float lineFillGradientSignal = balanceFillColorCalcInput != CC10 ? colorModeToSignal(balanceFillColorCalcInput) : balance
color balanceFillColor = gradientAdvDecPro(lineFillGradientSignal, lineFillGradientCenter, lineFillGradientSteps, lineFillDnLoColor, lineFillDnHiColor, lineFillUpLoColor, lineFillUpHiColor)
fill(balancePlot, zeroPlot, balanceLineCalcInput != CB5 ? balanceFillColor : na, title = "Volume Balance Fill")
// When Dual Buy/Sell Averages are plotted, fill between those.
fill(balancePlot, balanceLoPlot, balanceLineCalcInput == CB5 ? balanceFillColor : na, title = "Buy/Sell Averages Fill")


// —————————— Divergences and divergence levels
color divLevelsColor     = divLevelsHState ? color.new(divLevelsUpColorInput, divLevelsBriteInput)     : divLevelsLState ? color.new(divLevelsDnColorInput, divLevelsBriteInput)     : color.new(divLevelsNtColorInput, divLevelsBriteInput)
color divLevelsFillColor = divLevelsHState ? color.new(divLevelsUpColorInput, filldivLevelsBriteInput) : divLevelsLState ? color.new(divLevelsDnColorInput, filldivLevelsBriteInput) : color.new(divLevelsNtColorInput, filldivLevelsBriteInput)
color divColor           = divergenceDotColorInput
// Divergence levels.
divLevelsHiPlot = plot(not columnsOnInput and balanceLineCalcInput != CB5 and divergenceCalcInput != CB0 ? divLevelsHi : na, "Divergence Hi Level", divLevelsChanged ? na : divLevelsColor)
divLevelsLoPlot = plot(not columnsOnInput and balanceLineCalcInput != CB5 and divergenceCalcInput != CB0 ? divLevelsLo : na, "Divergence Lo Level", divLevelsChanged ? na : divLevelsColor)
fill(divLevelsHiPlot, divLevelsLoPlot, filldivLevelsInput and not divLevelsChanged ? divLevelsFillColor : na)
// Divergence dots.
plotchar(divergenceCalcInput != CB0 and divLevelsDiv, "Divergence dot", "•", location.top, divColor)


// —————————— Chart bars
color chartBarsUpLoColor = color.new(chartBarsUpColorInput, math.max(90, chartBarsBriteInput))
color chartBarsUpHiColor = color.new(chartBarsUpColorInput, chartBarsBriteInput)
color chartBarsDnLoColor = color.new(chartBarsDnColorInput, math.max(90, chartBarsBriteInput))
color chartBarsDnHiColor = color.new(chartBarsDnColorInput, chartBarsBriteInput)
int chartBarsFillGradientSteps = chartBarsColorCalcInput == CC2 or chartBarsColorCalcInput == CC9 ? 4 : 8
color chartBarsFillColor = chartBarsColorCalcInput == CC7 ? balBarBull ? chartBarsUpHiColor : chartBarsDnHiColor : gradientAdvDecPro(colorModeToSignal(chartBarsColorCalcInput), 0, chartBarsFillGradientSteps, chartBarsDnLoColor, chartBarsDnHiColor, chartBarsUpLoColor, chartBarsUpHiColor)
barcolor(chartBarsShowDivInput and divLevelsDiv ? chartBarsDivColorInput : hollowOutBodiesInput and not volUp ? na : chartBarsFillColor)


// —————————— Background
// Color background on selected signal.
color bgUpLoColor = color.new(bgUpColorInput, math.max(90, bgFillBriteInput))
color bgUpHiColor = color.new(bgUpColorInput, bgFillBriteInput)
color bgDnLoColor = color.new(bgDnColorInput, math.max(90, bgFillBriteInput))
color bgDnHiColor = color.new(bgDnColorInput, bgFillBriteInput)
color bgFillColor = gradientAdvDecPro(colorModeToSignal(bgFillColorCalcInput), 0, 32, bgDnLoColor, bgDnHiColor, bgUpLoColor, bgUpHiColor)
// Color background on total volume discrepancy.
bool totalVolumeDisc = math.abs(volT - volume) / volume > failureToleranceInput
bgcolor(totalVolumeDisc and color.t(bgColorInput) != 100 ? bgColorInput : bgFillColor)


// —————————— Markers
plotshape(a1U, "Marker 1 Up", shape.triangleup,   location.bottom,  NONE, size = size.tiny, text = "▲\n1", textcolor = GENERAL_UP_HI)
plotshape(a1D, "Marker 1 Dn", shape.triangledown, location.top,     NONE, size = size.tiny, text = "1\n▼", textcolor = GENERAL_DN_HI)
plotshape(a2U, "Marker 2 Up", shape.triangleup,   location.bottom,  NONE, size = size.tiny, text = "▲\n2", textcolor = GENERAL_UP_HI)
plotshape(a2D, "Marker 2 Dn", shape.triangledown, location.top,     NONE, size = size.tiny, text = "2\n▼", textcolor = GENERAL_DN_HI)
plotshape(a3U, "Marker 3 Up", shape.triangleup,   location.bottom,  NONE, size = size.tiny, text = "▲\n3", textcolor = GENERAL_UP_HI)
plotshape(a3D, "Marker 3 Dn", shape.triangledown, location.top,     NONE, size = size.tiny, text = "3\n▼", textcolor = GENERAL_DN_HI)
plotshape(a4U, "Marker 4 Up", shape.triangleup,   location.bottom,  NONE, size = size.tiny, text = "▲\n4", textcolor = GENERAL_UP_HI)
plotshape(a4D, "Marker 4 Dn", shape.triangledown, location.top,     NONE, size = size.tiny, text = "4\n▼", textcolor = GENERAL_DN_HI)
plotshape(a5U, "Marker 5 Up", shape.triangleup,   location.bottom,  NONE, size = size.tiny, text = "▲\n5", textcolor = GENERAL_UP_HI)
plotshape(a5D, "Marker 5 Dn", shape.triangledown, location.top,     NONE, size = size.tiny, text = "5\n▼", textcolor = GENERAL_DN_HI)


// —————————— Information box
// Display information box only once on the last historical bar, instead of on all realtime updates, as when `barstate.islast` is used.
if showInfoBoxInput and barstate.islastconfirmedhistory
    var table infoBox = table.new(infoBoxYPosInput + "_" + infoBoxXPosInput, 1, 1)
    color infoBoxBgColor = infoBoxColorInput
    string txt = str.format(
      "Uses intrabars at {0}\nAvg intrabars per chart bar: {1,number,#.##}\nChart bars covered: {2} / {3} ({4,number,percent})", 
      PCtime.formattedNoOfPeriods(timeframe.in_seconds(intrabarTf) * 1000), 
      avgIntrabars, chartBarsCovered, bar_index + 1, chartBarsCovered / (bar_index + 1))
    if avgIntrabars < 5
        txt += "\nThis quantity of intrabars is dangerously small.\nResults will not be as reliable with so few."
        infoBoxBgColor := color.red
    table.cell(infoBox, 0, 0, txt, text_color = infoBoxTxtColorInput, text_size = infoBoxSizeInput, bgcolor = infoBoxBgColor)
//#endregion



//#region ———————————————————— Alerts


// —————Build alert messages.
string alertMsgUp = ""
string alertMsgDn = ""
alertMsgUp := addTextIf(a1U, alertMsgUp, "M1▲", ", ")
alertMsgUp := addTextIf(a2U, alertMsgUp, "M2▲", ", ")
alertMsgUp := addTextIf(a3U, alertMsgUp, "M3▲", ", ")
alertMsgUp := addTextIf(a4U, alertMsgUp, "M4▲", ", ")
alertMsgUp := addTextIf(a5U, alertMsgUp, "M5▲", ", ")

alertMsgDn := addTextIf(a1D, alertMsgDn, "M1▼", ", ")
alertMsgDn := addTextIf(a2D, alertMsgDn, "M2▼", ", ")
alertMsgDn := addTextIf(a3D, alertMsgDn, "M3▼", ", ")
alertMsgDn := addTextIf(a4D, alertMsgDn, "M4▼", ", ")
alertMsgDn := addTextIf(a5D, alertMsgDn, "M5▼", ", ")

// ————— Triger alert if needed.
bool alertUp = alertMsgUp != ""
bool alertDn = alertMsgDn != ""
if alertUp
    alert(alertMsgUp == "" ? alertMsgUp : alertMsgUp, alert.freq_once_per_bar)
if alertDn
    alert(alertMsgDn == "" ? alertMsgDn : alertMsgDn, alert.freq_once_per_bar)
//#endregion
````
