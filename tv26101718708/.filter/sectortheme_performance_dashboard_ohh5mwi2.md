# Sector/Theme Performance Dashboard

- url: https://www.tradingview.com/script/oHH5Mwi2-Sector-Theme-Performance-Dashboard/
- type: indicator
- pine_id: PUB;565a359ae2fd4d639b6c321f4329aaac
- version: 3.0

## Description

This indicator renders a customizable matrix directly on your chart to track sector, sub-industry, and thematic ETF performance across key lookback periods without switching tabs.

Key Features:

Multi-Timeframe Metrics: Track 1-Day, 1-Week, 1-Month, and YTD performance side-by-side.

Theme Mapping: Displays explicit thematic descriptions alongside each ticker (e.g., Capital Markets, Semiconductors, Cloud, Cyber, Volatility).

Visual Customization: Toggle individual timeframe columns on/off, adjust matrix sizing, and set custom color palettes.

Bypassing the 40-Ticker Script Limit:

Because TradingView caps each script to 40 ⁠data calls, ETFs are organized into select group batches in the settings.

To display 120+ ETFs simultaneously:

1. Load multiple instances of the indicator onto your chart.

2. Assign a different group batch to each instance.

3. Set the screen placement (Left, Center, Right) in the settings to render side-by-side panels.

## Source Code

````pine
// This Pine Script® code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © chardogg74

//@version=6
indicator("Sector/Theme Performance Dashboard", overlay=true, max_labels_count=500)

// ============================================================================
// INPUTS & CONFIGURATION
// ============================================================================
grp_config   = "Matrix Configuration"
i_sectorGroup = input.string("1: Innovation & Tech", "Select Sector Cluster", 
                 options=["1: Innovation & Tech", "2: Energy & Commodities", "3: Healthcare, Bio & Crypto", "4: Defense, Infra & Global", "5: Financials, Retail & Consumer"], 
                 group=grp_config, tooltip="Keeps request calls under TradingView's 40-security limit per instance.")
i_sortByTime  = input.string("1M", "Sort By Column Performance", options=["1D", "1W", "1M", "YTD"], group=grp_config)

grp_cols      = "Visible Table Columns"
i_showTheme   = input.bool(true,  "Show Theme Tag", group=grp_cols)
i_showDetail  = input.bool(false, "Show Detailed Description", group=grp_cols)
i_show1D      = input.bool(true,  "Show 1-Day %", group=grp_cols)
i_show1W      = input.bool(true,  "Show 1-Week %", group=grp_cols)
i_show1M      = input.bool(true,  "Show 1-Month %", group=grp_cols)
i_showYTD     = input.bool(true,  "Show YTD %", group=grp_cols)

grp_layout    = "Display & Table Layout"
i_tablePos    = input.string("Top Right", "Screen Position", 
                 options=["Top Right", "Top Center", "Top Left", "Middle Right", "Center", "Middle Left", "Bottom Right", "Bottom Center", "Bottom Left"], group=grp_layout)
i_textSize    = input.string("Small", "Text Size", options=["Auto", "Tiny", "Small", "Normal", "Large", "Huge"], group=grp_layout)
i_maxRows     = input.int(15, "Max Display Rows", minval=3, maxval=40, group=grp_layout, tooltip="Reduce rows to prevent top and bottom tables from overlapping on smaller screens.")

grp_colors    = "Heatmap Color Palette"
threshStrong  = input.float(2.0, "Strong Threshold (%)", group=grp_colors)
c_strong_pos  = input.color(color.rgb(38, 166, 154, 0), "Strong Positive", group=grp_colors)
c_mild_pos    = input.color(color.rgb(38, 166, 154, 60), "Mild Positive", group=grp_colors)
c_strong_neg  = input.color(color.rgb(239, 83, 80, 0), "Strong Negative", group=grp_colors)
c_mild_neg    = input.color(color.rgb(239, 83, 80, 60), "Mild Negative", group=grp_colors)
c_neutral     = input.color(color.rgb(42, 46, 57, 0), "Neutral / Header Bg", group=grp_colors)

