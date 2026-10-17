# Strategy / Connectable [Azullian]

- url: https://www.tradingview.com/script/JDX8IhL0-Strategy-Connectable-Azullian/
- type: strategy
- pine_id: PUB;f434696bb50346ad9d01600e6f277f49
- version: 3.0

## Description

The [i]connectable strategy[/i] serves as a foundational component in our [i]indicator system[/i] on TradingView, designed for intuitive testing, visualization, and construction of trading strategies. In concert with the [i]connectable signal filter[/i], it forms a cohesive unit that allows for efficient signal processing and strategy implementation. This integration enables the strategy to receive and act on weighted signals from various connectable indicators, making it a versatile tool for both novice and experienced traders.

Let's review the separate parts of this indicator.

█ [b]STRATEGY INPUTS[/b]

We've provided an input to connect a signal filter or indicators or chains (→) which is set to 'Close' by default. 

[image]https://www.tradingview.com/x/wfFYbPu5/[/image]

An input has several controls: 
 • [b]Input:[/b] Connect indicators or signal filter here, choose indicators with a compatible : Signal connector.
 • [b]SM - Signal Mode:[/b] Choose a trading direction compatible with the settings in your signal filter



█ [b]POSITION INVESTMENT[/b]
Determine the percentage of your trading budget you would like to use in each position based on the strategy's profit or loss.

[image]https://www.tradingview.com/x/DbTdACOJ/[/image]

 • [b]LINVB - Loss Investment Base:[/b] Choose which base to use to determine the investment percentage when the strategy is in a loss.
    ○ Equity: Use the equity as the base for percentage calculation.
    ○ Initial capital: Use the initial capital as the base for percentage calculation.
 • [b]LINV% - Loss Investment Percentage:[/b] Set a percentage of the chosen investment base as the investment for a new position. 
    ○ For example, when 10% in loss, and a initial capital of $100, and the investment base is set to equity with a percentage of 50%, your investment will be 50% of $90, $45.

 • [b]PINVB - Profit Investment Base:[/b] Choose which base to use to determine the investment percentage when the strategy is in profit.
    ○ Equity: Use the equity as the base for percentage calculation.
    ○ Initial capital: Use the initial capital as the base for percentage calculation.
 • [b]PINV% - Profit Investment Percentage:[/b] Set a percentage of the chosen investment base as the investment for a new position. 
    ○ For example, when 10% in profit, and an initial capital of $100, and the investment base is set to equity with a percentage of 100%, your investment will be 100% of $110, $110.

 • [b]RISK% - Risk Percentage:[/b]
    ○ Determine how much of the calculated position investment is at risk when the stop-loss is hit. 
        - For example, 1% of $45 represents a maximum loss of $0.45.
    ○ Risk percentage works together with the stop loss and the max leverage.
 • [b]MXLVG - Maximum Leverage:[/b]
    ○ Investigate the trading rules for your trading pair and use the maximum allowed amount of leverage.
    ○ To determine the number of contracts to be bought or sold, considering the stop loss and the specified risk percentage, the maximum leverage available will constrain the amount of leverage utilized to ensure that the maximum risk threshold is not exceeded. For instance, suppose the stop loss is set at 1%, and the risk percentage is defined as 10%. Initially, the calculated leverage to be used would be 10. However, if there is a maximum leverage cap set at 5, it would constrain the calculated leverage of 10 to adhere to the maximum limit of 5.



█ [b]EXIT STOP LOSS[/b]
Determine the Stop Loss price based on your selected configuration. 
As the stop loss is an integral part of the ordered contracts calculation used in conjunction with the Risk and Max leverage, you'll always need to provide a stop loss price.  

[image]https://www.tradingview.com/x/57rpSvsF/[/image]

 • [b]SLB - Stop Loss Base:[/b] Choose a stop loss mode for calculating stop loss prices.
    ○ Risk: Determines the price using the Risk parameter (RISK%) and maximum leverage (MXLVG). In this case, SLB% will not have any impact.
    ○ Price Entry + Offset: Calculates the stop loss price based on a offset percentage (SLB%) from the entry price of the position.

 • [b]SLB% - Stop Loss Base Percentage:[/b] Define an offset percentage that will be applied in the price entry + offset stop loss mode.

 • [b]SLT - Stop Loss Trailing:[/b]
    ○ Fixed: The initial stop loss will be kept and no trailing stop loss will be applied.
    ○ Trail Price: Computes the trailing stop loss price based on an offset percentage (SLT%) from the closing price of the current candle. 
        - If a better stop loss price is calculated, it will be set as the new stop loss price.
    ○ Trail Incr: Adapts the trailing stop loss price based on the offset percentage (SLT%). 
        - Each price change in favor of your position will incrementally adapt the trailing stop loss with SLT%.
 • [b]SLT% - Stop Loss Trailing Percentage:[/b] This percentage serves as an offset or increment depending on your chosen trailing mode.




█ [b]EXIT TAKE PROFIT[/b]
Determine the Take Profit price based on your selected configuration. 

[image]https://www.tradingview.com/x/44xCzWeH/[/image]

 • [b]TPB - Take Profit Base:[/b] Choose a take profit mode for calculating take profit prices.
    ○ Reward: Determines the take profit price using the Risk parameter (RISK%) and the calculated Stop Loss price and the set reward percentage (TPB%). 
        -  For example: Risk 1%, Calculated Stop loss price: $90, Entry price: $100, Reward (TPB%): 2%, will result in a take profit price on $120.
    ○ Price Entry + Offset: Calculates the take profit price based on a offset percentage (TPB%) from the entry price of the position. 
        -  For example: Entry price: $100, Offset (TPB%): 2%, will result in a take profit price on $102.

 • [b]TPB% - Take Profit Base Percentage:[/b] Define an offset percentage that will be applied in the price entry + offset take profit mode.

 • [b]TPT - Take Profit Trailing:[/b]
    ○ Fixed: The initial take profit will be kept and no trailing take profit will be applied.
    ○ Trail Price: Computes the trailing take profit price based on an offset percentage (TPT%) from the closing price of the current candle. 
        -  If an applicable take profit price is calculated, it will be set as the new take profit price.
    ○ Trail Incr: Adapts the trailing take profit price based on the offset percentage (TPT%). Each price change against your position will incrementally adapt the trailing take profit with TPT%.
 • [b]TPT% - Take Profit Trailing Percentage:[/b] This percentage serves as an offset or increment depending on your chosen trailing mode.




█ [b]STRATEGY CONDITIONS[/b]

Specify when the strategy is permitted to execute trades.

[image]https://www.tradingview.com/x/3nlcknCu/[/image]

 • [b]DATE:[/b] Enable the Date Range filter to restrict entries to a specific date range.
    ○ START: Set a start date and hour to commence trading.
    ○ END: Set an end date and hour to conclude trading within the defined range.



■ [b]VISUALS[/b]

