<!-- tradingview-pine-id: PUB;c98181c35019409ba70dca5f0e6f9cc5 -->
<!-- tradingviewscripts-format: 1 -->
# HORARIOS TRAMPA ARELISFX

Source: https://www.tradingview.com/script/g049pZgm/

## Description

HORARIOS TRAMPA ARELISFX
Sombrea automáticamente las franjas horarias de baja volatilidad, donde el precio se mueve pero no hay volumen institucional detrás sosteniendo la dirección. Son las horas en las que aparecen rupturas que no continúan y donde la mayoría de traders sobreoperan por aburrimiento.

Franjas marcadas por defecto (hora de España):
• 06:00 – 08:00 — Fin de Asia, antes de la apertura real de Londres
• 13:00 – 14:30 — Pausa de Londres, antes de Nueva York
• 17:00 – 18:30 — Cierre de Londres: las mesas europeas liquidan, no abren

Característica principal: las franjas se calculan siempre sobre la zona horaria seleccionada, no sobre la del gráfico. Vivas donde vivas y tengas el gráfico configurado como lo tengas, las zonas caen siempre sobre el mismo tramo real de mercado.
Las tres sesiones son totalmente editables. Lo recomendable es auditar tu bitácora, sacar tu rendimiento por franja horaria y ajustar las zonas a tus propios datos.
Indicador de apoyo al plan de trading. No genera señales de entrada ni de salida.

---

## Source Code

````pine
//@version=6
indicator("HORARIOS TRAMPA ARELISFX", overlay = true)
tz = input.string("Europe/Madrid", "Zona horaria", options = ["Europe/Madrid", "Europe/London", "America/New_York", "America/Bogota", "America/Mexico_City", "UTC"])
col = input.color(color.red, "Color")
transp = input.int(85, "Transparencia", minval = 50, maxval = 98)
s1 = input.session("0600-0800:1234567", "1 Amanecer")
s2 = input.session("1300-1430:1234567", "2 Pausa Londres")
s3 = input.session("1700-1830:1234567", "3 Cierre Londres")
en1 = not na(time(timeframe.period, s1, tz))
en2 = not na(time(timeframe.period, s2, tz))
en3 = not na(time(timeframe.period, s3, tz))
trampa = timeframe.isintraday and (en1 or en2 or en3)
bgcolor(trampa ? color.new(col, transp) : na, title = "No operar")
````
