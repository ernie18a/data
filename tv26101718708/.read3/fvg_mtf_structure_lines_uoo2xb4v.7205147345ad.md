Calculation: Confirmed pivot levels(N) = on chart bars, initialize the leg as bearish; set it to bearish when high[N] > highest(high, N), otherwise set it to bullish when low[N] < lowest(low, N), otherwise retain it; when the leg changes to bearish, record high[N] as the pivot high, and when it changes to bullish, record low[N] as the pivot low.
Long: Close crosses above the most recent un-crossed pivot high calculated with the shorter lookback AND that pivot high differs from the most recent pivot high calculated with the longer lookback.
Short: Close crosses below the most recent un-crossed pivot low calculated with the shorter lookback AND that pivot low differs from the most recent pivot low calculated with the longer lookback.
Long: Close crosses above the most recent un-crossed pivot high calculated with the longer lookback.
Short: Close crosses below the most recent un-crossed pivot low calculated with the longer lookback.
Long: On chart bars when a new T1 bar begins, low of the T1 bar still forming > high(T1, two bars ago) AND close(T1, last completed bar) > high(T1, two bars ago).
Short: On chart bars when a new T1 bar begins, high of the T1 bar still forming < low(T1, two bars ago) AND close(T1, last completed bar) < low(T1, two bars ago).
Long: On chart bars when a new T2 bar begins, low of the T2 bar still forming > high(T2, two bars ago) AND close(T2, last completed bar) > high(T2, two bars ago).
Short: On chart bars when a new T2 bar begins, high of the T2 bar still forming < low(T2, two bars ago) AND close(T2, last completed bar) < low(T2, two bars ago).
Long: On chart bars when a new T3 bar begins, low of the T3 bar still forming > high(T3, two bars ago) AND close(T3, last completed bar) > high(T3, two bars ago).
Short: On chart bars when a new T3 bar begins, high of the T3 bar still forming < low(T3, two bars ago) AND close(T3, last completed bar) < low(T3, two bars ago).