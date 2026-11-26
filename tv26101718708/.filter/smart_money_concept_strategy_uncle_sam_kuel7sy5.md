# Smart Money Concept Strategy - Uncle Sam

- url: https://www.tradingview.com/script/KUeL7SY5-Smart-Money-Concept-Strategy-Uncle-Sam/
- type: strategy
- pine_id: PUB;ed13f4ea990248c7bfedd7f9710a21f7
- version: 2.0

## Description

This strategy combines concepts from two popular TradingView scripts:

Smart Money Concepts (SMC) [LuxAlgo]: The strategy identifies key levels in the market (swing highs and lows) and draws trend lines to visualize potential breakouts. It uses volume analysis to gauge the strength of these breakouts.

Smart Money Breakouts [ChartPrime]: This part of the strategy incorporates the idea of "Smart Money" – institutional traders who often lead market movements. It looks for breakouts of established levels with significant volume, aiming to catch the beginning of new trends.

How the Strategy Works:

Identification of Key Levels: The script identifies swing highs and swing lows based on a user-defined lookback period. These levels are considered significant points where price has reversed in the past.

Drawing Trend Lines: Trend lines are drawn connecting these key levels, creating a visual representation of potential support and resistance zones.

Volume Analysis: The script analyzes the volume during the formation of these levels and during breakouts. Higher volume suggests stronger moves and increases the probability of a successful breakout.

Entry Conditions:

Long Entry: A long entry is triggered when the price breaks above a resistance line with significant volume, and the moving average trend filter (optional) is bullish.
Short Entry: A short entry is triggered when the price breaks below a support line with significant volume, and the moving average trend filter (optional) is bearish.
Exit Conditions:

Stop Loss: Customizable stop loss percentages are implemented to protect against adverse price movements.
Take Profit: Customizable take profit percentages are used to lock in profits.
Credits and Compliance:

This strategy is inspired by the concepts and code from "Smart Money Concepts (SMC) [LuxAlgo]" and "Smart Money Breakouts [ChartPrime]." I've adapted and combined elements of both scripts to create this strategy.  Full credit is given to the original authors for their valuable contributions to the TradingView community.

To comply with TradingView's House Rules, I've made the following adjustments:

Clearly Stated Inspiration: The description explicitly mentions the original scripts and authors as the inspiration for this strategy.
No Direct Copying: The code has been modified and combined, not directly copied from the original scripts.
Educational Purpose: The primary purpose of this strategy is for learning and backtesting. It's not intended as financial advice.
Important Note:

This strategy is intended for educational and backtesting purposes only. It should not be used for live trading without thorough testing and understanding of the underlying concepts. Past performance is not indicative of future results.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Kostinay

//@version=5
//Thanks for the helpful Scripts from: Smart Money Concepts (SMC) [LuxAlgo] and Smart Money Breakouts [ChartPrime]



strategy('Smart Money Concept - Uncle Sam',
     shorttitle = "Smart Money Concept - Uncle Sam",
     overlay = true,
     pyramiding = 1,
     default_qty_type = strategy.percent_of_equity,
     default_qty_value = 100,
     initial_capital = 1000,
     commission_type=strategy.commission.percent,
     commission_value=0.00,
     process_orders_on_close=true,
     use_bar_magnifier=false)




// Enable Long Strategy
enable_long_strategy = input.bool(true, title='Enable Long Strategy', inline='1')
long_stoploss_value = input.float(defval=1, title='Long SL %', minval=0.1, inline='2')
long_stoploss_percentage = close * (long_stoploss_value / 100) / syminfo.mintick
long_takeprofit_value = input.float(defval=1.5, title='Long TP %', minval=0.1,inline='2')
long_takeprofit_percentage = close * (long_takeprofit_value / 100) / syminfo.mintick




