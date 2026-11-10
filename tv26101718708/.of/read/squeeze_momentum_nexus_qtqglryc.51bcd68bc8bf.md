Calculation: Momentum = EMA of the linear regression endpoint of (source − (midpoint of the highest high and lowest low over the momentum lookback + SMA of close over the same lookback) / 2) over the momentum lookback; source is a selectable price series, and the EMA uses a separate smoothing length.
Calculation: Higher-timeframe momentum = the same momentum calculation on higher-timeframe bars using close as the source and the same momentum lookback and smoothing length; use the last completed higher-timeframe bar.
Calculation: Squeeze-off = lower Bollinger Band < lower Keltner Channel AND upper Bollinger Band > upper Keltner Channel; Bollinger Bands use an SMA of source plus or minus a multiplier times its standard deviation, and Keltner Channels use an SMA of source plus or minus a multiplier times the SMA of either true range or high − low, with separate band and channel lookbacks and multipliers.
Long: Momentum > 0
Short: Momentum < 0
Long: Higher-timeframe momentum > 0
Short: Higher-timeframe momentum < 0
Long: Close > EMA of close
Short: Close < EMA of close
Long: Squeeze-off AND momentum > 0 AND momentum != previous-bar momentum
Short: Squeeze-off AND momentum < 0 AND momentum != previous-bar momentum