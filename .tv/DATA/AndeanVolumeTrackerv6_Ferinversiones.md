<!-- tradingview-pine-id: PUB;27d087917a494d3b914044a78edee362 -->
<!-- tradingviewscripts-format: 1 -->
# Andean_Volume_Tracker_v6 Fer_inversiones

Source: https://www.tradingview.com/script/5rEguLC1/

## Description

====================================================================
🇪🇸 DESCRIPCIÓN EN ESPAÑOL
====================================================================

📌 Resumen del Indicador :
Andean Volume Tracker V5 Fer_inversiones es una herramienta avanzada de análisis técnico diseñada para identificar trampas de mercado (falsas rupturas), absorciones en zonas de soporte y agotamientos en zonas de resistencia.

Este indicador combina la precisión matemática del algoritmo original del Andean Oscillator (desarrollado por Alex Grover) con un filtro de Volumen Climático Institucional y un sistema visual de alertas dinámicas. Está especialmente optimizado para traders de Swing Trading y Position Trading que analizan gráficos en temporalidades macro (1D, 1S y 1M).

--------------------------------------------------------------------
🧠 Lógica Operativa y Funcionamiento

1. Andean Oscillator (Líneas de Fuerza):
   - Verde Flúor (Bulls): Representa la fuerza acumulada de los compradores.
   - Rojo Fuerte (Bears): Representa la fuerza acumulada de los vendedores.
   - Línea Blanca (Signal): Promedio móvil exponencial de la fuerza dominante que sirve como pivote de confirmación.

2. Fondo Ganador de Volumen Climático:
   - Fondo Verde: Aparece cuando la vela actual cierra alcista y su volumen supera la Media Móvil de Volumen multiplicada por el factor de clímax (intención compradora real).
   - Fondo Rojo: Aparece cuando la vela actual cierra bajista con volumen institucional (intención vendedora real).

3. Detección de Trampas y Absorciones (Señales Visuales):
   - 🚨 Triángulo Verde (Abajo): Absorción Compradora / Bear Trap. Se activa cuando el Andean realiza un cruce alcista sostenido por un volumen climático comprador en niveles de soporte claves.
   - 🚨 Triángulo Rojo (Arriba): Agotamiento Vendedor / Bull Trap. Se activa cuando el Andean realiza un cruce bajista sostenido por un volumen climático vendedor en niveles de resistencia.

--------------------------------------------------------------------
⚙️ Configuraciones Sugeridas por Temporalidad

• Gráfico Diario (1D):
  - Andean Length: 26 | Signal Length: 12
  - Volume MA: 20 | Multiplicador: 1.15 a 1.25
  - Propósito: Filtro de ruido mensual y captura de absorciones en soportes/resistencias.

• Gráfico Semanal (1S):
  - Andean Length: 26 | Signal Length: 12
  - Volume MA: 12 | Multiplicador: 1.10 a 1.15
  - Propósito: Captura de giros institucionales trimestrales.

• Gráfico Mensual (1M):
  - Andean Length: 12 | Signal Length: 6
  - Volume MA: 6 | Multiplicador: 1.05 a 1.10
  - Propósito: Detección de techos y pisos de ciclo de largo plazo.

--------------------------------------------------------------------
🙏 Créditos
Algoritmo base del Andean Oscillator desarrollado originalmente por Alex Grover (licencia CC BY-NC-SA 4.0).

⚠️ Descargo de responsabilidad: Este indicador tiene fines educativos y de análisis técnico. No constituye asesoramiento financiero. El trading implica riesgo de pérdida de capital.

====================================================================
🇬🇧 ENGLISH DESCRIPTION
====================================================================

📌 Indicator Overview
Fer Andean Volume Tracker is an advanced technical analysis tool designed to spot market traps (fake breakouts), absorption at support levels, and exhaustion at resistance zones.

This indicator combines the mathematical foundation of the original Andean Oscillator (developed by Alex Grover) with an Institutional Climax Volume filter and a clean visual alert system. It is fully optimized for Swing Traders and Position Traders analyzing macro timeframes (1D, 1W, 1M).

