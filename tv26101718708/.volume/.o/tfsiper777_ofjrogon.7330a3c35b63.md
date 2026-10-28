Calculation: ATR filter = ATR >= simple moving average of ATR over the ATR lookback × volatility multiplier
Calculation: Long stop = entry price − ATR at entry × stop-loss multiple
Calculation: Long first target = entry price + ATR at entry × target multiple
Calculation: Long second target = entry price + 2 × ATR at entry × target multiple
Calculation: Short stop = entry price + ATR at entry × stop-loss multiple
Calculation: Short first target = entry price − ATR at entry × target multiple
Calculation: Short second target = entry price − 2 × ATR at entry × target multiple
Long: (RSI crosses above oversold level AND close > fast EMA OR RSI < lower momentum threshold AND close crosses above fast EMA OR fast EMA crosses above slow EMA AND RSI < upper momentum threshold) AND ATR filter AND fast EMA >= slow EMA
Short: (RSI crosses below overbought level AND close < fast EMA OR RSI > upper momentum threshold AND close crosses below fast EMA OR fast EMA crosses below slow EMA AND RSI > lower momentum threshold) AND ATR filter AND fast EMA < slow EMA
Exit: Long, low <= long stop OR high >= long first target OR high >= long second target
Exit: Short, high >= short stop OR low <= short first target OR low <= short second target