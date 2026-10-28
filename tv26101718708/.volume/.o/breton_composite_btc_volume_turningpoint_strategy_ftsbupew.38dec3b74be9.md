Calculation: Composite volume = sum of the nine source volumes for the current timeframe bar, including while it is forming
Calculation: Average volume = moving average of composite volume on the current timeframe, including the current bar while it is forming
Calculation: Percent above average = 100 × (composite volume − average volume) / average volume
Long: (open − close) < threshold AND (close − low) < threshold AND (high − open) < threshold AND percent above average > threshold AND composite volume > average volume AND close > previous completed bar close
Exit: long, low ≤ entry price − loss distance OR high ≥ entry price + profit distance OR (high has reached entry price + trail activation distance AND low ≤ the highest high since activation − trailing distance)