# RSI Full [Titans_Invest]

- url: https://www.tradingview.com/script/3HILR8U9-RSI-Full-Titans-Invest/
- type: indicator
- pine_id: PUB;7eefe6f76a004b82aca344ead96262d3
- version: 2.0

## Description

[b]RSI Full [Titans_Invest][/b]
One of the most complete RSI indicators on the market.
While maintaining the classic RSI foundation, our indicator integrates multiple entry conditions to generate more accurate buy and sell signals.
All conditions are fully configurable, allowing complete customization to fit your trading strategy.

[b]⯁ WHAT IS THE RSI❓[/b]
The Relative Strength Index (RSI) is a technical analysis indicator developed by J. Welles Wilder. It measures the magnitude of recent price movements to evaluate overbought or oversold conditions in a market. The RSI is an oscillator that ranges from 0 to 100 and is commonly used to identify potential reversal points, as well as the strength of a trend.

[b]⯁ HOW TO USE THE RSI❓[/b]
The RSI is calculated based on average gains and losses over a specified period (usually 14 periods). It is plotted on a scale from 0 to 100 and includes three main zones:
[list]
[*][b]Overbought:[/b] When the RSI is above 70, indicating that the asset may be overbought.
[*][b]Oversold:[/b] When the RSI is below 30, indicating that the asset may be oversold.
[*][b]Neutral Zone:[/b] Between 30 and 70, where there is no clear signal of overbought or oversold conditions.
[/list]
[b]⯁ ENTRY CONDITIONS[/b]
The conditions below are fully flexible and allow for complete customization of the signal.

______________________________________________________
[b]🔹 CONDITIONS TO BUY 📈[/b]
______________________________________________________
  •  Signal Validity: The signal will remain valid for [b]X bars[/b].
  •  Signal Sequence: Configurable as [b]AND/OR[/b].

📈 RSI Conditions:
🔹 RSI > Upper
🔹 RSI < Upper
🔹 RSI > Lower
🔹 RSI < Lower
🔹 RSI > Middle
🔹 RSI < Middle
🔹 RSI > MA
🔹 RSI < MA

📈 MA Conditions:
🔹 MA > Upper
🔹 MA < Upper
🔹 MA > Lower
🔹 MA < Lower

📈 Crossovers:
🔹 RSI (Crossover) Upper
🔹 RSI (Crossunder) Upper
🔹 RSI (Crossover) Lower
🔹 RSI (Crossunder) Lower
🔹 RSI (Crossover) Middle
🔹 RSI (Crossunder) Middle
🔹 RSI (Crossover) MA
🔹 RSI (Crossunder) MA
🔹 MA (Crossover) Upper
🔹 MA (Crossunder) Upper
🔹 MA (Crossover) Lower
🔹 MA (Crossunder) Lower

📈 RSI Divergences:
🔹 RSI Divergence Bull
🔹 RSI Divergence Bear
______________________________________________________

______________________________________________________
[b]🔸 CONDITIONS TO SELL 📉[/b]
______________________________________________________
  •  Signal Validity: The signal will remain valid for [b]X bars[/b].
  •  Signal Sequence: Configurable as [b]AND/OR[/b].

📉 RSI Conditions:
🔸 RSI > Upper
🔸 RSI < Upper
🔸 RSI > Lower
🔸 RSI < Lower
🔸 RSI > Middle
🔸 RSI < Middle
🔸 RSI > MA
🔸 RSI < MA

📉 MA Conditions:
🔸 MA > Upper
🔸 MA < Upper
🔸 MA > Lower
🔸 MA < Lower

📉 Crossovers:
🔸 RSI (Crossover) Upper
🔸 RSI (Crossunder) Upper
🔸 RSI (Crossover) Lower
🔸 RSI (Crossunder) Lower
🔸 RSI (Crossover) Middle
🔸 RSI (Crossunder) Middle
🔸 RSI (Crossover) MA
🔸 RSI (Crossunder) MA
🔸 MA (Crossover) Upper
🔸 MA (Crossunder) Upper
🔸 MA (Crossover) Lower
🔸 MA (Crossunder) Lower

📉 RSI Divergences:
🔸 RSI Divergence Bull
🔸 RSI Divergence Bear
______________________________________________________

______________________________________________________
[b]🤖 AUTOMATION 🤖[/b]

• You can automate the BUY and SELL signals of this indicator.
______________________________________________________

______________________________________________________
[b]⯁ UNIQUE FEATURES[/b]
______________________________________________________
[list=1]
[*]Signal Validity: The signal will remain valid for [b]X bars[/b]
[*]Signal Sequence: Configurable as [b]AND/OR[/b]
[*]Condition Table: BUY/SELL
[*]Condition Labels: BUY/SELL
[*]Plot Labels in the Graph Above: BUY/SELL
[*]Automate and Monitor Signals/Alerts: BUY/SELL
[/list]
[list=1]
[*]Signal Validity: The signal will remain valid for [b]X bars[/b]
https://www.tradingview.com/x/8imKVXlv/
[*]Signal Sequence: Configurable as [b]AND/OR[/b]
https://www.tradingview.com/x/jgrQEZOJ/
[*]Condition Table: BUY/SELL
https://www.tradingview.com/x/O3V5FkyV/
[*]Condition Labels: BUY/SELL
https://www.tradingview.com/x/KlRHTvGu/
[*]Plot Labels in the Graph Above: BUY/SELL
https://www.tradingview.com/x/MUc7vreg/
[*]Automate and Monitor Signals/Alerts: BUY/SELL
https://www.tradingview.com/x/KHxf6aVH/
[/list]

______________________________________________________
[b]📜 SCRIPT : RSI Full [Titans_Invest][/b]

🎴 Art by  : @Titans_Invest & @DiFlip
👨‍💻 Dev by : @Titans_Invest & @DiFlip

🎑 Titans Invest — The Wizards Without Gloves 🧤

✨ Enjoy the Spell!
______________________________________________________


[b]o Mission 🗺
• Inspire Traders to manifest Magic in the Market.

o Vision 𐓏
• To elevate collective Energy 𐓷𐓏[/b]

## Source Code

````pine
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
// © Titans_Invest
// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//


//--//


//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//@version=6

indicator(title                       = 'RSI Full [Titans_Invest]', 
 shorttitle                           = 'RSI Full [Titans_Invest]', 
 overlay                              = false, 
 max_lines_count                      = 500, 
 max_labels_count                     = 500, 
 max_boxes_count                      = 500, 
 max_polylines_count                  = 100, 
 max_bars_back                        = 0, 
 calc_bars_count                      = 0, 
 scale                                = scale.right, 
 format                               = format.inherit, 
 precision                            = 1) // format.inherit, format.price, format.volume, format.percent, The default is: format.inherit                
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//


//--//


//RSI ╭╯ INPUTS
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//

Group_RSI__                           = '        🔖 Labels'

showDivergence                        = input.bool  (defval = false,      title = '🔖 Show Divergence',                             group = Group_RSI__, display = display.data_window)

ACTIVE_LEFT_LABELS                    = input       (defval = true,       title = '🔖 Flags on Right               ', inline = '0', group = Group_RSI__)
ACTIVE_NUMBER_LABELS_RSI              = input       (defval = false,      title = 'Numbers on Flags',                 inline = '0', group = Group_RSI__, tooltip = 'Activate : Numbers in the Flags')
ACTIVE_TABLES                         = input       (defval = true,       title = 'Tables',                           inline = '0', group = Group_RSI__, tooltip = 'Activate : Tables to the Right')

On_Of_Type_Flag                       = input       (defval = true,       title = '🔖 Buy & Sell                  ',  inline = '1', group = Group_RSI__)
Type_Flag                             = input.string(defval = 'label',    title = '',                                 inline = '1', group = Group_RSI__, options = ['label', 'label conditions', 'flag', 'flag overlay'], display = display.data_window)
Size_Flag_Entry_RSI                   = input.string(defval = size.small, title = '',                                 inline = '1', group = Group_RSI__, tooltip = 'Edit : Display Style and Size', options = [size.auto, size.tiny, size.small, size.normal, size.large, size.huge])

//--//

Group_RSI_                            = '        🧲 RSI'

RSI_UPPER                             = input.int   (defval = 70,         title = '      🧲 Upper',      minval = 1,                group = Group_RSI_)
RSI_LOWER                             = input.int   (defval = 30,         title = '      🧲 Lower',      minval = 1,                group = Group_RSI_)

rsiLengthInput                        = input.int   (defval = 14,         title = '      🧲 Length RSI', minval = 1,                group = Group_RSI_)
rsiSourceInput                        = input.source(defval = close,      title = '      🧲 Source RSI',                            group = Group_RSI_)
//-------------------------------------------------------------------------------------------------------------//


//--//


// RSI ╭╯ MA INPUTS
//-------------------------------------------------------------------------------------------------------------// 
Group_MA_RSI                          = '        ╭╯ MA SETTINGS'

maTypeInput                           = input.string(defval = 'SMA', title = '      ╭╯ MA Type',   options = ['SMA', 'Bollinger Bands', 'EMA', 'SMMA (RMA)', 'WMA', 'VWMA'], display = display.data_window, group = Group_MA_RSI)
maLengthInput                         = input.int   (defval = 14,    title = '      ╭╯ MA Length', minval = 1,                                                               display = display.data_window, group = Group_MA_RSI)
bbMultInput                           = input.float (defval = 2.0,   title = '      ╭╯ BB StdDev', minval = 0.001, maxval = 50,                                              display = display.data_window, group = Group_MA_RSI)

ma(source, length, type)              =>
    switch type
        'SMA'                         => ta.sma     (source, length)
        'Bollinger Bands'             => ta.sma     (source, length)
        'EMA'                         => ta.ema     (source, length)
        'SMMA (RMA)'                  => ta.rma     (source, length)
        'WMA'                         => ta.wma     (source, length)
        'VWMA'                        => ta.vwma    (source, length)
//-------------------------------------------------------------------------------------------------------------//


//--//


//-------------------------------------------------------------------------------------------------------------//
Group_RSI_Buy                         = '        📈 Buy'

RSI_true_signal_up_to_X_bar_back_BUY  = input       (defval = false, title = '🧲 Signal will remain valid X bars                ', inline = '1',                      group = Group_RSI_Buy)
RSI_signal_up_to_X_bar_back_BUY       = input.int   (defval = 0,     title = '',                                                   inline = '1', minval = 0,          group = Group_RSI_Buy, tooltip = 'Edit : Signal will remain valid until X bars (<=)')

TYPE_CONDITION_RSI_BUY                = input.string(defval = 'and', title = '      🧲 Signal Sequence', options = ['or', 'and'],                                     group = Group_RSI_Buy, tooltip = 'Edit : Select the sequence for Buy signals')

