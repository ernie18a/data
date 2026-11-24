Calculation: IB high = highest high of chart bars in the configured initial-balance interval beginning at the configured session start
Calculation: IB low = lowest low of chart bars in the configured initial-balance interval beginning at the configured session start
Calculation: Locked ATR = ATR(lookback, T1, last completed bar), sampled on chart bars and fixed when the initial balance completes
Calculation: BO reset buffer = locked ATR × reset-buffer multiple, or IB range × reset-buffer multiple if locked ATR is unavailable
Calculation: IB extension high = IB high + IB range × extension fraction parameter; IB extension low = IB low − IB range × extension fraction parameter
Calculation: Prior-session POC, VAH, and VAL = build a volume profile from T2 sub-bars on chart bars within the configured profile session window; distribute each sub-bar's volume equally among the price bins from floor(low / bin width) through floor(high / bin width), ignoring bins outside the fixed-capacity range beginning at floor(session-reset close / bin width) − half the profile bin count; bin width is max(ATR(lookback, T1, last completed bar) / bin divisor, minimum tick), a configured manual price width, or tick count × minimum tick; the lowest-price bin with maximum volume is POC; expand the value area contiguously from POC until it contains total profile volume × value-area percentage, adding the adjacent bin with greater volume first and the lower bin on ties; POC is the bin center, VAH the upper edge, and VAL the lower edge; use completed prior-session data
Calculation: Trend-long stop = locked ATR available ? entry price − min(entry price − IB low, locked ATR × trend-stop cap multiple) : IB low
Calculation: Trend-short stop = locked ATR available ? entry price + min(IB high − entry price, locked ATR × trend-stop cap multiple) : IB high
Calculation: Fade-short stop = prior-session VAH + (locked ATR available ? locked ATR × fade-stop buffer multiple : (VAH − VAL) × fallback VA-width fraction)
Calculation: Fade-long stop = prior-session VAL − (locked ATR available ? locked ATR × fade-stop buffer multiple : (VAH − VAL) × fallback VA-width fraction)
Long: IB is complete AND close > IB high AND this is the first close above IB high since the session reset or the latest close < IB high − BO reset buffer
Short: IB is complete AND close < IB low AND this is the first close below IB low since the session reset or the latest close > IB low + BO reset buffer
Short: IB is complete AND an IB-high breakout signal is pending AND close < IB high AND close[1] >= IB high
Long: IB is complete AND an IB-low breakdown signal is pending AND close > IB low AND close[1] <= IB low
Short: IB is complete AND prior-session VAH and POC exist AND this is the first qualifying bar of the session with high >= prior-session VAH AND close < prior-session VAH AND close > prior-session POC
Long: IB is complete AND prior-session VAL and POC exist AND this is the first qualifying bar of the session with low <= prior-session VAL AND close > prior-session VAL AND close < prior-session POC
Long: IB is complete AND this is the first bar of the session with high >= IB extension high AND low has not reached IB extension low during the session
Short: IB is complete AND this is the first bar of the session with low <= IB extension low AND high has not reached IB extension high during the session
Exit: long, for trend-breakout entries, low <= trend-long stop OR high >= IB extension high
Exit: short, for trend-breakout entries, high >= trend-short stop OR low <= IB extension low
Exit: short, for fade entries, high >= fade-short stop OR low <= prior-session POC
Exit: long, for fade entries, low <= fade-long stop OR high >= prior-session POC