//+------------------------------------------------------------------+
//|                                            Fibonacci_Channel.mq5 |
//|                      Copyright © 2021, MetaQuotes Software Corp. |
//|                                      https://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Dark Ryd3r"
#property link      "https://darkryd3r.com"
#property version   "1.00"
#property description "Fibonacci_Channel"
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1

string  Fib_Levels=  "-0.786,-0.618,-0.5,-0.382,-0.236";
input color Levelclr = clrSlateBlue;
input ENUM_LINE_STYLE LevelStyle = STYLE_SOLID;
double levels_values[];                 // Array of level values
string levels_descriptions[] = {};      // Array of level descriptions

//+----------------------------------------------+
//|  Declaration of enumerations                 |
//+----------------------------------------------+
enum ENUM_WIDTH { // Type of constant
   w_1 = 1,     // 1
   w_2,         // 2
   w_3,         // 3
   w_4,         // 4
   w_5          // 5
};
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input int ExtDepth=55;
input int ExtDeviation=3;
input int ExtBackstep =1;
//+----------------------------------------------+
//| Channel creation input parameters            |
//+----------------------------------------------+

input int FirstExtrNumb=1; //Numb                   
color Upper_color= clrDeepPink;                 // Upper channel line color
ENUM_LINE_STYLE Upper_style=STYLE_DASH;       // Upper channel line style
ENUM_WIDTH Upper_width=w_1;                    // Upper channel line width
color Middle_color=C'55,55,55';                       // Middle line color
ENUM_LINE_STYLE Middle_style=STYLE_DASH; // Middle line style
ENUM_WIDTH Middle_width=w_1;                   // Middle line width
color Lower_color=clrDeepPink/* clrAqua*/;                     // Lower channel line color
ENUM_LINE_STYLE Lower_style=STYLE_DASH;       // Lower channel line style
ENUM_WIDTH Lower_width=w_1;                    // Lower channel line width

color L618_color=clrMagenta;                       // 618 line color
ENUM_LINE_STYLE L618_style=STYLE_DASH; // 618 line style
ENUM_WIDTH L618_width=w_1;                   // 618 line width

double LowestBuffer[];
double HighestBuffer[];

int LASTlowpos,LASThighpos,LASTColor;
double LASTlow0,LASTlow1,LASThigh0,LASThigh1;

int StartBars;
string prefix;
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateChannel(long     chart_id,  // chart ID
                   string   name,      // object name
                   int      nwin,      // window index
                   datetime time1,     // price level time 1
                   double   price1,    // price level 1
                   datetime time2,     // price level time 2
                   double   price2,    // price level 2
                   datetime time3,     // price level time 3
                   double   price3,    // price level 3
                   color    Color,     // line color
                   int      style,     // line style
                   int      width,     // line width
                   string   text) {    // text
//----
   ObjectCreate(chart_id,name,OBJ_CHANNEL,nwin,time1,price1,time2,price2,time3,price3);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
//ObjectSetDouble(chart_id,name,OBJPROP_ANGLE,45);
//----
}
//+------------------------------------------------------------------+
//|  Reinstallation of the equally-spaced channel                    |
//+------------------------------------------------------------------+
void SetChannel(long     chart_id,  // chart ID
                string   name,      // object name
                int      nwin,      // window index
                datetime time1,     // price level time 1
                double   price1,    // price level 1
                datetime time2,     // price level time 2
                double   price2,    // price level 2
                datetime time3,     // price level time 3
                double   price3,    // price level 3
                color    Color,     // line color
                int      style,     // line style
                int      width,     // line width
                string   text) {    // text
//----
   if(ObjectFind(chart_id,name)==-1) CreateChannel(chart_id,name,nwin,time1,price1,time2,price2,time3,price3,Color,style,width,text);
   else {
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,time1,price1);
      ObjectMove(chart_id,name,1,time2,price2);
      ObjectMove(chart_id,name,2,time3,price3);
   }
