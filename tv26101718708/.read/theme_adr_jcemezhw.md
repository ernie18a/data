# Theme & ADR %

- url: https://www.tradingview.com/script/jcEmEzHW-Theme-ADR/
- type: indicator
- pine_id: PUB;d1d06d17fc254c289063ab40895a0fba
- version: 1.0

## Description

stock themes and adr %. for scanning sector
stock themes and adr %. for scanning sector

stock themes and adr %. for scanning sector

## Source Code

````pine
// This Pine Script™ source code is subject to the terms of the Mozilla Public License 2.0
// https://mozilla.org/MPL/2.0/

//@version=5
indicator("Theme & ADR %", overlay=true)

// ──────────────────────────────────────────────
// SETTINGS
// ──────────────────────────────────────────────
adrLength    = input.int(14, "ADR Period (days)", minval=5, maxval=100)
showADR      = input.bool(true, "Show ADR %")
showTheme    = input.bool(true, "Show Theme")
fontSize     = input.string("small", "Font Size", options=["tiny", "small", "normal", "large"])

// ──────────────────────────────────────────────
// ADR % CALCULATION (TradingView default method)
// Entire calculation done on daily TF so value
// is identical regardless of chart timeframe
// ──────────────────────────────────────────────
adrPct = request.security(syminfo.tickerid, "D", (ta.sma(high, adrLength) - ta.sma(low, adrLength)) / close * 100)

// ──────────────────────────────────────────────
// THEME MAPPING — ~900+ tickers
// ──────────────────────────────────────────────
t = syminfo.ticker

// ── SOFTWARE ──────────────────────────────────
isSoftware =
  t == "MSFT"  or t == "ORCL"  or t == "CRM"   or
  t == "ADBE"  or t == "NOW"   or t == "INTU"   or
  t == "SNPS"  or t == "CDNS"  or t == "WDAY"   or
  t == "TEAM"  or t == "DDOG"  or t == "HUBS"   or
  t == "NET"   or t == "MDB"   or t == "SNOW"   or
  t == "SHOP"  or t == "UBER"  or t == "DASH"   or
  t == "ABNB"  or t == "TWLO"  or t == "ZM"     or
  t == "DOCU"  or t == "BILL"  or t == "PAYC"   or
  t == "PCTY"  or t == "MANH"  or t == "ANSS"   or
  t == "MNDY"  or t == "APP"   or t == "WIX"    or
  t == "FIG"   or t == "FICO"  or t == "CTSH"   or
  t == "ACN"   or t == "IT"    or t == "GPN"    or
  t == "FI"    or t == "FIS"   or t == "GDDY"   or
  t == "CPAY"  or t == "VRSK"  or t == "BR"     or
  t == "TYL"   or t == "VRSN"  or t == "FFIV"   or
  t == "JKHY"  or t == "SMCI"  or t == "DUOL"   or
  t == "IOT"   or t == "ZS"    or t == "PANW"   or
  t == "FSLY"  or t == "YOU"   or t == "ADEA"   or
  t == "RNG"   or t == "CFLT"  or t == "OS"     or
  t == "KEYS"  or t == "RELY"  or t == "WRBY"   or
  t == "CGNX"  or t == "GWRE"  or t == "TTAN"   or
  t == "RAMP"  or t == "CLVT"  or t == "ZD"     or
  t == "WLY"   or t == "TRI"   or t == "MASI"   or
  t == "BRZE"  or t == "BSY"   or t == "CARG"   or
  t == "DT"    or t == "DV"    or t == "FLYW"   or
  t == "FTDR"  or t == "GRND"  or t == "HNGE"   or
  t == "INTA"  or t == "NICE"  or t == "OPRA"   or
  t == "PEGA"  or t == "PCOR"  or t == "XYZ"    or
  t == "DAVE"  or t == "RELX"  or t == "MGNI"   or
  t == "DOCN"  or t == "KC"    or
  t == "GDS"   or t == "MSI"   or t == "ARW"    or
  t == "CW"    or t == "STRL"  or t == "TDY"    or
  t == "EE"    or t == "ESI"   or t == "ALH"    or
  t == "INGM"  or t == "PENG"  or
  t == "NAVN"  or t == "TLX"   or t == "VCX"    or
  t == "PSIX"  or t == "TH"    or t == "HLIT"  or t == "FROG"

// ── CYBERSECURITY ─────────────────────────────
isCyber =
  t == "CRWD"  or t == "PANW"  or t == "FTNT"   or
  t == "ZS"    or t == "S"     or t == "CYBR"   or
  t == "QLYS"  or t == "TENB"  or t == "RPD"    or
  t == "VRNS"  or t == "OKTA"  or t == "SAIL"

// ── SEMICONDUCTORS ────────────────────────────
isSemis =
  t == "NVDA"  or t == "AMD"   or t == "INTC"   or
  t == "AVGO"  or t == "QCOM"  or t == "TXN"    or
  t == "AMAT"  or t == "LRCX"  or t == "KLAC"   or
  t == "ADI"   or t == "MRVL"  or t == "ON"     or
  t == "NXPI"  or t == "TSM"   or t == "ASML"   or
  t == "ARM"   or t == "MCHP"  or t == "SWKS"   or
  t == "MPWR"  or t == "WOLF"  or t == "GFS"    or
  t == "AXTI"  or t == "ENTG"  or t == "MKSI"   or
  t == "ONTO"  or t == "AEHR"  or t == "ICHR"   or
  t == "UCTT"  or t == "FORM"  or t == "SLAB"   or
  t == "SKYT"  or t == "AEIS"  or t == "IMOS"   or
  t == "PLAB"  or t == "SIMO"  or t == "ACMR"   or
  t == "NVMI"  or t == "KLIC"  or t == "POWI"   or
  t == "TER"   or t == "ASIC"  or t == "ACDC"   or
  t == "CAMT"  or t == "COHU"  or t == "DIOD"   or
  t == "LSCC"  or t == "MTSI"  or t == "NVTS"   or
  t == "STM"   or t == "LFUS"  or t == "TSEM"   or
  t == "SITM"  or t == "SMTC"  or t == "AMKR"   or
  t == "ACLS"  or t == "MXL"   or t == "PDFS"   or
  t == "RMBS"  or t == "VECO"  or t == "VSH"    or
  t == "MPLT"  or t == "CBRS"

