Calculation: consensus = 100 × sum of votes for enabled indicators / number of enabled indicators, or 0 if none; each vote is +1 when indicator(primary close, primary lookback)[primary lag] > indicator(reference close, reference lookback)[reference lag], otherwise −1; indicators are ROC, CCI, RSI, MFI, and CMO
Long: consensus > 0
Short: consensus < 0
Calculation: Consensus score = 100 × (sum of enabled votes / number of enabled indicators), where each vote is +1 if the lagged indicator of Bitcoin closing price exceeds the lagged same indicator of Global Liquidity and −1 otherwise; indicators are ROC, CCI, RSI, MFI, and CMO, each with separate Bitcoin and Global Liquidity lookback parameters and lag parameters, and an individual enable parameter; score is 0 if no indicators are enabled
Long: Consensus score > 0
Short: Consensus score < 0