//+------------------------------------------------------------------+
//|                                              DinapoliTargets.mq5 |
//|                                       Copyright © 2007, mishanya |
//|                                            mishanya_fx@yahoo.com |
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2007, mishanya"
//---- link to the website of the author
#property link      "mishanya_fx@yahoo.com"
//---- indicator version
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
#property indicator_buffers   1
#property indicator_plots     1
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+  
enum WIDTH
  {
   Width_1=1,  // 1
   Width_2,    // 2
   Width_3,    // 3
   Width_4,    // 4
   Width_5     // 5
  };
//+-----------------------------------+
//|  Declaration of enumeration       |
//+-----------------------------------+
enum STYLE
  {
   SOLID_,       // Solid line
   DASH_,        // Dashed line
   DOT_,         // Dotted line
   DASHDOT_,     // Dot-dash line
   DASHDOTDOT_   // Dot-dash line with double dots
  };
//+----------------------------------------------+
//|  Indicator input parameters                  |
//+----------------------------------------------+
input uint Length=6; // Smoothing period
input uint EndBar=1; // End bar for calculation
//----
input color  Start_line_Color=Magenta;     // Start level color
input STYLE  Start_line_Style = SOLID_;    // Start level style
input WIDTH  Start_line_Width = Width_2;   // Start line width
//----
input color  Target1_line_Color= Green;     // Target1 level color
input STYLE  Target1_line_Style = DASH_;    // Target1 level style
input WIDTH  Target1_line_Width= Width_1;   // Target1 level width
//----
input color  Target2_line_Color= Orange;    // Target2 level color
input STYLE  Target2_line_Style = DASH_;    // Target2 level style
input WIDTH  Target2_line_Width= Width_1;   // Target2 level width
//----
input color  Target3_line_Color= DarkOrchid; // Target3 level color
input STYLE  Target3_line_Style = DASH_;     // Target3 level style
input WIDTH  Target3_line_Width= Width_1;    // Target3 level width
//----
input color  Stop_line_Color= Red;      // Stop-loss level color
input STYLE  Stop_line_Style = DASH_;   // Stop-loss level style
input WIDTH  Stop_line_Width= Width_1;  // End level width
//+----------------------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//+------------------------------------------------------------------+
//|  Creating horizontal price level                                 |
//+------------------------------------------------------------------+
void CreateHline(long   chart_id,  // chart ID
                 string name,      // object name
                 int    nwin,      // window index
                 double price,     // price level
                 color  Color,     // line color
                 int    style,     // line style
                 int    width,     // line width
                 string text)      // text
  {
//----
   ObjectCreate(chart_id,name,OBJ_HLINE,0,0,price);
   ObjectSetInteger(chart_id,name,OBJPROP_COLOR,Color);
   ObjectSetInteger(chart_id,name,OBJPROP_STYLE,style);
   ObjectSetInteger(chart_id,name,OBJPROP_WIDTH,width);
   ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
   ObjectSetInteger(chart_id,name,OBJPROP_BACK,true);
//----
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the horizontal price level                    |
//+------------------------------------------------------------------+
void SetHline(long   chart_id,  // chart ID
              string name,      // object name
              int    nwin,      // window index
              double price,     // price level
              color  Color,     // line color
              int    style,     // line style
              int    width,     // line width
              string text)      // text
  {
//----
   if(ObjectFind(chart_id,name)==-1)
     {
      CreateHline(chart_id,name,nwin,price,Color,style,width,text);
     }
   else
     {
      //ObjectSetDouble(chart_id,name,OBJPROP_PRICE,price);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=int(Length+4);

//---- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

//---- create labels to display in DataWindow and a name for display 
//---- in a separate sub-window and in a tooltip
   IndicatorSetString(INDICATOR_SHORTNAME,"Dinapoli Targets");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   ObjectDelete(0,"Start line");
   ObjectDelete(0,"Stop line");
   ObjectDelete(0,"Target1 line");
   ObjectDelete(0,"Target2 line");
   ObjectDelete(0,"Target3 line");
   Comment("");
//----
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// number of bars calculated at previous call
                const datetime &Time[],
                const double &Open[],
                const double& High[],     // price array of maximums of price for the indicator calculation
                const double& Low[],      // price array of minimums of price for the indicator calculation
                const double &Close[],
                const long &Tick_volume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- 
   if(rates_total<min_rates_total) return(0);

//---- indexing elements in arrays as time series  
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Spread,true);

//---- declarations of local variables    
   int limit,bar,Swing=0,i;
   double PointA,PointB,PointC;
   double Target1,Target2,Target3,Start=0,Stop=0;
   double LL,HH,spread,dPointBA;
   static double Uzel0,Uzel1,Uzel2,BH,BL;
   static int Swing_n;

//---- calculate the limit starting index for loop of bars recalculation and start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total; // starting index for calculation of all bars

      Uzel0=0;
      Uzel1=0;
      Uzel2=0;
      Swing=0;
      Swing_n=0;
      int startbar=int(rates_total-min_rates_total+EndBar);
      BH=High[startbar];
      BL=Low[startbar];
      Start=0.0;
      Stop=0.0;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//----
   for(bar=limit; bar>=int(EndBar); bar--)
     {
      LL=10000000;
      HH=-100000000;

      for(i=int(Length); i>=1; i--)
        {
         int barl=bar+i;
         if(Low[i]< LL) LL=Low[barl];
         if(High[i]>HH) HH=High[barl];
        }

      if(Low[bar]<LL && High[bar]>HH)Swing=2;
      else
        {
         if(Low[bar]<LL)  Swing=-1;
         if(High[bar]>HH) Swing=+1;
        }

      if(Swing!=Swing_n && Swing_n!=0)
        {
         if(Swing==2)
           {
            Swing=-Swing_n;
            BH=High[bar];
            BL=Low[bar];
           }

         Uzel2=Uzel1;
         Uzel1=Uzel0;

         if(Swing==+1) Uzel0=BL;
         if(Swing==-1) Uzel0=BH;

         BH=High[bar];
         BL=Low[bar];
        }

      if(Swing==1 && High[bar]>=BH) BH=High[bar];
      if(Swing==-1 && Low[bar]<=BL) BL=Low[bar];

      Swing_n=Swing;
     }

   PointA=Uzel2;
   PointB=Uzel1;
   PointC=Uzel0;
//----
   Comment(DoubleToString(NormalizeDouble(PointA,_Digits),_Digits)," ",
           DoubleToString(NormalizeDouble(PointB,_Digits),_Digits)," ",
           DoubleToString(NormalizeDouble(PointC,_Digits),_Digits));
//----
   dPointBA=PointB-PointA;
   Target1=NormalizeDouble(dPointBA*0.618+PointC,_Digits);
   Target2=dPointBA+PointC;
   Target3=NormalizeDouble(dPointBA*1.618+PointC,_Digits);
   spread=Spread[EndBar]*_Point;

   if(PointB<=PointC)
     {
      Start=NormalizeDouble(dPointBA*0.318+PointC,_Digits)-spread;
      Stop=PointC+2*spread;
     }

   if(PointB>PointC)
     {
      Start=NormalizeDouble(dPointBA*0.318+PointC,_Digits)+spread;
      Stop=PointC-2*spread;
     }

   SetHline(0,"Start line",0,Start,Start_line_Color,Start_line_Style,Start_line_Width,"Start line "+DoubleToString(Start,_Digits));
   SetHline(0,"Target1 line",0,Target1,Target1_line_Color,Target1_line_Style,Target1_line_Width,"Target1 line "+DoubleToString(Target1,_Digits));
   SetHline(0,"Target2 line",0,Target2,Target2_line_Color,Target2_line_Style,Target2_line_Width,"Target2 line "+DoubleToString(Target2,_Digits));
   SetHline(0,"Target3 line",0,Target3,Target3_line_Color,Target3_line_Style,Target3_line_Width,"Target3 line "+DoubleToString(Target3,_Digits));
   SetHline(0,"Stop line",0,Stop,Stop_line_Color,Stop_line_Style,Stop_line_Width,"Stop line "+DoubleToString(Stop,_Digits));
//----
   ChartRedraw(0);
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
