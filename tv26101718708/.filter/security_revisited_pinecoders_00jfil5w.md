# `security()` revisited [PineCoders]

- url: https://www.tradingview.com/script/00jFIl5w-security-revisited-PineCoders/
- type: indicator
- pine_id: PUB;CKohWiMWTSey36vsQZT8tkKbm6eUkevU
- version: 2.0

## Description

[b]NOTE[/b]

The non-repainting technique in this publication that relies on bar states is now deprecated, as we have identified inconsistencies that undermine its credibility as a universal solution. The outputs that use the technique are still available for reference in this publication. However, we do not endorse its usage. See [url=https://www.tradingview.com/script/W1YpYcOI-Higher-timeframe-requests/]this publication[/url] for more information about the current best practices for requesting HTF data and why they work. 



█ [b]OVERVIEW[/b]

This script presents a new function to help coders use [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] in both repainting and non-repainting modes. We revisit this often misunderstood and misused function, and explain its behavior in different contexts, in the hope of dispelling some of the coder lure surrounding it. The function is incredibly powerful, yet misused, it can become a dangerous [url=https://en.wikipedia.org/wiki/Weapon_of_mass_destruction]WMD[/url] and an instrument of deception, for both coders and traders.

We will discuss:
 • How to use our new `f_security()` function.
 • The behavior of Pine code and [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] on the three very different types of bars that make up any chart.
 • Why what you see on a chart is a simulation, and should be taken with a grain of salt.
 • Why we are presenting a new version of a function handling [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] calls.
 • Other topics of interest to coders using higher timeframe (HTF) data.


█ [b]WARNING[/b]

We have tried to deliver a function that is simple to use and will, in non-repainting mode, produce reliable results for both experienced and novice coders. If you are a novice coder, stick to our recommendations to avoid getting into trouble, and DO NOT change our `f_security()` function when using it. Use `false` as the function's last argument and refrain from using your script at smaller timeframes than the chart's. To call our function to fetch a non-repainting value of [url=https://www.tradingview.com/pine-script-reference/v4/#var_close]close[/url] from the 1D timeframe, use:
[pine]f_security(_sym, _res, _src, _rep) => security(_sym, _res, _src[not _rep and barstate.isrealtime ? 1 : 0])[_rep or barstate.isrealtime ? 0 : 1]
previousDayClose = f_security(syminfo.tickerid, "D", close, false)
[/pine]
If that's all you're interested in, you are done.

If you choose to ignore our recommendation and use the function in repainting mode by changing the `false` in there for `true`, we sincerely hope you read the rest of our ramblings before you do so, to understand the consequences of your choice.

Let's now have a look at what [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] is showing you. There is a lot to cover, so buckle up! But before we dig in, one last thing. 

[b]What is a chart?[/b]
A chart is a graphic representation of events that occur in markets. As any representation, it is not reality, but rather a model of reality. As Scott Page eloquently states in [i]The Model Thinker[/i]: "All models are wrong; many are useful". Having in mind that both chart bars and plots on our charts are imperfect and incomplete renderings of what actually occurred in realtime markets puts us coders in a place from where we can better understand the nature of, and the causes underlying the inevitable compromises necessary to build the data series our code uses, and print chart bars.

Traders or coders complaining that charts do not reflect reality act like someone who would complain that the word "dog" is not a real dog. Let's recognize that we are dealing with models here, and try to understand them the best we can. Sure, models can be improved; TradingView is constantly improving the quality of the information displayed on charts, but charts nevertheless remain mere translations. Plots of data fetched through [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] being modelized renderings of what occurs at higher timeframes, coders will build more useful and reliable tools for both themselves and traders if they endeavor to perfect their understanding of the abstractions they are working with. We hope this publication helps you in this pursuit.


█ [b]FEATURES[/b]

This script's "Inputs" tab has four settings:
 • [b]Repaint[/b]: Determines whether the functions will use their repainting or non-repainting mode. 
  Note that the setting will not affect the behavior of the yellow plot, as it always repaints.
 • [b]Source[/b]: The source fetched by the [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] calls.
 • [b]Timeframe[/b]: The timeframe used for the [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] calls. If it is lower than the chart's timeframe, a warning appears.
 • [b]Show timeframe reminder[/b]: Displays a reminder of the timeframe after the last bar.


█ [b]THE CHART[/b]

The chart shows two different pieces of information and we want to discuss other topics in this section, so we will be covering:
 A — The type of chart bars we are looking at, indicated by the colored band at the top.
 B — The plots resulting of calling [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] with the [url=https://www.tradingview.com/pine-script-reference/v4/#var_close]close[/url] price in different ways.
 C — Points of interest on the chart.

[b]A — Chart bars[/b]

The colored band at the top shows the three types of bars that any chart on a live market will print. It is critical for coders to understand the important distinctions between each type of bar:
 1 — [b]Gray[/b]: Historical bars, which are bars that were already closed when the script was run on them.
 2 — [b]Red[/b]: Elapsed realtime bars, i.e., realtime bars that have run their course and closed. 
   The state of script calculations showing on those bars is that of the last time they were made, when the realtime bar closed.
 3 — [b]Green[/b]: The realtime bar. Only the rightmost bar on the chart can be the realtime bar at any given time, and only when the chart's market is active.
Refer to the Pine User Manual's [url=https://www.tradingview.com/pine-script-docs/en/v4/language/Execution_model.html]Execution model[/url] page for a more detailed explanation of these types of bars.

[b]B — Plots[/b]

The chart shows the result of letting our 5sec chart run for a few minutes with the following settings: "Repaint" = "On" (the default is "Off"), "Source" = `close` and "Timeframe" = 1min. The five lines plotted are the following. They have progressively thinner widths:
 1 — [b]Yellow[/b]: A normal, repainting [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] call.
 2 — [b]Silver[/b]: Our recommended [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] function.
 3 — [b]Fuchsia[/b]: Our recommended way of achieving the same result as our [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] function, for cases when the source used is a function returning a tuple.
 4 — [b]White[/b]: The method we previously recommended in our [url=https://www.tradingview.com/script/90mqACUV-MTF-Selection-Framework-PineCoders-FAQ/]MTF Selection Framework[/url], which uses two distinct [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] calls.
 5 — [b]Black[/b]: A lame attempt at fooling traders that MUST be avoided.

All lines except the first one in yellow will vary depending on the "Repaint" setting in the script's inputs. The first plot does not change because, contrary to all other plots, it contains no conditional code to adapt to repainting/no-repainting modes; it is a simple [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] call showing its default behavior.

[b]C — Points of interest on the chart[/b]

[b]Historical bars do not show actual repainting behavior[/b]
To appreciate what a repainting [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] call will plot in realtime, one must look at the realtime bar and at elapsed realtime bars, the bars where the top line is green or red on the chart at the top of this page. There you can see how the plots go up and down, following the [url=https://www.tradingview.com/pine-script-reference/v4/#var_close]close[/url] value of each successive chart bar making up a single bar of the higher timeframe. You would see the same behavior in "Replay" mode. In the realtime bar, the movement of repainting plots will vary with the source you are fetching: [url=https://www.tradingview.com/pine-script-reference/v4/#var_open]open[/url] will not move after a new timeframe opens, [url=https://www.tradingview.com/pine-script-reference/v4/#var_low]low[/url] and [url=https://www.tradingview.com/pine-script-reference/v4/#var_high]high[/url] will change when a new [url=https://www.tradingview.com/pine-script-reference/v4/#var_low]low[/url] or [url=https://www.tradingview.com/pine-script-reference/v4/#var_high]high[/url] are found, [url=https://www.tradingview.com/pine-script-reference/v4/#var_close]close[/url] will follow the last feed update. If you are fetching a value calculated by a function, it may also change on each update.

Now notice how different the plots are on historical bars. There, the plot shows the [url=https://www.tradingview.com/pine-script-reference/v4/#var_close]close[/url] of the previously completed timeframe for the whole duration of the current timeframe, until on its last bar the price updates to the current timeframe's [url=https://www.tradingview.com/pine-script-reference/v4/#var_close]close[/url] when it is confirmed (if the timeframe's last bar is missing, the plot will only update on the next timeframe's first bar). That last bar is the only one showing where the plot would end if that timeframe's bars had elapsed in realtime. If one doesn't understand this, one cannot properly visualize how his script will calculate in realtime when using repainting. Additionally, as published scripts typically show charts where the script has only run on historical bars, they are, in fact, misleading traders who will naturally assume the script will behave the same way on realtime bars.

[b]Non-repainting plots are more accurate on historical bars[/b]
Now consider this chart, where we are using the same settings as on the chart used to publish this script, except that we have turned "Repainting" off this time:

[image]https://www.tradingview.com/x/ETkGnLWO/[/image]

The yellow line here is our reference, repainting line, so although repainting is turned off, it is still repainting, as expected. Because repainting is now off, however, plots on historical bars show the previous timeframe's [url=https://www.tradingview.com/pine-script-reference/v4/#var_close]close[/url] until the first bar of a new timeframe, at which point the plot updates. This correctly reflects the behavior of the script in the realtime bar, where because we are offsetting the series by one, we are always showing the previously calculated—and thus confirmed—higher timeframe value. This means that in realtime, we will only get the previous timeframe's values one bar after the timeframe's last bar has elapsed, at the [url=https://www.tradingview.com/pine-script-reference/v4/#var_open]open[/url] of the first bar of a new timeframe. Historical and elapsed realtime bars will not actually show this nuance because they reflect the state of calculations made on their [url=https://www.tradingview.com/pine-script-reference/v4/#var_close]close[/url], but we can see the plot update on that bar nonetheless.

► This more accurate representation on historical bars of what will happen in the realtime bar is one of the two key reasons why using non-repainting data is preferable. 
   The other is that in realtime, your script will be using more reliable data and behave more consistently.

[b]Misleading plots[/b]
Valiant attempts by coders to show non-repainting, higher timeframe data updating earlier than on our chart are futile. If updates occur one bar earlier because coders use the repainting version of the function, then so be it, but they must then also accept that their historical bars are not displaying information that is as accurate. Not informing script users of this is to mislead them. Coders should also be aware that if they choose to use repainting data in realtime, they are sacrificing reliability to speed and may be running a strategy that behaves very differently from the one they backtested, thus invalidating their tests.

When, however, coders make what are supposed to be non-repainting plots plot artificially early on historical bars, as in examples "c4" and "c5" of our script, they would want us to believe they have achieved the miracle of time travel. Our understanding of the current state of science dictates that for now, this is impossible. Using such techniques in scripts is plainly misleading, and public scripts using them will be moderated. We are coding trading tools here—not video games. Elementary ethics prescribe that we should not mislead traders, even if it means not being able to show sexy plots. As the great Feynman said: [i]You should not fool the layman when you're talking as a scientist.[/i]

You can readily appreciate the fantasy plot of "c4", the thinnest line in black, by comparing its supposedly non-repainting behavior between historical bars and realtime bars. After updating—by miracle—as early as the wide yellow line that is repainting, it suddenly moves in a more realistic place when the script is running in realtime, in synch with our non-repainting lines. The "c5" version does not plot on the chart, but it displays in the Data Window. It is even worse than "c4" in that it also updates magically early on historical bars, but goes on to evaluate like the repainting yellow line in realtime, except one bar late.

[b]Data Window[/b]
The Data Window shows the values of the chart's plots, then the values of both the inside and outside offsets used in our calculations, so you can see them change bar by bar. Notice their differences between historical and elapsed realtime bars, and the realtime bar itself. If you do not know about the Data Window, have a look at this essential tool for Pine coders in the Pine User Manual's page on [url=https://www.tradingview.com/pine-script-docs/en/v4/Debugging.html]Debugging[/url]. The conditional expressions used to calculate the offsets may seem tortuous but their objective is quite simple. When repainting is on, we use this form, so with no offset on all bars:
[pine]
security(ticker, i_timeframe, i_source[0])[0]
// which is equivalent to:
security(ticker, i_timeframe, i_source)
[/pine]
When repainting is off, we use two different and inverted offsets on historical bars and the realtime bar:
[pine]
// Historical bars:
security(ticker, i_timeframe, i_source[0])[1]
// Realtime bar (and thus, elapsed realtime bars):
security(ticker, i_timeframe, i_source[1])[0]
[/pine]
The offsets in the first line show how we prevent repainting on historical bars without the need for the `lookahead` parameter. We use the value of the function call on the chart's previous bar. Since values between the repainting and non-repainting versions only differ on the timeframe's last bar, we can use the previous value so that the update only occurs on the timeframe's first bar, as it will in realtime when not repainting.

In the realtime bar, we use the second call, where the offsets are inverted. This is because if we used the first call in realtime, we would be fetching the value of the repainting function on the previous bar, so the [url=https://www.tradingview.com/pine-script-reference/v4/#var_close]close[/url] of the last bar. What we want, instead, is the data from the previous, [b]higher timeframe bar[/b], which has elapsed and is confirmed, and thus will not change throughout realtime bars, except on the first constituent chart bar belonging to a new higher timeframe.

After the offsets, the Data Window shows values for the `barstate.*` variables we use in our calculations.


█ [b]NOTES[/b]

[b]Why are we revisiting [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] ?[/b]
For four reasons:
 1 — We were seeing coders misuse our `f_secureSecurity()` function presented in [url=https://www.tradingview.com/script/cyPWY96u-How-to-avoid-repainting-when-using-security-PineCoders-FAQ/]How to avoid repainting when using security()[/url]. 
   Some novice coders were modifying the offset used with the history-referencing operator in the function, making it zero instead of one, 
   which to our horror, caused look-ahead bias when used with `lookahead = barmerge.lookahead_on`.
   We wanted to present a safer function which avoids introducing the dreaded "lookahead" in the scripts of unsuspecting coders.
 2 — The popularity of [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] in screener-type scripts where coders need to use the full 40 calls allowed per script made us want to propose 
   a solid method of allowing coders to offer a repainting/no-repainting choice to their script users with only one [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] call.
 3 — We wanted to explain why some alternatives we see circulating are inadequate and produce misleading behavior.
 4 — Our previous publication on [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] focused on how to avoid repainting, yet many other considerations worthy of attention are not related to repainting.

[b]Handling tuples[/b]
When sending function calls that return [url=https://www.tradingview.com/pine-script-docs/en/v4/language/Type_system.html?highlight=tuple#tuples]tuples[/url] with [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url], our `f_security()` function will not work because Pine does not allow us to use the [url=https://www.tradingview.com/pine-script-docs/en/v4/language/Operators.html#history-reference-operator]history-referencing operator[/url] with [url=https://www.tradingview.com/pine-script-docs/en/v4/language/Type_system.html?highlight=tuple#tuples]tuple[/url] return values. The solution is to integrate the inside offset to your function's arguments, use it to offset the results the function is returning, and then add the outside offset in a reassignment of the [url=https://www.tradingview.com/pine-script-docs/en/v4/language/Type_system.html?highlight=tuple#tuples]tuple[/url] variables, after [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] returns its values to the script, as we do in our "c2" example.

[b]Does it repaint?[/b]
We're pretty sure Wilder was not asked very often if RSI repainted. Why? Because it wasn't in fashion—and largely unnecessary—to ask that sort of question in the 80's. Many traders back then used daily charts only, and indicator values were calculated at the day's close, so everybody knew what they were getting. Additionally, indicator values were calculated by generally reputable outfits or traders themselves, so data was pretty reliable. Today, almost anybody can write a simple indicator, and the programming languages used to write them are complex enough for some coders lacking the caution, know-how or ethics of the best professional coders, to get in over their heads and produce code that does not work the way they think it does.

As we hope to have clearly demonstrated, traders do have legitimate cause to ask if MTF scripts repaint or not when authors do not specify it in their script's description.
► We recommend that authors [b]always[/b] use our `f_security()` with `false` as the last argument to avoid repainting when fetching data dependent on OHLCV information. This is the [b]only[/b] way to obtain reliable HTF data. If you want to offer users a choice, make non-repainting mode the default, so that if users choose repainting, it will be their responsibility. Non-repainting [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] calls are also the only way for scripts to show historical behavior that matches the script's realtime behavior, so you are not misleading traders. Additionally, non-repainting HTF data is the only way that non-repainting alerts can be configured on MTF scripts, as users of MTF scripts cannot prevent their alerts from repainting by simply configuring them to trigger on the bar's close.

[b]Data feeds[/b]
A chart at one timeframe is made up of multiple feeds that mesh seamlessly to form one chart. Historical bars can use one feed, and the realtime bar another, which brokers/exchanges can sometimes update retroactively so that elapsed realtime bars will reappear with very slight modifications when the browser's tab is refreshed. Intraday and daily chart prices also very often originate from different feeds supplied by brokers/exchanges. That is why [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url][/b] calls at higher timeframes may be using a completely different feed than the chart, and explains why the daily [url=https://www.tradingview.com/pine-script-reference/v4/#var_high]high[/url] value, for example, can vary between timeframes. Volume information can also vary considerably between intraday and daily feeds in markets like stocks, because more volume information becomes available at the end of day. It is thus expected behavior—and not a bug—to see data variations between timeframes.

Another point to keep in mind concerning feeds it that when you are using a repainting [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] plot in realtime, you will sometimes see discrepancies between its plot and the realtime bars. An artefact revealing these inconsistencies can be seen when [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] plots sometimes skip a realtime chart bar during periods of high market activity. This occurs because of races between the chart and the [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] feeds, which are being monitored by independent, concurrent processes. A blue arrow on the chart indicates such an occurrence. This is another cause of repainting, where realtime bar-building logic can produce different outcomes on one closing price. It is also another argument supporting our recommendation to use non-repainting data.

[b]Alternatives[/b]
There is an alternative to using [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] in some conditions. If all you need are OHLC prices of a higher timeframe, you can use a technique like the one Duyck demonstrates in his [url=https://www.tradingview.com/script/Ql1FjjfX-security-free-MTF-example-JD/]security free MTF example - JD[/url] script. It has the great advantage of displaying actual repainting values on historical bars, which mimic the code's behavior in the realtime bar—or at least on elapsed realtime bars, contrary to a repainting [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] plot. It has the disadvantage of using the current chart's TF data feed prices, whereas higher timeframe data feeds may contain different and more reliable prices when they are compiled at the end of the day. In its current state, it also does not allow for a repainting/no-repainting choice.

[b]When `lookahead` is useful[/b]
When retrieving non-price data, or in special cases, for experiments, it can be useful to use `lookahead`. One example is our [url=https://www.tradingview.com/script/q9laJNG9-Backtesting-on-Non-Standard-Charts-Caution-PineCoders-FAQ/]Backtesting on Non-Standard Charts: Caution![/url] script where we are fetching prices of standard chart bars from non-standard charts.

[b]Warning users[/b]
Normal use of [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url][/b] dictates that it only be used at timeframes equal to or higher than the chart's. To prevent users from inadvertently using your script in contexts where it will not produce expected behavior, it is good practice to warn them when their chart is on a higher timeframe than the one in the script's "Timeframe" field. Our `f_tfReminderAndErrorCheck()` function in this script does that. It can also print a reminder of the higher timeframe. It uses one [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] call.

[b]Intrabar timeframes[/b]
[url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] is not supported by TradingView when used with timeframes lower than the chart's. While it is still possible to use [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] at intrabar timeframes, it then behaves differently. If no care is taken to send a function specifically written to handle the successive intrabars, [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url] will return the value of the last intrabar in the chart's timeframe, so the last 1H bar in the current 1D bar, if called at "60" from a "D" chart timeframe. If you are an advanced coder, see our [url=https://www.pinecoders.com/faq_and_code/#is-it-possible-to-use-security-on-lower-intervals-than-the-charts-current-interval]FAQ entry[/url] on the techniques involved in processing intrabar timeframes. Using intrabar timeframes comes with important limitations, which you must understand and explain to traders if you choose to make scripts using the technique available to others. Special care should also be taken to thoroughly test this type of script. Novice coders should refrain from getting involved in this.


█ [b]TERMINOLOGY[/b]

[b]Timeframe[/b]
[i]Timeframe[/i], [i]interval[/i] and [i]resolution[/i] are all being used to name the concept of timeframe. We have, in the past, used "timeframe" and "resolution" more or less interchangeably. Recently, members from the Pine and PineCoders team have decided to settle on "timeframe", so from hereon we will be sticking to that term.

[b]Multi-timeframe (MTF)[/b]
Some coders use "multi-timeframe" or "MTF" to name what are in fact "multi-period" calculations, as when they use MAs of progressively longer periods. We consider that a misleading use of "multi-timeframe", which should be reserved for code using calculations actually made from another timeframe's context and using [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url], safe for scripts like Duyck's one mentioned earlier, or TradingView's [url=https://www.tradingview.com/script/n0f50JKv-Relative-Volume-at-Time/]Relative  Volume  at  Time[/url], which use a user-selected timeframe as an anchor to reset calculations. Calculations made at the chart's timeframe by varying the period of MAs or other rolling window calculations should be called "multi-period", and "MTF-anchored" could be used for scripts that reset calculations on timeframe boundaries.

[b]Colophon[/b]
Our script was written using the [url=http://www.pinecoders.com/coding_conventions/]PineCoders Coding Conventions for Pine[/url].
The description was formatted using the techniques explained in the [url=https://www.tradingview.com/chart/SSP/aOYEvBxw-How-We-Write-and-Format-Script-Descriptions/]How We Write and Format Script Descriptions[/url] PineCoders publication.
Snippets were lifted from our [url=https://www.tradingview.com/script/90mqACUV-MTF-Selection-Framework-PineCoders-FAQ/]MTF Selection Framework[/url], then massaged to create the `f_tfReminderAndErrorCheck()` function.


█ [b]THANKS[/b]

Thanks to [url=https://www.tradingview.com/u/apozdnyakov/#published-scripts]apozdnyakov[/url] for his help with the innards of [url=https://www.tradingview.com/pine-script-reference/v4/#fun_security]security()[/url].
Thanks to [url=https://www.tradingview.com/u/bmistiaen/#published-charts]bmistiaen[/url] for proofreading our description.



[url=https://www.tradingview.com/athletes/]Look first. Then leap.[/url]

## Source Code

````pine
// REUSING THIS CODE: You are welcome to reuse this code without permission, including in closed-source publications. Credits are always appreciated.

//@version=4
//@author=LucF, for PineCoders
// PineCoders, Tools and ideas for all Pine coders: pinecoders.com

// `security()` revisited [PineCoders]
//  v2, 2021.06.10 18:18 — LucF

// This script provides:
//  - The `f_security()` function to make reliable, repainting/non-repainting `security()` calls.
//  - A technique to achieve the same functionality for functions returning tuples, when they must be used with `security()`.
//  - The `f_tfReminderAndErrorCheck()` function to validate the chart's TF and display a reminder of the HTF.

// This code was written using:
//  • PineCoders Coding Conventions for Pine: http://www.pinecoders.com/coding_conventions/



study("`security()` revisited [PineCoders]", "", true)

var string ON  = "On"
var string OFF = "Off"

bool   i_repaint   = input(OFF,   "Repaint",                 options = [ON, OFF]) == ON
float  i_source    = input(close, "Source")
string i_timeframe = input("1",   "Timeframe",               type = input.resolution)
bool   i_reminder  = input(ON,    "Show timeframe reminder", options = [ON, OFF]) == ON

var string ticker = syminfo.tickerid
plotchar(na, "══════════ PLOTS",  "", location.top)

// ————— YELLOW (Reference): Repaint-only, simple `security()` call.
//          - Historical plots do not represent realtime behavior accurately.
//          - In realtime, values other than `open` will update continuously and can vary significantly from EOD values.
c0 = security(ticker, i_timeframe, i_source)
plot(c0, "c0: 🔨 Repainting `security()` call", color.yellow, 20)

// ————— SILVER (BEST): Uses only one `security()` call but allows repainting control.
//          - Cannot be used when the source is a tuple-returning function (use the following method then).
//          The first three parameters are the same as those of `security()`. 
//          The last one: `_rep`, must be a boolean (true/false) value. It indicates if you want repainting (true) or not (false).
//▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼▼
f_security(_sym, _res, _src, _rep) => security(_sym, _res, _src[not _rep and barstate.isrealtime ? 1 : 0])[_rep or barstate.isrealtime ? 0 : 1]
//▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
c1 = f_security(ticker, i_timeframe, i_source, i_repaint)
plot(c1, "c1: 👍 `f_security()`", color.silver, 14)

// ————— SILVER (BEST for tuples): Technique providing the functional equivalent of `f_security()` for use with functions returning a tuple.
f_oc(_offset) => 
    // int _offset: the first half of the offset calcs required to achieve repainting/non-repainting.
    //              The second half will be handled post `security()` call, by indexing the received tuple values in a variable reassignment.
    _o = open
    _c = close
    [_o[_offset], _c[_offset]]
[o_, c_] = security(ticker, i_timeframe, f_oc(not i_repaint and barstate.isrealtime ? 1 : 0))
o = o_[i_repaint or barstate.isrealtime ? 0 : 1]
c = c_[i_repaint or barstate.isrealtime ? 0 : 1]
c2 = c
plot(c2, "c2: 👍 Tuple form", color.fuchsia, 8)

// ————— WHITE (OK): Classic two-call version with repainting control.
f_secureSecurity(_symbol, _res, _src) => security(_symbol, _res, _src[1], lookahead = barmerge.lookahead_on)
c3 = i_repaint ? security(ticker, i_timeframe, i_source) : f_secureSecurity(ticker, i_timeframe, i_source)
plot(c3, "c3: 🆗 Two-call form", color.white, 4)

// ————— BLACK (BAD): DO NOT USE THESE. They are two inadequate compromises showing misleading behavioral disparities between historical and realtime bars.
c4 = security(ticker, i_timeframe, i_source[not i_repaint and barstate.isrealtime ? 1 : 0])
plot(c4, "c4: 👎 Dysfunctional ersatz", color.black, 2)
c5 = security(ticker, i_timeframe, i_source)[not i_repaint and barstate.isrealtime ? 1 : 0]
plot(c5, "c5: 👎 Dysfunctional ersatz", na, 1)



// ————— Mark timeframe changes.
bgcolor(change(time(i_timeframe)) ? color.gray : na)
// ————— Value of offsets used in our `f_security()`.
plotchar(na, "══════════ OFFSETS",  "", location.top)
plotchar(not i_repaint and barstate.isrealtime ? 1 : 0, "not i_repaint and barstate.isrealtime ? 1 : 0", "", location.top, size = size.tiny)
plotchar(i_repaint or barstate.isrealtime ? 0 : 1,      "i_repaint or barstate.isrealtime ? 0 : 1",      "", location.top, size = size.tiny)
// ————— Colored bar at the top of the chart.
// plotchar(na, "══════════ BAR STATES",  "", location.top)
// plotchar(barstate.ishistory,  "ishistory",  "█", location.top, color.silver, size = size.normal)
// plotchar(barstate.isrealtime, "isrealtime", "█", location.top, color.green,  size = size.normal)
// plotchar(barstate.isrealtime and barstate.isconfirmed, "isrealtime and isconfirmed", "█", location.top, color.red, size = size.normal)



// ————— Show warning or HTF reminder, if needed.
f_tfReminderAndErrorCheck(_userSelectionOfTf, _tfReminder) =>
    // string _userSelectionOfTf: HTF selected by user.
    // bool   _tfReminder       : `true` when a reminder of the HTF must be displayed.
    
    // Get chart's TF.
    var float _chartTfInMinutes = timeframe.multiplier * (
      timeframe.isseconds ? 1. / 60             :
      timeframe.isminutes ? 1.                  :
      timeframe.isdaily   ? 60. * 24            :
      timeframe.isweekly  ? 60. * 24 * 7        :
      timeframe.ismonthly ? 60. * 24 * 30.4375  : na)
    
    // Get HTF.
    float _htfInMinutes = security(syminfo.tickerid, _userSelectionOfTf, _chartTfInMinutes)
    
    // Label.
    string _txt = ""
    var color _color = na
    if _chartTfInMinutes > _htfInMinutes
        // Chart TF is higher than user-selected TF.
        _txt := "The chart's timeframe\nshould not be greater than " + _userSelectionOfTf
        _color := color.red
    else if _tfReminder
        // Display reminder of HTF.
        _txt := _userSelectionOfTf
        _color := color.silver
    float _y = lowest(50)[1]
    var label _lbl = label.new(bar_index, _y, _txt, xloc.bar_index, yloc.price, #00000000, label.style_label_left, _color, size.large, text.align_left)
    if barstate.islast and _txt != ""
        // Update label.
        label.set_xy(_lbl, bar_index, _y)
        label.set_text(_lbl, _txt)
        label.set_textcolor(_lbl, _color)
    [_chartTfInMinutes, _htfInMinutes]

f_tfReminderAndErrorCheck(i_timeframe, i_reminder)
````
