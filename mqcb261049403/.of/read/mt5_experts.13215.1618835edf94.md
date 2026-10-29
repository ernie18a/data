Calculation: Center-of-gravity OSMA = MA2(X − MA1(X)), where X = SMA(price, P) × LWMA(price, P) / minimum price increment; price is the selected OHLC-derived price, and both price averages use the same lookback P. MA1 and MA2 use independently configurable smoothing lookbacks and methods. Compute on the chart timeframe using completed bars.
Long: OSMA two bars before the signal bar > OSMA one bar before the signal bar AND OSMA on the signal bar > OSMA one bar before the signal bar
Short: OSMA two bars before the signal bar < OSMA one bar before the signal bar AND OSMA on the signal bar < OSMA one bar before the signal bar
Exit: long, OSMA one bar before the signal bar > OSMA on the signal bar
Exit: short, OSMA one bar before the signal bar < OSMA on the signal bar