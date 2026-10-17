# Smart Money Setup 08 [TradingFinder] Binary Options Gold Scalper

- url: https://www.tradingview.com/script/wx2LInq3-Smart-Money-Setup-08-TradingFinder-Binary-Options-Gold-Scalper/
- type: indicator
- pine_id: PUB;3ccbc3fca8f946c485a2cc5a82d8dd91
- version: 1.0

## Description

🔵[b]Introduction[/b]

In the Smart Money methodology, the market is understood as a structure driven by liquidity flow. This structure forms through the movement of large orders, the accumulation of liquidity, and the reactions that occur around key price zones. The logic of Smart Money is based on the idea that price movement is not random and usually evolves with the intention of collecting liquidity and creating price inefficiencies known as imbalances. 

Within this framework, several important stages including the liquidity sweep, the formation of a point of interest, the appearance of an imbalance and the transition of market structure play major roles and collectively define the broader direction of price.

In many bullish scenarios, the market begins by sweeping sell side liquidity and targeting important lows in order to collect the liquidity resting below them. This liquidity collection often becomes the starting point for creating a point of interest which usually marks the area where Smart Money begins to enter the market. 

After price moves away from this point, it breaks a structural high and forms a change of character. This shift marks a transition in the balance of power between buyers and sellers and is considered the first clear signal that the market structure is changing.

After the change of character, new institutional order flow often creates a strong and rapid movement that leaves behind an imbalance. This imbalance is one of the most important elements in Smart Money analysis because price tends to return to this area in order to complete structure and restore balance. 

The return into the imbalance becomes meaningful when it occurs together with the liquidity sweep, the presence of a validated point of interest and a confirmed structural transition. These conditions frequently mark the beginning of powerful movements within the Smart Money cycle.

Understanding the sequence of liquidity, point of interest, imbalance, change of character and market structure builds the foundation of Smart Money analysis and provides a clear view of the true direction of institutional strength.


[i]Bullish Setup[/i]:

[image]https://www.tradingview.com/x/RvCUSZU4/[/image]

[i]Bearish Setup[/i]:

[image]https://www.tradingview.com/x/56edz15R/[/image]


🔵[b]How to Use[/b]

To use this framework effectively, the trader must analyze the market through the principles of Smart Money and observe how liquidity drives price. A trade becomes valid only when several essential components appear together in a clear and consistent order. 

These components include the liquidity sweep, the formation of a point of interest, the confirmation of a change of character, the transition of market structure and the return of price into an imbalance. The method is built on the understanding that the market first collects liquidity, then shifts order flow and finally provides an entry opportunity inside an inefficient area or inside a point of interest. 

For this reason, the trader must follow the path of liquidity from the moment the sweep occurs, through the point of interest and the change of character and finally into the return of price toward the imbalance. When applied correctly, this approach creates entries that are more precise, more structural and more aligned with the real behavior of the market rather than with superficial signals.

🟣[b]Long Position[/b]

A bullish setup in Smart Money structure begins with a liquidity sweep on the sell side. The market first targets the areas where sell side liquidity is located and collects the stops and resting liquidity under previous lows. This collection is the condition that Smart Money requires to begin creating a new order flow. After this liquidity has been taken, a point of interest forms which is usually the last bearish candle or the effective demand zone that initiated the upward movement.

Price then moves away from the point of interest and breaks a structural high which creates a change of character. This event confirms that the market structure has moved from a bearish state to a bullish one and that buying pressure has taken control of the order flow. Following this shift, a strong upward movement often occurs and creates an imbalance between candles. This imbalance reflects the entrance of strong Smart Money orders and is seen as an important confirmation of bullish strength.

When price returns to this imbalance after the displacement, the market enters a phase where Smart Money aims to complete the corrective movement and continue the upward direction. The reaction inside the imbalance when combined with the liquidity sweep, the confirmed point of interest and the change of character completes the bullish setup and forms a structure that often leads to a continuation of the bullish trend.

[image]https://www.tradingview.com/x/SllJIm0P/[/image]


🟣[b]Short Position[/b]

A bearish setup follows the same Smart Money logic but in the opposite direction. The market begins by collecting buy side liquidity and targets the highs where buy side liquidity and resting stops are located. This liquidity sweep on the buy side becomes the starting phase for Smart Money to initiate a downward order flow. After the liquidity is collected, a bearish point of interest forms which is usually the last bullish candle or the supply zone that created the initial drop.

