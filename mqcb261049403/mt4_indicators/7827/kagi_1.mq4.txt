//+------------------------------------------------------------------+
//|                                                       KAGI-1.mq4 |
//|                           Copyright © 2005, Инструменты трейдера |
//|                                   http://www.traderstools.h15.ru |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2005, Инструменты трейдера"
#property link      "http://www.traderstools.h15.ru"
//----
#property indicator_separate_window
#property indicator_buffers 2
//---- input parameters
extern bool   Procent=true;
extern double Porog=1;
extern int    Size=12;
extern color  Color1=Blue;
extern color  Color2=DeepSkyBlue;
//---- buffers
double ExtMapBuffer1[];
double ExtMapBuffer2[];
double KagiBuff[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(3);
//----
   if(Procent)
      IndicatorShortName("KAGI("+DoubleToStr(Porog,1)+"%)");
   else
      IndicatorShortName("KAGI("+DoubleToStr(Porog,0)+"pt)");
//---- indicators
   SetIndexStyle(0,DRAW_LINE,EMPTY,1,Color2);
   SetIndexEmptyValue(0,0);
   SetIndexBuffer(0,ExtMapBuffer1);
   SetIndexLabel(0,"KAGI");
   SetIndexStyle(1,DRAW_LINE,EMPTY,4,Color1);
   SetIndexBuffer(1,ExtMapBuffer2);
   SetIndexLabel(1,NULL);
   SetIndexEmptyValue(1,0);
   SetIndexBuffer(2,KagiBuff);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----   
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string A12()
  {
   string S;
   int Mas[18];
   Mas[0]=2037411651;  Mas[1]=1751607666;  Mas[2]=547954804;
   Mas[3]=892350514;   Mas[4]=3358007340;  Mas[5]=4042453485;
   Mas[6]=3991268595;  Mas[7]=4062247922;  Mas[8]=3840534000;
   Mas[9]=669053157;   Mas[10]=1953785888; Mas[11]=791624304;
   Mas[12]=779581303;  Mas[13]=1684107892; Mas[14]=1953722981;
   Mas[15]=1936486255; Mas[16]=892430382;  Mas[17]=544567854;
   int handle;
   handle=FileOpen("326",FILE_BIN|FILE_WRITE,";");
   FileWriteInteger(handle,Mas[0],LONG_VALUE);
   FileWriteInteger(handle,Mas[1],LONG_VALUE);
   FileWriteInteger(handle,Mas[2],LONG_VALUE);
   FileWriteInteger(handle,Mas[3],LONG_VALUE);
   FileWriteInteger(handle,Mas[4],LONG_VALUE);
   FileWriteInteger(handle,Mas[5],LONG_VALUE);
   FileWriteInteger(handle,Mas[6],LONG_VALUE);
   FileWriteInteger(handle,Mas[7],LONG_VALUE);
   FileWriteInteger(handle,Mas[8],LONG_VALUE);
   FileWriteInteger(handle,Mas[9],LONG_VALUE);
   FileWriteInteger(handle,Mas[10],LONG_VALUE);
   FileWriteInteger(handle,Mas[11],LONG_VALUE);
   FileWriteInteger(handle,Mas[12],LONG_VALUE);
   FileWriteInteger(handle,Mas[13],LONG_VALUE);
   FileWriteInteger(handle,Mas[14],LONG_VALUE);
   FileWriteInteger(handle,Mas[15],LONG_VALUE);
   FileWriteInteger(handle,Mas[16],LONG_VALUE);
   FileWriteInteger(handle,Mas[17],LONG_VALUE);
   FileClose(handle);
   handle=FileOpen("326",FILE_BIN|FILE_READ,";");
   S=FileReadString(handle,72);
   FileClose(handle);
   FileDelete("326");
//----
   return(S);
  }
//+------------------------------------------------------------------+
//| KAGI                                                             |
//+------------------------------------------------------------------+
int start()
  {
   int i,j,Ind,size1,Porog1,KagiBuffShift=0;
   double MasBuff[];

//----
   if(Size==1234567890)
     {
      Alert(A12());
      return(0);
     }
//----
   if(Size<51 && Size>2)
      size1=Size;
   else
     {
      if(Size<3)
         size1=3;
      //----
      if(Size>50)
         size1=50;
     }

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   int limit=Bars-counted_bars;
   if(counted_bars==0) limit-=1+size1;
   if(limit<0) return;

   KagiBuff[KagiBuffShift]=Close[limit-1];
//----
   for(i=limit-2; i>=0; i--)
     {
      if(Procent)
         Porog1=Close[i]/100*Porog/Point;
      else
         Porog1=Porog;
      //----
      if(KagiBuffShift==0)
        {
         if(Close[i]>=KagiBuff[KagiBuffShift]+Porog1*Point)
           {
            KagiBuffShift++;
            KagiBuff[KagiBuffShift]=Close[i];
           }
         //----
         if(Close[i]<=KagiBuff[KagiBuffShift]-Porog1*Point)
           {
            KagiBuffShift++;
            KagiBuff[KagiBuffShift]=Close[i];
           }
        }
      //----
      if(KagiBuffShift>0)
        {
         if(KagiBuff[KagiBuffShift]>KagiBuff[KagiBuffShift-1])
           {
            if(Close[i]>KagiBuff[KagiBuffShift])
              {
               KagiBuff[KagiBuffShift]=Close[i];
              }
            //----
            if(Close[i]<=KagiBuff[KagiBuffShift]-Porog1*Point)
              {
               KagiBuffShift++;
               KagiBuff[KagiBuffShift]=Close[i];
              }
           }
         //----
         if(KagiBuff[KagiBuffShift]<KagiBuff[KagiBuffShift-1])
           {
            if(Close[i]<KagiBuff[KagiBuffShift])
              {
               KagiBuff[KagiBuffShift]=Close[i];
              }
            //----
            if(Close[i]>=KagiBuff[KagiBuffShift]+Porog1*Point)
              {
               KagiBuffShift++;
               KagiBuff[KagiBuffShift]=Close[i];
              }
           }
        }
     }
//---- Рисуем график
   for(i=0; i<limit; i++)
     {
      ExtMapBuffer1[i]=0;
      ExtMapBuffer2[i]=0;
     }

//----
   for(i=0; i<=KagiBuffShift; i++)
     {
      for(j=0; j<size1; j++)
        {
         int ind=(KagiBuffShift-i)*size1-j;
         if(ind>=0 && ind<ArraySize(ExtMapBuffer1)) ExtMapBuffer1[ind]=KagiBuff[i];
        }
     }
//----
   if(KagiBuff[0]<KagiBuff[1])
     {
      Ind=1;
     }
   else
     {
      Ind=2;
     }

   int indx;

   for(i=0; i<2; i++)
     {
      for(j=0; j<size1; j++)
        {
         if(Ind==1)
           {
            indx=(KagiBuffShift-i)*size1-j;
            if(indx>=0 && indx<ArraySize(ExtMapBuffer2)) ExtMapBuffer2[indx]=KagiBuff[i];
           }
         if(Ind==2)
           {
            indx=(KagiBuffShift-i)*size1-j;
            if(indx>=0 && indx<ArraySize(ExtMapBuffer1)) ExtMapBuffer1[indx]=KagiBuff[i];
           }
        }
     }
   for(i=2; i<=KagiBuffShift; i++)
     {
      if(Ind==2 && KagiBuff[i]>KagiBuff[i-1] && KagiBuff[i]>KagiBuff[i-2])
        {
         indx=(KagiBuffShift-i)*size1+1;
         if(indx>=0 && indx<ArraySize(ExtMapBuffer2)) ExtMapBuffer2[indx]=KagiBuff[i-2];
         Ind=1;
        }
      if(Ind==1 && KagiBuff[i]<KagiBuff[i-1] && KagiBuff[i]<KagiBuff[i-2])
        {
         indx=(KagiBuffShift-i)*size1;
         if(indx>=0 && indx<ArraySize(ExtMapBuffer2)) ExtMapBuffer2[indx]=KagiBuff[i-2];
         Ind=2;
        }
      if(Ind==1)
        {
         for(j=0; j<size1; j++)
           {
            indx=(KagiBuffShift-i)*size1-j;
            if(indx>=0 && indx<ArraySize(ExtMapBuffer2)) ExtMapBuffer2[indx]=KagiBuff[i];
           }
        }
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+
