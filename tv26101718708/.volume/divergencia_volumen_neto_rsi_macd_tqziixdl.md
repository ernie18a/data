# Divergencia (Volumen Neto, RSI, MACD)

- url: https://www.tradingview.com/script/tqziIXDl/
- type: indicator
- pine_id: PUB;1b008c66fc5249688e62d232ad1437ff
- version: 5.0

## Description

Divergencia (Volumen Neto, RSI, MACD)                                                                                              
                                                                                                                                     
  ¿Qué hace este indicador?                                                                                                          
                                                                                                                                     
  Detecta señales de posible cambio de dirección en el precio combinando tres filtros simultáneos: presión interna de la vela        
  (volumen neto), RSI y MACD. Solo marca una señal cuando los tres confirman al mismo tiempo — lo que reduce drásticamente el ruido y
   los falsos positivos.                                                                                                             
                  
  ---
  La lógica detrás del indicador
                                                                                                                                     
  La clave está en una observación sencilla pero poderosa: el precio de cierre dentro del rango de la vela revela quién ganó la 
  batalla.                                                                                                                           
                  
  - Si una vela cierra en rojo (bajista) pero el cierre está cerca del máximo, significa que aunque los vendedores arrastraron el    
  precio, los compradores recuperaron gran parte del terreno dentro de esa misma barra. Hay presión compradora oculta.
  - Si una vela cierra en verde (alcista) pero el cierre está cerca del mínimo, ocurre lo contrario: los compradores subieron el     
  precio pero los vendedores lo devolvieron casi al punto de partida. Hay presión vendedora oculta.                                  
  
  Esto es lo que el indicador llama Volumen Neto normalizado — un valor entre -1 y +1 que mide exactamente dónde cerró el precio     
  dentro del rango de la vela.
                                                                                                                                     
  Cuando esta presión oculta coincide con RSI en zona extrema y MACD en confirmación, el indicador dibuja una señal sobre el gráfico.
  
  ---                                                                                                                                
  Dos tipos de señal
                    
  Señal Compradora (verde, debajo de la vela)
  Se activa cuando:                                                                                                                  
  - La vela cierra en rojo (bajista externamente)
  - Pero internamente hay presión compradora (cierre cerca del máximo)                                                               
  - El RSI está en sobreventa (≤ 30 por defecto)                      
  - El histograma MACD es negativo (≤ 0)                                                                                             
  - El volumen supera el mínimo configurado                                                                                          
                                                                                                                                     
  Señal Vendedora (rojo, encima de la vela)                                                                                          
  Se activa cuando:                                                                                                                  
  - La vela cierra en verde (alcista externamente)
  - Pero internamente hay presión vendedora (cierre cerca del mínimo)                                                                
  - El RSI está en sobrecompra (≥ 70 por defecto)                    
  - El histograma MACD es positivo (≥ 0)                                                                                             
  - El volumen supera el mínimo configurado
                                                                                                                                     
  Cada señal muestra en pantalla el texto de la etiqueta junto con los valores exactos de RSI y MACD en ese momento.                 
                                                                                                                                     
  ---                                                                                                                                
  Datos reales, siempre                                                                                                              
                                                                                                                                     
  El indicador trabaja sobre datos OHLCV reales aunque el gráfico esté en modo Heikin-Ashi u otro tipo de vela. Así la lógica no se
  distorsiona por velas sintéticas.                                                                                                  
                  
  ---                                                                                                                                
  Configuración :
                                                                                                                                                                                                                                                                      
  La ventana de configuración tiene cinco secciones:
                                                                                                                                     
  - Señal Compradora — umbral de exigencia del ratio, texto de la etiqueta, color y forma del símbolo                                
  - Señal Vendedora — mismos parámetros para las señales de venta
  - Filtro de Volumen Neto — porcentaje mínimo sobre la media de 20 velas para que el volumen se considere relevante                 
  - RSI — período y niveles de sobreventa/sobrecompra                                                                                
  - MACD — períodos rápido, lento y señal, más los umbrales del histograma para cada dirección                                       
                                                                                                                                     
  ▎ Consejo: Subir el umbral del ratio (p. ej. a 0.3–0.5) hace las señales más escasas pero más limpias. Bajarlo a 0.05 da más       
  ▎ señales pero con más ruido.                                                                                                      
                                                                                                                                     
  ---             
  ¿Para quién es útil?
                      
  Para traders de price action y analistas técnicos que buscan puntos de giro de alta confluencia sin añadir múltiples indicadores
  por separado al gráfico. Al combinar tres filtros en uno solo, mantiene el gráfico limpio y solo marca los momentos donde la       
  divergencia interna de la vela, el momentum (RSI) y la tendencia de fuerza (MACD) apuntan en la misma dirección.
                                                                                                                                     
  Funciona en cualquier activo y temporalidad. Se recomienda especialmente en temporalidades de 1h en adelante para reducir el ruido 
  de mercado.

