//+------------------------------------------------------------------+
//|                                  AlexSTAL_ZigZagProf_channel.mq5 |
//|                                         Copyright 2011, AlexSTAL |
//|                                           http://www.alexstal.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright 2011, AlexSTAL"
#property link      "http://www.alexstal.ru"
#property version   "1.00"
#property indicator_chart_window
//---- для расчёта и отрисовки индикатора использовано девять буферов
#property indicator_buffers 9
//---- использовано всего пять графических построений
#property indicator_plots   5
//+----------------------------------------------+
//|  Параметры отрисовки индикатора облака       |
//+----------------------------------------------+
//---- отрисовка индикатора в виде цветного облака
#property indicator_type1   DRAW_FILLING
//---- в качестве цвета облака использован
#property indicator_color1  clrLavender
//---- отображение метки индикатора
#property indicator_label1  " AlexSTAL_ZigZagProf Cloud"
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 2 в виде многоцветной линии
#property indicator_type2   DRAW_COLOR_LINE
//---- в качестве цвета индикатора использованы
#property indicator_color2  clrMediumSpringGreen,clrOrange
//---- толщина линии индикатора 2 равна 2
#property indicator_width2  2
//---- отображение бычей метки индикатора
#property indicator_label2  "Up  AlexSTAL_ZigZagProf"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 3 в виде многоцветной линии
#property indicator_type3   DRAW_COLOR_LINE
//---- в качестве цвета индикатора использованы
#property indicator_color3  clrMediumSpringGreen,clrOrange
//---- толщина линии индикатора 3 равна 2
#property indicator_width3  2
//---- отображение медвежьей метки индикатора
#property indicator_label3 "Down  AlexSTAL_ZigZagProf"
//+----------------------------------------------+
//|  Параметры отрисовки верхнего индикатора     |
//+----------------------------------------------+
//---- отрисовка индикатора 4 в виде символа
#property indicator_type4   DRAW_ARROW
//---- в качестве цвета индикатора использован Blue
#property indicator_color4  clrBlue
//---- толщина линии индикатора 4 равна 2
#property indicator_width4  2
//---- отображение бычей метки индикатора
#property indicator_label4  "Up AlexSTAL_ZigZagProf_Arrows"
//+----------------------------------------------+
//|  Параметры отрисовки нижнего индикатора      |
//+----------------------------------------------+
//---- отрисовка индикатора 5 в виде символа
#property indicator_type5   DRAW_ARROW
//---- в качестве цвета индикатора использован DeepPink
#property indicator_color5  clrDeepPink
//---- толщина линии индикатора 5 равна 2
#property indicator_width5  2
//---- отображение медвежьей метки индикатора
#property indicator_label5 "Down AlexSTAL_ZigZagProf_Arrows"
//+----------------------------------------------+

#include <AlexSTAL_OutsideBar.mqh>
//+----------------------------------------------+ 
//| Входные параметры индикатора                 |
//+----------------------------------------------+ 
// Количество баров для расчета экстремумов
// не может быть меньше 2
input uchar iExtPeriod=12;
// Минимальное расстояние цены между соседними пиком и впадиной (иначе не регистрируется)
input uchar iMinAmplitude=10;
// Минимальное движение цены в пунктах на нулевом баре для перерасчета индикатора
input uchar iMinMotion=0;
// Использовать более точный алгоритм вычисления порядка формирования High/Low бара
input bool iUseSmallerTFforEB=true;
input uint  UpLable=159;//лейба верхнего фрактала
input uint  DnLable=159;//лейба нижнего фрактала
//+----------------------------------------------+ 
uchar ExtPeriod,MinAmplitude,MinMotion;

//---- объявление динамических массивов, которые будут в дальнейшем использованы в качестве индикаторных буферов
double UpBuffer[],DnBuffer[];
double UpperBuffer[],LowerBuffer[];
double ColorUpperBuffer[],ColorLowerBuffer[];
double HighestBuffer[],LowestBuffer[];

// Буфер для кэширования внешнего бара
double OBBuffer[];

