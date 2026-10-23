#property copyright "Usamah"
#property link      "https://www.mql5.com/en/users/usamah41"
#property version   "1.00"
#property description "Read-only deal and round-trip cost reconciliation to CSV."
#property strict

#include "RoundTripCostCore.mqh"

enum ENUM_RTC_SYMBOL_SCOPE
  {
   RTC_CURRENT_SYMBOL=0,
   RTC_ALL_SYMBOLS=1
  };

input group "History scope"
input int                   InpDaysBack=30;                         // History window, 1..3650 days
input ENUM_RTC_SYMBOL_SCOPE InpSymbolScope=RTC_ALL_SYMBOLS;         // Current chart symbol or all symbols
input long                  InpMagicFilter=-1;                      // -1 = all magic numbers

input group "CSV output"
input string InpDealsFileName="RoundTripCostDeals.csv";            // Deal-level CSV file name
input string InpPositionsFileName="RoundTripCostPositions.csv";    // Position-level CSV file name
input bool   InpUseCommonFolder=true;                               // Write to terminal Common Files
input ushort InpDelimiter=44;                                      // 44 comma, 59 semicolon

RTCPositionRow g_rows[];

//+------------------------------------------------------------------+
//| Validate a local CSV file name                                   |
//+------------------------------------------------------------------+
bool RTCValidFileName(const string value)
  {
   if(StringLen(value)<5)
      return false;
   if(StringFind(value,"..")>=0 || StringFind(value,"\\")>=0 || StringFind(value,"/")>=0 || StringFind(value,":")>=0)
      return false;
   return(StringSubstr(value,StringLen(value)-4)==".csv");
  }

bool RTCDealTypeAllowed(const ENUM_DEAL_TYPE type)
  {
   return(type==DEAL_TYPE_BUY || type==DEAL_TYPE_SELL);
  }

bool RTCFilterDeal(const ulong ticket)
  {
   const string symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
   if(InpSymbolScope==RTC_CURRENT_SYMBOL && symbol!=_Symbol)
      return false;
   const long magic=HistoryDealGetInteger(ticket,DEAL_MAGIC);
   if(InpMagicFilter>=0 && magic!=InpMagicFilter)
      return false;
   return RTCDealTypeAllowed((ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE));
  }

int RTCFindOrAdd(const ulong position_id,const string symbol,const long magic,const datetime deal_time)
  {
   const int total=ArraySize(g_rows);
   for(int i=0;i<total;i++)
      if(g_rows[i].position_id==position_id && g_rows[i].symbol==symbol)
         return i;
   if(ArrayResize(g_rows,total+1)!=total+1)
      return -1;
   RTCResetRow(g_rows[total],position_id,symbol,magic,deal_time);
   return total;
  }

int RTCOpenCSV(const string name)
  {
   int flags=FILE_WRITE|FILE_CSV|FILE_ANSI;
   if(InpUseCommonFolder)
      flags|=FILE_COMMON;
   return FileOpen(name,flags,InpDelimiter);
  }

bool RTCWriteDealsHeader(const int file)
  {
   return(FileWrite(file,"time","time_msc","deal","order","position_id","symbol","magic","deal_type","entry",
                    "reason","volume","price","profit","commission","swap","fee","comment")>0);
  }

bool RTCWritePositionsHeader(const int file)
  {
   return(FileWrite(file,"position_id","symbol","magic","first_time","last_time","entry_volume","exit_volume",
                    "average_entry_price","average_exit_price","gross_profit","commission","swap","fee","total_costs",
                    "net_result","deal_count","status")>0);
  }

