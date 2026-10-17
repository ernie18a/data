# Guapoxtrades - Risk Panel

- url: https://www.tradingview.com/script/3o8RW9rq-Guapoxtrades-Risk-Panel/
- type: indicator
- pine_id: PUB;f3b0cbd9282f443192df9abb824c2fd6
- version: 2.0

## Description

GuapoxTrades Risk Panel™
Lot Size Calculator • Risk Management • Trade Planning Framework

The GuapoxTrades Risk Panel™ is a professional risk-management calculator designed to help traders calculate position size, potential risk, expected reward, commission impact, and drawdown exposure directly on the chart.

Instead of manually calculating lot size outside of TradingView, traders can input their account size, risk percentage, stop distance, reward target, commission estimate, and drawdown limit to receive a structured risk breakdown in real time.

The goal is simple:
Know the risk before entering the trade.

Core Features:
Account size input
Risk percentage calculator
Stop-distance-based lot sizing
Dynamic forex pip value engine
Suggested lot size output
Gross reward calculation
Estimated commission cost
Net reward after commission
Risk-to-reward target display
Break-even win-rate calculation
Max daily drawdown exposure
Max trades before drawdown limit
Valid / invalid risk status
Movable risk panel
Adjustable panel transparency

Why This Indicator Was Built
Many traders lose consistency not because they cannot find setups, but because they fail to properly size positions before entering the market.

The GuapoxTrades Risk Panel™ was created to help traders slow down and answer important questions before execution:
How much am I risking?
What lot size matches my risk plan?
What is the realistic reward?
How much does commission reduce the outcome?
What win rate do I need to break even?
How many losses would push me near my drawdown limit?
This turns risk management into a visible part of the trading process.

Visual Design Notice
This indicator was designed, tested, and optimized primarily for dark-theme chart backgrounds.
The panel colors, text contrast, and transparency settings were developed in a dark-mode trading environment for clean readability and minimal chart obstruction.

Users using light-theme charts may customize the appearance through:
Settings → Risk Panel Transparency
Settings → Risk Panel Position

Disclaimer - Educational Use Only.
GuapoxTrades Risk Panel™ is provided solely for educational and informational purposes. It does not provide financial advice, investment advice, trading advice, or buy/sell recommendations.

Lot size calculations, pip value estimates, commission estimates, drawdown projections, reward targets, and break-even win-rate calculations are based on user-provided inputs and may not reflect actual broker execution, spread, slippage, swap fees, margin requirements, or account-specific conditions.

Trading forex, futures, stocks, crypto, and leveraged financial products involves substantial risk and may result in loss of capital.

Users are solely responsible for verifying all calculations with their broker and managing their own trading decisions, risk exposure, and financial outcomes.

© GuapoxTrades. All Rights Reserved.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © GuapoxTrades

//@version=6
indicator("Guapoxtrades Risk Calculator", shorttitle="GT-RISK", overlay=true, dynamic_requests=true)

// GT GLOBAL™ — Welcome first, language second. Branding remains fixed.
grpWelcome = "0. Welcome to GuapoxTrades™"
username = input.string("King Guapo", "Username / Nombre", group=grpWelcome, tooltip="Your display name. GuapoxTrades branding is fixed.")
grpLanguage = "0.1. GT Global™ — Language / Idioma"
language = input.string("English", "Language / Idioma", options=["English", "Español", "Português", "Français", "Deutsch", "日本語", "简体中文", "Русский", "العربية", "हिन्दी", "Italiano"], group=grpLanguage, tooltip="Changes on-chart headings, units and risk status messages in 11 languages. Native settings retain fixed wording. Account currency is independent of language.")

f_riskLoadEnglish() =>
    str.split("Welcome¦LOT SIZE CALC¦Risk Status¦Invalid Stop¦Conversion N/A¦Invalid Size¦Size Too Small¦Valid¦Account Size¦Risk¦Lot Size¦ lots¦Stop Distance¦ pips¦Risk : Reward¦Gross Reward¦Net Reward¦Commission Est.¦Break-Even Win% (gross)¦Losses (gross DD ¦ losses", "¦")

f_riskLoadSpanish() =>
    str.split("Bienvenido¦CÁLCULO DE LOTES¦Estado del riesgo¦Stop inválido¦Conversión no disponible¦Tamaño inválido¦Tamaño demasiado pequeño¦Válido¦Saldo de la cuenta¦Riesgo¦Tamaño del lote¦ lotes¦Distancia del stop¦ pips¦Riesgo : Beneficio¦Beneficio bruto¦Beneficio neto¦Comisión estimada¦Acierto de equilibrio% (bruto)¦Pérdidas (DD bruto ¦ pérdidas", "¦")

