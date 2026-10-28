Calculation: RSI = relative strength index of close
Calculation: ATR = simple moving average of true range
Calculation: Alpha trend = if RSI >= 50, the greater of the prior Alpha trend and low − ATR × multiplier; otherwise, the lesser of the prior Alpha trend and high + ATR × multiplier
Calculation: Andean bullish and bearish components = recursively smoothed close/open and squared close/open envelopes; bullish = sqrt(smoothed lower squared envelope − smoothed lower envelope²), bearish = sqrt(smoothed upper squared envelope − smoothed upper envelope²)
Calculation: Cloud average = if Andean bullish > bearish, the greater of the prior cloud average and the lowest of a short-term EMA, a smoothed linear regression of close, and the Alpha trend from two bars earlier; if bearish > bullish, the lesser of the prior cloud average and the highest of those three values; otherwise, the prior cloud average
Calculation: Cloud trend = 1 when the cloud average has risen for two bars, −1 when it has fallen for two bars, otherwise its prior value
Calculation: Swing low/high = latest confirmed pivot low/high, using the configured pivot lookup; rolling swing low/high = lowest/highest swing low/high over the configured sizing lookback
Calculation: Long target 1/2 = entry price × (1 + ((entry price − rolling swing low) / entry price) × reward/risk multiple 1/2)
Calculation: Short target 1/2 = entry price × (1 − ((rolling swing high − entry price) / entry price) × reward/risk multiple 1/2)
Long: cloud trend > 0 AND close > cloud average AND within configured backtest time range AND position is flat or short AND long setup changes from its prior value AND long entry is permitted by the trend/re-entry gate
Short: cloud trend < 0 AND close < cloud average AND within configured backtest time range AND position is flat or long AND short setup changes from its prior value AND short entry is permitted by the trend/re-entry gate
Exit: long, cloud trend changes to −1 OR low <= rolling swing low OR high >= long target 1 OR high >= long target 2
Exit: short, cloud trend changes to 1 OR high >= rolling swing high OR low <= short target 1 OR low <= short target 2