// ── MEMORY ────────────────────────────────────
isMemory =
  t == "MU"    or t == "WDC"   or t == "STX"    or
  t == "SNDK"  or t == "MRAM"

// ── BIG TECH ──────────────────────────────────
isBigTech =
  t == "AAPL"  or t == "GOOGL" or t == "GOOG"   or
  t == "META"  or t == "AMZN"

// ── AI / CLOUD ────────────────────────────────
isAI =
  t == "PLTR"  or t == "AI"    or t == "DELL"   or
  t == "HPE"   or t == "IBM"   or t == "SOUN"   or
  t == "INOD"  or t == "RXT"   or t == "TEM"   or t == "SHAZ"

// ── DATA CENTERS ──────────────────────────────
isDataCenters =
  t == "CRWV"  or t == "APLD"  or t == "IREN"   or
  t == "NBIS"  or t == "WULF"  or t == "EQIX"   or
  t == "DLR"   or t == "VRT"   or t == "ALAB"   or
  t == "CLS"   or t == "PSTG"  or t == "NTNX"  or t == "KEEL"

// ── NETWORKING / FIBER ────────────────────────
isNetworking =
  t == "CSCO"  or t == "ANET"  or t == "COMM"   or
  t == "CALX"  or t == "UNIT"  or t == "SIFY"   or
  t == "UI"    or t == "JNPR"  or t == "NTGR"   or
  t == "EXTR"

// ── PHOTONICS / OPTICS ────────────────────────
// Pure-play photonics: lasers, transceivers, silicon photonics,
// optical interconnects, coherent optics
isPhotonics =
  t == "LITE"  or t == "COHR"  or t == "AAOI"   or
  t == "IPGP"  or t == "POET"  or t == "LWLG"   or
  t == "LASR"  or t == "LPTH"  or t == "VIAV"   or
  t == "CRDO"  or t == "CIEN"  or t == "HIMX"   or
  t == "FN"    or t == "NOK"   or t == "GLW"    or
  t == "ADTN"

// ── URANIUM / NUCLEAR ─────────────────────────
isUranium =
  t == "CCJ"   or t == "UUUU"  or t == "UEC"    or
  t == "LEU"   or t == "DNN"   or t == "NXE"    or
  t == "NNE"   or t == "SMR"   or t == "URA"    or
  t == "URNM"  or t == "UROY"

// ── NUCLEAR ENERGY ────────────────────────────
isNuclearEnergy =
  t == "CEG"   or t == "VST"   or t == "TLN"    or
  t == "BWXT"  or t == "OKLO"

// ── POWER / ENERGY INFRA ─────────────────────
isPower =
  t == "BE"    or t == "GEV"   or t == "PWR"    or
  t == "ETR"   or t == "FSLR"  or t == "ENPH"   or
  t == "SEDG"  or t == "NEE"   or t == "RUN"    or
  t == "PLUG"  or t == "KMI"   or t == "WMB"    or
  t == "OKE"   or t == "TRGP"  or t == "LNG"    or
  t == "EIX"   or t == "PCG"   or t == "AMPX"   or
  t == "ENLT"  or t == "VG"    or t == "AROC"   or
  t == "KGS"   or t == "PAGP"  or t == "HE"     or
  t == "LB"    or t == "NXT"   or t == "AMSC"  or t == "FCEL"   or t == "TE"

// ── LITHIUM / BATTERY ─────────────────────────
isLithium =
  t == "ALB"   or t == "SQM"   or t == "LAC"    or
  t == "SLI"   or t == "PLL"   or t == "SGML"   or
  t == "QS"    or t == "LIT"   or t == "LTHM"   or
  t == "LAR"

// ── SPACE ─────────────────────────────────────
isSpace =
  t == "RKLB"  or t == "ASTS"  or t == "LUNR"   or
  t == "PL"    or t == "RDW"   or t == "BKSY"   or
  t == "SPIR"  or t == "JOBY"  or t == "ACHR"   or
  t == "UFO"   or t == "VSAT"  or t == "GRMN"   or
  t == "SATS"  or t == "SIRI"  or t == "IRDM"   or
  t == "GSAT"  or t == "TRMB"  or t == "FLY"    or
  t == "SATL"  or t == "YSS"

// ── DRONES ────────────────────────────────────
isDrones =
  t == "ONDS"  or t == "RCAT"  or t == "AVAV"   or
  t == "KTOS"  or t == "UAVS"  or t == "UMAC"

// ── QUANTUM COMPUTING ─────────────────────────
isQuantum =
  t == "IONQ"  or t == "RGTI"  or t == "QBTS"   or
  t == "QUBT"  or t == "ARQQ"  or t == "INFQ"

// ── FINTECH ───────────────────────────────────
isFintech =
  t == "SOFI"  or t == "HOOD"  or t == "AFRM"   or
  t == "UPST"  or t == "NU"    or t == "LC"     or
  t == "PYPL"  or t == "V"     or t == "MA"     or
  t == "SQ"    or t == "FOUR"  or t == "TOST"   or
  t == "RKT"   or t == "AXP"   or t == "DFS"    or
  t == "NDAQ"  or t == "CME"   or t == "ICE"    or
  t == "SPGI"  or t == "MCO"   or t == "MSCI"   or
  t == "MKTX"  or t == "CBOE"  or t == "MORN"   or
  t == "ATLC"  or t == "EVR"   or t == "JEF"    or
  t == "OPY"   or t == "PJT"   or t == "PWP"    or
  t == "SNEX"  or t == "VIRT"  or t == "WLTH"   or
  t == "AAMI"  or t == "ANDG"  or t == "RHLD"   or
  t == "BULL"

