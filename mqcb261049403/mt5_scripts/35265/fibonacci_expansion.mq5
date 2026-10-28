//--- description
#property copyright "Copyright © 2021, Dark Ryd3r"
#property link      "https://twitter.com/DarkRyd3r"
#property version   "1.00"
#property description "Fibonacci Expansion with Custom Values"

#property script_show_inputs

input string               Fib_Levels=      "1.618,2.618,3.618,4.236";      //Enter Custom Fibonacci Level seperated by commas

double levels_values[];                 // Array of level values
string levels_descriptions[] = {};      // Array of level descriptions


//--- input parameters of the script 
string          InpName="FiboExpansion";   // Object name 
int             InpDate1=10;               // 1 st point's date, % 
int             InpPrice1=55;              // 1 st point's price, % 
int             InpDate2=30;               // 2 nd point's date, % 
int             InpPrice2=10;              // 2 nd point's price, % 
int             InpDate3=80;               // 3 rd point's date, % 
int             InpPrice3=75;              // 3 rd point's price, % 
input color           InpColor=clrAqua;           // Object color 
input ENUM_LINE_STYLE InpStyle=STYLE_DASHDOT; // Style of lines 
input int             InpWidth=1;                // Width of the lines 
bool            InpBack=false;             // Background object 
bool            InpSelection=true;         // Highlight to move 
input bool            InpRayLeft=false;          // Object's continuation to the left 
input bool            InpRayRight=true;         // Object's continuation to the right 
bool            InpHidden=true;            // Hidden in the object list 
long            InpZOrder=0;               // Priority for mouse click 



//+------------------------------------------------------------------+
//| Create Fibonacci Extension by the given coordinates              |
//+------------------------------------------------------------------+
bool FiboExpansionCreate(const long            chart_ID=0,           // chart's ID
                         const string          name="FiboExpansion", // channel name
                         const int             sub_window=0,         // subwindow index
                         datetime              time1=0,              // first point time
                         double                price1=0,             // first point price
                         datetime              time2=0,              // second point time
                         double                price2=0,             // second point price
                         datetime              time3=0,              // third point time
                         double                price3=0,             // third point price
                         const color           clr=clrRed,           // object color
                         const ENUM_LINE_STYLE style=STYLE_SOLID,    // style of the lines
                         const int             width=1,              // width of the lines
                         const bool            back=false,           // in the background
                         const bool            selection=true,       // highlight to move
                         const bool            ray_left=false,       // object's continuation to the left
                         const bool            ray_right=false,      // object's continuation to the right
                         const bool            hidden=true,          // hidden in the object list
                         const long            z_order=0) {          // priority for mouse click
//--- set anchor points' coordinates if they are not set
   ChangeFiboExpansionEmptyPoints(time1,price1,time2,price2,time3,price3);
   StringToDoubleArray(Fib_Levels,levels_values);
//--- reset the error value
   ResetLastError();
//--- Create Fibonacci Extension by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_EXPANSION,sub_window,time1,price1,time2,price2,time3,price3)) {
      Print(__FUNCTION__,
            ": failed to create \"Fibonacci Extension\"! Error code = ",GetLastError());
      return(false);
   }
//--- set the object's color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set the line style
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the lines
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the channel for moving
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the object's visualization to the left
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
//--- enable (true) or disable (false) the mode of continuation of the object's visualization to the right
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}

