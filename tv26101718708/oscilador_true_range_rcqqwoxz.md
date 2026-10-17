# Oscilador True Range

- url: https://www.tradingview.com/script/rCqQWoxz/
- type: indicator
- pine_id: PUB;9882687ace7448498a9f1010d99a6953
- version: 1.0

## Description

True Range Oscillator – Candle Strength & Position Sizing

This oscillator measures how large each candle is compared to the market's typical volatility. It helps identify strength bars (breakouts, ignition bars) and adjust position size to the current volatility.

How it works

The script compares each candle's size with the arithmetic average of the True Range over the last N candles (default 21). Two display modes are available:

• Multiple of average (default): how many times the candle is larger than the average True Range. The average appears as a fixed line at 1×, with reference lines at 2×, 3× and 4×. A column above 1× is a candle larger than usual.
• % of price: candle size as a percentage of the close (columns), plus its N-period average as a moving line. This mode shows whether overall volatility is expanding or contracting.

The multiple is always shown in the status line and Data Window, even in "% of price" mode.

Candle size can be measured as the range (high − low) or as the True Range, which also accounts for gaps from the previous close.

Color zones (in both modes)

• Gray: below 1× (ordinary candle)
• Green: 1–2× (strength bar, full position size)
• Yellow: 2–3× (consider 75% of normal size)
• Orange: 3–4× (consider 50% of normal size)
• Red: above 4× (stretched candle, entries usually not recommended)

The zones follow a common risk-management idea: the larger the signal candle, the wider the stop, so the position is reduced to keep the monetary risk constant.

Alerts

• Candle above X× the average True Range (adjustable, default 2×)
• Candle above 4× the average
• True Range % crossing above its average (volatility expansion)

Notes

• Works on any market and timeframe. Useful together with breakout and pullback setups to qualify the signal candle.
• This is a volatility and position-sizing tool, not a buy/sell signal on its own.

🇧🇷 Português

Este oscilador mede o tamanho de cada candle em relação à volatilidade típica do mercado. Ajuda a identificar barras de força (rompimentos, barras de ignição) e a ajustar o tamanho da posição à volatilidade atual.

Como funciona

O script compara o tamanho de cada candle com a média aritmética do True Range dos últimos N candles (padrão 21). Há dois modos:

• Múltiplo da média (padrão): quantas vezes o candle é maior que o True Range médio. A média aparece como linha fixa em 1×, com linhas de referência em 2×, 3× e 4×. Coluna acima de 1× é candle maior que o normal.
• % do preço: tamanho do candle em % do fechamento (colunas) e sua média de N períodos como linha móvel. Esse modo mostra se a volatilidade geral está se expandindo ou contraindo.

O múltiplo aparece sempre na legenda e na janela de dados, mesmo no modo "% do preço".

O tamanho do candle pode ser medido pela amplitude (máxima − mínima) ou pelo True Range, que considera também gaps em relação ao fechamento anterior.

Faixas de cor (nos dois modos)

• Cinza: abaixo de 1× (candle comum)
• Verde: 1–2× (barra de força, posição cheia)
• Amarelo: 2–3× (considerar 75% do tamanho normal)
• Laranja: 3–4× (considerar 50% do tamanho normal)
• Vermelho: acima de 4× (candle esticado, entrada geralmente não recomendada)

A lógica das faixas é de gestão de risco: quanto maior o candle de sinal, mais largo o stop. Por isso se reduz a posição, para manter constante o risco em dinheiro.

Alertas

• Candle acima de X× o True Range médio (ajustável, padrão 2×)
• Candle acima de 4× a média
• True Range % cruzando acima da média (expansão de volatilidade)

Observações

• Funciona em qualquer mercado e timeframe. É útil junto com setups de rompimento e pullback, para qualificar o candle de sinal.
• É uma ferramenta de volatilidade e dimensionamento de posição, não um sinal de compra/venda por si só.

## Source Code

````pine
//@version=6
indicator("Oscilador True Range", shorttitle="True Range", overlay=false)

