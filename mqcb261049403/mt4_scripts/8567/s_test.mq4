//+------------------------------------------------------------------+
//|                                                       s_Test.mq4 |
//|                                                                * |
//|                                                                * |
//+------------------------------------------------------------------+
#property copyright "Integer"
#property link      "for-good-letters@yandex.ru"

//+------------------------------------------------------------------+
//| script program start function                                    |
//+------------------------------------------------------------------+
int start()
  {
//----

   double f=0;
   double s=0.03;
   while(!IsStopped()){
      int y=MathAbs(MathSin(f))*100;
      f+=s;
         if(y<12){
            fObjLabel("Smile",25,y,StringSetChar("",0,75),2,Red,50,0,"WingDings",false);
         }
         else{
            fObjLabel("Smile",25,y,StringSetChar("",0,74),2,Red,50,0,"WingDings",false);         
         }
      WindowRedraw();
      Sleep(1);
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+
int deinit(){
   ObjectDelete("Smile");
   WindowRedraw();
}
void fObjLabel(
   string aObjectName,     // 1 имя
   int aX,                 // 2 х
   int aY,                 // 3 у
   string aText,           // 4 текст
   int aCorner=0,          // 5 угол   0  1
                           //          2  3
   color aColor=Red,       // 6 цвет
   int aFontSize=8,        // 7 размер шрифта
   int aWindowNumber=0,    // 8 окно
   string aFont="Arial",   // 9 шрифт
   bool aBack=false        // 10 фон
   ){     
      if(ObjectFind(aObjectName)!=aWindowNumber){
         ObjectCreate(aObjectName,OBJ_LABEL,aWindowNumber,0,0);
      }      
   ObjectSet(aObjectName,OBJPROP_XDISTANCE,aX);
   ObjectSet(aObjectName,OBJPROP_YDISTANCE,aY);   
   ObjectSetText(aObjectName,aText,aFontSize,aFont,aColor);
   ObjectSet(aObjectName,OBJPROP_BACK,aBack);
   ObjectSet(aObjectName,OBJPROP_CORNER,aCorner);   
}

