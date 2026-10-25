//+---------------------------------------------------------------------+
//|                                        MLSOnGraphics.mq4            |
//| The Method of Least Squares                                         |
//|      High and Low ver. 7                                            |
//|             Copyright © Trofimov 2008                               |
//+---------------------------------------------------------------------+
//| Метод наименьших квадратов                                          |
//|   по верхней и нижней отметке свечи                                 |
//| Описание: Расчёт минимального квадратичного отлонения от прямой     |
//|           в пунктах. Если рынок колеблется в пределах тангенса      |
//|           угла наклона линии тренда к горизонтальной прямой         |
//|           то тренд развивается уверенно и равномерно.               |
//| Авторское право принадлежит Трофимову Евгению Витальевичу, 2008     |
//+---------------------------------------------------------------------+


#property copyright "Copyright © Trofimov Evgeniy Vitalyevich, 2008"
#property link      "http://multitest.semico.ru/mnk.htm"

//---- Свойства индикатора
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_color1 DarkBlue
#property indicator_width1 2
#property indicator_color2 FireBrick
#property indicator_width2 2
#property indicator_color3 Blue
#property indicator_width3 1
#property indicator_color4 Red
#property indicator_width4 1
#property indicator_color5 Silver
#property indicator_width5 1


//---- Входящие параметры
extern int MyPeriod=12;
extern int Shift=0;
extern int Future=0;
extern bool CalculateDeflection=true;
extern bool ReDraw=true; //-если включен, то перерисовывает нулевой бар при каждом новом тике
                          // если выключен, то нулевой бар содержит фиксированное значение, вычисленное по предыдущим (готовым) барам

//---- Массив данных индикатора
double MLS_H[];
double MLS_L[];
double MLS_HD[];
double MLS_LD[];
double MLS_b[];
//+------------------------------------------------------------------+
//|                Функция инициализации индикатора                  |
//+------------------------------------------------------------------+
int init()
  {
//---- x дополнительных буфера, используемых для расчета
   IndicatorBuffers(5);
//---- параметры рисования (установка начального бара)
   SetIndexDrawBegin(0,MyPeriod);
   SetIndexDrawBegin(1,MyPeriod);
   SetIndexDrawBegin(2,MyPeriod);
   SetIndexDrawBegin(3,MyPeriod);
   SetIndexDrawBegin(4,MyPeriod);
   SetIndexShift(0,Shift);
   SetIndexShift(1,Shift);
   SetIndexShift(2,Shift);
   SetIndexShift(3,Shift);
   SetIndexShift(4,Shift);
//---- x распределенных буфера индикатора
   SetIndexBuffer(0,MLS_H);
   SetIndexBuffer(1,MLS_L);
   SetIndexBuffer(2,MLS_HD);
   SetIndexBuffer(3,MLS_LD);
   SetIndexBuffer(4,MLS_b);
//---- имя индикатора и подсказки для линий
   IndicatorShortName("MLSOnGraphics("+MyPeriod+") = ");
   SetIndexLabel(0,"HighLine("+MyPeriod+")");
   SetIndexLabel(1,"LowLine("+MyPeriod+")");
   SetIndexLabel(2,"HighDeflection("+MyPeriod+")");
   SetIndexLabel(3,"LowDeflection("+MyPeriod+")");
   SetIndexLabel(4,"b("+MyPeriod+")");
   SetIndexStyle(4,DRAW_NONE);
   return(0);
  }
//+------------------------------------------------------------------+
//|                Функция индикатора                                |
//+------------------------------------------------------------------+
int start() {
   //static datetime LastTime;
   int limit, RD;
   if(ReDraw) RD=1;
   
   // Пропущенные бары
   int counted_bars=IndicatorCounted();
//---- обходим возможные ошибки
   if(counted_bars<0) return(-1);
//---- новые бары не появились и поэтому ничего рисовать не нужно
   limit=Bars-counted_bars-1+RD;

   if(counted_bars==0) limit-=RD+MyPeriod;

//---- основные переменные
   double ha, hb, hk1, hi1, hj1, hk2, hi2, j2;
   double la, lb, lk1, li1, lj1, lk2, li2;
   double H, L;
   
   int x;
//---- основной цикл
   for(int t=limit-RD; t>-RD; t--) {
      //if(LastTime==iTime(NULL,0,t)) return(0);
      //LastTime=iTime(NULL,0,t);
      //if(t<5) Print(t,"===== ",TimeToStr(LastTime)," =====");
   
      hk1=0; hi1=0; hj1=0; hk2=0; hi2=0;
      lk1=0; li1=0; lj1=0; lk2=0; li2=0;
      for(x=t+MyPeriod-1; x>=t; x--)
        { // составляем нормальные уравнения k1=a*i1+b*j1 и k2=a*i2+b*j2
         H=High[x];
         hk1=hk1+H*x;    hk2=hk2+H;
         hi1=hi1+x*x;    hi2=hi2+x;
         hj1=hj1+x;
         
         L=Low[x];
         lk1=lk1+L*x;    lk2=lk2+L;
         li1=li1+x*x;    li2=li2+x;
         lj1=lj1+x;
        } //Next x
      j2=MyPeriod;
      //Решаем систему уравнений
      ha=(hk1*j2-hj1*hk2)/(hi1*j2-hj1*hi2);
      hb=(hk2-hi2*ha)/j2;
      la=(lk1*j2-lj1*lk2)/(li1*j2-lj1*li2);
      lb=(lk2-li2*la)/j2;
      //Теперь все точки High и Low, на данный момент времени,
      //приблизительно расположены вдоль прямой, описаной уравнением y=ax+b,
      //где x - это номер свечи, а y - значение цены.
      MLS_b[t]=(hb+lb)/2;
      if(!ReDraw && t==1) MLS_b[0]=(hb+lb)/2; 
      //Предположим, что цена пойдёт дальше вдоль той же прямой
      MLS_H[t]=ha*(t-Future)+hb+Point;
      if(!ReDraw && t==1) MLS_H[0]=ha*(t-Future+1)+hb+Point;
      MLS_L[t]=la*(t-Future)+lb-Point;
      if(!ReDraw && t==1) MLS_L[0]=la*(t-Future+1)+lb-Point;
      if(CalculateDeflection) { //расчёт отклонения
         double hS, lS;
         hS=0;lS=0;
         for(x=t+MyPeriod-1; x>=t; x--) {
            hS=hS+MathPow(High[x]-MLS_H[x],2);
            lS=lS+MathPow(Low[x] -MLS_L[x],2);
         } //Next x
         MLS_HD[t]=MLS_H[t]+MathSqrt(hS)/2;
         if(!ReDraw && t==1) MLS_HD[0]=MLS_H[0]+MathSqrt(hS)/2;
         MLS_LD[t]=MLS_L[t]-MathSqrt(lS)/2;
         if(!ReDraw && t==1) MLS_LD[0]=MLS_L[0]-MathSqrt(lS)/2;
      }
   } //Next t
   return(0);
}
//+------------------------------------------------------------------+

