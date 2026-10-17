# Range 6H J-1 + Fibo Auto v7

- url: https://www.tradingview.com/script/MJBlq6zG/
- type: indicator
- pine_id: PUB;e7100c6fcf8242418be40180d8fd9791
- version: 1.0

## Description

DANVY FIBO 124545451215hgmùklSNBHGEOLKJQbgLKJqzsgBNMJKzqgboFGKS>ZQJHWbvkhpljw<dssnbmjkl<xswdpbvpdswkljhbgpkwjsghbnpi<xwudbnp<sdojnb^poks<xbpijwsnbpij<sxe^nboi<snpbiujESQN)bôk<snbp<skldbnpksqd b<puijsebpiojk<sedvpoijesqbnvoijh>SbuohESQHNbpuioj<snbpoijks>bvohjksqEZNkjb<sijpczqbouhcvbeosiquhgvspIEungbouy<QnbgoiueshnHGOUYEQbngpoIUESQbogu<SQVVUBSQDEOYUVZSEBOIuvespiuvboyuswqBvoiuesqJnvbouyhesbIVYGWbvoUHEDSQbovHUEZS9YUHHCQESBIYUVS

## Source Code

````pine
// ============================================================
// INDICATEUR : Range 6H–6H (J-1) + Fibonacci Automatique v6
// Stratégie  : Fibo tracé sur le High/Low du range 6h–6h
//              de la VEILLE. Ex: le 20 Jan → range du 19 Jan.
// Fuseau     : Sélection par ville (heure d'été/hiver auto)
//              Paris, Londres, New York, Chicago, Los Angeles,
//              Toronto, São Paulo, Dubaï, Mumbai, Singapour,
//              Tokyo, Sydney
// Paires     : XAUUSD, EURUSD, GBPUSD
// Version    : 7.0 – Pine Script v6
//   Nouveautés v4 :
//     - Mode global : Fibonacci OU Pips fixes (SL/TP en pips)
//     - Choix d'affichage des positions par profil
//   Nouveautés v5 :
//     - Labels TP ✅ / SL ❌ sur la bougie de résultat
//   Nouveautés v6 :
//     - Fuseau horaire par ville nommée (DST automatique)
//     - 5 TP + 3 SL par côté (LONG & SHORT) sur les 3 profils
//   Nouveautés v7 :
//     - Nombre de jours de Fibo affichés simultanément (1 à 10)
//     - Longueur des lignes : infinie ou en nombre de barres
//     - Fuseau horaire par ville nommée (DST automatique)
//     - 5 TP + 3 SL par côté (LONG & SHORT) sur les 3 profils
//     - Chaque TP/SL supplémentaire est activable individuellement
// ============================================================

//@version=6
indicator("Range 6H J-1 + Fibo Auto v7", overlay=true, max_lines_count=500, max_labels_count=500, max_boxes_count=20)

// ============================================================
// ── FUSEAU HORAIRE PAR VILLE ─────────────────────────────────
// ============================================================

grp_tz = "🌍 Fuseau horaire (ville)"
tz_city = input.string("Paris", "Ville / Fuseau",
          options=["Paris","Londres","New York","Chicago","Los Angeles",
                   "Toronto","São Paulo","Dubaï","Mumbai",
                   "Singapour","Tokyo","Sydney"],
          group=grp_tz)

// Correspondance ville → chaîne IANA acceptée par Pine Script
// Ces identifiants gèrent automatiquement les changements DST (heure d'été/hiver)
f_tz_string(city) =>
    switch city
        "Paris"       => "Europe/Paris"
        "Londres"     => "Europe/London"
        "New York"    => "America/New_York"
        "Chicago"     => "America/Chicago"
        "Los Angeles" => "America/Los_Angeles"
        "Toronto"     => "America/Toronto"
        "São Paulo"   => "America/Sao_Paulo"
        "Dubaï"       => "Asia/Dubai"
        "Mumbai"      => "Asia/Kolkata"
        "Singapour"   => "Asia/Singapore"
        "Tokyo"       => "Asia/Tokyo"
        "Sydney"      => "Australia/Sydney"
        =>               "Europe/Paris"

// ============================================================
// ── MODE GLOBAL : FIBO vs PIPS FIXES ─────────────────────────
// ============================================================

grp_mode = "⚙️ Mode d'entrée (global)"
entry_mode  = input.string("Fibonacci", "Mode d'entrée", options=["Fibonacci", "Pips fixes"], group=grp_mode)

// Pips fixes – SL (3 niveaux)
pip_sl1        = input.float(15.0, "SL1 en pips",          minval=0.1, step=0.5, group=grp_mode)
pip_sl2_en     = input.bool(false, "Activer SL2",                                group=grp_mode)
pip_sl2        = input.float(20.0, "SL2 en pips",          minval=0.1, step=0.5, group=grp_mode)
pip_sl3_en     = input.bool(false, "Activer SL3",                                group=grp_mode)
pip_sl3        = input.float(25.0, "SL3 en pips",          minval=0.1, step=0.5, group=grp_mode)

// Pips fixes – TP (5 niveaux)
pip_tp1        = input.float(30.0, "TP1 en pips",          minval=0.1, step=0.5, group=grp_mode)
pip_tp2_en     = input.bool(false, "Activer TP2",                                group=grp_mode)
pip_tp2        = input.float(50.0, "TP2 en pips",          minval=0.1, step=0.5, group=grp_mode)
pip_tp3_en     = input.bool(false, "Activer TP3",                                group=grp_mode)
pip_tp3        = input.float(80.0, "TP3 en pips",          minval=0.1, step=0.5, group=grp_mode)
pip_tp4_en     = input.bool(false, "Activer TP4",                                group=grp_mode)
pip_tp4        = input.float(110.0,"TP4 en pips",          minval=0.1, step=0.5, group=grp_mode)
pip_tp5_en     = input.bool(false, "Activer TP5",                                group=grp_mode)
pip_tp5        = input.float(150.0,"TP5 en pips",          minval=0.1, step=0.5, group=grp_mode)

// ============================================================
// ── PROFILS ──────────────────────────────────────────────────
// ============================================================

grp_profile = "🔀 Profil actif"
active_profile = input.string("Manuel", "Profil actif", options=["Manuel", "Custom 1", "Custom 2"], group=grp_profile)

// ─────────────────────────────────────────────────────────────
// ── Profil Manuel ────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────
grp_fibo = "📐 [Manuel] Niveaux Fibonacci"
m_show_fibo   = input.bool(true,         "Afficher le Fibonacci",                                           group=grp_fibo)
m_positions   = input.string("Les deux", "Positions à afficher", options=["Les deux","LONG seulement","SHORT seulement"], group=grp_fibo)

// Manuel – LONG : 5 TP
m_tp1_high    = input.float( 1.04,  "TP1 côté HIGH", step=0.001, group=grp_fibo)
m_tp2_h_en    = input.bool(false,   "Activer TP2 côté HIGH",     group=grp_fibo)
m_tp2_high    = input.float( 1.08,  "TP2 côté HIGH", step=0.001, group=grp_fibo)
m_tp3_h_en    = input.bool(false,   "Activer TP3 côté HIGH",     group=grp_fibo)
m_tp3_high    = input.float( 1.14,  "TP3 côté HIGH", step=0.001, group=grp_fibo)
m_tp4_h_en    = input.bool(false,   "Activer TP4 côté HIGH",     group=grp_fibo)
m_tp4_high    = input.float( 1.20,  "TP4 côté HIGH", step=0.001, group=grp_fibo)
m_tp5_h_en    = input.bool(false,   "Activer TP5 côté HIGH",     group=grp_fibo)
m_tp5_high    = input.float( 1.27,  "TP5 côté HIGH", step=0.001, group=grp_fibo)
// Manuel – LONG : 3 SL
m_sl1_high    = input.float( 0.99,  "SL1 côté HIGH", step=0.001, group=grp_fibo)
m_sl2_h_en    = input.bool(false,   "Activer SL2 côté HIGH",     group=grp_fibo)
m_sl2_high    = input.float( 0.985, "SL2 côté HIGH", step=0.001, group=grp_fibo)
m_sl3_h_en    = input.bool(false,   "Activer SL3 côté HIGH",     group=grp_fibo)
m_sl3_high    = input.float( 0.978, "SL3 côté HIGH", step=0.001, group=grp_fibo)
// Manuel – Entrée HIGH
m_entry_high  = input.float( 1.0,   "Entrée HIGH",   step=0.001, group=grp_fibo)
// Manuel – Niveaux intermédiaires
m_mid3        = input.float( 0.618, "Niveau 0.618",  step=0.001, group=grp_fibo)
m_mid1        = input.float( 0.5,   "Niveau 0.5",    step=0.001, group=grp_fibo)
m_mid2        = input.float( 0.382, "Niveau 0.382",  step=0.001, group=grp_fibo)
// Manuel – Entrée LOW
m_entry_low   = input.float( 0.0,   "Entrée LOW",    step=0.001, group=grp_fibo)
// Manuel – SHORT : 3 SL
m_sl1_low     = input.float( 0.01,  "SL1 côté LOW",  step=0.001, group=grp_fibo)
m_sl2_l_en    = input.bool(false,   "Activer SL2 côté LOW",      group=grp_fibo)
m_sl2_low     = input.float( 0.015, "SL2 côté LOW",  step=0.001, group=grp_fibo)
m_sl3_l_en    = input.bool(false,   "Activer SL3 côté LOW",      group=grp_fibo)
m_sl3_low     = input.float( 0.022, "SL3 côté LOW",  step=0.001, group=grp_fibo)
// Manuel – SHORT : 5 TP
m_tp1_low     = input.float(-0.04,  "TP1 côté LOW",  step=0.001, group=grp_fibo)
m_tp2_l_en    = input.bool(false,   "Activer TP2 côté LOW",      group=grp_fibo)
m_tp2_low     = input.float(-0.08,  "TP2 côté LOW",  step=0.001, group=grp_fibo)
m_tp3_l_en    = input.bool(false,   "Activer TP3 côté LOW",      group=grp_fibo)
m_tp3_low     = input.float(-0.14,  "TP3 côté LOW",  step=0.001, group=grp_fibo)
m_tp4_l_en    = input.bool(false,   "Activer TP4 côté LOW",      group=grp_fibo)
m_tp4_low     = input.float(-0.20,  "TP4 côté LOW",  step=0.001, group=grp_fibo)
m_tp5_l_en    = input.bool(false,   "Activer TP5 côté LOW",      group=grp_fibo)
m_tp5_low     = input.float(-0.27,  "TP5 côté LOW",  step=0.001, group=grp_fibo)
m_show_mid    = input.bool(true,    "Niveaux intermédiaires",     group=grp_fibo)
m_line_width  = input.int(1,        "Épaisseur lignes", minval=1, maxval=4, group=grp_fibo)

