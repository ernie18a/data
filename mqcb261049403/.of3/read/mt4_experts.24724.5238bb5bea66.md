Calculation: Retracement threshold = retracement-count parameter × point size
Calculation: Weighted-average pair = LWMA(typical price, shorter lookback) and LWMA(typical price, longer lookback), both on the current forming chart bar
Calculation: RSI pair = RSI(close, lookback, T2, forming bar) and RSI(close, same lookback, T2, last completed bar), sampled on chart bars
Calculation: Short EMA group = six EMAs of typical price with six separate successively longer lookbacks on the forming T1 bar, sampled on chart bars
Calculation: Long EMA group = six EMAs of typical price with six separate successively longer lookbacks on the forming T1 bar, sampled on chart bars
Calculation: Lower band = lower Bollinger Band(close, lookback, deviation parameter) on the last completed chart bar
Long: absolute distance between current bid and close[long-entry distance lag] > retracement threshold AND shorter-lookback LWMA > longer-lookback LWMA AND forming-bar RSI > last-completed-bar RSI
Short: absolute distance between current ask and close[short-entry distance lag] > retracement threshold AND shorter-lookback LWMA < longer-lookback LWMA AND low[short-entry low lag] < high[short-entry high lag] AND forming-bar RSI < last-completed-bar RSI
Exit: long, all six values in the short EMA group are equal OR all six values in the long EMA group are equal OR last completed chart close <= lower band
Exit: short, all six values in the short EMA group are equal OR all six values in the long EMA group are equal OR last completed chart close <= lower band