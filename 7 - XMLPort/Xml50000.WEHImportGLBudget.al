xmlport 50000 "WEH_Import G/L Budget"
{
    Format = VariableText;
    Direction = Export;
    UseRequestPage = true;
    Caption = 'Import G/L Budget';

    schema
    {
        textelement(ImportDataLandOwner)
        {
            trigger OnBeforePassVariable()
            begin
                ImportInBufferTable;
                ProcessBufferTable;
            end;
        }
    }

    requestpage
    {
        layout
        {
            area(content)
            {
                group(Options)
                {
                    Caption = 'Import from';
                    field("File Name"; UploadFileName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'File Name';
                        Editable = false;
                        trigger OnAssistEdit()
                        begin
                            UploadFileName := FileMgt.UploadFile('Upload File', '');
                            if UploadFileName <> '' then
                                SheetName := TmpExcelBuf.SelectSheetsName(UploadFileName);
                        end;
                    }
                    field("Sheet Name"; SheetName)
                    {
                        ApplicationArea = Basic, Suite;
                        Caption = 'Sheet Name';
                        Editable = false;
                        trigger OnAssistEdit()
                        begin
                            SheetName := TmpExcelBuf.SelectSheetsName(UploadFileName);
                        end;
                    }
                }
            }
        }
    }

    trigger OnPreXmlPort()
    begin
        TmpExcelBuf.DELETEALL;
        TmpExcelBuf.OpenBook(UploadFileName, SheetName);
        TmpExcelBuf.ReadSheet;
    end;

    trigger OnPostXmlPort()
    begin
        MESSAGE('Import Budget Complete.');
        ERROR('');
    end;

    procedure ImportInBufferTable()
    begin
        IF TmpExcelBuf.FINDSET THEN
            REPEAT
                IF TmpExcelBuf."Row No." <> 1 THEN BEGIN
                    CASE TmpExcelBuf."Column No." OF
                        1:
                            TmpGLBudgetEntryImpBuf."G/L Account No." := TmpExcelBuf."Cell Value as Text";
                        2:
                            TmpGLBudgetEntryImpBuf.Description := TmpExcelBuf."Cell Value as Text";
                        3:
                            TmpGLBudgetEntryImpBuf."Global Dimension 1 Code" := TmpExcelBuf."Cell Value as Text";
                        4:
                            TmpGLBudgetEntryImpBuf."Global Dimension 2 Code" := TmpExcelBuf."Cell Value as Text";
                        //5:
                        //TmpGLBudgetEntryImpBuf."Budget Dimension 1 Code" := TmpExcelBuf."Cell Value as Text";
                        //6:
                        //TmpGLBudgetEntryImpBuf."Budget Dimension 2 Code" := TmpExcelBuf."Cell Value as Text";
                        5:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountJan, TmpExcelBuf."Cell Value as Text");
                        6:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountFeb, TmpExcelBuf."Cell Value as Text");
                        7:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountMar, TmpExcelBuf."Cell Value as Text");
                        8:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountApr, TmpExcelBuf."Cell Value as Text");
                        9:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountMay, TmpExcelBuf."Cell Value as Text");
                        10:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountJun, TmpExcelBuf."Cell Value as Text");
                        11:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountJul, TmpExcelBuf."Cell Value as Text");
                        12:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountAug, TmpExcelBuf."Cell Value as Text");
                        13:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountSep, TmpExcelBuf."Cell Value as Text");
                        14:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountOct, TmpExcelBuf."Cell Value as Text");
                        15:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountNov, TmpExcelBuf."Cell Value as Text");
                        16:
                            Evaluate(TmpGLBudgetEntryImpBuf.AmountDec, TmpExcelBuf."Cell Value as Text");
                        17:
                            Evaluate(TmpGLBudgetEntryImpBuf."Budget Type", TmpExcelBuf."Cell Value as Text");
                        18:
                            TmpGLBudgetEntryImpBuf."Budget Name" := TmpExcelBuf."Cell Value as Text";
                        19:
                            TmpGLBudgetEntryImpBuf.Remark := TmpExcelBuf."Cell Value as Text";
                    //22:
                    //TmpGLBudgetEntryImpBuf."Budget Dimension 3 Code" := TmpExcelBuf."Cell Value as Text";
                    //23:
                    //TmpGLBudgetEntryImpBuf."Budget Dimension 4 Code" := TmpExcelBuf."Cell Value as Text";
                    END;

                    IF TmpExcelBuf."Column No." = 1 THEN BEGIN
                        EntryNo += 1;
                        TmpGLBudgetEntryImpBuf."Entry No." := EntryNo;
                        TmpGLBudgetEntryImpBuf.INSERT;
                    END ELSE BEGIN
                        IF TmpExcelBuf."Column No." > 1 THEN
                            TmpGLBudgetEntryImpBuf.MODIFY;
                    END;
                END;
            UNTIL TmpExcelBuf.NEXT() = 0;
    end;

    procedure ProcessBufferTable()
    begin
        Window.OPEN(Text50001);
        Window.UPDATE(2, TmpGLBudgetEntryImpBuf.COUNT);
        IF TmpGLBudgetEntryImpBuf.FINDSET THEN
            REPEAT
                i += 1;
                Window.UPDATE(1, i);
                GLBudgetEntry.Init;
                GLBudgetEntry."Entry No." := GLBudgetEntry.LastEntryNo;
                GLBudgetEntry."G/L Account No." := TmpGLBudgetEntryImpBuf."G/L Account No.";
                GLBudgetEntry.Description := TmpGLBudgetEntryImpBuf.Description;
                GLBudgetEntry."Global Dimension 1 Code" := TmpGLBudgetEntryImpBuf."Global Dimension 1 Code";
                GLBudgetEntry."Global Dimension 2 Code" := TmpGLBudgetEntryImpBuf."Global Dimension 2 Code";
                GLBudgetEntry."Budget Dimension 1 Code" := TmpGLBudgetEntryImpBuf."Budget Dimension 1 Code";
                GLBudgetEntry."Budget Dimension 2 Code" := TmpGLBudgetEntryImpBuf."Budget Dimension 2 Code";
                GLBudgetEntry.AmountJan := TmpGLBudgetEntryImpBuf.AmountJan;
                GLBudgetEntry.AmountFeb := TmpGLBudgetEntryImpBuf.AmountFeb;
                GLBudgetEntry.AmountMar := TmpGLBudgetEntryImpBuf.AmountMar;
                GLBudgetEntry.AmountApr := TmpGLBudgetEntryImpBuf.AmountApr;
                GLBudgetEntry.AmountMay := TmpGLBudgetEntryImpBuf.AmountMay;
                GLBudgetEntry.AmountJun := TmpGLBudgetEntryImpBuf.AmountJun;
                GLBudgetEntry.AmountJul := TmpGLBudgetEntryImpBuf.AmountJul;
                GLBudgetEntry.AmountAug := TmpGLBudgetEntryImpBuf.AmountAug;
                GLBudgetEntry.AmountSep := TmpGLBudgetEntryImpBuf.AmountSep;
                GLBudgetEntry.AmountOct := TmpGLBudgetEntryImpBuf.AmountOct;
                GLBudgetEntry.AmountNov := TmpGLBudgetEntryImpBuf.AmountNov;
                GLBudgetEntry.AmountDec := TmpGLBudgetEntryImpBuf.AmountDec;
                GLBudgetEntry."Budget Type" := TmpGLBudgetEntryImpBuf."Budget Type";
                GLBudgetEntry."Budget Name" := TmpGLBudgetEntryImpBuf."Budget Name";
                GLBudgetEntry.Remark := TmpGLBudgetEntryImpBuf.Remark;
                GLBudgetEntry."Budget Dimension 3 Code" := TmpGLBudgetEntryImpBuf."Budget Dimension 3 Code";
                GLBudgetEntry."Budget Dimension 4 Code" := TmpGLBudgetEntryImpBuf."Budget Dimension 4 Code";
                GLBudgetEntry.insert;
            UNTIL TmpGLBudgetEntryImpBuf.NEXT = 0;
        COMMIT;
        Window.CLOSE;
    end;

    var
        UploadFileName: Text;
        SheetName: Text;
        FileMgt: Codeunit "File Management";
        TmpGLBudgetEntryImpBuf: Record "WEH_G/L Budget Entry_TMP" temporary;
        TmpExcelBuf: Record "Excel Buffer" temporary;
        Window: Dialog;
        i: Integer;
        UpdateData: Boolean;
        GLBudgetEntry: Record "WEH_G/L Budget Entry_TMP";
        Text006: label 'Import Excel File';
        Text50000: label 'There are lines on the Form. Please delete the lines before importing the file.';
        Text50001: label 'Creating #1########## of #2############';
        EntryNo: Integer;
}