// ============================================================================
// DATA STRUCTURES
// ============================================================================
type SectorAsset
    string symbol
    string themeTag
    string description

// ============================================================================
// DATASET CLUSTERS
// ============================================================================
f_loadSectorCluster(string groupName) =>
    SectorAsset[] list = array.new<SectorAsset>()
    if groupName == "1: Innovation & Tech"
        array.push(list, SectorAsset.new("BAI", "AI", "Actively selected companies across the AI value chain"))
        array.push(list, SectorAsset.new("AIQ", "AI", "Passive global AI, big-data, software and hardware exposure"))
        array.push(list, SectorAsset.new("MAGS", "Mega-cap tech", "Equal-weight exposure to only the Magnificent Seven"))
        array.push(list, SectorAsset.new("SMH", "Semiconductors", "Concentrated in approximately 25 dominant global chip companies"))
        array.push(list, SectorAsset.new("SOXX", "Semiconductors", "Approximately 30 large U.S.-listed chipmakers and equipment suppliers"))
        array.push(list, SectorAsset.new("XSD", "Semiconductors", "Equal-weight semiconductors with greater small-company exposure"))
        array.push(list, SectorAsset.new("DRAM", "Memory", "Concentrated exposure to global DRAM, NAND and storage-memory companies"))
        array.push(list, SectorAsset.new("QTUM", "Quantum computing", "Equal-weight quantum, machine-learning and enabling-chip companies"))
        array.push(list, SectorAsset.new("IGV", "Software", "Market-cap-weighted large software companies"))
        array.push(list, SectorAsset.new("XSW", "Software", "Equal-weight U.S. software with greater small-company exposure"))
        array.push(list, SectorAsset.new("CLOU", "Cloud", "Global companies deriving meaningful revenue from cloud computing"))
        array.push(list, SectorAsset.new("SKYY", "Cloud", "Established cloud infrastructure, platform and software companies"))
        array.push(list, SectorAsset.new("WCLD", "Cloud", "Equal-weight emerging cloud-software companies with higher growth exposure"))
        array.push(list, SectorAsset.new("CIBR", "Cybersecurity", "Cybersecurity software, networking and security-service companies"))
        array.push(list, SectorAsset.new("RACK", "Data centers", "Chips, power, cooling and equipment supplying data centers"))
        array.push(list, SectorAsset.new("IDGT", "Digital infrastructure", "Data-center and telecom-tower REITs plus communications equipment"))
        array.push(list, SectorAsset.new("BOTZ", "Robotics", "Large global industrial-robotics, automation and AI-hardware companies"))
        array.push(list, SectorAsset.new("ROBO", "Robotics", "Diversified, relatively equal-weight global robotics and automation"))
        array.push(list, SectorAsset.new("ARKQ", "Robotics", "Actively selected robotics, autonomy, drones and industrial AI"))
        array.push(list, SectorAsset.new("ARKK", "Innovation", "Actively selected disruptive companies across multiple industries"))
        array.push(list, SectorAsset.new("ARKW", "Internet", "Actively selected cloud, digital media, blockchain and internet companies"))
        array.push(list, SectorAsset.new("FDN", "Internet", "Approximately 40 large U.S. internet and digital-platform companies"))
        array.push(list, SectorAsset.new("FFTY", "Growth stocks", "The 50 highest-ranked stocks from the IBD growth methodology"))
        array.push(list, SectorAsset.new("SPMO", "Momentum", "The 100 S&P 500 stocks with the strongest price momentum"))
        array.push(list, SectorAsset.new("DXYZ", "Private tech", "Closed-end fund holding private high-growth technology companies"))
        array.push(list, SectorAsset.new("ESPO", "Gaming", "Video-game publishers, esports platforms and gaming hardware"))
        array.push(list, SectorAsset.new("METV", "Metaverse", "Gaming, virtual platforms, computing and metaverse infrastructure"))
        array.push(list, SectorAsset.new("BUZZ", "Social sentiment", "Large U.S. stocks receiving positive online attention"))

    else if groupName == "2: Energy & Commodities"
        array.push(list, SectorAsset.new("USO", "Crude oil", "WTI crude-oil futures—not oil-company stocks"))
        array.push(list, SectorAsset.new("UNG", "Natural gas", "Henry Hub natural-gas futures—not gas-producing stocks"))
        array.push(list, SectorAsset.new("FCG", "Natural gas", "Natural-gas producers—not the gas commodity"))
        array.push(list, SectorAsset.new("IEO", "Oil & gas", "Market-cap-weighted large U.S. oil and gas producers"))
        array.push(list, SectorAsset.new("XOP", "Oil & gas", "Equal-weight U.S. oil and gas producers and refiners"))
        array.push(list, SectorAsset.new("OIH", "Oil services", "Concentrated exposure to the largest oilfield-service companies"))
        array.push(list, SectorAsset.new("XES", "Oil services", "Equal-weight oil equipment and service companies"))
        array.push(list, SectorAsset.new("AMLP", "Energy infrastructure", "Midstream pipelines and MLPs focused on fees and distributions"))
        array.push(list, SectorAsset.new("GUNR", "Natural resources", "Upstream companies extracting energy, metals and agricultural resources"))
        array.push(list, SectorAsset.new("GNR", "Natural resources", "Large global energy, metals and agriculture producers"))
        array.push(list, SectorAsset.new("GLD", "Gold", "Holds physical gold bullion for direct gold-price exposure"))
        array.push(list, SectorAsset.new("GDX", "Gold miners", "Large and mid-sized global gold-mining companies"))
        array.push(list, SectorAsset.new("GDXJ", "Gold miners", "Smaller and more speculative gold-mining companies"))
        array.push(list, SectorAsset.new("SLV", "Silver", "Holds physical silver bullion for direct silver-price exposure"))
        array.push(list, SectorAsset.new("SIL", "Silver miners", "Established global silver-mining companies"))
        array.push(list, SectorAsset.new("SILJ", "Silver miners", "Smaller, more speculative silver-mining companies"))
        array.push(list, SectorAsset.new("COPX", "Copper", "Global copper miners—not the physical copper price"))
        array.push(list, SectorAsset.new("LIT", "Lithium", "Global lithium miners, processors and battery manufacturers"))
        array.push(list, SectorAsset.new("PLTM", "Platinum", "Physically backed platinum-price exposure"))
        array.push(list, SectorAsset.new("PALL", "Palladium", "Physically backed palladium-price exposure"))
        array.push(list, SectorAsset.new("REMX", "Strategic metals", "Rare-earth and strategic-metal miners, processors and refiners"))
        array.push(list, SectorAsset.new("SLX", "Steel", "Global steel producers and related mining companies"))
        array.push(list, SectorAsset.new("XME", "Metals & mining", "Equal-weight U.S. steel, coal and diversified mining companies"))
        array.push(list, SectorAsset.new("URA", "Uranium", "Uranium miners plus nuclear-equipment and component manufacturers"))
        array.push(list, SectorAsset.new("URNM", "Uranium", "Pure-play uranium miners plus some physical uranium exposure"))
        array.push(list, SectorAsset.new("NLR", "Nuclear", "Nuclear utilities, reactor suppliers and uranium companies"))
        array.push(list, SectorAsset.new("TAN", "Solar", "Global solar manufacturers, installers and technology suppliers"))
        array.push(list, SectorAsset.new("FAN", "Wind energy", "Global wind-turbine manufacturers, suppliers and wind-power operators"))
        array.push(list, SectorAsset.new("ICLN", "Clean energy", "Broad global renewable-energy producers and equipment companies"))

    else if groupName == "3: Healthcare, Bio & Crypto"
        array.push(list, SectorAsset.new("IBB", "Biotechnology", "Market-cap-weighted large Nasdaq-listed biotechnology companies"))
        array.push(list, SectorAsset.new("XBI", "Biotechnology", "Equal-weight biotech with substantial small-company exposure"))
        array.push(list, SectorAsset.new("PBE", "Biotechnology", "Biotech and genomic companies selected using multiple factors"))
        array.push(list, SectorAsset.new("ARKG", "Genomics", "Actively selected genomics, diagnostics and gene-therapy companies"))
        array.push(list, SectorAsset.new("HELX", "Genomics", "Actively selected gene-editing and genomic-medicine companies"))
        array.push(list, SectorAsset.new("CANC", "Healthcare", "Actively selected cancer-treatment and oncology companies"))
        array.push(list, SectorAsset.new("OZEM", "Weight loss", "Actively selected GLP-1 drugs and weight-loss supply-chain companies"))
        array.push(list, SectorAsset.new("PPH", "Pharmaceuticals", "Concentrated portfolio of large global drug manufacturers"))
        array.push(list, SectorAsset.new("XPH", "Pharmaceuticals", "Equal-weight U.S. drugmakers, giving smaller companies more influence"))
        array.push(list, SectorAsset.new("IHI", "Medical devices", "Market-cap-weighted large U.S. medical-device manufacturers"))
        array.push(list, SectorAsset.new("XHE", "Medical equipment", "Equal-weight U.S. medical equipment and supply companies"))
        array.push(list, SectorAsset.new("IHF", "Healthcare providers", "Market-cap-weighted U.S. insurers, hospitals and care providers"))
        array.push(list, SectorAsset.new("XHS", "Healthcare services", "Equal-weight insurers, facilities, distributors and healthcare services"))
        array.push(list, SectorAsset.new("PSIL", "Psychedelics", "Actively selected psychedelic-medicine companies"))
        array.push(list, SectorAsset.new("CNBS", "Cannabis", "Actively selected global cannabis-related companies"))
        array.push(list, SectorAsset.new("MSOS", "Cannabis", "U.S. cannabis operators accessed mainly through swap contracts"))
        array.push(list, SectorAsset.new("IBIT", "Bitcoin", "Holds Bitcoin directly for spot-price exposure"))
        array.push(list, SectorAsset.new("WGMI", "Bitcoin", "Bitcoin-mining companies—not Bitcoin itself"))
        array.push(list, SectorAsset.new("ETHA", "Ethereum", "Holds Ether directly for spot-price exposure"))
        array.push(list, SectorAsset.new("SOLZ", "Cryptocurrency", "One-times Solana exposure through futures—not spot SOL"))
        array.push(list, SectorAsset.new("XRPI", "Cryptocurrency", "One-times XRP exposure through futures and derivatives—not spot XRP"))
        array.push(list, SectorAsset.new("BLOK", "Blockchain", "Actively selected companies using or developing blockchain"))
        array.push(list, SectorAsset.new("ARKF", "Fintech", "Actively selected digital payments, banking and financial platforms"))
        array.push(list, SectorAsset.new("IPAY", "Payments", "Global card networks, payment processors and digital-wallet companies"))
        array.push(list, SectorAsset.new("ARKX", "Space", "Actively selected space companies plus enabling technologies"))
        array.push(list, SectorAsset.new("UFO", "Space", "Rules-based companies deriving substantial revenue directly from space"))
        array.push(list, SectorAsset.new("NASA", "Space", "Actively selected public and limited pre-IPO space companies"))
        array.push(list, SectorAsset.new("GENZ", "Digital economy", "Fintech, gig-economy and online-betting platforms serving digital natives"))

    else if groupName == "4: Defense, Infra & Global"
        array.push(list, SectorAsset.new("ITA", "Defense", "Market-cap-weighted portfolio dominated by major U.S. defense contractors"))
        array.push(list, SectorAsset.new("XAR", "Defense", "Equal-weight aerospace and defense, including smaller contractors"))
        array.push(list, SectorAsset.new("SHLD", "Defense technology", "Global drones, cybersecurity, AI and advanced-defense technology"))
        array.push(list, SectorAsset.new("PAVE", "Infrastructure", "U.S. construction, engineering, materials and industrial infrastructure"))
        array.push(list, SectorAsset.new("IGF", "Infrastructure", "Global owners and operators of utilities, transport and infrastructure"))
        array.push(list, SectorAsset.new("GRID", "Electrical grid", "Grid equipment, power management and electrical infrastructure"))
        array.push(list, SectorAsset.new("PHO", "Water", "U.S. water infrastructure, treatment and technology companies"))
        array.push(list, SectorAsset.new("EVX", "Environment", "Waste-management and environmental-service companies"))
        array.push(list, SectorAsset.new("USCA", "Climate", "Broad U.S. companies leading their sectors on climate policies"))
        array.push(list, SectorAsset.new("BOAT", "Shipping", "Global marine shipping operators"))
        array.push(list, SectorAsset.new("SUPL", "Logistics", "Global logistics, freight and supply-chain technology companies"))
        array.push(list, SectorAsset.new("IYT", "Transportation", "Market-cap-weighted large U.S. transport companies"))
        array.push(list, SectorAsset.new("XTN", "Transportation", "Equal-weight airlines, railroads, trucking and logistics"))
        array.push(list, SectorAsset.new("JETS", "Airlines", "Global airline operators and related aviation companies"))
        array.push(list, SectorAsset.new("AWAY", "Travel technology", "Booking platforms and travel technology—not airlines themselves"))
        array.push(list, SectorAsset.new("ASHR", "China", "300 large mainland Chinese A-share companies"))
        array.push(list, SectorAsset.new("FXI", "China", "Approximately 50 large Chinese companies listed in Hong Kong"))
        array.push(list, SectorAsset.new("GXC", "China", "Broad Chinese market across multiple sectors and company sizes"))
        array.push(list, SectorAsset.new("KWEB", "China internet", "Chinese internet, e-commerce and digital-platform companies"))
        array.push(list, SectorAsset.new("CHIQ", "China consumer", "Chinese consumer-discretionary companies"))
        array.push(list, SectorAsset.new("KURE", "China healthcare", "Healthcare companies operating primarily in China"))
        array.push(list, SectorAsset.new("EWY", "South Korea", "Large and mid-sized South Korean companies"))
        array.push(list, SectorAsset.new("EWZ", "Brazil", "Large and mid-sized Brazilian companies"))
        array.push(list, SectorAsset.new("ILF", "Latin America", "40 large companies from Brazil, Mexico, Chile and other Latin markets"))
        array.push(list, SectorAsset.new("ARGT", "Argentina", "Argentine companies and companies deriving revenue from Argentina"))
        array.push(list, SectorAsset.new("NANC", "Political", "Stocks disclosed as purchases by Democratic lawmakers and spouses"))
        array.push(list, SectorAsset.new("HYDR", "Hydrogen", "Hydrogen producers, fuel cells and electrolyzer companies"))
        array.push(list, SectorAsset.new("MOO", "Agriculture", "Global fertilizer, equipment, seed and agricultural companies"))

    else if groupName == "5: Financials, Retail & Consumer"
        array.push(list, SectorAsset.new("KRE", "Banks", "Equal-weight U.S. regional banks"))
        array.push(list, SectorAsset.new("KBE", "Banks", "Equal-weight mix of large, regional and diversified U.S. banks"))
        array.push(list, SectorAsset.new("IAI", "Capital markets", "Market-cap-weighted brokers, investment banks and stock exchanges"))
        array.push(list, SectorAsset.new("KCE", "Capital markets", "Equal-weight asset managers, brokers, exchanges and investment banks"))
        array.push(list, SectorAsset.new("KIE", "Insurance", "Equal-weight property, life, health and reinsurance companies"))
        array.push(list, SectorAsset.new("ITB", "Homebuilding", "Market-cap-weighted U.S. homebuilders and housing suppliers"))
        array.push(list, SectorAsset.new("XHB", "Housing", "Equal-weight homebuilders, building products and home retailers"))
        array.push(list, SectorAsset.new("HOMZ", "Housing", "Entire housing cycle: builders, REITs, materials and home services"))
        array.push(list, SectorAsset.new("SCHH", "Real estate", "Broad U.S. equity REITs, generally excluding mortgage REITs"))
        array.push(list, SectorAsset.new("RTH", "Retail", "Concentrated portfolio of the largest U.S.-listed retailers"))
        array.push(list, SectorAsset.new("XRT", "Retail", "Equal-weight retailers with much more small-company exposure"))
        array.push(list, SectorAsset.new("IBUY", "Online retail", "Companies earning most of their revenue from online sales"))
        array.push(list, SectorAsset.new("PEJ", "Leisure", "Restaurants, entertainment, hotels and leisure companies"))
        array.push(list, SectorAsset.new("BETZ", "Gambling", "Global sports-betting, casino and online-gambling companies"))
        array.push(list, SectorAsset.new("ACT", "Targeted exposure", "Actively managed target industry exposure"))
        array.push(list, SectorAsset.new("PBJ", "Food & beverage", "U.S. food and beverage companies selected using multiple factors"))
        array.push(list, SectorAsset.new("PAWZ", "Pet industry", "Pet food, veterinary care and animal-health companies"))
        array.push(list, SectorAsset.new("WOOD", "Timber", "Global forestry, paper, packaging and timber REIT companies"))
        array.push(list, SectorAsset.new("IYZ", "Telecom", "Market-cap-weighted U.S. telecom companies"))
        array.push(list, SectorAsset.new("XTL", "Telecom", "Equal-weight telecom carriers, equipment makers and satellite companies"))
        array.push(list, SectorAsset.new("SOCL", "Social media", "Global social networks, messaging and content platforms"))
        array.push(list, SectorAsset.new("MEME", "Meme stocks", "Stocks driven by social attention, volatility and retail participation"))
        array.push(list, SectorAsset.new("HLAL", "Values-based", "U.S. stocks screened for Sharia compliance"))
        array.push(list, SectorAsset.new("ESGU", "ESG", "Broad U.S. market tilted toward stronger ESG-rated companies"))
        array.push(list, SectorAsset.new("SHE", "Gender diversity", "U.S. companies with relatively strong female leadership"))
        array.push(list, SectorAsset.new("SVIX", "Volatility", "Targets the inverse daily performance of short-term VIX futures"))
        array.push(list, SectorAsset.new("FDRV", "Electric vehicles", "EV, autonomous-driving and supporting technology companies"))
        array.push(list, SectorAsset.new("DRIV", "Electric vehicles", "Broad EV and autonomous-driving value chain"))
        array.push(list, SectorAsset.new("PBW", "Clean energy", "Diversified clean-energy companies with a smaller-growth-stock tilt"))

    list

