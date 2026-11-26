# 8 Whittle Down

- url: https://www.tradingview.com/script/2GKQre3R-8-Whittle-Down/
- type: strategy
- pine_id: PUB;b35bdf4f1a524b7bb79b9cd740c57e72
- version: 1.0

## Description

The system is designed to short on directionally negative instruments like VXX & SQQQ


[list]
[*] The system only shorts, no longs
[*] It enters a pilot position if the system has no trades open at the time is in the late afternoon
[*] It uses a 200-day moving average as a filter and will only short if the price is below the 200 day moving average
[*] The pilot position will only enter with 1/3 ( one third ) of the total expected position size
[*] StopLossPerc sets the stop loss, (1.15) means it is set to a 15% stop loss. -- The Red Line
[/list]


[list]
[*] The system will buy additional shares for a full position if the pilot piston profit target was not reached
[*] The full shares position is set to purchase at a higher price. T2EntTrgPerc sets the buy percentage target for the additional shares. -- The Yellow Line
[*] Each entry has different settable profit targets. T1ProfTrgPerc sets the profit target for the first trade (0.95) is basically set to a 5% profit.
[*] T2ProfTrgPerc sets the profit target for the second trade (0.90) is basically set to a 10% profit. -- The White Line
[/list]


RED LINE == STOP LOSS LINE
GREENLINE == PROFIT TARGET FOR THE 1ST TRADE

YELLOW LINE == ADD ON SHARES TO THE TRADE
WHITE LINE == PROFIT TARGET FOR THE 1st & 2nd TRADE COMBINED

Let me know if you have any questions and I'll try to clarify

## Source Code

````pine
//              @version=4
strategy("8 Whittle Down", "8 WD", 1, initial_capital=0)


//              DUAL ENTRIES
//              ADDS ON MORE SHARES IF THE PILOT TRADE DOES NOT REACH PROFIT TARGET
//              RED     LINE        == STOP LOSS LINE
//              GREEN   LINE        == PROFIT TARGET FOR THE 1ST TRADE
//              YELLOW  LINE        == ADD ON SHARES TO THE TRADE
//              WHITE   LINE        == PROFIT TARGET FOR THE 1ST & SECOND TRADE COMBINED


StopLossPerc        = input(1.15, "Total Stop Loss", step=0.01)


T2EntTrgPerc        = input(1.05, "Enter Second trade @ what higher 5%?", step=0.01)    //  BUY STOP LIMIT ONLY WHEN ONE TRADE IS ALREADY OPEN & AIMS TO BUY DOUBLE THE OWNED SHARES AT A HIGHER ENTRY PRICE // YELLOW LINE

T1ProfTrgPerc       = input(0.95, "First Trade Profit % Target", step=0.01)
T2ProfTrgPerc       = input(0.90, "Second Trade Profit % Target", step=0.01)


RiskRange           = close*(StopLossPerc)-1
Shares              = floor(1000*1000/RiskRange) / 3                                    //  SPLITS THE RISK OVER THREE TRADES

F1                  = close < sma(security(syminfo.tickerid, "D", close[2]), 200)       //  HIGH OF OLD DATA -- SO NO REPAINTING
F2                  = strategy.opentrades == 0
buyTime             = time(timeframe.period, "1429-1500")                               //  BUY AT THE END OF THE  DAY
 
 
StopLossLine        = strategy.position_avg_price * StopLossPerc
StopLossCol         = strategy.opentrades != 0 ? #FF0000 : na
plot(StopLossLine,  "StopLossLine", StopLossCol, 2)



strategy.cancel_all()                                                                   //  CANCELS ALL ORDERS: BECAUSE THE SYSTEM WILL ADD A BUY STOP LIMIT ORDER FOR ENTRY TWO



///==============   ENTRY 1   ==============   
if  F1 and buyTime and strategy.opentrades == 0
    strategy.entry("S1", false, qty=Shares)


T1Prof              = strategy.position_avg_price * T1ProfTrgPerc
plot(T1Prof,        "1st Profit Target", strategy.opentrades == 1 ? #00FF00 : na, 2)

strategy.exit("S1 Ex", "S1", limit=T1Prof, stop=StopLossLine )


///==============   ENTRY 2   ==============   
T2EntryTrg          = strategy.position_avg_price * T2EntTrgPerc // enters on higher target than 1st entry
plot(T2EntryTrg,    "ent2EntryTrg", strategy.opentrades == 1 ? color.yellow : na, 2)
    
    
if  strategy.opentrades == 1
    strategy.order("S2", false, stop=T2EntryTrg, limit= T2EntryTrg, qty=Shares * 2)     //  BUYS MORE SHARES

T2Prof              = strategy.position_avg_price * T2ProfTrgPerc
    
T2Col               = strategy.opentrades == 2 ? color.white : na
plot(T2Prof,        "2nd Profit Target", T2Col, 2)
    
    
strategy.exit("S2 Ex", "S2", limit=T2Prof, stop=StopLossLine )
````