// ─────────────────────────────────────────────────────────────
// ── Profil Custom 1 ──────────────────────────────────────────
// ─────────────────────────────────────────────────────────────
grp_c1 = "🟡 [Custom 1] Niveaux Fibonacci"
c1_name       = input.string("Custom 1", "Nom du profil",                                                   group=grp_c1)
c1_show_fibo  = input.bool(true,         "Afficher le Fibonacci",                                           group=grp_c1)
c1_positions  = input.string("Les deux", "Positions à afficher", options=["Les deux","LONG seulement","SHORT seulement"], group=grp_c1)

c1_tp1_high   = input.float( 1.06,  "TP1 côté HIGH", step=0.001, group=grp_c1)
c1_tp2_h_en   = input.bool(false,   "Activer TP2 côté HIGH",     group=grp_c1)
c1_tp2_high   = input.float( 1.10,  "TP2 côté HIGH", step=0.001, group=grp_c1)
c1_tp3_h_en   = input.bool(false,   "Activer TP3 côté HIGH",     group=grp_c1)
c1_tp3_high   = input.float( 1.15,  "TP3 côté HIGH", step=0.001, group=grp_c1)
c1_tp4_h_en   = input.bool(false,   "Activer TP4 côté HIGH",     group=grp_c1)
c1_tp4_high   = input.float( 1.21,  "TP4 côté HIGH", step=0.001, group=grp_c1)
c1_tp5_h_en   = input.bool(false,   "Activer TP5 côté HIGH",     group=grp_c1)
c1_tp5_high   = input.float( 1.28,  "TP5 côté HIGH", step=0.001, group=grp_c1)
c1_sl1_high   = input.float( 0.995, "SL1 côté HIGH", step=0.001, group=grp_c1)
c1_sl2_h_en   = input.bool(false,   "Activer SL2 côté HIGH",     group=grp_c1)
c1_sl2_high   = input.float( 0.990, "SL2 côté HIGH", step=0.001, group=grp_c1)
c1_sl3_h_en   = input.bool(false,   "Activer SL3 côté HIGH",     group=grp_c1)
c1_sl3_high   = input.float( 0.983, "SL3 côté HIGH", step=0.001, group=grp_c1)
c1_entry_high = input.float( 1.0,   "Entrée HIGH",   step=0.001, group=grp_c1)
c1_mid3       = input.float( 0.618, "Niveau 0.618",  step=0.001, group=grp_c1)
c1_mid1       = input.float( 0.5,   "Niveau 0.5",    step=0.001, group=grp_c1)
c1_mid2       = input.float( 0.382, "Niveau 0.382",  step=0.001, group=grp_c1)
c1_entry_low  = input.float( 0.0,   "Entrée LOW",    step=0.001, group=grp_c1)
c1_sl1_low    = input.float( 0.005, "SL1 côté LOW",  step=0.001, group=grp_c1)
c1_sl2_l_en   = input.bool(false,   "Activer SL2 côté LOW",      group=grp_c1)
c1_sl2_low    = input.float( 0.010, "SL2 côté LOW",  step=0.001, group=grp_c1)
c1_sl3_l_en   = input.bool(false,   "Activer SL3 côté LOW",      group=grp_c1)
c1_sl3_low    = input.float( 0.017, "SL3 côté LOW",  step=0.001, group=grp_c1)
c1_tp1_low    = input.float(-0.06,  "TP1 côté LOW",  step=0.001, group=grp_c1)
c1_tp2_l_en   = input.bool(false,   "Activer TP2 côté LOW",      group=grp_c1)
c1_tp2_low    = input.float(-0.10,  "TP2 côté LOW",  step=0.001, group=grp_c1)
c1_tp3_l_en   = input.bool(false,   "Activer TP3 côté LOW",      group=grp_c1)
c1_tp3_low    = input.float(-0.15,  "TP3 côté LOW",  step=0.001, group=grp_c1)
c1_tp4_l_en   = input.bool(false,   "Activer TP4 côté LOW",      group=grp_c1)
c1_tp4_low    = input.float(-0.21,  "TP4 côté LOW",  step=0.001, group=grp_c1)
c1_tp5_l_en   = input.bool(false,   "Activer TP5 côté LOW",      group=grp_c1)
c1_tp5_low    = input.float(-0.28,  "TP5 côté LOW",  step=0.001, group=grp_c1)
c1_show_mid   = input.bool(true,    "Niveaux intermédiaires",     group=grp_c1)
c1_line_width = input.int(1,        "Épaisseur lignes", minval=1, maxval=4, group=grp_c1)

// ─────────────────────────────────────────────────────────────
// ── Profil Custom 2 ──────────────────────────────────────────
// ─────────────────────────────────────────────────────────────
grp_c2 = "🟠 [Custom 2] Niveaux Fibonacci"
c2_name       = input.string("Custom 2", "Nom du profil",                                                   group=grp_c2)
c2_show_fibo  = input.bool(true,         "Afficher le Fibonacci",                                           group=grp_c2)
c2_positions  = input.string("Les deux", "Positions à afficher", options=["Les deux","LONG seulement","SHORT seulement"], group=grp_c2)

c2_tp1_high   = input.float( 1.02,  "TP1 côté HIGH", step=0.001, group=grp_c2)
c2_tp2_h_en   = input.bool(false,   "Activer TP2 côté HIGH",     group=grp_c2)
c2_tp2_high   = input.float( 1.04,  "TP2 côté HIGH", step=0.001, group=grp_c2)
c2_tp3_h_en   = input.bool(false,   "Activer TP3 côté HIGH",     group=grp_c2)
c2_tp3_high   = input.float( 1.06,  "TP3 côté HIGH", step=0.001, group=grp_c2)
c2_tp4_h_en   = input.bool(false,   "Activer TP4 côté HIGH",     group=grp_c2)
c2_tp4_high   = input.float( 1.09,  "TP4 côté HIGH", step=0.001, group=grp_c2)
c2_tp5_h_en   = input.bool(false,   "Activer TP5 côté HIGH",     group=grp_c2)
c2_tp5_high   = input.float( 1.12,  "TP5 côté HIGH", step=0.001, group=grp_c2)
c2_sl1_high   = input.float( 0.998, "SL1 côté HIGH", step=0.001, group=grp_c2)
c2_sl2_h_en   = input.bool(false,   "Activer SL2 côté HIGH",     group=grp_c2)
c2_sl2_high   = input.float( 0.995, "SL2 côté HIGH", step=0.001, group=grp_c2)
c2_sl3_h_en   = input.bool(false,   "Activer SL3 côté HIGH",     group=grp_c2)
c2_sl3_high   = input.float( 0.991, "SL3 côté HIGH", step=0.001, group=grp_c2)
c2_entry_high = input.float( 1.0,   "Entrée HIGH",   step=0.001, group=grp_c2)
c2_mid3       = input.float( 0.618, "Niveau 0.618",  step=0.001, group=grp_c2)
c2_mid1       = input.float( 0.5,   "Niveau 0.5",    step=0.001, group=grp_c2)
c2_mid2       = input.float( 0.382, "Niveau 0.382",  step=0.001, group=grp_c2)
c2_entry_low  = input.float( 0.0,   "Entrée LOW",    step=0.001, group=grp_c2)
c2_sl1_low    = input.float( 0.002, "SL1 côté LOW",  step=0.001, group=grp_c2)
c2_sl2_l_en   = input.bool(false,   "Activer SL2 côté LOW",      group=grp_c2)
c2_sl2_low    = input.float( 0.005, "SL2 côté LOW",  step=0.001, group=grp_c2)
c2_sl3_l_en   = input.bool(false,   "Activer SL3 côté LOW",      group=grp_c2)
c2_sl3_low    = input.float( 0.009, "SL3 côté LOW",  step=0.001, group=grp_c2)
c2_tp1_low    = input.float(-0.02,  "TP1 côté LOW",  step=0.001, group=grp_c2)
c2_tp2_l_en   = input.bool(false,   "Activer TP2 côté LOW",      group=grp_c2)
c2_tp2_low    = input.float(-0.04,  "TP2 côté LOW",  step=0.001, group=grp_c2)
c2_tp3_l_en   = input.bool(false,   "Activer TP3 côté LOW",      group=grp_c2)
c2_tp3_low    = input.float(-0.06,  "TP3 côté LOW",  step=0.001, group=grp_c2)
c2_tp4_l_en   = input.bool(false,   "Activer TP4 côté LOW",      group=grp_c2)
c2_tp4_low    = input.float(-0.09,  "TP4 côté LOW",  step=0.001, group=grp_c2)
c2_tp5_l_en   = input.bool(false,   "Activer TP5 côté LOW",      group=grp_c2)
c2_tp5_low    = input.float(-0.12,  "TP5 côté LOW",  step=0.001, group=grp_c2)
c2_show_mid   = input.bool(false,   "Niveaux intermédiaires",     group=grp_c2)
c2_line_width = input.int(1,        "Épaisseur lignes", minval=1, maxval=4, group=grp_c2)

// ============================================================
// ── SÉLECTION DU PROFIL ACTIF ────────────────────────────────
// ============================================================

is_c1 = active_profile == "Custom 1"
is_c2 = active_profile == "Custom 2"

