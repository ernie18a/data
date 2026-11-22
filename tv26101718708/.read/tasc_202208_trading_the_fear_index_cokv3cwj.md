# TASC 2022.08 Trading The Fear Index

- url: https://www.tradingview.com/script/COkv3CwJ-TASC-2022-08-Trading-The-Fear-Index/
- type: strategy
- pine_id: PUB;e2095018a730448caa1b12d67c803667
- version: 1.0

## Description

█ OVERVIEW

[url=https://traders.com/Documentation/FEEDbk_docs/2022/08/TradersTips.html]TASC's August 2022 edition of Traders' Tips[/url] includes an article by Markos Katsanos titled "Trading The Fear Index". This script implements a trading strategy called the “daily long/short trading system for ​volatility ETFs” presented in this article.

█ CONCEPTS

This long-term strategy aims to capitalize on stock market [url=https://en.wikipedia.org/wiki/Volatility_(finance)]volatility[/url] by using [url=https://en.wikipedia.org/wiki/Exchange-traded_fund]exchange-traded funds[/url] (ETFs or ETNs) linked to the [url=https://en.wikipedia.org/wiki/VIX]VIX[/url] index.

The strategy rules (see below) are based on a combination of the movement of the ​Cboe [symbol="CBOE:VIX"]VIX[/symbol] index, the readings of the [url=https://en.wikipedia.org/wiki/Stochastic_oscillator]stochastic oscillator[/url] applied to the [symbol="AMEX:SPY"]SPY[/symbol] ​ETF relative to the ​​VIX, and a custom indicator presented in the article and called the [i]correlation trend[/i]. Thus, they are not based on the price movement of the traded ​ETF itself, but rather on the movement of the ​VIX and of the [symbol="SP:SPX"]S&P 500[/symbol] index. This allows the strategy to capture most of the spikes in ​volatility while profiting from the long-term time decay of the traded ETFs. 

█ STRATEGY RULES

[b]Long rules[/b]
[list]
[*] Rising ​volatility: The ​VIX should rise by more than 50% in the last 6 days.
[*] Trend: The [i]correlation trend[/i] of the ​VIX should be 0.8 or higher and also higher than yesterday's value.
[*] ​VIX-​SPY relative position: The 25-day and 10-day ​VIX ​stochastics should be above the 25-day and 10-day ​SPY ​stochastics respectively. In addition, the 10-day ​stochastic of the ​VIX should be above its yesterday's value.
[/list]
Long positions are closed if the 10-day ​stochastic of the ​SPY rises above the 10-day ​​stochastic of the ​VIX or falls below the yesterday's value.

[b]Short rules[/b]
[list]
[*] Declining ​volatility: The ​VIX should drop over 20% in the last 6 days and should be down during the last 3 days.
[*] ​VIX threshold: The ​VIX should spend less than 35% of time below 15.
[*] ​VIX-​SPY relative position: The 10-day ​VIX ​stochastic should be below the 10-day ​SPY ​stochastic. In addition, the 10-day ​SPY ​stochastic should be higher than the yesterday's value.
[/list]
Long positions are closed if the first two Long rules are triggered (Rising ​volatility and Trend).

The script allows you to display the readings of the indicators used in the strategy rules in the form of oscillator time series (as in the preview chart) and/or in the form of a table.

## Source Code

````pine
//  TASC Issue: August 2022 - Vol. 40, Issue 9
//     Article: Trading The Fear Index
//              There Is Nothing To Fear But Fear Itself
//  Article By: Markos Katsanos
//    Language: TradingView's Pine Script v5
// Provided By: PineCoders, for tradingview.com

// @version=5
strategy('TASC 2022.08 Trading The Fear Index', 'TTFI', false,
                 default_qty_type= strategy.percent_of_equity,
                 commission_type= strategy.commission.percent,
                 currency=currency.USD, initial_capital=10000,
                 default_qty_value=100, commission_value=0.01)
chl() =>
    [close, high, low]

isntVixETF() =>
    VIX_ETFs = array.from('VXX', 'VIXY', 'UVXY', 'VIXM', 
                      'VXZ', 'SVOL', 'SVXY')
    notVETF = not array.includes(VIX_ETFs, syminfo.ticker)
    notVETF

if isntVixETF()
    runtime.error('ERR: This is only intended for VIX ETFs '+
     '(tickers: VXX, VIXY, UVXY, VIXM, VXZ, SVOL, and SVXY)')

string SC= 'Strategy Configurations'
directiv = input.string( 'Long/Short', 'Direction(s) Allowed',
  options=['Long Only', 'Long/Short', 'Short Only'], group=SC)
strtTime = input.time(timestamp('2020-01-01'),  'Start Time:',
                                     inline='sTime', group=SC)
startON  = input(true, '', 'Start time of observation window.'
 +' The checkbox enables/disables the Start Time','sTime', SC)
endTime  = input.time(timestamp('2022-01-01'), '   End Time:',
                                     inline='eTime', group=SC)
lapseON  = input(true, '', 'Lapse Time of observation window.'
  +' The checkbox enables/disables the End Time', 'eTime', SC)

showAlgo = input.string('STVIXS/STVIXL', 'Display Indicators',
  options= ['STVIXS/STVIXL', 'STSPYS/STSPYL', 'STVIXL/STSPYL',
                 'STVIXS/STSPYS', 'VIXUP/VIXDN', 'RC', 'VIX'])

string SI= 'Stochastic Indicator Adjustments'
STBARSS  = input.int(10, 'Fast Period', 10, 15, 5, group=SI)
STBARSL  = input.int(25, 'Slow Period', 25, 30, 5, group=SI)

string VI= 'Adjustments for VIX Indicators'
vixIndex = input.string('CBOE:VIX', 'Select Volatility Index',
                   options=['CBOE:VIX', 'TVC:VIX'], group=VI)
VBARS    = input.int( 6, 'VIX Period',    5, 10, 1, group=VI)
VIXUPMAX = input.int(50, 'VIX Threshold',40, 60, 1, group=VI)

string TP   = 'Table Preferences'
showTable   = input.bool(true, 'Display Data Table', group=TP)
tableRegion = input.string(  position.middle_center, group=TP,
      tooltip='Optimize Your View', title='Table Positioning',
       options=[ position.bottom_left, position.bottom_center,
                 position.middle_left, position.middle_center,
                 position.top_left,    position.top_center  ])
 
string TFP        = timeframe.period
[VIX, VIXH, VIXL] = request.security(vixIndex, TFP, chl())
[SPY, SPYH, SPYL] = request.security(   'SPY', TFP, chl())

STVIXS = ta.sma(ta.stoch(VIX, VIXH, VIXL, STBARSS), 3)
STSPYS = ta.sma(ta.stoch(SPY, SPYH, SPYL, STBARSS), 3)
STVIXL = ta.sma(ta.stoch(VIX, VIXH, VIXL, STBARSL), 3)
STSPYL = ta.sma(ta.stoch(SPY, SPYH, SPYL, STBARSL), 3)
VIXUP  = (VIXH /  ta.lowest(VIXL, VBARS)[1] - 1.0) * 100.0
VIXDN  = ( VIX / ta.highest( VIX, VBARS)[1] - 1.0) * 100.0
RC     = ta.correlation(VIX, bar_index, VBARS-1)

plot(showAlgo=='STVIXS/STVIXL' ? STVIXS : na, '', #FF0000)
plot(showAlgo=='STVIXS/STVIXL' ? STVIXL : na, '', #0080FF)
plot(showAlgo=='STSPYS/STSPYL' ? STSPYS : na, '', #550000, 2)
plot(showAlgo=='STSPYS/STSPYL' ? STSPYL : na, '', #003060, 2)

plot(showAlgo=='STVIXS/STSPYS' ? STVIXS : na, '', #FF0000)
plot(showAlgo=='STVIXS/STSPYS' ? STSPYS : na, '', #550000, 2)
plot(showAlgo=='STVIXL/STSPYL' ? STVIXL : na, '', #0080FF)
plot(showAlgo=='STVIXL/STSPYL' ? STSPYL : na, '', #003060, 2)

plot( showAlgo=='VIXUP/VIXDN' ?    VIXUP : na, '', #FF8000)
plot( showAlgo=='VIXUP/VIXDN' ?    VIXDN : na, '', #550055, 2)
hline(showAlgo=='VIXUP/VIXDN' ? VIXUPMAX : na, '', #804000)
hline(showAlgo=='VIXUP/VIXDN' ?      -20 : na, '', #550055)

plot( showAlgo=='RC'  ?  RC : na, '', #FF40FF)
hline(showAlgo=='RC'  ? 0.8 : na)
plot( showAlgo=='VIX' ? VIX : na, '', #FFCC00, 2)
hline(showAlgo=='VIX' ?  15 : na)

BUY = VIXUP > VIXUPMAX    and STVIXL > STSPYL and
     STVIXS > STVIXS[1]   and STVIXS > STSPYS and
  bar_index > STBARSL + 3 and     RC > RC[1]  and RC > 0.8
SELL  = STVIXS < STVIXS[1] or STSPYS > STVIXS
COVER = STVIXS > STVIXS[1] and VIXUP > VIXUPMAX and RC > 0.8
SHORT = STSPYS > STSPYS[1]   and  VIXUP < VIXUPMAX and
     bar_index > STBARSS + 3 and STSPYS > STVIXS   and
   VIX > 15  and VIXDN < -20 and    VIX <= ta.lowest(VIX, 3)
if syminfo.ticker == 'SVXY'
    temp  = SHORT, SHORT :=  BUY, BUY  := temp
    temp := COVER, COVER := SELL, SELL := temp

strategyMode = switch directiv
    'Long/Short' => strategy.direction.all
    'Short Only' => strategy.direction.short
    =>              strategy.direction.long
strategy.risk.allow_entry_in(strategyMode)

withinStrategyObservationWindow = if startON
    time>=strtTime and (lapseON ? time<=endTime : true)
else
    lapseON ? time<=endTime : true

if withinStrategyObservationWindow and strategy.equity > 0.0
    if strategy.opentrades == 0
        if BUY or COVER
            strategy.entry('LONG\nENTRY', strategy.long)
        else if SHORT
            strategy.entry('SHORT\nENTRY', strategy.short)
    else
        if not (directiv == 'Long Only')
            if strategy.position_size > 0.0 and SHORT
                strategy.entry('SHORT', strategy.short)
            else if strategy.position_size < 0.0 and COVER
                strategy.entry('COVER', strategy.long)
        else if SELL
            strategy.close('ENTRY', comment='EXIT')
else if strategy.opentrades > 0
	strategy.close_all(comment='Strategy\nWindow\nElapsed')

string[] aLabels     = array.from( 'Ticker ID:', 'Bar Index:',
 '  High:', 'Close:',   'Open:',    'Low:', 'VIX:',   'VIXH:',
 'STVIXS:','STSPYS:', 'STVIXL:', 'STSPYL:',  'RC:', 'VIXUP%:',
           'VIXDN%:',    'BUY:',  'SELL:','SHORT:',  'COVER:')
tDT = table.new(tableRegion, 2, 19, #000000DD, #4499FF, 1)
if showTable and bar_index >= last_bar_index - 1
    string TICKER_ID = syminfo.prefix + ':' + syminfo.ticker
    color  odd       = #FFFFFF0b
    string[] aValues = array.from(TICKER_ID,
     str.tostring(bar_index),     str.tostring(high ),
     str.tostring(close),         str.tostring( open),
     str.tostring( low ),         str.tostring( VIX ),
     str.tostring( VIXH),         str.tostring(STVIXS, '.00'),
     str.tostring(STSPYS, '.00'), str.tostring(STVIXL, '.00'),
     str.tostring(STSPYL, '.00'), str.tostring(    RC, '.00'),
     str.tostring( VIXUP, '.00'), str.tostring( VIXDN, '.00'),
     str.tostring( BUY ),         str.tostring( SELL),
     str.tostring(SHORT),         str.tostring(COVER))
    for _i=0 to array.size(aLabels)-1
        table.cell( tDT, 0, _i, array.get( aLabels, _i), 0, 0,
         #4499FF, text.align_right, bgcolor=_i % 2 ? na : odd)
        table.cell( tDT, 1, _i, array.get( aValues, _i), 0, 0,
         #FFFFFF, text.align_center,bgcolor=_i % 2 ? na : odd)
````
