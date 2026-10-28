Calculation: Previous RTH high = highest high during the previous completed regular trading session
Calculation: Opening range high = highest high during the current session’s opening-range bars, used after the opening range is complete
Calculation: Previous close = close of the last completed daily bar
Calculation: 50-day SMA, 200-day SMA = simple moving averages of daily closes, including the daily bar still forming
Calculation: Constructive MA = close is within the configured percentage below or above either daily SMA, crosses above either SMA from at or below it on the prior chart bar, or is above either SMA
Calculation: RSI MA = selected moving average of RSI; if disabled or unavailable, its rising-or-flat condition is true
Calculation: Setup score = count of these seven true conditions: close above VWAP, close above previous close, close above completed opening range high, close at least the configured percentage below or above the previous RTH high or above it, constructive MA, RSI below its limit, RSI MA rising or flat
Long: during the regular session AND (setup score >= 4 OR (close > VWAP AND close > previous close AND opening range is complete AND close > opening range high AND close >= previous RTH high times (1 - configured percentage / 100) AND (MA filter disabled OR constructive MA)))