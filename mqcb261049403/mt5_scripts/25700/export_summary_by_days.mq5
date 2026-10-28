//+------------------------------------------------------------------+
//|                                       Export_Summary_By_Days.mq5 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "2.000"
#property description "The script exports summary of closed trades grouped by each trading day to .csv file"
#property script_show_inputs

#include <Trade\DealInfo.mqh>
#include <Generic\HashMap.mqh>
#include <Generic\SortedMap.mqh>

//--- input variables
input  datetime InpStartDate = 0;                        // Start date
input  datetime InpEndDate   = D'2038.01.01';            // End date
input  string   InpFileName  = "summary_by_days.csv";    // Filename
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/// Class CDaySummary for grouping closed trades by day in a SortedMap.
class CDaySummary
  {
public:
   int               count;
   double            vols;
   double            prof;
   double            comm;
   double            swap;
public:
                     CDaySummary() : count(0),vols(0),prof(0),comm(0),swap(0) {   }
                    ~CDaySummary() {   }
   void              Update(double v,double p,double c,double s) { vols+=v; prof+=p; comm+=c; swap+=s; count+=1; }
public:
   bool              Equals(CDaySummary *obj) { return false; }
   int               HashCode(void) { return 0; }
  };
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(InpStartDate>InpEndDate)
     {
      Alert("Error: The start date must be earlier than the end date");
      return;
     }

   if(ExportSummaryByDay(InpStartDate,InpEndDate,InpFileName))
     {
      //--- open the .csv file with the associated Windows program
      Execute(TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+InpFileName);

      Print("History is exported to ",TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL5\\Files\\"+InpFileName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ExportSummaryByDay(datetime from_date,datetime to_date,string filename)
  {
   ulong s_time=GetMicrosecondCount();

//--- hash map of <pos_id, deal_in_ticket> pairs
   CHashMap<ulong,ulong>HashMap;

//--- CSortedMap: <key>close_day, <value>CDaySummary
//--- Represents a collection of key/value pairs that are sorted on the key.
   CSortedMap<datetime,CDaySummary *>table;

//--- variable to hold the current deal object
   CDealInfo deal;

   double allVols = 0;
   double allProf = 0;
   double allComm = 0;
   double allSwap = 0;
   int    allCnts = 0;
   double allNetP = 0;

//--- request the history of deals and orders for the specified period
   if(!HistorySelect(from_date,to_date))
     {
      Alert("HistorySelect failed!");
      return(false);
     }

//--- now process the list of received deals for the specified period
   int deals=HistoryDealsTotal();
   for(int i=0; i<deals && !IsStopped(); i++)
     {
      if(deal.SelectByIndex(i))
        {
         if(deal.DealType()==DEAL_TYPE_BUY || deal.DealType()==DEAL_TYPE_SELL)
           {
            //--- If entry deal ticket, add to the hash table
            if(deal.Entry()==DEAL_ENTRY_IN)
              {
               HashMap.Add(deal.PositionId(),deal.Ticket());
              }
            //--- If exit deal ticket
            else if(deal.Entry()==DEAL_ENTRY_OUT || deal.Entry()==DEAL_ENTRY_OUT_BY)
              {
               datetime time              = deal.Time();
               double   volume            = deal.Volume();
               double   profit            = deal.Profit();
               double   commission        = deal.Commission();
               double   swap              = deal.Swap();

               //--- entry deal commission -------------------
               ulong ticket_in;
               if(HashMap.TryGetValue(deal.PositionId(),ticket_in))
                 {
                  double open_volume = HistoryDealGetDouble(ticket_in, DEAL_VOLUME);
                  double open_commis = HistoryDealGetDouble(ticket_in, DEAL_COMMISSION);
                  commission += open_commis * (volume/open_volume);
                 }

               //--- get close_day start from the close time
               int secs=PeriodSeconds(PERIOD_D1);
               datetime close_day=(time/secs)*secs;

               //---------- GroupBy --------------//
               //--- CSortedMap: <key>close_day, <value>CDaySummary
               CDaySummary *summary=NULL;

               if(!table.TryGetValue(close_day,summary))
                 {
                  // add new <key, value> pair
                  summary=new CDaySummary();
                  summary.Update(volume,profit,commission,swap);
                  table.Add(close_day,summary);
                 }
               else
                 {
                  summary.Update(volume,profit,commission,swap);
                 }

               //--- sums
               allVols += volume;
               allProf += profit;
               allComm += commission;
               allSwap += swap;
               allCnts += 1;
               allNetP += profit + commission + swap;
              }
           }
        }
     }

   int handle;

//---------- SIZE --------------//
   if(table.Count()>0)
     {
      ResetLastError();
      //--- use FILE_ANSI to correctly display .csv files within Excel 2013 and above.
      handle=FileOpen(filename,FILE_WRITE|FILE_SHARE_READ|FILE_CSV|FILE_ANSI,',');
      if(handle==INVALID_HANDLE)
        {
         Alert("File open failed, error ",_LastError);
         return(false);
        }

      FileWrite(handle,"Date","Trades","Volume","Commission","Swap","Profit","NetProfit");
     }

   else
      return(false);

//---------- FOR --------------//
   datetime        keys[];
   CDaySummary    *values[];
   int count = table.CopyTo(keys, values);
   for(int i = 0; i < count; i++)
     {
      FileWrite(handle,
                /* Date        */ TimeToString(keys[i],TIME_DATE),
                /* Trades      */ IntegerToString(values[i].count),
                /* Volume      */ DoubleToString(values[i].vols, 2),
                /* Commission  */ DoubleToString(values[i].comm, 2),
                /* Swap        */ DoubleToString(values[i].swap, 2),
                /* Profit      */ DoubleToString(values[i].prof, 2),
                /* NetProfit   */ DoubleToString(values[i].prof + values[i].swap + values[i].comm, 2)
               );

      //--- release object pointers to avoid memory leaks
      if(CheckPointer(values[i])==POINTER_DYNAMIC)
         delete values[i];
     }

//--- clear and delete all values from map
   table.Clear();

//--- footer
   FileWrite(handle,"");
   FileWrite(handle,"Total",IntegerToString(allCnts),DoubleToString(allVols,2),DoubleToString(allComm,2),DoubleToString(allSwap,2),DoubleToString(allProf,2),DoubleToString(allNetP,2));
//---
   PrintFormat("Time elapsed = %I64u microsec",GetMicrosecondCount()-s_time);
   FileClose(handle);
//---
   return(true);
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
