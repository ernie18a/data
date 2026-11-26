# Intramarket Difference Index Strategy

- url: https://www.tradingview.com/script/48muRGl2-Intramarket-Difference-Index-Strategy/
- type: strategy
- pine_id: PUB;6213f1c375d04439abe4474f6e3d8440
- version: 1.0

## Description

Hi Traders !! 

[b]The IDI Strategy:[/b] 

In layman’s terms this strategy compares two indicators across markets and exploits their differences.

[i]note: it is best the two markets are correlated as then we know we are trading a short to long term deviation from both markets' general trend with the assumption both markets will trend again sometime in the future thereby exhausting our trading opportunity.[/i]

📍 [b]Import Notes:  [/b]

[i][list]
[*]This Strategy calculates trade position size independently (i.e. risk per trade is controlled in the user inputs tab), this means that the ‘Order size’ input in the ‘Properties’ tab will have no effect on the strategy. Why ? because this allows us to define custom position size algorithms which we can use to improve our risk management and equity growth over time. Here we have the option to have fixed quantity or fixed percentage of equity ATR (Average True Range) based stops in addition to the turtle trading position size algorithm.
[*]‘Pyramiding’ does not work for this strategy’, similar to the order size input togeling this input will have no effect on the strategy as the strategy explicitly defines the maximum order size to be 1. 
[*]This strategy is not perfect, and as of writing of this post I have not traded this algo. 
[*]Always take your time to backtests and debug the strategy.
[/list][/i]

🔷 [b]The IDI Strategy:[/b]

By default this strategy pulls data from your current TV chart and then compares it  to the base market, be default [symbol="BINANCE:BTCUSD"]BINANCE:BTCUSD[/symbol] . The strategy pulls SMA and RSI data from either market (we call this the difference data), standardizes the data (solving the different unit problem across markets) such that it is comparable and then differentiates the data, calling the result of this transformation and difference the Intramarket Difference (ID). The formula for the the ID is 
 
ID = market1_diff_data - market2_diff_data	(1)

Where 

market(i)_diff_data = diff_data / ATR(j)_market(i)^0.5, 

where i = {1, 2} and j = the natural numbers excluding 0  

Formula (1) interpretation is the following 
[list=1]
[*]When ID > 0: this means the current market outperforms the base market
[*]When ID = 0: Markets are at long run equilibrium
[*]When ID < 0: this means the current market underperforms the base market
[/list]

To form the strategy we define one of two strategy type’s which are Trend and Mean Revesion respectively. 

🔸 [b]Trend Case:[/b]

Given the ‘‘Strategy Type’’ is equal to TREND we define a threshold for which if the ID crosses over we go long and if the ID crosses under the negative of the threshold we go short. 

The motivating idea is that the ID is an indicator of the two symbols being out of sync, and given we know volatility clustering, momentum and mean reversion of anomalies to be a stylised fact of financial data we can construct a trading premise. Let's first talk more about this premise. 

For some markets (cryptocurrency markets - synthetic symbols in TV) the stylised fact of momentum is true, this means that higher momentum is followed by higher momentum, and given we know momentum to be a vector quantity (with magnitude and direction) this  momentum can be both positive and negative i.e. when the ID crosses above some threshold we make an assumption it will continue in that direction for some time before executing back to its long run equilibrium of 0 which is a reasonable assumption to make if the market are correlated. For example for the BTCUSD - ETHUSD pair, if the ID > +threshold (inputs for MA and RSI based ID thresholds are found under the ‘‘INTRAMARKET DIFFERENCE INDEX’’ group’), ETHUSD outperforms BTCUSD, we assume the momentum to continue so we go long ETHUSD. 

In the standard case we would exit the market when the IDI returns to its long run equilibrium of 0 (for the positive case the ID may return to 0 because ETH’s difference data may have decreased or BTC’s difference data may have increased). However in this strategy we will not define this as our exit condition, why ? 

This is because we want to ‘‘let our winners run’’, to achieve this we define a trailing Donchian Channel stop loss (along with a fixed ATR based stop as our volatility proxy).  If we were too use the 0 exit the strategy may print a buy signal (ID > +threshold in the simple case, market regimes may be used), return to 0 and then print another buy signal, and this process can loop may times, this high trade frequency means we fail capture the entire market move lowering our profit, furthermore on lower time frames this high trade frequencies mean we pay more transaction costs (due to price slippage, commission and big-ask spread) which means less profit. 

By capturing the sum of many momentum moves we are essentially following the trend hence the trend following strategy type. 

https://www.tradingview.com/x/OrBZ1v77/
[i]Here we also print the IDI (with default strategy settings with the MA difference type), we can see that by letting our winners run we may catch many valid momentum moves, that results in a larger final pnl that if we would otherwise exit based on the equilibrium condition(Valid trades are denoted by solid green and red arrows respectively and all other valid trades which occur within the original signal are light green and red small arrows).[/i] 

another example...
https://www.tradingview.com/x/BtrXqKxZ/

Note: if you would like to plot the IDI separately copy and paste the following code in a new Pine Script indicator template. 
[pine]
indicator("IDI")

// INTRAMARKET INDEX 
var string g_idi = "intramarket diffirence index"
ui_index_1 = input.symbol("BINANCE:BTCUSD", title = "Base market", group = g_idi)
// ui_index_2 = input.symbol("BINANCE:ETHUSD", title = "Quote Market", group = g_idi)
type = input.string("MA", title = "Differrencing Series", options = ["MA", "RSI"], group = g_idi)
ui_ma_lkb = input.int(24, title = "lookback of ma and volatility scaling constant", group = g_idi)
ui_rsi_lkb = input.int(14, title = "Lookback of RSI", group = g_idi) 
ui_atr_lkb = input.int(300, title = "ATR lookback - Normalising value", group = g_idi)
ui_ma_threshold = input.float(5, title = "Threshold of Upward/Downward Trend (MA)", group = g_idi)
ui_rsi_threshold = input.float(20, title = "Threshold of Upward/Downward Trend (RSI)", group = g_idi)

