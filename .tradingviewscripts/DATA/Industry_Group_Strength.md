<!-- tradingview-pine-id: PUB;98928640eaf0453389ac2a7339e9f51f -->
<!-- tradingviewscripts-format: 1 -->
# Industry Group Strength

Source: https://www.tradingview.com/script/5NsvcOVp-Industry-Group-Strength/

## Description

The Industry Group Strength indicator is designed to help traders identify the best-performing stocks within specific industry groups. The movement of individual stocks is often closely tied to the overall performance of their industry. By focusing on industry groups, this indicator allows you to find the top-performing stocks within an industry.

Thanks to a recent Pine Script update, an indicator like this is now possible. Special thanks to @PineCoders for introducing the dynamic requests feature.

How this indicator works:
The indicator contains predefined lists of stocks for each industry group. To be included in these lists, stocks must meet the following basic filters:

[*]Market capitalization over 2B
[*]Price greater than $10
[*]Primary listing status

Once the relevant stocks are filtered, the indicator automatically recognizes the industry group of the current stock displayed on the chart. It then retrieves and displays data for that entire industry group.

Data Points Available:
The user can choose between three different data points to rank and compare stocks:

[*]YTD (Year-To-Date) Return: Measures how much a stock has gained or lost since the start of the year.
[*]RS Rating: A relative strength rating for a user-selected lookback period (explained below).
[*]% Return: The percentage return over a user-selected lookback period.

Stock Ranking:
Stocks are ranked based on their performance within their respective industry groups, allowing users to easily identify which stocks are leading or lagging behind others in the same sector.

Visualization:
The indicator presents stocks in a table format, with performance metrics displayed both as text labels and color-coded lines. The color gradient represents the percentile rank, making it visually clear which stocks are outperforming or underperforming within their industry group.

Relative Strength (RS):
Relative Strength (RS) measures a stock’s performance relative to a benchmark, typically the S&P 500 (the default setting). It is calculated by dividing the closing price of the stock by the closing price of the S&P 500.

If the stock rises while the S&P 500 falls, or if the stock rises more sharply than the S&P 500, the RS value increases. Conversely, if the stock falls while the S&P 500 rises, the RS value decreases. This indicator normalizes the RS value into a range from 1 to 99, allowing for easier comparison across different stocks, regardless of their raw performance. This normalized RS value helps traders quickly assess how a stock is performing relative to others.

---

## Source Code

````pine
// This Pine Script™ code is subject to the terms of the Mozilla Public License 2.0 at https://mozilla.org/MPL/2.0/
// © Amphibiantrading

//@version=5
indicator('Industry Group Strength', overlay = false, dynamic_requests = true, max_labels_count = 80)

if timeframe.isintraday
    runtime.error('Switch to Daily or Weekly Chart')

//----------settings----------//
select  = input.string('YTD', 'Data', ['YTD', 'RS Rating', '% Return'], display = display.none)
len     = input.int(90, 'Lookback Period', minval = 1, tooltip = 'This is the lookback period for % return & rs rating', display = display.none)
showMax = input.int(20, 'Number of Stocks to Show', minval = 1, maxval = 40, display = display.none)-1
theme   = input.string('Dark', 'Color Mode', ['Dark', 'Light'], display = display.none)
rsIndex = input.symbol('SPX', 'RS Symbol to Compare', display = display.none)
compact = input.bool(false, 'Compact Mode', display = display.none)
results = input.bool(true, 'Show Values in Compact Mode', display = display.none)

//----------industry groups----------//
type industry 
    string name
    string [] symbols

