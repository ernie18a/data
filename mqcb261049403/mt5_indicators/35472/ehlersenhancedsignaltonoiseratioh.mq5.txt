//+------------------------------------------------------------------+
//|                            Ehlers EnhancedSignalToNoiseRatio.mq5 |
//|                                Copyright 2020, Andrei Novichkov. |
//|                                               http://fxstill.com |
//|   Telegram: https://t.me/fxstill (Literature on cryptocurrencies,|
//|                                   development and code. )        |
//+------------------------------------------------------------------+

#property copyright "Copyright 2020, Andrei Novichkov."
#property link      "http://fxstill.com"
#property version   "1.00"
#property description "The Enhanced Signal To Noise Ratio:\nJohn Ehlers, \"Rocket Science for Traders.\", pg.87-88"


#property indicator_separate_window

#property indicator_level1     (double)6
#property indicator_levelstyle STYLE_SOLID

#property indicator_buffers 17
#property indicator_plots   1

#property indicator_type1   DRAW_COLOR_LINE 
#property indicator_width1  2
#property indicator_style1  STYLE_SOLID
#property indicator_color1  clrGreen, clrRed, clrLimeGreen 


double snr[];
double cf[]; 
double q3[], noise[];

double Smooth[], Detrender[], I1[], Q1[], jI[], jQ[], I2[], Q2[], Re[], Im[], Per[], SmoothPeriod[], price[]; 

static int MINBAR = 7;

