# AVIXZGROUP - Agente Sinais PRO | S/R e Anti-Spike

- url: https://www.tradingview.com/script/MBerrruF/
- type: indicator
- pine_id: PUB;3c14fbc9d6cd4644868c92f569850799
- version: 1.0

## Description

Descrição:

Este é o Agente Sinais PRO da AVIXZGROUP. Desenvolvemos este indicador para limpar o ruído do mercado e focar apenas nas zonas de preço onde o dinheiro institucional realmente atua.

Ideal para quem não pode passar o dia inteiro na frente do gráfico e precisa de um rastreador automático, confiável e com gestão de risco visual. Ele não desenha dezenas de linhas confusas na sua tela; ele entrega apenas as fronteiras finais de negociação.

⚙️ Como Funciona?
O Agente mapeia o gráfico buscando pontos fortes de reversão (Topos e Fundos) em tempos gráficos maiores (Radar) e agrupa níveis próximos para formar zonas sólidas de Suporte (Chão) e Resistência (Teto).

No gráfico, você verá apenas as zonas ativas mais próximas do preço atual, com um histórico limpo de apenas 7 dias para trás e 1 dia projetado para frente.

🎯 Principais Funcionalidades
Linhas Distais (Sólidas): As linhas vermelhas (Teto) e verdes (Chão) representam o extremo da zona de briga. É o ponto exato para avaliar a sua entrada.

Gatilho Anti-Spike (Tracejadas): A grande proteção do indicador. As linhas tracejadas marcam o seu limite de risco. Se o preço romper a zona de forma violenta (além da linha tracejada), o Agente classifica como rompimento real e não emite o sinal, protegendo você de pegar a "faca caindo".

Filtro de Volume Institucional (Opcional): No painel de configurações, você pode exigir que o indicador só plote zonas ou emita sinais se houver um pico de volume financeiro confirmando o movimento.

Congelamento Diário (Cache 24h): As zonas são recalculadas apenas na virada do dia (00:00). Isso impede que as suas marcações fiquem piscando ou mudando de lugar durante as suas operações diárias.

📲 Como configurar os Alertas (Telegram/App)
Este indicador está 100% pronto para enviar alertas estruturados direto para o seu celular via Webhook.

Adicione o indicador ao gráfico e ajuste as configurações (Tempo gráfico, Agrupamento e Volume) na engrenagem.

Clique em Criar Alerta no TradingView.

Na Condição, selecione AVIXZGROUP - Agente Sinais PRO.

Escolha a opção "Qualquer chamada da função de alerta" (Any alert() function call). Isso é obrigatório.

Na aba Notificações, insira a URL do seu Webhook e salve.

O script cuidará de formatar a mensagem com o nome do ativo, preço atual e a zona exata de defesa. Bons trades!

## Source Code

````pine
//@version=6
indicator("AVIXZGROUP - Agente Sinais PRO", overlay=true, max_lines_count=100)

// =========================================================================
// 1. PAINEL DE CONFIGURAÇÕES
// =========================================================================
grp_radar  = "1. O RADAR (Tempo Gráfico e Distância)"
tf_analise = input.timeframe("240", "Tempo Gráfico da Análise (Ex: 240 p/ 4H, D p/ Diário)", group=grp_radar)
pivot_len  = input.int(15, "Período do Pivô (Largura do Topo/Fundo)", group=grp_radar)
agrup_pct  = input.float(1.2, "Filtro de Agrupamento S/R (%)", step=0.1, group=grp_radar, tooltip="Absorve linhas intermediárias.") / 100
use_cache  = input.bool(true, "Congelar Zonas Diariamente (Cache 24h)?", group=grp_radar, tooltip="Simula o TTL de 24h. As zonas só mudam de lugar na virada do dia (00:00).")
dias_hist  = input.int(7, "Tamanho Visível (Dias p/ trás)", group=grp_radar, tooltip="Impede que as linhas sujem o passado do gráfico.")
dias_frente= input.int(1, "Projeção Visível (Dias p/ frente)", group=grp_radar, tooltip="Impede que o gráfico fique espremido, colocando um fim na linha.")

