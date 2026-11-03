Calculation: Confirmed swing high/low = a high/low that is the highest/lowest over the swing lookback bars on each side; becomes available after the bars on both sides complete.
Calculation: Advanced bullish liquidity grab = current low < the latest confirmed swing low AND current close > that swing low AND (swing low − current low) > 1.1 × |open − close| AND |open − close| < 0.5 × (high − low) AND volume > 1.4 × 20-bar SMA(volume).
Calculation: Advanced bearish liquidity grab = current high > the latest confirmed swing high AND current close < that swing high AND (current high − swing high) > 1.1 × |open − close| AND |open − close| < 0.5 × (high − low) AND volume > 1.4 × 20-bar SMA(volume).
Calculation: Bullish effective engulfing = close > open AND prior close < prior open AND close > prior open AND open < prior close AND (current bar is a confirmed swing low OR prior close < current close).
Calculation: Bearish effective engulfing = close < open AND prior close > prior open AND close < prior open AND open > prior close AND (current bar is a confirmed swing high OR prior close > current close).
Calculation: Effective hammer = (high − low) > 3 × |open − close| AND both (close − low)/(0.001 + high − low) and (open − low)/(0.001 + high − low) > 0.6 AND prior bar range > 10-bar ATR.
Calculation: Effective shooting star = (high − low) > 3 × |open − close| AND both (high − close)/(0.001 + high − low) and (high − open)/(0.001 + high − low) > 0.6 AND (current bar is a confirmed swing high OR prior close > current close).
Calculation: Effective hanging man = hammer conditions AND (current bar is a confirmed swing high OR prior close > current close).
Calculation: Effective doji = |close − open| ≤ 0.1 × (high − low) AND volume > 1.5 × 20-bar SMA(volume).
Calculation: Effective morning star = bearish first candle, middle candle body ≤ 0.3 of its range, middle low ≤ first low, current candle bullish, current close ≥ midpoint of first candle, and current low > middle low; also current bar is a confirmed swing low OR prior close < current close.
Calculation: Effective evening star = bullish first candle, middle candle body ≤ 0.3 of its range, middle high ≥ first high, current candle bearish, current close ≤ midpoint of first candle, and current high < middle high; also current bar is a confirmed swing high OR prior close > current close.
Calculation: Effective piercing = current candle bearish AND prior candle bullish AND open < prior close AND close > prior open AND close < open AND prior close < current close.
Calculation: Bullish iceberg = volume > 1.5 × longer-lookback volume SMA AND high > low AND |close − open|/(high − low) < 0.18 AND close > open. Bearish iceberg uses the same conditions with close < open.
Calculation: Session volume = volume accumulated since the start of the current day.
Calculation: Volume participation condition = volume > session volume × the participation threshold.
Calculation: VWAP = session VWAP or cumulative volume-weighted close, according to the selected VWAP mode. TWAP = close SMA. Higher-timeframe VWAP = VWAP on a higher timeframe, using the last completed higher-timeframe bar.
Calculation: Bullish trend alignment = close > higher-timeframe VWAP AND close > VWAP AND close > TWAP. Bearish trend alignment uses close < each of those values.
Calculation: Strong bullish signal = advanced bullish liquidity grab AND bullish effective engulfing AND volume participation condition AND bullish iceberg AND bullish trend alignment. Strong bearish signal is the mirrored conjunction.
Calculation: Bullish smart-money/SSL reversal = an unmitigated equal-low pool is nearest to close, its distance from close < 0.5 × 3-bar ATR, and close > open AND (open − low) > 2 × |open − close| AND volume > 1.4 × 20-bar SMA(volume). Bearish smart-money/BSL reversal is mirrored: nearest unmitigated equal-high pool, same distance condition, close < open AND (high − close) > 2 × |open − close| AND volume > 1.4 × 20-bar SMA(volume).
Calculation: Equal-high/low pool = midpoint of two confirmed swing highs/lows whose price difference is within the selected tolerance and whose bars are separated by at least the selected minimum gap; tolerance is either ATR-based or a percentage of close. A pool is mitigated when close exceeds an equal-high pool plus tolerance, or falls below an equal-low pool minus tolerance.
Calculation: Lite bullish score = one point each for bullish trend alignment, advanced bullish liquidity grab, volume participation condition, bullish iceberg, and bullish effective engulfing. Lite bearish score is the mirrored sum. Directional lite scores omit the volume participation point. Net score = bullish score − bearish score.
Calculation: Lite bullish state = net score > 0, or net score = 0 with bullish score ≥ 1 and bullish directional lite score > bearish directional lite score. Lite bearish state is the mirrored condition. A lite trigger occurs when its state is true and was false on the prior bar.
Calculation: Signal history = the last two lite triggers that also have rising accumulation/distribution line for bullish triggers, or falling accumulation/distribution line for bearish triggers. Bias is bullish when bullish history count exceeds bearish count, bearish when bearish count exceeds bullish count, otherwise neutral.
Long: Advanced bullish liquidity grab.
Long: Bullish effective engulfing OR effective hammer OR effective morning star OR effective piercing.
Long: Bullish smart-money/SSL reversal.
Long: Bullish iceberg.
Long: Strong bullish signal.
Long: Lite bullish trigger AND accumulation/distribution line rising AND resulting signal-history bias is bullish AND prior signal-history bias was not bullish.
Short: Advanced bearish liquidity grab.
Short: Bearish effective engulfing OR effective shooting star OR effective hanging man OR effective evening star.
Short: Bearish smart-money/BSL reversal.
Short: Bearish iceberg.
Short: Strong bearish signal.
Short: Lite bearish trigger AND accumulation/distribution line falling AND resulting signal-history bias is bearish AND prior signal-history bias was not bearish.
Exit: long, signal-history bias changes from bullish to bearish OR from bullish to neutral.
Exit: short, signal-history bias changes from bearish to bullish OR from bearish to neutral.