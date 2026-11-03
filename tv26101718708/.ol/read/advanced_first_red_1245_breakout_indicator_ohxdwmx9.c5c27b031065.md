Calculation: First bearish session range = high and low of the first bearish bar in the session, excluding the opening bar; use completed bars on the chart timeframe and reset daily
Calculation: 12:45 range = highest high and lowest low from 12:45 through the bar ending at 13:15; use completed bars on the chart timeframe and reset daily
Calculation: First bearish breakout levels = first bearish session range high plus buffer, and low minus buffer
Calculation: 12:45 breakout levels = 12:45 range high plus buffer, and low minus buffer
Calculation: 0.50 range level = range low + 0.50 × (range high − range low)
Calculation: 0.618 range level = range low + 0.618 × (range high − range low)
Calculation: Bullish EMA alignment = the shorter-period EMAs are both above the longer-period EMA
Calculation: Bearish EMA alignment = the longer-period EMA is above both shorter-period EMAs
Long: (close crosses above first bearish breakout high OR close crosses above 12:45 breakout high) AND bullish EMA alignment AND at least the configured cooldown bars since the previous main long signal
Long: close crosses above the 0.50 or 0.618 level of either range AND that range-level long signal has not already occurred for that range today
Long: previous bar closes below its open AND current close is above the previous bar high AND current close is above the highest high over the configured lookback ending on the previous bar AND bullish EMA alignment AND within the configured session
Short: (close crosses below first bearish breakout low OR close crosses below 12:45 breakout low) AND bearish EMA alignment AND at least the configured cooldown bars since the previous main short signal
Short: close crosses below the 0.50 or 0.618 level of either range
Short: previous bar closes above its open AND current close is below the previous bar low AND current close is below the lowest low over the configured lookback ending on the previous bar AND bearish EMA alignment AND within the configured session
Exit: long, close is below the low of the bar that generated the active first bearish-range or 12:45-range long signal
Exit: short, close is above the high of the bar that generated the active first bearish-range or 12:45-range main short signal