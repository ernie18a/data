# Relative Strength vs QQQ

- url: https://www.tradingview.com/script/uYDWLj1E-Relative-Strength-vs-QQQ/
- type: indicator
- pine_id: PUB;dc5810aa85164ed0b3577bb59f3101fd
- version: 1.0

## Description

Investor's Business Daily-like Relative Strength compared to NASDAQ (QQQ)

## Source Code

````pine
//@version=6
indicator("Relative Strength vs QQQ", overlay=false)

// Benchmark
qqq = request.security("QQQ", timeframe.period, close)

// RS brut
rs = close / qqq

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
