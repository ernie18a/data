Calculation: EMA lengths = fast < slow < trend; use the fast, slow, and trend EMAs for the chart-bar close.
Calculation: Higher-timeframe fast and slow EMAs = the chart fast and slow EMA lengths, calculated from the configured higher-timeframe bars, including the bar still forming.
Calculation: Momentum = 5-period EMA of the current close minus the close 5 bars earlier.
Calculation: Wave oscillator = 8-period EMA of close minus 21-period EMA of close; its signal line is the 9-period EMA of the oscillator.
Calculation: Equilibrium = midpoint of the highest high and lowest low over the last 100 chart bars.
Calculation: Bullish break = chart close crosses above the most recently confirmed pivot high; bearish break = chart close crosses below the most recently confirmed pivot low. Pivots use equal left and right strengths.
Calculation: Bullish sweep = chart low < most recently confirmed pivot low AND chart close > that pivot low; bearish sweep = chart high > most recently confirmed pivot high AND chart close < that pivot high.
Calculation: Bullish rejection = close > open AND lower wick > 2 × candle body; bearish rejection = close < open AND upper wick > 2 × candle body.
Calculation: Bullish order-block signal = bullish break AND previous bar close < previous bar open; bearish order-block signal = bearish break AND previous bar close > previous bar open.
Calculation: Demand-zone signal = volume > 1.8 × 20-bar average volume AND close > open AND lower wick > 0.75 × body; supply-zone signal = volume > 1.8 × 20-bar average volume AND close < open AND upper wick > 0.75 × body.
Calculation: AI score = 10 if either bullish or bearish trend, else 0; +12 if ADX > 25; +12 if higher-timeframe fast EMA > slow EMA and bullish trend, or higher-timeframe fast EMA < slow EMA and bearish trend; +8 if ATR > its 20-bar average; +8 if either close > open and volume > its 20-bar average, or close < open and volume > its 20-bar average; +8 during the London/New York session overlap; +10 if either break occurs; +8 if either sweep occurs; +6 if either FVG occurs (bullish: low > high 2 bars earlier; bearish: high < low 2 bars earlier); +7 if either order-block signal occurs; +6 if either demand- or supply-zone signal occurs; +5 if equal consecutive confirmed pivot highs or lows are within 0.25 × ATR; +6 if the wave oscillator is above its signal and above zero with bullish trend, or below its signal and below zero with bearish trend; +6 if close is above the SuperTrend line with bullish trend, or below it with bearish trend; +5 if candle body / candle range > 0.65 and candle range > ATR; +8 outside the configured New York news session when the news filter is enabled, otherwise −25 during that session. A disabled news filter always adds 8.
Long: fast EMA > slow EMA AND close > trend EMA AND RSI > 50 AND close > VWAP AND higher-timeframe fast EMA > slow EMA AND ADX > 25 AND close < Equilibrium AND close > SuperTrend line AND wave oscillator > its signal line AND wave oscillator > 0 AND (bullish break OR bullish sweep OR bullish rejection OR demand-zone signal) AND outside the configured New York news session or news filter disabled AND AI score >= 70.
Short: fast EMA < slow EMA AND close < trend EMA AND RSI < 50 AND close < VWAP AND higher-timeframe fast EMA < slow EMA AND ADX > 25 AND close > Equilibrium AND close < SuperTrend line AND wave oscillator < its signal line AND wave oscillator < 0 AND (bearish break OR bearish sweep OR bearish rejection OR supply-zone signal) AND outside the configured New York news session or news filter disabled AND AI score >= 70.
Long: bullish break AND prior market state is not bearish.
Short: bearish break AND prior market state is not bullish.
Long: bullish break AND prior market state is bearish.
Short: bearish break AND prior market state is bullish.
Short: bearish sweep.
Long: bullish sweep.
Long: bullish FVG (current low > high 2 bars earlier).
Short: bearish FVG (current high < low 2 bars earlier).
Long: bullish order-block signal.
Short: bearish order-block signal.
Long: demand-zone signal.
Short: supply-zone signal.
Long: bullish rejection.
Short: bearish rejection.
Long: wave oscillator crosses above its signal line.
Short: wave oscillator crosses below its signal line.