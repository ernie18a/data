Calculation: EMA = exponential moving average of close; fast < mid < base < macro lookback
Calculation: RSI = relative strength index of close
Calculation: MACD histogram = MACD line minus its signal line
Calculation: Relative volume = volume / average volume; compare with a required relative-volume threshold
Calculation: Candle body percentage = abs(close - open) / (high - low); close position = (close - low) / (high - low)
Calculation: Donchian upper/mid = highest high and midpoint of highest high and lowest low over the lookback; compare the upper level with its prior-bar value
Calculation: XGS score = weighted sum of trend, structure, momentum, relative leadership, and risk flags; trend flags use close vs. mid EMA, fast vs. mid EMA, mid vs. base EMA, base vs. macro EMA, and a healthy trend (close > mid EMA, mid EMA > base EMA, and mid EMA nondecreasing); structure flags use Donchian support/break, close vs. Donchian midpoint, higher-timeframe support, recent bullish structure, bullish order-block location, and healthy Fibonacci location; momentum flags use RSI, MACD histogram, positive divergence, fast-vs-slow micro EMA, and Bollinger control; leadership flags use relative strength vs. its EMA and relative-strength breakout; risk flags use absence of trap, safe price extension, and absence of bearish structure, order-block risk, and negative divergence
Calculation: DTS score = weighted sum of location, trigger, participation, and context flags; location uses close vs. mid EMA, close vs. VWAP (or mid EMA when VWAP is disabled), liquidity reclaim, daily pivot, bullish structure/FVG, bullish order block, and Fibonacci OTE; trigger uses candle authority, candle grade, stochastic direction, bullish close position, and bullish micro EMA flip; participation uses relative volume, OBV vs. its average, and CMF; context uses session, bullish phase, volatility expansion, no trap, and no negative divergence
Calculation: Higher-timeframe support = higher-timeframe close > mid EMA and mid EMA >= base EMA, using the last completed higher-timeframe bar
Calculation: Positive divergence = at least the required count of enabled oscillators makes a regular bullish divergence (price lower low, oscillator higher low) or hidden bullish divergence (price higher low, oscillator lower low) between successive confirmed pivot lows; negative divergence uses successive pivot highs (regular: price higher high, oscillator lower high; hidden: price lower high, oscillator higher high)
Calculation: Bullish structure event = close crosses above a confirmed internal or swing pivot high; bearish structure event = close crosses below a confirmed internal or swing pivot low
Calculation: Bullish reversal score = weighted sum of prior-downtrend, exhaustion, liquidity sweep, EMA/VWAP reclaim, bullish candle, momentum turn, positive divergence, bullish location, participation, and no-major-risk flags; bearish reversal score uses prior uptrend, exhaustion, liquidity sweep, EMA/VWAP loss, bearish candle, momentum fade, negative divergence, bearish location, distribution, and no-bullish-continuation flags
Calculation: Confirmed bottom reversal = prior downtrend and reversal score >= confirmation threshold and no-major-risk, subject to enabled sweep, reclaim, divergence, location, higher-timeframe, and confirmed-bar requirements
Calculation: Confirmed top reversal = prior uptrend and reversal score >= confirmation threshold, subject to enabled sweep, EMA/VWAP-loss, divergence, location, and confirmed-bar requirements
Calculation: Active stop = initial stop at the lower of close minus ATR risk multiple and swing low minus ATR buffer; raise it to entry after the gain threshold, to the buffered mid EMA after its gain threshold, and to the selected ATR, mid-EMA, swing-low, or hybrid trailing level after the selected trailing-start condition
Long: confirmed bottom reversal
Long: XGS score >= buy threshold AND DTS score >= buy threshold AND at least 10 of the 12 core layers pass AND confluence >= buy-grade threshold AND mandatory filters pass AND required module confirmations pass AND confirmed bar AND cooldown elapsed AND not already in a trade; core layers are XGS, DTS, trend, RSI/MACD momentum, MACD acceleration, relative-volume participation, CMF/MFI flow, relative leadership, higher-timeframe support, candle authority, no trap/distribution, and phase/safety
Long: bullish structure event
Long: positive divergence
Long: close crosses above a valid descending trendline, with confirmed-bar requirement when enabled
Long: fast micro EMA crosses above slow micro EMA, with bullish candle required when enabled
Short: confirmed top reversal
Short: bearish structure event
Short: negative divergence
Short: close crosses below a valid ascending trendline, with confirmed-bar requirement when enabled
Short: fast micro EMA crosses below slow micro EMA, with bearish candle required when enabled
Exit: long, close < active stop OR ((close < base EMA AND MACD histogram < 0) OR (RSI < bull-zone floor AND close < mid EMA) OR bearish swing-structure break) OR (exit-on-warning enabled AND warning event)