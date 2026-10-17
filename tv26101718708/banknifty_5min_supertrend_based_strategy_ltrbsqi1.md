# BankNifty 5min Supertrend Based Strategy

- url: https://www.tradingview.com/script/LTRBSQI1-BankNifty-5min-Supertrend-Based-Strategy/
- type: strategy
- pine_id: PUB;1abf2380cc8240f4be7b61c9e1d84156
- version: 6.0

## Description

[b]BankNifty 5min Supertrend Based Strategy, Intraday.[/b]

Work Best at [b]5mint chart[/b] on BankNifty.

The strategy is designed to trade using the[b] Supertrend indicator with session-based rules, and risk management.[/b]It allows for customization through [b]input variables[/b] and aims to provide a [b]clear visual representation[/b] of [b]the Supertrend by changing the color[/b]. 

The script also includes input variables for the trading session and date range, which allows the trader to specify the time period in which they want the strategy to run. The session variable specifies the start and end times of the trading session, which in this case is set to the Indian trading session from 9:15 am to 3:10 pm.

The strategy starts by defining input variables such as [b]the session time, start and end date for the backtesting, the length of the ATR, and the Supertrend factor.[/b] It also includes options for[b] delay at session start and stop loss points and trail percentage[/b].

The code then checks if [b]the current time is within the specified session and date range[/b]. If it is, the Supertrend and its direction are calculated using the defined input variables. The strategy then [b]waits for N numbers of candles (defined by the User)[/b] to form at the start of [b]every session i.e. 09:15 AM[/b] before entering a trade.

The entry and exit conditions for long and short trades are defined based on the change in the [b]Supertrend direction and the number of candles formed at the session start i.e. 09:15 AM[/b]. After that, it takes entry and exit for long and short trades on [b]the change in the Supertrend direction[/b]. Stop-loss and trailing stop-loss are also defined based on the input variables.

Stop-loss[b](Defined by the user) [/b]is [b]fixed points[/b] either below or above the [b]Entry Price[/b] for Long and Short entries.

The Supertrend plot is displayed with changing colors depending on the direction. Finally, the strategy closes all trades at the end of the session if there are any open trades.

Overall, this strategy aims to trade with the Supertrend indicator using session-based rules and risk management. 

However, as with any trading strategy, [b]it is important to thoroughly test it before using it in live trading[/b].

## Source Code

````pine
//@version=5
strategy("BankNifty 5min Supertrend Based Strategy, 09:15 Entry with Date Range and Risk Management",overlay=true)

// Session and date range input variables
session = input("0915-1510", "Session", group="Indian Session Time")
start_date = input.time(title="Start Date", defval=timestamp("01 Jan 2022 00:00:00"), group="Backtest Specific Range")
end_date = input.time(title="End Date", defval=timestamp("01 Dec 2023 23:59:59"))
atrPeriod = input(50, "ATR Length", group="SuperTrend Setting")
factor = input.float(3.0, "Factor", step=0.1)
//Delay N numbers of candles
useDelay = input(true, "Use Delay?", group="Delay at Session Start")
Delay = useDelay ? input(10, title="Delay N numbers of candle", group="Delay at Session Start") : na
//reentry option
Take_ReEntry = input(true, "Take ReEntry After Delay/SL/Target?", group="Delay at Session Start")
D1 = Take_ReEntry ? 100 : 0

//stoploss and target
useDelay_stopLoss = input(true, "Use Stoploss Fixed Points?", group="Fixed Point SL/TG")
stopLoss = useDelay_stopLoss ? input(100, "Stop Loss Fixed Points", group="Fixed Point SL/TG"): na

useTarget = input(true, "Use Target Fixed Points?", group="Fixed Point SL/TG")
target = useTarget? input(200, "Use Target Fixed Points", group="Fixed Point SL/TG"): na

stopLoss1 = 100
// trailing stop loss
useDelay_stopLossPerc1 = input(true, "Use Stoploss Trail?", group="Trailing")
stopLossPerc1 =useDelay_stopLossPerc1 ? input.float(0.1, "Stop Loss Trail%", step=0.1,maxval = 1, group="Trailing"): na


// Check if current time is within the specified session and date range
inSession = time("1", session) and time >= start_date and time <= end_date
//suprtrend
[supertrend, direction] = ta.supertrend(factor, atrPeriod)

// Wait for n candles to form at the start of every session
var candlesFormed = 0
if inSession and not inSession[1]
    candlesFormed := 1
else if inSession and candlesFormed > 0
    candlesFormed := candlesFormed + 1
else
    candlesFormed := 0
//get entry price
entryPrice = strategy.opentrades.entry_price(strategy.opentrades - 1)
//stop and target based on entry price
StopCE=entryPrice - stopLoss
StopPE= entryPrice + stopLoss
targetCE= entryPrice + target
targetPE=entryPrice - target
// long, short and close condition
entryce = (ta.change(direction) < 0) or (candlesFormed >= Delay and candlesFormed <= Delay+D1 and direction < 0)
exitce = ta.change(direction) > 0 or close < StopCE or close > targetCE
entrype = (ta.change(direction) > 0) or (candlesFormed >= Delay and candlesFormed <= Delay+D1 and direction > 0)
exitpe = ta.change(direction) < 0 or close > StopPE or close < targetPE

// entry price variable for defining stoploss
var entryPrice1 = 0.0
// Enter long trade
if entryce and inSession
    onePercent = strategy.position_avg_price *stopLossPerc1
    entryPrice1 := close   
    strategy.entry("My Long Entry Id", strategy.long, comment="long" )
    strategy.exit("My Long Exit Id", "My Long Entry Id", stop=(entryPrice1 - stopLoss1),trail_points=onePercent )
//close long trade
if exitce and inSession
    strategy.close("My Long Entry Id", comment="close" )
// Enter short trade   
if entrype and inSession
    onePercent1 = strategy.position_avg_price *stopLossPerc1
    entryPrice1 := close
    strategy.entry("My Short Entry Id", strategy.short, comment="short")
    strategy.exit("My Short Exit Id", "My Short Entry Id", stop=(entryPrice1 + stopLoss1),trail_points=onePercent1)
//close short trade
if exitpe and inSession
    strategy.close ("My Short Entry Id", comment="close" )

// Close all trades at end of session
if not inSession and strategy.opentrades > 0
    strategy.close_all()

// Plot Supertrend with changing colors
plot(supertrend, title="Supertrend", color=direction == 1 ? color.red : color.green, linewidth=2)
````
