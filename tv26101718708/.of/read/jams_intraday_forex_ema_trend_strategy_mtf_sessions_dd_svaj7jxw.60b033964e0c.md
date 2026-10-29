Calculation: Fast EMA = EMA with a shorter lookback than the slow EMA
Calculation: Higher-timeframe trend = direction of the most recent crossover of the fast and slow EMAs, retaining that direction until the next crossover
Calculation: Stop distance = higher-timeframe ATR multiplied by a configurable factor
Calculation: Target distance = twice the stop distance
Long: Fast EMA crosses above slow EMA on the chart timeframe AND higher-timeframe trend is upward AND the last completed higher-timeframe close is above its VWAP AND datetime is within either configured trading session
Short: Fast EMA crosses below slow EMA on the chart timeframe AND higher-timeframe trend is downward AND the last completed higher-timeframe close is below its VWAP AND datetime is within either configured trading session
Exit: Long, low is at or below the entry-signal bar close minus the stop distance OR high is at or above the entry-signal bar close plus the target distance
Exit: Short, high is at or above the entry-signal bar close plus the stop distance OR low is at or below the entry-signal bar close minus the target distance