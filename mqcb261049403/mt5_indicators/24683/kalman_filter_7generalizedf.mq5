//------------------------------------------------------------------
#property copyright "© mladen, 2019"
#property link      "mladenfx@gmail.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots   1
#property indicator_label1  "Kalman filter"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrDarkGray,clrMediumSeaGreen,clrOrangeRed
#property indicator_width1  2

//
//--- input parameters
//

input double             inpPeriod = 1;           // Period/smoothing ratio
input ENUM_APPLIED_PRICE inpPrice  = PRICE_CLOSE; // Price

//
//--- indicator buffers
//

double val[],valc[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------ 
//
//
//

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
      SetIndexBuffer(0,val,INDICATOR_DATA);
      SetIndexBuffer(1,valc,INDICATOR_COLOR_INDEX);
         iKalmanFilter.init(inpPeriod);
   //      
   //--- indicator short name assignment
   //
   IndicatorSetString(INDICATOR_SHORTNAME,"Kalman filter ("+(string)inpPeriod+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------
//
//---
//

int  OnCalculate( const int        rates_total,
                  const int        prev_calculated,
                  const int        begin,
                  const double&    price[])
{
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _velocity;
      val[i]  = iKalmanFilter.calculate((price[i]==EMPTY_VALUE ? 0 : price[i]),_velocity,i,rates_total);
      valc[i] = (_velocity>0) ?  1 :(_velocity<0) ? 2 : 0;
   }
   return(i);
}

//------------------------------------------------------------------
// Custom functions
//------------------------------------------------------------------
//
//---
//

class CKalmanFilter
{
   private :
      double m_period;
      double m_coeff;
      struct sKalmanFilter
      {
         double filter;
         double velocity;
      };
      sKalmanFilter m_array[];
      int           m_arraySize;
      
   public :      
      CKalmanFilter() : m_arraySize(-1) {};
     ~CKalmanFilter()                   {};
     
      //
      //
      //
      
      void init (double period)
      {
         m_coeff  = (period>0 ? period : 1.0)/100.0;
         m_period = MathSqrt(m_coeff);
      }
      double calculate(double value,double& velocity, int i, int bars)
      {
         if (m_arraySize<bars) m_arraySize = ArrayResize(m_array,bars+500);
         
         if (i>0)
         {
            double _distance = value-m_array[i-1].filter;
            double _error    = m_array[i-1].filter+_distance*m_period;
                               m_array[i].velocity = m_array[i-1].velocity+_distance*m_coeff;
                               m_array[i].filter   = _error+m_array[i].velocity;
         }
         else { m_array[i].filter = value; m_array[i].velocity = 0; }
         velocity = m_array[i].velocity; 
             return(m_array[i].filter);
      }
};
CKalmanFilter iKalmanFilter;
//------------------------------------------------------------------
