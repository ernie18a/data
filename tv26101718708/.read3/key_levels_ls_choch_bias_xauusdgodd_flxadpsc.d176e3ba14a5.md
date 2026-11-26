Calculation: Swing high = max(high of two consecutive bars) when the older bar closes above its open and the newer bar closes below its open
Calculation: Swing low = min(low of two consecutive bars) when the older bar closes below its open and the newer bar closes above its open
Calculation: Structure bias(T1/T2) = on chart bars, use each timeframe's last completed bar and the latest Swing high/low from completed bars; initialize neutral, set bullish when close > latest Swing high, then set bearish when close < latest Swing low, otherwise retain the prior bias (bearish wins if both); T1 is shorter than T2
Long: Structure bias(T1) is bullish
Short: Structure bias(T1) is bearish
Long: Structure bias(T2) is bullish
Short: Structure bias(T2) is bearish
Long: combined bias is bullish when Structure bias(T2) is bullish, or when Structure bias(T2) is neutral and Structure bias(T1) is bullish
Short: combined bias is bearish when Structure bias(T2) is bearish, or when Structure bias(T2) is neutral and Structure bias(T1) is bearish
Long: a tracked, unswept low key level is swept by a wick below it when the sweep mode permits wicks, or by a close below it followed within the double-close window by a close above it when the mode permits close sweeps, and a latest chart-bar Swing high exists
Short: a tracked, unswept high key level is swept by a wick above it when the sweep mode permits wicks, or by a close above it followed within the double-close window by a close below it when the mode permits close sweeps, and a latest chart-bar Swing low exists
Long: after a low-level sweep, close > its chart-bar Swing high reference within the ChoCh window, and, if invalidation is enabled, no close < the sweep-bar low
Short: after a high-level sweep, close < its chart-bar Swing low reference within the ChoCh window, and, if invalidation is enabled, no close > the sweep-bar high