// ── APPAREL ──────────────────────────────────
isApparel =
  t == "NKE"   or t == "LULU"  or t == "AEO"    or
  t == "CROX"  or t == "VSCO"  or t == "UAA"    or
  t == "RL"    or t == "PVH"   or t == "TPR"    or
  t == "CPRI"  or t == "HBI"   or t == "VFC"    or
  t == "GPS"   or t == "ANF"   or t == "DECK"   or
  t == "SKX"   or t == "ONON"  or t == "BIRK"   or
  t == "FIGS"  or t == "UA"    or t == "WRBY"   or
  t == "LEVI"  or t == "MC"

// ── E-COMMERCE ────────────────────────────────
isEcommerce =
  t == "MELI"  or t == "SE"    or t == "CPNG"   or
  t == "ETSY"  or t == "W"     or t == "CHWY"

// ── REAL ESTATE ───────────────────────────────
isRealEstate =
  t == "AMT"   or t == "PLD"   or t == "CCI"    or
  t == "SPG"   or t == "PSA"   or t == "O"      or
  t == "WELL"  or t == "AVB"   or t == "EQR"    or
  t == "VTR"   or t == "ARE"   or t == "MAA"    or
  t == "ESS"   or t == "IRM"   or t == "CBRE"   or
  t == "CSGP"  or t == "INVH"  or t == "KIM"    or
  t == "REG"   or t == "UDR"   or t == "CPT"    or
  t == "BXP"   or t == "HST"   or t == "DOC"    or
  t == "FRT"   or t == "SUI"   or t == "ELS"    or
  t == "ALEX"  or t == "BKD"   or t == "VRE"    or
  t == "DHC"   or t == "TPH"   or t == "NSA"

// ── BANKS ─────────────────────────────────────
isBanks =
  t == "JPM"   or t == "BAC"   or t == "WFC"    or
  t == "GS"    or t == "MS"    or t == "C"      or
  t == "USB"   or t == "PNC"   or t == "TFC"    or
  t == "SCHW"  or t == "COF"   or t == "BK"     or
  t == "STT"   or t == "FITB"  or t == "HBAN"   or
  t == "CFG"   or t == "KEY"   or t == "RF"     or
  t == "FLG"   or t == "WAL"   or t == "ZION"   or
  t == "NTRS"  or t == "MTB"   or t == "SIVB"   or
  t == "CMA"   or t == "EWBC"  or t == "FHN"

// ── INSURANCE ─────────────────────────────────
isInsurance =
  t == "BRK.B" or t == "BRK.A" or t == "PGR"   or
  t == "ALL"   or t == "MET"   or t == "AIG"    or
  t == "PRU"   or t == "TRV"   or t == "AFL"    or
  t == "CB"    or t == "AJG"   or t == "MMC"    or
  t == "AON"   or t == "WTW"   or t == "ERIE"   or
  t == "HIG"   or t == "GL"    or t == "L"      or
  t == "RNR"   or t == "CINF"  or t == "BRO"

// ── UTILITIES ─────────────────────────────────
isUtilities =
  t == "DUK"   or t == "SO"    or t == "D"      or
  t == "AEP"   or t == "SRE"   or t == "EXC"    or
  t == "XEL"   or t == "ED"    or t == "WEC"    or
  t == "ES"    or t == "AWK"   or t == "ATO"    or
  t == "CMS"   or t == "DTE"   or t == "PPL"    or
  t == "FE"    or t == "AES"   or t == "EVRG"   or
  t == "NI"    or t == "NRG"   or t == "PNW"    or
  t == "CNP"   or t == "LNT"   or t == "ELPC"

// ── TRANSPORTS ────────────────────────────────
isTransports =
  t == "UNP"   or t == "UPS"   or t == "FDX"    or
  t == "CSX"   or t == "NSC"   or t == "JBHT"   or
  t == "ODFL"  or t == "XPO"   or t == "SAIA"   or
  t == "CHRW"  or t == "EXPD"  or t == "LSTR"   or
  t == "GFL"   or t == "RSG"   or t == "WM"     or
  t == "WAB"   or t == "CARR"  or t == "OTIS"   or
  t == "CAR"   or t == "ARCB"  or t == "MATX"   or
  t == "WLFC"  or t == "DAN"   or t == "HTZ"    or
  t == "RXO"   or t == "SNX"

// ── SHIPPING / TANKERS ────────────────────────
isShipping =
  t == "NAT"   or t == "FRO"   or t == "INSW"   or
  t == "DHT"   or t == "STNG"  or t == "TEN"    or
  t == "TRMD"  or t == "TNK"   or t == "TK"     or
  t == "ZIM"   or t == "SFL"   or t == "BWLP"   or
  t == "LPG"   or t == "ECO"   or t == "CDLR"   or
  t == "HAFN"  or t == "GEMI"  or t == "NMM"    or
  t == "SBLK"  or t == "ECG"

// ── BITCOIN / CRYPTO ──────────────────────────
isBitcoin =
  t == "BTCUSD"  or t == "BTCUSDT" or t == "MSTR"  or
  t == "COIN"    or t == "MARA"    or t == "RIOT"  or
  t == "CLSK"    or t == "HUT"     or t == "BITF"  or
  t == "IBIT"    or t == "ETHUSD"  or t == "ETHUSDT" or
  t == "SOLUSD"  or t == "SOLUSDT" or t == "BITO"  or
  t == "GBTC"    or t == "ETHE"    or t == "CRCL"  or
  t == "BMNR"  or t == "CIFR"  or t == "BTDR"  or t == "HIVE"

// ── PHARMA ────────────────────────────────────
isPharma =
  t == "JNJ"   or t == "LLY"   or t == "PFE"    or
  t == "MRK"   or t == "ABBV"  or t == "BMY"    or
  t == "AMGN"  or t == "GILD"  or t == "VRTX"   or
  t == "VTRS"  or t == "TAK"   or t == "NVO"    or
  t == "PAHC"

