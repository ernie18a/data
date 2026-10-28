Calculation: Heikin-Ashi close = (open + high + low + close) / 4
Calculation: Heikin-Ashi open = first bar’s (open + close) / 2; thereafter, average the previous Heikin-Ashi open and close
Calculation: Heikin-Ashi body = absolute difference between Heikin-Ashi close and open
Calculation: Average Heikin-Ashi body = simple moving average of Heikin-Ashi body over a longer lookback
Calculation: Session VWAP = volume-weighted average of (high + low + close) / 3, resetting each session
Long: close > Session VWAP AND low > Session VWAP AND Heikin-Ashi close > Heikin-Ashi open AND Heikin-Ashi body > Average Heikin-Ashi body multiplied by a threshold AND (initially eligible OR, since the previous long signal, Heikin-Ashi close < Heikin-Ashi open OR Heikin-Ashi body < Average Heikin-Ashi body within a shorter lookback)
Short: close < Session VWAP AND high < Session VWAP AND Heikin-Ashi close < Heikin-Ashi open AND Heikin-Ashi body > Average Heikin-Ashi body multiplied by a threshold AND (initially eligible OR, since the previous short signal, Heikin-Ashi close > Heikin-Ashi open OR Heikin-Ashi body < Average Heikin-Ashi body within a shorter lookback)