//>>+----------------------------------------------------------------+}
//                                                  CUSTOM FUNCTIONS |
//<<+----------------------------------------------------------------+{
// construct UDT (User defined type) containing the IDI (Intramarket Difference Index) source values 
// UDT will hold many variables / functions grouped under the UDT 
type functions 
    float Close // close price 
    float ma    // ma of symbol 
    float rsi   // rsi of the asset 
    float atr   // atr of the asset 

// the security data 
getUDTdata(symbol, malookback, rsilookback, atrlookback) =>
    indexHighTF = barstate.isrealtime ? 1 : 0
    [close_, ma_, rsi_, atr_] = request.security(symbol, timeframe = timeframe.period, 
         expression = [close[indexHighTF], // Instentiate UDT variables
          ta.sma(close, malookback)[indexHighTF],
           ta.rsi(close, rsilookback)[indexHighTF], 
           ta.atr(atrlookback)[indexHighTF]])
    data = functions.new(close_, ma_, rsi_, atr_)  
    data    
    
// Intramerket Difference Index  
idi(type, symbol1, malookback, rsilookback, atrlookback, mathreshold, rsithreshold) =>
    threshold = float(na)
    index1 = getUDTdata(symbol1, malookback, rsilookback, atrlookback)
    index2 = getUDTdata(syminfo.tickerid, malookback, rsilookback, atrlookback)
    // declare difference variables for both base and quote symbols, conditional on which difference type is selected
    var diffindex1 = 0.0, var diffindex2 = 0.0, 
    // declare Intramarket Difference Index based on series type, note 
    // if > 0, index 2 outpreforms index 1, buy index 2 (momentum based) until equalibrium
    // if < 0, index 2 underpreforms index 1, sell index 1 (momentum based) until equalibrium
    // for idi to be valid both series must be stationary and normalised so both series hae he same scale  
    intramarket_difference = 0.0
    if type == "MA" 
        threshold := mathreshold
        diffindex1 := (index1.Close - index1.ma) / math.pow(index1.atr*malookback, 0.5)
        diffindex2 := (index2.Close - index2.ma) / math.pow(index2.atr*malookback, 0.5)
        intramarket_difference := diffindex2 - diffindex1
    else if type == "RSI"
        threshold := rsilookback
        diffindex1 := index1.rsi 
        diffindex2 := index2.rsi 
        intramarket_difference := diffindex2 - diffindex1
    [index1, index2, diffindex1, diffindex2, intramarket_difference, threshold]
  
//>>+----------------------------------------------------------------+}
//                                        STRATEGY FUNCTIONS CALLS |
//<<+----------------------------------------------------------------+{
// plot the intramarket difference
[index1, index2, diffindex1, diffindex2, intramarket_difference, threshold] = idi(type, 
                                                                                 ui_index_1, 
                                                                                 ui_ma_lkb, 
                                                                                 ui_rsi_lkb, 
                                                                                 ui_atr_lkb, 
                                                                                 ui_ma_threshold, 
                                                                                 ui_rsi_threshold)

//>>+----------------------------------------------------------------+}

plot(intramarket_difference, color = color.orange)
hline(type == "MA" ? ui_ma_threshold : ui_rsi_threshold, color = color.green)
hline(type == "MA" ? -ui_ma_threshold : -ui_rsi_threshold, color = color.red)
hline(0)
[/pine]

Note it is possible that after printing a buy the strategy then prints many sell signals before returning to a buy, which again has the same implication (less profit. Potentially because we exit early only for price to continue upwards hence missing the larger "trend"). The image below showcases this cenario and again, by allowing our winner to run we may capture more profit (theoretically). 

This should be clear...
https://www.tradingview.com/x/ClGMJibB/

🔸 [b]Mean Reversion Case:[/b]

We stated prior that mean reversion of anomalies is an standerdies fact of financial data, how can we exploit this ?

We exploit this by normalizing the ID by applying the Ehlers fisher transformation. The transformed data is then assumed to be approximately normally distributed. To form the strategy we employ the same logic as for the z score, if the FT normalized ID > 2.5 (< -2.5) we buy (short). Our exit conditions remain unchanged (fixed ATR stop and trailing Donchian Trailing stop) 

🔷 [b]Position Sizing:[/b]

If ‘‘Fixed Risk From Initial Balance’’ is toggled true this means we risk a fixed percentage of our initial balance, if false we risk a fixed percentage of our equity (current balance). 

Note we also employ a volatility adjusted position sizing formula, the turtle training method which is defined as follows. 

Turtle position size = (1/ r * ATR * DV) * C

Where,
r = risk factor coefficient (default is 20)
ATR(j) = risk proxy, over j times steps 
DV = Dollar Volatility, where DV = (1/Asset Price) * Capital at Risk

🔷 [b] Risk Management:[/b]

Correct money management means we can limit risk and increase reward (theoretically). Here we employ
[list=1]
[*]Max loss and gain per day 
[*]Max loss per trade
[*]Max number of consecutive losing trades until trade skip 
[/list]
[i]To read more see the tooltips (info circle). [/i]

🔷 [b]Take Profit:[/b]

By defualt the script uses a Donchain Channel as a trailing stop and take profit, In addition to this the script defines a fixed ATR stop losses (by defualt, this covers cases where the DC range may be to wide making a fixed ATR stop usefull), ATR take profits however are defined but optional. 

