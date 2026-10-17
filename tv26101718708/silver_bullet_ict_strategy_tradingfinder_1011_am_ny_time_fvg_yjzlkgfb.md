# Silver Bullet ICT Strategy [TradingFinder] 10-11 AM NY Time +FVG

- url: https://www.tradingview.com/script/yjZlKGfb-Silver-Bullet-ICT-Strategy-TradingFinder-10-11-AM-NY-Time-FVG/
- type: indicator
- pine_id: PUB;f626e2c361864b19acfd9175cfb3b3e8
- version: 1.0

## Description

🔵[b]Introduction[/b]

The ICT Silver Bullet trading strategy is a precise, time-based algorithmic approach that relies on Fair Value Gaps and Liquidity to identify high-probability trade setups. The strategy primarily focuses on the New York AM Session from 10:00 AM to 11:00 AM, leveraging heightened market activity within this critical window to capture short-term trading opportunities. 

As an intraday strategy, it is most effective on lower timeframes, with ICT recommending a 15-minute chart or lower. While experienced traders often utilize 1-minute to 5-minute charts, beginners may find the 1-minute timeframe more manageable for applying this strategy.

This approach specifically targets quick trades, designed to take advantage of market movements within tight one-hour windows. By narrowing its focus, the Silver Bullet offers a streamlined and efficient method for traders to capitalize on liquidity shifts and price imbalances with precision.

In the fast-paced world of forex trading, the ability to identify market manipulation and false price movements is crucial for traders aiming to stay ahead of the curve. The Silver Bullet Indicator simplifies this process by integrating ICT principles such as liquidity traps, Order Blocks, and Fair Value Gaps (FVG). 

These concepts form the foundation of a tool designed to mimic the strategies of institutional players, empowering traders to align their trades with the "smart money." By transforming complex market dynamics into actionable insights, the Silver Bullet Indicator provides a powerful framework for short-term trading success

[i]Silver Bullet Bullish Setup[/i]:

[image]https://www.tradingview.com/x/FQ82zjMs/[/image]

[i]Silver Bullet Bearish Setup[/i]:

[image]https://www.tradingview.com/x/IHbs47Lm/[/image]


🔵[b]How to Use[/b]

The Silver Bullet Indicator is a specialized tool that operates within the critical time windows of 9:00-10:00 and 10:00-11:00 in the forex market. Its design incorporates key principles from ICT (Inner Circle Trader) methodology, focusing on concepts such as liquidity traps, CISD Levels, Order Blocks, and Fair Value Gaps (FVG) to provide precise and actionable trade setups.

🟣[b]Bullish Setup[/b]

In a bullish setup, the indicator starts by marking the high and low of the session, serving as critical reference points for liquidity. A typical sequence involves a liquidity grab below the low, where the price manipulates retail traders into selling positions by breaching a key support level. 

This movement is often orchestrated by smart money to accumulate buy orders. Following this liquidity grab, a market structure shift (MSS) occurs, signaled by the price breaking the CISD Level—a confirmation of bullish intent. The indicator then highlights an Order Block near the CISD Level, representing the zone where institutional buying is concentrated. 

Additionally, it identifies a Fair Value Gap, which acts as a high-probability area for price retracement and trade entry. Traders can confidently take long positions when the price revisits these zones, targeting the next significant liquidity pool or resistance level.

[i]Bullish Setup in [symbol="CAPITALCOM:US100"]CAPITALCOM:US100[/symbol][/i]: 

[image]https://www.tradingview.com/x/ALFgWe7D/[/image]

🟣[b]Bearish Setup[/b]

Conversely, in a bearish setup, the price manipulates liquidity by creating a false breakout above the high of the session. This move entices retail traders into long positions, allowing institutional players to enter sell orders.

 Once the price reverses direction and breaches the CISD Level to the downside, a change of character (CHOCH) becomes evident, confirming a bearish market structure. The indicator highlights an Order Block near this level, indicating the origin of the institutional sell orders, along with an associated FVG, which represents an imbalance zone likely to be revisited before the price continues downward. 

