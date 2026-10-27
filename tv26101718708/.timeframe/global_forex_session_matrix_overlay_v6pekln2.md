# Global Forex Session Matrix Overlay

- url: https://www.tradingview.com/script/V6pekLN2-Global-Forex-Session-Matrix-Overlay/
- type: indicator
- pine_id: PUB;9b8716994e1c4dba8647d20a5a610afe
- version: 1.0

## Description

🌐 Global Forex Session Matrix Overlay

Global Forex Session Matrix Overlay is an educational chart overlay designed to help traders study intraday market behavior using global session timing, key reference levels, trend context, market structure, VWAP, and volume activity in one clean chart view.

This tool helps organize important market information such as session ranges, opening ranges, trading day levels, previous day levels, weekly reference areas, moving average trend context, pivot structure, VWAP value areas, and volume-weighted candle behavior. It is mainly useful for forex and gold chart analysis, especially on intraday timeframes.

The script includes global market session references such as Asian, Sydney, Tokyo, Frankfurt, London, and New York sessions. These session tools help users observe session highs, session lows, opening ranges, and price reactions around important market timing areas. This can support the study of liquidity movement, breakout behavior, rejection areas, and intraday market rhythm.

The overlay also includes key trading day levels such as Trading Day Open, Previous Day High, Previous Day Low, and optional day reference levels. These levels can help traders identify important support and resistance areas, possible breakout zones, and areas where price may react during the trading day.

For higher-timeframe context, the script includes reference levels such as Weekly Initial Balance, Weekly Open, Weekly Close, and optional weekly or monthly range tools. These levels can help users understand whether price is trading above or below important weekly reference points and can support a more structured view of market bias.

The Moving Average Cloud is included to help traders observe trend direction and dynamic support or resistance. When price is trading above the cloud, users may study bullish structure. When price is trading below the cloud, users may study bearish structure. When price is inside or near the cloud, market direction may be less clear and may require additional confirmation.

The VWAP framework can be enabled for value-based analysis. VWAP and optional VWAP bands help users study whether price is trading around value, above value, or below value during the selected anchor period. This can be useful when combined with session levels, structure, and candle confirmation.

The Pivot and Market Structure tools help highlight important swing points and developing structure areas. These can support the study of higher highs, higher lows, lower highs, lower lows, and possible structure shifts. Pivot-based elements should be used with confirmation because developing pivots can update before they are fully confirmed.

The Volume-Weighted Candle Coloring feature helps users visually identify candles with stronger or weaker volume participation. This can be useful for observing momentum, rejection, continuation, and possible exhaustion around important levels. Volume color should not be used alone as an entry reason and should always be combined with price action and structure.

📌 How to Use and Build Entry Ideas

Start by applying the indicator to an intraday forex or gold chart. First, check the active market session and observe where price is trading in relation to the current session range, session high, session low, Trading Day Open, Previous Day High, Previous Day Low, Weekly Open, and Weekly Initial Balance.

A bullish trade idea can be studied when price holds above an important reference level, the Moving Average Cloud supports upward structure, and candles confirm strength after a pullback or breakout. Extra confirmation may come from price holding above VWAP, rejecting a session low, breaking above a previous session high, or forming a higher low structure.

A bearish trade idea can be studied when price rejects an important resistance area, moves below a key reference level, and the Moving Average Cloud or structure supports weakness. Extra confirmation may come from price failing near Previous Day High, rejecting a session high, moving below VWAP, or forming a lower high structure.

Users can also study session range reactions for liquidity context. For example, price reacting around an Asian high or low, New York opening range, Previous Day High, Previous Day Low, Weekly Open, or Weekly Initial Balance can provide useful context. The idea should be confirmed with candle close behavior, market structure, and volume reaction.

When price is inside the Moving Average Cloud, between major levels, or moving without clear structure, it may be better to wait for a cleaner setup. This script is designed to support analysis, not to provide automatic entries.

For safer analysis, avoid making decisions from unfinished candles only. Wait for candle close confirmation, check the nearby support or resistance level, define risk clearly, and use your own trading plan before making any decision.

⚙️ Settings Overview

The indicator includes settings for visual themes, compact dashboard position, session ranges, opening ranges, trading day levels, weekly and monthly reference levels, VWAP tools, pivot and market structure display, moving average cloud settings, volume-weighted candle coloring, event layers, and timezone configuration.

Users can keep the chart simple by enabling only the most important tools, or they can activate more features when deeper market context is needed. Timezone and session settings should be checked carefully so session levels align correctly with the market being analyzed.

⚠️ Limitations

This script does not predict future price movement and does not guarantee any result. Market conditions can change quickly, especially during news, low liquidity, or high volatility periods. Some tools depend on the selected symbol, timeframe, session settings, and timezone.

Developing session ranges, pivots, and structure-related elements may update while candles are still forming. For more reliable analysis, users should wait for confirmed candle closes and avoid making decisions based only on unfinished bars.

📚 Educational Risk Disclaimer

This script is provided for educational and technical analysis only. It is not financial advice and should not be used as the only reason to enter or exit a trade. Trading involves risk, and past market behavior does not guarantee future results. Always use your own confirmation, risk management, and trading plan.

## Source Code

````pine
//@version=6
//====================================================
// LOKKA ALGO
// Educational trading analysis tool.
//====================================================
indicator('Global Forex Session Matrix Overlay', 'Session Matrix Overlay', true, max_lines_count = 500, max_labels_count = 500, max_boxes_count = 500, max_bars_back = 5000, dynamic_requests = true)

// ------------------------------------------------------------------------------------------------------------------ //
// Input Declarations

display = display.all - display.status_line

groupBrand = 'Theme Settings'
brandName = 'Global Forex Session Matrix Overlay'
brandSubtitle = 'Session Matrix Overlay'
brandEmoji = '•'
themePreset = input.string('Aqua Pulse', 'Visual Theme', options = ['Gold', 'Midnight', 'Emerald', 'Rose', 'Aqua Pulse', 'Custom'], group = groupBrand)
masterVisuals = input.bool(true, 'Enable Main Visuals', group = groupBrand)
showEmojiLabels = input.bool(false, 'Session Name Icons', group = groupBrand)
debugLogs = false
panelTransparency = 84
customAccent = #20E0C5
customBull = #18D39B
customBear = #FF5A7A
customSurface = #07111F
customText = #EAF2FF

groupMatrixPanel = 'Dashboard Settings'
showMatrixPanel = input.bool(true, 'Show Compact Dashboard', inline = 'MP1', group = groupMatrixPanel)
matrixPanelMode = input.string('Mobile Compact', 'Layout', options = ['Mobile Compact', 'Balanced Detail'], inline = 'MP1', group = groupMatrixPanel, display = display)
matrixPanelPosition = input.string('Bottom Right', 'Position', options = ['Top Left', 'Top Center', 'Top Right', 'Middle Right', 'Bottom Left', 'Bottom Center', 'Bottom Right'], inline = 'MP2', group = groupMatrixPanel, display = display)
matrixPanelSize = input.string('Tiny', 'Size', options = ['Tiny', 'Small', 'Normal'], inline = 'MP2', group = groupMatrixPanel, display = display)
matrixPanelTransparency = input.int(88, 'Panel Transparency', minval = 0, maxval = 100, group = groupMatrixPanel, display = display)

groupMasterToggles = 'Main Display Toggles'
showSessionRanges = input.bool(true, 'Session & Opening Ranges', group = groupMasterToggles)
showTradingDayLevels = input.bool(true, 'Trading Day Levels', group = groupMasterToggles)
showInstitutionalLevels = input.bool(true, 'Institutional Reference Levels', group = groupMasterToggles)
showVwapSuite = input.bool(true, 'VWAP Suite', group = groupMasterToggles)
showPivotSuite = input.bool(true, 'Pivot & Market Structure', group = groupMasterToggles)
showMASuite = input.bool(true, 'Moving Average Cloud', group = groupMasterToggles)
showVolumeBars = input.bool(true, 'Volume Weighted Candle Coloring', group = groupMasterToggles)
showForexEvents = input.bool(false, 'Forex Events & Volume Trend Layer', group = groupMasterToggles)


enum utcOffsets
    EXCHANGE = 'Exchange'

    // Major Global Trading Centers
    UTCm5_New_York = 'America/New_York'
    UTC0_London = 'Europe/London'
    UTCp9_Tokyo = 'Asia/Tokyo'
    UTCp10_Sydney = 'Australia/Sydney'
    UTCp4_Dubai = 'Asia/Dubai'
    UTCp1_Berlin = 'Europe/Berlin'
    UTCp1_Paris = 'Europe/Paris'
    UTCp3_Istanbul = 'Europe/Istanbul'
    UTCm6_Chicago = 'America/Chicago'
    UTCm8_Los_Angeles = 'America/Los_Angeles'
    UTCp8_Singapore = 'Asia/Singapore'
    UTCp8_Shanghai = 'Asia/Shanghai'
    UTCp9_Seoul = 'Asia/Seoul'
    UTCp5p30_Kolkata = 'Asia/Kolkata'

    // Americas
    UTCm5_Toronto = 'America/Toronto'
    UTCm8_Vancouver = 'America/Vancouver'
    UTCm8_Tijuana = 'America/Tijuana'
    UTCm7_Denver = 'America/Denver'
    UTCm7_Edmonton = 'America/Edmonton'
    UTCm7_Ciudad_Juarez = 'America/Ciudad_Juarez'
    UTCm6_Mexico_City = 'America/Mexico_City'
    UTCm6_Winnipeg = 'America/Winnipeg'
    UTCm6_Costa_Rica = 'America/Costa_Rica'
    UTCm5_Lima = 'America/Lima'
    UTCm5_Bogota = 'America/Bogota'
    UTCm5_Jamaica = 'America/Jamaica'
    UTCm4p30_Caracas = 'America/Caracas'
    UTCm4_Santiago = 'America/Santiago'
    UTCm4_Manaus = 'America/Manaus'
    UTCm4_La_Paz = 'America/La_Paz'
    UTCm4_Santo_Domingo = 'America/Santo_Domingo'
    UTCm3p30_St_Johns = 'America/St_Johns'
    UTCm3_Sao_Paulo = 'America/Sao_Paulo'
    UTCm3_Buenos_Aires = 'America/Argentina/Buenos_Aires'
    UTCm3_Montevideo = 'America/Montevideo'
    UTCm9_Anchorage = 'America/Anchorage'
    UTCm10_Honolulu = 'Pacific/Honolulu'
    UTCm11_Pago_Pago = 'Pacific/Pago_Pago'

    // Europe
    UTC0_Lisbon = 'Europe/Lisbon'
    UTCp1_Madrid = 'Europe/Madrid'
    UTCp1_Warsaw = 'Europe/Warsaw'
    UTCp2_Kyiv = 'Europe/Kyiv'
    UTCp2_Athens = 'Europe/Athens'
    UTCp3_Moscow = 'Europe/Moscow'
    UTCp4_Samara = 'Europe/Samara'

    // Middle East
    UTCp3_Riyadh = 'Asia/Riyadh'
    UTCp3_Baghdad = 'Asia/Baghdad'
    UTCp3p30_Tehran = 'Asia/Tehran'
    UTCp4_Baku = 'Asia/Baku'
    UTCp4_Yerevan = 'Asia/Yerevan'
    UTCp4p30_Kabul = 'Asia/Kabul'
    UTCp2_Jerusalem = 'Asia/Jerusalem'

    // Asia
    UTCp5_Karachi = 'Asia/Karachi'
    UTCp5_Tashkent = 'Asia/Tashkent'
    UTCp5_Yekaterinburg = 'Asia/Yekaterinburg'
    UTCp5p30_Colombo = 'Asia/Colombo'
    UTCp5p45_Kathmandu = 'Asia/Kathmandu'
    UTCp6_Dhaka = 'Asia/Dhaka'
    UTCp6_Almaty = 'Asia/Almaty'
    UTCp6_Omsk = 'Asia/Omsk'
    UTCp6p30_Yangon = 'Asia/Yangon'
    UTCp7_Jakarta = 'Asia/Jakarta'
    UTCp7_Bangkok = 'Asia/Bangkok'
    UTCp7_Krasnoyarsk = 'Asia/Krasnoyarsk'
    UTCp8_Taipei = 'Asia/Taipei'
    UTCp8_Kuala_Lumpur = 'Asia/Kuala_Lumpur'
    UTCp8_Manila = 'Asia/Manila'
    UTCp9_Pyongyang = 'Asia/Pyongyang'
    UTCp9_Yakutsk = 'Asia/Yakutsk'
    UTCp10_Vladivostok = 'Asia/Vladivostok'
    UTCp11_Magadan = 'Asia/Magadan'
    UTCp12_Kamchatka = 'Asia/Kamchatka'

    // Oceania
    UTCp9p30_Adelaide = 'Australia/Adelaide'
    UTCp8_Perth = 'Australia/Perth'
    UTCp10_Port_Moresby = 'Pacific/Port_Moresby'
    UTCp11_Noumea = 'Pacific/Noumea'
    UTCp12_Auckland = 'Pacific/Auckland'
    UTCp12_Fiji = 'Pacific/Fiji'
    UTCp13_Tongatapu = 'Pacific/Tongatapu'
    UTCp14_Kiritimati = 'Pacific/Kiritimati'

    // Africa
    UTC0_Accra = 'Africa/Accra'
    UTC0_Casablanca = 'Africa/Casablanca'
    UTCp1_Lagos = 'Africa/Lagos'
    UTCp1_Algiers = 'Africa/Algiers'
    UTCp2_Cairo = 'Africa/Cairo'
    UTCp2_Johannesburg = 'Africa/Johannesburg'
    UTCp3_Addis_Ababa = 'Africa/Addis_Ababa'

enum rangeOption
	non = 'None'
	or1 = '1m Opening Range'
	or3 = '3m Opening Range'
	or5 = '5m Opening Range'
	or10 = '10m Opening Range'
	or15 = '15m Opening Range'
	or30 = '30m Opening Range'
	or60 = '60m Opening Range'
	rnge = 'Full Range'

utcTip = 'Market session defaults are calibrated to the America/New_York timezone.\n\nIf you change the Indicator Timezone, session times must be adjusted accordingly to maintain alignment with actual market hours.'
utcOffsetIn = str.tostring(input.enum(utcOffsets.UTCm5_New_York, 'Indicator Timezone', tooltip = utcTip, inline = 'inline', display = display))

fxGroupChannels = 'Asian & European Openning Channels'

asianShow = input.bool(true, '', inline = 'Asian', group = fxGroupChannels) //, tooltip = 'Asian Opening Channel is the range between Tokyo Open and Hong Kong Open')
asianName = input.string('Asian', '', inline = 'Asian', group = fxGroupChannels, display = display)
asianRange = input.session('1900-2000', '', inline = 'Asian', group = fxGroupChannels, display = display)
asianColor = input.color(color.gray, '', inline = 'Asian', group = fxGroupChannels)

europeanShow = input.bool(false, '', inline = 'European', group = fxGroupChannels) //, tooltip = 'European Opening Channel is the range between Frankfurt Open and London Open')
europeanName = input.string('European', '', inline = 'European', group = fxGroupChannels, display = display)
europeanRange = input.session('0200-0300', '', inline = 'European', group = fxGroupChannels, display = display)
europeanColor = input.color(color.gray, '', inline = 'European', group = fxGroupChannels)

