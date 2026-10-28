//+------------------------------------------------------------------+
//|                                              Camarillapoints.mq5 |
//|   site:     http://fxstill.com                                   |
//|   Telegram: https://t.me/fxstill (Literature on cryptocurrencies,| 
//|                                   development and code. )        |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"

#property version   "1.00"

#property description "Telegram Channel: https://t.me/fxstill\n"
#property description "Camarillapoints: Slawomir Bobrowski \"Stocks & Commodities V. 31:3 (10-15)\""


#define NAME (string)"Camarillapoints"

const static int DAYINSEC = PeriodSeconds(PERIOD_D1); // 86400;


#property indicator_chart_window

#property indicator_buffers 10
#property indicator_plots   10
//--- 
#property indicator_label1  "S1 Buffer"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrFireBrick
#property indicator_style1  STYLE_DASH
#property indicator_width1  1

#property indicator_label2  "S2 Buffer"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrFireBrick
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
//
#property indicator_label3  "S3 Buffer"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  2
//
#property indicator_label4  "S4 Buffer"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  2
//
#property indicator_label5  "S5 Buffer"
#property indicator_type5   DRAW_LINE
#property indicator_color5  clrPink
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1
//
#property indicator_label6  "R1 Buffer"
#property indicator_type6   DRAW_LINE
#property indicator_color6  clrNavy
#property indicator_style6  STYLE_DASH
#property indicator_width6  1
//
#property indicator_label7  "R2 Buffer"
#property indicator_type7   DRAW_LINE
#property indicator_color7  clrNavy
#property indicator_style7  STYLE_SOLID
#property indicator_width7  1
//
#property indicator_label8  "R3 Buffer"
#property indicator_type8   DRAW_LINE
#property indicator_color8  clrBlue
#property indicator_style8  STYLE_SOLID
#property indicator_width8  2
//
#property indicator_label9  "R4 Buffer"
#property indicator_type9   DRAW_LINE
#property indicator_color9  clrBlue
#property indicator_style9  STYLE_SOLID
#property indicator_width9  2
//
#property indicator_label10  "R5 Buffer"
#property indicator_type10   DRAW_LINE
#property indicator_color10  clrSkyBlue
#property indicator_style10  STYLE_SOLID
#property indicator_width10  1

//--- indicator buffers
double         s1[];
double         s2[];
double         s3[];
double         s4[];
double         s5[];
double         r1[];
double         r2[];
double         r3[];
double         r4[];
double         r5[];

static const int MINBAR = 5;

class CPivotData {
public:
   void    CPivotData() {
   
      m_curCount = DAYINSEC / PeriodSeconds();
      if (m_curCount <= 1) 
         Print("The indicator works on a timeframe below the D1");
         
      k1 = 1.1 / 2;
      k2 = 1.1 / 4;
      k3 = 1.1 / 6;
      k4 = 1.1 / 12;         
   }// CPivotData()
   
   int      InitResult() const {
      return (m_curCount > 1)? INIT_SUCCEEDED: INIT_PARAMETERS_INCORRECT;  //Work only on the D1 timeframe
   }// InitResult()
   
   void     SetLasRates(const MqlRates& r) {
     
      double rg  = r.high - r.low;
      
		m_r5 = (r.high / r.low) * r.close;
		m_r4 = r.close + rg * k1;
		m_r3 = r.close + rg * k2;
		m_r2 = r.close + rg * k3;
		m_r1 = r.close + rg * k4;
		
		m_s1 = r.close - rg * k4;
		m_s2 = r.close - rg * k3;
		m_s3 = r.close - rg * k2;
		m_s4 = r.close - rg * k1;
		m_s5 = r.close - (m_r5 - r.close);      
   }// SetLasRates(MqlRates& r)
   
   void FillBuffers(int shift) {
      s1[shift] = m_s1;
      s2[shift] = m_s2;
      s3[shift] = m_s3;
      s4[shift] = m_s4;
      s5[shift] = m_s5;
      
      r1[shift] = m_r1;
      r2[shift] = m_r2;
      r3[shift] = m_r3;
      r4[shift] = m_r4;
      r5[shift] = m_r5;   
   }// FillBuffers(int shift)
   
private:

