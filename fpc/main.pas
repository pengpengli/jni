unit main;

{$MODE Delphi}

interface

uses
  Windows, SysUtils, Variants, Classes, Graphics, Controls, Forms, Dialogs, jni,
  StdCtrls, ExtCtrls;

type
  Tfmain = class(TForm)
    btnExit1: TButton;
    btnInvoking1: TButton;
    edtClassName: TEdit;
    edtData: TEdit;
    edtMethodName: TEdit;
    lblClassName: TLabel;
    lblData: TLabel;
    lblMethodName: TLabel;
    DisplayView: TMemo;
    lblResult: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;

    procedure FormDestroy(Sender: TObject);
    procedure btnInvokingClick(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FJavaVM: TJavaVM;
    FJNIEnv: TJNIEnv;
    // 加载虚拟机
    procedure LoadVM();
    // 调用Java方法
    procedure InvokingJavaMethod();

    function U2A(Str: string): AnsiString;
    // function A2U(Str: UTF8String): string;
  public
    { Public declarations }
  end;

var
  fmain: Tfmain;

implementation

{$R *.lfm}

{$ifndef fpc}
uses System.UITypes;
{$endif}

// 加载虚拟机
procedure Tfmain.LoadVM;
var
  Errcode: Integer;
  VM_args: JavaVMInitArgs;
  Options: array [0 .. 10] of JavaVMOption;
  Path: PAnsiChar;
  CurrentPath: string;
begin
  CurrentPath := ExtractFilePath(Application.Exename);
  try
    Path := PAnsiChar(CurrentPath + '..\jre9\bin;' + GetEnvironmentVariable('PATH'));
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
    Errcode := FJavaVM.LoadVM(VM_args);
    if Errcode < 0 then
    begin
      // Loading the VM more than once will cause this error
      if Errcode = JNI_EEXIST then begin
        MessageDlg('Java VM has already been loaded. Only one VM can be loaded.', mtError, [mbOK], 0);
      end else begin
        ShowMessageFmt('Error creating JavaVM, code = %d', [Errcode]);
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
  MethodResult: string;
  JStr: JString;
  ParamData: UTF8String;
  MethodName, ClassName: PAnsiChar;
  Obj: JObject;
begin
  try
    // 类名称
    ClassName := PAnsiChar(U2A(edtClassName.Text));
    // 查找类，类的路径如：com/teclick/arch/*
    Clazz := FJNIEnv.FindClass(ClassName);
    if Clazz = nil then
    begin
      ShowMessage('Can''t find class: ' + ClassName);
    end else begin
      // 方法名称
      MethodName := PAnsiChar(U2A(edtMethodName.Text));
      // 定位类的静态方法MethodName，并配置参数结构
      MethodID := FJNIEnv.GetStaticMethodID(Clazz, MethodName, '(Ljava/lang/String;)Ljava/lang/String;');
      if MethodID = nil then
      begin
        ShowMessage('Can''t find method: ' + MethodName);
      end else begin
        // 将传入的参数值转成UTF8字符，用于支持中文
        ParamData := UTF8Encode(edtData.Text);
        // 调用静态方法
        JStr := FJNIEnv.CallStaticObjectMethod(Clazz, MethodID, [ParamData]);
        MethodResult := FJNIEnv.JStringToString(JStr);
        // 显示结果
        DisplayView.Lines.Add(MethodResult);
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
