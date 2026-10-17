# 3 Line Strike [TTF] mit EMA 50

- url: https://www.tradingview.com/script/fxVaaUS8/
- type: indicator
- pine_id: PUB;e61261c7f9ad490aab5d80ace3505eba
- version: 1.0

## Description

This script is an updated, highly optimized Pine Script v6 version of the classic 3-Line Strike overlay, specifically tailored for trend continuation strategies. It filters out low-probability counter-trend setups by introducing a strict 50 Exponential Moving Average (EMA) body filter.

Key Features:

3-Line Strike Identification: Automatically spots the 4-candle continuation pattern (3 consecutive bearish/bullish candles followed by a powerful opposite-colored engulfing candle).

Strict 50 EMA Body Filter: To ensure you only trade in the direction of the macro trend, Bullish signals will only trigger if the entire candle body (both Open and Close) is completely above the 50 EMA. Conversely, Bearish signals will only trigger if the entire candle body is completely below the 50 EMA.

Standalone Engulfing Signals: Includes an optional toggle to track "Big A$$" Engulfing candles independently, which are also bound to the 50 EMA filter rules.

Fully Customizable Visuals: Switch between standard professional chart shapes or toggle Arty’s classic custom meme icons (🍆/🍑) for a more casual charting experience.

Pine Script v6 Native Alerts: Fully optimized for TradingView's modern dynamic alert engine (alert()), configured to trigger reliably on bar close to avoid repainting issues.

How to Trade It:
This indicator is best utilized as a trend-continuation signal at the end of a brief retracement period. When the market is in a healthy trend (above or below the 50 EMA) and a 3-Line Strike forms, it often signals that the temporary pullback has exhausted itself and the primary trend is ready to resume.

## Source Code

````pine
//@version=6
indicator(title='3 Line Strike [TTF] mit EMA 50', shorttitle='3LS+EMA', overlay=true)

// --- Inputs ---
// ### 3 Line Strike
showBear3LS = input.bool(title='Show Bearish 3 Line Strike', defval=true, group='3 Line Strike', tooltip="The Bearish 3 Line Strike (3LS-Bear) is a candlestick pattern comprised of 3 bullish (green) candles, followed by a bearish engulfing candle.\n\nDefault: Checked")
showBull3LS = input.bool(title='Show Bullish 3 Line Strike', defval=true, group='3 Line Strike', tooltip="The Bullish 3 Line Strike (3LS-Bull) is a candlestick pattern comprised of 3 bearish (red) candles, followed by a bullish engulfing candle.\n\nDefault: Checked")
showMemeChars = input.bool(title="Plot 3 Line Strike meme symbols", defval=false, group="3 Line Strike", tooltip="If disabled (default), standard shapes will be plotted instead.\n\nDefault: Unchecked")

// ### Engulfing Candles
showBearEngulfing = input.bool(title='Show Bearish Big A$$ Candles', defval=false, group='Big A$$ Candles', tooltip="Bearish 'Big A$$ Candles' are the same as Bearish Engulfing candles.")
showBullEngulfing = input.bool(title='Show Bullish Big A$$ Candles', defval=false, group='Big A$$ Candles', tooltip="Bullish 'Big A$$ Candles' are the same as Bullish Engulfing candles.")

// ### EMA Filter Settings
showEMA = input.bool(title='Show EMA 50', defval=true, group='EMA Filter')
emaLength = input.int(title='EMA Length', defval=50, minval=1, group='EMA Filter')

// --- EMA Berechnung & Plot ---
ema50 = ta.ema(close, emaLength)
plot(showEMA ? ema50 : na, title='EMA 50', color=color.blue, linewidth=2)

// --- Funktionen ---
getCandleColorIndex(barIndex) =>
    int ret = na
    if (close[barIndex] > open[barIndex])
        ret := 1
    else if (close[barIndex] < open[barIndex])
        ret := -1
    else
        ret := 0
    ret

