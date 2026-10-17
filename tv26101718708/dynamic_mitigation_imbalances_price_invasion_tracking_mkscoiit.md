# Dynamic Mitigation Imbalances - Price Invasion Tracking

- url: https://www.tradingview.com/script/MksCoIIt/
- type: indicator
- pine_id: PUB;5f8cd79632b74036a5dc351f9dea573c
- version: 1.0

## Description

### Overview
This closed-source indicator introduces a novel methodology for tracking market inefficiencies (Imbalances / Fair Value Gaps) by incorporating a real-time, price-action-driven dynamic resizing mechanism. Unlike conventional FVG indicators that keep blocks static until full mitigation or delete them abruptly upon a simple touch, this script visually "consumes" and shrinks the historical boxes proportionally to price invasion.

### Core Logic & Mathematical Concepts
The script scans consecutive candle sequences to detect structurally significant displacement zones:
- **Bearish Imbalances:** Identified when a green candle sequence encounters a red sequence, and the lowest low of the green origin remains completely above the high of the current corrective development.
- **Bullish Imbalances:** Identified when a red candle sequence meets a green sequence, leaving a price gap where the highest high of the red origin remains below the low of the current corrective development.

### The Innovation: Dynamic Consumption
The cornerstone of this script is its dynamic recalculation engine via arrays:
1. **Original Metrics Storage:** The script memorizes the absolute height (size) of the original inefficiency upon creation.
2. **Invasion Tracking:** As subsequent candles develop, the script monitors intra-bar tracking (`high[0]` for bearish zones, `low[0]` for bullish zones). If the price breaches the box limits, the dimensions are recalculated on the fly (`box.set_bottom()` / `box.set_top()`), visually shrinking the box area.
3. **Percentage-Based Elimination Threshold:** Through an adjustable input parameter (`pctMitigacion`), users can establish an exact percentage threshold (e.g., 95%). The indicator actively calculates:
   Remaining Size <= Original Size * (1.0 - Mitigation Factor)
   Once this threshold is breached, the script efficiently flushes the box data from memory.

### How to Use
- **Visualizing Inefficiencies:** Broad zones display active, unmitigated market gaps.
- **Shrinking Boxes:** A shrinking box indicates institutional orders are actively filling the liquidity vacuum.
- **Execution Areas:** The remaining unmitigated fractions of the boxes serve as highly precise refined zones for entry or risk management.

## Source Code

````pine
//@version=5
indicator("Imbalances Personalizados - Consumo Dinámico e Invasión", overlay=true, max_boxes_count=500)

// --- Parámetros de Configuración ---
pctMitigacion = input.float(95.0, title="Porcentaje de Relleno para Eliminar", minval=1.0, maxval=100.0, step=5.0)

