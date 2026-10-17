# Keltner Channels + EMA 56 Colorizer

- url: https://www.tradingview.com/script/M2MkAJOp/
- type: indicator
- pine_id: PUB;f297533adb6341bba243c4979c3eadcc
- version: 1.0

## Description

his indicator is a complete trend-following system designed to visually guide you through strong market trends by combining the volatility-based Keltner Channels with a medium-term 56-period Exponential Moving Average (EMA).

Instead of just plotting lines, this script repaints the chart's candles based on the current trend phase, allowing for split-second market context recognition. It also includes a built-in Multi-Timeframe (MTF) Dashboard to check trend alignment across higher timeframes without leaving your current chart.

How the Logic Works:
The indicator analyzes the relationship between the Keltner Channels boundaries and the 56 EMA:

Bullish Trend (Buy Zone): When the Lower Band of the Keltner Channel crosses above the 56 EMA. The market is in a strong uptrend, and candles are colored in bullish tones.

Bearish Trend (Sell Zone): When the Upper Band of the Keltner Channel crosses below the 56 EMA. The market is in a strong downtrend, and candles are colored in bearish tones.

Neutral Zone: When the EMA is trading inside the Keltner Channels. The market is consolidating or transitioning, and candles are colored in neutral (gray/black) tones.

Key Features:
Dynamic Candle Coloring: Total control over candle colors. The script distinguishes between up-candles (close > open) and down-candles (close < open) within each trend phase, giving you 18 independent color settings for bodies, borders, and wicks.

MTF Dashboard: A small, fully customizable table displayed on your chart showing the current signal (Buy, Sell, or Neutral) across 5 different timeframes. Perfect for top-down analysis.

Fully Customizable: You can adjust the Keltner Channel parameters (Length, Multiplier, ATR/True Range/Range style, SMA/EMA basis), the EMA length, and the dashboard position to fit your personal trading strategy.

Usage Tip:
Because this indicator draws custom colored candles over the chart to give you independent control over bodies, borders, and wicks, we highly recommend hiding the default chart candles.

How to hide: Right-click the chart background > Settings > Symbol > Uncheck "Body", "Borders", and "Wick" under the Candlesticks section.

## Source Code

````pine
//@version=6
indicator(title="Keltner Channels + EMA 56 Colorizer", shorttitle="KC+EMA56", overlay=true)

// =========================================================================
// 1. CONFIGURAÇÕES - KELTNER CHANNELS
// =========================================================================
grp_kc = "Configurações Keltner"
length     = input.int(25, title="Período", minval=1, group=grp_kc)
mult       = input.float(0.34, title="Multiplicador", group=grp_kc)
src        = input.source(close, title="Fonte", group=grp_kc)
exp        = input.bool(true, title="Usar MM Exponencial", group=grp_kc)
BandsStyle = input.string("Range", title="Estilo de Bandas", options=["Average True Range", "True Range", "Range"], group=grp_kc)
atrlength  = input.int(10, title="Comprimento ATR", group=grp_kc)

// =========================================================================
// 2. CONFIGURAÇÕES - EMA
// =========================================================================
grp_ema = "Configuração EMA"
ema_len = input.int(56, title="Período da EMA", group=grp_ema)

