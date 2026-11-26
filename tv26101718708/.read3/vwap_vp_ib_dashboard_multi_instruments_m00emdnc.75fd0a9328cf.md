Calculation: VWAP(anchor) = sum(OHLC4 × volume) ÷ sum(volume) over chart bars from the latest anchor bar through the current bar; anchor T1 = chart bar where the open time of the last completed T1 bar changes; anchor session = first chart bar of each session window (Tokyo, London, RTH), summing only bars inside a session window
Calculation: VWAPBand(anchor, side) = VWAP(anchor) + band multiplier × σ for side upper, VWAP(anchor) − band multiplier × σ for side lower, where σ = sqrt(max(0, sum(OHLC4² × volume) ÷ sum(volume) − VWAP(anchor)²)) over the same bars as VWAP(anchor)
Calculation: ValueArea(anchor) = [VAH, VAL] of a volume profile with row count rows spanning [mid − range multiplier × R, mid + range multiplier × R], where mid = (high + low) ÷ 2 and R = max(high − low, minimum range) of the latest anchor bar; each chart bar from the latest anchor bar adds its volume to each row its high–low overlaps, in proportion to overlap ÷ (high − low); starting from the row with the largest volume, repeatedly add the larger of the row above and the row below (ties: above) until accumulated volume ≥ value area percent × total volume; VAH = top of the highest added row; VAL = bottom of the lowest added row; anchor shifted T1 = chart bar where floor((bar time − day offset) ÷ T1 duration) changes; anchor session = first chart bar of each session window (Tokyo, London, RTH), summing only bars inside a session window
Calculation: InitialBalance(IB window) = [max high, min low] of chart bars inside the IB window, restarted at each IB window open and kept after the window closes until the next open
Long: close >= VWAP(T1)
Short: close < VWAP(T1)
Long: close > VWAPBand(T1, upper)
Short: close < VWAPBand(T1, lower)
Long: close >= VWAP(session) AND any session window active
Short: close < VWAP(session) AND any session window active
Long: close > VWAPBand(session, upper) AND any session window active
Short: close < VWAPBand(session, lower) AND any session window active
Long: close > VAH of ValueArea(shifted T1)
Short: close < VAL of ValueArea(shifted T1)
Long: close > VAH of ValueArea(session) AND any session window active
Short: close < VAL of ValueArea(session) AND any session window active
Long: close > high of InitialBalance(IB window) AND not within IB window
Short: close < low of InitialBalance(IB window) AND not within IB window
Calculation: in session = in W1 OR in W2 OR in W3
Calculation: profile range(I, A) = midpoint of the first bar of A +/- P5 * max(range of that bar, P6 ticks)
Calculation: value area high(I, A) = upper edge of the value area of a P3-row volume profile of I since A over profile range(I, A), where each bar's volume is divided among rows by price overlap, the value area starts at the highest-volume row and grows one row at a time toward the larger adjacent row (ties upward) until it holds P2 percent of total volume
Calculation: value area low(I, A) = lower edge of the same value area
Long: close(I1) >= VWAP(ohlc4 of I1, reset at T1)
Short: close(I1) < VWAP(ohlc4 of I1, reset at T1)
Long: close(I1) > upper VWAP band(ohlc4 of I1, reset at T1, multiplier P1)
Short: close(I1) < lower VWAP band(ohlc4 of I1, reset at T1, multiplier P1)
Long: in session AND close(I1) >= VWAP(ohlc4 of I1, reset at current session window start)
Short: in session AND close(I1) < VWAP(ohlc4 of I1, reset at current session window start)
Long: in session AND close(I1) > upper VWAP band(ohlc4 of I1, reset at current session window start, multiplier P1)
Short: in session AND close(I1) < lower VWAP band(ohlc4 of I1, reset at current session window start, multiplier P1)
Long: close(I1) > value area high(I1, Globex day at offset P4)
Short: close(I1) < value area low(I1, Globex day at offset P4)
Long: in session AND close(I1) > value area high(I1, current session window start)
Short: in session AND close(I1) < value area low(I1, current session window start)
Long: after latest W4 window ends AND close(I1) > Initial Balance high of I1 over latest W4 window
Short: after latest W4 window ends AND close(I1) < Initial Balance low of I1 over latest W4 window
Long: close(I2) >= VWAP(ohlc4 of I2, reset at T1)
Short: close(I2) < VWAP(ohlc4 of I2, reset at T1)
Long: close(I2) > upper VWAP band(ohlc4 of I2, reset at T1, multiplier P1)
Short: close(I2) < lower VWAP band(ohlc4 of I2, reset at T1, multiplier P1)
Long: in session AND close(I2) >= VWAP(ohlc4 of I2, reset at current session window start)
Short: in session AND close(I2) < VWAP(ohlc4 of I2, reset at current session window start)
Long: in session AND close(I2) > upper VWAP band(ohlc4 of I2, reset at current session window start, multiplier P1)
Short: in session AND close(I2) < lower VWAP band(ohlc4 of I2, reset at current session window start, multiplier P1)
Long: close(I2) > value area high(I2, Globex day at offset P4)
Short: close(I2) < value area low(I2, Globex day at offset P4)
Long: in session AND close(I2) > value area high(I2, current session window start)
Short: in session AND close(I2) < value area low(I2, current session window start)
Long: after latest W4 window ends AND close(I2) > Initial Balance high of I2 over latest W4 window
Short: after latest W4 window ends AND close(I2) < Initial Balance low of I2 over latest W4 window
Long: close(I3) >= VWAP(ohlc4 of I3, reset at T1)
Short: close(I3) < VWAP(ohlc4 of I3, reset at T1)
Long: close(I3) > upper VWAP band(ohlc4 of I3, reset at T1, multiplier P1)
Short: close(I3) < lower VWAP band(ohlc4 of I3, reset at T1, multiplier P1)
Long: in session AND close(I3) >= VWAP(ohlc4 of I3, reset at current session window start)
Short: in session AND close(I3) < VWAP(ohlc4 of I3, reset at current session window start)
Long: in session AND close(I3) > upper VWAP band(ohlc4 of I3, reset at current session window start, multiplier P1)
Short: in session AND close(I3) < lower VWAP band(ohlc4 of I3, reset at current session window start, multiplier P1)
Long: close(I3) > value area high(I3, Globex day at offset P4)
Short: close(I3) < value area low(I3, Globex day at offset P4)
Long: in session AND close(I3) > value area high(I3, current session window start)
Short: in session AND close(I3) < value area low(I3, current session window start)
Long: after latest W4 window ends AND close(I3) > Initial Balance high of I3 over latest W4 window
Short: after latest W4 window ends AND close(I3) < Initial Balance low of I3 over latest W4 window