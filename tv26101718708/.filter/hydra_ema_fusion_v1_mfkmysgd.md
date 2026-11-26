# Hydra EMA Fusion V1

- url: https://www.tradingview.com/script/mFkMYsGD/
- type: indicator
- pine_id: PUB;ea5b6c8d47a343afa2860e0c1647579e
- version: 1.0

## Description

🧠 Hydra EMA Fusion V1
Hydra EMA Fusion V1 est un indicateur multi-timeframe conçu pour simplifier la lecture du marché en fusionnant plusieurs EMA en une seule ligne par timeframe.
🔷 Concept
Au lieu d’utiliser plusieurs EMA séparées, cet indicateur combine :
EMA rapides
EMA intermédiaires
EMA lentes
➡️ Le tout pondéré pour créer une ligne synthétique unique.
⚙️ Fonctionnement
🔹 4 timeframes affichées simultanément :
🔵 TF1 (1 min) → Micro structure
🟢 TF2 (15 min) → Intraday
🟠 TF3 (1H) → Structure
🔴 TF4 (4H) → Macro
Chaque ligne représente une fusion pondérée de 3 EMA.
📏 Compression & Distance
L’indicateur mesure l’écart (%) entre les lignes Hydra :
TF1 ↔ TF2
TF2 ↔ TF3
TF3 ↔ TF4
➡️ Permet d’identifier :
📉 Compression (marché en attente)
📈 Expansion (marché en mouvement)
⏱️ Timer de compression
Quand deux lignes deviennent très proches :
➡️ Un timer démarre automatiquement
👉 Plus le temps augmente, plus la probabilité d’un mouvement fort augmente.
📊 Tableau intégré
Un panneau affiche en temps réel :
Distance entre les TF
Temps de compression
➡️ Lecture rapide du contexte marché.
🎯 Utilisation
✅ Détection des phases d’accumulation
✅ Identification des breakouts potentiels
✅ Confirmation de tendance multi-timeframe
🔥 Idéal avec :
Order Blocks
Fibonacci
RSI multi-timeframe
🧠 Résumé
Hydra EMA Fusion transforme plusieurs EMA complexes en une lecture simple :
➡️ 4 lignes = état complet du marché
➡️ Compression = opportunité
➡️ Expansion = mouvement
Indicateur conçu pour les traders cherchant précision, clarté et timing.

Affichage de fibo lZ.txt en cours...

## Source Code

````pine
//@version=6
indicator("Hydra EMA Fusion V1", overlay=true, max_labels_count=500)

// === INPUTS ===
// Timeframes
tf1 = input.timeframe("1", "TF 1 (Blue)")
tf2 = input.timeframe("15", "TF 2 (Green)")
tf3 = input.timeframe("60", "TF 3 (Orange)")
tf4 = input.timeframe("240", "TF 4 (Red)")

// EMA settings for each TF (modulables)
ema1_tf1 = input.int(50, "TF1 EMA 1")
ema2_tf1 = input.int(100, "TF1 EMA 2")
ema3_tf1 = input.int(200, "TF1 EMA 3")
w1_tf1 = input.float(1, "TF1 Poids EMA1")
w2_tf1 = input.float(2, "TF1 Poids EMA2")
w3_tf1 = input.float(3, "TF1 Poids EMA3")

ema1_tf2 = input.int(50, "TF2 EMA 1")
ema2_tf2 = input.int(100, "TF2 EMA 2")
ema3_tf2 = input.int(200, "TF2 EMA 3")
w1_tf2 = input.float(1, "TF2 Poids EMA1")
w2_tf2 = input.float(2, "TF2 Poids EMA2")
w3_tf2 = input.float(3, "TF2 Poids EMA3")

ema1_tf3 = input.int(50, "TF3 EMA 1")
ema2_tf3 = input.int(100, "TF3 EMA 2")
ema3_tf3 = input.int(200, "TF3 EMA 3")
w1_tf3 = input.float(1, "TF3 Poids EMA1")
w2_tf3 = input.float(2, "TF3 Poids EMA2")
w3_tf3 = input.float(3, "TF3 Poids EMA3")

