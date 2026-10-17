# FTB Strategy (Automated)

- url: https://www.tradingview.com/script/gcu6zUkw-FTB-Strategy-Automated/
- type: strategy
- pine_id: PUB;8abbe3c33f9e4187a40940e6452611ae
- version: 2.0

## Description

Hey traders!

This is a profitable strategy script I created to teach my students how to automate their scripts using 3rd party APIs (more info available in my profile link at the bottom of this page).

[b]What Is This?[/b]

This strategy is called the "Follow The Bear" strategy.

It's a forex trading strategy designed for one purpose and one purpose only: to take advantage of a recurring pattern on EURUSD's 1-Hour chart during the European market open.

The basic explanation is this:

During the European open we want to see a rally followed by a swing high shooting star / reversal pinbar candle. This typically means that traders buying EURUSD during the European/London open are now trapped long, and as price begins to retrace they are forced to sell, fueling a short-term retracement.

This strategy takes advantage of that pattern by aggressively selling short with a tight stop-loss above the pinbar candle and a conservative target.

There are many ways to trade this pattern, but this script represents my personal method for trading it.

It is not 100% accurate (no strategy is), but it does have a considerably high win rate over the past 6+ years considering its simplicity and I've been trading it for several months and can attest to its edge over the markets (at least through the Oanda data feed which is what I use).

The strategy rules are this:

[list]
[*]Market: EURUSD
[*]Timeframe: 1-Hour
[*]Direction: Short Only
[*]Timezone: 6AM-10AM GMT
[*]Days: Tuesday, Wednesday, Thursday
[*]Entry: Close of Pinbar Setup
[*]Stop: 2 pips above signal candle
[*]Target: 1:1
[*]Risk: Up to you (backtest first! I use 1%)
[/list]

The rule for the pinbar/shooting star candle pattern is that the candle must both open and close in the lower 50% of the bar's total size.

[b]Automation[/b]

This script is already prepared to be auto-traded through a 3rd-party API that was created to relay TradingView alerts to your broker to execute and manage trades.

Sorry for the lack of information - due to TradingView's house rules I cannot go into any more detail here, but if you're interested in automating this script there is more info available in the resources offered under my profile link at the bottom of this page.

[b]Disclaimer[/b]

The material and the resources offered here are for educational purposes only. Always do your own research and only execute trades based on your own personal judgement.

Trading foreign currencies can be a challenging and potentially profitable opportunity for investors. However, before deciding to participate in the forex market, you should carefully consider your investment objectives, level of experience, and risk appetite. Most importantly, do not invest money you cannot afford to lose.

There is considerable exposure to risk in any foreign exchange transaction. Any transaction involving currencies involves risks including, but not limited to, the potential for changing political and/or economic conditions that may substantially affect the price or liquidity of a currency, investments in foreign exchange speculation may also be susceptible to sharp rises and falls as the relevant market values fluctuate.

The leveraged nature of forex trading means that any market movement will have an equally proportional effect on your deposited funds. This may work against you as well as for you. Not only may investors get back less than they invested, but in the case of higher risk strategies, investors may lose the entirety of their investment. It is for this reason that when speculating in such markets it is advisable to use only risk capital.

Trading foreign exchange on margin carries a high level of risk, and may not be suitable for all investors. Past performance is not indicative of future results. The possibility exists that you could sustain a loss of some or all of your initial investment and therefore you should not invest money that you cannot afford to lose. You should be aware of all the risks associated with foreign exchange trading, and seek advice from an independent financial advisor if you have any doubts.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © ZenAndTheArtOfTrading
// Last Updated: 10th March 2022
// @version=5
strategy("FTB Strategy", shorttitle="FTB", overlay=true, calc_on_order_fills=true, initial_capital=10000)