## Source Code

````pine
//@version=6
indicator("Divergencia (Vol. Neto, RSI, MACD) / Divergence (Net Vol, RSI, MACD)", overlay=true, max_bars_back=500)

// ── IDIOMA / LANGUAGE ─────────────────────────────────────────────────────────
lang = input.string("ES", "Idioma / Language", options=["ES", "EN"], group="Config")
es   = lang == "ES"

// ── Grupos / Groups ───────────────────────────────────────────────────────────
grp_buy  = "Señal Compradora / Buy Signal"
grp_sell = "Señal Vendedora / Sell Signal"
grp_vol  = "Filtro Volumen Neto / Net Volume Filter"
grp_rsi  = "RSI"
grp_macd = "MACD"

// ── Señal Compradora / Buy Signal ─────────────────────────────────────────────
i_buy_threshold = input.float(0.1,   "Umbral ratio / Min ratio",        minval=0.01, maxval=0.99, step=0.05, group=grp_buy,
     tooltip="ES: 0–1. Mayor = más exigente. | EN: 0–1. Higher = more selective.")
i_buy_text      = input.string("Compra", "Texto etiqueta / Label text",                                       group=grp_buy)
i_buy_color     = input.color(color.rgb(118, 230, 0), "Color",                                                group=grp_buy)
i_buy_shape     = input.string("Triángulo / Triangle", "Forma / Shape",
     options=["Flecha / Arrow","Triángulo / Triangle","Círculo / Circle","Diamante / Diamond","Cruz / Cross","Etiqueta / Label"],
     group=grp_buy)

// ── Señal Vendedora / Sell Signal ─────────────────────────────────────────────
i_sell_threshold = input.float(0.15,  "Umbral ratio / Min ratio",        minval=0.01, maxval=0.99, step=0.05, group=grp_sell,
     tooltip="ES: 0–1. Mayor = más exigente. | EN: 0–1. Higher = more selective.")
i_sell_text      = input.string("Venta", "Texto etiqueta / Label text",                                       group=grp_sell)
i_sell_color     = input.color(color.red, "Color",                                                            group=grp_sell)
i_sell_shape     = input.string("Triángulo / Triangle", "Forma / Shape",
     options=["Flecha / Arrow","Triángulo / Triangle","Círculo / Circle","Diamante / Diamond","Cruz / Cross","Etiqueta / Label"],
     group=grp_sell)

// ── Filtro de Volumen / Volume Filter ─────────────────────────────────────────
i_vol_pct = input.float(0.1, "Vol. mínimo / Min volume (% vs media/avg 20)", minval=0.0, maxval=3.0, step=0.10, group=grp_vol)

// ── RSI ───────────────────────────────────────────────────────────────────────
i_rsi_period   = input.int(9,    "Período / Period",                         minval=2,  maxval=50,  group=grp_rsi)
i_rsi_buy_max  = input.float(45, "RSI máx Compra / RSI max Buy (≤)",         minval=1,  maxval=49, step=1, group=grp_rsi,
     tooltip="ES: Compra si RSI ≤ valor. Ej: 30 = sobreventa. | EN: Buy if RSI ≤ value. Ex: 30 = oversold.")
i_rsi_sell_min = input.float(55, "RSI mín Venta / RSI min Sell (≥)",         minval=51, maxval=99, step=1, group=grp_rsi,
     tooltip="ES: Venta si RSI ≥ valor. Ej: 70 = sobrecompra. | EN: Sell if RSI ≥ value. Ex: 70 = overbought.")

// ── MACD ──────────────────────────────────────────────────────────────────────
i_macd_fast     = input.int(12,  "Rápida / Fast",                              minval=1, maxval=100, group=grp_macd)
i_macd_slow     = input.int(26,  "Lenta / Slow",                               minval=1, maxval=200, group=grp_macd)
i_macd_signal   = input.int(9,   "Señal / Signal",                             minval=1, maxval=100, group=grp_macd)
i_macd_buy_max  = input.float(0, "MACD máx Compra / MACD max Buy (≤)",  step=0.1, group=grp_macd,
     tooltip="ES: Compra si histograma MACD ≤ valor. | EN: Buy if MACD histogram ≤ value.")