grp_vol    = "2. FORÇA DA ZONA"
req_vol_p  = input.bool(false, "Exigir Pico de Volume na Criação da Zona?", group=grp_vol)
vol_mult   = input.float(1.5, "Multiplicador de Volume (Ex: 1.5x a média)", step=0.1, group=grp_vol)
vol_len    = input.int(20, "Período da Média de Volume", group=grp_vol)
req_vol_v  = input.bool(false, "Exigir Pico de Volume no Toque (Ao Vivo)?", group=grp_vol)

grp_gatilho= "3. GATILHO E ANTI-SPIKE"
anti_spike = input.float(1.5, "Limite Anti-Spike (%)", step=0.1, group=grp_gatilho) / 100

// =========================================================================
// 2. CAPTAÇÃO MULTI-TIMEFRAME E VOLUME
// =========================================================================
[ph, pl, p_vol, p_vol_sma] = request.security(syminfo.tickerid, tf_analise, [ta.pivothigh(high, pivot_len, pivot_len), ta.pivotlow(low, pivot_len, pivot_len), volume[pivot_len], ta.sma(volume, vol_len)[pivot_len]], lookahead=barmerge.lookahead_on)

// =========================================================================
// 3. LÓGICA DE AGRUPAMENTO (Bastidores)
// =========================================================================
var array<float> res_zonas = array.new<float>()
var array<float> sup_zonas = array.new<float>()

f_atualizar_zonas(arr, novo_nivel, is_res) =>
    adicionar = true
    if array.size(arr) > 0
        for i = 0 to array.size(arr) - 1
            nivel_salvo = array.get(arr, i)
            dist = math.abs(novo_nivel - nivel_salvo) / nivel_salvo
            if dist <= agrup_pct
                adicionar := false
                if (is_res and novo_nivel > nivel_salvo) or (not is_res and novo_nivel < nivel_salvo)
                    array.set(arr, i, novo_nivel)
                break
    if adicionar
        array.push(arr, novo_nivel)
        if array.size(arr) > 20 
            array.shift(arr)

if not na(ph)
    vol_aprovado = req_vol_p ? (p_vol >= p_vol_sma * vol_mult) : true
    if vol_aprovado
        f_atualizar_zonas(res_zonas, ph, true)

if not na(pl)
    vol_aprovado = req_vol_p ? (p_vol >= p_vol_sma * vol_mult) : true
    if vol_aprovado
        f_atualizar_zonas(sup_zonas, pl, false)

// =========================================================================
// 4. MEMÓRIA DE 24H
// =========================================================================
var array<float> cached_res = array.new<float>()
var array<float> cached_sup = array.new<float>()

bool virada_dia = ta.change(time("1D")) != 0

if virada_dia or barstate.isfirst
    cached_res := array.copy(res_zonas)
    cached_sup := array.copy(sup_zonas)

matriz_ativa_r = use_cache ? cached_res : res_zonas
matriz_ativa_s = use_cache ? cached_sup : sup_zonas

// =========================================================================
// 5. SELECIONANDO AS 3 MAIS PRÓXIMAS
// =========================================================================
var array<float> r_closest = array.new<float>()
var array<float> s_closest = array.new<float>()

array.clear(r_closest)
array.clear(s_closest)

if array.size(matriz_ativa_r) > 0
    for i = 0 to array.size(matriz_ativa_r) - 1
        val = array.get(matriz_ativa_r, i)
        if val > close
            array.push(r_closest, val)
array.sort(r_closest, order.ascending)

if array.size(matriz_ativa_s) > 0
    for i = 0 to array.size(matriz_ativa_s) - 1
        val = array.get(matriz_ativa_s, i)
        if val < close
            array.push(s_closest, val)
array.sort(s_closest, order.descending)

// =========================================================================
// 6. DESENHANDO AS LINHAS (Tamanho Fixo: 7 dias pra trás, 1 dia pra frente)
// =========================================================================
var array<line> linhas_ativas = array.new<line>()