Price then moves away from this point and breaks the first structural low. This creates a change of character to the downside which confirms that the market structure has transitioned from bullish to bearish and that selling pressure has gained control. After this shift, a strong downward displacement appears and leaves behind a bearish imbalance that clearly shows the dominance of sellers.

As price returns to this imbalance and corrects the inefficient movement, the bearish setup becomes complete as long as the market structure remains bearish. The combination of the buy side liquidity sweep, the bearish point of interest, the change of character, the imbalance and the corrective return creates the ideal structure that Smart Money uses to continue the downward movement and develop a reliable selling opportunity.

[image]https://www.tradingview.com/x/zbqOtmYY/[/image]


🔵[b]Settings[/b]

🟣[b]Logic Settings[/b]

[i]Pivot Period[/i]: Defines how many bars are analyzed to identify swing highs and lows. Higher values detect larger, slower structures, while lower values respond to faster patterns. The default value of 5 offers a balanced sensitivity.

🟣[b]Alert Settings[/b]

[i]Alert[/i]: Enables alerts for SMS08.

[i]Message Frequency[/i]: Determines the frequency of alerts. Options include 'All' (every function call), 'Once Per Bar' (first call within the bar), and 'Once Per Bar Close' (final script execution of the real-time bar). Default is 'Once per Bar'.

[i]Show Alert Time by Time Zone[/i]: Configures the time zone for alert messages. Default is 'UTC'.


🔵[b]Conclusion[/b]

The Smart Money approach demonstrates that price movement is not random or based on surface level patterns. Instead, it develops through a clear cycle of liquidity collection, structural transition and corrective movement toward key price zones. By recognizing events such as the liquidity sweep, the formation of the point of interest, the change of character and the return into the imbalance, the trader gains the ability to understand order flow more accurately and identify the true direction of market structure. 

Both bullish and bearish setups show that the alignment of these elements creates a transparent view of institutional behavior and reveals the source of strong movements in the market. When the trader correctly identifies this sequence, entry points become more reliable and more aligned with liquidity flow. The combination of liquidity, structure and imbalance provides a consistent framework that removes guesswork and guides decisions through the real logic of the market.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TFlab

//@version=5

indicator("Smart Money Setup 08 [TradingFinder] Binary Options Gold Scalper", "Smart Money Setup 08 TFlab", overlay = true, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500)

//Import Library
import TFlab/AlertSenderLibrary_TradingFinder/1 as Alert

//Input
SwingPeriod = input.int(5, 'Swing Period' , minval = 1, group = 'Logical Setting')


// Alert Input
Alert = input.string('On', 'Alert', ['On', 'Off'], 'If you turn on the Alert, you can receive alerts and notifications after setting the "Alert".', group = 'Alert')
AlertName = input.string('Smart Money Setup 08 [TradingFinder]', 'Alert Name', group = 'Alert')
Frequncy = input.string('Once Per Bar' , 'Message Frequency' , ['All', 'Once Per Bar' , 'Per Bar Close'], 'The triggering frequency. Possible values are: All'+ 
 ' (all function calls trigger the alert), Once Per Bar (the first function call during the bar triggers the alert), ' +  
 ' Per Bar Close (the function call triggers the alert only when it occurs during the last script iteration of the real-time bar,' +  
 ' when it closes). The default is alert.freq_once_per_bar.)', group = 'Alert')
UTC = input.string('UTC' , 'Show Alert time by Time Zone', group = 'Alert')
MessageBull = input.text_area('Long Signal Position' , 'Long Position Message' , group = 'Alert') 
MessageBear = input.text_area('Short Signal Position', 'Short Position Message',group = 'Alert')

VFVGFilter = 'Off'
VFVGFilterType = 'Very Aggressive'

