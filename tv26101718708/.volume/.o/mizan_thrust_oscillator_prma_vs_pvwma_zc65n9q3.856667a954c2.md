Calculation: PSI = smoothed RSI-based momentum scaled around an equilibrium center
Calculation: P-VWMA = lookback average of close weighted by volume × PSI
Calculation: P-RMA = recursive moving average of close with a lookback that shortens as PSI deviates farther from its equilibrium center and lengthens as it approaches the center
Calculation: Thrust = P-RMA − P-VWMA
Calculation: Signal = shorter-lookback weighted moving average of Thrust
Long: Thrust crosses above zero OR (Thrust ≥ 0 AND Thrust > prior Thrust) OR (Thrust < 0 AND Thrust > prior Thrust) OR Thrust crosses above Signal
Short: Thrust crosses below zero OR (Thrust < 0 AND Thrust < prior Thrust) OR Thrust crosses below Signal
Exit: long, Thrust ≥ 0 AND Thrust < prior Thrust
Exit: short, Thrust < 0 AND Thrust > prior Thrust