// ── HEALTH INSURANCE / MANAGED CARE ──────────
isHealthIns =
  t == "UNH"   or t == "CI"    or t == "HUM"    or
  t == "ELV"   or t == "CNC"   or t == "MOH"    or
  t == "OSCR"  or t == "ALHC"

// ── HEALTHCARE / SERVICES ─────────────────────
isHealthCare =
  t == "ABT"   or t == "TMO"   or t == "DHR"    or
  t == "ISRG"  or t == "SYK"   or t == "MCK"    or
  t == "CAH"   or t == "CVS"   or t == "HCA"    or
  t == "GEHC"  or t == "RMD"   or t == "WAT"    or
  t == "A"     or t == "IQV"   or t == "ZTS"    or
  t == "IDXX"  or t == "MTD"   or t == "WST"    or
  t == "TECH"  or t == "COR"   or t == "RVTY"   or
  t == "HSIC"  or t == "DGX"   or t == "LH"     or
  t == "DVA"   or t == "INNV"  or t == "LMAT"   or
  t == "THC"   or t == "HIMS"

// ── OIL & GAS ─────────────────────────────────
isOilGas =
  t == "XOM"   or t == "CVX"   or t == "COP"    or
  t == "EOG"   or t == "SLB"   or t == "MPC"    or
  t == "PSX"   or t == "VLO"   or t == "OXY"    or
  t == "DVN"   or t == "HAL"   or t == "FANG"   or
  t == "HES"   or t == "BKR"   or t == "OVV"    or
  t == "APA"   or t == "CTRA"  or t == "MRO"    or
  t == "EQT"   or t == "FTI"   or t == "WHD"    or
  t == "AR"    or t == "CHK"   or t == "VIST"   or
  t == "KOS"   or t == "SOC"   or t == "EQNR"   or
  t == "PBR"   or t == "CNQ"   or t == "SM"     or
  t == "PR"    or t == "PBF"   or t == "PTEN"   or
  t == "CRC"   or t == "CLMT"  or t == "LBRT"   or
  t == "EC"    or t == "SU"    or t == "IMO"    or
  t == "VAL"   or t == "BORR"  or t == "TDW"    or
  t == "NBR"   or t == "RIG"   or t == "NE"     or
  t == "SDRL"  or t == "OII"   or t == "NESR"   or
  t == "PDS"   or t == "FLOC"  or t == "AM"     or
  t == "CHRD"  or t == "CRGY"  or t == "DK"     or
  t == "EFXT"  or t == "FLNG"  or t == "MTDR"   or
  t == "NVGS"  or t == "RRC"   or t == "PAA"    or
  t == "SSL"   or t == "UAN"   or t == "SEI"    or
  t == "BTU"   or t == "AESI"  or t == "BP"     or
  t == "BTE"   or t == "CVE"   or t == "DINO"   or
  t == "MGY"   or t == "NOG"   or t == "PARR"   or
  t == "PUMP"  or t == "RES"   or t == "SUN"    or
  t == "TALO"  or t == "TTE"   or t == "SHEL"   or
  t == "WTTR"  or t == "XPRO"  or t == "HP"     or
  t == "HLX"   or t == "GLNG"  or t == "KNTK"   or
  t == "INR"   or t == "VET"   or t == "UGP"    or
  t == "NEXT"

// ── HOME CONSTRUCTION ─────────────────────────
isHomeBuild =
  t == "DHI"   or t == "LEN"   or t == "NVR"    or
  t == "PHM"   or t == "TOL"   or t == "KBH"    or
  t == "MTH"   or t == "MDC"   or t == "MHO"    or
  t == "TMHC"  or t == "CCS"   or t == "GRBK"

// ── INDUSTRIALS ───────────────────────────────
isIndustrials =
  t == "CAT"   or t == "DE"    or t == "HON"    or
  t == "MMM"   or t == "GE"    or t == "ETN"    or
  t == "EMR"   or t == "ITW"   or t == "PH"     or
  t == "ROK"   or t == "CMI"   or t == "IR"     or
  t == "DOV"   or t == "AME"   or t == "NDSN"   or
  t == "SWK"   or t == "GWW"   or t == "FAST"   or
  t == "TT"    or t == "JCI"   or t == "CTAS"   or
  t == "ADP"   or t == "PAYX"  or t == "SNA"    or
  t == "ROP"   or t == "VRSK"  or t == "CPRT"   or
  t == "CRH"   or t == "VMC"   or t == "MLM"    or
  t == "HWM"   or t == "TDG"   or t == "AXON"   or
  t == "GNRC"  or t == "HUBB"  or t == "WCC"    or
  t == "XYL"   or t == "IEX"   or
  t == "PCAR"  or t == "ALLE"  or t == "AOS"    or
  t == "FTV"   or t == "BLDR"  or t == "WSO"    or
  t == "WWD"   or t == "IPGP"  or t == "BW"     or
  t == "DCO"   or t == "ATRO"  or t == "POWL"   or
  t == "DXPE"  or t == "TTC"   or t == "ESE"    or
  t == "GRC"   or t == "AGX"   or t == "MTZ"    or
  t == "FIX"   or t == "RRX"   or t == "ASTE"   or
  t == "ALSN"  or t == "VICR"  or t == "GLDD"   or
  t == "KTB"   or t == "MUSA"  or t == "SFM"    or
  t == "SSYS"  or t == "NVT"   or t == "EME"    or
  t == "ATKR"  or t == "WLDN"  or t == "CSWI"   or
  t == "ZWS"   or t == "ENVX"  or t == "FUN"    or
  t == "GGB"   or t == "HOG"   or t == "NSP"    or
  t == "DSGR"  or t == "DRVN"  or t == "TPC"    or
  t == "CDNL"  or t == "LGN"   or t == "VPG"    or
  t == "FLEX"  or t == "JBL"   or t == "APH"    or
  t == "TEL"   or t == "PLXS"  or t == "TTMI"   or
  t == "BELFA" or t == "MOD"   or t == "ZBRA"

