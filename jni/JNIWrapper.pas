unit JNIWrapper;

interface

{$IFDEF FPC}
uses Windows, Classes, SysUtils, jni, JUtils;
{$ELSE}
uses WinAPI.Windows, System.Classes, System.SysUtils, jni, JUtils;
{$ENDIF}

type
  TJDoubleArray = array of JDouble;
  TJSingleArray = array of JFloat;
  TJWordArray = array of JChar;
  TJShortintArray = array of JByte;
  TJSmallintArray = array of JShort;
  TJBooleanArray = array of JBoolean;
  TJLongArray = array of JLong;
  TJIntArray = array of JInt;

  PDoubleArray = ^TDoubleArray1;
  TDoubleArray1 = array[0..0] of Double;

  PSingleArray = ^TSingleArray1;
  TSingleArray1 = array[0..0] of Single;

  PWordArray = ^TWordArray1;
  TWordArray1 = array[0..0] of Word;

  PShortintArray = ^TShortintArray1;
  TShortintArray1 = array[0..0] of Shortint;

  PSmallintArray = ^TSmallintArray1;
  TSmallintArray1 = array[0..0] of Smallint;

  PBooleanArray = ^TBooleanArray1;
  TBooleanArray1 = array[0..0] of Boolean;

  PLongArray = ^TLongArray1;
  TLongArray1 = array[0..0] of Int64;

  PIntArray = ^TIntArray1;
  TIntArray1 = array[0..0] of NativeInt;

  // encapsulates a JVM instance,
  // wraps around the PJavaVM handle
  // and provides some static methods
  TJVMInstance = class
  private
    FPVM: PJavaVM;
  public
    constructor Create(PVM: PJavaVM);
    destructor Destroy; override;
    // convenience method to call a method's static main
    // uses delphi's native TStrings to pass the
    // array of string args
    class procedure CallMain(const ClassName: UTF8String; strings: TStrings);
    // waits until all the threads have completed.
    procedure Wait;
    // Convenience method. Calls Exit procedure
    class procedure CallExit(ExitCode: Integer);
    // procedure to explicitly detach a local reference.
    class procedure FreeRef(JObj: JObject; IsGlobal: Boolean);
    // returns the current JNI environment pointer.
    class function GetPenv: PJNIEnv;
    // IMPORTANT: The following method must be called by native methods
    // that receive a penv argument if they intend to use this unit.
    class procedure SetThreadPenv(PEnv: PJNIEnv);
    // This method sets whether you will only be using the JNIWrapper
    // methods from a single thread of execution. Basically, this
    // turns off thread-safety in order to obtain better code performance.
    // Only to be used if you really know what you're doing. Even
    // then, it's probably rarely worth it.
    class procedure SetSingleThreaded(IsSingleThreaded: Boolean);
  end;

  // class TJavaVM
  TJavaClass = class;
  TJavaObject = class;
  TJavaType = (J_Void, J_Object, J_Boolean, J_Byte, J_Char, J_Short, J_Integer, J_Long,
               J_Float, J_Double, J_String, J_BooleanArray, J_ByteArray, J_CharArray,
               J_ShortArray, J_IntArray, J_LongArray, J_FloatArray, J_DoubleArray, J_StringArray);

  TJavaMethodAttribute = (J_static, J_nonstatic, J_nonvirtual);

  {Delphi class to encapsulate list of params to Java method.}
  TJavaParams = class
  private
    FRefList: TList;
    FSignature: UTF8String;
    FArgPointer: Pointer;
    FBufLength: Integer;
    procedure AddToArgBuffer(P: Pointer; NumBytes: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    // The following methods add the various types to the parameter list,
    // updating the signature as well.
    procedure AddBoolean(val: Boolean);
    procedure AddByte(val: JByte);
    procedure AddChar(val: JChar);
    procedure AddShort(val: JShort);
    procedure AddInt(val: JInt);
    procedure AddLong(val: Jlong);
    procedure AddFloat(val: JFloat);
    procedure AddDouble(val: JDouble);
    procedure AddString(val: UTF8String);
    procedure AddBooleanArray(var arr: array of JBoolean);
    procedure AddByteArray(var arr: array of JByte);
    procedure AddCharArray(var arr: array of JChar);
    procedure AddShortArray(var arr: array of JShort);
    procedure AddIntArray(var arr: array of JInt);
    procedure AddLongArray(var arr: array of JLong);
    procedure AddFloatArray(var arr: array of JFloat);
    procedure AddDoubleArray(var arr: array of JDouble);
    procedure AddStringArray(var strings: TStrings);
    // In the following two methods, the second parameter
    // indicates the TJavaClass of which the object is an instance
    procedure AddObject(val: TJavaObject; jcl: TJavaClass);
    procedure AddObjectArray(arr: array of TJavaObject; jcl: TJavaClass);
    // the java signature of this parameter list.
    property Signature: UTF8String read FSignature;
    // a pointer to the buffer that contains the Parameters to be passed.
    property ArgPointer: Pointer read FArgPointer;
  end;

  {Delphi class to encapsulate a Java method; }
  TJavaMethod = class
  private
    FClass: TJavaClass;
    FSignature: UTF8String;
    FMethodType: TJavaMethodAttribute;
    FMethodID: JMethodID;
    FRetval: TJavaType;
  public
    // the constructor. The retclass is nil unless returntype is an object.
    // raises a EJavaMethodNotFound exception if method is not found.
    constructor Create(Clazz: TJavaClass; Name: UTF8String; MethodType: TJavaMethodAttribute;
      ReturnType: TJavaType; Params: TJavaParams; RetClass: TJavaClass);
    // a minimal constructor for virtual methods that
    // take no arguments and return nothing.
    constructor CreateVoid(Clazz: TJavaClass; Name: UTF8String);
    function Call(Params: TJavaParams; JObj: TJavaObject): JValue;
  end;

  {Delphi class to encapsulate a Java object reference.}
  TJavaObject = class
  private
    FLocalHandle: JObject;
    FGlobalHandle: JObject;
    FJavaClass: TJavaClass;
    FPenv: PJNIEnv;
    function GetPEnv: PJNIEnv;
    procedure SetGlobal(IsGlobal: Boolean);
    function IsGlobal: Boolean;
    function IsValid: Boolean;
    function GetHandle: JObject;
  public
    // instantiates a new object of the type passed as the first param,
    // using the constructor with parameters as encapsulated by the params argument.
    constructor Create(jcl: TJavaClass; params: TJavaParams);
    // creates a wrapper object around the low-level JNI handle passed as an argument.
    // to be used when you already have a JNI local object reference but want a delphi wrapper.
    constructor CreateWithHandle(jcl: TJavaClass; jobj: JObject);
    destructor Destroy; override;
    // returns a native delphi string by calling the object's toString()
    // if the object itself is a String, it simply copies it to a Delphi string.
    function ToString: UTF8String;
    // returns true if the argument represents the same java object.
    function Equals(JavaObject: TJavaObject): Boolean;
    // returns true if this object is an instance of the java class.
    function IsInstanceOf(JavaClass: TJavaClass): Boolean;

    property Handle: JObject read GetHandle;
    property ClassRef: TJavaClass read FJavaClass;
    property Global: Boolean read IsGlobal write SetGlobal;
    property Valid: Boolean read IsValid;
  end;

  {Delphi class to encapsulate a Java class reference.}
  TJavaClass = class(TJavaObject)
  private
    FSignature: UTF8String;
  public
    // the constructor raises a EJavaClassNotFound exception if class is not found.
    constructor Create(name: UTF8String);
    // a constructor that creates a TJavaClass wrapper object when it already has
    // a local object ref to the class's JNI handle.
    constructor CreateWithHandle(Name: UTF8String; jc: JClass);
    // returns a handle to a new instance of this class.
    function Instantiate(Params: TJavaParams): TJavaObject;
    function Extends(JavaClass: TJavaClass): Boolean;
    property Signature: UTF8String read FSignature;
  end;

  {Exceptions to be raised when stuff goes wrong with the Java runtime.}

  EJvmException = class(Exception);

  EJavaClassNotFound = class(EJvmException);

  EJavaMethodNotFound = class(EJvmException);

  EJavaObjectInstantiation = class(EJvmException);

  EInvalidJNIHandle = class(EJvmException);

  { Various utility functions for creating java objects from delphi objects.}
  function CreateJString(s: UTF8String): jstring;
  function CreateJStringArray(var strings: TStrings): jarray;
  function CreateJBooleanArray(var arr: array of JBoolean): jBooleanArray;
  function CreateJByteArray(var arr: array of JByte): jByteArray;
  function CreateJCharArray(var arr: array of JChar): jCharArray;
  function CreateJShortArray(var arr: array of JShort): jShortArray;
  function CreateJIntArray(var arr: array of JInt): jIntArray;
  function CreateJLongArray(var arr: array of Jlong): jLongArray;
  function CreateJFloatArray(var arr: array of JFloat): jFloatArray;
  function CreateJDoubleArray(var arr: array of JDouble): jDoubleArray;
  function GetStringClass: JClass;

  {various utility functions for creating Delphi objects from Java objects}
  function JToString(js: jstring): UTF8String;
  function JToTStrings(jarr: JobjectArray): TStrings;
  function JStringArrayToTStrings(jarr: jarray): TStrings;
  function JDoubleArrayToDoubleArray(jarr: jDoubleArray): TJDoubleArray;
  function JFloatArrayToSingleArray(jarr: jFloatArray): TJSingleArray;
  function JCharArrayToWordArray(jarr: jCharArray): TJWordArray;
  function JByteArrayToShortIntArray(jarr: jByteArray): TJShortintArray;
  function JShortArrayToSmallIntArray(jarr: jShortArray): TJSmallintArray;
  function JBooleanArrayToBooleanArray(jarr: jBooleanArray): TJBooleanArray;
  function JLongArrayToLongArray(jarr: jLongArray): TJLongArray;
  function JIntArrayToIntArray(jarr: jIntArray): TJIntArray;

implementation

uses JavaRuntime;

threadvar PEnvThread: PJNIEnv;

var
  PEnvGlobal: PJNIEnv;
  sc: JClass = nil;
  SingleThreaded: Boolean;

function JNIPointer: PJNIEnv;
begin
  Result := PEnvGlobal;
  if (not SingleThreaded) or (PEnvGlobal = nil) then
  begin
    Result := PEnvThread;
    if SingleThreaded then
      PEnvGlobal := PEnvThread;
  end;
  if Result = nil then
  begin
    //TJavaRuntime.getDefault.GetVM;
    Result := PEnvThread;
    if SingleThreaded then
      PEnvGlobal := PEnvThread;
  end;
  if Result = nil then
    raise EJvmException.Create('No PEnv pointer is available');
end;

constructor TJVMInstance.Create(PVM: PJavaVM);
begin
  FPVM := PVM;
end;

destructor TJVMInstance.Destroy;
begin
  if FPVM <> nil then
    CallExit(0);
  inherited Destroy;
end;

procedure TJVMInstance.Wait;
begin
  if FPVM <> nil then
    FPVM^.DestroyJavaVM(FPVM);
  FPVM := nil;
end;

class function TJVMInstance.GetPenv;
begin
  Result := JNIPointer;
end;

class procedure TJVMInstance.SetThreadPenv(PEnv: PJNIEnv);
begin
  PEnvThread := PEnv;
  PEnvGlobal := PEnv;
end;

class procedure TJVMInstance.SetSingleThreaded(IsSingleThreaded: Boolean);
begin
  if IsSingleThreaded then
    PEnvGlobal := PEnvThread;
  SingleThreaded := IsSingleThreaded;
end;

class procedure TJVMInstance.FreeRef(JObj: JObject; IsGlobal: Boolean);
var
  penv: PJNIEnv;
begin
  penv := JNIPointer;
  if IsGlobal then
    penv^.DeleteGlobalRef(penv, JObj)
  else
    penv^.DeleteLocalRef(penv, JObj);
end;

class procedure TJVMInstance.CallMain(const ClassName: UTF8String; strings: TStrings);
var
  ClassID: jclass;
  MethodID: JMethodID;
  StringArray: jarray;
  PEnv: PJNIEnv;
begin
  PEnv := JNIPointer;
  ClassID := PEnv^.FindClass(PEnv, PUTF8Char(DotToSlash(ClassName)));
  if ClassID = nil then
    raise EJavaClassNotFound.Create('Could not find class ' + ClassName);
  MethodID := PEnv^.GetStaticMethodID(PEnv, ClassID, PUTF8Char('main'), PUTF8Char('([Ljava/lang/String;)V'));
  if MethodID = nil then
    raise EJavaMethodNotFound.Create('Could not find main method in class ' + ClassName);
  StringArray := CreateJStringArray(strings);
  PEnv^.CallStaticVoidMethodV(PEnv, ClassID, MethodID, @StringArray);
  FreeRef(StringArray, false);
end;

class procedure TJVMInstance.CallExit(ExitCode: Integer);
var
  ClassID: jclass;
  MethodID: JMethodID;
  PEnv: PJNIEnv;
begin
  PEnv := JNIPointer;
  ClassID := PEnv^.FindClass(PEnv, 'java/lang/System');
  MethodID := PEnv^.GetStaticMethodID(PEnv, ClassID, 'exit', '(I)V');
  PEnv^.CallStaticVoidMethodV(PEnv, ClassID, MethodID, @ExitCode);
end;

constructor TJavaClass.Create(name: UTF8String);
begin
  FPenv := JNIPointer;
  FSignature := DotToSlash(name);
  FLocalHandle := FPenv^.FindClass(FPenv, PUTF8Char(FSignature));
  if FLocalHandle = nil then
    raise EJavaClassNotFound.Create('class ' + name + ' not found.');
end;

constructor TJavaClass.CreateWithHandle(Name: UTF8String; jc: JClass);
begin
  FPenv := JNIPointer;
  FSignature := DotToSlash(Name);
  FLocalHandle := jc;
end;

function TJavaClass.Instantiate(Params: TJavaParams): TJavaObject;
begin
  Result := TJavaObject.Create(Self, Params)
end;

function TJavaClass.Extends(JavaClass: TJavaClass): Boolean;
var
  penv: PJNIEnv;
begin
  penv := GetPEnv;
  Result := penv^.isAssignableFrom(penv, Handle, JavaClass.Handle);
end;

constructor TJavaObject.Create(jcl: TJavaClass; params: TJavaParams);
var
  Signature: UTF8String;
  methodID: JMethodID;
  argPointer: Pointer;
begin
  Signature := '';
  argPointer := nil;
  FJavaClass := jcl;
  FPenv := JNIPointer;
  if params <> nil then
  begin
    Signature := params.Signature;
    argPointer := params.ArgPointer;
  end;
  Signature := '(' + Signature + ')V';
  methodID := FPenv^.GetMethodID(FPenv, jcl.Handle, '<init>', PUTF8Char(Signature));
  if methodID = nil then
    raise EJavaObjectInstantiation.Create('No such constructor ' + Signature);
  FLocalHandle := FPenv^.NewObjectV(FPenv, jcl.Handle, methodID, argPointer);
  if FLocalHandle = nil then
    raise EJavaObjectInstantiation.Create('Could not create new instance of ' + jcl.Signature);
end;

constructor TJavaObject.CreateWithHandle(jcl: TJavaClass; jobj: JObject);
begin
  FPenv := JNIPointer;
  FJavaClass := jcl;
  FLocalHandle := jobj;
end;

destructor TJavaObject.Destroy;
begin
  if FGlobalHandle <> nil then
    TJVMInstance.FreeRef(FGlobalHandle, true);
  inherited Destroy;
end;

function TJavaObject.GetPEnv: PJNIEnv;
begin
  if IsGlobal or (FPenv = nil) then
    Result := JNIPointer
  else
    Result := FPenv;
end;

function TJavaObject.Equals(JavaObject: TJavaObject): Boolean;
var
  penv: PJNIEnv;
begin
  penv := GetPEnv;
  if (not self.Valid) or (not JavaObject.Valid) then
    raise EInvalidJNIHandle.Create('Attempt to use JNI local object reference in a different thread.');
  Result := penv^.IsSameObject(penv, Handle, JavaObject.Handle);
end;

function TJavaObject.IsInstanceOf(JavaClass: TJavaClass): Boolean;
var
  penv: PJNIEnv;
begin
  penv := GetPEnv;
  if (not self.Valid) or (not JavaClass.Valid) then
    raise EInvalidJNIHandle.Create('Attempt to use JNI local object reference in a different thread.');
  Result := penv^.isInstanceOf(penv, Handle, JavaClass.Handle);
end;

procedure TJavaObject.SetGlobal(IsGlobal: Boolean);
begin
  if IsGlobal = Global then
    Exit;
  if IsGlobal then
    FGlobalHandle := FPenv^.NewGlobalRef(FPenv, FLocalHandle)
  else
  begin
    FPenv := JNIPointer;
    FLocalHandle := FPenv^.NewLocalRef(FPenv, FGlobalHandle);
    FPenv^.DeleteGlobalRef(FPenv, FGlobalHandle);
    FGlobalHandle := nil;
  end;
end;

function TJavaObject.IsGlobal: Boolean;
begin
  Result := FGlobalHandle <> nil;
end;

function TJavaObject.IsValid: Boolean;
begin
  if IsGlobal then
    Result := true
  else
    Result := (FLocalHandle <> nil) and (FPenv = JNIPointer);
end;

function TJavaObject.GetHandle: JObject;
begin
  Result := FGlobalHandle;
  if Result = nil then
    Result := FLocalHandle;
end;

function TJavaObject.ToString: UTF8String;
var
  toStringMethod: JMethodID;
  js: jstring;
  penv: PJNIEnv;
begin
  penv := GetPEnv;
  toStringMethod := penv^.GetMethodID(penv, ClassRef.Handle, 'toString', '()Ljava/lang/String;');
  js := penv^.callObjectMethod(penv, Handle, toStringMethod);
  Result := JToString(js);
end;

constructor TJavaParams.Create;
begin
  FRefList := TList.Create;
end;

destructor TJavaParams.Destroy;
var
  I: Integer;
begin
  for I := 0 to FRefList.Count - 1 do
    TJVMInstance.FreeRef(FRefList.Items[I], false);
  FRefList.Free;
  if Assigned(FArgPointer) then
    FreeMem(FArgPointer);
  inherited Destroy;
end;

procedure TJavaParams.AddBoolean(val: Boolean);
begin
  AddToArgBuffer(@val, sizeof(val));
  FSignature := FSignature + 'Z';
end;

procedure TJavaParams.AddByte(val: JByte);
begin
  AddToArgBuffer(@val, sizeof(val));
  FSignature := FSignature + 'B';
end;

procedure TJavaParams.AddChar(val: JChar);
begin
  AddToArgBuffer(@val, sizeof(val));
  FSignature := FSignature + 'C';
end;

procedure TJavaParams.AddShort(val: JShort);
begin
  AddToArgBuffer(@val, sizeof(val));
  FSignature := FSignature + 'S';
end;

procedure TJavaParams.AddInt(val: JInt);
begin
  AddToArgBuffer(@val, sizeof(val));
  FSignature := FSignature + 'I';
end;

procedure TJavaParams.AddLong(val: Jlong);
begin
  AddToArgBuffer(@val, sizeof(val));
  FSignature := FSignature + 'J';
end;

procedure TJavaParams.AddFloat(val: JFloat);
begin
  AddToArgBuffer(@val, sizeof(val));
  FSignature := FSignature + 'F';
end;

procedure TJavaParams.AddDouble(val: JDouble);
begin
  AddToArgBuffer(@val, sizeof(val));
  FSignature := FSignature + 'D';
end;

procedure TJavaParams.AddString(val: UTF8String);
var
  js: JString;
begin
  js := CreateJString(val);
  AddToArgBuffer(@js, sizeof(js));
  FSignature := FSignature + 'Ljava/lang/String;';
  FRefList.add(js);
end;

procedure TJavaParams.AddObject(val: TJavaObject; jcl: TJavaClass);
var
  objHandle: JObject;
begin
  objHandle := val.Handle;
  AddToArgBuffer(@objHandle, sizeof(objHandle));
  FSignature := FSignature + 'L' + jcl.Signature + ';';
end;

procedure TJavaParams.AddObjectArray(arr: array of TJavaObject; jcl: TJavaClass);
var
  penv: PJNIEnv;
  jarr: JobjectArray;
  I: Integer;
begin
  penv := JNIPointer;
  jarr := penv^.NewObjectArray(penv, High(arr) + 1, jcl.Handle, arr[0].Handle);
  for I := 1 + Low(arr) to High(arr) do
    penv^.setObjectArrayElement(penv, jarr, I, arr[I].Handle);
  AddToArgBuffer(@jarr, sizeof(jarr));
  FSignature := FSignature + '[L' + jcl.Signature + ';';
  FRefList.add(jarr)
end;

procedure TJavaParams.AddBooleanArray(var arr: array of JBoolean);
var
  jbarray: jBooleanArray;
begin
  jbarray := CreateJBooleanArray(arr);
  AddToArgBuffer(@jbarray, sizeof(jbarray));
  FSignature := FSignature + '[Z';
  FRefList.add(jbarray)
end;

procedure TJavaParams.AddByteArray(var arr: array of JByte);
var
  jbarray: jByteArray;
begin
  jbarray := CreateJByteArray(arr);
  AddToArgBuffer(@jbarray, sizeof(jbarray));
  FSignature := FSignature + '[B';
  FRefList.add(jbarray)
end;

procedure TJavaParams.AddCharArray(var arr: array of JChar);
var
  jcarray: jCharArray;
begin
  jcarray := CreateJCharArray(arr);
  AddToArgBuffer(@jcarray, sizeof(jcarray));
  FSignature := FSignature + '[C';
  FRefList.add(jcarray)
end;

procedure TJavaParams.AddShortArray(var arr: array of JShort);
var
  jsarray: jShortArray;
begin
  jsarray := CreateJShortArray(arr);
  AddToArgBuffer(@jsarray, sizeof(jsarray));
  FSignature := FSignature + '[S';
  FRefList.add(jsarray)
end;

procedure TJavaParams.AddIntArray(var arr: array of JInt);
var
  jiarray: jIntArray;
begin
  jiarray := CreateJIntArray(arr);
  AddToArgBuffer(@jiarray, sizeof(jiarray));
  FSignature := FSignature + '[I';
  FRefList.add(jiarray)
end;

procedure TJavaParams.AddLongArray(var arr: array of JLong);
var
  jlarray: jLongArray;
begin
  jlarray := CreateJLongArray(arr);
  AddToArgBuffer(@jlarray, sizeof(jlarray));
  FSignature := FSignature + '[J';
  FRefList.add(jlarray)
end;

procedure TJavaParams.AddFloatArray(var arr: array of JFloat);
var
  jfarray: jFloatArray;
begin
  jfarray := CreateJFloatArray(arr);
  AddToArgBuffer(@jfarray, sizeof(jfarray));
  FSignature := FSignature + '[F';
  FRefList.add(jfarray)
end;

procedure TJavaParams.AddDoubleArray(var arr: array of JDouble);
var
  jdarray: jDoubleArray;
begin
  jdarray := CreateJDoubleArray(arr);
  AddToArgBuffer(@jdarray, sizeof(jdarray));
  FSignature := FSignature + '[D';
  FRefList.add(jdarray)
end;

procedure TJavaParams.AddStringArray(var strings: TStrings);
var
  jsarray: jarray;
begin
  jsarray := CreateJStringArray(strings);
  AddToArgBuffer(@jsarray, sizeof(jsarray));
  FSignature := FSignature + '[Ljava/lang/String;';
  FRefList.add(jsarray)
end;

procedure TJavaParams.AddToArgBuffer(P: Pointer; NumBytes: Integer);
var
  P1, P2: Pointer;
  I: Integer;
begin
  ReallocMem(FArgPointer, FBufLength + NumBytes);

  P1 := Pointer(NativeInt(FArgPointer) + FBufLength);
  P2 := Pointer(P);

  for I := 0 to (NumBytes - 1) do
    PUTF8Char(NativeInt(P1) + NativeInt(I))^ := PUTF8Char(NativeInt(P2) + NativeInt(I))^;
  inc(FBufLength, NumBytes);
end;

constructor TJavaMethod.Create(Clazz: TJavaClass; Name: UTF8String; MethodType: TJavaMethodAttribute; ReturnType: TJavaType;
  Params: TJavaParams; RetClass: TJavaClass);
var
  PEnv: PJNIEnv;
begin
  FClass := Clazz;
  if Params = nil then
    FSignature := '()'
  else
    FSignature := '(' + Params.Signature + ')';
  FMethodType := MethodType;
  FRetval := ReturnType;
  case FRetval of
    J_Boolean:
      FSignature := FSignature + 'Z';
    J_Byte:
      FSignature := FSignature + 'B';
    J_Char:
      FSignature := FSignature + 'C';
    J_Short:
      FSignature := FSignature + 'S';
    J_Integer:
      FSignature := FSignature + 'I';
    J_Long:
      FSignature := FSignature + 'J';
    J_Float:
      FSignature := FSignature + 'F';
    J_Double:
      FSignature := FSignature + 'D';
    J_String:
      FSignature := FSignature + 'Ljava/lang/String;';
    J_Object:
      FSignature := FSignature + 'L' + RetClass.Signature + ';';
    J_BooleanArray:
      FSignature := FSignature + '[Z';
    J_ByteArray:
      FSignature := FSignature + '[B';
    J_CharArray:
      FSignature := FSignature + '[C';
    J_ShortArray:
      FSignature := FSignature + '[S';
    J_IntArray:
      FSignature := FSignature + '[I';
    J_LongArray:
      FSignature := FSignature + '[J';
    J_FloatArray:
      FSignature := FSignature + '[F';
    J_DoubleArray:
      FSignature := FSignature + '[D';
    J_StringArray:
      FSignature := FSignature + '[Ljava/lang/String;';
  else
    FSignature := FSignature + 'V';
  end;

  PEnv := JNIPointer;

  if FMethodType = J_static then
    FMethodID := PEnv^.GetStaticMethodID(PEnv, FClass.Handle, PUTF8Char(Name), PUTF8Char(FSignature))
  else
    FMethodID := PEnv^.GetMethodID(PEnv, FClass.Handle, PUTF8Char(Name), PUTF8Char(FSignature));
  if FMethodID = nil then
    raise EJavaMethodNotFound.Create('method ' + Name + FSignature + ' not found.');
end;

constructor TJavaMethod.CreateVoid(Clazz: TJavaClass; Name: UTF8String);
begin
  Create(Clazz, Name, J_nonstatic, J_Void, nil, nil);
end;

function TJavaMethod.Call(Params: TJavaParams; JObj: TJavaObject): JValue;
var
  penv: PJNIEnv;
  obj: JObject;
  argPointer: Pointer;
begin
  penv := JNIPointer;
  argPointer := nil;
  if Params <> nil then
    argPointer := Params.ArgPointer;
  if JObj <> nil then
    obj := JObj.Handle
  else
    obj := nil;
  if FMethodType = J_static then
    case FRetval of
      J_Void:
        penv^.CallStaticVoidMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_Boolean:
        Result.z := penv^.CallStaticBooleanMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_Byte:
        Result.B := penv^.CallStaticByteMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_Char:
        Result.c := penv^.CallStaticCharMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_Short:
        Result.s := penv^.CallStaticShortMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_Integer:
        Result.I := penv^.CallStaticIntMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_Long:
        Result.J := penv^.CallStaticLongMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_Float:
        Result.F := penv^.CallStaticFloatMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_Double:
        Result.D := penv^.CallStaticDoubleMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_Object:
        Result.l := penv^.CallStaticObjectMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_String:
        Result.l := penv^.CallStaticObjectMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_DoubleArray:
        Result.l := penv^.CallStaticObjectMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_BooleanArray:
        Result.l := penv^.CallStaticObjectMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_ByteArray:
        Result.l := penv^.CallStaticObjectMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_CharArray:
        Result.l := penv^.CallStaticObjectMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_ShortArray:
        Result.l := penv^.CallStaticObjectMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_IntArray:
        Result.l := penv^.CallStaticObjectMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_LongArray:
        Result.l := penv^.CallStaticObjectMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_FloatArray:
        Result.l := penv^.CallStaticObjectMethodV(penv, FClass.Handle, FMethodID, argPointer);
      J_StringArray:
        Result.l := penv^.CallStaticObjectMethodV(penv, FClass.Handle, FMethodID, argPointer);

    end;

  if FMethodType = J_nonvirtual then
    case FRetval of
      J_Void:
        penv^.CallNonvirtualVoidMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_Boolean:
        Result.z := penv^.CallNonVirtualBooleanMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_Byte:
        Result.B := penv^.CallNonVirtualByteMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_Char:
        Result.c := penv^.CallNonVirtualCharMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_Short:
        Result.s := penv^.CallNonVirtualShortMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_Integer:
        Result.I := penv^.CallNonVirtualIntMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_Long:
        Result.J := penv^.CallNonVirtualLongMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_Float:
        Result.F := penv^.CallNonVirtualFloatMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_Double:
        Result.D := penv^.CallNonVirtualDoubleMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_Object:
        Result.l := penv^.CallNonVirtualObjectMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_String:
        Result.l := penv^.CallNonVirtualObjectMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_DoubleArray:
        Result.l := penv^.CallNonVirtualObjectMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_BooleanArray:
        Result.l := penv^.CallNonVirtualObjectMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_ByteArray:
        Result.l := penv^.CallNonVirtualObjectMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_CharArray:
        Result.l := penv^.CallNonVirtualObjectMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_ShortArray:
        Result.l := penv^.CallNonVirtualObjectMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_IntArray:
        Result.l := penv^.CallNonVirtualObjectMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_LongArray:
        Result.l := penv^.CallNonVirtualObjectMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_FloatArray:
        Result.l := penv^.CallNonVirtualObjectMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);
      J_StringArray:
        Result.l := penv^.CallNonVirtualObjectMethodV(penv, obj, FClass.Handle, FMethodID, argPointer);

    end;

  if FMethodType = J_nonstatic then
    case FRetval of
      J_Void:
        penv^.CallVoidMethodV(penv, obj, FMethodID, argPointer);
      J_Boolean:
        Result.z := penv^.CallBooleanMethodV(penv, obj, FMethodID, argPointer);
      J_Byte:
        Result.B := penv^.CallByteMethodV(penv, obj, FMethodID, argPointer);
      J_Char:
        Result.c := penv^.CallCharMethodV(penv, obj, FMethodID, argPointer);
      J_Short:
        Result.s := penv^.CallShortMethodV(penv, obj, FMethodID, argPointer);
      J_Integer:
        Result.I := penv^.CallIntMethodV(penv, obj, FMethodID, argPointer);
      J_Long:
        Result.J := penv^.CallLongMethodV(penv, obj, FMethodID, argPointer);
      J_Float:
        Result.F := penv^.CallFloatMethodV(penv, obj, FMethodID, argPointer);
      J_Double:
        Result.D := penv^.CallDoubleMethodV(penv, obj, FMethodID, argPointer);
      J_Object:
        Result.l := penv^.CallObjectMethodV(penv, obj, FMethodID, argPointer);
      J_String:
        Result.l := penv^.CallObjectMethodV(penv, obj, FMethodID, argPointer);
      J_DoubleArray:
        Result.l := penv^.CallObjectMethodV(penv, obj, FMethodID, argPointer);
      J_BooleanArray:
        Result.l := penv^.CallObjectMethodV(penv, obj, FMethodID, argPointer);
      J_ByteArray:
        Result.l := penv^.CallObjectMethodV(penv, obj, FMethodID, argPointer);
      J_CharArray:
        Result.l := penv^.CallObjectMethodV(penv, obj, FMethodID, argPointer);
      J_ShortArray:
        Result.l := penv^.CallObjectMethodV(penv, obj, FMethodID, argPointer);
      J_IntArray:
        Result.l := penv^.CallObjectMethodV(penv, obj, FMethodID, argPointer);
      J_LongArray:
        Result.l := penv^.CallObjectMethodV(penv, obj, FMethodID, argPointer);
      J_FloatArray:
        Result.l := penv^.CallObjectMethodV(penv, obj, FMethodID, argPointer);
      J_StringArray:
        Result.l := penv^.CallObjectMethodV(penv, obj, FMethodID, argPointer);
    end;
