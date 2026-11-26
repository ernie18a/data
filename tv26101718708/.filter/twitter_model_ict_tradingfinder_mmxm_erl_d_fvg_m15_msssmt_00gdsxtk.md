# Twitter Model ICT [TradingFinder] MMXM ERL D + FVG + M15 MSS/SMT

- url: https://www.tradingview.com/script/00gdsxtk-Twitter-Model-ICT-TradingFinder-MMXM-ERL-D-FVG-M15-MSS-SMT/
- type: indicator
- pine_id: PUB;dfc33e211c0648cab92a294eb625a004
- version: 2.0

## Description

🔵[b]Introduction[/b]

The Twitter Model ICT is a trading approach based on ICT (Inner Circle Trader) models, focusing on price movement between external and internal liquidity in lower timeframes. This model integrates key concepts such as Market Structure Shift (MSS), Smart Money Technique (SMT) divergence, and CISD level break to identify precise entry points in the market.

The primary goal of this model is to determine key liquidity levels, such as the previous day’s high and low (PDH/PDL) and align them with the Fair Value Gap (FVG) in the 1-hour timeframe. The overall strategy involves framing trades around the 1H FVG and using the M15 Market Structure Shift (MSS) for entry confirmation. 

The Twitter Model ICT is designed to utilize external liquidity levels, such as PDH/PDL, as key entry zones. The model identifies FVG in the 1-hour timeframe, which acts as a magnet for price movement. Additionally, traders confirm entries using M15 Market Structure Shift (MSS) and SMT divergence. 

[i]Bullish Twitter Model[/i]:

In a bullish setup, the price sweeps the previous day’s low (PDL), and after confirming reversal signals, buys are executed in internal liquidity zones. Conversely, in a bearish setup, the price sweeps the previous day’s high (PDH), and after confirming weakness signals, sells are executed.

[image]https://www.tradingview.com/x/EsyNnZkR/[/image]


[i]Bearish Twitter Model[/i]:

In short setups, entries are only executed above the Midnight Open, while in long setups, entries are taken below the Midnight Open. Adhering to these principles allows traders to define precise entry and exit points and analyze price movement with greater accuracy based on liquidity and market structure.

[image]https://www.tradingview.com/x/lr3pRN0F/[/image]


🔵[b]How to Use[/b]

The Twitter Model ICT is a liquidity-based trading strategy that analyzes price movements relative to the previous day’s high and low (PDH/PDL) and Fair Value Gap (FVG). This model is applicable in both bullish and bearish directions and utilizes the 1-hour (1H) and 15-minute (M15) timeframes for entry confirmation. 

The price first sweeps an external liquidity level (PDH or PDL) and then provides an entry opportunity based on Market Structure Shift (MSS) and SMT divergence. Additionally, the entry should be positioned relative to the Midnight Open, meaning long entries should occur below the Midnight Open and short entries above it.

🟣[b]Bullish Twitter Model[/b]

In a bullish setup, the price first sweeps the previous day’s low (PDL) and reaches an external liquidity level. Then, in the 1-hour timeframe (1H), a bullish Fair Value Gap (FVG) forms, which serves as the price target. 

To confirm the entry, a Market Structure Shift (MSS) in the 15-minute timeframe (M15) should be observed, signaling a trend reversal to the upside. Additionally, SMT divergence with correlated assets can indicate weakness in selling pressure. 

Under these conditions, a long position is taken below the Midnight Open, with a stop-loss placed at the lowest point of the recent bearish move. The price target for this trade is the FVG in the 1-hour timeframe.

[image]https://www.tradingview.com/x/87hljquZ/[/image]

🟣[b]Bearish Twitter Model[/b]

In a bearish setup, the price first sweeps the previous day’s high (PDH) and reaches an external liquidity level. Then, in the 1-hour timeframe (1H), a bearish Fair Value Gap (FVG) is identified, serving as the trade target. 