// ── AEROSPACE & DEFENSE ───────────────────────
isAerospace =
  t == "BA"    or t == "LMT"   or t == "RTX"    or
  t == "NOC"   or t == "GD"    or t == "LHX"    or
  t == "TXT"   or t == "HII"   or t == "LDOS"   or
  t == "HEI"   or t == "SPR"   or t == "HXL"    or
  t == "BWXT"  or t == "ESLT"  or t == "KRMN"   or
  t == "DRS"   or t == "AIR"   or t == "VVX"    or
  t == "FTAI"  or t == "MOG.A"

// ── BIOTECHNOLOGY ─────────────────────────────
isBiotech =
  t == "MRNA"  or t == "REGN"  or t == "BIIB"   or
  t == "ILMN"  or t == "ALNY"  or t == "BMRN"   or
  t == "EXAS"  or t == "PCVX"  or t == "SRPT"   or
  t == "RARE"  or t == "NBIX"  or t == "IONS"   or
  t == "SGEN"  or t == "ARGX"  or t == "INCY"   or
  t == "HALO"  or t == "UTHR"  or t == "BNTX"   or
  t == "IBRX"  or t == "TXG"   or t == "PDYN"   or
  t == "ERAS"  or t == "DAWN"  or t == "ALMS"   or
  t == "IOVA"  or t == "CRVS"  or t == "TNGX"   or
  t == "WVE"   or t == "RAPT"  or t == "GPCR"   or
  t == "ACHC"  or t == "ACLX"  or t == "TYRA"   or
  t == "VTYX"  or t == "DBVT"  or t == "DNTH"   or
  t == "FOLD"  or t == "NVAX"  or t == "CGON"   or
  t == "ELVN"  or t == "NTLA"  or t == "PVLA"   or
  t == "ROIV"  or t == "TERN"  or t == "VIR"    or
  t == "TWST"  or t == "RLAY"  or t == "MIRM"   or
  t == "PLSE"  or t == "DFTX"  or t == "NBTX"   or
  t == "BCRX"  or t == "NKTR"  or t == "NVCR"   or
  t == "ORIC"  or t == "APGE"  or t == "ASTH"   or
  t == "BCAX"  or t == "CLDX"  or t == "CRSP"   or
  t == "EYPT"  or t == "GLTO"  or t == "MLTX"   or
  t == "PPTA"  or t == "SYRE"  or
  t == "TARS"  or t == "VKTX"  or t == "ZBIO"   or
  t == "EVCM"  or t == "ANAB"  or t == "EWTX"   or
  t == "RVMD"  or t == "NYAX"  or t == "RGC"    or
  t == "OCS"   or t == "APLS"  or t == "CNTA"   or
  t == "CORT"  or t == "KOD"   or t == "MRX"    or
  t == "OGN"   or t == "RAPP"  or t == "SLNO"   or
  t == "SMMT"  or t == "STAA"  or t == "TVTX"   or
  t == "NNNN"  or t == "MANE"

// ── RETAIL ────────────────────────────────────
isRetail =
  t == "WMT"   or t == "COST"  or t == "TGT"    or
  t == "HD"    or t == "LOW"   or t == "TJX"    or
  t == "ROST"  or t == "DG"    or t == "DLTR"   or
  t == "BURL"  or t == "FIVE"  or t == "ULTA"   or
  t == "BBY"   or t == "M"     or t == "KSS"    or
  t == "ORLY"  or t == "AZO"   or t == "AAP"    or
  t == "GME"   or t == "CVNA"  or t == "WSM"    or
  t == "TSCO"  or t == "KMX"   or t == "GPC"    or
  t == "POOL"  or t == "RH"    or t == "EBAY"   or
  t == "LKQ"

// ── MEDICAL DEVICES ──────────────────────────
isMedical =
  t == "MDT"   or t == "BSX"   or t == "EW"     or
  t == "ZBH"   or t == "BAX"   or t == "BDX"    or
  t == "HOLX"  or t == "ALGN"  or t == "PODD"   or
  t == "DXCM"  or t == "INSP"  or t == "NVST"   or
  t == "TFX"   or t == "SWAV"  or t == "GMED"   or
  t == "TMDX"  or t == "ANGO"  or t == "HTFL"

// ── CASINOS / GAMING ─────────────────────────
isCasinos =
  t == "LVS"   or t == "WYNN"  or t == "MGM"    or
  t == "CZR"   or t == "DKNG"  or t == "FLUT"   or
  t == "PENN"  or t == "RRR"   or t == "GENI"   or
  t == "RSI"   or t == "BALY"  or t == "EA"     or
  t == "TTWO"  or t == "ATVI"  or t == "LUCK"

// ── AIRLINES ──────────────────────────────────
isAirlines =
  t == "DAL"   or t == "UAL"   or t == "LUV"    or
  t == "AAL"   or t == "ALK"   or t == "JBLU"   or
  t == "SAVE"  or t == "HA"    or t == "SKYW"   or
  t == "RYAAY" or t == "ALGT"

// ── CRUISE LINES ──────────────────────────────
isCruise =
  t == "RCL"   or t == "CCL"   or t == "NCLH"   or
  t == "LIND"  or t == "VIK"

// ── TELECOM ───────────────────────────────────
isTelecom =
  t == "T"     or t == "VZ"    or t == "TMUS"   or
  t == "USM"   or t == "CMCSA" or t == "CHTR"   or
  t == "NWSA"  or t == "FOXA"  or t == "PARA"   or
  t == "SKM"   or t == "TIGO"  or t == "VIV"    or
  t == "WDS"   or t == "E"

