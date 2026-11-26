# Son Model ICT [TradingFinder] HTF DOL H1  + Sweep M15 + FVG M1

- url: https://www.tradingview.com/script/zC2GIlWV-Son-Model-ICT-TradingFinder-HTF-DOL-H1-Sweep-M15-FVG-M1/
- type: indicator
- pine_id: PUB;f5bc5d770c1b44a4b611427ddf34b4ab
- version: 2.0

## Description

🔵[b]Introduction[/b]

The ICT Son Model setup is a precise trading strategy based on market structure and liquidity, implemented across multiple timeframes. This setup first identifies a liquidity level in the 1-hour (1H) timeframe and then confirms a Market Structure Shift (MSS) in the 5-minute (5M) timeframe to validate the trend. After confirmation, the price forms a new swing in the 5-minute timeframe, absorbing liquidity. 

Once this level is broken, traders typically drop to the 30-second (30s) timeframe and enter trades based on a Fair Value Gap (FVG). However, since access to the 30-second timeframe is not available to most traders, we take the entry signal directly from the 5-minute timeframe, using the same liquidity zones and confirmed breakouts to execute trades. This approach simplifies execution and makes the strategy accessible to all traders.

[i]This model operates in two setups[/i]: 

Bullish ICT Son Model and Bearish ICT Son Model. In the bullish setup, liquidity is first accumulated at the lows of the 1-hour timeframe, and after confirming a market structure shift, a long position is initiated. Conversely, in the bearish setup, liquidity is first drawn from higher levels, and upon confirmation of a bearish trend, a short position is executed.

[i]Bullish Setup[/i]:

[image]https://www.tradingview.com/x/XHRyilwj/[/image]

[i]Bearish Setup[/i]:

[image]https://www.tradingview.com/x/SKuclLCu/[/image]

🔵[b]How to Use[/b]

The ICT Son Model setup is designed around liquidity analysis and market structure shifts and can be applied in both bullish and bearish market conditions. The strategy first identifies a liquidity level in the 1-hour (1H) timeframe and then confirms a Market Structure Shift (MSS) in the 5-minute (5M) timeframe. 

After this shift, the price forms a new swing, absorbing liquidity. When this level is broken in the 5-minute timeframe, the trader enters based on a Fair Value Gap (FVG). While the ideal entry is in the 30-second (30s) timeframe, due to accessibility constraints, we take entry signals directly from the 5-minute timeframe.

🟣[b]Bullish Setup[/b]

In the Bullish ICT Son Model, the 1-hour timeframe first identifies liquidity at the market lows, where price sweeps this level to absorb liquidity. Then, in the 5-minute timeframe, an MSS confirms the bullish shift. 

After confirmation, the price forms a new swing, absorbing liquidity at a higher level. The price then retraces into a Fair Value Gap (FVG) created in the 5-minute timeframe, where the trader enters a long position, placing the stop-loss below the FVG.

[image]https://www.tradingview.com/x/J0qUHTcZ/[/image]

🟣[b]Bearish Setup[/b]

In the Bearish ICT Son Model, liquidity at higher market levels is identified in the 1-hour timeframe, where price sweeps these levels to absorb liquidity. Then, in the 5-minute timeframe, an MSS confirms the bearish trend.

After confirmation, the price forms a new swing, absorbing liquidity at a lower level. The price then retraces into a Fair Value Gap (FVG) created in the 5-minute timeframe, where the trader enters a short position, placing the stop-loss above the FVG.

[image]https://www.tradingview.com/x/wfXyztC6/[/image]

🔵[b]Settings[/b]

[i]Swing period[/i]: You can set the swing detection period.

[i]Max Swing Back Method[/i]: It is in two modes "All" and "Custom". If it is in "All" mode, it will check all swings, and if it is in "Custom" mode, it will check the swings to the extent you determine.

[i]Max Swing Back[/i]: You can set the number of swings that will go back for checking.

[i]FVG Length[/i]: Default is 120 Bar.

[i]MSS Length[/i]: Default is 80 Bar.

