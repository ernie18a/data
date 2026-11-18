Calculation: upper band = MA(close, lookback, selected type) + (MA(high, same lookback, same type) - MA(close, same lookback, same type)) * distance multiplier
Calculation: lower band = MA(close, lookback, selected type) - (MA(close, same lookback, same type) - MA(low, same lookback, same type)) * distance multiplier
Long: low > MA(close, lookback, selected type)
Short: high < MA(close, lookback, selected type)
Long: After close crosses above upper band, the pending trigger is that bar's high and remains pending on subsequent bars until a close crosses below lower band or the trigger breaks; each new close crossing above upper band replaces the pending trigger with that bar's high
Short: After close crosses below lower band, the pending trigger is that bar's low and remains pending on subsequent bars until a close crosses above upper band or the trigger breaks; each new close crossing below lower band replaces the pending trigger with that bar's low
Long: While an upper-band trigger is pending, open > its high OR close crosses above its high
Short: While a lower-band trigger is pending, open < its low OR close crosses below its low