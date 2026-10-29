Calculation: 15-MA ribbon = 15 moving averages of the same selected type on chart-timeframe bars, ordered from shortest to longest lookback
Calculation: Consensus score = 100 × (count of ribbon MAs below close + count of ribbon MAs above their prior-bar values) / 30
Calculation: Ribbon width = (highest ribbon MA − lowest ribbon MA) / ATR
Calculation: Efficiency ratio = abs(close − close from the lookback bars ago) / sum of absolute close-to-close changes over that lookback
Long: consensus score > bullish threshold AND prior consensus score ≤ bullish threshold AND ribbon width ≥ minimum width AND efficiency ratio ≥ minimum efficiency
Short: consensus score < bearish threshold AND prior consensus score ≥ bearish threshold AND ribbon width ≥ minimum width AND efficiency ratio ≥ minimum efficiency