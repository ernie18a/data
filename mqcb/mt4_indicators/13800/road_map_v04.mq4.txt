//+------------------------------------------------------------------+
//|                                                 Road_Map_v04.mq4 |
//|  нач. 15/10/2015                                                 |
//+------------------------------------------------------------------+
#property copyright "Inkov Evgeni"
#property link      "ew123@mail.ru"
//+------------------------------------------------------------------+
// без сжатия
// изменена логика зиг-зага на начальных барах
//+------------------------------------------------------------------+
#property version   "1.00"
#property strict
#property indicator_chart_window
//+------------------------------------------------------------------+
input int   TF_ind         = 0;
input int   Max_Bars       = 300;
input color clr_Series_Up  = clrBlue;
input color clr_Series_Dw  = clrPurple;
input color clr_Tail_ZZ    = clrGreen;
input color clr_Fibo       = clrDarkOrange;
input color clr_Prob_UP    = clrGreen;
input color clr_Prob_DW    = clrRed;
input bool  On_Nom_Series  = true;
input bool  On_Fibo        = true;
input bool  Sound          = true;
input bool  Alert_On       = false;
//+------------------------------------------------------------------+
int Mas_Fract[][2][3];   // [2]: 0 - левая, 1-правая точка фрактала (для вертикальной линии),
                         //    если наклонная линия, значения ячеек одинаковые
                         // [3] признаки:
                         // 0 - знач.фрактала: 1,2,3-макс, 0 - нет фракт, -1,-2,-3 - мин. (1-истиный фракт., 2- доп., 3-начало)
                         // 1 - (-1 - имп.волна вниз, 2 - корр.волна, 1 - имп.волна вверх)
                         //     в [0] части записывается импульс для верт.линии,
                         //     в [1]- для следующей наклонной линии
                         // 2 - (1 - серия волн вверх, -1 - серия волн вниз), число - некущий номер волны в серии
                         //     [0] номер волны для накл. линии и для левой точки верт.линии
                         //     [1] номер волны для правой точки верт.линии (для накл.линии не исп.)
int M_Bars;
string pref="ZZ_";
datetime time_end_urov;
bool new_bar;
bool Open_UP=0,Open_DW=0;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   if(Max_Bars>0)
      M_Bars=MathMin(Max_Bars,iBars(_Symbol,0));
   else
      M_Bars=iBars(_Symbol,0);

   ArrayResize(Mas_Fract,M_Bars);

   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   remove_objects(pref);
  }
