//======================================================================================================
//    LibreConver Function1_0 v1.107 MQL5/4
//    Основные функции алгоритма
//    Librecoin (c)2014-2017     
//======================================================================================================
#property strict
//======================================================================================================
//    MAIN FUNCTIONS
//------------------------------------------------------------------------------------------------------
//
//======================================================================================================
//    FileConverter4() - investing                                  
//======================================================================================================
bool FileConverter4(int InFileHandle,int OutFileHandle){
string
   DatesStr,
   OutStrBuff,
   OutStrBuff2,
   InpStrBuff2,
   InpStrBuff;
int
   nEnd;   
//-----
   {if(FileIsEnding(InFileHandle))//Файл кончился - сваливаем
   {
      return(false);
   }}//if(FileIsEnding(InFileHandle))
//2.  Обработка табличной части
   bool TableFounded=false;//Признак обнаружения табличной части
   InpStrBuff2="";
   {while(!FileIsEnding(InFileHandle))
   {
      ResetLastError(); 
      //Чтение строки
      InpStrBuff=InpStrBuff2+FileReadString(InFileHandle);
      bool  iResult=false;
      {if(!TableFounded)//Если табличная часть не найдена ранее
      {
         {if((StringFind(InpStrBuff,"<tbody pagestartat=")>=0))//Табличная часть обнаружена - выпиливаем теги из строки
         {
            InpStrBuff=StringSubstr(InpStrBuff,StringFind(InpStrBuff,"<tbody pagestartat="));
            iResult=TagDelete(InpStrBuff,"<tbody pagestartat=","\">");//Вырезаем от [<tbody pagestartat=] до [">] включительно
            TableFounded=true;//Признак обнаружения табличной части
         }else{//Табличная часть вновь не обнаружена - тело цикла с начала
            InpStrBuff="";
            InpStrBuff2="";
            continue;
         }}//if(TagContent(InpStrBuff,"id=\"theDay","/td>",iTheDay))
      }}//if(!TableFounded)
      {if(InpStrBuff==""){continue;}}//Если строка пустая - тело цикла с начала
      //Формируем наполнение тега <tr>...</tr>
      //Пытаемся наполнить строку тегом Строки Календаря
      int nBegin=StringFind(InpStrBuff,"<tr",0);//Проверяем наличие события в строке
      //int nBegin=StringFind(InpStrBuff,"<tr id=\"eventRowId_",0);//Проверяем наличие события в оставшейся строке
      {if(nBegin>=0)//Если событие обнаружено
      {
         //Print("5. InpStrBuff=",InpStrBuff);//Вывод для контроля
         //Нормализация слева
         {if(nBegin>0)
         {
            InpStrBuff=StringSubstr(InpStrBuff,nBegin);//Подрезка на всякий, хотя раньше уже было подрезано
         }}//if(nBegin>0)
         nEnd=StringFind(InpStrBuff,"</tr>",0);//Поиск концевого тега события
         {while((!FileIsEnding(InFileHandle))&&(nEnd<=0))//Прокрутка (подчитывание) файла до прочтения концевого тега
         {
            ResetLastError(); 
            InpStrBuff2=FileReadString(InFileHandle);
            InpStrBuff=InpStrBuff+InpStrBuff2;
            nEnd=StringFind(InpStrBuff,"</tr>",0);
         }}//while((!FileIsEnding(InFileHandle))&&(nEnd<=0))
         //Точка контроля заполнения строки
         //Print("6. InpStrBuff2=",InpStrBuff);//Вывод для контроля
         {if(FileIsEnding(InFileHandle)){return(false);}}//Файл кончился - сваливаем
         //Print(OutStrBuff2);//Вывод для контроля
         //Готовим для обработки кусок строки с тегом Строки Календаря
         OutStrBuff2=StringSubstr(InpStrBuff,0,nEnd+StringLen("</tr>"));//Голову строки с первым событием на анализ
         //Тут организован разбор строки и запись в файл
         {if(StringConverter(4,OutStrBuff2,OutStrBuff2))//Пропускаем строку с событием через конвертор с кодом 4 (Investing)
         {
            ResetLastError();
            //----- Запись строки 
            FileWriteString(OutFileHandle,OutStrBuff2+"\n");
            {if(PrnFileWrite){Print(OutStrBuff2);}}//Вывод для контроля
         }}//if(StringConverter(5,OutStrBuff2,OutStrBuff2))
            //InpStrBuff="";
         InpStrBuff2=StringSubstr(InpStrBuff,nEnd+StringLen("</tr>"));//Хвост строки - на повторное использование
         {if(InpStrBuff2==""){continue;}}//Если строка пустая - тело цикла с начала
      }}//if(nBegin>=0)
   }}//while((!FileIsEnding(InFileHandle))&&(!YearFounded))
   return(true);
}//FileConverter4()
//
//======================================================================================================
//    TagContent()   - Определяет содержимое тега
//    Вход
//       sInpStr     -  Входная строка для разбора (ссылка)    
//       sTagOpen    -  Открывающий тег
//       sTagClose   -  Закрывающий тег
//    Выход:
//       bool        - true/false есть/нет контент в теге
//       iTagContent - содержимое тега, результат (ссылка) 
//======================================================================================================
bool TagContent(const string &sInpStr,string sTagOpen,string sTagClose,string &sTagContent){
bool 
   iResult=false;
int 
   nTagOpenBegin  =  StringFind(sInpStr,sTagOpen,0),
   nTagOpenLen    =  StringLen(sTagOpen),
   nTagOpenEnd    =  nTagOpenBegin+nTagOpenLen,
   nTagCloseBegin =  StringFind(sInpStr,sTagClose,nTagOpenEnd),
   nTagCloseLen   =  StringLen(sTagClose),
   nTagCloseEnd   =  nTagCloseBegin+nTagCloseLen;
//-----
   {if((nTagCloseBegin-nTagOpenEnd>=1)&&(nTagOpenBegin>=0)&&(nTagCloseBegin>=0))
   {
      //Есть контент
      sTagContent=StringSubstr(sInpStr,nTagOpenEnd,nTagCloseBegin-nTagOpenEnd);
      iResult=true;
   }else{
      //Контент пуст
      sTagContent="";
      iResult=false;
   }}//if(nTagCloseBegin-nTagOpenEnd>=1)
   return(iResult);
}//TagContent()
//
//======================================================================================================
//    TagDelete()   - Удаляет тело элемента, огрниченного тэгами вместе с тэгами
//    Вход
//       sInpStr     -  Входная строка для разбора (ссылка)    
//       sTagOpen    -  Открывающий тег
//       sTagClose   -  Закрывающий тег
//    Выход:
//       bool        - true/false есть/нет остаток строки
//======================================================================================================
bool TagDelete(string &sInpStr,string sTagOpen,string sTagClose){
bool 
   iResult        =  false;
int 
   nTagOpenBegin  =  StringFind(sInpStr,sTagOpen),
   nTagOpenLen    =  StringLen(sTagOpen),
   nTagOpenEnd    =  nTagOpenBegin+nTagOpenLen,
   nTagCloseBegin =  StringFind(sInpStr,sTagClose,nTagOpenEnd),
   nTagCloseLen   =  StringLen(sTagClose),
   nTagCloseEnd   =  nTagCloseBegin+nTagCloseLen;
//-----
string
   iInpStr1=((nTagOpenBegin>=1)?(StringSubstr(sInpStr,0,nTagOpenBegin)):("")),//Часть строки до тэга открытия
   iInpStr2=((nTagCloseEnd<=StringLen(sInpStr)-1)?(StringSubstr(sInpStr,nTagCloseEnd)):(""));//Часть строки после тэга закрытия
   sInpStr=iInpStr1+iInpStr2;//Склейка частей строки до начального тэга удаленного элемента и после тэга конца
   {if(sInpStr!="")
   {
      //Есть остаток
      iResult=true;
   }else{
      //Остаток пуст
      iResult=false;
   }}//if(sInpStr!="")
   return(iResult);
}//TagDelete()
