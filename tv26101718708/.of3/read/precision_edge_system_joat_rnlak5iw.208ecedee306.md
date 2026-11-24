Calculation: opening range high = max of high over bars inside the latest opening range window
Calculation: opening range low = min of low over bars inside the latest opening range window
Calculation: opening range established = an opening range window has ended and no later window has started
Calculation: opening range breakout up = opening range established AND close crosses above opening range high
Calculation: opening range breakout down = opening range established AND close crosses below opening range low
Calculation: structure bullish = true initially; set true when pivot high(high, structure fractal period, structure fractal period) is above the previous pivot high; set false when pivot low(low, structure fractal period, structure fractal period) is below the previous pivot low, applied after the true setting on the same bar
Calculation: structure break occurred = a pivot high above the previous pivot high or a pivot low below the previous pivot low has been confirmed on this bar or an earlier bar
Calculation: bullish FVG retest = low <= upper AND close >= lower, where upper = low and lower = high[2] on the most recent bar with low > high[2] AND (low - high[2]) / high[2] * 100 >= min gap percent; false if no such bar
Calculation: bearish FVG retest = high >= lower AND close <= upper, where upper = low[2] and lower = high on the most recent bar with high < low[2] AND (low[2] - high) / low[2] * 100 >= min gap percent; false if no such bar
Calculation: bullish block = close[1] < open[1] AND close > open AND high - low > ATR(high, low, close, ATR lookback) * block range multiple AND volume > SMA(volume, volume average lookback) * block volume multiple
Calculation: bearish block = close[1] > open[1] AND close < open AND high - low > ATR(high, low, close, ATR lookback) * block range multiple AND volume > SMA(volume, volume average lookback) * block volume multiple
Calculation: block strong = (volume > SMA(volume, volume average lookback) * strong block volume multiple) OR (volume > SMA(volume, volume average lookback) * medium block volume multiple AND high - low > ATR(high, low, close, ATR lookback) * medium block range multiple) OR (high - low > ATR(high, low, close, ATR lookback) * strong block range multiple)
Calculation: last bullish block strong = block strong on the most recent bar where bullish block is true; false if none
Calculation: last bearish block strong = block strong on the most recent bar where bearish block is true; false if none
Calculation: premium zone = close > (Donchian midline(high, low, range lookback) + highest(high, range lookback)) / 2
Calculation: discount zone = close < (Donchian midline(high, low, range lookback) + lowest(low, range lookback)) / 2
Calculation: golden zone = close >= F AND close <= F * golden zone factor, where F = A + fib ratio * (B - A), A = whichever of highest(high, primary wave lookback) and lowest(low, primary wave lookback) occurred earlier in that window, B = the other one
Calculation: equal highs = high = high[1] AND high = high[2]
Calculation: equal lows = low = low[1] AND low = low[2]
Calculation: liquidity sweep up = liquidity switch on AND pivot high(high, liquidity swing length, liquidity swing length) is confirmed on this bar AND abs(that pivot - previous confirmed pivot high) / previous confirmed pivot high * 100 <= liquidity tolerance percent
Calculation: liquidity sweep down = liquidity switch on AND pivot low(low, liquidity swing length, liquidity swing length) is confirmed on this bar AND abs(that pivot - previous confirmed pivot low) / previous confirmed pivot low * 100 <= liquidity tolerance percent
Calculation: liquidity above = equal highs OR liquidity sweep up
Calculation: liquidity below = equal lows OR liquidity sweep down
Calculation: hammer strength = close > open AND open - low > wick multiple * (close - open) AND high - close < opposite wick fraction * (close - open) AND close - open < body fraction * (high - low) AND volume > SMA(volume, volume average lookback) * pattern volume multiple
Calculation: shooting star strength = close < open AND high - open > wick multiple * (open - close) AND close - low < opposite wick fraction * (open - close) AND open - close < body fraction * (high - low) AND volume > SMA(volume, volume average lookback) * pattern volume multiple
Calculation: bullish engulfing strength = close > open AND close[1] < open[1] AND open < close[1] AND close > open[1] AND volume > volume[1] * engulfing volume multiple
Calculation: bearish engulfing strength = close < open AND close[1] > open[1] AND open > close[1] AND close < open[1] AND volume > volume[1] * engulfing volume multiple
Calculation: morning star = close[2] < open[2] AND abs(close[1] - open[1]) < star body fraction * (high[1] - low[1]) AND close > open AND close > (high[2] + low[2]) / 2
Calculation: evening star = close[2] > open[2] AND abs(close[1] - open[1]) < star body fraction * (high[1] - low[1]) AND close < open AND close < (high[2] + low[2]) / 2
Calculation: bullish momentum = RSI(close, RSI lookback) > RSI(close, RSI lookback)[momentum lookback] AND MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) > 0
Calculation: bearish momentum = RSI(close, RSI lookback) < RSI(close, RSI lookback)[momentum lookback] AND MACD histogram(close, MACD fast lookback, MACD slow lookback, MACD signal lookback) < 0
Calculation: volume spike = volume > SMA(volume, volume average lookback) * volume spike multiple
Calculation: RSI-2 oversold = RSI(close, short RSI lookback) < RSI-2 oversold level AND close > EMA(close, longest EMA lookback)
Calculation: RSI-2 overbought = RSI(close, short RSI lookback) > RSI-2 overbought level AND close < EMA(close, longest EMA lookback)
Calculation: bullish divergence = pivot low(low, divergence pivot length, divergence pivot length) and pivot low(RSI(close, RSI lookback), divergence pivot length, divergence pivot length) are both confirmed on this bar, the price pivot low is below the previous price pivot low, and the RSI pivot low is above the previous RSI pivot low
Calculation: bearish divergence = pivot high(high, divergence pivot length, divergence pivot length) and pivot high(RSI(close, RSI lookback), divergence pivot length, divergence pivot length) are both confirmed on this bar, the price pivot high is above the previous price pivot high, and the RSI pivot high is below the previous RSI pivot high
Calculation: uptrend = EMA(close, shorter EMA lookback) > EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) > EMA(close, longer EMA lookback)
Calculation: downtrend = EMA(close, shorter EMA lookback) < EMA(close, middle EMA lookback) AND EMA(close, middle EMA lookback) < EMA(close, longer EMA lookback)
Calculation: high volatility = ATR(high, low, close, ATR lookback) / SMA(ATR(high, low, close, ATR lookback), longer ATR-average lookback) > high-volatility ratio
Calculation: long stop (evaluated on the entry bar) = opening range low if (opening range switch on AND opening range established), else low - stop ATR multiple * ATR(high, low, close, ATR lookback)
Calculation: short stop (evaluated on the entry bar) = opening range high if (opening range switch on AND opening range established), else high + stop ATR multiple * ATR(high, low, close, ATR lookback)
Calculation: long target (evaluated on the entry bar) = entry price + (entry price - long stop) * reward multiple * (high-volatility target factor if (adaptive target switch on AND high volatility), else 1)
Calculation: short target (evaluated on the entry bar) = entry price - (short stop - entry price) * reward multiple * (high-volatility target factor if (adaptive target switch on AND high volatility), else 1)
Calculation: long score = opening range weight if (opening range switch on AND opening range breakout up) + structure weight if (require structure switch on AND structure break occurred AND structure bullish) + FVG weight if (FVG switch on AND bullish FVG retest) + order block weight if (order block switch on AND a bullish block has occurred) + strong block weight if (order block switch on AND last bullish block strong) + value-zone weight if (value-zone switch on AND discount zone) + golden zone weight if (fib switch on AND golden zone switch on AND golden zone) + RSI-2 weight if (RSI-2 switch on AND RSI-2 oversold) + divergence weight if (divergence switch on AND bullish divergence) + liquidity weight if (liquidity switch on AND liquidity below) + volume weight if volume spike + momentum weight if bullish momentum + pattern weight if (hammer strength OR bullish engulfing strength OR morning star)
Calculation: short score = opening range weight if (opening range switch on AND opening range breakout down) + structure weight if (require structure switch on AND structure break occurred AND NOT structure bullish) + FVG weight if (FVG switch on AND bearish FVG retest) + order block weight if (order block switch on AND a bearish block has occurred) + strong block weight if (order block switch on AND last bearish block strong) + value-zone weight if (value-zone switch on AND premium zone) + golden zone weight if (fib switch on AND golden zone switch on AND golden zone) + RSI-2 weight if (RSI-2 switch on AND RSI-2 overbought) + divergence weight if (divergence switch on AND bearish divergence) + liquidity weight if (liquidity switch on AND liquidity above) + volume weight if volume spike + momentum weight if bearish momentum + pattern weight if (shooting star strength OR bearish engulfing strength OR evening star)
Long: long score >= entry-mode minimum score AND NOT (regime switch on AND avoid choppy switch on AND high volatility) AND (session switch off OR bar time in London window OR bar time in New York window OR bar time in silver-bullet window) AND entries taken today < max daily entries AND position is flat AND volume > SMA(volume, volume average lookback) * volume confirm multiple AND (allow partial setups switch on OR uptrend OR (close > EMA(close, longest EMA lookback) AND EMA(close, shorter EMA lookback) > EMA(close, middle EMA lookback))) AND close > long stop
Short: short score >= entry-mode minimum score AND NOT (regime switch on AND avoid choppy switch on AND high volatility) AND (session switch off OR bar time in London window OR bar time in New York window OR bar time in silver-bullet window) AND entries taken today < max daily entries AND position is flat AND volume > SMA(volume, volume average lookback) * volume confirm multiple AND (allow partial setups switch on OR downtrend OR (close < EMA(close, longest EMA lookback) AND EMA(close, shorter EMA lookback) < EMA(close, middle EMA lookback))) AND close < short stop
Long: opening range breakout up
Long: bullish FVG retest
Long: structure break occurred AND structure bullish
Long: bullish divergence
Long: hammer strength
Long: bullish engulfing strength
Long: morning star
Long: liquidity below
Long: RSI(close, RSI lookback) < RSI low marking level
Short: opening range breakout down
Short: bearish FVG retest
Short: structure break occurred AND NOT structure bullish
Short: bearish divergence
Short: shooting star strength
Short: bearish engulfing strength
Short: evening star
Short: liquidity above
Short: RSI(close, RSI lookback) > RSI high marking level
Exit: long, low <= long stop OR high >= long target OR (EOD switch on AND bar time in EOD window)
Exit: short, high >= short stop OR low <= short target OR (EOD switch on AND bar time in EOD window)