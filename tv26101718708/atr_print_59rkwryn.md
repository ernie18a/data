# ATR Print

- url: https://www.tradingview.com/script/59rKWrYn/
- type: indicator
- pine_id: PUB;6289b3e455f84108a300f46b1f9c4c0d
- version: 1.0

## Description

L’indicatore è stato progettato per avere una lettura immediata della volatilità senza dover aprire pannelli separati o utilizzare indicatori aggiuntivi nella parte inferiore del chart.
Funzionalità
ATR calcolato su timeframe indipendente dal grafico corrente
Periodo ATR personalizzabile
Supporto per diversi metodi di smoothing:
RMA
SMA
EMA
WMA
Colore testo personalizzabile
Dimensione testo regolabile
Sfondo con trasparenza configurabile
Visualizzazione compatta e non invasiva
Formattazione numerica con separatore decimale “,”

## Source Code

````pine
//@version=5
indicator("ATR Print", overlay=true)

// ── Input personalizzabili
tf_input   = input.timeframe(defval="5", title="Timeframe ATR")
len_input  = input.int(defval=14, title="Periodo ATR", minval=1, maxval=1000)
smoothing  = input.string(defval="RMA", title="Tipo di smoothing", options=["RMA", "SMA", "EMA", "WMA"])
text_color = input.color(defval=color.white, title="Colore testo")
bg_color   = input.color(color.new(color.purple, 0), "Colore sfondo celle")
bg_transp  = input.int(defval=85, title="Trasparenza sfondo (0=opaco, 100=trasparente)", minval=0, maxval=100)
font_size  = input.string(defval="Normale", title="Dimensione testo", options=["Piccolo", "Normale", "Grande"])

// ── Conversione input in size Pine
f_get_text_size(fs) =>
    fs == "Piccolo" ? size.small : fs == "Grande" ? size.large : size.normal

// ── True Range manuale
f_true_range(h, l, c) =>
    hl  = h - l
    hc1 = math.abs(h - c[1])
    lc1 = math.abs(l - c[1])
    math.max(hl, math.max(hc1, lc1))

// ── ATR con smoothing selezionabile
f_atr(len, smooth_type) =>
    tr = f_true_range(high, low, close)
    smooth_type == "SMA" ? ta.sma(tr, len) :
     smooth_type == "EMA" ? ta.ema(tr, len) :
     smooth_type == "WMA" ? ta.wma(tr, len) :
     ta.rma(tr, len)  // default ATR

// ── Calcolo ATR sul timeframe scelto
atr_tf = request.security(syminfo.tickerid, tf_input, f_atr(len_input, smoothing), barmerge.gaps_off, barmerge.lookahead_off)

// ── Tabella in alto a destra con UNA riga vuota sopra (2 righe totali)
var tbl = table.new(position.top_right, 1, 1)

// Converto l’ATR in stringa con virgola
atr_str   = str.replace_all(str.tostring(atr_tf, format.mintick), ".", ",")
label_txt = " ATR: " + atr_str

// Riga 0: spaziatore trasparente (serve a “spingere” la riga utile più in basso)
//table.cell(table_id=tbl, column=0, row=2, text=" ", text_color=color.new(color.white, 100), text_halign=text.align_right, text_valign=text.align_top, text_size=f_get_text_size(font_size), bgcolor=color.new(color.black, 100))

// Riga 0: spaziatore trasparente (serve a “spingere” la riga utile più in basso)
//table.cell(table_id=tbl, column=0, row=1, text=" ", text_color=color.new(color.white, 100), text_halign=text.align_right, text_valign=text.align_top, text_size=f_get_text_size(font_size), bgcolor=color.new(color.black, 100))

// Riga 1: testo vero e proprio
table.cell(table_id=tbl, column=0, row=0, text=label_txt, text_color=text_color, text_halign=text.align_right, text_valign=text.align_top, text_size=f_get_text_size(font_size), bgcolor=bg_color)
````