//+------------------------------------------------------------------+
//|                                                                  |
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
//  в начале rates_total=bars и prev_calculated=0, далее в течение бара они равны, 
//  при смене бара rates_total=prev_calculated+1, далее они снова равны
   new_bar=rates_total!=prev_calculated;
   int per=TF_ind;
   if(Period()>per)per=Period();
   Form_ZZ(per);

   return(rates_total);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Form_ZZ(int TF)
  {
   Find_Fractal(TF);
   Dorab_Fract(TF);
   Opred_Impuls_Wave(TF,Mas_Fract);
   Opred_Series_Wave(TF,Mas_Fract);

   Out_ZZ(TF,Mas_Fract);
   if(On_Nom_Series)Out_Nom_Series(TF,Mas_Fract);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Opred_Series_Wave(int TF,int &mas_ish[][][])
  {  // найти серии волн
   int impS=0,impS_beg=0,tek_series=0,kol_wave=0,b1=-1,b0=-1,b1S=0,b0S=0,b1S_beg=0,b0S_beg=0;
   int r0,r1,z10=0,z00=0,z11=0,z01=0;
   double H,L,HS=0,LS=0;
   double HS_beg=0,LS_beg=0;

   int n=0,m=0;
   for(int i=M_Bars-1;i>=0;i--)
     {
      if(mas_ish[i][0][0]==0)continue;

      r0=mas_ish[i][0][1]; // импульс
      r1=mas_ish[i][1][1];

      // номер бара
      b0=b1;  // левый   фрактал
      b1=i;   // текущий фрактал
              // знaчение ипульса
      z00=z10;
      z10=r0;

      z01=z11;
      z11=r1;
      if(b0<0 || b1<0)continue;

      if(z00!=0) // верт. линия
        {
         if(z00!=2) // найдена импульсная волна
           {
            L=iLow (_Symbol,TF,b0);
            H=iHigh(_Symbol,TF,b0);
            opred_prob(TF,H,L,b0,b0,z00,
                       HS,LS,b0S,b1S,impS,
                       HS_beg,LS_beg,b0S_beg,b1S_beg,impS_beg,
                       tek_series,kol_wave,n,m);
           }
         kol_wave++;
         mas_ish[b0][0][2]=tek_series*kol_wave;
        }
      //---
      if(z01!=2) // найдена импульсная волна
        {
         if(z01>0)
           {
            L=iLow (_Symbol,TF,b0);
            H=iHigh(_Symbol,TF,b1);
           }
         else
           {
            H=iHigh(_Symbol,TF,b0);
            L=iLow (_Symbol,TF,b1);
           }
         opred_prob(TF,H,L,b0,b1,z01,
                    HS,LS,b0S,b1S,impS,
                    HS_beg,LS_beg,b0S_beg,b1S_beg,impS_beg,
                    tek_series,kol_wave,n,m);
        }
      kol_wave++;
      mas_ish[i][1][2]=tek_series*kol_wave;
      //---
      if(i==0)
         if(z10!=2) // найдена импульсная волна
           {
            L=iLow (_Symbol,TF,0);
            H=iHigh(_Symbol,TF,0);
            opred_prob(TF,H,L,0,0,z10,
                       HS,LS,b0S,b1S,impS,
                       HS_beg,LS_beg,b0S_beg,b1S_beg,impS_beg,
                       tek_series,kol_wave,n,m);
            kol_wave++;
            mas_ish[0][0][2]=tek_series*kol_wave;
           }
     }
   Del_extra_obj(TF,"prob_U",n+1);
   Del_extra_obj(TF,"prob_D",m+1);

   if(On_Fibo)Out_Fibo(TF,impS_beg,b0S_beg,b1S_beg,LS_beg,HS_beg);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void opred_prob(int TF,double H,double L,int b0,int b1,int imp,
                double &HS,double &LS,int &b0S,int &b1S,int &impS,
                double &HS_beg,double &LS_beg,int &b0S_beg,int &b1S_beg,int &impS_beg,
                int &tek_series,int &kol_wave,int &n,int &m)
  {
   bool prob_up=0;
   bool prob_dw=0;
   if(ND(HS)!=0)
     {
      prob_up=impS<0 && ND(H)>ND(HS);  // пробой вверх
      prob_dw=impS>0 && ND(L)<ND(LS);  // пробой вниз
     }
   datetime t_prob;
   if(prob_up)
     {
      if(b1<2)
         t_prob=iTime(_Symbol,TF,b1)+2*TF*60;
      else
         t_prob=iTime(_Symbol,TF,b1-2);

      Out_TL(n,iTime(_Symbol,TF,b0S),HS,t_prob,HS,"prob_U",clr_Prob_UP,TF,1,2);

      if(iTime(_Symbol,TF,b0S)>time_end_urov)
        {
         time_end_urov=iTime(_Symbol,TF,b0S);
         if(iTime(_Symbol,TF,0)==iTime(_Symbol,TF,b1) && 
            ND(HS)<=ND(iHigh(_Symbol,TF,0)) &&
            ND(HS)>=ND(iLow (_Symbol,TF,0)))
           {
            Open_UP=true;
            Open_DW=false;
            if(Sound)PlaySound("alert.wav");
           }
        }
      n++;
     }
   if(prob_dw)
     {
      if(b1<2)
         t_prob=iTime(_Symbol,TF,b1)+2*TF*60;
      else
         t_prob=iTime(_Symbol,TF,b1-2);

      Out_TL(m,iTime(_Symbol,TF,b0S),LS,t_prob,LS,"prob_D",clr_Prob_DW,TF,1,2);

      if(iTime(_Symbol,TF,b0S)>time_end_urov)
        {
         time_end_urov=iTime(_Symbol,TF,b0S);
         if(iTime(_Symbol,TF,0)==iTime(_Symbol,TF,b1) && 
            ND(LS)<=ND(iHigh(_Symbol,TF,0)) &&
            ND(LS)>=ND(iLow (_Symbol,TF,0)))
           {
            Open_UP=false;
            Open_DW=true;
            if(Sound)PlaySound("email.wav");
           }
        }
      m++;
     }

   if(ND(HS)==0 || prob_up || prob_dw) // или волн ещё не было или пробой вверх/вниз
     {
      HS=H;
      LS=L;
      b0S=b0;
      b1S=b1;
      impS=imp;

      HS_beg=H;
      LS_beg=L;
      b0S_beg=b0;
      b1S_beg=b1;
      impS_beg=imp;

      tek_series=imp; // 1 или -1
      kol_wave=0;
     }
   else
      if((impS>0 && ND(H)>ND(HS)) || // превышение вверх 
         (impS<0 && ND(L)<ND(LS))) // или вниз
        {  // обновляем исходную волну
         HS=H;
         LS=L;
         b0S=b0;
         b1S=b1;
        }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Out_Fibo(int TF1,int dir,int b0,int b1,double L,double H)
  {
   if(dir>0)
     {
      double p=L;
      L=H;
      H=p;
     }
   string name=pref+str_TF(TF1)+"_Fibo";

   double d=MathCeil(0.1*((1.0*WindowBarsPerChart()-WindowFirstVisibleBar())/5.0+b1));
   b0=b1-(int)d;
   datetime t0;;
   if(b0<0)
      t0=iTime(_Symbol,TF1,0)-b0*TF1*60;
   else
      t0=iTime(_Symbol,TF1,b0);

   if(ObjectFind(name))ObjectCreate(name,OBJ_FIBO,0,iTime(_Symbol,TF1,b1),L,t0,H);

   ObjectSet(name,OBJPROP_TIME1,iTime(_Symbol,TF1,b1));
   ObjectSet(name,OBJPROP_PRICE1,L);

   ObjectSet(name,OBJPROP_TIME2,t0);
   ObjectSet(name,OBJPROP_PRICE2,H);
   ObjectSet(name,OBJPROP_COLOR,clr_Fibo);
   ObjectSet(name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_RAY_RIGHT,false);
   ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,0,clr_Fibo);
   ObjectSetInteger(0,name,OBJPROP_LEVELS,13);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,0,0);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,1,0.236);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,2,0.382);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,3,0.5);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,4,0.618);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,5,0.764);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,6,1.0);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,7,1.382);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,8,1.618);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,9,2.0);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,10,2.618);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,11,3.0);
   ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,12,4.0);
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,0,"0.0");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,1,"23.6");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,2,"38.2");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,3,"50.0");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,4,"61.8");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,5,"76.4");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,6,"100.0");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,7,"138.2");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,8,"161.8");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,9,"200.0");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,10,"261.8");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,11,"300.0");
   ObjectSetString(0,name,OBJPROP_LEVELTEXT,12,"400.0");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Find_Fractal(int TF)
  {
   int up,dw;
//---
   int max_bars;
   if(new_bar)
     {
      max_bars=M_Bars;
      ArrayInitialize(Mas_Fract,0);
     }
   else
     {
      max_bars=7;
      for(int i=0;i<max_bars-4;i++)
        {
         Mas_Fract[i][0][0]=0;
         Mas_Fract[i][1][0]=0;
        }
     }
//---
   for(int i=max_bars-4;i>=2;i--)
     {
      up=0;
      dw=0;
      double H_2=iHigh(_Symbol,TF,i-2);
      double H_1=iHigh(_Symbol,TF,i-1); // правый бар
      double H0 =iHigh(_Symbol,TF,i);   // текущий бар
      double H1 =iHigh(_Symbol,TF,i+1); // левый бар
      double H2 =iHigh(_Symbol,TF,i+2);
      double H3 =iHigh(_Symbol,TF,i+3);
      if(((ND(H0)>ND(H1) && ND(H0)>ND(H2)) || 
         (ND(H0)==ND(H1) && ND(H0)>ND(H2)) || 
         (ND(H0)>ND(H1) && ND(H0)==ND(H2)) || 
         (ND(H0)==ND(H1) && ND(H0)==ND(H2) && ND(H0)>ND(H3))) && 
         ND(H0)>ND(H_1) && ND(H0)>ND(H_2))
         up=1;
      //---
      double L_2=iLow(_Symbol,TF,i-2);
      double L_1=iLow(_Symbol,TF,i-1);
      double L0 =iLow(_Symbol,TF,i);
      double L1 =iLow(_Symbol,TF,i+1);
      double L2 =iLow(_Symbol,TF,i+2);
      double L3 =iLow(_Symbol,TF,i+3);
      if(((ND(L0)<ND(L1) && ND(L0)<ND(L2)) || 
         (ND(L0)==ND(L1) && ND(L0)<ND(L2)) || 
         (ND(L0)<ND(L1) && ND(L0)==ND(L2)) || 
         (ND(L0)==ND(L1) && ND(L0)==ND(L2) && ND(L0)<ND(L3))) && 
         ND(L0)<ND(L_1) && ND(L0)<ND(L_2))dw=1;
      //---
      if(up==1 && dw==0)
        {
         Mas_Fract[i][0][0]=1;
         Mas_Fract[i][1][0]=1;
        }
      else
      if(up==0 && dw==1)
        {
         Mas_Fract[i][0][0]=-1;
         Mas_Fract[i][1][0]=-1;
        }
      else
      if(up==1 && dw==1)
        {
         double op0=iOpen (_Symbol,TF,i);
         double cl0=iClose(_Symbol,TF,i);
         if(ND(cl0)>=ND(op0))
           {
            Mas_Fract[i][0][0]=-1;
            Mas_Fract[i][1][0]= 1;
           }
         else
           {
            Mas_Fract[i][0][0]= 1;
            Mas_Fract[i][1][0]=-1;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Dorab_Fract(int TF)
  {
   obrab_begin_ZZ(TF,Mas_Fract);  // обработать начало зиг-зага
//---
   Find_promezh_point(TF, Mas_Fract); // найти точки между одинаковыми вершинами
   ubrat_iskagen_ZZ  (TF, Mas_Fract); // убрать искажения ZZ
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void obrab_begin_ZZ(int TF,int &mas_Fr[][][])
  {
   int k,m,i;
   for(i=0;i<M_Bars;i++) // найти начало масива ZZ (i)
      if(mas_Fr[i][0][0]!=0)break;

   if(i==0)return;
//---
// найти макс и мин в начальных барах
   k=Main_iHighest(TF,i+1,0);
   m=Main_iLowest (TF,i+1,0);

   if(k==m) // вертикальная линия
     {
      if(i!=k)
         if(ND(iClose(_Symbol,TF,k))>=ND(iOpen(_Symbol,TF,k))) // бычий бар
           {
            mas_Fr[k][0][0]=-1;
            mas_Fr[k][1][0]= 1;
           }
      else    //  медв. бар
        {
         mas_Fr[m][0][0]= 1;
         mas_Fr[m][1][0]=-1;
        }
     }
   else
     {
      if(i!=k)
        {
         mas_Fr[k][0][0]= 1;
         mas_Fr[k][1][0]= 1;
        }
      if(i!=m)
        {
         mas_Fr[m][0][0]=-1;
         mas_Fr[m][1][0]=-1;
        }
     }
//---
// дорабатывем внутренние бары последней линии зиг-зага
   int min_n=(int)MathMin(k,m);
   if(min_n>0)
      if(min_n==1) // остался только 0-й бар
        {
         if(mas_Fr[min_n][1][0]<0) // окончание ZZ внизу
           {
            mas_Fr[0][0][0]= 1;
            mas_Fr[0][1][0]= 1;
           }
         else // окончание ZZ вверху
           {
            mas_Fr[0][0][0]=-1;
            mas_Fr[0][1][0]=-1;
           }
        }
   else // осталось 2 и более внутренних баров
     {
      k=Main_iHighest(TF,min_n,0);
      m=Main_iLowest (TF,min_n,0);
      if(mas_Fr[min_n][1][0]<0) // окончание ZZ внизу
        {
         mas_Fr[k][0][0]=1;  // делаем максимум
         mas_Fr[k][1][0]= 1;
         if(m<k) // если миниммальный бар дальше максимального
           {
            mas_Fr[m][0][0]=-1; // делаем минимкм
            mas_Fr[m][1][0]=-1;
            if(m>0) // если минимум не на нулевом бара
              {
               mas_Fr[0][0][0]=1; // на нулевом делаем макс.
               mas_Fr[0][1][0]=1;
              }
           }
         else // если миниммальный бар ближе максимального
         if(k>0) // и макс. бар не на нуле
           {
            mas_Fr[0][0][0]=-1; // на нулевом делаем мин.
            mas_Fr[0][1][0]=-1;
           }
        }
      else // окончание ZZ вверху
        {
         mas_Fr[m][0][0]=-1;
         mas_Fr[m][1][0]=-1;
         if(k<m)
           {
            mas_Fr[k][0][0]=1;
            mas_Fr[k][1][0]=1;
            if(k>0)
              {
               mas_Fr[0][0][0]=-1;
               mas_Fr[0][1][0]=-1;
              }
           }
         else
         if(m>0)
           {
            mas_Fr[0][0][0]=1;
            mas_Fr[0][1][0]=1;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Find_promezh_point(int TF,int &mas_ish_ZZ[][][])
  { // найти точки между одинаковыми вершинами
   int r0,r1,k,b0=0,b1=0,z0=0,z1=0;
//---
   int max_bars;
   if(new_bar)
      max_bars=M_Bars;
   else
      max_bars=7;
//---
   for(int i=0;i<max_bars;i++)
     {
      r0=mas_ish_ZZ[i][0][0];
      if(r0==0)continue;

      r1=mas_ish_ZZ[i][1][0];

      b0=b1; // правый фрактал
      b1=i;  // левый фрактал
             // запоминаем левый фрактал:
      z0=z1;
      z1=r0;

      if(r1*z0>0) // одинаковые фракталы
         if(b1-b0>1)
            if(r1>0) // два максимума
              {
               k=Main_iLowest(TF,b1-b0-1,b0+1);
               mas_ish_ZZ[k][0][0]=-1;
               mas_ish_ZZ[k][1][0]=-1;
              }
      else // два минимума
        {
         k=Main_iHighest(TF,b1-b0-1,b0+1);
         mas_ish_ZZ[k][0][0]=1;
         mas_ish_ZZ[k][1][0]=1;
        }
     }
  }
//---
void ubrat_iskagen_ZZ(int TF,int &mas_ish_ZZ[][][])
  {   // убрать искажения ZZ: если максимум ниже пред. минимума и наоборот
   int r0,r1,b0=0,b1=0,f0=0,f1=0;
   double p0,p1;

   for(int i=0;i<M_Bars;i++)
     {
      r0=mas_ish_ZZ[i][0][0];
      if(r0==0)continue;

      r1=mas_ish_ZZ[i][1][0];

      b0=b1;
      b1=i;

      f0=f1;
      f1=r0;

      p1=iLow (_Symbol,TF,b1);
      p0=iHigh(_Symbol,TF,b0);
      if(r0<0 && f0>0 && ND(p1)>=ND(p0))
        {
         mas_ish_ZZ[b0][0][0]=0;
         mas_ish_ZZ[b0][1][0]=0;
         mas_ish_ZZ[b1][0][0]=0;
         mas_ish_ZZ[b1][1][0]=0;
         continue;
        }
      p1=iHigh(_Symbol,TF,b1);
      p0=iLow (_Symbol,TF,b0);
      if(r0>0 && f0<0 && ND(p1)<=ND(p0))
        {
         mas_ish_ZZ[b0][0][0]=0;
         mas_ish_ZZ[b0][1][0]=0;
         mas_ish_ZZ[b1][0][0]=0;
         mas_ish_ZZ[b1][1][0]=0;
        }
     }
  }
//---
void Opred_Impuls_Wave(int TF,int &mas_ish_ZZ[][][])
  {   // выделить импульсные волны
   int r0,r1,z10=0,z00=0,z_10=0,z11=0,z01=0,z_11=0,b1=0,b0=0,b_1=0;
   double p1,p0L,p0H,p_1;

   for(int i=M_Bars-1;i>=0;i--)
     {
      r0=mas_ish_ZZ[i][0][0];
      if(r0==0)continue;

      r1=mas_ish_ZZ[i][1][0];

      // номер бара
      b1=b0;  // левый   фрактал
      b0=b_1; // текущий фрактал
      b_1=i;  // правый  фрактал
              // знaчение фрактала
      z10=z00;
      z00=z_10;
      z_10=r0;

      z11=z01;
      z01=z_11;
      z_11=r1;
      if(z00==z01) // слева и справа наклонные линии
         if(z_10>0) // правая линия вверх
           {
            p1 =iHigh(_Symbol,TF,b1);
            p_1=iHigh(_Symbol,TF,b_1);
            if(ND(p_1)>ND(p1))
               mas_ish_ZZ[b0][1][1]=1;
            else
               mas_ish_ZZ[b0][1][1]=2; // кор. волна
            mas_ish_ZZ[b0][0][1]=0;
           }
      else // правая линия вниз
        {
         p1 =iLow(_Symbol,TF,b1);
         p_1=iLow(_Symbol,TF,b_1);
         if(ND(p_1)<ND(p1))
            mas_ish_ZZ[b0][1][1]=-1;
         else
            mas_ish_ZZ[b0][1][1]=2;
         mas_ish_ZZ[b0][0][1]=0;
        }
      else
      if(z00<0) // верт. линия вверх
        {
         p1 =iHigh(_Symbol,TF,b1);
         p0H=iHigh(_Symbol,TF,b0);
         if(ND(p0H)>ND(p1))
            mas_ish_ZZ[b0][0][1]=1;
         else
            mas_ish_ZZ[b0][0][1]=2;

         p1 =iLow(_Symbol,TF,b0);
         p_1=iLow(_Symbol,TF,b_1);
         if(ND(p_1)<ND(p1))
            mas_ish_ZZ[b0][1][1]=-1;
         else
            mas_ish_ZZ[b0][1][1]=2;
        }
      else  // верт. линия вниз
        {
         p1 =iLow (_Symbol,TF,b1);
         p0L=iLow (_Symbol,TF,b0);
         if(ND(p0L)<ND(p1))
            mas_ish_ZZ[b0][0][1]=-1;
         else
            mas_ish_ZZ[b0][0][1]=2;

         p1 =iHigh(_Symbol,TF,b0);
         p_1=iHigh(_Symbol,TF,b_1);
         if(ND(p_1)>ND(p1))
            mas_ish_ZZ[b0][1][1]=1;
         else
            mas_ish_ZZ[b0][1][1]=2;
        }
      if(i==0)
         if(z_10<0) // верт. линия вверх
           {
            p1 =iHigh(_Symbol,TF,b0);
            p0H=iHigh(_Symbol,TF,0);
            if(ND(p0H)>ND(p1))
               mas_ish_ZZ[0][0][1]=1;
            else
               mas_ish_ZZ[0][0][1]=2;
           }
      else  // верт. линия вниз
      if(z_10>0) // верт. линия вверх
        {
         p1 =iLow (_Symbol,TF,b0);
         p0L=iLow (_Symbol,TF,0);
         if(ND(p0L)<ND(p1))
            mas_ish_ZZ[0][0][1]=-1;
         else
            mas_ish_ZZ[0][0][1]=2;
        }
      else
         mas_ish_ZZ[0][0][1]=2;
     }
  }
//---
void Out_ZZ(int TF,int &mas_ish_ZZ[][][])
  {   // Вывести ZZ       
   int r0=0,r1=0,z0=0,z1=0,z11=0,z10=0,b0=0,b1=0,m0=0,m1=0;
   double L0=0,H0=0,L1=0,H1=0;
   datetime t0=0,t1=0;

   for(int i=M_Bars-1;i>=0;i--)
      //   for (int i=0;i<M_Bars;i++)
     {
      r0=mas_ish_ZZ[i][0][0];
      if(r0==0)continue;

      r1=mas_ish_ZZ[i][1][0];

      b1=b0; // левый фрактал
      b0=i;  // текущий фрактал

      z1=z0;
      z0=r0;

      z11=z10;
      z10=r1;

      if(b1==0)continue;

      L1=iLow(_Symbol,TF,b1); // левый фрактал
      H1=iHigh(_Symbol,TF,b1);
      t1=iTime(_Symbol,TF,b1);


      L0=iLow(_Symbol,TF,b0); // текущий фрактал
      H0=iHigh(_Symbol,TF,b0);
      t0=iTime(_Symbol,TF,b0);
      //---
      if(z0<0) // линия вниз
        {
         Out_TL(m0,t0,L0,t1,H1,"T_D",mas_ish_ZZ[b0][1][2]>0?clr_Series_Up:clr_Series_Dw,TF,mas_ish_ZZ[b1][1][1]!=2,4);
         m0++;
        }
      else
      if(z0>0) // линия вверх
        {
         Out_TL(m1,t0,H0,t1,L1,"T_U",mas_ish_ZZ[b0][1][2]>0?clr_Series_Up:clr_Series_Dw,TF,mas_ish_ZZ[b1][1][1]!=2,4);
         m1++;
        }
      //---
      if(z1!=z11) // слева верт.линия
         if(z1<0) // линия вверх
           {
            Out_TL(m1,t1,L1,t1,H1,"T_U",mas_ish_ZZ[b1][0][2]>0?clr_Series_Up:clr_Series_Dw,TF,mas_ish_ZZ[b1][0][1]!=2,4);
            m1++;
           }
      else // линия вниз
        {
         Out_TL(m0,t1,L1,t1,H1,"T_D",mas_ish_ZZ[b1][0][2]>0?clr_Series_Up:clr_Series_Dw,TF,mas_ish_ZZ[b1][0][1]!=2,4);
         m0++;
        }
     }
//---
   if(r1 !=r0) // в конце верт.линия
      if(r0<0) // линия вверх
        {
         Out_TL(m1,t0,L0,t0,H0,"T_U",mas_ish_ZZ[b0][0][2]>0?clr_Series_Up:clr_Series_Dw,TF,mas_ish_ZZ[b0][0][1]!=2,4);
         m1++;
        }
   else // линия вниз
     {
      Out_TL(m0,t0,L0,t0,H0,"T_D",mas_ish_ZZ[b0][0][2]>0?clr_Series_Up:clr_Series_Dw,TF,mas_ish_ZZ[b0][0][1]!=2,4);
      m0++;
     }
   Del_extra_obj(TF,"T_U",m1);
   Del_extra_obj(TF,"T_D",m0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Del_extra_obj(int tf,string s,int n)
  {
   string name;
   bool F;
   do
     {
      name=pref+str_TF(tf)+"_"+s+(string)n;
      F=ObjectFind(name)>=0;
      if(F)ObjectDelete(name);
      n++;
     }
   while(F);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Main_iHighest(int tf,int n,int beg)
  {
   double pr,pr_max=0.0;
   int n_max=beg;
   for(int i=beg;i<beg+n;i++)
     {
      pr=iHigh(_Symbol,tf,i);
      if(pr>pr_max)
        {
         pr_max=pr;
         n_max=i;
        }
     }
   return(n_max);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Main_iLowest(int tf,int n,int beg)
  {
   double pr,pr_min=999999.0;
   int n_min=beg;
   for(int i=beg;i<beg+n;i++)
     {
      pr=iLow(_Symbol,tf,i);
      if(pr<pr_min)
        {
         pr_min=pr;
         n_min=i;
        }
     }
   return(n_min);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Out_Nom_Series(int TF,int &mas_ich[][][])
  {   // вывести фракталы
   int z,m=0,n=0,b=0;
   color clr;

   for(int i=M_Bars-1;i>=0;i--)
     {
      z=mas_ich[i][0][0];
      if(z==0)continue;
        {
         if(b>=Bars)break;

         if(mas_ich[i][0][2]!=0) // верт.линия
           {
            clr=clr_txt(b,i,mas_ich[i][0][2]);
            if(z>0){Out_txt(m,iTime(_Symbol,TF,i),iLow (_Symbol,TF,i),"N_D",clr,TF,ANCHOR_UPPER, (string)mas_ich[i][0][2]);m++;}
            if(z<0){Out_txt(n,iTime(_Symbol,TF,i),iHigh(_Symbol,TF,i),"N_U",clr,TF,ANCHOR_LOWER, (string)mas_ich[i][0][2]);n++;}
           }
         if(mas_ich[i][1][2]!=0)
           {
            clr=clr_txt(b,i,mas_ich[i][1][2]);
            if(z>0){Out_txt(n,iTime(_Symbol,TF,i),iHigh(_Symbol,TF,i),"N_U",clr,TF,ANCHOR_LOWER, (string)mas_ich[i][1][2]);n++;}
            if(z<0){Out_txt(m,iTime(_Symbol,TF,i),iLow (_Symbol,TF,i),"N_D",clr,TF,ANCHOR_UPPER, (string)mas_ich[i][1][2]);m++;}
           }
        }
     }
   Del_extra_obj(TF,"N_U",n);
   Del_extra_obj(TF,"N_D",m);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color clr_txt(int b,int i,int n)
  {
   color c=clr_Series_Dw;

//   if (b<=2 && i<=2)
//      c=clr_Tail_ZZ;
//   else
   if(n>0)
      c=clr_Series_Up;
   return(c);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string str_TF(int n)
  {
   if(n==0)n=Period();
   switch(n)
     {
      case PERIOD_M1:  return ("M1 ");
      case PERIOD_M5:  return ("M5");
      case PERIOD_M15: return ("M15");
      case PERIOD_M30: return ("M30");
      case PERIOD_H1:  return ("H1");
      case PERIOD_H4:  return ("H4");
      case PERIOD_D1:  return ("D1");
      case PERIOD_W1:  return ("W1");
      case PERIOD_MN1: return ("MN1");
     }
   return("TF?");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void remove_objects(string PreName)
  {
   string Obj_Name,Head;
   for(int k=ObjectsTotal()-1; k>=0; k--)
     {
      Obj_Name=ObjectName(k);
      Head=StringSubstr(Obj_Name,0,StringLen(PreName));
      if(Head==PreName)ObjectDelete(Obj_Name);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double ND(double n)
  {
   return(NormalizeDouble(n,Digits));
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Out_TL(int i,datetime t1,double pr1,datetime t2,double pr2,string s,color col,int TF,bool impuls,int width)
  {
   string name=pref+str_TF(TF)+"_"+s+(string)i;
   if(ObjectFind(name))ObjectCreate(name,OBJ_TREND,0,0,0,0,0);

   ObjectSet(name,OBJPROP_TIME1,t1);
   ObjectSet(name,OBJPROP_TIME2,t2);
   ObjectSet(name,OBJPROP_PRICE1,pr1);
   ObjectSet(name,OBJPROP_PRICE2,pr2);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_RAY,0);
   if(impuls)
     {
      ObjectSet(name,OBJPROP_WIDTH,width);
      ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
     }
   else
     {
      ObjectSet(name,OBJPROP_WIDTH,1);
      ObjectSet(name,OBJPROP_STYLE,STYLE_SOLID);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Out_Arrow(int i,datetime t,double pr,string s,color col,int cod,int TF,int anchor)
  {
   string name=pref+str_TF(TF)+"_"+s+(string)i;
   if(ObjectFind(name))ObjectCreate(name,OBJ_ARROW,0,0,0);

   ObjectSet(name,OBJPROP_TIME1,t);
   ObjectSet(name,OBJPROP_PRICE1,pr);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_WIDTH,1);
   ObjectSet(name,OBJPROP_ARROWCODE,cod);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Out_txt(int i,datetime t,double pr,string s,color col,int TF,int anchor,string sn)
  {
   string name=pref+str_TF(TF)+"_"+s+(string)i;
   if(ObjectFind(name))ObjectCreate(name,OBJ_TEXT,0,0,0);

   ObjectSetText(name,sn,10,"Arial Black");
   ObjectSet(name,OBJPROP_TIME1,t);
   ObjectSet(name,OBJPROP_PRICE1,pr);
   ObjectSet(name,OBJPROP_COLOR,col);
   ObjectSet(name,OBJPROP_WIDTH,1);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR,anchor);
  }
//+------------------------------------------------------------------+
