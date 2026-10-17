# XauLabs  Sessions & Kill Zones

- url: https://www.tradingview.com/script/4XT2JKkC/
- type: indicator
- pine_id: PUB;2205d158281f48f18a07c0d3ecb74e20
- version: 1.0

## Description

ENGLISH

What it does

Gold does not behave the same way around the clock. This indicator draws one box around each trading session — Asia, London, New York — covering exactly the price range that session has traded, and highlights two narrower windows inside them, commonly called Kill Zones, where volatility and participation concentrate. It answers one question only: what time is it, in market terms — and what has each part of the day actually done?

How it works (full method)

Session definition. Five time windows are defined in UTC and are all user-editable. Defaults: Asia 23:00–08:00, London 07:00–16:00, New York 12:30–21:00, London Kill Zone 07:00–10:00, New York Kill Zone 13:30–16:00. UTC is used deliberately so the display does not shift with the chart's timezone or with daylight saving changes in a single region.
Range boxes. When a session opens, a box is created at that bar. On every following bar of the session, the box extends to the right and its top and bottom are pushed to the highest high and lowest low reached so far. When the session ends, the box stops: what remains is the session's true footprint — its duration and its full price range.
Visual hierarchy. Sessions are drawn as thin outlines with no fill, one colour each (Asia blue, London amber, New York violet). Kill Zones are the only filled boxes, in red with a thicker border, and carry their name. A Kill Zone lives inside its parent session: you see a red block inside a thin frame, not two shapes fighting.
Dashboard. A panel in the top-right corner names the window currently active, then lists all five windows with a colour swatch and a countdown: "ends in 1h04" for an open window, "in 7h15" for the next occurrence of a closed one. The panel doubles as the colour legend.
Timeframe guard. Above H1 the whole display is suppressed and the panel says so. A four-hour candle spans several sessions, so a session reading on it would be meaningless. Rather than draw something wrong, the tool draws nothing.

No repainting

Boxes are anchored to bar timestamps and only ever extend forward as bars close; the countdown panel is informational and recomputed on the last bar. Nothing is redrawn after the fact: a box you see in history is exactly what was drawn live.

On-chart output

One outlined box per session occurrence, kept in history for day-to-day comparison.
Filled red boxes on both Kill Zones, with their names.
The dashboard panel with current window and countdowns, selectable text size.
Two alert conditions: London Kill Zone opening, New York Kill Zone opening.

Suggested use

M15 or M5. Watch how narrow the Asian box builds overnight, how the London open attacks its boundaries, and how often the day's real move starts inside a red window. Comparing box heights across days gives an immediate feel for which sessions are carrying the volatility. Used as a context filter, it answers when a setup is worth taking, not what the setup is.

All colours, fill strengths, session hours and display options are user-configurable.

This is an educational timing tool. It gives no buy or sell signals and makes no performance claim. Trading involves substantial risk of loss.

FRANÇAIS

Ce que fait l'indicateur

L'or ne se comporte pas de la même façon selon l'heure. Cet indicateur dessine une boîte autour de chaque session de cotation — Asie, Londres, New York — couvrant exactement l'amplitude de prix parcourue par cette session, et met en évidence deux fenêtres plus étroites à l'intérieur, communément appelées Kill Zones, où la volatilité et la participation se concentrent. Il répond à une seule question : quelle heure est-il, au sens du marché — et qu'a réellement fait chaque partie de la journée ?

Comment il fonctionne (méthode complète)

Définition des sessions. Cinq fenêtres horaires sont définies en UTC et toutes modifiables par l'utilisateur. Par défaut : Asie 23h00–08h00, Londres 07h00–16h00, New York 12h30–21h00, Kill Zone Londres 07h00–10h00, Kill Zone New York 13h30–16h00. L'UTC est un choix délibéré : l'affichage ne se décale ni avec le fuseau du graphique, ni avec les changements d'heure d'une seule région.
Boîtes d'amplitude. À l'ouverture d'une session, une boîte est créée sur cette bougie. À chaque bougie suivante de la session, la boîte s'étend vers la droite et ses bords haut et bas sont poussés jusqu'au plus haut et au plus bas atteints. À la fin de la session, la boîte s'arrête : il reste l'empreinte réelle de la session — sa durée et son amplitude complète.
Hiérarchie visuelle. Les sessions sont tracées en contour fin sans remplissage, une couleur chacune (Asie bleu, Londres ambre, New York violet). Les Kill Zones sont les seules boîtes remplies, en rouge avec bordure renforcée, et portent leur nom. Une Kill Zone vit à l'intérieur de sa session : on voit un bloc rouge dans un cadre fin, pas deux formes qui se disputent.
Tableau de bord. Un panneau dans le coin supérieur droit nomme la fenêtre en cours, puis liste les cinq fenêtres avec une pastille de couleur et un décompte : « finit dans 1h04 » pour une fenêtre ouverte, « dans 7h15 » pour la prochaine occurrence d'une fenêtre fermée. Le panneau sert aussi de légende des couleurs.
Garde-fou d'unité de temps. Au-dessus de H1, tout l'affichage est supprimé et le panneau l'indique. Une bougie de 4 heures couvre plusieurs sessions : y lire une session n'aurait aucun sens. Plutôt que d'afficher quelque chose de faux, l'outil n'affiche rien.

