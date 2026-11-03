Calculation: RSI-adaptive T3 = Tillson T3 of close, using six sequential EMAs with length round(minimum length + (maximum length − minimum length) × (1 − RSI(close) / 100)); use the standard T3 coefficients for the volume factor
Calculation: Long stop = lowest low over the stop lookback on the long-entry bar, held fixed until the position closes
Calculation: Short stop = highest high over the stop lookback on the short-entry bar, held fixed until the position closes
Long: RSI-adaptive T3 crosses above its value two bars earlier AND close > Parabolic SAR AND position side is flat or short
Short: RSI-adaptive T3 crosses below its value two bars earlier AND close <= Parabolic SAR AND position side is flat or long
Exit: Long, low <= long stop
Exit: Short, high >= short stop
Exit: Short, RSI-adaptive T3 crosses above its value two bars earlier AND close > Parabolic SAR
Exit: Long, RSI-adaptive T3 crosses below its value two bars earlier AND close <= Parabolic SAR