f_riskLoadPortuguese() =>
    str.split("Bem-vindo¦CÁLCULO DE LOTES¦Estado do risco¦Stop inválido¦Conversão indisponível¦Tamanho inválido¦Tamanho muito pequeno¦Válido¦Saldo da conta¦Risco¦Tamanho do lote¦ lotes¦Distância do stop¦ pips¦Risco : Retorno¦Retorno bruto¦Retorno líquido¦Comissão estimada¦Acerto de equilíbrio% (bruto)¦Perdas (DD bruto ¦ perdas", "¦")

f_riskLoadFrench() =>
    str.split("Bienvenue¦CALCUL DES LOTS¦État du risque¦Stop invalide¦Conversion indisponible¦Taille invalide¦Taille trop petite¦Valide¦Solde du compte¦Risque¦Taille du lot¦ lots¦Distance du stop¦ pips¦Risque : Gain¦Gain brut¦Gain net¦Commission estimée¦Réussite à l'équilibre% (brut)¦Pertes (DD brut ¦ pertes", "¦")

f_riskLoadGerman() =>
    str.split("Willkommen¦LOT-BERECHNUNG¦Risikostatus¦Ungültiger Stop¦Umrechnung nicht verfügbar¦Ungültige Größe¦Größe zu klein¦Gültig¦Kontostand¦Risiko¦Lotgröße¦ Lots¦Stop-Abstand¦ Pips¦Risiko : Ertrag¦Bruttoertrag¦Nettoertrag¦Geschätzte Provision¦Gewinnquote zum Ausgleich% (brutto)¦Verluste (Brutto-DD ¦ Verluste", "¦")

f_riskLoadJapanese() =>
    str.split("ようこそ¦ロット計算¦リスク状態¦ストップ無効¦換算不可¦サイズ無効¦サイズが小さすぎます¦有効¦口座残高¦リスク¦ロット数¦ ロット¦ストップ距離¦ pips¦リスク : リワード¦総利益¦純利益¦手数料見積¦損益分岐勝率%（手数料前）¦損失回数（手数料前DD ¦ 回", "¦")

f_riskLoadChinese() =>
    str.split("欢迎¦手数计算¦风险状态¦止损无效¦无法换算¦仓位无效¦仓位过小¦有效¦账户余额¦风险¦手数¦ 手¦止损距离¦ pips¦风险 : 回报¦毛收益¦净收益¦预计佣金¦盈亏平衡胜率%（费用前）¦亏损次数（费用前回撤 ¦ 次", "¦")

f_riskLoadRussian() =>
    str.split("Добро пожаловать¦РАСЧЁТ ЛОТА¦Статус риска¦Неверный стоп¦Конвертация недоступна¦Неверный объём¦Объём слишком мал¦Допустимо¦Баланс счёта¦Риск¦Размер лота¦ лотов¦Расстояние стопа¦ пипсов¦Риск : Прибыль¦Валовая прибыль¦Чистая прибыль¦Оценка комиссии¦Безубыточные победы% (до комиссии)¦Убытки (валовая просадка ¦ убытков", "¦")

f_riskLoadArabic() =>
    str.split("مرحبًا¦حساب حجم العقد¦حالة المخاطرة¦وقف غير صالح¦التحويل غير متاح¦حجم غير صالح¦الحجم صغير جدًا¦صالح¦رصيد الحساب¦المخاطرة¦حجم العقد¦ عقود¦مسافة الوقف¦ نقاط بيب¦مخاطرة : عائد¦العائد الإجمالي¦العائد الصافي¦العمولة المقدرة¦نسبة الفوز للتعادل% (قبل العمولة)¦خسائر (تراجع قبل العمولة ¦ خسائر", "¦")

f_riskLoadHindi() =>
    str.split("स्वागत है¦लॉट गणना¦जोखिम स्थिति¦अमान्य स्टॉप¦रूपांतरण अनुपलब्ध¦अमान्य आकार¦आकार बहुत छोटा¦मान्य¦खाता शेष¦जोखिम¦लॉट आकार¦ लॉट¦स्टॉप दूरी¦ पिप्स¦जोखिम : प्रतिफल¦सकल प्रतिफल¦शुद्ध प्रतिफल¦अनुमानित कमीशन¦संतुलन जीत% (कमीशन से पहले)¦हानियाँ (सकल DD ¦ हानियाँ", "¦")

