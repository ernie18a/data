# Backtesting & Trading Engine [PineCoders]

- url: https://www.tradingview.com/script/dYqL95JB-Backtesting-Trading-Engine-PineCoders/
- type: indicator
- pine_id: PUB;P9b8VQ6V7112WDY2Q6VM449BGkj00syi
- version: 5.0

## Description

The PineCoders Backtesting and Trading Engine is a sophisticated framework with hybrid code that can run as a study to generate alerts for automated or discretionary trading while simultaneously providing backtest results. It can also easily be converted to a TradingView strategy in order to run TV backtesting. The Engine comes with many built-in strats for entries, filters, stops and exits, but you can also add you own. 

If, like any self-respecting strategy modeler should, you spend a reasonable amount of time constantly researching new strategies and tinkering, our hope is that the Engine will become your inseparable go-to tool to test the validity of your creations, as once your tests are conclusive, you will be able to run this code as a study to generate the alerts required to put it in real-world use, whether for discretionary trading or to interface with an execution bot/app. You may also find the backtesting results the Engine produces in study mode enough for your needs and spend most of your time there, only occasionally converting to strategy mode in order to backtest using TV backtesting. 

As you will quickly grasp when you bring up this script’s Settings, this is a complex tool. While you will be able to see results very quickly by just putting it on a chart and using its built-in strategies, in order to reap the full benefits of the PineCoders Engine, you will need to invest the time required to understand the subtleties involved in putting all its potential into play. 

Disclaimer: use the Engine at your own risk. 

Before we delve in more detail, here’s a bird’s eye view of the Engine’s features: 
[list]
[*]More than 40 built-in strategies, 
[*]Customizable components, 
[*]Coupling with your own external indicator, 
[*]Simple conversion from Study to Strategy modes, 
[*]Post-Exit analysis to search for alternate trade outcomes, 
[*]Use of the Data Window to show detailed bar by bar trade information and global statistics, including some not provided by TV backtesting, 
[*]Plotting of reminders and generation of alerts on in-trade events.
[/list]
By combining your own strats to the built-in strats supplied with the Engine, and then tuning the numerous options and parameters in the Inputs dialog box, you will be able to play what-if scenarios from an infinite number of permutations. 


[b]USE CASES [/b]
You have written an indicator that provides an entry strat but it’s missing other components like a filter and a stop strategy. You add a plot in your indicator that respects the Engine’s External Signal Protocol, connect it to the Engine by simply selecting your indicator’s plot name in the Engine’s Settings/Inputs and then run tests on different combinations of entry stops, in-trade stops and profit taking strats to find out which one produces the best results with your entry strat. 

You are building a complex strategy that you will want to run as an indicator generating alerts to be sent to a third-party execution bot. You insert your code in the Engine’s modules and leverage its trade management code to quickly move your strategy into production. 

You have many different filters and want to explore results using them separately or in combination. Integrate the filter code in the Engine and run through different permutations or hook up your filtering through the external input and control your filter combos from your indicator. 

You are tweaking the parameters of your entry, filter or stop strat. You integrate it in the Engine and evaluate its performance using the Engine’s statistics. 

You always wondered what results a random entry strat would yield on your markets. You use the Engine’s built-in random entry strat and test it using different combinations of filters, stop and exit strats. 

You want to evaluate the impact of fees and slippage on your strategy. You use the Engine’s inputs to play with different values and get immediate feedback in the detailed numbers provided in the Data Window. 

You just want to inspect the individual trades your strategy generates. You include it in the Engine and then inspect trades visually on your charts, looking at the numbers in the Data Window as you move your cursor around. 

You have never written a production-grade strategy and you want to learn how. Inspect the code in the Engine; you will find essential components typical of what is being used in actual trading systems. 

You have run your system for a while and have compiled actual slippage information and your broker/exchange has updated his fees schedule. You enter the information in the Engine and run it on your markets to see the impact this has on your results. 

[b]FEATURES [/b]
Before going into the detail of the Inputs and the Data Window numbers, here’s a more detailed overview of the Engine’s features. 

[b]Built-in strats [/b]
The engine comes with more than 40 pre-coded strategies for the following standard system components: 
[list]
[*]Entries, 
[*]Filters, 
[*]Entry stops, 
[*]2 stage in-trade stops with kick-in rules, 
[*]Pyramiding rules, 
[*]Hard exits.
[/list]
While some of the filter and stop strats provided may be useful in production-quality systems, you will not devise crazy profit-generating systems using only the entry strats supplied; that part is still up to you, as will be finding the elusive combination of components that makes winning systems. The Engine will, however, provide you with a solid foundation where all the trade management nitty-gritty is handled for you. By binding your custom strats to the Engine, you will be able to build reliable systems of the best quality currently allowed on the TV platform. 

[b]On-chart trade information [/b]
As you move over the bars in a trade, you will see trade numbers in the Data Window change at each bar. The engine calculates the P&L at every bar, including slippage and fees that would be incurred were the trade exited at that bar’s close. If the trade includes pyramided entries, those will be taken into account as well, although for those, final fees and slippage are only calculated at the trade’s exit. 
You can also see on-chart markers for the entry level, stop positions, in-trade special events and entries/exits (you will want to disable these when using the Engine in strategy mode to see TV backtesting results). 

[b]Customization [/b]
You can couple your own strats to the Engine in two ways: 
1. By inserting your own code in the Engine’s different modules. The modular design should enable you to do so with minimal effort by following the instructions in the code. 
2. By linking an external indicator to the engine. After making the proper selections in the engine’s Settings and providing values respecting the engine’s protocol, your external indicator can, when the Engine is used in Indicator mode only: 
[list]
[*]Tell the engine when to enter long or short trades, but let the engine’s in-trade stop and exit strats manage the exits, 
[*]Signal both entries and exits, 
[*]Provide an entry stop along with your entry signal, 
[*]Filter other entry signals generated by any of the engine’s entry strats.
[/list]

[b]Conversion from strategy to study [/b]
TradingView strategies are required to backtest using the TradingView backtesting feature, but if you want to generate alerts with your script, whether for automated trading or just to trigger alerts that you will use in discretionary trading, your code has to run as a study since, for the time being, strategies can’t generate alerts. From hereon we will use indicator as a synonym for study. 
Unless you want to maintain two code bases, you will need hybrid code that easily flips between strategy and indicator modes, and your code will need to restrict its use of strategy() calls and their arguments if it’s going to be able to run both as an indicator and a strategy using the same trade logic. That’s one of the benefits of using this Engine. Once you will have entered your own strats in the Engine, it will be a matter of commenting/uncommenting only four lines of code to flip between indicator and strategy modes in a matter of seconds. 
Additionally, even when running in Indicator mode, the Engine will still provide you with precious numbers on your individual trades and global results, some of which are not available with normal TradingView backtesting. 

[b]Post-Exit Analysis for alternate outcomes (PEA) [/b]
While typical backtesting shows results of trade outcomes, PEA focuses on what could have happened after the exit. The intention is to help traders get an idea of the opportunity/risk in the bars following the trade in order to evaluate if their exit strategies are too aggressive or conservative. 
After a trade is exited, the Engine’s PEA module continues analyzing outcomes for a user-defined quantity of bars. It identifies the maximum opportunity and risk available in that space, and calculates the drawdown required to reach the highest opportunity level post-exit, while recording the number of bars to that point. 
Typically, if you can’t find opportunity greater than 1X past your trade using a few different reasonable lengths of PEA, your strategy is doing pretty good at capturing opportunity. Remember that 100% of opportunity is never capturable. If, however, PEA was finding post-trade maximum opportunity of 3 or 4X with average drawdowns of 0.3 to those areas, this could be a clue revealing your system is exiting trades prematurely. To analyze PEA numbers, you can uncomment complete sets of plots in the Plot module to reveal detailed global and individual PEA numbers. 

[b]Statistics [/b]
The Engine provides stats on your trades that TV backtesting does not provide, such as: 
[list]
[*]Average Profitability Per Trade (APPT), aka statistical expectancy, a crucial value. 
[*]APPT per bar, 
[*]Average stop size, 
[*]Traded volume .
[/list]
It also shows you on a trade-by-trade basis, on-going individual trade results and data. 

[b]In-trade events [/b]
In-trade events can plot reminders and trigger alerts when they occur. The built-in events are: 
[list]
[*]Price approaching stop, 
[*]Possible tops/bottoms, 
[*]Large stop movement (for discretionary trading where stop is moved manually), 
[*]Large price movements.
[/list]

[b]Slippage and Fees [/b]
Even when running in indicator mode, the Engine allows for slippage and fees to be included in the logic and test results. 

[b]Alerts [/b]
The alert creation mechanism allows you to configure alerts on any combination of the normal or pyramided entries, exits and in-trade events. 

[b]Backtesting results [/b]
A few words on the numbers calculated in the Engine. Priority is given to numbers not shown in TV backtesting, as you can readily convert the script to a strategy if you need them. 
We have chosen to focus on numbers expressing results relative to X (the trade’s risk) rather than in absolute currency numbers or in other more conventional but less useful ways. For example, most of the individual trade results are not shown in percentages, as this unit of measure is often less meaningful than those expressed in units of risk (X). A trade that closes with a +25% result, for example, is a poor outcome if it was entered with a -50% stop. Expressed in X, this trade’s P&L becomes 0.5, which provides much better insight into the trade’s outcome. A trade that closes with a P&L of +2X has earned twice the risk incurred upon entry, which would represent a pre-trade risk:reward ratio of 2. 
The way to go about it when you think in X’s and that you adopt the sound risk management policy to risk a fixed percentage of your account on each trade is to equate a currency value to a unit of X. E.g. your account is 10K USD and you decide you will risk a maximum of 1% of it on each trade. That means your unit of X for each trade is worth 100 USD. If your APPT is 2X, this means every time you risk 100 USD in a trade, you can expect to make, on average, 200 USD. 
By presenting results this way, we hope that the Engine’s statistics will appeal to those cognisant of sound risk management strategies, while gently leading traders who aren’t, towards them. 
We trade to turn in tangible profits of course, so at some point currency must come into play. Accordingly, some values such as equity, P&L, slippage and fees are expressed in currency. 
Many of the usual numbers shown in TV backtests are nonetheless available, but they have been commented out in the Engine’s Plot module. 

