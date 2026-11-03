Calculation: Session Supertrend = Supertrend calculated on the higher timeframe's last completed bar
Calculation: Session ATR = ATR calculated on the higher timeframe's last completed bar
Calculation: Session basis = session open or the selected prior-session price (HL2, OHLC4, or close)
Calculation: Reaction zones = bands centered at the session basis plus or minus tier offsets multiplied by Session ATR
Calculation: Laguerre PPO = 100 × (fast Laguerre filter of higher-timeframe HL2 − slow Laguerre filter of higher-timeframe HL2) / slow Laguerre filter; use the higher timeframe's last completed bar, with the fast filter shorter than the slow filter
Long: session open > Session Supertrend AND price overlaps a reaction zone below the session basis AND the zone is among the highest-ranked long setup zones AND (momentum filtering is disabled OR Laguerre PPO > 0)
Short: session open < Session Supertrend AND price overlaps a reaction zone above the session basis AND the zone is among the highest-ranked short setup zones AND (momentum filtering is disabled OR Laguerre PPO ≤ 0)
Exit: long, close < Session Supertrend
Exit: short, close > Session Supertrend