# Rolling Straddle Premium

- url: https://www.tradingview.com/script/oDbBeXOW-Rolling-Straddle-Premium/
- type: indicator
- pine_id: PUB;22283e7caab94959a7d1e1c3117eab77
- version: 1.0

## Description

Script is Basically intended to provide insight's on the Rolling Straddle premium for the selected index based on the input settings.

Important thing to consider for the script to work seamlessly:
[list]
[*]Specify the LTP in the input field (need not be very accurate)
[*]Specify the Expiry Date for the Option Strike.
[*]Ensure Profile matches to the chart script (Index Script)
[/list]

Note: Zones marked in Blue, is the max level that indicator can track the option prices. beyond which it may fail to track, during such time consider [b]reloading the indicator with Latest LTP[/b].

Labels on the chart indicate that If i had shorted the Straddle, what would be my current position of that Straddle. however the rational behind shorting is only the pivot high points [i](not sure if this is right or wrong! )[/i]

Note On Labels: Labels are delayed basis the pivot point candles specified in the indicator settings.

[list=1]
[*][b]EN: [/b]Entry Price (Straddle Premium) of the Strike Specified.
[*][b]Cur: [/b]Current Price ([i]Current Straddle Premium[/i]) of the Strike Specified.
[*][b]SH: [/b]Max Straddle Premium ([i]Increase in Premium[/i]) since position is active.
[*][b]SL: [/b]Min Straddle Premium ([i]Premium Erosion[/i]) since position is active.  
[/list]

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © TradeWiseWithEase

//@version=5
indicator(title = "Rolling Straddle Premium", shorttitle = "BE-RS_V0.0", overlay = false, calc_bars_count = 1000, dynamic_requests = true)

max_bars_back(time, 4500)
import TradeWiseWithEase/BE_CustomFx_Library/131 as BEL
import PineCoders/Time/3 as pcTimeLib
import TradeWiseWithEase/DerivativeAlertPlaceHolders/3 as PH

var string Grp1                         = "Indicator Inputs"

type ProfileInfo
    string SymbolInfo
    int    SymbolLot
    int    SymbolStrike
    string SymbolExc
    float  EntryLoss
    float  PeakOn
    float  FreshEntry

var ProfileInfo BNFProfile              = ProfileInfo.new("BANKNIFTY", 15, 100, "NFO", -40, 40, 10)
var ProfileInfo N50Profile              = ProfileInfo.new("NIFTY", 25, 50, "NFO", -20, 20, 5)
var ProfileInfo FINProfile              = ProfileInfo.new("FINNIFTY", 25, 50, "NFO", -20, 20, 5)
var ProfileInfoArray                    = array.new<ProfileInfo>()

var simple string SciptName             = input.string(
 defval                                 = "BANKNIFTY",
 group                                  = Grp1,
 options                                = ['BANKNIFTY','NIFTY', 'FINNIFTY'],
 tooltip                                = 'Select the Profile as per the Loaded Chart',
 confirm                                = true,
 title                                  = "Profile Input")

var simple int Modulo                   = SciptName == "BANKNIFTY" ? 100 : 50
var simple string ScriptExpiry          = input.string(
 defval                                 = "240925",
 group                                  = Grp1,
 confirm                                = true, 
 tooltip                                = 'Set the Expiry Date you wish to Track & Trade.\n\nNote: This should match the Option Name in TV Script',
 title                                  = "TV Expiry Date [IMPORTANT]")

var string ScriptPlusTVExpiry           = SciptName + ScriptExpiry
var simple float InputLTP               = input.float(
 defval                                 = 53800,
 step                                   = 50,
 confirm                                = true, 
 group                                  = Grp1,
 tooltip                                = "Set the Appx value. Need not to be very accurate.",
 title                                  = "Last Traded Price")
var simple float CalculatedATM          = InputLTP - (InputLTP % Modulo)
var int PivotRef                        = input.int(
 defval                                 = 6,
 step                                   = 1,
 minval                                 = 2,
 group                                  = Grp1,
 title                                  = "Pivot Reference")
var simple string SampleInputForText    = input.string(
 defval                                 = "Normal",
 title                                  = "Label Text Size",
 group                                  = Grp1,
 options                                = ["Auto", "Tiny", "Small", "Normal", "Large", "Huge"])
var TextSize                            = BEL.TxtSize(SampleInputForText)

