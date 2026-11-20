Calculation: Trend line = the selected SMA, EMA, DEMA, TEMA, WMA, HMA, LSMA, TMA, or Kijun midpoint of highest high and lowest low, using the selected source and trend lookback.
Calculation: Bull condition = close > trend line + EMA(TrueRange, trend lookback) * channel multiplier + ATR(ATR lookback) * buffer multiplier.
Calculation: Bear condition = close < trend line - EMA(TrueRange, trend lookback) * channel multiplier - ATR(ATR lookback) * buffer multiplier.
Calculation: Bull confirmation = bull condition holds for the confirmation lookback consecutive chart bars.
Calculation: Bear confirmation = bear condition holds for the confirmation lookback consecutive chart bars.
Calculation: Locked trend state = initially neutral; switches to bullish on bull confirmation and to bearish on bear confirmation, if momentum support is disabled or (for bullish) RSI(close, RSI lookback) > 50 OR MACD(close, fast lookback, slow lookback, signal lookback) line > signal line OR (volume > SMA(volume, volume lookback) * volume multiplier AND close > open), or (for bearish) RSI(close, RSI lookback) < 50 OR MACD line < signal line OR (volume > SMA(volume, volume lookback) * volume multiplier AND close < open); otherwise retains its prior state.
Calculation: Buy warning = (volume > SMA(volume, volume lookback) * volume multiplier AND close > open) OR MACD line crosses above signal line OR (RSI(close, RSI lookback) > buy strength level AND RSI(close, RSI lookback) > RSI(close, RSI lookback)[1]).
Calculation: Sell warning = (volume > SMA(volume, volume lookback) * volume multiplier AND close < open) OR MACD line crosses below signal line OR (RSI(close, RSI lookback) < sell weakness level AND RSI(close, RSI lookback) < RSI(close, RSI lookback)[1]).
Calculation: ATR distance from trend = ATR(ATR lookback) > 0 ? abs(close - trend line) / ATR(ATR lookback) : 0.
Long: bull condition.
Short: bear condition.
Long: locked trend state is bullish.
Short: locked trend state is bearish.
Long: MACD(close, fast lookback, slow lookback, signal lookback) line > signal line.
Short: MACD(close, fast lookback, slow lookback, signal lookback) line < signal line.
Long: RSI(close, RSI lookback) >= bullish RSI level.
Short: RSI(close, RSI lookback) <= bearish RSI level.
Long: Buy warning.
Short: Sell warning.
Long: locked trend state is bullish AND close > trend line AND (far-entry filter is disabled OR ATR distance from trend <= maximum distance) AND (candle-close confirmation is disabled OR the chart bar is confirmed) AND (warning filter is disabled OR Buy warning) AND the most recent confirmed BUY/SELL signal was not BUY.
Short: locked trend state is bearish AND close < trend line AND (far-entry filter is disabled OR ATR distance from trend <= maximum distance) AND (candle-close confirmation is disabled OR the chart bar is confirmed) AND (warning filter is disabled OR Sell warning) AND the most recent confirmed BUY/SELL signal was not SELL.
Exit: long, close < trend line OR Sell warning.
Exit: short, close > trend line OR Buy warning.
Exit: long, ATR(ATR lookback) > 0 AND (close - entry price) / ATR(ATR lookback) >= take-profit ATR distance.
Exit: short, ATR(ATR lookback) > 0 AND (entry price - close) / ATR(ATR lookback) >= take-profit ATR distance.
Calculation: SSL direction = initially neutral; becomes bullish when close > selected SSL MA(high, SSL lookback), bearish when close < selected SSL MA(low, SSL lookback), and otherwise retains its prior value.
Calculation: SSL line = selected SSL MA(high, SSL lookback) when SSL direction is bearish, otherwise selected SSL MA(low, SSL lookback).
Long: close > SSL line.
Short: close < SSL line.
Calculation: SSL2 direction = initially neutral; becomes bullish when close > selected SSL2 MA(high, SSL2 lookback), bearish when close < selected SSL2 MA(low, SSL2 lookback), and otherwise retains its prior value.
Calculation: SSL2 line = selected SSL2 MA(high, SSL2 lookback) when SSL2 direction is bearish, otherwise selected SSL2 MA(low, SSL2 lookback).
Long: close > SSL2 line.
Short: close < SSL2 line.