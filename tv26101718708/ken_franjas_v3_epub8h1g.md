# Ken - Franjas v3

- url: https://www.tradingview.com/script/EPuB8H1g/
- type: indicator
- pine_id: PUB;410d2ef93ed6487396832ab977b25113
- version: 1.0

## Description

este indicador crea una franja visual, para que puedas separar sesiones, puedas determinar tu horario operativo.

## Source Code

````pine
//@version=6
// ╔══════════════════════════════════════════════╗
// ║        KEN FRANJAS v3 — Ken / Claude        ║
// ║  Dos franjas horarias con fondo de color    ║
// ║  Selecciona tu UTC para ajustar al gráfico  ║
// ╚══════════════════════════════════════════════╝
indicator("Ken - Franjas v3", "KenFranja", overlay=true)

// ══════════════════════════════════════════════
// TIMEZONE
// ══════════════════════════════════════════════
var G_TZ = '🌐  Timezone'
utc_offset = input.string('UTC+0', 'UTC del gráfico',
  options=['UTC-12','UTC-11','UTC-10','UTC-9','UTC-8','UTC-7','UTC-6','UTC-5','UTC-4','UTC-3','UTC-2','UTC-1','UTC+0','UTC+1','UTC+2','UTC+3','UTC+4','UTC+5','UTC+6','UTC+7','UTC+8','UTC+9','UTC+10','UTC+11','UTC+12'],
  group=G_TZ)

// ══════════════════════════════════════════════
// FRANJA 1
// ══════════════════════════════════════════════
var G1 = '🟧  Franja 1'
f1_on  = input.bool(true, '',         inline='f1',  group=G1)
f1_css = input.color(color.new(#ff5d00, 80), 'Color', inline='f1', group=G1)
f1_h1  = input.int(0, 'Inicio h', minval=0, maxval=23, inline='f1h', group=G1)
f1_m1  = input.int(0, 'm',        minval=0, maxval=59, inline='f1h', group=G1)
f1_h2  = input.int(1, 'Fin h',    minval=0, maxval=23, inline='f1h', group=G1)
f1_m2  = input.int(0, 'm',        minval=0, maxval=59, inline='f1h', group=G1)

// ══════════════════════════════════════════════
// FRANJA 2
// ══════════════════════════════════════════════
var G2 = '🟦  Franja 2'
f2_on  = input.bool(true, '',         inline='f2',  group=G2)
f2_css = input.color(color.new(#2157f3, 80), 'Color', inline='f2', group=G2)
f2_h1  = input.int(0, 'Inicio h', minval=0, maxval=23, inline='f2h', group=G2)
f2_m1  = input.int(0, 'm',        minval=0, maxval=59, inline='f2h', group=G2)
f2_h2  = input.int(1, 'Fin h',    minval=0, maxval=23, inline='f2h', group=G2)
f2_m2  = input.int(0, 'm',        minval=0, maxval=59, inline='f2h', group=G2)

// ══════════════════════════════════════════════
// HELPERS
// ══════════════════════════════════════════════
f_hm(h, m) => (h < 10 ? '0' : '') + str.tostring(h) + (m < 10 ? '0' : '') + str.tostring(m)
f_ses(h1, m1, h2, m2) => f_hm(h1, m1) + '-' + f_hm(h2, m2)

// ══════════════════════════════════════════════
// DETECCIÓN — usa el UTC seleccionado
// ══════════════════════════════════════════════
bool in_f1 = math.sign(nz(time(timeframe.period, f_ses(f1_h1, f1_m1, f1_h2, f1_m2), utc_offset))) == 1
bool in_f2 = math.sign(nz(time(timeframe.period, f_ses(f2_h1, f2_m1, f2_h2, f2_m2), utc_offset))) == 1

bgcolor(f1_on and in_f1 ? f1_css : na, title='Franja 1')
bgcolor(f2_on and in_f2 ? f2_css : na, title='Franja 2')
````