ON_OFF_CONDITION_RSI_BUY_1            = input       (defval = false, title = '🧲 RSI > Upper',                                                                        group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_2            = input       (defval = true,  title = '🧲 RSI < Upper ',                                                                       group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_3            = input       (defval = false, title = '🧲 RSI > Lower',                                                                        group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_4            = input       (defval = false, title = '🧲 RSI < Lower',                                                                        group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_5            = input       (defval = false, title = '🧲 RSI > Middle',                                                                       group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_6            = input       (defval = false, title = '🧲 RSI < Middle',                                                                       group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_7            = input       (defval = true,  title = '🧲 RSI > MA',                                                                           group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_8            = input       (defval = false, title = '🧲 RSI < MA',                                                                           group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_9            = input       (defval = false, title = '🧲 MA > Upper',                                                                         group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_10           = input       (defval = false, title = '🧲 MA < Upper',                                                                         group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_11           = input       (defval = false, title = '🧲 MA > Lower',                                                                         group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_12           = input       (defval = false, title = '🧲 MA < Lower',                                                                         group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_13           = input       (defval = false, title = '🧲 RSI (Crossover) Upper',                                                              group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_14           = input       (defval = false, title = '🧲 RSI (Crossunder) Upper',                                                             group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_15           = input       (defval = false, title = '🧲 RSI (Crossover) Lower',                                                              group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_16           = input       (defval = false, title = '🧲 RSI (Crossunder) Lower',                                                             group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_17           = input       (defval = false, title = '🧲 RSI (Crossover) Middle',                                                             group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_18           = input       (defval = false, title = '🧲 RSI (Crossunder) Middle',                                                            group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_19           = input       (defval = false, title = '🧲 RSI (Crossover) MA',                                                                 group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_20           = input       (defval = false, title = '🧲 RSI (Crossunder) MA',                                                                group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_21           = input       (defval = false, title = '🧲 MA (Crossover) Upper',                                                               group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_22           = input       (defval = false, title = '🧲 MA (Crossunder) Upper',                                                              group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_23           = input       (defval = false, title = '🧲 MA (Crossover) Lower',                                                               group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_24           = input       (defval = false, title = '🧲 MA (Crossunder) Lower',                                                              group = Group_RSI_Buy)

ON_OFF_CONDITION_RSI_BUY_25           = input       (defval = false, title = '🧲 RSI Divergence Bull',                                                                group = Group_RSI_Buy)
ON_OFF_CONDITION_RSI_BUY_26           = input       (defval = false, title = '🧲 RSI Divergence Bear',                                                                group = Group_RSI_Buy)
//-------------------------------------------------------------------------------------------------------------//


//--//


//-------------------------------------------------------------------------------------------------------------//
Group_RSI_Sell                        = '        📉 Sell'

RSI_true_signal_up_to_X_bar_back_SELL = input       (defval = false, title = '🧲 Signal will remain valid X bars                ', inline = '1',                      group = Group_RSI_Sell)
RSI_signal_up_to_X_bar_back_SELL      = input.int   (defval = 0,     title = '',                                                   inline = '1', minval = 0,          group = Group_RSI_Sell, tooltip = 'Edit : Signal will remain valid until X bars (<=)')
 
TYPE_CONDITION_RSI_SELL               = input.string(defval = 'and', title = '      🧲 Signal Sequence                                    ', options = ['or', 'and'], group = Group_RSI_Sell, tooltip = 'Edit : Select the sequence for Buy signals')

ON_OFF_CONDITION_RSI_SELL_1           = input       (defval = false, title = '🧲 RSI > Upper',                                                                        group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_2           = input       (defval = false, title = '🧲 RSI < Upper ',                                                                       group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_3           = input       (defval = true,  title = '🧲 RSI > Lower',                                                                        group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_4           = input       (defval = false, title = '🧲 RSI < Lower',                                                                        group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_5           = input       (defval = false, title = '🧲 RSI > Middle',                                                                       group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_6           = input       (defval = false, title = '🧲 RSI < Middle',                                                                       group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_7           = input       (defval = false, title = '🧲 RSI > MA',                                                                           group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_8           = input       (defval = true,  title = '🧲 RSI < MA',                                                                           group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_9           = input       (defval = false, title = '🧲 MA > Upper',                                                                         group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_10          = input       (defval = false, title = '🧲 MA < Upper',                                                                         group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_11          = input       (defval = false, title = '🧲 MA > Lower',                                                                         group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_12          = input       (defval = false, title = '🧲 MA < Lower',                                                                         group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_13          = input       (defval = false, title = '🧲 RSI (Crossover) Upper',                                                              group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_14          = input       (defval = false, title = '🧲 RSI (Crossunder) Upper',                                                             group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_15          = input       (defval = false, title = '🧲 RSI (Crossover) Lower',                                                              group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_16          = input       (defval = false, title = '🧲 RSI (Crossunder) Lower',                                                             group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_17          = input       (defval = false, title = '🧲 RSI (Crossover) Middle',                                                             group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_18          = input       (defval = false, title = '🧲 RSI (Crossunder) Middle',                                                            group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_19          = input       (defval = false, title = '🧲 RSI (Crossover) MA',                                                                 group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_20          = input       (defval = false, title = '🧲 RSI (Crossunder) MA',                                                                group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_21          = input       (defval = false, title = '🧲 MA (Crossover) Upper',                                                               group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_22          = input       (defval = false, title = '🧲 MA (Crossunder) Upper',                                                              group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_23          = input       (defval = false, title = '🧲 MA (Crossover) Lower',                                                               group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_24          = input       (defval = false, title = '🧲 MA (Crossunder) Lower',                                                              group = Group_RSI_Sell)

ON_OFF_CONDITION_RSI_SELL_25          = input       (defval = false, title = '🧲 RSI Divergence Bull',                                                                group = Group_RSI_Sell)
ON_OFF_CONDITION_RSI_SELL_26          = input       (defval = false, title = '🧲 RSI Divergence Bear',                                                                group = Group_RSI_Sell)
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//


//--//


//FUNCTION RSI ╭╯
//-------------------------------------------------------------------------------------------------------------//
up   = ta.rma(math.max (ta.change(rsiSourceInput), 0), rsiLengthInput)
down = ta.rma(-math.min(ta.change(rsiSourceInput), 0), rsiLengthInput)
rsi  = down == 0 ? 100 : up == 0 ? 0 : 100 - 100 / (1 + up / down)
//-------------------------------------------------------------------------------------------------------------//


//FUNCTION ╭╯ MA SETTINGS
//-------------------------------------------------------------------------------------------------------------//
rsiMA = ma(rsi, maLengthInput, maTypeInput)

isBB  = maTypeInput == 'Bollinger Bands'
//-------------------------------------------------------------------------------------------------------------//


//PLOTS RSI & MA RSI
//-------------------------------------------------------------------------------------------------------------//
rsiPlot = plot(rsi,   '╭╯ RSI',    color = #7E57C2)

plot          (rsiMA, '╭╯ MA RSI', color = color.yellow) //RSI-based MA
//-------------------------------------------------------------------------------------------------------------//


//HLINES E FILLS
//-------------------------------------------------------------------------------------------------------------//
rsiUpperBand = hline(RSI_UPPER, 'RSI Upper Band',  color = #787B86)
midline      = hline(50,        'RSI Middle Band', color = color.new(#787B86, 50))
rsiLowerBand = hline(RSI_LOWER, 'RSI Lower Band',  color = #787B86)

fill(rsiUpperBand, rsiLowerBand, color = color.rgb(126, 87, 194, 90), title = 'RSI Background Fill')
//-------------------------------------------------------------------------------------------------------------//


//RSI Bollinger Band
//-------------------------------------------------------------------------------------------------------------//
bbUpperBand  = plot(isBB ? rsiMA + ta.stdev(rsi, maLengthInput) * bbMultInput : na, title = 'Upper Bollinger Band',            color = color.green)
bbLowerBand  = plot(isBB ? rsiMA - ta.stdev(rsi, maLengthInput) * bbMultInput : na, title = 'Lower Bollinger Band',            color = color.green)
fill(bbUpperBand, bbLowerBand,                                                      title = 'Bollinger Bands Background Fill', color = isBB ? color.new(color.green, 90) : na)
//-------------------------------------------------------------------------------------------------------------//


//RSI FILL GRADIENT
//-------------------------------------------------------------------------------------------------------------//
midLinePlot  = plot(50, color = na, editable = false, display = display.none)

fill(rsiPlot, midLinePlot, 100, RSI_UPPER,    top_color = color.new(color.green, 0), title = 'Overbought Gradient Fill', bottom_color = color.new(color.green, 100))
fill(rsiPlot, midLinePlot,      RSI_LOWER, 0, top_color = color.new(color.red, 100), title = 'Oversold Gradient Fill',   bottom_color = color.new(color.red,   0))
//-------------------------------------------------------------------------------------------------------------//


//--//


// RSI DIVERGENCES 
//-------------------------------------------------------------------------------------------------------------//
lookbackRight   = 5
lookbackLeft    = 5
rangeUpper      = 60
rangeLower      = 5
bearColor       = color.red
bullColor       = color.green
textColor       = color.white
noneColor       = color.new(color.white, 100)

plFound         = na(ta.pivotlow (rsi, lookbackLeft, lookbackRight)) ? false : true
phFound         = na(ta.pivothigh(rsi, lookbackLeft, lookbackRight)) ? false : true

_inRange(cond)  =>
    bars        = ta.barssince(cond == true)
    rangeLower <= bars and bars <= rangeUpper
    
// Store the results of the _inRange function in global variables
rsiHL_inRange   = _inRange(plFound[1])
rsiLH_inRange   = _inRange(phFound[1])
//-------------------------------------------------------------------------------------------------------------//

//-------------------------------------------------------------------------------------------------------------//
// Regular Bullish
// rsi: Higher Low

rsiHL         = rsi[lookbackRight] > ta.valuewhen(plFound, rsi[lookbackRight], 1) and rsiHL_inRange

// Price: Lower Low

priceLL       = low[lookbackRight] < ta.valuewhen(plFound, low[lookbackRight], 1)
bullCondAlert = priceLL and rsiHL and plFound
bullCond      = showDivergence and bullCondAlert

plot(plFound       ? rsi[lookbackRight] : na, offset = -lookbackRight, title = 'Regular Bullish', linewidth = 2, color = bullCond ? bullColor : noneColor, display = display.pane)

plotshape(bullCond ? rsi[lookbackRight] : na, offset = -lookbackRight, title = 'Regular Bullish Label', text = ' Bull ', style = shape.labelup, location = location.absolute, color = bullColor, textcolor = textColor)
//-------------------------------------------------------------------------------------------------------------//

//-------------------------------------------------------------------------------------------------------------//
// Regular Bearish
// rsi: Lower High

rsiLH         = rsi[lookbackRight] < ta.valuewhen(phFound, rsi[lookbackRight], 1) and rsiLH_inRange

// Price: Higher High

priceHH       = high[lookbackRight] > ta.valuewhen(phFound, high[lookbackRight], 1)

bearCondAlert = priceHH and rsiLH and phFound
bearCond      = showDivergence and bearCondAlert

plot(phFound       ? rsi[lookbackRight] : na, offset = -lookbackRight, title = 'Regular Bearish', linewidth = 2, color = bearCond ? bearColor : noneColor, display = display.pane)

plotshape(bearCond ? rsi[lookbackRight] : na, offset = -lookbackRight, title = 'Regular Bearish Label', text = ' Bear ', style = shape.labeldown, location = location.absolute, color = bearColor, textcolor = textColor)

//alertcondition(bullCondAlert, title='Regular Bullish Divergence', message="Found a new Regular Bullish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.")
//alertcondition(bearCondAlert, title='Regular Bearish Divergence', message='Found a new Regular Bearish Divergence, `Pivot Lookback Right` number of bars to the left of the current bar.')
//-------------------------------------------------------------------------------------------------------------//----------------------------------------------------------------------------------------------------//-------------------------------------------------------------------------------------------------------------//


//--//


//CONDITIONS FINALS | BUY
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//
CONDITION_RSI_BUY_1  = rsi > RSI_UPPER
CONDITION_RSI_BUY_2  = rsi < RSI_UPPER

CONDITION_RSI_BUY_3  = rsi > RSI_LOWER
CONDITION_RSI_BUY_4  = rsi < RSI_LOWER

CONDITION_RSI_BUY_5  = rsi > 50
CONDITION_RSI_BUY_6  = rsi < 50

CONDITION_RSI_BUY_7  = rsi > rsiMA
CONDITION_RSI_BUY_8  = rsi < rsiMA

CONDITION_RSI_BUY_9  = rsiMA > RSI_UPPER
CONDITION_RSI_BUY_10 = rsiMA < RSI_UPPER

CONDITION_RSI_BUY_11 = rsiMA > RSI_LOWER
CONDITION_RSI_BUY_12 = rsiMA < RSI_LOWER

CONDITION_RSI_BUY_13 = ta.crossover (rsi, RSI_UPPER)
CONDITION_RSI_BUY_14 = ta.crossunder(rsi, RSI_UPPER)

CONDITION_RSI_BUY_15 = ta.crossover (rsi, RSI_LOWER)
CONDITION_RSI_BUY_16 = ta.crossunder(rsi, RSI_LOWER)

CONDITION_RSI_BUY_17 = ta.crossover (rsi, 50)
CONDITION_RSI_BUY_18 = ta.crossunder(rsi, 50)

CONDITION_RSI_BUY_19 = ta.crossover (rsi, rsiMA)
CONDITION_RSI_BUY_20 = ta.crossunder(rsi, rsiMA)

CONDITION_RSI_BUY_21 = ta.crossover (rsiMA, RSI_UPPER)
CONDITION_RSI_BUY_22 = ta.crossunder(rsiMA, RSI_UPPER)

CONDITION_RSI_BUY_23 = ta.crossover (rsiMA, RSI_LOWER)
CONDITION_RSI_BUY_24 = ta.crossunder(rsiMA, RSI_LOWER)

CONDITION_RSI_BUY_25 = bullCondAlert
CONDITION_RSI_BUY_26 = bearCondAlert
//-------------------------------------------------------------------------------------------------------------//

//TA.BARSSINCE | BUY
//-------------------------------------------------------------------------------------------------------------//
//OR
OR_TA_CONDITION_RSI_BUY_1   = ON_OFF_CONDITION_RSI_BUY_1  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_1)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_1  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_1  : false
OR_TA_CONDITION_RSI_BUY_2   = ON_OFF_CONDITION_RSI_BUY_2  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_2)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_2  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_2  : false

OR_TA_CONDITION_RSI_BUY_3   = ON_OFF_CONDITION_RSI_BUY_3  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_3)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_3  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_3  : false
OR_TA_CONDITION_RSI_BUY_4   = ON_OFF_CONDITION_RSI_BUY_4  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_4)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_4  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_4  : false

OR_TA_CONDITION_RSI_BUY_5   = ON_OFF_CONDITION_RSI_BUY_5  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_5)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_5  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_5  : false
OR_TA_CONDITION_RSI_BUY_6   = ON_OFF_CONDITION_RSI_BUY_6  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_6)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_6  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_6  : false

OR_TA_CONDITION_RSI_BUY_7   = ON_OFF_CONDITION_RSI_BUY_7  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_7)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_7  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_7  : false
OR_TA_CONDITION_RSI_BUY_8   = ON_OFF_CONDITION_RSI_BUY_8  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_8)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_8  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_8  : false

OR_TA_CONDITION_RSI_BUY_9   = ON_OFF_CONDITION_RSI_BUY_9  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_9)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_9  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_9  : false
OR_TA_CONDITION_RSI_BUY_10  = ON_OFF_CONDITION_RSI_BUY_10 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_10) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_10 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_10 : false

OR_TA_CONDITION_RSI_BUY_11  = ON_OFF_CONDITION_RSI_BUY_11 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_11) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_11 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_11 : false
OR_TA_CONDITION_RSI_BUY_12  = ON_OFF_CONDITION_RSI_BUY_12 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_12) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_12 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_12 : false

OR_TA_CONDITION_RSI_BUY_13  = ON_OFF_CONDITION_RSI_BUY_13 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_13) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_13 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_13 : false
OR_TA_CONDITION_RSI_BUY_14  = ON_OFF_CONDITION_RSI_BUY_14 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_14) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_14 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_14 : false

OR_TA_CONDITION_RSI_BUY_15  = ON_OFF_CONDITION_RSI_BUY_15 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_15) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_15 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_15 : false
OR_TA_CONDITION_RSI_BUY_16  = ON_OFF_CONDITION_RSI_BUY_16 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_16) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_16 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_16 : false

OR_TA_CONDITION_RSI_BUY_17  = ON_OFF_CONDITION_RSI_BUY_17 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_17) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_17 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_17 : false
OR_TA_CONDITION_RSI_BUY_18  = ON_OFF_CONDITION_RSI_BUY_18 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_18) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_18 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_18 : false

OR_TA_CONDITION_RSI_BUY_19  = ON_OFF_CONDITION_RSI_BUY_19 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_19) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_19 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_19 : false
OR_TA_CONDITION_RSI_BUY_20  = ON_OFF_CONDITION_RSI_BUY_20 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_20) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_20 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_20 : false

OR_TA_CONDITION_RSI_BUY_21  = ON_OFF_CONDITION_RSI_BUY_21 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_21) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_21 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_21 : false
OR_TA_CONDITION_RSI_BUY_22  = ON_OFF_CONDITION_RSI_BUY_22 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_22) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_22 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_22 : false

OR_TA_CONDITION_RSI_BUY_23  = ON_OFF_CONDITION_RSI_BUY_23 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_23) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_23 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_23 : false
OR_TA_CONDITION_RSI_BUY_24  = ON_OFF_CONDITION_RSI_BUY_24 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_24) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_24 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_24 : false

OR_TA_CONDITION_RSI_BUY_25  = ON_OFF_CONDITION_RSI_BUY_25 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_25) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_25 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_25 : false
OR_TA_CONDITION_RSI_BUY_26  = ON_OFF_CONDITION_RSI_BUY_26 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_26) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_26 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_26 : false

//--//

//AND
AND_TA_CONDITION_RSI_BUY_1  = ON_OFF_CONDITION_RSI_BUY_1  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_1)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_1  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_1  : true
AND_TA_CONDITION_RSI_BUY_2  = ON_OFF_CONDITION_RSI_BUY_2  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_2)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_2  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_2  : true

AND_TA_CONDITION_RSI_BUY_3  = ON_OFF_CONDITION_RSI_BUY_3  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_3)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_3  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_3  : true
AND_TA_CONDITION_RSI_BUY_4  = ON_OFF_CONDITION_RSI_BUY_4  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_4)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_4  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_4  : true

AND_TA_CONDITION_RSI_BUY_5  = ON_OFF_CONDITION_RSI_BUY_5  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_5)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_5  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_5  : true
AND_TA_CONDITION_RSI_BUY_6  = ON_OFF_CONDITION_RSI_BUY_6  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_6)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_6  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_6  : true

AND_TA_CONDITION_RSI_BUY_7  = ON_OFF_CONDITION_RSI_BUY_7  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_7)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_7  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_7  : true
AND_TA_CONDITION_RSI_BUY_8  = ON_OFF_CONDITION_RSI_BUY_8  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_8)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_8  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_8  : true

AND_TA_CONDITION_RSI_BUY_9  = ON_OFF_CONDITION_RSI_BUY_9  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_9)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_9  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_9  : true
AND_TA_CONDITION_RSI_BUY_10 = ON_OFF_CONDITION_RSI_BUY_10 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_10) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_10 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_10 : true

AND_TA_CONDITION_RSI_BUY_11 = ON_OFF_CONDITION_RSI_BUY_11 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_11) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_11 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_11 : true
AND_TA_CONDITION_RSI_BUY_12 = ON_OFF_CONDITION_RSI_BUY_12 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_12) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_12 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_12 : true

AND_TA_CONDITION_RSI_BUY_13 = ON_OFF_CONDITION_RSI_BUY_13 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_13) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_13 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_13 : true
AND_TA_CONDITION_RSI_BUY_14 = ON_OFF_CONDITION_RSI_BUY_14 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_14) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_14 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_14 : true

AND_TA_CONDITION_RSI_BUY_15 = ON_OFF_CONDITION_RSI_BUY_15 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_15) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_15 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_15 : true
AND_TA_CONDITION_RSI_BUY_16 = ON_OFF_CONDITION_RSI_BUY_16 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_16) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_16 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_16 : true

AND_TA_CONDITION_RSI_BUY_17 = ON_OFF_CONDITION_RSI_BUY_17 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_17) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_17 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_17 : true
AND_TA_CONDITION_RSI_BUY_18 = ON_OFF_CONDITION_RSI_BUY_18 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_18) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_18 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_18 : true

AND_TA_CONDITION_RSI_BUY_19 = ON_OFF_CONDITION_RSI_BUY_19 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_19) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_19 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_19 : true
AND_TA_CONDITION_RSI_BUY_20 = ON_OFF_CONDITION_RSI_BUY_20 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_20) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_20 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_20 : true

AND_TA_CONDITION_RSI_BUY_21 = ON_OFF_CONDITION_RSI_BUY_21 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_21) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_21 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_21 : true
AND_TA_CONDITION_RSI_BUY_22 = ON_OFF_CONDITION_RSI_BUY_22 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_22) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_22 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_22 : true

AND_TA_CONDITION_RSI_BUY_23 = ON_OFF_CONDITION_RSI_BUY_23 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_23) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_23 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_23 : true
AND_TA_CONDITION_RSI_BUY_24 = ON_OFF_CONDITION_RSI_BUY_24 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_24) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_24 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_24 : true

AND_TA_CONDITION_RSI_BUY_25 = ON_OFF_CONDITION_RSI_BUY_25 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_25) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_25 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_25 : true
AND_TA_CONDITION_RSI_BUY_26 = ON_OFF_CONDITION_RSI_BUY_26 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_26) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_26 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_26 : true
//-------------------------------------------------------------------------------------------------------------//