https://www.tradingview.com/x/ZE8XsabK/
[i]ATR SL and TP defined for all trades[/i]

🔷 [b]Hurst Regime (Regime Filter):[/b] 

The Hurst Exponent (H) aims to segment the market into three different states, Trending (H > 0.5), Random Geometric Brownian Motion (H = 0.5) and Mean Reverting / Contrarian (H < 0.5). In my interpretation this can be used as a trend filter that eliminates market noise. 

We utilize the trending and mean reverting based states, as extra conditions required for valid trades for both strategy types respectively, in the process increasing our trade entry quality.

🔷 [b]Example model Architecture:[/b]

Here is an example of one configuration of this strategy, combining all aspects discussed in this post.

https://www.tradingview.com/x/yCl8lw72

[b]Future Updates[/b]

- Automation integration (next update)

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Amjad_S
//@version=5


//  ▀█▀ ▒█▀▀▄ ▀█▀ 　 ▒█▀▀▀█ ▀▀█▀▀ ▒█▀▀█ ░█▀▀█ ▀▀█▀▀ ▒█▀▀▀ ▒█▀▀█ ▒█░░▒█ 
//  ▒█░ ▒█░▒█ ▒█░ 　 ░▀▀▀▄▄ ░▒█░░ ▒█▄▄▀ ▒█▄▄█ ░▒█░░ ▒█▀▀▀ ▒█░▄▄ ▒█▄▄▄█ 
//  ▄█▄ ▒█▄▄▀ ▄█▄ 　 ▒█▄▄▄█ ░▒█░░ ▒█░▒█ ▒█░▒█ ░▒█░░ ▒█▄▄▄ ▒█▄▄█ ░░▒█░░ 

//+------------------------------------------------------------------+
//                                                     STRATEGY CALL |
//<<+----------------------------------------------------------------+{
strategy(title = "Intramarket Difference Index",
     shorttitle = "IDI", 
     overlay = true,
     initial_capital = 1000,
     default_qty_type = strategy.percent_of_equity,
     default_qty_value = 100,
     commission_type = strategy.commission.percent,
     commission_value = 0.02,
     slippage = 0,
     pyramiding = 0, 
     calc_on_every_tick = false,
     calc_on_order_fills = false,
     margin_long = 0,
     margin_short = 0)

//>>+----------------------------------------------------------------+}
//                                                           IMPORTS |
//<<+----------------------------------------------------------------+{
import TradingView/ta/7

//>>+----------------------------------------------------------------+}
//                                                     BACKTEST TIME |
//<<+----------------------------------------------------------------+{  
// Date and Time
var string g_backtest_time = "Backtest Time Range"
start_date = input.time(timestamp("2007-01-01T00:00:00"), group = g_backtest_time) // Unix time is a system for representing a point in time.
end_date = input.time(timestamp("9999-01-01T00:00:00"), group = g_backtest_time)   

// trade period function 
period() => 
    time >= start_date and time <= end_date ? true : false

//>>+----------------------------------------------------------------+}
//                                                    PINE CONNECTER |
//<<+----------------------------------------------------------------+{
// future update...

//>>+----------------------------------------------------------------+}
//                                                       USER INPUTS |
//<<+----------------------------------------------------------------+{
// ORDER TYPES 
var string g_order_type = "strategy order types"
ui_order_buy = input.bool(true, title = "Buy Orders", group = g_order_type)
ui_order_sell = input.bool(true, title = "Sell Orders", group = g_order_type)
// POSITION SIZING 
var string g_postion_sizing = "position sizing"
startbalance = strategy.initial_capital
ui_fixed_risk = input.bool(true, title = 'Fixed Risk From Initial Balance', group = g_postion_sizing)
ui_equity_risk = input.float(0.02, title = "Percentage of Acount Risk", group = g_postion_sizing)
ui_use_lot = input.bool(false, title = "Use Lot order fromat instaed of UNITS", group = g_postion_sizing)
// TURTULE TRADING POSITION SIZING 
var string g_tt = "turtule trading position sizing"
ui_turtule = input.bool(false, title = "Use Volatility Adjusted Position Sizing", group = g_tt)
ui_tt_atr_lkb = input.int(20, title = "ATR lookback (risk proxy)", group = g_tt) 
ui_tt_risk_coefficient = input.float(20, title = "Risk Factor", group = g_tt)
// RISK MANAGEMENT
var string g_rm = 'risk management'
string info_max_loss_daily = 'We want to cut our losses short (This script includes fixed ATR based stops, Donchian Channel trailing stops and fixed value amount based stops) and capture volatile price extensions'
     + ' which otherwise may not be captured by the Donchian trailing stop. Here we define a fixed max % amount of our initial account balance (which can be changed in strategy properties)'
     + ' that we are willing to lose and gain per day, i.e. a maximum loss and gain per day.'
string info_max_loss_trade = 'We want to cut our losses short (This script includes fixed ATR based stops, Donchian Channel trailing stops and fixed value amount based stops).'
     + ' Here we define a maximum % amount of our initial balance (which can be changed in strategy properties) we are willing to lose per trade.'
     + ' This should be >> the maximum loss per day, if not the maximum loss per trade is the maximum loss per day.'
