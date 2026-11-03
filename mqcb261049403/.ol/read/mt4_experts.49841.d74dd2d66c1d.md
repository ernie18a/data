Calculation: Custom RSI = 100 − 100/(1 + total positive close-to-close changes / total absolute negative close-to-close changes) over the configured lookback on the configured RSI timeframe, including its still-forming bar; if either total is zero, RSI = 0. That timeframe may be higher, lower, or equal to the chart timeframe.
Long: Custom RSI <= lower threshold AND no open long position
Short: Custom RSI >= upper threshold AND no open short position
Long: Ask <= last long entry price − grid spacing
Short: Bid >= last short entry price + grid spacing
Exit: Long, Bid >= basket break-even price + take-profit distance OR Bid <= basket break-even price − stop-loss distance OR Bid <= active trailing or breakeven stop
Exit: Short, Ask <= basket break-even price − take-profit distance OR Ask >= basket break-even price + stop-loss distance OR Ask >= active trailing or breakeven stop