Calculation: Momentum = sigmoid of the weighted average of trailing z-scores of TSI, ATR-normalized ROC, RSI change, normalized OBV change, and MACD histogram; TSI uses shorter and longer smoothing lengths, and wave weight may be zero
Calculation: Acceleration = EMA of one-bar change in Momentum
Calculation: Regime gate = ADX above threshold AND current volume / 20-bar average volume above threshold
Calculation: Bullish divergence = confirmed momentum pivot low higher than the prior confirmed pivot low AND price low at that pivot lower than at the prior pivot low
Calculation: Bearish divergence = confirmed momentum pivot high lower than the prior confirmed pivot high AND price high at that pivot higher than at the prior pivot high
Long: Momentum crosses above zero AND Regime gate
Long: Bullish divergence
Long: Momentum wave crosses above zero
Long: Acceleration > deadzone OR (Acceleration is between -deadzone and deadzone AND prior direction is bullish)
Short: Momentum crosses below zero AND Regime gate
Short: Bearish divergence
Short: Momentum wave crosses below zero
Short: Acceleration < -deadzone OR (Acceleration is between -deadzone and deadzone AND prior direction is bearish)
Exit: long, Momentum > upper exhaustion threshold AND Acceleration < 0
Exit: short, Momentum < lower exhaustion threshold AND Acceleration > 0
Exit: long, Momentum > Signal AND Acceleration < -deadzone
Exit: short, Momentum < Signal AND Acceleration > deadzone