// ============================================================================
// HELPER FUNCTIONS
// ============================================================================
f_cell_color(float val) =>
    val > threshStrong  ? c_strong_pos : val > 0.0 ? c_mild_pos : val < -threshStrong ? c_strong_neg : val < 0.0 ? c_mild_neg : c_neutral

f_format_pct(float val) =>
    na(val) ? "N/A" : (val > 0.0 ? "+" : "") + str.tostring(val, "0.02") + "%"

f_resolvePos(string posSetting) =>
    switch posSetting
        "Top Right"      => position.top_right
        "Top Center"     => position.top_center
        "Top Left"       => position.top_left
        "Middle Right"   => position.middle_right
        "Center"         => position.middle_center
        "Middle Left"    => position.middle_left
        "Bottom Right"   => position.bottom_right
        "Bottom Center"  => position.bottom_center
        "Bottom Left"    => position.bottom_left
        => position.top_right

f_resolveTextSize(string sz) =>
    switch sz
        "Auto"   => size.auto
        "Tiny"   => size.tiny
        "Small"  => size.small
        "Normal" => size.normal
        "Large"  => size.large
        "Huge"   => size.huge
        => size.small

// Added ignore_invalid_symbol=true to handle unlisted symbols gracefully
f_calc_returns(string sym) =>
    [d_c, w_c, m_c, y_c, curr] = request.security(sym, "D", [close[1], ta.valuewhen(ta.change(time("W")) != 0, close[1], 0), ta.valuewhen(ta.change(time("M")) != 0, close[1], 0), ta.valuewhen(ta.change(time("12M")) != 0, close[1], 0), close], barmerge.gaps_off, barmerge.lookahead_on, ignore_invalid_symbol=true)
    float p1d  = not na(d_c) and d_c != 0 ? ((curr - d_c) / d_c) * 100.0 : na
    float p1w  = not na(w_c) and w_c != 0 ? ((curr - w_c) / w_c) * 100.0 : na
    float p1m  = not na(m_c) and m_c != 0 ? ((curr - m_c) / m_c) * 100.0 : na
    float pytd = not na(y_c) and y_c != 0 ? ((curr - y_c) / y_c) * 100.0 : na
    [p1d, p1w, p1m, pytd]

