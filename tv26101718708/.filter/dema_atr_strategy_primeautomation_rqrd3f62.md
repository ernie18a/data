# DEMA ATR Strategy [PrimeAutomation]

- url: https://www.tradingview.com/script/rqRd3f62-DEMA-ATR-Strategy-PrimeAutomation/
- type: strategy
- pine_id: PUB;0338cbd8417445d2a46bfdebfd1db51d
- version: 2.0

## Description

[b]⯁ OVERVIEW[/b]
The [b]DEMA ATR Strategy[/b] combines trend-following logic with adaptive volatility filters to identify strong momentum phases and manage trades dynamically.  
It uses a Double Exponential Moving Average (DEMA) anchored to ATR volatility bands, creating a self-adjusting trend baseline.  
When the adjusted DEMA shifts direction, the strategy enters positions and scales out profit in phases based on ATR-driven targets.

This system adapts to volatility, filters noise, and seeks sustained directional moves.

[b]⯁ KEY FEATURES[/b]
[list]
[*] [b]DEMA-Volatility Hybrid Filter[/b]  
  Uses Double EMA with ATR expansion/compression logic to form a dynamic trend baseline.
[*] [b]Directional Shift Entries[/b]  
  Entries occur when the adjusted DEMA flips trend (bullish crossover or bearish crossunder vs its past value).
[image]https://www.tradingview.com/x/llEmLqvZ/[/image]
[*] [b]Noise Reduction Mechanism[/b]  
  ATR range caps extreme moves and prevents false flips during choppy volatility spikes.
[image]https://www.tradingview.com/x/CihUmwrR/[/image]
[*] [b]Multi-Level Take Profits[/b]  
  Targets scale out positions at 1×, 2×, and 3× ATR multiples in the trade direction.
[image]https://www.tradingview.com/x/ykGX5xP5/[/image]
[*] [b]Volatility-Adaptive Targets[/b]  
  ATR multiplier ensures profit targets expand/contract based on market conditions.
[*] [b]Single-Direction Exposure[/b]  
  No pyramiding; the strategy flips position only when trend shifts.
[*] [b]Automated Trade Finalization[/b]  
  When all profit targets trigger, the position is fully closed.
[/list]

[b]⯁ STRATEGY LOGIC[/b]
[list]
[*] [b]Trend Direction:[/b]  
  DEMA baseline is modified using ATR upper/lower envelopes.  
  • If the adjusted DEMA rises above previous value → Bullish  
  • If it falls below previous value → Bearish
[image]https://www.tradingview.com/x/MuAufVIm/[/image]
[*] [b]Entry Rules:[/b]  
  • Enter Long when bullish shift occurs and no long position exists  
  • Enter Short when bearish shift occurs and no short position exists

[*] [b]Take Profit Logic:[/b]  
  3 partial exits for each trade based on ATR:
  • TP1 = ±1× ATR  
  • TP2 = ±2× ATR  
  • TP3 = ±3× ATR  
  Profit distribution: 30% / 30% / 40%
[image]https://www.tradingview.com/x/APE7uRw0/[/image]

[*] [b]Exit Conditions:[/b]  
  • Exit when all TPs hit (full scale-out if sum of all TPs 100%)  
  • Opposite trend signal closes current trade and opens new one
[/list]

[b]⯁ WHEN TO USE[/b]
[list]
[*] Trending environments
[*] Medium–high volatility phases
[*] Swing trading and intraday trend plays
[image]https://www.tradingview.com/x/6rMGpmnP/[/image]
[*] Markets that respect momentum continuation (crypto, indices, FX majors)
[/list]

[b]⯁ CONCLUSION[/b]
This strategy blends DEMA trend recognition with ATR-based volatility adaptation to generate cleaner directional entries and structured take-profit exits. It is designed to capture momentum phases while avoiding noise-driven false signals, delivering a disciplined and scalable trend-following approach.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © PrimeAutomation
//@strategy_alert_message {{strategy.order.alert_message}}

//@version=6
strategy(title="DEMA ATR Strategy [PrimeAutomation]"
 , shorttitle = "DEMA ATR Strategy [PrimeAutomation]"
 , overlay=true
 , default_qty_type = strategy.percent_of_equity
 , default_qty_value = 10 
 , commission_type = strategy.commission.percent 
 , commission_value = 0.06 
 , initial_capital = 10000
 , margin_long = 0
 , margin_short = 0
 , process_orders_on_close = true
 , pyramiding = 0
 )