// Converte os dias da configuração em milissegundos
int ms_back = dias_hist * 86400000
int ms_fwd  = dias_frente * 86400000

// Define as âncoras exatas no relógio
int start_time = time - ms_back
int end_time   = time + ms_fwd

if barstate.islast
    while array.size(linhas_ativas) > 0
        line.delete(array.shift(linhas_ativas))
        
    int r_len = math.min(array.size(r_closest), 3)
    if r_len > 0
        for i = 0 to r_len - 1
            val = array.get(r_closest, i)
            val_as = val * (1 + anti_spike)
            c_red = i == 0 ? color.red : color.new(color.red, 60)
            
            // Desenha com começo e fim exatos
            array.push(linhas_ativas, line.new(x1=start_time, y1=val, x2=end_time, y2=val, xloc=xloc.bar_time, color=c_red, width=2, extend=extend.none))
            array.push(linhas_ativas, line.new(x1=start_time, y1=val_as, x2=end_time, y2=val_as, xloc=xloc.bar_time, color=color.new(color.red, 40), style=line.style_dashed, width=1, extend=extend.none))

    int s_len = math.min(array.size(s_closest), 3)
    if s_len > 0
        for i = 0 to s_len - 1
            val = array.get(s_closest, i)
            val_as = val * (1 - anti_spike)
            c_green = i == 0 ? color.green : color.new(color.green, 60)
            
            // Desenha com começo e fim exatos
            array.push(linhas_ativas, line.new(x1=start_time, y1=val, x2=end_time, y2=val, xloc=xloc.bar_time, color=c_green, width=2, extend=extend.none))
            array.push(linhas_ativas, line.new(x1=start_time, y1=val_as, x2=end_time, y2=val_as, xloc=xloc.bar_time, color=color.new(color.green, 40), style=line.style_dashed, width=1, extend=extend.none))

// =========================================================================
// 7. GATILHOS DA ALERTA
// =========================================================================
float res_ativa = array.size(r_closest) > 0 ? array.get(r_closest, 0) : na
float sup_ativa = array.size(s_closest) > 0 ? array.get(s_closest, 0) : na

vol_vivo_ok = req_vol_v ? (volume >= ta.sma(volume, vol_len) * vol_mult) : true

toque_res = not na(res_ativa) and high >= res_ativa
toque_sup = not na(sup_ativa) and low <= sup_ativa

as_ok_res = not na(res_ativa) and close <= res_ativa * (1 + anti_spike)
as_ok_sup = not na(sup_ativa) and close >= sup_ativa * (1 - anti_spike)

sinal_res = toque_res and as_ok_res and vol_vivo_ok
sinal_sup = toque_sup and as_ok_sup and vol_vivo_ok

// =========================================================================
// 8. COMUNICAÇÃO TELEGRAM
// =========================================================================
if (sinal_res)
    alert('{"chat_id": "582639518", "text": "🚨 <b>AVIXZGROUP: SHORT (R)</b> 🚨\\n\\nAtivo: ' + syminfo.ticker + '\\nTF Radar: ' + tf_analise + '\\nPreço: $' + str.tostring(close, "#.##") + '\\nZona Distal: $' + str.tostring(res_ativa, "#.##") + '\\n\\nStatus: Toque confirmado na zona Anti-Spike. Avalie a entrada!"}', alert.freq_once_per_bar)

if (sinal_sup)
    alert('{"chat_id": "582639518", "text": "🚨 <b>AVIXZGROUP: LONG (S)</b> 🚨\\n\\nAtivo: ' + syminfo.ticker + '\\nTF Radar: ' + tf_analise + '\\nPreço: $' + str.tostring(close, "#.##") + '\\nZona Distal: $' + str.tostring(sup_ativa, "#.##") + '\\n\\nStatus: Toque confirmado na zona Anti-Spike. Avalie a entrada!"}', alert.freq_once_per_bar)
````
