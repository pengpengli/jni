unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, jni, StdCtrls, Vcl.ExtCtrls;

type
  Tfmain = class(TForm)
    Panel1: TPanel;
    Panel2: TPanel;
    DisplayView: TMemo;
    btnInvoking: TButton;
    btnExit: TButton;
    lblClassName: TLabel;
    lblMethodName: TLabel;
    lblData: TLabel;
    edtClassName: TEdit;
    edtMethodName: TEdit;
    edtData: TEdit;
    procedure FormDestroy(Sender: TObject);
    procedure btnInvokingClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FJavaVM: TJavaVM;
    FJNIEnv: TJNIEnv;
    // 加载虚拟机
    procedure LoadVM();
    // 调用Java方法
    procedure InvokingJavaMethod();
    function U2A(Str: string): AnsiString;
  public
    { Public declarations }
  end;

var
  fmain: Tfmain;

implementation

{$R *.dfm}

uses System.UITypes;

// 加载虚拟机
procedure Tfmain.LoadVM;
var
  ErrCode: Integer;
  VM_args: JavaVMInitArgs;
  Options: array [0 .. 10] of JavaVMOption;
  Path: PWideChar;
  CurrentPath: string;
begin
  try
    // 创建虚拟机对象，并传入jvm.DLL接口路径
    CurrentPath := ExtractFilePath(Application.Exename);
    Path := PWideChar(CurrentPath + '..\jre9\bin;' + GetEnvironmentVariable('PATH'));
    SetEnvironmentVariable('PATH', Path);

    FJavaVM := TJavaVM.Create(JNI_VERSION_1_6, CurrentPath + '..\jre9\bin\server\jvm.dll');
    FillChar(Options, SizeOf(Options), #0);
    // 设置jar包或类的搜索路径，多个jar使用分号隔开
    Options[0].optionString := '-Djava.class.path=.;../java/target/classes';

    // 声明使用jdk1.6版本
    VM_args.version := JNI_VERSION_1_6;
    VM_args.Options := @Options;
    VM_args.nOptions := 1;
    VM_args.ignoreUnrecognized := False;

    // 加载虚拟机
    ErrCode := FJavaVM.LoadVM(VM_args);
    if ErrCode < 0 then
    begin
      // Loading the VM more than once will cause this error
      if ErrCode = JNI_EEXIST then begin
        MessageDlg('Java VM has already been loaded. Only one VM can be loaded.', mtError, [mbOK], 0)
      end else begin
        ShowMessageFmt('Error creating JavaVM, code = %d', [ErrCode]);
      end;
    end else begin
      // Create the Env class
      FJNIEnv := TJNIEnv.Create(FJavaVM.Env);
    end;
  except
    on E: Exception do
    begin
      ShowMessage('Error: ' + E.Message);
    end;
  end;
end;

function Tfmain.U2A(Str: string): AnsiString;
var
  Bytes: TBytes;
begin
  Bytes := TEncoding.ANSI.GetBytes(Str);
  result := TEncoding.ANSI.GetString(Bytes);
end;

// 调用Java方法
procedure Tfmain.InvokingJavaMethod;
var
  Clazz: JClass;
  MethodID: JMethodID;
  sResult: string;
  JStr: JString;
  ParamData: UTF8String;
  MethodName, ClassName: PAnsiChar;
begin
  try
    // 类名称
    ClassName := PAnsiChar(U2A(edtClassName.Text));

    // 查找类，注意：类的路径需要做转换，如：cn.com.tcsl.RSA 应转化为 cn/com/tcsl/RSA
    Clazz := FJNIEnv.FindClass(ClassName);
    if Clazz = nil then
    begin
      ShowMessage('Can''t find class: ' + ClassName);
    end else begin
      // 方法名称
      MethodName := PAnsiChar(U2A(edtMethodName.Text));
      // 定位类的静态方法sMethod，并配置参数结构
      MethodID := FJNIEnv.GetStaticMethodID(Clazz, MethodName, '(Ljava/lang/String;)Ljava/lang/String;');
      if MethodID = nil then
      begin
        ShowMessage('Can''t find method: ' + MethodName);
        Exit;
      end else begin
        // 将传入的参数值转成UTF8字符，用于支持中文
        ParamData := UTF8Encode(edtData.Text);
        // 调用静态方法
        JStr := FJNIEnv.CallStaticObjectMethod(Clazz, MethodID, [ParamData]);
        // 将JString转化成Delphi String，注意：需要使用UTF8Decode解码UTF8字符
        sResult := FJNIEnv.JStringToString(JStr);
        // 显示结果
        DisplayView.Lines.Add(sResult);
      end;
    end;
  except
    on E: Exception do
      ShowMessage('Error: ' + E.Message);
  end;
end;

procedure Tfmain.FormCreate(Sender: TObject);
begin
  LoadVM();
end;

procedure Tfmain.FormDestroy(Sender: TObject);
begin
  FJNIEnv.Free;
  FJavaVM.Free;
end;

procedure Tfmain.btnInvokingClick(Sender: TObject);
begin
  InvokingJavaMethod();
end;

procedure Tfmain.btnExitClick(Sender: TObject);
begin
  Close;
end;

end.