isEngulfing(checkBearish) =>
    ret = false
    sizePrevCandle = close[1] - open[1]
    sizeCurrentCandle = close - open
    isCurrentLagerThanPrevious = (math.abs(sizeCurrentCandle) > math.abs(sizePrevCandle))
    
    switch checkBearish
        true => 
            isGreenToRed = ((getCandleColorIndex(0) < 0) and (getCandleColorIndex(1) > 0))
            ret := (isCurrentLagerThanPrevious and isGreenToRed)
        false => 
            isRedToGreen = ((getCandleColorIndex(0) > 0) and (getCandleColorIndex(1) < 0))
            ret := (isCurrentLagerThanPrevious and isRedToGreen)
        => ret := false
    ret

isBearishEngulfing() =>
    isEngulfing(true)

isBullishEngulfing() =>
    isEngulfing(false)

is3LSBear() =>
    is3LineSetup = ((getCandleColorIndex(1) > 0) and (getCandleColorIndex(2) > 0) and (getCandleColorIndex(3) > 0))
    is3LineSetup and isBearishEngulfing()

is3LSBull() =>
    is3LineSetup = ((getCandleColorIndex(1) < 0) and (getCandleColorIndex(2) < 0) and (getCandleColorIndex(3) < 0))
    is3LineSetup and isBullishEngulfing()

// --- EMA Filter Bedingungen (Gesamter Kerzenkörper) ---
bodyAboveEMA = (open > ema50) and (close > ema50)
bodyBelowEMA = (open < ema50) and (close < ema50)

// --- Signal-Logik mit Filter-Verknüpfung ---
is3LSBullSig = is3LSBull() and bodyAboveEMA
is3LSBearSig = is3LSBear() and bodyBelowEMA

isBullEngulfingSig = isBullishEngulfing() and bodyAboveEMA
isBearEngulfingSig = isBearishEngulfing() and bodyBelowEMA

// --- Plots & Visualisierung ---
// Meme Plots (3LS)
plotchar(showBull3LS and showMemeChars and is3LSBullSig, char="🍆", color=color.rgb(0, 255, 0, 0), location=location.belowbar, size=size.tiny, text='3LS-Bull', title='3 Line Strike Up (Meme Icon)')
plotchar(showBear3LS and showMemeChars and is3LSBearSig, char="🍑", color=color.rgb(255, 0, 0, 0), location=location.abovebar, size=size.tiny, text='3LS-Bear', title='3 Line Strike Down (Meme Icon)')

// Standard Plots (3LS)
plotshape(showBull3LS and not showMemeChars and is3LSBullSig, style=shape.triangleup, color=color.rgb(0, 255, 0, 0), location=location.belowbar, size=size.small, text='3LS-Bull', title='3 Line Strike Up')
plotshape(showBear3LS and not showMemeChars and is3LSBearSig, style=shape.triangledown, color=color.rgb(255, 0, 0, 0), location=location.abovebar, size=size.small, text='3LS-Bear', title='3 Line Strike Down')

// Engulfing Plots
plotshape(showBullEngulfing and isBullEngulfingSig, style=shape.triangleup, location=location.belowbar, color=color.rgb(0, 255, 0, 0), size=size.tiny, title='Big A$$ Candle Up')
plotshape(showBearEngulfing and isBearEngulfingSig, style=shape.triangledown, location=location.abovebar, color=color.rgb(255, 0, 0, 0), size=size.tiny, title='Big A$$ Candle Down')

// --- Alerts ---
if (showBull3LS and is3LSBullSig)
    alert(syminfo.tickerid + ' ' + timeframe.period + ' - Bullish 3 Line Strike', alert.freq_once_per_bar_close)
if (showBear3LS and is3LSBearSig)
    alert(syminfo.tickerid + ' ' + timeframe.period + ' - Bearish 3 Line Strike', alert.freq_once_per_bar_close)   

if (showBullEngulfing and isBullEngulfingSig)
    alert(syminfo.tickerid + ' ' + timeframe.period + ' - Bullish Engulfing', alert.freq_once_per_bar_close)
if (showBearEngulfing and isBearEngulfingSig)
    alert(syminfo.tickerid + ' ' + timeframe.period + ' - Bearish Engulfing', alert.freq_once_per_bar_close)
````