// ============================================================================
// RENDERING & SORTING (LAST BAR ONLY)
// ============================================================================
if barstate.islast
    SectorAsset[] activeCluster = f_loadSectorCluster(i_sectorGroup)
    
    string[] tickers = array.new_string(0)
    string[] tags    = array.new_string(0)
    string[] desc    = array.new_string(0)
    float[]  arr1D   = array.new_float(0)
    float[]  arr1W   = array.new_float(0)
    float[]  arr1M   = array.new_float(0)
    float[]  arrYTD  = array.new_float(0)
    float[]  sortKey = array.new_float(0)

    for item in activeCluster
        [p1d, p1w, p1m, pytd] = f_calc_returns(item.symbol)
        
        tickers.push(item.symbol)
        tags.push(item.themeTag)
        desc.push(item.description)
        arr1D.push(p1d)
        arr1W.push(p1w)
        arr1M.push(p1m)
        arrYTD.push(pytd)
        
        float kVal = i_sortByTime == "1D" ? p1d : i_sortByTime == "1W" ? p1w : i_sortByTime == "1M" ? p1m : pytd
        sortKey.push(na(kVal) ? -999999.0 : kVal)

    // Sort Descending
    int n = tickers.size()
    if n > 1
        for i = 0 to n - 2
            for j = 0 to n - i - 2
                if sortKey.get(j) < sortKey.get(j + 1)
                    float tempK = sortKey.get(j)
                    sortKey.set(j, sortKey.get(j + 1))
                    sortKey.set(j + 1, tempK)
                    
                    string tempT = tickers.get(j)
                    tickers.set(j, tickers.get(j + 1))
                    tickers.set(j + 1, tempT)
                    
                    string tempTag = tags.get(j)
                    tags.set(j, tags.get(j + 1))
                    tags.set(j + 1, tempTag)
                    
                    string tempD = desc.get(j)
                    desc.set(j, desc.get(j + 1))
                    desc.set(j + 1, tempD)
                    
                    float temp1D = arr1D.get(j)
                    arr1D.set(j, arr1D.get(j + 1))
                    arr1D.set(j + 1, temp1D)
                    
                    float temp1W = arr1W.get(j)
                    arr1W.set(j, arr1W.get(j + 1))
                    arr1W.set(j + 1, temp1W)
                    
                    float temp1M = arr1M.get(j)
                    arr1M.set(j, arr1M.get(j + 1))
                    arr1M.set(j + 1, temp1M)
                    
                    float tempYTD = arrYTD.get(j)
                    arrYTD.set(j, arrYTD.get(j + 1))
                    arrYTD.set(j + 1, tempYTD)

    // Dynamic Column Calculation
    int colCount = 1 // Always show Ticker
    if i_showTheme
        colCount += 1
    if i_showDetail
        colCount += 1
    if i_show1D
        colCount += 1
    if i_show1W
        colCount += 1
    if i_show1M
        colCount += 1
    if i_showYTD
        colCount += 1

    string fontSz = f_resolveTextSize(i_textSize)
    
    // Setup Table with Max Row Limit to prevent overlap
    int displayRows = math.min(tickers.size(), i_maxRows)
    var table myTable = table.new(f_resolvePos(i_tablePos), colCount, displayRows + 1, border_width=1, border_color=color.black)

    // Dynamic Headers
    int curCol = 0
    table.cell(myTable, curCol, 0, "Ticker", text_color=color.white, bgcolor=c_neutral, text_size=fontSz)
    curCol += 1

    if i_showTheme
        table.cell(myTable, curCol, 0, "Theme", text_color=color.white, bgcolor=c_neutral, text_size=fontSz)
        curCol += 1

    if i_showDetail
        table.cell(myTable, curCol, 0, "Detailed Description", text_color=color.white, bgcolor=c_neutral, text_size=fontSz, text_halign=text.align_left)
        curCol += 1

    if i_show1D
        table.cell(myTable, curCol, 0, "1-Day", text_color=color.white, bgcolor=c_neutral, text_size=fontSz)
        curCol += 1

    if i_show1W
        table.cell(myTable, curCol, 0, "1-Week", text_color=color.white, bgcolor=c_neutral, text_size=fontSz)
        curCol += 1

    if i_show1M
        table.cell(myTable, curCol, 0, "1-Month", text_color=color.white, bgcolor=c_neutral, text_size=fontSz)
        curCol += 1

    if i_showYTD
        table.cell(myTable, curCol, 0, "YTD", text_color=color.white, bgcolor=c_neutral, text_size=fontSz)
        curCol += 1

    // Data Rows
    if displayRows > 0
        for r = 0 to displayRows - 1
            string t  = tickers.get(r)
            string tg = tags.get(r)
            string d  = desc.get(r)
            float  v1 = arr1D.get(r)
            float  vW = arr1W.get(r)
            float  vM = arr1M.get(r)
            float  vY = arrYTD.get(r)

            int rowIdx = r + 1
            int cIdx = 0

            table.cell(myTable, cIdx, rowIdx, t, text_color=color.white, bgcolor=c_neutral, text_size=fontSz)
            cIdx += 1

            if i_showTheme
                table.cell(myTable, cIdx, rowIdx, tg, text_color=color.white, bgcolor=c_neutral, text_size=fontSz)
                cIdx += 1

            if i_showDetail
                table.cell(myTable, cIdx, rowIdx, d, text_color=color.white, bgcolor=c_neutral, text_size=fontSz, text_halign=text.align_left)
                cIdx += 1

            if i_show1D
                table.cell(myTable, cIdx, rowIdx, f_format_pct(v1), text_color=color.white, bgcolor=f_cell_color(v1), text_size=fontSz)
                cIdx += 1

            if i_show1W
                table.cell(myTable, cIdx, rowIdx, f_format_pct(vW), text_color=color.white, bgcolor=f_cell_color(vW), text_size=fontSz)
                cIdx += 1

            if i_show1M
                table.cell(myTable, cIdx, rowIdx, f_format_pct(vM), text_color=color.white, bgcolor=f_cell_color(vM), text_size=fontSz)
                cIdx += 1

            if i_showYTD
                table.cell(myTable, cIdx, rowIdx, f_format_pct(vY), text_color=color.white, bgcolor=f_cell_color(vY), text_size=fontSz)
                cIdx += 1
````
