Calculation: Net liquidity = central bank balance sheet − treasury general account − reverse repo balance
Calculation: Fair value = net liquidity / 1,000,000,000 / 1.1 − 1,625
Calculation: Spread = higher-timeframe close (bar still forming) − fair value
Long: net liquidity > 0 AND previous spread > −150 AND current spread < −150 AND bar time is on or after the configured start date
Short: net liquidity > 0 AND previous spread < 350 AND current spread > 350 AND bar time is on or after the configured start date
Exit: long, (net liquidity > 0 AND previous spread < 350 AND current spread > 350 AND bar time is on or after the configured start date) OR bar date equals the configured close date
Exit: short, (net liquidity > 0 AND previous spread > −150 AND current spread < −150 AND bar time is on or after the configured start date) OR bar date equals the configured close date