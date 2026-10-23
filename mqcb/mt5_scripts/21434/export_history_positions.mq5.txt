//+------------------------------------------------------------------+
//|                                     Export_History_Positions.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "2.000"
#property description "The script exports history of closed positions from a retail hedging account to .csv file"
#property script_show_inputs

#include <Trade\DealInfo.mqh>
#include <Generic\HashSet.mqh>

enum ENUM_HISTORY_SORT
  {
   HISTORY_SORT_OPENTIME,   // Open time
   HISTORY_SORT_CLOSETIME   // Close time
  };

//--- input variables
input  datetime          InpStartDate   = 0;                       // Start date
input  datetime          InpEndDate     = D'2038.01.01';           // End date
input  string            InpFileName    = "history_positions.csv"; // Filename
input  ENUM_HISTORY_SORT InpHistorySort = HISTORY_SORT_CLOSETIME;  // Order positions by:
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

   if(ExportHistoryPositions(InpStartDate,InpEndDate,InpFileName,InpHistorySort))
     {
      //--- open the .csv file with the associated Windows program
      Execute(TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+InpFileName);

      Print("History is exported to ",TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+InpFileName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ExportHistoryPositions(datetime from_date,datetime to_date,string filename,int sort_by)
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
             "Ticket",
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
             "Deal Out Tickets");

   ulong s_time=GetMicrosecondCount();

   double Balance=0;
   int    allCnts = 0;
   double allVols = 0;
   double allComm = 0;
   double allSwap = 0;
   double allProf = 0;

//--- Define the array to store positions ID
   long arr_Positions[];

//--- variable to hold the current deal object
   CDealInfo deal;

//--- request the history of deals and orders for the specified period
   if(!HistorySelect(from_date,to_date))
     {
      Alert("HistorySelect failed!");
      return(false);
     }

//--- now process the list of received deals for the specified period
   int deals = HistoryDealsTotal();
//---
   if(sort_by==HISTORY_SORT_OPENTIME)
     {
      for(int i = 0; i < deals && !IsStopped(); i++)
         if(deal.SelectByIndex(i))
            if(deal.Entry()==DEAL_ENTRY_IN)
               if(deal.DealType()==DEAL_TYPE_BUY || deal.DealType()==DEAL_TYPE_SELL)
                 {
                  //--- save position ids to the array
                  long position_id=deal.PositionId();
                  int arr_size=ArraySize(arr_Positions);
                  ArrayResize(arr_Positions,arr_size+1,100);
                  arr_Positions[arr_size]=position_id;
                 }
     }
//---
   if(sort_by==HISTORY_SORT_CLOSETIME)
     {
      //--- define a hashset to collect position IDs (with no duplicates)
      CHashSet<long>hashset;

      //--- handle the case when a position has multiple deals out.
      for(int i = deals-1; i >= 0 && !IsStopped(); i--)
         if(deal.SelectByIndex(i))
            if(deal.Entry()==DEAL_ENTRY_OUT || deal.Entry()==DEAL_ENTRY_OUT_BY)
               if(deal.DealType()==DEAL_TYPE_BUY || deal.DealType()==DEAL_TYPE_SELL)
                  hashset.Add(deal.PositionId());

      //--- copy the elements from the set to a compatible one-dimensional array
      hashset.CopyTo(arr_Positions,0);
      //ArrayReverse(arr_Positions);
      ArraySetAsSeries(arr_Positions,true);
     }

//--- now process the list of positions stored in the array
   int positions=ArraySize(arr_Positions);
   for(int i=0; i<positions && !IsStopped(); i++)
     {
      string   pos_symbol=NULL;
      long     pos_id=-1;
      long     pos_type=-1;
      long     pos_magic=-1;
      double   pos_open_price=0;
      double   pos_close_price=0;
      double   pos_sl = 0;
      double   pos_tp = 0;
      double   pos_commission = 0;
      double   pos_swap=0;
      double   pos_profit=0;
      double   pos_open_volume= 0;
      double   pos_close_volume=0;
      datetime pos_open_time=0;
      datetime pos_close_time=0;
      double   pos_sum_cost=0;
      long     pos_open_reason=-1;
      long     pos_close_reason=-1;
      string   pos_open_comment = NULL;
      string   pos_close_comment = NULL;
      string   pos_deal_in = NULL;
      string   pos_deal_out=NULL;

      //--- request the history of deals and orders for the specified position
      if(HistorySelectByPosition(arr_Positions[i]) && HistoryDealsTotal()>1)
        {
         //--- now process the list of received deals for the specified position
         deals=HistoryDealsTotal();
         for(int j=0; j<deals && !IsStopped(); j++)
           {
            //--- select deal ticket by its position in the list
            if(deal.SelectByIndex(j))
              {
               pos_id                 = deal.PositionId();
               pos_symbol             = deal.Symbol();
               pos_commission        += deal.Commission();
               pos_swap              += deal.Swap();
               pos_profit            += deal.Profit();

               //--- Entry deal for position
               if(deal.Entry()==DEAL_ENTRY_IN)
                 {
                  pos_magic           = deal.Magic();
                  pos_type            = deal.DealType();
                  pos_open_time       = deal.Time();
                  pos_open_price      = deal.Price();
                  pos_open_volume     = deal.Volume();
                  //---
                  pos_open_comment    = deal.Comment();
                  pos_deal_in         = IntegerToString(deal.Ticket());
                  pos_open_reason     = HistoryDealGetInteger(deal.Ticket(), DEAL_REASON);
                 }

               //--- Exit deal(s) for position
               else if(deal.Entry()==DEAL_ENTRY_OUT || deal.Entry()==DEAL_ENTRY_OUT_BY)
                 {
                  pos_close_time      = deal.Time();
                  pos_sum_cost       += deal.Volume() * deal.Price();
                  pos_close_volume   += deal.Volume();
                  pos_close_price     = pos_sum_cost / pos_close_volume;
                  pos_sl              = HistoryDealGetDouble(deal.Ticket(), DEAL_SL);
                  pos_tp              = HistoryDealGetDouble(deal.Ticket(), DEAL_TP);
                  //---
                  pos_close_comment  += deal.Comment() + " ";
                  pos_deal_out       += IntegerToString(deal.Ticket()) + " ";
                  pos_close_reason    = HistoryDealGetInteger(deal.Ticket(), DEAL_REASON);
                 }
              }
           }

         //--- If the position is still open, it will not be displayed in the history.
         if(MathAbs(pos_open_volume-pos_close_volume)>0.00001)
            continue;

         //--- Closed position is reconstructed
         StringTrimLeft(pos_close_comment);
         StringTrimRight(pos_close_comment);
         StringTrimRight(pos_deal_out);
         //--- sums
         Balance+=pos_profit+pos_swap+pos_commission;
         allVols+=pos_close_volume;
         allComm+=pos_commission;
         allSwap+=pos_swap;
         allProf+=pos_profit;
         allCnts+=1;
         //---
         SymbolSelect(pos_symbol,true);
         int digits=(int)SymbolInfoInteger(pos_symbol,SYMBOL_DIGITS);
         double point=SymbolInfoDouble(pos_symbol,SYMBOL_POINT);
         //---
         FileWrite(handle,
                   (string)pos_open_time,
                   pos_id,
                   (pos_type==DEAL_TYPE_BUY) ? "buy" : (pos_type==DEAL_TYPE_SELL) ? "sell" : "other",
                   DoubleToString(pos_close_volume,2),
                   pos_symbol,
                   DoubleToString(pos_open_price,digits),
                   (pos_sl ? DoubleToString(pos_sl,digits) : ""),
                   (pos_tp ? DoubleToString(pos_tp,digits) : ""),
                   (string)pos_close_time,
                   DoubleToString(pos_close_price,(deals==2 ? digits : digits+3)),
                   DoubleToString(pos_commission,2),
                   DoubleToString(pos_swap,2),
                   DoubleToString(pos_profit,2),
                   MathRound((pos_type == DEAL_TYPE_BUY ? pos_close_price - pos_open_price : pos_open_price - pos_close_price) / point),
                   //
                   (sort_by == HISTORY_SORT_CLOSETIME ? DoubleToString(Balance,2) : ""),
                   //
                   pos_magic,
                   TimeElapsedToString(pos_close_time - pos_open_time),
                   DealReasonToString((ENUM_DEAL_REASON)pos_open_reason),
                   DealReasonToString((ENUM_DEAL_REASON)pos_close_reason),
                   pos_open_comment,
                   pos_close_comment,
                   pos_deal_in,
                   pos_deal_out
                   );
        }
     }
//--- footer
   FileWrite(handle,"");
   FileWrite(handle,"Closed Positions",IntegerToString(allCnts));
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
