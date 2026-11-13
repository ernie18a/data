Calculation: PriorHigh = highest high over the previous lookback bars, excluding the current bar
Calculation: PriorLow = lowest low over the previous lookback bars, excluding the current bar
Calculation: BreakUp = close crosses above PriorHigh (close > PriorHigh AND previous close <= previous PriorHigh); alternative setting: high > PriorHigh
Calculation: BreakDown = close crosses below PriorLow (close < PriorLow AND previous close >= previous PriorLow); alternative setting: low < PriorLow
Calculation: PrevHTFHigh / PrevHTFLow = high / low of the last completed bar of a higher timeframe than the chart (the previous day)
Calculation: ATR = average true range, same lookback as PriorHigh
Long: [exactly one variant is active per run; variants are mutually exclusive] Variant PrevDay: close crosses above PrevHTFHigh (close > PrevHTFHigh AND previous close <= PrevHTFHigh)
Long: Variant Bollinger: close crosses above upper Bollinger Band (SMA of close plus a multiplier times the standard deviation of close, same lookback as PriorHigh)
Long: Variant Volume: BreakUp AND volume > SMA of volume (same lookback as PriorHigh)
Long: Variant ATR: BreakUp AND (high - previous close) > ATR
Long: Variant Time: BreakUp AND current bar time falls inside a fixed intraday session window
Long: Variant EMA: BreakUp AND fast EMA of close > slow EMA of close (fast has the shorter length)
Long: Variant RSI: BreakUp AND RSI of close (same lookback as PriorHigh) > a long threshold above the 50 midline
Long: Variant Candle: BreakUp AND close > open AND close > previous close
Short: Variant PrevDay: close crosses below PrevHTFLow (close < PrevHTFLow AND previous close >= PrevHTFLow)
Short: Variant Bollinger: close crosses below lower Bollinger Band (SMA of close minus a multiplier times the standard deviation of close, same lookback as PriorHigh)
Short: Variant Volume: BreakDown AND volume > SMA of volume (same lookback as PriorHigh)
Short: Variant ATR: BreakDown AND (previous close - low) > ATR
Short: Variant Time: BreakDown AND current bar time falls inside a fixed intraday session window
Short: Variant EMA: BreakDown AND fast EMA of close < slow EMA of close (fast has the shorter length)
Short: Variant RSI: BreakDown AND RSI of close (same lookback as PriorHigh) < a short threshold below the 50 midline, symmetric to the long threshold
Short: Variant Candle: BreakDown AND close < open AND close < previous close
Exit: long, the active variant's Short condition is true (close the long and reverse to short)
Exit: short, the active variant's Long condition is true (close the short and reverse to long)