To confirm entry, a Market Structure Shift (MSS) in the 15-minute timeframe (M15) should form, signaling a trend shift to the downside. If an SMT divergence is present, it can provide additional confirmation for the trade. 

Once these conditions are met, a short position is taken above the Midnight Open, with a stop-loss placed at the highest level of the recent bullish move. The trade's price target is the FVG in the 1-hour timeframe.

[image]https://www.tradingview.com/x/6TfP1drq/[/image]

🔵[b]Settings[/b]


[i]Bar Back Check[/i]: Determining the return of candles to identify the CISD level.

[i]CISD Level Validity[/i]: CISD level validity period based on the number of candles.

[i]Daily Position[/i]: Determines whether only the first signal of the day is considered or if signals are evaluated throughout the entire day.

[i]Session[/i]: Specifies in which trading sessions the indicator will be active.

[i]Second Symbol[/i]: This setting allows you to select another asset for comparison with the primary asset. By default, "XAUUSD" (Gold) is set as the second symbol, but you can change it to any currency pair, stock, or cryptocurrency. For example, you can choose currency pairs like EUR/USD or GBP/USD to identify divergences between these two assets.

[i]Divergence Fractal Periods[/i]: This parameter defines the number of past candles to consider when identifying divergences. The default value is 2, but you can change it to suit your preferences. This setting allows you to detect divergences more accurately by selecting a greater number of candles.

[i]The indicator allows displaying sessions based on various time zones. The user can select one of the following options[/i]:

[list]
[*]UTC (Coordinated Universal Time)
[*]Local Time of the Session
[*]User’s Local Time
[/list]

[i]Show Open Price[/i]: Displays the New York market opening price.

[i]Show PDH / PDL[/i]: Displays the previous day’s high and low to identify potential entry points.

[i]Show SMT Divergence[/i]: Displays lines and labels for bullish ("+SMT") and bearish ("-SMT") divergences.


🔵[b]Conclusion[/b]

The Twitter Model ICT is an effective approach for analyzing and executing trades in financial markets, utilizing a combination of liquidity principles, market structure, and SMT confirmations to identify optimal entry and exit points. 

By analyzing the previous day’s high and low (PDH/PDL), Fair Value Gaps (FVG), and Market Structure Shift (MSS) in the 1H and M15 timeframes, traders can pinpoint liquidity-driven trade opportunities. Additionally, considering the Midnight Open level helps traders avoid random entries and ensures better trade placement.

By applying this model, traders can interpret market movements based on liquidity flow and structural changes, allowing them to fine-tune their trading decisions with higher precision. Ultimately, the Twitter Model ICT provides a structured and logical approach for traders who seek to trade based on liquidity behavior and trend shifts in the market.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TFlab

//@version=5

indicator("Twitter Model ICT [TradingFinder] MMXM ERL D + FVG + M15 MSS/SMT", "Twitter Model TFlab", overlay = true, max_bars_back = 5000, max_labels_count = 500, max_lines_count = 500)

//import Libraries
    //Import Library
import TFlab/AlertSenderLibrary_TradingFinder/1 as Alert

//Logical Setting
BarBackCheck        = input.int(5, 'Bar Back Check' , minval = 1,group = 'Logical Setting')
CISDVal             = input.int(25, 'CISD Level Validity' , minval = 1,group = 'Logical Setting')
DailyPosition = input.string('First', 'Daily Position', ['First', 'All Day'],group = 'Logical Setting')
Session_List = input.string('Every Session', 'Session', ['None','Every Session' ,'Sydney','Tokyo' ,'Shanghai' ,'London' ,'NewYork' ,'NYSE'],group = 'Logical Setting')
Sym = input.symbol('XAUUSD' , 'Second Symbol for SMT', group = 'Logical Setting')
n = input.int(4, title  ="SMT Fractal Periods", minval=1 , group = 'Logical Setting')

