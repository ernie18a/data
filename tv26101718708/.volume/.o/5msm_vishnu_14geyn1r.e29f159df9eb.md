Calculation: MACD histogram = fast moving average of close minus slow moving average of close, minus a moving average of that difference; the fast lookback is shorter than the slow lookback, and the signal lookback is applied to the difference.
Calculation: Lips, Teeth, Jaw = smoothed moving averages of (high + low) / 2, with Lips shortest, Teeth intermediate, and Jaw longest; initialize each with a simple moving average, then update as (prior value × (lookback − 1) + current value) / lookback.
Calculation: Range filter = recursively retain the prior filter value unless the source moves beyond it by the smoothed range; the smoothed range is an EMA of the EMA of absolute source changes, multiplied by the configured range multiplier. Upward/downward counts increase while the filter rises/falls and reset when it moves the other way.
Calculation: Session VWAP = volume-weighted average of hlc3, reset at the configured anchor period.
Calculation: ATR trailing stop = selected price basis (highest/lowest over the configured lookback, close, or open) offset by ATR times the configured multiplier; subtract the offset for the long stop and add it for the short stop.
Long: MACD histogram > 0 AND close > Lips AND open > Lips AND within the configured session AND close > session VWAP AND upward count > 0 AND high > Teeth AND Lips > Jaw AND prior-bar close − prior-bar open < configured threshold
Short: MACD histogram < 0 AND close < Lips AND open < Lips AND within the configured session AND close < session VWAP AND downward count > 0 AND high < Teeth AND Lips < Jaw AND prior-bar open − prior-bar close < configured threshold
Long: source > range filter AND upward count > 0 AND (source > prior-bar source OR source < prior-bar source) AND prior direction state is short
Short: source < range filter AND downward count > 0 AND (source < prior-bar source OR source > prior-bar source) AND prior direction state is long
Long: close > session VWAP AND open > session VWAP AND MACD histogram > 0 AND prior-bar low < session VWAP AND close − open > configured threshold AND within the configured session
Short: close < session VWAP AND open < session VWAP AND MACD histogram < 0 AND prior-bar high > session VWAP AND open − close > configured threshold AND within the configured session
Long: close > Teeth AND close > opening-range high AND prior four closes < opening-range high AND within the configured session
Short: close < Teeth AND close < opening-range low AND prior four closes > opening-range low AND within the configured session
Long: close crosses above the ATR trailing stop calculated from close with the configured ATR lookback and multiplier
Short: close crosses below the ATR trailing stop calculated from close with the configured ATR lookback and multiplier
Exit: Long, close < Lips AND MACD histogram < negative configured threshold
Exit: Short, close > Lips AND MACD histogram > configured threshold
Exit: Long, high > entry price + configured target offset AND open < entry price + configured target offset
Exit: Long, prior-bar close < prior-bar Teeth AND prior-bar close < entry price AND prior-bar Teeth ≤ prior-bar long ATR stop
Exit: Short, low < entry price − configured target offset AND open > entry price − configured target offset
Exit: Short, prior-bar close > prior-bar Teeth AND prior-bar close > entry price AND prior-bar Teeth ≤ prior-bar long ATR stop