Calculation: RSI = relative strength index of close
Calculation: Confirmed RSI trough = an RSI value lower than the preceding left-lookback bars and following right-lookback bars; known after the right-lookback bars close
Calculation: Confirmed RSI peak = an RSI value higher than the preceding left-lookback bars and following right-lookback bars; known after the right-lookback bars close
Calculation: Trough price = lowest low in the window of 2 × right-lookback + 1 bars centered on the RSI trough
Calculation: Peak price = highest high in the window of 2 × right-lookback + 1 bars centered on the RSI peak
Calculation: Trough anchor = the prior confirmed RSI trough with the lowest RSI among the most recent 40 stored troughs whose gaps from the current trough are within the configured minimum and maximum
Calculation: Peak anchor = the prior confirmed RSI peak with the highest RSI among the most recent 40 stored peaks whose gaps from the current peak are within the configured minimum and maximum
Long: a confirmed RSI trough has a trough price lower than its trough anchor's price AND its RSI is at least the configured minimum RSI difference above the anchor's RSI AND (oversold filter disabled OR anchor RSI is at or below the oversold threshold AND current RSI is below 50)
Short: a confirmed RSI peak has a peak price higher than its peak anchor's price AND its RSI is at least the configured minimum RSI difference below the anchor's RSI AND (overbought filter disabled OR anchor RSI is at or above the overbought threshold AND current RSI is above 50)