var simple string C09                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM + (Modulo * 9))
var simple string C08                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM + (Modulo * 8))
var simple string C07                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM + (Modulo * 7))
var simple string C06                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM + (Modulo * 6))
var simple string C05                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM + (Modulo * 5))
var simple string C04                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM + (Modulo * 4))
var simple string C03                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM + (Modulo * 3))
var simple string C02                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM + (Modulo * 2))
var simple string C01                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM + (Modulo * 1))
var simple string C00                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM)
var simple string C_1                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM - (Modulo * 1))
var simple string C_2                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM - (Modulo * 2))
var simple string C_3                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM - (Modulo * 3))
var simple string C_4                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM - (Modulo * 4))
var simple string C_5                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM - (Modulo * 5))
var simple string C_6                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM - (Modulo * 6))
var simple string C_7                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM - (Modulo * 7))
var simple string C_8                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM - (Modulo * 8))
var simple string C_9                   = "NSE:" + ScriptPlusTVExpiry + "C" + str.tostring(CalculatedATM - (Modulo * 9))
var simple string P09                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM + (Modulo * 9))
var simple string P08                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM + (Modulo * 8))
var simple string P07                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM + (Modulo * 7))
var simple string P06                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM + (Modulo * 6))
var simple string P05                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM + (Modulo * 5))
var simple string P04                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM + (Modulo * 4))
var simple string P03                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM + (Modulo * 3))
var simple string P02                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM + (Modulo * 2))
var simple string P01                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM + (Modulo * 1))
var simple string P00                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM)
var simple string P_1                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM - (Modulo * 1))
var simple string P_2                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM - (Modulo * 2))
var simple string P_3                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM - (Modulo * 3))
var simple string P_4                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM - (Modulo * 4))
var simple string P_5                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM - (Modulo * 5))
var simple string P_6                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM - (Modulo * 6))
var simple string P_7                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM - (Modulo * 7))
var simple string P_8                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM - (Modulo * 8))
var simple string P_9                   = "NSE:" + ScriptPlusTVExpiry + "P" + str.tostring(CalculatedATM - (Modulo * 9))

type PrntLbl
    int BarRef                          = bar_index
    float PriceRef                      = 0.
    color ColorRef                      = color.blue
    string LblDirection                 = ""
    int IndexRef                        = na
    float EN                            = na
    float SH                            = na
    float SL                            = na

varip StrikePrices                      = array.new_string(0)
varip CalSymbols                        = array.new_string(0)
varip PutSymbols                        = array.new_string(0)
varip LTPSymbols                        = array.from(C08, P08)
varip SymbolOut                         = array.new_float(0)
var GetUserProfile                      = ProfileInfo.new()
var ChangeInStrike                      = array.new_int(PivotRef, 0)
var int ChangeInStrike_                 = 99
var int FirstBarIndex                   = na
var float RolPrem                       = 0.
varip symIndex                          = array.new_int(0)
varip CurPrices                         = array.new_float(0)
varip RolPremSlice                      = array.new_float(0)
varip StrdleSym                         = array.new_string(0)
varip ArrayOfInfoLabels                 = array.new<PrntLbl>(0)
method MaintainArray(PrntLbl[] id, PrntLbl Value2Store) =>
    if id.size() == 5
        id.shift()
        id.push(Value2Store)
    else
        id.push(Value2Store)

method MaintainArray(int[] id, int Value2Store, int size2Maintain) =>
    if id.size() == size2Maintain
        id.shift()
        id.push(Value2Store)
    else
        id.push(Value2Store)

PrintLabels(float ValRef, int Idx, float Prem = na, color DispColor = color.blue, string DirLbl = label.style_label_down, int CanRef) =>
    ArrayOfInfoLabels.MaintainArray(PrntLbl.new(CanRef, ValRef, DispColor, DirLbl, Idx, Prem))

if barstate.isfirst
    FirstBarIndex                       := bar_index
    ProfileInfoArray.push(BNFProfile)
    ProfileInfoArray.push(N50Profile)
    ProfileInfoArray.push(FINProfile)
    CalSymbols                          := array.from(C09, C08, C07, C06, C05, C04, C03, C02, C01, C00, C_1, C_2, C_3, C_4, C_5, C_6, C_7, C_8, C_9)
    PutSymbols                          := array.from(P09, P08, P07, P06, P05, P04, P03, P02, P01, P00, P_1, P_2, P_3, P_4, P_5, P_6, P_7, P_8, P_9)
    for i = 9 to 0 by 1
        StrikePrices.push(str.tostring(CalculatedATM + (Modulo * i)))
    for a = 1 to 9 by 1
        StrikePrices.push(str.tostring(CalculatedATM - (Modulo * a)))
    for [index, echProfile] in ProfileInfoArray
        if echProfile.SymbolInfo == SciptName
            GetUserProfile              := echProfile    

