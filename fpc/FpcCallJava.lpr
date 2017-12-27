program FpcCallJava;

{$MODE Delphi}

uses
  Forms, Interfaces,
  main in 'main.pas' {fmain},
  jni in '../jni/jni.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(Tfmain, fmain);
  Application.Run;
end.
