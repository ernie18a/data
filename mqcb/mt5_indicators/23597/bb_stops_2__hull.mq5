//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "Bollinger bands stops - Hull moving average based with multiple stops"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 8
#property indicator_plots   8
#property indicator_label1  "Bollinger bands stops up stop line"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDodgerBlue
#property indicator_width1  3
#property indicator_label2  "Bollinger bands stops down stop line"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrSandyBrown
#property indicator_width2  3
#property indicator_label3  "Bollinger bands stops up first stop line"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrDodgerBlue
#property indicator_label4  "Bollinger bands stops down first stop line"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrSandyBrown
#property indicator_label5  "Bollinger bands stops up second stop line"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrDodgerBlue
#property indicator_label6  "Bollinger bands stops down second stop line"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrSandyBrown
#property indicator_label7  "Bollinger bands stops up trend start"
#property indicator_type7   DRAW_ARROW
#property indicator_color7  clrDodgerBlue
#property indicator_width7  2
#property indicator_label8  "Bollinger bands stops down trend start"
#property indicator_type8   DRAW_ARROW
#property indicator_color8  clrSandyBrown
#property indicator_width8  2

//
//--- input parameters
//

input int                inpPeriod    = 32;          // Hull period
input double             inpDivisor   = 1.75;         // Hull divisor ("speed")
input ENUM_APPLIED_PRICE inpPrice     = PRICE_CLOSE; // Price
input int                inpDevPeriod = 0;           // Deviation period (<=1 for same as average period)
input double             inpDeviation = 2;           // Deviation multiplier
input string             __º__01_00   = "";          // .
input string             __º__01_01   = "";          // Risk settings
input string             __º__01_02   = "";          // .
input double             inpRisk      = 0.75;        // Risk multiplier
input double             inpRisk2     = 1.5;         // Risk 2 multiplier
input double             inpRisk3     = 2.5;         // Risk 3 multiplier

//
//--- indicator buffers
//