//+------------------------------------------------------------------+
//| Move Fibonacci Expansion anchor point                            |
//+------------------------------------------------------------------+
bool FiboExpansionPointChange(const long   chart_ID=0,           // chart's ID
                              const string name="FiboExpansion", // object name
                              const int    point_index=0,        // anchor point index
                              datetime     time=0,               // anchor point time coordinate
                              double       price=0) {            // anchor point price coordinate
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
//| Check the values of Fibonacci Expansion anchor points and set    |
//| default values for empty ones                                    |
//+------------------------------------------------------------------+
void ChangeFiboExpansionEmptyPoints(datetime &time1,double &price1,datetime &time2,
                                    double &price2,datetime &time3,double &price3) {
//--- if the third (right) point's time is not set, it will be on the current bar
   if(!time3)
      time3=TimeCurrent();
//--- if the third point's price is not set, it will have Bid value
   if(!price3)
      price3=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the first (left) point's time is not set, it is located 9 bars left from the third one
//--- array for receiving the open time of the last 10 bars
   datetime temp[];
   ArrayResize(temp,10);
   if(!time1) {
      CopyTime(Symbol(),Period(),time3,10,temp);
      //--- set the first point 9 bars left from the second one
      time1=temp[0];
   }
//--- if the first point's price is not set, it is equal to the third point's one
   if(!price1)
      price1=price3;
//--- if the second point's time is not set, it is located 7 bars left from the third one
   if(!time2)
      time2=temp[2];
//--- if the second point's price is not set, move it 250 points lower than the first one
   if(!price2)
      price2=price1-250*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
}
//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
//--- check correctness of the input parameters
   if(InpDate1<0 || InpDate1>100 || InpPrice1<0 || InpPrice1>100 ||
         InpDate2<0 || InpDate2>100 || InpPrice2<0 || InpPrice2>100 ||
         InpDate3<0 || InpDate3>100 || InpPrice3<0 || InpPrice3>100) {
      Print("Error! Incorrect values of input parameters!");
      return;
   }
//--- number of visible bars in the chart window
   int bars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
//--- price array size
   int accuracy=1000;
//--- arrays for storing the date and price values to be used
//--- for setting and changing object anchor points' coordinates
   datetime date[];
   double   price[];
//--- memory allocation
   ArrayResize(date,bars);
   ArrayResize(price,accuracy);
//--- fill the array of dates
   ResetLastError();
   if(CopyTime(Symbol(),Period(),0,bars,date)==-1) {
      Print("Failed to copy time values! Error code = ",GetLastError());
      return;
   }
//--- fill the array of prices
//--- find the highest and lowest values of the chart
   double max_price=ChartGetDouble(0,CHART_PRICE_MAX);
   double min_price=ChartGetDouble(0,CHART_PRICE_MIN);
//--- define a change step of a price and fill the array
   double step=(max_price-min_price)/accuracy;
   for(int i=0; i<accuracy; i++)
      price[i]=min_price+i*step;
//--- define points for drawing Fibonacci Expansion
   int d1=InpDate1*(bars-1)/100;
   int d2=InpDate2*(bars-1)/100;
   int d3=InpDate3*(bars-1)/100;
   int p1=InpPrice1*(accuracy-1)/100;
   int p2=InpPrice2*(accuracy-1)/100;
   int p3=InpPrice3*(accuracy-1)/100;
//--- create Fibonacci Expansion
   if(!FiboExpansionCreate(0,InpName,0,date[d1],price[p1],date[d2],price[p2],date[d3],price[p3],
                           InpColor,InpStyle,InpWidth,InpBack,InpSelection,InpRayLeft,InpRayRight,InpHidden,InpZOrder)) {
      return;
   }
   SetFiboLevels(InpName,levels_values);
   SetFiboDescriptions(InpName, levels_descriptions);
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
      ObjectSetInteger(0,_object_name,OBJPROP_LEVELCOLOR,i,InpColor);
      ObjectSetInteger(0,_object_name,OBJPROP_LEVELSTYLE,i,InpStyle);
   }
//--- Redraw the chart before finishing
   ChartRedraw(0);
}


//+------------------------------------------------------------------+
//| SetFiboDescriptions                                                                 |
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
         ObjectSetString(0,_object_name,OBJPROP_LEVELTEXT,i,StringSubstr(Cuttext,0,StringLen(Cuttext)-5));
      }
   }
//--- Redraw the chart before finishing
   ChartRedraw(0);
}
//+------------------------------------------------------------------+

