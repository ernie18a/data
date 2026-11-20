Calculation: footprint delta percentage = 100 * footprint delta / (footprint buy volume + footprint sell volume)
Long: On bar close, a footprint contains at least the minimum consecutive-row parameter buy-imbalanced rows, using the footprint imbalance threshold
Short: On bar close, a footprint contains at least the minimum consecutive-row parameter sell-imbalanced rows, using the footprint imbalance threshold
Long: On bar close, low < an active liquidity low, close > the highest swept liquidity low, and footprint delta percentage <= -absorption threshold
Short: On bar close, high > an active liquidity high, close < the lowest swept liquidity high, and footprint delta percentage >= absorption threshold