//AND/OR | BUY
//-------------------------------------------------------------------------------------------------------------//
OR_AND_CONDITION_RSI_BUY = TYPE_CONDITION_RSI_BUY == 'or' ? OR_TA_CONDITION_RSI_BUY_1 or OR_TA_CONDITION_RSI_BUY_2 or OR_TA_CONDITION_RSI_BUY_3 or OR_TA_CONDITION_RSI_BUY_4 or OR_TA_CONDITION_RSI_BUY_5 or OR_TA_CONDITION_RSI_BUY_6 or OR_TA_CONDITION_RSI_BUY_7 or OR_TA_CONDITION_RSI_BUY_8 or OR_TA_CONDITION_RSI_BUY_9 or OR_TA_CONDITION_RSI_BUY_10 or OR_TA_CONDITION_RSI_BUY_11 or OR_TA_CONDITION_RSI_BUY_12 or OR_TA_CONDITION_RSI_BUY_13 or OR_TA_CONDITION_RSI_BUY_14 or OR_TA_CONDITION_RSI_BUY_15 or OR_TA_CONDITION_RSI_BUY_16 or OR_TA_CONDITION_RSI_BUY_17 or OR_TA_CONDITION_RSI_BUY_18 or OR_TA_CONDITION_RSI_BUY_19 or OR_TA_CONDITION_RSI_BUY_20 or OR_TA_CONDITION_RSI_BUY_21 or OR_TA_CONDITION_RSI_BUY_22 or OR_TA_CONDITION_RSI_BUY_23 or OR_TA_CONDITION_RSI_BUY_24 or OR_TA_CONDITION_RSI_BUY_25 or OR_TA_CONDITION_RSI_BUY_26 : TYPE_CONDITION_RSI_BUY == 'and' ? AND_TA_CONDITION_RSI_BUY_1 and AND_TA_CONDITION_RSI_BUY_2 and AND_TA_CONDITION_RSI_BUY_3 and AND_TA_CONDITION_RSI_BUY_4 and AND_TA_CONDITION_RSI_BUY_5 and AND_TA_CONDITION_RSI_BUY_6 and AND_TA_CONDITION_RSI_BUY_7 and AND_TA_CONDITION_RSI_BUY_8 and AND_TA_CONDITION_RSI_BUY_9 and AND_TA_CONDITION_RSI_BUY_10 and AND_TA_CONDITION_RSI_BUY_11 and AND_TA_CONDITION_RSI_BUY_12 and AND_TA_CONDITION_RSI_BUY_13 and AND_TA_CONDITION_RSI_BUY_14 and AND_TA_CONDITION_RSI_BUY_15 and AND_TA_CONDITION_RSI_BUY_16 and AND_TA_CONDITION_RSI_BUY_17 and AND_TA_CONDITION_RSI_BUY_18 and AND_TA_CONDITION_RSI_BUY_19 and AND_TA_CONDITION_RSI_BUY_20 and AND_TA_CONDITION_RSI_BUY_21 and AND_TA_CONDITION_RSI_BUY_22 and AND_TA_CONDITION_RSI_BUY_23 and AND_TA_CONDITION_RSI_BUY_24 and AND_TA_CONDITION_RSI_BUY_25 and AND_TA_CONDITION_RSI_BUY_26 : true
//-------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
// :}


//NAMES CONDITIONS | LABELS | BUY :{
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
NAME_TA_CONDITION_RSI_BUY_1  = ON_OFF_CONDITION_RSI_BUY_1  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_1)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_1  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_1  : false
NAME_TA_CONDITION_RSI_BUY_2  = ON_OFF_CONDITION_RSI_BUY_2  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_2)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_2  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_2  : false

NAME_TA_CONDITION_RSI_BUY_3  = ON_OFF_CONDITION_RSI_BUY_3  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_3)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_3  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_3  : false
NAME_TA_CONDITION_RSI_BUY_4  = ON_OFF_CONDITION_RSI_BUY_4  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_4)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_4  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_4  : false

NAME_TA_CONDITION_RSI_BUY_5  = ON_OFF_CONDITION_RSI_BUY_5  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_5)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_5  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_5  : false
NAME_TA_CONDITION_RSI_BUY_6  = ON_OFF_CONDITION_RSI_BUY_6  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_6)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_6  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_6  : false

NAME_TA_CONDITION_RSI_BUY_7  = ON_OFF_CONDITION_RSI_BUY_7  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_7)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_7  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_7  : false
NAME_TA_CONDITION_RSI_BUY_8  = ON_OFF_CONDITION_RSI_BUY_8  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_8)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_8  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_8  : false

NAME_TA_CONDITION_RSI_BUY_9  = ON_OFF_CONDITION_RSI_BUY_9  and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_9)  <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_9  == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_9  : false
NAME_TA_CONDITION_RSI_BUY_10 = ON_OFF_CONDITION_RSI_BUY_10 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_10) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_10 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_10 : false

NAME_TA_CONDITION_RSI_BUY_11 = ON_OFF_CONDITION_RSI_BUY_11 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_11) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_11 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_11 : false
NAME_TA_CONDITION_RSI_BUY_12 = ON_OFF_CONDITION_RSI_BUY_12 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_12) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_12 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_12 : false

NAME_TA_CONDITION_RSI_BUY_13 = ON_OFF_CONDITION_RSI_BUY_13 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_13) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_13 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_13 : false
NAME_TA_CONDITION_RSI_BUY_14 = ON_OFF_CONDITION_RSI_BUY_14 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_14) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_14 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_14 : false