f_riskLoadItalian() =>
    str.split("Benvenuto¦CALCOLO LOTTI¦Stato del rischio¦Stop non valido¦Conversione non disponibile¦Dimensione non valida¦Dimensione troppo piccola¦Valido¦Saldo del conto¦Rischio¦Dimensione del lotto¦ lotti¦Distanza dello stop¦ pip¦Rischio : Rendimento¦Guadagno lordo¦Guadagno netto¦Commissione stimata¦Vittorie per pareggio% (lordo)¦Perdite (DD lordo ¦ perdite", "¦")

f_riskLoadSelected(string _language, array<string> _english) =>
    switch _language
        "Español" => f_riskLoadSpanish()
        "Português" => f_riskLoadPortuguese()
        "Français" => f_riskLoadFrench()
        "Deutsch" => f_riskLoadGerman()
        "日本語" => f_riskLoadJapanese()
        "简体中文" => f_riskLoadChinese()
        "Русский" => f_riskLoadRussian()
        "العربية" => f_riskLoadArabic()
        "हिन्दी" => f_riskLoadHindi()
        "Italiano" => f_riskLoadItalian()
        => _english

var array<string> riskGlobalKeys = f_riskLoadEnglish()
var array<string> riskGlobalValues = f_riskLoadSelected(language, riskGlobalKeys)
var map<string, string> riskGlobalDictionary = map.new<string, string>()
if barstate.isfirst
    for riskGlobalIndex = 0 to array.size(riskGlobalKeys) - 1
        map.put(riskGlobalDictionary, array.get(riskGlobalKeys, riskGlobalIndex), array.get(riskGlobalValues, riskGlobalIndex))

f_riskText(string _english) =>
    map.contains(riskGlobalDictionary, _english) ? map.get(riskGlobalDictionary, _english) : _english

//══════════════════════════════════════════════════════════════════════════════
// GROUPS
//══════════════════════════════════════════════════════════════════════════════
grpGlobal = "Global Settings"
grpRisk   = "Risk / Lot Size Panel"
//══════════════════════════════════════════════════════════════════════════════
// COLORS
//══════════════════════════════════════════════════════════════════════════════
bullColor = color.lime
bearColor = color.red
//══════════════════════════════════════════════════════════════════════════════
// HELPER FUNCTIONS
//══════════════════════════════════════════════════════════════════════════════
f_panelPos(_pos) =>
    switch _pos
        "Top Left"      => position.top_left
        "Top Center"    => position.top_center
        "Top Right"     => position.top_right
        "Middle Left"   => position.middle_left
        "Middle Center" => position.middle_center
        "Middle Right"  => position.middle_right
        "Bottom Left"   => position.bottom_left
        "Bottom Center" => position.bottom_center
        => position.bottom_right
f_safeDiv(_num, _den) =>
    _den == 0.0 ? 0.0 : _num / _den
f_round2(_val) =>
    math.round(_val * 100.0) / 100.0
f_formatNumber(_value) =>
    str.format("{0,number,#,###.##}", _value)
//══════════════════════════════════════════════════════════════════════════════
// RISK PANEL — INPUTS
//══════════════════════════════════════════════════════════════════════════════
showRiskPanel = input.bool(
     true,
     "Show Risk / Lot Size Panel",
     group=grpRisk)
riskPanelPosition = input.string(
     "Middle Center",
     "Risk Panel Position",
     options=[
         "Top Left",
         "Top Center",
         "Top Right",
         "Middle Left",
         "Middle Center",
         "Middle Right",
         "Bottom Left",
         "Bottom Center",
         "Bottom Right"],
     group=grpRisk)
riskPanelTransparency = input.int(
     90,
     "Risk Panel Transparency",
     minval=0,
     maxval=100,
     group=grpRisk)
riskPanelTextSize = input.string(
     "Small",
     "Panel Text Size",
     options=["Small", "Tiny"],
     group=grpRisk)
accountSize = input.float(
     25000.0,
     "Account Size (account currency)",
     minval=0.0,
     group=grpRisk)
riskPct = input.float(
     2.0,
     "Risk % Per Trade",
     minval=0.1,
     step=0.1,
     group=grpRisk)