if barstate.isconfirmed or barstate.islastconfirmedhistory
    ATM_Inf                             = BEL.G_ATM(Modulo, true, "c", close, 0)
    ATM_Txt                             = ATM_Inf.IAO_Text
    IdxOfATM                            = StrikePrices.indexof(ATM_Txt)
    if barstate.isfirst
        ChangeInStrike_                 := 99
        LTPSymbols.clear()
        LTPSymbols                      := CalSymbols.copy()
        LTPSymbols.concat(PutSymbols)
    else if not barstate.isfirst
        if IdxOfATM >= 0 and IdxOfATM != ChangeInStrike_
            ChangeInStrike_             := IdxOfATM

    if bar_index != FirstBarIndex
        LTPSymbols.clear()
        symIndex.clear()
        if ArrayOfInfoLabels.size()     == 0
            symIndex.push(ChangeInStrike_)
        else
            for [index, value] in ArrayOfInfoLabels
                if index == 0
                    symIndex            := array.from(ChangeInStrike_, value.IndexRef)
                else
                    symIndex.push(value.IndexRef)
        for [index, ech] in symIndex
            if ech                      != 99
                CalSym                  = CalSymbols.get(ech)
                PutSym                  = PutSymbols.get(ech)
                LTPSymbols.push(CalSym)
                LTPSymbols.push(PutSym)
    ChangeInStrike.MaintainArray(ChangeInStrike_, PivotRef)

if LTPSymbols.size() > 0
    SymbolOut.clear()
    for [idx, symbols] in LTPSymbols
        ClosePrice                      = request.security(symbols, timeframe.period, close)
        SymbolOut.push(ClosePrice)
    if bar_index != FirstBarIndex
        RolPremSlice                    := SymbolOut.slice(0, 2)
        StrdleSym                       := LTPSymbols.slice(0, 2)
        BalanceSlice                    = array.new_float(0)
        if ArrayOfInfoLabels.size() > 0
            BalanceSlice                := SymbolOut.slice(2, SymbolOut.size())
            CurPrices.clear()
            for i = BalanceSlice.size() - 1 to 0 by 1           
                if i % 2 == 1
                    PutPrice            = BalanceSlice.get(i)
                    CalPrice            = BalanceSlice.get(i - 1)
                    CurPrices.push(CalPrice + PutPrice)

RolPrem                                     := RolPremSlice.sum()
PH                                          = ta.pivothigh(RolPrem, 20, PivotRef)
a_allLabels                                 = label.all
if array.size(a_allLabels) > 0
    for i = 0 to array.size(a_allLabels) - 1
        label.delete(array.get(a_allLabels, i))
if ArrayOfInfoLabels.size() == CurPrices.size()
    for [i, plotInfo] in ArrayOfInfoLabels
        NewInfo                             = PrntLbl.new(plotInfo.BarRef, plotInfo.PriceRef, plotInfo.ColorRef, plotInfo.LblDirection, plotInfo.IndexRef)
        Strike                              = StrikePrices.get(plotInfo.IndexRef)
        NowPrice                            = CurPrices.get(CurPrices.size() - 1 - i)
        EnPrem                              = na(plotInfo.EN) ? NowPrice : plotInfo.EN
        MaxPrem                             = na(plotInfo.SH) ? EnPrem : math.max(plotInfo.SH, NowPrice)
        MinPrem                             = na(plotInfo.SL) ? EnPrem : math.min(plotInfo.SL, NowPrice)
        NewInfo.EN                          := EnPrem
        NewInfo.SH                          := MaxPrem
        NewInfo.SL                          := MinPrem
        label.new(NewInfo.BarRef, NewInfo.PriceRef, str.format("{0}\nEN: {1}\nCur: {2}\nSH: {3}\nSL: {4}", Strike, EnPrem, NowPrice, NewInfo.SH, NewInfo.SL), xloc.bar_index, yloc.price, NewInfo.ColorRef, NewInfo.LblDirection, color.white, TextSize, force_overlay = true)
        ArrayOfInfoLabels.set(i, NewInfo)


if not na(PH) and bar_index - PivotRef > FirstBarIndex and barstate.isconfirmed
    PrintLabels(high[PivotRef], ChangeInStrike.first(), na, CanRef = bar_index - PivotRef)

plot(RolPrem, "Rolling Straddle Premium", color.blue, 1)

fill(plot(CalculatedATM + Modulo * 9, force_overlay = true, color = color.new(color.blue, 100), display = display.all - display.status_line), plot(CalculatedATM - Modulo * 9, force_overlay = true, color = color.new(color.blue, 100), display = display.all - display.status_line), color = color.new(color.blue, 90))
````
