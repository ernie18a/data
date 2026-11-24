Calculation: pressure score = pressure scale * clamp(z-score(EMA(body weight * (close - open) / max(EMA(abs(close - open), body normalization lookback), minimum tick) + close-location weight * (if high = low then 0 else 2 * (close - low) / (high - low) - 1) + range weight * ((high - low) - EMA(high - low, range normalization lookback)) / max(EMA(high - low, range normalization lookback), minimum tick) + volume weight * (if volume impulse enabled then (volume - EMA(volume, volume normalization lookback)) / max(EMA(volume, volume normalization lookback), 1) else 0), pressure-memory lookback), normalization lookback), -100, 100); z-score = (value - SMA(value, normalization lookback)) / STDEV(value, normalization lookback), or 0 when the standard deviation is 0
Calculation: channel context = EMA(clamp(100 * (close - (channel mid - channel offset)) / max(2 * channel offset, minimum tick) - 50, -100, 100), context smoothing lookback), where channel mid = EMA((high + low) / 2, channel lookback) and channel offset = EMA(high - low, channel lookback) * (channel scale / 100) * (1 + EMA(abs(close - open), channel lookback) / max(EMA(high - low, channel lookback), minimum tick) * channel body boost)
Calculation: composite pressure = EMA(EMA(pressure score * pressure/context blend + channel context * (1 - pressure/context blend), pre-smoothing lookback), main smoothing lookback)
Calculation: signal = EMA(composite pressure, signal lookback)
Calculation: regime state = 1 if composite pressure > upper regime threshold + hysteresis; -1 if composite pressure < lower regime threshold - hysteresis; 0 if prior regime state = 1 and composite pressure < upper regime threshold - hysteresis, or prior regime state = -1 and composite pressure > lower regime threshold + hysteresis; otherwise prior regime state, initially 0
Long: composite pressure >= 0
Short: composite pressure < 0
Long: channel context >= 0
Short: channel context < 0
Long: composite pressure > signal
Short: composite pressure < signal
Long: composite pressure > composite pressure[1]
Short: composite pressure < composite pressure[1]
Long: regime state = 1
Short: regime state = -1
Long: regime state = 1 AND regime state[1] != 1 AND current chart bar is closed
Short: regime state = -1 AND regime state[1] != -1 AND current chart bar is closed
Long: composite pressure crosses above signal AND current chart bar is closed
Short: composite pressure crosses below signal AND current chart bar is closed
Long: regime state = 1 AND composite pressure > upper extreme threshold AND abs(composite pressure - composite pressure[1]) > expansion trigger AND current chart bar is closed
Short: regime state = -1 AND composite pressure < lower extreme threshold AND abs(composite pressure - composite pressure[1]) > expansion trigger AND current chart bar is closed
Long: divergence detection and regular divergence are enabled AND a current pivot low of composite pressure is confirmed AND the prior pivot low was confirmed within the minimum and maximum pivot spacing AND low[pivot right bars ago] < the prior pivot low price AND composite pressure[pivot right bars ago] > the prior pivot low value AND current chart bar is closed
Short: divergence detection and regular divergence are enabled AND a current pivot high of composite pressure is confirmed AND the prior pivot high was confirmed within the minimum and maximum pivot spacing AND high[pivot right bars ago] > the prior pivot high price AND composite pressure[pivot right bars ago] < the prior pivot high value AND current chart bar is closed
Long: divergence detection and hidden divergence are enabled AND a current pivot low of composite pressure is confirmed AND the prior pivot low was confirmed within the minimum and maximum pivot spacing AND low[pivot right bars ago] > the prior pivot low price AND composite pressure[pivot right bars ago] < the prior pivot low value AND current chart bar is closed
Short: divergence detection and hidden divergence are enabled AND a current pivot high of composite pressure is confirmed AND the prior pivot high was confirmed within the minimum and maximum pivot spacing AND high[pivot right bars ago] < the prior pivot high price AND composite pressure[pivot right bars ago] > the prior pivot high value AND current chart bar is closed