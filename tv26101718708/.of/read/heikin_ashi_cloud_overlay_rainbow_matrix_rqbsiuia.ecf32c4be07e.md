Calculation: Heikin Ashi close = (open + high + low + close) / 4; Heikin Ashi open = (open + close) / 2 on the first bar, otherwise (previous Heikin Ashi open + previous Heikin Ashi close) / 2.
Calculation: Heikin Ashi body percentage = 100 × absolute value of (Heikin Ashi close − Heikin Ashi open) / Heikin Ashi open when Heikin Ashi open > 0, otherwise 0; average body percentage = simple moving average of Heikin Ashi body percentage, including the current bar.
Long: Heikin Ashi close ≥ Heikin Ashi open.
Short: Heikin Ashi close < Heikin Ashi open.
Long: Higher-timeframe Heikin Ashi close ≥ higher-timeframe Heikin Ashi open, using the last completed higher-timeframe bar.
Short: Higher-timeframe Heikin Ashi close < higher-timeframe Heikin Ashi open, using the last completed higher-timeframe bar.
Long: Heikin Ashi close ≥ Heikin Ashi open AND average body percentage > 0 AND Heikin Ashi body percentage > anomaly multiplier × average body percentage.
Short: Heikin Ashi close < Heikin Ashi open AND average body percentage > 0 AND Heikin Ashi body percentage > anomaly multiplier × average body percentage.