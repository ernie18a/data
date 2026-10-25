//+------------------------------------------------------------------+
//|                                              Move Trand line.mq5 |
//|                        Copyright 2017, MetaQuotes Software Corp. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2017, MetaQuotes Software Corp."
#property link      "https://forge.mql5.io"
#property version   "1.004"
#property description "Move trend lines that were previously on the chart"
#property script_show_inputs
//--- input parameters
input int      shift=-90;                       // price shift
input datetime new_date=D'2017.04.20 14:00:37'; // new date
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   long  chart_id=0;       // Chart identifier. 0 means the current chart
   int   sub_window=0;     // Number of the chart subwindow. 0 means the main chart window ...
   int   type=OBJ_TREND;   // Type of the object. The value can be one of the values of the ENUM_OBJECT enumeration ...

   int  total=ObjectsTotal(chart_id,sub_window,type);

   for(int i=0;i<total;i++)
     {
      string name=ObjectName(chart_id,i,sub_window,type);
      double   new_price_0 =           ObjectGetDouble(chart_id,name,OBJPROP_PRICE,0);
      long     shift_date_0= new_date- ObjectGetInteger(chart_id,name,OBJPROP_TIME,0);
      long     date_1      =           ObjectGetInteger(chart_id,name,OBJPROP_TIME,1);
      //double   price_1     =           ObjectGetDouble(chart_id,name,OBJPROP_PRICE,1);

      TrendPointChange(chart_id,name,0,new_date,new_price_0+shift*Point());
      TrendPointChange(chart_id,name,1,date_1+shift_date_0,new_price_0+shift*Point());
     }
  }
//+------------------------------------------------------------------+ 
//| Move trend line anchor point                                     | 
//+------------------------------------------------------------------+ 
bool TrendPointChange(const long   chart_ID=0,       // chart's ID 
                      const string name="TrendLine", // line name 
                      const int    point_index=0,    // anchor point index 
                      datetime     time=0,           // anchor point time coordinate 
                      double       price=0)          // anchor point price coordinate 
  {
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move trend line's anchor point 
   if(!ObjectMove(chart_ID,name,point_index,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