var indArr = array.from(
     industry.new('Advertising/Marketing Services', array.from('OMC', 'IPG', 'DJT')),
     industry.new('Aerospace & Defense', array.from('RTX', 'LMT', 'HON', 'BA', 'GD', 'NOC', 'TDG', 'LHX', 'HWM', 'AXON', 'HEI', 'LDOS', 'TDY', 'TXT', 'FTAI', 'CW', 'BWXT', 'HII', 'CR', 'DRS', 'LOAR', 'AVAV', 'HXL', 'SPR', 'KTOS', 'MIR', 'OSIS', 'AIR', 'MRCY')),
     industry.new('Agricultural Commodities/Milling', array.from('ADM', 'BG', 'PPC', 'CALM', 'SEB')),
     industry.new('Air Freight/Couriers', array.from('UPS', 'FDX', 'DASH', 'EXPD', 'CHRW', 'CART', 'GXO', 'HUBG')),
     industry.new('Airlines', array.from('DAL', 'UAL', 'LUV', 'AAL', 'ALK', 'CPA', 'SKYW')),
     industry.new('Alternative Power Generation', array.from('BIP', 'TLN', 'CWEN', 'AY', 'NEP')),
     industry.new('Aluminum', array.from('AA')),
     industry.new('Apparel/Footwear', array.from('NKE', 'DECK', 'ONON', 'RL', 'SKX', 'BIRK', 'CROX', 'LEVI', 'VFC', 'GIL', 'PVH', 'COLM', 'KTB', 'SHOO')),
     industry.new('Apparel/Footwear Retail', array.from('TJX', 'ROST', 'BURL', 'TPR', 'GAP', 'ANF', 'BBWI', 'CPRI', 'BOOT', 'AEO', 'URBN', 'CRI', 'BKE', 'FL')),
     industry.new('Auto Parts: OEM', array.from('ITW', 'CMI', 'APTV', 'ITT', 'DCI', 'ALSN', 'ALV', 'GNTX', 'LEA', 'BC', 'ATMU', 'VC')),
     industry.new('Automotive Aftermarket', array.from('LKQ', 'DORM')),
     industry.new('Beverages: Alcoholic', array.from('STZ', 'TAP', 'SAM')),
     industry.new('Beverages: Non-Alcoholic', array.from('KO', 'MNST', 'CCEP', 'COKE', 'BRBR', 'CELH', 'FIZZ')),
     industry.new('Biotechnology', array.from('AMGN', 'GILD', 'MRNA', 'ILMN', 'SMMT', 'PCVX', 'BMRN', 'TECH', 'NUVL', 'ELAN', 'HALO', 'BPMC', 'RNA', 'KRYS', 'ADMA', 'BBIO', 'IMVT', 'ACLX', 'AXSM', 'CRSP', 'DNLI', 'ALVO', 'MRUS', 'APGE', 'DYN', 'RYTM', 'KYMR', 'EWTX', 'PTGX', 'TWST', 'SWTX', 'TXG', 'CGON', 'JANX', 'ARWR', 'VERA', 'NVAX', 'CLDX')),
     industry.new('Broadcasting', array.from('FOX', 'SIRI', 'PARA', 'NXST', 'TGNA')),
     industry.new('Building Products', array.from('OTIS', 'CSL', 'WSO', 'MAS', 'AOS', 'ALLE', 'FBIN', 'MHK', 'SSD', 'SPXC', 'AZEK', 'GFF', 'TGLS')),
     industry.new('Cable/Satellite TV', array.from('CMCSA', 'CHTR')),
     industry.new('Casinos/Gaming', array.from('FLUT', 'LVS', 'MGM', 'WYNN', 'CZR', 'LNW', 'BYD', 'IGT', 'RSI')),
     industry.new('Chemicals: Agricultural', array.from('CTVA', 'CF', 'MOS', 'FMC', 'SMG')),
     industry.new('Chemicals: Major Diversified', array.from('DD', 'ESI', 'AVNT', 'HUN', 'IOSP')),
     industry.new('Chemicals: Specialty', array.from('LIN', 'ECL', 'APD', 'DOW', 'LYB', 'WLK', 'AVTR', 'CE', 'EMN', 'ALB', 'CHX', 'CBT', 'NEU', 'CC', 'KWR', 'HWKN', 'MTX', 'TROX')),
     industry.new('Coal', array.from('TECK', 'HCC', 'BTU', 'ARLP', 'CEIX', 'AMR', 'ARCH')),
     industry.new('Commercial Printing/Forms', array.from('WMG')),
     industry.new('Computer Peripherals', array.from('ANET', 'NTAP', 'WDC', 'STX', 'PSTG')),
     industry.new('Computer Processing Hardware', array.from('DELL', 'HPQ', 'SMCI', 'HPE', 'ZBRA', 'NATL')),
     industry.new('Containers/Packaging', array.from('SW', 'BALL', 'PKG', 'AVY', 'AMCR', 'OC', 'CCK', 'ATR', 'GPK', 'SLGN', 'SON', 'SEE', 'GEF', 'PTVE', 'OI')),
     industry.new('Contract Drilling', array.from('SLB', 'BKR', 'NE', 'VAL', 'HP', 'SDRL')),
     industry.new('Construction Materials', array.from('CRH', 'MLM', 'VMC', 'EXP', 'SUM', 'KNF', 'USLM')),
     industry.new('Data Processing Services', array.from('PAYX', 'MSCI', 'VRSK', 'ZS', 'TYL', 'GDDY', 'J', 'FDS', 'AKAM', 'DBX', 'EXLS', 'KD', 'MARA', 'EEFT', 'DXC', 'CORZ', 'AVPT')),
     industry.new('Department Stores', array.from('DDS', 'OLLI', 'M', 'JWN', 'KSS')),
     industry.new('Discount Stores', array.from('DG', 'DLTR', 'FIVE')),
     industry.new('Drugstore Chains', array.from('CVS')),
     industry.new('Electric Utilities', array.from('NEE', 'SO', 'CEG', 'DUK', 'AEP', 'SRE', 'D', 'VST', 'PEG', 'PCG', 'EXC', 'XEL', 'ED', 'EIX', 'WEC', 'ETR', 'DTE', 'FE', 'PPL', 'AEE', 'ES', 'CMS', 'NRG', 'CNP', 'LNT', 'AGR', 'EVRG', 'AES', 'PNW', 'OGE', 'BEPC', 'IDA', 'POR', 'ORA', 'BKH', 'TXNM', 'ALE', 'NWE', 'MGEE')),
     industry.new('Electrical Products', array.from('ETN', 'GEV', 'AME', 'ROK', 'HUBB', 'RRX', 'GNRC', 'AYI', 'BDC', 'LITE', 'ENS', 'FLNC', 'SMR', 'ATKR', 'POWL', 'BE', 'ENVX')),
     industry.new('Electronic Components', array.from('APH', 'GLW', 'NVT', 'CAMT')),
     industry.new('Electronic Equipment/Instruments', array.from('KLAC', 'PH', 'EMR', 'KEYS', 'FTV', 'COHR', 'ONTO', 'CGNX', 'NOVT', 'NVMI', 'ST', 'NXT', 'ITRI', 'ESE', 'SXI', 'MTRN')),
     industry.new('Electronic Production Equipment', array.from('VRT', 'TER', 'FLEX', 'OLED', 'LFUS', 'AEIS', 'PLXS', 'VSH')),
     industry.new('Electronics Distributors', array.from('SNX', 'ARW', 'AVT', 'REZI')),
     industry.new('Electronics/Appliance Stores', array.from('BBY', 'GME')),
     industry.new('Electronics/Appliances', array.from('SN', 'ROKU', 'WHR', 'SPB')),
     industry.new('Engineering & Construction', array.from('PWR', 'EME', 'FIX', 'ACM', 'TTEK', 'BLD', 'MTZ', 'APG', 'FLR', 'IBP', 'EXPO', 'DY', 'STRL', 'IESC', 'ROAD', 'GVA', 'PRIM')),
     industry.new('Environmental Services', array.from('WM', 'RSG', 'CLH', 'CWST', 'SRCL')),
     industry.new('Finance/Rental/Leasing', array.from('AXP', 'BLK', 'URI', 'DFS', 'RKT', 'SYF', 'AER', 'UHAL', 'AFRM', 'WSC', 'R', 'COOP', 'OBDC', 'OMF', 'PFSI', 'CACC', 'FCFS', 'SLM', 'AL', 'HRI', 'NNI', 'WD', 'CAR', 'MGRC', 'ENVA', 'PRG')),
     industry.new('Financial Conglomerates', array.from('AACT', 'AAM', 'BCSF', 'BFAC', 'EQV', 'HYAC', 'LOCL', 'MNTN', 'MSDL', 'NCDL', 'OKLO', 'PHYT', 'PSBD', 'RCFA', 'RMI', 'RRAC', 'SBXC', 'SBXD', 'SEDA', 'WEL')),
     industry.new('Financial Publishing/Services', array.from('SPGI', 'MCO', 'EFX', 'TRU')),
     industry.new('Food Distributors', array.from('SYY', 'USFD')),
     industry.new('Food Retail', array.from('KR', 'SFM', 'ACI', 'TBBB')),
     industry.new('Food: Major Diversified', array.from('KHC', 'GIS', 'CAG', 'SMPL')),
     industry.new('Food: Meat/Fish/Dairy', array.from('TSN', 'HRL')),
     industry.new('Food: Specialty/Candy', array.from('PEP', 'MDLZ', 'KDP', 'HSY', 'K', 'IFF', 'MKC', 'CPB', 'SJM', 'LW', 'INGR', 'FRPT', 'POST', 'DAR', 'BCPC', 'LANC', 'BROS', 'FLO', 'ASH', 'JJSF', 'SXT', 'NOMD', 'UTZ', 'TR', 'THS')),
     industry.new('Forest Products', array.from('UFPI', 'LPX', 'TREX')),
     industry.new('Gas Distributors', array.from('TRGP', 'CQP', 'ATO', 'NI', 'MDU', 'BIPC', 'SWX', 'NJR', 'OGS', 'SR', 'CPK', 'EE')),
     industry.new('Home Furnishings', array.from('TPX', 'MBC')),
     industry.new('Home Improvement Chains', array.from('HD', 'LOW', 'BLDR', 'FND')),
     industry.new('Homebuilding', array.from('DHI', 'LEN', 'NVR', 'PHM', 'TOL', 'MTH', 'TMHC', 'KBH', 'SKY', 'MHO', 'TPH', 'FTDR', 'GRBK', 'CVCO', 'PATK', 'DFH', 'CCS', 'LGIH')),
     industry.new('Hospital/Nursing Management', array.from('HCA', 'THC', 'UHS', 'CHE', 'PACS', 'SEM', 'SGRY', 'ARDT')),
     industry.new('Hotels/Resorts/Cruise lines', array.from('MAR', 'HLT', 'RCL', 'CCL', 'VIK', 'H', 'NCLH', 'MTN', 'WH', 'CHH', 'RRR', 'TNL')),
     industry.new('Household/Personal Care', array.from('PG', 'CL', 'KMB', 'KVUE', 'EL', 'CHD', 'CLX', 'REYN', 'ELF', 'IPAR', 'ENR')),
     industry.new('Industrial Conglomerates', array.from('MMM', 'AGS', 'HI', 'RLX')),
     industry.new('Industrial Machinery', array.from('GE', 'AMAT', 'LRCX', 'TT', 'CARR', 'JCI', 'IR', 'XYL', 'DOV', 'LII', 'ENTG', 'PNR', 'IEX', 'GGG', 'NDSN', 'JBL', 'LECO', 'WWD', 'AAON', 'MKSI', 'FLS', 'MIDD', 'MOD', 'WTS', 'BMI', 'ZWS', 'ESAB', 'TKR', 'GTLS', 'GTES', 'FELE', 'KAI', 'MWA', 'NPO', 'ACLS', 'JBT', 'CXT', 'OII', 'SYM')),
     industry.new('Industrial Specialties', array.from('SHW', 'PPG', 'RPM', 'AXTA', 'CSWI', 'OLN', 'FUL', 'WDFC', 'AZZ', 'UFPT')),
     industry.new('Information Technology Services', array.from('ACN', 'SHOP', 'NU', 'WDAY', 'FTNT', 'SQ', 'CTSH', 'CDW', 'NET', 'VLTO', 'BR', 'SSNC', 'GWRE', 'BSY', 'Z', 'JNPR', 'CACI', 'PSN', 'EPAM', 'DOX', 'KBR', 'WIX', 'APPF', 'GLOB', 'NSIT', 'SAIC', 'SQSP', 'PEGA', 'RBRK', 'CRDO', 'QTWO', 'BOX', 'WK', 'ASGN', 'RPD')),
     industry.new('Insurance Brokers/Services', array.from('MMC', 'AON', 'AJG', 'WTW', 'BRO', 'RYAN', 'CRVL', 'GSHD')),
     industry.new('Integrated Oil', array.from('XOM', 'CVX', 'OXY', 'HES', 'DVN', 'EQT', 'EXE', 'CTRA', 'MRO', 'PR', 'OVV', 'APA', 'VNOM', 'CHRD', 'HESM', 'MTDR', 'NFG', 'CIVI', 'CNX', 'CRC', 'CRGY')),
     industry.new('Internet Retail', array.from('AMZN', 'MELI', 'CPNG', 'LULU', 'EBAY', 'CHWY', 'GLBE', 'ETSY', 'ACVA')),
     industry.new('Internet Software/Services', array.from('GOOGL', 'META', 'NFLX', 'SPOT', 'IT', 'MSTR', 'CSGP', 'PINS', 'CHKP', 'VRSN', 'RDDT', 'MMYT', 'MTCH', 'IAC', 'UPST', 'BRZE', 'CARG', 'YELP', 'VZIO', 'GRND')),
     industry.new('Investment Banks/Brokers', array.from('GS', 'SCHW', 'ICE', 'CME', 'IBKR', 'BK', 'AMP', 'COIN', 'NDAQ', 'TW', 'STT', 'CBOE', 'HOOD', 'LPLA', 'JEF', 'HLI', 'MKTX', 'XP', 'EVR', 'FRHC', 'PJT', 'MC', 'PIPR', 'VIRT', 'LAZ', 'SNEX')),
     industry.new('Investment Managers', array.from('BX', 'MS', 'KKR', 'BN', 'APO', 'ARES', 'OWL', 'RJF', 'TROW', 'TPG', 'PFG', 'BAM', 'NTRS', 'CRBG', 'CG', 'MORN', 'ARCC', 'BEN', 'SF', 'HLNE', 'SEIC', 'IVZ', 'HQY', 'STEP', 'JHG', 'FSK', 'AMG', 'CNS', 'MAIN', 'GBDC', 'AB', 'VCTR', 'APAM', 'HTGC', 'IFS', 'FHI', 'GCMG')),
     industry.new('Investment Trusts/Mutual Funds', array.from('TPL', 'BXSL', 'STR', 'BSM')),
     industry.new('Life/Health Insurance', array.from('PRU', 'EQH', 'PRI', 'VOYA', 'JXN', 'LNC', 'BHF', 'PRVA')),
     industry.new('Major Banks', array.from('JPM', 'BAC', 'WFC', 'C', 'PNC', 'UBS', 'COF', 'HBAN', 'RF', 'CFG', 'KEY', 'BAP', 'CMA', 'ZION', 'BOKF', 'ONB', 'CADE', 'FFIN', 'UMBF', 'FNB', 'AX', 'TCBI', 'ASB', 'FULT', 'CBU', 'WAFD', 'SFNC', 'PRK', 'BKU', 'FBK', 'FRME', 'NBTB')),
     industry.new('Major Telecommunications', array.from('FYBR', 'CCOI')),
     industry.new('Managed Health Care', array.from('UNH', 'ELV', 'CI', 'CNC', 'HUM', 'MOH', 'OSCR', 'ALHC')),
     industry.new('Marine Shipping', array.from('KEX', 'FRO', 'MATX', 'GLNG', 'STNG', 'TDW', 'INSW', 'SBLK', 'GOGL', 'ZIM', 'TNK')),
     industry.new('Media Conglomerates', array.from('EDR')),
     industry.new('Medical Distributors', array.from('MCK', 'COR', 'CAH', 'HSIC')),
     industry.new('Medical Specialties', array.from('TMO', 'ABT', 'DHR', 'ISRG', 'SYK', 'BSX', 'MDT', 'BDX', 'A', 'IDXX', 'GEHC', 'EW', 'RMD', 'MTD', 'DXCM', 'STE', 'WST', 'COO', 'ZBH', 'WAT', 'HOLX', 'BAX', 'ALGN', 'PODD', 'NTRA', 'RVTY', 'EXAS', 'TFX', 'BRKR', 'QGEN', 'BIO', 'GMEN', 'PEN', 'LNTH', 'MASI', 'GKOS', 'BLCO', 'INSP', 'MMSI')),
     industry.new('Medical/Nursing Services', array.from('DVA', 'SOLV', 'EHC', 'ENSG', 'ACHC', 'RDNT', 'OPCH', 'HIMS', 'AMED', 'GH', 'BTSG', 'CON', 'AZTA', 'ADUS')),
     industry.new('Metal Fabrication', array.from('RBC', 'MLI', 'VMI', 'ROCk')),
     industry.new('Miscellaneous Commercial Services', array.from('V', 'MA', 'PYPL', 'GPN', 'ICLR', 'CPAY', 'BAH', 'MEDP', 'CRL', 'WEX', 'FOUR', 'FCN', 'BFAM', 'G', 'RCM', 'QXO', 'MMS', 'BCO', 'TNET', 'LOPE', 'CNXC', 'ABM', 'CBZ', 'NSP', 'ICFI', 'EVH', 'FA', 'PAY', 'RELY', 'LAUR', 'CSTM')),
     industry.new('Miscellaneous Manufacturing', array.from('WMS', 'BERY', 'AWI', 'BRC', 'YETI', 'LCII')),
     industry.new('Motor Vehicles', array.from('TSLA', 'GM', 'F', 'RIVN', 'OSK', 'HOG')),
     industry.new('Movies/Entertainment', array.from('DIS', 'LYV', 'FWONA', 'TKO', 'DKNG', 'CHDN', 'MSGS', 'FUN', 'CNK', 'PRKS', 'PENN', 'MANU', 'BATRA')),
     industry.new('Multi-Line Insurance', array.from('PGR', 'AFL', 'MET', 'ACGL', 'HIG', 'CINF', 'RGA', 'CNA', 'UNM', 'KNSL', 'GL', 'RLI', 'AXS', 'BWIN', 'ACT', 'FG', 'ESGR', 'WTM', 'CNO')),
     industry.new('Office Equipment/Supplies', array.from('HNI')),
     industry.new('Oil & Gas Pipelines', array.from('EPD', 'WMB', 'ET', 'OKE', 'KMI', 'MPLX', 'LNG', 'WES', 'PAA', 'DTM', 'KNTK', 'AM', 'ENLC', 'SOBO', 'PAGP', 'DKL')),
     industry.new('Oil & Gas Production', array.from('COP', 'EOG', 'FANG', 'AR', 'RRC', 'MUR', 'MGY', 'SM', 'NOG', 'CRK', 'GPOR', 'XPRO')),
     industry.new('Oil Refining/Marketing', array.from('PSX', 'MPC', 'VLO', 'DINO', 'IEP', 'PBF', 'CVI')),
     industry.new('Oilfield Services/Equipment', array.from('BATS:HAL', 'FIT', 'WFRD', 'NOV', 'WHD', 'AROC', 'LBRT', 'USAC', 'KGS', 'AESI')),
     industry.new('Other Consumer Services', array.from('BKNG', 'ABNB', 'CTAS', 'ROL', 'EXPE', 'SCI', 'HRB', 'PLNT', 'LTH', 'VVV', 'GHC', 'UNF', 'LRN', 'ATGE', 'VAC', 'DRVN', 'STRA', 'TRIP')),
     industry.new('Other Consumer Specialties', array.from('MSA')),
     industry.new('Other Metals/Minerals', array.from('SCCO', 'FCX', 'CCJ', 'CRS', 'ATI', 'MP')),
     industry.new('Other Transportation', array.from('UBER', 'PFGC', 'SARO', 'VNT', 'VRRM', 'CAAP')),
     industry.new('Packaged Software', array.from('MSFT', 'ORCL', 'CRM', 'ADBE', 'IBM', 'NOW', 'INTU', 'ADP', 'PANW', 'PLTR', 'SNPS', 'CDNS', 'CRWD', 'ADSK', 'ROP', 'TTD', 'FICO', 'APP', 'FIS', 'TEAM', 'DDOG', 'SNOW', 'EA', 'VEEV', 'ANSS', 'HUBS', 'TTWO', 'IOT', 'RBLX', 'PTC', 'ZM', 'MDB', 'SNAP', 'MANH', 'TOST', 'DT', 'TRMB', 'AZPN', 'MNDY')),
     industry.new('Personnel Services', array.from('RHI', 'KFY', 'MAN')),
     industry.new('Pharmaceuticals: Major', array.from('LLY', 'JNJ', 'ABBV', 'MRK', 'PFE', 'VRTX', 'REGN', 'BMY', 'ZTS', 'ALNY', 'BIIB', 'RPRX', 'UTHR', 'VTRS', 'INCY', 'INSM', 'SRPT', 'NBIX', 'CTLT', 'ROIV', 'ITCI', 'RGEN', 'VKTX', 'EXEL', 'JAZZ', 'CYTK', 'IONS', 'BHVN', 'RARE', 'CORT', 'MDGL', 'OGN', 'ALKS', 'CRNX', 'TGTX', 'PHB', 'PRGO', 'APLS')),
     industry.new('Pharmaceuticals: Other', array.from('RVMD')),
     industry.new('Precious Metals', array.from('NEM', 'RGLD')),
     industry.new('Property/Casualty Insurance', array.from('BRK.A', 'BRK.B', 'CB', 'TRV', 'ALL', 'AIG', 'ERIE', 'WRB', 'MKL', 'L', 'EG', 'RNR', 'AFG', 'AIZ', 'MTG', 'SIGI', 'THG', 'KMPR', 'HGTY', 'MCY', 'NMIH', 'PLMR', 'SPNT')), 
     industry.new('Publishing: Books/Magazines', array.from('WLY')),
     industry.new('Publishing: Newspapers', array.from('NWS', 'NYT')),
     industry.new('Pulp & Paper', array.from('IP', 'SLVM')),
     industry.new('Railroads', array.from('UNP', 'CSX', 'NSC', 'GATX')),
     industry.new('Real Estate Development', array.from('CBRE', 'JLL', 'HHH', 'HGV', 'JOE', 'CWK', 'NMRK', 'EXPI')),
     industry.new('Real Estate Investment Trusts', array.from('HASI', 'ESBA')),
     industry.new('Recreational Products', array.from('HAS', 'AS', 'MAT', 'THO', 'PII', 'GOLF', 'HAYW', 'VSTO')),
     industry.new('Regional Banks', array.from('FI', 'TFC', 'MTB', 'FITB', 'FCNCA', 'EWBC', 'ALLY', 'WAL', 'FHN', 'CFR', 'CBSH', 'PNFP', 'SSB', 'WTFC', 'BPOP', 'PB', 'SNV', 'COLB', 'HOMB', 'GBCI', 'UBSI', 'OZK', 'HWC', 'SFBS', 'ABCB', 'WU', 'IBOC', 'EBC', 'BANF', 'UCB', 'FBP', 'AUB', 'FIBK', 'CATY', 'FHB', 'TBBK', 'BOH', 'CVBF', 'TOWN')),
     industry.new('Restaurants', array.from('MCD', 'SBUX', 'CMG', 'YUM', 'QSR', 'DRI', 'YUMC', 'CAVA', 'DPZ', 'WING', 'TXRH', 'ARMK', 'SHAK', 'SG', 'EAT', 'WEN', 'CAKE')),
     industry.new('Savings Banks', array.from('WBS', 'NYCB', 'TFSL', 'WSFS', 'PFS')),
     industry.new('Semiconductors', array.from('NVDA', 'AVGO', 'AMD', 'QCOM', 'TXN', 'ADI', 'MU', 'INTC', 'MRVL', 'NXPI', 'MPWR', 'TEL', 'MCHP', 'ON', 'GFS', 'SWKS', 'SWKS', 'QRVO', 'FN', 'ALAB', 'MTSI', 'AMKR', 'LSCC', 'CRUS', 'PI', 'TSEM', 'RMBS', 'SITM', 'ALGM', 'SLAB', 'FORM', 'POWI', 'IPGP', 'SMTC', 'DIOD', 'SYNA', 'AMBA')),
     industry.new('Services to the Health Industry', array.from('IQV', 'DGX', 'ASTH')),
     industry.new('Specialty Insurance', array.from('FNF', 'ORI', 'ESNT', 'FAF', 'RDN', 'AGO')),
     industry.new('Specialty Stores', array.from('WMT', 'COST', 'TGT', 'ORLY', 'AZO', 'CRPT', 'CVNA', 'TSCO', 'WSM', 'ULTA', 'DKS', 'CASY', 'BJ', 'KMX', 'PAG', 'MUSA', 'LAD', 'W', 'AN', 'RH', 'GPI', 'ABG', 'SIG', 'RUSHA', 'ASO', 'PSMT', 'AAP')),
     industry.new('Specialty Telecommunications', array.from('LBTYA', 'SATS', 'ASTS', 'IRDM')),
     industry.new('Steel', array.from('NUE', 'STLD', 'RS', 'X', 'CMC', 'CLF')),
     industry.new('Telecommunications Equipment', array.from('AAPL', 'CSCO', 'MSI', 'GRMN', 'UI', 'CIEN', 'CALX')),
     industry.new('Textiles', array.from('AIN')),
     industry.new('Tobacco', array.from('PM', 'MO')),
     industry.new('Tools & Hardware', array.from('SWK', 'SNA')),
     industry.new('Trucking', array.from('ODFL', 'JBHT', 'XPO', 'SAIA', 'KNX', 'LSTR', 'SNDR', 'ARCB', 'WERN')),
     industry.new('Trucks/Construction/Farm Machinery', array.from('CAT', 'DE', 'PCAR', 'WAB', 'CNH', 'TTC', 'BWA', 'AGCO', 'SITE', 'FSS', 'ACA', 'TEX', 'TRN', 'ALG')),
     industry.new('Water Utilities', array.from('AWK', 'WTRG', 'AWR', 'CWT')),
     industry.new('Wholesale Distributors', array.from('GWW', 'FAST', 'FERG', 'GPC', 'POOL', 'CNM', 'AIT', 'WCC', 'SUN', 'BECN', 'BCC', 'UGI', 'MSM', 'GMS')),
     industry.new('Wireless Telecommunications', array.from('TMUS', 'VZ', 'T', 'LBRDA', 'USM', 'TIGO', 'TDS'))
     )