// Enable Short Strategy
enable_short_strategy = input.bool(true, title='Enable Short Strategy', inline='3')
short_stoploss_value = input.float(defval=1, title='Short SL %', minval=0.1, inline='4')
short_stoploss_percentage = close * (short_stoploss_value / 100) / syminfo.mintick
short_takeprofit_value = input.float(defval=1.5, title='Short TP %', minval=0.1, inline='4')
short_takeprofit_percentage = close * (short_takeprofit_value / 100) / syminfo.mintick




// Plot Stoploss & Take Profit Levels
long_stoploss_price = strategy.position_avg_price * (1 - long_stoploss_value / 100)
long_takeprofit_price = strategy.position_avg_price * (1 + long_takeprofit_value / 100)
short_stoploss_price = strategy.position_avg_price * (1 + short_stoploss_value / 100)
short_takeprofit_price = strategy.position_avg_price * (1 - short_takeprofit_value / 100)


//@version=5
//strategy("Smart Money Breakouts - Sam", overlay=true, max_labels_count=500, max_lines_count=500)
color GREEN           = color.rgb(2, 133, 69)
color TAIL            = color.rgb(20, 141, 154)
color RED             = color.rgb(246, 7, 7)
color _Green          = color.rgb(2, 106, 89)
color OFF             = color.new(color.red,100)


//
var float UpdatedHigh = na
var float UpdatedLow  = na
var int HighIndex     = na
var bool phActive     = false
var bool plActive     = false
var int LowIndex      = na
var bool HBreak       = false
var label LAB         = na
int Sync              = bar_index
bool BUY              = false
bool SELL             = false




type Vol
    array<float> Total
    array<float> Green
    array<float> Red
    array<float> SCR


Volume = Vol.new(
     array.new_float(),
     array.new_float(),
     array.new_float(),
     array.new_float()


     )


int period            = input.int(20, 'Length', group = 'SMart Money Concept')
bool CandleType      = 'Wicks' //input.string(title = "Type ➞",
    
       == 'Wicks'

string Linestyle      = 'Dotted' //input.string('Dashed',


color Bull = color.white// input.color(GREEN,"",group=CORE,inline= "Line")
color Bear = color.white //input.color(RED,"",group=CORE,inline= "Line")    




StyleSwitch = switch Linestyle
    'Dashed' => line.style_dashed ,
    'Dotted' => line.style_dotted ,
    => line.style_solid



method volAdj(int len)=>
    math.min(ta.atr(len) * 0.3, close * (0.3/100)) [20] /2


Adj = volAdj(30)


VolCal(Index,Sync) =>
    Bars = math.abs(Index - Sync)
    for i = 0 to Bars -1
        Volume.SCR.push(close[i])


    for i = 0 to Volume.SCR.size() -1


        if Volume.SCR.get(i) > open[i]
            Volume.Green.push(volume[i])


        if Volume.SCR.get(i) < open[i]
            Volume.Red.push(volume[i])


        Volume.Total.push(volume[i])


    GreenRatio = math.round(Volume.Green.sum() / Volume.Total.sum()* 100,2)
    RedRatio = math.round(Volume.Red.sum() / Volume.Total.sum()* 100,2)
    Out = GreenRatio > 55 ? " " : RedRatio > 55 ? " " : " "
    Out



PH = ta.pivothigh(high, period, period)
PL = ta.pivotlow(low, period, period)
ScrHigh = CandleType ? high : close
ScrLow = CandleType ? low : close


if ta.change(fixnan(PH)) != 0
    UpdatedHigh := PH
    phActive    := true
    HighIndex   := Sync - period


if ta.change(fixnan(PL)) != 0
    UpdatedLow  := PL
    plActive    := true
    LowIndex    := Sync - period


// LONG
if ScrHigh > UpdatedHigh and phActive
    BUY := true
    phActive := false


//Sell
if ScrLow < UpdatedLow and plActive
    SELL := true
    plActive := false


// lets Draw


