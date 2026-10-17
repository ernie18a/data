# Rally Detection System

- url: https://www.tradingview.com/script/qYM9QFog-Rally-Detection-System/
- type: indicator
- pine_id: PUB;a7361bce2016496c830e7008814190d6
- version: 1.0

## Description

System for detecting the beginning of an upward trend

## Source Code

````pine
//@version=6
indicator(title="Sistem Detecție Raliuri Instituționale: Confluență EMA/SMA/RSI/MACD", shorttitle="Începutul Raliului", overlay=true)

// =====================================================================
// 1. DEFINIREA ȘI STRUCTURAREA PARAMETRILOR DE INTRARE (USER INPUTS)
// =====================================================================
// Crearea unui tablou de bord (UI) curat, care permite utilizatorului
// ajustarea constantelor fără a fi nevoie să modifice liniile de cod.

// Grup: Setările Mediilor Mobile
ema_rapida_len = input.int(defval=9, title="Perioada EMA Rapidă (Galben)", group="Filtre Trend & Momentum", minval=1)
ema_lenta_len  = input.int(defval=21, title="Perioada EMA Lentă (Portocaliu)", group="Filtre Trend & Momentum", minval=1)
sma_medie_len  = input.int(defval=50, title="Perioada SMA Suport (Albastru Deschis)", group="Filtre Trend Macro", minval=10)
sma_lunga_len  = input.int(defval=200, title="Perioada SMA Macro (Albastru Închis)", group="Filtre Trend Macro", minval=50)

// Grup: Setările Oscilatorilor și Accelerării
rsi_len = input.int(defval=14, title="Perioada Standard RSI", group="Indicatori de Forță și Accelerare", minval=2)
macd_fast = input.int(defval=12, title="Setare MACD Rapid", group="Indicatori de Forță și Accelerare")
macd_slow = input.int(defval=26, title="Setare MACD Lent", group="Indicatori de Forță și Accelerare")
macd_signal = input.int(defval=9, title="Setare Netezire Semnal MACD", group="Indicatori de Forță și Accelerare")

// =====================================================================
// 2. PRE-CALCULUL RUTINELOR MATEMATICE (PREVENIREA CORUPERII ISTORICULUI v6)
// =====================================================================
// Așa cum impun constrângerile arhitecturale Pine Script v6 referitoare la evaluarea leneșă,
// absolut toate funcțiile built-in care mențin un istoric computațional (ta.ema, ta.sma etc.) 
// trebuie apelate constant în spațiul global (global scope), pe fiecare bară analizată.

// Generarea vectorilor de serii temporale pentru Mediile Mobile
seria_ema9 = ta.ema(close, ema_rapida_len)
seria_ema21 = ta.ema(close, ema_lenta_len)
seria_sma50 = ta.sma(close, sma_medie_len)
seria_sma200 = ta.sma(close, sma_lunga_len)

// Generarea seriei temporale pentru oscilatorul Puterii Relative (RSI)
valoare_dinamica_rsi = ta.rsi(close, rsi_len)

// Generarea matricei de date pentru MACD. Funcția returnează simultan 3 elemente structurale (tuple unpack).
[linia_principala_macd, linia_semnal_macd, hist_macd] = ta.macd(close, macd_fast, macd_slow, macd_signal)

// =====================================================================
// 3. RENDERIZAREA VIZUALĂ ȘI REPREZENTAREA GRAFICĂ A ECHILIBRULUI
// =====================================================================
// Suprapunerea vizuală exactă pe graficul de preț pentru confirmarea manuală 
// de către utilizator a elementelor descrise în imaginile analizate anterior.

