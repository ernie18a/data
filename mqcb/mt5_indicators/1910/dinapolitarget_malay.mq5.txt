//+------------------------------------------------------------------+
//|                                         DinapoliTarget_Malay.mq4 |
//|                                     fxfariz a.k.a warrior trader |
//|                                                fxfariz@gmail.com |
//+------------------------------------------------------------------+
//---- Copyright
#property copyright "fxfariz a.k.a warrior trader"
//---- website link
#property link      "fxfariz@gmail.com"
//---- Indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window 
//---- one buffer is used for calculation and drawing of the indicator
#property indicator_buffers 1
//---- one plot is used
#property indicator_plots   1
//+----------------------------------------------+
//|  Indicator drawing parameters                |
//+----------------------------------------------+
//---- drawing indicator 1 as a line
#property indicator_type1   DRAW_SECTION
//---- DarkOrchid color is used as the color of the bullish line of the indicator
#property indicator_color1  clrDarkOrchid
//---- the line of the indicator 1 is a continuous curve
#property indicator_style1  STYLE_SOLID
//---- indicator 1 line width is equal to 2
#property indicator_width1  2
//---- displaying the indicator label
#property indicator_label1  "DinapoliTarget_Malay"
//+----------------------------------------------+
//| Indicator input parameters                   |
//+----------------------------------------------+
input uint  barn=300;                            //Number of bars in the indicator calculation
input uint  Length=6;                            //Indicator period
input bool  SoundAlertMode=true;                 //Enable alert
input bool  targets=true;                        //Enable drawing of levels
input color Start_line_Color=clrBlueViolet;
input color Stop_line_Color=clrRed;
input color Target1_line_Color=clrBlue;
input color Target2_line_Color=clrDeepSkyBlue;
input color Target3_line_Color=clrLime;
input int   Shift=0;                             //Horizontal shift of the indicator in bars
//+----------------------------------------------+
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double IndBuffer[];
//---- declaration of the integer variables for the start of data calculation
int min_rates_total,size;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- Initialization of variables of the start of data calculation
   min_rates_total=int(barn+Length);

//---- Set dynamic array as an indicator buffer
   SetIndexBuffer(0,IndBuffer,INDICATOR_DATA);
//---- shifting the indicator 1 horizontally by Shift
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
//---- shifting the starting point of the indicator 1 drawing by min_rates_total
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,min_rates_total);
//---- Setting the indicator values that won't be visible on a chart
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,0.0);
//---- Indexing elements in the buffer as in timeseries
   ArraySetAsSeries(IndBuffer,true);

//---- Initializations of variable for indicator short name
   string shortname;
   StringConcatenate(shortname,"DinapoliTarget_Malay(",barn,", ",Length,", ",Shift,")");
//--- Creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,shortname);
//--- Determining the accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
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
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+
//|  Creating horizontal price level                                 |
//+------------------------------------------------------------------+
void CreateHline(long   chart_id,      // Chart ID
                 string name,          // object name
                 int    nwin,          // window index
                 double price,         // price level
                 color  Color,         // line color
                 int    style,         // line style
                 int    width,         // line width
                 string text)          // text
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
//|  Resetting the horizontal price level                            |
//+------------------------------------------------------------------+
void SetHline(long   chart_id,      // chart ID
              string name,          // object name
              int    nwin,          // window index
              double price,         // price level
              color  Color,         // line color
              int    style,         // line style
              int    width,         // line width
              string text)          // text
  {
//----
   if(ObjectFind(chart_id,name)==-1) CreateHline(chart_id,name,nwin,price,Color,style,width,text);
   else
     {
      //ObjectSetDouble(chart_id,name,OBJPROP_PRICE,price);
      ObjectSetString(chart_id,name,OBJPROP_TEXT,text);
      ObjectMove(chart_id,name,0,0,price);
     }
//----
  }
//+------------------------------------------------------------------+
//|  Getting a timeframe as a line                                   |
//+------------------------------------------------------------------+
string GetStringTimeframe(ENUM_TIMEFRAMES timeframe)
  {
   return(StringSubstr(EnumToString(timeframe),7,-1));
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,    // number of bars in history at the current tick
                const int prev_calculated,// amount of history in bars at the previous tick
                const datetime &Time[],
                const double &Open[],
                const double& High[],     // price array of maximums of price for the indicator calculation
                const double& Low[],      // price array of minimum of price for the indicator calculation
                const double &Close[],
                const long &Tick_Volume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- checking the number of bars to be enough for the calculation
   if(rates_total<min_rates_total) return(0);

//---- declaration of local variables 
   int limit,bar,Swing,Swing_n,uzl,i,zu,zd,mv;
   double PointA,PointB,PointC,Target1,Target2,Target3,Fantnsy,CrazyDream,Start,Stop;
   double LL,HH,BH,BL;
   double Uzel[1000][3];
   double prev;
   double alertBar;
//---- loop from first bar to current bar (with shift=0) 
   Swing_n=0;
   Swing=0;
   uzl=0;
   BH=High[barn];
   BL=Low[barn];
   zu=int(barn);
   zd=int(barn);

//---- calculation of the 'limit' starting index for the bars recalculation loop
   if(prev_calculated>rates_total || prev_calculated<=0)// Checking for the first start of the indicator calculation
      limit=rates_total-1; // starting index for calculation of all bars
   else limit=int(rates_total-prev_calculated+barn); // starting index for calculation of new bars

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Spread,true);

