<!-- tradingview-pine-id: PUB;6f50930522644bcbb09507b80fdbbe7e -->
<!-- tradingviewscripts-format: 1 -->
# IFR Níveis Móveis

Source: https://www.tradingview.com/script/O0QdRLYK/

## Description

A intenção de colocar os níveis de sobre compra e sobre venda moveis veio do livro da Constance Brown  "Technical Analysis for the Trading Professional", que fala em seu livro que os níveis de sobre compra e sobre venda costumam variar de acosto com a tendencia que o ativo está, em tendencia de baixa temos um deslocamento para baixo do nível de sobre compra e sobre venda e na tendencia de alta o inverso (deslocamento para cima do nível). 

Partindo desse princípio pequei as máximas e mínimas do RSI de N períodos (padrão 200) e apliquei uma taxa de desconto (padrão 5%) para que as máximas fiquei menores e as mínimas maiores. 

Também mostra no indicador uma linha central entre as bandas de sobre compra e sobre venda.
 

Também coloquei a opção de pedir para aparecer ou não os níveis fixos de (70, 50 e 30) e também duas medias moveis. a média curta com a opção de colorir o fundo do indicador a despender da posição (média acima ou abaixo do RSI).

Inputs:

Fonte de dados: Fechamento (ou qualquer outro dado ex: abertura, outro indicador)
Período do IFR: 14
Nível sobre compra (fixo): 70
Nível Sobrevinda (fixo): 30
Período média curta: 9
Período média longa: 50
Período máximas/mínimas ifr: 200
taxa de desconto (%): 5

Mostrar níveis fixos:
Colorir fundo (IFR x Média Curta):
Coloquei linha do IFR Dinamicamente: (colore de estiver acima ou abaixo dos níveis moveis de sobre compra e sobre venda)

Exceto pelos níveis moveis e as medias não existe nenhuma alteração no RSI e devem ser utilizadas as técnicas usuais e de domínio de cada operador.

---

## Source Code

````pine
//@version=6
indicator(title = 'IFR Níveis Móveis', shorttitle = 'IFR NM', overlay = false)

// ================================================================
//                         INPUTS
// ================================================================
Fonte = input.source(close, title = 'Fonte de Dados (Source)')
Periodo = input.int(14, title = 'Período do IFR', minval = 1)
NivelSobreCompra = input.int(70, title = 'Nível Sobrecompra (fixo)', minval = 1, maxval = 100)
NivelSobreVenda = input.int(30, title = 'Nível Sobrevenda (fixo)', minval = 1, maxval = 100)
MediaCurta = input.int(9, title = 'Período Média Curta', minval = 1)
MediaLonga = input.int(50, title = 'Período Média Longa', minval = 1)
PeriodoLimites = input.int(200, title = 'Período Máximas/Mínimas do IFR', minval = 1)
Porcentagem = input.float(5, title = 'Taxa de Desconto (%)', minval = 0, maxval = 100, step = 0.1)
NiveisFixos = input.bool(false, title = 'Mostrar Níveis Fixos')
ColorirFundo = input.bool(false, title = 'Colorir Fundo (IFR x Média Curta)')
ColorirLinhaIFR = input.bool(true, title = 'Colorir Linha do IFR Dinamicamente')
CorFixaIFR = input.color(color.blue, title = 'Cor Fixa da Linha do IFR')

// ================================================================
//                     CÁLCULO DO IFR (RSI)
// ================================================================
// O Pine Script possui ta.rsi() nativo, que implementa o mesmo
// algoritmo de Wilder (média suavizada) usado na Nelogica.
// Agora calculado sobre a "Fonte" escolhida pelo usuário,
// da mesma forma que o RSI nativo do TradingView permite.
sResult = ta.rsi(Fonte, Periodo)

// ================================================================
//               NÍVEIS MÓVEIS (Máximas/Mínimas do IFR)
// ================================================================
ifrMax = ta.highest(sResult, PeriodoLimites)
ifrMin = ta.lowest(sResult, PeriodoLimites)
Nivelcentral = (ifrMax + ifrMin) / 2
Nivelsup = ifrMax - Nivelcentral * 2 * Porcentagem / 100
Nivelinf = ifrMin + Nivelcentral * 2 * Porcentagem / 100

// ================================================================
//                        MÉDIAS DO IFR
// ================================================================
mediaCurtaPlot = ta.sma(sResult, MediaCurta)
mediaLongaPlot = ta.sma(sResult, MediaLonga)

// ================================================================
//                     COR DO IFR PRINCIPAL
// ================================================================
corIFRDinamica = sResult >= Nivelsup ? color.red : sResult <= Nivelinf ? color.green : color.blue
corIFR = ColorirLinhaIFR ? corIFRDinamica : CorFixaIFR

// ================================================================
//                    COR DE FUNDO (IFR x Média Curta)
// ================================================================
corFundo = sResult > mediaCurtaPlot ? color.new(color.green, 85) : sResult < mediaCurtaPlot ? color.new(color.red, 85) : na
bgcolor(ColorirFundo ? corFundo : na, title = 'Fundo IFR x Média Curta')

// ================================================================
//                          PLOTAGENS
// ================================================================

// IFR principal (colorido dinamicamente)
plot(sResult, title = 'IFR', color = corIFR, linewidth = 2)

// Médias sobre o IFR
plot(mediaCurtaPlot, title = 'Média Curta', color = color.green, linewidth = 1)
plot(mediaLongaPlot, title = 'Média Longa', color = color.orange, linewidth = 1)

// Níveis móveis
plot(Nivelsup, title = 'Nível Sup Móvel', color = color.red, style = plot.style_line, linewidth = 1)
plot(Nivelinf, title = 'Nível Inf Móvel', color = color.green, style = plot.style_line, linewidth = 1)
plot(Nivelcentral, title = 'Nível Central', color = color.gray, style = plot.style_line, linewidth = 1)

// Níveis fixos (exibidos apenas se NiveisFixos = true)
hline(NiveisFixos ? NivelSobreCompra : na, title = 'Sobrecompra Fixo', color = color.red, linestyle = hline.style_dashed)
hline(NiveisFixos ? NivelSobreVenda : na, title = 'Sobrevenda Fixo', color = color.green, linestyle = hline.style_dashed)
hline(NiveisFixos ? 50 : na, title = 'Nível 50 Fixo', color = color.gray, linestyle = hline.style_dashed)
````