[image]https://www.tradingview.com/x/xXQ0o5dz/[/image]

 • [b]LINE:[/b] Activate a colored dashed diagonal line to visually connect the entry and exit points of positions.
 • [b]SLTP:[/b] Enable visualization of stop loss, take profit, and break-even levels.
 • [b]PNL:[/b] Enable Break-Even and Close Lines along with a colored area in between to visualize profit and loss.

 • [b]☼: Brightness % :[/b] Adjust the opacity of the plotted trading visuals. 
 • [b]P - Profit Color :[/b] Choose the color for profit-related elements.
 • [b]L - Loss Color:[/b] Choose the color for loss-related elements.
 • [b]B - Breakeven Color :[/b] Select the color for break-even points.
 • [b]EL - Long Color:[/b] Specify the color for long positions.
 • [b]ES - Short Color:[/b] Specify the color for short positions.

 • [b]TRADE LABELING:[/b] For better analysis we've labeled all entries and exits conform with the type of order your strategy has executed, some examples: 
    ○ XL-TP-150: Exit Long - Take Profit - Position 150
    ○ XS-TP-154: Exit Short - Take Profit - Position 154
    ○ XL-SL-160: Exit Long - Stop Loss - Position 160
    ○ XS-SL-164: Exit Short - Stop Loss - Position 164



█ [b]USAGE OF CONNECTABLE INDICATORS[/b]

 ■ [b]Connectable chaining mechanism[/b]

Connectable indicators can be connected directly to the [i]signal monitor, signal filter or strategy[/i], or they can be daisy chained to each other while the last indicator in the chain connects to the signal monitor, signal filter or strategy. When using a [i]signal filter[/i] you can chain the filter to the strategy input to make your chain complete.

  [image]https://www.tradingview.com/x/vuA8KnS9/[/image]

   • [b]Direct chaining:[/b] Connect an indicator directly to the [i]signal monitor, signal filter or strategy[/i] through the provided inputs (→).
   • [b]Daisy chaining:[/b] Connect indicators using the indicator input (→). The first in a daisy chain should have a flow (⌥) set to 'Indicator only'. Subsequent indicators use 'Both' to pass the previous weight. The final indicator connects to the [i]signal monitor, signal filter, or strategy.[/i]



 ■ [b]Set up the strategy with a signal filter and an RSI indicator[/b]

  Let's connect the Strategy to a connectable [i]signal filter [/i] and a [i]connectable RSI indicator[/i]: 


  1. [b]Load all relevant indicators[/b] 
   • Load RSI / Connectable
   • Load Signal filter / Connectable
   • Load Strategy / Connectable

  2. [b]Signal Filter: Connect the RSI to the Signal Filter[/b] 
   • Open the signal filter settings
   • Choose one of the three input dropdowns (1→, 2→, 3→) and choose : RSI / Connectable: Signal Connector
   • Toggle the enable box before the connected input to enable the incoming signal

  3. [b]Signal Filter: Update the filter signals settings if needed[/b] 
   • The default settings of the filter enable EL (Enter Long), XL (Exit Long), ES (Enter Short) and XS (Exit Short).

  4. [b]Signal Filter: Update the weight threshold settings if needed[/b] 
   • All connectable indicators load by default with a score of 6 for each direction (EL, XL, ES, XS)
   • By default, weight threshold (TH) is set at 5. This allows each occurrence to score, as the default score in each connectable indicator is 1 point above the threshold. Adjust to your liking.

  5. [b]Strategy: Connect the strategy to the signal filter in the strategy settings[/b] 
   • Select the strategy input → and select the Signal filter: Signal connector

  6. [b]Strategy: Enable filter compatible directions[/b] 
   • Set the signal mode of the strategy to a compatible direction with the signal filter. 


   

[quote]
  Now that everything is connected, you'll notice green spikes in the [i]signal filter[/i] representing long signals, and red spikes indicating short signals. Trades will also appear on the chart, complemented by a performance overview. Your journey is just beginning: delve into different scoring mechanisms, merge diverse connectable indicators, and craft unique chains. Instantly test your results and discover the potential of your configurations. Dive deep and enjoy the process!
[/quote]


█ [b]BENEFITS[/b]

 • [b]Adaptable Modular Design:[/b] Arrange indicators in diverse structures via direct or daisy chaining, allowing tailored configurations to align with your analysis approach.
 • [b]Streamlined Backtesting:[/b] Simplify the iterative process of testing and adjusting combinations, facilitating a smoother exploration of potential setups.
 • [b]Intuitive Interface:[/b] Navigate TradingView with added ease. Integrate desired indicators, adjust settings, and establish alerts without delving into complex code.
 • [b]Signal Weight Precision:[/b] Leverage granular weight allocation among signals, offering a deeper layer of customization in strategy formulation.
 • [b]Advanced Signal Filtering:[/b] Define entry and exit conditions with more clarity, granting an added layer of strategy precision.
 • [b]Clear Visual Feedback:[/b] Distinct visual signals and cues enhance the readability of charts, promoting informed decision-making.
 • [b]Standardized Defaults:[/b] Indicators are equipped with universally recognized preset settings, ensuring consistency in initial setups across different types like momentum or volatility.
 • [b]Reliability:[/b]  Our indicators are meticulously developed to prevent repainting. We strictly adhere to TradingView's coding conventions, ensuring our code is both performant and clean.



█ [b]COMPATIBLE INDICATORS[/b]

  Each indicator that incorporates our open-source 'azLibConnector' library and adheres to our conventions can be effortlessly integrated and used as detailed above. 
  For clarity and recognition within the TradingView platform, we append the suffix ' / Connectable' to every compatible indicator. 



█ [b]COMMON MISTAKES AND CLARIFICATIONS[/b]

 • [b]Removing an indicator from a chain:[/b] Deleting a linked indicator and confirming the "remove study tree" alert will also remove all underlying indicators in the object tree. Before removing one, disconnect the adjacent indicators and move it to the object stack's bottom.
 • [b]Point systems:[/b] The azLibConnector provides 500 points for each direction (EL: Enter long, XL: Exit long, ES: Enter short, XS: Exit short) Remember this cap when devising a point structure.
 • [b]Flow misconfiguration:[/b] In daisy chains the first indicator should always have a flow (⌥) setting of 'indicator only' while other indicator should have a flow (⌥) setting of 'both'.
 • [b]Recalculate:[/b] While this strategy has undergone extensive testing, enabling recalculation options like 'After order is filled' or 'On every tick' may lead to unexpected behavior.
 • [b]Fill orders:[/b] The strategy is thoroughly tested, yet enabling fill order options such as 'Using bar magnifier', 'On bar close', or 'Using standard OHLC' might result in unexpected outcomes.
 • [b]Layout and abbreviations:[/b] To maintain a consistent structure, we use abbreviations for each input. While this may initially seem complex, you'll quickly become familiar with them. Each abbreviation is also explained in the inline tooltips.
 • [b]Optimized for crypto trading:[/b] While many principles are common across markets, this strategy is specifically optimized and tested for crypto trading.
 • [b]Inputs:[/b] Connecting a connectable indicator directly to the strategy delivers the raw signal without a weight threshold, meaning every signal will trigger a trade.


█ [b]A NOTE OF GRATITUDE[/b]

  Through years of exploring TradingView and Pine Script, we've drawn immense inspiration from the community's knowledge and innovation. Thank you for being a constant source of motivation and insight.



█ [b]RISK DISCLAIMER[/b]

  Azullian's content, tools, scripts, articles, and educational offerings are presented purely for educational and informational uses. Please be aware that past performance should not be considered a predictor of future results.

## Source Code

````pine
// ===LICENSE ===

// This work is licensed under a Attribution-NonCommercial-ShareAlike 4.0 International (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Azullian

// ===VERSION ===

//@version = 5

// ===DECLARATIONS ===

