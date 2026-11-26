# MTF Structure & Bias [BETA] | OMSF 

- url: https://www.tradingview.com/script/YHaB6Wa8-MTF-Structure-Bias-BETA-OMSF/
- type: indicator
- pine_id: PUB;35a64f07c8a145989f6574b1b3945ad4
- version: 1.0

## Description

This is a professional-grade market structure interface [b]designed for Daytraders and Swingtraders[/b]. It provides a high-clarity view of market mechanics by filtering out noise and focusing on validated structural shifts across multiple timeframes.
[b]Eliminate Emotional Decision-Making The core mission of the OMSF Framework[/b] is to solve the fundamental problem of trading: Emotion. By [b]projecting clear, rules-based logic directly onto your screen[/b], this interface removes the "guesswork" from your process.

[b]Key Functionality:[/b]
[b]Structural Interpretation: [/b]The script translates raw price action into defined market trends. It distinguishes between Uptrend, Downtrend, and Sideways ranges based on validated structural levels.
[b]Bias Derivation:[/b] A rule-based trading bias is derived by aligning higher timeframe structure with a regime filter.
[b]Calibration:[/b] Optional background colors visualize these internal decision rules. This allows for an objective check of how parameters affect the classification of market phases.

[b]Core Logic & Bias Derivation[/b]
The script follows a systematic hierarchy to determine the market state and trading bias:
[b]1. Structural Raw Bias (HTF)[/b]
The primary direction is derived from the Higher Timeframe (HTF) market phases. If the structure is in an expansion or correction phase, it is assigned a directional value:
    • Long (+1): Bullish Expansion or Bullish Correction.
    • Short (-1): Bearish Expansion or Bearish Correction.
    • Neutral (0): No clear structural phase.
[b]2. EMA Regime Filter[/b]
To ensure trend alignment, a "Regime Lock" is applied. A structural bias is only validated as an Uptrend or Downtrend if the price remains on the correct side of the EMA. If the structural bias and EMA alignment contradict each other, the market is classified as Sideways.
[b]3. Trading Bias & Risk Assessment[/b]
The final trading bias (Long/Short) is then cross-referenced with the current price range:
    • Trend Continuation: If the HTF is trending and the market is not overextended, the bias follows the trend.
    • Counter-Trend Awareness: If the HTF is "Extended ⚠️" (overheated) and the Lower Timeframe (LTF) shows a correction, the bias reflects a potential mean reversion or temporary shift.
    • Sideways Handling: In sideways markets, the bias remains neutral unless specific range conditions are met.

[b]Configuration & Visual Feedback [/b]
The settings menu includes the standard parameters from the [b]OMSF framework[/b]. To better understand their impact, it is recommended to use the Background Colors feature:
[list]
[*] Real-time Calibration: Adjust parameters like ATR thresholds or momentum filters and observe how the background colors shift.
[*] Visual Consistency: The background colors correspond directly with the status indicators on the Dashboard, providing a unified view of the current market phase.
[*]  Logical Mapping: This allows you to see exactly where the framework switches its interpretation based on your specific settings.
[/list]
For a deep dive into the underlying logic of these variables, please refer to the core library documentation: 🔗https://www.tradingview.com/script/g1122Yj2/