// Время открытия последнего обсчитанного бара
datetime LastBarTime;
// Защита от докачки истории
//int LastBarNum;
// Для оптимизации расчетов
double LastBarLastHigh,LastBarLastLow;
// Время первого экстремума (необходимо для алгоритма внешнего бара)
datetime TimeFirstExtBar;

// Статические переменные для ускорения расчетов
double MP,MM;

// Вспомогательная переменная
bool DownloadHistory;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   if(iExtPeriod>=2)
      ExtPeriod=iExtPeriod;
   else
      ExtPeriod=2;

   if(iMinAmplitude>=0)
      MinAmplitude=iMinAmplitude;
   else
      MinAmplitude=0;
   MP=NormalizeDouble(MinAmplitude*_Point,_Digits);

   if(iMinMotion>=1)
      MinMotion=iMinMotion;
   else
      MinMotion=1;
   MM=NormalizeDouble(MinMotion*_Point,_Digits);

//---- превращение динамических массивов в индикаторные буферы
   SetIndexBuffer(0,UpBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,DnBuffer,INDICATOR_DATA);
   SetIndexBuffer(2,UpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(3,ColorUpperBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(4,LowerBuffer,INDICATOR_DATA);
   SetIndexBuffer(5,ColorLowerBuffer,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(6,HighestBuffer,INDICATOR_DATA);
   SetIndexBuffer(7,LowestBuffer,INDICATOR_DATA);
   SetIndexBuffer(8,OBBuffer,INDICATOR_CALCULATIONS);
//---- запрет на отрисовку индикатором пустых значений
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(2,PLOT_EMPTY_VALUE,NULL);
   PlotIndexSetDouble(3,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(4,PLOT_EMPTY_VALUE,EMPTY_VALUE);
//---- индексация элементов в буферах как в таймсериях   
   ArraySetAsSeries(UpBuffer,true);
   ArraySetAsSeries(DnBuffer,true);
   ArraySetAsSeries(UpperBuffer,true);
   ArraySetAsSeries(LowerBuffer,true);
   ArraySetAsSeries(ColorUpperBuffer,true);
   ArraySetAsSeries(ColorLowerBuffer,true);
   ArraySetAsSeries(LowestBuffer,true);
   ArraySetAsSeries(HighestBuffer,true);
   ArraySetAsSeries(OBBuffer,true);
//---- символы для индикатора
   PlotIndexSetInteger(3,PLOT_ARROW,DnLable);
   PlotIndexSetInteger(4,PLOT_ARROW,UpLable);
//---- Установка формата точности отображения индикатора
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- set short name and digits   
   PlotIndexSetString(0,PLOT_LABEL,"ZigZag("+(string)ExtPeriod+","+(string)MinAmplitude+","+(string)MinMotion+","+(string)iUseSmallerTFforEB+")");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);

   DownloadHistory=true;

//---
   return(0);
  }
//+------------------------------------------------------------------+
//|  searching index of the highest bar                              |
//+------------------------------------------------------------------+
int iHighest(const double &array[],int depth,int startPos)
  {
   int index=startPos;
   int MaxBar=ArraySize(array)-1;
//--- start index validation
   if((startPos<0) || (startPos>MaxBar))
     {
      Print("Invalid parameter in the function iHighest, startPos =",startPos);
      return -1;
     }
   double max=array[startPos];

//--- start searching
   for(int i=MathMin(startPos+depth-1,MaxBar); i>=startPos; i--)
     {
      if(array[i]>max)
        {
         index=i;
         max=array[i];
        }
     }
//--- return index of the highest bar
   return(index);
  }
//+------------------------------------------------------------------+
//|  searching index of the lowest bar                               |
//+------------------------------------------------------------------+
int iLowest(const double &array[],int depth,int startPos)
  {
   int index=startPos;
   int MaxBar=ArraySize(array)-1;
//--- start index validation
   if((startPos<0) || (startPos>MaxBar))
     {
      Print("Invalid parameter in the function iLowest, startPos =",startPos);
      return -1;
     }
   double min=array[startPos];

//--- start searching
   for(int i=MathMin(startPos+depth-1,MaxBar); i>=startPos; i--)
     {
      if(array[i]<min)
        {
         index=i;
         min=array[i];
        }
     }
//--- return index of the lowest bar
   return(index);
  }
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
   ArraySetAsSeries(time,true);
   ArraySetAsSeries(high,true);
   ArraySetAsSeries(low,true);
   int i;
   for(i=(rates_total-prev_calculated-1); i>=0; i--)
     {
      HighestBuffer[i]= EMPTY_VALUE;
      LowestBuffer[i] = EMPTY_VALUE;
      OBBuffer[i]=EMPTY_VALUE;
     }

//---
// Блок полной инициализации при подкачке истории
// ----------------------------------------------
   int counted_bars=prev_calculated;

// IndicatorCounted() может обнулится при восстановлении связи
   if(counted_bars==0)
      DownloadHistory=true;

// Защита от докачки пропущенной истории внутрь расчета
/*if ( (counted_bars != 0) && (LastBarNum != 0) )
      if ( (rates_total - iBarShift(NULL, 0, LastBarTime, true)) != LastBarNum )
         DownloadHistory = true;*/

// Полная инициализация
   if(DownloadHistory)
     {
      ArrayInitialize(HighestBuffer,EMPTY_VALUE);
      ArrayInitialize(LowestBuffer,EMPTY_VALUE);
      ArrayInitialize(OBBuffer,EMPTY_VALUE);
      TimeFirstExtBar=0;
      counted_bars= 0;
      LastBarTime = 0;
      //LastBarNum = 0;
      DownloadHistory=false;
     }

// Блок определения формирования нового бара (первый дошедший тик)
   bool NewBar=false;
   if(LastBarTime!=time[0])
     {
      NewBar=true;
      LastBarTime=time[0];
      //LastBarNum = rates_total;
      // новый бар - обнулим переменные для оптимизации расчетов
      LastBarLastHigh= high[0];
      LastBarLastLow = low[0];
     }

// Вычислим необходимое количество баров для пересчета
   int BarsForRecalculation;
   if(counted_bars!=0)
     {
      BarsForRecalculation=rates_total-counted_bars;
      // Блок оптимизации расчетов
      if(!NewBar)
        {
         if((NormalizeDouble(high[0]-LastBarLastHigh,_Digits)>=MM) || (NormalizeDouble(LastBarLastLow-low[0],_Digits)>=MM))
           {
            LastBarLastHigh= high[0];
            LastBarLastLow = low[0];
              } else {
            // На данном тике расчет производить не будем, так как цена изменялась внутри
            // нулевого бара или же её изменения не были больше минимального порога,
            // заданного в переменной MinMotion
            return(rates_total);
           }
        }
        } else {
      BarsForRecalculation=rates_total-ExtPeriod;
     }

//======================================================
//======== основной цикл ===============================
//======================================================
   int LET;
   double H,L,Fup,Fdn;
   int lastHighestBufferbar,lastLowestBufferbar;
   double lastHighestBuffer,lastLowestBuffer;
   int m,n; // Для поиска последнего экстремума
   for(i=BarsForRecalculation; i>=0; i--)
     {
      // Поиск последнего экстремума
      // ---------------------------
      lastHighestBuffer= 0;
      lastLowestBuffer = 0;
      lastHighestBufferbar= i;
      lastLowestBufferbar = i;
      LET=0;
      m=0; n=0;
      while(HighestBuffer[lastHighestBufferbar]==EMPTY_VALUE)
        {
         if(lastHighestBufferbar>(rates_total-ExtPeriod))
            break;
         lastHighestBufferbar++;
        }
      lastHighestBuffer=HighestBuffer[lastHighestBufferbar]; //возможно нашли последний пик
      while(LowestBuffer[lastLowestBufferbar]==EMPTY_VALUE)
        {
         if(lastLowestBufferbar>(rates_total-ExtPeriod))
            break;
         lastLowestBufferbar++;
        }
      lastLowestBuffer=LowestBuffer[lastLowestBufferbar]; //возможно нашли последнюю впадину

      if(lastHighestBufferbar<lastLowestBufferbar)
         LET=1;
      if(lastHighestBufferbar>lastLowestBufferbar)
         LET=-1;
      if(lastHighestBufferbar==lastLowestBufferbar)
        {
         //lastHighestBufferbar==lastLowestBufferbar надо узнать, какой одиночный экстремум был последним:
         m = lastHighestBufferbar;
         n = m;
         while(m==n)
           {
            m++; n++;
            while(HighestBuffer[m]==EMPTY_VALUE)
              {
               if(m>(rates_total-ExtPeriod))
                  break;
               m++;
              } //возможно нашли последний пик
            while(LowestBuffer[n]==EMPTY_VALUE)
              {
               if(n>(rates_total-ExtPeriod))
                  break;
               n++;
              } //возможно нашли последнюю впадину
            if(MathMax(m,n)>(rates_total-ExtPeriod))
               break;
           }
         if(m<n)
            LET=1;       //базовый отсчет - пик
         else
         if(m>n)
            LET=-1; //базовый отсчет - впадина
        }
      // если LET==0 - значит это начало отсчета или в самом начале зафиксирован внешний бар с 2 экстремумами
      // Конец поиска последнего экстремума
      // ----------------------------------

      //---- рассмотрим ценовые экстремумы за расчетный период:       
      H = high[iHighest(high, ExtPeriod, i)];
      L = low[iLowest(low, ExtPeriod, i)];
      Fup = high[i];
      Fdn = low[i];

      //---- проанализируем ситуацию и рассмотрим возможность регистрации новых экстремумов: 
      switch(Comb(i,H,L,Fup,Fdn))
        {
         //---- на расчетном баре потенциальный пик (Comb)      
         case 1 :
            switch(LET)
              {
               case 1 :
                  //предыдущий экстремум тоже пик, выбираем больший:
                  if(lastHighestBuffer<Fup)
                    {
                     HighestBuffer[lastHighestBufferbar]=EMPTY_VALUE;
                     HighestBuffer[i]=Fup;
                    }
                  break;
               case -1 :
                  if((Fup-lastLowestBuffer)>MP) //предыдущий экстремум - впадина
                  HighestBuffer[i]=Fup;
                  break;
               default :
                  HighestBuffer[i]=Fup;
                  TimeFirstExtBar=time[i]; //0 - значит это начало расчета 
                  break;
              }
            break;

            //---- на расчетном баре потенциальная впадина  (Comb)          
         case -1 :
            switch(LET)
              {
               case 1 :
                  if((lastHighestBuffer-Fdn)>MP) //предыдущий экстремум - пик
                  LowestBuffer[i]=Fdn;
                  break;
               case -1 :
                  //предыдущий экстремум тоже впадина, выбираем меньшую:
                  if(lastLowestBuffer>Fdn)
                    {
                     LowestBuffer[lastLowestBufferbar]=EMPTY_VALUE;
                     LowestBuffer[i]=Fdn;
                    }
                  break;
               default :
                  LowestBuffer[i]=Fdn;
                  TimeFirstExtBar=time[i]; //0 - значит это начало расчета 
                  break;
              }
            break;

            //---- на расчетном баре потенциальный пик и потенциальная впадина (Comb)        
         case 2 : //предположительно сначала сформировался LOW потом HIGH (бычий бар)
            switch(LET)
              {
               case 1 : //предыдущий экстремум - пик
                  if((Fup-Fdn)>MP)
                    {
                     if((lastHighestBuffer-Fdn)>MP)
                       {
                        HighestBuffer[i]= Fup;
                        LowestBuffer[i] = Fdn;
                          } else {
                        if(lastHighestBuffer<Fup)
                          {
                           HighestBuffer[lastHighestBufferbar]=EMPTY_VALUE;
                           HighestBuffer[i]=Fup;
                          }
                       }
                       } else {
                     if((lastHighestBuffer-Fdn)>MP)
                        LowestBuffer[i]=Fdn;
                     else 
                       {
                        if(lastHighestBuffer<Fup)
                          {
                           HighestBuffer[lastHighestBufferbar]=EMPTY_VALUE;
                           HighestBuffer[i]=Fup;
                          }
                       }
                    }
                  break;
               case -1 : //предыдущий экстремум - впадина
                  if((Fup-Fdn)>MP)
                    {
                     HighestBuffer[i]=Fup;
                     if((Fdn<lastLowestBuffer) && (time[lastLowestBufferbar]>TimeFirstExtBar))
                       {
                        LowestBuffer[lastLowestBufferbar]=EMPTY_VALUE;
                        LowestBuffer[i]=Fdn;
                       }
                       } else {
                     if((Fup-lastLowestBuffer)>MP)
                        HighestBuffer[i]=Fup;
                     else 
                       {
                        if(lastLowestBuffer>Fdn)
                          {
                           LowestBuffer[lastLowestBufferbar]=EMPTY_VALUE;
                           LowestBuffer[i]=Fdn;
                          }
                       }
                    }
                  break;
               default: break;
              } //switch LET
            break;

            //---- на расчетном баре потенциальный пик и потенциальная впадина (Comb)        
         case -2 : //предположительно сначала сформировался HIGH потом LOW (медвежий бар)
            switch(LET)
              {
               case 1 : //предыдущий экстремум - пик
                  if((Fup-Fdn)>MP)
                    {
                     LowestBuffer[i]=Fdn;
                     if((lastHighestBuffer<Fup) && (time[lastHighestBufferbar]>TimeFirstExtBar))
                       {
                        HighestBuffer[lastHighestBufferbar]=EMPTY_VALUE;
                        HighestBuffer[i]=Fup;
                       }
                       } else {
                     if((lastHighestBuffer-Fdn)>MP)
                        LowestBuffer[i]=Fdn;
                     else 
                       {
                        if(lastHighestBuffer<Fup)
                          {
                           HighestBuffer[lastHighestBufferbar]=EMPTY_VALUE;
                           HighestBuffer[i]=Fup;
                          }
                       }
                    }
                  break;
               case -1 : //предыдущий экстремум - впадина
                  if((Fup-Fdn)>MP)
                    {
                     if((Fup-lastLowestBuffer)>MP)
                       {
                        HighestBuffer[i]= Fup;
                        LowestBuffer[i] = Fdn;
                          } else {
                        if(lastLowestBuffer>Fdn)
                          {
                           LowestBuffer[lastLowestBufferbar]=EMPTY_VALUE;
                           LowestBuffer[i]=Fdn;
                          }
                       }
                       } else {
                     if((Fup-lastLowestBuffer)>MP)
                        HighestBuffer[i]=Fup;
                     else 
                       {
                        if(lastLowestBuffer>Fdn)
                          {
                           LowestBuffer[lastLowestBufferbar]=EMPTY_VALUE;
                           LowestBuffer[i]=Fdn;
                          }
                       }
                    }
                  break;
               default: break;
              } //switch LET
            break;

         default: break;
        } // switch (главный)
     } // for (главный)
     
//---- объявления локальных переменных 
   int limit,bar,barHH,barHH1,barLL,barLL1;
   double HH,LL,HH1,LL1;

//---- расчёт стартового номера limit для цикла пересчёта баров и стартовая инициализация переменных
   if(prev_calculated>rates_total || prev_calculated<=0)// проверка на первый старт расчёта индикатора
     {
      limit=rates_total-1; // стартовый номер для расчёта всех баров

      for(int index=rates_total-1; index>=0 && !IsStopped(); index--)
        {
         UpBuffer[index]=NULL;
         UpperBuffer[index]=NULL;
         //HighestBuffer[index]=NULL;
         
         DnBuffer[index]=NULL;
         LowerBuffer[index]=NULL;
         //LowestBuffer[index]=NULL;
        }
     }
   else
     {
      limit=rates_total-prev_calculated; // стартовый номер для расчёта новых баров
     }
     
//---- Цикл расчёта канала
   for(bar=limit; bar>=0 && !IsStopped(); bar--)    
     {
      barHH=FindFirstExtremum(bar,rates_total,HighestBuffer,HH);
      barHH1=FindFirstExtremum(barHH+1,rates_total,HighestBuffer,HH1);
      
      if(barHH>=0 && barHH1>=0)
        {
         for(int index=barHH1-1; index>barHH && !IsStopped(); index--)
           {
            UpBuffer[index]=HH1;
            UpperBuffer[index]=HH1;
            ColorUpperBuffer[index]=ColorUpperBuffer[index+1];
           }
           
         for(int index=barHH; index>=bar && !IsStopped(); index--)
           {
            UpBuffer[index]=HH;
            UpperBuffer[index]=HH;
            if(HH>HH1) ColorUpperBuffer[index]=0;
            else if(HH<HH1) ColorUpperBuffer[index]=1;
            else ColorUpperBuffer[index]=ColorUpperBuffer[index+1];
           }
        }
        
      barLL=FindFirstExtremum(bar,rates_total,LowestBuffer,LL);
      barLL1=FindFirstExtremum(barLL+1,rates_total,LowestBuffer,LL1);     

      if(barLL>=0 && barLL1>=0)
        {
         for(int index=barLL1-1; index>barLL && !IsStopped(); index--)
           {
            DnBuffer[index]=LL1;
            LowerBuffer[index]=LL1;
            ColorLowerBuffer[index]=ColorLowerBuffer[index+1];
           }
           
         for(int index=barLL; index>=bar && !IsStopped(); index--)
           {
            DnBuffer[index]=LL;
            LowerBuffer[index]=LL;
            if(LL>LL1) ColorLowerBuffer[index]=0;
            else if(LL<LL1) ColorLowerBuffer[index]=1;
            else ColorLowerBuffer[index]=ColorLowerBuffer[index+1];
           }
        }
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| функция анализа текущей ситуации                                 |
//+------------------------------------------------------------------+ 
int Comb(int i,double H,double L,double Fup,double Fdn)
  {
//----
   if(Fup==H && (Fdn==0 || (Fdn>0 && Fdn>L))) return(1);  //на расчетном баре потенциальный пик
   if(Fdn==L && (Fup==0 || (Fup>0 && Fup<H))) return(-1); //на расчетном баре потенциальная впадина
   if(Fdn==L && Fup==H)                                   //на расчетном баре потенциальный пик и потенциальная впадина 
     {
      OrderFormationBarHighLow OrderFormationHL=OFBError;
      // Попытка найти кешированные данные в буфере OBBuffer[]
      if(OBBuffer[i]==EMPTY_VALUE)
         OrderFormationHL=GetOrderFormationBarHighLow(Symbol(),Period(),i,iUseSmallerTFforEB);
      if(OrderFormationHL!=OFBError)
         OBBuffer[i]=OrderFormationHL;
      else
         OrderFormationHL=(OrderFormationBarHighLow)OBBuffer[i];

      switch(OrderFormationHL)
        {
         case OFBLowHigh:       //предположительно сначала сформировался LOW потом HIGH (бычий бар)
            return(2);
            break;
         case OFBHighLow:       //предположительно сначала сформировался HIGH потом LOW (медвежий бар)
            return(-2);
            break;
        }
     }
//----  
   return(0);           //на расчетном баре пусто...
  }
//+------------------------------------------------------------------+
//| Поиск самой первой вершины Зигзага в буферах таймсериях          |
//+------------------------------------------------------------------+     
int FindFirstExtremum(int StartPos,int Rates_total,double &Array[],double &Extremum)
  {
//----
   for(int bar=StartPos; bar<Rates_total; bar++)
     {
      if(Array[bar] && Array[bar]!=EMPTY_VALUE)
        {
         Extremum=Array[bar];
         return(bar);
         break;
        }
     }
//----
   Extremum=NULL;
   return(-1);
  }
//+------------------------------------------------------------------+
