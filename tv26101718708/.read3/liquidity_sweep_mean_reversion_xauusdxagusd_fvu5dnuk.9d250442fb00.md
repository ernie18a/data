Calculation: Bullish sweep = (low < Lowest(low, shorter liquidity lookback)[1] AND close > Lowest(low, shorter liquidity lookback)[1]) OR (low < Lowest(low, longer liquidity lookback)[1] AND close > Lowest(low, longer liquidity lookback)[1])
Calculation: Bearish sweep = (high > Highest(high, shorter liquidity lookback)[1] AND close < Highest(high, shorter liquidity lookback)[1]) OR (high > Highest(high, longer liquidity lookback)[1] AND close < Highest(high, longer liquidity lookback)[1])
Calculation: Bullish filtered sweep = Bullish sweep AND (sweep VWAP filter disabled OR close > VWAP(hlc3, selected anchor period))
Calculation: Bearish filtered sweep = Bearish sweep AND (sweep VWAP filter disabled OR close < VWAP(hlc3, selected anchor period))
Calculation: Bullish active sweep = a bullish sweep occurred within the active sweep window
Calculation: Bearish active sweep = a bearish sweep occurred within the active sweep window
Calculation: Bullish MSS = Bullish active sweep AND a confirmed pivot high exists AND close > the latest confirmed PivotHigh(high, pivot lookback, pivot lookback)
Calculation: Bearish MSS = Bearish active sweep AND a confirmed pivot low exists AND close < the latest confirmed PivotLow(low, pivot lookback, pivot lookback)
Calculation: Long setup = (Bullish MSS AND (RMA(close, faster smoothing lookback) crosses above RMA(close, slower smoothing lookback) OR close > RMA(close, faster smoothing lookback)) AND close > VWAP(hlc3, selected anchor period)) OR (Bullish filtered sweep AND (RMA(close, faster smoothing lookback) crosses above RMA(close, slower smoothing lookback) OR close crosses above RMA(close, faster smoothing lookback)) AND close > VWAP(hlc3, selected anchor period)) OR Bullish filtered sweep
Calculation: Short setup = (Bearish MSS AND (RMA(close, faster smoothing lookback) crosses below RMA(close, slower smoothing lookback) OR close < RMA(close, faster smoothing lookback)) AND close < VWAP(hlc3, selected anchor period)) OR (Bearish filtered sweep AND (RMA(close, faster smoothing lookback) crosses below RMA(close, slower smoothing lookback) OR close crosses below RMA(close, faster smoothing lookback)) AND close < VWAP(hlc3, selected anchor period)) OR Bearish filtered sweep
Calculation: Candidate long stop = most recent bullish sweep candle low × (1 − stop buffer percentage / 100)
Calculation: Candidate short stop = most recent bearish sweep candle high × (1 + stop buffer percentage / 100)
Calculation: Candidate long target = Highest(high, shorter liquidity lookback)
Calculation: Candidate short target = Lowest(low, shorter liquidity lookback)
Calculation: Long reward/risk = if abs(close − Candidate long stop) > 0 then abs(Candidate long target − close) / abs(close − Candidate long stop) else 0
Calculation: Short reward/risk = if abs(Candidate short stop − close) > 0 then abs(close − Candidate short target) / abs(Candidate short stop − close) else 0
Long: Bullish sweep
Short: Bearish sweep
Long: Bullish filtered sweep
Short: Bearish filtered sweep
Long: Bullish MSS
Short: Bearish MSS
Long: close > VWAP(hlc3, selected anchor period)
Short: close <= VWAP(hlc3, selected anchor period)
Long: position side is long
Short: position side is short
Long: Long setup AND Long reward/risk >= minimum reward/risk parameter AND (time filter disabled OR current bar UTC time is within the configured UTC session)
Short: Short setup AND Short reward/risk >= minimum reward/risk parameter AND (time filter disabled OR current bar UTC time is within the configured UTC session)
Long: position is flat AND Long setup AND Long reward/risk >= minimum reward/risk parameter AND (time filter disabled OR current bar UTC time is within the configured UTC session)
Short: position is flat AND Short setup AND Short reward/risk >= minimum reward/risk parameter AND (time filter disabled OR current bar UTC time is within the configured UTC session)
Exit: long, low <= Candidate long stop captured at entry OR high >= Candidate long target captured at entry
Exit: short, high >= Candidate short stop captured at entry OR low <= Candidate short target captured at entry
Exit: long, partial-close option enabled AND the first close cross above RMA(close, faster smoothing lookback) since entry
Exit: short, partial-close option enabled AND the first close cross below RMA(close, faster smoothing lookback) since entry