[b]Systematic Consistency (Educational Core)[/b]
The primary goal of this implementation is to demonstrate how a rule-based framework enables a trader to make the same decisions under the same market conditions.
[list]
[*] Objective Strategy Testing: By using fixed structural definitions, you can test strategies on a foundation that does not change based on intuition or emotion.
[*] Repeatability: Once a valid strategy is identified, the framework ensures that the entry and exit conditions remain objective and repeatable over any number of trades.
[*]   Condition-Based Execution: This approach shows that professional trading is not about predicting the future, but about reacting consistently to predefined market states.
[/list]
[b]Dashboard Logic & Layout[/b]
The dashboard acts as a real-time monitor for the Multi-Timeframe (MTF) analysis, organized into two primary data columns:
[list]
[*]Left Column (Higher Timeframe):
[*]        ◦ Market Stage: Displays the structural trend (Uptrend, Downtrend, or Sideways) derived from the HTF.
[*]        ◦ Market State: Real-time feedback on the specific OMSF phase (Expansion/Correction).
[*]        ◦ Price Range: Volatility-based assessment of the current price extension.
[*]            Right Column (Lower Timeframe & Confluence):
[*]        ◦ Trading Bias: Shows the final confluence signal. It aligns the HTF structure with the                   internal regime filter and risk parameters to provide a clear directional bias.
[*]        ◦ LTF Dynamics: Parallel monitoring of the execution timeframe's state and price range.
[/list]
[b]Visual Indicators:[/b] All colors on the dashboard are synchronized with the Visual Calibration (Background Colors). This ensures that the information on the dashboard is always reflected by the logic projected onto the chart.
[b]Visual Structure Tools[/b]
Lines and boxes are rendered using functions from the Visual Structure Tools library:
[list]
[*]Orange Box: Automatically drawn when compress.htf == true.
[*]Logic: This highlights unconfirmed, tight structures (where omsfHigh is not yet a confirmed strHigh), which often mark the starting point of impulsive breakouts.
[*]  Documentation: For a detailed breakdown of how levels and boxes are calculated, refer to 
[/list]the library documentation:
🔗https://www.tradingview.com/script/RYljd98y/

[b]I release my frameworks to the community to validate the OMSF logic against real-world volatility. This live feedback loop is essential for refining the code and ensuring the framework remains resilient and reliable across all market conditions.[/b]
Made in Germany 🇩🇪 with a focus on logic and precision.

[b]Disclaimer[/b]
For Educational Purposes Only. The information and tools provided in this script are for educational and demonstration purposes only and do not constitute financial, investment, or trading advice.
    • No Guarantees: Past performance is not indicative of future results. Trading involves significant risk, and most individual traders lose money.
    • Not a Signal Service: This script is a technical framework designed to assist in market structure analysis. It is not an automated trading system or a signal provider.
    • Risk Responsibility: The author (arnipoer) assumes no liability for any financial losses resulting from the use of this script. Always perform your own due diligence and use a demo account before risking real capital.
    • Beta Software: This is a demo/beta version. Logic and visual representations are subject to change and should be verified against your own analysis.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © arnipoer | Made in Germany 🇩🇪 ☺

//----------------------------------------------------------------------------------------- //
// EDUCATIONAL EXAMPLE: How to implement the PriceActionPubLib                               //
// This script demonstrates how to map the 19 output variables from the library into         //
// a functional MTF Dashboard and visual Chart Structure.                                   //
// Use this as a template to understand the alignment of:                                    //
// - Market Phases (expansion/correction)                                              //
// - Structural Ranges (Compression/Expansion)                                               //
// - Confluence with standard indicators (EMA Trend Alignment)                               //
// ----------------------------------------------------------------------------------------- //

//@version=6

indicator('MTF Structure & Bias [BETA] | OMSF ', shorttitle = 'UI OMSF', overlay = true)
import arnipoer/PriceActionStructure/3 as omsf //@link https://www.tradingview.com/script/g1122Yj2/
import arnipoer/VisualStructureTools/2 as vst //@link https://www.tradingview.com/script/RYljd98y/

///////////////////////////////Inputs////////////////////////////////////////////////////////
gp_multiTF = "Using function as Multi-Timeframe-Request"
htf = input.timeframe('120', title = 'Higher Timeframe', group = gp_multiTF,  inline = "1", tooltip = "The timeframe used for higher-level structure analysis.")
htf_color = input.color(color.aqua, title = '', group = gp_multiTF,  inline = "1", tooltip = "The color associated with lower-level structure analysis.")
ltf = input.timeframe('10', title = 'Lower Timeframe', group = gp_multiTF,  inline = "2", tooltip = "The timeframe used for local structure analysis.")
ltf_color = input.color(color.blue, title = '', group = gp_multiTF,  inline = "2",  tooltip = "the color assoziated with lower-level structure analysis.")


