# open close Sunday cripto

- url: https://www.tradingview.com/script/hMaXfr8R/
- type: indicator
- pine_id: PUB;66ebb4913b8447de906344e11cbf2a06
- version: 1.0

## Description

Tener el Open/Close semanal (domingo 20:00 UTC-4) te da el "Mapa del Dinero" en cripto.Aquí tienes sus 3 ventajas clave de forma corta y directa:Define el sesgo semanal: Si el precio cotiza por encima del Open es zona de compras (alcista); si cotiza por debajo, es zona de cortos (bajista).Imán de liquidez: El Open/Close semanal actúa como un soporte o resistencia institucional ultra fuerte donde el precio siempre reacciona o regresa a testear.Filtra trampas (Fakeouts): Te ayuda a identificar desviaciones. Si el precio rompe el Open el lunes pero regresa el martes, sabes que fue una manipulación para cazar stop-losses.

## Source Code

````pine
//@version=5
indicator("Línea Domingo 20:00 (UTC-4) Fijo", overlay=true)

// Configuración de la línea vertical
color_linea = input.color(color.new(color.red, 20), title="Color de la línea")

// Convertimos el tiempo UTC del gráfico a tu hora local restando 4 horas (en milisegundos)
tiempo_local = time - (4 * 60 * 60 * 1000)

// Extraemos el día, hora y minuto exactos en base a tu zona horaria (1 = Domingo)
dia_local   = timeframe.isintraday ? dayofweek(tiempo_local) : dayofweek
hora_local  = hour(tiempo_local)
min_local   = minute(tiempo_local)

// Detectamos el inicio de la barra. Buscamos el domingo a las 20:00 (8:00 PM)
// Para temporalidades de 1 hora, buscamos hora_local == 20.
// Usamos un filtro para que solo dibuje una única línea por cada domingo.
es_las_20_domingo = (dia_local == 1) and (hora_local == 20) and ta.change(time("D"))

// Dibujar la línea delgada en la vela exacta
if timeframe.isintraday and es_las_20_domingo
    line.new(bar_index, low, bar_index, high, extend=extend.both, color=color_linea, style=line.style_solid, width=1)
````