NAME_TA_CONDITION_RSI_BUY_15 = ON_OFF_CONDITION_RSI_BUY_15 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_15) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_15 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_15 : false
NAME_TA_CONDITION_RSI_BUY_16 = ON_OFF_CONDITION_RSI_BUY_16 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_16) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_16 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_16 : false

NAME_TA_CONDITION_RSI_BUY_17 = ON_OFF_CONDITION_RSI_BUY_17 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_17) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_17 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_17 : false
NAME_TA_CONDITION_RSI_BUY_18 = ON_OFF_CONDITION_RSI_BUY_18 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_18) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_18 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_18 : false

NAME_TA_CONDITION_RSI_BUY_19 = ON_OFF_CONDITION_RSI_BUY_19 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_19) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_19 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_19 : false
NAME_TA_CONDITION_RSI_BUY_20 = ON_OFF_CONDITION_RSI_BUY_20 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_20) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_20 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_20 : false

NAME_TA_CONDITION_RSI_BUY_21 = ON_OFF_CONDITION_RSI_BUY_21 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_21) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_21 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_21 : false
NAME_TA_CONDITION_RSI_BUY_22 = ON_OFF_CONDITION_RSI_BUY_22 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_22) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_22 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_22 : false

NAME_TA_CONDITION_RSI_BUY_23 = ON_OFF_CONDITION_RSI_BUY_23 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_23) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_23 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_23 : false
NAME_TA_CONDITION_RSI_BUY_24 = ON_OFF_CONDITION_RSI_BUY_24 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_24) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_24 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_24 : false

NAME_TA_CONDITION_RSI_BUY_25 = ON_OFF_CONDITION_RSI_BUY_25 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_25) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_25 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_25 : false
NAME_TA_CONDITION_RSI_BUY_26 = ON_OFF_CONDITION_RSI_BUY_26 and RSI_true_signal_up_to_X_bar_back_BUY == true ? ta.barssince(CONDITION_RSI_BUY_26) <= RSI_signal_up_to_X_bar_back_BUY : ON_OFF_CONDITION_RSI_BUY_26 == true and RSI_true_signal_up_to_X_bar_back_BUY == false ? CONDITION_RSI_BUY_26 : false
//-------------------------------------------------------------------------------------------------------------//


//TEXT CONDITIONS LABEL | BUY
//-------------------------------------------------------------------------------------------------------------//
NAME_CONDITION_RSI_BUY_1  = NAME_TA_CONDITION_RSI_BUY_1  == true ? '\nRSI > ' + str.tostring(RSI_UPPER) : na
NAME_CONDITION_RSI_BUY_2  = NAME_TA_CONDITION_RSI_BUY_2  == true ? '\nRSI < ' + str.tostring(RSI_UPPER) : na

NAME_CONDITION_RSI_BUY_3  = NAME_TA_CONDITION_RSI_BUY_3  == true ? '\nRSI > ' + str.tostring(RSI_LOWER) : na
NAME_CONDITION_RSI_BUY_4  = NAME_TA_CONDITION_RSI_BUY_4  == true ? '\nRSI < ' + str.tostring(RSI_LOWER) : na

NAME_CONDITION_RSI_BUY_5  = NAME_TA_CONDITION_RSI_BUY_5  == true ? '\nRSI > Middle' : na
NAME_CONDITION_RSI_BUY_6  = NAME_TA_CONDITION_RSI_BUY_6  == true ? '\nRSI < Middle' : na

NAME_CONDITION_RSI_BUY_7  = NAME_TA_CONDITION_RSI_BUY_7  == true ? '\nRSI > MA' : na
NAME_CONDITION_RSI_BUY_8  = NAME_TA_CONDITION_RSI_BUY_8  == true ? '\nRSI < MA' : na

NAME_CONDITION_RSI_BUY_9  = NAME_TA_CONDITION_RSI_BUY_9  == true ? '\nMA > ' + str.tostring(RSI_UPPER) : na
NAME_CONDITION_RSI_BUY_10 = NAME_TA_CONDITION_RSI_BUY_10 == true ? '\nMA < ' + str.tostring(RSI_UPPER) : na

NAME_CONDITION_RSI_BUY_11 = NAME_TA_CONDITION_RSI_BUY_11 == true ? '\nMA > ' + str.tostring(RSI_LOWER) : na
NAME_CONDITION_RSI_BUY_12 = NAME_TA_CONDITION_RSI_BUY_12 == true ? '\nMA < ' + str.tostring(RSI_LOWER) : na

NAME_CONDITION_RSI_BUY_13 = NAME_TA_CONDITION_RSI_BUY_13 == true ? '\nRSI (Crossover) '  + str.tostring(RSI_UPPER) : na
NAME_CONDITION_RSI_BUY_14 = NAME_TA_CONDITION_RSI_BUY_14 == true ? '\nRSI (Crossunder) ' + str.tostring(RSI_UPPER) : na

NAME_CONDITION_RSI_BUY_15 = NAME_TA_CONDITION_RSI_BUY_15 == true ? '\nRSI (Crossover) '  + str.tostring(RSI_LOWER) : na
NAME_CONDITION_RSI_BUY_16 = NAME_TA_CONDITION_RSI_BUY_16 == true ? '\nRSI (Crossunder) ' + str.tostring(RSI_LOWER) : na

NAME_CONDITION_RSI_BUY_17 = NAME_TA_CONDITION_RSI_BUY_17 == true ? '\nRSI (Crossover) Middle'  : na
NAME_CONDITION_RSI_BUY_18 = NAME_TA_CONDITION_RSI_BUY_18 == true ? '\nRSI (Crossunder) Middle' : na

NAME_CONDITION_RSI_BUY_19 = NAME_TA_CONDITION_RSI_BUY_19 == true ? '\nRSI (Crossover) MA'  : na
NAME_CONDITION_RSI_BUY_20 = NAME_TA_CONDITION_RSI_BUY_20 == true ? '\nRSI (Crossunder) MA' : na

NAME_CONDITION_RSI_BUY_21 = NAME_TA_CONDITION_RSI_BUY_21 == true ? '\nMA (Crossover) '  + str.tostring(RSI_UPPER) : na
NAME_CONDITION_RSI_BUY_22 = NAME_TA_CONDITION_RSI_BUY_22 == true ? '\nMA (Crossunder) ' + str.tostring(RSI_UPPER) : na

NAME_CONDITION_RSI_BUY_23 = NAME_TA_CONDITION_RSI_BUY_23 == true ? '\nMA (Crossover) '  + str.tostring(RSI_LOWER) : na
NAME_CONDITION_RSI_BUY_24 = NAME_TA_CONDITION_RSI_BUY_24 == true ? '\nMA (Crossunder) ' + str.tostring(RSI_LOWER) : na

NAME_CONDITION_RSI_BUY_25 = NAME_TA_CONDITION_RSI_BUY_25 == true ? '\nRSI Divergence Bull' : na
NAME_CONDITION_RSI_BUY_26 = NAME_TA_CONDITION_RSI_BUY_26 == true ? '\nRSI Divergence Bear' : na

RSI_NAMES_CONDITIONS_BUY_LABEL = NAME_CONDITION_RSI_BUY_1 + NAME_CONDITION_RSI_BUY_2 + NAME_CONDITION_RSI_BUY_3 + NAME_CONDITION_RSI_BUY_4 + NAME_CONDITION_RSI_BUY_5 + NAME_CONDITION_RSI_BUY_6 + NAME_CONDITION_RSI_BUY_7 + NAME_CONDITION_RSI_BUY_8 + NAME_CONDITION_RSI_BUY_9 + NAME_CONDITION_RSI_BUY_10 + NAME_CONDITION_RSI_BUY_11 + NAME_CONDITION_RSI_BUY_12 + NAME_CONDITION_RSI_BUY_13 + NAME_CONDITION_RSI_BUY_14 + NAME_CONDITION_RSI_BUY_15 + NAME_CONDITION_RSI_BUY_16 + NAME_CONDITION_RSI_BUY_17 + NAME_CONDITION_RSI_BUY_18 + NAME_CONDITION_RSI_BUY_19 + NAME_CONDITION_RSI_BUY_20 + NAME_CONDITION_RSI_BUY_21 + NAME_CONDITION_RSI_BUY_22 + NAME_CONDITION_RSI_BUY_23 + NAME_CONDITION_RSI_BUY_24 + NAME_CONDITION_RSI_BUY_25 + NAME_CONDITION_RSI_BUY_26
//-------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
// :}