gp_funct_para = 'Function-Parameters'
period      = input.int(100, 'ATR Period', step = 1, group = gp_funct_para, inline = '1', tooltip = "The lookback period for ATR. All swing sizes are calculated relative to this volatility.")
comp_tresh  = input.float(1.5, 'Comp-Threshold', group = gp_funct_para, step = 0.05, inline = '2', tooltip = "Swings smaller than this multiplier * ATR are labeled as 'Compression' (low volatility).")
hrg_tresh   = input.float(4.0, 'Huge-Threshold', group = gp_funct_para, step = 0.05, minval = 0.05, inline = '3', tooltip = "Swings larger than this multiplier * ATR are labeled as 'Expansion' (high volatility).")
expans_tresh = input.float(1.2, 'expans-Factor', group = gp_funct_para, step = 0.05, minval = 1.05, inline = '4', tooltip = "Defines the breakout zone. Price must move this factor beyond the previous range to trigger an expansion phase.")
use_mom_filter = input.bool(true, "Use Momentumfilter", group = gp_funct_para, inline = '5', tooltip = "If enabled, compression zones are only updated if the candle body exceeds the Momentum Threshold.")
mom_tresh   = input.float(1.2, 'Mom-Threshold', step = 0.05, minval = 0, group = gp_funct_para, inline = '5', tooltip = "Minimum candle body size relative to ATR to pass the momentum filter.")

show_bgColor    = input.bool(false, "bgColor for ParaTuning", group = gp_funct_para, inline = '6', tooltip = "If enabled...")
bg_options = input.string('Market Structure', title='', options = ['Market Structure', 'Trade Bias'], group = gp_funct_para, inline = '6', display=display.none, tooltip = "Dummy Option. Just for fun...\n                          ...and out of pride...in the script.")

gp_dashboard = 'Show Dashboard'
show_dashboard = input.bool(true,title ="", group = gp_dashboard, inline = '1')
dash_positiion = input.string(position.middle_left , title='', options = [position.top_left, position.middle_left,position.bottom_left,
     position.top_center,position.bottom_center,position.top_right, position.middle_right,position.bottom_right], group = gp_dashboard, inline = '1', display=display.none, tooltip = '')
dummy = input.string('© arnipoer', title='', options = ['© arnipoer', '☺ 🇩🇪 Made in Germany'], group = gp_dashboard, inline = '2', display=display.none, tooltip = "Visualizes the interpreted market phases directly on the chart background for easier parameter tuning.\n Dummy Option. Just for fun...\n                          ...and out of pride...in the script.")
//
//
//------------------------MTF Requests-----------------------------------------------------------//
[close_htf, ema_htf] = request.security(syminfo.tickerid, htf, [close, ta.ema(close, 100)])
float close_ltf = request.security(syminfo.tickerid, ltf, close)

//
[omsf_strHighhtf, omsf_strHightime_htf, omsf_strLowhtf, omsf_strLowtime_htf, peakHigh_htf, peakLow_htf, upMove_htf, downMove_htf, omsfHigh_htf, omsfHigh_time_htf, omsfLow_htf, omsfLow_time_htf, compress_htf, standardRange_htf, hugeRange_htf, expansLong_htf, expansShort_htf, longCorr_htf, shortCorr_htf] = request.security(syminfo.tickerid, htf, omsf.get_omsf_structure(use_mom_filter, mom_tresh, close_htf , period, expans_tresh, comp_tresh, hrg_tresh))
[omsf_strHighltf, omsf_strHightime_ltf, omsf_strLowltf, omsf_strLowtime_ltf, peakHigh_ltf, peakLow_ltf, upMove_ltf, downMove_ltf, omsfHigh_ltf, omsfHigh_time_ltf, omsfLow_ltf, omsfLow_time_ltf, compress_ltf, standardRange_ltf, hugeRange_ltf, expansLong_ltf, expansShort_ltf, longCorr_ltf, shortCorr_ltf]  = request.security(syminfo.tickerid, ltf, omsf.get_omsf_structure(use_mom_filter, mom_tresh, close_ltf ,period, expans_tresh, comp_tresh, hrg_tresh))
//
//------------------------Visualize Price Levels (Floats)---------------------------------------------------------// 