end;

function CreateJString(s: UTF8String): jstring;
var
  penv: PJNIEnv;
begin
  penv := JNIPointer;
  Result := penv^.NewStringUTF(penv, PUTF8Char(s));
end;

function JToString(js: jstring): UTF8String;
var
  PEnv: PJNIEnv;
  len: NativeInt;
  CharBuf: PUTF8Char;
  IsCopy: JBoolean;
begin
  PEnv := JNIPointer;
  CharBuf := PEnv^.GetStringUTFChars(PEnv, js, IsCopy);
  len := PEnv^.GetStringUTFLength(PEnv, js);
  SetLength(Result, 1 + len);
  StrLCopy(PUTF8Char(Result), CharBuf, len);
  if IsCopy then
    PEnv^.ReleaseStringUTFChars(PEnv, js, CharBuf);
end;

function JToTStrings(jarr: JobjectArray): TStrings;
var
  penv: PJNIEnv;
  jobj: JObject;
  len, I: NativeInt;
begin
  penv := JNIPointer;
  Result := TStringList.Create;
  len := penv^.GetArrayLength(penv, jarr);

  for I := 1 to len Do
  begin
    jobj := penv^.GetObjectArrayElement(penv, jarr, I - 1);
    Result.add(JToString(jobj));
  end;
