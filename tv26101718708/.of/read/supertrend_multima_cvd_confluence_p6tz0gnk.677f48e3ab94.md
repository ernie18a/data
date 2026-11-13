Calculation: Fast MA, Slow MA = EMA of close, fast has a shorter lookback than slow
Calculation: CVD = running cumulative sum of per-bar delta, where delta = volume*((close-low)-(high-close))/(high-low), and 0 if high==low
Calculation: Volatility OK = ATR > simple moving average of ATR
Calculation: Cooldown OK = bars since the last Long or Short signal of either direction >= a minimum bar count
Calculation: SuperTrend = standard ATR-band trailing SuperTrend; uptrend means price is above the line, downtrend means price is below it
Long: Fast MA crosses above Slow MA AND CVD > previous bar CVD AND Volatility OK AND Cooldown OK
Short: Fast MA crosses below Slow MA AND CVD <= previous bar CVD AND Volatility OK AND Cooldown OK
Long: Fast MA > Slow MA AND ADX >= a threshold
Short: Fast MA <= Slow MA AND ADX >= a threshold
Long: SuperTrend is in uptrend
Short: SuperTrend is in downtrend
Long: Fast MA > Slow MA, computed on bars of a timeframe different from the chart (lower or higher), using the bar still forming
Short: Fast MA <= Slow MA, computed on bars of a timeframe different from the chart (lower or higher), using the bar still forming
Exit: long, Fast MA crosses below Slow MA OR SuperTrend turns to downtrend
Exit: short, Fast MA crosses above Slow MA OR SuperTrend turns to uptrend