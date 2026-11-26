# Dugomes Macro Flow - Blindado PRO

- url: https://www.tradingview.com/script/eGwSCF1w/
- type: indicator
- pine_id: PUB;ea40a5ee3c244bb88a73a608029adbdc
- version: 3.0

## Description

1. Os Componentes Visuais (O que você vê)
Linha Preta (Macro Line): Representa o "preço justo global". Ela combina o preço do Ouro, Prata e Petróleo com a força inversa do Dólar (DXY). Se ela sobe, o cenário externo é favorável ao Brasil.

Linha Azul (EMA 200): É o filtro de Tendência Forte. Ela define o "lado" do mercado.

Velas (Candles) e Fundo: Mostram a ação do preço e o sentimento atual (Verde para alta, Vermelho para baixa).

2. A Lógica de Tomada de Decisão (O Gatilho)
O usuário não deve operar cada cruzamento, mas sim buscar a Confluência Blindada:

Cenário de Compra Profissional (PRO BUY)
Para o sinal de compra aparecer, quatro condições precisam ser verdadeiras ao mesmo tempo:

Ação do Preço: O BRA50 cruzou para cima da Linha Preta.

Tendência: O preço está trabalhando acima da Linha Azul (EMA 200).

Fluxo de Dinheiro: O indicador MFI está acima de 50 (dinheiro entrando).

Esforço: O volume financeiro está acima da média (institucionais estão ativos).

Cenário de Venda Profissional (PRO SELL)
Ação do Preço: O BRA50 cruzou para baixo da Linha Preta.

Tendência: O preço está trabalhando abaixo da Linha Azul (EMA 200).

Fluxo de Dinheiro: O indicador MFI está abaixo de 50 (dinheiro saindo).

Esforço: Volume alto confirmando a batida na venda.

3. Como Analisar Divergências
Uma das funções mais poderosas para o usuário é observar quando o preço "foge" do macro:

Divergência de Alta: A Linha Preta está subindo (exterior favorável), mas o BRA50 ainda está caindo. Isso sugere que o Brasil está "barato" e pode dar um sinal de PRO BUY a qualquer momento.

Divergência de Baixa: As commodities e o dólar indicam queda (Linha Preta para baixo), mas o BRA50 insiste em subir. Cuidado: o índice pode estar "esticado" e prestes a uma correção forte.

4. Dica de Ouro: Uso com SMC (Smart Money Concepts)
Instrua o usuário a marcar suas zonas de Order Blocks (OB) e Fair Value Gaps (FVG).

O Setup de Alta Probabilidade:
Se o preço toca um Order Block de Compra e, naquele exato momento ou logo em seguida, o indicador dispara o rótulo PRO BUY, a chance de o trade ir direto no alvo é muito maior, pois você tem a técnica (SMC) e o combustível (Macro e Fluxo) alinhados.

Resumo para o Usuário
"Não opere contra a Linha Azul. Não ignore a Linha Preta. Só entre quando o Volume e o MFI confirmarem o sinal."

## Source Code

````pine
//@version=5
indicator("Dugomes Macro Flow - Elite Final", shorttitle="Dugomes Elite", overlay=true, max_boxes_count=100)

// ==========================================
// 1. CONFIGURAÇÃO DE ATIVOS & INPUTS
// ==========================================
t_brent  = input.symbol("UKOIL", "Petróleo")
t_gold   = input.symbol("GOLD", "Ouro")
t_usdind = input.symbol("DXY", "DXY") 

lookback   = input.int(20, "Período Macro", minval=5)
ema_trend  = input.int(200, "Tendência EMA 200")
vol_mult   = input.float(1.2, "Sensibilidade Absorção", step=0.1)

// Parâmetros do Fluxo de Dinheiro (MFI)
mfi_length = input.int(14, "MFI Período")
mfi_buy    = input.int(52, "MFI Nível Compra")
mfi_sell   = input.int(48, "MFI Nível Venda")

// ==========================================
// 2. CÁLCULOS MACRO E DELTA DE VOLUME
// ==========================================
f_get(s) => request.security(s, timeframe.period, close, ignore_invalid_symbol=true)
f_pct(src, len) => src / ta.valuewhen(not na(src), src, len)

macro_val = (f_pct(f_get(t_brent), lookback) + f_pct(f_get(t_gold), lookback) + (1 / f_pct(f_get(t_usdind), lookback))) / 3
linha_macro = ta.valuewhen(not na(close), close, lookback) * macro_val
trend_filter = ta.ema(close, ema_trend)

// Cálculo de Agressão (Delta de Volume)
vol_ma = ta.sma(volume, 20)
hl_diff = high - low
v_compra = hl_diff == 0 ? 0 : (volume * ((close - low) + (high - open))) / (2 * hl_diff)
v_venda  = volume - v_compra

// Detecção de Absorção (Velas de Contratos Apregoados)
abs_venda  = (v_venda > vol_ma * vol_mult) and (close < ((high + low) / 2))
abs_compra = (v_compra > vol_ma * vol_mult) and (close > ((high + low) / 2))

// ==========================================
// 3. GATILHOS PRO (FLUXO + MACRO + SMC)
// ==========================================
mfi = ta.mfi(close, mfi_length)

compra_pro = (ta.crossover(close, linha_macro) or abs_compra) and close > trend_filter and mfi > mfi_buy
venda_pro  = (ta.crossunder(close, linha_macro) or abs_venda) and close < trend_filter and mfi < mfi_sell

// ==========================================
// 4. GESTÃO DE RISCO (TP1, TP2, TP3)
// ==========================================
var float sl = na, var float tp1 = na, var float tp2 = na, var float tp3 = na

if compra_pro
    risk = close - ta.lowest(low, 3)
    sl := close - risk, tp1 := close + risk, tp2 := close + (risk * 2), tp3 := close + (risk * 3)
if venda_pro
    risk = ta.highest(high, 3) - close
    sl := close + risk, tp1 := close - risk, tp2 := close - (risk * 2), tp3 := close - (risk * 3)

// ==========================================
// 5. PINTURA DE VELAS E VISUAL
// ==========================================
// Cores: Verde (Compra), Vermelho (Venda), Roxo (Absorção Venda), Ciano (Absorção Compra)
barcolor(compra_pro ? #00ff08 : venda_pro ? #ff0000 : abs_venda ? #e040fb : abs_compra ? #00e5ff : na)

plot(linha_macro, "Linha Macro", color=color.new(color.black, 15), linewidth=2)
plot(trend_filter, "EMA 200", color=color.new(color.blue, 60))

// Plotagem dos Alvos e Stop
plot(sl, "Stop Loss", color=color.new(color.red, 20), style=plot.style_linebr, linewidth=2)
plot(tp1, "TP1", color=color.new(color.green, 40), style=plot.style_linebr, linewidth=1)
plot(tp2, "TP2", color=color.new(color.green, 20), style=plot.style_linebr, linewidth=2)
plot(tp3, "TP3", color=color.new(color.green, 5), style=plot.style_linebr, linewidth=3)

plotshape(compra_pro, "BUY", shape.labelup, location.belowbar, color.green, text="PRO BUY", textcolor=color.white)
plotshape(venda_pro, "SELL", shape.labeldown, location.abovebar, color.red, text="PRO SELL", textcolor=color.white)

// Alertas para Automação via n8n ou Robôs
alertcondition(compra_pro, "COMPRA PRO", "Entrada Compra Detectada")
alertcondition(venda_pro, "VENDA PRO", "Entrada Venda Detectada")
````