// Risk Settings
var g_risk      = "Risk Settings"
pips            = input.float(title="Stop Pips", defval=2.0, group=g_risk, tooltip="How many pips above high to put stop loss")
rr              = input.float(title="Risk:Reward", defval=1.0, group=g_risk, tooltip="This determines the risk:reward profile of the setup")
// Filters
var g_filter    = "Filter Settings"
timezone        = input.session(title="Timezone", defval="0200-0700", group=g_filter, tooltip="Which timezone to search for FTB signals in")
useRsiFilter    = input.bool(title="RSI OB/OS?", defval=true, group=g_filter, tooltip="If true then the RSI must be considered overbought before a signal is valid")
useCloseFilter  = input.bool(title="Previous Bar Must Be Bullish?", defval=false, group=g_filter, tooltip="If true then the previous bar must have closed bullish")
useHighFilter   = input.bool(title="High Filter", defval=false, group=g_filter, tooltip="If true then the signal bar must be the highest bar over X bars")
highLookback    = input.int(title="High Lookback", defval=10, group=g_filter, tooltip="This is for setting the High Filter lookback distance")
fib             = input.float(title="Candle Close %", defval=0.5, group=g_filter, tooltip="For identifying shooting star candles (0.5 = must close <= 50% mark of candle size)")
rsiLen          = input.int(title="RSI Length", defval=3, group=g_filter, tooltip="RSI length")
rsiOB           = input.float(title="RSI OB", defval=70.0, group=g_filter, tooltip="RSI overbought threshold")
var g_days      = "Day Filter"
d_monday        = input.bool(title="Monday", defval=true, group=g_days, tooltip="Take trades on this day?", inline="days")
d_tuesday       = input.bool(title="Tuesday", defval=true, group=g_days, tooltip="Take trades on this day?", inline="days")
d_wednesday     = input.bool(title="Wednesday", defval=true, group=g_days, tooltip="Take trades on this day?", inline="days")
d_thursday      = input.bool(title="Thursday", defval=true, group=g_days, tooltip="Take trades on this day?", inline="days")
d_friday        = input.bool(title="Friday", defval=true, group=g_days, tooltip="Take trades on this day?", inline="days")
var g_tester    = "Backtester Settings"
startBalance    = input.float(title="Starting Balance", defval=10000.0, group=g_tester, tooltip="Your starting balance for the inbuilt tester system")
riskPerTrade    = input.float(title="Risk Per Trade", defval=1.0, group=g_tester, tooltip="Your desired % risk per trade (as a whole number)")
drawTester      = input.bool(title="Draw Backtester", defval=true, group=g_tester, tooltip="Turn on/off inbuilt backtester display")
// PineConnector Settings
var g_pc        = "PineConnector Settings"
pc_id           = input.string(title="License ID", defval="ID", group=g_pc, tooltip="This is your PineConnector license ID")
pc_risk         = input.float(title="Risk Per Trade", defval=1, step=0.5, group=g_pc, tooltip="This is how much to risk per trade (% of balance or lots)")
pc_prefix       = input.string(title="MetaTrader Prefix", defval="", group=g_pc, tooltip="This is your broker's MetaTrader symbol prefix")
pc_suffix       = input.string(title="MetaTrader Suffix", defval="", group=g_pc, tooltip="This is your broker's MetaTrader symbol suffix")
pc_spread       = input.float(title="Spread", defval=0.5, group=g_pc, tooltip="Enter your average spread for this pair (used for offsetting limit order)")
pc_limit        = input.bool(title="Use Limit Order?", defval=true, group=g_pc, tooltip="If true a limit order will be used, if false a market order will be used")

// Generate PineConnector alert string
var symbol = pc_prefix + syminfo.ticker + pc_suffix
var limit = pc_limit ? "limit" : ""
pc_entry_alert(direction, sl, tp) =>
    price = pc_limit ? "price=" + str.tostring(pc_spread) + "," : ""
    pc_id + "," + direction + limit + "," + symbol + "," + price + "sl=" + str.tostring(sl) + ",tp=" + str.tostring(tp) + ",risk=" + str.tostring(pc_risk)

// Get RSI filter
rsiValue = ta.rsi(close, rsiLen)
rsiFilter = not useRsiFilter or rsiValue >= rsiOB

// Check high & close filter
highFilter = not useHighFilter or high == ta.highest(high, highLookback)
closeFilter = not useCloseFilter or close[1] > open[1]

// InSession() determines if a price bar falls inside the specified session (and day)
days = d_monday ? "2" : ""
days := days + (d_tuesday ? "3" : "")
days := days + (d_wednesday ? "4" : "")
days := days + (d_thursday ? "5" : "")
days := days + (d_friday ? "6" : "")
inSession(sess) => na(time(timeframe.period, sess + ":" + days)) == false

// Calculate 50% mark of candle size
bearFib = (high - low) * fib + low

// Check filters
filters = inSession(timezone) and closeFilter and high > high[1] and rsiFilter and highFilter and open != close

// Detect valid shooting star pinbar pattern
var takenTradeAlready = false
star = filters and close < bearFib and open < bearFib and not takenTradeAlready and strategy.position_size == 0

// Calculate stops & targets
shortStopPrice = high + (syminfo.mintick * pips * 10)
shortStopDistance = shortStopPrice - close
shortTargetPrice = close - (shortStopDistance * rr)

// Save stops & targets for the current trade
var t_stop = 0.0
var t_target = 0.0
var t_entry = 0.0

// If we detect a valid shooting star, save our stops & targets, enter short and generate alert
if star and barstate.isconfirmed
    t_stop := shortStopPrice
    t_target := shortTargetPrice
    t_entry := close
    takenTradeAlready := true
    positionSize = math.floor((strategy.equity * (riskPerTrade/100)) / (t_stop - close))
    strategy.entry(id="Short", direction=strategy.short, qty=positionSize, when=strategy.position_size == 0)
    alertString = pc_entry_alert("sell", t_stop, t_target)	
    alert(alertString, alert.freq_once_per_bar_close)