double lineup[],linedn[],lineup2[],linedn2[],lineup3[],linedn3[],arrowup[],arrowdn[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   SetIndexBuffer(0,lineup ,INDICATOR_DATA);
   SetIndexBuffer(1,linedn ,INDICATOR_DATA);
   SetIndexBuffer(2,lineup2,INDICATOR_DATA);
   SetIndexBuffer(3,linedn2,INDICATOR_DATA);
   SetIndexBuffer(4,lineup3,INDICATOR_DATA);
   SetIndexBuffer(5,linedn3,INDICATOR_DATA);
   SetIndexBuffer(6,arrowup,INDICATOR_DATA); PlotIndexGetInteger(6,PLOT_ARROW,159);
   SetIndexBuffer(7,arrowdn,INDICATOR_DATA); PlotIndexGetInteger(7,PLOT_ARROW,159);
         double _risks[3];
                _risks[0] = inpRisk;
                _risks[1] = inpRisk2;
                _risks[2] = inpRisk3; ArraySort(_risks);
         int _devPeriod = inpDevPeriod>1 ? inpDevPeriod : (int)inpPeriod;
            iHull.init(inpPeriod,inpDivisor);
            iBbStops.init(_devPeriod,inpDeviation,_risks[0],_risks[1],_risks[2]);
   return(INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { return; }

//------------------------------------------------------------------
// Custom iteration function
//------------------------------------------------------------------
//
//
//

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime& time[],
                const double& open[],
                const double& high[],
                const double& low[],
                const double& close[],
                const long& tick_volume[],
                const long& volume[],
                const int& spread[])
{                
   static double _results[8] = {EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE,EMPTY_VALUE};
   int i= prev_calculated-1; if (i<0) i=0; for (; i<rates_total && !_StopFlag; i++)
   {
      double _price = getPrice(inpPrice,open,close,high,low,i);
      double _avg   = iHull.calculate(_price,i,rates_total);
         iBbStops.calculate(_price,_avg,i,_results);
               lineup[i]  = _results[4];
               linedn[i]  = _results[5];
               lineup2[i] = _results[0];
               linedn2[i] = _results[1];
               lineup3[i] = _results[2];
               linedn3[i] = _results[3];
               arrowup[i] = (_results[6] && _results[7]== 1) ? lineup[i] : EMPTY_VALUE;
               arrowdn[i] = (_results[6] && _results[7]==-1) ? linedn[i] : EMPTY_VALUE;
   }          
   return(i);
}
//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//---
//

class CHull
{
   private :
      int    m_fullPeriod;
      int    m_halfPeriod;
      int    m_sqrtPeriod;
      int    m_arraySize;
      double m_weight1;
      double m_weight2;
      double m_weight3;
      struct sHullArrayStruct
         {
            double price;
            double price3;
            double wsum1;
            double wsum2;
            double wsum3;
            double lsum1;
            double lsum2;
            double lsum3;
         };
      sHullArrayStruct m_array[];
   
   public :
      CHull() { init(1,2.0); };
     ~CHull() { ArrayFree(m_array); };
     
     ///
     ///
     ///
     
      bool init(int period, double divisor)
      {
            m_fullPeriod = (int)(period>1 ? period : 1);   
            m_halfPeriod = (int)(m_fullPeriod>1 ? m_fullPeriod/(divisor>1 ? divisor : 1) : 1);
            m_sqrtPeriod = (int) MathSqrt(m_fullPeriod);
            m_arraySize  = -1; m_weight1 = m_weight2 = m_weight3 = 1;
               return(true);
      }
      
      double calculate( double value, int i, int bars)
      {
         if (m_arraySize<bars) { m_arraySize = ArrayResize(m_array,bars+500); if (m_arraySize<bars) return(0); }
            
            //
            //
            //
             
            m_array[i].price=value;
            if (i>m_fullPeriod)
            {
               m_array[i].wsum1 = m_array[i-1].wsum1+value*m_halfPeriod-m_array[i-1].lsum1;
               m_array[i].lsum1 = m_array[i-1].lsum1+value-m_array[i-m_halfPeriod].price;
               m_array[i].wsum2 = m_array[i-1].wsum2+value*m_fullPeriod-m_array[i-1].lsum2;
               m_array[i].lsum2 = m_array[i-1].lsum2+value-m_array[i-m_fullPeriod].price;
            }
            else
            {
               m_array[i].wsum1 = m_array[i].wsum2 =
               m_array[i].lsum1 = m_array[i].lsum2 = m_weight1 = m_weight2 = 0;
               for(int k=0, w1=m_halfPeriod, w2=m_fullPeriod; w2>0 && i>=k; k++, w1--, w2--)
               {
                  if (w1>0)
                  {
                     m_array[i].wsum1 += m_array[i-k].price*w1;
                     m_array[i].lsum1 += m_array[i-k].price;
                     m_weight1 += w1;
                  }                  
                  m_array[i].wsum2 += m_array[i-k].price*w2;
                  m_array[i].lsum2 += m_array[i-k].price;
                  m_weight2 += w2;
               }
            }
            m_array[i].price3=2.0*m_array[i].wsum1/m_weight1-m_array[i].wsum2/m_weight2;
         
            // 
            //---
            //
         
            if (i>m_sqrtPeriod)
            {
               m_array[i].wsum3 = m_array[i-1].wsum3+m_array[i].price3*m_sqrtPeriod-m_array[i-1].lsum3;
               m_array[i].lsum3 = m_array[i-1].lsum3+m_array[i].price3-m_array[i-m_sqrtPeriod].price3;
            }
            else
            {  
               m_array[i].wsum3 =
               m_array[i].lsum3 = m_weight3 = 0;
               for(int k=0, w3=m_sqrtPeriod; w3>0 && i>=k; k++, w3--)
               {
                  m_array[i].wsum3 += m_array[i-k].price3*w3;
                  m_array[i].lsum3 += m_array[i-k].price3;
                  m_weight3 += w3;
               }
            }         
         return(m_array[i].wsum3/m_weight3);
      }
};
CHull iHull;

//
//---
//

class CEmaDeviation
{
   #define _ringSize 32
   private :
      double m_period;
      double m_divisor;
      double m_alpha;
      int    m_workSize;
      struct sEmaDeviationStruct
      {
         double ema0;
         double ema1;
      };
      sEmaDeviationStruct m_work[_ringSize];
   
   public : 
      CEmaDeviation() { init(1); }
     ~CEmaDeviation() { }
     
     ///
     ///
     ///
     
     bool init(double period)
     {
         m_period  = (period>1) ? period : 1;
         m_divisor = (m_period>2) ? m_period-1 : 1;
         m_alpha   = (2.0/(2.0+(period-1.0)/2.0));
         return(true);
     }
     
     double calculate(double price, int i)
     {
         int _indC = (i)%_ringSize;
         if (i>0)
         {
            int _indP  = (i-1)%_ringSize;
               m_work[_indC].ema0 = m_work[_indP].ema0+m_alpha*(price      -m_work[_indP].ema0);
               m_work[_indC].ema1 = m_work[_indP].ema1+m_alpha*(price*price-m_work[_indP].ema1);
         }         
         else m_work[_indC].ema0 = m_work[_indC].ema1 = price;
   
         return(MathSqrt(m_period*(m_work[_indC].ema1-m_work[_indC].ema0*m_work[_indC].ema0)/m_divisor));
      }      
   #undef _ringSize
};

//
//
//

class CBbStops
{
   #define _ringSize 32
   private :
      int            m_devPeriod;
      double         m_devMultiplier;
      double         m_risk1;
      double         m_risk2;
      double         m_risk3;
      CEmaDeviation* m_emaDeviation;
      struct sBbStopsStruct
      {
         double amax;
         double amin;
         double bmax;
         double bmin;
         double cmax;
         double cmin;
         double dmax;
         double dmin;
         double trend;
      };  
      sBbStopsStruct m_work[_ringSize];
   
   public : 
      CBbStops() { init(1,1,1,1,1); };
     ~CBbStops() { if (CheckPointer(m_emaDeviation)==POINTER_DYNAMIC) delete(m_emaDeviation); };
      
      ///
      ///
      ///
      
      bool init(int devPeriod, double devMultiplier, double risk1, double risk2, double risk3)
      {
         if (CheckPointer(m_emaDeviation) != POINTER_DYNAMIC)
                          m_emaDeviation  = new CEmaDeviation;
         if (CheckPointer(m_emaDeviation) != POINTER_DYNAMIC) return(false);
            
            //
            //
            //
            
            m_devPeriod     = (devPeriod>1) ? devPeriod : 1;
            m_devMultiplier = (devMultiplier>0) ? devMultiplier : 0;
            m_emaDeviation.init(m_devPeriod);
               m_risk1 = risk1;
               m_risk2 = risk2;
               m_risk3 = risk3;
            return(true);
      }

      void calculate(double value, double average, int i, double& result[])
      {
         int _indC = (i  )%_ringSize;
         int _indP = (i-1)%_ringSize;
   
         //
         //---
         //
   
         double deviation = m_emaDeviation.calculate(value,i);
            m_work[_indC].amax  = average + m_devMultiplier*deviation;
            m_work[_indC].amin  = average - m_devMultiplier*deviation;
            m_work[_indC].bmax  = average + m_risk1        *deviation;
            m_work[_indC].bmin  = average - m_risk1        *deviation;
            m_work[_indC].cmax  = average + m_risk2        *deviation;
            m_work[_indC].cmin  = average - m_risk2        *deviation;
            m_work[_indC].dmax  = average + m_risk3        *deviation;
            m_work[_indC].dmin  = average - m_risk3        *deviation;
            if (i>0)
            {
               m_work[_indC].trend = (value > m_work[_indP].amax) ? 1 : (value < m_work[_indP].amin) ? -1 : m_work[_indP].trend;
               if (m_work[_indC].trend==-1)
               {
                  if (m_work[_indC].amax > m_work[_indP].amax) m_work[_indC].amax = m_work[_indP].amax;
                  if (m_work[_indC].bmax > m_work[_indP].bmax) m_work[_indC].bmax = m_work[_indP].bmax;
                  if (m_work[_indC].cmax > m_work[_indP].cmax) m_work[_indC].cmax = m_work[_indP].cmax;
                  if (m_work[_indC].dmax > m_work[_indP].dmax) m_work[_indC].dmax = m_work[_indP].dmax;
                     result[0] = result[2] = result[4] = EMPTY_VALUE;
                     result[1] = m_work[_indC].bmax;
                     result[3] = m_work[_indC].cmax;
                     result[5] = m_work[_indC].dmax;
               }         
               if (m_work[_indC].trend==1)
               {
                  if (m_work[_indC].amin < m_work[_indP].amin) m_work[_indC].amin = m_work[_indP].amin;
                  if (m_work[_indC].bmin < m_work[_indP].bmin) m_work[_indC].bmin = m_work[_indP].bmin;
                  if (m_work[_indC].cmin < m_work[_indP].cmin) m_work[_indC].cmin = m_work[_indP].cmin;
                  if (m_work[_indC].dmin < m_work[_indP].dmin) m_work[_indC].dmin = m_work[_indP].dmin;
                     result[1] = result[3] = result[5] = EMPTY_VALUE;
                     result[0] = m_work[_indC].bmin;
                     result[2] = m_work[_indC].cmin;
                     result[4] = m_work[_indC].dmin;
               }
               result[6] = (m_work[_indC].trend != m_work[_indP].trend);
            }                  
            else m_work[_indC].trend = result[6] = 0;

         //
         //---
         //
      
         result[7] =  m_work[_indC].trend;
      }
   #undef _ringSize
};
CBbStops iBbStops;

//
//---
//

double getPrice(ENUM_APPLIED_PRICE tprice,const double &open[],const double &close[],const double &high[],const double &low[],int i)
{
   switch(tprice)
   {
      case PRICE_CLOSE:     return(close[i]);
      case PRICE_OPEN:      return(open[i]);
      case PRICE_HIGH:      return(high[i]);
      case PRICE_LOW:       return(low[i]);
      case PRICE_MEDIAN:    return((high[i]+low[i])/2.0);
      case PRICE_TYPICAL:   return((high[i]+low[i]+close[i])/3.0);
      case PRICE_WEIGHTED:  return((high[i]+low[i]+close[i]+close[i])/4.0);
   }
   return(0);
}