ui_use_max_per_day = input.bool(false, title = 'Use Maximum Loss & Gain Per Day', tooltip = info_max_loss_daily, group = g_rm)
ui_max_loss_per_day = input.float(0.50, title = 'Maximum Intraday Trade Loss % of initial balance', group = g_rm) 
ui_max_gain_per_day = input.float(2.00, title = 'Maximum Intraday Trade Gain % of initial balance', group = g_rm)
ui_use_max_per_trade = input.bool(false, title = 'Use Maximum Loss Per Trade', tooltip = info_max_loss_trade, group = g_rm)
ui_max_loss_per_trade = input.float(1.50, title = 'Maximum Trade Loss % of initial balance', group = g_rm)
ui_use_consec_loss = input.bool(false, title = 'Use Maximum Number of Consecutive Losses', group = g_rm)
ui_consec_loosers = input.int(3, title = 'Number of Consecutive Trade Loosers before skip', group = g_rm)
// STOP LOSS IN PIPS
// var string g_sl = "stop loss in pips"
// ui_tp_pips = input.float(100.0, title = "pips TP (BUY 1)", step = 1, group = g_sl)
// ATR STOP
var string g_atr_stop = "ATR TP"
string info_atr = 'This Strategy by defualt uses ATR based stops, ATR based take profits however are optional'
ui_atr_tp = input.bool(false, title = "ATR take profit", tooltip = info_atr, group = g_atr_stop)
ui_atr_lkb_sl_tp = input.int(300, title = "ATR lookback", group = g_atr_stop)
ui_atr_mult_sl = input.float(3, title = "ATR stop loss multiplier", step = 1, group = g_atr_stop)
ui_atr_mult_tp = input.float(3, title = "ATR take profit multiplier", step = 1, group = g_atr_stop)
// DONCHIAN CHANNEL EXIT 
var string g_trade_exit = "donchian trade exit"
ui_don_source = input.source(close, title = "Source for Donchian calculation", group = g_trade_exit)
ui_don_uc_lkb = input.int(60, title = "Source of Donchian Upper Channel", group = g_trade_exit)
ui_don_lc_lkb = input.int(60, title = "Source of Donchian Lower Channel", group = g_trade_exit)
ui_don_source_lock = input.timeframe("CHART", title = "Time frame to lock", options = ["CHART", "D", "240", "120", "60", "30", "15", "5"], group = g_trade_exit)
atr = ta.atr(ui_atr_lkb_sl_tp)
// REGIME FILTERS 
var g_regime = "hurst regime filter"
ui_hurst_regime = input.bool(false, title = "Hurst coefficent Strategy Regime", group = g_regime)
ui_hurst_lkb = input.int(title="Coeffecient Length", defval=30, minval=1, group = g_regime)
ui_hurst_ssfLength = input.int(title="SSFLength", defval=20, minval=1, group = g_regime)
ui_hurst_threshold = input.float(title ="Threshold Value", defval = 0.51, step = 0.01, group = g_regime)
// STRATEGY TYPE
var g_strategy_type = "strategy type"
string ui_strategy_type = input.string("TREND", title = "Strategy Type", options = ["TREND", "MEAN REVERSION"], group = g_strategy_type)
// INTRAMARKET INDEX 
var string g_idi = "intramarket diffirence index"
ui_index_1 = input.symbol("BINANCE:BTCUSD", title = "Base market", group = g_idi)
// ui_index_2 = input.symbol("BINANCE:ETHUSD", title = "Quote Market", group = g_idi)
type = input.string("MA", title = "Differrencing Series", options = ["MA", "RSI"], group = g_idi)
ui_ma_lkb = input.int(24, title = "lookback of ma and volatility scaling constant", group = g_idi)
ui_rsi_lkb = input.int(14, title = "Lookback of RSI", group = g_idi) 
ui_atr_lkb = input.int(300, title = "ATR lookback - Normalising value", group = g_idi)
ui_ma_threshold = input.float(5, title = "Threshold of Upward/Downward Trend (MA)", group = g_idi)
ui_rsi_threshold = input.float(20, title = "Threshold of Upward/Downward Trend (RSI)", group = g_idi)
// NORMALISING FUNCTION
var string g_norm_ft = "fisher transform normalising"
ui_ft_lkb = input.int(10, title = "Fisher Transformation lookback period", group = g_norm_ft)
ui_ft_lkb_avg = input.int(5, title = "Lagged Fisher Transformation Trigger lookback period", group = g_norm_ft)
// CORRELATION 
// var string g_corr = "correlation of market"
// ui_correlation_lkb = input.int(200, title = "Historical Correlation", group = g_corr)

//>>+----------------------------------------------------------------+}
//                          REGIME FILTERS: EHLERS HURST COEFFICIENT |
//<<+----------------------------------------------------------------+{
// Hurst coefficient to measure market persistance i.e. momentum  
// The regime is not directional, the breakout of the IDI will solve this 
// HURST COEFICIENT - LOW PASS FILTER  
// Code by @cheatcountry 
pi = 2 * math.asin(1)
alpha = math.exp(-1.414 * pi / ui_hurst_ssfLength)
beta = 2 * alpha * math.cos(1.414 * pi / ui_hurst_ssfLength)
c2 = beta
c3 = -alpha * alpha
c1 = 1 - c2 - c3
hLength = math.ceil(ui_hurst_lkb / 2)

n3 = (ta.highest(close, ui_hurst_lkb) - ta.lowest(close, ui_hurst_lkb)) / ui_hurst_lkb
hh = close, ll = close
for i = 0 to hLength - 1
    price = nz(close[i])
    hh := price > hh ? price : hh
    ll := price < ll ? price : ll
    
n1 = (hh - ll) / hLength
hh := nz(close[hLength])
ll := nz(close[hLength])
for i = hLength to ui_hurst_lkb - 1
    price = nz(close[i])
    hh := price > hh ? price : hh
    ll := price < ll ? price : ll
    
