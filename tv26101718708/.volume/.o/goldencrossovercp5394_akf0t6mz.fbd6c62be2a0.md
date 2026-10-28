Calculation: Signal candle percentage range = (signal candle high − signal candle low) / signal candle low × 100
Calculation: Long risk = the smaller of entry price − signal candle low and entry price × configured risk cap percentage
Calculation: Short risk = the smaller of signal candle high − entry price and entry price × configured risk cap percentage
Calculation: Long reward/risk multiple = lower configured multiple if signal candle percentage range exceeds its threshold; otherwise higher configured multiple
Calculation: Short reward/risk multiple = lower configured multiple if signal candle percentage range exceeds its threshold; otherwise higher configured multiple
Calculation: Long stop = entry price − long risk
Calculation: Long target = entry price + long reward/risk multiple × long risk
Calculation: Short stop = entry price + short risk
Calculation: Short target = entry price − short reward/risk multiple × short risk
Long: short-term EMA crosses above both longer-term EMAs AND volume > its moving average
Short: short-term EMA crosses below both longer-term EMAs AND volume > its moving average
Exit: long, low ≤ long stop OR high ≥ long target OR bar hour = configured exit hour AND bar minute ≥ configured exit minute
Exit: short, high ≥ short stop OR low ≤ short target OR bar hour = configured exit hour AND bar minute ≥ configured exit minute