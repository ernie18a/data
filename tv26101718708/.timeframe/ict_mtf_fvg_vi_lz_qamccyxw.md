# ICT - MTF FVG & VI  LZ

- url: https://www.tradingview.com/script/QaMCCyXw/
- type: indicator
- pine_id: PUB;5d2229b54c98495eb8b1a326929f7496
- version: 1.0

## Description

ICT MTF FVG & Volume Imbalance [VHX] LZ

Indicateur multi-timeframes basé sur les concepts ICT / Smart Money Concepts permettant d’afficher automatiquement les Fair Value Gaps (FVG) et Volume Imbalances (VI) sur plusieurs unités de temps.

Cette version LZ ajoute une couche d’alertes webhook en JSON pour suivre les événements importants des zones :
- Création de FVG / VI
- Mitigation / contact de zone
- Remplissage complet de zone

Fonctions principales :
✅ Affichage des FVG haussières et baissières
✅ Affichage des Volume Imbalances VI+ / VI-
✅ Jusqu’à 4 timeframes configurables
✅ Couleurs et transparences indépendantes par timeframe
✅ Extension automatique des zones non mitigées
✅ Option de masquage ou recoloration des zones mitigées
✅ Ligne C.E. / Consequent Encroachment pour les FVG
✅ Labels indiquant le type de zone et la timeframe
✅ Alertes webhook JSON compatibles avec une application externe ou un bridge local

Les alertes LZ sont prévues pour être utilisées avec :
“Tout appel de la fonction alert()” dans TradingView.

Exemple d’événements envoyés :
- FVG CREATED
- FVG MITIGATED
- FVG FILLED
- VI CREATED
- VI MITIGATED
- VI FILLED

Par défaut, seules certaines alertes sont activées afin de limiter le spam et éviter les déclenchements excessifs.

⚠️ Important :
Cet indicateur ne donne pas de conseil financier et ne constitue pas un signal d’achat ou de vente automatique. Il sert à visualiser des zones de déséquilibre et à fournir des alertes structurées pour analyse ou intégration externe.

Crédits :
Script original / base : Vulnerable_human_x
Extension et patchs LZ : alertes JSON, webhook, anti-spam, compatibilité bridge local.
Licence : Mozilla Public License 2.0

## Source Code

````pine
// This source code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Vulnerable_human_x  — MTF extension
// ICT MTF FVG & Volume Imbalance — 4 timeframes avec couleur/transparence indépendantes
// Patch LZ : alertes JSON FVG/VI CREATED / MITIGATED / FILLED
// Patch anti-spam : alert.freq_once_per_bar_close
// Patch JSON : suppression tickerid pour éviter JSON cassé TradingView

//@version=6
indicator('ICT - MTF FVG & VI [VHX] LZ', shorttitle='ICT MTF [VHX] LZ', overlay=true, max_boxes_count=500, max_lines_count=500, max_labels_count=500, behind_chart=true)

// ============================================================================
// PARAMÈTRES GLOBAUX
// ============================================================================
g_g = "⚙ Paramètres Globaux"
showFVG = input.bool(true, "Afficher FVG", group=g_g, inline="show")
showVI  = input.bool(true, "Afficher VI",  group=g_g, inline="show")

fvgMitType = input.string('Engulf', 'Mitigation FVG', options=['Engulf', 'Mitigate', 'Rebalance'], group=g_g, tooltip="Engulf : close du body dépasse la FVG.\nMitigate : un wick touche la FVG.\nRebalance : la FVG rétrécit au fur et à mesure qu'elle est comblée.")
viMitType  = input.string('Engulf', 'Mitigation VI',  options=['Engulf', 'Mitigate'], group=g_g, tooltip="Engulf : close du body dépasse la VI.\nMitigate : un wick touche la VI.")

extendBoxes   = input.bool(true,  "Étendre boxes non mitigées", group=g_g)
hideMitigated = input.bool(false, "Masquer boxes mitigées",     group=g_g)
mitBoxColor   = input.color(color.new(color.gray, 88), "Couleur boxes mitigées", group=g_g)

showCE   = input.bool(true, "Ligne C.E. (Consequent Encroachment)", group=g_g)
ceTransp = input.int(55, "Transp. C.E.", minval=0, maxval=100, group=g_g)
ceStyle  = input.string(line.style_dashed, "Style C.E.", options=[line.style_solid, line.style_dashed, line.style_dotted], group=g_g)