import TradingView/ta/7


string OpSettings           = "➞ Optimization Settings 🔸"
string OpSettings1          = "➞ Settings 🔸"


// Strategy Settings
startTime     = input.time(timestamp("01-01-2023"), "Strategy Start Date", group = OpSettings1)
MarketClosed  = input.bool(false ,"Exit before market close", group = OpSettings1)

var StartTIME = 0
totaltrades = strategy.closedtrades
PNL = strategy.netprofit_percent + strategy.openprofit_percent
WinRate = (strategy.wintrades / totaltrades ) * 100 
MaxDraw = strategy.max_drawdown_percent

Con = strategy.closedtrades == 0 and strategy.opentrades == 1 
StartTIME:= ta.valuewhen(Con and not Con[1],time,0)

MC()=>
    hr = hour == 15
    min = minute == 55
    _Hr = request.security(syminfo.tickerid,"5",hr)
    _min = request.security(syminfo.tickerid,"5",min)
    MClose = (_Hr and _min )
    MClose


var float dailyPNL = na
var int maxDays = 60
var float lastNetProfit = na
var array<string> PNLS = array.new_string()

newDay = ta.change(time("D")) != 0
currentNetProfit = strategy.netprofit

if newDay
    if not na(lastNetProfit)
        dailyPNL := currentNetProfit - lastNetProfit

        if dailyPNL != 0
            dateStr = str.format("{0,date,MM-dd}", time)
            combined = dateStr + ":" + str.tostring(dailyPNL, "#.##")
            array.unshift(PNLS, combined)

            if array.size(PNLS) > maxDays
                array.pop(PNLS)

    lastNetProfit := currentNetProfit



// log.error(str.tostring(PNLS))



tradesCount = strategy.closedtrades

// Get PnL of last closed trade
LastPNL = 0.
if tradesCount > 0
    LastPNL := strategy.closedtrades.profit(tradesCount - 1)



method parseing(string st,tp = 0 , sl = 0 , size = 0 , per = 0.)=>
    string ret = st
    ret := str.replace_all(ret, "{{tickerid}}", syminfo.tickerid)
    ret := str.replace_all(ret, "{{ticker}}", syminfo.ticker)
    ret := str.replace_all(ret, "{{exchange}}", syminfo.prefix)
    ret := str.replace_all(ret, "{{close}}", str.tostring(close))
    ret := str.replace_all(ret, "{{open}}", str.tostring(open))
    ret := str.replace_all(ret, "{{high}}", str.tostring(high))
    ret := str.replace_all(ret, "{{low}}", str.tostring(low))
    ret := str.replace_all(ret, "{{time}}", str.format_time(time, "yyyy-MM-dd HH:mm", syminfo.timezone))
    ret := str.replace_all(ret, "{{timenow}}", str.format_time(timenow, "yyyy-MM-dd HH:mm", syminfo.timezone))
    ret := str.replace_all(ret, "{{volume}}", str.tostring(volume))
    ret := str.replace_all(ret, "{{interval}}", timeframe.period)
    ret := str.replace_all(ret, "{{country}}", syminfo.country)
    ret := str.replace_all(ret, "{{description}}", syminfo.description)
    ret := str.replace_all(ret, "{{root}}", syminfo.root)
    ret := str.replace_all(ret, "{{industry}}", syminfo.industry)
    ret := str.replace_all(ret, "{{type}}", syminfo.type)
    ret := str.replace_all(ret, "{{tp}}", str.tostring(tp))
    ret := str.replace_all(ret, "{{sl}}", str.tostring(sl))
    ret := str.replace_all(ret, "{{size}}", str.tostring(size))
    ret := str.replace_all(ret, "{{per}}", str.tostring(per))
    ret := str.replace_all(ret, "{{TotalTrades}}", str.tostring(strategy.closedtrades))
    ret := str.replace_all(ret, "{{PNL}}", str.tostring(strategy.netprofit_percent + strategy.openprofit_percent,"#.##"))
    ret := str.replace_all(ret, "{{WinRate}}", str.tostring((strategy.wintrades / totaltrades) * 100 ,"#.##"))
    ret := str.replace_all(ret, "{{MaxDraw}}", str.tostring(strategy.max_drawdown_percent,"#.##" ))
    ret := str.replace_all(ret, "{{StartDate}}", str.format("{0,date,medium}",StartTIME))
    ret := str.replace_all(ret, "{{DailyPnl}}", str.tostring(dailyPNL,"#.##"))
    ret := str.replace_all(ret, "{{historyPNL}}", str.tostring(PNLS))
    ret := str.replace_all(ret, "{{LastPNL}}", str.tostring(LastPNL))
    ret