end;

function JStringArrayToTStrings(jarr: jarray): TStrings;
var
  penv: PJNIEnv;
  jobj: JObject;
  len, I: NativeInt;
begin
  penv := JNIPointer;
  Result := TStringList.Create;
  len := penv^.GetArrayLength(penv, jarr);
  I := 0;
  if len > 0 then
  begin
    repeat
      inc(I);
      jobj := penv^.GetObjectArrayElement(penv, jarr, I - 1);
      Result.add(JToString(jobj));
    until I = len;
  end;
end;

function JDoubleArrayToDoubleArray(jarr: JDoubleArray): TJDoubleArray;
var
  PEnv: PJNIEnv;
  len, I: NativeInt;
  d1: PJDouble;
  IsCopy: JBoolean;
begin
  IsCopy := JNI_FALSE;
  PEnv := JNIPointer;
  len := PEnv^.GetArrayLength(PEnv, jarr);
  d1 := PEnv^.GetDoubleArrayElements(PEnv, jarr, IsCopy);
  I := 0;
  if len > 0 then
  begin
    SetLength(Result, 1000);
    repeat
      inc(I);
      if (I - 1) = length(Result) then
        SetLength(Result, length(Result) + 1000);
      Result[I - 1] := PDoubleArray(d1)[I - 1];
    until I > len;
  end;
  SetLength(Result, len);