if BUY
    sign = VolCal(HighIndex,Sync)
    line.new(HighIndex,
         UpdatedHigh,
         Sync,
         UpdatedHigh,
         color=Bull,
         style=StyleSwitch,
         width=1)
    label.new(math.floor(Sync - (Sync - HighIndex) / 2),
         UpdatedHigh,
         not HBreak ? ' ' + sign  : ' ' + sign,
         color=OFF,
         textcolor=color.white,
         size=size.tiny)
    label.new(Sync,
         low,
         "",
         yloc = yloc.belowbar,
         color = color.lime,
         size = size.small,
         style = label.style_triangleup)
    HBreak := true



if SELL
    sign = VolCal(LowIndex,Sync)
    line.new(LowIndex,
         UpdatedLow,
         Sync,
         UpdatedLow,
         color=Bear,
         style=StyleSwitch,
         width=1)
    label.new(math.floor(Sync - (Sync - LowIndex) / 2),
         UpdatedLow,
         HBreak ? ' ' + sign  : ' ' + sign,
         color=OFF,
         textcolor=color.white,
         style=label.style_label_up,
         size=size.tiny)
    label.new(Sync,
         low,
         "",
         yloc = yloc.abovebar,
         color =RED,
         size = size.small,
         style = label.style_triangledown)
    HBreak := false


LongSMB = BUY
ShortSMB = SELL


/////////////////////////////////////////////////////

////////////////////////////////////////////////


/// SPECIAL TREND FILTER | STRATEGY 2
enable_strategy_2 = input.bool(defval = false, title = 'Enable MA Trend', group='MA Trend')




ma(source, length, type) =>
    switch type
        "SMA" => ta.sma(source, length)
        "HMA" => ta.hma(source, length)
        "EMA" => ta.ema(source, length)
        "SMMA (RMA)" => ta.rma(source, length)
        "WMA" => ta.wma(source, length)
        "VWMA" => ta.vwma(source, length)

maSourceInput = input.source(close, "Source", group="MA Trend")
maTypeInput = input.string("SMA", title="MA Type", options=["SMA", "HMA" , "EMA", "SMMA (RMA)", "WMA", "VWMA"], group="MA Trend", display = display.all)
maLengthInput = input.int(200, title="MA Length", group="MA Trend", display = display.all)



MAT = ma(maSourceInput, maLengthInput, maTypeInput)

plot(MAT, "MA", color=color.yellow)



long_MA =  enable_strategy_2 ? (close > MAT) : true 
short_MA = enable_strategy_2 ? (close < MAT) : true



////////////////////////////////////////////////////////
////////////////////////////////////////////////////////////
/////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////

/////////////////////////////////////////////////////
longCondition_2 = long_MA

shortCondition_2 = short_MA

var co2 = 0


if longCondition_2
    co2:=1


if shortCondition_2
    co2:=-1


long_2 = enable_strategy_2 ? co2 ==1 : true
short_2 = enable_strategy_2 ? co2==-1 : true



///////////////////////////////////////////


// Long and Short Conditions COMBINED

longCondition   = strategy.position_size<=1 and long_2
shortCondition  = strategy.position_size>=-1 and short_2
//closelong =      bear == true 
//closeshort=      bull == true 



// Long Strategy
if LongSMB and longCondition and enable_long_strategy and strategy.position_size<=1 == true
    strategy.entry('Long', strategy.long, alert_message= "Long Entry")
    strategy.exit('Long', from_entry='Long', loss=long_stoploss_percentage, profit=long_takeprofit_percentage, alert_loss = "Long SL", alert_profit = "Long TP", comment_loss="Long SL", comment_profit="Long TP")


// Short Strategy
if ShortSMB and shortCondition and enable_short_strategy and strategy.position_size>=-1 == true
    strategy.entry('Short', strategy.short, alert_message= "Short Entry")
    strategy.exit('Short', from_entry='Short', loss=short_stoploss_percentage, profit=short_takeprofit_percentage, alert_loss="Short SL", alert_profit="Short TP", comment_loss="Short SL", comment_profit="Short TP")
````
