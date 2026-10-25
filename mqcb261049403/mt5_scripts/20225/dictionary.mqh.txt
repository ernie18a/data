//+------------------------------------------------------------------+
//|                                                  CDictionary.mqh |
//|                                 Copyright 2015, Vasiliy Sokolov. |
//|                                            https://forge.mql5.io |
//+------------------------------------------------------------------+
#property copyright "Copyright 2015, Vasiliy Sokolov."
#property link      "https://forge.mql5.io"
#property strict
#include <Object.mqh>
#include <Arrays\List.mqh>
//+------------------------------------------------------------------+
//| Контейнер для хранения элементов CObject                         |
//+------------------------------------------------------------------+
class KeyValuePair : public CObject
  {
private:
   string            m_string_key;    // Хранит строковый ключ.
   double            m_double_key;    // Хранит ключ с плавающей запятой.
   ulong             m_ulong_key;     // Хранит безнаковый целочисленный ключ.
   ulong             m_hash;
   bool              m_free_mode;     // Режим освобождения памяти объекта
public:
   CObject          *object;
   KeyValuePair     *next_kvp;
   KeyValuePair     *prev_kvp;
   template<typename T>
                     KeyValuePair(T key,ulong hash,CObject *obj);
                    ~KeyValuePair();
   template<typename T>
   bool              EqualKey(T key);
   template<typename T>
   void              GetKey(T &gkey);
   ulong             GetHash(){return m_hash;}
   void              FreeMode(bool free_mode){m_free_mode=free_mode;}
   bool              FreeMode(void){return m_free_mode;}
  };