//----
}
//+------------------------------------------------------------------+
//|  Trend line creation                                             |
//+------------------------------------------------------------------+
void CreateTline(long     chart_id,  // chart ID
                 string   name,      // object name
                 int      nwin,      // window index
                 datetime time1,     // price level time 1
                 double   price1,    // price level 1
                 datetime time2,     // price level time 2
                 double   price2,    // price level 2
                 color    Color,     // line color
                 int      style,     // line style
                 int      width,     // line width
                 string   text) {    // text
//----
   ObjectCreate(chart_id,name,OBJ_TREND,nwin,time1,price1,time2,price2);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
   ObjectSetInteger(chart_id,name,OBJPROP_RAY_RIGHT,true);
//----
}
//+------------------------------------------------------------------+
//|  Trend line reinstallation                                       |
//+------------------------------------------------------------------+
void SetTline(long     chart_id,  // chart ID
              string   name,      // object name
              int      nwin,      // window index
              datetime time1,     // price level time 1
              double   price1,    // price level 1
              datetime time2,     // price level time 2
              double   price2,    // price level 2
              color    Color,     // line color
              int      style,     // line style
              int      width,     // line width
              string   text) {    // text
//----
   CreateTline(chart_id,name,nwin,time1,price1,time2,price2,Color,style,width,text);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectMove(chart_id,name,0,time1,price1);
   ObjectMove(chart_id,name,1,time2,price2);
//----
}
//+------------------------------------------------------------------+
//| Searching for the very first ZigZag high in time series buffers  |
//+------------------------------------------------------------------+
int FindFirstExtremum(int StartPos,int Rates_total,double &UpArray[],double &DnArray[],int &Sign,double &Extremum) {
//----
   if(StartPos>=Rates_total)
      StartPos=Rates_total-1;

   for(int bar=StartPos; bar<Rates_total; bar++) {
      if(UpArray[bar]!=0.0 && UpArray[bar]!=EMPTY_VALUE) {
         Sign=+1;
         Extremum=UpArray[bar];
         return(bar);
         break;
      }

      if(DnArray[bar]!=0.0 && DnArray[bar]!=EMPTY_VALUE) {
         Sign=-1;
         Extremum=DnArray[bar];
         return(bar);
         break;
      }
   }
//----
   return(-1);
}
//+------------------------------------------------------------------+
//| Searching for the second ZigZag high in time series buffers      |
//+------------------------------------------------------------------+
int FindSecondExtremum(int Direct,
                       int StartPos,
                       int Rates_total,
                       double &UpArray[],
                       double &DnArray[],
                       int &Sign,
                       double &Extremum) {
//----
   if(StartPos>=Rates_total)StartPos=Rates_total-1;

   if(Direct==-1)
      for(int bar=StartPos; bar<Rates_total; bar++) {
         if(UpArray[bar]!=0.0 && UpArray[bar]!=EMPTY_VALUE) {
            Sign=+1;
            Extremum=UpArray[bar];
            return(bar);
            break;
         }

      }

   if(Direct==+1)
      for(int bar=StartPos; bar<Rates_total; bar++) {
         if(DnArray[bar]!=0.0 && DnArray[bar]!=EMPTY_VALUE) {
            Sign=-1;
            Extremum=DnArray[bar];
            return(bar);
            break;
         }
      }
//----
   return(-1);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit() {
   prefix= "w_";
   StartBars=ExtDepth+ExtBackstep;

   SetIndexBuffer(0,LowestBuffer,INDICATOR_CALCULATIONS);
   SetIndexBuffer(1,HighestBuffer,INDICATOR_CALCULATIONS);
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,0.0);
   PlotIndexSetString(0,PLOT_LABEL,"ZigZag Lowest");
   PlotIndexSetString(1,PLOT_LABEL,"ZigZag Highest");
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,StartBars);
   PlotIndexSetInteger(1,PLOT_DRAW_BEGIN,StartBars);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   string shortname;
   StringConcatenate(shortname,"ZigZag (ExtDepth=",
                     ExtDepth,"ExtDeviation = ",ExtDeviation,"ExtBackstep = ",ExtBackstep,")");
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//----
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
//----
   ObjectsDeleteAll(0,prefix);
   ChartRedraw(0);

//----
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
//---- checking the number of bars to be enough for the calculation
   if(rates_total<StartBars) return(0);

//---- declarations of local variables
   int limit,bar,back,lasthighpos,lastlowpos;
   double curlow,curhigh,lasthigh0=0.0,lastlow0=0.0,lasthigh1,lastlow1,val,res;

//---- declarations of local variables for creating the channel and Fibo
   int bar1=0,bar2,bar3,bar4,sign;
   double price1=0.0,price2,price3,price4;

//---- calculate the limit starting index for loop of bars recalculation and start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0) { // checking for the first start of the indicator calculation
      limit=rates_total-StartBars; // starting index for calculation of all bars
      lastlow1=-1;
      lasthigh1=-1;
      lastlowpos=-1;
      lasthighpos=-1;
   } else {
      limit=rates_total-prev_calculated; // starting index for calculation of new bars
      //---- restore values of the variables
      lastlow0=LASTlow0;
      lasthigh0=LASThigh0;

      lastlow1=LASTlow1;
      lasthigh1=LASThigh1;

      lastlowpos=LASTlowpos+limit;
      lasthighpos=LASThighpos+limit;
   }

