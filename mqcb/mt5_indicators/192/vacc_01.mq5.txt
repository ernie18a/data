//+------------------------------------------------------------------+
//|                                                      VAcc_01.mq5 |
//|                                                          victorg |
//+------------------------------------------------------------------+
#property description "VAcc"
//--- indicator settings
#property indicator_separate_window
#property indicator_level1 0.0
#property indicator_levelcolor DarkSlateGray
#property indicator_levelwidth 0
#property indicator_levelstyle STYLE_DOT 
#property indicator_buffers 1
#property indicator_plots   1
#property indicator_type1   DRAW_LINE
#property indicator_color1  DodgerBlue
#property indicator_label1  "VAcc"
//--- input parameters
input int InpAccPeriod=3;  // Acc period (1...100)
input int InpMAPeriod=5;   // MA period  (2...100)
input int InpNHistory=255; // N History  (32...1024)
//--- indicator buffers
double    ExtOutBuffer[];
//--- global variable
int       ExtPeriodAcc;
int       ExtPeriodMA;
int       ExtNHistory;
double    P1,P2;
//+------------------------------------------------------------------+
//| Indicator initialization function                                |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- check for input value
   if(InpAccPeriod<1 || InpAccPeriod>100)
     {
      ExtPeriodAcc=3;
      printf("Incorrect input parameter InpAccPeriod = %d. Indicator will use value %d for calculations.",InpAccPeriod,ExtPeriodAcc);
     }
   else ExtPeriodAcc=InpAccPeriod;
   if(InpMAPeriod<2 || InpMAPeriod>100)
     {
      ExtPeriodMA=3;
      printf("Incorrect input parameter InpMAPeriod = %d. Indicator will use value %d for calculations.",InpMAPeriod,ExtPeriodMA);
     }
   else ExtPeriodMA=InpMAPeriod;
   P1=2.0/(ExtPeriodMA+1); P2=1.0-P1;
   if(InpNHistory<32 || InpNHistory>1024)
     {
      ExtNHistory=255;
      printf("Incorrect input parameter InpNHistory = %d. Indicator will use value %d for calculations.",InpNHistory,ExtNHistory);
     }
   else ExtNHistory=InpNHistory;
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtOutBuffer,INDICATOR_DATA);
//--- установим индексацию для буфера как в таймсерии
   ArraySetAsSeries(ExtOutBuffer,true);
//---
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- name for DataWindow and indicator subwindow label
   string short_name="VAcc("+string(ExtPeriodAcc)+")";
   IndicatorSetString(INDICATOR_SHORTNAME,short_name);
   PlotIndexSetString(0,PLOT_LABEL,short_name);
//--- initialization done
  }
//+------------------------------------------------------------------+
//| Indicator iteration function                                     |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &Time[],
                const double &Open[],
                const double &High[],
                const double &Low[],
                const double &Close[],
                const long &TickVolume[],
                const long &Volume[],
                const int &Spread[])
  {
   int i;

   ArraySetAsSeries(Close,true);
   PlotIndexSetInteger(0,PLOT_DRAW_BEGIN,Bars(Symbol(),0)-ExtNHistory);

   ExtOutBuffer[ExtNHistory+1]=0.0;
   for(i=ExtNHistory;i>=0;i--)ExtOutBuffer[i]=MathLog(Close[i]/Close[i+ExtPeriodAcc])*P1+ExtOutBuffer[i+1]*P2;
   for(i=1;i<ExtNHistory;i++)ExtOutBuffer[i]=ExtOutBuffer[i]*P1+ExtOutBuffer[i-1]*P2;
   for(i=ExtNHistory-1;i>=0;i--) ExtOutBuffer[i]=ExtOutBuffer[i]*P1+ExtOutBuffer[i+1]*P2;
   for(i=1;i<ExtNHistory;i++)ExtOutBuffer[i]=ExtOutBuffer[i]*P1+ExtOutBuffer[i-1]*P2;

   return(rates_total);
  }
//------------------------------------------------------------------
