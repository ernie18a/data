Calculation: Volume-weighted Fisher = 100 × the selected moving average of volume × Fisher transform of the selected bar price, using the selected moving-average method and length
Calculation: Fisher transform = 0.5 × ln((1 + value) / (1 − value)) + 0.5 × previous Fisher transform, where value = (normalized price − 0.5) + 0.67 × previous value, normalized price = (selected bar price − lowest low) / (highest high − lowest low) over the lookback; highest high and lowest low use the same lookback
Calculation: Upper threshold = overbought level × the selected moving average of volume
Calculation: Lower threshold = oversold level × the selected moving average of volume; the overbought level is positive and the oversold level is negative
Long: Volume-weighted Fisher > Upper threshold AND Volume-weighted Fisher >= its previous bar value
Short: Volume-weighted Fisher < Lower threshold AND Volume-weighted Fisher <= its previous bar value