end;

function JFloatArrayToSingleArray(jarr: jFloatArray): TJSingleArray;
var
  penv: PJNIEnv;
  len, I: NativeInt;
  d1: PJFloat;
  IsCopy: JBoolean;
begin
  IsCopy := JNI_FALSE;
  penv := JNIPointer;
  len := penv^.GetArrayLength(penv, jarr);
  d1 := penv^.GetFloatArrayElements(penv, jarr, IsCopy);
  I := 0;
  if len > 0 then
  begin
    SetLength(Result, 1000);
    repeat
      inc(I);
      if (I - 1) = length(Result) then
        SetLength(Result, length(Result) + 1000);
      Result[I - 1] := PSingleArray(d1)[I - 1];
    until I > len;
  end;
  SetLength(Result, len);
end;

function JCharArrayToWordArray(jarr: jCharArray): TJWordArray;
var
  PEnv: PJNIEnv;
  len, I: NativeInt;
  d1: PJChar;
  IsCopy: JBoolean;
begin
  IsCopy := JNI_FALSE;
  PEnv := JNIPointer;
  len := PEnv^.GetArrayLength(PEnv, jarr);
  d1 := PEnv^.GetCharArrayElements(PEnv, jarr, IsCopy);
  I := 0;
  if len > 0 then
  begin
    SetLength(Result, 1000);
    repeat
      inc(I);
      if (I - 1) = length(Result) then
        SetLength(Result, length(Result) + 1000);
      //Result[I - 1] := PWordArray(d1)[I - 1];
    until I > len;
  end;
  SetLength(Result, len);
