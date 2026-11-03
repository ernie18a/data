Calculation: Point of Control = center of the price bin with the greatest summed volume, using closes and volumes from a rolling lookback of bars divided into equal-width bins spanning the rolling lowest low to highest high; ties select the lowest bin
Calculation: ATR = average true range
Calculation: POC zone = Point of Control ± 0.5 × ATR
Calculation: Upper and lower ATR bands = close ± ATR × multiplier
Calculation: Average volume = average volume over a lookback
Long: close > POC zone upper boundary AND previous close ≤ previous POC zone upper boundary AND volume > average volume
Short: close < POC zone lower boundary AND previous close ≥ previous POC zone lower boundary AND volume > average volume
Exit: long, close ≤ POC zone upper boundary OR low ≤ upper ATR band
Exit: short, close ≥ POC zone lower boundary OR high ≥ lower ATR band