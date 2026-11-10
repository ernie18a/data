Calculation: Analysis bars = chart bars, or bars aggregated to a higher timeframe using the last completed bar, or bars aggregated to a lower timeframe using the last completed lower-timeframe bar within each chart bar; use the corresponding analysis-timeframe OHLC and ATR.
Calculation: Net = analysis close − analysis open.
Calculation: Speed = EMA on chart bars of Net divided by the analysis-bar duration in seconds.
Calculation: Linearity score = 1 if absolute Net / max(analysis ATR, minimum price increment) is below the minimum progress threshold; otherwise start at 1 and successively assign 2, 3, 4 and 5 whenever adverse excursion / max(analysis ATR, minimum price increment) is at or below the corresponding progressively smaller threshold. Adverse excursion is max(0, analysis open − analysis low) when Net >= 0, otherwise max(0, analysis high − analysis open).
Calculation: Entry speed = absolute Speed, optionally multiplied by Linearity score / 5.
Calculation: Entry cooldown = chart bars since the most recent qualifying long or short entry signal, with no restriction before the first signal.
Long: Net > 0 AND Linearity score >= entry score threshold AND Entry speed >= entry speed threshold AND Entry cooldown >= cooldown threshold.
Short: Net < 0 AND Linearity score >= entry score threshold AND Entry speed >= entry speed threshold AND Entry cooldown >= cooldown threshold.
Long: Net > 0.
Short: Net < 0.
Exit: long, Linearity score < entry score threshold OR Entry speed < entry speed threshold.
Exit: short, Linearity score < entry score threshold OR Entry speed < entry speed threshold.
Exit: long, Linearity score <= exit score threshold OR absolute Speed <= exit speed threshold.
Exit: short, Linearity score <= exit score threshold OR absolute Speed <= exit speed threshold.
Exit: long, Speed <= 0.
Exit: short, Speed >= 0.
Exit: long, Speed <= upper channel threshold AND Speed >= negative lower channel threshold.
Exit: short, Speed <= upper channel threshold AND Speed >= negative lower channel threshold.
Exit: long, Net < 0 AND Linearity score >= entry score threshold AND Entry speed >= entry speed threshold AND Entry cooldown >= cooldown threshold.
Exit: short, Net > 0 AND Linearity score >= entry score threshold AND Entry speed >= entry speed threshold AND Entry cooldown >= cooldown threshold.