// @description This strategy provides simple trading features to manage and control your trades. 
strategy(title = "Strategy / Connectable [Azullian]", shorttitle = "Strategy / Connectable [Azullian]", overlay = true, pyramiding = 100, initial_capital = 1000, currency = currency.NONE, default_qty_type = strategy.percent_of_equity, default_qty_value = 100.0, commission_type = strategy.commission.percent, commission_value = 0.0, precision = 6, max_lines_count = 500, max_boxes_count = 500, max_labels_count = 500, margin_long = 1./1*1, margin_short = 1./1*1)

// ===IMPORTS ===

import azullian/azLibConnector/2 as azconnector

// ===CONSTANTS ===

// ————— Constants: Options - Signal Mode
var string SM_SWING                                 = "Swing (EL, ES)"
var string SM_LONG                                  = "Long (EL, XL)"
var string SM_SHORT                                 = "Short (ES, XS)"
var string SM_BOTH                                  = "Both (EL, XL, ES, XS)"

// ————— Constants: Options - Investment Base
var string INITIAL_CAPITAL                          = "Initial Capital"
var string EQUITY                                   = "Equity"

// ————— Constants: Options - Stop Loss Base 
var string SLM_RISK                                 = "Risk"
var string SLM_RISK_LVG                             = "Risk + Leverage"
var string SLM_PRICE_OFFSET                         = "Price Entry + Offset"

// ————— Constants: Options - Stop Loss Trailing Mode 
var string SLT_FIXED                                = "Fixed"
var string SLT_TRAIL_PRICE                          = "Trail Price"
var string SLT_TRAIL_INCR                           = "Trail Incr"

// ————— Constants: Options - Take Profit Base 
var string TPM_REWARD                               = "Reward"
var string TPM_PRICE_OFFSET                         = "Price Entry + Offset"

// ————— Constants: Options - Take Profit Trailing Mode 
var string TPT_FIXED                                = "Fixed"
var string TPT_TRAIL_PRICE                          = "Trail Price"
var string TPT_TRAIL_INCR                           = "Trail Incr"

// ————— Constants: Labels and Tips - Trade Comments
var string ID_ENTRY                                 = "E"
var string ID_EXIT                                  = "X"

var string ID_LONG                                  = "L"
var string ID_SHORT                                 = "S"

var string ID_SL                                    = "SL"
var string ID_TP                                    = "TP"

var string ID_SIG                                   = "SIG"

// ————— Constants: Labels and Tips - Signal Inputs
var string GRP_SIGNAL_INPUTS                        = "SIGNAL INPUTS"
var string LBL_CONNECTOR_SOURCE                     = "→"
var string TIP_SIGNAL_INPUTS                        = "→: Connector. Important! Connect here with the latest Connector from your Indicator Connector Chain to start receiving Signals."

var string LBL_SIGNAL_MODE                          = "SM"
var string TIP_SIGNAL_MODE                          = "SM: Signal Mode. Define allowed position directions and which signal weights from the signal are used in the strategy. Swing (EL, ES) / Long (EL, XL) / Short (ES, XS) / Both (EL, XL, ES, XS)."

// ————— Constants: Defaults - Signal Inputs
var bool CONNECTOR_ENABLED_DEFAULT                  = false

var string SIGNAL_MODE_DEFAULT                      = SM_LONG

// ————— Constants: Labels and Tips - Position Investment
var string GRP_INVEST                               = "POSITION INVESTMENT"
var string LBL_INVEST_LOSS_BASE                     = "LINVB"
var string LBL_INVEST_LOSS_PERC                     = "LINV%"
var string TIP_INVEST_LOSS                          = "Max Position Investment when strategy is In Loss. LINVB: Investment Base. / LINV%: % of Investment Base for new trade."

var string LBL_INVEST_PROFIT_BASE                   = "PINVB"
var string LBL_INVEST_PROFIT_PERC                   = "PINV%"
var string TIP_INVEST_PROFIT                        = "Max Position Investment when strategy is In Profit. PINVB: Investment Base / PINV%: % of Investment Base for new trade."

var string LBL_INVEST_RISK_PERC                     = "RISK%"
var string LBL_INVEST_LEVERAGE                      = "MXLVG"
var string TIP_INVEST_RISK                          = "RISK%: Define how much % of the calculated position investment is at risk when the stop loss price is hit. / MXLVG: Max leverage the strategy is allowed to use with given StopLoss and Risk%. Use 1 in case of Spot, or in case of Futures look it up in your exchange's trading rules for the selected trading pair."

// ————— Constants: Defaults - Position Investment
var string INVEST_LOSS_BASE_DEFAULT                 = EQUITY
var float INVEST_LOSS_PERC_DEFAULT                  = 100.0
var float INVEST_LOSS_PERC_MIN                      = 0.1
var float INVEST_LOSS_PERC_MAX                      = 100.0
var float INVEST_LOSS_PERC_STEP                     = 0.1

var string INVEST_PROFIT_BASE_DEFAULT               = EQUITY
var float INVEST_PROFIT_PERC_DEFAULT                = 100.0
var float INVEST_PROFIT_PERC_MIN                    = 0.1
var float INVEST_PROFIT_PERC_MAX                    = 100.0
var float INVEST_PROFIT_PERC_STEP                   = 0.1

var float INVEST_RISK_PERC_DEFAULT                  = 100.0
var float INVEST_RISK_PERC_MIN                      = 0.01
var float INVEST_RISK_PERC_MAX                      = 100.0
var float INVEST_RISK_PERC_STEP                     = 0.1

var int INVEST_LEVERAGE_DEFAULT                     = 1
var int INVEST_LEVERAGE_MIN                         = 1
var int INVEST_LEVERAGE_MAX                         = 500
var int INVEST_LEVERAGE_STEP                        = 1

// ————— Constants: Labels and Tips - Exit Stop Loss Settings
var string GRP_SL                                   = "EXIT STOP LOSS"
var string LBL_SL_BASE                              = "SLB"
var string LBL_SL_PERC                              = "SLB%"
var string TIP_SL                                   = "SLB: Stop Loss Base / SLB%: Stop Loss Base Percentage. Note: Check documentation for further explanation of the stoploss settings."

var string LBL_SLT_MODE                             = "SLT"
var string LBL_SLT_PERC                             = "SLT%"
var string TIP_SLT                                  = "SLT: Stop Loss Long Trailing / SLT%: Stop Loss Long Trailing Percentage. Note: Check documentation for further explanation of the trailing stoploss settings."

// ————— Constants: Defaults - Exit Stop Loss Settings
var string SL_BASE_DEFAULT                          = SLM_PRICE_OFFSET
var float SL_PERC_DEFAULT                           = 100.0
var float SL_PERC_MIN                               = 0.0
var float SL_PERC_MAX                               = 100.0
var float SL_PERC_STEP                              = 0.1

var string SLT_MODE_DEFAULT                         = SLT_FIXED
var float SLT_PERC_DEFAULT                          = 1.0
var float SLT_PERC_MIN                              = 0.0
var float SLT_PERC_MAX                              = 100.0
var float SLT_PERC_STEP                             = 0.1

// ————— Constants: Labels and Tips - Exit Take Profit Settings
var string GRP_TP                                   = "EXIT TAKE PROFIT"
var string LBL_TP_BASE                              = "TPB"
var string LBL_TP_PERC                              = "TPB%"
var string TIP_TP                                   = "TPB: Take Profit Base / TPB%: Take Profit Base Percentage. Note: Check documentation for further explanation of the take profit settings."

