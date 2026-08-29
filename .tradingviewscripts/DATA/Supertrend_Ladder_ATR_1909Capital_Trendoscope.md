<!-- tradingview-pine-id: PUB;c61e4a062a284871841f3bde06c57b3e -->
<!-- tradingviewscripts-format: 1 -->
# Supertrend - Ladder ATR - 1909Capital [Trendoscope®]

Source: https://www.tradingview.com/script/8EZaD3CW-Supertrend-Ladder-ATR/

## Description

This is a supertrend with slight twisted concept which can be very benefecial in strong trending markets to reduce stop loss distance and exit slightly quicker.

⬜ Concept
▶ When the instrument is trending up, regular ATR shows high values if there are big green candles. This affect the stoploss distance in regular supertrend which leads to wide stops or delayed lagging. When you are in long trade, what matters for stoploss is how much a negative candle can move within bar. Hence, using ATR derived only based on red candles is more beneficial for trailing stops on long signals. Same applies to short trades where using ATR derived from only green candles is more efficient than overall ATR.
▶ ATR will be minimal when the volatility is less and ATR will increase with volatility. That means, once you are in trade, the trailing of stoploss also will vary based on ATR (or volatility). With regular ATR and supertrend, chances of stop loss distance widening is high with increased volatility even though stoploss levels will not move down. This again poses the risk of higher drawdown during trade closure and also keeps in the trade during ranging market. To avoid this, the second trick we are using here is only to reduce the atr stoploss difference when in trade. That is, when in long trade and negative candles ATR is increasing, we will not consider that. We will consider the new ATR only if it is lesser than previous bar ATR.

Effect of these changes on the trending market is quite visual. Lets take example of USDTRY

