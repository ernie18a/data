//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "TrendStrength of EMA variation"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_label1  "EMA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrDarkGray
#property indicator_label2  "trend up"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDodgerBlue
#property indicator_width2  2
#property indicator_label3  "trend down"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrSandyBrown
#property indicator_width3  2

//
//--- input parameters
//

input int                inpPeriod      = 32;          // EMA period
input double             inpDivisor     =  2;          // Speed
input ENUM_APPLIED_PRICE inpPrice       = PRICE_CLOSE; // Price
input double             inpStrength    = 4.236;       // Strength

//
//--- indicator buffers
//

double avg[],valu[],vald[];

//------------------------------------------------------------------
// 
//------------------------------------------------------------------
//
//
//

int OnInit()
{
   //
   //---
   //
      SetIndexBuffer(0,avg,INDICATOR_DATA);
      SetIndexBuffer(1,valu,INDICATOR_DATA);
      SetIndexBuffer(2,vald,INDICATOR_DATA);
         iEmaVar.init(inpPeriod,inpDivisor);
         iTrendStrength.init(inpStrength);

   //--- 
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend strength EMA variation ("+(string)inpPeriod+","+(string)inpDivisor+","+(string)inpStrength+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) {  }

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
   int i=  prev_calculated-1; if (i<0) i=0; for(; i<rates_total && !_StopFlag; i++)
   {
      avg[i] = iEmaVar.calculate(getPrice(inpPrice,open,close,high,low,i),i);
         double hval = avg[i];
         double lval = avg[i];
         if(i>0)
         {   
            if(avg[i]>avg[i-1]) lval = avg[i-1];
            if(avg[i]<avg[i-1]) hval = avg[i-1];
         }            
         iTrendStrength.calculate(avg[i],hval,lval,valu[i],vald[i],i);
   }
   return(i);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//

class CTrendStrength
{
   private : 
      int    m_arraySize;
      double m_strength;
      struct sTrendStrengthStruct
      {
         double smin;
         double smax;
         int    trend;
      };
      sTrendStrengthStruct m_array[];
      
   public : 
      CTrendStrength() : m_arraySize(32) { init(1); }
     ~CTrendStrength() {}
  
      ///
      ///
      ///
      
      bool init(double strength)
      {
         m_strength = strength; if (ArrayResize(m_array,m_arraySize)==m_arraySize) return(true);
                                                                                   return(false);
      }
      bool calculate(double value, double valueHi, double valueLow, double& resultUp, double& resultDown, int i)
      {
         int _indC = (i)%m_arraySize; 
                            
         //
         //
         //
                            
         double delta=valueHi-valueLow;
         m_array[_indC].smin  = value - m_strength*delta;
         m_array[_indC].smax  = value + m_strength*delta;
            if (i>0)
            {
               int _indP = (i-1)%m_arraySize; 
                  m_array[_indC].trend = m_array[_indP].trend;
                  if(value > m_array[_indP].smax) m_array[_indC].trend =  1;
                  if(value < m_array[_indP].smin) m_array[_indC].trend = -1;
                  if(m_array[_indC].trend>0) { if(m_array[_indC].smin < m_array[_indP].smin) m_array[_indC].smin=m_array[_indP].smin; resultUp  =m_array[_indC].smin; resultDown=EMPTY_VALUE; }
                  if(m_array[_indC].trend<0) { if(m_array[_indC].smax > m_array[_indP].smax) m_array[_indC].smax=m_array[_indP].smax; resultDown=m_array[_indC].smax; resultUp  =EMPTY_VALUE; }
            }
            else { m_array[_indC].trend = 0; resultUp = resultDown = EMPTY_VALUE; }
         return(true);
      }
};
CTrendStrength iTrendStrength;

//
//---
//

class CEmaVar
{
   #define _ringSize 32
   private :
      double m_period;
      double m_divisor;
      double m_alpha;
      struct sEmaVarStruct
      {
         double ema1;
         double ema2;
      };
      sEmaVarStruct m_array[_ringSize];
   public :
      CEmaVar() { init(1,1); return; }
     ~CEmaVar() {            return; }
     
     //
     //---
     //
     
     bool init(int period, double divisor)
         {
            m_period  = (period>1) ? period : 1;
            m_divisor = (divisor>0) ? divisor : 1;
            m_alpha   = 2.0/(1.0+m_period/m_divisor);
               return(true);
         }
      double calculate(double value, int i)
         {
            int _indC = (i)%_ringSize; 
            int _indP = _indC-1; if (_indP<0) _indP+=_ringSize;
               if (i>0)
               {
                    m_array[_indC].ema1 = m_array[_indP].ema1+m_alpha*(value              -m_array[_indP].ema1); 
                    m_array[_indC].ema2 = m_array[_indP].ema2+m_alpha*(m_array[_indC].ema1-m_array[_indP].ema2); 
               }                    
               else m_array[_indC].ema1 = m_array[_indC].ema2 = value;
            return (m_array[_indC].ema2);
         }
   #undef _ringSize         
};
CEmaVar iEmaVar;
//------------------------------------------------------------------