var string LBL_TPT_MODE                             = "TPT"
var string LBL_TPT_PERC                             = "TPT%"
var string TIP_TPT                                  = "TPT: Take Profit Trailing / TPT%: Take Profit Trailing Percentage. Note: Check documentation for further explanation of the trailing take profit settings."

// ————— Constants: Defaults - Exit Take Profit Settings
var string TP_BASE_DEFAULT                          = TPM_PRICE_OFFSET
var float TP_PERC_DEFAULT                           = 100.0
var float TP_PERC_MIN                               = 0.0
var float TP_PERC_MAX                               = 10000.0
var float TP_PERC_STEP                              = 0.1

var string TPT_MODE_DEFAULT                         = TPT_FIXED
var float TPT_PERC_DEFAULT                          = 1.0
var float TPT_PERC_MIN                              = 0.0
var float TPT_PERC_MAX                              = 100.0
var float TPT_PERC_STEP                             = 0.1

// ————— Constants: Labels and Tips - Strategy Conditions
var string GRP_CONDITIONS                           = "STRATEGY CONDITIONS"
var string LBL_CONDITIONS_DATE_ENABLED              = "DATE"
var string LBL_CONDITIONS_DATE_START                = "START"
var string LBL_CONDITIONS_DATE_END                  = "END"
var string TIP_CONDITIONS_DATE                      = "Enable Date Range filter. If enabled, this strategy condition allows only entries within the specified date range."

// ————— Constants: Defaults - Strategy Conditions
var bool CONDITIONS_DATE_ENABLED_DEFAULT            = false
var string CONDITIONS_DATE_START_DEFAULT            = "01 Jan 2023 00:00 +0000"
var string CONDITIONS_DATE_END_DEFAULT              = "31 Dec 2024 00:00 +0000"

// ————— Constants: Labels and Tips - Visuals
var string GRP_VISUALS                              = "VISUALS"
var string LBL_VISUALS_BRIGHTNESS                   = "☼"
var string LBL_VISUALS_COLOR_P                      = "P"
var string LBL_VISUALS_COLOR_L                      = "L"
var string LBL_VISUALS_COLOR_B                      = "B"
var string LBL_VISUALS_COLOR_EL                     = "EL"
var string LBL_VISUALS_COLOR_ES                     = "ES"
var string TIP_VISUALS_COLOR                        = "☼: Brightness % / P: Profit Color / L: Loss Color / B: Break-Even Color / EL: Long Color / ES: Short Color"

var string LBL_VISUALS_DIR_ENABLED                  = "LINE"
var string TIP_VISUALS_DIR                          = "Enables a profit/loss colored line between the Entry and Exit prices of a trade."

var string LBL_VISUALS_SLTP_ENABLED                 = "SLTP"
var string TIP_VISUALS_SLTP                         = "Enables the Break-Even and (T)SL(T)TP lines and a loss colored area for (trailing) Stop Loss in between and a profit colored area for (trailing) Take Profit in between."

var string LBL_VISUALS_PNL_ENABLED                  = "PNL"
var string TIP_VISUALS_PNL                          = "Enables the Break-Even and Close Lines and a profit/loss colored area in between to show Profit and Loss."

// ————— Constants: Defaults - Visuals
var int VISUALS_BRIGHTNESS_DEFAULT                  = 100
var int VISUALS_BRIGHTNESS_MIN                      = 0
var int VISUALS_BRIGHTNESS_MAX                      = 100
var int VISUALS_BRIGHTNESS_STEP                     = 10
var color VISUALS_COLOR_P_DEFAULT                   = color.green
var color VISUALS_COLOR_L_DEFAULT                   = color.red
var color VISUALS_COLOR_B_DEFAULT                   = color.gray
var color VISUALS_COLOR_EL_DEFAULT                  = color.blue
var color VISUALS_COLOR_ES_DEFAULT                  = color.red

var bool VISUALS_DIR_ENABLED_DEFAULT                = true
var bool VISUALS_SLTP_ENABLED_DEFAULT               = false
var bool VISUALS_PNL_ENABLED_DEFAULT                = false

// ————— Constants: Labels - Plots
var string LBL_PLOTS_CONNECTOR                      = "Signal connector"

var string LBL_PLOTS_BE1                            = "Break-Even"
var string LBL_PLOTS_BE2                            = "Break-Even"
var string LBL_PLOTS_BE3                            = "Break-Even"

var string LBL_PLOTS_TSL1                           = "Stop Loss"
var string LBL_PLOTS_TSL2                           = "Stop Loss"
var string LBL_PLOTS_TSL3                           = "Stop Loss"

var string LBL_PLOTS_TTP1                           = "Take Profit"
var string LBL_PLOTS_TTP2                           = "Take Profit"
var string LBL_PLOTS_TTP3                           = "Take Profit"

var string LBL_PLOTS_PX1                            = "Profit and Loss"
var string LBL_PLOTS_PX2                            = "Profit and Loss"
var string LBL_PLOTS_PX3                            = "Profit and Loss"

var string LBL_FILLS_SL1                            = "SL1"
var string LBL_FILLS_SL2                            = "SL2"
var string LBL_FILLS_SL3                            = "SL3"

var string LBL_FILLS_TP1                            = "TP1"
var string LBL_FILLS_TP2                            = "TP2"
var string LBL_FILLS_TP3                            = "TP3"

var string LBL_FILLS_PNL1                           = "PNL1"
var string LBL_FILLS_PNL2                           = "PNL2"
var string LBL_FILLS_PNL3                           = "PNL3"

// ===INPUTS ===

// ————— Inputs: Signal Input Settings
float i_connector = input.source(title = LBL_CONNECTOR_SOURCE, defval = close, inline = LBL_CONNECTOR_SOURCE, group = GRP_SIGNAL_INPUTS, tooltip = TIP_SIGNAL_INPUTS)

var string i_signalMode = input.string(title = LBL_SIGNAL_MODE, defval = SIGNAL_MODE_DEFAULT, options = [SM_SWING, SM_LONG, SM_SHORT, SM_BOTH], inline = LBL_SIGNAL_MODE, group = GRP_SIGNAL_INPUTS, tooltip = TIP_SIGNAL_MODE)

// ————— Inputs: Position Investment
var string i_investInLossBase = input.string(title = LBL_INVEST_LOSS_BASE, defval = INVEST_LOSS_BASE_DEFAULT, options = [INITIAL_CAPITAL,EQUITY], inline = LBL_INVEST_LOSS_BASE, group = GRP_INVEST)
var float i_investInLossPerc = input.float(title = LBL_INVEST_LOSS_PERC, defval = INVEST_LOSS_PERC_DEFAULT, minval = INVEST_LOSS_PERC_MIN, maxval = INVEST_LOSS_PERC_MAX, step = INVEST_LOSS_PERC_STEP, inline = LBL_INVEST_LOSS_BASE, group = GRP_INVEST, tooltip = TIP_INVEST_LOSS) * 0.01

var string i_investInProfitBase = input.string(title = LBL_INVEST_PROFIT_BASE, defval = INVEST_PROFIT_BASE_DEFAULT, options = [INITIAL_CAPITAL,EQUITY], inline = LBL_INVEST_PROFIT_BASE, group = GRP_INVEST)
var float i_investInProfitPerc = input.float(title = LBL_INVEST_PROFIT_PERC, defval = INVEST_PROFIT_PERC_DEFAULT, minval = INVEST_PROFIT_PERC_MIN, maxval = INVEST_PROFIT_PERC_MAX, step = INVEST_PROFIT_PERC_STEP, inline = LBL_INVEST_PROFIT_BASE, group = GRP_INVEST, tooltip = TIP_INVEST_PROFIT) * 0.01