int OnInit()  {

   SetIndexBuffer(0,snr,INDICATOR_DATA);
   SetIndexBuffer(1,cf,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(2,q3,INDICATOR_CALCULATIONS);
   SetIndexBuffer(3,noise,INDICATOR_CALCULATIONS);
   
   SetIndexBuffer(4,Smooth,INDICATOR_CALCULATIONS);
   SetIndexBuffer(5,Detrender,INDICATOR_CALCULATIONS);
   SetIndexBuffer(6,I1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(7,Q1,INDICATOR_CALCULATIONS);
   SetIndexBuffer(8,jI,INDICATOR_CALCULATIONS);
   SetIndexBuffer(9,jQ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,I2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(11,Q2,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,Re,INDICATOR_CALCULATIONS);
   SetIndexBuffer(13,Im,INDICATOR_CALCULATIONS);
   SetIndexBuffer(14,Per,INDICATOR_CALCULATIONS);
   SetIndexBuffer(15,SmoothPeriod,INDICATOR_CALCULATIONS);   
   SetIndexBuffer(16, price, INDICATOR_CALCULATIONS);
   
   
   ArraySetAsSeries(snr,true);
   ArraySetAsSeries(cf,true);
   ArraySetAsSeries(q3, true);
   ArraySetAsSeries(noise, true);
   
   ArraySetAsSeries(Smooth,true);
   ArraySetAsSeries(Detrender,true);
   ArraySetAsSeries(I1,true);
   ArraySetAsSeries(Q1,true);
   ArraySetAsSeries(jI,true);
   ArraySetAsSeries(jQ,true);
   ArraySetAsSeries(I2,true);
   ArraySetAsSeries(Q2,true);
   ArraySetAsSeries(Re,true);
   ArraySetAsSeries(Im,true);
   ArraySetAsSeries(Per,true);
   ArraySetAsSeries(SmoothPeriod,true);
   
   ArraySetAsSeries(price, true);
   
   
   IndicatorSetString(INDICATOR_SHORTNAME,"EnhancedSignalToNoiseRatioH");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
   
   return(INIT_SUCCEEDED);
}

double GetValue(const double& h[], const double& l[], int i) {
   
   q3[i] = 0.5 * (Smooth[i] - Smooth[i + 2]) * (0.1759 * SmoothPeriod[i] + 0.4607);
   double i3 = 0.0;
   int sp = (int)MathCeil(SmoothPeriod[i] / 2);
   if (sp == 0) sp = 1;
   
   for (int j = 0; j < sp; j++) {
       i3 += q3[j + i];
   }    
   i3 = (1.57 * i3) / sp;
   
   double signal = MathPow(i3, 2) + MathPow(q3[i], 2);
   
   noise[i] = 0.1 * MathPow((h[i] - l[i]), 2) * 0.25 + 0.9 * noise[i + 1];
   
   if (noise[i] != 0.0 && signal != 0) {
      double s = ZerroIfEmpty(snr[i + 1]);
      snr[i] = 3.3 * MathLog(signal / noise[i]) / MathLog(10) + 0.67 * s;
   } else {
      snr[i] = 0;
   }
   if (price[i] > Smooth[i])  cf[i] = 2 ; 
   else
      if (price[i] < Smooth[i])  cf[i] = 1 ;
 
   return snr[i];
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {
      if(rates_total <= 4) return 0;
      ArraySetAsSeries(high,true);    
      ArraySetAsSeries(low,true);
      int limit = rates_total - prev_calculated;
      if (limit == 0)        {   // Пришел новый тик 
      } else if (limit == 1) {   // Образовался новый бар
         price[1] = (high[1] + low[1]) / 2;
         Hilbert(1);
         GetValue(high, low, 1);      
         return(rates_total);            
      } else if (limit > 1)  {   // Первый вызов индикатора, смена таймфрейма, подгрузка данных из истории
         ArrayInitialize(snr,   EMPTY_VALUE);
         ArrayInitialize(cf,    0);
         ArrayInitialize(q3,    0);
         ArrayInitialize(noise, 0);
         
         ArrayInitialize(Smooth,0);
         ArrayInitialize(Detrender,0);
         ArrayInitialize(I1,0);
         ArrayInitialize(Q1,0);
         ArrayInitialize(jI,0);
         ArrayInitialize(jQ,0);
         ArrayInitialize(I2,0);
         ArrayInitialize(Q2,0);
         ArrayInitialize(Re,0);
         ArrayInitialize(Im,0);
         ArrayInitialize(Per,0);
         ArrayInitialize(SmoothPeriod,0);
         ArrayInitialize(price,0);
         
         limit = rates_total - MINBAR;
         for(int i = limit; i >= 1 && !IsStopped(); i--){
            price[i] = (high[i] + low[i]) / 2;
            Hilbert(i);
            GetValue(high, low, i);
         }//for(int i = limit + 1; i >= 0 && !IsStopped(); i--)
         return(rates_total);         
      }
      price[0] = (high[0] + low[0]) / 2;
      Hilbert(0);
      GetValue(high, low, 0);          
                
   return(rates_total);
}

double ZerroIfEmpty(double value) {
   if (value >= EMPTY_VALUE || value <= -EMPTY_VALUE) return 0.0;
   return value;
}


void Hilbert(int i) {
         Smooth[i] = (4 * price[i] + 3 * price[i + 1] + 2 * price[i + 2] + price[i + 3]) / 10;
         Detrender[i] = (0.0962 * Smooth[i]        + 0.5769 * Smooth[i + 2]     - 
                         0.5769 * Smooth[i + 4]    - 0.0962 * Smooth[i + 6])    * (0.075 * Per[i + 1] + 0.54);
//InPhase and Quadrature components                         
			Q1[i]        = (0.0962 * Detrender[i]     + 0.5769 * Detrender[i + 2]  - 
			                0.5769 * Detrender[i + 4] - 0.0962 * Detrender[i + 6]) * (0.075 * Per[i + 1] + 0.54);			 
			I1[i]        = Detrender[i + 3];    
//Advance the phase of I1 and Q1 by 90 degrees 
			jI[i]        = (0.0962 * I1[i]            + 0.5769 * I1[i + 2]         - 
			                0.5769 * I1[i + 4]        - 0.0962 * I1[i + 6])        * (0.075 * Per[i + 1] + 0.54); 
			jQ[i]        = (0.0962 * Q1[i]            + 0.5769 * Q1[i + 2]         -
			                0.5769 * Q1[i + 4]        - 0.0962 * Q1[i + 6])        * (0.075 * Per[i + 1] + 0.54); 	
//Phasor Addition 
			I2[i]        =  I1[i] - jQ[i]; 
			Q2[i]        =  Q1[i] + jI[i]; 	
//Smooth the I and Q components before applying the discriminator 
			I2[i]        =  0.2 * I2[i] + 0.8 * I2[i  + 1]; 
			Q2[i]        =  0.2 * Q2[i] + 0.8 * Q2[i  + 1]; 		
//Homodyne Discriminator 
			Re[i]        = I2[i] * I2[i]      + Q2[i] * Q2[i + 1]; 
			Im[i]        = I2[i] * Q2[i + 1]  - Q2[i] * I2[i + 1]; 
			Re[i]        = 0.2   * Re[i]      + 0.8   * Re[i + 1]; 
			Im[i]        = 0.2   * Im[i]      + 0.8   * Im[i + 1]; 		
			
			if(Im[i]!=0 && Re[i]!=0)       Per[i]     = 2 * M_PI  / (MathArctan(Im[i] / Re[i]) ); 		
			else                           Per[i]     = 0; 
			if(Per[i] > 1.5  * Per[i + 1]) Per[i]     = 1.5  * Per[i + 1]; 			 
			if(Per[i] < 0.67 * Per[i + 1]) Per[i]     = 0.67 * Per[i + 1]; 			 
			if(Per[i] < 6)                 Per[i]     = 6; 			 
			if(Per[i] > 50)                Per[i]     = 50; 		

			Per[i]          = 0.2  * Per[i] + 0.8  * Per[i + 1]; 
			SmoothPeriod[i] = 0.33 * Per[i] + 0.67 * SmoothPeriod[i + 1]; 		

}// void Hilbert(i)