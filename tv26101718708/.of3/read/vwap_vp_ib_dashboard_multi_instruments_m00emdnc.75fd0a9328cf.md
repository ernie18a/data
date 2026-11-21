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