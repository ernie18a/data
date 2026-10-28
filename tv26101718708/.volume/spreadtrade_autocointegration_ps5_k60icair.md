# SpreadTrade - Auto-Cointegration (ps5)

- url: https://www.tradingview.com/script/k60icAir-SpreadTrade-Auto-Cointegration-ps5/
- type: indicator
- pine_id: PUB;39984da5a28042f683a3431ea086c509
- version: 2.0

## Description

Decsription: Auto-Cointegration-Based Pair Trading Strategy (revised version)

To review, there are three popular styles of Pair trading: distance-based pair trading, correlation-based pair trading and cointegration-based pair trading. Typically, they require preliminary statistical estimation of the viability of the corresponding strategy. 
Basically a pair trade strategy boils down to shorting the outperforming instrument and going long on the underperforming instrument whenever the temporary correlation weakens which means one instrument is going up and another is going down. Apart from the typical cointegration strategy which employs two cointegrated instruments, this script uses just one instrument, in base timeframe and in lagged timeframe, actually making it an auto-cointegration, or better still, an auto-correlation strategy.

Notice that each moving average function may require different Threshold settings.The orange cross symbol indicates the exit points. To filter out the signals use higher values for the LongWindow and the Threshold parameters. Also pay attention that in some cases with some moving averages the color of the signals has to be inverted.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © capissimo

//@version=5
indicator('SpreadTrade - Auto-Cointegration (ps5)', 'ST-AutoCI', false)

// Auto-Cointegration-Based Pair Trading Strategy (revised version)

// There are three popular styles of Pair trading: distance-based pair trading, 
// correlation-based pair trading and cointegration-based pair trading. Typically,
// they require preliminary statistical estimation of the viability of the
// corresponding strategy. 
// The Cointegration strategy boild down to shorting the outperforming instrument  
// and going long on the underperforming instrument whenever the temporary correlation 
// weakens which means one instrument is going up and another is going down.
// Apart from the typical cointegration strategy which employs two cointegrated 
// instruments, this script uses just one instrument, in base timeframe and in 
// lagged timeframe. So in fact this an auto-cointegration strategy, or better
// still, an auto-correlation strategy.
// Notice that each moving average function may require different Threshold 
// settings.Thr orange cross symbol indicates the exit points. To filter out
// the signals use higher values for the LongWindow and the Threshold parameters.
// Also pay attention that in some cases with some moving averages the color of
// the signals has to be inverted.

//-- Inputs

Dataset     = input.source   (close, 'Dataset')
Tframe      = input.timeframe('',    'Timeframe', tooltip='A timeframe of the lagged dataset used as a devisor in ratio')
ShortWindow = input.int      (2,     'Short Window [2..n]', 2, tooltip='A lookback period for the first moving average')  
LongWindow  = input.int      (1500,  'Long Window [3..m]',  3, tooltip='A lookback period for the second moving average') 
Maverage    = input.string   ('SMA', 'Moving Average Function', ['EMA','HMA','SMA','VWAP','WMA'])
Threshold   = input.float    (20.0,  'Z-Score Threshold [0.1..400.0]', minval=0.1, maxval=400.0, step=0.1)  // 0.1 for vwap
Ticks       = input.int      (252,   'Tick Threshold [2..500]', 2, 500, tooltip='Used for deciding on what bar to exit a trade')
Invert      = input.bool     (true,  'Invert the Color', tooltip='Occasionally signal color inversion is required')

//-- Constants

var int BUY   = 1
var int SELL  =-1
var int CLEAR = 0

//-- Variables

var int signal = CLEAR
var array<int> ticks = array.new<int>(1, 0) // array used as a container for inter-bar variables

//-- Logic

float lagged_dataset = request.security('', Tframe, Dataset[1])

float ratios = math.log(Dataset / lagged_dataset)

float mov_avg1 = switch Maverage
    'EMA'  => ta.ema (ratios, ShortWindow) 
    'HMA'  => ta.hma (ratios, ShortWindow) 
    'VWAP' => ta.vwap(ratios) 
    'WMA'  => ta.wma (ratios, ShortWindow) 
    => ta.sma(ratios, ShortWindow) 

float mov_avg2 = switch Maverage
    'EMA'  => ta.ema (ratios, LongWindow) 
    'HMA'  => ta.hma (ratios, LongWindow) 
    'VWAP' => ta.vwap(ratios[1]) 
    'WMA'  => ta.wma (ratios, LongWindow) 
    => ta.sma(ratios, LongWindow) 

float std_deviation = ta.stdev(mov_avg2, math.round(math.avg(ShortWindow, LongWindow)))
float z_score       = (mov_avg1 - mov_avg2) / std_deviation  // brings out the mean reverting nature of the ratio!

bool long  = z_score < -Threshold 
bool short = z_score >  Threshold 
bool clear = not(long and short)
 
// Ratio is BUY (+1) whenever the z-score is below -Threshold because we expect z-score to go back up to 0, hence ratio to increase
// Ratio is SELL(-1) whenever the z-score is above +Threshold because we expect z-score to go back down to 0, hence ratio to decrease
signal := long ? BUY : short ? SELL : clear ? CLEAR : nz(signal[1])

if array.get(ticks, 0)==Ticks
    signal := CLEAR
    array.set(ticks, 0, 0)
if signal == BUY
    array.set(ticks, 0, array.get(ticks, 0) + 1)
if signal == SELL
    array.set(ticks, 0, array.get(ticks, 0) + 1)

int  changed         = ta.change(signal)
bool long_condition  = changed and signal==BUY
bool short_condition = changed and signal==SELL
bool clear_condition = changed and signal==CLEAR

color clr_green = Invert ? color.red   : color.green
color clr_red   = Invert ? color.green : color.red

//-- Visuals

hline(Threshold,  'Upper Bound', color.red)
hline(-Threshold, 'Lower Bound', color.green)
plot(CLEAR,       'Midline',     color.silver, 1)
plot(z_score,     'Z-Score')
plot(long_condition  ? z_score : na, 'Sell Signal',     clr_green,      3, plot.style_circles)  
plot(short_condition ? z_score : na, 'Buy Signal',      clr_red,        3, plot.style_circles)
plot(clear_condition ? z_score : na, 'Clear Position',  color.orange, 2, plot.style_cross)

//-- Notification

if changed and signal==BUY 
    alert('Buy Alert', alert.freq_once_per_bar)  // alert.freq_once_per_bar_close
if changed and signal==SELL 
    alert('Sell Alert', alert.freq_once_per_bar)

alertcondition(long_condition,  'Buy',  'Go long!')
alertcondition(short_condition, 'Sell', 'Go short!') 
//alertcondition(long_condition or short_condition, 'Alert', 'Deal Time!')

// :End:
````