[i]FVG Filter[/i]: This refines the number of identified FVG areas based on a specified algorithm to focus on higher quality signals and reduce noise.

[i]Types of FVG filters[/i]:

[list]
[*]Very Aggressive Filter: Adds a condition where, for an upward FVG, the last candle's highest price must exceed the middle candle's highest price, and for a downward FVG, the last candle's lowest price must be lower than the middle candle's lowest price. This minimally filters out FVGs.
[*]Aggressive Filter: Builds on the Very Aggressive mode by ensuring the middle candle is not too small, filtering out more FVGs.
[*]Defensive Filter: Adds criteria regarding the size and structure of the middle candle, requiring it to have a substantial body and specific polarity conditions, filtering out a significant number of FVGs.
[*]Very Defensive Filter: Further refines filtering by ensuring the first and third candles are not small-bodied doji candles, retaining only the highest quality signals.
[/list]

🔵[b]Conclusion[/b]

The ICT Son Model setup is a structured and precise method for trade execution based on liquidity analysis and market structure shifts. This strategy first identifies a liquidity level in the 1-hour timeframe and then confirms a trend shift using the 5-minute timeframe. 

Trade entries are executed based on Fair Value Gaps (FVGs), which highlight optimal entry points. By applying this model, traders can leverage existing market liquidity to enter high-probability trades. The bullish setup activates when liquidity is swept from market lows and a market structure shift confirms an upward trend, whereas the bearish setup is used when liquidity is drawn from market highs, confirming a downtrend.

This approach enables traders to identify high-probability trade setups with greater precision compared to many other strategies. Additionally, since access to the 30-second timeframe is limited, the strategy remains fully functional in the 5-minute timeframe, making it more practical and accessible for a wider range of traders.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TFlab

//@version=5

indicator("Son Model ICT [TradingFinder] HTF DOL H1  + Sweep M15 + FVG M1","TFlab ICT Son's Model", overlay = true, max_bars_back = 5000, max_lines_count = 500, max_labels_count = 500)

//import Libraries
    //import Order Block Refiner
import TFlab/OrderBlockRefiner_TradingFinder/2 as Refiner
    //import Order Block Drawing  Library
import TFlab/OrderBlockDrawing_TradingFinder/4 as Drawing
    //import FVD Detector Library
import TFlab/FVGDetectorLibrary/3 as FVG
    //import Alert Sender Library
import TFlab/AlertSenderLibrary_TradingFinder/1 as Alert

//Input
SwingPeriod = input.int(50, 'Swing Period' , minval = 1, group = 'Logical Setting')
MaxSwingBack_Method = input.string('All', 'Max Swing Back Method' , ['All', 'Custom'], group = 'Logical Setting')
MaxSwingBack = input.int(100, 'Max Swing Back' , minval = 1, group = 'Logical Setting')
FVG_Length = input.int(120, 'FVG Length' , minval = 1, group = 'Logical Setting')
MSS_Length =  input.int(80, 'MSS Length' , minval = 1, group = 'Logical Setting')

    //FVG Filter

PFVGFilter = input.bool(false, 'FVG Filter ............',  group = 'FVG Logical Setting' , inline = 'FVG Filter')
PFVGFilterType = input.string('Defensive', '', ['Very Aggressive' , 'Aggressive' , 'Defensive' , 'Very Defensive'], group = 'FVG Logical Setting', inline = 'FVG Filter' ,
 tooltip = 'If it is "On", this filter will filter "FVGs" based on the width of the Zone.'  + 
 'From "Very Aggressive" to "Very Defensive" the width of the "FVG" decreases.')
MLFVG = input.string('Proximal' , 'Mitigation Level FVG', ['Proximal', '50 % OB', 'Distal'], 
 tooltip= 'Using this entry, you can determine which level the price reacts to in a FVG.', group = 'FVG Logical Setting')

    // Alert
