//+------------------------------------------------------------------+
//|                                                      shablon.mq4 |
//|                                             Viatcheslav Suvorov  |
//+------------------------------------------------------------------+
#property copyright "Viatcheslav Suvorov"
#property show_inputs
#include <WinUser32.mqh>

#import "IdleLib.dll"
int GetLastKeyWP();
int GetLastMouseWP();
int IdleLibInit();
int IdleLibUnInit();
string GetActiveWndName();
#import

int start()
  {
        IdleLibInit();//инициализируем Dll для перехвата событий   
         bool NeedLoop=true;  
         while(NeedLoop){           
           int lastkey=GetLastKeyWP();//Опрашиваем код посл. клавиши
           int lastmouse=GetLastMouseWP();//Опрашиваем код мыши           
           string lastwnd=GetActiveWndName();//Имя окна Metatrader где произошло событие
           if ((lastkey!=0) && (lastwnd!="")) {             
             Print("Код нажатой клавиши=",lastkey," из окна ",lastwnd);
           }  
           if ((lastmouse!=0) && (lastwnd!="") && (lastmouse!=512)) {//отражаем все события кроме движения мыши             
             Print("Код мыши=",lastmouse," из окна ",lastwnd);
           }                                    
           Sleep(100);
         }//while                
   return(0);
  }

void deinit()
  {
   IdleLibUnInit();
  }

