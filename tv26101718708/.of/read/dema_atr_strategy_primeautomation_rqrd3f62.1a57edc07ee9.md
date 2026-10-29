Calculation: ATR-adjusted DEMA = clamp the previous bar’s ATR-adjusted DEMA to the current bar’s DEMA ± (ATR × volatility factor); initialize with DEMA. Use a longer lookback for the ATR in the profit targets than for the ATR in this band.
Long: ATR-adjusted DEMA crosses above its value 2 bars earlier AND position is flat or short
Short: ATR-adjusted DEMA crosses below its value 2 bars earlier AND position is long
Exit: long, high > entry price + 1 × ATR (target ATR evaluated at entry)
Exit: long, high > entry price + 2 × ATR (target ATR evaluated at entry)
Exit: long, high > entry price + 3 × ATR (target ATR evaluated at entry)
Exit: short, low < entry price − 1 × ATR (target ATR evaluated at entry)
Exit: short, low < entry price − 2 × ATR (target ATR evaluated at entry)
Exit: short, low < entry price − 3 × ATR (target ATR evaluated at entry)