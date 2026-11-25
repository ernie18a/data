Calculation: range high = highest high during the range-building period
Calculation: range low = lowest low during the range-building period
Calculation: range width = range high - range low
Long: first close of the day above range high + breakout buffer
Short: first close of the day below range low - breakout buffer
Exit: long, low <= range low OR high >= entry price + target multiple * range width
Exit: short, high >= range high OR low <= entry price - target multiple * range width