//Session Setting
MarketMode = 'TFlab suggestion'
TimeZoneMode = input.string('UTC', 'Time Zone Mode', options = ['UTC', 'Session Local Time', 'Your Time Zone'],group = 'Session Setting')
YourTZ = input.string('UTC-4:00', 'Your Time Zone',group = 'Session Setting')
CustomTZ = input.string('UTC-4:00', 'Custom Time Zone',group = 'Session Setting')

//Display Setting
Open_Show         = input.bool(true, 'Show Open Price' ,group = 'Display Setting', inline = 'Open')
Open_Color          = input.color(#000000   , ''  ,group = 'Display Setting', inline = 'Open')
PD_HShow          = input.bool(true, 'Show PDH' ,group = 'Display Setting', inline = 'PDH')
PD_LShow          = input.bool(true, 'Show PDL'  ,group = 'Display Setting', inline = 'PDL')
PD_HNColor        = input.color(#000000   , ''  ,group = 'Display Setting', inline = 'PDH')
PD_LNColor        = input.color(#000000   , ''  ,group = 'Display Setting', inline = 'PDL')


CISD_AShow          = input.bool(true, 'Show All CISD'  ,group = 'Display Setting')
CISD_HShow          = input.bool(true, 'Show High CISD' ,group = 'Display Setting', inline = 'CH')
CISD_LShow          = input.bool(true, 'Show Low CISD'  ,group = 'Display Setting', inline = 'CL')
CISD_HNColor        = input.color(#870505   , 'Name'  ,group = 'Display Setting', inline = 'CH')
CISD_LNColor        = input.color(#014f07   , 'Name'  ,group = 'Display Setting', inline = 'CL')
CISD_HLColor        = input.color(#b90000b8 , 'Line'  ,group = 'Display Setting', inline = 'CH')
CISD_LLColor        = input.color(#069206a7 , 'Line'  ,group = 'Display Setting', inline = 'CL')

Bull_Line   = input.bool(true   , 'Show SMT Divergence Line from the Bottom.') 
Bull_Label  = input.bool(false  , 'Show SMT Divergence Label from the Bottom.') 
Bear_Line   = input.bool(true   , 'Show SMT Divergence Line from the Top.') 
Bear_Label  = input.bool(false  , 'Show SMT Divergence Label from the Top.') 

   //Alert
Alert = input.string('On', 'Alert', ['On', 'Off'], 'If you turn on the Alert, you can receive alerts and notifications after setting the "Alert".', group = 'Alert')
AlertName = input.string('Twitter Model [TradingFinder]', 'Alert Name', group = 'Alert')
Frequncy = input.string('Once Per Bar' , 'Message Frequency' , ['All', 'Once Per Bar' , 'Per Bar Close'], 'The triggering frequency. Possible values are: All'+ 
 ' (all function calls trigger the alert), Once Per Bar (the first function call during the bar triggers the alert), ' +  
 ' Per Bar Close (the function call triggers the alert only when it occurs during the last script iteration of the real-time bar,' +  
 ' when it closes). The default is alert.freq_once_per_bar.)', group = 'Alert')
UTC = input.string('UTC' , 'Show Alert time by Time Zone', group = 'Alert')
MessageBull = input.text_area('Long Signal Position Based on Twitter Model' , 'Long Position Message' , group = 'Alert') 
MessageBear = input.text_area('Short Signal Position Based on Twitter Model', 'Short Position Message',group = 'Alert')

//Calculation

ATR = ta.atr(55)
Body = close - open

var float NY_Open_Price = 0.0
var int   NY_Open_Time  = 0
var bool Permit_HGlobal = true 
var bool Permit_LGlobal = true

var float CISDLvLP_L  = 0.0
var float CISDLvLP_H  = 0.0
var int CISDLvLI_L    = 0
var int CISDLvLI_H    = 0  
var bool Permit_HSet  = true
var bool Permit_LSet  = true
var bool Permit_HReset = true
var bool Permit_LReset = true  

var line  CISD_LineL  = na
var line  CISD_LineH  = na
var label CISD_NameH  = na
var label CISD_NameL  = na
var label CISD_ShapH  = na
var label CISD_ShapL  = na

var line PDH_Line   = na
var line PDL_Line   = na
var label PDH_Label = na
var label PDL_Label = na

var line  Open_Line  = na
var label Open_Label = na

//Session

    //Daylight Saving Time
DST_Detector(Start_Month, Start_Day, Start_CountDay, End_Month, End_Day, End_CountDay, TimeZone) =>
    var int StartCountDay = 0
    var int EndCountDay   = 0
    var bool S_PermitCount = true
    var bool E_PermitCount = true
    var bool SS_PermitCount = true
    var bool EE_PermitCount = true
    var int S = Start_CountDay
    var int E = End_CountDay   
    Y = year
    M = month
    D = dayofweek
    //dayofmonth counter
    if M[1] != M
        StartCountDay := 0
        EndCountDay   := 0
        SS_PermitCount := true
        EE_PermitCount := true       
    if D[1] != D
        S_PermitCount := true
        E_PermitCount := true

    if D == Start_Day and S_PermitCount
        StartCountDay  := StartCountDay + 1
        S_PermitCount := false

    if D == End_Day and E_PermitCount
        EndCountDay    := EndCountDay + 1
        E_PermitCount := false
    if Start_CountDay < 4 and SS_PermitCount == true
        S := Start_CountDay
    else if Start_CountDay == 4 and SS_PermitCount == true
        if StartCountDay < 4
            S := 4
        else if (StartCountDay[1] == 3 and StartCountDay == 4) and dayofmonth > 23
            S := 4
            SS_PermitCount := false
        else 
            S := 5
    
    if End_CountDay < 4 and EE_PermitCount == true
        E := End_CountDay
    else if End_CountDay == 4 and EE_PermitCount == true
        if EndCountDay < 4
            E := 4
        else if (EndCountDay[1] == 3 and EndCountDay == 4) and dayofmonth > 23
            E := 4
            EE_PermitCount := false
        else 
            E := 5

    if  M == Start_Month and StartCountDay >= S
     or  (M > Start_Month and M < End_Month)
     or M == End_Month and  EndCountDay < E 
        TimeZone == "Australia/Sydney" ? 'Inactive' : 'Active'
    else 
        TimeZone == "Australia/Sydney" ? 'Active' : 'Inactive'
    
Sydney_DST  = DST_Detector(4  , dayofweek.sunday, 1, 10 , dayofweek.sunday, 1, "Australia/Sydney")
London_DST  = DST_Detector(3  , dayofweek.sunday, 4, 10 , dayofweek.sunday, 4,    "Europe/London")
NewYork_DST = DST_Detector(3  , dayofweek.sunday, 2, 11 , dayofweek.sunday, 1, "America/New_York")

    //Session Timing
Market_TimeZone_Calculator(MarketMode, TimeZoneMode) =>
    var string Sydney   = na
    var string Tokyo    = na
    var string Shanghai = na
    var string Asia     = na
    var string Europe   = na
    var string London   = na
    var string NewYork  = na
    var string NYSE     = na

    if TimeZoneMode == 'UTC'
        if Sydney_DST == 'Inactive'
            Sydney   := '2300-0500'
            Asia     := '2300-0600'

        else if Sydney_DST == 'Active'
            Sydney   := '2200-0400'
            Asia     := '2200-0600'


        if London_DST == 'Inactive'
            Europe   := '0700-1600'
            London   := '0800-1600'

        else if London_DST == 'Active'
            Europe   := '0600-1500'
            London   := '0700-1500'


        if NewYork_DST == 'Inactive'
            NewYork  := '1300-2100'
            NYSE     := '1430-2100'
        else if NewYork_DST == 'Active'
            NewYork  := '1200-2000'
            NYSE     := '1330-2000'


        Tokyo    := '0000-0600'
        Shanghai := '0100-0900'

    else if TimeZoneMode == 'Session Local Time'  or TimeZoneMode == 'Your Time Zone'
        Sydney   := '0900-1600'
        Tokyo    := '0900-1500'
        Shanghai := '0900-1700'
        Europe   := '0700-1600'
        London   := '0800-1600'
        NewYork  := '0800-1600'
        if Sydney_DST == 'Inactive'
            Asia     := '2300-0600'
        if Sydney_DST == 'Active'
            Asia     := '2200-0600'
  
    [Sydney, Tokyo, Shanghai, Asia, Europe, London, NewYork, NYSE]


//zones

[Sydney, Tokyo, Shanghai, Asia, Europe, London, NewYork, NYSE] = Market_TimeZone_Calculator(MarketMode, TimeZoneMode)

AsiaTZ     = MarketMode == 'User Custom' ? CustomTZ :TimeZoneMode == 'Session Local Time' or TimeZoneMode == 'Your Time Zone'?  'UTC+0': TimeZoneMode == 'UTC' ? 'UTC+0' :  na
SydneyTZ   = MarketMode == 'User Custom' ? CustomTZ :TimeZoneMode == 'Session Local Time' or TimeZoneMode == 'Your Time Zone'? "Australia/Sydney" : TimeZoneMode == 'UTC' ? 'UTC+0' :  na
TokyoTZ    = MarketMode == 'User Custom' ? CustomTZ :TimeZoneMode == 'Session Local Time' or TimeZoneMode == 'Your Time Zone'?  "Asia/Tokyo" : TimeZoneMode == 'UTC' ? 'UTC+0' :  na
ShanghaiTZ = MarketMode == 'User Custom' ? CustomTZ :TimeZoneMode == 'Session Local Time' or TimeZoneMode == 'Your Time Zone'?  "Asia/Shanghai" : TimeZoneMode == 'UTC' ? 'UTC+0' :  na
EuropeTZ   = MarketMode == 'User Custom' ? CustomTZ :TimeZoneMode == 'Session Local Time' or TimeZoneMode == 'Your Time Zone'?  "Europe/London" : TimeZoneMode == 'UTC' ? 'UTC+0' :  na
LondonTZ   = MarketMode == 'User Custom' ? CustomTZ :TimeZoneMode == 'Session Local Time' or TimeZoneMode == 'Your Time Zone'?  "Europe/London" : TimeZoneMode == 'UTC' ? 'UTC+0' :  na
NewYorkTZ  = MarketMode == 'User Custom' ? CustomTZ :TimeZoneMode == 'Session Local Time' or TimeZoneMode == 'Your Time Zone'?  "America/New_York" : TimeZoneMode == 'UTC' ? 'UTC+0' :  na

On_sesasia = math.sign(nz(time(timeframe.period, Asia, AsiaTZ)))
On_sesSydney = math.sign(nz(time(timeframe.period, Sydney, SydneyTZ)))
On_sesTokyo = math.sign(nz(time(timeframe.period, Tokyo, TokyoTZ)))
On_sesShanghai = math.sign(nz(time(timeframe.period, Shanghai, ShanghaiTZ)))
On_sesEuro = math.sign(nz(time(timeframe.period, Europe, EuropeTZ)))
On_seslondon = math.sign(nz(time(timeframe.period, London, LondonTZ)))
On_sesNewyork = math.sign(nz(time(timeframe.period, NewYork, NewYorkTZ)))
On_sesNYSE = math.sign(nz(time(timeframe.period, NYSE, NewYorkTZ)))
Newyork_Open = math.sign(nz(time(timeframe.period, "0000-0001" , "America/New_York")))

if bool(Newyork_Open)
    NY_Open_Price := open
    NY_Open_Time  := time

session_Switch = switch Session_List
    'None'     =>  true
    'Every Session' => On_sesSydney or On_sesTokyo or On_sesShanghai or On_seslondon or On_sesNewyork or On_sesNYSE
    'Sydney'   =>  On_sesSydney
    'Tokyo'    =>  On_sesTokyo
    'Shanghai' =>  On_sesShanghai
    'London'   =>  On_seslondon
    'NewYork'  =>  On_sesNewyork
    'NYSE'     =>  On_sesNYSE

if Session_List == 'Every Session'
    if (On_sesSydney and On_sesSydney[1] == false ) or (On_sesTokyo and On_sesTokyo[1] == false) or (On_sesShanghai and On_sesShanghai[1] == false) or 
     (On_seslondon and On_seslondon[1] == false) or (On_sesNewyork and On_sesNewyork[1] == false) or (On_sesNYSE and On_sesNYSE[1] == false)
        Permit_HGlobal:= true
        Permit_LGlobal:= true
else if bool(Newyork_Open)
    Permit_HGlobal:= true
    Permit_LGlobal:= true   

//PD Function
HTF_Info(x) =>
    var float H = 0.0
    var float L = 0.0
    var int   T = 0
    if barstate.isconfirmed
        H := high[x]
        L := low[x]
        T := time[x]
    [H, L, T]
[PDH , PDL, PDT] = request.security(syminfo.tickerid, '1D', HTF_Info(0))

//PD Drawing 
if PDT  != PDT[1] 
    if  PD_HShow
        PDH_Line := line.new(time, PDH, time, PDH,xloc = xloc.bar_time, style = line.style_solid, color = PD_HNColor, width = 3)
        PDH_Label := label.new(time, PDH, 'PDH', xloc = xloc.bar_time, style =  label.style_label_left, color = #ffffff00, textcolor = PD_HNColor)
    if  PD_LShow
        PDL_Line := line.new(time, PDL, time, PDL,xloc = xloc.bar_time, style = line.style_solid, color = PD_LNColor, width = 3)
        PDL_Label := label.new(time, PDL, 'PDL', xloc = xloc.bar_time, style =  label.style_label_left, color = #ffffff00, textcolor = PD_LNColor)
    line.delete(PDH_Line[1])
    line.delete(PDL_Line[1])
    label.delete(PDH_Label[1])
    label.delete(PDL_Label[1])   
else
    PDH_Line.set_x2(time)
    PDL_Line.set_x2(time)
    PDH_Label.set_x(time)
    PDL_Label.set_x(time)

if bool(Newyork_Open) != bool(Newyork_Open[1])
    if Open_Show
        Open_Line  := line.new(time, NY_Open_Price, time, NY_Open_Price ,xloc = xloc.bar_time, style = line.style_dashed, color = Open_Color , width = 1)
        Open_Label := label.new(time, NY_Open_Price, 'NY Open Price', xloc = xloc.bar_time, style =  label.style_label_left, color = #ffffff00, textcolor = Open_Color)
    line.delete(Open_Line[1])
    label.delete(Open_Label[1])
else
    Open_Line.set_x2(time)
    Open_Label.set_x(time)
//CISD DST_Detector

if (close > PDH and close > NY_Open_Price) and session_Switch
    Permit_HSet := true
    for i = 1 to BarBackCheck by 1
        if Body[i] < 0 and Permit_HSet and (DailyPosition == 'First' ? Permit_HGlobal : true)
            Permit_HReset := true
            CISDLvLP_H := (BarBackCheck > 1 and i > 1) ? math.min(open[i - 1], open[i - 2]) : open[i - 1]
            CISDLvLI_H := (BarBackCheck > 1 and i > 1) ? (math.min(open[i - 1], open[i - 2]) == open[i - 2]) ? bar_index[i - 2] : bar_index[i - 1] : bar_index[i - 1]
            if CISD_AShow and CISD_HShow
                CISD_LineH := line.new(CISDLvLI_H, CISDLvLP_H, bar_index , CISDLvLP_H , color = na, style = line.style_dotted)
                CISD_NameH := label.new(CISDLvLI_H + 1 , low[bar_index - CISDLvLI_H] - (ATR * 0.3) , 'CISD level', color = na, style = label.style_label_upper_left , textcolor = na, size = size.small)
            Permit_HSet := false
            Permit_HGlobal := false
if Permit_HReset 
    if  close >= CISDLvLP_H and (bar_index - line.get_x1(CISD_LineH)) <= CISDVal
        CISD_LineH.set_x2(bar_index + 1)
    if  close <= CISDLvLP_H and (bar_index - line.get_x1(CISD_LineH)) <= CISDVal
        Permit_HReset := false
        if CISD_AShow and CISD_HShow
            CISD_ShapH := label.new(bar_index , high + (ATR * 0.6), "", color = #890505, style = label.style_triangledown , size = size.tiny)
            CISD_LineH.set_color(CISD_HLColor)
            CISD_NameH.set_textcolor(CISD_HNColor)           

if (close < PDL and close < NY_Open_Price) and session_Switch
    Permit_LSet := true
    for i = 1 to BarBackCheck by 1
        if Body[i] > 0 and Permit_LSet and (DailyPosition == 'First' ? Permit_LGlobal : true)
            Permit_LReset := true
            CISDLvLP_L := (BarBackCheck > 1  and i > 1) ? math.max(open[i - 1], open[i - 2]) : open[i - 1]
            CISDLvLI_L := (BarBackCheck > 1  and i > 1) ? (math.max(open[i - 1], open[i - 2]) == open[i - 2]) ? bar_index[i - 2] : bar_index[i - 1] : bar_index[i - 1]
            if CISD_AShow and CISD_LShow
                CISD_LineL := line.new(CISDLvLI_L, CISDLvLP_L, bar_index , CISDLvLP_L, color = na, style = line.style_dotted)
                CISD_NameL := label.new(CISDLvLI_L + 1 , high[bar_index - CISDLvLI_L] + (ATR * 0.6) , 'CISD level', color = na, style = label.style_label_lower_right , textcolor = na , size = size.small)
            Permit_LSet := false
            Permit_LGlobal := false
if Permit_LReset 
    if  close <= CISDLvLP_L and (bar_index - line.get_x1(CISD_LineL)) <= CISDVal
        CISD_LineL.set_x2(bar_index + 1)
    if  close >= CISDLvLP_L and (bar_index - line.get_x1(CISD_LineL)) <= CISDVal
        Permit_LReset := false
        if CISD_AShow and CISD_LShow
            CISD_ShapL := label.new(bar_index , low - (ATR * 0.6), "", color = #016004, style = label.style_triangleup  , size = size.tiny)
            CISD_LineL.set_color(CISD_LNColor)
            CISD_NameL.set_textcolor(CISD_LLColor)

Alert.AlertSender(Permit_LReset[1] and not Permit_LReset  , Alert, AlertName , 'Analysis', '', 'Basic' ,'Once Per Bar', 'UTC', 'Off', MessageBull, open, high, low, close,0,0,0,0,0)
Alert.AlertSender(Permit_HReset[1] and not Permit_HReset  , Alert, AlertName , 'Analysis', '', 'Basic' ,'Once Per Bar', 'UTC', 'Off', MessageBear, open, high, low, close,0,0,0,0,0)

//SMT 
//Fractal////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
[Open_, High_, Low_, Close_] = request.security(Sym, timeframe.period,[open, high, low, close])
// UpPivot
UpPivot = bool(ta.pivothigh(n,n))

// DownPivot
DownPivot = bool(ta.pivotlow(n,n))

//Data//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// Bearish Divergence Data

//price Data
High_Last_Price = ta.valuewhen(UpPivot,high[n],0)
High_Per_Price = ta.valuewhen(UpPivot,high[n],1)

//MACD hist Data
High_Last_Hist = ta.valuewhen(UpPivot, High_[n],0)
High_Per_Hist = ta.valuewhen(UpPivot, High_[n],1)

//Bar index Data
High_Last_Bar = ta.valuewhen(UpPivot, bar_index[n],0)
High_Per_Bar = ta.valuewhen(UpPivot, bar_index[n],1)

// Time Condition Bullish
Time_Condition_Bear = (High_Last_Bar + 30) > bar_index


//Bearish Divergenc Detector////////////////////////
Last_Bearish_Divergece = if High_Last_Hist > 0 and High_Per_Hist > 0 and Time_Condition_Bear and (High_Last_Bar - High_Per_Bar) < 30
    ((High_Last_Price > High_Per_Price) and (High_Last_Hist < High_Per_Hist)) or ((High_Last_Price < High_Per_Price) and (High_Last_Hist > High_Per_Hist)) 
else 
    false

// Bullish Divergennce Data

//price Data
Low_Last_Price = ta.valuewhen(DownPivot,low[n],0)
Low_Per_Price = ta.valuewhen(DownPivot,low[n],1)

//MACD hist Data
Low_Last_Hist = ta.valuewhen(DownPivot, Low_[n],0)
Low_Per_Hist = ta.valuewhen(DownPivot, Low_[n],1)

//Bar index Data
Low_Last_Bar = ta.valuewhen(DownPivot, bar_index[n],0)
Low_Per_Bar = ta.valuewhen(DownPivot, bar_index[n],1)

// Time Condition Bullish
Time_Condition_Bull = (Low_Last_Bar + 30) > bar_index 

//Bullish Divergenc Detector////////////////////////
Last_Bullish_Divergece = if Low_Last_Hist > 0 and Low_Per_Hist > 0 and Time_Condition_Bull and (Low_Last_Bar - Low_Per_Bar) < 30
    ((Low_Last_Price < Low_Per_Price) and (Low_Last_Hist > Low_Per_Hist)) or ((Low_Last_Price > Low_Per_Price) and (Low_Last_Hist < Low_Per_Hist))
else 
    false

var line BeLine_OnChart  = na
var line BuLine_OnChart  = na
var label BeLabel_OnChart = na
var label BuLabel_OnChart = na

if Last_Bullish_Divergece and (close < PDL and close < NY_Open_Price) and session_Switch
    BuLine_OnChart:=(line.new(Low_Per_Bar, low[bar_index - Low_Per_Bar], Low_Last_Bar,low[bar_index - Low_Last_Bar] , color = Bull_Line ? color.black : na, width = 1 , style = line.style_dashed))
    BuLabel_OnChart:=(label.new(Low_Last_Bar,low[bar_index - Low_Last_Bar] , '+SMT', color = Bull_Label ? color.green : na, textcolor = color.white, size = size.tiny , style = label.style_label_up))
    line.delete(BuLine_OnChart[1])
    label.delete(BuLabel_OnChart[1])

if Last_Bearish_Divergece and (close > PDH and close > NY_Open_Price) and session_Switch
    BeLine_OnChart:=(line.new(High_Per_Bar,high[bar_index - High_Per_Bar], High_Last_Bar,high[bar_index - High_Last_Bar] , color = Bear_Line ? color.black : na, width = 1, style = line.style_dashed))
    BeLabel_OnChart:=(label.new(High_Last_Bar,high[bar_index - High_Last_Bar] ,'-SMT', color = Bear_Label ? color.red : na, textcolor = color.white, size = size.tiny, style = label.style_label_down))
    line.delete(BeLine_OnChart[1])
    label.delete(BeLabel_OnChart[1])
````
