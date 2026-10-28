//+------------------------------------------------------------------+
//|                                              Moving Averages.mq5 |
//|                   Copyright 2009-2017, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2009-2017, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.00"
#property tester_everytick_calculate
//#include <Common.mqh>
#include <Trade\Trade.mqh>
#include <Arrays\ArrayString.mqh>
#include <Arrays\ArrayLong.mqh>
#include <Arrays\ArrayObj.mqh>
#include <Math\Stat\Math.mqh>
#include <generic/hashmap.mqh>
#include <generic/arraylist.mqh>


#define MA_MAGIC 1002

//--- input parameters
enum ENUM_RISK_OR_LOTS
  {
   Risk=0,
   Lots=1,

  };


CHashMap<string, long> symbols_trading_time;

//--- input parameters
class STRUCT_TRADE_INFO
  {
public:
   string            symbol;
   datetime          time;
   double            amount;
   bool              stoploss;
   bool              takeprofit;
   string               id;
  };

STRUCT_TRADE_INFO trades[];

input string      SymbolsFile    = "OrdersExecution/Symbols.csv";        // Symbols to trade
input string      AccountFile    = "OrdersExecution/Account.csv";        // Account Info
input string      DownloadDir    = "OrdersExecution/Data";        // Directory to download
input string      InpFileName    = "OrdersExecution/Orders.csv";        // Orders file
input int         LookBack = 252;    // LookBack Period to download
input int      DownloadingHour    = 21;        // Hour to Download
input int      TradingHour    = 23;        // Hour to Open Trades, if not specified
input bool     IgnoreTradingHour = false; // Ignore trading hour
input bool     IgnoreTradeID = true; // Ignore trade ID, close all trades for a symbol
input int      MaxPositions = 1; // Max Positions
input bool      RemoveOrdersFile = true; // Delete Orders file after reading
input bool      Multiplier = false; // Apply multiplier (usually for tester)
input bool      Debug = true; // Debug

//---
bool   ExtHedging=false;
CTrade ExtTrade;
double initialBalance = 0, prevEquity = 0;
int file_debug;
uint last_open=0, last_close=0;
double spread_cost = 0;