//---- indexing elements in arrays as timeseries
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   ArraySetAsSeries(time,true);

//---- first big indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--) {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0) {
         LASTlow0=lastlow0;
         LASThigh0=lasthigh0;
      }

      //--- low
      val=low[ArrayMinimum(low,bar,ExtDepth)];
      if(val==lastlow0) val=0.0;
      else {
         lastlow0=val;
         if((low[bar]-val)>(ExtDeviation*_Point))val=0.0;
         else {
            for(back=1; back<=ExtBackstep; back++) {
               res=LowestBuffer[bar+back];
               if((res!=0) && (res>val)) {
                  LowestBuffer[bar+back]=0.0;
               }
            }
         }
      }
      LowestBuffer[bar]=val;

      //--- high
      val=high[ArrayMaximum(high,bar,ExtDepth)];
      if(val==lasthigh0) val=0.0;
      else {
         lasthigh0=val;
         if((val-high[bar])>(ExtDeviation*_Point))val=0.0;
         else {
            for(back=1; back<=ExtBackstep; back++) {
               res=HighestBuffer[bar+back];
               if((res!=0) && (res<val)) {
                  HighestBuffer[bar+back]=0.0;
               }
            }
         }
      }
      HighestBuffer[bar]=val;
   }

//---- the second big indicator calculation loop
   for(bar=limit; bar>=0 && !IsStopped(); bar--) {
      //---- store values of the variables before running at the current bar
      if(rates_total!=prev_calculated && bar==0) {
         LASTlow1=lastlow1;
         LASThigh1=lasthigh1;
         //----
         LASTlowpos=lastlowpos;
         LASThighpos=lasthighpos;
      }

      curlow=LowestBuffer[bar];
      curhigh=HighestBuffer[bar];
      //---
      if(curlow==0 && curhigh==0) continue;
      //---
      if(curhigh!=0) {
         if(lasthigh1>0) {
            if(lasthigh1<curhigh) HighestBuffer[lasthighpos]=0;
            else                  HighestBuffer[bar]=0;
         }
         //---
         if(lasthigh1<curhigh || lasthigh1<0) {
            lasthigh1=curhigh;
            lasthighpos=bar;
         }
         lastlow1=-1;
      }
      //----
      if(curlow!=0) {
         if(lastlow1>0) {
            if(lastlow1>curlow) LowestBuffer[lastlowpos]=0;
            else                LowestBuffer[bar]=0;
         }
         //---
         if((curlow<lastlow1) || (lastlow1<0)) {
            lastlow1=curlow;
            lastlowpos=bar;
         }
         lasthigh1=-1;
      }
   }

//---- channel creation
   bar1=FindFirstExtremum(0,rates_total,HighestBuffer,LowestBuffer,sign,price1);

   for(int numb=1; numb<=FirstExtrNumb && bar1>-1; numb++)
      bar1=FindSecondExtremum(sign,bar1,rates_total,HighestBuffer,LowestBuffer,sign,price1);

   if(bar1==-1) {
      ObjectsDeleteAll(0,prefix);
      return(rates_total);
   }

   bar2=FindSecondExtremum(sign,bar1,rates_total,HighestBuffer,LowestBuffer,sign,price2);
   bar3=FindSecondExtremum(sign,bar2,rates_total,HighestBuffer,LowestBuffer,sign,price3);

   bar4=bar2+bar3-bar1;
   price4=price2+price3-price1;

   if(sign==+1) {
      FiboChannelCreate(0,prefix+"Upper Fib",0,time[bar3],price3,time[bar1],price1,time[bar4],price4,Upper_color,Upper_style);
      SetFiboLevels(prefix+"Upper Fib",levels_values);
      SetFiboDescriptions(prefix+"Upper Fib", levels_descriptions);
   }

   if(sign==-1) {
      FiboChannelCreate(0,prefix+"Lower Fib",0,time[bar4],price4,time[bar2],price2,time[bar3],price3,Upper_color,Upper_style);
      SetFiboLevels(prefix+"Lower Fib",levels_values);
      SetFiboDescriptions(prefix+"Lower Fib", levels_descriptions);
   }
//----
   ChartRedraw(0);
   return(rates_total);
}

