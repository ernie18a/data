Calculation: True-range volatility = ATR(volatility lookback)
Calculation: Volatility rank = PercentRank(100 * ATR(volatility lookback) / close, volatility-rank lookback)
Calculation: Directional efficiency = abs(close - close[efficiency lookback]) / sum(abs(close - close[1]), efficiency lookback), or 0 if the denominator is 0
Calculation: Choppiness score = 100 * log10(sum(ATR(1), volatility lookback) / (highest(high, volatility lookback) - lowest(low, volatility lookback))) / log10(volatility lookback)
Calculation: Directional power = (100 * directional efficiency + (100 - choppiness score) + (ADX(DI lookback, ADX smoothing) > trend-strength threshold ? trend-strength bonus : 0)) / power divisor
Calculation: Equilibrium power = (100 - volatility rank + 100 * (1 - directional efficiency) + (ADX(DI lookback, ADX smoothing) < trend-strength threshold ? trend-strength bonus : 0)) / power divisor
Calculation: Chaos power = (choppiness score + 100 * (1 - directional efficiency)) / chaos-power divisor
Calculation: Directional score = 100 * directional power / (directional power + equilibrium power + chaos power), or fallback score if the denominator is 0
Calculation: Chaos score = 100 * chaos power / (directional power + equilibrium power + chaos power), or fallback score if the denominator is 0
Calculation: Market regime = Directional if directional score > directional-regime threshold; otherwise Chaotic if chaos score > chaos-regime threshold; otherwise Equilibrium
Calculation: Bullish regime = market regime is Directional AND +DI(DI lookback) > -DI(DI lookback)
Calculation: Bearish regime = market regime is Directional AND -DI(DI lookback) > +DI(DI lookback)
Calculation: Fast ribbon level = EMA(close, fast lookback)
Calculation: Mid ribbon level = EMA(close, fast lookback + (slow lookback - fast lookback) * middle-layer index / (ribbon layer count - 1))
Calculation: Slow ribbon level = EMA(close, slow lookback)
Calculation: Ribbon direction is bullish when fast ribbon level > slow ribbon level, otherwise bearish
Calculation: Ribbon alignment = (close > mid ribbon level AND ribbon direction is bullish) OR (close < mid ribbon level AND ribbon direction is bearish)
Calculation: Ribbon power = abs(fast ribbon level - slow ribbon level) / true-range volatility
Calculation: Ribbon spread percentage = 100 * abs(fast ribbon level - slow ribbon level) / close
Calculation: Ribbon tight = ribbon spread percentage < SMA(ribbon spread percentage, spread-average lookback) * ribbon-tightness factor
Calculation: Ribbon expanding = abs(fast ribbon level - slow ribbon level) > its previous-bar value
Calculation: Average volume = SMA(volume, volume-average lookback)
Calculation: Volume surge = volume > average volume * volume-surge factor
Calculation: Pressure delta = 2 * buy pressure - volume, where buy pressure is volume * ((close - open + 0.5 * (high - max(open, close))) / (high - low)) when close > open, volume * ((high - max(open, close) + 0.3 * abs(close - open)) / (high - low)) when close < open, and volume * 0.5 otherwise
Calculation: Pressure index = 100 * SMA(pressure delta, pressure lookback) / SMA(volume, pressure lookback)
Calculation: Cumulative pressure = running sum of pressure delta, initialized at 0
Calculation: Volume absorption = volume / average volume > absorption-volume threshold AND (high - low) / SMA(high - low, range-average lookback) < absorption-range threshold
Calculation: Price flow = EMA(close, flow lookback) - EMA(close, flow lookback * flow expansion factor)
Calculation: Flow direction is bullish when price flow > 0, otherwise bearish
Calculation: Flow magnitude = abs(price flow) / true-range volatility
Calculation: Flow acceleration = price flow - price flow[flow-acceleration lookback]
Calculation: Flow reversal = flow direction differs from the preceding bar's direction, after an initialized preceding direction exists
Calculation: Net candle-volume flow = EMA(volume when close > open, otherwise -volume when close < open, otherwise 0, net-flow lookback)
Calculation: Volume-flow ratio = volume / EMA(volume, volume-flow lookback)
Calculation: Temporal force = (price flow / true-range volatility) * (volume-flow ratio - 1) * flow magnitude
Calculation: Fractal efficiency = clamp((log(sum(high - low adjusted by previous close, fractal lookback) / (highest(high, fractal lookback) - lowest(low, fractal lookback))) / log(fractal lookback) + 1) / 2, 0, 1), where each adjusted range is max(high, close[1]) - min(low, close[1])
Calculation: Adaptive Laguerre value = 100 * up-stage movement / (up-stage movement + down-stage movement), or 50 if the denominator is 0; use four recursive Laguerre stages on the Gaussian-filtered close, with gamma = high-efficiency gamma * fractal efficiency + low-efficiency gamma * (1 - fractal efficiency), and each stage's unavailable prior values treated as 0
Calculation: Fractal momentum = clamp(EMA((adaptive Laguerre value - 50) * (1 + fractal efficiency), momentum smoothing), -momentum cap, momentum cap)
Calculation: Bullish structure break, bearish structure break, bullish structure shift, bearish structure shift, structure direction, and latest confirmed pivot high and low = initialize direction neutral; confirm pivot highs and lows using the structure span on both sides; on a confirmed higher pivot high, mark a bullish break if direction is bullish, or a bullish shift and change direction to bullish if direction is bearish; on a confirmed lower pivot low, mark a bearish break if direction is bearish, or a bearish shift and change direction to bearish if direction is bullish; update the corresponding latest pivot and reset break and shift marks each bar
Calculation: Bullish order block = close[1] < open[1] AND close > open AND volume > average volume * order-block volume factor
Calculation: Bearish order block = close[1] > open[1] AND close < open AND volume > average volume * order-block volume factor
Calculation: Up gap = low > high[gap separation bars] AND low - high[gap separation bars] > true-range volatility * gap-size factor
Calculation: Down gap = high < low[gap separation bars] AND low[gap separation bars] - high > true-range volatility * gap-size factor
Calculation: Bullish range break = close > highest(high, range lookback)[1] AND volume surge
Calculation: Bearish range break = close < lowest(low, range lookback)[1] AND volume surge
Calculation: Strong bullish candle = close > open AND close - open > true-range volatility * strong-candle body factor
Calculation: Strong bearish candle = close < open AND open - close > true-range volatility * strong-candle body factor
Calculation: Momentum bullish = fractal momentum > bullish-momentum threshold
Calculation: Momentum bearish = fractal momentum < -bearish-momentum threshold
Calculation: Extreme momentum = abs(fractal momentum) > extreme-momentum threshold
Calculation: Rapid bullish signal = (adaptive Laguerre value < oversold threshold AND flow direction is bullish AND close > fast ribbon level) OR (pressure index > rapid-pressure threshold AND flow reversal AND flow direction is bullish) OR (momentum bullish AND volume surge AND close > mid ribbon level) OR (strong bullish candle AND ribbon direction is bullish AND pressure index > candle-pressure threshold) OR (fractal momentum > 0 AND flow acceleration > 0 AND ribbon alignment)
Calculation: Rapid bearish signal = (adaptive Laguerre value > overbought threshold AND flow direction is bearish AND close < fast ribbon level) OR (pressure index < -rapid-pressure threshold AND flow reversal AND flow direction is bearish) OR (momentum bearish AND volume surge AND close < mid ribbon level) OR (strong bearish candle AND ribbon direction is bearish AND pressure index < -candle-pressure threshold) OR (fractal momentum < 0 AND flow acceleration < 0 AND ribbon alignment)
Calculation: Swing bullish signal = (ribbon direction is bullish AND close > slow ribbon level AND bullish regime) OR (bullish structure break AND structure direction is bullish AND momentum bullish) OR (bullish order block AND flow direction is bullish AND ADX(DI lookback, ADX smoothing) > swing-conviction threshold) OR (up gap AND pressure index > gap-pressure threshold AND ribbon alignment) OR (bullish range break AND cumulative pressure > 0 AND flow magnitude > flow-strength threshold)
Calculation: Swing bearish signal = (ribbon direction is bearish AND close < slow ribbon level AND bearish regime) OR (bearish structure break AND structure direction is bearish AND momentum bearish) OR (bearish order block AND flow direction is bearish AND ADX(DI lookback, ADX smoothing) > swing-conviction threshold) OR (down gap AND pressure index < -gap-pressure threshold AND ribbon alignment) OR (bearish range break AND cumulative pressure < 0 AND flow magnitude > flow-strength threshold)
Calculation: Momentum-continuation bullish signal = (fractal momentum > strong-momentum threshold AND ribbon direction is bullish AND ADX(DI lookback, ADX smoothing) > strong-conviction threshold) OR (adaptive Laguerre value < oversold threshold AND flow direction is bullish AND volume surge) OR (extreme momentum AND fractal momentum > 0 AND ribbon expanding) OR (pressure index > extreme-pressure threshold AND flow acceleration > 0 AND bullish regime) OR (+DI(DI lookback) > -DI(DI lookback) AND +DI(DI lookback) > directional-force threshold AND ribbon alignment)
Calculation: Momentum-continuation bearish signal = (fractal momentum < -strong-momentum threshold AND ribbon direction is bearish AND ADX(DI lookback, ADX smoothing) > strong-conviction threshold) OR (adaptive Laguerre value > overbought threshold AND flow direction is bearish AND volume surge) OR (extreme momentum AND fractal momentum < 0 AND ribbon expanding) OR (pressure index < -extreme-pressure threshold AND flow acceleration < 0 AND bearish regime) OR (-DI(DI lookback) > +DI(DI lookback) AND -DI(DI lookback) > directional-force threshold AND ribbon alignment)
Calculation: Structure-confirmation bullish signal = (bullish structure shift AND structure direction is bullish AND volume surge) OR (bullish order block AND close > latest confirmed pivot low AND momentum bullish) OR (up gap AND flow direction is bullish AND ribbon direction is bullish) OR (bullish structure break AND structure direction is bullish AND pressure index > structure-pressure threshold) OR (volume absorption AND pressure delta > 0 AND close > mid ribbon level)
Calculation: Structure-confirmation bearish signal = (bearish structure shift AND structure direction is bearish AND volume surge) OR (bearish order block AND close < latest confirmed pivot high AND momentum bearish) OR (down gap AND flow direction is bearish AND ribbon direction is bearish) OR (bearish structure break AND structure direction is bearish AND pressure index < -structure-pressure threshold) OR (volume absorption AND pressure delta < 0 AND close < mid ribbon level)
Calculation: Bull strength = 1 if rapid bullish signal else 0, plus 1 if swing bullish signal else 0, plus 1 if momentum-continuation bullish signal else 0, plus 1 if structure-confirmation bullish signal else 0, plus 1 if ribbon tight AND ribbon expanding AND ribbon direction is bullish AND volume surge else 0, plus 1 if net candle-volume flow > 0 AND temporal force > positive temporal-force threshold AND bullish regime else 0
Calculation: Bear strength = 1 if rapid bearish signal else 0, plus 1 if swing bearish signal else 0, plus 1 if momentum-continuation bearish signal else 0, plus 1 if structure-confirmation bearish signal else 0, plus 1 if ribbon tight AND ribbon expanding AND ribbon direction is bearish AND volume surge else 0, plus 1 if net candle-volume flow < 0 AND temporal force < negative temporal-force threshold AND bearish regime else 0
Long: bull strength >= minimum signal strength AND position is flat
Short: bear strength >= minimum signal strength AND position is flat
Long: pressure index > extreme-buy threshold
Short: pressure index < -extreme-sell threshold
Calculation: Initial long stop = close on entry-signal bar - ATR(volatility lookback) on entry-signal bar * stop-distance multiplier
Calculation: Initial long target = close on entry-signal bar + ATR(volatility lookback) on entry-signal bar * stop-distance multiplier * target multiplier
Calculation: Initial short stop = close on entry-signal bar + ATR(volatility lookback) on entry-signal bar * stop-distance multiplier
Calculation: Initial short target = close on entry-signal bar - ATR(volatility lookback) on entry-signal bar * stop-distance multiplier * target multiplier
Exit: long, low <= initial long stop OR high >= initial long target OR (trailing stop enabled AND low <= previous bar close - ATR(volatility lookback)[1] * trailing offset)
Exit: short, high >= initial short stop OR low <= initial short target OR (trailing stop enabled AND high >= previous bar close + ATR(volatility lookback)[1] * trailing offset)