//--- description
#property copyright "Copyright © 2021, Dark Ryd3r"
#property link      "https://twitter.com/DarkRyd3r"
#property version   "1.00"
#property description "RiskReward"

#property script_show_inputs

input string  Fib_Levels             =  "-1,0,1,2,3,4,5";         //Enter risk reward, Risk in negative, Reward in Positive
input string  colors           =  "clrCrimson,clrSnow,clrSnow,clrLimeGreen,clrAqua,clrAqua,clrAqua" ;        // Colors of Risk Rewards
input   ENUM_LINE_STYLE styles =  STYLE_DASH;   // Style of level lines
input int  widths              =  1;        // Widths of level lines

double levels_values[];                 // Array of level values
color  colors_values[];
string styles_values[];
int    widths_values[];
string levels_descriptions[] = {};      // Array of level descriptions

//--- input parameters of the script
string          InpName="RiskReward";      // Object name
int             InpDate1=10;               // 1 st point's date, %
int             InpPrice1=65;              // 1 st point's price, %
int             InpDate2=90;               // 2 nd point's date, %
int             InpPrice2=85;              // 2 nd point's price, %
color           InpColor=clrCrimson;           // Object color
ENUM_LINE_STYLE InpStyle=STYLE_DASH; // Line style
int             InpWidth=1;                // Line width
bool            InpBack=false;             // Background object
bool            InpSelection=true;         // Highlight to move
input bool            InpRayLeft=true;          // Object's continuation to the left
input bool            InpRayRight=true;         // Object's continuation to the right
bool            InpHidden=true;            // Hidden in the object list
long            InpZOrder=0;               // Priority for mouse click
//+------------------------------------------------------------------+
//| Create Fibonacci Retracement by the given coordinates            |
//+------------------------------------------------------------------+
bool FiboLevelsCreate(const long            chart_ID=0,        // chart's ID
                      const string          name="RiskReward", // object name
                      const int             sub_window=0,      // subwindow index
                      datetime              time1=0,           // first point time
                      double                price1=0,          // first point price
                      datetime              time2=0,           // second point time
                      double                price2=0,          // second point price
                      const color           clr=clrSnow,        // object color
                      const ENUM_LINE_STYLE style=STYLE_SOLID, // object line style
                      const int             width=1,           // object line width
                      const bool            back=false,        // in the background
                      const bool            selection=true,    // highlight to move
                      const bool            ray_left=false,    // object's continuation to the left
                      const bool            ray_right=false,   // object's continuation to the right
                      const bool            hidden=true,       // hidden in the object list
                      const long            z_order=0) {       // priority for mouse click
//--- set anchor points' coordinates if they are not set
   ChangeFiboLevelsEmptyPoints(time1,price1,time2,price2);
   StringToDoubleArray(Fib_Levels,levels_values);
   StringToColorArray(colors,colors_values);
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
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart() {
//--- check correctness of the input parameters
   if(InpDate1<0 || InpDate1>100 || InpPrice1<0 || InpPrice1>100 ||
         InpDate2<0 || InpDate2>100 || InpPrice2<0 || InpPrice2>100) {
      Print("Error! Incorrect values of input parameters!");
      return;
   }
//--- number of visible bars in the chart window
   int bars=(int)ChartGetInteger(0,CHART_VISIBLE_BARS);
//--- price array size
   int accuracy=1000;
//--- arrays for storing the date and price values to be used
//--- for setting and changing the coordinates of Fibonacci Retracement anchor points
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
//--- define points for drawing Fibonacci Retracement
   int d1=InpDate1*(bars-1)/100;
   int d2=InpDate2*(bars-1)/100;
   int p1=InpPrice1*(accuracy-1)/100;
   int p2=InpPrice2*(accuracy-1)/100;
//--- create an object
   if(!FiboLevelsCreate(0,InpName,0,date[d1],price[p1],date[d2],price[p2],InpColor,
                        InpStyle,InpWidth,InpBack,InpSelection,InpRayLeft,InpRayRight,InpHidden,InpZOrder)) {
      return;
   }
   SetFiboLevels(InpName,levels_values,colors_values,widths_values);
   SetFiboDescriptions(InpName, levels_descriptions);
//--- redraw the chart and wait for 1 second
   ChartRedraw();
   Sleep(1000);
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
void StringToColorArray (
   string _haystack,            // source string
   color &_result[],           // array of results
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
         _result[i]=StringToColor(haystack_pieces[i]);
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
   const double &_levels_values[],            // Array of levels
   const color &_colors_values[],            // Array of levels
   const int &_widths_values[]            // Array of levels
) {
   int i,                                      // Current level counter
       levels_count=ArraySize(_levels_values), // Total number of levels
       colors_count=ArraySize(_colors_values), // Total number of levels
       widths_count=ArraySize(_widths_values); // Total number of levels

//--- Proceed with the implementation

//--- Set the quantity property for the current object
   ObjectSetInteger(0,_object_name,OBJPROP_LEVELS,levels_count);
//--- Set value, color and style for each level.
   for(i=0; i<levels_count; i++) {
      ObjectSetDouble(0,_object_name,OBJPROP_LEVELVALUE,i,_levels_values[i]);
      ObjectSetInteger(0,_object_name,OBJPROP_LEVELCOLOR,i,_colors_values[i]);
      ObjectSetInteger(0,_object_name,OBJPROP_LEVELSTYLE,i,styles);
      ObjectSetInteger(0,_object_name,OBJPROP_WIDTH,i,widths);
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
         ObjectSetString(0,_object_name,OBJPROP_LEVELTEXT,i,StringSubstr(Cuttext,0,StringLen(Cuttext)-6)); // ...leave the description empty
      }
   }
//--- Redraw the chart before finishing
   ChartRedraw(0);
}
//+------------------------------------------------------------------+
