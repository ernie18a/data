Long: high >= High(high, T1, last completed bar, sampled on chart bars) + entry offset (points)
Short: low <= Low(low, T1, last completed bar, sampled on chart bars) - entry offset (points)
Calculation: Long no-loss stop = close at the first time close - no-loss distance > entry price, minus no-loss distance
Calculation: Short no-loss stop = close at the first time close + no-loss distance < entry price, plus no-loss distance
Exit: long, low <= entry price - stop-loss distance (points) OR high >= entry price + take-profit distance (points) OR low <= Long no-loss stop OR low <= Highest(high since entry) - trailing distance (points) AND Highest(high since entry) - trailing distance (points) > entry price
Exit: short, high >= entry price + stop-loss distance (points) OR low <= entry price - take-profit distance (points) OR high >= Short no-loss stop OR high >= Lowest(low since entry) + trailing distance (points) AND Lowest(low since entry) + trailing distance (points) < entry price