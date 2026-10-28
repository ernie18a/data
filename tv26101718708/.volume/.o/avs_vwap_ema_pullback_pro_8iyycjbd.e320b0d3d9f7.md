Calculation: fast EMA = exponential moving average of close with a shorter lookback than the slow EMA
Calculation: long stop = min(VWAP, slow EMA) minus ATR times a parameter
Calculation: short stop = max(VWAP, slow EMA) plus ATR times a parameter
Calculation: long risk = entry price minus long stop
Calculation: short risk = short stop minus entry price
Calculation: long target 1 and target 2 = entry price plus long risk times separate reward-to-risk parameters
Calculation: short target 1 and target 2 = entry price minus short risk times separate reward-to-risk parameters
Long: current bar is within the configured trading session AND ADX is at least the configured minimum AND close is above VWAP AND fast EMA is above slow EMA AND positive DI is above negative DI AND low is at or below VWAP times (1 plus the configured pullback percentage) AND close is above VWAP AND close is above fast EMA AND RSI is above the configured long threshold AND no short signal is present
Short: current bar is within the configured trading session AND ADX is at least the configured minimum AND close is below VWAP AND fast EMA is below slow EMA AND negative DI is above positive DI AND high is at or above VWAP times (1 minus the configured pullback percentage) AND close is below VWAP AND close is below fast EMA AND RSI is below the configured short threshold AND no long signal is present
Exit: long, low is at or below the long stop OR high is at or above long target 1 OR high is at or above long target 2
Exit: short, high is at or above the short stop OR low is at or below short target 1 OR low is at or below short target 2