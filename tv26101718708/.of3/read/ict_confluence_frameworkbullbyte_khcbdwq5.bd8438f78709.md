Calculation: Most recent confirmed pivot high = latest non-missing PivotHigh(high, pivot-left lookback, pivot-right confirmation); most recent confirmed pivot low = latest non-missing PivotLow(low, pivot-left lookback, pivot-right confirmation)
Calculation: Bullish sweep = current confirmed bar makes a new sweep of the most recent confirmed pivot low, with low below that pivot and no earlier sweep of that pivot
Calculation: Bearish sweep = current confirmed bar makes a new sweep of the most recent confirmed pivot high, with high above that pivot and no earlier sweep of that pivot
Calculation: Bullish sweep reclaim = after a bullish sweep, within the reclaim window and on a later confirmed bar, low <= swept pivot low AND close > swept pivot low
Calculation: Bearish sweep reclaim = after a bearish sweep, within the reclaim window and on a later confirmed bar, high >= swept pivot high AND close < swept pivot high
Calculation: Bullish stopping volume = current confirmed bar has volume >= the volume percentile at the stopping-volume percentile over the volume lookback AND that percentile > 0 AND (close - low) / (high - low) >= rejection ratio AND low <= lowest(low, stopping-volume extreme lookback)[1]
Calculation: Bearish stopping volume = current confirmed bar has volume >= the volume percentile at the stopping-volume percentile over the volume lookback AND that percentile > 0 AND (high - close) / (high - low) >= rejection ratio AND high >= highest(high, stopping-volume extreme lookback)[1]
Calculation: Bullish compression expansion = prior bar range <= lowest(high - low, compression lookback)[1] AND current bar range >= expansion multiplier * ATR(ATR lookback) AND close > open
Calculation: Bearish compression expansion = prior bar range <= lowest(high - low, compression lookback)[1] AND current bar range >= expansion multiplier * ATR(ATR lookback) AND close < open
Calculation: Bullish break of structure = close crosses above the most recent confirmed pivot high
Calculation: Bearish break of structure = close crosses below the most recent confirmed pivot low
Calculation: Bullish order block = prior bar is bearish AND current confirmed bar is bullish AND close - open >= impulse multiplier * ATR(ATR lookback); its zone is the prior bar's low-to-high range
Calculation: Bearish order block = prior bar is bullish AND current confirmed bar is bearish AND open - close >= impulse multiplier * ATR(ATR lookback); its zone is the prior bar's low-to-high range
Calculation: Bullish order-block mitigation = low is within the latest bullish order-block zone AND close > that zone's high
Calculation: Bearish order-block mitigation = high is within the latest bearish order-block zone AND close < that zone's low
Calculation: Bullish pattern count = number of enabled bullish sweep reclaims, stopping-volume patterns, compression expansions, breaks of structure, and order-block mitigations whose most recent occurrence is within the confluence window
Calculation: Bearish pattern count = number of enabled bearish sweep reclaims, stopping-volume patterns, compression expansions, breaks of structure, and order-block mitigations whose most recent occurrence is within the confluence window
Calculation: Required pattern count = min(maximum pattern count, max(minimum pattern parameter, ceil(minimum pattern parameter * active-phase multiplier))); active phase applies when the ATR percentile rank over the phase lookback reaches the active-phase boundary, and the multiplier is one otherwise
Calculation: Efficiency ratio = abs(close - close[regime lookback]) / sum(abs(close[i] - close[i + 1]), i = 0 to regime lookback - 1); regime is trend-up or trend-down when efficiency reaches the trend boundary and displacement has that sign, range when efficiency is below the range boundary, volatile when ATR percentile rank over twice the regime lookback reaches the volatility boundary, and neutral otherwise
Calculation: Pattern emphasis for each pattern type = one when adaptive emphasis is disabled; otherwise weight floor + (1 - weight floor) * that pattern type's follow-through rate. Follow-through rate is one-half below the minimum sample count and otherwise tracked wins divided by tracked observations; a win requires favorable excursion to reach the configured ATR threshold
Calculation: Bullish raw confluence score = sum of active bullish pattern emphasis weights, with expansion multiplied by its volatile-regime weight, break of structure multiplied by its base weight and range-regime weight, and the total multiplied by the countertrend weight in a downtrend
Calculation: Bearish raw confluence score = sum of active bearish pattern emphasis weights, with expansion multiplied by its volatile-regime weight, break of structure multiplied by its base weight and range-regime weight, and the total multiplied by the countertrend weight in an uptrend
Calculation: Bullish residual confluence score = bullish raw confluence score when positive; otherwise, if decay is enabled, max(0, prior bullish residual confluence score - decay decrement), or prior score when decay is disabled
Calculation: Bearish residual confluence score = bearish raw confluence score when positive; otherwise, if decay is enabled, max(0, prior bearish residual confluence score - decay decrement), or prior score when decay is disabled
Long: Bullish sweep OR bullish sweep reclaim
Short: Bearish sweep OR bearish sweep reclaim
Long: Bullish stopping volume
Short: Bearish stopping volume
Long: Bullish compression expansion
Short: Bearish compression expansion
Long: Bullish break of structure
Short: Bearish break of structure
Long: Bullish order block OR bullish order-block mitigation
Short: Bearish order block OR bearish order-block mitigation
Long: On confirmation of a pivot high, no preceding confirmed pivot high exists OR the new pivot high is higher than the preceding confirmed pivot high
Short: On confirmation of a pivot high, a preceding confirmed pivot high exists AND the new pivot high is equal to or lower than the preceding confirmed pivot high
Long: On confirmation of a pivot low, a preceding confirmed pivot low exists AND the new pivot low is equal to or higher than the preceding confirmed pivot low
Short: On confirmation of a pivot low, no preceding confirmed pivot low exists OR the new pivot low is lower than the preceding confirmed pivot low
Long: Current bar is confirmed AND data is warmed up AND no setup is active AND cooldown has elapsed AND bullish pattern count >= required pattern count AND bullish pattern count > bearish pattern count AND bearish residual confluence score < required pattern count AND (quiet mode is disabled OR bullish pattern count reaches the high-confluence threshold)
Short: Current bar is confirmed AND data is warmed up AND no setup is active AND cooldown has elapsed AND bearish pattern count >= required pattern count AND bearish pattern count > bullish pattern count AND bullish residual confluence score < required pattern count AND (quiet mode is disabled OR bearish pattern count reaches the high-confluence threshold)
Exit: long, after the entry bar, low <= entry price - invalidation ATR multiple * ATR at entry OR high >= entry price + target reward/risk multiple * invalidation ATR multiple * ATR at entry
Exit: short, after the entry bar, high >= entry price + invalidation ATR multiple * ATR at entry OR low <= entry price - target reward/risk multiple * invalidation ATR multiple * ATR at entry