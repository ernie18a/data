<!-- tradingview-pine-id: PUB;879f4124478b4e308b2306e7a4f78ae7 -->
<!-- tradingviewscripts-format: 1 -->
# Asian Session XAUUSD by Capitanzor

Source: https://www.tradingview.com/script/4bHyZ4vQ/

## Description

This indicator highlights the Asian trading session (default 01:00–03:00, Europe/London time) on the chart — a period typically characterized by lower volatility and tighter price ranges in Gold (XAUUSD), before the London session opens.

The session's time range and timezone are fully configurable via the indicator's settings (input.session and input.string), allowing each trader to adapt it to their own local time and preferred session window, without needing to edit the code.

How it works:
- The script uses time() combined with input.session() to detect whether the current bar falls within the selected time range, converted to the chosen timezone.
- When the condition is true, the background is shaded in a light yellow color for easy visual identification.
- Useful for spotting pre-breakout consolidation zones ahead of higher-volatility sessions (e.g. London or New York open).

—

Este indicador resalta la sesión asiática (por defecto 01:00–03:00, hora de Londres) en el gráfico — un periodo típicamente caracterizado por baja volatilidad y rangos de precio más estrechos en el oro (XAUUSD), antes de la apertura de la sesión de Londres.

El rango horario y la zona horaria son totalmente configurables desde las opciones del indicador, permitiendo a cada trader adaptarlo a su hora local sin necesidad de tocar el código.

Cómo funciona:
- El script usa time() junto con input.session() para detectar si la vela actual cae dentro del rango horario seleccionado, convertido a la zona horaria elegida.
- Cuando la condición se cumple, el fondo se sombrea en amarillo claro para facilitar su identificación visual.
- Útil para detectar zonas de consolidación previas a sesiones de mayor volatilidad (ej. apertura de Londres o Nueva York).

---

## Source Code

````pine
//@version=6
indicator("Asian Session XAUUSD by Capitanzor", overlay=true)

// Rango horario (por defecto 01:00–03:00 Londres)
sess = input.session("0100-0300", "Sesión 1 a 3 AM")

// Detección de sesión usando zona horaria Londres
inSession = not na(time(timeframe.period, sess, "Europe/London"))

// Fondo amarillo durante la sesión
bgcolor(inSession ? color.new(color.yellow, 85) : na)
````