//Fair Value Gap
FVG_Detector(FVGFilter, FVGFilterType) =>
    var bool DConditionFVG = false
    var bool SConditionFVG = false
    //ATR
    ATR = ta.atr(55)
    //Demand FVG Filter Method {Choose and switch}
    DConditionFVG := if FVGFilter == 'Off'  
        if (low > high[2] )
            true
        else
            false

    else if FVGFilter == 'On'
        if FVGFilterType =='Very Aggressive' and  (low > high[2] ) and (high > high[1] ) 
            true
        else if FVGFilterType =='Aggressive' and ((low > high[2] )and ((high[1] - low[1]) >= (1.0 * ATR)) and (high > high[1] )) 
            true
        else if FVGFilterType == 'Defensive' and ((low > high[2] )and ((high[1] - low[1]) >= (1.5 * ATR)) and (high > high[1] )) 
         and ((close[2] - open[2] > 0 and close[1] - open[1] > 0) or math.abs((close[1] - open[1])/(high[1] - low[1])) > 0.7) 
            true         
        else if FVGFilterType =='Very Defensive' and ((low > high[2] )and ((high[1] - low[1]) >= (1.5 * ATR)) and (high > high[1] )) 
         and ((close[2] - open[2] > 0 and close[1] - open[1] > 0) and math.abs((close[1] - open[1])/(high[1] - low[1])) > 0.7)
         and math.abs((close[2] - open[2])/(high[2] - low[2])) > 0.35 and math.abs((close - open)/(high - low)) > 0.35
            true
        else
            false

    //Supply FVG Filter Method {Choose and switch}
    SConditionFVG := if FVGFilter == 'Off' 
        if (high < low[2] )
            true
        else
            false
    else if FVGFilter == 'On'
        if FVGFilterType == 'Very Aggressive' and  (high < low[2] ) and (low[1] > low )  
            true
        else if FVGFilterType == 'Aggressive' and ((high < low[2] )and ((high[1] - low[1]) >= (1.0 * ATR)) and (low[1] > low ))  
            true
        else if FVGFilterType == 'Defensive' and ((high < low[2] )and ((high[1] - low[1]) >= (1.5 * ATR)) and (low[1] > low ))  
         and ((close[2] - open[2] < 0 and close[1] - open[1] < 0) or math.abs((close[1] - open[1])/(high[1] - low[1])) > 0.7) 
            true
        else if FVGFilterType == 'Very Defensive' and ((high < low[2] )and ((high[1] - low[1]) >= (1.5 * ATR)) and (low[1] > low )) 
         and ((close[2] - open[2] < 0 and close[1] - open[1] < 0) and math.abs((close[1] - open[1])/(high[1] - low[1])) > 0.7)
         and math.abs((close[2] - open[2])/(high[2] - low[2])) > 0.35 and math.abs((close - open)/(high - low)) > 0.35
            true
        else
            false

    [DConditionFVG, SConditionFVG]


