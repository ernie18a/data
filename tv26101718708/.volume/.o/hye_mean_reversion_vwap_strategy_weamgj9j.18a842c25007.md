Calculation: Short-lookback VWAP = sum(((high + low + close) / 3) × volume, short lookback) / sum(volume, short lookback)
Calculation: Long-lookback VWAP = sum(((high + low + close) / 3) × volume, longer lookback) / sum(volume, longer lookback)
Calculation: RSI filter = EMA of the RSI of close, using a shorter RSI lookback and a longer EMA lookback
Long: Short-lookback VWAP crosses below Long-lookback VWAP × (1 − configured buy percentage) AND RSI filter < configured buy level AND datetime is within the configured date range AND position side is flat or short AND long trading is enabled
Short: Short-lookback VWAP crosses above Long-lookback VWAP × (1 + configured sell percentage) AND RSI filter > configured sell level AND datetime is within the configured date range AND position side is flat or short AND short trading is enabled
Exit: Long, Short-lookback VWAP crosses above Long-lookback VWAP OR datetime is outside the configured date range
Exit: Short, Short-lookback VWAP crosses above Long-lookback VWAP OR datetime is outside the configured date range