stopDistance = input.float(
     100.0,
     "Stop Distance (points/pips)",
     minval=0.1,
     step=0.1,
     group=grpRisk)
rrTarget = input.float(
     3.0,
     "Risk:Reward Target",
     minval=0.5,
     step=0.5,
     group=grpRisk)
accountCurrencySymbol = input.string(
     "$",
     "Account Currency",
     options=["$", "€", "£", "¥", "C$", "Fr", "A$", "NZ$"],
     tooltip="US dollar ($), euro (€), British pound (£), Japanese yen (¥), Canadian dollar (C$), Swiss franc (Fr), Australian dollar (A$), New Zealand dollar (NZ$).",
     group=grpRisk)
// Currency symbols are for display; ISO codes drive conversion.
accountCurrency = switch accountCurrencySymbol
    "€"   => "EUR"
    "£"   => "GBP"
    "¥"   => "JPY"
    "C$"  => "CAD"
    "Fr"  => "CHF"
    "A$"  => "AUD"
    "NZ$" => "NZD"
    => "USD"
useAutoPipValue = input.bool(
     true,
     "Automatic Cross-Pair Pip Conversion",
     group=grpRisk)
manualPipValue = input.float(
     10.0,
     "Manual Pip Value Per 1.0 Lot",
     minval=0.0001,
     step=0.1,
     tooltip="Used when automatic conversion is disabled or a conversion rate is unavailable.",
     group=grpRisk)
commissionPerLot = input.float(
     7.0,
     "Commission Per Lot (round trip, account currency)",
     minval=0.0,
     step=0.5,
     group=grpRisk)
maxDrawdownPct = input.float(
     6.0,
     "Max Daily Drawdown %",
     minval=0.1,
     step=0.1,
     group=grpRisk)
//══════════════════════════════════════════════════════════════════════════════
// DYNAMIC FOREX PIP-VALUE ENGINE
//══════════════════════════════════════════════════════════════════════════════
string baseCurrency  = syminfo.basecurrency
string quoteCurrency = syminfo.currency
// JPY pairs use 0.01 as one pip.
// Most other Forex pairs use 0.0001 as one pip.
float pipSize =
     quoteCurrency == "JPY" ? 0.01 : 0.0001
float standardLot = 100000.0
// Convert the pip value from the pair's quote currency into the selected
// account currency.
//
// Example:
// One EURJPY standard lot produces JPY 1,000 per pip.
// That JPY value must be converted into USD before calculating a position
// size for a USD-denominated trading account.
float quoteToAccountRate =
     quoteCurrency == accountCurrency
         ? 1.0
         : request.currency_rate(
             quoteCurrency,
             accountCurrency)
float autoPipValuePerLot =
     standardLot *
     pipSize *
     quoteToAccountRate
bool conversionAvailable =
     not na(autoPipValuePerLot) and
     autoPipValuePerLot > 0.0
float pipValuePerLot =
     useAutoPipValue and conversionAvailable
         ? autoPipValuePerLot
         : manualPipValue
//══════════════════════════════════════════════════════════════════════════════
// RISK CALCULATIONS
//══════════════════════════════════════════════════════════════════════════════
float riskAmount =
     accountSize *
     (riskPct / 100.0)
float suggestedLots =
     f_safeDiv(
         riskAmount,
         stopDistance * pipValuePerLot)
float rewardAmount =
     riskAmount *
     rrTarget
float commissionCost =
     commissionPerLot *
     suggestedLots
float netReward =
     rewardAmount -
     commissionCost
float netRisk =
     riskAmount +
     commissionCost
float maxDDAmount =
     accountSize *
     (maxDrawdownPct / 100.0)
float maxTradesAtRisk =
     f_safeDiv(
         maxDDAmount,
         riskAmount)
float breakEvenWinRate =
     f_safeDiv(
         1.0,
         1.0 + rrTarget) *
     100.0
string riskStatus =
     stopDistance <= 0.0
         ? "Invalid Stop"
         : useAutoPipValue and not conversionAvailable
             ? "Conversion N/A"
             : suggestedLots <= 0.0
                 ? "Invalid Size"
                 : suggestedLots < 0.01
                     ? "Size Too Small"
                     : "Valid"
color riskStatusColor =
     riskStatus == "Valid"
         ? bullColor
         : riskStatus == "Size Too Small"
             ? color.orange
             : bearColor
panelTextSize =
     riskPanelTextSize == "Tiny"
         ? size.tiny
         : size.small
