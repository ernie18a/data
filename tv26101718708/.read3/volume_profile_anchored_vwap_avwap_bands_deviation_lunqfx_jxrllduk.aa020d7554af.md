Calculation: Anchored VWAP = sum(hlc3 × volume) / sum(volume) from the latest confirmed pivot high or low, limited by the maximum-leg lookback
Calculation: Anchored deviation = max(sqrt(max(0, sum(hlc3² × volume) / sum(volume) − Anchored VWAP²)) over the same anchor and lookback, ATR(ATR lookback) × deviation-floor parameter)
Long: close > Anchored VWAP
Short: close <= Anchored VWAP
Long: close crosses above Anchored VWAP
Short: close crosses below Anchored VWAP
Long: low <= Anchored VWAP − Anchored deviation × the band multiplier selected by the band selector from three separate band-multiplier parameters AND low[1] > Anchored VWAP[1] − Anchored deviation[1] × the same selected band multiplier
Short: high >= Anchored VWAP + Anchored deviation × the band multiplier selected by the band selector from three separate band-multiplier parameters AND high[1] < Anchored VWAP[1] + Anchored deviation[1] × the same selected band multiplier