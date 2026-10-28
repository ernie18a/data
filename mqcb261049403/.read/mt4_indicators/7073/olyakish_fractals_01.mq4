//+------------------------------------------------------------------+
//|                                             olyakish_fractals_01 |
//|                                      Copyright © -2007, olyakish |
//|                                           plutonia-dmb#yandex.ru |
//+------------------------------------------------------------------+
#property copyright "olyakish"
#property link "plutonia-dmb#yandex.ru"
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Green   // Зеленый фрактал
#property indicator_color2 Red     // Приседающий
#property indicator_color3 Brown   // Увядающий
#property indicator_color4 Blue    // Фальшивый
//----
extern int			Pips		= 15;
extern int			ShiftBars	= 150;
double ExtLimeBuffer[];
double ExtRedBuffer[];
double ExtSaddleBrownBuffer[];
double ExtBlueBuffer[];
int i,j;
double a_Fractal[2]; // 0- последний 1-предыдущий
double a_MFI[2];     // 0- последний 1-предыдущий
double a_Volume[2];  // 0- последний 1-предыдущий
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   SetIndexBuffer(0, ExtLimeBuffer);
   SetIndexBuffer(1, ExtRedBuffer);
   SetIndexBuffer(2, ExtSaddleBrownBuffer);
   SetIndexBuffer(3, ExtBlueBuffer);
//----
   SetIndexStyle(0, DRAW_ARROW, 0, 1);
   SetIndexStyle(1, DRAW_ARROW, 0, 1);
   SetIndexStyle(2, DRAW_ARROW, 0, 1);
   SetIndexStyle(3, DRAW_ARROW, 0, 1);
   
   SetIndexArrow(0, 177);
   SetIndexArrow(1, 177);
   SetIndexArrow(2, 177);
   SetIndexArrow(3, 177);               
///----
   SetIndexLabel(0, "Зеленый фрактал");
   SetIndexLabel(1, "Приседающий фрактал");
   SetIndexLabel(2, "Увядающий фрактал");
   SetIndexLabel(3, "Фальшивый фрактал");