end;

function JByteArrayToShortIntArray(jarr: jByteArray): TJShortintArray;
var
  penv: PJNIEnv;
  len, I: NativeInt;
  d1: PJByte;
  IsCopy: JBoolean;
begin
  IsCopy := JNI_FALSE;
  penv := JNIPointer;
  len := penv^.GetArrayLength(penv, jarr);
  d1 := penv^.GetByteArrayElements(penv, jarr, IsCopy);
  I := 0;
  if len > 0 then
  begin
    SetLength(Result, 1000);
    repeat
      inc(I);
      if (I - 1) = length(Result) then
        SetLength(Result, length(Result) + 1000);
      Result[I - 1] := PShortintArray(d1)[I - 1];
    until I > len;
  end;
  SetLength(Result, len);
end;

function JShortArrayToSmallIntArray(jarr: jShortArray): TJSmallintArray;
var
  penv: PJNIEnv;
  len, I: NativeInt;
  d1: PJShort;
  IsCopy: JBoolean;
begin
  IsCopy := JNI_FALSE;
  penv := JNIPointer;
  len := penv^.GetArrayLength(penv, jarr);
  d1 := penv^.GetShortArrayElements(penv, jarr, IsCopy);
  I := 0;
  if len > 0 then
  begin
    SetLength(Result, 1000);
    repeat
      inc(I);
      if (I - 1) = length(Result) then
        SetLength(Result, length(Result) + 1000);
      Result[I - 1] := PSmallintArray(d1)[I - 1];
    until I > len;
  end;
  SetLength(Result, len);
