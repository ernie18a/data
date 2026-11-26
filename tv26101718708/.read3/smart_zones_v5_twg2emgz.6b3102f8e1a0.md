Calculation: RSI = RSI(RSI source, RSI lookback)
Calculation: ATR = ATR(ATR lookback)
Calculation: Ichimoku conversion line = (highest(high, shorter lookback) + lowest(low, shorter lookback)) / 2
Calculation: Ichimoku base line = (highest(high, middle lookback) + lowest(low, middle lookback)) / 2
Calculation: Ichimoku leading span A = (Ichimoku conversion line + Ichimoku base line) / 2
Calculation: Ichimoku leading span B = (highest(high, longest lookback) + lowest(low, longest lookback)) / 2
Long: RSI >= RSI bullish threshold
Short: RSI <= RSI bearish threshold
Long: Ichimoku cloud enabled AND Ichimoku leading span A[Kijun lookback] > Ichimoku leading span B[Kijun lookback]
Short: Ichimoku cloud enabled AND Ichimoku leading span A[Kijun lookback] <= Ichimoku leading span B[Kijun lookback]
Long: at least two of close > max(Ichimoku leading span A[Kijun lookback], Ichimoku leading span B[Kijun lookback]), Ichimoku conversion line > Ichimoku base line AND Ichimoku conversion line[1] <= Ichimoku base line[1], close > high[Kijun lookback]
Short: at least two of close < min(Ichimoku leading span A[Kijun lookback], Ichimoku leading span B[Kijun lookback]), Ichimoku conversion line < Ichimoku base line AND Ichimoku conversion line[1] >= Ichimoku base line[1], close < low[Kijun lookback]
Long: bullish FVG display enabled AND low - high[2] > FVG minimum size in ATR units × ATR
Short: bearish FVG display enabled AND low[2] - high > FVG minimum size in ATR units × ATR
Long: bullish order blocks enabled AND prior bullish order-block count < OB maximum AND close > close[1] AND (close - close[1]) / ATR >= minimum OB impulse in ATR units AND open[1] != close[1]
Short: bearish order blocks enabled AND prior bearish order-block count < OB maximum AND close < close[1] AND (close[1] - close) / ATR >= minimum OB impulse in ATR units AND open[1] != close[1]