Calculation: Go histogram = simple moving average of (close − open) over a lookback, calculated on the configured indicator timeframe using completed bars
Long: Go histogram on the latest completed bar > 0 AND Go histogram on the preceding completed bar < 0
Short: Go histogram on the latest completed bar < 0 AND Go histogram on the preceding completed bar > 0
Exit: long, Go histogram on the latest completed bar < 0
Exit: short, Go histogram on the latest completed bar > 0