show_ltf_structure = input.bool(true, 'LowerTF OMSF Structure', group = 'Visualize Market Structure')
show_htf_structure = input.bool(true, 'HigherTF OMSF Structure', group = 'Visualize Market Structure', inline = '2')
compression_warning = input.bool(true, 'non filtered compression', group = 'Visualize Market Structure', inline = '3')
show_ema = input.bool(false, "Regime EMA(100) for comparison?", group = 'Visualize Market Structure', inline = '4', tooltip = "Displays the HTF EMA used for the structural Regime Lock. Helps to visually verify why certain trends are classified as 'sideways'.")

if show_ltf_structure and timeframe.in_seconds(timeframe.period) < timeframe.in_seconds(htf)
    vst.setLine(omsf_strHighltf, omsf_strHightime_ltf, "LTF High" , "above" ,"no ext." ,3 , ltf_color)
    vst.setLine(omsf_strLowltf, omsf_strLowtime_ltf, "LTF Low" , "below" ,"no ext." ,3 , ltf_color)
if show_htf_structure 
    vst.setLine(omsf_strHighhtf, omsf_strHightime_htf, "omsf.StructHigh" , "above" ,"no ext." ,3 , color.new(htf_color,50))
    vst.setLine(omsf_strLowhtf, omsf_strLowtime_htf, "omsf.StructLow" , "below" ,"no ext." , 3, color.new(htf_color,50))
if compress_htf 
    vst.setBox(omsfHigh_htf, omsfLow_htf, omsfHigh_time_htf > omsfLow_time_htf ? omsfHigh_time_htf : omsfLow_time_htf, time,"compressive", "center", color.orange, 0, "solid", 85) 

plot(show_ema ? ema_htf : na,title='HTF EMA(100)', style = plot.style_linebr)
//-------------------------Process & Visualize Logic (Booleans)--------------------------------------------------//      
omsf_states(color timeframeColor, float strHigh, float strLow, float omsfHigh, float omsfLow, bool upMove, bool downMove, bool compress, bool standardRange, bool hugeRange, bool expansLong, bool expansShort, bool longCorr, bool shortCorr) =>
    period_atr = ta.atr(period) 
    bool overheated = expansLong and close > strLow + period_atr*hrg_tresh, bool collapsed = expansShort and close > strHigh - period_atr*hrg_tresh
    bool compressed =  upMove and (close - omsfLow) <  period_atr*comp_tresh or downMove and (omsfHigh - close) <  period_atr*comp_tresh

    string rangeSizeTxt = 'Usual', color rangeSizeColor = color.new(timeframeColor,50)
    switch 
        compressed => rangeSizeTxt := 'Compressed', rangeSizeColor := color.new(color.orange,50)
        overheated => rangeSizeTxt := 'Extended⚠️', rangeSizeColor := color.new(color.red,0)
        => ['Usual', color.new(timeframeColor, 50)]
    [omsf_state, state_color] = switch 
        expansLong => ['Expansion', color.new(color.green, 30)]
        expansShort =>  ['Expansion', color.new(color.red, 30)]
        longCorr => ['Corrective', color.new(color.green, 60)]
        shortCorr => ['Corrective', color.new(color.red,60)]

     
    [rangeSizeTxt, rangeSizeColor, omsf_state, state_color]
[rangeSizeTxt_htf, rangeSizeColor_htf, omsf_state_htf, state_color_htf] = omsf_states(htf_color, omsf_strHighhtf, omsf_strLowhtf, omsfHigh_htf, omsfLow_htf, upMove_htf, downMove_htf, compress_htf, standardRange_htf, hugeRange_htf, expansLong_htf, expansShort_htf, longCorr_htf, shortCorr_htf)
[rangeSizeTxt_ltf, rangeSizeColor_ltf, omsf_state_ltf, state_color_ltf]  = omsf_states(ltf_color, omsf_strHighltf, omsf_strLowltf, omsfHigh_ltf, omsfLow_ltf, upMove_ltf, downMove_ltf, compress_ltf, standardRange_ltf, hugeRange_ltf, expansLong_ltf, expansShort_ltf, longCorr_ltf, shortCorr_ltf)
//
//---------------Confluence: Combining Library Data with Technical Indicators------------------------------------//

