Calculation: High volume = volume > SMA(volume, volume lookback) * volume multiplier
Long: close(T1, still-forming bar, mapped to chart bars) > SMA(close, stage lookback, T1, still-forming bar, mapped to chart bars) AND close(T1, still-forming bar, mapped to chart bars) > SMA(close, monthly MA lookback, T2, still-forming bar, mapped to chart bars) AND bars_since(high >= highest(high[1], higher-high lookback, T1), T1, still-forming bar, mapped to chart bars) <= higher-high hold AND RSI(close, RSI lookback, T2, still-forming bar, mapped to chart bars) > RSI threshold
Long: High volume AND close >= open
Short: High volume AND close < open
Exit: long, high < SMA(close, monthly MA lookback, T2, still-forming bar, mapped to chart bars)
Long: Stage-2 trend of the traded instrument on T1 AND higher high of the traded instrument on T1 AND RSI strength of the traded instrument on T2 AND relative strength of the traded instrument versus NIFTY MidSmall
Exit: long, traded instrument below its P1-period moving average on T2