//----
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int deinit()
  {
   Comment("");
   Comment("");
   return(0);
  }        
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {  
   int n = 3;
   while(ExtLimeBuffer[n] != NULL || ExtRedBuffer[n] != NULL || 
         ExtSaddleBrownBuffer[n] != NULL || ExtBlueBuffer[n] != NULL)
     {
       if(n > ShiftBars) 
         {
           n = ShiftBars;
           break;
         }
       n++;
     }
   for(int i = n + 20; i >= 3; i--)
     {
       //-- верхние фракталы
       ArrayInitialize(a_Fractal, 0);
       ArrayInitialize(a_MFI, 0);
       ArrayInitialize(a_Volume, 0);
       // на i баре есть фрактал вверх
       if(iFractals(NULL, 0, MODE_UPPER, i) != 0)
         {
           Comment("olyakish_fractals_01\n",i, ", ", j);
           Sleep(1000);                 
           // цена на фрактале 
           a_Fractal[0] = iFractals(NULL, 0, MODE_UPPER, i);              
           a_Volume[0] = Volume[i] + Volume[i+1] + Volume[i+2] + 
                         Volume[i-1] + Volume[i-2];   // объем
           a_MFI[0] = (High[i] - Low[i] + High[i-1] - Low[i-1] + 
                      High[i-2] - Low[i-2] + High[i+1] - Low[i+1] + 
                      High[i+2] - Low[i+2]) / a_Volume[0];  // MFI
           // пошли искать фрактал на вниз по истории
           j = i + 1;
           while(a_Fractal[1] == 0)
             {
               if(iFractals(NULL, 0, MODE_UPPER, j) != 0) 
                 {
                   break;
                 }
               //-- Нашли фрактал  вниз
               if(iFractals(NULL, 0, MODE_LOWER, j) != 0)
                 {
                   a_Fractal[1] = iFractals(NULL, 0, MODE_LOWER, j);
                   a_Volume[1] = Volume[j+2] + Volume[j+1] + Volume[j] + 
                                 Volume[j-1] + Volume[j-2];
                   a_MFI[1] = (High[j+1] - Low[j+1] + High[j+2] - 
                              Low[j+2] + High[j] - Low[j] + High[j-1] - 
                              Low[j-1] + High[j-2] - Low[j-2]) / a_Volume[1];                                             
                   if(a_Volume[0] > a_Volume[1] && a_MFI[0] < a_MFI[1])
                     {
                       // имеем приседающий фрактал (MFI - объем +)
                       ExtRedBuffer[i] = High[i]; // + Pips*Point;
                       break;
                     }
                   if(a_Volume[0] > a_Volume[1] && a_MFI[0] > a_MFI[1])
                     {
                       // имеем зеленый фрактал (MFI + объем +)
                       ExtLimeBuffer[i] = High[i]; // + Pips*Point;
                       break;
                     }
                   if(a_Volume[0] < a_Volume[1] && a_MFI[0] > a_MFI[1])
                     {
                       // имеем фальшивый фрактал (MFI + объем -)
                       ExtBlueBuffer[i] = High[i]; // + Pips*Point;
                       break;
                     }      
                   if(a_Volume[0] < a_Volume[1] && a_MFI[0] < a_MFI[1])
                     {
                       // имеем увядающий фрактал (MFI - объем -)
                       ExtSaddleBrownBuffer[i] = High[i]; // + Pips*Point;
                       break;
                     }
                 }                          
               j++;                                         
             }
         }
       //--- нижние фракталы
       ArrayInitialize(a_Fractal, 0);
       ArrayInitialize(a_MFI, 0);
       ArrayInitialize(a_Volume, 0);
       // на i баре есть фрактал вниз
       if(iFractals(NULL, 0, MODE_LOWER, i) != 0)
         {
           // цена на фрактале 
           a_Fractal[0] = iFractals(NULL, 0, MODE_LOWER, i);              
           a_Volume[0] = Volume[i] + Volume[i+1] + Volume[i+2] + 
                         Volume[i-1] + Volume[i-2];  // объем
           a_MFI[0] = (High[i] - Low[i] + High[i-1] - Low[i-1] + 
                      High[i-2] - Low[i-2] + High[i+1] - Low[i+1] + 
                      High[i+2] - Low[i+2]) / a_Volume[0];  // MFI
           // пошли искать фрактал на вверх по истории
           j = i + 1;
           while(a_Fractal[1] == 0)
             {
               if(iFractals(NULL, 0, MODE_LOWER, j) != 0) 
                 {
                   break;
                 }
               //-- Нашли фрактал  вверх
               if(iFractals(NULL, 0, MODE_UPPER, j) != 0)
                 {
                   a_Fractal[1] = iFractals(NULL, 0, MODE_UPPER, j);
                   a_Volume[1] = Volume[j+2] + Volume[j+1] + Volume[j] + 
                                 Volume[j-1] + Volume[j-2];
                   a_MFI[1] = (High[j+1] - Low[j+1] + High[j+2] - Low[j+2] + 
                              High[j] - Low[j] + High[j-1] - Low[j-1] + 
                              High[j-2] - Low[j-2]) / a_Volume[1];                                             
                   if(a_Volume[0] > a_Volume[1] && a_MFI[0] < a_MFI[1])
                     {
                       // имеем приседающий фрактал (MFI - объем +)
                       ExtRedBuffer[i] = Low[i]; // - Pips*Point;
                       break;
                     }
                   if(a_Volume[0] > a_Volume[1] && a_MFI[0] > a_MFI[1])
                     {
                       // имеем зеленый фрактал (MFI + объем +)
                       ExtLimeBuffer[i] = Low[i]; // - Pips*Point;
                       break;
                     }
                   if(a_Volume[0] < a_Volume[1] && a_MFI[0] > a_MFI[1])
                     {
                       // имеем фальшивый фрактал (MFI + объем -)
                       ExtBlueBuffer[i] = Low[i]; // - Pips*Point;
                       break;
                     }
                   if(a_Volume[0] < a_Volume[1] && a_MFI[0] < a_MFI[1])
                     {
                       // имеем увядающий фрактал (MFI - объем -)
                       ExtSaddleBrownBuffer[i] = Low[i]; // - Pips*Point;
                       break;
                     }
                 }
               j++;                                         
             }
         }
     }
   return(0);
  }
//+------------------------------------------------------------------+



