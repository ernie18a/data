//+------------------------------------------------------------------+
//|                                                              v04 |
//|                                                                  |
//| v02                                                              |
//| Добавлен процент для отсеивания фракталов                        |
//| v03                                                              |
//| Рисует линии                                                     |
//| v04                                                              |
//| Фильтр для линий по аллигатору                                   |
//| v05                                                              |
//| выбор варианта построения линий                                  |
//| v06                                                              |
//| выбор количества баров в фрактале                                |
//+------------------------------------------------------------------+

#property copyright "by olyakish"
#property link      ""
//----
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Lime //Зеленый фрактал
#property indicator_color2 Red // Приседающий
#property indicator_color3 SaddleBrown //Увядающий
#property indicator_color4 Blue // Фальшивый
//----
extern int			Pips		= 15;
extern int			ShiftBars	= 1000;
extern string rem0="Количество баров в фрактале";
extern int			BarsInFractal	= 11;
extern string rem1="Процент для отсеивания по объему";
extern int Percent=110;
extern string rem2="Рисовать предыдущие линии?";
extern bool UseOldLine=true;
extern string rem3="По каким фракталам рисуем линии";
extern string rem4="0-зеленые,1-приседающие";
extern string rem5="2-увядающие,3-фальшивые";
extern int FractalLines=1;

double ExtLimeBuffer[];
double ExtRedBuffer[];
double ExtSaddleBrownBuffer[];
double ExtBlueBuffer[];
int i,j,z;
double a_Fractal[2]; // 0- последний 1-предыдущий
double a_MFI[2];     // 0- последний 1-предыдущий
double a_Volume[2];  // 0- последний 1-предыдущий