i_macd_sell_min = input.float(0, "MACD mín Venta / MACD min Sell (≥)",  step=0.1, group=grp_macd,
     tooltip="ES: Venta si histograma MACD ≥ valor. | EN: Sell if MACD histogram ≥ value.")

// ── Fecha inicio visible / Visible start date ─────────────────────────────────
start_date = chart.left_visible_bar_time

// ── Datos reales (no Heikin-Ashi) / Real data ────────────────────────────────
real_open  = request.security(syminfo.tickerid, timeframe.period, open,  lookahead=barmerge.lookahead_off)
real_high  = request.security(syminfo.tickerid, timeframe.period, high,  lookahead=barmerge.lookahead_off)
real_low   = request.security(syminfo.tickerid, timeframe.period, low,   lookahead=barmerge.lookahead_off)
real_close = request.security(syminfo.tickerid, timeframe.period, close, lookahead=barmerge.lookahead_off)

// ── RSI ───────────────────────────────────────────────────────────────────────
rsi = ta.rsi(real_close, i_rsi_period)

// ── MACD ──────────────────────────────────────────────────────────────────────
[macd_line, signal_line, macd_hist] = ta.macd(real_close, i_macd_fast, i_macd_slow, i_macd_signal)

// ── Ratio volumen neto / Net volume ratio (−1 a +1) ───────────────────────────
hl_range = real_high - real_low
nv_ratio = hl_range > 0 ? (2.0 * real_close - real_high - real_low) / hl_range : 0.0

// ── Filtro de volumen / Volume filter ────────────────────────────────────────
avg_vol       = ta.sma(volume, 20)
vol_relevante = na(start_date) or volume >= avg_vol * i_vol_pct

// ── Condiciones / Conditions ─────────────────────────────────────────────────
in_range     = na(start_date) or time >= start_date
red_candle   = real_close < real_open
green_candle = real_close > real_open

div_bull = in_range and red_candle   and nv_ratio >  i_buy_threshold  and vol_relevante
         and rsi <= i_rsi_buy_max  and macd_hist <= i_macd_buy_max

div_bear = in_range and green_candle and nv_ratio < -i_sell_threshold and vol_relevante
         and rsi >= i_rsi_sell_min and macd_hist >= i_macd_sell_min

// ── Forma → estilo label / Shape → label style ───────────────────────────────
f_style_up(s) =>
    switch s
        "Flecha / Arrow"         => label.style_arrowup
        "Triángulo / Triangle"   => label.style_triangleup
        "Círculo / Circle"       => label.style_circle
        "Diamante / Diamond"     => label.style_diamond
        "Cruz / Cross"           => label.style_xcross
        =>                          label.style_label_up

f_style_down(s) =>
    switch s
        "Flecha / Arrow"         => label.style_arrowdown
        "Triángulo / Triangle"   => label.style_triangledown
        "Círculo / Circle"       => label.style_circle
        "Diamante / Diamond"     => label.style_diamond
        "Cruz / Cross"           => label.style_xcross
        =>                          label.style_label_down

// ── Textos bilingues en etiquetas / Bilingual label text ─────────────────────
lbl_rsi  = "RSI "
lbl_macd = "  MACD "

// ── Dibujar etiquetas / Draw labels ──────────────────────────────────────────
if div_bull
    label.new(bar_index, low,
      i_buy_text
      + "\n" + lbl_rsi  + str.tostring(math.round(rsi,       1))
      + lbl_macd        + str.tostring(math.round(macd_hist, 2)),
      style     = f_style_up(i_buy_shape),
      color     = color.new(i_buy_color, 20),
      textcolor = color.white,
      size      = size.small,
      yloc      = yloc.belowbar)

if div_bear
    label.new(bar_index, high,
      i_sell_text
      + "\n" + lbl_rsi  + str.tostring(math.round(rsi,       1))
      + lbl_macd        + str.tostring(math.round(macd_hist, 2)),
      style     = f_style_down(i_sell_shape),
      color     = color.new(i_sell_color, 20),
      textcolor = color.white,
      size      = size.small,
      yloc      = yloc.abovebar)
````
