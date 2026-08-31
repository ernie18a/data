<!-- tradingview-pine-id: PUB;5d5e878b054a47c6b7a768a99e354249 -->
<!-- tradingviewscripts-format: 1 -->
# QUANTUM NEXUS AI v9.3 SENTINEL

Source: https://www.tradingview.com/script/XJU56w6r/

## Description

RSI,MACD,VWAP,VOLUME,PROFILE,PATERN.. 
all partern that you love in one indicator

---

## Source Code

````pine
//@version=6
// ╔══════════════════════════════════════════════════════════════════════════════╗
// ║  QUANTUM NEXUS AI  v9.3  —  SENTINEL (audité + fanions)                                           ║
// ║  Indicateurs classiques + Volume Profile + 100 IA + Scénarios de prix       ║
// ║  Pine Script v6  |  overlay=true  |  ingénierie quant                      ║
// ╚══════════════════════════════════════════════════════════════════════════════╝
indicator("QUANTUM NEXUS AI v9.3 SENTINEL", shorttitle="QN-v9.3", overlay=true,
     max_lines_count=500, max_labels_count=200, max_boxes_count=100, max_bars_back=1000)

// ═══════════════════════════════════════════════════════════════════════════════
// GROUPES
// ═══════════════════════════════════════════════════════════════════════════════
G_IND = "📊 Indicateurs principaux"
G_VP  = "📦 Volume Profile"
G_IA  = "🌍 100 IA (timeframe)"
G_MTF = "🛰️ Multi-Timeframe"
G_PRED= "🔮 Projection & Scénarios"
G_TRD = "🎯 Entrée / Stop / Cible"
G_ACC = "📈 Précision Live"
G_CND = "🎼 Décision (pondération)"
G_VIS = "🎨 Affichage graphique"
G_TBL = "🧠 Tableau"

// ═══════════════════════════════════════════════════════════════════════════════
// INPUTS — INDICATEURS
// ═══════════════════════════════════════════════════════════════════════════════
src       = input.source(close, "Source", group=G_IND)
emaFastL  = input.int(9,   "EMA rapide",  minval=1, group=G_IND)
emaMidL   = input.int(21,  "EMA moyenne", minval=1, group=G_IND)
emaSlowL  = input.int(50,  "EMA lente",   minval=1, group=G_IND)
emaTrendL = input.int(200, "EMA tendance",minval=1, group=G_IND)
rsiLen    = input.int(14,  "RSI",         minval=1, group=G_IND)
rsiOB     = input.float(70,"RSI surachat",minval=50, maxval=95, group=G_IND)
rsiOS     = input.float(30,"RSI survente",minval=5,  maxval=50, group=G_IND)
macdFast  = input.int(12,  "MACD rapide", minval=1, group=G_IND)
macdSlow  = input.int(26,  "MACD lente",  minval=1, group=G_IND)
macdSig   = input.int(9,   "MACD signal", minval=1, group=G_IND)
stochLen  = input.int(14,  "Stoch",       minval=1, group=G_IND)
stochK    = input.int(3,   "Stoch %K",    minval=1, group=G_IND)
stochD    = input.int(3,   "Stoch %D",    minval=1, group=G_IND)
stochOB   = input.float(80,"Stoch surachat", minval=50, maxval=95, group=G_IND)
stochOS   = input.float(20,"Stoch survente", minval=5, maxval=50, group=G_IND)
adxLen    = input.int(14,  "ADX",         minval=1, group=G_IND)
adxThresh = input.float(20,"ADX seuil tendance", minval=0, step=1, group=G_IND)
adxStrong = input.float(30,"ADX seuil fort",     minval=0, step=1, group=G_IND)
mfiLen    = input.int(14,  "MFI",         minval=1, group=G_IND)
volMaLen  = input.int(20,  "Volume MA",   minval=1, group=G_IND)
vwapLen   = input.int(20,  "VWAP glissant", minval=1, group=G_IND)
cciLen    = input.int(20,  "CCI",         minval=2, group=G_IND)
bbLen     = input.int(20,  "Bollinger",   minval=2, group=G_IND)
bbMult    = input.float(2.0,"Bollinger mult", minval=0.5, step=0.1, group=G_IND)
bbSqLen   = input.int(100, "Bollinger squeeze (barres)", minval=20, maxval=300, group=G_IND)
stFactor1 = input.float(2.0,"Supertrend facteur", minval=0.5, step=0.1, group=G_IND)
stAtr1    = input.int(10,  "Supertrend ATR", minval=1, group=G_IND)

// INPUTS — VOLUME PROFILE
showVP    = input.bool(true, "Afficher Volume Profile", group=G_VP)
vpLook    = input.int(150, "Période d'analyse (barres)", minval=20, maxval=500, group=G_VP)
vpBins    = input.int(24,  "Nombre de niveaux", minval=10, maxval=50, group=G_VP)
vpVA      = input.float(70,"Value Area (%)", minval=50, maxval=90, step=5, group=G_VP)

// INPUTS — 100 IA
agentTF   = input.timeframe("", "Timeframe des 100 IA (vide=graphique)", group=G_IA)

// INPUTS — MTF
useMTF = input.bool(true, "Activer Multi-TF", group=G_MTF)
tf1    = input.timeframe("60",  "TF 1", group=G_MTF)
tf2    = input.timeframe("240", "TF 2", group=G_MTF)
tf3    = input.timeframe("D",   "TF 3", group=G_MTF)

// INPUTS — PROJECTION & SCÉNARIOS
showProj    = input.bool(true, "Ligne de projection", group=G_PRED)
forecastBars= input.int(25,    "Horizon (barres)", minval=5, maxval=200, group=G_PRED)
sensitivity = input.float(1.5, "Sensibilité momentum", minval=0.1, maxval=5.0, step=0.1, group=G_PRED)
minConf     = input.int(50,    "Confiance min %", minval=0, maxval=100, group=G_PRED)
atrLen      = input.int(14,    "ATR", minval=1, group=G_PRED)
lenReg      = input.int(50,    "Régression", minval=5, group=G_PRED)
showBreak   = input.bool(true, "Marqueurs de cassure S/R", group=G_PRED)
pivotLen    = input.int(12,    "Sensibilité pivots S/R", minval=2, maxval=50, group=G_PRED)
srMerge     = input.float(0.6, "Fusion niveaux proches (×ATR)", minval=0.1, maxval=3.0, step=0.1, group=G_PRED)
srMax       = input.int(6,     "Nombre max de niveaux S/R", minval=2, maxval=15, group=G_PRED)
srWidth     = input.int(2,     "Épaisseur lignes S/R", minval=1, maxval=4, group=G_PRED)

// ── ZOOM CHANDELLES (limite la hauteur des dessins pour agrandir les bougies) ──
G_ZOOM = "🔍 Zoom chandelles"
drawZone = input.float(10.0, "Bande max des lignes (% du prix)", minval=3, maxval=40, step=1, group=G_ZOOM)

// INPUTS — TRADE
showTrade = input.bool(true, "Dessiner Entrée/Stop/Cible", group=G_TRD)
stopMult  = input.float(1.5, "Stop = ATR ×", minval=0.5, maxval=5, step=0.1, group=G_TRD)

// INPUTS — PRÉCISION LIVE
showAcc   = input.bool(true, "Précision réelle (auto-backtest)", group=G_ACC)
accWindow = input.int(100,   "Fenêtre (barres)", minval=20, maxval=500, group=G_ACC)

// INPUTS — DÉCISION (pondération conducteur)
wcTrend  = input.float(2.0, "Poids Tendance", minval=0, step=0.5, group=G_CND)
wcAgents = input.float(3.0, "Poids 100 IA",   minval=0, step=0.5, group=G_CND)
wcMTF    = input.float(2.5, "Poids Multi-TF", minval=0, step=0.5, group=G_CND)
wcVP     = input.float(1.5, "Poids Volume Profile", minval=0, step=0.5, group=G_CND)
wcLor    = input.float(1.0, "Poids Lorentzian", minval=0, step=0.5, group=G_CND)
wcRev    = input.float(1.5, "Poids Figures retournement", minval=0, step=0.5, group=G_CND)
wcChart  = input.float(2.0, "Poids Figures chartistes", minval=0, step=0.5, group=G_CND)
wcZone   = input.float(1.5, "Poids Confirmation zone", minval=0, step=0.5, group=G_CND)
cndBuy   = input.float(30.0,"Seuil ACHAT", minval=5, maxval=90, group=G_CND)
cndStrong= input.float(60.0,"Seuil ACHAT FORT", minval=10, maxval=95, group=G_CND)

