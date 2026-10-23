//+------------------------------------------------------------------+
//|                                         AMA three timeframes.mq5 |
//|                              Copyright © 2018, Vladimir Karputov |
//|                                           http://wmua.ru/slesar/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2018, Vladimir Karputov"
#property link      "http://wmua.ru/slesar/"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//---
enum HLineOrArrow
  {
   hline       = 0,  // HLine
   arrow       = 1,  // Arrow
   hline_arrow = 2,  // HLine and Arrow
  };
//+------------------------------------------------------------------+ 
//| Enumeration of the methods of handle creation                    | 
//+------------------------------------------------------------------+ 
//--- input parameters 
input HLineOrArrow         InpHLineOrArrow   = hline_arrow; // Use object
input ENUM_TIMEFRAMES      InpTimeFrames_1   = PERIOD_H1;   // TimeFrames 1st AMA
input ENUM_TIMEFRAMES      InpTimeFrames_2   = PERIOD_H4;   // TimeFrames 2nd AMA
input ENUM_TIMEFRAMES      InpTimeFrames_3   = PERIOD_D1;   // TimeFrames 3nd AMA
input int                  ama_period        = 15;          // period of calculation 
input int                  fast_ma_period    = 2;           // period of fast MA 
input int                  slow_ma_period    = 30;          // period of slow MA 
input int                  ama_shift         = 0;           // horizontal shift 
input ENUM_APPLIED_PRICE   applied_price     = PRICE_CLOSE; // type of price 
//--- variables for storing the handle of the iAMA indicator 
int    handle_1;
int    handle_2;
int    handle_3;
//--- name of the indicator on a chart 
string short_name;
string name_1="";
string name_2="";
string name_3="";
//+------------------------------------------------------------------+ 
//| Custom indicator initialization function                         | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
//--- create handle of the indicator 
   handle_1=iAMA(Symbol(),InpTimeFrames_1,ama_period,fast_ma_period,slow_ma_period,ama_shift,applied_price);
