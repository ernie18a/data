//+------------------------------------------------------------------+
//|                                         Export_History_Deals.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "2.000"
#property description "The script exports history of deals ordered by close time from a retail hedging account to .csv file"
#property script_show_inputs

#include <Generic\HashMap.mqh>

//--- input variables
input  datetime InpStartDate = 0;                       // Start date
input  datetime InpEndDate   = D'2038.01.01';           // End date
input  string   InpFileName  = "history_deals.csv";     // Filename
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(AccountInfoInteger(ACCOUNT_MARGIN_MODE)!=ACCOUNT_MARGIN_MODE_RETAIL_HEDGING)
     {
      Alert("This script can be started only on a retail hedging account (Forex).");
      return;
     }
//---
   if(InpStartDate>InpEndDate)
     {
      Alert("Error: The start date must be earlier than the end date");
      return;
     }

   if(ExportHistoryDeals(InpStartDate,InpEndDate,InpFileName))
     {
      //--- open the .csv file with the associated Windows program
      Execute(TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+InpFileName);

      Print("History is exported to ",TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+InpFileName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ExportHistoryDeals(datetime from_date,datetime to_date,string filename)
  {
//---
   ResetLastError();
//--- use FILE_ANSI to correctly display .csv files within Excel 2013 and above.
   int handle= FileOpen(filename,FILE_WRITE|FILE_SHARE_READ|FILE_CSV|FILE_ANSI,',');
   if(handle == INVALID_HANDLE)
     {
      Alert("File open failed, error ",_LastError);
      return(false);
     }

   FileWrite(handle,
             "Open Time",
             "Position ID",
             "Type",
             "Volume",
             "Symbol",
             "Open Price",
             "S/L",
             "T/P",
             "Close Time",
             "Close Price",
             "Commission",
             "Swap",
             "Profit",
             "Profit Points",
             "Balance",
             "Magic Number",
             "Duration",
             "Open Reason",
             "Close Reason",
             "Open Comment",
             "Close Comment",
             "Deal In Ticket",
             "Deal Out Ticket"
             );

   ulong s_time=GetMicrosecondCount();

   double Balance=0;
   int    allCnts = 0;
   double allVols = 0;
   double allComm = 0;
   double allSwap = 0;
   double allProf = 0;

//--- hash map of <pos_id, deal_in_ticket> pairs
   CHashMap<ulong,ulong>DealsIn;

//--- request the history of deals and orders for the specified period
   if(!HistorySelect(from_date,to_date))
     {
      Alert("HistorySelect failed!");
      return(false);
     }

//--- now process the list of received deals for the specified period
   ulong ticket = 0;
   int deals = HistoryDealsTotal();
   for(int i = 0; i < deals && !IsStopped(); i++)
     {
      if((ticket=HistoryDealGetTicket(i))>0)
        {
         long  EntryType = HistoryDealGetInteger(ticket,DEAL_ENTRY);
         ulong POS_ID    = HistoryDealGetInteger(ticket,DEAL_POSITION_ID);

         //--- If entry deal ticket, add to hash table
         if(EntryType==DEAL_ENTRY_IN)
           {
            DealsIn.Add(POS_ID,ticket);
           }

         //--- If exit deal ticket, search hash table by POS_ID for the entry deal
         else if(EntryType==DEAL_ENTRY_OUT || EntryType==DEAL_ENTRY_OUT_BY)
           {
            ulong ticket_in = 0;
            DealsIn.TryGetValue(POS_ID,ticket_in);

            if(ticket_in>0)
              {
               //--- Entry deal -------------------------------------------------------
               long     type             = HistoryDealGetInteger(ticket_in, DEAL_TYPE);
               long     magic            = HistoryDealGetInteger(ticket_in, DEAL_MAGIC);
               string   symbol           = HistoryDealGetString(ticket_in, DEAL_SYMBOL);
               ulong    open_ticket      = HistoryDealGetInteger(ticket_in, DEAL_TICKET);
               long     open_time        = HistoryDealGetInteger(ticket_in, DEAL_TIME);
               double   open_price       = HistoryDealGetDouble(ticket_in, DEAL_PRICE);
               double   open_volume      = HistoryDealGetDouble(ticket_in, DEAL_VOLUME);
               double   open_commission  = HistoryDealGetDouble(ticket_in, DEAL_COMMISSION);
               string   open_comment     = HistoryDealGetString(ticket_in, DEAL_COMMENT);
               long     open_reason      = HistoryDealGetInteger(ticket_in, DEAL_REASON);

               //--- Exit deal --------------------------------------------------------
               ulong    close_ticket     = HistoryDealGetInteger(ticket, DEAL_TICKET);
               long     close_time       = HistoryDealGetInteger(ticket, DEAL_TIME);
               double   close_price      = HistoryDealGetDouble(ticket, DEAL_PRICE);
               double   close_sl         = HistoryDealGetDouble(ticket, DEAL_SL);
               double   close_tp         = HistoryDealGetDouble(ticket, DEAL_TP);
               double   close_volume     = HistoryDealGetDouble(ticket, DEAL_VOLUME);
               double   close_profit     = HistoryDealGetDouble(ticket, DEAL_PROFIT);
               double   close_swap       = HistoryDealGetDouble(ticket, DEAL_SWAP);
               double   close_commission = HistoryDealGetDouble(ticket, DEAL_COMMISSION);
               string   close_comment    = HistoryDealGetString(ticket, DEAL_COMMENT);
               long     close_reason     = HistoryDealGetInteger(ticket, DEAL_REASON);

               //----------------------------------------------------------------------
               double trade_commission = close_commission + (close_volume / open_volume) * open_commission;
               //--- sums
               Balance+=close_profit+close_swap+trade_commission;;
               allVols+=close_volume;
               allComm+=trade_commission;
               allSwap+=close_swap;
               allProf+=close_profit;
               allCnts+=1;
               //---
               SymbolSelect(symbol,true);
               int digits=(int)SymbolInfoInteger(symbol,SYMBOL_DIGITS);
               double point=SymbolInfoDouble(symbol,SYMBOL_POINT);

               //----------------------------------------------------------------------
               FileWrite(handle,
                         (string)(datetime)open_time,
                         POS_ID,
                         (type==DEAL_TYPE_BUY) ? "buy" : (type==DEAL_TYPE_SELL) ? "sell" : "other",
                         // DoubleToString(close_volume,2),
                         (MathAbs(open_volume-close_volume)<0.00001 ? DoubleToString(close_volume,2) : DoubleToString(close_volume,2)+" / "+DoubleToString(open_volume,2)),
                         symbol,
                         DoubleToString(open_price,digits),
                         (close_sl ? DoubleToString(close_sl,digits) : ""),
                         (close_tp ? DoubleToString(close_tp,digits) : ""),
                         (string)(datetime)close_time,
                         DoubleToString(close_price,digits),
                         DoubleToString(trade_commission,2),
                         DoubleToString(close_swap,2),
                         DoubleToString(close_profit,2),
                         MathRound((type==DEAL_TYPE_BUY ? close_price - open_price : open_price - close_price) / point),
                         //
                         DoubleToString(Balance,2),
                         //
                         magic,
                         TimeElapsedToString((datetime)(close_time - open_time)),
                         DealReasonToString((ENUM_DEAL_REASON)open_reason),
                         DealReasonToString((ENUM_DEAL_REASON)close_reason),
                         open_comment,
                         close_comment,
                         open_ticket,
                         close_ticket
                         );
              }
           }
        }
     }
//--- footer
   FileWrite(handle,"");
   FileWrite(handle,"Closed Deals",IntegerToString(allCnts));
   FileWrite(handle,"Total Volume",DoubleToString(allVols,2));
   FileWrite(handle,"Total Commission",DoubleToString(allComm,2));
   FileWrite(handle,"Total Swap",DoubleToString(allSwap,2));
   FileWrite(handle,"Total Profit",DoubleToString(allProf,2));
   FileWrite(handle,"Total Net P/L",DoubleToString(Balance,2));
//---
   PrintFormat("Time elapsed = %I64u microsec",GetMicrosecondCount()-s_time);
   FileClose(handle);
//---
   return(true);
  }
//+------------------------------------------------------------------+
//| Get the property value "DEAL_REASON" as string                   |
//+------------------------------------------------------------------+
string DealReasonToString(ENUM_DEAL_REASON deal_reason)
  {
   switch(deal_reason)
     {
      case DEAL_REASON_CLIENT:   return ("client");
      case DEAL_REASON_MOBILE:   return ("mobile");
      case DEAL_REASON_WEB:      return ("web");
      case DEAL_REASON_EXPERT:   return ("expert");
      case DEAL_REASON_SL:       return ("sl");
      case DEAL_REASON_TP:       return ("tp");
      case DEAL_REASON_SO:       return ("so");
      case DEAL_REASON_ROLLOVER: return ("rollover");
      case DEAL_REASON_VMARGIN:  return ("vmargin");
      case DEAL_REASON_SPLIT:    return ("split");
      default:
         return ("unknow reason");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string TimeElapsedToString(const datetime pElapsedSeconds)
  {
   const long days = pElapsedSeconds / PeriodSeconds(PERIOD_D1);

   return((days ? (string)days + "d " : "") + TimeToString(pElapsedSeconds,TIME_SECONDS));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#import "shell32.dll"
int ShellExecuteW(int hWnd,string Verb,string File,string Parameter,string Path,int ShowCommand);
#import
//+------------------------------------------------------------------+
//| Execute Windows command/program or open a document/webpage       |
//+------------------------------------------------------------------+
void Execute(const string command,const string parameters="")
  {
   shell32::ShellExecuteW(0,"open",command,parameters,NULL,1);
  }
//+------------------------------------------------------------------+
