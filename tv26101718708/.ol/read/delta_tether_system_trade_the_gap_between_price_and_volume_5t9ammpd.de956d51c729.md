Calculation: Delta Line = intercept of a linear regression of close over a lookback, optionally smoothed with a moving average
Calculation: Tether = (close - Delta Line) / ATR
Calculation: Tether Rank = percentile rank of absolute Tether over a lookback
Calculation: Volume Average = moving average of volume over a lookback
Long: (Mean Reversion mode AND Tether < 0 AND Tether Rank >= threshold AND Tether Rank < previous bar's rank) OR (Trend Following mode AND Tether crosses above 0 AND Tether Rank < threshold) OR (Tether Rank >= extreme threshold for at least two consecutive bars AND Tether < 0)
Long: flat position AND (Mean Reversion mode AND close < EMA) OR (Trend Following mode AND close > EMA) AND volume > Volume Average × threshold AND long cooldown ready
Short: (Mean Reversion mode AND Tether > 0 AND Tether Rank >= threshold AND Tether Rank < previous bar's rank) OR (Trend Following mode AND Tether crosses below 0 AND Tether Rank < threshold) OR (Tether Rank >= extreme threshold for at least two consecutive bars AND Tether > 0)
Short: flat position AND (Mean Reversion mode AND close > EMA) OR (Trend Following mode AND close < EMA) AND volume > Volume Average × threshold AND short cooldown ready
Exit: long, Tether crosses above 0 in Mean Reversion mode OR Tether crosses below 0 in Trend Following mode OR low <= stop OR high >= target
Exit: short, Tether crosses below 0 in Mean Reversion mode OR Tether crosses above 0 in Trend Following mode OR high >= stop OR low <= target