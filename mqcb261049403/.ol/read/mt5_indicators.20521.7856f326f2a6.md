Calculation: EMA = exponential moving average of close
Calculation: Upper level = initialize to EMA; on each later bar, if EMA > prior lower level, prior upper level + α × (EMA − prior upper level); otherwise prior upper level
Calculation: Lower level = initialize to EMA; on each later bar, if EMA < prior upper level, prior lower level + α × (EMA − prior lower level); otherwise prior lower level; α = 2 ÷ (EMA period + 1)
Long: EMA > upper level
Short: EMA < lower level