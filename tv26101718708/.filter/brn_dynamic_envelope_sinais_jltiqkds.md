# BRN Dynamic Envelope Sinais

- url: https://www.tradingview.com/script/JLtIQKDs/
- type: indicator
- pine_id: PUB;92f2d915e5714cdb839fc73dd2a69750
- version: 2.0

## Description

Here is a brief explanatory text in English that you can use to present or document your indicator:

Overview of the BRN Dynamic Envelope Signals
The BRN Dynamic Envelope is a sophisticated, price-action-driven indicator designed to capture explosive trend breakouts while aggressively filtering out market noise. Instead of relying on simple moving average crossovers, it utilizes a multi-layered volatility envelope to identify high-probability trade setups.

How the System Works:

The Dynamic Envelope: The indicator calculates three customized Moving Averages—a central baseline, an upper band based on candle highs, and a lower band based on candle lows. A built-in distance multiplier allows you to expand or contract these bands, adapting the system to any asset's volatility.

The Setup (Setting the Trap): When the price crosses and closes outside the upper or lower band, it indicates a potential trend shift. The system immediately draws a horizontal "trigger line" at the extreme of that breakout candle (the highest high for a bullish setup, or the lowest low for a bearish setup).

The Execution (The Signal): The system demands proof of momentum. A definitive Buy ("B") or Sell ("S") signal is only fired when a subsequent candle breaks the horizontal trigger line. This execution can happen via a traditional candle close or instantaneously if the market opens with a gap beyond the trigger.

Smart Cleanup: The moment the signal is fired and the trade is executed, the trigger line is automatically erased from the chart. This smart cleanup prevents redundant signals and keeps the visual interface clean.

Visual Trend Filter: The central moving average dynamically changes color to reflect the immediate market regime: Green for a fluid uptrend, Red for a fluid downtrend, and Gray for a ranging or transitional market.

By demanding price confirmation before issuing a signal, the BRN Dynamic Envelope effectively protects traders from false breakouts and whipsaw markets, delivering surgical entry points for swing trading.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © nicks1008 (BRN Dynamic Envelope Sinais - Clean Chart)
//@version=5
indicator('BRN Dynamic Envelope Sinais', title='BRN Dynamic Envelope Sinais', shorttitle='BRN Dynamic Envelope Sinais', precision=1, overlay=true)

// ========================================================
// 1. CONFIGURAÇÕES DAS MÉDIAS E MULTIPLICADOR
// ========================================================
periodo_ma = input(50, title='Período do Canal de Médias')
tipo_ma = input.string('SMA', title='Tipo de Média', options=['SMA', 'EMA', 'WMA', 'RMA', 'VWMA'])
mult_dist = input.float(1.0, title='Multiplicador de Distância das Bandas', step=0.1)

// Opção para manter o gráfico limpo
exibir_env = input(false, title='Exibir Envelope de Médias no Gráfico')

// Função em linha única
obter_media(tipo, fonte, periodo) =>
    tipo == 'SMA' ? ta.sma(fonte, periodo) : tipo == 'EMA' ? ta.ema(fonte, periodo) : tipo == 'WMA' ? ta.wma(fonte, periodo) : tipo == 'RMA' ? ta.rma(fonte, periodo) : tipo == 'VWMA' ? ta.vwma(fonte, periodo) : na

// Médias Base (Calculadas no plano de fundo)
ma_principal = obter_media(tipo_ma, close, periodo_ma)
ma_max_bruta = obter_media(tipo_ma, high, periodo_ma)
ma_min_bruta = obter_media(tipo_ma, low, periodo_ma)

// Aplicação do Multiplicador na Distância
distancia_alta = (ma_max_bruta - ma_principal) * mult_dist
distancia_baixa = (ma_principal - ma_min_bruta) * mult_dist

// Novas Bandas Expandidas
ma_maximas = ma_principal + distancia_alta
ma_minimas = ma_principal - distancia_baixa

// ========================================================
// 2. PLOTAGEM DO CANAL (Oculto por padrão)
// ========================================================
iff_1 = high < ma_principal ? color.red : color.gray
mycolor = low > ma_principal ? color.lime : iff_1

// Se 'exibir_env' for falso, a cor vira 'na' (invisível)
plot(exibir_env ? ma_principal : na, title='Média Principal (Close)', color=mycolor, linewidth=2, transp=20)
plot(exibir_env ? ma_maximas : na, title='Banda Superior', color=color.new(color.lime, 60), linewidth=1)
plot(exibir_env ? ma_minimas : na, title='Banda Inferior', color=color.new(color.red, 60), linewidth=1)

// ========================================================
// 3. LÓGICA DE MARCAÇÃO E CONSUMO DO GATILHO
// ========================================================
vela_cruza_banda_alta = ta.crossover(close, ma_maximas)
vela_cruza_banda_baixa = ta.crossunder(close, ma_minimas)

var float max_high = na
var float min_low = na

if vela_cruza_banda_alta
    max_high := high
    min_low := na
    min_low

if vela_cruza_banda_baixa
    min_low := low
    max_high := na
    max_high

sinal_imediato_compra = not na(max_high) and open > max_high
sinal_imediato_venda = not na(min_low) and open < min_low

rompeu_max = ta.crossover(close, max_high) or sinal_imediato_compra
rompeu_min = ta.crossunder(close, min_low) or sinal_imediato_venda

buycall = rompeu_max
sellcall = rompeu_min

// Apaga a linha de marcação após o sinal
if buycall
    max_high := na
    max_high
if sellcall
    min_low := na
    min_low

// Linhas de armadilha (Sempre visíveis, pois são o foco visual da estratégia)
plot_max = vela_cruza_banda_alta ? na : max_high
plot_min = vela_cruza_banda_baixa ? na : min_low

plot(plot_max, title='Gatilho de Compra', color=color.new(color.lime, 10), linewidth=2, style=plot.style_linebr)
plot(plot_min, title='Gatilho de Venda', color=color.new(color.red, 10), linewidth=2, style=plot.style_linebr)

// ========================================================
// 4. PLOTAGEM DE SINAIS E ALERTAS
// ========================================================               
plotshape(buycall, title='Buy', style=shape.labelup, location=location.belowbar, color=color.new(color.aqua, 0), text='B', textcolor=color.new(color.white, 0))
plotshape(sellcall, title='Sell', style=shape.labeldown, location=location.abovebar, color=color.new(color.red, 20), text='S', textcolor=color.new(color.black, 20))

alertcondition(buycall or sellcall, title='BRN Sinal Executado', message='Sinal de Entrada Executado no BRN Envelope')
````
