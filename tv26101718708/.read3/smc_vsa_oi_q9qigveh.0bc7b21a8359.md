Calculation: Target high = maximum high of Asian chart bars set at London session start or maximum high of London chart bars set at NY session start; unset at Asian session start
Calculation: Target low = minimum low of Asian chart bars set at London session start or minimum low of London chart bars set at NY session start; unset at Asian session start
Calculation: Sweep high = target high is set AND high > target high AND close < target high AND volume > SMA(volume, volume lookback) × volume multiplier
Calculation: Sweep low = target low is set AND low < target low AND close > target low AND volume > SMA(volume, volume lookback) × volume multiplier
Calculation: Active sweep-high pivot = high of the latest Sweep high bar; cleared when close > pivot or at Asian session start
Calculation: Active sweep-low pivot = low of the latest Sweep low bar; cleared when close < pivot or at Asian session start
Long: Sweep low OR (active sweep-high pivot is set AND close > active sweep-high pivot)
Short: Sweep high OR (active sweep-low pivot is set AND close < active sweep-low pivot)
Calculation: Open interest change = current open interest − previous bar's open interest
Calculation: Average absolute open interest change = SMA(abs(open interest change), P1)
Long: open interest change > 0 AND open interest change > average absolute open interest change × P2
Short: open interest change < 0 AND abs(open interest change) > average absolute open interest change × P2