//----------variables----------//
var table data  = table.new(compact ? position.top_left : position.top_center, 1, 2)
var table list  = table.new(position.top_right, showMax+1, 2)
outputArr       = array.new<float>()
indy            = 0
per             = 0
txtCol          = theme == 'Dark' ? color.white : color.black

//----------functions----------//
f_ytd_change() =>
    var float start_of_year_price = open
    float ytd_change = na
    if timeframe.change('12M')
        start_of_year_price := open
    if (not na(start_of_year_price))
        ytd_change := ((close - start_of_year_price) / start_of_year_price) * 100
    ytd_change

f_normalized_rs(indexSymbol, length) =>
    indexClose = request.security(indexSymbol, timeframe.period, close)
    RSclose = close / indexClose
    newRngMax = 99
    newRngMin = 1
    HHDataclose = ta.highest(RSclose, length)
    LLDataclose = ta.lowest(RSclose, length)
    normalizeRSclose = na(HHDataclose - LLDataclose) ? na : ((newRngMax - newRngMin) * (RSclose - LLDataclose) / (HHDataclose - LLDataclose)) + newRngMin
    nz(normalizeRSclose,0)


//----------data----------//
if barstate.islast
    data.cell(0,0, '')
    data.cell(0, 1, syminfo.industry + ' (' + select + ')', text_color = txtCol, text_size = size.large)
    for [idx,i] in indArr
        if i.name == syminfo.industry
            indy := idx
            for s in i.symbols
                if select == 'RS Rating'
                    rs = request.security(s, timeframe.period, f_normalized_rs(rsIndex, len), lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
                    outputArr.push(rs)
                if select == 'YTD'
                    ytd = request.security(s,  timeframe.period, f_ytd_change(), lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
                    outputArr.push(ytd)
                    per := 1
                if select == '% Return'
                    roc = request.security(s,  timeframe.period, ta.roc(close,len), lookahead = barmerge.lookahead_on, ignore_invalid_symbol = true)
                    outputArr.push(roc)
                    per := 1

    sorted = outputArr.sort_indices(order.descending)
    
    if outputArr.size() > 0
        space = 3
        for i = math.min(outputArr.size()-1, showMax) to 0
            ind = indArr.get(indy)
            bar_pos = bar_index - (i*space)
            si = sorted.get(i)
            rank = outputArr.percentrank(si)
            col = color.from_gradient(rank, 0, 100, color.red, color.lime)
            if not compact
                label.new(bar_pos, 0, ind.symbols.get(si), textcolor = txtCol, style = label.style_label_up, color = color.new(color.white,100))
                line.new(bar_pos, 0, bar_pos, rank, width = 8, color = col)
                label.new(bar_pos, rank, str.tostring(outputArr.get(si), '#.#') + (per == 1 ? '%' : ''), textcolor = txtCol, color = color.new(color.white,100))
            else
                list.cell(0, 0, '')
                cell = math.abs(i - (math.min(outputArr.size()-1, showMax)))
                list.cell(cell, 1, ind.symbols.get(si) + (results ? '\n' + str.tostring(outputArr.get(si), '#.#') + (per == 1 ? '%' : '') : ''), text_color = txtCol)
````
