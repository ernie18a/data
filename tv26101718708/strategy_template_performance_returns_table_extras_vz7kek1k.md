# Strategy Template + Performance & Returns table + Extras

- url: https://www.tradingview.com/script/vZ7KEK1k-Strategy-Template-Performance-Returns-table-Extras/
- type: strategy
- pine_id: PUB;6e2e9b72c25e476988d3eb077ca71416
- version: 6.0

## Description

A script I've been working on since summer 2022. A template for any strategy so you just have to write or paste the code and go straight into risk management settings

Features:

>Signal only Longs/only Shorts/Both
>Leverage system
>Proper fees calculation (even with leverage on)

>Different Stop Loss systems: Simple percentage, 4 different "move to Break Even" systems and Scaling SL after each TP order (read the disclaimer at the bottom regarding this and the TV % profitable metric)
>2 Take Profit systems: Simple percentages, or Risk/reward ratios based on SL level
>Additional option on TP so last one "rides free" until closure of position or Stoploss is hit (for more than 1 orders)
>Up to 5 TP orders
>Show or hide SL/TP levels on demand

>2 date filters. Manual filter is nothing new, enter two dates/hours and filter will turn on. BUT automatic filter is another thing (thanks to user @bfr_ for his help in codingthis feature)
>AUTOMATIC DATE FILTER. Allows you to split all historical data on the chart in X periods, then choose the range of periods used. Up to 10 but that can be changed, instructions included. Useful for WalkForward simulations, haven't seen a script in TradingView that allows you to do this and test your strategy on "unseen data" automatically

EXTRA SETTINGS
Besides, some additions I like to add to my codes:

>Returns table for monthly and weekly performance. Requires recalculation on every tick. This is a modified version of @QuantNomad's work. May add lower TF options later on
>Volume Based S/R system. Original work from @shtcoinr
>One feature that was made by me, the "portfolio table". Yields info and metrics of your strategy, current position and balance. You're able to turn it off and change its size

Should anyone find an error, or have any idea on how to improve this code, please contact me. Future updates could come, stay tuned

DISCLAIMER:
In order to have accurate StopLoss hit, I had to change the previous system, which was a "close position on candle close" instead at actual stoploss level. It was fixed, but resulted on inflation of the number of trading orders, thus reducing the percent profitable and making it strongly biased and unreal. Keep that in mind, that "real" profitability could be 2x or 3x the metric TradingView says. If your strategy has a really high trading frequency, resulting in 3000+ orders, might be a problem. Try to make use of the automatic/manual date filter as workaround, I have no means of changing this, seems it is not a bug but an intended design of the PineScript Code

## Source Code

````pine
//@version=6

//@Sweetz on TradingView. Contact me if you have any question or suggestion.
//This template hasn't been designed to be used with pyramiding.

strategy(title = 'Strategy Template', overlay = true, initial_capital = 1000, default_qty_type = strategy.percent_of_equity, commission_value = 0.02, process_orders_on_close = false)

//SIGNALS SETTINGS
signalSwitcher = input.string(defval = 'Both', title = 'Enable signals', options = ['Both', 'Longs', 'Shorts', 'None'], group = 'Risk settings')
bool signalLongs = signalSwitcher == 'Longs' or signalSwitcher == 'Both'
bool signalShorts = signalSwitcher == 'Shorts' or signalSwitcher == 'Both'

long_StopLossType = input.string(title = 'Stop Loss Type: (L)', defval = 'Simple', options = ['Disabled', 'Simple', 'Break Even 1', 'Break Even 2', 'Break Even 3', 'Break Even 4', 'Scaling'], group = 'Risk settings', inline = 'StopLoss Types', tooltip = 'Simple: Percentage loss from entry\n\nBreak Even (n): As TP levels are claimed, SL will be moved in (n) steps towards entry price\n\nScaling: SL is not moved towards entry but to the previous level, SL to BE when TP1 claimed, from BE to TP1 when TP2, so on')
bool long_SL_Simple = long_StopLossType == 'Simple'
bool long_SL_BreakEven1 = long_StopLossType == 'Break Even 1'
bool long_SL_BreakEven2 = long_StopLossType == 'Break Even 2'
bool long_SL_BreakEven3 = long_StopLossType == 'Break Even 3'
bool long_SL_BreakEven4 = long_StopLossType == 'Break Even 4'
bool long_SL_Scaling = long_StopLossType == 'Scaling'
bool long_SL_Any = long_StopLossType != 'Disabled'

long_TakeProfitType = input.string(title = 'Take Profit Type: (L)', defval = 'Percentage', options = ['Disabled', 'Percentage', 'Risk/Reward Ratio'], group = 'Risk settings', inline = 'TakeProfit Types', tooltip = 'Take Profit levels based on percentage are self describing\n\nRisk/Reward based levels ALWAYS require a StopLoss system, keep that in mind')
bool long_TP_Percentage = long_TakeProfitType == 'Percentage'
bool long_TP_Ratio = long_TakeProfitType == 'Risk/Reward Ratio'

long_numberOrders = input.int(defval = 5, title = 'Number of Orders: (L)', options = [1, 2, 3, 4, 5], group = 'Risk settings', inline = 'Order Numbers')
bool numberLongs_one = long_numberOrders >= 1
bool numberLongs_two = long_numberOrders >= 2
bool numberLongs_three = long_numberOrders >= 3
bool numberLongs_four = long_numberOrders >= 4
bool numberLongs_five = long_numberOrders == 5

