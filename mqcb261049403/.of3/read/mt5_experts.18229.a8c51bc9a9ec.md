Calculation: reference T1 close percentage change = 100 * close of last completed T1 bar / close of preceding completed T1 bar - 100, evaluated on chart bars
Calculation: strategy open profit points = sum over open strategy positions of trunc_toward_zero((close - entry price) / instrument point size) for long positions and trunc_toward_zero((entry price - close) / instrument point size) for short positions
Long: trading enabled AND new broker day AND hour(datetime) > entry-hour parameter AND reference T1 close percentage change > 0
Short: trading enabled AND new broker day AND hour(datetime) > entry-hour parameter AND reference T1 close percentage change < 0
Exit: long, hour(datetime) >= exit-hour parameter
Exit: short, hour(datetime) >= exit-hour parameter
Exit: long, profit monitoring enabled AND strategy open profit points >= profit threshold
Exit: short, profit monitoring enabled AND strategy open profit points >= profit threshold
Exit: long, loss monitoring enabled AND strategy open profit points <= -loss threshold
Exit: short, loss monitoring enabled AND strategy open profit points <= -loss threshold