Aucun repaint

Les boîtes sont ancrées sur l'horodatage des bougies et ne font que s'étendre vers l'avant à mesure que les bougies clôturent ; le panneau de décomptes est informatif et recalculé sur la dernière bougie. Rien n'est redessiné après coup : une boîte visible dans l'historique est exactement celle qui a été tracée en direct.

Affichage

Une boîte en contour par occurrence de session, conservée dans l'historique pour comparer les journées.
Des boîtes rouges remplies sur les deux Kill Zones, avec leur nom.
Le tableau de bord avec fenêtre en cours et décomptes, taille de texte réglable.
Deux conditions d'alerte : ouverture de la Kill Zone de Londres, ouverture de celle de New York.

Utilisation suggérée

M15 ou M5. Observer comme la boîte asiatique se construit étroite pendant la nuit, comment l'ouverture de Londres attaque ses bornes, et combien de fois le vrai mouvement du jour démarre dans une fenêtre rouge. Comparer la hauteur des boîtes d'un jour à l'autre donne une lecture immédiate des sessions qui portent la volatilité. Utilisé comme filtre de contexte, il répond à la question de savoir quand un setup vaut la peine d'être pris, pas de quel setup il s'agit.

Toutes les couleurs, intensités de remplissage, heures de session et options d'affichage sont réglables.

Outil éducatif de lecture horaire. Il ne donne aucun signal d'achat ou de vente et ne formule aucune promesse de performance. Le trading comporte un risque de perte important.

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0
// © XauLabs
// NIVEAU 3 / 8 — Sessions & Kill Zones — v1.9
// Changements v1.8 -> v1.9 :
//   - Hiérarchie inversée : sessions en CONTOUR fin sans remplissage,
//     Kill Zones en BOÎTE PLEINE rouge — plus d'enchevêtrement quand la KZ vit dans la session
//   - Couleurs retravaillées : Asie bleu / Londres AMBRE / New York violet — plus de confusion
//   - Nom affiché uniquement sur les Kill Zones par défaut (sessions reconnaissables
//     à leur bordure + légende du tableau de bord) ; noms de session réactivables
//   - Bordures renforcées, lisibles sur thème clair

//@version=6
indicator("XauLabs — Sessions & Kill Zones", shorttitle="XauLabs · Sessions & KZ", overlay=true, max_boxes_count=500)

// ============================================================
// RÉGLAGES (heures en UTC)
// ============================================================
grpSessions = "Sessions (UTC)"
sessAsie    = input.session("2300-0800", "Session Asie",     group=grpSessions, display=display.none)
sessLondres = input.session("0700-1600", "Session Londres",  group=grpSessions, display=display.none)
sessNY      = input.session("1230-2100", "Session New York", group=grpSessions, display=display.none)
montrerSessions = input.bool(true, "Encadrer les sessions", group=grpSessions, display=display.none)

grpKZ = "Kill Zones (UTC) — les fenêtres décisives"
kzLondres = input.session("0700-1000", "Kill Zone Londres",  group=grpKZ, display=display.none)
kzNY      = input.session("1330-1600", "Kill Zone New York", group=grpKZ, display=display.none)
montrerKZ = input.bool(true, "Encadrer les Kill Zones", group=grpKZ, display=display.none)

