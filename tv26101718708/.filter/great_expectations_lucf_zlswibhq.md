# Great Expectations [LucF]

- url: https://www.tradingview.com/script/ZLswiBhQ-Great-Expectations-LucF/
- type: indicator
- pine_id: PUB;RNJPPSqdpoWt87AAYknMzanGqkBVc6PJ
- version: 6.0

## Description

Great Expectations helps traders answer the question: What is possible? It is a powerful question, yet exploration of the unknown always entails risk. A more complete set of questions better suited to traders could be:
[i]What opportunity exists from any given point on a chart?[/i]
[i]What portion of this opportunity can be realistically captured?[/i]
[i]What risk will be incurred in trying to do so, and how long will it take?[/i]
Great Expectations is the result of an exploration of these questions. It is a trade simulator that generates visual and quantitative information to help strategy modelers visually identify and analyse areas of optimal expectation on charts, whether they are designing automated or discretionary strategies.

[b]WARNING: Great Expectations is NOT an indicator that helps determine the current state of a market.[/b] It works by looking at points in the past from which the future is already known. It uses one definition of repainting extensively (i.e. it goes back in the past to print information that could not have been know at the time). Repainting understood that way is in fact almost all the indicator does! —albeit for what I hope is a noble cause. The indicator is of no use whatsoever in analyzing markets in real-time. [b]If you do not understand what it does, please stay away![/b]

This is an indicator—not a strategy that uses TradingView’s backtesting engine. It works by simulating trades, not unlike a backtest, but with the crucial difference that it assumes a trade (either long or short) is entered on all bars in the historic sample. It walks forward from each bar and determines possible outcomes, gathering individual trade statistics that in turn generate precious global statistics from all outcomes tested on the chart.

Great Expectations provides numbers summarizing trade results on all simulations run from the chart. Those numbers cannot be compared to backtest-produced numbers since all non-filtered bars are examined, even if an entry was taken on the bar immediately preceding the current one, which never happens in a backtest. This peculiarity does NOT invalidate Great Expectations calculations; it just entails that results be considered under a different light. Provided they are evaluated within the indicator’s context, they can be useful—sometimes even more than backtesting results, e.g. in evaluating the impact of parameter-fitting or variations in entry, exit or filtering strats.

Traders and strategy modelers are creatures of hope often suffering from blurred vision; my hope is that Great Expectations will help them appraise the validity of their setup and strat intuitions in a realistic fashion, preventing confirmation bias from obstructing perspective—and great expectations from turning into financial great deceptions.


[b]USE CASES[/b]
You’ve identified what looks like a promising setup on other indicators. You load Great Expectations on the chart and evaluate if its high-expectation areas match locations where your setup’s conditions occur. Unless today is your lucky day, chances are the indicator will help you realize your setup is not as promising as you had hoped.

You want to get a rough estimate of the optimal trade duration for a chart and you don’t mind using the entry and exit strategies provided with the indicator. You use the trade length readouts of the indicator.

You’re experimenting with a new stop strategy and want to know how long it will keep you in trades, on average. You integrate your stop strategy in the indicator’s code and look at the average trade length it produces and the TST ratio to evaluate its performance.

You have put together your own entry and exit criteria and are looking for a filter that will help you improve backtesting results. You visually ascertain the suitability of your filter by looking at its results on the charts with great Expectations, to see if your filter is choosing its areas correctly.

You have a strategy that shows backtested trades on your chart. Great Expectations can help you evaluate how well your strategy is benefitting from high-opportunity areas while avoiding poor expectation spots.

You want more complete statistics on your set of strategies than what backtesting will provide. You use Great Expectations, knowing that it tests all bars in the sample that correspond to your criteria, as opposed to backtesting results which are limited to a subset of all possible entries.

You want to fool your friends into thinking you’ve designed the holy grail of indicators, something that identifies optimal opportunities on any chart; you show them the P&L cloud.


[b]FEATURES[/b]
[b]For one trade[/b]
At any given point on the chart, assuming a trade is entered there, Great Expectations shows you information specific to that trade simulation both on the chart and in the Data Window.
The chart can display:
[list][*]the P & L Cloud which shows whether the trade ended profitably or not, and by how much,
[*]the Opportunity & Risk Cloud which the maximum opportunity and risk the simulation encountered. When superimposed over the P & L cloud, you will see what I call the [i]managed[/i] opportunity and risk, i.e the portion of maximum opportunity that was captured and the portion of the maximum risk that was incurred,
[*]the target and if it was reached, 
[*]a background that uses a gradient to show different levels of trade length, P&L or how frequently the target was reached during simulation.[/list]
The Data Window displays more than 40 values on individual trades and global results. For any given trade you will know:
[list][*]Entry/Exit levels, including slippage impact,
[*]It’s outcome and duration,
[*]P/L achieved,
 [*]The fraction of the maximum opportunity/risk managed by the trade.[/list]
[b]For all trades[/b]
After going through all the possible trades on the chart, the indicator will provide you with a rare view of all outcomes expressed with the P&L cloud, which allows us to instantly see the most/least profitable areas of a chart using trade data as support, while also showing its relationship with the opportunity/risk encountered during the simulation. The difference between the two clouds is the managed opportunity and risk.
The Data Window will present you with numbers which we will go through later. Some of them are: average stop size, P/L, win rate, % opportunity managed, trade lengths for different types of trade outcomes and the TST (Target:Stop Travel) ratio.
Let’s see Great Expectations in action… and remember to open your Data Window!


[b]INPUTS[/b]
[b]Trade direction[/b]: You must first choose if you wish to look at long or short trades. Because of the way the indicator works and the amount of visual information on the chart, it is only practical to look at one type of trades at a time. The default is Longs.
[b]Maximum trade Length (MaxL)[/b]: This is the maximum walk forward distance the simulator will go in analyzing outcomes from any given point in the past. It also determines the size of the dead zone among the chart’s last bars. A red background line identifies the beginning of the dead zone for which not enough bars have elapsed to analyze outcomes for the maximum trade length defined. If an ATR-based entry stop is used, that length is added to the wait time before beginning simulations, so that the first entry starts with a clean ATR value. On a sample of around 16000 bars, my tests show that the indicator runs into server errors at lengths of around 290, i.e. having completed ~4,6M simulation loop iterations. That is way too high a length anyways; 100 will usually be amply enough to ring out all the possibilities out of a simulation, and on shorter time frames, 30 can be enough. While making it unduly small will prevent simulations of expressing the market’s potential, the less you use, the faster the indicator will run. The default is 40.
[b]Unrealized P&L base at End of Trade (EOT)[/b]: When a simulation ends and the trade is still open, we calculate unrealized P&L from an exit order executed from either the last in-trade stop on the previous bar, or the close of the last bar. You can readily see the impact of this selection on the chart, with the P&L cloud. The default is on the close.

[b]Display[/b]: The check box besides the title does nothing.
[b]Show target[/b]: Shows a green line displaying the trade’s target expressed as a multiple of X, i.e. the amplitude of the entry stop. [b]I call this value “X” and use it as a unit to express profit and loss on a trade[/b] (some call it “R”). The line is highlighted for trades where the close reached the target during the trade, whether the trade ended in profit or loss. This is also where you specify the multiple of X you wish to use in calculating targets. The multiple is used even if targets are not displayed.
[b]Show P&L Cloud[/b]: The cloud allows traders to see right away the profitable areas of the chart. The only line printed with the cloud is the “end of trade line” (EOT). The EOT line is the only way one can see the level where a trade ended on the chart (in the Data Window you can see it as the “Exit Fill” value). The EOT level for the trade determines if the trade ended in a profit or a loss. Its value represents one of the following:
- fill from order executed at close of bar where stop is breached during trade (which produces “Realized P/L”),
- simulation of a fill pseudo-fill at the user-defined EOT level (last close or stop level) if the trade runs its course through MaxL bars without getting stopped (producing Unrealized P/L).
The EOT line and the cloud fill print in green when the trade’s outcome is profitable and in red when it is not. If the trade was closed after breaching the stop, the line appears brighter.
 [b]Show Opportunity&Risk Cloud[/b]: Displays the maximum opportunity/risk that was present during the trade, i.e. the maximum and minimum prices reached.
[b]Background Color Scheme[/b]: Allows you to choose between 3 different color schemes for the background gradients, to accommodate different types of chart background/candles. Select “None” if you don’t want a background.
[b]Background source[/b]: Determines what value will be used to generate the different intensities of the gradient. You can choose trade length (brighter is shorter), Trade P&L (brighter is higher) or the number of times the target was reached during simulation (brighter is higher). The default is Trade Length.

[b]Entry strat[/b]: The check box besides the title does nothing. The default strat is All bars, meaning a trade will be simulated from all bars not excluded by the filters where a MaxL bars future exists. For fun, I’ve included a pseudo-random entry strat (an indirect way of changing the seed is to vary the starting date of the simulation). 

[b]Show Filter State[/b]: Displays areas where the combination of filters you have selected are allowing entries. Filtering occurs as per your selection(s), whether the state is displayed or not. The effect of multiple selections is additive. The filters are:
1. Bar direction: Longs will only be entered if close>open and vice versa.
2. Rising Volume: Applies to both long and shorts.
3. Rising/falling MA of the length you choose over the number of bars you choose.
4. Custom indicator: You can feed your own filtering signal through this from another indicator. It must produce a signal of 1 to allow long entries and 0 to allow shorts.