var float i_riskPerc = input.float(title = LBL_INVEST_RISK_PERC, defval = INVEST_RISK_PERC_DEFAULT, minval = INVEST_RISK_PERC_MIN, maxval = INVEST_RISK_PERC_MAX, step = INVEST_RISK_PERC_STEP, inline = LBL_INVEST_RISK_PERC, group = GRP_INVEST) * 0.01
var int i_leverage = input.int(title = LBL_INVEST_LEVERAGE, defval = INVEST_LEVERAGE_DEFAULT, minval = INVEST_LEVERAGE_MIN, maxval = INVEST_LEVERAGE_MAX, step = INVEST_LEVERAGE_STEP, inline = LBL_INVEST_RISK_PERC, group = GRP_INVEST, tooltip = TIP_INVEST_RISK)

// ————— Inputs: Stop Loss Settings
var string i_slBase = input.string(title = LBL_SL_BASE, defval = SL_BASE_DEFAULT, options = [SLM_RISK, SLM_PRICE_OFFSET], inline = LBL_SL_BASE, group = GRP_SL)
var float i_slPerc = input.float(title = LBL_SL_PERC, defval = SL_PERC_DEFAULT, minval = SL_PERC_MIN, maxval = SL_PERC_MAX, step = SL_PERC_STEP, inline = LBL_SL_BASE, group = GRP_SL, tooltip = TIP_SL) * 0.01

var string i_slTrailMode = input.string(title = LBL_SLT_MODE, defval = SLT_MODE_DEFAULT, options = [SLT_FIXED, SLT_TRAIL_PRICE, SLT_TRAIL_INCR], inline = LBL_SLT_MODE, group = GRP_SL)
var float i_slTrailPerc = input.float(title = LBL_SLT_PERC, defval = SLT_PERC_DEFAULT, minval = SLT_PERC_MIN, maxval = SLT_PERC_MAX, step = SLT_PERC_STEP, inline = LBL_SLT_MODE, group = GRP_SL, tooltip = TIP_SLT) * 0.01

// ————— Inputs: Take Profit Settings
var string i_tpBase = input.string(title = LBL_TP_BASE, defval = TP_BASE_DEFAULT, options = [TPM_REWARD, TPM_PRICE_OFFSET], inline = LBL_TP_BASE, group = GRP_TP)
var float i_tpPerc = input.float(title = LBL_TP_PERC, defval = TP_PERC_DEFAULT, minval = TP_PERC_MIN, maxval = TP_PERC_MAX, step = TP_PERC_STEP, inline = LBL_TP_BASE, group = GRP_TP, tooltip = TIP_TP) * 0.01

var string i_tpTrailMode = input.string(title = LBL_TPT_MODE, defval = TPT_MODE_DEFAULT, options = [TPT_FIXED, TPT_TRAIL_PRICE, TPT_TRAIL_INCR], inline = LBL_TPT_MODE, group = GRP_TP)
var float i_tpTrailPerc = input.float(title = LBL_TPT_PERC, defval = TPT_PERC_DEFAULT, minval = TPT_PERC_MIN, maxval = TPT_PERC_MAX, step = TPT_PERC_STEP, inline = LBL_TPT_MODE, group = GRP_TP, tooltip = TIP_TPT) * 0.01

// ————— Inputs: Strategy Conditions
var bool i_conditionsDateEnabled = input.bool(title = LBL_CONDITIONS_DATE_ENABLED, defval = CONDITIONS_DATE_ENABLED_DEFAULT, group = GRP_CONDITIONS, tooltip = TIP_CONDITIONS_DATE)
var int i_conditionsDateStart = input.time(title = LBL_CONDITIONS_DATE_START, defval = timestamp(CONDITIONS_DATE_START_DEFAULT), group = GRP_CONDITIONS)
var int i_conditionsDateEnd = input.time(title = LBL_CONDITIONS_DATE_END, defval = timestamp(CONDITIONS_DATE_END_DEFAULT), group = GRP_CONDITIONS)

// ————— Inputs: Visuals
var bool i_plotDirEnabled = input.bool(title = LBL_VISUALS_DIR_ENABLED, defval = VISUALS_DIR_ENABLED_DEFAULT, inline = LBL_VISUALS_DIR_ENABLED, group = GRP_VISUALS, tooltip = TIP_VISUALS_DIR)
var bool i_plotSltpEnabled = input.bool(title = LBL_VISUALS_SLTP_ENABLED, defval = VISUALS_SLTP_ENABLED_DEFAULT, inline = LBL_VISUALS_SLTP_ENABLED, group = GRP_VISUALS, tooltip = TIP_VISUALS_SLTP)
var bool i_plotPnlEnabled = input.bool(title = LBL_VISUALS_PNL_ENABLED, defval = VISUALS_PNL_ENABLED_DEFAULT, inline = LBL_VISUALS_PNL_ENABLED, group = GRP_VISUALS, tooltip = TIP_VISUALS_PNL)

var float i_plotBrightness = input.int(title = LBL_VISUALS_BRIGHTNESS, defval = VISUALS_BRIGHTNESS_DEFAULT, minval = VISUALS_BRIGHTNESS_MIN, maxval = VISUALS_BRIGHTNESS_MAX, step = VISUALS_BRIGHTNESS_STEP, inline = LBL_VISUALS_BRIGHTNESS, group = GRP_VISUALS) * 0.01
var color i_plotColorP = input.color(title = LBL_VISUALS_COLOR_P, defval = VISUALS_COLOR_P_DEFAULT, inline = LBL_VISUALS_BRIGHTNESS, group = GRP_VISUALS)
var color i_plotColorL = input.color(title = LBL_VISUALS_COLOR_L, defval = VISUALS_COLOR_L_DEFAULT, inline = LBL_VISUALS_BRIGHTNESS, group = GRP_VISUALS)
var color i_plotColorB = input.color(title = LBL_VISUALS_COLOR_B, defval = VISUALS_COLOR_B_DEFAULT, inline = LBL_VISUALS_BRIGHTNESS, group = GRP_VISUALS)
var color i_plotColorEL = input.color(title = LBL_VISUALS_COLOR_EL, defval = VISUALS_COLOR_EL_DEFAULT, inline = LBL_VISUALS_BRIGHTNESS, group = GRP_VISUALS)
var color i_plotColorES = input.color(title = LBL_VISUALS_COLOR_ES, defval = VISUALS_COLOR_ES_DEFAULT, inline = LBL_VISUALS_BRIGHTNESS, group = GRP_VISUALS, tooltip = TIP_VISUALS_COLOR)

// ===FUNCTIONS ===

// ————— Function: Get Position Direction
getPositionDirection() => [strategy.position_size > 0, strategy.position_size < 0, strategy.position_size == 0]

// ————— Function: Get Strategy PnL Percentage. Ex. 0.5 = 50%
getPnLPercStrategy() => (strategy.netprofit / strategy.initial_capital) // * 100