colorImbalanceBear = input.color(color.new(#ec92e0, 75), title="Color Imbalance Bajista (Amarillo)")
colorBordeBear     = input.color(color.new(#ec92e0, 85), title="Color Borde Bajista")

colorImbalanceBull = input.color(color.new(#39d7ec, 75), title="Color Imbalance Alcista (Azul/Celeste)")
colorBordeBull     = input.color(color.new(#39d7ec, 85), title="Color Borde Alcista")

// Matrices para guardar los bloques activos
var box[] bearBoxes = array.new<box>()
var box[] bullBoxes = array.new<box>()

// Matrices adicionales para recordar el TAMAÑO ORIGINAL del bloque (necesario para el cálculo del 95%)
var float[] bearOriginalSizes = array.new<float>()
var float[] bullOriginalSizes = array.new<float>()

// Definición de velas
isGreen = close > open
isRed   = close < open

float factorM = pctMitigacion / 100.0

// ==========================================
// LÓGICA 1: DETECCIÓN DE IMBALANCES BAJISTAS
// ==========================================
if isGreen and bar_index > 2
    int redCount = 0
    while (bar_index - 1 - redCount) >= 0 and isRed[1 + redCount]
        redCount := redCount + 1
        
    if redCount > 0
        int greenBlockStart = 1 + redCount
        int greenCount = 0
        while (bar_index - greenBlockStart - greenCount) >= 0 and isGreen[greenBlockStart + greenCount]
            greenCount := greenCount + 1
            
        if greenCount > 0
            float lowestGreenLow = low[greenBlockStart]
            int leftIndex = bar_index[greenBlockStart]
            for j = 0 to greenCount - 1
                if low[greenBlockStart + j] < lowestGreenLow
                    lowestGreenLow := low[greenBlockStart + j]
                    leftIndex := bar_index[greenBlockStart + j]
            
            float currGreenHigh = high
            if lowestGreenLow > currGreenHigh
                bx = box.new(left=leftIndex, top=lowestGreenLow, right=bar_index, bottom=currGreenHigh, 
                             bgcolor=colorImbalanceBear, border_color=colorBordeBear, extend=extend.none)
                array.push(bearBoxes, bx)
                array.push(bearOriginalSizes, lowestGreenLow - currGreenHigh) // Guardamos la distancia original

// ==========================================
// LÓGICA 2: DETECCIÓN DE IMBALANCES ALCISTAS
// ==========================================
if isRed and bar_index > 2
    int greenCount = 0
    while (bar_index - 1 - greenCount) >= 0 and isGreen[1 + greenCount]
        greenCount := greenCount + 1
        
    if greenCount > 0
        int redBlockStart = 1 + greenCount
        int redCount = 0
        while (bar_index - redBlockStart - redCount) >= 0 and isRed[redBlockStart + redCount]
            redCount := redCount + 1
            
        if redCount > 0
            float highestRedHigh = high[redBlockStart]
            int leftIndexBull = bar_index[redBlockStart]
            for j = 0 to redCount - 1
                if high[redBlockStart + j] > highestRedHigh
                    highestRedHigh := high[redBlockStart + j]
                    leftIndexBull := bar_index[redBlockStart + j]
            
            float currRedLow = low
            if currRedLow > highestRedHigh
                bx = box.new(left=leftIndexBull, top=currRedLow, right=bar_index, bottom=highestRedHigh, 
                             bgcolor=colorImbalanceBull, border_color=colorBordeBull, extend=extend.none)
                array.push(bullBoxes, bx)
                array.push(bullOriginalSizes, currRedLow - highestRedHigh) // Guardamos la distancia original

// ==========================================
// PROCESAMIENTO CON REDIMENSIONAMIENTO DINÁMICO
// ==========================================

// 1. Mitigación y Consumo de Bloques Bajistas (Amarillos)
if array.size(bearBoxes) > 0
    for i = array.size(bearBoxes) - 1 to 0 by 1
        box b = array.get(bearBoxes, i)
        float b_top = box.get_top(b)
        float b_bottom = box.get_bottom(b)
        float sizeOriginal = array.get(bearOriginalSizes, i)
        
        if bar_index > box.get_right(b)
            // Si el High actual invade el bloque por encima de su piso actual, lo REDIMENSIONAMOS (sube el piso)
            if high[0] > b_bottom
                box.set_bottom(b, high[0])
                b_bottom := high[0] // Actualizamos la variable local para el cálculo matemático inmediato
            
            // Calculamos cuánto queda del bloque respecto a su tamaño original
            float sizeActual = b_top - b_bottom
            
            // Si el bloque se redujo tanto que se consumió el 95% (o el tamaño es negativo/cero), lo eliminamos
            if sizeActual <= (sizeOriginal * (1.0 - factorM)) or b_bottom >= b_top
                box.delete(b)
                array.remove(bearBoxes, i)
                array.remove(bearOriginalSizes, i)
            else
                box.set_right(b, bar_index)
        else
            box.set_right(b, bar_index)

// 2. Mitigación y Consumo de Bloques Alcistas (Azules)
if array.size(bullBoxes) > 0
    for i = array.size(bullBoxes) - 1 to 0 by 1
        box b = array.get(bullBoxes, i)
        float b_top = box.get_top(b)
        float b_bottom = box.get_bottom(b)
        float sizeOriginal = array.get(bullOriginalSizes, i)
        
        if bar_index > box.get_right(b)
            // Si el Low actual invade el bloque por debajo de su techo actual, lo REDIMENSIONAMOS (baja el techo)
            if low[0] < b_top
                box.set_top(b, low[0])
                b_top := low[0] // Actualizamos la variable local
            
            // Calculamos el tamaño restante
            float sizeActual = b_top - b_bottom
            
            // Si se consumió el 95%, eliminamos
            if sizeActual <= (sizeOriginal * (1.0 - factorM)) or b_top <= b_bottom
                box.delete(b)
                array.remove(bullBoxes, i)
                array.remove(bullOriginalSizes, i)
            else
                box.set_right(b, bar_index)
        else
            box.set_right(b, bar_index)
````
