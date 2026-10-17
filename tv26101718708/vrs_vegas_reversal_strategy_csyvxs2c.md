# VRS (Vegas Reversal Strategy)

- url: https://www.tradingview.com/script/CSyvxS2C-VRS-Vegas-Reversal-Strategy/
- type: strategy
- pine_id: PUB;665887531a734bd690e75e7bb3bd3032
- version: 1.0

## Description

It is based on the reversal of the price after an accentuated volatility of the previous day. It is tested only on BTC, TF Day, and has an activation value equal to a spike of minimum 2.4% amplitude, a value that I have left in the settings free to be modified if it is found valid for other assets. 
In the settings you can change how many of the latest longs or shorts I want to view in the past, colors and various aesthetics. 
When the system detects a spike at the end of the day from 2.4% onwards it will signal the direction of Reversal, generating the 3 TP, dotted lines.

Entry into the market must be done at the close of the candle day, unfortunately at night time if you want to enter on the tick.
Stop above/below the spike that generated the condition.
If the Day2 candle closes FULL inside the spike, immediate and early closing of the operation.
There cannot be two consecutive Day events: if you are Long or Short and have taken a stop on the next candle, even if the latter generates another entry, this must not be activated.
TP 1 and 2 are both mandatory at 33% of the position, TP3, based on the current movement, can be considered to be left to run to the bitter end or in any case to structuring confirmations of a slowdown in the price.
Upon reaching TP1 it is mandatory to move the STOP to even.
In the event of the presence of extremely strong directional movements, for example Long direction, an opposite activation, Short, must be done but with reduced capital, on the contrary an activation in the same direction as the trend movement can be done with a surcharge. Always pay attention to Money Management and Risk Management.

Always manage Risk and Money Management in an adequate, technical and sustainable manner in relation to your capital. A fair exposure per transaction is between 1% and 2% of the capital.

## Source Code

````pine
//@version=5
strategy("VRS (Vegas Reversal Strategy)", overlay=true, default_qty_type=strategy.percent_of_equity, default_qty_value=10)

// Parametri
spikePercentage = input.float(2.5, title="Spike Percentage Threshold", minval=0.1) / 100

// Opzioni per visualizzare separatamente frecce e scritte "Long/Short"
showLongLabels = input.bool(true, title="Mostra etichette Long")
showShortLabels = input.bool(true, title="Mostra etichette Short")
showLongTPs = input.bool(true, title="Mostra linee Take Profit Long")
showShortTPs = input.bool(true, title="Mostra linee Take Profit Short")

// Parametro per il numero di barre dopo cui rimuovere le linee TP
tpLineDuration = input.int(50, title="Numero di barre per visualizzare le linee TP", minval=1)

// Opzione per il numero di attivazioni da visualizzare
historySize = input.int(5, title="Numero di attivazioni da visualizzare", options=[5, 10, 15])

// Opzioni per la personalizzazione delle etichette
longLabelColor = input.color(color.new(color.green, 0), title="Colore etichetta Long")
shortLabelColor = input.color(color.new(color.red, 0), title="Colore etichetta Short")
longLabelTextColor = input.color(color.white, title="Colore testo etichetta Long")
shortLabelTextColor = input.color(color.white, title="Colore testo etichetta Short")
labelFontSize = input.string("normal", title="Grandezza testo etichetta", options=["small", "normal", "large"])

// Calcolo delle lunghezze delle spike
upperSpike = high - math.max(close, open)
lowerSpike = math.min(close, open) - low

// Condizioni per validare una spike
validUpperSpike = upperSpike >= (close * spikePercentage)
validLowerSpike = lowerSpike >= (close * spikePercentage)

// Esclusione di attivazioni su spike contrapposte
validSpikeCondition = (validUpperSpike and not validLowerSpike) or (validLowerSpike and not validUpperSpike)

// Condizioni di entrata alla chiusura della candela che ha generato la spike
enterLongCondition = validSpikeCondition and validLowerSpike
enterShortCondition = validSpikeCondition and validUpperSpike

// Linee e etichette per i Take Profit e segnali
var line[] tpLines = array.new_line(0)
var label[] tpLabels = array.new_label(0)
var label[] entryLabels = array.new_label(0)

// Funzione per gestire le linee dei TP
f_add_tp_line(_y, _color, _labelText) =>
    tpLine = line.new(x1=bar_index, y1=_y, x2=bar_index + tpLineDuration, y2=_y, color=_color, width=1, style=line.style_dashed)
    array.push(tpLines, tpLine)
    midpoint = bar_index + tpLineDuration / 2
    tpLabel = label.new(x=midpoint, y=_y, text=_labelText, color=_color, textcolor=color.white, style=label.style_label_center, size=size.small)
    array.push(tpLabels, tpLabel)

// Funzione per gestire la rimozione di etichette e linee storiche
f_manage_history() =>
    while array.size(tpLines) > historySize
        line.delete(array.shift(tpLines))
    while array.size(tpLabels) > historySize
        label.delete(array.shift(tpLabels))
    while array.size(entryLabels) > historySize
        label.delete(array.shift(entryLabels))

// Aggiunge le linee TP, etichette e gestisce lo storico
if (enterLongCondition)
    f_manage_history()
    if showLongTPs
        f_add_tp_line(close + (lowerSpike * 1), color.green, "TP1")
        f_add_tp_line(close + (lowerSpike * 2), color.green, "TP2")
        f_add_tp_line(close + (lowerSpike * 2.5), color.green, "TP3")
    
    if showLongLabels
        entryLabel = label.new(bar_index, low, text="Long", style=label.style_label_down, 
                               color=longLabelColor, textcolor=longLabelTextColor, 
                               size=labelFontSize)
        array.push(entryLabels, entryLabel)

if (enterShortCondition)
    f_manage_history()
    if showShortTPs
        f_add_tp_line(close - (upperSpike * 1), color.red, "TP1")
        f_add_tp_line(close - (upperSpike * 2), color.red, "TP2")
        f_add_tp_line(close - (upperSpike * 2.5), color.red, "TP3")
    
    if showShortLabels
        entryLabel = label.new(bar_index, high, text="Short", style=label.style_label_up, 
                               color=shortLabelColor, textcolor=shortLabelTextColor, 
                               size=labelFontSize)
        array.push(entryLabels, entryLabel)

// Gestione dei Take Profit e dello Stop Loss
if strategy.position_size > 0  // Posizione lunga
    strategy.exit("TP1", "Long", limit=close + (lowerSpike * 1))
    strategy.exit("TP2", "Long", limit=close + (lowerSpike * 2), stop=strategy.position_avg_price)
    strategy.exit("TP3", "Long", limit=close + (lowerSpike * 2.5), stop=strategy.position_avg_price)

if strategy.position_size < 0  // Posizione corta
    strategy.exit("TP1", "Short", limit=close - (upperSpike * 1))
    strategy.exit("TP2", "Short", limit=close - (upperSpike * 2), stop=strategy.position_avg_price)
    strategy.exit("TP3", "Short", limit=close - (upperSpike * 2.5), stop=strategy.position_avg_price)
````