end;

function JBooleanArrayToBooleanArray(jarr: jBooleanArray): TJBooleanArray;
var
  penv: PJNIEnv;
  len, I: NativeInt;
  d1: PJBoolean;
  IsCopy: JBoolean;
begin
  IsCopy := JNI_FALSE;
  penv := JNIPointer;
  len := penv^.GetArrayLength(penv, jarr);
  d1 := penv^.GetBooleanArrayElements(penv, jarr, IsCopy);
  I := 0;
  if len > 0 then
  begin
    SetLength(Result, 1000);
    repeat
      inc(I);
      if (I - 1) = length(Result) then
        SetLength(Result, length(Result) + 1000);
      Result[I - 1] := PBooleanArray(d1)[I - 1];
    until I > len;
  end;
  SetLength(Result, len);
end;

function JLongArrayToLongArray(jarr: jLongArray): TJLongArray;
var
  penv: PJNIEnv;
  len, I: NativeInt;
  d1: PJLong;
  IsCopy: JBoolean;
begin
  IsCopy := JNI_FALSE;
  penv := JNIPointer;
  len := penv^.GetArrayLength(penv, jarr);
  d1 := penv^.GetLongArrayElements(penv, jarr, IsCopy);
  I := 0;
  if len > 0 then
  begin
    SetLength(Result, 1000);
    repeat
      inc(I);
      if (I - 1) = length(Result) then
        SetLength(Result, length(Result) + 1000);
      Result[I - 1] := PLongArray(d1)[I - 1];
    until I > len;
  end;
  SetLength(Result, len);
