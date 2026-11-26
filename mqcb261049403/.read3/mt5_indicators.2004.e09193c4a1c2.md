Calculation: Ergodic line = XMA(XMA((selected price - XMA(selected price, price lookback))/point, first lookback), second lookback)
Calculation: Signal line = XMA(Ergodic line, signal lookback)
Long: Ergodic line > Signal line
Short: Ergodic line < Signal line
Long: Signal line > 0
Short: Signal line < 0
Long: Ergodic line(T1, bar still forming, mapped to chart bars) > Signal line(T1, bar still forming, mapped to chart bars)
Short: Ergodic line(T1, bar still forming, mapped to chart bars) < Signal line(T1, bar still forming, mapped to chart bars)
Long: Signal line(T1, bar still forming, mapped to chart bars) > 0
Short: Signal line(T1, bar still forming, mapped to chart bars) < 0