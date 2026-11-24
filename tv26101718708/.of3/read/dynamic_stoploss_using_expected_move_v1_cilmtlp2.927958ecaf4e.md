Calculation: Entry Anchor = selected manual entry price, EMA(close, anchor lookback), VWAP(hlc3), or close according to anchor mode
Calculation: Selected Annualized Volatility = StDev(log(close / close[1]), RV lookback) × sqrt(bars per year), ATR(ATR lookback) / close × sqrt(bars per year), or their weighted sum using separate RV and ATR weights, according to volatility method
Calculation: Expected Move = Entry Anchor × Selected Annualized Volatility × sqrt(holding period bars / bars per year)
Calculation: Volatility Percentile = 100 × count of valid preceding Selected Annualized Volatility values strictly below the current value / count of valid preceding values over the percentile lookback; unavailable if none are valid
Calculation: Regime Multiplier = low volatility multiplier if Volatility Percentile < low volatility threshold; normal volatility multiplier if it is below the high volatility threshold; high volatility multiplier if it is below the extreme volatility threshold; otherwise extreme volatility multiplier; 1 if the percentile is unavailable
Calculation: Stop Distance = Expected Move × base stop sigma × Regime Multiplier
Calculation: Long Stop = Entry Anchor − Stop Distance in static mode; (high or close according to trailing basis) − Stop Distance in trailing mode; or the greater of the prior Long Stop and that trailing value in ratchet mode, using Entry Anchor − Stop Distance if the prior stop is unavailable; if break-even is enabled and close ≥ Entry Anchor + Expected Move × break-even trigger sigma, use the greater of that result and Entry Anchor
Calculation: Short Stop = Entry Anchor + Stop Distance in static mode; (low or close according to trailing basis) + Stop Distance in trailing mode; or the lesser of the prior Short Stop and that trailing value in ratchet mode, using Entry Anchor + Stop Distance if the prior stop is unavailable; if break-even is enabled and close ≤ Entry Anchor − Expected Move × break-even trigger sigma, use the lesser of that result and Entry Anchor
Calculation: Long Target 1 = Entry Anchor + Expected Move × target 1 sigma
Calculation: Long Target 2 = Entry Anchor + Expected Move × target 2 sigma
Calculation: Short Target 1 = Entry Anchor − Expected Move × target 1 sigma
Calculation: Short Target 2 = Entry Anchor − Expected Move × target 2 sigma
Exit: long, position mode includes long AND Long Stop is available AND close < Long Stop
Exit: short, position mode includes short AND Short Stop is available AND close > Short Stop
Exit: long, position mode includes long AND close ≥ Long Target 1
Exit: long, position mode includes long AND close ≥ Long Target 2
Exit: short, position mode includes short AND close ≤ Short Target 1
Exit: short, position mode includes short AND close ≤ Short Target 2