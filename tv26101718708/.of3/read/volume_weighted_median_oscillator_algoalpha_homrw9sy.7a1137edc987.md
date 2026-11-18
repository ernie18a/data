Calculation: VolumeWeightedMedian = volume-weighted median of hlc3 over the shared short lookback
Calculation: RangeScale = max(EMA(high - low, range lookback), minimum tick)
Calculation: MomentumHistogram = if smoothing is enabled then WMA((close - VolumeWeightedMedian) / RangeScale, smoothing lookback) else (close - VolumeWeightedMedian) / RangeScale
Calculation: MedianOscillator = if smoothing is enabled then WMA((VolumeWeightedMedian - EMA(VolumeWeightedMedian, longer lookback)) / RangeScale, smoothing lookback) else (VolumeWeightedMedian - EMA(VolumeWeightedMedian, longer lookback)) / RangeScale
Calculation: SignalLine = EMA(MedianOscillator, shared short lookback)
Long: MomentumHistogram crosses above zero OR MedianOscillator crosses above zero OR MedianOscillator crosses above SignalLine OR (MedianOscillator >= SignalLine AND MedianOscillator[1] < SignalLine[1]) OR MedianOscillator crosses below negative extreme threshold
Short: MomentumHistogram crosses below zero OR MedianOscillator crosses below zero OR MedianOscillator crosses below SignalLine OR MedianOscillator crosses above extreme threshold
Exit: short, MedianOscillator crosses below extreme threshold
Exit: long, MedianOscillator crosses above negative extreme threshold