// If price has exceeded target then cancel limit order if it's still active	
if pc_limit and low <= t_target and strategy.position_size == 0	and takenTradeAlready
    alert(pc_id + ",cancelshort," + symbol, alert.freq_once_per_bar_close)

// If we have exited the FTB session then reset our takenTradeAlready flag for the next session
if not inSession(timezone) and inSession(timezone)[1]
    takenTradeAlready := false

// Draw stops & targets
plot(star or strategy.position_size != 0 ? t_stop : na, color=color.red, style=plot.style_linebr, title="SL")
plot(star or strategy.position_size != 0 ? t_target : na, color=color.green, style=plot.style_linebr, title="TP")
// Draw short signals
plotshape(star ? 1 : na, style=shape.triangledown, color=color.red)
// Change background color to highlight detection zone
bgcolor(color=inSession(timezone) ? color.new(color.red,80) : na, title="Session")

// Exit trade whenever our stop or target is hit
strategy.exit(id="Short Exit", from_entry="Short", limit=t_target, stop=t_stop, when=strategy.position_size != 0)

// =============================================================================
// START BACKTEST CODE
// =============================================================================

// Import Zen library
import ZenAndTheArtOfTrading/ZenLibrary/5 as zen

// Declare balance tracking variables (for backtester simulation)
var balance = startBalance
var drawdown = 0.0
var maxDrawdown = 0.0
var maxBalance = 0.0
var totalPips = 0.0

// Increase profit for wins
wonTrade = strategy.wintrades != strategy.wintrades[1]
if wonTrade
    balance += riskPerTrade / 100 * balance * rr
    totalPips += zen.toWhole(math.abs(t_entry - t_target))
    if balance > maxBalance
        maxBalance := balance

// Decrease profit for losses
lostTrade = strategy.losstrades != strategy.losstrades[1]
if lostTrade
    balance -= riskPerTrade / 100 * balance
    totalPips -= zen.toWhole(math.abs(t_stop - t_entry))
    // Update drawdown
    drawdown := balance / maxBalance - 1
    if drawdown < maxDrawdown
        maxDrawdown := drawdown

// Declare error tracking variables (for identifying how many "questionable" trades were detected)
var questionableTrades = 0
flagQuestionableTrade = false

// If price has hit both TP & SL on the same bar, flag it for further investigation
if ((wonTrade or lostTrade) and high >= t_stop and low <= t_target)
    questionableTrades += 1
    flagQuestionableTrade := true

// Highlight questionable trades
bgcolor(flagQuestionableTrade ? color.new(color.purple,50) : na)

// Prepare stats table
var table testTable = table.new(position.top_right, 5, 2, border_width=1)
f_fillCell(_table, _column, _row, _title, _value, _bgcolor, _txtcolor) =>
    _cellText = _title + "\n" + _value
    table.cell(_table, _column, _row, _cellText, bgcolor=_bgcolor, text_color=_txtcolor)

// Draw stats table
var bgcolor = color.black
if barstate.islastconfirmedhistory
    if drawTester
        dollarReturn = balance - startBalance
        f_fillCell(testTable, 0, 0, "Total Trades:", str.tostring(strategy.closedtrades) + " [*" + str.tostring(questionableTrades) + "]", bgcolor, color.white)
        f_fillCell(testTable, 0, 1, "Win Rate:", str.tostring(zen.truncate(strategy.wintrades / strategy.closedtrades * 100)) + "%", bgcolor, color.white)
        f_fillCell(testTable, 1, 0, "Starting:", "$" + str.tostring(startBalance), bgcolor, color.white)
        f_fillCell(testTable, 1, 1, "Ending:", "$" + str.tostring(zen.truncate(balance)), bgcolor, color.white)
        f_fillCell(testTable, 2, 0, "Return:", "$" + str.tostring(zen.truncate(dollarReturn)), bgcolor, dollarReturn > 0 ? color.green : color.red)
        f_fillCell(testTable, 2, 1, "Pips:", (totalPips > 0 ? "+" : "") + str.tostring(zen.truncate(totalPips)), bgcolor, color.white)
        f_fillCell(testTable, 3, 0, "Return:", (dollarReturn > 0 ? "+" : "") + str.tostring(zen.truncate(dollarReturn / startBalance * 100)) + "%", dollarReturn > 0 ? color.green : color.red, color.white)
        f_fillCell(testTable, 3, 1, "Max DD:", str.tostring(zen.truncate(maxDrawdown * 100)) + "%", color.red, color.white)

// =============================================================================
// END BACKTEST CODE
// =============================================================================
````