AlertName = input.string('Son Model ICT [TradingFinder]', 'Alert Name', group = 'Alert')
Frequncy = input.string('Once Per Bar' , 'Message Frequency' , ['All', 'Once Per Bar' , 'Per Bar Close'], 'The triggering frequency. Possible values are: All'+ 
 ' (all function calls trigger the alert), Once Per Bar (the first function call during the bar triggers the alert), ' +  
 ' Per Bar Close (the function call triggers the alert only when it occurs during the last script iteration of the real-time bar,' +  
 ' when it closes). The default is alert.freq_once_per_bar.)', group = 'Alert')
UTC = input.string('UTC' , 'Show Alert time by Time Zone', group = 'Alert')
Son_Bull = input.string('On', 'Alert Demand Mitigation', ['On', 'Off'], 'If you turn on the Alert, you can receive alerts and notifications after setting the "Alert".', group = 'Alert')
Son_Bear = input.string('On', 'Alert Supply Mitigation', ['On', 'Off'], 'If you turn on the Alert, you can receive alerts and notifications after setting the "Alert".', group = 'Alert')



    //Display FVG

DFVGShow  = input.bool(true, 'Demand FVG', inline = 'DFVG', group = 'FVG Display Setting')
DFVGColor = input.color(#2d8d006b, '', inline = 'DFVG', group = 'FVG Display Setting')

SFVGShow  = input.bool(true, 'Supply FVG', inline = 'SFVG', group = 'FVG Display Setting')
SFVGColor = input.color(#db120470, '', inline = 'SFVG', group = 'FVG Display Setting')

AShow = input.bool(true, 'Show All HTF LvL',group = 'Display Setting')
HShow = input.bool(true, 'Show High HTF LvL',group = 'Display Setting', inline = 'H')
LShow = input.bool(true, 'Show Low HTF LvL',group = 'Display Setting' , inline = 'L')

HNColor = input.color(#870505 , 'Name',group = 'Display Setting', inline = 'H')
LNColor = input.color(#014f07 , 'Name',group = 'Display Setting', inline = 'L')
HLColor = input.color(#b90000b8 , 'Line',group = 'Display Setting', inline = 'H')
LLColor = input.color(#069206a7 , 'Line',group = 'Display Setting', inline = 'L')


AShow_MSS = input.bool(true, 'Show All MSS',group = 'Display Setting')
HShow_MSS = input.bool(true, 'Show High MSS',group = 'Display Setting', inline = 'HMSS')
LShow_MSS = input.bool(true, 'Show Low MSS',group = 'Display Setting' , inline = 'LMSS')

HNColor_MSS = input.color(#870505 , 'Name',group = 'Display Setting', inline = 'HMSS')
LNColor_MSS = input.color(#014f07 , 'Name',group = 'Display Setting', inline = 'LMSS')
HLColor_MSS = input.color(#b90000b8 , 'Line',group = 'Display Setting', inline = 'HMSS')
LLColor_MSS = input.color(#069206a7 , 'Line',group = 'Display Setting', inline = 'LMSS')


//HTF LvL Detector Function
HTF_Detector(SwingPeriod, MaxSwingBack_Method, MaxSwingBack) => //Swing Failure 
    const int Z = 100000000000000000

    var MSH_P = array.new_float()
    var MSH_I = array.new_int()
    var MSL_P = array.new_float()
    var MSL_I = array.new_int()

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
    
    var bool RealHTFLvL         = na
    var bool ConsiderableHTFLvL = na

    var float H_Price_HTFLvL = 0.0
    var int   H_Index_HTFLvL = 0
    var float L_Price_HTFLvL = 0.0
    var int   L_Index_HTFLvL = 0

    bool HAlert = na
    bool LAlert = na  

    MSH = ta.pivothigh(SwingPeriod , SwingPeriod)   // Major Swing High
    MSL = ta.pivotlow(SwingPeriod , SwingPeriod)   // Major Swing Low

    if not (not MSH)
        MSH_P.push(high[SwingPeriod])
        MSH_I.push(time[SwingPeriod])
        MSH_Permit.push(true)
        AOI_MSH.push(Z)

    if not (not MSL)
        MSL_P.push(low[SwingPeriod])
        MSL_I.push(time[SwingPeriod])
        MSL_Permit.push(true)
        AOI_MSL.push(Z)

    if  MSH_P.size() > 0 
        Last_MSH_P := MSH_P.get(MSH_P.size() - 1)
        Last_MSH_I := MSH_I.get(MSH_I.size() - 1)

    if  MSL_P.size() > 0 
        Last_MSL_P := MSL_P.get(MSL_P.size() - 1)
        Last_MSL_I := MSL_I.get(MSL_I.size() - 1)

    switch MaxSwingBack_Method
        'All'    => HSwingBack := MSH_P.size() , LSwingBack := MSL_P.size()
        'Custom' => HSwingBack := MaxSwingBack , LSwingBack := MaxSwingBack 


    if MSH_P.size() > (MaxSwingBack_Method == 'All' ? 1 : HSwingBack)
        for i = 1 to HSwingBack   by 1
            if  MSH_Permit.get(MSH_P.size()  - i)
                if    (bar_index <= AOI_MSH.get(AOI_MSH.size() - i) ) 
                    if   (MSH_P.get(MSH_P.size() - i)  < high and MSH_P.get(MSH_P.size() - i)  > close and (AOI_MSH.get(AOI_MSH.size() - i) == Z) ) 
                        MSH_Permit.set(MSH_P.size() - i  , false)
                        H_Index_HTFLvL := MSH_I.get(MSH_P.size() - i)
                        H_Price_HTFLvL := MSH_P.get(MSH_P.size() - i)
                        HAlert := true
                if ((MSH_P.get(MSH_P.size() - i)  < close) and (AOI_MSH.get(AOI_MSH.size() - i) == Z))
                    AOI_MSH.set(AOI_MSH.size() - i, bar_index)



    if MSL_P.size() > (MaxSwingBack_Method == 'All' ? 1 : LSwingBack)
        for i = 1 to  LSwingBack  by 1
            if  MSL_Permit.get(MSL_P.size()  - i)
                if    (bar_index <= AOI_MSL.get(AOI_MSL.size() - i) ) 
                    if    (MSL_P.get(MSL_P.size() - i)  > low and MSL_P.get(MSL_P.size() - i)  < close and (AOI_MSL.get(AOI_MSL.size() - i) == Z))
                        MSL_Permit.set(MSL_P.size() - i  , false)
                        L_Index_HTFLvL := MSL_I.get(MSL_P.size() - i)
                        L_Price_HTFLvL := MSL_P.get(MSL_P.size() - i)
                        LAlert := true
                if ((MSL_P.get(MSL_P.size() - i)  > close) and (AOI_MSL.get(AOI_MSL.size() - i) == Z))
                    AOI_MSL.set(AOI_MSL.size() - i, bar_index)
    [nz(HAlert),H_Index_HTFLvL, H_Price_HTFLvL, nz(LAlert), L_Index_HTFLvL, L_Price_HTFLvL]



[HAlert_o, H_Index_HTFLvL_o, H_Price_HTFLvL_o, LAlert_o, L_Index_HTFLvL_o, L_Price_HTFLvL_o] = 
 request.security(syminfo.tickerid, '60', HTF_Detector(SwingPeriod, MaxSwingBack_Method, MaxSwingBack), gaps = barmerge.gaps_on)

var bool  HAlert = na 
var int   H_Index_HTFLvL = na 
var float H_Price_HTFLvL = na
var bool  LAlert = na
var int   L_Index_HTFLvL = na
var float L_Price_HTFLvL = na 

if HAlert_o
    HAlert      := true
    H_Index_HTFLvL := H_Index_HTFLvL_o
    H_Price_HTFLvL := H_Price_HTFLvL_o
else 
    HAlert      := false

if LAlert_o
    LAlert      := true
    L_Index_HTFLvL := L_Index_HTFLvL_o
    L_Price_HTFLvL := L_Price_HTFLvL_o
else 
    LAlert      := false

Drawing(H_Cond, H_Index, H_Price, L_Cond, L_Index, L_Price) =>
    var line  MSH_Line  = na 
    var label MSH_Label = na
    var label MSH_Shap  = na
    var line  MSL_Line   = na
    var label MSL_Label = na
    var label MSL_Shap  = na
    var bool H_Permit = true
    var bool L_Permit = true
    ATR = ta.atr(200)
    if H_Cond and H_Permit
        H_Permit := false
        if AShow
            if HShow
                MSH_Line  := line.new(H_Index, H_Price, time, H_Price, color = HLColor , style = line.style_dashed , xloc = xloc.bar_time)
                MSH_Label := label.new(bar_index, (high + 1.15 * ATR), 'H1 Liquidity Sweep', color = #ffffff00, textcolor = HNColor, style = label.style_label_down, size = size.small)
                MSH_Shap  := label.new(bar_index, (high + 1.05 * ATR), '', color = HNColor, textcolor = #ffffff00, style = label.style_triangledown, size = size.tiny)
    if not HAlert
        H_Permit := true
    if L_Cond and L_Permit
        L_Permit := false
        if AShow
            if LShow
                MSL_Line  := line.new(L_Index, L_Price, time, L_Price, color = LLColor , style = line.style_dashed , xloc = xloc.bar_time)
                MSL_Label := label.new(bar_index, (low - 1.15 * ATR), 'H1 Liquidity Sweep', color = #ffffff00, textcolor = LNColor, style = label.style_label_up, size = size.small)
                MSL_Shap  := label.new(bar_index, (low - 1.05 * ATR), '', color = LNColor, textcolor = #ffffff00, style = label.style_triangleup, size = size.tiny)  
    if not LAlert
        L_Permit := true

// Drawing Higher TimeFrame Hunt
Drawing(HAlert, H_Index_HTFLvL, H_Price_HTFLvL, LAlert, L_Index_HTFLvL, L_Price_HTFLvL)

//MSS Detector Function

MSSLevelDetector(CondHigh, CondLow,DConditionFVG, DDFVG, DPFVG, BarDFVG, SConditionFVG, SDFVG, SPFVG, BarSFVG, Label ) =>
    ATR                      = ta.atr(55) 
    Body                     = close - open
    var float MSSLvLP_L      = 0.0
    var float MSSLvLP_H      = 0.0
    var int MSSLvLI_L        = 0
    var int MSSLvLI_H        = 0  
    var bool Permit_HSet     = true
    var bool Permit_LSet     = true
    var bool Permit_HReset   = true
    var bool Permit_LReset   = true   

    var line  MSS_LineL      = na
    var line  MSS_LineH      = na
    var label MSS_NameH      = na
    var label MSS_NameL      = na
    var label MSS_ShapH      = na
    var label MSS_ShapL      = na

    var bool Bear_Trigger    = false
    var bool Bull_Trigger    = false    
    
    var int   Bear_FVG       = 0 
    var float Bear_FVG_D     = 0.0
    var float Bear_FVG_P     = 0.0

    var int   Bull_FVG       = 0 
    var float Bull_FVG_D     = 0.0
    var float Bull_FVG_P     = 0.0

    var bool FVG_Bear_Trigger = false
    var bool FVG_Bull_Trigger = false  

    var FVG_Bear_D            = array.new_float()
    var FVG_Bear_P            = array.new_float()
    var FVG_Bear_I            = array.new_int()
    
    var FVG_Bull_D            = array.new_float()
    var FVG_Bull_P            = array.new_float()
    var FVG_Bull_I            = array.new_int()

    var float H_P = 0.0
    var int   H_I = 0
    var float L_P = 0.0
    var int   L_I = 0

    // MSS Level
    if bool(ta.pivothigh(2 , 1))
        H_P := high[1]
        H_I := bar_index[1]

    if bool(ta.pivotlow(2 , 1))
        L_P := low[1]
        L_I := bar_index[1]
  
    if CondHigh

        Permit_HSet := true 
        if Permit_HSet and H_Index_HTFLvL != H_Index_HTFLvL[1]
            Permit_HReset := true
            MSSLvLP_H := L_P
            MSSLvLI_H := L_I
            if AShow_MSS and HShow_MSS
                MSS_LineH := line.new(MSSLvLI_H, MSSLvLP_H, bar_index , MSSLvLP_H , color = HLColor_MSS, style = line.style_dotted)
                MSS_NameH := label.new(MSSLvLI_H + 1 , low[bar_index - MSSLvLI_H] - (ATR * 0.3) , Label, color = na, style = label.style_label_upper_left , textcolor = HNColor_MSS, size = size.small)
            Permit_HSet := false
    if Permit_HReset[0]  
        if SConditionFVG[0]
            FVG_Bear_I.push(BarSFVG)
            FVG_Bear_D.push(SDFVG)
            FVG_Bear_P.push(SPFVG)
        if FVG_Bear_I.size() > 0
            if high > FVG_Bear_D.get(FVG_Bear_I.size() - 1)
                FVG_Bear_I.remove(FVG_Bear_I.size() - 1)
                FVG_Bear_D.remove(FVG_Bear_D.size() - 1)
                FVG_Bear_P.remove(FVG_Bear_P.size() - 1)               

        if  close[1] >= MSSLvLP_H and (bar_index[1]  - MSSLvLI_H) <= MSS_Length
            MSS_LineH.set_x2(bar_index + 1)
            
        if  close[1]  <= MSSLvLP_H and (bar_index[1]  - MSSLvLI_H) <= MSS_Length

            Permit_HReset := false
            if AShow_MSS and HShow_MSS
                MSS_ShapH := label.new(bar_index , high + (ATR * 0.6), "", color = HNColor_MSS, style = label.style_triangledown , size = size.tiny)   

    if CondLow

        Permit_LSet := true 
        if Permit_LSet and L_Index_HTFLvL != L_Index_HTFLvL[1]
            Permit_LReset := true
            MSSLvLP_L := H_P
            MSSLvLI_L := H_I
            if AShow_MSS and LShow_MSS
                MSS_LineL := line.new(MSSLvLI_L, MSSLvLP_L, bar_index , MSSLvLP_L, color = LLColor_MSS, style = line.style_dotted)
                MSS_NameL := label.new(MSSLvLI_L + 1 , high[bar_index - MSSLvLI_L] + (ATR * 0.6) , Label, color = na, style = label.style_label_lower_right , textcolor = LNColor_MSS , size = size.small)
            Permit_LSet := false
    if Permit_LReset[0]
        if DConditionFVG[0]
            FVG_Bull_I.push(BarDFVG)
            FVG_Bull_D.push(DDFVG)
            FVG_Bull_P.push(DPFVG)
        if FVG_Bull_I.size() > 0
            if low < FVG_Bull_D.get(FVG_Bull_I.size() - 1)
                FVG_Bull_I.remove(FVG_Bull_I.size() - 1)
                FVG_Bull_D.remove(FVG_Bull_D.size() - 1)
                FVG_Bull_P.remove(FVG_Bull_P.size() - 1)   
        if  close[0]  <= MSSLvLP_L and (bar_index[0]  - MSSLvLI_L) <= MSS_Length
            MSS_LineL.set_x2(bar_index + 1)
        if  close[0]  >= MSSLvLP_L and (bar_index[0]  - MSSLvLI_L) <= MSS_Length

            Permit_LReset := false
            if AShow_MSS and LShow_MSS
                MSS_ShapL := label.new(bar_index , low - (ATR * 0.6), "", color = LNColor_MSS, style = label.style_triangleup  , size = size.tiny)
   
    //Set FVG
    if FVG_Bull_I.size() > 0 or (ta.change(FVG_Bull_I.size() > 0) and FVG_Bull_I.size() > 0)
        Bull_FVG := FVG_Bull_I.get(FVG_Bull_I.size() - 1)
        Bull_FVG_D := FVG_Bull_D.get(FVG_Bull_D.size() - 1)
        Bull_FVG_P:= FVG_Bull_P.get(FVG_Bull_P.size() - 1)
    if FVG_Bear_I.size() > 0 or (ta.change(FVG_Bear_I.size() > 0) and FVG_Bear_I.size() > 0)
        Bear_FVG := FVG_Bear_I.get(FVG_Bear_I.size() - 1)
        Bear_FVG_D := FVG_Bear_D.get(FVG_Bear_D.size() - 1)
        Bear_FVG_P := FVG_Bear_P.get(FVG_Bear_P.size() - 1)

    if Permit_HReset[1] and Permit_HReset == false
        Bear_Trigger := true 
        if FVG_Bear_I.size() > 0 and Bear_FVG != 0
            FVG_Bear_Trigger := true
        else
            FVG_Bear_Trigger := false
    else 
        Bear_Trigger := false
        FVG_Bear_Trigger := false

    if Permit_LReset[1] and Permit_LReset == false
        Bull_Trigger := true
        if FVG_Bull_I.size() > 0 and Bull_FVG != 0
            FVG_Bull_Trigger := true 
        else 
            FVG_Bull_Trigger := false                      
    else 
        Bull_Trigger := false
        FVG_Bull_Trigger := false
    //Reset FVG
    if HAlert
        Bear_FVG   := 0 
        Bear_FVG_D := 0.0
        Bear_FVG_P := 0.0
        FVG_Bear_D.clear()
        FVG_Bear_P.clear()
        FVG_Bear_I.clear()
    if LAlert
        FVG_Bull_D.clear()
        FVG_Bull_P.clear()
        FVG_Bull_I.clear()
        Bull_FVG   := 0 
        Bull_FVG_D := 0.0
        Bull_FVG_P := 0.0
    [Bull_Trigger, Bear_Trigger,FVG_Bull_Trigger, FVG_Bear_Trigger, Bull_FVG, Bear_FVG, Bull_FVG_D, Bear_FVG_D,Bull_FVG_P, Bear_FVG_P]


//FVG Call Function
[DConditionFVG, DDFVG, DPFVG, BarDFVG, SConditionFVG, SDFVG, SPFVG, BarSFVG] = FVG.FVGDetector(PFVGFilter ? 'On' : 'Off', PFVGFilterType, false, false)

//Call MSS Function
[Bull_Trigger, Bear_Trigger,FVG_Bull_Trigger, FVG_Bear_Trigger,  Bull_FVG, Bear_FVG,  Bull_FVG_D, Bear_FVG_D,Bull_FVG_P, Bear_FVG_P ] = 
 MSSLevelDetector(HAlert,LAlert ,DConditionFVG, DDFVG, DPFVG, BarDFVG, SConditionFVG, SDFVG, SPFVG, BarSFVG,'MSS')

if bar_index - Bull_FVG < 500
    [MitigationAlert_Bu, MitigationAlert_BB_Bu, ProximalPrice_BB_Bu, DistalPrice_BB_Bu, Index_BB_Bu] = Drawing.OBDrawing('Demand', FVG_Bull_Trigger   , Bull_FVG_D  , Bull_FVG_P , Bull_FVG ,true , FVG_Length  ,MLFVG ,MLFVG , true ,false ,DFVGShow, false,DFVGColor, #ffffff00) //Bull_FVG 
    Alert.AlertSender(MitigationAlert_Bu  , Son_Bull, AlertName, 'Bullish', 'Order Block Signal', 'Full' ,Frequncy, UTC, 'Off', 'Alert Demand Mitigation in Son Model ICT Setup', open, high, low, close,0,0,0, 0, 0)

if bar_index - Bear_FVG < 500
    [MitigationAlert_Be, MitigationAlert_BB_Be, ProximalPrice_BB_Be, DistalPrice_BB_Be, Index_BB_Be] = Drawing.OBDrawing('Supply', FVG_Bear_Trigger   , Bear_FVG_D  , Bear_FVG_P , Bear_FVG ,true , FVG_Length  ,MLFVG ,MLFVG , true ,false ,SFVGShow, false,SFVGColor, #ffffff00) // Bear_FVG
    Alert.AlertSender(MitigationAlert_Be  , Son_Bear, AlertName, 'Bearish', 'Order Block Signal', 'Full' ,Frequncy, UTC, 'Off', 'Alert Demand Mitigation in Son Model ICT Setup', open, high, low, close,0,0,0, 0, 0)
````