   int      m_curCount;
   double   m_s1, m_s2, m_s3, m_s4, m_s5, m_r1, m_r2, m_r3, m_r4, m_r5;
   double   k1, k2, k3, k4;

};

CPivotData cPivot;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()   {

   SetIndexBuffer(0,s1,INDICATOR_DATA);
   SetIndexBuffer(1,s2,INDICATOR_DATA);
   SetIndexBuffer(2,s3,INDICATOR_DATA);
   SetIndexBuffer(3,s4,INDICATOR_DATA);
   SetIndexBuffer(4,s5,INDICATOR_DATA);
   
   SetIndexBuffer(5,r1,INDICATOR_DATA);
   SetIndexBuffer(6,r2,INDICATOR_DATA);
   SetIndexBuffer(7,r3,INDICATOR_DATA);
   SetIndexBuffer(8,r4,INDICATOR_DATA);
   SetIndexBuffer(9,r5,INDICATOR_DATA);

   ArraySetAsSeries(s1,true); 
   ArraySetAsSeries(s2,true); 
   ArraySetAsSeries(s3,true);    
   ArraySetAsSeries(s4,true); 
   ArraySetAsSeries(s5,true); 

   ArraySetAsSeries(r1,true); 
   ArraySetAsSeries(r2,true); 
   ArraySetAsSeries(r3,true); 
   ArraySetAsSeries(r4,true); 
   ArraySetAsSeries(r5,true); 
  
   IndicatorSetString(INDICATOR_SHORTNAME, NAME);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);     

//   return cPivot.InitResult();     // Please uncomment this line !!!!!!!
   return INIT_SUCCEEDED;   
  }

  
  
void GetValue(const double& h[], const double& l[], const double& c[], const datetime& t[], int shift) {
   if (isNewDay(t[shift], t[shift + 1]) ) {
      int d = iBarShift(_Symbol,PERIOD_D1,t[shift]);
      GetDay(d + 1);
   }
   cPivot.FillBuffers(shift);
}// void GetValue(const double& h[]...  

bool GetDay(int shift) {
   MqlRates mrt[1];
   if (CopyRates(_Symbol, PERIOD_D1, shift, 1, mrt ) != 1) {
      Print(" Error in CopyRates: ", GetLastError()," for day: ",shift);
      return false;
   }
   cPivot.SetLasRates(mrt[0]);
   return true;
}//bool GetDay(int shift)


bool isNewDay(datetime now, datetime prv) {

   static datetime tmp = -1;
   if (tmp == now) return false;
   tmp = now;
   
   long dn = now / DAYINSEC;
   long dp = prv / DAYINSEC;
   
   return dn != dp;
}// bool isNewDay(datetime now, datetime prv)     

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
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
      if(rates_total < MINBAR) return 0;
      ArraySetAsSeries(high,   true); 
      ArraySetAsSeries(low,    true);
      ArraySetAsSeries(close,  true);      
      ArraySetAsSeries(time,   true);         
      int limit = rates_total - prev_calculated;
      if (limit == 0)        {   // new tick
      } else if (limit == 1) {   // new bar
         GetValue(high, low, close, time, 1);
         return(rates_total); 
      } else if (limit > 1)  {   // first call
      
         if (!GetDay(1) ) return 0;   //handle 4401 error   
         
         ArrayInitialize(s1, EMPTY_VALUE);
         ArrayInitialize(s2, EMPTY_VALUE);
         ArrayInitialize(s3, EMPTY_VALUE);
         ArrayInitialize(s4, EMPTY_VALUE);
         ArrayInitialize(s5, EMPTY_VALUE);
         
         ArrayInitialize(r1, EMPTY_VALUE);
         ArrayInitialize(r2, EMPTY_VALUE);
         ArrayInitialize(r3, EMPTY_VALUE);
         ArrayInitialize(r4, EMPTY_VALUE);
         ArrayInitialize(r5, EMPTY_VALUE); 
         
         limit = rates_total - MINBAR;
         
         for(int i = limit; i >= 1 && !IsStopped(); i--){
            GetValue(high, low, close, time, i);
         }//for(int i = limit + 1; i >= 0 && !IsStopped(); i--)
         return(rates_total);         
      }
      GetValue(high, low, close, time, 0);

   return(rates_total);
}//int OnCalculate(...