--------------------------------------------------------------------
🧠 How It Works

1. Andean Oscillator (Strength Lines):
   - Neon Green (Bulls): Measures the accumulated strength of buyers.
   - Bright Red (Bears): Measures the accumulated strength of sellers.
   - White Line (Signal): Exponential Moving Average of the dominant force, serving as a crossover confirmation line.

2. Climax Volume Background Winner:
   - Green Background: Triggers when the current candle closes bullish with volume exceeding the Volume Moving Average multiplied by the climax factor (true buying intent).
   - Red Background: Triggers when the current candle closes bearish with institutional volume (true selling intent).

3. Traps & Absorption Signals:
   - 🚨 Green Triangle (Bottom): Bullish Absorption / Bear Trap. Confirms when the Andean Oscillator crosses upward accompanied by institutional buying volume at key support zones.
   - 🚨 Red Triangle (Top): Bearish Exhaustion / Bull Trap. Confirms when the Andean Oscillator crosses downward accompanied by institutional selling volume at resistance zones.

--------------------------------------------------------------------
⚙️ Recommended Settings by Timeframe

• Daily Chart (1D):
  - Andean Length: 26 | Signal Length: 12
  - Volume MA: 20 | Multiplier: 1.15 to 1.25
  - Core Objective: Noise filtering & key support absorption.

• Weekly Chart (1W):
  - Andean Length: 26 | Signal Length: 12
  - Volume MA: 12 | Multiplier: 1.10 to 1.15
  - Core Objective: Quarterly institutional reversal detection.

• Monthly Chart (1M):
  - Andean Length: 12 | Signal Length: 6
  - Volume MA: 6 | Multiplier: 1.05 to 1.10
  - Core Objective: Major cycle top and bottom detection.

--------------------------------------------------------------------
🙏 Credits
Base Andean Oscillator algorithm originally created by Alex Grover (licensed under CC BY-NC-SA 4.0).

⚠️ Disclaimer: This indicator is for educational and technical analysis purposes only and does not constitute financial advice. Trading carries significant financial risk.

---

## Source Code

````pine
//@version=6
indicator("Andean_Volume_Tracker_v6 Fer_inversiones", overlay=false, precision=4)

// ==========================================
// 1. INPUTS Y CONFIGURACIÓN
// ==========================================
// Configuración Andean Oscillator (Tus parámetros: 26 y 12)
andeanGroup   = "Configuración Andean Oscillator"
length        = input.int(26, "Length", group=andeanGroup)
sig_length    = input.int(12, "Signal Length", group=andeanGroup)

// Configuración Volumen Climático
volGroup      = "Configuración Volumen"
volMaLength   = input.int(20, "Media Móvil de Volumen", group=volGroup)
volMult       = input.float(1.15, "Multiplicador Volumen Climático", group=volGroup, tooltip="Ajustado en 1.15 por defecto para temporalidades macro 1D, 1S, 1M")

