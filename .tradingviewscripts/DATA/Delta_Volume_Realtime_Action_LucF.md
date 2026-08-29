<!-- tradingview-pine-id: PUB;qcUK0SOdKz1UMja225BeyM9hbIQjMWcB -->
<!-- tradingviewscripts-format: 1 -->
# Delta Volume Realtime Action [LucF]

Source: https://www.tradingview.com/script/Xh8tLDTe-Realtime-Delta-Volume-Action-LucF/

## Description

█ OVERVIEW

This indicator displays on-chart, realtime, delta volume​ and delta ticks information for each bar. It aims to provide traders who trade price action on small timeframes with volume​ and tick information gathered as updates come in the chart's feed. It builds its own candles, which are optimized to display volume​ delta information. It only works in realtime.

█ WARNING

This script is intended for traders who can already profitably trade discretionary on small timeframes. The high cost in fees and the excitement of trading at small timeframes have ruined many newcomers to trading. While trading at small timeframes can work magic for adrenaline junkies in search of thrills rather than profits, I DO NOT recommend it to most traders. Only seasoned discretionary traders able to factor in the relatively high cost of such a trading practice can ever hope to take money out of markets in that type of environment, and I would venture​ they account for an infinitesimal percentage of traders. If you are a newcomer to trading, AVOID THIS TOOL AT ALL COSTS — unless you are interested in experimenting with the interpretation of volume​ delta combined with price action. No tool currently available on TradingView provides this type of close monitoring of volume​ delta information, but if you are not already trading small timeframes profitably, please do not let yourself become convinced that it is the missing piece you needed. Avoid becoming a sucker who only contributes by providing liquidity to markets.

The information calculated by the indicator cannot be saved on charts, nor can it be recalculated from historical bars.
If you refresh the chart or restart the script, the accumulated information will be lost.

█ FEATURES

Key values
The script displays the following key values:
 • Above the bar: ticks delta​ (DT​), the total ticks​ for the bar, the percentage of total ticks that DT​ represents (DT%)
 • Below the bar: volume delta​ (DV​), the total volume​ for the bar, the percentage of total volume​ that DV​ represents (DV%).

Candles
Candles are composed of four components:
 1. A top shaped like this: ┴, and a bottom shaped like this: ┬ (picture a normal Japanese candle without a body outline; the values used are the same).
 2. The candle bodies are filled with the bull/bear color representing the polarity of DV​. The intensity of the body's color is determined by the DV% value. 
   When DV% is 100, the intensity of the fill is brightest. This plays well in interpreting the body colors, as the smaller, less significant DV% values will produce less vivid colors.
 3. The bright-colored borders of the candle bodies occur on "strong bars", i.e., bars meeting the criteria selected in the script's inputs, which you can configure.
 4. The POC line is a small horizontal line that appears to the left of the candle. It is the volume-weighted average of all price updates during the bar.

