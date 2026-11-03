Calculation: Opening delta = volume delta aggregated from lower-timeframe bars within the current chart bar; if it is zero and candle-volume fallback is enabled, use +volume when close > open, −volume when close < open, otherwise +volume when close > previous close, −volume when close < previous close, else 0
Calculation: RVOL = volume / moving average of volume over a long lookback
Calculation: Candle quality = if delta > 0: (close − low) / max(high − low, minimum tick) + abs(close − open) / max(high − low, minimum tick) + 0.5 × (min(open, close) − low) / max(high − low, minimum tick); if delta < 0: 1 − (close − low) / max(high − low, minimum tick) + abs(close − open) / max(high − low, minimum tick) + 0.5 × (high − max(open, close)) / max(high − low, minimum tick); otherwise 1
Calculation: Bull/bear pressure = in-session positive/negative delta’s absolute value × (max(RVOL, 0.25) if RVOL weighting is enabled, else 1) × (max(candle quality, 0.25) if candle-quality weighting is enabled, else 1); each side’s accumulated pressure decays by the configured per-bar percentage before adding current pressure
Calculation: Dominance = 100 × (bull pressure − bear pressure) / (bull pressure + bear pressure), or 0 when total pressure is zero; buyer control when dominance exceeds the configured positive threshold, seller control when it is below the corresponding negative threshold
Calculation: Opening threshold = max(abs(opening delta), 1) on the first session bar; opening side is the sign of opening delta
Calculation: Bull/bear challenge = in session, delta has that side’s sign, and abs(delta) is at least opening threshold × the configured challenge factor
Calculation: Superior bull/bear delta = in session, not the first session bar, delta has that side’s sign, abs(delta) is at least opening threshold × the configured superior factor, candle quality meets its configured minimum, and RVOL meets its configured minimum
Calculation: Daily supply/demand zones = after each completed daily bar, divide its high-low range into configured equal levels; accumulate volume of samples whose highs fall in each descending level for supply, or whose lows fall in each ascending level for demand. A zone spans the day’s extreme to the first level where accumulated volume exceeds the configured percentage of daily volume. Keep zones active until a later close is above supply’s top or below demand’s bottom, respectively
Long: First session bar and opening delta > 0
Long: In session and (delta > 0 OR buyer control OR dominance changed from below 0 to at least the configured positive flip threshold OR bull challenge OR superior bull delta)
Long: A prior-bar-or-older active demand zone is touched (high >= zone bottom AND low <= zone top), and close > zone top; the zone is untested when the untested-zones filter is enabled; AND the preceding in-session delta confirmation holds; AND seller control is absent when opposite-control blocking is enabled; AND the number of bars since the previous long signal exceeds the configured cooldown
Long: Superior bull delta
Long: In session, dominance on the prior bar < 0 and current dominance >= the configured positive flip threshold
Long: Bull challenge
Short: First session bar and opening delta < 0
Short: In session and (delta < 0 OR seller control OR dominance changed from above 0 to at most the configured negative flip threshold OR bear challenge OR superior bear delta)
Short: A prior-bar-or-older active supply zone is touched (high >= zone bottom AND low <= zone top), and close < zone bottom; the zone is untested when the untested-zones filter is enabled; AND the preceding in-session delta confirmation holds; AND buyer control is absent when opposite-control blocking is enabled; AND the number of bars since the previous short signal exceeds the configured cooldown
Short: Superior bear delta
Short: In session, dominance on the prior bar > 0 and current dominance <= the configured negative flip threshold
Short: Bear challenge