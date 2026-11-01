Calculation: Timeframe data = Apply each decision independently to each selected chart, higher, or lower timeframe. For higher timeframes use the last completed bar on historical chart bars and the still-forming bar in real time; for lower timeframes use the last available completed intrabar within each chart bar. Evaluate score crossings and alignment changes on chart bars.
Calculation: Structure direction = Confirm a pivot high or low after the same lookback number of bars on each side. Keep the latest confirmed high and low active until each is broken or replaced by a newer pivot of the same type. An active high is broken when the selected close or high exceeds it; an active low is broken when the selected close or low falls below it. Direction is that of the most recent break; process the high break before the low break if both occur on one bar.
Calculation: Cloud = The undisplaced span A is the average of the short-range and medium-range high-low midpoints; span B is the long-range high-low midpoint. The cloud boundaries are the larger and smaller spans, respectively.
Calculation: Approximate cumulative volume delta = Cumulative sum of volume × ((close − low) − (high − close)) / (high − low), using zero when high equals low or volume is unavailable.
Calculation: Score = Sum one vote each for close versus fast EMA, fast versus medium EMA, medium versus slow EMA, MACD line versus signal with histogram agreement, RSI versus its directional thresholds, SuperTrend direction, close versus the undisplaced cloud, and approximate cumulative volume delta versus its lookback value with close moving in the same direction. Each vote is +1 for its corresponding long condition, −1 for its corresponding short condition, and 0 otherwise. Include the volume-delta vote only when the selected timeframe bar's volume is positive.
Long: Structure direction = up.
Short: Structure direction = down.
Long: Close > fast EMA.
Short: Close < fast EMA.
Long: Fast EMA > medium EMA.
Short: Fast EMA < medium EMA.
Long: Medium EMA > slow EMA.
Short: Medium EMA < slow EMA.
Long: MACD line > signal line AND MACD histogram > 0.
Short: MACD line < signal line AND MACD histogram < 0.
Long: RSI >= bullish RSI threshold.
Short: RSI < bullish RSI threshold AND RSI <= bearish RSI threshold.
Long: SuperTrend direction = up.
Short: SuperTrend direction = down.
Long: Close > upper cloud boundary.
Short: Close < lower cloud boundary.
Long: At least one chart bar to date has positive volume AND approximate cumulative volume delta > its value at the volume-flow lookback AND close > its value at the same lookback.
Short: At least one chart bar to date has positive volume AND approximate cumulative volume delta < its value at the volume-flow lookback AND close < its value at the same lookback.
Long: ADX >= its trend threshold AND +DI > −DI.
Short: ADX >= its trend threshold AND +DI <= −DI.
Long: At least one chart bar to date has positive volume AND close <= the lowest close in the OBV divergence window AND OBV > the lowest OBV in that window AND NOT (close >= the highest close in that window AND OBV < the highest OBV in that window).
Short: At least one chart bar to date has positive volume AND close >= the highest close in the OBV divergence window AND OBV < the highest OBV in that window.
Long: Close <= the lowest close in the RSI divergence window AND RSI > the lowest RSI in that window AND NOT (close >= the highest close in that window AND RSI < the highest RSI in that window).
Short: Close >= the highest close in the RSI divergence window AND RSI < the highest RSI in that window.
Long: Score >= bullish verdict threshold.
Short: Score <= bearish verdict threshold.
Long: Score crosses above the bullish alert threshold between consecutive chart bars.
Short: Score crosses below the bearish alert threshold between consecutive chart bars.
Long: Every selected visible timeframe's score >= bullish verdict threshold AND at least one selected visible timeframe's score was below that threshold on the preceding chart bar.
Short: Every selected visible timeframe's score <= bearish verdict threshold AND at least one selected visible timeframe's score was above that threshold on the preceding chart bar.