# Andean Volume Tracker

- url: https://www.tradingview.com/script/RrsC3wU1/
- type: indicator
- pine_id: PUB;1fcc10c7f67b417aacd65f69f67a5e3d
- version: 1.0

## Description

ENGLISH DESCRIPTION
Andean Volume Tracker is an advanced technical indicator designed to identify market absorption and seller exhaustion points on macro timeframes (1D, 1W, 1M). By combining price momentum dynamics with climatic volume confirmation, this tool highlights high-probability institutional trap zones.

📌 Core Components & Logic
Andean Oscillator Engine

Based on the original mathematical model developed by @AlexGrover.

Calculates the true bullish (Bull) and bearish (Bear) market components alongside a dynamic moving average (Signal).

Measures continuous buyer vs. seller strength without lag.

Climatic Volume Filter

Uses a Simple Moving Average (SMA) multiplied by a customizable threshold (1.15 by default) to filter out market noise.

Isolates candles where institutional volume significantly exceeds average activity.

Pattern & Trap Identification

🚨 Buying Absorption (Bear Trap): Triggered when the bullish component crosses above the bearish component (bullCross) during a high-volume bullish candle. Indicates buyers actively absorbing selling pressure.

🚨 Selling Exhaustion (Bull Trap): Triggered when the bearish component crosses above the bullish component (bearCross) during a high-volume bearish candle. Indicates aggressive selling into an exhausted order book.

🛠️ Customization Options
Andean Oscillator Parameters: Adjustable length (26) and signal smoothing (12).

Volume Thresholds: Customizable SMA period and multiplier for precise volume spikes.

Visual Styling: Fully customizable color palette and adjustable signal sizes (Tiny, Small, Normal, Large).

Alerts: Built-in alert conditions for real-time notifications on absorption and exhaustion signals.

💡 How to Use
Best applied on daily, weekly, or monthly timeframes for long-term trend continuation or reversal setups.

Green background highlights bullish volume dominant bars, while red background highlights bearish volume dominant bars.

Look for Absorción signals near key support levels and Agotamiento signals near key resistance levels.

Disclaimer: This indicator is for educational and analytical purposes only and does not constitute financial advice. Credits to @AlexGrover for the original Andean Oscillator concept.

DESCRIPCIÓN EN ESPAÑOL
Andean Volume Tracker es un indicador técnico avanzado diseñado para identificar puntos de absorción compradora y agotamiento vendedor en temporalidades macro (1D, 1S, 1M). Combina la dinámica de momentum del precio con la confirmación de volumen climático para señalar zonas de trampa con alta probabilidad institucional.

📌 Componentes Clave y Lógica
Motor Andean Oscillator

Basado en el modelo matemático original desarrollado por @AlexGrover.

Calcula los componentes reales alcistas (Bull) y bajistas (Bear) del mercado junto con una media móvil dinámica (Signal).

Mide la fuerza continua de compradores vs. vendedores sin retraso.

Filtro de Volumen Climático

Utiliza una Media Móvil Simple (SMA) multiplicada por un umbral configurable (1.15 por defecto) para filtrar el ruido del mercado.

Aísla velas donde el volumen institucional supera de forma significativa la actividad promedio.

Identificación de Patrones y Trampas

🚨 Absorción Compradora (Bear Trap): Se activa cuando el componente alcista cruza por encima del bajista (bullCross) durante una vela verde con volumen climático. Indica que los compradores están absorbiendo la presión vendedora.

🚨 Agotamiento Vendedor (Bull Trap): Se activa cuando el componente bajista cruza por encima del alcista (bearCross) durante una vela roja con volumen climático. Indica ventas agresivas sobre un libro de órdenes agotado.

🛠️ Opciones de Configuración
Parámetros del Andean Oscillator: Longitud (26) y suavizado de señal (12) ajustables.

Umbrales de Volumen: Período SMA y multiplicador personalizables para adaptar la detección de picos de volumen.

Estilo Visual: Paleta de colores totalmente personalizable y tamaño de señales adaptable (Diminuto, Pequeño, Normal, Grande).

Alertas: Condiciones de alerta integradas para notificaciones en tiempo real ante señales de absorción o agotamiento.

💡 Cómo Utilizarlo
Diseñado para usarse en gráficos diarios, semanales o mensuales para confirmar setups de continuación de tendencia o reversión.

