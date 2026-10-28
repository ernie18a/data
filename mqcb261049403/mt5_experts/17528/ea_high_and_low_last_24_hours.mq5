//+------------------------------------------------------------------+
//|                                EA High and Low last 24 hours.mq5 |
//|                              Copyright © 2017, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property description "Example: gets the history data of highest and lowest bar prices in the last 24 hours"
#property version   "1.000"
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   Comment("");
   LinesDelete(0);
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---

  }
//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
   if(id==CHARTEVENT_KEYDOWN)
     {
      if(lparam==72) // kew "H"
        {
         datetime stop_time   = TimeCurrent();              // stop date and time 
         datetime start_time  = stop_time-24*60*60;         // start date and time  
         //---
         double High[];
         ResetLastError();
         if(CopyHigh(Symbol(),Period(),start_time,stop_time,High)==-1)
           {
            Print("Error CopyHigh #",GetLastError());
            return;
           }
         int position_max=ArrayMaximum(High);
         double price_max=High[position_max];

         Comment("\n",
                 "start date: ",TimeToString(start_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),"\n",
                 "to","\n",
                 "stop date: ",TimeToString(stop_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),"\n",
                 "\n",
                 "highest bar prices in the last 24 hours: ",DoubleToString(price_max,Digits()));

         HLineCreate(0,"HLine",0,price_max);
         VLineCreate(0,"VLine",0,start_time);
        }
      if(lparam==76) // kew "L"
        {
         datetime stop_time   = TimeCurrent();              // stop date and time 
         datetime start_time  = stop_time-24*60*60;         // start date and time  
         //---
         double Low[];
         ResetLastError();
         if(CopyLow(Symbol(),Period(),start_time,stop_time,Low)==-1)
           {
            Print("Error CopyHigh #",GetLastError());
            return;
           }
         int position_min=ArrayMinimum(Low);
         double price_min=Low[position_min];

         Comment("\n",
                 "start date: ",TimeToString(start_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),"\n",
                 "to","\n",
                 "stop date: ",TimeToString(stop_time,TIME_DATE|TIME_MINUTES|TIME_SECONDS),"\n",
                 "\n",
                 "lowest bar prices in the last 24 hours: ",DoubleToString(price_min,Digits()));

         HLineCreate(0,"HLine",0,price_min);
         VLineCreate(0,"VLine",0,start_time);
        }
     }
  }
//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long   chart_ID=0,    // chart's ID 
                 const string name="HLine",  // line name 
                 const int    sub_window=0,  // subwindow index 
                 double       price=0)       // line price 
  {
   if(ObjectFind(chart_ID,name)>=0)
     {
      return(HLineMove(chart_ID,name,price));
     }
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long     chart_ID=0,    // chart's ID 
               const string   name="HLine",  // line name 
               double         price=0)       // line price 
  {
//--- reset the error value 
   ResetLastError();
//--- move a horizontal line 
   if(!ObjectMove(chart_ID,name,0,0,price))
     {
      Print(__FUNCTION__,
            ": failed to move the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Create the vertical line                                         | 
//+------------------------------------------------------------------+ 
bool VLineCreate(const long   chart_ID=0,    // chart's ID 
                 const string name="VLine",  // line name 
                 const int    sub_window=0,  // subwindow index 
                 datetime     time=0)        // line time 
  {
   if(ObjectFind(chart_ID,name)>=0)
     {
      return(VLineMove(chart_ID,name,time));
     }
//--- reset the error value 
   ResetLastError();
//--- create a vertical line 
   if(!ObjectCreate(chart_ID,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__,
            ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move the vertical line                                           | 
//+------------------------------------------------------------------+ 
bool VLineMove(const long     chart_ID=0,    // chart's ID 
               const string   name="VLine",  // line name 
               datetime       time=0)        // line time 
  {
//--- reset the error value 
   ResetLastError();
//--- move the vertical line 
   if(!ObjectMove(chart_ID,name,0,time,0))
     {
      Print(__FUNCTION__,
            ": failed to move the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete the vertical line and the horizontal line                 | 
//+------------------------------------------------------------------+ 
bool LinesDelete(const long   chart_ID=0) // chart's ID 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the horizontal line 
   if(!ObjectDelete(chart_ID,"HLine"))
     {
      Print(__FUNCTION__,
            ": failed to delete the horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- reset the error value 
   ResetLastError();
//--- delete the vertical line 
   if(!ObjectDelete(chart_ID,"VLine"))
     {
      Print(__FUNCTION__,
            ": failed to delete the vertical line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+
