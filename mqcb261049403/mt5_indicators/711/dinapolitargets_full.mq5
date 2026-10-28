//+------------------------------------------------------------------+
//|                                         DinapoliTargets_Full.mq5 |
//|                             Copyright © 2011,   Nikolay Kositsin | 
//|                              Khabarovsk,   farria@mail.redcom.ru | 
//+------------------------------------------------------------------+
//---- author of the indicator
#property copyright "Copyright © 2011, Nikolay Kositsin"
//---- link to the website of the author
#property link "farria@mail.redcom.ru"
//---- indicator version number
#property version   "1.00"
//---- drawing the indicator in the main window
#property indicator_chart_window
//---- number of indicator buffers is 5
#property indicator_buffers 5
//---- 5 graphical plots are used in total
#property indicator_plots   5
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a label
#property indicator_type1   DRAW_ARROW
//---- magenta color is used for the indicator label
#property indicator_color1 Magenta
//---- width of the indicator label
#property indicator_width1  1
//---- displaying the indicator label
#property indicator_label1  "Dinapoli Start line"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a label
#property indicator_type2   DRAW_ARROW
//---- green color is used for the indicator label
#property indicator_color2 Green
//---- width of the indicator label
#property indicator_width2  1
//---- displaying the indicator label
#property indicator_label2  "Dinapoli Target1 line"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a label
#property indicator_type3   DRAW_ARROW
//---- orange color is used for the indicator label
#property indicator_color3 Orange
//---- width of the indicator label
#property indicator_width3  1
//---- displaying the indicator label
#property indicator_label3  "Dinapoli Target2 line"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a label
#property indicator_type4   DRAW_ARROW
//---- DarkOrchid color is used for the indicator label
#property indicator_color4 DarkOrchid
//---- width of the indicator label
#property indicator_width4  1
//---- displaying the indicator label
#property indicator_label4  "Dinapoli Target3 line"
//+-----------------------------------+
//|  Parameters of indicator drawing  |
//+-----------------------------------+
//---- drawing the indicator as a label
#property indicator_type5   DRAW_ARROW
//---- red color is used for the indicator label
#property indicator_color5 Red
//---- width of the indicator label
#property indicator_width5  1
//---- displaying the indicator label
#property indicator_label5  "Dinapoli Stop line"
//+-----------------------------------+
//|  Indicator input parameters       |
//+-----------------------------------+
input int Length=6;        // period of averaging
input int Symbol_H0 = 119; // start level label
input int Symbol_H1 = 119; // level 1 label
input int Symbol_H2 = 119; // level 2 label
input int Symbol_H3 = 119; // level 3 label
input int Symbol_H4 = 119; // stop level label
input int Shift=1;         // horizontal shift of the indicator in bars
//+-----------------------------------+
//---- declaration of the integer variables for the start of data calculation
int min_rates_total;
//---- declaration of dynamic arrays that
//---- will be used as indicator buffers
double H0_Buffer[],H1_Buffer[],H2_Buffer[],H3_Buffer[],H4_Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+  
void OnInit()
  {
//---- initialization of variables of the start of data calculation
   min_rates_total=Length+4;

//---- converting dynamic arrays into indicator buffers
   SetIndexBuffer(0,H0_Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,H1_Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,H2_Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,H3_Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,H4_Buffer,INDICATOR_DATA);

//---- indicator symbols
   PlotIndexSetInteger(0,PLOT_ARROW,Symbol_H0);
   PlotIndexSetInteger(1,PLOT_ARROW,Symbol_H1);
   PlotIndexSetInteger(2,PLOT_ARROW,Symbol_H2);
   PlotIndexSetInteger(3,PLOT_ARROW,Symbol_H3);
   PlotIndexSetInteger(4,PLOT_ARROW,Symbol_H4);

//---- restriction to draw empty values for the indicator
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);

//---- indexing the elements in buffers as in timeseries   
   ArraySetAsSeries(H0_Buffer,true);
   ArraySetAsSeries(H1_Buffer,true);
   ArraySetAsSeries(H2_Buffer,true);
   ArraySetAsSeries(H3_Buffer,true);
   ArraySetAsSeries(H4_Buffer,true);

//---- moving the indicator 1 horizontally
   PlotIndexSetInteger(0,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(1,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(2,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(3,PLOT_SHIFT,Shift);
   PlotIndexSetInteger(4,PLOT_SHIFT,Shift);

//---- name for the data window and the label for sub-windows
   IndicatorSetString(INDICATOR_SHORTNAME,"Dinapoli Targets");
//---- setting the format of accuracy of displaying the indicator
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//----
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
                const long &Tick_volume[],
                const long &Volume[],
                const int &Spread[])
  {
//---- 
   if(rates_total<min_rates_total) return(0);

//---- indexation of elements in arrays as in timeseries  
   ArraySetAsSeries(Time,true);
   ArraySetAsSeries(High,true);
   ArraySetAsSeries(Low,true);
   ArraySetAsSeries(Spread,true);

//---- declaration of local variables    
   int limit,bar,Swing=0,i;
   double PointA,PointB,PointC;
   double Target1,Target2,Target3,Start=0,Stop=0;
   double LL,HH,spread,dPointBA;
   static double Uzel0,Uzel1,Uzel2,BH,BL;
   static int Swing_n;

//---- calculation pf the limit starting index for the loop of recalculation of bars, and the start initialization of variables
   if(prev_calculated>rates_total || prev_calculated<=0)// checking for the first start of the indicator calculation
     {
      limit=rates_total-min_rates_total; // starting index for calculation of all bars

      Uzel0=0;
      Uzel1=0;
      Uzel2=0;
      Swing=0;
      Swing_n=0;
      int startbar=int(rates_total-min_rates_total);
      BH=High[startbar];
      BL=Low[startbar];
      Start=0.0;
      Stop=0.0;
     }
   else limit=rates_total-prev_calculated; // starting index for calculation of new bars

//----
   for(bar=limit; bar>=0; bar--)
     {
      LL=10000000;
      HH=-100000000;

      H0_Buffer[bar]=EMPTY_VALUE;
      H1_Buffer[bar]=EMPTY_VALUE;
      H2_Buffer[bar]=EMPTY_VALUE;
      H3_Buffer[bar]=EMPTY_VALUE;
      H4_Buffer[bar]=EMPTY_VALUE;

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

      PointA=Uzel2;
      PointB=Uzel1;
      PointC=Uzel0;

      dPointBA=PointB-PointA;
      Target1=NormalizeDouble(dPointBA*0.618+PointC,_Digits);
      Target2=dPointBA+PointC;
      Target3=NormalizeDouble(dPointBA*1.618+PointC,_Digits);
      spread=Spread[bar]*_Point;

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

      H0_Buffer[bar]=Start;
      H1_Buffer[bar]=Target1;
      H2_Buffer[bar]=Target2;
      H3_Buffer[bar]=Target3;
      H4_Buffer[bar]=Stop;
     }
//----   
   return(rates_total);
  }
//+------------------------------------------------------------------+
