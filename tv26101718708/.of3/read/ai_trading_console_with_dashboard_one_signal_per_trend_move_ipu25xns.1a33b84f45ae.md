Calculation: Opening-range high = maximum high during the session’s opening-range interval
Calculation: Opening-range low = minimum low during the session’s opening-range interval
Calculation: EMA bullish = EMA(close, shorter lookback) > EMA(close, longer lookback)
Calculation: HTF bullish = close of the still-forming T1 bar, sampled on chart bars, > EMA(close, HTF EMA lookback) calculated on T1 bars and sampled on chart bars
Calculation: Stop = for a long, entry price − ATR(high, low, close, ATR lookback) at entry × initial-stop multiplier, raised to the highest close − ATR(high, low, close, ATR lookback) × trailing-stop multiplier since entry when trailing is enabled; for a short, entry price + ATR(high, low, close, ATR lookback) at entry × initial-stop multiplier, lowered to the lowest close + ATR(high, low, close, ATR lookback) × trailing-stop multiplier since entry when trailing is enabled
Long: buy enabled AND no open position AND last entry direction is not long AND (ORB disabled OR close crosses above opening-range high) AND (EMA filter disabled OR EMA bullish) AND (RSI filter disabled OR RSI(close, lookback) > long RSI threshold) AND (ADX filter disabled OR ADX(high, low, close, lookback, smoothing) > ADX threshold) AND (VIX filter disabled OR VIX close < VIX threshold) AND (HTF filter disabled OR HTF bullish)
Short: sell enabled AND no open position AND last entry direction is not short AND (ORB disabled OR close crosses below opening-range low) AND (EMA filter disabled OR EMA(close, shorter lookback) < EMA(close, longer lookback)) AND (RSI filter disabled OR RSI(close, lookback) < short RSI threshold) AND (ADX filter disabled OR ADX(high, low, close, lookback, smoothing) > ADX threshold) AND (VIX filter disabled OR VIX close < VIX threshold) AND (HTF filter disabled OR close of the still-forming T1 bar, sampled on chart bars, < EMA(close, HTF EMA lookback) calculated on T1 bars and sampled on chart bars)
Long: EMA filter disabled OR EMA bullish
Short: EMA filter enabled AND NOT EMA bullish
Long: HTF bullish
Short: NOT HTF bullish
Exit: long, close < Stop
Exit: short, close > Stop