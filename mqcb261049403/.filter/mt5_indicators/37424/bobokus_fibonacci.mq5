//+------------------------------------------------------------------+
//|                                                      DR Fibo.mq5 |
//|                                     Copyright © 2020, Dark Ryd3r |
//|                                        https://www.darkryd3r.com |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Dark Ryd3r"
#property link      "https://twitter.com/DarkRyd3r"
#property version   "1.00"
#property description "Bobokus Fibonacci Retracement"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots   0
//--- input parameters
//---
bool     hideit   = false;
string   m_fibo_name    = "BobokusFibo";
datetime m_prev_bars    = 0;           // "0" -> D'1970.01.01 00:00';
MqlRates m_rates_W1[];                 // rates W1

input ENUM_TIMEFRAMES TimeFrame=PERIOD_D1; //Chart period
input string               Fib_Levels=      "0.382, 0.5, 0.618";         //Add any other levels seperated by commas



color Levelclr = clrCornflowerBlue;
ENUM_LINE_STYLE LevelStyle = STYLE_DASHDOT;
//RESEARCH ON 0.707 and 0.578

double levels_values[];                 // Array of level values
string levels_descriptions[];      // Array of level descriptions
string level_names = "Short Resistance %$,Pivot %$,Long Support %$";      // Array of level descriptions
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   if(Period()>=TimeFrame) {
      hideit=true;
      return(INIT_SUCCEEDED);
   }

   ArraySetAsSeries(m_rates_W1,true);
   IndicatorSetString(INDICATOR_SHORTNAME,"Bobokus_Fibonacci");
   ChartRedraw();
//---
   return(INIT_SUCCEEDED);
}
//+------------------------------------------------------------------+
//| Indicator deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//---
   ObjectDelete(0,m_fibo_name);
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
                const int &spread[]) {
   if(hideit)
      return(0);
   if(rates_total<10)
      return(0);
//---
   int start_pos=0,count=3;
   if(CopyRates(Symbol(),TimeFrame,start_pos,count,m_rates_W1)!=count)
      return(rates_total);
//--- we work only at the time of the birth of new bar
   datetime time_0=m_rates_W1[0].time;
   if(time_0==m_prev_bars)
      return(rates_total);
   m_prev_bars=time_0;
//---
   MqlRates m_rates_M1[];
   ArraySetAsSeries(m_rates_M1,true);
   int count_M1=CopyRates(Symbol(),PERIOD_M1,m_rates_W1[1].time,m_rates_W1[0].time,m_rates_M1);
   if(count_M1<2) {
      time_0=0;
      return(rates_total);
   }
   datetime time_high=0, time_low=0;
   double price_high=DBL_MIN, price_low=DBL_MAX;
   for(int i=0; i<count_M1; i++) {
      if(m_rates_M1[i].high>price_high) {
         time_high=m_rates_M1[i].time;
         price_high=m_rates_M1[i].high;
      }
      if(m_rates_M1[i].low<price_low) {
         time_low=m_rates_M1[i].time;
         price_low=m_rates_M1[i].low;
      }
   }
//---
   double   fibo_price_start  = (time_high<time_low)?price_high:price_low;
   double   fibo_price_end    = (time_high<time_low)?price_low:price_high;
   datetime fibo_time_start   = (time_high<time_low)?time_high:time_low;
   datetime fibo_time_end     = (time_high<time_low)?time_low:time_high;
//---
   if(ObjectFind(0,m_fibo_name)<0 ) {
      FiboLevelsCreate(0,m_fibo_name,0,fibo_time_start,fibo_price_start,fibo_time_end,fibo_price_end);
      SetFiboLevels(m_fibo_name,levels_values);
      SetFiboDescriptions(m_fibo_name, levels_descriptions);
   } else {
      FiboLevelsPointChange(0,m_fibo_name,0,fibo_time_start,fibo_price_start);
      FiboLevelsPointChange(0,m_fibo_name,1,fibo_time_end,fibo_price_end);
   }

//fib set


//--- return value of prev_calculated for next call
   ChartRedraw();
   return(rates_total);
}
//+------------------------------------------------------------------+
//| Create Fibonacci Retracement by the given coordinates            |
//+------------------------------------------------------------------+
bool FiboLevelsCreate(const long            chart_ID=0,        // chart's ID
                      const string          name="Fibo_Bobokus", // object name
                      const int             sub_window=0,      // subwindow index
                      datetime              time1=0,           // first point time
                      double                price1=0,          // first point price
                      datetime              time2=0,           // second point time
                      double                price2=0,          // second point price
                      const color           clr=clrSnow, // object color
                      const ENUM_LINE_STYLE style=STYLE_DASHDOT, // object line style
                      const int             width=2,           // object line width
                      const bool            back=false,        // in the background
                      const bool            selection=true,   // highlight to move
                      const bool            ray_left=false,    // object's continuation to the left
                      const bool            ray_right=true,    // object's continuation to the right
                      const bool            hidden=true,       // hidden in the object list
                      const long            z_order=0) {       // priority for mouse click
//--- set anchor points' coordinates if they are not set
   ChangeFiboLevelsEmptyPoints(time1,price1,time2,price2);
   StringToDoubleArray(Fib_Levels,levels_values);
   StringToStringArray(level_names,levels_descriptions);
//--- reset the error value
   ResetLastError();
//--- Create Fibonacci Retracement by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_FIBO,sub_window,time1,price1,time2,price2)) {
      Print(__FUNCTION__,
            ": failed to create \"Fibonacci Retracement\"! Error code = ",GetLastError());
      return(false);
   }