// Configuración Visual
visualGroup   = "Configuración Visual"
colorBull     = input.color(#00FF00, "Color Compradores (Verde Flúor)", group=visualGroup)
colorBear     = input.color(#FF0000, "Color Vendedores (Rojo Fuerte)", group=visualGroup)
colorSig      = input.color(#FFFFFF, "Color Señal (Blanco)", group=visualGroup)
shapeSizeStr  = input.string("Pequeño", "Tamaño de las Señales", options=["Diminuto", "Pequeño", "Normal", "Grande"], group=visualGroup)

// Mapeo del tamaño para las condiciones de ploteo
isTiny   = shapeSizeStr == "Diminuto"
isSmall  = shapeSizeStr == "Pequeño"
isNormal = shapeSizeStr == "Normal"
isLarge  = shapeSizeStr == "Grande"

// ==========================================
// 2. FÓRMULA EXACTA DEL ANDEAN OSCILLATOR (Alex Grover)
// ==========================================
alpha = 2.0 / (length + 1)

var up1 = 0.0, var up2 = 0.0
var dn1 = 0.0, var dn2 = 0.0

C = close
O = open

up1 := nz(math.max(C, O, up1[1] - (up1[1] - C) * alpha), C)
up2 := nz(math.max(C * C, O * O, up2[1] - (up2[1] - C * C) * alpha), C * C)

dn1 := nz(math.min(C, O, dn1[1] + (C - dn1[1]) * alpha), C)
dn2 := nz(math.min(C * C, O * O, dn2[1] + (C * C - dn2[1]) * alpha), C * C)

// Componentes exactos del Andean
bull   = math.sqrt(math.max(0, dn2 - dn1 * dn1))
bear   = math.sqrt(math.max(0, up2 - up1 * up1))
signal = ta.ema(math.max(bull, bear), sig_length)

// ==========================================
// 3. CÁLCULO DE VOLUMEN Y TRAMPAS
// ==========================================
volMA     = ta.sma(volume, volMaLength)
isHighVol = volume > (volMA * volMult) // Volumen Climático
isBullish = close >= open              // Vela Verde
isBearish = close < open               // Vela Roja

// Cruces claves del Andean
bullCross = ta.crossover(bull, bear)  // Compradores ganan a Vendedores
bearCross = ta.crossover(bear, bull)  // Vendedores ganan a Compradores

// Detectar Trampas (Cruce del Andean apoyado con Volumen Climático)
bearTrap = bullCross and isHighVol and isBullish // Absorción Compradora
bullTrap = bearCross and isHighVol and isBearish // Agotamiento Vendedor

// ==========================================
// 4. VISUALIZACIÓN EN PANEL
// ==========================================
// Fondo con Ganador de Volumen Climático
bgColor = isHighVol ? (isBullish ? color.new(color.green, 80) : color.new(color.red, 80)) : na
bgcolor(bgColor, title="Fondo Ganador Volumen Climático")

// Ploteo exacto de líneas
plot(bull, 'Bullish Component', color=colorBull, linewidth=2)
plot(bear, 'Bearish Component', color=colorBear, linewidth=2)
plot(signal, 'Signal', color=colorSig, linewidth=2, style=plot.style_line)

// Señales visuales de Trampa
plotshape(bearTrap and isTiny, "🚨 Absorción (Diminuto)", shape.triangleup, location=location.bottom, color=color.lime, size=size.tiny)
plotshape(bearTrap and isSmall, "🚨 Absorción (Pequeño)", shape.triangleup, location=location.bottom, color=color.lime, size=size.small)
plotshape(bearTrap and isNormal, "🚨 Absorción (Normal)", shape.triangleup, location=location.bottom, color=color.lime, size=size.normal)
plotshape(bearTrap and isLarge, "🚨 Absorción (Grande)", shape.triangleup, location=location.bottom, color=color.lime, size=size.large)

plotshape(bullTrap and isTiny, "🚨 Agotamiento (Diminuto)", shape.triangledown, location=location.top, color=color.red, size=size.tiny)
plotshape(bullTrap and isSmall, "🚨 Agotamiento (Pequeño)", shape.triangledown, location=location.top, color=color.red, size=size.small)
plotshape(bullTrap and isNormal, "🚨 Agotamiento (Normal)", shape.triangledown, location=location.top, color=color.red, size=size.normal)
plotshape(bullTrap and isLarge, "🚨 Agotamiento (Grande)", shape.triangledown, location=location.top, color=color.red, size=size.large)

// ==========================================
// 5. ALERTAS
// ==========================================
alertcondition(bearTrap, title="🚨 Falsa Baja (Bear Trap)", message="¡Atención! Cruce del Andean con Volumen Climático Comprador.")
alertcondition(bullTrap, title="🚨 Falsa Suba (Bull Trap)", message="¡Atención! Cruce del Andean con Volumen Climático Vendedor.")
````
