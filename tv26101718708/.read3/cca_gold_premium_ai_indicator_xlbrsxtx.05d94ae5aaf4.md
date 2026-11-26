Calculation: confluence score = count of close > open, EMA(close, shorter lookback) > EMA(close, medium lookback), close > VWAP, and close > EMA(close, longer lookback), with shorter lookback < medium lookback < longer lookback
Calculation: active order-block zones = When OB detection is enabled, a close crossover above the latest confirmed pivot high creates a bullish zone anchored at the latest confirmed pivot-low bar if that anchor exists and its age is below the maximum anchor age; initialize its bounds from that candle's low and high, then scan offsets equal to the anchor's absolute chart index minus i for i from zero through the OB scan reach, replacing the bounds with the first bearish candle's low and high when its low is below the current bottom times (1 + OB tolerance). A close crossunder below the latest confirmed pivot low creates a bearish zone anchored at the latest confirmed pivot-high bar under the same age condition; initialize its bounds from that candle's low and high, then scan the same offsets, replacing the bounds with the first bullish candle's low and high when its high is above the current top times (1 - OB tolerance). Remove bullish zones when close < bottom and bearish zones when close > top; retain only the newest maximum-zone-count zones across both directions.
Calculation: bullish OB rejection = any active bullish order-block zone where low <= top AND close >= bottom AND close > open
Calculation: bearish OB rejection = any active bearish order-block zone where high >= bottom AND close <= top AND close < open
Long: custom candles are enabled AND close >= open
Short: custom candles are enabled AND close < open
Long: RSI(close, RSI lookback) <= oversold level
Short: RSI(close, RSI lookback) >= overbought level
Long: EMA(close, shorter lookback) >= EMA(close, medium lookback)
Short: EMA(close, shorter lookback) < EMA(close, medium lookback)
Long: close > VWAP
Short: close <= VWAP
Long: confluence score >= bullish bias threshold
Short: confluence score <= bearish bias threshold
Long: low > high[FVG separation lookback]
Short: high < low[FVG separation lookback]
Long: OB detection is enabled AND close crosses above the latest confirmed pivot high AND a confirmed pivot-low anchor exists and is younger than the maximum anchor age
Short: OB detection is enabled AND close crosses below the latest confirmed pivot low AND a confirmed pivot-high anchor exists and is younger than the maximum anchor age
Long: close crosses above the latest confirmed pivot high AND the preceding market trend is not bullish
Short: close crosses below the latest confirmed pivot low AND the preceding market trend is not bearish
Long: (RSI(close, RSI lookback) crosses above the oversold level AND (EMA(close, shorter lookback) > EMA(close, medium lookback) OR confluence score >= entry bias threshold) OR bullish OB rejection AND EMA(close, shorter lookback) > EMA(close, medium lookback)) AND current bar index minus the shared last buy-or-sell signal bar > signal cooldown
Short: (RSI(close, RSI lookback) crosses below the overbought level AND (EMA(close, shorter lookback) <= EMA(close, medium lookback) OR confluence score <= entry bias threshold) OR bearish OB rejection AND EMA(close, shorter lookback) <= EMA(close, medium lookback)) AND current bar index minus the shared last buy-or-sell signal bar > signal cooldown