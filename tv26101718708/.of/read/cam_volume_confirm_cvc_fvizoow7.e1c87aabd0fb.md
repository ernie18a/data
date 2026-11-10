Calculation: Volume power = Let direction be (close − open) / (high − low), or zero when high = low. Let volume weight be volume^(1 − volume boost) when volume > 0, otherwise zero, multiplied by volume factor, plus (1 − volume factor). Let raw power be direction × volume weight. Divide raw power by the Wilder RMA of its absolute value, or use raw power unchanged if that RMA is zero; multiply by 100 and clamp to [−100, 100]. Apply a separate Wilder RMA, then optionally apply an SMA, EMA, Wilder RMA, HMA, or WMA with its own length. The scaling RMA length is a configurable number of days multiplied by max(1, round(23400 / chart bar duration in seconds)).
Long: Volume power >= positive power threshold AND RSI of close >= RSI midpoint
Short: Volume power <= negative weakness threshold AND RSI of close < RSI midpoint
Long: Volume power >= positive power threshold
Short: Volume power <= negative weakness threshold
Long: RSI of close >= RSI midpoint
Short: RSI of close < RSI midpoint
Long: Volume power >= positive power threshold AND RSI of close < RSI midpoint AND previous volume power < positive power threshold
Long: RSI of close >= RSI midpoint AND volume power < positive power threshold AND previous RSI of close < RSI midpoint
Short: Volume power <= negative weakness threshold AND RSI of close >= RSI midpoint AND previous volume power > negative weakness threshold
Short: RSI of close < RSI midpoint AND volume power > negative weakness threshold AND previous RSI of close >= RSI midpoint
Long: RSI of close > RSI midpoint AND previous RSI of close <= RSI midpoint AND volume power < positive power threshold
Short: RSI of close < RSI midpoint AND previous RSI of close >= RSI midpoint AND volume power > negative weakness threshold