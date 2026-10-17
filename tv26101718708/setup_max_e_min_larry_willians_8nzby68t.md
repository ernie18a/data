# Setup Max e Min Larry Willians

- url: https://www.tradingview.com/script/8NzbY68T/
- type: indicator
- pine_id: PUB;43a5d5384d704efb841f1c9aeb1d773d
- version: 3.0

## Description

[b]Larry Williams used this system to win the trading championship[/b]

Hello friends, I bring a script with a trading strategy to be used in futures such as Index, Forex and Commodities. Developed by famous trader Larry Williams.

In them we use two 3-period Simple Moving Averages (Arithmetic) (one with the high price, the other with the low price), and a 21-period Moving Average (Arithmetic) to determine the trend. This will form an average channel with the prices of the maximums and minimums of the last three candles.

Best time charts use the strategy: from 5 minutes to 60 minutes.

This strategy is quite simple. The 21 Moving Average will color according to the trend (Green for bullish, Red for bearish and Gray for transitions). The Script will signal the entry according to the trend by the colors of the candles and also by the signal:

When green, the buy will be on the crossing of the lower Moving Average crossing the candlestick, and the exit will be on the crossing of the candlestick on the next Upper Moving Average.

When red, the sell will be at the crossing of the Upper Moving Average crossing the candlestick, and the exit will be at the crossing of the candlestick on the next Lower Moving Average.

When the Script signals the candle with a purple X, it means that the trend is changing and the entire open operation must be closed.

This system has no Stop, so be careful when using it.

Na linguagem do autor:

Larry Williams usou esse sistema ganhar campeonato de trade

Olá amigos, trago um script com uma estratégia de trade pra ser usada em futuros como Índice, Forex e Commodities. Desenvolvido pelo famoso trader Larry Willians.

Neles usamos duas Médias Móveis Simples (Aritmética) de 3 períodos (uma com o preço da máxima, outra com o preço da mínima), e uma Média Móvel (Aritmética) de 21 períodos para determinar a tendência.  Nisso vai formar uma canal de médias com os preços das máximas e mínimas dos últimos três candles.

Melhores tempos gráficos usar a estratégia: de 5 minutos até 60 minutos.

Essa estratégia é bem simples. A Média Móvel de 21 irá colorir de acordo com a tendência (Green pra alta, Red para baixa e Gray para transições). O Script irá sinalizar a entrada de acordo com a tendência pela cores dos candles e também pela sinalização:

Quando green, a compra será no cruzamento da Média Móvel inferior cruzando o candle, e a saida será no cruzamento do candle na Média Móvel Superior seguinte. 

Quando red, a venda será no cruzamento da Média Móvel Superior cruzando o candle, e a saida será no cruzamento do candle na Média Móvel Inferior seguinte. 

Quando o Script sinaliza o candle com X purple, significa que a tendência está em mudança e deve ser fechada toda a operação em aberto.

Este sistema não possui Stop, portando cuidado quanto a seu uso.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
///\\===============================================================================//\\\
//████████╗██████╗  █████╗ ██████╗ ██╗███╗   ██╗ ██████╗ ██╗   ██╗██╗███████╗██╗    ██╗\\
//╚══██╔══╝██╔══██╗██╔══██╗██╔══██╗██║████╗  ██║██╔════╝ ██║   ██║██║██╔════╝██║    ██║\\
//   ██║   ██████╔╝███████║██║  ██║██║██╔██╗ ██║██║  ███╗██║   ██║██║█████╗  ██║ █╗ ██║\\
//   ██║   ██╔══██╗██╔══██║██║  ██║██║██║╚██╗██║██║   ██║╚██╗ ██╔╝██║██╔══╝  ██║███╗██║\\
//   ██║   ██║  ██║██║  ██║██████╔╝██║██║ ╚████║╚██████╔╝ ╚████╔╝ ██║███████╗╚███╔███╔╝\\
//   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═════╝ ╚═╝╚═╝  ╚═══╝ ╚═════╝   ╚═══╝  ╚═╝╚══════╝ ╚══╝╚══╝ \\
//\\==============================================================================//\\ \\
// ----------------------------------------------------------------------------------- \\
// Setup Max e Min Larry Willians : Developed by Cavuca-Trader                         \\                                  
// ----------------------------------------------------------------------------------- \\
// ................................................................................... \\
// Name                  : Setup Max e Min Larry Willians                              \\                                                  
// Surname               : Setup Max Min                                               \\                       
// Description           : Technical Analysis Setup Scalper                            \\
// Info                  : Setup for quick operations following the asset trend.       \\
// Creation Date         : 01/02/2023                                                  \\
// Version TradingView   : 5                                                           \\
// ................................................................................... \\
// v1.0 - release = TradingView = Ok                                                   \\
// v2.0 - fixed system stop indication                                                 \\
// v3.0 - fixed corrected documentation                                                \\
//=====================================================================================\\
// © Cavuca-Trader
// @version=5
indicator(title="Setup Max e Min Larry Willians", shorttitle="Setup Max Min", overlay=true)

// Creating var
var int sma1 = 3
var int sma2 = 3
var int sma3 = 21
var bool stp = false
var bool stpX = false

// Creating moving averages
ma1 = ta.sma(high,sma1)
ma2 = ta.sma(low,sma2)
ma3 = ta.sma(close,sma3)


// Moving average coloring 
m_col = color.gray
if ma3 < ma2 and ma3 < ma1 
    m_col := color.rgb(7, 249, 15)   
if ma3 > ma2 and ma3 > ma1 
    m_col :=color.rgb(247, 8, 8)
    
// System Disable
if ma3 > ma2 and ma3[1] < ma2[1] and stp 
    stpX := true
    stp := false
else
    if ma3 < ma1 and ma3[1] > ma1[1] and stp
        stpX := true
        stp := false 
    else
        stpX := false 

// Coloring Rule Entry
Cwbar = close != open
Cgbar = ma3 < ma2 and ma3 < ma1 and low <= ma2 and stp == false
Crbar = ma3 > ma1 and ma3 > ma1 and high >= ma1 and stp == false

// Stop enable 
if Cgbar
    stp := true
else 
    if Crbar
        stp := true
    
// Stop Rule
StopCgbar = ma3 < ma2 and ma3 < ma1 and high >= ma1 and stp
StopCrbar = ma3 > ma1 and ma3 > ma1 and low <= ma2 and stp
if StopCgbar
    stp := false
else
    if StopCrbar
        stp := false

// Color of candles
barcolor(Cgbar ? color.green : na)
barcolor(Crbar ? color.red: na)
barcolor(Cwbar ? color.white : na)

// Trade indication
plotshape(Cgbar, style=shape.triangleup, color=color.rgb(7, 249, 15), location=location.belowbar, size=size.small)
plotshape(StopCgbar, style=shape.triangledown, color=color.rgb(247, 8, 8), location=location.abovebar, size=size.small)
plotshape(Crbar, style=shape.triangledown, color=color.rgb(247, 8, 8), location=location.abovebar, size=size.small)
plotshape(StopCrbar, style=shape.triangleup, color=color.rgb(7, 249, 15), location=location.belowbar, size=size.small)
plotshape(stpX, style=shape.xcross, color=color.purple, location=location.belowbar, size=size.small)

// Moving average plots
plot(ma1,color = color.purple,linewidth = 1)
plot(ma2,color = color.blue,linewidth = 1)
plot(ma3,color = m_col,linewidth = 2)
````
