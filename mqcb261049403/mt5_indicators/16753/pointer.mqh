#property strict

class POINTER
{
public:
  template <typename T>
  static void DeleteObject( const T &Pointer )
  {
    if (::CheckPointer(Pointer) == ::POINTER_DYNAMIC)
      delete Pointer;

    return;
  }

  template <typename T>
  static void DeleteObject( const T &Pointer[] )
  {
    const int Size = ::ArraySize(Pointer);

    for (int i = 0; i < Size; i++)
      POINTER::DeleteObject(Pointer[i]);

    return;
  }

  template <typename T>
  static void Swap( const T &Pointer1, const T &Pointer2 )
  {
    const T Tmp = Pointer1;

    Pointer1 = Pointer2;
    Pointer2 = Tmp;

    return;
  }

};