[b]Show Entry Stops[/b]:
1. Multiple of user-defined length ATR.
2. Fixed percentage.
3. Fixed value.
All entry stops are calculated using the entry fill price as a reference. The fill price is calculated from the current bar’s open, to which slippage is added if configured. This simulates the case where the strategy issued the entry signal on the previous bar for it to be executed at the next bar’s open.
The entry stop remains active until the in-trade stop becomes the more aggressive of the two stops. From then on, the entry stop will be ignored, unless a bar close breaches the in-trade stop, in which case the stop will be reset with a new entry stop and the process repeats.

[b]Show In-trade stops[/b]: Displays in bright red the selected in-trade stop (be sure to read the note in this section about them).
1. ATR multiple: added/subtracted from the average of the two previous bars minimum/maximum of open/close.
2. A trailing stop with a deviation expressed as a multiple of entry stop (X).
3. A fixed percentage trailing stop.
Trailing stops deviations are measured from the highest/lowest high/low reached during the trade.
Note: There is a twist with the in-trade stops. It’s that for any given bar, its in-trade stop can hold multiple values, as each successive pass of the advancing simulation loops goes over it from a different entry points. What is printed is the stop from the loop that ended on that bar, which may have nothing to do with other instances of the trade’s in-trade stop for the same bar when visited from other starting points in previous simulations. There is just no practical way to print all stop values that were used for any given bar. While the printed entry stops are the actual ones used on each bar, the in-trade stops shown are merely the last instance used among many.

[b]Include Slippage[/b]: if checked, slippage will be added/subtracted from order price to yield the fill price. Slippage is in percentage. If you choose to include slippage in the simulations, remember to adjust it by considering the liquidity of the markets and the time frame you’ll be analyzing.

[b]Include Fees[/b]: if checked, fees will be subtracted/added to both realized an unrealized trade profits/losses. Fees are in percentage. The default fees work well for crypto markets but will need adjusting for others—especially in Forex. Remember to modify them accordingly as they can have a major impact on results. Both fees and slippage are included to remind us of their importance, even if the global numbers produced by the indicator are not representative of a real trading scenario composed of sequential trades.

[b]Date Range filtering[/b]: the usual. Just note that the checkbox [b]has[/b] to be selected for date filtering to activate.


[b]DATA WINDOW[/b]
Most of the information produced by this indicator is made available in the Data Window, which you bring up by using the icon below the Watchlist and Alerts buttons at the right of the TV UI. Here’s what’s there.
Some of the information presented in the Data Window is standard trade data; other values are not so standard; e. g. the notions of managed opportunity and risk and Target:Stop Travel ratio. The interplay between all the values provided by Great Expectations is inherently complex, even for a static set of entry/filter/exit strats. During the constant updating which the habitual process of progressive refinement in building strategies that is the lot of strategy modelers entails, another level of complexity is no doubt added to the analysis of this indicator’s values. While I don’t want to sound like Wolfram presenting [i]A New Kind of Science[/i], I do believe that if you are a serious strategy modeler and spend the time required to get used to using all the information this indicator makes available, you may find it useful.


[b]Trade Information[/b]

[b]Entry Order[/b]: This is the open of the bar where simulation starts. We suppose that an entry signal was generated at the previous bar.
[b]Entry Fill (including slip.)[/b]: The actual entry price, including slippage. This is the base price from which other values will be calculated.
[b]Exit Order[/b]: When a stop is breached, an exit order is executed from the close of the bar that breached the stop. While there is no “In-trade stop” value included in the Data Window (other than the End of trade Stop previously discussed), this “Exit Order” value is how we can know the level where the trade was stopped during the simulation. The “Trade Length” value will then show the bar where the stop was breached.
[b]Exit Fill (including slip.)[/b]: When the exit order is simulated, slippage is added to the order level to create the fill.
[b]Chart: Target[/b]: This is the target calculated at the beginning of the simulation. This value also appear on the chart in teal. It is controlled by the multiple of X defined under the “Show Target” checkbox in the Inputs.
[b]Chart: Entry Stop[/b]: This value also appears on the chart (the red dots under points where a trade was simulated). Its value is controlled by the Entry Strat chosen in the Inputs.
[b]X (% Fill, including Fees)[/b] and [b]X (currency)[/b]: This is the stop’s amplitude (Entry Fill – Entry Stop) + Fees. It represents the risk incurred upon entry and will be used to express P&L. We will show R expressed in both a percentage of the Entry Fill level (this value), and currency (the next value). This value represents the risk in the risk:reward ratio and is considered to be a unit of 1 so that RR can be expressed as a single value (i.e. “2” actually meaning “1:2”).
[b]Trade Length[/b]: If trade was stopped, it’s the number of bars elapsed until then. The trade is then considered “Closed”. If the trade ends without being stopped (there is no profit-taking strat implemented, so the stop is the only exit strat), then the trade is “Open”, the length is MaxL and it will show in orange. Otherwise the value will print in green/red to reflect if the trade is winning/losing. 
[b]P&L (X)[/b]: The P&L of the trade, expressed as a multiple of X, which takes into account fees paid at entry and exit. Given our default target setting at 2 units of “X”, a trade that closes at its target will have produced a P&L of +2.0, i.e. twice the value of X (not counting fees paid at exit [remember fees at entry have already been included in X, so they are accounted for]). A trade that gets stopped late 50% further that the entry stop’s level will produce a P&L of -1.5X.
[b]P&L (currency, including Fees)[/b]: same value as above, but expressed in currency.
[b]Target first reached at bar[/b]: If price closed above the target during the trade (even if it occurs after the trade was stopped), this will show when. This value will be used in calculating our TST ratio.
[b]Times Stop/Target reached in sim.[/b]: Includes all occurrences during the complete simulation loop.
[b]Opportunity (X)[/b]: The highest/lowest price reached during a simulation, i.e. the maximum opportunity encountered, whether the trade was previously stopped or not, expressed as a multiple of X.
[b]Risk (X)[/b]: The lowest/highest price reached during a simulation, i.e. the maximum risk encountered, whether the trade was previously stopped or not, expressed as a multiple of X.
[b]Risk:Opportunity[/b]: The greater this ratio, the greater Opportunity is, compared to Risk.
[b]Managed Opportunity (%)[/b]: The portion of Opportunity that was captured by the highest/low stop position, even if it occurred after a previous stop closed the trade.
 [b]Managed Risk (%)[/b]: The portion of risk that was protected by the lowest/highest stop position, even if it occurred after a previous stop closed the trade. When this value is greater than 100%, it means the trade’s stop is protecting more than the maximum risk, which is frequent. You will, however, never see close to those values for the Managed Opportunity value, since the stop would have to be higher than the Maximum opportunity. It is much easier to alleviate the risk than it is to lock in profits.
[b]Managed Risk:Opportunity[/b]: The ratio of the two preceding values.
[b] Managed Opp. vs. Risk[/b]: The Managed Opportunity minus the Managed Risk. When it is negative, which is most often is, it means your strat is protecting a greater portion of the risk than it captures opportunity.


[b]Global Numbers[/b]

[b]Win Rate(%)[/b]: Percentage of winning trades over all entries. Open trades are considered winning if their last stop/close (as per user selection) locks in profits.
[b]Avg X%, Avg X (currency)[/b]: Averages of previously described values:.
[b]Avg Profitability/Trade (APPT)[/b]: This measures expectation using: [i]Average Profitability Per Trade = (Probability of Win × Average Win) − (Probability of Loss × Average Loss)[/i]. It quantifies the average expectation/trade, which RR alone can’t do, as the probabilities of each outcome (win/lose) must also be used to calculate expectancy. The APPT combine the RR with the win rate to yield the true expectancy of a strategy. In my usual way of expressing risk with X, APPT is the equivalent of the average P&L per trade expressed in X. An APPT of -1.5 means that we lose on average 1.5X/trade.
[b]Equity (X), Equity (currency)[/b]: The cumulative result of all trade outcomes, expressed as a multiple of X. Multiplied by the Average X in currency, this yields the Equity in currency.
[b]Risk:Opportunity, Managed Risk:Opportunity, Managed Opp. vs. Risk[/b]: The global values of the ones previously described.
[b]Avg Trade Length (TL)[/b]: One of the most important values derived by going through all the simulations. Again, it is composed of either the length of stopped trades, or MaxL when the trade isn’t stopped (open). This value can help systems modelers shape the characteristics of the components they use to build their strategies.
[b]Avg Closed Win TL[/b] and [b]Avg Closed Lose TL[/b]: The average lengths of winning/losing trades that were stopped.
[b]Target reached? Avg bars to Stop[/b] and [b]Target reached? Avg bars to Target[/b]: For the trades where the target was reached at some point in the simulation, the number of bars to the first point where the stop was breached and where the target was reached, respectively. These two values are used to calculate the next value.
[b]TST (Target:Stop Travel Ratio)[/b]: This tracks the ratio between the two preceding values (Bars to first stop/Bars to first target), but only for trades where the target was reached somewhere in the loop. A ratio of 2 means targets are reached twice as fast as stops.
The next values of this section are counts or percentages and are self-explanatory.