end;

function JIntArrayToIntArray(jarr: jIntArray): TJIntArray;
var
  penv: PJNIEnv;
  len, I: NativeInt;
  d1: PJInt;
  IsCopy: JBoolean;
begin
  IsCopy := JNI_FALSE;
  penv := JNIPointer;
  len := penv^.GetArrayLength(penv, jarr);
  d1 := penv^.GetIntArrayElements(penv, jarr, IsCopy);
  I := 0;
  if len > 0 then
  begin
    SetLength(Result, 1000);
    repeat
      inc(I);
      if (I - 1) = length(Result) then
        SetLength(Result, length(Result) + 1000);
      Result[I - 1] := PIntArray(d1)[I - 1];
    until I > len;
  end;
  SetLength(Result, len);
end;

function GetStringClass: JClass;
var
  penv: PJNIEnv;
begin
  if sc = nil then
  begin
    penv := JNIPointer;
    sc := penv^.FindClass(JNIPointer, 'java/lang/String');
    sc := penv^.NewGlobalRef(penv, sc);
  end;
  Result := sc;
end;

function CreateJStringArray(var strings: TStrings): jarray;
var
  I, Count: NativeInt;
  js: jstring;
  penv: PJNIEnv;
begin
  penv := JNIPointer;
  Count := 0;
  if strings <> nil then
    Count := strings.Count;
  js := CreateJString('');
  Result := penv^.NewObjectArray(penv, Count, GetStringClass, js);
  for I := 0 to Count - 1 do
  begin
    js := CreateJString(UTF8String(strings.strings[I]));
    penv^.setObjectArrayElement(penv, Result, I, js);
  end;
