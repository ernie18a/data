Use volatility-index (VIX) and broad-market ETF (SPY) data, not the traded instrument’s price. Compute smoothed fast and slow stochastic readings for both series, VIX’s percentage rise from its recent low, its percentage fall from its prior high, and the rolling correlation between VIX and time.

Enter long when VIX has surged past its configured rise threshold; its slow stochastic exceeds SPY’s slow stochastic; its fast stochastic is rising and exceeds SPY’s fast stochastic; and VIX’s correlation trend is rising and above its configured minimum. Also enter long on the cover condition: VIX’s fast stochastic is rising, its rise measure exceeds the configured threshold, and its correlation trend exceeds the minimum.

Enter short when SPY’s fast stochastic is rising and exceeds VIX’s fast stochastic; VIX is above its configured level; its recent fall exceeds the configured decline threshold; it has fallen on each of the latest three bars; and its rise measure is below the configured threshold.

When holding long, a short signal reverses the position to short. When holding short, a cover signal reverses the position to long. When flat, prioritize a long or cover signal over a short signal. For the inverse-volatility fund SVXY, swap the long and short signals and swap the sell and cover signals.

In long-only mode, close a long position when VIX’s fast stochastic falls from the prior bar or SPY’s fast stochastic exceeds VIX’s fast stochastic. Close any open position when the configured observation window ends.