//══════════════════════════════════════════════════════════════════════════════
// RISK PANEL — TABLE
//══════════════════════════════════════════════════════════════════════════════
var table riskPanel = na
var string lastRiskPanelPosition = ""
if na(riskPanel) or riskPanelPosition != lastRiskPanelPosition
    if not na(riskPanel)
        table.delete(riskPanel)
    riskPanel := table.new(
         f_panelPos(riskPanelPosition),
         2,
         14,
         frame_color=color.new(color.white, 70),
         frame_width=1)
    lastRiskPanelPosition := riskPanelPosition
if barstate.islast and showRiskPanel
    table.clear(
         riskPanel,
         0,
         0,
         1,
         13)
    rbg = color.new(
         color.black,
         riskPanelTransparency)
    // Row 0 — Header
    table.cell(
         riskPanel,
         0,
         0,
         "GT RISK PANEL",
         text_color=color.lime,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         0,
         f_riskText("LOT SIZE CALC"),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 1 — Risk Status
    table.cell(
         riskPanel,
         0,
         1,
         f_riskText("Risk Status"),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         1,
         f_riskText(riskStatus),
         text_color=riskStatusColor,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 2 — Divider
    table.cell(
         riskPanel,
         0,
         2,
         "────────",
         text_color=color.gray,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         2,
         "────────",
         text_color=color.gray,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 3 — Account Size
    table.cell(
         riskPanel,
         0,
         3,
         f_riskText("Account Size"),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         3,
         accountCurrencySymbol + " " + f_formatNumber(accountSize),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 4 — Risk Amount
    table.cell(
         riskPanel,
         0,
         4,
         f_riskText("Risk") + " " + accountCurrencySymbol + " (" + str.tostring(riskPct) + "%)",
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         4,
         accountCurrencySymbol + " " + f_formatNumber(riskAmount),
         text_color=bearColor,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 5 — Suggested Lot Size
    table.cell(
         riskPanel,
         0,
         5,
         f_riskText("Lot Size"),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         5,
         str.tostring(f_round2(suggestedLots)) + f_riskText(" lots"),
         text_color=color.yellow,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 6 — Stop Distance
    table.cell(
         riskPanel,
         0,
         6,
         f_riskText("Stop Distance"),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         6,
         str.tostring(stopDistance) + f_riskText(" pips"),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 7 — Risk-to-Reward Ratio
    table.cell(
         riskPanel,
         0,
         7,
         f_riskText("Risk : Reward"),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         7,
         "1:" + str.tostring(rrTarget),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 8 — Gross Reward
    table.cell(
         riskPanel,
         0,
         8,
         f_riskText("Gross Reward"),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         8,
         accountCurrencySymbol + " " + f_formatNumber(rewardAmount),
         text_color=bullColor,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 9 — Net Reward
    table.cell(
         riskPanel,
         0,
         9,
         f_riskText("Net Reward"),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         9,
         accountCurrencySymbol + " " + f_formatNumber(netReward),
         text_color=netReward > 0.0
             ? bullColor
             : bearColor,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 10 — Commission Estimate
    table.cell(
         riskPanel,
         0,
         10,
         f_riskText("Commission Est."),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         10,
         accountCurrencySymbol + " " + f_formatNumber(commissionCost),
         text_color=color.gray,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 11 — Divider
    table.cell(
         riskPanel,
         0,
         11,
         "────────",
         text_color=color.gray,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         11,
         "────────",
         text_color=color.gray,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 12 — Break-Even Win Rate
    table.cell(
         riskPanel,
         0,
         12,
         f_riskText("Break-Even Win% (gross)"),
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         12,
         str.tostring(f_round2(breakEvenWinRate)) + "%",
         text_color=color.orange,
         bgcolor=rbg,
         text_size=panelTextSize)
    // Row 13 — Maximum Trades Before Drawdown Limit
    table.cell(
         riskPanel,
         0,
         13,
         f_riskText("Losses (gross DD ") +
             str.tostring(maxDrawdownPct) +
             "%)",
         text_color=color.white,
         bgcolor=rbg,
         text_size=panelTextSize)
    table.cell(
         riskPanel,
         1,
         13,
         str.tostring(
             math.floor(maxTradesAtRisk)) +
             f_riskText(" losses"),
         text_color=color.orange,
         bgcolor=rbg,
         text_size=panelTextSize)

if barstate.islast and not showRiskPanel
    table.clear(riskPanel, 0, 0, 1, 13)
````
