Calculation: Relative volume = volume divided by its simple moving average, or zero if the average is not positive.
Calculation: Body efficiency = absolute value of close minus open divided by high minus low; use zero when high equals low.
Calculation: Close position = (close minus low) divided by high minus low; use zero when high equals low.
Calculation: Buyer strength = close position multiplied by body efficiency.
Calculation: Seller strength = (1 minus close position) multiplied by body efficiency.
Calculation: Upper wick = high minus the greater of open and close; lower wick = the lesser of open and close minus low. Wick fractions divide the respective wick by high minus low; use zero when high equals low.
Long: Relative volume >= event threshold AND buyer strength >= dominance threshold AND buyer strength > seller strength.
Short: Relative volume >= event threshold AND seller strength >= dominance threshold AND seller strength > buyer strength.
Long: Relative volume >= event threshold AND body efficiency <= battle threshold AND lower wick fraction >= wick-fraction threshold, where the battle threshold is less than the dominance threshold.
Short: Relative volume >= event threshold AND body efficiency <= battle threshold AND upper wick fraction >= wick-fraction threshold, where the battle threshold is less than the dominance threshold.
Long: For every bar in the wick-sequence lookback, lower wick > 0 AND lower wick > upper wick AND the highest low minus the lowest low over that lookback <= price tolerance AND the current candle body does not contain the lowest low of the lookback.
Short: For every bar in the wick-sequence lookback, upper wick > 0 AND upper wick > lower wick AND the highest high minus the lowest high over that lookback <= price tolerance AND the current candle body does not contain the highest high of the lookback.
Long: Shorter-period EMA of close crosses above longer-period EMA of close.
Short: Shorter-period EMA of close crosses below longer-period EMA of close.