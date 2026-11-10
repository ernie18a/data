Calculation: Core score = sum of four votes: MACD line and signal line both above zero: +1, both below zero: -1, otherwise 0; SMA of close above SMA of open over the same lookback: +1, below: -1, otherwise 0; close above its value at a momentum lookback: +1, below: -1, otherwise 0; close above its long-term SMA: +1, otherwise -1.
Calculation: Extended score = core score plus the OBV vote: +1 if OBV is above its SMA, -1 if below, otherwise 0. Relative strength is excluded because benchmark prices are not available in the specified data.
Calculation: Realized volatility = standard deviation of consecutive log close returns over a volatility lookback, multiplied by an annualization factor and optionally smoothed with an EMA.
Calculation: Extension = (close - long-term SMA of close) / standard deviation of close over the same lookback.
Long: core score > 0.
Short: core score < 0.
Long: position is flat AND extended score >= positive entry threshold for every bar in a confirmation lookback AND realized volatility <= volatility cap AND extension <= upper extension threshold.
Exit: long, extended score <= negative exit threshold for every bar in the same confirmation lookback AND realized volatility <= volatility cap AND extension >= lower extension threshold.