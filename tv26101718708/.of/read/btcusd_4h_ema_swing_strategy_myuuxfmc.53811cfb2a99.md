Calculation: EMA buffer = ATR × a configurable multiplier in ATR mode, or EMA × a configurable percentage in percentage mode
Calculation: Upper and lower EMA bands = EMA + buffer and EMA − buffer
Calculation: Smoothed stochastic %K = simple moving average of (close − lowest low) ÷ (highest high − lowest low) × 100; %D = simple moving average of %K
Long: EMA > close and MACD histogram crosses below zero and RSI is above its lower threshold and below its upper threshold and MFI < 50
Long: Within the configured date window and position is flat or short and either close remains above the upper EMA band for the confirmation lookback, was not confirmed above it on the prior bar, and the minimum bars since the last trade have elapsed; or, when the buffer is disabled, close crosses above the EMA and the minimum bars since the last trade have elapsed
Short: EMA > close and MACD histogram crosses below zero and RSI is above its lower threshold and below its upper threshold and MFI > 50
Short: Within the configured date window and position is flat or long and either close remains below the lower EMA band for the confirmation lookback, was not confirmed below it on the prior bar, and the minimum bars since the last trade have elapsed; or, when the buffer is disabled, close crosses below the EMA and the minimum bars since the last trade have elapsed
Exit: long, close is confirmed below the lower EMA band for the confirmation lookback and was not confirmed below it on the prior bar and the minimum bars since the last trade have elapsed; or, when the buffer is disabled, close crosses below the EMA and the minimum bars since the last trade have elapsed
Exit: short, close is confirmed above the upper EMA band for the confirmation lookback and was not confirmed above it on the prior bar and the minimum bars since the last trade have elapsed; or, when the buffer is disabled, close crosses above the EMA and the minimum bars since the last trade have elapsed
Exit: short, MACD histogram crosses below zero and EMA > close and RSI is above its lower threshold and below its upper threshold and MFI > 50
Exit: long, low ≤ entry price − ATR × configurable stop multiplier
Exit: short, high ≥ entry price + ATR × configurable stop multiplier
Exit: short, low ≤ entry price − ATR × configurable first target multiple
Exit: short, low ≤ entry price − ATR × configurable second target multiple
Exit: short, (entry price − close) ÷ ATR ≥ configurable capitulation threshold and (RSI ≤ configurable oversold threshold or smoothed stochastic %K ≤ configurable oversold threshold) and smoothed stochastic %K crosses above %D
Exit: long or short, current bar time is before the configured start time or after the configured end time