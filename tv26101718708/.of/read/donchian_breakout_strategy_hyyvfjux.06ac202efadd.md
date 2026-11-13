Calculation: UpperBand = highest high over a long lookback
Calculation: LowerBand = lowest low over a lookback shorter than UpperBand's
Calculation: TightBand = lowest low over a lookback shorter than LowerBand's (optional tighter initial stop)
Calculation: ADR = simple average, over a fixed number of bars, of (high-low)/|low|*100 on a higher-timeframe bar (last completed bar)
Calculation: Stop = LowerBand. With the optional tight stop: while in a long and entry price > TightBand, Stop = TightBand; once entry price <= TightBand, hold the last TightBand value as Stop, but replace Stop with LowerBand whenever LowerBand > Stop
Calculation: Trigger = high for entry and low for exit (or close for both, as a variant)
Long: Trigger(high) >= UpperBand of the previous bar (excluding the current bar) AND, each only if enabled: UpperBand > MA(close) on the chart timeframe; UpperBand > MA(close) on a higher timeframe (last completed bar); (UpperBand-LowerBand)/UpperBand*100 < a set percentage of ADR; MA(close) on a higher timeframe (last completed bar) is rising versus its previous bar
Exit: Long, Trigger(low) <= Stop of the previous bar