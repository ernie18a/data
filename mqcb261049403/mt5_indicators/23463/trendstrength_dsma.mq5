//------------------------------------------------------------------
#property copyright   "© mladen, 2018"
#property link        "mladenfx@gmail.com"
#property description "TrendStrength of deviation scaled MA"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_plots   3
#property indicator_label1  "DSMA"
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

input int                inpPeriod      = 32;          // DSMA period
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
         iDsma.init(inpPeriod);
         iTrendStrength.init(inpStrength);

   //--- 
   IndicatorSetString(INDICATOR_SHORTNAME,"Trend strength DSMA ("+(string)inpPeriod+","+(string)inpStrength+")");
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
      avg[i] = iDsma.calculate(getPrice(inpPrice,open,close,high,low,i),i);
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

class cDsma
{
   private :
         bool   m_OK;
         int    m_period;
         int    m_arraysize;
         double m_periodMultiplier;
         double m_sc1;
         double m_sc2;
         double m_sc3;
            struct sDsmaArray
            {
               double filter;
               double price;
               double dsm;
               double ssm;
               double mul;
               double sum;
            };
         sDsmaArray m_array[];
                     
   public : 
         cDsma() { init(1); }
        ~cDsma() {          };
   
         ///
         ///
         ///
         
         bool init(int period)
         {
            m_period           = (period>1) ? period : 1;
            m_periodMultiplier = 5.0 / (double)m_period;
            m_arraysize        = m_period+32;
            m_OK               = (ArrayResize(m_array,m_arraysize)==m_arraysize);

                  double a1 = MathExp(-1.414*M_PI_2/m_period);
                      m_sc2 = 2.0*a1*MathCos(1.414*M_PI/m_period);
                      m_sc3 = -a1*a1;
                      m_sc1 = 1.0 - m_sc2 - m_sc3;
            return(m_OK);
         }
         double calculate(double price, int i)
         {
            if (!m_OK) return(price);
            int _indC = (i)%m_arraysize; m_array[_indC].price = price;
            
            //
            //---
            //
            
            if (i>1)
            {
               int _indP  = (i-1)%m_arraysize;
               int _indP2 = (i-2)%m_arraysize;
                     m_array[_indC].filter = m_array[_indC].price-m_array[_indP2].price;
                     m_array[_indC].ssm    = m_sc1*(m_array[_indC].filter+m_array[_indP].filter)/2.0 + 
                                             m_sc2*m_array[_indP ].ssm                               + 
                                             m_sc3*m_array[_indP2].ssm; 
                    
                     m_array[_indC].mul = m_array[_indC].ssm*m_array[_indC].ssm;
                     if  (i>m_period)
                            m_array[_indC].sum = m_array[_indP].sum+m_array[_indC].mul-m_array[(i-m_period)%m_arraysize].mul;
                     else { m_array[_indC].sum = m_array[_indC].mul; for (int k=1; k<m_period && i>=k; k++) m_array[_indC].sum += m_array[_indC-k].mul; }
                     
                     //
                     //---
                     //
                     
                     double  rms        = m_array[_indC].sum ? MathSqrt(m_array[_indC].sum / m_period) : 1;
                     double _scaledFilt = m_array[_indC].ssm / rms;
                     double _alpha      = (_scaledFilt>0 ? _scaledFilt : -_scaledFilt) * m_periodMultiplier;
         
                     m_array[_indC].dsm = m_array[_indP].dsm+_alpha*(price-m_array[_indP].dsm);
            }
            else { m_array[_indC].dsm = price; m_array[_indC].ssm = m_array[_indC].mul = m_array[_indC].filter = 0; }
            return(m_array[_indC].dsm);
         }
};
cDsma iDsma;
//------------------------------------------------------------------