//SFP Detector Function
SF_Detector(SwingPeriod, MaxSwingBack_Method, MaxSwingBack, SFPType, BackToBreakPeriod) => //Swing Failure 
    const int Z = 100000000000000000

    var MSH_P = array.new_float()
    var MSH_I = array.new_int()
    var MSH_II= array.new_int()

    var MSL_P = array.new_float()
    var MSL_I = array.new_int()
    var MSL_II = array.new_int()

    var MSH_Permit = array.new_bool()
    var AOI_MSH = array.new_int()//Another Opportunity Index

    var MSL_Permit = array.new_bool()
    var AOI_MSL = array.new_int()//Another Opportunity Index

    var float Last_MSH_P = 0.0
    var int Last_MSH_I   = 0
    var float Last_MSL_P = 0.0
    var int Last_MSL_I   = 0

    int HSwingBack = 0
    int LSwingBack = 0
    
    var bool RealSFP         = na
    var bool ConsiderableSFP = na

    var float H_Price_SFP = 0.0
    var int   H_Index_SFP = 0
    var float L_Price_SFP = 0.0
    var int   L_Index_SFP = 0

    bool HAlert = na
    bool LAlert = na  

    MSH = ta.pivothigh(SwingPeriod , SwingPeriod)   // Major Swing High
    MSL = ta.pivotlow(SwingPeriod , SwingPeriod)   // Major Swing Low

    if not (not MSH)
        MSH_P.push(high[SwingPeriod])
        MSH_I.push(time[SwingPeriod])
        MSH_II.push(bar_index[SwingPeriod])
        MSH_Permit.push(true)
        AOI_MSH.push(Z)

    if not (not MSL)
        MSL_P.push(low[SwingPeriod])
        MSL_I.push(time[SwingPeriod])
        MSL_II.push(bar_index[SwingPeriod])
        MSL_Permit.push(true)
        AOI_MSL.push(Z)

    if  MSH_P.size() > 0 
        Last_MSH_P := MSH_P.get(MSH_P.size() - 1)
        Last_MSH_I := MSH_II.get(MSH_I.size() - 1)

    if  MSL_P.size() > 0 
        Last_MSL_P := MSL_P.get(MSL_P.size() - 1)
        Last_MSL_I := MSL_II.get(MSL_I.size() - 1)

    switch MaxSwingBack_Method
        'All'    => HSwingBack := MSH_P.size() , LSwingBack := MSL_P.size()
        'Custom' => HSwingBack := MaxSwingBack , LSwingBack := MaxSwingBack 

    switch SFPType
        'All'              => RealSFP := true  , ConsiderableSFP := true
        'Real SFP'         => RealSFP := true  , ConsiderableSFP := false
        'Considerable SFP' => RealSFP := false , ConsiderableSFP := true

    if MSH_P.size() > (MaxSwingBack_Method == 'All' ? 1 : HSwingBack)
        if bar_index > bar_index[1] 
            for i = 1 to HSwingBack   by 1
                if  MSH_Permit.get(MSH_P.size()  - i)
                    if    (bar_index <= AOI_MSH.get(AOI_MSH.size() - i) + BackToBreakPeriod) 
                        if   ((MSH_P.get(MSH_P.size() - i)  < high and MSH_P.get(MSH_P.size() - i)  > close and (AOI_MSH.get(AOI_MSH.size() - i) == Z) and RealSFP )
                             or   ( (MSH_P.get(MSH_P.size() - i) > close and (MSH_P.get(MSH_P.size() - i) < close[1]))  and ConsiderableSFP))
                               
                            MSH_Permit.set(MSH_P.size() - i  , false)

                            if bar_index - MSH_II.get(MSH_P.size() - i) >= 10 and bar_index - MSH_II.get(MSH_P.size() - i) <= 50 //and (high[1] < high[2])
 
                                MSH_Permit.set(MSH_P.size() - i  , false)
                                H_Index_SFP := MSH_II.get(MSH_P.size() - i)
                                H_Price_SFP := MSH_P.get(MSH_P.size() - i)
                                HAlert := true

                        if RealSFP == false
                            if (MSH_P.get(MSH_P.size() - i)  < high and MSH_P.get(MSH_P.size() - i)  > close and (AOI_MSH.get(AOI_MSH.size() - i) == Z))
                                MSH_Permit.set(MSH_P.size() - i  , false)
                    if ((MSH_P.get(MSH_P.size() - i)  < close) and (AOI_MSH.get(AOI_MSH.size() - i) == Z))
                        AOI_MSH.set(AOI_MSH.size() - i, bar_index)



    if MSL_P.size() > (MaxSwingBack_Method == 'All' ? 1 : LSwingBack)
        if bar_index > bar_index[1] 
            for i = 1 to  LSwingBack  by 1
                if  MSL_Permit.get(MSL_P.size()  - i)
                    if    (bar_index <= AOI_MSL.get(AOI_MSL.size() - i) + BackToBreakPeriod) 
                        if    ((MSL_P.get(MSL_P.size() - i)  > low and MSL_P.get(MSL_P.size() - i)  < close and (AOI_MSL.get(AOI_MSL.size() - i) == Z) and RealSFP )
                             or   ( (MSL_P.get(MSL_P.size() - i) < close and MSL_P.get(MSL_P.size() - i) > close[1])  and ConsiderableSFP))
                               

                            MSL_Permit.set(MSL_P.size() - i  , false)

                            if bar_index - MSL_II.get(MSL_P.size() - i) >= 10 and bar_index - MSL_II.get(MSL_P.size() - i) <= 100 //and (low[1] > low[2])

                                MSL_Permit.set(MSL_P.size() - i  , false)
                                L_Index_SFP := MSL_II.get(MSL_P.size() - i)
                                L_Price_SFP := MSL_P.get(MSL_P.size() - i)
                                LAlert := true

                        if RealSFP == false
                            if (MSL_P.get(MSL_P.size() - i)  > low and MSL_P.get(MSL_P.size() - i)  < close and (AOI_MSL.get(AOI_MSL.size() - i) == Z))
                                MSL_Permit.set(MSL_P.size() - i  , false)

                    if ((MSL_P.get(MSL_P.size() - i)  > close) and (AOI_MSL.get(AOI_MSL.size() - i) == Z))
                        AOI_MSL.set(AOI_MSL.size() - i, bar_index)
    [nz(HAlert),H_Index_SFP, H_Price_SFP, nz(LAlert), L_Index_SFP, L_Price_SFP, Last_MSH_I, Last_MSH_P, Last_MSL_I, Last_MSL_P]


