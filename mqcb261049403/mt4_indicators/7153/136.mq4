//+------------------------------------------------------------------+
//|                                        maloma 4 vicont 1-2-3.mq4 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2006, maloma."
#property  indicator_chart_window
//----
extern double level_1=1.2971;//1.2937;//1.2937;
extern double level_2=1.2694;//1.2725;//1.2630;
extern double level_3=1.2978;//1.2874;//1.2829;
/*
extern double level_1=1.2764;//1.2483;//1.2937;
extern double level_2=1.2668;//1.2641;//1.2630;
extern double level_3=1.2714;//1.2524;//1.2829;
*/
extern bool Show_etalon=true;
extern bool Show_target=true;
extern bool Show_true=true;
//----
double level_4=0; double level_5=0; double level_6=0; double level_t=0;
double etalon_4=0; double etalon_5=0; double etalon_6=0;
double true_4=0; double true_5=0; double true_6=0;
int index_1=0; int index_2=0; int index_3=0; int index_4=0; int index_5=0; int index_6=0;
int p2d=0; int p3d=0;
bool get_4=false; bool get_5=false; bool get_6=false;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int init()
  {
   int i=0;
   if (level_3>level_2 && level_1>level_2) {p3d=1; p2d=-1;}
   if (level_3<level_2 && level_1<level_2) {p3d=-1; p2d=1;}
   if (p3d==1)
     {
      while(index_3==0 && i<Bars)
        {
         if (High[i]==level_3) index_3=Time[i];
        i++;}
      while(index_2==0 && i<Bars)
        {
         if (Low[i]==level_2) index_2=Time[i];
        i++;}
        while(index_1==0 && i<Bars){
         if (High[i]==level_1) index_1=Time[i];
        i++;}
     } else
      if (p3d==-1)
        {
           while(index_3==0 && i<Bars){
            if (Low[i]==level_3) index_3=Time[i];
           i++;}
         while(index_2==0 && i<Bars)
           {
            if (High[i]==level_2) index_2=Time[i];
           i++;}
         while(index_1==0 && i<Bars)
           {
            if (Low[i]==level_1) index_1=Time[i];
           i++;}
        }
   CreateText("Point_3","3",index_3,level_3+50*Point*p3d,FireBrick);
   CreateText("Point_2","2",index_2,level_2+50*Point*p2d,FireBrick);
   CreateText("Point_1","1",index_1,level_1+50*Point*p3d,FireBrick);
   //----
   etalon_4=(level_3-(level_3-level_2)*1.62);
   etalon_5=((level_3-(level_3-(level_3-(level_3-level_2)*1.62))/2)-(level_2-(level_3-(level_3-(level_3-(level_3-level_2)*1.62))/2)));
   etalon_6=(((level_3-(level_3-level_2)*1.62)-((level_3-(level_3-level_2)*1.62)-((level_3-(level_3-(level_3-(level_3-level_2)*1.62))/2)-(level_2-(level_3-(level_3-(level_3-(level_3-level_2)*1.62))/2))))/2)-(level_1-((level_3-(level_3-level_2)*1.62)-((level_3-(level_3-level_2)*1.62)-((level_3-(level_3-(level_3-(level_3-level_2)*1.62))/2)-(level_2-(level_3-(level_3-(level_3-(level_3-level_2)*1.62))/2))))/2)));
   //----
   if (Show_etalon) CreateObj("Etalon_4",OBJ_HLINE,Time[0],etalon_4,SaddleBrown,STYLE_DASHDOT);
   if (Show_etalon) CreateObj("Etalon_5",OBJ_HLINE,Time[0],etalon_5,Teal,STYLE_DASHDOT);
   if (Show_etalon) CreateObj("Etalon_6",OBJ_HLINE,Time[0],etalon_6,Purple,STYLE_DASHDOT);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int deinit()
  {
   if (ObjectFind("Point_1")==0) ObjectDelete("Point_1");
   if (ObjectFind("Point_2")==0) ObjectDelete("Point_2");
   if (ObjectFind("Point_3")==0) ObjectDelete("Point_3");
   if (ObjectFind("Point_4")==0) ObjectDelete("Point_4");
   if (ObjectFind("Point_5")==0) ObjectDelete("Point_5");
   if (ObjectFind("Point_6")==0) ObjectDelete("Point_6");
   if (ObjectFind("Etalon_4")==0) ObjectDelete("Etalon_4");
   if (ObjectFind("Etalon_5")==0) ObjectDelete("Etalon_5");
   if (ObjectFind("Etalon_6")==0) ObjectDelete("Etalon_6");
   if (ObjectFind("Level_4")==0) ObjectDelete("Level_4");
   if (ObjectFind("Level_5")==0) ObjectDelete("Level_5");
   if (ObjectFind("Level_6")==0) ObjectDelete("Level_6");
   if (ObjectFind("True_4")==0) ObjectDelete("True_4");
   if (ObjectFind("True_5")==0) ObjectDelete("True_5");
   if (ObjectFind("True_6")==0) ObjectDelete("True_6");
   Comment ("");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  void find_4(int index, int dir)
  {
   int tBar=iBarShift(Symbol(),0,index,false)-1;
   if (tBar<0) return(0);
   level_4=(level_3-(level_3-level_2)*1.62);
   if (Show_target) CreateObj("Level_4",OBJ_HLINE,Time[0],level_4,Gold,STYLE_DOT);
   for(int cb=tBar;cb>=0;cb--)
     {
      if (dir==-1)
        {
         if (true_4==0) double level=level_4; else level=true_4;
         if (Low[cb]<=level && get_4==false)
           {
            true_4=Low[cb];
            index_4=Time[cb];
            if (Show_true) CreateObj("True_4",OBJ_HLINE,Time[0],true_4,Gold,STYLE_DASH);
            CreateText("Point_4","4",index_4,true_4+50*Point*p2d,Gold);
            level_5=(level_3-(level_3-true_4)/2)-(level_2-(level_3-(level_3-true_4)/2));
            if (Show_target) CreateObj("Level_5",OBJ_HLINE,Time[0],level_5,Aqua,STYLE_DOT);
           }
         if (true_4!=0 && cb>0)
            if (level_5<=High[cb-1])
              {
               get_4=true;
               find_5(index_4,p3d);
              }
        }
      if (dir==1)
        {
         if (true_4==0) level=level_4; else level=true_4;
         if (High[cb]>=level && get_4==false)
           {
            true_4=High[cb];
            index_4=Time[cb];
            if (Show_true) CreateObj("True_4",OBJ_HLINE,Time[0],true_4,Gold,STYLE_DASH);
            CreateText("Point_4","4",index_4,true_4+50*Point*p2d,Gold);
            level_5=(level_3-(level_3-true_4)/2)-(level_2-(level_3-(level_3-true_4)/2));
            if (Show_target) CreateObj("Level_5",OBJ_HLINE,Time[0],level_5,Aqua,STYLE_DOT);
           }
         if (true_4!=0 && cb>0)
            if (level_5>=Low[cb-1])
              {
               get_4=true;
               find_5(index_4,p3d);
              }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  void find_5(int index, int dir)
  {
   int tBar=iBarShift(Symbol(),0,index,false)-1;
   if (tBar<0) return(0);
   for(int cb=tBar;cb>=0;cb--)
     {
        if (dir==-1) {
         if (true_5==0) double level=level_5; else level=true_5;
         if (Low[cb]<=level && get_5==false)
           {
            true_5=Low[cb];
            index_5=Time[cb];
            if (Show_true) CreateObj("True_5",OBJ_HLINE,Time[0],true_5,Aqua,STYLE_DASH);
            CreateText("Point_5","5",index_5,true_5+50*Point*p3d,Aqua);
            level_6=(true_4-(true_4-true_5)/2)-(level_1-(true_4-(true_4-true_5)/2));
            if (Show_target) CreateObj("Level_6",OBJ_HLINE,Time[0],level_6,Magenta,STYLE_DOT);
           }
         if (true_5!=0 && cb>0)
            if (level_6<=High[cb-1])
              {
               get_5=true;
               find_6(index_5,p2d);
              }
        }
      if (dir==1)
        {
         if (true_5==0) level=level_5; else level=true_5;
         if (High[cb]>=level && get_5==false)
           {
            true_5=High[cb];
            index_5=Time[cb];
            if (Show_true) CreateObj("True_5",OBJ_HLINE,Time[0],true_5,Aqua,STYLE_DASH);
            CreateText("Point_5","5",index_5,true_5+50*Point*p3d,Aqua);
            level_6=(true_4-(true_4-true_5)/2)-(level_1-(true_4-(true_4-true_5)/2));
            if (Show_target) CreateObj("Level_6",OBJ_HLINE,Time[0],level_6,Magenta,STYLE_DOT);
           }
         if (true_5!=0 && cb>0)
            if (level_6>=Low[cb-1])
              {
               get_5=true;
               find_6(index_5,p2d);
              }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  void find_6(int index, int dir)
  {
   int tBar=iBarShift(Symbol(),0,index,false)-1;
   if (tBar<0) return(0);
   for(int cb=tBar;cb>=0;cb--)
     {
      if (dir==-1)
        {
         if (true_6==0) double level=level_6; else level=true_6;
         if (Low[cb]<=level && get_6==false)
           {
            true_6=Low[cb];
            index_6=Time[cb];
            if (Show_true) CreateObj("True_6",OBJ_HLINE,Time[0],true_6,Magenta,STYLE_DASH);
            CreateText("Point_6","6",index_6,true_6+50*Point*p2d,Magenta);
           }
        }
      if (dir==1)
        {
         if (true_6==0) level=level_6; else level=true_6;
         if (High[cb]>=level && get_6==false)
           {
            true_6=High[cb];
            index_6=Time[cb];
            if (Show_true) CreateObj("True_6",OBJ_HLINE,Time[0],true_6,Magenta,STYLE_DASH);
            CreateText("Point_6","6",index_6,true_6+50*Point*p2d,Magenta);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  void CreateText(string name, string text, int index, double level, color col)
  {
   if (ObjectFind(name)==-1)
     {
      ObjectCreate (name,OBJ_TEXT,0,index,level,0,0,0,0);
      ObjectSetText(name, text, 14, "Times New Roman", col);
     }
   else
     {
      ObjectMove(name, 0, index,level);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  void CreateObj(string name, int type, int index, double level, color col, int style)
  {
   if (ObjectFind(name)==-1)
     {
      ObjectCreate (name,type,0,index,level,0,0,0,0);
      ObjectSet    (name, OBJPROP_COLOR, col);
      ObjectSet    (name, OBJPROP_STYLE, style);
     }
   else
     {
      ObjectMove(name, 0, index,level);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
  int start()
  {
   int i=0; int j=0; int k=0;
   find_4(index_3,p2d);
   Comment("1: уровень=",level_1,"; дата=",TimeToStr(index_1,TIME_DATE),"\n",
           "2: уровень=",level_2,"; дата=",TimeToStr(index_2,TIME_DATE),"\n",
           "3: уровень=",level_3,"; дата=",TimeToStr(index_3,TIME_DATE),"\n",
           "4: эталон=",etalon_4,"; целевой=",level_4,"; достигли=",true_4,"; дата=",TimeToStr(index_4,TIME_DATE),"\n",
           "5: эталон=",etalon_5,"; целевой=",level_5,"; достигли=",true_5,"; дата=",TimeToStr(index_5,TIME_DATE),"\n",
           "6: эталон=",etalon_6,"; целевой=",level_6,"; достигли=",true_6,"; дата=",TimeToStr(index_6,TIME_DATE));
   return(0);
  }
//+------------------------------------------------------------------+