bool objects_initialized=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int init()
  {
   int test;
   test=BarsInFractal/2;
   if (test*2==BarsInFractal){Alert("Значение BarsInFractal должно быть нечетным");deinit();}
   if (BarsInFractal<3){Alert("Значение BarsInFractal должно быть >=3");deinit();}
   SetIndexShift(0,0);
   SetIndexShift(1,0);
   SetIndexShift(2,0);
   SetIndexShift(3,0);
//----
   SetIndexBuffer(0, ExtLimeBuffer);
   SetIndexBuffer(1, ExtRedBuffer);
   SetIndexBuffer(2, ExtSaddleBrownBuffer);
   SetIndexBuffer(3, ExtBlueBuffer);
//----
   SetIndexStyle(0, DRAW_ARROW );
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexStyle(2, DRAW_ARROW);
   SetIndexStyle(3, DRAW_ARROW);
   
   SetIndexArrow(0,177);
   SetIndexArrow(1,177);
   SetIndexArrow(2,177);
   SetIndexArrow(3,177);               
   
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
bool ObjectsInit()
  {
//---- check if we have enough bars
   if(ArraySize(High)<3)
     {
      Print("Timeseries is not ready yet - exit");
      return(false);
     }
//----

     ObjectCreate("Up",OBJ_TREND,0,iTime(NULL, 0, 2),High[2],iTime(NULL, 0, 1),High[1],0,0);
     ObjectSet("Up",OBJPROP_COLOR,Aqua);
     ObjectSet("Up",OBJPROP_RAY,true);
     ObjectSet("Up",OBJPROP_BACK,1);
     
     ObjectCreate("Down",OBJ_TREND,0,iTime(NULL, 0, 2),Low[2],iTime(NULL, 0, 1),Low[1],0,0);
     ObjectSet("Down",OBJPROP_COLOR,Tomato);
     ObjectSet("Down",OBJPROP_RAY,true);
     ObjectSet("Down",OBJPROP_BACK,1);
     if (UseOldLine)
      {
         ObjectCreate("Up_Prev",OBJ_TREND,0,iTime(NULL, 0, 2),High[2],iTime(NULL, 0, 1),High[1],0,0);
         ObjectSet("Up_Prev",OBJPROP_COLOR,Aqua);
         ObjectSet("Up_Prev",OBJPROP_RAY,true);
         ObjectSet("Up_Prev",OBJPROP_STYLE,STYLE_DASH);
         ObjectSet("Up_Prev",OBJPROP_BACK,1);
     
         ObjectCreate("Down_Prev",OBJ_TREND,0,iTime(NULL, 0, 2),Low[2],iTime(NULL, 0, 1),Low[1],0,0);
         ObjectSet("Down_Prev",OBJPROP_COLOR,Tomato);
         ObjectSet("Down_Prev",OBJPROP_RAY,true);         
         ObjectSet("Down_Prev",OBJPROP_STYLE,STYLE_DASH);
         ObjectSet("Down_Prev",OBJPROP_BACK,1);
      }      
//----
   return(true);
  }  
int deinit()
   {
      ObjectDelete("Up");
      ObjectDelete("Down");
      if (UseOldLine)
         {
            ObjectDelete("Up_Prev");
            ObjectDelete("Down_Prev");
         }
   return(0);
  }   
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {  
   if(!objects_initialized)
     {
      objects_initialized=ObjectsInit();
     }      
   int n=BarsInFractal;
   while (ExtLimeBuffer[n]!=NULL || ExtRedBuffer[n]!=NULL || ExtSaddleBrownBuffer[n]!=NULL || ExtBlueBuffer[n]!=NULL)
      {
         if (n>ShiftBars) {n=ShiftBars;break;}
         n++;
      }
   for(int i=n+20; i>=(BarsInFractal/2+1); i--)
     {
         //-- верхние фракталы
         ArrayInitialize(a_Fractal,0);
         ArrayInitialize(a_MFI,0);
         ArrayInitialize(a_Volume,0);         
         if (High[i]==High[iHighest(Symbol(),0,MODE_HIGH,BarsInFractal,i-BarsInFractal/2)]) // на i баре есть фрактал вверх
            {               
               a_Fractal[0]=High[i];   // цена на фрактале               
               for (z=i-BarsInFractal/2;z<=i-BarsInFractal/2+BarsInFractal;z++){a_Volume[0]+=Volume[z];} // объем
               for (z=i-BarsInFractal/2;z<=i-BarsInFractal/2+BarsInFractal;z++){a_MFI[0]+=High[z]-Low[z];}
               a_MFI[0]=a_MFI[0]/a_Volume[0];               
               // пошли искать фрактал на вниз по истории
               j=i+1;
               while (a_Fractal[1]==0 && j<Bars)
                  {
                     if (High[j]==High[iHighest(Symbol(),0,MODE_HIGH,BarsInFractal,j-BarsInFractal/2)]) {break;} // нашли но не тот (тоже вверх)
                     if (Low[j]==Low[iLowest(Symbol(),0,MODE_LOW,BarsInFractal,j-BarsInFractal/2)]) //-- Нашли фрактал  вниз
                        {
                           a_Fractal[1]=Low[j];
                           for (z=j-BarsInFractal/2;z<=j-BarsInFractal/2+BarsInFractal;z++){a_Volume[1]+=Volume[z];} // объем
                           for (z=j-BarsInFractal/2;z<=j-BarsInFractal/2+BarsInFractal;z++){a_MFI[1]+=High[z]-Low[z];}
                           a_MFI[1]=a_MFI[1]/a_Volume[1];                              

                           if (a_Volume[0]>a_Volume[1]*Percent/100 && a_MFI[0]<a_MFI[1]){ExtRedBuffer[i]=High[i]+Pips*Point;break;}       // имеем приседающий фрактал (MFI - объем +)
                           if (a_Volume[0]>a_Volume[1]*Percent/100 && a_MFI[0]>a_MFI[1]){ExtLimeBuffer[i]=High[i]+Pips*Point;break;}      // имеем зеленый фрактал (MFI + объем +)
                           if (a_Volume[0]*Percent/100<a_Volume[1] && a_MFI[0]>a_MFI[1]){ExtBlueBuffer[i]=High[i]+Pips*Point;break;}      // имеем фальшивый фрактал (MFI + объем -)
                           if (a_Volume[0]*Percent/100<a_Volume[1] && a_MFI[0]<a_MFI[1]){ExtSaddleBrownBuffer[i]=High[i]+Pips*Point;break;}    // имеем увядающий фрактал (MFI - объем -)
                        }                          
                        j++;                                         
                  }
            }
         //--- нижние фракталы
         ArrayInitialize(a_Fractal,0);
         ArrayInitialize(a_MFI,0);
         ArrayInitialize(a_Volume,0);
         if (Low[i]==Low[iLowest(Symbol(),0,MODE_LOW,BarsInFractal,i-BarsInFractal/2)]) // на i баре есть фрактал вниз
            {
               a_Fractal[0]=Low[i];   // цена на фрактале               
               for (z=i-BarsInFractal/2;z<=i-BarsInFractal/2+BarsInFractal;z++){a_Volume[0]+=Volume[z];} // объем
               for (z=i-BarsInFractal/2;z<=i-BarsInFractal/2+BarsInFractal;z++){a_MFI[0]+=High[z]-Low[z];}
               a_MFI[0]=a_MFI[0]/a_Volume[0];   
               // пошли искать фрактал на вверх по истории
               j=i+1;
               while (a_Fractal[1]==0 && j<Bars)
                  {
                     if (Low[j]==Low[iLowest(Symbol(),0,MODE_LOW,BarsInFractal,j-BarsInFractal/2)]) {break;}
                     if (High[j]==High[iHighest(Symbol(),0,MODE_HIGH,BarsInFractal,j-BarsInFractal/2)]) //-- Нашли фрактал  вверх
                        {
                           a_Fractal[1]=High[j];
                           for (z=j-BarsInFractal/2;z<=j-BarsInFractal/2+BarsInFractal;z++){a_Volume[1]+=Volume[z];} // объем
                           for (z=j-BarsInFractal/2;z<=j-BarsInFractal/2+BarsInFractal;z++){a_MFI[1]+=High[z]-Low[z];}
                           a_MFI[1]=a_MFI[1]/a_Volume[1];                              
                           if (a_Volume[0]>a_Volume[1]*Percent/100 && a_MFI[0]<a_MFI[1]){ExtRedBuffer[i]=Low[i]-Pips*Point;break;}           // имеем приседающий фрактал (MFI - объем +)
                           if (a_Volume[0]>a_Volume[1]*Percent/100 && a_MFI[0]>a_MFI[1]){ExtLimeBuffer[i]=Low[i]-Pips*Point;break;}          // имеем зеленый фрактал (MFI + объем +)
                           if (a_Volume[0]*Percent/100<a_Volume[1] && a_MFI[0]>a_MFI[1]){ExtBlueBuffer[i]=Low[i]-Pips*Point;break;}          // имеем фальшивый фрактал (MFI + объем -)
                           if (a_Volume[0]*Percent/100<a_Volume[1] && a_MFI[0]<a_MFI[1]){ExtSaddleBrownBuffer[i]=Low[i]-Pips*Point;break;}   // имеем увядающий фрактал (MFI - объем -)
                        }
                        j++;                                         
                  }
            }
      }
   
   /// отрисовка линий
    double _Price[3,2];
    int  _Time[3,2];
    ArrayInitialize(_Price,-1);
    ArrayInitialize(_Time,-1);
    int up=0,down=0;
    for(i=BarsInFractal/2; i<=ShiftBars; i++)
      {
      //up
      //   double  iLips=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORLIPS, i);
      //   double  iTeeth=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORTEETH, i);
      //   double  iJaw=iAlligator(NULL, 0, 13, 8, 8, 5, 5, 3, MODE_SMMA, PRICE_MEDIAN, MODE_GATORJAW, i);                                                    
      // по зеленым
         if (FractalLines==0)
            {
               if (ExtLimeBuffer[i]!=2147483647 && High[i]<=ExtLimeBuffer[i] && up<=2) 
                 // && iFractals(NULL,0,MODE_UPPER,i)>iLips && iFractals(NULL,0,MODE_UPPER,i)>iTeeth && iFractals(NULL,0,MODE_UPPER,i)>iJaw)
                  {
                     _Price[up,0]=ExtLimeBuffer[i];_Time[up,0]=iTime(NULL, 0, i);up++;
                  }
               if (ExtLimeBuffer[i]!=2147483647 &&  down<=2 && Low[i]>=ExtLimeBuffer[i])
                  //&& iFractals(NULL,0,MODE_LOWER,i)<iLips && iFractals(NULL,0,MODE_LOWER,i)<iTeeth && iFractals(NULL,0,MODE_LOWER,i)<iJaw)
                  {
                     _Price[down,1]=ExtLimeBuffer[i];_Time[down,1]=iTime(NULL, 0, i);down++;         
                  } 
            }
        // по приседающим                                                      
         if (FractalLines==1)
            {
               if (ExtRedBuffer[i]!=2147483647 &&  up<=2 && High[i]<=ExtRedBuffer[i]) 
                  //&& iFractals(NULL,0,MODE_UPPER,i)>iLips && iFractals(NULL,0,MODE_UPPER,i)>iTeeth && iFractals(NULL,0,MODE_UPPER,i)>iJaw)
                  {
                     _Price[up,0]=ExtRedBuffer[i];_Time[up,0]=iTime(NULL, 0, i);up++;
                  }
               if (ExtRedBuffer[i]!=2147483647 &&  down<=2 && Low[i]>=ExtRedBuffer[i])
                  //&& iFractals(NULL,0,MODE_LOWER,i)<iLips && iFractals(NULL,0,MODE_LOWER,i)<iTeeth && iFractals(NULL,0,MODE_LOWER,i)<iJaw)
                  {
                     _Price[down,1]=ExtRedBuffer[i];_Time[down,1]=iTime(NULL, 0, i);down++;         
                  } 
            }
         // по фальшивым   
         if (FractalLines==2)
            {
               if (ExtSaddleBrownBuffer[i]!=2147483647  && up<=2 && High[i]<=ExtSaddleBrownBuffer[i]) 
                  //&& iFractals(NULL,0,MODE_UPPER,i)>iLips && iFractals(NULL,0,MODE_UPPER,i)>iTeeth && iFractals(NULL,0,MODE_UPPER,i)>iJaw)
                  {
                     _Price[up,0]=ExtSaddleBrownBuffer[i];_Time[up,0]=iTime(NULL, 0, i);up++;
                  }
               if (ExtSaddleBrownBuffer[i]!=2147483647  && down<=2 && Low[i]>=ExtSaddleBrownBuffer[i])
                  //&& iFractals(NULL,0,MODE_LOWER,i)<iLips && iFractals(NULL,0,MODE_LOWER,i)<iTeeth && iFractals(NULL,0,MODE_LOWER,i)<iJaw)
                  {
                     _Price[down,1]=ExtSaddleBrownBuffer[i];_Time[down,1]=iTime(NULL, 0, i);down++;         
                  } 
            }
         // по увядающим 
         if (FractalLines==3)
            {
               if (ExtBlueBuffer[i]!=2147483647 && up<=2 && High[i]<=ExtBlueBuffer[i]) 
                  //&& iFractals(NULL,0,MODE_UPPER,i)>iLips && iFractals(NULL,0,MODE_UPPER,i)>iTeeth && iFractals(NULL,0,MODE_UPPER,i)>iJaw)
                  {
                     _Price[up,0]=ExtBlueBuffer[i];_Time[up,0]=iTime(NULL, 0, i);up++;
                  }
               if (ExtBlueBuffer[i]!=2147483647 && down<=2 && Low[i]>=ExtBlueBuffer[i])
                  //&& iFractals(NULL,0,MODE_LOWER,i)<iLips && iFractals(NULL,0,MODE_LOWER,i)<iTeeth && iFractals(NULL,0,MODE_LOWER,i)<iJaw)
                  {
                     _Price[down,1]=ExtBlueBuffer[i];_Time[down,1]=iTime(NULL, 0, i);down++;         
                  } 
            }                                   
      }   
   ObjectMove("Up",1,_Time[0,0],_Price[0,0]);
   ObjectMove("Up",0,_Time[1,0],_Price[1,0]);
    
   ObjectMove("Down",1,_Time[0,1],_Price[0,1]);
   ObjectMove("Down",0,_Time[1,1],_Price[1,1]);
   if (UseOldLine)
      {
         ObjectMove("Up_Prev",1,_Time[1,0],_Price[1,0]);
         ObjectMove("Up_Prev",0,_Time[2,0],_Price[2,0]);
    
         ObjectMove("Down_Prev",1,_Time[1,1],_Price[1,1]);
         ObjectMove("Down_Prev",0,_Time[2,1],_Price[2,1]);         
      }
   return(0);
  }
//+------------------------------------------------------------------+