plot(seria_ema9, color=color.new(color.yellow, 0), title="EMA 9 (Rapidă)", linewidth=2)
plot(seria_ema21, color=color.new(color.orange, 0), title="EMA 21 (Lentă)", linewidth=2)
plot(seria_sma50, color=color.new(#29b6f6, 0), title="SMA 50 (Suport Dinamic)", linewidth=3) // Albastru Deschis
plot(seria_sma200, color=color.new(#1a237e, 0), title="SMA 200 (Barieră Macro)", linewidth=3) // Albastru Închis

// =====================================================================
// 4. MOTORUL DE EVALUARE LOGICĂ STRICTĂ (SISTEMUL BOOLEAN MULTI-STRAT)
// =====================================================================

// Filtrul A: Validarea Regimului de Piață și a Dominanței Macroeconomice.
bool regim_structural_aprobat = (close > seria_sma50)

// Filtrul B: Declanșatorul Cinetic de Volatilitate (Momentum Ignition).
bool impuls_cinetic_activat = ta.crossover(seria_ema9, seria_ema21)

// Filtrul C: Aprobarea Forței Relative Intrinseci a activului financiar.
bool rsi_valideaza_puterea = (valoare_dinamica_rsi > 50.0)

// Filtrul D: Confirmarea Accelerării și a Divergenței de Momentum.
bool macd_valideaza_accelerarea = (linia_principala_macd > linia_semnal_macd)

// =====================================================================
// 5. SINTEZA GENERATORULUI SINTETIC DE SEMNALE PENTRU RALIURI
// =====================================================================
// Algoritmul reunește logic și secvențial toate filtrele de decizie.

bool semnal_final_intrare_raliu = regim_structural_aprobat and impuls_cinetic_activat and rsi_valideaza_puterea and macd_valideaza_accelerarea

plotshape(series=semnal_final_intrare_raliu, title="Detecție Raliu", style=shape.triangleup, location=location.belowbar, color=color.new(color.lime, 0), size=size.normal, text="RALLY", textcolor=color.white)

// =====================================================================
// 6. GESTIONAREA PACHETULUI DE DATE, A ALERTELOR ȘI INTEGRAREA EXTERNĂ
// =====================================================================
if semnal_final_intrare_raliu
    string constructie_mesaj_json = '{"Command": "EXECUTE_LONG", "Ticker": "' + syminfo.ticker + '", "Entry_Price": ' + str.tostring(close) + ', "RSI_Level": ' + str.tostring(valoare_dinamica_rsi, "#.##") + ', "Momentum_Status": "CONFIRMED"}'
    alert(constructie_mesaj_json, alert.freq_once_per_bar_close)

// =====================================================================
// 7. TABEL DASHBOARD VIZUAL (UI)
// =====================================================================
// Implementare tabel dinamic cu afișare in timp real plasat în zona din dreapta.
var tabel_status = table.new(position.top_right, columns=2, rows=9, border_width=1, border_color=color.new(color.gray, 50))

if barstate.islast
    // Calcule dinamice pentru status tabel
    string stare_trend = seria_sma50 > seria_sma200? "Bullish" : "Bearish"
    color culoare_trend = seria_sma50 > seria_sma200? color.new(color.green, 20) : color.new(color.red, 20)
    
    string stare_sma50 = close > seria_sma50? "Peste" : "Sub"
    color culoare_sma50 = close > seria_sma50? color.new(color.green, 20) : color.new(color.red, 20)

    string stare_sma200 = close > seria_sma200? "Peste" : "Sub"
    color culoare_sma200 = close > seria_sma200? color.new(color.green, 20) : color.new(color.red, 20)

    string stare_ema = seria_ema9 > seria_ema21? "Bullish" : "Bearish"
    color culoare_ema = seria_ema9 > seria_ema21? color.new(color.green, 20) : color.new(color.red, 20)

    bool momentum_pozitiv = rsi_valideaza_puterea and macd_valideaza_accelerarea
    string stare_momentum = momentum_pozitiv? "Puternic" : "Slab"
    color culoare_momentum = momentum_pozitiv? color.new(color.green, 20) : color.new(color.red, 20)

    float extensie_val = ((close - seria_ema21) / seria_ema21) * 100
    string stare_extensie = str.tostring(extensie_val, "#.##") + "%"
    color culoare_extensie = color.new(color.orange, 0)

    int scor_curent = (seria_sma50 > seria_sma200? 1 : 0) + (close > seria_sma50? 1 : 0) + (close > seria_sma200? 1 : 0) + (seria_ema9 > seria_ema21? 1 : 0) + (valoare_dinamica_rsi > 50? 1 : 0) + (linia_principala_macd > linia_semnal_macd? 1 : 0) + (impuls_cinetic_activat? 1 : 0)
    string scor_trend_str = str.tostring(scor_curent) + "/7"
    color culoare_scor = scor_curent >= 5? color.new(color.green, 20) : color.new(color.orange, 0)

    string semnal_tabel = semnal_final_intrare_raliu? "Cumpărare" : "Așteaptă"
    color culoare_semnal = semnal_final_intrare_raliu? color.new(color.green, 20) : color.new(color.gray, 20)

    color culoare_bg_titluri = color.new(#4285f4, 10)
    color culoare_bg_celule = color.new(color.black, 90)

    // Renderizare Header
    table.cell(tabel_status, 0, 0, "Indicator", text_color=color.white, bgcolor=culoare_bg_titluri)
    table.cell(tabel_status, 1, 0, "Status", text_color=color.white, bgcolor=culoare_bg_titluri)

    // Rand 1: Trend
    table.cell(tabel_status, 0, 1, "Trend", text_color=color.gray, bgcolor=culoare_bg_celule)
    table.cell(tabel_status, 1, 1, stare_trend, text_color=color.white, bgcolor=culoare_trend)

    // Rand 2: SMA 50
    table.cell(tabel_status, 0, 2, "SMA 50", text_color=color.gray, bgcolor=culoare_bg_celule)
    table.cell(tabel_status, 1, 2, stare_sma50, text_color=color.white, bgcolor=culoare_sma50)

    // Rand 3: SMA 200
    table.cell(tabel_status, 0, 3, "SMA 200", text_color=color.gray, bgcolor=culoare_bg_celule)
    table.cell(tabel_status, 1, 3, stare_sma200, text_color=color.white, bgcolor=culoare_sma200)

    // Rand 4: EMA 9/21
    table.cell(tabel_status, 0, 4, "EMA 9/21", text_color=color.gray, bgcolor=culoare_bg_celule)
    table.cell(tabel_status, 1, 4, stare_ema, text_color=color.white, bgcolor=culoare_ema)

    // Rand 5: Momentum
    table.cell(tabel_status, 0, 5, "Momentum", text_color=color.gray, bgcolor=culoare_bg_celule)
    table.cell(tabel_status, 1, 5, stare_momentum, text_color=color.white, bgcolor=culoare_momentum)

    // Rand 6: Extensie
    table.cell(tabel_status, 0, 6, "Extensie", text_color=color.gray, bgcolor=culoare_bg_celule)
    table.cell(tabel_status, 1, 6, stare_extensie, text_color=color.white, bgcolor=culoare_extensie)

    // Rand 7: Score Trend
    table.cell(tabel_status, 0, 7, "Score Trend", text_color=color.gray, bgcolor=culoare_bg_celule)
    table.cell(tabel_status, 1, 7, scor_trend_str, text_color=color.white, bgcolor=culoare_scor)

    // Rand 8: Semnal
    table.cell(tabel_status, 0, 8, "Semnal", text_color=color.gray, bgcolor=culoare_bg_celule)
    table.cell(tabel_status, 1, 8, semnal_tabel, text_color=color.white, bgcolor=culoare_semnal)
````