end;

function CreateJBooleanArray(var arr: array of JBoolean): jBooleanArray;
var
  penv: PJNIEnv;
begin
  penv := JNIPointer;
  Result := penv^.newBooleanArray(penv, High(arr) + 1);
  penv^.setBooleanArrayRegion(penv, Result, low(arr), High(arr) + 1, @arr);
end;

function CreateJByteArray(var arr: array of JByte): jByteArray;
var
  penv: PJNIEnv;
begin
  penv := JNIPointer;
  Result := penv^.newByteArray(penv, High(arr) + 1);
  penv^.setByteArrayRegion(penv, Result, 0, High(arr) + 1, @arr);
end;

function CreateJCharArray(var arr: array of JChar): jCharArray;
var
  penv: PJNIEnv;
begin
  penv := JNIPointer;
  Result := penv^.newCharArray(penv, High(arr) + 1);
  penv^.setCharArrayRegion(penv, Result, low(arr), High(arr) + 1, @arr);
end;

function CreateJShortArray(var arr: array of JShort): jShortArray;
var
  penv: PJNIEnv;
begin
  penv := JNIPointer;
  Result := penv^.newShortArray(penv, High(arr) + 1);
  penv^.setShortArrayRegion(penv, Result, 0, High(arr) + 1, @arr);
end;

function CreateJIntArray(var arr: array of JInt): jIntArray;
var
  penv: PJNIEnv;
begin
  penv := JNIPointer;
  Result := penv^.newIntArray(penv, High(arr) + 1);
  penv^.setIntArrayRegion(penv, Result, low(arr), High(arr) + 1, @arr);
end;

function CreateJLongArray(var arr: array of Jlong): jLongArray;
var
  penv: PJNIEnv;
begin
  penv := JNIPointer;
  Result := penv^.newLongArray(penv, High(arr) + 1);
  penv^.setLongArrayRegion(penv, Result, low(arr), High(arr) + 1, @arr);
end;

function CreateJFloatArray(var arr: array of JFloat): jFloatArray;
var
  penv: PJNIEnv;
begin
  penv := JNIPointer;
  Result := penv^.newFloatArray(penv, High(arr) + 1);
  penv^.setFloatArrayRegion(penv, Result, low(arr), High(arr) + 1, @arr);
end;

function CreateJDoubleArray(var arr: array of JDouble): jDoubleArray;
var
  penv: PJNIEnv;
begin
  penv := JNIPointer;
  Result := penv^.newDoubleArray(penv, High(arr) + 1);
  penv^.setDoubleArrayRegion(penv, Result, 0, High(arr) + 1, @arr);
end;

end.
