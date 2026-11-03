Calculation: Heikin Ashi close = (open + high + low + close) / 4; Heikin Ashi open = (previous Heikin Ashi open + previous Heikin Ashi close) / 2, seeded with (open + close) / 2 on the first bar.
Calculation: Filtered midpoint = Heikin Ashi open and close midpoint, optionally smoothed using SMA, EMA, double EMA, SMMA, or LWMA; use the unsmoothed midpoint before the smoothing lookback is available. When the step filter is enabled, retain the previous filtered midpoint if the absolute change from it is less than the step threshold; otherwise use the current smoothed midpoint. Seed with the first midpoint.
Long: On the chart timeframe with the step filter disabled, Heikin Ashi close > Heikin Ashi open.
Short: On the chart timeframe with the step filter disabled, Heikin Ashi close < Heikin Ashi open.
Long: On the chart timeframe with the step filter enabled, filtered midpoint > previous filtered midpoint.
Short: On the chart timeframe with the step filter enabled, filtered midpoint < previous filtered midpoint.
Long: Heikin Ashi close > Heikin Ashi open.
Short: Heikin Ashi close < Heikin Ashi open.
Long: Higher-timeframe forming-bar Heikin Ashi close > Heikin Ashi open.
Short: Higher-timeframe forming-bar Heikin Ashi close < Heikin Ashi open.