// ── CONSUMER STAPLES ──────────────────────────
isStaples =
  t == "PG"    or t == "KO"    or t == "PEP"    or
  t == "PM"    or t == "MO"    or t == "CL"     or
  t == "MDLZ"  or t == "GIS"   or t == "KHC"   or
  t == "HSY"   or t == "K"     or t == "SJM"    or
  t == "STZ"   or t == "BF.B"  or t == "TAP"    or
  t == "SAM"   or t == "MNST"  or t == "KDP"    or
  t == "EL"    or t == "CHD"   or t == "MKC"    or
  t == "SYY"   or t == "KR"    or t == "ADM"    or
  t == "BG"    or t == "TSN"   or t == "HRL"    or
  t == "CAG"   or t == "CPB"   or t == "CLX"    or
  t == "WBA"   or t == "KVUE"  or t == "PRMB"   or
  t == "HLF"   or t == "DAR"   or t == "GPRE"   or
  t == "ANDE"  or t == "NTR"   or t == "SPB"    or
  t == "UNF"   or t == "DLX"   or t == "NEOG"   or
  t == "COKE"  or t == "OLPX"

// ── RESTAURANTS ───────────────────────────────
isRestaurants =
  t == "MCD"   or t == "SBUX"  or t == "CMG"    or
  t == "YUM"   or t == "DPZ"   or t == "WING"   or
  t == "QSR"   or t == "DINE"  or t == "DRI"    or
  t == "TXRH"  or t == "CAKE"  or t == "EAT"    or
  t == "JACK"  or t == "SHAK"  or t == "CAVA"   or
  t == "FRPT"

// ── GOLD / MINERS ─────────────────────────────
isGold =
  t == "XAUUSD" or t == "GLD"  or t == "GDX"    or
  t == "NEM"    or t == "GOLD" or t == "AEM"    or
  t == "FNV"    or t == "WPM"  or t == "RGLD"   or
  t == "KGC"    or t == "AGI"  or t == "AU"     or
  t == "GDXJ"  or t == "HYMC"  or t == "AUGO"   or
  t == "IAG"   or t == "CGAU"  or t == "AAUC"   or
  t == "IAUX"  or t == "ORLA"  or t == "NGD"    or
  t == "EGO"   or t == "ASA"   or t == "BVN"    or
  t == "ARMN"  or t == "ARIS"  or t == "CNL"    or
  t == "SII"   or t == "NG"    or t == "EQX"    or
  t == "GCMG"  or t == "TFPM"  or t == "IVA"    or
  t == "ORKA"  or t == "AHG"   or t == "NAK"

// ── SILVER / SILVER MINERS ────────────────────
isSilver =
  t == "SLV"   or t == "XAGUSD" or t == "PAAS"  or
  t == "HL"    or t == "CDE"   or t == "AG"     or
  t == "EXK"   or t == "FSM"   or t == "SVM"    or
  t == "SILJ"  or t == "SIL"   or t == "SIVR"   or
  t == "MAG"   or t == "SSRM"  or t == "GORO"   or
  t == "MUX"   or t == "SKE"   or t == "SA"     or
  t == "ASM"   or t == "USAS"  or t == "PSLV"   or
  t == "CEF"

// ── MATERIALS ─────────────────────────────────
isMaterials =
  t == "LIN"   or t == "SHW"   or t == "APD"    or
  t == "DD"    or t == "PPG"   or t == "ECL"    or
  t == "DOW"   or t == "CF"    or t == "MOS"    or
  t == "CE"    or t == "EMN"   or t == "IP"     or
  t == "PKG"   or t == "WRK"   or t == "AVY"    or
  t == "SEE"   or t == "IFF"   or t == "FMC"    or
  t == "RPM"   or t == "BALL"  or t == "AMCR"   or
  t == "TROX"  or t == "LYB"   or t == "WLK"    or
  t == "CC"    or t == "IPX"   or t == "SOLS"   or
  t == "KMT"   or t == "ECVT"  or t == "MEOH"   or
  t == "SON"   or t == "ALM"   or t == "EMAT"   or
  t == "AGRO"  or t == "OLN"   or t == "LXU"    or
  t == "CMBT"

// ── AUTOS ─────────────────────────────────────
isAutos =
  t == "TSLA"  or t == "F"     or t == "GM"     or
  t == "RIVN"  or t == "LCID"  or t == "NIO"    or
  t == "XPEV"  or t == "LI"    or t == "STLA"   or
  t == "TM"    or t == "HMC"   or t == "RACE"   or
  t == "APTV"  or t == "BWA"   or t == "LEA"    or
  t == "ALV"   or t == "GNTX"  or t == "VC"     or
  t == "PSNY"  or t == "VFS"

// ── SOCIAL / INTERNET ─────────────────────────
isSocial =
  t == "SNAP"  or t == "PINS"  or t == "RDDT"   or
  t == "MTCH"  or t == "BMBL"  or t == "SPOT"   or
  t == "NFLX"  or t == "DIS"   or t == "ROKU"   or
  t == "TTD"   or t == "RBLX"  or t == "U"      or
  t == "AMC"   or t == "BB"    or
  t == "TLRY"  or t == "CHPT"  or t == "DJT"    or
  t == "CLOV"  or t == "SPCE"  or t == "WKHS"   or
  t == "FUBO"  or t == "WISH"  or t == "SKLZ"   or
  t == "LAZR"  or t == "OPEN"  or t == "DNA"    or
  t == "BKNG"  or t == "EXPE"  or t == "ABNB"   or
  t == "MAR"   or t == "HLT"   or t == "H"      or
  t == "MSGS"  or t == "SPHR"  or t == "NXST"   or t == "MCW"   or t == "LRN"    or
  t == "UTI"   or t == "LINC"  or t == "VAC"    or
  t == "ECPG"  or t == "TPL"   or t == "LLYVA"  or
  t == "LLYVK" or t == "NYT"   or t == "OMC"    or
  t == "SBGI"  or t == "SGHC"  or t == "TRVI"   or
  t == "APEI"  or t == "EZPW"  or t == "WBI"    or
  t == "THR"   or t == "KEN"   or t == "PTON"   or
  t == "FBYD"  or t == "KODK"