//SIMPLE TEXT CONDITIONS TABLES | BUY
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_1  = ON_OFF_CONDITION_RSI_BUY_1  == true ? '\nRSI > ' + str.tostring(RSI_UPPER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_2  = ON_OFF_CONDITION_RSI_BUY_2  == true ? '\nRSI < ' + str.tostring(RSI_UPPER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_3  = ON_OFF_CONDITION_RSI_BUY_3  == true ? '\nRSI > ' + str.tostring(RSI_LOWER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_4  = ON_OFF_CONDITION_RSI_BUY_4  == true ? '\nRSI < ' + str.tostring(RSI_LOWER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_5  = ON_OFF_CONDITION_RSI_BUY_5  == true ? '\nRSI > Middle' : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_6  = ON_OFF_CONDITION_RSI_BUY_6  == true ? '\nRSI < Middle' : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_7  = ON_OFF_CONDITION_RSI_BUY_7  == true ? '\nRSI > MA' : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_8  = ON_OFF_CONDITION_RSI_BUY_8  == true ? '\nRSI < MA' : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_9  = ON_OFF_CONDITION_RSI_BUY_9  == true ? '\nMA > ' + str.tostring(RSI_UPPER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_10 = ON_OFF_CONDITION_RSI_BUY_10 == true ? '\nMA < ' + str.tostring(RSI_UPPER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_11 = ON_OFF_CONDITION_RSI_BUY_11 == true ? '\nMA > ' + str.tostring(RSI_LOWER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_12 = ON_OFF_CONDITION_RSI_BUY_12 == true ? '\nMA < ' + str.tostring(RSI_LOWER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_13 = ON_OFF_CONDITION_RSI_BUY_13 == true ? '\nRSI (Crossover) '  + str.tostring(RSI_UPPER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_14 = ON_OFF_CONDITION_RSI_BUY_14 == true ? '\nRSI (Crossunder) ' + str.tostring(RSI_UPPER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_15 = ON_OFF_CONDITION_RSI_BUY_15 == true ? '\nRSI (Crossover) '  + str.tostring(RSI_LOWER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_16 = ON_OFF_CONDITION_RSI_BUY_16 == true ? '\nRSI (Crossunder) ' + str.tostring(RSI_LOWER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_17 = ON_OFF_CONDITION_RSI_BUY_17 == true ? '\nRSI (Crossover) Middle'  : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_18 = ON_OFF_CONDITION_RSI_BUY_18 == true ? '\nRSI (Crossunder) Middle' : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_19 = ON_OFF_CONDITION_RSI_BUY_19 == true ? '\nRSI (Crossover) MA'  : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_20 = ON_OFF_CONDITION_RSI_BUY_20 == true ? '\nRSI (Crossunder) MA' : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_21 = ON_OFF_CONDITION_RSI_BUY_21 == true ? '\nMA (Crossover) '  + str.tostring(RSI_UPPER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_22 = ON_OFF_CONDITION_RSI_BUY_22 == true ? '\nMA (Crossunder) ' + str.tostring(RSI_UPPER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_23 = ON_OFF_CONDITION_RSI_BUY_23 == true ? '\nMA (Crossover) '  + str.tostring(RSI_LOWER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_24 = ON_OFF_CONDITION_RSI_BUY_24 == true ? '\nMA (Crossunder) ' + str.tostring(RSI_LOWER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_25 = ON_OFF_CONDITION_RSI_BUY_25 == true ? '\nRSI Divergence Bull' : na
SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_26 = ON_OFF_CONDITION_RSI_BUY_26 == true ? '\nRSI Divergence Bear' : na

RSI_SIMPLE_TABLE_NAMES_CONDITIONS_BUY_LABEL = SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_1 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_2 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_3 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_4 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_5 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_6 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_7 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_8 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_9 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_10 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_11 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_12 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_13 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_14 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_15 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_16 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_17 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_18 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_19 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_20 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_21 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_22 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_23 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_24 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_25 + SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_26
//-------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//


//COUNT CONDITIONS TABLES | BUY
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_1  = ON_OFF_CONDITION_RSI_BUY_1  == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_2  = ON_OFF_CONDITION_RSI_BUY_2  == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_3  = ON_OFF_CONDITION_RSI_BUY_3  == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_4  = ON_OFF_CONDITION_RSI_BUY_4  == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_5  = ON_OFF_CONDITION_RSI_BUY_5  == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_6  = ON_OFF_CONDITION_RSI_BUY_6  == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_7  = ON_OFF_CONDITION_RSI_BUY_7  == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_8  = ON_OFF_CONDITION_RSI_BUY_8  == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_9  = ON_OFF_CONDITION_RSI_BUY_9  == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_10 = ON_OFF_CONDITION_RSI_BUY_10 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_11 = ON_OFF_CONDITION_RSI_BUY_11 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_12 = ON_OFF_CONDITION_RSI_BUY_12 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_13 = ON_OFF_CONDITION_RSI_BUY_13 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_14 = ON_OFF_CONDITION_RSI_BUY_14 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_15 = ON_OFF_CONDITION_RSI_BUY_15 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_16 = ON_OFF_CONDITION_RSI_BUY_16 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_17 = ON_OFF_CONDITION_RSI_BUY_17 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_18 = ON_OFF_CONDITION_RSI_BUY_18 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_19 = ON_OFF_CONDITION_RSI_BUY_19 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_20 = ON_OFF_CONDITION_RSI_BUY_20 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_21 = ON_OFF_CONDITION_RSI_BUY_21 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_22 = ON_OFF_CONDITION_RSI_BUY_22 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_23 = ON_OFF_CONDITION_RSI_BUY_23 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_24 = ON_OFF_CONDITION_RSI_BUY_24 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_25 = ON_OFF_CONDITION_RSI_BUY_25 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_26 = ON_OFF_CONDITION_RSI_BUY_26 == true ? 1 : 0

RSI_COUNT_SIMPLE_TABLE_NAMES_CONDITIONS_BUY_LABEL = COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_1 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_2 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_3 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_4 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_5 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_6 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_7 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_8 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_9 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_10 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_11 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_12 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_13 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_14 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_15 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_16 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_17 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_18 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_19 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_20 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_21 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_22 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_23 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_24 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_25 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_BUY_26
//-------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//


//--//
//--//


//CONDITIONS FINALS | SELL
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
CONDITION_RSI_SELL_1  = rsi > RSI_UPPER
CONDITION_RSI_SELL_2  = rsi < RSI_UPPER

CONDITION_RSI_SELL_3  = rsi > RSI_LOWER
CONDITION_RSI_SELL_4  = rsi < RSI_LOWER

CONDITION_RSI_SELL_5  = rsi > 50
CONDITION_RSI_SELL_6  = rsi < 50

CONDITION_RSI_SELL_7  = rsi > rsiMA
CONDITION_RSI_SELL_8  = rsi < rsiMA

CONDITION_RSI_SELL_9  = rsiMA > RSI_UPPER
CONDITION_RSI_SELL_10 = rsiMA < RSI_UPPER

CONDITION_RSI_SELL_11 = rsiMA > RSI_LOWER
CONDITION_RSI_SELL_12 = rsiMA < RSI_LOWER

CONDITION_RSI_SELL_13 = ta.crossover(rsi, RSI_UPPER)
CONDITION_RSI_SELL_14 = ta.crossunder(rsi, RSI_UPPER)

CONDITION_RSI_SELL_15 = ta.crossover(rsi, RSI_LOWER)
CONDITION_RSI_SELL_16 = ta.crossunder(rsi, RSI_LOWER)

CONDITION_RSI_SELL_17 = ta.crossover(rsi, 50)
CONDITION_RSI_SELL_18 = ta.crossunder(rsi, 50)

CONDITION_RSI_SELL_19 = ta.crossover(rsi, rsiMA)
CONDITION_RSI_SELL_20 = ta.crossunder(rsi, rsiMA)

CONDITION_RSI_SELL_21 = ta.crossover(rsiMA, RSI_UPPER)
CONDITION_RSI_SELL_22 = ta.crossunder(rsiMA, RSI_UPPER)

CONDITION_RSI_SELL_23 = ta.crossover(rsiMA, RSI_LOWER)
CONDITION_RSI_SELL_24 = ta.crossunder(rsiMA, RSI_LOWER)

CONDITION_RSI_SELL_25 = bullCondAlert
CONDITION_RSI_SELL_26 = bearCondAlert
//-------------------------------------------------------------------------------------------------------------//


//TA.BARSSINCE | SELL
//-------------------------------------------------------------------------------------------------------------//
//OR
OR_TA_CONDITION_RSI_SELL_1  = ON_OFF_CONDITION_RSI_SELL_1  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_1)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_1  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_1  : false
OR_TA_CONDITION_RSI_SELL_2  = ON_OFF_CONDITION_RSI_SELL_2  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_2)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_2  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_2  : false

OR_TA_CONDITION_RSI_SELL_3  = ON_OFF_CONDITION_RSI_SELL_3  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_3)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_3  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_3  : false
OR_TA_CONDITION_RSI_SELL_4  = ON_OFF_CONDITION_RSI_SELL_4  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_4)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_4  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_4  : false

OR_TA_CONDITION_RSI_SELL_5  = ON_OFF_CONDITION_RSI_SELL_5  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_5)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_5  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_5  : false
OR_TA_CONDITION_RSI_SELL_6  = ON_OFF_CONDITION_RSI_SELL_6  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_6)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_6  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_6  : false

OR_TA_CONDITION_RSI_SELL_7  = ON_OFF_CONDITION_RSI_SELL_7  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_7)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_7  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_7  : false
OR_TA_CONDITION_RSI_SELL_8  = ON_OFF_CONDITION_RSI_SELL_8  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_8)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_8  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_8  : false

OR_TA_CONDITION_RSI_SELL_9  = ON_OFF_CONDITION_RSI_SELL_9  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_9)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_9  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_9  : false
OR_TA_CONDITION_RSI_SELL_10 = ON_OFF_CONDITION_RSI_SELL_10 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_10) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_10 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_10 : false

OR_TA_CONDITION_RSI_SELL_11 = ON_OFF_CONDITION_RSI_SELL_11 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_11) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_11 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_11 : false
OR_TA_CONDITION_RSI_SELL_12 = ON_OFF_CONDITION_RSI_SELL_12 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_12) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_12 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_12 : false

OR_TA_CONDITION_RSI_SELL_13 = ON_OFF_CONDITION_RSI_SELL_13 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_13) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_13 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_13 : false
OR_TA_CONDITION_RSI_SELL_14 = ON_OFF_CONDITION_RSI_SELL_14 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_14) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_14 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_14 : false

OR_TA_CONDITION_RSI_SELL_15 = ON_OFF_CONDITION_RSI_SELL_15 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_15) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_15 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_15 : false
OR_TA_CONDITION_RSI_SELL_16 = ON_OFF_CONDITION_RSI_SELL_16 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_16) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_16 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_16 : false

OR_TA_CONDITION_RSI_SELL_17 = ON_OFF_CONDITION_RSI_SELL_17 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_17) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_17 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_17 : false
OR_TA_CONDITION_RSI_SELL_18 = ON_OFF_CONDITION_RSI_SELL_18 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_18) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_18 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_18 : false

OR_TA_CONDITION_RSI_SELL_19 = ON_OFF_CONDITION_RSI_SELL_19 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_19) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_19 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_19 : false
OR_TA_CONDITION_RSI_SELL_20 = ON_OFF_CONDITION_RSI_SELL_20 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_20) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_20 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_20 : false

OR_TA_CONDITION_RSI_SELL_21 = ON_OFF_CONDITION_RSI_SELL_21 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_21) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_21 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_21 : false
OR_TA_CONDITION_RSI_SELL_22 = ON_OFF_CONDITION_RSI_SELL_22 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_22) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_22 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_22 : false

OR_TA_CONDITION_RSI_SELL_23 = ON_OFF_CONDITION_RSI_SELL_23 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_23) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_23 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_23 : false
OR_TA_CONDITION_RSI_SELL_24 = ON_OFF_CONDITION_RSI_SELL_24 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_24) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_24 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_24 : false

OR_TA_CONDITION_RSI_SELL_25 = ON_OFF_CONDITION_RSI_SELL_25 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_25) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_25 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_25 : false
OR_TA_CONDITION_RSI_SELL_26 = ON_OFF_CONDITION_RSI_SELL_26 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_26) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_26 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_26 : false

//--//

//AND
AND_TA_CONDITION_RSI_SELL_1  = ON_OFF_CONDITION_RSI_SELL_1  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_1)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_1  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_1  : true
AND_TA_CONDITION_RSI_SELL_2  = ON_OFF_CONDITION_RSI_SELL_2  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_2)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_2  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_2  : true

AND_TA_CONDITION_RSI_SELL_3  = ON_OFF_CONDITION_RSI_SELL_3  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_3)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_3  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_3  : true
AND_TA_CONDITION_RSI_SELL_4  = ON_OFF_CONDITION_RSI_SELL_4  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_4)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_4  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_4  : true

AND_TA_CONDITION_RSI_SELL_5  = ON_OFF_CONDITION_RSI_SELL_5  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_5)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_5  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_5  : true
AND_TA_CONDITION_RSI_SELL_6  = ON_OFF_CONDITION_RSI_SELL_6  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_6)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_6  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_6  : true

AND_TA_CONDITION_RSI_SELL_7  = ON_OFF_CONDITION_RSI_SELL_7  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_7)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_7  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_7  : true
AND_TA_CONDITION_RSI_SELL_8  = ON_OFF_CONDITION_RSI_SELL_8  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_8)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_8  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_8  : true

AND_TA_CONDITION_RSI_SELL_9  = ON_OFF_CONDITION_RSI_SELL_9  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_9)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_9  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_9  : true
AND_TA_CONDITION_RSI_SELL_10 = ON_OFF_CONDITION_RSI_SELL_10 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_10) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_10 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_10 : true

AND_TA_CONDITION_RSI_SELL_11 = ON_OFF_CONDITION_RSI_SELL_11 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_11) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_11 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_11 : true
AND_TA_CONDITION_RSI_SELL_12 = ON_OFF_CONDITION_RSI_SELL_12 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_12) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_12 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_12 : true

AND_TA_CONDITION_RSI_SELL_13 = ON_OFF_CONDITION_RSI_SELL_13 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_13) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_13 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_13 : true
AND_TA_CONDITION_RSI_SELL_14 = ON_OFF_CONDITION_RSI_SELL_14 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_14) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_14 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_14 : true

AND_TA_CONDITION_RSI_SELL_15 = ON_OFF_CONDITION_RSI_SELL_15 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_15) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_15 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_15 : true
AND_TA_CONDITION_RSI_SELL_16 = ON_OFF_CONDITION_RSI_SELL_16 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_16) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_16 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_16 : true

AND_TA_CONDITION_RSI_SELL_17 = ON_OFF_CONDITION_RSI_SELL_17 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_17) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_17 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_17 : true
AND_TA_CONDITION_RSI_SELL_18 = ON_OFF_CONDITION_RSI_SELL_18 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_18) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_18 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_18 : true

AND_TA_CONDITION_RSI_SELL_19 = ON_OFF_CONDITION_RSI_SELL_19 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_19) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_19 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_19 : true
AND_TA_CONDITION_RSI_SELL_20 = ON_OFF_CONDITION_RSI_SELL_20 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_20) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_20 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_20 : true

AND_TA_CONDITION_RSI_SELL_21 = ON_OFF_CONDITION_RSI_SELL_21 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_21) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_21 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_21 : true
AND_TA_CONDITION_RSI_SELL_22 = ON_OFF_CONDITION_RSI_SELL_22 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_22) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_22 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_22 : true

AND_TA_CONDITION_RSI_SELL_23 = ON_OFF_CONDITION_RSI_SELL_23 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_23) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_23 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_23 : true
AND_TA_CONDITION_RSI_SELL_24 = ON_OFF_CONDITION_RSI_SELL_24 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_24) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_24 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_24 : true

AND_TA_CONDITION_RSI_SELL_25 = ON_OFF_CONDITION_RSI_SELL_25 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_25) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_25 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_25 : true
AND_TA_CONDITION_RSI_SELL_26 = ON_OFF_CONDITION_RSI_SELL_26 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_26) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_26 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_26 : true
//-------------------------------------------------------------------------------------------------------------//

