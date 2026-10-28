Calculation: Kernel regression = linear regression of close over one lookback; slope = current value − prior bar value
Calculation: VWAP = session VWAP of close or, if rolling mode is selected, SMA of hlc3; slope = current value − prior bar value
Calculation: Cumulative volume delta = cumulative sum of volume on up bars minus volume on down bars (zero on doji bars)
Calculation: Candle body ratio = abs(close − open) / (high − low), or zero when high = low
Calculation: Initial stop = for long, entry price minus ATR × multiplier, the lower of the lookback swing low and entry price minus ATR × multiplier, or entry price minus fixed distance; for short, entry price plus ATR × multiplier, the higher of the lookback swing high and entry price plus ATR × multiplier, or entry price plus fixed distance, according to the selected stop type
Calculation: Risk distance = entry price − initial stop for long; initial stop − entry price for short
Calculation: Targets = entry price ± risk distance × target reward/risk ratio (plus for long, minus for short)
Calculation: Active stop = initial stop until trailing activates, then the trailing stop; trailing activates when favorable close movement reaches the configured activation reward/risk multiple and follows the close by the configured trailing reward/risk multiple, moving only in the favorable direction
Long: close > kernel regression AND kernel regression slope > 0 AND close > VWAP AND VWAP slope > 0 AND cumulative volume delta > its SMA AND cumulative volume delta > each of its prior two bars AND RSI > oversold threshold AND RSI < overbought threshold AND (volume > its SMA × spike threshold OR volume > prior bar volume > volume two bars ago) AND close > open AND candle body ratio ≥ minimum AND high − low ≥ minimum candle size AND close ≥ high − 0.25 × (high − low) AND trading time is within the configured session and after the configured initial bars AND flat position AND daily trade, consecutive loss, daily loss, and daily profit limits are not reached AND long entries are enabled
Short: close < kernel regression AND kernel regression slope < 0 AND close < VWAP AND VWAP slope < 0 AND cumulative volume delta < its SMA AND cumulative volume delta < each of its prior two bars AND RSI < overbought threshold AND RSI > oversold threshold AND (volume > its SMA × spike threshold OR volume > prior bar volume > volume two bars ago) AND close < open AND candle body ratio ≥ minimum AND high − low ≥ minimum candle size AND close ≤ low + 0.25 × (high − low) AND trading time is within the configured session and after the configured initial bars AND flat position AND daily trade, consecutive loss, daily loss, and daily profit limits are not reached AND short entries are enabled
Exit: long, low ≤ active stop
Exit: long, high ≥ first target AND first target has not already been reached
Exit: long, high ≥ second target
Exit: long, current time ≥ configured session end minus five minutes
Exit: long, first target has been reached AND ((close < kernel regression AND kernel regression slope < 0) OR close < VWAP)
Exit: short, high ≥ active stop
Exit: short, low ≤ first target AND first target has not already been reached
Exit: short, low ≤ second target
Exit: short, current time ≥ configured session end minus five minutes
Exit: short, first target has been reached AND ((close > kernel regression AND kernel regression slope > 0) OR close > VWAP)