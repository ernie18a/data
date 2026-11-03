Calculation: True range = max(high − low, abs(high − previous close), abs(low − previous close))
Calculation: ATR = simple moving average of true range over a lookback
Calculation: Bull and bear Andean components = sqrt(smoothed minimum of close²/open² minus squared smoothed minimum of close); sqrt(smoothed maximum of close²/open² minus squared smoothed maximum of close), respectively, using the same lookback and alpha = 2/(lookback + 1); update the smoothed maxima and minima recursively as in an Andean oscillator
Calculation: AlphaTrend = if RSI is at least 50, the greater of the prior AlphaTrend and low − ATR × multiplier; otherwise, the lesser of the prior AlphaTrend and high + ATR × multiplier
Calculation: Smoothed linear regression = EMA of linear regression of close at offset 0
Calculation: CloudMA = if bull Andean component > bear component, the greater of the prior CloudMA and the minimum of fast EMA, smoothed linear regression, and AlphaTrend from two bars earlier; if bear component > bull component, the lesser of the prior CloudMA and the maximum of those three values; otherwise, the prior CloudMA
Calculation: Cloud trend = 1 when CloudMA has risen for two consecutive bars, −1 when it has fallen for two consecutive bars, otherwise its prior value
Calculation: Confirmed pivot high/low = high/low that is greater/less than the configured number of bars on both sides; use the most recent confirmed pivot values
Calculation: Long stop = lowest confirmed pivot high over a lookback
Calculation: Short stop = highest confirmed pivot low over a lookback
Calculation: Long targets = entry price × (1 + ((entry price − long stop) / entry price) × risk-reward multiple); calculate a nearer and a farther target
Calculation: Short targets = entry price × (1 − ((short stop − entry price) / entry price) × risk-reward multiple); calculate a nearer and a farther target
Long: Cloud trend > 0 AND close > CloudMA AND position is flat or short AND datetime is strictly within the configured backtest time range AND this long-eligibility condition changed from its prior-bar value AND no long entry has already occurred in this uptrend, unless a long stop-loss occurred during this uptrend
Short: Cloud trend < 0 AND close < CloudMA AND position is flat or long AND datetime is strictly within the configured backtest time range AND this short-eligibility condition changed from its prior-bar value AND no short entry has already occurred in this downtrend, unless a short stop-loss occurred during this downtrend
Exit: Long, Cloud trend changes to −1 OR low <= long stop OR high >= nearer long target OR high >= farther long target
Exit: Short, Cloud trend changes to 1 OR high >= short stop OR low <= nearer short target OR low <= farther short target