profile_name    = is_c1 ? c1_name       : is_c2 ? c2_name       : "Manuel"
fibo_tp1_high   = is_c1 ? c1_tp1_high   : is_c2 ? c2_tp1_high   : m_tp1_high
fibo_tp2_h_en   = is_c1 ? c1_tp2_h_en   : is_c2 ? c2_tp2_h_en   : m_tp2_h_en
fibo_tp2_high   = is_c1 ? c1_tp2_high   : is_c2 ? c2_tp2_high   : m_tp2_high
fibo_tp3_h_en   = is_c1 ? c1_tp3_h_en   : is_c2 ? c2_tp3_h_en   : m_tp3_h_en
fibo_tp3_high   = is_c1 ? c1_tp3_high   : is_c2 ? c2_tp3_high   : m_tp3_high
fibo_tp4_h_en   = is_c1 ? c1_tp4_h_en   : is_c2 ? c2_tp4_h_en   : m_tp4_h_en
fibo_tp4_high   = is_c1 ? c1_tp4_high   : is_c2 ? c2_tp4_high   : m_tp4_high
fibo_tp5_h_en   = is_c1 ? c1_tp5_h_en   : is_c2 ? c2_tp5_h_en   : m_tp5_h_en
fibo_tp5_high   = is_c1 ? c1_tp5_high   : is_c2 ? c2_tp5_high   : m_tp5_high
fibo_sl1_high   = is_c1 ? c1_sl1_high   : is_c2 ? c2_sl1_high   : m_sl1_high
fibo_sl2_h_en   = is_c1 ? c1_sl2_h_en   : is_c2 ? c2_sl2_h_en   : m_sl2_h_en
fibo_sl2_high   = is_c1 ? c1_sl2_high   : is_c2 ? c2_sl2_high   : m_sl2_high
fibo_sl3_h_en   = is_c1 ? c1_sl3_h_en   : is_c2 ? c2_sl3_h_en   : m_sl3_h_en
fibo_sl3_high   = is_c1 ? c1_sl3_high   : is_c2 ? c2_sl3_high   : m_sl3_high
fibo_entry_high = is_c1 ? c1_entry_high  : is_c2 ? c2_entry_high  : m_entry_high
fibo_mid3       = is_c1 ? c1_mid3        : is_c2 ? c2_mid3        : m_mid3
fibo_mid1       = is_c1 ? c1_mid1        : is_c2 ? c2_mid1        : m_mid1
fibo_mid2       = is_c1 ? c1_mid2        : is_c2 ? c2_mid2        : m_mid2
fibo_entry_low  = is_c1 ? c1_entry_low   : is_c2 ? c2_entry_low   : m_entry_low
fibo_sl1_low    = is_c1 ? c1_sl1_low     : is_c2 ? c2_sl1_low     : m_sl1_low
fibo_sl2_l_en   = is_c1 ? c1_sl2_l_en   : is_c2 ? c2_sl2_l_en   : m_sl2_l_en
fibo_sl2_low    = is_c1 ? c1_sl2_low     : is_c2 ? c2_sl2_low     : m_sl2_low
fibo_sl3_l_en   = is_c1 ? c1_sl3_l_en   : is_c2 ? c2_sl3_l_en   : m_sl3_l_en
fibo_sl3_low    = is_c1 ? c1_sl3_low     : is_c2 ? c2_sl3_low     : m_sl3_low
fibo_tp1_low    = is_c1 ? c1_tp1_low     : is_c2 ? c2_tp1_low     : m_tp1_low
fibo_tp2_l_en   = is_c1 ? c1_tp2_l_en   : is_c2 ? c2_tp2_l_en   : m_tp2_l_en
fibo_tp2_low    = is_c1 ? c1_tp2_low     : is_c2 ? c2_tp2_low     : m_tp2_low
fibo_tp3_l_en   = is_c1 ? c1_tp3_l_en   : is_c2 ? c2_tp3_l_en   : m_tp3_l_en
fibo_tp3_low    = is_c1 ? c1_tp3_low     : is_c2 ? c2_tp3_low     : m_tp3_low
fibo_tp4_l_en   = is_c1 ? c1_tp4_l_en   : is_c2 ? c2_tp4_l_en   : m_tp4_l_en
fibo_tp4_low    = is_c1 ? c1_tp4_low     : is_c2 ? c2_tp4_low     : m_tp4_low
fibo_tp5_l_en   = is_c1 ? c1_tp5_l_en   : is_c2 ? c2_tp5_l_en   : m_tp5_l_en
fibo_tp5_low    = is_c1 ? c1_tp5_low     : is_c2 ? c2_tp5_low     : m_tp5_low
show_fibo       = is_c1 ? c1_show_fibo   : is_c2 ? c2_show_fibo   : m_show_fibo
show_mid        = is_c1 ? c1_show_mid    : is_c2 ? c2_show_mid    : m_show_mid
line_width_fibo = is_c1 ? c1_line_width  : is_c2 ? c2_line_width  : m_line_width
active_positions= is_c1 ? c1_positions   : is_c2 ? c2_positions   : m_positions

show_long  = active_positions == "Les deux" or active_positions == "LONG seulement"
show_short = active_positions == "Les deux" or active_positions == "SHORT seulement"

is_pips_mode = entry_mode == "Pips fixes"
pip_value    = syminfo.mintick * 10

// ============================================================
// ── PARAMÈTRES COMMUNS ───────────────────────────────────────
// ============================================================