[b]Chart Plots[/b]
Contains chart plots of values already describes.

[b]NOTES[/b]
Optimization/Overfitting: There is a fine line between optimizing and overfitting. Tools like this indicator can lead unsuspecting modelers down a path of overfitting that often turns strategies into over-specialized beasts that do not perform elegantly when confronted to the real-world. Proven testing strategies like walk forward analysis will go a long way in helping modelers alleviate this risk.

Input tuning: Because the results generated by the indicator will vary with the parameters used in the active entry, filtering and exit strats, it’s important to realize that although it may be fun at first, just slapping the default settings on a chart and time frame will not yield optimal nor reliable results. While using ATR as often as possible (as I do in this indicator) is a good way to make strat parametrization adaptable, it is not a foolproof solution.

There is no data for the last MaxL bars of the chart, since not enough trade future has elapsed to run a simulation from MaxL bars back.

Modifying the code: I have tried to structure the code modularly, even if that entails a larger code base, so that you can adapt it to your needs. I’ve included a few token components in each of the placeholders designed for entry strategies, filters, entry stops and in-trade stops. This will hopefully make it easier to add your own. In the same spirit, I have also commented liberally.

You will find in the code many instances of standard trade management tasks that can be lifted to code TV strategies where, as I do in mine, you manage everything yourself and don’t rely on built-in Pine strategy functions to act on your trades.

Enjoy!

[b]THANKS[/b]
To @scarf who showed me how [i]plotchar()[/i] could be used to plot values without ruining scale.
To @glaz for the suggestion to include a Chandelier stop strat; I will.
To @simpelyfe for the idea of using an indicator input for the filters (if some day TV lets us use more than one, it will be useful in other modules of the indicator).
To @RicardoSantos for the random generator used in the random entry strat.
To all scripters publishing open source on TradingView; their code is the best way to learn.
To my trading buddies Irving and Bruno; who showed me way back how pro traders get it done.

## Source Code

````pine
//@version=3
//@author=LucF

study("Great Expectations [LucF]", "Great Expectations", overlay=true)

// Great Expectations [LucF]
//  v1.4, 2019.05.03

// WARNING: This is NOT an indicator to help trade in real-time.
//          It is an R&D tool. If you don't understand what it does, PLEASE STAY AWAY.

// NOTE:    Great Expectations relies heavily on the Data Window to show information that cannot be displayed on the chart.

// Intended audience:
//      - automated strategy modelers,
//      - discretionary traders modeling setups,
//      - other traders just wanting to train their eye to what areas with positive expectancy
//        look like on a chart——and how few there are.

// Great Expectations is a trade simulator to help:
//      - identify and evaluate areas of optimal expectation,
//      - visually corroborate indicator setups,
//      - rigourously evaluate the potential of the totality of a historical sample,
//      - if you integrate your entry, filtering, stop or exit strats in the indicator,
//        evaluate and fine-tune them on a complete historical set.

// I've tried to design the indicator to make it easier to personalize.
// Comments are on the verbose side for that purpose.

