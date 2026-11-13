Calculation: Fast EMA / Slow EMA = EMA of close with a shorter lookback / EMA of close with a longer lookback
Calculation: Session VWAP = cumulative sum of (typical price * volume) / cumulative volume, reset at each new trading day, where typical price = (high+low+close)/3
Calculation: Bar delta = volume * (2*close - high - low) / (high - low); 0 if high == low
Calculation: Smoothed delta = short-lookback EMA of Bar delta
Calculation: CVD = cumulative sum of Bar delta, reset at each new trading day
Calculation: Relative volume = volume / simple moving average of volume
Calculation: Delta peak = highest value of abs(Smoothed delta) over the last L bars including the current bar
Long: at least 4 of these 5 are true: close > Session VWAP; Fast EMA > Slow EMA; Fast EMA > Fast EMA 3 bars ago; Smoothed delta > 0; CVD > CVD 5 bars ago
Long: all 5 of the above are true AND Relative volume >= a threshold above its average (1.0)
Short: at least 4 of these 5 are true: close <= Session VWAP; Fast EMA <= Slow EMA; Fast EMA <= Fast EMA 3 bars ago; Smoothed delta <= 0; CVD <= CVD 5 bars ago
Short: all 5 of the above are true AND Relative volume >= a threshold above its average (1.0)
Exit: long, high >= highest high of the last L bars including the current bar AND Smoothed delta > 0 AND abs(Smoothed delta) < a fraction (<1) of Delta peak AND Smoothed delta < Smoothed delta 3 bars ago
Exit: short, low <= lowest low of the last L bars including the current bar AND Smoothed delta < 0 AND abs(Smoothed delta) < a fraction (<1) of Delta peak AND Smoothed delta > Smoothed delta 3 bars ago