Calculations
This script monitors each realtime update of the chart's feed. It first determines if price has moved up or down since the last update. The polarity of the price change, in turn, determines the polarity of the volume​​ and tick for that specific update. If price does not move between consecutive updates, then the last known polarity is used. Using this method, we can calculate a running volume​ delta and ticks delta for the bar, which becomes the bar's final​ delta values when the bar closes (you can inspect values of elapsed realtime bars in the Data Window or the indicator's values). Note that these values will all reset if the script re-executes because of a change in inputs or a chart refresh.

While this method of calculating is not perfect, it is by far the most precise way of calculating volume​ delta available on TradingView at the moment. Calculating more precise results would require scripts to have access to tick data from any chart timeframe. Charts at seconds timeframes do use exchange/broker ticks when the feeds you are using allow for it, and this indicator will run on them, but tick data is not yet available from higher timeframes. Also, note that the method used in this script is far superior to the intrabar inspection technique used on historical bars in my other "Delta Volume​" indicators. This is because volume​ and ticks delta here are calculated from many more realtime updates than the available intrabars in history. Unfortunately, the calculation method used here cannot be used on historical bars, where intrabar inspection remains, in my opinion, the optimal method.

Inputs
The script's inputs provide many ways to personalize all the components: what is displayed, the colors used to display the information, and the marker conditions. Tooltips provide details for many of the inputs; I leave their exploration to you.

Markers
Markers provide a way for you to identify the points of interest of your choice on the chart. You control the set of conditions that trigger each of the five available markers.
You select conditions by entering, in the field for each marker, the number of each condition you want to include, separated by a comma. The conditions are:
  1 —  The bar's polarity is up/dn​.
  2 —  `close` rises/falls ("rises" means it is higher than its value on the previous bar).
  3 —  DV's polarity is +/–.
  4 —  DV% rises (↕).
  5 —  POC rises/falls.
  6 —  The quantity of realtime updates rises (↕).
  7 —  DV​ > limit (You specify the limit in the inputs. Since DV​ can be +/–, DV– must be less than `–limit` for a short marker).
  8 —  DV% > limit (↕).
  9 —  DV+ rises for a long marker, DV– falls for a short.
 10 —  Consecutive DV+/DV– on two bars.
 11 —  Total volume rises (↕).
 12 —  DT's polarity is +/–.
 13 —  DT% rises (↕).
 14 —  DT+ rises for a long marker, DT– falls for a short.

Conditions showing the (↕) symbol do not have symmetrical states; they act more like filters. If you only include condition 4 in a marker's setup, for example, both long and short markers will trigger on bars where DV% rises. To trigger only long or short markers, you must add a condition providing directional differentiation, such as conditions 1 or 2. Accordingly, you would enter "1,4" or "2,4".

For a marker to trigger, ALL the conditions you specified for it must be met. Long markers appear on the chart as "Mx▲" signs under the values displayed below candles. Short markers display "Mx▼" over the number of updates displayed above candles. The marker's number will replace the "x" in "Mx▲". The script loads with five markers that will not trigger because no conditions are associated with them. To activate markers, you will need to select and enter the set of conditions you require for each one.

Alerts
You can configure alerts on this script. They will trigger whenever one of the configured markers triggers. Alerts do not repaint, so they trigger at the bar's close—which is also when the markers will appear.

█ HOW TO USE IT

As a rule, I do not prescribe expected use of my indicators, as traders have proved to be much more creative than me in using them. Additionally, I tend to think that if you expect detailed recommendations from me to be able to use my indicators, it's a sign you are in a precarious situation and should go back to the drawing board and master the necessary basics that will allow you to explore and decide for yourself if my indicators can be useful to you, and how you will use them. I will make an exception for this thing, as it presents fairly novel information. I will use simple logic to surmise potential uses, as contrary to most of my other indicators, I have NOT used this one to actually trade. Markets have a way of throwing wrenches in our seemingly bullet-proof rationalizing, so drive cautiously and please forgive me if the pointers I share here don't pan out.

The first thing to do is to disable your normal bars. You can do this by clicking on the eye icon that appears when you hover over the symbol's name in the upper-left corner of your chart.

The absolute value and polarity of DV​ mean little without perspective; that's why I include both total volume​ for the bar and the percentage that DV​ represents of that total volume​. I interpret a low DV% value as indecision. If you share that opinion, you could, let's say, configure one of the markers on "DV% > 80%", for example (to do so you would enter "8" in the condition field of any marker, and "80" in the limit field for condition 8, below the marker conditions).

I also like to analyze price action on the bar with DV%. Small DV% values should often produce small candle bodies. If a small DV% value occurs on a bar with much movement and high volume​, I'm thinking "tough battle with potential explosive power when one side wins". Conversely, large bodies with high DV% mean that large volume​ is breaching through multiple levels, or that nobody is suddenly willing to take the other side of a normal volume of trades.

I find the POC lines really interesting. First, they tell us the price point where the most significant action (taking into account both price occurrences AND volume​) during the bar occurred. Second, they can be useful when compared against past values. Third, their color helps us in figuring out which ones are the most significant. Unsurprisingly, bunches of orange POCs tend to appear in consolidation zones, in pauses, and before reversals. It may be useful to often focus more on POC progression than on `close` values. This is not to say that OHLC values are not useful; looking, as is customary, for higher highs or lower lows, or for repeated tests of precise levels can of course still be useful. I do like how POCs add another dimension to chart readings.

What should you do with the ticks delta above bars? Old-time ticker tape readers paid attention to the sounds coming from it (the "ticker" moniker actually comes from the sound they made). They knew activity was picking up when the frequency of the "ticks" increased. My thinking is that the total number of ticks will help you in the same way, since increasing updates usually mean growing interest—and thus perhaps price movement, as increasing volatility​ or volume​ would lead us to surmise. Ticks delta can help you figure out when proportionally large, random orders come in from traders with other perspectives than the short-term price action you are typically working with when you use this tool. Just as volume delta, ticks delta are one more informational component that can help you confirm convergence when building your opinions on price action.

What are strong bars? They are an attempt to identify significance. They are like a default marker, except that instead of displaying "Mx▲/▼" below/above the bar, the candle's body is outlined in bright​ bull/bear color when one is detected. Strong bars require a respectable amount of conditions to be met (you can see and re-configure them in the inputs). Think of them as pushes rather than indications of an upcoming, strong and multi-bar move. Pushes do, for sure, often occur at the beginning of strong trends. You will often see a few strong bars occur at 2-3 bar intervals at the beginning or middle of trends. But they also tend to occur at tops/bottoms, which makes their interpretation problematic. Another pattern that you will see quite frequently is a final strong bar in the direction of the trend, followed a few bars later by another strong bar in the reverse direction. My summary analyses seemed to indicate these were perhaps good points where one could make a bet on an early, risky reversal entry.

The last piece of information displayed by the indicator is the color of the candle bodies. Three possible colors are used. Bull/bear is determined by the polarity of DV​, but only when the bar's polarity matches that of DV​. When it doesn't, the color is the divergence color (orange, by default). Whichever color is used for the body, its intensity is determined by the DV% value. Maximum intensity occurs when DV%=100, so the more significant DV% values generate more noticeable colors. Body colors can be useful when looking to confirm the convergence of other components. The visual effect this creates hopefully makes it easier to detect patterns on the chart.

One obvious methodology that comes to mind to trade with this tool would be to use another indicator like [Technical Ratings](https://www.tradingview.com/script/Jdw7wW2g-Technical-Ratings/) at a higher timeframe to identify the larger context's trend, and then use this tool to identify entries for short-term trades in that direction.

█ NOTES AND RAMBLINGS

Instant Calculations
This indicator uses instant values calculated on the bar only. No moving averages or calculations involving historical periods are used. The only exception to this rule is in some of the marker conditions like "Two consecutive DV+ values", where information from the previous bar is used.

Trading Small vs Long Timeframes
I never trade discretionary at the 5sec–5min timeframes this indicator was designed to be used with; I trade discretionary at 1D, 1W and 1M timeframes, and let systems trade at smaller timeframes. The higher the timeframe you trade at, the fewer fees you will pay because you trade less and are not churning trading volume​, as is inevitable at smaller timeframes. Trading at higher timeframes is also a good way to gain an instant edge on most of the trading crowd that has its nose to the ground and often tends to forget the big picture. It also makes for a much less demanding trading practice, where you have lots of time to research and build your long-term opinions on potential future outcomes. While the future is always uncertain, I believe trades riding on long-term trends have stronger underlying support from the reality outside markets.

To traders who will ask why I publish an indicator designed for small timeframes, let me say that my main purpose here is to showcase what can be done with Pine. I often see comments by coders who are obviously not aware of what Pine is capable of in 2021. Since its humble beginnings seven years ago, Pine has grown and become a serious programming language. TradingView's growing popularity and its ongoing commitment to keep Pine accessible to newcomers to programming is gradually making Pine more and more of a standard in indicator and strategy programming. The technical barriers to entry for traders interested in owning their trading practice by developing their personal tools to trade have never been so low. I am also publishing this script because I value volume​ delta information, and I present here what I think is an original way of analyzing it.

Performance
The script puts a heavy load on the Pine runtime and the charting engine. After running the script for a while, you will often notice your chart becoming less responsive, and your chart tab can take longer to activate when you go back to it after using other tabs. That is the reason I encourage you to set the number of historical values displayed on bars to the minimum that meets your needs. When your chart becomes less responsive because the script has been running on it for many hours, refreshing the browser tab will restart everything and bring the chart's speed back up. You will then lose the information displayed on elapsed bars.

Neutral Volume
This script represents a departure from the way I have previously calculated volume​ delta in my scripts. I used the notion of "neutral volume" when inspecting intrabar timeframes, for bars where price did not move. No longer. While this had little impact​ when using intrabar inspection because the minimum usable timeframe was 1min (where bars with zero movement are relatively infrequent), a more precise way was required to handle realtime updates, where multiple consecutive prices often have the same value. This will usually happen whenever orders are unable to move across the bid/ask levels, either because of slow action or because a large-volume​ bid/ask level is taking time to breach. In either case, the proper way to calculate the polarity of volume​ delta for those updates is to use the last known polarity, which is how I calculate now.

The Order Book
Without access to the order book's levels (the depth of market), we are limited to analyzing transactions that come in the TradingView feed for the chart. That does not mean the volume​ delta information calculated this way is irrelevant; on the contrary, much of the information calculated here is not available in trading consoles supplied by exchanges/brokers. Yet it's important to realize that without access to the order book, you are forfeiting the valuable information that can be gleaned from it. The order book's levels are always in movement, of course, and some of the information they contain is mere posturing, i.e., attempts to influence the behavior of other players in the market by traders/systems who will often remove their orders when price comes near their order levels. Nonetheless, the order book is an essential tool for serious traders operating at intraday timeframes. It can be used to time entries/exits, to explain the causes of particular price movements, to determine optimal stop levels, to get to know the traders/systems you are betting against (they tend to exhibit behavioral patterns only recognizable through the order book), etc. This tool in no way makes the order book less useful; I encourage all intraday traders to become familiar with it and avoid trading without one.

---

## Source Code

````pine
//@version=4
//@author=LucF
 
// Delta Volume Realtime Action [LucF]
//  v12, 2022.12.30 14:12 — LucF

// Displays realtime, on-chart, volume and ticks delta information for trading on small timeframes. It replaces the chart's candles.

// This code was written using:
//  • The PineCoders Coding Conventions for Pine: http://www.pinecoders.com/coding_conventions/
//  • Code inspired by the PineCoders publication on `varip`: https://www.tradingview.com/script/ppQxBISk-Using-varip-variables-PineCoders/

// This indicator's page on TV: https://www.tradingview.com/script/Xh8tLDTe-Delta-Volume-Realtime-Action-LucF/


study("Delta Volume Realtime Action [LucF]", "Delta Volume Realtime Action", true, max_labels_count = 500, max_lines_count = 500)



// ———————————————————— Constants {

// Input options.
var string ON  = "On"
var string OFF = "Off"

var string TD1 = "Up"
var string TD2 = "Down"
var string TD3 = "Up and Down"

var string TT_DIRECTIONS = "These settings allow you to filter the marker events you have selected in the section below.
  The filters you apply here will determine which markers trigger alerts.\n► You can safely disregard the warning that will appear when you create alerts."
var string TT_CONDITIONS_LIST = "  1  –  Bar up/dn\n  2  – `close` rises/falls\n  3  –  DV +/–\n  4  –  DV% rises\n  5  –  POC rises/falls\n  6  – 
  Total ticks rises\n  7  –  DV > limit\n  8  –  DV% > limit\n  9  –  DV+ rises / DV– falls\n  10 –  Two consecutive DV+/DV-\n  11 – 
  Total volume rises\n  12 –  DT +/–\n  13 –  DT% rises\n  14 –  DT+ rises / DT– falls\nSee the script's description for more information."
var string TT_STRONGBAR  = "Enter the number of each condition you require for a 'strong bar', separated by a comma, e.g., '1,4,8,11':\n"  + TT_CONDITIONS_LIST
var string TT_CONDITIONS = "Enter the number of each condition you require for the marker to trigger, separated by a comma, e.g., '1,4,8,11':\n" + TT_CONDITIONS_LIST

// Color constants.
var color C_GREEN       = #008000ff
var color C_LIME        = #00FF00ff
var color C_TEAL        = color.teal
var color C_MAROON      = #800000ff
var color C_PINK        = #FF0080ff
var color C_BAR_RED     = #EF5350
var color C_DK_RED      = #C90707
var color C_ORANGE      = #FF8000ff
var color C_DK_ORANGE   = #CE6F0F
var color C_GRAY        = #808080ff
var color C_DK_GRAY     = #434650ff
var color C_SILVER      = color.silver
// }



// ———————————————————— Inputs {

var string GP1 = "Volume Delta (DV is below bar)"
bool    i_showDv            = input(true,           "Show volume delta",                                inline = "10", group = GP1)
bool    i_showDvVolRises    = input(true,           "With ▲▼",                                          inline = "10", group = GP1, tooltip = "When selected, on bars with increasing DV+ or falling DV–, ▲/▼ will appear to the right of the delta volume value. It's the same as condition 9.")
bool    i_showTotalVolume   = input(true,           "Show total volume",                                inline = "11", group = GP1)
bool    i_showTotVolRises   = input(true,           "With ▲▼",                                          inline = "11", group = GP1, tooltip = "When selected, on up/dn bars with increasing total volume, ▲/▼ will appear to the right of the total volume value. It's the same as condition 11.")
bool    i_showDvPercent     = input(true,           "Show DV as % of total volume",                     inline = "12", group = GP1)
bool    i_showDvPctRises    = input(true,           "With ▲▼",                                          inline = "12", group = GP1, tooltip = "When selected, on up/dn bars with increasing DV%, ▲/▼ will appear to the right of the DV% value. It's the same as condition 4.")
bool    i_showDvValueSeps   = input(true,           "Show separators between values",                   group = GP1)
int     i_dvQtyOfValues     = input(50,             "Visible elapsed values",                           inline = "13", minval = 0, maxval = 245, group = GP1, tooltip = "0-245. Use only as many as you need for optimal chart speed.")
string  i_dvTextSize        = input("small",        "Text Size",                                        inline = "14", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = GP1)
int     i_showDVPrec        = input(0,              "Precision of volume values",                       inline = "14", minval = 0, group = GP1)
color   i_c_dvBull          = input(C_GREEN,        "🡑",                                                inline = "15", group = GP1)
color   i_c_dvBear          = input(C_DK_RED,       "🡓",                                                inline = "15", group = GP1)
bool    i_showDvDiv         = input(ON,             "Divergences",                                      inline = "15", options = [OFF, ON], group = GP1) == ON
color   i_c_dvDiv           = input(C_DK_ORANGE,    "",                                                 inline = "15", group = GP1, tooltip = "A divergence occurs when the polarity of delta volume does not match the direction of the bar.")

var string GP2 = "Ticks Delta (DT is above bar)"
bool    i_showDt            = input(true,           "Show ticks delta",                                 inline = "20", group = GP2)
bool    i_showDtVolRises    = input(true,           "With ▲▼",                                          inline = "20", group = GP2, tooltip = "When selected, on bars with increasing DT+ or falling DT–, ▲/▼ will appear to the right of the delta ticks value. It's the same as condition 14.")
bool    i_showTotalTicks    = input(true,           "Show total ticks",                                 inline = "21", group = GP2)
bool    i_showTotTicksRises = input(true,           "With ▲▼",                                          inline = "21", group = GP2, tooltip = "When selected, on up/dn bars with increasing total ticks, ▲/▼ will appear to the right of the total ticks value. It's the same as condition 6.")
bool    i_showDtPercent     = input(true,           "Show DT as % of total ticks",                      inline = "22", group = GP2)
bool    i_showDtPctRises    = input(true,           "With ▲▼",                                          inline = "22", group = GP2, tooltip = "When selected, on up/dn bars with increasing DT%, ▲/▼ will appear to the right of the DT% value. It's the same as condition 13.")
bool    i_showDtValueSeps   = input(true,           "Show separators between values",                   group = GP2)
int     i_dtQtyOfValues     = input(50,             "Visible elapsed values",                           inline = "23", minval = 0, maxval = 245, group = GP2, tooltip = "0-245. Use only as many as you need for optimal chart speed.")
string  i_dtTextSize        = input("small",        "Text Size",                                        inline = "23", options = ["tiny", "small", "normal", "large", "huge", "auto"], group = GP2)
color   i_c_dtBull          = input(C_GREEN,        "🡑",                                                inline = "24", group = GP2)
color   i_c_dtBear          = input(C_DK_RED,       "🡓",                                                inline = "24", group = GP2)
bool    i_showDtDiv         = input(ON,             "Divergences",                                      inline = "24", options = [OFF, ON], group = GP2) == ON
color   i_c_dtDiv           = input(C_DK_ORANGE,    "",                                                 inline = "24", group = GP2, tooltip = "A divergence occurs when the polarity of delta ticks does not match the direction of the bar.")

var string GP3 = "Point of Control (POC)"
bool    i_showPoc           = input(true,           "Show POC",                                         group = GP3)
int     i_pocQtyOfLines     = input(50,             "Visible elapsed POCs",                             inline = "30", minval = 0, maxval = 499, group = GP3, tooltip = "0-499. Use only as many as you need for optimal chart speed.")
int     i_pocLineWidth      = input(2,              "Line width",                                       inline = "30", minval = 0, maxval = 50, group = GP3)
color   i_c_pocBull         = input(C_LIME,         "🡑",                                                inline = "31", group = GP3)
color   i_c_pocBear         = input(C_PINK,         "🡓",                                                inline = "31", group = GP3)
color   i_c_pocNeutral      = input(C_GRAY,         "•",                                                inline = "31", group = GP3)
bool    i_showPocDiv        = input(ON,             "Divergences",                                      inline = "31", options = [OFF, ON], group = GP3) == ON
color   i_c_pocDiv          = input(C_ORANGE,       "",                                                 inline = "31", group = GP3, tooltip = "A divergence occurs when the bar's close is not above/below the POC for an up/dn bar.")
bool    i_pocDivAddDv       = input(ON,             "Add DV+/- requirement to avoid divergence",        options = [OFF, ON], group = GP3, tooltip = "This requires DV polarity to match that of a rising/falling POC to prevent a divergence.") == ON

var string GP4 = "Price Of Highest Volume Tick"
bool    i_showMaxVol        = input(false,          "Show Price Level",                                 inline = "41", group = GP4)
string  i_maxVolChar        = input("•",            "Using",                                            inline = "41", group = GP4)
color   i_c_maxVolUp        = input(C_SILVER,       "🡑",                                                inline = "41", group = GP4)
color   i_c_maxVolDn        = input(C_SILVER,       "🡓",                                                inline = "41", group = GP4, tooltip = "You can use distinct 🡑 and 🡓 colors to distinguish the polarity of the highest volume tick.")

var string GP5 = "Candles"
color   i_c_bodyBull        = input(C_TEAL,         "Bodies: DV+",                                      inline = "51", group = GP5)
color   i_c_bodyBear        = input(C_MAROON,       "DV–",                                              inline = "51", group = GP5)
color   i_c_bodyDiv         = input(C_ORANGE,       "Divergence",                                       inline = "51", group = GP5)
color   i_c_strongBarBull   = input(C_LIME,         "Strong bar outline: 🡑",                            inline = "52", group = GP5)
color   i_c_strongBarBear   = input(C_PINK,         "🡓",                                                inline = "52", group = GP5)
string  i_strongConditions  = input("1,3,5,6,9",    "Conditions",                                       inline = "52", group = GP5, tooltip = TT_STRONGBAR)

var string GP6 = "Marker and alert configuration"
string  i_markerDir         = input(TD3,            "Direction",                                        inline = "6A", group = GP6, options = [TD1, TD2, TD3], tooltip = TT_DIRECTIONS)
string  i_m1Conditions      = input("",             "M1",                                               inline = "60", group = GP6, tooltip = TT_CONDITIONS)
string  i_m2Conditions      = input("",             "M2",                                               inline = "60", group = GP6)
string  i_m3Conditions      = input("",             "M3",                                               inline = "60", group = GP6)
string  i_m4Conditions      = input("",             "M4",                                               inline = "61", group = GP6)
string  i_m5Conditions      = input("",             "M5",                                               inline = "61", group = GP6)
string  i_m6Conditions      = input("",             "M6",                                               inline = "61", group = GP6)
float   i_cond7Limit        = input(0,              "Condition 7: DV Limit",                            inline = "62", group = GP6, minval = 0.)
float   i_cond8Limit        = input(75.,            "Condition 8: DV% Limit",                           inline = "62", group = GP6, minval = 0., maxval = 100, step = 10)
color   i_c_markerUp        = input(C_LIME,         "Marker colors: 🡑",                                 inline = "63", group = GP6)
color   i_c_markerDn        = input(C_PINK,         "🡓",                                                inline = "63", group = GP6, tooltip = "These determine the color of the text above/below candles when a marker triggers.")
string  i_alertMsgUp        = input("",             "Alert message 🡑",                                  inline = "6D", group = GP6)
string  i_alertMsgDn        = input("",             "Alert message 🡓",                                  inline = "6D", group = GP6, tooltip = "This text will replace the alert message for up/down alerts.")
// }



// ———————————————————— Functions {

// ————— Function queues a new element in an array and de-queues its first element.
f_qDq(_array, _val) =>
    array.push(_array, _val)
    array.shift(_array)

// ————— Function creates a string by concatenating `_count` times the `_string`.
f_stringOf(_count, _string) =>
    array.join(array.new_string(_count, _string))

// ————— Function appends `_text` to `_msg` when `_cond` is true.
f_addTextIf(_cond, _msg, _text, _sep) => 
    string _return = _cond ? _msg + (_msg != "" ? _sep : "") + _text : _msg

// ————— Function rounding OHLC to tick precision.
f_roundedToTickOHLC() => 
    float _op = round_to_mintick(open)
    float _hi = round_to_mintick(high)
    float _lo = round_to_mintick(low)
    float _cl = round_to_mintick(close)
    [_op, _hi, _lo, _cl]

// ————— Function returning the delta volume polarity (+/-) for a historical bar or a realtime update.
//       When there is no movement since the last `close`, it uses the previous bar's polarity.
//       The function also works on historical bars and is particularly well-suited to smaller TFs with many bars with no movement.
//       WARNING: Note that one peculiarity of this logic is that a bar with `close > open` will always be considered positive, even if `close < close[1]`.
f_dvUpDn(_open, _close) => 
    // float _open : open price of current bar.
    // float _close: close price of current bar.
    varip bool _dvUp = false
    varip bool _dvDn = false
    varip float _prevClose = _open
    if barstate.isrealtime
        bool _flat = _close == _prevClose
        _dvUp := _flat ? _dvUp : _close > _prevClose
        _dvDn := _flat ? _dvDn : _close < _prevClose
    else
        bool _flat = _close == _open
        _dvUp := not _flat ? _close > _open : _close == _prevClose ? _dvUp : _close > _prevClose
        _dvDn := not _dvUp
    _prevClose := _close
    [_dvUp, _dvDn]

// ————— Function using realtime updates to calculate volume delta, ticks delta and POC.
f_realtimeDvPocDt(_op, _cl) =>
    // float _op: `open` for the bar.
    // float _cl: current price (`close`) of the realtime update.
    // Dependency: f_dvUpDn()
    [_updUp, _updDn]   = f_dvUpDn(_op, _cl)
    if barstate.isrealtime
        varip float _deltaVolume = 0.
        varip float _lastVolume  = 0.
        varip int   _ticksUp     = 0
        varip int   _ticksDn     = 0
        // `close` and volume values for each realtime update.
        varip float[] _weightedCloses  = array.new_float()
        varip float[] _closes  = array.new_float()
        varip float[] _volumes = array.new_float()
        if barstate.isnew
            // New realtime bar or first realtime update when script loads on the chart; reset data.
            _lastVolume  := 0.
            _deltaVolume := 0.
            _ticksUp     := 0
            _ticksDn     := 0
            array.clear(_weightedCloses)
            array.clear(_closes)
            array.clear(_volumes)
    
        // Volume and ticks delta.
        float _newVolume = nz(volume) - _lastVolume
        if _updUp
            _deltaVolume += _newVolume
            _ticksUp     += 1
        else if _updDn
            _deltaVolume -= _newVolume
            _ticksDn     += 1
    
        // POC (volume-weighted average of all prices during the bar's updates).
        array.push(_weightedCloses, _cl * _newVolume)
        array.push(_volumes, _newVolume)
        float _poc = array.avg(_weightedCloses) / array.avg(_volumes)
        // Maintain directional price and volume of ticks to determine price and direction of highest volume tick.
        array.push(_closes, _updUp ? _cl : - _cl)
        float _maxVolume = array.max(_volumes)
        float _priceOfMaxVolume = array.get(_closes, array.lastindexof(_volumes, _maxVolume))
        _maxVolume *= sign(_priceOfMaxVolume)
        // Save current volume to calculate DV in next update.
        _lastVolume := nz(volume)
        [_deltaVolume, _poc, _ticksUp, _ticksDn, abs(_priceOfMaxVolume), _maxVolume]

// ————— Function returning one of up/dn states for a bar.
//       When there is no movement in a bar, it uses the change in `close` from the previous bar to determine an up/dn state.
//       On consecutive bars with no movement and no change from the previous `close`, it uses the last known up/dn state.
f_barUpDn(_open, _close) => 
    // float open : open price of current bar.
    // float close: close price of current bar.
    var bool _barUp = false
    var bool _barDn = false
    bool _flat = _close == _open
    bool _noChange = _close == _close[1]
    _barUp := _close > _open or (_flat and (_close > nz(_close[1], _close) or (_noChange and _barUp)))
    _barDn := _close < _open or (_flat and (_close < nz(_close[1], _close) or (_noChange and _barDn)))
    [_barUp, _barDn]

// ————— Function that transforms strings of user selection of the conditions ("1,2,4,5", let's say) required to be true for each of the markers. 
//       We set an element of the `_map` bool[] array to true for each selected condition. Only requires calling on first bar.
f_initMarkerConditionsMap(_condQty, _userConditions, _map) =>
    // int      _condQty       : quantity of conditions users can choose from.
    // string[] _userConditions: array containing, for each marker, the string of conditions entered by user.
    // bool[]   _map           : boolean translation of user choice of conditions for all markers.
    var int _marquerQty = array.size(_userConditions)
    // 1. Loop across all input strings containing marker conditions. Detect for each the conditions user has entered.
    // 2. For each condition required for a marker to trigger, set its corresponding element in the `_map` to `true`.
    for _markerNo = 0  to _marquerQty - 1
        // Get one input string.
        string[] _userSelections = str.split(array.get(_userConditions, _markerNo), ",")
        int _qtyOfuserConditions = array.size(_userSelections)
        if _qtyOfuserConditions > 0
            // Loop across all values parsed in the input string.
            for _condition = 0 to _qtyOfuserConditions - 1
                string _userChar = array.get(_userSelections, _condition)
                if str.length(_userChar) > 0
                    int _userConditionNo = int(nz(tonumber(_userChar))) - 1
                    if _userConditionNo >= 0 and _userConditionNo < _condQty
                        // Set the corresponding element to `true`; that's how `f_markerState()` will know the condition must be included in the compound condition check for the marker.
                        // This array concatenates all conditions for all markers, so must be indexed accordingly.
                        array.set(_map, (_markerNo * _condQty) + _userConditionNo, true)

// ————— Function returns `true` if all required user-selected conditions for a `_marker` are true.
f_markerState(_marker, _arrayOfConditions, _map) =>
    // int    _marker            : (1 to qty of markers) number of the marker whose required conditions are to be checked.
    // bool[] _arrayOfConditions : array containing the current state of all up or dn conditions on this bar.
    // bool[] _map               : map of user selection of conditions to be checked for each marker.
    var int _condQty = array.size(_arrayOfConditions)
    bool _compoundConditions = true
    bool _conditionsExist    = false
    for _condition = 0 to _condQty - 1
        bool _condMustBeIncluded = array.get(_map, ((_marker - 1) * _condQty) + _condition)
        _conditionsExist := _conditionsExist or _condMustBeIncluded
        if _condMustBeIncluded
            _compoundConditions := _compoundConditions and array.get(_arrayOfConditions, _condition)
    _conditionsExist ? _compoundConditions : false
// }



// ———————————————————— Calculations {

// ————— Get rounded prices.
[op, hi, lo, cl] = f_roundedToTickOHLC()

// ————— Get DV, POC and DT.
[deltaVolume, poc, ticksUp, ticksDn, priceOfMaxVolume, maxVolume] = f_realtimeDvPocDt(op, cl)
float totalVolume  = nz(volume)
float dvPercent    = 100. * abs(deltaVolume) / totalVolume

float deltaTicks   = ticksUp - ticksDn
float totalTicks   = ticksUp + ticksDn
float dtPercent    = 100. * abs(deltaTicks) / totalTicks
// }

// ———————————————————— Markers and alerts {

// User-selected marker directions.
var bool doLongs  = i_markerDir == TD1 or i_markerDir == TD3
var bool doShorts = i_markerDir == TD2 or i_markerDir == TD3

// ————— Set marker conditions.
// Cond 1: bar is up/dn.
[barUp, barDn]   = f_barUpDn(op, cl)
// Cond 2: `close` rises/falls.
bool clHigher    = cl > cl[1]
bool clLower     = cl < cl[1]
// Cond 3: DV is +/-.
bool dvPlus      = deltaVolume > 0
bool dvMinus     = deltaVolume < 0
// Cond 4: DV% rises.
bool dvPctRises  = dvPercent > dvPercent[1]
// Cond 5: POC rises/falls.
bool pocHigher   = poc > poc[1]
bool pocLower    = poc < poc[1]
// Cond 6: Total ticks rises.
bool totTicksRises = totalTicks > totalTicks[1]
// Cond 7: DV breaches limit.
bool dvLimitUp   = deltaVolume >  i_cond7Limit
bool dvLimitDn   = deltaVolume < -i_cond7Limit
// Cond 8: DV% breaches limit.
bool dvpLimit    = dvPercent > i_cond8Limit
// Cond 9: DV rises/falls.
bool dvHigher    = deltaVolume > deltaVolume[1] and dvPlus  and dvPlus[1]
bool dvLower     = deltaVolume < deltaVolume[1] and dvMinus and dvMinus[1]
// Cond 10: Two consecutive DV+/DV-.
bool dvPlusBump  = dvPlus  and dvPlus[1]
bool dvMinusBump = dvMinus and dvMinus[1]
// Cond 11: Total volume Rises.
bool totVolRises = totalVolume > totalVolume[1]
// Cond 12: DT is +/-.
bool dtPlus      = deltaTicks > 0
bool dtMinus     = deltaTicks < 0
// Cond 13: DT% rises.
bool dtPctRises  = dtPercent > dtPercent[1]
// Cond 14: DT rises/falls.
bool dtHigher    = deltaTicks > deltaTicks[1] and dtPlus  and dtPlus[1]
bool dtLower     = deltaTicks < deltaTicks[1] and dtMinus and dtMinus[1]

// Load arrays of states to test each marker's specific conditions against them.
bool[] conditionsUp = array.from(barUp, clHigher, dvPlus,  dvPctRises, pocHigher, totTicksRises, dvLimitUp, dvpLimit, dvHigher, dvPlusBump,  totVolRises, dtPlus,  dtPctRises, dtHigher)
bool[] conditionsDn = array.from(barDn, clLower,  dvMinus, dvPctRises, pocLower,  totTicksRises, dvLimitDn, dvpLimit, dvLower,  dvMinusBump, totVolRises, dtMinus, dtPctRises, dtLower)

// ————— Initialize user-selected marker conditions.
// This array contains one element for each of the input strings of conditions entered by the user for each marker.
// (We use one marker space at the end to put the conditions for "strong bars", but the visual cue for this marker is to outline candle bodies.)
string[] markerUserConditions = array.from(i_m1Conditions, i_m2Conditions, i_m3Conditions, i_m4Conditions, i_m5Conditions, i_m6Conditions, i_strongConditions)
var int markerQty = array.size(markerUserConditions)
var int conditionsQty = array.size(conditionsUp)
// Once initialized using `f_initMarkerConditionsMap()`, this fixed size array will contain the representation of the user's selection of conditions for each marker.
// After initialization, its elements will be `true` for each condition required by user for each marker. Aggregates all selections for all markers, sequentially.
var bool[] markerConditionsMap = array.new_bool(markerQty * conditionsQty, false)
// On first bar only, intialize the map of user conditions for the markers. This tells us which conditions must be true for each marker to trigger.
if barstate.isfirst
    f_initMarkerConditionsMap(conditionsQty, markerUserConditions, markerConditionsMap)

// ————— Test each marker's required conditions against their state and build relevant alert triggering conditions, label and alert texts.
string labelMsgUp   = ""
string labelMsgDn   = ""
string alertMsgUp   = ""
string alertMsgDn   = ""
if barstate.isconfirmed
    for _marker = 1 to markerQty - 1
        // Get up/dn state of one marker.
        bool _cUp = f_markerState(_marker, conditionsUp, markerConditionsMap) and doLongs
        bool _cDn = f_markerState(_marker, conditionsDn, markerConditionsMap) and doShorts
        // Build marker label's text.
        string _markerNo = "M" + tostring(_marker)
        labelMsgUp := f_addTextIf(_cUp, labelMsgUp, _markerNo + "▲", "\n")
        labelMsgDn := f_addTextIf(_cDn, labelMsgDn, _markerNo + "▼", "\n")
        // Build alert's message.
        alertMsgUp := f_addTextIf(_cUp, alertMsgUp, _markerNo + "▲", ", ")
        alertMsgDn := f_addTextIf(_cDn, alertMsgDn, _markerNo + "▼", ", ")

// ————— Triger alert if needed.
bool alertUp = alertMsgUp != ""
bool alertDn = alertMsgDn != ""
if alertUp
    alert(i_alertMsgUp == "" ? alertMsgUp : i_alertMsgUp, alert.freq_once_per_bar_close)
if alertDn
    alert(i_alertMsgDn == "" ? alertMsgDn : i_alertMsgDn, alert.freq_once_per_bar_close)
// }



// ———————————————————— Plots {

// —————————— Update realtime POC and labels above/below bar.
// ————— POC line
bool dvDiv  = (dvPlus and barDn) or (dvMinus and barUp)
bool dtDiv  = (dtPlus and barDn) or (dtMinus and barUp)
bool pocDiv = (pocHigher and cl < op) or (pocLower and cl > op) or (i_pocDivAddDv and ((pocHigher and dvMinus) or (pocLower and dvPlus)))
color c_poc = pocHigher ? i_showPocDiv and pocDiv ? i_c_pocDiv : i_c_pocBull : pocLower ? i_showPocDiv and pocDiv ? i_c_pocDiv : i_c_pocBear : i_c_pocNeutral
if i_showPoc
    var line rtPoc = line.new(na, na, na, na, width = i_pocLineWidth)
    line.set_xy1(rtPoc, bar_index - 1, poc)
    line.set_xy2(rtPoc, bar_index, poc)
    line.set_color(rtPoc, c_poc)

// ————— Label above bar (DT).
var string SEPARATOR = "⸺\n"
var string sepBeforeTotalTicks = i_showDt and i_showTotalTicks and i_showDtValueSeps ? SEPARATOR : ""
var string sepBeforeDtPercent  = i_showDt and i_showTotalTicks and i_showDtPercent and i_showDtValueSeps ? "=\n" : ""
string dtText          = i_showDt ? tostring(deltaTicks) + (i_showDtVolRises ? dtHigher ? "▲" : dtLower ? "▼" : "" : "") + "\n" : ""
string totalTicksText  = i_showTotalTicks ? sepBeforeTotalTicks + tostring(totalTicks) + (i_showTotTicksRises and totTicksRises ? barUp ? "▲" : "▼" : "") + "\n" : ""
string dtPctText       = i_showDtPercent ? sepBeforeDtPercent + tostring(dtPercent, "#") + "%" + (i_showDtPctRises and dtPctRises ? barUp ? "▲" : "▼" : "") : ""
string labelTextAbove  = dtText + totalTicksText + dtPctText
color  c_labelAbove    = i_showDtDiv and dtDiv ? i_c_dtDiv : dtPlus ? i_c_dtBull : dtMinus ? i_c_dtBear : na
var label rtLabelAbove = label.new(bar_index, na, labelTextAbove, style = label.style_label_down, color = color(na), textcolor = c_labelAbove, size = i_dtTextSize)
label.set_xy(rtLabelAbove, bar_index, hi)
label.set_text(rtLabelAbove, labelTextAbove)
label.set_textcolor(rtLabelAbove, c_labelAbove)

// ————— Label below bar (DV).
var string sepBeforeTotalVolume = i_showDv and i_showTotalVolume and i_showDvValueSeps ? SEPARATOR : ""
var string sepBeforeDvPercent   = i_showDv and i_showTotalVolume and i_showDvPercent and i_showDvValueSeps ? "=\n" : ""
var string dvPrecision = "0" + (i_showDVPrec == 0 ? "" : ".") + f_stringOf(i_showDVPrec, "0")
string dvText          = i_showDv ? tostring(deltaVolume, dvPrecision) + (i_showDvVolRises ? dvHigher ? "▲" : dvLower ? "▼" : "" : "") + "\n" : ""
string totalVolumeText = i_showTotalVolume ? sepBeforeTotalVolume + tostring(totalVolume, dvPrecision) + (i_showTotVolRises and totVolRises ? barUp ? "▲" : "▼" : "") + "\n" : ""
string dvPctText       = i_showDvPercent ? sepBeforeDvPercent + tostring(dvPercent, "#") + "%" + (i_showDvPctRises and dvPctRises ? barUp ? "▲" : "▼" : "") + "\n" : ""
string labelTextBelow  = dvText + totalVolumeText + dvPctText
color  c_labelBelow    = i_showDvDiv and dvDiv ? i_c_dvDiv : dvPlus ? i_c_dvBull : dvMinus ? i_c_dvBear : na
var label rtLabelBelow = label.new(bar_index, na, labelTextBelow, style = label.style_label_up, color = color(na), textcolor = c_labelBelow, size = i_dvTextSize)
label.set_xy(rtLabelBelow, bar_index, lo)
label.set_text(rtLabelBelow, labelTextBelow)
label.set_textcolor(rtLabelBelow, c_labelBelow)


// —————————— Realtime bar closes; create final POC and labels for elapsed realtime bars, showing only as many as user has chosen.
if barstate.isrealtime and barstate.isconfirmed 
    var label[] dvLabels = array.new_label(i_dvQtyOfValues)
    var label[] dtLabels = array.new_label(i_dtQtyOfValues)
    var line[]  pocLines = array.new_line( i_pocQtyOfLines)
    // Draw above/below bar labels.
    labelTextAbove := (alertDn ? labelMsgDn + "\n\n" : "") + labelTextAbove
    c_labelAbove   := alertDn ? i_c_markerDn : c_labelAbove
    label.delete(f_qDq(dtLabels, label.new(bar_index, hi, labelTextAbove, style = label.style_label_down, color = color(na), textcolor = c_labelAbove, size = i_dtTextSize)))
    labelTextBelow += alertUp ? "\n" + labelMsgUp : ""
    c_labelBelow   := alertUp ? i_c_markerUp : c_labelBelow
    label.delete(f_qDq(dvLabels,  label.new(bar_index, lo, labelTextBelow, style = label.style_label_up,   color = color(na), textcolor = c_labelBelow, size = i_dvTextSize)))
    // Display elapsed POCs.
    line.delete(f_qDq(pocLines, line.new(bar_index - 1, poc, bar_index, poc, color = c_poc, width = i_pocLineWidth)))
    

// —————————— Data Window.
float dvPctSigned = dvPercent * sign(deltaVolume)
float dtPctSigned = dtPercent * sign(deltaTicks)
plotchar(barstate.isrealtime ? deltaVolume : na, "DV",           "", location.top, c_labelBelow)
plotchar(barstate.isrealtime ? volume      : na, "Total Volume", "", location.top, c_labelBelow)
plotchar(barstate.isrealtime ? dvPctSigned : na, "DV% +/−",      "", location.top, c_labelBelow)
plotchar(barstate.isrealtime ? poc         : na, "POC",          "", location.top, c_poc)
plotchar(barstate.isrealtime ? dtPctSigned : na, "DT% +/−",      "", location.top, c_labelAbove)

// —————————— Candles.
// ————— Body-less ┴ and ┬ formations for top/bottom of candle.
float topHi = hi
float topLo = max(op, cl)
float botHi = min(op, cl)
float botLo = lo
color c_outlines = barUp ? i_c_bodyBull : i_c_bodyBear
plotcandle(topLo, topHi, topLo, topLo, "Open",  color = c_outlines, wickcolor = c_outlines, bordercolor = c_outlines)
plotcandle(botHi, botHi, botLo, botHi, "Close", color = c_outlines, wickcolor = c_outlines, bordercolor = c_outlines)

// ————— Body containing color indicating DV polarity.
float dvTransp = 100 - dvPercent
color c_candleBody = dvDiv ? color.new(i_c_bodyDiv, dvTransp) : dvPlus ? color.new(i_c_bodyBull, dvTransp) : dvMinus ? color.new(i_c_bodyBear, dvTransp) : na
color c_strongBarBorder = f_markerState(7, conditionsUp, markerConditionsMap) ? i_c_strongBarBull : f_markerState(7, conditionsDn, markerConditionsMap) ? i_c_strongBarBear : na
plotcandle(botHi, topLo, botHi, topLo, "Body",  c_candleBody, wickcolor = na, bordercolor = c_strongBarBorder)

// ————— Level of highest volume tick.
color c_maxVolume = maxVolume > 0  ? i_c_maxVolUp : i_c_maxVolDn
plotchar(i_showMaxVol ? priceOfMaxVolume : na, "Price Mark for Highest Volume", i_maxVolChar, location.absolute, c_maxVolume, size = size.tiny)
plotchar(priceOfMaxVolume, "Price of Highest Volume", "", location.top, c_maxVolume, size = size.tiny)
plotchar(maxVolume, "Highest Volume", "", location.top, c_maxVolume, size = size.tiny)
// }
````
