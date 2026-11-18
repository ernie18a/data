Calculation: Asian-session high = highest(high, bars during the Asian session)
Calculation: Asian-session low = lowest(low, bars during the Asian session)
Long: BOS display is enabled AND no BOS has been marked for the current Asian session AND since that session ended, a bar has had low < Asian-session low AND close > highest(high, lookback)[1]
Short: BOS display is enabled AND no BOS has been marked for the current Asian session AND since that session ended, a bar has had high > Asian-session high AND close < lowest(low, lookback)[1]