By entering short positions when the price retraces to these levels, traders align their strategies with the anticipated continuation of bearish momentum, targeting nearby liquidity voids or support zones.

[i]Bearish Setup in [symbol="OANDA:XAUUSD"]OANDA:XAUUSD[/symbol][/i]:

[image]https://www.tradingview.com/x/TFulmDM0/[/image]

🔵[b]Settings[/b]

[i]Refine Order Block[/i]: Enables finer adjustments to Order Block levels for more accurate price responses. 

[i]Mitigation Level OB[/i]: Allows users to set specific reaction points within an Order Block, including: Proximal: Closest level to the current price. 50% OB: Midpoint of the Order Block. Distal: Farthest level from the current price.

[i]FVG Filter[/i]: The Judas Swing indicator includes a filter for Fair Value Gap (FVG), allowing different filtering based on FVG width: FVG Filter Type: Can be set to "Very Aggressive," "Aggressive," "Defensive," or "Very Defensive." Higher defensiveness narrows the FVG width, focusing on narrower gaps. 

[i]Mitigation Level FVG[/i]: Like the Order Block, you can set price reaction levels for FVG with options such as Proximal, 50% OB, and Distal.

[i]CISD[/i]: The Bar Back Check option enables traders to specify the number of past candles checked for identifying the CISD Level, enhancing CISD Level accuracy on the chart.


🔵[b]Conclusion[/b]

The Silver Bullet Indicator is a cutting-edge tool designed specifically for forex traders who aim to leverage market dynamics during critical liquidity windows. By focusing on the highly active 9:00-10:00 and 10:00-11:00 timeframes, the indicator simplifies complex market concepts such as liquidity traps, Order Blocks, Fair Value Gaps (FVG), and CISD Levels, transforming them into actionable insights.

What sets the Silver Bullet Indicator apart is its precision in detecting false breakouts and market structure shifts (MSS), enabling traders to align their strategies with institutional activity. The visual clarity of its signals, including color-coded zones and directional arrows, ensures that both novice and experienced traders can easily interpret and apply its findings in real-time.

By integrating ICT principles, the indicator empowers traders to identify high-probability entry and exit points, minimize risk, and optimize trade execution. Whether you are capturing short-term price movements or navigating complex market conditions, the Silver Bullet Indicator offers a robust framework to enhance your trading performance.

Ultimately, this tool is more than just an indicator; it is a strategic ally for traders who seek to decode the movements of smart money and capitalize on institutional strategies. With the Silver Bullet Indicator, traders can approach the market with greater confidence, precision, and profitability.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TFlab

//@version=5
indicator("Silver Bullet ICT Strategy [TradingFinder] 10-11 AM NY Time +FVG","TFlab Silver Bullet", overlay = true, max_bars_back = 5000, max_lines_count = 500 , max_labels_count = 500)

//import Libraries
    //import Order Block Refiner
import TFlab/OrderBlockRefiner_TradingFinder/2 as Refiner
    //import Order Block Drawing  Library
import TFlab/OrderBlockDrawing_TradingFinder/4 as Drawing
    //import FVD Detector Library
import TFlab/FVGDetectorLibrary/3 as FVG

//Input 
    //Order Blocks Refinement

Refine= input.bool(true, 'Refine Order Block', group ='Order Blocks Logical Setting', inline = 'Refine')
RefineMe = input.string('Defensive', '', ['Defensive', 'Aggressive'] , group = 'Order Blocks Logical Setting', inline = 'Refine')
MLOB = input.string('Proximal' , 'Mitigation Level OB', ['Proximal', '50 % OB', 'Distal'], 
 tooltip= 'Using this entry, you can determine which level the price reacts to in a Order Block.', group = 'Order Blocks Logical Setting')

    //FVG Filter

PFVGFilter = input.bool(false, 'FVG Filter ............',  group = 'FVG Logical Setting' , inline = 'FVG Filter')
PFVGFilterType = input.string('Defensive', '', ['Very Aggressive' , 'Aggressive' , 'Defensive' , 'Very Defensive'], group = 'FVG Logical Setting', inline = 'FVG Filter' ,
 tooltip = 'If it is "On", this filter will filter "FVGs" based on the width of the Zone.'  + 
 'From "Very Aggressive" to "Very Defensive" the width of the "FVG" decreases.')