grp_colors = "🎨 Couleurs (communes aux 3 profils)"
col_tp1    = input.color(color.new(#00BFA5, 0),  "Couleur TP1",                     group=grp_colors)
col_tp2    = input.color(color.new(#00E5FF, 0),  "Couleur TP2",                     group=grp_colors)
col_tp3    = input.color(color.new(#80DEEA, 0),  "Couleur TP3",                     group=grp_colors)
col_tp4    = input.color(color.new(#B2EBF2, 0),  "Couleur TP4",                     group=grp_colors)
col_tp5    = input.color(color.new(#E0F7FA, 0),  "Couleur TP5",                     group=grp_colors)
col_entry  = input.color(color.new(#2962FF, 0),  "Couleur Entrée",                  group=grp_colors)
col_sl1    = input.color(color.new(#FF6D00, 0),  "Couleur SL1",                     group=grp_colors)
col_sl2    = input.color(color.new(#FF9100, 0),  "Couleur SL2",                     group=grp_colors)
col_sl3    = input.color(color.new(#FFCA28, 0),  "Couleur SL3",                     group=grp_colors)
col_mid    = input.color(color.new(#B0BEC5, 0),  "Couleur niveaux intermédiaires",  group=grp_colors)

grp_time = "⏰ Horaires"
session_start  = input.int(6,  "Heure début/fin du range", minval=0, maxval=23, group=grp_time)
no_trade_start = input.int(20, "Début zone rouge  (20h00)", minval=0, maxval=23, group=grp_time)
no_trade_end   = input.int(6,  "Fin zone rouge    (06h00)", minval=0, maxval=23, group=grp_time)

grp_hl = "📊 Lignes High / Low du range J-1"
show_high_low = input.bool(true, "Afficher High & Low", group=grp_hl)
col_high      = input.color(color.new(#00C853, 0), "Couleur High", group=grp_hl)
col_low       = input.color(color.new(#D50000, 0), "Couleur Low",  group=grp_hl)
line_width_hl = input.int(2, "Épaisseur", minval=1, maxval=4, group=grp_hl)

grp_zone = "🔴 Zone sans trade (20h–06h)"
show_zone = input.bool(true, "Afficher la zone rouge", group=grp_zone)
col_zone  = input.color(color.new(#FF1744, 88), "Couleur zone rouge", group=grp_zone)

grp_lbl = "🏷️ Labels"
show_labels = input.bool(true,   "Afficher les labels",                                  group=grp_lbl)
label_size  = input.string("Petit", "Taille labels", options=["Petit","Moyen","Grand"],  group=grp_lbl)

grp_boxes = "📦 Zones TP/SL style TradingView"
show_boxes     = input.bool(true, "Afficher les zones TP1/SL1",  group=grp_boxes)
col_box_tp     = input.color(color.new(#00BCD4, 75), "Couleur zone TP  (cyan)", group=grp_boxes)
col_box_sl     = input.color(color.new(#9E9E9E, 75), "Couleur zone SL  (gris)", group=grp_boxes)
col_box_border = input.color(color.new(#FFFFFF,  0), "Bordure des zones",        group=grp_boxes)

grp_lines = "📏 Longueur & historique des lignes"
nb_days       = input.int(1,   "Nombre de jours affichés (1 = J-1 seulement)", minval=1, maxval=10, step=1, group=grp_lines)
line_extend   = input.string("Infinie →", "Extension des lignes à droite",
                  options=["Infinie →", "Longueur fixe"], group=grp_lines)
line_len_bars = input.int(50, "Longueur en barres (si Longueur fixe)", minval=1, maxval=500, step=5, group=grp_lines)

grp_hist = "🗂️ Style des Fibo historiques (J-2, J-3...)"
hist_show_hl      = input.bool(true,      "Afficher High/Low historiques",                          group=grp_hist)
hist_show_fibo    = input.bool(true,      "Afficher Fibo historiques",                              group=grp_hist)
hist_show_labels  = input.bool(true,      "Afficher labels historiques",                            group=grp_hist)
hist_line_width   = input.int(1,          "Épaisseur lignes historiques", minval=1, maxval=4,       group=grp_hist)
hist_line_style   = input.string("Pointillés", "Style des lignes historiques",
                      options=["Solide","Pointillés","Tirets"],                                      group=grp_hist)
hist_opacity_base = input.int(50,         "Transparence de base (J-2)  0=opaque 90=très transparent",
                      minval=0, maxval=90, step=5,                                                   group=grp_hist)
hist_opacity_step = input.int(15,         "Incrément transparence par jour supplémentaire",
                      minval=0, maxval=30, step=5,                                                   group=grp_hist)
hist_use_own_cols = input.bool(false,     "Utiliser des couleurs dédiées (sinon : hérite de J-1)", group=grp_hist)
hist_col_tp1      = input.color(color.new(#00BFA5, 0), "Couleur TP1 historique",                   group=grp_hist)
hist_col_tp2      = input.color(color.new(#00E5FF, 0), "Couleur TP2 historique",                   group=grp_hist)
hist_col_tp3      = input.color(color.new(#80DEEA, 0), "Couleur TP3 historique",                   group=grp_hist)
hist_col_tp4      = input.color(color.new(#B2EBF2, 0), "Couleur TP4 historique",                   group=grp_hist)
hist_col_tp5      = input.color(color.new(#E0F7FA, 0), "Couleur TP5 historique",                   group=grp_hist)
hist_col_entry    = input.color(color.new(#2962FF, 0), "Couleur Entrée historique",                group=grp_hist)
hist_col_sl1      = input.color(color.new(#FF6D00, 0), "Couleur SL1 historique",                   group=grp_hist)
hist_col_sl2      = input.color(color.new(#FF9100, 0), "Couleur SL2 historique",                   group=grp_hist)
hist_col_sl3      = input.color(color.new(#FFCA28, 0), "Couleur SL3 historique",                   group=grp_hist)
hist_col_high     = input.color(color.new(#00C853, 0), "Couleur High historique",                  group=grp_hist)
hist_col_low      = input.color(color.new(#D50000, 0), "Couleur Low historique",                   group=grp_hist)

grp_dash = "📋 Tableau de bord"
dash_text_size  = input.string("Petit", "Taille du texte", options=["Micro","Petit","Moyen","Grand"], group=grp_dash)
show_dash_rng   = input.bool(true, "Afficher High/Low/Amplitude", group=grp_dash)
show_dash_long  = input.bool(true, "Afficher section LONG",       group=grp_dash)
show_dash_short = input.bool(true, "Afficher section SHORT",      group=grp_dash)
show_dash_rr    = input.bool(true, "Afficher Ratio R/R (TP1)",    group=grp_dash)

grp_alert = "🔔 Alertes"
alert_buy  = input.bool(true, "Alerte BUY  (prix touche HIGH)", group=grp_alert)
alert_sell = input.bool(true, "Alerte SELL (prix touche LOW)",  group=grp_alert)

grp_result = "🏁 Labels résultat TP/SL sur bougie"
show_result_labels = input.bool(true,    "Afficher les labels TP ✅ / SL ❌",    group=grp_result)
result_label_size  = input.string("Moyen", "Taille", options=["Petit","Moyen","Grand"], group=grp_result)

// ============================================================
// ── UTILITAIRES ──────────────────────────────────────────────
// ============================================================

f_label_size(s) =>
    s == "Grand" ? size.normal : s == "Moyen" ? size.small : size.tiny

f_dash_size(s) =>
    s == "Grand" ? size.normal : s == "Moyen" ? size.small : s == "Petit" ? size.tiny : size.auto

f_price(hi, lo, lvl) =>
    lo + (hi - lo) * lvl

f_pct(entry, target) =>
    math.round((target - entry) / entry * 100, 2)

// ============================================================
// ── HEURE LOCALE (ville, DST automatique) ────────────────────
// ============================================================

_tz          = f_tz_string(tz_city)
local_hour   = hour(time,   _tz)
local_minute = minute(time, _tz)
is_6h_open   = (local_hour == session_start and local_minute == 0)

// ============================================================
// ── LOGIQUE : RANGE J-1 (multi-jours) ───────────────────────
// On conserve un historique de `nb_days` ranges pour le dessin.
// locked_high / locked_low = le range J-1 le plus récent
//   (utilisé pour alertes, labels résultat, dashboard).
// Les tableaux hist_* stockent les N derniers ranges.
// ============================================================

var float acc_high         = na
var float acc_low          = na
var float locked_high      = na
var float locked_low       = na
var int   locked_bar_start = na

var int   long_state  = 0
var int   short_state = 0

// Historique multi-jours (max 10 slots)
var float[] hist_high  = array.new_float(0)
var float[] hist_low   = array.new_float(0)
var int[]   hist_start = array.new_int(0)

if is_6h_open
    if not na(acc_high)
        locked_high      := acc_high
        locked_low       := acc_low
        locked_bar_start := bar_index
        long_state  := 0
        short_state := 0
        // Ajouter au début de l'historique
        array.unshift(hist_high,  acc_high)
        array.unshift(hist_low,   acc_low)
        array.unshift(hist_start, bar_index)
        // Garder seulement nb_days slots
        while array.size(hist_high) > nb_days
            array.pop(hist_high)
            array.pop(hist_low)
            array.pop(hist_start)
    acc_high := high
    acc_low  := low

if not is_6h_open
    acc_high := na(acc_high) ? high : math.max(acc_high, high)
    acc_low  := na(acc_low)  ? low  : math.min(acc_low,  low)

// Longueur de ligne : infinie ou fixe
_ln_extend = line_extend == "Infinie →" ? extend.right : extend.none
_ln_x2_offset(x1) => line_extend == "Infinie →" ? bar_index : x1 + line_len_bars

// ============================================================
// ── CALCUL DES NIVEAUX ───────────────────────────────────────
// Retourne [tp1h,tp2h,tp3h,tp4h,tp5h, sl1h,sl2h,sl3h, enth,
//           entl, sl1l,sl2l,sl3l, tp1l,tp2l,tp3l,tp4l,tp5l]
// ============================================================

f_levels(hi, lo) =>
    float tp1h = na, float tp2h = na, float tp3h = na
    float tp4h = na, float tp5h = na
    float sl1h = na, float sl2h = na, float sl3h = na
    float enth = na
    float entl = na
    float sl1l = na, float sl2l = na, float sl3l = na
    float tp1l = na, float tp2l = na, float tp3l = na
    float tp4l = na, float tp5l = na

    if is_pips_mode
        enth  := hi
        tp1h  := hi + pip_tp1 * pip_value
        tp2h  := hi + pip_tp2 * pip_value
        tp3h  := hi + pip_tp3 * pip_value
        tp4h  := hi + pip_tp4 * pip_value
        tp5h  := hi + pip_tp5 * pip_value
        sl1h  := hi - pip_sl1 * pip_value
        sl2h  := hi - pip_sl2 * pip_value
        sl3h  := hi - pip_sl3 * pip_value
        entl  := lo
        tp1l  := lo - pip_tp1 * pip_value
        tp2l  := lo - pip_tp2 * pip_value
        tp3l  := lo - pip_tp3 * pip_value
        tp4l  := lo - pip_tp4 * pip_value
        tp5l  := lo - pip_tp5 * pip_value
        sl1l  := lo + pip_sl1 * pip_value
        sl2l  := lo + pip_sl2 * pip_value
        sl3l  := lo + pip_sl3 * pip_value
    else
        tp1h  := f_price(hi, lo, fibo_tp1_high)
        tp2h  := f_price(hi, lo, fibo_tp2_high)
        tp3h  := f_price(hi, lo, fibo_tp3_high)
        tp4h  := f_price(hi, lo, fibo_tp4_high)
        tp5h  := f_price(hi, lo, fibo_tp5_high)
        sl1h  := f_price(hi, lo, fibo_sl1_high)
        sl2h  := f_price(hi, lo, fibo_sl2_high)
        sl3h  := f_price(hi, lo, fibo_sl3_high)
        enth  := f_price(hi, lo, fibo_entry_high)
        entl  := f_price(hi, lo, fibo_entry_low)
        sl1l  := f_price(hi, lo, fibo_sl1_low)
        sl2l  := f_price(hi, lo, fibo_sl2_low)
        sl3l  := f_price(hi, lo, fibo_sl3_low)
        tp1l  := f_price(hi, lo, fibo_tp1_low)
        tp2l  := f_price(hi, lo, fibo_tp2_low)
        tp3l  := f_price(hi, lo, fibo_tp3_low)
        tp4l  := f_price(hi, lo, fibo_tp4_low)
        tp5l  := f_price(hi, lo, fibo_tp5_low)

    [tp1h,tp2h,tp3h,tp4h,tp5h, sl1h,sl2h,sl3h, enth,
     entl, sl1l,sl2l,sl3l, tp1l,tp2l,tp3l,tp4l,tp5l]

// ============================================================
// ── ZONE ROUGE ───────────────────────────────────────────────
// ============================================================

is_no_trade = (local_hour >= no_trade_start) or (local_hour < no_trade_end)
bgcolor(show_zone and is_no_trade ? col_zone : na, title="Zone sans trade")

// ============================================================
// ── ALERTES ──────────────────────────────────────────────────
// ============================================================

// ta.crossover/crossunder doivent être évalués hors condition pour Pine v6
_cross_buy  = not na(locked_high) and not na(locked_low) ? ta.crossover( high, locked_high) : false
_cross_sell = not na(locked_high) and not na(locked_low) ? ta.crossunder(low,  locked_low)  : false

if not na(locked_high) and not na(locked_low)
    [a_tp1h,_,_,_,_, _,_,_, a_enth,
     a_entl, _,_,_, a_tp1l,_,_,_,_] = f_levels(locked_high, locked_low)
    if alert_buy  and show_long  and _cross_buy
        alert("🟢 BUY ["  + profile_name + "] – Prix touche HIGH : " + str.tostring(a_enth, format.mintick), alert.freq_once_per_bar)
    if alert_sell and show_short and _cross_sell
        alert("🔴 SELL [" + profile_name + "] – Prix touche LOW : "  + str.tostring(a_entl, format.mintick), alert.freq_once_per_bar)

// ============================================================
// ── SUIVI DES TRADES + LABELS TP ✅ / SL ❌ ──────────────────
// ============================================================

f_result_lbl_size(s) =>
    s == "Grand" ? size.normal : s == "Moyen" ? size.small : size.tiny

if not na(locked_high) and not na(locked_low) and show_result_labels
    [r_tp1h,r_tp2h,r_tp3h,r_tp4h,r_tp5h,
     r_sl1h,_,_, r_enth,
     r_entl, r_sl1l,_,_,
     r_tp1l,r_tp2l,r_tp3l,r_tp4l,r_tp5l] = f_levels(locked_high, locked_low)
    _rsz = f_result_lbl_size(result_label_size)

    // TP cible = TP le plus éloigné activé (LONG)
    bool _a5h = is_pips_mode ? pip_tp5_en : fibo_tp5_h_en
    bool _a4h = is_pips_mode ? pip_tp4_en : fibo_tp4_h_en
    bool _a3h = is_pips_mode ? pip_tp3_en : fibo_tp3_h_en
    bool _a2h = is_pips_mode ? pip_tp2_en : fibo_tp2_h_en
    float tp_h_target = _a5h ? r_tp5h : _a4h ? r_tp4h : _a3h ? r_tp3h : _a2h ? r_tp2h : r_tp1h
    // TP cible = TP le plus éloigné activé (SHORT)
    bool _a5l = is_pips_mode ? pip_tp5_en : fibo_tp5_l_en
    bool _a4l = is_pips_mode ? pip_tp4_en : fibo_tp4_l_en
    bool _a3l = is_pips_mode ? pip_tp3_en : fibo_tp3_l_en
    bool _a2l = is_pips_mode ? pip_tp2_en : fibo_tp2_l_en
    float tp_l_target = _a5l ? r_tp5l : _a4l ? r_tp4l : _a3l ? r_tp3l : _a2l ? r_tp2l : r_tp1l

    if show_long
        if long_state == 0 and high >= r_enth
            long_state := 1
        if long_state == 1
            if high >= tp_h_target
                long_state := 2
                label.new(bar_index, high, "TP ✅",
                          color=color.new(#00C853,20), textcolor=#FFFFFF,
                          style=label.style_label_down, size=_rsz)
            else if low <= r_sl1h
                long_state := 2
                label.new(bar_index, low, "SL ❌",
                          color=color.new(#D50000,20), textcolor=#FFFFFF,
                          style=label.style_label_up, size=_rsz)

    if show_short
        if short_state == 0 and low <= r_entl
            short_state := 1
        if short_state == 1
            if low <= tp_l_target
                short_state := 2
                label.new(bar_index, low, "TP ✅",
                          color=color.new(#00C853,20), textcolor=#FFFFFF,
                          style=label.style_label_up, size=_rsz)
            else if high >= r_sl1l
                short_state := 2
                label.new(bar_index, high, "SL ❌",
                          color=color.new(#D50000,20), textcolor=#FFFFFF,
                          style=label.style_label_down, size=_rsz)

// ============================================================
// ── FONCTION HELPER DESSIN HISTORIQUE ────────────────────────
// Crée une ligne historique et la stocke dans hist_lines.
// Doit être définie au niveau global (Pine v6 interdit les
// fonctions locales dans des blocs if/for).
// ============================================================

f_hist_ln(target_arr, _x1, _x2, _y, _col, _alpha, _is_dash, _ext, _lw2) =>
    array.push(target_arr,
        line.new(x1=_x1, y1=_y, x2=_x2, y2=_y,
                 color=color.new(_col, _alpha), width=_lw2,
                 style=_is_dash ? line.style_dashed : line.style_solid,
                 extend=_ext))

// ============================================================
// ── DESSIN ───────────────────────────────────────────────────
// ============================================================

var line ln_high  = na, var line ln_low   = na
// LONG lines
var line ln_tp1h  = na, var line ln_tp2h  = na, var line ln_tp3h  = na
var line ln_tp4h  = na, var line ln_tp5h  = na
var line ln_sl1h  = na, var line ln_sl2h  = na, var line ln_sl3h  = na
var line ln_enth  = na
// Mid lines
var line ln_mid3  = na, var line ln_mid1  = na, var line ln_mid2  = na
// SHORT lines
var line ln_entl  = na
var line ln_sl1l  = na, var line ln_sl2l  = na, var line ln_sl3l  = na
var line ln_tp1l  = na, var line ln_tp2l  = na, var line ln_tp3l  = na
var line ln_tp4l  = na, var line ln_tp5l  = na

// LONG labels
var label lbl_high  = na, var label lbl_low   = na
var label lbl_tp1h  = na, var label lbl_tp2h  = na, var label lbl_tp3h  = na
var label lbl_tp4h  = na, var label lbl_tp5h  = na
var label lbl_sl1h  = na, var label lbl_sl2h  = na, var label lbl_sl3h  = na
var label lbl_enth  = na
// Mid labels
var label lbl_mid3  = na, var label lbl_mid1  = na, var label lbl_mid2  = na
// SHORT labels
var label lbl_entl  = na
var label lbl_sl1l  = na, var label lbl_sl2l  = na, var label lbl_sl3l  = na
var label lbl_tp1l  = na, var label lbl_tp2l  = na, var label lbl_tp3l  = na
var label lbl_tp4l  = na, var label lbl_tp5l  = na

// Boxes
var box bx_tp_long  = na, var box bx_sl_long  = na
var box bx_tp_short = na, var box bx_sl_short = na

// ── Helpers ──────────────────────────────────────────────────
f_line(old_ln, y_val, col, lw, is_solid, int x1_override) =>
    if not na(old_ln)
        line.delete(old_ln)
    _x1 = na(x1_override) ? locked_bar_start : x1_override
    _x2 = _ln_x2_offset(_x1)
    line.new(x1=_x1, y1=y_val, x2=_x2, y2=y_val,
             color=col, width=lw,
             style=is_solid ? line.style_solid : line.style_dashed,
             extend=_ln_extend)

f_lbl(old_lbl, y_val, txt, col, sz) =>
    if not na(old_lbl)
        label.delete(old_lbl)
    label.new(x=locked_bar_start, y=y_val, text=txt,
              color=color.new(col, 85), textcolor=col,
              style=label.style_label_right, size=sz)

f_del_ln(ln) =>
    if not na(ln)
        line.delete(ln)
    line(na)

f_del_lb(lb) =>
    if not na(lb)
        label.delete(lb)
    label(na)

f_box(old_bx, x1, top, bottom, bg_col, bdr_col) =>
    if not na(old_bx)
        box.delete(old_bx)
    box.new(left=x1, top=top, right=bar_index, bottom=bottom,
            bgcolor=bg_col, border_color=bdr_col, border_width=1,
            extend=extend.right)

// ── Dessin principal (barstate.islast uniquement) ─────────────
// Le jour J-1 le plus récent (index 0) est dessiné avec les variables
// persistantes (ln_*, lbl_*) — comportement identique à v6.
// Les jours J-2 … J-N sont dessinés de façon non-persistante dans
// une boucle ; leurs lignes sont supprimées et recréées à chaque tick.
var line[]  hist_lines  = array.new<line>(0)
var label[] hist_labels = array.new<label>(0)

if not na(locked_high) and barstate.islast
    _sz = f_label_size(label_size)
    _lw = line_width_fibo

    // ── Effacer les dessins historiques précédents ────────────
    for _hl in hist_lines
        line.delete(_hl)
    array.clear(hist_lines)
    for _hlb in hist_labels
        label.delete(_hlb)
    array.clear(hist_labels)

    // ── Dessiner les jours J-2 … J-N ────────────────────────
    _nb = array.size(hist_high)
    if _nb > 1
        // Style des lignes historiques
        _h_style = hist_line_style == "Solide"      ? line.style_solid :
                   hist_line_style == "Tirets"       ? line.style_dashed :
                   line.style_dotted
        // Sélection couleurs : dédiées ou héritées de J-1
        _hc_tp1   = hist_use_own_cols ? hist_col_tp1   : col_tp1
        _hc_tp2   = hist_use_own_cols ? hist_col_tp2   : col_tp2
        _hc_tp3   = hist_use_own_cols ? hist_col_tp3   : col_tp3
        _hc_tp4   = hist_use_own_cols ? hist_col_tp4   : col_tp4
        _hc_tp5   = hist_use_own_cols ? hist_col_tp5   : col_tp5
        _hc_entry = hist_use_own_cols ? hist_col_entry  : col_entry
        _hc_sl1   = hist_use_own_cols ? hist_col_sl1   : col_sl1
        _hc_sl2   = hist_use_own_cols ? hist_col_sl2   : col_sl2
        _hc_sl3   = hist_use_own_cols ? hist_col_sl3   : col_sl3
        _hc_high  = hist_use_own_cols ? hist_col_high  : col_high
        _hc_low   = hist_use_own_cols ? hist_col_low   : col_low

        for _i = 1 to _nb - 1
            _hi   = array.get(hist_high,  _i)
            _lo   = array.get(hist_low,   _i)
            _bs   = array.get(hist_start, _i)
            _x2h  = _ln_x2_offset(_bs)
            // Transparence croissante selon le paramètre utilisateur
            _fade = math.min(hist_opacity_base + (_i - 1) * hist_opacity_step, 95)

            if hist_show_hl
                _lnh = line.new(x1=_bs, y1=_hi, x2=_x2h, y2=_hi,
                                color=color.new(_hc_high, _fade),
                                width=hist_line_width,
                                style=line.style_solid, extend=_ln_extend)
                _lnl = line.new(x1=_bs, y1=_lo, x2=_x2h, y2=_lo,
                                color=color.new(_hc_low, _fade),
                                width=hist_line_width,
                                style=line.style_solid, extend=_ln_extend)
                array.push(hist_lines, _lnh)
                array.push(hist_lines, _lnl)
                if hist_show_labels
                    _lbh = label.new(x=_bs, y=_hi,
                                     text="HIGH J-" + str.tostring(_i+1) + "  " + str.tostring(_hi, format.mintick),
                                     color=color.new(_hc_high, 90),
                                     textcolor=color.new(_hc_high, _fade),
                                     style=label.style_label_right, size=size.tiny)
                    _lbl = label.new(x=_bs, y=_lo,
                                     text="LOW  J-" + str.tostring(_i+1) + "  " + str.tostring(_lo, format.mintick),
                                     color=color.new(_hc_low, 90),
                                     textcolor=color.new(_hc_low, _fade),
                                     style=label.style_label_right, size=size.tiny)
                    array.push(hist_labels, _lbh)
                    array.push(hist_labels, _lbl)

            if hist_show_fibo and show_fibo
                [_tp1h,_tp2h,_tp3h,_tp4h,_tp5h, _sl1h,_sl2h,_sl3h, _enth,
                 _entl, _sl1l,_sl2l,_sl3l, _tp1l,_tp2l,_tp3l,_tp4l,_tp5l] = f_levels(_hi, _lo)
                _x2f  = _ln_x2_offset(_bs)
                _hlw  = hist_line_width
                _hst  = _h_style
                if show_long
                    f_hist_ln(hist_lines, _bs, _x2f, _enth,  _hc_entry, _fade, false, _ln_extend, _hlw)
                    f_hist_ln(hist_lines, _bs, _x2f, _tp1h,  _hc_tp1,   _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    f_hist_ln(hist_lines, _bs, _x2f, _sl1h,  _hc_sl1,   _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_tp2_en : fibo_tp2_h_en
                        f_hist_ln(hist_lines, _bs, _x2f, _tp2h, _hc_tp2, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_tp3_en : fibo_tp3_h_en
                        f_hist_ln(hist_lines, _bs, _x2f, _tp3h, _hc_tp3, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_tp4_en : fibo_tp4_h_en
                        f_hist_ln(hist_lines, _bs, _x2f, _tp4h, _hc_tp4, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_tp5_en : fibo_tp5_h_en
                        f_hist_ln(hist_lines, _bs, _x2f, _tp5h, _hc_tp5, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_sl2_en : fibo_sl2_h_en
                        f_hist_ln(hist_lines, _bs, _x2f, _sl2h, _hc_sl2, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_sl3_en : fibo_sl3_h_en
                        f_hist_ln(hist_lines, _bs, _x2f, _sl3h, _hc_sl3, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                if show_short
                    f_hist_ln(hist_lines, _bs, _x2f, _entl,  _hc_entry, _fade, false, _ln_extend, _hlw)
                    f_hist_ln(hist_lines, _bs, _x2f, _tp1l,  _hc_tp1,   _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    f_hist_ln(hist_lines, _bs, _x2f, _sl1l,  _hc_sl1,   _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_tp2_en : fibo_tp2_l_en
                        f_hist_ln(hist_lines, _bs, _x2f, _tp2l, _hc_tp2, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_tp3_en : fibo_tp3_l_en
                        f_hist_ln(hist_lines, _bs, _x2f, _tp3l, _hc_tp3, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_tp4_en : fibo_tp4_l_en
                        f_hist_ln(hist_lines, _bs, _x2f, _tp4l, _hc_tp4, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_tp5_en : fibo_tp5_l_en
                        f_hist_ln(hist_lines, _bs, _x2f, _tp5l, _hc_tp5, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_sl2_en : fibo_sl2_l_en
                        f_hist_ln(hist_lines, _bs, _x2f, _sl2l, _hc_sl2, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)
                    if is_pips_mode ? pip_sl3_en : fibo_sl3_l_en
                        f_hist_ln(hist_lines, _bs, _x2f, _sl3l, _hc_sl3, _fade, _hst == line.style_dashed or _hst == line.style_dotted, _ln_extend, _hlw)

    // ══════════════════════════════════════════════════════════
    // ── Dessin J-1 (range le plus récent) ────────────────────
    // ══════════════════════════════════════════════════════════
    [d_tp1h,d_tp2h,d_tp3h,d_tp4h,d_tp5h,
     d_sl1h,d_sl2h,d_sl3h, d_enth,
     d_entl, d_sl1l,d_sl2l,d_sl3l,
     d_tp1l,d_tp2l,d_tp3l,d_tp4l,d_tp5l] = f_levels(locked_high, locked_low)

    // ── Flags actifs selon mode ───────────────────────────────
    tp2h_on = is_pips_mode ? pip_tp2_en : fibo_tp2_h_en
    tp3h_on = is_pips_mode ? pip_tp3_en : fibo_tp3_h_en
    tp4h_on = is_pips_mode ? pip_tp4_en : fibo_tp4_h_en
    tp5h_on = is_pips_mode ? pip_tp5_en : fibo_tp5_h_en
    sl2h_on = is_pips_mode ? pip_sl2_en : fibo_sl2_h_en
    sl3h_on = is_pips_mode ? pip_sl3_en : fibo_sl3_h_en
    tp2l_on = is_pips_mode ? pip_tp2_en : fibo_tp2_l_en
    tp3l_on = is_pips_mode ? pip_tp3_en : fibo_tp3_l_en
    tp4l_on = is_pips_mode ? pip_tp4_en : fibo_tp4_l_en
    tp5l_on = is_pips_mode ? pip_tp5_en : fibo_tp5_l_en
    sl2l_on = is_pips_mode ? pip_sl2_en : fibo_sl2_l_en
    sl3l_on = is_pips_mode ? pip_sl3_en : fibo_sl3_l_en

    // ── Textes des labels ─────────────────────────────────────
    tp1h_lbl = is_pips_mode ? str.tostring(pip_tp1) + " pips" : str.tostring(fibo_tp1_high)
    tp2h_lbl = is_pips_mode ? str.tostring(pip_tp2) + " pips" : str.tostring(fibo_tp2_high)
    tp3h_lbl = is_pips_mode ? str.tostring(pip_tp3) + " pips" : str.tostring(fibo_tp3_high)
    tp4h_lbl = is_pips_mode ? str.tostring(pip_tp4) + " pips" : str.tostring(fibo_tp4_high)
    tp5h_lbl = is_pips_mode ? str.tostring(pip_tp5) + " pips" : str.tostring(fibo_tp5_high)
    sl1h_lbl = is_pips_mode ? str.tostring(pip_sl1) + " pips" : str.tostring(fibo_sl1_high)
    sl2h_lbl = is_pips_mode ? str.tostring(pip_sl2) + " pips" : str.tostring(fibo_sl2_high)
    sl3h_lbl = is_pips_mode ? str.tostring(pip_sl3) + " pips" : str.tostring(fibo_sl3_high)
    tp1l_lbl = is_pips_mode ? str.tostring(pip_tp1) + " pips" : str.tostring(fibo_tp1_low)
    tp2l_lbl = is_pips_mode ? str.tostring(pip_tp2) + " pips" : str.tostring(fibo_tp2_low)
    tp3l_lbl = is_pips_mode ? str.tostring(pip_tp3) + " pips" : str.tostring(fibo_tp3_low)
    tp4l_lbl = is_pips_mode ? str.tostring(pip_tp4) + " pips" : str.tostring(fibo_tp4_low)
    tp5l_lbl = is_pips_mode ? str.tostring(pip_tp5) + " pips" : str.tostring(fibo_tp5_low)
    sl1l_lbl = is_pips_mode ? str.tostring(pip_sl1) + " pips" : str.tostring(fibo_sl1_low)
    sl2l_lbl = is_pips_mode ? str.tostring(pip_sl2) + " pips" : str.tostring(fibo_sl2_low)
    sl3l_lbl = is_pips_mode ? str.tostring(pip_sl3) + " pips" : str.tostring(fibo_sl3_low)
    enth_lbl = is_pips_mode ? "HIGH" : str.tostring(fibo_entry_high)
    entl_lbl = is_pips_mode ? "LOW"  : str.tostring(fibo_entry_low)

    pct_tp1h = f_pct(d_enth, d_tp1h)
    pct_tp2h = f_pct(d_enth, d_tp2h)
    pct_tp3h = f_pct(d_enth, d_tp3h)
    pct_tp4h = f_pct(d_enth, d_tp4h)
    pct_tp5h = f_pct(d_enth, d_tp5h)
    pct_sl1h = f_pct(d_enth, d_sl1h)
    pct_sl2h = f_pct(d_enth, d_sl2h)
    pct_sl3h = f_pct(d_enth, d_sl3h)
    pct_tp1l = f_pct(d_entl, d_tp1l)
    pct_tp2l = f_pct(d_entl, d_tp2l)
    pct_tp3l = f_pct(d_entl, d_tp3l)
    pct_tp4l = f_pct(d_entl, d_tp4l)
    pct_tp5l = f_pct(d_entl, d_tp5l)
    pct_sl1l = f_pct(d_entl, d_sl1l)
    pct_sl2l = f_pct(d_entl, d_sl2l)
    pct_sl3l = f_pct(d_entl, d_sl3l)

    // ── Zones TP1/SL1 style TradingView ──────────────────────
    if show_boxes
        if show_long
            bx_tp_long := f_box(bx_tp_long, locked_bar_start, d_tp1h, d_enth, col_box_tp, col_box_border)
            bx_sl_long := f_box(bx_sl_long, locked_bar_start, d_enth, d_sl1h, col_box_sl, col_box_border)
        else
            if not na(bx_tp_long)
                box.delete(bx_tp_long)
                bx_tp_long  := na
            if not na(bx_sl_long)
                box.delete(bx_sl_long)
                bx_sl_long  := na
        if show_short
            bx_tp_short := f_box(bx_tp_short, locked_bar_start, d_entl, d_tp1l, col_box_tp, col_box_border)
            bx_sl_short := f_box(bx_sl_short, locked_bar_start, d_sl1l, d_entl, col_box_sl, col_box_border)
        else
            if not na(bx_tp_short)
                box.delete(bx_tp_short)
                bx_tp_short := na
            if not na(bx_sl_short)
                box.delete(bx_sl_short)
                bx_sl_short := na

    // ── High / Low ────────────────────────────────────────────
    if show_high_low
        ln_high := f_line(ln_high, locked_high, col_high, line_width_hl, true, int(na))
        ln_low  := f_line(ln_low,  locked_low,  col_low,  line_width_hl, true, int(na))
        if show_labels
            lbl_high := f_lbl(lbl_high, locked_high, "HIGH (J-1)  " + str.tostring(locked_high, format.mintick), col_high, _sz)
            lbl_low  := f_lbl(lbl_low,  locked_low,  "LOW  (J-1)  " + str.tostring(locked_low,  format.mintick), col_low,  _sz)

    // ── Lignes Fibonacci / Pips ────────────────────────────────
    if show_fibo
        // ════ LONG ════════════════════════════════════════════
        if show_long
            ln_enth  := f_line(ln_enth,  d_enth,  col_entry, _lw+1, true, int(na))
            ln_sl1h  := f_line(ln_sl1h,  d_sl1h,  col_sl1,   _lw,   false, int(na))
            ln_tp1h  := f_line(ln_tp1h,  d_tp1h,  col_tp1,   _lw+1, false, int(na))
            if show_labels
                lbl_enth := f_lbl(lbl_enth, d_enth, "BUY "  + enth_lbl + "   " + str.tostring(d_enth,  format.mintick),                                                   col_entry, _sz)
                lbl_sl1h := f_lbl(lbl_sl1h, d_sl1h, "SL1 "  + sl1h_lbl + "   " + str.tostring(d_sl1h,  format.mintick) + "  ("  + str.tostring(pct_sl1h) + "%)", col_sl1,   _sz)
                lbl_tp1h := f_lbl(lbl_tp1h, d_tp1h, "TP1 "  + tp1h_lbl + "   " + str.tostring(d_tp1h,  format.mintick) + "  (+" + str.tostring(pct_tp1h) + "%)", col_tp1,   _sz)
            // SL2
            if sl2h_on
                ln_sl2h  := f_line(ln_sl2h, d_sl2h, col_sl2, _lw, false, int(na))
                if show_labels
                    lbl_sl2h := f_lbl(lbl_sl2h, d_sl2h, "SL2 " + sl2h_lbl + "   " + str.tostring(d_sl2h, format.mintick) + "  (" + str.tostring(pct_sl2h) + "%)", col_sl2, _sz)
            else
                ln_sl2h  := f_del_ln(ln_sl2h)
                lbl_sl2h := f_del_lb(lbl_sl2h)
            // SL3
            if sl3h_on
                ln_sl3h  := f_line(ln_sl3h, d_sl3h, col_sl3, _lw, false, int(na))
                if show_labels
                    lbl_sl3h := f_lbl(lbl_sl3h, d_sl3h, "SL3 " + sl3h_lbl + "   " + str.tostring(d_sl3h, format.mintick) + "  (" + str.tostring(pct_sl3h) + "%)", col_sl3, _sz)
            else
                ln_sl3h  := f_del_ln(ln_sl3h)
                lbl_sl3h := f_del_lb(lbl_sl3h)
            // TP2
            if tp2h_on
                ln_tp2h  := f_line(ln_tp2h, d_tp2h, col_tp2, _lw+1, false, int(na))
                if show_labels
                    lbl_tp2h := f_lbl(lbl_tp2h, d_tp2h, "TP2 " + tp2h_lbl + "   " + str.tostring(d_tp2h, format.mintick) + "  (+" + str.tostring(pct_tp2h) + "%)", col_tp2, _sz)
            else
                ln_tp2h  := f_del_ln(ln_tp2h)
                lbl_tp2h := f_del_lb(lbl_tp2h)
            // TP3
            if tp3h_on
                ln_tp3h  := f_line(ln_tp3h, d_tp3h, col_tp3, _lw+1, false, int(na))
                if show_labels
                    lbl_tp3h := f_lbl(lbl_tp3h, d_tp3h, "TP3 " + tp3h_lbl + "   " + str.tostring(d_tp3h, format.mintick) + "  (+" + str.tostring(pct_tp3h) + "%)", col_tp3, _sz)
            else
                ln_tp3h  := f_del_ln(ln_tp3h)
                lbl_tp3h := f_del_lb(lbl_tp3h)
            // TP4
            if tp4h_on
                ln_tp4h  := f_line(ln_tp4h, d_tp4h, col_tp4, _lw+1, false, int(na))
                if show_labels
                    lbl_tp4h := f_lbl(lbl_tp4h, d_tp4h, "TP4 " + tp4h_lbl + "   " + str.tostring(d_tp4h, format.mintick) + "  (+" + str.tostring(pct_tp4h) + "%)", col_tp4, _sz)
            else
                ln_tp4h  := f_del_ln(ln_tp4h)
                lbl_tp4h := f_del_lb(lbl_tp4h)
            // TP5
            if tp5h_on
                ln_tp5h  := f_line(ln_tp5h, d_tp5h, col_tp5, _lw+1, false, int(na))
                if show_labels
                    lbl_tp5h := f_lbl(lbl_tp5h, d_tp5h, "TP5 " + tp5h_lbl + "   " + str.tostring(d_tp5h, format.mintick) + "  (+" + str.tostring(pct_tp5h) + "%)", col_tp5, _sz)
            else
                ln_tp5h  := f_del_ln(ln_tp5h)
                lbl_tp5h := f_del_lb(lbl_tp5h)
        else
            ln_enth  := f_del_ln(ln_enth),  lbl_enth  := f_del_lb(lbl_enth)
            ln_sl1h  := f_del_ln(ln_sl1h),  lbl_sl1h  := f_del_lb(lbl_sl1h)
            ln_sl2h  := f_del_ln(ln_sl2h),  lbl_sl2h  := f_del_lb(lbl_sl2h)
            ln_sl3h  := f_del_ln(ln_sl3h),  lbl_sl3h  := f_del_lb(lbl_sl3h)
            ln_tp1h  := f_del_ln(ln_tp1h),  lbl_tp1h  := f_del_lb(lbl_tp1h)
            ln_tp2h  := f_del_ln(ln_tp2h),  lbl_tp2h  := f_del_lb(lbl_tp2h)
            ln_tp3h  := f_del_ln(ln_tp3h),  lbl_tp3h  := f_del_lb(lbl_tp3h)
            ln_tp4h  := f_del_ln(ln_tp4h),  lbl_tp4h  := f_del_lb(lbl_tp4h)
            ln_tp5h  := f_del_ln(ln_tp5h),  lbl_tp5h  := f_del_lb(lbl_tp5h)

        // ── Niveaux intermédiaires (Fibo uniquement) ──────────
        if show_mid and not is_pips_mode
            p_m3 = f_price(locked_high, locked_low, fibo_mid3)
            p_m1 = f_price(locked_high, locked_low, fibo_mid1)
            p_m2 = f_price(locked_high, locked_low, fibo_mid2)
            ln_mid3 := f_line(ln_mid3, p_m3, col_mid, _lw, false, int(na))
            ln_mid1 := f_line(ln_mid1, p_m1, col_mid, _lw, false, int(na))
            ln_mid2 := f_line(ln_mid2, p_m2, col_mid, _lw, false, int(na))
            if show_labels
                lbl_mid3 := f_lbl(lbl_mid3, p_m3, str.tostring(fibo_mid3) + "   " + str.tostring(p_m3, format.mintick), col_mid, _sz)
                lbl_mid1 := f_lbl(lbl_mid1, p_m1, str.tostring(fibo_mid1) + "   " + str.tostring(p_m1, format.mintick), col_mid, _sz)
                lbl_mid2 := f_lbl(lbl_mid2, p_m2, str.tostring(fibo_mid2) + "   " + str.tostring(p_m2, format.mintick), col_mid, _sz)
        else
            ln_mid3  := f_del_ln(ln_mid3),  lbl_mid3  := f_del_lb(lbl_mid3)
            ln_mid1  := f_del_ln(ln_mid1),  lbl_mid1  := f_del_lb(lbl_mid1)
            ln_mid2  := f_del_ln(ln_mid2),  lbl_mid2  := f_del_lb(lbl_mid2)

        // ════ SHORT ═══════════════════════════════════════════
        if show_short
            ln_entl  := f_line(ln_entl,  d_entl,  col_entry, _lw+1, true, int(na))
            ln_sl1l  := f_line(ln_sl1l,  d_sl1l,  col_sl1,   _lw,   false, int(na))
            ln_tp1l  := f_line(ln_tp1l,  d_tp1l,  col_tp1,   _lw+1, false, int(na))
            if show_labels
                lbl_entl := f_lbl(lbl_entl, d_entl, "SELL " + entl_lbl + "   " + str.tostring(d_entl,  format.mintick),                                                   col_entry, _sz)
                lbl_sl1l := f_lbl(lbl_sl1l, d_sl1l, "SL1 "  + sl1l_lbl + "   " + str.tostring(d_sl1l,  format.mintick) + "  ("  + str.tostring(pct_sl1l) + "%)", col_sl1,   _sz)
                lbl_tp1l := f_lbl(lbl_tp1l, d_tp1l, "TP1 "  + tp1l_lbl + "   " + str.tostring(d_tp1l,  format.mintick) + "  (" + str.tostring(pct_tp1l)  + "%)", col_tp1,   _sz)
            // SL2
            if sl2l_on
                ln_sl2l  := f_line(ln_sl2l, d_sl2l, col_sl2, _lw, false, int(na))
                if show_labels
                    lbl_sl2l := f_lbl(lbl_sl2l, d_sl2l, "SL2 " + sl2l_lbl + "   " + str.tostring(d_sl2l, format.mintick) + "  (" + str.tostring(pct_sl2l) + "%)", col_sl2, _sz)
            else
                ln_sl2l  := f_del_ln(ln_sl2l)
                lbl_sl2l := f_del_lb(lbl_sl2l)
            // SL3
            if sl3l_on
                ln_sl3l  := f_line(ln_sl3l, d_sl3l, col_sl3, _lw, false, int(na))
                if show_labels
                    lbl_sl3l := f_lbl(lbl_sl3l, d_sl3l, "SL3 " + sl3l_lbl + "   " + str.tostring(d_sl3l, format.mintick) + "  (" + str.tostring(pct_sl3l) + "%)", col_sl3, _sz)
            else
                ln_sl3l  := f_del_ln(ln_sl3l)
                lbl_sl3l := f_del_lb(lbl_sl3l)
            // TP2
            if tp2l_on
                ln_tp2l  := f_line(ln_tp2l, d_tp2l, col_tp2, _lw+1, false, int(na))
                if show_labels
                    lbl_tp2l := f_lbl(lbl_tp2l, d_tp2l, "TP2 " + tp2l_lbl + "   " + str.tostring(d_tp2l, format.mintick) + "  (" + str.tostring(pct_tp2l) + "%)", col_tp2, _sz)
            else
                ln_tp2l  := f_del_ln(ln_tp2l)
                lbl_tp2l := f_del_lb(lbl_tp2l)
            // TP3
            if tp3l_on
                ln_tp3l  := f_line(ln_tp3l, d_tp3l, col_tp3, _lw+1, false, int(na))
                if show_labels
                    lbl_tp3l := f_lbl(lbl_tp3l, d_tp3l, "TP3 " + tp3l_lbl + "   " + str.tostring(d_tp3l, format.mintick) + "  (" + str.tostring(pct_tp3l) + "%)", col_tp3, _sz)
            else
                ln_tp3l  := f_del_ln(ln_tp3l)
                lbl_tp3l := f_del_lb(lbl_tp3l)
            // TP4
            if tp4l_on
                ln_tp4l  := f_line(ln_tp4l, d_tp4l, col_tp4, _lw+1, false, int(na))
                if show_labels
                    lbl_tp4l := f_lbl(lbl_tp4l, d_tp4l, "TP4 " + tp4l_lbl + "   " + str.tostring(d_tp4l, format.mintick) + "  (" + str.tostring(pct_tp4l) + "%)", col_tp4, _sz)
            else
                ln_tp4l  := f_del_ln(ln_tp4l)
                lbl_tp4l := f_del_lb(lbl_tp4l)
            // TP5
            if tp5l_on
                ln_tp5l  := f_line(ln_tp5l, d_tp5l, col_tp5, _lw+1, false, int(na))
                if show_labels
                    lbl_tp5l := f_lbl(lbl_tp5l, d_tp5l, "TP5 " + tp5l_lbl + "   " + str.tostring(d_tp5l, format.mintick) + "  (" + str.tostring(pct_tp5l) + "%)", col_tp5, _sz)
            else
                ln_tp5l  := f_del_ln(ln_tp5l)
                lbl_tp5l := f_del_lb(lbl_tp5l)
        else
            ln_entl  := f_del_ln(ln_entl),  lbl_entl  := f_del_lb(lbl_entl)
            ln_sl1l  := f_del_ln(ln_sl1l),  lbl_sl1l  := f_del_lb(lbl_sl1l)
            ln_sl2l  := f_del_ln(ln_sl2l),  lbl_sl2l  := f_del_lb(lbl_sl2l)
            ln_sl3l  := f_del_ln(ln_sl3l),  lbl_sl3l  := f_del_lb(lbl_sl3l)
            ln_tp1l  := f_del_ln(ln_tp1l),  lbl_tp1l  := f_del_lb(lbl_tp1l)
            ln_tp2l  := f_del_ln(ln_tp2l),  lbl_tp2l  := f_del_lb(lbl_tp2l)
            ln_tp3l  := f_del_ln(ln_tp3l),  lbl_tp3l  := f_del_lb(lbl_tp3l)
            ln_tp4l  := f_del_ln(ln_tp4l),  lbl_tp4l  := f_del_lb(lbl_tp4l)
            ln_tp5l  := f_del_ln(ln_tp5l),  lbl_tp5l  := f_del_lb(lbl_tp5l)

// ============================================================
// ── TABLEAU DE BORD ──────────────────────────────────────────
// ============================================================

var table dash = table.new(position.top_right, 2, 26,
     bgcolor=color.new(#1E1E2E, 10),
     border_color=color.new(#444466, 50),
     border_width=1)

if barstate.islast and not na(locked_high)
    _dsz = f_dash_size(dash_text_size)
    [d_tp1h,d_tp2h,d_tp3h,d_tp4h,d_tp5h,
     d_sl1h,d_sl2h,d_sl3h, d_enth,
     d_entl, d_sl1l,d_sl2l,d_sl3l,
     d_tp1l,d_tp2l,d_tp3l,d_tp4l,d_tp5l] = f_levels(locked_high, locked_low)
    _rng = locked_high - locked_low

    rr_long  = math.abs(d_tp1h - d_enth) / math.abs(d_enth - d_sl1h)
    rr_short = math.abs(d_entl - d_tp1l) / math.abs(d_sl1l - d_entl)

    pct_tp1h = f_pct(d_enth, d_tp1h)
    pct_tp2h = f_pct(d_enth, d_tp2h)
    pct_tp3h = f_pct(d_enth, d_tp3h)
    pct_tp4h = f_pct(d_enth, d_tp4h)
    pct_tp5h = f_pct(d_enth, d_tp5h)
    pct_sl1h = f_pct(d_enth, d_sl1h)
    pct_sl2h = f_pct(d_enth, d_sl2h)
    pct_sl3h = f_pct(d_enth, d_sl3h)
    pct_tp1l = f_pct(d_entl, d_tp1l)
    pct_tp2l = f_pct(d_entl, d_tp2l)
    pct_tp3l = f_pct(d_entl, d_tp3l)
    pct_tp4l = f_pct(d_entl, d_tp4l)
    pct_tp5l = f_pct(d_entl, d_tp5l)
    pct_sl1l = f_pct(d_entl, d_sl1l)
    pct_sl2l = f_pct(d_entl, d_sl2l)
    pct_sl3l = f_pct(d_entl, d_sl3l)

    tp2h_on_d = is_pips_mode ? pip_tp2_en : fibo_tp2_h_en
    tp3h_on_d = is_pips_mode ? pip_tp3_en : fibo_tp3_h_en
    tp4h_on_d = is_pips_mode ? pip_tp4_en : fibo_tp4_h_en
    tp5h_on_d = is_pips_mode ? pip_tp5_en : fibo_tp5_h_en
    sl2h_on_d = is_pips_mode ? pip_sl2_en : fibo_sl2_h_en
    sl3h_on_d = is_pips_mode ? pip_sl3_en : fibo_sl3_h_en
    tp2l_on_d = is_pips_mode ? pip_tp2_en : fibo_tp2_l_en
    tp3l_on_d = is_pips_mode ? pip_tp3_en : fibo_tp3_l_en
    tp4l_on_d = is_pips_mode ? pip_tp4_en : fibo_tp4_l_en
    tp5l_on_d = is_pips_mode ? pip_tp5_en : fibo_tp5_l_en
    sl2l_on_d = is_pips_mode ? pip_sl2_en : fibo_sl2_l_en
    sl3l_on_d = is_pips_mode ? pip_sl3_en : fibo_sl3_l_en

    mode_badge  = is_pips_mode ? "  📏 PIPS" : "  📐 FIBO"
    tz_badge    = "  🌍 " + tz_city
    badge_col   = is_c1 ? color.new(#F9A825, 20) : is_c2 ? color.new(#E64A19, 20) : color.new(#2D2B55, 20)
    badge_txt   = is_c1 ? #FFF176 : is_c2 ? #FFCCBC : #A78BFA

    // ── Header ───────────────────────────────────────────────
    table.cell(dash, 0, 0, "RANGE J-1  6H–6H" + mode_badge + tz_badge, text_color=badge_txt, text_size=_dsz, bgcolor=badge_col)
    table.cell(dash, 1, 0, "▶ " + profile_name + " ◀  " + syminfo.ticker, text_color=badge_txt, text_size=_dsz, bgcolor=badge_col)

    row = 1

    // ── Range ─────────────────────────────────────────────────
    if show_dash_rng
        table.cell(dash, 0, row,     "High J-1",  text_color=#E2E8F0, text_size=_dsz)
        table.cell(dash, 1, row,     str.tostring(locked_high, format.mintick), text_color=#00C853, text_size=_dsz)
        table.cell(dash, 0, row + 1, "Low J-1",   text_color=#E2E8F0, text_size=_dsz)
        table.cell(dash, 1, row + 1, str.tostring(locked_low,  format.mintick), text_color=#D50000, text_size=_dsz)
        table.cell(dash, 0, row + 2, "Amplitude", text_color=#E2E8F0, text_size=_dsz)
        table.cell(dash, 1, row + 2, str.tostring(math.round(_rng / syminfo.mintick), "##,###") + " pts", text_color=#FFC107, text_size=_dsz)
        row := row + 3

    // ── LONG ─────────────────────────────────────────────────
    if show_dash_long and show_long
        table.cell(dash, 0, row, "── LONG ──", text_color=#64B5F6, text_size=_dsz, bgcolor=color.new(#1565C0,70))
        table.cell(dash, 1, row, "",            text_color=#64B5F6, text_size=_dsz, bgcolor=color.new(#1565C0,70))
        row := row + 1
        // TP5 → TP1 (du plus loin au plus proche)
        if tp5h_on_d
            table.cell(dash, 0, row, "TP5 Long", text_color=#E2E8F0,  text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_tp5h, format.mintick) + "  (+" + str.tostring(pct_tp5h) + "%)", text_color=#E0F7FA, text_size=_dsz)
            row := row + 1
        if tp4h_on_d
            table.cell(dash, 0, row, "TP4 Long", text_color=#E2E8F0,  text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_tp4h, format.mintick) + "  (+" + str.tostring(pct_tp4h) + "%)", text_color=#B2EBF2, text_size=_dsz)
            row := row + 1
        if tp3h_on_d
            table.cell(dash, 0, row, "TP3 Long", text_color=#E2E8F0,  text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_tp3h, format.mintick) + "  (+" + str.tostring(pct_tp3h) + "%)", text_color=#80DEEA, text_size=_dsz)
            row := row + 1
        if tp2h_on_d
            table.cell(dash, 0, row, "TP2 Long", text_color=#E2E8F0,  text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_tp2h, format.mintick) + "  (+" + str.tostring(pct_tp2h) + "%)", text_color=#00E5FF, text_size=_dsz)
            row := row + 1
        table.cell(dash, 0, row, "TP1 Long",   text_color=#E2E8F0,  text_size=_dsz)
        table.cell(dash, 1, row, str.tostring(d_tp1h, format.mintick) + "  (+" + str.tostring(pct_tp1h) + "%)", text_color=#00BFA5, text_size=_dsz)
        row := row + 1
        table.cell(dash, 0, row, "BUY @ High", text_color=#E2E8F0,  text_size=_dsz)
        table.cell(dash, 1, row, str.tostring(d_enth, format.mintick), text_color=#2962FF, text_size=_dsz)
        row := row + 1
        table.cell(dash, 0, row, "SL1 Long",   text_color=#E2E8F0,  text_size=_dsz)
        table.cell(dash, 1, row, str.tostring(d_sl1h, format.mintick) + "  (" + str.tostring(pct_sl1h) + "%)", text_color=#FF6D00, text_size=_dsz)
        row := row + 1
        if sl2h_on_d
            table.cell(dash, 0, row, "SL2 Long", text_color=#E2E8F0, text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_sl2h, format.mintick) + "  (" + str.tostring(pct_sl2h) + "%)", text_color=#FF9100, text_size=_dsz)
            row := row + 1
        if sl3h_on_d
            table.cell(dash, 0, row, "SL3 Long", text_color=#E2E8F0, text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_sl3h, format.mintick) + "  (" + str.tostring(pct_sl3h) + "%)", text_color=#FFCA28, text_size=_dsz)
            row := row + 1
        if show_dash_rr
            table.cell(dash, 0, row, "R/R Long (TP1)", text_color=#E2E8F0, text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(math.round(rr_long, 2)), text_color=rr_long >= 2.0 ? #00C853 : rr_long >= 1.0 ? #FFC107 : #D50000, text_size=_dsz)
            row := row + 1

    // ── SHORT ────────────────────────────────────────────────
    if show_dash_short and show_short
        table.cell(dash, 0, row, "── SHORT ──", text_color=#EF9A9A, text_size=_dsz, bgcolor=color.new(#B71C1C,70))
        table.cell(dash, 1, row, "",             text_color=#EF9A9A, text_size=_dsz, bgcolor=color.new(#B71C1C,70))
        row := row + 1
        table.cell(dash, 0, row, "SELL @ Low", text_color=#E2E8F0, text_size=_dsz)
        table.cell(dash, 1, row, str.tostring(d_entl, format.mintick), text_color=#2962FF, text_size=_dsz)
        row := row + 1
        table.cell(dash, 0, row, "SL1 Short",  text_color=#E2E8F0, text_size=_dsz)
        table.cell(dash, 1, row, str.tostring(d_sl1l, format.mintick) + "  (" + str.tostring(pct_sl1l) + "%)", text_color=#FF6D00, text_size=_dsz)
        row := row + 1
        if sl2l_on_d
            table.cell(dash, 0, row, "SL2 Short", text_color=#E2E8F0, text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_sl2l, format.mintick) + "  (" + str.tostring(pct_sl2l) + "%)", text_color=#FF9100, text_size=_dsz)
            row := row + 1
        if sl3l_on_d
            table.cell(dash, 0, row, "SL3 Short", text_color=#E2E8F0, text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_sl3l, format.mintick) + "  (" + str.tostring(pct_sl3l) + "%)", text_color=#FFCA28, text_size=_dsz)
            row := row + 1
        table.cell(dash, 0, row, "TP1 Short",  text_color=#E2E8F0, text_size=_dsz)
        table.cell(dash, 1, row, str.tostring(d_tp1l, format.mintick) + "  (" + str.tostring(pct_tp1l) + "%)", text_color=#00BFA5, text_size=_dsz)
        row := row + 1
        if tp2l_on_d
            table.cell(dash, 0, row, "TP2 Short", text_color=#E2E8F0, text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_tp2l, format.mintick) + "  (" + str.tostring(pct_tp2l) + "%)", text_color=#00E5FF, text_size=_dsz)
            row := row + 1
        if tp3l_on_d
            table.cell(dash, 0, row, "TP3 Short", text_color=#E2E8F0, text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_tp3l, format.mintick) + "  (" + str.tostring(pct_tp3l) + "%)", text_color=#80DEEA, text_size=_dsz)
            row := row + 1
        if tp4l_on_d
            table.cell(dash, 0, row, "TP4 Short", text_color=#E2E8F0, text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_tp4l, format.mintick) + "  (" + str.tostring(pct_tp4l) + "%)", text_color=#B2EBF2, text_size=_dsz)
            row := row + 1
        if tp5l_on_d
            table.cell(dash, 0, row, "TP5 Short", text_color=#E2E8F0, text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(d_tp5l, format.mintick) + "  (" + str.tostring(pct_tp5l) + "%)", text_color=#E0F7FA, text_size=_dsz)
            row := row + 1
        if show_dash_rr
            table.cell(dash, 0, row, "R/R Short (TP1)", text_color=#E2E8F0, text_size=_dsz)
            table.cell(dash, 1, row, str.tostring(math.round(rr_short, 2)), text_color=rr_short >= 2.0 ? #00C853 : rr_short >= 1.0 ? #FFC107 : #D50000, text_size=_dsz)
````
