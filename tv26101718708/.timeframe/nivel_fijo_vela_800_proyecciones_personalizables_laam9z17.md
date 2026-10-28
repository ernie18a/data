# Nivel Fijo Vela 8:00 + Proyecciones Personalizables

- url: https://www.tradingview.com/script/Laam9Z17/
- type: indicator
- pine_id: PUB;447e9f40f99c4ccebc9ece311e18d44b
- version: 1.0

## Description

jhkhklkj btfrt
rthrtgt
rfjtr
fufthy
idsoihjdsoi
dsjpikjdsijd
kdaopjdpicjpd
hjocdshlcspd
pndlsnklkjncdlk
jdlijlisclicf
phikdsfhcolihksfliks
holhfojhodship
oluhrfhovlsrhof

## Source Code

````pine
//@version=5
indicator("Nivel Fijo Vela 8:00 + Proyecciones Personalizables", overlay=true)

// --- CONFIGURACIÓN GENERAL ---
zona_horaria = "UTC-4"
tf_referencia = "5" 

// --- INPUTS LÍNEAS PRINCIPALES ---
color_max = input.color(color.green, "Color Máximo (8:00)")
color_min = input.color(color.red, "Color Mínimo (8:00)")
ancho_linea = input.int(2, "Grosor Líneas Principales", minval=1)

// --- INPUTS LÍNEAS DE PROYECCIÓN ---
color_proy = input.color(color.gray, "Color Proyecciones")
ancho_proy = input.int(1, "Grosor Proyecciones", minval=1)
estilo_input = input.string("Discontinua", "Estilo Proyecciones", options=["Sólida", "Discontinua", "Punteada"])

// Función para convertir el texto del input en el estilo de línea de Pine Script
obtener_estilo(txt) =>
    switch txt
        "Sólida"      => line.style_solid
        "Discontinua" => line.style_dashed
        "Punteada"    => line.style_dotted
        => line.style_dashed

estilo_proy = obtener_estilo(estilo_input)

// --- LÓGICA DE DATOS ---
obtener_datos_800() =>
    es_800 = hour(time, zona_horaria) == 8 and minute(time, zona_horaria) == 0
    [es_800, high, low]

[es_vela_referencia, high_5min, low_5min] = request.security(syminfo.tickerid, tf_referencia, obtener_datos_800())

var float precio_alto_fijo = na
var float precio_bajo_fijo = na
var float rango_vela = na

var line linea_max = na
var line linea_min = na
var line linea_proy_arriba = na
var line linea_proy_abajo = na

// --- DIBUJO ---
if es_vela_referencia
    precio_alto_fijo := high_5min
    precio_bajo_fijo := low_5min
    rango_vela := high_5min - low_5min
    
    float proy_arriba = precio_alto_fijo + rango_vela
    float proy_abajo = precio_bajo_fijo - rango_vela
    
    // Limpieza de objetos
    line.delete(linea_max)
    line.delete(linea_min)
    line.delete(linea_proy_arriba)
    line.delete(linea_proy_abajo)
    
    // Líneas principales
    linea_max := line.new(bar_index, precio_alto_fijo, bar_index + 1, precio_alto_fijo, color=color_max, width=ancho_linea, extend=extend.right)
    linea_min := line.new(bar_index, precio_bajo_fijo, bar_index + 1, precio_bajo_fijo, color=color_min, width=ancho_linea, extend=extend.right)
    
    // Líneas de proyección con sus propios ajustes
    linea_proy_arriba := line.new(bar_index, proy_arriba, bar_index + 1, proy_arriba, color=color_proy, width=ancho_proy, style=estilo_proy, extend=extend.right)
    linea_proy_abajo := line.new(bar_index, proy_abajo, bar_index + 1, proy_abajo, color=color_proy, width=ancho_proy, style=estilo_proy, extend=extend.right)
````
