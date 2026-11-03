Calculation: Fast and slow CCI = commodity channel index of the selected moving average of close; fast CCI uses a shorter lookback than slow CCI.
Long: (previous CHO < 0 AND current CHO > 0) OR (current CHO > 0 AND previous fast CCI < 0 AND previous fast CCI < previous slow CCI AND current fast CCI > current slow CCI)
Short: (previous CHO > 0 AND current CHO < 0) OR (current CHO < 0 AND previous fast CCI > 0 AND previous fast CCI > previous slow CCI AND current fast CCI < current slow CCI)
Exit: long, previous CHO > 0 AND current CHO < 0
Exit: short, previous CHO < 0 AND current CHO > 0