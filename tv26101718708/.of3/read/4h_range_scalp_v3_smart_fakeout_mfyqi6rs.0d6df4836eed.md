Calculation: RangeHigh = highest high during the range-building period
Calculation: RangeLow = lowest low during the range-building period
Calculation: ShortStop = highest high on bars closing above RangeHigh during the current excursion
Calculation: LongStop = lowest low on bars closing below RangeLow during the current excursion
Short: RangeHigh is defined AND close < RangeHigh after at least one close above RangeHigh, with no more than the outside-bar parameter closes above it since the excursion began AND (EMA filter is disabled OR close < EMA(close, longer-lookback parameter)) AND 0 < ShortStop - close < ATR(lookback) * stop-distance parameter AND no short entry has occurred in the current T1 period
Long: RangeLow is defined AND close > RangeLow after at least one close below RangeLow, with no more than the outside-bar parameter closes below it since the excursion began AND (EMA filter is disabled OR close > EMA(close, longer-lookback parameter)) AND 0 < close - LongStop < ATR(lookback) * stop-distance parameter AND no long entry has occurred in the current T1 period
Exit: short, high >= ShortStop OR low <= entry price - (ShortStop - entry price) * risk/reward parameter
Exit: long, low <= LongStop OR high >= entry price + (entry price - LongStop) * risk/reward parameter