showLabel   = input.bool(true,  "Labels (type + TF)", group=g_g)
labelSize   = input.string(size.tiny, "Taille label", options=[size.tiny, size.small, size.normal, size.large], group=g_g)
labelColor  = input.color(color.new(color.white, 10), "Couleur label", group=g_g)
labelHAlign = input.string(text.align_right, "Alignement H. label", options=[text.align_left, text.align_center, text.align_right], group=g_g)
labelVAlign = input.string(text.align_center, "Alignement V. label", options=[text.align_top, text.align_center, text.align_bottom], group=g_g)

borderStyle  = input.string(line.style_solid, "Style bordure", options=[line.style_solid, line.style_dashed, line.style_dotted], group=g_g)
borderTransp = input.int(55, "Transp. bordure", minval=0, maxval=100, group=g_g)

maxBoxesPerTF = input.int(10, "Max boxes / type / TF", minval=1, maxval=50, group=g_g)

// ============================================================================
// ALERTES LZ WEBHOOK
// ============================================================================
g_lz = "🔔 Alertes LZ Webhook"

lzEnableAlerts      = input.bool(true, "Activer alertes LZ webhook", group=g_lz)

// Par défaut : on limite fort pour éviter "Trop de déclenchements".
lzAlertFvgCreated   = input.bool(false, "FVG créée / affichée", group=g_lz)
lzAlertFvgMitigated = input.bool(false, "FVG touchée / mitigée", group=g_lz)
lzAlertFvgFilled    = input.bool(false, "FVG comblée totalement", group=g_lz)

lzAlertViCreated    = input.bool(false, "VI créée / affichée", group=g_lz)
lzAlertViMitigated  = input.bool(true,  "VI touchée / mitigée", group=g_lz)
lzAlertViFilled     = input.bool(false, "VI comblée totalement", group=g_lz)

