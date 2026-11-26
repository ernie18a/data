Calculation: CVD factor = if CVD is enabled, VWMA(((close - low) - (high - close)) / max(high - low, minimum tick) * volume, CVD lookback), otherwise unit constant
Calculation: absorption factor = if absorption is enabled, (volume / max(high - low, minimum tick)) / VWMA(volume / max(high - low, minimum tick), absorption lookback), otherwise unit constant
Calculation: composite weight = max(abs(CVD factor) * absorption factor * volume, unit constant)
Calculation: composite institutional moving average = VWMA(close * composite weight, composite lookback) / VWMA(composite weight, composite lookback); calculate on chart bars, or on T1 bars when multi-timeframe is enabled and carry the current T1 value to chart bars (forming in realtime, last completed on historical bars)
Long: close >= composite institutional moving average
Short: close < composite institutional moving average