// =========================================================================
// 3. CONFIGURAÇÕES - CORES (COMPRA)
// =========================================================================
grp_buy_bull = "Compra - Candle de Alta"
b_bull_body   = input.color(#089981, title="Corpo", group=grp_buy_bull)
b_bull_border = input.color(#089981, title="Borda", group=grp_buy_bull)
b_bull_wick   = input.color(#089981, title="Pavio", group=grp_buy_bull)

grp_buy_bear = "Compra - Candle de Baixa"
b_bear_body   = input.color(#00695C, title="Corpo", group=grp_buy_bear)
b_bear_border = input.color(#00695C, title="Borda", group=grp_buy_bear)
b_bear_wick   = input.color(#00695C, title="Pavio", group=grp_buy_bear)

// =========================================================================
// 4. CONFIGURAÇÕES - CORES (VENDA)
// =========================================================================
grp_sell_bull = "Venda - Candle de Alta"
s_bull_body   = input.color(#FF5252, title="Corpo", group=grp_sell_bull)
s_bull_border = input.color(#FF5252, title="Borda", group=grp_sell_bull)
s_bull_wick   = input.color(#FF5252, title="Pavio", group=grp_sell_bull)

grp_sell_bear = "Venda - Candle de Baixa"
s_bear_body   = input.color(#F23645, title="Corpo", group=grp_sell_bear)
s_bear_border = input.color(#F23645, title="Borda", group=grp_sell_bear)
s_bear_wick   = input.color(#F23645, title="Pavio", group=grp_sell_bear)

// =========================================================================
// 5. CONFIGURAÇÕES - CORES (NEUTRO)
// =========================================================================
grp_neu_bull = "Neutro - Candle de Alta"
n_bull_body   = input.color(color.new(color.gray, 30), title="Corpo", group=grp_neu_bull)
n_bull_border = input.color(color.gray, title="Borda", group=grp_neu_bull)
n_bull_wick   = input.color(color.gray, title="Pavio", group=grp_neu_bull)

grp_neu_bear = "Neutro - Candle de Baixa"
n_bear_body   = input.color(color.new(color.black, 30), title="Corpo", group=grp_neu_bear)
n_bear_border = input.color(color.black, title="Borda", group=grp_neu_bear)
n_bear_wick   = input.color(color.black, title="Pavio", group=grp_neu_bear)

// =========================================================================
// 6. CÁLCULOS PRINCIPAIS
// =========================================================================
// Função para decidir entre SMA e EMA no Keltner
esma(source, len) =>
    s = ta.sma(source, len)
    e = ta.ema(source, len)
    exp ? e : s

// Keltner Channels
ma = esma(src, length)
rangema = BandsStyle == "True Range" ? ta.tr(true) : BandsStyle == "Average True Range" ? ta.atr(atrlength) : ta.rma(high - low, length)
upper = ma + rangema * mult
lower = ma - rangema * mult

// EMA de 56
ema56 = ta.ema(src, ema_len)

// =========================================================================
// 7. LÓGICA DE CONDIÇÕES E COLORAÇÃO
// =========================================================================
// Identifica se o candle é de alta ou baixa
is_bull = close >= open

// Condições do Setup
buy_cond = lower > ema56
sell_cond = upper < ema56

// Escolha dinâmica das cores
c_body = buy_cond ? (is_bull ? b_bull_body : b_bear_body) : sell_cond ? (is_bull ? s_bull_body : s_bear_body) : (is_bull ? n_bull_body : n_bear_body)
c_border = buy_cond ? (is_bull ? b_bull_border : b_bear_border) : sell_cond ? (is_bull ? s_bull_border : s_bear_border) : (is_bull ? n_bull_border : n_bear_border)
c_wick = buy_cond ? (is_bull ? b_bull_wick : b_bear_wick) : sell_cond ? (is_bull ? s_bull_wick : s_bear_wick) : (is_bull ? n_bull_wick : n_bear_wick)

// =========================================================================
// 8. PLOTAGEM NO GRÁFICO
// =========================================================================
// Linhas do Keltner
u = plot(upper, color=#2962FF, title="Upper KC")
plot(ma, color=#2962FF, title="Basis KC")
l = plot(lower, color=#2962FF, title="Lower KC")
fill(u, l, color=color.rgb(33, 150, 243, 90), title="Fundo KC")

// Linha da EMA 56
plot(ema56, color=color.orange, linewidth=2, title="EMA 56")

// Desenha os novos candles configurados
plotcandle(open, high, low, close, title="Candles", color=c_body, wickcolor=c_wick, bordercolor=c_border)
````