ema1_tf4 = input.int(50, "TF4 EMA 1")
ema2_tf4 = input.int(100, "TF4 EMA 2")
ema3_tf4 = input.int(200, "TF4 EMA 3")
w1_tf4 = input.float(1, "TF4 Poids EMA1")
w2_tf4 = input.float(2, "TF4 Poids EMA2")
w3_tf4 = input.float(3, "TF4 Poids EMA3")

// === HYDRA FUSION FUNCTION ===
f_fusion(_tf, e1, e2, e3, w1, w2, w3) =>
    ema1 = request.security(syminfo.tickerid, _tf, ta.ema(close, e1))
    ema2 = request.security(syminfo.tickerid, _tf, ta.ema(close, e2))
    ema3 = request.security(syminfo.tickerid, _tf, ta.ema(close, e3))
    (ema1 * w1 + ema2 * w2 + ema3 * w3) / (w1 + w2 + w3)

// === CALCUL DES 4 LIGNES HYDRA ===
fusion1 = f_fusion(tf1, ema1_tf1, ema2_tf1, ema3_tf1, w1_tf1, w2_tf1, w3_tf1)
fusion2 = f_fusion(tf2, ema1_tf2, ema2_tf2, ema3_tf2, w1_tf2, w2_tf2, w3_tf2)
fusion3 = f_fusion(tf3, ema1_tf3, ema2_tf3, ema3_tf3, w1_tf3, w2_tf3, w3_tf3)
fusion4 = f_fusion(tf4, ema1_tf4, ema2_tf4, ema3_tf4, w1_tf4, w2_tf4, w3_tf4)

// === PLOT DES LIGNES ===
plot(fusion1, color=color.blue, title="Hydra TF1")
plot(fusion2, color=color.green, title="Hydra TF2")
plot(fusion3, color=color.orange, title="Hydra TF3")
plot(fusion4, color=color.red, title="Hydra TF4")

// === TIMER COMPRESSION ===
seuil = input.float(0.05, "Seuil compression (%)") // 0.05 = 0.05% écart
f_distance(a, b) => math.abs(a - b) / ((a + b) / 2) * 100

var float chrono12 = na
var float chrono23 = na
var float chrono34 = na
var int start12 = na
var int start23 = na
var int start34 = na

d12 = f_distance(fusion1, fusion2)
d23 = f_distance(fusion2, fusion3)
d34 = f_distance(fusion3, fusion4)

if d12 < seuil
    if na(start12)
        start12 := time
    chrono12 := (time - start12) / 60000
else
    start12 := na
    chrono12 := na

if d23 < seuil
    if na(start23)
        start23 := time
    chrono23 := (time - start23) / 60000
else
    start23 := na
    chrono23 := na

if d34 < seuil
    if na(start34)
        start34 := time
    chrono34 := (time - start34) / 60000
else
    start34 := na
    chrono34 := na

// === TABLEAU TIMER ===
var table t = table.new(position.top_right, 3, 4)  // 3 colonnes, 4 lignes
if barstate.islast
    table.cell(t, 0, 0, "Pair", text_color=color.white)
    table.cell(t, 1, 0, "Dist (%)", text_color=color.white)
    table.cell(t, 2, 0, "Timer (min)", text_color=color.white)

    table.cell(t, 0, 1, "TF1-TF2")
    table.cell(t, 0, 2, "TF2-TF3")
    table.cell(t, 0, 3, "TF3-TF4")

    table.cell(t, 1, 1, str.tostring(d12, "#.##"))
    table.cell(t, 1, 2, str.tostring(d23, "#.##"))
    table.cell(t, 1, 3, str.tostring(d34, "#.##"))

    table.cell(t, 2, 1, na(chrono12) ? "-" : str.tostring(chrono12, "#.##"))
    table.cell(t, 2, 2, na(chrono23) ? "-" : str.tostring(chrono23, "#.##"))
    table.cell(t, 2, 3, na(chrono34) ? "-" : str.tostring(chrono34, "#.##"))
````
