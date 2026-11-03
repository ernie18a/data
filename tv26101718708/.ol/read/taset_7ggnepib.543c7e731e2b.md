Calculation: RSI = Relative Strength Index of close
Calculation: Bullish divergence = a confirmed price pivot low is lower than the previous price pivot low while RSI at the latest pivot low is higher than RSI at the previous pivot low
Calculation: Bearish divergence = a confirmed price pivot high is higher than the previous price pivot high while RSI at the latest pivot high is lower than RSI at the previous pivot high
Calculation: Near support/resistance = close is within the configured percentage distance of any of the three latest confirmed pivot lows/highs, respectively, including the quick pivot
Calculation: Support/resistance space = the latest confirmed long-lookback pivot high is above the latest confirmed long-lookback pivot low, and their percentage separation exceeds the configured minimum
Long: (low < latest confirmed long-lookback pivot low and close > that pivot low OR near support) AND support/resistance space AND (RSI <= oversold threshold OR bullish divergence) AND RSI <= oversold threshold AND RSI > previous-bar RSI AND raw long condition was false on the previous bar
Short: (high > latest confirmed long-lookback pivot high and close < that pivot high OR near resistance) AND support/resistance space AND (RSI >= near-overbought threshold OR bearish divergence) AND RSI >= near-overbought threshold AND RSI < previous-bar RSI AND raw short condition was false on the previous bar
Long: bullish divergence
Short: bearish divergence
Long: a sellside sweep occurs below the captured recent-window low, then on a later bar low is below the prior bar's rolling short-lookback low
Short: a buyside sweep occurs above the captured recent-window high, then on a later bar low is below the prior bar's rolling short-lookback low
Exit: Long, high >= dynamic take-profit target OR low <= dynamic stop-loss target
Exit: Short, low <= dynamic take-profit target OR high >= dynamic stop-loss target
Calculation: Dynamic stop-loss target = at entry, the rolling short-lookback high plus ATR times the stop multiplier for a short, or rolling short-lookback low minus ATR times the stop multiplier for a long
Calculation: Dynamic take-profit target = entry price minus (absolute distance from entry to stop-loss target times the reward/risk multiplier) for a short, or entry price plus that distance for a long
Long: close crosses above the latest major swing high
Short: close crosses below the latest major swing low
Long: close crosses above the latest internal swing high
Short: close crosses below the latest internal swing low
Long: close crosses above the ATR trailing stop
Short: close crosses below the ATR trailing stop
Long: close is above the ATR trailing stop AND close crosses above the ATR trailing stop
Short: close is below the ATR trailing stop AND close crosses below the ATR trailing stop