//+------------------------------------------------------------------+
//| Конструктор по умолчанию.                                        |
//+------------------------------------------------------------------+
template<typename T>
void KeyValuePair::KeyValuePair(T key,ulong hash,CObject *obj)
  {
   m_hash=hash;
   string name=typename(key);
   if(name=="string")
      m_string_key=(string)key;
   else if(name=="double" || name=="float")
      m_double_key=(double)key;
   else
      m_ulong_key=(ulong)key;
   object=obj;
   m_free_mode=true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
template<typename T>
KeyValuePair::GetKey(T &gkey)
  {
   string name=typename(gkey);
   if(name=="string")
      gkey=(T)m_string_key;
   else if(name=="double" || name=="float")
      gkey=(T)m_double_key;
   else
      gkey=(T)m_ulong_key;
  }
//+------------------------------------------------------------------+
//| Диструктор.                                                      |
//+------------------------------------------------------------------+
KeyValuePair::~KeyValuePair()
  {
   if(m_free_mode)
      delete object;
  }
//+------------------------------------------------------------------+
//| Возвращает истину, если ключи равны.                             |
//+------------------------------------------------------------------+
template<typename T>
bool KeyValuePair::EqualKey(T key)
  {
   string name=typename(key);
   if(name=="string")
      return m_string_key == (string)key;
   if(name=="double" || name=="float")
      return m_double_key == (double)key;
   else
      return m_ulong_key == (ulong)key;
  }
//+------------------------------------------------------------------+
//| Ассоциативный массив или словарь, хранящий элементы в виде       |
//| <ключ - значение>. Где ключом может являться любой базовый тип,  |
//| а значением - объект типа CObject.                               |
//+------------------------------------------------------------------+
class CDictionary : public CObject
  {
private:
   int               m_array_size;
   int               m_total;
   bool              m_free_mode;
   bool              m_auto_free;
   int               m_index;
   ulong             m_hash;
   CList            *m_array[];
   union casting_struct
   {
      double d_value;
      ulong  l_value;
   }casting;
   KeyValuePair     *m_first_kvp;
   KeyValuePair     *m_current_kvp;
   KeyValuePair     *m_last_kvp;

   ulong             Adler32(string line);
   int               GetIndexByHash(ulong hash);
   template<typename T>
   ulong             GetHashByKey(T key);
   void              Resize();
   int               FindNextSimpleNumber(int number);
   int               FindNextLevel();
   void              Init(int capacity);
public:
                     CDictionary();
                     CDictionary(int capacity);
                    ~CDictionary();
   void              Compress(void);
   ///
   /// Returns the total number of items.
   ///
   int Total(void){return m_total;}
   /// Returns the element at key    
   template<typename T>
   CObject          *GetObjectByKey(T key);
   template<typename T>
   bool              AddObject(T key,CObject *value);
   template<typename T>
   bool              DeleteObjectByKey(T key);
   template<typename T>
   bool              ContainsKey(T key);
   template<typename T>
   void              GetCurrentKey(T &key);
   bool              DeleteCurrentNode(void);
   bool              FreeMode(void) { return(m_free_mode); }
   void              FreeMode(bool free_mode);
   void              AutoFreeMemory(bool autoFree){m_auto_free=autoFree;}
   void              Clear();

   CObject          *GetNextNode(void);
   CObject          *GetPrevNode(void);
   CObject          *GetCurrentNode(void);
   CObject          *GetFirstNode(void);
   CObject          *GetLastNode(void);

  };
//+------------------------------------------------------------------+
//| Конструктор по умолчанию.                                        |
//+------------------------------------------------------------------+
CDictionary::CDictionary()
  {
   Init(3);
   m_free_mode = true;
   m_auto_free=true;
  }
//+------------------------------------------------------------------+
//| Создает словарь, с заранее определенной емкостью capacity.       |
//+------------------------------------------------------------------+
CDictionary::CDictionary(int capacity)
  {
   if(capacity < 3)
      Init(3);
   else
      Init(capacity);
   m_free_mode = true;
   m_auto_free=true;
  }
//+------------------------------------------------------------------+
//| Диструктор.                                                      |
//+------------------------------------------------------------------+
CDictionary::~CDictionary()
  {
   Clear();
  }
//+------------------------------------------------------------------+
//| Режим устанавливает режим памяти для всех подузлов               |
//+------------------------------------------------------------------+  
void CDictionary::FreeMode(bool free_mode)
  {
   if(free_mode==m_free_mode)
      return;
   m_free_mode=free_mode;
   for(int i=0; i<ArraySize(m_array); i++)
     {
      CList *list=m_array[i];
      if(CheckPointer(list)==POINTER_INVALID)
         continue;
      for(KeyValuePair *kvp=list.GetFirstNode(); kvp!=NULL; kvp=list.GetNextNode())
         kvp.FreeMode(m_free_mode);
     }
  }
//+------------------------------------------------------------------+
//| Выполняет инициализацию словаря.                                 |
//+------------------------------------------------------------------+
void CDictionary::Init(int capacity)
  {
   m_array_size=ArrayResize(m_array,capacity);
   m_index= 0;
   m_hash = 0;
   m_total=0;
  }
//+------------------------------------------------------------------+
//| Находит следующий размер для словаря.                            |
//+------------------------------------------------------------------+
int CDictionary::FindNextLevel()
  {
   double value=4;
   for(int i=2; i<=31; i++)
     {
      value=MathPow(2.0,(double)i);
      if(value > m_total)return (int)value;
     }
   return (int)value;
  }
//+------------------------------------------------------------------+
//| Принимает строку и возвращает хэширующее 32 битное число,        |
//| характеризующее эту строку.                                      |
//+------------------------------------------------------------------+
ulong CDictionary::Adler32(string line)
  {
   ulong s1 = 1;
   ulong s2 = 0;
   uint buflength=StringLen(line);
   uchar char_array[];
   ArrayResize(char_array,buflength,0);
   StringToCharArray(line,char_array,0,-1,CP_ACP);
   for(uint n=0; n<buflength; n++)
     {
      s1 = (s1 + char_array[n]) % 65521;
      s2 = (s2 + s1)     % 65521;
     }
   return ((s2 << 16) + s1);
  }
//+------------------------------------------------------------------+
//| Рассчитывает хэш на основе переданного ключа. Ключом может быть  |
//| любой базовый MQL тип.
//+------------------------------------------------------------------+
template<typename T>
ulong CDictionary::GetHashByKey(T key)
  {
   ulong ukey = 0;
   string name=typename(key);
   if(name=="string")
      return Adler32((string)key);
   if(name=="double" || name=="float")
     {
      casting.d_value = (double)key;
      ukey=casting.l_value;
     }
   else
      ukey=(ulong)key;
   return ukey;
  }
//+------------------------------------------------------------------+
//| Возвращает ключ текущего элемента.                               |
//+------------------------------------------------------------------+
template<typename T>
void CDictionary::GetCurrentKey(T &key)
  {
   m_current_kvp.GetKey(key);
  }
//+------------------------------------------------------------------+
//| Возвращает индекс по ключу.                                      |
//+------------------------------------------------------------------+
int CDictionary::GetIndexByHash(ulong key)
  {
   return (int)(key%m_array_size);
  }
//+------------------------------------------------------------------+
//| Очищает словарь от всех значений.                                |
//+------------------------------------------------------------------+
void CDictionary::Clear(void)
  {
   int size=ArraySize(m_array);
   for(int i=0; i<size; i++)
     {
      if(CheckPointer(m_array[i])!=POINTER_INVALID)
        {
         m_array[i].FreeMode(true); // Элементы типа KeyValuePair удаляются всегда
         delete m_array[i];
        }
     }
   ArrayFree(m_array);
   if(m_auto_free)
      Init(3);
   else
      Init(size);
   m_first_kvp=m_last_kvp=m_current_kvp=NULL;
  }
//+------------------------------------------------------------------+
//| Переразмечает контейнер хранения данных.                         |
//+------------------------------------------------------------------+
void CDictionary::Resize(void)
  {
   int level=FindNextLevel();
   int n=level;
   CList *temp_array[];
   #ifdef __MQL4__
   int t_size = ArrayResize(temp_array, ArraySize(m_array));
   for(int i = 0; i < t_size; i++)
      temp_array[i] = m_array[i];
   #else
   ArrayCopy(temp_array, m_array);
   #endif
   ArrayFree(m_array);
   m_array_size=ArrayResize(m_array,n);
   int total=ArraySize(temp_array);
   KeyValuePair *kv=NULL;
   for(int i=0; i<total; i++)
     {
      if(temp_array[i]==NULL)continue;
      CList *list=temp_array[i];
      int count=list.Total();
      list.FreeMode(false);
      kv=list.GetFirstNode();
      while(kv!=NULL)
        {
         int index=GetIndexByHash(kv.GetHash());
         if(CheckPointer(m_array[index])==POINTER_INVALID)
           {
            m_array[index]=new CList();
            m_array[index].FreeMode(true);   // Элементы KeyValuePair удаляются всегда
           }
         list.DetachCurrent();
         m_array[index].Add(kv);
         kv=list.GetCurrentNode();
        }
      delete list;
     }
   int size=ArraySize(temp_array);
   ArrayFree(temp_array);
  }
//+------------------------------------------------------------------+
//| Сжимает словарь.                                                 |
//+------------------------------------------------------------------+
CDictionary::Compress(void)
  {
   if(!m_auto_free)return;
   double koeff=m_array_size/(double)(m_total+1);
   if(koeff < 2.0 || m_total <= 4)return;
   Resize();
  }
//+------------------------------------------------------------------+
//| Возвращет объект по ключу.                                       |
//+------------------------------------------------------------------+
template<typename T>
CObject *CDictionary::GetObjectByKey(T key)
  {
   if(!ContainsKey(key))
      return NULL;
   CObject *obj=m_current_kvp.object;
   return obj;
  }
//+------------------------------------------------------------------+
//| Проверяет содержит ли словарь ключ произвольного типа T.         |
//| RETURNS:                                                         |
//|   Возвращает истину, если объект с таким ключом уже существует   |
//|   и ложь в противном случае.                                     |
//+------------------------------------------------------------------+
template<typename T>
bool CDictionary::ContainsKey(T key)
  {
   m_hash=GetHashByKey(key);
   m_index=GetIndexByHash(m_hash);
   if(CheckPointer(m_array[m_index])==POINTER_INVALID)
      return false;
   CList *list=m_array[m_index];
   KeyValuePair *current_kvp=list.GetCurrentNode();
   if(current_kvp == NULL)return false;
   if(current_kvp.EqualKey(key))
     {
      m_current_kvp=current_kvp;
      return true;
     }
   current_kvp=list.GetFirstNode();
   while(true)
     {
      if(current_kvp.EqualKey(key))
        {
         m_current_kvp=current_kvp;
         return true;
        }
      current_kvp=list.GetNextNode();
      if(current_kvp==NULL)
         return false;
     }
   return false;
  }
//+------------------------------------------------------------------+
//| Добавляет в словарь элемент типа CObject с ключом T key.         |
//| INPUT PARAMETRS:                                                 |
//|   T key - любой базовый тип, например int, double или string.    |
//|   value - класс, производный от CObject.                         |
//| RETURNS:                                                         |
//|   Истина, если элемент был добавлен и ложь в противном случае.   |
//+------------------------------------------------------------------+
template<typename T>
bool CDictionary::AddObject(T key,CObject *value)
  {
   if(ContainsKey(key))
      return false;
   if(m_total==m_array_size)
     {
      Resize();
      ContainsKey(key);
     }
   if(CheckPointer(m_array[m_index])==POINTER_INVALID)
     {
      m_array[m_index]=new CList();
      m_array[m_index].FreeMode(true);   // Элементы KeyValuePair удаляются всегда
     }
   KeyValuePair *kv=new KeyValuePair(key,m_hash,value);
   kv.FreeMode(m_free_mode);
   if(m_array[m_index].Add(kv)!=-1)
      m_total++;
   if(CheckPointer(m_current_kvp)==POINTER_INVALID)
     {
      m_first_kvp=kv;
      m_current_kvp=kv;
      m_last_kvp=kv;
     }
   else
     {
      //добавляем в самый конец, т.к. текущий узел может быть где угодно
      while(m_current_kvp.next_kvp!=NULL)
         m_current_kvp=m_current_kvp.next_kvp;
      m_current_kvp.next_kvp=kv;
      kv.prev_kvp=m_current_kvp;
      m_current_kvp=kv;
      m_last_kvp=kv;
     }
   return true;
  }
//+------------------------------------------------------------------+
//| Возвращает текущий объект. Если объект не выбран возвращает      |
//| NULL.                                                            |
//+------------------------------------------------------------------+
CObject *CDictionary::GetCurrentNode(void)
  {
   if(m_current_kvp==NULL)
      return NULL;
   return m_current_kvp.object;
  }
//+------------------------------------------------------------------+
//| Возвращает предыдущий объект. После вызова метода текущий        |
//| объект становиться предыдущим. Если объект не выбран, возвращает |
//| NULL.                                                            |
//+------------------------------------------------------------------+
CObject *CDictionary:: GetPrevNode(void)
  {
   if(m_current_kvp==NULL)
      return NULL;
   if(m_current_kvp.prev_kvp==NULL)
      return NULL;
   KeyValuePair *kvp=m_current_kvp.prev_kvp;
   m_current_kvp=kvp;
   return kvp.object;
  }
//+------------------------------------------------------------------+
//| Возвращает следующий объект. После вызова метода текущий         |
//| объект становиться следующим. Если объект не выбран, возвращает  |
//| NULL.                                                            |
//+------------------------------------------------------------------+
CObject *CDictionary::GetNextNode(void)
  {
   if(m_current_kvp==NULL)
      return NULL;
   if(m_current_kvp.next_kvp==NULL)
      return NULL;
   m_current_kvp=m_current_kvp.next_kvp;
   return m_current_kvp.object;
  }
//+------------------------------------------------------------------+
//| Возвращает первый узел в списке узлов. Если в словаре узлов нет, |
//| возвращает NULL.                                                 |
//+------------------------------------------------------------------+
CObject *CDictionary::GetFirstNode(void)
  {
   if(m_first_kvp==NULL)
      return NULL;
   m_current_kvp=m_first_kvp;
   return m_first_kvp.object;
  }
//+------------------------------------------------------------------+
//| Возвращает последний узел в списке узлов. Если в словаре узлов   |
//| нет возвращает NULL.                                             |
//+------------------------------------------------------------------+
CObject *CDictionary::GetLastNode(void)
  {
   if(m_last_kvp==NULL)
      return NULL;
   m_current_kvp=m_last_kvp;
   return m_last_kvp.object;
  }
//+------------------------------------------------------------------+
//| Удаляет текущий узел                                             |
//+------------------------------------------------------------------+
bool CDictionary::DeleteCurrentNode(void)
  {
   if(m_current_kvp==NULL)
      return false;
   KeyValuePair* p_kvp = m_current_kvp.prev_kvp;
   KeyValuePair* n_kvp = m_current_kvp.next_kvp;
   if(CheckPointer(p_kvp)!=POINTER_INVALID)
      p_kvp.next_kvp=n_kvp;
   if(CheckPointer(n_kvp)!=POINTER_INVALID)
      n_kvp.prev_kvp=p_kvp;
   m_array[m_index].FreeMode(m_free_mode);
   bool res=m_array[m_index].DeleteCurrent();
   if(res)
     {
      m_total--;
      Compress();
     }
   return res;
  }
//+------------------------------------------------------------------+
//| Удаляет объект с ключом key из словаря.                          |
//+------------------------------------------------------------------+
template<typename T>
bool CDictionary::DeleteObjectByKey(T key)
  {
   if(!ContainsKey(key))
      return false;
   return DeleteCurrentNode();
  }

#define FOREACH_DICT(dict) for(CObject* node = (dict).GetFirstNode(); node != NULL; node = (dict).GetNextNode())
//+------------------------------------------------------------------+
