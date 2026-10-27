# Leader NASDAQ (Shape Matcher & MTF Bias) (LACERDA)

- url: https://www.tradingview.com/script/tVgzb9hU-Leader-NASDAQ-Shape-Matcher-MTF-Bias-LACERDA/
- type: indicator
- pine_id: PUB;b44a4649372f438182db3259eda71bcb
- version: 1.0

## Description

The Leader NASDAQ is an advanced, real-time correlation dashboard designed for index traders who want to track the global macro ecosystem and identify which assets are currently driving the NASDAQ's price action.

Instead of just showing absolute percentage changes, this script utilizes a sophisticated "Shape Matcher" (Cumulative Deviation) algorithm. At the exact opening of each major global liquidity session (Asia, London, and New York), the script anchors the opening price of the NASDAQ and your custom watchlist to 0%. Minute by minute, it calculates the cumulative deviation between the NASDAQ's intraday performance curve and every tracked asset's curve.

The dashboard actively filters and displays the Top 2 "Leaders" for each active session—meaning it isolates the specific assets whose intraday price action most perfectly correlates with the NASDAQ at that exact moment.

✨ Key Features:

Three-Session Tracking: Automatically segmented into Asia (Pacific liquidity), London (European macro), and New York (Core volume) sessions.
Shape-Matching Logic: Finds the "gravitational pull" of the market. If NVIDIA or TSMC is dictating the Nasdaq's movement, the script will mathematically identify them as the session leaders by having the lowest cumulative error.
Live Trend Indicators: Quick-glance visual cues next to each leader. A Green circle (🟢) means the asset is currently trading above its session open (bullish pull), while a Red circle (🔴) indicates it's dragging below its open (bearish pull).
Highly Customizable: You can input up to 8 assets for Asia, 8 for London, and 9 for New York via the indicator settings. Perfect for monitoring the "Magnificent Seven", key semiconductors (like ASML, TSMC), and global indices (DAX, Nikkei 225, KOSPI).
Non-Intrusive HUD: A sleek, borderless table overlay that can be positioned anywhere on your chart (Top Right, Bottom Left, etc.) without cluttering your technical analysis.
How to Use:

Apply the indicator to your chart (optimally a NASDAQ/MNQ chart).
Open the Indicator Settings (⚙️).
Type in your favorite market-driving tickers for each session (e.g., AAPL, NVDA, NI225, FDAX1!, USDJPY).
Watch the dashboard dynamically update to show you where the smart money and heavy correlation currently reside!

## Source Code

````pine
//@version=6
indicator("Leader NASDAQ (Shape Matcher & MTF Bias)", overlay=true)

// =====================================================================
// 1. CONFIGURAÇÕES VISUAIS
// =====================================================================
grpVis = "Configurações de Visualização"
posInput_str = input.string("Topo Direita", title="Localização no Gráfico", options=["Topo Esquerda", "Topo Centro", "Topo Direita", "Baixo Esquerda", "Baixo Centro", "Baixo Direita"], group=grpVis)
sizeInput_str = input.string("Normal", title="Tamanho do Texto", options=["Pequeno", "Normal", "Grande"], group=grpVis)

calcPos() =>
    if posInput_str == "Topo Esquerda"
        position.top_left
    else if posInput_str == "Topo Centro"
        position.top_center
    else if posInput_str == "Topo Direita"
        position.top_right
    else if posInput_str == "Baixo Esquerda"
        position.bottom_left
    else if posInput_str == "Baixo Centro"
        position.bottom_center
    else
        position.bottom_right

calcSize() =>
    if sizeInput_str == "Pequeno"
        size.small
    else if sizeInput_str == "Grande"
        size.large
    else
        size.normal

// =====================================================================
// 2. CONFIGURAÇÕES DE SESSÕES
// =====================================================================
grpSes = "Configurações de Sessão"
sesASIA_str = input.session("2000-0300", title="Horário Ásia", group=grpSes)
sesLND_str = input.session("0300-0930", title="Horário Londres", group=grpSes)
sesNY_str  = input.session("0930-1600", title="Horário NY", group=grpSes)
tz         = input.string("America/New_York", title="Fuso Horário", group=grpSes)

isASIA = not na(time(timeframe.period, sesASIA_str, tz))
isLND  = not na(time(timeframe.period, sesLND_str, tz))
isNY   = not na(time(timeframe.period, sesNY_str, tz))

isNewASIA = isASIA and not isASIA[1]
isNewLND  = isLND and not isLND[1]
isNewNY   = isNY and not isNY[1]

