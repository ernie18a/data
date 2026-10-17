# C320up Strategy Tester Start Time

- url: https://www.tradingview.com/script/VQ38nufE-C320up-Strategy-Tester-Start-Time/
- type: strategy
- pine_id: PUB;FikDVvKLx26ttmQdJbanPCqGAMay6oAq
- version: 2.0

## Description

[b]C320up Strategy Tester Start Time[/b]

This is a little snippet you can paste into your Strategy to set the testing start date and time.

It is not a Strategy per se, though is an example with the timestamp script included.

Instructions are fairly straight forward, and are listed in the script.

If for some reason you also wanted an end date, that too is possible. Just leave a note in the comments.

Disclaimer: We searched for a similar script on TV, and could not find anything at this point in time.

You can set your preferred date and time in the input section of the settings.

Enjoy!

## Source Code

````pine
//@version=3
strategy("C320up Strategy Tester Start Time", overlay = true)
// Copy and paste below into your strategy
// Strategy Tester Start Time
sYear = input(2018, title = "Start Year")
sMonth = input(01, title = "Start Month", minval = 01, maxval = 12)
sDay = input(01, title = "Start Day", minval = 01, maxval = 31)
sHour = input(00, title = "Start Hour", minval = 00, maxval = 23)
sMinute = input(00, title = "Start Minute", minval = 00, maxval = 59)
startTime = time >= timestamp(sYear, sMonth, sDay, sHour, sMinute)
// End copy and paste
// Add (and startTime) at the end of your condition/s to activate

// If you want to use End Time copy and paste below into your strategy
// Strategy Tester End Time
eYear = input(2020, title = "End Year")
eMonth = input(01, title = "End Month", minval = 01, maxval = 12)
eDay = input(01, title = "End Day", minval = 01, maxval = 31)
eHour = input(00, title = "End Hour", minval = 00, maxval = 23)
eMinute = input(00, title = "End Minute", minval = 00, maxval = 59)
endTime = time <= timestamp(eYear, eMonth, eDay, eHour, eMinute)
// End copy and paste
// Add (and endTime) at the end of your condition/s to activate

// The strategy below is just an example
longCondition = crossover(sma(close, 14), sma(close, 28))
if (longCondition and startTime and endTime)
    strategy.entry("My Long Entry Id", strategy.long)
shortCondition = crossunder(sma(close, 14), sma(close, 28))
if (shortCondition and startTime and endTime)
    strategy.entry("My Short Entry Id", strategy.short)
// Happy trading!
````