// ————— Function: Get Position PnL Percentage. Ex. 0.5 = 50%
getPnLPercPosition(series bool isInLongPosition, series bool isInShortPosition) => isInLongPosition ? (close - strategy.position_avg_price) / strategy.position_avg_price : isInShortPosition ? (strategy.position_avg_price - close) / strategy.position_avg_price : 0

// ————— Function: Check if date is in range
getIsDateInRange(simple bool enabled, simple int start, simple int end, series int timeCurrent) => not enabled or (timeCurrent >= start and timeCurrent <= end)

// ————— Function: Check strategy condition for date
getIsConditionDateValid() => getIsDateInRange(i_conditionsDateEnabled, i_conditionsDateStart, i_conditionsDateEnd, time)

// ————— Function: Get signal weights from connector
getSignalWeights() => azconnector.extract(i_connector)

// ————— Function: Get allowed exits based on settings and signal weights
getExitsAllowed(series float pnlPercOpenPosition, series float signalEL, series float signalXL, series float signalES, series float signalXS) =>
    bool isXLAllowed = ((i_signalMode == SM_BOTH or i_signalMode == SM_LONG) and signalXL > 0) or ((i_signalMode == SM_SWING or i_signalMode == SM_BOTH) and signalES > 0)    
    bool isXSAllowed = ((i_signalMode == SM_BOTH or i_signalMode == SM_SHORT) and signalXS > 0) or ((i_signalMode == SM_SWING or i_signalMode == SM_BOTH) and signalEL > 0)
    [isXLAllowed, isXSAllowed]

// ————— Function: Get allowed entries based on settings and signal weights
getEntriesAllowed(series bool isEntryAllowed, series float signalEL, series float signalES) => 
    bool isELAllowed = isEntryAllowed and i_signalMode != SM_SHORT and signalEL > 0
    bool isESAllowed = isEntryAllowed and i_signalMode != SM_LONG and signalES > 0
    [isELAllowed, isESAllowed]

// ————— Function: Get Position Investment for Long or Short based on the Position Investment settings.
getInvestmentPosition(series bool isEL, series bool isES) =>
    float strategyPnLPerc = getPnLPercStrategy()
    string investBase = strategyPnLPerc > 0 ? i_investInProfitBase : i_investInLossBase
    float investPerc = strategyPnLPerc > 0 ? i_investInProfitPerc : i_investInLossPerc
    float investBaseValue = investBase == INITIAL_CAPITAL ? strategy.initial_capital : strategy.openprofit <= 0 ? strategy.equity : strategy.equity - strategy.openprofit
    float result = investBaseValue * investPerc

// ————— Function: Get Stop Loss Price by Risk
getPriceStopLossByRisk(series bool isLong, series float priceEntry) => float result = isLong ? priceEntry * (1 - i_riskPerc) : priceEntry * (1 + i_riskPerc)

// ————— Function: Get Stop Loss Price by Risk and max Leverage
getPriceStopLossByRiskAndLvg(series bool isLong, series float priceEntry) => float result = isLong ? priceEntry * (1 - (i_riskPerc / i_leverage)) : priceEntry * (1 + (i_riskPerc / i_leverage))

// ————— Function: Get Stop Loss Price by fixed percentage Offset on Price
getPriceStopLossByPrice(series bool isLong, series float priceEntry, simple float slPerc) => float result = isLong ? priceEntry * (1 - math.abs(slPerc)) : priceEntry * (1 + math.abs(slPerc))

// ————— Function: Get Stop Loss Price
getPriceStopLoss(series bool isLong, series bool isTrailing, series float priceEntry) =>
    float result = switch i_slBase
        SLM_RISK => getPriceStopLossByRisk(isLong, priceEntry)
        SLM_RISK_LVG => getPriceStopLossByRiskAndLvg(isLong, priceEntry)
        SLM_PRICE_OFFSET => getPriceStopLossByPrice(isLong, priceEntry, i_slPerc)

// ————— Function: Get Trailing Stop Loss Price
getPriceTrailingStopLoss(series bool isLong, series float priceSL, series float priceTSL) =>
    float result = na(priceTSL) ? priceSL : priceTSL
    float priceTSLNew = result

    if (i_slTrailMode == SLT_TRAIL_PRICE)
        priceTSLNew := isLong ? close * (1 - i_slTrailPerc) : close * (1 + i_slTrailPerc)
    else if (i_slTrailMode == SLT_TRAIL_INCR)
        priceTSLNew := isLong and close > open ? result * (1 + i_slTrailPerc) : not isLong and close < open ? result * (1 - i_slTrailPerc) : result
    
    if (isLong and priceTSLNew > result) or (not isLong and priceTSLNew < result)
        if (i_slTrailMode == SLT_FIXED or i_slTrailMode == SLT_TRAIL_PRICE or i_slTrailMode == SLT_TRAIL_INCR)
            result := priceTSLNew

    result 

// ————— Function: Get Take Profit Price by Reward
getPriceTakeProfitByReward(series bool isLong, series float priceEntry, simple float tpPerc, series float priceSL) => float result = isLong ? priceEntry * (1 + (((priceEntry - priceSL) / priceEntry) * (tpPerc / i_riskPerc))) : priceEntry * (1 - ((math.abs(priceEntry - priceSL) / priceEntry) * (tpPerc / i_riskPerc)))

// ————— Function: Get Take Profit Price by fixed percentage Offset on Entry Price
getPriceTakeProfitByPrice(series bool isLong, series float priceEntry, simple float tpPerc) => isLong ? priceEntry * (1 + math.abs(tpPerc)) : priceEntry * (1 - math.abs(tpPerc))

// ————— Function: Get Take Profit Price Long
getPriceTakeProfit(series bool isLong, series bool isTrailing, series float priceEntry, series float priceSL) =>
    float result = switch i_tpBase
        TPM_REWARD => getPriceTakeProfitByReward(isLong, priceEntry, i_tpPerc, priceSL)
        TPM_PRICE_OFFSET => getPriceTakeProfitByPrice(isLong, priceEntry, i_tpPerc)

// ————— Function: Get Trailing Take Profit Price
getPriceTrailingTakeProfit(series bool isLong, series float priceTP, series float priceTTP, series float priceSL) =>
    float result = na(priceTTP) ? priceTP : priceTTP
    float priceTTPNew = result

    if (i_tpTrailMode == TPT_TRAIL_PRICE)
        priceTTPNew := isLong ? close * (1 + i_tpTrailPerc) : close * (1 - i_tpTrailPerc)
    else if (i_tpTrailMode == TPT_TRAIL_INCR)
        priceTTPNew := isLong and close < open ? result * (1 - i_tpTrailPerc) : not isLong and close > open ? result * (1 + i_tpTrailPerc) : result

    if (isLong and priceTTPNew < result) or (not isLong and priceTTPNew > result)
        if (i_tpTrailMode == TPT_FIXED or i_tpTrailMode == TPT_TRAIL_PRICE or i_tpTrailMode == TPT_TRAIL_INCR)
            result := priceTTPNew

    result

// ————— Function: Calculate the number of contracts based on a given investment, risk percentage, entry price and stoploss price 
getOrderQuantity(series float investment, series float priceEntry, series float priceSL, series bool isLong) =>
    float riskPerContract = math.abs(priceEntry - priceSL) // 0.1 = 10-9.9
    float riskAmount = investment * i_riskPerc // 3000 = 100000 * 0.03
    float riskQty = (riskAmount / riskPerContract) // 30000 = 3000 / 0.1  
    float notionalValue = investment * i_leverage // 1000000 = 100000 * 10
    float maxQty = notionalValue / priceEntry // 100000 = 1000000 / 10    
    float result = math.min(riskQty, maxQty) // 30000 = min(30000, 100000)  

