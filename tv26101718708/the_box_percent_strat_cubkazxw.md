# The Box Percent Strat

- url: https://www.tradingview.com/script/cubKazxW-The-Box-Percent-Strat/
- type: strategy
- pine_id: PUB;eAze7gsQQbCFhfrR4v5MihzMC7At3bsZ
- version: 1.0

## Description

Hi guys, 

Version Zero (more work needed) of an idea I've been meaning to out into a strategy for a while. 🤯

This uses percent boxes🤔 instead of traditional indicators like RSI, MACD etc. 🤫

Takes the first close price of the series and creates a Top Band 10% up, buys if price reaches that level, and puts a stop on a Bot Band, 10% down
When the first trade is in profit by another 10%, it enters another trade and moves the stop of the first trade to breakeven ~ this way it only has one unit of risk at a time

///     Designed for LONG only on Daily, 2D or 3D Charts👌🏻
///     Uses fixed investment risk amount, meaning you're willing to lose that amount per trade
///     Limit buy to not overpay on entries

///     Idea Based on the Darvas system:
///     System only enters trades on strength, when prices equals of exceeds the green line
///     It ads onto the trades, but only *IF* the previous trade is in profit by the UpBoxSize percent size
///     The trailing stop loss is moved up, with the red line
///     A key idea is to only take one unit of risk at a time, meaning for a new add on trade to be taken, the previous trade should be in profit by the same box size as the new new trade's stop loss

///     This will keep adding trades again and again, and they will stop out at the same stop loss
///     Yellow Circles is an MA that filters out choppy areas -- this system only does really well on trending linear markets like: TQQQ, SSO, SPX, SPY
///     Base setting is 10% UpBox Size and 10% DnBox Size: 15% & 15% will be more accurate but fewer signals. 13% profit and 10% stop loss will give a higher risk to reward ratio

## Source Code

````pine
//@version=4
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © HermanBrummer 4 April 2021

strategy ("The Box Percent Strat", shorttitle="The Box", overlay = true, initial_capital = 1000)

///     Designed for LONG only on Daily, 2D or 3D Charts
///     Uses fixed investment risk amount, meaning you're willing to lose that amount per trade
///     Limit buy to not overpay

RiskPerTrade            = input(100, "Risk losing this much per trade", tooltip="This calculates how much you will lose based on difference between the entry price and stop loss price")
TradeAboveMAFilterPer   = input(50, "The System won't trade if price is below this MA")

UpBoxSize               = (input(10, "Box size in %") * 0.01)+1 // 1.1 == 10% up
DnBoxSize               = 1-(input(10, "Box size in %") * 0.01) // 0.9 == 10% dn


var FirstBar            = close > 0 ? close : na
var FirstTop            = FirstBar * UpBoxSize
var FirstBot            = FirstBar * DnBoxSize


var top                 = sma(FirstTop, 1)
var bot                 = sma(FirstBot, 1)

///     The Box Calcs
if  high[2] > top
    top                 := top * UpBoxSize
    bot                 := bot * UpBoxSize
if  low[1]  < bot
    top                 := top * DnBoxSize
    bot                 := bot * DnBoxSize

 
plot(bot,   "Bot",      #ff0000) // Green
plot(top,   "Top",      #00ff00) // Red

mid                     = ((top-bot)/2)+bot 
plot(mid,   "Mid", color.gray)

TradeAboveMAFilter      = sma(close, TradeAboveMAFilterPer)
plot(TradeAboveMAFilter, "Trade AboveMAF Filter", color.yellow, 3, style=plot.style_circles)

// col = high[1] < top and high >= top ? color.white : na
// bgcolor(col)


///     Shares
RiskRange                   = close * abs(DnBoxSize - 1) // 0.9 - 1 == 1.10 // 10% abs so you don't get a neg number NB NB
Shares                      = RiskPerTrade / RiskRange 
//plot(close-RiskRange, "RiskRange", color.fuchsia)

Enter   =   high >= top
             and close[1] > TradeAboveMAFilter
             and strategy.opentrades[0] == strategy.opentrades[1]
             and strategy.opentrades[1] == strategy.opentrades[2] 
             and strategy.opentrades[2] == strategy.opentrades[3]
             and strategy.opentrades[3] == strategy.opentrades[4] 
             and strategy.opentrades[4] == strategy.opentrades[5]
             and strategy.opentrades[5] == strategy.opentrades[6]
             // won't enter if new positon was taken in the last 6 bars
             // need better code for this.

///     Buy & Sell
//  (new highs)    and  (Close above moving average filter) and (No new trades were taken receently)
if  Enter //(high >= top)  and  (close[1] > TradeAboveMAFilter) and strategy.opentrades[0] == strategy.opentrades[1] 
    strategy.order("En", strategy.long, qty=Shares, limit=top)//, stop=top)
    
//barcolor(strategy.position_size != 0 ? #00ff00 : color.gray)


// ///     If ONE Position THEN this Stop Because: 
// if  strategy.position_size == 1
//     strategy.exit("Ex", "En", stop=bot)
///     If it has more than one trad OPEN
if  strategy.position_size > 0
    strategy.exit("Ex", "En", stop=bot[2] )   // puts stop on old bot

//plot(strategy.position_avg_price, "Avg Price", color.yellow)
````
