Calculation: Opening range high/low = highest high and lowest low during each configured opening session; freeze when that session ends.
Calculation: EMA = exponential moving average of close; the fast EMA uses a shorter lookback than the slow EMA.
Calculation: VWAP = daily volume-weighted average of typical price (high + low + close) / 3.
Calculation: Volume average = simple moving average of volume over a configurable lookback.
Calculation: Vector volume and range ratios = current volume and (high − low), respectively, divided by their separate simple moving averages over the same configurable lookback.
Calculation: ATR = average true range over a configurable lookback.
Calculation: Opening-range quality score = clamp to 0–100 the rounded score based on opening-range size / ATR: within the configured minimum and maximum ratios, 100 − abs(ratio − 0.5) × 80; below minimum, ratio / minimum × 40; above maximum, max(0, 100 − ((ratio − maximum) / maximum)^1.5 × 150).
Calculation: Stop and target prices = entry price offset by configured stop distance and either configured target distance or configured multiple of opening-range size.
Calculation: Trap state = after a close beyond an opening-range boundary, detect a return close inside the range within a configurable number of bars; bullish breakout returning inside is a bull trap, bearish breakout returning inside is a bear trap.
Long: Close > opening-range high AND (EMA fast > EMA slow if EMA filter enabled) AND (close > VWAP if VWAP filter enabled) AND (last completed bar on each configured higher-timeframe confirmation interval closes > opening-range high if that filter is enabled) AND (higher-timeframe EMA fast > EMA slow on its last completed bar if that filter is enabled) AND (opening-range size within configured minimum and maximum if that filter is enabled) AND (quality score >= configured minimum if that filter is enabled) AND (bull trap retest sequence completed if retest filter is enabled) AND (first-signal-per-session, daily trade limit, and configured trading-time-window restrictions pass when enabled).
Short: Close < opening-range low AND (EMA fast < EMA slow if EMA filter enabled) AND (close < VWAP if VWAP filter enabled) AND (last completed bar on each configured higher-timeframe confirmation interval closes < opening-range low if that filter is enabled) AND (higher-timeframe EMA fast < EMA slow on its last completed bar if that filter is enabled) AND (opening-range size within configured minimum and maximum if that filter is enabled) AND (quality score >= configured minimum if that filter is enabled) AND (bear trap retest sequence completed if retest filter is enabled) AND (first-signal-per-session, daily trade limit, and configured trading-time-window restrictions pass when enabled).
Long: EMA fast crosses above EMA slow.
Short: EMA fast crosses below EMA slow.
Long: Close crosses above VWAP.
Short: Close crosses below VWAP.
Long: EMA fast > EMA slow on the last completed dashboard-timeframe bar (dashboard timeframes may be higher or lower than the chart timeframe).
Short: EMA fast < EMA slow on the last completed dashboard-timeframe bar (dashboard timeframes may be higher or lower than the chart timeframe).
Long: Bullish-condition count > bearish-condition count, where conditions are chart-timeframe EMA fast > EMA slow, close > VWAP, and higher-timeframe EMA fast > EMA slow on its last completed bar.
Short: Bearish-condition count > bullish-condition count, where conditions are chart-timeframe EMA fast < EMA slow, close < VWAP, and higher-timeframe EMA fast < EMA slow on its last completed bar.
Long: Close > open AND vector volume ratio >= light-volume threshold.
Short: Close < open AND vector volume ratio >= light-volume threshold.
Long: Close > open AND vector volume ratio >= elevated-volume threshold AND vector volume ratio < climax-volume threshold.
Short: Close < open AND vector volume ratio >= elevated-volume threshold AND vector volume ratio < climax-volume threshold.
Long: Close > open AND vector volume ratio >= climax-volume threshold AND vector range ratio >= configured range threshold.
Short: Close < open AND vector volume ratio >= climax-volume threshold AND vector range ratio >= configured range threshold.
Long: A prior close broke below opening-range low, then within the configured bar limit a later close returned inside the opening range.
Short: A prior close broke above opening-range high, then within the configured bar limit a later close returned inside the opening range.
Exit: Long, low <= stop price OR high >= target price OR configured forced-close time window is active.
Exit: Short, high >= stop price OR low <= target price OR configured forced-close time window is active.