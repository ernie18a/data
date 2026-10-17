# CENTRAL Size Calculator

- url: https://www.tradingview.com/script/8eqXvega/
- type: indicator
- pine_id: PUB;fef6b67f25f34f05b2ce91e664d821f3
- version: 1.0

## Description

CENTRAL Size Calculator 📊
Optimiza tu gestión de riesgo de forma profesional directamente en el gráfico.
Esta herramienta es un calculador de lotaje dinámico diseñado para traders que buscan precisión y rapidez. Olvida las calculadoras externas; con CENTRAL Size Calculator, puedes ver exactamente cuánto operar basándote en tu capital y el riesgo que decidas asumir, todo visualizado en un panel elegante y minimalista. 
Características Principales:
Cálculo Automático de Lotes: Determina el tamaño de la posición ideal en función de tu balance, el porcentaje de riesgo y la distancia de tu Stop Loss en pips.
Detección Inteligente de Activos: Reconoce automáticamente si estás operando Forex (incluyendo pares con JPY) o CFDs para ajustar el valor del pip de forma precisa.
Panel UI Profesional: Interfaz limpia en la esquina inferior derecha que muestra:
Símbolo actual.
Balance de cuenta y riesgo en dólares ($).
Stop Loss configurado.
Lote Final sugerido (destacado en color lima para lectura rápida).
Modo Manual Avanzado: Opción para ingresar el valor del pip manualmente si operas activos con especificaciones particulares. 
¿Cómo usarlo?
Ingresa tu Balance de Cuenta.
Define el Porcentaje de Riesgo (ej. 1% o 0.5%).
Coloca los Pips de Stop Loss según tu análisis.
¡Listo! El panel te mostrará instantáneamente el lotaje que debes usar en tu plataforma de ejecución. 
Desarrollado por: Sebastián Figueroa

## Source Code

````pine
//@version=5
indicator("CENTRAL Size Calculator", overlay=true)

// ===== INPUTS =====
balance      = input.float(10000, "Account Balance ($)", minval=0)
riskPercent  = input.float(1, "Risk (%)", minval=0.1)
sl_pips      = input.float(13, "Stop Loss (pips)", minval=0.1)

// AVANZADO
use_manual   = input.bool(false, "Manual Pip Value")
manual_value = input.float(10, "Manual Value")

// ===== DETECCION =====
isForex = syminfo.type == "forex"
isJPY   = str.contains(syminfo.ticker, "JPY")

pip_size = isForex ? (isJPY ? 0.01 : 0.0001) : syminfo.mintick

auto_pip = (pip_size / syminfo.mintick) * syminfo.pointvalue
pip_value = use_manual ? manual_value : auto_pip

// ===== CALC =====
risk_amount = balance * (riskPercent / 100)
lot_size    = sl_pips > 0 ? risk_amount / (sl_pips * pip_value) : na
lot_final   = math.round(lot_size * 100) / 100

// ===== UI =====
var table panel = table.new(position.bottom_right, 2, 7, border_width=1)

// COLORES PROFESIONALES
bg_main   = color.new(color.black, 0)
bg_header = color.rgb(20, 20, 20)
bg_cell   = color.rgb(15, 15, 15)

txt_main  = color.white
txt_sub   = color.gray
accent    = color.rgb(0, 140, 255)

// ===== DISPLAY =====
if barstate.islast
    
    // HEADER
    table.cell(panel, 0, 0, "POSITION SIZE", text_color=txt_main, bgcolor=bg_header)
    table.cell(panel, 1, 0, "CALCULATOR", text_color=accent, bgcolor=bg_header)
    
    // AUTHOR (discreto)
    table.cell(panel, 0, 1, "Author", text_color=txt_sub, bgcolor=bg_cell)
    table.cell(panel, 1, 1, "Sebastián Figueroa", text_color=txt_main, bgcolor=bg_cell)
    
    // SYMBOL
    table.cell(panel, 0, 2, "Symbol", text_color=txt_sub, bgcolor=bg_cell)
    table.cell(panel, 1, 2, syminfo.ticker, text_color=txt_main, bgcolor=bg_cell)
    
    // BALANCE
    table.cell(panel, 0, 3, "Balance", text_color=txt_sub, bgcolor=bg_cell)
    table.cell(panel, 1, 3, "$" + str.tostring(balance), text_color=txt_main, bgcolor=bg_cell)
    
    // RISK
    table.cell(panel, 0, 4, "Risk", text_color=txt_sub, bgcolor=bg_cell)
    table.cell(panel, 1, 4, "$" + str.tostring(risk_amount), text_color=color.orange, bgcolor=bg_cell)
    
    // SL
    table.cell(panel, 0, 5, "Stop Loss", text_color=txt_sub, bgcolor=bg_cell)
    table.cell(panel, 1, 5, str.tostring(sl_pips) + " pips", text_color=color.red, bgcolor=bg_cell)
    
    // RESULTADO (DESTACADO)
    table.cell(panel, 0, 6, "Lot Size", text_color=accent, bgcolor=bg_cell)
    table.cell(panel, 1, 6, str.tostring(lot_final), text_color=color.lime, bgcolor=bg_cell)
````
