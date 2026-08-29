<!-- tradingview-pine-id: PUB;e675240c6ead464c83dc1e092d68fe94 -->
<!-- tradingviewscripts-format: 1 -->
# Prontuario CSP + Zonas | R1M

Source: https://www.tradingview.com/script/DszGjPpj/

## Description

# Prontuario CSP + Zonas | R1M

**Línea corta (tagline):**
Checklist visual para vender Cash-Secured Puts con disciplina: 10 criterios, zonas de soporte/resistencia y avisos de volatilidad, todo en un panel.

---

## Resumen

Herramienta todo-en-uno para organizar la decisión de vender **Cash-Secured Puts (CSP)** sobre acciones de calidad, siguiendo un checklist de criterios fijo y disciplinado. Reúne en un solo panel el estado de cada criterio de entrada, dibuja las zonas de soporte y resistencia del rango, mide qué tan extendido está el precio respecto a sus medias, y avisa de caídas intradía que suelen elevar la volatilidad implícita.

La idea es simple: **quitar la emoción de la decisión**. En vez de vender un put "porque se ve barato", el panel te obliga a revisar los mismos criterios cada vez y te da un veredicto claro de si el nombre es candidato o si toca esperar.

## Qué muestra

- **Panel de 10 criterios:** calidad del subyacente, contexto técnico vs media de 200, cash requerido, IV Rank, delta objetivo, DTE, yield estimado, y recordatorios de los criterios que requieren tu confirmación manual (catalizador, earnings y exposición de sector).
- **Zonas de soporte/resistencia:** caja verde en la mitad inferior del rango (soporte/demanda) y caja roja en la superior (resistencia), calculadas con el máximo y mínimo del lookback. Incluye líneas de máximo, mínimo y punto medio, y marca el soporte como referencia de strike.
- **Descuento vs EMA50 y EMA200:** mide en porcentaje qué tan lejos está el precio de sus medias. Negativo = pullback/descuento; positivo = extendido/premium.
- **Aviso de caída del día:** etiqueta ↓IV cuando el precio cae dentro de una banda configurable (2–5% por defecto), como señal de posible salto de volatilidad.
- **Línea de strike estimado:** nivel aproximado según la delta objetivo que elijas.
- **Veredicto:** 🟢 CANDIDATO / 🔴 ESPERAR según los criterios que el script puede evaluar de forma automática.

## Cómo se usa

1. Aplica el indicador sobre una acción de tu universo de calidad.
2. Revisa el panel: el veredicto se pone en 🟢 cuando se cumplen los criterios automáticos.
3. Confirma los criterios manuales (catalizador, earnings, sector) y, sobre todo, la **delta y la prima reales en tu bróker**.
4. Usa las zonas y el descuento vs EMA para afinar el momento de entrada: lo ideal es vender el put con el precio en zona de soporte y con descuento respecto a la EMA50.
5. Activa las alertas (clic derecho en el gráfico → Añadir alerta) para recibir avisos de candidato, caída del día o entrada a la zona de soporte.

## Ajustes principales

- DTE objetivo, modo de delta (want-to-own 0.20–0.30 o premium grab 0.10–0.15) y yield mensual objetivo.
- Ventana de HV y lookback del IV Rank.
- EMAs de referencia y si el criterio técnico usa EMA o SMA.
- Banda de la caída del día.
- Lookback y grosor de las zonas de soporte/resistencia (se pueden apagar por completo).

## Nota importante

Este indicador es una **herramienta educativa y de organización, no una recomendación de inversión**.

Pine Script no tiene acceso a la cadena de opciones. Por eso, el **IV Rank se aproxima con la volatilidad histórica (HV)** y el **yield se estima con el modelo Black-Scholes** usando esa HV como proxy de la volatilidad implícita. Los valores reales de delta, prima e IV deben confirmarse siempre en tu bróker, sobre todo cerca de reportes de resultados, cuando la IV real suele superar a la HV.

Vender opciones conlleva riesgo de asignación y de pérdida. Cada quien opera bajo su propio criterio y gestión de riesgo.

---

## Source Code

````pine
//@version=6
// ============================================================
//  PRONTUARIO CSP - PMC + ZONAS S/R  |  Rumbo1Millón
//  TODO EN UNO:
//   - Tabla de los 10 criterios del prontuario PMC
//   - Aviso ↓IV de caída del día (banda 2-5%)
//   - Descuento del precio vs EMA50 / EMA200
//   - Línea de strike estimado por delta objetivo
//   - Zonas de soporte (verde) y resistencia (roja) del rango
//
//  ⚠️ Delta y prima reales SIEMPRE se confirman en TradeStation.
//  El IVR y el yield del panel son proxies con HV.
// ============================================================

indicator("Prontuario CSP + Zonas | R1M", overlay=true)

