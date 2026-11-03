Calculation: Short-term Force Index = RMA((close − previous close) × volume) using a shorter lookback than the long-term Force Index
Calculation: Long-term Force Index = RMA((close − previous close) × volume) using a longer lookback than the short-term Force Index
Calculation: EMA channel = EMA(high) as the upper boundary and EMA(low) as the lower boundary, using the same lookback
Calculation: Pullback average = RMA(HLC3) using a shorter lookback than the EMA channel
Long: long-term Force Index > 0 AND short-term Force Index < 0 AND previous short-term Force Index < current short-term Force Index AND ADX >= its trade threshold AND open < upper EMA channel AND pullback average >= lower EMA channel
Short: long-term Force Index < 0 AND short-term Force Index > 0 AND previous short-term Force Index > current short-term Force Index AND ADX >= its trade threshold AND open > lower EMA channel AND pullback average <= upper EMA channel
Exit: long, price <= signal-bar low minus an ATR multiple OR price >= signal-bar high plus an ATR multiple
Exit: short, price >= signal-bar high plus an ATR multiple OR price <= signal-bar low minus an ATR multiple