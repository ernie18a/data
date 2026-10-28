Calculation: Bollinger basis = simple moving average of close
Calculation: Awesome Oscillator = short-lookback simple moving average of hl2 minus long-lookback simple moving average of hl2; the long lookback is longer than the short lookback
Long: fast EMA crosses above Bollinger basis AND close > Bollinger basis AND Awesome Oscillator >= 0 AND Awesome Oscillator > its previous value
Short: fast EMA crosses below Bollinger basis AND close < Bollinger basis AND Awesome Oscillator <= its previous value
Long: fast EMA crosses above Bollinger basis AND close > Bollinger basis AND Awesome Oscillator >= 0 AND Awesome Oscillator > its previous value AND Supertrend is bullish
Short: fast EMA crosses below Bollinger basis AND close < Bollinger basis AND Awesome Oscillator <= its previous value AND Supertrend is bearish
Exit: long, high reaches any configured take-profit target above entry price OR close < entry price × (1 − configured stop-loss fraction)
Exit: short, low reaches any configured take-profit target below entry price OR close > entry price × (1 + configured stop-loss fraction)