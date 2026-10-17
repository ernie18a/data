# AVDO + Proporcion de volumen SR by TraderDeConfianza

- url: https://www.tradingview.com/script/avKlVvgu/
- type: indicator
- pine_id: PUB;558d8ac665ee4efca5e4736e931214e4
- version: 1.0

## Description

Este es un indicador todo-en-uno que combina dos sistemas complementarios para detectar zonas de interés institucional y dirección de tendencia. Es una herramienta de análisis basada en lectura de volumen real, por lo que su efectividad depende directamente de la calidad y autenticidad de los datos de volumen del activo que analizas.

Importante: dónde funciona y dónde no
El motor principal del indicador es el volumen real (transacciones efectivamente ejecutadas en un exchange centralizado). Por eso, su rendimiento varía dramáticamente según el tipo de activo:
Activos recomendados (volumen real y confiable):

Futuros de CME Group: especialmente los futuros de índices americanos como MNQ, NQ, ES, MES, YM, MYM, RTY, M2K. También funciona bien en futuros de commodities (CL, GC, SI, NG) y de bonos (ZN, ZB, ZF). El volumen de CME es centralizado y refleja transacciones reales.
Criptomonedas (preferentemente Binance): BTC, ETH, SOL y altcoins principales. Binance concentra el mayor volumen real del mercado cripto spot y de perpetuos. Otros exchanges grandes como Bybit, OKX o Coinbase también funcionan bien. Evita exchanges menores con volumen inflado.
Acciones directas (NYSE, NASDAQ, ARCA, AMEX): AAPL, TSLA, NVDA, SPY, QQQ y cualquier acción de alta liquidez listada en exchanges americanos primarios. El volumen es transparente y auditable.

No recomendado:

CFDs (Contracts for Difference): el volumen mostrado en CFDs es sintético, derivado del proveedor del broker, y no representa transacciones reales del mercado subyacente. El indicador perderá fiabilidad porque sus señales se basarán en datos artificiales.
Forex spot retail: el mercado forex no es centralizado, no existe un volumen "real" verificable. Lo que se muestra como volumen suele ser tick count del broker, no contratos negociados.
Mercados ilíquidos o de bajo volumen: acciones penny, criptos con poca capitalización, instrumentos exóticos. El ruido en los datos hace que las señales no sean confiables.


¿Qué hace el indicador?
Combina dos motores independientes que trabajan en armonía:
Motor 1 — AVDO (Anchored Value Distribution Oscillator): un sistema avanzado de distribución de valor anclada. Construye un perfil de volumen dinámico, identifica las zonas de valor (donde se ha negociado la mayor parte del volumen) y deriva una línea de tendencia adaptativa (trailing) que se mueve con el precio. Además, colorea las velas según el "estado" del mercado: alcista, bajista o neutral. Cuando detecta velas con volumen crítico histórico, las pinta de amarillo como advertencia de actividad institucional excepcional.
Motor 2 — VolProp SR (Volumen Proporcional Soporte/Resistencia): detecta velas donde el volumen actual supera al de la vela anterior en una proporción configurable. Marca esa vela con una caja que cubre todo su rango (high-low) y la proyecta hacia la derecha como zona activa de soporte o resistencia. La caja se mantiene viva hasta que el precio cierre atravesándola — momento en que se considera "mitigada" y se vuelve gris.
Cuando ambos motores se alinean, tienes confluencia institucional: precisamente las zonas donde los grandes operadores están dejando huella.

Filosofía de configuración
La mayoría del indicador viene listo para usar tal como está. Los componentes de AVDO y Volumen Crítico están afinados con parámetros robustos que funcionan bien en la mayoría de activos sin necesidad de ajuste. Déjalos en sus valores por defecto a menos que tengas una razón muy específica para tocarlos.
El verdadero trabajo de calibración está en el Motor 2 (VolProp SR), específicamente en dos parámetros: la proporción de volumen y el multiplicador ATR. Estos dos son los que adaptas a cada activo y timeframe que operes. El objetivo es encontrar el balance donde el indicador te marca solo las zonas verdaderamente institucionales, sin saturar el gráfico con ruido ni dejar pasar señales válidas.

Cómo calibrar VolProp para cada activo
Proceso recomendado:

Carga el indicador en el activo y timeframe que vas a operar. Déjalo en valores default (proporción 1.5, ATR multiplicador 1.0).
Observa 30 a 50 señales históricas sin tocar nada. Anota cuántas cajas aparecen por sesión y cuántas funcionaron realmente como S/R cuando el precio regresó a tocarlas.
Si aparecen demasiadas cajas y muchas no funcionan (gráfico saturado, señales ruidosas):

Sube la proporción de volumen en pasos de 0.2 (de 1.5 → 1.7 → 2.0).
Sube el multiplicador ATR en pasos de 0.2 (de 1.0 → 1.2 → 1.5).
Repite la observación.

Si aparecen muy pocas cajas (gráfico vacío, te pierdes movimientos importantes):

Baja la proporción de volumen en pasos de 0.1 (de 1.5 → 1.4 → 1.3).
Baja el multiplicador ATR (de 1.0 → 0.8).
O desactiva temporalmente el filtro ATR para diagnosticar dónde se está bloqueando.

Repite hasta que cada sesión te entregue entre 3 y 8 cajas activas de calidad — suficientes para tener oportunidades, no tantas que ensucien el análisis.

Y ajusta también según timeframe: timeframes bajos (1m–5m) toleran proporciones más bajas, timeframes altos (1H+) requieren proporciones más altas para que la señal sea significativa.

