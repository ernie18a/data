Calculation: Price z-score = (close − lookback mean of close) / lookback standard deviation of close
Calculation: Bollinger squeeze = current Bollinger-band width is less than its lookback average width divided by a multiplier
Calculation: VWAP deviation bands = VWAP ± a multiplier × lookback standard deviation of (close − VWAP)
Long: RSI is below its entry threshold AND (close > long-term SMA OR trend filter is disabled)
Short: RSI is above the complementary threshold AND (close < long-term SMA OR trend filter is disabled)
Exit: long, RSI is above its exit threshold
Exit: short, RSI is below the complementary exit threshold
Long: price z-score is below the negative entry threshold AND (close > long-term SMA OR trend filter is disabled)
Short: price z-score is above the entry threshold AND (close < long-term SMA OR trend filter is disabled)
Exit: long, price z-score is above the negative exit threshold
Exit: short, price z-score is below the exit threshold
Long: fast EMA crosses above slow EMA AND RSI is below its overbought threshold AND (close > long-term SMA OR trend filter is disabled)
Short: fast EMA crosses below slow EMA AND RSI is above its oversold threshold AND (close < long-term SMA OR trend filter is disabled)
Exit: long, fast EMA crosses below slow EMA OR RSI is above its exit threshold
Exit: short, fast EMA crosses above slow EMA OR RSI is below its exit threshold
Long: close is below the lower Bollinger band AND the previous bar was a squeeze AND (close > long-term SMA OR trend filter is disabled)
Short: close is above the upper Bollinger band AND the previous bar was a squeeze AND (close < long-term SMA OR trend filter is disabled)
Exit: long, close is above the Bollinger basis
Exit: short, close is below the Bollinger basis
Long: MACD line crosses above its signal line AND RSI is below 50 AND MACD histogram is rising AND (close > long-term SMA OR trend filter is disabled)
Short: MACD line crosses below its signal line AND RSI is above 50 AND MACD histogram is falling AND (close < long-term SMA OR trend filter is disabled)
Exit: long, MACD line crosses below its signal line OR RSI is above its exit threshold
Exit: short, MACD line crosses above its signal line OR RSI is below its exit threshold
Long: fast EMA is above middle EMA AND middle EMA is above slow EMA AND fast EMA was at or below middle EMA on the previous bar AND (close > long-term SMA OR trend filter is disabled)
Short: fast EMA is below middle EMA AND middle EMA is below slow EMA AND fast EMA was at or above middle EMA on the previous bar AND (close < long-term SMA OR trend filter is disabled)
Exit: long, fast EMA is below middle EMA
Exit: short, fast EMA is above middle EMA
Long: close is below the lower VWAP deviation band AND (close > long-term SMA OR trend filter is disabled)
Short: close is above the upper VWAP deviation band AND (close < long-term SMA OR trend filter is disabled)
Exit: long, close is above VWAP
Exit: short, close is below VWAP
Long: count of long signals from the seven individual strategies is at least the configured consensus threshold
Short: count of short signals from the seven individual strategies is at least the configured consensus threshold
Exit: long, count of long signals from the seven individual strategies is zero
Exit: short, count of short signals from the seven individual strategies is zero
Exit: long, price reaches the configured take-profit or stop-loss level from entry price, or the configured trailing-stop level, or bars held reaches the configured time limit
Exit: short, price reaches the configured take-profit or stop-loss level from entry price, or the configured trailing-stop level, or bars held reaches the configured time limit