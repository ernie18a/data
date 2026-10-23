//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   1
#property indicator_label1  "Squeeze candles"
#property indicator_type1   DRAW_COLOR_BARS
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed

//
//
//

input int     inpPeriod        = 25; // Period
input double  inpDevMultiplier = 1;  // Deviation multiplier
input double  inpAtrMultiplier = 1;  // ATR multiplier

//
//
//
double cano[],canh[],canl[],canc[],valc[];

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //
   //
         SetIndexBuffer(0,cano,INDICATOR_DATA);
         SetIndexBuffer(1,canh,INDICATOR_DATA);
         SetIndexBuffer(2,canl,INDICATOR_DATA);
         SetIndexBuffer(3,canc,INDICATOR_DATA);
         SetIndexBuffer(4,valc,INDICATOR_COLOR_INDEX);
            iSqueeze.init(inpPeriod,inpDevMultiplier,inpAtrMultiplier);
   //
   //
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Squeeze ("+(string)inpPeriod+","+(string)inpDevMultiplier+","+(string)inpAtrMultiplier+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
   static int _displayType = -1;
          if (_displayType!=ChartGetInteger(0,CHART_MODE))
          {
             _displayType = (int)ChartGetInteger(0,CHART_MODE);
             if (_displayType==CHART_CANDLES)
                  PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_CANDLES);
             else PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_COLOR_BARS);
          }
   //
   //---
   //
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      cano[i] = open[i];
      canh[i] = high[i];
      canl[i] = low[i];
      canc[i] = close[i];
      double val = iSqueeze.calculate(close,high,low,i,rates_total);
             valc[i] = (val==1) ? 1 : (val==-1) ? 2 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
//
//---
//

class cSqueeze
{
   private :
      int    m_period;
      int    m_arraySize;
      double m_devMultiplier;
      double m_atrMultiplier;
         struct sSqueezeStruct
         {
            public :
               double price;
               double price2;
               double sum;
               double sum2;
               double tr;
               double sumtr;
         };
      sSqueezeStruct m_array[];
   public:
      cSqueeze() : m_period(1), m_arraySize(-1), m_devMultiplier(2) {                     }
     ~cSqueeze()                                                    { ArrayFree(m_array); }

      ///
      ///
      ///

      void init(int period, double devMultiplier, double atrMultiplier)
      {
         m_period        = (period>1) ? period : 1;
         m_devMultiplier = devMultiplier;
         m_atrMultiplier = atrMultiplier;
      }
      
      template <typename T>
      double calculate(T& close[], T& high[], T& low[], int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize=ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
         
            m_array[i].price  = close[i];
            m_array[i].price2 = close[i]*close[i];
            m_array[i].tr     = (i>0) ? (close[i-1] < high[i] ? high[i] : close[i-1]) - (close[i-1] > low[i] ? low[i] : close[i-1]) : high[i]-low[i];
            
            //
            //---
            //
            
            if (i>m_period)
            {
               m_array[i].sum   = m_array[i-1].sum  +m_array[i].price -m_array[i-m_period].price;
               m_array[i].sum2  = m_array[i-1].sum2 +m_array[i].price2-m_array[i-m_period].price2;
               m_array[i].sumtr = m_array[i-1].sumtr+m_array[i].tr    -m_array[i-m_period].tr;
            }
            else  
            {
               m_array[i].sum   = m_array[i].price;
               m_array[i].sum2  = m_array[i].price2; 
               m_array[i].sumtr = m_array[i].tr; 
               for(int k=1; k<m_period && i>=k; k++) 
               {
                  m_array[i].sum   += m_array[i-k].price; 
                  m_array[i].sum2  += m_array[i-k].price2; 
                  m_array[i].sumtr += m_array[i-k].tr; 
               }                  
            }       
            double _dev = MathSqrt((m_array[i].sum2-m_array[i].sum*m_array[i].sum/(double)m_period)/(double)m_period);
            double _atr = m_array[i].sumtr/(double)m_period;
            double _avg = m_array[i].sum  /(double)m_period;
            return ((m_devMultiplier*_dev)>(m_atrMultiplier*_atr) ? (high[i]+low[i])/2.0>_avg ? 1 : -1 : 0);
      }
};
cSqueeze iSqueeze;
//------------------------------------------------------------------