Calculation: Typical Price = (high + low + close) / 3
Calculation: Directional Ratio = EMA(Typical Price - Typical Price[1], directional lookback) / EMA(abs(Typical Price - Typical Price[1]), directional lookback), or 0 if the denominator is not positive
Calculation: Trend Center = EMA(Typical Price, main lookback) + (EMA(Typical Price, fast lookback) - EMA(Typical Price, main lookback)) * clamp(efficiency weight * Kaufman Efficiency Ratio(Typical Price, main lookback) + directional weight * abs(Directional Ratio), 0, 1), with fast lookback shorter than main lookback
Calculation: Break Threshold = (range weight * RMA(True Range, range lookback) + deviation weight * EMA(abs(Typical Price - Trend Center), range lookback)) * band multiplier * reversal buffer * (clamp(EMA(True Range, noise lookback) / EMA(True Range, main lookback), regime lower bound, regime upper bound) if EMA(True Range, main lookback) > 0, else 1), with range lookback shorter than main lookback and noise lookback shorter than range lookback
Calculation: Upside Held = the condition (Close > Trend Center + Break Threshold AND Directional Ratio > directional threshold AND Trend Center > Trend Center[slope lookback]) is true on each of the last confirmation bars, including the current bar
Calculation: Downside Held = the condition (Close < Trend Center - Break Threshold AND Directional Ratio < -directional threshold AND Trend Center < Trend Center[slope lookback]) is true on each of the last confirmation bars, including the current bar
Calculation: Trend Direction = 1 if the most recent bar where Upside Held AND NOT Upside Held[1] is true is more recent than the most recent bar where Downside Held AND NOT Downside Held[1] is true; -1 if the most recent such Downside bar is more recent; 0 if neither has occurred
Calculation: Chart Direction = Trend Direction if the current bar is closed, else Trend Direction[1]
Calculation: Timeframe Direction(T) = Chart Direction if T equals the chart timeframe; Trend Direction on T bars at the last completed T bar if T is longer than the chart timeframe; Trend Direction on T bars at the bar before the last completed T bar if T is shorter than the chart timeframe
Calculation: Duration Weight(T) = ln(1 + seconds(T) / min(seconds(T1), seconds(T2), seconds(T3), seconds(T4)))
Calculation: Agreement Score = (Timeframe Direction(T1) * Duration Weight(T1) + Timeframe Direction(T2) * Duration Weight(T2) + Timeframe Direction(T3) * Duration Weight(T3) + Timeframe Direction(T4) * Duration Weight(T4)) / (Duration Weight(T1) + Duration Weight(T2) + Duration Weight(T3) + Duration Weight(T4)), with a missing Timeframe Direction counted as 0
Calculation: Consensus Direction = Bullish if Agreement Score >= overall threshold; Bearish if Agreement Score <= -overall threshold
Long: Chart Direction = 1
Long: the current bar is closed AND Chart Direction = 1 AND Chart Direction[1] != 1
Short: Chart Direction = -1
Short: the current bar is closed AND Chart Direction = -1 AND Chart Direction[1] != -1
Long: Timeframe Direction(T1) = 1
Long: Timeframe Direction(T2) = 1
Long: Timeframe Direction(T3) = 1
Long: Timeframe Direction(T4) = 1
Short: Timeframe Direction(T1) = -1
Short: Timeframe Direction(T2) = -1
Short: Timeframe Direction(T3) = -1
Short: Timeframe Direction(T4) = -1
Long: Timeframe Direction(T1) = 1 AND Timeframe Direction(T1)[1] != 1
Long: Timeframe Direction(T2) = 1 AND Timeframe Direction(T2)[1] != 1
Long: Timeframe Direction(T3) = 1 AND Timeframe Direction(T3)[1] != 1
Long: Timeframe Direction(T4) = 1 AND Timeframe Direction(T4)[1] != 1
Short: Timeframe Direction(T1) = -1 AND Timeframe Direction(T1)[1] != -1
Short: Timeframe Direction(T2) = -1 AND Timeframe Direction(T2)[1] != -1
Short: Timeframe Direction(T3) = -1 AND Timeframe Direction(T3)[1] != -1
Short: Timeframe Direction(T4) = -1 AND Timeframe Direction(T4)[1] != -1
Long: Consensus Direction = Bullish
Short: Consensus Direction = Bearish
Long: Consensus Direction = Bullish AND Consensus Direction[1] != Bullish
Short: Consensus Direction = Bearish AND Consensus Direction[1] != Bearish