LongEntryMSG   = '{"ticker": "{{ticker}}","action": "buy","price": "{{close}}", "time": "{{timenow}}", "size": "{{size}}","TotalTrades":  "{{TotalTrades}}" ,"PNL": "{{PNL}}", "WinRate":  "{{WinRate}}", "MaxDraw": "{{MaxDraw}}", "StartDate":  "{{StartDate}}", "DailyPNL": "{{DailyPnl}}"}'
LongExitMSG    = '{"ticker": "{{ticker}}","action": "exit_buy","price": "{{close}}", "time": "{{timenow}}", "size": "{{size}}", "per": "{{per}}", "sl": "{{sl}}", "tp": "{{tp}}" ,"TotalTrades":  "{{TotalTrades}}" ,"PNL": "{{PNL}}", "WinRate":  "{{WinRate}}", "MaxDraw": "{{MaxDraw}}", "StartDate":  "{{StartDate}}", "DailyPNL": "{{DailyPnl}}"}'
ShortEntryMSG  = '{"ticker": "{{ticker}}","action": "sell","price": "{{close}}", "time": "{{timenow}}", "size": "{{size}}","TotalTrades":  "{{TotalTrades}}" ,"PNL": "{{PNL}}", "WinRate":  "{{WinRate}}", "MaxDraw": "{{MaxDraw}}", "StartDate":  "{{StartDate}}", "DailyPNL": "{{DailyPnl}}"}'
ShortExitMSG   = '{"ticker": "{{ticker}}","action": "exit_sell","price": "{{close}}", "time": "{{timenow}}", "size": "{{size}}", "per": "{{per}}", "sl": "{{sl}}", "tp": "{{tp}}" ,"TotalTrades":  "{{TotalTrades}}" ,"PNL": "{{PNL}}", "WinRate":  "{{WinRate}}", "MaxDraw": "{{MaxDraw}}", "StartDate":  "{{StartDate}}", "DailyPNL": "{{DailyPnl}}"}'




var float currentSize = na
isNewTrade = strategy.opentrades > strategy.opentrades[1]

if isNewTrade
    currentSize := math.abs(strategy.opentrades.size(strategy.opentrades -1))


MarketisClose = MC()


// --------------------------------------------------------------------------------------------------------------------}
// 📌 𝙐𝙎𝙀𝙍 𝙄𝙉𝙋𝙐𝙏𝙎
// --------------------------------------------------------------------------------------------------------------------{

// Define User Inputs
int   periodDema  = input.int(75, "Dema Period", group = "Dema Atr")
int   periodAtr   = input.int(20, "ATR Period", group = "Dema Atr", step = 1)
float factorAtr   = input.float(1.20, "ATR Factor", step = 0.05, group = "Dema Atr")

gTP      = "Take Profit"
useTP    = input.bool(true, "Take Profit", group = gTP, inline = "tp")
factorTP = input.float(3, "", step = 0.1, group = gTP, inline = "tp")
tp1Size = input.int(30, "TP1 Size Exit", group = gTP)
tp2Size = input.int(30, "TP2 Size Exit", group = gTP)
tp3Size = input.int(40, "TP3 Size Exit", group = gTP)


demaOut = ta.dema(close, periodDema)

trueRange = ta.atr(periodAtr) * factorAtr 

DemaAtr = demaOut 
DemaAtr := nz(DemaAtr[1], DemaAtr)

trueRangeUpper = demaOut + trueRange
trueRangeLower = demaOut - trueRange 

if trueRangeLower > DemaAtr 
    DemaAtr := trueRangeLower
if trueRangeUpper < DemaAtr 
    DemaAtr := trueRangeUpper

color = DemaAtr > DemaAtr[2] ? color.lime : DemaAtr < DemaAtr[2] ? #e42c2c : color.orange