// Documentation: https://www.tradingview.com/script/ZLswiBhQ-Great-Expectations-LucF/
// My scripts: https://www.tradingview.com/u/LucF/#published-scripts
// The most active community of Pine scripters on the Planet: https://t.me/pinescripters



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// —————————————————————————————————————— Inputs and state definitions ————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————— Colors
MyGreenRaw = color(#00FF00,0),      MyGreenMedium = color(#00FF00,50),      MyGreenSemiDark = color(#00FF00,65),    MyGreenDark = color(#00FF00,75),    MyGreenDarkDark = color(#00FF00,91)
MyRedRaw = color(#FF0000,0),        MyRedMedium = color(#FF0000,30),        MyRedSemiDark = color(#FF0000,55),      MyRedDark = color(#FF0000,75),      MyRedDarkDark = color(#FF0000,87)
MyTealRaw = color(teal,0),          MyTealMedium = color(teal,50)
// ————— Option list statics.
PL1 = "Stop",                   PL2 = "Close"
ET1 = "1. All Bars",            ET2 = "2. Random"
ES1 = "1. ATR Multiple",        ES2 = "2. Fixed %",         ES3 = "3. Fixed Value"
IS1 = "1. ATR",                 IS2 = "2. Mult. of X",      IS3 = "3. Fixed % TS"
BG1 = "1. Green",               BG2 = "2. Orange",          BG3 = "3. Blue",                BG4 = "4. None"
BS1 = "Trade Length",           BS2 = "Trade P and L",      BS3 = "Times Target Reached",   BS4 = "Trade Direction"
SL1 = "None",                   SL2 = "Percentage",         SL3 = "Fixed Value"
FE1 = "None",                   FE2 = "Percentage",         FE3 = "Fixed Value"
// ————— General choices
MaxL = input(40, "Maximum trade length", minval=2)
UnrealizedPLType = input(PL2, "Unrealized P&L base at End of Trade (EOT)", options=[PL1, PL2])
UnrealizedPLStop = UnrealizedPLType==PL1
// ————— Chart Display
_ds = input(true, "═════════ Display")
ShowTarget = input(false, "Show Target")
TargetRR = input(2.0, "... Target Risk:Reward ratio", minval=0.1, step=0.1)
ShowPL = input(true, "Show P&L Cloud")
ShowOR = input(true, "Show Opportunity&Risk Cloud")
BgScheme = input(BG3, "Background color scheme", options=[BG1, BG2, BG3, BG4])
BgSchemeIndex = BgScheme==BG1? 1:BgScheme==BG2? 2:BgScheme==BG3? 3:0
BgSource = input(BS1, "Background source", options=[BS1, BS2, BS3, BS4])
BgSource1 = BgSource==BS1
BgSource2 = BgSource==BS2
BgSource3 = BgSource==BS3
BgSource4 = BgSource==BS4
// ————— Entry Strats
EntryStrat = input(true, "═════════ Entry Strat")
EntryStratType1 = input(false, "1. All Longs")
EntryStratType2 = input(false, "2. All Shorts")
EntryStratType3 = input(true, "3. Rising/Falling MA")
EntryStratType3Len = input(20, "... Length", minval=2)
EntryStratType3Bars = input(1, "... For n Bars", minval=1)
EntryStratType4 = input(false, "4. Random")
EntryStratType4Freq = input(10.0, "... Frequency (approx. 1/n bars)", minval=2, step=4)
EntryStratType5 = input(false, "5. ADX")
EntryStratType5DILength = input(14, "... DI Length", minval=2)
EntryStratType5Smooth = input(14, "... ADX Smoothing", minval=2)
EntryStratType5Threshold = input(20, "... Threshold", minval=0)
// ————— Filters
ShowFilter = input(false, "═════════ Show Filter State")
FilterType1 = input(false, "1. Bar direction=Trade direction")
FilterType2 = input(false, "2. Rising Volume")
FilterType3 = input(false, "3. Rising/Falling MA")
FilterType3Len = input(50, "... Length", minval=2)
FilterType3Bars = input(1, "... For n Bars", minval=1)
FilterType4 = input(false, "4. Custom Indicator")
FilterType4Src = input(close, "... Source (Bull=1, Bear=0)")
FilterType5 = input(false, "5. Random")
FilterType5Freq = input(10.0, "... Frequency (approx. 1/n bars)", minval=2, step=4)
FilterType6 = input(false, "6. Longs Only")
FilterType7 = input(false, "7. Shorts Only")
// ————— Entry stops
ShowEntryStop = input(false, "═════════ Show Entry Stops")
EntryStopType = input(ES1, "Entry Stop Selection", options=[ES1, ES2, ES3])
EntryStopType1Mult = input(1.25, "1. ATR multiple", minval=0.05, step=0.05)
EntryStopType1Len = input(14, "... Length", minval=2)
EntryStopType2Pct = input(3.0, "2. Fixed %", minval=0.0001, step=0.1)
EntryStopType3Val = input(0.0018, "3. Fixed Value", minval=0.00000001, step=0.0001)
EntryStopType1 = EntryStopType==ES1
EntryStopType2 = EntryStopType==ES2
EntryStopType3 = EntryStopType==ES3
// ————— In-trade stops
ShowTradeStop = input(false, "═════════ Show In-Trade Stops")
InTradeStopType = input(IS1, "In-trade Stop Selection", options=[IS1, IS2, IS3])
InTradeStopType1Mult = input(2.0, "1. ATR multiple", minval=0.05, step=0.05)
InTradeStopType2Mult = input(1.0, "2. Multiple of Entry stop (trailing)", minval=0.001, step=0.1)
InTradeStopType3Pct = input(2.0, "3. Fixed percent (trailing)", minval=0.001, step=0.1)
InTradeStopType1 = InTradeStopType==IS1
InTradeStopType2 = InTradeStopType==IS2
InTradeStopType3 = InTradeStopType==IS3
// ————— Slippage
SlippageType = input(SL1, "═════════ Slippage", options=[SL1, SL2, SL3])
SlippageType2InPct = input(0.25, "% Slippage on Entry", minval=0.0, step=0.1)
SlippageType2OutPct = input(0.25, "% Slippage on Exit", minval=0.0, step=0.1)
SlippageType3InVal = input(0.0001, "Fixed Slippage on Entry", minval=0.0, step=0.0001)
SlippageType3OutVal = input(0.0001, "Fixed Slippage on Exit", minval=0.0, step=0.0001)
SlippageType2 = SlippageType==SL2
SlippageType3 = SlippageType==SL3
// ————— Fees
FeesType = input(FE1, "═════════ Fees", options=[FE1, FE2, FE3])
FeesType2InPct = input(0.075, "% Fees on Entry", minval=0.0, step=0.1)
FeesType2OutPct = input(0.075, "% Fees on Exit", minval=0.0, step=0.1)
FeesType3InVal = input(0.0001, "Fixed Fees on Entry", minval=0.0, step=0.0001)
FeesType3OutVal = input(0.0001, "Fixed Fees on Exit", minval=0.0, step=0.0001)
FeesType2 = FeesType==SL2
FeesType3 = FeesType==SL3
// ————— Date range filtering
DateFilter = input(false, "═════════ Date Range Filtering")
FromYear = input(1900, "From Year", minval=1900),   FromMonth = input(1, "From Month", minval=1, maxval=12),    FromDay = input(1, "From Day", minval=1, maxval=31)
ToYear = input(2999, "To Year", minval=1900),       ToMonth = input(1, "To Month", minval=1, maxval=12),        ToDay = input(1, "To Day", minval=1, maxval=31)
FromDate = timestamp(FromYear, FromMonth, FromDay, 00, 00),     ToDate = timestamp(ToYear, ToMonth, ToDay, 23, 59)
TradeDateIsAllowed() => DateFilter? (time >= FromDate and time <= ToDate) : true



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// —————————————————————————————————————— Indicators and Functions ————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// All the generic stuff we're going to need later to make decisions on entries and filters.
// 

// ———————————————————— MA for Entry Strat 3
EntryStrat3Ma = nz(sma(close,EntryStratType3Len))

// ———————————————————— ADX for Entry Strat 5
TrueRange = max(max(high-low, abs(high-nz(close[1]))), abs(low-nz(close[1])))
DirectionalMovementPlus = high-nz(high[1]) > nz(low[1])-low ? max(high-nz(high[1]), 0): 0
DirectionalMovementMinus = nz(low[1])-low > high-nz(high[1]) ? max(nz(low[1])-low, 0): 0
SmoothedTrueRange = tr
SmoothedTrueRange := nz(SmoothedTrueRange[1]) - (nz(SmoothedTrueRange[1])/EntryStratType5DILength) + TrueRange
SmoothedDirectionalMovementPlus = high
SmoothedDirectionalMovementPlus := nz(SmoothedDirectionalMovementPlus[1]) - (nz(SmoothedDirectionalMovementPlus[1])/EntryStratType5DILength) + DirectionalMovementPlus
SmoothedDirectionalMovementMinus = low
SmoothedDirectionalMovementMinus := nz(SmoothedDirectionalMovementMinus[1]) - (nz(SmoothedDirectionalMovementMinus[1])/EntryStratType5DILength) + DirectionalMovementMinus
DIPlus = SmoothedDirectionalMovementPlus / SmoothedTrueRange * 100
DIMinus = SmoothedDirectionalMovementMinus / SmoothedTrueRange * 100
DX = abs(DIPlus-DIMinus) / (DIPlus+DIMinus)*100
ADX = sma(DX, EntryStratType5Smooth)
ADXTrending = ADX>EntryStratType5Threshold
// Notice we need to refer to the starting bar of the simulation to produce the correct signal.
ADXLong = crossover( DIPlus, DIMinus) and ADXTrending
ADXShort = crossover( DIMinus, DIPlus) and ADXTrending

// ———————————————————— MA for Filter 3
Filter3Ma = nz(sma(close,FilterType3Len))

// ———————————————————— ATR for Entry Stop 1
AtrFast = atr(EntryStopType1Len)

// ———————————————————— Function used for Filter 5 (Thx to the King, @RicardoSantos, for the function).
f_pseudo_random_number(_range, _seed)=>
    _return = 1.0
    if na(_seed)
        _return := 3.14159 * nz(_return[1], 1) % n
    else
        _return := 3.14159 * nz(_return[1], 1) % (n + _seed)
    _return := _return % (_range)

// ————————————————————————————————————————
// —————————————— Entry Stop ——————————————
// ————————————————————————————————————————
// ————— Function to calculate an entry stop from an entry fill.
// A function is needed because it must be called during the loop before the trade,
// and when an entry or in-trade stop is taken.
GetEntryStop( _base, _long) =>
    // _base: the base price from which an entry stop is to be calculated.
    // _long: true if entry is generated for a long trade.
    // return value: 
    // Dependencies: AtrFast, MaxL, EntryStopType1, EntryStopType1Mult, EntryStopType2, EntryStopType2Pct, EntryStopType3, EntryStopType3Val

    // ————— Entry Stop 1: ATR*Multiple
    EntryStop1_AtrGap = nz(AtrFast[MaxL])*EntryStopType1Mult
    EntryStop1 = EntryStopType1? _long? _base-EntryStop1_AtrGap : _base+EntryStop1_AtrGap : na
    // ————— Entry Stop 2: Fixed Percent
    EntryStop2 = EntryStopType2? _long? _base*(1.0-(EntryStopType2Pct/100)) : _base*(1.0+(EntryStopType2Pct/100)) : na
    // ————— Entry Stop 3: Fixed value
    EntryStop3 = EntryStopType3? _long? max(_base-EntryStopType3Val,0.0) : _base+EntryStopType3Val : na
    // ————— Select final stop
    // Make sure it's not <0 !
    _EntryStop = max(0.0, EntryStopType1? EntryStop1: EntryStopType2? EntryStop2: EntryStopType3? EntryStop3: 0.0)
    _EntryStop
    
// ————— Function used to increment counters by 1 using test criterion.
OneZero( _test) => 
    _return = _test? 1:0


// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ———————————————————————————————————————————————— Loop Prep  ————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// So here's the plan. A Maximum length of trade has been defined in the inputs: MaxL.
// Until that amount of bars + the ATR length (when ATR is used for entry stop) has elapsed we don't do anything because we need
// those bars as future history for our trade when we go back MaxL bars to run our first simulation,
// which will take us forward into the MaxL already elasped bars ahead of it.

// While we call our loop a trade simulation loop, it doesn't stop when a trade is stopped
// because we are scanning all the MaxL future to gather other information, e.g. how many times the
// target level is reached during the trade.
// Once our trade loop is executed and the outcomes we look for have been determined,
// we do some housekeeping to calculate our numbers for global stats,
// then we print out the indicator's plots, most of which will be printed with a -MaxL offset
// so information appears at the bar atwhere the simulation started.

// ———————————————————— Global stats initializion
// Initialize variables that will hold global statistics, then propagate their values from bar to bar.
// Note that these stats always reflect results MaxL bars back.
// ————— Counts, X, trade lengths
All_UsableBars = 0                              // All bars where an entry is possible, as long as strat conditions allow.
All_UsableBars := nz(All_UsableBars[1])
All_Entries = 0                                 // All bars where an entry was made and the loop was executed.
All_Entries := nz(All_Entries[1])
All_X = 0.0                                     // Sum of all stops in currency.
All_X := nz(All_X[1])
All_XAvg = 0.0                                  // Average of all stops in currency.
All_XAvg := nz(All_XAvg[1])
All_XPct = 0.0                                  // Sum of all stops in percentage.
All_XPct := nz(All_XPct[1])
All_XPctAvg = 0.0                               // Average of all stops in percentage.
All_XPctAvg := nz(All_XPctAvg[1])
All_Winning = 0                                 // Sum of all winning trades.
All_Winning := nz(All_Winning[1])
All_Losing = 0                                  // Sum of all losing trades.
All_Losing := nz(All_Losing[1])
All_Closed = 0                                  // All stopped trades (realized PL can be + or -).
All_Closed := nz(All_Closed[1])
All_ClosedWins = 0                              // Count of closed winning trades.
All_ClosedWins := nz(All_ClosedWins[1])
All_ClosedWinsL = 0                             // Sum of lengths of closed Wins.
All_ClosedWinsL := nz(All_ClosedWinsL[1])
All_ClosedLoseL = 0                             // Sum of lengths of closed Loses.
All_ClosedLoseL := nz(All_ClosedLoseL[1])
All_Open = 0                                    // All trades that ended without being stopped out (unrealized PL can be + or -).
All_Open := nz(All_Open[1])
All_OpenWins = 0                                // Count of open winning trades.
All_OpenWins := nz(All_OpenWins[1])
All_OpenWinsL = 0                               // Sum of lengths of open Wins.
All_OpenWinsL := nz(All_OpenWinsL[1])
All_OpenLoseL = 0                               // Sum of lengths of open Loses.
All_OpenLoseL := nz(All_OpenLoseL[1])
All_TradeLengths = 0                            // Sum of trade lengths.
All_TradeLengths := nz(All_TradeLengths[1])
All_TradeLengthsAvg = 0.0                       // Average of trade lengths.
All_TradeLengthsAvg := nz(All_TradeLengthsAvg[1])
All_LoopIterations = 0                          // Average of all stops in percentage.
All_LoopIterations := nz(All_LoopIterations[1])
// ————— Numbers to calculate Target/Stop Travel ratio (TST).
All_TST_BarsToStop = 0                          // Sum of all TLs of trades that reach target and stop.
All_TST_BarsToStop := nz(All_TST_BarsToStop[1])
All_TST_BarsToStopAvg = 0.0                     // Average of those TLs.
All_TST_BarsToStopAvg := nz(All_TST_BarsToStopAvg[1])
All_TST_BarsToTarget = 0                        // Sum of all TLs of all trades where target was reached, even after first time.
All_TST_BarsToTarget := nz(All_TST_BarsToTarget[1])
All_TST_BarsToTargetAvg = 0.0                   // // Average of those TLs.
All_TST_BarsToTargetAvg := nz(All_TST_BarsToTargetAvg[1])
All_TradesWhereTargetReached = 0                // Sum of trades where target was reached by close during trade (has nothing to do with whether trade finished + or -).
All_TradesWhereTargetReached := nz(All_TradesWhereTargetReached[1])
// ————— P/L numbers
All_PLX = 0.0                                   // Sum of PLX (P&L expressed as mult of X) for all trades.
All_PLX := nz(All_PLX[1])
All_PLXAvg = 0.0                                // Average of PLX trade lengths.
All_PLXAvg := nz(All_PLXAvg[1])
All_RealizedPL = 0.0                            // All realized PL (trade was stopped) in currency.
All_RealizedPL := nz(All_RealizedPL[1])
All_UnrealizedPL = 0.0                          // All unrealized PL (trade was not stopped) in currency.
All_UnrealizedPL := nz(All_UnrealizedPL[1])
All_RealizedProfits = 0.0
All_RealizedProfits := nz(All_RealizedProfits[1])
All_RealizedLosses = 0.0
All_RealizedLosses := nz(All_RealizedLosses[1])
All_UnrealizedProfits = 0.0
All_UnrealizedProfits := nz(All_UnrealizedProfits[1])
All_UnrealizedLosses = 0.0
All_UnrealizedLosses := nz(All_UnrealizedLosses[1])
//// ————— Opportunity/Risk (no propagation required).
All_Opp = 0.0                                   // All Max Opportunity
All_Risk = 0.0                                  // All Max Risk
All_MOpp = 0.0                                  // All Managed Opportunity
All_MRisk = 0.0                                 // All Managed RIsk
All_ManagedOpp = 0.0                            // All Managed Opportunity
All_ManagedRisk = 0.0                           // All Managed RIsk


// ———————————————————— In-Trade stats initialization
// Intialize the trade variables that will be updated in the simulation loop.
// All these values reside in current bar but they are only valid for the bar MaxL bars back where we enter the trade from.
// They will all need to be printed with a -MaxL offset and don't require propagation.

// Direction of Entry
Longs = false
Shorts = false
// Lowest of open/close used 
MinOC = min(open,close)         // Calculated at current bar so will require indexing when used in trade.
MaxOC = max(open,close)
// ————— Trade info
BarsWhereStopReached = 0        // Number of instances where stop was reached for full length of MaxL.
BarsWhereTargetReached = 0      // Number of instances where target was reached for full length of MaxL.
FirstTargetBar = 0              // In-trade bar where target reached for first time.
FirstStoppedBar = 0             // In-Trade bar where stopped out.
EntryOrder = 0.0                // Entry level (order: close of previous bar)
EntryFill = 0.0                 // Entry price taking slippage into account, if required.
EntryStop = 0.0                 // Entry stop.
EntryX = 0.0                    // Entry stop in base currency.
EntryXPct = 0.0                 // Entry stop as % of entry level (Order Fill).
ExitOrder = 0.0                 // Exit level (order).
ExitFill = 0.0                  // Exit price including fees & slippage.
FeesPaidIn = 0.0                // Fees paid on entry.
SlipPaidIn = 0.0                // Slippage incurred on entry.
FeesPaidOut = 0.0               // Fees paid on exit.
SlipPaidOut = 0.0               // Slippage incurred on exit.
TradeStop = 0.0                 // Keeps track of last stop during trade because this one can only be calculated in the simulation loop.
PreviousStop = 0.0              // While in the loop, saves previous bar's stop.
TradeTarget = 0.0               // Trade's target determined on entry.
TradeLength = 0                 // Trade length in bars.
// ————— P&L
RealizedPL = 0.0                // PL in currency after stop taken or at stop level after end of loop (base).
UnrealizedPL = 0.0              // PL in currency guaranteed by stop for non-stopped trades. 
TradePLX = 0.0                  // Trade PL (mult of X), whether closed or open.
WinningTrade = false            // True when PL>0
LosingTrade = false             // True when PL<=0
// ————— Trade states
FilterOK = false                // True when filter conditions are met.
TradeEntered = false            // True if trade is entered (filter and date range allow it).
StopReached = false             // True when bar closes below/above stop, which can happen regardless of trade outcome.
TradeOpen = false               // True if trade is was not stopped out during loop (can be for P or L).
TradeClosed = false             // True if trade is stopped out during loop (can be for P or L).
TargetReached = false           // True when bar closes above/below target (does not stop trade).
// ————— Managed Opportunity/Risk
MinHiLoReached = 0.0            // Min high/low (opportunity) reached during trade, for VolOpp & TS.
MaxHiLoReached = 0.0            // Max high/low (opportunity) reached during trade, for VolOpp & TS.
MaxCloseReached = 0.0           // Highest/Lowest close reached during trade.
MaxStopReached = 0.0            // Max stop reached during trade.
MinStopReached = 0.0            // Min stop reached during trade.
ManagedOpp = 0.0
ManagedRisk = 0.0
Opp = 0.0                       // Max Opportunity
Risk = 0.0                      // Max Risk
MOpp = 0.0                      // Managed Opportunity
MRisk = 0.0                     // Managed RIsk





// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// —————————————————————————————————————————————————— Loop ————————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ———————————————————————————————————————— Start checks to control entry in Trade simulation Loop
// Only enter loop if enough bars have elapsed to build the MaxL future we need to go back in time and run the loop.
if n>MaxL+1+(InTradeStopType1? EntryStopType1Len:0)
    // Update scanned bars count.
    All_UsableBars := All_UsableBars+1

    // ————————————————————————————————————————
    // ———————————— Entry Strats ——————————————
    // ————————————————————————————————————————
    Longs := false
    Shorts := false
    // ————— Entry Strat 1: All Longs
    EnterLong1 = EntryStratType1 and true
    EnterShort1 = EntryStratType1 and false
    // ————— Entry Strat 2: All Shorts
    EnterLong2 = EntryStratType2 and false
    EnterShort2 = EntryStratType2 and true
    // ————— Entry Strat 3: Rising/Falling MA
    EnterLong3 = EntryStratType3 and rising(EntryStrat3Ma[MaxL],EntryStratType3Bars)
    EnterShort3 = EntryStratType3 and falling(EntryStrat3Ma[MaxL],EntryStratType3Bars)
    // ————— Entry Strat 4: Random
    // Enter when generated number's integer part matches 1, which should account for approx. 1/EntryType2Freq occurrences.
    // No need to distinguish between Longs and Shorts here.
    EnterLong4 = EntryStratType4 and round( f_pseudo_random_number(EntryStratType4Freq, 0))==1
    EnterShort4 = EntryStratType4 and round( f_pseudo_random_number(EntryStratType4Freq, 0))==2
    // ————— Entry Strat 5: ADX
    EnterLong5 = EntryStratType5 and ADXLong[MaxL]
    EnterShort5 = EntryStratType5 and ADXShort[MaxL]

    // ————— Assemble entry signals while allowing for only shorts or longs.
    Longs := EnterLong1 or EnterLong2 or EnterLong3 or EnterLong4 or EnterLong5
    Shorts := EnterShort1 or EnterShort2 or EnterShort3 or EnterShort4 or EnterShort5
    // EntrySignalOK = (Longs and not ShortsOnly) or (Shorts and not LongsOnly)
    // EntrySignalOK = Longs or Shorts
    
    
    // ————————————————————————————————————————
    // —————————————— Filters —————————————————
    // ————————————————————————————————————————
    // ————— Filter 1: Bar direction
    Filter1 = FilterType1? Longs? close[MaxL]>open[MaxL] : close[MaxL]<open[MaxL] : true
    // ————— Filter 2: Rising volume
    Filter2 = FilterType2? rising(volume[MaxL],1) : true
    // ————— Filter 3: Rising/Falling MA
    Filter3 = FilterType3? Longs? rising(Filter3Ma[MaxL],FilterType3Bars) : falling(Filter3Ma[MaxL],FilterType3Bars) : true
    // ————— Filter 4: External indicator (thx to @theheirophant via @simpelyfe for the idea)
    // Indicator must supply us with: Bull=1.0, Bear=0.0 (integers work too).
    Filter4 = FilterType4? Longs? nz(FilterType4Src[MaxL])==1.0 : nz(FilterType4Src[MaxL])==0.0 : true
    // ————— Filter 5: Random
    Filter5 = FilterType5? round( f_pseudo_random_number(FilterType5Freq, 0))==1 : true
    // ————— Filter 6: Longs Only
    Filter6 = FilterType6? not Longs? false:true : true
    // ————— Filter 7: Shorts Only
    Filter7 = FilterType7? Longs? false:true : true

    // ————— Assemble filters
    FilterOK := Filter1 and Filter2 and Filter3 and Filter4 and Filter5 and Filter6 and Filter7
    
    // ————— Can we enter a trade? We need an entry signal, a filter confirmation and a valid entry date range.
    TradeEntered := (Longs or Shorts) and FilterOK and TradeDateIsAllowed()[MaxL]
    if TradeEntered
        BarsWhereStopReached := 0
        BarsWhereTargetReached := 0
        StopReached := false
        TradeClosed := false
        TradeStop := 0.0
        PreviousStop := 0.0
        TradeLength := 0
        
        // Before entering loop, initialize trade variables that we only want to have a value if we enter a trade.
        All_Entries := nz(All_Entries[1])+1
        EntryOrder := open[MaxL]
        // Add slippage to entry.
        SlipPaidIn := (SlippageType2? EntryOrder*SlippageType2InPct/100 : SlippageType3? SlippageType3InVal : 0.0)
        // Entry fill price including slippage.
        EntryFill := max(0.0, EntryOrder + (Longs? SlipPaidIn:-SlipPaidIn))
        // Fees are calculated on the execution price that includes slippage. They will later be deducted/added to trade's PL.
        FeesPaidIn := (FeesType2? EntryFill*FeesType2InPct/100 : FeesType3? FeesType3InVal : 0.0)
        // If stop is taken, then ExitOrder gets set to current close, otherwise it will still be 0 at end of loop.
        ExitOrder := 0.0

        // ———————————————————— Entry Stop
        // EntryStop := GetEntryStop( EntryFill).
        EntryStop := GetEntryStop( Longs? low[MaxL]:high[MaxL], Longs)
        
        // ———————————————————— Initialize trade "constants".
        // We have a stop level; can calculate X and with it, our target.
        // X in base currency from fill (includes fees & slippage).
        EntryX := abs(EntryFill-EntryStop)+FeesPaidIn/100
        // X as % of fill.
        EntryXPct := EntryX/EntryFill
        // Determine Target using multiple of entry stop added to fill.
        TradeTarget := Longs? EntryFill * (1+EntryXPct*TargetRR) : max(0.0, EntryFill * (1-EntryXPct*TargetRR))

        // Init Opp/Risk extremes
        MaxHiLoReached := EntryFill
        MinHiLoReached := EntryFill
        MaxCloseReached := EntryFill
        MaxStopReached := EntryStop
        MinStopReached := EntryStop
        
        // ———————————————————————————————————————— 
        // ▼▼▼▼▼▼▼▼▼▼▼▼▼▼ Loop Entry ▼▼▼▼▼▼▼▼▼▼▼▼▼▼
        // ———————————————————————————————————————— 
        // At this point we start MaxL bars back and run through a trade from there.
        // We will be recording if the stop is hit or the target reached,
        // but in any case the loop has to run its course so we can gather all the data we need for stats.
        // We will be calculating stop from within the loop, as we move along ahead,
        // because trailing stops require a known entry point and the specific trade's price action,
        // so they can't be calculated from script's global section.
        for i=MaxL to 1
            All_LoopIterations := All_LoopIterations+1
            // Has a new high/low been reached? Will be used in calculating trailing stops and Max Opportunity.
            MaxHiLoReached := Longs and high[i]>MaxHiLoReached? high[i] : Shorts and low[i]<MaxHiLoReached? low[i] : MaxHiLoReached
            MinHiLoReached := Longs and low[i]<MinHiLoReached? low[i] : Shorts and high[i]>MinHiLoReached? high[i] : MinHiLoReached
            MaxCloseReached := Longs and close[i]>MaxCloseReached? close[i] : Shorts and close[i]<MaxCloseReached? close[i] : MaxCloseReached

            // ———————————————————— Calculate in-trade stop
            // We're now calculating the stop against which close will be compared at the loop's next iteration.
            // These are the trade stops that we can't print on the chart; we'll only be printing the last.
            // Before, save stop previously calculated.
            PreviousStop := TradeStop
            if i==MaxL
                // For the trade's 1st bar only, the entry stop becomes the active stop.
                TradeStop := EntryStop
                PreviousStop := EntryStop
            else
                // For all other bars than the 1st, calculate a new stop.
                if InTradeStopType1
                    // ———————————————————— Stop 1: ATR stop
                    // Calculated using average of 2 preceeding MinOC - ATR*Multiple
                    TradeStop := (Longs? avg(MinOC[i+1], MinOC[i+2]) : avg(MaxOC[i+1], MaxOC[i+2])) + ((AtrFast[i]*InTradeStopType1Mult)*(Longs?-1:1))
                else
                    // ———————————————————— Stop 2: Trailing stop using multiple of X% as max deviation
                    if InTradeStopType2
                        TradeStop := MaxHiLoReached * (Longs? (1-EntryXPct*InTradeStopType2Mult) : (1+EntryXPct*InTradeStopType2Mult))
                    else
                        // ———————————————————— Stop 3: Trailing stop using fixed percentage as max deviation
                        if InTradeStopType3
                            TradeStop := MaxHiLoReached * (Longs? (1-InTradeStopType3Pct/100) : (1+InTradeStopType3Pct/100))
            // Our potential new stop value is determined. Only use it as new one if it moved in trade direction.
            TradeStop := max(0.0, Longs? max(TradeStop,PreviousStop) : min(TradeStop,PreviousStop))
            // Save max stop reached for Managed Opp/Risk.
            MaxStopReached := ((Longs and TradeStop>MaxStopReached) or (Shorts and TradeStop<MaxStopReached)? TradeStop : MaxStopReached)
            MinStopReached := ((Longs and TradeStop<MinStopReached) or (Shorts and TradeStop>MinStopReached)? TradeStop : MinStopReached)
            
            // After first bar has passed, check if target was reached (for stats). Can occur multiple times during loop.
            TargetReached := Longs? close[i]>TradeTarget : close[i]<TradeTarget
            if TargetReached
                // Record bar number from start of trade where target was first reached.
                FirstTargetBar := FirstTargetBar==0? MaxL-i : FirstTargetBar
                // Increase qty of hits.
                BarsWhereTargetReached := BarsWhereTargetReached+1

            // After first bar has passed, check if stop reached. Can occur multiple times during loop.
            StopReached := i!=MaxL? Longs? close[i]<PreviousStop : close[i]>PreviousStop : false
            if StopReached
                if BarsWhereStopReached==0
                    // Stop taken for 1st time during trade;
                    // Record bar number from start of trade where stop reached.
                    FirstStoppedBar := MaxL-i
                    // Save summary closing info. Simulation loop will continue;
                    // we'll complete numbers once out of the loop.
                    TradeClosed := true
                    ExitOrder := close[i]
                // Count all bars where stop was hit.
                BarsWhereStopReached := BarsWhereStopReached+1
                // Reset stop to a new entry stop to move it lower.
                TradeStop := GetEntryStop( Longs?low[i]:high[i], Longs)
        // ————————————————————————————————————————
        // ▲▲▲▲▲▲▲▲▲▲▲▲▲ Loop Exit ▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲▲
        // ————————————————————————————————————————
                

        // ———————————————————— Loop done; finish up by finalizing trade stats
        // Trade results. We distinguish between realized P/L (stop taken) and unrealized P/L when loop ends and stop wasn't taken.
        // If ExitOrder is still zero it means trade is still open, set it so we can calculate PL at either
        // current stop or close, depending on user EOT selection.
        ExitOrder := ExitOrder==0.0? (UnrealizedPLStop? TradeStop:close[1]) : ExitOrder
        // Calculate slippage from stop.
        SlipPaidOut := (SlippageType2? ExitOrder*SlippageType2OutPct/100 : SlippageType3? SlippageType3OutVal : 0.0)
        // Calculate Exit Fill including slipppage.
        ExitFill := max(0.0, ExitOrder + (Longs? -SlipPaidOut:SlipPaidOut))
        // Fees are calculated on the execution price that includes slippage.
        FeesPaidOut := (FeesType2? ExitFill*FeesType2OutPct/100 : FeesType3? FeesType3OutVal : 0.0)
        if TradeClosed
            // Trade was closed. Calculate PL - (Fees at entry and exit).
            RealizedPL := (((ExitFill-EntryFill)*(Longs?1:-1)) - FeesPaidIn - FeesPaidOut)/EntryX
            // Remember trade length.
            TradeLength := FirstStoppedBar
        else
            TradeOpen := true
            // Trade still open; calculate PL - Fees at entry and exit.
            UnrealizedPL := (((ExitFill-EntryFill)*(Longs?1:-1)) - FeesPaidIn - FeesPaidOut)/EntryX
            // Remember trade length.
            TradeLength := MaxL
            
            
        // ———————————————————— Calculate global trade info.
        
        // P&L average.
        TradePLX := (TradeClosed? RealizedPL:UnrealizedPL)
        All_PLX := All_PLX+TradePLX
        All_PLXAvg := All_PLX/All_Entries

        // Win/Lose state.
        WinningTrade := TradePLX>=0.0
        LosingTrade := not WinningTrade     // Yeah yeah, I know; but it's good for readability.

        // X values: update avgs.
        All_X := All_X+EntryX
        All_XAvg := All_X/All_Entries
        All_XPct := All_XPct+EntryXPct
        All_XPctAvg := All_XPct/All_Entries
        
        // ————— Target:Stop Travel ratio
        // These numbers will be used to compare, for all trades that reach target at any point, the time it takes to reach target vs time to reach stop.
        if FirstTargetBar>0
            // Target was reached; update TST numbers
            // Trade where target was reached: update total.
            All_TradesWhereTargetReached := All_TradesWhereTargetReached[1] + 1
            // Sum bars to stop for avg (Stopped length is counted as MaxL if trade still open.).
            All_TST_BarsToStop := All_TST_BarsToStop[1] + TradeLength
            // We can simply use all target reached count since we use TL=MaxL if TradeOpen.
            All_TST_BarsToStopAvg := All_TST_BarsToStop/All_TradesWhereTargetReached
            // Sum bars to target for avg.
            All_TST_BarsToTarget := All_TST_BarsToTarget[1] + FirstTargetBar
            // Avg bars to target.
            All_TST_BarsToTargetAvg := All_TST_BarsToTarget/All_TradesWhereTargetReached

        // Winning/Losing trade totals
        All_Winning := All_Winning[1] + OneZero(WinningTrade)
        All_Losing :=  All_Losing[1] + OneZero(LosingTrade)
        All_Closed := All_Closed[1] + OneZero(TradeClosed)
        All_Open := All_Open[1] + OneZero(TradeOpen)
        ClosedWin = TradeClosed and WinningTrade
        OpenWin = TradeOpen and WinningTrade
        All_ClosedWins := All_ClosedWins[1] + OneZero(ClosedWin)
        All_OpenWins := All_OpenWins[1] + OneZero(OpenWin)

        // Trade lengths: update avg.
        All_TradeLengths := All_TradeLengths+TradeLength
        All_TradeLengthsAvg := All_TradeLengths/All_Entries
        All_ClosedWinsL := All_ClosedWinsL[1] + (TradeClosed and WinningTrade? TradeLength:0)
        All_ClosedLoseL := All_ClosedLoseL[1] + (TradeClosed and LosingTrade? TradeLength:0)
        All_OpenWinsL := All_OpenWinsL[1] + (TradeOpen and WinningTrade? TradeLength:0)
        All_OpenLoseL := All_OpenLoseL[1] + (TradeOpen and LosingTrade? TradeLength:0)
        

        // ———————————————————— Calculate global numbers.
        
        // ————— Opportunity & Risk
        // Get maximum opportunity reached during loop and update avg.
        Opp := abs(MaxHiLoReached-EntryFill)/EntryX
        Risk := abs(MinHiLoReached-EntryFill)/EntryX
        // Managed Opp/Risk
        MOppLong = abs(max(EntryFill, MaxStopReached)-EntryFill)
        MOppShort = abs(min(EntryFill, MaxStopReached)-EntryFill)
        MRisk_Long = abs(min(MinStopReached, EntryFill)-EntryFill)
        MRisk_Short = abs(max(MinStopReached, EntryFill)-EntryFill)
        MOpp := (Longs? MOppLong:MOppShort)/EntryX
        MRisk := (Longs? MRisk_Long:MRisk_Short)/EntryX
        ManagedOpp := 100*MOpp/max(Opp,0.000000001)
        ManagedRisk := 100*MRisk/max(Risk,0.000000001)
        // Totals
        All_Opp := cum(Opp)
        All_Risk := cum(Risk)
        All_MOpp := cum(MOpp)
        All_MRisk := cum(MRisk)
        All_ManagedOpp := 100*All_MOpp/max(All_Opp,0.000000001)
        All_ManagedRisk := 100*All_MRisk/max(All_Risk,0.000000001)

        // P&L
        All_RealizedPL := All_RealizedPL[1] + RealizedPL
        All_UnrealizedPL := All_UnrealizedPL[1] + UnrealizedPL
        All_RealizedProfits := All_RealizedProfits[1] + (TradeClosed and WinningTrade? RealizedPL:0.0)
        All_RealizedLosses := All_RealizedLosses[1] + (TradeClosed and LosingTrade? RealizedPL:0.0)
        All_UnrealizedProfits := All_UnrealizedProfits[1] + (TradeOpen and WinningTrade? UnrealizedPL:0.0)
        All_UnrealizedLosses := All_UnrealizedLosses[1] + (TradeOpen and LosingTrade? UnrealizedPL:0.0)



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ——————————————————————————————————————————————————— Plots ——————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————— Colors
// Standout color and another one a bit darker.
AAA = orange
AA2 = #ff6500
// Plus/Minus color
PMC( _val) => _val>=0.0? MyGreenMedium:MyRedMedium
// True/False color
PMB( _val) => _val? MyGreenMedium:MyRedMedium
// Same color as TV dark Theme background color to hide value of titles.
BLK = #171b29
// Aquas
TIC1 = #009a9a
TIC2 = #00cdcd
// Blues
GF1 = #6c9cec
GF2 = #4978e7

// ———————————————————————————————————————— Data Window.
// Indicator values only. No plot on chart. (Thx @scarf for the tip!)
// These plots print the trade info in the past, at the starting point of the simulation loop. 

// ———————————————————— Trade info
plotchar( 0, "══════ Trade Information", char="", color=BLK)
plotchar( EntryOrder,               "Entry Order", char="", color=TIC2, offset=-MaxL)
plotchar( EntryFill,                "Entry Fill (including Slippage)", char="", color=TIC2, offset=-MaxL)
plotchar( ExitOrder,                "Exit Order", char="", color=TIC1, offset=-MaxL)
plotchar( ExitFill,                 "Exit Fill (including Slippage)", char="", color=TIC1, offset=-MaxL)
// These 2 plots also appear on the chart.
plot( ShowTarget and TradeEntered? TradeTarget:na, "Target", color=FirstTargetBar>0?MyTealRaw:MyTealMedium, style=linebr, offset=-MaxL)
plot( ShowEntryStop and TradeEntered? EntryStop:na, "Entry Stop", color=maroon, style=circles, linewidth=2, offset=-MaxL)
plotchar( EntryXPct*100,            "X (% Fill, including Fees)", char="", color=TIC1, offset=-MaxL)
plotchar( EntryX,                   "X (currency)", char="", color=TIC1, offset=-MaxL)
plotchar( TradeLength,              "Trade Length", char="", color=TradeLength==MaxL?AAA:PMC(TradePLX), offset=-MaxL)
plotchar( TradePLX,                 "P&L (X)", char="", color=PMC( TradePLX), offset=-MaxL)
plotchar( TradePLX*EntryX,          "P&L (currency, including Fees)", char="", color=PMC( TradePLX), offset=-MaxL)
plotchar( FirstTargetBar,           "Target first reached at bar", char="", color=TIC1, offset=-MaxL)
plotchar( BarsWhereStopReached,     "Times Stop reached in simulation", char="", color=TIC1, offset=-MaxL)
plotchar( BarsWhereTargetReached,   "Times Target reached in simulation", char="", color=TIC1, offset=-MaxL)
// ————— Opportunity/Risk
plotchar( Opp,                      "Opportunity (X)", char="", color=TIC2, offset=-MaxL)
plotchar( Risk,                     "Risk (X)", char="", color=TIC2, offset=-MaxL)
plotchar( Opp/Risk,                 "Risk:Opportunity", char="", color=AAA, offset=-MaxL)
plotchar( ManagedOpp,               "Managed Opportunity (%)", char="", color=TIC2, offset=-MaxL)
plotchar( ManagedRisk,              "Managed Risk (%)", char="", color=TIC2, offset=-MaxL)
plotchar( ManagedOpp/ManagedRisk,   "Managed Risk:Opportunity", char="", color=TIC2, offset=-MaxL)
plotchar( ManagedOpp-ManagedRisk,   "Managed Opp. vs. Risk", char="", color=AA2, offset=-MaxL)

// ———————————————————— Global numbers
plotchar( 0, "══════ Global Numbers", char="", color=BLK, offset=-MaxL)
plotchar( 100*All_Winning/All_Entries,                          "Win Rate (%)", char="", color=AAA, offset=-MaxL)
plotchar( All_XPctAvg*100,                                      "Avg X (%)", char="", color=AAA, offset=-MaxL)
plotchar( All_XAvg,                                             "Avg X (currency)", char="", color=GF2, offset=-MaxL)
plotchar( All_PLXAvg,                                           "Avg Profitability/Trade (APPT) (X)", char="", color=PMC(All_PLXAvg), offset=-MaxL)
Equity = All_RealizedPL+All_UnrealizedPL
plotchar( Equity,                                               "Equity (X)", char="", color=PMC(Equity), offset=-MaxL)
EquityCurr = (All_RealizedPL+All_UnrealizedPL)*All_XAvg
plotchar( EquityCurr,                                           "Equity (currency)", char="", color=PMC(EquityCurr), offset=-MaxL)
plotchar( All_Opp/All_Risk,                                     "Risk:Opportunity", char="", color=AAA, offset=-MaxL)
plotchar( All_ManagedOpp/All_ManagedRisk,                       "Managed Risk:Opportunity", char="", color=GF2, offset=-MaxL)
plotchar( All_ManagedOpp-All_ManagedRisk,                       "Managed Opp. vs. Risk", char="", color=GF2, offset=-MaxL)

// ————— Global trade information
plotchar( All_TradeLengthsAvg,                                  "Avg Trade Length [TL]", char="", color=AA2, transp=30, offset=-MaxL)
plotchar( round(All_ClosedWinsL/All_ClosedWins),                "Avg Closed Win TL", char="", color=GF1, offset=-MaxL)
plotchar( round(All_ClosedLoseL/(All_Closed-All_ClosedWins)),   "Avg Closed Lose TL", char="", color=GF1, offset=-MaxL)
plotchar( round(All_TST_BarsToStopAvg),                         "Target reached? Avg bars to Stop", char="", color=GF2, offset=-MaxL)
plotchar( round(All_TST_BarsToTargetAvg),                       "Target reached? Avg bars to Target", char="", color=GF2, offset=-MaxL)
plotchar( All_TST_BarsToStopAvg/All_TST_BarsToTargetAvg,        "TST (Target:Stop Travel Ratio)", char="", color=AAA, offset=-MaxL)
// —— Quantities of trades and Percentages Winning/Losing
plotchar( All_UsableBars,                                       "Bars", char="", color=GF1, offset=-MaxL)
plotchar( 100*All_Entries/All_UsableBars,                       "Entries (% of bars)", char="", color=GF1, offset=-MaxL)
plotchar( 100*All_Closed/All_Entries,                           "Closed trades(% of entries)", char="", color=GF2, offset=-MaxL)
plotchar( All_ClosedWins,                                       "Closed Wins", char="", color=GF2, offset=-MaxL)
plotchar( 100*All_ClosedWins/All_Closed,                        "... % of Closed", char="", color=GF2, offset=-MaxL)
plotchar( 100*All_Open/All_Entries,                             "Open trades (% of entries)", char="", color=GF1, offset=-MaxL)
plotchar( All_OpenWins,                                         "Open Wins", char="", color=GF1, offset=-MaxL)
plotchar( 100*All_OpenWins/All_Open,                            "... % of Open", char="", color=GF1, offset=-MaxL)
plotchar( 100*All_TradesWhereTargetReached/All_Entries,         "% that reach Target", char="", color=GF2, offset=-MaxL)

// ———————————————————— Chart plots
plotchar( 0, "══════ Chart plots", char="", color=BLK, offset=-MaxL)
// ————— P&L cloud
_Entry = plot( (ShowPL or ShowOR) and TradeEntered? EntryFill:na,   "Chart: Entry Fill", color=white, transp=100, style=linebr, offset=-MaxL)
_Exit = plot( ShowPL and TradeEntered? ExitFill:na,                 "Chart: End of Trade Price (EOT)", 
  color=Longs? (ExitFill>EntryFill? TradeClosed?MyGreenSemiDark:MyGreenDark:TradeClosed?MyRedSemiDark:MyRedDark) : (ExitFill<EntryFill? TradeClosed?MyGreenSemiDark:MyGreenMedium:TradeClosed?MyRedSemiDark:MyRedDark), style=linebr, offset=-MaxL)
fill( _Entry, _Exit, color=Longs? ExitFill>EntryFill? MyGreenDarkDark:MyRedDarkDark : ExitFill<EntryFill? MyGreenDarkDark:MyRedDarkDark, title="Chart: P/L cloud fill")
// ————— Opportunity/Risk cloud
_Opp = plot( ShowOR and TradeEntered? MaxHiLoReached:na,            "Chart: Max Opportunity", color=white, transp=100, style=linebr, offset=-MaxL)
_Risk = plot( ShowOR and TradeEntered? MinHiLoReached:na,           "Chart: Max Risk", color=white, transp=100, style=linebr, offset=-MaxL)
fill( _Entry, _Opp, color=MyGreenDarkDark, title=                   "Chart: Opportunity cloud fill")
fill( _Entry, _Risk, color=MyRedDarkDark, title=                    "Chart: Risk cloud fill")

// ————— FIlter state 
plotchar(ShowFilter? FilterOK:na, char="•", title="Filter State", color=MyGreenMedium, location=location.top, size=size.tiny, offset=-MaxL)

// ————— Stop (no offset)
// Keep in mind that this only represents the last in-trade stop calculated during the simulation that ended there after MaxL bars.
// It has nothing to do with where the trade was stopped if the stop was hit before MaxL bars where visited. To see that value, you need to look at the "Exit order" value for the trade.
// Since TradeStop does show the last stop of a simulation, it is the level where Unrealized PL are calculated from 
// if the trade ran through MaxL bars without getting stopped and user has chosen to use the stop rather than the close to calculate P&L from.
plot( ShowTradeStop and TradeEntered? TradeStop:na, "Chart: Simulation's last stop", color=MyRedMedium, transp=38, style=circles, linewidth=2)

// ———————————————————— Background Plots
// ————— Function to generate background color gradients
ColorGradient( _src, _min, _max, _scm) =>
    // Scale _src to 0-100 range and choose color from one of 3 schemes.
    //  _src: value to scale
    //  _min: minimum possible value of _src
    //  _max: maximum possible value of _src
    //  _scm: color scheme (0=invisible, 1=greens, 2=oranges, 3=blue)
    //
    // Bind input to min/max
    _src2 = min(_max, max(_src,_min))
    // Handle negative mins by shifting scale.
    _minneg = _min<0
    _min2 = _minneg? 0.0:_min
    _max2 = _minneg? _max+abs(_min):_max
    _src2 := _minneg? _src2+abs(_min):_src
    // Scale 0-100
    _Pct = (_src2-_min2)/_max2*100
    // Transparency for each color scheme (to fine-tune one scheme as a whole)
    _Trs0 = 100, _Trs1 = 70, _Trs2 = 30, _Trs3 = 85
    // Convert 0-100 value into a color.
    _Clr = 
      _Pct<10? _scm==1? color(#08550A, _Trs1) : _scm==2? color(#ffd9a5, _Trs2) : _scm==3? color(#0c585e, _Trs3) : color(white, _Trs0) :
      _Pct<20? _scm==1? color(#095C0B, _Trs1) : _scm==2? color(#ffd294, _Trs2) : _scm==3? color(#0e646b, _Trs3) : color(white, _Trs0) :
      _Pct<30? _scm==1? color(#0A640C, _Trs1) : _scm==2? color(#ffcb84, _Trs2) : _scm==3? color(#0f7078, _Trs3) : color(white, _Trs0) :
      _Pct<40? _scm==1? color(#0B6B0D, _Trs1) : _scm==2? color(#ffc474, _Trs2) : _scm==3? color(#117c84, _Trs3) : color(white, _Trs0) :
      _Pct<50? _scm==1? color(#0C720E, _Trs1) : _scm==2? color(#ffbe63, _Trs2) : _scm==3? color(#128891, _Trs3) : color(white, _Trs0) :
      _Pct<60? _scm==1? color(#0D790F, _Trs1) : _scm==2? color(#ffb752, _Trs2) : _scm==3? color(#14949e, _Trs3) : color(white, _Trs0) :
      _Pct<70? _scm==1? color(#0E8111, _Trs1) : _scm==2? color(#ffb042, _Trs2) : _scm==3? color(#15a0ab, _Trs3) : color(white, _Trs0) :
      _Pct<80? _scm==1? color(#0F8812, _Trs1) : _scm==2? color(#ffa931, _Trs2) : _scm==3? color(#17abb8, _Trs3) : color(white, _Trs0) :
      _Pct<90? _scm==1? color(#108F13, _Trs1) : _scm==2? color(#ffa221, _Trs2) : _scm==3? color(#19b7c5, _Trs3) : color(white, _Trs0) :
      _scm==1? color(#119614, _Trs1) : _scm==2? color(#ff9b11, _Trs2) : _scm==3? color(#1ac3d1, _Trs3) : color(white, _Trs0)
    _Clr

// ————— Background Gradients on RR or TL
bgcolor( 
  BgSource1 and TradeEntered? ColorGradient( MaxL-TradeLength, 0, MaxL, BgSchemeIndex):
  BgSource2 and TradeEntered? ColorGradient( TradePLX, -TargetRR, TargetRR, BgSchemeIndex):
  BgSource3 and TradeEntered? ColorGradient( BarsWhereTargetReached, 0, MaxL, BgSchemeIndex):
  BgSource4 and TradeEntered? Longs? color(green,85):color(maroon,85):
  na, offset=-MaxL, title="Background"
  )

// plotchar( 0, "64 left ——————————", char="", color=BLK)
````