[b]Position sizing and risk management[/b] 
All good system designers understand that optimal risk management is at the very heart of all winning strategies. The risk in a trade is defined by the fraction of current equity represented by the amplitude of the stop, so in order to manage risk optimally on each trade, position size should adjust to the stop’s amplitude. Systems that enter trades with a fixed stop amplitude can get away with calculating position size as a fixed percentage of current equity. In the context of a test run where equity varies, what represents a fixed amount of risk translates into different currency values. 
Dynamically adjusting position size throughout a system’s life is optimal in many ways. First, as position sizing will vary with current equity, it reproduces a behavioral pattern common to experienced traders, who will dial down risk when confronted to poor performance and increase it when performance improves. Second, limiting risk confers more predictability to statistical test results. Third, position sizing isn’t just about managing risk, it’s also about maximizing opportunity. By using the maximum leverage (no reference to trading on margin here) into the trade that your risk management strategy allows, a dynamic position size allows you to capture maximal opportunity. 
To calculate position sizes using the fixed risk method, we use the following formula: Position = Account * MaxRisk% / Stop%[, which calculates a position size taking into account the trade’s entry stop so that if the trade is stopped out, 100 USD will be lost. For someone who manages risk this way, common instructions to invest a certain percentage of your account in a position are simply worthless, as they do not take into account the risk incurred in the trade. 

The Engine lets you select either the fixed risk or fixed percentage of equity position sizing methods. The closest thing to dynamic position sizing that can currently be done with alerts is to use a bot that allows syntax to specify position size as a percentage of equity which, while being dynamic in the sense that it will adapt to current equity when the trade is entered, does not allow us to modulate position size using the stop’s amplitude. Changes to alerts are on the way which should solve this problem. 
In order for you to simulate performance with the constraint of fixed position sizing, the Engine also offers a third, less preferable option, where position size is defined as a fixed percentage of initial capital so that it is constant throughout the test and will thus represent a varying proportion of current equity. 
Let’s recap. The three position sizing methods the Engine offers are: 
1. By specifying the maximum percentage of risk to incur on your remaining equity, so the Engine will dynamically adjust position size for each trade so that, combining the stop’s amplitude with position size will yield a fixed percentage of risk incurred on current equity, 
2. By specifying a fixed percentage of remaining equity. Note that unless your system has a fixed stop at entry, this method will not provide maximal risk control, as risk will vary with the amplitude of the stop for every trade. This method, as the first, does however have the advantage of automatically adjusting position size to equity. It is the Engine’s default method because it has an equivalent in TV backtesting, so when flipping between indicator and strategy mode, test results will more or less correspond. 
3. By specifying a fixed percentage of the Initial Capital. While this is the least preferable method, it nonetheless reflects the reality confronted by most system designers on TradingView today. In this case, risk varies both because the fixed position size in initial capital currency represents a varying percentage of remaining equity, and because the trade’s stop amplitude may vary, adding another variability vector to risk. 
[b]Note that the Engine cannot display equity results for strategies entering trades for a fixed amount of shares/contracts at a variable price. 
[/b]

[b]SETTINGS/INPUTS [/b]
Because the initial text first published with a script cannot be edited later and because there are just too many options, the Engine’s Inputs will not be covered in minute detail, as they will most certainly evolve. We will go over them with broad strokes; you should be able to figure the rest out. If you have questions, just ask them here or in the PineCoders Telegram group. 

[b]Display [/b]
The display header’s checkbox does nothing. 
For the moment, only one exit strategy uses a take profit level, so only that one will show information when checking “Show Take Profit Level”. 
[b]Entries [/b]
You can activate two simultaneous entry strats, each selected from the same set of strats contained in the Engine. If you select two and they fire simultaneously, the main strat’s signal will be used. 
The random strat in each list uses a different seed, so you will get different results from each. 
The “Filter transitions” and “Filter states” strats delegate signal generation to the selected filter(s). “Filter transitions” signals will only fire when the filter transitions into bull/bear state, so after a trade is stopped out, the next entry may take some time to trigger if the filter’s state does not change quickly. When you choose “Filter states”, then a new trade will be entered immediately after an exit in the direction the filter allows. 
If you select “External Indicator”, your indicator will need to generate a +2/-2 (or a positive/negative stop value) to enter a long/short position, providing the selected filters allow for it. If you wish to use the Engine’s capacity to also derive the entry stop level from your indicator’s signal, then you must explicitly choose this option in the Entry Stops section. 
[b]Filters [/b]
You can activate as many filters as you wish; they are additive. The “Maximum stop allowed on entry” is an important component of proper risk management. If your system has an average 3% stop size and you need to trade using fixed position sizes because of alert/execution bot limitations, you must use this filter because if your system was to enter a trade with a 15% stop, that trade would incur 5 times the normal risk, and its result would account for an abnormally high proportion in your system’s performance. 
Remember that any filter can also be used as an entry signal, either when it changes states, or whenever no trade is active and the filter is in a bull or bear mode. 
[b]Entry Stops [/b]
An entry stop must be selected in the Engine, as it requires a stop level before the in-trade stop is calculated. Until the selected in-trade stop strat generates a stop that comes closer to price than the entry stop (or respects another one of the in-trade stops kick in strats), the entry stop level is used. 
It is here that you must select “External Indicator” if your indicator supplies a +price/-price value to be used as the entry stop. A +price is expected for a long entry and a -price value will enter a short with a stop at price. Note that the price is the absolute price, not an offset to the current price level. 
[b]In-Trade Stops[/b] 
The Engine comes with many built-in in-trade stop strats. Note that some of them share the “Length” and “Multiple” field, so when you swap between them, be sure that the length and multiple in use correspond to what you want for that stop strat. Suggested defaults appear with the name of each strat in the dropdown. 
In addition to the strat you wish to use, you must also determine when it kicks in to replace the initial entry’s stop, which is determined using different strats. For strats where you can define a positive or negative multiple of X, percentage or fixed value for a kick-in strat, a positive value is above the trade’s entry fill and a negative one below. A value of zero represents breakeven. 
[b]Pyramiding[/b] 
What you specify in this section are the rules that allow pyramiding to happen. By themselves, these rules will not generate pyramiding entries. For those to happen, entry signals must be issued by one of the active entry strats, and conform to the pyramiding rules which act as a filter for them. The “Filter must allow entry” selection must be chosen if you want the usual system’s filters to act as additional filtering criteria for your pyramided entries. 
[b]Hard Exits[/b] 
You can choose from a variety of hard exit strats. Hard exits are exit strategies which signal trade exits on specific events, as opposed to price breaching a stop level in In-Trade Stops strategies. They are self-explanatory. The last one labelled When Take Profit Level (multiple of X) is reached is the only one that uses a level, but contrary to stops, it is above price and while it is relative because it is expressed as a multiple of X, it does not move during the trade. This is the level called Take Profit that is show when the “Show Take Profit Level” checkbox is checked in the Display section. 
While stops focus on managing risk, hard exit strategies try to put the emphasis on capturing opportunity. 
[b]Slippage[/b] 
You can define it as a percentage or a fixed value, with different settings for entries and exits. The entry and exit markers on the chart show the impact of slippage on the entry price (the fill). 
[b]Fees[/b] 
Fees, whether expressed as a percentage of position size in and out of the trade or as a fixed value per in and out, are in the same units of currency as the capital defined in the Position Sizing section. Fees being deducted from your Capital, they do not have an impact on the chart marker positions. 
[b]In-Trade Events [/b]
These events will only trigger during trades. They can be helpful to act as reminders for traders using the Engine as assistance to discretionary trading. 
[b]Post-Exit Analysis [/b]
It is normally on. Some of its results will show in the Global Numbers section of the Data Window. Only a few of the statistics generated are shown; many more are available, but commented out in the Plot module. 
[b]Date Range Filtering [/b]
Note that you don’t have to change the dates to enable/diable filtering. When you are done with a specific date range, just uncheck “Date Range Filtering” to disable date filtering. 
[b]Alert Triggers [/b]
Each selection corresponds to one condition. Conditions can be combined into a single alert as you please. Just be sure you have selected the ones you want to trigger the alert before you create the alert. For example, if you trade in both directions and you want a single alert to trigger on both types of exits, you must select both “Long Exit” and “Short Exit” before creating your alert. 
Once the alert is triggered, these settings no longer have relevance as they have been saved with the alert. 
When viewing charts where an alert has just triggered, if your alert triggers on more than one condition, you will need the appropriate markers active on your chart to figure out which condition triggered the alert, since plotting of markers is independent of alert management. 
[b]Position sizing[/b] 
You have 3 options to determine position size: 
1. Proportional to Stop -> Variable, with a cap on size. 
2. Percentage of equity -> Variable. 
3. Percentage of Initial Capital -> Fixed. 
[b]External Indicator [/b]
This is where you connect your indicator’s plot that will generate the signals the Engine will act upon. Remember this only works in Indicator mode. 


[b]DATA WINDOW INFORMATION [/b]
The top part of the window contains global numbers while the individual trade information appears in the bottom part. The different types of units used to express values are: 
[list]
[*]curr: denotes the currency used in the Position Sizing section of Inputs for the Initial Capital value. 
[*]quote: denotes quote currency, i.e. the value the instrument is expressed in, or the right side of the market pair (USD in EURUSD ). 
[*]X: the stop’s amplitude, itself expressed in quote currency, which we use to express a trade’s P&L, so that a trade with P&L=2X has made twice the stop’s amplitude in profit. This is sometimes referred to as R, since it represents one unit of risk. It is also the unit of measure used in the APPT, which denotes expected reward per unit of risk. 
[*]X%: is also the stop’s amplitude, but expressed as a percentage of the Entry Fill.
[list]

The numbers appearing in the Data Window are all prefixed: 
[list]
[*]“ALL:” the number is the average for all first entries and pyramided entries. 
[*]”1ST:” the number is for first entries only. 
[*]”PYR:” the number is for pyramided entries only. 
[*]”PEA:” the number is for Post-Exit Analyses
[/list]

[b]Global Numbers [/b]
Numbers in this section represent the results of all trades up to the cursor on the chart. 
[b]Average Profitability Per Trade (X):[/b] This value is the most important gauge of your strat’s worthiness. It represents the returns that can be expected from your strat for each unit of risk incurred. E.g.: your APPT is 2.0, thus for every unit of currency you invest in a trade, you can on average expect to obtain 2 after the trade. APPT is also referred to as “statistical expectancy”. If it is negative, your strategy is losing, even if your win rate is very good (it means your winning trades aren’t winning enough, or your losing trades lose too much, or both). Its counterpart in currency is also shown, as is the APPT/bar, which can be a useful gauge in deciding between rivalling systems. 
[b]Profit Factor:[/b] Gross of winning trades/Gross of losing trades. Strategy is profitable when >1. Not as useful as the APPT because it doesn’t take into account the win rate and the average win/loss per trade. It is calculated from the total winning/losing results of this particular backtest and has less predictive value than the APPT. A good profit factor together with a poor APPT means you just found a chart where your system outperformed. Relying too much on the profit factor is a bit like a poker player who would think going all in with two’s against aces is optimal because he just won a hand that way. 
[b]Win Rate:[/b] Percentage of winning trades out of all trades. Taken alone, it doesn’t have much to do with strategy profitability. You can have a win rate of 99% but if that one trade in 100 ruins you because of poor risk management, 99% doesn’t look so good anymore. This number speaks more of the system’s profile than its worthiness. Still, it can be useful to gauge if the system fits your personality. It can also be useful to traders intending to sell their systems, as low win rate systems are more difficult to sell and require more handholding of worried customers. 
[b]Equity (curr):[/b] This the sum of initial capital and the P&L of your system’s trades, including fees and slippage. 
[b]Return on Capital[/b] is the equivalent of TV’s Net Profit figure, i.e. the variation on your initial capital. 
[b]Maximum drawdown[/b] is the maximal drawdown from the highest equity point until the drop . There is also a close to close (meaning it doesn’t take into account in-trade variations) maximum drawdown value commented out in the code. 
The next values are self-explanatory, until: 
[b]PYR: Avg Profitability Per Entry (X):[/b] this is the APPT for all pyramided entries. 
[b]PEA: Avg Max Opp . Available (X):[/b] the average maximal opportunity found in the Post-Exit Analyses. 
[b]PEA: Avg Drawdown to Max Opp . (X):[/b] this represents the maximum drawdown (incurred from the close at the beginning of the PEA analysis) required to reach the maximal opportunity point. 

[b]Trade Information [/b]
Numbers in this section concern only the current trade under the cursor. Most of them are self-explanatory. Use the description’s prefix to determine what the values applies to. 
[b]PYR: Avg Profitability Per Entry (X):[/b] While this value includes the impact of all current pyramided entries (and only those) and updates when you move your cursor around, P&L only reflects fees at the trade’s last bar. 
[b]PEA: Max Opp . Available (X):[/b] It’s the most profitable close reached post-trade, measured from the trade’s Exit Fill, expressed in the X value of the trade the PEA follows. 
[b]PEA: Drawdown to Max Opp . (X):[/b] This is the maximum drawdown from the trade’s Exit Fill that needs to be sustained in order to reach the maximum opportunity point, also expressed in X. Note that PEA numbers do not include slippage and fees. 

[b]EXTERNAL SIGNAL PROTOCOL [/b]
Only one external indicator can be connected to a script; in order to leverage its use to the fullest, the engine provides options to use it as either an entry signal, an entry/exit signal or a filter. When used as an entry signal, you can also use the signal to provide the entry’s stop. Here’s how this works: 
[b]For filter state:[/b] supply +1 for bull (long entries allowed), -1 for bear (short entries allowed). 
[b]For entry signals:[/b] supply +2 for long, -2 for short. 
[b]For exit signals:[/b] supply +3 for exit from long, -3 for exit from short. 
[b]To send an entry stop level with an entry signal:[/b] Send positive stop level for long entry (e.g. 103.33 to enter a long with a stop at 103.33), negative stop level for short entry (e.g. -103.33 to enter a short with a stop at 103.33). If you use this feature, your indicator will have to check for exact stop levels of 1.0, 2.0 or 3.0 and their negative counterparts, and fudge them with a tick in order to avoid confusion with other signals in the protocol. 
Remember that mere generation of the values by your indicator will have no effect until you explicitly allow their use in the appropriate sections of the Engine’s Settings/Inputs. 
An example of a script issuing a signal for the Engine is published by PineCoders. 

[b]RECOMMENDATIONS TO ASPIRING SYSTEM DESIGNERS [/b]
[b]Stick to higher timeframes.[/b] On progressively lower timeframes, margins decrease and fees and slippage take a proportionally larger portion of profits, to the point where they can very easily turn a profitable strategy into a losing one. Additionally, your margin for error shrinks as the equilibrium of your system’s profitability becomes more fragile with the tight numbers involved in the shorter time frames. Avoid <1H time frames. 

[b]Know and calculate fees and slippage.[/b] To avoid market shock, backtest using conservative fees and slippage parameters. Systems rarely show unexpectedly good returns when they are confronted to the markets, so put all chances on your side by being outrageously conservative—or a the very least, realistic. Test results that do not include fees and slippage are worthless. Slippage is there for a reason, and that’s because our interventions in the market change the market. It is easier to find alpha in illiquid markets such as cryptos because not many large players participate in them. If your backtesting results are based on moving large positions and you don’t also add the inevitable slippage that will occur when you enter/exit thin markets, your backtesting will produce unrealistic results. Even if you do include large slippage in your settings, the Engine can only do so much as it will not let slippage push fills past the high or low of the entry bar, but the gap may be much larger in illiquid markets. 

[b]Never test and optimize your system on the same dataset[/b], as that is the perfect recipe for overfitting or data dredging, which is trying to find one precise set of rules/parameters that works only on one dataset. These setups are the most fragile and often get destroyed when they meet the real world. 

[b]Try to find datasets yielding more than 100 trades.[/b] Less than that and results are not as reliable. 

[b]Consider all backtesting results with suspicion.[/b] If you never entertained sceptic tendencies, now is the time to begin. If your backtest results look really good, assume they are flawed, either because of your methodology, the data you’re using or the software doing the testing. Always assume the worse and learn proper backtesting techniques such as monte carlo simulations and walk forward analysis to avoid the traps and biases that unchecked greed will set for you. If you are not familiar with concepts such as survivor bias, lookahead bias and confirmation bias, learn about them. 

[b]Stick to simple bars or candles when designing systems.[/b] Other types of bars often do not yield reliable results, whether by design (Heikin Ashi) or because of the way they are implemented on TV (Renko bars). 

[b]Know that you don’t know[/b] and use that knowledge to learn more about systems and how to properly test them, about your biases, and about yourself. 

[b]Manage risk first[/b], then capture opportunity. 

[b]Respect the inherent uncertainty of the future.[/b] Cleanse yourself of the sad arrogance and unchecked greed common to newcomers to trading. Strive for rationality. Respect the fact that while backtest results may look promising, there is no guarantee they will repeat in the future (there is actually a high probability they won’t!), because the future is fundamentally unknowable. If you develop a system that looks promising, don’t oversell it to others whose greed may lead them to entertain unreasonable expectations. 

[b]Have a plan.[/b] Understand what king of trading system you are trying to build. Have a clear picture or where entries, exits and other important levels will be in the sort of trade you are trying to create with your system. This stated direction will help you discard more efficiently many of the inevitably useless ideas that will pop up during system design. 

[b]Be wary of complexity.[/b] Experienced systems engineers understand how rapidly complexity builds when you assemble components together—however simple each one may be. The more complex your system, the more difficult it will be to manage. 

[b]Play![/b]. Allow yourself time to play around when you design your systems. While much comes about from working with a purpose, great ideas sometimes come out of just trying things with no set goal, when you are stuck and don’t know how to move ahead. Have fun! 
@LucF 


[b]NOTES [/b]
While the engine’s code can supply multiple consecutive entries of longs or shorts in order to scale positions (pyramid), all exits currently assume the execution bot will exit the totality of the position. No partial exits are currently possible with the Engine. 
Because the Engine is literally crippled by the limitations on the number of plots a script can output on TV; it can only show a fraction of all the information it calculates in the Data Window. You will find in the Plot Module vast amounts of commented out lines that you can activate if you also disable an equivalent number of other plots. This may be useful to explore certain characteristics of your system in more detail. 
When backtesting using the TV backtesting feature, you will need to provide the strategy parameters you wish to use through either Settings/Properties or by changing the default values in the code’s header. These values are defined in variables and used not only in the strategy() statement, but also as defaults in the Engine’s relevant Inputs. 
If you want to test using pyramiding, then both the strategy’s Setting/Properties and the Engine’s Settings/Inputs need to allow pyramiding. 
If you find any bugs in the Engine, please let us know. 


[b]THANKS [/b]
To @glaz for allowing the use of his unpublished MA Squize in the filters. 
To @everget for his Chandelier stop code, which is also used as a filter in the Engine. 
To @RicardoSantos for his pseudo-random generator, and because it’s from him that I first read in the Pine chat about the idea of using an external indicator as input into another. In the PineCoders group, @theheirophant then mentioned the idea of using it as a buy/sell signal and @simpelyfe showed a piece of code implementing the idea. That’s the tortuous story behind the use of the external indicator in the Engine. 
To @admin for the Volatility stop’s original code and for the donchian function lifted from Ichimoku . 
To @BobHoward21 for the v3 version of Volatility Stop . 
To @scarf and @midtownsk8rguy for the color tuning. 
To many other scripters who provided encouragement and suggestions for improvement during the long process of writing and testing this piece of code. 
To J. Welles Wilder Jr. for ATR, used extensively throughout the Engine. 
To TradingView for graciously making an account available to PineCoders. 
And finally, to all fellow PineCoders for the constant intellectual stimulation; it is a privilege to share ideas with you all. The Engine is for all TradingView PineCoders, of course—but especially for you. 



[url=https://www.tradingview.com/athletes/]Look first. Then leap.[/url]

## Source Code

````pine
//@version=3
//@author=LucF, for PineCoders

// Backtesting-Trading Engine [PineCoders]
//  v1.5, 2019.08.05 16:28 — Luc

// PineCoders, Tools and ideas for all Pine coders: pinecoders.com

// This script is referenced from the PineCoders FAQ & Code here: http://www.pinecoders.com/faq_and_code/
// Documentation: https://www.tradingview.com/script/dYqL95JB-Backtesting-Trading-Engine-PineCoders/

// The PineCoders Backtesting and Trading Engine is a sophisticated framework with hybrid code 
// that can run as a study to generate alerts for automated or discretionary trading while simultaneously providing
// backtest results. It can also easily be converted to a TradingView strategy in order to run TV backtesting.
// The Engine comes with many built-in strats for entries, filters, stops and exits, but you can also add your own.

// LOGIC
//  1. Entry Trigger (Module 10)
//      The big picture here is that when we are not yet in a trade, we are looking to identify an entry condition,
//      which we call a trigger. The trigger only occurs if all required entry conditions are respected,
//      i.e. we have an entry strat that fires, trading is allowed in that direction, the selected filters agree,
//      the date range allows a trade here, enough bars have passed in the dataset to have a proper atr value and
//      some trading capital is left.
//      Once an entry trigger is confirmed, not much is done on that bar besides firing the entry alert, if required.
//      The rest of the action, including plotting the in-trade information on the chart, only happens on the next bar.
//      The smaller picture is that while we are in a trade, we are also monitoring the entry strats
//      to identify pyramiding opportunities, if the pyramiding conditions allow for it, and updating results for the Data Window.
//  2. Entry fill (Module 6)
//      At the bar following a first entry trigger, we put the trade in motion. We start from the open of that bar and
//      add slippage if required. From there we get our precious X value, i.e. the distance between the entry fill
//      and the entry's stop value, which represents the risk incurred on the trade.
//      After that we update numbers and begin plotting the trade's status.
//  3. In-Trade management (Module 6)
//      During a trade we are watching for events (Module 13) and, if required, trigger alerts on them.
//      We also watch the progress of the trade, continually updating stop and take profit exit conditions,
//      shifting between different exit strats if required, as price progresses, and updating info like 
//      the P&L in order to display a putative value at each bar. We are also checking numbers for max drawdown data.
//  4. Exit trigger (Module 10)
//      Exit conditions are all measured against "close", so in the realtime bar they are evaluated
//      every time price changes. An exit trigger occurs if the in-trade stop is breached or if
//      a level or condition defined by an Exit strat is reached. Once an exit trigger is confirmed,
//      trade and global data is updated and the exit alert is triggered. We are then no longer in a trade.
//      The trade's last bar information is printed and trade vars are reset in Module 16.
//  5. Post-Exit analysis (Module 12)
//      If Post-Exit analysis is selected and the trade was stopped out or exited with an Exit strat, we continue analyzing for
//      PEABars to see what opportunity could have been captured in those bars if we hadn't exited,
//      and what drawdown would need to be incurred to attain it.
//      The idea here is to help traders evaluate if their stop or exit strat is too aggressive.

// MODULES (* denotes modules that don't require mods when only adding/deleting strats):
//      0.  Inputs
//      1.  Variable Initializations
//      2.  Indicators and functions
//      3.  Entry Stops
//      4.  Filters
//      5.  Entries
//      6.  Trade Entry and In-trade Processing *
//      7.  Pyramiding Rules
//      8.  In-trade Stops
//      9.  Exits
//     10.  Trade Entry/Exit Trigger Detection *
//     11.  Trade Exit Processing *
//     12.  Post-Exit Analysis *
//     13.  Events *
//     14.  Plots *
//     15.  Alerts *
//     16.  Variable resets *
//     17.  Strategy() calls *

// CUSTOMIZATION
//      The code is organized so that it will be relatively easy to insert your own strats in its different modules.
//      Customizing the engine does, of course, require a certain level of understanding of the code's organization,
//      but the script was designed so that unless you need to modify the actual trade management logic and the global interaction
//      between the modules, you should be able to add your strats and remove those you don't use by making local
//      interventions only, dispensing you of understanding all of the engine's logic.
//
//      Insertion of new strats will typically involve the following steps:
//          1. Add the required inputs in Module 0,
//          2. If needed, add the indicator(s) you need to support your strat in Module 2. There are no particular rules
//             to be aware of in deciding whether your indicator code must go in Module 2 or right along your strat in its corresponding
//             module. We put them in Module 2 when they are used by more than one strat or if they are too big, to keep module code tidy.
//          3. Add the new strat in its corresponding module (entry stops, filters, etc.),
//          4. In that module, add your new strat to the "glue" statements that conclude each module and allow assembly/selection.

// EXTERNAL SIGNAL PROTOCOL
//      Only one external indicator can be connected to a script; in order to leverage its use to the fullest,
//      the engine provides options to use it as either and entry signal, an entry/exit signal or a filter.
//      When used as an entry signal, you can also use the signal to provide the entry stop. Here’s how this works.
//        - For filter state: supply +1.0 for bull (long entries allowed), -1.0 for bear (short entries allowed).
//        - For entry signals: supply +2.0 for long, -2.0 for short.
//        - For exit signals: supply +3.0 for exit from long, -3.0 for exit from short.
//        - To send an entry stop level with entry signal: Send positive stop level for long entry
//          (e.g. 103.33 to enter a long with a stop at 103.33), negative stop level for short entry
//          (e.g. -103.33 to enter a short with a stop at 103.33). If you use this feature,
//          your indicator will have to check for exact stop levels of 1.0, 2.0 or 3.0 and their negative counterparts,
//          and fudge them with a tick in order to avoid confusion with other signals in the protocol.
//      Note that each use must be confirmed in the corresponding section of the script's Settings/Inputs.
//      See here for an example of a script able to produce the values the Engine requires: https://www.tradingview.com/script/y4CvTwRo-Signal-for-Backtesting-Trading-Engine-PineCoders/

// CONFIGURATION OF ALERTS
//      Entry and Event alerts will generally be configured to trigger Once Per Bar Close.
//      Exit alerts can be configured to trigger Once Per Bar Close or Once Per Bar, depending on how fast
//      you want them. Once Per Bar means the alert will trigger the moment the condition is first encountered
//      during the realtime bar, instead of at the bar's close. It's faster but noisier.
//      Entry and Exit alerts trigger at the same bar where the relevant marker will appear on the chart.
//      Event alerts trigger on the bar following the appearance of their respective marker on the chart.

// NOTES
//    - Don't let the size of the script impress you; it should be relatively easy to find your way around.
//    - Stop behavior: The engine works with the assumption that entry stops and in-trade stops are calculated
//      in separate modules and using different strats. Both long and short entry stops calculations must currently be done without
//      without the benefit of in-trade information such as trigger detection, trade direction, an entry level, a maximum reached, etc.
//    - While performance improvements could have been achieved by structuring more of the code with if statements,
//      we have chosen to stay away from local blocks whenever possible in order to prevent scope issues to come into play.
//      Performance optimization can be achieved by commenting out or eliminating unused strats for production.

// CONVERSION FROM STUDY (INDICATOR) TO STRATEGY
//      1.  Comment out study() statement at the beginning of the script.
//      2.  Uncomment strategy() statement preceding it.
//      3.  Uncomment last 3 lines of script.
//      4.  Save and voilà!

// Put the name of your system here. This string is used in study(), strategy() and alertconditon() statements.
SystemName = "Backtesting & Trading Engine [PineCoders]"
// This string is to personalize the text that appears with your orders on the chart through strategy() calls and entry/exit markers, and in the alert default message.
// Although leaving it empty will not cause problems in study mode,
// IT MUST BE NON NULL WHEN THIS CODE IS COMPILED AS A STRATEGY, otherwise you will get a server error. A space is legal.
TradeId = "BTE"
// These values are used both in the strategy() header and in the script's relevant inputs as default values so they match.
// Unless these values match in the script's Inputs and the TV backtesting Properties, results between them cannot be compared.
InitCapital = 100000
InitPosition = 10.0
InitCommission = 0.075
InitPyramidMax = 10
// strategy(title=SystemName, shorttitle=SystemName, overlay=true, pyramiding=InitPyramidMax, initial_capital=InitCapital, default_qty_type=strategy.percent_of_equity, default_qty_value=InitPosition, commission_type=strategy.commission.percent, commission_value=InitCommission)
study(title=SystemName, shorttitle=SystemName, overlay=true)


 
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————— 0. Inputs ————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ——————————————— Colors
MyGreenRaw = color(lime,0),             MyGreenMedium = color(#00b300,0),       MyGreenSemiDark = color(#009900,0),     MyGreenDark = color(#006600,0),         MyGreenDarkDark = color(#003300,0)
MyRedRaw = color(red,0),                MyRedMedium = color(#cc0000,0),         MyRedSemiDark = color(#990000,0),       MyRedDark = color(#330000,0),           MyRedDarkDark = color(#330000,0)
MyFuchsiaRaw = color(fuchsia,0),        MyFuchsiaMedium = color(#c000c0,0),     MyFuchsiaDark = color(#800080,0),       MyFuchsiaDarkDark = color(#400040,0)
MyYellowRaw  = color(yellow,0),         MyYellowMedium  = color(#c0c000,0),     MyYellowDark  = color(#808000,0),       MyYellowDarkDark  = color(#404000,0)
MyOrangeRaw = color(#ffa500,0),         MyOrangeMedium = color(#cc8400,0),      MyOrangeDark = color(#996300,0)
MyBlueRaw   = color(#4985E7,0),         MyBlueMedium   = color(#4985E7,0)
MyGreenBackGround = color(#00FF00,93),  MyRedBackGround = color(#FF0000,90)

// ——————————————— Inputs and states
// ————— A. Option list statics.
TD1 = "Both",                       TD2 = "Longs Only",                 TD3 = "Shorts Only"
EN0 = "0. None",                    EN1 = "1. Random",                  EN2 = "2. External Indicator (+2/-2 or +stop/-stop)",                   EN3 = "3. Filter transitions",          EN4 = "4. Filter states",           EN5 = "5. RSI crosses",     EN6 = "6. Tenkan/Kijun crosses"
SE1 = "1. None",                    SE2 = "2. On Entries",              SE3 = "3. All"
ES1 = "1. External Indicator (+stop/-stop)",                            ES2 = "2. ATR multiple",            ES3 = "3. Fixed %",                 ES4 = "4. Fixed Value"
IS0 = "0. None",                    IS1 = "1. Trailing at X multiple",  IS2 = "2. Trailing at %",           IS3 = "3. Trailing at Fixed Value", IS4 = "4. Donchian Center (Kijun)", IS5 = "5. Simple ATR multiple (14,4)",  IS6 = "6. Chandelier(20,3)", IS7 = "7. Volatility Stop (20,3)", IS8 = "8. Last Lo/Hi"
IK1 = "1. Entry Stop",              IK2 = "2. Entry +/- X multiple",    IK3 = "3. Entry +/- %",             IK4 = "4. Entry +/- Fixed Value"
PY1 = "Off",                        PY2 = "Off but all opportunities displayed",                            PY3 = "On"
PT1 = "1. Every X Multiple",        PT2 = "2. Every % Increment",       PT3 = "3. Every Price Increment",   PT4 = "4. On same entry",           PT5 = "5. On different entry",          PT6 = "6. At every opportunity"
SL1 = "1. None",                    SL2 = "2. Percentage",              SL3 = "3. Fixed Value"
FE1 = "1. None",                    FE2 = "2. Percentage",              FE3 = "3. Fixed Value"
PA1 = "Off",                        PA2 = "On"
PS1 = "1. Proportional to Stop -> Variable",                            PS2 = "2. % of Equity -> Variable", PS3 = "3. % of Capital -> Fixed"
// ————— B. Display
_0 =    input(true, "═════════════ Display")
ShowTradedBackground = input(true, "Color Traded Background")
ShowMarkers = input(true, "Show Entry/Exit Markers")
ShowEntry = input(true, "Show Entry Level")
ShowTakeProfit = input(false, "Show Take Profit Level")
ShowEquity = false //input(false, "Show Equity Curve")
// ————— C. Entries
_2 =    input(true, "═════════════ Entries")
TradeDirection = input(TD1, "Trade Direction", options=[TD1, TD2, TD3])
GenerateLongs = TradeDirection!=TD3
GenerateShorts = TradeDirection!=TD2
EntryA = input(EN1, "Main Entry Strat", options=[EN0, EN1, EN2, EN3, EN4, EN5, EN6])
EntryB = input(EN0, "Alternate Entry Strat", options=[EN0, EN1, EN2, EN3, EN4, EN5, EN6])
EntryType0 = EntryA==EN0 or EntryB==EN0
// Split the random entries in 2 so we can generate from 2 different seeds.
EntryType1A = EntryA==EN1
EntryType1B = EntryB==EN1
EntryType2 = EntryA==EN2 or EntryB==EN2
EntryType3 = EntryA==EN3 or EntryB==EN3
EntryType4 = EntryA==EN4 or EntryB==EN4
EntryType5 = EntryA==EN5 or EntryB==EN5
EntryType6 = EntryA==EN6 or EntryB==EN6
EntryType1Freq = input(10.0, "1. Frequency (approx. 1/n bars)", minval=2, step=4)
EntryType5Len = input(14, "5. Length", minval=2)
EntryType5LongLvl = input(30, "5. Long Crossover Level", minval=0, maxval=100)
EntryType5ShortLvl = input(70, "5. Short Crossunder Level", minval=0, maxval=100)
EntryType6TLen = input(9, "6. Tenkan Length", minval=2)
EntryType6KLen = input(26, "6. Kijun Length", minval=2)
// ————— D. Filters
ShowFilter = input(false, "═════════════ Show Filter State")
ShowFilteredOut = input(false, "Show Filtered Out Entries")
FilterType1 = input(false, "1. Random")
FilterType1Freq = input(10.0, "... Frequency (approx. 1/n bars)", minval=2, step=4)
FilterType2 = input(false, "2. External Indicator (+1/-1)")
FilterType3 = input(false, "3. Bar direction=Trade direction")
FilterType4 = input(false, "4. Rising Volume")
FilterType5 = input(false, "5. Rising/Falling MA")
FilterType5Len = input(50, "... Length", minval=2)
FilterType5Bars = input(1, "... For n Bars", minval=1)
FilterType6 = input(false, "6. Maximum % Stop allowed on entry")
FilterType6MaxRisk = input(6.0, title="... %", minval=0.0, step=0.5)
FilterType7 = input(false, "7. Maximum close change (%) allowed on entry")
FilterType7IncPct = input(6.0, title="... %", minval=0.0, step=0.5)
FilterType8 = input(false, "8. Ichimoku")
FilterType9 = input(false, "9. RSI OB/OS")
FilterType9Len = input(20, "... Length", minval=2)
FilterType9OS = input(25, "... Oversold Level", minval=0, maxval=100)
FilterType9OB = input(75, "... Overbought Level", minval=0, maxval=100)
FilterType10 = input(true, "10. Chandelier")
FilterType10Len = input(20, "... Length", minval=2)
FilterType10Mult = input(3, "... ATR Multiple", minval=0, step=0.25)
FilterType11 = input(false, "11. MA Squize")
FilterType11Len1 = input(5, "... Fast MA", minval=2)
FilterType11Len2 = input(21, "... Slow MA", minval=2)
// ————— E. Entry stops
ShowEntryStop = input(SE1, "═══════════════ Show Entry Stops", options=[SE1, SE2, SE3])
ShowEntryStopEntry = ShowEntryStop==SE2
ShowEntryStopAll = ShowEntryStop==SE3
EntryStopType = input(ES2, "Entry Stop Selection", options=[ES1, ES2, ES3, ES4])
EntryStopType1 = EntryStopType==ES1
EntryStopType2 = EntryStopType==ES2
EntryStopType3 = EntryStopType==ES3
EntryStopType4 = EntryStopType==ES4
EntryStopType2Mult = input(1.5, "2. ATR Multiple", minval=0.05, step=0.1)
EntryStopType2Len = input(14, "2. ATR Length", minval=2)
EntryStopType3Pct = input(3.0, "3. %", minval=0.0001, step=0.1)
EntryStopType4Val = input(0.001, "4. Value", minval=0.00000001, step=0.0001)
// ————— F. In-trade stops
ShowInTradeStop = input(true, "═════════════ Show In-Trade Stops")
InTradeStopType = input(IS7, "In-Trade Stop Selection", options=[IS0, IS1, IS2, IS3, IS4, IS5, IS6, IS7, IS8])
InTradeStopDisabled = InTradeStopType==IS0
InTradeStopType1 = InTradeStopType==IS1
InTradeStopType2 = InTradeStopType==IS2
InTradeStopType3 = InTradeStopType==IS3
InTradeStopType4 = InTradeStopType==IS4
InTradeStopType5 = InTradeStopType==IS5
InTradeStopType6 = InTradeStopType==IS6
InTradeStopType7 = InTradeStopType==IS7
InTradeStopType8 = InTradeStopType==IS8
InTradeStopType1Mult = input(1.0, "1. X (Entry Stop's Amplitude) Multiple", minval=0.001, step=0.1)
InTradeStopType2Pct = input(2.0, "2. %", minval=0.001, step=0.1)
InTradeStopType3Val = input(0.001, "3. Value", minval=0.00000001, step=0.0001)
InTradeStopType4Len = input(26, "4. Length", minval=2)
InTradeStopType567Len = input(20, "5-6-7. Length", minval=2)
InTradeStopType567Mult = input(3.0, "5-6-7. Multiple", minval=0.001, step=0.5)
InTradeKickType = input(IK1, "════ In-Trade Stop Kicks In When It Passes...", options=[IK1, IK2, IK3, IK4])
InTradeKickType1 = InTradeKickType==IK1
InTradeKickType2 = InTradeKickType==IK2
InTradeKickType3 = InTradeKickType==IK3
InTradeKickType4 = InTradeKickType==IK4
InTradeKickType2Mult = input(2.0, "2. X Multiple (+ is in trade direction, - is against)", step=0.05)
InTradeKickType3Pct = input(3.0, "3. %  (+/-)", step=0.1)
InTradeKickType4Val = input(0.001, "4. Value  (+/-)", step=0.0001)
// ————— G. Pyramiding rules
Pyramiding = input(PY1, "═══════════════ Pyramiding", options=[PY1, PY2, PY3])
PyramidingOff = Pyramiding==PY1
PyramidingOffButShow = Pyramiding==PY2
PyramidingOn = Pyramiding==PY3
PyramidingType = input(PT6, "Pyramiding is allowed...", options=[PT1, PT2, PT3, PT4, PT5, PT6])
PyramidingFilterNeeded = input(false, "Filter must allow entry")
PyramidingMaxCnt = input(InitPyramidMax, "Maximum number of pyramiding entries", minval=1)
PyramidingPosMult = input(1.0, "Position Size Multiple of Original Entry Position", minval=0.00000001, step=0.1)
Pyramiding1MultX = input(1.0, "1. Multiple of X (stop)", minval=0.00000001)
Pyramiding2Pct = input(2.0, "2. % Increment", minval=0.00000001)
Pyramiding3Val = input(0.00001, "3. Price Increment", minval=0.00000001)
PyramidingType1 = not PyramidingOff and PyramidingType==PT1
PyramidingType2 = not PyramidingOff and PyramidingType==PT2
PyramidingType3 = not PyramidingOff and PyramidingType==PT3
PyramidingType4 = not PyramidingOff and PyramidingType==PT4
PyramidingType5 = not PyramidingOff and PyramidingType==PT5
PyramidingType6 = not PyramidingOff and PyramidingType==PT6
// ————— H. Hard Exits
_4 = input(true, "═════════════ Hard Exits")
ExitType1 = input(false, "1. Random")
ExitType1Freq = input(10.0, "... Frequency (approx. 1/n bars)", minval=2, step=4)
ExitType2 = input(false, "2. External Indicator (+3/-3)")
ExitType3 = input(false, "3. Filter Transitions")
ExitType4 = input(false, "4. RSI Crosses")
ExitType4Len = input(20, "... Length", minval=2)
ExitType4LongLvl = input(70, "... Exit Long Crossunder Level", minval=0, maxval=100)
ExitType4ShortLvl = input(30, "... Exit Short Crossover Level", minval=0, maxval=100)
ExitType5 = input(false, "5. Tenkan/Kijun Crosses")
ExitType5TLen = input(9, "... Tenkan Length", minval=2)
ExitType5KLen = input(26, "... Kijun Length", minval=2)
ExitType6 = input(false, title="6. When Take Profit Level (multiple of X) is reached")
ExitType6Mult = input(2.0, "... X Multiple", minval=0.0)
// ————— I. Slippage
SlippageType = input(SL1, "═══════════════ Slippage", options=[SL1, SL2, SL3])
SlippageType2InPct = input(0.25, "2. % Slippage on Entry", minval=0.0, step=0.1)
SlippageType2OutPct = input(0.25, "2. % Slippage on Exit", minval=0.0, step=0.1)
SlippageType3InVal = input(0.0001, "3. Fixed Slippage on Entry (quote)", minval=0.0, step=0.0001)
SlippageType3OutVal = input(0.0001, "3. Fixed Slippage on Exit (quote)", minval=0.0, step=0.0001)
SlippageType2 = SlippageType==SL2
SlippageType3 = SlippageType==SL3
// ————— J. Fees
FeesType = input(FE1, "═══════════════ Fees", options=[FE1, FE2, FE3])
FeesType2InPct = input(InitCommission, "2. % of Position on Entry (Curr)", minval=0.0, step=0.1)
FeesType2OutPct = input(InitCommission, "2. % of Position on Exit (Curr)", minval=0.0, step=0.1)
FeesType3InVal = input(10.0, "3. Fixed Amount on Entry (Curr)", minval=0.0)
FeesType3OutVal = input(10.0, "3. Fixed Amount on Exit (Curr)", minval=0.0)
FeesType2 = FeesType==SL2
FeesType3 = FeesType==SL3
// ————— K. In-Trade Events
_6 = input(true, "═════════════ In-Trade Events")
EventType1 = input(false, "1. Show When Price Is Within... (orange)")
EventType1Mult = input(1.0, title="... ATR Multiple of Stop", minval=0.0, step=0.1)
EventType2 = input(false, "2. Show Possible Tops/Bottoms (red)")
EventType3 = input(false, "3. Show Stop Move Larger than... (yellow)")
EventType3Mult = input(0.2, title="... ATR multiple", minval=0.0, step=0.05)
EventType4 = input(false, "4. Show Favorable Price Move Larger than... (green)")
EventType4Mult = input(2.0, title="... ATR Multiple", minval=0.0, step=0.25)
EventAtrLen = input(14, "ATR Length for Events", minval=2)
// ————— L. Post-Trade Analysis
PEA = input(PA2, "═══════════════ Post-Exit Analysis (PEA)", options=[PA1, PA2])
PEABars = input(10, "Look n bars after Exit", minval=3)
PEAOn = PEA==PA2
// ————— M. Date range filtering
DateFilter = input(false, "═════════════ Date Range Filtering")
FromYear = input(1900, "From Year", minval=1900),   FromMonth = input(1, "From Month", minval=1, maxval=12),    FromDay = input(1, "From Day", minval=1, maxval=31)
ToYear = input(2999, "To Year", minval=1900),       ToMonth = input(1, "To Month", minval=1, maxval=12),        ToDay = input(1, "To Day", minval=1, maxval=31)
FromDate = timestamp(FromYear, FromMonth, FromDay, 00, 00),     ToDate = timestamp(ToYear, ToMonth, ToDay, 23, 59)
TradeDateIsAllowed() => DateFilter? (time >= FromDate and time <= ToDate) : true
// ————— N. Alert Configuration
_8 = input(true, "═════════════ Alert Triggers")
AlertType1 = input(false, "Long Entry")
AlertType2 = input(false, "Long Pyramiding Entry")
AlertType3 = input(false, "Short Entry")
AlertType4 = input(false, "Short Pyramiding Entry")
AlertType5 = input(false, "Long Exit")
AlertType6 = input(false, "Short Exit")
AlertType7 = input(false, "Event 1: Price nearing Stop")
AlertType8 = input(false, "Event 2: Possible Tops/Bottoms")
AlertType9 = input(false, "Event 3: Stop Move")
AlertType10 = input(false, "Event 4: Price Swing")
// ————— O. Position sizing
PosType = input(PS2, "═══════════════ Position Sizing", options=[PS1, PS2, PS3])
PosType1 = PosType==PS1
PosType2 = PosType==PS2
PosType3 = PosType==PS3
PosTypeCapital = input(InitCapital, title="Initial Capital (In Units of Currency)", minval=0.0, step=10000)
PosType1Risk = input(1.0, title="1. % of Equity Risked Per Trade (Stop% * Position)", minval=0.0, maxval=100.0, step=0.1)
PosType1Cap = input(50.0, title="1. Cap on position sizes (% of Equity)", minval=0.0, maxval=100.0, step=10.0)
PosType2Pct = input(InitPosition, title="2. % of Equity", minval=0.0, maxval=100.0, step=5.0)
PosType3Pct = input(10.0, title="3. % of Initial Capital", minval=0.0, maxval=100.0, step=5.0)
// ————— P. Misc.
_10 = input(true, "═════════════ External Indicator")
ExternalIndie_ = input(close, "Connect your indicator here (Study mode only)")
ExternalIndie = nz(ExternalIndie_)



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// —————————————————————————————————————— 1. Variable Initializations —————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// We declare global and trade vars and propagate values for those that need it.
// Vars holding global stats for all trades are divided in 4 groups: Combined (First and pyramided entries), First entries, Pyramided entries and PEA (Post-Exit Analysis).
// They start with All_, First_, Pyr_ or PEA_ respectively.
// So-called local vars hold data relating to one trade at a time. They use the same prefix, without an underscore.

// We deal with 4 different units in the code:
//  1.  Quote currency (quote), i.e. the price on the chart.
//  2.  X (X): the stop's amplitude,
//  3.  Currency (curr): the currency of the Initial Capital.
//  4.  % of Initial Capital (equ): a % representing a fraction of Initial Capital.

// ———————————————————— A. Global data.
// ————— Global stats (1st and pyramided entries)
// All entries.
All_Entries = 0, All_Entries := nz(All_Entries[1])
// All fees paid (equ).
All_FeesEqu = 0.0, All_FeesEqu := nz(All_FeesEqu[1])
// Sum and avg of PLX (P&L expressed as mult of X).
All_PLXTot = 0.0, All_PLXTot := nz(All_PLXTot[1])
All_PLXAvg = 0.0, All_PLXAvg := nz(All_PLXAvg[1])
// Total of all Entry position sizes (equ).
All_PositionInTot = 0.0, All_PositionInTot := nz(All_PositionInTot[1])
// Profit factor.
All_ProfitFactor = 0.0, All_ProfitFactor := nz(All_ProfitFactor[1])
// All slippage paid (equ).
All_SlipEqu = 0.0, All_SlipEqu := nz(All_SlipEqu[1])
// Sum and avg of trade lengths.
All_TradeLengthsTot = 0.0, All_TradeLengthsTot := nz(All_TradeLengthsTot[1])
All_TradeLengthsAvg = 0.0, All_TradeLengthsAvg := nz(All_TradeLengthsAvg[1])
// All currency volume traded (both entries and exits counted).
All_VolumeTraded = 0.0, All_VolumeTraded := nz(All_VolumeTraded[1])
// Sum of all winning/losing trades.
All_Winning = 0, All_Winning := nz(All_Winning[1])
All_Losing = 0, All_Losing := nz(All_Losing[1])
// Sum of winning/losing trade lengths.
All_WinsTL = 0.0, All_WinsTL := nz(All_WinsTL[1])
All_LoseTL = 0.0, All_LoseTL := nz(All_LoseTL[1])
// P&L total (X) of all winning/losing trades.
All_WinsX = 0.0, All_WinsX := nz(All_WinsX[1])
All_LoseX = 0.0, All_LoseX := nz(All_LoseX[1])
// P&L total (equ) of all winning/losing trades.
All_WinsEqu = 0.0, All_WinsEqu := nz(All_WinsEqu[1])
All_LoseEqu = 0.0, All_LoseEqu := nz(All_LoseEqu[1])
// Sum and avg of all stops (quote).
All_XTot = 0.0, All_XTot := nz(All_XTot[1])
All_XAvg = 0.0, All_XAvg := nz(All_XAvg[1])
// Sum and avg of all stops (equ).
All_XEquTot = 0.0, All_XEquTot := nz(All_XEquTot[1])
All_XEquAvg = 0.0, All_XEquAvg := nz(All_XEquAvg[1])
// Sum and avg of all stops as percentage of fill.
All_XPctTot = 0.0, All_XPctTot := nz(All_XPctTot[1])
All_XPctAvg = 0.0, All_XPctAvg := nz(All_XPctAvg[1])

// ————— First entry stats.
First_Entries = 0, First_Entries := nz(First_Entries[1])
First_FeesEqu = 0.0, First_FeesEqu := nz(First_FeesEqu[1])
First_PLXTot = 0.0, First_PLXTot := nz(First_PLXTot[1])
First_PLXAvg = 0.0, First_PLXAvg := nz(First_PLXAvg[1])
First_PositionInTot = 0.0, First_PositionInTot := nz(First_PositionInTot[1])
First_ProfitFactor = 0.0, First_ProfitFactor := nz(First_ProfitFactor[1])
First_SlipEqu = 0.0, First_SlipEqu := nz(First_SlipEqu[1])
First_TradeLengthsTot = 0.0, First_TradeLengthsTot := nz(First_TradeLengthsTot[1])
First_TradeLengthsAvg = 0.0, First_TradeLengthsAvg := nz(First_TradeLengthsAvg[1])
First_VolumeTraded = 0.0, First_VolumeTraded := nz(First_VolumeTraded[1])
First_Winning = 0, First_Winning := nz(First_Winning[1])
First_Losing = 0, First_Losing := nz(First_Losing[1])
First_WinsTL = 0, First_WinsTL := nz(First_WinsTL[1])
First_LoseTL = 0, First_LoseTL := nz(First_LoseTL[1])
First_WinsX = 0.0, First_WinsX := nz(First_WinsX[1])
First_LoseX = 0.0, First_LoseX := nz(First_LoseX[1])
First_WinsEqu = 0.0, First_WinsEqu := nz(First_WinsEqu[1])
First_LoseEqu = 0.0, First_LoseEqu := nz(First_LoseEqu[1])
First_XTot = 0.0, First_XTot := nz(First_XTot[1])
First_XAvg = 0.0, First_XAvg := nz(First_XAvg[1])
First_XEquTot = 0.0, First_XEquTot := nz(First_XEquTot[1])
First_XEquAvg = 0.0, First_XEquAvg := nz(First_XEquAvg[1])
First_XPctTot = 0.0, First_XPctTot := nz(First_XPctTot[1])
First_XPctAvg = 0.0, First_XPctAvg := nz(First_XPctAvg[1])

// ————— Pyramiding
// All pyramid entries.
Pyr_Entries = 0, Pyr_Entries := nz(Pyr_Entries[1])
Pyr_EntryBarTot = 0.0, Pyr_EntryBarTot := nz(Pyr_EntryBarTot[1])
Pyr_EntryBarAvg = 0.0, Pyr_EntryBarAvg := nz(Pyr_EntryBarAvg[1])
Pyr_FeesEqu = 0.0, Pyr_FeesEqu := nz(Pyr_FeesEqu[1])
Pyr_PLXTot = 0.0, Pyr_PLXTot := nz(Pyr_PLXTot[1])
Pyr_PLXAvg = 0.0, Pyr_PLXAvg := nz(Pyr_PLXAvg[1])
Pyr_PositionInTot = 0.0, Pyr_PositionInTot := nz(Pyr_PositionInTot[1])
Pyr_PositionInAvg = 0.0, Pyr_PositionInAvg := nz(Pyr_PositionInAvg[1])
Pyr_PositionInQtyTot = 0.0, Pyr_PositionInQtyTot := nz(Pyr_PositionInQtyTot[1])
Pyr_ProfitFactor = 0.0, Pyr_ProfitFactor := nz(Pyr_ProfitFactor[1])
Pyr_SlipQuote = 0.0, Pyr_SlipQuote := nz(Pyr_SlipQuote[1])
Pyr_SlipEqu = 0.0, Pyr_SlipEqu := nz(Pyr_SlipEqu[1])
Pyr_TradeLengthsTot = 0.0, Pyr_TradeLengthsTot := nz(Pyr_TradeLengthsTot[1])
Pyr_TradeLengthsAvg = 0.0, Pyr_TradeLengthsAvg := nz(Pyr_TradeLengthsAvg[1])
Pyr_VolumeTraded = 0.0, Pyr_VolumeTraded := nz(Pyr_VolumeTraded[1])
Pyr_Winning = 0, Pyr_Winning := nz(Pyr_Winning[1])
Pyr_Losing = 0, Pyr_Losing := nz(Pyr_Losing[1])
Pyr_WinsTL = 0.0, Pyr_WinsTL := nz(Pyr_WinsTL[1])
Pyr_LoseTL = 0.0, Pyr_LoseTL := nz(Pyr_LoseTL[1])
Pyr_WinsX = 0.0, Pyr_WinsX := nz(Pyr_WinsX[1])
Pyr_LoseX = 0.0, Pyr_LoseX := nz(Pyr_LoseX[1])
Pyr_WinsEqu = 0.0, Pyr_WinsEqu := nz(Pyr_WinsEqu[1])
Pyr_LoseEqu = 0.0, Pyr_LoseEqu := nz(Pyr_LoseEqu[1])
Pyr_XTot = 0.0, Pyr_XTot := nz(Pyr_XTot[1])
Pyr_XAvg = 0.0, Pyr_XAvg := nz(Pyr_XAvg[1])
Pyr_XEquTot = 0.0, Pyr_XEquTot := nz(Pyr_XEquTot[1])
Pyr_XEquAvg = 0.0, Pyr_XEquAvg := nz(Pyr_XEquAvg[1])
Pyr_XPctTot = 0.0, Pyr_XPctTot := nz(Pyr_XPctTot[1])
Pyr_XPctAvg = 0.0, Pyr_XPctAvg := nz(Pyr_XPctAvg[1])

// ————— All PEA (Post-Exit Analyses).
// Total analyses.
PEA_Analyses = 0, PEA_Analyses := nz(PEA_Analyses[1])
// Bars to max opportunity reached (total to build avg).
PEA_BarsToMaxOppTot = 0, PEA_BarsToMaxOppTot := nz(PEA_BarsToMaxOppTot[1])
// Bars to largest drawdown reached (total to build avg).
PEA_BarsToMaxRiskTot = 0, PEA_BarsToMaxRiskTot := nz(PEA_BarsToMaxRiskTot[1])
// Maximum drawdown incurred before reaching max opportunity (X) (total to build avg).
PEA_MaxDrawdownTot = 0.0, PEA_MaxDrawdownTot := nz(PEA_MaxDrawdownTot[1])
// Maximum opportunity reached during analysis (X) (total to build avg).
PEA_MaxOppReachedTot = 0.0, PEA_MaxOppReachedTot := nz(PEA_MaxOppReachedTot[1])
// Maximum risk reached during analysis (X) (total to build avg).
PEA_MaxRiskReachedTot = 0.0, PEA_MaxRiskReachedTot := nz(PEA_MaxRiskReachedTot[1])

// ————— Risk/Equity management.
// Starting Equity in the script is represented as value 1.0. It is converted at display time in units of currency
// corresponding to whatever the user thinks he's using in the "Initial Capital" field.
// Equity = Initial Capital + P&L. If equity reaches 0.0, ruin occurs and no more trades are entered.
Equity = na, Equity := nz(Equity[1], 1.0)
// Current ROI.
ReturnOnEquity = 0.0, ReturnOnEquity := nz(ReturnOnEquity[1])
// True if ruin occurs.
Ruin = false, Ruin := Ruin[1]

// ————— Close to close max drawdown (only measured from trade close to trade close).
// Max and min close to close equity points, and end of trade max drawdown reached. Reset min when new high encountered.
CToCEquityMax = 0.0
CToCEquityMin = 0.0
CToCDrawdown = 0.0
// Max close to close drawdown in equity.
CToCMaxDrawdown = 0.0, CToCMaxDrawdown := nz(CToCMaxDrawdown[1])

// ————— Max drawdown (measured at every in-trade bar).
// This max drawdown calc needs to maintain separate max and min equity points.
// We are re-evaluating the max and min at each in-trade bar.
// All-time in-trade equity high and min. Min resets when new high encountered.
EquityMin = 0.0, EquityMin := nz(EquityMin[1])
EquityMax = 0.0, EquityMax := nz(EquityMax[1])
Drawdown = 0.0
// Max drawdown in equity.
MaxDrawdown = 0.0, MaxDrawdown := nz(MaxDrawdown[1])
// Equity update in-trade to provide full equity max drawdown instead of close to close drawdown.
InTradeEquity = 0.0, InTradeEquity := nz(InTradeEquity[1])
InTradeStartEquity = 0.0, InTradeStartEquity := nz(InTradeStartEquity[1])


// ———————————————————— B. Local data.
// "Local" refers to data that is maintained while a trade is open or a PEA is ongoing.
// ————— Trade management.
// Entry level (open of bar following trigger).
EntryOrder = 0.0, EntryOrder := EntryOrder[1]
// Entry price after slippage.
EntryFill = 0.0, EntryFill := EntryFill[1]
// Stop level at Entry.
EntryStop = 0.0, EntryStop := EntryStop[1]
// Entry stop amplitude in quote, from fill to stop (so includes slippage).
EntryX = 0.0, EntryX := EntryX[1]
// Entry stop as % of entry fill.
EntryXPct = 0.0, EntryXPct := EntryXPct[1]
// Entry stop (equ).
EntryXEqu = 0.0, EntryXEqu := EntryXEqu[1]
// Exit level (order).
ExitOrder = 0.0, ExitOrder := ExitOrder[1]
// Exit fill after slippage.
ExitFill = 0.0, ExitFill := ExitFill[1]
// Fees paid on entry (equ).
FeesPaidIn = 0.0, FeesPaidIn := FeesPaidIn[1]
// Fees paid on exit (equ).
FeesPaidOut = 0.0, FeesPaidOut := FeesPaidOut[1]
// Holds last issued entry signal: + for longs, - for shorts.
LastEntryNumber = 0, LastEntryNumber := LastEntryNumber[1]
// Last entry's price level, whether it was a normal or pyramided entry.
LastEntryPrice = 0.0, LastEntryPrice := LastEntryPrice[1]
// Position size at entry (equ).
PositionIn = 0.0, PositionIn := PositionIn[1]
// Position size at exit (equ).
PositionOut = 0.0, PositionOut := PositionOut[1]
// Slippage incurred on entry (quote).
SlipPaidIn = 0.0, SlipPaidIn := SlipPaidIn[1]
// Slippage incurred on exit (quote).
SlipPaidOut = 0.0, SlipPaidOut := SlipPaidOut[1]
// Total trade slippage (equ).
SlippageEqu = 0.0, SlippageEqu := SlippageEqu[1]
// Target level for hard exits.
TakeProfitLevel = 0.0, TakeProfitLevel := TakeProfitLevel[1]
// Trade length in bars.
TradeLength = 0, TradeLength := TradeLength[1]
// Max in-trade drawdown.
TradeMaxDrawdown = 0.0, TradeMaxDrawdown := TradeMaxDrawdown[1]

EntryNumber = 0         // Current first entry number throughout trade.
EntryNumberA = 0        // Current first entry number from selecton A.
EntryNumberB = 0        // Current first entry number from selecton B.
InTradeStop = 0.0       // Last valid in-trade stop (we always use previous bar's stop for comparison to price, so must be used indexed).
MaxReached = 0.0        // Max high/low reached since beginning of trade.
MinReached = 0.0        // Min high/low reached since beginning of trade.
TradeDrawdown = 0.0     // Discrete drawdown at each bar in trade's history, to be used to determine trade max drawdown.
TradePLX = 0.0          // Trade PL (X), after slippage.
TradePLXMax = 0.0       // Highest PL (X) reached during trade.
TradePLXMin = 0.0       // Lowest PL (X) reached during trade.
TradePLPct = 0.0       // Trade PL (%) after slippage.
TradePLEqu = 0.0        // Net trade PL (equ), i.e. including slippage AND fees.

// ————— Pyramiding.
PyrEntries = 0, PyrEntries := nz(PyrEntries[1])
PyrEntryBarTot = 0, PyrEntryBarTot := nz(PyrEntryBarTot[1])
PyrEntryBarAvg = 0.0, PyrEntryBarAvg := nz(PyrEntryBarAvg[1])
PyrEntryFill = 0.0
PyrEntryFillTot = 0.0, PyrEntryFillTot := nz(PyrEntryFillTot[1])
PyrEntryFillAvg = 0.0, PyrEntryFillAvg := nz(PyrEntryFillAvg[1])
PyrEntryOrder = 0.0
PyrEntryX = 0.0, PyrEntryX := nz(PyrEntryX[1])
PyrEntryXTot = 0.0, PyrEntryXTot := nz(PyrEntryXTot[1])
PyrEntryXAvg = 0.0, PyrEntryXAvg := nz(PyrEntryXAvg[1])
PyrEntryXPctTot = 0.0, PyrEntryXPctTot := nz(PyrEntryXPctTot[1])
PyrEntryXPctAvg = 0.0, PyrEntryXPctAvg := nz(PyrEntryXPctAvg[1])
PyrFeesEquTot = 0.0, PyrFeesEquTot := nz(PyrFeesEquTot[1])
PyrFeesPaidIn = 0.0
PyrFeesPaidOut = 0.0
PyrEntryXPct = 0.0
PyrPositionIn = 0.0
PyrPositionOut = 0.0
PyrPositionInTot = 0.0, PyrPositionInTot := nz(PyrPositionInTot[1])
PyrPositionInAvg = 0.0, PyrPositionInAvg := nz(PyrPositionInAvg[1])
PyrPositionInQtyTot = 0.0, PyrPositionInQtyTot := nz(PyrPositionInQtyTot[1])
PyrSlipPaidEqu = 0.0
PyrSlipPaidIn = 0.0
PyrSlipPaidOut = 0.0
PyrSlipEquTot = 0.0, PyrSlipEquTot := nz(PyrSlipEquTot[1])
PyrTradePLX = 0.0
PyrTradePLPct = 0.0
PyrTradePLEqu = 0.0
PyrTradeLengthsTot = 0, PyrTradeLengthsTot := nz(PyrTradeLengthsTot[1])
PyrTradeLengthsAvg = 0.0, PyrTradeLengthsAvg := nz(PyrTradeLengthsAvg[1])

// ————— PEA (Post-Exit Analysis).
// True if PEA analysis is for a long trade.
PEAInLong = false, PEAInLong := nz(PEAInLong[1])
// Bar counts saves.
PEABarToMaxOpp = 0, PEABarToMaxOpp := nz(PEABarToMaxOpp[1])
PEABarToMaxRisk = 0, PEABarToMaxRisk := nz(PEABarToMaxRisk[1])
// Level saves.
PEAMaxOppReached = 0.0, PEAMaxOppReached := nz(PEAMaxOppReached[1])
PEAMaxRiskReached = 0.0, PEAMaxRiskReached := nz(PEAMaxRiskReached[1])
PEAMaxDrawdown = 0.0, PEAMaxDrawdown := nz(PEAMaxDrawdown[1])
// Reference level against which opp and risk are measured (close of starting bar of the PEA).
PEAReferenceLevel = 0.0, PEAReferenceLevel := nz(PEAReferenceLevel[1])
// X (quote) for current analysis.
PEAX = 0.0, PEAX := nz(PEAX[1])
// Current bar in analysis.
PEABar = 0, PEABar := nz(PEABar[1])
// Target we are looking for.
PEATarget = 0.0, PEATarget := nz(PEATarget[1])
// True while analysis is ongoing.
InPEA = false, InPEA := nz(InPEA[1])


// ———————————————————— C. State and misc vars.
// These variables get updated after triggers and during trades.
// They do not require propagation because they are derived from the state of other propagated information or previous states.
EntryTrigger = false            // True when an entry trigger is detected.
ExitTrigger = false             // True when an exit trigger is detected
PyramidEntry = false            // True when a long/short pyramid entry occurs.
InTrade = false                 // True when in InLong or InShort is true.
ExitCondition = false           // True when stop breached, take profit or target level reached.
// ————— Longs
LongEntryTrigger = false        // Becomes true on the bar when entry order is to be issued; false otherwise.
InLong = false                  // True from bar after entry trigger to bar of exit trigger, inclusively.
// ————— Shorts
ShortEntryTrigger = false       // Becomes true on the bar when entry order is to be issued; false otherwise.
InShort = false                 // True from bar after entry trigger to bar of exit trigger, inclusively.
// Fixed fees converted to (equ), for use with FeesType3 option.
FeesType3In = 0.0, FeesType3In := nz(FeesType3In[1],FeesType3InVal/PosTypeCapital)
FeesType3Out = 0.0, FeesType3Out := nz(FeesType3Out[1],FeesType3OutVal/PosTypeCapital)



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// —————————————————————————————————————— 2. Indicators and Functions —————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// This module contains indicators typically used by more than one strat or that contain too much code to be included
// in the module where it is used without distracting from the rest.

// ———————————————————— Chandelier for In-Trade Stop 6 (Thx to Alex Orekhov aka @everget).
// Note that for both of these Chandeliers, the stop will not be allowed to go against the trade,
// as it normally could, because of the assembly rules that prevent it.
Catr = InTradeStopType567Mult * atr(InTradeStopType567Len)
Clong = highest(InTradeStopType567Len) - Catr
Cshort = lowest(InTradeStopType567Len) + Catr
ClongStop = 0.0, ClongStop := close[1] > ClongStop[1] ? max(Clong, ClongStop[1]) : Clong
CshortStop = 0.0, CshortStop := close[1] < CshortStop[1] ? min(Cshort, CshortStop[1]) : Cshort

// ———————————————————— Chandelier for Filter 10 (Thx to Alex Orekhov aka @everget).
C2atr = FilterType10Mult * atr(FilterType10Len)
C2long = highest(FilterType10Len) - C2atr
C2short = lowest(FilterType10Len) + C2atr
C2longStop = 0.0, C2longStop := close[1] > C2longStop[1] ? max(C2long, C2longStop[1]) : C2long
C2shortStop = 0.0, C2shortStop := close[1] < C2shortStop[1] ? min(C2short, C2shortStop[1]) : C2short
C2dir = 1, C2dir := close > C2shortStop[1] ? 1 : close < C2longStop[1] ? -1 : nz(C2dir[1], C2dir)
C2Bull = C2dir==1, C2Bear = not C2Bull

// ———————————————————— Donchian center line used in Entry 6, Filter 8, In-Trade Stop 4 (Thx to @admin).
donchian(_len) => avg(lowest(_len), highest(_len))

// ———————————————————— MA Squize used in Filter 11 (Thx to @glaz).
MAsThreSHoldPips = 15, ATRmode = true, ATRperiod = 50, ATRmultipl = 0.4
delta = 0.0, SqLup = na, SqLdn = na
upma = ema(close,FilterType11Len1), dnma = ema(close,FilterType11Len2), madif = abs(upma-dnma)
delta := ATRmode? atr(ATRperiod) * ATRmultipl/syminfo.mintick : MAsThreSHoldPips
if (madif/syminfo.mintick<delta)
    SqLup := dnma + delta*syminfo.mintick 
    SqLdn := dnma - delta*syminfo.mintick 
MASqzBull = na(SqLup) and upma>dnma
MASqzBear = na(SqLup) and upma<dnma
// Plots are there in case you want to see what MA Squize looks like.
// plot(upma,color=lime,linewidth=2,transp=0)
// plot(dnma,color=red,linewidth=2,transp=0)
// plot(SqLup,color=yellow,linewidth=4,style=linebr,transp=0)
// plot(SqLdn,color=red,linewidth=4,style=linebr,transp=0)

// ———————————————————— Function used to increment counters by 1 using boolean criterion.
OneZero( _test) => 
    _return = _test? 1:0

// ———————————————————— Pseudo-random generator function used for Entry 1, Filter 1 and Exit 1 (Thx to the King, @RicardoSantos).
f_pseudo_random_number(_range, _seed)=>
    _return = 1.0
    if na(_seed)
        _return := 3.14159 * nz(_return[1], 1) % n
    else
        _return := 3.14159 * nz(_return[1], 1) % (n + _seed)
    _return := _return % (_range)

// ———————————————————— Function used to round values.
Round( _val, _decimals) => 
    // Rounds _val to _decimals places.
    _p = pow(10,_decimals)
    round(abs(_val)*_p)/_p*sign(_val)

// ———————————————————— Function used to round prices to tick size everywhere we calculate prices.`
// In places where it is not used, most of the time it's because it isn't relevant or because value will be rounded further down the logic line.
RoundToTick( _price) => round(_price/syminfo.mintick)*syminfo.mintick

// ———————————————————— Volatility Stop for In-Trade Stop 7 (Thx to @admin for original and @BobHoward21 for v3).
VSvsmult = InTradeStopType567Mult, VSatr_ = atr(InTradeStopType567Len)
VSmax1 = 0.0, VSmin1 = 0.0, VSstop = 0.0, VSvstop_prev = 0.0, VSvstop1 = 0.0, VSmax_ = 0.0, VSmin_ = 0.0, VSvstop = 0.0
VSis_uptrend_prev = false, VSis_uptrend = false, VSis_trend_changed = false
VSmax1 := max(nz(VSmax_[1]), close), VSmin1 := min(nz(VSmin_[1]), close)
VSis_uptrend_prev := nz(VSis_uptrend[1], true)
VSstop := VSis_uptrend_prev ? VSmax1 - VSvsmult * VSatr_ : VSmin1 + VSvsmult * VSatr_
VSvstop_prev := nz(VSvstop[1])
VSvstop1 := VSis_uptrend_prev ? max(VSvstop_prev, VSstop) : min(VSvstop_prev, VSstop)
VSis_uptrend := close - VSvstop1 >= 0
VSis_trend_changed := VSis_uptrend != VSis_uptrend_prev
VSmax_ := VSis_trend_changed ? close : VSmax1, VSmin_ := VSis_trend_changed ? close : VSmin1
VSvstop := VSis_trend_changed ? VSis_uptrend ? VSmax_ - VSvsmult * VSatr_ : VSmin_ + VSvsmult * VSatr_ : VSvstop1



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ——————————————————————————————————————————— 3. Entry Stops —————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————— OHLC rounded to mintick (used to standardize values across test as mintick sometimes varies during dataset).
// Although situated in this module, are used all over the script.
Ropen   = RoundToTick(open)
Rhigh   = RoundToTick(high)
Rlow    = RoundToTick(low)
Rclose  = RoundToTick(close)
// ————— Lowest/highest of open/close
MinOC = RoundToTick(min(open,close))
MaxOC = RoundToTick(max(open,close))
// ————— Entry Stops init.
EntryStopLong = MinOC
EntryStopShort = MaxOC
// Entry Stops are pre-calculated every bar so they are always at hand upon entering.
// They cannot depend on information like a trade entry level as they must be calculated prior to entry.
// The entry stop wil be taken over by the In-trade stop when its kick-in rules allow for it.
// ————— Entry Stop 1: External Indicator
EntryStop1Val = ExternalIndie[1]
EntryStop1Long = EntryStop1Val>0 and EntryStop1Val!=1.0 and EntryStop1Val!=2.0 and EntryStop1Val!=3.0 ? EntryStop1Val : na
EntryStop1Short = EntryStop1Val<0 and EntryStop1Val!=-1.0 and EntryStop1Val!=-2.0 and EntryStop1Val!=-3.0 ? -EntryStop1Val : na
// ————— Entry Stop 2: ATR*Multiple
EntryStop2_Atr = nz(atr(EntryStopType2Len))
EntryStop2_AtrGap = EntryStop2_Atr*EntryStopType2Mult
EntryStop2Long = MinOC-EntryStop2_AtrGap
EntryStop2Short = MaxOC+EntryStop2_AtrGap
// ————— Entry Stop 3: Fixed Percent
EntryStop3Long = MinOC*(1.0-(EntryStopType3Pct/100))
EntryStop3Short = MaxOC*(1.0+(EntryStopType3Pct/100))
// ————— Entry Stop 4: Fixed value
EntryStop4Long = max(MinOC-EntryStopType4Val,0.0)
EntryStop4Short = MaxOC+EntryStopType4Val

// ———————————————————— Select Entry Stop chosen by user.
EntryStopLong_ = EntryStopType1? EntryStop1Long : EntryStopType2? EntryStop2Long : EntryStopType3? EntryStop3Long : EntryStopType4? EntryStop4Long : 0.0
EntryStopShort_ = EntryStopType1? EntryStop1Short : EntryStopType2? EntryStop2Short : EntryStopType3? EntryStop3Short : EntryStopType4? EntryStop4Short : 0.0
// Round stop to tick size.
EntryStopLong := RoundToTick(EntryStopLong_)
EntryStopShort := RoundToTick(EntryStopShort_)



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————————————————————————————————————————————— 4. Filters ———————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————— Filter 1: Random
Filter1Long = FilterType1? round( f_pseudo_random_number(FilterType1Freq, 0.5))==1 : true
Filter1Short = FilterType1? round( f_pseudo_random_number(FilterType1Freq, 0.6))==1 : true
// ————— Filter 2: External indicator (thx to @RicardoSantos and @theheirophant via @simpelyfe for the idea)
// Indicator must supply us with: Bull=1.0, Bear=-1.0.
Filter2Long = FilterType2? ExternalIndie==1.0 : true
Filter2Short = FilterType2? ExternalIndie==-1.0 : true
// ————— Filter 3: Bar direction
Filter3Long = FilterType3? close>open : true
Filter3Short = FilterType3? close<open : true
// ————— Filter 4: Rising volume
Filter4Long = FilterType4? rising(volume,1) : true
Filter4Short = Filter4Long
// ————— Filter 5: Rising/Falling MA
Filter5Ma = nz(sma(close,FilterType5Len))
Filter5Long = FilterType5? rising(Filter5Ma,FilterType5Bars) : true
Filter5Short = FilterType5? falling(Filter5Ma,FilterType5Bars) : true
// ————— Filter 6: Maximum risk allowed at entry
Filter6Long = FilterType6? close-EntryStopLong<close*FilterType6MaxRisk/100 : true
Filter6Short = FilterType6? EntryStopShort-close<close*FilterType6MaxRisk/100 : true
// ————— Filter 7: Maximum delta with previous close allowed at entry
Filter7Long = FilterType7? close<close[1]*(1+FilterType7IncPct/100) : true
Filter7Short = FilterType7? close>close[1]*(1-FilterType7IncPct/100) : true
// ————— Filter 8: Ichimoku with big settings
FIchiDisplacement = 30, FTenkan = donchian(20), FKijun = donchian(60)
FKumoA = avg(FTenkan, FKijun), FKumoB = donchian(120)
FKumoANow = FKumoA[FIchiDisplacement], FKumoBNow = FKumoB[FIchiDisplacement], FKumoNowHigh = max(FKumoANow,FKumoBNow)
FilterIchiBull = (FKumoA>FKumoB and FKumoANow>FKumoBNow and close>FKumoNowHigh) or (FTenkan>FKijun and FKijun>FKumoNowHigh and FTenkan>FKumoNowHigh and close>FKumoNowHigh) and rising(FKijun,1) and rising(FTenkan,1)
FilterIchiBear = (FKumoA<FKumoB and FKumoANow<FKumoBNow and close<FKumoNowHigh) or (FTenkan<FKijun and FKijun<FKumoNowHigh and FTenkan<FKumoNowHigh and close<FKumoNowHigh) and falling(FKijun,1) and falling(FTenkan,1)
Filter8Long = FilterType8? FilterIchiBull : true
Filter8Short = FilterType8? FilterIchiBear : true
// ————— Filter 9: RSI OS/OB
Rsi = rsi(close, FilterType9Len), RsiOS = Rsi<FilterType9OS, RsiOB = Rsi>FilterType9OB
Filter9Long = FilterType9? not RsiOB : true
Filter9Short = FilterType9? not RsiOS : true
// ————— Filter 10: Chandelier
Filter10Long = FilterType10? C2Bull : true
Filter10Short = FilterType10? C2Bear : true
// ————— Filter 11: MA Squize
Filter11Long = FilterType11? MASqzBull : true
Filter11Short = FilterType11? MASqzBear : true

// ———————————————————— Assemble filters
FilterLongOK = false
FilterShortOK = false
FilterLongOK := Filter1Long and Filter2Long and Filter3Long and Filter4Long and Filter5Long and Filter6Long and Filter7Long and Filter8Long and Filter9Long and Filter10Long and Filter11Long
FilterShortOK := Filter1Short and Filter2Short and Filter3Short and Filter4Short and Filter5Short and Filter6Short and Filter7Short and Filter8Short and Filter9Short and Filter10Short and Filter11Short



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————————————————————————————————————————————— 5. Entries ———————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
// ————— Entry 1A: Random
Entry1ALong = EntryType1A and round(f_pseudo_random_number(EntryType1Freq, 0.1))==1
Entry1AShort = EntryType1A and round(f_pseudo_random_number(EntryType1Freq, 0.2))==1
// ————— Entry 1B: Random
Entry1BLong = EntryType1B and round(f_pseudo_random_number(EntryType1Freq, 0.25))==1
Entry1BShort = EntryType1B and round(f_pseudo_random_number(EntryType1Freq, 0.15))==1
// ————— Entry 2: External Indicator
Entry2Long = EntryType2 and ExternalIndie>0.0 and ExternalIndie!=1.0 and ExternalIndie!=3.0
Entry2Short = EntryType2 and ExternalIndie<0.0 and ExternalIndie!=-1.0 and ExternalIndie!=-3.0
// ————— Entry 3: Filter Transitions
// Only enter when filter transitions into bull/bear.
Entry3Long = EntryType3 and FilterLongOK and not FilterLongOK[1]
Entry3Short = EntryType3 and FilterShortOK and not FilterShortOK[1]
// ————— Entry 4: Filter States
// Enter whenever we are not in a trade and filter is bull/bear.
Entry4Long = EntryType4 and not InTrade and FilterLongOK
Entry4Short = EntryType4 and not InTrade and FilterShortOK
// ————— Entry 5: RSI Crosses
Entry5Rsi = rsi(close, EntryType5Len)
Entry5Long = EntryType5 and crossover(Entry5Rsi, EntryType5LongLvl)
Entry5Short = EntryType5 and crossunder(Entry5Rsi, EntryType5ShortLvl)
// ————— Entry 6: Tenkan/Kijun Crosses
Entry6Tenkan = donchian(EntryType6TLen)
Entry6Kijun = donchian(EntryType6KLen)
Entry6Long = EntryType6 and crossover(Entry6Tenkan, Entry6Kijun)
Entry6Short = EntryType6 and crossunder(Entry6Tenkan, Entry6Kijun)

// ———————————————————— Get entry number (positive for longs, negative for shorts).
// Distinguish between A and B selections.
EntryNumberA := 
  Entry1ALong and EntryA==EN1? 1 : Entry2Long and EntryA==EN2? 2 : Entry3Long and EntryA==EN3? 3 : Entry4Long and EntryA==EN4? 4 : Entry5Long and EntryA==EN5? 5 : Entry6Long and EntryA==EN6? 6 : 
  Entry1AShort and EntryA==EN1? -1 : Entry2Short and EntryA==EN2? -2 : Entry3Short and EntryA==EN3? -3 : Entry4Short and EntryA==EN4? -4 : Entry5Short and EntryA==EN5? -5 : Entry6Short and EntryA==EN6? -6 : 0
EntryNumberB := 
  Entry1BLong and EntryB==EN1? 1 : Entry2Long and EntryB==EN2? 2 : Entry3Long and EntryB==EN3? 3 : Entry4Long and EntryB==EN4? 4 : Entry5Long and EntryB==EN5? 5 : Entry6Long and EntryB==EN6? 6 : 
  Entry1BShort and EntryB==EN1? -1 : Entry2Short and EntryB==EN2? -2 : Entry3Short and EntryB==EN3? -3 : Entry4Short and EntryB==EN4? -4 : Entry5Short and EntryB==EN5? -5 : Entry6Short and EntryB==EN6? -6 : 0
// Entry A numbers are as is, entry B numbers get 100 added/subtracted.
EntryNumber := EntryNumberA!=0? EntryNumberA : EntryNumberB!=0? EntryNumberB+(EntryNumberB>0?100:-100) : 0
// States used to print markers.
EntryIsALong = EntryNumberA>0
EntryIsBLong = not EntryIsALong and EntryNumberB>0
EntryIsAShort = EntryNumberA<0
EntryIsBShort = not EntryIsAShort and EntryNumberB<0



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————————————————————————————————— 6. Trade Entry and In-trade Processing ———————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Here we:
//  A. Process 1st entries.
//  B. Process pyramided entries.
//  C. Update in-trade numbers for display purposes.

// ———————————————————— Trade state management
// ————— Determine if we have entered a trade and propagate state until we exit.
InLong := LongEntryTrigger[1] or (InLong[1] and not ExitCondition[1])
InShort := ShortEntryTrigger[1] or (InShort[1] and not ExitCondition[1])
// ————— Merge states for ease of logical testing.
InTrade := InLong or InShort
FirstEntry1stBar = EntryTrigger[1] and not PyramidEntry[1]
PyramidEntry1stBar = EntryTrigger[1] and PyramidEntry[1]

// ———————————————————— A. Process 1st entries.
// ————— If a trade's first entry (as opposed to pyramiding entries) must be entered, process it.
// While this code appears earlier in the script than the entry trigger detection that comes in module 10,
// it is only executed at the bar following the one where the trigger is detected.
if FirstEntry1stBar
    // ————— Handle trade-opening tasks.
    // Suppose market entry order is given at open.
    EntryOrder := Ropen
    // Begin counting trade length.
    TradeLength := 1
    // Reset max and min point reached during trade.
    MaxReached := InLong? Rhigh:Rlow
    MinReached := InLong? Rlow:Rhigh
    // Save last issued signal number.
    LastEntryNumber := EntryNumber[1]

    // Calculate what slippage should be before hi/lo constraints.
    SlipPaidIn := (SlippageType2? RoundToTick(EntryOrder*SlippageType2InPct/100) : SlippageType3? RoundToTick(SlippageType3InVal) : 0.0)
    // Entry fill price including tentative slippage.
    EntryFill := max(0.0, EntryOrder + (InLong? SlipPaidIn:-SlipPaidIn))
    // Cap fill to bar's hi/lo (can't slip more/less that hi/lo).
    EntryFill := InLong? min(Rhigh, EntryFill) : max(Rlow, EntryFill)
    // Calculate actual slippage.
    SlipPaidIn := abs(EntryFill-EntryOrder)
    // Save fill for pyramiding rules validations.
    LastEntryPrice := EntryFill
    // Initialized upon entry and constant throughout trade, InTradeStop will usually take over in further trade management.
    EntryStop := InLong ? EntryStopLong : EntryStopShort
    // ————— Calculate X upon entry.
    // This amplitude in quote currency is the fundamental unit of risk for the trade, which we call X.
    // We also keep a version of it expressed as a % of the entry fill, and another in equ. Notice that entry slippage affects the size of X.
    EntryX := abs(EntryFill-EntryStop)
    EntryXPct := EntryX/EntryFill
    
    // PositionIn size is determined according to user selection: Type 1 for relative pos size and fixed risk. Type 2 for fixed % of Equity. Type 3 for fixed % of initial capital.
    PositionIn := min(Equity, PosType1? min(Equity*PosType1Cap/100, Equity*PosType1Risk/100/EntryXPct) : PosType2? Equity*PosType2Pct/100 : PosType3Pct/100)
    // % Fees are calculated on the PositionIn size. Fixed fees are in equ. Either way they end up being expressed in equ and will only later be deducted from trade's PL and Equity.
    FeesPaidIn := (FeesType2? PositionIn*FeesType2InPct/100 : FeesType3? FeesType3In : 0.0)
    // X (equ).
    EntryXEqu := PositionIn*EntryXPct
    // Convert slippage to equ units for display during trade.
    SlippageEqu := SlipPaidIn/EntryOrder*PositionIn    

    ExitOrder := 0.0
    ExitFill := 0.0
    TakeProfitLevel := na
    TradePLX := 0.0
    TradePLPct := 0.0
    TradePLEqu := 0.0
    TradePLXMax := 0.0
    TradePLXMin := 0.0
    SlipPaidOut := 0.0
    FeesPaidOut := 0.0
    TradeMaxDrawdown := 0.0
    
    // Going to use this temp value to watch for a new maximum equity drawdown during the trade,
    // leaving the real Equity unchanged until the end of the trade.
    InTradeStartEquity := Equity
    InTradeEquity := Equity
else
    // ———————————————————— B. Process pyramided entries.
    if PyramidEntry1stBar
        // Count of pyramids in current trade.
        PyrEntries := PyrEntries+1
        // Cumulative count of TLs for all pyramided entries. Adds 1 per bar per active entry.
        PyrTradeLengthsTot := PyrTradeLengthsTot+PyrEntries
        PyrTradeLengthsAvg := PyrTradeLengthsTot/PyrEntries
        // Suppose market entry order is given at open.
        PyrEntryOrder := Ropen
        // Add slippage to entry.
        PyrSlipPaidIn := (SlippageType2? RoundToTick(PyrEntryOrder*SlippageType2InPct/100) : SlippageType3? RoundToTick(SlippageType3InVal) : 0.0)
        // Entry fill price including slippage.
        PyrEntryFill := max(0.0, PyrEntryOrder + (InLong? PyrSlipPaidIn:-PyrSlipPaidIn))
        // Cap fill to hi/lo.
        PyrEntryFill := InLong? min(Rhigh, PyrEntryFill) : max(Rlow, PyrEntryFill)
        // Update X. Need to use previous bar's in-trade stop as current one isn't calculated yet.
        PyrEntryX := abs(PyrEntryFill-InTradeStop[1])
        // Update X%. 
        PyrEntryXPct := PyrEntryX/PyrEntryFill
        // PositionIn size is determined according to user selection: Type 1 for relative pos size and fixed risk. Type 2 for fixed % of Equity. Type 3 for fixed % of initial capital.
        PyrPositionIn := PyramidingPosMult*min(Equity, PosType1? min(Equity*PosType1Cap/100, Equity*PosType1Risk/100/EntryXPct) : PosType2? Equity*PosType2Pct/100 : PosType3Pct/100)
        // Also keep position size in units of asset.
        PyrPositionInQty = PyrPositionIn*PosTypeCapital/PyrEntryFill
        // % Fees are calculated on the PositionIn size. Fixed fees are in equ. Either way they end up being expressed in equ and will only later be deducted from trade's PL and Equity.
        PyrFeesPaidIn := (FeesType2? PyrPositionIn*FeesType2InPct/100 : FeesType3? FeesType3In : 0.0)
        // X (equ).
        // PyrEntryXEqu := PyrPositionIn*PyrEntryXPct
        // Convert slippage in equ.
        PyrSlipPaidEqu := PyrSlipPaidIn/PyrEntryOrder*PyrPositionIn
       
        // ————— Build totals and avgs for all pyramided entries in current trade.
        // X (quote)
        PyrEntryXTot := PyrEntryXTot+PyrEntryX
        PyrEntryXAvg := PyrEntryXTot/PyrEntries
        // X %
        PyrEntryXPctTot := PyrEntryXPctTot+PyrEntryXPct
        PyrEntryXPctAvg := PyrEntryXPctTot/PyrEntries
        // Entry positions.
        PyrPositionInTot := PyrPositionInTot+PyrPositionIn
        PyrPositionInAvg := PyrPositionInTot/PyrEntries
        PyrPositionInQtyTot := PyrPositionInQtyTot+PyrPositionInQty
        // Average fill.
        PyrEntryFillTot := PyrEntryFillTot+PyrEntryFill
        PyrEntryFillAvg := PyrEntryFillTot/PyrEntries
        // 1st entry's TL at pyr entry point. Use +1 because it hasn't been incremented yet!
        PyrEntryBarTot := PyrEntryBarTot+TradeLength+1
        PyrEntryBarAvg := PyrEntryBarTot/PyrEntries
        // Fees & Slippage.
        PyrFeesEquTot := PyrFeesEquTot + PyrFeesPaidIn
        PyrSlipEquTot := PyrSlipEquTot + PyrSlipPaidEqu
        // Save last entry price to then calculate subsequent pyramiding rules.
        LastEntryPrice := PyrEntryFill


    // ———————————————————— C. Update in-trade info. Also update some numbers for display purposes.
    if InTrade
        // ————— Update essential in-trade info.
        // Increase trade length.
        TradeLength := TradeLength+1
        // Update Max point reached during trade (used both for trailing stop reference point and in-trade max drawdown calcs).
        MaxReached := InLong ? max(nz(MaxReached[1], Rhigh), Rhigh) : InShort ? min(nz(MaxReached[1], Rlow), Rlow) : na
        
        // ————— Update in-trade max drawdown info (has nothing to do with max drawdown calcs later in this section).
        // Since we only use the Min point to calculate in-trade max drawdown, reset it when a new max is found.
        MinReached := change(MaxReached)? MaxReached : InLong ? min(nz(MinReached[1], Rlow), Rlow) : InShort ? max(nz(MinReached[1], Rhigh), Rhigh) : na
        // Record current drawdown to build history of all drawdowns during trade.
        TradeDrawdown := min(0.0,(MaxReached-MinReached)*(InLong[1]?-1:1)/MaxReached)
        // Find largest drawdown during trade.
        TradeMaxDrawdown := min(TradeMaxDrawdown, TradeDrawdown)
        
        // ————— Simulate a complete exit from close here to display provisional trade info.
        // In this "display only mode" during trade, fees paid in or out are ignored. They will only be included in results at real exit.
        ExitOrder := Ropen
        // Calculate tentative slippage from Exit order level.
        SlipPaidOut := (SlippageType2? RoundToTick(ExitOrder*SlippageType2OutPct/100) : SlippageType3? RoundToTick(SlippageType3OutVal) : 0.0)
        // Calculate Exit Fill including slipppage, protecting against negative values.
        ExitFill := max(0.0, ExitOrder + (InLong[1]? -SlipPaidOut:SlipPaidOut))
        // Fill cannot be outside hi/lo.
        ExitFill := InLong[1]? max(Rlow, ExitFill) : min(Rhigh, ExitFill)
        // Calculate slippage that actually occured.
        SlipPaidOut := abs(ExitFill-ExitOrder)
        // Net P&L including slippage and fees.
        TradePLX := (ExitFill-EntryFill)*(InLong[1]?1:-1)/EntryX
        // Highest/LOwest PL (mult of X) reached during trade.
        TradePLXMax := max(TradePLX, TradePLXMax[1])
        TradePLXMin := min(TradePLX, TradePLXMin[1])
        // Trade P&L in %.
        TradePLPct := TradePLX*EntryXPct
        // Trade P&L in equity units.
        TradePLEqu := PositionIn*TradePLX*EntryXPct
        // Add initial position size to P&L to get exit position before fees.
        PositionOut := TradePLEqu + PositionIn
        // Convert slippage into equity units.
        SlippageEqu := SlipPaidIn/EntryOrder*PositionIn + SlipPaidOut/ExitOrder*PositionOut
        // Calculate a pseudo equity value given current trade result.
        InTradeEquity := InTradeStartEquity + PositionOut - PositionIn

        // ————— Process active pyramided entries info.
        if PyrEntries>0
            // ————— Update active pyramided entries informations.
            // Add 1 in length for each pyr entry, but don't add if pyr entry made on this bar, as total already updated.
            PyrTradeLengthsTot := PyrTradeLengthsTot + (PyramidEntry1stBar? 0 : PyrEntries)
            PyrTradeLengthsAvg := PyrTradeLengthsTot/PyrEntries
            // Update following numbers for display purposes only, without worrying about fees.
            PyrPositionOut := PyrPositionInQtyTot*ExitFill/PosTypeCapital
            PyrTradePLEqu := ((PyrPositionOut-PyrPositionInTot)*(InLong[1]?1:-1))
            PyrTradePLPct := PyrTradePLEqu / PyrPositionInTot
            PyrTradePLX := PyrTradePLPct / PyrEntryXPctAvg



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ———————————————————————————————————————— 7. Pyramiding Rules ———————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Here we evaluate the rules determining if pyramiding is allowed.
// ————— Pyramiding 1: Once after X multiple.
Pyramiding1Long = PyramidingType1 and Rclose>LastEntryPrice+(EntryX*Pyramiding1MultX)
Pyramiding1Short = PyramidingType1 and Rclose<LastEntryPrice-(EntryX*Pyramiding1MultX)
// ————— Pyramiding 2: Every % increment.
Pyramiding2Long = PyramidingType2 and Rclose>LastEntryPrice*(1+(Pyramiding2Pct/100))
Pyramiding2Short = PyramidingType2 and Rclose<LastEntryPrice*(1-(Pyramiding2Pct/100))
// ————— Pyramiding 3: Every price increment.
Pyramiding3Long = PyramidingType3 and Rclose>LastEntryPrice+Pyramiding3Val
Pyramiding3Short = PyramidingType3 and Rclose<LastEntryPrice-Pyramiding3Val
// ————— Pyramiding 4: Entry number=previous entry number.
Pyramiding4Long = PyramidingType4 and EntryNumber==LastEntryNumber
Pyramiding4Short = Pyramiding4Long
// ————— Pyramiding 5: Entry number<>previous entry number.
Pyramiding5Long = PyramidingType5 and EntryNumber!=LastEntryNumber
Pyramiding5Short = Pyramiding5Long
// ————— Pyramiding 6: All opportunities.
Pyramiding6Long = PyramidingType6
Pyramiding6Short = PyramidingType6

// ———————————————————— Assemble Pyramiding rules.
// In addition to the above rules allowing a pyramided entry, we need to be in a trade and the number of max pyramided entries must not have been reached.
PyramidLongOK = InLong[1] and InLong and PyrEntries<PyramidingMaxCnt and (PyramidingFilterNeeded? FilterLongOK:true) and (Pyramiding1Long or Pyramiding2Long or Pyramiding3Long or Pyramiding4Long or Pyramiding5Long or Pyramiding6Long) 
PyramidShortOK = InShort[1] and InShort and PyrEntries<PyramidingMaxCnt and (PyramidingFilterNeeded? FilterShortOK:true) and (Pyramiding1Short or Pyramiding2Short or Pyramiding3Short or Pyramiding4Short or Pyramiding5Short or Pyramiding6Short)



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ——————————————————————————————————————————— 8. In-trade stops ——————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// We work in 2 steps: first we calculate the stop for each strat,
// then we evaluate the kick in conditions that will determine if the stop we have calculated will be used.
// In all cases a new stop will only replace a previous one if it closer to price, so this logic does not
// currently allow implementing stop strats where the stop moves against price. They won't cause errors; the
// stop will just never go further away from price than the previous one.

// ———————————————————— In-trade stops
// ————— In-Trade Stop 1: Trailing stop using multiple of X% as max deviation
InTradeStop1Long = MaxReached - EntryX*InTradeStopType1Mult
InTradeStop1Short = MaxReached + EntryX*InTradeStopType1Mult
// ————— In-Trade Stop 2: Trailing stop using fixed percentage as max deviation
InTradeStop2Long = MaxReached * (1-InTradeStopType2Pct/100)
InTradeStop2Short = MaxReached * (1+InTradeStopType2Pct/100)
// ————— In-Trade Stop 3: Trailing stop using fixed value as max deviation
InTradeStop3Long = MaxReached - InTradeStopType3Val
InTradeStop3Short = MaxReached + InTradeStopType3Val
// ————— In-Trade Stop 4: Donchian center
InTradeStop4Long = donchian(InTradeStopType4Len)
InTradeStop4Short = donchian(InTradeStopType4Len)
// ————— In-Trade Stop 5: ATR stop
// Calculated using average of 2 preceeding MinOC/MaxOC and ATR gap.
InTradeStop5Atr = atr(InTradeStopType567Len)
InTradeStop5Long = avg(MinOC[1], MinOC[2]) - (InTradeStop5Atr*InTradeStopType567Mult)
InTradeStop5Short = avg(MaxOC[1], MaxOC[2]) + (InTradeStop5Atr*InTradeStopType567Mult)
// ————— In-Trade Stop 6: Chandelier
InTradeStop6Long = ClongStop
InTradeStop6Short = CshortStop
// ————— In-Trade Stop 7: Volatility Stop, but only if it's on right side of trade, otherwise, stay with previous one.
InTradeStop7Long = VSis_uptrend? VSvstop : nz(InTradeStop[1])
InTradeStop7Short = not VSis_uptrend? VSvstop : nz(InTradeStop[1])
// ————— In-Trade Stop 8: Last Lo/Hi
InTradeStop8Long = low[1]
InTradeStop8Short = high[1]

// ————— Select potential new stop.
InTradeStopLong_ = 0.0
InTradeStopShort_ = 0.0
InTradeStopLong_ := InTradeStopType1? InTradeStop1Long : InTradeStopType2? InTradeStop2Long : InTradeStopType3? InTradeStop3Long : InTradeStopType4? InTradeStop4Long : InTradeStopType5? InTradeStop5Long :
  InTradeStopType6? InTradeStop6Long : InTradeStopType7? InTradeStop7Long : InTradeStopType8? InTradeStop8Long : 0.0
InTradeStopShort_ := InTradeStopType1? InTradeStop1Short : InTradeStopType2? InTradeStop2Short : InTradeStopType3? InTradeStop3Short : InTradeStopType4? InTradeStop4Short : InTradeStopType5? InTradeStop5Short : 
  InTradeStopType6? InTradeStop6Short : InTradeStopType7? InTradeStop7Short : InTradeStopType8? InTradeStop8Short : 0.0
// Make sure stop is not on wrong side of the trade.
InTradeStopLong_ := InLong[1] and InTradeStopLong_>Rhigh? nz(InTradeStop[1]) : RoundToTick(InTradeStopLong_)
InTradeStopShort_ := InShort[1] and InTradeStopShort_<Rlow? nz(InTradeStop[1]) : RoundToTick(InTradeStopShort_)


// —————————— Kick In Conditions
// Determine if we can move stop or leave the entry stop behind and start using the in-trade stop.
PreviousStop = nz(InTradeStop[1])
// ————— Kisk In 1: When the stop passes the entry stop.
InTradeKick1Long = InTradeStopLong_>EntryStop
InTradeKick1Short = InTradeStopShort_<EntryStop
// ————— Kisk In 2: When the stop passes Entry +/- X Multiple.
InTradeKick2Long_ = EntryFill+EntryX*InTradeKickType2Mult
InTradeKick2Short_ = EntryFill-EntryX*InTradeKickType2Mult
InTradeKick2Long = InTradeStopLong_>max(RoundToTick(InTradeKick2Long_), EntryStop)
InTradeKick2Short = InTradeStopShort_<min(RoundToTick(InTradeKick2Short_), EntryStop)
// ————— Kisk In 3: When the stop passes Entry +/- %.
InTradeKick3Long_ = EntryFill*(1.0+(InTradeKickType3Pct/100))
InTradeKick3Short_ = EntryFill*(1.0-(InTradeKickType3Pct/100))
InTradeKick3Long = InTradeStopLong_>max(RoundToTick(InTradeKick3Long_), EntryStop)
InTradeKick3Short = InTradeStopShort_<min(RoundToTick(InTradeKick3Short_), EntryStop)
// ————— Kisk In 4: When the stop passes Entry +/- Value.
InTradeKick4Long_ = EntryFill+InTradeKickType4Val
InTradeKick4Short_ = EntryFill-InTradeKickType4Val
InTradeKick4Long = InTradeStopLong_>max(RoundToTick(InTradeKick4Long_), EntryStop)
InTradeKick4Short = InTradeStopShort_<min(RoundToTick(InTradeKick4Short_), EntryStop)

// ————— Select Kick In
InTradeKickLong = InTradeKickType1? InTradeKick1Long : InTradeKickType2? InTradeKick2Long : InTradeKickType3? InTradeKick3Long : InTradeKickType4? InTradeKick4Long : false
InTradeKickShort = InTradeKickType1? InTradeKick1Short : InTradeKickType2? InTradeKick2Short : InTradeKickType3? InTradeKick3Short : InTradeKickType4? InTradeKick4Short : false

// ———————————————————— Assemble In-Trade stop.
// Our potential new stop value is determined. Only use it as new one if it moved in trade direction compared to previous one.
// ————— Set In-trade stop for check on next bar.
// Exceptionally, on entry bar of a trade, init to EntryStop.
InTradeStop_ = FirstEntry1stBar? EntryStop : InLong? InTradeKickLong? max(InTradeStopLong_, nz(InTradeStop[1]))  : nz(InTradeStop[1]) : InTradeKickShort? min(InTradeStopShort_, nz(InTradeStop[1])) : nz(InTradeStop[1])
InTradeStop := max(0.0, InTradeStop_)



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ———————————————————————————————————————————————— 9. Exits ——————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//
// ————— Exit 1: Random
Exit1Long = ExitType1 and round(f_pseudo_random_number(ExitType1Freq, 0.5))==1
Exit1Short = ExitType1 and round(f_pseudo_random_number(ExitType1Freq, 0.6))==2
// ————— Exit 2: External Indicator
Exit2Long = ExitType2 and ExternalIndie==3.0
Exit2Short = ExitType2 and ExternalIndie==-3.0
// ————— Exit 3: Filter Transitions
// Exit when filter transitions into bull/bear.
Exit3Long = ExitType3 and FilterShortOK and not FilterShortOK[1]
Exit3Short = ExitType3 and FilterLongOK and not FilterLongOK[1]
// ————— Exit 4: RSI Crosses
Exit4Rsi = rsi(close, ExitType4Len)
Exit4Long = ExitType4 and crossunder(Exit4Rsi, ExitType4LongLvl)
Exit4Short = ExitType4 and crossover(Exit4Rsi, ExitType4ShortLvl)
// ————— Exit 5: Tenkan/Kijun Crosses
Exit5Tenkan = donchian(ExitType5TLen)
Exit5Kijun = donchian(ExitType5KLen)
Exit5Long = ExitType5 and crossunder(Exit5Tenkan, Exit5Kijun)
Exit5Short = ExitType5 and crossover(Exit5Tenkan, Exit5Kijun)
// ————— Exit 6: When the stop passes Entry +/- X Multiple.
Exit6Long_ = EntryFill+EntryX*ExitType6Mult
Exit6Short_ = EntryFill-EntryX*ExitType6Mult
Exit6TakeProfitLevel = InLong? RoundToTick(Exit6Long_) : InShort? RoundToTick(Exit6Short_) : 0.0
Exit6Long = ExitType6 and RoundToTick(close)>Exit6TakeProfitLevel
Exit6Short = ExitType6 and RoundToTick(close)<Exit6TakeProfitLevel

// ————— Set TakePRofit Level (for display purposes only)
// Currently this is done according to the only Exit strat that uses one, no 6.
// All the other exit strats generate signals on discrete events unrelated to speccific level breaches,
// so the concept of a fixed take-profit level on the chart does not apply to them.
// If you add an exit strat that uses a fixed target level, you can include it here
// so your level is displayed when the "Show Take Profit Level" checked box is checked.
TakeProfitLevel := ExitType6? Exit6TakeProfitLevel : na

// ———————————————————— Assemble exits
ExitLong = Exit1Long or Exit2Long or Exit3Long or Exit4Long or Exit5Long or Exit6Long
ExitShort = Exit1Short or Exit2Short or Exit3Short or Exit4Short or Exit5Short or Exit6Short



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ——————————————————————————————————————— 10. Trade Entry/Exit Trigger Detection —————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
//  Detect Exit and then Entry trigger conditions for execution on next bar.

// We start with exit triggers because if one is generated, we don't want to enter on the same bar.
// ————— Exit triggers
// Make an exception on Entry bar; since no previous trade stop existed, test current one.
StoppedCondition = not InTradeStopDisabled and ((InLong and Rclose<InTradeStop[LongEntryTrigger[1]?0:1]) or (InShort and Rclose>InTradeStop[ShortEntryTrigger[1]?0:1]))
ExitTradeCondition = (InLong and ExitLong) or (InShort and ExitShort)
ExitCondition := StoppedCondition or ExitTradeCondition
LongExitTrigger = InLong and ExitCondition
ShortExitTrigger = InShort and ExitCondition

// ————— Entry triggers
// If a signal has triggered, this is its number (+ for long, - for short)
LongEntry = EntryNumber>0
ShortEntry = EntryNumber<0
// Identify Pyramiding entries so they can be treated distincly.
PyramidLongEntry = LongEntry and PyramidLongOK and not ExitCondition
PyramidShortEntry = ShortEntry and PyramidShortOK and not ExitCondition
// Confirm entries with filter and pyramiding.
LongEntryConfirmed = (LongEntry and FilterLongOK and not InTrade) or (PyramidLongEntry and PyramidingOn)
ShortEntryConfirmed = not LongEntryConfirmed and ((ShortEntry and FilterShortOK and not InTrade) or (PyramidShortEntry and PyramidingOn))
// Determine if final conditions allow an entry trigger. The actual entry happens at the next bar.
// True only during the bar where an entry triggers.
// The 5 conditions are:
//      1. Trade direction allowed,
//      2. Confirmed signal,
//      3. Date filtering allows trade,
//      4. Enough bars have elapsed from beginning of dataset to have an ATR for entry stop,
//      5. Ruin has not occurred.
LongEntryTrigger := GenerateLongs and LongEntryConfirmed and TradeDateIsAllowed() and n>EntryStopType2Len and not Ruin
ShortEntryTrigger := GenerateShorts and ShortEntryConfirmed and TradeDateIsAllowed() and n>EntryStopType2Len and not Ruin

// ————— Assembly of states for ease in logical testing.
EntryTrigger := LongEntryTrigger or ShortEntryTrigger
ExitTrigger  := LongExitTrigger or ShortExitTrigger
PyramidEntry := PyramidLongEntry or PyramidShortEntry



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————————————————————————————————————————— 11. Trade Exit Processing ————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// On exit, all currently open positions (1st entry + pyramiding) are closed.
// Some of the currently valid trade data is needed in further modules,
// so we don't reset everything just yet. We will finish cleanup in next to last module before leaving the current bar.
if ExitTrigger[1]
    // ——————————————— Trade state and numbers.
    // As for entry, everything starts from the open of the bar following trigger.
    ExitOrder := Ropen
    // Calculate tentative slippage from Exit order level.
    SlipPaidOut := (SlippageType2? RoundToTick(ExitOrder*SlippageType2OutPct/100) : SlippageType3? RoundToTick(SlippageType3OutVal) : 0.0)
    // Calculate Exit Fill including slipppage, protecting against negative values.
    ExitFill := max(0.0, ExitOrder + (InLong[1]? -SlipPaidOut:SlipPaidOut))
    // Fill cannot be outside hi/lo.
    ExitFill := InLong[1]? max(Rlow, ExitFill) : min(Rhigh, ExitFill)
    // Calculate slippage that actually occured (because it can be limited by bar's hi/lo).
    SlipPaidOut := abs(ExitFill-ExitOrder)
    // Net P&L after slippage.
    TradePLX := (ExitFill-EntryFill)*(InLong[1]?1:-1)/EntryX
    // Highest/Lowest PL (mult of X) reached during trade.
    TradePLXMax := max(TradePLX, TradePLXMax[1])
    TradePLXMin := min(TradePLX, TradePLXMin[1])
    // Trade P&L in %.
    TradePLPct := TradePLX*EntryXPct
    // Trade P&L in equity units.
    TradePLEqu := PositionIn*TradePLX*EntryXPct
    // Add initial position size to P&L to get exit position before fees.
    PositionOut := TradePLEqu + PositionIn
    // % fees are calculated on exit's position size, so taking into account P&L after slippage.
    FeesPaidOut := abs((FeesType2? PositionOut*FeesType2OutPct/100 : FeesType3? FeesType3Out : 0.0))
    // ————— From here we can integrate the impact of fees in our calcs.
    // Subtract fees from previously calculated P&L (equ).
    TradePLEqu := TradePLEqu - FeesPaidIn - FeesPaidOut
    // Recalculate PLX taking fees into account.
    TradePLX := TradePLEqu/EntryXEqu
    // Recalculate PL% taking fees into account.
    TradePLPct := TradePLX*EntryXPct
    // Convert slippage in equ.
    SlippageEqu := SlipPaidIn/EntryOrder*PositionIn + SlipPaidOut/ExitOrder*PositionOut
    // Max Drawdown (from high to low) during trade.
    TradeMaxDrawdown := min(0.0,(MaxReached[1]-MinReached[1])*(InLong[1]?-1:1)/MaxReached[1])
    
    // ——————————————— Global 1st entry trade info.
    First_Entries := First_Entries+1
    // Win/Lose state.
    WinningTrade = TradePLX>=0.0
    LosingTrade = not WinningTrade
    // P&L average=Expectancy=APPT in X.
    First_PLXTot := First_PLXTot+TradePLX
    First_PLXAvg := First_PLXTot/First_Entries
    // X values: update avgs.
    First_XTot := First_XTot+EntryX
    First_XAvg := First_XTot/First_Entries
    First_XPctTot := First_XPctTot+EntryXPct
    First_XPctAvg := First_XPctTot/First_Entries
    First_XEquTot := First_XEquTot + PositionIn*EntryXPct
    First_XEquAvg := First_XEquTot/First_Entries
    // Winning/Losing trade total X.
    First_WinsX := First_WinsX + (WinningTrade? TradePLX:0.0)
    First_LoseX := First_LoseX + (LosingTrade? TradePLX:0.0)
    First_WinsEqu := First_WinsEqu + (WinningTrade? PositionOut - PositionIn:0.0)
    First_LoseEqu := First_LoseEqu + (LosingTrade? PositionOut - PositionIn:0.0)
    // Winning/Losing trade totals.
    First_Winning := First_Winning + OneZero(WinningTrade)
    First_Losing :=  First_Losing + OneZero(LosingTrade)
    // Other global trade data.
    First_TradeLengthsTot := First_TradeLengthsTot+TradeLength
    First_TradeLengthsAvg := First_TradeLengthsTot/First_Entries
    First_WinsTL := First_WinsTL + (WinningTrade? TradeLength:0)
    First_LoseTL := First_LoseTL + (LosingTrade? TradeLength:0)
    // Entry slippage and fees were added on entry; only add exit ones here.
    First_FeesEqu := First_FeesEqu + FeesPaidIn + FeesPaidOut
    First_SlipEqu := First_SlipEqu + SlippageEqu
    First_PositionInTot := First_PositionInTot + PositionIn
    First_VolumeTraded := First_VolumeTraded + PositionIn + PositionOut
    // Profit factor: gross wins / gross losses
    First_ProfitFactor := First_LoseEqu==0.0? 0.0 : abs(nz(First_WinsEqu/First_LoseEqu))
    
    // If we have active pyramid entries, process them. 
    if PyrEntries>0
        // For Pyramided positions, instead of starting from the usual TradePLX, we will be working from the total of number
        // of assets bought/sold at each successive entry, then calculating the delta between the currency value of the entries
        // and the exit. PLX and PLPct will then be derived from there.
        
        // Exit position before fees.
        PyrPositionOut := PyrPositionInQtyTot*ExitFill/PosTypeCapital
        // Exit fees.
        PyrFeesPaidOut := abs((FeesType2? PyrPositionOut*FeesType2OutPct/100 : FeesType3? FeesType3Out : 0.0))
        // Add exit fees to in fees (equ).
        PyrFeesEquTot := PyrFeesEquTot+PyrFeesPaidOut
        // Add slippage out (equ) (slippage is already in PyrSlipEquTot).
        PyrSlipEquTot := PyrSlipEquTot + SlipPaidOut/ExitOrder*PyrPositionOut
        // PL (equ) including Fees & Slippage.
        PyrTradePLEqu := ((PyrPositionOut-PyrPositionInTot)*(InLong[1]?1:-1)) - PyrFeesEquTot
        // ————— From here we can integrate the impact of fees in PL.
        // PL% taking fees into account.
        PyrTradePLPct := PyrTradePLEqu/PyrPositionInTot
        // PLX taking fees into account.
        PyrTradePLX := PyrTradePLPct/PyrEntryXPctAvg
    
        // ——————————————— Global trade info.
        // Total count of pyr entries (kept separate from First_Entries count).
        Pyr_Entries := Pyr_Entries+PyrEntries
        // Trade length (avg for all last trade's pyramids).
        Pyr_TradeLengthsTot := Pyr_TradeLengthsTot + PyrTradeLengthsAvg*PyrEntries
        Pyr_TradeLengthsAvg := Pyr_TradeLengthsTot/Pyr_Entries
        // Win/Lose state.
        PyrWinningTrade = PyrTradePLX>=0.0
        PyrLosingTrade = not PyrWinningTrade
        // Winning/Losing trade total (X).
        Pyr_WinsX := Pyr_WinsX + (PyrWinningTrade? PyrTradePLX*PyrEntries:0.0)
        Pyr_LoseX := Pyr_LoseX + (PyrLosingTrade? PyrTradePLX*PyrEntries:0.0)
        // Winning/Losing trade total (equ).
        Pyr_WinsEqu := Pyr_WinsEqu + (PyrWinningTrade? PyrTradePLEqu:0.0)
        Pyr_LoseEqu := Pyr_LoseEqu + (PyrLosingTrade? PyrTradePLEqu:0.0)
        // Winning/Losing trade totals.
        Pyr_Winning := Pyr_Winning + OneZero(PyrWinningTrade)*PyrEntries
        Pyr_Losing :=  Pyr_Losing + OneZero(PyrLosingTrade)*PyrEntries
        // Winning/Losing trade lengths
        Pyr_WinsTL := Pyr_WinsTL + (PyrWinningTrade? PyrTradeLengthsAvg*PyrEntries:0)
        Pyr_LoseTL := Pyr_LoseTL + (PyrLosingTrade? PyrTradeLengthsAvg*PyrEntries:0)
        // P&L average per pyr entry.
        Pyr_PLXTot := Pyr_PLXTot + PyrTradePLX*PyrEntries
        Pyr_PLXAvg := Pyr_PLXTot/Pyr_Entries
        // X values: update avgs.
        Pyr_XTot := Pyr_XTot + PyrEntryXAvg*PyrEntries
        Pyr_XAvg := Pyr_XTot/Pyr_Entries
        Pyr_XPctTot := Pyr_XPctTot + PyrEntryXPctAvg*PyrEntries
        Pyr_XPctAvg := Pyr_XPctTot/Pyr_Entries
        // Other global trade data.
        // Fees and slip paid in were already added with each successive pyramid.
        Pyr_FeesEqu := Pyr_FeesEqu + PyrFeesEquTot
        Pyr_SlipEqu := Pyr_SlipEqu + PyrSlipEquTot
        // Avg first entry trade length when entering pyr entry.        
        Pyr_EntryBarTot := Pyr_EntryBarTot + PyrEntryBarAvg*PyrEntries
        Pyr_EntryBarAvg := Pyr_EntryBarTot/Pyr_Entries
        // Avg entry position.
        Pyr_PositionInTot := Pyr_PositionInTot + PyrPositionInTot
        Pyr_PositionInAvg := Pyr_PositionInTot/Pyr_Entries
        // Total volume traded.
        Pyr_VolumeTraded := Pyr_VolumeTraded + PyrPositionOut + PyrPositionInTot
        // Pyr Profit factor.
        Pyr_ProfitFactor := Pyr_LoseEqu==0.0? 0.0 : abs(nz(Pyr_WinsEqu/Pyr_LoseEqu))

    // ——————————————— Global combined (1st entries and pyramiding) numbers.
    All_Entries := All_Entries + 1 + PyrEntries
    // Win/Lose state.
    WinningTrade := (TradePLX + PyrTradePLX*PyrEntries) / (PyrEntries+1) >= 0.0
    LosingTrade := not WinningTrade
    // P&L average=Expectancy=APPT in X.
    All_PLXTot := All_PLXTot + TradePLX + PyrTradePLX*PyrEntries
    All_PLXAvg := All_PLXTot/All_Entries
    // X values: update avgs.
    All_XTot := All_XTot + EntryX + PyrEntryXAvg*PyrEntries
    All_XAvg := All_XTot/All_Entries
    All_XPctTot := All_XPctTot + EntryXPct + PyrEntryXPctAvg*PyrEntries
    All_XPctAvg := All_XPctTot/All_Entries
    All_XEquTot := All_XEquTot + PositionIn*EntryXPct + PyrPositionInTot*PyrEntryXPctAvg
    All_XEquAvg := All_XEquTot/All_Entries
    // Winning/Losing trade total X.
    All_WinsX := All_WinsX + (WinningTrade? TradePLX + PyrTradePLX*PyrEntries:0.0)
    All_LoseX := All_LoseX + (LosingTrade? TradePLX + PyrTradePLX*PyrEntries:0.0)
    
    All_WinsEqu := All_WinsEqu + (WinningTrade? PositionOut - PositionIn + PyrTradePLEqu:0.0)
    All_LoseEqu := All_LoseEqu + (LosingTrade? PositionOut - PositionIn + PyrTradePLEqu:0.0)
    // Winning/Losing trade totals.
    All_Winning := All_Winning + OneZero(WinningTrade) + OneZero(WinningTrade)*PyrEntries
    All_Losing :=  All_Losing + OneZero(LosingTrade) + OneZero(LosingTrade)*PyrEntries
    // Other global trade data.
    All_TradeLengthsTot := All_TradeLengthsTot + TradeLength + PyrTradeLengthsAvg*PyrEntries
    All_TradeLengthsAvg := All_TradeLengthsTot/All_Entries
    All_WinsTL := All_WinsTL + (WinningTrade? TradeLength + PyrTradeLengthsAvg*PyrEntries:0)
    All_LoseTL := All_LoseTL + (LosingTrade? TradeLength + PyrTradeLengthsAvg*PyrEntries:0)
    // Entry slippage and fees were added on entry; only add exit ones here.
    All_FeesEqu := All_FeesEqu + FeesPaidIn + FeesPaidOut + PyrFeesEquTot
    All_SlipEqu := All_SlipEqu + SlippageEqu + PyrSlipEquTot
    All_PositionInTot := All_PositionInTot + PositionIn + PyrPositionInTot
    All_VolumeTraded := All_VolumeTraded + PositionIn + PositionOut + PyrPositionOut + PyrPositionInTot
    // Profit factor: gross wins / gross losses
    All_ProfitFactor := All_LoseEqu==0.0? 0.0 : abs(nz(All_WinsEqu/All_LoseEqu))

    // ——————————————— Equity update.
    // First entry and pyramiding (if any) exited; finish up a few numbers.
    // Equity update with PL only (PositionIn never left equity) and subtracting fees.
    Equity := Equity + PositionOut - PositionIn - FeesPaidIn - FeesPaidOut + PyrTradePLEqu
    // Return on Capital.
    ReturnOnEquity := Equity-1.0
    // Detect if capital is depleted. If so, new trades will no longer be opened.
    Ruin := Equity<=0
    // Last update of in-trade equity before next trade.
    InTradeEquity := Equity


    // ——————————————— Drawdown (close to close).
    // ————— Close to close max drawdown (only measured from trade close to trade close).
    // Max and min close to close equity reached, and end of trade drawdown reached.
    CToCEquityMax := max(Equity, nz(CToCEquityMax[1],Equity))
    // Reset min when new high encountered.
    CToCEquityMin := change(CToCEquityMax)? CToCEquityMax : min(Equity, nz(CToCEquityMin[1],Equity))
    CToCDrawdown := (CToCEquityMin-CToCEquityMax)/CToCEquityMax
    // Max close to close drawdown in equity.
    CToCMaxDrawdown := min(CToCDrawdown, nz(CToCMaxDrawdown[1]))

// ——————————————— Drawdown.
// ————— Max drawdown (using InTradeEquity measured at every bar but only changes during in-trade bars).
EquityMax := max(InTradeEquity, nz(EquityMax[1]))
// Reset min when new high encountered.
EquityMin := change(EquityMax)? EquityMax : min(InTradeEquity, nz(EquityMin[1]))
Drawdown := (EquityMin-EquityMax)/EquityMax
// Max drawdown in equity.
MaxDrawdown := min(Drawdown, nz(MaxDrawdown[1]))



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————————————————————————————————————————— 12. Post-Exit Analysis ———————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
if PEAOn
    // If we have just exited a trade at the last bars and PEA is turned on, keep analyzing outcome of bars for PEABars,
    // looking for highest andlowest close and a target expressed as a the trade's entry + multiple of X.
    // If another trade enters, we continue independently of it until we've reached our PEABars. After that, we pick up another
    // PEA analysis on the next exit, so we may miss a trade or two here and there. As we're mostly interested in the ratios, not a major issue.
    if ExitTrigger[1] and not InPEA
        // Start an analysis.
        InPEA := true
        PEAInLong := InLong[1]
        PEAX := EntryX
        PEAReferenceLevel := Rclose
        PEAMaxOppReached := Rclose
        PEAMaxRiskReached := Rclose
        PEAMaxDrawdown := Rclose
    else
        if InPEA
            if PEABar==PEABars
                // End analysis.
                PEA_Analyses := PEA_Analyses+1
                InPEA := false
                // Save bar count where events we follow occurred.
                PEA_BarsToMaxOppTot    := PEABarToMaxOpp>0?    PEA_BarsToMaxOppTot    +   PEABarToMaxOpp  :PEA_BarsToMaxOppTot
                PEA_BarsToMaxRiskTot   := PEABarToMaxRisk>0?   PEA_BarsToMaxRiskTot   +   PEABarToMaxRisk :PEA_BarsToMaxRiskTot
                // Update grand total of Xs of Opp and Risk reached for avg.
                PEA_MaxOppReachedTot   := PEABarToMaxOpp>0?    PEA_MaxOppReachedTot   +   abs(PEAReferenceLevel-PEAMaxOppReached)/PEAX   :   PEA_MaxOppReachedTot
                PEA_MaxRiskReachedTot  := PEABarToMaxRisk>0?   PEA_MaxRiskReachedTot  +   abs(PEAReferenceLevel-PEAMaxRiskReached)/PEAX  :   PEA_MaxRiskReachedTot
                // Find max drawdown between beginning of analysis and Max Opp point.
                PEA_MaxDrawdownTot := PEA_MaxDrawdownTot + abs(PEAReferenceLevel-PEAMaxDrawdown)/PEAX
                
                // Reset indivual PEA vars.
                PEABar := 0
                PEABarToMaxOpp := 0
                PEABarToMaxRisk := 0
                PEAMaxOppReached := 0.0
                PEAMaxRiskReached := 0.0
                PEAMaxDrawdown := 0.0
                PEAX := 0.0
                PEAReferenceLevel := 0.0
            else
                // Analysis is ongoing. Look for highest lowest points reached and if target is reached, and save bar no where event occurred.
                PEABar := PEABar+1
                PEAMaxOppReached := PEAInLong? max(PEAMaxOppReached, Rclose) : min(PEAMaxOppReached, Rclose)
                PEAMaxRiskReached := PEAInLong? min(PEAMaxRiskReached, Rclose) : max(PEAMaxRiskReached, Rclose)
                PEABarToMaxOpp := change(PEAMaxOppReached)? PEABar : PEABarToMaxOpp
                PEABarToMaxRisk := change(PEAMaxRiskReached)? PEABar : PEABarToMaxRisk
                PEAMaxDrawdown := change(PEAMaxOppReached)? PEAMaxRiskReached : PEAMaxDrawdown



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————————————————————————————————————————————— 13. Events ———————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
EventAtr = atr(EventAtrLen)
EventType1Trigger_  = false
EventType1Trigger_  := not EntryTrigger[1] and ((InLong and Rclose-InTradeStop[1]<EventAtr*EventType1Mult) or (InShort and InTradeStop[1]-Rclose<EventAtr*EventType1Mult))
EventType1Trigger   = EventType1Trigger_ and not EventType1Trigger_[1]
EventType2Trigger   = (InLong and pivothigh(Rsi,1,1) and RsiOB) or (InShort and pivotlow(Rsi,1,1) and RsiOS)
EventType3Trigger   = not EntryTrigger[1] and ((InLong and InTradeStop>InTradeStop[1]+EventAtr*EventType3Mult) or (InShort and InTradeStop<InTradeStop[1]-EventAtr*EventType3Mult))
EventType4Trigger   = (InLong and Rclose-Ropen>EventAtr*EventType4Mult) or (InShort and Ropen-Rclose>EventAtr*EventType4Mult)
EventsCondition     = EventType1Trigger or EventType2Trigger or EventType3Trigger or EventType4Trigger



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ————————————————————————————————————————————— 14. Plots ————————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// Plot groups:
//      A.  Data Window Plots
//          A.1. Global numbers
//              A.1.1 Global combined (1st entries + pyramiding)
//              A.1.2 Global First Entries
//              A.1.3 Global Pyramiding
//              A.1.4 Global PEA numbers
//          A.2. Trade numbers
//              A.2.1 Combined Trade info (1st entries + pyramiding)
//              A.2.2 First Entry Trade info (no pyramided info)
//              A.2.3 In-trade Pyramiding info
//              A.2.4 Individual PEA numbers
//      B.  Chart Plots

// ———————————————————————————————————————— A. Data Window Plots
// ————— Colors
// Standout color and another one a bit darker.
AAA = orange
AA2 = #ff6500
// Same color as TV dark Theme background color to hide value of titles.
BLK = #171b29
// Plus/Minus color
PMC( _val) => _val>=0.0? MyGreenMedium:MyRedRaw
// True/False color
PMB( _val) => _val? MyGreenMedium:MyRedMedium
// Global stats blues
GF1 = #6c9cec
GF2 = #4978e7
// Trade info Aquas
TI1 = #009a9a
TI2 = #00cdcd

// ———————————————————— A.1. Global numbers

// ————— A.1.1 Global combined (1st entries + pyramiding)
APPTCur11 = nz((First_Winning/First_Entries*First_WinsEqu*PosTypeCapital/First_Winning)-(-First_Losing/First_Entries*First_LoseEqu*PosTypeCapital/First_Losing))
plotchar(0, "═════════ Global Information", "", color=BLK)
plotchar(Round(All_PLXAvg,4),                                               "ALL: Avg Profitability Per Trade (X)", "", color=PMC(All_PLXAvg))      // ————— Show
plotchar(APPTCur11,                                                         "ALL: Avg Profitability Per Trade (curr)", "", color=PMC(APPTCur11))    // ————— Show
plotchar(Round(nz(All_PLXAvg/All_TradeLengthsAvg),4),                       "ALL: Avg Profitability Per Bar (X)", "", color=GF2)                    // ————— Show
plotchar(Round(All_ProfitFactor,4),                                         "ALL: Profit Factor", "", color=GF1)                                    // ————— Show
plotchar(Round(nz(100*All_Winning/All_Entries),2),                          "ALL: Win Rate (%)", "", color=GF1)                                     // ————— Show
plotchar(Equity*PosTypeCapital,                                             "ALL: Equity (curr)", "", color=AAA)                                    // ————— Show
plotchar(Round(ReturnOnEquity*100,2),                                       "ALL: Return On Capital (%)", "", color=GF1)                            // ————— Show
plotchar(Round(MaxDrawdown*100,2),                                          "ALL: Max drawdown (%)", "", color=MyRedRaw)                            // ————— Show
// plotchar(Round(CToCMaxDrawdown*100,2),                                      "ALL: Max close to close drawdown (%)", "", color=MyRedRaw, transp=30)
plotchar(Round(nz(All_WinsX/All_Winning),4),                                "ALL: Avg Win (X)", "", color=MyGreenMedium)                            // ————— Show
plotchar(Round(nz(All_LoseX/All_Losing),4),                                 "ALL: Avg Loss (X)", "", color=MyRedMedium)                             // ————— Show
// plotchar(Round(nz(All_WinsEqu*PosTypeCapital/All_Winning),4),               "ALL: Avg Win (curr)", "", color=MyGreenMedium)
// plotchar(Round(nz(All_LoseEqu*PosTypeCapital/All_Losing),4),                "ALL: Avg Loss (curr)", "", color=MyRedMedium)
plotchar(All_Entries,                                                       "ALL: Trades", "", color=GF1)                                           // ————— Show
// plotchar(All_Winning,                                                       "ALL: Wins", "", color=MyGreenMedium)
// plotchar(All_Losing,                                                        "ALL: Losses", "", color=MyRedMedium)
plotchar(Round(All_TradeLengthsAvg,2),                                      "ALL: Avg Trade Length", "", color=GF2)                                 // ————— Show
// plotchar(Round(nz(All_WinsTL/All_Winning),2),                               "ALL: Avg Winning Trade Length", "", color=GF1)
// plotchar(Round(nz(All_LoseTL/All_Losing),2),                                "ALL: Avg Losing Trade Length", "", color=GF1)
plotchar(Round(-All_XPctAvg*100,4),                                         "ALL: Avg X (%) = Stop% = Risk", "", color=MyRedSemiDark)               // ————— Show
plotchar(-All_XEquAvg*PosTypeCapital,                                       "ALL: Avg X (currency)", "", color=MyRedSemiDark)                       // ————— Show
// plotchar(All_XAvg,                                                          "ALL: Avg X (quote)", "", color=GF1)
// plotchar(All_SlipEqu*PosTypeCapital,                                        "ALL: Slippage paid (curr)", "", color=GF2)
// plotchar(All_FeesEqu*PosTypeCapital,                                        "ALL: Fees paid (curr)", "", color=GF2)
// plotchar(Round((All_SlipEqu+All_FeesEqu)/All_VolumeTraded*100,2),           "ALL: Slippage & Fees (% of Traded Volume)", "", color=GF2)
// plotchar(nz(All_PositionInTot/All_Entries*PosTypeCapital),                  "ALL: Avg Initial Position Size (curr)", "", color=GF1)
plotchar(All_VolumeTraded*PosTypeCapital,                                   "ALL: Traded Volume (curr)", "", color=GF2)                             // ————— Show

// ————— A.1.2 Global First Entries
// APPTCur12 = nz((First_Winning/First_Entries*First_WinsEqu*PosTypeCapital/First_Winning)-(-First_Losing/First_Entries*First_LoseEqu*PosTypeCapital/First_Losing))
// plotchar(0, "═════════ Global First Entries", "", color=BLK)
// plotchar(Round(First_PLXAvg,4),                                             "1ST: Avg Profitability Per Trade (X)", "", color=PMC(First_PLXAvg))
// plotchar(Round(First_PLXAvg/First_TradeLengthsAvg,4),                       "1ST: Avg Profitability Per Bar (X)", "", color=GF2)
// plotchar(APPTCur12,                                                         "1ST: Avg Profitability Per Trade (curr)", "", color=PMC(APPTCur12))
// plotchar(Equity*PosTypeCapital,                                             "1ST: Equity (curr)", "", color=AAA)
// plotchar(Round(ReturnOnEquity*100,2),                                       "1ST: Return On Capital (%)", "", color=GF1)
// plotchar(Round(MaxDrawdown*100,2),                                          "1ST: Max drawdown (%)", "", color=MyRedRaw)
// plotchar(Round(CToCMaxDrawdown*100,2),                                      "1ST: Max close to close drawdown (%)", "", color=MyRedRaw, transp=30)
// plotchar(Round(First_ProfitFactor,4),                                       "1ST: Profit Factor", "", color=GF1)
// plotchar(Round(nz(100*First_Winning/First_Entries),2),                      "1ST: Win Rate (%)", "", color=GF1)
// plotchar(Round(nz(First_WinsX/First_Winning),4),                            "1ST: Avg Win (X)", "", color=MyGreenMedium)
// plotchar(Round(nz(First_LoseX/First_Losing),4),                             "1ST: Avg Loss (X)", "", color=MyRedMedium)
// plotchar(Round(nz(First_WinsEqu*PosTypeCapital/First_Winning),4),           "1ST: Avg Win (curr)", "", color=MyGreenMedium)
// plotchar(Round(nz(First_LoseEqu*PosTypeCapital/First_Losing),4),            "1ST: Avg Loss (curr)", "", color=MyRedMedium)
// plotchar(First_Entries,                                                     "1ST: Trades", "", color=GF1)
// plotchar(First_Winning,                                                     "1ST: Wins", "", color=MyGreenMedium)
// plotchar(First_Losing,                                                      "1ST: Losses", "", color=MyRedMedium)
// plotchar(Round(First_TradeLengthsAvg,2),                                    "1ST: Avg Trade Length", "", color=GF2)
// plotchar(Round(nz(First_WinsTL/First_Winning),2),                           "1ST: Avg Winning Trade Length", "", color=GF1)
// plotchar(Round(nz(First_LoseTL/First_Losing),2),                            "1ST: Avg Losing Trade Length", "", color=GF1)
// plotchar(Round(-First_XPctAvg*100,4),                                       "1ST: Avg X (%) = Stop% = Risk", "", color=MyRedSemiDark)
// plotchar(-First_XEquAvg*PosTypeCapital,                                     "1ST: Avg X (currency)", "", color=MyRedSemiDark)
// plotchar(First_XAvg,                                                        "1ST: Avg X (quote)", "", color=GF1)
// plotchar(First_SlipEqu*PosTypeCapital,                                      "1ST: Slippage paid (curr)", "", color=GF2)
// plotchar(First_FeesEqu*PosTypeCapital,                                      "1ST: Fees paid (curr)", "", color=GF2)
// plotchar(Round((First_SlipEqu+First_FeesEqu)/First_VolumeTraded*100,2),     "1ST: Slippage & Fees (% of Traded Volume)", "", color=GF2)
// plotchar(nz(First_PositionInTot/First_Entries*PosTypeCapital),              "1ST: Avg Initial Position Size (curr)", "", color=GF1)
// plotchar(First_VolumeTraded*PosTypeCapital,                                 "1ST: Traded Volume (curr)", "", color=GF2)

// ————— A.1.3 Global Pyramiding
// APPTCur13 = nz((Pyr_Winning/Pyr_Entries*Pyr_WinsEqu*PosTypeCapital/Pyr_Winning)-(-Pyr_Losing/Pyr_Entries*Pyr_LoseEqu*PosTypeCapital/Pyr_Losing))
// plotchar(0, "═════════ Global Pyramiding", "", color=BLK)
plotchar(Round(Pyr_PLXAvg,4),                                               "PYR: Avg Profitability Per Entry (X)", "", color=PMC(Pyr_PLXAvg))      // ————— Show
// plotchar(APPTCur13,                                                         "PYR: Avg Profitability Per Entry (curr)", "", color=PMC(APPTCur13))
// plotchar(nz(Round(Pyr_PLXAvg/Pyr_TradeLengthsAvg,4)),                       "PYR: Avg Profitability Per Bar (X)", "", color=GF2)
// plotchar(Round(Pyr_ProfitFactor,4),                                         "PYR: Profit Factor", "", color=GF1)
// plotchar(Round(nz(100*Pyr_Winning/Pyr_Entries),2),                          "PYR: Win Rate (%)", "", color=GF1)
// plotchar(Round(nz(Pyr_WinsX/Pyr_Winning),4),                                "PYR: Avg Win (X)", "", color=MyGreenMedium)
// plotchar(Round(nz(Pyr_LoseX/Pyr_Losing),4),                                 "PYR: Avg Loss (X)", "", color=MyRedMedium)
// plotchar(Round(nz(Pyr_WinsEqu*PosTypeCapital/Pyr_Winning),4),               "PYR: Avg Win (curr)", "", color=MyGreenMedium)
// plotchar(Round(nz(Pyr_LoseEqu*PosTypeCapital/Pyr_Losing),4),                "PYR: Avg Loss (curr)", "", color=MyRedMedium)
// plotchar(Pyr_Entries,                                                       "PYR: Trades", "", color=GF2)
// plotchar(Pyr_Winning,                                                       "PYR: Wins", "", color=MyGreenMedium)
// plotchar(Pyr_Losing,                                                        "PYR: Losses", "", color=MyRedMedium)
// plotchar(Round(Pyr_TradeLengthsAvg,2),                                      "PYR: Avg Trade Length", "", color=GF2)
// plotchar(Round(nz(Pyr_WinsTL/Pyr_Winning),2),                               "PYR: Avg Winning Trade Length", "", color=GF1)
// plotchar(Round(nz(Pyr_LoseTL/Pyr_Losing),2),                                "PYR: Avg Losing Trade Length", "", color=GF1)
// plotchar(Round(Pyr_EntryBarAvg,2),                                          "PYR: Avg First Entry TL on Pyr. Entry", "", color=GF2)
// plotchar(Round(-Pyr_XPctAvg*100,4),                                         "PYR: Avg X (%) = Stop% = Risk", "", color=MyRedSemiDark)
// plotchar(Pyr_SlipEqu*PosTypeCapital,                                        "PYR: Slippage paid (curr)", "", color=GF2)
// plotchar(Pyr_FeesEqu*PosTypeCapital,                                        "PYR: Fees paid (curr)", "", color=GF2)
// plotchar(nz(Round((Pyr_SlipEqu+Pyr_FeesEqu)/Pyr_VolumeTraded*100,2)),       "PYR: Slippage & Fees (% of Traded Volume)", "", color=GF2)
// plotchar(Pyr_PositionInAvg*PosTypeCapital,                                  "PYR: Avg Initial Position Size (curr)", "", color=GF1)
// plotchar(Pyr_VolumeTraded*PosTypeCapital,                                   "PYR: Traded Volume (curr)", "", color=GF1)

// ————— A.1.4 Global PEA numbers
// plotchar(0, "═════════ Global PEA", "", color=BLK)
// plotchar(PEA_Analyses,                                                      "PEA: Analyses", "", color=GF2)
plotchar(nz(PEA_MaxOppReachedTot/PEA_Analyses),                             "PEA: Avg Max Opp. Available (X)", "", color=MyGreenMedium)          // ————— Show
// plotchar(nz(PEA_MaxRiskReached/PEA_Analyses),                               "PEA: Avg Risk Incurred (X)", "", color=GF1)
plotchar(nz(PEA_MaxDrawdownTot/PEA_Analyses),                               "PEA: Avg Drawdown to Max Opp. (X)", "", color=MyRedMedium)          // ————— Show
// plotchar(nz(PEA_MaxOppReached/PEA_MaxRiskReached),                          "PEA: Opportunity/Risk (X)", "", color=GF1)
// plotchar(nz(PEA_MaxOppReached-PEA_MaxRiskReached),                          "PEA: Opportunity-Risk (X)", "", color=GF1)
// plotchar(nz(PEA_BarsToMaxOpp/PEA_Analyses),                                 "PEA: Avg Bars to Max Opportunity", "", color=GF2)
// plotchar(nz(PEA_BarsToMaxRisk/PEA_Analyses),                                "PEA: Avg Bars to Max Risk", "", color=GF2)


// ———————————————————— A.2. Trade numbers
// ————— A.2.1 Combined Trade info (1st entries + pyramiding)
PositionShownA21 = PosTypeCapital * ((EntryTrigger[1]? PositionIn : PositionOut) + PyrPositionInTot)
plotchar(0, "═════════ Trade Information", "", color=BLK)
plotchar(EntryFill,                                                                         "1ST: Entry Fill after slippage", "", color=TI1)                                    // ————— Show
plotchar(ExitFill,                                                                          "1ST: Exit Fill after slippage", "", color=TI1)                                     // ————— Show
plotchar(Round((TradePLX + PyrTradePLX*PyrEntries) / (PyrEntries+1),4),                     "ALL: P&L (X) after slippage", "", color=ExitTrigger[1]? PMC(TradePLX) : InTrade? AAA : TI2)    // ————— Show
plotchar(Round(nz((TradePLX + PyrTradePLX*PyrEntries) / (PyrEntries+1) / TradeLength),4),   "ALL: P&L/Bar (X)", "", color=TI2)                                                  // ————— Show
plotchar(Round((TradePLPct + PyrTradePLPct*PyrEntries)/(PyrEntries+1)*100,4),               "ALL: P&L (%) after slippage", "", color=TI2)                                       // ————— Show
plotchar(Round((TradePLEqu+PyrTradePLEqu) * PosTypeCapital,4),                              "ALL: P&L (curr) after slippage & fees", "", color=TI2)                             // ————— Show
plotchar(Round((TradePLEqu+PyrTradePLEqu) / nz(Equity[1])*100,2),                           "ALL: Impact on Equity (%)", "", color=TI1)                                         // ————— Show
plotchar(Round(TradeLength,2),                                                              "1ST: Trade Length", "", color=TI1)                                                 // ————— Show
plotchar(Round(-(EntryXPct + PyrEntryXPctAvg*PyrEntries)/(PyrEntries+1)*100,4),             "ALL: X (% of fill) = Stop = Risk", "", color=MyRedMedium)                          // ————— Show
plotchar(-(EntryXEqu + PyrPositionInTot*PyrEntryXPctAvg)*PosTypeCapital,                    "ALL: X (curr)", "", color=MyRedMedium)                                             // ————— Show
plotchar((SlippageEqu+PyrSlipEquTot) * PosTypeCapital,                                      "ALL: Slippage cost (curr)", "", color=MyRedMedium)                                 // ————— Show
plotchar(nz(FeesPaidIn+FeesPaidOut+PyrFeesEquTot) * PosTypeCapital,                         "ALL: Fees paid (curr)", "", color=MyRedMedium)                                     // ————— Show
plotchar(PositionShownA21,                                                                  "ALL: Position Size (curr)", "", color=TI1)                                         // ————— Show
plotchar(Round(nz(PositionIn*PosTypeCapital/EntryFill) + PyrPositionInQtyTot,2),            "ALL: Position Size (qty)", "", color=TI1)                                          // ————— Show

// ————— A.2.2 First Entry Trade info (no pyramided info)
// PositionShownA22 = PosTypeCapital * (EntryTrigger[1]? PositionIn : PositionOut)
// plotchar(0, "═════════ First Entries", "", color=BLK)
// plotchar(EntryOrder,                                                                        "1ST: Entry Order", "", color=TI1)
// plotchar(EntryFill,                                                                         "1ST: Entry Fill after slippage", "", color=TI1)
// plotchar(ExitOrder,                                                                         "1ST: Exit Order", "", color=TI1)
// plotchar(ExitFill,                                                                          "1ST: Exit Fill after slippage", "", color=TI1)
// plotchar(Round(TradePLX,4),                                                                 "1ST: P&L (X) after slippage", "", color=ExitTrigger[1]? PMC(TradePLX) : InTrade? AAA : TI2)
// plotchar(Round(nz(TradePLX/TradeLength),4),                                                 "1ST: P&L/Bar (X)", "", color=TI2)
// plotchar(Round(TradePLPct*100,4),                                                           "1ST: P&L (%) after slippage", "", color=TI2)
// plotchar(Round(TradePLEqu*PosTypeCapital,4),                                                "1ST: P&L (curr) after slippage & fees", "", color=TI2)
// plotchar(Round(TradePLEqu/nz(Equity[1])*100,2),                                             "1ST: Impact on Equity (%)", "", color=TI1)
// plotchar(TradeLength,                                                                       "1ST: Trade Length", "", color=TI1)
// plotchar(-EntryX,                                                                           "1ST: X=Stop=Risk (quote, from fill)", "", color=TI1)
// plotchar(Round(-EntryXPct*100,4),                                                           "1ST: X (% of fill) = Stop = Risk", "", color=MyRedMedium)
// plotchar(-EntryXEqu*PosTypeCapital,                                                         "1ST: X (curr)", "", color=MyRedMedium)
// plotchar(SlippageEqu*PosTypeCapital,                                                        "1ST: Slippage cost (curr)", "", color=MyRedMedium)
// plotchar(nz(SlipPaidIn)+nz(SlipPaidOut),                                                    "1ST: Slippage cost (quote)", "", color=MyRedMedium)
// plotchar((nz(FeesPaidIn)+nz(FeesPaidOut))*PosTypeCapital,                                   "1ST: Fees paid (curr)", "", color=MyRedMedium)
// plotchar(PositionShownA22,                                                                  "1ST: Position Size (curr)", "", color=TI1)
// plotchar(Round(nz(PositionIn*PosTypeCapital/EntryFill),2),                                  "1ST: Position Size (qty)", "", color=TI1)
// plotchar(Round(TradeMaxDrawdown*100,4),                                                     "1ST: Maximum Drawdown (%)", "", color=TI2)
// plotchar(MaxReached,                                                                        "1ST: Highest High reached", "", color=TI2)
// plotchar(MinReached,                                                                        "1ST: Lowest Low reached since HiHi", "", color=TI2)
// plotchar(TradePLXMax,                                                                       "1ST: Highest P&L (X) reached", "", color=TI2)
// plotchar(TradePLXMin,                                                                       "1ST: Lowest P&L (X) reached", "", color=TI2)

// ————— A.2.3 In-trade Pyramiding info
// plotchar( 0, "═════════ Pyramiding (active)", "", color=BLK)
// plotchar(PyrEntries,                                                                        "PYR: Entries", "", color=TI1)
plotchar(Round(PyrTradePLX,4),                                                              "PYR: Avg P&L (X) after slippage & fees", "", color=PMC(PyrTradePLX))               // ————— Show
// plotchar(PyrTradePLEqu*PosTypeCapital,                                                      "PYR: P&L (curr) after slippage & fees", "", color=TI1)
// plotchar(Round(PyrTradePLPct*100,4),                                                        "PYR: P&L (%) after slippage & fees", "", color=TI1)
// plotchar(Round(nz(PyrTradePLX/PyrTradeLengthsAvg),4),                                       "PYR: P&L/Bar (X)", "", color=TI2)
// plotchar(Round(PyrTradePLEqu/nz(Equity[1])*100,2),                                          "PYR: Impact on Equity (%)", "", color=TI1)
// plotchar(Round(PyrTradeLengthsAvg,2),                                                       "PYR: Avg Trade Length", "", color=TI1)
// plotchar(-Round(PyrEntryXPctAvg*100,4),                                                     "PYR: Avg X (% of fill) after slippage", "", color=MyRedMedium)
// plotchar(-PyrEntryXAvg,                                                                     "PYR: Avg X (quote) after slippage", "", color=MyRedMedium)
// plotchar(-PyrEntryX,                                                                        "PYR: Current X (quote) after slippage", "", color=MyRedMedium)
// plotchar(PyrEntries>0? LastEntryPrice:0,                                                    "PYR: Last Entry", "", color=TI2)
// plotchar(Round(PyrEntryBarAvg,2),                                                           "PYR: Avg First Entry TL on Pyr. Entry", "", color=TI2)
// plotchar(PyrSlipEquTot*PosTypeCapital,                                                      "PYR: Slippage (curr)", "", color=MyRedMedium)
// plotchar(PyrFeesEquTot*PosTypeCapital,                                                      "PYR: Fees (curr)", "", color=MyRedMedium)
// plotchar(PyrPositionInTot*PosTypeCapital,                                                   "PYR: Entry Positions Total (curr)", "", color=TI2)
// plotchar(PyrPositionOut*PosTypeCapital,                                                     "PYR: Exit Positions Total (curr)", "", color=TI2)
// plotchar((PyrPositionOut+PyrPositionInTot)*PosTypeCapital,                                  "PYR: Volume Traded (curr)", "", color=TI1)
// plotchar(PyrEntryFillAvg,                                                                   "PYR: Avg Entry Fill after slippage", "", color=TI1)
// plotchar(PyrPositionInQtyTot,                                                               "PYR: Entry Positions Total (qty)", "", color=TI2)
// plotchar(PyrPositionInQtyTot*ExitFill,                                                      "PYR: Exit Position Total (curr)", "", color=TI2)

// ————— A.2.4 Individual PEA numbers
MaxOpp  = nz(abs(PEAReferenceLevel-PEAMaxOppReached)/PEAX)
MaxRisk = nz(abs(PEAReferenceLevel-PEAMaxRiskReached)/PEAX)
MaxDraw = nz(abs(PEAReferenceLevel-PEAMaxDrawdown)/PEAX)
// plotchar(0, "═════════ PEA Information", "", color=BLK)
// plotchar(InPEA? PEA_Analyses+1:0,                                                           "PEA: Analysis no", "", color=TI1)
// plotchar(PEABar,                                                                            "PEA: bar", "", color=TI1)
plotchar(MaxOpp,                                                                            "PEA: Max Opportunity Available (X)", "", color=MyGreenMedium)                      // ————— Show
// plotchar(-MaxRisk,                                                                          "PEA: Max Risk Incurred (X)", "", color=MyRedMedium)
plotchar(-MaxDraw,                                                                          "PEA: Drawdown to Max Opp. (X)", "", color=MyRedMedium)
// plotchar(MaxRisk==0?0.0:nz(MaxOpp/MaxRisk),                                                 "PEA: Opportunity/Risk (X)", "", color=TI2)                                         // ————— Show
// plotchar(MaxOpp-MaxRisk,                                                                    "PEA: Opportunity-Risk (X)", "", color=TI2)
// plotchar(PEABarToMaxOpp,                                                                    "PEA: Bars to Max Opportunity", "", color=TI1)
// plotchar(PEABarToMaxRisk,                                                                   "PEA: Bars to Max Risk", "", color=TI1)
// plotchar(PEAX,                                                                              "PEA: X", "", color=TI2)
// plotchar(PEAReferenceLevel,                                                                 "PEA: Reference Level", "", color=TI2)
// plotchar(PEAInLong,                                                                         "PEA: Analysis after Long Trade", "", color=TI2)
    

// ———————————————————— B. Chart Plots
// Atr used in generating offsets for some plots.
PrintingAtr = nz(atr(14))
// ————— Equity and in-trade equity.
// plot(Equity*PosTypeCapital:na, "Equity", color=Equity>=1? MyGreenMedium:MyRedMedium)
// plot(InTradeEquity*PosTypeCapital:na, "In-Trade Equity", color=InTradeEquity>=1? MyGreenMedium:MyRedMedium)
// ————— Entry
plot(ShowEntry and InTrade? EntryFill:na, "Entry Level", color=MyBlueMedium, style=circles, linewidth=1)
// ————— Entry Stop
plot(ShowEntryStopAll or (ShowEntryStopEntry and LongEntryTrigger[1] and FirstEntry1stBar)? EntryStopLong:na, "Long Entry Stop", color=MyOrangeDark, style=circles, transp=30)
plot(ShowEntryStopAll or (ShowEntryStopEntry and ShortEntryTrigger[1] and FirstEntry1stBar)? EntryStopShort:na, "Short Entry Stop", color=MyOrangeDark, style=circles, transp=30)
// ————— In-trade stop
plot(ShowInTradeStop and InTrade? InTradeStop:na, "In-trade stop", color=MyOrangeMedium, style=circles, linewidth=2)
// ————— Take-profit
plot(ShowTakeProfit and InTrade? TakeProfitLevel:na, "Take-Profit Level", color=MyFuchsiaMedium, style=circles, linewidth=2)
// ————— Filter state
plotshape(ShowFilter? FilterLongOK:na,  "Bull Filter OK", style=shape.triangleup, color=MyGreenMedium, location=location.top, size=size.tiny)
plotshape(ShowFilter? FilterShortOK:na, "Bear Filter OK", style=shape.triangledown, color=MyRedMedium, location=location.top, size=size.tiny)
// ————— Events
EventPrintLevel = InLong? (EventType1Trigger or EventType3Trigger? InTradeStop[1]:MinOC)-2*PrintingAtr : InShort? (EventType1Trigger or EventType3Trigger? InTradeStop[1]:MaxOC)+2*PrintingAtr : na
EventPrintLevelTopBot = InShort? MinOC-2*PrintingAtr : InLong? MinOC+2*PrintingAtr : na
plotshape(EventType1 and EventType1Trigger? EventPrintLevel:na,         "Event 1: Price nearing stop",  style=shape.circle, color=MyOrangeMedium,   location=location.absolute, size=size.tiny)
plotshape(EventType2 and EventType2Trigger? EventPrintLevelTopBot:na,   "Event 2: Possible Top/Bottom", style=shape.circle, color=MyRedSemiDark,    location=location.absolute, size=size.tiny)
plotshape(EventType3 and EventType3Trigger? EventPrintLevel:na,         "Event 3: Stop Moved",          style=shape.circle, color=MyYellowMedium,   location=location.absolute, size=size.tiny)
plotshape(EventType4 and EventType4Trigger? EventPrintLevel:na,         "Event 4: Big Price Swing",     style=shape.circle, color=MyGreenMedium,    location=location.absolute, size=size.tiny)
// ————— Entry markers with entry number
// These plots all print on the bar following the trigger, which corresponds to where TV backtesting will also enter/exit trades.
MarkerSize = size.small
// Define states used to determine color of marker.
PrintFilteredOutLong = ShowFilteredOut and GenerateLongs and LongEntry[1] and not FilterLongOK[1]
PrintFilteredOutShort = ShowFilteredOut and GenerateShorts and ShortEntry[1] and not FilterShortOK[1]
PrintPyramidedOutLong = PyramidingOffButShow and GenerateLongs and PyramidLongEntry[1]
PrintPyramidedOutShort = PyramidingOffButShow and GenerateShorts and PyramidShortEntry[1]
EntryToPrintLong = LongEntryTrigger[1] or PrintFilteredOutLong or PrintPyramidedOutLong
EntryToPrintShort = ShortEntryTrigger[1] or PrintFilteredOutShort or PrintPyramidedOutShort
// Marker color info.
EntryMarkerColorLong = PrintFilteredOutLong? MyGreenDark : LongEntryTrigger[1]? PyramidLongEntry[1]? MyGreenMedium : MyGreenRaw : PrintPyramidedOutLong? MyGreenSemiDark : yellow
EntryMarkerColorShort = PrintFilteredOutShort? MyRedDark : ShortEntryTrigger[1]? PyramidShortEntry[1]? MyRedMedium : MyRedRaw : PrintPyramidedOutShort? MyRedSemiDark : yellow
EntryTextColorLong = MyGreenRaw
EntryTextColorShort = MyRedRaw
// Price level where marker is printed.
EntryPrintLevelLong = LongEntryTrigger[1] and FirstEntry1stBar? EntryFill : LongEntryTrigger[1] and PyramidEntry1stBar? PyrEntryFill : MinOC-2*PrintingAtr
EntryPrintLevelShort = ShortEntryTrigger[1] and FirstEntry1stBar? EntryFill : ShortEntryTrigger[1] and PyramidEntry1stBar? PyrEntryFill : MaxOC+2*PrintingAtr
// Finally print markers. Phew.
plotchar(ShowMarkers and EntryToPrintLong and EntryIsALong[1]? EntryPrintLevelLong:na,
  "Long Entry A", "╚", color=EntryMarkerColorLong,  location=location.absolute, size=MarkerSize, text=TradeId+"\nEnter\nLong A\n▲", textcolor=EntryTextColorLong)
plotchar(ShowMarkers and EntryToPrintLong and EntryIsBLong[1]? EntryPrintLevelLong:na,
  "Long Entry B", "╚", color=EntryMarkerColorLong,  location=location.absolute, size=MarkerSize, text=TradeId+"\nEnter\nLong B\n▲", textcolor=EntryTextColorLong)
plotchar(ShowMarkers and EntryToPrintShort and EntryIsAShort[1]? EntryPrintLevelShort:na,
  "Short Entry A", "╔", color=EntryMarkerColorShort, location=location.absolute, size=MarkerSize, text=TradeId+"\nEnter\nShort A\n▼", textcolor=EntryTextColorShort)
plotchar(ShowMarkers and EntryToPrintShort and EntryIsBShort[1]? EntryPrintLevelShort:na,
  "Short Entry B", "╔", color=EntryMarkerColorShort, location=location.absolute, size=MarkerSize, text=TradeId+"\nEnter\nShort B\n▼", textcolor=EntryTextColorShort)
// ————— Exit markers
// These plots are all one bar late, to replicate Strategy behavior.
plotchar(ShowMarkers and LongExitTrigger[1]? ExitFill:na, "Exit Long", "╗", color=MyGreenMedium, location=location.absolute, size=MarkerSize, text=TradeId+"\nExit\nLong\n▼")
plotchar(ShowMarkers and ShortExitTrigger[1]? ExitFill:na, "Exit Short", "╝", color=MyRedMedium, location=location.absolute, size=MarkerSize, text=TradeId+"\nExit\nShort\n▲")
// ————— Color Traded Background
bgcolor(ShowTradedBackground? InLong? MyGreenBackGround : InShort? MyRedBackGround : na : na, title="Traded Background")



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ——————————————————————————————————————————————— 15. Alerts —————————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// If your alerts are sent to an execution bot, then you will need to include the proper encoding in the message field.
A1  = AlertType1    and LongEntryTrigger    and not PyramidLongEntry
A2  = AlertType2    and LongEntryTrigger    and PyramidLongEntry
A3  = AlertType3    and ShortEntryTrigger   and not PyramidShortEntry
A4  = AlertType4    and ShortEntryTrigger   and PyramidShortEntry
A5  = AlertType5    and LongExitTrigger
A6  = AlertType6    and ShortExitTrigger
A7  = AlertType7    and EventType1Trigger
A8  = AlertType8    and EventType2Trigger
A9  = AlertType9    and EventType3Trigger
A10 = AlertType10   and EventType4Trigger
alertcondition(A1 or A2 or A3 or A4 or A5 or A6 or A7 or A8 or A9 or A10, title=SystemName, message=TradeId)



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ———————————————————————————————————————————— 16. Variable resets ———————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// ———————————————————— Last cleanup of exits.
// Now that we have used and plotted all Exit information, we can do final cleanup before next bar.
// Some of these values are reset a second time at the beginning of cycles;
// they are nonetheless reset here for cleaner between trade display purposes.
if ExitTrigger[1]
    EntryFill := 0.0
    EntryOrder := 0.0
    EntryX := 0.0
    EntryXPct := 0.0
    EntryXEqu := 0.0
    ExitOrder := 0.0
    ExitFill := 0.0
    FeesPaidIn := 0.0
    FeesPaidOut := 0.0
    InTradeEquity := Equity
    InTradeStartEquity := Equity
    LastEntryPrice := 0
    PositionIn := 0.0
    PositionOut := 0.0
    SlippageEqu := 0.0
    SlipPaidIn := 0.0
    SlipPaidOut := 0.0
    TakeProfitLevel := 0.0
    TradeLength := 0
    TradeMaxDrawdown := 0.0

    PyrEntries := 0
    PyrEntryBarTot := 0
    PyrEntryBarAvg := 0.0
    PyrEntryFill := 0.0
    PyrEntryFillTot := 0.0
    PyrEntryFillAvg := 0.0
    PyrEntryOrder := 0.0
    PyrEntryX := 0.0
    PyrEntryXAvg := 0.0
    PyrEntryXPct := 0.0
    PyrEntryXPctTot := 0.0
    PyrEntryXPctAvg := 0.0
    PyrEntryXTot := 0.0
    PyrFeesPaidIn := 0.0
    PyrFeesPaidOut := 0.0
    PyrFeesEquTot := 0.0
    PyrPositionIn := 0.0
    PyrPositionOut := 0.0
    PyrPositionInQtyTot := 0.0
    PyrPositionInTot := 0.0
    PyrSlipPaidIn := 0.0
    PyrSlipPaidOut := 0.0
    PyrSlipEquTot := 0.0
    PyrTradePLEqu := 0.0
    PyrTradePLX := 0.0
    PyrTradeLengthsTot := 0
    PyrTradeLengthsAvg := 0.0



// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// —————————————————————————————————————————— 17. Strategy() calls ————————————————————————————————————————————————————————
// ————————————————————————————————————————————————————————————————————————————————————————————————————————————————————————
// [See top of script for "TradeId" string initialization.]
// strategy.entry(TradeId, strategy.long, when=LongEntryTrigger)
// strategy.entry(TradeId, strategy.short, when=ShortEntryTrigger)
// strategy.close(TradeId, when=LongExitTrigger or ShortExitTrigger)
````