//AND/OR | SELL
//-------------------------------------------------------------------------------------------------------------//
OR_AND_CONDITION_RSI_SELL = TYPE_CONDITION_RSI_SELL == 'or' ? OR_TA_CONDITION_RSI_SELL_1 or OR_TA_CONDITION_RSI_SELL_2 or OR_TA_CONDITION_RSI_SELL_3 or OR_TA_CONDITION_RSI_SELL_4 or OR_TA_CONDITION_RSI_SELL_5 or OR_TA_CONDITION_RSI_SELL_6 or OR_TA_CONDITION_RSI_SELL_7 or OR_TA_CONDITION_RSI_SELL_8 or OR_TA_CONDITION_RSI_SELL_9 or OR_TA_CONDITION_RSI_SELL_10 or OR_TA_CONDITION_RSI_SELL_11 or OR_TA_CONDITION_RSI_SELL_12 or OR_TA_CONDITION_RSI_SELL_13 or OR_TA_CONDITION_RSI_SELL_14 or OR_TA_CONDITION_RSI_SELL_15 or OR_TA_CONDITION_RSI_SELL_16 or OR_TA_CONDITION_RSI_SELL_17 or OR_TA_CONDITION_RSI_SELL_18 or OR_TA_CONDITION_RSI_SELL_19 or OR_TA_CONDITION_RSI_SELL_20 or OR_TA_CONDITION_RSI_SELL_21 or OR_TA_CONDITION_RSI_SELL_22 or OR_TA_CONDITION_RSI_SELL_23 or OR_TA_CONDITION_RSI_SELL_24 or OR_TA_CONDITION_RSI_SELL_25 or OR_TA_CONDITION_RSI_SELL_26 : TYPE_CONDITION_RSI_SELL == 'and' ? AND_TA_CONDITION_RSI_SELL_1 and AND_TA_CONDITION_RSI_SELL_2 and AND_TA_CONDITION_RSI_SELL_3 and AND_TA_CONDITION_RSI_SELL_4 and AND_TA_CONDITION_RSI_SELL_5 and AND_TA_CONDITION_RSI_SELL_6 and AND_TA_CONDITION_RSI_SELL_7 and AND_TA_CONDITION_RSI_SELL_8 and AND_TA_CONDITION_RSI_SELL_9 and AND_TA_CONDITION_RSI_SELL_10 and AND_TA_CONDITION_RSI_SELL_11 and AND_TA_CONDITION_RSI_SELL_12 and AND_TA_CONDITION_RSI_SELL_13 and AND_TA_CONDITION_RSI_SELL_14 and AND_TA_CONDITION_RSI_SELL_15 and AND_TA_CONDITION_RSI_SELL_16 and AND_TA_CONDITION_RSI_SELL_17 and AND_TA_CONDITION_RSI_SELL_18 and AND_TA_CONDITION_RSI_SELL_19 and AND_TA_CONDITION_RSI_SELL_20 and AND_TA_CONDITION_RSI_SELL_21 and AND_TA_CONDITION_RSI_SELL_22 and AND_TA_CONDITION_RSI_SELL_23 and AND_TA_CONDITION_RSI_SELL_24 and AND_TA_CONDITION_RSI_SELL_25 and AND_TA_CONDITION_RSI_SELL_26 : true
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//


//--//


//NAMES CONDITIONS | LABELS | SELL :{
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
NAME_TA_CONDITION_RSI_SELL_1  = ON_OFF_CONDITION_RSI_SELL_1  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_1)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_1  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_1  : false
NAME_TA_CONDITION_RSI_SELL_2  = ON_OFF_CONDITION_RSI_SELL_2  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_2)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_2  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_2  : false

NAME_TA_CONDITION_RSI_SELL_3  = ON_OFF_CONDITION_RSI_SELL_3  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_3)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_3  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_3  : false
NAME_TA_CONDITION_RSI_SELL_4  = ON_OFF_CONDITION_RSI_SELL_4  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_4)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_4  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_4  : false

NAME_TA_CONDITION_RSI_SELL_5  = ON_OFF_CONDITION_RSI_SELL_5  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_5)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_5  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_5  : false
NAME_TA_CONDITION_RSI_SELL_6  = ON_OFF_CONDITION_RSI_SELL_6  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_6)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_6  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_6  : false

NAME_TA_CONDITION_RSI_SELL_7  = ON_OFF_CONDITION_RSI_SELL_7  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_7)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_7  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_7  : false
NAME_TA_CONDITION_RSI_SELL_8  = ON_OFF_CONDITION_RSI_SELL_8  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_8)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_8  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_8  : false

NAME_TA_CONDITION_RSI_SELL_9  = ON_OFF_CONDITION_RSI_SELL_9  and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_9)  <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_9  == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_9  : false
NAME_TA_CONDITION_RSI_SELL_10 = ON_OFF_CONDITION_RSI_SELL_10 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_10) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_10 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_10 : false

NAME_TA_CONDITION_RSI_SELL_11 = ON_OFF_CONDITION_RSI_SELL_11 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_11) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_11 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_11 : false
NAME_TA_CONDITION_RSI_SELL_12 = ON_OFF_CONDITION_RSI_SELL_12 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_12) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_12 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_12 : false

NAME_TA_CONDITION_RSI_SELL_13 = ON_OFF_CONDITION_RSI_SELL_13 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_13) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_13 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_13 : false
NAME_TA_CONDITION_RSI_SELL_14 = ON_OFF_CONDITION_RSI_SELL_14 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_14) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_14 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_14 : false

NAME_TA_CONDITION_RSI_SELL_15 = ON_OFF_CONDITION_RSI_SELL_15 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_15) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_15 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_15 : false
NAME_TA_CONDITION_RSI_SELL_16 = ON_OFF_CONDITION_RSI_SELL_16 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_16) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_16 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_16 : false

NAME_TA_CONDITION_RSI_SELL_17 = ON_OFF_CONDITION_RSI_SELL_17 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_17) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_17 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_17 : false
NAME_TA_CONDITION_RSI_SELL_18 = ON_OFF_CONDITION_RSI_SELL_18 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_18) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_18 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_18 : false

NAME_TA_CONDITION_RSI_SELL_19 = ON_OFF_CONDITION_RSI_SELL_19 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_19) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_19 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_19 : false
NAME_TA_CONDITION_RSI_SELL_20 = ON_OFF_CONDITION_RSI_SELL_20 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_20) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_20 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_20 : false

NAME_TA_CONDITION_RSI_SELL_21 = ON_OFF_CONDITION_RSI_SELL_21 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_21) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_21 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_21 : false
NAME_TA_CONDITION_RSI_SELL_22 = ON_OFF_CONDITION_RSI_SELL_22 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_22) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_22 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_22 : false

NAME_TA_CONDITION_RSI_SELL_23 = ON_OFF_CONDITION_RSI_SELL_23 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_23) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_23 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_23 : false
NAME_TA_CONDITION_RSI_SELL_24 = ON_OFF_CONDITION_RSI_SELL_24 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_24) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_24 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_24 : false

NAME_TA_CONDITION_RSI_SELL_25 = ON_OFF_CONDITION_RSI_SELL_25 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_25) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_25 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_25 : false
NAME_TA_CONDITION_RSI_SELL_26 = ON_OFF_CONDITION_RSI_SELL_26 and RSI_true_signal_up_to_X_bar_back_SELL == true ? ta.barssince(CONDITION_RSI_SELL_26) <= RSI_signal_up_to_X_bar_back_SELL : ON_OFF_CONDITION_RSI_SELL_26 == true and RSI_true_signal_up_to_X_bar_back_SELL == false ? CONDITION_RSI_SELL_26 : false
//-------------------------------------------------------------------------------------------------------------//


//SIMPLE TEXT CONDITIONS LABEL | SELL
//-------------------------------------------------------------------------------------------------------------//
NAME_CONDITION_RSI_SELL_1  = NAME_TA_CONDITION_RSI_SELL_1  == true ? '\nRSI > ' + str.tostring(RSI_UPPER) : na
NAME_CONDITION_RSI_SELL_2  = NAME_TA_CONDITION_RSI_SELL_2  == true ? '\nRSI < ' + str.tostring(RSI_UPPER) : na

NAME_CONDITION_RSI_SELL_3  = NAME_TA_CONDITION_RSI_SELL_3  == true ? '\nRSI > ' + str.tostring(RSI_LOWER) : na
NAME_CONDITION_RSI_SELL_4  = NAME_TA_CONDITION_RSI_SELL_4  == true ? '\nRSI < ' + str.tostring(RSI_LOWER) : na

NAME_CONDITION_RSI_SELL_5  = NAME_TA_CONDITION_RSI_SELL_5  == true ? '\nRSI > Middle' : na
NAME_CONDITION_RSI_SELL_6  = NAME_TA_CONDITION_RSI_SELL_6  == true ? '\nRSI < Middle' : na

NAME_CONDITION_RSI_SELL_7  = NAME_TA_CONDITION_RSI_SELL_7  == true ? '\nRSI > MA' : na
NAME_CONDITION_RSI_SELL_8  = NAME_TA_CONDITION_RSI_SELL_8  == true ? '\nRSI < MA' : na

NAME_CONDITION_RSI_SELL_9  = NAME_TA_CONDITION_RSI_SELL_9  == true ? '\nMA > ' + str.tostring(RSI_UPPER) : na
NAME_CONDITION_RSI_SELL_10 = NAME_TA_CONDITION_RSI_SELL_10 == true ? '\nMA < ' + str.tostring(RSI_UPPER) : na

NAME_CONDITION_RSI_SELL_11 = NAME_TA_CONDITION_RSI_SELL_11 == true ? '\nMA > ' + str.tostring(RSI_LOWER) : na
NAME_CONDITION_RSI_SELL_12 = NAME_TA_CONDITION_RSI_SELL_12 == true ? '\nMA < ' + str.tostring(RSI_LOWER) : na

NAME_CONDITION_RSI_SELL_13 = NAME_TA_CONDITION_RSI_SELL_13 == true ? '\nRSI (Crossover) '  + str.tostring(RSI_UPPER) : na
NAME_CONDITION_RSI_SELL_14 = NAME_TA_CONDITION_RSI_SELL_14 == true ? '\nRSI (Crossunder) ' + str.tostring(RSI_UPPER) : na

NAME_CONDITION_RSI_SELL_15 = NAME_TA_CONDITION_RSI_SELL_15 == true ? '\nRSI (Crossover) '  + str.tostring(RSI_LOWER) : na
NAME_CONDITION_RSI_SELL_16 = NAME_TA_CONDITION_RSI_SELL_16 == true ? '\nRSI (Crossunder) ' + str.tostring(RSI_LOWER) : na

NAME_CONDITION_RSI_SELL_17 = NAME_TA_CONDITION_RSI_SELL_17 == true ? '\nRSI (Crossover) Middle'  : na
NAME_CONDITION_RSI_SELL_18 = NAME_TA_CONDITION_RSI_SELL_18 == true ? '\nRSI (Crossunder) Middle' : na

NAME_CONDITION_RSI_SELL_19 = NAME_TA_CONDITION_RSI_SELL_19 == true ? '\nRSI (Crossover) MA'  : na
NAME_CONDITION_RSI_SELL_20 = NAME_TA_CONDITION_RSI_SELL_20 == true ? '\nRSI (Crossunder) MA' : na

NAME_CONDITION_RSI_SELL_21 = NAME_TA_CONDITION_RSI_SELL_21 == true ? '\nMA (Crossover) '  + str.tostring(RSI_UPPER) : na
NAME_CONDITION_RSI_SELL_22 = NAME_TA_CONDITION_RSI_SELL_22 == true ? '\nMA (Crossunder) ' + str.tostring(RSI_UPPER) : na

NAME_CONDITION_RSI_SELL_23 = NAME_TA_CONDITION_RSI_SELL_23 == true ? '\nMA (Crossover) '  + str.tostring(RSI_LOWER) : na
NAME_CONDITION_RSI_SELL_24 = NAME_TA_CONDITION_RSI_SELL_24 == true ? '\nMA (Crossunder) ' + str.tostring(RSI_LOWER) : na

NAME_CONDITION_RSI_SELL_25 = NAME_TA_CONDITION_RSI_SELL_25 == true ? '\nRSI Divergence Bull' : na
NAME_CONDITION_RSI_SELL_26 = NAME_TA_CONDITION_RSI_SELL_26 == true ? '\nRSI Divergence Bear' : na

RSI_NAMES_CONDITIONS_SELL_LABEL                  = NAME_CONDITION_RSI_SELL_1 + NAME_CONDITION_RSI_SELL_2 + NAME_CONDITION_RSI_SELL_3 + NAME_CONDITION_RSI_SELL_4 + NAME_CONDITION_RSI_SELL_5 + NAME_CONDITION_RSI_SELL_6 + NAME_CONDITION_RSI_SELL_7 + NAME_CONDITION_RSI_SELL_8 + NAME_CONDITION_RSI_SELL_9 + NAME_CONDITION_RSI_SELL_10 + NAME_CONDITION_RSI_SELL_11 + NAME_CONDITION_RSI_SELL_12 + NAME_CONDITION_RSI_SELL_13 + NAME_CONDITION_RSI_SELL_14 + NAME_CONDITION_RSI_SELL_15 + NAME_CONDITION_RSI_SELL_16 + NAME_CONDITION_RSI_SELL_17 + NAME_CONDITION_RSI_SELL_18 + NAME_CONDITION_RSI_SELL_19 + NAME_CONDITION_RSI_SELL_20 + NAME_CONDITION_RSI_SELL_21 + NAME_CONDITION_RSI_SELL_22 + NAME_CONDITION_RSI_SELL_23 + NAME_CONDITION_RSI_SELL_24 + NAME_CONDITION_RSI_SELL_25 + NAME_CONDITION_RSI_SELL_26
//-------------------------------------------------------------------------------------------------------------//