[omsf_bias_htf] = switch
    expansLong_htf or longCorr_htf => [1]
    expansShort_htf or shortCorr_htf => [-1]
    => [0]

bool ema_regime_lock = omsf_bias_htf == 1 and close_htf < ema_htf or omsf_bias_htf == -1 and close_htf > ema_htf

string labeledMarketStructure_htf = 'sideways', color msColor = color.aqua

switch
    omsf_bias_htf == 1 and not ema_regime_lock => labeledMarketStructure_htf := 'upTrend', msColor := color.green
    omsf_bias_htf == -1 and not ema_regime_lock => labeledMarketStructure_htf := 'downTrend', msColor := color.red
    => labeledMarketStructure_htf := 'sideways', msColor := htf_color
        
string trading_bias = 'none', color bias_color = ltf_color
switch
    labeledMarketStructure_htf == 'upTrend'  => trading_bias := not (rangeSizeTxt_htf == 'Extended⚠️' and longCorr_ltf) ? 'long ' : 'short', 
         bias_color := not (rangeSizeTxt_htf == 'Extended⚠️' and longCorr_ltf) ? color.green : color.red
    labeledMarketStructure_htf == 'downTrend'  => trading_bias := not (rangeSizeTxt_htf == 'Extended⚠️' and shortCorr_ltf)  ? 'short ' : 'long',
         bias_color := not (rangeSizeTxt_htf == 'Extended⚠️'and shortCorr_ltf) ? color.red : color.green
    labeledMarketStructure_htf == 'sideways'  => not (hugeRange_htf) ? ltf_color : bias_color


printDashboard(string position, string textsize, int cell_width) =>
    var table t = table.new(position, 2, 5, border_color = color.silver, force_overlay = true)    
    table.cell(t, 0, 0, text = '⚠️ Demo Version', bgcolor = color.new(color.silver,70), text_color = color.new(color.white, 0), text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 0, 1, text = 'Higher TF '+htf+'\nMarketstage: '+ labeledMarketStructure_htf, width =  cell_width, bgcolor = color.new(msColor,20), text_color = color.white, text_size = textsize)// mit h1-Fibos arbeiten
    table.cell(t, 0, 2, text = omsf_state_htf, bgcolor = state_color_htf, width =  cell_width, text_color = color.white, text_size = textsize)//hier prime daten nehmen
    table.cell(t, 0, 3, text = 'price range: '+rangeSizeTxt_htf, bgcolor = rangeSizeColor_htf, text_color = color.white, text_size = textsize)// hier prime nehmen
    //--------------------------------------------------------------------------------------------------------------------------// 
    table.cell(t, 1, 0, text = '', bgcolor = color.new(color.silver,70), text_color = color.new(color.white, 50), text_size = size.tiny, text_halign = text.align_left)
    table.cell(t, 1, 1, text = 'Lower TF '+ltf + '\nHigherTF Bias: ' + trading_bias, width =  cell_width, bgcolor =  trading_bias == 'none' ? color.new(ltf_color,70) :  color.new(bias_color, 10) , text_color = color.white, text_size = textsize)
    table.cell(t, 1, 2, text = omsf_state_ltf, bgcolor = state_color_ltf, width =  cell_width, text_color = color.white, text_size = textsize)
    table.cell(t, 1, 3, text = 'price range: '+rangeSizeTxt_ltf, width =  cell_width, bgcolor = rangeSizeColor_ltf, text_color = color.white, text_size = textsize)
    table.merge_cells(t, 0, 4, 1, 4)
    table.cell(t, 0, 4, text = "© 2026 ap | Made in Germany 🇩🇪 ☺", bgcolor = color.new(color.silver, 70), text_color = color.new(color.white, 50), text_size = size.tiny, text_halign = text.align_right)

if show_dashboard 
    printDashboard(dash_positiion, size.small, 10)

bgcolor(show_bgColor ? bg_options == 'Trade Bias' ? color.new(bias_color, 80) : color.new(msColor, 80) : na, title = "Background")
````
