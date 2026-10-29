Calculation: Money-flow RSI = RSI of the rolling positive-flow sum and rolling negative-flow sum; each sum uses volume × hlc3 over the same lookback, including hlc3 only when its change is respectively positive or negative
Calculation: Smoothed money-flow RSI = EMA of money-flow RSI over a shorter smoothing period
Calculation: Long trailing stop = after high reaches entry price × (1 + take-profit fraction), highest high since activation minus entry price × (1 − 1/(1 + trail-offset fraction))
Calculation: Short trailing stop = after low reaches entry price ÷ (1 + take-profit fraction), lowest low since activation plus entry price × trail-offset fraction
Long: Smoothed money-flow RSI crosses below the oversold threshold AND datetime is within the configured backtest window
Short: Smoothed money-flow RSI crosses above the overbought threshold AND datetime is within the configured backtest window
Exit: long, low ≤ entry price ÷ (1 + stop-loss fraction) OR low ≤ long trailing stop OR (previous-bar money-flow RSI > long exit threshold AND current money-flow RSI > long exit threshold)
Exit: short, high ≥ entry price × (1 + stop-loss fraction) OR high ≥ short trailing stop OR (previous-bar money-flow RSI < short exit threshold AND current money-flow RSI < short exit threshold)