//-------------------------------------------------------------------------------------------------------------//
RSI_NAMES_CONDITIONS_SELL_LABEL_LABEL_ENTRY_SELL = NAME_CONDITION_RSI_SELL_26 + NAME_CONDITION_RSI_SELL_25 + NAME_CONDITION_RSI_SELL_24 + NAME_CONDITION_RSI_SELL_23 + NAME_CONDITION_RSI_SELL_22 + NAME_CONDITION_RSI_SELL_21 + NAME_CONDITION_RSI_SELL_20 + NAME_CONDITION_RSI_SELL_19 + NAME_CONDITION_RSI_SELL_18 + NAME_CONDITION_RSI_SELL_17 + NAME_CONDITION_RSI_SELL_16 + NAME_CONDITION_RSI_SELL_15 + NAME_CONDITION_RSI_SELL_14 + NAME_CONDITION_RSI_SELL_13 + NAME_CONDITION_RSI_SELL_12 + NAME_CONDITION_RSI_SELL_11 + NAME_CONDITION_RSI_SELL_10 + NAME_CONDITION_RSI_SELL_9 + NAME_CONDITION_RSI_SELL_8 + NAME_CONDITION_RSI_SELL_7 + NAME_CONDITION_RSI_SELL_6 + NAME_CONDITION_RSI_SELL_5 + NAME_CONDITION_RSI_SELL_4 + NAME_CONDITION_RSI_SELL_3 + NAME_CONDITION_RSI_SELL_2 + NAME_CONDITION_RSI_SELL_1
//-------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
// :}


