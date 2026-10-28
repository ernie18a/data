//////////////////////////////////////////////////////////////////////////////////////////////////////
//
// клас парсинга DJ
//
//  Файл должен быть в каталоге MQL5\files
//  текстовый файл с именем на каждый день может быть свой файл - если файла нет нет и уровней
//  версия пока русская
//
//    DJ2009.09.28 
//    DJ2009.09.27 
//
//////////////////////////////////////////////////////////////////////////////////////////////////////
class Parsing
  {
private:  int beg,end;

   string            filename;
   int               handle;
   int               first;
   string            str;
   int               err;
   int               len;
   int               i;

public:

   string            efs[14];
   int               efl[14];

   double            level[9+1][7+1];
   string            levelS[9+1][7+1];

   void              Parsing()
     {
      efs[0 ]="3-е сопротивление";
      efl[0 ]= StringLen(efs[0] );

      efs[1 ]="2-е сопротивление";
      efl[1 ]= StringLen(efs[1] );
      efs[2 ]="1-е сопротивление";
      efl[2 ]= StringLen(efs[2] );
      efs[3 ]="Точка разворота*";
      efl[3 ]= StringLen(efs[3] );
      efs[4 ]="1-я поддержка";
      efl[4 ]= StringLen(efs[4] );
      efs[5 ]="2-я поддержка";
      efl[5 ]= StringLen(efs[5] );
      efs[6 ]="3-я поддержка";
      efl[6 ]= StringLen(efs[6] );


      efs[7 ]="3-е сопротивление";
      efl[7 ]= StringLen(efs[0] );
      efs[8 ]="2-е сопротивление";
      efl[8 ]= StringLen(efs[1] );
      efs[9 ]="1-е сопротивление";
      efl[9 ]= StringLen(efs[2] );
      efs[10]="Точка разворота*";
      efl[10]= StringLen(efs[3] );
      efs[11]="1-я поддержка";
      efl[11]= StringLen(efs[4] );
      efs[12]="2-я поддержка";
      efl[12]= StringLen(efs[5] );
      efs[13]="3-я поддержка";
      efl[13]= StringLen(efs[6] );
     };
   bool              begin(datetime td);
private:
   void              Parsing::begdat(datetime dt);
   string            ReadFileStr(int handle);
   int               OpenFileDowJones(string filename);
   bool              FileFind(datetime td);
   bool              IsDigit(int cod);
   void              CreateLevelScreen(datetime dt);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Parsing::begdat(datetime dt)
  {

   filename="DJ"+TimeToString(dt,TIME_DATE);
   handle=OpenFileDowJones(filename);
   if(handle==-1)
     {
      printf("не могу открыть  %s ",filename);
      return;
     }
   first=0;

   int num=0;
   string pars1;
   string levelstr;

   int countDigitStr=0;
   int contdigit=0;
//int countSym = 1;

   int iCur = 1;
   int iPos = 1;
   int  levelCur=1;
   while(FileIsEnding(handle)==false) // iss временно ибо как ловить конец  файла совершенно непонятно
     {
      str=ReadFileStr(handle);
      if(num==14)
         break;
      if(StringFind(str,efs[num],0)>=0)
        {
         pars1=StringSubstr(str,efl[num],StringLen(str)-efl[num]); // выделим уровни
         len=StringLen(pars1);
         for(i=0;i<len;i++)
           {
            if(IsDigit(StringGetCharacter(pars1,i))==true)
              {
               if(contdigit==0)
                  contdigit++;
               levelstr=levelstr+StringSubstr(pars1,i,1);
              }
            else
              {
               if(contdigit==0)
                  continue;
               contdigit=0;

               level[iCur][levelCur]=StringToDouble(levelstr); // вытащили строку и в массив ее
               levelS[iCur][levelCur]=levelstr;
               iCur++;
               levelstr="";
               countDigitStr++; // считаем

               if(countDigitStr==4) // нашли цифры
                 {
                  iCur=iPos;
                  countDigitStr=0;
                  levelCur++; // ПО 7 уровней НА ПАРУ
                  num++; // номер для сравнения
                  if(num==7 || num==14)
                    {
                     levelCur=1;
                     iPos=5; // уходим на второй блок валют
                     iCur=iPos;
                    }
                  break;
                 }
              }
           }
        }
     }

   FileClose(handle);

   CreateLevelScreen(dt);

  }
//
// разложить сразу по всем парам
// eurusd usdjpy gbpusd usdchf
// eurgbp eurjpy eurchf audusd
//
void Parsing::CreateLevelScreen(datetime dt)
  {
   string sSymbol[9];
   sSymbol[1]="EURUSD";
   sSymbol[2]="USDJPY";
   sSymbol[3]="GBPUSD";
   sSymbol[4]="USDCHF";
   sSymbol[5]="EURGBP";
   sSymbol[6]="EURJPY";
   sSymbol[7]="EURCHF";
   sSymbol[8]="AUDUSD";

   string sLev[8];
   sLev[1]="R3";
   sLev[2]="R2";
   sLev[3]="R1";
   sLev[4]="P";
   sLev[5]="S1";
   sLev[6]="S2";
   sLev[7]="S3";

   string sss=Symbol();

   long IDChart=ChartWindowOnDropped(); // запомним
   sSymbol[0]=ChartSymbol(IDChart);

   long chart_id=ChartFirst();

   chart_id = IDChart ;
   int iC = 1;
//   for(int iC=1;iC<=8;iC++)
//     {
//      while( true  )
//        {
//         if(ChartSymbol(chart_id) == sSymbol[iC] )
//           {

            for(int iL=1;iL<=7;iL++)
              {
               if(ObjectFind(chart_id,sLev[iL]+TimeToString(dt,TIME_DATE))<0)
                 {
                  ObjectCreate(chart_id,sLev[iL]+TimeToString(dt,TIME_DATE)
                               ,OBJ_TREND,0,dt,level[iC][iL],dt+86400,level[iC][iL]);
                  ObjectSetInteger(chart_id,sLev[iL]+TimeToString(dt,TIME_DATE),OBJPROP_COLOR,DarkViolet);
                  ObjectSetString(chart_id,sLev[iL]+TimeToString(dt,TIME_DATE),OBJPROP_TEXT,sLev[iL]+" "+levelS[1][iL]);
                 } // if
              } // for


//           }// if 
//           chart_id = ChartNext(chart_id);
//           if ( chart_id == 0)
//              break;
//        }
//     }


//ChartSetSymbolPeriod(IDChart,sSymbol[0],PERIOD_M15);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Parsing::IsDigit(int cod) // 
  {
   if((cod>=48 && cod<=57) || cod==46) // 48 49 50 51 52 53 54 55 56 57 
      return(true);
   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string Parsing::ReadFileStr(int hamdle)
  {
   string str="";
   str=FileReadString(handle,-1);
   err=GetLastError();
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(err!=0 && FileIsEnding(handle) == true)
     {
      if(err !=0 )
         {
         printf(" >>  err %d ",err); // ошибка
         }
     }
   return(str);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int Parsing::OpenFileDowJones(string filename)
  {
   int handle=FileOpen(filename,FILE_TXT|FILE_ANSI|FILE_READ|FILE_SHARE_READ);
   return(handle);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Parsing::begin(datetime td)
  {

   while(td<=StringToTime(TimeToString(TimeCurrent(),TIME_DATE)))
     {
      if(FileFind(td)==true)
         begdat(td);
      td=td+86400;
     }

   return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Parsing::FileFind(datetime td)
  {
   string FileNameFind="DJ"+TimeToString(td,TIME_DATE)+".txt";
   string FileN;
   int found=FileFindFirst(FileNameFind,FileN);
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   if(found>=1)
     {
      FileClose(found);
      return(true);
     }
   return(false);
  }
/////////////////////////////////////////