// ————— Function: Construct entry comment
getEntryComment(series string action, series string direction, series string id, series int pos) => string result = action + direction + "-" + id + "-" + str.tostring(pos)

// ————— Function: Construct exit comment
getExitComment(series string action, series string direction, series string id, series int pos) => string result = action + direction + "-" + id + "-" + str.tostring(pos)

// ————— Function: In order to plot lines like Break-Even, SL, TP etc with 'plots' and let them break for each position, we need seperate plots.
getNextPlotSwitch(series int ps) => int result = ps + 1 <= 3 ? ps + 1 : 1

// ————— Function: Apply brightness settings on color
applyBrightness(simple color _color, simple float _bright) => color result = color.new(_color, 100 - 100 * _bright * i_plotBrightness)

// ===CALCULATIONS ===

// ————— Calculations: Initialize variables once
var float investmentPosition = 0.0
var float priceEntry = na
var float priceExit = na
var float priceSL = na
var float priceTP = na
var float priceTSL = na
var float priceTTP = na
var float priceBE = na
var float qtyEntry = na 
var float plotBE1 = na
var float plotBE2 = na
var float plotBE3 = na
var float plotTSL1 = na
var float plotTSL2 = na
var float plotTSL3 = na
var float plotTTP1 = na
var float plotTTP2 = na
var float plotTTP3 = na
var float plotExit1 = na
var float plotExit2 = na
var float plotExit3 = na
var int plotSwitch = 1
var line tradeLine = na 
var int positionNumber = 0

// ————— Calculations: Initialize variables every script run
bool isClosePending1 = false
bool isClosePending2 = false
bool isClosePending3 = false
bool isPositionNew = false
bool isLastPositionClosed = false

// ————— Calculations: Strategy Entry Conditions
bool isEntryAllowed = barstate.isconfirmed and getIsConditionDateValid()

// ————— Calculations: Current situation
[isInLongPosition, isInShortPosition, isInFlatPosition] = getPositionDirection()
isLastPositionClosed := isInFlatPosition and not isInFlatPosition[1] and strategy.closedtrades != strategy.closedtrades[1]
pnlPercOpenPosition = getPnLPercPosition(isInLongPosition, isInShortPosition)

// ————— Calculations: Extract EL, XL, ES and XS signal values from each connector
[signalEL, signalXL, signalES, signalXS] = getSignalWeights()

// ————— Calculations: Get allowed entries and exits based on settings and signal weights
[isELAllowed, isESAllowed] = getEntriesAllowed(isEntryAllowed, signalEL, signalES)
[isXLAllowed, isXSAllowed] = getExitsAllowed(pnlPercOpenPosition, signalEL, signalXL, signalES, signalXS)

// ————— Calculations: Long/Short Entry/Exit decision based on signal weight values, enabled settings and current trading position
bool isXS = isXSAllowed and isInShortPosition
bool isEL = isELAllowed and not isInLongPosition and (not isInShortPosition or (isInShortPosition and isXS))
bool isXL = isXLAllowed and isInLongPosition
bool isES = isESAllowed and not isInShortPosition and (not isInLongPosition or (isInLongPosition and isXL)) and not isEL

// ————— Calculations: Get if a new position is allowed
bool isNewPositionAllowed = isInFlatPosition or isXS or isXL

// ————— Calculations: Calculate Position Investment
investmentPosition := not isNewPositionAllowed ? investmentPosition : getInvestmentPosition(isEL, isES)

// ————— Calculations: Calculate Initial Entry, SL and TP Prices
priceEntry := not isNewPositionAllowed ? priceEntry : isEL or isES ? close : na
priceSL := isNewPositionAllowed ? isEL ? getPriceStopLoss(true, false, priceEntry) : isES ? getPriceStopLoss(false, false, priceEntry) : na : priceSL
priceTP := isNewPositionAllowed ? isEL ? getPriceTakeProfit(true, false, priceEntry, priceSL) : isES ? getPriceTakeProfit(false, false, priceEntry, priceSL) : na : priceTP

// ————— Calculations: Calculate Initial Entry Order Qty
qtyEntry := not isNewPositionAllowed ? qtyEntry : isEL ? getOrderQuantity(investmentPosition, priceEntry, priceSL, true) : isES ? getOrderQuantity(investmentPosition, priceEntry, priceSL, false) : na

// ————— Calculations: Calculate trailing SL and TP
priceTSL := isNewPositionAllowed ? priceSL : isInLongPosition ? getPriceTrailingStopLoss(true, priceSL, priceTSL) : isInShortPosition ? getPriceTrailingStopLoss(false, priceSL, priceTSL) : priceSL
priceTTP := isNewPositionAllowed ? priceTP : isInLongPosition ? getPriceTrailingTakeProfit(true, priceTP, priceTTP, priceSL) : isInShortPosition ? getPriceTrailingTakeProfit(false, priceTP, priceTTP, priceSL) : priceTP

// ————— Calculations: Calculate break-even price
priceBE := not isInFlatPosition ? strategy.position_avg_price : na

// ————— Calculations: Calculate exit price
priceExit := isLastPositionClosed ? strategy.closedtrades.exit_price(strategy.closedtrades - 1) : not isInFlatPosition ? close : na

// ————— Calculations: Combine output L, XL, S and XS weight values to single number based on input settings
float connectorOut = azconnector.compose(signalEL, signalXL, signalES, signalXS)

// ————— Calculations: Calculate visuals (abstract triple plots to get the lines breaking properly)
if (i_plotSltpEnabled or i_plotPnlEnabled)
    plotBE1 := plotSwitch != 1 ? na : isLastPositionClosed ? plotBE1 : priceBE
    plotBE2 := plotSwitch != 2 ? na : isLastPositionClosed ? plotBE2 : priceBE
    plotBE3 := plotSwitch != 3 ? na : isLastPositionClosed ? plotBE3 : priceBE

if (i_plotPnlEnabled)
    plotExit1 := plotSwitch != 1 ? na : priceExit
    plotExit2 := plotSwitch != 2 ? na : priceExit
    plotExit3 := plotSwitch != 3 ? na : priceExit

// ===STRATEGY CALLS ===

// ————— Strategy Calls: Cancel all when in flat position
if barstate.isconfirmed and isInFlatPosition
    strategy.cancel_all()

// ————— Strategy Calls: Exit by Signal
if barstate.isconfirmed and (isXL or isXS) // TODO: Fix switching by signal    
    string idDir = isInLongPosition ? ID_LONG : ID_SHORT
    string orderComment = getExitComment(ID_EXIT, idDir, ID_SIG, positionNumber)
    strategy.cancel_all()    
    strategy.close_all(comment = orderComment)
    isClosePending1 := plotSwitch == 1
    isClosePending2 := plotSwitch == 2
    isClosePending3 := plotSwitch == 3
    isInLongPosition := false
    isInShortPosition := false
    isInFlatPosition := true
    priceExit := close

