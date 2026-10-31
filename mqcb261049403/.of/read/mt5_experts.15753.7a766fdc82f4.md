Calculation: RSI oscillator H = short-period moving average of RSI of a selected OHLC-derived price minus a longer-period moving average of that short-period average; both averages use the same selected smoothing method and phase.
Calculation: Signal S = moving average of H using a separately selected smoothing method and phase.
Calculation: For indicator markings, H and S use the chart timeframe. For trading decisions, H and S use a selectable higher or lower timeframe and a selectable last completed or still-forming bar; previous values refer to preceding bars of that timeframe.
Long: H > 0 AND H > previous H OR H < 0 AND H > previous H
Short: H > 0 AND H < previous H OR H < 0 AND H < previous H
Long: H > previous S
Short: H < previous S
Long: zero-breakout mode AND H > 0 AND previous H <= 0
Short: zero-breakout mode AND H < 0 AND previous H >= 0
Long: oscillator-turn mode AND H > previous H AND previous H < H two bars ago
Short: oscillator-turn mode AND H < previous H AND previous H > H two bars ago
Long: signal-turn mode AND S > previous S AND previous S < S two bars ago
Short: signal-turn mode AND S < previous S AND previous S > S two bars ago
Long: signal-cross mode AND H > S AND previous H <= previous S
Short: signal-cross mode AND H < S AND previous H >= previous S
Exit: long, zero-breakout mode AND H < 0 OR oscillator-turn mode AND H < previous H OR signal-turn mode AND S < previous S OR signal-cross mode AND H < S
Exit: short, zero-breakout mode AND H > 0 OR oscillator-turn mode AND H > previous H OR signal-turn mode AND S > previous S OR signal-cross mode AND H > S
Exit: long, low <= entry price - stop distance OR high >= entry price + profit-target distance
Exit: short, high >= entry price + stop distance OR low <= entry price - profit-target distance