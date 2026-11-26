Calculation: Bull score = add one for each true condition: close > VWAP(hlc3); RSI(close, RSI lookback) > RSI midpoint; MACD(close, shorter lookback, longer lookback, signal lookback) line > signal; EMA(close, shorter lookback) > EMA(close, longer lookback); ADX(DI lookback, ADX smoothing) > ADX threshold AND close > EMA(close, shorter lookback); volume > SMA(volume, volume lookback) AND close > open; RSI(close, RSI lookback, T1, bar still forming, sampled on chart bars) > RSI midpoint
Calculation: Bear score = add one for each true condition: close < VWAP(hlc3); RSI(close, RSI lookback) < RSI midpoint; MACD(close, shorter lookback, longer lookback, signal lookback) line < signal; EMA(close, shorter lookback) < EMA(close, longer lookback); ADX(DI lookback, ADX smoothing) > ADX threshold AND close < EMA(close, shorter lookback); volume > SMA(volume, volume lookback) AND close < open; RSI(close, RSI lookback, T1, bar still forming, sampled on chart bars) < RSI midpoint
Calculation: Position score = bull score when position side is long, bear score when short, and the greater of the two scores when flat
Calculation: Fast smoothed stochastic = SMA(Stochastic(close, high, low, fast K lookback), fast D lookback)
Calculation: Medium smoothed stochastic = SMA(Stochastic(close, high, low, medium K lookback), medium D lookback)
Calculation: Slow smoothed stochastic = SMA(Stochastic(close, high, low, slow K lookback), slow D lookback)
Calculation: Trend smoothed stochastic = SMA(Stochastic(close, high, low, trend K lookback), trend D lookback, T4, bar still forming, sampled on chart bars)
Calculation: Short structure events = store high[1] when high[1] > high[2] AND high[1] >= high, reset its crossed state, and emit one bullish event when a later close first exceeds the stored high; store low[1] when low[1] < low[2] AND low[1] <= low, reset its crossed state, and emit one bearish event when a later close first falls below the stored low
Calculation: Intermediate structure events = when a short pivot-high condition with a stored short pivot high first becomes true, store that short pivot high as the intermediate high and reset its crossed state; emit one bullish event when a later close first exceeds it; apply the corresponding low-pivot and close-below logic for bearish events
Calculation: Long structure events = when a short pivot-high condition with a stored intermediate pivot high first becomes true, store that intermediate pivot high as the long high and reset its crossed state; emit one bullish event when a later close first exceeds it; apply the corresponding low-pivot and close-below logic for bearish events
Calculation: Normalized structure-event oscillator(bullish event, bearish event, smoothing) = SMA((close - running minimum) / (running maximum - running minimum), smoothing) × 100; event state becomes bullish on a bullish event, bearish on a bearish event, otherwise retains its prior state; reset the running maximum to close when event state rises, reset the running minimum to close when it falls, and otherwise extend each extreme with close
Calculation: Short structure oscillator = Normalized structure-event oscillator(short bullish event, short bearish event, oscillator smoothing)
Calculation: Intermediate structure oscillator = Normalized structure-event oscillator(intermediate bullish event, intermediate bearish event, oscillator smoothing)
Calculation: Long structure oscillator = Normalized structure-event oscillator(long bullish event, long bearish event, oscillator smoothing)
Calculation: Market Structure Oscillator = (short-term weight × short structure oscillator + intermediate-term weight × intermediate structure oscillator + long-term weight × long structure oscillator) / sum of the three weights
Calculation: Cycle oscillator = Market Structure Oscillator - EMA(Market Structure Oscillator, cycle lookback) + oscillator midpoint
Calculation: Quad stage reference = on the first bar when all four smoothed stochastic values are at or below oversold, store low and fast smoothed stochastic; on the first bar when all four are at or above overbought, store high and fast smoothed stochastic, overwriting both stored values
Calculation: Quad bullish stage = true on the first all-four-oversold bar, false on the first all-four-overbought bar or a main EMA entry signal, otherwise retain its prior state
Calculation: Quad bearish stage = true on the first all-four-overbought bar, false on the first all-four-oversold bar or a main EMA entry signal, otherwise retain its prior state
Calculation: Quad bullish reversal = reset false on the first all-four-oversold bar or a main EMA entry signal; while the bullish stage is active and not all four are oversold, set true when low <= the stored quad stage reference low AND fast smoothed stochastic > the stored reference stochastic AND fast smoothed stochastic is rising AND fast smoothed stochastic <= oversold + divergence edge buffer; otherwise retain its prior state
Calculation: Quad bearish reversal = reset false on the first all-four-overbought bar or a main EMA entry signal; while the bearish stage is active and not all four are overbought, set true when high >= the stored quad stage reference high AND fast smoothed stochastic < the stored reference stochastic AND fast smoothed stochastic is falling AND fast smoothed stochastic >= overbought - divergence edge buffer; otherwise retain its prior state
Long: EMA(close, shorter lookback) crosses above EMA(close, longer lookback) AND position side is not long AND (HTF filter is disabled OR HTF bullish alignment)
Short: EMA(close, shorter lookback) crosses below EMA(close, longer lookback) AND position side is not short AND (HTF filter is disabled OR HTF bearish alignment)
Long: close crosses above the UT Bot ATR trailing stop using ATR(UT ATR lookback) × UT sensitivity
Short: close crosses below the UT Bot ATR trailing stop using ATR(UT ATR lookback) × UT sensitivity
Long: Market Structure Oscillator crosses from below oscillator midpoint to at or above it, OR from at or below it to above it
Short: Market Structure Oscillator crosses from above oscillator midpoint to at or below it, OR from at or above it to below it
Long: Cycle oscillator crosses from below oscillator midpoint to at or above it, OR from at or below it to above it
Short: Cycle oscillator crosses from above oscillator midpoint to at or below it, OR from at or above it to below it
Long: Quad bullish reversal
Short: Quad bearish reversal
Long: Trend smoothed stochastic >= trend boundary AND Medium smoothed stochastic >= stochastic midpoint AND Slow smoothed stochastic >= stochastic midpoint AND Fast smoothed stochastic <= oversold AND Fast smoothed stochastic is rising
Short: Trend smoothed stochastic <= 100 - trend boundary AND Medium smoothed stochastic <= stochastic midpoint AND Slow smoothed stochastic <= stochastic midpoint AND Fast smoothed stochastic >= overbought AND Fast smoothed stochastic is falling
Long: all four smoothed stochastic values <= oversold
Short: all four smoothed stochastic values >= overbought
Long: Quad bullish stage AND not all four smoothed stochastic values <= oversold
Short: Quad bearish stage AND not all four smoothed stochastic values >= overbought
Long: Trend smoothed stochastic >= trend-strength threshold AND Medium smoothed stochastic >= stochastic midpoint AND Slow smoothed stochastic >= stochastic midpoint AND Fast smoothed stochastic <= oversold AND Fast smoothed stochastic is rising
Short: Trend smoothed stochastic <= 100 - trend-strength threshold AND Medium smoothed stochastic <= stochastic midpoint AND Slow smoothed stochastic <= stochastic midpoint AND Fast smoothed stochastic >= overbought AND Fast smoothed stochastic is falling
Long: EMA(close, shorter lookback, T2, bar still forming, sampled on chart bars) > EMA(close, longer lookback, T2, bar still forming, sampled on chart bars) AND close > VWAP(hlc3, T2, bar still forming, sampled on chart bars) AND (second HTF reference is disabled OR EMA(close, shorter lookback, T3, bar still forming, sampled on chart bars) > EMA(close, longer lookback, T3, bar still forming, sampled on chart bars) AND close > VWAP(hlc3, T3, bar still forming, sampled on chart bars))
Short: EMA(close, shorter lookback, T2, bar still forming, sampled on chart bars) < EMA(close, longer lookback, T2, bar still forming, sampled on chart bars) AND close < VWAP(hlc3, T2, bar still forming, sampled on chart bars) AND (second HTF reference is disabled OR EMA(close, shorter lookback, T3, bar still forming, sampled on chart bars) < EMA(close, longer lookback, T3, bar still forming, sampled on chart bars) AND close < VWAP(hlc3, T3, bar still forming, sampled on chart bars))
Long: bull score > bear score
Short: bull score <= bear score
Long: Market Structure Oscillator >= bullish structure threshold
Short: Market Structure Oscillator <= bearish structure threshold
Long: long bullish structure event OR (not long bearish structure event AND intermediate bullish structure event)
Short: not long bullish structure event AND (long bearish structure event OR (not intermediate bullish structure event AND intermediate bearish structure event))
Long: Trend smoothed stochastic >= trend boundary
Short: Trend smoothed stochastic <= 100 - trend boundary
Long: close > VWAP(hlc3)
Short: close <= VWAP(hlc3)
Long: RSI(close, RSI lookback) > RSI midpoint
Short: RSI(close, RSI lookback) <= RSI midpoint
Long: MACD(close, shorter lookback, longer lookback, signal lookback) line > signal
Short: MACD(close, shorter lookback, longer lookback, signal lookback) line <= signal
Long: EMA(close, shorter lookback) > EMA(close, longer lookback)
Short: EMA(close, shorter lookback) <= EMA(close, longer lookback)
Long: RSI(close, RSI lookback, T1, bar still forming, sampled on chart bars) > RSI midpoint
Short: RSI(close, RSI lookback, T1, bar still forming, sampled on chart bars) <= RSI midpoint
Long: position side is long AND position score >= A-plus score threshold AND (Quad bullish reversal OR hidden bullish stochastic divergence OR fast stochastic bull-flag condition) AND Market Structure Oscillator >= oscillator midpoint AND close > VWAP(hlc3) AND (HTF filter is disabled OR HTF bullish alignment)
Short: position side is short AND position score >= A-plus score threshold AND (Quad bearish reversal OR hidden bearish stochastic divergence OR fast stochastic bear-flag condition) AND Market Structure Oscillator <= oscillator midpoint AND close < VWAP(hlc3) AND (HTF filter is disabled OR HTF bearish alignment)
Long: position score >= B-setup score threshold AND Market Structure Oscillator >= B-setup bullish threshold AND close > VWAP(hlc3)
Short: position score >= B-setup score threshold AND Market Structure Oscillator <= B-setup bearish threshold AND close < VWAP(hlc3)
Long: position side is long AND Fast smoothed stochastic >= overbought AND Trend smoothed stochastic < its prior-bar value AND close < EMA(close, longer lookback)
Short: position side is short AND Fast smoothed stochastic <= oversold AND Trend smoothed stochastic > its prior-bar value AND close > EMA(close, longer lookback)
Exit: long, position score <= exit-zone threshold
Exit: short, position score <= exit-zone threshold
Exit: long, (close - (entry price - initial stop distance)) / initial stop distance <= stop-close warning ratio, where initial stop distance is ATR(risk ATR lookback) × stop-distance multiplier at entry
Exit: short, ((entry price + initial stop distance) - close) / initial stop distance <= stop-close warning ratio, where initial stop distance is ATR(risk ATR lookback) × stop-distance multiplier at entry