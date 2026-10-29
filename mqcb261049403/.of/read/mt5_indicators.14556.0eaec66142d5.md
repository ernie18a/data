Calculation: Fast–slow average difference = XMA of the selected applied price with the shorter lookback minus XMA of the selected applied price with the longer lookback
Calculation: Signal line = XMA of the fast–slow average difference
Calculation: Awesome signal state = fast–slow average difference minus signal line when nonzero; otherwise the previous state
Long: current Awesome signal state > 0 AND previous Awesome signal state <= 0 (using the still-forming bar on the higher timeframe)
Short: current Awesome signal state < 0 AND previous Awesome signal state >= 0 (using the still-forming bar on the higher timeframe)