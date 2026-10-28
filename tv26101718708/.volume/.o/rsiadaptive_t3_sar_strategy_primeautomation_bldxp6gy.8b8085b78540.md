Calculation: RSI-adaptive T3 = Tillson T3 of close, using six sequential recursive EMAs with the same length; length is rounded from a minimum to a maximum as RSI falls from 100 to 0.
Calculation: Long stop = lowest low over the lookback ending on the long-entry bar; hold fixed for the trade.
Calculation: Short stop = highest high over the lookback ending on the short-entry bar; hold fixed for the trade.
Long: T3 crosses above its value two bars earlier AND close > Parabolic SAR AND position is flat or short AND datetime is on or after the configured start date
Short: T3 crosses below its value two bars earlier AND close <= Parabolic SAR AND position is flat or long AND datetime is on or after the configured start date
Exit: Long, T3 crosses below its value two bars earlier AND close <= Parabolic SAR OR low <= long stop
Exit: Short, T3 crosses above its value two bars earlier AND close > Parabolic SAR OR high >= short stop