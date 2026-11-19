Calculation: volume confirmation = volume >= volume[1] * volume multiplier
Calculation: risk distance = ATR(ATR lookback) on the entry bar * stop-distance multiplier
Calculation: bullish confluence score = (close > VWAP(hlc3) ? 1 : 0) + (RSI(close, RSI lookback) > RSI midpoint ? 1 : 0) + (MACD line(close, fast lookback, slow lookback, signal lookback) > MACD signal(close, fast lookback, slow lookback, signal lookback) ? 1 : 0) + (EMA(close, shorter lookback) > EMA(close, longer lookback) ? 1 : 0) + (ADX(DI lookback, ADX smoothing lookback) > ADX threshold AND close > EMA(close, shorter lookback) ? 1 : 0) + (volume > SMA(volume, volume-average lookback) AND close > open ? 1 : 0) + (RSI(close, RSI lookback, T1, computed on T1 bars using the bar still forming and sampled on chart bars) > RSI midpoint ? 1 : 0)
Calculation: bearish confluence score = (close < VWAP(hlc3) ? 1 : 0) + (RSI(close, RSI lookback) < RSI midpoint ? 1 : 0) + (MACD line(close, fast lookback, slow lookback, signal lookback) < MACD signal(close, fast lookback, slow lookback, signal lookback) ? 1 : 0) + (EMA(close, shorter lookback) < EMA(close, longer lookback) ? 1 : 0) + (ADX(DI lookback, ADX smoothing lookback) > ADX threshold AND close < EMA(close, shorter lookback) ? 1 : 0) + (volume > SMA(volume, volume-average lookback) AND close < open ? 1 : 0) + (RSI(close, RSI lookback, T1, computed on T1 bars using the bar still forming and sampled on chart bars) < RSI midpoint ? 1 : 0)
Long: position side is not long AND EMA(close, shorter lookback) crosses above EMA(close, longer lookback) AND (volume filter is disabled OR volume confirmation)
Short: position side is not short AND EMA(close, shorter lookback) crosses below EMA(close, longer lookback) AND (volume filter is disabled OR volume confirmation)
Long: bullish confluence score > bearish confluence score
Short: bearish confluence score >= bullish confluence score
Long: EMA(close, shorter lookback) > EMA(close, longer lookback) AND close > VWAP(hlc3)
Short: EMA(close, shorter lookback) < EMA(close, longer lookback) AND close < VWAP(hlc3)
Long: RSI(close, RSI lookback) > RSI midpoint AND RSI(close, RSI lookback) <= RSI overbought threshold
Short: RSI(close, RSI lookback) >= RSI oversold threshold AND RSI(close, RSI lookback) <= RSI midpoint
Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) <= EMA(close, longer lookback)
Long: close > VWAP(hlc3)
Short: close <= VWAP(hlc3)
Long: position side is long AND low <= EMA(close, shorter lookback) AND low > EMA(close, longer lookback)
Short: position side is short AND high >= EMA(close, shorter lookback) AND high < EMA(close, longer lookback)
Exit: long, high >= entry price + risk distance * first target multiple
Exit: long, high >= entry price + risk distance * second target multiple
Exit: long, high >= entry price + risk distance * third target multiple
Exit: long, high >= entry price + risk distance * fourth target multiple
Exit: long, high >= entry price + risk distance * fifth target multiple
Exit: short, low <= entry price - risk distance * first target multiple
Exit: short, low <= entry price - risk distance * second target multiple
Exit: short, low <= entry price - risk distance * third target multiple
Exit: short, low <= entry price - risk distance * fourth target multiple
Exit: short, low <= entry price - risk distance * fifth target multiple