fxGroupSydney = 'Sydney Market'
sydneyName = input.string('Sydney', '', inline = 'sydney', group = fxGroupSydney, display = display)
sydneyRange = input.session('1700-0200', '', inline = 'sydney', group = fxGroupSydney, display = display)
sydneyColor = input.color(#556080, '', inline = 'sydney', group = fxGroupSydney)
sydneyShow = str.tostring(input.enum(rangeOption.non, ' Session Range', inline = 'SY', group = fxGroupSydney, display = display))
sydneyLast = input.int(1, ' Show Recent', minval = 1, inline = 'SY', group = fxGroupSydney, display = display)

fxGroupTokyo = 'Tokyo Market'
tokyoName = input.string('Tokyo', '', inline = 'tokyo', group = fxGroupTokyo, display = display)
tokyoRange = input.session('1900-0400', '', inline = 'tokyo', group = fxGroupTokyo, display = display)
tokyoColor = input.color(#C080C0, '', inline = 'tokyo', group = fxGroupTokyo)
tokyoShow = str.tostring(input.enum(rangeOption.non, ' Session Range', inline = 'tk', group = fxGroupTokyo, display = display))
tokyoLast = input.int(1, ' Show Recent', inline = 'tk', minval = 1, group = fxGroupTokyo, display = display)

fxGroupFrankfurt = 'Frankfurt Market'
frankfurtName = input.string('Frankfurt', '', inline = 'frankfurt', group = fxGroupFrankfurt, display = display)
frankfurtRange = input.session('0200-1000', '', inline = 'frankfurt', group = fxGroupFrankfurt, display = display)
frankfurtColor = input.color(#E6D76A, '', inline = 'frankfurt', group = fxGroupFrankfurt)
frankfurtShow = str.tostring(input.enum(rangeOption.or1, ' Session Range', inline = 'fr', group = fxGroupFrankfurt, display = display))
frankfurtLast = input.int(1, ' Show Recent', inline = 'fr', minval = 1, group = fxGroupFrankfurt, display = display)

London = 'London Market'
londonName = input.string('London', '', inline = 'london', group = London, display = display)
londonRange = input.session('0300-1200', '', inline = 'london', group = London, display = display)
londonColor = input.color(#7DA3E0, '', inline = 'london', group = London)
londonShow = str.tostring(input.enum(rangeOption.non, ' Session Range', inline = 'ln', group = London, display = display))
londonLast = input.int(1, ' Show Recent', inline = 'ln', minval = 1, group = London, display = display)

fxGroupNewYork = 'New York Market'
newYorkName = input.string('New York', '', inline = 'newYork', group = fxGroupNewYork, display = display)
newYorkRange = input.session('0800-1700', '', inline = 'newYork', group = fxGroupNewYork, display = display)
newYorkColor = input.color(#7CC58C, '', inline = 'newYork', group = fxGroupNewYork)
newYorkShow = str.tostring(input.enum(rangeOption.or5, ' Session Range', inline = 'ny', group = fxGroupNewYork, display = display))
newYorkLast = input.int(1, ' Show Recent', inline = 'ny', minval = 1, group = fxGroupNewYork, display = display)

group_htf = 'Trading Day Levels'

dayOpen = input.string('Open', 'Trading Day', 
    options = ['None', 'Open', '1m Opening Range', '3m Opening Range', '5m Opening Range', '10m Opening Range', '15m Opening Range', '30m Opening Range', '60m Opening Range'], inline = 'DO', group = group_htf, display = display)
dayLast = input.int(1, 'Show Recent', minval = 1, inline = 'DO', group = group_htf, display = display)
dayColor = input.color(#90bff9, '', inline = 'DO', group = group_htf)

dayCandle = input.bool(true, 'Trading Day Candle | Offset', inline = 'dc', group = group_htf,
     tooltip = 'Displays the current trading day candle with optional horizontal offset for improved visual separation.')
dayOffset = input.int(33, '', minval = 1, inline = 'dc', group = group_htf, display = display)
dayColorUp = input.color(#089981, '', inline = 'dc', group = group_htf)
dayColorDn = input.color(#F23645, '', inline = 'dc', group = group_htf)

dayRefTip = 'Reference Levels estimate potential support and resistance using volatility-based models.\n\n' +
             '• Average True Range (ATR): Adapts dynamically to recent volatility\n' +
             '• Previous Day Range (PDH–PDL): Derived from prior session expansion\n\n' +
             'These levels help anticipate breakout phases, expansion targets, and mean-reversion zones.'

dayRefLevels = input.string('Previous Day Range (PDH - PDL)', 'Day Reference Levels', options = ['None', 'Average True Range (ATR)', 'Previous Day Range (PDH - PDL)'], inline = 'REFL', group = group_htf, tooltip = dayRefTip, display = display)
dayRefColor = input.color(#E39A5B, '', inline = 'REFL', group = group_htf)
refAlert = input.bool(false, 'Alerts', inline = 'REFL', group = group_htf)

dayATRLength = input.int(5, '  ATR Length', minval = 1, group = group_htf, tooltip = 'Period used for ATR calculation when ATR-based reference levels are selected.', display = display)
dayRefLevel1 = input.float(0.5, '  Level Multiplier #1', minval = 0, step = 0.1, inline = 'Ref', group = group_htf, display = display)
dayRefLevel2 = input.float(1.0, '#2', minval = 0, step = 0.1, inline = 'Ref', group = group_htf, display = display)
//dayRefLevel3 = input.float(1.0, '#3', minval = 0, step = 0.1, inline = 'Ref', group = group_htf, display = display)

refLast = input.int(1, '  Show Recent Levels', minval = 1, group = group_htf, display = display)

pdCShow = input.bool(false, 'Previous Day Close', inline = 'pd', group = group_htf,
         tooltip = 'Previous Day Close\n' +
             'Plots the prior trading day’s closing price.\n' +
             '• Combine with the current day’s Open to visualize the New Day Opening Gap (NDOG).\n' +
             '• Helps identify early-session support/resistance levels and potential breakout zones.\n' +
             '• Useful for anticipating intraday trend direction and initial liquidity zones.\n\n' +
             'Previous Day High / Low\n' +
             'Plots the prior trading day’s High and Low levels.\n' +
             'Commonly used as liquidity references and breakout confirmation zones.')

pdCColor = input.color(#90bff9, '', inline = 'pd', group = group_htf)

pdHLShow = input.bool(true, 'Previous Day High / Low', inline = 'pd', group = group_htf)
pdHLColor = input.color(#90bff9, '', inline = 'pd', group = group_htf)


group_htf2 = 'Institutional Reference Levels'

monHLShow = input.bool(true, 'Weekly Initial Balance (WIB)', inline = 'pd2', group = group_htf2,
     tooltip = 'Tracks the High, Low, and Midpoint formed during Monday’s trading session.\n\n' +
                 'These levels define the early-week price discovery range and are widely used to identify liquidity zones, breakout potential, and directional bias for the remainder of the week.')
monHLColor = input.color(#5b9cf6, '', inline = 'pd2', group = group_htf2)

weekOpen = input.bool(true, 'Weekly Open', inline = 'pd3', group = group_htf2)
weekColor = input.color(#5b9cf6, '', inline = 'pd3', group = group_htf2)

weeklyClose = input.bool(true, 'Weekly Close', inline = 'pd3', group = group_htf2,
     tooltip = 'Weekly Open\nPlots the opening price of the current trading week.\n\n' +
                 'Often used as a directional benchmark and equilibrium reference for weekly price action.\n\n' +
                 'Weekly Close\nDisplays the official weekly closing price, typically defined by Friday’s session close.\n\n' +
                 'This level often acts as a key institutional reference for positioning, weekend sentiment, and potential gap reactions at the next week’s open.\n\n' +
                 'The price difference between the previous week’s close and the new week’s open represents New Week Opening Gap (NWOG)\n\n' +
                 '• Highlights potential liquidity zones where stop orders may cluster.\n' +
                 '• Acts as early-week support/resistance, providing clues for trend continuation or reversal.\n' +
                 '• Gauges market sentiment at weekly open: bullish if gap up, bearish if gap down.')

weeklyCColor = input.color(#5b9cf6, '', inline = 'pd3', group = group_htf2)

nwog = input.bool(false, 'Gap Fill', inline = 'pd3', group = group_htf2)

weekHL = input.bool(false, 'Weekly Range (High / Mid / Low)', inline = 'WO', group = group_htf2,
     tooltip = 'Displays the current week’s High, Low, and Midpoint levels.\n\n' +
                 'These boundaries help identify expansion phases, range compression, and key liquidity zones within the weekly structure.')
weekHLColor = input.color(#5b9cf6, '', inline = 'WO', group = group_htf2)

monthOpen = input.bool(false, 'Monthly Open', inline = 'MO', group = group_htf2,
     tooltip = 'Plots the opening price of the current month.\n\n' +
                 'Commonly used as a higher-timeframe bias reference and macro equilibrium level.')
monthColor = input.color(#3179f5, '', inline = 'MO', group = group_htf2)

monthHL = input.bool(false, 'Monthly Range (High / Mid / Low)', inline = 'MO2', group = group_htf2,
     tooltip = 'Displays the current month’s High, Low, and Midpoint levels.\n\n' +
                 'These levels define macro range boundaries, liquidity pools, and potential expansion zones.')
monthHLColor = input.color(#3179f5, '', inline = 'MO2', group = group_htf2)

group_vwap = 'VWAP Framework'
ttip_vwap = 'The Volume Weighted Average Price (VWAP) calculates the average price weighted by traded volume.\n\n' +
             'It helps assess whether price is trading at a theme or discount relative to value, ' +
             'providing insight into intraday sentiment, trend positioning, and institutional bias.'

ttip_vwapAnchor = 'Anchor Modes:\n\n' +
                  '• Auto:\n' +
                  '  Automatically adapts anchor timeframe based on chart resolution:\n' +
                  '  - ≤ 15m → Daily\n' +
                  '  - > 15m intraday → Weekly\n' +
                  '  - Daily → Monthly\n' +
                  '  - Weekly → Quarterly\n' +
                  '  - Monthly → Yearly\n\n' +
                  '• Interactive:\n' +
                  '  Allows manual placement of the anchor point directly on the chart.\n' +
                  '  Use “Reset points” from the indicator menu to reposition.\n\n' +
                  '• Manual:\n' +
                  '  Uses a fixed higher timeframe anchor independent of chart timeframe.'

isVwap = input.bool(false, 'Volume Weighted Average Price (VWAP)', group = group_vwap, tooltip = ttip_vwap)
htf_tf = input.string('Auto', '  Anchor Mode', options = ['Auto', 'Interactive', '15 Minutes', '1 Hour', '4 Hours', 'Daily', 'Weekly', 'Monthly', 'Quarterly', 'Yearly'], inline = 'vwap', group = group_vwap, tooltip = ttip_vwapAnchor, display = display)
vwapAnchor = htf_tf == '15 Minutes' ? '15' : htf_tf == '1 Hour' ? '60' : htf_tf == '4 Hours' ? '240' : htf_tf == 'Daily' ? 'D' : htf_tf == 'Weekly' ? 'W' : htf_tf == 'Monthly' ? 'M' : htf_tf == 'Quarterly' ? '3M' : htf_tf == 'Yearly' ? '12M' : timeframe.isintraday and (timeframe.period == '1' or timeframe.period == '3' or timeframe.period == '5' or timeframe.period == '15') ? 'D' : timeframe.isintraday and (timeframe.period == '30' or timeframe.period == '45' or timeframe.period == '60' or timeframe.period == '120' or timeframe.period == '180' or timeframe.period == '240') ? 'W' : timeframe.isdaily ? 'M' : timeframe.isweekly ? '3M' : timeframe.ismonthly ? '12M' : '3M'

vwapSource = input.source(hlc3, 'Source', inline = 'vwap', group = group_vwap, display = display)
startDate = input.time(timestamp('1 Mar 2026'), '  Interactive Anchor', inline = 'inn', group = group_vwap, display = display)

vwapBand1 = input.bool(false, 'Band #1', inline = 'B1', group = group_vwap)
stdevMult1 = input.float(1, '', step = .1, inline = 'B1', group = group_vwap, display = display)
vwapBand2 = input.bool(true, 'Band #2', inline = 'B1', group = group_vwap)
stdevMult2 = input.float(2, '', step = .1, inline = 'B1', group = group_vwap, display = display)

ttip_vwapHL = 'High/Low VWAPs compute separate VWAP curves using the highest and lowest prices within the selected anchor period.\n\n' +
              'These act as dynamic support and resistance zones and help define value extremes across the anchor timeframe.'
isVwapHL = input.bool(false, 'High/Low VWAPs', inline = 'B1H', group = group_vwap, tooltip = ttip_vwapHL)
vwapShowHL = input.string('High/Low of Week', '', options = ['High/Low of Day', 'High/Low of Week', 'High/Low of Month'], inline = 'B1H', group = group_vwap, display = display)
vwapColorH = input.color(#F23645, '', inline = 'B1H', group = group_vwap) 
vwapColorL = input.color(#089981, '', inline = 'B1H', group = group_vwap) 

groupPvt = 'Pivot & Market Structure Engine'
tooltip_pvt = 'The Pivot Engine identifies potential reversal zones and developing swing structures.\n\n' +
              'Core Capabilities:\n' +
              '• Detects standard Pivot Highs/Lows using user-defined left/right lengths\n' +
              '• Detects short-term pivots (3-bar logic) for early structure awareness\n' +
              '• Analyzes price movement and cumulative traded volume between pivot points\n\n' +
              'Alert Mode:\n' +
              'Enables early notifications for temporary swing points detected after three bars. ' +
              'These are developing pivots and may repaint. Use them as preparation signals, not confirmation triggers.'

dispPVT = input.bool(true, 'Pivot Detection | Enable Alerts', inline = 'MS', group = groupPvt, tooltip = tooltip_pvt)
pvtAlert = input.bool(false, '', inline = 'MS', group = groupPvt)

msTip = 'Automatically detects real-time market structure shifts, including higher highs/lows and lower highs/lows.\n\n' +
         'Helps identify trend transitions, continuation phases, and structural breaks across timeframes.'

marketS = input.bool(false, 'Market Structure Shifts | Enable Alerts', inline = 'MS2', group = groupPvt, tooltip = msTip)
msAlert = input.bool(false, '', inline = 'MS2', group = groupPvt)

pvtLength = input.int(20, '  Pivot Left/Right Length', minval = 1, group = groupPvt, display = display)
pvtText = input.string('Small', '  Label Text', options = ['Tiny', 'Small', 'Normal'], inline = 'Levels', group = groupPvt, display = display)
pvtTextSize = pvtText == 'Small' ? size.small : pvtText == 'Normal' ? size.normal : size.tiny
pvtPrice = input.bool(false, 'Price', inline = 'Levels', group = groupPvt)
pvtChange = input.bool(false, 'Change', inline = 'Levels', group = groupPvt)
pvtVolume = input.bool(false, 'Volume', inline = 'Levels', group = groupPvt)

groupMA = 'Moving Average Cloud'
ttip_ma = 'The Moving Average Cloud provides visual guidance on trend direction, momentum shifts, and dynamic support/resistance zones.\n\n' +
          'The relationship between the two averages helps identify structural transitions, including bullish and bearish crossover events.'
maDisplay = input.bool(true, 'Moving Average Cloud | Enable Alerts', inline = 'MAA', group = groupMA, tooltip = ttip_ma)
maAlert = input.bool(false, '', inline = 'MAA', group = groupMA)

maType1 = input.string('EMA', ' ', options = ['SMA', 'EMA', 'HMA', 'RMA', 'WMA', 'VWMA'], inline = 'MA', group = groupMA, display = display)
maSource1 = input.source(close, '', inline = 'MA', group = groupMA, display = display)
maLength1 = input.int(50, '', minval = 1, inline = 'MA', group = groupMA, display = display)
maColor1 = input.color(#089981, '', inline = 'MA', group = groupMA)

maType2 = input.string('EMA', ' ', options = ['SMA', 'EMA', 'HMA', 'RMA', 'WMA', 'VWMA'], inline = 'MA2', group = groupMA, display = display)
maSource2 = input.source(close, '', inline = 'MA2', group = groupMA, display = display)
maLength2 = input.int(200, '', minval = 1, inline = 'MA2', group = groupMA, display = display)
maColor2 = input.color(#F23645, '', inline = 'MA2', group = groupMA)

groupVWCB = 'Volume-Weighted Candle Intelligence'
vwcb = input.bool(true, 'Volume-Weighted Coloring | Enable Alerts', inline = 'VAlrt', group = groupVWCB,
     tooltip = 'Colors price bars based on current volume relative to its moving average.\n\n' +
               'Highlights conviction-driven activity and abnormal participation shifts.')
volAlert = input.bool(false, '', inline = 'VAlrt', group = groupVWCB)
vwcbLen = input.int(21, '  Volume MA Length', group = groupVWCB, display = display)
hThresh = input.float(1.618, '  High Thresh', minval = 1., step = .1, inline = 'dummy1', group = groupVWCB, display = display)
lThresh = input.float(0.618, 'Low Thresh', minval = .1, step = .1, inline = 'dummy1', group = groupVWCB, display = display)
showEnhancedCandleColors = input.bool(true, 'Show Enhanced Candle Colors', inline = 'PCC1', group = groupVWCB)
candleColorMode = input.string('Volume + Trend', 'Candle Color Mode', options = ['Volume', 'Trend', 'Volume + Trend'], inline = 'PCC1', group = groupVWCB, display = display)
strongBullColor = input.color(#00FFC2, 'Strong Bull Color', inline = 'PCC2', group = groupVWCB)
strongBearColor = input.color(#FF1E5A, 'Strong Bear Color', inline = 'PCC2', group = groupVWCB)
neutralCandleColor = input.color(#8592A6, 'Neutral Color', inline = 'PCC3', group = groupVWCB)

eventsGroup = 'Forex Events & Volume Trend Layer'

ttip_events = 'This module provides a graphical representation* of typical trading volume behavior**, real-time volume bars, and major Forex market opening/closing events***.\n\n' +
     '* Displayed on 1-hour and lower timeframes.\n' +
     '** Typical volume patterns are modeled using the two most actively traded currencies (USD & EUR). Volume dynamics may differ for other currency groups, particularly Asian sessions.\n' +
     '*** Event schedule does not account for daylight saving adjustments and may show minor timing deviations during seasonal transitions.'

forexEvents = input.bool(false, 'Forex Market Events & Volume Trends', group = eventsGroup, tooltip = ttip_events)
oscVO = input.int(0, '  Vertical Offset', minval = -3, maxval = 10, inline = 'evt', group = eventsGroup, display = display) / 10
oscHight = 11 - input.int(7, 'Height', minval = 1, maxval = 10, inline = 'evt', group = eventsGroup, display = display)

groupTZ = 'Exchange Timezone Settings'
sydneyLocal = str.tostring(input.enum(utcOffsets.UTCp10_Sydney, '  Sydney TZ ', inline = 'TZ1', group = groupTZ, display = display))
tokyoLocal = str.tostring(input.enum(utcOffsets.UTCp9_Tokyo, 'Tokyo TZ ', inline = 'TZ1', group = groupTZ, display = display))
frankfurtLocal = str.tostring(input.enum(utcOffsets.UTCp1_Berlin, '  Frankfurt TZ', group = groupTZ, inline = 'TZ2', display = display))
londonLocal = str.tostring(input.enum(utcOffsets.UTC0_London, 'London TZ', group = groupTZ, inline = 'TZ2', display = display))
newYorkLocal = str.tostring(input.enum(utcOffsets.UTCm5_New_York, '        New York TZ', group = groupTZ, inline = 'TZ3', display = display))

// ------------------------------------------------------------------------------------------------------------------ //
// Theme Engine

rgbPhase = bar_index * 0.035
rgbR = int(math.round(127.5 + 127.5 * math.sin(rgbPhase)))
rgbG = int(math.round(127.5 + 127.5 * math.sin(rgbPhase + 2.0943951024)))
rgbB = int(math.round(127.5 + 127.5 * math.sin(rgbPhase + 4.1887902048)))
rgbGlow = color.rgb(rgbR, rgbG, rgbB)

presetAccent = switch themePreset
    'Gold' => #FFD166
    'Midnight' => #56A3FF
    'Emerald' => #18D39B
    'Rose' => #FF6BAA
    'Aqua Pulse' => rgbGlow
    => customAccent

presetBull = switch themePreset
    'Gold' => #1ED7A6
    'Midnight' => #39C0ED
    'Emerald' => #00E6A8
    'Rose' => #44F2B2
    'Aqua Pulse' => #00E6A8
    => customBull

presetBear = switch themePreset
    'Gold' => #FF4D6D
    'Midnight' => #FF6678
    'Emerald' => #FF6F61
    'Rose' => #FF4FA3
    'Aqua Pulse' => #FF4D6D
    => customBear

presetSurface = switch themePreset
    'Gold' => #121722
    'Midnight' => #0B172A
    'Emerald' => #0B1E19
    'Rose' => #1B0D26
    'Aqua Pulse' => #080D18
    => customSurface

presetText = switch themePreset
    'Gold' => #FFF8E6
    'Midnight' => #EAF4FF
    'Emerald' => #ECFFF7
    'Rose' => #FFF0F8
    'Aqua Pulse' => #F4F7FB
    => customText

themeAccent = themePreset == 'Custom' ? customAccent : presetAccent
themeBull = themePreset == 'Custom' ? customBull : presetBull
themeBear = themePreset == 'Custom' ? customBear : presetBear
themeSurface = themePreset == 'Custom' ? customSurface : presetSurface
themeText = themePreset == 'Custom' ? customText : presetText
themeSurfaceSoft = color.new(themeSurface, panelTransparency)
themeAccentSoft = color.new(themeAccent, panelTransparency)
themeGlass = color.new(themeSurface, math.min(96, math.max(55, panelTransparency)))
themePanelBg = color.new(themeSurface, matrixPanelTransparency)
themePanelBgAlt = color.new(themeSurface, math.min(96, matrixPanelTransparency + 7))
themeDivider = color.new(themeAccent, 58)
themeNote = 'Educational Analysis Tool'
volumeBullStrong = showEnhancedCandleColors ? strongBullColor : themeBull
volumeBearStrong = showEnhancedCandleColors ? strongBearColor : themeBear
volumeBullSoft = color.new(showEnhancedCandleColors ? strongBullColor : themeBull, 45)
volumeBearSoft = color.new(showEnhancedCandleColors ? strongBearColor : themeAccent, 45)

sessionRangesOn = masterVisuals and showSessionRanges
tradingDayLevelsOn = masterVisuals and showTradingDayLevels
institutionalLevelsOn = masterVisuals and showInstitutionalLevels
vwapSuiteOn = masterVisuals and showVwapSuite
pivotSuiteOn = masterVisuals and showPivotSuite
maSuiteOn = masterVisuals and showMASuite
volumeBarsOn = masterVisuals and showVolumeBars
eventsSuiteOn = masterVisuals and showForexEvents
tableSuiteOn = false  // small session table removed for clean publish/mobile layout

sydneyLabelTxt = (showEmojiLabels ? '🌏 ' : '') + str.upper(sydneyName)
tokyoLabelTxt = (showEmojiLabels ? '🗼 ' : '') + str.upper(tokyoName)
frankfurtLabelTxt = (showEmojiLabels ? '🏦 ' : '') + str.upper(frankfurtName)
londonLabelTxt = (showEmojiLabels ? '💷 ' : '') + str.upper(londonName)
newYorkLabelTxt = (showEmojiLabels ? '🗽 ' : '') + str.upper(newYorkName)
brandBadgeText = brandEmoji + ' LOKKA ALGO'
brandTooltip = brandSubtitle + '\nTheme · ' + themePreset


// ------------------------------------------------------------------------------------------------------------------ //
// User Defined Types

utcOffset = utcOffsetIn == 'Exchange' ? syminfo.timezone : utcOffsetIn

noColor = #00000000

dayChange = timeframe.change('D')
fxChartTF = timeframe.in_seconds() / 60 <= 60 and not timeframe.isseconds
dayChartTF = timeframe.in_seconds() / 60 <= 240 and not timeframe.isseconds
nzVolume = nz(volume)
isVoly = ta.cum(nzVolume) > 0

// ------------------------------------------------------------------------------------------------------------------ //
// Global Functions / Methods

lnStyle(style) =>
    switch style
        'Solid' => line.style_solid
        'Dashed' => line.style_dashed
        'Dotted' => line.style_dotted

posFromString(pos) =>
    switch pos
        'Top Left' => position.top_left
        'Top Center' => position.top_center
        'Top Right' => position.top_right
        'Middle Right' => position.middle_right
        'Bottom Left' => position.bottom_left
        'Bottom Center' => position.bottom_center
        'Bottom Right' => position.bottom_right
        => position.top_right

wmPosFromString(pos) =>
    switch pos
        'Top Center' => position.top_center
        'Top Right' => position.top_right
        'Bottom Right' => position.bottom_right
        => position.top_center

sizeFromString(txtSize) =>
    txtSize == 'Tiny' or txtSize == 'Compact' ? size.tiny : txtSize == 'Normal' or txtSize == 'Large' ? size.normal : size.small

fmtPrice(v) =>
    na(v) ? '—' : str.tostring(v, format.mintick)

clearTable(tableId, cols, rows) =>
    for c = 0 to cols - 1
        for r = 0 to rows - 1
            table.cell(tableId, c, r, '', text_color = noColor, bgcolor = noColor, text_size = size.tiny)

hideTable(tableId, cols, rows) =>
    clearTable(tableId, cols, rows)
    table.set_frame_color(tableId, noColor)
    table.set_border_color(tableId, noColor)

timeInRange(sessRange, utc) =>
    not na(time('1', sessRange, utc)) ? true : false

timeRange(opt, sessRange) =>
    if opt == 'Full Range'
        sessRange
    else if str.contains(opt, 'Opening Range') //sessRange != ''
        srOH = int(str.tonumber(str.substring(sessRange, 0, 2)))
        srOM = int(str.tonumber(str.substring(sessRange, 2, 4)))

        n = str.tonumber(str.substring(opt, 0, str.pos(opt, 'm ')))
        cH = (srOM + n) % 60 == srOM + n ? srOH : (srOH + 1) % 24
        cM = (srOM + n) % 60

        str.substring(sessRange, 0, 2) + str.substring(sessRange, 2, 5) + (cH < 10 ? '0' : '') + str.tostring(cH) + (cM < 10 ? '0' : '') + str.tostring(cM)

timeRange(opt, startTime, utc) =>
    sessRange = str.format_time(startTime, 'HHmm', utc)

    srOH = int(str.tonumber(str.substring(sessRange, 0, 2)))
    srOM = int(str.tonumber(str.substring(sessRange, 2, 4)))
    srOH := str.contains(syminfo.prefix, 'BIST') ? (srOH + 1) % 24 : srOH
    srOM := str.contains(syminfo.prefix, 'BIST') ? 0 : srOM - srOM % 5 // workaround 

    n = str.tonumber(str.substring(opt, 0, str.pos(opt, 'm ')))
    cH = (srOM + n) % 60 == srOM + n ? srOH : (srOH + 1) % 24
    cM = (srOM + n) % 60

    (srOH < 10 ? '0' : '') + str.tostring(srOH) + (srOM < 10 ? '0' : '') + str.tostring(srOM) + '-' + (cH < 10 ? '0' : '') + str.tostring(cH) + (cM < 10 ? '0' : '') + str.tostring(cM)

// ------------------------------------------------------------------------------------------------------------------ //
// Process Market Ranges

type LEVEL
	line ln
	label lb

type RANGE
	float rHigh
	float rLow
	box bxTxtBg
	label lbTop
	label lbAvg
	label lbBtm
	line lnTop
	line lnAvg
	line lnBtm
	bool topBrk
	bool btmBrk

method updateRange(RANGE this, H, L, name) =>
    this.lnTop.set_y1(H)
    this.lnTop.set_xy2(bar_index, H)
    this.lnAvg.set_y1(math.avg(H, L))
    this.lnAvg.set_xy2(bar_index, math.avg(H, L))
    this.lnBtm.set_y1(L)
    this.lnBtm.set_xy2(bar_index, L)

    this.bxTxtBg.set_top(H)
    this.bxTxtBg.set_rightbottom(bar_index, L)

    this.lbTop.set_xy(bar_index, H)
    this.lbTop.set_tooltip(name + ' High · ' + str.tostring(H, format.mintick))
    this.lbAvg.set_xy(bar_index, math.avg(H, L))
    this.lbAvg.set_tooltip(name + ' Mean · ' + str.tostring(math.avg(H, L), format.mintick))
    this.lbBtm.set_xy(bar_index, L)
    this.lbBtm.set_tooltip(name + ' Low · ' + str.tostring(L, format.mintick))

ltf = timeframe.isminutes and timeframe.multiplier == 1 ? '15S' : timeframe.isseconds ? '1S' : '1'

renderRange(show, name, sessRange, color, last, utc, sessFull) =>

    if show != 'None'

        var array<RANGE> rngArray = array.new<RANGE>()

        if rngArray.size() > last
            lastRNG = rngArray.pop()
            lastRNG.bxTxtBg.delete()
            lastRNG.lbTop.delete()
            lastRNG.lbAvg.delete()
            lastRNG.lbBtm.delete()
            lastRNG.lnTop.delete()
            lastRNG.lnAvg.delete()
            lastRNG.lnBtm.delete()

        var bool processRange = false
        var int barIndex = na
        extend = show != 'Full Range' 

        [ltfSession, ltfSessionFull, ltfHigh, ltfLow]  = request.security_lower_tf(syminfo.tickerid, ltf, [timeInRange(sessRange, utc), timeInRange(sessFull, utc), high, low])//, calc_bars_count = 60)

        if ltfSession.some() and not processRange
            barIndex := bar_index

            sliceHigh = ltfHigh.slice(ltfSession.indexof(true), ltfSession.lastindexof(true) + 1)
            rangeHigh = sliceHigh.max()
            sliceLow  = ltfLow. slice(ltfSession.indexof(true), ltfSession.lastindexof(true) + 1)
            rangeLow  = sliceLow.min()

            if ltfHigh.size() == ltfSession.lastindexof(true) + 1
                processRange := true
                processRange

            rngArray.unshift(
                 RANGE.new(rangeHigh, rangeLow, 
                  box.new  (bar_index, rangeHigh, bar_index, rangeLow, color.new(color, 18), bgcolor = extend ? color.new(color, 78) : color.new(color, 88), text = extend and show != 'Channel' ? '' : '  ' + str.upper(name), text_size = size.tiny, text_color = color.new(color, 0), text_halign = text.align_left, text_valign = text.align_top), 
                  label.new(bar_index, rangeHigh, name + ' High', color = color.new(#000000, 92), style = label.style_label_left, textcolor = color.new(color, 4), size = size.tiny, tooltip = name + ' ' + show + ' High · ' + str.tostring(rangeHigh, format.mintick)), 
                  label.new(bar_index, math.avg(rangeHigh, rangeLow), name + ' Mean', color = noColor, style = label.style_label_left, textcolor = noColor, size = size.tiny, tooltip = name + ' ' + show + ' Mean · ' + str.tostring(math.avg(rangeHigh, rangeLow), format.mintick)), 
                  label.new(bar_index, rangeLow, name + ' Low', color = color.new(#000000, 92), style = label.style_label_left, textcolor = color.new(color, 4), size = size.tiny, tooltip = name + ' ' + show + ' Low · ' + str.tostring(rangeLow, format.mintick)), 
                  line.new (bar_index, rangeHigh, bar_index, rangeHigh, color = color.new(color, 0), width = 1), line.new(bar_index, math.avg(rangeHigh, rangeLow), bar_index, math.avg(rangeHigh, rangeLow), color = color.new(color, 25), style = line.style_dotted), 
                  line.new (bar_index, rangeLow, bar_index, rangeLow, color = color.new(color, 0), width = 1), 
                  false, false))

            if name == 'Day'
                linefill.new(rngArray.first().lnTop, rngArray.first().lnBtm, color.new(color, 95))

        if rngArray.size() > 0 and bar_index > barIndex
            first = rngArray.first()

            if processRange
                if ltfSession.every()
                    first.rHigh := math.max(first.rHigh, ltfHigh.max())
                    first.rLow  := math.min(first.rLow, ltfLow.min())
                    first.rLow

                else if ltfSession.some()
                    sliceHigh = ltfHigh.slice(0, ltfSession.lastindexof(true) + 1)
                    first.rHigh := math.max(first.rHigh, sliceHigh.max())
                    sliceLow  = ltfLow. slice(0, ltfSession.lastindexof(true) + 1)
                    first.rLow := math.min(first.rLow, sliceLow.min())
                    first.rLow

                if ltfSession.size() > 0
                    if not ltfSession.last()
                        processRange := false
                        processRange
                    else
                        first.updateRange(first.rHigh, first.rLow, name + ' ' + show)

                true
            else

                if extend
                    if ltfSessionFull.size() > 0
                        sessionActive = ltfSessionFull.last()
                        if sessionActive or name == 'Day' or name == 'Asian' or name == 'European'
                            first.lnTop.set_x2(bar_index + 1)
                            first.lbTop.set_x(bar_index + 1)

                            first.lnAvg.set_x2(bar_index + 1)
                            first.lbAvg.set_x(bar_index + 1)

                            first.lnBtm.set_x2(bar_index + 1)
                            first.lbBtm.set_x(bar_index + 1)
                else
                    if not first.topBrk
                        if high > first.rHigh
                            first.topBrk := true
                            first.topBrk
                        first.lnTop.set_x2(bar_index)
                        first.lbTop.set_x(bar_index)

                    if not first.btmBrk
                        if low < first.rLow
                            first.btmBrk := true
                            first.btmBrk
                        first.lnBtm.set_x2(bar_index)
                        first.lbBtm.set_x(bar_index)
                true

if sessionRangesOn and fxChartTF and syminfo.type != 'stock' and syminfo.type != 'bond' and syminfo.type != 'fund'
    renderRange(asianShow ? 'Channel' : 'None', asianName, asianRange, asianColor, 1, utcOffset, asianRange)
    renderRange(europeanShow ? 'Channel' : 'None', europeanName, europeanRange, europeanColor, 1, utcOffset, europeanRange)

    renderRange(sydneyShow, sydneyName, timeRange(sydneyShow, sydneyRange), sydneyColor, sydneyLast, utcOffset, sydneyRange)
    renderRange(tokyoShow, tokyoName, timeRange(tokyoShow, tokyoRange), tokyoColor, tokyoLast, utcOffset, tokyoRange)
    renderRange(frankfurtShow, frankfurtName, timeRange(frankfurtShow, frankfurtRange), frankfurtColor, frankfurtLast, utcOffset, frankfurtRange)
    renderRange(londonShow, londonName, timeRange(londonShow, londonRange), londonColor, londonLast, utcOffset, londonRange)
    renderRange(newYorkShow, newYorkName, timeRange(newYorkShow, newYorkRange), newYorkColor, newYorkLast, utcOffset, newYorkRange)


// Process Market Ranges
// ------------------------------------------------------------------------------------------------------------------ //
// Trading Day

renderLevel(name, start, end, value, color, style, width, last, tip) =>
    var array<LEVEL> levelArray = array.new<LEVEL>(0, LEVEL.new())

    if levelArray.size() > last - 1
        lastLVL = levelArray.pop()
        lastLVL.ln.delete()
        lastLVL.lb.delete()

    if levelArray.size() > 0
        for i = 0 to levelArray.size() - 1
            levelArray.get(i).lb.set_textcolor(noColor)

    levelArray.unshift(
         LEVEL.new(
             line.new(start, value, end, value, xloc.bar_time, color = color.new(color, 5), style = style, width = width), 
             label.new(end, value, name + ' · ' + str.tostring(value, format.mintick), xloc.bar_time, color = color.new(#000000, 88), style = label.style_label_left, textcolor = color.new(color, 0), size = size.small, tooltip = tip + ' · ' + str.tostring(value, format.mintick))))

previousPriceRange(htf) =>
    var float htf_h  = na
    var float htf_l  = na
    var float htf_hx = na
    var float htf_lx = na
    var int   htf_ht = na
    var int   htf_lt = na
    var int   htf_hxt = na
    var int   htf_lxt = na

    if timeframe.change(htf)
        htf_hx := htf_h
        htf_h := high
        htf_lx := htf_l
        htf_l := low
        htf_hxt := htf_ht
        htf_ht := time
        htf_lxt := htf_lt
        htf_lt := time
        htf_lt
    else
        if high > htf_h
            htf_h := high
            htf_ht := time
            htf_ht

        if low < htf_l
            htf_l := low
            htf_lt := time
            htf_lt

    [htf_hx, htf_hxt, htf_lx, htf_lxt]

method updateLevel(LEVEL this, bool newPeriod, src, idx, color col, string name, string tName) =>
    rightEdge = bar_index + 5

    if newPeriod
        if not na(this.ln)
            line.delete(this.ln)
            label.delete(this.lb)

        this.ln := line.new(bar_index[idx], src[idx], rightEdge, src[idx], color = color.new(col, 8))
        this.lb := label.new(rightEdge, src[idx], name + ' · ' + str.tostring(src[idx], format.mintick), color = color.new(#000000, 88), textcolor = color.new(col, 0), style = label.style_label_left,
             size = size.small, textalign = text.align_left, tooltip = tName + ' : ≅' + str.format_time(time[idx], 'dd-MM-yyyy HH:mm \'UTC\'Z'))
        true
    else
        this.ln.set_x2(rightEdge)
        this.lb.set_x(rightEdge)
        true

refAlers(s, r, l) =>
    if high > r and close[1] < r
        alert('Price (' + str.tostring(close, format.mintick) + ')' + (close > r ? ' has crossed above the R' : ' has touched the R') + l + ' Reference Level(' + str.tostring(r, format.mintick) + '). Price interactions at resistance can indicate potential trend continuation or reversal. Use this as an early signal and seek further confirmation before acting.', alert.freq_once_per_bar_close)

    if low < s and close[1] > s
        alert('Price (' + str.tostring(close, format.mintick) + ')' + (close < s ? ' has dropped below the S' : ' has touched the S') + l + ' Reference Level(' + str.tostring(s, format.mintick) + '). Dropping below support can suggest a potential trend change or false breakdown. Treat this as an early signal and confirm with other indicators.', alert.freq_once_per_bar_close)

[H1, HT1, L1, LT1] = previousPriceRange('D')
atr = ta.atr(dayATRLength)

var float panelDayOpen = na
var float panelPDH = na
var float panelPDL = na
var float panelR1 = na
var float panelS1 = na
var float panelR2 = na
var float panelS2 = na

if dayChange
    panelDayOpen := open
    panelPDH := H1
    panelPDL := L1
    panelR1 := na
    panelS1 := na
    panelR2 := na
    panelS2 := na

if tradingDayLevelsOn and dayChange and (dayOpen == 'Open' or dayRefLevels != 'None' or pdHLShow) and dayChartTF
    dayStart = time
    dayEnd = time + 3600000 * 24
    O0 = open

    if dayOpen == 'Open'
        renderLevel('DO', dayStart, dayEnd, O0, dayColor, line.style_solid, 1, dayLast, 'Trading Day Open')

    if dayRefLevels != 'None'
        atrRange = request.security(syminfo.tickerid, 'D', atr)
        refRange = dayRefLevels == 'Average True Range (ATR)' ? atrRange : H1 - L1
        panelR1 := O0 + refRange * dayRefLevel1
        panelS1 := O0 - refRange * dayRefLevel1
        panelR2 := dayRefLevel2 > dayRefLevel1 ? O0 + refRange * dayRefLevel2 : na
        panelS2 := dayRefLevel2 > dayRefLevel1 ? O0 - refRange * dayRefLevel2 : na

        renderLevel('R1', dayStart, dayEnd, O0 + refRange * dayRefLevel1, dayRefColor, line.style_dotted, 2, refLast, 'Reference Model: ' + dayRefLevels + '\nFirst Reference Level')
        renderLevel('S1', dayStart, dayEnd, O0 - refRange * dayRefLevel1, dayRefColor, line.style_dotted, 2, refLast, 'Reference Model: ' + dayRefLevels + '\nFirst Reference Level')

        if refAlert
            refAlers(O0 - refRange * dayRefLevel1, O0 + refRange * dayRefLevel1, '1')

        if dayRefLevel2 > dayRefLevel1
            renderLevel('R2', dayStart, dayEnd, O0 + refRange * dayRefLevel2, dayRefColor, line.style_dotted, 2, refLast, 'Reference Model: ' + dayRefLevels + '\nSecond Reference Level')
            renderLevel('S2', dayStart, dayEnd, O0 - refRange * dayRefLevel2, dayRefColor, line.style_dotted, 2, refLast, 'Reference Model: ' + dayRefLevels + '\nSecond Reference Level')

            if refAlert
                refAlers(O0 - refRange * dayRefLevel2, O0 + refRange * dayRefLevel2, '2')

        //if dayRefLevel3 > dayRefLevel2
        //    renderLevel('R3', dayStart, dayEnd, O0 + refRange * dayRefLevel3, dayRefColor, line.style_dotted, 2, refLast, 'Reference Model: ' + dayRefLevels + '\nThird Reference Level')
        //    renderLevel('S3', dayStart, dayEnd, O0 - refRange * dayRefLevel3, dayRefColor, line.style_dotted, 2, refLast, 'Reference Model: ' + dayRefLevels + '\nThird Reference Level')

        //    if refAlert
        //        refAlers(O0 - refRange * dayRefLevel3, O0 + refRange * dayRefLevel3, '3')

    if pdHLShow
        renderLevel('PDH', HT1, dayEnd, H1, pdHLColor, line.style_solid, 1, 1, 'Previous Trading Day High\n ≅' + str.format_time(HT1, 'dd-MM-yyyy HH:mm \'UTC\'Z'))
        renderLevel('PDL', LT1, dayEnd, L1, pdHLColor, line.style_solid, 1, 1, 'Previous Trading Day Low\n ≅' + str.format_time(LT1, 'dd-MM-yyyy HH:mm \'UTC\'Z'))

var string daySession = na

if tradingDayLevelsOn and str.contains(dayOpen, 'Opening Range') and dayChartTF
    if dayChange
        daySession := timeRange(dayOpen, time, utcOffset)

    renderRange(dayOpen, 'Day', daySession, dayColor, dayLast, utcOffset, daySession)

if tradingDayLevelsOn and dayCandle and dayChartTF
    var box cndlBody = box.new(na, na, na, na, noColor, bgcolor = noColor)
    var line lnDHL = line.new(na, na, na, na, xloc.bar_index, extend.none, noColor, line.style_solid, 2)
    var label lbDO = label.new(na, na, 'Day Open', color = noColor, style = label.style_label_left, textcolor = noColor, size = size.small)
    var label lbDH = label.new(na, na, 'Day High', color = noColor, style = label.style_label_left, textcolor = noColor, size = size.small)
    var label lbDL = label.new(na, na, 'Day Low', color = noColor, style = label.style_label_left, textcolor = noColor, size = size.small)
    var label lbDC = label.new(na, na, 'Day Close', color = noColor, style = label.style_label_left, textcolor = noColor, size = size.small)

    if dayChange
        barColor = open > close ? dayColorDn : dayColorUp
        cndlBody.set_bgcolor(barColor)
        cndlBody.set_rightbottom(last_bar_index + dayOffset + 5, open)
        cndlBody.set_lefttop(last_bar_index + dayOffset - 5, close)
        lnDHL.set_color(barColor)
        lnDHL.set_xy1(last_bar_index + dayOffset, high)
        lnDHL.set_xy2(last_bar_index + dayOffset, low)
        lbDO.set_xy(last_bar_index + dayOffset, open)
        lbDO.set_tooltip('Day Open · ' + str.tostring(open, format.mintick))
        lbDH.set_xy(last_bar_index + dayOffset, high)
        lbDH.set_tooltip('Day High · ' + str.tostring(high, format.mintick))
        lbDL.set_xy(last_bar_index + dayOffset, low)
        lbDL.set_tooltip('Day Low · ' + str.tostring(low, format.mintick))
        lbDC.set_xy(last_bar_index + dayOffset, close)
        lbDC.set_tooltip('Day Close · ' + str.tostring(close, format.mintick))
    else
        barColor = cndlBody.get_bottom() > close ? dayColorDn : dayColorUp
        cndlBody.set_bgcolor(barColor)
        cndlBody.set_right(last_bar_index + dayOffset + 5)
        cndlBody.set_lefttop(last_bar_index + dayOffset - 5, close)
        dHigh = math.max(high, lnDHL.get_y1())
        dLow = math.min(low, lnDHL.get_y2())
        lnDHL.set_color(barColor)
        lnDHL.set_xy1(last_bar_index + dayOffset, dHigh)
        lnDHL.set_xy2(last_bar_index + dayOffset, dLow)
        lbDO.set_x(last_bar_index + dayOffset)
        lbDH.set_xy(last_bar_index + dayOffset, dHigh)
        lbDH.set_tooltip('Day High · ' + str.tostring(dHigh, format.mintick))
        lbDL.set_xy(last_bar_index + dayOffset, dLow)
        lbDL.set_tooltip('Day Low · ' + str.tostring(dLow, format.mintick))
        lbDC.set_xy(last_bar_index + dayOffset, close)
        lbDC.set_tooltip('Day Close · ' + str.tostring(close, format.mintick))

var LEVEL pdC = LEVEL.new()

if tradingDayLevelsOn and pdCShow and timeframe.isintraday
    pdC.updateLevel(dayChange, close, 1, pdCColor, 'PDC', 'Previous Trading Day Close')

// Trading Day
// ------------------------------------------------------------------------------------------------------------------ //
// Week/Month Open/HL, Monday HL

method updateRange(RANGE this, bool newPeriod, color col, string name, string tName, bool update) =>
    rightEdge = bar_index + 5
    float mid = (this.rHigh + this.rLow) * 0.5

    if newPeriod
        this.rHigh := high
        this.rLow  := low
        mid := (this.rHigh + this.rLow) * 0.5

        if not na(this.lnTop)
            line.delete(this.lnTop)
            line.delete(this.lnBtm)
            line.delete(this.lnAvg)
            label.delete(this.lbTop)
            label.delete(this.lbBtm)
            label.delete(this.lbAvg)

        this.lnTop := line.new(bar_index, this.rHigh, rightEdge, this.rHigh, color = color.new(col, 7))
        this.lnAvg := line.new(bar_index, mid       , rightEdge, mid       , color = color.new(col, 45), style = line.style_dotted)
        this.lnBtm := line.new(bar_index, this.rLow,  rightEdge, this.rLow,  color = color.new(col, 7))

        this.lbTop := label.new(rightEdge, this.rHigh, name + 'H · ' + str.tostring(this.rHigh, format.mintick), color = color.new(#000000, 88), textcolor = color.new(col, 0), style = label.style_label_left,
             size = size.small, textalign = text.align_left, tooltip = tName + ' High: ≅' + str.format_time(time, 'dd-MM-yyyy HH:mm \'UTC\'Z'))
        this.lbAvg := label.new(rightEdge, mid, name + 'M · ' + str.tostring(mid, format.mintick), color = color.new(#000000, 92), textcolor = color.new(col, 10), style = label.style_label_left,
             size = size.small, textalign = text.align_left, tooltip = tName + ' Midpoint (Equilibrium)')
        this.lbBtm := label.new(rightEdge, this.rLow , name + 'L · ' + str.tostring(this.rLow , format.mintick), color = color.new(#000000, 88), textcolor = color.new(col, 0), style = label.style_label_left,
             size = size.small, textalign = text.align_left, tooltip = tName + ' Low: ≅' + str.format_time(time, 'dd-MM-yyyy HH:mm \'UTC\'Z'))
        true

    else
        bool newHigh = high > this.rHigh
        bool newLow  = low  < this.rLow

        if newHigh and update
            this.rHigh := high
            this.lnTop.set_xy1(bar_index, this.rHigh)
            this.lbTop.set_text(name + 'H · ' + str.tostring(this.rHigh, format.mintick))
            this.lbTop.set_tooltip(tName + ' High: ≅' + str.format_time(time, 'dd-MM-yyyy HH:mm \'UTC\'Z'))

        if newLow and update
            this.rLow := low
            this.lnBtm.set_xy1(bar_index, this.rLow)
            this.lbBtm.set_text(name + 'L · ' + str.tostring(this.rLow , format.mintick))
            this.lbBtm.set_tooltip(tName + ' Low: ≅' + str.format_time(time, 'dd-MM-yyyy HH:mm \'UTC\'Z'))

        mid := (this.rHigh + this.rLow) * 0.5

        if not na(this.lnTop)
            this.lnTop.set_xy2(rightEdge, this.rHigh)
            this.lnBtm.set_xy2(rightEdge, this.rLow)
            this.lnAvg.set_y1(mid)
            this.lnAvg.set_xy2(rightEdge, mid)

            this.lbTop.set_xy(rightEdge, this.rHigh)
            this.lbBtm.set_xy(rightEdge, this.rLow)
            this.lbAvg.set_xy(rightEdge, mid)
            this.lbAvg.set_text(name + 'M · ' + str.tostring(mid, format.mintick))
        true

weekChange = timeframe.change('W')

var LEVEL weekOpenn = LEVEL.new()
var RANGE weekRange = RANGE.new()

if institutionalLevelsOn and (weekHL or weekOpen) and timeframe.isintraday
    if weekHL
        weekRange.updateRange(weekChange, weekHLColor, 'W', 'Week', true)
    if weekOpen
        weekOpenn.updateLevel(weekChange, open, 0, weekHLColor, 'WO', 'Weekly Open')

var LEVEL weekClose = LEVEL.new()

if institutionalLevelsOn and weeklyClose and timeframe.isintraday and (syminfo.type == 'forex' or syminfo.type == 'stock')
    weekClose.updateLevel(weekChange, close, 1, weeklyCColor, 'WC', 'Weekly Close')

var LEVEL nwogMid = LEVEL.new()

if institutionalLevelsOn and nwog
    linefill.new(weekOpenn.ln, weekClose.ln, weekOpenn.ln.get_y1() > weekClose.ln.get_y1() ? color.new(#5BC58C, 89) : color.new(#F26D5C, 89))
    nwogMid.updateLevel(weekChange and not na(weekOpenn.ln) and not na(weekClose.ln), math.avg(weekOpenn.ln.get_y1(), weekClose.ln.get_y1()), 0, weekOpenn.ln.get_y1() > weekClose.ln.get_y1() ? color.new(#5BC58C, 50) : color.new(#F26D5C, 50), 'WOG M', 'Week Opening Gap Mid')

var RANGE mondayRange = RANGE.new()

isMondayStart = weekChange and dayChange
var bool processMonday = false

if isMondayStart
    processMonday := true
else if dayChange and not isMondayStart
    processMonday := false

if institutionalLevelsOn and monHLShow and timeframe.isintraday
    mondayRange.updateRange(isMondayStart, monHLColor, 'WIB ', 'Weekly Initial Balance (WIB)\nMonaday', processMonday)


monthChange = timeframe.change('M')

var RANGE monthRange = RANGE.new()
var LEVEL monthOpenn = LEVEL.new()

if institutionalLevelsOn and (monthHL or monthOpen) and (timeframe.isintraday or timeframe.isdaily)
    if monthHL
        monthRange.updateRange(monthChange, monthHLColor, 'M', 'Monthly', true)
    if monthOpen
        monthOpenn.updateLevel(monthChange, open, 0, monthHLColor, 'MO', 'Monthly Open')

// Week/Month Open/HL, Monday HL


// ------------------------------------------------------------------------------------------------------------------ //
// Volume Weighted Average Price (VWAP) 

type VWAP
	array<chart.point> points
	polyline lines
	label labels

renderPolyline(source, anchor, color, style, txt, width) =>

    var VWAP vwap = VWAP.new(array.new<chart.point>(na))

    if anchor
        vwap.points.clear()
        vwap.points.push(chart.point.from_index(bar_index, source))
    else
        vwap.points.push(chart.point.from_index(bar_index, source))

        if vwap.points.size() == 2002
            vwap.points.remove(1)

    if barstate.islast and vwap.points.size() > 0
        vwap.lines.delete()
        vwap.lines := polyline.new(vwap.points, false, false, line_color = color, line_style = lnStyle(style), line_width = width)
        vwap.labels.delete()
        vwap.labels := label.new(vwap.points.last(), 'hidden', color = noColor, style = label.style_label_left, textcolor = noColor, size = size.small, tooltip = txt + ' · ' + str.tostring(vwap.points.last().price, format.mintick))
        vwap.labels

var float panelVWAP = na

if vwapSuiteOn and isVwap
    autoAnchor = timeframe.change(vwapAnchor)
    interAnchor = startDate == time
    anchor = htf_tf == 'Interactive' ? interAnchor : autoAnchor
    [vwap, upper, lower] = ta.vwap(vwapSource, anchor, stdevMult1)
    panelVWAP := vwap

    if isVoly
        renderPolyline(vwap, anchor, color.new(themeAccent, 0), 'Solid', 'VWAP(' + (htf_tf == 'Interactive' ? 'Interactive' : vwapAnchor) + ')', 1)

        if vwapBand1
            renderPolyline(upper, anchor, color.new(themeBull, 10), 'Dotted', 'VWAP(' + (htf_tf == 'Interactive' ? 'Interactive' : vwapAnchor) + ') Upper Band #1', 2)
            renderPolyline(lower, anchor, color.new(themeBull, 10), 'Dotted', 'VWAP(' + (htf_tf == 'Interactive' ? 'Interactive' : vwapAnchor) + ') Lower Band #1', 2)

        if vwapBand2
            renderPolyline(vwap + (upper - vwap) / stdevMult1 * stdevMult2, anchor, color.new(themeAccent, 20), 'Dotted', 'VWAP(' + (htf_tf == 'Interactive' ? 'Interactive' : vwapAnchor) + ') Upper Band #2', 2)
            renderPolyline(vwap - (vwap - lower) / stdevMult1 * stdevMult2, anchor, color.new(themeAccent, 20), 'Dotted', 'VWAP(' + (htf_tf == 'Interactive' ? 'Interactive' : vwapAnchor) + ') Lower Band #2', 2)

if vwapSuiteOn and isVwapHL
    var float highOf = na
    var float lowOf = na

    xChange = switch vwapShowHL
        'High/Low of Day' => dayChange
        'High/Low of Week' => weekChange
        'High/Low of Month' => monthChange

    if xChange
        highOf := high
        lowOf := low
        lowOf
    else
        highOf := math.max(high, highOf)
        lowOf := math.min(low, lowOf)
        lowOf

    vwaph = ta.vwap(high, highOf == high)
    if isVoly
        renderPolyline(vwaph, highOf == high, vwapColorH, 'Solid', str.replace(vwapShowHL, '/Low', '', 0) + ' VWAP', 1)

    vwapl = ta.vwap(low, lowOf == low)
    if isVoly
        renderPolyline(vwapl, lowOf == low, vwapColorL, 'Solid', str.replace(vwapShowHL, 'High/', '', 0) + ' VWAP', 1)

// Volume Weighted Average Price (VWAP) 
// ------------------------------------------------------------------------------------------------------------------ //
// Pivot Points High Low 

f_drawOnlyLabelX(_x, _y, _text, _xloc, _yloc, _color, _style, _textcolor, _size, _textalign, _tooltip) =>
    label.new(_x, _y, _text, _xloc, _yloc, _color, _style, _textcolor, _size, _textalign, _tooltip)

tradedVolume(_len, _calc, _offset) =>
    if _calc and isVoly
        vol = 0.
        for x = 0 to _len - 1 by 1
            vol := vol + volume[_offset + x]
            vol
        vol

pvtHigh = ta.pivothigh(pvtLength, pvtLength)
pvtLow = ta.pivotlow(pvtLength, pvtLength)

if pivotSuiteOn and dispPVT
    proceed = not na(pvtHigh) or not na(pvtLow)

    pvtLengthTemp = 3
    pvtHighTemp = ta.pivothigh(pvtLengthTemp, pvtLengthTemp)
    pvtLowTemp = ta.pivotlow(pvtLengthTemp, pvtLengthTemp)
    proceedTemp = not na(pvtHighTemp) or not na(pvtLowTemp)

    var x1 = 0
    var x2 = 0
    var x2Temp = 0
    var pvtHigh1 = 0.
    var pvtLow1 = 0.
    var pvtHigh1Temp = 0.
    var pvtLow1Temp = 0.

    if proceed
        x1 := x2
        x2 := bar_index
        x2

    if proceedTemp
        x2Temp := bar_index
        x2Temp

    profileLength = x2 - x1
    profileLengthTemp = x2Temp - pvtLengthTemp - x2 + pvtLength

    var label tempHigh = na
    var label tempLow = na

    if not na(pvtHigh)
        tradedVolume = tradedVolume(profileLength, proceed, pvtLength)
        TX = pvtHigh > pvtHigh1 ? ' · Higher High' : ' · Lower High'
        none = not pvtPrice and not pvtChange and (not pvtVolume or not isVoly)
        pvtDispText = none ? '▼' : (pvtPrice ? str.tostring(pvtHigh, format.mintick) : '') + (pvtChange ? (pvtPrice ? ' ↑ %' : '↑ %') + str.tostring((pvtHigh - pvtLow1) * 100 / pvtLow1, '#.##') : '') + (pvtVolume and isVoly ? (pvtPrice or pvtChange ? '\n' : '') + str.tostring(tradedVolume, format.volume) : '')
        f_drawOnlyLabelX(bar_index[pvtLength], pvtHigh, pvtDispText, xloc.bar_index, yloc.price, none ? noColor : color.new(themeBear, 78), label.style_label_down, none ? color.new(themeBear, 15) : themeText, pvtTextSize, text.align_center, 'Pivot High · ' + str.tostring(pvtHigh, format.mintick) + TX + '\n -Price Change: ↑ %' + str.tostring((pvtHigh - pvtLow1) * 100 / pvtLow1, '#.##') + (isVoly ? '\n -Traded Volume: ' + str.tostring(tradedVolume, format.volume) + ' (' + str.tostring(profileLength - 1) + ' bars)\n      *Average Volume/Bar: ' + str.tostring(tradedVolume / (profileLength - 1), format.volume) : '') + '\n\nNumber of Bars: ' + str.tostring(profileLength))
        pvtHigh1 := pvtHigh
        label.delete(tempHigh[1])
        if x2 - pvtLength > x2Temp - pvtLengthTemp
            label.delete(tempLow[1])

    if not na(pvtLow)
        tradedVolume = tradedVolume(profileLength, proceed, pvtLength)
        TX = pvtLow < pvtLow1 ? ' · Lower Low' : ' · Higher Low'
        none = not pvtPrice and not pvtChange and (not pvtVolume or not isVoly)
        pvtDispText = none ? '▲' : (pvtPrice ? str.tostring(pvtLow, format.mintick) : '') + (pvtChange ? (pvtPrice ? ' ↓ %' : '↓ %') + str.tostring((pvtHigh1 - pvtLow) * 100 / pvtHigh1, '#.##') : '') + (pvtVolume and isVoly ? (pvtPrice or pvtChange ? '\n' : '') + str.tostring(tradedVolume, format.volume) : '')
        f_drawOnlyLabelX(bar_index[pvtLength], pvtLow, pvtDispText, xloc.bar_index, yloc.price, none ? noColor : color.new(themeBull, 78), label.style_label_up, none ? color.new(themeBull, 15) : themeText, pvtTextSize, text.align_center, 'Pivot Low · ' + str.tostring(pvtLow, format.mintick) + TX + '\n -Price Change: ↓ %' + str.tostring((pvtHigh1 - pvtLow) * 100 / pvtHigh1, '#.##') + (isVoly ? '\n -Traded Volume: ' + str.tostring(tradedVolume, format.volume) + ' (' + str.tostring(profileLength - 1) + ' bars)\n      *Average Volume/Bar: ' + str.tostring(tradedVolume / (profileLength - 1), format.volume) : '') + '\n\nNumber of Bars: ' + str.tostring(profileLength))
        pvtLow1 := pvtLow
        label.delete(tempLow[1])
        if x2 - pvtLength > x2Temp - pvtLengthTemp // ???
            label.delete(tempHigh[1])

    if not na(pvtHighTemp) //and pvtLast  == 'L' 
        if pvtHighTemp > pvtHigh1Temp // or pvtHighTemp > pvtHigh1 
            label.delete(tempHigh[1])
            none = not pvtPrice and not pvtChange and (not pvtVolume or not isVoly)
            tradedVolume = tradedVolume(profileLengthTemp, proceedTemp, pvtLengthTemp)
            tempHigh := label.new(bar_index[pvtLengthTemp], pvtHighTemp, (none ? '●\n▼' : '●\n') + (pvtPrice ? str.tostring(pvtHighTemp, format.mintick) : '') + (pvtChange ? (pvtPrice ? ' ↑ %' : '↑ %') + str.tostring((pvtHighTemp - pvtLow1) * 100 / pvtLow1, '#.##') : '') + (pvtVolume and isVoly ? (pvtPrice or pvtChange ? '\n' : '') + str.tostring(tradedVolume, format.volume) : ''), xloc.bar_index, yloc.price, none ? noColor : color.new(themeAccent, 78), label.style_label_down, none ? color.new(themeAccent, 10) : themeText, none ? size.small : pvtTextSize, text.align_center, 'Temporary Pivot High · ' + str.tostring(pvtHighTemp, format.mintick) + '\n -Price Change: ↑ %' + str.tostring((pvtHighTemp - pvtLow1) * 100 / pvtLow1, '#.##') + (isVoly ? '\n -Traded Volume: ' + str.tostring(tradedVolume, format.volume) + ' (' + str.tostring(profileLengthTemp - 1) + ' bars)\n      *Average Volume/Bar: ' + str.tostring(tradedVolume / (profileLengthTemp - 1), format.volume) : '') + '\n\nNumber of bars since last confirmed Pivot High/Low: ' + str.tostring(profileLengthTemp) + '\n\n⚠ Provisional level\n' + 'Subject to repaint until structure confirms')

            if pvtAlert
                alert('Temporary Pivot High' + (pvtHighTemp > pvtHigh1 ? ' (Higher High)' : ' (Lower High)') + ' detected at (' + str.tostring(pvtHighTemp, format.mintick) + ')\n⚠ Caution: These alerts highlight potential market pivots but are not definitive signals. Use them as early indications of possible movement and seek further confirmation before making trading decisions. ⚠\nCurrent price · ' + str.tostring(close, format.mintick), alert.freq_once_per_bar)

        pvtHigh1Temp := pvtHighTemp
        pvtHigh1Temp

    if high > pvtHigh1Temp
        label.delete(tempHigh[1])

    if not na(pvtLowTemp) //and pvtLast  == 'H'
        if pvtLowTemp < pvtLow1Temp // or pvtLowTemp < pvtLow1
            label.delete(tempLow[1])
            tradedVolume = tradedVolume(profileLengthTemp, proceedTemp, pvtLengthTemp)
            none = not pvtPrice and not pvtChange and (not pvtVolume or not isVoly)
            tempLow := label.new(bar_index[pvtLengthTemp], pvtLowTemp, (none ? '▲\n●' : '●\n') + (pvtPrice ? str.tostring(pvtLowTemp, format.mintick) : '') + (pvtChange ? (pvtPrice ? ' ↓ %' : '↓ %') + str.tostring((pvtHigh1 - pvtLowTemp) * 100 / pvtLowTemp, '#.##') : '') + (pvtVolume and isVoly ? (pvtPrice or pvtChange ? '\n' : '') + str.tostring(tradedVolume, format.volume) : ''), xloc.bar_index, yloc.price, none ? noColor : color.new(themeAccent, 78), label.style_label_up, none ? color.new(themeAccent, 10) : themeText, none ? size.small : pvtTextSize, text.align_center, 'Temporary Pivot Low · ' + str.tostring(pvtLowTemp, format.mintick) + '\n -Price Change: ↓ %' + str.tostring((pvtHigh1 - pvtLowTemp) * 100 / pvtHigh1, '#.##') + (isVoly ? '\n -Traded Volume: ' + str.tostring(tradedVolume, format.volume) + ' (' + str.tostring(profileLengthTemp - 1) + ' bars)\n      *Average Volume/Bar: ' + str.tostring(tradedVolume / (profileLengthTemp - 1), format.volume) : '') + '\n\nNumber of bars since last confirmed Pivot High/Low: ' + str.tostring(profileLengthTemp) + '\n\n⚠ Provisional level\n' + 'Subject to repaint until structure confirms')

            if pvtAlert
                alert('Temporary Pivot Low' + (pvtLowTemp < pvtLow1 ? ' (Lower Low)' : ' (Higher Low)') + ' detected at (' + str.tostring(pvtLowTemp, format.mintick) + ')\n⚠ Caution: These alerts highlight potential market pivots but are not definitive signals. Use them as early indications of possible movement and seek further confirmation before making trading decisions. ⚠\nCurrent price · ' + str.tostring(close, format.mintick), alert.freq_once_per_bar)

        pvtLow1Temp := pvtLowTemp
        pvtLow1Temp

    if low < pvtLow1Temp
        label.delete(tempLow[1])

if pivotSuiteOn and marketS
    var float pHigh = na
    var int iHigh = na
    var xHigh = false
    var float pLow = na
    var int iLow = na
    var xLow = false

    var bias = 0

    if not na(pvtHigh)
        pHigh := pvtHigh
        iHigh := bar_index - pvtLength
        xHigh := false

    if not na(pvtLow)
        pLow := pvtLow
        iLow := bar_index - pvtLength
        xLow := false
 
    if close > pHigh and not xHigh
        xHigh := true
        line.new(iHigh, pHigh, bar_index, pHigh, color = themeBull, style = bias == -1 ? line.style_solid : line.style_dotted, width = 1)
        box.new(iHigh, pHigh, bar_index, pHigh, noColor, bgcolor = noColor, text = bias == -1 ? 'CHoCH' : 'BoS', text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_bottom, text_color = color.new(themeBull, 25))

        if msAlert
            alert((bias == -1 ? 'Bullish CHoCH Detected.\nThis suggests a market change from one structural pattern, such as a trending market, to another, like a ranging or consolidating market. It may indicate a potential trend reversal.' : 'Bullish BoS Detected.\nThis indicates that price has broken through a significant level, which may signify a continuation of the current trend or a liquidity sweep. Monitor for further confirmation of this movement.') + '\nCurrent price · ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

        bias := 1

    if close < pLow and not xLow
        xLow := true
        line.new(iLow, pLow, bar_index, pLow, color = themeBear, style = bias == 1 ? line.style_solid : line.style_dotted, width = 1)
        box.new(iLow, pLow, bar_index, pLow, noColor, bgcolor = noColor, text = bias == 1 ? 'CHoCH' : 'BoS', text_size = size.tiny, text_halign = text.align_left, text_valign = text.align_top, text_color = color.new(themeBear, 25))

        if msAlert
            alert((bias == 1 ? 'Bearish CHoCH Detected.\nThis suggests a market change from one structural pattern, such as a trending market, to another, like a ranging or consolidating market. It may indicate a potential trend reversal.' : 'Bearish BoS Detected.\nThis indicates that price has broken through a significant level, which may signify a continuation of the current trend or a liquidity sweep. Monitor for further confirmation of this movement.') + '\nCurrent price · ' + str.tostring(close, format.mintick), alert.freq_once_per_bar_close)

        bias := -1

// Pivot Points High Low 
// ------------------------------------------------------------------------------------------------------------------ //
// Moving Averages

movingAverage(source, length, maType) =>
    switch maType
        'SMA' => ta.sma(source, length)
        'EMA' => ta.ema(source, length)
        'HMA' => ta.hma(source, length)
        'RMA' => ta.rma(source, length)
        'WMA' => ta.wma(source, length)
        'VWMA' => ta.vwma(source, length)

maFast = maSuiteOn and maDisplay ? movingAverage(maSource1, maLength1, maType1) : na
maSlow = maSuiteOn and maDisplay ? movingAverage(maSource2, maLength2, maType2) : na

maColor = maFast > maSlow ? maColor1 : maColor2
ma1 = plot(maSuiteOn and maDisplay ? maFast : na, 'Moving Average #1', color.new(maColor, 18), 2, plot.style_linebr, display = display, editable = false)
ma2 = plot(maSuiteOn and maDisplay ? maSlow : na, 'Moving Average #2', color.new(maColor, 8), 2, plot.style_linebr, display = display, editable = false)

fill(ma1, ma2, math.max(maFast, maSlow), math.min(maFast, maSlow), color.new(maColor, maFast > maSlow ? 92 : 84), color.new(maColor, maFast > maSlow ? 82 : 92))

if maSuiteOn and maAlert
    if ta.cross(maFast, maSlow)
        alert((maFast > maSlow ? 'Bullish' : 'Bearish') + ' Moving Average Cross Detected\nThis signals potential ' + (maFast > maSlow ? 'bullish' : 'bearish') + ' momentum.\nCurrent price · ' + str.tostring(close, format.mintick), alert.freq_once_per_bar)

    if ta.cross(close, maSlow)
        alert('Price (' + str.tostring(close, format.mintick) + ')' + (close > maSlow ? ' crossed above ' : ' dropped below ') + maType2 + str.tostring(maLength2) + ' (' + str.tostring(maSlow, format.mintick) + ')', alert.freq_once_per_bar_close)


// Moving Averages
// ------------------------------------------------------------------------------------------------------------------ //
// Volume Weighted Colored Bars 

volMa = ta.sma(nzVolume, vwcbLen)
if volumeBarsOn and volAlert and nzVolume > volMa * 4.669
    alert('Volume SPIKE Detected.\nCurrent price · ' + str.tostring(close, format.mintick))

isHV = nzVolume >= hThresh * volMa
isLV = nzVolume <= lThresh * volMa

trendBullCandle = not na(maFast) and not na(maSlow) ? maFast >= maSlow : close >= open
volRatio = volMa > 0 ? nzVolume / volMa : 1.0
megaVol = volRatio >= hThresh * 1.35
bodyBull = close >= open
bodyRange = math.abs(close - open)
isMicroBody = bodyRange <= syminfo.mintick * 2
alignedCandle = bodyBull == trendBullCandle
bullPowerTransparency = megaVol ? 0 : isHV ? 5 : isLV ? 62 : alignedCandle ? 20 : 36
bearPowerTransparency = megaVol ? 0 : isHV ? 5 : isLV ? 62 : alignedCandle ? 20 : 36
color legacyCandleColor = isHV ? open < close ? volumeBullStrong : volumeBearStrong : isLV ? open < close ? volumeBullSoft : volumeBearSoft : na
color volumeEnhancedColor = isMicroBody ? color.new(neutralCandleColor, 35) : isHV ? bodyBull ? color.new(strongBullColor, megaVol ? 0 : 3) : color.new(strongBearColor, megaVol ? 0 : 3) : isLV ? color.new(neutralCandleColor, 62) : na
color trendEnhancedColor = trendBullCandle ? color.new(strongBullColor, bodyBull ? 14 : 30) : color.new(strongBearColor, bodyBull ? 30 : 14)
color combinedEnhancedColor = isMicroBody ? color.new(neutralCandleColor, 30) : bodyBull ? color.new(strongBullColor, bullPowerTransparency) : color.new(strongBearColor, bearPowerTransparency)
color selectedEnhancedColor = candleColorMode == 'Volume' ? volumeEnhancedColor : candleColorMode == 'Trend' ? trendEnhancedColor : combinedEnhancedColor

barcolor(volumeBarsOn and vwcb and isVoly ? showEnhancedCandleColors ? selectedEnhancedColor : legacyCandleColor : na, title = 'Enhanced Candle Visuals', editable = false)

//fgColor = isHV ? open < close ? #006400 : #910000 : isLV ? open < close ? #7FFFD4 : #FF9800 : na
//plotcandle(open, high, low, close, 'Volume Weighted Colored Bars', fgColor, fgColor, bordercolor = fgColor, editable = false)

// Volume Weighted Colored Bars 
// ------------------------------------------------------------------------------------------------------------------ //
// Market Sessions Tabular View 

sessionBegins(sess) =>
    t = time('', sess)
    timeframe.isintraday and not barstate.isfirst and na(t[1]) and not na(t)


cellInfo(sessRange, utc, utcLocal) =>
    dateTime = str.format_time(timenow, 'dd-MM-yyyy HH:mm:ss \'UTC\'Z', utcLocal)

    srOH = int(str.tonumber(str.substring(sessRange, 0, 2)))
    srOM = int(str.tonumber(str.substring(sessRange, 2, 4)))
    srCH = int(str.tonumber(str.substring(sessRange, 5, 7)))
    srCM = int(str.tonumber(str.substring(sessRange, 7, 9)))

    endTime = timestamp(utc, year, month, dayofmonth, srCH, srCM, 00)
    startTime = timestamp(utc, year, month, dayofmonth, srOH, srOM, 00)

    closesIn = str.format_time(endTime - timenow, '\'Closes in \'HH:mm:ss', 'Etc/UTC')
    opensIn = str.format_time(startTime - timenow, '\'Opens in \'HH:mm:ss', 'Etc/UTC')

    if str.contains(closesIn, 'in 00:')
        closesIn := timenow % 2 == 0 ? ' 🟢 ' + closesIn : ' 🔴 ' + closesIn
        closesIn
    else
        closesIn := ' 🟢 ' + closesIn
        closesIn

    if str.contains(opensIn, 'in 00:')
        opensIn := timenow % 2 == 0 ? ' 🟢 ' + opensIn : ' 🔴 ' + opensIn
        opensIn
    else
        opensIn := ' 🔴 ' + opensIn
        opensIn

    A = dayofweek(timenow, utcLocal) //  Etc/UTC'
    //log.info("yaz_kizim {0} {1} {2}", A, str.format_time(timestamp('Etc/UTC', year(time, 'Etc/UTC'), month(time, 'Etc/UTC'), dayofmonth(time, 'Etc/UTC'), math.floor(time / 3600000) % 24, math.floor(time / 60000) % 60, 00), "dd-MM-yyyy HH:mm:ss 'UTC'Z"), str.format_time(time, "dd-MM-yyyy HH:mm:ss 'UTC'Z"))
    if debugLogs
        log.info('yaz_kizim {0} {1} {2} {3}', utcLocal, str.format_time(time, 'dd-MM-yyyy HH:mm:ss \'UTC\'Z'), str.format_time(timestamp('Etc/UTC', year, month, dayofmonth, srOH < srCH ? srCH : srCH + 24, srCM, 00), 'dd-MM-yyyy HH:mm:ss \'UTC\'Z'), str.format_time(time, 'dd-MM-yyyy HH:mm:ss \'UTC\'Z'))

    if A != 1 and A != 7
        ltfSession = request.security_lower_tf(syminfo.tickerid, ltf, timeInRange(sessRange, utc), calc_bars_count = 60)

        if ltfSession.size() > 0
            if ltfSession.last()
                //if not na(time("", sessRange, utc)) 
                dateTime + closesIn //+ str.format_time(endTime, "' at 'HH:mm 'UTC'Z", utc)
            else //
                if A == 6 and time >= (srOH > srCH ? 3600000 * 24 + timestamp('Etc/UTC', year, month, dayofmonth, srCH, srCM, 00) : timestamp('Etc/UTC', year, month, dayofmonth, srCH, srCM, 00))
                    //if A == 2 and timestamp(utc, year, month, dayofmonth, math.floor(time / 3600000) % 24, math.floor(time / 60000) % 60, 00) >= endTime
                    dateTime + ' 🟠 Weekend'
                else
                    dateTime + opensIn //+ str.format_time(startTime, "' at 'HH:mm 'UTC'Z", utc)
    else
        dateTime + ' 🟠 Weekend'

sessionCountdown(ms) =>
    str.format_time(ms, 'HH:mm:ss', 'Etc/UTC')

sessionQuick(sessRange, utc) =>
    srOH = int(str.tonumber(str.substring(sessRange, 0, 2)))
    srOM = int(str.tonumber(str.substring(sessRange, 2, 4)))
    srCH = int(str.tonumber(str.substring(sessRange, 5, 7)))
    srCM = int(str.tonumber(str.substring(sessRange, 7, 9)))

    nowY = year(timenow, utc)
    nowM = month(timenow, utc)
    nowD = dayofmonth(timenow, utc)
    sessionStart = timestamp(utc, nowY, nowM, nowD, srOH, srOM, 00)
    sessionEnd = timestamp(utc, nowY, nowM, nowD, srCH, srCM, 00)
    sessionEnd := sessionEnd <= sessionStart ? sessionEnd + 86400000 : sessionEnd

    if timenow >= sessionEnd
        sessionStart += 86400000
        sessionEnd += 86400000

    isOpenNow = timenow >= sessionStart and timenow < sessionEnd
    dow = dayofweek(timenow, utc)
    isWeekend = dow == dayofweek.saturday or dow == dayofweek.sunday
    msToEvent = isOpenNow ? sessionEnd - timenow : sessionStart - timenow
    status = isWeekend ? 'WEEKEND' : isOpenNow ? 'OPEN' : 'CLOSED'
    [status, sessionCountdown(msToEvent), msToEvent]

sessionColor(status) =>
    status == 'OPEN' ? themeBull : status == 'WEEKEND' ? color.orange : status == 'NEXT' ? themeAccent : themeBear

sessionBadge(status, timer) =>
    status == 'OPEN' ? 'OPEN · ' + timer : status == 'NEXT' ? 'NEXT · ' + timer : status == 'WEEKEND' ? 'WEEKEND' : 'CLOSED · ' + timer

hide = true

// Session Matrix Panel
// ------------------------------------------------------------------------------------------------------------------ //

var table matrixPanel = table.new(position.bottom_right, 4, 13, border_width = 0, frame_color = noColor, border_color = noColor)

shortSessionName(name) =>
    name == sydneyName ? 'SYD' : name == tokyoName ? 'TKY' : name == frankfurtName ? 'FRA' : name == londonName ? 'LDN' : name == newYorkName ? 'NY' : name

shortStatus(status, timer) =>
    status == 'OPEN' ? 'OPEN ' + timer : status == 'NEXT' ? 'NEXT ' + timer : status == 'WEEKEND' ? 'WEEKEND' : 'CLOSED ' + timer

if barstate.islast
    [sStatus, sTimer, sMs] = sessionQuick(sydneyRange, utcOffset)
    [tStatus, tTimer, tMs] = sessionQuick(tokyoRange, utcOffset)
    [fStatus, fTimer, fMs] = sessionQuick(frankfurtRange, utcOffset)
    [lStatus, lTimer, lMs] = sessionQuick(londonRange, utcOffset)
    [nStatus, nTimer, nMs] = sessionQuick(newYorkRange, utcOffset)

    nextName = sydneyName
    nextTimer = sTimer
    nextMs = sMs
    nextName := tStatus != 'OPEN' and tStatus != 'WEEKEND' and tMs < nextMs ? tokyoName : nextName
    nextTimer := tStatus != 'OPEN' and tStatus != 'WEEKEND' and tMs < nextMs ? tTimer : nextTimer
    nextMs := tStatus != 'OPEN' and tStatus != 'WEEKEND' and tMs < nextMs ? tMs : nextMs
    nextName := fStatus != 'OPEN' and fStatus != 'WEEKEND' and fMs < nextMs ? frankfurtName : nextName
    nextTimer := fStatus != 'OPEN' and fStatus != 'WEEKEND' and fMs < nextMs ? fTimer : nextTimer
    nextMs := fStatus != 'OPEN' and fStatus != 'WEEKEND' and fMs < nextMs ? fMs : nextMs
    nextName := lStatus != 'OPEN' and lStatus != 'WEEKEND' and lMs < nextMs ? londonName : nextName
    nextTimer := lStatus != 'OPEN' and lStatus != 'WEEKEND' and lMs < nextMs ? lTimer : nextTimer
    nextMs := lStatus != 'OPEN' and lStatus != 'WEEKEND' and lMs < nextMs ? lMs : nextMs
    nextName := nStatus != 'OPEN' and nStatus != 'WEEKEND' and nMs < nextMs ? newYorkName : nextName
    nextTimer := nStatus != 'OPEN' and nStatus != 'WEEKEND' and nMs < nextMs ? nTimer : nextTimer

    activeSession = lStatus == 'OPEN' and nStatus == 'OPEN' ? 'London + New York' :
         fStatus == 'OPEN' and lStatus == 'OPEN' ? 'Frankfurt + London' :
         tStatus == 'OPEN' and sStatus == 'OPEN' ? 'Sydney + Tokyo' :
         nStatus == 'OPEN' ? newYorkName :
         lStatus == 'OPEN' ? londonName :
         fStatus == 'OPEN' ? frankfurtName :
         tStatus == 'OPEN' ? tokyoName :
         sStatus == 'OPEN' ? sydneyName : 'No Active Session'

    activeTimer = nStatus == 'OPEN' ? nTimer :
         lStatus == 'OPEN' ? lTimer :
         fStatus == 'OPEN' ? fTimer :
         tStatus == 'OPEN' ? tTimer :
         sStatus == 'OPEN' ? sTimer : nextTimer

    sessionStatusNow = activeSession == 'No Active Session' ? 'Waiting for ' + nextName : 'Active · ' + activeSession
    nextSessionText = activeSession == 'No Active Session' ? nextName + ' opens in ' + nextTimer : activeSession + ' closes in ' + activeTimer
    marketMode = lStatus == 'OPEN' and nStatus == 'OPEN' ? 'NY/London Overlap' : fStatus == 'OPEN' or lStatus == 'OPEN' ? 'European Flow' : nStatus == 'OPEN' ? 'New York Flow' : tStatus == 'OPEN' or sStatus == 'OPEN' ? 'Asian Flow' : 'Transition Zone'
    maTrendState = not na(maFast) and not na(maSlow) ? maFast > maSlow ? 'Bullish MA Cloud' : maFast < maSlow ? 'Bearish MA Cloud' : 'MA Neutral' : 'MA Disabled'
    pivotState = not na(pvtHigh) ? 'Pivot High Confirmed' : not na(pvtLow) ? 'Pivot Low Confirmed' : 'Structure Monitoring'
    volumeState = isHV ? close >= open ? 'High Bull Volume' : 'High Bear Volume' : isLV ? 'Low Activity' : 'Normal Activity'
    doState = na(panelDayOpen) ? 'Day Open n/a' : close >= panelDayOpen ? 'Above Day Open' : 'Below Day Open'
    pdState = not na(panelPDH) and close > panelPDH ? 'Above PDH' : not na(panelPDL) and close < panelPDL ? 'Below PDL' : 'Inside PDH/PDL'
    vwapState = vwapSuiteOn and isVwap and not na(panelVWAP) ? close >= panelVWAP ? 'Above VWAP' : 'Below VWAP' : 'VWAP Disabled'
    biasSummary = doState + ' • ' + (not na(maFast) and not na(maSlow) ? maFast > maSlow ? 'Bullish Flow' : 'Bearish Flow' : 'Neutral Flow')

    nearestName = '—'
    float nearestPrice = na
    nearestDist = 10e10
    if not na(panelDayOpen) and math.abs(close - panelDayOpen) < nearestDist
        nearestDist := math.abs(close - panelDayOpen)
        nearestName := 'Day Open'
        nearestPrice := panelDayOpen
    if not na(panelPDH) and math.abs(close - panelPDH) < nearestDist
        nearestDist := math.abs(close - panelPDH)
        nearestName := 'PDH'
        nearestPrice := panelPDH
    if not na(panelPDL) and math.abs(close - panelPDL) < nearestDist
        nearestDist := math.abs(close - panelPDL)
        nearestName := 'PDL'
        nearestPrice := panelPDL
    if not na(panelR1) and math.abs(close - panelR1) < nearestDist
        nearestDist := math.abs(close - panelR1)
        nearestName := 'R1'
        nearestPrice := panelR1
    if not na(panelS1) and math.abs(close - panelS1) < nearestDist
        nearestDist := math.abs(close - panelS1)
        nearestName := 'S1'
        nearestPrice := panelS1
    if not na(panelR2) and math.abs(close - panelR2) < nearestDist
        nearestDist := math.abs(close - panelR2)
        nearestName := 'R2'
        nearestPrice := panelR2
    if not na(panelS2) and math.abs(close - panelS2) < nearestDist
        nearestDist := math.abs(close - panelS2)
        nearestName := 'S2'
        nearestPrice := panelS2

    weekOpenTxt = institutionalLevelsOn and weekOpen and not na(weekOpenn.ln) ? fmtPrice(weekOpenn.ln.get_y1()) : '—'
    wibTxt = institutionalLevelsOn and monHLShow and not na(mondayRange.lnTop) ? fmtPrice(mondayRange.lnTop.get_y1()) + ' / ' + fmtPrice(mondayRange.lnBtm.get_y1()) : '—'
    tzText = utcOffsetIn == 'Exchange' ? 'EXCH' : str.upper(str.replace(str.substring(utcOffsetIn, str.pos(utcOffsetIn, '/') + 1), '_', ' ', 0))
    panelSizeResolved = sizeFromString(matrixPanelSize)
    compactPanel = matrixPanelMode == 'Mobile Compact'
    activePanel = matrixPanel

    activeShort = activeSession == 'No Active Session' ? 'None' : activeSession == 'London + New York' ? 'LDN+NY' : activeSession == 'Frankfurt + London' ? 'FRA+LDN' : activeSession == 'Sydney + Tokyo' ? 'SYD+TKY' : shortSessionName(activeSession)
    nextShort = shortSessionName(nextName)
    modeShort = marketMode == 'NY/London Overlap' ? 'Overlap' : marketMode == 'European Flow' ? 'Europe' : marketMode == 'New York Flow' ? 'NY Flow' : marketMode == 'Asian Flow' ? 'Asia' : 'Transition'
    biasShort = na(panelDayOpen) ? 'DO n/a' : close >= panelDayOpen ? 'Above DO' : 'Below DO'
    maShort = maTrendState == 'Bullish MA Cloud' ? 'Bull MA' : maTrendState == 'Bearish MA Cloud' ? 'Bear MA' : maTrendState == 'MA Disabled' ? 'MA Off' : 'MA Neutral'
    pivotShort = not na(pvtHigh) ? 'Pivot High' : not na(pvtLow) ? 'Pivot Low' : 'Monitoring'
    volShort = isHV ? close >= open ? 'High Bull' : 'High Bear' : isLV ? 'Low' : 'Normal'
    vwapShort = vwapSuiteOn and isVwap and not na(panelVWAP) ? close >= panelVWAP ? 'Above' : 'Below' : 'Off'
    pdShort = pdState == 'Inside PDH/PDL' ? 'Inside PD' : pdState
    flowShort = doState == 'Above Day Open' and maShort == 'Bull MA' ? 'Bull Flow' : doState == 'Below Day Open' and maShort == 'Bear MA' ? 'Bear Flow' : 'Mixed'

    table.set_position(activePanel, posFromString(matrixPanelPosition))

    if masterVisuals and showMatrixPanel
        clearTable(activePanel, 4, 13)
        panelHeadBg = color.new(themeSurface, math.max(58, matrixPanelTransparency - 14))
        panelBg = color.new(themeSurface, matrixPanelTransparency)
        panelBgAlt = color.new(themeSurface, math.min(96, matrixPanelTransparency + 5))
        panelSectionBg = color.new(themeAccent, 88)
        table.set_frame_color(activePanel, noColor)
        table.set_border_color(activePanel, noColor)

        if compactPanel
            table.cell(activePanel, 0, 0, '●', text_color = themeAccent, bgcolor = panelHeadBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 0, 'MATRIX', text_color = themeText, bgcolor = panelHeadBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 0, syminfo.ticker, text_color = themeAccent, bgcolor = panelHeadBg, text_halign = text.align_center, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 0, timeframe.period, text_color = themeText, bgcolor = panelHeadBg, text_halign = text.align_center, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 1, 'NOW', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 1, activeShort, text_color = activeShort == 'None' ? themeBear : themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 1, activeTimer, text_color = themeBull, bgcolor = panelBg, text_halign = text.align_center, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 1, modeShort, text_color = themeAccent, bgcolor = panelBg, text_halign = text.align_center, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 2, 'NEXT', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 2, nextShort, text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 2, nextTimer, text_color = themeAccent, bgcolor = panelBgAlt, text_halign = text.align_center, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 2, tzText, text_color = color.new(themeText, 15), bgcolor = panelBgAlt, text_halign = text.align_center, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 3, 'SYD', text_color = sydneyColor, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 3, shortStatus(sStatus == 'CLOSED' and nextName == sydneyName ? 'NEXT' : sStatus, sTimer), text_color = sessionColor(sStatus == 'CLOSED' and nextName == sydneyName ? 'NEXT' : sStatus), bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 3, 'TKY', text_color = tokyoColor, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 3, shortStatus(tStatus == 'CLOSED' and nextName == tokyoName ? 'NEXT' : tStatus, tTimer), text_color = sessionColor(tStatus == 'CLOSED' and nextName == tokyoName ? 'NEXT' : tStatus), bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 4, 'FRA', text_color = frankfurtColor, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 4, shortStatus(fStatus == 'CLOSED' and nextName == frankfurtName ? 'NEXT' : fStatus, fTimer), text_color = sessionColor(fStatus == 'CLOSED' and nextName == frankfurtName ? 'NEXT' : fStatus), bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 4, 'LDN', text_color = londonColor, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 4, shortStatus(lStatus == 'CLOSED' and nextName == londonName ? 'NEXT' : lStatus, lTimer), text_color = sessionColor(lStatus == 'CLOSED' and nextName == londonName ? 'NEXT' : lStatus), bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 5, 'NY', text_color = newYorkColor, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 5, shortStatus(nStatus == 'CLOSED' and nextName == newYorkName ? 'NEXT' : nStatus, nTimer), text_color = sessionColor(nStatus == 'CLOSED' and nextName == newYorkName ? 'NEXT' : nStatus), bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 5, 'BIAS', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 5, flowShort, text_color = flowShort == 'Bull Flow' ? themeBull : flowShort == 'Bear Flow' ? themeBear : themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 6, 'DO', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 6, fmtPrice(panelDayOpen), text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 6, 'PDH', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 6, fmtPrice(panelPDH), text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 7, 'PDL', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 7, fmtPrice(panelPDL), text_color = themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 7, 'R/S', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 7, fmtPrice(panelR1) + ' / ' + fmtPrice(panelS1), text_color = themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 8, 'NEAR', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 8, nearestName + ' ' + fmtPrice(nearestPrice), text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 8, 'FLOW', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 8, maShort, text_color = maShort == 'Bull MA' ? themeBull : maShort == 'Bear MA' ? themeBear : themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 9, 'VOL', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 9, volShort, text_color = isHV ? themeAccent : themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 9, 'VWAP', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 9, vwapShort, text_color = themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 10, 'R2/S2', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 10, fmtPrice(panelR2) + ' / ' + fmtPrice(panelS2), text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 10, 'WEEK', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 10, weekOpenTxt, text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 11, 'PIVOT', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 11, pivotShort, text_color = themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 11, 'LOC', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 11, pdShort, text_color = themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 12, 'STATE', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 12, biasShort, text_color = biasShort == 'Above DO' ? themeBull : biasShort == 'Below DO' ? themeBear : themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 12, 'RISK', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 12, 'Confirm', text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
        else
            table.cell(activePanel, 0, 0, '●', text_color = themeAccent, bgcolor = panelHeadBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 0, 'Session Matrix', text_color = themeText, bgcolor = panelHeadBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 0, syminfo.ticker + ' · ' + timeframe.period, text_color = themeAccent, bgcolor = panelHeadBg, text_halign = text.align_center, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 0, tzText, text_color = themeText, bgcolor = panelHeadBg, text_halign = text.align_center, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 1, 'Active', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 1, activeShort + ' · ' + activeTimer, text_color = activeShort == 'None' ? themeBear : themeBull, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 1, 'Next', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 1, nextShort + ' · ' + nextTimer, text_color = themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 2, 'Mode', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 2, modeShort, text_color = themeAccent, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 2, 'Bias', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 2, flowShort, text_color = flowShort == 'Bull Flow' ? themeBull : flowShort == 'Bear Flow' ? themeBear : themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 3, 'SYD', text_color = sydneyColor, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 3, shortStatus(sStatus == 'CLOSED' and nextName == sydneyName ? 'NEXT' : sStatus, sTimer), text_color = sessionColor(sStatus == 'CLOSED' and nextName == sydneyName ? 'NEXT' : sStatus), bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 3, 'TKY', text_color = tokyoColor, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 3, shortStatus(tStatus == 'CLOSED' and nextName == tokyoName ? 'NEXT' : tStatus, tTimer), text_color = sessionColor(tStatus == 'CLOSED' and nextName == tokyoName ? 'NEXT' : tStatus), bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 4, 'FRA', text_color = frankfurtColor, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 4, shortStatus(fStatus == 'CLOSED' and nextName == frankfurtName ? 'NEXT' : fStatus, fTimer), text_color = sessionColor(fStatus == 'CLOSED' and nextName == frankfurtName ? 'NEXT' : fStatus), bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 4, 'LDN', text_color = londonColor, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 4, shortStatus(lStatus == 'CLOSED' and nextName == londonName ? 'NEXT' : lStatus, lTimer), text_color = sessionColor(lStatus == 'CLOSED' and nextName == londonName ? 'NEXT' : lStatus), bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 5, 'NY', text_color = newYorkColor, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 5, shortStatus(nStatus == 'CLOSED' and nextName == newYorkName ? 'NEXT' : nStatus, nTimer), text_color = sessionColor(nStatus == 'CLOSED' and nextName == newYorkName ? 'NEXT' : nStatus), bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 5, 'Timer', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 5, activeTimer, text_color = themeBull, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 6, 'Day Open', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 6, fmtPrice(panelDayOpen), text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 6, 'PDH', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 6, fmtPrice(panelPDH), text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 7, 'PDL', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 7, fmtPrice(panelPDL), text_color = themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 7, 'R1 / S1', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 7, fmtPrice(panelR1) + ' / ' + fmtPrice(panelS1), text_color = themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 8, 'R2 / S2', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 8, fmtPrice(panelR2) + ' / ' + fmtPrice(panelS2), text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 8, 'Nearest', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 8, nearestName + ' · ' + fmtPrice(nearestPrice), text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 9, 'Week', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 9, weekOpenTxt, text_color = themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 9, 'WIB', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 9, wibTxt, text_color = themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 10, 'Trend', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 10, maShort, text_color = maShort == 'Bull MA' ? themeBull : maShort == 'Bear MA' ? themeBear : themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 10, 'Location', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 10, pdShort, text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 11, 'Pivot', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 11, pivotShort, text_color = themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 11, 'Volume', text_color = themeAccent, bgcolor = panelBg, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 11, volShort, text_color = isHV ? themeAccent : themeText, bgcolor = panelBg, text_halign = text.align_left, text_size = panelSizeResolved)

            table.cell(activePanel, 0, 12, 'VWAP', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 1, 12, vwapShort, text_color = themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
            table.cell(activePanel, 2, 12, 'State', text_color = themeAccent, bgcolor = panelBgAlt, text_size = panelSizeResolved)
            table.cell(activePanel, 3, 12, biasShort, text_color = biasShort == 'Above DO' ? themeBull : biasShort == 'Below DO' ? themeBear : themeText, bgcolor = panelBgAlt, text_halign = text.align_left, text_size = panelSizeResolved)
    else
        hideTable(activePanel, 4, 13)


// Session Matrix Panel
// ------------------------------------------------------------------------------------------------------------------ //

// Forex Market Events 

if eventsSuiteOn and forexEvents and fxChartTF and syminfo.type == 'forex'

    var meEvents = array.new_string()
    var meVolume = array.new_float()

    if barstate.isfirst
        meVolume.push(0.7)
        meEvents.push('Lowest\nNew trading day begins · Institutional reset\n')

        meVolume.push(1)
        meEvents.push('Very Low\nBooks balancing · Spread stabilization\n')

        meVolume.push(1.7)
        meEvents.push('Low, slightly increasing\nEarly positioning activity\n')

        meVolume.push(3.9)
        meEvents.push('Low and Increasing\nRegional participation expanding\n')

        meVolume.push(2.9)
        meEvents.push('Low\nActive participation building\n')

        meVolume.push(2)
        meEvents.push('Low and Decreasing\nTemporary liquidity contraction\n')

        meVolume.push(1.7)
        meEvents.push('Low\nPre-expansion transition phase\n')

        meVolume.push(2.)
        meEvents.push('Low and Increasing\nEarly European flows entering\n')

        meVolume.push(2.7)
        meEvents.push('Increasing\nLiquidity building\n')

        meVolume.push(3.7)
        meEvents.push('Medium\nParticipation accelerating\n')

        meVolume.push(4.1)
        meEvents.push('High and Increasing\nMajor liquidity expansion\n')

        meVolume.push(3.6)
        meEvents.push('High\nBroad institutional activity\n')

        meVolume.push(3.2)
        meEvents.push('High\nPosition adjustments before next expansion\n')

        meVolume.push(2.5)
        meEvents.push('High\nSustained participation\n')

        meVolume.push(3.5)
        meEvents.push('High and Increasing\nCross-region flows increasing\n')

        meVolume.push(5.7)
        meEvents.push('Higher\nPeak volatility window beginning\n')

        meVolume.push(7.5)
        meEvents.push('Higher\nStrong multi-region participation\n')

        meVolume.push(8.5)
        meEvents.push('Highest\nMaximum institutional engagement\n')

        meVolume.push(7.7)
        meEvents.push('Higher and Decreasing\nProfit-taking and rebalancing\n')

        meVolume.push(5.3)
        meEvents.push('Medium and Decreasing\nDominant regional control\n')

        meVolume.push(3.1)
        meEvents.push('Low and Decreasing\nActivity cooling\n')

        meVolume.push(2)
        meEvents.push('Low\nNew York afternoon · Participation fading\n')

        meVolume.push(1.4)
        meEvents.push('Very Low\nPre-rollover positioning · Liquidity withdrawal\n')

        meVolume.push(1.1)
        meEvents.push('Lowest\nEnd-cycle positioning\n')

        meVolume.push(1) // Dummy required
        meEvents.push('\n')


    //hourIndex = int((time - dayStartTime) / hourInMS)
    var blabla = 0
    var label events = na
    var meLines = array.new_line()
    var meLabels = array.new_label()
    var meFills = array.new_linefill()
    var a_hist = array.new_box()
    var float vHST = na
    var float prL = na
    var float prC = na

    meLN = int(1440 / timeframe.multiplier)
    pHST = ta.highest(high, meLN)
    pLST = ta.lowest(low, meLN)
    volH = ta.highest(nzVolume, meLN)
    pCHR = (pHST - pLST) / pHST
    pLST := pLST * (1 - pCHR * oscVO)
    oHST = 13
    hight = pCHR / oscHight
    bullCandle = close > open


    vST = isHV ? '\n\nReal-Time Activity: HIGH' : isLV ? '\n\nReal-Time Activity: LOW' : '\n\nReal-Time Activity: NORMAL'

    if dayChange
        vHST := volH
        prL := pLST
        prC := pCHR
        if meLines.size() > 0
            for i = meLines.size() to 1 
                line.delete(meLines.shift())

        if meLabels.size() > 0
            for i = meLabels.size() to 1
                label.delete(meLabels.shift())

        if meFills.size() > 0
            for i = meFills.size() to 1
                linefill.delete(meFills.shift())

        if a_hist.size() > 0
            for i = a_hist.size() to 1
                box.delete(a_hist.shift())

        hourInMS = 60 * 60 * 1000

        for index = 0 to 23
            meLines.push(line.new(time + index * hourInMS, pLST * (1 - (oHST - meVolume.get(index)) * hight / oHST), time + (index + 1) * hourInMS, pLST * (1 - (oHST - meVolume.get(index + 1)) * hight / oHST), xloc.bar_time, extend.none, noColor, line.style_solid, 1)) // color.from_gradient(meVolume.get(barIndex), 1,  6, #ef5350, #26a69a), line.style_solid, 1)) // 
            meLines.push(line.new(time + index * hourInMS, pLST * (1 - hight), time + (index + 1) * hourInMS, pLST * (1 - hight), xloc.bar_time, extend.none, noColor, line.style_solid, 1))

            meFills.push(linefill.new(meLines.get(2 * index), meLines.get(2 * index + 1), color.new(color.from_gradient(meVolume.get(index), 1, 5.7, #F23645, #089981), 73)))

            meLabels.push(label.new(time + index * hourInMS, pLST * (1 - (oHST - meVolume.get(index)) * hight / oHST), '', xloc.bar_time, yloc.price, noColor, label.style_circle, noColor, size.tiny, text.align_left, 'At this time of day\nTrading Volume is typically ' + meEvents.get(index)))
            meLabels.push(label.new(time + index * hourInMS, pLST * (1 - (oHST - meVolume.get(index)) * hight / oHST), '', xloc.bar_time, yloc.price, color.from_gradient(meVolume.get(index), 1, 6, #F23645, #089981), label.style_circle, noColor, size.auto, text.align_left, ''))

        meLabels.push(label.new(time + 24 * hourInMS, pLST * (1 - (oHST - meVolume.get(0)) * hight / oHST), '', xloc.bar_time, yloc.price, noColor, label.style_circle, noColor, size.tiny, text.align_left, 'At this time of day\nTrading Volume is typically Lowest\nMarket reset\n'))
        meLabels.push(label.new(time + 24 * hourInMS, pLST * (1 - (oHST - meVolume.get(0)) * hight / oHST), '', xloc.bar_time, yloc.price, color.from_gradient(meVolume.get(0), 1, 6, #F23645, #089981), label.style_circle, noColor, size.auto, text.align_left, ''))

        if not na(events)
            label.delete(events)
        blabla := 0
        events := label.new(time, pLST * (1 - hight), '', xloc.bar_time, yloc.price, color.new(color.from_gradient(nzVolume, 0.618 * volMa, 1.618 * volMa, #F23645, #089981), 50), label.style_label_up, color.white, size.tiny, text.align_left, 'At this time of day\nTrading Volume is typically ' + meEvents.get(blabla))

    a_hist.push(
         box.new(time, prL * (1 - prC / oscHight) * (1 + (nzVolume / vHST * prC / oscHight)), 
                 time, prL * (1 - prC / oscHight), 
                 bullCandle ? color.new(themeBull, 65) : color.new(themeBear, 65), 2, xloc = xloc.bar_time, bgcolor = noColor)) // theme theme colors

    if ta.change(pLST) < 0 and not dayChange
        for barIndex = 0 to meLines.size() - 1
            line.set_y1(meLines.get(barIndex), line.get_y1(meLines.get(barIndex)) - pLST[1] + pLST)
            line.set_y2(meLines.get(barIndex), line.get_y2(meLines.get(barIndex)) - pLST[1] + pLST)

        for barIndex = 0 to meLabels.size() - 1
            label.set_y(meLabels.get(barIndex), label.get_y(meLabels.get(barIndex)) - pLST[1] + pLST)

        events.set_y(events.get_y() - pLST[1] + pLST)

        prL := (box.get_bottom(a_hist.get(0)) - pLST[1] + pLST) / (1 - prC / oscHight)

        for barIndex = a_hist.size() - 1 to 0   
            box.set_top(a_hist.get(barIndex), box.get_top(a_hist.get(barIndex)) - pLST[1] + pLST)
            box.set_bottom(a_hist.get(barIndex), box.get_bottom(a_hist.get(barIndex)) - pLST[1] + pLST)




    inSydney     = not na(time(timeframe.period, sydneyRange, utcOffset))
    inTokyo      = not na(time(timeframe.period, tokyoRange, utcOffset))
    inFrankfurt  = not na(time(timeframe.period, frankfurtRange, utcOffset))
    inLondon     = not na(time(timeframe.period, londonRange, utcOffset))
    inNewYork    = not na(time(timeframe.period, newYorkRange, utcOffset))

    sessTxt = ''

    sessTxt += inSydney    ? '\nSydney · Active'    : ''
    sessTxt += inTokyo     ? '\nTokyo · Active'     : ''
    sessTxt += inFrankfurt ? '\nFrankfurt · Active' : ''
    sessTxt += inLondon    ? '\nLondon · Active'    : ''
    sessTxt += inNewYork   ? '\nNew York · Active'  : ''

    sessTxt := sessTxt == '' ? 'Interbank transition' : sessTxt

    liqDesc =
     inLondon and inNewYork              ? '\n\nPeak liquidity (London–New York overlap)' :
     inLondon and inFrankfurt            ? '\n\nHigh liquidity (European overlap)' :
     inTokyo and inFrankfurt             ? '\n\nModerate liquidity (Asia–Europe transition)' :
     inTokyo and inSydney                ? '\n\nModerate liquidity (Asia overlap)' :
     inLondon                            ? '\n\nHigh liquidity (London session)' :
     inNewYork                           ? '\n\nHigh liquidity (New York session)' :
     inFrankfurt                         ? '\n\nModerate liquidity (Frankfurt session)' :
     inTokyo                             ? '\n\nModerate liquidity (Tokyo session)' :
     inSydney                            ? '\n\nLow liquidity (Sydney session)' :
                                           '\n\nVery low liquidity'
         
    if timeframe.change('60') and not dayChange
        blabla := blabla + 1
        //events.set_tooltip('At this time of day\nTrading volume is typically ' + meEvents.get(blabla) + vST)
    if not na(events) and blabla < array.size(meEvents)
        events.set_tooltip('At this time of day\nTrading Volume is typically ' + meEvents.get(blabla) + sessTxt + liqDesc + vST)
        events.set_color(color.new(color.from_gradient(nzVolume, 0.618 * volMa, 1.618 * volMa, #F23645, #089981), 50))
        events.set_x(time)
    //else
    //    events.set_tooltip('At this time of day\nTrading Volume is typically ' + meEvents.get(blabla) + sessTxt + liqDesc + vST)
    //    events.set_color(color.new(color.from_gradient(nzVolume, 0.618 * volMa, 1.618 * volMa, #F23645, #089981), 50))
    //    events.set_x(time)


// Forex Market Events 
// ------------------------------------------------------------------------------------------------------------------ //

// Identification panel removed for clean publish/mobile layout.
````
