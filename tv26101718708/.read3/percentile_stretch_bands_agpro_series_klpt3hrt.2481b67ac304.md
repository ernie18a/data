Calculation: Reference = EMA(EMA source, reference lookback), VWAP(VWAP source), or anchored VWAP(VWAP source, volume, anchor timestamp), selected by reference mode
Calculation: Distance = 100 * (close / Reference - 1)
Calculation: Empirical percentile(values, percentile) = linearly interpolated value at index percentile / 100 * (count(values) - 1) after sorting values ascending
Calculation: Upper stretch band = Reference * (1 + Empirical percentile({Distance[n] | 1 <= n <= lookback and Distance[n] > 0}, stretch percentile) / 100), when positive sample count >= minimum side sample and the upper band is not hidden by the focus-active-side setting
Calculation: Upper extreme band = Reference * (1 + Empirical percentile({Distance[n] | 1 <= n <= lookback and Distance[n] > 0}, higher extreme percentile) / 100), when positive sample count >= minimum side sample and the upper band is not hidden by the focus-active-side setting
Calculation: Lower stretch band = Reference * (1 - Empirical percentile({abs(Distance[n]) | 1 <= n <= lookback and Distance[n] < 0}, stretch percentile) / 100), when negative sample count >= minimum side sample and the lower band is not hidden by the focus-active-side setting
Calculation: Lower extreme band = Reference * (1 - Empirical percentile({abs(Distance[n]) | 1 <= n <= lookback and Distance[n] < 0}, higher extreme percentile) / 100), when negative sample count >= minimum side sample and the lower band is not hidden by the focus-active-side setting
Calculation: Upper rank = 100 * count({Distance[n] | 1 <= n <= lookback and Distance[n] > 0 and Distance[n] <= Distance}) / positive sample count, when positive sample count >= minimum side sample
Calculation: Lower rank = 100 * count({abs(Distance[n]) | 1 <= n <= lookback and Distance[n] < 0 and abs(Distance[n]) <= abs(Distance)}) / negative sample count, when negative sample count >= minimum side sample
Short: close crosses above Upper stretch band
Short: close crosses above Upper extreme band
Long: close crosses below Lower stretch band
Long: close crosses below Lower extreme band
Short: Distance > 0 AND Upper rank >= higher extreme percentile
Short: Distance > 0 AND Upper rank >= stretch percentile AND Upper rank < higher extreme percentile
Long: Distance < 0 AND Lower rank >= higher extreme percentile
Long: Distance < 0 AND Lower rank >= stretch percentile AND Lower rank < higher extreme percentile