// =====================================================================
// 3. ATIVOS MONITORADOS
// =====================================================================
grpASIA = "Ativos ÁSIA"
asia_sym1 = input.symbol("NK2251!", "Ásia 1 (Nikkei Fut)", group=grpASIA)
asia_sym2 = input.symbol("CN1!",    "Ásia 2 (China Fut)", group=grpASIA)
asia_sym3 = input.symbol("NI225",   "Ásia 3 (Nikkei)", group=grpASIA)
asia_sym4 = input.symbol("2330",    "Ásia 4 (TSMC Chips)", group=grpASIA) 
asia_sym5 = input.symbol("HSTECH",  "Ásia 5 (Hang Seng Tech)", group=grpASIA)
asia_sym6 = input.symbol("AUS200",  "Ásia 6 (Austrália)", group=grpASIA)
asia_sym7 = input.symbol("KOSPI",   "Ásia 7 (Coreia Tech)", group=grpASIA)
asia_sym8 = input.symbol("USDJPY",  "Ásia 8 (Dólar/Yen)", group=grpASIA)

grpLND = "Ativos LONDRES"
lnd_sym1 = input.symbol("FDAX1!",   "Londres 1 (DAX Fut)", group=grpLND)
lnd_sym2 = input.symbol("FESX1!",   "Londres 2 (EuroStoxx)", group=grpLND)
lnd_sym3 = input.symbol("ASML",     "Londres 3 (ASML Tech)", group=grpLND)
lnd_sym4 = input.symbol("DE40FU",   "Londres 4 (DAX)", group=grpLND) 
lnd_sym5 = input.symbol("EU50",     "Londres 5 (EU 50)", group=grpLND)
lnd_sym6 = input.symbol("UK100",    "Londres 6 (UK 100)", group=grpLND)
lnd_sym7 = input.symbol("UK100GBP", "Londres 7 (UK GBP)", group=grpLND)
lnd_sym8 = input.symbol("VIX",      "Londres 8 (VIX)", group=grpLND)

grpNY = "Ativos NOVA YORK"
ny_sym1 = input.symbol("NASDAQ:NVDA", "NY 1 (Nvidia)", group=grpNY) 
ny_sym2 = input.symbol("NASDAQ:AAPL", "NY 2 (Apple)", group=grpNY)
ny_sym3 = input.symbol("NASDAQ:MSFT", "NY 3 (Microsoft)", group=grpNY)
ny_sym4 = input.symbol("NASDAQ:AMZN", "NY 4 (Amazon)", group=grpNY)
ny_sym5 = input.symbol("NASDAQ:META", "NY 5 (Meta)", group=grpNY)
ny_sym6 = input.symbol("NASDAQ:GOOGL", "NY 6 (Google)", group=grpNY)
ny_sym7 = input.symbol("NASDAQ:TSLA", "NY 7 (Tesla)", group=grpNY)
ny_sym8 = input.symbol("NASDAQ:AVGO", "NY 8 (Broadcom)", group=grpNY)
ny_sym9 = input.symbol("NASDAQ:AMD",  "NY 9 (AMD)", group=grpNY)

// =====================================================================
// 4. FUNÇÕES GERAIS E EXTRAÇÃO
// =====================================================================
getClose(sym) =>
    if sym == "" or na(sym)
        na
    else
        request.security(sym, timeframe.period, close)

getName(sym) =>
    if sym == "" or na(sym)
        ""
    else
        arr = str.split(sym, ":")
        array.size(arr) > 1 ? array.get(arr, 1) : sym

// EXTRAÇÃO ÁSIA (8)
c_a1 = getClose(asia_sym1), c_a2 = getClose(asia_sym2), c_a3 = getClose(asia_sym3)
c_a4 = getClose(asia_sym4), c_a5 = getClose(asia_sym5), c_a6 = getClose(asia_sym6)
c_a7 = getClose(asia_sym7), c_a8 = getClose(asia_sym8)
arr_asia_closes = array.from(c_a1, c_a2, c_a3, c_a4, c_a5, c_a6, c_a7, c_a8)

n_a1 = getName(asia_sym1), n_a2 = getName(asia_sym2), n_a3 = getName(asia_sym3)
n_a4 = getName(asia_sym4), n_a5 = getName(asia_sym5), n_a6 = getName(asia_sym6)
n_a7 = getName(asia_sym7), n_a8 = getName(asia_sym8)
arr_asia_nom = array.from(n_a1, n_a2, n_a3, n_a4, n_a5, n_a6, n_a7, n_a8)

