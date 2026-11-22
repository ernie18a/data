# Relative Strength vs SPY

- url: https://www.tradingview.com/script/f3A2F3yp-Relative-Strength-vs-SPY/
- type: indicator
- pine_id: PUB;0f370aa3a95544ce8681b910bc3df531
- version: 1.0

## Description

Investor's Business Daily-like Relative Strength compared to S&P500 (SPY)

## Source Code

````pine
//@version=6
indicator("Relative Strength vs SPY", overlay=false)

// Benchmark
spy = request.security("SPY", timeframe.period, close)

// RS brut
rs = close / spy

// Normalisation stable (évite tous les bugs de base)
rs_norm = rs / ta.sma(rs, 200) * 100



// Plots

// Couleurs conditionnelles
// Couleur dynamique avec zone neutre autour de 100
col =
     rs_norm > 100 ? color.green :
     rs_norm < 100 ? color.red :
     color.gray

plot(rs_norm, title="RS", linewidth=2, color=col)



hline(100, "Neutral", linestyle=hline.style_dashed)

bgcolor(rs_norm >= 100 ? color.new(color.green, 95) : color.new(color.red, 95))
````
