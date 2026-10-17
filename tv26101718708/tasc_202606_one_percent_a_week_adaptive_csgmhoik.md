# TASC 2026.06 One Percent A Week - Adaptive

- url: https://www.tradingview.com/script/CSGmHoik-TASC-2026-06-One-Percent-A-Week-Adaptive/
- type: strategy
- pine_id: PUB;e6f6c156de904413904e583a2be748b7
- version: 1.0

## Description

[b]█ OVERVIEW[/b]

This script implements a variant of Dion Kurczek's "High-Probability Weekly Trading Strategy For TQQQ" concept, as presented in his article "Part 2: Variations and Community Enhancements" in the [url=https://traders.com/Documentation/FEEDbk_docs/2026/06/TradersTips.html]June 2026 edition of the TASC Traders' Tips[/url]. In the article, the author explores multiple possible revisions to the original strategy. In this publication, we've adapted the final revision presented in the article: the "Adaptive Weekly Momentum Exit" model. 


[b]█ BACKGROUND[/b]

The One Percent a Week strategy was recently introduced in the [url=https://www.tradingview.com/script/nVECqIQx-TASC-2026-03-One-Percent-A-Week/]March 2026 publication[/url]. It utilizes the 3x leverage and volatility of TQQQ to attempt to capture 1% weekly profit from reactive moves made early in the week. The system was designed with simple, strict trading rules to prevent overtrading and control drawdown. Although this was the goal, the system left room for improvements to the base concept.

The original system used the following mechanics:
[list]
[*]Enter a trade after a 1% dip from the Monday open.
[*]Set an initial profit target of 1% for the open trade.
[*]If the trade's drawdown is 0.5% or greater, create a short limit order to fill at the entry price.
[*]Close the trade at the end of the week, regardless of profit or loss.
[/list] 
The version discussed in this article overhauls most of these mechanics. It preserves the same premise of striving for 1% average weekly returns, but aims to minimize drawdowns and allow for conditionally higher profit targets by introducing the following improvements:
[list]
[*][b]Entry on Monday open[/b]: The strategy enters a trade at the open of each Monday rather than waiting for a 1% dip, increasing market exposure. 
[*][b]Dynamic profit target[/b]: The initial profit target for each trade is 7%. Depending on the trade performance during the Monday session, the target increases by 1.1%, decreases to 2.5%, or remains unchanged. 
[*][b]Momentum-weakness exit[/b]: If the trade's performance is strong on Monday and begins to weaken on Tuesday, the system places a market order to exit the trade to avoid potential increased losses.
[*][b]Hard stop-loss[/b]: Each trade has a fixed 1.5% stop-loss order to prevent trades from further deterioration. 
[/list]

[b]█ THE RULES[/b]

The rules of the "Adaptive Weekly Momentum Exit" model discussed in the article differ significantly from those in the original strategy. The rules for this version are as follows:
[list=1]
[*]Enter a new trade at Monday's open.
[*]Set a fixed stop-loss order at 1.5% below the entry price. 
[*]Set an initial take-profit order at 7% above the entry price. 
[*]Check the trade's performance at the end of Monday. If the trade is still open and the profit is greater than 0.3%, multiply the take-profit price by 1.011 to allow a potential profit of 8.177%. If the open profit is currently zero or negative, reduce the target to 2.5%. 
[*]At the end of Tuesday, check for a momentum-based exit condition. If the return was above a specified threshold on Monday (2% by default) but fails to meet a separate threshold on Tuesday (3% by default), indicating a loss of momentum, place an order to close the position early. 
[*]If the position is open at the end of the week, close it immediately. 
[/list]
[b]▌Properties[/b]
[list]
[*][b]Position Sizing[/b]: Sizing is 10% of equity, the same as in the article.
[*][b]Commissions[/b]: Commission value is set to $0. Most major US brokers charge $0 commission on stocks and ETF trades, including leveraged ETFs such as TQQQ.
[*][b]Slippage[/b]: Slippage is not discussed in the article and likewise has not been included in this strategy.
[/list]
[i][b]Note:[/b]
This script enables "Recalculate after order is filled" by default, allowing the strategy to update trades and orders on the same bar to match the intended mechanics discussed in the article. Using this setting by default results in a warning in the strategy report because it can cause lookahead bias in some scripts. However, this script does not leak future price data into the past to control its orders or logic.[/i]


[b]█ DISPLAY[/b]

Similar to the strategy published for Part 1, this script plots lines to visualize the levels that it uses for order execution:
[list]
[*][b]Entry price[/b]: The blue line plots the entry price for the position, which is placed at Monday's opening price. 
[*][b]-1.5% Hard stop[/b]: The red dashed line is the level at which the 1.5% fixed stop loss is placed.
[*][b]Profit target[/b]: The solid green line shows the profit target.
[/list]

[b]█ INPUTS[/b]

[b]"Monday %"[/b] and [b]"Tuesday %"[/b]: These thresholds adjust the parameters of the loss-of-momentum exit. An early exit occurs if trade's return percentage as of Monday is greater than the "Monday %" value, and the current percentage on Tuesday is less than the "Tuesday %" value. The default percentages are the specific values referenced in the article.

## Source Code

````pine
//  TASC Issue: June 2026
//     Article: Trading Snapbacks In A Leveraged ETF
//              One Percent A Week: A High-Probability 
//              Weekly Trading Strategy For TQQQ - Part 2
//  Article By: Dion Kurczek
//    Language: TradingView's Pine Script® v6
// Provided By: PineCoders, for tradingview.com


//@version=6

TITLE = "TASC 2026.06 One Percent A Week - Adaptive"
SHORTTITLE = "1%/W - Adaptive"
strategy(TITLE,SHORTTITLE,
    overlay = true, 
    initial_capital = 10000, 
    default_qty_type = strategy.percent_of_equity, 
    default_qty_value = 10,
    calc_on_order_fills = true
)

//#region --- Inputs ---

float monPercent  = input.float(2, "Monday %", 1, 3, 0.1)
float tuesPercent = input.float(3, "Tuesday %", 1, 5, 0.1)
// #endregion


//#region --- Global variables ---

var   float monOpen  = na
var   float monProf  = na
var   float pt       = na
var   float sl       = na
varip bool  eowClose = false

bool newMon = (
    dayofweek == dayofweek.monday 
    and session.isfirstbar_regular
)
bool endMon = (
    dayofweek == dayofweek.monday
    and session.islastbar_regular
)
bool endTue = (
    dayofweek == dayofweek.tuesday 
    and session.islastbar_regular
)
//#endregion


//#region --- End of week order logic ---

//@variable The day number of the next trading day.
int nextDay = dayofweek(time("" , "", -1))

if barstate.isconfirmed and session.islastbar_regular
    // Close the current trade at the end of the week.
    if (
        dayofweek == dayofweek.friday or nextDay < dayofweek
    ) and eowClose
        strategy.close_all("End of week exit", immediately = true)
        eowClose := false
    // Place a market order at EOW to enter a new trade on Monday.
    if nextDay == dayofweek.monday
        strategy.entry("Buy", strategy.long)
        pt := na
        sl := na
//#endregion


//#region --- Bracket and momentum exit logic ---

// Place initial stop-loss and take-profit orders after entry fills.
if newMon
    monOpen  := open
    if strategy.position_avg_price > 0
        eowClose := true
        sl       := strategy.position_avg_price * 0.985
        pt       := strategy.position_avg_price * 1.07
        strategy.exit(
            "Exit", "Buy", stop = sl, limit = pt,
            comment_profit = "Profit +7%", 
            comment_loss = "Hard stop -1.5%"
        )

// Adjust the profit target at the end of Monday.
if barstate.isconfirmed
    float plPct = 100.0 * (close - strategy.position_avg_price) / strategy.position_avg_price
    if endMon
        monProf := plPct
        // Increase the target to 8.177% if the current profit 
        // is greater than 0.3%.
        if plPct > 0.3
            pt *= 1.011
            strategy.exit(
                "Exit", "Buy", stop = sl, limit = pt,
                comment_profit = "Profit +8.18%",
                comment_loss = "Hard stop -1.5%"
            )
        // Reduce the target to 2.5% if the current
        // profit is zero or negative.
        else if plPct <= 0
            pt := strategy.position_avg_price * 1.025
            strategy.exit(
                "Exit", "Buy", stop = sl, limit = pt,
                comment_profit = "Profit +2.5%",
                comment_loss = "Hard stop -1.5%"
            )

    // Place a market order to close the position
    // if the profit momentum is weakening.
    if endTue and monProf > monPercent and plPct < tuesPercent
        strategy.close_all("Loss of momentum exit")
//#endregion

//#region --- Plots ---

plot(
    strategy.position_avg_price, "Entry Price", 
    color.blue, style = plot.style_linebr
)
plot(
    strategy.position_size > 0 or strategy.position_size[1] > 0 ? sl : na, "-1.5% Hard stop", 
    #ff0000, style = plot.style_linebr, 
    linestyle = plot.linestyle_dashed
)
plot(
    strategy.position_size > 0 or strategy.position_size[1] > 0 ? pt : na, "Profit target", 
    #00ff00, style = plot.style_linebr, 
    linestyle = plot.linestyle_solid
)
//#endregion
````