//--- set color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
   long levels=ObjectGetInteger(chart_ID,name,OBJPROP_LEVELS);
   for(int i=0; i<levels; i++)

      ObjectSetInteger(chart_ID,name,OBJPROP_LEVELCOLOR,i,clr);
//--- set line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set line width
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the channel for moving
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the object's display to the left
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
//--- enable (true) or disable (false) the mode of continuation of the object's display to the right
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
//| Check the values of Fibonacci Retracement anchor points and set  |
//| default values for empty ones                                    |
//+------------------------------------------------------------------+
void ChangeFiboLevelsEmptyPoints(datetime &time1,double &price1,
                                 datetime &time2,double &price2) {
//--- if the second point's time is not set, it will be on the current bar
   if(!time2)
      time2=TimeCurrent();
//--- if the second point's price is not set, it will have Bid value
   if(!price2)
      price2=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the first point's time is not set, it is located 9 bars left from the second one
   if(!time1) {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- set the first point 9 bars left from the second one
      time1=temp[0];
   }
//--- if the first point's price is not set, move it 200 points below the second one
   if(!price1)
      price1=price2-200*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
}


//+------------------------------------------------------------------+
//| Move Fibonacci Retracement anchor point                          |
//+------------------------------------------------------------------+
bool FiboLevelsPointChange(const long   chart_ID=0,        // chart's ID
                           const string name="Fibo_W1", // object name
                           const int    point_index=0,     // anchor point index
                           datetime     time=0,            // anchor point time coordinate
                           double       price=0) {         // anchor point price coordinate
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time=TimeCurrent();
   if(!price)
      price=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move the anchor point
   if(!ObjectMove(chart_ID,name,point_index,time,price)) {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ",GetLastError());
      return(false);
   }
//--- successful execution
   return(true);
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StringToDoubleArray (
   string _haystack,            // source string
   double &_result[],           // array of results
   const string _delimiter=","  // separator
) {
//---
   string haystack_pieces[];  // Array of string fragments
   int pieces_count,          // Number of fragments
       i;                     // Counter
   string current_number="";  // The current string fragment (estimated number)

//--- Split the string into fragments
   pieces_count=StringSplit(_haystack,StringGetCharacter(_delimiter,0),haystack_pieces);
//--- Convert
   if(pieces_count>0) {
      ArrayResize(_result,pieces_count);
      for(i=0; i<pieces_count; i++) {
         StringTrimLeft(haystack_pieces[i]);
         StringTrimRight(haystack_pieces[i]);
         _result[i]=StringToDouble(haystack_pieces[i]);
      }
   } else {
      ArrayResize(_result,1);
      _result[0]=0;
   }
}
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void StringToStringArray (
   string _haystack,            // source string
   string &_result[],           // array of results
   const string _delimiter=","  // separator
) {
//---
   string haystack_pieces[];  // Array of string fragments
   int pieces_count,          // Number of fragments
       i;                     // Counter
   string current_number="";  // The current string fragment (estimated number)

//--- Split the string into fragments
   pieces_count=StringSplit(_haystack,StringGetCharacter(_delimiter,0),haystack_pieces);
//--- Convert
   if(pieces_count>0) {
      ArrayResize(_result,pieces_count);
      for(i=0; i<pieces_count; i++) {
         StringTrimLeft(haystack_pieces[i]);
         StringTrimRight(haystack_pieces[i]);
         _result[i]=haystack_pieces[i];
      }
   } else {
      ArrayResize(_result,1);
      _result[0]=NULL;
   }
}

//+------------------------------------------------------------------+
//| Set number of levels and their parameters                        |
//+------------------------------------------------------------------+
void SetFiboLevels(
   string _object_name,                      // Object name
   const double &_levels_values[]            // Array of levels
) {
   int i,                                      // Current level counter
       levels_count=ArraySize(_levels_values); // Total number of levels

//--- Proceed with the implementation

//--- Set the quantity property for the current object
   ObjectSetInteger(0,_object_name,OBJPROP_LEVELS,levels_count);
//--- Set value, color and style for each level.
   for(i=0; i<levels_count; i++) {
      ObjectSetDouble(0,_object_name,OBJPROP_LEVELVALUE,i,_levels_values[i]);
      ObjectSetInteger(0,_object_name,OBJPROP_LEVELCOLOR,i,Levelclr);
      ObjectSetInteger(0,_object_name,OBJPROP_LEVELSTYLE,i,LevelStyle);
   }
//--- Redraw the chart before finishing
   ChartRedraw(0);
}

//+------------------------------------------------------------------+
//| Sets descriptions of levels in any Fibonacci object              |
//|    _object_name - the name of the Fibonacci object               |
//|    _levels_descriptions[] - array of level descriptions          |
//+------------------------------------------------------------------+
void SetFiboDescriptions(
   string _object_name,                  // Object name
   const string &_levels_descriptions[]  // Array of descriptions
) {
   int i,                                                                  // Current level counter
       levels_count=(int)ObjectGetInteger(0,_object_name,OBJPROP_LEVELS),  // Real number of levels
       array_size=ArraySize(_levels_descriptions);                         // Number of received descriptions
//Print("LC ", array_size);
//--- Loop  through all levels
   for(i=0; i<levels_count; i++) {
      string Cuttext = DoubleToString(levels_values[i]);
      if(array_size>0 && i<array_size) { // Choose a description from the array
         //--- and write it to the level
         ObjectSetString(0,_object_name,OBJPROP_LEVELTEXT,i,_levels_descriptions[i]);
      } else { // If the descriptions are not enough...
         //ObjectSetString(0,_object_name,OBJPROP_LEVELTEXT,i,""); // ...leave the description empty
         ObjectSetString(0,_object_name,OBJPROP_LEVELTEXT,i,StringSubstr(Cuttext,0,StringLen(Cuttext)-5) + " %$"); // ...leave the description empty
      }
   }
//--- Redraw the chart before finishing
   ChartRedraw(0);
}
//+------------------------------------------------------------------+