short_StopLossType = input.string(title = '(S)', defval = 'Simple', options = ['Disabled', 'Simple', 'Break Even 1', 'Break Even 2', 'Break Even 3', 'Break Even 4', 'Scaling'], group = 'Risk settings', inline = 'StopLoss Types', tooltip = 'Simple: Percentage loss from entry\n\nBreak Even (n): As TP levels are claimed, SL will be moved in (n) steps towards entry price\n\nScaling: SL is not moved towards entry but to the previous level, SL to BE when TP1 claimed, from BE to TP1 when TP2, so on')
bool short_SL_Simple = short_StopLossType == 'Simple'
bool short_SL_BreakEven1 = short_StopLossType == 'Break Even 1'
bool short_SL_BreakEven2 = short_StopLossType == 'Break Even 2'
bool short_SL_BreakEven3 = short_StopLossType == 'Break Even 3'
bool short_SL_BreakEven4 = short_StopLossType == 'Break Even 4'
bool short_SL_Scaling = short_StopLossType == 'Scaling'
bool short_SL_Any = short_StopLossType != 'Disabled'

short_TakeProfitType = input.string(title = '(S)', defval = 'Percentage', options = ['Disabled', 'Percentage', 'Risk/Reward Ratio'], group = 'Risk settings', inline = 'TakeProfit Types', tooltip = 'Take Profit levels based on percentage are self describing\n\nRisk/Reward based levels ALWAYS require a StopLoss system, keep that in mind')
bool short_TP_Percentage = short_TakeProfitType == 'Percentage'
bool short_TP_Ratio = short_TakeProfitType == 'Risk/Reward Ratio'

short_numberOrders = input.int(defval = 5, title = '(S)', options = [1, 2, 3, 4, 5], group = 'Risk settings', inline = 'Order Numbers')
bool numberShorts_one = short_numberOrders >= 1
bool numberShorts_two = short_numberOrders >= 2
bool numberShorts_three = short_numberOrders >= 3
bool numberShorts_four = short_numberOrders >= 4
bool numberShorts_five = short_numberOrders == 5

pos_RideFree_L = input.bool(true, title = '[TP] Ride Free (L)', group = 'Risk settings', inline = 'Ride Free Settings')
pos_RideFree_S = input.bool(true, title = '(S)', tooltip = 'If true, the last order (if more than 1 is set) won\'t ever be activated, leaving the position ride free', group = 'Risk settings', inline = 'Ride Free Settings')

setLeverage = input.int(defval = 10, title = 'Position Leverage', minval = 1, maxval = 125, step = 1, group = 'Risk settings')
max_acceptedLoss = input.float(defval = 10, title = 'Maximum Accepted Loss %', minval = 0, maxval = 100, step = 1, group = 'Risk settings', tooltip = 'Maximum acepted loss per trade, actual SL can be lower due to selected StopLoss system. Also used as the simple SL level') / 100 / setLeverage
amount_per_trade = input.int(10, title = 'Equity % per trade', minval = 1, maxval = 100, step = 1, group = 'Risk settings', tooltip = 'This overwrites the default TV property') / 100
leveraged_size = strategy.equity * setLeverage / close * amount_per_trade

//SHOW SETTINGS
show_TP_SL_lines = input.string(title = 'Show TP/SL lines', defval = 'Entry+TP+SL', options = ['Entry+TP+SL', 'Entry+SL', 'Disable all'], group = 'Risk settings')
bool i_show_Entry = show_TP_SL_lines == 'Entry+TP+SL' or show_TP_SL_lines == 'Entry+SL'
bool i_show_TPLevels = show_TP_SL_lines == 'Entry+TP+SL'
bool i_show_CurrentSL = show_TP_SL_lines == 'Entry+TP+SL' or show_TP_SL_lines == 'Entry+SL'

//TAKING PROFIT ENTRIES
TP1Level = input.float(defval = 30, title = 'TP1: %', group = 'Taking Profit Levels', inline = 'Take Profit levels 1') / 100 / setLeverage
TP2Level = input.float(defval = 60, title = 'TP2: %', group = 'Taking Profit Levels', inline = 'Take Profit levels 2') / 100 / setLeverage
TP3Level = input.float(defval = 90, title = 'TP3: %', group = 'Taking Profit Levels', inline = 'Take Profit levels 3') / 100 / setLeverage
TP4Level = input.float(defval = 120, title = 'TP4: %', group = 'Taking Profit Levels', inline = 'Take Profit levels 4') / 100 / setLeverage
TP5Level = input.float(defval = 150, title = 'TP5: %', group = 'Taking Profit Levels', inline = 'Take Profit levels 5') / 100 / setLeverage

TP1Ratio = input.float(defval = 1.0, title = 'Ratio', group = 'Taking Profit Levels', inline = 'Take Profit levels 1')
TP2Ratio = input.float(defval = 2.0, title = 'Ratio', group = 'Taking Profit Levels', inline = 'Take Profit levels 2')
TP3Ratio = input.float(defval = 3.0, title = 'Ratio', group = 'Taking Profit Levels', inline = 'Take Profit levels 3')
TP4Ratio = input.float(defval = 4.0, title = 'Ratio', group = 'Taking Profit Levels', inline = 'Take Profit levels 4')
TP5Ratio = input.float(defval = 5.0, title = 'Ratio', group = 'Taking Profit Levels', inline = 'Take Profit levels 5')