n2 = (hh - ll) / hLength
dimen = 0.0
dimen := n1 > 0 and n2 > 0 and n3 > 0 ? 0.5 * (((math.log(n1 + n2) - math.log(n3)) / math.log(2)) + dimen[1]) : 0
hurst = 2 - dimen

smoothHurst = 0.0
smoothHurst := (c1 * ((hurst + nz(hurst[1])) / 2)) + (c2 * nz(smoothHurst[1])) + (c3 * nz(smoothHurst[2]))

//>>+----------------------------------------------------------------+}
//                                           STRATEGY REGIMES STATES |
//<<+----------------------------------------------------------------+{
bool market_persistance = ui_hurst_regime == true ? smoothHurst >= ui_hurst_threshold : true 
bool mean_reverseion = ui_hurst_regime == true ? smoothHurst < ui_hurst_threshold : true 

//>>+----------------------------------------------------------------+}
//                                                  CUSTOM FUNCTIONS |
//<<+----------------------------------------------------------------+{
// construct UDT (User defined type) containing the IDI (Intramarket Difference Index) source values 
// UDT will hold many variables / functions grouped under the UDT 
type functions 
    float Close // close price 
    float ma    // ma of symbol 
    float rsi   // rsi of the asset 
    float atr   // atr of the asset 

// the security data 
getUDTdata(symbol, malookback, rsilookback, atrlookback) =>
    indexHighTF = barstate.isrealtime ? 1 : 0
    [close_, ma_, rsi_, atr_] = request.security(symbol, timeframe = timeframe.period, 
         expression = [close[indexHighTF], // Instentiate UDT variables
          ta.sma(close, malookback)[indexHighTF],
           ta.rsi(close, rsilookback)[indexHighTF], 
           ta.atr(atrlookback)[indexHighTF]])
    data = functions.new(close_, ma_, rsi_, atr_)  
    data    
    
// Intramerket Difference Index  
idi(type, symbol1, malookback, rsilookback, atrlookback, mathreshold, rsithreshold) =>
    threshold = float(na)
    index1 = getUDTdata(symbol1, malookback, rsilookback, atrlookback)
    index2 = getUDTdata(syminfo.tickerid, malookback, rsilookback, atrlookback)
    // declare difference variables for both base and quote symbols, conditional on which difference type is selected
    var diffindex1 = 0.0, var diffindex2 = 0.0, 
    // declare Intramarket Difference Index based on series type, note 
    // if > 0, index 2 outpreforms index 1, buy index 2 (momentum based) until equalibrium
    // if < 0, index 2 underpreforms index 1, sell index 1 (momentum based) until equalibrium
    // for idi to be valid both series must be stationary and normalised so both series hae he same scale  
    intramarket_difference = 0.0
    if type == "MA" 
        threshold := mathreshold
        diffindex1 := (index1.Close - index1.ma) / math.pow(index1.atr*malookback, 0.5)
        diffindex2 := (index2.Close - index2.ma) / math.pow(index2.atr*malookback, 0.5)
        intramarket_difference := diffindex2 - diffindex1
    else if type == "RSI"
        threshold := rsilookback
        diffindex1 := index1.rsi 
        diffindex2 := index2.rsi 
        intramarket_difference := diffindex2 - diffindex1
    [index1, index2, diffindex1, diffindex2, intramarket_difference, threshold]
  
//>>+----------------------------------------------------------------+}
//                                          STRATEGY FUNCTIONS CALLS |
//<<+----------------------------------------------------------------+{
// plot the intramarket difference
[index1, index2, diffindex1, diffindex2, intramarket_difference, threshold] = idi(type, 
                                                                                 ui_index_1, 
                                                                                 ui_ma_lkb, 
                                                                                 ui_rsi_lkb, 
                                                                                 ui_atr_lkb, 
                                                                                 ui_ma_threshold, 
                                                                                 ui_rsi_threshold)

// correlation moving average
// corr = ta.correlation(index1.Close, index2.Close, ui_correlation_lkb)

// hline(0)
// plot(intramarket_difference)
// plot(corr, color = color.red)

//>>+----------------------------------------------------------------+}
//                                          STRATEGY FUNCTIONS CALLS |
//<<+----------------------------------------------------------------+{
// indicator Normalising
// The IDI uses differences between indicators derived from price action from different symbols which are not normaly distribted
// i.e. the IDI is not normally distribted
// we can normalise the IDI by applying the fisher transform 
// Fisher Transform
FT(src_, lkb_, lkb_avg_) => 
    // max and min of time series 
    float maxH = ta.highest(src_, lkb_)
    float minL = ta.lowest(src_, lkb_)
    // Gussian normal distribution Transform 
    var float val1 = 0
    // alpha smoothing of 0.33
    val1 := na(val1[1]) ? 0.33 * 2 * ((src_ - minL) / (maxH - minL) - 0.5) + (0.67 * nz(val1[1], 0)) : 
         0.33 * 2 * ((src_ - minL) / (maxH - minL) - 0.5) + (0.67 * val1[1])
    if val1 > 0.99 
        val1 := 0.999
    else if val1 < -0.99
        val1 := -0.999
    // fish transform
    var float fish_trsf = 0
    fish_trsf :=  na(fish_trsf[1]) ? 0.5 * math.log((1 + val1) / (1 - val1)) + (0.5 * nz(fish_trsf[1], 0)) :
         0.5 * math.log((1 + val1) / (1 - val1)) + (0.5 * fish_trsf[1])
    // Trigger line
    fish_trsf_lag = ta.sma(fish_trsf, lkb_avg_)
    // Function Sub function call
    [fish_trsf, fish_trsf_lag]

// function call 
[fish_trsf, fish_trsf_lag] = FT(intramarket_difference, ui_ft_lkb, ui_ft_lkb_avg)