// =====================================================================
// Oscilador de True Range no padrão do Método Cripto.
//
// Modo "% do preço": True Range de cada candle em % do fechamento
//   (colunas) + média de N candles (linha) — mesma leitura do painel
//   "SMA True Range(%)": volatilidade atual vs. volatilidade típica.
// Modo "Múltiplo da média": quantas vezes o candle é maior que a média
//   (mesma fórmula da Amplitude de Lorenz) com as faixas do guia:
//   1-2 TR = posição cheia · 2-3 = 75% · 3-4 = 50% · acima de 4 = evitar.
// Nos dois modos, a cor das colunas segue as faixas do guia.
// =====================================================================

mode     = input.string("Múltiplo da média", "Modo", options=["Múltiplo da média", "% do preço"])
numOpt   = input.string("Amplitude (máx − mín)", "Medida do candle",
     options=["Amplitude (máx − mín)", "True Range"],
     tooltip="Amplitude = fórmula da Amplitude de Lorenz (Profit). True Range inclui gaps em relação ao fechamento anterior.")
avgLen   = input.int(21, "Período da média (Profit: 21)", minval=2)
showAvg  = input.bool(true, "Mostrar linha da média (no modo Múltiplo ela fica fixa em 1×)")

colNormal = input.color(color.new(color.gray, 20),   "Abaixo de 1× (candle comum)", group="Cores por faixa")
col12     = input.color(color.new(color.teal, 0),    "1–2× (posição cheia)",        group="Cores por faixa")
col23     = input.color(color.new(color.yellow, 0),  "2–3× (75% da posição)",       group="Cores por faixa")
col34     = input.color(color.new(color.orange, 0),  "3–4× (50% da posição)",       group="Cores por faixa")
col4p     = input.color(color.new(color.red, 0),     "Acima de 4× (evitar)",        group="Cores por faixa")
colAvg    = input.color(color.aqua, "Cor da média", group="Cores por faixa")

alertMult = input.float(2.0, "Alerta: candle acima de X× a média", minval=0.5, step=0.1, group="Alertas")

// ============================ CÁLCULO ==================================
trV     = ta.tr(true)
trAvg   = ta.sma(trV, avgLen)
candleM = numOpt == "True Range" ? trV : high - low

mult    = trAvg > 0 ? candleM / trAvg : na
pctNow  = close > 0 ? candleM / close * 100 : na
pctAvg  = ta.sma(pctNow, avgLen)

barCol = mult < 1 ? colNormal : mult < 2 ? col12 : mult < 3 ? col23 : mult < 4 ? col34 : col4p

isPct = mode == "% do preço"

// ============================ PLOTS ====================================
plot(isPct ? pctNow : mult, "True Range", style=plot.style_columns, color=barCol)
plot(isPct and showAvg ? pctAvg : na, "Média", color=colAvg, linewidth=2)
// múltiplo sempre visível na legenda e na janela de dados (mesmo número
// que aparece embaixo dos candles), inclusive no modo "% do preço"
plot(mult, "Múltiplo", color=barCol, display=display.status_line + display.data_window)

hline(isPct or not showAvg ? na : 1, "Média (1×)", color=colAvg, linestyle=hline.style_solid, linewidth=2)
hline(isPct ? na : 2, "2×", color=color.new(color.yellow, 50), linestyle=hline.style_dotted)
hline(isPct ? na : 3, "3×", color=color.new(color.orange, 50), linestyle=hline.style_dotted)
hline(isPct ? na : 4, "4×", color=color.new(color.red, 50), linestyle=hline.style_dotted)

// ============================ ALERTAS ==================================
alertcondition(mult >= alertMult, "Candle de força", "Candle acima do múltiplo de True Range definido em {{ticker}} {{interval}} ({{close}})")
alertcondition(mult >= 4,         "Candle acima de 4×", "Candle acima de 4× a média de True Range em {{ticker}} {{interval}} — fora da faixa do guia")
alertcondition(isPct and ta.crossover(pctNow, pctAvg), "Volatilidade acima da média", "True Range % cruzou acima da média em {{ticker}} {{interval}}")
````
