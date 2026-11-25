Calculation: Advance/decline ratio = (advances - declines) / (advances + declines), or zero if the denominator is zero; count only symbols with a bar aligned to the chart bar, omit ties, and reverse advances and declines for inverse symbols.
Calculation: P-smoother(x, lookback) = L4, where beta = smoothing coefficient * (lookback - 1) / (smoothing coefficient * (lookback - 1) + 2), alpha = beta^3, L0 = (1 - alpha) * x + alpha * prior L0, L1 = (x - L0) * (1 - beta) + beta * prior L1, L2 = L0 + L1, L3 = (L2 - prior L4) * (1 - alpha)^2 + alpha^2 * prior L3, and L4 = prior L4 + L3; initialize L0, L1, and L4 to x, and L2 and L3 to zero.
Calculation: McClellan Summation Index = prior index + P-smoother(advance/decline ratio, shorter lookback) - P-smoother(advance/decline ratio, longer lookback), with the first value equal to the first fast P-smoother value minus the first slow P-smoother value.
Calculation: Upper floating level = Lowest(McClellan Summation Index, floating-level lookback) + upper-level percentage * (Highest(McClellan Summation Index, floating-level lookback) - Lowest(McClellan Summation Index, floating-level lookback)) / 100.
Calculation: Lower floating level = Lowest(McClellan Summation Index, floating-level lookback) + lower-level percentage * (Highest(McClellan Summation Index, floating-level lookback) - Lowest(McClellan Summation Index, floating-level lookback)) / 100.
Long: color mode is floating levels AND McClellan Summation Index > Upper floating level
Short: color mode is floating levels AND McClellan Summation Index < Lower floating level
Long: color mode is slope AND McClellan Summation Index > McClellan Summation Index[1]
Short: color mode is slope AND McClellan Summation Index < McClellan Summation Index[1]
Long: color mode is zero AND McClellan Summation Index > (Upper floating level + Lower floating level) / 2
Short: color mode is zero AND McClellan Summation Index < (Upper floating level + Lower floating level) / 2