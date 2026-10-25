//+------------------------------------------------------------------
#property copyright   "© mladen, 2019"
#property link        "mladenfx@gmail.com"
#property description "Trading the trend"
//+------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   2
#property indicator_label1  "Trend candles/bars"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_label2  "Trend line"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrDarkGray,clrDeepSkyBlue,clrSandyBrown
#property indicator_style2  STYLE_DOT

//
//
//

input int     inpPeriod       = 21;  // Look back period
input double  inpMultiplier   = 3;   // Multiplier
input int     inpChannelShift = 1;   // Channel shift
enum enDisplayMode
{
   disp_bars,   // Display bars
   disp_candles // Display candles
};
input enDisplayMode inpDisplayMode = disp_bars; // Display mode

//
//
//

double baro[],barh[],barl[],barc[],barcl[],line[],linecl[];
int _minMaxPeriod;

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,baro  ,INDICATOR_DATA);
   SetIndexBuffer(1,barh  ,INDICATOR_DATA);
   SetIndexBuffer(2,barl  ,INDICATOR_DATA);
   SetIndexBuffer(3,barc  ,INDICATOR_DATA);
   SetIndexBuffer(4,barcl ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(5,line  ,INDICATOR_DATA);
   SetIndexBuffer(6,linecl,INDICATOR_COLOR_INDEX);
      PlotIndexSetInteger(0,PLOT_DRAW_TYPE, inpDisplayMode==disp_bars ? DRAW_COLOR_BARS : DRAW_COLOR_CANDLES);
   
      //
      //
      //
      
      _minMaxPeriod = MathMax(inpPeriod-1,0);
      iLwma.init(inpPeriod);
   
      //
      //
      //
      
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Trading the trend (%i,%.1f shift %i)",inpPeriod,inpMultiplier,inpChannelShift));
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {}


//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

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
   int limit=prev_calculated-1; if (limit<0) limit = 0;
       static datetime prevTime = -1;
       static double   prevMax, prevMin;

   //
   //
   //
   
   int i=limit; for(; i<rates_total && !_StopFlag; i++)
   {
      if (prevTime!=time[i])
      {
         prevTime = time[i];
         int _start = i-inpPeriod-inpChannelShift+1; 
         if (_start<0) _start=0;
               prevMax  = close[ArrayMaximum(close,_start,_minMaxPeriod)];
               prevMin  = close[ArrayMinimum(close,_start,_minMaxPeriod)];
      }        
      
      //
      //
      //
          
         double hi      = (close[i]>prevMax) ? close[i] : prevMax;
         double lo      = (close[i]<prevMin) ? close[i] : prevMin;
         double rhigh   = (i>0) ? (high[i]>close[i-1] ? high[i] : close[i-1]) : high[i];
         double rlow    = (i>0) ? (low[i] <close[i-1] ? low[i]  : close[i-1]) : low[i];
         double tr      = iLwma.calculate(rhigh-rlow,i,rates_total);
         double hiLimit = hi-tr*inpMultiplier;
         double loLimit = lo+tr*inpMultiplier;

      //
      //
      //
               
      line[i]   = (close[i]>loLimit && close[i]>hiLimit) ? hiLimit : (close[i]<loLimit && close[i]<hiLimit) ? loLimit : (i>0) ? line[i-1] : close[i];
      linecl[i] = (close[i]>line[i]) ? 1 : (close[i]<line[i]) ? 2 : (i>0) ? linecl[i-1] : 0;
      barh[i]   = high[i];
      barl[i]   = low[i];
      barc[i]   = close[i];
      baro[i]   = open[i];
      barcl[i]  = linecl[i];
   }
   return (i);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//

class CLwma
{
   private :
      struct sLwmaArrayStruct
         {
            double value;
            double wsumm;
            double vsumm;
         };
      sLwmaArrayStruct m_array[];
      int              m_arraySize;
      int              m_period;
      double           m_weight;
   public :
      CLwma(): m_period(1), m_arraySize(-1), m_weight(1) { }
     ~CLwma()                                            { }
     
      //
      //---
      //

      void   init(int period) { m_period = (period>1) ? period : 1; }
      double calculate(double value, int i, int bars)
      {
            if (m_arraySize<bars) m_arraySize=ArrayResize(m_array,bars+500,2000);
                m_array[i].value = value;
            
                if (i>m_period)
                {
                  m_array[i].wsumm  = m_array[i-1].wsumm+value*m_period-m_array[i-1].vsumm;
                  m_array[i].vsumm  = m_array[i-1].vsumm+value         -m_array[i-m_period].value;
                }
                else
                {
                     m_weight          = 
                     m_array[i].wsumm  = 
                     m_array[i].vsumm  = 0;
                     for(int k=0, w=m_period; k<m_period && i>=k; k++,w--)
                     {
                           m_weight             += w;
                           m_array[i].wsumm += m_array[i-k].value*(double)w;
                           m_array[i].vsumm += m_array[i-k].value;
                     }
                 }
                 return(m_array[i].wsumm/m_weight);
      }
};
CLwma iLwma;