Calculation: Bulls Power = bar high minus the exponential moving average of close over the power lookback
Calculation: Bears Power = bar low minus the exponential moving average of close over the power lookback
Long: count of bars with Bulls Power > 0 in the lookback > half the lookback AND that count > count of bars with Bears Power < 0 in the lookback
Short: count of bars with Bears Power < 0 in the lookback > half the lookback AND that count > count of bars with Bulls Power > 0 in the lookback