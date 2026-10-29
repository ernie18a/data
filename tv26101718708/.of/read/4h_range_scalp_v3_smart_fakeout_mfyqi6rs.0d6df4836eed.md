Calculation: Session range high/low = highest high / lowest low among chart-timeframe bars in the New York 00:00–04:00 session; available after that session ends and reset at the next New York midnight
Calculation: Upside extreme = highest high while closes are above the session range high, through the last such close before re-entry
Calculation: Downside extreme = lowest low while closes are below the session range low, through the last such close before re-entry
Calculation: Upside outside count = number of closes above the session range high since the last reset or re-entry
Calculation: Downside outside count = number of closes below the session range low since the last reset or re-entry
Long: close > session range low AND downside outside count > 0 AND downside outside count <= maximum allowed outside bars AND close > EMA AND 0 < close - downside extreme < ATR × maximum allowed ATR multiple AND no prior long entry for this range day
Short: close < session range high AND upside outside count > 0 AND upside outside count <= maximum allowed outside bars AND close < EMA AND 0 < upside extreme - close < ATR × maximum allowed ATR multiple AND no prior short entry for this range day
Exit: Long, low <= downside extreme OR high >= entry price + reward/risk multiple × (entry price - downside extreme)
Exit: Short, high >= upside extreme OR low <= entry price - reward/risk multiple × (upside extreme - entry price)