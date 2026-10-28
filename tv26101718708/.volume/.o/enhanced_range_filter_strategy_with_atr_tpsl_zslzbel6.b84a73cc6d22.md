Calculation: Smoothed range = multiplier × EMA(EMA(abs(source − prior source), sampling period), 2 × sampling period − 1)
Calculation: Range filter = source − smoothed range when source is above the prior filter and that value exceeds it; source + smoothed range when source is below the prior filter and that value is below it; otherwise the prior filter
Calculation: Uptrend count = prior count + 1 when the range filter rises, 0 when it falls, otherwise prior count; downtrend count = prior count + 1 when the range filter falls, 0 when it rises, otherwise prior count
Calculation: Direction state = 1 on an uptrend setup, −1 on a downtrend setup, otherwise prior state
Calculation: ATR ratio = ATR / ((highest high − lowest low) / lookback)
Long: source > range filter AND source ≠ prior source AND uptrend count > 0 AND prior direction state = −1 AND (volume ≥ volume multiplier × volume moving average OR volume filter disabled) AND RSI < overbought threshold AND fast EMA > slow EMA AND ATR ratio ≥ ranging threshold
Short: source < range filter AND source ≠ prior source AND downtrend count > 0 AND prior direction state = 1 AND (volume ≥ volume multiplier × volume moving average OR volume filter disabled) AND RSI > oversold threshold AND fast EMA < slow EMA AND ATR ratio ≥ ranging threshold
Exit: long, low ≤ entry price − ATR × stop multiplier OR high ≥ entry price + ATR × take-profit multiplier × reward-risk ratio
Exit: short, high ≥ entry price + ATR × stop multiplier OR low ≤ entry price − ATR × take-profit multiplier × reward-risk ratio