Parámetros del indicador
Grupo AVDO • Core (déjalo como está)
Lookback (default 233): número de barras usadas para construir la distribución de volumen. Solo bájalo si quieres reactividad extrema en scalping, o súbelo para contextos macro.
Canvas Pad (default 0.03) y Rebuild Drift (default 0.2): afinan internamente cómo se construye el perfil. No los toques sin razón específica.
Grupo AVDO • Signal (déjalo como está)
Signal Line Length (default 50): línea de señal interna del oscilador. Bájalo solo si quieres cruces más rápidos para scalping agresivo.
Grupo AVDO • Trend Logic (déjalo como está)
Show Trail on Chart, Fill, Profile Center Bias, Trail Acceleration, Max Trail Acceleration: todos vienen optimizados. Solo modifica si entiendes el efecto exacto que buscas — por ejemplo, subir Trail Acceleration si quieres un trailing más agresivo en mercados de alta volatilidad.
Grupo AVDO • Display
Show Reversal Marks (default OFF): actívalo si quieres diamantes de reversión visuales. Útil para alertas tempranas de techo/piso.
Trend Candlesticks (default ON): si lo desactivas, las velas se ven con su color real verde/rojo nativo. Recomendado dejar ON.
Grupo AVDO • Colors (estética)
Personaliza los colores a tu gusto. El amarillo del Volumen Crítico tiene prioridad sobre los demás, así que recuerda que ese color destaca lo más relevante.
Grupo AVDO • Volumen Crítico (déjalo como está)
Lookback Volumen (89), Suavizado Volumen (21), Umbral Crítico (0.618 — ratio áureo): los defaults están finamente calibrados con principios de teoría de mercado clásica. Solo súbelos si tu activo es muy ruidoso y aparecen demasiadas velas amarillas, o bájalos si casi nunca aparecen.

Grupo VolProp • Detección (★ AJUSTE PRINCIPAL)
Proporción de volumen (default 1.5): el parámetro más importante del indicador. Define cuánto debe crecer el volumen de la vela actual respecto a la anterior para disparar una caja.
Este es uno de los dos parámetros que debes calibrar para cada activo. Sigue el proceso descrito arriba.
Grupo VolProp • Filtro ATR (★ AJUSTE PRINCIPAL)
Activar filtro ATR (default ON): mantenlo activado, descarta velas pequeñas que tuvieron volumen alto pero no movieron precio.
Período ATR (default 14): estándar técnico, no necesita ajuste.
Multiplicador ATR (default 1.0): el segundo parámetro a calibrar por activo. Define qué tan grande debe ser la vela respecto a la volatilidad promedio reciente. Ajústalo según el proceso de calibración descrito.
Grupo VolProp • Filtro Cuerpo
Activar filtro cuerpo dominante (default ON): descarta dojis y velas indecisas. Mantenlo ON.
% mínimo del cuerpo (default 60%): ajusta solo si notas que se cuelan velas con mucha mecha y cuerpo chico. Súbelo a 70-75% para mayor exigencia.
Grupo VolProp • Cajas S/R
Modo extensión (default Dinámica): déjalo en Dinámica para que las cajas se proyecten hasta que el precio las rompa. Cambia a "Fija" solo si quieres que duren un número específico de barras.
Mostrar cajas mitigadas (default ON): las cajas rotas quedan en gris como contexto histórico. Desactívalo si quieres el gráfico más limpio sin contexto previo.
Colores y ancho de borde: estética pura.
Grupo VolProp • Etiqueta
Mostrar etiqueta con ratio (default ON): muestra el "2.3x" debajo de la vela marcada para que veas qué tan fuerte fue la señal.
Tamaño y color de texto: ajustes visuales.

Ejemplo de uso paso a paso
Imagina que abres el chart de MNQ a las 8:30 AM CST (apertura de NYSE). El indicador ya está calibrado para este activo (proporción 1.8, ATR multiplicador 1.1 después de tu proceso de prueba).
Paso 1 — Lectura del contexto general (AVDO):
A las 8:30 ves que las velas vienen pintadas de verde intenso y el trailing line está claramente por debajo del precio. AVDO confirma tendencia alcista, el precio está aceptado en la zona alta del perfil de valor. No operas en contra de esto. Tu sesgo es alcista.
Paso 2 — Aparece una caja VolProp:
A las 9:15 AM, una vela explota de volumen y cumple los filtros. Aparece una caja verde semitransparente cubriendo todo su rango con etiqueta "2.4x" abajo. Significa que esa vela tuvo 2.4 veces el volumen de la anterior y pasó los filtros. Esta es tu zona de entrada potencial.
Paso 3 — Confluencia élite:
A las 9:45 AM, otra vela alcista. Esta vez la vela aparece pintada en amarillo (Volumen Crítico AVDO) y se le dibuja una caja verde de VolProp con etiqueta "3.1x". Setup A+: confluencia triple — volumen crítico histórico, ratio proporcional, y tendencia AVDO alineada.
Paso 4 — Espera el pullback:
No entras al breakout. Esperas a que el precio se aleje y regrese a tocar la caja. A las 10:20 AM, el precio retrocede y entra dentro de la caja amarilla. Esta es la señal de entrada.
Paso 5 — Entrada, stop y target:
Long con stop justo por debajo del low de la caja (extremo inferior, no el cuerpo). Target en el siguiente nivel claro: otra caja superior, una zona AVDO de resistencia, o un múltiplo de R según tu plan.
Paso 6 — Gestión:
Si el precio sigue subiendo: ¿aparece otra caja verde más arriba? → toma parcial o trail. ¿La trail de AVDO se voltea a bajista? → cierre. ¿Una caja gris previa ahora actúa como resistencia? → cuida la posición.

Reglas de oro