// ===================== ENTRADAS =====================
grpP = "Parámetros CSP (PMC)"
dte       = input.int(35, "DTE objetivo (30-45)", minval=1, group=grpP)
modo      = input.string("Want to own (0.20-0.30)", "Modo delta", options=["Want to own (0.20-0.30)", "Premium grab (0.10-0.15)"], group=grpP)
contratos = input.int(1, "Contratos (para cash req)", minval=1, group=grpP)
yTarget   = input.float(2.0, "Yield mensual objetivo %", minval=0, step=0.1, group=grpP)

grpV = "Volatilidad / Técnico"
hvLen     = input.int(20,  "Ventana HV", minval=5, group=grpV)
rankLook  = input.int(252, "Lookback ranking IVR (barras)", minval=50, group=grpV)
trendLen  = input.int(200, "Media de tendencia/soporte", group=grpV)
emaFastLen = input.int(50,  "EMA rápida (descuento)", group=grpV)
emaSlowLen = input.int(200, "EMA lenta (descuento)", group=grpV)
useEmaTrend = input.bool(true, "Criterio #2 usa EMA (no SMA)", group=grpV)
rf        = input.float(0.04, "Tasa libre de riesgo (BS)", step=0.005, group=grpV)

grpD = "Alerta de caída del día"
dropMin   = input.float(2.0, "Caída mínima %", minval=0, step=0.1, group=grpD)
dropMax   = input.float(5.0, "Caída máxima %", minval=0, step=0.1, group=grpD)

grpZ = "Zonas S/R (rango)"
showZones = input.bool(true, "Mostrar zonas de soporte/resistencia", group=grpZ)
rangeLen  = input.int(150, "Barras del rango (lookback)", minval=10, group=grpZ)
zonePct   = input.float(50, "Grosor de cada zona (% del rango)", minval=5, maxval=50, group=grpZ)
extendR   = input.int(10, "Extender cajas a la derecha (barras)", minval=0, group=grpZ)
cDemand   = input.color(color.new(color.green, 85), "Zona de compra (soporte)", group=grpZ)
cSupply   = input.color(color.new(color.red, 85), "Zona de resistencia", group=grpZ)

// ===================== FUNCIONES =====================
// CDF normal estándar (aprox. Zelen & Severo)
f_ncdf(x) =>
    tt = 1.0 / (1.0 + 0.2316419 * math.abs(x))
    dd = 0.3989422804014327 * math.exp(-x * x / 2.0)
    pp = dd * tt * (0.319381530 + tt * (-0.356563782 + tt * (1.781477937 + tt * (-1.821255978 + tt * 1.330274429))))
    x > 0 ? 1.0 - pp : pp

// Precio de un PUT europeo por Black-Scholes
f_bsPut(S, K, sigma, Tt, r) =>
    sig = math.max(sigma, 0.0001)
    d1 = (math.log(S / K) + (r + sig * sig / 2.0) * Tt) / (sig * math.sqrt(Tt))
    d2 = d1 - sig * math.sqrt(Tt)
    K * math.exp(-r * Tt) * f_ncdf(-d2) - S * f_ncdf(-d1)

// ===================== CÁLCULOS BASE =====================
logRet = math.log(close / close[1])
hv     = ta.stdev(logRet, hvLen) * math.sqrt(252) * 100          // HV anualizada %
hvHi   = ta.highest(hv, rankLook)
hvLo   = ta.lowest(hv, rankLook)
ivr    = (hvHi - hvLo) != 0 ? (hv - hvLo) / (hvHi - hvLo) * 100 : na  // proxy IVR
smaTr  = ta.sma(close, trendLen)

// EMAs y descuento del precio respecto a ellas
emaFast = ta.ema(close, emaFastLen)
emaSlow = ta.ema(close, emaSlowLen)
discFast = (close - emaFast) / emaFast * 100
discSlow = (close - emaSlow) / emaSlow * 100
trendRef = useEmaTrend ? emaSlow : smaTr

// Cambio del día (funciona en cualquier temporalidad)
prevDayClose = request.security(syminfo.tickerid, "D", close[1], lookahead=barmerge.lookahead_off)
dayChg = prevDayClose > 0 ? (close - prevDayClose) / prevDayClose * 100 : na
dropHit = not na(dayChg) and dayChg <= -dropMin and dayChg >= -dropMax

T      = dte / 365.0
sigma  = hv / 100.0
zMult  = modo == "Premium grab (0.10-0.15)" ? 1.15 : 0.674
deltaLbl = modo == "Premium grab (0.10-0.15)" ? "0.10-0.15" : "0.20-0.30"
em     = close * sigma * math.sqrt(T)
strikeEst = close - zMult * em

