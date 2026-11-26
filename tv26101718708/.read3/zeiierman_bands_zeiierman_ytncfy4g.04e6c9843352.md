Calculation: Upper wick = max(0, high - max(open, close))
Calculation: Lower wick = max(0, min(open, close) - low)
Calculation: Observation weight = clamp((volume-valid ? volume / SMA(volume, base lookback) / max(TrueRange / SMA(TrueRange, base lookback), range-ratio floor) : 1), weight floor, weight ceiling) ^ weight exponent, where volume-valid means volume > 0 and SMA(volume, base lookback) > 0
Calculation: Adjusted close = close + wick adjustment factor * (lower wick - upper wick)
Calculation: Liquidity mean = SMA(close, base lookback) + mean blend factor * (sum(adjusted close * observation weight) / sum(observation weight) - SMA(close, base lookback)), over the base lookback
Calculation: Sweep lookback = max(minimum sweep lookback, round(base lookback * sweep-lookback fraction))
Calculation: Upper sweep sample = if high >= prior highest high over the sweep lookback minus SMA(TrueRange, base lookback) * sweep-proximity factor, then upper wick + (high > prior highest high AND close < prior highest high ? sweep-penetration factor * (high - prior highest high) + sweep-rejection factor * (high - close) : 0), else 0
Calculation: Lower sweep sample = if low <= prior lowest low over the sweep lookback plus SMA(TrueRange, base lookback) * sweep-proximity factor, then lower wick + (low < prior lowest low AND close > prior lowest low ? sweep-penetration factor * (prior lowest low - low) + sweep-rejection factor * (close - low) : 0), else 0
Calculation: Rolling stress deviation = sqrt(mean((close[i] - current liquidity mean)^2, i over the base lookback))
Calculation: RMS(x, lookback) = sqrt(mean(x[i]^2, i over the lookback))
Calculation: Upper stress = sqrt(rolling stress deviation^2 + (stress wick factor * RMS(upper wick, base lookback))^2 + (stress sweep factor * RMS(upper sweep sample, base lookback))^2)
Calculation: Lower stress = sqrt(rolling stress deviation^2 + (stress wick factor * RMS(lower wick, base lookback))^2 + (stress sweep factor * RMS(lower sweep sample, base lookback))^2)
Calculation: Stress position = (close - liquidity mean) / upper stress when close >= liquidity mean, otherwise (close - liquidity mean) / lower stress
Calculation: OU model lookback = max(minimum OU model lookback, base lookback * OU model-lookback multiplier)
Calculation: OU half-life = ln(0.5) / ln(AR1 slope of log(close / liquidity mean) on its prior-bar value over the OU model lookback), when the slope is between 0 and 1
Calculation: OU mean drift = abs(current liquidity mean - liquidity mean base-lookback bars ago) / mean(upper stress, lower stress)
Calculation: OU filter passes = stress position is defined AND (OU filter disabled OR (more than OU model lookback + base lookback chart bars have elapsed AND OU half-life is at least the OU minimum half-life and at most base lookback * OU half-life multiplier / OU strictness AND OU mean drift <= 1 / OU strictness))
Calculation: Path efficiency = min(abs(close - close[path-efficiency lookback bars ago]) / (SMA(abs(change(close)), path-efficiency lookback) * path-efficiency lookback), 1)
Calculation: Color source timeframe = configured color timeframe T1, or its fixed auto-map replacement when auto color timeframe is enabled and the chart timeframe equals T1; on each chart bar use the last completed bar of the resulting timeframe T2
Calculation: Liquidity target = clamp(normalization factor * (chart close - midpoint of the last completed T2 high and low) / (last completed T2 high - low) * path efficiency, -maximum tension, maximum tension)
Calculation: Liquidity tension = clamp(prior chart-bar tension + alpha * (liquidity target - prior chart-bar tension), -maximum tension, maximum tension), where alpha = 2 / (tension build length + 1) if target and prior tension have the same sign or either is zero AND abs(target) > abs(prior tension), otherwise alpha = 2 / (tension release length + 1)
Calculation: Liquidity regime = bullish when liquidity tension >= trend tension threshold, bearish when liquidity tension <= -trend tension threshold, otherwise neutral
Calculation: Outer stress threshold = deviation multiplier; inner reclaim threshold = deviation multiplier * reclaim ratio
Calculation: Armed-long state = on each confirmed chart bar, false if the OU filter fails or either reclaim fires; otherwise true if stress position <= -outer stress threshold, false if stress position >= 0, otherwise carry the prior state
Calculation: Armed-short state = on each confirmed chart bar, false if the OU filter fails or either reclaim fires; otherwise true if stress position >= outer stress threshold, false if stress position <= 0, otherwise carry the prior state
Long: liquidity tension >= trend tension threshold AND prior chart-bar liquidity tension < trend tension threshold
Short: liquidity tension <= -trend tension threshold AND prior chart-bar liquidity tension > -trend tension threshold
Long: prior confirmed chart-bar armed-long state AND stress position crosses above -inner reclaim threshold AND stress position < 0 AND OU filter passes AND (trend alignment disabled OR liquidity regime is bullish)
Short: prior confirmed chart-bar armed-short state AND stress position crosses below inner reclaim threshold AND stress position > 0 AND OU filter passes AND (trend alignment disabled OR liquidity regime is bearish)