// ── CHINA ─────────────────────────────────────
isChina =
  t == "BABA"  or t == "JD"    or t == "PDD"    or
  t == "BIDU"  or t == "NTES"  or t == "TCEHY"  or
  t == "TME"   or t == "BILI"  or t == "KWEB"   or
  t == "FXI"   or t == "MCHI"  or t == "XPEV"   or
  t == "NIO"   or t == "LI"    or t == "YY"     or
  t == "MAAS"

// ── RARE EARTH / CRITICAL MINERALS ───────────
isRareEarth =
  t == "USAR"  or t == "MP"    or t == "TMRC"   or
  t == "REEMF" or t == "LYC"   or t == "REMX"   or
  t == "CRML"  or t == "UAMY"

// ── COPPER ────────────────────────────────────
isCopper =
  t == "FCX"   or t == "SCCO"  or t == "HBM"    or
  t == "TGB"   or t == "NEXA"  or t == "ERO"    or
  t == "COPX"  or t == "CPER"

// ── ALUMINIUM ─────────────────────────────────
isAluminium =
  t == "AA"    or t == "CENX"  or t == "CSTM"   or
  t == "KALU"  or t == "ACH"

// ── STEEL ─────────────────────────────────────
isSteel =
  t == "NUE"   or t == "STLD"  or t == "MT"     or
  t == "CRS"   or t == "ATI"   or t == "TS"     or
  t == "RS"    or t == "CMC"   or t == "X"      or
  t == "CLF"   or t == "ZEUS"  or t == "TREC"

// ── SECTOR ETFs ───────────────────────────────
isETFTech     = t == "XLK"
isETFHealth   = t == "XLV"
isETFComm     = t == "XLC"
isETFFin      = t == "XLF"
isETFDisc     = t == "XLY"
isETFInd      = t == "XLI"
isETFStaples  = t == "XLP"
isETFEnergy   = t == "XLE"
isETFUtil     = t == "XLU"
isETFRE       = t == "XLRE"
isETFMat      = t == "XLB"
isETFSemis    = t == "SMH"
isETFSoftware = t == "IGV"
isETFGold     = t == "GDX"  or t == "GDXJ"
isETFBiotech  = t == "XBI"
isETFHome     = t == "XHB"
isETFRegBank  = t == "KRE"
isETFOilSvc   = t == "OIH"

// ──────────────────────────────────────────────
// RESOLVE THEME (first match wins)
// ──────────────────────────────────────────────
theme =
  // ETFs first
  isETFTech     ? "Technology"          :
  isETFHealth   ? "Health Care"         :
  isETFComm     ? "Comm Services"       :
  isETFFin      ? "Financials"          :
  isETFDisc     ? "Discretionary"       :
  isETFInd      ? "Industrials"         :
  isETFStaples  ? "Staples"             :
  isETFEnergy   ? "Energy"              :
  isETFUtil     ? "Utilities"           :
  isETFRE       ? "Real Estate"         :
  isETFMat      ? "Materials"           :
  isETFSemis    ? "Semiconductors"      :
  isETFSoftware ? "Software"            :
  isETFGold     ? "Gold Miners"         :
  isETFBiotech  ? "Biotech"             :
  isETFHome     ? "Homebuilders"        :
  isETFRegBank  ? "Regional Banks"      :
  isETFOilSvc   ? "Oil Services"        :
  // Stock themes
  isCyber       ? "Cybersecurity"      :
  isSemis       ? "Semiconductors"     :
  isMemory      ? "Memory"             :
  isPhotonics   ? "Photonics / Optics" :
  isDataCenters ? "Data Centers"       :
  isNetworking  ? "Networking / Fiber" :
  isUranium     ? "Uranium / Nuclear"  :
  isNuclearEnergy ? "Nuclear Energy"   :
  isPower       ? "Power / Energy"     :
  isLithium     ? "Lithium / Battery"  :
  isSpace       ? "Space"              :
  isDrones      ? "Drones"             :
  isQuantum     ? "Quantum Computing"  :
  isBigTech     ? "Big Tech"           :
  isAI          ? "AI / Cloud"         :
  isSoftware    ? "Software"           :
  isFintech     ? "Fintech"            :
  isApparel     ? "Apparel"            :
  isEcommerce   ? "E-Commerce"         :
  isBiotech     ? "Biotechnology"      :
  isBanks       ? "Banks"              :
  isInsurance   ? "Insurance"          :
  isRealEstate  ? "Real Estate"        :
  isUtilities   ? "Utilities"          :
  isTransports  ? "Transports"         :
  isShipping    ? "Shipping / Tankers" :
  isBitcoin     ? "Bitcoin / Crypto"   :
  isGold        ? "Gold / Miners"      :
  isSilver      ? "Silver / Miners"    :
  isPharma      ? "Pharma"             :
  isHealthIns   ? "Health Insurance"   :
  isHealthCare  ? "Healthcare"         :
  isMedical     ? "Medical Devices"    :
  isOilGas      ? "Oil & Gas"          :
  isHomeBuild   ? "Home Construction"  :
  isMaterials   ? "Materials"          :
  isIndustrials ? "Industrials"        :
  isAerospace   ? "Aerospace & Defense":
  isRetail      ? "Retail"             :
  isRestaurants ? "Restaurants"        :
  isCasinos     ? "Casinos / Gaming"   :
  isAirlines    ? "Airlines"           :
  isCruise      ? "Cruise Lines"       :
  isTelecom     ? "Telecom"            :
  isStaples     ? "Consumer Staples"   :
  isAutos       ? "Autos"              :
  isSocial      ? "Social / Internet"  :
  isChina       ? "China"              :
  isRareEarth   ? "Rare Earth"         :
  isCopper      ? "Copper"             :
  isAluminium   ? "Aluminium"          :
  isSteel       ? "Steel"              :
  "—"