//INPUT SETTINGS=========================================================================================================================================================================================================================================================================================================================================================================================

//Here you would add input functions for your strategy calculation 
lenght_fast = input(12, group = 'Indicator Settings')
lenght_slow = input(27, group = 'Indicator Settings')
//SUPERTREND===================================
ST_Filter = input.bool(false, 'SuperTrend Filter', group = 'Indicator Settings')
atrPeriod = 10
factor = 3.0
ST_Filter_Show = input.bool(false, 'Show SuperTrend', group = 'Indicator Settings')

//INDICATORS===============================================================================================================================================================================================================================================================================================================================================================================================

//Here you would add the code of every indicator or formula that introduces conditions for positions
test_fast = ta.sma(close, lenght_fast)
test_slow = ta.sma(close, lenght_slow)
bullish = ta.crossover(test_fast, test_slow)
bearish = ta.crossunder(test_fast, test_slow)
//SUPERTREND FILTER------------------------------
[supertrend, direction] = ta.supertrend(factor, atrPeriod)

//STRATEGY ===================================================================================================================================================================================================================================================================================================================================================================

SPRtrend_condition_L = close > supertrend
SPRtrend_condition_S = close < supertrend

//And here I usually add those conditions or group of conditions that trigger an Open Long/Short Signal
long = bullish

short = bearish

//Detonators
openLongSignal = not ST_Filter ? long : long and SPRtrend_condition_L //Here you'd edit the opening conditions, keep the rest of the section untouched
openShortSignal = not ST_Filter ? short : short and SPRtrend_condition_S //

closeLongSignal = openShortSignal
closeShortSignal = openLongSignal

bool isActiveLong = (openLongSignal or strategy.position_size > 0) and not closeLongSignal
bool isActiveShort = (openShortSignal or strategy.position_size < 0) and not closeShortSignal

//---DATE RANGE FILTER SETTINGS---//                                                                                                                Managed to make this new feature with the help of @bfr_
dateFilter = input.string(defval = 'No', title = 'Date filter:', options = ['Automatic', 'Manual input', 'No'], group = 'Time range settings', tooltip = 'Feature improved so automatic filter would help me (and you) through walk forward backtesting\n\nManual input is the simplest date input')
bool autoFilter = dateFilter == 'Automatic'
bool manualFilter = dateFilter == 'Manual input'

numberDivisions = input.int(defval = 10, minval = 1, maxval = 10, title = 'Number of divisions', group = 'Time range settings', tooltip = 'These 3 settings must respect some rules, or else the automatic filter won\'t work and yield an error sign\n\nStart must not be equal to or higher than Finish, and neither can be higher than the Number of divisions')
rangeStart = input.int(defval = 0, minval = 0, maxval = 9, title = 'Start->Finish', group = 'Time range settings', inline = 'Start-Finish')
rangeFinish = input.int(defval = 10, minval = 1, maxval = 10, title = '', group = 'Time range settings', inline = 'Start-Finish')

