Calculation: Previous-period close (PDC) = close of the last completed bar of the selected level timeframe, which is higher than or equal to the chart timeframe.
Calculation: ATR = average true range over a lookback of the selected level timeframe, using only completed bars.
Calculation: Upper/lower trigger = PDC +/- trigger share × ATR; entry buffer, if enabled, is added beyond the trigger.
Calculation: Upper/lower 38.2%, 50%, 61.8%, 78.6%, and 1 ATR levels = PDC +/- the corresponding ATR fraction.
Calculation: EMA8 = 8-period exponential moving average of close on a timeframe higher than or equal to the chart timeframe, using the last completed bar.
Long: Confirmed close crosses above the buffered upper trigger from at or below it AND the signal session and chart timeframe are allowed AND long position is inactive AND entry budget remains AND cooldown has elapsed.
Short: Confirmed close crosses below the buffered lower trigger from at or above it AND the signal session and chart timeframe are allowed AND short position is inactive AND entry budget remains AND cooldown has elapsed.
Long: Long position active AND the confirmed close first crosses above the upper 38.2% level.
Short: Short position active AND the confirmed close first crosses below the lower 38.2% level.
Long: Long position active AND upper 38.2% has been reached AND low <= upper trigger AND confirmed close > upper trigger.
Short: Short position active AND lower 38.2% has been reached AND high >= lower trigger AND confirmed close < lower trigger.
Long: Long position active AND upper 38.2% has been reached AND close <= upper 61.8% AND low <= EMA8 AND confirmed close > EMA8.
Short: Short position active AND lower 38.2% has been reached AND close >= lower 61.8% AND high >= EMA8 AND confirmed close < EMA8.
Long: During the first session hour, a completed bar from a timeframe lower than or equal to the chart timeframe closes above PDC, the preceding completed bar closes at or below PDC, and that preceding close is at or above the lower trigger.
Short: During the first session hour, a completed bar from a timeframe lower than or equal to the chart timeframe closes below PDC, the preceding completed bar closes at or above PDC, and that preceding close is at or below the upper trigger.
Exit: Long, confirmed close < upper trigger.
Exit: Short, confirmed close > lower trigger.
Exit: Long, close >= upper 61.8% level (scale out at least half).
Exit: Short, close <= lower 61.8% level (scale out at least half).
Exit: Long, close >= upper 78.6% level (trail remaining position stop to upper 61.8% level).
Exit: Short, close <= lower 78.6% level (trail remaining position stop to lower 61.8% level).
Exit: Long, close >= upper 1 ATR level (exit remaining position).
Exit: Short, close <= lower 1 ATR level (exit remaining position).