longCondition  = ta.crossover(DemaAtr, DemaAtr[2]) and barstate.isconfirmed
shortCondition = ta.crossunder(DemaAtr, DemaAtr[2]) and barstate.isconfirmed


atr = ta.atr(200) * factorTP

var float tp1 = na
var float tp2 = na
var float tp3 = na

var float tp11 = na
var float tp22 = na
var float tp33 = na
var float entr = na

// Strategy Execution

if time >= startTime 
    // Trades
    if longCondition and strategy.position_size <= 0
        strategy.close('Short', 'Short Exit', alert_message = ShortExitMSG.parseing(per = 100,size = math.abs(strategy.position_size)))   
        strategy.entry("Long", strategy.long, comment="Long", alert_message =  LongEntryMSG.parseing( size = currentSize ))

        

        if useTP
            tp1 := close + atr
            tp2 := close + atr*2
            tp3 := close + atr*3
            tp11 := na
            tp22 := na
            tp33 := na
            entr := close


    if shortCondition and strategy.position_size > 0
        strategy.close('Long', 'Long Exit', alert_message = LongExitMSG.parseing(per = 100,size = math.abs(strategy.position_size))) 
        strategy.entry("Short", strategy.short, comment="Short", alert_message =  ShortEntryMSG.parseing( size = currentSize))

        

        if useTP
            tp11 := close - atr
            tp22 := close - atr*2
            tp33 := close - atr*3
            tp1 := na
            tp2 := na
            tp3 := na
            entr := close

    if strategy.position_size > 0

        if high > tp1 
            strategy.close('Long', 'Long TP1', alert_message = LongExitMSG.parseing(per = tp1Size,size = math.abs(strategy.position_size)), qty_percent = tp1Size) 
            tp1 := na
       
        if high > tp2
            strategy.close('Long', 'Long TP2', alert_message = LongExitMSG.parseing(per = tp2Size,size = math.abs(strategy.position_size)), qty_percent = tp2Size) 
            tp2 := na
       
        if high > tp3
            strategy.close('Long', 'Long TP3', alert_message = LongExitMSG.parseing(per = tp3Size,size = math.abs(strategy.position_size)), qty_percent = tp3Size) 
            tp3 := na
            entr := na
    else
        if low < tp11
            strategy.close('Short', 'Short TP1', alert_message = ShortExitMSG.parseing(per = tp1Size,size = math.abs(strategy.position_size)), qty_percent = tp1Size)   
            tp11 := na
          
        if low < tp22
            strategy.close('Short', 'Short TP2', alert_message = ShortExitMSG.parseing(per = tp2Size,size = math.abs(strategy.position_size)), qty_percent = tp2Size)   
            tp22 := na
       
    
        if low < tp33
            strategy.close('Short', 'Short TP3', alert_message = ShortExitMSG.parseing(per = tp3Size,size = math.abs(strategy.position_size)), qty_percent = tp3Size)   
            tp33 := na
            entr := na




// Close Trades when Market Closed
if MarketClosed and MarketClosed 
    if strategy.position_size > 0
        strategy.close('Long', 'Long Exit', alert_message = LongExitMSG.parseing(per = 100,size = math.abs(strategy.position_size))) 
    else 
        strategy.close('Short', 'Short Exit', alert_message = ShortExitMSG.parseing(per = 100,size = math.abs(strategy.position_size)))   




tpCol = strategy.position_size > 0 ? color.lime : #e42c2c
plot(tp1, "TP1 Long", style = plot.style_linebr, color = tpCol)
plot(tp2, "TP2 Long", style = plot.style_linebr, color = tpCol)
p3 = plot(tp3, "TP3 Long", style = plot.style_linebr, color = tpCol)

plot(tp11, "TP1 Short", style = plot.style_linebr, color = tpCol)
plot(tp22, "TP2 Short", style = plot.style_linebr, color = tpCol)
p33 = plot(tp33, "TP3 Short", style = plot.style_linebr, color = tpCol)

pe = plot(entr != entr[1] ? na : entr, "Enter", color = chart.fg_color, style = plot.style_linebr)

fill(pe, p3, color.new(tpCol, 90))
fill(pe, p33, color.new(tpCol, 90))

plot(DemaAtr, color = color, linewidth = 3)
````