premEst   = f_bsPut(close, strikeEst, sigma, T, rf)
premEst   := math.max(premEst, 0.0)
yieldPer  = strikeEst > 0 ? premEst / strikeEst * 100 : na
yieldMens = yieldPer * (30.0 / dte)
cashReq   = strikeEst * 100 * contratos

// ===================== RANGO / ZONAS S/R =====================
rHi = ta.highest(high, rangeLen)
rLo = ta.lowest(low, rangeLen)
rRng = rHi - rLo
rMid = (rHi + rLo) / 2.0
demandTop = rLo + rRng * zonePct / 100.0
supplyBot = rHi - rRng * zonePct / 100.0
inDemand = close <= demandTop
inSupply = close >= supplyBot

// ===================== CRITERIOS PRONTUARIO =====================
qt     = array.from("GOOGL","GOOG","MSFT","META","AVGO","NVDA","AMZN","TSM","ASML","MELI")
inQT   = array.includes(qt, syminfo.ticker)

c1 = inQT
c2 = close > trendRef
c4 = not na(ivr) and ivr >= 30
c7 = dte >= 30 and dte <= 45
c9 = not na(yieldMens) and yieldMens >= yTarget
cspAuto = c1 and c2 and c4 and c7 and c9

// ===================== SEÑALES EN GRÁFICO =====================
plotshape(cspAuto and not cspAuto[1], title="Candidato CSP", style=shape.triangleup, location=location.belowbar, color=color.new(color.green, 0), size=size.small, text="CSP")
bgcolor(cspAuto ? color.new(color.green, 90) : na, title="Zona CSP")
plotshape(dropHit and not dropHit[1], title="Caida del dia en banda", style=shape.labeldown, location=location.abovebar, color=color.new(color.orange, 0), textcolor=color.white, size=size.tiny, text="↓IV")

// --- Línea de strike por delta + zonas S/R ---
var line  lnK  = na
var label lbK  = na
var box   bxD  = na
var box   bxS  = na
var line  lnHi = na
var line  lnLo = na
var line  lnMid = na
var label lbSop = na
if barstate.islast
    line.delete(lnK)
    label.delete(lbK)
    lnK := line.new(bar_index - 30, strikeEst, bar_index + 5, strikeEst, color=color.orange, style=line.style_dashed, width=1)
    lbK := label.new(bar_index + 5, strikeEst, "Strike~Δ" + deltaLbl + "  $" + str.tostring(strikeEst, "#.##"), style=label.style_label_left, color=color.new(color.orange, 15), textcolor=color.white, size=size.small)
    // Zonas S/R
    box.delete(bxD)
    box.delete(bxS)
    line.delete(lnHi)
    line.delete(lnLo)
    line.delete(lnMid)
    label.delete(lbSop)
    if showZones
        left  = bar_index - rangeLen
        right = bar_index + extendR
        bxD  := box.new(left, demandTop, right, rLo, bgcolor=cDemand, border_color=color.new(color.green, 50), border_width=1)
        bxS  := box.new(left, rHi, right, supplyBot, bgcolor=cSupply, border_color=color.new(color.red, 50), border_width=1)
        lnHi := line.new(left, rHi, right, rHi, color=color.red, width=2)
        lnLo := line.new(left, rLo, right, rLo, color=color.green, width=2)
        lnMid := line.new(left, rMid, right, rMid, color=color.gray, style=line.style_dashed, width=1)
        lbSop := label.new(right, rLo, "Soporte  $" + str.tostring(rLo, "#.##"), style=label.style_label_left, color=color.new(color.green, 20), textcolor=color.white, size=size.small)

// ===================== PANEL =====================
f_mk(cond) => cond ? "✅" : "❌"
ivrTxt  = na(ivr) ? "s/d" : ivr >= 50 ? "✅ >50 (" + str.tostring(ivr, "#") + ")" : ivr >= 30 ? "🟡 ok (" + str.tostring(ivr, "#") + ")" : "❌ <30 (" + str.tostring(ivr, "#") + ")"
yTxt    = na(yieldMens) ? "s/d" : (c9 ? "✅ " : "❌ ") + str.tostring(yieldMens, "#.##") + "% men"

