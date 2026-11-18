Calculation: EMA_fast = EMA(close over chart bars, lookback_fast * T1/T0), with lookback_fast < lookback_second < lookback_third < lookback_slow
Calculation: EMA_second = EMA(close over chart bars, lookback_second * T1/T0)
Calculation: EMA_third = EMA(close over chart bars, lookback_third * T1/T0)
Calculation: EMA_slow = EMA(close over chart bars, lookback_slow * T1/T0)
Calculation: UpTrend = EMA_fast > EMA_second AND EMA_second > EMA_third AND EMA_third > EMA_slow
Calculation: DownTrend = EMA_fast < EMA_second AND EMA_second < EMA_third AND EMA_third < EMA_slow
Calculation: ChannelHigh = max(high[channel_shift .. channel_shift + channel_period - 1]) over chart bars
Calculation: ChannelLow = min(low[channel_shift .. channel_shift + channel_period - 1]) over chart bars
Calculation: ResistanceLine = ChannelHigh + entry_buffer
Calculation: SupportLine = ChannelLow - entry_buffer
Calculation: RsiValue = RSI(close over chart bars, rsi_period)
Long: UpTrend AND close > ResistanceLine
Long: UpTrend AND RsiValue <= lower_rsi_limit
Short: DownTrend AND close < SupportLine
Short: DownTrend AND RsiValue >= upper_rsi_limit