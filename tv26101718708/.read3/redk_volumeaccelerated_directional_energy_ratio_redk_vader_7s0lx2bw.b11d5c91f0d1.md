Calculation: Volume factor = neutral factor when volume scaling mode is none or volume is unavailable; Stoch(volume, volume, volume, relative-volume lookback) / percentage normalization factor when mode is relative; volume when mode is full
Calculation: Directional volume change = fixnan(clamp(change(close) / ((highest(high, range lookback) - lowest(low, range lookback)) / range divisor), -move cap, move cap) × volume factor)
Calculation: Positive DER = selected MA(positive part of directional volume change, energy lookback) / selected MA(volume factor, energy lookback)
Calculation: Negative DER = selected MA(magnitude of negative part of directional volume change, energy lookback) / selected MA(volume factor, energy lookback)
Calculation: Demand energy = energy scale × WMA(positive DER, short average lookback)
Calculation: Supply energy = energy scale × WMA(negative DER, short average lookback)
Calculation: Net energy = WMA(demand energy - supply energy, smoothing lookback)
Calculation: Sentiment demand energy = energy scale × WMA(positive DER, sentiment lookback)
Calculation: Sentiment supply energy = energy scale × WMA(negative DER, sentiment lookback)
Calculation: Net sentiment energy = WMA(sentiment demand energy - sentiment supply energy, smoothing lookback)
Long: Net energy ≥ net-energy zero threshold
Long: Demand energy > supply energy
Long: Net sentiment energy ≥ sentiment zero threshold
Long: Net energy crosses above net-energy zero threshold
Short: Net energy < net-energy zero threshold
Short: Demand energy ≤ supply energy
Short: Net sentiment energy < sentiment zero threshold
Short: Net energy crosses below net-energy zero threshold