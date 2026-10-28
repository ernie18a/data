Calculation: ATR = average true range using the current bar and prior bars
Calculation: Relative volume = current volume / simple moving average of volume, including the current bar
Calculation: Lower wick = min(open, close) - low; upper wick = high - max(open, close); candle range = max(high - low, minimum price increment)
Calculation: Context high/low = highest high/lowest low across the prior wick-context lookback bars, excluding the current bar
Calculation: Bullish pocket reclaim rail = pocket candle's body top + ATR × reclaim buffer; failure rail = pocket low - ATR × failure buffer
Calculation: Bearish pocket reclaim rail = pocket candle's body bottom - ATR × reclaim buffer; failure rail = pocket high + ATR × failure buffer
Long: Lower wick / ATR ≥ minimum wick size AND lower wick / candle range ≥ minimum wick-to-range ratio AND low ≤ context low AND close > body bottom AND relative volume ≥ minimum relative volume OR an active bullish pocket exists, the current bar is later than its pocket bar, close > its reclaim rail, and the prior bar did not satisfy either reclaim condition
Short: Upper wick / ATR ≥ minimum wick size AND upper wick / candle range ≥ minimum wick-to-range ratio AND high ≥ context high AND close < body top AND relative volume ≥ minimum relative volume OR an active bearish pocket exists, the current bar is later than its pocket bar, close < its reclaim rail, and the prior bar did not satisfy either reclaim condition
Exit: long, an active bullish pocket exists and close < its failure rail
Exit: short, an active bearish pocket exists and close > its failure rail