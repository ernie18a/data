//+------------------------------------------------------------------+
//|                                    Export_Summary_By_Symbols.mq4 |
//|                                        Copyright © 2018, Amr Ali |
//|                             https://www.mql5.com/en/users/amrali |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Amr Ali"
#property link      "https://www.mql5.com/en/users/amrali"
#property version   "1.000"
#property description "The script exports summary of closed trades grouped by each currency pair to .csv file"
#property strict
#property script_show_inputs

#include <Arrays\ArrayObj.mqh>

//--- input variables
input  datetime InpStartDate = 0;                        // Start date
input  datetime InpEndDate   = D'2038.01.01';            // End date
input  string   InpFileName  = "summary_by_symbols.csv"; // Filename
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
/// Class CSymbolSummary for grouping closed trades by symbol in ArrayObj.
class CSymbolSummary : public CObject
  {
public:
   string            symbol;
   int               count;
   double            vols;
   double            prof;
   double            comm;
   double            swap;
public:
                     CSymbolSummary() : count(0),vols(0),prof(0),comm(0),swap(0) {   }
                    ~CSymbolSummary() {   }
   void              Update(double v,double p,double c,double s) { vols+=v; prof+=p; comm+=c; swap+=s; count+=1; }
public:
   //--- method of comparing the objects
   virtual int       Compare(const CObject *node,const int mode=0) const
     {
      const CSymbolSummary *obj=dynamic_cast<const CSymbolSummary *>(node);
      return(StringCompare(this.symbol,obj.symbol));  // 1, 0, -1
     }
  };
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
   if(MQLInfoInteger(MQL_DLLS_ALLOWED)==false)
     {
      Alert("Error: DLL imports is not allowed in the program settings.");
      return;
     }

   if(InpStartDate>InpEndDate)
     {
      Alert("Error: The start date must be earlier than the end date");
      return;
     }

   if(ExportSummaryBySymbol(InpStartDate,InpEndDate,InpFileName))
     {
      //--- open the .csv file with the associated Windows program
      Execute(TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\"+InpFileName);

      Print("History is exported to ",TerminalInfoString(TERMINAL_DATA_PATH)+"\\MQL4\\Files\\"+InpFileName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ExportSummaryBySymbol(datetime from_date,datetime to_date,string filename)
  {
   int oht=OrdersHistoryTotal();

   if(oht==0)
     {
      Alert("Error: history is not downloaded (not connected).");
      return(false);
     }

   double allVols = 0;
   double allProf = 0;
   double allComm = 0;
   double allSwap = 0;
   int    allCnts = 0;
   double allNetP = 0;

//--- Sorted array of CSymbolSummary objects
   CArrayObj arr;
   arr.Sort(MODE_ASCEND);

//--- now process the list of history orders
   for(int i=0; i<oht && !IsStopped(); i++)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) && OrderType()<=OP_SELL
         && OrderCloseTime()>=from_date && OrderCloseTime()<to_date)
        {
         string   symbol            = OrderSymbol();
         double   volume            = OrderLots();
         double   profit            = OrderProfit();
         double   commission        = OrderCommission();
         double   swap              = OrderSwap();

         //---------- GroupBy --------------//
         CSymbolSummary *summary=NULL;
         summary=new CSymbolSummary();
         summary.symbol=symbol;
         int index=arr.Search(summary);

         if(index==-1)
           {
            // add new array element
            summary.Update(volume,profit,commission,swap);
            arr.InsertSort(summary);
           }
         else
           {
            delete(summary);
            summary=arr.At(index);
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

   int handle;

//---------- SIZE --------------//
   if(arr.Total()>0)
     {
      ResetLastError();
      //--- use FILE_ANSI to correctly display .csv files within Excel 2013 and above.
      handle=FileOpen(filename,FILE_WRITE|FILE_SHARE_READ|FILE_CSV|FILE_ANSI,',');
      if(handle==INVALID_HANDLE)
        {
         Alert("File open failed, error ",_LastError);
         return(false);
        }

      FileWrite(handle,"Symbol","Trades","Volume","Profit","Swap","Commission","NetProfit");
     }

   else
      return(false);

//---------- FOR --------------//
   CSymbolSummary *summary=NULL;
   int count = arr.Total();
   for(int i = 0; i < count; i++)
     {
      summary=arr.At(i);
      FileWrite(handle,
                /* Symbol      */ summary.symbol,
                /* Trades      */ IntegerToString(summary.count),
                /* Volume      */ DoubleToString(summary.vols, 2),
                /* Profit      */ DoubleToString(summary.prof, 2),
                /* Swap        */ DoubleToString(summary.swap, 2),
                /* Commission  */ DoubleToString(summary.comm, 2),
                /* NetProfit   */ DoubleToString(summary.prof + summary.swap + summary.comm, 2)
                );
     }

//--- complete cleaning of the array with the release of memory
   arr.Shutdown();

//--- footer
   FileWrite(handle,"");
   FileWrite(handle,"Total",IntegerToString(allCnts),DoubleToString(allVols,2),DoubleToString(allProf,2),DoubleToString(allSwap,2),DoubleToString(allComm,2),DoubleToString(allNetP,2));
//---
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
