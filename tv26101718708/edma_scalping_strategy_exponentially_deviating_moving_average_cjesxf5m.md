# EDMA Scalping Strategy (Exponentially Deviating Moving Average)

- url: https://www.tradingview.com/script/CJesxF5m-EDMA-Scalping-Strategy-Exponentially-Deviating-Moving-Average/
- type: strategy
- pine_id: PUB;2b21153f3b3b4f1ba3a369899903aa97
- version: 3.0

## Description

This strategy uses crossover of Exponentially Deviating Moving Average (MZ [url=https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/]EDMA[/url]) along with Exponential Moving Average for trades entry/exits. Exponentially Deviating Moving Average (MZ [url=https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/]EDMA[/url]) is derived from Exponential Moving Average to predict better exit in top reversal case.

[b][url=https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/]EDMA[/url]  Philosophy[/b]
[url=https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/]EDMA[/url] is calculated in following steps:
[list]
[*]In first step, Exponentially expanding moving line is calculated with same code as of EMA but with different smoothness (1 instead of 2).
[*]In 2nd step, Exponentially contracting moving line is calculated using 1st calculated line as source input and also using same code as of EMA but with different smoothness (1 instead of 2).
[*]In 3rd step, Hull Moving Average with 2/3 of [url=https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/]EDMA[/url] length is calculated using final line as source input. This final HMA will be equal to Exponentially Deviating Moving Average.
[/list]
[b][url=https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/]EDMA[/url] Defaults[/b]
Currently default [url=https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/]EDMA[/url] and EMA length is set to 20 period which I've found better for higher timeframes but this can be adjusted according to user's timeframe. I would soon add Multi Timeframe option in script too. [url=https://www.tradingview.com/script/7eyXMAn7-Chikou/]Chikou[/url] filter's period is set to 25.

[b]Additional Features[/b]
[list]
[*][b]EMA Band: [/b]EMA band is shown on chart to better visualize EMA cross with [url=https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/]EDMA[/url].
[*][b]Dynamic Coloring: [/b]Chikou Filter library is used for derivation of dynamic coloring of [url=https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/]EDMA[/url] and its band.
[*][b]Trade Confirmation with [url=https://www.tradingview.com/script/7eyXMAn7-Chikou/]Chikou[/url] Filter: [/b]Trend filteration from Chikou filter library is used as an option to enhance trades signals accuracy.

[b]Strategy Default Test Settings[/b]
For backtesting purpose, following settings are used:
[list]
[*]Initial capital=10000 USD
[*]Default quantity value = 5 % of total capital
[*]Commission value = 0.1 %
[*]Pyramiding isn't included.
[*]Backtesting data never assures that the same results would occur in future and also above settings use very less of total portfolio for trades, which in a way results less maximum drawdown along with less total profit on initial capital too. For example, increasing default quantity value will definity increase maximum drawdown value. The other way is also to use fix contracts in backtesting but it all depends on users general practice. Best option is to explore backtesting results with manually modified settings on different charts, before trusting them for other uses in future.
[/list]

[b]Usage and In-Detail Backtesting[/b]
[list]
[*]This strategy has built-in option to enable trade confirmations with [url=https://www.tradingview.com/script/7eyXMAn7-Chikou/]Chikou[/url] filter which will reduce the total number of trades increasing profit factor.
[*]Symmetrically Weighted Moving Average (SWMA) on input source, may risk repainting in real-time data. Better option is to run a trade on bar close or simply left this optin unchecked.
[*]I've set [url=https://www.tradingview.com/script/7eyXMAn7-Chikou/]Chikou[/url] filter unchecked  to increase number of trades (greater than 100) on higher timeframe (12H) and this can be changed according to your precision requirement and timeframe.
[*]Timeframes lower than 4H usually have more noise. So its better to use higher [url=https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/]EDMA[/url] and EMA length on lower timeframes which will decrease total number of offsetting trades increasing average total number of bars within a single trade. 
[/list]
Original "Exponentially Deviating Moving Average (MZ [url=https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/]EDMA[/url])" Indicator can be found here.
https://www.tradingview.com/script/x5PyksrR-Exponentially-Deviating-Moving-Average-MZ-EDMA/

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © MightyZinger

//@version=5

strategy('EDMA Scalping Strategy (Exponentially Deviating Moving Average)', shorttitle='MZ EDMA Strategy', overlay=true, initial_capital=10000, default_qty_type=strategy.percent_of_equity, default_qty_value=5, calc_on_every_tick=false, commission_type=strategy.commission.percent, commission_value=0.1)

import MightyZinger/Chikou/3 as filter


/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////
/////                     Source Options                       //////
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

// ─── Different Sources Options List ───► [
string SRC_Tv = 'Use traditional TradingView Sources '
string SRC_Wc = '(open+close+3(high+low))/8'
string SRC_Wo = 'close+high+low-2*open'
string SRC_Wu = '(close+5(high+low)-7(open))/4'
string SRC_Wi = '(open+close+5(high+low))/12'
string SRC_Exi = 'close>open ? high : low'
string SRC_Exj = 'Heiken-ashi(close>open) ? high : low'
string src_grp = 'Source Parameters'

// ●───────── Inputs ─────────● {
diff_src = input.string(SRC_Exi, '→ Different Sources Options', options=[SRC_Tv, SRC_Wc, SRC_Wo, SRC_Wu, SRC_Wi, SRC_Exi, SRC_Exj], group=src_grp)
i_sourceSetup = input.source(close, 'Tradingview Source Setup', group=src_grp)
i_Sym = input.bool(true, 'Apply Symmetrically Weighted Moving Average at the price source (May Result Repainting)', group=src_grp)

// Heikinashi Candles for calculations
f_ha_open() =>
    haopen   = float(na)
    haopen := na(haopen[1]) ? (open + close) / 2 : (nz(haopen[1]) + nz(ohlc4[1])) / 2
    haopen
h_open  = f_ha_open()

// Get Source 
src_o = diff_src == SRC_Wc ? (open+close+3*(high+low))/8 :
     diff_src == SRC_Wo ? close+high+low-2*open :
     diff_src == SRC_Wu ? (close+5*(high+low)-7*(open))/4 :
     diff_src == SRC_Wi ? (open+close+5*(high+low))/12 : 
     diff_src == SRC_Exi ? (close > open ? high : low) :
     diff_src == SRC_Exj ? (ohlc4 > h_open ? high : low) :
     i_sourceSetup
     
src_f = i_Sym ? ta.swma(src_o) : src_o  // Symmetrically Weighted Moving Average?

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

string grp1 = 'MA Parameters'
edma_Length = input.int(20, title='MA Length:', group=grp1)
i_Symmetrical = input(true, '‍ Apply Symmetrically Weighted Moving Average at EDMA')
ema1_Length = input.int(20, title='EMA 1 Length:', group=grp1)
show_ema1 = input(true, '‍ Show EMA 1')
ema2_Length = input.int(40, title='EMA 2 Length:', group=grp1)
show_ema2 = input(false, '‍ Show EMA 2')

string grp2 = 'Chikou Filter Parameters'
c_len = input.int(25, title='Chikou Period (Displaced Source)', group=grp2)
c_bull_col = input.color(color.green, 'Bull Color  ', group = grp2, inline='c_col')
c_bear_col = input.color(color.red, 'Bear Color  ', group = grp2, inline='c_col')
c_rvsl_col = input.color(color.yellow, 'Consollidation/Reversal Color  ', group = grp2, inline='c_col')

string grp3 = 'EMA Color Settings'
ema1_col = input.color(#2962FF, 'EMA 1 Color  ', group = grp3, inline='e_col')
ema2_col = input.color(#FF6D00, 'EMA 2 Color  ', group = grp3, inline='e_col')

string grp4 = 'ETrade Parameters'
showSignals = input.bool(true, title='Show Cross Alerts', group=grp4)
conf_chk = input.bool(false, title='Use Chikou Filter for Confirmation', group=grp4)
/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

// EDMA Function
f_edma(src, len)=>
    var hexp = float(na)    // Initiallizing Variables
    var lexp = float(na)
    var _hma = float(na)
    var _edma = float(na)
    float smoothness = 1.0  // Increasing smoothness will result in MA same as EMA
    h_len = int(len/1.5)    // Length to be used in final calculation of Hull Moving Average
    // Defining Exponentially Expanding Moving Line
    hexp := na(hexp[1]) ? src : src >= hexp[1] ? src : hexp[1] + (src - hexp[1]) * (smoothness / (len + 1))
    // Defining Exponentially Contracting Moving Line
    lexp := na(lexp[1]) ? hexp : src <= lexp[1] ? hexp : lexp[1] + (src - lexp[1]) * (smoothness / (len + 1))
    // Calculating Hull Moving Average of resulted Exponential Moving Line with 3/2 of total length
    _hma := ta.wma(2 * ta.wma(lexp, h_len / 2) - ta.wma(lexp, h_len), math.round(math.sqrt(h_len)))
    _edma := _hma   // EDMA will be equal to resulted smoothened Hull Moving Average
    _edma

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

edma = i_Symmetrical ? ta.swma(f_edma(src_f, edma_Length)) : f_edma(src_f, edma_Length)
ema1 = ta.ema(src_f, ema1_Length)
ema2 = ta.ema(src_f, ema2_Length)

// Calling Chikou filter function from library to obtaing dynamic color of EDMA Band and also Chikou Trend 
[edma_col, _trend] = filter.chikou(src_f, c_len, high, low, c_bull_col, c_bear_col, c_rvsl_col)  
edma_plot = plot(edma, title='EDMA', color= edma_col , linewidth=4)     // Plotting EDMA with dynamic color from Chikou Filter Function
ema1_plot = plot(show_ema1 ? ema1 : na, title='EMA 1', color= ema1_col , linewidth=3)
ema2_plot = plot(show_ema2 ? ema2 : na, title='EMA 2', color= ema2_col , linewidth=3)
fill(ema1_plot , edma_plot, title = "Background", color = color.new(edma_col,70)) // Filling the bands inbetween EMA and EDMA

/////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////

// Trade Signals and Alerts

L1 = ema2 > edma    // Weak Uptrend Condition
L2 = ema1 > edma    // Strong Uptrend Condition
L3 = _trend == 1    // Chikou Filter Uptrend Condition

S1 = ema2 < edma    // Weak Downtrend Condition
S2 = ema1 < edma    // Strong Downtrend Condition
S3 = _trend == -1   // Chikou Filter Downtrend Condition

// Setting confirmation conditional operator for Chikou Filter
weak_up = conf_chk ? L1 and L3 : L1
strong_up = conf_chk ? L2 and L3 : L2
weak_dn = conf_chk ? S1 and S3 : S1
strong_dn = conf_chk ? S2 and S3 : S2

// Defining condition equivalent to Crossover & Crossunder
bool[] signal_a = array.from(weak_up, strong_up, weak_dn, strong_dn)
var swing_a = array.new_int(2)

f_signal()=>
    for i = 0 to 1
        var sig = 0
        if array.get(signal_a, i) and sig <= 0
            sig := 1
        if array.get(signal_a, i+2) and sig >= 0
            sig := -1
        array.set(swing_a, i, sig)    

f_signal()

buy_weak = array.get(swing_a, 0) == 1 and array.get(swing_a, 0)[1] != 1 
buy_strong =  array.get(swing_a, 1) == 1 and array.get(swing_a, 1)[1] != 1 
sell_weak = array.get(swing_a, 0) == -1 and array.get(swing_a, 0)[1] != -1 
sell_strong =  array.get(swing_a, 1) == -1 and array.get(swing_a, 1)[1] != -1 

// Plotting Signals on Chart
//atrOver = 0.7 * ta.atr(5)   // Atr to place alert shape on chart
//plotshape(showSignals and buy_strong ? (low - atrOver) : na, style=shape.triangleup, color=color.new(color.green, 30), location=location.absolute, text='Buy', size=size.small)
//plotshape(showSignals and sell_strong ? (high + atrOver) : na, style=shape.triangledown, color=color.new(color.red, 30), location=location.absolute, text='Sell', size=size.small)

strategy.close('sell', when = buy_strong)
strategy.entry("buy", strategy.long, when = buy_strong)
strategy.close('buy', when = sell_strong)
strategy.entry("sell", strategy.short, when = sell_strong)
````
