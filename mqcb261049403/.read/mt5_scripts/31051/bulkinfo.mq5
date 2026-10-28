#property copyright           "Mokara"
#property link                "https://www.mql5.com/en/users/mokara"
#property description         "Bulk Information"
#property version             "1.0"
#property script_show_inputs  true

/*
#import "shell32.dll"
int ShellExecuteW(int hwnd, string operation, string file, string parameters, string directory, int showCmd);
#import
*/

string ACCOUNT[28], SYMBOL[98], TERMINAL[58], PROGRAM[16];

enum CP
{
   ACP = 0,
   MACCP = 2,
   OEMCP = 1,
   SYMBOL = 42,
   THREAD_ACP = 3,
   UTF7 = 65000,
   UTF8 = 65001
};

void OnStart()
{
   MqlDateTime dt;
   TimeToStruct(TimeCurrent(), dt);
   string fileName = "INFO_" + _Symbol + "_" + dt.year + dt.mon + dt.day + "_" + dt.hour + dt.min + dt.sec + ".htm";
   int fileHandle, i;
   
   i = 0;
   ACCOUNT[i++] = "Trader Name#" + AccountInfoString(ACCOUNT_NAME);
   ACCOUNT[i++] = "Server#" + AccountInfoString(ACCOUNT_SERVER);
   ACCOUNT[i++] = "Currency#" + AccountInfoString(ACCOUNT_CURRENCY);
   ACCOUNT[i++] = "Company#" + AccountInfoString(ACCOUNT_COMPANY);
   ACCOUNT[i++] = "Account ID#" + AccountInfoInteger(ACCOUNT_LOGIN);
   ACCOUNT[i++] = "Leverage#" + AccountInfoInteger(ACCOUNT_LEVERAGE);
   ACCOUNT[i++] = "Trade Allowed#" + ((AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)==1)?"true":"false");
   ACCOUNT[i++] = "Expert Allowed#" + ((AccountInfoInteger(ACCOUNT_TRADE_EXPERT)==1)?"true":"false");
   ACCOUNT[i++] = "Trade Mode#" + ((AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_DEMO)?"Demo":((AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_CONTEST)?"Contest":"Real"));
   ACCOUNT[i++] = "Balance#" + AccountInfoDouble(ACCOUNT_BALANCE);
   ACCOUNT[i++] = "Equity#" + AccountInfoDouble(ACCOUNT_EQUITY);
   ACCOUNT[i++] = "Free Margin#" + AccountInfoDouble(ACCOUNT_MARGIN_FREE);
   ACCOUNT[i++] = "Used Margin#" + AccountInfoDouble(ACCOUNT_MARGIN);
   ACCOUNT[i++] = "Used Margin (%)#" + AccountInfoDouble(ACCOUNT_MARGIN_LEVEL);
   ACCOUNT[i++] = "Reserved Margin#" + AccountInfoDouble(ACCOUNT_MARGIN_INITIAL);
   ACCOUNT[i++] = "Maintenance Margin#" + AccountInfoDouble(ACCOUNT_MARGIN_MAINTENANCE);
   ACCOUNT[i++] = "Margin Mode#" + ((AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_EXCHANGE)?"Exchange":((AccountInfoInteger(ACCOUNT_MARGIN_MODE)==ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)?"Retail Hedging":"Retail Netting"));
   ACCOUNT[i++] = "Margin Call Level (%)#" + AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL);
   ACCOUNT[i++] = "Stop Out Mode#" + ((AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_MONEY)?"Money":"Percent");
   ACCOUNT[i++] = "Margin Stopout Level (%)#" + AccountInfoDouble(ACCOUNT_MARGIN_SO_SO);
   ACCOUNT[i++] = "Profit#" + AccountInfoDouble(ACCOUNT_PROFIT);
   ACCOUNT[i++] = "Credit#" + AccountInfoDouble(ACCOUNT_CREDIT);
   ACCOUNT[i++] = "Assets#" + AccountInfoDouble(ACCOUNT_ASSETS);
   ACCOUNT[i++] = "Liabilities#" + AccountInfoDouble(ACCOUNT_LIABILITIES);
   ACCOUNT[i++] = "Blocked Commisions#" + AccountInfoDouble(ACCOUNT_COMMISSION_BLOCKED);
   ACCOUNT[i++] = "Maximum Pending Orders#" + AccountInfoInteger(ACCOUNT_LIMIT_ORDERS);
   ACCOUNT[i++] = "Currency Digits#" + AccountInfoInteger(ACCOUNT_CURRENCY_DIGITS);
   ACCOUNT[i++] = "Close Oldest First#" + ((AccountInfoInteger(ACCOUNT_FIFO_CLOSE)==1)?"true":"false");
   
   i = 0;
   int s = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_CALC_MODE);
   string calcMode = "", tradeMode = "", dealMode = "", swapMode = "", gtcMode = "";
   switch(s)
   {
      case SYMBOL_CALC_MODE_FOREX: calcMode = "Forex"; break;
      case SYMBOL_CALC_MODE_FOREX_NO_LEVERAGE: calcMode = "Forex No Leverage"; break;
      case SYMBOL_CALC_MODE_FUTURES: calcMode = "Futures"; break;
      case SYMBOL_CALC_MODE_CFD: calcMode = "CFD"; break;
      case SYMBOL_CALC_MODE_CFDINDEX: calcMode = "CFD Index"; break;
      case SYMBOL_CALC_MODE_CFDLEVERAGE: calcMode = "CFD Leverage"; break;
      case SYMBOL_CALC_MODE_EXCH_STOCKS: calcMode = "Exchange Stocks"; break;
      case SYMBOL_CALC_MODE_EXCH_FUTURES: calcMode = "Exchange Futures"; break;
      case SYMBOL_CALC_MODE_EXCH_FUTURES_FORTS: calcMode = "FORTS Futures"; break;
      case SYMBOL_CALC_MODE_EXCH_BONDS: calcMode = "Exchange Bonds"; break;
      case SYMBOL_CALC_MODE_EXCH_STOCKS_MOEX: calcMode = "Exchange MOEX Stocks"; break;
      case SYMBOL_CALC_MODE_EXCH_BONDS_MOEX: calcMode = "Exchange MOEX Bonds"; break;
      case SYMBOL_CALC_MODE_SERV_COLLATERAL: calcMode = "Collateral"; break;      
   }
   s = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_MODE);
   switch(s)
   {
      case SYMBOL_TRADE_MODE_DISABLED: tradeMode = "Disabled"; break;
      case SYMBOL_TRADE_MODE_LONGONLY: tradeMode = "Only Long"; break;
      case SYMBOL_TRADE_MODE_SHORTONLY: tradeMode = "Only Short"; break;
      case SYMBOL_TRADE_MODE_CLOSEONLY: tradeMode = "Only Close"; break;
      case SYMBOL_TRADE_MODE_FULL: tradeMode = "Full"; break;
   }
   s = SymbolInfoInteger(_Symbol, SYMBOL_TRADE_EXEMODE);
   switch(s)
   {
      case SYMBOL_TRADE_EXECUTION_REQUEST: dealMode = "Request"; break;
      case SYMBOL_TRADE_EXECUTION_INSTANT: dealMode = "Instant"; break;
      case SYMBOL_TRADE_EXECUTION_MARKET: dealMode = "Market"; break;
      case SYMBOL_TRADE_EXECUTION_EXCHANGE: dealMode = "Exchange"; break;
   }
   s = SymbolInfoInteger(_Symbol, SYMBOL_SWAP_MODE);
   switch(s)
   {
      case SYMBOL_SWAP_MODE_DISABLED: swapMode = "Disabled"; break;
      case SYMBOL_SWAP_MODE_POINTS: swapMode = "Points"; break;
      case SYMBOL_SWAP_MODE_CURRENCY_SYMBOL: swapMode = "Currency Symbol"; break;
      case SYMBOL_SWAP_MODE_CURRENCY_MARGIN: swapMode = "Currency Margin"; break;
      case SYMBOL_SWAP_MODE_CURRENCY_DEPOSIT: swapMode = "Currency Deposit"; break;
      case SYMBOL_SWAP_MODE_INTEREST_CURRENT: swapMode = "Interest Current"; break;
      case SYMBOL_SWAP_MODE_INTEREST_OPEN: swapMode = "Interest Open"; break;
      case SYMBOL_SWAP_MODE_REOPEN_CURRENT: swapMode = "Reopened Close"; break;
      case SYMBOL_SWAP_MODE_REOPEN_BID: swapMode = "Reopened BID"; break;
   }
   s = SymbolInfoInteger(_Symbol, SYMBOL_ORDER_GTC_MODE);
   switch(s)
   {
      case SYMBOL_ORDERS_GTC: gtcMode = "Good Till Cancelled"; break;
      case SYMBOL_ORDERS_DAILY: gtcMode = "Daily (Delete Pendings and Stops)"; break;
      case SYMBOL_ORDERS_DAILY_EXCLUDING_STOPS: gtcMode = "Daily (Delete Pendings)"; break;
   }
   SYMBOL[i++] = "Symbol Description#" + SymbolInfoString(_Symbol, SYMBOL_DESCRIPTION);
   SYMBOL[i++] = "Base Currency of a Symbol#" + SymbolInfoString(_Symbol, SYMBOL_CURRENCY_BASE);
   SYMBOL[i++] = "Profit Currency#" + SymbolInfoString(_Symbol, SYMBOL_CURRENCY_PROFIT);
   SYMBOL[i++] = "Margin Currency#" + SymbolInfoString(_Symbol, SYMBOL_CURRENCY_MARGIN);   
   SYMBOL[i++] = "Path in the Symbol Tree#" + SymbolInfoString(_Symbol, SYMBOL_PATH);
   SYMBOL[i++] = "Digits After a Decimal Point#" + SymbolInfoInteger(_Symbol, SYMBOL_DIGITS);
   SYMBOL[i++] = "Symbol Point Value#" + SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   SYMBOL[i++] = "Minimal Price Change#" + SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE);
   SYMBOL[i++] = "Tick Profit Value#" + SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE);
   SYMBOL[i++] = "Trade Contract Size#" + SymbolInfoDouble(_Symbol, SYMBOL_TRADE_CONTRACT_SIZE);
   SYMBOL[i++] = "Long Swap Value#" + SymbolInfoDouble(_Symbol, SYMBOL_SWAP_LONG);
   SYMBOL[i++] = "Short Swap Value#" + SymbolInfoDouble(_Symbol, SYMBOL_SWAP_SHORT);
   SYMBOL[i++] = "Spread Value in Points#" + SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
   SYMBOL[i++] = "Bid - Best Sell Offer#" + SymbolInfoDouble(_Symbol, SYMBOL_BID);
   SYMBOL[i++] = "Maximal Bid of the Day#" + SymbolInfoDouble(_Symbol, SYMBOL_BIDHIGH);
   SYMBOL[i++] = "Minimal Bid of the Day#" + SymbolInfoDouble(_Symbol, SYMBOL_BIDLOW);
   SYMBOL[i++] = "Ask - Best Buy Offer#" + SymbolInfoDouble(_Symbol, SYMBOL_ASK);
   SYMBOL[i++] = "Maximal Ask of the Day#" + SymbolInfoDouble(_Symbol, SYMBOL_ASKHIGH);
   SYMBOL[i++] = "Minimal Ask of the Day#" + SymbolInfoDouble(_Symbol, SYMBOL_ASKLOW);   
   SYMBOL[i++] = "Open Price of the Current Session#" + SymbolInfoDouble(_Symbol, SYMBOL_SESSION_OPEN);
   SYMBOL[i++] = "Close Price of the Current Session#" + SymbolInfoDouble(_Symbol, SYMBOL_SESSION_CLOSE);
   SYMBOL[i++] = "Minimal Volume for a Deal#" + SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN);
   SYMBOL[i++] = "Maximal Volume for a Deal#" + SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX);
   SYMBOL[i++] = "Minimal Volume Change Step for Deal Execution#" + SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP);
   SYMBOL[i++] = "Volume of the Last Deal#" + SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_REAL);
   SYMBOL[i++] = "Price of the Last Deal#" + SymbolInfoDouble(_Symbol, SYMBOL_LAST);
   SYMBOL[i++] = "Maximal Last of the Day#" + SymbolInfoDouble(_Symbol, SYMBOL_LASTHIGH);
   SYMBOL[i++] = "Minimal Last of the Day#" + SymbolInfoDouble(_Symbol, SYMBOL_LASTLOW);
   SYMBOL[i++] = "Maximum Volume of the Day#" + SymbolInfoDouble(_Symbol, SYMBOL_VOLUMEHIGH_REAL);
   SYMBOL[i++] = "Minimum Volume of the Day#" + SymbolInfoDouble(_Symbol, SYMBOL_VOLUMELOW_REAL);
   SYMBOL[i++] = "Calculated Tick Price for a Profitable Position#" + SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_PROFIT);
   SYMBOL[i++] = "Calculated Tick Price for a Losing Position#" + SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE_LOSS);
   SYMBOL[i++] = "Custom Symbol#" + ((SymbolInfoInteger(_Symbol, SYMBOL_CUSTOM)==1)?"YES":"NO");
   SYMBOL[i++] = "Background Color#" + (color)SymbolInfoInteger(_Symbol, SYMBOL_BACKGROUND_COLOR);
   SYMBOL[i++] = "Chart Mode#" + ((SymbolInfoInteger(_Symbol, SYMBOL_CHART_MODE)==SYMBOL_CHART_MODE_BID)?"BID":"LAST");
   SYMBOL[i++] = "Symbol Exists#" + ((SymbolInfoInteger(_Symbol, SYMBOL_EXIST)==1)?"YES":"NO");
   SYMBOL[i++] = "Selected in Marketwatch#" + ((SymbolInfoInteger(_Symbol, SYMBOL_SELECT)==1)?"YES":"NO");
   SYMBOL[i++] = "Visible in Marketwatch#" + ((SymbolInfoInteger(_Symbol, SYMBOL_VISIBLE)==1)?"YES":"NO");
   SYMBOL[i++] = "Number of Deals in the Current Session#" + SymbolInfoInteger(_Symbol, SYMBOL_SESSION_DEALS);
   SYMBOL[i++] = "Number of Buy Orders at the Moment#" + SymbolInfoInteger(_Symbol, SYMBOL_SESSION_BUY_ORDERS);
   SYMBOL[i++] = "Number of Sell Orders at the Moment#" + SymbolInfoInteger(_Symbol, SYMBOL_SESSION_SELL_ORDERS);
   SYMBOL[i++] = "Volume of the Last Deal#" + SymbolInfoInteger(_Symbol, SYMBOL_VOLUME);
   SYMBOL[i++] = "Maximal Day Volume#" + SymbolInfoInteger(_Symbol, SYMBOL_VOLUMEHIGH);
   SYMBOL[i++] = "Minimal Day Volume#" + SymbolInfoInteger(_Symbol, SYMBOL_VOLUMELOW);
   SYMBOL[i++] = "Time of the Last Quote#" + TimeToString(SymbolInfoInteger(_Symbol, SYMBOL_TIME));
   SYMBOL[i++] = "Time of the Last Quote in ms since 1970.01.01#" + SymbolInfoInteger(_Symbol, SYMBOL_TIME_MSC);
   SYMBOL[i++] = "Indication of a Floating Spread#" + SymbolInfoInteger(_Symbol, SYMBOL_SPREAD_FLOAT);   
   SYMBOL[i++] = "Maximal Number of Requests in Depth of Market#" + SymbolInfoInteger(_Symbol, SYMBOL_TICKS_BOOKDEPTH);
   SYMBOL[i++] = "Contract Price Calculation Mode#" + calcMode;
   SYMBOL[i++] = "Order Execution Type#" + tradeMode;
   SYMBOL[i++] = "Trade Beginning (Futures)#" + TimeToString((datetime)SymbolInfoInteger(_Symbol, SYMBOL_START_TIME));
   SYMBOL[i++] = "Trade Expiration (Futures)#" + TimeToString((datetime)SymbolInfoInteger(_Symbol, SYMBOL_EXPIRATION_TIME));
   SYMBOL[i++] = "Minimum Stop in Points#" + SymbolInfoInteger(_Symbol, SYMBOL_TRADE_STOPS_LEVEL);
   SYMBOL[i++] = "Distance to Freeze Trade in Points#" + SymbolInfoInteger(_Symbol, SYMBOL_TRADE_FREEZE_LEVEL);
   SYMBOL[i++] = "Deal Execution Mode#" + dealMode;
   SYMBOL[i++] = "Swap Mode#" + swapMode;
   SYMBOL[i++] = "Day of Week to Charge 3 Days Swap Rollover#" + EnumToString((ENUM_DAY_OF_WEEK)SymbolInfoInteger(_Symbol, SYMBOL_SWAP_ROLLOVER3DAYS));
   SYMBOL[i++] = "Calculating Hedging Margin Using the Larger Leg#" + ((SymbolInfoInteger(_Symbol, SYMBOL_MARGIN_HEDGED_USE_LEG)==1)?"true":"false");
   SYMBOL[i++] = "Flags of Allowed Order Expiration Modes (GTC=1,Day=2,Specified=4,SpecifiedDay=8)#" + SymbolInfoInteger(_Symbol, SYMBOL_EXPIRATION_MODE);
   SYMBOL[i++] = "Flags of Allowed Order Filling Modes (Fill/Kill=1,Immediate/Cancel=2,Return=0)#" + SymbolInfoInteger(_Symbol, SYMBOL_FILLING_MODE);
   SYMBOL[i++] = "Flags of Allowed Order Types (M=1,L=2,S=4,SL=8,SL=16,TP=32,CBY=64)#" + SymbolInfoInteger(_Symbol, SYMBOL_ORDER_MODE);
   SYMBOL[i++] = "Expiration of Stop Loss and Take Profit Orders#" + gtcMode;
   SYMBOL[i++] = "Option Type#" + ((SymbolInfoInteger(_Symbol, SYMBOL_OPTION_MODE)==SYMBOL_OPTION_MODE_AMERICAN)?"American":"European");
   SYMBOL[i++] = "Option Right#" + ((SymbolInfoInteger(_Symbol, SYMBOL_OPTION_RIGHT)==SYMBOL_OPTION_RIGHT_CALL)?"Right Call":"Right Put");
   SYMBOL[i++] = "Strike Price of an Option#" + SymbolInfoDouble(_Symbol, SYMBOL_OPTION_STRIKE);
   SYMBOL[i++] = "Accumulated Coupon Interest#" + SymbolInfoDouble(_Symbol, SYMBOL_TRADE_ACCRUED_INTEREST);
   SYMBOL[i++] = "Initial Bond Value#" + SymbolInfoDouble(_Symbol, SYMBOL_TRADE_FACE_VALUE);
   SYMBOL[i++] = "Liquidity Rate#" + SymbolInfoDouble(_Symbol, SYMBOL_TRADE_LIQUIDITY_RATE);
   SYMBOL[i++] = "Total Volume in One Direction # " + SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_LIMIT);   
   SYMBOL[i++] = "Initial Margin Required for 1 Lot#" + SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_INITIAL);
   SYMBOL[i++] = "Maintenance Margin from 1 Lot#" + SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_MAINTENANCE);
   SYMBOL[i++] = "Summary Volume of Current Session Deals#" + SymbolInfoDouble(_Symbol, SYMBOL_SESSION_VOLUME);
   SYMBOL[i++] = "Summary Turnover of the Current Session#" + SymbolInfoDouble(_Symbol, SYMBOL_SESSION_TURNOVER);
   SYMBOL[i++] = "Summary Open Interest#" + SymbolInfoDouble(_Symbol, SYMBOL_SESSION_INTEREST);
   SYMBOL[i++] = "Current Volume of Buy Orders#" + SymbolInfoDouble(_Symbol, SYMBOL_SESSION_BUY_ORDERS_VOLUME);
   SYMBOL[i++] = "Current Volume of Sell Orders#" + SymbolInfoDouble(_Symbol, SYMBOL_SESSION_SELL_ORDERS_VOLUME);   
   SYMBOL[i++] = "Average Weighted Price of the Current Session#" + SymbolInfoDouble(_Symbol, SYMBOL_SESSION_AW);
   SYMBOL[i++] = "Settlement Price of the Current Session#" + SymbolInfoDouble(_Symbol, SYMBOL_SESSION_PRICE_SETTLEMENT);
   SYMBOL[i++] = "Minimal Price of the Current Session#" + SymbolInfoDouble(_Symbol, SYMBOL_SESSION_PRICE_LIMIT_MIN);
   SYMBOL[i++] = "Maximal Price of the Current Session#" + SymbolInfoDouble(_Symbol, SYMBOL_SESSION_PRICE_LIMIT_MAX);
   SYMBOL[i++] = "Contract Size or Margin Value per 1 Lot of Hedged Positions#" + SymbolInfoDouble(_Symbol, SYMBOL_MARGIN_HEDGED);
   SYMBOL[i++] = "Change of the Current Price Relative to the End of the Previous Trading Day in %#" + SymbolInfoDouble(_Symbol, SYMBOL_PRICE_CHANGE);
   SYMBOL[i++] = "Price Volatility in %#" + SymbolInfoDouble(_Symbol, SYMBOL_PRICE_VOLATILITY);
   SYMBOL[i++] = "Theoretical Option Price#" + SymbolInfoDouble(_Symbol, SYMBOL_PRICE_THEORETICAL);
   SYMBOL[i++] = "Option/Warrant Delta#" + SymbolInfoDouble(_Symbol, SYMBOL_PRICE_DELTA);
   SYMBOL[i++] = "Option/Warrant Theta#" + SymbolInfoDouble(_Symbol, SYMBOL_PRICE_THETA);
   SYMBOL[i++] = "Option/Warrant Gamma#" + SymbolInfoDouble(_Symbol, SYMBOL_PRICE_GAMMA);
   SYMBOL[i++] = "Option/Warrant Vega#" + SymbolInfoDouble(_Symbol, SYMBOL_PRICE_VEGA);
   SYMBOL[i++] = "Option/Warrant Rho#" + SymbolInfoDouble(_Symbol, SYMBOL_PRICE_RHO);
   SYMBOL[i++] = "Option/Warrant Omega#" + SymbolInfoDouble(_Symbol, SYMBOL_PRICE_OMEGA);
   SYMBOL[i++] = "Option/Warrant Sensitivity#" + SymbolInfoDouble(_Symbol, SYMBOL_PRICE_SENSITIVITY);
   SYMBOL[i++] = "Underlying Asset of a Derivative#" + SymbolInfoString(_Symbol, SYMBOL_BASIS);
   SYMBOL[i++] = "Sector/Category#" + SymbolInfoString(_Symbol, SYMBOL_CATEGORY);   
   SYMBOL[i++] = "Feeder of the Current Quote#" + SymbolInfoString(_Symbol, SYMBOL_BANK);   
   SYMBOL[i++] = "Exchange Market#" + SymbolInfoString(_Symbol, SYMBOL_EXCHANGE);
   SYMBOL[i++] = "Custom Symbol Pricing Formula#" + SymbolInfoString(_Symbol, SYMBOL_FORMULA);
   SYMBOL[i++] = "Name of a Symbol in the ISIN System#" + SymbolInfoString(_Symbol, SYMBOL_ISIN);
   SYMBOL[i++] = "Web Page Containing Symbol Information#" + SymbolInfoString(_Symbol, SYMBOL_PAGE);
   
   i = 0;
   TERMINAL[i++] = "Company Name#" + TerminalInfoString(TERMINAL_COMPANY);
   TERMINAL[i++] = "Terminal Name#" + TerminalInfoString(TERMINAL_NAME);
   TERMINAL[i++] = "Language#" + TerminalInfoString(TERMINAL_LANGUAGE); 
   TERMINAL[i++] = "Build Number#" + TerminalInfoInteger(TERMINAL_BUILD);
   TERMINAL[i++] = "Trade Server Connection#" + ((TerminalInfoInteger(TERMINAL_CONNECTED)==1)?"YES":"NO");
   TERMINAL[i++] = "Trade Allowed#" + ((TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)==1)?"YES":"NO");
   TERMINAL[i++] = "Last Ping in Microseconds#" + TerminalInfoInteger(TERMINAL_PING_LAST);
   TERMINAL[i++] = "Resent Network Packets (%)#" + TerminalInfoDouble(TERMINAL_RETRANSMISSION);
   TERMINAL[i++] = "MQL5.community Authorization#" + ((TerminalInfoInteger(TERMINAL_COMMUNITY_ACCOUNT)==1)?"YES":"NO");
   TERMINAL[i++] = "MQL5.community Connection#" + ((TerminalInfoInteger(TERMINAL_COMMUNITY_CONNECTION)==1)?"YES":"NO");
   TERMINAL[i++] = "MQL5.community Balance#" + TerminalInfoDouble(TERMINAL_COMMUNITY_BALANCE);
   TERMINAL[i++] = "VPS Server#" + ((TerminalInfoInteger(TERMINAL_VPS)==1)?"YES":"NO");
   TERMINAL[i++] = "Terminal Executable Path#" + TerminalInfoString(TERMINAL_PATH);
   TERMINAL[i++] = "Terminal Data Path#" + TerminalInfoString(TERMINAL_DATA_PATH);
   TERMINAL[i++] = "Terminals Common Data Path#" + TerminalInfoString(TERMINAL_COMMONDATA_PATH);
   TERMINAL[i++] = "Free Space for MQL5\Files (MB)#" + TerminalInfoInteger(TERMINAL_DISK_SPACE);
   TERMINAL[i++] = "Maximum Bars on Chart#" + TerminalInfoInteger(TERMINAL_MAXBARS);
   TERMINAL[i++] = "Screen DPI#" + TerminalInfoInteger(TERMINAL_SCREEN_DPI);
   TERMINAL[i++] = "Virtual Screen Left Coordinate#" + TerminalInfoInteger(TERMINAL_SCREEN_LEFT);
   TERMINAL[i++] = "Virtual Screen Top Coordinate#" + TerminalInfoInteger(TERMINAL_SCREEN_TOP);
   TERMINAL[i++] = "Terminal Width#" + TerminalInfoInteger(TERMINAL_SCREEN_WIDTH);
   TERMINAL[i++] = "Terminal Height#" + TerminalInfoInteger(TERMINAL_SCREEN_HEIGHT);
   TERMINAL[i++] = "Terminal Left Coordinate Relative to Virtual Screen#" + TerminalInfoInteger(TERMINAL_LEFT);
   TERMINAL[i++] = "Terminal Top Coordinate Relative to Virtual Screen#" + TerminalInfoInteger(TERMINAL_TOP);
   TERMINAL[i++] = "Terminal Right Coordinate Relative to Virtual Screen#" + TerminalInfoInteger(TERMINAL_RIGHT);
   TERMINAL[i++] = "Terminal Bottom Coordinate Relative to Virtual Screen#" + TerminalInfoInteger(TERMINAL_BOTTOM);
   TERMINAL[i++] = "CPU Cores#" + TerminalInfoInteger(TERMINAL_CPU_CORES);
   TERMINAL[i++] = "Total Physical Memory of System (MB)#" + TerminalInfoInteger(TERMINAL_MEMORY_PHYSICAL);
   TERMINAL[i++] = "Available Memory for Terminal (MB)#" + TerminalInfoInteger(TERMINAL_MEMORY_TOTAL);
   TERMINAL[i++] = "Free Memory for Terminal (MB)#" + TerminalInfoInteger(TERMINAL_MEMORY_AVAILABLE);
   TERMINAL[i++] = "Used Memory for Terminal (MB)#" + TerminalInfoInteger(TERMINAL_MEMORY_USED);
   TERMINAL[i++] = "64-Bit Terminal#" + ((TerminalInfoInteger(TERMINAL_X64)==1)?"YES":"NO");
   TERMINAL[i++] = "OpenCL Version#" + ((TerminalInfoInteger(TERMINAL_OPENCL_SUPPORT)==0)?"None":TerminalInfoInteger(TERMINAL_OPENCL_SUPPORT));   
   TERMINAL[i++] = "DLLs Allowed#" + ((TerminalInfoInteger(TERMINAL_DLLS_ALLOWED)==1)?"YES":"NO");
   TERMINAL[i++] = "Email Enabled#" + ((TerminalInfoInteger(TERMINAL_EMAIL_ENABLED)==1)?"YES":"NO");
   TERMINAL[i++] = "FTP Enabled#" + ((TerminalInfoInteger(TERMINAL_FTP_ENABLED)==1)?"YES":"NO");
   TERMINAL[i++] = "SmartPhone Notifications Enabled#" + TerminalInfoInteger(TERMINAL_NOTIFICATIONS_ENABLED);   
   TERMINAL[i++] = "MetaQuotes ID Data Presence#" + TerminalInfoInteger(TERMINAL_MQID);
   TERMINAL[i++] = "Code Page of The Language#" + EnumToString((CP)TerminalInfoInteger(TERMINAL_CODEPAGE));
   TERMINAL[i++] = "Left Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_LEFT);
   TERMINAL[i++] = "Up Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_UP);
   TERMINAL[i++] = "Right Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_RIGHT);
   TERMINAL[i++] = "Down Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_DOWN);
   TERMINAL[i++] = "Shift Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_SHIFT);
   TERMINAL[i++] = "Control Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_CONTROL);
   TERMINAL[i++] = "Menu Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_MENU);
   TERMINAL[i++] = "CapsLock Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_CAPSLOCK);
   TERMINAL[i++] = "NumLock Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_NUMLOCK);
   TERMINAL[i++] = "ScrLock Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_SCRLOCK);
   TERMINAL[i++] = "Enter Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_ENTER);
   TERMINAL[i++] = "Insert Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_INSERT);
   TERMINAL[i++] = "Delete Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_DELETE);
   TERMINAL[i++] = "Home Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_HOME);
   TERMINAL[i++] = "End Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_END);
   TERMINAL[i++] = "Tab Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_TAB);
   TERMINAL[i++] = "PageUp Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_PAGEUP);
   TERMINAL[i++] = "PageDown Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_PAGEDOWN);
   TERMINAL[i++] = "Escape Key#" + TerminalInfoInteger(TERMINAL_KEYSTATE_ESCAPE);
   
   i = 0;
   PROGRAM[i++] = "Maximum Dynamic Memory for Program (MB)#" + MQLInfoInteger(MQL_MEMORY_LIMIT);
   PROGRAM[i++] = "Memory Used by Program (MB)#" + MQLInfoInteger(MQL_MEMORY_USED);
   PROGRAM[i++] = "Type of Program#" + ((MQLInfoInteger(MQL_PROGRAM_TYPE)==PROGRAM_EXPERT)?"Expert":((MQLInfoInteger(MQL_PROGRAM_TYPE)==PROGRAM_INDICATOR)?"Indicator":((MQLInfoInteger(MQL_PROGRAM_TYPE)==PROGRAM_SCRIPT)?"Script":"Service")));
   PROGRAM[i++] = "DLLs Allowed#" + ((MQLInfoInteger(MQL_DLLS_ALLOWED)==1)?"YES":"NO"); 
   PROGRAM[i++] = "Trade Allowed#" + ((MQLInfoInteger(MQL_TRADE_ALLOWED)==1)?"YES":"NO");  
   PROGRAM[i++] = "Signals Allowed#" + ((MQLInfoInteger(MQL_SIGNALS_ALLOWED)==1)?"YES":"NO"); 
   PROGRAM[i++] = "Debugging Mode#" + ((MQLInfoInteger(MQL_DEBUG)==1)?"YES":"NO"); 
   PROGRAM[i++] = "Code Profiling Mode#" + ((MQLInfoInteger(MQL_PROFILER)==1)?"YES":"NO"); 
   PROGRAM[i++] = "Tester Mode#" + ((MQLInfoInteger(MQL_TESTER)==1)?"YES":"NO"); 
   PROGRAM[i++] = "Forward Testing Process Mode#" + ((MQLInfoInteger(MQL_FORWARD)==1)?"YES":"NO"); 
   PROGRAM[i++] = "Optimization Mode#" + ((MQLInfoInteger(MQL_OPTIMIZATION)==1)?"YES":"NO"); 
   PROGRAM[i++] = "Visual Testing Mode#" + ((MQLInfoInteger(MQL_VISUAL_MODE)==1)?"YES":"NO"); 
   PROGRAM[i++] = "Gathering Optimization Result Frames Mode#" + ((MQLInfoInteger(MQL_FRAME_MODE)==1)?"YES":"NO");  
   PROGRAM[i++] = "License Type#" + ((MQLInfoInteger(MQL_LICENSE_TYPE)==LICENSE_DEMO)?"Demo":((MQLInfoInteger(MQL_LICENSE_TYPE)==LICENSE_FREE)?"Free":((MQLInfoInteger(MQL_LICENSE_TYPE)==LICENSE_FULL)?"Full":"Time"))); 
   PROGRAM[i++] = "Program Name#" + MQLInfoString((ENUM_MQL_INFO_STRING)MQL5_PROGRAM_NAME);
   PROGRAM[i++] = "Program Path#" + MQLInfoString((ENUM_MQL_INFO_STRING)MQL5_PROGRAM_PATH);
   
   fileHandle = FileOpen(fileName, FILE_WRITE|FILE_TXT, 0, 0);
   if(fileHandle == INVALID_HANDLE)
   {
      Alert("ERROR: file cannot be opened.");
      return;
   }
   
   FileWriteString(fileHandle,
   "<!DOCTYPE HTML><HTML><HEAD><TITLE>BULK INFO (" + _Symbol + " - " + TimeCurrent() + ")</TITLE></HEAD>" +
   "<BODY style=background-color:black;color:aqua;font-family:calibri;font-size:10;font-weight:bold>"
   "<H1 style=color:gold;><CENTER><U>BULK INFORMATION 1.0</U></CENTER></H1><hr style=height:2px;border-width:0;background-color:gold>"
   );
   
   string temp[2];
   FileWriteString(fileHandle, "<br><h3 style=color:yellow;line-height:10%>ACCOUNT INFORMATION</h3><hr style=height:2px;border-width:0;background-color:crimson></span><ul style=line-height:80%;\">", -1); 
   for(i = 0; i < ArraySize(ACCOUNT); i++)
   {
      StringSplit(ACCOUNT[i], '#', temp);
      FileWriteString(fileHandle, "<li><span style=color:chartreuse;\">" + temp[0] + " = </span>" + temp[1] + "</li><br>", -1);      
   }
   FileWriteString(fileHandle, "</ul>");    
   
   FileWriteString(fileHandle, "<br><h3 style=color:yellow;line-height:10%>SYMBOL INFORMATION</h3><hr style=height:2px;border-width:0;background-color:crimson></span><ul style=line-height:80%;\">", -1); 
   for(i = 0; i < ArraySize(SYMBOL); i++)
   {
      StringSplit(SYMBOL[i], '#', temp);
      FileWriteString(fileHandle, "<li><span style=color:chartreuse;\">" + temp[0] + " = </span>" + temp[1] + "</li><br>", -1);   
   }
   FileWriteString(fileHandle, "</ul>"); 
   
   FileWriteString(fileHandle, "<br><h3 style=color:yellow;line-height:10%>TERMINAL INFORMATION</h3><hr style=height:2px;border-width:0;background-color:crimson></span><ul style=line-height:80%;\">", -1); 
   for(i = 0; i < ArraySize(TERMINAL); i++)
   {
      StringSplit(TERMINAL[i], '#', temp);
      FileWriteString(fileHandle, "<li><span style=color:chartreuse;\">" + temp[0] + " = </span>" + temp[1] + "</li><br>", -1);
   }
   FileWriteString(fileHandle, "</ul>"); 
   
   FileWriteString(fileHandle, "<br><h3 style=color:yellow;line-height:10%>PROGRAM INFORMATION</h3><hr style=height:2px;border-width:0;background-color:crimson></span><ul style=line-height:80%;\">", -1); 
   for(i = 0; i < ArraySize(PROGRAM); i++)
   {
      StringSplit(PROGRAM[i], '#', temp);
      FileWriteString(fileHandle, "<li><span style=color:chartreuse;\">" + temp[0] + " = </span>" + temp[1] + "</li><br>", -1);
   }
   FileWriteString(fileHandle, "</ul>"); 
   
   FileWriteString(fileHandle,
   "</BODY></HTML>"
   );
   
   FileClose(fileHandle);
   /*
   int result = ShellExecuteW(0, "open", TerminalInfoString(TERMINAL_DATA_PATH) + "\\MQL5\\Files\\" + fileName, NULL, NULL, 1);
   if (result <= 32) Print("Shell Execute Failed: ", result);
   */
}