//+------------------------------------------------------------------+
//| Export filtered history and reconcile position identifiers       |
//+------------------------------------------------------------------+
int RTCExport()
  {
   ArrayResize(g_rows,0);
   const datetime to_time=TimeCurrent();
   const datetime from_time=to_time-(datetime)(InpDaysBack*86400);
   if(!HistorySelect(from_time,to_time))
     {
      PrintFormat("RTC history selection failed error=%d",GetLastError());
      return -1;
     }

   const int deals_file=RTCOpenCSV(InpDealsFileName);
   if(deals_file==INVALID_HANDLE)
     {
      PrintFormat("RTC cannot open deals CSV error=%d",GetLastError());
      return -1;
     }
   if(!RTCWriteDealsHeader(deals_file))
     {
      FileClose(deals_file);
      Print("RTC cannot write deals CSV header");
      return -1;
     }

   int exported_deals=0;
   const int total=HistoryDealsTotal();
   for(int i=0;i<total;i++)
     {
      const ulong ticket=HistoryDealGetTicket(i);
      if(ticket==0 || !RTCFilterDeal(ticket))
         continue;

      const ulong position_id=(ulong)HistoryDealGetInteger(ticket,DEAL_POSITION_ID);
      const string symbol=HistoryDealGetString(ticket,DEAL_SYMBOL);
      const long magic=HistoryDealGetInteger(ticket,DEAL_MAGIC);
      const datetime deal_time=(datetime)HistoryDealGetInteger(ticket,DEAL_TIME);
      const ENUM_DEAL_ENTRY entry=(ENUM_DEAL_ENTRY)HistoryDealGetInteger(ticket,DEAL_ENTRY);
      const double volume=HistoryDealGetDouble(ticket,DEAL_VOLUME);
      const double price=HistoryDealGetDouble(ticket,DEAL_PRICE);
      const double profit=HistoryDealGetDouble(ticket,DEAL_PROFIT);
      const double commission=HistoryDealGetDouble(ticket,DEAL_COMMISSION);
      const double swap=HistoryDealGetDouble(ticket,DEAL_SWAP);
      const double fee=HistoryDealGetDouble(ticket,DEAL_FEE);
      const int row_index=RTCFindOrAdd(position_id,symbol,magic,deal_time);
      if(row_index<0)
        {
         FileClose(deals_file);
         Print("RTC memory allocation failed");
         return -1;
        }
      RTCAccumulate(g_rows[row_index],entry,volume,price,profit,commission,swap,fee,deal_time,magic);

      const long time_msc=HistoryDealGetInteger(ticket,DEAL_TIME_MSC);
      const ulong order=(ulong)HistoryDealGetInteger(ticket,DEAL_ORDER);
      FileWrite(deals_file,TimeToString(deal_time,TIME_DATE|TIME_SECONDS),time_msc,ticket,order,position_id,symbol,magic,
                EnumToString((ENUM_DEAL_TYPE)HistoryDealGetInteger(ticket,DEAL_TYPE)),EnumToString(entry),
                EnumToString((ENUM_DEAL_REASON)HistoryDealGetInteger(ticket,DEAL_REASON)),DoubleToString(volume,8),
                DoubleToString(price,(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS)),DoubleToString(profit,2),
                DoubleToString(commission,2),DoubleToString(swap,2),DoubleToString(fee,2),
                HistoryDealGetString(ticket,DEAL_COMMENT));
      exported_deals++;
     }
   FileClose(deals_file);

   const int positions_file=RTCOpenCSV(InpPositionsFileName);
   if(positions_file==INVALID_HANDLE)
     {
      PrintFormat("RTC cannot open positions CSV error=%d",GetLastError());
      return -1;
     }
   if(!RTCWritePositionsHeader(positions_file))
     {
      FileClose(positions_file);
      Print("RTC cannot write positions CSV header");
      return -1;
     }

   int complete=0,incomplete=0,complex_count=0;
   for(int i=0;i<ArraySize(g_rows);i++)
     {
      const int digits=(int)SymbolInfoInteger(g_rows[i].symbol,SYMBOL_DIGITS);
      const double step=SymbolInfoDouble(g_rows[i].symbol,SYMBOL_VOLUME_STEP);
      const string status=RTCStatus(g_rows[i],step);
      if(status=="COMPLETE") complete++;
      else if(status=="COMPLEX_REVERSAL") complex_count++;
      else incomplete++;
      FileWrite(positions_file,g_rows[i].position_id,g_rows[i].symbol,g_rows[i].magic,
                TimeToString(g_rows[i].first_time,TIME_DATE|TIME_SECONDS),TimeToString(g_rows[i].last_time,TIME_DATE|TIME_SECONDS),
                DoubleToString(g_rows[i].entry_volume,8),DoubleToString(g_rows[i].exit_volume,8),
                DoubleToString(RTCAveragePrice(g_rows[i].entry_value,g_rows[i].entry_volume),digits),
                DoubleToString(RTCAveragePrice(g_rows[i].exit_value,g_rows[i].exit_volume),digits),
                DoubleToString(g_rows[i].gross_profit,2),DoubleToString(g_rows[i].commission,2),
                DoubleToString(g_rows[i].swap,2),DoubleToString(g_rows[i].fee,2),DoubleToString(RTCCosts(g_rows[i]),2),
                DoubleToString(RTCNetResult(g_rows[i]),2),g_rows[i].deal_count,status);
     }
   FileClose(positions_file);

   Comment("ROUND TRIP COST RECONCILER | READ ONLY\n",
           "Deals: ",exported_deals," | Position IDs: ",ArraySize(g_rows),"\n",
           "Complete: ",complete," | Review: ",incomplete," | Complex reversal: ",complex_count,"\n",
           "Files: ",InpDealsFileName," + ",InpPositionsFileName);
   PrintFormat("RTC export complete deals=%d positions=%d complete=%d review=%d complex=%d read_only=true",
               exported_deals,ArraySize(g_rows),complete,incomplete,complex_count);
   return exported_deals;
  }

//+------------------------------------------------------------------+
//| Validate inputs and run the read-only export                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(InpDaysBack<1 || InpDaysBack>3650)
     {
      Print("RTC initialization failed: days back must be 1..3650");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpMagicFilter<-1)
     {
      Print("RTC initialization failed: magic filter must be -1 or non-negative");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(InpDelimiter!=44 && InpDelimiter!=59)
     {
      Print("RTC initialization failed: delimiter must be comma (44) or semicolon (59)");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(!RTCValidFileName(InpDealsFileName) || !RTCValidFileName(InpPositionsFileName) || InpDealsFileName==InpPositionsFileName)
     {
      Print("RTC initialization failed: use two distinct safe .csv file names");
      return INIT_PARAMETERS_INCORRECT;
     }
   if(RTCExport()<0)
      return INIT_FAILED;
   return INIT_SUCCEEDED;
  }

void OnTick()
  {
  }

void OnDeinit(const int reason)
  {
   Comment("");
  }
