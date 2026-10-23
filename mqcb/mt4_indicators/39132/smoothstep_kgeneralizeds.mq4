//---------------------------------------------------------------------------------------------------------------------
#property copyright   "© mladen, 2022"
#property link        "mladenfx@gmail.com"
//---------------------------------------------------------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_label1  "SmoothStep up"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  2
#property indicator_label2  "SmoothStep down"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrCoral
#property indicator_width2  2
#property indicator_label3  "SmoothStep down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrCoral
#property indicator_width3  2
#property indicator_level1  0.2
#property indicator_level2  0.8
#property strict

//
//
//

input int             inpPeriod = 32;       // Period
   enum enPrices
         {
            pr_close,      // Close
            pr_open,       // Open
            pr_high,       // High
            pr_low,        // Low
            pr_median,     // Median
            pr_typical,    // Typical
            pr_weighted,   // Weighted
            pr_lowhigh,    // Low/High/Close
         };
input enPrices        inpPrice = pr_close; // Price         
input int             inpOrder = 1;        // Order

//
//
//

double val[],valda[],valdb[],valc[];
struct sGlobalStruct
{
   int period;
   int order;
};
sGlobalStruct global;

//---------------------------------------------------------------------------------------------------------------------
//                                                                  
//---------------------------------------------------------------------------------------------------------------------
//
//
//

int OnInit()
{
   IndicatorBuffers(4);
   SetIndexBuffer(0,val  ,INDICATOR_DATA);
   SetIndexBuffer(1,valda,INDICATOR_DATA);
   SetIndexBuffer(2,valdb,INDICATOR_DATA);
   SetIndexBuffer(3,valc ,INDICATOR_CALCULATIONS);
   
      //
      //
      //

      global.period  = MathMax(inpPeriod,1);
      global.order   = MathMax(MathMin(inpOrder,16),0);
         
         //
         //
         //
         
         PlotIndexSetString(0,PLOT_LABEL,"SmoothStep "+(string)global.order+" order");
   IndicatorSetString(INDICATOR_SHORTNAME,StringFormat("Smooth step (%i, order %i)",global.period,global.order));
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return;}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

int OnCalculate (const int       rates_total,
                 const int       prev_calculated,
                 const datetime& time[],
                 const double&   open[],
                 const double&   high[],
                 const double&   low[],
                 const double&   close[],
                 const long&     tick_volume[],
                 const long&     volume[],
                 const int&      spread[] )
{
   int limit = (prev_calculated>0) ? rates_total-prev_calculated : rates_total-1;
      
   //
   //
   //

         static double m_lows[];  
         static int    m_lowsSize  = -1; 
                   if (m_lowsSize <rates_total) m_lowsSize = ArrayResize(m_lows ,rates_total+500,2000);
         static double m_highs[]; 
         static int    m_highsSize = -1; 
                   if (m_highsSize<rates_total) m_highsSize = ArrayResize(m_highs,rates_total+500,2000);
         struct sWorkStruct   
            {
                  int    prevBar;
                  double prevmin;
                  double prevmax;
            };
         static sWorkStruct m_work[];
         static int         m_workSize= -1;
                        if (m_workSize<=rates_total) m_workSize = ArrayResize(m_work,rates_total+500,2000);  
      
      //
      //
      //
      
      if (valc[limit]==2) iCleanPoint(limit,rates_total,valda,valdb);
      for(int i=limit, r=rates_total-i-1; i>=0; i--,r++)
         {
            double _price  = close[i];
            double _priceh = close[i];
            double _pricel = close[i];
            
            //
            //
            //
            
               switch (inpPrice)
                  {
                     case pr_close    : _price  = _priceh = _pricel = close[i]; break;
                     case pr_open     : _price  = _priceh = _pricel = open[i];  break;
                     case pr_high     : _price  = _priceh = _pricel = high[i];  break;
                     case pr_low      : _price  = _priceh = _pricel = low[i];   break;
                     case pr_median   : _price  = _priceh = _pricel = (high[i]+low[i])/2.0; break;
                     case pr_typical  : _price  = _priceh = _pricel = (high[i]+low[i]+close[i])/3.0; break;
                     case pr_weighted : _price  = _priceh = _pricel = (high[i]+low[i]+close[i]*2.0)/4.0; ; break;
                     case pr_lowhigh  : _price  = close[i]; 
                                        _priceh = high[i]; 
                                        _pricel = low[i]; 
                                        break;
                  }
                  m_lows[r]  = _pricel;      
                  m_highs[r] = _priceh;      

                  //
                  //
                  //
      
                  if (m_work[r].prevBar!=i)
                     {
                        m_work[r  ].prevBar = i;
                        m_work[r+1].prevBar =-1;
      
                        if (r>0 && global.period>1)
                              {
                                 int _minMaxPeriod = global.period-1; 
                                 int _start        = r-global.period+1; if(_start<0) { _start = 0; _minMaxPeriod = r+1; }
                                          m_work[r].prevmin = m_lows [ArrayMinimum(m_lows ,_minMaxPeriod,_start)];
                                          m_work[r].prevmax = m_highs[ArrayMaximum(m_highs,_minMaxPeriod,_start)];
                              }
                        else
                              {
                                          m_work[r].prevmin = m_lows[i];
                                          m_work[r].prevmax = m_highs[i];
                              }
                     }
         
                  double min = (m_work[r].prevmin < _pricel) ? m_work[r].prevmin : _pricel;
                  double max = (m_work[r].prevmax > _priceh) ? m_work[r].prevmax : _priceh;
                  double raw = (max!=min) ? (_price - min)/(max- min) : 0;
                  
                  double result = 0;
                     for (int k = 0; k<=global.order; ++k)
                           result += iPascalTriangle(-global.order-1, k) * iPascalTriangle(2 * global.order + 1, global.order - k) * MathPow(raw, global.order + k + 1);

            //
            //
            //
            
            val[i]  = MathMin(MathMax(result,0),1.0);
            valc[i] = (r>0) ? (val[i]>val[i+1]) ? 1 : (val[i]<val[i+1]) ? 2 : valc[i+1] : 0;
            if (valc[i]==2) iPlotPoint(i,rates_total,valda,valdb,val); else valda[i] = valdb[i] = EMPTY_VALUE;
         }
   
   //
   //
   //
   
   return (rates_total);
}

//---------------------------------------------------------------------------------------------------------------------
//                                                                  
//---------------------------------------------------------------------------------------------------------------------
//
//
//

double iPascalTriangle(int a, int b)
{
  double result = 1.0; for (int i=0; i<b; ++i) result *= (a-i)/(i+1.0);
  return(result);
   
}

//
//
//

void iCleanPoint(int i,int bars, double& first[],double& second[])
{
   if (i>=bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void iPlotPoint(int i, int bars, double& first[],double& second[],double& from[])
{
   if (i>=bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}
