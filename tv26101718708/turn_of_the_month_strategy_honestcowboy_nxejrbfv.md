# Turn of the Month Strategy [Honestcowboy]

- url: https://www.tradingview.com/script/NXejRbFv-Turn-of-the-Month-Strategy-Honestcowboy/
- type: strategy
- pine_id: PUB;5aeeea18c9cd4ec1b9a6c16df5f646fe
- version: 1.0

## Description

The end of month effect is a well known trading strategy in the stock market. Quite simply, most stocks go up at the end of the month. What's even better is that this effect spills over to the next phew days of the next month.

In this script we backtest this theory which should work especially well on SP500 pair.

[b]By default the strategy buys 2 days before the end of each month and exits the position 3 days into the next month.[/b] 

The strategy is a long only strategy and is extremely simple. The SP500 is one of the #1 assets people use for long term investing due to it's "9.8%" annualised return. However as a trader you want the best deal possible. This strategy is only inside the market for about 25% of the time while delivering a similar return per exposure with a lower drawdown.

[b]Here are some hypothesis why turn of the month effect happens in the stock markets:[/b]
[list=1]
[*]Increased inflow from savings accounts to stocks at end of month
[*]Rebalancing of portfolios by fund managers at end of month
[*]The timing of monthly cash flows received by pension funds, which are reinvested in the stock market.
[/list]

The script also has some inputs to define how many days before end of the month you want to buy the asset and how long you want to hold it into the next month. 

[i]It is not possible to buy the asset exactly on this day every month as the market closes on the weekend. I've added some logic where it will check if that day is a friday, saturdady or sunday. If that is the case it will send the buy signal on the end of thursday, this way we enter on the friday and don't lose that months trading opportunity.[/i]

The backtest below uses 4% exposure per trade as to show the equity curve more clearly and because of publishing rules. However, most fund managers and investors use 100% exposure. This way you actually risk money to earn money. Feel free to adjust the settings to your risk profile to get a clearer picture of risks and rewards before implementing in your portfolio.

## Source Code

````pine
//@version=5
//@author Honestcowboy
//
strategy("Turn of the Month", max_lines_count = 500, max_boxes_count = 500, overlay = true, default_qty_type = strategy.percent_of_equity, default_qty_value = 4, initial_capital = 20000, commission_value = 0.03)

  
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> User Inputs <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

daysBeforeEndOfMonth  = input.int(2)
daysAfterStartOfMonth = input.int(3)

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> IMMUTABLE CONSTANTS <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

var january   = 31
var february  = 29
var march     = 31
var april     = 30
var may       = 31
var june      = 30
var july      = 31
var august    = 31
var september = 30
var october   = 31
var november  = 30
var december  = 31

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> Functions <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

getEntryDay(daysBeforeEnd) =>
    entryBar = 0
    if month == 1
        entryBar := january-daysBeforeEnd
    if month == 2
        entryBar := february-daysBeforeEnd
    if month == 3
        entryBar := march-daysBeforeEnd
    if month == 4
        entryBar := april-daysBeforeEnd
    if month == 5
        entryBar := may-daysBeforeEnd
    if month == 6
        entryBar := june-daysBeforeEnd
    if month == 7
        entryBar := july-daysBeforeEnd
    if month == 8
        entryBar := august-daysBeforeEnd
    if month == 9
        entryBar := september-daysBeforeEnd
    if month == 10
        entryBar := october-daysBeforeEnd
    if month == 11
        entryBar := november-daysBeforeEnd
    if month == 12
        entryBar := december-daysBeforeEnd
    [entryBar]

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> VARIABLE CALCULATIONS <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

[entryBar] = getEntryDay(daysBeforeEndOfMonth)

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> GRAPHICAL DISPLAY <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

barcolor(dayofmonth == entryBar ? color.fuchsia : na)

// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>
// ---------> AUTOMATION AND BACKTESTING <----------- >>
// $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ >>

longCondition = (dayofmonth >= entryBar) or ((dayofweek == 4) and dayofmonth == (entryBar-1)) or ((dayofweek == 4) and dayofmonth == (entryBar-2)) or ((dayofweek == 4) and dayofmonth == (entryBar-3))
closeCondition = ((dayofmonth >= daysAfterStartOfMonth) or (dayofweek == 4 and dayofmonth == daysAfterStartOfMonth-1) or (dayofweek == 4 and dayofmonth == daysAfterStartOfMonth-2) or (dayofweek == 4 and dayofmonth == daysAfterStartOfMonth-3)) and (dayofmonth < entryBar-10)
if longCondition and strategy.position_size==0
    strategy.entry("LONG", strategy.long)
if closeCondition
    strategy.close("LONG")
````