// ── THEME COLOR ───────────────────────────────
themeColor =
  // ETF colors
  isETFTech     ? color.new(#448aff, 0)  :
  isETFHealth   ? color.new(#ea80fc, 0)  :
  isETFComm     ? color.new(#d500f9, 0)  :
  isETFFin      ? color.new(#ffd740, 0)  :
  isETFDisc     ? color.new(#ff80ab, 0)  :
  isETFInd      ? color.new(#82b1ff, 0)  :
  isETFStaples  ? color.new(#f4ff81, 0)  :
  isETFEnergy   ? color.new(#ff5252, 0)  :
  isETFUtil     ? color.new(#69f0ae, 0)  :
  isETFRE       ? color.new(#ff6e40, 0)  :
  isETFMat      ? color.new(#b2ff59, 0)  :
  isETFSemis    ? color.new(#ffab00, 0)  :
  isETFSoftware ? color.new(#448aff, 0)  :
  isETFGold     ? color.new(#ffd700, 0)  :
  isETFBiotech  ? color.new(#69f0ae, 0)  :
  isETFHome     ? color.new(#b2ff59, 0)  :
  isETFRegBank  ? color.new(#ffd740, 0)  :
  isETFOilSvc   ? color.new(#ff5252, 0)  :
  // Stock themes
  isCyber       ? color.new(#00e5ff, 0)  :
  isSemis       ? color.new(#ffab00, 0)  :
  isMemory      ? color.new(#ffc107, 0)  :
  isPhotonics   ? color.new(#e040fb, 0)  :
  isDataCenters ? color.new(#18ffff, 0)  :
  isNetworking  ? color.new(#00bfa5, 0)  :
  isUranium     ? color.new(#76ff03, 0)  :
  isNuclearEnergy ? color.new(#00e676, 0) :
  isPower       ? color.new(#ff6d00, 0)  :
  isLithium     ? color.new(#39ff14, 0)  :
  isSpace       ? color.new(#7c4dff, 0)  :
  isDrones      ? color.new(#64ffda, 0)  :
  isQuantum     ? color.new(#b39ddb, 0)  :
  isBigTech     ? color.new(#e0e0e0, 0)  :
  isAI          ? color.new(#d500f9, 0)  :
  isSoftware    ? color.new(#448aff, 0)  :
  isFintech     ? color.new(#00e5ff, 0)  :
  isApparel     ? color.new(#f48fb1, 0)  :
  isEcommerce   ? color.new(#ffab40, 0)  :
  isBiotech     ? color.new(#69f0ae, 0)  :
  isBanks       ? color.new(#ffd740, 0)  :
  isInsurance   ? color.new(#ffe082, 0)  :
  isRealEstate  ? color.new(#ff6e40, 0)  :
  isUtilities   ? color.new(#69f0ae, 0)  :
  isTransports  ? color.new(#40c4ff, 0)  :
  isShipping    ? color.new(#4fc3f7, 0)  :
  isBitcoin     ? color.new(#ff9100, 0)  :
  isGold        ? color.new(#ffd700, 0)  :
  isSilver      ? color.new(#c0c0c0, 0)  :
  isPharma      ? color.new(#ea80fc, 0)  :
  isHealthIns   ? color.new(#ce93d8, 0)  :
  isHealthCare  ? color.new(#f48fb1, 0)  :
  isMedical     ? color.new(#a7ffeb, 0)  :
  isOilGas      ? color.new(#ff5252, 0)  :
  isHomeBuild   ? color.new(#b2ff59, 0)  :
  isMaterials   ? color.new(#a5d6a7, 0)  :
  isIndustrials ? color.new(#82b1ff, 0)  :
  isAerospace   ? color.new(#b388ff, 0)  :
  isRetail      ? color.new(#ff80ab, 0)  :
  isRestaurants ? color.new(#ffcc80, 0)  :
  isCasinos     ? color.new(#ffe57f, 0)  :
  isAirlines    ? color.new(#80d8ff, 0)  :
  isCruise      ? color.new(#26c6da, 0)  :
  isTelecom     ? color.new(#ccff90, 0)  :
  isStaples     ? color.new(#f4ff81, 0)  :
  isAutos       ? color.new(#ff8a80, 0)  :
  isSocial      ? color.new(#ce93d8, 0)  :
  isChina       ? color.new(#ef5350, 0)  :
  isRareEarth   ? color.new(#8d6e63, 0)  :
  isCopper      ? color.new(#ff7043, 0)  :
  isAluminium   ? color.new(#b0bec5, 0)  :
  isSteel       ? color.new(#90a4ae, 0)  :
  color.new(color.gray, 0)

// ──────────────────────────────────────────────
// TABLE DISPLAY (top-right, no borders, no bg)
// ──────────────────────────────────────────────
var tbl = table.new(position.top_right, 1, 2,
  bgcolor      = color.new(color.black, 100),
  border_color = color.new(color.black, 100),
  border_width = 0,
  frame_color  = color.new(color.black, 100),
  frame_width  = 0)

fSize = fontSize == "tiny" ? size.tiny : fontSize == "small" ? size.small : fontSize == "large" ? size.large : size.normal

// Detect RTH vs ETH (only for stocks/futures, not crypto/forex)
hasSession = syminfo.type == "stock" or syminfo.type == "futures" or syminfo.type == "fund" or syminfo.type == "dr"
sessionType = not hasSession ? "" : syminfo.session == session.extended ? "(ETH) " : "(RTH) "

if barstate.islast
    row = 0

    if showTheme
        table.cell(tbl, 0, row, theme,
          text_color  = themeColor,
          text_size   = fSize,
          text_halign = text.align_right,
          bgcolor     = color.new(color.black, 100))
        row := row + 1

    if showADR
        table.cell(tbl, 0, row, sessionType + "ADR " + str.tostring(adrPct, "#.##") + "%",
          text_color  = color.new(color.gray, 20),
          text_size   = fSize,
          text_halign = text.align_right,
          bgcolor     = color.new(color.black, 100))
````