// INPUTS — AFFICHAGE
showEma   = input.bool(true,  "EMAs", group=G_VIS)
showVwap  = input.bool(true,  "VWAP", group=G_VIS)
showSt    = input.bool(true,  "Supertrend", group=G_VIS)
showBB    = input.bool(true,  "Bandes de Bollinger", group=G_VIS)
showSR    = input.bool(true,  "Support/Résistance", group=G_VIS)
showBg    = input.bool(true,  "Fond coloré tendance", group=G_VIS)
colBull   = input.color(#26a69a, "Hausse", group=G_VIS)
colStrongBull = input.color(#00c853, "Hausse forte", group=G_VIS)
colBear   = input.color(#ef5350, "Baisse", group=G_VIS)
colStrongBear = input.color(#d50000, "Baisse forte", group=G_VIS)

// INPUTS — COULEURS AVANCÉES
G_COL = "🎨 Couleurs (avancé)"
colEmaFast = input.color(#2962ff, "EMA rapide",   group=G_COL, inline="e1")
colEmaMid  = input.color(#ff6d00, "moyenne",      group=G_COL, inline="e1")
colEmaSlow = input.color(#b2b5be, "EMA lente",    group=G_COL, inline="e2")
colEmaTrend= input.color(#e0e0e0, "tendance",     group=G_COL, inline="e2")
colVwapL   = input.color(#7e57c2, "VWAP",         group=G_COL, inline="v")
colBBL     = input.color(#26c6da, "Bollinger",    group=G_COL, inline="v")
colPOCL    = input.color(#ffeb3b, "POC",          group=G_COL, inline="v")
colResL    = input.color(#f23645, "Résistance",   group=G_COL, inline="sr")
colSupL    = input.color(#089981, "Support",      group=G_COL, inline="sr")
colPatBull = input.color(#00e676, "Pattern haussier", group=G_COL, inline="p")
colPatBear = input.color(#ff1744, "Pattern baissier", group=G_COL, inline="p")
useQBars   = input.bool(false, "Colorer les bougies selon le signal (quantique)", group=G_COL)
useQBg     = input.bool(true,  "Fond dynamique selon la confiance", group=G_COL)

// INPUTS — PATTERNS DE CHANDELIER
G_PAT = "🕯️ Patterns de chandelier"
showPat  = input.bool(true, "Détecter et afficher les patterns", group=G_PAT)
patBars  = input.int(120, "Barres récentes affichées", minval=10, maxval=500, group=G_PAT)
wcCandle = input.float(1.5, "Poids patterns dans la décision", minval=0, maxval=5, step=0.5, group=G_PAT)
patSize  = input.string("Petite", "Taille des étiquettes", options=["Minuscule","Petite","Normale"], group=G_PAT)
patTsize = patSize == "Minuscule" ? size.tiny : patSize == "Normale" ? size.normal : size.small
zoneAtr = input.float(1.5, "Proximité zone demande/offre (×ATR)", minval=0.3, maxval=5.0, step=0.1, group=G_PAT)

// INPUTS — POWER OF THREE (AMD)
G_AMD = "⚡ Power of Three (AMD)"
showAMD      = input.bool(true, "Détecter Accumulation → Manipulation → Distribution", group=G_AMD)
amdLen       = input.int(30, "Longueur accumulation (barres)", minval=10, maxval=100, group=G_AMD)
amdRangeMult = input.float(3.5, "Compression max du range (×ATR)", minval=1.0, maxval=10.0, step=0.5, group=G_AMD)
amdMaxWait   = input.int(15, "Barres max après manipulation", minval=3, maxval=50, group=G_AMD)
wcAMD        = input.float(2.5, "Poids AMD dans la décision", minval=0, step=0.5, group=G_AMD)
colAccu      = input.color(#f9e79f, "Accumulation",  group=G_AMD, inline="c")
colManip     = input.color(#f5b7b1, "Manipulation",  group=G_AMD, inline="c")
colDistr     = input.color(#a9dfbf, "Distribution",  group=G_AMD, inline="c")
colNeutral= input.color(#787b86, "Neutre", group=G_VIS)

// INPUTS — TABLEAU
showTable = input.bool(true, "Afficher tableau", group=G_TBL)
posInput  = input.string("Haut Droite", "Position", options=["Haut Droite","Haut Gauche","Bas Droite","Bas Gauche","Milieu Droite","Milieu Gauche"], group=G_TBL)
szInput   = input.string("Normale", "Taille texte", options=["Tiny","Petite","Normale","Grande","Énorme"], group=G_TBL)
wLabel    = input.int(0, "Largeur col. gauche (%, 0=auto)", minval=0, maxval=40, group=G_TBL)
wValue    = input.int(0, "Largeur col. droite (%, 0=auto)", minval=0, maxval=40, group=G_TBL)
secDecision = input.bool(true, "▸ Décision", group=G_TBL)
secScen     = input.bool(true, "▸ Projection & niveaux", group=G_TBL)
secInd      = input.bool(true, "▸ Indicateurs", group=G_TBL)
secVP       = input.bool(true, "▸ Volume Profile", group=G_TBL)
secIA       = input.bool(true, "▸ 100 IA & ML", group=G_TBL)
secPat      = input.bool(true, "▸ Patterns chandelier", group=G_TBL)
secAccT     = input.bool(true, "▸ Précision live", group=G_TBL)

// ── LIGNES INDIVIDUELLES DU TABLEAU (chaque ligne ON/OFF) ──
G_ROWS = "🧠 Tableau — lignes individuelles"
rVerdict = input.bool(true, "Verdict",   group=G_ROWS, inline="a")
rAction  = input.bool(true, "Action",    group=G_ROWS, inline="a")
rConf    = input.bool(true, "Confiance", group=G_ROWS, inline="a")
rAccord  = input.bool(true, "Accord",    group=G_ROWS, inline="b")
rPos     = input.bool(true, "Position",  group=G_ROWS, inline="b")
rProj    = input.bool(true, "Projection",group=G_ROWS, inline="b")
rZoneP   = input.bool(true, "Zone proj.",group=G_ROWS, inline="c")
rR1      = input.bool(true, "Résistance",group=G_ROWS, inline="c")
rS1      = input.bool(true, "Support",   group=G_ROWS, inline="c")
rRSI     = input.bool(true, "RSI",       group=G_ROWS, inline="d")
rMACD    = input.bool(true, "MACD",      group=G_ROWS, inline="d")
rADX     = input.bool(true, "ADX",       group=G_ROWS, inline="d")
rStoch   = input.bool(true, "Stoch",     group=G_ROWS, inline="e")
rCCI     = input.bool(true, "CCI",       group=G_ROWS, inline="e")
rMFI     = input.bool(true, "MFI",       group=G_ROWS, inline="e")
rVol     = input.bool(true, "Volume",    group=G_ROWS, inline="f")
rVWAP    = input.bool(true, "VWAP",      group=G_ROWS, inline="f")
rEMA     = input.bool(true, "EMA",       group=G_ROWS, inline="f")
rST      = input.bool(true, "Supertrend",group=G_ROWS, inline="g")
rATR     = input.bool(true, "ATR",       group=G_ROWS, inline="g")
rPOC     = input.bool(true, "POC",       group=G_ROWS, inline="g")
rVA      = input.bool(true, "Value Area",group=G_ROWS, inline="h")
rVsPOC   = input.bool(true, "Prix/POC",  group=G_ROWS, inline="h")
rIA      = input.bool(true, "100 IA",    group=G_ROWS, inline="h")
rConn    = input.bool(true, "Connexion", group=G_ROWS, inline="i")
rMTVS    = input.bool(true, "M·T·V·S",   group=G_ROWS, inline="i")
rMTF     = input.bool(true, "Multi-TF",  group=G_ROWS, inline="i")
rLor     = input.bool(true, "Lorentzian",group=G_ROWS, inline="j")
rPat     = input.bool(true, "Chandelier",group=G_ROWS, inline="j")
rRev     = input.bool(true, "Retournem.",group=G_ROWS, inline="j")
rChart   = input.bool(true, "Chartiste", group=G_ROWS, inline="k")
rZoneDO  = input.bool(true, "Zone D/O",  group=G_ROWS, inline="k")
rAccP    = input.bool(true, "Préc.proj", group=G_ROWS, inline="k")
rAccD    = input.bool(true, "Préc.déc",  group=G_ROWS, inline="l")
rBB      = input.bool(true, "Bollinger", group=G_ROWS, inline="l")
rIntens  = input.bool(true, "Intensité", group=G_ROWS, inline="m")
rAMD     = input.bool(true, "Power of 3",group=G_ROWS, inline="m")

tablePos = posInput == "Haut Gauche" ? position.top_left : posInput == "Bas Droite" ? position.bottom_right : posInput == "Bas Gauche" ? position.bottom_left : posInput == "Milieu Droite" ? position.middle_right : posInput == "Milieu Gauche" ? position.middle_left : position.top_right
tSize = szInput == "Tiny" ? size.tiny : szInput == "Petite" ? size.small : szInput == "Normale" ? size.normal : szInput == "Grande" ? size.large : size.huge

// ═══════════════════════════════════════════════════════════════════════════════
// 🎯 STYLE DE TRADING — presets automatiques (Manuel = tes réglages individuels)
// ═══════════════════════════════════════════════════════════════════════════════
G_STYLE = "🎯 Style de trading"
tradeStyle = input.string("Manuel", "Préréglage", options=["Manuel", "⚡ Scalping", "☀️ Day Trading", "🌊 Swing"], group=G_STYLE, tooltip="Scalping: graphique 1-5m · Day: 5-15m · Swing: 4h-D.\nManuel = utilise tous tes réglages individuels ci-dessous.\nUn style sélectionné ÉCRASE les réglages concernés.")
bool stM = tradeStyle == "Manuel"
bool stS = tradeStyle == "⚡ Scalping"
bool stD = tradeStyle == "☀️ Day Trading"
// (sinon = 🌊 Swing)
eAgentTF      = stM ? agentTF      : stS ? "15"  : stD ? "60"  : "D"
eTf1          = stM ? tf1          : stS ? "5"   : stD ? "15"  : "240"
eTf2          = stM ? tf2          : stS ? "15"  : stD ? "60"  : "D"
eTf3          = stM ? tf3          : stS ? "60"  : stD ? "240" : "W"
eForecastBars = stM ? forecastBars : stS ? 12    : stD ? 22    : 40
ePivotLen     = stM ? pivotLen     : stS ? 6     : stD ? 11    : 18
eSrMerge      = stM ? srMerge      : stS ? 0.4   : stD ? 0.6   : 0.9
eVpLook       = stM ? vpLook       : stS ? 90    : stD ? 150   : 280
ePatBars      = stM ? patBars      : stS ? 40    : stD ? 80    : 150
eSensitivity  = stM ? sensitivity  : stS ? 1.0   : stD ? 1.5   : 1.8
eMinConf      = stM ? minConf      : stS ? 62    : stD ? 55    : 50
eCndBuy       = stM ? cndBuy       : stS ? 35.0  : stD ? 30.0  : 25.0
eCndStrong    = stM ? cndStrong    : stS ? 65.0  : stD ? 60.0  : 55.0
eStopMult     = stM ? stopMult     : stS ? 1.1   : stD ? 1.5   : 2.2
eDrawZone     = stM ? drawZone     : stS ? 4.0   : stD ? 7.0   : 12.0
eZoneAtr      = stM ? zoneAtr      : stS ? 1.0   : stD ? 1.5   : 2.0
eBbSqLen      = stM ? bbSqLen      : stS ? 60    : stD ? 100   : 120
eWcCandle     = stM ? wcCandle     : stS ? 0.5   : stD ? 1.2   : 2.0
eWcZone       = stM ? wcZone       : stS ? 3.0   : stD ? 2.0   : 1.5
eWcChart      = stM ? wcChart      : stS ? 1.0   : stD ? 1.5   : 2.5
eWcMTF        = stM ? wcMTF        : stS ? 3.0   : stD ? 2.5   : 2.0
eAccWindow    = stM ? accWindow    : stS ? 200   : stD ? 100   : 100
eAmdLen       = stM ? amdLen       : stS ? 20    : stD ? 30    : 45
eWcAMD        = stM ? wcAMD        : stS ? 3.0   : stD ? 2.5   : 2.0

// ═══════════════════════════════════════════════════════════════════════════════
// CALCULS PRINCIPAUX
// ═══════════════════════════════════════════════════════════════════════════════
float emaF  = ta.ema(src, emaFastL)
float emaM  = ta.ema(src, emaMidL)
float emaS  = ta.ema(src, emaSlowL)
float emaT  = ta.ema(src, emaTrendL)
[stVal1, stDir1] = ta.supertrend(stFactor1, stAtr1)
bool upTrend1 = stDir1 < 0
[diP14, diM14, adxV14] = ta.dmi(adxLen, adxLen)
[macdL1, sigL1, histL1] = ta.macd(src, macdFast, macdSlow, macdSig)
float rsiV  = ta.rsi(src, rsiLen)
float rawK  = ta.stoch(close, high, low, stochLen)
float kVal  = ta.sma(rawK, stochK)
float dVal  = ta.sma(kVal, stochD)
float bbBasis = ta.sma(close, bbLen)
float bbDev   = bbMult * ta.stdev(close, bbLen)
float bbUpper = bbBasis + bbDev
float bbLower = bbBasis - bbDev
float bbRange = bbUpper - bbLower > 0 ? bbUpper - bbLower : syminfo.mintick
float bbPos   = (close - bbLower) / bbRange
float atrV    = ta.atr(atrLen)
float atrSafe = atrV > 0 ? atrV : syminfo.mintick
float volMa   = ta.sma(volume, volMaLen)
bool  volOk   = volume > 0 and not na(volMa) and volMa > 0
float volRel  = volOk ? volume / volMa : 1.0
float pvSum   = math.sum(hlc3 * volume, vwapLen)
float vSum    = math.sum(volume, vwapLen)
float rollVwap= vSum > 0 ? pvSum / vSum : na
float lr0     = ta.linreg(close, lenReg, 0)
float lr1     = ta.linreg(close, lenReg, 1)
float slope   = lr0 - lr1
float cciV    = ta.cci(close, cciLen)
float mfiV    = ta.mfi(close, mfiLen)

// ═══════════════════════════════════════════════════════════════════════════════
// LORENTZIAN (1 signal ML décorrélé)
// ═══════════════════════════════════════════════════════════════════════════════
f_rsiL = ta.rsi(close, 14)
f_wt   = ta.ema(hlc3, 10) - ta.sma(ta.ema(hlc3, 10), 4)
f_cciL = ta.cci(close, 20)
feat1 = (f_rsiL - 50) / 50
feat2 = math.max(math.min(f_wt / (ta.stdev(f_wt, 20) > 0 ? ta.stdev(f_wt, 20) : 1), 1), -1)
feat3 = math.max(math.min(f_cciL / 200, 1), -1)
feat4 = (slope / (atrSafe > 0 ? atrSafe : 1)) > 0 ? 1.0 : -1.0
float dd1 = math.log(1+math.abs(feat1-nz(feat1[20],0)))+math.log(1+math.abs(feat2-nz(feat2[20],0)))+math.log(1+math.abs(feat3-nz(feat3[20],0)))+math.log(1+math.abs(feat4-nz(feat4[20],0)))
float dd2 = math.log(1+math.abs(feat1-nz(feat1[40],0)))+math.log(1+math.abs(feat2-nz(feat2[40],0)))+math.log(1+math.abs(feat3-nz(feat3[40],0)))+math.log(1+math.abs(feat4-nz(feat4[40],0)))
float dd3 = math.log(1+math.abs(feat1-nz(feat1[60],0)))+math.log(1+math.abs(feat2-nz(feat2[60],0)))+math.log(1+math.abs(feat3-nz(feat3[60],0)))+math.log(1+math.abs(feat4-nz(feat4[60],0)))
float ff1 = nz(close[10],close) > nz(close[20],close) ? 1.0 : -1.0
float ff2 = nz(close[30],close) > nz(close[40],close) ? 1.0 : -1.0
float ff3 = nz(close[50],close) > nz(close[60],close) ? 1.0 : -1.0
float lorScoreRaw = ff1/(dd1+0.001) + ff2/(dd2+0.001) + ff3/(dd3+0.001)
bool lorBull = lorScoreRaw > 0
bool lorBear = lorScoreRaw < 0

// ── Alias pour le moteur 100 IA ──
emaF_len = emaFastL
emaM_len = emaMidL
emaMD_len = emaSlowL
emaS_len = int(math.round((emaSlowL + emaTrendL) / 2.0))
emaVS_len = emaTrendL
adxSmooth = adxLen
stFactor2 = stFactor1 + 1.0
stAtr2 = stAtr1 + 4

f_agents() =>
    float _rsi2  = ta.rsi(close, 2)
    float _rsi5  = ta.rsi(close, 5)
    float _rsiV  = ta.rsi(close, rsiLen)
    float _rsi7  = ta.rsi(close, 7)
    float _rsi21 = ta.rsi(close, 21)
    float _st9   = ta.stoch(close, high, low, 9)
    float _st14  = ta.stoch(close, high, low, stochLen)
    float _st21  = ta.stoch(close, high, low, 21)
    float _k     = ta.sma(_st14, stochK)
    float _d     = ta.sma(_k, stochD)
    float _cci14 = ta.cci(close, 14)
    float _cciV  = ta.cci(close, cciLen)
    float _cmo14 = ta.cmo(close, 14)
    float _cmo20 = ta.cmo(close, 20)
    float _roc9  = ta.roc(close, 9)
    float _roc14 = ta.roc(close, 14)
    float _roc21 = ta.roc(close, 21)
    float _mom10 = ta.mom(close, 10)
    float _mom20 = ta.mom(close, 20)
    float _mom30 = ta.mom(close, 30)
    float _tsi   = ta.tsi(close, 13, 25)
    float _wpr14 = ta.wpr(14)
    float _wpr21 = ta.wpr(21)
    [_mL1, _sL1, _h1] = ta.macd(close, macdFast, macdSlow, macdSig)
    [_mL2, _sL2, _h2] = ta.macd(close, 8, 17, 9)
    float _emaF  = ta.ema(close, emaF_len)
    float _emaM  = ta.ema(close, emaM_len)
    float _emaMD = ta.ema(close, emaMD_len)
    float _emaS  = ta.ema(close, emaS_len)
    float _emaVS = ta.ema(close, emaVS_len)
    float _sma20 = ta.sma(close, 20)
    float _sma50 = ta.sma(close, 50)
    float _sma100= ta.sma(close, 100)
    float _sma200= ta.sma(close, 200)
    float _sar   = ta.sar(0.02, 0.02, 0.2)
    float _sarA  = ta.sar(0.03, 0.03, 0.3)
    float _lr20  = ta.linreg(close, 20, 0)
    float _lr50  = ta.linreg(close, 50, 0)
    float _slope = ta.linreg(close, lenReg, 0) - ta.linreg(close, lenReg, 1)
    [_dp14, _dm14, _adx14] = ta.dmi(adxLen, adxSmooth)
    [_dp21, _dm21, _adx21] = ta.dmi(21, 21)
    float _wma10 = ta.wma(close, 10)
    float _wma30 = ta.wma(close, 30)
    float _vwma20= ta.vwma(close, 20)
    float _vwma50= ta.vwma(close, 50)
    float _hma20 = ta.hma(close, 20)
    float _hma50 = ta.hma(close, 50)
    float _alma  = ta.alma(close, 20, 0.85, 6)
    float _dema20= 2*ta.ema(close,20)-ta.ema(ta.ema(close,20),20)
    float _dema50= 2*ta.ema(close,50)-ta.ema(ta.ema(close,50),50)
    float _volMa = ta.sma(volume, volMaLen)
    float _obv   = ta.obv
    float _mfi14 = ta.mfi(close, mfiLen)
    float _mfi20 = ta.mfi(close, 20)
    float _accd  = ta.accdist
    float _pvt   = ta.pvt
    float _nvi   = ta.nvi
    float _bbB   = ta.sma(close, bbLen)
    float _bbD   = bbMult * ta.stdev(close, bbLen)
    float _bbU   = _bbB + _bbD
    float _bbL   = _bbB - _bbD
    float _bbRng = _bbU - _bbL > 0 ? _bbU - _bbL : syminfo.mintick
    float _bbPos = (close - _bbL) / _bbRng
    float _bb50u = ta.sma(close,50) + 2.0*ta.stdev(close,50)
    float _atr   = ta.atr(atrLen)
    float _atr20 = ta.atr(20)
    float _dh20  = ta.highest(high, 20)
    float _dl20  = ta.lowest(low, 20)
    float _vwapP = math.sum(hlc3*volume, vwapLen)
    float _vwapV = math.sum(volume, vwapLen)
    float _vwap  = _vwapV > 0 ? _vwapP/_vwapV : na
    [_stv1, _std1] = ta.supertrend(stFactor1, stAtr1)
    [_stv2, _std2] = ta.supertrend(stFactor2, stAtr2)

    int b1  = _rsi2  > 50 ? 1 : 0
    int b2  = _rsi5  > 50 ? 1 : 0
    int b3  = _rsiV  > 55 ? 1 : 0
    int b4  = _rsi7  > 50 ? 1 : 0
    int b5  = _rsi21 > 50 ? 1 : 0
    int b6  = _rsiV  < rsiOS ? 1 : 0
    int b7  = _rsiV  > rsiOB ? 0 : 1
    int b8  = _rsi7  > _rsi21 ? 1 : 0
    int b9  = _st9   > 50 ? 1 : 0
    int b10 = _st21  > 50 ? 1 : 0
    int b11 = _k     > _d ? 1 : 0
    int b12 = _k     > stochOS ? 1 : 0
    int b13 = _st9   > _st21 ? 1 : 0
    int b14 = _k     > 50 ? 1 : 0
    int b15 = _mL1   > _sL1 ? 1 : 0
    int b16 = _h1    > 0 ? 1 : 0
    int b17 = _mL2   > _sL2 ? 1 : 0
    int b18 = _h2    > 0 ? 1 : 0
    int b19 = _mL1   > 0 ? 1 : 0
    int b20 = _h1    > _h1[1] ? 1 : 0
    int b21 = _tsi   > 0 ? 1 : 0
    int b22 = _mL1   > _mL2 ? 1 : 0
    int b23 = _cci14 > 0 ? 1 : 0
    int b24 = _cciV  > 100 ? 1 : 0
    int b25 = _cmo14 > 0 ? 1 : 0
    int b26 = _cmo20 > 0 ? 1 : 0
    int b27 = _roc9  > 0 ? 1 : 0
    int b28 = _roc14 > 0 ? 1 : 0
    int b29 = _roc21 > 0 ? 1 : 0
    int b30 = _mom10 > 0 ? 1 : 0
    int b31 = _mom20 > 0 ? 1 : 0
    int b32 = _mom30 > 0 ? 1 : 0
    int b33 = _wpr14 > -50 ? 1 : 0
    int b34 = _wpr21 > -50 ? 1 : 0
    int b35 = _wpr14 > _wpr21 ? 1 : 0
    int b36 = _emaF  > _emaM  ? 1 : 0
    int b37 = _emaM  > _emaMD ? 1 : 0
    int b38 = _emaMD > _emaS  ? 1 : 0
    int b39 = _emaS  > _emaVS ? 1 : 0
    int b40 = ta.ema(close,9)  > ta.ema(close,21)  ? 1 : 0
    int b41 = ta.ema(close,12) > ta.ema(close,26)  ? 1 : 0
    int b42 = ta.ema(close,20) > ta.ema(close,50)  ? 1 : 0
    int b43 = ta.ema(close,50) > ta.ema(close,100) ? 1 : 0
    int b44 = ta.ema(close,100)> ta.ema(close,200) ? 1 : 0
    int b45 = close > _emaF  ? 1 : 0
    int b46 = close > _emaMD ? 1 : 0
    int b47 = close > _emaVS ? 1 : 0
    int b48 = _sma20  > _sma50  ? 1 : 0
    int b49 = _sma50  > _sma100 ? 1 : 0
    int b50 = _sma100 > _sma200 ? 1 : 0
    int b51 = close   > _sma20  ? 1 : 0
    int b52 = close   > _sma50  ? 1 : 0
    int b53 = close   > _sma200 ? 1 : 0
    int b54 = close > _sar  ? 1 : 0
    int b55 = close > _sarA ? 1 : 0
    int b56 = close > _lr20 ? 1 : 0
    int b57 = close > _lr50 ? 1 : 0
    int b58 = _slope > 0 ? 1 : 0
    int b59 = _dp14  > _dm14 ? 1 : 0
    int b60 = _dp21  > _dm21 ? 1 : 0
    int b61 = _adx14 > adxThresh ? (_dp14 > _dm14 ? 1 : 0) : 0
    int b62 = _wma10  > _wma30  ? 1 : 0
    int b63 = _vwma20 > _vwma50 ? 1 : 0
    int b64 = close   > _hma20  ? 1 : 0
    int b65 = close   > _hma50  ? 1 : 0
    int b66 = _hma20  > _hma50  ? 1 : 0
    int b67 = close   > _alma   ? 1 : 0
    int b68 = _dema20 > _dema50 ? 1 : 0
    int b69 = close   > _dema20 ? 1 : 0
    int b70 = volume > _volMa and close > open ? 1 : 0
    int b71 = volume > ta.sma(volume, 50) ? 1 : 0
    int b72 = (_volMa > 0 ? volume/_volMa : 1) > 1.5 and close > open ? 1 : 0
    int b73 = _obv > ta.sma(_obv, 20) ? 1 : 0
    int b74 = _obv > ta.sma(_obv, 50) ? 1 : 0
    int b75 = _mfi14 > 50 ? 1 : 0
    int b76 = _mfi20 > 50 ? 1 : 0
    int b77 = _mfi14 < 20 ? 1 : 0
    int b78 = _accd > ta.sma(_accd, 20) ? 1 : 0
    int b79 = _pvt  > ta.sma(_pvt, 20) ? 1 : 0
    int b80 = _nvi  > ta.sma(_nvi, 20) ? 1 : 0
    int b81 = na(_vwap) ? 0 : close > _vwap ? 1 : 0
    int b82 = close > _bbU ? 1 : 0
    int b83 = close > _bbB ? 1 : 0
    int b84 = _bbPos > 0.6 ? 1 : 0
    int b85 = close > _bb50u ? 1 : 0
    int b86 = _atr   > ta.sma(_atr, 14) and close > close[1] ? 1 : 0
    int b87 = _atr20 > ta.sma(_atr20, 20) and close > close[1] ? 1 : 0
    int b88 = _std1 < 0 ? 1 : 0
    int b89 = _std2 < 0 ? 1 : 0
    int b90 = close > (_dh20 + _dl20)/2.0 ? 1 : 0
    int b91 = high > ta.highest(high, 10)[1] ? 1 : 0
    int b92 = low  > ta.lowest(low, 10)[1] ? 1 : 0
    int b93 = ta.tr > ta.sma(ta.tr, 14) and close > open ? 1 : 0
    int b94 = close > close[1] ? 1 : 0
    int b95 = (high-low) > 0 and math.abs(close-open)/(high-low) > 0.6 and close > open ? 1 : 0
    int b96 = close > ta.ema(close, 5) ? 1 : 0
    int b97 = ta.ema(close,5) > ta.ema(close,13) ? 1 : 0
    int b98 = _adx14 > adxStrong ? (_dp14 > _dm14 ? 1 : 0) : 0
    int b99 = _sma20 > _sma200 ? 1 : 0
    int b100 = close > ta.highest(high, 5)[1] ? 1 : 0

    int _mom   = b1+b2+b3+b4+b5+b6+b7+b8+b9+b10+b11+b12+b13+b14+b15+b16+b17+b18+b19+b20+b21+b22+b23+b24+b25+b26+b27+b28+b29+b30+b31+b32+b33+b34+b35
    int _trend = b36+b37+b38+b39+b40+b41+b42+b43+b44+b45+b46+b47+b48+b49+b50+b51+b52+b53+b54+b55+b56+b57+b58+b59+b60+b61+b62+b63+b64+b65+b66+b67+b68+b69
    int _vol   = b70+b71+b72+b73+b74+b75+b76+b77+b78+b79+b80+b81+b82+b83+b84+b85
    int _struct= b86+b87+b88+b89+b90+b91+b92+b93+b94+b95+b96+b97+b98+b99+b100
    int _bull  = _mom + _trend + _vol + _struct
    [_bull, _mom, _trend, _vol, _struct]

// Exécution des 100 IA sur le timeframe choisi
aTF = eAgentTF == "" ? timeframe.period : eAgentTF
[bullCount, momBull, trendBull, volBull, structBull] = request.security(syminfo.tickerid, aTF, f_agents(), lookahead=barmerge.lookahead_off)
float confAgents = bullCount / 100.0 * 100.0

// ═══════════════════════════════════════════════════════════════════════════════
// MULTI-TIMEFRAME
// ═══════════════════════════════════════════════════════════════════════════════
f_dir() =>
    e1 = ta.ema(close, 20)
    e2 = ta.ema(close, 50)
    [ml, sl, _h] = ta.macd(close, 12, 26, 9)
    int dd = (close > e1 and e1 > e2 and ml > sl) ? 1 : (close < e1 and e1 < e2 and ml < sl) ? -1 : 0
    dd
int mtf1raw = request.security(syminfo.tickerid, eTf1, f_dir(), lookahead=barmerge.lookahead_off)
int mtf2raw = request.security(syminfo.tickerid, eTf2, f_dir(), lookahead=barmerge.lookahead_off)
int mtf3raw = request.security(syminfo.tickerid, eTf3, f_dir(), lookahead=barmerge.lookahead_off)
int mtf1 = useMTF ? mtf1raw : 0
int mtf2 = useMTF ? mtf2raw : 0
int mtf3 = useMTF ? mtf3raw : 0
int mtfSigned = mtf1 + mtf2 + mtf3

// ═══════════════════════════════════════════════════════════════════════════════
// RÉGIME
// ═══════════════════════════════════════════════════════════════════════════════
float hhc = ta.highest(high, 14)
float llc = ta.lowest(low, 14)
float atrSum = math.sum(ta.tr, 14)
float chop = (hhc - llc) > 0 ? 100 * math.log10(atrSum / (hhc - llc)) / math.log10(14) : 50
bool isTrending = adxV14 >= adxThresh and chop < 50
string regimeTxt = adxV14 >= adxStrong and chop < 38 ? "TENDANCE FORTE" : isTrending ? "TENDANCE" : chop > 61 ? "RANGE" : "TRANSITION"

// ═══════════════════════════════════════════════════════════════════════════════
// VOLUME PROFILE (POC / VAH / VAL) — calculé sur la dernière barre
// ═══════════════════════════════════════════════════════════════════════════════
f_vp(int lb, int bins, float vaPct) =>
    float hi = ta.highest(high, lb)
    float lo = ta.lowest(low, lb)
    float stepv = (hi - lo) / bins
    array<float> vols = array.new<float>(bins, 0.0)
    if stepv > 0
        for i = 0 to lb - 1
            float p = hlc3[i]
            int bx = int(math.floor((p - lo) / stepv))
            bx := math.max(0, math.min(bins - 1, bx))
            array.set(vols, bx, array.get(vols, bx) + volume[i])
    int pocIdx = 0
    float pocVol = 0.0
    for i = 0 to bins - 1
        if array.get(vols, i) > pocVol
            pocVol := array.get(vols, i)
            pocIdx := i
    float poc = lo + (pocIdx + 0.5) * stepv
    float totVol = array.sum(vols)
    float tgt = totVol * vaPct / 100.0
    float acc = array.get(vols, pocIdx)
    int up = pocIdx
    int dn = pocIdx
    for i = 0 to bins
        if acc >= tgt
            break
        float vUp = up < bins - 1 ? array.get(vols, up + 1) : -1.0
        float vDn = dn > 0 ? array.get(vols, dn - 1) : -1.0
        if vUp < 0 and vDn < 0
            break
        if vUp >= vDn
            up += 1
            acc += (vUp > 0 ? vUp : 0.0)
        else
            dn -= 1
            acc += (vDn > 0 ? vDn : 0.0)
    float vah = lo + (up + 1) * stepv
    float val = lo + dn * stepv
    [poc, vah, val]

float vpPOC = na
float vpVAH = na
float vpVAL = na
if barstate.islast and showVP
    [p, h, l] = f_vp(eVpLook, vpBins, vpVA)
    vpPOC := p
    vpVAH := h
    vpVAL := l

// Direction Volume Profile : prix vs POC
int vpDir = na(vpPOC) ? 0 : close > vpPOC ? 1 : close < vpPOC ? -1 : 0

// ═══════════════════════════════════════════════════════════════════════════════
// SCORE TENDANCE (modules classiques pondérés)
// ═══════════════════════════════════════════════════════════════════════════════
float dz = 0.15 * atrSafe
int sEma   = src > emaS + dz and emaF > emaM and emaM > emaS ? 1 : src < emaS - dz and emaF < emaM and emaM < emaS ? -1 : 0
int sSt    = upTrend1 ? 1 : -1
int sAdx   = adxV14 >= adxThresh ? (diP14 > diM14 ? 1 : -1) : 0
int sMacd  = macdL1 > sigL1 and histL1 > 0 ? 1 : macdL1 < sigL1 and histL1 < 0 ? -1 : 0
int sRsi   = rsiV > 55 ? 1 : rsiV < 45 ? -1 : 0
int sStoch = kVal > dVal and kVal > stochOS ? 1 : kVal < dVal and kVal < stochOB ? -1 : 0
int sVol   = volOk and volume > volMa * 1.2 ? (close > open ? 1 : -1) : 0
int sVwap  = na(rollVwap) ? 0 : close > rollVwap + dz ? 1 : close < rollVwap - dz ? -1 : 0
int sMfi   = mfiV > 50 ? 1 : mfiV < 50 ? -1 : 0
// Bollinger adaptatif au régime (planche : rebond aux bandes en range, continuation en tendance)
int sBB = isTrending ? (close > bbBasis ? 1 : close < bbBasis ? -1 : 0) : (low <= bbLower ? 1 : high >= bbUpper ? -1 : 0)
float bbW = bbBasis > 0 ? (bbUpper - bbLower) / bbBasis * 100.0 : 0.0
bool bbSqueeze = bbW <= ta.lowest(bbW, eBbSqLen) * 1.02
// Intensité de la bougie (planche « niveaux d'intensité ») : corps signé en ATR
float candleIntensity = (close - open) / atrSafe
string intensTxt = math.abs(candleIntensity) >= 1.2 ? "FORTE" : math.abs(candleIntensity) >= 0.6 ? "Moyenne" : "Faible"
float scoreTrend = (sEma*3 + sSt*3 + sAdx*2.5 + sMacd*2 + sRsi*1.5 + sStoch*1.5 + sVol*1.5 + sVwap*1.5 + sMfi*1.0 + sBB*1.5) / 19.0 * 100.0

// ═══════════════════════════════════════════════════════════════════════════════
// CONNEXION ENTRE LES 100 IA (cohérence inter-blocs)
// ═══════════════════════════════════════════════════════════════════════════════
int blkMom = momBull > 17 ? 1 : momBull < 18 ? -1 : 0
int blkTrd = trendBull > 17 ? 1 : -1
int blkVol = volBull > 8 ? 1 : -1
int blkStr = structBull > 7 ? 1 : -1
int blkBull = (blkMom > 0 ? 1 : 0) + (blkTrd > 0 ? 1 : 0) + (blkVol > 0 ? 1 : 0) + (blkStr > 0 ? 1 : 0)
int blkAlign = math.max(blkBull, 4 - blkBull)
float iaConnection = blkAlign / 4.0 * 100.0

// ═══════════════════════════════════════════════════════════════════════════════
// SUPPORT / RÉSISTANCE — niveaux fusionnés, coloration dynamique
// ═══════════════════════════════════════════════════════════════════════════════
float ph = ta.pivothigh(high, ePivotLen, ePivotLen)
float pl = ta.pivotlow(low,  ePivotLen, ePivotLen)
float recentHi = ta.highest(high, 50)
float recentLo = ta.lowest(low, 50)
float mergeTol = atrSafe * eSrMerge

var array<float> srP = array.new<float>()
var array<line>  srL = array.new<line>()

// Ajout d'un niveau (fusion si proche d'un existant)
if showSR and (not na(ph) or not na(pl))
    float px = not na(ph) ? ph : pl
    bool near = false
    if array.size(srP) > 0
        for i = 0 to array.size(srP) - 1
            if math.abs(array.get(srP, i) - px) <= mergeTol
                near := true
    if not near
        line ln = line.new(bar_index - ePivotLen, px, bar_index, px, color=color.new(colNeutral, 20), width=srWidth, extend=extend.right)
        array.push(srP, px)
        array.push(srL, ln)
        if array.size(srP) > srMax
            array.shift(srP)
            line.delete(array.shift(srL))

// Recolore les niveaux selon leur rôle (au-dessus = résistance, en dessous = support)
if barstate.islast and array.size(srL) > 0
    for i = 0 to array.size(srL) - 1
        float lv = array.get(srP, i)
        line.set_color(array.get(srL, i), lv >= close ? color.new(colResL, 0) : color.new(colSupL, 0))

if not showSR and array.size(srL) > 0
    for i = 0 to array.size(srL) - 1
        line.delete(array.get(srL, i))
    array.clear(srL)
    array.clear(srP)

// Niveaux clés R1 (résistance la plus proche) / S1 (support le plus proche)
float R1 = recentHi
float S1 = recentLo
if array.size(srP) > 0
    float bestR = na
    float bestS = na
    for i = 0 to array.size(srP) - 1
        float lv = array.get(srP, i)
        if lv > close and (na(bestR) or lv < bestR)
            bestR := lv
        if lv < close and (na(bestS) or lv > bestS)
            bestS := lv
    R1 := not na(bestR) ? bestR : recentHi
    S1 := not na(bestS) ? bestS : recentLo
R1 := math.max(R1, close + atrSafe * 0.25)
S1 := math.min(S1, close - atrSafe * 0.25)
bool brokeR = close > R1 and close[1] <= R1
bool brokeS = close < S1 and close[1] >= S1

// Fonction de plafonnement — bande réglable (zoom chandelles)
f_cd(float v) =>
    float lim = close * eDrawZone / 100.0
    math.max(close - lim, math.min(close + lim, v))

// ═══════════════════════════════════════════════════════════════════════════════
// FIGURES DE RETOURNEMENT (double sommet/creux, épaule-tête-épaule)
// ═══════════════════════════════════════════════════════════════════════════════
revTol   = input.float(0.5, "Tolérance figures (×ATR)", minval=0.1, maxval=3.0, step=0.1, group=G_PAT)
showRev  = input.bool(true, "Détecter figures de retournement", group=G_PAT)
float rTol = atrSafe * revTol * 3

// Mémoire des 3 derniers sommets et creux
var float H1 = na
var float H2 = na
var float H3 = na
var float L1 = na
var float L2 = na
var float L3 = na
if not na(ph)
    H3 := H2
    H2 := H1
    H1 := ph
if not na(pl)
    L3 := L2
    L2 := L1
    L1 := pl

// Double sommet : 2 sommets proches + cassure du creux entre eux (baissier)
bool dblTop = not na(H2) and not na(L1) and math.abs(H1 - H2) <= rTol and H1 > L1 and H2 > L1 and close < L1 and close[1] >= L1
// Double creux : 2 creux proches + cassure du sommet entre eux (haussier)
bool dblBot = not na(L2) and not na(H1) and math.abs(L1 - L2) <= rTol and L1 < H1 and L2 < H1 and close > H1 and close[1] <= H1
// Épaule-tête-épaule : tête (H2) plus haute, épaules (H1,H3) proches + cassure neckline (baissier)
bool hns = not na(H3) and H2 > H1 and H2 > H3 and math.abs(H1 - H3) <= rTol and not na(L1) and close < L1 and close[1] >= L1
// ETE inversé : creux central (L2) plus bas, épaules (L1,L3) proches + cassure (haussier)
bool ihns = not na(L3) and L2 < L1 and L2 < L3 and math.abs(L1 - L3) <= rTol and not na(H1) and close > H1 and close[1] <= H1
// 3 Drives : trois sommets/creux quasi égaux + cassure (planche 16 patterns)
bool drive3T = not na(H3) and math.abs(H1 - H2) <= rTol and math.abs(H2 - H3) <= rTol and not na(L1) and close < L1 and close[1] >= L1
bool drive3B = not na(L3) and math.abs(L1 - L2) <= rTol and math.abs(L2 - L3) <= rTol and not na(H1) and close > H1 and close[1] <= H1
// Diamant : extrême central dans les DEUX sens (expansion puis contraction) + cassure directionnelle
bool diamCore = not na(H3) and not na(L3) and H2 > H1 + rTol * 0.5 and H2 > H3 + rTol * 0.5 and L2 < L1 - rTol * 0.5 and L2 < L3 - rTol * 0.5
bool diamT = diamCore and close < L1 and close[1] >= L1
bool diamB = diamCore and close > H1 and close[1] <= H1
// Sommet/creux arrondi : courbure de l'EMA (dérivée seconde) — approximation
float curvE = emaM - 2 * nz(emaM[10], emaM) + nz(emaM[20], emaM)
bool roundTraw = curvE < -atrSafe * 0.25 and nz(emaM[10], emaM) > nz(emaM[20], emaM) and emaM < nz(emaM[10], emaM)
bool roundBraw = curvE > atrSafe * 0.25 and nz(emaM[10], emaM) < nz(emaM[20], emaM) and emaM > nz(emaM[10], emaM)
bool roundT = roundTraw and not roundTraw[1]
bool roundB = roundBraw and not roundBraw[1]

string revName = diamT ? "Diamant sommet" : diamB ? "Diamant creux" : drive3T ? "3 Drives ▼" : drive3B ? "3 Drives ▲" : hns ? "Épaule-Tête-Épaule" : ihns ? "ETE inversé" : dblTop ? "Double sommet" : dblBot ? "Double creux" : roundT ? "Sommet arrondi" : roundB ? "Creux arrondi" : ""
int revDir = (diamB or drive3B or ihns or dblBot or roundB) ? 1 : (diamT or drive3T or hns or dblTop or roundT) ? -1 : 0
var int lastRevDir = 0
var string lastRevName = "—"
var int revAge = 999
if revName != ""
    lastRevDir := revDir
    lastRevName := revName
    revAge := 0
else
    revAge := revAge + 1
int revSig = revAge <= 5 ? lastRevDir : 0

// ═══════════════════════════════════════════════════════════════════════════════
// FIGURES CHARTISTES (triangles, biseaux, rectangle, drapeaux) — style Wealthsimple
// ═══════════════════════════════════════════════════════════════════════════════
float cTol = atrSafe * revTol * 2
bool hFlat  = not na(H2) and math.abs(H1 - H2) <= cTol
bool lFlat  = not na(L2) and math.abs(L1 - L2) <= cTol
bool hRise  = not na(H2) and H1 > H2 + cTol
bool hFall  = not na(H2) and H1 < H2 - cTol
bool lRise  = not na(L2) and L1 > L2 + cTol
bool lFall  = not na(L2) and L1 < L2 - cTol
bool haveHL = not na(H1) and not na(L1) and not na(H2) and not na(L2)
bool converging = haveHL and (H1 - L1) < (H2 - L2)

// Impulsion récente (pour drapeaux) : mouvement > 4 ATR sur 15 barres
float roc15 = close - nz(close[15], close)
bool impUp = roc15 > atrSafe * 4
bool impDn = roc15 < -atrSafe * 4

bool triAsc  = haveHL and hFlat and lRise and close > H1 and close[1] <= H1
bool triDesc = haveHL and lFlat and hFall and close < L1 and close[1] >= L1
bool triSymU = haveHL and hFall and lRise and close > H1 and close[1] <= H1
bool triSymD = haveHL and hFall and lRise and close < L1 and close[1] >= L1
bool rectU   = haveHL and hFlat and lFlat and close > H1 and close[1] <= H1
bool rectD   = haveHL and hFlat and lFlat and close < L1 and close[1] >= L1
bool wedgeR  = haveHL and hRise and lRise and converging and close < L1 and close[1] >= L1
bool wedgeF  = haveHL and hFall and lFall and converging and close > H1 and close[1] <= H1
bool flagB   = impUp and haveHL and hFall and lFall and close > H1 and close[1] <= H1
bool flagS   = impDn and haveHL and hRise and lRise and close < L1 and close[1] >= L1
// Fanion (Pennant) : impulsion + petite consolidation CONVERGENTE (≠ drapeau qui est un canal parallèle)
bool pennantB = impUp and haveHL and hFall and lRise and close > H1 and close[1] <= H1
bool pennantS = impDn and haveHL and hFall and lRise and close < L1 and close[1] >= L1

string chartName = flagB ? "Drapeau haussier" : flagS ? "Drapeau baissier" : pennantB ? "Fanion haussier" : pennantS ? "Fanion baissier" : triAsc ? "Triangle ascendant" : triDesc ? "Triangle descendant" : wedgeF ? "Biseau descendant" : wedgeR ? "Biseau ascendant" : rectU ? "Rectangle (haut)" : rectD ? "Rectangle (bas)" : triSymU ? "Triangle sym. ▲" : triSymD ? "Triangle sym. ▼" : ""
int chartDir = (flagB or pennantB or triAsc or wedgeF or rectU or triSymU) ? 1 : (flagS or pennantS or triDesc or wedgeR or rectD or triSymD) ? -1 : 0
var string lastChartName = "—"
var int lastChartDir = 0
var int chartAge = 999
if chartName != ""
    lastChartName := chartName
    lastChartDir := chartDir
    chartAge := 0
else
    chartAge := chartAge + 1
int chartSig = chartAge <= 5 ? lastChartDir : 0

// ═══════════════════════════════════════════════════════════════════════════════
// ZONE DEMANDE / OFFRE (concept planche 2 : pattern PRÈS du niveau = confirmation)
// ═══════════════════════════════════════════════════════════════════════════════
bool nearSup = (close - S1) <= atrSafe * eZoneAtr
bool nearRes = (R1 - close) <= atrSafe * eZoneAtr


// ═══════════════════════════════════════════════════════════════════════════════
// PATTERNS DE CHANDELIER (all-in-one) — détection
// ═══════════════════════════════════════════════════════════════════════════════
float pBody = math.abs(close - open)
float pRng  = high - low
float pUp   = high - math.max(close, open)
float pLo   = math.min(close, open) - low
float pAvg  = ta.sma(pBody, 14)
bool pBull = close > open
bool pBear = close < open
bool cDoji     = pRng > 0 and pBody <= pRng * 0.1
bool cHammer   = pBody > 0 and pLo >= pBody * 2 and pUp <= pBody * 0.6 and pBull
bool cInvHam   = pBody > 0 and pUp >= pBody * 2 and pLo <= pBody * 0.6 and pBull
bool cShoot    = pBody > 0 and pUp >= pBody * 2 and pLo <= pBody * 0.6 and pBear
bool cBullMaru = pBull and pRng > 0 and pUp <= pRng * 0.05 and pLo <= pRng * 0.05 and pBody > pAvg
bool cBearMaru = pBear and pRng > 0 and pUp <= pRng * 0.05 and pLo <= pRng * 0.05 and pBody > pAvg
bool cBullEng  = pBull and close[1] < open[1] and close >= open[1] and open <= close[1]
bool cBearEng  = pBear and close[1] > open[1] and close <= open[1] and open >= close[1]
bool cPierce   = pBull and close[1] < open[1] and open <= low[1] and close > (open[1]+close[1])/2 and close < open[1]
bool cDark     = pBear and close[1] > open[1] and open >= high[1] and close < (open[1]+close[1])/2 and close > open[1]
bool cMorning  = close[2] < open[2] and math.abs(close[1]-open[1]) < pAvg*0.6 and pBull and close > (open[2]+close[2])/2
bool cEvening  = close[2] > open[2] and math.abs(close[1]-open[1]) < pAvg*0.6 and pBear and close < (open[2]+close[2])/2
bool cTweezTop = math.abs(high - high[1]) <= atrSafe*0.1 and pBear and close[1] > open[1]
bool cTweezBot = math.abs(low - low[1]) <= atrSafe*0.1 and pBull and close[1] < open[1]
bool c3White   = pBull and close[1]>open[1] and close[2]>open[2] and close>close[1] and close[1]>close[2] and open<close[1] and open>open[1]
bool c3Black   = pBear and close[1]<open[1] and close[2]<open[2] and close<close[1] and close[1]<close[2] and open>close[1] and open<open[1]

// ── Nouveaux chandeliers v9 (planches D-Trading + confirmation) ──
bool cPinBar   = pRng > 0 and pLo >= pRng * 0.66 and pBody <= pRng * 0.3 and math.min(close, open) >= low + pRng * 0.55
bool cDblPin   = cPinBar and pRng[1] > 0 and pLo[1] >= pRng[1] * 0.5
bool cHaramiB  = pBull and close[1] < open[1] and math.max(close, open) <= open[1] and math.min(close, open) >= close[1] and pBody < pBody[1]
bool cHaramiS  = pBear and close[1] > open[1] and math.max(close, open) <= close[1] and math.min(close, open) >= open[1] and pBody < pBody[1]
bool cHangMan  = pBody > 0 and pLo >= pBody * 2 and pUp <= pBody * 0.6 and pBear and close > emaM
bool cGapUp    = low > high[1] and pBull and close[2] < open[2]
bool cGapDn    = high < low[1] and pBear and close[2] > open[2]
bool cRise3    = close[4] > open[4] and (close[4] - open[4]) > pAvg and pBull and close > close[4] and high[1] <= high[4] and high[2] <= high[4] and high[3] <= high[4] and low[1] >= low[4] and low[2] >= low[4] and low[3] >= low[4]
bool cFall3    = close[4] < open[4] and (open[4] - close[4]) > pAvg and pBear and close < close[4] and high[1] <= high[4] and high[2] <= high[4] and high[3] <= high[4] and low[1] >= low[4] and low[2] >= low[4] and low[3] >= low[4]
bool midDoji   = (high[1] - low[1]) > 0 and math.abs(close[1] - open[1]) <= (high[1] - low[1]) * 0.1
bool cMornDoji = cMorning and midDoji
bool cEveDoji  = cEvening and midDoji

// Un pattern prioritaire par barre + direction (priorité : multi-bougies fortes → simples)
string patName = cRise3 ? "3 Méthodes ▲" : cFall3 ? "3 Méthodes ▼" : cMornDoji ? "Morning Doji★" : cEveDoji ? "Evening Doji★" : cBullEng ? "Engl+" : cBearEng ? "Engl-" : cMorning ? "Morning★" : cEvening ? "Evening★" : c3White ? "3 Soldats" : c3Black ? "3 Corbeaux" : cHaramiB ? "Harami+" : cHaramiS ? "Harami-" : cPierce ? "Perçant" : cDark ? "Nuage noir" : cGapUp ? "Gap haussier" : cGapDn ? "Gap baissier" : cTweezBot ? "Pince bas" : cTweezTop ? "Pince haut" : cDblPin ? "Double Pin Bar" : cPinBar ? "Pin Bar" : cHangMan ? "Pendu" : cHammer ? "Marteau" : cShoot ? "Ét.filante" : cInvHam ? "Marteau inv" : cBullMaru ? "Marubozu+" : cBearMaru ? "Marubozu-" : cDoji ? "Doji" : ""
int patDir = (cRise3 or cMornDoji or cBullEng or cMorning or c3White or cHaramiB or cPierce or cGapUp or cTweezBot or cDblPin or cPinBar or cHammer or cInvHam or cBullMaru) ? 1 : (cFall3 or cEveDoji or cBearEng or cEvening or c3Black or cHaramiS or cDark or cGapDn or cTweezTop or cHangMan or cShoot or cBearMaru) ? -1 : 0

// Influence sur quelques barres (mémoire courte)
var int lastPatDir = 0
var string lastPatName = "—"
var int patAge = 999
if patName != ""
    lastPatDir := patDir
    lastPatName := patName
    patAge := 0
else
    patAge := patAge + 1
int candleSig = patAge <= 3 ? lastPatDir : 0

// Confirmation en zone (planche 2) : pattern chandelier haussier PRÈS du support = achat renforcé
int zoneSig = candleSig > 0 and nearSup ? 1 : candleSig < 0 and nearRes ? -1 : 0

// ═══════════════════════════════════════════════════════════════════════════════
// ⚡ POWER OF THREE (AMD) — Accumulation · Manipulation · Distribution
// ═══════════════════════════════════════════════════════════════════════════════
var int amdState = 0
var float amdTop = na
var float amdBot = na
var int amdDir = 0
var int amdT0 = 0
var int amdTsw = 0
var float amdExt = na
var int amdWait = 0
float amdHH = ta.highest(high, eAmdLen)
float amdLL = ta.lowest(low, eAmdLen)
bool amdTight = (amdHH - amdLL) <= atrSafe * amdRangeMult

int amdSig = 0
string amdStateTxt = "—"
if showAMD
    if amdState == 0
        amdStateTxt := "recherche range"
        if amdTight
            amdState := 1
            amdTop := amdHH
            amdBot := amdLL
            amdT0 := bar_index - eAmdLen + 1
    else if amdState == 1
        amdStateTxt := "Accumulation"
        bool swLow  = low < amdBot and close > amdBot
        bool swHigh = high > amdTop and close < amdTop
        if swLow or swHigh
            amdState := 2
            amdDir := swLow ? 1 : -1
            amdTsw := bar_index
            amdExt := swLow ? low : high
            amdWait := 0
        else if close > amdTop or close < amdBot
            amdState := 0
    else
        amdWait += 1
        amdStateTxt := "Manipulation " + (amdDir > 0 ? "▲?" : "▼?")
        bool distUp = amdDir > 0 and close > amdTop
        bool distDn = amdDir < 0 and close < amdBot
        bool amdFail = (amdDir > 0 and close < amdExt) or (amdDir < 0 and close > amdExt) or amdWait > amdMaxWait
        if distUp or distDn
            amdSig := amdDir
            amdState := 0
        else if amdFail
            amdState := 0

// Mémoire du signal (alimente le conducteur pendant 8 barres)
var int lastAmdDir = 0
var int amdAge = 999
if amdSig != 0
    lastAmdDir := amdSig
    amdAge := 0
else
    amdAge += 1
int amdActive = amdAge <= 8 ? lastAmdDir : 0

// Boîtes Accumulation (jaune) + Manipulation (rose) + étiquette Distribution
var array<box> amdBoxes = array.new<box>()
if amdSig != 0 and showAMD
    box bA = box.new(amdT0, amdTop, amdTsw, amdBot, bgcolor=color.new(colAccu, 82), border_color=color.new(colAccu, 45))
    box bM = box.new(amdTsw - 1, amdDir > 0 ? amdBot : amdExt, bar_index - 1, amdDir > 0 ? amdExt : amdTop, bgcolor=color.new(colManip, 78), border_color=color.new(colManip, 40))
    array.push(amdBoxes, bA)
    array.push(amdBoxes, bM)
    if array.size(amdBoxes) > 10
        box.delete(array.shift(amdBoxes))
        box.delete(array.shift(amdBoxes))
    label.new(bar_index, amdDir > 0 ? low : high, "⚡ AMD " + (amdDir > 0 ? "▲ Distribution" : "▼ Distribution"), style=amdDir > 0 ? label.style_label_up : label.style_label_down, color=amdDir > 0 ? color.new(colDistr, 0) : color.new(colManip, 0), textcolor=color.black, size=size.small)


float cTrend  = scoreTrend / 100.0
float cAgents = (confAgents - 50.0) / 50.0
float cMTF    = useMTF ? mtfSigned / 3.0 : 0.0
float cVP     = vpDir
float cLor    = lorBull ? 1.0 : lorBear ? -1.0 : 0.0
float cCandle = candleSig
float cRev    = revSig
float cChart  = chartSig
float cZone   = zoneSig
float cAMD    = amdActive
float cWsum   = wcTrend + wcAgents + eWcMTF + wcVP + wcLor + eWcCandle + wcRev + eWcChart + eWcZone + eWcAMD
float conductor = cWsum > 0 ? (cTrend*wcTrend + cAgents*wcAgents + cMTF*eWcMTF + cVP*wcVP + cLor*wcLor + cCandle*eWcCandle + cRev*wcRev + cChart*eWcChart + cZone*eWcZone + cAMD*eWcAMD) / cWsum * 100.0 : 0.0

int cdir = conductor > 0 ? 1 : conductor < 0 ? -1 : 0
int agree = 0
agree := agree + (math.sign(cTrend) == cdir and cdir != 0 ? 1 : 0)
agree := agree + (math.sign(cAgents) == cdir and cdir != 0 ? 1 : 0)
agree := agree + ((mtfSigned > 0 ? 1 : mtfSigned < 0 ? -1 : 0) == cdir and cdir != 0 ? 1 : 0)
agree := agree + (vpDir == cdir and cdir != 0 ? 1 : 0)
agree := agree + ((lorBull ? 1 : lorBear ? -1 : 0) == cdir and cdir != 0 ? 1 : 0)
agree := agree + (candleSig == cdir and cdir != 0 ? 1 : 0)
agree := agree + (revSig == cdir and cdir != 0 ? 1 : 0)
agree := agree + (chartSig == cdir and cdir != 0 ? 1 : 0)

// Confiance calibrée (R² + accord IA + MTF + connexion inter-blocs + régime)
float corrR = ta.correlation(close, bar_index, lenReg)
float r2 = nz(corrR * corrR, 0.0)
float agentExtremity = math.abs(confAgents - 50.0) / 50.0
float mtfFrac = useMTF ? math.abs(mtfSigned) / 3.0 : 0.0
float regimeClarity = math.min(adxV14 / 50.0, 1.0)
float connFrac = (iaConnection - 50.0) / 50.0
// Confluence pattern-zone : chandelier + figure + zone qui pointent avec la décision
float patConf = (candleSig == cdir and cdir != 0 ? 0.3 : 0.0) + (chartSig == cdir and cdir != 0 ? 0.25 : 0.0) + (zoneSig == cdir and cdir != 0 ? 0.25 : 0.0) + (amdActive == cdir and cdir != 0 ? 0.2 : 0.0)
float finalConf = math.round(100.0 * (0.22*agentExtremity + 0.22*r2 + 0.18*mtfFrac + 0.13*math.max(connFrac,0) + 0.13*regimeClarity + 0.12*patConf))
bool confOK = finalConf >= eMinConf

string verdict = ""
color verdictCol = colNeutral
string vEmoji = "➡️"
if conductor >= eCndStrong
    verdict := "ACHAT FORT"
    verdictCol := colStrongBull
    vEmoji := "🚀"
else if conductor >= eCndBuy
    verdict := "ACHAT"
    verdictCol := colBull
    vEmoji := "📈"
else if conductor > -eCndBuy
    verdict := "NEUTRE / ATTENDRE"
    verdictCol := colNeutral
    vEmoji := "➡️"
else if conductor > -eCndStrong
    verdict := "VENTE"
    verdictCol := colBear
    vEmoji := "📉"
else
    verdict := "VENTE FORTE"
    verdictCol := colStrongBear
    vEmoji := "🔻"

string sizeTxt = finalConf >= 70 and agree >= 6 ? "Pleine (selon TON risque)" : finalConf >= 55 and agree >= 5 ? "Demi-position" : finalConf >= 40 ? "Quart / prudence" : "Attendre"

// ═══════════════════════════════════════════════════════════════════════════════
// PROJECTION
// ═══════════════════════════════════════════════════════════════════════════════
float rsiScore  = (rsiV - 50.0) / 50.0
float macdScore = math.max(math.min(histL1 / atrSafe, 1.0), -1.0)
float bbScore   = (bbPos - 0.5) * 2.0
float slopeScore = math.max(math.min(slope / atrSafe * 5.0, 1.0), -1.0)
float momentum  = rsiScore*0.25 + macdScore*0.25 + bbScore*0.15 + slopeScore*0.20 + cAgents*0.15
float adjMom    = math.max(math.min(momentum * eSensitivity, 3.0), -3.0)
float trendTarget = lr0 + slope * eForecastBars + adjMom * atrSafe * math.sqrt(float(eForecastBars))
float rangeMid    = (ta.highest(high, 20) + ta.lowest(low, 20)) / 2.0
float predicted   = isTrending ? trendTarget : close + (rangeMid - close) * 0.5
float bandFactor  = 2.2 - r2
float coneW       = atrSafe * math.sqrt(float(eForecastBars)) * bandFactor
float predUpper   = predicted + coneW
float predLower   = predicted - coneW
float changePct   = close != 0 ? (predicted - close) / close * 100.0 : 0.0
bool  bullish     = predicted > close
color dirCol      = bullish ? colStrongBull : colStrongBear


// ═══════════════════════════════════════════════════════════════════════════════
// PRÉCISION LIVE (auto-backtest)
// ═══════════════════════════════════════════════════════════════════════════════
int evalH = eForecastBars
bool canEval = bar_index > evalH
int projHit = canEval ? (bullish[evalH] == (close > close[evalH]) ? 1 : 0) : 0
int projVal = canEval ? 1 : 0
float accSum = math.sum(projHit, eAccWindow)
float accCnt = math.sum(projVal, eAccWindow)
float projAcc = accCnt > 0 ? accSum / accCnt * 100.0 : na
int cDirH = conductor > 0 ? 1 : conductor < 0 ? -1 : 0
bool cEval = bar_index > evalH and cDirH[evalH] != 0
int cHit = cEval ? ((cDirH[evalH] == 1 and close > close[evalH]) or (cDirH[evalH] == -1 and close < close[evalH]) ? 1 : 0) : 0
int cVal = cEval ? 1 : 0
float cAccSum = math.sum(cHit, eAccWindow)
float cAccCnt = math.sum(cVal, eAccWindow)
float condAcc = cAccCnt > 0 ? cAccSum / cAccCnt * 100.0 : na

// ═══════════════════════════════════════════════════════════════════════════════
// ENTRÉE / STOP / CIBLE
// ═══════════════════════════════════════════════════════════════════════════════
float tEntry  = close
float tStop   = bullish ? close - atrSafe * eStopMult : close + atrSafe * eStopMult
float tTarget = bullish ? (R1 > close ? R1 : predicted) : (S1 < close ? S1 : predicted)
float rrNum = math.abs(tTarget - tEntry)
float rrDen = math.abs(tEntry - tStop)
float rrRatio = rrDen > 0 ? rrNum / rrDen : 0.0

string planAction = conductor >= eCndStrong ? "🟢 ACHETER (signal fort)" : conductor >= eCndBuy ? "🟢 Acheter / surveiller" : conductor > -eCndBuy ? "⚪ ATTENDRE" : conductor > -eCndStrong ? "🔴 Vendre / surveiller" : "🔴 VENDRE (signal fort)"

// ═══════════════════════════════════════════════════════════════════════════════
// VISUALISATION GRAPHIQUE
// ═══════════════════════════════════════════════════════════════════════════════
plot(showEma ? emaF : na, "EMA rapide",  color=colEmaFast, linewidth=1)
plot(showEma ? emaM : na, "EMA moyenne", color=colEmaMid, linewidth=1)
plot(showEma ? emaS : na, "EMA lente",   color=colEmaSlow, linewidth=2)
plot(showEma ? emaT : na, "EMA tendance",color=color.new(colEmaTrend, 30), linewidth=2)
plot(showVwap ? rollVwap : na, "VWAP", color=colVwapL, linewidth=1)
pBBu = plot(showBB ? bbUpper : na, "Bollinger haut", color=color.new(colBBL, 45), linewidth=1)
pBBl = plot(showBB ? bbLower : na, "Bollinger bas",  color=color.new(colBBL, 45), linewidth=1)
plot(showBB ? bbBasis : na, "Bollinger 20SMA", color=color.new(colBBL, 25), linewidth=1)
fill(pBBu, pBBl, color=color.new(colBBL, 96), title="Zone Bollinger")
plot(showSt and upTrend1 ? stVal1 : na, "ST▲", color=color.new(colBull, 0), linewidth=2, style=plot.style_linebr)
plot(showSt and not upTrend1 ? stVal1 : na, "ST▼", color=color.new(colBear, 0), linewidth=2, style=plot.style_linebr)

// Coloration quantique des bougies (selon la décision)
color qbar = conductor >= eCndStrong ? colStrongBull : conductor >= eCndBuy ? colBull : conductor > -eCndBuy ? colNeutral : conductor > -eCndStrong ? colBear : colStrongBear
barcolor(useQBars ? qbar : na, title="Bougies quantiques")

// Fond dynamique : plus opaque quand la confiance est haute
bgcolor(showBg ? (useQBg ? color.new(verdictCol, int(math.max(60, 92 - finalConf / 4))) : color.new(verdictCol, 90)) : na, title="Fond")

// ── Volume Profile (lignes POC / VAH / VAL) ──
var line lnPOC = na
var line lnVAH = na
var line lnVAL = na
var label lbPOC = na
var label lbVAH = na
var label lbVAL = na
if barstate.islast
    line.delete(lnPOC)
    line.delete(lnVAH)
    line.delete(lnVAL)
    label.delete(lbPOC)
    label.delete(lbVAH)
    label.delete(lbVAL)
    if showVP and not na(vpPOC)
        int xa = bar_index - eVpLook
        int xb = bar_index + 10
        lnPOC := line.new(xa, vpPOC, xb, vpPOC, color=colPOCL, width=2)
        lnVAH := line.new(xa, vpVAH, xb, vpVAH, color=color.new(#9598a1, 30), width=1, style=line.style_dashed)
        lnVAL := line.new(xa, vpVAL, xb, vpVAL, color=color.new(#9598a1, 30), width=1, style=line.style_dashed)
        lbPOC := label.new(xb, vpPOC, "POC " + str.tostring(vpPOC, format.mintick), style=label.style_label_left, color=colPOCL, textcolor=color.black, size=size.small)
        lbVAH := label.new(xb, vpVAH, "VAH " + str.tostring(vpVAH, format.mintick), style=label.style_label_left, color=color.new(#9598a1, 0), textcolor=color.white, size=size.tiny)
        lbVAL := label.new(xb, vpVAL, "VAL " + str.tostring(vpVAL, format.mintick), style=label.style_label_left, color=color.new(#9598a1, 0), textcolor=color.white, size=size.tiny)

// ── Projection + Scénarios + Entrée/Stop/Cible ──
var line lnProj = na
var line lnR1   = na
var line lnS1   = na
var line lnEnt  = na
var line lnStp  = na
var line lnTgt  = na
var label lbProj = na
var label lbEnt  = na
var label lbStp  = na
var label lbTgt  = na
if barstate.islast
    line.delete(lnProj)
    line.delete(lnR1)
    line.delete(lnS1)
    line.delete(lnEnt)
    line.delete(lnStp)
    line.delete(lnTgt)
    label.delete(lbProj)
    label.delete(lbEnt)
    label.delete(lbStp)
    label.delete(lbTgt)
    int xN = bar_index
    int xF = bar_index + eForecastBars
    // Projection
    if showProj and confOK
        lnProj := line.new(xN, close, xF, f_cd(predicted), color=dirCol, width=3)
        lbProj := label.new(xF, f_cd(predicted), (bullish ? "▲ " : "▼ ") + str.tostring(predicted, format.mintick) + " (" + (changePct >= 0 ? "+" : "") + str.tostring(changePct, "#.#") + "%)", style=label.style_label_left, color=dirCol, textcolor=color.white, size=size.normal)
    // Lignes de référence R1 / S1 (niveaux clés, proches — pas de cibles lointaines)
    lnR1 := line.new(xN, f_cd(R1), xF, f_cd(R1), color=color.new(colResL, 20), width=1, style=line.style_dotted)
    lnS1 := line.new(xN, f_cd(S1), xF, f_cd(S1), color=color.new(colSupL, 20), width=1, style=line.style_dotted)
    // Entrée / Stop / Cible
    if showTrade and confOK
        lnEnt := line.new(xN - 2, f_cd(tEntry), xF, f_cd(tEntry), color=color.new(color.gray, 0), width=1)
        lnStp := line.new(xN - 2, f_cd(tStop),  xF, f_cd(tStop),  color=color.new(colStrongBear, 0), width=2, style=line.style_dashed)
        lnTgt := line.new(xN - 2, f_cd(tTarget),xF, f_cd(tTarget),color=color.new(colStrongBull, 0), width=2, style=line.style_dashed)
        lbEnt := label.new(xF, f_cd(tEntry), "ENTRÉE " + str.tostring(tEntry, format.mintick), style=label.style_label_left, color=color.new(color.gray, 0), textcolor=color.white, size=size.tiny)
        lbStp := label.new(xF, f_cd(tStop), "🛑 STOP " + str.tostring(tStop, format.mintick), style=label.style_label_left, color=color.new(colStrongBear, 0), textcolor=color.white, size=size.tiny)
        lbTgt := label.new(xF, f_cd(tTarget), "🎯 " + str.tostring(tTarget, format.mintick) + " · R:R " + str.tostring(rrRatio, "#.#"), style=label.style_label_left, color=color.new(colStrongBull, 0), textcolor=color.white, size=size.tiny)

// ── Flèches de signal (cassure conducteur, confirmé) ──
bool bullHold = conductor > eCndBuy
bool bearHold = conductor < -eCndBuy
bool bullFlip = bullHold and not bullHold[1] and barstate.isconfirmed
bool bearFlip = bearHold and not bearHold[1] and barstate.isconfirmed
plotshape(bullFlip, "ACHAT", shape.triangleup, location.belowbar, color.new(colStrongBull, 0), size=size.small)
plotshape(bearFlip, "VENTE", shape.triangledown, location.abovebar, color.new(colStrongBear, 0), size=size.small)

// ── Marqueurs de cassure ──
plotshape(showBreak and brokeR, "Cassure R", shape.labelup, location.belowbar, color.new(colStrongBull, 0), text="R cassée", textcolor=color.white, size=size.tiny)
plotshape(showBreak and brokeS, "Cassure S", shape.labeldown, location.abovebar, color.new(colStrongBear, 0), text="S cassé", textcolor=color.white, size=size.tiny)

// ── Figures de retournement (étiquettes) ──
if showRev and revName != "" and bar_index > last_bar_index - ePatBars
    label.new(bar_index, revDir > 0 ? low : high, "🔄 " + revName, style=revDir > 0 ? label.style_label_up : label.style_label_down, color=revDir > 0 ? color.new(colPatBull, 0) : color.new(colPatBear, 0), textcolor=color.white, size=size.small)

// ── Figures chartistes (étiquettes) ──
if showRev and chartName != "" and bar_index > last_bar_index - ePatBars
    label.new(bar_index, chartDir > 0 ? low : high, "📐 " + chartName, style=chartDir > 0 ? label.style_label_up : label.style_label_down, color=chartDir > 0 ? color.new(colPatBull, 20) : color.new(colPatBear, 20), textcolor=color.white, size=size.small)

// ── Confirmation en zone (étoile = le signal de la planche : pattern + zone demande/offre) ──
if zoneSig > 0 and zoneSig[1] <= 0
    label.new(bar_index, low, "⭐ ACHAT ZONE", style=label.style_label_up, color=color.new(colStrongBull, 0), textcolor=color.white, size=size.small)
if zoneSig < 0 and zoneSig[1] >= 0
    label.new(bar_index, high, "⭐ VENTE ZONE", style=label.style_label_down, color=color.new(colStrongBear, 0), textcolor=color.white, size=size.small)

// ── Patterns de chandelier (étiquettes, barres récentes) ──
if showPat and patName != "" and bar_index > last_bar_index - ePatBars
    label.new(bar_index, patDir > 0 ? low : high, patName, style=patDir > 0 ? label.style_label_up : label.style_label_down, color=patDir > 0 ? colPatBull : patDir < 0 ? colPatBear : color.new(colNeutral, 0), textcolor=color.white, size=patTsize)

bool agentBuy  = bullCount >= 65
bool agentSell = (100 - bullCount) >= 65

// ═══════════════════════════════════════════════════════════════════════════════
// TABLEAU
// ═══════════════════════════════════════════════════════════════════════════════
color cBG  = color.new(#131722, 0)
color cHDR = color.new(#1e222d, 0)
color cTXT = color.new(#d1d4dc, 0)
color cMUT = color.new(#787b86, 0)
var table dash = table.new(tablePos, 2, 52, border_width=1, border_color=color.new(color.gray, 75), frame_width=2, frame_color=color.new(color.gray, 40), bgcolor=cBG)

f_L(int row, string txt, color tc) =>
    table.cell(dash, 0, row, txt, text_color=tc, text_halign=text.align_left, text_size=tSize, bgcolor=cBG, width=wLabel)
f_R(int row, string txt, color tc, color bg) =>
    table.cell(dash, 1, row, txt, text_color=tc, text_halign=text.align_right, text_size=tSize, bgcolor=bg, width=wValue)
f_HDR(int row, string l, string rr) =>
    table.cell(dash, 0, row, l,  text_color=color.new(#8a8d98, 0), text_halign=text.align_left,  text_size=tSize, bgcolor=cHDR, width=wLabel)
    table.cell(dash, 1, row, rr, text_color=color.new(#8a8d98, 0), text_halign=text.align_right, text_size=tSize, bgcolor=cHDR, width=wValue)
f_dc(int d) =>
    d > 0 ? color.new(colBull, 15) : d < 0 ? color.new(colBear, 15) : color.new(colNeutral, 35)

if barstate.islast and showTable
    int r = 0
    table.cell(dash, 0, r, "⚛ NEXUS v9.3", text_color=color.white, text_halign=text.align_left, text_size=tSize, bgcolor=cHDR, width=wLabel)
    table.cell(dash, 1, r, syminfo.ticker + " " + timeframe.period + (stM ? "" : " · " + tradeStyle), text_color=cMUT, text_halign=text.align_right, text_size=tSize, bgcolor=cHDR, width=wValue)
    r += 1

    if secDecision
        if rVerdict
            table.cell(dash, 0, r, vEmoji + " " + verdict, text_color=color.white, text_halign=text.align_center, text_size=tSize, bgcolor=color.new(verdictCol, 0), width=wLabel)
            table.cell(dash, 1, r, str.tostring(conductor, "#.0") + "/100", text_color=color.white, text_halign=text.align_center, text_size=tSize, bgcolor=color.new(verdictCol, 0), width=wValue)
            r += 1
        if rAction
            f_L(r, "Action", cTXT)
            f_R(r, planAction, color.white, color.new(verdictCol, 12))
            r += 1
        if rConf
            f_L(r, "Confiance", cTXT)
            f_R(r, str.tostring(finalConf, "0") + "%" + (confOK ? " ✓" : " ⏸"), confOK ? color.new(#26c6da, 0) : cMUT, cBG)
            r += 1
        if rAccord
            f_L(r, "Accord systèmes", cTXT)
            f_R(r, str.tostring(agree) + "/8 · " + regimeTxt, cTXT, f_dc(cdir))
            r += 1
        if rPos
            f_L(r, "Position", cTXT)
            f_R(r, sizeTxt, color.new(#ffd54f, 0), cBG)
            r += 1

    if secScen
        f_HDR(r, "🔮 PROJECTION & NIVEAUX", "prix")
        r += 1
        if rProj
            f_L(r, "Projection " + str.tostring(eForecastBars) + "b", cTXT)
            f_R(r, str.tostring(predicted, format.mintick) + " (" + (changePct >= 0 ? "+" : "") + str.tostring(changePct, "#.#") + "%)", color.white, color.new(dirCol, 15))
            r += 1
        if rZoneP
            f_L(r, "Zone basse — haute", cTXT)
            f_R(r, str.tostring(predLower, format.mintick) + " — " + str.tostring(predUpper, format.mintick), cMUT, cBG)
            r += 1
        if rR1
            f_L(r, "🔼 Résistance proche", cTXT)
            f_R(r, str.tostring(R1, format.mintick) + " (+" + str.tostring((R1-close)/close*100, "#.#") + "%)", color.white, color.new(colResL, 30))
            r += 1
        if rS1
            f_L(r, "🔽 Support proche", cTXT)
            f_R(r, str.tostring(S1, format.mintick) + " (" + str.tostring((S1-close)/close*100, "#.#") + "%)", color.white, color.new(colSupL, 30))
            r += 1

    if secInd
        f_HDR(r, "──── INDICATEURS ────", "valeur")
        r += 1
        if rRSI
            string rsiState = rsiV > rsiOB ? "SURACHAT" : rsiV < rsiOS ? "SURVENTE" : rsiV > 50 ? "▲" : "▼"
            f_L(r, "RSI " + str.tostring(rsiLen), cTXT)
            f_R(r, str.tostring(rsiV, "#.0") + " " + rsiState, color.white, f_dc(sRsi))
            r += 1
        if rMACD
            f_L(r, "MACD", cTXT)
            f_R(r, str.tostring(macdL1, "#.##") + "/" + str.tostring(sigL1, "#.##"), color.white, f_dc(sMacd))
            r += 1
        if rADX
            f_L(r, "ADX", cTXT)
            f_R(r, str.tostring(adxV14, "#.0") + " (+" + str.tostring(diP14, "#.0") + "/-" + str.tostring(diM14, "#.0") + ")", color.white, f_dc(sAdx))
            r += 1
        if rStoch
            f_L(r, "Stoch K/D", cTXT)
            f_R(r, str.tostring(kVal, "#.0") + "/" + str.tostring(dVal, "#.0"), color.white, f_dc(sStoch))
            r += 1
        if rCCI
            f_L(r, "CCI " + str.tostring(cciLen), cTXT)
            f_R(r, (cciV >= 0 ? "+" : "") + str.tostring(cciV, "#.0"), color.white, f_dc(cciV > 0 ? 1 : -1))
            r += 1
        if rMFI
            f_L(r, "MFI " + str.tostring(mfiLen), cTXT)
            f_R(r, str.tostring(mfiV, "#.0"), color.white, f_dc(sMfi))
            r += 1
        if rVol
            f_L(r, "Volume", cTXT)
            f_R(r, str.tostring(volRel, "#.##") + "×", color.white, f_dc(sVol))
            r += 1
        if rVWAP
            f_L(r, "VWAP", cTXT)
            f_R(r, na(rollVwap) ? "N/D" : str.tostring(rollVwap, format.mintick), color.white, f_dc(sVwap))
            r += 1
        if rEMA
            string emaAlign = (emaF > emaM ? "▲" : "▼") + (emaM > emaS ? "▲" : "▼") + (emaS > emaT ? "▲" : "▼")
            f_L(r, "EMA " + str.tostring(emaFastL) + "/" + str.tostring(emaMidL) + "/" + str.tostring(emaSlowL), cTXT)
            f_R(r, emaAlign, color.white, f_dc(sEma))
            r += 1
        if rST
            f_L(r, "Supertrend", cTXT)
            f_R(r, upTrend1 ? "BULL ▲" : "BEAR ▼", color.white, f_dc(sSt))
            r += 1
        if rATR
            f_L(r, "ATR", cTXT)
            f_R(r, str.tostring(atrV, format.mintick) + " " + str.tostring(atrV/close*100, "#.#") + "%", color.white, cBG)
            r += 1
        if rBB
            f_L(r, "Bollinger " + str.tostring(bbLen) + "/" + str.tostring(bbMult, "#.#"), cTXT)
            f_R(r, str.tostring(bbPos * 100, "#.0") + "% · larg " + str.tostring(bbW, "#.#") + "%" + (bbSqueeze ? " ⚡SQUEEZE" : ""), color.white, f_dc(sBB))
            r += 1
        if rIntens
            f_L(r, "Intensité bougie", cTXT)
            f_R(r, (candleIntensity >= 0 ? "▲ +" : "▼ ") + str.tostring(candleIntensity, "#.##") + " ATR · " + intensTxt, color.white, f_dc(candleIntensity > 0.2 ? 1 : candleIntensity < -0.2 ? -1 : 0))
            r += 1

    if secVP
        f_HDR(r, "📦 VOLUME PROFILE", str.tostring(eVpLook) + "b")
        r += 1
        if rPOC
            f_L(r, "POC (prix pivot)", cTXT)
            f_R(r, na(vpPOC) ? "..." : str.tostring(vpPOC, format.mintick), colPOCL, f_dc(vpDir))
            r += 1
        if rVA
            f_L(r, "Value Area H/L", cTXT)
            f_R(r, na(vpVAH) ? "..." : str.tostring(vpVAH, format.mintick) + " / " + str.tostring(vpVAL, format.mintick), color.white, cBG)
            r += 1
        if rVsPOC
            f_L(r, "Prix vs POC", cTXT)
            f_R(r, na(vpPOC) ? "..." : vpDir > 0 ? "AU-DESSUS ▲" : vpDir < 0 ? "SOUS ▼" : "=", color.white, f_dc(vpDir))
            r += 1

    if secIA
        f_HDR(r, "──── 100 IA & ML ────", "")
        r += 1
        if rIA
            string iaLoc = eAgentTF == "" ? timeframe.period : eAgentTF
            f_L(r, "100 IA @" + iaLoc, cTXT)
            f_R(r, str.tostring(bullCount) + "/100", color.white, f_dc(bullCount > 60 ? 1 : bullCount < 40 ? -1 : 0))
            r += 1
        if rConn
            f_L(r, "Connexion inter-IA", cTXT)
            f_R(r, str.tostring(blkAlign) + "/4 blocs · " + str.tostring(iaConnection, "#") + "%", color.white, f_dc(blkAlign >= 3 ? cdir : 0))
            r += 1
        if rMTVS
            f_L(r, " M·T·V·S", cMUT)
            f_R(r, str.tostring(momBull) + "·" + str.tostring(trendBull) + "·" + str.tostring(volBull) + "·" + str.tostring(structBull), cMUT, cBG)
            r += 1
        if rMTF
            f_L(r, "Multi-TF", cTXT)
            f_R(r, useMTF ? ("Σ" + (mtfSigned >= 0 ? "+" : "") + str.tostring(mtfSigned) + " (" + str.tostring(mtf1) + "/" + str.tostring(mtf2) + "/" + str.tostring(mtf3) + ")") : "OFF", color.white, useMTF ? f_dc(mtfSigned > 0 ? 1 : mtfSigned < 0 ? -1 : 0) : color.new(colNeutral, 40))
            r += 1
        if rLor
            f_L(r, "Lorentzian ML", cTXT)
            f_R(r, (lorScoreRaw >= 0 ? "+" : "") + str.tostring(lorScoreRaw, "#.##"), color.white, f_dc(lorBull ? 1 : lorBear ? -1 : 0))
            r += 1

    if secPat
        f_HDR(r, "🕯️ PATTERNS & FIGURES", "signal")
        r += 1
        if rPat
            f_L(r, "Chandelier", cTXT)
            f_R(r, lastPatName + (lastPatDir > 0 ? " ▲" : lastPatDir < 0 ? " ▼" : ""), color.white, f_dc(candleSig))
            r += 1
        if rRev
            f_L(r, "🔄 Figure retourn.", cTXT)
            f_R(r, lastRevName + (lastRevDir > 0 ? " ▲" : lastRevDir < 0 ? " ▼" : ""), color.white, f_dc(revSig))
            r += 1
        if rChart
            f_L(r, "📐 Figure chartiste", cTXT)
            f_R(r, lastChartName + (lastChartDir > 0 ? " ▲" : lastChartDir < 0 ? " ▼" : ""), color.white, f_dc(chartSig))
            r += 1
        if rZoneDO
            f_L(r, "⭐ Zone demande/offre", cTXT)
            f_R(r, zoneSig > 0 ? "ACHAT confirmé zone" : zoneSig < 0 ? "VENTE confirmée zone" : (nearSup ? "proche support" : nearRes ? "proche résistance" : "—"), color.white, f_dc(zoneSig))
            r += 1
        if rAMD
            f_L(r, "⚡ Power of 3 (AMD)", cTXT)
            f_R(r, amdAge <= 8 ? ("DISTRIBUTION " + (lastAmdDir > 0 ? "▲" : "▼") + " il y a " + str.tostring(amdAge) + "b") : amdStateTxt, color.white, f_dc(amdActive))
            r += 1

    if secAccT
        f_HDR(r, "📈 PRÉCISION RÉELLE", "auto-test")
        r += 1
        if rAccP
            f_L(r, "Projection " + str.tostring(evalH) + "b", cTXT)
            f_R(r, na(projAcc) ? "calcul..." : str.tostring(math.round(projAcc)) + "% /" + str.tostring(int(accCnt)), color.white, color.new(na(projAcc) ? colNeutral : projAcc >= 55 ? colBull : projAcc < 45 ? colBear : colNeutral, 25))
            r += 1
        if rAccD
            f_L(r, "Décision", cTXT)
            f_R(r, na(condAcc) ? "calcul..." : str.tostring(math.round(condAcc)) + "% /" + str.tostring(int(cAccCnt)), color.white, color.new(na(condAcc) ? colNeutral : condAcc >= 55 ? colBull : condAcc < 45 ? colBear : colNeutral, 25))
            r += 1

    table.cell(dash, 0, r, "⚠ Scénario, pas garantie", text_color=color.new(#ffcc66, 0), text_halign=text.align_left, text_size=size.tiny, bgcolor=cHDR, width=wLabel)
    table.cell(dash, 1, r, "Risque 1% max", text_color=color.new(#ffcc66, 0), text_halign=text.align_right, text_size=size.tiny, bgcolor=cHDR, width=wValue)
// ═══════════════════════════════════════════════════════════════════════════════
// ALERTES
// ═══════════════════════════════════════════════════════════════════════════════
alertcondition(bullFlip, "QN9 ▲ ACHAT", "QUANTUM NEXUS v9: Signal ACHAT — {{ticker}} @ {{close}}")
alertcondition(bearFlip, "QN9 ▼ VENTE", "QUANTUM NEXUS v9: Signal VENTE — {{ticker}} @ {{close}}")
alertcondition(brokeR, "QN9 Cassure Résistance", "QUANTUM NEXUS v9: Résistance cassée — {{ticker}} @ {{close}}")
alertcondition(brokeS, "QN9 Cassure Support", "QUANTUM NEXUS v9: Support cassé — {{ticker}} @ {{close}}")
alertcondition(agentBuy, "QN9 🚀 100 IA BULL", "QUANTUM NEXUS v9: 100 IA haussières — {{ticker}} @ {{close}}")
alertcondition(agentSell, "QN9 🔻 100 IA BEAR", "QUANTUM NEXUS v9: 100 IA baissières — {{ticker}} @ {{close}}")
alertcondition(bullish and not bullish[1], "QN9 Projection ▲", "QUANTUM NEXUS v9: Projection haussière — {{ticker}}")
alertcondition(not bullish and bullish[1], "QN9 Projection ▼", "QUANTUM NEXUS v9: Projection baissière — {{ticker}}")
alertcondition(patName != "" and patDir > 0, "QN9 Pattern haussier", "QUANTUM NEXUS v9: Pattern chandelier haussier — {{ticker}} @ {{close}}")
alertcondition(patName != "" and patDir < 0, "QN9 Pattern baissier", "QUANTUM NEXUS v9: Pattern chandelier baissier — {{ticker}} @ {{close}}")
alertcondition(revName != "" and revDir > 0, "QN9 Retournement haussier", "QUANTUM NEXUS v9: Figure de retournement haussière — {{ticker}} @ {{close}}")
alertcondition(revName != "" and revDir < 0, "QN9 Retournement baissier", "QUANTUM NEXUS v9: Figure de retournement baissière — {{ticker}} @ {{close}}")
alertcondition(chartName != "" and chartDir > 0, "QN9 Figure chartiste ▲", "QUANTUM NEXUS v9: Cassure de figure haussière — {{ticker}} @ {{close}}")
alertcondition(chartName != "" and chartDir < 0, "QN9 Figure chartiste ▼", "QUANTUM NEXUS v9: Cassure de figure baissière — {{ticker}} @ {{close}}")
alertcondition(zoneSig > 0 and zoneSig[1] <= 0, "QN9 ⭐ Achat zone demande", "QUANTUM NEXUS v9: Confirmation ACHAT en zone de demande — {{ticker}} @ {{close}}")
alertcondition(zoneSig < 0 and zoneSig[1] >= 0, "QN9 ⭐ Vente zone offre", "QUANTUM NEXUS v9: Confirmation VENTE en zone d'offre — {{ticker}} @ {{close}}")
alertcondition(bbSqueeze and not bbSqueeze[1], "QN9 ⚡ BB Squeeze", "QUANTUM NEXUS v9: SQUEEZE Bollinger — volatilité comprimée, cassure imminente — {{ticker}}")
alertcondition(low <= bbLower and close > bbLower, "QN9 BB rebond bas", "QUANTUM NEXUS v9: Rejet de la bande basse Bollinger — {{ticker}} @ {{close}}")
alertcondition(high >= bbUpper and close < bbUpper, "QN9 BB rejet haut", "QUANTUM NEXUS v9: Rejet de la bande haute Bollinger — {{ticker}} @ {{close}}")
alertcondition(amdState == 2 and amdState[1] == 1, "QN9 ⚡ AMD Manipulation", "QUANTUM NEXUS v9: Sweep de liquidité détecté (manipulation) — surveiller la cassure — {{ticker}} @ {{close}}")
alertcondition(amdSig > 0, "QN9 ⚡ AMD Distribution ▲", "QUANTUM NEXUS v9: Power of Three complété HAUSSIER — distribution en cours — {{ticker}} @ {{close}}")
alertcondition(amdSig < 0, "QN9 ⚡ AMD Distribution ▼", "QUANTUM NEXUS v9: Power of Three complété BAISSIER — distribution en cours — {{ticker}} @ {{close}}")
````