MLFVG = input.string('Proximal' , 'Mitigation Level FVG', ['Proximal', '50 % OB', 'Distal'], 
 tooltip= 'Using this entry, you can determine which level the price reacts to in a FVG.', group = 'FVG Logical Setting')

    //CISD Logical Setting

BarBackCheck        = input.int(5, 'Bar Back Check' , minval = 1,group = 'CISD Logical Setting')


    //Display Order Block

DOBShow  = input.bool(true, 'Demand Order Block', inline = 'DMOLB', group = 'Order Block Display Setting')
DOBColor = input.color(#17c0016b, '', inline = 'DMOLB', group = 'Order Block Display Setting')

SOBShow  = input.bool(true, 'Supply Order Block', inline = 'SSOLB', group = 'Order Block Display Setting')
SOBColor = input.color(#df050573, '', inline = 'SSOLB', group = 'Order Block Display Setting')

    //Display FVG

DFVGShow  = input.bool(true, 'Demand FVG', inline = 'DFVG', group = 'FVG Display Setting')
DFVGColor = input.color(#2195f36c, '', inline = 'DFVG', group = 'FVG Display Setting')

SFVGShow  = input.bool(true, 'Supply FVG', inline = 'SFVG', group = 'FVG Display Setting')
SFVGColor = input.color(#ff990070, '', inline = 'SFVG', group = 'FVG Display Setting')

//CISD Display Setting

CISD_AShow          = input.bool(true, 'Show All CISD'  ,group = 'CISD Display Setting')
CISD_HShow          = input.bool(true, 'Show High CISD' ,group = 'CISD Display Setting', inline = 'CH')
CISD_LShow          = input.bool(true, 'Show Low CISD'  ,group = 'CISD Display Setting', inline = 'CL')
CISD_HNColor        = input.color(#870505   , 'Name'  ,group = 'CISD Display Setting', inline = 'CH')
CISD_LNColor        = input.color(#014f07   , 'Name'  ,group = 'CISD Display Setting', inline = 'CL')
CISD_HLColor        = input.color(#b90000b8 , 'Line'  ,group = 'CISD Display Setting', inline = 'CH')
CISD_LLColor        = input.color(#069206a7 , 'Line'  ,group = 'CISD Display Setting', inline = 'CL')


//Range Time
Newyork_OpeningRange  = '0900-1000'
Newyork_Trading       = '1000-1100'

Newyork_OR = math.sign(nz(time(timeframe.period, Newyork_OpeningRange , "America/New_York")))
Newyork_T = math.sign(nz(time(timeframe.period, Newyork_Trading       , "America/New_York")))

var line Start_OR_Line     = na
var line Start_Trade_Line  = na
var line End_Trade_Line    = na
var line High_Level        = na
var line Low_Level         = na
var label Opening_Label    = na
var label Trading_label    = na

one_hour = 60 * 60 * 1000
ATR = ta.atr(55)

//High & Low Session Detector 

LowHighSessionDetector(On_Session) =>
    var int Time = 0
    var float High = 0.0 
    var float Low = 0.0
 
    if  (On_Session[1] == 0 and On_Session == 1)
        Time := time
        High := high
        Low := low
    else if (On_Session[1] == 1 or On_Session == 1)
        High := math.max(high , High) 
        Low :=   math.min(low , Low)
    [High , Low , Time]

[High_OR , Low_OR , Time_OR] = LowHighSessionDetector(Newyork_OR)

if Newyork_OR > Newyork_OR[1]
    Start_OR_Line     := line.new(time , low, time , low + ATR, xloc = xloc.bar_time, extend = extend.both, style = line.style_dashed, color = color.black)
    Start_Trade_Line  := line.new(time + one_hour, low, time + one_hour, low + ATR, xloc = xloc.bar_time, extend = extend.both, style = line.style_dashed, color = color.black)
    End_Trade_Line    := line.new(time + (one_hour * 2), low, time + (one_hour * 2), low + ATR, xloc = xloc.bar_time, extend = extend.both, style = line.style_dashed, color = color.black)
    Opening_Label     := label.new(time + one_hour / 2, high + 10 * ATR , '09:00 to 10:00 Range' + '\nNew York AM', xloc = xloc.bar_time, color = na, textcolor= #000000)
    Trading_label     := label.new(time + int(one_hour * 1.5),  high + 10 * ATR, '10:00 to 11:00 Trading Time' + '\nNew York AM', xloc = xloc.bar_time, color = na, textcolor= #000000)

if Newyork_T > Newyork_T[1]
    High_Level := line.new(time - one_hour , High_OR , time + one_hour , High_OR, xloc = xloc.bar_time , style = line.style_dotted, color = #000000)
    Low_Level  := line.new(time - one_hour , Low_OR  , time + one_hour  , Low_OR, xloc = xloc.bar_time , style = line.style_dotted, color = #000000)

var bool Permit_Break = true
var bool High_Break   = false
var bool Low_Break    = false

var int  High_Break_Bar = na
var int  Low_Break_Bar  = na

if Newyork_T == 0
    High_Break := false
    Low_Break  := false
    High_Break_Bar := na
    Low_Break_Bar  := na

if Newyork_T == 1 
    if high > High_OR
        High_Break := true

    if low < Low_OR
        Low_Break  := true

//FVG Call Function
[DConditionFVG, DDFVG, DPFVG, BarDFVG, SConditionFVG, SDFVG, SPFVG, BarSFVG] = FVG.FVGDetector(PFVGFilter ? 'On' : 'Off', PFVGFilterType, false, false)

//CISD Detector Function

CISDLevelDetector(CondHigh, CondLow,Newyork_OR ,Newyork_T ,DConditionFVG, DDFVG, DPFVG, BarDFVG, SConditionFVG, SDFVG, SPFVG, BarSFVG, BarBackCheck, Label, AShow, HShow, LShow, HNColor, LNColor , HLColor, LLColor) =>
    var float CISDLvLP_L      = 0.0
    var float CISDLvLP_H      = 0.0
    var int CISDLvLI_L        = 0
    var int CISDLvLI_H        = 0  
    var bool Permit_HSet      = true
    var bool Permit_LSet      = true
    var bool Permit_HReset    = true
    var bool Permit_LReset    = true   

    var line  CISD_LineL      = na
    var line  CISD_LineH      = na
    var label CISD_NameH      = na
    var label CISD_NameL      = na
    var label CISD_ShapH      = na
    var label CISD_ShapL      = na

    var bool Bear_Trigger     = false
    var bool Bull_Trigger     = false    
    
    var int   Bear_FVG        = 0 
    var float Bear_FVG_D      = 0.0
    var float Bear_FVG_P      = 0.0

    var int   Bull_FVG        = 0 
    var float Bull_FVG_D      = 0.0
    var float Bull_FVG_P      = 0.0

    var bool FVG_Bear_Trigger = false
    var bool FVG_Bull_Trigger = false  

    var FVG_Bear_D            = array.new_float()
    var FVG_Bear_P            = array.new_float()
    var FVG_Bear_I            = array.new_int()
    
    var FVG_Bull_D            = array.new_float()
    var FVG_Bull_P            = array.new_float()
    var FVG_Bull_I            = array.new_int()

    var float High_OB         = na
    var float Low_OB          = na

    var float Bear_D          = na
    var float Bear_P          = na
    var int   Bear_I          = na
    
    var float Bull_D          = na
    var float Bull_P          = na
    var int   Bull_I          = na

    Body                      = close - open


    if (Newyork_T[1] == 0 and  Newyork_T == 1)
        High_OB := high
        Bear_I  := bar_index
        Low_OB  := low
        Bull_I  := bar_index

    if  Newyork_T[1] == 1 
        if high > High_OB 
            High_OB := high
            Bear_I  := bar_index
        if low < Low_OB 
            Low_OB := low
            Bull_I  := bar_index

    if CondHigh

        Permit_HSet := true
        for i = 1 to BarBackCheck by 1
            if Body[i] < 0 and Permit_HSet
                Permit_HReset := true
                CISDLvLP_H := (BarBackCheck > 1 and i > 1) ? math.min(open[i - 1], open[i - 2]) : open[i - 1]
                CISDLvLI_H := (BarBackCheck > 1 and i > 1) ? (math.min(open[i - 1], open[i - 2]) == open[i - 2]) ? bar_index[i - 2] : bar_index[i - 1] : bar_index[i - 1]
                if AShow and HShow
                    CISD_LineH := line.new(CISDLvLI_H, CISDLvLP_H, bar_index , CISDLvLP_H , color = #890505, style = line.style_dotted)
                    CISD_NameH := label.new(CISDLvLI_H + 1 , low[bar_index - CISDLvLI_H] - (ATR * 0.3) , Label, color = na, style = label.style_label_upper_left , textcolor = #890505, size = size.tiny)
                Permit_HSet := false
    if Permit_HReset and Newyork_T == 1 
        if SConditionFVG
            FVG_Bear_I.push(BarSFVG)
            FVG_Bear_D.push(SDFVG)
            FVG_Bear_P.push(SPFVG)
        if FVG_Bear_I.size() > 0
            if high > FVG_Bear_P.get(FVG_Bear_I.size() - 1)
                FVG_Bear_I.remove(FVG_Bear_I.size() - 1)
                FVG_Bear_D.remove(FVG_Bear_D.size() - 1)
                FVG_Bear_P.remove(FVG_Bear_P.size() - 1)               

        if  close >= CISDLvLP_H and (bar_index - CISDLvLI_H) <= 90
            CISD_LineH.set_x2(bar_index + 1)
            
        if  close <= CISDLvLP_H and (bar_index - CISDLvLI_H) <= 90

            Permit_HReset := false
            if AShow and HShow
                CISD_ShapH := label.new(bar_index , high + (ATR * 0.6), "", color = #890505, style = label.style_triangledown , size = size.tiny)   

    if CondLow

        Permit_LSet := true
        for i = 1 to BarBackCheck by 1
            if Body[i] > 0 and Permit_LSet
                Permit_LReset := true
                CISDLvLP_L := (BarBackCheck > 1  and i > 1) ? math.max(open[i - 1], open[i - 2]) : open[i - 1]
                CISDLvLI_L := (BarBackCheck > 1  and i > 1) ? (math.max(open[i - 1], open[i - 2]) == open[i - 2]) ? bar_index[i - 2] : bar_index[i - 1] : bar_index[i - 1]
                if AShow and LShow
                    CISD_LineL := line.new(CISDLvLI_L, CISDLvLP_L, bar_index , CISDLvLP_L, color = #016004, style = line.style_dotted)
                    CISD_NameL := label.new(CISDLvLI_L + 1 , high[bar_index - CISDLvLI_L] + (ATR * 0.6) , Label, color = na, style = label.style_label_lower_right , textcolor = #016004 , size = size.tiny)
                Permit_LSet := false
    if Permit_LReset and Newyork_T == 1
        if DConditionFVG
            FVG_Bull_I.push(BarDFVG)
            FVG_Bull_D.push(DDFVG)
            FVG_Bull_P.push(DPFVG)
        if FVG_Bull_I.size() > 0
            if low < FVG_Bull_P.get(FVG_Bull_I.size() - 1)
                FVG_Bull_I.remove(FVG_Bull_I.size() - 1)
                FVG_Bull_D.remove(FVG_Bull_D.size() - 1)
                FVG_Bull_P.remove(FVG_Bull_P.size() - 1)   
        if  close <= CISDLvLP_L and (bar_index - CISDLvLI_L) <= 90
            CISD_LineL.set_x2(bar_index + 1)
        if  close >= CISDLvLP_L and (bar_index - CISDLvLI_L) <= 90

            Permit_LReset := false
            if AShow and LShow
                CISD_ShapL := label.new(bar_index , low - (ATR * 0.6), "", color = #016004, style = label.style_triangleup  , size = size.tiny)
   
    if Newyork_T == 1
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
 
    if Newyork_T[1] == 0 and Newyork_T[2] == 1
        Bear_FVG   := 0 
        Bear_FVG_D := 0.0
        Bear_FVG_P := 0.0
        Bull_FVG   := 0 
        Bull_FVG_D := 0.0
        Bull_FVG_P := 0.0
        High_OB    := na
        Low_OB     := na       
        Bear_D     := na
        Bear_P     := na
        Bear_I     := na
        Bull_D     := na
        Bull_P     := na
        Bull_I     := na
        FVG_Bear_D.clear()
        FVG_Bear_P.clear()
        FVG_Bear_I.clear()
        FVG_Bull_D.clear()
        FVG_Bull_P.clear()
        FVG_Bull_I.clear()

    [Bull_Trigger, Bear_Trigger,FVG_Bull_Trigger, FVG_Bear_Trigger, Bull_FVG, Bear_FVG, Bull_FVG_D, Bear_FVG_D,Bull_FVG_P, Bear_FVG_P,Bull_I, Bear_I, Bull_D, Bear_D, Bull_P, Bear_P ]


Cond_High = (Newyork_T == 1 ) and (High_Break and not High_Break[1]) and not Low_Break
Cond_Low  = (Newyork_T == 1 ) and (Low_Break and not Low_Break[1])   and not High_Break

//Call CISD Function
[Bull_Trigger, Bear_Trigger,FVG_Bull_Trigger, FVG_Bear_Trigger,  Bull_FVG, Bear_FVG,  Bull_FVG_D, Bear_FVG_D,Bull_FVG_P, Bear_FVG_P,Bull_I, Bear_I, Bull_D, Bear_D, Bull_P, Bear_P ] = 
 CISDLevelDetector(Cond_High,Cond_Low ,Newyork_OR ,Newyork_T ,DConditionFVG, DDFVG, DPFVG, BarDFVG, SConditionFVG, SDFVG, SPFVG, BarSFVG, 120, 'CISD level', 
 CISD_AShow, CISD_HShow, CISD_LShow, CISD_HNColor, CISD_LNColor , CISD_HLColor, CISD_LLColor)

[Bu_Xd1, Bu_Xd2, Bu_Yd12, Bu_Xp1, Bu_Xp2, Bu_Yp12] = 
 Refiner.OBRefiner('Demand', Refine ? 'On' : 'Off', RefineMe,Bull_Trigger , Bull_I) //and not Bull_FVG 

[Be_Xd1, Be_Xd2, Be_Yd12, Be_Xp1, Be_Xp2, Be_Yp12] = 
 Refiner.OBRefiner('Supply', Refine ? 'On' : 'Off', RefineMe ,Bear_Trigger ,  Bear_I) // and not Bear_FVG 

[Alert_DAMM, Alert_SAMMbb, PASBB, DASBB, IASBB] = Drawing.OBDrawing('Demand', Bull_Trigger  , Bu_Yd12, Bu_Yp12, Bu_Xd1, Newyork_T == 1, 60 ,MLOB ,MLOB , true, false, DOBShow, false, DOBColor, #ffffff00) // and not Bull_FVG 11
[Alert_SMMM, Alert_DMMMbb, PMDBB, DMDBB, IMDBB] = Drawing.OBDrawing('Supply', Bear_Trigger  , Be_Yd12, Be_Yp12, Be_Xd1, Newyork_T == 1, 60 ,MLOB ,MLOB , true, false, SOBShow, false, SOBColor, #ffffff00) //  and not Bear_FVG  

Drawing.OBDrawing('Demand', FVG_Bull_Trigger   , Bull_FVG_D  , Bull_FVG_P , Bull_FVG ,Newyork_T == 1 , 60  ,MLFVG ,MLFVG , true ,false ,DFVGShow, false,DFVGColor, #ffffff00) //Bull_FVG 
Drawing.OBDrawing('Supply', FVG_Bear_Trigger   , Bear_FVG_D  , Bear_FVG_P , Bear_FVG, Newyork_T == 1 , 60  ,MLFVG ,MLFVG , true ,false ,SFVGShow, false,SFVGColor, #ffffff00) // Bear_FVG
````