// ============================================================================
// TF 1
// ============================================================================
g1 = "⏱ TF 1"
en1    = input.bool(true, "Activer TF 1", group=g1)
tf1    = input.timeframe("5", "Résolution", group=g1)
fvgBu1 = input.color(color.green,  "FVG+", group=g1, inline="a1")
tfvg1a = input.int(82, "Transp.", minval=0, maxval=100, group=g1, inline="a1")
fvgBe1 = input.color(color.red,    "FVG-", group=g1, inline="b1")
tfvg1b = input.int(82, "Transp.", minval=0, maxval=100, group=g1, inline="b1")
viBu1  = input.color(#00e640,      "VI+",  group=g1, inline="c1")
tvi1a  = input.int(82, "Transp.", minval=0, maxval=100, group=g1, inline="c1")
viBe1  = input.color(#e30000,      "VI-",  group=g1, inline="d1")
tvi1b  = input.int(82, "Transp.", minval=0, maxval=100, group=g1, inline="d1")

// ============================================================================
// TF 2
// ============================================================================
g2 = "⏱ TF 2"
en2    = input.bool(true, "Activer TF 2", group=g2)
tf2    = input.timeframe("15", "Résolution", group=g2)
fvgBu2 = input.color(#26a69a, "FVG+", group=g2, inline="a2")
tfvg2a = input.int(80, "Transp.", minval=0, maxval=100, group=g2, inline="a2")
fvgBe2 = input.color(#ef5350, "FVG-", group=g2, inline="b2")
tfvg2b = input.int(80, "Transp.", minval=0, maxval=100, group=g2, inline="b2")
viBu2  = input.color(#4caf50, "VI+",  group=g2, inline="c2")
tvi2a  = input.int(80, "Transp.", minval=0, maxval=100, group=g2, inline="c2")
viBe2  = input.color(#f44336, "VI-",  group=g2, inline="d2")
tvi2b  = input.int(80, "Transp.", minval=0, maxval=100, group=g2, inline="d2")

// ============================================================================
// TF 3
// ============================================================================
g3 = "⏱ TF 3"
en3    = input.bool(true, "Activer TF 3", group=g3)
tf3    = input.timeframe("60", "Résolution", group=g3)
fvgBu3 = input.color(#1b5e20, "FVG+", group=g3, inline="a3")
tfvg3a = input.int(75, "Transp.", minval=0, maxval=100, group=g3, inline="a3")
fvgBe3 = input.color(#b71c1c, "FVG-", group=g3, inline="b3")
tfvg3b = input.int(75, "Transp.", minval=0, maxval=100, group=g3, inline="b3")
viBu3  = input.color(#2e7d32, "VI+",  group=g3, inline="c3")
tvi3a  = input.int(75, "Transp.", minval=0, maxval=100, group=g3, inline="c3")
viBe3  = input.color(#c62828, "VI-",  group=g3, inline="d3")
tvi3b  = input.int(75, "Transp.", minval=0, maxval=100, group=g3, inline="d3")

// ============================================================================
// TF 4
// ============================================================================
g4 = "⏱ TF 4"
en4    = input.bool(false, "Activer TF 4", group=g4)
tf4    = input.timeframe("240", "Résolution", group=g4)
fvgBu4 = input.color(#004d40, "FVG+", group=g4, inline="a4")
tfvg4a = input.int(70, "Transp.", minval=0, maxval=100, group=g4, inline="a4")
fvgBe4 = input.color(#7f0000, "FVG-", group=g4, inline="b4")
tfvg4b = input.int(70, "Transp.", minval=0, maxval=100, group=g4, inline="b4")
viBu4  = input.color(#00796b, "VI+",  group=g4, inline="c4")
tvi4a  = input.int(70, "Transp.", minval=0, maxval=100, group=g4, inline="c4")
viBe4  = input.color(#4e0000, "VI-",  group=g4, inline="d4")
tvi4b  = input.int(70, "Transp.", minval=0, maxval=100, group=g4, inline="d4")

// ============================================================================
// TYPES
// ============================================================================
type Imb
    box    b
    line   ce
    float  boxTop
    float  boxBottom
    bool   isBull
    bool   mitigated
    bool   alertMitigated
    bool   filled
    string kind
    string tfStr

// ============================================================================
// ÉTAT : tableaux persistants par TF
// ============================================================================
var array<Imb> a1_f = array.new<Imb>()
var array<Imb> a1_v = array.new<Imb>()
var array<Imb> a2_f = array.new<Imb>()
var array<Imb> a2_v = array.new<Imb>()
var array<Imb> a3_f = array.new<Imb>()
var array<Imb> a3_v = array.new<Imb>()
var array<Imb> a4_f = array.new<Imb>()
var array<Imb> a4_v = array.new<Imb>()

// ============================================================================
// HELPERS
// ============================================================================
paint(color c, int t) => color.new(color.new(c, 0), t)

fmt(float v) =>
    str.tostring(v, format.mintick)

lzShouldSend(string eventName, string kind) =>
    send = false

    if kind == "FVG"
        if eventName == "CREATED"
            send := lzAlertFvgCreated
        else if eventName == "MITIGATED"
            send := lzAlertFvgMitigated
        else if eventName == "FILLED"
            send := lzAlertFvgFilled

    else if kind == "VI"
        if eventName == "CREATED"
            send := lzAlertViCreated
        else if eventName == "MITIGATED"
            send := lzAlertViMitigated
        else if eventName == "FILLED"
            send := lzAlertViFilled

    send

lzSend(string eventName, string kind, bool bull, string tfStr, float top, float bot) =>
    if lzEnableAlerts and lzShouldSend(eventName, kind)
        side = kind + (bull ? "_PLUS" : "_MINUS")
        zoneBias = bull ? "BUY" : "SELL"
        mid = (top + bot) / 2.0

        // IMPORTANT :
        // Pas de tickerid ici, car sur certains symboles TradingView renvoie un tickerid JSON-like
        // qui casse le JSON webhook.
        msg = '{"type":"LZ_IMBALANCE_EVENT"' +
          ',"event":"' + eventName + '"' +
          ',"kind":"' + kind + '"' +
          ',"side":"' + side + '"' +
          ',"zone_bias":"' + zoneBias + '"' +
          ',"symbol":"' + syminfo.ticker + '"' +
          ',"chart_tf":"' + timeframe.period + '"' +
          ',"tf":"' + tfStr + '"' +
          ',"top":' + fmt(top) +
          ',"bottom":' + fmt(bot) +
          ',"mid":' + fmt(mid) +
          ',"price":' + fmt(close) +
          ',"bar_time_ms":' + str.tostring(time) +
          '}'

        alert(msg, alert.freq_once_per_bar_close)

lbl(string kind, bool bull, string tfStr) =>
    s = bull ? "+" : "-"
    kind + s + " " + tfStr

mkFVG(bool bull, int tL, int tR, float top, float bot, color col, int tr, string tfStr) =>
    bg = paint(col, tr)
    bc = paint(col, borderTransp)
    txt = showLabel ? lbl("FVG", bull, tfStr) : ""
    bx = box.new(left=tL, top=top, right=tR, bottom=bot, xloc=xloc.bar_time, bgcolor=bg, border_color=bc, border_style=borderStyle, text=txt, text_halign=labelHAlign, text_valign=labelVAlign, text_size=labelSize, text_color=labelColor)
    line ln = na
    if showCE
        mid = (top + bot) / 2
        ln := line.new(x1=tL, y1=mid, x2=tR, y2=mid, xloc=xloc.bar_time, color=paint(col, ceTransp), style=ceStyle)
    Imb.new(b=bx, ce=ln, boxTop=top, boxBottom=bot, isBull=bull, mitigated=false, alertMitigated=false, filled=false, kind="FVG", tfStr=tfStr)

mkVI(bool bull, int tL, int tR, float top, float bot, color col, int tr, string tfStr) =>
    bg = paint(col, tr)
    bc = paint(col, borderTransp)
    txt = showLabel ? lbl("VI", bull, tfStr) : ""
    bx = box.new(left=tL, top=top, right=tR, bottom=bot, xloc=xloc.bar_time, bgcolor=bg, border_color=bc, border_style=borderStyle, text=txt, text_halign=labelHAlign, text_valign=labelVAlign, text_size=labelSize, text_color=labelColor)
    Imb.new(b=bx, ce=na, boxTop=top, boxBottom=bot, isBull=bull, mitigated=false, alertMitigated=false, filled=false, kind="VI", tfStr=tfStr)

pushCap(array<Imb> arr, Imb item) =>
    arr.push(item)
    if arr.size() > maxBoxesPerTF
        f = arr.shift()
        box.delete(f.b)
        if not na(f.ce)
            line.delete(f.ce)

// ============================================================================
// METHOD : mise à jour d'une box à chaque bar
// - MITIGATED = prix touche la zone
// - FILLED = zone comblée totalement
// ============================================================================
method upd(Imb self, string mitType) =>
    top = self.boxTop
    bot = self.boxBottom
    bull = self.isBull

    touchNow = bull ? low <= top : high >= bot
    filledNow = bull ? low <= bot : high >= top

    if touchNow and not self.alertMitigated
        self.alertMitigated := true
        lzSend("MITIGATED", self.kind, self.isBull, self.tfStr, self.boxTop, self.boxBottom)

    if filledNow and not self.filled
        self.filled := true
        lzSend("FILLED", self.kind, self.isBull, self.tfStr, self.boxTop, self.boxBottom)

    if not self.mitigated
        mit = false

        if mitType == "Engulf"
            mit := bull ? close < bot : close > top
        else if mitType == "Mitigate"
            mit := bull ? low < top : high > bot
        else if mitType == "Rebalance" and self.kind == "FVG"
            if bull
                if low > bot and low < top
                    self.boxTop := low
                    box.set_top(self.b, low)
                    if not na(self.ce)
                        m = (low + bot) / 2
                        line.set_y1(self.ce, m)
                        line.set_y2(self.ce, m)
                else if low <= bot
                    mit := true
            else
                if high < top and high > bot
                    self.boxBottom := high
                    box.set_bottom(self.b, high)
                    if not na(self.ce)
                        m = (high + top) / 2
                        line.set_y1(self.ce, m)
                        line.set_y2(self.ce, m)
                else if high >= top
                    mit := true

        if mit
            self.mitigated := true
            if hideMitigated
                box.delete(self.b)
                if not na(self.ce)
                    line.delete(self.ce)
            else
                box.set_bgcolor(self.b, mitBoxColor)
                box.set_border_color(self.b, mitBoxColor)
                if not na(self.ce)
                    line.set_color(self.ce, mitBoxColor)
        else if extendBoxes
            dt = time - time[1]
            if not na(dt)
                nr = time + dt
                box.set_right(self.b, nr)
                if not na(self.ce)
                    line.set_x2(self.ce, nr)

// ============================================================================
// FONCTION : traitement d'une TF
// ============================================================================
process(simple string tf, simple bool enable, array<Imb> fArr, array<Imb> vArr,
        color fBu, int fBuT, color fBe, int fBeT,
        color vBu, int vBuT, color vBe, int vBeT) =>
    if enable
        [o, h, l, c, o1, h1, l1, c1, o2, h2, l2, c2, t, t1, t2] = request.security(syminfo.tickerid, tf,
            [open, high, low, close, open[1], high[1], low[1], close[1], open[2], high[2], low[2], close[2], time, time[1], time[2]],
            lookahead=barmerge.lookahead_off)

        newBar = ta.change(t) != 0
        dur_ms = timeframe.in_seconds(tf) * 1000
        tR = t + dur_ms * 2

        if newBar
            // ---- FVG ----
            if showFVG
                // Bull FVG / FVG+
                if not na(l) and not na(h2) and l > h2 and l1 <= h2 and h1 >= l
                    pushCap(fArr, mkFVG(true, t2, tR, l, h2, fBu, fBuT, tf))
                    lzSend("CREATED", "FVG", true, tf, l, h2)

                // Bear FVG / FVG-
                if not na(h) and not na(l2) and h < l2 and h >= l1 and h1 >= l2
                    pushCap(fArr, mkFVG(false, t2, tR, l2, h, fBe, fBeT, tf))
                    lzSend("CREATED", "FVG", false, tf, l2, h)

            // ---- VI ----
            if showVI
                // Bull VI / VI+
                if not na(o) and not na(c1) and o > c1 and l <= h1 and c > o and c1 > o1
                    pushCap(vArr, mkVI(true, t1, tR, o, c1, vBu, vBuT, tf))
                    lzSend("CREATED", "VI", true, tf, o, c1)

                // Bear VI / VI-
                if not na(o) and not na(c1) and o < c1 and h >= l1 and c < o and c1 < o1
                    pushCap(vArr, mkVI(false, t1, tR, c1, o, vBe, vBeT, tf))
                    lzSend("CREATED", "VI", false, tf, c1, o)

    // Mitigation + extension
    if fArr.size() > 0
        for i = fArr.size() - 1 to 0
            item = fArr.get(i)
            item.upd(fvgMitType)

    if vArr.size() > 0
        for i = vArr.size() - 1 to 0
            item = vArr.get(i)
            item.upd(viMitType)

// ============================================================================
// EXÉCUTION PAR TF
// ============================================================================
process(tf1, en1, a1_f, a1_v, fvgBu1, tfvg1a, fvgBe1, tfvg1b, viBu1, tvi1a, viBe1, tvi1b)
process(tf2, en2, a2_f, a2_v, fvgBu2, tfvg2a, fvgBe2, tfvg2b, viBu2, tvi2a, viBe2, tvi2b)
process(tf3, en3, a3_f, a3_v, fvgBu3, tfvg3a, fvgBe3, tfvg3b, viBu3, tvi3a, viBe3, tvi3b)
process(tf4, en4, a4_f, a4_v, fvgBu4, tfvg4a, fvgBe4, tvi4b, viBu4, tvi4a, viBe4, tvi4b)

// ============================================================================
// ALERTCONDITIONS OPTIONNELLES
// Les vraies alertes webhook LZ passent par alert().
// Dans TradingView, choisis : Tout appel de la fonction alerte().
// ============================================================================
newBar1 = en1 ? (ta.change(request.security(syminfo.tickerid, tf1, time, lookahead=barmerge.lookahead_off)) != 0) : false
newBar2 = en2 ? (ta.change(request.security(syminfo.tickerid, tf2, time, lookahead=barmerge.lookahead_off)) != 0) : false
newBar3 = en3 ? (ta.change(request.security(syminfo.tickerid, tf3, time, lookahead=barmerge.lookahead_off)) != 0) : false
newBar4 = en4 ? (ta.change(request.security(syminfo.tickerid, tf4, time, lookahead=barmerge.lookahead_off)) != 0) : false

alertcondition(newBar1, title="Nouvelle bar TF1", message="Nouvelle bougie clôturée sur TF1 : {{ticker}} {{interval}}")
alertcondition(newBar2, title="Nouvelle bar TF2", message="Nouvelle bougie clôturée sur TF2 : {{ticker}} {{interval}}")
alertcondition(newBar3, title="Nouvelle bar TF3", message="Nouvelle bougie clôturée sur TF3 : {{ticker}} {{interval}}")
alertcondition(newBar4, title="Nouvelle bar TF4", message="Nouvelle bougie clôturée sur TF4 : {{ticker}} {{interval}}")

// Fin du script
````