rangePlotError = rangeStart > rangeFinish or rangeFinish > numberDivisions or rangeStart == numberDivisions or rangeStart == rangeFinish
if rangePlotError and barstate.islast //This will warn of wrong settings
    label.new(bar_index + 30, close, 'WALKFORWARD WRONG SETTINGS', color = #ff000080, textcolor = #ffffff, style = label.style_label_left)
//
var int firstTime = na
if barstate.isfirst
    firstTime := time
//
dateFirst = math.round((last_bar_time - firstTime) / numberDivisions) * rangeStart + firstTime
dateLast = math.round((last_bar_time - firstTime) / numberDivisions) * rangeFinish + firstTime

inRange_auto = time >= dateFirst and time <= dateLast and autoFilter

//Manual date filter
rangeStart_manual = input.time(timestamp('01 Jan 2000 00:00:00'), 'Manual range: Start', group = 'Time range settings', confirm = false) //Set confirm to true so script forces you to set the range when adding it to the chart. Not my taste.
rangeFinish_manual = input.time(timestamp('01 Jan 2030 00:00:00'), 'Manual range: Finish', group = 'Time range settings', confirm = false)

inRange_manual = time >= rangeStart_manual and time <= rangeFinish_manual and manualFilter
inRange_both = not autoFilter and not manualFilter ? true : inRange_auto or inRange_manual

//LONG ARRAYS, TP AND SL LOGIC ===============================================================================================================================================================================================================================================================================================================================================

float LongStopLossLevel = na
float longTP1L = na
float longTP2L = na
float longTP3L = na
float longTP4L = na
float longTP5L = na
long_starting_level = strategy.position_size < 0 ? close : strategy.position_size >= 0 ? strategy.position_avg_price : na

if long_TP_Percentage
    longTP1L := (1 + TP1Level) * long_starting_level
    longTP2L := (1 + TP2Level) * long_starting_level
    longTP3L := (1 + TP3Level) * long_starting_level
    longTP4L := (1 + TP4Level) * long_starting_level
    longTP5L := (1 + TP5Level) * long_starting_level
if long_TP_Ratio
    if long_SL_Any
        Simple_SL_Diff = math.abs(long_starting_level - long_starting_level * (1 - max_acceptedLoss))
        longTP1L := long_starting_level + Simple_SL_Diff * TP1Ratio
        longTP2L := long_starting_level + Simple_SL_Diff * TP2Ratio
        longTP3L := long_starting_level + Simple_SL_Diff * TP3Ratio
        longTP4L := long_starting_level + Simple_SL_Diff * TP4Ratio
        longTP5L := long_starting_level + Simple_SL_Diff * TP5Ratio

bool longTP1hit = high >= longTP1L
bool longTP2hit = high >= longTP2L
bool longTP3hit = high >= longTP3L
bool longTP4hit = high >= longTP4L
bool longTP5hit = high >= longTP5L

if isActiveLong
    if long_SL_Simple
        LongStopLossLevel := long_starting_level * (1 - max_acceptedLoss)
    if long_SL_Scaling
        if openLongSignal and not(strategy.position_size > 0)
            LongStopLossLevel := close * (1 - max_acceptedLoss)
        else
            longSteppedStopLoss = longTP5hit ? longTP4L : longTP4hit ? longTP3L : longTP3hit ? longTP2L : longTP2hit ? longTP1L : longTP1hit ? strategy.position_avg_price : long_starting_level * (1 - max_acceptedLoss)
            LongStopLossLevel := math.max(longSteppedStopLoss, nz(LongStopLossLevel[1]))
    if long_SL_BreakEven1
        if openLongSignal and not(strategy.position_size > 0)
            LongStopLossLevel := close * (1 - max_acceptedLoss)
        else
            longBEStopLoss = longTP1hit ? strategy.position_avg_price : long_starting_level * (1 - max_acceptedLoss)
            LongStopLossLevel := math.max(longBEStopLoss, nz(LongStopLossLevel[1]))
    if long_SL_BreakEven2
        if openLongSignal and not(strategy.position_size > 0)
            LongStopLossLevel := close * (1 - max_acceptedLoss)
        else
            longBEStopLoss = longTP2hit ? strategy.position_avg_price : longTP1hit ? long_starting_level * (1 - max_acceptedLoss) + (strategy.position_avg_price - long_starting_level * (1 - max_acceptedLoss)) / 2 : long_starting_level * (1 - max_acceptedLoss)
            LongStopLossLevel := math.max(longBEStopLoss, nz(LongStopLossLevel[1]))
    if long_SL_BreakEven3
        if openLongSignal and not(strategy.position_size > 0)
            LongStopLossLevel := close * (1 - max_acceptedLoss)
        else
            longBEStopLoss = longTP3hit ? strategy.position_avg_price : longTP2hit ? long_starting_level * (1 - max_acceptedLoss) + 2 * ((strategy.position_avg_price - long_starting_level * (1 - max_acceptedLoss)) / 3) : longTP1hit ? long_starting_level * (1 - max_acceptedLoss) + (strategy.position_avg_price - long_starting_level * (1 - max_acceptedLoss)) / 3 : long_starting_level * (1 - max_acceptedLoss)
            LongStopLossLevel := math.max(longBEStopLoss, nz(LongStopLossLevel[1]))
    if long_SL_BreakEven4
        if openLongSignal and not(strategy.position_size > 0)
            LongStopLossLevel := close * (1 - max_acceptedLoss)
        else
            longBEStopLoss = longTP4hit ? strategy.position_avg_price : longTP3hit ? long_starting_level * (1 - max_acceptedLoss) + 3 * ((strategy.position_avg_price - long_starting_level * (1 - max_acceptedLoss)) / 4) : longTP2hit ? long_starting_level * (1 - max_acceptedLoss) + 2 * ((strategy.position_avg_price - long_starting_level * (1 - max_acceptedLoss)) / 4) : longTP1hit ? long_starting_level * (1 - max_acceptedLoss) + (strategy.position_avg_price - long_starting_level * (1 - max_acceptedLoss)) / 4 : long_starting_level * (1 - max_acceptedLoss)
            LongStopLossLevel := math.max(longBEStopLoss, nz(LongStopLossLevel[1]))
bool longSLHIT = low < LongStopLossLevel


//SHORT ARRAYS, TP AND SL LOGIC =======================================================================================================================================================================================================================================================================================================================================

float ShortStopLossLevel = na
float shortTP1L = na
float shortTP2L = na
float shortTP3L = na
float shortTP4L = na
float shortTP5L = na
short_starting_level = strategy.position_size > 0 ? close : strategy.position_size <= 0 ? strategy.position_avg_price : na

if short_TP_Percentage
    shortTP1L := (1 - TP1Level) * short_starting_level
    shortTP2L := (1 - TP2Level) * short_starting_level
    shortTP3L := (1 - TP3Level) * short_starting_level
    shortTP4L := (1 - TP4Level) * short_starting_level
    shortTP5L := (1 - TP5Level) * short_starting_level
if short_TP_Ratio
    if short_SL_Any
        Simple_SL_Diff = math.abs(short_starting_level - short_starting_level * (1 + max_acceptedLoss))
        shortTP1L := short_starting_level - Simple_SL_Diff * TP1Ratio
        shortTP2L := short_starting_level - Simple_SL_Diff * TP2Ratio
        shortTP3L := short_starting_level - Simple_SL_Diff * TP3Ratio
        shortTP4L := short_starting_level - Simple_SL_Diff * TP4Ratio
        shortTP5L := short_starting_level - Simple_SL_Diff * TP5Ratio

bool shortTP1hit = low <= shortTP1L
bool shortTP2hit = low <= shortTP2L
bool shortTP3hit = low <= shortTP3L
bool shortTP4hit = low <= shortTP4L
bool shortTP5hit = low <= shortTP5L

if isActiveShort
    if short_SL_Simple
        ShortStopLossLevel := short_starting_level * (1 + max_acceptedLoss)
    if short_SL_Scaling
        if openShortSignal and not(strategy.position_size < 0)
            ShortStopLossLevel := close * (1 + max_acceptedLoss)
        else
            shortSteppedStopLoss = shortTP5hit ? shortTP4L : shortTP4hit ? shortTP3L : shortTP3hit ? shortTP2L : shortTP2hit ? shortTP1L : shortTP1hit ? strategy.position_avg_price : short_starting_level * (1 + max_acceptedLoss)
            ShortStopLossLevel := math.min(shortSteppedStopLoss, nz(ShortStopLossLevel[1]))
    if short_SL_BreakEven1
        if openShortSignal and not(strategy.position_size < 0)
            ShortStopLossLevel := close * (1 + max_acceptedLoss)
        else
            shortBEStopLoss = shortTP1hit ? strategy.position_avg_price : short_starting_level * (1 + max_acceptedLoss)
            ShortStopLossLevel := math.min(shortBEStopLoss, nz(ShortStopLossLevel[1]))
    if short_SL_BreakEven2
        if openShortSignal and not(strategy.position_size < 0)
            ShortStopLossLevel := close * (1 + max_acceptedLoss)
        else
            shortBEStopLoss = shortTP2hit ? strategy.position_avg_price : shortTP1hit ? short_starting_level * (1 + max_acceptedLoss) + (strategy.position_avg_price - short_starting_level * (1 + max_acceptedLoss)) / 2 : short_starting_level * (1 + max_acceptedLoss)
            ShortStopLossLevel := math.min(shortBEStopLoss, nz(ShortStopLossLevel[1]))
    if short_SL_BreakEven3
        if openShortSignal and not(strategy.position_size < 0)
            ShortStopLossLevel := close * (1 + max_acceptedLoss)
        else
            shortBEStopLoss = shortTP3hit ? strategy.position_avg_price : shortTP2hit ? short_starting_level * (1 + max_acceptedLoss) + 2 * ((strategy.position_avg_price - short_starting_level * (1 + max_acceptedLoss)) / 3) : shortTP1hit ? short_starting_level * (1 + max_acceptedLoss) + (strategy.position_avg_price - short_starting_level * (1 + max_acceptedLoss)) / 3 : short_starting_level * (1 + max_acceptedLoss)
            ShortStopLossLevel := math.min(shortBEStopLoss, nz(ShortStopLossLevel[1]))
    if short_SL_BreakEven4
        if openShortSignal and not(strategy.position_size < 0)
            ShortStopLossLevel := close * (1 + max_acceptedLoss)
        else
            shortBEStopLoss = shortTP4hit ? strategy.position_avg_price : shortTP3hit ? short_starting_level * (1 + max_acceptedLoss) + 3 * ((strategy.position_avg_price - short_starting_level * (1 + max_acceptedLoss)) / 4) : shortTP2hit ? short_starting_level * (1 + max_acceptedLoss) + 2 * ((strategy.position_avg_price - short_starting_level * (1 + max_acceptedLoss)) / 4) : shortTP1hit ? short_starting_level * (1 + max_acceptedLoss) + (strategy.position_avg_price - short_starting_level * (1 + max_acceptedLoss)) / 4 : short_starting_level * (1 + max_acceptedLoss)
            ShortStopLossLevel := math.min(shortBEStopLoss, nz(ShortStopLossLevel[1]))
bool shortSLHIT = high > ShortStopLossLevel


//LONG AND SHORT LINES PLOTS    ===============================================================================================================================================================================================================

//--TP LINES PLOT--//
float plotEntry = na
if isActiveLong and inRange_both and i_show_Entry
    if strategy.position_size < 0
        plotEntry := close
    else
        if strategy.position_size >= 0
            plotEntry := strategy.position_avg_price
if isActiveShort and inRange_both and i_show_Entry
    if strategy.position_size > 0
        plotEntry := close
    else
        if strategy.position_size <= 0
            plotEntry := strategy.position_avg_price

float plotSL = na
if isActiveLong and inRange_both and i_show_CurrentSL and strategy.position_size > 0
    plotSL := LongStopLossLevel
if isActiveShort and inRange_both and i_show_CurrentSL and strategy.position_size < 0
    plotSL := ShortStopLossLevel

float plotTP1 = na
if isActiveLong and inRange_both and i_show_TPLevels and strategy.position_size > 0
    plotTP1 := longTP1L
if isActiveShort and inRange_both and i_show_TPLevels and strategy.position_size < 0
    plotTP1 := shortTP1L

float plotTP2 = na
if isActiveLong and inRange_both and i_show_TPLevels and strategy.position_size > 0 and numberLongs_two
    plotTP2 := longTP2L
if isActiveShort and inRange_both and i_show_TPLevels and strategy.position_size < 0 and numberShorts_two
    plotTP2 := shortTP2L

float plotTP3 = na
if isActiveLong and inRange_both and i_show_TPLevels and strategy.position_size > 0 and numberLongs_three
    plotTP3 := longTP3L
if isActiveShort and inRange_both and i_show_TPLevels and strategy.position_size < 0 and numberShorts_three
    plotTP3 := shortTP3L

float plotTP4 = na
if isActiveLong and inRange_both and i_show_TPLevels and strategy.position_size > 0 and numberLongs_four
    plotTP4 := longTP4L
if isActiveShort and inRange_both and i_show_TPLevels and strategy.position_size < 0 and numberShorts_four
    plotTP4 := shortTP4L

float plotTP5 = na
if isActiveLong and inRange_both and i_show_TPLevels and strategy.position_size > 0 and numberLongs_five
    plotTP5 := longTP5L
if isActiveShort and inRange_both and i_show_TPLevels and strategy.position_size < 0 and numberShorts_five
    plotTP5 := shortTP5L
    //
plot(plotEntry, title = 'Entry Price', color = #FFFFFF, linewidth = 1, style = plot.style_cross)
plot(plotSL, 'StopLoss Price', color = isActiveLong ? #0044ff : isActiveShort ? #ff7800 : na, linewidth = 2, style = plot.style_circles, offset = 0)
plot(plotTP1, title = 'TP 1', color = #00e2ff80, linewidth = 1, style = plot.style_circles, offset = 0)
plot(plotTP2, title = 'TP 2', color = #0bff0080, linewidth = 1, style = plot.style_circles, offset = 0)
plot(plotTP3, title = 'TP 3', color = #ffe50080, linewidth = 1, style = plot.style_circles, offset = 0)
plot(plotTP4, title = 'TP 4', color = #ff780080, linewidth = 1, style = plot.style_circles, offset = 0)
plot(plotTP5, title = 'TP 5', color = #ff000080, linewidth = 1, style = plot.style_circles, offset = 0)

bodyMiddle = plot(ST_Filter_Show ? (open + close) / 2 : na, display = display.none)
upTrnd = plot(direction < 0 and ST_Filter_Show ? supertrend : na, '+ SuperTrend', color = color.green, style = plot.style_linebr)
dnTrnd = plot(direction > 0 and ST_Filter_Show ? supertrend : na, '- SuperTrend', color = color.red, style = plot.style_linebr)
fill(bodyMiddle, upTrnd, color.new(color.green, 95), fillgaps = false, title = 'Bullish SuperTrend')
fill(bodyMiddle, dnTrnd, color.new(color.red, 95), fillgaps = false, title = 'Bearish SuperTrend')

bgcolor(autoFilter and inRange_auto and not rangePlotError ? #00ff0008 : autoFilter and not rangePlotError ? #ff000008 : autoFilter ? #ffffff15 : na, title = 'Date filter color')

//BACKTESTING   =============================================================================================================================================================================================================================

// LONG ORDERS  ============================
order_quantity_longs = numberLongs_five ? 20 : numberLongs_four ? 25 : numberLongs_three ? 33 : numberLongs_two ? 50 : 100
longTPhit_last = numberLongs_five ? longTP5hit : numberLongs_four ? longTP4hit : numberLongs_three ? longTP3hit : numberLongs_two ? longTP2hit : longTP1hit
if signalLongs and inRange_both
    if not pos_RideFree_L ? closeLongSignal or longTPhit_last : closeLongSignal
        strategy.close(id = 'Long', alert_message = 'Long(' + syminfo.ticker + '): Closed position', comment = 'C')
    if openLongSignal
        strategy.entry(id = 'Long', direction = strategy.long, alert_message = 'Long(' + syminfo.ticker + '): Started', comment = 'Open L', qty = leveraged_size)
    if isActiveLong
        strategy.exit(id = 'Long Scaling TP1', from_entry = 'Long', stop = LongStopLossLevel, limit = longTP1L, alert_message = 'Long(' + syminfo.ticker + '): TP1 Hit', comment = 'L1', comment_profit = 'L1 Profit', comment_loss = 'L1 Stop', qty_percent = not numberLongs_two ? 100 : order_quantity_longs)
        if numberLongs_two
            strategy.exit(id = 'Long Scaling TP2', from_entry = 'Long', stop = LongStopLossLevel, limit = not numberLongs_three and pos_RideFree_L ? na : longTP2L, alert_message = 'Long(' + syminfo.ticker + '): TP2 Hit', comment = 'L2', comment_profit = 'L2 Profit', comment_loss = 'L2 Stop', qty_percent = not numberLongs_three ? 100 : order_quantity_longs)
        if numberLongs_three
            strategy.exit(id = 'Long Scaling TP3', from_entry = 'Long', stop = LongStopLossLevel, limit = not numberLongs_four and pos_RideFree_L ? na : longTP3L, alert_message = 'Long(' + syminfo.ticker + '): TP3 Hit', comment = 'L3', comment_profit = 'L3 Profit', comment_loss = 'L3 Stop', qty_percent = not numberLongs_four ? 100 : order_quantity_longs)
        if numberLongs_four
            strategy.exit(id = 'Long Scaling TP4', from_entry = 'Long', stop = LongStopLossLevel, limit = not numberLongs_five and pos_RideFree_L ? na : longTP4L, alert_message = 'Long(' + syminfo.ticker + '): TP4 Hit', comment = 'L4', comment_profit = 'L4 Profit', comment_loss = 'L4 Stop', qty_percent = not numberLongs_five ? 100 : order_quantity_longs)
        if numberLongs_five
            strategy.exit(id = 'Long Scaling TP5', from_entry = 'Long', stop = LongStopLossLevel, limit = pos_RideFree_L ? na : longTP5L, alert_message = 'Long(' + syminfo.ticker + '): TP5 Hit', comment = 'L5', comment_profit = 'L5 Profit', comment_loss = 'L5 Stop', qty_percent = 100)
            // SHORT ORDERS ============================
order_quantity_shorts = numberShorts_five ? 20 : numberShorts_four ? 25 : numberShorts_three ? 33 : numberShorts_two ? 50 : 100
shortTPhit_last = numberShorts_five ? shortTP5hit : numberShorts_four ? shortTP4hit : numberShorts_three ? shortTP3hit : numberShorts_two ? shortTP2hit : shortTP1hit
if signalShorts and inRange_both
    if not pos_RideFree_S ? closeShortSignal or shortTPhit_last : closeShortSignal
        strategy.close(id = 'Short', alert_message = 'Short(' + syminfo.ticker + '): Closed position', comment = 'C')
    if openShortSignal
        strategy.entry(id = 'Short', direction = strategy.short, alert_message = 'Short(' + syminfo.ticker + '): Started', comment = 'Open S', qty = leveraged_size)
    if isActiveShort
        strategy.exit(id = 'Short Scaling TP1', from_entry = 'Short', stop = ShortStopLossLevel, limit = shortTP1L, alert_message = 'Short(' + syminfo.ticker + '): TP1 Hit', comment = 'S1', comment_profit = 'S1 Profit', comment_loss = 'S1 Stop', qty_percent = not numberShorts_two ? 100 : order_quantity_shorts)
        if numberShorts_two
            strategy.exit(id = 'Short Scaling TP2', from_entry = 'Short', stop = ShortStopLossLevel, limit = not numberShorts_three and pos_RideFree_S ? na : shortTP2L, alert_message = 'Short(' + syminfo.ticker + '): TP2 Hit', comment = 'S2', comment_profit = 'S2 Profit', comment_loss = 'S2 Stop', qty_percent = not numberShorts_three ? 100 : order_quantity_shorts)
        if numberShorts_three
            strategy.exit(id = 'Short Scaling TP3', from_entry = 'Short', stop = ShortStopLossLevel, limit = not numberShorts_four and pos_RideFree_S ? na : shortTP3L, alert_message = 'Short(' + syminfo.ticker + '): TP3 Hit', comment = 'S3', comment_profit = 'S3 Profit', comment_loss = 'S3 Stop', qty_percent = not numberShorts_four ? 100 : order_quantity_shorts)
        if numberShorts_four
            strategy.exit(id = 'Short Scaling TP4', from_entry = 'Short', stop = ShortStopLossLevel, limit = not numberShorts_five and pos_RideFree_S ? na : shortTP4L, alert_message = 'Short(' + syminfo.ticker + '): TP4 Hit', comment = 'S4', comment_profit = 'S4 Profit', comment_loss = 'S4 Stop', qty_percent = not numberShorts_five ? 100 : order_quantity_shorts)
        if numberShorts_five
            strategy.exit(id = 'Short Scaling TP5', from_entry = 'Short', stop = ShortStopLossLevel, limit = pos_RideFree_S ? na : shortTP5L, alert_message = 'Short(' + syminfo.ticker + '): TP5 Hit', comment = 'S5', comment_profit = 'S5 Profit', comment_loss = 'S5 Stop', qty_percent = 100)
            //
plotshape(strategy.position_size <= 0 ? openLongSignal : false, style = shape.triangleup, location = location.bottom, color = #00ff00, size = size.small)
plotshape(strategy.position_size >= 0 ? openShortSignal : false, style = shape.triangledown, location = location.bottom, color = #ff0000, size = size.small)

// # ========================================================================= #
// #                   |   Portfolio table |
// # ========================================================================= #

tfString(int timeInMs) =>
    float s = timeInMs / 1000
    float m = s / 60
    float h = m / 60
    float d = h / 24
    float mo = d / 30.41666666666666666666
    int tm = math.floor(m % 60)
    int tr = math.floor(h % 24)
    int td = math.floor(d % 30.41666666666666666666)
    int tmo = math.floor(mo % 12)
    int ys = math.floor(d / 365)

    string result = switch 
        d == 30 and tr == 10 and tm == 0 => '1M'
        d == 7 and tr == 0 and tm == 0 => '1W'
        => 
    	    string yStr = not na(ys) ? str.tostring(ys) + 'Y ' : ''
    	    string moStr = not na(tmo) ? str.tostring(tmo) + 'M ' : ''
    	    string dStr = not na(td) ? str.tostring(td) + 'D ' : ''
    	    string hStr = not na(tr) ? str.tostring(tr) + 'H ' : ''
    	    string mStr = not na(tm) ? str.tostring(tm) + 'min' : ''
    	    yStr + moStr + dStr + hStr + mStr

table_initial_capital = strategy.initial_capital
table_net_profit = strategy.netprofit
table_realised_balance = strategy.initial_capital + strategy.netprofit
table_open_profit = strategy.openprofit
table_equity = strategy.equity
table_profitability = strategy.wintrades / (strategy.wintrades + strategy.losstrades) * 100
table_trading_time = strategy.closedtrades.exit_time(strategy.closedtrades - 1) - strategy.closedtrades.entry_time(0)
table_avg_price = nz(strategy.position_avg_price)
table_position_size = math.abs(strategy.position_size) / setLeverage
table_position_cost = table_position_size * table_avg_price
table_cash = strategy.initial_capital + strategy.netprofit - table_position_size * table_avg_price
table_position_ROI = nz(table_open_profit / table_position_cost) * 100
table_profit_factor = strategy.grossprofit / strategy.grossloss
table_leverage_factor = math.abs(nz(strategy.position_size * table_avg_price / table_equity))
show_PF_table = input.string(defval = 'Normal', title = 'Portfolio table', options = ['Large', 'Normal', 'Small', 'Tiny', 'Disabled'], group = 'Extra settings', inline = 'Portfolio table')

bool PF_table_size_tiny = show_PF_table == 'Tiny'
bool PF_table_size_small = show_PF_table == 'Small'
bool PF_table_size_normal = show_PF_table == 'Normal'
bool PF_table_size_large = show_PF_table == 'Large'
bool PF_table_shown = show_PF_table != 'Disabled'
PF_table_location = input.string(defval = 'Bot left', title = ' ', options = ['Top mid', 'Top right', 'Mid right', 'Bot left', 'Bot mid', 'Bot right'], group = 'Extra settings', inline = 'Portfolio table')

string PF_table_loc = PF_table_location == 'Top mid' ? position.top_center : PF_table_location == 'Top right' ? position.top_right : PF_table_location == 'Mid right' ? position.middle_right : PF_table_location == 'Bot left' ? position.bottom_left : PF_table_location == 'Bot mid' ? position.bottom_center : PF_table_location == 'Bot right' ? position.bottom_right : na
var table portfolio_table = PF_table_shown ? table.new(PF_table_loc, 4, 7, border_width = 1) : na

ftable(_table_id, _column, _row, _text, _bgcolor) =>
    table.cell(_table_id, _column, _row, _text, 0, 0, color.black, text.align_right, text.align_center, PF_table_size_tiny ? size.tiny : PF_table_size_small ? size.small : PF_table_size_normal ? size.normal : PF_table_size_large ? size.large : na, _bgcolor)

ftable(portfolio_table, 0, 0, 'Trading Time: ', #9598a1)
ftable(portfolio_table, 1, 0, tfString(table_trading_time), #fff7d5)
ftable(portfolio_table, 0, 1, 'Profitability: ', #9598a1)
ftable(portfolio_table, 1, 1, str.tostring(table_profitability, '#.##') + ' %', #fff7d5)
ftable(portfolio_table, 0, 2, 'Equity: ', #9598a1)
ftable(portfolio_table, 1, 2, str.tostring(table_equity, '#.##') + ' ' + syminfo.currency, table_equity >= 0 ? color.green : color.red)
ftable(portfolio_table, 0, 3, 'Open Profit: ', #9598a1)
ftable(portfolio_table, 1, 3, str.tostring(table_open_profit, '#.##') + ' ' + syminfo.currency, table_open_profit >= 0 ? color.green : color.red)
ftable(portfolio_table, 0, 4, 'Realised Balance: ', #9598a1)
ftable(portfolio_table, 1, 4, str.tostring(table_realised_balance, '#.##') + ' ' + syminfo.currency, table_realised_balance >= 0 ? color.green : color.red)
ftable(portfolio_table, 0, 5, 'Net Profit: ', #9598a1)
ftable(portfolio_table, 1, 5, str.tostring(table_net_profit, '#.##') + ' ' + syminfo.currency, table_net_profit >= 0 ? color.green : color.red)
ftable(portfolio_table, 0, 6, 'Initial Capital: ', #9598a1)
ftable(portfolio_table, 1, 6, str.tostring(table_initial_capital, '#.##') + ' ' + syminfo.currency, #fff7d5)

ftable(portfolio_table, 2, 0, 'Leverage Factor: ', #9598a1)
ftable(portfolio_table, 3, 0, strategy.position_size != 0 ? str.tostring(table_leverage_factor, '#.####') : 'No pos.', #fff7d5)
ftable(portfolio_table, 2, 1, 'Profit Factor: ', #9598a1)
ftable(portfolio_table, 3, 1, str.tostring(table_profit_factor, '#.##'), #fff7d5)
ftable(portfolio_table, 2, 2, 'Position ROI: ', #9598a1)
ftable(portfolio_table, 3, 2, str.tostring(table_position_ROI, '#.##') + ' %', table_position_ROI > 0 ? color.green : table_position_ROI < 0 ? color.red : table_position_ROI == 0 ? #fff7d5 : na)
ftable(portfolio_table, 2, 3, 'Cash: ', #9598a1)
ftable(portfolio_table, 3, 3, str.tostring(table_cash, '#.##') + ' ' + syminfo.currency, #fff7d5)
ftable(portfolio_table, 2, 4, 'Position Cost: ', #9598a1)
ftable(portfolio_table, 3, 4, str.tostring(table_position_cost, '#.##') + ' ' + syminfo.currency, #fff7d5)
ftable(portfolio_table, 2, 5, 'Deleveraged Size: ', #9598a1)
ftable(portfolio_table, 3, 5, str.tostring(table_position_size, '#.########') + ' ' + syminfo.basecurrency, #fff7d5)
ftable(portfolio_table, 2, 6, 'Average Price: ', #9598a1)
ftable(portfolio_table, 3, 6, str.tostring(table_avg_price, '#.##') + ' ' + syminfo.currency, #fff7d5)
````
