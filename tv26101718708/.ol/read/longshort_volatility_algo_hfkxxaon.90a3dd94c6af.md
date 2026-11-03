Calculation: Ratio-adjusted net advances = multiplier × (weighted advances − weighted declines) / (weighted advances + weighted declines); the weights are configurable.
Calculation: Market oscillator = short-lookback EMA of ratio-adjusted net advances − long-lookback EMA of ratio-adjusted net advances. If ratio adjustment is disabled, use net advances instead. The oscillator uses the selected timeframe’s advance/decline data, which may be higher than the chart timeframe; use its last completed bar.
Calculation: Bollinger %B = (value − (SMA − 2 × standard deviation)) / (4 × standard deviation).
Calculation: Market breadth decline = the average of the last three one-bar changes in the SMA of the percent of stocks above a threshold.
Calculation: Skew rise = the average of the last three one-bar changes in the SMA of SKEW.
Calculation: Short-volatility roll yield = (front-month volatility futures close − VIX close) / VIX close. Use daily bars, higher than the chart timeframe when applicable, at their last completed bar.
Calculation: Fast and slow sell EMAs = short-lookback and long-lookback EMAs of the market oscillator.
Calculation: Fast and slow buy EMAs = short-lookback and long-lookback EMAs of the market oscillator.
Long: Market oscillator ≤ −100 AND market oscillator > its prior value
Short: Market oscillator ≥ 100 AND market oscillator < its prior value
Short: Position is flat or long AND (year is an election year beginning in 2004 and repeating every four years is false OR (current SKEW Bollinger %B > threshold OR prior SKEW Bollinger %B > threshold))
Short: Position is flat or short AND (year is an election year beginning in 2004 and repeating every four years is false OR fast buy EMA ≥ slow buy EMA)
Short: Position is flat or long AND (year is an election year beginning in 2004 and repeating every four years is false OR (MMFI Bollinger %B ≥ 0 AND prior MMFI Bollinger %B ≤ 0.01) AND skew rise > 0)
Short: Position is flat or long AND (year is an election year beginning in 2004 and repeating every four years is false OR (IWM close > its 12-period SMA AND skew rise > 0))
Long: Position is flat or short AND (year is an election year beginning in 2004 and month is October and day is 10 through 17 OR (short-volatility roll yield ≤ 0.01 AND market breadth decline < 0 AND fast sell EMA < slow sell EMA AND (VVIX daily Bollinger %B ≥ 0.90 OR VXX daily Bollinger %B ≥ 0.90 AND fast sell EMA < its prior value) AND current and prior SKEW Bollinger %B are both ≤ threshold AND IWM close ≤ its 12-period SMA))