// // plot 
// hline(2)
// hline(0)
// hline(-2)
// plot(fish_trsf)
// plot(fish_trsf_lag)

//>>+----------------------------------------------------------------+}
//                                          STRATEGY POSITION SIZING |
//<<+----------------------------------------------------------------+{
// currency conversion, code by @ZenAndTheArtOfTrading
AcountequalQcurrency = strategy.account_currency == syminfo.currency // for GBPUSD will return USD
AcountequalBcurrency = strategy.account_currency == syminfo.basecurrency // for GBPUSD will reurn GBP
AcountnotQB = not AcountequalBcurrency and not AcountequalQcurrency // acount currency not equal to either symbol denominated curency
// construct the custom pair, and call if fx pair is true 
conversionPair = AcountequalQcurrency ? syminfo.tickerid : strategy.account_currency + syminfo.currency // account currency plus quote symbol currency
conversionRate = AcountnotQB or AcountequalBcurrency ? request.security(conversionPair, "D", close, ignore_invalid_symbol = true) : 1.0

// pip converison
Pip() => 
    if syminfo.type == "forex"
    // to convert to points (pips to points), note pip = 0.0001 
        syminfo.mintick * 10
    else if syminfo.type != "forex"
        syminfo.mintick * 1000

// turtule trading volatility adjusted position sizing 
TurtuleTrade(fC, rt, N, D) =>
    Unit = math.floor(fC/rt*N*D)

// trade order size 
GetPosTrade(float balance, 
         bool fixed = true, 
         bool volatility_adjusted = false, 
         float atr_tt, 
         float risk_coeff,
         float cent_risked, 
         float stoppoints, 
         conversion) =>
    var float net = na     
    var float risk_amount = na 
    var float Dollar_volatility = na 
    var float unit = na 
    var float positionsize = na 
    // doller for point move
    riskperpoint = stoppoints * syminfo.pointvalue
    if fixed == true
        risk_amount := (balance * cent_risked) * conversion 
    else if fixed != true
        net := strategy.grossprofit - strategy.grossloss
        risk_amount := ((balance + net) * cent_risked) * conversion
    if volatility_adjusted == false
        positionsize := risk_amount *  (1 / riskperpoint)
    else 
        // Turtule Trading position sizing takes both fixed or variable risk amount 
        // Dollar volatility is the the amount of value a $1 change in the contract would impact your portfolio.
        Dollar_volatility := risk_amount / stoppoints
        // The position scaling decreases as the risk coefficient increases, given all other variables are fixed 
        unit := TurtuleTrade(risk_amount, risk_coeff, atr_tt, Dollar_volatility)
        // standard risk has been scaled by unit, if risk increases, unit scaling will decrease, the opposite is true 
        positionsize := unit*risk_amount * (1 / stoppoints)
    math.round(positionsize, 2)

// units to lots calculation
UnitsToLot(float units) =>
    math.round((units / 100000), 2) 

// percentage to percentage amount of initial balance
PercentOfEquity(float percentage) =>
    res = (percentage/100)*startbalance
    res

//>>+----------------------------------------------------------------+}
//                                                           SL & TP |
//<<+----------------------------------------------------------------+{
// function is used to calculate stop loss and take profit for both long and short trades 
getSLandTPprice(ent, pips, bool b = true) =>
    var float SLorTP = na 
    if b == true
        SLorTP := ent - (pips * Pip())
    if b == false 
        SLorTP := ent + (pips * Pip())
    SLorTP

//>>+----------------------------------------------------------------+}
//                         TRADE ENTREY CONDITIONS (ANTI REPAINTING) |
//<<+----------------------------------------------------------------+{
// this function checks if the expression was false one bar ago 
lag(expression, bars) =>
    nz(expression[bars] == false, false) // Ensure non-null value 

// mean reversion signals and signal confermations 
momentum_buy = intramarket_difference >= threshold, momentum_sell = intramarket_difference <= -1*threshold
momentum_buy_confirm = momentum_buy[1] and lag(momentum_buy, 2) and market_persistance
momentum_sell_confirm = momentum_sell[1] and lag(momentum_sell, 2) and market_persistance

// momentum signals and signal confermation
mean_reversion_buy = fish_trsf >= 2.5, mean_reversion_sell = fish_trsf <= -2.5 
mean_reversion_buy_confirm = mean_reversion_buy[1] and lag(mean_reversion_buy, 2) and mean_reverseion
mean_reversion_sell_confirm = mean_reversion_sell[1] and lag(mean_reversion_sell, 2) and mean_reverseion 

//>>+----------------------------------------------------------------+}
//                                               STANDARDISE SIGNALS |
//<<+----------------------------------------------------------------+{
// standardise trade entry signals to two variable names based on strategy type 
StratgeySignalsStandardise(strategytype, signal_momentum_buy, signal_momentum_sell, signal_mean_reversion_buy, signal_mean_reversion_sell) =>
    [buy, sell] = switch strategytype // change tupels value based on switch
        "TREND" => [signal_momentum_buy, signal_momentum_sell]       
        "MEAN REVERSION" => [signal_mean_reversion_buy, signal_mean_reversion_sell]      
    [buy, sell]

// Standardise signals
[buy, sell] = StratgeySignalsStandardise(ui_strategy_type, 
     momentum_buy_confirm, momentum_sell_confirm, 
     mean_reversion_buy_confirm, mean_reversion_sell_confirm)