//+------------------------------------------------------------------+
//| Create Fibonacci Channel by the given coordinates                |
//+------------------------------------------------------------------+
bool FiboChannelCreate(const long            chart_ID=0,         // chart's ID
                       const string          name="FiboChannel", // channel name
                       const int             sub_window=0,       // subwindow index
                       datetime              time1=0,            // first point time
                       double                price1=0,           // first point price
                       datetime              time2=0,            // second point time
                       double                price2=0,           // second point price
                       datetime              time3=0,            // third point time
                       double                price3=0,           // third point price
                       const color           clr=clrCrimson,         // channel color
                       const ENUM_LINE_STYLE style=STYLE_SOLID,  // style of channel lines
                       const int             width=1,            // width of channel lines
                       const bool            back=false,         // in the background
                       const bool            selection=true,     // highlight to move
                       const bool            ray_left=false,     // channel's continuation to the left
                       const bool            ray_right=true,    // channel's continuation to the right
                       const bool            hidden=true,        // hidden in the object list
                       const long            z_order=0) {        // priority for mouse click
//--- set anchor points' coordinates if they are not set
   ChangeFiboChannelEmptyPoints(time1,price1,time2,price2,time3,price3);
   StringToDoubleArray(Fib_Levels,levels_values);
//--- reset the error value
   ResetLastError();
//--- create a channel by the given coordinates
   if(!ObjectCreate(chart_ID,name,OBJ_FIBOCHANNEL,sub_window,time1,price1,time2,price2,time3,price3)) {
      Print(__FUNCTION__,
            ": failed to create \"Fibonacci Channel\"! Error code = ",GetLastError());
      return(false);
   }
//--- set channel color
   ObjectSetInteger(chart_ID,name,OBJPROP_COLOR,clr);
//--- set style of the channel lines
   ObjectSetInteger(chart_ID,name,OBJPROP_STYLE,style);
//--- set width of the channel lines
   ObjectSetInteger(chart_ID,name,OBJPROP_WIDTH,width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID,name,OBJPROP_BACK,back);
//--- enable (true) or disable (false) the mode of highlighting the channel for moving
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTABLE,selection);
   ObjectSetInteger(chart_ID,name,OBJPROP_SELECTED,selection);
//--- enable (true) or disable (false) the mode of continuation of the channel's display to the left
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_LEFT,ray_left);
//--- enable (true) or disable (false) the mode of continuation of the channel's display to the right
   ObjectSetInteger(chart_ID,name,OBJPROP_RAY_RIGHT,ray_right);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID,name,OBJPROP_HIDDEN,hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID,name,OBJPROP_ZORDER,z_order);
//--- successful execution
   return(true);
}

//+------------------------------------------------------------------+
//| Move Fibonacci Channel anchor point                              |
//+------------------------------------------------------------------+
bool FiboChannelPointChange(const long   chart_ID=0,         // chart's ID
                            const string name="FiboChannel", // channel name
                            const int    point_index=0,      // anchor point index
                            datetime     time=0,             // anchor point time coordinate
                            double       price=0) {          // anchor point price coordinate
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
//| Check the values of Fibonacci Channel anchor points and set      |
//| default values for empty ones                                    |
//+------------------------------------------------------------------+
void ChangeFiboChannelEmptyPoints(datetime &time1,double &price1,datetime &time2,
                                  double &price2,datetime &time3,double &price3) {
//--- if the second (right) point's time is not set, it will be on the current bar
   if(!time2)
      time2=TimeCurrent();
//--- if the second point's price is not set, it will have Bid value
   if(!price2)
      price2=SymbolInfoDouble(Symbol(),SYMBOL_BID);
//--- if the first (left) point's time is not set, it is located 9 bars left from the second one
   if(!time1) {
      //--- array for receiving the open time of the last 10 bars
      datetime temp[10];
      CopyTime(Symbol(),Period(),time2,10,temp);
      //--- set the first point 9 bars left from the second one
      time1=temp[0];
   }
//--- if the first point's price is not set, move it 300 points higher than the second one
   if(!price1)
      price1=price2+300*SymbolInfoDouble(Symbol(),SYMBOL_POINT);
//--- if the third point's time is not set, it coincides with the first point's one
   if(!time3)
      time3=time1;
//--- if the third point's price is not set, it is equal to the second point's one
   if(!price3)
      price3=price2;
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
         ObjectSetString(0,_object_name,OBJPROP_LEVELTEXT,i,StringSubstr(Cuttext,0,StringLen(Cuttext)-5)); // ...leave the description empty
      }
   }
//--- Redraw the chart before finishing
   ChartRedraw(0);
}
//+------------------------------------------------------------------+
