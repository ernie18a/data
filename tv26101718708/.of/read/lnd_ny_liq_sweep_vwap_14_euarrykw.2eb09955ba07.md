Calculation: Session range = highest high and lowest low accumulated during each configured range session in the New York time zone; retain each range until its next range session.
Calculation: Consecutive close changes = on each chart bar compare the selected lower-timeframe close with its value on the previous chart bar; count consecutive increases and decreases separately, resetting both on equality and at the start of each New York day. Use the last completed lower-timeframe bar historically and the latest available bar while the chart bar is forming.
Calculation: Swept low/high = during a session's trade window, the chart-bar low/high crosses strictly below/above that session's range low/high while the corresponding consecutive decrease/increase count is at least its threshold; retain each sweep state through the New York day, including the sweep bar.
Calculation: Offset level = round((close − offset) / price step) × price step + offset; use separate lower and higher offsets for the long and short conditions.
Calculation: Consolidation = during the configured first-hour session, the running session high minus low is less than a multiplier times chart-timeframe ATR; retain the final state during the configured later session and set it false outside those sessions.
Long: During either session's trade window, its low has been swept AND low <= lower-offset level AND close > lower-offset level AND (displacement filter disabled OR high − low > the highest high − low of the preceding lookback bars) AND (fair-value-gap filter disabled OR low > high two chart bars earlier AND close > high two chart bars earlier).
Short: During either session's trade window, its high has been swept AND high >= higher-offset level AND close < higher-offset level AND (displacement filter disabled OR high − low > the highest high − low of the preceding lookback bars) AND (fair-value-gap filter disabled OR high < low two chart bars earlier AND close < low two chart bars earlier).
Long: During either session's trade window, low < that session's range low AND consecutive decreases >= threshold AND close < open.
Short: During either session's trade window, high > that session's range high AND consecutive increases >= threshold AND close > open.
Long: Higher-timeframe close > its shorter-period EMA.
Short: Higher-timeframe close <= its shorter-period EMA.
Long: Higher-timeframe close > its longer-period EMA.
Short: Higher-timeframe close <= its longer-period EMA.
Long: Higher-timeframe close > the EMA of a still higher timeframe.
Short: Higher-timeframe close <= the EMA of a still higher timeframe.
Long: Higher-timeframe close > its shorter-period EMA AND (higher-timeframe alignment filter disabled OR higher-timeframe close > the EMA of a still higher timeframe) AND chart close < the open of the first chart bar of the New York day AND consolidation is false.
Short: Higher-timeframe close <= its shorter-period EMA AND (higher-timeframe alignment filter disabled OR higher-timeframe close <= the EMA of a still higher timeframe) AND chart close > the open of the first chart bar of the New York day AND consolidation is false.
Calculation: Higher-timeframe close and EMAs use the last completed higher-timeframe bar on historical chart bars and the still-forming higher-timeframe bar in real time.