// EXTRAÇÃO LONDRES (8)
c_l1 = getClose(lnd_sym1), c_l2 = getClose(lnd_sym2), c_l3 = getClose(lnd_sym3)
c_l4 = getClose(lnd_sym4), c_l5 = getClose(lnd_sym5), c_l6 = getClose(lnd_sym6)
c_l7 = getClose(lnd_sym7), c_l8 = getClose(lnd_sym8)
arr_lnd_closes = array.from(c_l1, c_l2, c_l3, c_l4, c_l5, c_l6, c_l7, c_l8)

n_l1 = getName(lnd_sym1), n_l2 = getName(lnd_sym2), n_l3 = getName(lnd_sym3)
n_l4 = getName(lnd_sym4), n_l5 = getName(lnd_sym5), n_l6 = getName(lnd_sym6)
n_l7 = getName(lnd_sym7), n_l8 = getName(lnd_sym8)
arr_lnd_nom = array.from(n_l1, n_l2, n_l3, n_l4, n_l5, n_l6, n_l7, n_l8)

// EXTRAÇÃO NY (9)
c_n1 = getClose(ny_sym1), c_n2 = getClose(ny_sym2), c_n3 = getClose(ny_sym3)
c_n4 = getClose(ny_sym4), c_n5 = getClose(ny_sym5), c_n6 = getClose(ny_sym6)
c_n7 = getClose(ny_sym7), c_n8 = getClose(ny_sym8), c_n9 = getClose(ny_sym9)
arr_ny_closes = array.from(c_n1, c_n2, c_n3, c_n4, c_n5, c_n6, c_n7, c_n8, c_n9)

n_n1 = getName(ny_sym1), n_n2 = getName(ny_sym2), n_n3 = getName(ny_sym3)
n_n4 = getName(ny_sym4), n_n5 = getName(ny_sym5), n_n6 = getName(ny_sym6)
n_n7 = getName(ny_sym7), n_n8 = getName(ny_sym8), n_n9 = getName(ny_sym9)
arr_ny_nom = array.from(n_n1, n_n2, n_n3, n_n4, n_n5, n_n6, n_n7, n_n8, n_n9)


// =====================================================================
// 5. MEMÓRIA E LÓGICA (SHAPE-MATCHER)
// =====================================================================
var float mnq_open_asia = na
var float mnq_open_lnd = na
var float mnq_open_ny = na

var float[] asia_opens = array.new_float(8, na)
var float[] lnd_opens  = array.new_float(8, na)
var float[] ny_opens   = array.new_float(9, na)

var float[] asia_errors = array.new_float(8, 0.0)
var float[] lnd_errors  = array.new_float(8, 0.0)
var float[] ny_errors   = array.new_float(9, 0.0)

var string leaderASIA = "Aguardando..."
var string leaderLND  = "Aguardando..."
var string leaderNY   = "Aguardando..."

getArrow(o, c) =>
    if na(o) or na(c) or o == 0
        ""
    else if c > o
        " 🟢"
    else if c < o
        " 🔴"
    else
        " ⚪"

// CÁLCULO ÁSIA (0 a 7)
if isNewASIA
    mnq_open_asia := close
    for i = 0 to 7
        array.set(asia_opens, i, array.get(arr_asia_closes, i))
        array.set(asia_errors, i, 0.0)

if isASIA and not na(mnq_open_asia)
    float mnq_norm = close / mnq_open_asia
    float minErr1 = 999999.0
    float minErr2 = 999999.0
    string bestName1 = ""
    string bestName2 = ""
    
    for i = 0 to 7
        float sym_open = array.get(asia_opens, i)
        float sym_c = array.get(arr_asia_closes, i)
        string nome = array.get(arr_asia_nom, i)
        
        if not na(sym_open) and not na(sym_c) and sym_open != 0 and nome != ""
            float sym_norm = sym_c / sym_open
            float err = math.abs(mnq_norm - sym_norm)
            
            float new_err = array.get(asia_errors, i) + err
            array.set(asia_errors, i, new_err)
            
            string full_name = nome + getArrow(sym_open, sym_c)
            
            if new_err < minErr1
                minErr2 := minErr1
                bestName2 := bestName1
                minErr1 := new_err
                bestName1 := full_name
            else if new_err < minErr2
                minErr2 := new_err
                bestName2 := full_name
                
    string res = ""
    if bestName1 != ""
        res := bestName1
    if bestName2 != ""
        res += "  |  " + bestName2
        
    leaderASIA := res != "" ? res : "Calculando..."

// CÁLCULO LONDRES (0 a 7)
if isNewLND
    mnq_open_lnd := close
    for i = 0 to 7
        array.set(lnd_opens, i, array.get(arr_lnd_closes, i))
        array.set(lnd_errors, i, 0.0)

