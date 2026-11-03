Calculation: Smoothed OHLC = apply the same configurable smoothing method and lookback to each bar’s open, high, low, and close
Calculation: Heikin-Ashi close = (smoothed open + smoothed high + smoothed low + smoothed close) / 4
Calculation: Heikin-Ashi open = previous Heikin-Ashi open and close average; use previous Heikin-Ashi close instead when |bar open − bar close| ≤ the configurable gap threshold. Seed the first bar’s previous open and close with its raw open and close.
Calculation: Heikin-Ashi trend = +1 when Heikin-Ashi close > Heikin-Ashi open; −1 when Heikin-Ashi close < Heikin-Ashi open; otherwise retain the prior trend. Seed the first trend as 0.
Long: current Heikin-Ashi trend > 0 AND previous Heikin-Ashi trend ≤ 0
Short: current Heikin-Ashi trend < 0 AND previous Heikin-Ashi trend ≥ 0