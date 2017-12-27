object fmain: Tfmain
  Left = 564
  Top = 135
  Caption = 'Delphi'#35843#29992'Java'#31867
  ClientHeight = 351
  ClientWidth = 483
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = #23435#20307
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 12
  object DisplayView: TMemo
    Left = 0
    Top = 113
    Width = 483
    Height = 180
    Align = alClient
    ImeName = #20013#25991'('#31616#20307') - '#25628#29399#20116#31508#36755#20837#27861
    ScrollBars = ssVertical
    TabOrder = 0
    WordWrap = False
  end
  object Panel1: TPanel
    Left = 0
    Top = 293
    Width = 483
    Height = 58
    Align = alBottom
    TabOrder = 1
    ExplicitTop = 480
    ExplicitWidth = 739
    DesignSize = (
      483
      58)
    object btnInvoking: TButton
      Left = 255
      Top = 19
      Width = 74
      Height = 23
      Anchors = [akTop, akRight]
      Caption = #35843#29992
      TabOrder = 0
      OnClick = btnInvokingClick
      ExplicitLeft = 511
    end
    object btnExit: TButton
      Left = 347
      Top = 19
      Width = 74
      Height = 23
      Anchors = [akTop, akRight]
      Caption = #36864#20986
      TabOrder = 1
      OnClick = btnExitClick
      ExplicitLeft = 603
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 0
    Width = 483
    Height = 113
    Align = alTop
    TabOrder = 2
    ExplicitLeft = 8
    ExplicitTop = 8
    ExplicitWidth = 739
    object lblClassName: TLabel
      Left = 42
      Top = 24
      Width = 36
      Height = 12
      Caption = #31867#21517#65306
    end
    object lblMethodName: TLabel
      Left = 31
      Top = 53
      Width = 48
      Height = 12
      Caption = #26041#27861#21517#65306
    end
    object lblData: TLabel
      Left = 31
      Top = 82
      Width = 48
      Height = 12
      Caption = #21442#25968#20540#65306
    end
    object edtClassName: TEdit
      Left = 74
      Top = 16
      Width = 376
      Height = 20
      ImeName = #20013#25991'('#31616#20307') - '#25628#29399#20116#31508#36755#20837#27861
      TabOrder = 0
      Text = 'com/teclick/arch/test/HelloWorld'
    end
    object edtMethodName: TEdit
      Left = 74
      Top = 45
      Width = 376
      Height = 20
      ImeName = #20013#25991'('#31616#20307') - '#25628#29399#20116#31508#36755#20837#27861
      TabOrder = 1
      Text = 'showContext'
    end
    object edtData: TEdit
      Left = 74
      Top = 74
      Width = 376
      Height = 20
      ImeName = #20013#25991'('#31616#20307') - '#25628#29399#20116#31508#36755#20837#27861
      TabOrder = 2
      Text = 'English '#20013#25991
    end
  end
end