[HAlert, H_Index_SFP, H_Price_SFP, LAlert, L_Index_SFP, L_Price_SFP, Last_MSH_I, Last_MSH_P, Last_MSL_I, Last_MSL_P] = request.security(syminfo.tickerid, timeframe.period , SF_Detector(SwingPeriod, 'Custom', 100, 'Real SFP', 2))



type data
    int   G_Permit
    float Lvl_cp
    int   Lvl_ci
    int   Lvl_pt
    int   POI_pt
    int   POI_t         
    int   POI_i
    float POI_o
    float POI_h
    float POI_l
    float POI_c
    int   FVG_i
    float FVG_d
    float FVG_p
    int   Fill_Ch_i
    int   Fill_POI_i
    int   Swg_i
    float Swg_p



Pattern_Checker() =>
    var int xSL_i = 0, var int xSL_ii = 0, var float xSL_p = 0.0, var int ChoCh_i = 0, var int ChoCh_ii = 0, var float ChoCh_p = 0.0, var int POI_i = 0, var int POI_ii = 0, var float POI_p = 0.0, var float POI_d = 0.0, var int FVG_i = 0, var float FVG_p = 0.0, var float FVG_d = 0.0
    bool Bull = false
    bool Bear = false

    var Data = array.new<data>()

    [DConditionFVG, SConditionFVG] = FVG_Detector(VFVGFilter, VFVGFilterType)

    if barstate.isconfirmed

        if LAlert
            Data.push(data.new(1, Last_MSH_P, Last_MSH_I, 0, 0, 1 , bar_index, open, high, low, close, 0, 0, 0, 0, 0, L_Index_SFP, L_Price_SFP))

        if HAlert
            Data.push(data.new(1, Last_MSL_P, Last_MSL_I, 0, 0, -1, bar_index, open, high, low, close, 0, 0, 0, 0, 0, H_Index_SFP, H_Price_SFP))

    if barstate.isconfirmed and (Data.size() >= 10)
        for i = 1 to 10 by 1

            get = Data.get(Data.size() - i)

            if get.G_Permit == 1

                if get.POI_t == 1 
                    if get.POI_l > close
                        get.G_Permit := 0

                    if get.POI_i + SwingPeriod <= bar_index and get.POI_pt == 0
                        if get.POI_h > low and close > get.POI_l
                            get.POI_pt := 1
                            get.Fill_POI_i := bar_index
                            
                        
                    if get.Lvl_pt == 0
                        if close > get.Lvl_cp
                            get.Lvl_pt := 1
                            get.Fill_Ch_i := bar_index

                        if Last_MSH_P > get.Lvl_cp
                            get.Lvl_ci := Last_MSH_I
                            get.Lvl_cp := Last_MSH_P


                    if get.FVG_i == 0
                        if get.POI_pt == 1
                            if DConditionFVG
                                get.FVG_i := bar_index[1]
                                get.FVG_d := high[2]
                                get.FVG_p := low

                    else
                        if low < get.FVG_p and close > get.FVG_d and get.Lvl_pt == 1 
                            xSL_i := get.Swg_i, xSL_ii := get.POI_i, xSL_p := get.Swg_p, ChoCh_i := get.Lvl_ci, ChoCh_ii := get.Fill_Ch_i, ChoCh_p := get.Lvl_cp, POI_i := get.POI_i, POI_ii := get.Fill_POI_i, POI_p := get.POI_h, POI_d := get.POI_l, FVG_i := get.FVG_i, FVG_p := get.FVG_p, FVG_d := get.FVG_d
                            Bull := true
                            get.G_Permit := 0
                        if close < get.FVG_d
                            get.G_Permit := 0



                if get.POI_t == -1
                    if get.POI_h < close
                        get.G_Permit := 0

                    if get.POI_i + SwingPeriod <= bar_index and get.POI_pt == 0
                        if get.POI_l < high 
                            get.POI_pt := 1
                            get.Fill_POI_i := bar_index


                    if get.Lvl_pt == 0
                        if close < get.Lvl_cp
                            get.Lvl_pt := 1
                            get.Fill_Ch_i := bar_index

                        if Last_MSL_P < get.Lvl_cp
                            get.Lvl_ci := Last_MSL_I
                            get.Lvl_cp := Last_MSL_P

                    if get.FVG_i == 0
                        if get.POI_pt == 1
                            if SConditionFVG
                                get.FVG_i := bar_index[1]
                                get.FVG_d := low[2]
                                get.FVG_p := high

                    else
                        if high > get.FVG_p and close < get.FVG_d and get.Lvl_pt == 1 
                            xSL_i := get.Swg_i, xSL_ii := get.POI_i, xSL_p := get.Swg_p, ChoCh_i := get.Lvl_ci, ChoCh_ii := get.Fill_Ch_i, ChoCh_p := get.Lvl_cp, POI_i := get.POI_i, POI_ii := get.Fill_POI_i, POI_p := get.POI_l, POI_d := get.POI_h, FVG_i := get.FVG_i, FVG_p := get.FVG_p, FVG_d := get.FVG_d
                            Bear := true
                            get.G_Permit := 0
                        if close > get.FVG_d
                            get.G_Permit := 0
 
    [Bull, Bear, xSL_i , xSL_ii , xSL_p , ChoCh_i , ChoCh_ii , ChoCh_p , POI_i , POI_ii , POI_p , POI_d , FVG_i , FVG_p, FVG_d]

