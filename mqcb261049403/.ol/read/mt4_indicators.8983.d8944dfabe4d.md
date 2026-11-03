Calculation: Average Spread = sum of (high − low) for the signal bar and the preceding SpreadPeriod − 1 completed bars, divided by SpreadPeriod − 1
Calculation: Average Volume = sum of volume for the signal bar and the preceding VolumePeriod − 1 completed bars, divided by VolumePeriod − 1
Calculation: Wide Spread = signal bar range ≥ 1.8 × Average Spread
Calculation: Narrow Spread = signal bar range ≤ 0.8 × Average Spread
Calculation: High Volume = signal bar volume ≥ Average Volume
Calculation: Low Volume = signal bar volume < Average Volume
Calculation: Up Close = signal bar close ≥ signal bar low + 0.7 × (high − low)
Calculation: Down Close = signal bar close ≤ signal bar low + 0.3 × (high − low)
Calculation: Mid Close = signal bar close is above signal bar low + 0.3 × (high − low) and below signal bar low + 0.7 × (high − low)
Calculation: Up Bar = signal bar close > preceding bar close
Calculation: Down Bar = signal bar close < preceding bar close
Long: (High Volume AND Up Close AND Down Bar) OR (Narrow Spread AND Low Volume AND Down Close AND Down Bar) OR (Wide Spread AND Up Close AND Up Bar AND (High Volume OR signal bar volume > preceding bar volume))
Short: (Wide Spread AND High Volume AND Down Close AND preceding bar close > close of the bar before it AND signal bar high > preceding bar high) OR (Narrow Spread AND (Low Volume OR signal bar volume < preceding bar volume) AND (Down Close OR Mid Close) AND Up Bar) OR (Wide Spread AND Down Bar AND Down Close AND (High Volume OR signal bar volume > preceding bar volume))