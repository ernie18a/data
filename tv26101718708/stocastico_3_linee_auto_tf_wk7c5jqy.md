# Stocastico 3 Linee [AUTO TF]

- url: https://www.tradingview.com/script/Wk7c5jQY/
- type: indicator
- pine_id: PUB;aa0b694035454325b3bdf0c747b580d3
- version: 1.0

## Description

**Stochastic 3 Lines [AUTO TF]** is an enhanced oscillator based on the classic Stochastic, featuring a third filter line calculated as a moving average of the %D. Designed to pinpoint momentum shifts and convergences with greater accuracy while filtering out market noise.

🚀 **Key Features:**
• 🔄 Automatic parameter adjustment based on Timeframe (1m, 5m, 15m, 1h, 4h)
• 🔧 Manual mode for full customization
• 🏷️ Real-time info label displaying active parameters
• 📐 20/80 levels for overbought/oversold zones
• 🧹 Clean chart: no intrusive shapes or alerts by default

📊 **Best for:** Scalping, Day Trading, and Swing Trading across Forex, Crypto, Indices, and Stocks.
⚙️ **Setup:** Toggle `Auto Parametri per TF` to use optimized presets, or disable it to input your custom values.

_________

**Stocastico 3 Linee [AUTO TF]** è un oscillatore evoluto basato sullo Stocastico classico, potenziato da una terza linea di filtro calcolata come media mobile della %D. Progettato per identificare con maggiore precisione le fasi di convergenza e il momentum, riducendo drasticamente i falsi segnali tipici dei timeframe veloci.

🚀 **Funzionalità principali:**
• 🔄 Cambio automatico dei parametri in base al Timeframe (1m, 5m, 15m, 1h, 4h)
• 🔧 Modalità manuale per personalizzare liberamente ogni input
• 🏷️ Etichetta informativa in tempo reale con i parametri attualmente attivi
• 📐 Livelli 20/80 per zone di ipercomprato/ipervenduto
• 🧹 Grafico pulito: nessuna forma o alert invasiva di default

📊 **Ideale per:** Scalping, Day Trading e Swing Trading su Forex, Crypto, Indici e Azioni.
⚙️ **Configurazione:** Attiva/disattiva `Auto Parametri per TF` per usare i preset ottimizzati, oppure disattivala per inserire i tuoi valori personalizzati.

___

🔹 **Come si usa:**
1. Aggiungi l'indicatore al grafico.
2. Di default, `Auto Parametri per TF` è ON: i valori si adattano automaticamente al timeframe selezionato.
3. L'etichetta in alto a destra mostra in tempo reale i parametri attivi.
4. Disattiva `Auto` per usare configurazioni manuali personalizzate.
5. Utilizza i livelli 80/20 come riferimento per estensioni e rientri del prezzo.

⚠️ **Nota:** Nessun segnale grafico (pallini/frecce) è attivo di default per mantenere il grafico pulito. La convergenza delle 3 linee va interpretata visivamente o combinata con la tua strategia di price action.

## Source Code

````pine
//@version=5
indicator("Stocastico 3 Linee [AUTO TF]", shorttitle="STOCH 3L", overlay=false)

// 1⃣ INPUT
autoTF = input.bool(true, "Auto Parametri per TF", group="⚙️ Impostazioni")
lenK_m  = input.int(10, "Periodo %K", group="🔧 Manuale (se Auto OFF)")
smK_m   = input.int(3,  "%K Smooth", group="🔧 Manuale (se Auto OFF)")
lenD_m  = input.int(3,  "%D Smooth", group="🔧 Manuale (se Auto OFF)")
len3_m  = input.int(9,  "Terza Linea", group="🔧 Manuale (se Auto OFF)") // ✅ Default impostato a 9

// 2⃣ SELEZIONE AUTOMATICA BASATA SUL TIMEFRAME
tf = timeframe.period

lenK  = autoTF ? (tf == "1" ? 8  : tf == "5" ? 10 : tf == "15" ? 14 : tf == "60" ? 21 : tf == "240" ? 34 : lenK_m) : lenK_m
smK   = autoTF ? (tf == "1" ? 2  : tf == "5" ? 3  : tf == "15" ? 3  : tf == "60" ? 5  : tf == "240" ? 5  : smK_m)  : smK_m
lenD  = autoTF ? (tf == "1" ? 2  : tf == "5" ? 3  : tf == "15" ? 3  : tf == "60" ? 5  : tf == "240" ? 5  : lenD_m)  : lenD_m
len3L = autoTF ? (tf == "1" ? 5  : tf == "5" ? 9  : tf == "15" ? 9  : tf == "60" ? 13 : tf == "240" ? 21 : len3_m) : len3_m

// 3⃣ CALCOLI
k_raw = ta.stoch(close, high, low, lenK)
k     = ta.sma(k_raw, smK)
d     = ta.sma(k, lenD)
line3 = ta.sma(d, len3L)

// 4⃣ GRAFICO
plot(k, "%K", color=color.blue, linewidth=2)
plot(d, "%D", color=color.red, linewidth=2)
plot(line3, "Terza", color=color.yellow, linewidth=2)
hline(80, "", color=color.gray, linestyle=hline.style_dotted)
hline(20, "", color=color.gray, linestyle=hline.style_dotted)

// 5⃣ ETICHETTA INFO (in alto a destra)
if barstate.islast
    var label info = label.new(x=bar_index, y=90, text="", style=label.style_label_down, color=color.new(color.black, 80), textcolor=color.white, textalign=text.align_left)
    label.set_text(info, "TF: " + tf + "\nK:" + str.tostring(lenK) + " | D:" + str.tostring(lenD) + " | 3ª:" + str.tostring(len3L))
````
