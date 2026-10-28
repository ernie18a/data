Calculation: Composite trend score = clamp to [-1,1] the weighted mean of four components: clamp((shorter-lookback EMA − longer-lookback EMA)/ATR, −1, 1); clamp((RSI − its midpoint)/its scaling factor, −1, 1); clamp((close − VWAP)/ATR, −1, 1) on intraday bars and 0 otherwise; and +1 when Supertrend is bullish, −1 when bearish. Calculate on chart bars and on weekly and monthly bars; use the last completed weekly and monthly bars.
Calculation: Overall score = mean of the chart, weekly, and monthly composite trend scores.
Calculation: Expected move = close × annualized standard deviation of daily log returns × square root of days to expiry / 365; annualized volatility uses the daily-return lookback and √252.
Calculation: Put strike = close − safety distance × expected move; call strike = close + safety distance × expected move.
Calculation: Put exit level = put strike + exit buffer × expected move; call exit level = call strike − exit buffer × expected move.
Calculation: Prior swing low = lowest low over the swing lookback, excluding the current bar; prior swing high = highest high over the swing lookback, excluding the current bar.
Long: Overall score ≥ −range band.
Short: Overall score ≤ range band.
Exit: Long, (overall score ≥ range band AND close ≤ put exit level) OR (overall score > range band AND close < prior swing low).
Exit: Short, (overall score ≤ range band AND close ≥ call exit level) OR (overall score < −range band AND close > prior swing high).