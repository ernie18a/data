Regime-classification framework. It uses external crypto market-structure data to emit long, short, or flat calls for crypto instruments. The category of each call (BTC, large-cap alts, small-cap/low-cap alts) says which instrument group it applies to. Evaluate on every bar of the chart timeframe, using each series' close.

INPUTS (all fetched at the chart timeframe, no lookahead): BTC price, ETH price, BTC dominance, USDT dominance, OTHERS dominance (everything outside the top 10), TOTAL market cap, TOTAL2 (total excluding BTC), TOTAL3 (total excluding BTC and ETH), ETH/BTC ratio.

DERIVED MEASURES:
1. Momentum for each series: percent change of the current value versus its value a fixed number of bars ago. Written below as chg(X).
2. Trend for BTC price, BTC dominance, OTHERS dominance and TOTAL: compare a fast simple moving average with a slow one. Up (+1) if fast > slow, down (-1) if fast < slow, else 0. Written below as trend(X).
3. Thresholds: four base percentage thresholds defined on the daily timeframe, namely a USDT-dominance pump threshold (U), a BTC-dominance rise threshold (D), an OTHERS-dominance rise threshold (O), and a price-dump threshold (P). Multiply each by the square root of (chart timeframe length in minutes / minutes in a day). This scaling can be switched off, in which case the factor is 1.

SHORT CONDITIONS:
- ShortLowCaps: chg(USDT.D) >= U AND chg(TOTAL3) < chg(TOTAL2) AND chg(TOTAL) < 0 AND chg(OTHERS.D) < 0.
- ShortAlts: trend(BTC price) = -1 AND trend(BTC.D) = +1 AND chg(TOTAL2) < chg(TOTAL) AND chg(ETH/BTC) < 0 AND chg(TOTAL2) < -P.
- ShortBTC: trend(BTC price) = -1 AND chg(BTC price) < -P AND chg(TOTAL) < 0 AND neither ShortLowCaps nor ShortAlts is true.

LONG CONDITIONS (each also requires that none of the three short conditions is true):
- BTC season (long BTC): trend(BTC price) = +1 AND trend(BTC.D) = +1 AND trend(TOTAL) = +1 AND chg(BTC.D) > D.
- Top-10 alt season (long ETH and large-cap alts): trend(BTC price) = +1 AND trend(BTC.D) = -1 AND chg(TOTAL2) > chg(TOTAL) AND chg(ETH/BTC) > 0 AND chg(TOTAL) > 0.
- Small-cap alt season (long low caps): trend(BTC.D) = -1 AND trend(OTHERS.D) = +1 AND chg(OTHERS.D) > O AND chg(TOTAL3) > chg(TOTAL2).

PRIORITY: resolve overlaps in this order: ShortLowCaps, ShortAlts, ShortBTC, BTC season, Top-10 season, Small-cap season. The first true condition wins.

NEUTRAL: if none is true, the regime is neutral/range. Hold no position (stay flat, exit any open one).

ACTIONS: ShortLowCaps means short OTHERS/low caps. ShortAlts means short alts or ETH/BTC pairs. ShortBTC means short BTC. The three long regimes mean go long BTC, top-10 alts, or small caps respectively. A position is held while its regime persists and exited when the regime changes to neutral or flips.