[https://www.tradingview.com/x/9wtbnKiR/](https://www.tradingview.com/x/9wtbnKiR/)

Settings are quite simple and does not vary much from regular supertrend settings.

[https://www.tradingview.com/x/w4WAnHN0/](https://www.tradingview.com/x/w4WAnHN0/)

---

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License (CC BY-NC-SA 4.0) https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Trendoscope Pty Ltd
//                                       ░▒             
//                                  ▒▒▒   ▒▒      
//                              ▒▒▒▒▒     ▒▒      
//                      ▒▒▒▒▒▒▒░     ▒     ▒▒          
//                  ▒▒▒▒▒▒           ▒     ▒▒          
//             ▓▒▒▒       ▒        ▒▒▒▒▒▒▒▒▒▒▒  
//   ▒▒▒▒▒▒▒▒▒▒▒ ▒        ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒         
//   ▒  ▒       ░▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░        
//   ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒░▒▒▒▒▒▒▒▒         
//   ▓▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ ▒▒                       
//    ▒▒▒▒▒         ▒▒▒▒▒▒▒                            
//                 ▒▒▒▒▒▒▒▒▒                           
//                ▒▒▒▒▒ ▒▒▒▒▒                          
//               ░▒▒▒▒   ▒▒▒▒▓      ████████╗██████╗ ███████╗███╗   ██╗██████╗  ██████╗ ███████╗ ██████╗ ██████╗ ██████╗ ███████╗
//              ▓▒▒▒▒     ▒▒▒▒      ╚══██╔══╝██╔══██╗██╔════╝████╗  ██║██╔══██╗██╔═══██╗██╔════╝██╔════╝██╔═══██╗██╔══██╗██╔════╝
//              ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒        ██║   ██████╔╝█████╗  ██╔██╗ ██║██║  ██║██║   ██║███████╗██║     ██║   ██║██████╔╝█████╗ 
//             ▒▒▒▒▒       ▒▒▒▒▒       ██║   ██╔══██╗██╔══╝  ██║╚██╗██║██║  ██║██║   ██║╚════██║██║     ██║   ██║██╔═══╝ ██╔══╝  
//            ▒▒▒▒▒         ▒▒▒▒▒      ██║   ██║  ██║███████╗██║ ╚████║██████╔╝╚██████╔╝███████║╚██████╗╚██████╔╝██║     ███████╗
//             ▒▒             ▒                        
//@version=6
indicator('Supertrend - Ladder ATR - 1909Capital [Trendoscope®]', "SLA [Trendoscope®]", overlay = true)
import HeWhoMustNotBeNamed/arrayutils/10 as pa

matype = input.string('hma', title = 'Moving Average  ', group = 'Supertrend', options = ['sma', 'ema', 'rma', 'wma', 'hma'], inline = 'ma')
malength = input.int(7, title = '', group = 'Supertrend', inline = 'ma')

multiplier = input.int(4, 'ATR Multiplier', step = 1, group = 'Supertrend')
waitForClose = input.bool(false, 'Wait For Close', group = 'Supertrend')
delayed = input.bool(false, 'Delayed/Sticky', group = 'Supertrend')

supertrend_atr(float positiveAtr, float negativeAtr, simple float multiplier, simple bool waitForClose = false, simple bool delayed = false) =>
    var dir = 1
    lowSource = low
    highSource = high
    source = close
    buyStopDiff = negativeAtr * multiplier
    sellStopDiff = positiveAtr * multiplier
    buyStopDiff := dir == 1 ? math.min(buyStopDiff, nz(buyStopDiff[1], buyStopDiff)) : buyStopDiff
    sellStopDiff := dir == -1 ? math.min(sellStopDiff, nz(sellStopDiff[1], sellStopDiff)) : sellStopDiff
    var buyStop = lowSource - buyStopDiff
    var sellStop = highSource + sellStopDiff

    buyStopCurrent = lowSource - buyStopDiff
    sellStopCurrent = highSource + sellStopDiff

    buyStopInverse = lowSource - buyStopDiff / 2
    sellStopInverse = highSource + sellStopDiff / 2

    highConfirmation = waitForClose ? source : highSource
    lowConfirmation = waitForClose ? source : lowSource
    dir := dir == 1 and lowConfirmation[1] < buyStop[1] ? -1 : dir == -1 and highConfirmation[1] > sellStop[1] ? 1 : dir
    targetReached = dir == 1 and nz(highConfirmation[1]) >= nz(sellStop[1]) or dir == -1 and nz(lowConfirmation[1]) <= nz(buyStop[1]) or not delayed
    buyStop := dir == 1 ? targetReached ? math.max(nz(buyStop, buyStopCurrent), buyStopCurrent) : buyStop : targetReached ? buyStopCurrent : math.max(nz(buyStop, buyStopInverse), buyStopInverse)
    sellStop := dir == -1 ? targetReached ? math.min(nz(sellStop, sellStopCurrent), sellStopCurrent) : sellStop : targetReached ? sellStopCurrent : math.min(nz(sellStop, sellStopInverse), sellStopInverse)
    [dir, dir > 0 ? buyStop : sellStop]

var positiveTrArray = array.new_float()
var negativeTrArray = array.new_float()

if open < close
    pa.push(positiveTrArray, ta.tr, malength)
else
    pa.push(negativeTrArray, ta.tr, malength)

positiveAtr = pa.ma(positiveTrArray, matype, malength)
negativeAtr = pa.ma(negativeTrArray, matype, malength)

[dir, supertrend] = supertrend_atr(positiveAtr, negativeAtr, multiplier, waitForClose, delayed)
alertcondition(ta.change(dir) > 0, 'Supertrend Bullish Alert')
alertcondition(ta.change(dir) < 0, 'Supertrend Bearish Alert')

directionChange = ta.change(dir)
alertMessage = directionChange > 0 ? 'Supertrend Bullish' : directionChange < 0 ? 'Supertrend Bearish' : 'na'
if directionChange != 0
    alert(alertMessage, alert.freq_once_per_bar_close)

plot(supertrend, color = dir > 0 ? color.rgb(83, 195, 189) : color.fuchsia, title = 'Supertrend Stop')
plot(dir, 'Direction', display=display.data_window)
````