//---- the main loop of indicator reset
   for(bar=limit; bar>=0 && !IsStopped(); bar--) IndBuffer[bar]=0.0;

//---- The main loop of the indicator calculation   
   for(bar=int(barn); bar>=0 && !IsStopped(); bar--)
     {
      LL=+100000000;
      HH=-100000000;

      for(i=int(bar+Length); i>bar; i--)
        {
         if(Low[i]< LL) LL=Low[i];
         if(High[i]>HH) HH=High[i];
        }

      if(Low[bar]<LL && High[bar]>HH)
        {
         Swing=2;
         if(Swing_n==+1) zu=bar+1;
         if(Swing_n==-1) zd=bar+1;
        }
      else
        {
         if(Low[bar]<LL) Swing=-1;
         if(High[bar]>HH) Swing=1;
        }

      if(Swing!=Swing_n && Swing_n)
        {
         if(Swing==2)
           {
            Swing=-Swing_n;
            BH=High[bar];
            BL=Low[bar];
           }

         uzl++;

         if(Swing==1)
           {
            Uzel[uzl][1]=zd;
            Uzel[uzl][2]=BL;
           }
         if(Swing==-1)
           {
            Uzel[uzl][1]=zu;
            Uzel[uzl][2]=BH;
           }

         BH=High[bar];
         BL=Low[bar];
        }

      if(Swing==1 && High[bar]>=BH)
        {
         BH=High[bar];
         zu=bar;
        }

      if(Swing==-1 && Low[bar]<=BL)
        {
         BL=Low[bar];
         zd=bar;
        }

      Swing_n=Swing;
     }

   for(i=1; i<=uzl; i++)
     {
      mv=int(Uzel[i][1]);
      //----      
      if(prev>Uzel[i][2] && IndBuffer[mv]!=Uzel[i][2] && SoundAlertMode && rates_total>alertBar)
        {
         Alert("Dinapoli Target menunjukkan BUY SIGNAL kat ",Symbol()," pada TF ",GetStringTimeframe(Period()));
         alertBar=rates_total;
         prev=Uzel[i][2];
        }

      if(prev<Uzel[i][2] && IndBuffer[mv]!=Uzel[i][2] && SoundAlertMode && rates_total>alertBar)
        {
         Alert("Dinapoli Target menunjukkan SELL SIGNAL kat ",Symbol()," pada TF ",GetStringTimeframe(Period()));
         alertBar=rates_total;
         prev=Uzel[i][2];
        }

      IndBuffer[mv]=Uzel[i][2];
     }

   PointA=Uzel[uzl-2][2];
   PointB=Uzel[uzl-1][2];
   PointC=Uzel[uzl][2];
//----
   Target1=NormalizeDouble((PointB-PointA)*0.618+PointC,_Digits);
   Target2=PointB-PointA+PointC;
   Target3=NormalizeDouble((PointB-PointA)*1.618+PointC,_Digits);
   Fantnsy=NormalizeDouble((PointB-PointA)*2.618+PointC,_Digits);
   CrazyDream=NormalizeDouble((PointB-PointA)*4.618+PointC,_Digits);

   if(PointB<PointC)
     {
      Start=NormalizeDouble((PointB-PointA)*0.318+PointC,_Digits)-_Point*Spread[0];
      Stop=PointC+2*_Point*Spread[0];
     }

   if(PointB>PointC)
     {
      Start=NormalizeDouble((PointB-PointA)*0.318+PointC,_Digits)+_Point*Spread[0];
      Stop=PointC-2*_Point*Spread[0];
     }

   SetHline(0,"Start line",0,Start,Start_line_Color,STYLE_DOT,3,"Start line");
   SetHline(0,"Stop line",0,Stop,Stop_line_Color,STYLE_DOT,3,"Stop line");
   SetHline(0,"Target1 line",0,Target1,Target1_line_Color,STYLE_DOT,3,"Target1 line");
   SetHline(0,"Target2 line",0,Target2,Target2_line_Color,STYLE_DOT,3,"Target2 line");
   SetHline(0,"Target3 line",0,Target3,Target3_line_Color,STYLE_DOT,3,"Target3 line");
//---- 
   ChartRedraw(0);
   return(rates_total);
  }
//+------------------------------------------------------------------+