El fondo verde destaca barras dominadas por volumen comprador, mientras que el fondo rojo señala volumen vendedor relevante.

Buscá las señales de Absorción cerca de niveles clave de soporte y las de Agotamiento cerca de resistencias importantes.

Aviso: Este indicador tiene fines exclusivamente educativos y analíticos y no constituye asesoramiento financiero. Créditos a @AlexGrover por el concepto original del Andean Oscillator.

## Source Code

````pine
//@version=6
indicator("Andean Volume Tracker", overlay=false, precision=4)

// ==========================================
// 1. INPUTS Y CONFIGURACIÓN
// ==========================================
// Configuración Andean Oscillator (Basado en el desarrollo original de Alex Grover)
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

// Flags booleanas para mapear el tamaño dinámico
isTiny   = shapeSizeStr == "Diminuto"
isSmall  = shapeSizeStr == "Pequeño"
isNormal = shapeSizeStr == "Normal"
isLarge  = shapeSizeStr == "Grande"

// ==========================================
// 2. FÓRMULA DEL ANDEAN OSCILLATOR
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

// Componentes del Andean
bull   = math.sqrt(math.max(0, dn2 - dn1 * dn1))
bear   = math.sqrt(math.max(0, up2 - up1 * up1))
signal = ta.ema(math.max(bull, bear), sig_length)

// ==========================================
// 3. CÁLCULO DE VOLUMEN Y PATRONES
// ==========================================
volMA     = ta.sma(volume, volMaLength)
isHighVol = volume > (volMA * volMult) // Volumen Climático
isBullish = close >= open              // Vela Verde
isBearish = close < open               // Vela Roja

// Cruces clave del Andean
bullCross = ta.crossover(bull, bear)  // Compradores superan a Vendedores
bearCross = ta.crossover(bear, bull)  // Vendedores superan a Compradores

// Detección de Absorción y Agotamiento con apoyo de Volumen
bearTrap = bullCross and isHighVol and isBullish // Absorción Compradora
bullTrap = bearCross and isHighVol and isBearish // Agotamiento Vendedor

// ==========================================
// 4. VISUALIZACIÓN EN PANEL
// ==========================================
// Fondo según dirección con Volumen Climático
bgColor = isHighVol ? (isBullish ? color.new(color.green, 80) : color.new(color.red, 80)) : na
bgcolor(bgColor, title="Fondo Ganador Volumen Climático")

// Trazado de líneas
plot(bull, "Bullish Component", color=colorBull, linewidth=2)
plot(bear, "Bearish Component", color=colorBear, linewidth=2)
plot(signal, "Signal", color=colorSig, linewidth=2, style=plot.style_line)

// Señales visuales con constantes explícitas size.* (Evita el error CE10123)
plotshape(bearTrap and isTiny,   "🚨 Absorción", shape.triangleup, location=location.bottom, color=color.lime, size=size.tiny)
plotshape(bearTrap and isSmall,  "🚨 Absorción", shape.triangleup, location=location.bottom, color=color.lime, size=size.small)
plotshape(bearTrap and isNormal, "🚨 Absorción", shape.triangleup, location=location.bottom, color=color.lime, size=size.normal)
plotshape(bearTrap and isLarge,  "🚨 Absorción", shape.triangleup, location=location.bottom, color=color.lime, size=size.large)

plotshape(bullTrap and isTiny,   "🚨 Agotamiento", shape.triangledown, location=location.top, color=color.red, size=size.tiny)
plotshape(bullTrap and isSmall,  "🚨 Agotamiento", shape.triangledown, location=location.top, color=color.red, size=size.small)
plotshape(bullTrap and isNormal, "🚨 Agotamiento", shape.triangledown, location=location.top, color=color.red, size=size.normal)
plotshape(bullTrap and isLarge,  "🚨 Agotamiento", shape.triangledown, location=location.top, color=color.red, size=size.large)

// ==========================================
// 5. ALERTAS
// ==========================================
alertcondition(bearTrap, title="🚨 Absorción Compradora", message="¡Atención! Cruce del Andean con Volumen Climático Comprador.")
alertcondition(bullTrap, title="🚨 Agotamiento Vendedor", message="¡Atención! Cruce del Andean con Volumen Climático Vendedor.")
````
