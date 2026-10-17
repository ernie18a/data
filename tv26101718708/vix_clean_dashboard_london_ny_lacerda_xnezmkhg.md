# VIX Clean Dashboard (London & NY ) (LACERDA

- url: https://www.tradingview.com/script/xnEzmkhg-VIX-Clean-Dashboard-London-NY-LACERDA/
- type: indicator
- pine_id: PUB;35a40051bc534da98c6ddb576d5a2ee2
- version: 1.0

## Description

The VIX Clean Dashboard is an essential Heads-Up Display (HUD) for day traders and macro analysts who need to track the exact expansion and contraction phases of market volatility (VIX / VXN) during the core liquidity sessions.

Unlike standard VIX indicators that rely on delayed feeds or dead overnight data, this script pulls continuous, gapless data from the curated 24/7 tape. It mathematically anchors the base 0% to the previous daily close and tracks real-time percentages flawlessly across global sessions.

✨ Key Features & Mechanics:

London Lock (03:00 EST): Automatically captures and locks the exact VIX percentage at the start of the European cash session. This allows you to instantly gauge the overnight macro sentiment before the US wakes up.
New York Anchor (09:30 EST): Records the precise VIX percentage at the ringing of the Wall Street opening bell.
Real-Time Extremes (Max/Min): Once NY opens, the dashboard actively hunts and records the absolute Highest and Lowest VIX percentages reached during the intraday session.
Live Delta (Δ) Tracking: The most powerful feature of the dashboard. Next to the Current, Max, and Min values, it displays the live Delta (Δ) — dynamically calculating exactly how much volatility has expanded (Red/Danger) or contracted (Green/Risk-On) relative to the 09:30 AM New York Open.
Selectable Feeds: Choose between the 24/7 seamless S&P 500 (TVC:VIX) for global macro reading, or Nasdaq (USI:VXN) for tech-heavy volatility trading.
Non-Intrusive Design: A transparent, sleek UI table that can be repositioned anywhere on your chart (e.g., Middle Right) to keep your candlesticks perfectly clean.
How to Use: Keep this dashboard running on your main index chart (SPX, ES, NQ, MNQ). If the Current Delta (Δ) is flashing green and dropping negative relative to the NY Open, volatility is being crushed, signaling a strong environment for equities to rally. If the Delta is strictly positive and pushing towards the VIX Máximo, the market is pricing in fear/hedging, signaling heavy intraday resistance or sell-offs for equities.

## Source Code

````pine
//@version=6
indicator("VIX Clean Dashboard (London & NY Live)", overlay=true)

// =====================================
// Inputs e Configurações Visuais
// =====================================
vixChoice = input.string("S&P 500 (TVC:VIX - 24h Liso)", title="Índice de Volatilidade", options=["S&P 500 (TVC:VIX - 24h Liso)", "Nasdaq (USI:VXN)"])

posInput = input.string("Middle Right", title="Posição do Painel", options=["Top Right", "Top Center", "Top Left", "Middle Right", "Middle Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"])

var string pos = position.middle_right
if posInput == "Top Right"
    pos := position.top_right
else if posInput == "Top Center"
    pos := position.top_center
else if posInput == "Top Left"
    pos := position.top_left
else if posInput == "Middle Center"
    pos := position.middle_center
else if posInput == "Middle Left"
    pos := position.middle_left
else if posInput == "Bottom Right"
    pos := position.bottom_right
else if posInput == "Bottom Center"
    pos := position.bottom_center
else if posInput == "Bottom Left"
    pos := position.bottom_left

// =====================================
// 1. EXTRAÇÃO DE DADOS (Puros, sem delay)
// =====================================
sym = vixChoice == "S&P 500 (TVC:VIX - 24h Liso)" ? "TVC:VIX" : "USI:VXN"

// Puxar o Fechamento Exato de Ontem (Base 0% do dia de hoje)
prev_daily = request.security(sym, "D", close[1], barmerge.gaps_off, barmerge.lookahead_on)

// Dados da vela atual no tempo gráfico rodando ao vivo
[vix_o, vix_h, vix_l, vix_c] = request.security(sym, timeframe.period, [open, high, low, close])

// Converte os preços para porcentagem (idêntico à lista de acompanhamento)
pct_curr = prev_daily != 0 ? ((vix_c - prev_daily) / prev_daily) * 100 : na
pct_o    = prev_daily != 0 ? ((vix_o - prev_daily) / prev_daily) * 100 : na
pct_h    = prev_daily != 0 ? ((vix_h - prev_daily) / prev_daily) * 100 : na
pct_l    = prev_daily != 0 ? ((vix_l - prev_daily) / prev_daily) * 100 : na


// =====================================
// 2. GRAVADOR DE SESSÕES 
// =====================================
var float open_london_pct = na
var float open_930_pct    = na
var float max_ny_pct      = na
var float min_ny_pct      = na

// Reset todo o lixo computacional quando vira o dia à meia-noite
if time("D", "America/New_York") != time("D", "America/New_York")[1]
    open_london_pct := na
    open_930_pct    := na
    max_ny_pct      := na
    min_ny_pct      := na

// Criando os detectores de Horário (Fuso NY)
in_london = time(timeframe.period, "0300-0930", "America/New_York")
in_ny     = time(timeframe.period, "0930-1600", "America/New_York")

