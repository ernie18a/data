Calculation: Swing high and swing low = on each chart bar, set swing state to high when high[swing lookback] > Highest(high, swing lookback); otherwise set it to low when low[swing lookback] < Lowest(low, swing lookback); otherwise retain the state. When the state changes to high or low, respectively store high[swing lookback] or low[swing lookback] and its chart-bar index as the latest swing level and reset that level's crossed flag.
Calculation: Active bullish and bearish order blocks = on the first bar with close > an uncrossed latest swing high, mark it crossed and add a bullish zone using the selected high and low (body extrema when the body-source parameter is enabled, otherwise full-bar extrema) of the bar with the lowest selected low among bars after that swing high through the prior chart bar; on the first bar with close < an uncrossed latest swing low, mark it crossed and add a bearish zone using the selected high and low of the bar with the highest selected high in the corresponding range. For ties, use the oldest matching bar. Remove bullish zones when min(open, close) < zone bottom and bearish zones when max(open, close) > zone top; use the newest remaining zone of each side.
Calculation: Bullish structure = a latest swing high exists and close > that swing high.
Calculation: Bearish structure = a latest swing low exists and close < that swing low.
Calculation: Near bullish order block = a valid active bullish order block exists and its bottom <= close <= its top.
Calculation: Near bearish order block = a valid active bearish order block exists and its bottom <= close <= its top.
Calculation: Bullish rejection = close > open AND high - max(open, close) > (max(open, close) - min(open, close)) * wick-rejection parameter AND high - max(open, close) >= (high - low) * minimum-wick parameter.
Calculation: Bearish rejection = close < open AND min(open, close) - low > (max(open, close) - min(open, close)) * wick-rejection parameter AND min(open, close) - low >= (high - low) * minimum-wick parameter.
Calculation: Bullish order-block sweep = low < active bullish order-block bottom AND close > active bullish order-block bottom.
Calculation: Bearish order-block sweep = high > active bearish order-block top AND close < active bearish order-block top.
Calculation: Bullish divergence = ROC(close, shorter ROC lookback) > ROC(close, longer ROC lookback) AND ROC(close, shorter ROC lookback) > its value on the previous chart bar AND close < close on the previous chart bar.
Calculation: Bearish divergence = ROC(close, shorter ROC lookback) < ROC(close, longer ROC lookback) AND ROC(close, shorter ROC lookback) < its value on the previous chart bar AND close > close on the previous chart bar.
Calculation: Volume pressure = volume / SMA(volume, volume-pressure lookback).
Calculation: Bullish volume pressure = volume pressure > volume-pressure ratio parameter AND close > open.
Calculation: Bearish volume pressure = volume pressure > volume-pressure ratio parameter AND close < open.
Calculation: Acceleration = (close - close on the previous chart bar) - 2 * (close on the previous chart bar - close two chart bars ago) + (close two chart bars ago - close three chart bars ago).
Calculation: Early bullish signal = (bullish divergence OR (bullish volume pressure) OR ((close - low) > (high - close) * imbalance-ratio parameter AND volume > SMA(volume, volume-pressure lookback))) AND acceleration > 0 AND close > close on the previous chart bar.
Calculation: Early bearish signal = (bearish divergence OR (bearish volume pressure) OR ((high - close) > (close - low) * imbalance-ratio parameter AND volume > SMA(volume, volume-pressure lookback))) AND acceleration < 0 AND close < close on the previous chart bar.
Calculation: Gold-futures volume confirmation = gold futures volume from the current chart timeframe, sampled on chart bars and including the still-forming bar, divided by SMA of that volume over the gold-volume lookback parameter > the volume-multiplier parameter OR gold futures volume > that SMA * the above-average-volume parameter OR gold futures volume is rising over the gold-volume rising lookback parameter.
Calculation: Normalized momentum = (close - close[displacement lookback]) / ATR(slower ATR lookback); use a shorter lookback for fast ATR than for slow ATR.
Calculation: Bullish impulse = (early bullish signal OR normalized momentum > normalized-momentum threshold) AND (bullish structure OR bullish divergence).
Calculation: Bearish impulse = (early bearish signal OR normalized momentum < -normalized-momentum threshold) AND (bearish structure OR bearish divergence).
Calculation: Active order-block strength = minimum of the strength-cap parameter and (active order-block width / ATR(shorter ATR lookback)) * strength-scale parameter.
Calculation: Quant score = round(structure-score parameter if bullish structure OR bearish structure else zero + order-block-presence-score parameter if near bullish OR near bearish order block else zero + order-block-strength-score parameter if bullish or bearish active order-block strength > order-block-strength threshold else fallback-strength-score parameter + rejection-score parameter if bullish or bearish rejection else zero + volume-score parameter if gold-futures volume confirmation else zero + liquidity-sweep-score parameter if bullish or bearish order-block sweep else zero + trend-alignment-score parameter if (close > SMA(close, SMA lookback) AND bullish structure) OR (close < SMA(close, SMA lookback) AND bearish structure) else zero + session-score parameter if hour(datetime) is between the inclusive session-start-hour and session-end-hour parameters else zero + momentum-score parameter if abs(close - close[displacement lookback]) > ATR(momentum-and-range lookback) * momentum-strength parameter else zero + choppiness-adjustment parameter if (high - low) / ATR(momentum-and-range lookback) < normalized-range threshold else zero + reversal-bonus parameter if (close on the previous chart bar > open on the previous chart bar AND close < open) OR (close on the previous chart bar < open on the previous chart bar AND close > open) else zero + impulse-score parameter if bullish or bearish impulse, else early-signal-score parameter if early bullish or bearish signal, else normalized-momentum-score parameter if abs(normalized momentum) > normalized-momentum threshold, else divergence-score parameter if bullish or bearish divergence, else zero + volume-pressure-bonus parameter if bullish or bearish volume pressure else zero).
Long: bullish structure.
Short: bearish structure AND NOT bullish structure.
Long: near bullish order block.
Short: near bearish order block AND NOT near bullish order block.
Long: bullish rejection.
Short: bearish rejection.
Long: bullish order-block sweep.
Short: bearish order-block sweep.
Long: bullish divergence.
Short: bearish divergence.
Long: early bullish signal.
Short: early bearish signal.
Long: bullish impulse.
Short: bearish impulse AND NOT bullish impulse.
Long: normalized momentum > 0.
Short: normalized momentum <= 0.
Long: quant score >= signal-threshold parameter AND bullish structure AND close > SMA(close, SMA lookback).
Short: quant score >= signal-threshold parameter AND bearish structure AND close < SMA(close, SMA lookback).