//>>+----------------------------------------------------------------+}
//                                      TRAILING STOP: DONCHIAN STOP |
//<<+----------------------------------------------------------------+{
// donchian trade exit 
donchian(source, lookbackofhigh, lookbackoflow, sourcelock) =>
    hc = ta.highest(close[1], lookbackofhigh)
    lc = ta.lowest(close[1], lookbackoflow)
    // get hh or ll depending on timeframe requested, timeframe requested should always be >= current timeframe
    UC = request.security(ticker.standard(syminfo.tickerid), timeframe = sourcelock == "CHART" ? timeframe.period : sourcelock, expression = hc)
    LC = request.security(ticker.standard(syminfo.tickerid), timeframe = sourcelock == "CHART" ? timeframe.period : sourcelock, expression = lc)
    mid_channel = (UC + LC) / 2 
    [UC, LC, mid_channel]

// call function
[UC, LC, mid_channel] = donchian(ui_don_source, ui_don_uc_lkb, ui_don_lc_lkb, sourcelock = ui_don_source_lock)

// print values 
plot(UC, title = "Donchian Upper Channel", color = color.aqua)
plot(LC, title = "Donchian Lower Channel", color = color.purple)
plot(mid_channel, title = "Donchian Middle Channel", color = color.gray)

// validate that the prioir DC is not making LL or HH (e.g. past LC of DC is making LL)
// if so then we should not go long / short as Channel is going in opposing direction of market position 
LC_invalidate = LC[1] < LC[2] and LC[1] < LC[3] and LC[1] < LC[4]
UC_invalidate = LC[1] > LC[2] and LC[1] > LC[3] and LC[1] > LC[4]
LC_valid = not LC_invalidate
UC_valid = not UC_invalidate

//>>+----------------------------------------------------------------+}
//                                                  TRADE VALIDATION |
//<<+----------------------------------------------------------------+{
// for buy trades bar close must be greater than 
in_range = close > LC and close < UC

// check if currrently not in trade (avoid closing and opening trade within one bar), we enter trade 1 bar after signal
validlong = buy and in_range and strategy.position_size[1] == 0 
validshort = sell and in_range and strategy.position_size[1] == 0

