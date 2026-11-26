# VVIX/VIX

- url: https://www.tradingview.com/script/hr3d6ug9/
- type: indicator
- pine_id: PUB;0cd66c268db847b9a0c1177c4fe2eaa8
- version: 1.0

## Description

The VVIX/VIX ratio compares the volatility of volatility to the level of equity-market volatility itself. VVIX measures expected volatility of the VIX, while VIX measures expected volatility of the S&P 500. A high ratio suggests that traders are pricing a higher risk of sudden volatility shocks.

## Source Code

````pine
//@version=6
indicator("VVIX/VIX", shorttitle="VVIX/VIX", overlay=false)

// Données VVIX et VIX séparées
vvix = request.security("CBOE:VVIX", timeframe.period, open, gaps=barmerge.gaps_off)
vix  = request.security("CBOE:VIX", timeframe.period, open, gaps=barmerge.gaps_off)

// Ratio sécurisé
ratio = (vix != 0 and not na(vix) and not na(vvix)) ? vvix / vix : na

// MA9
ma_ratio = ta.sma(ratio, 7)

// Affichage
plot(series=ma_ratio, title="VVIX/VIX", color=color.orange, linewidth=1)
// plot(series=ratio, title="Ratio brut", color=color.blue, linewidth=1, style=plot.style_line_dashed)
````
