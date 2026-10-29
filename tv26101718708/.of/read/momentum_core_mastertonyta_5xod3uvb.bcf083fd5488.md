Calculation: Momentum = squash of the weighted average of z-scores for TSI, ATR-normalized ROC ((close − close[n]) / ATR), RSI change over a short lookback, normalized OBV change, and MACD histogram. Each z-score is (value − its trailing mean) / trailing standard deviation; squash(x) = 100 × (2 / (1 + exp(−0.9x)) − 1). The MACD histogram weight is configurable and may be zero.
Calculation: Momentum acceleration = EMA of the one-bar change in Momentum.
Calculation: Momentum direction = bullish when Momentum acceleration > the slope deadzone; bearish when Momentum acceleration < the negative slope deadzone; otherwise retain the prior direction (initially bullish).
Calculation: Regime gate = ADX ≥ its threshold AND current volume / its 20-bar average ≥ its threshold.
Long: Momentum crosses above zero AND Regime gate
Long: Momentum direction is bullish AND Regime gate
Long: At a confirmed pivot low, price makes a lower low and Momentum makes a higher low
Short: Momentum crosses below zero AND Regime gate
Short: Momentum direction is bearish AND Regime gate
Short: At a confirmed pivot high, price makes a higher high and Momentum makes a lower high
Exit: long, Momentum > its upper extreme AND Momentum acceleration < 0
Exit: short, Momentum < its lower extreme AND Momentum acceleration > 0
Exit: long, Momentum direction is bearish AND Momentum > its signal EMA
Exit: short, Momentum direction is bullish AND Momentum < its signal EMA