El AVDO da contexto, VolProp SR da zonas. No operes una caja contra el contexto. Caja verde con AVDO bajista → mejor pásala.
Vela amarilla + caja del mismo color = setup A+. Estas son las raras y valiosas. Espéralas con paciencia.
La caja gris no es zona activa. Es referencia histórica. Si el precio regresa a una caja gris y reacciona, considera el principio de polaridad (soporte roto = posible resistencia).
Operación de retorno, no de breakout. El indicador marca dónde estuvieron los institucionales. Operas el pullback a la zona, no el breakout inicial.
Calibración por activo. Lo que funciona en MNQ no funciona idéntico en BTC, ni en NVDA, ni en cada timeframe. Dedica tiempo al proceso de ajuste de proporción y ATR antes de operar en vivo.
Activa las alertas de confluencia. En la lista de alertas hay tres claves: "VolProp + Volumen Crítico", "VolProp + AVDO Bull Stack" y "VolProp + AVDO Bear Stack". Activa esas como push — son las que realmente vale la pena mirar.


Cuándo NO operarlo

Aperturas con gap brutal (primeros 5–10 minutos en días de noticia macro): el indicador necesita unas pocas velas para estabilizar el perfil.
Activos con volumen sintético o no confiable (CFDs, forex retail, mercados ilíquidos).
Cuando el contexto AVDO es plano (trailing cerca del precio, oscilador cerca de cero): el mercado está en consolidación, las cajas son menos confiables.
Sin calibración previa al activo: si lo cargas en un instrumento nuevo y operas con defaults sin observar primero, vas a ciegas.


Resumen ejecutivo
Tienes un sistema que mapea las zonas donde los institucionales dejaron huella (cajas verdes/rojas), te dice cuándo esas zonas son especialmente significativas (vela amarilla), te da la dirección de la corriente principal (trailing AVDO), y te avisa cuando todo se alinea (alertas de confluencia).
La estructura del indicador está prácticamente lista de fábrica — la parte de AVDO y Volumen Crítico viene optimizada. Tu trabajo de calibración se concentra en dos parámetros del Motor 2 (VolProp): proporción de volumen y multiplicador ATR. Ajústalos para cada activo hasta que las cajas sean significativas y proporcionadas a la sesión, y el indicador se vuelve una extensión natural de tu análisis.
Recuerda siempre: este indicador es tan bueno como el volumen real del activo que analizas. Úsalo en mercados centralizados con datos auténticos, y rendirá. Evita los mercados con volumen sintético, ahí no tiene cómo brillar.

## Source Code

````pine
// This work is licensed under Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International
// https://creativecommons.org/licenses/by-nc-sa/4.0/
// © Zeiierman (AVDO base) | Integración + VolProp SR por Héctor
//@version=6
indicator("AVDO + VolProp SR [Héctor]", shorttitle="AVDO+VP", overlay=true, max_bars_back=2000, max_boxes_count=500, max_labels_count=500, precision=0)

// ═══════════════════════════════════════════════════════════════════════════════
// ▓▓▓ SECCIÓN 1: AVDO (Anchored Value Distribution Oscillator) — Zeiierman ▓▓▓
// ═══════════════════════════════════════════════════════════════════════════════

// ~~ Tooltips AVDO
var string t1  = "Number of bars used to build the value distribution."
var string t2  = "Expands the price range used to build the distribution."
var string t3  = "Sensitivity of profile rebuild when price range changes."
var string t4  = "Shows the smoothed signal line of the oscillator."
var string t5  = "Length of the signal line smoothing."
var string t6  = "Displays the adaptive trailing anchor on the main chart."
var string t7  = "Fills the area between price and the trailing anchor."
var string t8  = "Blends between value center and point of control."
var string t9  = "Controls how strongly fast price movement compresses the trailing distance."
var string t16 = "Limits the maximum tightening effect from acceleration."
var string t11 = "Displays reversal diamonds when momentum shifts within extreme zones."
var string t12 = "Colors price candles based on oscillator state."
var string t13 = "Primary bullish color."
var string t14 = "Primary bearish color."
var string t15 = "Neutral midpoint color."

// ~~ Inputs AVDO
nBar  = input.int(233, "Lookback", minval=25, maxval=600, step=10, group="AVDO • Core", tooltip=t1)
pad   = input.float(0.03, "Canvas Pad", minval=0.0, maxval=1, step=0.05, group="AVDO • Core", tooltip=t2)
rbPct = input.float(0.2, "Rebuild Drift", minval=0.0, maxval=10.0, step=0.025, group="AVDO • Core", tooltip=t3)

shSig  = input.bool(true, "Signal Line (internal)", group="AVDO • Signal", inline="signal", tooltip=t4)
lenSig = input.int(50, "", minval=2, group="AVDO • Signal", inline="signal", tooltip=t4 + "\n\n" + t5)

showTrailOnChart = input.bool(true, "Show Trail On Chart", group="AVDO • Trend Logic", inline="t", tooltip=t6)
showTrailFill    = input.bool(true, "Fill", group="AVDO • Trend Logic", inline="t", tooltip=t6 + "\n\n" +t7)

profBias  = input.float(0.70, "Profile Center Bias", minval=0.0, maxval=1.0, step=0.05, group="AVDO • Trend Logic", tooltip=t8)
accelSens = input.float(2.25, "Trail Acceleration", minval=0.1, maxval=5.0, step=0.05, group="AVDO • Trend Logic", tooltip=t9)
accelMax  = input.float(2.5, "Max Trail Acceleration", minval=1.0, maxval=10.0, step=0.1, group="AVDO • Trend Logic", tooltip=t16)

showRevMarks = input.bool(false, "Show Reversal Marks", group="AVDO • Display", tooltip=t11)
paintBars    = input.bool(true, "Trend Candlesticks", group="AVDO • Display", tooltip=t12)

