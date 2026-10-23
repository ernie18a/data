//+------------------------------------------------------------------+
//|                                                  m-Fibonacci.mq4 |
//|                оригинальная идея для D1 - Ким Игорь В. aka KimIV |
//|                                              http://www.kimiv.ru |
//|  Переписал для стандартных таймфреймов - Михаил Житнев (MikeZTN) |
//|                                                    ICQ 138092006 |
//|                                    2008.09.09   уровни Фибоначчи |
//+------------------------------------------------------------------+
#property copyright "Житнев Михаил aka MikeZTN"
#property link      "ICQ 138092006"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_color1 0x00FFFF
#property indicator_color2 0x880088
#property indicator_color3 0xAA00AA
#property indicator_color4 0xDD00DD
#property indicator_color5 0xCCCC00
#property indicator_color6 0xAAAA00
#property indicator_color7 0x777700


//------- Внешние параметры индикатора -------------------------------
extern int TFBar = 1440;  // Период по умолчанию
extern string FileName = "level.wav";
extern int delta=5;
extern bool Notice=true;
datetime LastTime;

//------- Буферы индикатора ------------------------------------------
   double pivot[];
   double r3[];
   double r2[];
   double r1[];
   double s1[];
   double s2[];
   double s3[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() {
  
  bool OK_Period=false;   
  switch (TFBar)
  {    
    case 30:OK_Period=true;break;
    case 60:OK_Period=true;break;
    case 240:OK_Period=true;break;
    case 1440:OK_Period=true;break;
    case 10080:OK_Period=true;break;
    case 43200:OK_Period=true;break;
  }
  if (OK_Period==false)
     {
       Comment("Вы ввели нестандартную цифру таймфрейма TFBar! Необходимо ввести одну из следующих: 30,60,240,1440 и т.д.");   
       return(0);
     }
      
  IndicatorShortName("m-Fibonacci (" +TFBar+")");    
      
  SetIndexBuffer(0, pivot);
  SetIndexStyle (0, DRAW_LINE, STYLE_DOT);
  SetIndexEmptyValue(0, EMPTY_VALUE);

  SetIndexBuffer(1, r3);
  SetIndexStyle (1, DRAW_LINE, STYLE_DOT);
  SetIndexEmptyValue(1, EMPTY_VALUE);

  SetIndexBuffer(2, r2);
  SetIndexStyle (2, DRAW_LINE, STYLE_DOT);
  SetIndexEmptyValue(2, EMPTY_VALUE);

  SetIndexBuffer(3, r1);
  SetIndexStyle (3, DRAW_LINE, STYLE_DOT);
  SetIndexEmptyValue(3, EMPTY_VALUE);

  SetIndexBuffer(4, s1);
  SetIndexStyle (4, DRAW_LINE, STYLE_DOT);
  SetIndexEmptyValue(4, EMPTY_VALUE);

  SetIndexBuffer(5, s2);
  SetIndexStyle (5, DRAW_LINE, STYLE_DOT);
  SetIndexEmptyValue(5, EMPTY_VALUE);

  SetIndexBuffer(6, s3);
  SetIndexStyle (6, DRAW_LINE, STYLE_DOT);
  SetIndexEmptyValue(6, EMPTY_VALUE);
  
  Comment(""); 
}

void Beep(double Level)
  { 
    if (Bid<=Level+delta*Point && Bid>=Level-delta*Point && Notice==true && LastTime!=Time[0])
    {
      PlaySound("level.wav");            
      Print( TimeToStr(Time[0],TIME_SECONDS));
      LastTime = Time[0];        
    }      
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start() {
  double dMax, dMin, dClose, R, p;
  int    i, nsb, prevDay, shift;  
 
  for (i=0; i<Bars-1; i++) 
  {
   nsb=iBarShift(NULL, TFBar, Time[i])+1;
   dMax=iHigh(NULL, TFBar, nsb);
   dMin=iLow (NULL, TFBar, nsb);
   dClose =iClose(NULL, TFBar, nsb);
   R = dMax - dMin; //дневной диапазон
   p = (dMax + dMin + dClose)/3; // стандартный пивот          
   r3[i] = p + (R * 1.000);
   r2[i] = p + (R * 0.618);
   r1[i] = p + (R * 0.382);
   pivot[i] = p; 
   s1[i] = p - (R * 0.382);
   s2[i] = p - (R * 0.618);
   s3[i] = p - (R * 1.000);     
  }
  Beep(r3[0]);
  Beep(r2[0]);
  Beep(r1[0]);
  Beep(pivot[0]);
  Beep(s1[0]);
  Beep(s2[0]);
  Beep(s3[0]);    
   
}
 
//+------------------------------------------------------------------+