grpCouleurs = "Couleurs"
theme      = input.string("Sombre", "Thème du graphique", options=["Sombre", "Clair"], group=grpCouleurs, display=display.none, tooltip="Ajuste le contraste des textes au fond de votre graphique.")
teinteAsie = input.color(#4A7FD6, "Asie",       group=grpCouleurs, inline="a", display=display.none)
opacAsie   = input.int(0,  "fond %", minval=0, maxval=50, step=2, group=grpCouleurs, inline="a", display=display.none)
teinteLon  = input.color(#E08A2E, "Londres",    group=grpCouleurs, inline="b", display=display.none)
opacLon    = input.int(0,  "fond %", minval=0, maxval=50, step=2, group=grpCouleurs, inline="b", display=display.none)
teinteNY   = input.color(#9B6BD6, "New York",   group=grpCouleurs, inline="c", display=display.none)
opacNY     = input.int(0,  "fond %", minval=0, maxval=50, step=2, group=grpCouleurs, inline="c", display=display.none)
teinteKZ   = input.color(#D93B3B, "Kill Zones", group=grpCouleurs, inline="d", display=display.none)
opacKZ     = input.int(18, "fond %", minval=0, maxval=60, step=2, group=grpCouleurs, inline="d", display=display.none)

grpAffichage = "Affichage"
montrerNomsKZ   = input.bool(true,  "Nom sur les Kill Zones", group=grpAffichage, display=display.none)
montrerNomsSess = input.bool(false, "Nom sur les sessions", group=grpAffichage, display=display.none)
montrerBadge = input.bool(true, "Tableau de bord (coin supérieur droit)", group=grpAffichage, display=display.none)
tailleBadge  = input.string(size.small, "Taille du texte", options=[size.tiny, size.small, size.normal, size.large], group=grpAffichage, display=display.none, tooltip="Passer en normal ou large pour une capture d'écran lisible.")

// ============================================================
// PALETTE
// ============================================================
clair     = theme == "Clair"
colTexte  = clair ? color.new(#2A2430, 0) : color.new(#F4EFE6, 0)
colFaible = clair ? color.new(#6B6474, 0) : color.new(#8A8494, 0)
colFondUI = clair ? color.new(#FFFFFF, 4) : color.new(#17141A, 6)
colBordUI = color.new(#D9A441, 55)
colAccent = color.new(#D9A441, 0)

// ============================================================
// LECTURE DES SESSIONS (basée sur l'heure — non-repainting par nature)
// ============================================================
estIntraday = timeframe.in_seconds() <= 3600

dansAsie    = estIntraday and not na(time(timeframe.period, sessAsie,    "UTC"))
dansLondres = estIntraday and not na(time(timeframe.period, sessLondres, "UTC"))
dansNY      = estIntraday and not na(time(timeframe.period, sessNY,      "UTC"))
dansKzLon   = estIntraday and not na(time(timeframe.period, kzLondres,   "UTC"))
dansKzNY    = estIntraday and not na(time(timeframe.period, kzNY,        "UTC"))

// ============================================================
// BOÎTES DE SESSION — un cadre par occurrence, ajusté bougie par bougie
// ============================================================
f_boite(bool dedans, box courante, color teinte, int opac, string nom, bool montrerCadre, bool avecNom, int epaisseur) =>
    box b = courante
    if montrerCadre
        if dedans and not dedans[1]
            b := box.new(left=time, top=high, right=time, bottom=low, xloc=xloc.bar_time, bgcolor=color.new(teinte, 100 - opac), border_color=color.new(teinte, 10), border_width=epaisseur, text=avecNom ? nom : "", text_color=color.new(teinte, 5), text_size=size.tiny, text_valign=text.align_top, text_halign=text.align_left)
        else if dedans and not na(b)
            box.set_right(b, time)
            box.set_top(b, math.max(box.get_top(b), high))
            box.set_bottom(b, math.min(box.get_bottom(b), low))
    b

var box bAsie  = na
var box bLon   = na
var box bNY    = na
var box bKzLon = na
var box bKzNY  = na

bAsie  := f_boite(dansAsie,    bAsie,  teinteAsie, opacAsie, "ASIE",     montrerSessions, montrerNomsSess, 1)
bLon   := f_boite(dansLondres, bLon,   teinteLon,  opacLon,  "LONDRES",  montrerSessions, montrerNomsSess, 1)
bNY    := f_boite(dansNY,      bNY,    teinteNY,   opacNY,   "NEW YORK", montrerSessions, montrerNomsSess, 1)
bKzLon := f_boite(dansKzLon,   bKzLon, teinteKZ,   opacKZ,   "KZ LONDRES",  montrerKZ, montrerNomsKZ, 2)
bKzNY  := f_boite(dansKzNY,    bKzNY,  teinteKZ,   opacKZ,   "KZ NEW YORK", montrerKZ, montrerNomsKZ, 2)

// ============================================================
// OUTILS DE CALENDRIER (tableau de bord)
// ============================================================
f_occ(string s, int maintenant) =>
    hd = str.tonumber(str.substring(s, 0, 2))
    md = str.tonumber(str.substring(s, 2, 4))
    hf = str.tonumber(str.substring(s, 5, 7))
    mf = str.tonumber(str.substring(s, 7, 9))
    an = year(maintenant, "UTC")
    mo = month(maintenant, "UTC")
    jo = dayofmonth(maintenant, "UTC")
    int rs = na
    int re = na
    bool trouve = false
    for off = -1 to 2
        if not trouve
            st = timestamp("UTC", an, mo, jo + off, math.round(hd), math.round(md))
            en = timestamp("UTC", an, mo, jo + off, math.round(hf), math.round(mf))
            if en <= st
                en += 86400000
            if en > maintenant
                rs := st
                re := en
                trouve := true
    [rs, re]

f_duree(int ms) =>
    tot = math.max(0, math.floor(ms / 60000))
    h   = math.floor(tot / 60)
    mn  = tot % 60
    h > 0 ? str.tostring(h) + "h" + (mn < 10 ? "0" : "") + str.tostring(mn) : str.tostring(mn) + "m"

// ============================================================
// TABLEAU DE BORD
// ============================================================
var table bord = table.new(position.top_right, 3, 6, border_width=1, border_color=colBordUI, frame_width=1, frame_color=colBordUI)

if barstate.islast and montrerBadge
    for r = 0 to 5
        for c = 0 to 2
            table.cell(bord, c, r, "", bgcolor=colFondUI)

    if not estIntraday
        table.cell(bord, 0, 0, " SESSIONS & KILL ZONES ", text_color=colAccent, text_size=tailleBadge, bgcolor=colFondUI)
        table.merge_cells(bord, 0, 0, 2, 0)
        table.cell(bord, 0, 1, " PASSE EN INTRADAY (≤ H1) ", text_color=colFaible, text_size=tailleBadge, bgcolor=colFondUI)
        table.merge_cells(bord, 0, 1, 2, 1)
    else
        maintenant = time_close
        string enCours = dansKzLon ? "KILL ZONE LONDRES" : dansKzNY ? "KILL ZONE NEW YORK" : dansLondres and dansNY ? "LONDRES + NEW YORK" : dansLondres ? "LONDRES" : dansNY ? "NEW YORK" : dansAsie ? "ASIE" : "HORS SESSION"
        color  colEnCours = (dansKzLon or dansKzNY) ? teinteKZ : dansLondres ? teinteLon : dansNY ? teinteNY : dansAsie ? teinteAsie : colFaible

        table.cell(bord, 0, 0, " EN COURS ", text_color=colFaible, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_left)
        table.cell(bord, 1, 0, " " + enCours + " ", text_color=colEnCours, text_size=tailleBadge, bgcolor=colFondUI, text_halign=text.align_left)
        table.merge_cells(bord, 1, 0, 2, 0)

        for i = 0 to 4
            string sess = i == 0 ? sessAsie : i == 1 ? sessLondres : i == 2 ? sessNY : i == 3 ? kzLondres : kzNY
            string nom  = i == 0 ? "Asie" : i == 1 ? "Londres" : i == 2 ? "New York" : i == 3 ? "KZ Londres" : "KZ New York"
            color  teinte = i == 0 ? teinteAsie : i == 1 ? teinteLon : i == 2 ? teinteNY : teinteKZ
            [st, en] = f_occ(sess, maintenant)
            string etat = na(st) ? "—" : maintenant >= st ? "finit dans " + f_duree(en - maintenant) : "dans " + f_duree(st - maintenant)
            color  colEtat = na(st) ? colFaible : maintenant >= st ? colTexte : colFaible
            table.cell(bord, 0, i + 1, "  ", bgcolor=color.new(teinte, 0))
            table.cell(bord, 1, i + 1, " " + nom + " ", text_color=colTexte, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_left)
            table.cell(bord, 2, i + 1, " " + etat + " ", text_color=colEtat, text_size=size.tiny, bgcolor=colFondUI, text_halign=text.align_right)

// ============================================================
// ALERTES — ouverture des fenêtres décisives
// ============================================================
alertcondition(dansKzLon and not dansKzLon[1], "Kill Zone Londres — ouverture",  "Kill Zone de Londres : ouverture.")
alertcondition(dansKzNY  and not dansKzNY[1],  "Kill Zone New York — ouverture", "Kill Zone de New York : ouverture.")
````
