Calculation: transformed signal = inverse Fisher transform ( (e^(2x)−1)/(e^(2x)+1) ) of the smoothed selected factor, evaluated on the last completed bar of the selected timeframe
Calculation: selected factor = RSI(close), RSX(close), Karobein oscillator(close), MFI, or close scaled to 0–100 over its lookback; normalize as 0.1 × (factor − 50), then either apply the JMA smoother and multiply by 100, or apply the WMA smoother to the factor and multiply by 100
Long: transformed signal crosses above threshold AND year >= 2019 AND month > 7
Short: transformed signal crosses below negative threshold AND year >= 2019 AND month > 7
Exit: long, after high reaches entry price plus activation distance, low <= highest high since activation minus trailing offset
Exit: short, after low reaches entry price minus activation distance, high >= lowest low since activation plus trailing offset