var table t = table.new(position.top_right, 2, 16, border_width=1, bgcolor=color.new(#0d1f17, 5))
if barstate.islast
    table.cell(t, 0, 0,  "PRONTUARIO CSP · PMC", text_color=#2ecc71, text_size=size.normal)
    table.cell(t, 1, 0,  syminfo.ticker, text_color=#2ecc71, text_size=size.normal)
    table.cell(t, 0, 1,  "1. Calidad (Quality Tier)", text_color=color.white)
    table.cell(t, 1, 1,  f_mk(c1))
    table.cell(t, 0, 2,  "2. Técnico > " + (useEmaTrend ? "EMA" : "SMA") + str.tostring(emaSlowLen), text_color=color.white)
    table.cell(t, 1, 2,  f_mk(c2))
    table.cell(t, 0, 3,  "3. Cash req (" + str.tostring(contratos) + "c)", text_color=color.gray)
    table.cell(t, 1, 3,  "$" + str.tostring(cashReq, "#"), text_color=color.gray)
    table.cell(t, 0, 4,  "4. IV Rank", text_color=color.white)
    table.cell(t, 1, 4,  ivrTxt)
    table.cell(t, 0, 5,  "5. Catalizador + exit", text_color=color.orange)
    table.cell(t, 1, 5,  "⚠️ manual")
    table.cell(t, 0, 6,  "6. Delta " + deltaLbl, text_color=color.gray)
    table.cell(t, 1, 6,  "$" + str.tostring(strikeEst, "#.##"), text_color=color.gray)
    table.cell(t, 0, 7,  "7. DTE 30-45", text_color=color.white)
    table.cell(t, 1, 7,  (c7 ? "✅ " : "❌ ") + str.tostring(dte) + "d")
    table.cell(t, 0, 8,  "8. Earnings calendar", text_color=color.orange)
    table.cell(t, 1, 8,  "⚠️ manual")
    table.cell(t, 0, 9,  "9. Yield ≥" + str.tostring(yTarget, "#.#") + "% (est)", text_color=color.white)
    table.cell(t, 1, 9,  yTxt)
    table.cell(t, 0, 10, "10. Sector exposure", text_color=color.orange)
    table.cell(t, 1, 10, "⚠️ manual")
    dayTxt = na(dayChg) ? "s/d" : (dropHit ? "🟠 " : "") + str.tostring(dayChg, "#.##") + "%"
    dayCol = dropHit ? color.new(color.orange, 0) : color.new(#0d1f17, 5)
    table.cell(t, 0, 11, "Caída hoy (banda " + str.tostring(dropMin, "#.#") + "-" + str.tostring(dropMax, "#.#") + ")", text_color=color.white)
    table.cell(t, 1, 11, dayTxt, bgcolor=dayCol, text_color=color.white)
    dFastCol = discFast < 0 ? color.new(color.green, 60) : color.new(color.red, 70)
    dSlowCol = discSlow < 0 ? color.new(color.green, 60) : color.new(color.red, 70)
    fastTxt = (discFast >= 0 ? "+" : "") + str.tostring(discFast, "#.##") + "% " + (discFast >= 0 ? "sobre" : "bajo (desc)")
    slowTxt = (discSlow >= 0 ? "+" : "") + str.tostring(discSlow, "#.##") + "% " + (discSlow >= 0 ? "sobre" : "bajo (desc)")
    table.cell(t, 0, 12, "Precio vs EMA" + str.tostring(emaFastLen), text_color=color.white)
    table.cell(t, 1, 12, fastTxt, bgcolor=dFastCol, text_color=color.white)
    table.cell(t, 0, 13, "Precio vs EMA" + str.tostring(emaSlowLen), text_color=color.white)
    table.cell(t, 1, 13, slowTxt, bgcolor=dSlowCol, text_color=color.white)
    zoneTxt = inDemand ? "🟢 soporte" : inSupply ? "🔴 resistencia" : "⚪ medio"
    zoneCol = inDemand ? color.new(color.green, 0) : inSupply ? color.new(color.red, 0) : color.new(color.gray, 30)
    table.cell(t, 0, 14, "Zona rango", text_color=color.white)
    table.cell(t, 1, 14, zoneTxt, bgcolor=zoneCol, text_color=color.white)
    table.cell(t, 0, 15, "VEREDICTO", text_color=color.white, text_size=size.normal)
    table.cell(t, 1, 15, cspAuto ? "🟢 CANDIDATO*" : "🔴 ESPERAR", bgcolor=cspAuto ? color.new(color.green, 0) : color.new(color.red, 0), text_color=color.white, text_size=size.normal)

// ===================== ALERTAS NATIVAS =====================
alertcondition(cspAuto and not cspAuto[1], title="CSP: candidato válido (PMC)", message="{{ticker}}: cumple criterios auto del prontuario PMC. Confirmar #5 catalizador, #8 earnings, #10 sector, y delta+prima reales en TradeStation.")
alertcondition(dropHit and not dropHit[1], title="Caída del día 2-5% (posible CSP)", message="{{ticker}}: cayó dentro de la banda 2-5% hoy. IV probablemente elevado — revisar como posible entrada CSP.")
alertcondition(close <= demandTop and close[1] > demandTop, title="Entró a zona de soporte (CSP)", message="{{ticker}}: el precio entró a la zona de soporte del rango. Buen momento para evaluar un CSP.")
````
