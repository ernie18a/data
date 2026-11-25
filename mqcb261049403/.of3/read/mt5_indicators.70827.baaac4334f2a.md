Calculation: Filtered HA midpoint = selected moving average((Heikin-Ashi close + Heikin-Ashi open)/2, smoothing lookback, smoothing method), or (Heikin-Ashi close + Heikin-Ashi open)/2 with smoothing disabled; with step filtering enabled, retain the previous filtered HA midpoint when the absolute difference from the selected moving average is less than the step threshold, otherwise use the selected moving average
Calculation: HA strength = when candle display mode is selected, round(100 × abs(Heikin-Ashi close − Heikin-Ashi open)/abs(Heikin-Ashi high − Heikin-Ashi low)), capped at 100, or the zero-range fallback when the range is zero; when line display mode is selected, 100 when Heikin-Ashi close differs from Heikin-Ashi open, otherwise the zero-range fallback
Long: On chart bars using chart-timeframe data, Heikin-Ashi close > Heikin-Ashi open
Short: On chart bars using chart-timeframe data, Heikin-Ashi close < Heikin-Ashi open
Long: On chart bars using chart-timeframe data, step filtering enabled, filtered HA midpoint > its previous value
Short: On chart bars using chart-timeframe data, step filtering enabled, filtered HA midpoint < its previous value
Long: On chart bars using current/forming T1 data, Heikin-Ashi close > Heikin-Ashi open
Short: On chart bars using current/forming T1 data, Heikin-Ashi close < Heikin-Ashi open
Long: On chart bars using chart-timeframe data, HA strength >= upper strength threshold
Short: On chart bars using chart-timeframe data, HA strength < lower strength threshold
Long: On chart bars using current/forming T1 data, HA strength >= upper strength threshold
Short: On chart bars using current/forming T1 data, HA strength < lower strength threshold
Long: On chart bars with step filtering disabled, Heikin-Ashi close > Heikin-Ashi open AND previous chart bar Heikin-Ashi close <= previous chart bar Heikin-Ashi open
Short: On chart bars with step filtering disabled, Heikin-Ashi close < Heikin-Ashi open AND previous chart bar Heikin-Ashi close >= previous chart bar Heikin-Ashi open
Long: On chart bars with step filtering enabled, filtered HA midpoint > its previous value AND its previous value <= its value two bars ago
Short: On chart bars with step filtering enabled, filtered HA midpoint < its previous value AND its previous value >= its value two bars ago
Long: At a T1 bar transition, current/forming T1 Heikin-Ashi close > Heikin-Ashi open AND previous completed T1 Heikin-Ashi close <= Heikin-Ashi open
Short: At a T1 bar transition, current/forming T1 Heikin-Ashi close < Heikin-Ashi open AND previous completed T1 Heikin-Ashi close >= Heikin-Ashi open
Long: On the last completed chart bar using current/forming T1 data, Heikin-Ashi close > Heikin-Ashi open AND the T1 Heikin-Ashi close mapped to the previous chart bar <= its Heikin-Ashi open
Short: On the last completed chart bar using current/forming T1 data, Heikin-Ashi close < Heikin-Ashi open AND the T1 Heikin-Ashi close mapped to the previous chart bar >= its Heikin-Ashi open