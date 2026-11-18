Calculation: Volatility spread = T1 volatility index close - annualized historical volatility of chart close over P1 bars
Calculation: Dynamic threshold = standard deviation of volatility spread over P1 bars * P2
Long: Volatility spread > Dynamic threshold
Short: Volatility spread < -Dynamic threshold
Exit: Long, volatility spread crosses above zero
Exit: Short, volatility spread crosses below zero