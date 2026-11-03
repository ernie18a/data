Calculation: Up counter-close count = number of adjacent close pairs in the streak lookback where the newer close is lower than the older close
Calculation: Down counter-close count = number of adjacent close pairs in the streak lookback where the newer close is higher than the older close
Calculation: Volume ratio = current bar volume / SMA(volume, independent volume-baseline lookback)
Calculation: Support origin = first down candle found looking backward within the origin lookback whose immediately following candle has a lower low; in First Only mode test only the nearest down candle, and in Off mode omit the sweep condition
Calculation: Resistance origin = first up candle found looking backward within the origin lookback whose immediately following candle has a higher high; in First Only mode test only the nearest up candle, and in Off mode omit the sweep condition
Calculation: Zone bounds = range of the origin candle and, when sweep is enabled, its immediately following candle; if the range is shorter than the configured ATR fraction, expand it symmetrically around its midpoint
Long: confirmed bar AND support marking enabled AND Up counter-close count = 0 AND Volume ratio >= minimum ratio AND a Support origin exists AND its index differs from the last marked support origin
Short: confirmed bar AND resistance marking enabled AND Down counter-close count = 0 AND Volume ratio >= minimum ratio AND a Resistance origin exists AND its index differs from the last marked resistance origin
Exit: long, confirmed close < lower bound of an active support zone
Exit: short, confirmed close > upper bound of an active resistance zone