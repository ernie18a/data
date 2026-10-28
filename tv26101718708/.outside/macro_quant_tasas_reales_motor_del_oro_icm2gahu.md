# Macro Quant: Tasas Reales (Motor del Oro)

- url: https://www.tradingview.com/script/iCm2gAhu/
- type: indicator
- pine_id: PUB;7c9a6adf5f4e45bbaa422a125e04ff88
- version: 1.0

## Description

Cómo interpretar este script en tu operativa diaria(función optima en temporalidad de 1d)
Una vez añadido, verás un panel debajo de tu gráfico del Oro. No mires este indicador buscando "sobrecompra" o "sobreventa". Estás mirando la brújula de los gestores de fondos de cobertura.

La Pendiente (El color de la línea): Cuando la línea se vuelve verde y apunta hacia abajo, significa que los rendimientos reales están cayendo. Esta es tu confirmación cuantitativa para buscar configuraciones largas (Longs) agresivas en XAU/USD. El viento institucional está a tu favor. Si la línea es roja y sube, el capital se está refugiando en renta fija; es momento de acortar objetivos en el Oro o buscar cortos.

El Nivel Cero (La Línea Punteada): Si la línea de las Tasas Reales perfora el nivel de cero hacia abajo (el fondo se tiñe de un verde suave), significa que la inflación es más alta que lo que pagan los bonos. En este régimen, mantener dólares en efectivo destruye poder adquisitivo. Históricamente, aquí es donde el Oro experimenta sus rupturas alcistas más violentas de varios cientos de dólares.

## Source Code

````pine
//@version=5
indicator("Macro Quant: Tasas Reales (Motor del Oro)", overlay=false, format=format.price, precision=2)

// =========================================================================
// 1. INPUTS DE DATOS INSTITUCIONALES
// =========================================================================
// TVC:US10Y representa el rendimiento del bono a 10 años.
// FRED:T10YIE es la tasa de inflación "Breakeven" esperada a 10 años.
ticker_yield = input.symbol("TVC:US10Y", title="Rendimiento Bono 10A (Nominal)")
ticker_inf   = input.symbol("FRED:T10YIE", title="Expectativa Inflación (Breakeven)")

// =========================================================================
// 2. EXTRACCIÓN Y CÁLCULO
// =========================================================================
// Forzamos la extracción en temporalidad diaria ("D") porque los datos macro 
// institucionales se actualizan a cierre diario, evitando ruido intradiario.
nominal   = request.security(ticker_yield, "D", close)
inflation = request.security(ticker_inf, "D", close)

// Ecuación de Fisher: Tasa Real = Tasa Nominal - Inflación Esperada
real_yield = nominal - inflation

// =========================================================================
// 3. LÓGICA DE DIRECCIONALIDAD Y COLOR
// =========================================================================
// Si la tasa real cae, el costo de oportunidad del Oro baja = Alcista para XAU (Verde)
// Si la tasa real sube, el capital fluye hacia los bonos = Bajista para XAU (Rojo)
color_linea = real_yield < real_yield[1] ? color.new(#089981, 0) : color.new(#F23645, 0)

// Régimen estructural (fondo del indicador)
// Si estamos bajo cero, es un régimen de "Refugio Absoluto" (impresión masiva/crisis).
color_fondo = real_yield < 0 ? color.new(#089981, 90) : color.new(#F23645, 90)

// =========================================================================
// 4. PLOTEO EN PANTALLA
// =========================================================================
plot(real_yield, title="Tasa de Interés Real (%)", color=color_linea, linewidth=3, style=plot.style_line)
hline(0, title="Línea Cero", color=color.gray, linestyle=hline.style_dashed, linewidth=1)

bgcolor(color_fondo, title="Régimen Macro")
````
