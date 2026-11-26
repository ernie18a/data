Calculation: Current-day high = maximum high from the first chart bar of the current trading day through the current chart bar
Calculation: Current-day low = minimum low from the first chart bar of the current trading day through the current chart bar
Calculation: Current-day range midpoint = (current-day high + current-day low) / 2
Calculation: Current-day body midpoint = (max(first chart bar's open of the current trading day, current close) + min(first chart bar's open of the current trading day, current close)) / 2
Long: current-day levels are initialized AND no entry has occurred today AND close > current-day range midpoint AND close > current-day body midpoint AND prior chart-bar close <= current-day range midpoint
Short: current-day levels are initialized AND no entry has occurred today AND close < current-day range midpoint AND close < current-day body midpoint AND prior chart-bar close >= current-day range midpoint
Exit: Long, low <= current-day low on the entry signal bar OR high >= entry-signal close + (entry-signal close - current-day low on the entry signal bar) × risk/reward parameter
Exit: Short, high >= current-day high on the entry signal bar OR low <= entry-signal close - (current-day high on the entry signal bar - entry-signal close) × risk/reward parameter