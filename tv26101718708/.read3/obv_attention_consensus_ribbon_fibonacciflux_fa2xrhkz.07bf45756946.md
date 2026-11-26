Calculation: standardized OBV sensor for each Ti = clamp((linreg(OBV(close, volume), slope lookback, 0) - linreg(OBV(close, volume), slope lookback, 1)) / max(stdev(OBV(close, volume), normalization lookback), epsilon), -z limit, z limit), calculated on Ti bars and sampled from the last completed Ti bar in confirmed mode or the still-forming Ti bar in developing mode; the slope and normalization lookbacks are shared across T1, T2, T3, and T4
Calculation: sensor change for each Ti = standardized OBV sensor(Ti) - standardized OBV sensor(Ti)[1], with [1] the prior Ti bar and the same confirmed or developing mode as the sensor
Calculation: normalized attention weight wi = configured weight ai / sum(a1, a2, a3, a4) when that sum is positive, otherwise fallback weight fi; i = 1, 2, 3, 4, with separate configured and fallback weights for each timeframe and fallback weights summing to one
Calculation: weighted consensus = sum(wi * sensor(Ti)) for i = 1, 2, 3, 4
Calculation: weighted dispersion = sqrt(sum(wi * (sensor(Ti) - weighted consensus)^2)) for i = 1, 2, 3, 4
Calculation: concentration = 1 - clamp(weighted dispersion / concentration scale, 0, 1)
Calculation: bullish side share = sum(wi * 1 when sensor(Ti) > 0, otherwise 0) for i = 1, 2, 3, 4
Calculation: bearish side share = sum(wi * 1 when sensor(Ti) < 0, otherwise 0) for i = 1, 2, 3, 4
Calculation: bullish acceleration share = sum(wi * clamp(sensor change(Ti) / acceleration scale, 0, 1)) for i = 1, 2, 3, 4
Calculation: bearish acceleration share = sum(wi * clamp(-sensor change(Ti) / acceleration scale, 0, 1)) for i = 1, 2, 3, 4
Calculation: bullish strength = 100 * cube root(max(concentration * bullish side share * bullish acceleration share, 0))
Calculation: bearish strength = 100 * cube root(max(concentration * bearish side share * bearish acceleration share, 0))
Calculation: bullish active = bullish strength >= strength threshold AND bullish strength > bearish strength
Calculation: bearish active = bearish strength >= strength threshold AND bearish strength > bullish strength
Long: (NOT chart-close-only OR confirmed chart bar) AND bullish active AND NOT bullish active[1]
Short: (NOT chart-close-only OR confirmed chart bar) AND bearish active AND NOT bearish active[1]