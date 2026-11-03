Calculation: Fast EVWMA = ((sum of volume over the shorter lookback − current volume) × previous Fast EVWMA + current volume × close) ÷ sum of volume over the shorter lookback; initialize previous Fast EVWMA with close
Calculation: Slow EVWMA = ((sum of volume over the longer lookback − current volume) × previous Slow EVWMA + current volume × close) ÷ sum of volume over the longer lookback; initialize previous Slow EVWMA with close
Long: Fast EVWMA crosses above Slow EVWMA
Short: Fast EVWMA crosses below Slow EVWMA