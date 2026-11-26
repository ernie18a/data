Calculation: PrevSessionBodyRatio = abs(close - open) / (high - low) of the previous NY session bar, undefined when high = low
Calculation: PrevSessionClosePosition = (close - low) / (high - low) of the previous NY session bar, 0.5 when high = low
Calculation: PrevSessionConsolidation = PrevSessionBodyRatio < previous-session compression factor AND volume of the previous NY session bar > SMA(volume, daily volume average length, T4, last completed bar)[1] * previous-session volume factor
Calculation: Consolidation = Highest(high, range lookback) - Lowest(low, range lookback) < SMA(high - low, range lookback) * range lookback * compression factor AND SMA(volume, range lookback) > SMA(volume, volume average length) * volume concentration factor
Calculation: ConsolidationHigh = Highest(high, range lookback) at the most recent bar up to and including the current bar where Consolidation is true
Calculation: ConsolidationLow = Lowest(low, range lookback) at the most recent bar up to and including the current bar where Consolidation is true
Calculation: StochK = SMA(StochRSI(close, RSI length, stochastic RSI length), K smoothing length)
Calculation: StochD = SMA(StochK, D smoothing length)
Long: close > EMA(close, length A)
Short: close < EMA(close, length A)
Long: close > EMA(close, length B)
Short: close < EMA(close, length B)
Long: close > EMA(close, length C)
Short: close < EMA(close, length C)
Long: close > EMA(close, length D)
Short: close < EMA(close, length D)
Long: EMA(close, shorter length E) > EMA(close, longer length F)
Short: EMA(close, shorter length E) < EMA(close, longer length F)
Long: EMA(close, shorter length A) > EMA(close, longer length G)
Short: EMA(close, shorter length A) < EMA(close, longer length G)
Long: EMA(close, shorter length B) > EMA(close, longer length C)
Short: EMA(close, shorter length B) < EMA(close, longer length C)
Long: EMA(close, shorter length C) > EMA(close, longer length D)
Short: EMA(close, shorter length C) < EMA(close, longer length D)
Long: close > EMA(close, length A, T1, last completed bar)
Short: close < EMA(close, length A, T1, last completed bar)
Long: close > EMA(close, length B, T1, last completed bar)
Short: close < EMA(close, length B, T1, last completed bar)
Long: close > EMA(close, length C, T1, last completed bar)
Short: close < EMA(close, length C, T1, last completed bar)
Long: close > EMA(close, length D, T1, last completed bar)
Short: close < EMA(close, length D, T1, last completed bar)
Long: close > EMA(close, length A, T2, last completed bar)
Short: close < EMA(close, length A, T2, last completed bar)
Long: close > EMA(close, length B, T2, last completed bar)
Short: close < EMA(close, length B, T2, last completed bar)
Long: close > EMA(close, length C, T2, last completed bar)
Short: close < EMA(close, length C, T2, last completed bar)
Long: close > EMA(close, length D, T2, last completed bar)
Short: close < EMA(close, length D, T2, last completed bar)
Long: close > EMA(close, length A, T3, last completed bar)
Short: close < EMA(close, length A, T3, last completed bar)
Long: close > EMA(close, length B, T3, last completed bar)
Short: close < EMA(close, length B, T3, last completed bar)
Long: close > EMA(close, length C, T3, last completed bar)
Short: close < EMA(close, length C, T3, last completed bar)
Long: close > EMA(close, length D, T3, last completed bar)
Short: close < EMA(close, length D, T3, last completed bar)
Long: close > VWAP(session parameter)
Short: close < VWAP(session parameter)
Long: PrevSessionClosePosition > bull threshold
Short: PrevSessionClosePosition < bear threshold
Long: close > ConsolidationHigh AND (high - low) > SMA(high - low, range lookback) * breakout factor AND close > open AND close > close[1]
Short: close < ConsolidationLow AND (high - low) > SMA(high - low, range lookback) * breakout factor AND close < open AND close < close[1]
Long: previous NY session close > previous NY session open AND PrevSessionBodyRatio > previous-session breakout factor / 2 AND NOT PrevSessionConsolidation
Short: previous NY session close < previous NY session open AND PrevSessionBodyRatio > previous-session breakout factor / 2 AND NOT PrevSessionConsolidation
Long: RSI(close, RSI length) > RSI bull level AND StochK > StochD
Short: RSI(close, RSI length) < RSI bear level AND StochK < StochD
Long: RSI(close, RSI length) > strict RSI bull level AND StochK > StochD AND StochK < stochastic RSI overbought level
Short: RSI(close, RSI length) < strict RSI bear level AND StochK < StochD AND StochK > stochastic RSI oversold level
Long: StochK > StochD
Short: StochK < StochD
Long: RSI(close, RSI length) rounded to one decimal place > RSI color midline
Short: RSI(close, RSI length) rounded to one decimal place < RSI color midline
Long: close > open
Short: close < open