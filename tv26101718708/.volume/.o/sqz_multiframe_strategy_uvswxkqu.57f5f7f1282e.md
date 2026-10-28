Calculation: Squeeze Momentum = linear regression, over a lookback, of close minus the average of (the average of the lookback highest high and lowest low) and the lookback SMA of close; use the same lookback on current- and higher-timeframe bars
Calculation: CMF = sum of money-flow volume over a lookback divided by volume sum over that lookback, where money-flow volume is volume × (2 × close − high − low) / (high − low), or zero when high = low; use the current-timeframe bars
Calculation: Kaufman stop = low minus the SMA of high − low multiplied by a volatility factor for longs; high plus that amount for shorts
Long: higher-timeframe Squeeze Momentum on the still-forming bar > its prior value
Long: current-timeframe Squeeze Momentum > its prior value AND CMF at a recent bar is below its two preceding and two following values
Long: current-timeframe Squeeze Momentum is rising AND its minimum over a short lookback is below zero
Long: higher-timeframe Squeeze Momentum on the still-forming bar > its prior value AND current-timeframe Squeeze Momentum is rising AND its minimum over a short lookback is below zero AND CMF at a recent bar is below its two preceding and two following values
Short: higher-timeframe Squeeze Momentum on the still-forming bar < its prior value
Short: current-timeframe Squeeze Momentum < its prior value AND CMF at a recent bar is above its two preceding and two following values
Short: current-timeframe Squeeze Momentum is falling AND its maximum over a short lookback is above zero
Short: higher-timeframe Squeeze Momentum on the still-forming bar < its prior value AND current-timeframe Squeeze Momentum is falling AND its maximum over a short lookback is above zero AND CMF at a recent bar is above its two preceding and two following values
Exit: long, low <= the active stop; initialize the stop to the higher of the entry-bar Kaufman stop and the maximum-loss stop, then raise it to the configured profit-lock level each time close exceeds the next profit target
Exit: short, high >= the active stop; initialize the stop to the lower of the entry-bar Kaufman stop and the maximum-loss stop, then lower it to the configured profit-lock level each time close falls below the next profit target