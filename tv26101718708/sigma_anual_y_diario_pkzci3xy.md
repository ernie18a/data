# Sigma Anual y Diario

- url: https://www.tradingview.com/script/PKZCi3xY/
- type: indicator
- pine_id: PUB;ec360fcf36c94cad813dddd16bd6dd1d
- version: 1.0

## Description

Cálculo de Sigma anual y diario de un activo. Parámetros útiles para conocer el comportamiento del activo que se vá a operar. Normalmente se usa 252 días, para analizar el comportamiento del ultimo año ya que el régimen de volatilidad cambia lo largo de la historia del activo

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © LFAlvarez

//@version=6
//@version=5
indicator("Sigma Anual y Diario", overlay=true)

// --- Inputs ---
lookback = input.int(252, title="Período Anual (Días Hábiles)", minval=10)
tablePos = input.string("top_right", title="Posición del Cuadro", options=["top_right", "bottom_right", "top_left", "bottom_left"])

// --- Cálculos Estadísticos Diarios ("D") ---
[dClose] = request.security(syminfo.tickerid, "D", [close])

// 1. Rendimiento Logarítmico Diario
logReturn = math.log(dClose / dClose[1])

// 2. Desviación Estándar de la muestra
dailyStDev = ta.stdev(logReturn, lookback)

// 3. Volatilidad Anualizada
annualizedSigma = dailyStDev * math.sqrt(lookback)

// 4. Sigma Diario derivado del Anualizado
dailySigmaFromAnnual = annualizedSigma / math.sqrt(lookback)

// --- Crear la Tabla ---
var table sigmaTable = table.new(position = tablePos, columns = 2, rows = 2, border_width = 1, border_color = color.gray)

if barstate.islast
    // Fila 1: Sigma Anualizado
    table.cell(sigmaTable, 0, 0, "Sigma Anualizado (σ)", text_color=color.white, bgcolor=color.rgb(30, 30, 30))
    table.cell(sigmaTable, 1, 0, str.tostring(annualizedSigma * 100, "0.00") + "%", text_color=color.rgb(248, 248, 248), bgcolor=color.rgb(30, 30, 30))
    
    // Fila 2: Sigma Diario
    table.cell(sigmaTable, 0, 1, "Sigma Diario (σ)", text_color=color.white, bgcolor=color.navy)
    table.cell(sigmaTable, 1, 1, "± " + str.tostring(dailySigmaFromAnnual * 100, "0.00") + "%", text_color=color.yellow, bgcolor=color.navy)
````
