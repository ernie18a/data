Calculation: Heikin Ashi candle = standard Heikin Ashi open, high, low, and close derived from the input bars
Calculation: Swing high/low = confirmed pivot high/low of Heikin Ashi highs/lows on a higher 5-minute timeframe, using equal left and right lookbacks
Calculation: Daily VWAP = cumulative typical price × volume divided by cumulative volume, reset at the UTC+7 day boundary
Calculation: Session CVD = cumulative lower-timeframe volume on up candles minus volume on down candles, reset at each session start; use NY CVD during NY, otherwise London during London, otherwise Asia during Asia
Calculation: Daily VWAP ROC = 100 × (daily VWAP − its value at the longer lookback) / its value at the longer lookback; valid only after that many bars since the UTC+7 day boundary
Calculation: Momentum score = mean over the shorter lookback of signed candle body/range × directional close position; directional close position is (close − low)/range for up candles and (high − close)/range for down candles
Long: Close crosses above the latest confirmed swing high after a low sweep (bullish CHoCH)
Long: Close crosses above the latest confirmed swing high without a pending low sweep (bullish BOS)
Short: Close crosses below the latest confirmed swing low after a high sweep (bearish CHoCH)
Short: Close crosses below the latest confirmed swing low without a pending high sweep (bearish BOS)
Long: Close > daily VWAP
Short: Close <= daily VWAP
Long: Close > daily VWAP AND active session CVD > 0
Short: Close <= daily VWAP AND active session CVD < 0
Long: Valid daily VWAP ROC crosses above either positive threshold
Short: Valid daily VWAP ROC crosses below either negative threshold
Long: Momentum score >= 0.40
Short: Momentum score <= -0.40
Long: Bullish CHoCH or BOS occurs while close > daily VWAP; then a Heikin Ashi down candle occurs within 6 bars; within 20 bars of the structure break, a Heikin Ashi up candle occurs while close > daily VWAP and active session CVD is rising, and current candle body/range >= the entry body ratio
Short: Bearish CHoCH or BOS occurs while close <= daily VWAP; then a Heikin Ashi up candle occurs within 6 bars; within 20 bars of the structure break, a Heikin Ashi down candle occurs while close <= daily VWAP and active session CVD is falling, and current candle body/range >= the entry body ratio