// ————— Strategy Calls: Entry by Signal
if barstate.isconfirmed and isInFlatPosition and (isEL or isES) and not na(qtyEntry) and qtyEntry > 0
    if (not isClosePending1 and not isClosePending2 and not isClosePending3) 
        strategy.cancel_all() 

    isPositionNew := true
    plotSwitch := getNextPlotSwitch(plotSwitch)
    string idEntry = ID_SIG + str.tostring(0)
    positionNumber += 1
    if (isEL)
        string orderComment = getEntryComment(ID_ENTRY, ID_LONG, idEntry, positionNumber)
        strategy.entry(idEntry, strategy.long, qty = qtyEntry, comment = orderComment)
        isInLongPosition := true
        isInFlatPosition := false        
    else
        string orderComment = getEntryComment(ID_ENTRY, ID_SHORT, idEntry, positionNumber)
        strategy.entry(idEntry, strategy.short, qty = qtyEntry, comment = orderComment)        
        isInShortPosition := true
        isInFlatPosition := false

// ————— Strategy Calls: Exit by (trailing) SL / TP
if barstate.isconfirmed and not isInFlatPosition and (not na(priceTSL) or not na(priceTTP))
    string idDir = isInLongPosition ? ID_LONG : ID_SHORT
    string orderCommentSL = getExitComment(ID_EXIT, idDir, ID_SL, positionNumber)
    string orderCommentTP = getExitComment(ID_EXIT, idDir, ID_TP, positionNumber)
    strategy.exit(id = ID_EXIT + idDir + ID_SL + ID_TP, stop = priceTSL, limit = priceTTP, comment_loss = orderCommentSL, comment_profit = orderCommentTP)

// ===VISUALS ===

// ————— Visuals: Plot Trade Line
if barstate.isconfirmed and i_plotDirEnabled
    if isLastPositionClosed or isClosePending1 or isClosePending2 or isClosePending3
        line.set_xy2(id = tradeLine, x = isClosePending1 or isClosePending2 or isClosePending3 ? bar_index + 1 : bar_index, y = priceExit)
    if isPositionNew
        tradeLine := line.new(x1 = bar_index + 1, y1 = priceEntry, x2 = bar_index + 1, y2 = close, xloc = xloc.bar_index, extend = extend.none, color = isInLongPosition ? applyBrightness(i_plotColorEL, 1) : applyBrightness(i_plotColorES, 1), style = line.style_dashed, width = 1)
    else if not isInFlatPosition and strategy.closedtrades == strategy.closedtrades[1]
        line.set_xy2(id = tradeLine, x = bar_index, y = priceExit)

// ————— Visuals: Plot Break-Even Line
plotIdPriceBE1 = plot(series = isClosePending1[1] ? plotBE1[1] : plotBE1, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_BE1, color = applyBrightness(i_plotColorB, 1))
plotIdPriceBE2 = plot(series = isClosePending2[1] ? plotBE2[1] : plotBE2, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_BE2, color = applyBrightness(i_plotColorB, 1))
plotIdPriceBE3 = plot(series = isClosePending3[1] ? plotBE3[1] : plotBE3, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_BE3, color = applyBrightness(i_plotColorB, 1))

// ————— Visuals: Plot (trailing) Stop Loss Line and area 
plotTSL1 := not i_plotSltpEnabled or plotSwitch != 1 ? na : priceTSL
plotIdPriceTSL1 = plot(series = isClosePending1 ? plotTSL1[1] : plotTSL1, offset = 1, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_TSL1, color = applyBrightness(i_plotColorL, 1))
fill(plot1 = plotIdPriceBE1, plot2 = plotIdPriceTSL1, color = applyBrightness(i_plotColorL, 0.15), title = LBL_FILLS_SL1)

plotTSL2 := not i_plotSltpEnabled or plotSwitch != 2 ? na : priceTSL
plotIdPriceTSL2 = plot(series = isClosePending2 ? plotTSL2[1] : plotTSL2, offset = 1, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_TSL2, color = applyBrightness(i_plotColorL, 1))
fill(plot1 = plotIdPriceBE2, plot2 = plotIdPriceTSL2, color = applyBrightness(i_plotColorL, 0.15), title = LBL_FILLS_SL2)

plotTSL3 := not i_plotSltpEnabled or plotSwitch != 3 ? na : priceTSL
plotIdPriceTSL3 = plot(series = isClosePending3 ? plotTSL3[1] : plotTSL3, offset = 1, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_TSL3, color = applyBrightness(i_plotColorL, 1))
fill(plot1 = plotIdPriceBE3, plot2 = plotIdPriceTSL3, color = applyBrightness(i_plotColorL, 0.15), title = LBL_FILLS_SL3)

// ————— Visuals: Plot (trailing) Take Profit Line and area
plotTTP1 := not i_plotSltpEnabled or plotSwitch != 1 ? na : priceTTP
plotIdPriceTTP1 = plot(series = isClosePending1 ? plotTTP1[1] : plotTTP1, offset = 1, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_TTP1, color = applyBrightness(i_plotColorP, 1))
fill(plot1 = plotIdPriceBE1, plot2 = plotIdPriceTTP1, color = applyBrightness(i_plotColorP, 0.15), title = LBL_FILLS_TP1)

plotTTP2 := not i_plotSltpEnabled or plotSwitch != 2 ? na : priceTTP
plotIdPriceTTP2 = plot(series = isClosePending2 ? plotTTP2[1] : plotTTP2, offset = 1, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_TTP2, color = applyBrightness(i_plotColorP, 1))
fill(plot1 = plotIdPriceBE2, plot2 = plotIdPriceTTP2, color = applyBrightness(i_plotColorP, 0.15), title = LBL_FILLS_TP2)

plotTTP3 := not i_plotSltpEnabled or plotSwitch != 3 ? na : priceTTP
plotIdPriceTTP3 = plot(series = isClosePending3 ? plotTTP3[1] : plotTTP3, offset = 1, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_TTP3, color = applyBrightness(i_plotColorP, 1))
fill(plot1 = plotIdPriceBE3, plot2 = plotIdPriceTTP3, color = applyBrightness(i_plotColorP, 0.15), title = LBL_FILLS_TP3)

// ————— Visuals: Plot Price Exit Line and Profit and Loss area
plotIdPriceExit1 = plot(series = isClosePending1[1] ? plotExit1[1] : plotExit1, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_PX1, color = applyBrightness(i_plotColorB, 1), display = display.none)
fill(plot1 = plotIdPriceExit1, plot2 = plotIdPriceBE1, color = applyBrightness(color.white, 0.05), title = LBL_FILLS_PNL1)

plotIdPriceExit2 = plot(series = isClosePending2[1] ? plotExit2[1] : plotExit2, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_PX2, color = applyBrightness(i_plotColorB, 1), display = display.none)
fill(plot1 = plotIdPriceExit2, plot2 = plotIdPriceBE2, color = applyBrightness(color.white, 0.05), title = LBL_FILLS_PNL2)

plotIdPriceExit3 = plot(series = isClosePending3[1] ? plotExit3[1] : plotExit3, style = plot.style_linebr, linewidth = 1, title = LBL_PLOTS_PX3, color = applyBrightness(i_plotColorB, 1), display = display.none)
fill(plot1 = plotIdPriceExit3, plot2 = plotIdPriceBE3, color = applyBrightness(color.white, 0.05), title = LBL_FILLS_PNL3)

// ————— Visuals: Plot Signal Connector (to daisy-chain for instance to a monitor or another strategy)
plot(series = connectorOut, title = LBL_PLOTS_CONNECTOR, display = display.none)

// ===ALERTS ===

// Provided in Strategy Plus only.
````
