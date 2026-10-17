# CRT Hour Protection H1/H4/H12

- url: https://www.tradingview.com/script/QxDBPuLw/
- type: indicator
- pine_id: PUB;e8ce8b0959b14bdebab5f79c65f6fde4
- version: 1.0

## Description

[b]CRT Hour Protection H1/H4/H12[/b]
Indicador de protección de cambio de vela para las temporalidades H1, H4 y H12. Su función es alertar visualmente sobre los últimos minutos antes del cierre de cada vela de temporalidad superior, ayudando a evitar entradas en zonas de alta volatilidad institucional o manipulación de precio que suelen producirse en esos momentos.

[b]¿Qué hace?[/b]
Colorea el fondo del gráfico durante los N minutos finales de cada ciclo horario, con tres niveles de zona diferenciados por color:
⬜ Zona H1 — Se activa en los últimos minutos antes del cierre de cada vela de 1 hora. Color gris por defecto.
🟠 Zona H4 — Se activa cuando esos mismos minutos finales coinciden con el cierre de una vela de 4 horas (0h, 4h, 8h, 12h, 16h, 20h). Color naranja por defecto. Tiene prioridad sobre H1.
🔵 Zona H12 — Se activa cuando coinciden con el cierre de una vela de 12 horas (0h y 12h). Color azul por defecto. Tiene prioridad sobre H4 y H1.

Cuando varias zonas se solapan, siempre se muestra únicamente la de mayor temporalidad, evitando ruido visual. Al inicio de cada zona aparece una línea vertical y una etiqueta identificativa, ambas configurables.
Configuración

Minutos de protección ajustables (por defecto 15)
Límite de timeframe: el indicador se desactiva automáticamente en gráficos superiores al TF configurado
Colores personalizables para cada zona
Línea vertical con grosor y estilo configurable (sólida, punteada, discontinua)
Etiquetas activables con tamaño ajustable

Uso recomendado: gráficos de M1 a M15 en instrumentos con alta liquidez como XAUUSD, EURUSD o índices. Evitar abrir nuevas operaciones mientras el fondo esté coloreado.

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0
// @deivid3k 

//@version=5
indicator("CRT Hour Protection H1/H4/H12", overlay=true, max_bars_back=500)

// ═══════════════════════════════════════════════════════════
// INPUTS
// ═══════════════════════════════════════════════════════════

grp1 = "⏱ Configuración"
minutos_h1  = input.int(15, "Minutos protección (final de vela)", minval=1, maxval=59, group=grp1)
tf_max      = input.int(15, "Mostrar solo hasta TF (min)",        minval=1, maxval=60,  group=grp1)

grp2 = "🎨 Colores de zona"
color_h1    = input.color(color.new(color.orange, 60), "Color zona H1  (15 min finales)",  group=grp2)
color_h4    = input.color(color.new(color.blue,   55), "Color zona H4  (15 min finales)",  group=grp2)
color_h12   = input.color(color.new(color.purple, 50), "Color zona H12 (15 min finales)",  group=grp2)

grp3 = "🔲 Línea vertical"
mostrar_linea   = input.bool(true, "Mostrar línea vertical",    group=grp3)
ancho_linea     = input.int(1,     "Grosor",  minval=1, maxval=4, group=grp3)
estilo_linea_in = input.string("Sólida", "Estilo", options=["Sólida","Punteada","Discontinua"], group=grp3)

grp4 = "🏷 Etiquetas"
mostrar_label   = input.bool(true, "Mostrar etiqueta",  group=grp4)
size_label      = input.string("small", "Tamaño", options=["tiny","small","normal","large"], group=grp4)

// ═══════════════════════════════════════════════════════════
// SOLO ACTIVO EN TFs PEQUEÑOS
// ═══════════════════════════════════════════════════════════

tf_mins = timeframe.in_seconds() / 60
activo  = tf_mins <= tf_max

// ═══════════════════════════════════════════════════════════
// CÁLCULO DE MINUTO ABSOLUTO DENTRO DE CADA CICLO
// ═══════════════════════════════════════════════════════════

h = hour(time)
m = minute(time)

// Minuto absoluto desde medianoche
min_abs = h * 60 + m

// Minuto dentro del ciclo de 4H  (0-239)
min_en_4h  = min_abs % 240

// Minuto dentro del ciclo de 12H (0-719)
min_en_12h = min_abs % 720

// Cuántos minutos faltan para el cierre de cada ciclo
faltan_h1  = 60  - (m % 60)
faltan_h4  = 240 - min_en_4h
faltan_h12 = 720 - min_en_12h

// ═══════════════════════════════════════════════════════════
// ZONA ACTIVA CON PRIORIDAD: H12 > H4 > H1
// ═══════════════════════════════════════════════════════════

zona_h1  = activo and faltan_h1  <= minutos_h1
zona_h4  = activo and faltan_h4  <= minutos_h1
zona_h12 = activo and faltan_h12 <= minutos_h1

// Color con prioridad: si coinciden varias zonas gana la mayor
color_fondo =
     zona_h12 ? color_h12 :
     zona_h4  ? color_h4  :
     zona_h1  ? color_h1  :
     na

// ═══════════════════════════════════════════════════════════
// PINTAR EL FONDO DE LA VELA
// ═══════════════════════════════════════════════════════════

bgcolor(color_fondo)

// ═══════════════════════════════════════════════════════════
// LÍNEA VERTICAL AL INICIO DE CADA ZONA
// ═══════════════════════════════════════════════════════════

estilo_linea = estilo_linea_in == "Punteada"    ? line.style_dotted :
               estilo_linea_in == "Discontinua" ? line.style_dashed  :
               line.style_solid

// Detectar el PRIMER bar que entra en cada zona (flanco de subida)
inicio_h12 = zona_h12 and not zona_h12[1]
inicio_h4  = zona_h4  and not zona_h4[1]  and not zona_h12
inicio_h1  = zona_h1  and not zona_h1[1]  and not zona_h4 and not zona_h12

color_linea =
     inicio_h12 ? color_h12 :
     inicio_h4  ? color_h4  :
     inicio_h1  ? color_h1  :
     na

if mostrar_linea and (inicio_h1 or inicio_h4 or inicio_h12)
    line.new(bar_index, high * 1.002, bar_index, low * 0.998,
             color=color_linea, width=ancho_linea, style=estilo_linea,
             extend=extend.both)

// ═══════════════════════════════════════════════════════════
// ETIQUETA
// ═══════════════════════════════════════════════════════════

label_size =
     size_label == "tiny"   ? size.tiny   :
     size_label == "normal" ? size.normal :
     size_label == "large"  ? size.large  :
     size.small

if mostrar_label and (inicio_h1 or inicio_h4 or inicio_h12)
    txt = inicio_h12 ? "⚡ H12 zone" :
          inicio_h4  ? "🔵 H4 zone"  :
                       "🟠 H1 zone"
    clr = inicio_h12 ? color_h12 : inicio_h4 ? color_h4 : color_h1
    label.new(bar_index, high, txt,
              color=clr, textcolor=color.white,
              style=label.style_label_down, size=label_size)
````
