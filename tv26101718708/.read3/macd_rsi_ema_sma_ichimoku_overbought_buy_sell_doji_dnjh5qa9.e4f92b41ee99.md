Calculation: Pattern OHLC = Heikin Ashi OHLC when the Heikin Ashi setting is enabled, otherwise chart OHLC
Calculation: Pattern body = pattern close − pattern open
Calculation: Pattern body size = abs(pattern body)
Calculation: Pattern range = pattern high − pattern low
Calculation: Up candle = pattern body >= 0
Calculation: Upper wick = up candle ? pattern high − pattern close : pattern high − pattern open
Calculation: Lower wick = up candle ? pattern open − pattern low : pattern close − pattern low
Calculation: Prior body-size filter = minimum prior-body ticks parameter is zero OR each of the prior doji-lookback bars has body size > minimum prior-body ticks parameter × minimum tick size
Calculation: Doji geometry = pattern body size < pattern range × (100 − doji wick-percentage parameter)/100 AND upper wick > pattern range × doji wick-percentage parameter/200 AND lower wick > pattern range × doji wick-percentage parameter/200
Calculation: Bullish containment = prior pattern open >= max(pattern open, pattern close) AND prior pattern close <= min(pattern open, pattern close)
Calculation: Bearish containment = prior pattern close >= max(pattern open, pattern close) AND prior pattern open <= min(pattern open, pattern close)
Calculation: Prior bearish sequence = each of the prior doji-lookback bars has pattern open > pattern close
Calculation: Prior bullish sequence = each of the prior doji-lookback bars has pattern open < pattern close
Calculation: Bullish harami core = bullish containment AND prior body-size filter AND doji geometry
Calculation: Bearish harami core = bearish containment AND prior body-size filter AND doji geometry
Calculation: MACD line = SMA(MACD source, MACD fast lookback) − SMA(MACD source, MACD slow lookback), with MACD fast lookback < MACD slow lookback
Calculation: SMA-based MACD histogram = MACD line − SMA(MACD line, MACD signal lookback)
Calculation: Smoothed PPO = SMA(100 × (EMA(MACD source, PPO fast lookback) − EMA(MACD source, PPO slow lookback))/EMA(MACD source, PPO slow lookback), PPO smoothing lookback), with PPO fast lookback < PPO slow lookback
Calculation: PPO trough = Smoothed PPO > Smoothed PPO[1] AND Smoothed PPO[1] < Smoothed PPO[2]
Calculation: PPO peak = Smoothed PPO < Smoothed PPO[1] AND Smoothed PPO[1] > Smoothed PPO[2]
Calculation: Price trough = low > low[1] AND low[1] < low[2] OR low[1] = low[2] AND low[1] < low AND low[1] < low[3] OR low[1] = low[2] AND low[1] = low[3] AND low[1] < low AND low[1] < low[4] OR low[1] = low[2] AND low[1] = low[3] AND low[1] = low[4] AND low[1] != 0 AND low[1] < low AND low[1] < low[5]
Calculation: Price peak = high < high[1] AND high[1] > high[2] OR high[1] = high[2] AND high[1] > high AND high[1] > high[3] OR high[1] = high[2] AND high[1] = high[3] AND high[1] > high AND high[1] > high[4] OR high[1] = high[2] AND high[1] = high[3] AND high[1] = high[4] AND high[1] != 0 AND high[1] > high AND high[1] > high[5]
Calculation: Current PPO trough value = valuewhen(PPO trough, Smoothed PPO[1], 0)
Calculation: Current PPO peak value = valuewhen(PPO peak, Smoothed PPO[1], 0)
Calculation: Previous PPO trough value = valuewhen(PPO trough, current PPO trough value, 1)
Calculation: Previous PPO peak value = valuewhen(PPO peak, current PPO peak value, 1)
Calculation: Current price trough = valuewhen(price trough, low[1], 0)
Calculation: Current price peak = valuewhen(price peak, high[1], 0)
Calculation: Delayed price trough = price trough AND barssince(PPO trough) < delayed-extremum age parameter ? low[1] : na
Calculation: Delayed price peak = price peak AND barssince(PPO peak) < delayed-extremum age parameter ? high[1] : na
Calculation: Rolling price-trough filter = barssince(price trough) < price-filter age parameter ? lowest(current price trough, price-filter lookback) : na
Calculation: Rolling price-peak filter = barssince(price peak) < price-filter age parameter ? highest(current price peak, price-filter lookback) : na
Calculation: Second price-trough filter at PPO trough = valuewhen(PPO trough, rolling price-trough filter, 1)
Calculation: Second price-peak filter at PPO peak = valuewhen(PPO peak, rolling price-peak filter, 1)
Calculation: Prior long-term price-trough filter = valuewhen(price trough, lowest(low, divergence lookback), 1)
Calculation: Prior long-term price-peak filter = valuewhen(price peak, highest(high, divergence lookback), 1)
Calculation: Price at recent PPO trough = valuewhen(PPO trough, current price trough, 0)
Calculation: Price at recent PPO peak = valuewhen(PPO peak, current price peak, 0)
Long: RSI(close, entry RSI lookback) <= long-entry RSI threshold AND close >= SMA(close, long-entry SMA lookback) AND EMA(close, long-entry EMA lookback) != 0
Short: RSI(close, entry RSI lookback) >= short-entry RSI threshold AND close <= SMA(close, short-entry SMA lookback) AND EMA(close, short-entry EMA lookback) != 0
Exit: Long, EMA(close, long-exit EMA lookback) != 0 AND RSI(close, long-exit RSI lookback) >= long-exit RSI threshold
Exit: Short, low <= EMA(close, short-exit EMA lookback) AND RSI(close, short-exit RSI lookback) <= short-exit RSI threshold
Exit: Long, low <= entry price − stop-loss ticks OR high >= entry price + take-profit ticks OR (high since entry >= entry price + trailing activation ticks AND low <= highest high since activation − trailing offset ticks)
Exit: Short, high >= entry price + stop-loss ticks OR low <= entry price − take-profit ticks OR (low since entry <= entry price − trailing activation ticks AND high >= lowest low since activation + trailing offset ticks)
Long: change(SMA(MACD source, MACD very-slow lookback)) > 0
Short: change(SMA(MACD source, MACD very-slow lookback)) <= 0
Long: SMA(MACD source, MACD fast lookback) > SMA(MACD source, MACD slow lookback) AND change(SMA(MACD source, MACD very-slow lookback)) > 0 AND close > SMA(MACD source, MACD slow lookback)
Short: SMA(MACD source, MACD fast lookback) < SMA(MACD source, MACD slow lookback) AND change(SMA(MACD source, MACD very-slow lookback)) < 0 AND close < SMA(MACD source, MACD slow lookback)
Long: close > SMA(MACD source, MACD fast lookback) AND close > SMA(MACD source, MACD slow lookback) AND close > SMA(MACD source, MACD very-slow lookback) AND change(SMA(MACD source, MACD slow lookback)) > 0
Short: close < SMA(MACD source, MACD fast lookback) AND close < SMA(MACD source, MACD slow lookback) AND close < SMA(MACD source, MACD very-slow lookback) AND change(SMA(MACD source, MACD slow lookback)) < 0
Long: SMA(MACD source, MACD slow lookback) > SMA(MACD source, MACD very-slow lookback) AND crosses above(SMA-based MACD histogram, 0) AND MACD line > 0 AND SMA(MACD source, MACD fast lookback) > SMA(MACD source, MACD slow lookback) AND close[MACD slow lookback] > SMA(MACD source, MACD very-slow lookback)
Short: SMA(MACD source, MACD slow lookback) < SMA(MACD source, MACD very-slow lookback) AND crosses below(SMA-based MACD histogram, 0) AND MACD line < 0 AND SMA(MACD source, MACD fast lookback) < SMA(MACD source, MACD slow lookback) AND close[MACD slow lookback] < SMA(MACD source, MACD very-slow lookback)
Long: Ichimoku Span A(turning lookback, standard lookback) >= Ichimoku Span B(longer lookback), with turning lookback < standard lookback < longer lookback
Short: Ichimoku Span A(turning lookback, standard lookback) < Ichimoku Span B(longer lookback), with turning lookback < standard lookback < longer lookback
Long: RSI(close, overbought/oversold RSI lookback)[1] <= oversold threshold AND RSI(close, overbought/oversold RSI lookback) <= oversold threshold AND volume[1] >= volume
Short: RSI(close, overbought/oversold RSI lookback)[1] >= overbought threshold AND RSI(close, overbought/oversold RSI lookback) >= overbought threshold AND volume[1] >= volume
Long: EMA(close, bar-color fast lookback) − EMA(close, bar-color slow lookback) > (EMA(close, bar-color fast lookback) − EMA(close, bar-color slow lookback))[1], with bar-color fast lookback < bar-color slow lookback
Short: EMA(close, bar-color fast lookback) − EMA(close, bar-color slow lookback) <= (EMA(close, bar-color fast lookback) − EMA(close, bar-color slow lookback))[1], with bar-color fast lookback < bar-color slow lookback
Short: −(close − open) > bearish-engulf multiplier × (close − open)[1] AND (close − open)[1] > 0 AND (close − open)[2] > 0 AND close − open < 0
Long: close − open > −bullish-engulf multiplier × (close − open)[1] AND (close − open)[1] < 0 AND (close − open)[2] < 0 AND close − open > 0
Long: (close − open) × doji-small-body multiplier < abs(close − open) AND high − low > abs(close − open) × doji-range multiplier AND (close − open)[1] < 0
Short: (close − open) × doji-small-body multiplier < abs(close − open) AND high − low > abs(close − open) × doji-range multiplier AND (close − open)[1] > 0
Long: Pattern body × dragonfly-small-body multiplier < pattern body size AND lower wick × dragonfly-small-wick multiplier < pattern body size AND upper wick > pattern body size × dragonfly-wick-dominance multiplier AND Pattern body[1] < 0
Short: Pattern body × dragonfly-small-body multiplier < pattern body size AND upper wick × dragonfly-small-wick multiplier < pattern body size AND lower wick > pattern body size × dragonfly-wick-dominance multiplier AND Pattern body[1] > 0
Long: Pattern body > same-up body multiplier × pattern body size AND Pattern body[1] > same-up body multiplier × pattern body size[1] AND Pattern body[2] > same-up body multiplier × pattern body size[2] AND up candle
Short: Pattern body × same-down body multiplier < pattern body size AND pattern range > pattern body size × same-down range multiplier AND Pattern body[1] > 0
Long: low[2] < low AND low[2] < low[1] AND low[2] < low[3] AND low[2] < low[4] AND high[1] < max(high[3], high[2]) AND high > max(high[3], high[2]) OR low[1] < low AND low[1] < low[2] AND low[1] < low[3] AND high > max(high[2], high[1])
Short: high[2] > high AND high[2] >= high[1] AND high[2] > high[3] AND high[2] > high[4] AND low[1] > min(low[3], low[2]) AND low < min(low[3], low[2]) OR high[1] > high AND high[1] > high[2] AND high[1] > high[3] AND low < min(low[2], low[1])
Short: Price at recent PPO peak > second price-peak filter at PPO peak AND PPO peak AND current PPO peak value < previous PPO peak value OR delayed price peak > second price-peak filter at PPO peak AND current PPO peak value < previous PPO peak value OR long-term divergence setting enabled AND PPO peak AND current PPO peak value < highest(Smoothed PPO, divergence lookback) AND price at recent PPO peak > prior long-term price-peak filter OR long-term divergence setting enabled AND current PPO peak value < highest(Smoothed PPO, divergence lookback) AND delayed price peak > prior long-term price-peak filter
Long: Price at recent PPO trough < second price-trough filter at PPO trough AND PPO trough AND current PPO trough value > previous PPO trough value OR delayed price trough < second price-trough filter at PPO trough AND current PPO trough value > previous PPO trough value OR long-term divergence setting enabled AND PPO trough AND current PPO trough value > lowest(Smoothed PPO, divergence lookback) AND price at recent PPO trough < prior long-term price-trough filter OR long-term divergence setting enabled AND current PPO trough value > lowest(Smoothed PPO, divergence lookback) AND delayed price trough < prior long-term price-trough filter
Long: PPO trough AND Smoothed PPO[1] != 0
Short: PPO peak AND Smoothed PPO[1] != 0
Long: close > EMA(close, EMA-touch lookback) AND low <= EMA(close, EMA-touch lookback) AND open > EMA(close, EMA-touch lookback) OR open < EMA(close, EMA-touch lookback) AND close > EMA(close, EMA-touch lookback)
Short: close < EMA(close, EMA-touch lookback) AND high >= EMA(close, EMA-touch lookback) AND open < EMA(close, EMA-touch lookback) OR open > EMA(close, EMA-touch lookback) AND close < EMA(close, EMA-touch lookback)
Long: (pattern open <= pattern close OR pattern body size < minimum tick size/2) AND prior bearish sequence AND bullish harami core
Short: (pattern open >= pattern close OR pattern body size < minimum tick size/2) AND prior bullish sequence AND bearish harami core
Long: show-only-harami setting is off AND NOT bullish harami AND NOT bearish harami AND prior bearish sequence AND bullish harami core
Short: show-only-harami setting is off AND NOT bullish harami AND NOT bearish harami AND prior bullish sequence AND bearish harami core