// Dispara como um gatilho verdadeiro apenas no PRIMEIRO candle da sessão
is_london_open = not na(in_london) and na(in_london[1])
is_ny_open     = not na(in_ny) and na(in_ny[1])

// Trava a porcentagem de abertura exatamente às 03:00
if is_london_open
    open_london_pct := pct_o // Se por acaso a abertura for NA por falta de tick, usa o preço atual
    if na(open_london_pct)
        open_london_pct := pct_curr

// Trava a porcentagem de NY exatamente às 09:30
if is_ny_open
    open_930_pct := pct_o
    max_ny_pct   := pct_h
    min_ny_pct   := pct_l
    
// Durante toda a sessão de NY, caça os topos e fundos absolutos
else if not na(in_ny) and not na(open_930_pct)
    if not na(pct_h)
        max_ny_pct := na(max_ny_pct) ? pct_h : math.max(max_ny_pct, pct_h)
    if not na(pct_l)
        min_ny_pct := na(min_ny_pct) ? pct_l : math.min(min_ny_pct, pct_l)

// Matemática dos Deltas
delta_current = pct_curr - open_930_pct
delta_max     = max_ny_pct - open_930_pct
delta_min     = min_ny_pct - open_930_pct


// =====================================
// 3. RENDERIZAÇÃO DO PAINEL
// =====================================
var table dashboard = table.new(pos, 3, 5, border_width=0, frame_width=0)

if barstate.islast
    table.set_position(dashboard, pos)

    bg_color = color.new(color.white, 100)  // Transparente
    txt_color = color.white
    
    // -- 00. LONDRES --
    color_london = open_london_pct > 0 ? color.lime : open_london_pct < 0 ? color.red : color.white
    s_london = not na(open_london_pct) ? str.tostring(open_london_pct, "#.##") + "%" : "Aguardando..."
    
    table.cell(dashboard, 0, 0, "Abertura LONDRES (03:00)", text_color=txt_color, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_left)
    table.cell(dashboard, 1, 0, s_london, text_color=color_london, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_right)
    table.cell(dashboard, 2, 0, "", bgcolor=bg_color) 

    // -- 01. NY --
    color_ny = open_930_pct > 0 ? color.lime : open_930_pct < 0 ? color.red : color.white
    s_open   = not na(open_930_pct) ? str.tostring(open_930_pct, "#.##") + "%" : "Aguardando..."
    
    table.cell(dashboard, 0, 1, "Abertura NY (09:30)", text_color=txt_color, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_left)
    table.cell(dashboard, 1, 1, s_open, text_color=color_ny, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_right)
    table.cell(dashboard, 2, 1, "", bgcolor=bg_color) 
    
    // -- 02. ATUAL --
    color_curr = pct_curr > 0 ? color.lime : pct_curr < 0 ? color.red : color.white
    s_curr = not na(pct_curr) ? str.tostring(pct_curr, "#.##") + "%" : "Aguardando..."
    
    s_delta_curr = not na(delta_current) ? " (Δ " + (delta_current > 0 ? "+" : "") + str.tostring(delta_current, "#.##") + "%)" : ""
    color_delta_curr = delta_current > 0 ? color.lime : delta_current < 0 ? color.red : color.gray
    
    table.cell(dashboard, 0, 2, "VIX Atual", text_color=txt_color, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_left)
    table.cell(dashboard, 1, 2, s_curr, text_color=color_curr, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_right)
    table.cell(dashboard, 2, 2, s_delta_curr, text_color=color_delta_curr, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_left)
    
    // -- 03. MÁXIMO --
    color_max_ny = max_ny_pct > 0 ? color.lime : max_ny_pct < 0 ? color.red : color.white
    s_max_val = not na(max_ny_pct) ? str.tostring(max_ny_pct, "#.##") + "%" : "..."
    
    s_delta_max = not na(delta_max) ? " (Δ " + (delta_max > 0 ? "+" : "") + str.tostring(delta_max, "#.##") + "%)" : ""
    color_delta_max = delta_max > 0 ? color.lime : delta_max < 0 ? color.red : color.gray
    
    table.cell(dashboard, 0, 3, "VIX Máximo", text_color=txt_color, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_left)
    table.cell(dashboard, 1, 3, s_max_val, text_color=color_max_ny, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_right)
    table.cell(dashboard, 2, 3, s_delta_max, text_color=color_delta_max, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_left)
    
    // -- 04. MÍNIMO --
    color_min_ny = min_ny_pct > 0 ? color.lime : min_ny_pct < 0 ? color.red : color.white
    s_min_val = not na(min_ny_pct) ? str.tostring(min_ny_pct, "#.##") + "%" : "..."
    
    s_delta_min = not na(delta_min) ? " (Δ " + (delta_min > 0 ? "+" : "") + str.tostring(delta_min, "#.##") + "%)" : ""
    color_delta_min = delta_min > 0 ? color.lime : delta_min < 0 ? color.red : color.gray
    
    table.cell(dashboard, 0, 4, "VIX Mínimo", text_color=txt_color, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_left)
    table.cell(dashboard, 1, 4, s_min_val, text_color=color_min_ny, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_right)
    table.cell(dashboard, 2, 4, s_delta_min, text_color=color_delta_min, bgcolor=bg_color, text_size=size.normal, text_halign=text.align_left)
````