cPos = input.color(#26a69a, "Bull", group="AVDO • Colors", tooltip=t13)
cNeg = input.color(#ef5350, "Bear", group="AVDO • Colors", tooltip=t14)
cTra = input.color(#94cfff, "Neutral", group="AVDO • Colors", tooltip=t15)
cVC  = input.color(color.yellow, "Volumen Critico", group="AVDO • Colors", tooltip="Color para velas con volumen critico.")

// Volumen Crítico inputs
showVC    = input.bool(true, "Mostrar Volumen Critico", group="AVDO • Volumen Critico")
vcLen     = input.int(89, "Lookback Volumen", minval=10, group="AVDO • Volumen Critico")
vcEmaLen  = input.int(21, "Suavizado Volumen", minval=2, group="AVDO • Volumen Critico")
vcThr     = input.float(0.618, "Umbral Critico", minval=0.1, maxval=1.0, step=0.01, group="AVDO • Volumen Critico")

// ~~ Helpers AVDO
neu() =>
    bg = chart.bg_color
    r  = color.r(bg) / 255.0
    g0 = color.g(bg) / 255.0
    b  = color.b(bg) / 255.0
    lum = 0.2126 * r + 0.7152 * g0 + 0.0722 * b
    lum > 0.5 ? color.black : cTra

clp(x, lo, hi) =>
    math.max(lo, math.min(hi, x))

lg(x) =>
    x > 0 ? math.log(x) : na

ctr(lf0, rs0, i) =>
    math.exp(lf0 + (i + 0.5) * rs0)

gmid(a, b) =>
    a > 0 and b > 0 ? math.sqrt(a * b) : na

mix(c1, c2, t) =>
    u = clp(t, 0.0, 1.0)
    color.rgb(
         int(math.round(color.r(c1) + (color.r(c2) - color.r(c1)) * u)),
         int(math.round(color.g(c1) + (color.g(c2) - color.g(c1)) * u)),
         int(math.round(color.b(c1) + (color.b(c2) - color.b(c1)) * u)),
         int(math.round(color.t(c1) + (color.t(c2) - color.t(c1)) * u))
    )

ease(x, p) =>
    s = clp(x, -1.0, 1.0)
    s == 0 ? 0.0 : math.sign(s) * math.pow(math.abs(s), p)

triCol(x, neg, mid, pos, p) =>
    s = ease(x, p)
    s <= 0 ? mix(mid, neg, math.abs(s)) : mix(mid, pos, s)

oscCol(x, neg, mid, pos) =>
    triCol(clp(x / 50.0, -1.0, 1.0), neg, mid, pos, 0.7)

fixBands(a, vh, vl, xh, xl) =>
    lo1 = math.min(vl, vh)
    hi1 = math.max(vl, vh)
    lo2 = math.min(xl, xh)
    hi2 = math.max(xl, xh)
    aa  = clp(a, lo1, hi1)
    vll = lo1
    vhh = hi1
    xll = math.min(lo2, vll)
    xhh = math.max(hi2, vhh)
    [aa, vhh, vll, xhh, xll]

norm(px, a, vh, vl, xh, xl) =>
    s = 0.0
    if na(px) or na(a) or na(vh) or na(vl) or na(xh) or na(xl)
        s := na
    else
        [aa, vhh, vll, xhh, xll] = fixBands(a, vh, vl, xh, xl)
        if px >= aa
            if px <= vhh
                sp = vhh - aa
                s := sp > 0 ? 25.0 * (px - aa) / sp : 0.0
            else
                sp = xhh - vhh
                s := sp > 0 ? 25.0 + 25.0 * (px - vhh) / sp : 25.0
        else
            if px >= vll
                sp = aa - vll
                s := sp > 0 ? -25.0 * (aa - px) / sp : 0.0
            else
                sp = vll - xll
                s := sp > 0 ? -25.0 - 25.0 * (vll - px) / sp : -25.0
    clp(s, -50.0, 50.0)

colClr(m, nr, c) =>
    for r = 0 to nr - 1
        matrix.set(m, r, c, 0.0)

addBar(m, p, nr, c, lf0, rs0, kRaw, gs, bb) =>
    h = lg(high)
    l = lg(low)
    o = lg(open)
    cc = lg(close)
    v = math.max(0.0, nz(volume)) * kRaw
    if not na(h) and not na(l) and not na(o) and not na(cc) and v > 0 and rs0 > 0
        r0 = int(math.floor((l - lf0) / rs0))
        r1 = int(math.floor((h - lf0) / rs0))
        r0 := math.max(0, math.min(nr - 1, r0))
        r1 := math.max(0, math.min(nr - 1, r1))
        cnt = math.max(1, r1 - r0 + 1)
        bLo = math.min(o, cc)
        bHi = math.max(o, cc)
        bodyV = v * bb
        wickV = v * (1.0 - bb)
        wickAdd = wickV / cnt
        bodyDen = math.max(rs0, bHi - bLo)
        addNow = 0.0
        for r = r0 to r1
            rl = lf0 + r * rs0
            rh = rl + rs0
            ov = math.max(0.0, math.min(rh, bHi) - math.max(rl, bLo))
            bodyAdd = bodyV * ov / bodyDen
            raw = wickAdd + bodyAdd
            if raw != 0
                matrix.set(m, r, c, raw)
                addNow := raw * gs
                array.set(p, r, array.get(p, r) + addNow)

subCol(m, p, nr, c, gs) =>
    for r = 0 to nr - 1
        v = matrix.get(m, r, c)
        if v != 0
            array.set(p, r, array.get(p, r) - v * gs)
            matrix.set(m, r, c, 0.0)

reb(m, p, nr, nb, lf0, rs0, q, bb) =>
    matrix.fill(m, 0.0)
    array.fill(p, 0.0)
    for c = 0 to nb - 1
        b = nb - 1 - c
        h = lg(high[b])
        l = lg(low[b])
        o = lg(open[b])
        cc = lg(close[b])
        v  = math.max(0.0, nz(volume[b])) * math.pow(q, b)
        if not na(h) and not na(l) and not na(o) and not na(cc) and v > 0 and rs0 > 0
            r0 = int(math.floor((l - lf0) / rs0))
            r1 = int(math.floor((h - lf0) / rs0))
            r0 := math.max(0, math.min(nr - 1, r0))
            r1 := math.max(0, math.min(nr - 1, r1))
            cnt = math.max(1, r1 - r0 + 1)
            bLo = math.min(o, cc)
            bHi = math.max(o, cc)
            bodyV = v * bb
            wickV = v * (1.0 - bb)
            wickAdd = wickV / cnt
            bodyDen = math.max(rs0, bHi - bLo)
            for r  = r0 to r1
                rl = lf0 + r * rs0
                rh = rl + rs0
                ov = math.max(0.0, math.min(rh, bHi) - math.max(rl, bLo))
                raw = wickAdd + bodyV * ov / bodyDen
                if raw != 0
                    matrix.set(m, r, c, raw)
                    array.set(p, r, array.get(p, r) + raw)

rebase(m, p, nr, nb, gs) =>
    if gs != 1.0
        array.fill(p, 0.0)
        for c = 0 to nb - 1
            for r = 0 to nr - 1
                v = matrix.get(m, r, c) * gs
                matrix.set(m, r, c, v)
                if v != 0
                    array.set(p, r, array.get(p, r) + v)

massIdx(a, nr, frac) =>
    tv = 0.0
    for r = 0 to nr - 1
        tv += array.get(a, r)
    if tv <= 0
        na
    else
        tgt = tv * frac
        run = 0.0
        outI = 0.0
        for r = 0 to nr - 1
            v = array.get(a, r)
            prev = run
            run += v
            if run >= tgt
                f = v > 0 ? (tgt - prev) / v : 0.0
                outI := r + clp(f, 0.0, 1.0)
                break
        outI

stats(a, lf0, rs0, nr, im, om, st) =>
    tv  = 0.0
    wm  = 0.0
    pk  = -1.0
    ipk = 0
    for r = 0 to nr - 1
        v = array.get(a, r)
        tv += v
        wm += v * r
        if v > pk
            pk := v
            ipk := r
    if tv <= 0
        [na, na, na, na, na, na]
    else
        float p0 = ipk
        if ipk > 0 and ipk < nr - 1
            vl0 = array.get(a, ipk - 1)
            vm0 = array.get(a, ipk)
            vr0 = array.get(a, ipk + 1)
            dn0 = vl0 + vm0 + vr0
            if dn0 > 0
                p0 := ((ipk - 1) * vl0 + ipk * vm0 + (ipk + 1) * vr0) / dn0

        mu = wm / tv
        loIn  = massIdx(a, nr, (1.0 - im) * 0.5)
        hiIn  = massIdx(a, nr, 1.0 - (1.0 - im) * 0.5)
        loOut = massIdx(a, nr, (1.0 - om) * 0.5)
        hiOut = massIdx(a, nr, 1.0 - (1.0 - om) * 0.5)

        vh0  = ctr(lf0, rs0, hiIn)
        vl0  = ctr(lf0, rs0, loIn)
        xh0  = ctr(lf0, rs0, hiOut)
        xl0  = ctr(lf0, rs0, loOut)
        muPx = ctr(lf0, rs0, mu)

        mid0  = gmid(vh0, vl0)
        sym   = mid0 > 0 ? math.abs(muPx - mid0) / mid0 : 1.0
        blend = clp(sym / math.max(st, 0.0001), 0.0, 1.0)
        cen   = na(mid0) or na(muPx) ? na : mid0 * (1.0 - blend) + muPx * blend

        [ctr(lf0, rs0, p0), vh0, vl0, xh0, xl0, cen]

// ~~ Lengths AVDO
lenF = int(math.max(3.0, math.round(math.sqrt(nBar))))
lenM = int(math.max(5.0, math.round(math.sqrt(float(lenF * nBar)))))
lenS = int(math.max(8.0, math.round((float(lenF + lenM + nBar)) / 3.0)))

cNeu    = neu()
cMidOsc = mix(cNeu, color.new(cNeu, 0), 1.0)

// ~~ Profile state AVDO
mxMax = 100000
nCap  = int(math.max(1, math.min(nBar, math.floor(mxMax / 400))))
q     = math.exp(-1.0 / math.max(1.0, math.sqrt(nBar)))

var matrix<float> m = matrix.new<float>(400, nCap, 0.0)
var float[] p  = array.new_float(400, 0.0)
var int fill   = 0
var int head   = 0
var float cvLo = na
var float cvHi = na
var float lf   = na
var float rs   = na
var int rbCnt  = 0
var float gs   = 1.0

inMass   = 0.68
outMass  = 0.95
bodyBias = 0.64
symThr   = 0.20

hiLb  = ta.highest(high, nBar)
loLb  = ta.lowest(low, nBar)
loPad = math.max(syminfo.mintick, loLb * (1.0 - pad))
hiPad = hiLb * (1.0 + pad)

initCv = na(cvLo) or na(cvHi) or na(lf) or na(rs)
outCv  = not initCv and (low < cvLo or high > cvHi)
lfNew  = lg(loPad)
rsNew  = not na(lfNew) and hiPad > 0 ? (lg(hiPad) - lfNew) / 400 : na
rsDr    = not initCv and rs > 0 and rsNew > 0 ? math.abs(rsNew - rs) / rs : 0.0
driftCv = not initCv and rsDr > rbPct
doRb    = initCv or outCv or driftCv

if doRb and not na(lfNew) and not na(rsNew) and rsNew > 0
    cvLo := loPad
    cvHi := hiPad
    lf := lfNew
    rs := rsNew
    fill := math.min(nCap, bar_index + 1)
    head := 0
    gs := 1.0
    reb(m, p, 400, fill, lf, rs, q, bodyBias)
    rbCnt += 1
else if barstate.isnew and not na(lf) and not na(rs) and rs > 0
    gs := gs * q
    if fill < nCap
        addBar(m, p, 400, fill, lf, rs, 1.0 / gs, gs, bodyBias)
        fill += 1
    else
        subCol(m, p, 400, head, gs)
        colClr(m, 400, head)
        addBar(m, p, 400, head, lf, rs, 1.0 / gs, gs, bodyBias)
        head := (head + 1) % nCap
    if gs < 0.000001
        rebase(m, p, 400, fill, gs)
        gs := 1.0
    if low < cvLo or high > cvHi
        cvLo := math.min(cvLo, low * (1.0 - pad))
        cvHi := math.max(cvHi, high * (1.0 + pad))

// ~~ Profile stats AVDO
[vp0, vh0, vl0, xh0, xl0, cen0] = stats(p, lf, rs, 400, inMass, outMass, symThr)

vp = ta.ema(vp0, lenF)
vh = ta.ema(vh0, lenF)
vl = ta.ema(vl0, lenF)
xh = ta.ema(xh0, lenM)
xl = ta.ema(xl0, lenM)
cen = ta.ema(cen0, lenF)

// ~~ Trend logic AVDO
profBase = na(cen) or na(vp) ? na : profBias * cen + (1.0 - profBias) * vp
atrv     = ta.atr(120)

var float anc    = na
var int trendDir = 1

flipDistBase  = 2.2 * atrv
transDist     = 2.2 * atrv
minDist       = 0.45 * atrv

moveNow = math.abs(close - close[1]) / math.max(atrv, syminfo.mintick)
baseGap = na(profBase) ? 0.0 : math.abs(close - profBase) / math.max(atrv, syminfo.mintick)

rawAccel = 1.0 + accelSens * (0.7 * moveNow + 0.3 * baseGap)
accelMul = clp(rawAccel, 1.0, accelMax)

effFlipDist = flipDistBase / accelMul
effFlipDist := math.max(minDist, effFlipDist)

if na(anc) or na(profBase) or na(atrv)
    anc := profBase
    trendDir := close >= profBase ? 1 : -1
else
    if trendDir == 1 and close < anc
        trendDir := -1
        anc := profBase + effFlipDist
    else if trendDir == -1 and close > anc
        trendDir := 1
        anc := profBase - effFlipDist

    baseTrail = trendDir == 1 ? profBase - effFlipDist : profBase + effFlipDist
    anc := trendDir == 1 ? math.max(anc, baseTrail) : math.min(anc, baseTrail)

    gapToBase = trendDir == 1 ? profBase - anc : anc - profBase
    if gapToBase > transDist
        targetLevel = trendDir == 1 ? profBase - minDist : profBase + minDist
        anc := trendDir == 1 ? math.max(anc, targetLevel) : math.min(anc, targetLevel)

// ~~ Oscillator AVDO
[ancA, vhA, vlA, xhA, xlA] = fixBands(anc, vh, vl, xh, xl)
[vpA, vhB, vlB, xhB, xlB]  = fixBands(vp, vh, vl, xh, xl)

scAnc = norm(close, ancA, vhA, vlA, xhA, xlA)
scVp  = norm(close, vpA, vhB, vlB, xhB, xlB)

conf   = 1.0 - clp(math.abs(scAnc - scVp) / 100.0, 0.0, 1.0)
outAvg = ta.ema(scAnc * 0.75 + scVp * 0.25 * conf, 8)
sig    = ta.ema(outAvg, lenSig)

// ~~ Volumen Crítico
volmax   = ta.highest(volume, vcLen)
volNorm  = volmax > 0 ? volume * 100 / volmax * 4 / 5 : 0.0
volpmed  = ta.ema(volNorm, vcEmaLen)
hvpm     = volNorm - volpmed
niv_crit = ta.highest(hvpm, vcLen) * vcThr
isCritVol = showVC and hvpm > 0 and hvpm >= niv_crit

// ~~ Plots AVDO
outColSrc = ta.ema(outAvg, 2)
cOsc      = oscCol(outColSrc, cNeg, cMidOsc, cPos)

finalCandleCol = isCritVol ? cVC : cOsc

trailCol  = trendDir == 1 ? cPos : cNeg
trailPlot = showTrailOnChart ? (trendDir != trendDir[1] ? float(na) : anc) : na
closePlot = showTrailOnChart ? close : na

pTrail = plot(trailPlot, "Trailing", color=color.new(trailCol, 0), linewidth=2, style=plot.style_linebr)
pClose = plot(closePlot, display=display.none, editable=false)
fill(pTrail, pClose, anc, close, showTrailFill ? color.new(trailCol, 85) : na, color(na))
plotcandle(open, high, low, close, title="Trend Candlesticks", color=paintBars ? finalCandleCol : na, wickcolor=paintBars ? finalCandleCol : na, bordercolor=paintBars ? finalCandleCol : na)
barcolor(paintBars ? finalCandleCol : na, title="Bar Color Backup")

// ~~ Reversal marks AVDO
var int lastRevBar = na
canMark = na(lastRevBar) or bar_index - lastRevBar > 20

sweepLen  = 2
sweepHigh = high > ta.highest(high[1], sweepLen)
sweepLow  = low  < ta.lowest(low[1], sweepLen)

revavg    = ta.ema(outAvg,10)
prevreavg = revavg[1]
revDown = ta.crossunder(revavg, prevreavg) and outAvg > 30 and sweepHigh
revUp   = ta.crossover(revavg, prevreavg) and outAvg < -30 and sweepLow

if (showRevMarks and revDown and canMark) or (showRevMarks and revUp and canMark)
    lastRevBar := bar_index

plotshape(showRevMarks and revDown and canMark, "Chart Reversal Down", shape.diamond, location.abovebar, size=size.tiny, color=color.new(cNeg, 0), offset=-1)
plotshape(showRevMarks and revUp and canMark, "Chart Reversal Up", shape.diamond, location.belowbar, size=size.tiny, color=color.new(cPos, 0), offset=-1)

// ═══════════════════════════════════════════════════════════════════════════════
// ▓▓▓ SECCIÓN 2: VolProp SR (Volumen Proporcional Soporte/Resistencia) — Héctor ▓▓▓
// ═══════════════════════════════════════════════════════════════════════════════

// ~~ Inputs VolProp SR
grpVol = "VolProp • Deteccion"
ratioUmbral = input.float(1.5, "Proporcion de volumen (ej. 1.5 = 150%)", minval=1.01, step=0.1, group=grpVol, tooltip="La vela actual debe alcanzar este multiplo del volumen de la vela anterior cerrada.")

grpATR = "VolProp • Filtro ATR"
usarATR = input.bool(true, "Activar filtro ATR", group=grpATR)
atrLen = input.int(14, "Periodo ATR", minval=1, group=grpATR)
atrMult = input.float(1.0, "Multiplicador ATR (rango minimo)", minval=0.1, step=0.1, group=grpATR)

grpCuerpo = "VolProp • Filtro Cuerpo"
usarCuerpo = input.bool(true, "Activar filtro cuerpo dominante", group=grpCuerpo)
cuerpoMinPct = input.float(60.0, "% minimo del cuerpo sobre el rango", minval=1.0, maxval=100.0, step=5.0, group=grpCuerpo)

grpCaja = "VolProp • Cajas S/R"
modoExtension = input.string("Dinamica", "Modo extension", options=["Dinamica", "Fija"], group=grpCaja)
barrasFijas = input.int(50, "Barras (modo fijo)", minval=1, group=grpCaja)
colorBull = input.color(color.new(#26a69a, 75), "Color caja alcista", group=grpCaja)
colorBear = input.color(color.new(#ef5350, 75), "Color caja bajista", group=grpCaja)
colorMitigada = input.color(color.new(color.gray, 80), "Color caja mitigada", group=grpCaja)
mostrarMitigadas = input.bool(true, "Mostrar cajas mitigadas", group=grpCaja)
bordeAncho = input.int(1, "Ancho borde", minval=1, maxval=4, group=grpCaja)

grpEtiqueta = "VolProp • Etiqueta"
mostrarEtiqueta = input.bool(true, "Mostrar etiqueta con ratio", group=grpEtiqueta)
colorTextoEtiqueta = input.color(color.white, "Color texto", group=grpEtiqueta)
tamanoEtiqueta = input.string("Pequeno", "Tamano", options=["Diminuto", "Pequeno", "Normal", "Grande"], group=grpEtiqueta)

// ~~ Cálculos VolProp SR
volAnterior = volume[1]
ratioActual = volAnterior > 0 ? volume / volAnterior : 0.0

atrValVP = ta.atr(atrLen)
rangoVela = high - low
filtroATRok = not usarATR or rangoVela >= atrValVP * atrMult

cuerpoVP = math.abs(close - open)
pctCuerpo = rangoVela > 0 ? (cuerpoVP / rangoVela) * 100 : 0.0
filtroCuerpoOk = not usarCuerpo or pctCuerpo >= cuerpoMinPct

condRatio = ratioActual >= ratioUmbral
condicionDisparo = condRatio and filtroATRok and filtroCuerpoOk

// ~~ Estado persistente VolProp
var bool yaMarcada = false
var box cajaActual = na
var label etiquetaActual = na
var float ratioCapturado = 0.0

if barstate.isnew
    yaMarcada := false
    ratioCapturado := 0.0

// ~~ Arrays cajas activas VolProp
var array<box> cajasActivas = array.new<box>()
var array<float> cajasTop = array.new<float>()
var array<float> cajasBot = array.new<float>()
var array<bool> cajasAlcistas = array.new<bool>()
var array<int> cajasInicio = array.new<int>()

// ~~ Disparo VolProp
if condicionDisparo and not yaMarcada
    yaMarcada := true
    ratioCapturado := ratioActual
    
    esAlcistaVP = close >= open
    colorCaja = esAlcistaVP ? colorBull : colorBear
    colorBorde = esAlcistaVP ? color.new(#26a69a, 30) : color.new(#ef5350, 30)
    
    rangoTop = high
    rangoBot = low
    
    finCajaInicial = modoExtension == "Fija" ? bar_index + barrasFijas : bar_index + 1
    cajaActual := box.new(left=bar_index, top=rangoTop, right=finCajaInicial, bottom=rangoBot, bgcolor=colorCaja, border_color=colorBorde, border_width=bordeAncho, extend=extend.none)
    
    array.push(cajasActivas, cajaActual)
    array.push(cajasTop, rangoTop)
    array.push(cajasBot, rangoBot)
    array.push(cajasAlcistas, esAlcistaVP)
    array.push(cajasInicio, bar_index)
    
    if mostrarEtiqueta
        tamano = switch tamanoEtiqueta
            "Diminuto" => size.tiny
            "Pequeno" => size.small
            "Normal" => size.normal
            "Grande" => size.large
            => size.small
        
        textoEtiqueta = str.tostring(ratioCapturado, "#.##") + "x"
        etiquetaActual := label.new(x=bar_index, y=low, text=textoEtiqueta, yloc=yloc.belowbar, color=esAlcistaVP ? color.new(#26a69a, 20) : color.new(#ef5350, 20), textcolor=colorTextoEtiqueta, style=label.style_label_up, size=tamano)

// Actualizar high/low intrabar
if yaMarcada and not na(cajaActual) and barstate.islast
    nuevoTop = math.max(box.get_top(cajaActual), high)
    nuevoBot = math.min(box.get_bottom(cajaActual), low)
    box.set_top(cajaActual, nuevoTop)
    box.set_bottom(cajaActual, nuevoBot)
    if array.size(cajasActivas) > 0
        ultimoIdx = array.size(cajasActivas) - 1
        ultimoInicio = array.get(cajasInicio, ultimoIdx)
        if ultimoInicio == bar_index
            array.set(cajasTop, ultimoIdx, nuevoTop)
            array.set(cajasBot, ultimoIdx, nuevoBot)

if yaMarcada and ratioActual > ratioCapturado
    ratioCapturado := ratioActual
    if mostrarEtiqueta and not na(etiquetaActual)
        label.set_text(etiquetaActual, str.tostring(ratioCapturado, "#.##") + "x")

// ~~ Extensión + Mitigación VolProp
if barstate.isconfirmed or barstate.islast
    i = 0
    while i < array.size(cajasActivas)
        bx = array.get(cajasActivas, i)
        topBx = array.get(cajasTop, i)
        botBx = array.get(cajasBot, i)
        esAlcistaBx = array.get(cajasAlcistas, i)
        inicioBx = array.get(cajasInicio, i)
        
        mitigada = (esAlcistaBx and close < botBx) or (not esAlcistaBx and close > topBx)
        
        if mitigada and barstate.isconfirmed
            if mostrarMitigadas
                box.set_right(bx, bar_index)
                box.set_bgcolor(bx, colorMitigada)
                box.set_border_color(bx, color.new(color.gray, 50))
            else
                box.delete(bx)
            array.remove(cajasActivas, i)
            array.remove(cajasTop, i)
            array.remove(cajasBot, i)
            array.remove(cajasAlcistas, i)
            array.remove(cajasInicio, i)
        else
            nuevoRight = modoExtension == "Fija" ? inicioBx + barrasFijas : bar_index + 1
            box.set_right(bx, nuevoRight)
            i += 1

// ═══════════════════════════════════════════════════════════════════════════════
// ▓▓▓ ALERTAS UNIFICADAS ▓▓▓
// ═══════════════════════════════════════════════════════════════════════════════

// AVDO alerts
sigCrossUpRaw         = ta.crossover(outAvg, sig)
sigCrossDownRaw       = ta.crossunder(outAvg, sig)
zeroCrossUpRaw        = ta.crossover(outAvg, 0)
zeroCrossDownRaw      = ta.crossunder(outAvg, 0)
priceCrossTrailUpRaw   = ta.crossover(close, anc)
priceCrossTrailDownRaw = ta.crossunder(close, anc)
trendFlipBull     = trendDir == 1 and trendDir[1] == -1
trendFlipBear     = trendDir == -1 and trendDir[1] == 1
bullReversal      = showRevMarks and revUp and canMark
bearReversal      = showRevMarks and revDown and canMark
fullBullStack     = trendDir == 1 and close > anc and outAvg > 0 and outAvg > sig
fullBearStack     = trendDir == -1 and close < anc and outAvg < 0 and outAvg < sig

alertcondition(sigCrossUpRaw, "AVDO Sig Bull", "AVDO Sig crossed above Osc.")
alertcondition(sigCrossDownRaw, "AVDO Sig Bear", "AVDO Sig crossed below Osc.")
alertcondition(zeroCrossUpRaw, "AVDO Mid Bull", "AVDO Osc crossed above Mid.")
alertcondition(zeroCrossDownRaw, "AVDO Mid Bear", "AVDO Osc crossed below Mid.")
alertcondition(trendFlipBull, "AVDO Trail Bull", "AVDO Trailing flipped bullish.")
alertcondition(trendFlipBear, "AVDO Trail Bear", "AVDO Trailing flipped bearish.")
alertcondition(priceCrossTrailUpRaw, "AVDO Price Trail Bull", "Price crossed above Trailing.")
alertcondition(priceCrossTrailDownRaw, "AVDO Price Trail Bear", "Price crossed below Trailing.")
alertcondition(bullReversal, "AVDO Reversal Up", "AVDO chart bullish reversal.")
alertcondition(bearReversal, "AVDO Reversal Down", "AVDO chart bearish reversal.")
alertcondition(fullBullStack, "AVDO Full Stack Bull", "AVDO full bullish alignment.")
alertcondition(fullBearStack, "AVDO Full Stack Bear", "AVDO full bearish alignment.")
alertcondition(isCritVol, "Volumen Critico", "Vela con volumen critico detectada.")

// VolProp SR alerts
alertcondition(condicionDisparo, "VolProp SR", "Vela con ratio de volumen elevado detectada.")
alertcondition(condicionDisparo and isCritVol, "VolProp + Volumen Critico", "CONFLUENCIA: VolProp + Volumen Critico en la misma vela.")
alertcondition(condicionDisparo and fullBullStack, "VolProp + AVDO Bull Stack", "CONFLUENCIA: VolProp con AVDO bullish stack completo.")
alertcondition(condicionDisparo and fullBearStack, "VolProp + AVDO Bear Stack", "CONFLUENCIA: VolProp con AVDO bearish stack completo.")
````