// signal plots 
plotshape(validlong, style = shape.triangleup, color = #10c900, location = location.belowbar, title = "valid long setup", size = size.normal)
plotshape(validshort, style = shape.triangledown, color = #ff0000, location = location.abovebar, title = "valid short setup", size = size.normal)
plotshape(buy and not validlong, style = shape.triangleup, color = #a4ff9c65, location = location.belowbar, title = "long setup", size = size.tiny)
plotshape(sell and not validshort, style = shape.triangledown, color = #ff7c7c70, location = location.abovebar, title = "short setup", size = size.tiny)


//>>+----------------------------------------------------------------+}
//                                                   RISK MANAGEMENT |
//<<+----------------------------------------------------------------+{
// General Rules
// 1) Let winners run and cut losses short 
// Fundemental Truths 
// 1) Their is a random distribution between wins and losses for any given set of variables that define and edge
// 2) Every moment in the market is unique
// Risk and Money Management 
// we must define 
// 1) Maximum loss per day 
// 2) Maximum loss per trade (> than max loss per day)
// 3) Maximum number of consecutive lossing trades before we skip the next trade 
// 4) Maximum number of losing trades in a day before we stop trading 
// 5) Maximum number of lossing trades in the same direction before we stop trading
// 6) If we are up $x on a single trade we put a profit floor of $x underneath the current price 
// 7) If we are up $y for the day, we will stop trading for the day even if we have valid trade signals

// 1-7) 
max_loss_gain_per_day(maxlossday_, maxgainday_) =>
    var tradeinvalid = bool(na)
    var day_start_equity = float(na), var day_profit = float(na)
    equity = strategy.initial_capital + strategy.netprofit + strategy.openprofit
    if ta.change(time('D')) == 0 // for 'bool', returns true when the current source is different from the previous source. i.e. when new day 
        day_start_equity := equity 
    else 
        day_profit := equity - day_start_equity
        if strategy.position_size != 0
            if day_profit <= maxlossday_ or day_profit >= maxgainday_
                tradeinvalid := true    
            else 
                tradeinvalid := false
        else 
            tradeinvalid := false
    tradeinvalid

// 2)
max_loss_per_trade(maxlosstrade_) =>
    var tradeinvalid = bool(na)
    if strategy.position_size != 0
        if strategy.openprofit < maxlosstrade_
            tradeinvalid := true
        else 
            tradeinvalid := false
    tradeinvalid

// 3)
// Inure that current code does not keep skipping trades indefinitely after the first trade skip
max_consec_l_trade(maxconsecutivelossingtrades_, bool tradesignallong,  bool tradesignalshort) =>
    // Initialize variables
    equity = strategy.initial_capital + strategy.netprofit + strategy.openprofit
    var float tradestartequity = na
    var bool tradeinvalid = false
    var int consecutiveloss = 0
    var bool tradeskipped = false

    // Determine if a buy or sell trade is open
    buytrade = strategy.position_size > 0
    selltrade = strategy.position_size < 0
    // Detect trade entries and exits
    buytradeentry = buytrade and strategy.position_size[1] == 0
    selltradeentry = selltrade and strategy.position_size[1] == 0
    trade_exit = strategy.position_size == 0 and (buytrade[1] or selltrade[1])

    // Handle trade entries
    if buytradeentry or selltradeentry
        tradestartequity := equity

    // Handle trade exits
    if trade_exit 
        // Check if the trade was a loss
        if equity < tradestartequity
            consecutiveloss += 1
        else
            consecutiveloss := 0 // Reset counter on winning trade

    if tradesignallong or tradesignalshort
        // Check if consecutive loss count exceeds the threshold
        if consecutiveloss >= maxconsecutivelossingtrades_ and not tradeskipped 
            tradeinvalid := true // Prepare to skip the next trade
        else if tradeskipped
            tradeinvalid := false // Allow trading again after skipping
            consecutiveloss := 0
            
    // Skip the next trade and reset counter
    if tradeinvalid
        tradeskipped := true  // Mark that the trade has been skipped

    // Return whether the trade is invalid due to consecutive losses
    tradeinvalid

//>>+----------------------------------------------------------------+}
//                                                      TRADE ENTREY |
//<<+----------------------------------------------------------------+{
non_paint = barstate.isrealtime ? 1 : 0
atr_turtule = ta.atr(ui_tt_atr_lkb)[non_paint]
// custom trade function 
tradeentry(bool orderconditionbuy, bool orderconditionsell) =>
    max_consec_l = max_consec_l_trade(ui_consec_loosers, 
                                         orderconditionbuy, 
                                         orderconditionsell) // requires trade skipped to be false
    var float entry        = na
    var float stoploss     = na
    var float stoplossdiff = na
    var float takeprofit   = na
    var float positionsize = na // calculated independantly from pine script strategy() calculation
    if period() 
        entry := orderconditionbuy or orderconditionsell ? open : na 
        stoploss := orderconditionbuy ? entry - atr[non_paint]*ui_atr_mult_sl :
                     orderconditionsell ? entry + atr[non_paint]*ui_atr_mult_sl : 
                     stoploss 
        stoplossdiff := math.abs(entry - stoploss)
        // in addtion to state based exits, trailing exits and fixed exits we also have a dynamic take profit
        takeprofit := orderconditionbuy and ui_atr_tp ? entry + atr[non_paint]*ui_atr_mult_tp :
                     orderconditionsell and ui_atr_tp ? entry - atr[non_paint]*ui_atr_mult_tp : 
                     takeprofit
        positionsize := GetPosTrade(balance = startbalance, 
                     fixed = ui_fixed_risk, 
                     volatility_adjusted = ui_turtule, 
                     atr_tt = atr_turtule,
                     risk_coeff = ui_tt_risk_coefficient, 
                     cent_risked = ui_equity_risk, 
                     stoppoints = stoplossdiff,
                     conversion = conversionRate)
    // Incorporating Risk Management to skip trade 
    if (ui_use_consec_loss ? not max_consec_l : true) // trades exacuted if max_consec_l is false
        if orderconditionbuy and ui_order_buy
            strategy.entry(id = "tradelong", direction = strategy.long, qty = ui_use_lot and syminfo.type == "forex" ? UnitsToLot(positionsize) : positionsize)
        else if orderconditionsell and ui_order_sell
            strategy.entry(id = "tradeshort", direction = strategy.short, qty = ui_use_lot and syminfo.type == "forex" ? UnitsToLot(positionsize) : positionsize)
        [entry, stoploss, stoplossdiff, takeprofit, positionsize]

// call for trade entry 
[entry, stoploss, stoplossdiff, takeprofit, positionsize] = tradeentry(orderconditionbuy = validlong, 
                                                                         orderconditionsell = validshort)

//>>+----------------------------------------------------------------+}
//                                               TRADE EXIT: SL & TP |
//<<+----------------------------------------------------------------+{
// TP and SL and risk are specafied in strategy alert, Therefore their is no need to enter alerts for trade exits specificly. This code is for trade exits on tradingview, this is required for the backtester to run 
// we do define a ATR take profit
// for buy 
strategy.exit(id = (ui_atr_tp ? 'ATRExitsBuy' : "ATRStopBuy"), 
     from_entry = "tradelong", 
     stop = stoploss, 
     limit = ui_atr_tp ? takeprofit : na, 
     qty_percent = 100)
// for sell 
strategy.exit(id = (ui_atr_tp ? 'ATRExitsSell' : "ATRStopSell"), 
     from_entry = "tradeshort", 
     stop = stoploss,
     limit = ui_atr_tp ? takeprofit : na, 
     qty_percent = 100)

//>>+----------------------------------------------------------------+}
//                                                TRAILING EXITS: DC |
//<<+----------------------------------------------------------------+{
// we will use a Market order to exit position, we do no define a take profit 
if strategy.position_size > 0
    if close <= LC or low <= LC
    // reapainting is fine, the "and" insures the we close trade without full loss
        strategy.close(id = "tradelong", qty_percent = 100, comment = 'DCTrailExitFromBuy')        
else if strategy.position_size < 0
    if close >= UC or high >= UC
        strategy.close(id = "tradeshort", qty_percent = 100, comment = 'DCTrailExitFromSell')        

//>>+----------------------------------------------------------------+}
//                                              RISK MANAGEMENT EXITS |
//<<+----------------------------------------------------------------+{
max_l_w_day = max_loss_gain_per_day(-PercentOfEquity(ui_max_loss_per_day), PercentOfEquity(ui_max_gain_per_day))
max_trade_loss = max_loss_per_trade(-PercentOfEquity(ui_max_loss_per_trade))

if ui_use_max_per_day 
    if max_l_w_day 
        strategy.close_all(comment = 'MaxLossDayReached', immediately = true) // we canot source the trade id causing the failing so we just close all trades open
if ui_use_max_per_trade 
    if max_trade_loss 
        strategy.close_all(comment = 'MaxLossTradeReached', immediately = true) 

//>>+----------------------------------------------------------------+}
//                                                     PLOTS: ATR SL |
//<<+----------------------------------------------------------------+{
atr_sl = plot(strategy.position_size != 0 ? stoploss : na,  color=color.red, style=plot.style_linebr, title="ATRStops")
atr_tp = plot(strategy.position_size != 0 and ui_atr_tp ? takeprofit : na, color=color.green, style=plot.style_linebr, title="ATRProfits")
````
