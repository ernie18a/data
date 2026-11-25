Calculation: Position floating profit = position profit + swap + commission
Calculation: Long basket floating profit = sum of position floating profit over the strategy's long positions
Calculation: Short basket floating profit = sum of position floating profit over the strategy's short positions
Calculation: Combined floating profit = sum of position floating profit over the strategy's long and short positions
Calculation: Profit target = take-profit parameter as a percentage of account balance when target mode is percentage, or take-profit parameter as a fixed amount otherwise
Calculation: Loss limit = maximum-loss parameter as a percentage of account balance when target mode is percentage, or maximum-loss parameter as a fixed amount otherwise
Long: Supertrend direction using chart bars at the last completed bar, ATR lookback, ATR multiplier, and either Wilder ATR or simple average true range is bullish AND (the strategy has no open long position OR the HTF filter is disabled OR Supertrend direction using T1 bars at the last completed T1 bar, ATR lookback, ATR multiplier, and the same ATR method is bullish)
Short: Supertrend direction using chart bars at the last completed bar, ATR lookback, ATR multiplier, and either Wilder ATR or simple average true range is bearish AND (the strategy has no open short position OR the HTF filter is disabled OR Supertrend direction using T1 bars at the last completed T1 bar, ATR lookback, ATR multiplier, and the same ATR method is bearish)
Exit: long, long basket floating profit >= profit target OR combined floating profit <= -loss limit
Exit: short, short basket floating profit >= profit target OR combined floating profit <= -loss limit