//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void updateAccountFile()
  {
   if(Debug)
      Print("ººº Updating Account File: ", AccountFile);  
   FileDelete(AccountFile, FILE_COMMON);
   int account_file = FileOpen(AccountFile, FILE_WRITE|FILE_ANSI|FILE_CSV|FILE_COMMON, ",");
   if(account_file==INVALID_HANDLE)
     {
      PrintFormat("*** Failed to open %s file, Error code = %d",AccountFile,GetLastError());
      ExpertRemove();
     }
   double balance = AccountInfoDouble(ACCOUNT_BALANCE);
   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   int positions = PositionsTotal();
   FileWrite(account_file, "Balance",  equity);
   FileWrite(account_file, "Equity",  balance);
   FileWrite(account_file, "Positions",  positions);
   FileClose(account_file);

  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void readInfoFile()
  {
   if(Debug)
      Print("ººº Reading info file: ", SymbolsFile);
      
// Open the file
   int input_file = FileOpen(SymbolsFile, FILE_SHARE_READ|FILE_ANSI|FILE_COMMON);
   if(input_file==INVALID_HANDLE)
     {
      PrintFormat("*** Failed to open %s file, Error code = %d",SymbolsFile,GetLastError());
      return;
     }
   int    str_size;
   string str;

// Read the file
   while(!FileIsEnding(input_file))
     {
      str_size=FileReadInteger(input_file,INT_VALUE);
      str=FileReadString(input_file,str_size);
      string splitted[];
      StringSplit(str, ',', splitted);
      if(ArraySize(splitted) != 2)
        {
         PrintFormat("*** Failed to read %s file, columns %d", input_file, ArraySize(splitted));
         ExpertRemove();

        }
      string symbol = splitted[0];
      long time = StringToInteger(splitted[1]);
      if(TradingHour > -1) // TradingHour overwrites indicated trading hours
         time = TradingHour;

      symbols_trading_time.Add(symbol, time);
      long trading_time;
      symbols_trading_time.TryGetValue(symbol, trading_time);

     }
   FileClose(input_file);
   
  
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void retrieveData(string& symbols[])
  {
   if(Debug)
      Print("ººº Retrieving symbols data, total symbols: ", ArraySize(symbols));
      
   ENUM_TIMEFRAMES period = PERIOD_D1;

// Download the data for each symbol   
   for(int j = 0; j < ArraySize(symbols); j++)
     {
      string symbol = symbols[j];
      long time;
      symbols_trading_time.TryGetValue(symbol, time);
      Print("ººº Downloading data for symbol: ", symbol);
      MqlRates BarData[];
      int n = CopyRates(symbol, period, 0, LookBack, BarData); // Copy the data of last incomplete BAR
      if(n == -1)
        {
         PrintFormat("*** Failed to download data for symbol %s, Error code = %d, waiting 5 second and try again",symbol,GetLastError());
         Sleep(5000);
         j--;
         continue;
        }
      string file;
      StringConcatenate(file, DownloadDir, "/", symbol, ".csv");
      
      int output_file = FileOpen(file, FILE_WRITE|FILE_ANSI|FILE_CSV|FILE_COMMON, ",");
      FileWrite(output_file, "Date",  "Open", "High", "Low", "Close", "Volume",  "Ticks",  "Spread");
      for(int t = 0; t < LookBack; t++)
         FileWrite(output_file, BarData[t].time,  BarData[t].open, BarData[t].high, BarData[t].low, BarData[t].close, BarData[t].real_volume,  BarData[t].tick_volume,  BarData[t].spread);
      FileClose(output_file);

     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void checkNewOrders()
  {
   if(Debug)
      Print("ººº Checking new orders: ", InpFileName);
   
   MqlDateTime  dt_struct_time;
   TimeLocal(dt_struct_time);

   ArrayFree(trades);

// read trades
   string file_trades = InpFileName;
   int file_handle=FileOpen(file_trades,FILE_SHARE_READ|FILE_ANSI|FILE_COMMON);
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("ººº %s file is available for reading",file_trades);
      //--- additional variables
      string str;
      //--- read data from the file
      while(!FileIsEnding(file_handle))
        {
         str=FileReadString(file_handle);
         string splitted[];
         StringSplit(str, ',', splitted);
         if(ArraySize(splitted) != 6)
           {
            PrintFormat("*** Failed to read %s file, columns %d", file_trades, ArraySize(splitted));

           }
         string symbol = splitted[0];
         datetime time = StringToTime(splitted[1]);
         MqlDateTime  dt_trade_time;
         TimeToStruct(time, dt_trade_time);
         double amount = StringToDouble(splitted[2]);
         bool stoploss = StringToInteger(splitted[3]);
         bool takeprofit = StringToInteger(splitted[4]);
         string id = splitted[5];

         if(!MQLInfoInteger(MQL_TESTER) && dt_trade_time.day < dt_struct_time.day && dt_trade_time.mon < dt_struct_time.mon && dt_trade_time.year < dt_struct_time.year)
           {
            if(Debug)
               Print("ººº Trade ",  str, " is old, ignored");
            continue;
           }

         STRUCT_TRADE_INFO t;
         t.symbol = symbol;
         t.time = time;
         t.amount = amount;
         t.stoploss = stoploss;
         t.takeprofit = takeprofit;
         t.id = id;
         ArrayResize(trades, ArraySize(trades)+1);
         trades[ArraySize(trades)-1] = t;
        }
      Print("ººº Found: ", ArraySize(trades), " trades");
     }
   else
     {
      Print("*** Cannot open file "+InpFileName+", I will try again at next bar");
      
     }

//--- close the file
   FileClose(file_handle);
   if(!MQLInfoInteger(MQL_TESTER) && RemoveOrdersFile)
      FileDelete(file_trades,FILE_COMMON);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   
   ExtTrade.SetExpertMagicNumber(MA_MAGIC);
   initialBalance = AccountInfoDouble(ACCOUNT_EQUITY);
   // No need to update the account file during testing
   if(!MQLInfoInteger(MQL_TESTER)) 
      updateAccountFile();
   readInfoFile();
   // check orders only at the beginning during testing
   if(MQLInfoInteger(MQL_TESTER)) 
     checkNewOrders();
     
   if(Debug)
     {
      file_debug = FileOpen("debug_file.txt",FILE_WRITE|FILE_ANSI|FILE_COMMON);
      if(file_debug==INVALID_HANDLE)
        {
         Print("*** Cannot open file debug: ",GetLastError());
         ExpertRemove();
        }
      prevEquity = AccountInfoDouble(ACCOUNT_EQUITY);
     }

   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(Debug)
      Print("ººº Total spread cost: ", spread_cost*1000, " pips");
   FileClose(file_debug);   
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool isNewBar()
  {
   static datetime lastTime=0;
   datetime lastbarTime=(datetime)SeriesInfoInteger(Symbol(),0,SERIES_LASTBAR_DATE);
   if(lastTime==0)
     {
      lastTime=lastbarTime;
      return(false);
     }
   if(lastTime!=lastbarTime)
     {
      lastTime=lastbarTime;
      return(true);
     }
   return(false);
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getPositionsForSymbol(string symbol)
  {

   int postions = 0;

   for(int i = PositionsTotal()-1; i>=0; i--)
     {
      string s = PositionGetSymbol(i);

      if(symbol == s)

        {

         postions+=1 ;

        }
     }

   return(postions);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTick()
  {

// Only operate at new bar (hourly)
   if(!isNewBar())
      return;

   MqlDateTime  dt_struct_time;
   TimeCurrent(dt_struct_time);

// Update account file and download new data (not in tester)
   if(!MQLInfoInteger(MQL_TESTER) && dt_struct_time.hour == DownloadingHour) {
      updateAccountFile();
      string symbols[];
      long trading_times[];
      symbols_trading_time.CopyTo(symbols, trading_times);
      retrieveData(symbols);
      }

// Check for new orders (not in tester)
   if(!MQLInfoInteger(MQL_TESTER))
      checkNewOrders();

   double equity = AccountInfoDouble(ACCOUNT_EQUITY);
   double multiplier = equity / initialBalance;
   if(!Multiplier)
      multiplier = 1;

   if(Debug)
      FileWrite(file_debug, equity);
//Print(   equity);


// check for trades to close
   for(uint i=0; i < trades.Size(); i++)
     {
      STRUCT_TRADE_INFO t = trades[i];
      MqlDateTime dt_struct_trade;
      TimeToStruct(t.time, dt_struct_trade);
      // Check if symbol trading time is the current time
      long trading_time;
      symbols_trading_time.TryGetValue(t.symbol, trading_time);
      if(dt_struct_time.hour != trading_time)
         continue;
      // Check if position time matches order closing time
      if(dt_struct_time.day == dt_struct_trade.day && dt_struct_time.mon == dt_struct_trade.mon && dt_struct_time.year == dt_struct_trade.year)
        {
         if(t.amount == 0)
           {
            Print("ººº Processing close entry: ", t.id);
            for(int j = 0; j < PositionsTotal(); j++)
              {
               PositionGetSymbol(j);
               if(MA_MAGIC==PositionGetInteger(POSITION_MAGIC))
                  if((!IgnoreTradeID && PositionGetString(POSITION_COMMENT) == t.id) || IgnoreTradeID)
                 {
                  ExtTrade.PositionClose(PositionGetTicket(j));
                  //last_close = i + 1;
                 }
              }
           }
        }
     }


// check for new trades to open
   for(uint i=0; i < trades.Size(); i++)
     {
      STRUCT_TRADE_INFO t = trades[i];
      MqlDateTime dt_struct_trade;
      TimeToStruct(t.time, dt_struct_trade);
      // Check if symbol trading time is the current time
      long trading_time;
      symbols_trading_time.TryGetValue(t.symbol, trading_time);
      //Print(dt_struct_time.hour, " ", trading_time);
      if(dt_struct_time.hour != trading_time)
         continue;
      // Check if position time matches order opening time
      if((dt_struct_time.day == dt_struct_trade.day && dt_struct_time.mon == dt_struct_trade.mon && dt_struct_time.year == dt_struct_trade.year))
        {

         if(t.amount != 0)
           {
            Print("ººº Processing open entry: ", t.id);
            if(getPositionsForSymbol(t.symbol) >= MaxPositions)
              {
               Print("*** Already too many positions for symbol: ", t.symbol);
               continue;
              }
            double ask = SymbolInfoDouble(t.symbol,SYMBOL_ASK);
            double bid = SymbolInfoDouble(t.symbol,SYMBOL_BID);
            double spread = ask - bid;
            double entry = t.amount > 0 ?  SymbolInfoDouble(t.symbol,SYMBOL_ASK) : SymbolInfoDouble(t.symbol,SYMBOL_BID);
            double position = 0;
            int    lotdigits   = (int) - MathLog10(SymbolInfoDouble(t.symbol, SYMBOL_VOLUME_STEP));
            position = NormalizeDouble(MathAbs(t.amount * multiplier), lotdigits);
            ENUM_ORDER_TYPE order = t.amount > 0 ? ORDER_TYPE_BUY : ORDER_TYPE_SELL;
            double stoploss = t.stoploss;
            double takeprofit = t.takeprofit;
            string ID = t.id;
            ExtTrade.PositionOpen(t.symbol,order,position,entry,stoploss,takeprofit,ID);
            //last_open = i + 1;
            spread_cost += spread;
           }
        }

     }

// Mopping up zombie trades
   for(uint i=last_close; i < trades.Size(); i++)
     {
      STRUCT_TRADE_INFO t = trades[i];
      MqlDateTime dt_struct_trade;
      TimeToStruct(t.time, dt_struct_trade);
      for(int j = 0; j < PositionsTotal(); j++)
        {
         PositionGetSymbol(j);
         if(MA_MAGIC==PositionGetInteger(POSITION_MAGIC) && PositionGetString(POSITION_COMMENT) == t.id)
           {
            if((TimeCurrent() > t.time + 86400) && t.amount == 0)
              {
               Print("*** OLD position stilll alive, killing it: " + t.id);
               ExtTrade.PositionClose(PositionGetTicket(j));
              }
           }
        }

     }
  }



//+------------------------------------------------------------------+

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