//--- if the handle is not created 
   if(handle_1==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(InpTimeFrames_1),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator 
   handle_2=iAMA(Symbol(),InpTimeFrames_2,ama_period,fast_ma_period,slow_ma_period,ama_shift,applied_price);
//--- if the handle is not created 
   if(handle_2==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(InpTimeFrames_2),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- create handle of the indicator 
   handle_3=iAMA(Symbol(),InpTimeFrames_3,ama_period,fast_ma_period,slow_ma_period,ama_shift,applied_price);
//--- if the handle is not created 
   if(handle_3==INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code 
      PrintFormat("Failed to create handle of the iAMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(InpTimeFrames_3),
                  GetLastError());
      //--- the indicator is stopped early 
      return(INIT_FAILED);
     }
//--- show the symbol/timeframe the Adaptive Moving Average indicator is calculated for 
   short_name=StringFormat("AMA three timeframes (%d,%d,%d)",ama_period,fast_ma_period,slow_ma_period);
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
//---
   name_1=StringSubstr(EnumToString(InpTimeFrames_1),7);
   if(InpHLineOrArrow==hline || InpHLineOrArrow==hline_arrow)
      if(!HLineCreate(0,"HLine "+name_1,0,0,clrRed,STYLE_DASH))
         return(INIT_FAILED);
   if(InpHLineOrArrow==arrow || InpHLineOrArrow==hline_arrow)
      if(!ArrowRightPriceCreate(0,"Arrow "+name_1,0,0,0,clrRed))
         return(INIT_FAILED);
//---
   name_2=StringSubstr(EnumToString(InpTimeFrames_2),7);
   if(InpHLineOrArrow==hline || InpHLineOrArrow==hline_arrow)
      if(!HLineCreate(0,"HLine "+name_2,0,0,clrGold,STYLE_DASH))
         return(INIT_FAILED);
   if(InpHLineOrArrow==arrow || InpHLineOrArrow==hline_arrow)
      if(!ArrowRightPriceCreate(0,"Arrow "+name_2,0,0,0,clrGold))
         return(INIT_FAILED);
//---
   name_3=StringSubstr(EnumToString(InpTimeFrames_3),7);
   if(InpHLineOrArrow==hline || InpHLineOrArrow==hline_arrow)
      if(!HLineCreate(0,"HLine "+name_3,0,0,clrBlueViolet,STYLE_DASH))
         return(INIT_FAILED);
   if(InpHLineOrArrow==arrow || InpHLineOrArrow==hline_arrow)
      if(!ArrowRightPriceCreate(0,"Arrow "+name_3,0,0,0,clrBlueViolet))
         return(INIT_FAILED);
//--- normal initialization of the indicator     
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+ 
//| Indicator deinitialization function                              | 
//+------------------------------------------------------------------+ 
void OnDeinit(const int reason)
  {
//--- 
   if(InpHLineOrArrow==hline || InpHLineOrArrow==hline_arrow)
     {
      HLineDelete(0,"HLine "+name_1);
      HLineDelete(0,"HLine "+name_2);
      HLineDelete(0,"HLine "+name_3);
     }
   if(InpHLineOrArrow==arrow || InpHLineOrArrow==hline_arrow)
     {
      ArrowRightPriceDelete(0,"Arrow "+name_1);
      ArrowRightPriceDelete(0,"Arrow "+name_2);
      ArrowRightPriceDelete(0,"Arrow "+name_3);
     }
  }
//+------------------------------------------------------------------+ 
//| Custom indicator iteration function                              | 
//+------------------------------------------------------------------+ 
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
   double iAMABuffer_1[];
   double iAMABuffer_2[];
   double iAMABuffer_3[];
   if(!FillArrayFromBuffer(iAMABuffer_1,ama_shift,handle_1,1))
      return(0);
   if(!FillArrayFromBuffer(iAMABuffer_2,ama_shift,handle_2,1))
      return(0);
   if(!FillArrayFromBuffer(iAMABuffer_3,ama_shift,handle_3,1))
      return(0);
//---
   if(InpHLineOrArrow==hline || InpHLineOrArrow==hline_arrow)
     {
      HLineMove(0,"HLine "+name_1,iAMABuffer_1[0]);
      HLineMove(0,"HLine "+name_2,iAMABuffer_2[0]);
      HLineMove(0,"HLine "+name_3,iAMABuffer_3[0]);
     }
   if(InpHLineOrArrow==arrow || InpHLineOrArrow==hline_arrow)
     {
      ArrowRightPriceMove(0,"Arrow "+name_1,time[rates_total-1],iAMABuffer_1[0]);
      ArrowRightPriceMove(0,"Arrow "+name_2,time[rates_total-1],iAMABuffer_2[0]);
      ArrowRightPriceMove(0,"Arrow "+name_3,time[rates_total-1],iAMABuffer_3[0]);
     }
//--- return the prev_calculated value for the next call 
   return(rates_total);
  }
//+------------------------------------------------------------------+ 
//| Filling indicator buffer from the iAMA indicator                 | 
//+------------------------------------------------------------------+ 
bool FillArrayFromBuffer(double &ama_buffer[],  // indicator buffer of the AMA line 
                         int a_shift,           // shift of the AMA line 
                         int ind_handle,        // handle of the iAMA indicator 
                         int amount             // number of copied values 
                         )
  {
//--- reset error code 
   ResetLastError();
//--- fill a part of the iAMABuffer array with values from the indicator buffer that has 0 index 
   if(CopyBuffer(ind_handle,0,-a_shift,amount,ama_buffer)<0)
     {
      //--- if the copying fails, tell the error code 
      PrintFormat("Failed to copy data from the iAMA indicator, error code %d",GetLastError());
      //--- quit with zero result - it means that the indicator is considered as not calculated 
      return(false);
     }
//--- everything is fine 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Create the horizontal line                                       | 
//+------------------------------------------------------------------+ 
bool HLineCreate(const long            chart_ID=0,        // chart's ID 
                 const string          name="HLine",      // line name 
                 const int             sub_window=0,      // subwindow index 
                 double                price=0,           // line price 
                 const color           clr=clrRed,        // line color 
                 const ENUM_LINE_STYLE style=STYLE_SOLID, // line style 
                 const int             width=1,           // line width 
                 const bool            back=false,        // in the background 
                 const bool            selection=false,   // highlight to move 
                 const bool            hidden=true,       // hidden in the object list 
                 const long            z_order=0)         // priority for mouse click 
  {
//--- if the price is not set, set it at the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- create a horizontal line 
   if(!ObjectCreate(chart_ID,name,OBJ_HLINE,sub_window,0,price))
     {
      Print(__FUNCTION__,
            ": failed to create a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- set line color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set line display style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the line by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move horizontal line                                             | 
//+------------------------------------------------------------------+ 
bool HLineMove(const long   chart_ID=0,   // chart's ID 
               const string name="HLine", // line name 
               double       price=0)      // line price 
  {
//--- if the line price is not set, move it to the current Bid price level 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
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
//| Delete a horizontal line                                         | 
//+------------------------------------------------------------------+ 
bool HLineDelete(const long   chart_ID=0,   // chart's ID 
                 const string name="HLine") // line name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete a horizontal line 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete a horizontal line! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Create the right price label                                     | 
//+------------------------------------------------------------------+ 
bool ArrowRightPriceCreate(const long            chart_ID=0,        // chart's ID 
                           const string          name="RightPrice", // price label name 
                           const int             sub_window=0,      // subwindow index 
                           datetime              time=0,            // anchor point time 
                           double                price=0,           // anchor point price 
                           const color           clr=clrRed,        // price label color 
                           const ENUM_LINE_STYLE style=STYLE_SOLID, // border line style 
                           const int             width=1,           // price label size 
                           const bool            back=false,        // in the background 
                           const bool            selection=false,   // highlight to move 
                           const bool            hidden=true,       // hidden in the object list 
                           const long            z_order=0)         // priority for mouse click 
  {
//--- set anchor point coordinates if they are not set 
   ChangeArrowEmptyPoint(time,price);
//--- reset the error value 
   ResetLastError();
//--- create a price label 
   if(!ObjectCreate(chart_ID,name,OBJ_ARROW_RIGHT_PRICE,sub_window,time,price))
     {
      Print(__FUNCTION__,
            ": failed to create the right price label! Error code = ",GetLastError());
      return(false);
     }
//--- set the label color 
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the border line style 
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set the label size 
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true) 
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of moving the label by mouse 
//--- when creating a graphical object using ObjectCreate function, the object cannot be 
//--- highlighted and moved by default. Inside this method, selection parameter 
//--- is true by default making it possible to highlight and move the object 
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- hide (true) or display (false) graphical object name in the object list 
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart 
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Move the anchor point                                            | 
//+------------------------------------------------------------------+ 
bool ArrowRightPriceMove(const long   chart_ID=0,        // chart's ID 
                         const string name="RightPrice", // label name 
                         datetime     time=0,            // anchor point time coordinate 
                         double       price=0)           // anchor point price coordinate 
  {
//--- if point position is not set, move it to the current bar having Bid price 
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value 
   ResetLastError();
//--- move the anchor point 
   if(!ObjectMove(chart_ID,name,0,time,price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Delete the right price label from the chart                      | 
//+------------------------------------------------------------------+ 
bool ArrowRightPriceDelete(const long   chart_ID=0,        // chart's ID 
                           const string name="RightPrice") // label name 
  {
//--- reset the error value 
   ResetLastError();
//--- delete the label 
   if(!ObjectDelete(chart_ID,name))
     {
      Print(__FUNCTION__,
            ": failed to delete the right price label! Error code = ",GetLastError());
      return(false);
     }
//--- successful execution 
   return(true);
  }
//+------------------------------------------------------------------+ 
//| Check anchor point values and set default values                 | 
//| for empty ones                                                   | 
//+------------------------------------------------------------------+ 
void ChangeArrowEmptyPoint(datetime &time,double &price)
  {
//--- if the point's time is not set, it will be on the current bar 
   if(!time)
      time=TimeCurrent();
//--- if the point's price is not set, it will have Bid value 
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
  }
//+------------------------------------------------------------------+