if isLND and not na(mnq_open_lnd)
    float mnq_norm = close / mnq_open_lnd
    float minErr1 = 999999.0
    float minErr2 = 999999.0
    string bestName1 = ""
    string bestName2 = ""
    
    for i = 0 to 7
        float sym_open = array.get(lnd_opens, i)
        float sym_c = array.get(arr_lnd_closes, i)
        string nome = array.get(arr_lnd_nom, i)
        
        if not na(sym_open) and not na(sym_c) and sym_open != 0 and nome != ""
            float sym_norm = sym_c / sym_open 
            float err = math.abs(mnq_norm - sym_norm)
            
            float new_err = array.get(lnd_errors, i) + err
            array.set(lnd_errors, i, new_err)
            
            string full_name = nome + getArrow(sym_open, sym_c)
            
            if new_err < minErr1
                minErr2 := minErr1
                bestName2 := bestName1
                minErr1 := new_err
                bestName1 := full_name
            else if new_err < minErr2
                minErr2 := new_err
                bestName2 := full_name
                
    string res = ""
    if bestName1 != ""
        res := bestName1
    if bestName2 != ""
        res += "  |  " + bestName2
        
    leaderLND := res != "" ? res : "Calculando..."

// CÁLCULO NY (0 a 8)
if isNewNY
    mnq_open_ny := close
    for i = 0 to 8
        array.set(ny_opens, i, array.get(arr_ny_closes, i))
        array.set(ny_errors, i, 0.0)

if isNY and not na(mnq_open_ny)
    float mnq_norm = close / mnq_open_ny
    float minErr1 = 999999.0
    float minErr2 = 999999.0
    string bestName1 = ""
    string bestName2 = ""
    
    for i = 0 to 8
        float sym_open = array.get(ny_opens, i)
        float sym_c = array.get(arr_ny_closes, i)
        string nome = array.get(arr_ny_nom, i)
        
        if not na(sym_open) and not na(sym_c) and sym_open != 0 and nome != ""
            float sym_norm = sym_c / sym_open
            float err = math.abs(mnq_norm - sym_norm)
            
            float new_err = array.get(ny_errors, i) + err
            array.set(ny_errors, i, new_err)
            
            string full_name = nome + getArrow(sym_open, sym_c)
            
            if new_err < minErr1
                minErr2 := minErr1
                bestName2 := bestName1
                minErr1 := new_err
                bestName1 := full_name
            else if new_err < minErr2
                minErr2 := new_err
                bestName2 := full_name
                
    string res = ""
    if bestName1 != ""
        res := bestName1
    if bestName2 != ""
        res += "  |  " + bestName2
        
    leaderNY := res != "" ? res : "Calculando..."


// =====================================================================
// 6. RENDERIZAÇÃO E MTF BIAS (DIÁRIO + 4H)
// =====================================================================

// >>> Lógica Diária (A mesma de antes: Ontem VS Anteontem)
[yestClose, prevYestHigh, prevYestLow] = request.security(syminfo.tickerid, "D", [close[1], high[2], low[2]], barmerge.gaps_off, barmerge.lookahead_on)

string biasDaily = "NEUTRAL ⚪"
if yestClose > prevYestHigh
    biasDaily := "BULLISH 🟢"
else if yestClose < prevYestLow
    biasDaily := "BEARISH 🔴"


// >>> Lógica de 4 Horas (Vela Fechada em tempo real)
[c4h, o4h] = request.security(syminfo.tickerid, "240", [close[1], open[1]], barmerge.gaps_off, barmerge.lookahead_on)

string bias4H = "⚪" // Neutro se empatou (raro)
if c4h > o4h
    bias4H := "🟢"
else if c4h < o4h
    bias4H := "🔴"


// Renderiza a Tabela
var table painelTexto = table.new(calcPos(), 1, 1, bgcolor=color.new(color.black, 100), border_width=0)

if barstate.islast
    string texto_BIAS = "Direction: Daily " + biasDaily + "  |  4H " + bias4H + "\n"
    string texto_ASIA = "Asia: " + leaderASIA + "\n"
    string texto_LND  = "London: " + leaderLND + "\n"
    string texto_NY   = "New York: " + leaderNY
    
    // Mesclando tudo
    string logicaFinal = texto_BIAS + texto_ASIA + texto_LND + texto_NY
    
    table.cell(painelTexto, column=0, row=0, text=logicaFinal, text_color=chart.fg_color, text_size=calcSize(), text_halign=text.align_left)
````