[Bull, Bear, xSL_i , xSL_ii , xSL_p , ChoCh_i , ChoCh_ii , ChoCh_p , POI_i , POI_ii , POI_p , POI_d , FVG_i , FVG_p, FVG_d] = Pattern_Checker()


Drawing(Bull, Bear, xSL_i , xSL_ii , xSL_p , ChoCh_i , ChoCh_ii , ChoCh_p , POI_i , POI_ii , POI_p , POI_d , FVG_i , FVG_p, FVG_d) =>

    var line xSL_Li = na, var label xSL_La = na
    var line Cho_Li = na, var label Cho_La = na
    var line POI_D  = na, var line  POI_P  = na , var label POI_La = na, var linefill POI_F = na
    var line FVG_D  = na, var line  FVG_P  = na , var label FVG_La = na, var linefill FVG_F = na
    var FVG_Box = array.new_box(),var POI_Box = array.new_box()

    if Bull 
        xSL_Li := line.new(xSL_i, xSL_p, xSL_ii, xSL_p, color = #5be660, style = line.style_dotted)
        xSL_La := label.new(int(math.avg(xSL_i, xSL_ii)), xSL_p, 'SSL',color = #a5f2a7,textcolor = #000000, style = label.style_label_center, size = size.small)
        Cho_Li := line.new(ChoCh_i, ChoCh_p, ChoCh_ii, ChoCh_p, color = #5be660, style = line.style_dotted)
        Cho_La := label.new(int(math.avg(ChoCh_i, ChoCh_ii)), ChoCh_p, 'ChoCh',color = #a5f2a7,textcolor = #000000, style = label.style_label_center, size = size.small)
        POI_D  := line.new(POI_i, POI_d, POI_ii, POI_d, color = #509fff, style = line.style_dashed)
        POI_P  := line.new(POI_i, POI_p, POI_ii, POI_p, color = #509fff, style = line.style_dashed)
        POI_La := label.new(int(math.avg(POI_i, POI_ii)), math.avg(POI_d, POI_p), 'POI',color = #85b9f900,textcolor = #dadada, style = label.style_label_center, size = size.small)
        FVG_D  := line.new(FVG_i, FVG_d, bar_index, FVG_d, color = #68ff6d, style = line.style_dashed)
        FVG_P  := line.new(FVG_i, FVG_p, bar_index, FVG_p, color = #68ff6d, style = line.style_dashed)
        FVG_La := label.new(int(math.avg(FVG_i, bar_index)), math.avg(FVG_d, FVG_p), 'Imbalance',color = #a5f2a800,textcolor = #dadada, style = label.style_label_center, size = size.small)

        for i = 0 to 19 by 1 
            FVG_Box.push(box.new(FVG_i, FVG_d + ((FVG_p - FVG_d) * (0.05 * (i + 1))), bar_index, FVG_d + ((FVG_p - FVG_d) * (0.05 * i)), bgcolor = color.new(#00d37087, 55 + ((i + 1)* 2.25)), border_color = na, border_width = 0))
            POI_Box.push(box.new(POI_i, POI_d + ((POI_p - POI_d) * (0.05 * (i + 1))), POI_ii   , POI_d + ((POI_p - POI_d) * (0.05 * i)), bgcolor = color.new(#00b4eb6b, 55 + ((i + 1)* 2.25)), border_color = na, border_width = 0))


    if Bear
        xSL_Li := line.new(xSL_i, xSL_p, xSL_ii, xSL_p, color = #e65b5b, style = line.style_dotted)
        xSL_La := label.new(int(math.avg(xSL_i, xSL_ii)), xSL_p, 'BSL',color = #dd8e8e,textcolor = #ffffff, style = label.style_label_center, size = size.small)
        Cho_Li := line.new(ChoCh_i, ChoCh_p, ChoCh_ii, ChoCh_p, color = #e65b5b, style = line.style_dotted)
        Cho_La := label.new(int(math.avg(ChoCh_i, ChoCh_ii)), ChoCh_p, 'ChoCh',color = #dd8e8e,textcolor = #ffffff, style = label.style_label_center, size = size.small)
        POI_D  := line.new(POI_i, POI_d, POI_ii, POI_d, color = #ffeb50, style = line.style_dashed)
        POI_P  := line.new(POI_i, POI_p, POI_ii, POI_p, color = #ffeb50, style = line.style_dashed)
        POI_La := label.new(int(math.avg(POI_i, POI_ii)), math.avg(POI_d, POI_p), 'POI',color = #85b9f900,textcolor = #dadada, style = label.style_label_center, size = size.small)
        FVG_D  := line.new(FVG_i, FVG_d, bar_index, FVG_d, color = #ff6868, style = line.style_dashed)
        FVG_P  := line.new(FVG_i, FVG_p, bar_index, FVG_p, color = #ff6868, style = line.style_dashed)
        FVG_La := label.new(int(math.avg(FVG_i, bar_index)), math.avg(FVG_d, FVG_p), 'Imbalance',color = #a5f2a800,textcolor = #dadada, style = label.style_label_center, size = size.small)

        for i = 0 to 19 by 1 
            FVG_Box.push(box.new(FVG_i, FVG_d + ((FVG_p - FVG_d) * (0.05 * (i + 1))), bar_index, FVG_d + ((FVG_p - FVG_d) * (0.05 * i)), bgcolor = color.new(#d3004a5d, 50 + ((i + 1)* 2.25)), border_color = na, border_width = 0))
            POI_Box.push(box.new(POI_i, POI_d + ((POI_p - POI_d) * (0.05 * (i + 1))), POI_ii   , POI_d + ((POI_p - POI_d) * (0.05 * i)), bgcolor = color.new(#e7eb006b, 50 + ((i + 1)* 2.25)), border_color = na, border_width = 0))

Drawing(Bull, Bear, xSL_i , xSL_ii , xSL_p , ChoCh_i , ChoCh_ii , ChoCh_p , POI_i , POI_ii , POI_p , POI_d , FVG_i , FVG_p, FVG_d)

plotshape(Bull, '', shape.triangleup  , location.belowbar, color = color.green, size = size.normal)
plotshape(Bear, '', shape.triangledown, location.abovebar, color = color.red  , size = size.normal)

Alert.AlertSender(Bull  , Alert, AlertName , 'Analysis', '', 'Basic' ,'Once Per Bar', 'UTC', 'Off', MessageBull, open, high, low, close,0,0,0,0,0)
Alert.AlertSender(Bear  , Alert, AlertName , 'Analysis', '', 'Basic' ,'Once Per Bar', 'UTC', 'Off', MessageBear, open, high, low, close,0,0,0,0,0)
````