//TEXT CONDITIONS TABLES | SELL
//-------------------------------------------------------------------------------------------------------------//
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_1  = ON_OFF_CONDITION_RSI_SELL_1  == true ? '\nRSI > ' + str.tostring(RSI_UPPER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_2  = ON_OFF_CONDITION_RSI_SELL_2  == true ? '\nRSI < ' + str.tostring(RSI_UPPER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_3  = ON_OFF_CONDITION_RSI_SELL_3  == true ? '\nRSI > ' + str.tostring(RSI_LOWER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_4  = ON_OFF_CONDITION_RSI_SELL_4  == true ? '\nRSI < ' + str.tostring(RSI_LOWER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_5  = ON_OFF_CONDITION_RSI_SELL_5  == true ? '\nRSI > Middle' : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_6  = ON_OFF_CONDITION_RSI_SELL_6  == true ? '\nRSI < Middle' : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_7  = ON_OFF_CONDITION_RSI_SELL_7  == true ? '\nRSI > MA' : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_8  = ON_OFF_CONDITION_RSI_SELL_8  == true ? '\nRSI < MA' : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_9  = ON_OFF_CONDITION_RSI_SELL_9  == true ? '\nMA > ' + str.tostring(RSI_UPPER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_10 = ON_OFF_CONDITION_RSI_SELL_10 == true ? '\nMA < ' + str.tostring(RSI_UPPER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_11 = ON_OFF_CONDITION_RSI_SELL_11 == true ? '\nMA > ' + str.tostring(RSI_LOWER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_12 = ON_OFF_CONDITION_RSI_SELL_12 == true ? '\nMA < ' + str.tostring(RSI_LOWER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_13 = ON_OFF_CONDITION_RSI_SELL_13 == true ? '\nRSI (Crossover) '  + str.tostring(RSI_UPPER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_14 = ON_OFF_CONDITION_RSI_SELL_14 == true ? '\nRSI (Crossunder) ' + str.tostring(RSI_UPPER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_15 = ON_OFF_CONDITION_RSI_SELL_15 == true ? '\nRSI (Crossover) '  + str.tostring(RSI_LOWER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_16 = ON_OFF_CONDITION_RSI_SELL_16 == true ? '\nRSI (Crossunder) ' + str.tostring(RSI_LOWER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_17 = ON_OFF_CONDITION_RSI_SELL_17 == true ? '\nRSI (Crossover) Middle'  : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_18 = ON_OFF_CONDITION_RSI_SELL_18 == true ? '\nRSI (Crossunder) Middle' : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_19 = ON_OFF_CONDITION_RSI_SELL_19 == true ? '\nRSI (Crossover) MA'  : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_20 = ON_OFF_CONDITION_RSI_SELL_20 == true ? '\nRSI (Crossunder) MA' : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_21 = ON_OFF_CONDITION_RSI_SELL_21 == true ? '\nMA (Crossover) '  + str.tostring(RSI_UPPER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_22 = ON_OFF_CONDITION_RSI_SELL_22 == true ? '\nMA (Crossunder) ' + str.tostring(RSI_UPPER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_23 = ON_OFF_CONDITION_RSI_SELL_23 == true ? '\nMA (Crossover) '  + str.tostring(RSI_LOWER) : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_24 = ON_OFF_CONDITION_RSI_SELL_24 == true ? '\nMA (Crossunder) ' + str.tostring(RSI_LOWER) : na

SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_25 = ON_OFF_CONDITION_RSI_SELL_25 == true ? '\nRSI Divergence Bull' : na
SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_26 = ON_OFF_CONDITION_RSI_SELL_26 == true ? '\nRSI Divergence Bear' : na

RSI_SIMPLE_TABLE_NAMES_CONDITIONS_SELL_LABEL = SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_1 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_2 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_3 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_4 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_5 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_6 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_7 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_8 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_9 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_10 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_11 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_12 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_13 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_14 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_15 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_16 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_17 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_18 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_19 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_20 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_21 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_22 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_23 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_24 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_25 + SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_26
//-------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//


//COUNT CONDITIONS TABLES | SELL
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_1  = ON_OFF_CONDITION_RSI_SELL_1  == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_2  = ON_OFF_CONDITION_RSI_SELL_2  == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_3  = ON_OFF_CONDITION_RSI_SELL_3  == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_4  = ON_OFF_CONDITION_RSI_SELL_4  == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_5  = ON_OFF_CONDITION_RSI_SELL_5  == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_6  = ON_OFF_CONDITION_RSI_SELL_6  == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_7  = ON_OFF_CONDITION_RSI_SELL_7  == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_8  = ON_OFF_CONDITION_RSI_SELL_8  == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_9  = ON_OFF_CONDITION_RSI_SELL_9  == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_10 = ON_OFF_CONDITION_RSI_SELL_10 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_11 = ON_OFF_CONDITION_RSI_SELL_11 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_12 = ON_OFF_CONDITION_RSI_SELL_12 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_13 = ON_OFF_CONDITION_RSI_SELL_13 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_14 = ON_OFF_CONDITION_RSI_SELL_14 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_15 = ON_OFF_CONDITION_RSI_SELL_15 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_16 = ON_OFF_CONDITION_RSI_SELL_16 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_17 = ON_OFF_CONDITION_RSI_SELL_17 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_18 = ON_OFF_CONDITION_RSI_SELL_18 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_19 = ON_OFF_CONDITION_RSI_SELL_19 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_20 = ON_OFF_CONDITION_RSI_SELL_20 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_21 = ON_OFF_CONDITION_RSI_SELL_21 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_22 = ON_OFF_CONDITION_RSI_SELL_22 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_23 = ON_OFF_CONDITION_RSI_SELL_23 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_24 = ON_OFF_CONDITION_RSI_SELL_24 == true ? 1 : 0

COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_25 = ON_OFF_CONDITION_RSI_SELL_25 == true ? 1 : 0
COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_26 = ON_OFF_CONDITION_RSI_SELL_26 == true ? 1 : 0

RSI_COUNT_SIMPLE_TABLE_NAMES_CONDITIONS_SELL_LABEL = COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_1 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_2 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_3 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_4 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_5 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_6 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_7 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_8 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_9 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_10 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_11 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_12 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_13 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_14 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_15 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_16 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_17 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_18 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_19 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_20 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_21 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_22 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_23 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_24 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_25 + COUNT_SIMPLE_TABLE_NAME_CONDITION_RSI_SELL_26
//-------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//


//--//
//--//


//LABEL (→) ╭╯ RSI
//-------------------------------------------------------------------------------------------------------------//----------------------------------------------------------------------------------------------------//-------------------------------------------------------------------------------------------------------------//
if ACTIVE_LEFT_LABELS
    LBL_RSI = label.new      (bar_index + 1, rsi,       text = ACTIVE_NUMBER_LABELS_RSI ? str.tostring(rsi,   '#.#') : 'RSI', size = Size_Flag_Entry_RSI, tooltip = ACTIVE_NUMBER_LABELS_RSI ? 'RSI' : str.tostring(rsi,   '#.#'), style = label.style_label_left, color = color.new(#7e57c2, 0), textcolor = color.new(#000000, 0), text_font_family = font.family_default) // ╭╯
    label.delete(LBL_RSI[1])
//-------------------------------------------------------------------------------------------------------------//


//LABEL (→) ╭╯ MA RSI
//-------------------------------------------------------------------------------------------------------------//
if ACTIVE_LEFT_LABELS
    LBL_RSI_MA = label.new   (bar_index + 1, rsiMA,     text = ACTIVE_NUMBER_LABELS_RSI ? str.tostring(rsiMA, '#.#') : 'MA',  size = Size_Flag_Entry_RSI, tooltip = ACTIVE_NUMBER_LABELS_RSI ? 'MA'  : str.tostring(rsiMA, '#.#'), style = label.style_label_left, color = color.new(#FFEB3B, 0), textcolor = color.new(#000000, 0), text_font_family = font.family_default) // ╭╯
    label.delete(LBL_RSI_MA[1])
//-------------------------------------------------------------------------------------------------------------//----------------------------------------------------------------------------------------------------//-------------------------------------------------------------------------------------------------------------//


//--//


//LABEL (→) RSI Upper Band 
//-------------------------------------------------------------------------------------------------------------//----------------------------------------------------------------------------------------------------//-------------------------------------------------------------------------------------------------------------//
if ACTIVE_LEFT_LABELS
    LBL_RSI_UPPER = label.new(bar_index + 1, RSI_UPPER, text = str.tostring(RSI_UPPER),                                       size = Size_Flag_Entry_RSI, tooltip = 'Upper Band',                                                  style = label.style_label_left, color = color.new(#787B86, 0), textcolor = color.new(#000000, 0), text_font_family = font.family_default)
    label.delete(LBL_RSI_UPPER[1])
//-------------------------------------------------------------------------------------------------------------//


//LABEL (→) RSI Lower Band
//-------------------------------------------------------------------------------------------------------------//
if ACTIVE_LEFT_LABELS
    LBL_RSI_LOWER = label.new(bar_index + 1, RSI_LOWER, text = str.tostring(RSI_LOWER),                                       size = Size_Flag_Entry_RSI, tooltip = 'Lower Band',                                                  style = label.style_label_left, color = color.new(#787B86, 0), textcolor = color.new(#000000, 0), text_font_family = font.family_default)
    label.delete(LBL_RSI_LOWER[1])
//-------------------------------------------------------------------------------------------------------------//----------------------------------------------------------------------------------------------------//-------------------------------------------------------------------------------------------------------------//


//--//
//--//


//LABELS | PLOTSHAPES | PLOTS | BUY/SELL :{
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//

//PLOTSHAPE diamond | Buy | flag overlay == false
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
plotshape(On_Of_Type_Flag                                                                            ? OR_AND_CONDITION_RSI_BUY                                       : false,               title = 'Buy',  style = shape.diamond,   location = location.bottom, color = color.new(#26A69A, 0),  textcolor = color.new(#000000, 0), size = size.auto, force_overlay = false, display = display.all)

plotshape(On_Of_Type_Flag and Type_Flag == 'flag' or On_Of_Type_Flag and Type_Flag == 'flag overlay' ? OR_AND_CONDITION_RSI_BUY and not OR_AND_CONDITION_RSI_BUY[1]   : false, text = 'Buy', title = 'Buy',  style = shape.labeldown, location = location.bottom, color = color.new(#26A69A, 0),  textcolor = color.new(#000000, 0), size = size.auto, force_overlay = false, display = display.all)
//-------------------------------------------------------------------------------------------------------------//

//PLOTSHAPE diamond | Sell | flag overlay == false
//-------------------------------------------------------------------------------------------------------------//
plotshape(On_Of_Type_Flag                                                                            ? OR_AND_CONDITION_RSI_SELL                                      : false,                title = 'Sell', style = shape.diamond,  location = location.top,    color = color.new(#b71c1c, 10), textcolor = color.new(#000000, 0), size = size.auto, force_overlay = false, display = display.all)

plotshape(On_Of_Type_Flag and Type_Flag == 'flag' or On_Of_Type_Flag and Type_Flag == 'flag overlay' ? OR_AND_CONDITION_RSI_SELL and not OR_AND_CONDITION_RSI_SELL[1] : false, text = 'Sell', title = 'Sell', style = shape.labelup,  location = location.top,    color = color.new(#b71c1c, 10), textcolor = color.new(#000000, 0), size = size.auto, force_overlay = false, display = display.all)
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//

//--//

//PLOTSHAPE diamond | Buy | flag overlay == true
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
plotshape(On_Of_Type_Flag and Type_Flag == 'flag overlay'                                            ? OR_AND_CONDITION_RSI_BUY                                       : false,                title = 'Buy', style = shape.diamond,   location = location.bottom, color = color.new(#26A69A, 0),  textcolor = color.new(#000000, 0), size = size.auto, force_overlay = true,  display = display.all)

plotshape(On_Of_Type_Flag and Type_Flag == 'flag overlay'                                            ? OR_AND_CONDITION_RSI_BUY and not OR_AND_CONDITION_RSI_BUY[1]   : false, text = 'Buy',  title = 'Buy', style = shape.labeldown, location = location.bottom, color = color.new(#26A69A, 0),  textcolor = color.new(#000000, 0), size = size.auto, force_overlay = true,  display = display.all)
//-------------------------------------------------------------------------------------------------------------//

//PLOTSHAPE diamond | Sell | flag overlay == true
//-------------------------------------------------------------------------------------------------------------//
plotshape(On_Of_Type_Flag and Type_Flag == 'flag overlay'                                            ? OR_AND_CONDITION_RSI_SELL                                      : false,                title = 'Sell', style = shape.diamond,  location = location.top,    color = color.new(#b71c1c, 10), textcolor = color.new(#000000, 0), size = size.auto, force_overlay = true,  display = display.all)

plotshape(On_Of_Type_Flag and Type_Flag == 'flag overlay'                                            ? OR_AND_CONDITION_RSI_SELL and not OR_AND_CONDITION_RSI_SELL[1] : false, text = 'Sell', title = 'Sell', style = shape.labelup,  location = location.top,    color = color.new(#b71c1c, 10), textcolor = color.new(#000000, 0), size = size.auto, force_overlay = true,  display = display.all)
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//


//--//
//--//


//LABELS RSI | BUY
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//SIGNAL_SMOOTHING
if OR_AND_CONDITION_RSI_BUY and not OR_AND_CONDITION_RSI_BUY[1] and On_Of_Type_Flag and (Type_Flag == 'label' or Type_Flag == 'label conditions')

    LBL_RSI_BUY = label.new(x = bar_index,  y = RSI_LOWER, text = Type_Flag == 'label conditions' ? RSI_NAMES_CONDITIONS_BUY_LABEL                   : 'Buy',  size = Size_Flag_Entry_RSI, tooltip = Type_Flag == 'label conditions' ? 'Buy'  : RSI_NAMES_CONDITIONS_BUY_LABEL,                   style = label.style_label_up,   color = color.new(#26A69A, 0),  textcolor = color.new(#000000, 0), text_font_family = font.family_default)
    LBL_RSI_BUY
//-------------------------------------------------------------------------------------------------------------//

//LABELS RSI | SELL
//-------------------------------------------------------------------------------------------------------------//
if OR_AND_CONDITION_RSI_SELL and not OR_AND_CONDITION_RSI_SELL[1] and On_Of_Type_Flag and (Type_Flag == 'label' or Type_Flag == 'label conditions')

    LBL_RSI_SELL = label.new(x = bar_index, y = RSI_UPPER, text = Type_Flag == 'label conditions' ? RSI_NAMES_CONDITIONS_SELL_LABEL_LABEL_ENTRY_SELL : 'Sell', size = Size_Flag_Entry_RSI, tooltip = Type_Flag == 'label conditions' ? 'Sell' : RSI_NAMES_CONDITIONS_SELL_LABEL_LABEL_ENTRY_SELL, style = label.style_label_down, color = color.new(#b71c1c, 10), textcolor = color.new(#000000, 0), text_font_family = font.family_default)
    LBL_RSI_SELL
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
// :}


//--//
//--//


//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
// Alertcondition() & Alert()
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//

// alert() Automation 
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
tooltip_Frequency         = 'Edit : How often the alert is triggered.\n\nPossible values are:\n\n◾ alert.freq_all (all function calls trigger the alert).\n\n◾ alert.freq_once_per_bar (first function call during bar triggers alert).\n\n◾ alert.freq_once_per_bar_close (function call triggers alert only when it occurs during the last script iteration of the realtime bar, when it closes).\n\n◽ Default is : alert.freq_once_per_bar\n\n◾ This option is only valid if you are going to use the menu below, i.e. the option:\n\n\'Any Alert() function call\''

tooltip_Type_Alert        = 'Edit : Alert() Mode\n\n ◾ Single (first valid bar only)\n ◾ The alert triggers only on the first bar where the signal appears.\n\n ◾ Continuous (every valid bar)\n ◾ The alert triggers on every bar while the signal remains active.\n\n ◽ Default Setting : Single (first valid bar only)'


group_Alert_Automation    = '        🤖 Alert() Frequency'

Freq_Alert                = input.string(title = '      🤖 Alert() Drive Frequency', defval = alert.freq_once_per_bar_close,   group = group_Alert_Automation, tooltip = tooltip_Frequency,  options = [alert.freq_all, alert.freq_once_per_bar, alert.freq_once_per_bar_close])

Alert_Type                = input.string(title = '      🤖 Alert() Type',            defval = 'Single (first valid bar only)', group = group_Alert_Automation, tooltip = tooltip_Type_Alert, options = ['Single (first valid bar only)', 'Continuous (every valid bar)'])
//-------------------------------------------------------------------------------------------------------------//

//--//
//--//

//LONG &  SHORT FINALS
//-------------------------------------------------------------------------------------------------------------//
LONG_ENTRY_FINAL          = Alert_Type == 'Single (first valid bar only)' ? OR_AND_CONDITION_RSI_BUY  and not OR_AND_CONDITION_RSI_BUY[1]  : OR_AND_CONDITION_RSI_BUY
SHORT_ENTRY_FINAL         = Alert_Type == 'Single (first valid bar only)' ? OR_AND_CONDITION_RSI_SELL and not OR_AND_CONDITION_RSI_SELL[1] : OR_AND_CONDITION_RSI_SELL
//-------------------------------------------------------------------------------------------------------------//

//-------------------------------------------------------------------------------------------------------------//
tooltip_alert_Long_Entry  = '🤖 Message: Buy'
tooltip_alert_Short_Entry = '🤖 Message: Sell'
//-------------------------------------------------------------------------------------------------------------//

// alertcondition() Automation
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
alertcondition(condition  = LONG_ENTRY_FINAL,  title = '🤖 Message: Buy',  message = tooltip_alert_Long_Entry)
alertcondition(condition  = SHORT_ENTRY_FINAL, title = '🤖 Message: Sell', message = tooltip_alert_Short_Entry)
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//

//--//
//--//

//-------------------------------------------------------------------------------------------------------------//
group_Alert_Entry_Long    = '        🤖 Automation'

message_long_entry_1      = input.text_area(title = '       🤖 Message: Buy',  defval = '', confirm = false, group = group_Alert_Entry_Long, tooltip = tooltip_alert_Long_Entry)
if LONG_ENTRY_FINAL
    alert(message_long_entry_1, Freq_Alert)
//-------------------------------------------------------------------------------------------------------------//


//-------------------------------------------------------------------------------------------------------------//
message_short_entry_1     = input.text_area(title = '       🤖 Message: Sell', defval = '', confirm = false, group = group_Alert_Entry_Long, tooltip = tooltip_alert_Short_Entry)
if SHORT_ENTRY_FINAL
    alert(message_short_entry_1, Freq_Alert)
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//


//--//
//--//


// TABLE OF CONDITIONS :{
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//

//TABLE BUY
//-------------------------------------------------------------------------------------------------------------//
Table_Dev_By1           = table.new(position = position.top_right, columns = 1, rows = 2, bgcolor = OR_AND_CONDITION_RSI_BUY ? color.new(#26A69A, 0) : color.new(#787B86, 0), frame_color = color.new(#26A69A, 40), border_color = color.new(#000000, 0), frame_width = 2, border_width = 1)

if ACTIVE_TABLES
    table.cell(table_id = Table_Dev_By1, column = 0, row = 0, width = 0, height = 0, text = RSI_COUNT_SIMPLE_TABLE_NAMES_CONDITIONS_BUY_LABEL > 1 ? 'Buy ' + '(' + TYPE_CONDITION_RSI_BUY + ')' : RSI_COUNT_SIMPLE_TABLE_NAMES_CONDITIONS_BUY_LABEL != 0 ? 'Buy' : '', text_size = Size_Flag_Entry_RSI, text_color = color.new(#000000, 0), bgcolor = na, tooltip = 'Buy', text_font_family = font.family_default, text_halign = text.align_center)

if ACTIVE_TABLES
    table.cell(table_id = Table_Dev_By1, column = 0, row = 1, width = 0, height = 0, text = OR_AND_CONDITION_RSI_BUY ? RSI_NAMES_CONDITIONS_BUY_LABEL : RSI_SIMPLE_TABLE_NAMES_CONDITIONS_BUY_LABEL, text_size = Size_Flag_Entry_RSI, text_color = color.new(#000000, 0), bgcolor = na, tooltip = 'Buy', text_font_family = font.family_default, text_halign = text.align_left)
//-------------------------------------------------------------------------------------------------------------//


//--//


//TABLE SELL
//-------------------------------------------------------------------------------------------------------------//
Table_Dev_By2           = table.new(position = position.bottom_right, columns = 1, rows = 2, bgcolor = OR_AND_CONDITION_RSI_SELL ? color.new(#b71c1c, 10) : color.new(#787B86, 0), frame_color = color.new(#b71c1c, 50), border_color = color.new(#000000, 0), frame_width = 2, border_width = 1)

if ACTIVE_TABLES
    table.cell(table_id = Table_Dev_By2, column = 0, row = 0, width = 0, height = 0, text = RSI_COUNT_SIMPLE_TABLE_NAMES_CONDITIONS_SELL_LABEL > 1 ? 'Sell ' + '(' + TYPE_CONDITION_RSI_SELL + ')' : RSI_COUNT_SIMPLE_TABLE_NAMES_CONDITIONS_SELL_LABEL != 0 ? 'Sell' : '', text_size = Size_Flag_Entry_RSI, text_color = color.new(#000000, 0), bgcolor = na, tooltip = 'Sell', text_font_family = font.family_default, text_halign = text.align_center)

if ACTIVE_TABLES
    table.cell(table_id = Table_Dev_By2, column = 0, row = 1, width = 0, height = 0, text = OR_AND_CONDITION_RSI_SELL ? RSI_NAMES_CONDITIONS_SELL_LABEL : RSI_SIMPLE_TABLE_NAMES_CONDITIONS_SELL_LABEL, text_size = Size_Flag_Entry_RSI, text_color = color.new(#000000, 0), bgcolor = na, tooltip = 'Sell', text_font_family = font.family_default, text_halign = text.align_left)
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
// :}


//--//
//--//


// 🏛️ Titans_Invest 🏛️
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
Tooltip_Mission = 'Inspire Traders to manifest Magic in the Market'
Tooltip_Vision  = 'To elevate collective Energy 𐓷𐓏'

Mission_Titan   = input(false, title = 'Mission 🗺', group = '\n', tooltip = Tooltip_Mission)
Vision_Titan    = input(false, title = 'Vision 𐓏',   group = '\n', tooltip = Tooltip_Vision)
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//


//--//
//--//


// ®️INDICATOR PROJECT
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
// 📜 ®️Indicator: RSI Full [Titans_Invest]


// 🧙 Of: Titans_Invest & DiFlip
// 🌬️ ﮩ٨ـﮩﮩ٨ـ📜ﮩ٨ـﮩﮩ٨ـﮩ٨ـﮩﮩ٨ـ🌲ﮩ٨ـﮩﮩ٨ـﮩ٨ـﮩﮩ٨ـ👨‍💻ﮩ٨ـﮩﮩ٨ـ A Dose of Magic ✨
// 🧑‍💼 For: 🌇 Titans City 🌃

// 🧙Titans_Invest The Wizards Without Gloves. 🧤
// 🪄 Bringing you what has never been seen in PineScript. 


//  ____  __ _  ____ 
// (  __)(  ( \(    \
//  ) _) /    / ) D (
// (____)\_)__)(____
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------------//--//--------------------------------------------------------------------------------------------------------------//
````
