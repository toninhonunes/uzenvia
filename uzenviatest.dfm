object Form1: TForm1
  Left = 247
  Top = 114
  Width = 869
  Height = 253
  Caption = 'Envio de SMS Zenvia Usando REST API'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object Memo1: TMemo
    Left = 0
    Top = 0
    Width = 861
    Height = 141
    Align = alTop
    Lines.Strings = (
      'Memo1')
    TabOrder = 0
  end
  object Button1: TButton
    Left = 376
    Top = 185
    Width = 75
    Height = 25
    Caption = 'Enviar'
    TabOrder = 1
    OnClick = Button1Click
  end
end
